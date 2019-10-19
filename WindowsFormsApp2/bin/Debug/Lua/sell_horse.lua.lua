function on_init()
end
function insert_horse_item(info, index)
  local is_frozen = info:get_flag(bo2.eRidePetFlagInt32_SafeFrozen)
  if is_frozen ~= 0 then
    return
  end
  local item = w_list_view:item_append()
  local file_name = "$gui/frame/npcfunc/sell_horse.xml"
  local style_name = "horse_info"
  item:load_style(file_name, style_name)
  item:search("card").grid = info.grid
  local horse_name = item:search("horse_name")
  local horse_gift = item:search("horse_gift")
  local horse_level = item:search("horse_level")
  local excel = bo2.gv_ridepet_list:find(info:get_flag(bo2.eRidePetFlagInt32_RidePetListId))
  if excel == nil then
    return
  end
  item.svar.index = index
  item.svar.horse_id = excel.id
  local star_id = info:get_flag(bo2.eRidePetFlagInt32_Star)
  local type_id = info:get_flag(bo2.eRidePetFlagInt32_Type)
  local name = ""
  local star_excel = bo2.gv_ridepet_star_init:find(star_id)
  if star_excel ~= nil then
    name = name .. star_excel.name
  end
  local type_excel = bo2.gv_ridepet_type_init:find(type_id)
  if type_excel ~= nil then
    if type_excel.nNoGrow ~= 0 then
      name = type_excel.name
    else
      name = name .. type_excel.name
    end
  end
  local level = info:get_flag(bo2.eRidePetFlagInt32_Level)
  horse_name.text = excel.name
  horse_gift.text = name
  horse_level.text = L("Lv:") .. level
end
function on_visible(w, vis)
  ui_widget.on_border_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis then
    local quest_id = bo2.gv_define:find(1077).value.v_int
    local quest_info = ui.quest_find(quest_id)
    if quest_info == nil then
    end
    w_list_view:item_clear()
    local horse_count = ui.get_ride_count()
    for i = 0, horse_count - 1 do
      local info = ui_ridepet.find_info_from_pos(i)
      if info ~= nil then
        insert_horse_item(info, i)
      end
    end
  end
  local item = w_list_view.item_sel
  if item == nil then
    btn_confirm.enable = false
  else
    btn_confirm.enable = true
  end
end
function horse_highlight(ctrl, is_highlight)
  local hl = ctrl:search("high_light")
  if hl ~= nil then
    hl.visible = is_highlight
  end
end
function on_item_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_enter then
    horse_highlight(ctrl, true)
  elseif msg == ui.mouse_leave then
    horse_highlight(ctrl, false)
  elseif msg == ui.mouse_lbutton_dbl then
    on_confirm_click(nil)
  end
end
function is_right_horse(req_id, horse_id)
  local excel = bo2.gv_quest_horsegroup:find(req_id)
  if excel == nil then
    return false
  end
  for i = 0, excel.list.size - 1 do
    if horse_id == excel.list[i] then
      return true
    end
  end
  return false
end
function on_confirm_click()
  local item = w_list_view.item_sel
  if item == nil then
    return
  end
  local info = ui_ridepet.find_info_from_pos(item.svar.index)
  local quest_id = bo2.gv_define:find(1077).value.v_int
  local quest_info = ui.quest_find(quest_id)
  if quest_info == nil then
    ui_tool.note_insert(ui.get_text("quest|sell_horse_no_quest_warning"), "FFFF0000")
    return
  end
  local function on_confirm(msg)
    if msg.result == 0 then
      return
    end
    local var = sys.variant()
    var:set(packet.key.ridepet_onlyid, info.onlyid)
    var:set(packet.key.cmn_id, item.svar.horse_id)
    bo2.send_variant(packet.eCTS_UI_SellHorse, var)
  end
  local info = ui_ridepet.find_info_from_pos(item.svar.index)
  local excel = bo2.gv_ridepet_list:find(info:get_flag(bo2.eRidePetFlagInt32_RidePetListId))
  if excel == nil then
    return
  end
  local star_id = info:get_flag(bo2.eRidePetFlagInt32_Star)
  local type_id = info:get_flag(bo2.eRidePetFlagInt32_Type)
  local name = ""
  local star_excel = bo2.gv_ridepet_star_init:find(star_id)
  if star_excel ~= nil then
    name = name .. star_excel.name
  end
  local type_excel = bo2.gv_ridepet_type_init:find(type_id)
  if type_excel ~= nil then
    if type_excel.nNoGrow ~= 0 then
      name = type_excel.name
    else
      name = name .. type_excel.name
    end
  end
  local msg = {
    callback = on_confirm,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui_widget.merge_mtf({
    horse_name = excel.name,
    horse_gift = name
  }, ui.get_text("quest|sell_horse_msg"))
  ui_widget.ui_msg_box.show_common(msg)
end
function on_cancel_click()
  w_main.visible = false
end
function on_item_sel(item, is_select)
  item:search("select_high_light").visible = is_select
  btn_confirm.enable = true
end
