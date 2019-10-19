function chat(data)
  local name = data[packet.key.sociality_personals_name]
  ui_chat.set_channel(bo2.eChatChannel_PersonalChat, name)
end
function talk_with_im(data)
  local name = data[packet.key.sociality_personals_name]
  ui_im.create_friend_dialog(name.v_string)
end
function add_friend(data)
  local name = data[packet.key.sociality_personals_name]
  ui_sociality.send_make_friend_with_cha(name)
end
function join_guild(data)
  local id = data[packet.key.sociality_personals_guild_onlyid]
  ui_guild_mod.ui_apply_win.set_apply_info(3, id)
  ui_guild_mod.ui_apply_win.w_apply_main.visible = true
end
function talk_to_leader(data)
  local name = data[packet.key.sociality_personals_guild_leader_name]
  ui_chat.set_channel(bo2.eChatChannel_PersonalChat, name)
end
function im_talk_to_leader(data)
  local name = data[packet.key.sociality_personals_guild_leader_name]
  ui_im.create_friend_dialog(name.v_string)
end
function see_detail(data)
  local name = data[packet.key.sociality_personals_name]
  ui_im.create_info_dlg(name.v_string)
end
function see_leader_detail(data)
  local name = data[packet.key.sociality_personals_guild_leader_name]
  ui_im.create_info_dlg(name.v_string)
end
ui.get_text(sys.format("advertise|%s", name))
advertise_menu_datas = {}
advertise_menu_datas.chat = {
  text = ui.get_text("advertise|menu_chat"),
  func = chat
}
advertise_menu_datas.talk_with_im = {
  text = ui.get_text("advertise|menu_talk_im"),
  func = talk_with_im
}
advertise_menu_datas.add_friend = {
  text = ui.get_text("advertise|menu_add_friend"),
  func = add_friend
}
advertise_menu_datas.join_guild = {
  text = ui.get_text("advertise|menu_join_guild"),
  func = join_guild
}
advertise_menu_datas.see_detail = {
  text = ui.get_text("advertise|menu_see_detial"),
  func = see_detail
}
advertise_menu_datas.talk_to_leader = {
  text = ui.get_text("advertise|menu_talk_to_leader"),
  func = talk_to_leader
}
advertise_menu_datas.im_talk_to_leader = {
  text = ui.get_text("advertise|menu_im_talk_to_leader"),
  func = im_talk_to_leader
}
advertise_menu_datas.see_leader_detail = {
  text = ui.get_text("advertise|menu_see_leader_detail"),
  func = see_leader_detail
}
advertise_rb_menu = {}
advertise_rb_menu[bo2.PersonalsType_FindHusband] = {}
advertise_rb_menu[bo2.PersonalsType_FindHusband][1] = advertise_menu_datas.chat
advertise_rb_menu[bo2.PersonalsType_FindHusband][2] = advertise_menu_datas.add_friend
advertise_rb_menu[bo2.PersonalsType_FindHusband][3] = advertise_menu_datas.talk_with_im
advertise_rb_menu[bo2.PersonalsType_FindHusband][4] = advertise_menu_datas.see_detail
advertise_rb_menu[bo2.PersonalsType_FindWife] = {}
advertise_rb_menu[bo2.PersonalsType_FindWife][1] = advertise_menu_datas.chat
advertise_rb_menu[bo2.PersonalsType_FindWife][2] = advertise_menu_datas.add_friend
advertise_rb_menu[bo2.PersonalsType_FindWife][3] = advertise_menu_datas.talk_with_im
advertise_rb_menu[bo2.PersonalsType_FindWife][4] = advertise_menu_datas.see_detail
advertise_rb_menu[bo2.PersonalsType_FindSworn] = {}
advertise_rb_menu[bo2.PersonalsType_FindSworn][1] = advertise_menu_datas.chat
advertise_rb_menu[bo2.PersonalsType_FindSworn][2] = advertise_menu_datas.add_friend
advertise_rb_menu[bo2.PersonalsType_FindSworn][3] = advertise_menu_datas.talk_with_im
advertise_rb_menu[bo2.PersonalsType_FindSworn][4] = advertise_menu_datas.see_detail
advertise_rb_menu[bo2.PersonalsType_FindMaster] = {}
advertise_rb_menu[bo2.PersonalsType_FindMaster][1] = advertise_menu_datas.chat
advertise_rb_menu[bo2.PersonalsType_FindMaster][2] = advertise_menu_datas.add_friend
advertise_rb_menu[bo2.PersonalsType_FindMaster][3] = advertise_menu_datas.talk_with_im
advertise_rb_menu[bo2.PersonalsType_FindMaster][4] = advertise_menu_datas.see_detail
advertise_rb_menu[bo2.PersonalsType_FindAppren] = {}
advertise_rb_menu[bo2.PersonalsType_FindAppren][1] = advertise_menu_datas.chat
advertise_rb_menu[bo2.PersonalsType_FindAppren][2] = advertise_menu_datas.add_friend
advertise_rb_menu[bo2.PersonalsType_FindAppren][3] = advertise_menu_datas.talk_with_im
advertise_rb_menu[bo2.PersonalsType_FindAppren][4] = advertise_menu_datas.see_detail
advertise_rb_menu[bo2.PersonalsType_JoinGuild] = {}
advertise_rb_menu[bo2.PersonalsType_JoinGuild][1] = advertise_menu_datas.chat
advertise_rb_menu[bo2.PersonalsType_JoinGuild][2] = advertise_menu_datas.add_friend
advertise_rb_menu[bo2.PersonalsType_JoinGuild][3] = advertise_menu_datas.talk_with_im
advertise_rb_menu[bo2.PersonalsType_JoinGuild][4] = advertise_menu_datas.see_detail
advertise_rb_menu[bo2.PersonalsType_FindGuildMember] = {}
advertise_rb_menu[bo2.PersonalsType_FindGuildMember][1] = advertise_menu_datas.talk_to_leader
advertise_rb_menu[bo2.PersonalsType_FindGuildMember][2] = advertise_menu_datas.im_talk_to_leader
advertise_rb_menu[bo2.PersonalsType_FindGuildMember][3] = advertise_menu_datas.join_guild
advertise_rb_menu[bo2.PersonalsType_FindGuildMember][4] = advertise_menu_datas.see_leader_detail
function on_rb_click(ctrl, pos)
  local parent_page = ui_widget.ui_tab.get_show_page(gx_main_win)
  if parent_page == nil then
    return
  end
  local cur_page = ui_widget.ui_tab.get_show_page(parent_page)
  local type = cur_page.var.v_int
  local t = advertise_rb_menu[type]
  local items = {}
  for i, v in ipairs(t) do
    local item = {
      id = v.id,
      color = v.color,
      text = v.text,
      style_uri = v.style_uri,
      style = v.style,
      func = v.func
    }
    table.insert(items, item)
  end
  local function on_select(item)
    local svar = ctrl.svar
    local addition_data = svar.addition_data
    item.func(addition_data)
  end
  local size = #t
  local vs
  if size > 7 then
    size = 7
    vs = true
  end
  local dy = size * 28 + 20
  local advertise_menu = {
    items = items,
    event = on_select,
    dx = 140,
    dy = dy,
    vs = vs
  }
  ui_tool.show_menu(advertise_menu)
  advertise_menu.window.offset = ctrl.abs_area.p1 + pos
end
