g_match_list = {}
g_match_list_cur = {}
g_matchscn_list = {}
g_thebestfight_list = {}
eCurType_All = 99
eCurType_Scn = 0
eCurType_1v1 = 1
eCurType_3v3_all = 2
eCurType_3v3_chg = 3
eCurType_5v5_all = 4
eCurType_5v5_chg = 5
eCurType_TBF = 6
eCurType_2v2 = 7
eCurType_dooaltar = 8
eCurType_gamb = 9
g_cur_type = eCurType_All
local mode_define = {}
local g_request_data = {}
function on_init_mode_define()
  local function insert_mode_define(tab)
    table.insert(mode_define, tab)
    if tab.type ~= eCurType_dooaltar then
      g_request_data[eCurType_Scn] = {id = -1}
    else
      g_request_data[eCurType_dooaltar] = {id = -1}
    end
  end
  insert_mode_define({
    name = L("arena"),
    type = eCurType_1v1,
    request_id = -1,
    pack = packet.eCTS_Arena_ShowAllMultiServerMatch
  })
  insert_mode_define({
    name = L("mode_3v3"),
    type = eCurType_3v3_all,
    request_id = -1,
    pack = packet.eCTS_Arena_ShowAllMultiServerMatch
  })
  insert_mode_define({
    name = L("mode_gamb"),
    type = eCurType_gamb,
    request_id = -1,
    pack = packet.eCTS_Arena_ShowAllMultiServerMatch
  })
  insert_mode_define({
    name = L("dooaltar_list"),
    type = eCurType_dooaltar,
    request_id = -1,
    pack = packet.eCTS_Arena_ShowAllMatch
  })
end
on_init_mode_define()
n_page_limit = 14
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_match.packet_handler"
function OnSelectItem(item, sel)
  item:search("select").visible = sel
end
function on_set_cell_date(page, item_idx, data_idx)
  local var = page
  if sys.check(page.list) ~= true then
    return
  end
  local item = var.list:item_get(item_idx)
  if sys.check(item) ~= true then
    if data_idx >= page.count then
      return
    else
      item = var.list:item_append()
      item:load_style("$frame/match/arena_list.xml", "arenaitem")
    end
  elseif data_idx >= page.count then
    item.visible = false
    return
  end
  item.visible = true
  local data = page.var:fetch_v(data_idx)
  item:search("arena_type").text = simple_GetMatchType(data)
  item:search("group1").text = data:get(packet.key.arena_a_turn).v_string
  item:search("group2").text = data:get(packet.key.arena_b_turn).v_string
  item:search("start_time").text = bo2.get_cpgtime(data:get(packet.key.arena_start_time).v_int)
  item.svar.type = data:get(packet.key.arena_mode).v_int
  item.svar.match_id = data:get(packet.key.arena_id)
end
function update_page(page)
  local step = page.step
  if page.index > page.count then
    page.index = 0
  end
  local p_idx = math.floor(page.index / n_page_limit)
  local p_cnt = math.floor((page.count + n_page_limit - 1) / n_page_limit)
  local p_cur_begin = p_idx * n_page_limit
  local p_cur_end = (p_idx + 1) * n_page_limit
  ui_widget.ui_stepping.set_page(step, p_idx, p_cnt)
  local count = page.count - 1
  local idx = 0
  local page_count = n_page_limit - 1
  for i = 0, page_count do
    idx = page.index + i
    on_set_cell_date(page, i, idx)
  end
end
function show_match_list(match_list)
  local page = {
    index = 0,
    count = match_list.count
  }
  page.var = match_list.var
  page.step = match_list.step
  page.list = match_list.list
  page.list:item_clear()
  local function on_page_step(var)
    page.index = var.index * n_page_limit
    update_page(page)
  end
  ui_widget.ui_stepping.set_event(page.step, on_page_step)
  update_page(page)
end
function simple_GetMatchType(data)
  local match_type = data:get(packet.key.arena_mode).v_int
  local match_type_count = data:get(packet.key.arena_mode_data).v_int
  local idx = 1
  if match_type == bo2.eMatchType_ArenaSingle then
    idx = 1
  elseif match_type == bo2.eMatchType_Act3V3 then
    idx = 2
  elseif match_type == bo2.eMatchType_ArenaSingleGamb then
    idx = 3
  elseif match_type == bo2.eMatchType_ArenaSinglePractice then
    idx = 4
  end
  local text = ui.get_text("match|mode_search_" .. idx)
  return text
end
function refresh_arena_list(type)
  local tab_v = g_request_data[type].data
  if tab_v == nil or tab_v:has(packet.key.append_data) ~= true then
    return
  end
  if type == eCurType_Scn then
    local v_total = tab_v:get(packet.key.append_data)
    local match_tab = {}
    for i = 0, 2 do
      match_tab[i] = {
        var = sys.variant(),
        count = 0
      }
      if i == 0 then
        match_tab[i].name = L("arena")
      elseif i == 1 then
        match_tab[i].name = L("mode_3v3")
      elseif i == 2 then
        match_tab[i].name = L("mode_gamb")
      end
      local step_p = ui_match.g_match_test:search(match_tab[i].name)
      match_tab[i].step = step_p:search(L("step"))
      match_tab[i].list = step_p:search(L("gx_arenalist"))
    end
    local count = v_total.size
    for i = 0, count - 1 do
      local var0 = v_total:fetch_v(i)
      local arena_type = var0[packet.key.arena_mode]
      local table_index = 0
      if arena_type == bo2.eMatchType_ArenaSingle or arena_type == bo2.eMatchType_ArenaSinglePractice then
        table_index = 0
      elseif arena_type == bo2.eMatchType_Act3V3 then
        table_index = 1
      else
        table_index = 2
      end
      if g_debug == true then
        for m = 0, 100 do
          match_tab[table_index].var:push_back(var0)
        end
      else
        match_tab[table_index].var:push_back(var0)
      end
    end
    local sort_fn = function(left, right)
      local gs_0 = left:get(packet.key.gs_score).v_int
      local gs_1 = right:get(packet.key.gs_score).v_int
      if gs_0 <= gs_0 then
        return false
      end
      return true
    end
    for i = 0, 2 do
      match_tab[i].count = match_tab[i].var.size
      match_tab[i].var:sort(sort_fn)
      show_match_list(match_tab[i])
    end
  else
    local v_total = tab_v:get(packet.key.append_data)
    local match_tab = {
      var = v_total,
      count = v_total.size
    }
    local step_p = ui_match.g_match_test:search(L("dooaltar_list"))
    match_tab.step = step_p:search(L("step"))
    match_tab.list = step_p:search(L("gx_arenalist"))
    show_match_list(match_tab)
  end
end
function b()
  local var = sys.variant()
  var:set(packet.key.cmn_type, bo2.eMatchType_ArenaSingle)
  local var0 = sys.variant()
  var0[packet.key.ui_request_id] = 1
  local var_a = sys.variant()
  var_a:set(packet.key.arena_mode, bo2.eMatchType_ArenaSingle)
  var_a:set(packet.key.arena_a_turn, L("s111"))
  var_a:set(packet.key.arena_b_turn, L("s112"))
  var_a:set(packet.key.arena_start_time, os.time)
  local var_a0 = sys.variant()
  var_a0:set(packet.key.arena_mode, bo2.eMatchType_Act3V3)
  var_a0:set(packet.key.arena_a_turn, L("\214\208\206\196\195\251\215\214\179\172\188\182\179\164\181\196"))
  var_a0:set(packet.key.arena_b_turn, L("\209\167\207\176\208\196\181\195\208\180\207\234\207\184\181\196"))
  var_a0:set(packet.key.arena_start_time, os.time)
  local var_a1 = sys.variant()
  var_a1:set(packet.key.arena_mode, bo2.eMatchType_ArenaSingleGamb)
  var_a1:set(packet.key.arena_a_turn, L("s111"))
  var_a1:set(packet.key.arena_b_turn, L("s112"))
  var_a1:set(packet.key.arena_start_time, os.time)
  local var_sss = sys.variant()
  var_sss:push_back(var_a)
  var_sss:push_back(var_a0)
  var_sss:push_back(var_a1)
  var0:set(packet.key.append_data, var_sss)
  var:set(bo2.eRequestModelType_StaticData, var0)
  handleShowAllMatchList(cmd, var)
end
function handleShowAllMatchList(cmd, data)
  if data:has(packet.key.cmn_type) ~= true then
    return
  end
  local cmn_type = data:get(packet.key.cmn_type).v_int
  local refresh_type = eCurType_dooaltar
  if cmn_type ~= eCurType_dooaltar then
    refresh_type = eCurType_Scn
  else
  end
  local all_packet = data:get(bo2.eRequestModelType_StaticData)
  local request_id = all_packet[packet.key.ui_request_id]
  g_request_data[refresh_type].id = request_id
  g_request_data[refresh_type].data = all_packet
  refresh_arena_list(refresh_type)
end
function handleShowAllMatchScnList(cmd, data)
end
function handleShowTheBestFightList(cmd, data)
end
function on_update_arena_list(ctrl)
  local ctrl_name = ctrl.name
  local function update_tab_data(v)
    local send_v = sys.variant()
    send_v:set(packet.key.cmn_type, v.type)
    if v.type == eCurType_dooaltar then
      send_v:set(bo2.eRequestModelType_StaticData, g_request_data[eCurType_dooaltar].id)
    else
      send_v:set(bo2.eRequestModelType_StaticData, g_request_data[eCurType_Scn].id)
    end
    bo2.send_variant(v.pack, send_v)
  end
  for i, v in pairs(mode_define) do
    if v ~= nil and v.name == ctrl_name then
      update_tab_data(v)
      return
    end
  end
end
function OnArenaListObservable(ctrl, vis)
  if vis then
    on_update_arena_list(ctrl)
    on_update_radio()
  else
  end
end
function OnArenaListVisible(ctrl, vis)
  if not vis then
  else
  end
end
function OnUpdateClick(btn)
end
function OnItemLinkClick(btn)
  local item = btn.parent
  if item ~= nil then
    local text = item:search("arena_type").text
    text = text .. ":" .. item:search("group1").text .. " VS " .. item:search("group2").text
    local idx = get_idx_by_item(item)
    if idx == 0 then
      ui_chat.insert_arena(item.svar.match_id, text)
    end
  end
end
function OnLinkClick(arena_id)
  local var = sys.variant()
  var:set(packet.key.arena_id, arena_id)
  bo2.send_variant(packet.eCTS_UI_VisitArenaScarecrow, var)
end
function OnLinkClick_Scn(arena_id)
  local var = sys.variant()
  var:set(packet.key.arena_id, arena_id)
  if ui_scn_matchunit.is_knight_fight then
    bo2.send_variant(packet.eCTS_Knight_PK_Touch, var)
  elseif ui_scn_matchunit.g_match_type == bo2.eMatchType_TheBestFighter then
    bo2.send_variant(packet.eCTS_TheBestFighter_Touch, var)
  else
    bo2.send_variant(packet.eCTS_MatchScn_Touch, var)
  end
end
function get_idx_by_item(item)
  local match_type = item.svar.type
  local idx = -1
  if match_type == bo2.eMatchType_ArenaSingle then
    idx = 0
  elseif match_type == bo2.eMatchType_Act3V3 then
    idx = 0
  elseif match_type == bo2.eMatchType_ArenaSingleGamb then
    idx = 0
  elseif match_type == bo2.eMatchType_ArenaSinglePractice then
    idx = 0
  end
  return idx
end
function get_idx_by_blow_btn(btn)
  local core = btn:upsearch_name(L("core"))
  local list = core:search(L("gx_arenalist"))
  local item = list.item_sel
  if item == nil then
    return -1
  end
  if gx_innermng_pn.visible == true then
    return -1
  end
  return get_idx_by_item(item), item
end
function OnVisitArena(btn)
  local idx, item = get_idx_by_blow_btn(btn)
  if idx == 0 then
    local var = sys.variant()
    var:set(packet.key.arena_id, item.svar.match_id)
    bo2.send_variant(packet.eCTS_UI_Arena_GoinWatch, var)
  end
end
function OnDetailClick(btn)
  local idx, item = get_idx_by_blow_btn(btn)
  if idx == 0 then
    local v = sys.variant()
    v:set(packet.key.arena_id, item.svar.match_id)
    bo2.send_variant(packet.eCTS_UI_VisitArenaScarecrow, v)
  end
end
function onEnterClick()
  ui_popo.del_popo_by_name("arena")
  local v = sys.variant()
  v:set(packet.key.cmn_agree_ack, 1)
  bo2.send_variant(packet.eCTS_Arena_ReplyMatchAsk, v)
end
function on_menu_event(item)
  if item.callback then
    item:callback()
  end
end
function on_list_item_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_rbutton_click or msg == ui.mouse_lbutton_click then
    local list = panel:upsearch_name(L("gx_arenalist"))
    if list.item_sel ~= nil then
      list.item_sel.selected = false
    end
    panel.selected = true
    local function vistArena()
      OnVisitArena(panel)
    end
    local function detailClick()
      OnDetailClick(panel)
    end
    local function menu_link()
      local btn_link = panel:search(L("btn_link"))
      OnItemLinkClick(btn_link)
    end
    local data = {
      items = {
        {
          text = ui.get_text("match|apply_enter"),
          callback = vistArena
        },
        {
          text = ui.get_text("match|btn_detail"),
          callback = detailClick
        },
        {
          text = ui.get_text("match|btn_link"),
          callback = menu_link
        }
      },
      event = on_menu_event,
      parent = panel.parent,
      dx = 100,
      dy = 50
    }
    ui_tool.show_menu(data)
    data.window.offset = panel.abs_area.p1 + pos
  end
end
function OnGroupMngClick(btn)
  bo2.send_variant(packet.eCTS_DooAltar_GetScore)
end
reg(packet.eSTC_UI_ShowAllMatch, handleShowAllMatchList, sig)
reg(packet.eSTC_UI_ShowAllMatchScn, handleShowAllMatchScnList, sig)
reg(packet.eSTC_UI_ShowAllTheBestFight, handleShowTheBestFightList, sig)
