function set_money()
  local excel = bo2.gv_pet_money_consume:find(bo2.ePet_Money_ToToy)
  if excel == nil then
    return
  end
  w_req_money.money = excel.money
end
function check_can_to_toy(pet)
  if pet == nil then
    return false
  end
  local kind = pet:get_atb(bo2.eFlag_Pet_Kind)
  if kind == bo2.ePet_KindNextGen then
    return true
  end
  return false
end
function clear_all()
  ui_pet.ui_pet_common.clear_select()
end
function on_cancel_click(btn)
  set_visible(false)
end
function on_to_toy_msg(msg)
  if msg.result == 0 then
    return
  end
  if msg.result == 1 then
    ui_pet.send_pet_to_toy(msg.only_id)
  end
  set_visible(false)
end
function on_to_toy_click(btn)
  local excel = bo2.gv_pet_money_consume:find(bo2.ePet_Money_ToToy)
  local g_select_pet = ui_pet.ui_pet_common.get_select()
  if g_select_pet == nil then
    ui_tool.note_insert(ui.get_text(sys.format("pet|pet_warning_select")), ui_pet.c_warning_color)
    return
  end
  local pet = ui.pet_find(g_select_pet)
  if check_can_to_toy(pet) == false then
    ui_tool.note_insert(ui.get_text("pet|pet_warning_cannot_totoy"), ui_pet.c_warning_color)
    return
  end
  local msg = {callback = on_to_toy_msg, only_id = g_select_pet}
  msg.text = ui.get_text("pet|pet_refine_confirm")
  ui_widget.ui_msg_box.show_common(msg)
end
function on_close_skill(btn)
  local parent = btn.parent.parent
  parent.visible = false
end
