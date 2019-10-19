local reg = ui_packet.game_recv_signal_insert
local sig = "ui_scn_matchunit.packet_handler"
local history_item_uri = L("$frame/scn_matchunit/scn_matchunit.xml")
local history_item_1 = L("fight_history_item")
local history_item_2 = L("fight_history_item2")
local match_tie_uri = L("$image/match_cmn/match_tie1.png")
local match_win_uri = L("$image/match_cmn/match_win1.png")
local match_lose_uri = L("$image/match_cmn/match_lose1.png")
local knight_excel_id = 0
is_knight_fight = false
g_match_id = 0
g_scn_onlyid = 0
g_fight_list = {}
g_item_back_color = {}
g_is_in_scn = false
g_members = {}
g_mini_members = {}
g_cur_time = 0
g_spectator_count = 0
g_fight_history = {}
g_match_type = 0
local g_match_type_text = ""
local g_link_player_name = {
  [0] = "",
  [1] = ""
}
function insert_fight_history_data(rst)
  if rst == 0 then
    g_fight_history._max = g_fight_history._max + 1
    g_fight_history.win = g_fight_history.win + 1
  elseif rst == 1 then
    g_fight_history._max = g_fight_history._max + 1
  end
end
function on_status_init(muliti)
  if muliti ~= true then
    g_fight_list = {
      [0] = gx_fighter_single_info_left,
      [1] = gx_fighter_single_info_right
    }
    w_single_fighter.visible = true
    w_muliti_fighter.visible = false
  else
    g_fight_list = {
      [0] = gx_fighter_muliti_info_left,
      [1] = gx_fighter_muliti_info_right
    }
    w_single_fighter.visible = false
    w_muliti_fighter.visible = true
  end
  g_members.left_size = 0
  g_members.right_size = 0
  for i = 0, 4 do
    local name = sys.format(L("item_right%d"), i)
    local name2 = sys.format(L("item_left%d"), i)
    gx_minimum:search(name).visible = false
    gx_minimum:search(name2).visible = false
    w_muliti_fighter:search(name).visible = false
    w_muliti_fighter:search(name2).visible = false
  end
end
function get_career_idx(val)
  local pro = bo2.gv_profession_list:find(val)
  if pro == nil then
    return -1
  end
  return pro.career - 1
end
function set_career_color(pic, career_idx)
  local pro = bo2.gv_profession_list:find(career_idx)
  if pro ~= nil then
    ui_portrait.make_career_color(pic, pro)
  end
end
function on_career_tip_make(tip)
  local panel = tip.owner.parent
  local career_panel = panel:search("job")
  local pro_list = bo2.gv_profession_list:find(career_panel.svar)
  if pro_list ~= nil then
    text = sys.format("%s", pro_list.name)
    ui_widget.tip_make_view(tip.view, text)
  end
end
function on_selected_item(panel)
  bo2.ChgCamera(panel.svar)
  bo2.player:SetTarget(panel.svar)
end
function on_mouse_muliti_item(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    if g_members[bo2.player.name] ~= nil then
      return
    end
    if not g_is_in_scn then
      return
    end
    local obj = bo2.findobj(panel.svar)
    if sys.check(obj) then
      local cur_hp = obj:get_atb(bo2.eAtb_HP)
      if cur_hp == 0 then
        return
      end
    end
    on_selected_item(panel)
  end
end
function on_mouse_mini_item(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    if g_mini_members[bo2.player.name] ~= nil then
      return
    end
    if not g_is_in_scn then
      return
    end
    local obj = bo2.findobj(panel.svar)
    if sys.check(obj) then
      local cur_hp = obj:get_atb(bo2.eAtb_HP)
      if cur_hp == 0 then
        return
      end
    end
    on_selected_item(panel)
  end
end
function on_mouse_show_hp(panel, msg, pos, wheel)
  if msg == ui.mouse_inner then
    local hp_val = panel:search("hp_val")
    if sys.check(hp_val) then
      hp_val.visible = true
    end
  elseif msg == ui.mouse_outer then
    local hp_val = panel:search("hp_val")
    if sys.check(hp_val) then
      hp_val.visible = false
    end
  elseif msg == ui.mouse_lbutton_click then
    if g_members[bo2.player.name] ~= nil then
      return
    end
    if not g_is_in_scn then
      return
    end
    on_selected_item(panel)
  end
end
function update_hp_pic(item, cur_hp, max_hp)
  local hp_min2 = item:search("hp_main2")
  if sys.check(hp_min2) then
    local hp_left1 = hp_min2:search("hp_left1")
    local hp_left2 = hp_min2:search("hp_left2")
    local dx = 155 * (cur_hp / max_hp)
    dx = 155 - dx
    if dx < 27 then
      hp_left1.dx = 27 - dx
      hp_left2.dx = 128
    else
      hp_left1.dx = 0
      hp_left2.dx = 155 - dx
    end
  else
    item:search("hp_main").dx = 155 * (cur_hp / max_hp)
  end
end
function updata_mini_item_hp(item, _cur_hp, _max_hp)
  local hp_item = item:search("hp")
  hp_item.tip.text = sys.format("%d/%d", _cur_hp, _max_hp)
  hp_item.dx = 44 * _cur_hp / _max_hp
  local mtf_hp_data = {
    pre_string = hp_item.svar,
    cur_hp = _cur_hp,
    max_hp = _max_hp
  }
  item.tip.text = ui_widget.merge_mtf(mtf_hp_data, ui.get_text("scn_matchunit|mini_item_hp_tips"))
end
function RenderMiniPlayerItem(item, var, type, bUpdate, side_name)
  item.visible = true
  local player_name = var:get(packet.key.cha_name).v_string
  local portrait_item = item:search("portrait")
  local _level = var:get(packet.key.cha_level).v_int
  if type == nil or type == 0 then
    local portrait = var:get(packet.key.cha_portrait).v_int
    local por_list = bo2.gv_portrait:find(portrait)
    portrait_item.image = sys.format("$icon/portrait/%s.png", por_list.icon)
  elseif type == 1 then
    local portrait = var:get(packet.key.cha_portrait).v_string
    portrait_item.image = sys.format("$icon/portrait/%s", portrait)
    portrait_item.svar = portrait
  end
  local handle = var:get(packet.key.scnobj_handle).v_int
  item.svar = handle
  local _cur_hp = var:get(packet.key.cha_cur_hp).v_int
  local _max_hp = var:get(packet.key.cha_max_hp).v_int
  local hp_item = item:search("hp")
  hp_item.tip.text = sys.format("%d/%d", _cur_hp, _max_hp)
  local mtf_data_string
  if type ~= 1 then
    local career = var:get(packet.key.player_profession).v_int
    pro = bo2.gv_profession_list:find(career)
    local mtf_data = {
      name = player_name,
      count = cn_default_item_num,
      career = pro.name,
      level = _level
    }
    mtf_data_string = ui_widget.merge_mtf(mtf_data, ui.get_text("scn_matchunit|mini_item_tips"))
  else
    local mtf_data = {
      name = player_name,
      count = cn_default_item_num,
      level = _level
    }
    mtf_data_string = ui_widget.merge_mtf(mtf_data, ui.get_text("scn_matchunit|mini_item_tips2"))
  end
  hp_item.svar = mtf_data_string
  updata_mini_item_hp(item, _cur_hp, _max_hp)
  if bUpdate then
    local sub_item = gx_minimum:search(side_name)
    if sys.check(sub_item) then
      local name = RenderMiniPlayerItem(sub_item, var, type, false)
      g_mini_members[player_name] = sub_item
    end
  end
  return player_name
end
function RenderPlayerItem(item, var, side, type)
  local name = var:get(packet.key.cha_name).v_string
  local level = var:get(packet.key.cha_level).v_int
  item:search("player_level").text = sys.format("Lv%d", level)
  item:search("player_name").text = sys.format("%s", name)
  if type == nil or type == 0 then
    local portrait = var:get(packet.key.cha_portrait).v_int
    local por_list = bo2.gv_portrait:find(portrait)
    item:search("portrait").image = sys.format("$icon/portrait/%s.png", por_list.icon)
    local career = var:get(packet.key.player_profession).v_int
    local career_panel = item:search("job")
    local career_idx = get_career_idx(career)
    if career_idx >= 0 then
      career_panel.image = sys.format("$image/personal/32x32/%d.png|0,0,27,30", career_idx + 1)
      set_career_color(career_panel, career)
      career_panel.svar = career
      career_panel.parent.visible = true
    else
      career_panel.visible = false
    end
  elseif type == 1 then
    local portrait = var:get(packet.key.cha_portrait).v_string
    item:search("portrait").image = sys.format("$icon/portrait/%s", portrait)
    item:search("portrait").svar = portrait
    local career = var:get(packet.key.player_profession).v_int
    local career_panel = item:search("job")
    career_panel.parent.visible = false
  end
  local handle = var:get(packet.key.scnobj_handle).v_int
  item.svar = handle
  local cur_hp = var:get(packet.key.cha_cur_hp).v_int
  local max_hp = var:get(packet.key.cha_max_hp).v_int
  item:search("hp_val").text = sys.format("%d/%d", cur_hp, max_hp)
  update_hp_pic(item, cur_hp, max_hp)
  if g_is_in_scn then
    local sub_item
    if side == 0 then
      sub_item = gx_minimum:search(L("item_left0"))
    else
      sub_item = gx_minimum:search(L("item_right0"))
    end
    if sys.check(sub_item) then
      local name = RenderMiniPlayerItem(sub_item, var, type, false)
      g_mini_members[name] = sub_item
    end
  end
  return name
end
function add_arena_member(var, type)
  local side = var:get(packet.key.arena_side).v_int
  if w_single_fighter.visible then
    local item = g_fight_list[side]
    local name = RenderPlayerItem(item, var, side, type)
    g_members[name] = item
  else
    local side_index = 0
    local item_name = 0
    if side == 0 then
      side_index = g_members.left_size
      item_name = sys.format(L("item_left%d"), side_index)
    else
      side_index = g_members.right_size
      item_name = sys.format(L("item_right%d"), side_index)
    end
    local list = g_fight_list[side]
    local item = list:search(item_name)
    local name = RenderMiniPlayerItem(item, var, type, true, item_name)
    g_members[name] = item
  end
  if g_link_player_name[side] == "" or g_link_player_name[side] == nil then
    g_link_player_name[side] = var:get(packet.key.cha_name).v_string
  end
  if side == 0 then
    g_members.left_size = g_members.left_size + 1
  else
    g_members.right_size = g_members.right_size + 1
  end
end
function ClickGoinMatchScn()
  local var = sys.variant()
  var:set(packet.key.scnmatch_id, g_match_id)
  var:set(packet.key.scn_onlyid, g_scn_onlyid)
  if ui_scn_matchunit.g_match_type == bo2.eMatchType_TheBestFighter then
    bo2.send_variant(packet.eCTS_TheBestFighter_GotoScn, var)
  else
    if is_knight_fight then
      var:set(packet.key.is_knight_fight, 1)
    end
    bo2.send_variant(packet.eCTS_UI_GoinMatchScn, var)
  end
  gx_status_window.visible = false
end
function GoinMatchScn(match_id)
  local var = sys.variant()
  var:set(packet.key.scn_onlyid, match_id)
  if is_knight_fight then
    var:set(packet.key.is_knight_fight, 1)
  end
  bo2.send_variant(packet.eCTS_UI_GoinMatchScn, var)
  gx_status_window.visible = false
end
function on_toggle_click_close(btn)
end
function auto_select()
  if g_members[bo2.player.name] ~= nil then
    return
  end
  if w_single_fighter.visible == true then
    on_selected_item(gx_fighter_single_info_left)
  else
    on_selected_item(gx_fighter_muliti_info_left:search(L("item_left0")))
  end
end
function adjust_fighter_list()
  if w_muliti_fighter.visible ~= true then
    return
  end
  local max_size = g_members.left_size
  local max_side = 0
  if max_size < g_members.right_size then
    max_size = g_members.right_size
    max_side = 1
  end
  local set_divider = function(item, size)
    local top_divider = item:search("top_divider")
    local buttom_divider = item:search("buttom_divider")
    if size <= 3 then
      top_divider.visible = true
      buttom_divider.visible = false
      top_divider.dock = L("pin_xy")
      local margin_dx = (3 - size) * 44 / 2
      top_divider.margin = ui.rect(margin_dx, 2, 0, 0)
    else
      top_divider.dock = L("pin_x1y1")
      top_divider.visible = true
      buttom_divider.visible = true
      top_divider.margin = ui.rect(0, 2, 0, 0)
    end
  end
  set_divider(gx_fighter_muliti_info_left, g_members.left_size)
  set_divider(gx_fighter_muliti_info_right, g_members.right_size)
end
function adjust_mini_fighter_list()
  local max_size = g_members.left_size
  local _side = 0
  local margin_size = g_members.left_size - g_members.right_size
  if max_size < g_members.right_size then
    max_size = g_members.right_size
    margin_size = g_members.right_size - g_members.left_size
    _side = 1
  elseif g_members.right_size == max_size then
    _side = -1
    margin_size = 0
  end
  gx_minimum.dy = 195 + 54 * (max_size - 1)
  gx_minimum_fight_list.dy = 54 + 54 * (max_size - 1)
  local left_divider = gx_minimum_fight_list:search(L("left_divider"))
  local right_divider = gx_minimum_fight_list:search(L("right_divider"))
  local margin_dy = 3 + 27 * margin_size
  if _side == 0 then
    left_divider.margin = ui.rect(1, 3, 0, 0)
    right_divider.margin = ui.rect(1, margin_dy, 0, 0)
  else
    right_divider.margin = ui.rect(1, 3, 0, 0)
    left_divider.margin = ui.rect(1, margin_dy, 0, 0)
  end
end
function init_fight_history_list()
  ui_scn_matchunit.gx_history_list:item_clear()
  g_fight_history = {}
  g_fight_history._max = 0
  g_fight_history.win = 0
  g_fight_history.max_count = 0
end
function set_history_item_data(item, item_data, index, nil_data)
  local real_index = index
  local match_count = item:search("match_count")
  if real_index < 10 then
    match_count.image = sys.format(L("$image/match_cmn/match_count/%d.png"), real_index)
  elseif real_index < 100 then
    local match_count_large = item:search("match_count_large")
    match_count.visible = false
    match_count_large.visible = true
    local match_count0 = item:search("match_count0")
    match_count0.image = sys.format(L("$image/match_cmn/match_count/%d.png"), real_index / 10)
    local match_count1 = item:search("match_count1")
    match_count1.image = sys.format(L("$image/match_cmn/match_count/%d.png"), real_index % 10)
  elseif real_index < 1000 then
    local match_count_large = item:search("match_count_big0")
    match_count.visible = false
    match_count_large.visible = true
    local match_count0 = match_count_large:search("match_count0")
    match_count0.image = sys.format(L("$image/match_cmn/match_count/%d.png"), real_index / 100)
    local match_count1 = match_count_large:search("match_count1")
    local coun1 = real_index - math.floor(real_index / 100) * 100
    match_count1.image = sys.format(L("$image/match_cmn/match_count/%d.png"), coun1 / 10)
    local match_count2 = match_count_large:search("match_count2")
    local count1_floor = math.fmod(coun1, 10)
    match_count2.image = sys.format(L("$image/match_cmn/match_count/%d.png"), count1_floor)
    local match_count3 = match_count_large:search("match_count3")
    match_count3.visible = false
  elseif real_index < 10000 then
    local match_count_large = item:search("match_count_big0")
    match_count.visible = false
    match_count_large.visible = true
    local match_count0 = match_count_large:search("match_count0")
    match_count0.image = sys.format(L("$image/match_cmn/match_count/%d.png"), real_index / 1000)
    local match_count1 = match_count_large:search("match_count1")
    local coun1 = real_index - math.floor(real_index / 1000) * 1000
    match_count1.image = sys.format(L("$image/match_cmn/match_count/%d.png"), coun1 / 100)
    local match_count2 = match_count_large:search("match_count2")
    coun1 = coun1 - math.floor(coun1 / 100) * 100
    match_count2.image = sys.format(L("$image/match_cmn/match_count/%d.png"), coun1 / 10)
    local count1_floor = math.fmod(coun1, 10)
    local match_count3 = match_count_large:search("match_count3")
    match_count3.visible = true
    match_count3.image = sys.format(L("$image/match_cmn/match_count/%d.png"), count1_floor)
  else
    local match_count_big = item:search("match_count_big")
    match_count_big.visible = true
    local rb = match_count_big:search(L("count_text"))
    rb.mtf = sys.format(L("%d"), real_index)
  end
  local match_result1 = item:search("match_result1")
  local match_result2 = item:search("match_result2")
  if nil_data == nil then
    match_result1.visible = false
    match_result2.visible = false
    return
  end
  local fight_result = item_data.v_int
  match_result1.visible = true
  match_result2.visible = true
  if fight_result == -1 then
    match_result1.image = match_tie_uri
    match_result2.image = match_tie_uri
  elseif fight_result == 1 then
    match_result1.image = match_win_uri
    match_result2.image = match_lose_uri
  elseif fight_result == 0 then
    match_result1.image = match_lose_uri
    match_result2.image = match_win_uri
  end
end
function test()
  ui_scn_matchunit.gx_status_window.visible = true
  local v = sys.variant()
  local v_data = sys.variant()
  for i = 1, 10100 do
    v_data:set(i, 1)
  end
  g_fight_history._max = 0
  g_fight_history.win = 0
  g_fight_history.max_count = 0
  v:set(packet.key.cmn_dataobj, v_data)
  set_fight_history_data(v)
end
function set_fight_history_data(data)
  local vHistory = data:get(packet.key.cmn_dataobj)
  if sys.check(ui_scn_matchunit.gx_history_list) ~= true then
    return
  end
  local size = vHistory.size
  local list = ui_scn_matchunit.gx_history_list
  for i = 0, size do
    local item = list:item_append()
    local load_style = history_item_1
    if i % 2 ~= 0 then
      load_style = history_item_2
    end
    item:load_style(history_item_uri, load_style)
    if i >= size then
      set_history_item_data(item, nil, i + 1, nil)
      return
    else
      local current_data = vHistory:get(i)
      set_history_item_data(item, current_data, i + 1, false)
      insert_fight_history_data(current_data.v_int)
      g_fight_history.max_count = g_fight_history.max_count + 1
    end
  end
end
function test2()
  g_is_in_scn = true
  ui_scn_matchunit.gx_minimum.visible = true
  g_fight_history._max = 10000
  g_fight_history.win = 1000
  set_mini_panel_history_data()
end
function set_mini_panel_history_data()
  if g_is_in_scn ~= true then
    return
  end
  local set_item_count = function(item, idx, name_1, name_2, name_3)
    local match_count = item:search(name_1)
    local match_count_large = item:search(name_2)
    local match_count_big = item:search(name_3)
    match_count_big.visible = false
    if idx < 10 then
      match_count.image = sys.format(L("$image/match_cmn/%d.png"), idx)
      match_count.visible = true
      match_count_large.visible = false
    elseif idx < 100 then
      match_count.visible = false
      match_count_large.visible = true
      local match_count0 = match_count_large:search("match_count0")
      match_count0.image = sys.format(L("$image/match_cmn/%d.png"), idx / 10)
      local match_count1 = match_count_large:search("match_count1")
      match_count1.image = sys.format(L("$image/match_cmn/%d.png"), idx % 10)
    else
      match_count.visible = false
      match_count_large.visible = false
      match_count_big.visible = true
      match_count_big:search(L("count_text")).mtf = idx
    end
  end
  local win = g_fight_history.win
  if win == nil then
    win = 0
  end
  local win2 = 0
  if g_fight_history._max then
    if g_fight_history.win == nil then
      win2 = g_fight_history._max
    else
      win2 = g_fight_history._max - g_fight_history.win
    end
  end
  set_item_count(gx_match_score, win, "match_count2", "match_count_large1", "match_count_big2")
  set_item_count(gx_match_score, win2, "match_count", "match_count_large", "match_count_big")
end
function handleResultCount(cmn, var)
  local rst_packet = var:get(packet.key.cmn_rst)
  local cm_type = var:get(packet.key.cmn_type)
  local list = ui_scn_matchunit.gx_history_list
  local count = g_fight_history.max_count
  if count == nil then
    count = 0
  end
  local function insert_history_data(list, rst, count, nil_rst)
    local item = list:item_append()
    local load_style = history_item_1
    if count % 2 ~= 0 then
      load_style = history_item_2
    end
    item:load_style(history_item_uri, load_style)
    set_history_item_data(item, nil, count, nil)
  end
  local item = list:item_get(count)
  if item ~= nil then
    set_history_item_data(item, rst_packet, count + 1, false)
  end
  insert_fight_history_data(rst_packet.v_int)
  count = count + 2
  insert_history_data(list, nil, count, nil)
  g_fight_history.max_count = g_fight_history.max_count + 1
  set_mini_panel_history_data()
end
function handleShowMatchInfo(cmd, data)
  if g_is_in_scn then
    ui_chat.show_ui_text_id(1700)
    return
  end
  g_members = {}
  g_match_id = data:get(packet.key.scnmatch_id)
  g_scn_onlyid = data:get(packet.key.scn_onlyid)
  g_is_in_scn = data:has(packet.key.arena_in_scn)
  is_knight_fight = data:has(packet.key.is_knight_fight)
  is_seeking_help = data:has(packet.key.is_knight_seeking_help)
  if is_knight_fight then
    knight_excel_id = data:get(packet.key.knight_pk_npc_cha_id).v_int
  end
  if g_is_in_scn then
    bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enter_scn, on_player_enter, "ui_scn_matchunit:on_player_enter")
    bo2.insert_on_scnmsg(bo2.eScnObjKind_Npc, bo2.scnmsg_enter_scn, on_player_enter, "ui_scn_matchunit:on_npc_enter")
  end
  local players = data:get(packet.key.arena_players)
  if players.size == 2 then
    on_status_init(false)
  else
    on_status_init(true)
  end
  for i = 0, players.size - 1 do
    local player = players:get(i)
    local type = 0
    if player:has(packet.key.is_knight) then
      type = 1
    end
    add_arena_member(player, type)
  end
  adjust_fighter_list()
  if g_is_in_scn then
    adjust_mini_fighter_list()
  end
  init_fight_history_list()
  set_fight_history_data(data)
  set_mini_panel_history_data()
  g_spectator_count = data:get(packet.key.player_count).v_int
  local seecount = {count = g_spectator_count}
  gx_btn_seecount.tip.text = ui_widget.merge_mtf(seecount, ui.get_text("scn_matchunit|see"))
  gx_btn_goin.visible = not g_is_in_scn
  gx_btn_goout.visible = g_is_in_scn
  gx_button_match_group.visible = g_is_in_scn
  gx_btn_mute.enable = not is_knight_fight
  gx_btn_mute.visible = true
  gx_btn_mute_disable.visible = false
  gx_btn_applaud.enable = not is_knight_fight
  gx_btn_catcall.enable = not is_knight_fight
  gx_btn_come_on.enable = not is_knight_fight
  gx_btn_seecount.enable = not is_knight_fight
  gx_btn_link.visible = not is_knight_fight
  gx_btn_help.visible = is_knight_fight
  gx_btn_help.enable = is_seeking_help
  ui_handson_teach.w_flicker_knighthelp.visible = is_seeking_help
  ui_handson_teach.w_flicker_knightsee.visible = is_seeking_help
  if g_is_in_scn then
    if g_members[bo2.player.name] == nil then
      bo2.player:SetShow(bo2.eShowType_MatchSpectator, false)
      bo2.SetMatchSpectator(true)
      ui_match_cmn.set_visible(true)
      ui_match_cmn.set_timeinfo_visible(not is_knight_fight)
    else
      on_player_enter(bo2.player)
      ui_widget.ui_wnd.show_notice({
        text = ui.get_text("match|match_notice"),
        timeout = 30
      })
    end
  end
  g_match_type = data:get(packet.key.cmn_type).v_int
  if g_match_type == bo2.eMatchType_ScnPractice then
    g_match_type_text = ui.get_text("scn_matchunit|practice_title")
  elseif g_match_type == bo2.eMatchType_TheBestFighter then
    g_match_type_text = ui.get_text("scn_matchunit|thebestfighter_title")
  else
    g_match_type_text = ui.get_text("scn_matchunit|common_title")
  end
  gx_status_window.visible = true
  local inner_close = gx_status_window:search("inner_close")
  local btn_close = gx_status_window:search("btn_close")
  inner_close.visible = g_is_in_scn
  btn_close.visible = not g_is_in_scn
end
reg(packet.eSTC_UI_ShowMatchScnInfo, handleShowMatchInfo, sig)
function handleActiveHelp(cmd, data)
  is_seeking_help = data:has(packet.key.is_knight_seeking_help)
  gx_btn_help.enable = is_seeking_help
  ui_handson_teach.w_flicker_knighthelp.visible = is_seeking_help
  ui_handson_teach.w_flicker_knightsee.visible = is_seeking_help
  ui_handson_teach.w_tip_knightsee.visible = is_seeking_help
end
reg(packet.eSTC_Knight_Help_2_Spectator, handleActiveHelp, sig)
function handleAskPlayer(cmd, data)
  if data:get(packet.key.ui_window_type).v_int == packet.key.scnmatch_win_type then
    local function on_msg(msg)
      local var = sys.variant()
      var:set(packet.key.scnmatch_id, data:get(packet.key.scnmatch_id))
      var:set(packet.key.cmn_agree_ack, msg.result)
      bo2.send_variant(packet.eCTS_UI_ReplyScnMatchAsk, var)
    end
    local msg = {
      callback = on_msg,
      btn_confirm = true,
      btn_cancel = true,
      modal = false,
      close_on_leavascn = true
    }
    msg.text = ui.get_text("scn_matchunit|askplayer")
    ui_widget.ui_msg_box.show_common(msg)
  end
end
reg(packet.eSTC_UI_OpenWindow, handleAskPlayer, sig)
function on_status_visible(ctrl, vis)
  if not vis and g_is_in_scn then
    gx_minimum.visible = true
    gx_status_min_clock.visible = not is_knight_fight
  end
end
function least_number(src_num, n, direction)
  src_num = tostring(src_num)
  local len = #src_num
  local output = src_num
  if n > len then
    if direction == "R" then
      for i = 1, n - len do
        output = output .. "0"
      end
    else
      for i = 1, n - len do
        output = "0" .. output
      end
    end
  end
  return output
end
function on_timer()
  if g_cur_time <= 0 then
    gx_timer.suspended = true
    return
  end
  g_cur_time = g_cur_time - 1
  local ONE_MINUTE = 60
  local s = ""
  if ONE_MINUTE >= g_cur_time then
    s = sys.format(ui.get_text("match|clock_fmt"), least_number(g_cur_time, 2))
  else
    local minute = math.floor(g_cur_time / ONE_MINUTE)
    local second = g_cur_time % ONE_MINUTE
    s = sys.format(ui.get_text("match|clock_fmt_big"), least_number(minute, 2), least_number(second, 2))
  end
  gx_status_min_clock.text = s
end
function handleMatchScnClock(cmn, var)
  g_cur_time = var:get(packet.key.itemdata_val).v_int
  if g_cur_time == 0 then
    gx_status_min_clock.text = ui.get_text("scn_matchunit|common_time")
    ui_match_cmn.set_timer(0, 0, 0)
    return
  end
  local ONE_MINUTE = 60
  local s = ""
  if ONE_MINUTE >= g_cur_time then
    s = sys.format(ui.get_text("match|clock_fmt"), least_number(g_cur_time, 2))
  else
    local minute = math.floor(g_cur_time / ONE_MINUTE)
    local second = g_cur_time % ONE_MINUTE
    s = sys.format(ui.get_text("match|clock_fmt_big"), least_number(minute, 2), least_number(second, 2))
  end
  local num1 = math.modf(g_cur_time / 100)
  local num2 = math.modf((g_cur_time % 100 - g_cur_time % 10) / 10)
  local num3 = g_cur_time % 10
  ui_match_cmn.set_timer(num1, num2, num3)
  gx_status_min_clock.text = s
  gx_timer.suspended = false
end
reg(packet.eSTC_UI_MatchScnClock, handleMatchScnClock, sig)
function handleCloseWin()
  g_is_in_scn = false
  gx_status_window.visible = false
  local inner_close = gx_status_window:search("inner_close")
  inner_close.visible = false
  local btn_close = gx_status_window:search("btn_close")
  btn_close.visible = true
  gx_minimum.visible = false
  gx_timer.suspended = true
  ui_match_cmn.set_visible(false)
  bo2.SetMatchSpectator(false)
  bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enter_scn, "ui_scn_matchunit:on_player_enter")
  bo2.remove_on_scnmsg(bo2.eScnObjKind_Npc, bo2.scnmsg_enter_scn, "ui_scn_matchunit:on_npc_enter")
  for key, value in pairs(g_members) do
    if key ~= "left_size" and key ~= "right_size" then
      local obj = bo2.findobj(g_members[key].svar)
      if sys.check(obj) then
        obj:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, "ui_scn_matchunit:on_fight_chghp")
      end
    end
  end
  g_link_player_name = {
    [0] = "",
    [1] = ""
  }
end
reg(packet.eSTC_UI_MatchScnClose, handleCloseWin, sig)
function on_item_mouse(panel, msg, pos, wheel)
end
function on_fight_chghp(obj)
  local max_hp = obj:get_atb(bo2.eAtb_HPMax)
  local cur_hp = obj:get_atb(bo2.eAtb_HP)
  local item = g_members[obj.name]
  if sys.check(item) then
    if w_single_fighter.visible then
      item:search("hp_val").text = sys.format("%d/%d", cur_hp, max_hp)
    else
      local hp_item = item:search("hp")
      hp_item.tip.text = sys.format("%d/%d", _cur_hp, _max_hp)
    end
  end
  if w_single_fighter.visible then
    update_hp_pic(item, cur_hp, max_hp)
    local mini_item = g_mini_members[obj.name]
    updata_mini_item_hp(mini_item, cur_hp, max_hp)
  else
    updata_mini_item_hp(item, cur_hp, max_hp)
  end
  local mini_item = g_mini_members[obj.name]
  updata_mini_item_hp(mini_item, cur_hp, max_hp)
  if bo2.player.target_handle == obj.sel_handle and cur_hp == 0 then
    auto_select()
  end
end
function on_player_enter(obj, msg)
  if g_members[obj.name] ~= nil and g_is_in_scn then
    on_fight_chghp(obj)
    g_members[obj.name].svar = obj.sel_handle
    auto_select()
    obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, on_fight_chghp, "ui_scn_matchunit:on_fight_chghp")
  end
end
function on_link(btn)
  local text = sys.format("%s: %s VS %s", g_match_type_text, g_link_player_name[0], g_link_player_name[1])
  ui_chat.insert_matchscn(g_scn_onlyid, text)
end
function ClickApplaud(btn)
  local var = sys.variant()
  var:set(packet.key.cmn_type, bo2.eSpectatorAction_Applaud)
  bo2.send_variant(packet.eCTS_MatchSpectator_Action, var)
end
function ClickCatcall(btn)
  local var = sys.variant()
  var:set(packet.key.cmn_type, bo2.eSpectatorAction_Catcall)
  bo2.send_variant(packet.eCTS_MatchSpectator_Action, var)
end
function ClickMute(btn)
  if btn == gx_btn_mute then
    btn.visible = false
    gx_btn_mute_disable.visible = true
  else
    btn.visible = false
    gx_btn_mute.visible = true
  end
  local var = sys.variant()
  var:set(packet.key.cmn_type, bo2.eSpectatorAction_Mute)
  bo2.send_variant(packet.eCTS_MatchSpectator_SetAction, var)
end
function ClickSee(btn)
  local cmd = packet.eCTS_MatchScn_ViewerListReq
  if g_match_type == bo2.eMatchType_TheBestFighter then
    cmd = packet.eCTS_TheBestFighter_ViewerListReq
  end
  ui_match.viewlist.OpenViewerPage(cmd, g_scn_onlyid)
end
function ClickHelp(btn)
  if 0 ~= g_match_id then
    local var = sys.variant()
    var:set(packet.key.scnmatch_id, g_match_id)
    var:set(packet.key.arena_id, g_scn_onlyid)
    var:set(packet.key.knight_pk_npc_cha_id, knight_excel_id)
    bo2.send_variant(packet.eCTS_Knight_GiveHelp, var)
  end
end
function on_quite(btn)
  local on_msg_callback = function(msg)
    if msg.result ~= 1 then
      return false
    end
    bo2.send_variant(packet.eCTS_UI_LeaveDungeonScn)
  end
  local mtf_text
  if g_members[bo2.player.name] ~= nil then
    mtf_text = sys.format(ui.get_text("scn_matchunit|on_fighter_quit"))
  else
    mtf_text = sys.format(ui.get_text("scn_matchunit|on_spectators_quit"))
  end
  local msg = {callback = on_msg_callback, text = mtf_text}
  ui_widget.ui_msg_box.show_common(msg)
end
function handleUpdateSpectators(cmn, var)
  local count = var:get(packet.key.player_count).v_int
  g_spectator_count = g_spectator_count + count
  local seecount = {count = g_spectator_count}
  gx_btn_seecount.tip.text = ui_widget.merge_mtf(seecount, ui.get_text("scn_matchunit|see"))
end
reg(packet.eSTC_MatchScn_SpectatorsCount, handleUpdateSpectators, sig)
function on_player_leave()
  handleCloseWin()
end
function HandleCloseUI(cmd, var)
  if g_is_in_scn ~= true then
    ui_scn_matchunit.gx_status_window.visible = false
  end
end
reg(packet.eSTC_UI_CloseTalk, HandleCloseUI, "ui_scn_matchunit.CloseUI")
reg(packet.eSTC_UI_Match_ResultCount, handleResultCount, "ui_scn_matchunit.handleResultCount")
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_leave, on_player_leave, "ui_scn_matchunit:on_player_leave")
