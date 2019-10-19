local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
local g_p_item_id = 0
local g_npcfunc_id = 0
function handCheckCampaignOn(cmd, data)
  local campaign_eventid = data:get(packet.key.campaign_eventid).v_int
  local talk_excel_id = data:get(packet.key.talk_excel_id).v_int
  if campaign_eventid ~= 17359 or talk_excel_id ~= bo2.eNpcFunc_ChgPrfShenBingSwap then
    return
  end
  local campaign_eventstate = data:get(packet.key.campaign_eventstate).v_int
  if campaign_eventstate == 1 then
    local my_w = ui_npcfunc.ui_chgprf_shenbingswap.w_main
    my_on_visible(my_w, true)
  else
    ui_chat.show_ui_text_id(2651)
  end
end
function on_npcfunc_open_window(npcfunc_id)
  ui.log("npcfunc_id:" .. npcfunc_id)
  g_npcfunc_id = npcfunc_id
  ui_npcfunc.ui_chgprf_shenbingswap.w_main.visible = false
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_ChgPrfShenBingSwap)
  v:set(packet.key.campaign_eventid, 17359)
  bo2.send_variant(packet.eCTS_UI_Check_Campaign_ON, v)
end
function get_equip_invalid_text()
  if g_npcfunc_id == bo2.eNpcFunc_ChgPrfShenBingSwap then
    txt_tip = ui.get_text("npcfunc|tips_only_input_chgprf_shenbingswap")
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
  local henbingswap_excel = get_chgprf_shenbingswap_excel(card_equip.excel_id)
  ui_cell.set(w_cell_tool1.parent.parent, henbingswap_excel.reg_id[0], henbingswap_excel.reg_num[0])
  local card_tool2 = w_cell_tool2:search("card")
  ui_cell.set(card_tool2.parent.parent, henbingswap_excel.reg_id[1], henbingswap_excel.reg_num[1])
  if g_p_item_id ~= 0 then
    ui_cell.set(w_cell_pdt_pre.parent.parent, g_p_item_id)
  end
  local money_type = henbingswap_excel.money_type
  local wmoney = {}
  if money_type == 0 then
    w_money0.visible = true
    ui_cmn.money_set(w_money0, henbingswap_excel.money)
  elseif money_type == 1 then
    w_money1.visible = true
    ui_cmn.money_set(w_money1, henbingswap_excel.money)
  end
  local cur_cnt0 = ui.item_get_count(henbingswap_excel.reg_id[0], true)
  local cur_cnt1 = ui.item_get_count(henbingswap_excel.reg_id[1], true)
  if cur_cnt0 < henbingswap_excel.reg_num[0] or cur_cnt1 < henbingswap_excel.reg_num[1] then
    return
  end
  w_btn_mk.enable = true
end
function post_product_update()
  w_main:insert_post_invoke(do_product_update, "ui_npcfunc.ui_chgprf_shenbingswap.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  post_product_update()
end
function get_chgprf_shenbingswap_excel(excel_id)
  local excel = bo2.gv_equip_item:find(excel_id)
  if excel == nil then
    return nil
  end
  local henbingswap_excel
  for i = 0, bo2.gv_chgprf_shenbingswap.size - 1 do
    local tmp_excel = bo2.gv_chgprf_shenbingswap:get(i)
    local a_item_id = tmp_excel.a_item_id
    if a_item_id == excel_id then
      henbingswap_excel = tmp_excel
      break
    end
  end
  return henbingswap_excel
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
  local shenbingswap_excel = get_chgprf_shenbingswap_excel(info.excel_id)
  if shenbingswap_excel == nil then
    ui_tool.note_insert(txt_tip, "FF0000")
    return false
  end
  local player = bo2.player
  local profession_id = player:get_atb(bo2.eAtb_Cha_Profession)
  local shenbing_list = shenbingswap_excel.p_item_ids
  local size_sb = shenbing_list.size
  if size_sb == 0 then
    return false
  end
  g_p_item_id = 0
  for i = 0, size_sb - 1 do
    local tmp_id = shenbing_list[i]
    local excel = bo2.gv_equip_item:find(tmp_id)
    if excel == nil then
      return
    end
    if excel.requires[0] == bo2.eItemReq_Profession and excel.requires[1] == profession_id then
      g_p_item_id = tmp_id
      break
    end
  end
  local cur_cnt = ui.item_get_count(g_p_item_id, true)
  if g_p_item_id == 0 or cur_cnt > 0 then
    ui_chat.show_ui_text_id(2648)
    return false
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
  local def_level = bo2.gv_define:find(1255).value.v_int
  local player = bo2.player
  local my_level = player:get_atb(bo2.eAtb_Level)
  if def_level > my_level then
    local var = sys.variant()
    var:set(L("level"), def_level)
    local data = sys.variant()
    data:set(packet.key.ui_text_id, 2644)
    data:set(packet.key.ui_text_arg, var)
    ui_chat.show_ui_text(0, data)
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_ChgPrfShenBingSwap)
  v:set64(packet.key.item_key, info.only_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function on_visible(w, vis)
  clear_money()
  ui_cell.clear(w_cell_equip.parent.parent)
  ui_cell.clear(w_cell_tool1.parent.parent)
  ui_cell.clear(w_cell_tool2.parent.parent)
end
function my_on_visible(w, vis)
  ui_cell.clear(w_cell_equip.parent.parent)
  ui_cell.clear(w_cell_tool1.parent.parent)
  ui_cell.clear(w_cell_tool2.parent.parent)
  w_btn_mk.enable = false
  w.visible = true
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
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
local sig = "ui_npcfunc.ui_chgprf_shenbingswap:on_signal"
ui_packet.game_recv_signal_insert(packet.eSTC_UI_Campaign_Check_Campaign_On, handCheckCampaignOn, sig)
