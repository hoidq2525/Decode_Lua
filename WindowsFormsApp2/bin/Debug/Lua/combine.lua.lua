function on_init(ctrl)
  g_raw.require_count = 1
  g_raw:insert_on_item_only_id(on_card_chg, "ui_combine.on_card_chg")
  g_equip:insert_on_item_only_id(on_card_chg, "ui_combine.on_card_chg")
end
function on_card_chg(card, onlyid, info)
  if info == nil then
    g_preview.excel_id = 0
    ui_npcfunc.set_succ_rate(g_succ_rate, 0)
    if card == g_equip then
      g_req_money.money = 0
    end
    combine_ok.enable = false
    return
  end
  if g_equip.info ~= nil and g_raw.info ~= nil then
    combine_ok.enable = true
  end
  if g_equip.info == nil then
    return
  end
  local comExcel = bo2.gv_equip_combine:find(g_equip.info.excel.variety)
  if comExcel == nil then
    return
  end
  g_req_money.money = comExcel.money
  if g_raw.excel_id == 0 then
    return
  end
  ui_npcfunc.set_succ_rate(g_succ_rate, 1000000)
  for i = 0, 11 do
    if g_raw.excel_id == comExcel.reg_id[i] then
      g_preview.excel_id = comExcel.prod_id[i]
      break
    end
  end
end
function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  if vis == false then
    ui_npcfunc.clear_card(g_equip)
    ui_npcfunc.clear_card(g_raw)
  end
end
function on_ok(ctrl)
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_CombineEquip)
  v:set64(packet.key.item_key, g_equip.only_id)
  v:set64(packet.key.item_key1, g_raw.only_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
