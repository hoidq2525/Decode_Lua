local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
local g_npcfunc_id = 0
function on_npcfunc_open_window(npcfunc_id)
  ui.log("npcfunc_id:" .. npcfunc_id)
  g_npcfunc_id = npcfunc_id
  if g_npcfunc_id == bo2.eNpcFunc_ManufEquipDuhuDown then
    w_lb_src_desc.text = ui.get_text("npcfunc|manuf_input_duhu_down")
    w_lb_title.text = ui.get_text("npcfunc|manuf_title_duhu_down")
  end
end
function get_equip_invalid_text()
  if g_npcfunc_id == bo2.eNpcFunc_ManufEquipDuhuDown then
    txt_tip = ui.get_text("npcfunc|manuf_invalid_equip_duhu_down")
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
    ui_cell.clear(w_cell_tool.parent.parent)
    return
  end
  local card_tool = w_cell_tool:search("card")
  local manuf_excel = get_manuf_down_excel(card_equip.excel_id)
  local med_id = manuf_excel.med_id
  local req_cnt = manuf_excel.med_id_num
  ui_cell.set(w_cell_tool.parent.parent, med_id, req_cnt)
  local pdt_excel_id = manuf_excel.p_item_id
  ui_cell.set(w_cell_pdt_pre.parent.parent, pdt_excel_id)
  local cur_cnt = ui.item_get_count(card_tool.excel_id, true)
  local money_type = manuf_excel.money_type
  local wmoney = {}
  if money_type == 0 then
    w_money0.visible = true
    ui_cmn.money_set(w_money0, manuf_excel.money)
  elseif money_type == 1 then
    w_money1.visible = true
    ui_cmn.money_set(w_money1, manuf_excel.money)
  end
  if req_cnt > cur_cnt then
    return
  end
  w_btn_mk.enable = true
end
function post_product_update()
  w_main:insert_post_invoke(do_product_update, "ui_npcfunc.ui_manuf_equip.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  post_product_update()
end
function get_manuf_down_excel(excel_id)
  local excel = bo2.gv_equip_item:find(excel_id)
  if excel == nil then
    return nil
  end
  local manuf_excel
  for i = 0, bo2.gv_manuf_equip_down.size - 1 do
    local tmp_excel = bo2.gv_manuf_equip_down:get(i)
    local a_item_id = tmp_excel.a_item_id
    if a_item_id == excel_id then
      manuf_excel = tmp_excel
      break
    end
  end
  return manuf_excel
end
function on_equip_change(card)
  do_product_update()
end
function on_equip_drop(pn, msg, pos, data)
  if ui_cell.check_drop(pn, msg, pos, data) == false then
    return
  end
  local card = pn:search("card")
  local info = ui.item_of_only_id(data:get("only_id"))
  if info.box < bo2.eItemBox_BagBeg or info.box >= bo2.eItemBox_BagEnd then
    local txt = ui.get_text("npcfunc|only_item_from_bag")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  local txt_tip = get_equip_invalid_text()
  local manuf_excel = get_manuf_down_excel(info.excel_id)
  if manuf_excel == nil then
    ui_tool.note_insert(txt_tip, "FF0000")
    return
  end
  local def_star = bo2.gv_define:find(1225).value.v_int
  if def_star > info:get_data_8(bo2.eItemByte_Star) then
    ui_tool.note_insert(txt_tip, "FF0000")
    return
  end
  ui_cell.drop(pn, info)
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
  local med_id = w_cell_tool:search("card").excel_id
  if med_id == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, g_npcfunc_id)
  v:set64(packet.key.item_key, info.only_id)
  v:set64(packet.key.item_excelid, med_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function on_visible(w, vis)
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
  ui_cell.clear(w_cell_equip.parent.parent)
  ui_cell.clear(w_cell_tool.parent.parent)
  w_btn_mk.enable = false
  clear_money()
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
function item_rbutton_use(info)
  local card_equip = w_cell_equip:search("card")
  local txt_tip = get_equip_invalid_text()
  local manuf_excel = get_manuf_down_excel(info.excel_id)
  if manuf_excel == nil then
    ui_tool.note_insert(txt_tip, "FF0000")
    return
  end
  local def_star = bo2.gv_define:find(1225).value.v_int
  if def_star > info:get_data_8(bo2.eItemByte_Star) then
    ui_tool.note_insert(txt_tip, "FF0000")
    return
  end
  ui_cell.drop(w_cell_equip, info)
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
