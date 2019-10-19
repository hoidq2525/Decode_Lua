local SENIOR_SEL_ACCEPT = 1
local SENIOR_SEL_REJECT = 2
cur_quest_list = {}
local quest_list_temp = {}
function ask_for_dlg(dlg_id)
  local variant = sys.variant()
  variant:set("dlg_id", dlg_id)
  bo2.send_variant(packet.eCTS_UI_SendTaskMsg, variant)
end
function send_senior_task_request(dlg_id)
  local senior_task = bo2.gv_senior_task_list:find(dlg_id)
  if senior_task == nil then
    return
  end
  local career_id_list = senior_task.career_id
  local career_id_num = career_id_list.size
  local career_right = false
  if bo2.player == nil then
    return
  end
  local player_career = bo2.player:get_atb(bo2.eAtb_Cha_Profession)
  if career_id_num > 0 then
    for i = 0, career_id_num - 1 do
      if career_id_list[i] == player_career then
        career_right = true
        break
      end
    end
  else
    local group_id_list = senior_task.group_id
    local group_id_num = group_id_list.size
    local pro_excel = bo2.gv_profession_list:find(player_career)
    if pro_excel ~= nil then
      local group_id = pro_excel.career
      if group_id ~= nil then
        for i = 0, group_id_num - 1 do
          if group_id_list[i] == group_id then
            career_right = true
            break
          end
        end
      end
    end
  end
  if career_right == false then
    return
  end
  local player_lvl = bo2.player:get_atb(bo2.eAtb_Level)
  if 0 < senior_task.level_min and player_lvl < senior_task.level_min then
    return
  end
  if 0 < senior_task.level_max and player_lvl > senior_task.level_max then
    return
  end
  local quest_data = senior_task.task_list
  local quest_id_size = quest_data.size
  if quest_id_size == 0 then
    return
  elseif quest_id_size == 1 then
    local quest_id = quest_data[0]
    local quest_list_data = bo2.gv_quest_list:find(quest_id)
    if quest_list_data == nil then
      return
    end
    local quest_temp = ui.quest_find(quest_id)
    if quest_temp ~= nil then
      return
    end
    if quest_list_data.in_theme ~= bo2.eThemeType_IM and quest_list_data.in_theme ~= bo2.eThemeType_IMNoGiveUp then
      return
    end
    if bo2.IsCoolDownOver(quest_list_data.cooldown) == false then
      return
    end
    if bo2.MayAddQuest(quest_list_data) == true then
      ask_for_dlg(dlg_id)
    end
  elseif quest_id_size > 1 then
    local size_temp = math.floor(quest_id_size / 2)
    if quest_id_size ~= size_temp * 2 then
      return
    end
    local quest_rate = 0
    for i = 0, quest_id_size - 1, 2 do
      local quest_id = quest_data[i]
      local quest_player = ui.quest_find(quest_id)
      if quest_player then
        return
      end
      local quest_list_data = bo2.gv_quest_list:find(quest_id)
      if quest_list_data == nil then
        return
      end
      if quest_list_data.in_theme ~= bo2.eThemeType_IM and quest_list_data.in_theme ~= bo2.eThemeType_IMNoGiveUp then
        return
      end
      if bo2.IsCoolDownOver(quest_list_data.cooldown) == false then
        return
      end
      if bo2.MayAddQuest(quest_list_data) ~= true then
        return
      end
    end
    ask_for_dlg(dlg_id)
  end
end
function is_exist_remind(dlg_id)
  for i = 1, table.getn(ui_im.senior_remind_quests) do
    if dlg_id == ui_im.senior_remind_quests[i] then
      return true
    end
  end
  return false
end
function add2_remind_list(dlg_id)
  if is_exist_remind(dlg_id) then
    return
  end
  local idx = table.getn(ui_im.senior_remind_quests)
  ui_im.senior_remind_quests[idx] = dlg_id
end
function del_from_remind_list(dlg_id)
  local table_size = table.getn(ui_im.senior_remind_quests)
  local idx = 1
  for i = 1, table_size do
    if ui_im.senior_remind_quests[idx] ~= nil and dlg_id == ui_im.senior_remind_quests[idx] then
      table.remove(ui_im.senior_remind_quests, idx)
      idx = idx - 1
    end
    idx = idx + 1
  end
end
function on_senior_dlg_visible(dlg)
  check_fun_btn_visible(dlg)
end
function is_in_dlg_quest_list(dlg_id, senior_dlg_quest_tree)
  if senior_dlg_quest_tree == nil then
    return
  end
  local root = senior_dlg_quest_tree.root
  local root_size = senior_dlg_quest_tree.root.item_count
  for i = 0, root_size - 1 do
    local item = senior_dlg_quest_tree.root:item_get(i)
    local dlg_id_temp = item.var:get("dlg_id").v_int
    if dlg_id == dlg_id_temp then
      return true
    end
  end
  return false
end
function is_in_cur_quest_table(dlg_id)
  local table_size = table.getn(cur_quest_list_ids)
  for i = 1, table_size do
    if dlg_id == cur_quest_list_ids[i] then
      return true
    end
  end
  return false
end
function insert_dlg_senior_quest(dlg_id, senior_dlg_quest_tree)
  if senior_dlg_quest_tree == nil then
    return
  end
  if is_in_cur_quest_table(dlg_id) == false then
    table.insert(cur_quest_list_ids, dlg_id)
  end
  if is_in_dlg_quest_list(dlg_id, senior_dlg_quest_tree) then
    return
  end
  local senior_task_data = bo2.gv_senior_task_list:find(dlg_id)
  if senior_task_data == nil then
    return
  end
  local item_uri = "$frame/im/dialog.xml"
  local item_style = "cmn_quest_item"
  if senior_dlg_quest_tree.root == nil then
    return
  end
  if senior_task_data.task_list.size <= 0 then
    return
  end
  local quest_data = bo2.gv_quest_list:find(senior_task_data.task_list[0])
  local root = senior_dlg_quest_tree.root
  local app_item = senior_dlg_quest_tree.root:item_append()
  app_item.obtain_title:load_style(item_uri, item_style)
  app_item.obtain_title:search("title_label").text = ui_im.get_quest_type(quest_data)
  app_item.obtain_title:search("title_name").text = senior_task_data.dialog_title
  app_item.var:set("dlg_id", senior_task_data.dialog_id)
  local npc_id = senior_task_data.npc_id
  local senior_data = bo2.gv_senior_npc_list:find(npc_id)
  app_item.var:set("senior_name", senior_data.name)
  app_item.selected = true
  local dlg = senior_dlg_quest_tree.topper
  check_fun_btn_visible(dlg)
end
function remove_quest_dlg_id(dlg_id)
  local table_size = table.getn(cur_quest_list_ids)
  local idx = 1
  for i = 1, table_size do
    if ui_im.cur_quest_list_ids[idx] ~= nil and dlg_id == cur_quest_list_ids[idx] then
      table.remove(cur_quest_list_ids, idx)
      idx = idx - 1
    end
    idx = idx + 1
  end
end
function del_dlg_senior_quest(dlg_id)
  remove_quest_dlg_id(dlg_id)
  if senior_dlg_quest_tree == nil then
    return
  end
  local root = senior_dlg_quest_tree.root
  local root_size = senior_dlg_quest_tree.root.item_count
  for i = 0, root_size - 1 do
    local item = senior_dlg_quest_tree.root:item_get(i)
    local dlg_id_temp = item.var:get("dlg_id").v_int
    if dlg_id == dlg_id_temp then
      on_quest_item_click(item, false)
      local senior_name = item.var:get("senior_name").v_string
      ui_im.senior_name_list[senior_name].cur_task = nil
      cur_quest_list[dlg_id] = nil
      root:item_remove(i)
      return
    end
  end
end
function decide_quest_sel(decide, dlg_id)
  if dlg_id == nil then
    return
  end
  ui.console_print("senior task id" .. dlg_id)
  local task_dlg_data = bo2.gv_senior_task_list:find(dlg_id)
  if task_dlg_data == nil then
    return
  end
  local npc_id = task_dlg_data.npc_id
  local senior_data = bo2.gv_senior_npc_list:find(npc_id)
  local senior_name = senior_data.name
  local time_var = bo2.get_svrcurtime64()
  local quest_data = sys.variant()
  quest_data:set(packet.key.senior_dlg_id, dlg_id)
  if decide == 1 then
    local accept_content = task_dlg_data.accept_content
    input_data_add(senior_name, bo2.player.name, senior_name, accept_content, time_var:get(packet.key.chat_im_time), true, true)
    quest_data:set(packet.key.senior_quest_decide, 1)
    bo2.send_variant(packet.eCTS_UI_QuestDecide, quest_data)
  else
    local reject_content = task_dlg_data.reject_content
    input_data_add(senior_name, bo2.player.name, senior_name, reject_content, time_var:get(packet.key.chat_im_time), true, true)
    if task_dlg_data.task_level == 4 then
      quest_data:set(packet.key.senior_quest_decide, 0)
      bo2.send_variant(packet.eCTS_UI_QuestDecide, quest_data)
    end
  end
  for i = 1, table.getn(accepted_quest_list_ids) do
    local quest = accepted_quest_list_ids[i]
    if dlg_id == quest.quest_id and quest.accept == false then
      quest.accept = true
    end
  end
  senior_name_list[senior_name].cur_task = nil
  local senior_dlg = find_friend_dialog(senior_name, nil, nil, true)
  if senior_dlg then
    show_chat(senior_dialog_list[senior_dlg].item)
  end
  remove_quest_dlg_id(dlg_id)
end
function on_quest_btn_click(btn, type)
  local dlg = btn.topper
  if dlg == nil then
    return
  end
  local senior_dlg_quest_tree = dlg:search("senior_dlg_quest_tree")
  if senior_dlg_quest_tree == nil then
    return
  end
  local dlg_id = senior_dlg_quest_tree.var:get("sel_dlg_id").v_int
  decide_quest_sel(type, dlg_id)
end
function on_quest_accept(btn)
  on_quest_btn_click(btn, 1)
end
function on_quest_reject(btn)
  on_quest_btn_click(btn, 0)
end
function on_quest_item_click(item, v)
  local s = item:search("select")
  s.visible = v
  s.parent.alpha = 1
  local dlg
  if v then
    local dlg_id = item.var:get("dlg_id").v_int
    if dlg_id == nil then
      return
    end
    local task_dlg_data = bo2.gv_senior_task_list:find(dlg_id)
    if task_dlg_data == nil then
      return
    end
    local npc_id = task_dlg_data.npc_id
    local senior_data = bo2.gv_senior_npc_list:find(npc_id)
    local senior_name = senior_data.name
    local time_var = bo2.get_svrcurtime64()
    local task_content = task_dlg_data.task_content
    senior_name_list[senior_name].cur_task = dlg_id
    local senior_dlg = find_friend_dialog(senior_name, nil, nil, true)
    if senior_dlg == nil then
      return
    end
    dlg = senior_dialog_list[senior_dlg].item
    show_chat(dlg)
    local senior_dlg_quest_tree = dlg:search("senior_dlg_quest_tree")
    senior_dlg_quest_tree.var:set("sel_dlg_id", dlg_id)
  else
    dlg = item.topper
    local senior_dlg_quest_tree = dlg:search("senior_dlg_quest_tree")
    senior_dlg_quest_tree.var:set("sel_dlg_id", 0)
  end
  check_fun_btn_visible(dlg)
end
function clear_imdlg_quest_list(senior_dlg_quest_tree)
  if senior_dlg_quest_tree == nil then
    return
  end
  local root = senior_dlg_quest_tree.root
  local root_size = root.item_count
  for i = 0, root_size - 1 do
    local item = root:item_get(i)
    on_quest_item_click(item, false)
    root:item_remove(i)
  end
end
function update_imdlg_quest_list(dlg, senior_name)
  if dlg == nil then
    return
  end
  local senior_dlg_quest_tree = dlg:search("senior_dlg_quest_tree")
  if senior_dlg_quest_tree == nil then
    return
  end
  clear_imdlg_quest_list(senior_dlg_quest_tree)
  for i = 1, table.getn(cur_quest_list_ids) do
    local dlg_id = cur_quest_list_ids[i]
    local senior_dlg_data = bo2.gv_senior_task_list:find(dlg_id)
    if senior_dlg_data == nil then
      return
    end
    if senior_dlg_data.task_level ~= 1 then
      local senior_npc = bo2.gv_senior_npc_list:find(senior_dlg_data.npc_id)
      if senior_npc == nil or senior_npc.name ~= senior_name then
        return
      end
      insert_dlg_senior_quest(dlg_id, senior_dlg_quest_tree)
    end
  end
end
function check_fun_btn_visible(dlg)
  if dlg == nil then
    ui.log("senior quest: senior_dialog::check_fun_btn_visible() dlg is nil")
    return
  end
  local senior_dlg_quest_tree = dlg:search("senior_dlg_quest_tree")
  if senior_dlg_quest_tree == nil then
    ui.log("senior quest: senior_dialog::check_fun_btn_visible() senior_dlg_quest_tree is nil")
    btn_quest_accept.enable = false
    btn_quest_reject.enable = false
    return
  end
  local sel_dlg_id = senior_dlg_quest_tree.var:get("sel_dlg_id").v_int
  local btn_quest_accept = dlg:search("btn_quest_accept")
  local btn_quest_reject = dlg:search("btn_quest_reject")
  if sel_dlg_id > 0 then
    btn_quest_accept.enable = true
    btn_quest_reject.enable = true
  else
    btn_quest_accept.enable = false
    btn_quest_reject.enable = false
  end
end
function insert_richbox_senior_quest(dlg_index, richbox)
  local dlg_quest = accepted_quest_list_ids[dlg_index]
  if dlg_quest ~= nil and dlg_quest.quest_id ~= nil then
    local dlg_id = dlg_quest.quest_id
    local senior_task_data = bo2.gv_senior_task_list:find(dlg_id)
    if senior_task_data == nil then
      return true
    end
    local quest_data = bo2.gv_quest_list:find(senior_task_data.task_list[0])
    if quest_data == nil then
      return true
    end
    local senior_quest_name = ui_im.get_quest_type(quest_data)
    senior_quest_name = senior_quest_name .. quest_data.name
    richbox.margin = ui.rect(15, 3, 7, 50)
    richbox.parent.dy = richbox.parent.dy + 50
    local quest_item = ui.create_control(richbox.parent, "panel")
    quest_item:load_style("$frame/im/dialog.xml", "senior_quest_item")
    quest_item:search("title_name").text = senior_quest_name
    if dlg_quest.accept == false then
      if is_in_cur_quest_table(dlg_id) then
        quest_item:search("btn_accept_quest").svar = dlg_id
        quest_item:search("btn_accept_quest").text = ui.get_text("im|senior_sel_accept")
        quest_item:search("btn_accept_quest").enable = true
      else
        quest_item:search("btn_accept_quest").visible = false
      end
    end
    return true
  end
  return false
end
function on_btn_quest_accept(btn)
  btn.text = ui.get_text("im|senior_quest_accepted")
  btn.enable = false
  local dlg_id = btn.svar
  decide_quest_sel(1, dlg_id)
end
