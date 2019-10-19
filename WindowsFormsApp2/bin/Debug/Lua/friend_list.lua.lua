sex_type_list = {
  ui.get_text("sociality|cmn_tip1"),
  ui.get_text("sociality|cmn_tip2")
}
function set_received_quest_visible(b)
  local w = ui.find_control("$frame:friends_main")
  w.visible = b
end
function on_sociality_close()
  set_received_quest_visible(false)
end
function find_friend_item(player_name)
  local root = w_current_friend_tree.root
  local root_size = root.item_count
  for i = 0, root_size - 1 do
    local item = root:item_get(i)
    local item_size = item.item_count
    for j = 0, item_size - 1 do
      local child_item = item:item_get(j)
      local name = child_item:search("player_name").text
      if tostring(player_name) == tostring(name) then
        return child_item
      end
    end
  end
  return nil
end
function ack_sociality_request_popo(click, data)
  local v = sys.variant()
  v:set(packet.key.sociality_requestid, data:get(packet.key.sociality_requestid))
  accept = 0
  if "yes" ~= click then
    accept = 1
  end
  v:set(packet.key.sociality_acceptrequest, accept)
  bo2.send_variant(packet.eCTS_Sociality_ResponseWaiting, v)
end
function find_tree_item(name)
  local root = w_current_friend_tree.root
  local root_size = root.item_count
  for i = 0, root_size - 1 do
    local item = root:item_get(i)
    local title_name = item.obtain_title:search("title_label").text
    if tostring(title_name) == tostring(name) then
      return item
    end
  end
  return nil
end
function insert_tree_item(name)
  local item = find_tree_item(name)
  if item == nil then
    local root = w_current_friend_tree.root
    local item_uri = "$frame/sociality/friend_list.xml"
    local item_style = "friend_tree_item"
    local app_item = root:item_append()
    app_item.obtain_title:load_style(item_uri, item_style)
    app_item.obtain_title:search("title_label").text = name
    return app_item
  else
    return item
  end
end
function insert_tree_item_child(tree_root, player_name, player_signature, player_state, relation_depth)
  local item_uri = "$frame/sociality/friend_list.xml"
  local item_style = "friend_tree_item_child"
  local app_item = tree_root:item_append()
  if app_item == nil then
    return
  end
  app_item.obtain_title:load_style(item_uri, item_style)
  app_item.obtain_title:search("player_name").text = player_name
  app_item.obtain_title:search("player_signature").text = player_signature.v_string
  set_relation_icon(player_name, player_state, app_item)
end
function remove_friend_item(player_name)
  local root = w_current_friend_tree.root
  local root_size = root.item_count
  local del_item_list = {}
  for i = 0, root_size - 1 do
    local item = root:item_get(i)
    local item_size = item.item_count
    local del_child_item_list = {}
    for j = 0, item_size - 1 do
      local child_item = item:item_get(j)
      local name = child_item:search("player_name").text
      if tostring(player_name) == tostring(name) then
        item:item_remove(j)
        break
      end
    end
    if item.item_count == 0 then
      root:item_remove(i)
      break
    end
  end
end
function add_friend_item(player_name, player_signature, player_state, relation_depth, relation_type, group_name_var)
  local type_name
  if group_name_var.size == 0 then
    type_name = ui.get_text("sociality|friend_type_friend")
  else
    type_name = group_name_var.v_string
  end
  local tree_item = insert_tree_item(type_name)
  local item = find_friend_item(player_name)
  if item ~= nil then
    remove_friend_item(player_name)
  end
  insert_tree_item_child(tree_item, player_name, player_signature, player_state, relation_depth)
end
function chg_friend_item_state(player_name, state)
  local item = find_friend_item(player_name)
  set_relation_icon(player_name, state, item)
end
function on_icon_mouse(ctrl, msg, pos, wheel)
  local item = ctrl.parent
  local player_name = item:search("player_name").text
  local x = ctrl.abs_area.p1.x - 200
  local y = ctrl.abs_area.p1.y
  if msg == ui.mouse_enter then
    show_player_atbs(player_name, true, x, y)
  elseif msg == ui.mouse_leave then
    show_player_atbs(player_name, false, 0, 0)
  end
end
g_portrait_path = "$image/cha/portrait/"
function show_player_atbs(player_name, visible, x, y)
  local w = ui.find_control("$frame:friend_info")
  if visible == true then
    local player_data = friend_name_list[tostring(player_name)]
    local player_atb = player_data.atb
    local player_sign = player_data.sign
    local player_pic = player_atb[tostring(bo2.eAtb_ExcelID)]
    local cha_pic_line = bo2.gv_cha_pic:find(player_pic)
    local portrait = bo2.gv_cha_pic:find(1).head_icon
    if cha_pic_line ~= nil then
      portrait = cha_pic_line.head_icon
    end
    local sex = sex_type_list[tonumber(player_atb[tostring(bo2.eAtb_Sex)])]
    local career = on_make_career_text(player_data, tonumber(player_atb[tostring(bo2.eAtb_Cha_Profession)]))
    local level = sys.format("LV%d", player_atb[tostring(bo2.eAtb_Level)])
    local area_line = bo2.gv_area_list:find(player_atb[tostring(bo2.eAtb_AreaID)])
    local area = ""
    if area_line ~= nil then
      area = area_line.name
    end
    w_friend_detail_info:search("name").text = player_name
    w_friend_detail_info:search("signature").text = player_sign
    w_friend_detail_info:search("portrait").image = g_portrait_path .. portrait
    w_friend_detail_info:search("sex").text = sex
    w_friend_detail_info:search("level").text = level
    w_friend_detail_info:search("carrer").text = career
    w_friend_detail_info:search("current_area").text = area
    w.x = x
    w.y = y
  end
  w.visible = visible
end
function remove_player_data(player_name)
  friend_list.remove(tostring(player_name))
end
function on_item_rbtn_event(item)
  if item.callback then
    item.callback(item)
  end
end
function on_item_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_enter then
    ctrl:search("high_light").visible = true
  elseif msg == ui.mouse_leave then
    ctrl:search("high_light").visible = false
  elseif msg == ui.mouse_rbutton_down then
    local friend_name = ctrl:search("player_name").text
    ui.console_print("friend_name is %s", friend_name)
    local data = {
      items = {
        {
          text = ui.get_text("menu|make_friend"),
          callback = send_friend_invite,
          id = bo2.ePortraitMenu_Friend
        },
        {
          text = ui.get_text("menu|remove_friend"),
          callback = send_remove_friend,
          id = bo2.ePortraitMenu_RemoveFriend
        }
      },
      event = on_item_rbtn_event,
      parent = ctrl.parent,
      dx = 100,
      dy = 50
    }
    ui_tool.show_menu(data)
    data.window.offset = ctrl.abs_area.p1 + pos
  end
end
function set_progress(list_item, f)
end
function on_make_career_text(player_data, pro)
  local career
  if pro == 0 then
    career = "NONE"
  end
  local career_find = bo2.gv_profession_list:find(pro)
  if career_find ~= nil then
    career = career_find.name
  end
  return career
end
function on_make_level_text(player, atb)
  local val = player:get_atb(atb.value)
  return sys.format("LV%d", val)
end
function set_relation_icon(player_name, player_online, item)
  local player_data = friend_name_list[tostring(player_name)]
  local matser_or_appren = player_data.matype
  local icon_name
  if matser_or_appren ~= 0 then
    if matser_or_appren == 1 then
      if player_online == 0 then
        icon_name = "$image/sociality/appren_offline.png"
      else
        icon_name = "$image/sociality/appren_online.png"
      end
    elseif matser_or_appren == 2 then
      if player_online == 0 then
        icon_name = "$image/sociality/master_offline.png"
      else
        icon_name = "$image/sociality/master_online.png"
      end
    else
      icon_name = "$image/sociality/temp_offline.png"
    end
  else
    local friend_type = player_data.thetype
    if friend_type == 1 then
      if player_online == 0 then
        icon_name = "$image/sociality/temp_offline.png"
      else
        icon_name = "$image/sociality/temp_online.png"
      end
    elseif friend_type == 2 then
      if player_online == 0 then
        icon_name = "$image/sociality/friend_offline.png"
      else
        icon_name = "$image/sociality/friend_online.png"
      end
    elseif friend_type == 3 or friend_type == 4 then
      if player_online == 0 then
        icon_name = "$image/sociality/marry_offline.png"
      else
        icon_name = "$image/sociality/marry_online.png"
      end
    elseif friend_type == 5 then
      if player_online == 0 then
        icon_name = "$image/sociality/sworn_offline.png"
      else
        icon_name = "$image/sociality/sworn_online.png"
      end
    else
      icon_name = "$image/sociality/temp_offline.png"
    end
  end
  item.obtain_title:search("relation_icon").image = icon_name
  local online_icon = item.obtain_title:search("online_icon")
  if player_online == 2 then
    online_icon.visible = true
    online_icon.image = "$image/sociality/afk.png"
  else
    online_icon.visible = false
  end
end
function send_friend_invite(item)
  ui.console_print("send_friend_invite end")
end
function send_remove_friend(item)
  local v = sys.variant()
  local parent = item.owner_menu.parent.parent
  local name = parent:search("player_name").text
  ui.console_print("send_remove_friend tar_name is %s", name)
  v:set(packet.key.sociality_tarplayername, name)
  v:set(packet.key.sociality_twrelationchgtype, 4)
  bo2.send_variant(packet.eCTS_Sociality_ChgTWRelation, v)
  ui.console_print("send_remove_friend end")
end
