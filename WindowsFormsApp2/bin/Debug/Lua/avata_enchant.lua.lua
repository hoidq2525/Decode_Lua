local create_flag = false
local avata_enchant_need_itemids = bo2.gv_define:find(1226).value
local enchant_slot1 = bo2.gv_define:find(1227).value
local enchant_slot2 = bo2.gv_define:find(1228).value
local enchant_slot3 = bo2.gv_define:find(1229).value
local enchant_slot4 = bo2.gv_define:find(1230).value
local enchant_slot5 = bo2.gv_define:find(1231).value
local enchant_slot6 = bo2.gv_define:find(1232).value
local enchant_slot7 = bo2.gv_define:find(1233).value
local enchant_slot8 = bo2.gv_define:find(1234).value
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
function is_avata_enchant_need_itemid(item_id)
  if item_id == nil then
    return false
  end
  local avata_enchant_need_itemids_vec = {}
  avata_enchant_need_itemids_vec = GetVecFromString(avata_enchant_need_itemids)
  if avata_enchant_need_itemids_vec == nil then
    return false
  end
  for i, v in ipairs(avata_enchant_need_itemids_vec) do
    if tonumber(v) == tonumber(item_id) then
      return true
    end
  end
  return false
end
function may_enchant_use_itemid(item_id, slot)
  if slot < 0 and slot > 8 then
    return false
  end
  local enchant_slot
  slot = slot + 1
  if slot == 1 then
    enchant_slot = enchant_slot1
  elseif slot == 2 then
    enchant_slot = enchant_slot2
  elseif slot == 3 then
    enchant_slot = enchant_slot3
  elseif slot == 4 then
    enchant_slot = enchant_slot4
  elseif slot == 5 then
    enchant_slot = enchant_slot5
  elseif slot == 6 then
    enchant_slot = enchant_slot6
  elseif slot == 7 then
    enchant_slot = enchant_slot7
  elseif slot == 8 then
    enchant_slot = enchant_slot8
  end
  local vec = GetVecFromString(enchant_slot)
  if vec == nil then
    return false
  end
  for i, v in ipairs(vec) do
    if tonumber(v) == tonumber(item_id) then
      return true
    end
  end
  return false
end
function clear_traints1()
  local traits_panel1 = w_avata_enchant:search("traits_panel1")
  for i = 0, 7 do
    local trait_check = traits_panel1:control_get(i)
    trait_check.visible = false
  end
end
function clear_traints2()
  local traits_panel2 = w_avata_enchant:search("traits_panel2")
  for i = 0, 7 do
    local trait_check = traits_panel2:control_get(i)
    trait_check.visible = false
  end
end
function clear_traints1_select()
  local traits_panel1 = w_avata_enchant:search("traits_panel1")
  for i = 0, 7 do
    local trait_check = traits_panel1:control_get(i)
    trait_check.check = false
    trait_check.enable = true
  end
end
function clear_traints2_select()
  local traits_panel2 = w_avata_enchant:search("traits_panel2")
  for i = 0, 7 do
    local trait_check = traits_panel2:control_get(i)
    trait_check.check = false
  end
end
function clear_item1()
  local card = w_enchant1:search("card")
  if card ~= nil then
    ui_npcfunc.clear_card(card)
  end
end
function top_of(c)
  while c ~= nil do
    if c.name == L("cell_base") then
      return c.parent
    end
    c = c.parent
  end
  return nil
end
function clear_item2()
  local card = w_enchant2:search("card")
  if card ~= nil then
    local card1 = card:search("card")
    local lb = top_of(card1):search("lb_item")
    if lb then
      lb.text = ""
    end
    ui_npcfunc.clear_card(card)
  end
end
function update_item1(target_item_info)
  clear_item1()
  local pn1 = w_avata_enchant:search("item1")
  ui_npcfunc.ui_cell.drop(pn1, target_item_info)
end
function update_item2(src_item_info)
  clear_item2()
  local item_id = src_item_info.excel.id
  local item_count = ui.item_get_count(item_id, true)
  if not is_avata_enchant_need_itemid(item_id) or item_count < 1 then
    ui_chat.show_ui_text_id(2634)
    return
  end
  local pn2 = w_avata_enchant:search("item2")
  ui_npcfunc.ui_cell.drop(pn2, src_item_info)
end
function get_traits_panel1_select()
  local sele
  local traits_panel1 = w_avata_enchant:search("traits_panel1")
  for i = 0, traits_panel1.control_size - 1 do
    local bt = traits_panel1:control_get(i)
    if bt.check then
      return bt
    end
  end
  return sele
end
function get_traits_panel2_select()
  local sele
  local traits_panel2 = w_avata_enchant:search("traits_panel2")
  for i = 0, traits_panel2.control_size - 1 do
    local bt = traits_panel2:control_get(i)
    if bt.check then
      return bt
    end
  end
  return sele
end
function may_enable_confirm()
  local confirm = w_avata_enchant:search("confirm")
  if confirm.svar == nil then
    return false
  end
  local v = confirm.svar
  local src_item_info = ui.item_of_only_id(v:get(packet.key.item_key).v_string)
  local target_item_info = ui.item_of_only_id(v:get(packet.key.use_dstitem_key).v_string)
  if src_item_info == nil or target_item_info == nil then
    return false
  end
  local itemdata_idx = v:get(packet.key.itemdata_idx).v_string
  local sele = get_traits_panel2_select()
  if itemdata_idx == nil or sele == nil then
    return false
  end
  local item_id = src_item_info.excel.id
  local item_count = ui.item_get_count(item_id, true)
  if item_count > 0 then
    return true
  end
  return false
end
function update_btn_confirm()
  local confirm = w_avata_enchant:search("confirm")
  if may_enable_confirm() then
    confirm.enable = true
  else
    confirm.enable = false
  end
end
function get_desc_color(desc, id, check)
  local color = ""
  if id == 0 then
    color = "00FF00"
  elseif id == 1 then
    color = "59a1fe"
  elseif id == 2 then
    color = "8250af"
  elseif id == 3 then
    color = "DE3910"
  elseif id == 4 then
    color = "F9D23A"
  end
  if check == false and id == -1 then
    color = "CCCCCC"
  end
  desc = "<c+:" .. color .. ">" .. desc .. "<c->"
  return desc
end
function update_traints1()
  clear_traints1()
  local confirm = w_avata_enchant:search("confirm")
  local v = confirm.svar
  local src_item_info = ui.item_of_only_id(v:get(packet.key.item_key).v_string)
  local target_item_info = ui.item_of_only_id(v:get(packet.key.use_dstitem_key).v_string)
  local iSlotNum = target_item_info:get_data_32(bo2.eItemUInt32_AvataEnchant_SlotNum)
  local iSelIndex = v:get(packet.key.itemdata_idx).v_int
  local index_falg = false
  local traits_panel1 = w_avata_enchant:search("traits_panel1")
  for i = 0, 7 do
    local trait_check = traits_panel1:control_get(i)
    if i < iSlotNum then
      if may_enchant_use_itemid(src_item_info.excel.id, i) then
        if iSelIndex ~= 0 and iSelIndex == i then
          index_falg = true
          trait_check.check = true
        elseif iSelIndex == 0 and index_falg == false then
          iSelIndex = i
          index_falg = true
          trait_check.check = true
        end
      else
        trait_check.enable = false
      end
      local iValue = target_item_info:get_data_32(bo2.eItemUInt32_AvataEnchant_Begin + i)
      local desc = ui.get_text("item|avata_enchant_no_avata")
      local enchant_id_id = 0
      local trait_list_exel
      if iValue ~= 0 then
        enchant_id_id = bo2.bit_rshift(iValue, 24)
        local enchant_id = bo2.bit_and(iValue, 16777215)
        if enchant_id_id ~= 0 then
          local enchant_excel = bo2.gv_avata_equip_enchant:find(enchant_id)
          local vaule_id = enchant_excel.trait[enchant_id_id - 1]
          trait_list_exel = bo2.gv_trait_list:find(vaule_id)
        end
      end
      if trait_list_exel ~= nil then
        desc = trait_list_exel.desc
      end
      desc = get_desc_color(desc, enchant_id_id - 1, trait_check.enable)
      trait_check.svar = i
      trait_check:search("txt").mtf = ui_widget.merge_mtf({}, desc)
      trait_check.visible = true
    else
      trait_check.visible = false
    end
  end
  if index_falg == false then
    iSelIndex = -1
  end
  v:set(packet.key.itemdata_idx, iSelIndex)
  confirm.svar = v
end
function update_traints2()
  clear_traints2()
  local confirm = w_avata_enchant:search("confirm")
  local v = confirm.svar
  local src_item_info = ui.item_of_only_id(v:get(packet.key.item_key).v_string)
  local target_item_info = ui.item_of_only_id(v:get(packet.key.use_dstitem_key).v_string)
  if target_item_info == nil then
    ui_chat.show_ui_text_id(2633)
    return
  end
  local iSelIndex = v:get(packet.key.itemdata_idx).v_int
  if iSelIndex == -1 then
    return
  end
  local iSlotNum = target_item_info:get_data_32(bo2.eItemUInt32_AvataEnchant_SlotNum)
  function MayAddTrait(id)
    local iSelV = target_item_info:get_data_32(bo2.eItemUInt32_AvataEnchant_Begin + iSelIndex)
    iSelV = bo2.bit_and(iSelV, 16777215)
    if id == iSelV then
      return true
    end
    for i = 0, iSlotNum - 1 do
      local iValue = target_item_info:get_data_32(bo2.eItemUInt32_AvataEnchant_Begin + i)
      if iValue ~= 0 then
        local enchant_id = bo2.bit_and(iValue, 16777215)
        if enchant_id == id then
          return false
        end
      end
    end
    return true
  end
  local traits_panel2 = w_avata_enchant:search("traits_panel2")
  if src_item_info == nil then
    return
  end
  local traits = src_item_info.excel.use_par
  local size = traits.size - 1
  local index = 0
  for i = 0, size do
    local id = traits[i]
    if MayAddTrait(id) then
      local enchant_excel = bo2.gv_avata_equip_enchant:find(id)
      local trait_check = traits_panel2:control_get(index)
      trait_check.svar = i
      trait_check:search("txt").mtf = ui_widget.merge_mtf({}, enchant_excel.desc)
      trait_check.visible = true
      index = index + 1
    end
  end
end
function UpdataTraits()
  local confirm = w_avata_enchant:search("confirm")
  local v = confirm.svar
  local src_item_info = ui.item_of_only_id(v:get(packet.key.item_key).v_string)
  local target_item_info = ui.item_of_only_id(v:get(packet.key.use_dstitem_key).v_string)
  update_item1(target_item_info)
  update_item2(src_item_info)
  update_traints1()
  update_traints2()
  update_btn_confirm()
end
function open(src_item_info, target_item_info)
  local src_only_id = src_item_info.only_id
  local target_only_id = target_item_info.only_id
  local target_excel = target_item_info.excel
  if target_excel == nil or target_excel.ptype == nil then
    return
  end
  if target_excel.ptype.group ~= bo2.eItemGroup_Avata then
    return
  end
  if target_excel.life_mode ~= 0 or 0 < target_item_info:get_data_32(bo2.eItemUInt32_RenewalDays) then
    return
  end
  local iSlotNum = target_item_info:get_data_32(bo2.eItemUInt32_AvataEnchant_SlotNum)
  if iSlotNum == 0 then
    ui_chat.show_ui_text_id(190001)
    return
  end
  if create_flag == true then
    w_avata_enchant:post_release()
    w_avata_enchant = nil
    clear_item1()
    clear_item2()
  end
  create_flag = true
  local ctr = ui.create_control(ui_main.w_top, "panel")
  ctr:load_style("$gui/frame/item/avata_enchant.xml", "avata_enchant")
  local iselindex = 0
  local confirm = ctr:search("confirm")
  local v = sys.variant()
  v:set(packet.key.itemdata_idx, iselindex)
  v:set(packet.key.item_key, src_only_id)
  v:set(packet.key.use_dstitem_key, target_only_id)
  confirm.svar = v
  clear_traints1_select()
  clear_traints2_select()
  UpdataTraits()
end
function isbestatb(v)
  local target_item_info = ui.item_of_only_id(v:get(packet.key.use_dstitem_key).v_string)
  local iSelIndex = v:get(packet.key.itemdata_idx).v_int
  local iValue = target_item_info:get_data_32(bo2.eItemUInt32_AvataEnchant_Begin + iSelIndex)
  local enchant_id_id = bo2.bit_rshift(iValue, 24)
  if enchant_id_id == 5 then
    return true
  end
  return false
end
function on_confirm_click(btn)
  local c = btn.parent.parent
  local bt_check
  bt_check = get_traits_panel2_select()
  if bt_check == nil then
    ui_chat.show_ui_text_id(190003)
    return
  end
  local v = btn.svar
  if isbestatb(v) then
    ui_widget.ui_msg_box.show_common({
      text = ui_widget.merge_mtf({}, ui.get_text("item|btn_avata_enchant_ok_ask")),
      modal = true,
      btn_confirm = true,
      btn_cancel = true,
      callback = function(msg)
        if msg.result == 1 then
          v:set(packet.key.itemdata_val, bt_check.svar)
          bo2.send_variant(packet.eCTS_UI_UseItem, v)
        else
          return
        end
      end
    })
  else
    v:set(packet.key.itemdata_val, bt_check.svar)
    bo2.send_variant(packet.eCTS_UI_UseItem, v)
  end
end
function on_cancel_click(btn)
  clear_item1()
  clear_item2()
  clear_traints1()
  clear_traints2()
  local c = btn.parent.parent.parent
  c:post_release()
  create_flag = false
end
function on_avata_trait_click(ctrl)
  local confirm = w_avata_enchant:search("confirm")
  local v = confirm.svar
  v:set(packet.key.itemdata_idx, ctrl.svar)
  confirm.svar = v
  clear_traints2_select()
  update_traints2()
  update_btn_confirm()
end
function avata_item1_drop(card, msg, pos, data)
  if msg == ui.mouse_rbutton_down or msg == ui.mouse_rbutton_up then
    return
  end
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  local target_item_info = ui.item_of_only_id(data:get("only_id").v_string)
  if target_item_info == nil then
    return
  end
  local target_excel = target_item_info.excel
  if target_excel == nil or target_excel.ptype == nil then
    return
  end
  if target_excel.ptype.group ~= bo2.eItemGroup_Avata then
    return
  end
  if target_excel.life_mode ~= 0 or 0 < target_item_info:get_data_32(bo2.eItemUInt32_RenewalDays) then
    return
  end
  local iSlotNum = target_item_info:get_data_32(bo2.eItemUInt32_AvataEnchant_SlotNum)
  if iSlotNum == 0 then
    ui_chat.show_ui_text_id(190001)
    return
  end
  local confirm = w_avata_enchant:search("confirm")
  local v = confirm.svar
  local iselindex = 0
  v:set(packet.key.itemdata_idx, iselindex)
  v:set(packet.key.use_dstitem_key, data:get("only_id").v_string)
  confirm.svar = v
  clear_traints1_select()
  clear_traints2_select()
  UpdataTraits()
end
function avata_item2_drop(card, msg, pos, data)
  if msg == ui.mouse_rbutton_down or msg == ui.mouse_rbutton_up then
    return
  end
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  local src_item_info = ui.item_of_only_id(data:get("only_id").v_string)
  if src_item_info == nil then
    return
  end
  local item_id = src_item_info.excel.id
  local item_count = ui.item_get_count(item_id, true)
  if not is_avata_enchant_need_itemid(src_item_info.excel.id) or item_count < 1 then
    ui_chat.show_ui_text_id(2634)
    return
  end
  local src_item_info = ui.item_of_only_id(data:get("only_id").v_string)
  if src_item_info == nil then
    return
  end
  local confirm = w_avata_enchant:search("confirm")
  local v = confirm.svar
  local iselindex = 0
  v:set(packet.key.itemdata_idx, iselindex)
  v:set(packet.key.item_key, data:get("only_id").v_string)
  confirm.svar = v
  clear_traints1_select()
  clear_traints2_select()
  UpdataTraits()
end
function avata_item1_mouse(card, msg, pos, data)
end
function avata_item2_mouse(card, msg, pos, data)
end
function handle_avata_enchant(cmd, var)
  local only_id = var:get(packet.key.item_key).v_string
  if w_avata_enchant == nil then
    return
  end
  local confirm = w_avata_enchant:search("confirm")
  local v = confirm.svar
  local target_item_onlyid = v:get(packet.key.use_dstitem_key).v_string
  if target_item_onlyid ~= only_id then
    return
  end
  local iSelIndex = var:get(packet.key.itemdata_idx).v_int
  v:set(packet.key.itemdata_idx, iSelIndex)
  confirm.svar = v
  UpdataTraits()
end
function on_close(btn)
  clear_item1()
  clear_item2()
  clear_traints1()
  clear_traints2()
  local c = btn.parent.parent
  c:post_release()
  create_flag = false
end
function on_timer()
  local confirm = w_avata_enchant:search("confirm")
  if confirm.svar == nil then
    return
  end
  local v = confirm.svar
  local src_item_info = ui.item_of_only_id(v:get(packet.key.item_key).v_string)
  if src_item_info == nil or src_item_info.excel.id == nil or ui.item_get_count(src_item_info.excel.id, true) < 1 then
    clear_item2()
    clear_traints2()
    confirm.enable = false
  end
end
function init_once()
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_ItemData_AvataEnchant, handle_avata_enchant, "ui_item.ui_avata.handle_avata_enchant")
end
init_once()
