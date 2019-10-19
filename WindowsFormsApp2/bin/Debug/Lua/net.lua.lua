function on_scode(cmd, data)
  ui_scode.load(ui_scode.w_pic)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_scode:signal"
reg(packet.eSTC_SecurityCode, on_scode, sig)
function send_answer(t)
  local data = sys.variant()
  local answer = sys.format("%s%s", t.select[1].id, t.select[2].id)
  data:set(packet.key.check_code_buffer, answer)
  bo2.send_variant(packet.eCTS_SecurityCode_Check, data)
end
