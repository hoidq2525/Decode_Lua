local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
local g_npcfunc_id = 0
local g_profession_id = 0
local g_damage_type, g_chgprf_equipswap_id
local def_star = bo2.gv_define:find(1258).value.v_int
function handCheckCampaignOn(cmd, data)
  local campaign_eventid = data:get(packet.key.campaign_eventid).v_int
  local talk_excel_id = data:get(packet.key.talk_excel_id).v_int
  if campaign_eventid ~= 17359 or talk_excel_id ~= bo2.eNpcFunc_ChgPrfEquipSwap then
    return
  end
  local campaign_eventstate = data:get(packet.key.campaign_eventstate).v_int
  if campaign_eventstate == 1 then
    local my_w = ui_npcfunc.ui_chgprf_equipswap.w_main
    my_on_visible(my_w, true)
  else
    ui_chat.show_ui_text_id(2651)
  end
end
function on_npcfunc_open_window(npcfunc_id)
  ui.log("npcfunc_id:" .. npcfunc_id)
  g_npcfunc_id = npcfunc_id
  ui_npcfunc.ui_chgprf_equipswap.w_main.visible = false
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_ChgPrfEquipSwap)
  v:set(packet.key.campaign_eventid, 17359)
  bo2.send_variant(packet.eCTS_UI_Check_Campaign_ON, v)
end
function GetVecFromString(str)
  if str == nil then
    return nil
  end
  if #str == 0 then
    return nil
  end
  local vec = {}
  local data, leftStr = str:split2("*")
  while #leftStr ~= 0 do
    table.insert(vec, data.v_int)
    data, leftStr = leftStr:split2("*")
  end
  table.insert(vec, data.v_int)
  return vec
end
function get_equip_invalid_text()
  if g_npcfunc_id == bo2.eNpcFunc_ChgPrfEquipSwap then
    txt_tip = ui.get_text("npcfunc|tips_only_input_chgprf_equipswap")
  end
  return txt_tip
end
function clear_money()
  if sys.check(w_money0) and sys.check(w_money1) and sys.check(w_money0.visible) and sys.check(w_money1.visible) then
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
  local equipswap_excel = get_chgprf_equipswap_excel(card_equip.excel_id)
  ui_cell.set(w_cell_tool1.parent.parent, equipswap_excel.reg_id[0], equipswap_excel.reg_num[0])
  local card_tool2 = w_cell_tool2:search("card")
  ui_cell.set(card_tool2.parent.parent, equipswap_excel.reg_id[1], equipswap_excel.reg_num[1])
  local pdt_excel_id = 0
  local size = equipswap_excel.p_item_id.size
  if size <= 0 then
    return
  elseif size == 1 then
    pdt_excel_id = equipswap_excel.p_item_id[0]
  else
    local pExcel = bo2.gv_profession_list:find(g_profession_id)
    if pExcel == nil or pExcel.career > 8 or 0 >= pExcel.career then
      return
    end
    local career_id = pExcel.career
    for i = 0, size do
      local p_itemid = equipswap_excel.p_item_id[i]
      local pEquipExcel = bo2.gv_equip_item:find(p_itemid)
      if pEquipExcel == nil then
        return
      end
      if pEquipExcel.requires[0] == 1 and pEquipExcel.requires[1] == career_id or pEquipExcel.requires[0] == 2 and pEquipExcel.requires[1] == g_profession_id then
        pdt_excel_id = p_itemid
        break
      end
    end
  end
  if pdt_excel_id == 0 then
    return
  end
  ui_cell.set(w_cell_pdt_pre.parent.parent, pdt_excel_id)
  local money_type = equipswap_excel.money_type
  local wmoney = {}
  if money_type == 0 then
    w_money0.visible = true
    ui_cmn.money_set(w_money0, equipswap_excel.money)
  elseif money_type == 1 then
    w_money1.visible = true
    ui_cmn.money_set(w_money1, equipswap_excel.money)
  end
  local cur_cnt0 = ui.item_get_count(equipswap_excel.reg_id[0], true)
  local cur_cnt1 = ui.item_get_count(equipswap_excel.reg_id[1], true)
  if cur_cnt0 < equipswap_excel.reg_num[0] or cur_cnt1 < equipswap_excel.reg_num[1] then
    return
  end
  w_btn_mk.enable = true
end
function post_product_update()
  w_main:insert_post_invoke(do_product_update, "ui_npcfunc.ui_chgprf_equipswap.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  post_product_update()
end
function get_chgprf_equipswap_excel(excel_id)
  local excel = bo2.gv_equip_item:find(excel_id)
  if excel == nil then
    return nil
  end
  local equipswap_excel
  for i = 0, bo2.gv_chgprf_equipswap.size - 1 do
    local tmp_excel = bo2.gv_chgprf_equipswap:get(i)
    local a_item_id = tmp_excel.a_item_id
    if a_item_id == excel_id then
      equipswap_excel = tmp_excel
      g_chgprf_equipswap_id = i + 1
      break
    end
  end
  return equipswap_excel
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
  local equipswap_excel = get_chgprf_equipswap_excel(info.excel_id)
  if equipswap_excel == nil then
    ui_tool.note_insert(txt_tip, "FF0000")
    return false
  end
  local star = info.star
  if star < tonumber(def_star) then
    ui_tool.note_insert(txt_tip, "FF0000")
    return false
  end
  if equipswap_excel.no_check_hurt_type == 1 then
    local pExcel = bo2.gv_profession_list:find(g_profession_id)
    local career_id = pExcel.career
    local pEquipExcel = bo2.gv_equip_item:find(info.excel_id)
    if pEquipExcel == nil then
      return false
    end
    if pEquipExcel.requires[0] == 1 and pEquipExcel.requires[1] == career_id or pEquipExcel.requires[0] == 2 and pEquipExcel.requires[1] == g_profession_id then
      ui_tool.note_insert(txt_tip, "FF0000")
      return false
    end
    return true
  end
  local phy_mic = math.mod(g_chgprf_equipswap_id, 2)
  if g_chgprf_equipswap_id == nil or phy_mic ~= g_damage_type then
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
    data:set(packet.key.ui_text_id, 2646)
    data:set(packet.key.ui_text_arg, var)
    ui_chat.show_ui_text(0, data)
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_ChgPrfEquipSwap)
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
  local player = bo2.player
  g_profession_id = player:get_atb(bo2.eAtb_Cha_Profession)
  local profession_excel = bo2.gv_profession_list:find(g_profession_id)
  if profession_excel == nil then
    return
  end
  g_damage_type = profession_excel.damage
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
local sig = "ui_npcfunc.ui_chgprf_equipswap:on_signal"
ui_packet.game_recv_signal_insert(packet.eSTC_UI_Campaign_Check_Campaign_On, handCheckCampaignOn, sig)
