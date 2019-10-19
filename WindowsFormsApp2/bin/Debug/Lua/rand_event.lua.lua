b_system_on = false
Msk_EventState_Zero = 0
Msk_EventState_Active = 1
Msk_EventState_Success = 2
Msk_EventState_Over = 4
local path_rand_event_def = SHARED("$mb/random_event/rand_event_def.xml")
local path_cmn_award = SHARED("$mb/award/cmn_award.xml")
local path_money_award = SHARED("$mb/award/money_award/money_award.xml")
local path_exp_award = SHARED("$mb/award/exp_award/exp_award.xml")
local path_money = SHARED("$mb/award/money_award/")
local path_exp = SHARED("$mb/award/exp_award/")
function clear_global()
  g_event_mgr = nil
  g_event_def_excel = nil
  g_cmn_award_excel = nil
  g_money_award_excel = nil
  g_exp_award_excel = nil
  g_event_sort_idx = nil
  local info_panel = rand_event_show_wnd:search("info_panel")
  if nil == info_panel then
    return
  end
  for i = 1, 6 do
    local item_name = "item" .. i
    local event_item = info_panel:search(item_name)
    if nil ~= event_item then
      event_item.visible = false
    end
  end
end
function on_event_got(data)
  if nil == g_event_mgr then
    g_event_mgr = {}
    g_event_mgr.count = 0
    g_event_mgr.event = {}
  end
  if nil == g_event_def_excel then
    g_event_def_excel = bo2.gv_rand_event_def
  end
  if nil == g_cmn_award_excel then
    g_cmn_award_excel = sys.load_table(path_cmn_award)
  end
  local eventID = data:get(packet.key.rand_event_info_id).v_int
  local state = data:get(packet.key.rand_event_info_state).v_int
  local score = data:get(packet.key.rand_event_info_score).v_int
  local award = data:get(packet.key.rand_event_info_award).v_int
  g_event_mgr.event[eventID] = {}
  local event_info = g_event_mgr.event[eventID]
  event_info.eventID = eventID
  event_info.state = state
  event_info.score = score
  event_info.award = award
  event_info.idx = 0
  g_event_mgr.count = g_event_mgr.count + 1
  local event_def = g_event_def_excel:find(eventID)
  if nil == event_def then
    return
  end
  event_info.name = event_def.name
  event_info.short_desc = event_def.short_desc
  event_info.desc = event_def.desc
  event_info.monistyle = event_def.monistyle
  event_info.difficulty = event_def.difficulty
  if 0 <= event_info.monistyle then
    event_info.monidata = 0
  elseif event_info.monistyle <= -1 then
    event_info.monidata = math.abs(event_info.monistyle)
  end
  local award_line = g_cmn_award_excel:find(event_info.award)
  if nil == award_line then
    return
  end
  local item_str = award_line.item
  local item_type, item_count = item_str:split("*")
  event_info.item_type = tonumber(tostring(item_type))
  event_info.item_count = item_count
  event_info.money_type = award_line.money_award_basic[0]
  event_info.money_base = award_line.money_award_basic[1]
  event_info.exp_base = tonumber(award_line.exp_award_basic)
  event_info.money_level = 0
  event_info.exp_level = 0
  if not award_line.money_award_match_level.empty then
    if nil == g_money_award_excel then
      g_money_award_excel = sys.load_table(path_money_award, path_money .. award_line.money_award_match_level .. ".txt")
    end
    if nil == g_money_award_excel then
      return
    end
    local money_line = g_money_award_excel:find(bo2.player:get_atb(bo2.eAtb_Level))
    if nil == money_line then
      return
    end
    event_info.money_level = tonumber(money_line.award)
  end
  if not award_line.exp_award_match_level.empty then
    if nil == g_exp_award_excel then
      g_exp_award_excel = sys.load_table(path_exp_award, path_exp .. award_line.exp_award_match_level .. ".txt")
    end
    if nil == g_exp_award_excel then
      return
    end
    local exp_line = g_exp_award_excel:find(bo2.player:get_atb(bo2.eAtb_Level))
    if nil == exp_line then
      return
    end
    event_info.exp_level = tonumber(exp_line.award)
  end
  g_money_award_excel = nil
  g_exp_award_excel = nil
end
function identify_event()
  if nil == g_event_sort_idx then
    g_event_sort_idx = {}
  end
  local idx = 1
  for i, _ in pairs(g_event_mgr.event) do
    g_event_sort_idx[idx] = i
    idx = idx + 1
  end
  local sort_help = function(t1, t2)
    local event = g_event_mgr.event
    if event[t1].score == event[t2].score then
      return event[t1].eventID < event[t2].eventID
    else
      return event[t1].score > event[t2].score
    end
  end
  table.sort(g_event_sort_idx, sort_help)
  local event = g_event_mgr.event
  for i, v in pairs(g_event_sort_idx) do
    event[v].idx = i
  end
end
function GetStateDetail(state)
  local bActive = 1 == state % 2 and true or false
  state = math.floor(state / 2)
  local bSuccess = 1 == state % 2 and true or false
  state = math.floor(state / 2)
  local bOver = 1 == state % 2 and true or false
  return bActive, bSuccess, bOver
end
function on_iknow_click(btn)
  rand_event_show_wnd.visible = false
  ui_rand_event.monitor.show_monitor(true)
end
function on_rand_event_visible(panel, bool)
  if bool then
    b_system_on = true
    update_ui()
    bo2.AddTimeEvent(3000, on_iknow_click)
  end
  ui_widget.on_leavescn_stk_visible(panel, bool)
end
function update_ui()
  if nil == g_event_mgr then
    return
  end
  local info_panel = rand_event_show_wnd:search("info_panel")
  if nil == info_panel then
    return
  end
  rand_event_show_wnd:search("big_title").text = bo2.scn.excel.name
  for _, v in pairs(g_event_mgr.event) do
    local item_name = "item" .. v.idx
    local event_item = info_panel:search(item_name)
    if nil ~= event_item then
      event_item:search("event_name").text = v.name
      event_item:search("rich_exp").mtf = sys.format("<a:r>%d", v.exp_base + v.exp_level)
      event_item:search("money_label").money = v.money_base + v.money_level
      event_item:search("money_label").bounded = 1 == v.money_type
      local item_line = bo2.gv_item_list:find(v.item_type)
      if nil ~= item_line then
        local image_uri = sys.format("$icon/item/%s.png|0,0,64,64*20,20", tostring(item_line.icon))
        local item_mtf = sys.format("<a:r><img:%s> x", image_uri)
        event_item:search("icon_item").mtf = item_mtf
        event_item:search("rich_item").mtf = sys.format("<a:l>%s", v.item_count)
      end
      event_item.visible = true
    end
  end
end
function on_event_show(data)
  identify_event()
  rand_event_show_wnd.visible = true
  ui_rand_event.monitor.pre_init_monitor()
end
function on_tip_make(tip)
  local item_panel = tip.owner
  local event_id = g_event_sort_idx[tonumber(string.sub(tostring(item_panel.name), 5))]
  local event_info = g_event_mgr.event[event_id]
  if nil == event_info then
    return
  end
  local tip_title = event_info.name
  if nil == tip_title then
    return
  end
  local tip_content = event_info.desc
  if nil == tip_content then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_push_text(stk, tip_title, ui_tool.cs_tip_color_green)
  ui_tool.ctip_push_sep(stk)
  stk:raw_push(tip_content)
  ui_tool.ctip_push_sep(stk)
  local tmoney
  if 0 == event_info.money_type then
    tmoney = sys.format("<m:%d>", event_info.money_base + event_info.money_level)
  else
    tmoney = sys.format("<bm:%d>", event_info.money_base + event_info.money_level)
  end
  local v = sys.variant()
  v:set("tip_money", tmoney)
  v:set("tip_exp", tostring(event_info.exp_base + event_info.exp_level))
  local diff, diff_desc
  if 0 == event_info.difficulty then
    diff = ui.get_text("scncopy|hard")
    diff_desc = ui.get_text("scncopy|tip_hard")
  elseif 1 == event_info.difficulty then
    diff = ui.get_text("scncopy|normal")
    diff_desc = ui.get_text("scncopy|tip_normal")
  else
    diff = ui.get_text("scncopy|easy")
    diff_desc = ui.get_text("scncopy|tip_easy")
  end
  v:set("tip_difficulty", diff)
  stk:raw_format(sys.mtf_merge(v, ui.get_text("scncopy|tip_money")))
  stk:raw_format(sys.mtf_merge(v, ui.get_text("scncopy|tip_exp")))
  stk:raw_format(sys.mtf_merge(v, ui.get_text("scncopy|tip_difficulty")))
  local item_line = bo2.gv_item_list:find(event_info.item_type)
  if nil ~= item_line then
    v:set("tip_icon", tostring(item_line.icon))
    v:set("tip_tool", event_info.item_count)
    stk:raw_format(sys.mtf_merge(v, ui.get_text("scncopy|tip_tool")))
  end
  stk:raw_format(sys.mtf_merge(v, diff_desc))
  ui_tool.ctip_show(tip.owner, stk, nil)
end
