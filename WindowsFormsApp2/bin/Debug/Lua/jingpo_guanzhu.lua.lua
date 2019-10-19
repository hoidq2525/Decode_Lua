local iGemSemltProductItemID = bo2.gv_define:find(1289).value.v_int
local iJingpoGuanzhuOnLevel = bo2.gv_define:find(1290).value.v_int
function find_index_item_slot(equip_slot)
  local index_item_slot = -1
  local excel_data = bo2.gv_jingpo_guanzhu:find(1)
  if excel_data == nil then
    return index_item_slot
  end
  local size_is = excel_data.item_slots.size
  for i = 0, size_is - 1 do
    if excel_data.item_slots[i] == equip_slot then
      index_item_slot = i
      break
    end
  end
  return index_item_slot, excel_data
end
function check_drop(pn, msg, pos, info)
  local excel = info.excel
  if excel == nil then
    return false
  end
  local ptype = excel.ptype
  local index_item_slot, excel_data = find_index_item_slot(ptype.equip_slot)
  if index_item_slot == -1 then
    local v = sys.variant()
    v:set(packet.key.ui_text_id, 20329)
    ui_packet.recv_wrap(packet.eSTC_UI_ShowText, v)
    return false
  end
  local main_weapon_info = ui.item_of_coord(bo2.eItemArray_InSlot, excel_data.item_slots[index_item_slot])
  if main_weapon_info == nil or main_weapon_info.only_id ~= info.only_id then
    local v = sys.variant()
    v:set(packet.key.ui_text_id, 20330)
    ui_packet.recv_wrap(packet.eSTC_UI_ShowText, v)
    return false
  end
  return true
end
function on_card_drop(card, msg, pos, data)
  if ui_npcfunc.ui_cell.check_drop(pn, msg, pos, data) == false then
    return
  end
  local info = ui.item_of_only_id(data:get("only_id"))
  if info == nil or check_drop(card, msg, pos, info) == false then
    return
  end
  drop(card, info)
end
function clear(card)
  if card == nil then
    return
  end
  local equip_card = card.parent.parent.parent.parent
  equip_card:search("level").text = ""
  equip_card:search("exp_text").text = ""
  equip_card:search("exp_cur").dx = ""
  ui_npcfunc.ui_cell.clear(card.parent.parent)
end
function drop(card, info)
  if card == nil or bo2.player == nil or info == nil then
    return
  end
  ui_npcfunc.ui_cell.drop(card, info)
  local excel = info.excel
  local ptype = excel.ptype
  local index_item_slot, excel_data = find_index_item_slot(ptype.equip_slot)
  if index_item_slot == -1 then
    return
  end
  local nLevel = bo2.player:get_flag_int64(excel_data.db_jingpo_levels[index_item_slot]).v_int
  local cur_count = bo2.player:get_flag_int64(excel_data.db_jingpo_counts[index_item_slot]).v_int
  if excel_data.item_slots[index_item_slot] == bo2.eItemSlot_MainWeapon then
    nLevel = bo2.player:get_flag_int32(excel_data.db_jingpo_levels[index_item_slot])
    cur_count = bo2.player:get_flag_int32(excel_data.db_jingpo_counts[index_item_slot])
  end
  local line = GetExcelByLevel(nLevel)
  if line == nil then
    return
  end
  local max_count = line.counts[index_item_slot]
  local value = cur_count / max_count
  value = math.min(value, 1)
  local equip_card = card.parent.parent.parent.parent
  equip_card:search("level").text = line.level
  equip_card:search("exp_text").text = cur_count .. "/" .. max_count
  equip_card:search("exp_cur").dx = value * 85
end
function on_card_mouse(card, msg, pos, wheel)
  local icon = card.icon
  if icon == nil then
    return
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_drag then
  elseif msg == ui.mouse_rbutton_click then
    clear(card)
  end
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
function item_rbutton_check(info)
  if info == nil then
    return false
  end
  local excel = info.excel
  if excel == nil then
    return false
  end
  local ptype = excel.ptype
  if ptype == nil then
    return false
  end
  if find_index_item_slot(ptype.equip_slot) == -1 then
    return false
  end
  return true
end
function set_range()
  local cnt = ui.item_get_count(iGemSemltProductItemID, true)
  ui_widget.ui_count_box.set_range(w_count_box, 0, cnt)
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
  if check_drop(card, msg, pos, info) == false then
    return
  end
  if find_index_item_slot(ptype.equip_slot) ~= -1 then
    drop(w_equip_target, info)
    ui_npcfunc.ui_cell.set(w_equip_material.parent.parent, iGemSemltProductItemID, 1)
    set_range()
  end
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|jingpo_guanzhu_rclick_to_place")
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  local w_person = ui.find_control("$frame:personal")
  if w_person ~= nil and vis == true and w_person.visible == false then
    w_person.visible = true
  end
  w_btn_ok.enable = false
  clear(w_equip_target)
  clear(w_equip_preview)
  ui_npcfunc.ui_cell.clear(w_equip_material.parent.parent)
end
function on_timer_ui()
  on_update_preview()
end
function is_ready()
  if w_equip_target.info == nil then
    return false
  end
  local excel_id = w_equip_material.excel_id
  if excel_id == nil then
    return false
  end
  return true
end
function on_tip_show(tip)
end
function GetExcelByLevel(level)
  if level <= 0 then
    return bo2.gv_jingpo_guanzhu:find(1)
  end
  if level >= iJingpoGuanzhuOnLevel then
    return bo2.gv_jingpo_guanzhu:find(iJingpoGuanzhuOnLevel)
  end
  return bo2.gv_jingpo_guanzhu:find(level)
end
function GetExcelByLevelAndCount(level, count)
  local cur_count = count
  local cur_level = level
  if level <= 0 then
    cur_level = 1
  end
  local excel = w_equip_target.info.excel
  local ptype = excel.ptype
  local index_item_slot, excel_data = find_index_item_slot(ptype.equip_slot)
  local cur_line
  local index = cur_level
  local size_jp = bo2.gv_jingpo_guanzhu.size
  while index <= size_jp do
    local line = bo2.gv_jingpo_guanzhu:find(index)
    if not line then
      return cur_line, cur_count
    end
    cur_line = line
    if line.level >= iJingpoGuanzhuOnLevel and cur_count >= line.counts[index_item_slot] - 1 then
      local cur_db_count = bo2.player:get_flag_int64(excel_data.db_jingpo_counts[index_item_slot]).v_int
      if excel_data.item_slots[index_item_slot] == bo2.eItemSlot_MainWeapon then
        cur_db_count = bo2.player:get_flag_int32(excel_data.db_jingpo_counts[index_item_slot])
      end
      ui_widget.ui_count_box.set_value(w_count_box, count - (cur_count - line.count) - cur_db_count - 1)
      return line, line.counts[index_item_slot] - 1
    end
    if cur_count < line.counts[index_item_slot] then
      return line, cur_count
    else
      cur_level = line.level
      cur_count = cur_count - line.counts[index_item_slot]
    end
    index = index + 1
  end
  return nil
end
function get_level_count_countmax()
  if bo2.player == nil then
    return
  end
  local excel = w_equip_target.info.excel
  local ptype = excel.ptype
  local index_item_slot, excel_data = find_index_item_slot(ptype.equip_slot)
  local nLevel = bo2.player:get_flag_int64(excel_data.db_jingpo_levels[index_item_slot]).v_int
  local cur_count = bo2.player:get_flag_int64(excel_data.db_jingpo_counts[index_item_slot]).v_int
  if excel_data.item_slots[index_item_slot] == bo2.eItemSlot_MainWeapon then
    nLevel = bo2.player:get_flag_int32(excel_data.db_jingpo_levels[index_item_slot])
    cur_count = bo2.player:get_flag_int32(excel_data.db_jingpo_counts[index_item_slot])
  end
  local line = GetExcelByLevel(nLevel)
  if line == nil then
    return 0, 0, 0
  end
  local count_box = ui_widget.ui_count_box.get_value(w_count_box)
  local total = cur_count + count_box
  if total < line.counts[index_item_slot] then
    return line.level, total, line.counts[index_item_slot]
  end
  local next_line, cur_count = GetExcelByLevelAndCount(nLevel, total)
  if next_line == nil then
    return 0, 0, 0
  end
  return next_line.level, cur_count, next_line.counts[index_item_slot]
end
function on_update_preview()
  if bo2.player == nil then
    return
  end
  if is_ready() then
    drop(w_equip_preview, w_equip_target.info)
    local level, count, count_max = get_level_count_countmax()
    local equip_card = w_equip_preview.parent.parent.parent.parent
    equip_card:search("level").text = level
    equip_card:search("exp_text").text = count .. "/" .. count_max
    local value = count / count_max
    value = math.min(value, 1)
    equip_card:search("exp_cur").dx = value * 85
    local count_box = ui_widget.ui_count_box.get_value(w_count_box)
    set_range()
    if count_box > 0 then
      w_btn_ok.enable = true
    else
      w_btn_ok.enable = false
    end
    ui_npcfunc.ui_cell.set(w_equip_material.parent.parent, iGemSemltProductItemID, count_box)
    local excel = w_equip_target.info.excel
    local ptype = excel.ptype
    local index_item_slot, excel_data = find_index_item_slot(ptype.equip_slot)
    local nLevel = bo2.player:get_flag_int64(excel_data.db_jingpo_levels[index_item_slot]).v_int
    if excel_data.item_slots[index_item_slot] == bo2.eItemSlot_MainWeapon then
      nLevel = bo2.player:get_flag_int32(excel_data.db_jingpo_levels[index_item_slot])
    end
    local line = GetExcelByLevel(nLevel)
    local next_line = GetExcelByLevel(level)
    w_atb:search("pre"):search("precent").text = line.add_percents[index_item_slot] .. "%"
    local datas = w_equip_target.info.excel.datas
    local add_percent_value = ui_tool.ctip_get_add_bases_atb_text(datas, line.add_percents[index_item_slot])
    w_atb:search("pre"):search("value"):search("box").mtf = add_percent_value
    w_atb:search("next"):search("precent").text = next_line.add_percents[index_item_slot] .. "%"
    local add_next_percent_value = ui_tool.ctip_get_add_bases_atb_text(datas, next_line.add_percents[index_item_slot])
    w_atb:search("next"):search("value"):search("box").mtf = add_next_percent_value
  else
    clear(w_equip_preview)
    ui_npcfunc.ui_cell.clear(w_equip_material.parent.parent)
    set_range()
    ui_widget.ui_count_box.set_value(w_count_box, 0)
    w_atb:search("pre"):search("precent").text = ""
    w_atb:search("pre"):search("value"):search("box").mtf = ""
    w_atb:search("next"):search("precent").text = ""
    w_atb:search("next"):search("value"):search("box").mtf = ""
  end
end
function on_btn_ok()
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_JingpoGuanzhu)
  v:set64(packet.key.item_key, w_equip_target.info.only_id)
  v:set(packet.key.item_count, ui_widget.ui_count_box.get_value(w_count_box))
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function on_btn_max_click(btn)
  ui_widget.ui_count_box.set_max(w_count_box)
end
function on_result_update(obj, ft, idx)
  set_range()
  on_update_preview()
  drop(w_equip_target, w_equip_target.info)
  w_btn_ok.enable = false
end
function on_self_enter(obj, msg)
  bo2.player:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_JPGZManWeaponLevel, on_result_update, "ui_npcfunc.ui_jingpo_guanzhu.on_result_update")
  bo2.player:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_JPGZManWeaponCount, on_result_update, "ui_npcfunc.ui_jingpo_guanzhu.on_result_update")
  bo2.player:insert_on_flagmsg(bo2.eFlagType_Int64, bo2.ePlayerFlagInt64_JPGZNeckLevel, on_result_update, "ui_npcfunc.ui_jingpo_guanzhu.on_result_update")
  bo2.player:insert_on_flagmsg(bo2.eFlagType_Int64, bo2.ePlayerFlagInt64_JPGZNeckCount, on_result_update, "ui_npcfunc.ui_jingpo_guanzhu.on_result_update")
  bo2.player:insert_on_flagmsg(bo2.eFlagType_Int64, bo2.ePlayerFlagInt64_JPGZFingerLevel, on_result_update, "ui_npcfunc.ui_jingpo_guanzhu.on_result_update")
  bo2.player:insert_on_flagmsg(bo2.eFlagType_Int64, bo2.ePlayerFlagInt64_JPGZFingerCount, on_result_update, "ui_npcfunc.ui_jingpo_guanzhu.on_result_update")
  for i = bo2.ePlayerFlagInt64_JPGZFeetLevel, bo2.ePlayerFlagInt64_JPGZ2ndWeaponCount do
    bo2.player:insert_on_flagmsg(bo2.eFlagType_Int64, i, on_result_update, "ui_npcfunc.ui_jingpo_guanzhu.on_result_update")
  end
end
if bo2 ~= nil then
  bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_npcfunc.ui_jingpo_guanzhu.on_self_enter")
end
