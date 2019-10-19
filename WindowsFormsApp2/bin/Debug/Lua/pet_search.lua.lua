g_select_pet = nil
function on_pet_breed_search()
  ui_pet.send_open_breed_search()
end
function is_exist(pet_only_id)
  local size = w_pet_search_list.item_count
  for i = 0, size - 1 do
    local item = w_pet_search_list:item_get(i)
    local only_id = item:search("only_id").text
    if pet_only_id == only_id then
      return true
    end
  end
  return false
end
function insert_item(pet_only_id, left_time)
  if is_exist(pet_only_id) then
    return
  end
  local pet = ui.pet_find(pet_only_id)
  if pet == nil then
    return
  end
  insert_pet_search_item(pet, left_time)
end
function get_pet_index(pet_only_id)
  local num = ui_pet.get_pet_num()
  for i = 0, num - 1 do
    local pet = ui.get_pet_by_index(i, bo2.ePetBox_Player)
    if pet.only_id == pet_only_id then
      return i
    end
  end
  return nil
end
c_unfetch_able = L("FF756060")
c_fetch_able = L("FFFFFFFF")
function is_exist_fetch(only_id)
  local size = w_pet_fetch_list.item_count
  for i = 0, size - 1 do
    local item = w_pet_fetch_list:item_get(i)
    local parent_only_id = item:search("parent_only_id").text
    if parent_only_id == only_id then
      return true
    end
  end
  return false
end
function insert_pet_fetch_item(only_id, fetch_able)
  if is_exist_fetch(only_id) then
    return
  end
  local item_file = L("$frame/pet/pet_search.xml")
  local item_style = L("fetch_item")
  local item = w_pet_fetch_list:item_append()
  item:load_style(item_file, item_style)
  item.size = ui.point(245, 25)
  local parent_only_id = item:search("parent_only_id")
  parent_only_id.text = only_id
  local parent = parent_only_id.parent
  local pet_name = item:search("pet_name")
  if fetch_able == 0 then
    pet_name.xcolor = c_unfetch_able
    parent.mouse_able = false
  else
    pet_name.xcolor = c_fetch_able
    parent.mouse_able = true
  end
end
function insert_pet_search_item(pet, left_time)
  local item_file = L("$frame/pet/pet_search.xml")
  local item_style = L("time_item")
  local item = w_pet_search_list:item_append()
  item:load_style(item_file, item_style)
  item.size = ui.point(245, 25)
  local only_id = item:search("only_id")
  only_id.text = pet.only_id
  local time = item:search("time")
  time.left_time = left_time
end
function on_card_tip_show(tip)
end
function clear_all()
  w_pet_search_list:item_clear()
  w_pet_fetch_list:item_clear()
  g_select_pet = nil
end
function set_visible(vis)
  local w = ui.find_control("$frame:pet_search")
  w.visible = vis
end
function update_fetch_item()
  local size = w_pet_fetch_list.item_count
  for i = 0, size - 1 do
    local item = w_pet_fetch_list:item_get(i)
    local select = item:search("select")
    select.visible = false
  end
end
function on_pet_fetch_item(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    update_fetch_item()
    local select = panel:search("select")
    select.visible = true
    local parent_only_id = panel:search("parent_only_id").text
    g_select_pet = parent_only_id
  end
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
  else
    ui_widget.esc_stk_pop(w)
    clear_all()
  end
end
function on_cancel_click(btn)
  set_visible(false)
end
function on_sure_click(btn)
  if g_select_pet == nil then
    ui_tool.note_insert(ui.get_text("pet|fetch_select_warning"), ui_pet.c_warning_color)
    return
  end
  local group_id = bo2.get_group_id()
  if group_id == sys.wstring(0) then
    ui_tool.note_insert(ui.get_text("pet|fetch_no_group_warning"), ui_pet.c_warning_color)
    return
  end
  ui_pet.send_fetch_baby(group_id, g_select_pet)
  set_visible(false)
end
