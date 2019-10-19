local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
local g_npcfunc_id = 0
function on_npcfunc_open_window(npcfunc_id)
  ui.log("npcfunc_id:" .. npcfunc_id)
  g_npcfunc_id = npcfunc_id
  if g_npcfunc_id == bo2.eNpcFunc_TianwuSwap then
    w_desc:search("box").mtf = ui.get_text("npcfunc|desc_tianwu_swap")
    w_lb_title.text = ui.get_text("npcfunc|title_tianwu_swap")
  elseif g_npcfunc_id == bo2.eNpcFunc_2ndWeaponSwapGaoDing then
    w_desc:search("box").mtf = ui.get_text("npcfunc|desc_fuwuqi_swap_gaoding")
    w_lb_title.text = ui.get_text("npcfunc|title_fuwuqi_swap_gaoding")
  end
end
function get_equip_type(id)
  if id >= 1 and id <= 10000 then
    return bo2.eNpcFunc_TianwuSwap
  elseif id >= 10001 and id <= 20000 then
    return bo2.eNpcFunc_2ndWeaponSwapGaoDing
  end
end
function get_equip_invalid_text()
  if g_npcfunc_id == bo2.eNpcFunc_TianwuSwap then
    txt_tip = ui.get_text("npcfunc|tips_only_input_tianwu_swap")
  elseif g_npcfunc_id == bo2.eNpcFunc_2ndWeaponSwapGaoDing then
    txt_tip = ui.get_text("npcfunc|tips_only_input_tianwu_swap")
  end
  return txt_tip
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
  local card_equip = w_cell_equip:search("card")
  if card_equip.excel_id == 0 then
    ui_cell.clear(w_cell_equip.parent.parent)
    ui_cell.clear(w_cell_tool1.parent.parent)
    ui_cell.clear(w_cell_tool2.parent.parent)
    return
  end
  local card_tool1 = w_cell_tool1:search("card")
  local swap_excel = get_excel(card_equip.excel_id)
  ui_cell.set(w_cell_tool1.parent.parent, swap_excel.reg_id[0], swap_excel.reg_num[0])
  local card_tool2 = w_cell_tool2:search("card")
  ui_cell.set(card_tool2.parent.parent, swap_excel.reg_id[1], swap_excel.reg_num[1])
  if swap_excel.p_item_id ~= 0 then
    ui_cell.set(w_cell_pdt_pre.parent.parent, swap_excel.p_item_id)
  end
  local money_type = swap_excel.money_type
  local wmoney = {}
  if money_type == 0 then
    w_money0.visible = true
    w_money1.visible = false
    ui_cmn.money_set(w_money0, swap_excel.money)
  elseif money_type == 1 then
    w_money0.visible = false
    w_money1.visible = true
    ui_cmn.money_set(w_money1, swap_excel.money)
  end
  local cur_cnt0 = ui.item_get_count(swap_excel.reg_id[0], true)
  local cur_cnt1 = ui.item_get_count(swap_excel.reg_id[1], true)
  if cur_cnt0 < swap_excel.reg_num[0] or cur_cnt1 < swap_excel.reg_num[1] then
    return
  end
  w_btn_mk.enable = true
end
function post_product_update()
  w_main:insert_post_invoke(do_product_update, "ui_npcfunc.ui_tianwu_swap.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  post_product_update()
end
function get_excel(excel_id)
  local excel = bo2.gv_equip_item:find(excel_id)
  if excel == nil then
    return nil
  end
  local swap_excel
  local size = bo2.gv_tianwu_swap.size
  for i = 0, size - 1 do
    local tmp_excel = bo2.gv_tianwu_swap:get(i)
    if tmp_excel.a_item_id == excel_id then
      swap_excel = tmp_excel
      break
    end
  end
  return swap_excel
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
  local swap_excel = get_excel(info.excel_id)
  if swap_excel == nil then
    ui_tool.note_insert(txt_tip, "FF0000")
    return false
  end
  if g_npcfunc_id ~= get_equip_type(swap_excel.id) then
    ui_tool.note_insert(txt_tip, "FF0000")
    return
  end
  for i = bo2.eItemUInt32_GemBeg, bo2.eItemUInt32_GemEnd - 1 do
    if info:get_data_32(i) ~= 0 then
      ui_chat.show_ui_text_id(2647)
      return false
    end
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
function on_btn_mk_click()
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, g_npcfunc_id)
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
