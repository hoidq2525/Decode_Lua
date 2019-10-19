w_hole_card = nil
local ui_tab = ui_widget.ui_tab
g_item_id = 53911
g_select_skill = 0
function set_money()
  local excel = bo2.gv_pet_money_consume:find(bo2.ePet_Money_OpenHole)
  if excel == nil then
    return
  end
  w_req_money_zb.money = excel.money
  w_req_money_fight.money = excel.money
end
function set_item()
  local info = ui.item_of_excel_id(g_item_id, bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
  if info == nil then
    w_item_card.excel_id = g_item_id
    return
  end
  w_hole_card = info.only_id
  w_item_card.only_id = info.only_id
  w_item_card.excel_id = g_item_id
  w_item_name.text = info.excel.name
end
function on_fight_click(btn)
  if w_fight_panel.visible == true then
    return
  end
  w_fight_panel.visible = true
  w_zb_panel.visible = false
  local pet = ui_pet.ui_pet_common.get_select()
  if pet ~= nil then
    ui_pet.ui_pet_common.set_pet_hole_select(0)
    g_select_skill = 0
  end
end
function on_zb_click(btn)
  if w_zb_panel.visible == true then
    return
  end
  w_fight_panel.visible = false
  w_zb_panel.visible = true
  local pet = ui_pet.ui_pet_common.get_select()
  if pet ~= nil then
    ui_pet.ui_pet_common.set_pet_hole_select(1)
    g_select_skill = 1
  end
end
function get_select_skill_kind()
  if w_fight_panel.visible == true then
    return 0
  end
  return 1
end
function on_init()
  w_fight_btn.check = true
  w_zb_btn.check = false
end
function set_open_hole_odds(pet_only_id)
  local base_odds = 0
  local up_odds = 0
  if pet_only_id ~= nil then
    base_odds = ui.get_base_odds(pet_only_id)
    up_odds = ui.get_up_odds(pet_only_id)
  end
  local final_odds = base_odds + up_odds
  ui.log("base:" .. base_odds .. "up: " .. up_odds)
  w_base_success.text = sys.format("%.2f%s", base_odds * 100, "%")
  local star = w_base_success.parent:search("star")
  star.dx = 80 * base_odds
  w_up_success.text = sys.format("%.2f%s", up_odds * 100, "%")
  star = w_up_success.parent:search("star")
  star.dx = 80 * up_odds
  w_final_success.text = sys.format("%.2f%s", final_odds * 100, "%")
  star = w_final_success.parent:search("star")
  star.dx = 80 * final_odds
  local kind = get_select_skill_kind()
  if kind == nil then
    return
  end
  if pet_only_id ~= nil then
    ui.log("kind:%d", kind)
    ui_pet.ui_pet_common.set_pet_hole_select(kind)
  else
    ui_pet.ui_pet_common.set_hole_no_select()
  end
end
function set_visible(vis)
  local w = ui.find_control("$frame:open_hole")
  w.visible = vis
end
function insert_pet_item()
  local item_file = L("$frame/pet/open_hole.xml")
  local item_style = L("pet_item")
  local item = w_pet_select_list:item_append()
  item:load_style(item_file, item_style)
  item.size = ui.point(200, 40)
  local card = item:search("card")
  card.index = w_pet_select_list.item_count - 1
  local pet = ui.pet_find(card.only_id)
  local name = item:search("name")
  local size = w_pet_select_list.item_count
  name.text = pet.name
  local level = item:search("level")
  level.text = sys.format("%s%d", ui.get_text("pet|name_atb_level"), pet:get_atb(bo2.eFlag_Pet_Level))
  local growth = item:search("growth")
  growth.text = sys.format("%s%d", ui.get_text("pet|pet_growth"), pet:get_atb(bo2.eFlag_Pet_GenGrowth))
end
function clear_all()
  w_item_card.only_id = 0
  local info = ui.item_of_excel_id(g_item_id, bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
  if info == nil then
    return
  end
end
function on_pet_item_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local select = panel:search("select")
    select.visible = true
    local card = panel:search("card")
  end
end
function on_card_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local parent = card.parent
    local select = parent:search("select")
    select.visible = true
  end
end
function on_observable(vis)
end
function on_esc_stk_visible(w, vis)
end
function on_card_pet_tip_show()
end
function on_hole_mouse(card, msg, pos, wheel)
end
function check_item(only_id)
  local info = ui.item_of_only_id(only_id)
  if info == nil then
    return false
  end
  if bo2.eItemBox_BagBeg > info.box or info.box > bo2.eItemBox_Quest then
    return false
  end
  ui.log(info.excel.type)
  ui.log("sdf" .. bo2.eItemType_PetHole)
  if info.excel.type ~= bo2.eItemType_PetHole then
    ui_tool.note_insert(ui.get_text("common|baditem"), ui_pet.c_warning_color)
    return false
  end
  return true
end
function on_hole_drop(card, msg, pos, data)
end
function on_cancel_click(btn)
  set_visible(false)
end
function on_sure_click(btn)
  local g_select_pet = ui_pet.ui_pet_common.get_select()
  if g_select_pet == nil then
    ui_tool.note_insert(ui.get_text("pet|pet_warning_select"), ui_pet.c_warning_color)
    return
  end
  ui.log(w_hole_card)
  local info = ui.item_of_excel_id(g_item_id, bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
  if info == nil then
    ui_tool.note_insert(ui.get_text("pet|pet_warning_hole_item"), ui_pet.c_warning_color)
    return
  end
  ui_pet.send_open_hole(g_select_pet, info.only_id, 0, g_select_skill, 0)
end
