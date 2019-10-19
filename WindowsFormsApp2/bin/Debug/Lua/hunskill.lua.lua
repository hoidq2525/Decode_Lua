local MAXSLOTNUM = 6
function item_rbutton_use(info)
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
end
function on_big_lock_tip(tip)
  local card = tip.owner.parent:search("card")
  local stk = sys.mtf_stack()
  stk:raw_push(ui.get_text("skill|tip_unlock_items"))
  local excel = bo2.gv_hunskill:find(card.grid - bo2.eItemSlot_HunskillBegin + 1)
  if excel == nil then
    return
  end
  local items = excel.unlock_items
  for i = 0, items.size - 1 do
    local excel_id = items[i]
    local item = ui.item_get_excel(excel_id)
    if item ~= nil then
      stk:raw_format([[

<i:%d>]], excel_id)
    end
  end
  ui_widget.tip_make_view(tip.view, stk.text)
end
function on_tip_show(tip)
  local card = tip.owner:search("card")
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    local stk = sys.mtf_stack()
    stk:raw_push(ui.get_text("skill|tip_input_item_group"))
    local excel = bo2.gv_hunskill:find(card.grid - bo2.eItemSlot_HunskillBegin + 1)
    if excel == nil then
      return
    end
    stk:raw_push([[

<c+:00FF00>]])
    stk:push(excel.input_item_group)
    stk:raw_push("<c->")
    ui_tool.ctip_show(tip.owner, stk, stk_use)
  else
    local stk = sys.mtf_stack()
    ui_tool.ctip_make_item(stk, excel, card.info)
    local stk_use
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|manuf_rclick_to_clear"), ui_tool.cs_tip_color_operation)
    ui_tool.ctip_show(tip.owner, stk, stk_use)
  end
end
function get_flag_index(idx)
  local flag = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_HunskillUnlock)
  local value = bo2.bit_and(flag, bo2.bit_lshift(1, idx))
  if value ~= 0 then
    return true
  else
    return false
  end
end
function update_hunskill()
  for i = 0, MAXSLOTNUM - 1 do
    local skill_item = w_hunskill:search("skill" .. i)
    local card = skill_item:search("skill_card")
    local small_lock = skill_item:search("small_lock")
    local name = skill_item:search("name")
    local info = ui.item_of_coord(bo2.eItemArray_InSlot, bo2.eItemSlot_HunskillBegin + i)
    if info ~= nil and info.excel ~= nil then
      local skill_id = info:get_data_32(bo2.eItemUInt32_DiaowenSkillID)
      if skill_id == 0 then
        skill_id = 0
      end
      card.excel_id = skill_id
      local excel = get_skill_excel(skill_id, 1)
      if excel ~= nil then
        name.text = excel.name
      else
        excel = get_skill_excel(skill_id, 0)
      end
      if excel ~= nil then
        name.text = excel.name
      else
        name.text = ""
      end
      small_lock.visible = false
      name.visible = true
    else
      card.excel_id = 0
      name.text = ""
      name.visible = false
      small_lock.visible = true
    end
  end
end
function update_lock_state()
  if w_hunskill_info == nil or w_hunskill == nil then
  end
  for i = 0, MAXSLOTNUM - 1 do
    if get_flag_index(i + 1) then
      local item_info = w_hunskill_info:search("item_" .. i)
      item_info:search("big_lock").visible = false
    end
  end
  local curunlock = 0
  local maxunlock = bo2.gv_define:find(1278).value
  for i = 1, MAXSLOTNUM do
    if get_flag_index(i) then
      curunlock = curunlock + 1
    end
  end
  local hunnum = w_hunskill_info:search("hunnum")
  hunnum:search("unlock_num").text = curunlock .. "/" .. maxunlock
end
function check_is_hunskill(excel_id)
  if excel_id == 0 or excel_id == nil then
    return false
  end
  local size = bo2.gv_diaowen.size
  for i = 0, size - 1 do
    local line = bo2.gv_diaowen:get(i)
    if line ~= nil and line.skill_id == excel_id then
      return true
    end
  end
  return false
end
function on_hunskill_visible(ctrl, vis)
  if not vis then
    return
  end
  w_skill:search("wuxing").visible = not vis
  w_skill:search("xinfapingfen").visible = not vis
  update_lock_state()
  update_hunskill()
end
function refresh_ui_hunskill(cmd, data)
  update_lock_state()
  update_hunskill()
end
