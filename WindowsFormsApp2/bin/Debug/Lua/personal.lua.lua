local ui_tab = ui_widget.ui_tab
function insert_tab(name, x)
  local btn_uri = "$frame/personal/common.xml"
  local btn_sty = "common_tab_btn"
  local page_uri = "$frame/personal/" .. name .. ".xml"
  local page_sty = name
  ui_tab.insert_suit(w_personal, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_personal, name)
  btn.name = name
  btn.tip.text = ui.get_text("personal|title_" .. name)
  local page = ui_tab.get_page(w_personal, name)
  page.name = name
  btn:search("tab_pic").irect = ui.rect(x, 0, x + 41, 168)
  btn:insert_on_press(on_tab_press, "ui_personal.on_tab_press")
end
function on_tab_press(btn)
  if btn.name == L("repute") then
    ui_personal.ui_repute.update_recommend()
  end
end
function item_rbutton_tip(info)
  local excel = info.excel
  local ptype = excel.ptype
  if ptype ~= nil then
    local group = ptype.group
    if group == bo2.eItemGroup_Equip or group == bo2.eItemGroup_Bag or group == bo2.eItemGroup_Avata then
      if ptype.equip_slot >= bo2.eItemSlot_RidePetBegin and ptype.equip_slot < bo2.eItemSlot_RidePetEnd then
        return nil
      end
      local identify_type = info:get_identify_state()
      if identify_type == bo2.eIdentifyEquip_Ready or identify_type == bo2.eIdentifyEquip_Countine then
        return ui.get_text("item|rbutton_identify")
      else
        return ui.get_text("common|rclick_equip")
      end
    end
  end
  local type = excel.type
  if type ~= nil and type == bo2.eItemType_EmptySeriesBook then
    return ui.get_text("common|rclick_use")
  end
  local puse = excel.iuse
  if puse ~= nil and puse.use_limit ~= 2 then
    return ui.get_text("common|rclick_use")
  end
  return nil
end
function item_rbutton_check(info)
  local txt = item_rbutton_tip(info)
  return txt ~= nil
end
function item_rbutton_use(info)
  ui_item.use_item_bag(info)
end
local enable_sub_page_sound = false
function on_visible(ctrl, vis)
  ui_widget.on_border_visible(ctrl, vis)
  ui_widget.on_esc_stk_visible(ctrl, vis)
  ui_tab.show_page(w_personal, "equip", true)
end
function on_init(ctrl)
  ui_tab.clear_tab_data(w_personal)
  insert_tab("equip", 0)
  insert_tab("title", 210)
  insert_tab("repute", 42)
  insert_tab("match", 84)
  ui_tab.show_page(w_personal, "equip", true)
  ui_tab.set_button_sound(w_personal, 592)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
function on_close(ctrl)
  ui_personal.w_personal.visible = false
end
function on_click_view_title_trait()
  ui_personal.ui_title.on_click_view_title_trait()
end
