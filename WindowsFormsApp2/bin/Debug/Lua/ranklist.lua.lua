g_cur_rank_win = {
  win = 0,
  list = 0,
  input_mask = 0,
  search_text = 0,
  step_btn = 0,
  myself_info = 0
}
g_rank_list_cur = {}
g_rank_list = {}
g_cur_page = 0
g_max_page = 0
MAX_COUNT = 13
g_rank_id = {arena_rank = 1111, dooaltar_rank = 1112}
function getIntPart(x)
  if x <= 0 then
    return 0
  end
  if math.ceil(x) == x then
    x = math.ceil(x) - 1
  else
    x = math.ceil(x)
  end
  return x
end
function update_btn_enable()
  local btn_head = true
  local btn_foot = true
  local btn_prev = true
  local btn_next = true
  if g_cur_page == g_max_page then
    btn_next = false
    btn_foot = false
  end
  if g_cur_page == 1 then
    btn_head = false
    btn_prev = false
  end
  g_cur_rank_win.step_btn:search("btn_head").enable = btn_head
  g_cur_rank_win.step_btn:search("btn_foot").enable = btn_foot
  g_cur_rank_win.step_btn:search("btn_prev").enable = btn_prev
  g_cur_rank_win.step_btn:search("btn_next").enable = btn_next
end
function on_stepping_head(btn)
  g_cur_page = 1
  show_rank_list(g_rank_list_cur)
end
function on_stepping_foot(btn)
  g_cur_page = g_max_page
  show_rank_list(g_rank_list_cur)
end
function on_stepping_prev(btn)
  g_cur_page = g_cur_page - 1
  show_rank_list(g_rank_list_cur)
end
function on_stepping_next(btn)
  g_cur_page = g_cur_page + 1
  show_rank_list(g_rank_list_cur)
end
local rank_cd_group = {}
function on_send_GetRankDataReq(id)
  if rank_cd_group[id] ~= nil and sys.dtick(sys.tick(), rank_cd_group[id]) < 60000 then
    return
  end
  rank_cd_group[id] = sys.tick()
  local v = sys.variant()
  v:set(packet.key.ranklist_id, id)
  bo2.send_wrap(packet.eSTC_Fake_GetRankDataReq, v)
end
function change_win(win)
  g_cur_rank_win.win = win
  g_cur_rank_win.list = win:search("rank_list")
  g_cur_rank_win.input_mask = win:search("input_mask")
  g_cur_rank_win.search_text = win:search("search_text")
  g_cur_rank_win.step_btn = win:search("step_btn")
  g_cur_rank_win.myself_info = win:search("myself_info")
  ui_match.g_cur_page_win = win
end
function GetRankData(id)
  local v = sys.variant()
  v:set(packet.key.ranklist_id, id)
  bo2.send_wrap(packet.eSTC_Fake_GetRankDataReq, v)
end
function OnRankWinVisible(win, vis)
  if vis then
    change_win(win)
    local id = 1111
    if win.name == L("dooaltar_rank") then
      id = 1112
    end
    if win.name == L("act3v3_rank") then
      id = 1113
    end
    on_send_GetRankDataReq(id)
  end
end
function on_keydown_return(ctrl, key, keyflag)
  if key == ui.VK_RETURN and keyflag.down then
    OnSearchClick(ctrl)
  end
end
function on_input_change(tb, txt)
  g_cur_rank_win.input_mask.visible = tb.text.empty
end
function onSelfInfoClick(btn)
  if ui_personal.w_personal.visible == true then
    local page = ui_widget.ui_tab.get_show_page(ui_personal.w_personal)
    if page.visible == true then
      ui_personal.w_personal.visible = false
      return
    end
  end
  ui_personal.w_personal.visible = true
  ui_widget.ui_tab.show_page(ui_personal.w_personal, "match", true)
end
function OnSearchClick(btn)
  if #g_cur_rank_win.search_text.text == 0 or #g_rank_list_cur == 0 then
    return
  end
  g_cur_rank_win.search_text.focus = false
  g_cur_rank_win.list:item_clear()
  local search_text = tostring(g_cur_rank_win.search_text.text)
  local search_table = {}
  for i = 1, #g_rank_list_cur do
    local item = g_rank_list_cur[i]
    if string.find(item.name, search_text) ~= nil then
      table.insert(search_table, item)
    end
  end
  if #search_table == 0 then
    g_cur_page = 1
    g_max_page = 1
    update_btn_enable()
    return
  end
  g_rank_list_cur = search_table
  g_cur_page = 1
  g_max_page = math.ceil(#g_rank_list_cur / MAX_COUNT)
  show_rank_list(g_rank_list_cur)
end
local get_profession_name = function(id)
  local pro_excel = bo2.gv_profession_list:find(id)
  if pro_excel ~= nil then
    return pro_excel.name
  end
end
local get_camp_name = function(id)
  if id == bo2.eCamp_Blade then
    return ui.get_text("phase|camp_blade")
  else
    return ui.get_text("phase|camp_sword")
  end
  return "-"
end
function insert_rank_item(table_item)
  local item = g_cur_rank_win.list:item_append()
  item:load_style("$frame/match/cmn_rank.xml", "rank_item")
  item:search("rank").text = table_item.rank
  item:search("scoure").text = table_item.scoure
  item:search("name").text = table_item.name
  item:search("career").text = get_profession_name(table_item.profession)
  item:search("level").text = table_item.level
  item:search("camp").text = get_camp_name(table_item.camp)
  item:search("guild").text = table_item.guild
end
function insert_myself_rank(table_item)
  local my_info = g_cur_rank_win.myself_info
  my_info:search("rank"):search("text").text = table_item.rank
  my_info:search("scoure"):search("text").text = table_item.scoure
  my_info:search("name"):search("text").text = table_item.name
  my_info:search("profession").text = get_profession_name(table_item.profession)
  my_info:search("level").text = table_item.level
  my_info:search("camp").text = get_camp_name(table_item.camp)
  my_info:search("guild").text = table_item.guild
end
function show_rank_list(rank_list)
  update_btn_enable()
  g_cur_rank_win.list:item_clear()
  local began_idx = (g_cur_page - 1) * MAX_COUNT + 1
  local end_idx = g_cur_page * MAX_COUNT
  if end_idx > #rank_list then
    end_idx = #rank_list
  end
  for i = began_idx, end_idx do
    insert_rank_item(rank_list[i])
  end
  g_cur_rank_win.step_btn:search("lb_text").text = sys.format("%d/%d", g_cur_page, g_max_page)
end
function handleShowRankList(cmd, data)
  local datalist_v = data:get(packet.key.ranklist_alllinedata)
  if datalist_v.size <= 0 then
    return
  end
  g_cur_rank_win.list:item_clear()
  g_rank_list_cur = {}
  g_rank_list = {}
  local my_info = g_cur_rank_win.myself_info
  my_info:search("rank"):search("text").text = "-"
  my_info:search("scoure"):search("text").text = "-"
  my_info:search("name"):search("text").text = "-"
  for i = 0, datalist_v.size - 1 do
    local info = datalist_v:get(i)
    local list_item = {
      rank = info:get(packet.key.ranklist_id).v_int,
      scoure = info:get(packet.key.ranklist_data).v_int,
      name = info:get(packet.key.cha_name).v_string,
      profession = info:get(packet.key.player_career).v_int,
      level = info:get(packet.key.cha_level).v_int,
      camp = info:get(packet.key.camp_id).v_int,
      guild = info:get(packet.key.guild_name).v_string
    }
    table.insert(g_rank_list, list_item)
    if list_item.name == bo2.player.name then
      insert_myself_rank(list_item)
    end
  end
  if #g_rank_list == 0 then
    g_cur_page = 1
    g_max_page = 1
    update_btn_enable()
    return
  end
  g_rank_list_cur = g_rank_list
  g_cur_page = 1
  g_max_page = math.ceil(#g_rank_list_cur / MAX_COUNT)
  show_rank_list(g_rank_list_cur)
end
