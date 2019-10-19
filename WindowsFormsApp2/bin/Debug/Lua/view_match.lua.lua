local match_info = {}
local g_is_old_match_visible = false
local g_portrait_path = "$icon/portrait/"
local cur_player
function build_info(panel, info_table)
  for i = 1, 8 do
    if info_table[i] == nil then
      info_table[i] = 0
    end
  end
  panel:search("win_text").text = info_table[1]
  panel:search("lose_text").text = info_table[2]
  panel:search("dogfall_text").text = info_table[3]
  panel:search("max_win_text").text = info_table[4]
  panel:search("score_text").text = info_table[5]
  panel:search("rank_text").text = info_table[7]
  panel:search("rank_score").text = info_table[8]
  if info_table[1] == 0 and info_table[2] == 0 and info_table[3] == 0 then
    panel:search("win_rate_text").text = "0%"
  else
    local max_num = info_table[1] + info_table[2] + info_table[3]
    local rate = info_table[1] / max_num
    panel:search("win_rate_text").text = string.format("%.2f%%", rate * 100)
  end
end
function on_match_init(ctrl)
  match_info = {arena = g_arena_rank_info, dooaltar = g_dooaltar_info}
  local flag_table = {}
  for i, v in pairs(match_info) do
    build_info(v, flag_table)
  end
  history_btn0.press = true
  history_btn1.press = true
  g_arena_rank_info.visible = true
  g_dooaltar_info.visible = true
end
function on_self_arena(obj)
  local flag_table = {}
  for i = bo2.ePlayerFlagInt32_ArenaWin, bo2.ePlayerFlagInt32_ArenaScore do
    table.insert(flag_table, obj:get_flag32(i))
  end
  build_info(g_arena_info, flag_table)
end
function on_self_arena_rank(obj, ft, idx)
  local flag_table = {}
  flag_table[1] = obj:get_flag32(bo2.ePlayerFlagInt32_ArenaRankWin)
  flag_table[2] = obj:get_flag32(bo2.ePlayerFlagInt32_ArenaRankLose)
  flag_table[4] = obj:get_flag16(bo2.ePlayerFlagInt16_ArenaElo_1V1_EncliseswinCount)
  local excel = obj:GetPlayerArenaRank()
  local get_excel_text = function(excel)
    local excel_text = bo2.gv_text:find(excel.desc_id)
    return excel_text.text
  end
  if excel then
    local next_excel = bo2.gv_arena_rank:find(excel.id + 1)
    flag_table[7] = get_excel_text(excel)
    local current_score = obj:get_flag32(bo2.ePlayerFlagInt32_ArenaRankScore)
    if next_excel ~= nil then
      flag_table[8] = sys.format(L("%d/%d"), current_score, next_excel.min_rank_score)
    else
      flag_table[8] = sys.format(L("%d"), current_score)
    end
  end
  build_info(g_arena_rank_info, flag_table)
end
function on_self_doo(obj)
  local flag_table = {}
  if g_is_old_match_visible == true then
    for i = bo2.ePlayerFlagInt16_DooOldWin, bo2.ePlayerFlagInt16_DooOldScore do
      table.insert(flag_table, obj:get_flag16(i))
    end
  else
    for i = bo2.ePlayerFlagInt16_DooNowWin, bo2.ePlayerFlagInt16_DooNowScore do
      table.insert(flag_table, obj:get_flag16(i))
    end
  end
  build_info(g_dooaltar_info, flag_table)
end
function onOldClick(btn)
  g_is_old_match_visible = not g_is_old_match_visible
  g_is_old_match_visible = not g_is_old_match_visible
  g_dooaltar_info.visible = true
  on_self_doo(cur_player)
  bo2.PlaySound2D(578)
end
function on_match_visible(w, vis)
  if vis then
    gx_player_info:search("level").text = sys.format("Lv%d", cur_player:get_atb(bo2.eAtb_Level))
    local portrait_id = cur_player:get_flag32(bo2.ePlayerFlagInt32_Portrait)
    gx_player_info:search("portrait").image = g_portrait_path .. bo2.gv_portrait:find(portrait_id).icon .. ".png"
    local pro = cur_player:get_atb(bo2.eAtb_Cha_Profession)
    local n = bo2.gv_profession_list:find(pro)
    local dmg = n.damage
    local f = gx_player_info:search("job")
    if dmg == 1 then
      f.xcolor = "FF608CD9"
    else
      f.xcolor = "FFEE5544"
    end
    f.image = sys.format("$image/personal/32x32/%d.png|0,0,27,30", n.career)
    updata(cur_player)
  end
end
function updata(player)
  cur_player = player
  on_self_arena(cur_player)
  on_self_doo(cur_player)
  on_self_act3v3(cur_player)
  on_self_arena_rank(cur_player)
end
function on_self_act3v3(obj, ft, idx)
  local flag_table = {}
  for i = bo2.ePlayerFlagInt16_Act3v3PersonalWin, bo2.ePlayerFlagInt16_Act3v3TotalCnt do
    table.insert(flag_table, obj:get_flag16(i))
  end
  g_act3v3_info:search("personal_win").text = flag_table[1]
  g_act3v3_info:search("team_win").text = flag_table[2]
  g_act3v3_info:search("total_cnt").text = flag_table[3]
end
function onChangeArenaOrAct3v3(btn)
  g_arena_info.visible = false
  g_act3v3_info.visible = true
  g_arena_rank_info.visible = false
  bo2.PlaySound2D(578)
end
function onChangeArenaOrAct3v3_0(btn)
  g_arena_info.visible = true
  g_act3v3_info.visible = false
  g_arena_rank_info.visible = false
  bo2.PlaySound2D(578)
end
function onChangeArenaOrAct3v3_1(btn)
  g_arena_info.visible = false
  g_act3v3_info.visible = false
  g_arena_rank_info.visible = true
  bo2.PlaySound2D(578)
end
