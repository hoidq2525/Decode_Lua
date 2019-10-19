function handle_teach_flyracing(cmd, data)
  ui_handson_teach.redo_jump()
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_battle_fly_racing.packet_handle"
reg(packet.eSTC_Teach_Flyracing, handle_teach_flyracing, sig)
