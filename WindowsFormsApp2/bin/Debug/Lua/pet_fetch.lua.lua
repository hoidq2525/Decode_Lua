g_select_pet = nil
function on_pet_fetch()
  local group_id = bo2.get_group_id()
  ui_pet.send_open_fetch(group_id)
  return nil
end
function is_pet_exist(pet_only_id)
  local size = w_pet_fetch_list.item_count
  if size == 0 then
    return false
  end
  for i = 0, size - 1 do
    local item = w_pet_fetch_list:item_get(i)
    local parent = item:search("parent_only_id")
    if parent.text == pet_only_id then
      return true
    end
  end
  return false
end
function insert_item(pet_only_id, fetch_enable)
  local exist = is_pet_exist(pet_only_id)
  if exist then
    return
  end
  local item_file = L("$frame/pet/pet_fetch.xml")
  local item_style = L("item")
  local item = w_pet_fetch_list:item_append()
  item:load_style(item_file, item_style)
  item.size = ui.point(180, 20)
  local btn = item:search("item_text")
  if fetch_enable == 0 then
    btn.enable = false
  else
    btn.enable = true
  end
  local name = ui.get_text(sys.format("pet|pet_fetch_name"))
  local pet = ui.pet_find(pet_only_id)
  btn.text = sys.format("%s%s", name, pet.excel.name)
  local parent = item:search("parent_only_id")
  parent.text = pet_only_id
end
function set_visible(vis)
  local w = ui.find_control("$frame:pet_fetch")
  w.visible = vis
end
function clear_all_item()
  w_pet_fetch_list:item_clear()
end
function clear_select()
  local size = w_pet_fetch_list.item_count
  for i = 0, size - 1 do
    local item = w_pet_fetch_list:item_get(i)
    local select = item:search("select")
    select.visible = false
  end
  g_select_pet = nil
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
  else
    ui_widget.esc_stk_pop(w)
    clear_select()
    clear_all_item()
  end
end
function on_item_click(btn)
  clear_select()
  local parent = btn.parent
  local select = parent:search("select")
  select.visible = true
  local p_only_id = parent:search("parent_only_id")
  g_select_pet = p_only_id.text
end
function on_fetch_click(btn)
  if g_select_pet == nil then
    return
  end
  local group_id = bo2.get_group_id()
  if group_id == sys.wstring(0) then
    return
  end
  clear_all_item()
  ui_pet.send_fetch_baby(group_id, g_select_pet)
  set_visible(false)
end
function on_cancel_click(btn)
  set_visible(false)
end
