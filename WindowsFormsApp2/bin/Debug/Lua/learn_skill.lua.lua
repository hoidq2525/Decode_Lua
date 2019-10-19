function set_money()
  local item = ui.item_of_only_id(w_book_card.only_id)
  if item == nil then
    return
  end
  local money = ui.pet_learn_skill_money(item.excel_id)
  w_req_money.money = money
end
function clear_all()
  ui_pet.clear_data(w_book_card)
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
  if info.excel.type ~= bo2.eItemType_PetLearnSkill then
    ui_tool.note_insert(ui.get_text("common|baditem"), ui_pet.c_warning_color)
    return false
  end
  return true
end
function on_skill_book_drop(card, msg, pos, data)
  if not ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    return
  end
  if msg == ui.mouse_lbutton_down then
    local only_id = data:get("only_id").v_string
    local item = ui.item_of_only_id(only_id)
    if check_item(only_id) then
      if card.only_id ~= 0 then
        ui_pet.clear_data(card)
      end
      card.only_id = only_id
      local excel = bo2.gv_item_list:find(item.excel_id)
      w_item_name.text = excel.name
      set_money()
      item:insert_lock(bo2.eItemLock_UI)
    elseif card.only_id ~= sys.wstring(0) then
      ui_pet.clear_data(card)
      w_item_name.text = ""
      w_req_money.money = 0
    end
  end
end
function on_skill_book_mouse(card, msg, pos, wheel)
  local icon = card.icon
  if icon == nil then
    return
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_drag then
    ui.clean_drop()
    if card.info.lock > 0 then
      return
    end
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_item)
    data:set("only_id", card.only_id)
    ui.set_cursor_icon(icon.uri)
    ui.log("card.only_id" .. card.only_id)
    local function on_drop_hook(w, msg, pos, data)
      local info = card.info
      if info == nil then
        return
      end
      if msg == ui.mouse_drop_setup then
        info:insert_lock(bo2.eItemLock_Drop)
      elseif msg == ui.mouse_drop_clean then
        info:remove_lock(bo2.eItemLock_Drop)
      end
    end
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  elseif msg == ui.mouse_rbutton_click then
    ui_pet.clear_data(card)
    w_item_name.text = ""
    w_req_money.money = 0
  end
end
function on_sure_click(btn)
  local g_select_pet_id = ui_pet.ui_pet_common.get_select()
  if g_select_pet_id == nil then
    ui_tool.note_insert(ui.get_text("pet|pet_warning_select"), ui_pet.c_warning_color)
    return
  end
  if w_book_card.only_id == sys.wstring(0) then
    ui_tool.note_insert(ui.get_text("pet|pet_warning_book_item"), ui_pet.c_warning_color)
    return
  end
  ui_pet.send_learn_skill(g_select_pet_id, w_book_card.only_id)
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
function clear_item_name()
  w_item_name.text = ""
  ui_pet.clear_data(w_book_card)
end
function on_close()
  ui_pet.clear_data(w_book_card)
  w_item_name.text = ""
end
