g_excel_id = nil
g_mstone_id = nil
g_select_reward = nil
function on_move()
  local m_excel = bo2.gv_milestone_list:find(g_mstone_id)
  local excel = bo2.gv_quest_list:find(g_excel_id)
  if m_excel == nil then
    return
  end
  if excel == nil then
    return
  end
  set_milestone_quest_aim(m_excel, excel)
end
function on_update(quest_info)
  if quest_info then
    ui_handson_teach.test_complate_milestone_update(quest_info.mstone_id)
  end
  if g_excel_id ~= quest_info.excel_id then
    return
  end
  if g_mstone_id ~= quest_info.mstone_id then
    return
  end
  local w = ui.find_control("$frame:milestone_quest")
  if w.visible == false then
    return
  end
  local m_excel = bo2.gv_milestone_list:find(quest_info.mstone_id)
  local excel = bo2.gv_quest_list:find(quest_info.excel_id)
  set_milestone_quest_aim(m_excel, excel)
  local disable = bo2.gv_define:find(1108).value.v_int
  if g_excel_id == 10 and g_mstone_id == 421 and disable == 0 then
    set_visible(false)
    ui_tool.ui_xinshou_animation.test_all_anim()
  end
end
function set_visible(vis)
  local w = ui.find_control("$frame:milestone_quest")
  w.visible = vis
end
function set_milestone_quest_title(excel)
  if excel == nil then
    return
  end
  w_desc_title.text = excel.name
end
function set_milestone_quest_desc(excel)
  w_quest_desc_list:item_clear()
  if excel ~= nil then
    local details
    details = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, excel.details)
    ui_quest.box_insert_text(w_quest_desc_list, details)
    w_quest_desc_list.parent:tune_y("desc")
  end
end
function set_milestone_quest_aim(excel, quest)
  ui.log("-----------%s,%s", excel.name, quest.name)
  if excel == nil then
    return
  end
  if quest == nil then
    return
  end
  local quest_info = ui.quest_find(quest.id)
  w_quest_aim:item_clear()
  local all_text = ""
  if excel.brief ~= nil then
    local item = ui_quest.get_item(w_parent_list, "milestone_aim")
    local aim = item:search("aim")
    local goal = excel.brief
    all_text = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, goal)
    local cur_num = 0
    local obj = bo2.gv_quest_object:find(excel.req_obj)
    if obj ~= nil then
      local name1 = obj.name
      local name_repute = ui_quest.get_repute_req_name(excel.req_obj)
      name1 = name1 .. name_repute
      local obj_excel = ui.quest_get_qobj_excel(excel.req_obj, excel.req_id)
      local name2 = ""
      if obj_excel ~= nil then
        name2 = obj_excel.name
      end
      local total_num = ui_quest.get_aim_max_num(excel.req_obj, excel, 0, true)
      if quest_info == nil then
        cur_num = 0
      else
        cur_num = quest_info.mstone_comp
      end
      if total_num <= cur_num then
        cur_num = total_num
      end
      cur_num = ui_quest.reset_value(excel.req_obj, cur_num, total_num)
      local v = sys.variant()
      v:set("color", ui_quest.c_aim_color)
      v:set("do", name1)
      v:set("something", name2)
      v:set("cur_num", cur_num)
      v:set("total_num", total_num)
      local content = sys.mtf_merge(v, ui.get_text("quest|quest_object_text"))
      all_text = sys.format([[
%s
%s]], all_text, content)
    end
  end
  ui_quest.box_insert_text(w_quest_aim, all_text)
  local aim_parent = w_parent_list:search("milestone_aim")
  aim_parent:tune_y("aim_box")
end
function set_milestone_quest_rewards(excel, m)
  ui_quest.set_quest_rewards_big_icon(w_reward_list, excel, w_parent_list, "milestone_rewards", m)
end
function set_milestone_quest_select_rewards(excel, m)
  ui_quest.ui_complete.complete_select_rewards(w_select_reward_list, excel, w_parent_list, "milestone_select_rewards", m)
  ui_quest.ui_complete.set_milestone_flag(true)
end
function set_milestone(excel_id, mstone_id)
  local excel = bo2.gv_milestone_list:find(mstone_id)
  local quest = bo2.gv_quest_list:find(excel_id)
  if quest == nil then
    return
  end
  if excel == nil then
    return
  end
  set_milestone_quest_title(excel)
  set_milestone_quest_desc(excel)
  set_milestone_quest_aim(excel, quest)
  local lbl_rewards_spe = w_parent_list:search("lbl_rewards_spe")
  if lbl_rewards_spe ~= nil then
    lbl_rewards_spe.visible = false
  end
  set_milestone_quest_rewards(excel, true)
  set_milestone_quest_select_rewards(excel, true)
  ui_quest.set_all_not_visible()
  g_excel_id = excel_id
  g_mstone_id = mstone_id
  if sys.check(ui_tempshortcut.w_main_mask) then
    if not ui_tempshortcut.w_main_mask.visible then
      set_visible(true)
    end
  else
    set_visible(true)
  end
end
function show_next_milestone_popo(excel_id, mstone_id)
  ui_quest.send_next_milestone(excel_id, 0)
end
function next_milestone_popo(def, data)
  local excel_id = data:get(packet.key.quest_id).v_int
  local mstone_id = data:get(packet.key.milestone_id).v_int
  g_excel_id = excel_id
  ui.log("popo:%d", g_excel_id)
  show_next_milestone(excel_id, mstone_id)
end
function show_next_milestone(excel_id, mstone_id)
  set_milestone(excel_id, mstone_id)
  set_next_milestone(excel_id, mstone_id)
end
function show_inform_milestone(excel_id, mstone_id)
  set_milestone(excel_id, mstone_id)
  set_inform_milestone()
end
function update_select_rewards()
  local size = w_select_reward_list.item_count
  for i = 0, size - 1 do
    local item = w_select_reward_list:item_get(i)
    local select = item:search("select")
    select.visible = false
  end
end
function on_select_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    update_select_rewards()
    local parent = panel.parent
    local select = parent:search("select")
    select.visible = true
    g_select_reward = parent.index
    ui.log(parent.index)
  end
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
    local on_time_milestone = function()
      ui_handson_teach.test_complate_milestone_visible(g_mstone_id)
    end
    bo2.AddTimeEvent(5, on_time_milestone)
  else
    ui_handson_teach.test_complate_milestone_close(g_mstone_id)
    g_excel_id = nil
    g_mstone_id = nil
    g_select_reward = nil
    ui_quest.ui_complete.set_milestone_flag(false)
    ui_widget.esc_stk_pop(w)
  end
end
g_num = 122
function on_next_milestone(btn)
  ui.log("-----------------------------------")
  ui.log("%%%%%%%%%%%% %d", g_excel_id)
  if g_excel_id == nil then
    return
  end
  ui.log(w_select_reward_list.item_count)
  if w_select_reward_list.item_count ~= 0 and g_select_reward == nil then
    ui_quest.quest_show_text(ui.get_text("quest|reward_select_warning"))
    return
  end
  ui_quest.send_next_milestone(g_excel_id, g_select_reward)
  set_visible(false)
end
function on_inform(btn)
  set_visible(false)
end
function set_next_milestone(excel_id, mstone_id)
  w_next_btn.visible = true
  w_inform_btn.visible = false
  w_next_btn.text = ui.get_text("quest|milestone_next")
  local excel = bo2.gv_quest_list:find(excel_id)
  if excel == nil then
    return
  end
  local size = excel.milestones.size
  if size == 0 or size == nil then
    return
  end
  if mstone_id == excel.milestones[size - 1] then
    w_next_btn.text = ui.get_text("quest|quest_complete")
    return
  end
end
function set_inform_milestone()
  w_next_btn.visible = false
  w_inform_btn.visible = true
end
