local reg = ui_packet.game_recv_signal_insert
local sig = "ui_quest.packet_handler"
function areaquest_show(cmd, data)
  ui.log("ininin")
end
reg(packet.eSTC_UI_AreaQuest_Show, areaquest_show, sig)
