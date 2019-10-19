local reg = ui_packet.game_recv_signal_insert
local sig = "ui_guild_mod.ui_schedule:on_signal"
local define_one_day = 86400
local cur_week = 1
local select_day
local week_info = {
  [1] = {},
  [2] = {},
  [3] = {}
}
local tree_root_name = {
  [1] = ui.get_text("guild|tip_cmn26"),
  [2] = ui.get_text("guild|tip_cmn27"),
  [3] = nil,
  [4] = ui.get_text("guild|guild_schedule_type_enemy")
}
local week_text = {
  [1] = ui.get_text("guild|guild_schedule_week_day1"),
  [2] = ui.get_text("guild|guild_schedule_week_day2"),
  [3] = ui.get_text("guild|guild_schedule_week_day3"),
  [4] = ui.get_text("guild|guild_schedule_week_day4"),
  [5] = ui.get_text("guild|guild_schedule_week_day5"),
  [6] = ui.get_text("guild|guild_schedule_week_day6"),
  [7] = ui.get_text("guild|guild_schedule_week_day7")
}
local days_items = {}
local chgweek_btn = {}
local book_count = {
  [1] = {},
  [2] = {},
  [3] = {}
}
local cur_time_idx = -1
local cur_event_id = -1
local cur_type_id = -1
local cur_guild_id = -1
local cur_guild_name = ""
local operate_state = false
local check_need_state = true
local STATE_IMAGE_NONE = SHARED("$image/guild/schedule/date.png|94,6,26,26")
local STATE_IMAGE_BOOK = SHARED("$image/guild/schedule/date.png|94,153,26,26")
local STATE_IMAGE_LOCK = SHARED("$image/guild/schedule/date.png|94,44,26,26")
local STATE_IMAGE_STAR = SHARED("$image/guild/schedule/date.png|94,76,26,26")
local STATE_IMAGE_RUN = SHARED("$image/guild/schedule/date.png|94,76,26,26")
local STATE_IMAGE_END = SHARED("$image/guild/schedule/date.png|95,115,26,26")
local STATE_TEXT_COLOR_NONE = SHARED("16bfe9")
local STATE_TEXT_COLOR_BOOK = SHARED("e6c114")
local STATE_TEXT_COLOR_LOCK = SHARED("ff3d1d")
local STATE_TEXT_COLOR_STAR = SHARED("82c016")
local STATE_TEXT_COLOR_RUN = SHARED("82c016")
local STATE_TEXT_COLOR_END = SHARED("d1d1d1")
local COLOR_RED = ui.make_color(SHARED("ff3d1d"))
local COLOR_WRITE = ui.make_color(SHARED("ffffff"))
function get_day_begin()
  local m = os.date("*t", ui_main.get_os_time())
  m.hour = 0
  m.min = 0
  m.sec = 0
  return os.time(m)
end
function get_day_end()
  local m = os.date("*t", ui_main.get_os_time())
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
    m = os.date("*t", ui_main.get_os_time())
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
    m = os.date("*t", ui_main.get_os_time())
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
  local m = os.date("*t", ui_main.get_os_time())
  m.hour = math.floor(tar / 3600)
  m.min = math.floor(math.fmod(tar, 3600) / 60)
  return os.date("%H:%M", os.time(m))
end
function get_week_day(t)
  local tar = os.date("*t", t)
  if tar.wday == 1 then
    return 7
  else
    return tar.wday - 1
  end
end
function get_week_count_from_curtime(tar)
  local cur_time = ui_main.get_os_time()
  local m = os.date("*t", cur_time)
  m.hour = 0
  m.min = 0
  m.sec = 0
  local t = os.date("*t", tar)
  t.hour = 0
  t.min = 0
  t.sec = 0
  local days = os.difftime(os.time(t), os.time(m)) / define_one_day
  days = days + get_week_day(cur_time)
  return math.floor(days / 7) + 1
end
function on_visible(p, v)
  if v == true then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_Guild_GetScheduleData, v)
    local cur_money = ui.guild_get_money()
    g_guild_money.color = ui.make_color("ffffff")
    local ctrl = g_follow:search("gx_guild_money")
    local label1 = ctrl:search("l_lable_left1")
    local label2 = ctrl:search("l_lable_left2")
    label1.visible = true
    label2.visible = false
    if cur_money < 0 then
      cur_money = -cur_money
      g_guild_money.color = ui.make_color("FF0000")
      label1.visible = false
      label2.visible = true
    end
    g_guild_money.money = cur_money
    g_guild_develop.text = ui.guild_get_develop()
    gx_btn_book.visible = false
    local self = ui.guild_get_self()
    if self == nil then
      return
    end
    local line = bo2.gv_guild_auth:find(self.guild_pos)
    if line ~= nil and line.schedule == 1 then
      gx_btn_book.visible = true
    end
  end
end
function SetDayInfo(data)
  local day = {
    id = data:get(packet.key.cmn_id).v_string,
    reserve_time = data:get(packet.key.guild_schedule_reservetime).v_int,
    book_time = data:get(packet.key.guild_schedule_booktime).v_int,
    state = data:get(packet.key.cmn_state).v_int,
    event_type = data:get(packet.key.cmn_type).v_int,
    event_id = data:get(packet.key.quest_id).v_int,
    target_name = data:get(packet.key.org_name).v_string
  }
  return day
end
function SetWeekInfo(info)
  if sys.check(select_day) == true then
    local old_panel = select_day.parent
    old_panel:search("date_select").visible = false
    select_day = nil
  end
  gx_btn_book.enable = false
  local daybegin = get_day_begin()
  local dayend = get_day_end()
  for i, v in pairs(info) do
    local panel = w_win:search("date_card_" .. i)
    local state_uri, text_color
    local text = ""
    if v.book_time ~= 0 then
      day_time = get_tar_time(v.book_time)
    end
    if v.state == bo2.eScheduleState_None then
      text = ui.get_text("guild|guild_schedule_state_none")
      state_uri = STATE_IMAGE_NONE
      text_color = STATE_TEXT_COLOR_NONE
    elseif v.state == bo2.eScheduleState_Book then
      if dayend < v.reserve_time then
        text = ui.get_text("guild|guild_schedule_state_book")
        state_uri = STATE_IMAGE_BOOK
        text_color = STATE_TEXT_COLOR_BOOK
      else
        text = ui.get_text("guild|guild_schedule_state_lock")
        state_uri = STATE_IMAGE_LOCK
        text_color = STATE_TEXT_COLOR_LOCK
      end
    elseif v.state == bo2.eScheduleState_Execute then
      text = ui.get_text("guild|guild_schedule_state_exe")
      state_uri = STATE_IMAGE_STAR
      text_color = STATE_TEXT_COLOR_STAR
    elseif v.state == bo2.eScheduleState_Done then
      text = ui.get_text("guild|guild_schedule_state_done")
      state_uri = STATE_IMAGE_RUN
      text_color = STATE_TEXT_COLOR_RUN
    elseif v.state == bo2.eScheduleState_End then
      text = ui.get_text("guild|guild_schedule_state_end")
      state_uri = STATE_IMAGE_END
      text_color = STATE_TEXT_COLOR_END
    end
    panel:search("state_pic").image = SHARED(state_uri)
    local state_text = panel:search("state_text")
    state_text.text = text
    state_text.color = ui.make_color(text_color)
    panel:search("day_btn").svar = v
    if v.event_type ~= 0 then
      panel:search("type_image").image = SHARED(sys.format("$image/guild/schedule_type/%d_1.png|14,13,40,40", v.event_type))
      panel:search("type_text").image = SHARED(sys.format("$image/guild/schedule_type/%d.png|14,13,40,40", v.event_type))
      panel:search("type_image").visible = true
      panel:search("type_text").visible = true
    else
      panel:search("type_image").visible = false
      panel:search("type_text").visible = false
    end
    local m = os.date("*t", v.reserve_time)
    panel:search("month_text").text = sys.format(ui.get_text("guild|guild_schedule_text_day"), m.year, m.month)
    panel:search("date_text").text = m.day
    panel:search("week_text").text = week_text[m.wday]
  end
  local week_begin = get_week_begin(info[1].reserve_time)
  local week_end = get_week_end(info[1].reserve_time)
  updata_step_btn()
  w_book_win.visible = false
  w_desc_win.visible = true
  gx_schedule_des.mtf = ""
  operate_state = false
end
function typelist_define()
  g_typelist:search("btn_drop_down").enable = true
  ui_widget.ui_combo_box.clear(g_typelist)
  for i = 1, 4 do
    if tree_root_name[i] ~= nil then
      ui_widget.ui_combo_box.append(g_typelist, {
        id = i,
        text = tree_root_name[i]
      })
    end
  end
  cur_type_id = 1
  if ui_widget.ui_combo_box.size(g_typelist) == 0 then
    g_typelist:search("btn_drop_down").enable = false
    return
  end
  ui_widget.ui_combo_box.select(g_typelist, cur_type_id)
end
function datalist_define()
  cur_event_id = -1
  g_datalist:search("btn_drop_down").enable = true
  ui_widget.ui_combo_box.clear(g_datalist)
  local tar_week = get_week_count_from_curtime(select_day.svar.reserve_time)
  local tar_day = get_week_day(select_day.svar.reserve_time)
  for i = 0, bo2.gv_guild_schedule.size - 1 do
    local line = bo2.gv_guild_schedule:get(i)
    if line.type == cur_type_id then
      local visible_level = true
      local visible_level_line = line.visible_level
      for k = 0, visible_level_line.size - 1, 3 do
        local build = ui.guild_get_build(visible_level_line[k])
        local iMin = visible_level_line[k + 1]
        local iMax = visible_level_line[k + 2]
        if iMin ~= 0 and iMin > build.level or iMax ~= 0 and iMax < build.level then
          visible_level = false
          break
        end
      end
      local visible_type = true
      local check_type = line.guild_type
      if check_type.size ~= 0 then
        visible_type = false
        local my_cult_type = ui.guild_cult_type()
        for k = 0, check_type.size - 1 do
          local t = check_type[k]
          if t == 0 and my_cult_type == 0 then
            visible_type = true
            break
          elseif t > 4 and my_cult_type == t - 4 then
            visible_type = true
            break
          end
        end
      end
      local visible_week = true
      local check_week = line.week
      if check_week.size ~= 0 then
        visible_week = false
        for k = 0, check_week.size - 1 do
          if check_week[k] == tar_week then
            visible_week = true
            break
          end
        end
      end
      local visible_day = true
      local check_day = line.day
      if check_day.size ~= 0 then
        visible_day = false
        for k = 0, check_day.size - 1 do
          if check_day[k] == tar_day then
            visible_day = true
            break
          end
        end
      end
      local visible_count = true
      if book_count[cur_week][line.group] >= line.count then
        visible_count = false
      end
      if visible_level and visible_type and visible_week and visible_day and visible_count then
        ui_widget.ui_combo_box.append(g_datalist, {
          id = line.id,
          text = line.name
        })
        if cur_event_id == -1 then
          cur_event_id = line.id
        end
      end
    end
  end
  if ui_widget.ui_combo_box.size(g_datalist) == 0 then
    g_datalist:search("btn_drop_down").enable = false
    return
  end
  ui_widget.ui_combo_box.select(g_datalist, cur_event_id)
end
function timelist_define()
  g_timelist:search("btn_drop_down").enable = true
  ui_widget.ui_combo_box.clear(g_timelist)
  local line = bo2.gv_guild_schedule:find(cur_event_id)
  if line ~= nil then
    for i = 0, line.book_time.size - 1 do
      local m = os.date("*t", os.time())
      local book_time = line.book_time[i]
      m.hour = math.floor(book_time / 3600)
      m.min = math.floor(math.fmod(book_time, 3600) / 60)
      local time_text = os.date("%H:%M", os.time(m))
      ui_widget.ui_combo_box.append(g_timelist, {id = i, text = time_text})
    end
  end
  if ui_widget.ui_combo_box.size(g_timelist) == 0 then
    g_timelist:search("btn_drop_down").enable = false
    return
  end
  cur_time_idx = 0
  ui_widget.ui_combo_box.select(g_timelist, cur_time_idx)
end
function guildlist_define()
  cur_guild_id = -1
  cur_guild_name = ""
  ui_widget.ui_combo_box.clear(g_guildlist)
  g_guildlist:search("btn_drop_down").enable = false
  local line = bo2.gv_guild_schedule:find(cur_event_id)
  local enemy_list = ui_guild_mod.ui_guild.enemy_list
  if line and line.type == 4 and #enemy_list ~= 0 then
    for i = 1, #enemy_list do
      local guild = enemy_list[i]
      ui_widget.ui_combo_box.append(g_guildlist, {
        id = i,
        text = guild.name,
        onlyid = guild.org_id
      })
      if cur_guild_id == -1 then
        cur_guild_id = guild.org_id
        cur_guild_name = guild.name
      end
    end
    ui_widget.ui_combo_box.select(g_guildlist, 1)
    g_guildlist:search("btn_drop_down").enable = true
  end
end
function on_book_win_visible(panel, vis)
  if vis == false then
    return
  end
  cur_type_id = -1
  cur_event_id = -1
  cur_time_idx = -1
  typelist_define()
  datalist_define()
  timelist_define()
  guildlist_define()
  updata_need()
  updata_desc()
  update_btn_book_inner()
  local m = os.date("*t", select_day.svar.reserve_time)
  g_bookdate.text = sys.format(ui.get_text("guild|guild_schedule_text_day2"), m.year, m.month, m.day)
end
function make_book_tip()
  if cur_event_id == -1 then
    return
  end
  local line = bo2.gv_guild_schedule:find(cur_event_id)
  if line == nil then
    return
  end
  local money = sys.format("<m:%d>", line.money)
  local item = ui.get_text("guild|null")
  if line.items[0] ~= 0 and line.items[1] ~= 0 then
    item = sys.format("<i:%d>x%d", line.items[0], line.items[1])
  end
  local m = os.date("*t", select_day.svar.reserve_time)
  local book_time = line.book_time[cur_time_idx]
  m.hour = math.floor(book_time / 3600)
  m.min = math.floor(math.fmod(book_time, 3600) / 60)
  local time_begin = os.date("%Y/%m/%d %H:%M", os.time(m))
  book_time = book_time + 3600
  m.hour = math.floor(book_time / 3600)
  m.min = math.floor(math.fmod(book_time, 3600) / 60)
  local time_end = os.date("%Y/%m/%d %H:%M", os.time(m))
  m.hour = math.floor(line.time / 3600)
  m.min = math.floor(math.fmod(line.time, 3600) / 60)
  local time_long = os.date("%H:%M:%S", os.time(m))
  local desc = ""
  if cur_type_id == 3 or cur_type_id == 4 then
    local schedule_name = sys.format(L("%s-%s"), line.name, cur_guild_name)
    desc = sys.format(ui.get_text(L("guild|schedule_book_tip2")), schedule_name, tree_root_name[line.type], time_begin, time_long, line.count, book_count[cur_week][line.group], money, line.develop, item, line.desc)
  else
    desc = sys.format(ui.get_text(L("guild|schedule_book_tip")), line.name, tree_root_name[line.type], time_begin, time_end, time_long, line.count, book_count[cur_week][line.group], money, line.develop, item, line.desc)
  end
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
        v:set(packet.key.org_name, cur_guild_name)
        bo2.send_variant(packet.eCTS_Guild_SetSchedule, v)
      end
    end
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_book_click(btn)
  if sys.check(select_day) == false then
    return
  end
  if gx_btn_book.svar.state == bo2.eScheduleRequest_Book and w_book_win.visible == false then
    w_book_win.visible = true
    w_desc_win.visible = false
    return
  end
  if w_book_win.visible == true then
    make_book_tip()
    return
  end
  if gx_btn_book.svar.state == bo2.eScheduleRequest_Start then
    local v = sys.variant()
    v:set(packet.key.cmn_requestid, gx_btn_book.svar.state)
    v:set(packet.key.cmn_id, select_day.svar.id)
    bo2.send_variant(packet.eCTS_Guild_SetSchedule, v)
    return
  end
  if gx_btn_book.svar.state == bo2.eScheduleRequest_Cancel then
    local line = bo2.gv_guild_schedule:find(select_day.svar.event_id)
    local money = sys.format("<m:%d>", line.money)
    local item = ui.get_text("guild|null")
    if line.items[0] ~= 0 and line.items[1] ~= 0 then
      item = sys.format("<i:%d>x%d", line.items[0], line.items[1])
    end
    local m = os.date("*t", select_day.svar.reserve_time)
    local book_time = select_day.svar.book_time
    m.hour = math.floor(book_time / 3600)
    m.min = math.floor(math.fmod(book_time, 3600) / 60)
    local time_begin = os.date("%Y/%m/%d %H:%M", os.time(m))
    book_time = select_day.svar.book_time + 3600
    m.hour = math.floor(book_time / 3600)
    m.min = math.floor(math.fmod(book_time, 3600) / 60)
    local time_end = os.date("%Y/%m/%d %H:%M", os.time(m))
    m.hour = math.floor(line.time / 3600)
    m.min = math.floor(math.fmod(line.time, 3600) / 60)
    local time_long = os.date("%H:%M:%S", os.time(m))
    local desc = sys.format(ui.get_text("guild|schedule_book_cancel_tip"), line.name, tree_root_name[line.type], time_begin, time_end, time_long, line.count, book_count[cur_week][line.group], money, line.develop, item, line.desc)
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
function show_day(btn, update)
  if select_day == btn and update == nil then
    return
  end
  if sys.check(select_day) == true then
    local old_panel = select_day.parent
    old_panel:search("date_select").visible = false
  end
  local self = ui.guild_get_self()
  if self == nil then
    return
  end
  local pos_line = bo2.gv_guild_auth:find(self.guild_pos)
  if pos_line == nil then
    return
  end
  local panel = btn.parent
  panel:search("date_select").visible = true
  select_day = btn
  w_book_win.visible = false
  w_desc_win.visible = true
  operate_state = false
  gx_btn_book.enable = true
  gx_btn_book.text = ui.get_text("guild|schedule_btn_book")
  gx_btn_book.svar.state = bo2.eScheduleRequest_Book
  if select_day.svar.state == bo2.eScheduleState_End then
    gx_btn_book.enable = false
  end
  if select_day.svar.event_id == 0 then
    gx_schedule_des.mtf = ""
    if select_day.svar.state == bo2.eScheduleState_None and pos_line.schedule == 1 then
      on_book_click(gx_btn_book)
    end
    return
  end
  local line = bo2.gv_guild_schedule:find(select_day.svar.event_id)
  local money = sys.format("<m:%d>", line.money)
  local item = ui.get_text("guild|null")
  if line.items[0] ~= 0 and line.items[1] ~= 0 then
    item = sys.format("<i:%d>x%d", line.items[0], line.items[1])
  end
  local m = os.date("*t", select_day.svar.reserve_time)
  local show_date = sys.format(ui.get_text("guild|guild_schedule_text_day2"), m.year, m.month, m.day)
  local book_time = select_day.svar.book_time
  m.hour = math.floor(book_time / 3600)
  m.min = math.floor(math.fmod(book_time, 3600) / 60)
  local time_begin = os.date("%H:%M", os.time(m))
  book_time = select_day.svar.book_time + bo2.gv_define_org:find(56).value.v_int
  m.hour = math.floor(book_time / 3600)
  m.min = math.floor(math.fmod(book_time, 3600) / 60)
  local time_end = os.date("%H:%M", os.time(m))
  m.hour = math.floor(line.time / 3600)
  m.min = math.floor(math.fmod(line.time, 3600) / 60)
  local time_long = os.date("%H:%M:%S", os.time(m))
  local desc = ""
  if select_day.svar.event_type == 3 or select_day.svar.event_type == 4 then
    local schedule_name = line.name
    if select_day.svar.target_name.empty then
      schedule_name = sys.format(L("%s-%s"), schedule_name, ui.get_text("guild|guild_schedule_noguild"))
    else
      schedule_name = sys.format(L("%s-%s"), schedule_name, select_day.svar.target_name)
    end
    desc = sys.format(ui.get_text("guild|schedule_desc3"), show_date, schedule_name, tree_root_name[line.type], time_begin, line.time / 60, line.count, book_count[cur_week][line.group], line.desc)
  else
    desc = sys.format(ui.get_text("guild|schedule_desc"), show_date, line.name, tree_root_name[line.type], time_begin, time_end, line.time / 60, line.count, book_count[cur_week][line.group], line.desc)
  end
  gx_schedule_des.mtf = desc
  w_desc_win:search("slider_y").scroll = 0
  if select_day.svar.state == bo2.eScheduleState_Execute then
    gx_btn_book.text = ui.get_text("guild|schedule_btn_start")
    gx_btn_book.svar.state = bo2.eScheduleRequest_Start
  elseif select_day.svar.state == bo2.eScheduleState_Book then
    gx_btn_book.text = ui.get_text("guild|schedule_btn_cancel")
    gx_btn_book.svar.state = bo2.eScheduleRequest_Cancel
    if select_day.svar.reserve_time < get_day_end() then
      gx_btn_book.enable = false
    end
    if select_day.svar.event_type == 4 then
      gx_btn_book.enable = false
    end
  elseif select_day.svar.state ~= bo2.eScheduleState_None then
    gx_btn_book.enable = false
  end
end
function day_on_click(btn)
  if operate_state == true then
    local msg = {
      text = ui.get_text("guild|guild_schedule_make_sure_chg"),
      modal = true,
      btn_confirm = 1,
      btn_cancel = 1,
      callback = function(data)
        if data.result == 1 then
          show_day(btn)
        end
      end
    }
    ui_widget.ui_msg_box.show_common(msg)
  else
    show_day(btn)
  end
end
function update_btn_book_inner()
  gx_btn_book.enable = false
  if cur_time_idx == -1 then
    return
  end
  if cur_event_id == -1 then
    return
  end
  local line = bo2.gv_guild_schedule:find(cur_event_id)
  if line == nil then
    return
  end
  if check_need_state == false then
    return
  end
  if book_count[cur_week][line.group] >= line.count then
    return
  end
  local book_level = line.book_level
  for k = 0, book_level.size - 1, 3 do
    local build = ui.guild_get_build(book_level[k])
    local iMin = book_level[k + 1]
    local iMax = book_level[k + 2]
    if iMin ~= 0 and iMin > build.level or iMax ~= 0 and iMax < build.level then
      return
    end
  end
  if cur_type_id == 4 and cur_guild_id == -1 then
    return
  end
  gx_btn_book.enable = true
end
function on_event_timelist_select(item)
  cur_time_idx = item.id
  guildlist_define()
  update_btn_book_inner()
  operate_state = true
end
function on_event_typelist_select(item)
  if item.id ~= cur_type_id then
    cur_type_id = item.id
    datalist_define()
    timelist_define()
    guildlist_define()
    updata_need()
    updata_desc()
    update_btn_book_inner()
    operate_state = true
  end
end
function updata_need()
  check_need_state = true
  gx_need_money.money = 0
  gx_need_develop.text = 0
  gx_need_item:search("item_picture").visible = false
  gx_need_item:search("item_text").visible = false
  if cur_event_id == -1 then
    return
  end
  local line = bo2.gv_guild_schedule:find(cur_event_id)
  if line == nil then
    return
  end
  gx_need_money.money = line.money
  if ui.guild_get_money() < line.money then
    gx_need_money.color = COLOR_RED
    check_need_state = false
  else
    gx_need_money.color = COLOR_WRITE
  end
  gx_need_develop.text = line.develop
  if ui.guild_get_develop() < line.develop then
    check_need_state = false
    gx_need_develop.color = COLOR_RED
  else
    gx_need_develop.color = COLOR_WRITE
  end
  if line.items[0] == 0 or line.items[1] == 0 then
    return
  end
  local item = bo2.gv_item_list:find(line.items[0])
  if item == nil then
    item = bo2.gv_gem_item:find(line.items[0])
    if item == nil then
      item = bo2.gv_equip_item:find(line.items[0])
      if item == nil then
        return
      end
    end
  end
  gx_need_item:search("item_picture").image = SHARED(sys.format("$icon/item/%s.png|0,0,64,64*16,16", item.icon))
  gx_need_item:search("item_text").text = sys.format("%s X%d", item.name, line.items[1])
  gx_need_item:search("item_picture").visible = true
  gx_need_item:search("item_text").visible = true
end
function updata_desc()
  gx_schedule_des2.mtf = ""
  if cur_event_id == -1 then
    return
  end
  local line = bo2.gv_guild_schedule:find(cur_event_id)
  if line == nil then
    return
  end
  local c_txt_b = ""
  local c_txt_e = ""
  if book_count[cur_week][line.group] >= line.count then
    c_txt_b = "<c+:ff0000>"
    c_txt_e = "<c->"
  end
  gx_schedule_des2.mtf = sys.format(ui.get_text("guild|schedule_desc2"), line.time / 60, c_txt_b, line.count, book_count[cur_week][line.group], c_txt_e, line.desc)
  gx_schedule_des2:search("slider_y_inner").scroll = 0
end
function on_event_datalist_select(item)
  if item.id ~= cur_event_id then
    cur_event_id = item.id
    timelist_define()
    guildlist_define()
    updata_need()
    updata_desc()
    update_btn_book_inner()
    operate_state = true
  end
end
function on_event_guildlist_select(item)
  cur_guild_id = item.data.onlyid
  cur_guild_name = item.data.text
  update_btn_book_inner()
  operate_state = true
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
    old_panel:search("date_select").visible = false
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
    if tree_root_name[line.type] ~= nil then
      book_count[1][line.group] = 0
      book_count[2][line.group] = 0
      book_count[3][line.group] = 0
    end
  end
  cur_type_id = -1
  cur_event_id = -1
  cur_time_idx = -1
  cur_guild_id = -1
  cur_guild_name = ""
  local begin_day = get_day_begin()
  local end_day = get_day_end()
  for i = 0, data.size - 1 do
    local day = SetDayInfo(data:get(i))
    local week = math.ceil((i + 1) / 7)
    day.week = week
    if day.event_id ~= 0 then
      local pLine = bo2.gv_guild_schedule:find(day.event_id)
      book_count[week][pLine.group] = book_count[week][pLine.group] + 1
    end
    table.insert(week_info[week], day)
    if cur_week ~= week and begin_day <= day.reserve_time and end_day >= day.reserve_time then
      cur_week = week
    end
  end
  SetWeekInfo(week_info[cur_week])
  g_timelist.svar.on_select = on_event_timelist_select
  g_typelist.svar.on_select = on_event_typelist_select
  g_datalist.svar.on_select = on_event_datalist_select
  g_guildlist.svar.on_select = on_event_guildlist_select
end
function update_item(data)
  local v = SetDayInfo(data)
  local which_week = -1
  local which_date = -1
  for _where, week in pairs(week_info) do
    for i, dayinfo in pairs(week) do
      if dayinfo.id == v.id then
        which_week = _where
        which_date = i
      end
    end
  end
  if which_date == -1 or which_week == -1 then
    return
  end
  for i, day in pairs(week_info[which_week]) do
    if day.id == v.id then
      week_info[which_week][i] = v
      if data:has(packet.key.cmn_requestid) then
        local update_type = data:get(packet.key.cmn_requestid).v_int
        if update_type == bo2.eScheduleRequest_Book then
          do
            local pLine = bo2.gv_guild_schedule:find(v.event_id)
            book_count[which_week][pLine.group] = book_count[which_week][pLine.group] + 1
          end
          break
        end
        if update_type == bo2.eScheduleRequest_Cancel then
          local pLine = bo2.gv_guild_schedule:find(day.event_id)
          book_count[which_week][pLine.group] = book_count[which_week][pLine.group] - 1
        end
      end
      break
    end
  end
  if cur_week ~= which_week then
    return
  end
  local panel = w_win:search("date_card_" .. which_date)
  local day_btn = panel:search("day_btn")
  local daybegin = get_day_begin()
  local dayend = get_day_end()
  local state_uri, text_color
  local text = ""
  if v.state == bo2.eScheduleState_None then
    text = ui.get_text("guild|guild_schedule_state_none")
    state_uri = STATE_IMAGE_NONE
    text_color = STATE_TEXT_COLOR_NONE
  elseif v.state == bo2.eScheduleState_Book then
    if dayend < v.reserve_time then
      text = ui.get_text("guild|guild_schedule_state_book")
      state_uri = STATE_IMAGE_BOOK
      text_color = STATE_TEXT_COLOR_BOOK
    else
      text = ui.get_text("guild|guild_schedule_state_lock")
      state_uri = STATE_IMAGE_LOCK
      text_color = STATE_TEXT_COLOR_LOCK
    end
  elseif v.state == bo2.eScheduleState_Execute then
    text = ui.get_text("guild|guild_schedule_state_exe")
    state_uri = STATE_IMAGE_STAR
    text_color = STATE_TEXT_COLOR_STAR
  elseif v.state == bo2.eScheduleState_Done then
    text = ui.get_text("guild|guild_schedule_state_done")
    state_uri = STATE_IMAGE_RUN
    text_color = STATE_TEXT_COLOR_RUN
  elseif v.state == bo2.eScheduleState_End then
    text = ui.get_text("guild|guild_schedule_state_end")
    state_uri = STATE_IMAGE_END
    text_color = STATE_TEXT_COLOR_END
  end
  panel:search("state_pic").image = SHARED(state_uri)
  local state_text = panel:search("state_text")
  state_text.text = text
  state_text.color = ui.make_color(text_color)
  if v.event_type ~= 0 then
    panel:search("type_image").image = SHARED(sys.format("$image/guild/schedule_type/%d_1.png|14,13,40,40", v.event_type))
    panel:search("type_text").image = SHARED(sys.format("$image/guild/schedule_type/%d.png|14,13,40,40", v.event_type))
    panel:search("type_image").visible = true
    panel:search("type_text").visible = true
  else
    panel:search("type_image").visible = false
    panel:search("type_text").visible = false
  end
  day_btn.svar = v
  show_day(day_btn, true)
end
function updata_step_btn()
  w_win:search("btn_prev").enable = true
  w_win:search("btn_next").enable = true
  if cur_week == 1 then
    w_win:search("btn_prev").enable = false
  elseif cur_week == 3 then
    w_win:search("btn_next").enable = false
  end
end
function on_stepping_left(btn)
  if operate_state == true then
    local msg = {
      text = ui.get_text("guild|guild_schedule_make_sure_chg"),
      modal = true,
      btn_confirm = 1,
      btn_cancel = 1,
      callback = function(data)
        if data.result == 1 then
          cur_week = cur_week - 1
          SetWeekInfo(week_info[cur_week])
        end
      end
    }
    ui_widget.ui_msg_box.show_common(msg)
  else
    cur_week = cur_week - 1
    SetWeekInfo(week_info[cur_week])
  end
end
function on_stepping_right(btn)
  if operate_state == true then
    local msg = {
      text = ui.get_text("guild|guild_schedule_make_sure_chg"),
      modal = true,
      btn_confirm = 1,
      btn_cancel = 1,
      callback = function(data)
        if data.result == 1 then
          cur_week = cur_week + 1
          SetWeekInfo(week_info[cur_week])
        end
      end
    }
    ui_widget.ui_msg_box.show_common(msg)
  else
    cur_week = cur_week + 1
    SetWeekInfo(week_info[cur_week])
  end
end
function BuildSchedule(cmd, data)
  if data:get(packet.key.cmn_system_flag).v_int == 1 then
    update_item(data)
  else
    init_data(data)
  end
end
function update_selfinfo(cmd, data)
  local cur_money = ui.guild_get_money()
  local ctrl = g_follow:search("gx_guild_money")
  local label1 = ctrl:search("l_lable_left1")
  local label2 = ctrl:search("l_lable_left2")
  label1.visible = true
  label2.visible = false
  g_guild_money.color = ui.make_color("ffffff")
  if cur_money < 0 then
    cur_money = -cur_money
    g_guild_money.color = ui.make_color("FF0000")
    label1.visible = false
    label2.visible = true
  end
  g_guild_money.money = cur_money
  g_guild_develop.text = ui.guild_get_develop()
end
function on_init()
  local offon = bo2.gv_define_org:find(114).value.v_int
  if offon == 1 then
    tree_root_name[4] = nil
  end
end
reg(packet.eSTC_Guild_Schedule, BuildSchedule, sig)
reg(packet.eSTC_Guild_SelfData, update_selfinfo, sig)
