function on_init()
end
function on_visible_init()
  clear_item()
  local num = ui_pet.get_pet_num()
  for i = 0, num - 1 do
    insert_item()
  end
end
function insert_item()
  local c_file_path = "$frame/pet/pet_train.xml"
  local c_style_name = "pet_item"
  local item = w_pet_list:item_append()
  item:load_style(c_file_path, c_style_name)
  item.size = ui.point(240, 40)
  local card = item:search("card")
  card.index = w_pet_list.item_count - 1
  local pet = ui.pet_find(card.only_id)
  local name = item:search("name")
  local size = w_pet_list.item_count
  name.text = pet.name
  local level = item:search("level")
  level.text = sys.format("%s%d", ui.get_text("pet|name_atb_level"), pet:get_atb(bo2.eFlag_Pet_Level))
  local growth = item:search("growth")
  growth.text = sys.format("%s%d", ui.get_text("pet|pet_growth"), pet:get_atb(bo2.eFlag_Pet_GenGrowth))
end
function clear_select()
  local size = w_pet_list.item_count
  for i = 0, size - 1 do
    local item = w_pet_list:item_get(i)
    local select = item:search("select")
    select.visible = false
  end
end
function set_visible(vis)
  local w = ui.find_control("$frame:pet_train")
  w.visible = vis
end
function clear_item()
  w_pet_list:item_clear()
end
function clear_all()
  clear_item()
  clear_select()
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
    on_visible_init()
  else
    ui_widget.esc_stk_pop(w)
    clear_all()
  end
end
function on_item_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    clear_select()
    local select = panel:search("select")
    select.visible = true
    local card = panel:search("card")
  end
end
function on_card_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    clear_select()
    local select = card.parent:search("select")
    select.visible = true
    g_select_pet_id = card.only_id
  end
end
function on_card_tip_show(tip)
end
function on_cancel_click(btn)
  set_visible(false)
end
function on_train_click(btn)
  local g_select_pet_id = ui_pet.ui_pet_common.get_select()
  if g_select_pet_id == nil then
    ui_tool.note_insert(ui.get_text(sys.format("pet|pet_warning_select")), ui_pet.c_warning_color)
    return
  end
  local pet = ui.pet_find(g_select_pet_id)
  if pet == nil then
    return
  end
  local state = pet:get_atb(bo2.eFlag_Pet_State)
  if state == bo2.ePet_StateReproduction then
    ui_tool.note_insert(ui.get_text(sys.format("pet|pet_genius_warning")), ui_pet.c_warning_color)
    return
  end
  ui_pet.ui_pet_genius.set_visible(true, g_select_pet_id)
end
