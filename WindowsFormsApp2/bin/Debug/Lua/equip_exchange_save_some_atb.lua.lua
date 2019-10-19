local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
function on_npcfunc_open_window(npcfunc_id)
end
function get_equip_invalid_text()
  local txt_tip = ui.get_text("npcfunc|input_require_equip_exchange")
  return txt_tip
end
function get_equip_exchange_save_some_atb_excel(excel_id)
  local excel_item = bo2.gv_equip_item:find(excel_id)
  if excel_item == nil then
    return nil
  end
  local excel
  local size_e = bo2.gv_equip_exchange_save_some_atb.size
  for i = 0, size_e - 1 do
    local tmp_excel = bo2.gv_equip_exchange_save_some_atb:get(i)
    local a_item_id = tmp_excel.a_item_id
    if a_item_id == excel_id then
      excel = tmp_excel
      return excel
    end
  end
  return excel
end
function clear_money()
  if sys.check(w_money0) and sys.check(w_money1) then
    ui_cmn.money_set(w_money0, 0)
    ui_cmn.money_set(w_money1, 0)
    w_money0.visible = true
    w_money1.visible = false
  end
end
function do_product_update()
  clear_money()
  if not sys.check(w_btn_mk) then
    return
  end
  w_btn_mk.enable = false
  ui_cell.clear(w_cell_pdt_pre.parent.parent)
  w_desc:search("box").mtf = ui.get_text("npcfunc|info_desc_equip_exchange_save_some_atb")
  local card_equip = w_cell_equip:search("card")
  if card_equip.excel_id == 0 then
    ui_cell.clear(w_cell_equip.parent.parent)
    ui_cell.clear(w_cell_tool1.parent.parent)
    ui_cell.clear(w_cell_tool2.parent.parent)
    return
  end
  local card_tool1 = w_cell_tool1:search("card")
  local excel = get_equip_exchange_save_some_atb_excel(card_equip.excel_id)
  ui_cell.set(w_cell_tool1.parent.parent, excel.reg_id[0], excel.reg_num[0])
  local card_tool2 = w_cell_tool2:search("card")
  ui_cell.set(card_tool2.parent.parent, excel.reg_id[1], excel.reg_num[1])
  local pdt_id = excel.p_item_id
  if pdt_id == 0 then
    return
  end
  ui_cell.set(w_cell_pdt_pre.parent.parent, pdt_id)
  local money_type = excel.money_type
  local wmoney = {}
  if money_type == 0 then
    w_money0.visible = true
    w_money1.visible = false
    ui_cmn.money_set(w_money0, excel.money)
  elseif money_type == 1 then
    w_money0.visible = false
    w_money1.visible = true
    ui_cmn.money_set(w_money1, excel.money)
  end
  if excel.text_id ~= nil and excel.text_id ~= 0 then
    local tip_x = bo2.gv_text:find(excel.text_id)
    if tip_x ~= nil and tip_x.text.empty == false then
      w_desc:search("box").mtf = tip_x.text
    end
  end
  local cur_cnt0 = ui.item_get_count(excel.reg_id[0], true)
  local cur_cnt1 = ui.item_get_count(excel.reg_id[1], true)
  if cur_cnt0 < excel.reg_num[0] or cur_cnt1 < excel.reg_num[1] then
    return
  end
  w_btn_mk.enable = true
end
function post_product_update()
  w_main:insert_post_invoke(do_product_update, "ui_npcfunc.ui_equip_exchange_save_some_atb.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  post_product_update()
end
function on_equip_change(card)
  do_product_update()
end
function check_drop(info)
  if info.box < bo2.eItemBox_BagBeg or info.box >= bo2.eItemBox_BagEnd then
    local txt = ui.get_text("npcfunc|only_item_from_bag")
    ui_tool.note_insert(txt, "FF0000")
    return false
  end
  local txt_tip = get_equip_invalid_text()
  local excel = get_equip_exchange_save_some_atb_excel(info.excel_id)
  if excel == nil or excel.disable == 1 then
    ui_tool.note_insert(txt_tip, "FF0000")
    return false
  end
  return true
end
function on_equip_drop(pn, msg, pos, data)
  if ui_cell.check_drop(pn, msg, pos, data) == false then
    return
  end
  local card = pn:search("card")
  local info = ui.item_of_only_id(data:get("only_id"))
  if not check_drop(info) then
    return
  end
  ui_cell.drop(pn, info)
end
function item_rbutton_use(info)
  local card_equip = w_cell_equip:search("card")
  if not check_drop(info) then
    return
  end
  ui_cell.drop(w_cell_equip, info)
end
function on_med_card_count()
  do_product_update()
end
function on_equip_card_mouse(ctrl, msg)
end
function on_fix_card_mouse(ctrl, msg)
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
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|manuf_rclick_to_clear"), ui_tool.cs_tip_color_operation)
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_tip_show_product(tip)
  local card_base = w_cell_equip:search(L("card"))
  if sys.check(card_base) ~= true then
    return false
  end
  local info_base = card_base.info
  if sys.check(info_base) ~= true then
    return false
  end
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  local excel_exchange = get_equip_exchange_save_some_atb_excel(card_base.excel_id)
  if excel_exchange == nil then
    return
  end
  local save_enforce = excel_exchange.save_enforce
  local save_recognized = excel_exchange.save_recognized
  local save_ident = excel_exchange.save_ident
  local save_gem = excel_exchange.save_gem
  local save_gem_holes = excel_exchange.save_gem_holes
  local save_enchant = excel_exchange.save_enchant
  local copy_byte_enforce = {}
  copy_byte_enforce[bo2.eItemByte_EnforceFlagOldNew] = 1
  copy_byte_enforce[bo2.eItemByte_EnforceID] = 1
  copy_byte_enforce[bo2.eItemByte_EnforceCounted] = 1
  copy_byte_enforce[bo2.eItemByte_EnforceMaxCount] = 1
  copy_byte_enforce[bo2.eItemByte_EnforcePre] = 1
  local copy_uint64_enforce = {}
  copy_uint64_enforce[bo2.eItemUInt64_EnforceData0] = 1
  copy_uint64_enforce[bo2.eItemUInt64_EnforceData1] = 1
  local copy_byte_recognized = {}
  copy_byte_recognized[bo2.eItemByte_RecognizedMaxCount] = 1
  copy_byte_recognized[bo2.eItemByte_RecognizedCounted] = 1
  local copy_uint32_recognized = {}
  copy_uint32_recognized[bo2.eItemUInt32_RecognizedMasterTimes] = 1
  copy_uint32_recognized[bo2.eItemUInt32_RecognizedMasterVal] = 1
  local copy_uint32_ident = {}
  for i = bo2.eItemUInt32_IdentTraitBeg, bo2.eItemUInt32_IdentTraitEnd - 1 do
    copy_uint32_ident[i] = 1
  end
  local copy_uint32_enchant = {}
  for i = bo2.eItemUInt32_EnchantBeg, bo2.eItemUInt32_EnchantEnd - 1 do
    copy_uint32_enchant[i] = 1
  end
  local copy_byte_gem_holes = {}
  copy_byte_gem_holes[bo2.eItemByte_Holes] = 1
  copy_byte_gem_holes[bo2.eItemByte_HolesTotle] = 1
  local copy_uint32_gem = {}
  for i = bo2.eItemUInt32_GemBeg, bo2.eItemUInt32_GemEnd - 1 do
    copy_uint32_gem[i] = 1
  end
  local info = {
    name = excel.name,
    plootlevel_star = bo2.gv_lootlevel:find(excel.lootlevel),
    get_data_8 = function(info, val)
      if val == bo2.eItemByte_Star then
        return info_base:get_data_8(bo2.eItemByte_Star)
      end
      if val == bo2.eItemByte_Bound then
        return info_base:get_data_8(bo2.eItemByte_Bound)
      end
      if save_recognized == 1 and copy_byte_recognized[val] == 1 then
        local v = 0
        v = info_base:get_data_8(val)
        return v
      end
      if save_enforce == 1 and copy_byte_enforce[val] == 1 then
        if val == bo2.eItemByte_EnforceFlagOldNew then
          return 0
        end
        if val == bo2.eItemByte_EnforcePre then
          return ui.item_get_total_enforce_data(info_base)
        end
        local v = 0
        v = info_base:get_data_8(val)
        return v
      end
      if save_gem_holes == 1 and copy_byte_gem_holes[val] == 1 then
        local v = 0
        v = info_base:get_data_8(val)
        return v
      end
      return 0
    end,
    star = info_base:get_data_8(bo2.eItemByte_Star),
    get_data_s = function()
      return L("")
    end,
    box = bo2.eItemBox_BagBeg,
    get_data_32 = function(info, val)
      if save_recognized == 1 and copy_uint32_recognized[val] == 1 then
        local v = 0
        v = info_base:get_data_32(val)
        return v
      end
      if save_enchant == 1 and copy_uint32_enchant[val] == 1 then
        local v = 0
        v = info_base:get_data_32(val)
        return v
      end
      if save_ident == 1 and copy_uint32_ident[val] == 1 then
        local v = 0
        v = info_base:get_data_32(val)
        return v
      end
      if save_gem == 1 and copy_uint32_gem[val] == 1 then
        local v = 0
        v = info_base:get_data_32(val)
        return v
      end
      if val == bo2.eItemUInt32_CurWearout or val == bo2.eItemUInt32_MaxWearout then
        return excel.consume_par
      end
      return 0
    end,
    get_identify_state = function()
      local identify_state = bo2.eIdentifyEquip_Finish
      if save_ident == 0 then
        identify_state = bo2.eIdentifyEquip_Countine
      end
      return identify_state
    end
  }
  ui_tool.ctip_make_item(stk, excel, info, card)
  local stk_use
  local ptype = excel.ptype
  if ptype ~= nil then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_btn_mk_click()
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_EquipExchangeSaveSomeAtb)
  v:set64(packet.key.item_key, info.only_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function on_visible(w, vis)
  clear_money()
  ui_cell.clear(w_cell_equip.parent.parent)
  ui_cell.clear(w_cell_tool1.parent.parent)
  ui_cell.clear(w_cell_tool2.parent.parent)
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
  w_btn_mk.enable = false
  w_desc:search("box").mtf = ui.get_text("npcfunc|info_desc_equip_exchange_save_some_atb")
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|manuf_rclick_to_place")
end
function item_rbutton_check(info)
  local card_equip = w_cell_equip:search("card")
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel == nil then
    return false
  end
  return true
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
