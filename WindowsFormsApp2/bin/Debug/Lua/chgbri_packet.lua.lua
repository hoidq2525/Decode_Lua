function handle_chgbright(cmd, data)
  ui_levelup.scn_chgbri.on_chgbright(data)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "scn_chgbri.packet_handle"
reg(packet.eSTC_UI_ChgBrightness, handle_chgbright, sig)
