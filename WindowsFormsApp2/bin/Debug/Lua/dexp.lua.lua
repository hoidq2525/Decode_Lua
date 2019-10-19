function on_tip_make(tip)
  local view = tip.view
  local text = tip.text
  local card = tip.owner
  ui_tool.ctip_show(card, tip)
  local view_off = ui.point(100, 100)
  view.offset = view_off
end
function on_available_mouse(panel, msg)
  local x = 1
end
function on_display_mouse(panel, msg)
  if msg == ui.mouse_enter then
    if w_flicker_dexp_display.visible == true then
      w_flicker_dexp_display.visible = false
      w_flicker_dexp_display.suspended = true
      w_flicker_timer.suspended = true
    end
    w_dexp_display_bg.visible = true
  elseif msg == ui.mouse_leave then
    w_dexp_display_bg.visible = false
  end
end
function on_display_time_mouse(panel, msg)
  w_dexp_display_bg.visible = true
end
function on_window_visible(c)
  if c.visible == true then
    packet_update()
  end
end
function set_time(item, time, uint)
  item:search("label").text = string.format("%d", time) .. ui.get_text("dexp|dexp_" .. uint)
end
function sel_hours(btn)
  for i, v in ipairs(can_sel_hours) do
    if v.btn:search("hour") == btn then
      btn:search("button_figure").visible = true
      v.sel = true
      w_get_ok.enable = true
    else
      v.btn:search("button_figure").visible = false
      v.sel = false
    end
  end
end
local seltime
function on_add_dexp(cmd, data)
  local state = data:get("state").v_int
  if state == 1 then
    local sys_total_time = data:get("sysTime").v_int
    local item_total_time = data:get("itemTime").v_int
    local total_time = sys_total_time + item_total_time
    w_freeze_button.enable = true
    w_dexp_current.left_time = total_time
    ui_reciprocal.del_reciproca("doubledexp")
    local insert_sub = {}
    insert_sub.time = total_time
    insert_sub.name = ui.get_text("dexp|dexp_double")
    insert_sub.close = true
    insert_sub.callback = nil
    insert_sub.icon = L("$image/qbar/timer_bar.png|9,10,20,20")
    ui_reciprocal.add_reciproca("doubledexp", insert_sub)
  elseif state == 2 then
    ui_reciprocal.del_reciproca("doubledexp")
    w_dexp_current.left_time = 0
    w_freeze_button.enable = false
  end
end
function on_freeze_confirm(msg)
  if msg.result == 0 then
    return
  end
  packet_freeze()
end
function on_freeze()
  local msg = {
    callback = on_freeze_confirm,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.title = ui.get_text("dexp|dexp_freeze_confirm")
  msg.text = ui.get_text("dexp|dexp_going_freeze")
  ui_widget.ui_msg_box.show_common(msg)
end
function on_get_confirm(msg)
  if msg.result == 0 then
    return
  end
  local hours = ui_widget.ui_combo_box.selected(w_dexp_available).id
  if hours == 0 then
    return
  end
  if hours > bo2.player:get_flag_int32(bo2.eFlagInt32_iSysUnGet) then
    ui.log("hours selected more than remain hours")
  end
  packet_get_sysTime(hours)
end
function on_get()
  local msg = {
    callback = on_get_confirm,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.title = ui.get_text("dexp|dexp_get_confirm")
  local sel_item = ui_widget.ui_combo_box.selected(w_dexp_available)
  local surplus_hours = bo2.player:get_flag_int32(bo2.eFlagInt32_iSysUnGet) - sel_item.id
  msg.text = ui_widget.merge_mtf({
    time = sel_item.text,
    hour = sys.format("%d", surplus_hours)
  }, ui.get_text("dexp|dexp_going_get"))
  ui_widget.ui_msg_box.show_common(msg)
end
function on_active_confirm(msg)
  if msg.result == 0 then
    return
  end
  packet_active()
end
function on_active()
  local msg = {
    callback = on_active_confirm,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.title = ui.get_text("dexp|dexp_active_confirm")
  msg.text = ui_widget.merge_mtf({
    time = w_dexp_freeze.text
  }, ui.get_text("dexp|dexp_going_active"))
  ui_widget.ui_msg_box.show_common(msg)
end
function set_dexp_info()
  on_dexpView_visible()
end
function on_player_info_init(obj)
  if obj == bo2.player then
    obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.eFlagInt32_iSysUnGet, set_dexp_info, "ui_dexp.packet_handle")
    obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.eFlagInt32_iSysFreeze, set_dexp_info, "ui_dexp.packet_handle")
    obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.eFlagInt32_iItemFreeze, set_dexp_info, "ui_dexp.packet_handle")
  end
end
function on_dexpinquire_visible()
end
function on_dexpFreeze_visible()
end
function on_dexpActive_visible()
end
function on_dexpView_visible(w, vis)
  if vis then
    bo2.PlaySound2D(578)
  else
    bo2.PlaySound2D(579)
  end
  ui_widget.ui_combo_box.clear(w_dexp_available)
  if w_dexpView_main.visible then
    local ava_hours = bo2.player:get_flag_int32(bo2.eFlagInt32_iSysUnGet)
    w_dexp_surplus.text = ava_hours
    if ava_hours < 1 then
      ui_widget.ui_combo_box.append(w_dexp_available, {id = 0, text = "00:00:00"})
      ui_widget.ui_combo_box.select(w_dexp_available, 0)
      w_get_button.enable = false
      w_dexp_surplus.color = ui.make_argb("FFFF0000")
    else
      if ava_hours >= 4 then
        ui_widget.ui_combo_box.append(w_dexp_available, {id = 4, text = "04:00:00"})
      end
      if ava_hours >= 2 then
        ui_widget.ui_combo_box.append(w_dexp_available, {id = 2, text = "02:00:00"})
      end
      if ava_hours >= 1 then
        ui_widget.ui_combo_box.append(w_dexp_available, {id = 1, text = "01:00:00"})
      end
      ui_widget.ui_combo_box.select(w_dexp_available, 1)
      w_get_button.enable = true
      w_dexp_surplus.color = ui.make_argb("FF00FF00")
    end
    local freeze_seconds = bo2.player:get_flag_int32(bo2.eFlagInt32_iSysFreeze) + bo2.player:get_flag_int32(bo2.eFlagInt32_iItemFreeze)
    w_dexp_freeze.text = string.format("%02d:%02d:%02d", freeze_seconds / 3600, freeze_seconds / 60 % 60, freeze_seconds % 60)
    if freeze_seconds > 0 then
      w_active_button.enable = true
    else
      w_active_button.enable = false
    end
    local current_seconds = w_dexp_current.left_time
    if w_dexp_current:is_running() == true then
      w_freeze_button.enable = true
    else
      w_freeze_button.enable = false
    end
  end
end
function on_dexpget_init()
  w_get_ok.enable = false
  for i = 0, bo2.gv_sysexp_list:find(1).sel_hours.size - 1 do
    local item = gx_timelist:item_append()
    item:load_style("$frame/dexp/dexp.xml", "timeitem")
    item:search("timetext").text = bo2.gv_sysexp_list:find(1).sel_hours[i]
    item:search("hourtext").text = ui.get_text("dexp|dexp_hour")
  end
end
function on_dexpInquire_init()
  w_Inquire_ok.visible = true
  w_Inquire_ok.enable = true
end
function on_dexpFreeze_init()
  w_Freeze_ok.visible = true
  w_Freeze_ok.enable = true
end
function on_dexpActive_init()
  w_Active_ok.visible = true
  w_Active_ok.enable = true
end
function OnSelecttimeItem(item, sel)
  item:search("select").visible = sel
  seltime = item:search("timetext").text
  w_get_ok.enable = true
end
local sig_name = "ui_dexp.packet_get_sysTime:on_signal"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_DExpAdd, on_add_dexp, sig_name)
function setguilddexp()
  local hours = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_iGuildExp)
  local function on_setsysdexp_msg(msg)
    if msg == nil then
      return
    end
    if msg.result == 1 then
      if hours == 0 then
        return
      end
      packet_get_guildTime(hours)
    end
  end
  local arg = sys.variant()
  arg:set("hours", hours)
  local msg = {
    title = ui.get_text("org|shuangbei"),
    callback = on_setsysdexp_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    limit = 16,
    text_confirm = ui.get_text("org|jihuo"),
    text_cancel = ui.get_text("org|quxiao")
  }
  msg.text = sys.mtf_merge(arg, ui.get_text("org|dexp"))
  if hours == 0 then
    msg.btn_confirm = false
  end
  ui_widget.ui_msg_box.show_common(msg)
end
function on_display_config_load(cfg, root)
  if root == nil then
    w_dexp_display.dock = "ext_x2y1"
    w_dexp_display.margin = ui.rect(0, 48, 10, 0)
    return
  end
  local display_data = root:find("dexp_display")
  if display_data == nil then
    w_dexp_display.dock = "ext_x2y1"
    w_dexp_display.margin = ui.rect(0, 48, 10, 0)
    return
  end
  local position = display_data:get("position")
  local x = position:get_attribute("x")
  local y = position:get_attribute("y")
  if not x.empty and not y.empty and x.v_int ~= 0 and y.v_int ~= 0 then
    w_dexp_display.dock = "none"
    w_dexp_display.offset = ui.point(x.v_int, y.v_int)
  else
    w_dexp_display.dock = "ext_x2y1"
    w_dexp_display.margin = ui.rect(0, 48, 10, 0)
  end
end
function on_display_config_save(cfg, root)
  if root == nil then
    return
  end
  local display_data = root:find("dexp_display")
  if display_data == nil then
    root:add("dexp_display")
    display_data = root:find("dexp_display")
  end
  local position = display_data:get("position")
  if position == nil then
    display_data:add("position")
    position = display_data:get("position")
  end
  position:set_attribute("x", w_dexp_display.x)
  position:set_attribute("y", w_dexp_display.y)
end
function on_flicker_timer()
  w_flicker_dexp_display.visible = false
  w_flicker_dexp_display.suspended = true
  w_flicker_timer.suspended = true
end
function on_half_timer()
  if w_dexp_display.visible == true then
    w_flicker_dexp_display.visible = true
    w_flicker_dexp_display.suspended = false
    w_flicker_timer.suspended = false
  end
  w_half_timer.suspended = true
end
function on_surplus_timer()
  if w_dexp_display.visible == true then
    w_flicker_dexp_display.visible = true
    w_flicker_dexp_display.suspended = false
    w_flicker_timer.suspended = true
    w_flicker_timer.suspended = false
  end
  w_surplus_timer.suspended = true
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_dexp.packet_handle"
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_player_info_init, sig)
