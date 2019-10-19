function set_money()
  local excel = bo2.gv_pet_money_consume:find(bo2.ePet_Money_ClearAbility)
  if excel == nil then
    return
  end
  w_req_money.money = excel.money
end
function clear_all()
  ui_pet.clear_data(w_hole_card)
  w_item_name.text = ""
end
function check_item(only_id)
  local info = ui.item_of_only_id(only_id)
  if info == nil then
    return false
  end
  if bo2.eItemBox_BagBeg > info.box or info.box > bo2.eItemBox_Quest then
    return false
  end
  if info.excel.type ~= bo2.eItemType_PetGenius then
    ui_tool.note_insert(ui.get_text(sys.format("common|baditem")), ui_pet.c_warning_color)
    ui.log("213")
    return false
  end
  local use_list = bo2.gv_use_list:find(info.excel.use_id)
  if use_list == nil or use_list.model ~= bo2.eUseMod_ClearPetAbility then
    ui_tool.note_insert(ui.get_text(sys.format("common|baditem")), ui_pet.c_warning_color)
    return false
  end
  return true
end
function on_card_pet_tip_show(tip)
end
function on_hole_mouse(card, msg, pos, wheel)
  local icon = card.icon
  if icon == nil then
    return
  end
  if msg == ui.mouse_rbutton_click then
    ui_pet.clear_data(card)
    w_item_name.text = ""
  end
end
function on_hole_drop(card, msg, pos, data)
  if not ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    return
  end
  if msg == ui.mouse_lbutton_down then
    if card.only_id ~= sys.wstring(0) then
      ui_pet.clear_data(card)
      w_item_name.text = ""
    end
    local only_id = data:get("only_id").v_string
    if check_item(only_id) then
      card.only_id = only_id
      local item = ui.item_of_only_id(only_id)
      local excel = bo2.gv_item_list:find(item.excel_id)
      w_item_name.text = excel.name
      item:insert_lock(bo2.eItemLock_UI)
    elseif card.only_id ~= sys.wstring(0) then
      ui_pet.clear_data(card)
      w_item_name.text = ""
      w_req_money.money = 0
    end
  end
end
function on_sure_click(btn)
  local g_select_pet = ui_pet.ui_pet_common.get_select()
  if g_select_pet == nil then
    ui_tool.note_insert(ui.get_text(sys.format("pet|pet_warning_select")), ui_pet.c_warning_color)
    return
  end
  if w_hole_card.only_id == sys.wstring(0) then
    ui_tool.note_insert(ui.get_text(sys.format("pet|pet_warning_clear_genius_item")), ui_pet.c_warning_color)
    return
  end
  ui_pet.send_pet_clear_genius(g_select_pet, w_hole_card.only_id)
  local item = ui.item_of_only_id(w_hole_card.only_id)
  if item == nil then
    ui_pet.clear_data(w_hole_card)
    w_item_name.text = ""
  end
end
function on_item_only_id(ctrl, only_id, info)
  if info == nil then
    if w_item_name ~= nil then
      w_item_name.text = ""
    end
    return
  end
  local excel = bo2.gv_item_list:find(info.excel_id)
  if excel == nil then
    return
  end
  if w_item_name ~= nil then
    w_item_name.text = excel.name
  end
end
function on_close()
  ui_pet.clear_data(w_hole_card)
  w_item_name.text = ""
end
