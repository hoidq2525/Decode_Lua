g_refresh_ui = {}
g_cmd = nil
g_data = nil
function on_init()
  g_refresh_ui[bo2.eRefreshUI_Hunskill] = {
    w_main = ui_skill.w_skill,
    refresh_ui = ui_skill.refresh_ui_hunskill
  }
  g_refresh_ui[bo2.eRefreshUI_Livingskill] = {
    w_main = ui_skill.w_skill,
    refresh_ui = ui_skill.refresh_ui_livingskill
  }
end
function handle_refresh_ui(cmd, data)
  local cmn_val = data:get(packet.key.cmn_val).v_int
  local w = g_refresh_ui[cmn_val]
  if w == nil then
    return
  end
  if w.w_main ~= nil then
    bo2.AddTimeEvent(5, w.refresh_ui(cmd, data))
  end
end
function handle_use_circulated_rep_bounded_msg(cmd, data)
  local msg = {
    modal = true,
    btn_cancel = false,
    btn_confirm = true,
    btn_close = false
  }
  msg.title = ui.get_text("portrait|use_irculated_msg_title")
  msg.text = ui.get_text("portrait|use_irculated_msg_content")
  ui_widget.ui_msg_box.show_common(msg)
end
on_init()
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_Refresh_UI, handle_refresh_ui, "ui_refresh_ui.handle_refresh_ui")
ui_packet.recv_wrap_signal_insert(packet.eSTC_UseCirculatedRepBoundedMsg, handle_use_circulated_rep_bounded_msg, "ui_refresh_ui.handle_use_circulated_rep_bounded_msg")
