g_pet_only_id = nil
function bind_pet(excel_id)
  local scn = w_scn.scn
  scn:clear_obj(-1)
  local p = scn:create_obj(bo2.eScnObjKind_Pet, excel_id)
  if p == nil then
    return
  end
  scn:bind_camera(p)
end
local f_rot_factor = 0.04
function on_doll_rotl_click(btn)
  ui.log("lbutton click")
  local scn = w_scn.scn
  scn:change_angle_x(-f_rot_factor)
end
function on_doll_rotr_click(btn)
  local scn = w_scn.scn
  scn:change_angle_x(f_rot_factor)
end
function on_visible_init()
  local pet = ui.pet_find(g_pet_only_id)
  if pet == nil then
    ui.log("ni lnil nil")
    return
  end
  local excel = pet.excel
  local adult = ui.get_text("pet|pet_kind1")
  insert_stage(adult, excel.cha_id)
  local baby = ui.get_text("pet|pet_kind2")
  insert_stage(baby, excel.baby_cha_id)
  local size = excel.next_gen_cha.size
  for i = 0, size - 1 do
    local stage_t = ui.get_text(sys.format("pet|pet_stage%d", i + 1))
    local excel_id = excel.next_gen_cha[i]
    insert_stage(stage_t, excel_id)
  end
  local cur_id = pet:get_atb(bo2.eFlag_Pet_ChaID)
  set_select(pet)
end
function set_select(pet)
  local id = pet:get_atb(bo2.eFlag_Pet_ChaID)
  local kind = pet:get_atb(bo2.eFlag_Pet_Kind)
  ui.console_print(id)
  if kind == bo2.ePet_KindAdult then
    local item = w_pet_develop_list:item_get(0)
    local select = item:search("select")
    select.visible = true
    bind_pet(id)
  elseif kind == bo2.ePet_KindBaby then
    local item = w_pet_develop_list:item_get(1)
    local select = item:search("select")
    select.visible = true
    bind_pet(id)
  else
    local size = w_pet_develop_list.item_count
    for i = 2, size - 1 do
      local item = w_pet_develop_list:item_get(i)
      local select = item:search("select")
      local excel_id = item:search("excel_id").text.v_int
      if select.visible then
        select.visible = false
      end
      ui.console_print(excel_id)
      if excel_id == id then
        select.visible = true
        bind_pet(excel_id)
      end
    end
  end
end
function update_select()
  local size = w_pet_develop_list.item_count
  for i = 0, size - 1 do
    local item = w_pet_develop_list:item_get(i)
    local select = item:search("select")
    select.visible = false
  end
end
function clear_all_stage()
  w_pet_develop_list:item_clear()
  bind_pet(0)
end
function insert_stage(text, excel_id)
  local item_file = L("$frame/pet/pet_show.xml")
  local item_style = L("develop_stage")
  local item = w_pet_develop_list:item_append()
  item:load_style(item_file, item_style)
  item.size = ui.point(140, 28)
  local stage = item:search("stage")
  stage.text = text
  local id = item:search("excel_id")
  id.text = excel_id
end
function set_visible(vis, pet_only_id)
  local w = ui.find_control("$frame:pet_show")
  w.visible = vis
  if vis == true then
    g_pet_only_id = pet_only_id
    on_visible_init()
  end
end
function on_stage_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local excel_id = panel:search("excel_id").text
    ui.log("excel_id:%d", excel_id.v_int)
    bind_pet(excel_id.v_int)
    update_select()
    local select = panel:search("select")
    select.visible = true
  end
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
  else
    ui_widget.esc_stk_pop(w)
    clear_all_stage()
  end
end
