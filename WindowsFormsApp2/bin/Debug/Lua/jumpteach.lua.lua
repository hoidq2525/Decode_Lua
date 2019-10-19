function on_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
  else
    ui_widget.esc_stk_pop(w)
  end
end
function on_first_show_window(cmd, data)
  gx_window.visible = true
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_jumpteach.packet_handle"
reg(packet.eSTC_ScnObj_JumpTeach, on_first_show_window, sig)
