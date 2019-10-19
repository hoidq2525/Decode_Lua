local reg = ui_packet.game_recv_signal_insert
local sig = "ui_pixelmouse.packet_handle"
function OnPMPlaySolo(cmd, data)
  local filename = data:get(packet.key.pm_file_name).v_string
  if filename == L("") then
    return
  end
  local g_mds_handle = assert(io.open(filename, "rb"))
end
reg(packet.eSTC_PM_PlaySolo, OnPMPlaySolo, sig)
