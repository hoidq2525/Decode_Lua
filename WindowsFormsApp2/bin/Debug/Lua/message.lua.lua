function on_im_start(c, image, name)
  local function add_qlink_flash()
    local c = w_im_flash
    if image then
      w_qlink_flash.visible = true
      for i, v in ipairs(w_qlink_flash.svar.names) do
        if v.name == name then
          return
        end
      end
      w_qlink_flash.image = image
      table.insert(w_qlink_flash.svar.names, {name = name, image = image})
      w_qlink_flash.image = w_qlink_flash.svar.names[#w_qlink_flash.svar.names].image
      c.parent:search("button_picture").visible = false
      c.visible = true
      c.suspended = false
    else
    end
  end
  add_qlink_flash()
  if c == nil then
    return
  end
  c.visible = true
  c.suspended = false
end
function on_im_end(c, name)
  local function refresh_qlink()
    local names = w_qlink_flash.svar.names
    c = w_im_flash
    if #names == 0 then
      c.visible = false
      w_qlink_flash.visible = false
      c.parent:search("button_picture").visible = true
      c.suspended = true
    else
      local name = names[#names].name
      local image = names[#names].image
      w_qlink_flash.visible = true
      w_qlink_flash.image = image
      w_qlink_flash.image = w_qlink_flash.svar.names[#w_qlink_flash.svar.names].image
      c.parent:search("button_picture").visible = false
    end
  end
  if c == nil then
    refresh_qlink()
    return
  end
  c.suspended = true
  for i, v in ipairs(w_qlink_flash.svar.names) do
    if v.name == name then
      table.remove(w_qlink_flash.svar.names, i)
      refresh_qlink()
      break
    end
  end
end
function on_qlink_friend()
  if w_qlink_flash.visible == false then
    w_main.visible = not w_main.visible
    return
  end
  local names = w_qlink_flash.svar.names
  if #names == 0 then
    return
  end
  local id = names[#names].name
  if id == flag_leaveword then
    w_leaveword.visible = true
    return
  end
  for k, v in pairs(senior_name_list) do
    if id == v.id then
      create_friend_dialog(k, -1)
      return
    end
  end
  if chatgroup_list[id] == nil then
    create_friend_dialog(id, 1)
  else
    create_group_dialog(chatgroup_list[id].title, id)
  end
end
function flash_items()
  for p, q in pairs(friend_group_list) do
    if q.id ~= FG_ID_SENIOR then
      q.msg_num = nil
      q.item:search("node_group").parent.suspended = true
    end
  end
  for k, v in pairs(friend_item_list) do
    if records_list[k] and #records_list[k].input_data.texts > 0 and records_list[k].input_data.index < #records_list[k].input_data.texts then
      local bIsStranger = false
      for m, n in pairs(v.item) do
        local friend_item = friend_name_list[k]
        if friend_item == nil then
          return
        end
        local portrait = bo2.gv_portrait:find(friend_item.flag[bo2.ePlayerFlagInt32_Portrait])
        if portrait ~= nil and m < 12 then
          if n.item:search("item_person").suspended then
            inc_friend_group_msg_num(n.group)
          end
          local image = g_portrait_path .. portrait.icon .. ".png"
          on_im_start(n.item:search("item_person"), image, k)
          if m == 11 then
            bIsStranger = true
          end
          break
        end
      end
      if history_list[k] ~= nil then
        on_im_start(history_list[k]:search("item_person"))
      elseif bIsStranger then
        update_history(k)
        on_im_start(history_list[k]:search("item_person"))
      end
    end
  end
  if ui_im.group_msg_tip == L("false") then
    return
  end
  for k, v in pairs(chatgroup_list) do
    if records_list[k] and #records_list[k].input_data.texts > 0 and records_list[k].input_data.index < #records_list[k].input_data.texts then
      if v.team or v.org then
      elseif v.item:search("item_group").suspended then
        local image = "$data/gui/image/im/btn_group_icon.png|1,41,28,20"
        on_im_start(v.item:search("item_group"), image, k)
        if v.leader == bo2.player.name then
          my_chat_msg_num = my_chat_msg_num + 1
          if 0 < my_chat_msg_num and my_chat_group.expanded == false then
            my_chat_group:search("node_group").parent.suspended = false
          end
        else
          join_chat_msg_num = join_chat_msg_num + 1
          if 0 < join_chat_msg_num and join_chat_group.expanded == false then
            join_chat_group:search("node_group").parent.suspended = false
          end
        end
      end
      if history_list[k] ~= nil then
        on_im_start(history_list[k]:search("item_group"))
      end
    end
  end
end
function namenode(records, name)
  if not records[name] then
    records[name] = {
      name = name,
      input_data = {
        limit = 200,
        index = 0,
        record_index = 0,
        texts = {}
      }
    }
  end
  return records[name]
end
function set_index_end(name)
  if records_list[name] then
    local input_data = records_list[name].input_data
    input_data.index = #input_data.texts
  end
end
function input_data_add(name, s_name, t_name, txt, time, is_senior, is_answer)
  local input_data
  if is_senior then
    input_data = namenode(senior_records_list, name).input_data
  else
    input_data = namenode(records_list, name).input_data
    update_history(name)
    if w_msg_ctl_record.suspended then
      w_msg_ctl_record.suspended = false
    end
  end
  local texts = input_data.texts
  local limit = input_data.limit
  while limit < #texts do
    table.remove(texts, 1)
    input_data.index = input_data.index - 1
  end
  table.insert(texts, {
    s_name = s_name,
    t_name = t_name,
    text = txt,
    time = time,
    is_senior_asw = is_answer
  })
end
function inc_friend_group_msg_num(list)
  if list.msg_num == nil then
    list.msg_num = 1
  else
    list.msg_num = list.msg_num + 1
  end
  if list.msg_num > 0 and list.item.expanded == false then
    list.item:search("node_group").parent.suspended = false
  end
end
function dec_friend_group_msg_num(list)
  if list.msg_num == nil then
    return
  elseif list.msg_num > 0 then
    list.msg_num = list.msg_num - 1
  end
  local group_flicker = list.item:search("node_group").parent
  if list.msg_num == 0 and group_flicker.suspended == false then
    group_flicker.suspended = true
  end
end
