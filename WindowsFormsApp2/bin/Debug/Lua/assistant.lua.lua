function check(info)
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
