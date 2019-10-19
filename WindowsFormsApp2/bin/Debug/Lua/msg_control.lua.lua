local msg_cur_selected
local max_record_num = 1000
local max_msg_num = 30
local cur_page = 0
local max_page = 0
local msg_insert_group = function(w, text)
  local root = w
  local style_uri = L("$frame/im/msg_control.xml")
  local style_name_g = L("msg_node_group")
  local item_g = root:item_append()
  item_g:load_style(style_uri, style_name_g)
  item_g:search("group_name").text = text
  return item_g
end
local msg_insert_item = function(w, text)
  local child_item_uri = L("$frame/im/msg_control.xml")
  local child_item_style = L("item_friend")
  local child_item = w:item_append()
  child_item:load_style(child_item_uri, child_item_style)
  child_item:search("label_name").text = text
  return child_item
end
local player_chat_save = function(x, file)
  local uri = ui_main.player_cfg_make_uri(file)
  x:bin_save(uri)
end
local insert_msg_into_box = function(txt, name, time)
  local rank = ui.mtf_rank_system
  local stk = sys.format("<c:999999>%s\n", txt)
  local info = sys.format([[
<c:23afd7><imn:%s,%s>
	]], name, time)
  local box = w_im_msg_control:search("display_record")
  if name ~= nil then
    box:insert_mtf(info, rank)
  end
  box:insert_mtf(stk, rank)
  set_box_no_sel(box)
end
function on_msg_control_visible(ctrl, vis)
  if vis == false then
    return
  end
  msg_cur_selected = nil
  w_im_msg_control:search("tool_panel").visible = false
  w_im_msg_control:search("display_record"):item_clear()
  w_im_msg_control:search("display_record"):update()
  local tree = ctrl:search("trees")
  tree.root:item_clear()
  create_sorted_friend_group_list()
  for k, v in pairs(temp_friend_group_list) do
    if v.id > -1 and v.id < 12 then
      local group = msg_insert_group(tree.root, v.name)
      for i, name in ipairs(friend_group_list[v.id].name) do
        msg_insert_item(group, name)
      end
    end
  end
end
function on_msg_node_group_mouse(btn, msg)
  local bg_fold = btn:search("bg_fold")
  if bg_fold == nil then
    return
  end
  if msg == ui.mouse_inner then
    bg_fold.visible = true
  end
  if msg == ui.mouse_outer then
    bg_fold.visible = false
  end
  if msg == ui.mouse_lbutton_up then
    local p = btn
    while true do
      if p == nil or sys.is_type(p, "ui_tree_item") then
        break
      end
      p = p.parent
    end
    if p == nil then
      return
    end
    p.expanded = not p.expanded
  end
end
local function show_record(name)
  w_im_msg_control:search("tool_panel").visible = false
  w_im_msg_control:search("display_record"):item_clear()
  local root = ui_main.player_cfg_load("chat.rec")
  if root == nil then
    insert_msg_into_box(ui.get_text("im|no_msg_record"))
    return
  end
  local contacter = root:find(name)
  if contacter == nil or contacter.size == 0 then
    insert_msg_into_box(ui.get_text("im|no_msg_record"))
  else
    max_page = math.ceil(contacter.size / max_msg_num)
    cur_page = max_page
    w_im_msg_control:search("cur_page").text = sys.format("%d/%d", cur_page, max_page)
    local date_begin = 0
    if max_page > 1 then
      w_im_msg_control:search("tool_panel").visible = true
      date_begin = contacter.size - math.mod(contacter.size, max_msg_num)
    end
    local date_str
    for i = date_begin, contacter.size - 1 do
      local msg = contacter:get(i)
      local s_name = msg:get_attribute("talker")
      local text = msg:get_attribute("text")
      local time = msg:get_attribute("time")
      local time_str = bo2.get_cpgtime(time)
      local cur_date = bo2.get_cpgdate(time)
      if cur_date ~= date_str then
        insert_msg_into_box(sys.format("--------------%s--------------", cur_date))
        date_str = cur_date
      end
      insert_msg_into_box(text, s_name, time_str)
    end
  end
  w_im_msg_control:search("btn_head").enable = true
  w_im_msg_control:search("btn_prev").enable = true
  w_im_msg_control:search("btn_next").enable = false
  w_im_msg_control:search("btn_foot").enable = false
end
function on_msg_item_person_mouse(btn, msg)
  if msg == ui.mouse_lbutton_down then
    if btn == msg_cur_selected then
      return
    end
    if sys.check(msg_cur_selected) then
      msg_cur_selected:search("bg_selected").visible = false
    end
    msg_cur_selected = btn
    msg_cur_selected:search("bg_selected").visible = true
    show_record(msg_cur_selected:search("label_name").text)
  end
  local bg_fold = btn:search("bg_fold")
  if bg_fold == nil then
    return
  end
  if msg == ui.mouse_inner then
    bg_fold.visible = true
  end
  if msg == ui.mouse_outer then
    bg_fold.visible = false
  end
end
function on_chat_record_save(cfg, root)
  if ui_im.save_friend_msg == L("false") then
    return
  end
  local root = ui_main.player_cfg_load("chat.rec")
  if root == nil then
    root = sys.xnode()
  end
  for k, v in pairs(friend_group_list) do
    if v.id > -1 and v.id < 11 then
      for p, q in ipairs(v.name) do
        if records_list[q] then
          local record = records_list[q]
          local contacter = root:get(q)
          local texts = record.input_data.texts
          local need_del_num = contacter.size + #texts - max_record_num
          if need_del_num > 0 then
            for i = 0, need_del_num - 1 do
              contacter:erase(i)
            end
          end
          for i, val in ipairs(texts) do
            if i > record.input_data.record_index then
              local s_name = val.s_name
              local text = val.text
              local time = val.time
              local message = contacter:add("msg" .. time)
              message:set_attribute("time", time)
              message:set_attribute("talker", s_name)
              message:set_attribute("text", text)
            end
          end
          record.input_data.record_index = #texts
        end
      end
    end
  end
  player_chat_save(root, "chat.rec")
end
local function get_message_from_file(begin_index)
  local root = ui_main.player_cfg_load("chat.rec")
  if root == nil then
    insert_msg_into_box(ui.get_text("im|no_msg_record"))
    return
  end
  if msg_cur_selected == nil then
    return
  end
  local date_str
  local name = msg_cur_selected:search("label_name").text
  local contacter = root:find(name)
  local cur_msg_num = 0
  for i = begin_index, contacter.size - 1 do
    local msg = contacter:get(i)
    local s_name = msg:get_attribute("talker")
    local text = msg:get_attribute("text")
    local time = msg:get_attribute("time")
    local time_str = bo2.get_cpgtime(time)
    local cur_date = bo2.get_cpgdate(time)
    if cur_date ~= date_str then
      insert_msg_into_box(sys.format("--------------%s--------------", cur_date))
      date_str = cur_date
    end
    insert_msg_into_box(text, s_name, time_str)
    cur_msg_num = cur_msg_num + 1
    if cur_msg_num >= max_msg_num then
      break
    end
  end
end
function on_chat_record_head(btn)
  w_im_msg_control:search("display_record"):item_clear()
  cur_page = 1
  w_im_msg_control:search("cur_page").text = sys.format("%d/%d", cur_page, max_page)
  get_message_from_file(0)
  w_im_msg_control:search("btn_head").enable = false
  w_im_msg_control:search("btn_prev").enable = false
  w_im_msg_control:search("btn_next").enable = true
  w_im_msg_control:search("btn_foot").enable = true
end
function on_chat_record_prev(btn)
  w_im_msg_control:search("display_record"):item_clear()
  cur_page = cur_page - 1
  w_im_msg_control:search("cur_page").text = sys.format("%d/%d", cur_page, max_page)
  get_message_from_file((cur_page - 1) * max_msg_num)
  if cur_page == 1 then
    w_im_msg_control:search("btn_head").enable = false
    w_im_msg_control:search("btn_prev").enable = false
  end
  w_im_msg_control:search("btn_next").enable = true
  w_im_msg_control:search("btn_foot").enable = true
end
function on_chat_record_next(btn)
  w_im_msg_control:search("display_record"):item_clear()
  cur_page = cur_page + 1
  w_im_msg_control:search("cur_page").text = sys.format("%d/%d", cur_page, max_page)
  get_message_from_file((cur_page - 1) * max_msg_num)
  w_im_msg_control:search("btn_head").enable = true
  w_im_msg_control:search("btn_prev").enable = true
  if cur_page == max_page then
    w_im_msg_control:search("btn_next").enable = false
    w_im_msg_control:search("btn_foot").enable = false
  end
end
function on_chat_record_foot(btn)
  w_im_msg_control:search("display_record"):item_clear()
  cur_page = max_page
  w_im_msg_control:search("cur_page").text = sys.format("%d/%d", cur_page, max_page)
  get_message_from_file((cur_page - 1) * max_msg_num)
  w_im_msg_control:search("btn_head").enable = true
  w_im_msg_control:search("btn_prev").enable = true
  w_im_msg_control:search("btn_next").enable = false
  w_im_msg_control:search("btn_foot").enable = false
end
function on_chat_record_del_all(btn)
  w_im_msg_control:search("display_record"):item_clear()
  w_im_msg_control:search("tool_panel").visible = false
  local root = ui_main.player_cfg_load("chat.rec")
  if root == nil then
    return
  end
  root:clear()
  player_chat_save(root, "chat.rec")
  if msg_cur_selected ~= nil then
    msg_cur_selected:search("bg_selected").visible = false
    msg_cur_selected = nil
  end
end
function on_chat_record_del(btn)
  w_im_msg_control:search("display_record"):item_clear()
  w_im_msg_control:search("tool_panel").visible = false
  local root = ui_main.player_cfg_load("chat.rec")
  if root == nil then
    return
  end
  if msg_cur_selected == nil then
    return
  end
  local name = msg_cur_selected:search("label_name").text
  local contacter = root:erase(name)
  player_chat_save(root, "chat.rec")
  msg_cur_selected:search("bg_selected").visible = false
  msg_cur_selected = nil
end
function on_msg_ctl_record(timer)
  timer.suspended = true
  on_chat_record_save()
end
