function get_livingskill_exp_dbflggid(xinfa_id)
  local size = bo2.gv_livingskill_xinfa.size
  for i = 0, size - 1 do
    local line = bo2.gv_livingskill_xinfa:get(i)
    if line ~= nil and line.xinfa_id == xinfa_id then
      return line.db_flag32_id
    end
  end
  return 0
end
function get_livingskill_exp_value(xinfa_id)
  local db_falgid = get_livingskill_exp_dbflggid(xinfa_id)
  if db_falgid == 0 then
    return
  end
  local player = bo2.player
  local exp = player:get_flag_int32(db_falgid)
  return exp
end
function may_learn_livingskill(xinfa_id)
  local xinfa_info = ui.xinfa_find(xinfa_id)
  if xinfa_info ~= nil then
    ui_chat.show_ui_text_id(76027)
    return false
  end
  return true
end
function learn_livingskill(index, xinfa_id)
  local function on_btn_msg(msg)
    if msg.result == 1 then
      local v = sys.variant()
      v:set(packet.key.cmn_type, bo2.eFuncTypeXinfa)
      v:set(packet.key.xinfa_levelup_id, xinfa_id)
      v:set(packet.key.cmn_val, 1)
      bo2.send_variant(packet.eCTS_UI_Livingskill, v)
    end
  end
  local msg = {
    callback = on_btn_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui.get_text("skill|livingskill_text_info" .. index)
  ui_widget.ui_msg_box.show_common(msg)
end
function get_lingskill_info_excel(npcfunc_id)
  local excel
  local size = bo2.gv_livingskill_xinfa.size
  for i = 0, size - 1 do
    local line = bo2.gv_livingskill_xinfa:get(i)
    if line.npcfunc_id_learn == npcfunc_id then
      excel = line
      break
    end
  end
  return excel
end
function get_lingskill_info_excel_levelup(npcfunc_id)
  local excel
  local size = bo2.gv_livingskill_xinfa.size
  for i = 0, size - 1 do
    local line = bo2.gv_livingskill_xinfa:get(i)
    if line.npcfunc_id_levelup == npcfunc_id then
      excel = line
      break
    end
  end
  return excel
end
function on_npcfunc_open_window(npcfunc_id)
  local excel = get_lingskill_info_excel(npcfunc_id)
  if excel == nil then
    return
  end
  if not may_learn_livingskill(excel.xinfa_id) then
    return
  end
  local index = excel.id
  learn_livingskill(index, excel.xinfa_id)
end
function on_init_livingskill_skill_card(ctrl, data)
end
function set_livingskill_exp(id)
  local item_list = xinfa_item_list[id]
  if item_list then
    local child_item = xinfa_item_list[id].item
    if sys.check(child_item) then
      local excel = bo2.gv_xinfa_list:find(id)
      local xinfa_name_text = excel.name
      local info = ui.xinfa_find(id)
      local exp = math.modf(get_livingskill_exp_value(id) / 100)
      local excel_levelup = bo2.gv_livingskill_levelup:find(info.level)
      if excel_levelup == nil then
        return
      end
      if info.level >= excel.level_max and exp >= excel_levelup.exp_max then
        local max_level = ui.get_text("skill|livingskill_max_level")
        xinfa_name_text = excel.name .. " " .. excel_levelup.name .. "(" .. max_level .. ")"
      else
        local next_level_exp = excel_levelup.exp_max
        xinfa_name_text = excel.name .. " " .. excel_levelup.name .. "(" .. exp .. "/" .. next_level_exp .. ")"
      end
      child_item:search("name").text = xinfa_name_text
    end
  end
end
function update_livingskill_exp()
  local size = bo2.gv_livingskill_xinfa.size
  for i = 0, size - 1 do
    local line = bo2.gv_livingskill_xinfa:get(i)
    if line ~= nil and line.xinfa_id ~= nil then
      set_livingskill_exp(line.xinfa_id)
    end
  end
end
function on_livingskill_visible(ctrl, vis)
  if ctrl.visible == true and w_living_xinfa_list:item_get(0) then
    update_livingskill_exp()
    on_xinfa_item(w_living_xinfa_list:item_get(0), ui.mouse_lbutton_click)
  end
end
function del_livingskill_xinfa(xinfa_id)
  local function on_btn_msg(msg)
    if msg.result == 1 then
      local v = sys.variant()
      v:set(packet.key.cmn_type, bo2.eFuncTypeXinfa)
      v:set(packet.key.xinfa_levelup_id, xinfa_id)
      v:set(packet.key.cmn_val, -1)
      bo2.send_variant(packet.eCTS_UI_Livingskill, v)
    end
  end
  local msg = {
    callback = on_btn_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui.get_text("skill|del_livingskill_info_confirm")
  ui_widget.ui_msg_box.show_common(msg)
end
function on_del_livingskill()
  if sys.check(last_xinfa_highlight_ctrl) then
    local id = last_xinfa_highlight_ctrl:search("xinfa_card").excel_id
    del_livingskill_xinfa(id)
  end
end
function may_levelup_livingskill(xinfa_id)
  local xinfa_info = ui.xinfa_find(xinfa_id)
  if xinfa_info == nil then
    ui_chat.show_ui_text_id(76023)
    return false
  end
  local exp = math.modf(get_livingskill_exp_value(xinfa_id) / 100)
  local excel = bo2.gv_livingskill_levelup:find(xinfa_info.level)
  if excel == nil then
    return false
  end
  local exp_max = excel.exp_max
  local excel_xinfa = bo2.gv_xinfa_list:find(xinfa_id)
  if xinfa_info.level >= excel_xinfa.level_max then
    ui_chat.show_ui_text_id(76033)
    return false
  end
  if exp < exp_max then
    ui_chat.show_ui_text_id(76190)
    return false
  end
  local p_level = bo2.player:get_atb(bo2.eAtb_Level)
  if p_level < excel.level_min then
    ui_chat.show_ui_text_id(76192)
    return false
  end
  return true
end
function on_living_xinfa_levelup(btn)
  if sys.check(last_xinfa_highlight_ctrl) then
    local id = last_xinfa_highlight_ctrl:search("xinfa_card").excel_id
    if not may_levelup_livingskill(id) then
      return
    end
    packet_xinfa_levelup(id)
  end
end
function on_livingskill_exp_mouse()
end
function levelup_livingskill(index, id)
  local function on_btn_msg(msg)
    if msg.result == 1 then
      packet_xinfa_levelup(id)
    end
  end
  local info = ui.xinfa_find(id)
  if info == nil then
    return
  end
  local level = info.level
  local mb_levelup = bo2.gv_xinfa_levelup_spend:find(level + 1)
  local exp_id = info.excel.exp_id
  local data2 = "data" .. exp_id * 2
  local req_money = mb_levelup[data2]
  local msg = {
    callback = on_btn_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  local arg = sys.variant()
  arg:set("money", req_money)
  msg.text = sys.mtf_merge(arg, ui.get_text("skill|livingskill_text_levelup_info" .. index))
  ui_widget.ui_msg_box.show_common(msg)
end
function on_npcfunc_open_window_levelup(npcfunc_id)
  local excel = get_lingskill_info_excel_levelup(npcfunc_id)
  if excel == nil then
    return
  end
  local id = excel.xinfa_id
  if not may_levelup_livingskill(id) then
    return
  end
  local index = excel.id
  levelup_livingskill(index, id)
end
function check_is_livingskill_xinfa(xinfa_id)
  local size = bo2.gv_livingskill_xinfa.size
  for i = 0, size - 1 do
    local line = bo2.gv_livingskill_xinfa:get(i)
    if line ~= nil and line.xinfa_id == xinfa_id then
      return true
    end
  end
  return false
end
function refresh_ui_livingskill(cmd, data)
  if not ui_widget.ui_tab.get_button(w_skill, "livingskill").visible then
    return
  end
  local xinfa_id = data:get(packet.key.xinfa_levelup_id).v_int
  if check_is_livingskill_xinfa(xinfa_id) then
    update_xinfa(xinfa_id)
  end
end
