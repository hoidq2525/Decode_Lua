function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  w_equip_target:insert_on_item_only_id(on_target_onlyid, "ui_ridepet_unseal.on_target_onlyid")
  w_equip_material:insert_on_item_only_id(on_material_onlyid, "ui_ridepet_unseal.on_material_onlyid")
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
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|ridepet_weapon_rclick_to_place")
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  if vis == false then
    ui_npcfunc.ui_ridepet_cmn.clear(w_equip_target)
    ui_npcfunc.ui_ridepet_cmn.clear(w_equip_material)
    w_label_preview.text = ""
    ui.item_mark_show("ridepet_weapon_skill_add", false)
  else
    ui.item_mark_show("ridepet_weapon_skill_add", true)
  end
end
function on_target_onlyid(card, onlyid, info)
  on_update_skill_state()
end
function on_material_onlyid(card, onlyid, info)
  on_update_skill_state()
end
function update_skill_lock(target, material)
  ui_npcfunc.ui_ridepet_cmn.clear_lock(target)
  local target_info = target.info
  local material_info = material.info
  for i = bo2.eItemUInt32_RideFightSkillBeg, bo2.eItemUInt32_RideFightSkillEnd - 1 do
    local skill_id = target_info:item_get_ridepet_skill_id(i - bo2.eItemUInt32_RideFightSkillBeg)
    if skill_id > 0 then
      local material_idx = ui_npcfunc.ui_ridepet_cmn.find_skill_idx(material_info, skill_id)
      if material_idx ~= -1 then
        ui_npcfunc.ui_ridepet_cmn.lock_card(target, skill_id)
      end
    end
  end
end
function on_update_skill_state()
  ui_npcfunc.ui_ridepet_cmn.clear_lock(w_equip_target)
  ui_npcfunc.ui_ridepet_cmn.clear_lock(w_equip_material)
  ui_npcfunc.ui_ridepet_cmn.clear_select(w_equip_target)
  ui_npcfunc.ui_ridepet_cmn.clear_select(w_equip_material)
  if w_equip_target.info ~= nil and w_equip_material.info ~= nil then
    update_skill_lock(w_equip_material, w_equip_target)
  end
  on_update_preview()
end
function is_legal()
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
  info = w_equip_material.info
  if info == nil then
    return false
  end
  excel = info.excel
  if excel == nil then
    return false
  end
  ridepet_identify_excel = bo2.gv_equip_ridepet_identify:find(excel.ridepet_identify)
  if ridepet_identify_excel == nil then
    return false
  end
  return true
end
function get_preview_money_enable()
  local text = ""
  local money = 0
  local enable = false
  if is_legal() == false then
    return text, money, false
  end
  local skill_id = ui_npcfunc.ui_ridepet_cmn.get_select_skill_id(w_equip_material)
  if skill_id == 0 then
    return text, money, enable
  end
  local target_info = w_equip_target.info
  local upgrade_id = target_info:get_data_8(bo2.eItemByte_AssUpgradeID)
  if upgrade_id == 0 then
    text = ui.get_text("npcfunc|equip_ridepet_skill_add_none")
    return text, money, enable
  end
  local target_skill_cur_cnt = ui_npcfunc.ui_ridepet_cmn.get_skill_cnt(target_info)
  local target_skill_max_cnt = target_info:get_data_32(bo2.eItemUInt32_RideFightSkillSlot)
  if target_skill_cur_cnt >= target_skill_max_cnt then
    text = ui.get_text("npcfunc|equip_ridepet_skill_add_full")
    return text, money, enable
  end
  local material_info = w_equip_material.info
  local material_skill_idx = ui_npcfunc.ui_ridepet_cmn.find_skill_idx(material_info, skill_id)
  local material_level = material_info:item_get_ridepet_skill_level(material_skill_idx)
  local skill_add_excel = bo2.gv_equip_ridepet_skill_add:find(material_level)
  if skill_add_excel == nil then
    return text, money, enable
  end
  local arg = sys.variant()
  arg:set("percent", skill_add_excel.nPercent[target_skill_cur_cnt])
  text = sys.mtf_merge(arg, ui.get_text("npcfunc|equip_ridepet_skill_add_text"))
  money = skill_add_excel.nMoney[target_skill_cur_cnt]
  enable = true
  return text, money, enable
end
function on_update_preview()
  local text, money, enable = get_preview_money_enable()
  w_label_preview.text = text
  w_money.money = money
  w_btn_ok.enable = enable
end
function on_material_mouse(card, msg, pos, wheel)
  if msg ~= ui.mouse_lbutton_click then
    return
  end
  local card_skill = card:search("skill")
  local info = card_skill.info
  if info == nil then
    return
  end
  if info.card_lock == true then
    return
  end
  if w_equip_target.info == nil or w_equip_material.info == nil then
    return
  end
  ui_npcfunc.ui_ridepet_cmn.select_skill(w_equip_material, card_skill)
  on_update_preview()
end
function on_btn_ok()
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_RidePetWeaponAddSkill)
  v:set64(packet.key.item_key, w_equip_target.info.only_id)
  v:set(packet.key.item_key1, w_equip_material.info.only_id)
  local skill_id = ui_npcfunc.ui_ridepet_cmn.get_select_skill_id(w_equip_material)
  v:set(packet.key.skill_id, skill_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  ui_npcfunc.ui_ridepet_cmn.clear(w_equip_target)
  ui_npcfunc.ui_ridepet_cmn.clear(w_equip_material)
  w_label_preview.text = ""
end
