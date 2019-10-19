cur_quest_list_ids = {}
math.randomseed(os.time())
function insert_senior_item(list, name)
  local child_item_uri = L("$frame/im/im.xml")
  local child_item_style = L("item_friend")
  local child_item = list.item:item_append()
  child_item:load_style(child_item_uri, child_item_style)
  child_item:search("label_name").text = name
  local found_name = false
  for i, n in ipairs(list.name) do
    if n == name then
      found_name = true
      break
    end
  end
  if not found_name then
    table.insert(list.name, name)
  end
  local friend_item = senior_name_list[name]
  local flag_icon = friend_item.flag
  child_item:search("rel_icon").image = g_portrait_path .. flag_icon
  if friend_item.title ~= sys.wstring("") then
    child_item:search("xinqing2").text = friend_item.title
    child_item:search("xinqing2").color = ui.make_color(friend_item.title_color)
  end
  local npc_career = friend_item.atb[bo2.eAtb_Cha_Profession]
  local pro_excel = bo2.gv_profession_list:find(npc_career)
  if pro_excel ~= nil then
    local dir = bo2.gv_career:find(pro_excel.career).dir
    if dir ~= nil then
      SetCareerIcon(child_item:search("career_icon"), pro_excel)
    else
      child_item:search("career_icon").visible = false
    end
  else
    child_item:search("career_icon").visible = false
  end
  child_item:search("senior_icon").visible = true
  child_item:search("label_name").color = ui.make_color("FFFF00")
  senior_item_list[name] = senior_item_list[name] or {}
  senior_item_list[name].item = senior_item_list[name].item or {}
  senior_item_list[name].item[list.id] = {}
  senior_item_list[name].item[list.id].item = child_item
  senior_item_list[name].item[list.id].group = list
  child_item:search("item_person").svar.is_senior = true
  child_item:search("item_person").var:set("name", name)
  child_item:search("item_person").var:set("group", list.id)
end
function update_senior_group_num()
  local get_online_num = function(list)
    local num = 0
    for i, v in ipairs(list) do
      if senior_name_list[v] and senior_name_list[v].state == 1 then
        num = num + 1
      end
    end
    return num
  end
  local temp_group_list = friend_group_list[c_senior_group_id]
  temp_group_list.item:search("btn_up").text = sys.format("%s(%s/%s)", ui.get_text("im|my_senior"), get_online_num(temp_group_list.name), #temp_group_list.name)
  temp_group_list.item:search("btn_left").text = sys.format("%s(%s/%s)", ui.get_text("im|my_senior"), get_online_num(temp_group_list.name), #temp_group_list.name)
end
function update_senior()
  friend_group_list[c_senior_group_id].item:item_clear()
  senior_item_list = {}
  for k, v in pairs(senior_name_list) do
    insert_senior_item(friend_group_list[c_senior_group_id], k)
  end
  update_senior_group_num()
  senior_flash_items()
end
function add_senior_npc(senior_id)
  local senior_data = bo2.gv_senior_npc_list:find(senior_id)
  if senior_data == nil then
    return
  end
  local senior_name = senior_data.name
  local npc_pic_data = bo2.gv_cha_pic:find(senior_data.hero_flag)
  ui.console_print(senior_name)
  if senior_name == nil then
    return
  end
  local senior_item = {}
  senior_item.name = senior_name
  senior_item.id = senior_data.id
  senior_item.depth = 1
  senior_item.thetype = "senior"
  senior_item.owtype = {}
  senior_item.matype = 0
  senior_item.state = 1
  senior_item.sign = "ad"
  senior_item.title = senior_data.title
  senior_item.title_color = senior_data.title_color
  local npc_level = senior_data.hero_level
  if npc_level == nil then
    npc_level = 0
  end
  local npc_career = senior_data.hero_career
  local outlook_id_list = senior_data.outlook_id
  local outlook_num = outlook_id_list.size
  local cur_id_idx = math.random(0, outlook_num - 1)
  local outlook_id = outlook_id_list[cur_id_idx]
  senior_item.atb = {
    [bo2.eAtb_ExcelID] = outlook_id,
    [bo2.eAtb_Level] = npc_level,
    [bo2.eAtb_Cha_Profession] = npc_career
  }
  senior_item.flag = npc_pic_data.head_icon
  senior_item.equip = {}
  senior_item.groupid = -1
  senior_item.cur_task = nil
  senior_name_list[senior_name] = senior_item
  ui.log("Senior Hero: Add Hero, ID is " .. senior_id .. "; Name is " .. senior_name_list[senior_name].name)
  ui.console_print("senior_name_list:" .. senior_name_list[senior_name].name)
end
function on_btn_send_msg(btn)
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_SendTaskMsg, senior_data)
end
function add_task_dlg(dlg_id, self_name)
  local task_dlg_data = bo2.gv_senior_task_list:find(dlg_id)
  ui.log("Senior Quest: Add Senior Quest, Quest ID is " .. dlg_id)
  ui_im.cur_quest_list[dlg_id] = task_dlg_data.task_level
  local task_content = task_dlg_data.task_content
  local npc_id = task_dlg_data.npc_id
  local senior_data = bo2.gv_senior_npc_list:find(npc_id)
  local senior_name = senior_data.name
  local time_var = bo2.get_svrcurtime64()
  input_data_add(senior_name, senior_name, self_name, task_content, time_var:get(packet.key.chat_im_time), true)
  table.insert(accepted_quest_list_ids, {quest_id = dlg_id, accept = false})
  if task_dlg_data.task_level == 1 then
    senior_name_list[senior_name].cur_task = nil
    remove_quest_dlg_id(dlg_id)
    local senior_dlg = create_friend_dialog(senior_name, -1)
    if senior_dlg then
      show_chat(senior_dlg)
    end
    return
  elseif task_dlg_data.task_level == 3 then
    ui_im.w_senior_remind_quest.suspended = false
    add2_remind_list(dlg_id)
    insert_chat_dlg(dlg_id)
    return
  else
    insert_chat_dlg(dlg_id)
    return
  end
end
function insert_chat_dlg(dlg_id)
  local task_dlg_data = bo2.gv_senior_task_list:find(dlg_id)
  local npc_id = task_dlg_data.npc_id
  local senior_data = bo2.gv_senior_npc_list:find(npc_id)
  local senior_name = senior_data.name
  ui.console_print("add_task_dlg senior_name is" .. dlg_id .. "," .. npc_id .. "," .. senior_name)
  if senior_name_list[senior_name] == nil then
    return
  end
  local senior_dlg = find_friend_dialog(senior_name, nil, nil, true)
  if senior_dlg then
    show_chat(senior_dialog_list[senior_dlg].item)
  else
    senior_flash_items()
  end
end
function senior_flash_items()
  for p, q in pairs(friend_group_list) do
    if q.id == FG_ID_SENIOR then
      q.msg_num = nil
      q.item:search("node_group").parent.suspended = true
    end
  end
  for k, v in pairs(senior_item_list) do
    if senior_records_list[k] and #senior_records_list[k].input_data.texts > 0 and senior_records_list[k].input_data.index < #senior_records_list[k].input_data.texts then
      for m, n in pairs(v.item) do
        if n.item:search("item_person").suspended then
          inc_friend_group_msg_num(n.group)
        end
        local image = g_portrait_path .. senior_name_list[k].flag
        on_im_start(n.item:search("item_person"), image, senior_name_list[k].id)
      end
    end
  end
end
function on_senior_remind_quest(timer)
  if bo2.player == nil then
    return
  end
  local self_name = bo2.player.name
  for i = 1, table.getn(ui_im.senior_remind_quests) do
    insert_chat_dlg(senior_remind_quests[i], self_name)
  end
end
