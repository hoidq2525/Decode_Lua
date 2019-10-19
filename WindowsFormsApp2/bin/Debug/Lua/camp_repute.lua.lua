g_max_item_size = 3
g_award_cd = 30135
g_player_anime = false
g_stage_color = {}
g_stage_color[0] = L("00FF00")
g_stage_color[1] = L("FFFFFF")
g_stage_color[2] = L("FF0000")
g_stage_color[3] = L("FF0000")
g_reset_week = 1
g_reset_hour = 6
function get_view_award_type()
  if bo2.IsCoolDownOver(g_award_cd) ~= true then
    return 0
  end
  return 1
end
function get_view_cross_branches_data()
  if get_view_award_type() == 0 then
    return ui_cross_line.g_score_data
  else
    return ui_cross_line.g_history_score_data
  end
end
function on_event_list_observable()
end
function on_click_rank()
  ui_cross_line._runf()
end
function on_click_history_rank()
  ui_cross_line.runf_yesterday()
end
function set_visible()
  w_main.visible = true
  if sys.check(ui_net_delay.w_flicker_cross_line) then
    ui_net_delay.w_flicker_cross_line.suspended = true
    ui_net_delay.btn_cross_line.tip.text = ui.get_text("qbar|cross_line_tips")
  end
end
function r()
  on_init_list()
  w_main.visible = true
end
function get_useble()
  local player = bo2.player
  if sys.check(player) ~= true then
    return 0
  end
  return player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeCanUsePoint)
end
function get_title_text(grade_excel, camp)
  local player = bo2.player
  local title_excel_id = grade_excel.title
  local camp_id = player:get_atb(bo2.eAtb_Camp)
  if camp ~= nil then
    camp_id = camp
  end
  if camp_id == bo2.eCamp_Sword then
    title_excel_id = grade_excel.title1
  end
  local excel_camp = bo2.gv_text:find(title_excel_id)
  if sys.check(excel_camp) then
    return excel_camp.text, excel_camp
  end
end
function get_camp_repute_grade_by_id(id)
  return bo2.gv_camp_repute_grade:find(id)
end
function get_camp_repute_grade()
  local player = bo2.player
  if sys.check(player) ~= true then
    return nil
  end
  local point = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeTotalPoint)
  local grade_excel = get_grade_excel(point)
  return grade_excel
end
function get_grade_excel(point)
  local nGradeSize = bo2.gv_camp_repute_grade.size
  for i = 0, nGradeSize - 1 do
    local pGrade = bo2.gv_camp_repute_grade:get(i)
    if point < pGrade.point or 0 > pGrade.point then
      return pGrade
    end
  end
  return nil
end
function get_camp_repute_grade_excel()
  local total = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeTotalPoint)
  local grade_excel = get_grade_excel(total)
  return grade_excel
end
function refresh_point()
  local g_view_data = ui_cross_line.g_score_data
  local on_reset_dx = function()
    if sys.check(lb_blade_score_data) ~= true then
      return
    end
    lb_blade_score_data.text = sys.format(L("50.0%%"))
    lb_blade_score_data.tip.text = 0
    lb_sword_score_data.text = sys.format(L("50.0%%"))
    lb_sword_score_data.tip.text = 0
  end
  local blade_score = 0
  local sword_score = 0
  if g_view_data == nil or g_view_data.blade_score == nil or g_view_data.sword_score == nil then
  else
    blade_score = g_view_data.blade_score
    sword_score = g_view_data.sword_score
  end
  local totoal_dx = blade_score + sword_score
  local persent_blade = 50
  local persent_sword = 50
  if totoal_dx == nil or totoal_dx <= 0 then
    blade_score = 0
    sword_score = 0
    totoal_dx = 100
  else
    persent_blade = blade_score / totoal_dx * 100
    persent_sword = sword_score / totoal_dx * 100
  end
  lb_blade_score_data.tip.text = blade_score
  lb_sword_score_data.tip.text = sword_score
  lb_blade_score_data.svar.value = persent_blade
  lb_sword_score_data.svar.value = persent_sword
  if g_player_anime then
    playe_anime()
    g_player_anime = false
  end
end
function refresh_self()
  local player = bo2.player
  local mtf = {}
  mtf.total = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeTotalPoint)
  local grade_excel = get_grade_excel(mtf.total)
  if grade_excel ~= nil then
    if grade_excel.point < 0 then
      mtf.max = ui.get_text(L("camp_repute|infinite"))
    else
      mtf.max = grade_excel.point
    end
    mtf.rank_name = get_title_text(grade_excel)
    lb_grade.text = ui_widget.merge_mtf(mtf, ui.get_text(L("camp_repute|total_text")))
    fg_process.dx = 340 * mtf.total / grade_excel.point
  end
end
function refresh_period()
  local mtf = {}
  local os_time = ui_main.get_os_time()
  local c_week = tonumber(os.date("%w", os_time))
  local c_day = 0
  if c_week < g_reset_week then
    c_day = 7 - g_reset_week
  elseif c_week == g_reset_week then
    c_day = 0
    local h = tonumber(os.date("%H", os_time))
    if h < g_reset_hour then
      c_day = 7
    end
  else
    c_day = c_week - g_reset_week
  end
  local m_time = os_time - c_day * 24 * 60 * 60
  mtf.year = os.date("%Y", m_time)
  mtf.month = os.date("%m", m_time)
  mtf.day = os.date("%d", m_time)
  mtf.hour = sys.format("0%d", g_reset_hour)
  local end_time = m_time + 604800
  mtf.end_year = os.date("%Y", end_time)
  mtf.end_month = os.date("%m", end_time)
  mtf.end_day = os.date("%d", end_time)
  mtf.minute = L("00")
  ui_camp_repute.lb_period.text = ui_widget.merge_mtf(mtf, ui.get_text("camp_repute|period"))
end
function refresh_text()
  local player = bo2.player
  if sys.check(player) ~= true then
    return
  end
  local mtf = {}
  mtf.useble = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeCanUsePoint)
  mtf.last_week_point = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeLastWeekPoint)
  mtf.weekly_point = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeRankPoint)
  mtf.kill_count = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeKillCount)
  mtf.dead_count = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeDeadCount)
  mtf.total = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeTotalPoint)
  local grade_excel = get_grade_excel(mtf.total)
  local c_level = player:get_atb(bo2.eAtb_Level)
  if grade_excel ~= nil then
    local size_grade_level = bo2.gv_camp_repute_grade_level.size
    local max = 0
    local level_excel
    for i = 0, size_grade_level - 1 do
      local level = bo2.gv_camp_repute_grade_level:get(i)
      if c_level <= level.id then
        level_excel = level
        break
      end
    end
    if sys.check(level_excel) then
      max = level_excel.level_useble
    end
    if max < 0 then
      mtf.max_useble = sys.format(L("<c+:FFFFFF>%s<c->"), ui.get_text(L("camp_repute|infinite")))
    else
      mtf.max_useble = sys.format(L("<c+:FFFFFF>%d<c->"), max)
    end
  end
  local get_rank_text = function(_score_data)
    if _score_data.self_rank == nil or _score_data.self_rank <= 0 then
      return sys.format(L("<c+:FFFFFF>%s<c->"), ui.get_text("cross_line|no_rank"))
    else
      return sys.format(L("<c+:FFFFFF>%d<c->"), _score_data.self_rank)
    end
  end
  mtf.rank = get_rank_text(ui_cross_line.g_score_data)
  mtf.last_week_rank = get_rank_text(ui_cross_line.g_history_score_data)
  local function set_lb_text(name, value)
    local fmt_text = sys.format(L("camp_repute|%s"), name)
    local lb_parent = rb_list:search(name)
    if sys.check(lb_parent) ~= true then
      return
    end
    local rb = lb_parent:search(L("rb_info"))
    if sys.check(rb) then
      local fmt = sys.format(L("<c+:d3a75e>%s<c->"), ui.get_text(fmt_text))
      rb.mtf = ui_widget.merge_mtf(mtf, fmt)
      local lb_text = lb_parent:search(L("label0"))
      if sys.check(lb_text) then
        lb_text.visible = true
        lb_text.text = rb.mtf
        rb.parent.dx = lb_text.dx + 3
        lb_text.visible = false
      end
      return
    end
    local lb = lb_parent:search(L("lb_info"))
    lb.text = ui.get_text(fmt_text)
    local lb_value = lb_parent:search(L("lb_value"))
    lb_value.text = value
    local speed_point = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeWeeklyRecordPoint)
    local c_stage = 0
    local persent_size = grade_excel.weekly_reduce_point.size
    for i = 0, persent_size - 1 do
      if speed_point <= grade_excel.weekly_reduce_point[i] or 0 > grade_excel.weekly_reduce_point[i] then
        c_stage = i
        break
      end
    end
    lb_value.color = ui.make_color(g_stage_color[c_stage])
  end
  mtf.useble = sys.format(L("<c+:22AA66>%d<c->"), mtf.useble)
  mtf.last_week_point = sys.format(L("<c+:FFFFFF>%d<c->"), mtf.last_week_point)
  mtf.kill_count = sys.format(L("<c+:FFFFFF>%d<c->"), mtf.kill_count)
  mtf.dead_count = sys.format(L("<c+:FFFFFF>%d<c->"), mtf.dead_count)
  set_lb_text(L("rank"))
  set_lb_text(L("last_week_rank"))
  set_lb_text(L("week_point"), mtf.weekly_point)
  set_lb_text(L("last_week_point"))
  set_lb_text(L("kill_count"))
  set_lb_text(L("dead_count"))
  set_lb_text(L("useble"))
  set_lb_text(L("max_useble"))
end
function modify_cross_branches_text(owner)
  local os_time = ui_main.get_os_time()
  local mtf = ui_cross_line.get_battle_time_text(os_time)
  refresh_cb_button(mtf)
  local lt_camp_desc = owner.parent
  mtf.event_time = mtf.time
  local function set_rb_text(name, vis)
    local fmt_text = sys.format(L("camp_repute|%s"), name)
    local lb_parent = lt_camp_desc:search(name)
    if sys.check(lb_parent) ~= true then
      return
    end
    local lb = lb_parent:search(L("label"))
    if sys.check(lb) ~= true then
      return
    end
    if vis ~= nil then
      lb_parent.visible = false
    end
    local fmt = sys.format(L("<c+:FFFFFF>%s<c->"), ui.get_text(fmt_text))
    local text = ui_widget.merge_mtf(mtf, fmt)
    lb.mtf = text
  end
  set_rb_text("event_time")
end
function on_timer_modify_text(timer)
  if sys.check(ui_camp_repute.w_main) ~= true or ui_camp_repute.w_main.visible ~= true then
    return
  end
  local owner = timer.owner
  modify_cross_branches_text(owner)
  refresh_maze()
end
function refresh_cb_button(mtf_data)
  local item = g_event_list:item_get(0)
  local btn_table = item:search(L("port_btn"))
  local btn_trans = btn_table:search(L("btn_cl_trans"))
  local btn_join_battle = btn_table:search(L("btn_cl_join"))
  btn_trans.visible = mtf_data.btn_trans_vis
  btn_join_battle.visible = not mtf_data.btn_trans_vis
  btn_join_battle.enable = mtf_data.btn_join_vis
end
function refresh_maze()
  local item = g_event_list:item_get(2)
  if item == nil then
    return
  end
  local btn_table = item:search(L("port_btn"))
  local btn_trans = btn_table:search(L("btn_cl_trans"))
  local btn_join_battle = btn_table:search(L("btn_cl_join"))
  local function update_button()
    if get_maze_trans_data() ~= false and bo2.IsCoolDownOver(30149) ~= true then
      btn_trans.visible = true
      btn_join_battle.visible = false
      return 2
    else
      btn_trans.visible = false
      btn_join_battle.visible = true
      if bo2.IsCoolDownOver(30148) ~= true then
        btn_join_battle.enable = false
        return 1
      else
        btn_join_battle.enable = is_maze_event_opened()
        return 0
      end
    end
  end
  local rst = update_button()
  local excel = bo2.gv_camp_repute_desc:find(3)
  if excel == nil then
    return
  end
  local mtf = {}
  local fmt_text = sys.format(L("camp_repute|event_time"))
  local function set_rb_text(name, vis)
    local lb_parent = item:search(name)
    if sys.check(lb_parent) ~= true then
      return
    end
    local lb = lb_parent:search(L("label"))
    if sys.check(lb) ~= true then
      return
    end
    if vis ~= nil then
      lb_parent.visible = false
    end
    local fmt = sys.format(L("<c+:FFFFFF>%s<c->"), ui.get_text(fmt_text))
    local text = ui_widget.merge_mtf(mtf, fmt)
    lb.mtf = text
  end
  if rst == 0 then
    mtf.event_time = excel.time
  elseif rst == 1 then
    local os_time = ui_main.get_os_time()
    local second = tonumber(os.date("%S", os_time))
    mtf.second = 30 - second % 30
    mtf.event_time = ui_widget.merge_mtf(mtf, ui.get_text(L("cross_line|maze_transfer_counter")))
  else
    local os_time = ui_main.get_os_time()
    get_maze_trans_time()
    mtf.second = get_maze_trans_time() - os_time
    mtf.event_time = ui_widget.merge_mtf(mtf, ui.get_text(L("cross_line|maze_transfer_timeout")))
  end
  set_rb_text(L("event_time"))
end
function refresh_list_item()
  local os_time = ui_main.get_os_time()
  local mtf_data = ui_cross_line.get_battle_time_text(os_time)
  refresh_cb_button(mtf_data)
  refresh_maze()
end
function update_ui()
  refresh_point()
  refresh_self()
  refresh_period()
  refresh_text()
  refresh_award()
  refresh_list_item()
  btn_show_grade.check = bo2.player:get_flag_int8(bo2.ePlayerFlag8_ShowArenaRank) == 2
end
function on_make_point_tip(tip)
  local mtf = {}
  local grade_excel = get_camp_repute_grade_excel()
  local player = bo2.player
  mtf.point = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeRankPoint)
  mtf.speed = 100
  local speed_point = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeWeeklyRecordPoint)
  local stk = sys.mtf_stack()
  stk:raw_push(L("<c:9c9c9c>"))
  local function push_new_line()
    stk:push(L("\n"))
  end
  if grade_excel then
    local size_grade_level = bo2.gv_camp_repute_grade_level.size
    local function push_reduce_persent(persent)
      if persent >= 100 then
      else
        local persent_mtf = {}
        persent_mtf.reduce_persent = 100 - persent
        mtf.speed = mtf.speed * persent / 100
      end
    end
    local persent_size = grade_excel.weekly_reduce_point.size
    for i = 0, persent_size - 1 do
      if speed_point <= grade_excel.weekly_reduce_point[i] or grade_excel.weekly_reduce_point[i] < 0 then
        local w_reduce = grade_excel.weekly_reduce_persent[i]
        push_reduce_persent(w_reduce)
        break
      end
    end
    local c_level = player:get_atb(bo2.eAtb_Level)
    local level_excel
    for i = 0, size_grade_level - 1 do
      local level = bo2.gv_camp_repute_grade_level:get(i)
      if c_level <= level.id then
        level_excel = level
        break
      end
    end
    local level_reduce_persent = level_excel.level_reduce_persent
    push_reduce_persent(level_reduce_persent)
    mtf.speed = sys.format(L("%.1f"), mtf.speed)
    stk:raw_push(ui.get_text("camp_repute|reduce_cause"))
    push_new_line()
    stk:raw_push(ui.get_text("camp_repute|reduce_level_cause"))
  end
  ui_tool.ctip_push_sep(stk)
  local fmt = ui.get_text("camp_repute|week_point_tip")
  stk:raw_push(ui_widget.merge_mtf(mtf, fmt))
  ui_widget.tip_make_view(tip.view, stk.text)
end
function on_make_grade_tip(tip)
  local mtf = {}
  local player = bo2.player
  mtf.total = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeTotalPoint)
  local grade_excel = get_grade_excel(mtf.total)
  local fmt = ui.get_text("camp_repute|grade_tip")
  local stk = sys.mtf_stack()
  local function push_new_line()
    stk:push(L("\n"))
  end
  if grade_excel == nil then
    return
  end
  mtf.grade_title = get_title_text(grade_excel)
  local text = ui_widget.merge_mtf(mtf, fmt)
  local c_size = bo2.gv_camp_repute_grade.size
  local c_title_color = "d3a75e"
  for i = 0, c_size - 1 do
    local excel = bo2.gv_camp_repute_grade:get(i)
    local title_text, title_excel = get_title_text(excel, camp_id)
    if i + 1 == grade_excel.id and 0 < title_excel.targets.size then
      local c_excel_id = title_excel.targets[0]
      local lootlevel = bo2.gv_lootlevel:find(c_excel_id)
      if lootlevel ~= nil then
        c_title_color = sys.format(L("%x"), lootlevel.color)
        break
      end
    end
  end
  ui_tool.ctip_make_title_ex(stk, mtf.grade_title, c_title_color, ui_tool.cs_tip_a_add_m)
  push_new_line()
  stk:raw_push(L("<c:9C9C9C>"))
  ui_tool.ctip_push_sep(stk)
  local camp_id = player:get_atb(bo2.eAtb_Camp)
  local target_camp = camp_id
  if camp_id == bo2.eCamp_Sword then
    mtf.camp = ui.get_text("cross_line|camp_sword")
    target_camp = bo2.eCamp_Blade
  else
    mtf.camp = ui.get_text("cross_line|camp_blade")
    target_camp = bo2.eCamp_Sword
  end
  text = ui_widget.merge_mtf(mtf, ui.get_text("camp_repute|title_level"))
  stk:raw_push(text)
  for i = 0, c_size - 1 do
    local c_color = "9C9C9C"
    local excel = bo2.gv_camp_repute_grade:get(i)
    local title_text, title_excel = get_title_text(excel, camp_id)
    if i + 1 == grade_excel.id and 0 < title_excel.targets.size then
      local c_excel_id = title_excel.targets[0]
      local lootlevel = bo2.gv_lootlevel:find(c_excel_id)
      if lootlevel ~= nil then
        c_color = sys.format(L("%x"), lootlevel.color)
      end
    end
    push_new_line()
    stk:raw_push(L("<space:0.5>"))
    ui_tool.ctip_push_text(stk, title_text, c_color, ui_tool.cs_tip_a_add_l)
    local point = excel.point
    if point < 0 then
      point = ui.get_text(L("camp_repute|infinite"))
    end
    ui_tool.ctip_push_text(stk, point, c_color, ui_tool.cs_tip_a_add_r)
    if 0 > excel.point then
      break
    end
  end
  ui_tool.ctip_push_sep(stk)
  local dead_reduce_text
  if 0 <= grade_excel.reduce_total then
    dead_reduce_text = ui.get_text("camp_repute|camp_dead_reduce_all")
  else
    dead_reduce_text = ui.get_text("camp_repute|camp_dead_notify")
  end
  stk:raw_push(dead_reduce_text)
  push_new_line()
  local pve_reduce
  if grade_excel.pve_reduce_persent < 100 then
    pve_reduce = ui.get_text("camp_repute|pve_reduce")
  else
    pve_reduce = ui.get_text("camp_repute|pve_none_reduce")
  end
  stk:raw_push(pve_reduce)
  ui_widget.tip_make_view(tip.view, stk.text)
end
function on_esc_stk_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  on_anime_visible(vis)
  ui_cross_line.view_all_score()
  g_player_anime = vis
end
function update_item_highlight(item)
  if item == nil then
    return
  end
  local hover = item:search("item_hover")
  if hover == nil then
    return
  end
  if item.inner_hover then
    if item.selected == false then
      hover.visible = true
    else
      hover.visible = false
    end
  else
    hover.visible = false
  end
end
function on_item_mouse(w, msg, pos, wheel)
  update_item_highlight(w)
end
function disselected_all_item()
  local size = g_event_list.item_count
  for i = 0, size - 1 do
    local item = g_event_list:item_get(i)
    disselect_item(item)
  end
end
function disselect_item(item)
  item.dy = 72
  item:search(L("cell2")).visible = false
  item.svar.sel = nil
  item:search(L("highlight")).visible = false
  item:search(L("aq_select")).visible = false
end
function select_item(item)
  if sys.check(item) ~= true then
    return false
  end
  if item.svar.sel ~= nil then
    return
  end
  disselected_all_item()
  item.dy = 240
  item:search(L("cell2")).visible = true
  item.svar.sel = 1
  item:search(L("highlight")).visible = true
  item:search(L("aq_select")).visible = true
end
function on_event_item_sel(item)
  select_item(item)
end
function on_click_show_grade()
  local check = btn_show_grade.check
  local flag = 0
  if check == true then
    flag = 2
  else
    flag = 0
  end
  bo2.send_flag_int8(bo2.ePlayerFlag8_ShowArenaRank, flag)
end
function on_init_list()
  g_event_list:item_clear()
  local excel_size = bo2.gv_camp_repute_desc.size
  local load_item = function(excel, sel)
    if excel == nil then
      return
    end
    local item = g_event_list:item_append()
    item:load_style(L("$frame/cross_line/camp_repute.xml"), "event_item")
    local lb_name = item:search(L("event_name"))
    lb_name.text = excel.name
    if sel then
      item.selected = true
    end
    local mtf = {}
    mtf.event_time = excel.time
    mtf.rule = excel.rule
    mtf.rule_tip = excel.rule_tip
    mtf.win_condition = excel.win_condition
    mtf.reaward = excel.award
    mtf.port = excel.enter_port
    local fmt_mtf = {}
    for i, v in pairs(mtf) do
      fmt_mtf.i = sys.format(L("<c+:FFFFFF>%s<c->"), v)
    end
    local lt_camp_desc = item:search(L("cell2"))
    local pic = item:search(L("campaign_pic"))
    pic.image = sys.format(L("$image/campaign/img/%s"), excel.pic)
    local function set_rb_text(name, vis)
      local fmt_text = sys.format(L("camp_repute|%s"), name)
      local lb_parent = lt_camp_desc:search(name)
      if sys.check(lb_parent) ~= true then
        return
      end
      local lb = lb_parent:search(L("label"))
      if sys.check(lb) ~= true then
        return
      end
      if vis ~= nil then
        lb_parent.visible = false
      end
      local fmt = sys.format(L("<c+:FFFFFF>%s<c->"), ui.get_text(fmt_text))
      local text = ui_widget.merge_mtf(mtf, fmt)
      lb.mtf = text
    end
    local function set_lb_with_tip_text(name, tip_title, tip_text)
      local fmt_text = sys.format(L("camp_repute|%s"), name)
      local lb_parent = lt_camp_desc:search(name)
      if sys.check(lb_parent) ~= true then
        return
      end
      local lb = lb_parent:search(L("label_tip"))
      if sys.check(lb) ~= true then
        return
      end
      lb.text = tip_title
      lb.tip.text = tip_text
    end
    local function set_lb_with_btn(name, vis, type)
      local fmt_text = sys.format(L("camp_repute|%s"), name)
      local lb_parent = lt_camp_desc:search(name)
      if sys.check(lb_parent) ~= true then
        return
      end
      lb_parent.visible = true
      if type ~= 2 then
        local timer = lb_parent.timer
        timer.suspended = false
        modify_cross_branches_text(lb_parent)
      else
        local btn_trans = lb_parent:search(L("btn_cl_trans"))
        local btn_join_battle = lb_parent:search(L("btn_cl_join"))
        btn_trans.svar.type = type
        btn_join_battle.svar.type = type
        btn_trans.text = ui.get_text(L("cross_line|trans_maze"))
        btn_join_battle.text = ui.get_text(L("cross_line|reg_maze"))
        btn_trans.margin = ui.rect(0, 0, 40, 37)
        btn_join_battle.margin = ui.rect(0, 0, 40, 37)
        btn_trans.visible = false
        btn_join_battle.visible = true
        btn_join_battle.enable = false
      end
      local lb = lb_parent:search(L("label"))
      if sys.check(lb) ~= true then
        return
      end
      local fmt = ui.get_text(fmt_text)
      local text = ui_widget.merge_mtf(mtf, fmt)
      lb.text = text
    end
    set_rb_text("event_time")
    set_lb_with_tip_text(L("rule"), mtf.rule, mtf.rule_tip)
    if mtf.win_condition.size >= 1 then
      set_rb_text("win_condition")
    else
      set_rb_text("win_condition", false)
    end
    local event_type = excel.event_type
    set_rb_text("reaward")
    if event_type == 3 then
      set_rb_text("port")
    elseif event_type == 1 or event_type == 2 then
      set_rb_text("port", false)
      set_lb_with_btn("port_btn", true, event_type)
    end
  end
  for i = 0, excel_size - 1 do
    local excel = bo2.gv_camp_repute_desc:get(i)
    load_item(excel, i == 0)
  end
  local total_repute_money = bo2.gv_define_org:find(132).value.v_int
  repute_total_award.mtf = sys.format(L("<space:0.2><m:%d>"), total_repute_money)
end
function on_click_open_shop()
  local v = sys.variant()
  v:set(packet.key.cmn_system_flag, 1)
  v:set(packet.key.cmn_type, 100)
  bo2.send_variant(packet.eCTS_UI_OpenReputeShop, v)
  w_main.visible = false
end
function on_point()
  refresh_self()
  refresh_text()
end
function on_self_enter()
  local obj = bo2.player
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_CampReputeTotalPoint, on_point, "ui_camp_repute.on_score")
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_CampReputeCanUsePoint, on_point, "ui_camp_repute.on_score")
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_CampReputeRankPoint, on_point, "ui_camp_repute.on_score")
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_CampReputeKillCount, on_point, "ui_camp_repute.on_score")
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_CampReputeDeadCount, on_point, "ui_camp_repute.on_score")
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_camp_repute.on_self_enter")
