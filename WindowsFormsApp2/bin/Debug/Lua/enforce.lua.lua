local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
function do_product_update()
  w_btn_enforce.enable = false
  local card_equip = w_cell_equip:search("card")
  local info_equip = card_equip.info
  if info_equip == nil then
    return
  end
  local card_tool = w_cell_tool:search("card")
  local count = ui.item_get_count(card_tool.excel_id, true)
  if count > 0 then
    w_btn_enforce.enable = true
  end
end
function post_product_update()
  w_main:insert_post_invoke(do_product_update, "ui_npcfunc.ui_enforce.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  post_product_update()
end
function getequipslot(type)
  local n = bo2.gv_item_type:find(type)
  if n ~= nil then
    return n.equip_slot
  end
  return 0
end
function get_equip_enforce(info)
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
    return true
  end
  if ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
    return true
  end
  if ptype.id == bo2.eItemtype_Enforce then
    return true
  end
  return false
end
function get_enforce_limit(info, id)
  local excel = bo2.gv_enforce_light:find(id)
  local cur_count = info:get_data_8(bo2.eItemByte_EnforceAcount)
  local one_count = excel.acount
  local finel_count = cur_count
  if info:get_data_8(bo2.eItemByte_EnforceLvl) == 2 then
    finel_count = cur_count + one_count
  end
  if finel_count > excel.a_h_limit then
  end
  local mix = excel.r_l_limit1 + finel_count
  if mix > excel.t_h_limit then
    mix = excel.t_h_limit
  end
  local r_h_limit = math.max(excel.r_h_limit1, excel.r_h_limit2, excel.r_h_limit3, excel.r_h_limit4)
  local max = r_h_limit + finel_count
  if max > excel.t_h_limit then
    max = excel.t_h_limit
  end
  return max, mix
end
function on_card_chg(card, onlyid, info)
  ui_cmn.succ_rate_set(w_low_limit, 0)
  ui_cmn.succ_rate_set(w_high_limit, 0)
  ui_cmn.money_set(w_money, 0)
  if info == nil then
    return
  end
  if w_cell_equip.info and w_cell_tool.info then
    w_btn_enforce.enable = true
  else
    return
  end
  local enforcelvl = w_cell_equip.info:get_data_8(bo2.eItemByte_EnforceLvl)
  if enforcelvl == 1 then
    return
  end
  local enf_id = math.floor((w_cell_equip.info.excel.reqlevel + 10) / 10)
  local enf = bo2.gv_equip_enforce:find(enf_id)
  if enf == nil then
    return
  end
  local tool = 0
  local tool_ok = false
  for i = enf.tool.size - 1, 0, -1 do
    if w_cell_tool.info ~= nil and enf.tool[i] == w_cell_tool.info.excel_id then
      tool_ok = true
      break
    end
  end
  if tool_ok == false then
    return
  end
  local light_id = w_cell_tool.info.excel.datas[0]
  ui.log("light_id %s", light_id)
  local light_excel = bo2.gv_enforce_light:find(light_id)
  if light_id == nil then
    return
  end
  local max, mix = get_enforce_limit(w_cell_equip.info, light_id)
  ui.log("max %s min %s", max, mix)
  ui_cmn.succ_rate_set(w_low_limit, mix / 100)
  ui_cmn.succ_rate_set(w_high_limit, max / 100)
  ui_cmn.money_set(w_money, enf.money)
end
function on_equip_change(card)
  post_product_update()
  if sys.check(w_tool_quick_buy) then
    w_tool_quick_buy.visible = false
    if card.info ~= nil then
      local enforce_id = math.floor((card.info.excel.reqlevel + 10) / 10)
      local enf_line = bo2.gv_equip_enforce:find(enforce_id)
      for k = enf_line.tool.size - 1, 0, -1 do
        local tool_id = enf_line.tool[k]
        local tool_goods_id = ui_supermarket2.shelf_quick_buy_id(tool_id)
        if tool_goods_id ~= 0 then
          w_tool_quick_buy.name = tostring(tool_goods_id)
          w_tool_quick_buy.visible = true
          break
        end
      end
    end
  end
  if sys.check(w_cell_tool) then
  end
  ui_cmn.succ_rate_set(w_succ_rate, 0)
  local info = card.info
  if info == nil then
    return
  end
  local tool_info = w_cell_tool:search("card").info
  if tool_info == nil then
    return
  end
  local enf_id = math.floor((info.excel.reqlevel + 10) / 10)
  local enf = bo2.gv_equip_enforce:find(enf_id)
  local tool = enf.tool[0]
  local tool_ok = false
  for i = enf.tool.size - 1, 0, -1 do
    if tool == tool_info.excel_id then
      tool_ok = true
      break
    end
  end
  if tool_ok == false then
    return
  end
  w_btn_enforce.enable = true
end
function on_equip_card_mouse(ctrl, msg)
  if msg ~= ui.mouse_rbutton_down then
    return
  end
  ui_cell.clear(w_cell_tool.parent.parent)
end
function on_tool_change(card)
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
  ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|enforce_rclick_to_clear"), ui_tool.cs_tip_color_operation)
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_enforce_confirm(msg)
  if msg.result == 0 then
    return
  end
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  local info1 = w_cell_tool:search("card").info
  if info1 == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_EnforceEquip)
  v:set64(packet.key.item_key, info.only_id)
  v:set64(packet.key.item_key1, info1.only_id)
  if w_money:search("rmbchk").check then
    v:set(packet.key.rmb_amount, 1)
  end
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function on_enforce_click()
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  local info1 = w_cell_tool:search("card").info
  if info1 == nil then
    return
  end
  local enforcelvl = w_cell_equip.info:get_data_8(bo2.eItemByte_EnforceLvl)
  if enforcelvl == 2 then
    local msg = {
      callback = on_enforce_confirm,
      btn_confirm = true,
      btn_cancel = true,
      modal = true
    }
    msg.title = ui.get_text("npcfunc|enforce_confirm_title")
    msg.text = ui.get_text("npcfunc|enforce_note")
    ui_widget.ui_msg_box.show_common(msg)
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_EnforceEquip)
  v:set64(packet.key.item_key, info.only_id)
  v:set64(packet.key.item_key1, info1.only_id)
  if w_money:search("rmbchk").check then
    v:set(packet.key.rmb_amount, 1)
  end
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  ui_cell.clear(w_cell_equip.parent.parent)
  ui_cell.clear(w_cell_tool.parent.parent)
end
function on_tool_quick_buy(btn)
  ui_supermarket2.shelf_singleBuy(btn)
end
function on_visible(w, vis)
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
  ui_cell.clear(w_cell_equip.parent.parent)
  ui_cell.clear(w_cell_tool.parent.parent)
  w_btn_enforce.enable = false
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|enforce_rclick_to_place")
end
function item_rbutton_check(info)
  local enf = get_equip_enforce(info)
  return enf
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
  if ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
    ui_cell.drop(w_cell_equip, info)
  end
  if ptype.id == bo2.eItemtype_Enforce then
    ui_cell.drop(w_cell_tool, info)
  end
end
function on_init(ctrl)
  ui_cmn.succ_rate_set(w_succ_rate, 0)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  w_cell_tool:insert_on_item_only_id(on_card_chg, "ui_enforce.on_card_chg")
  w_cell_equip:insert_on_item_only_id(on_card_chg, "ui_enforce.on_card_chg")
end
