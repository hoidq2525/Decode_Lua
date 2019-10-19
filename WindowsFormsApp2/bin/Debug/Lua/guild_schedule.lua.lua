local reg = ui_packet.game_recv_signal_insert
local sig = "ui_org.packet_handle"
local cur_week = 1
local select_day
local week_info = {
  [1] = {},
  [2] = {},
  [3] = {}
}
local tree_root_name = {
  ui.get_text("org|tip_cmn26"),
  ui.get_text("org|tip_cmn27"),
  ui.get_text("org|tip_cmn28")
}
local tree_root_panel = {}
local cur_quest_item
local days_items = {}
local chgweek_btn = {}
local book_count = {
  [1] = {},
  [2] = {},
  [3] = {}
}
local cur_time_idx = -1
local cur_event_id = 0
function get_day_begin()
  local m = os.date("*t", os.time())
  m.hour = 0
  m.min = 0
  m.sec = 0
  return os.time(m)
end
function get_day_end()
  local m = os.date("*t", os.time())
  m.hour = 23
  m.min = 59
  m.sec = 59
  return os.time(m)
end
function get_week_begin(day)
  local m
  if day ~= nil then
    m = os.date("*t", day)
  else
    m = os.date("*t", os.time())
  end
  m.hour = 0
  m.min = 0
  m.sec = 0
  local r = os.time(m)
  local del = 0
  if m.wday == 1 then
    r = r - 518400
  else
    r = r - 86400 * (m.wday - 2)
  end
  return r
end
function get_week_end(day)
  local m
  if day ~= nil then
    m = os.date("*t", day)
  else
    m = os.date("*t", os.time())
  end
  m.hour = 23
  m.min = 59
  m.sec = 59
  local r = os.time(m)
  if m.wday ~= 1 then
    r = r + 86400 * (7 - m.wday)
  end
  return r
end
function get_tar_time(tar)
  local m = os.date("*t", os.time())
  m.hour = math.floor(tar / 3600)
  m.min = math.mod(tar, 3600)
  return os.date("%H:%M", os.time(m))
end
function on_make_quest_tip(tip)
  local panel = tip.owner
  if panel:search("lb_text").text ~= "" then
    tip.text = panel:search("lb_text").text
    ui_widget.tip_make_view(tip.view, tip.text)
  end
end
function on_make_tip(tip)
  local panel = tip.owner
  local select_day = panel:search("day_btn")
  local m = os.date("*t", select_day.svar.reserve_time)
  local book_time = select_day.svar.book_time
  m.hour = math.floor(book_time / 3600)
  m.min = math.mod(book_time, 3600)
  local time_begin = os.date("%Y/%m/%d", os.time(m))
  local line = bo2.gv_guild_schedule:find(select_day.svar.event_id)
  if line == nil then
    tip.text = sys.format("%s", time_begin)
  else
    tip.text = sys.format([[
%s
%s]], line.name, time_begin)
  end
  ui_widget.tip_make_view(tip.view, tip.text)
end
function update_btn_book_inner()
  if cur_time_idx == -1 then
    return
  end
  if cur_event_id == 0 then
    return
  end
  local line = bo2.gv_guild_schedule:find(cur_event_id)
  if book_count[cur_week][line.id] >= line.count then
    return
  end
  if cur_quest_item.svar.book_level == false then
    return
  end
  gx_btn_book_inner.enable = true
end
function on_event_list_select(item)
  cur_time_idx = item.id
  update_btn_book_inner()
end
function on_book_init()
  for i = 1, #tree_root_name do
    local toggle_node = ui_widget.ui_tree2.insert(w_book_tree.root)
    ui_widget.ui_tree2.set_text(toggle_node, tree_root_name[i])
    tree_root_panel[i] = toggle_node
  end
  for i = 0, bo2.gv_guild_schedule.size - 1 do
    local line = bo2.gv_guild_schedule:get(i)
    if tree_root_panel[line.type] ~= nil then
      book_count[1][line.id] = 0
      book_count[2][line.id] = 0
      book_count[3][line.id] = 0
      local leaf_node = ui_widget.ui_tree2.insert(tree_root_panel[line.type])
      leaf_node.expanded = false
      leaf_node.title:search("lb_text").text = line.name
      leaf_node.svar.id = line.id
    end
  end
  w_time_list.svar.on_select = on_event_list_select
end
function on_item_leaf_sel(item, sel)
  ui_widget.ui_tree2.on_leaf_sel(item, sel)
  local vis = item.selected or item.inner_hover
  local fig = item.title:search("fig_highlight_sel")
  fig.visible = vis
  if vis == true then
    gx_btn_book_inner.enable = false
    local line = bo2.gv_guild_schedule:find(item.svar.id)
    cur_event_id = line.id
    if line ~= nil then
      local money = sys.format("<m:%d>", line.money)
      local item = ui.get_text("org|null")
      if line.items[0] ~= 0 and line.items[1] ~= 0 then
        item = sys.format("<i:%d>x%d", line.items[0], line.items[1])
      end
      local desc = sys.format(ui.get_text("org|schedule_desc2"), line.name, line.count, book_count[cur_week][line.id], tree_root_name[line.type], money, line.develop, item, line.time / 3600, line.desc)
      gx_schedule_des2.mtf = desc
    end
    cur_quest_item = item
    ui_widget.ui_combo_box.clear(w_time_list)
    local line = bo2.gv_guild_schedule:find(cur_quest_item.svar.id)
    for i = 0, line.book_time.size - 1 do
      local m = os.date("*t", os.time())
      local book_time = line.book_time[i]
      m.hour = math.floor(book_time / 3600)
      m.min = math.mod(book_time, 3600)
      local time_text = os.date("%H:%M", os.time(m))
      ui_widget.ui_combo_box.append(w_time_list, {id = i, text = time_text})
    end
    ui_widget.ui_combo_box.select(w_time_list, 0)
    cur_time_idx = 0
    update_btn_book_inner()
    gx_schedule_book_win:search("slider_y_inner").scroll = 0
  end
end
function on_leaf_title_mouse(title, msg)
  local item = title.item
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    ui_widget.ui_tree2.update_leaf_highlight(item)
  end
end
function on_schedule_init()
  chgweek_btn = {
    gx_btn_chgweek1,
    gx_btn_chgweek2,
    gx_btn_chgweek3
  }
  days_items = {
    gx_day1,
    gx_day2,
    gx_day3,
    gx_day4,
    gx_day5,
    gx_day6,
    gx_day7
  }
end
function update_day(btn, update)
  if select_day == btn and update == nil then
    return
  end
  if sys.check(select_day) == true then
    local old_panel = select_day.parent
    old_panel:search("day_select").visible = false
  end
  local panel = btn.parent
  panel:search("day_select").visible = true
  select_day = btn
  gx_btn_book.enable = true
  gx_btn_book.text = ui.get_text("org|schedule_btn_book")
  gx_btn_book.svar.state = bo2.eScheduleRequest_Book
  if select_day.svar.state == bo2.eScheduleState_End then
    gx_btn_book.enable = false
  end
  if select_day.svar.event_id == 0 then
    gx_schedule_des.mtf = ""
    return
  end
  local line = bo2.gv_guild_schedule:find(select_day.svar.event_id)
  local money = sys.format("<m:%d>", line.money)
  local item = ui.get_text("org|null")
  if line.items[0] ~= 0 and line.items[1] ~= 0 then
    item = sys.format("<i:%d>x%d", line.items[0], line.items[1])
  end
  local m = os.date("*t", select_day.svar.reserve_time)
  local book_time = select_day.svar.book_time
  m.hour = math.floor(book_time / 3600)
  m.min = math.mod(book_time, 3600)
  local time_begin = os.date("%Y/%m/%d %H:%M", os.time(m))
  book_time = select_day.svar.book_time + bo2.gv_define_org:find(56).value.v_int
  m.hour = math.floor(book_time / 3600)
  m.min = math.mod(book_time, 3600)
  local time_end = os.date("%Y/%m/%d %H:%M", os.time(m))
  m.hour = math.floor(line.time / 3600)
  m.min = math.mod(line.time, 3600)
  local time_long = os.date("%H:%M", os.time(m))
  local desc = sys.format(ui.get_text("org|schedule_desc"), line.name, tree_root_name[line.type], time_begin, time_end, time_long, line.count, book_count[cur_week][line.id], money, line.develop, item, line.desc)
  gx_schedule_des.mtf = desc
  gx_schedule_win:search("slider_y").scroll = 0
  if select_day.svar.state == bo2.eScheduleState_Execute then
    gx_btn_book.text = ui.get_text("org|schedule_btn_start")
    gx_btn_book.svar.state = bo2.eScheduleRequest_Start
  elseif select_day.svar.state == bo2.eScheduleState_Book then
    gx_btn_book.text = ui.get_text("org|schedule_btn_cancel")
    gx_btn_book.svar.state = bo2.eScheduleRequest_Cancel
    if select_day.svar.reserve_time < get_day_end() then
      gx_btn_book.enable = false
    end
  elseif select_day.svar.state ~= bo2.eScheduleState_None then
    gx_btn_book.enable = false
  end
end
function day_on_click(btn)
  update_day(btn)
end
function on_book_click(btn)
  if sys.check(select_day) == false then
    return
  end
  if gx_btn_book.svar.state == bo2.eScheduleRequest_Book then
    gx_schedule_book_win.visible = true
  elseif gx_btn_book.svar.state == bo2.eScheduleRequest_Start then
    local v = sys.variant()
    v:set(packet.key.cmn_requestid, gx_btn_book.svar.state)
    v:set(packet.key.cmn_id, select_day.svar.id)
    bo2.send_variant(packet.eCTS_Guild_SetSchedule, v)
  elseif gx_btn_book.svar.state == bo2.eScheduleRequest_Cancel then
    local line = bo2.gv_guild_schedule:find(select_day.svar.event_id)
    local money = sys.format("<m:%d>", line.money)
    local item = ui.get_text("org|null")
    if line.items[0] ~= 0 and line.items[1] ~= 0 then
      item = sys.format("<i:%d>x%d", line.items[0], line.items[1])
    end
    local m = os.date("*t", select_day.svar.reserve_time)
    local book_time = select_day.svar.book_time
    m.hour = math.floor(book_time / 3600)
    m.min = math.mod(book_time, 3600)
    local time_begin = os.date("%Y/%m/%d %H:%M", os.time(m))
    book_time = select_day.svar.book_time + line.time
    m.hour = math.floor(book_time / 3600)
    m.min = math.mod(book_time, 3600)
    local time_end = os.date("%Y/%m/%d %H:%M", os.time(m))
    m.hour = math.floor(line.time / 3600)
    m.min = math.mod(line.time, 3600)
    local time_long = os.date("%H:%M", os.time(m))
    local desc = sys.format(ui.get_text("org|schedule_book_cancel_tip"), line.name, tree_root_name[line.type], time_begin, time_end, time_long, line.count, book_count[cur_week][line.id], money, line.develop, item, line.desc)
    local msg = {
      text = desc,
      modal = true,
      btn_confirm = 1,
      btn_cancel = 1,
      callback = function(data)
        if data.result == 1 then
          local v = sys.variant()
          v:set(packet.key.cmn_requestid, gx_btn_book.svar.state)
          v:set(packet.key.cmn_id, select_day.svar.id)
          bo2.send_variant(packet.eCTS_Guild_SetSchedule, v)
        end
      end
    }
    ui_widget.ui_msg_box.show_common(msg)
  end
end
function on_book_click_inner(btn)
  local line = bo2.gv_guild_schedule:find(cur_event_id)
  local money = sys.format("<m:%d>", line.money)
  local item = ui.get_text("org|null")
  if line.items[0] ~= 0 and line.items[1] ~= 0 then
    item = sys.format("<i:%d>x%d", line.items[0], line.items[1])
  end
  local m = os.date("*t", select_day.svar.reserve_time)
  local book_time = line.book_time[cur_time_idx]
  m.hour = math.floor(book_time / 3600)
  m.min = math.mod(book_time, 3600)
  local time_begin = os.date("%Y/%m/%d %H:%M", os.time(m))
  book_time = book_time + line.time
  m.hour = math.floor(book_time / 3600)
  m.min = math.mod(book_time, 3600)
  local time_end = os.date("%Y/%m/%d %H:%M", os.time(m))
  m.hour = math.floor(line.time / 3600)
  m.min = math.mod(line.time, 3600)
  local time_long = os.date("%H:%M", os.time(m))
  local desc = sys.format(ui.get_text("org|schedule_book_tip"), line.name, tree_root_name[line.type], time_begin, time_end, time_long, line.count, book_count[cur_week][line.id], money, line.develop, item, line.desc)
  local msg = {
    text = desc,
    modal = true,
    btn_confirm = 1,
    btn_cancel = 1,
    callback = function(data)
      if data.result == 1 then
        local v = sys.variant()
        v:set(packet.key.cmn_requestid, gx_btn_book.svar.state)
        v:set(packet.key.cmn_id, select_day.svar.id)
        v:set(packet.key.quest_id, cur_event_id)
        v:set(packet.key.guild_schedule_booktime, cur_time_idx)
        bo2.send_variant(packet.eCTS_Guild_SetSchedule, v)
      end
    end
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function SetWeekInfo(info)
  if sys.check(select_day) == true then
    local old_panel = select_day.parent
    old_panel:search("day_select").visible = false
    select_day = nil
  end
  gx_btn_book.enable = false
  local daybegin = get_day_begin()
  local dayend = get_day_end()
  for i, v in pairs(info) do
    local panel = days_items[i]
    local image_uri = sys.format("$image/guild/number/normal%d.png|6,4,90,103", i)
    if v.state == bo2.eScheduleState_End then
      image_uri = sys.format("$image/guild/number/%s%d.png|6,4,90,103", "timeout", i)
    end
    panel:search("day_image").image = SHARED(image_uri)
    local state1_uri = "$image/guild/schedule/state.png|30,0,30,30"
    local state2_uri = "$image/guild/schedule/state.png|0,60,72,30"
    local day_time = "--:--"
    if v.book_time ~= 0 then
      day_time = get_tar_time(v.book_time)
    end
    if v.state == bo2.eScheduleState_None then
      state1_uri = "$image/guild/schedule/state.png|30,0,30,30"
      state2_uri = "$image/guild/schedule/state.png|0,60,72,30"
    elseif v.state == bo2.eScheduleState_Book then
      if dayend < v.reserve_time then
        state1_uri = "$image/guild/schedule/state.png|60,0,30,30"
        state2_uri = "$image/guild/schedule/state.png|0,90,72,30"
      else
        state1_uri = "$image/guild/schedule/state.png|0,0,30,30"
        state2_uri = "$image/guild/schedule/state.png|0,30,72,30"
      end
    elseif v.state == bo2.eScheduleState_Execute then
      state1_uri = "$image/guild/schedule/state.png|150,0,30,30"
      state2_uri = "$image/guild/schedule/state.png|76,30,72,30"
    elseif v.state == bo2.eScheduleState_Done then
      state1_uri = "$image/guild/schedule/state.png|180,0,30,30"
      state2_uri = "$image/guild/schedule/state.png|76,60,72,30"
    elseif v.state == bo2.eScheduleState_End then
      state1_uri = "$image/guild/schedule/state.png|120,0,30,30"
      state2_uri = "$image/guild/schedule/state.png|0,158,72,30"
    end
    panel:search("day_state1").image = SHARED(state1_uri)
    panel:search("day_state2").image = SHARED(state2_uri)
    panel:search("day_time").text = day_time
    panel:search("day_btn").svar = v
  end
  local week_begin = get_week_begin(info[1].reserve_time)
  local week_end = get_week_end(info[1].reserve_time)
  local day_title = sys.format(ui.get_text("org|schedule_day_title"), os.date("%Y/%m/%d", week_begin), os.date("%Y/%m/%d", week_end))
  gx_day_title.mtf = day_title
end
function on_chgweek_click(btn)
  local week = 1
  if btn == gx_btn_chgweek1 then
    week = 1
  elseif btn == gx_btn_chgweek2 then
    week = 2
  else
    week = 3
  end
  if week == cur_week then
    return
  end
  cur_week = week
  SetWeekInfo(week_info[cur_week])
end
function SetDayInfo(data)
  local day = {
    id = data:get(packet.key.cmn_id).v_string,
    reserve_time = data:get(packet.key.guild_schedule_reservetime).v_int,
    book_time = data:get(packet.key.guild_schedule_booktime).v_int,
    state = data:get(packet.key.cmn_state).v_int,
    event_type = data:get(packet.key.cmn_type).v_int,
    event_id = data:get(packet.key.quest_id).v_int,
    target_id = data:get(packet.key.org_id).v_string
  }
  return day
end
function on_book_visible(panel, vis)
  g_guild_money.money = ui.guild_get_money()
  g_guild_develop.text = tostring(ui.guild_get_develop())
  local text = os.date("%y/%m/%d", select_day.svar.reserve_time)
  gx_schedule_book_win:search("book_title").text = sys.format(ui.get_text("org|schedule_book_title"), text)
  ui_widget.ui_combo_box.clear(w_time_list)
  w_book_tree:clear_selection()
  gx_btn_book_inner.enable = false
  for i = 1, #tree_root_name do
    local delitem = {}
    local toggle_node = tree_root_panel[i]
    for j = 0, toggle_node.item_count - 1 do
      local item = toggle_node:item_get(j)
      local line = bo2.gv_guild_schedule:find(item.svar.id)
      if line.count == book_count[cur_week][line.id] then
        item.title:search("lb_text").color = ui.make_color("ff808080")
      else
        item.title:search("lb_text").color = ui.make_color("ffffffff")
      end
      item.svar.book_level = true
      local visible_level = line.visible_level
      for k = 0, visible_level.size - 1, 2 do
        local build = ui.guild_get_build(visible_level[k])
        if build.level < visible_level[k + 1] then
          table.insert(delitem, j)
          break
        end
      end
      local book_level = line.book_level
      for k = 0, book_level.size - 1, 2 do
        local build = ui.guild_get_build(book_level[k])
        if build.level < book_level[k + 1] then
          item.title:search("lb_text").color = ui.make_color("ff808080")
          item.svar.book_level = false
          break
        end
      end
    end
    for m = 1, #delitem do
      toggle_node:item_remove(delitem[m])
    end
  end
end
function on_book_win_close()
  gx_schedule_book_win.visible = false
end
function init_data(data)
  week_info = {
    [1] = {},
    [2] = {},
    [3] = {}
  }
  cur_week = 1
  if sys.check(select_day) == true then
    local old_panel = select_day.parent
    old_panel:search("day_select").visible = false
    select_day = nil
  end
  gx_btn_book.enable = false
  book_count = {
    [1] = {},
    [2] = {},
    [3] = {}
  }
  for i = 0, bo2.gv_guild_schedule.size - 1 do
    local line = bo2.gv_guild_schedule:get(i)
    if tree_root_panel[line.type] ~= nil then
      book_count[1][line.id] = 0
      book_count[2][line.id] = 0
      book_count[3][line.id] = 0
    end
  end
  cur_time_idx = 0
  local begin_day = get_day_begin()
  local end_day = get_day_end()
  for i = 0, data.size - 1 do
    local day = SetDayInfo(data:get(i))
    local week = math.ceil((i + 1) / 7)
    day.week = week
    if day.event_id ~= 0 then
      book_count[week][day.event_id] = book_count[week][day.event_id] + 1
    end
    table.insert(week_info[week], day)
    if cur_week ~= week and begin_day <= day.reserve_time and end_day >= day.reserve_time then
      cur_week = week
    end
  end
  local btn = chgweek_btn[cur_week]
  btn.check = true
  SetWeekInfo(week_info[cur_week])
  gx_schedule_win.visible = true
end
function update_item(data)
  gx_schedule_book_win.visible = false
  local daybegin = get_day_begin()
  local dayend = get_day_end()
  local v = SetDayInfo(data)
  local panel
  local idx = 1
  for _, week in pairs(week_info) do
    for i, dayinfo in pairs(week) do
      if dayinfo.id == v.id then
        panel = days_items[i]
        idx = i
      end
    end
  end
  local image_uri = sys.format("$image/guild/number/normal%d.png|6,4,90,103", idx)
  if v.state == bo2.eScheduleState_End then
    image_uri = sys.format("$image/guild/number/%s%d.png|6,4,90,103", "timeout", idx)
  end
  panel:search("day_image").image = SHARED(image_uri)
  local state1_uri = "$image/guild/schedule/state.png|30,0,30,30"
  local state2_uri = "$image/guild/schedule/state.png|0,60,72,30"
  local day_time = "--:--"
  if v.book_time ~= 0 then
    day_time = get_tar_time(v.book_time)
  end
  if v.state == bo2.eScheduleState_None then
    state1_uri = "$image/guild/schedule/state.png|30,0,30,30"
    state2_uri = "$image/guild/schedule/state.png|0,60,72,30"
  elseif v.state == bo2.eScheduleState_Book then
    if dayend < v.reserve_time then
      state1_uri = "$image/guild/schedule/state.png|60,0,30,30"
      state2_uri = "$image/guild/schedule/state.png|0,90,72,30"
    else
      state1_uri = "$image/guild/schedule/state.png|0,0,30,30"
      state2_uri = "$image/guild/schedule/state.png|0,30,72,30"
    end
  elseif v.state == bo2.eScheduleState_Execute then
    state1_uri = "$image/guild/schedule/state.png|150,0,30,30"
    state2_uri = "$image/guild/schedule/state.png|76,30,72,30"
  elseif v.state == bo2.eScheduleState_Done then
    state1_uri = "$image/guild/schedule/state.png|180,0,30,30"
    state2_uri = "$image/guild/schedule/state.png|76,60,72,30"
  elseif v.state == bo2.eScheduleState_End then
    state1_uri = "$image/guild/schedule/state.png|120,0,30,30"
    state2_uri = "$image/guild/schedule/state.png|0,158,72,30"
  end
  panel:search("day_state1").image = SHARED(state1_uri)
  panel:search("day_state2").image = SHARED(state2_uri)
  panel:search("day_time").text = day_time
  local src_svar = panel:search("day_btn").svar
  panel:search("day_btn").svar = v
  local day_btn = panel:search("day_btn")
  for i, day in pairs(week_info[cur_week]) do
    if day.id == v.id then
      week_info[cur_week][i] = v
      local update_type = data:get(packet.key.cmn_state).v_int
      if update_type == bo2.eScheduleRequest_Book then
        book_count[cur_week][v.event_id] = book_count[cur_week][v.event_id] + 1
        break
      end
      if update_type == bo2.eScheduleRequest_Cancel then
        book_count[cur_week][src_svar.event_id] = book_count[cur_week][src_svar.event_id] - 1
      end
      break
    end
  end
  day_btn.svar = v
  update_day(day_btn, true)
end
function BuildSchedule(cmd, data)
  if data:get(packet.key.cmn_system_flag).v_int == 1 then
    update_item(data)
  else
    init_data(data)
  end
  gx_schedule_win:move_to_head()
end
reg(packet.eSTC_Guild_Schedule, BuildSchedule, sig)
