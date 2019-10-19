local online = true
local option = "current_con"
local sort_asc = true
local hall_id = -2
local riddling_member_list = {}
local riddling_member_list_size = 0
local sort_by, select, hall_select, apply_select
local cur_page = 1
local max_page = 1
local page_maxmember = bo2.gv_define_org:find(6).value.v_int
local member_menu, apply_menu, hall_menu, status_menu, manager_menu, riddling_member_menu
local self_portrait_menu = {}
local ui_chat_list = ui_widget.ui_chat_list
local input_mun = 0
local inputmax = bo2.gv_define_org:find(7).value.v_int
local inputtext, select_id
local color_offline = ui.make_color("808080")
local color_online = ui.make_color("74c165")
local color_my = ui.make_color("007FFF")
local color_def = ui.make_color("FFFFFF")
local member_xml_uri = SHARED("$frame/guild/member.xml")
local member_item_style = SHARED("guild_item")
local guild_title_showall = false
function member_list_clear()
  for i = 0, g_member_list.item_count - 1 do
    g_member_list:item_get(i).visible = false
  end
end
function set()
end
function on_init()
  online = true
  option = "current_con"
  sort_asc = true
  hall_id = -2
  riddling_member_list = {}
  riddling_member_list_size = 0
  sort_by = nil
  select = nil
  ismember = true
  cur_page = 1
  max_page = 1
  member_menu = nil
  apply_menu = nil
  hall_menu = nil
  status_menu = nil
  manager_menu = nil
  riddling_member_menu = nil
  member_list_clear()
end
function menu_remove(items, id)
  for i = 1, table.maxn(items) do
    if items[i].id == id then
      table.remove(items, i)
      return
    end
  end
end
function on_status_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    ctrl.parent.parent:click()
  end
end
function member_menu_init(ctrl)
  member_menu = {
    name = "guild_member_menu",
    items = {
      {
        text = ui.get_text("guild|tongyong"),
        sub_menu = self_portrait_menu,
        id = "tongyong"
      },
      {
        text = ui.get_text("guild|setpos"),
        callback = on_set_title,
        id = "setpos"
      },
      {
        text = ui.get_text("guild|attemper"),
        callback = on_attemper_member,
        id = "attemper"
      },
      {
        text = ui.get_text("guild|kick"),
        callback = on_kick_member,
        id = "member"
      }
    },
    event = on_guild_menu_event,
    popup = "x2y1"
  }
end
function apply_menu_init(ctrl)
  apply_menu = {
    name = "guild_apply_menu",
    items = {
      {
        text = ui.get_text("guild|applytext"),
        callback = on_query_apply,
        id = "apply"
      },
      {
        text = ui.get_text("guild|accept"),
        callback = on_accept_apply,
        id = "accept"
      },
      {
        text = ui.get_text("guild|refuse"),
        callback = on_refuse_apply,
        id = "refuse"
      }
    },
    event = on_guild_menu_event,
    popup = "x2y1",
    source = ctrl
  }
end
function riddling_member_menu_init(ctrl)
  riddling_member_menu = {
    name = "guild_riddling_member",
    items = {
      {
        text = ui.get_text("guild|all_member"),
        callback = on_all_member_tab,
        id = -2
      },
      {
        text = ui.get_text("guild|manager"),
        callback = on_manager_tab,
        id = -1
      },
      {
        text = ui.get_text("guild|scattered"),
        callback = on_scattered_tab,
        id = 0
      }
    },
    event = on_guild_menu_event,
    popup = "y2x2",
    source = ctrl,
    dx = ctrl.parent.dx
  }
  for i = 0, ui.guild_hall_size() - 1 do
    local ui_guild_hall
    hall = ui.guild_get_hall(i)
    riddling_member_menu.items[#riddling_member_menu.items + 1] = {
      text = hall.name,
      callback = on_set_hall,
      id = i + 1
    }
  end
end
function status_menu_init(ctrl)
  status_menu = {
    name = "guild_status_menu",
    items = {
      {
        text = ui.get_text("guild|current_con"),
        callback = on_status_current_con,
        id = "current_con"
      },
      {
        text = ui.get_text("guild|week_con"),
        callback = on_status_week_con,
        id = "week_con"
      },
      {
        text = ui.get_text("guild|total_con"),
        callback = on_status_total_con,
        id = "total_con"
      }
    },
    event = on_guild_menu_event,
    popup = "y2x2",
    source = ctrl,
    dx = ctrl.parent.dx,
    margin = ui.rect(0, 0, 0, 8)
  }
end
function manager_menu_init(ctrl)
  manager_menu = {
    name = "guild_manager_menu",
    items = {
      {
        text = ui.get_text("guild|applytext"),
        callback = on_query_family,
        id = "apply"
      },
      {
        text = ui.get_text("guild|accept"),
        callback = on_accept_family,
        id = "accept"
      },
      {
        text = ui.get_text("guild|refuse"),
        callback = on_refuse_family,
        id = "refuse"
      },
      {
        text = ui.get_text("guild|family_kick"),
        callback = on_kick_family,
        id = "kick"
      }
    },
    event = on_guild_menu_event,
    popup = "x1y1",
    source = ctrl
  }
end
function on_guild_menu_event(item)
  if item.callback then
    item:callback()
  end
end
function on_set_status(ctrl)
  status_menu_init(ctrl)
  menu_remove(status_menu.items, option)
  ui_tool.show_menu(status_menu)
end
function on_set_riddling_member(ctrl)
  riddling_member_menu_init(ctrl)
  ui_tool.show_menu(riddling_member_menu)
end
function on_status_total_con(ctrl)
  option = "total_con"
  g_total_con_btn.visible = true
  g_week_con_btn.visible = false
  g_current_con_btn.visible = false
  update_member()
end
function on_status_week_con(ctrl)
  option = "week_con"
  g_total_con_btn.visible = false
  g_week_con_btn.visible = true
  g_current_con_btn.visible = false
  update_member()
end
function on_status_current_con(ctrl)
  option = "current_con"
  g_total_con_btn.visible = false
  g_week_con_btn.visible = false
  g_current_con_btn.visible = true
  update_member()
end
function on_all_member_tab(item)
  hall_id = item.id
  g_base_info.text = item.text
  update_member()
end
function on_manager_tab(item)
  hall_id = item.id
  g_base_info.text = item.text
  update_member()
end
function on_scattered_tab(item)
  hall_id = item.id
  g_base_info.text = item.text
  update_member()
end
function on_set_hall(item)
  hall_id = item.id
  g_base_info.text = item.text
  update_member()
end
function guild_member_sort()
  sort_asc = not sort_asc
  update_member()
end
function on_name_sort(ctrl)
  sort_by = "name"
  guild_member_sort()
end
function on_level_sort(ctrl)
  sort_by = "level"
  guild_member_sort()
end
function on_career_sort(ctrl)
  sort_by = "career"
  guild_member_sort()
end
function on_position_sort(ctrl)
  sort_by = "title"
  guild_member_sort()
end
function on_area_sort(ctrl)
  sort_by = "area"
  guild_member_sort()
end
function on_status_sort(ctrl)
  sort_by = "status"
  guild_member_sort()
end
function on_line_sort(ctrl)
  sort_by = "line"
  guild_member_sort()
end
function on_hall_sort(ctrl)
  sort_by = "hall"
  guild_member_sort()
end
function on_welfare_sort(ctrl)
  sort_by = "welfare"
  guild_member_sort()
end
function on_total_con_sort(ctrl)
  sort_by = "total_con"
  guild_member_sort()
end
function on_week_con_sort(ctrl)
  sort_by = "week_con"
  guild_member_sort()
end
function on_current_con_sort(ctrl)
  sort_by = "current_con"
  guild_member_sort()
end
function on_item_mouse(item, msg, pos)
  if msg == ui.mouse_rbutton_down and select ~= nil then
    ui_tool.hide_menu()
    local id = select:search("id")
    local ui_guild_member
    member = ui.guild_find_member(id.text)
    local name = member.name
    local self_portrait_menu = {}
    ui_im.generate_rb(name)
    self_portrait_menu = {
      items = ui_im.im_rb_items,
      event = ui_im.on_player_portrait_event,
      info = {name = name},
      dx = 100,
      dy = 50,
      offset = item.abs_area.p1 + pos
    }
    if self_portrait_menu then
      ui_tool.show_menu(self_portrait_menu)
    end
  end
end
function on_make_tip(tip)
  local id = tip.owner.parent:search("id")
  local member = ui.guild_find_member(id.text)
  if member == nil then
    text = ui.get_text("guild|null")
    ui_widget.tip_make_view(tip.view, text)
    return
  end
  local text = L("")
  if option == "total_con" then
    text = tostring(member.total_con)
  elseif option == "week_con" then
    text = tostring(member.week_con)
  elseif option == "current_con" then
    text = tostring(member.current_con)
  end
  ui_widget.tip_make_view(tip.view, text)
end
function on_show_offline(ctrl)
  online = not g_show_check.check
  update_member()
end
function on_list_prev(ctrl)
  if cur_page > 1 then
    cur_page = cur_page - 1
  end
  update_list_page()
  update_page()
end
function on_list_next(ctrl)
  if cur_page < max_page then
    cur_page = cur_page + 1
  end
  update_list_page()
  update_page()
end
function on_item_select(ctrl)
  if select ~= nil then
    select:search("fig_highlight_sel").visible = false
  end
  select = ctrl
  select:search("fig_highlight_sel").visible = true
  local self = ui.guild_get_self()
  local excel = bo2.gv_guild_auth:find(self.guild_pos)
  local id = select:search("id")
  select_id = id.text
  local member = ui.guild_find_member(select_id)
  if member == nil then
    return
  end
  member_menu_init(ctrl)
  if excel.appoint == 0 or member == self or member.guild_pos >= self.guild_pos then
    menu_remove(member_menu.items, "setpos")
  end
  if tostring(self.hall_id) ~= "0" and self.hall_id ~= member.hall_id then
    menu_remove(member_menu.items, "setpos")
  end
  if excel.kick == 0 or member == self then
    menu_remove(member_menu.items, "member")
  end
  if excel.dismiss == 0 then
    menu_remove(member_menu.items, "contribute")
  end
  if excel.attemper == 0 or self.hall_id ~= sys.wstring(0) and self.hall_id ~= member.hall_id then
    menu_remove(member_menu.items, "attemper")
  end
  local name = member.name
  ui_im.generate_rb(name)
  member_menu.items[1].sub_menu = {
    items = ui_im.im_rb_items,
    event = ui_im.on_player_portrait_event,
    info = {name = name, real_name = name},
    dx = 100,
    dy = 50
  }
  ui_tool.show_menu(member_menu)
end
function inriddling(member)
  if online and member.status ~= 1 then
    return false
  end
  if hall_id == -1 and member.guild_pos > 4 then
    return true
  end
  if hall_id == -2 then
    return true
  end
  if hall_id == 0 then
    local hall = ui.guild_find_hall(member.hall_id)
    if hall == nil then
      if member.guild_pos < 4 then
        return true
      end
      return false
    end
    return false
  elseif hall_id > 0 then
    local hall = ui.guild_get_hall(hall_id - 1)
    if hall ~= nil and member.hall_id == hall.id then
      return true
    end
    return false
  end
end
function set_riddlingitem(item, member)
  local id = item:search("id")
  id.text = member.id
  local name = item:search("name")
  name.text = member.name
  local level = item:search("level")
  level.text = member.level
  local career = item:search("career")
  local excel = bo2.gv_profession_list:find(member.career)
  if excel == nil then
    career.text = L("--")
  else
    career.text = excel.name
  end
  local hall_item = item:search("hall")
  local guild_hall = ui.guild_find_hall(member.hall_id)
  if guild_hall ~= nil then
    hall_item.text = guild_hall.name
  elseif member.guild_pos > 4 then
    hall_item.text = ui.get_text("guild|manager")
  else
    hall_item.text = ui.get_text("guild|scattered")
  end
  local pos = item:search("pos")
  pos.text = bo2.gv_guild_title:find(member.title).name
  local welfare = item:search("welfare")
  welfare.text = member.welfare
  local con = 0
  if option == "total_con" then
    con = member.total_con
  elseif option == "week_con" then
    con = member.week_con
  elseif option == "current_con" then
    con = member.current_con
  end
  local status = item:search("status")
  if con > 10000 then
    arg = sys.variant()
    arg:set(L("con"), math.floor(member.total_con / 10000))
    status.text = sys.mtf_merge(arg, ui.get_text("guild|con"))
  else
    status.text = con
  end
  local to_color = color_def
  if member.status == 0 then
    to_color = color_offline
  elseif member.status == 2 then
    to_color = color_online
  elseif member.name == bo2.player.name then
    to_color = color_my
  end
  name.color = to_color
  level.color = to_color
  career.color = to_color
  pos.color = to_color
  welfare.color = to_color
  status.color = to_color
  hall_item.color = to_color
  if select_id ~= nil and id.text == select_id then
    select = item
    item:search("fig_highlight_sel").visible = true
  else
    item:search("fig_highlight_sel").visible = false
  end
end
function update_list_page()
  local item_file = member_xml_uri
  local item_style = member_item_style
  if select ~= nil then
    select = nil
  end
  member_list_clear()
  local _begin = (cur_page - 1) * page_maxmember
  local _end = _begin + page_maxmember - 1
  if _end > riddling_member_list_size then
    _end = riddling_member_list_size - 1
  end
  local c = g_member_list.item_count
  for i = _begin, _end do
    local insert_item = riddling_member_list[i + 1]
    local item
    local idx = i - _begin
    if c <= idx then
      item = g_member_list:item_append()
      item:load_style(item_file, item_style)
    else
      item = g_member_list:item_get(idx)
    end
    item.visible = true
    set_riddlingitem(item, insert_item)
  end
end
function update_select_member()
  riddling_member_list, riddling_member_list_size = ui.guild_select_member(inriddling, sort_by, sort_asc)
end
function update_member()
  local slider_y = g_member_list.slider_y.scroll
  select = nil
  local item_file = member_xml_uri
  local item_style = member_item_style
  update_select_member()
  max_page = 1
  max_page = math.floor((riddling_member_list_size + page_maxmember - 1) / page_maxmember)
  if max_page == 0 then
    max_page = 1
  end
  if cur_page > max_page then
    cur_page = max_page
  end
  update_list_page()
  g_member_list.slider_y.scroll = slider_y
  update_page()
end
function update_news()
  if g_new_tab.press == false then
    return
  end
  local slider_y = g_news_list.slider_y.scroll
  ui_chat_list.clear(g_news_list)
  for i = 0, ui.guild_news_size() - 1 do
    ui_chat_list.insert(g_news_list, {
      text = ui.guild_get_news(i)
    }, 0)
  end
  g_news_list.slider_y.scroll = slider_y
end
function get_hall_name(id)
  local hall_name = ui.guild_get_hall_name(id)
  if sys.check(hall_name) == false then
    hall_name = ui.get_text("guild|null")
  end
  return hall_name
end
function get_week_con_max(id)
  local line = bo2.gv_guild_welfare:find(id)
  local re_value = 0
  if line ~= nil then
    re_value = line.weekmax
  end
  return re_value
end
function get_welfare_need_con(id)
  local line = bo2.gv_guild_welfare:find(id)
  local re_value = 0
  if line ~= nil then
    re_value = line.totalc
  end
  return re_value
end
function get_dexp()
  return bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_iGuildExp)
end
function update_page()
  local arg = sys.variant()
  arg:set("cur_page", cur_page)
  arg:set("max_page", max_page)
  local page_text = sys.mtf_merge(arg, ui.get_text("guild|member_page"))
  g_member_page.text = page_text
end
function ack_guild_union_popo(click, data)
  local v = sys.variant()
  v:set(packet.key.org_requestid, data:get(packet.key.org_requestid))
  accept = 0
  if "yes" ~= click then
    accept = 1
  end
  v:set(packet.key.org_acceptrequest, accept)
  v:set(packet.key.cmn_type, bo2.eSociality_ResponseType_GuildUnion)
  bo2.send_variant(packet.eCTS_Guild_Response, v)
end
function on_kick_member(ctrl)
  local function on_kick_msg(msg)
    if msg == nil then
      return
    end
    if msg.result == 1 then
      local v = sys.variant()
      local id = select:search("id")
      local ui_guild_member
      member = ui.guild_find_member(id.text)
      if member ~= nil then
        v:set(packet.key.org_tarplayerid, member.id)
        bo2.send_variant(packet.eCTS_Guild_KickM, v)
      end
    end
  end
  local msg = {
    callback = on_kick_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui.get_text("guild|kick_msg")
  ui_widget.ui_msg_box.show_common(msg)
end
function on_attemper_member(ctrl)
  local function on_attemper_msg_init(msg)
    local id = select:search("id")
    local member = ui.guild_find_member(id.text)
    local self = ui.guild_get_self()
    for i = 0, ui.guild_hall_size() - 1 do
      local radio_item = w_hall:search("guild_hall" .. i + 1)
      local guildhall = ui.guild_get_hall(i)
      if guildhall ~= nil then
        radio_item.text = guildhall.name
        if self.guild_pos <= bo2.Guild_Captain and self.hall_id ~= guildhall.id then
          radio_item.enable = false
        end
        if member.hall_id == guildhall.id then
          radio_item.check = true
        end
      end
    end
    if tostring(member.hall_id) == tostring(0) then
      local radio_item = w_hall:search("guild_hall0")
      radio_item.check = true
    end
    for i = ui.guild_hall_size() + 1, 5 do
      local radio_item = w_hall:search("guild_hall" .. i)
      radio_item.enable = false
    end
    local id = select:search("id")
    local member = ui.guild_find_member(id.text)
    local arg = sys.variant()
    arg:set("cha_name", select:search("name").text)
    arg:set("pos_name", select:search("pos").text)
    g_set_hall_title.text = sys.mtf_merge(arg, ui.get_text("guild|pos_info"))
    local keep_banner_item = w_hall:search("keep_guild_banner")
    keep_banner_item.enable = false
    local excel = bo2.gv_guild_auth:find(self.guild_pos)
    if excel ~= nil and excel.update_banner == 1 then
      keep_banner_item.enable = true
    end
  end
  local function on_attemper_msg_callback(msg)
    if msg.result == 0 then
      return
    end
    local hallid = 0
    local flag = 0
    for i = 0, 5 do
      local radio_item = w_hall:search("guild_hall" .. i)
      if radio_item.check == true and i ~= 0 then
        local ui_guild_hall
        guildhall = ui.guild_get_hall(i - 1)
        flag = 1
        if guildhall ~= nil then
          hallid = guildhall.id
          radio_item.text = guildhall.name
        end
        break
      end
    end
    local radio_item = w_hall:search("guild_hall0")
    if radio_item.check ~= true and hallid == 0 and flag == 0 then
      hallid = 11
    end
    local v = sys.variant()
    local id = select:search("id")
    local ui_guild_member
    member = ui.guild_find_member(id.text)
    if member ~= nil then
      v:set(packet.key.org_tarplayerid, member.id)
      v:set(packet.key.guild_hallid, hallid)
      bo2.send_variant(packet.eCTS_Guild_Attemper, v)
    end
  end
  local msg = {
    init = on_attemper_msg_init,
    callback = on_attemper_msg_callback,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    style_uri = member_xml_uri,
    style_name = "guild_hall"
  }
  ui_widget.ui_msg_box.show(msg)
end
function on_title_item_select(item, sel)
  ui_guild_mod.ui_guild.update_highlight(item)
  item:search("fig_highlight_sel").visible = item.selected or item.inner_hover
  g_guild_title_btn.enable = true
end
function sort_title(t)
  local mysort = function(a, b)
    return a.sort_id > b.sort_id
  end
  table.sort(t, mysort)
end
function check_title(member, line)
  if line.needcon > member.total_con then
    return false
  end
  if (line.status == bo2.Guild_AssistCaptain or line.status == bo2.Guild_Captain) and member.hall_id == L("0") then
    return false
  end
  if line.status == bo2.Guild_Leader and member.guild_pos ~= bo2.Guild_Assist then
    return false
  end
  return true
end
function on_show_all_title(btn)
  for i = 0, g_title_list.item_count - 1 do
    local item = g_title_list:item_get(i)
    if item.svar.is_mine ~= true and item.enable == false then
      item.visible = not item.visible
    end
  end
end
function get_hall_name(id)
  local hall_name = ui.guild_get_hall_name(id)
  if sys.check(hall_name) == false then
    hall_name = ui.get_text("org|null")
  end
  return hall_name
end
function on_title_init(panel, vis)
  if vis then
    ui_guild_mod.ui_member.g_title_show_check.check = true
  end
end
function on_title_apply(ctrl)
  local self = ui.guild_get_self()
  local title_table = {}
  for i = 0, bo2.gv_guild_title.size - 1 do
    local line = bo2.gv_guild_title:get(i)
    if line.count == 0 and line.needcon ~= 0 then
      table.insert(title_table, i)
    elseif line.id == self.title then
      table.insert(title_table, i)
    end
  end
  if #title_table == 0 then
    ui_chat.show_ui_text_id(70352)
    return
  end
  local function on_posmsg_init(msg)
    g_guild_title_info:search("name").text = self.name
    g_guild_title_info:search("hall").text = get_hall_name(bo2.player.only_id)
    g_guild_title_info:search("con").text = self.total_con
    g_guild_title_info:search("title").text = bo2.gv_guild_title:find(self.title).name
    gx_guild_title_text.text = ui.get_text("guild|title_apply")
    local item_file = member_xml_uri
    local item_style = "guild_title_item"
    g_title_list:item_clear()
    for i = 1, #title_table do
      local line = bo2.gv_guild_title:get(title_table[i])
      local item = g_title_list:item_append()
      item:load_style(item_file, item_style)
      local title_name = item:search("name")
      title_name.text = line.name
      local needcon = item:search("needcon")
      if line.needcon == 0 then
        needcon.text = "-"
      else
        needcon.text = line.needcon
      end
      local other = item:search("other")
      if line.status == bo2.Guild_AssistCaptain or line.status == bo2.Guild_Captain then
        other.text = ui.get_text("guild|apply_title_other_hall")
      elseif line.status == bo2.Guild_Leader then
        other.text = ui.get_text("guild|apply_title_other_assist")
      else
        other.text = "-"
      end
      if line.id == self.title then
        item.visible = true
        item.enable = false
        title_name.color = color_my
        needcon.color = color_my
        other.color = color_my
        item.svar.is_mine = true
      end
      if check_title(self, line) == false then
        item.visible = true
        item.enable = false
        title_name.color = color_offline
        needcon.color = color_offline
        other.color = color_offline
      end
      item.svar.id = line.id
      item.svar.sort = line.sort_id
    end
    local mysort = function(a, b)
      if a.svar.sort < b.svar.sort then
        return -1
      elseif a.svar.sort == b.svar.sort then
        return 0
      else
        return 1
      end
    end
    g_title_list:item_sort(mysort)
    g_guild_title_btn.enable = false
  end
  local on_appoint_msg_callback = function(msg)
    if g_title_list.item_sel == nil then
      return
    end
    if msg.result == 0 then
      return
    end
    local v = sys.variant()
    v:set(packet.key.cmn_requestid, g_title_list.item_sel.svar.id)
    bo2.send_variant(packet.eCTS_Guild_TitleApply, v)
  end
  local msg = {
    init = on_posmsg_init,
    callback = on_appoint_msg_callback,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    style_uri = member_xml_uri,
    style_name = "guild_title"
  }
  ui_widget.ui_msg_box.show(msg)
end
function on_set_title(ctrl)
  local id = select:search("id")
  local member = ui.guild_find_member(id.text)
  local self = ui.guild_get_self()
  local title_table = {}
  for i = 0, bo2.gv_guild_title.size - 1 do
    local line = bo2.gv_guild_title:get(i)
    if self.guild_pos > line.status then
      table.insert(title_table, i)
    end
    if line.status == bo2.Guild_Leader and self.guild_pos == bo2.Guild_Leader then
      table.insert(title_table, i)
    end
  end
  if #title_table == 0 then
    ui_chat.show_ui_text_id(70353)
    return
  end
  local function on_posmsg_init(msg)
    g_guild_title_info:search("name").text = member.name
    g_guild_title_info:search("hall").text = select:search("hall").text
    g_guild_title_info:search("con").text = member.total_con
    g_guild_title_info:search("title").text = select:search("pos").text
    gx_guild_title_text.text = ui.get_text("guild|setpos")
    local item_file = member_xml_uri
    local item_style = "guild_title_item"
    g_title_list:item_clear()
    for i = 1, #title_table do
      local line = bo2.gv_guild_title:get(title_table[i])
      local item = g_title_list:item_append()
      item:load_style(item_file, item_style)
      local title_name = item:search("name")
      title_name.text = line.name
      local needcon = item:search("needcon")
      if line.needcon == 0 then
        needcon.text = "-"
      else
        needcon.text = line.needcon
      end
      local other = item:search("other")
      if line.status == bo2.Guild_AssistCaptain or line.status == bo2.Guild_Captain then
        other.text = ui.get_text("guild|apply_title_other_hall")
      elseif line.status == bo2.Guild_Leader then
        other.text = ui.get_text("guild|apply_title_other_assist")
      else
        other.text = "-"
      end
      if check_title(member, line) == false then
        item.visible = true
        item.enable = false
        title_name.color = color_offline
        needcon.color = color_offline
        other.color = color_offline
      end
      if line.id == member.title then
        item.visible = true
        item.enable = false
        title_name.color = color_my
        needcon.color = color_my
        other.color = color_my
        item.svar.is_mine = true
      end
      item.svar.id = line.id
      item.svar.sort = line.sort_id
    end
    local mysort = function(a, b)
      if a.svar.sort < b.svar.sort then
        return -1
      elseif a.svar.sort == b.svar.sort then
        return 0
      else
        return 1
      end
    end
    g_title_list:item_sort(mysort)
    g_guild_title_btn.enable = false
  end
  local function on_appoint_msg_callback(msg)
    if g_title_list.item_sel == nil then
      return
    end
    if msg.result == 0 then
      return
    end
    local sel_id = g_title_list.item_sel.svar.id
    local function send_server()
      if member ~= nil then
        local v = sys.variant()
        v:set(packet.key.cmn_id, member.id)
        v:set(packet.key.cmn_requestid, sel_id)
        bo2.send_variant(packet.eCTS_Guild_TitleSet, v)
      end
    end
    local line = bo2.gv_guild_title:find(g_title_list.item_sel.svar.id)
    if line ~= nil and line.status == bo2.Guild_Punish then
      local function on_set_punish(msg2)
        if msg2 == nil then
          return
        end
        if msg2.result == 1 then
          send_server()
        end
      end
      local msg2 = {
        callback = on_set_punish,
        btn_confirm = true,
        btn_cancel = true,
        modal = true,
        show_sound = 578,
        hide_sound = 579
      }
      msg2.text = sys.format(ui.get_text("guild|punish_msg"), member.name)
      ui_widget.ui_msg_box.show_common(msg2)
    else
      send_server()
    end
  end
  local msg = {
    init = on_posmsg_init,
    callback = on_appoint_msg_callback,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    style_uri = member_xml_uri,
    style_name = "guild_title"
  }
  ui_widget.ui_msg_box.show(msg)
end
function on_set_position(ctrl)
  local function on_posmsg_init(msg)
    local id = select:search("id")
    local ui_guild_member
    member = ui.guild_find_member(id.text)
    for pos = bo2.Guild_Punish, bo2.Guild_Leader do
      local radio_item = w_pos:search("guild_pos" .. pos)
      if member.guild_pos == pos then
        radio_item.check = true
      end
    end
    local ui_guild_member
    self = ui.guild_get_self()
    if self.guild_pos ~= bo2.Guild_Leader then
      for i = self.guild_pos, 8 do
        local radio_item = w_pos:search("guild_pos" .. i)
        radio_item.enable = false
      end
    end
    local id = select:search("id")
    local ui_guild_member
    member = ui.guild_find_member(id.text)
    local arg = sys.variant()
    arg:set("cha_name", select:search("name").text)
    arg:set("pos_name", select:search("pos").text)
    local r = msg.window:search("rv_text")
    r.mtf = sys.mtf_merge(arg, ui.get_text("guild|pos_info"))
    r.dock = "pin_xy"
    r.size = r.extent
  end
  local function on_appoint_msg_callback(msg)
    if msg.result == 0 then
      return
    end
    local pos = 0
    for i = 1, 8 do
      local radio_item = w_pos:search("guild_pos" .. i)
      if radio_item.check == true then
        pos = i
        break
      end
    end
    local v = sys.variant()
    local id = select:search("id")
    local ui_guild_member
    member = ui.guild_find_member(id.text)
    if member ~= nil and pos ~= 0 then
      v:set(packet.key.org_tarplayerid, member.id)
      v:set(packet.key.guild_position, pos)
      bo2.send_variant(packet.eCTS_Guild_Appoint, v)
    end
  end
  local msg = {
    init = on_posmsg_init,
    callback = on_appoint_msg_callback,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    style_uri = member_xml_uri,
    style_name = "guild_pos"
  }
  ui_widget.ui_msg_box.show(msg)
end
local title_acs = {
  info = ui.get_text(L("guild|acs_info")),
  invite = ui.get_text(L("guild|acs_invite")),
  approve = ui.get_text(L("guild|acs_approve")),
  kick = ui.get_text(L("guild|acs_kick")),
  appoint = ui.get_text(L("guild|acs_appoint")),
  levelup = ui.get_text(L("guild|acs_levelup")),
  attemper = ui.get_text(L("guild|acs_attemper")),
  selarylevel = ui.get_text(L("guild|acs_selarylevel")),
  draw_welfare = ui.get_text(L("guild|acs_draw_welfare")),
  depotshop = ui.get_text(L("guild|acs_depotshop")),
  schedule = ui.get_text(L("guild|acs_schedule")),
  no_access = ui.get_text(L("guild|no_access"))
}
function title_tip_init(title, tag)
  local self_access
  for i = 0, bo2.gv_guild_title.size - 1 do
    local line = bo2.gv_guild_title:get(i)
    if line.name == title then
      self_access = line.status
    end
  end
  local stk = sys.mtf_stack()
  local cnt = 0
  local function prt(acs, text, flag)
    if acs == 1 then
      if cnt > 0 then
        ui_tool.ctip_push_newline(stk)
      end
      ui_tool.ctip_push_text(stk, text, "00FF00")
      cnt = cnt + 1
    elseif flag == 1 then
      if cnt > 0 then
        ui_tool.ctip_push_newline(stk)
      end
      ui_tool.ctip_push_text(stk, text, "808080")
      cnt = cnt + 1
    end
  end
  for i = 0, bo2.gv_guild_auth.size - 1 do
    local line = bo2.gv_guild_auth:get(i)
    if line.id == self_access then
      cnt = 0
      prt(line.info, title_acs.info, tag)
      prt(line.invite, title_acs.invite, tag)
      prt(line.approve, title_acs.approve, tag)
      prt(line.kick, title_acs.kick, tag)
      prt(line.appoint, title_acs.appoint, tag)
      prt(line.levelup, title_acs.levelup, tag)
      prt(line.attemper, title_acs.attemper, tag)
      prt(line.selarylevel, title_acs.selarylevel, tag)
      prt(line.draw_welfare, title_acs.draw_welfare, tag)
      prt(line.depotshop, title_acs.depotshop, tag)
      prt(line.schedule, title_acs.schedule, tag)
      if cnt == 0 then
        ui_tool.ctip_push_text(stk, title_acs.no_access, "808080")
      end
    end
  end
  return stk
end
function on_tip_show(tip)
  local self_title = tip.owner.text
  local stk = title_tip_init(self_title, 0)
  ui_tool.ctip_show(tip.owner, stk)
end
function on_tip_show_2(tip)
  local self_title = tip.owner.text
  local stk = title_tip_init(self_title, 1)
  ui_tool.ctip_show(tip.owner, stk)
end
