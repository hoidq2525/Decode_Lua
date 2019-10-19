function drop(card, info)
  local star = info:get_data_8(bo2.eItemByte_Star)
  if star == 0 then
    ui_safe.notify(10202)
    return
  end
  local c = card:search("card")
  local equip_card = c.parent.parent.parent.parent
  if equip_card.name == L("wp1") then
    local p = equip_card.parent.parent.parent
    local equip_card2 = p:search("wp2")
    local card2 = equip_card2:search("card")
    local info2 = card2.info
    if info2 ~= nil then
      local identify1 = info.excel.ridepet_identify
      local identify2 = info2.excel.ridepet_identify
      local pExcel1 = bo2.gv_equip_ridepet_identify:find(identify1)
      local pExcel2 = bo2.gv_equip_ridepet_identify:find(identify2)
      if pExcel1.nGroup ~= pExcel2.nGroup then
        clear(card2)
      end
    end
  elseif equip_card.name == L("wp2") then
    local p = equip_card.parent.parent.parent
    local equip_card1 = p:search("wp1")
    local card1 = equip_card1:search("card")
    local info1 = card1.info
    if info1 ~= nil then
      local identify1 = info1.excel.ridepet_identify
      local identify2 = info.excel.ridepet_identify
      local pExcel1 = bo2.gv_equip_ridepet_identify:find(identify1)
      local pExcel2 = bo2.gv_equip_ridepet_identify:find(identify2)
      if pExcel1.nGroup ~= pExcel2.nGroup then
        ui_safe.notify(5463)
        return
      end
    end
  end
  local nLevel = info:get_data_32(bo2.eItemUInt32_SecondLevel)
  local exp_excel = bo2.gv_assistant_level:find(nLevel)
  local cur_exp = info:get_data_32(bo2.eItemUInt32_SecondExp)
  local ass_upgrade_id = info:get_data_8(bo2.eItemByte_AssUpgradeID)
  if ass_upgrade_id > 0 then
    local ae = bo2.gv_assistant_upgrade:find(ass_upgrade_id)
    if ae ~= nil then
      equip_card:search("level").text = nLevel
      equip_card:search("exp_text").text = cur_exp .. "/" .. exp_excel.exp[ae.exp_id]
      local value = cur_exp / exp_excel.exp[ae.exp_id]
      value = math.min(value, 1)
      equip_card:search("exp_cur").dx = value * 85
    end
  end
  local ctr = card:search("card")
  ui.remove_ride_skill_info(ctr.only_id)
  local skill_max = info:get_data_32(bo2.eItemUInt32_RideFightSkillSlot)
  local skill_card = equip_card:search("skill_list")
  local control_cnt = skill_card.control_size
  for i = 0, control_cnt - 1 do
    local ctr = skill_card:control_get(i)
    local skill_ctr = ctr:search("skill")
    skill_ctr.excelid = 0
    skill_ctr.onlyid = 0
    local skill_back_lock = ctr:search("skill_back_lock")
    skill_back_lock.visible = true
    local skill_back_normal = ctr:search("skill_back_normal")
    skill_back_normal.visible = false
    local name_text_ctr = ctr:search("name_text")
    name_text_ctr.text = ""
    local level_text_ctr = ctr:search("level_text")
    level_text_ctr.text = ""
    local select_ctr = ctr:search("select")
    select_ctr.visible = false
    if i < skill_max then
      skill_back_lock.visible = false
      skill_back_normal.visible = true
      local skill_id = info:item_get_ridepet_skill_id(i)
      local ridepet_skill_excel = bo2.gv_ridepet_skill:find(skill_id)
      if ridepet_skill_excel ~= nil then
        local skill_cur_level = info:item_get_ridepet_skill_level(i)
        local skill_max_level = ridepet_skill_excel.nMaxLevel
        local skill_name = ridepet_skill_excel.name
        ui.insert_ride_skill_info(info.only_id, skill_id, skill_cur_level)
        skill_ctr.excelid = skill_id
        skill_ctr.onlyid = info.only_id
        name_text_ctr.text = skill_name
        level_text_ctr.text = skill_cur_level .. "/" .. skill_max_level
      end
    end
  end
  ui_npcfunc.ui_cell.drop(card, info)
end
function clear(card)
  if card == nil then
    return
  end
  local equip_card = card.parent.parent.parent.parent
  equip_card:search("level").text = ""
  equip_card:search("exp_text").text = ""
  equip_card:search("exp_cur").dx = ""
  local ctr = card:search("card")
  ui.remove_ride_skill_info(ctr.only_id)
  local skill_card = equip_card:search("skill_list")
  local control_cnt = skill_card.control_size
  for i = 0, control_cnt - 1 do
    local ctr = skill_card:control_get(i)
    local skill_ctr = ctr:search("skill")
    skill_ctr.excelid = 0
    skill_ctr.onlyid = 0
    local skill_back_lock = ctr:search("skill_back_lock")
    skill_back_lock.visible = true
    local skill_back_normal = ctr:search("skill_back_normal")
    skill_back_normal.visible = false
    local name_text_ctr = ctr:search("name_text")
    name_text_ctr.text = ""
    local level_text_ctr = ctr:search("level_text")
    level_text_ctr.text = ""
    local select_ctr = ctr:search("select")
    select_ctr.visible = false
  end
  ui_npcfunc.ui_cell.clear(card.parent.parent)
end
function check_drop(pn, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return false
  end
  ui.clean_drop()
  if not ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    return false
  end
  local info = ui.item_of_only_id(data:get("only_id"))
  local excel = info.excel
  if excel == nil then
    return false
  end
  local ptype = excel.ptype
  if ptype == nil then
    local v = sys.variant()
    v:set(packet.key.ui_text_id, 5456)
    ui_packet.recv_wrap(packet.eSTC_UI_ShowText, v)
    return false
  end
  if ptype.equip_slot ~= bo2.eItemSlot_RidePetWeapon then
    local v = sys.variant()
    v:set(packet.key.ui_text_id, 5456)
    ui_packet.recv_wrap(packet.eSTC_UI_ShowText, v)
    return false
  end
  return true
end
function on_card_drop(card, msg, pos, data)
  local info = ui.item_of_only_id(data:get("only_id"))
  if info == nil or check_drop(card, msg, pos, data) == false then
    return
  end
  if (bo2.eItemBox_BagBeg > info.box or info.box > bo2.eItemBox_Quest) and (bo2.eItemBox_RidePetBegin > info.box or info.box > bo2.eItemBox_RidePetEnd) and bo2.eItemArray_InSlot ~= info.box then
    return
  end
  drop(card, info)
end
function on_card_drop2(card, msg, pos, data)
  local info = ui.item_of_only_id(data:get("only_id"))
  if info == nil or check_drop(card, msg, pos, data) == false then
    return
  end
  if bo2.eItemBox_BagBeg > info.box or info.box > bo2.eItemBox_Quest then
    return
  end
  drop(card, info)
end
function on_card_mouse(card, msg, pos, wheel)
  local icon = card.icon
  if icon == nil then
    return
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_drag then
    ui.set_cursor_icon(icon.uri)
    local function on_drop_hook(w, msg, pos, data)
      if msg == ui.mouse_drop_clean then
        clear(card)
      end
    end
    local data = sys.variant()
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  elseif msg == ui.mouse_rbutton_click then
    clear(card)
  end
end
function lock_card(card, skill_id)
  card = card.parent.parent.parent.parent
  local skill_list_card = card:search("skill_list")
  local control_cnt = skill_list_card.control_size
  for i = 0, control_cnt - 1 do
    local ctr = skill_list_card:control_get(i)
    local skill_card = ctr:search("skill")
    if skill_card.excelid == skill_id then
      local info = skill_card.info
      if info ~= nil then
        info.card_lock = true
      end
      break
    end
  end
end
function clear_lock(card)
  card = card.parent.parent.parent.parent
  local skill_list_card = card:search("skill_list")
  local control_cnt = skill_list_card.control_size
  for i = 0, control_cnt - 1 do
    local ctr = skill_list_card:control_get(i)
    local skill_card = ctr:search("skill")
    local info = skill_card.info
    if info ~= nil then
      info.card_lock = false
    end
  end
end
function select_skill(card, skill_card)
  card = card.parent.parent.parent.parent
  local skill_list_card = card:search("skill_list")
  local control_cnt = skill_list_card.control_size
  for i = 0, control_cnt - 1 do
    local ctr = skill_list_card:control_get(i)
    local skill_ctr = ctr:search("skill")
    local select_ctr = ctr:search("select")
    if skill_ctr == skill_card then
      select_ctr.visible = true
    else
      select_ctr.visible = false
    end
  end
end
function clear_select(card)
  card = card.parent.parent.parent.parent
  local skill_list_card = card:search("skill_list")
  local control_cnt = skill_list_card.control_size
  for i = 0, control_cnt - 1 do
    local ctr = skill_list_card:control_get(i)
    local select_ctr = ctr:search("select")
    select_ctr.visible = false
  end
end
function get_select_skill_id(card)
  card = card.parent.parent.parent.parent
  local skill_list_card = card:search("skill_list")
  local control_cnt = skill_list_card.control_size
  for i = 0, control_cnt - 1 do
    local ctr = skill_list_card:control_get(i)
    local skill_ctr = ctr:search("skill")
    local select_ctr = ctr:search("select")
    if select_ctr.visible == true then
      return skill_ctr.excelid
    end
  end
  return 0
end
function find_skill_idx(info, skill_id)
  local idx = -1
  for i = bo2.eItemUInt32_RideFightSkillBeg, bo2.eItemUInt32_RideFightSkillEnd - 1 do
    local cur_id = info:item_get_ridepet_skill_id(i - bo2.eItemUInt32_RideFightSkillBeg)
    if cur_id > 0 and cur_id == skill_id then
      idx = i - bo2.eItemUInt32_RideFightSkillBeg
      break
    end
  end
  return idx
end
function get_skill_cnt(info)
  local cnt = 0
  for i = bo2.eItemUInt32_RideFightSkillBeg, bo2.eItemUInt32_RideFightSkillEnd - 1 do
    local value = info:get_data_32(i)
    if value > 0 then
      cnt = cnt + 1
    else
      break
    end
  end
  return cnt
end
