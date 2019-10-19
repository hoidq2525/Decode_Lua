local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
local g_afx_num = 1
function do_product_update()
  w_btn_enchant_upgrades.enable = false
  local card_equip = w_cell_equip:search("card")
  local info_equip = card_equip.info
  if info_equip == nil then
    return
  end
  local card_tool = w_cell_tool:search("card")
  local count = ui.item_get_count(card_tool.excel_id, true)
  if count >= g_afx_num then
    w_btn_enchant_upgrades.enable = true
  end
end
function post_product_update()
  w_main:insert_post_invoke(do_product_update, "ui_npcfunc.ui_enchant_upgrades.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  post_product_update()
end
function get_equip_enchant_id(info)
  if info == 0 then
    return 0
  end
  if info.excel == 0 then
    return 0
  end
  local raw_mat_id = info:get_data_32(bo2.eItemUInt32_EnchantEquipRawExcelID)
  if raw_mat_id == 0 then
    return 0
  end
  local item_type_line = bo2.gv_item_type:find(info.excel.type)
  if item_type_line == nil then
    ui.log("ERROR!!No specific type for this item")
    return 0
  end
  local equip_slot_id = item_type_line.equip_slot
  if equip_slot_id == 0 then
    return 0
  end
  for i = 0, bo2.gv_enchant_property.size - 1 do
    local line = bo2.gv_enchant_property:get(i)
    if line.raw_item_id == raw_mat_id then
      for j = 0, line.equip_slot.size - 1 do
        if line.equip_slot[j] == equip_slot_id then
          return line.id
        end
      end
    end
  end
  return 0
end
function on_equip_change(card)
  post_product_update()
  if sys.check(w_cell_tool) then
    ui_cell.clear(w_cell_tool.parent.parent)
  end
  if sys.check(w_money) then
    ui_cmn.money_set(w_money, 0)
  end
  if card.info == nil then
    return
  end
  local enchant_id = get_equip_enchant_id(card.info)
  local enchant_line = bo2.gv_enchant_property:find(enchant_id)
  if enchant_line == nil then
    return
  end
  ui_cell.set_n(w_detail, "mat_tool", enchant_line.afx_item_id, g_afx_num)
  ui_cmn.money_set(w_money, enchant_line.afx_money)
  w_btn_enchant_upgrades.enable = true
end
function on_equip_card_tip_show(tip)
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item(stk, excel, card.info)
  local stk_use
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|enchant_upgrades_rclick_to_clear"), ui_tool.cs_tip_color_operation)
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_upgrades_click()
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_EnchantUpgrades)
  v:set64(packet.key.item_key, info.only_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function on_visible(w, vis)
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
  ui_cell.clear(w_cell_equip.parent.parent)
  ui_cell.clear(w_cell_tool.parent.parent)
  ui_cmn.money_set(w_money, 0)
  w_btn_enchant_upgrades.enable = false
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|enchant_upgrades_rclick_to_place")
end
function item_rbutton_check(info)
  local enchant_id = get_equip_enchant_id(info)
  if enchant_id == 0 or enchant_id == nil then
    return false
  else
    return true
  end
end
function item_rbutton_use(info)
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  local ptype = excel.ptype
  if ptype == nil then
    return nil
  end
  if ptype.equip_slot >= bo2.eItemSlot_EquipBeg and ptype.equip_slot <= bo2.eItemSlot_EquipEnd then
    ui_cell.drop(w_cell_equip, info)
  end
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
