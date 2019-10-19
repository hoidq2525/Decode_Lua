local Total_repute_money = bo2.gv_define_org:find(132).value.v_int
local Repute_min = bo2.gv_define_org:find(133).value.v_int
local B_award_money = bo2.gv_define_org:find(134).value.v_int
function get_camp_repute_total_point()
  local requte_total
  local player = bo2.player
  local _score_data = get_view_cross_branches_data()
  local camp_id = player:get_atb(bo2.eAtb_Camp)
  if camp_id == bo2.eCamp_Blade then
    requte_total = _score_data.blade_score
  else
    requte_total = _score_data.sword_score
  end
  return requte_total
end
function on_refresh_camp_award()
  local excel = ui_cross_line.find_camp_award(1)
  if excel == nil then
    return
  end
  local _self_award = {}
  _self_award.v_item = excel.award_item
  _self_award.v_count = excel.award_count
  if sys.check(_self_award.v_item) and sys.check(_self_award.v_count) and _self_award.v_item.size == _self_award.v_count.size then
    local nItemSize = _self_award.v_item.size
    local item_pos = 0
    for i = 0, nItemSize - 1 do
      if item_pos >= g_max_item_size then
        break
      end
      local itemExcelId = _self_award.v_item[i]
      local itemName = sys.format("award%d", item_pos)
      item_pos = item_pos + 1
    end
  end
end
function refresh_award_by_rank(_score_data)
  local _self_rank = {}
  local _self_award = {}
  local modify_rank_data = function(pExcelAward)
    local _mtf_data = {}
    if sys.check(pExcelAward) then
      _mtf_data.rank0 = pExcelAward.level_begin
      _mtf_data.rank1 = pExcelAward.level_end
      _mtf_data.v_item = pExcelAward.award_item
      _mtf_data.award_money_type = pExcelAward.award_money_type
      _mtf_data.award_money = pExcelAward.award_money
    end
    return _mtf_data
  end
  local rank_range_mtf
  if _score_data.self_rank == nil or _score_data.self_rank <= 0 then
    _self_rank = {
      rank = ui.get_text("cross_line|no_rank")
    }
    local iSize = ui_cross_line.get_size_rank_award()
    if iSize ~= nil and iSize > 0 then
      local pExcelAward = ui_cross_line.get_rank_award(iSize - 1)
      _self_award = modify_rank_data(pExcelAward)
      rank_range_mtf = ui_widget.merge_mtf(_self_award, ui.get_text("cross_line|overlap_range"))
    end
  else
    _self_rank = {
      rank = _score_data.self_rank
    }
    local iSize = ui_cross_line.get_size_rank_award()
    local bFound = false
    for i = 0, iSize - 1 do
      local pExcelAward = ui_cross_line.get_rank_award(i)
      if sys.check(pExcelAward) and _score_data.self_rank >= pExcelAward.level_begin and _score_data.self_rank <= pExcelAward.level_end then
        _self_award = modify_rank_data(pExcelAward)
        bFound = true
        break
      end
    end
    if bFound ~= true then
      local pExcelAward = get_rank_award(iSize - 1)
      _self_award = modify_rank_data(pExcelAward)
      rank_range_mtf = ui_widget.merge_mtf(_self_award, ui.get_text("cross_line|overlap_range"))
    elseif _self_award.rank0 == _self_award.rank1 then
      rank_range_mtf = ui_widget.merge_mtf(_self_award, ui.get_text("camp_repute|single_rank_award"))
    else
      rank_range_mtf = ui_widget.merge_mtf(_self_award, ui.get_text("cross_line|award_range"))
    end
  end
  return _self_rank, _self_award, rank_range_mtf
end
function on_refresh_rank_award()
  local _score_data = get_view_cross_branches_data()
  local _self_rank = {}
  local _self_award = {}
  local rank_range_mtf
  _self_rank, _self_award, rank_range_mtf = refresh_award_by_rank(_score_data)
  local rb_award_items = list_award:search(L("rank_award"))
  if sys.check(_self_award.v_item) then
    local nItemSize = _self_award.v_item.size
    local item_pos = 0
    for i = 0, nItemSize - 1, 2 do
      if item_pos >= g_max_item_size then
        break
      end
      local itemExcelId = _self_award.v_item[i]
      local itemName = sys.format("award%d", item_pos)
      item_pos = item_pos + 1
      local itemCard = rb_award_items:search(itemName)
      if sys.check(itemCard) then
        local _item = itemCard:search("item")
        if sys.check(_item) then
          _item.excel_id = itemExcelId
        end
        local itemCount = itemCard:search("num")
        if sys.check(itemCount) then
          itemCount.text = sys.format(L("x%d"), _self_award.v_item[i + 1])
        end
      end
    end
  end
  local player = bo2.player
  local requte_total = get_camp_repute_total_point()
  local week_point = 0
  if get_view_award_type() == 0 then
    week_point = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeRankPoint)
  else
    week_point = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeLastWeekPoint)
  end
  local hold_rate = 0
  if requte_total > 0 and week_point > 0 and week_point > Repute_min then
    hold_rate = week_point / requte_total * 100
  end
  if week_point > Repute_min and hold_rate > 0 then
    local my_get_money = hold_rate / 100 * Total_repute_money / 10000
    rb_award.mtf = sys.format(L("<space:0.2><m:%d>"), math.floor(my_get_money) * 10000)
  else
    rb_award.mtf = sys.format(L("<space:0.2><bm:%d>"), B_award_money)
  end
end
function on_refresh_score_award()
  local _score_data = get_view_cross_branches_data()
  if _score_data.total_score == nil then
    _score_data.total_score = 0
  end
  local excel_current, excel_next = ui_cross_line.get_score_award_excel(_score_data.total_score)
  local award_excel
  if excel_current == nil then
    rb_award.mtf = sys.format(ui.get_text("camp_repute|leak_of_point"))
    return
  else
    award_excel = excel_current
  end
  local mtf_data = {}
  rb_award.mtf = sys.format(L("<m:%d>"), excel_current.award_money)
end
function refresh_award()
  on_refresh_rank_award()
  on_refresh_camp_award()
  if get_view_award_type() == 1 then
    btn_award.enable = true
  else
    btn_award.enable = false
  end
end
function insert_point_award(_score_data, stk)
  local color_current = SHARED("FFFFFF")
  if _score_data.total_score == nil or _score_data.total_score == 0 then
    _score_data.total_score = 0
  end
  local score = _score_data.total_score
  ui_tool.ctip_push_sep(stk)
  local excel_current, excel_next = ui_cross_line.get_score_award_excel(score)
  local mtf_data = {}
  ui_tool.ctip_push_text(stk, sys.format(ui.get_text("cross_line|total_contri_current_stage")), SHARED("C92B2B"), ui_tool.cs_tip_a_add_l)
  ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  if excel_current == nil then
    ui_tool.ctip_push_text(stk, sys.format(ui.get_text("cross_line|total_contri_current_none")), SHARED("979797"), ui_tool.cs_tip_a_add_l)
  else
    if 0 < excel_current.score_end then
      mtf_data.begin0 = excel_current.score_begin
      mtf_data.end0 = excel_current.score_end
      title_text = ui_widget.merge_mtf(mtf_data, sys.format(ui.get_text("cross_line|total_contri_bd")))
    else
      mtf_data.begin0 = excel_current.score_begin
      title_text = ui_widget.merge_mtf(mtf_data, sys.format(ui.get_text("cross_line|total_contri_max")))
    end
    ui_tool.ctip_push_text(stk, title_text, SHARED("9C9C9C"), ui_tool.cs_tip_a_add_l)
    ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
    stk:raw_push(L("<a+:l><c+:FFFFFF><space:1.0>"))
    stk:raw_push(sys.format(L("<m:%d>"), excel_current.award_money))
    stk:raw_push(L("<a-><c->"))
  end
  local is_history = get_view_award_type()
  if is_history == 1 then
    return
  end
  if excel_next ~= nil then
    ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
    local mtf_data = {}
    local title_text
    if 0 < excel_next.score_end then
      mtf_data.begin0 = excel_next.score_begin
      mtf_data.end0 = excel_next.score_end
      title_text = ui_widget.merge_mtf(mtf_data, sys.format(ui.get_text("cross_line|total_contri_bd")))
    else
      mtf_data.begin0 = excel_next.score_begin
      title_text = ui_widget.merge_mtf(mtf_data, sys.format(ui.get_text("cross_line|total_contri_max")))
    end
    ui_tool.ctip_push_text(stk, sys.format(ui.get_text("cross_line|total_contri_next_stage")), SHARED("C92B2B"), ui_tool.cs_tip_a_add_l)
    ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
    ui_tool.ctip_push_text(stk, title_text, SHARED("979797"), ui_tool.cs_tip_a_add_l)
    ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
    stk:raw_push(sys.format(L("<space:1.0><c+:9c9c9c><m:%d><c->"), excel_next.award_money))
  else
  end
end
function open(m)
  local v = sys.variant()
  v:set(packet.key.cmn_id, m.v_int)
  v:set(packet.key.cmn_type, 100)
  bo2.send_variant(packet.eCTS_UI_OpenReputeShop, v)
end
function on_show_tip_repute_award(tip)
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_title_ex(stk, ui.get_text(L("camp_repute|tips_repute_award")), L("d3a75e"), ui_tool.cs_tip_a_add_)
  ui_tool.ctip_push_sep(stk)
  local player = bo2.player
  local mtf = {}
  local requte_total = get_camp_repute_total_point()
  local week_point = 0
  if get_view_award_type() == 0 then
    week_point = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeRankPoint)
  else
    week_point = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeLastWeekPoint)
  end
  local hold_rate = 0
  if requte_total > 0 and week_point > 0 and week_point > Repute_min then
    hold_rate = week_point / requte_total * 100
  end
  mtf.requte_total = sys.format(L("<c+:FFFFFF>%d<c-><c->"), requte_total)
  mtf.week_point = sys.format(L("<c+:FFFFFF>%d<c-><c->"), week_point)
  mtf.hold_rate = sys.format(L("<c+:FFFFFF>%d%%<c-><c->"), hold_rate)
  local week_point_text, requte_total_text, hold_rate_text, total_repute_money_text, requte_min_text
  week_point_text = sys.format(L("%s%s"), ui.get_text("camp_repute|tips_week_point"), mtf.week_point)
  requte_total_text = sys.format(L("%s%s"), ui.get_text("camp_repute|tips_total_requtes"), mtf.requte_total)
  hold_rate_text = sys.format(L("%s%s"), ui.get_text("camp_repute|tips_hold_total_rate"), mtf.hold_rate)
  total_repute_money_text = sys.format(L("%s<c+:ffffff><space:1.0><m:%d>"), ui.get_text("camp_repute|tips_repute_total_award"), Total_repute_money)
  requte_min_text = sys.format(L("%s%s"), ui.get_text("camp_repute|tips_requte_min"), Repute_min)
  local mtf_text_point = ui_widget.merge_mtf(mtf, week_point_text)
  local mtf_text_total = ui_widget.merge_mtf(mtf, requte_total_text)
  local mtf_hold_rate = ui_widget.merge_mtf(mtf, hold_rate_text)
  local mtf_total_money = ui_widget.merge_mtf(mtf, total_repute_money_text)
  local mtf_requte_min = ui_widget.merge_mtf(mtf, requte_min_text)
  stk:raw_push(L("<space:1.0><c+:9c9c9c>"))
  stk:raw_push(mtf_text_total)
  ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  stk:raw_push(L("<space:1.0><c+:9c9c9c>"))
  stk:raw_push(mtf_text_point)
  ui_tool.ctip_push_sep(stk)
  stk:raw_push(L("<space:1.0><c+:9c9c9c>"))
  stk:raw_push(mtf_requte_min)
  ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  stk:raw_push(L("<space:1.0><c+:9c9c9c>"))
  stk:raw_push(mtf_hold_rate)
  ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  stk:raw_push(L("<space:1.0><c+:9c9c9c>"))
  stk:raw_push(mtf_total_money)
  ui_tool.ctip_push_sep(stk)
  stk:raw_push(L("<space:1.0><c+:9c9c9c>"))
  ui_tool.ctip_push_text(stk, ui.get_text("camp_repute|tips_repute_rate_info"), SHARED("9c9c9c"), ui_tool.cs_tip_a_add_l)
  ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  if week_point > Repute_min and hold_rate > 0 then
    local my_get_money = hold_rate / 100 * Total_repute_money / 10000
    stk:raw_push(sys.format(L("<c+:ffffff><space:1.0><m:%d>"), math.floor(my_get_money) * 10000))
  else
    stk:raw_push(sys.format(L("<c+:ffffff><space:1.0><bm:%d>"), B_award_money))
  end
  tip.text = stk.text
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_show_tip_rank_award(tip)
  local stk = sys.mtf_stack()
  local is_history = get_view_award_type()
  local _score_data = get_view_cross_branches_data()
  local _self_rank = {}
  local _self_award = {}
  local rank_range_mtf
  _self_rank, _self_award, rank_range_mtf = refresh_award_by_rank(_score_data)
  ui_tool.ctip_make_title_ex(stk, ui.get_text(L("camp_repute|tips_rank_award_title")), L("d3a75e"), ui_tool.cs_tip_a_add_)
  ui_tool.ctip_push_sep(stk)
  local player = bo2.player
  local mtf = {}
  mtf.last_week_point = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeLastWeekPoint)
  mtf.week_point = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeRankPoint)
  mtf.last_week_point = sys.format(L("<c+:FFFFFF>%d<c-><c->"), mtf.last_week_point)
  mtf.week_point = sys.format(L("<c+:FFFFFF>%d<c-><c->"), mtf.week_point)
  local get_rank_text = function(_score_data)
    if _score_data.self_rank == nil or _score_data.self_rank <= 0 then
      return sys.format(L("<c+:FFFFFF>%s<c->"), ui.get_text("cross_line|no_rank"))
    else
      return sys.format(L("<c+:FFFFFF>%d<c->"), _score_data.self_rank)
    end
  end
  mtf.rank = get_rank_text(ui_cross_line.g_score_data)
  mtf.last_week_rank = get_rank_text(ui_cross_line.g_history_score_data)
  local week_point_text, week_rank_text
  if is_history == 1 then
    week_point_text = ui.get_text("camp_repute|last_week_point")
    week_rank_text = ui.get_text("camp_repute|last_week_rank")
  else
    week_point_text = sys.format(L("%s%s"), ui.get_text("camp_repute|week_point"), mtf.week_point)
    week_rank_text = ui.get_text("camp_repute|rank")
  end
  local mtf_text_point = ui_widget.merge_mtf(mtf, week_point_text)
  local mtf_text_rank = ui_widget.merge_mtf(mtf, week_rank_text)
  stk:raw_push(L("<space:1.0><c+:9c9c9c>"))
  stk:raw_push(mtf_text_rank)
  ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  stk:raw_push(L("<space:1.0><c+:9c9c9c>"))
  stk:raw_push(mtf_text_point)
  ui_tool.ctip_push_sep(stk)
  stk:raw_push(L("<space:1.0><c+:9c9c9c>"))
  ui_tool.ctip_push_text(stk, rank_range_mtf, SHARED("C92B2B"), ui_tool.cs_tip_a_add_l)
  stk:raw_push(L("<space:2.0>"))
  if is_history ~= 1 then
    ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
    stk:raw_push(L("<space:1.0><c+:9c9c9c>"))
    ui_tool.ctip_push_text(stk, ui.get_text("cross_line|item"), SHARED("9c9c9c"), ui_tool.cs_tip_a_add_l)
  else
  end
  if sys.check(_self_award.v_item) then
    local nItemSize = _self_award.v_item.size
    local item_pos = 0
    for i = 0, nItemSize - 1, 2 do
      local itemExcelId = _self_award.v_item[i]
      local itemCount = _self_award.v_item[i + 1]
      ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
      stk:raw_push(sys.format(L("<space:1.0><i:%d> x %d"), itemExcelId, itemCount))
    end
  end
  tip.text = stk.text
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_click_trans(btn)
  if btn.svar.type ~= nil then
    on_click_maze_transfer(btn)
  else
    ui_cross_line.on_click_trans()
  end
end
function on_click_join_battle(btn)
  if btn.svar.type ~= nil then
    local v_data = sys.variant()
    v_data[packet.key.misc_begin] = 2
    bo2.send_variant(packet.eCTS_UI_RequestCrossLineData, v_data)
  else
    ui_cross_line.on_click_join_battle()
  end
end
function on_click_award()
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_RequestCrossLineAward, v)
end
g_maze_popo_data = {is_open = false}
function set_maze_event(open)
  g_maze_popo_data.is_open = open
end
function get_maze_trans_time()
  return g_maze_popo_data.time
end
function on_maze_popo(data)
  g_maze_popo_data.data = data
  g_maze_popo_data.time = ui_main.get_os_time() + 35
end
function is_maze_event_opened()
  return g_maze_popo_data.is_open
end
function get_maze_trans_data()
  local os_time = ui_main.get_os_time()
  if g_maze_popo_data.time ~= nil and os_time < g_maze_popo_data.time then
    return true
  end
  return false
end
function on_click_maze_transfer(btn)
  if g_maze_popo_data ~= nil and g_maze_popo_data.data ~= nil then
    w_main.visible = false
    ui_popo.ask_maze_trans("yes", g_maze_popo_data.data)
  else
    btn.visible = false
  end
end
