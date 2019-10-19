local online = true
local list_type = 0
local cur_page = 1
local max_page = 1
local sort = 0
local sort_table = {}
local select, option, appoint_id
local ui_chat_list = ui_widget.ui_chat_list
local member_menu, apply_menu, status_menu
function on_init(ctrl)
  g_member_list:item_clear()
  online = true
  list_type = 0
  cur_page = 1
  sort = 0
  sort_table.name = true
  sort_table.level = true
  sort_table.career = true
  sort_table.pos = true
  sort_table.area = true
  sort_table.status = true
  sort_table.line = true
  ui.insert_on_family_refresh("ui_org.ui_family.on_refresh")
end
function on_refresh()
  refresh()
end
function menu_remove(items, id)
  for i = 1, table.maxn(items) do
    if items[i].id == id then
      table.remove(items, i)
      return
    end
  end
end
function member_menu_init(ctrl)
  member_menu = {
    name = "family_member_menu",
    items = {
      {
        text = ui.get_text("org|setpos"),
        callback = on_set_position,
        id = "setpos"
      },
      {
        text = ui.get_text("org|kick"),
        callback = on_kick_member,
        id = "member"
      }
    },
    event = on_family_menu_event,
    popup = "x1y1",
    source = ctrl
  }
end
function apply_menu_init(ctrl)
  apply_menu = {
    name = "family_apply_menu",
    items = {
      {
        text = ui.get_text("org|applytext"),
        callback = on_query_apply,
        id = "apply"
      },
      {
        text = ui.get_text("org|accept"),
        callback = on_accept_apply,
        id = "accept"
      },
      {
        text = ui.get_text("org|refuse"),
        callback = on_refuse_apply,
        id = "refuse"
      }
    },
    event = on_family_menu_event,
    popup = "x1y1",
    source = ctrl
  }
end
function status_menu_init(ctrl)
  status_menu = {
    name = "family_status_menu",
    items = {
      {
        text = ui.get_text("org|status"),
        callback = on_status_status,
        id = "status"
      },
      {
        text = ui.get_text("org|line"),
        callback = on_status_line,
        id = "line"
      }
    },
    event = on_family_menu_event,
    popup = "y2x2",
    source = ctrl
  }
end
function on_family_menu_event(item)
  if item.callback then
    item:callback()
  end
end
function menu_remove(items, id)
  for i = 1, table.maxn(items) do
    if items[i].id == id then
      table.remove(items, i)
      return
    end
  end
end
function refresh_member()
  if ui_tool.get_menu_name() == "family_member_menu" then
    ui_tool.hide_menu()
  end
  g_member_list:item_clear()
  select = nil
  ui.family_refresh(list_type, cur_page, sort, online)
  max_page = ui.family_member_max_page()
  if max_page < cur_page then
    cur_page = max_page
    ui.family_refresh(list_type, cur_page, sort, online)
  end
  local item_file = "$frame/org/family.xml"
  local item_style = "family_item"
  for i = 0, ui.family_member_size() - 1 do
    local item = g_member_list:item_append()
    item:load_style(item_file, item_style)
    local ui_family_member
    member = ui.family_get_member(i)
    local id = item:search("id")
    id.text = member.id
    local name = item:search("name")
    name.text = member.name
    local level = item:search("level")
    level.text = member.level
    local pos = item:search("pos")
    pos.text = ui.get_text("org|family_pos" .. member.position)
    local career = item:search("career")
    local excel = bo2.gv_profession_list:find(member.career)
    if excel == nil then
      career.text = L("")
    else
      career.text = excel.name
    end
    local area = item:search("area")
    excel = bo2.gv_area_list:find(member.area)
    if excel == nil then
      area.text = L("")
    else
      area.text = excel.name
    end
    local status = item:search("status")
    if option == "status" then
      status.text = ui.get_text("org|status" .. member.status)
    else
      status.text = ui.get_text("org|line" .. member.line)
    end
    if member.status == 0 then
      name.color = ui.make_color("808080")
      level.color = ui.make_color("808080")
      career.color = ui.make_color("808080")
      pos.color = ui.make_color("808080")
      area.color = ui.make_color("808080")
      status.color = ui.make_color("808080")
    end
  end
end
function refresh_apply()
  if ui_tool.get_menu_name() == "family_apply_menu" then
    ui_tool.hide_menu()
  end
  g_member_list:item_clear()
  select = nil
  ui.family_refresh(list_type, cur_page, sort, online)
  max_page = ui.family_apply_max_page()
  if max_page < cur_page then
    cur_page = max_page
    ui.family_refresh(list_type, cur_page, sort, online)
  end
  local item_file = "$frame/org/family.xml"
  local item_style = "family_item"
  for i = 0, ui.family_apply_size() - 1 do
    local item = g_member_list:item_append()
    item:load_style(item_file, item_style)
    local ui_family_apply
    member = ui.family_get_apply(i)
    local id = item:search("id")
    id.text = member.id
    local name = item:search("name")
    name.text = member.name
    local level = item:search("level")
    level.text = member.level
    local pos = item:search("pos")
    pos.text = ui.get_text("org|family_pos1")
    local career = item:search("career")
    local excel = bo2.gv_profession_list:find(member.career)
    if excel == nil then
      career.text = L("")
    else
      career.text = excel.name
    end
    local area = item:search("area")
    excel = bo2.gv_area_list:find(member.area)
    if excel == nil then
      area.text = L("")
    else
      area.text = excel.name
    end
    local status = item:search("status")
    if option == "status" then
      status.text = ui.get_text("org|status" .. member.status)
    else
      status.text = ui.get_text("org|line" .. member.line)
    end
    if member.status == 0 then
      name.color = ui.make_color("808080")
      level.color = ui.make_color("808080")
      career.color = ui.make_color("808080")
      pos.color = ui.make_color("808080")
      area.color = ui.make_color("808080")
      status.color = ui.make_color("808080")
    end
  end
end
function refresh_news()
  ui_chat_list.clear(g_news_list)
  for i = 0, ui.family_news_size() - 1 do
    ui_chat_list.insert(g_news_list, {
      text = ui.family_get_news(i)
    }, 0)
  end
end
function on_item_select(ctrl)
  if select ~= nil then
    select:search("select").visible = false
  end
  select = ctrl
  select:search("select").visible = true
  local ui_family_member
  self = ui.family_get_self()
  if self.position == 3 or self.position == 4 then
    if g_all_member_tab.press == true or g_manager_tab.press == true then
      member_menu_init(ctrl)
      if self.position == 3 then
        menu_remove(member_menu.items, "setpos")
      end
      ui_tool.show_menu(member_menu)
    else
      apply_menu_init(ctrl)
      ui_tool.show_menu(apply_menu)
    end
  end
end
function on_status_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    ctrl.parent.parent:click()
  end
end
function on_make_tip(tip)
  local id = tip.owner.parent:search("id")
  local ui_family_member
  member = ui.family_find_member(id.text)
  local time
  if member ~= nil then
    if member.status == 0 then
      time = member.leave
    else
      time = 0
    end
  end
  local text = L("")
  if time == nil then
    text = ui.get_text("org|null")
  elseif time == 0 then
    text = ui.get_text("org|online")
  elseif time / 2592000 >= 1 then
    text = ui.get_text("org|offline_o")
  elseif 1 <= time / 86400 then
    local arg = sys.variant()
    arg:set("time", math.floor(time / 86400))
    text = sys.mtf_merge(arg, ui.get_text("org|offline_d"))
  elseif 1 <= time / 3600 then
    local arg = sys.variant()
    arg:set("time", math.floor(time / 3600))
    text = sys.mtf_merge(arg, ui.get_text("org|offline_h"))
  else
    local arg = sys.variant()
    arg:set("time", math.floor(time / 60))
    text = sys.mtf_merge(arg, ui.get_text("org|offline_m"))
  end
  ui_widget.tip_make_view(tip.view, text)
end
function refresh()
  if list_type == 0 or list_type == 1 then
    refresh_member()
  else
    refresh_apply()
  end
  refresh_news()
  local arg = sys.variant()
  arg:set("cur_page", cur_page)
  arg:set("max_page", max_page)
  local page_text = sys.mtf_merge(arg, ui.get_text("org|member_page"))
  g_member_page.text = page_text
  arg:clear()
  arg:set("cur_num", ui.family_member_count())
  arg:set("max_num", ui.family_max_member())
  local num_text = sys.mtf_merge(arg, ui.get_text("org|member_num"))
  g_member_num.text = num_text
  local ui_family_member
  self = ui.family_get_self()
  if ui.family_get_self() == nil then
    g_base_info.color = ui.make_color("FF0000")
    g_base_info.text = ui.get_text("org|nofamily")
  else
    arg:clear()
    arg:set("family_name", ui.family_name())
    arg:set("leader_name", ui.family_leader_name())
    local info_text = sys.mtf_merge(arg, ui.get_text("org|base_info"))
    g_base_info.color = ui.make_color("FFFFFF")
    g_base_info.text = info_text
  end
  g_prev_btn.enable = true
  g_next_btn.enable = true
  if cur_page == 1 then
    g_prev_btn.enable = false
  end
  if cur_page >= max_page then
    g_next_btn.enable = false
  end
  select = nil
  auth_check()
end
function auth_check()
  local ui_family_member
  self = ui.family_get_self()
  g_invite_btn.enable = false
  g_leave_btn.enable = false
  g_change_btn.enable = false
  if self == nil then
    return
  end
  if self.position == 2 then
    g_leave_btn.enable = true
  end
  if self.position == 3 then
    g_invite_btn.enable = true
    g_leave_btn.enable = true
    g_change_btn.enable = true
  end
  if self.position == 4 then
    g_invite_btn.enable = true
    g_change_btn.enable = true
  end
end
function on_visible(w, vis)
  if vis == true then
    option = "status"
    g_status_btn.visible = true
    g_line_btn.visible = false
    g_all_member_tab:click()
    g_info_tab:click()
    g_all_member_tab.press = true
    g_info_box.focus_able = false
    g_info_box.focus = false
    g_change_btn.visible = true
    g_confirm_btn.visible = false
    g_intro_tab.enable = true
    g_info_tab.enable = true
    g_info_tab.press = true
  else
    g_member_list:item_clear()
    g_show_check.check = false
    online = true
    list_type = 0
    cur_page = 1
    sort = 0
    select = nil
    local member_menu = ui.find_control("$frame:family_member_menu")
    local apply_menu = ui.find_control("$frame:family_apply_menu")
    w_pos_main.visible = false
  end
end
function on_name_sort(ctrl)
  sort_table.name = not sort_table.name
  if sort_table.name == true then
    sort = 1
  else
    sort = 2
  end
  refresh()
end
function on_level_sort(ctrl)
  sort_table.level = not sort_table.level
  if sort_table.level == true then
    sort = 3
  else
    sort = 4
  end
  refresh()
end
function on_career_sort(ctrl)
  sort_table.career = not sort_table.career
  if sort_table.career == true then
    sort = 5
  else
    sort = 6
  end
  refresh()
end
function on_position_sort(ctrl)
  sort_table.position = not sort_table.position
  if sort_table.position == true then
    sort = 7
  else
    sort = 8
  end
  refresh()
end
function on_area_sort(ctrl)
  sort_table.area = not sort_table.area
  if sort_table.area == true then
    sort = 9
  else
    sort = 10
  end
  refresh()
end
function on_status_sort(ctrl)
  sort_table.status = not sort_table.status
  if sort_table.status == true then
    sort = 11
  else
    sort = 12
  end
  refresh()
end
function on_line_sort(ctrl)
  sort_table.line = not sort_table.line
  if sort_table.line == true then
    sort = 13
  else
    sort = 14
  end
  refresh()
end
function on_list_prev(ctrl)
  if cur_page > 1 then
    cur_page = cur_page - 1
    refresh()
  end
end
function on_list_next(ctrl)
  if cur_page < max_page then
    cur_page = cur_page + 1
    refresh()
  end
end
function on_info_tab(ctrl)
  local dst = ui.filter_text(ui.family_get_info())
  g_info_box.text = dst
end
function on_intro_tab(ctrl)
  local dst = ui.filter_text(ui.family_get_intro())
  g_info_box.text = dst
end
function on_info_change(ctrl)
  g_info_box.focus_able = true
  g_info_box.focus = true
  g_change_btn.visible = false
  g_confirm_btn.visible = true
  if g_info_tab.press == true then
    g_intro_tab.enable = false
  end
  if g_intro_tab.press == true then
    g_info_tab.enable = false
  end
end
function on_info_confirm(ctrl)
  g_info_box.focus_able = false
  g_info_box.focus = false
  g_change_btn.visible = true
  g_confirm_btn.visible = false
  if g_info_tab.press == true then
    g_intro_tab.enable = true
    local v = sys.variant()
    v:set(packet.key.org_vartext, g_info_box.text)
    bo2.send_variant(packet.eCTS_Family_SetInfo, v)
  end
  if g_intro_tab.press == true then
    g_info_tab.enable = true
    local v = sys.variant()
    v:set(packet.key.org_vartext, g_info_box.text)
    bo2.send_variant(packet.eCTS_Family_SetIntro, v)
  end
end
function on_all_member_tab(ctrl)
  list_type = 0
  cur_page = 1
  g_show_check.enable = true
  refresh()
end
function on_manager_tab(ctrl)
  list_type = 1
  cur_page = 1
  g_show_check.enable = true
  refresh()
end
function on_apply_tab(ctrl)
  list_type = 2
  cur_page = 1
  g_show_check.enable = false
  refresh()
end
function on_show_offline(ctrl)
  if g_show_check.check == true then
    online = false
  else
    online = true
  end
  refresh()
end
function on_refresh(ctrl)
  refresh()
end
function on_build(ctrl)
  local msg = {
    callback = on_build_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    limit = 16
  }
  msg.text = ui.get_text("org|guild_invite_msg")
  msg.input = L("")
  ui_tool.show_msg(msg)
end
function on_invite(ctrl)
  local msg = {
    callback = on_invite_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    limit = 16
  }
  msg.text = ui.get_text("org|invite_msg")
  msg.input = L("")
  ui_tool.show_msg(msg)
end
function on_leave(ctrl)
  local msg = {
    callback = on_leave_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui.get_text("org|leave_msg")
  ui_tool.show_msg(msg)
end
function on_dismiss(ctrl)
  local msg = {
    callback = on_dismiss_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui.get_text("org|dismiss_msg")
  ui_tool.show_msg(msg)
end
function on_cancel_dismiss(ctrl)
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_Family_Cancel, v)
end
function on_set_position(ctrl)
  w_pos_main.visible = true
end
function on_kick_member(ctrl)
  local msg = {
    callback = on_kick_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui.get_text("org|kick_msg")
  ui_tool.show_msg(msg)
end
function on_query_apply(ctrl)
  local msg = {
    callback = nil,
    btn_confirm = true,
    btn_cancel = false,
    modal = true
  }
  local id = select:search("id")
  local ui_family_apply
  member = ui.family_find_apply(id.text)
  if member ~= nil then
    msg.title = ui.get_text("org|apply_text")
    local dst = ui.filter_text(member.apply)
    local stk = sys.mtf_stack()
    stk:push(dst)
    msg.text = stk.text
    ui_tool.show_msg(msg)
  end
end
function on_accept_apply(ctrl)
  local v = sys.variant()
  local id = select:search("id")
  local ui_family_apply
  member = ui.family_find_apply(id.text)
  if member ~= nil then
    v:set(packet.key.org_tarplayerid, member.id)
    v:set(packet.key.org_acceptrequest, 1)
    bo2.send_variant(packet.eCTS_Family_Approve, v)
  end
end
function on_refuse_apply(ctrl)
  local v = sys.variant()
  local id = select:search("id")
  local ui_family_apply
  member = ui.family_find_apply(id.text)
  if member ~= nil then
    v:set(packet.key.org_tarplayerid, member.id)
    v:set(packet.key.org_acceptrequest, 0)
    bo2.send_variant(packet.eCTS_Family_Approve, v)
  end
end
function on_pos_visible(w, vis)
  if vis == true then
    local ui_family_member
    self = ui.family_get_self()
    g_member_radio.check = false
    g_assist_radio.check = false
    g_leader_radio.check = false
    if self.position == 4 then
      g_member_radio.enable = true
      g_assist_radio.enable = true
      g_leader_radio.enable = true
    else
      g_member_radio.enable = false
      g_assist_radio.enable = false
      g_leader_radio.enable = false
    end
    local arg = sys.variant()
    arg:set("cha_name", select:search("name").text)
    arg:set("pos_name", select:search("pos").text)
    local pos_text = sys.mtf_merge(arg, ui.get_text("org|pos_info"))
    g_pos_info.text = pos_text
    appoint_id = select:search("id").text
  end
end
function on_pos_confirm(ctrl)
  local v = sys.variant()
  local ui_family_member
  member = ui.family_find_member(appoint_id)
  if member ~= nil then
    local pos = 0
    if g_member_radio.check == true then
      pos = 2
    end
    if g_assist_radio.check == true then
      pos = 3
    end
    if g_leader_radio.check == true then
      pos = 4
      local msg = {
        callback = on_leader_msg,
        btn_confirm = true,
        btn_cancel = true,
        modal = true
      }
      msg.text = ui.get_text("org|leader_msg")
      ui_tool.show_msg(msg)
      w_pos_main.visible = false
      return
    end
    if pos ~= 0 then
      v:set(packet.key.org_tarplayerid, member.id)
      v:set(packet.key.family_position, pos)
      bo2.send_variant(packet.eCTS_Family_Appoint, v)
    end
    w_pos_main.visible = false
  end
end
function on_pos_cancel(ctrl)
  w_pos_main.visible = false
end
function on_set_status(ctrl)
  status_menu_init(ctrl)
  ui_tool.show_menu(status_menu)
end
function on_status_status(ctrl)
  option = "status"
  g_status_btn.visible = true
  g_line_btn.visible = false
  refresh()
end
function on_status_line(ctrl)
  option = "line"
  g_status_btn.visible = false
  g_line_btn.visible = true
  refresh()
end
function on_build_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local v = sys.variant()
    v:set(packet.key.org_name, msg.input)
    bo2.send_variant(packet.eCTS_Family_Build, v)
  end
end
function on_invite_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local v = sys.variant()
    v:set(packet.key.org_tarplayername, msg.input)
    bo2.send_variant(packet.eCTS_Family_Invite, v)
  end
end
function on_leave_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_Family_Leave, v)
    w_main.visible = false
  end
end
function on_dismiss_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_Family_Dismiss, v)
    w_main.visible = false
  end
end
function on_kick_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local v = sys.variant()
    local id = select:search("id")
    local ui_family_member
    member = ui.family_find_member(id.text)
    if member ~= nil then
      v:set(packet.key.org_tarplayerid, member.id)
      bo2.send_variant(packet.eCTS_Family_Kick, v)
    end
  end
end
function on_leader_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local v = sys.variant()
    local id = select:search("id")
    local ui_family_member
    member = ui.family_find_member(id.text)
    if member ~= nil then
      v:set(packet.key.org_tarplayerid, member.id)
      v:set(packet.key.family_position, 4)
      bo2.send_variant(packet.eCTS_Family_Appoint, v)
    end
  end
end
function ack_family_invite_popo(click, data)
  ui.console_print("ack_family_invite_popo.")
  local v = sys.variant()
  ui.console_print("family_requestid is %s", data:get(packet.key.org_requestid).v_string)
  v:set(packet.key.org_requestid, data:get(packet.key.org_requestid))
  accept = 0
  if "yes" ~= click then
    accept = 1
  end
  v:set(packet.key.org_acceptrequest, accept)
  bo2.send_variant(packet.eCTS_Family_Response, v)
end
