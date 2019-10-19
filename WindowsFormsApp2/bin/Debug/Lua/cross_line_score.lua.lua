local n_page_limit = 7
local cell_name = L("rank%d")
local g_max_rank_score_count = 4
local max_cd_times = 14
g_score_data = {}
g_history_score_data = {}
g_cross_line_battle_time = {}
g_cross_line_popo_data = nil
g_cross_line_item_flag = nil
g_cd_table = {}
g_use_cross_line_ghost = bo2.gv_define:find(50015).value.v_int
g_minute_inteval = 1
function on_init_battle_time()
  g_cross_line_battle_time.size = 2
  g_cross_line_battle_time[1] = {
    _begin = {hour = 11, minute = 20},
    _end = {hour = 12, minute = 0}
  }
  g_cross_line_battle_time[2] = {
    _begin = {hour = 23, minute = 20},
    _end = {hour = 24, minute = 0}
  }
  for i = 1, g_cross_line_battle_time.size do
    local hour = g_cross_line_battle_time[i]._begin.hour
    local minute = g_cross_line_battle_time[i]._begin.minute
    g_cross_line_battle_time[i]._begin.t0 = hour * 60 + minute
    hour = g_cross_line_battle_time[i]._end.hour
    minute = g_cross_line_battle_time[i]._end.minute
    g_cross_line_battle_time[i]._end.t0 = hour * 60 + minute
  end
  g_cd_table = {}
  g_cd_table[0] = {max = 12}
  g_cd_table[1] = {max = 16}
  g_cd_table[1][0] = 30041
  local index = 1
  for i = 30065, 30079 do
    g_cd_table[1][index] = i
    index = index + 1
  end
  index = 0
  for i = 30053, 30064 do
    g_cd_table[0][index] = i
    index = index + 1
  end
end
on_init_battle_time()
function get_full_time(time_data)
  if time_data <= 0 then
    return sys.format(L("%d"), 0)
  elseif time_data < 10 then
    return sys.format(L("0%d"), time_data)
  else
    return sys.format(L("%d"), time_data)
  end
end
function get_battle_time_text(os_time)
  local hour = tonumber(os.date("%H", os_time))
  local minute = tonumber(os.date("%M", os_time))
  local second = tonumber(os.date("%S", os_time))
  local default_text = {}
  default_text.status_dy = 23
  default_text.btn_trans_vis = false
  default_text.btn_join_vis = false
  if g_cross_line_popo_data ~= nil and os_time < g_cross_line_popo_data.time and bo2.IsCoolDownOver(50054) then
    default_text.status = ui.get_text("cross_line|status_battle")
    local totoal_second = g_cross_line_popo_data.time - os_time
    default_text.minute = get_full_time(math.floor(totoal_second / 60))
    default_text.second = get_full_time(math.floor(totoal_second % 60))
    default_text.time = ui_widget.merge_mtf(default_text, ui.get_text("cross_line|trans_time_out"))
    default_text.btn_trans_vis = true
    if g_cross_line_item_flag == 1 then
      default_text.btn_trans_vis = false
    end
    return default_text
  end
  local _time = hour * 60 + minute
  local function get_trans_minute(time_begin, time_end)
    local next_minute = 0
    local minute_inteval = g_minute_inteval
    local end_minute = time_end.minute
    if end_minute == 0 then
      end_minute = 60
    end
    for i = minute_inteval, end_minute, minute_inteval do
      next_minute = time_begin.minute + i
      if next_minute > minute then
        return get_full_time(next_minute - minute - 1)
      end
    end
    return L("0")
  end
  for i = 1, g_cross_line_battle_time.size do
    local time_begin = g_cross_line_battle_time[i]._begin
    local time_end = g_cross_line_battle_time[i]._end
    if _time < time_begin.t0 then
      default_text.status = ui.get_text("cross_line|status_close")
      local time_diff = time_begin.t0 - _time
      default_text.hour = get_full_time(math.floor(time_diff / 60))
      default_text.second = get_full_time(59 - second)
      default_text.minute = get_full_time(math.floor(time_diff % 60) - 1)
      default_text.time = ui_widget.merge_mtf(default_text, ui.get_text("cross_line|close_text"))
      local time_data = get_next_time_data(os_time)
      default_text.award_time = sys.format(L("<a:r><c:979797>%s"), ui_widget.merge_mtf(time_data, ui.get_text("cross_line|current_award")))
      return default_text
    else
      if _time >= time_begin.t0 and _time < time_end.t0 then
        if bo2.IsCoolDownOver(30046) then
          default_text.status = ui.get_text("cross_line|status_open")
          default_text.status_dy = 23
          default_text.btn_join_vis = true
        else
          default_text.status = ui.get_text("cross_line|status_join")
        end
        default_text.second = get_full_time(59 - second)
        default_text.minute = get_trans_minute(time_begin, time_end)
        default_text.time = ui_widget.merge_mtf(default_text, ui.get_text("cross_line|next_battle_text"))
        return default_text
      else
      end
    end
  end
  return default_text
end
local g_view_award_type = 0
local g_rank_award_table, g_camp_award_table, g_score_award_table
local g_max_item_size = 3
local g_camp_cd = {}
local g_rank_cd = {}
local g_score_cd = {}
local g_total_cd = {}
g_camp_ghost_cd = {}
local g_award_cd_type = {}
function get_next_day(week)
  local week0 = 3
  local week1 = 7
  if week < week0 then
    return week0 - week - 1
  elseif week < week1 then
    return week1 - week - 1
  else
    return 7 - week + week0 - 1
  end
end
function get_cd_type(week, type)
  local cd_type = g_award_cd_type[week]
  if type == 1 then
    if cd_type == 0 then
      cd_type = 1
    else
      cd_type = 0
    end
  end
  return cd_type
end
function get_score_cd_index(week, type)
  local cd_type = g_award_cd_type[week]
  if type == 1 then
    if cd_type == 0 then
      cd_type = 1
    else
      cd_type = 0
    end
  end
  return g_score_cd[cd_type]
end
function get_cd_index(week, type)
  local cd_type = g_award_cd_type[week]
  if type == 0 then
    return g_rank_cd[cd_type]
  elseif type == 1 then
    return g_camp_cd[cd_type]
  else
    return g_total_cd[cd_type]
  end
end
function on_init_cd_data()
  g_camp_cd[0] = 30100
  g_camp_cd[1] = 30043
  g_rank_cd[0] = 30101
  g_rank_cd[1] = 30045
  g_score_cd[0] = 30053
  g_score_cd[1] = 30041
  g_total_cd[0] = 30114
  g_total_cd[1] = 30113
  g_camp_ghost_cd[0] = 30125
  g_camp_ghost_cd[1] = 30124
  g_award_cd_type = {}
  g_award_cd_type[0] = 0
  g_award_cd_type[1] = 0
  g_award_cd_type[2] = 0
  g_award_cd_type[3] = 1
  g_award_cd_type[4] = 1
  g_award_cd_type[5] = 1
  g_award_cd_type[6] = 1
  g_award_cd_type[7] = 0
end
on_init_cd_data()
function check_award_table_vaild()
  if g_rank_award_table == nil then
    g_rank_award_table = sys.load_table("$mb/cross_line/cross_line_rank_award.xml")
  end
end
function find_camp_award(id)
  if g_camp_award_table == nil then
    g_camp_award_table = sys.load_table("$mb/cross_line/cross_line_camp_award.xml")
  end
  if sys.check(g_camp_award_table) then
    return g_camp_award_table:find(id)
  else
    return nil
  end
end
function find_rank_award(id)
  check_award_table_vaild()
  if sys.check(g_rank_award_table) then
    return g_rank_award_table:find(id)
  else
    return nil
  end
end
function get_rank_award(id)
  check_award_table_vaild()
  if sys.check(g_rank_award_table) then
    return g_rank_award_table:get(id)
  else
    return nil
  end
end
function get_size_rank_award()
  check_award_table_vaild()
  if sys.check(g_rank_award_table) then
    return g_rank_award_table.size
  else
    return 0
  end
end
function check_score_award_valid()
  if g_score_award_table == nil then
    g_score_award_table = sys.load_table("$mb/cross_line/cross_line_score_award.xml")
  end
end
function get_score_award(i)
  check_score_award_valid()
  if sys.check(g_score_award_table) then
    return g_score_award_table:get(i)
  else
    return nil
  end
end
function get_score_award_size()
  check_score_award_valid()
  if sys.check(g_score_award_table) then
    return g_score_award_table.size
  else
    return 0
  end
end
function find_score_award(id)
  check_score_award_valid()
  if sys.check(g_score_award_table) then
    return g_score_award_table:find(id)
  else
    return nil
  end
end
local page_blade = {}
local page_sword = {}
g_view_type = 0
function on_init_data()
  local reset_data = function()
    _score_data = {}
    _score_data.rank = {}
    _score_data.request_page = {}
    _score_data.rank[bo2.eCamp_Blade] = {}
    _score_data.request_page[bo2.eCamp_Blade] = 0
    _score_data.rank[bo2.eCamp_Sword] = {}
    _score_data.request_page[bo2.eCamp_Sword] = 0
    _score_data.request_id = 0
    _score_data.blade_score = 0
    _score_data.sword_score = 0
    _score_data.self_rank = 0
    _score_data.self_score = 0
    return _score_data
  end
  g_score_data = reset_data()
  g_history_score_data = reset_data()
  g_view_type = 0
end
on_init_data()
function set_cell(cell, page, id)
  if id > page.count or page.data == nil or page.data[id] == nil then
    cell.visible = false
    return
  end
  cell.visible = true
  local view_data = page.data[id]
  local lb_rank = cell:search("lb_rank")
  local lb_cha_name = cell:search("lb_cha_name")
  local lb_score = cell:search("lb_score")
  local cur_name = view_data.name
  if g_use_cross_line_ghost ~= 0 and page.key == bo2.eCamp_Blade then
    local g_view_data = g_score_data
    if g_view_type ~= 0 then
      g_view_data = g_history_score_data
    end
    for i, v in pairs(g_view_data.rank[bo2.eCamp_Sword]) do
      if v ~= nil and v.name ~= nil and v.name == cur_name then
        cur_name = ui.get_text(L("cross_line|new_camp"))
        break
      end
    end
  end
  lb_rank.text = id
  lb_cha_name.text = cur_name
  lb_score.text = view_data.score
end
function update_page(page)
  if sys.check(page.step) ~= true then
    return
  end
  if page.index > page.count then
    page.index = 0
  end
  local p_idx = math.floor(page.index / n_page_limit)
  local p_cnt = math.floor((page.count + n_page_limit - 1) / n_page_limit)
  ui_widget.ui_stepping.set_page(page.step, p_idx, p_cnt)
  local view = page.step.parent
  local idx = p_idx * n_page_limit + 1
  local page_count = n_page_limit - 1
  for i = 0, page_count do
    local cname = sys.format(cell_name, i)
    local cell = view:search(cname)
    if sys.check(cell) ~= true then
      return
    end
    local iRank = i + 1 + page.index
    set_cell(cell, page, iRank)
  end
end
function update_step()
  local g_view_data = g_score_data
  if g_view_type ~= 0 then
    g_view_data = g_history_score_data
  end
  if g_view_data == nil then
    return
  end
  page_blade = {
    index = 0,
    count = 20,
    key = bo2.eCamp_Blade
  }
  page_sword = {
    index = 0,
    count = 20,
    key = bo2.eCamp_Sword
  }
  page_blade.data = g_view_data.rank[page_blade.key]
  page_sword.data = g_view_data.rank[page_sword.key]
  local blade_step = ui_cross_line.w_score_rank:search("blade_rank")
  local sword_step = ui_cross_line.w_score_rank:search("sword_rank")
  if sys.check(blade_step) ~= true or sys.check(sword_step) ~= true then
    ui.log("error step")
    return
  end
  page_blade.step = blade_step:search("step")
  page_sword.step = sword_step:search("step")
  local function on_init_step(page)
    local function on_page_step(var)
      page.index = var.index * n_page_limit
      update_page(page)
      if var.index >= 0 then
        local iIndex = var.index + 1
        local v_data = sys.variant()
        v_data[packet.key.CrossLineClientPacket_RequestType] = g_view_type
        v_data[packet.key.mall_page_cur] = iIndex
        v_data[packet.key.camp_id] = page.key
        bo2.send_variant(packet.eCTS_UI_RequestCrossLineData, v_data)
      end
    end
    ui_widget.ui_stepping.set_event(page.step, on_page_step)
    update_page(page)
  end
  on_init_step(page_blade)
  on_init_step(page_sword)
end
function update_score_data()
  local g_view_data = g_score_data
  if g_view_type ~= 0 then
    g_view_data = g_history_score_data
  end
  local on_reset_dx = function()
    if sys.check(lb_blade_score_data) ~= true then
      return
    end
    lb_blade_score_data.text = sys.format(L("0(50.00%%)"))
    lb_sword_score_data.text = sys.format(L("0(50.00%%)"))
    fg_blade_score_pic.dx = 252
    fg_sword_score_pic.dx = 252
    fg_sword_score_pic.margin = ui.rect(252, 0, 0, 0)
  end
  if g_view_data == nil or g_view_data.blade_score == nil or g_view_data.sword_score == nil then
    on_reset_dx()
    return
  end
  local blade_score = g_view_data.blade_score
  local sword_score = g_view_data.sword_score
  local totoal_dx = blade_score + sword_score
  if totoal_dx == nil or totoal_dx <= 0 then
    on_reset_dx()
  else
    local persent_blade = blade_score / totoal_dx * 100
    local persent_sword = sword_score / totoal_dx * 100
    lb_blade_score_data.text = sys.format(L("%d(%.2f%%)"), blade_score, persent_blade)
    lb_sword_score_data.text = sys.format(L("%d(%.2f%%)"), sword_score, persent_sword)
    local dx_persent = 100 + math.floor(g_view_data.blade_score / totoal_dx * 252)
    fg_blade_score_pic.dx = dx_persent
    fg_sword_score_pic.dx = 512 - dx_persent
    fg_sword_score_pic.margin = ui.rect(dx_persent, 0, 0, 0)
  end
end
local stk_push_color_red = function(stk)
  stk:push("<c+:C92B2B>")
end
local stk_push_color_blue = function(stk)
  stk:push("<c+:17A6DB>")
end
local stk_push_color_gray = function(stk)
  stk:push("<c+:979797>")
end
function stk_push_color_end(stk)
  stk:push("<c->")
end
function stk_push_edge_full(stk, _font, size)
  stk:push(sys.format(L("<lb:%s,%d,full,,100|"), _font, size))
end
function stk_push_edge_full_end(stk)
  stk:push(">")
end
function stk_push_new_line(stk)
  stk:push("\n")
end
function stk_push_line_text(stk, text, color_fn, _size, _font, _noline)
  if color_fn ~= nil then
    color_fn(stk)
  end
  if _font == nil then
    _font = "plain"
  end
  if _size == nil then
    _size = 14
  end
  stk_push_edge_full(stk, _font, _size)
  stk:push(text)
  stk_push_edge_full_end(stk)
  if _noline == nil then
    stk_push_new_line(stk)
  end
  if color_fn ~= nil then
    stk_push_color_end(stk)
  end
end
function on_show_tip_rank_score(tip)
  local stk = sys.mtf_stack()
  local desc_title
  local _score_data = g_score_data
  if g_view_type ~= 0 then
    _score_data = g_history_score_data
    desc_title = sys.format(ui.get_text("cross_line|last_contri_desc"))
  else
    desc_title = sys.format(ui.get_text("cross_line|my_contri_desc"))
  end
  ui_tool.ctip_make_title_ex(stk, desc_title, SHARED("17A6DB"), ui_tool.cs_tip_a_add_m)
  ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  ui_tool.ctip_push_text(stk, sys.format(ui.get_text("cross_line|rank_rule_desc")), SHARED("979797"), ui_tool.cs_tip_a_add_l)
  stk:raw_push(L("<space:15>"))
  ui_tool.ctip_push_sep(stk)
  local first = true
  local function add_sep()
    if first == false then
      ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
    else
      first = false
    end
  end
  local sort_tab = _score_data.sort_tab
  local common_tab = _score_data.self_rank_data
  local has_tab = {}
  local os_time = ui_main.get_os_time()
  local time_data = {}
  local week = tonumber(os.date("%w", os_time))
  local cd_type = get_cd_type(week, g_view_type)
  local idx_table = g_cd_table[cd_type]
  local function add_data(val, score)
    local color = SHARED("979797")
    if score ~= 0 then
      color = SHARED("FFFFFF")
    end
    local week_desc
    if g_view_type ~= 0 then
      if cd_type == 1 then
        week_desc = ui.get_text("cross_line|last_week")
      elseif val >= 30057 and val <= 30064 then
        week_desc = ui.get_text("cross_line|this_week")
      else
        week_desc = ui.get_text("cross_line|last_week")
      end
    elseif cd_type == 1 then
      week_desc = ui.get_text("cross_line|this_week")
    elseif week == 0 then
      if val >= 30057 and val <= 30064 then
        week_desc = ui.get_text("cross_line|next_week")
      else
        week_desc = ui.get_text("cross_line|this_week")
      end
    elseif val >= 30057 and val <= 30064 then
      week_desc = ui.get_text("cross_line|this_week")
    else
      week_desc = ui.get_text("cross_line|last_week")
    end
    local text = sys.format("cross_line|%d", val)
    text = ui.get_text(text)
    text = ui_widget.merge_mtf({time = week_desc}, text)
    add_sep()
    ui_tool.ctip_push_text(stk, text, color, ui_tool.cs_tip_a_add_l)
    local score_text = sys.format(L("%d"), score)
    ui_tool.ctip_push_text(stk, score_text, color, ui_tool.cs_tip_a_add_r)
  end
  ui_tool.ctip_push_text(stk, sys.format(ui.get_text("cross_line|max_contri_desc")), SHARED("17A6DB"), ui_tool.cs_tip_a_add_m)
  ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  if sys.check(sort_tab) then
    for i = 0, sort_tab.size - 1 do
      local n, data = sort_tab:fetch_nv(i)
      local v_index = data[packet.key.cmn_type]
      local v_val = data[packet.key.gs_score]
      add_data(v_index, v_val, SHARED("C92B2B"))
      has_tab[v_index] = 1
      if i >= g_max_rank_score_count - 1 then
        break
      end
    end
  end
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, sys.format(ui.get_text("cross_line|current_contri_desc")), SHARED("17A6DB"), ui_tool.cs_tip_a_add_m)
  ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  first = true
  for i = 0, idx_table.max - 1 do
    local val = idx_table[i]
    if val ~= nil and has_tab[val] == nil then
      local score = 0
      if sys.check(common_tab) and common_tab:has(tonumber(val)) then
        score = common_tab:get(val).v_int
      end
      add_data(val, score)
    end
  end
  tip.text = stk.text
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function get_score_award_excel(score)
  local size = get_score_award_size()
  local current, next
  local max = false
  for i = 0, size - 1 do
    local excel = get_score_award(i)
    if i == 0 then
      next = excel
    end
    if score >= excel.score_begin and (score < excel.score_end or 0 > excel.score_end) then
      current = excel
      next = get_score_award(i + 1)
      break
    end
  end
  return current, next
end
function refresh_total_score_award(stk)
  local _score_data = g_score_data
  ui_tool.ctip_push_text(stk, sys.format(ui.get_text("cross_line|total_contri_title")), SHARED("17A6DB"), ui_tool.cs_tip_a_add_m)
  ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  ui_tool.ctip_push_text(stk, sys.format(ui.get_text("cross_line|total_contri_desc")), SHARED("979797"), ui_tool.cs_tip_a_add_l)
  ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  local color_current = SHARED("FFFFFF")
  if _score_data.total_score == nil or _score_data.total_score == 0 then
    _score_data.total_score = 0
  end
  ui_tool.ctip_push_text(stk, sys.format(ui.get_text("cross_line|total_contri_current")), color_current, ui_tool.cs_tip_a_add_l)
  ui_tool.ctip_push_text(stk, _score_data.total_score, color_current, ui_tool.cs_tip_a_add_r)
  ui_tool.ctip_push_sep(stk)
  local score = _score_data.total_score
  local excel_current, excel_next = get_score_award_excel(score)
  local mtf_data = {}
  ui_tool.ctip_push_text(stk, sys.format(ui.get_text("cross_line|total_contri_current_stage")), SHARED("C92B2B"), ui_tool.cs_tip_a_add_m)
  if excel_current == nil then
    ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
    ui_tool.ctip_push_text(stk, sys.format(ui.get_text("cross_line|total_contri_current_none")), SHARED("979797"), ui_tool.cs_tip_a_add_l)
    ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  else
    if 0 < excel_current.score_end then
      mtf_data.begin0 = excel_current.score_begin
      mtf_data.end0 = excel_current.score_end
      title_text = ui_widget.merge_mtf(mtf_data, sys.format(ui.get_text("cross_line|total_contri_bd")))
    else
      mtf_data.begin0 = excel_current.score_begin
      title_text = ui_widget.merge_mtf(mtf_data, sys.format(ui.get_text("cross_line|total_contri_max")))
    end
    ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
    ui_tool.ctip_push_text(stk, title_text, SHARED("FFFFFF"), ui_tool.cs_tip_a_add_l)
    stk:raw_push(L("<a+:r><c+:FFFFFF>"))
    stk:raw_push(sys.format(L("<m:%d>"), excel_current.award_money))
    stk:raw_push(L("<c-><a->"))
    ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  end
  if excel_next ~= nil then
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
    ui_tool.ctip_push_text(stk, sys.format(ui.get_text("cross_line|total_contri_next_stage")), SHARED("C92B2B"), ui_tool.cs_tip_a_add_m)
    ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
    ui_tool.ctip_push_text(stk, title_text, SHARED("979797"), ui_tool.cs_tip_a_add_l)
    stk:raw_push(L("<a+:r><c+:979797>"))
    stk:raw_push(sys.format(L("<m:%d>"), excel_next.award_money))
    stk:raw_push(L("<c-><a->"))
    ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  else
  end
  ui_tool.ctip_push_sep(stk)
end
function on_show_tip_rank_award(tip)
  local stk = sys.mtf_stack()
  local _score_data = g_score_data
  local _self_rank = {}
  local _self_award = {}
  local rank_range_mtf
  _self_rank, _self_award, rank_range_mtf = refresh_award_by_rank(_score_data)
  refresh_total_score_award(stk)
  ui_tool.ctip_push_text(stk, rank_range_mtf, SHARED("17A6DB"), ui_tool.cs_tip_a_add_m)
  ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
  local os_time = ui_main.get_os_time()
  local time_data = get_next_time_data(os_time)
  ui_tool.ctip_push_text(stk, ui_widget.merge_mtf(time_data, ui.get_text("cross_line|current_award")), SHARED("979797"), ui_tool.cs_tip_a_add_l)
  stk:raw_push(L("<space:18>"))
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("cross_line|item"), SHARED("FFFFFF"), ui_tool.cs_tip_a_add_l)
  if sys.check(_self_award.v_item) then
    local nItemSize = _self_award.v_item.size
    local item_pos = 0
    for i = 0, nItemSize - 1, 2 do
      local itemExcelId = _self_award.v_item[i]
      local itemCount = _self_award.v_item[i + 1]
      ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline)
      stk:raw_push(sys.format(L("<i:%d> x %d"), itemExcelId, itemCount))
    end
  end
  tip.text = stk.text
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function update_self_data()
  local player = bo2.player
  if sys.check(player) ~= true then
    return
  end
  local _score_data = g_score_data
  if g_view_type ~= 0 then
    _score_data = g_history_score_data
  else
    local os_time = ui_main.get_os_time()
    local time_data = get_next_time_data(os_time)
    btn_receive_award.tip.text = ui_widget.merge_mtf(time_data, ui.get_text("cross_line|current_award"))
  end
  local camp_id = player:get_atb(bo2.eAtb_Camp)
  local _camp_list
  if camp_id == bo2.eCamp_Blade then
    _camp_list = {
      camp = ui.get_text("cross_line|camp_blade")
    }
  else
    _camp_list = {
      camp = ui.get_text("cross_line|camp_sword")
    }
  end
  if _score_data.self_score == nil then
    _score_data.self_score = 0
  end
  if g_view_type ~= 0 then
    rb_score_desc.visible = false
    on_view_award()
    local mtf = {}
    mtf.score = g_history_score_data.total_score
    rb_total_score.text = ui_widget.merge_mtf(mtf, ui.get_text("cross_line|my_total_score"))
    rb_total_score.visible = true
    rb_my_rank.visible = false
    rb_my_rank0.visible = true
  else
    local _self_rank
    if _score_data.self_rank == nil or 0 >= _score_data.self_rank then
      _self_rank = {
        rank = ui.get_text("cross_line|no_rank")
      }
    else
      _self_rank = {
        rank = _score_data.self_rank
      }
    end
    rb_my_rank.text = ui_widget.merge_mtf(_self_rank, ui.get_text("cross_line|my_rank"))
    rb_my_rank.visible = true
    rb_my_rank0.visible = false
    rb_score_desc.visible = true
    rb_total_score.visible = false
    on_view_battle_time()
  end
  local os_time = ui_main.get_os_time()
  local time_data = {}
  local week = tonumber(os.date("%w", os_time))
  local cd_type = get_cd_type(week, g_view_type)
  local cd = g_camp_ghost_cd[cd_type]
  if bo2.IsCoolDownOver(cd) ~= true then
    _camp_list.camp = ui.get_text("cross_line|camp_sword")
  end
  rb_my_camp.mtf = ui_widget.merge_mtf(_camp_list, ui.get_text("cross_line|my_camp"))
  rb_my_contri.text = ui_widget.merge_mtf({
    contri = _score_data.self_score
  }, ui.get_text("cross_line|my_contri"))
end
function update_UI()
  update_score_data()
  update_step()
  update_self_data()
  ui_camp_repute.update_ui()
end
function on_init_score_data()
end
function view_all_score()
  local v_data = sys.variant()
  v_data[packet.key.CrossLineClientPacket_RequestType] = 0
  local function send_view(_score_data)
    v_data[packet.key.cmn_price] = _score_data.self_score
    v_data[packet.key.CrossLineClientPacket_RequestID] = _score_data.request_id
    bo2.send_variant(packet.eCTS_UI_RequestCrossLineData, v_data)
  end
  send_view(g_score_data)
  v_data[packet.key.CrossLineClientPacket_RequestType] = 1
  send_view(g_history_score_data)
  update_UI()
end
function view_score(vis)
  if vis then
    local view_panel = false
    if g_view_type ~= 0 then
      view_panel = true
    else
      g_timer_second.suspended = false
    end
    view_history_panel(view_panel)
    local lb_title = ui_cross_line.w_main_score:search("lb_title")
    if sys.check(lb_title) then
      local text = ui.get_text("cross_line|score_title")
      if g_view_type ~= 0 then
        text = ui.get_text("cross_line|score_title_yesterday")
      end
      lb_title.text = text
    end
    local v_data = sys.variant()
    v_data[packet.key.CrossLineClientPacket_RequestType] = g_view_type
    local _score_data = g_score_data
    if g_view_type ~= 0 then
      _score_data = g_history_score_data
    end
    v_data[packet.key.cmn_price] = _score_data.self_score
    v_data[packet.key.CrossLineClientPacket_RequestID] = _score_data.request_id
    bo2.send_variant(packet.eCTS_UI_RequestCrossLineData, v_data)
    update_UI()
  elseif g_view_type == 0 then
    g_timer_second.suspended = false
  end
end
function on_esc_stk_visible_score(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  view_score(vis)
end
function view_history_panel(vis)
  ui_cross_line.p_award.visible = vis
  ui_cross_line.p_view_history.visible = not vis
end
function _runf()
  if g_view_type ~= 0 then
    w_main_score.visible = false
  end
  g_view_type = 0
  w_main_score.visible = true
  if sys.check(ui_net_delay.w_flicker_cross_line) then
    ui_net_delay.w_flicker_cross_line.suspended = true
    ui_net_delay.btn_cross_line.tip.text = ui.get_text("qbar|cross_line_tips")
  end
end
function runf_yesterday()
  if g_view_type ~= 1 then
    w_main_score.visible = false
  end
  g_view_type = 1
  w_main_score.visible = true
end
function on_click_receive_award()
  runf_yesterday()
end
function on_click_rank_award()
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_RequestCrossLineAward, v)
end
function on_click_contribute_award()
  local v = sys.variant()
  v[packet.key.fate_current_stage] = 1
  bo2.send_variant(packet.eCTS_UI_RequestCrossLineAward, v)
end
function on_click_camp_award()
  local v = sys.variant()
  v[packet.key.fate_rank_award] = 1
  bo2.send_variant(packet.eCTS_UI_RequestCrossLineAward, v)
end
function on_timer_modify_text()
  local rst = on_view_battle_time()
  if rst ~= true then
    g_timer_second.suspended = true
  end
end
function on_view_battle_time()
  if g_view_type ~= 0 then
    return false
  end
  if ui_cross_line.w_main_score.visible ~= true then
    return false
  end
  local os_time = ui_main.get_os_time()
  local mtf_data = get_battle_time_text(os_time)
  if mtf_data == nil or mtf_data.status == nil then
    return false
  end
  rb_status.mtf = sys.format(L("%s%s"), ui.get_text("cross_line|status"), mtf_data.status)
  rb_status.dy = mtf_data.status_dy
  btn_trans.visible = mtf_data.btn_trans_vis
  btn_join_battle.visible = mtf_data.btn_join_vis
  rb_battle_time.mtf = mtf_data.time
  if mtf_data.award_time ~= nil then
    rb_award_time.mtf = mtf_data.award_time
    rb_award_time.visible = true
  else
    rb_award_time.visible = false
  end
  return true
end
function on_view_award()
  for i = 0, 3 do
    local itemName = sys.format("award%d", i)
    local itemCard = rb_award_items:search(itemName)
    if sys.check(itemCard) then
      local _item = itemCard:search("item")
      if sys.check(_item) then
        _item.excel_id = 0
      end
      local itemCount = itemCard:search("num")
      if sys.check(itemCount) then
        itemCount.text = L("")
      end
    end
  end
  rb_cd_time.mtf = L("")
  rb_award_items.visible = true
  rb_cd_time.margin = ui.rect(0, 25, 150, 0)
  rb_award_range.margin = ui.rect(0, 2, 150, 0)
end
function get_next_time_data(os_time)
  local time_data = {}
  time_data.week = tonumber(os.date("%w", os_time))
  time_data.day = get_next_day(time_data.week)
  local hour = tonumber(os.date("%H", os_time))
  time_data.hour = get_full_time(23 - hour)
  local minute = tonumber(os.date("%M", os_time))
  time_data.minute = get_full_time(60 - minute)
  return time_data
end
function refresh_time_mtf(type)
  local os_time = ui_main.get_os_time()
  local time_data = get_next_time_data(os_time)
  local week = time_data.week
  local cd = get_cd_index(week, type)
  if bo2.IsCoolDownOver(cd) then
    rb_cd_time.mtf = ui_widget.merge_mtf(time_data, ui.get_text("cross_line|award_time"))
  else
    rb_cd_time.mtf = ui_widget.merge_mtf(time_data, ui.get_text("cross_line|next_award_time"))
  end
end
function on_refresh_camp_award()
  local _score_data = g_score_data
  if g_view_type ~= 0 then
    _score_data = g_history_score_data
  end
  refresh_time_mtf(1)
  rb_award_range.mtf = ui.get_text("cross_line|camp_win_award")
  local excel = find_camp_award(1)
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
      local itemCard = rb_award_items:search(itemName)
      if sys.check(itemCard) then
        local _item = itemCard:search("item")
        if sys.check(_item) then
          _item.excel_id = itemExcelId
        end
        local itemCount = itemCard:search("num")
        if sys.check(itemCount) then
          itemCount.text = sys.format(L("x%d"), _self_award.v_count[i])
        end
      end
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
    end
    return _mtf_data
  end
  local rank_range_mtf
  if _score_data.self_rank == nil or _score_data.self_rank <= 0 then
    _self_rank = {
      rank = ui.get_text("cross_line|no_rank")
    }
    local iSize = get_size_rank_award()
    if iSize ~= nil and iSize > 0 then
      local pExcelAward = get_rank_award(iSize - 1)
      _self_award = modify_rank_data(pExcelAward)
      rank_range_mtf = ui_widget.merge_mtf(_self_award, ui.get_text("cross_line|overlap_range"))
    end
  else
    _self_rank = {
      rank = _score_data.self_rank
    }
    local iSize = get_size_rank_award()
    local bFound = false
    for i = 0, iSize - 1 do
      local pExcelAward = get_rank_award(i)
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
    else
      rank_range_mtf = ui_widget.merge_mtf(_self_award, ui.get_text("cross_line|award_range"))
    end
  end
  return _self_rank, _self_award, rank_range_mtf
end
function on_refresh_rank_award()
  local _score_data = g_score_data
  if g_view_type ~= 0 then
    _score_data = g_history_score_data
  end
  refresh_time_mtf(0)
  local _self_rank = {}
  local _self_award = {}
  local rank_range_mtf
  _self_rank, _self_award, rank_range_mtf = refresh_award_by_rank(_score_data)
  rb_my_rank0.text = ui_widget.merge_mtf(_self_rank, ui.get_text("cross_line|my_rank"))
  rb_my_rank.visible = false
  rb_my_rank0.visible = true
  rb_award_range.mtf = sys.format(L("<a:r>%s"), rank_range_mtf)
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
end
function on_refresh_score_award()
  local _score_data = g_score_data
  if g_view_type ~= 0 then
    _score_data = g_history_score_data
  end
  rb_award_items.visible = false
  refresh_time_mtf(2)
  if _score_data.total_score == nil then
    _score_data.total_score = 0
  end
  local excel_current, excel_next = get_score_award_excel(_score_data.total_score)
  if excel_current == nil then
    rb_award_range.mtf = sys.format(L("<a:r><c:979797>%s"), sys.format(ui.get_text("cross_line|none_total")))
  else
    local stk = sys.mtf_stack()
    stk:raw_push(L("<a:r><c:FFFFFF>"))
    local mtf_data = {}
    if 0 < excel_current.score_end then
      mtf_data.begin0 = excel_current.score_begin
      mtf_data.end0 = excel_current.score_end
      title_text = ui_widget.merge_mtf(mtf_data, sys.format(ui.get_text("cross_line|total_contri_bd")))
    else
      mtf_data.begin0 = excel_current.score_begin
      title_text = ui_widget.merge_mtf(mtf_data, sys.format(ui.get_text("cross_line|total_contri_max")))
    end
    stk:raw_push(title_text)
    stk:raw_push(ui.get_text("cross_line|total_award"))
    stk:raw_push(sys.format(L("<m:%d>"), excel_current.award_money))
    rb_award_range.mtf = stk.text
  end
end
function view_mutex_award_by_type(type)
  if g_view_award_type ~= type then
    g_view_award_type = type
    on_view_award()
  end
end
function on_mouse_view_contribute_award(w, msg)
  if msg == ui.mouse_inner then
    view_mutex_award_by_type(2)
  end
end
function on_mouse_view_camp_award(w, msg)
  if msg == ui.mouse_inner then
    view_mutex_award_by_type(1)
  end
end
function on_mouse_view_rank_award(w, msg)
  if msg == ui.mouse_inner then
    view_mutex_award_by_type(0)
  end
end
function on_click_return()
  _runf()
end
function on_handle_request_data_rst(cmd, data)
  local view_type = data[packet.key.CrossLineClientPacket_RequestType]
  local _score_data = g_score_data
  if view_type ~= 0 then
    _score_data = g_history_score_data
  end
  local function on_fill_page_data(type, vData)
    _score_data.request_page[type] = vData:get(packet.key.request_page).v_int
    local vRankData = vData:get(packet.key.cmn_dataobj)
    local iRankIndex = 1
    local iMaxRankIndex = n_page_limit
    if data:has(packet.key.mall_page_cur) then
      local iCurrentPage = data:get(packet.key.mall_page_cur).v_int
      iRankIndex = iRankIndex + (iCurrentPage - 1) * n_page_limit
      iMaxRankIndex = iRankIndex + iCurrentPage * n_page_limit
    end
    local modify_rank = _score_data.rank[type]
    if vRankData.empty then
      for i = iRankIndex, iMaxRankIndex do
        modify_rank[i] = nil
      end
    else
      for i = iRankIndex, iRankIndex + 6 do
        modify_rank[i] = nil
      end
      for i, key, value in vpairs(vRankData) do
        modify_rank[iRankIndex] = {}
        modify_rank[iRankIndex].name = value:get(packet.key.cha_name).v_string
        modify_rank[iRankIndex].score = value[packet.key.battle_kill_count]
        iRankIndex = iRankIndex + 1
      end
    end
  end
  local update_blade = false
  local update_sword = false
  if data:has(packet.key.Sociality_CrossLineScore_Blade) then
    local vData = data:get(packet.key.Sociality_CrossLineScore_Blade)
    on_fill_page_data(bo2.eCamp_Blade, vData)
    update_blade = true
  end
  if data:has(packet.key.Sociality_CrossLineScore_Sword) then
    local vData = data:get(packet.key.Sociality_CrossLineScore_Sword)
    on_fill_page_data(bo2.eCamp_Sword, vData)
    update_sword = true
  end
  if data:has(packet.key.Sociality_CrossLineYesterdayScore_Blade) then
    local vData = data:get(packet.key.Sociality_CrossLineYesterdayScore_Blade)
    on_fill_page_data(bo2.eCamp_Blade, vData)
    update_sword = true
  end
  if data:has(packet.key.Sociality_CrossLineYesterdayScore_Sword) then
    local vData = data:get(packet.key.Sociality_CrossLineYesterdayScore_Sword)
    on_fill_page_data(bo2.eCamp_Sword, vData)
    update_sword = true
  end
  if data:has(packet.key.mall_page_cur) then
    if update_blade ~= false then
      update_page(page_blade)
    end
    if update_sword ~= false then
      update_page(page_sword)
    end
    return
  end
  _score_data.request_id = data[packet.key.CrossLineClientPacket_RequestID]
  _score_data.blade_score = data[packet.key.CrossLineRSTPacket_BladeScore]
  _score_data.sword_score = data[packet.key.CrossLineRSTPacket_SwordScore]
  _score_data.self_rank = data[packet.key.ranklist_id]
  _score_data.self_score = data[packet.key.cmn_exp]
  if data:has(packet.key.fate_score) then
    _score_data.self_rank_data = data:get(packet.key.fate_score)
    local total_score = 0
    local sort_tab = sys.variant()
    for i = 0, _score_data.self_rank_data.size - 1 do
      local n, data = _score_data.self_rank_data:fetch_nv(i)
      local v_data = sys.variant()
      v_data[packet.key.cmn_type] = n
      v_data[packet.key.gs_score] = data
      total_score = total_score + data.v_int
      sort_tab:push_back(v_data)
    end
    local sort_fun = function(left, right)
      if left[packet.key.gs_score] > right[packet.key.gs_score] then
        return true
      end
      return false
    end
    sort_tab:sort(sort_fun)
    _score_data.sort_tab = sort_tab
    _score_data.total_score = total_score
  end
  update_UI()
end
function on_get_battle_popo(data)
  g_cross_line_popo_data = {}
  g_cross_line_popo_data.data = data
  g_cross_line_popo_data.time = ui_main.get_os_time() + 120
end
function on_click_join_battle()
  if bo2.IsCoolDownOver(30046) then
    local v_data = sys.variant()
    v_data[packet.key.misc_begin] = 1
    bo2.send_variant(packet.eCTS_UI_RequestCrossLineData, v_data)
  else
    btn_join_battle.visible = false
  end
end
function on_click_trans(btn)
  if g_cross_line_popo_data ~= nil and g_cross_line_popo_data.data ~= nil then
    ui_popo.ask_cross_line_battle_trans("yes", g_cross_line_popo_data.data)
  else
    btn.visible = false
  end
end
function on_cross_line_battle_pop(vis)
  if vis ~= true then
    g_cross_line_popo_data = nil
  end
end
function on_handle_cooldown_token(cmd, data)
  local iExcelId = data:get(packet.key.cooldown_id).v_int
  local function found_cd(_tab)
    for i, v in pairs(_tab) do
      if v == iExcelId then
        on_view_award()
        return
      end
    end
  end
  found_cd(g_camp_cd)
  found_cd(g_rank_cd)
end
local sig_name = "ui_cross_line:on_handle_request_data_rst"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Sociality_CrossLineResquestDataRST, on_handle_request_data_rst, sig_name)
sig_name = "ui_cross_line:on_signal_cooldown_token"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_AddCooldown, on_handle_cooldown_token, sig_name)
function set_flicker()
  ui_net_delay.w_flicker_cross_line.suspended = false
  ui_net_delay.btn_cross_line.tip.text = ui.get_text("cross_line|cross_line_tips")
end
function on_self_enter()
  local obj_level = ui.safe_get_atb(bo2.eAtb_Level)
  if obj_level < 30 then
    return
  end
  if bo2.IsCoolDownOver(30135) ~= true then
    return
  end
  set_flicker()
  local clear_score_request_id = function()
    g_score_data.request_id = 0
    g_history_score_data.request_id = 0
  end
  clear_score_request_id()
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_cross_line.on_self_enter")
