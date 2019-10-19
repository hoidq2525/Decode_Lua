function item_rbutton_tip(info)
  local rclick_to_refine = ui.get_text("assistant|rclick_to_refine")
  return rclick_to_refine
end
function item_rbutton_check(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel == nil then
    return false
  end
  local type_excel = bo2.gv_item_type:find(excel.type)
  if type_excel == nil then
    return false
  end
  if type_excel.equip_slot ~= bo2.eItemSlot_2ndWeapon then
    return false
  end
  local ass_id = excel.ass_id
  if ass_id == 0 then
    return false
  end
  local ass_t_excel = bo2.gv_second_equip_template:find(ass_id)
  if ass_t_excel == nil then
    return false
  end
  local prize_excel = bo2.gv_assistant_prize:find(ass_t_excel.prize_id)
  if prize_excel == nil then
    return false
  end
  return true
end
function item_rbutton_use(info)
  ui_npcfunc.ui_cell.drop(g_equip.parent.parent, info)
end
function on_ok()
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_AssTransfer)
  v:set64(packet.key.item_key, g_equip.only_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  if vis == false then
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
  end
  transfer_ok.enable = false
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  g_equip:insert_on_item_only_id(on_card_chg, "ui_assrefine.on_card_chg")
end
function on_card_chg(card, onlyid, info)
  if card.excel_id == 0 then
    ui_npcfunc.ui_cmn.money_set(w_money, 0)
    transfer_ok.enable = false
    return
  end
  transfer_ok.enable = true
  local excel = bo2.gv_equip_item:find(card.excel_id)
  if excel == nil then
    return
  end
  local type_excel = bo2.gv_item_type:find(excel.type)
  if type_excel == nil then
    return
  end
  if type_excel.equip_slot ~= bo2.eItemSlot_2ndWeapon then
    return
  end
  local ass_id = excel.ass_id
  if ass_id == 0 then
    return
  end
  local ass_t_excel = bo2.gv_second_equip_template:find(ass_id)
  if ass_t_excel == nil then
    return
  end
  local prize_excel = bo2.gv_assistant_prize:find(ass_t_excel.prize_id)
  if prize_excel == nil then
    return
  end
  local level = info:get_data_32(bo2.eItemUInt32_GemEnd + 1)
  local prize = prize_excel.transfer_prize
  ui_npcfunc.ui_cmn.money_set(w_money, prize)
  transfer_ok.enable = true
end
