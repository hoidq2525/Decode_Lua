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
  local enforce_max = info_equip:get_data_8(bo2.eItemByte_EnforceMaxCount)
  local enforce_cur = info_equip:get_data_8(bo2.eItemByte_EnforceCounted)
  local card_tool = w_cell_tool:search("card")
  local count_tool = ui.item_get_count(card_tool.excel_id, true)
  if count_tool > 0 then
    if enforce_max > enforce_cur then
      w_btn_enforce.enable = true
    end
  elseif sys.check(w_cell_tool) then
    ui_cell.clear(w_cell_tool.parent.parent)
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
  if ptype.equip_slot >= bo2.eItemSlot_EquipBeg and ptype.equip_slot <= bo2.eItemSlot_EquipEnd and ptype.equip_slot ~= bo2.eItemSlot_HWeapon and ptype.equip_slot ~= bo2.eItemSlot_Ornament then
    return true
  end
  if ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
    return true
  end
  if ptype.id == bo2.eItemtype_Enforce then
    return true
  end
  if excel.id == bo2.gv_define:find(1091).value.v_int then
    return true
  end
  return false
end
function get_enforce_limit_20140408(info, id, kind, ensure)
  local excel = bo2.gv_enforce_light_20140408:find(id)
  if excel == nil then
    return
  end
  local cur_count = info:get_data_8(bo2.eItemByte_EnforceAcount)
  local pre_count = info:get_data_8(bo2.eItemByte_EnforcePre)
  local finel_count = cur_count
  ui.log("cur_count %s per_count %s finel_count %s", cur_count, pre_count, finel_count)
  ui.log("level %s", info:get_data_8(bo2.eItemByte_EnforceLvl))
  if info:get_data_8(bo2.eItemByte_EnforceLvl) == 2 then
    finel_count = cur_count + pre_count
  elseif info:get_data_8(bo2.eItemByte_EnforceLvl) == 0 then
    finel_count = pre_count
  end
  local mix = excel.r_l_limit1 + finel_count
  local r_h_limit = math.max(excel.r_h_limit1, excel.r_h_limit2, excel.r_h_limit3, excel.r_h_limit4)
  local max = r_h_limit + finel_count
  if kind == 2 then
    max = max + 1
    mix = mix + 1
  end
  local ensure_id = bo2.gv_define:find(1091).value.v_int
  if ensure == ensure_id and ensure ~= 0 then
    mix = max
  end
  return max, mix
end
function get_enforce_limit(info, id)
  local excel = bo2.gv_enforce_light:find(id)
  local cur_count = info:get_data_8(bo2.eItemByte_EnforceAcount)
  local pre_count = info:get_data_8(bo2.eItemByte_EnforcePre)
  local one_count = excel.acount
  local finel_count = cur_count
  ui.log("cur_count %s per_count %s finel_count %s", cur_count, pre_count, finel_count)
  ui.log("level %s", info:get_data_8(bo2.eItemByte_EnforceLvl))
  if info:get_data_8(bo2.eItemByte_EnforceLvl) == 2 then
    finel_count = cur_count + pre_count
  elseif info:get_data_8(bo2.eItemByte_EnforceLvl) == 0 then
    finel_count = pre_count
  end
  local mix = excel.r_l_limit1 + finel_count
  if mix > excel.t_h_limit then
  end
  local r_h_limit = math.max(excel.r_h_limit1, excel.r_h_limit2, excel.r_h_limit3, excel.r_h_limit4)
  local max = r_h_limit + finel_count
  if max > excel.t_h_limit then
  end
  return max, mix
end
function on_card_chg(card, onlyid, info)
  ui_cmn.succ_rate_set(w_low_limit, 0)
  ui_cmn.succ_rate_set(w_high_limit, 0)
  ui_cmn.money_set(w_money, 0)
  if w_cell_equip.info then
    if w_cell_tool.info then
      w_btn_enforce.enable = true
    end
    local enforce_count = w_cell_equip.info:get_data_8(bo2.eItemByte_EnforceCounted)
    if enforce_count == 0 then
      w_btn_reset.enable = false
    else
      w_btn_reset.enable = true
    end
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
  local enforce_kind = w_cell_tool.info.excel.datas[0]
  local enforce_ensure = 0
  local info2 = w_cell_ensure:search("card").info
  if info2 ~= nil then
    enforce_ensure = info2.excel.id
  end
  local curIndex = w_cell_equip.info:get_data_8(bo2.eItemByte_EnforceCounted) + 1
  local max, mix = get_enforce_limit_20140408(w_cell_equip.info, curIndex, enforce_kind, enforce_ensure)
  ui.log("max %s mix %s", max, mix)
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
    w_btn_reset.enable = false
    return
  end
  local enforce_count = info:get_data_8(bo2.eItemByte_EnforceCounted)
  if enforce_count == 0 then
    w_btn_reset.enable = false
    w_btn_enforce.enable = false
  end
  local tool_info = w_cell_tool:search("card").info
  if tool_info == nil then
    w_btn_enforce.enable = false
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
  ui_cell.clear(w_cell_ensure.parent.parent)
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
  local info2 = w_cell_ensure:search("card").info
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_EnforceEquipV201418)
  v:set64(packet.key.item_key, info.only_id)
  v:set64(packet.key.item_key1, info1.only_id)
  if info2 ~= nil then
    v:set64(packet.key.item_key2, info2.only_id)
  end
  if w_money:search("rmbchk").check then
    v:set(packet.key.rmb_amount, 1)
  end
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function on_enforce_reset()
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  local enforce_count = info:get_data_8(bo2.eItemByte_EnforceCounted)
  if enforce_count == 0 then
    return
  end
  local function on_enforce_reset_confirm(msg)
    if msg.result == 0 then
      return
    end
    local v = sys.variant()
    v:set64(packet.key.item_key, info.only_id)
    bo2.send_variant(packet.eCTS_UI_EnforceReset, v)
  end
  local msg = {
    callback = on_enforce_reset_confirm,
    modal = true,
    text = ui.get_text("npcfunc|reset_enforce_confirm")
  }
  ui_widget.ui_msg_box.show_common(msg)
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
  local info2 = w_cell_ensure:search("card").info
  local state = info:get_data_8(bo2.eItemByte_EnforceLvl)
  local reserve = info:get_data_8(bo2.eItemByte_EnforceAcount)
  local id = info:get_data_8(bo2.eItemByte_EnforceID)
  if state == 0 and reserve > 0 then
    local m = bo2.gv_enforce_light_20140408:find(id)
    local min = m.r_l_limit1
    local r_h_limit = math.max(m.r_h_limit1, m.r_h_limit2, m.r_h_limit3, m.r_h_limit4)
    local max = r_h_limit
    local kind = info1.excel.datas[0]
    if kind == 2 then
      max = max + 1
      min = min + 1
    end
    if info2 ~= nil then
      min = max
    end
    local enforce_pre = info:get_data_8(bo2.eItemByte_EnforcePre)
    local msg = {
      callback = on_enforce_confirm,
      modal = true,
      btn2 = true,
      text_confirm = ui.get_text("npcfunc|enforce_confirm_yes"),
      text_cancel = ui.get_text("npcfunc|enforce_cancel_no")
    }
    msg.title = ui.get_text("npcfunc|enforce_confirm_title")
    msg.text = ui_widget.merge_mtf({
      key = info.code,
      limit_l = min,
      limit_h = max,
      res = reserve,
      total = enforce_pre + reserve
    }, ui.get_text("npcfunc|enforce_confirm_info"))
    ui_widget.ui_msg_box.show_common(msg)
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_EnforceEquipV201418)
  v:set64(packet.key.item_key, info.only_id)
  v:set64(packet.key.item_key1, info1.only_id)
  if info2 ~= nil then
    v:set64(packet.key.item_key2, info2.only_id)
  end
  if w_money:search("rmbchk").check then
    v:set(packet.key.rmb_amount, 1)
  end
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
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
  ui_cell.clear(w_cell_ensure.parent.parent)
  w_btn_enforce.enable = false
  w_btn_reset.enable = false
  local item_id = bo2.gv_define:find(1091).value.v_int
  if ui.item_get_count(item_id) ~= 0 then
    w_panel_ensure.visible = true
    w_ensure_title.visible = true
  else
    w_panel_ensure.visible = false
    w_ensure_title.visible = false
  end
end
function on_ensure_drop(pn, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  ui.clean_drop()
  local info = ui.item_of_only_id(data:get("only_id"))
  if info.excel.id == bo2.gv_define:find(1091).value.v_int then
    ui_npcfunc.ui_cell.drop(pn, info)
  end
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
  if ptype.equip_slot >= bo2.eItemSlot_EquipBeg and ptype.equip_slot <= bo2.eItemSlot_EquipEnd and ptype.equip_slot ~= bo2.eItemSlot_HWeapon and ptype.equip_slot ~= bo2.eItemSlot_Ornament then
    ui_cell.drop(w_cell_equip, info)
    if info:get_data_8(bo2.eItemByte_EnforceCounted) ~= 0 then
      w_btn_reset.enable = true
    else
      w_btn_reset.enable = false
    end
  end
  if ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
    ui_cell.drop(w_cell_equip, info)
  end
  if ptype.id == bo2.eItemtype_Enforce then
    ui_cell.drop(w_cell_tool, info)
  end
  if ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
    ui_cell.drop(w_cell_equip, info)
  end
  if info.excel.id == bo2.gv_define:find(1091).value.v_int then
    ui_cell.drop(w_cell_ensure, info)
  end
end
function on_init(ctrl)
  ui_cmn.succ_rate_set(w_succ_rate, 0)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  w_cell_tool:insert_on_item_only_id(on_card_chg, "ui_enforce.on_card_chg")
  w_cell_equip:insert_on_item_only_id(on_card_chg, "ui_enforce.on_card_chg")
  w_cell_ensure:insert_on_item_only_id(on_card_chg, "ui_enforce.on_card_chg")
end
function on_enforce_res_confirm(msg)
  local title = msg.title
  local text = msg.text
  local key = msg.key
  local function on_enforce_res_confirm2(msg)
    if msg.result == 1 then
      local v = sys.variant()
      v:set(packet.key.item_key, key)
      bo2.send_variant(packet.eCTS_UI_Enforce_Cannel, v)
    elseif msg.result == 0 then
      local msg = {
        callback = on_enforce_res_confirm,
        modal = true,
        btn_close = false,
        btn2 = true,
        text_confirm = ui.get_text("npcfunc|enforce_confirm"),
        text_cancel = ui.get_text("npcfunc|enforce_cancel")
      }
      msg.title = title
      msg.text = text
      msg.key = key
      ui_widget.ui_msg_box.show_common(msg)
    end
  end
  if msg.result == 0 then
    local msg = {
      callback = on_enforce_res_confirm2,
      modal = true,
      btn2 = true,
      btn_close = false,
      text_confirm = ui.get_text("npcfunc|enforce_cancel_yes"),
      text_cancel = ui.get_text("npcfunc|enforce_cancel_no")
    }
    msg.text = ui.get_text("npcfunc|enforce_cannel_confirm")
    ui_widget.ui_msg_box.show_common(msg)
  else
    local v = sys.variant()
    v:set(packet.key.item_key, key)
    bo2.send_variant(packet.eCTS_UI_Enforce_Confirm, v)
  end
end
function showenforceinfo20140408(cmd, data)
  local id = data:get(packet.key.cmn_id).v_int
  local count = data:get(packet.key.cmn_index).v_int
  local key = data:get(packet.key.item_key).v_string
  local kind = data:get(packet.key.cmn_rst).v_int
  local key2 = data:get(packet.key.item_key2).v_string
  local m = bo2.gv_enforce_light_20140408:find(id)
  local item_info = ui.item_of_only_id(key)
  ui.log("showenforceinfo20140408 %s %s %s %s", item_info, count, limit_max, limit_min)
  local min = m.r_l_limit1
  local r_h_limit = math.max(m.r_h_limit1, m.r_h_limit2, m.r_h_limit3, m.r_h_limit4)
  local max = r_h_limit
  if kind == 2 then
    min = min + 1
    max = max + 1
  end
  local item_info2 = ui.item_of_only_id(key2)
  if item_info2 ~= nil and item_info2.excel.id == bo2.gv_define:find(1091).value.v_int then
    min = max
  end
  local enforce_pre = item_info:get_data_8(bo2.eItemByte_EnforcePre)
  local msg = {
    callback = on_enforce_res_confirm,
    modal = true,
    btn_close = false,
    btn2 = true,
    text_confirm = ui.get_text("npcfunc|enforce_confirm"),
    text_cancel = ui.get_text("npcfunc|enforce_cancel")
  }
  msg.title = ui.get_text("npcfunc|enforce_title")
  msg.text = ui_widget.merge_mtf({
    key = item_info.code,
    limit_l = min,
    limit_h = max,
    res = count,
    total = count + enforce_pre
  }, ui.get_text("npcfunc|enforce_info"))
  msg.key = key
  ui_widget.ui_msg_box.show_common(msg)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_npcfun.equip_enforce"
reg(packet.eSTC_UI_ShowEnforceInfo, showenforceinfo20140408, sig)
