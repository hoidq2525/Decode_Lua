local quick_buy_item = {
  63115,
  63114,
  63113
}
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  w_equip_target:insert_on_item_only_id(on_target_onlyid, "ui_ridepet_unseal.on_target_onlyid")
  w_equip_material:insert_on_item_only_id(on_material_onlyid, "ui_ridepet_unseal.on_material_onlyid")
  for _, id in ipairs(quick_buy_item) do
    local goods_id = ui_supermarket2.shelf_quick_buy_id(id)
    if goods_id > 0 then
      w_material_quick_buy.visible = true
      w_material_quick_buy.name = goods_id
      break
    end
  end
end
function item_rbutton_check(info)
  if info == nil then
    return false
  end
  local excel = info.excel
  if excel == nil then
    return false
  end
  local ptype = excel.ptype
  if ptype == nil then
    return false
  end
  if ptype.id == bo2.eItemType_RidePetUnSeal then
    return true
  end
  if ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
    return true
  end
  return false
end
function item_rbutton_use(info)
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  local ptype = excel.ptype
  if ptype == nil then
    return nil
  end
  if ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
    ui_npcfunc.ui_ridepet_cmn.drop(w_equip_target, info)
  end
  if ptype.id == bo2.eItemType_RidePetUnSeal then
    ui_npcfunc.ui_cell.drop(w_equip_material, info)
  end
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|ridepet_weapon_rclick_to_place")
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  if vis == false then
    ui_npcfunc.ui_ridepet_cmn.clear(w_equip_target)
    ui_npcfunc.ui_cell.clear(w_equip_material.parent.parent)
    w_label_preview.text = ""
    ui.item_mark_show("ridepet_weapon_unseal", false)
  else
    ui.item_mark_show("ridepet_weapon_unseal", true)
  end
end
function on_target_onlyid(card, onlyid, info)
  on_update_preview()
end
function on_material_onlyid(card, onlyid, info)
  on_update_preview()
end
function is_ready()
  local info = w_equip_target.info
  if info == nil then
    return false
  end
  local excel = info.excel
  if excel == nil then
    return false
  end
  local ridepet_identify_excel = bo2.gv_equip_ridepet_identify:find(excel.ridepet_identify)
  if ridepet_identify_excel == nil then
    return false
  end
  if info:get_data_32(bo2.eItemUInt32_RideFightSkillSlot) == 0 then
    return false
  end
  info = w_equip_material.info
  if info == nil then
    return false
  end
  excel = info.excel
  if excel == nil then
    return false
  end
  if excel.type ~= bo2.eItemType_RidePetUnSeal then
    return false
  end
  if excel.datas.size ~= 1 then
    return false
  end
  local idx = excel.datas[0]
  local ridepet_unseal_excel = bo2.gv_equip_ridepet_unseal:find(idx)
  if ridepet_unseal_excel == nil then
    return false
  end
  return true
end
function get_preview_money()
  local text
  local money = 0
  local upgrade_id = w_equip_target.info:get_data_8(bo2.eItemByte_AssUpgradeID)
  if upgrade_id == 0 then
    text = ui.get_text("npcfunc|equip_ridepet_unseal_none")
    money = 0
    return text, money
  end
  local excel = w_equip_target.info.excel
  local ridepet_identify_excel = bo2.gv_equip_ridepet_identify:find(excel.ridepet_identify)
  local cur_slot = w_equip_target.info:get_data_32(bo2.eItemUInt32_RideFightSkillSlot)
  if cur_slot >= ridepet_identify_excel.nMaxSlot then
    text = ui.get_text("npcfunc|equip_ridepet_unseal_full")
    money = 0
    return text, money
  end
  local excel = w_equip_material.info.excel
  local idx = excel.datas[0]
  local ridepet_unseal_excel = bo2.gv_equip_ridepet_unseal:find(idx)
  local arg = sys.variant()
  arg:set("percent", ridepet_unseal_excel.nPercent[cur_slot])
  text = sys.mtf_merge(arg, ui.get_text("npcfunc|equip_ridepet_unseal_text"))
  money = ridepet_unseal_excel.nMoney[cur_slot]
  return text, money
end
function on_update_preview()
  if is_ready() then
    local text, money = get_preview_money()
    w_label_preview.text = text
    w_money.money = money
    w_btn_ok.enable = true
  else
    w_label_preview.text = ""
    w_money.money = 0
    w_btn_ok.enable = false
  end
end
function on_btn_ok()
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_RidePetWeaponAddSlot)
  v:set64(packet.key.item_key, w_equip_target.info.only_id)
  v:set(packet.key.item_key1, w_equip_material.info.excel_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  ui_npcfunc.ui_ridepet_cmn.clear(w_equip_target)
  ui_npcfunc.ui_cell.clear(w_equip_material.parent.parent)
  w_label_preview.text = ""
end
function on_material_drop(pn, msg, pos, data)
  if ui_npcfunc.ui_cell.check_drop(pn, msg, pos, data) == false then
    return
  end
  local info = ui.item_of_only_id(data:get("only_id"))
  if info.excel.type ~= bo2.eItemType_RidePetUnSeal then
    ui_safe.notify(5492)
    return
  end
  ui_npcfunc.ui_cell.drop(pn, info)
end
