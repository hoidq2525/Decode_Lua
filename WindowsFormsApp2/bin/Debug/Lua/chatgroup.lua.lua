local orginal_notice = L("")
local ui_tab = ui_widget.ui_tab
local invite_list = {}
function creat_chat_group(msg)
  if msg.result == 0 then
    return
  end
  if msg.input == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.sociality_cg_name, msg.input)
  bo2.send_variant(packet.eCTS_Sociality_CreateChatGroup, v)
end
function add_member(groupid, name)
  local v = sys.variant()
  v:set(packet.key.sociality_cg_id, groupid)
  v:set(packet.key.sociality_cg_member, name)
  bo2.send_variant(packet.eCTS_Sociality_ChatGroupAddMember, v)
end
function del_member(groupid, name)
  local v = sys.variant()
  v:set(packet.key.sociality_cg_id, groupid)
  v:set(packet.key.sociality_cg_member, name)
  bo2.send_variant(packet.eCTS_Sociality_ChatGroupDelMember, v)
end
function del_cg(groupid)
  local v = sys.variant()
  v:set(packet.key.sociality_cg_id, groupid)
  bo2.send_variant(packet.eCTS_Sociality_DestroyChatGroup, v)
end
function cg_update()
  local v = sys.variant()
  v:set(packet.key.sociality_cg_id, chatgroup_list[1].id)
  bo2.send_variant(packet.eCTS_Sociality_UpdateChatGroup, v)
end
function find_chat_group(title, item, member, online)
  for k, v in pairs(chatgroup_list) do
    if title and v.title == title then
      return k
    end
    if item and v.item == item then
      return k
    end
    if member then
      for m, n in pairs(v.members) do
        if m == member then
          if online then
            return n.online
          else
            return k
          end
        end
      end
    end
  end
  return nil
end
function cg_insert_group(w, text)
  local root = w.root
  local style_uri = L("$frame/im/chatgroup.xml")
  local style_name_g = L("cg_node_group")
  local style_name_k = L("item_friend")
  local item_g = root:item_append()
  item_g:load_style(style_uri, style_name_g)
  item_g:search("group_name").text = text
  return item_g
end
function cg_insert_item(w, text)
  local child_item_uri = L("$frame/im/chatgroup.xml")
  local child_item_style = L("item_friend")
  local child_item = w:item_append()
  child_item:load_style(child_item_uri, child_item_style)
  child_item:search("label_name").text = text
  return child_item
end
function on_cg_relation()
  local tree = tree_cg_left:search("trees")
  tree.root:item_clear()
  create_sorted_friend_group_list()
  for k, v in pairs(temp_friend_group_list) do
    if v.id > -1 and v.id < 12 then
      local group = cg_insert_group(tree, v.name)
      for i, name in ipairs(friend_group_list[v.id].name) do
        cg_insert_item(group, name)
      end
    end
  end
end
function on_cg_group(btn, msg)
  local tree = tree_cg_left:search("trees")
  tree.root:item_clear()
  for k, v in pairs(chatgroup_list) do
    if v.team ~= true and v.org ~= true then
      local group = cg_insert_group(tree, v.title)
      for i, member in pairs(v.members) do
        cg_insert_item(group, member.name)
      end
    end
  end
  for k, v in pairs(chatgroup_list) do
    if v.team == true then
      local group = cg_insert_group(tree, v.title)
      for i, member in pairs(v.members) do
        cg_insert_item(group, member.name)
      end
    end
  end
  for k, v in pairs(chatgroup_list) do
    if v.org == true then
      local group = cg_insert_group(tree, v.title)
      for i, member in pairs(v.members) do
        cg_insert_item(group, member.name)
      end
    end
  end
end
function on_cg_defind_res(data)
  local tree = tree_cg_left:search("trees")
  tree.root:item_clear()
  local group = cg_insert_group(tree, ui.get_text("im|cg_find_des"))
  for i = 0, data.size - 1 do
    local v = data:get(i)
    cg_insert_item(group, v:get(packet.key.sociality_playername).v_string)
  end
  find_define_flag = false
end
function on_cg_define(btn, msg)
  local name = btn.parent.parent:search("text").text
  if name == L("") then
    ui_tool.note_insert(ui.get_text("im|cg_input_search"), "FFFF00")
    return
  end
  find_define_flag = true
  local v = sys.variant()
  v:set(packet.key.sociality_playername, name)
  bo2.send_variant(packet.eCTS_Sociality_SearchPlayer, v)
end
function on_cg_item_person_mouse(btn, msg)
  if msg == ui.mouse_lbutton_down then
    if sys.check(cg_name_select) then
      cg_name_select:search("bg_selected").visible = false
    end
    cg_name_select = btn
    cg_name_select:search("bg_selected").visible = true
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
function on_cg_create_group()
  local msg = {
    callback = creat_chat_group,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.title = ui.get_text("im|cg_create_group_title")
  msg.text = ui.get_text("im|cg_input_group_name")
  msg.input = L("")
  local limit = 16
  msg.limit = limit
  ui_widget.ui_msg_box.show_common(msg)
end
function add_member_to_right(name)
  cg_insert_item(tree_cg_right:search("trees").root, name)
end
function on_add_group_msg_box(msg)
  if msg.result == 0 then
    return
  end
  add_member(msg.group_id, msg.name)
end
function on_cg_add_member(btn)
  if sys.check(cg_name_select) then
    local num = 0
    local id
    for k, v in pairs(chatgroup_list) do
      if v.leader == bo2.player.name and v.team ~= true and v.org ~= true then
        num = num + 1
        id = v.id
      end
    end
    if num == 1 then
      local msg = {
        callback = on_add_group_msg_box,
        btn_confirm = true,
        btn_cancel = true,
        modal = true
      }
      msg.title = ui.get_text("im|invite_cg")
      msg.text = get_merge("im|invite_someone_cg", cg_name_select:search("label_name").text, "group_name", chatgroup_list[id].title)
      msg.name = cg_name_select:search("label_name").text
      msg.group_id = id
      ui_widget.ui_msg_box.show_common(msg)
      return
    end
    if not sys.check(friend_group_select) then
      ui_tool.note_insert(ui.get_text("im|select_a_group"), "ffff00")
      return
    end
    for i, v in ipairs(cg_right_tree_list) do
      if v.item:search("node_group") == friend_group_select then
        local msg = {
          callback = on_add_group_msg_box,
          btn_confirm = true,
          btn_cancel = true,
          modal = true
        }
        msg.title = ui.get_text("im|invite_cg")
        msg.text = get_merge("im|invite_someone_cg", cg_name_select:search("label_name").text, "group_name", chatgroup_list[id].title)
        msg.name = cg_name_select:search("label_name").text
        msg.group_id = id
        ui_widget.ui_msg_box.show_common(msg)
      end
    end
  else
    ui_tool.note_insert(ui.get_text("im|select_a_name"), "ffff00")
  end
end
function on_cg_del_member(btn)
  cg_update()
end
function update_chatgroup()
  local flick_item_list = {}
  my_chat_msg_num = 0
  join_chat_msg_num = 0
  my_chat_group:search("node_group").parent.suspended = true
  join_chat_group:search("node_group").parent.suspended = true
  for i = 0, my_chat_group.item_count - 1 do
    local item = my_chat_group:item_get(i)
    if item:search("item_group").suspended == false then
      my_chat_msg_num = my_chat_msg_num + 1
      flick_item_list[item.svar.id] = true
    end
  end
  if my_chat_msg_num > 0 and my_chat_group.expanded == false then
    my_chat_group:search("node_group").parent.suspended = false
  end
  for i = 0, join_chat_group.item_count - 1 do
    local item = join_chat_group:item_get(i)
    if item:search("item_group").suspended == false then
      join_chat_msg_num = join_chat_msg_num + 1
      flick_item_list[item.svar.id] = true
    end
  end
  if 0 < join_chat_msg_num and join_chat_group.expanded == false then
    join_chat_group:search("node_group").parent.suspended = false
  end
  my_chat_group:item_clear()
  join_chat_group:item_clear()
  tree_cg_right:search("trees").root:item_clear()
  cg_right_tree_list = {}
  local has_invite = false
  local selected_group
  for k, v in pairs(chatgroup_list) do
    local item
    if bo2.player.name == v.leader then
      item = insert_group_item(my_chat_group, v.title)
    else
      item = insert_group_item(join_chat_group, v.title)
    end
    item.svar.id = v.id
    v.item = item
    if flick_item_list[v.id] == true then
      item:search("item_group").suspended = false
    end
    if v.leader == bo2.player.name and v.team ~= true and v.org ~= true then
      local item_g = cg_insert_group(tree_cg_right:search("trees"), v.title)
      item_g.svar = {
        group_id = v.id
      }
      table.insert(cg_right_tree_list, {
        id = v.id,
        item = item_g,
        members = {}
      })
      for m, n in pairs(v.members) do
        local item_k = cg_insert_item(item_g, n.name)
        item_k.svar = {
          group_id = v.id,
          name = n.name,
          is_temp = false
        }
        table.insert(cg_right_tree_list[#cg_right_tree_list].members, {
          name = n.name,
          online = n.online
        })
      end
      if has_invite == false then
        for p, q in pairs(invite_list) do
          if v.id ~= q.svar.group_id then
            break
          end
          local item_k = cg_insert_item(item_g, p)
          item_k:search("label_name").color = ui.make_color("ffff00")
          q.item = item_k
          has_invite = true
          selected_group = item_g
        end
      end
      item_g.expanded = false
    end
  end
  if has_invite then
    selected_group.selected = true
    selected_group.expanded = true
  else
    invite_list = {}
    if 0 < #cg_right_tree_list then
      cg_right_tree_list[1].item.selected = true
    end
  end
  update_team_group()
  update_org_group()
  updata_group_num(my_chat_group)
  updata_group_num(join_chat_group)
end
function update_group_members()
  for k, v in pairs(friend_dialog_list) do
    if v.group == true and chatgroup_list[v.name] then
      do
        local cur_member_list = chatgroup_list[v.name].members
        local cur_list_item = v.item:search("group_friend_tree").root
        local online_num = 0
        local total_num = 0
        local bIsOrg = chatgroup_list[v.name].org
        local sort_name_tb = {}
        cur_list_item:item_clear()
        for m, n in pairs(cur_member_list) do
          local item = insert_group_friend_item(cur_list_item, n.name)
          n.item = item
          table.insert(sort_name_tb, n.name)
          local portrait = bo2.gv_portrait:find(n.portrait)
          if portrait ~= nil then
            n.item:search("rel_icon").image = g_portrait_path .. portrait.icon .. ".png"
          else
            n.item:search("rel_icon").image = uri_strange
          end
          local pro_excel = bo2.gv_profession_list:find(n.career)
          if pro_excel ~= nil then
            dir = bo2.gv_career:find(pro_excel.career).dir
            if dir ~= nil then
              SetCareerIcon(n.item:search("career_icon"), pro_excel)
            end
          end
          if n.online == 1 then
            n.item:search("label_name").color = ui.make_color("FFFF00")
            online_num = online_num + 1
          else
            n.item:search("label_name").color = ui.make_color("737373")
            n.item:search("rel_icon").effect = "gray"
            n.item:search("career_icon").effect = "gray"
          end
          if bIsOrg then
            n.priority = n.online * bo2.gv_guild_title.size + n.title
          else
            n.priority = n.online * 8
            if n.name == chatgroup_list[v.name].leader then
              n.priority = n.priority + 7
            elseif n.name == bo2.player.name then
              n.priority = n.priority + 6
            elseif friend_name_list[n.name] ~= nil then
              n.priority = n.priority + sort_priority[friend_name_list[n.name].thetype]
            end
          end
          total_num = total_num + 1
        end
        local function group_member_sort(a, b)
          return cur_member_list[a].priority > cur_member_list[b].priority
        end
        table.sort(sort_name_tb, group_member_sort)
        for i, n in ipairs(sort_name_tb) do
          cur_member_list[n].item.index = i - 1
        end
        cur_list_item:post_modify()
        v.item:search("member_list"):search("title").text = ui.get_text("im|group_chat_list") .. "(" .. online_num .. "/" .. total_num .. ")"
      end
    end
  end
  for k, v in pairs(cg_right_tree_list) do
    if chatgroup_list[v.id] then
      v.members = {}
      v.item:item_clear()
      for m, n in pairs(chatgroup_list[v.id].members) do
        local item_k = cg_insert_item(v.item, n.name)
        item_k.svar = {
          group_id = v.id,
          name = n.name,
          is_temp = false
        }
        table.insert(v.members, {
          name = n.name,
          online = n.online
        })
      end
      for p, q in pairs(invite_list) do
        if v.id == q.svar.group_id then
          local item_k = cg_insert_item(v.item, p)
          item_k:search("label_name").color = ui.make_color("ffff00")
          q.item = item_k
        end
      end
    end
  end
end
function on_cg_visible(dlg)
  if dlg.visible == false then
    return
  end
  dlg:move_to_head()
  update_chatgroup()
  on_cg_relation()
  dlg:move_to_head()
  local org_id = bo2.is_in_guild()
  if org_id ~= sys.wstring(0) then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_Guild_GetGuildList, v)
  end
  for k, v in pairs(invite_list) do
    v.item:self_remove()
  end
  invite_list = {}
end
function ack_chatgroup_invite_popo(click, data)
  local v = sys.variant()
  v:set(packet.key.sociality_requestid, data:get(packet.key.sociality_requestid))
  accept = 0
  if "yes" ~= click then
    accept = 1
  end
  v:set(packet.key.sociality_acceptrequest, accept)
  bo2.send_variant(packet.eCTS_Sociality_ResponseWaiting, v)
end
function destroy(groupid)
  chatgroup_list[groupid] = nil
  if history_list[groupid] ~= nil then
    local history_item = history_list[groupid]
    history_item:self_remove()
    history_list[groupid] = nil
  end
  local index = find_friend_dialog(groupid)
  if index then
    release_dlg(index)
  end
end
function update_team_group()
  local team_id
  for k, v in pairs(chatgroup_list) do
    if v.team == true then
      team_id = k
      break
    end
  end
  if team_id then
    local index = find_friend_dialog(team_id)
    if index then
      release_dlg(index)
    end
    chatgroup_list[team_id].item:self_remove()
    chatgroup_list[team_id] = nil
  end
  team_id = bo2.get_group_id()
  if team_id ~= sys.wstring(0) then
    local item = insert_group_item(join_chat_group, ui.get_text("im|team_group"))
    item:search("rel_icon").image = "$data/gui/image/im/btn_group_icon.png|1,21,28,20"
    item.svar.id = team_id
    chatgroup_list[team_id] = {
      id = team_id,
      notices = "",
      leader = nil,
      title = ui.get_text("im|team_group"),
      members = {},
      item = item,
      team = true
    }
    update_team_group_members()
  else
    destroy(team_id)
  end
  updata_group_num(join_chat_group)
end
function update_team_group_members()
  local team_id = bo2.get_group_id()
  if team_id ~= sys.wstring(0) then
    chatgroup_list[team_id].members = {}
    for i = 0, 19 do
      local info = ui.member_get_by_idx(i)
      if info.only_id ~= sys.wstring(0) then
        chatgroup_list[team_id].members[info.name] = {
          name = info.name,
          online = info.status,
          portrait = info:get_flag_int32(bo2.ePlayerFlagInt32_Portrait),
          career = info.career
        }
      end
    end
  end
  update_group_members()
end
function update_org_group()
  local npc_guild_index = ui.npc_guild_mb_id()
  if npc_guild_index ~= 0 then
    return
  end
  local org_id
  for k, v in pairs(chatgroup_list) do
    if v.org == true then
      org_id = k
      break
    end
  end
  if org_id then
    chatgroup_list[org_id].item:self_remove()
    chatgroup_list[org_id] = nil
  end
  org_id = bo2.is_in_guild()
  if org_id ~= sys.wstring(0) then
    local item = insert_group_item(join_chat_group, ui.guild_name())
    item:search("rel_icon").image = "$data/gui/image/im/btn_group_icon.png|1,1,28,20"
    item.svar.id = org_id
    chatgroup_list[org_id] = {
      id = org_id,
      notices = ui.guild_get_info(),
      leader = ui.guild_leader_name(),
      title = ui.guild_name(),
      members = {},
      item = item,
      org = true
    }
    update_org_group_members()
  else
    destroy(org_id)
  end
  updata_group_num(join_chat_group)
end
function update_org_group_members()
  local org_id = bo2.is_in_guild()
  if org_id ~= sys.wstring(0) then
    chatgroup_list[org_id].members = {}
    for i = 0, ui.guild_member_size() - 1 do
      local info = ui.guild_get_member(i)
      if info.id ~= sys.wstring(0) then
        chatgroup_list[org_id].members[info.name] = {
          name = info.name,
          online = info.status,
          career = info.career,
          title = info.title,
          portrait = guild_group_portrait[info.name]
        }
      end
    end
  end
  update_group_members()
end
function chg_notices(id, notices)
  local v = sys.variant()
  v:set(packet.key.sociality_cg_id, id)
  v:set(packet.key.sociality_cg_notices, notices)
  bo2.send_variant(packet.eCTS_Sociality_ChgCgNotice, v)
end
function on_chg_notices(btn)
  local item = btn.topper
  item:search("notices_confirm").visible = true
  item:search("notices_cannel").visible = true
  item:search("notices_steup").visible = false
  item:search("notices").focus_able = true
  item:search("notices").focus = true
  orginal_notice = item:search("notice"):search("notices").mtf
end
function on_chg_notices_confirm(btn)
  local item = btn.topper
  item:search("notices_confirm").visible = false
  item:search("notices_cannel").visible = false
  item:search("notices_steup").visible = true
  item:search("notices").focus_able = false
  item:search("notices").focus = false
  set_box_no_sel(item:search("notices"))
  local groupid
  local notice = item:search("notice"):search("notices").mtf
  local index = find_friend_dialog(nil, item)
  if index and notice ~= orginal_notice then
    chg_notices(friend_dialog_list[index].name, notice)
  end
end
function on_chg_notices_cannel(btn)
  local item = btn.topper
  item:search("notices_confirm").visible = false
  item:search("notices_cannel").visible = false
  item:search("notices_steup").visible = true
  item:search("notices").focus_able = false
  item:search("notices").focus = false
  set_box_no_sel(item:search("notices"))
  item:search("notice"):search("notices").mtf = orginal_notice
end
function update_notice(id, notice)
  local index = find_friend_dialog(id)
  if index then
    noice = ui.filter_mtf(notice)
    friend_dialog_list[index].item:search("notice"):search("notices").mtf = noice
    local chg_notice = ui.get_text("im|chgnoitce") .. L("\n") .. notice
    insert_msg(nil, chg_notice, id, ui.make_color("00ff00"))
  end
end
function recivie()
end
local function group_insert_tab(name)
  local btn_uri = "$frame/im/chatgroup.xml"
  local btn_sty = "tab_" .. name .. "_btn"
  ui_tab.insert_suit(w_chatgroup, name, btn_uri, btn_sty)
  local btn = ui_tab.get_button(w_chatgroup, name)
  btn.text = ui.get_text("im|" .. name)
end
function on_dlg_chatgroup_init()
  chatgroup_list = {}
  cg_right_tree_list = {}
  find_define_flag = false
  ui.insert_on_guild_refresh("ui_im.update_org_group")
  ui_tab.clear_tab_data(w_chatgroup)
  group_insert_tab("cg_contact")
  group_insert_tab("cg_group")
  group_insert_tab("cg_search")
  ui_tab.show_page(w_chatgroup, "cg_contact", true)
  tree_cg_right:search("trees"):insert_on_item_sel(function(item, sel)
    item:search("bg_selected").visible = sel
  end)
  guild_group_portrait = {}
end
function updata_group_num(chat_group)
  local group_text = ui.get_text("im|my_group")
  if chat_group ~= my_chat_group then
    group_text = ui.get_text("im|my_join_group")
  end
  if chat_group.item_count > 0 then
    group_text = group_text .. " [" .. chat_group.item_count .. "]"
  end
  chat_group:search("btn_up").text = group_text
  chat_group:search("btn_left").text = group_text
end
function on_cg_node_group_mouse(btn, msg)
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
  if msg == ui.mouse_lbutton_down then
    local group_item = btn.parent.parent
    if group_item.svar.group_id == nil then
      return
    end
    for k, v in pairs(invite_list) do
      if v ~= nil then
        ui.log("invite_list.k:%s", k)
        ui_tool.note_insert(ui.get_text("im|cg_err_not_support_multi"), "ffff00")
        return
      end
    end
    group_item.selected = true
  end
end
function on_cg_search(btn, msg)
  local on_chatgroup_edit_search_init = function(msg)
    chatgroup_edit_search:search("cg_searchname").focus = true
  end
  local on_msg = function(msg)
    if msg.result == 0 then
      return
    end
    local name = chatgroup_edit_search:search("cg_searchname").text
    if name == nil or #name == 0 then
      ui_tool.note_insert(ui.get_text("im|cg_err_no_input"), "ffff00")
      return
    end
    local tree = tree_cg_left:search("trees")
    tree.root:item_clear()
    local group = cg_insert_group(tree, ui.get_text("im|cg_find_result"))
    local find_list = {}
    local find_num = 0
    for k, v in pairs(chatgroup_list) do
      for i, member in pairs(v.members) do
        if string.find(tostring(member.name), tostring(name)) ~= nil and find_list[member.name] == nil then
          find_list[member.name] = true
          cg_insert_item(group, member.name)
          find_num = find_num + 1
        end
      end
    end
    for k, v in pairs(friend_name_list) do
      if string.find(tostring(k), tostring(name)) ~= nil and find_list[k] == nil then
        find_list[k] = true
        cg_insert_item(group, k)
        find_num = find_num + 1
      end
    end
    if find_num == 0 then
      ui_tool.note_insert(ui.get_text("im|cg_err_no_result"), "ffff00")
    end
  end
  local msg = {
    callback = on_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    init = on_chatgroup_edit_search_init,
    owner = w_chatgroup,
    style_uri = "$frame/im/chatgroup.xml",
    style_name = "chatgroup_edit_search"
  }
  ui_widget.ui_msg_box.show(msg)
end
function on_search_input_enter(ctrl)
  local btn = ctrl.topper:search("cg_btn_ok")
  if btn then
    ui_widget.ui_msg_box.on_confirm_click(btn)
  end
end
function add_invite_member(btn)
  if sys.check(cg_name_select) then
    local name = cg_name_select:search("label_name").text
    local right_tree = tree_cg_right:search("trees")
    local selected_group = right_tree.item_sel
    if selected_group == nil then
      ui_tool.note_insert(ui.get_text("im|cg_err_no_group"), "ffff00")
      return
    else
      for k, v in pairs(cg_right_tree_list) do
        if selected_group == v.item then
          for i = 1, #v.members do
            if name == v.members[i].name then
              ui_tool.note_insert(name .. ui.get_text("im|cg_err_exist_in_group"), "ffff00")
              return
            end
          end
          break
        end
      end
      if invite_list[name] == nil then
        local item = cg_insert_item(selected_group, name)
        item.svar = {
          group_id = selected_group.svar.group_id,
          name = name,
          is_temp = true
        }
        item:search("label_name").color = ui.make_color("ffff00")
        invite_list[name] = {
          item = item,
          svar = item.svar
        }
      else
        ui_tool.note_insert(name .. ui.get_text("im|cg_err_exist_in_invite"), "ffff00")
      end
      if selected_group.expanded == false then
        selected_group.expanded = true
      end
    end
  else
    ui_tool.note_insert(ui.get_text("im|select_a_name"), "ffff00")
  end
end
function del_invite_member(btn)
  if sys.check(cg_name_select) then
    local item = cg_name_select.parent.parent
    local right_tree = tree_cg_right:search("trees")
    local selected_group = right_tree.item_sel
    if item.svar.name ~= nil then
      cg_name_select = nil
      if item.svar.is_temp then
        invite_list[item.svar.name] = nil
        item:self_remove()
      else
        del_member(item.svar.group_id, item.svar.name)
      end
    else
      ui_tool.note_insert(ui.get_text("im|cg_err_only_in_right"), "ffff00")
    end
  else
    ui_tool.note_insert(ui.get_text("im|cg_err_select_del_player"), "ffff00")
  end
end
function send_invitations(btn)
  local right_tree = tree_cg_right:search("trees")
  local selected_group = right_tree.item_sel
  if selected_group ~= nil then
    local group_id = selected_group.svar.group_id
    local send_num = 0
    for k, v in pairs(invite_list) do
      v.item:self_remove()
      add_member(group_id, k)
      send_num = send_num + 1
    end
    invite_list = {}
    if send_num == 0 then
      ui_tool.note_insert(ui.get_text("im|cg_err_no_invitee"), "ffff00")
    end
  else
    ui_tool.note_insert(ui.get_text("im|select_a_group"), "ffff00")
  end
end
function on_cg_cancel_btn(btn)
  w_chatgroup.visible = false
end
