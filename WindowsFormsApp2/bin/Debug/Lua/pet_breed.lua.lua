function set_money()
  local excel = bo2.gv_pet_money_consume:find(bo2.ePet_Money_PetBreed)
  if excel == nil then
    return
  end
  w_req_money.money = excel.money
end
function on_pet_breed()
  local group_id = bo2.get_group_id()
  ui_pet.send_open_breed(group_id)
  return nil
end
function on_sure_click(btn)
  local g_select_breed_pet = ui_pet.ui_pet_common.get_select()
  if g_select_breed_pet == nil then
    ui_tool.note_insert(ui.get_text("pet|pet_warning_select"), ui_pet.c_warning_color)
    return
  end
  local group_id = bo2.get_group_id()
  if group_id == 0 then
    ui_tool.note_insert(ui.get_text("pet|no_group"), ui_pet.c_warning_color)
    return
  end
  ui_pet.send_breed_id(g_select_breed_pet, group_id)
end
