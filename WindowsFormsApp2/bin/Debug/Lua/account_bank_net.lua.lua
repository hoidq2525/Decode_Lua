function send_bank_extend(size)
  local data = sys.variant()
  data:set(packet.key.item_key, size)
  bo2.send_variant(packet.eCTS_UI_AccBankExtend, data)
end
