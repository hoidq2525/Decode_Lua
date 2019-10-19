g_loyal = nil
g_func = nil
g_info = nil
g_item_only_id = nil
function on_pet_update(pet_info)
  local size = g_pet_list.item_count
  for i = 0, size - 1 do
    local item = g_pet_list:item_get(i)
    if pet_info.only_id == item.svar.id then
      item:search("name").text = pet_info.name
      item:search("level").text = ui.get_text("pet|name_atb_level") .. pet_info:get_atb(bo2.eFlag_Pet_Level)
      local gen_atb = {
        value = bo2.eFlag_Pet_GenGrowth
      }
      item:search("star").dx = 16 * ui_pet.get_star_num(pet_info, gen_atb) / 2
      item:search("star_max").dx = 16 * ui_pet.get_star_max(pet_info, gen_atb) / 2
    end
  end
end
function insert_item(idx)
  local c_file_path = "$frame/pet/pet_list.xml"
  local c_style_name = "pet_item"
  local item = g_pet_list:item_append()
  item:load_style(c_file_path, c_style_name)
  local card = item:search("card")
  card.box = bo2.ePetBox_Player
  card.index = idx
  local pet_info = ui.pet_find(card.only_id)
  item:search("name").text = pet_info.name
  item:search("level").text = ui.get_text("pet|name_atb_level") .. pet_info:get_atb(bo2.eFlag_Pet_Level)
  local gen_atb = {
    value = bo2.eFlag_Pet_GenGrowth
  }
  item:search("star").dx = 16 * ui_pet.get_star_num(pet_info, gen_atb) / 2
  item:search("star_max").dx = 16 * ui_pet.get_star_max(pet_info, gen_atb) / 2
  item.svar.id = card.only_id
end
function do_raw_update()
  g_pet_list:item_clear()
  local num = ui_pet.get_pet_num()
  for idx = 0, num - 1 do
    insert_item(idx)
  end
end
function on_init()
end
function on_close(btn)
  local select_pet = g_pet_list.item_sel
  if select_pet ~= nil then
    select_pet.selected = false
  end
  local item = ui.item_of_only_id(g_item_only_id)
  if item ~= nil then
    item:remove_lock(bo2.eItemLock_UI)
  end
  if g_info ~= nil and g_info:get("keep_show").v_int == 1 then
    return
  end
  w_main.visible = false
end
function on_pet_select(ctrl, v)
  ctrl:search("select").visible = v
end
function on_card_tip_show(tip)
end
function on_ok(btn)
  local select_pet = g_pet_list.item_sel
  if select_pet ~= nil and g_func ~= nil then
    sys.pcall(g_func, select_pet.svar.id, g_info)
  end
  on_close(btn)
end
function show_pet_list(func, data)
  if w_main.visible then
    return
  end
  w_main.visible = true
  g_func = func
  g_info = data
  if data == nil then
    g_item_only_id = 0
    return
  end
  if data:has("ok_text") then
    w_main:search("ok_btn").text = data:get("ok_text").v_string
  end
  g_item_only_id = data:get(packet.key.item_key).v_string
  local item = ui.item_of_only_id(g_item_only_id)
  if item == nil then
    return
  end
  item:insert_lock(bo2.eItemLock_UI)
end
function on_watch_click(btn)
  local leaf_item = ui_mall.find_parent(btn, L("leaf_item"))
  local only_id = leaf_item.svar.id
  ui_pet.ui_pet_info.show_info(only_id)
end
function on_pet_insert(pet_info)
  w_main:insert_post_invoke(do_raw_update, "ui_pet.ui_pet_list.do_raw_update")
end
function on_pet_remove(pet_info)
  w_main:insert_post_invoke(do_raw_update, "ui_pet.ui_pet_list.do_raw_update")
end
ui.insert_pet_on_insert(on_pet_insert, "ui_pet.ui_pet_list:on_pet_insert")
ui.insert_pet_on_remove(on_pet_remove, "ui_pet.ui_pet_list:on_pet_remove")
