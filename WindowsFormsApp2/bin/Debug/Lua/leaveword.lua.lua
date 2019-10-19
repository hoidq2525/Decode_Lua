flag_leaveword = -1
function insert_leaveword_confirm(data)
  ui.log("insert_leaveword_confirm")
  local name = data:get(packet.key.target_name).v_string
  local index = find_friend_dialog(name)
  if index == nil then
    return
  end
  local length = #confirm_datas
  local item = friend_dialog_list[index].item
  box = item:search("msg_box")
  local rank = ui.mtf_rank_system
  local money = bo2.gv_define_sociality:find(62).value
  local text = data:get(packet.key.chat_text).v_string
  if text.size >= 10 then
    text = text:substr(10) .. "..."
  end
  box:item_clear()
  box.visible = true
  box.parent:apply_dock(true)
  local stk = get_merge("im|leaveword_confirm", name, "text", text, "money", money, "index", length)
  box:insert_mtf(stk, rank)
  box:update_view()
  cur_leaveword_data = data
  local dy = box.extent.y
  if dy < 20 then
    dy = 20
  end
  box.dy = dy
end
function create_temp_relation(name)
  ui.log("create_temp_relation %s", name)
  local friend_item = {}
  friend_item.name = name
  friend_item.id = 0
  friend_item.thetype = 0
  friend_item.atb = {}
  friend_item.flag = {}
  friend_item.equip = {}
  friend_item.state = 0
  friend_item.depth = 0
  friend_item.groupid = 0
  local portrait = leavewords[name][#leavewords[name]].script:get(tostring(packet.key.cha_portrait))
  local cha_level = leavewords[name][#leavewords[name]].script:get(tostring(packet.key.cha_level))
  local profession = leavewords[name][#leavewords[name]].script:get(tostring(packet.key.player_career))
  if portrait then
    friend_item.flag[bo2.ePlayerFlagInt32_Portrait] = portrait
  end
  ui.log("portrait %s", portrait)
  if cha_level then
    friend_item.atb[bo2.eAtb_Level] = cha_level
  end
  ui.log("level %s", portrait)
  if profession then
    friend_item.atb[bo2.eAtb_Cha_Profession] = profession
  end
  ui.log("profession %s", profession)
  local owrelation_list = {}
  owrelation_list[bo2.OWR_Type_Temp] = true
  friend_item.owtype = owrelation_list
  friend_name_list[name] = friend_item
  update()
end
function leaveword_view(name)
  ui.log("%s %s", name, leavewords[name])
  ui.log("friend_name_list[name] %s", friend_name_list[name])
  if friend_name_list[name] == nil then
    create_temp_relation(name)
  end
  for i, v in ipairs(leavewords[name]) do
    insert_chat(name, bo2.player.name, v.content, v.time)
    local var = sys.variant()
    var:set(packet.key.mail_db_id, v.id)
    bo2.send_variant(packet.eCTS_Mail_Delete, var)
  end
  leavewords[name] = nil
end
function on_leaveword_view_all(btn)
  if sys.check(cur_selected_item) then
    local name = cur_selected_item.var:get("name").v_string
    if name then
      leaveword_view(name)
      on_im_leaveword_visible(true)
    end
  end
end
function on_leaveword_delete(btn)
  local name = cur_selected_item.var:get("name").v_string
  for i, v in ipairs(leavewords[name]) do
    local var = sys.variant()
    var:set(packet.key.mail_db_id, v.id)
    bo2.send_variant(packet.eCTS_Mail_Delete, var)
  end
  leavewords[name] = nil
  on_im_leaveword_visible(true)
end
function on_leaveword_delete_all(btn)
  for m, n in pairs(leavewords) do
    for i, j in pairs(n) do
      local v = sys.variant()
      v:set(packet.key.mail_db_id, j.id)
      bo2.send_variant(packet.eCTS_Mail_Delete, v)
    end
  end
  leavewords = {}
  on_im_leaveword_visible(true)
end
function send_leaveword_confirm(btn)
  ui.log("index %s", index)
  local data = cur_leaveword_data
  local v = sys.variant()
  v:set(packet.key.chat_channel_id, bo2.eChatChannel_PersonalIm)
  v:set(packet.key.chat_text, data:get(packet.key.chat_text).v_string)
  v:set(packet.key.target_name, data:get(packet.key.target_name).v_string)
  v:set(packet.key.im_leaveword, 1)
  bo2.send_variant(packet.eCTS_UI_Chat, v)
  btn.parent.visible = false
end
function send_leaveword_cannel(btn)
  btn.parent.visible = false
end
function set_leaveword(mt)
  local name = mt.script:get(L("sName")).v_string
  if leavewords[name] == nil then
    leavewords[name] = {}
  end
  ui.log("set_leaveword %s %s mt.id %s", name, leavewords[name], mt.id)
  table.insert(leavewords[name], mt)
  local image = "$data/gui/image/im/btn_bottom_func.png|21,1,18,17"
  on_im_start(w_leave_flash, image, flag_leaveword)
end
function insert_leaveword(view, name, time, count, content, read)
  local item = view:item_append()
  item:load_style("$frame/im/leaveword.xml", "row_lables")
  item:search("name"):search("text").text = name
  item:search("time"):search("text").text = time
  item:search("count"):search("text").text = count
  item.var:set("name", name)
  return item
end
function on_im_leaveword_visible(c)
  w_leaveword_res:item_clear()
  for k, v in pairs(leavewords) do
    ui.log("%s %s %s %s %s", k, os.date("%m/%d/%Y %X", v[#v].time), #v, v[#v].read)
    ui.log("mt.id %s", v.id)
    insert_leaveword(w_leaveword_res, k, os.date("%x %X", v[#v].time), #v, v[#v].content, v[#v].read)
  end
  on_im_end(w_leave_flash, flag_leaveword)
  w_leave_flash.visible = false
end
function on_leaveword_row_mouse(btn, msg)
  if msg == ui.mouse_lbutton_dbl then
    local name = btn.var:get("name").v_string
    leaveword_view(name)
    if find_friend_dialog(name, nil, nil, false) == nil then
      create_friend_dialog(name, 1)
    end
    btn:insert_post_invoke(on_im_leaveword_visible, "ui_im.on_leaveword_row_mouse")
  end
  if msg == ui.mouse_lbutton_up and cur_selected_item ~= btn then
    if sys.check(cur_selected_item) then
      cur_selected_item:search("bg_fold").visible = false
    end
    cur_selected_item = btn
    btn:search("bg_fold").visible = true
  end
  if msg == ui.mouse_inner and cur_selected_item ~= btn then
    btn:search("bg_fold").visible = true
  end
  if msg == ui.mouse_outer and cur_selected_item ~= btn then
    btn:search("bg_fold").visible = false
  end
end
function on_leaveword_init(c)
  leavewords = {}
  confirm_datas = {}
  cur_selected_item = nil
end
