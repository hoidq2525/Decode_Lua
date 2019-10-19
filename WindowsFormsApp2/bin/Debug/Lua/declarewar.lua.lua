function HandleDeclareWarPoPo(cmd, data)
  local name = data:get(packet.key.ui_invitor_name).v_string
  if not bo2.player.bIshOpen then
    ui_widget.ui_wnd.show_notice({
      text = ui_widget.merge_mtf({cha_name = name}, ui.get_text("convene|declarewar_message")),
      timeout = 30,
      sound = "$sound/gps_finish.wav"
    })
  end
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_Player_DeclareWarPoPo, HandleDeclareWarPoPo, "ui_portrait:HandleDeclareWarPoPo")
