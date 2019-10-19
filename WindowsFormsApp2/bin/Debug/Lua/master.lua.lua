master_id = nil
g_sound_receive = 501
function set_cooldown_time(excel_id)
  local cooldown = w_cooldown_p
  if cooldown == nil then
    return
  end
  local q = bo2.gv_quest_list:find(excel_id)
  if q == nil then
    cooldown.visible = false
    return
  end
  local time = bo2.get_cur_time()
  local hour = time:get(L("hour")).v_int
  local minute = time:get(L("minute")).v_int
  local second = time:get(L("second")).v_int
  local cd = bo2.gv_cooldown_list:find(q.cooldown)
  if cd == nil then
    cooldown.visible = false
    return
  end
  local over = bo2.is_cooldown_over(q.cooldown)
  if over == true then
    cooldown.visible = false
    return
  end
  local val = 0
  if cd.mode == 2 then
    local t = cd.time
    if hour < cd.time then
      val = (t - hour - 1) * 3600 + val + (59 - minute) * 60 + (60 - second)
    else
      val = (23 - hour + t) * 3600 + val + (59 - minute) * 60 + (60 - second)
    end
  end
  if val == 0 then
    cooldown.visible = false
    return
  end
  local left = cooldown:search("left")
  left.left_time = val
  cooldown.visible = true
  w_timer.suspended = false
end
function on_timer()
  local left = w_cooldown_p:search("left")
  if left.left_time.v_int <= 1 then
    w_cooldown_p.visible = false
    w_timer.suspended = true
  end
end
function on_master_quest_init()
  ui.log("master_quest_init")
end
function on_move()
end
function on_update(quest_info)
  if master_id ~= quest_info.excel_id then
    return
  end
  local w = ui.find_control("$frame:master_quest")
  if w.visible == false then
    return
  end
  update_quest_aim(quest_info)
end
function is_contain_milestone(excel)
  local size = excel.milestones.size
  if size == 0 then
    return false
  elseif size > 0 then
    return true
  end
  return false
end
function get_item(index)
  local size = w_parent_list.item_count
  if index >= size then
    return nil
  end
  return w_parent_list:item_get(index)
end
function set_master_quest(excel)
  master_id = excel.id
  ui_quest.set_all_not_visible()
  ui.log("master_id = " .. master_id)
  set_visible(true)
  set_master_quest_title(excel)
  set_master_quest_desc(excel)
  set_master_quest_aim(excel)
  local lbl_rewards_spe = w_parent_list:search("lbl_rewards_spe")
  if lbl_rewards_spe ~= nil then
    lbl_rewards_spe.visible = false
  end
  set_master_quest_rewards(excel)
  set_master_quest_select_rewards(excel)
  set_cooldown_time(excel.id)
end
function set_master_quest_title(excel)
  if excel == nil then
    return
  end
  w_desc_title.text = excel.name
end
function set_master_quest_desc(excel)
  w_quest_desc_list:item_clear()
  if excel ~= nil then
    local text = excel.text
    if text ~= nil then
      local details
      details = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, text.details)
      ui_quest.box_insert_text(w_quest_desc_list, details)
    end
    w_quest_desc_list.parent:tune_y("desc")
  end
end
function update_quest_aim(quest_info)
  local list = bo2.gv_quest_list:find(quest_info.excel_id)
  if list == nil then
    return
  end
  w_master_aim:item_clear()
  if list.text ~= nil then
    local goal = list.text.goal
    local all_text = ""
    all_text = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, goal)
    for i = 0, 3 do
      local cur_num = 0
      local obj = bo2.gv_quest_object:find(list.req_obj[i])
      if obj ~= nil then
        local name1 = obj.name
        local name_repute = ui_quest.get_repute_req_name(list.req_obj[i])
        name1 = name1 .. name_repute
        local excel = ui.quest_get_qobj_excel(list.req_obj[i], list.req_id[i])
        local name2 = ""
        if excel ~= nil then
          name2 = excel.name
        end
        local total_num = ui_quest.get_aim_max_num(list.req_obj[i], list, i, false)
        cur_num = ui_quest.reset_value(list.req_obj[i], cur_num, total_num)
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
    ui_quest.box_insert_text(w_master_aim, all_text)
    w_master_aim.parent:tune_y("aim_quest")
  end
end
function set_master_quest_aim(list)
  if list == nil then
    return
  end
  w_master_aim:item_clear()
  if list.text ~= nil then
    local goal = list.text.goal
    local all_text = ""
    all_text = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, goal)
    for i = 0, 3 do
      local cur_num = 0
      local obj = bo2.gv_quest_object:find(list.req_obj[i])
      if obj ~= nil then
        local name1 = obj.name
        local excel = ui.quest_get_qobj_excel(list.req_obj[i], list.req_id[i])
        local name2 = ""
        if excel ~= nil then
          name2 = excel.name
        end
        if list.req_obj[i] == bo2.eQuestObj_CompleteMilestones then
          name2 = ui.get_text("quest|milestone_step")
        end
        local total_num = ui_quest.get_aim_max_num(list.req_obj[i], list, i, false)
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
    ui_quest.box_insert_text(w_master_aim, all_text)
    w_master_aim.parent:tune_y("aim_quest")
  end
end
function set_master_quest_rewards(excel)
  ui_quest.set_quest_rewards_big_icon(w_reward_list, excel, w_parent_list, "quest_rewards")
end
function set_master_quest_select_rewards(excel)
  ui_quest.set_quest_select_rewards_big_icon(w_select_rewards_list, excel, w_parent_list, "quest_select_rewards")
  w_select_rewards_list.parent:tune_y("quest_select_rewards")
end
function set_visible(b)
  local w = ui.find_control("$frame:master_quest")
  w.visible = b
end
g_num = 1
function on_master_quest_receive(btn)
  local excel = bo2.gv_quest_list:find(master_id)
  local q_info = ui.quest_find(master_id)
  if excel == nil or excel.in_theme == bo2.eThemeType_Mission then
    set_visible(false)
    local info = ui.quest_find(master_id)
    if info == nil then
      ui_quest.quest_paly_sound(g_sound_receive)
      ui_quest.add(master_id)
      set_visible(false)
      return
    end
    local excel_m = bo2.gv_milestone_list:find(info.mstone_id)
    if excel_m == nil then
      return
    end
    if info.mstone_comp >= excel_m.req_num then
      return
    end
    ui_quest.ui_milestone.show_inform_milestone(excel.id, excel_m.id)
    return
  end
  if q_info ~= nil then
    set_visible(false)
    local excel_m = bo2.gv_milestone_list:find(q_info.mstone_id)
    if excel_m == nil then
      return
    end
    if q_info.mstone_comp >= excel_m.req_num then
      return
    end
    ui_quest.ui_milestone.show_inform_milestone(excel.id, excel_m.id)
    return
  end
  if ui_npcfunc.ui_talk.g_talk_sel_id == master_id and ui_npcfunc.ui_talk.talk_obj ~= nil then
    if not ui_npcfunc.ui_talk.talk_obj:playsound(bo2.eSE_Talk_CloseQuestTalk) then
      ui_quest.quest_paly_sound(g_sound_receive)
    end
  else
    ui_quest.quest_paly_sound(g_sound_receive)
  end
  ui_quest.add(master_id)
  ui.log("try add quest:%d", master_id)
  set_visible(false)
  if excel == nil then
    return
  end
end
function on_master_close(btn)
  set_visible(false)
end
