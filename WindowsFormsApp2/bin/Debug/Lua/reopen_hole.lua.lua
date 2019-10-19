g_select_skill_index = nil
g_item_id = 53921
function set_index(val)
  g_select_skill_index = val
end
function on_init()
end
function set_money()
  local excel = bo2.gv_pet_money_consume:find(bo2.ePet_Money_OpenHole)
  if excel == nil then
    return
  end
  w_req_money.money = excel.money
end
function set_item()
  local info = ui.item_of_excel_id(g_item_id, bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
  if info == nil then
    w_hole_card.excel_id = g_item_id
    return
  end
  w_hole_card.only_id = info.only_id
  w_hole_card.excel_id = g_item_id
  w_item_name.text = info.excel.name
end
function clear_all()
  ui_pet.ui_pet_common.set_hole_no_select()
  w_hole_card.only_id = 0
  w_item_name.text = ""
  g_select_skill_index = nil
  local info = ui.item_of_excel_id(g_item_id, bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
  if info == nil then
    return
  end
end
function check_item(only_id)
  local info = ui.item_of_only_id(only_id)
  if info == nil then
    return false
  end
  if bo2.eItemBox_BagBeg > info.box or info.box > bo2.eItemBox_Quest then
    return false
  end
  if info.excel.type ~= bo2.eItemType_PetHole then
    ui_tool.note_insert(ui.get_text(sys.format("common|baditem")), ui_pet.c_warning_color)
    return false
  end
  return true
end
function on_hole_mouse(card, msg, pos, wheel)
  local icon = card.icon
  if icon == nil then
    return
  end
  if msg == ui.mouse_rbutton_click then
  end
end
function on_hole_drop(card, msg, pos, data)
end
function set_skill_index(idx)
  g_select_skill_index = idx
end
function on_sure_click(btn)
  local g_select_pet = ui_pet.ui_pet_common.get_select()
  if g_select_pet == nil then
    ui_tool.note_insert(ui.get_text(sys.format("pet|pet_warning_select")), ui_pet.c_warning_color)
    return
  end
  if g_select_skill_index == nil then
    ui_tool.note_insert(ui.get_text(sys.format("pet|pet_warning_skill_index")), ui_pet.c_warning_color)
    return
  end
  local info = ui.item_of_excel_id(g_item_id, bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
  if info == nil then
    ui_tool.note_insert(ui.get_text(sys.format("pet|pet_warning_reopen_hole_item")), ui_pet.c_warning_color)
    return
  end
  ui_pet.send_open_hole(g_select_pet, info.only_id, 1, 1, g_select_skill_index)
end
