local online = true
local option = "current_con"
local sort_asc = true
local hall_id = -2
local riddling_member_list = {}
local riddling_member_list_size = 0
local get_member_list = true
local sort_by, select, hall_select, apply_select
local cur_page = 1
local max_page = 1
local max_mamber = 0
local page_maxmember = bo2.gv_define_org:find(6).value.v_int
local hall_member_size = sys.variant()
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
function member_list_clear()
  for i = 0, g_member_list.item_count - 1 do
    g_member_list:item_get(i).visible = false
  end
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
function set()
end
function on_visible(w, vis)
  if vis then
    local page = ui_widget.ui_tab.get_show_page(ui_npc_guild_mod.ui_npc_guild.w_win)
    if page.name ~= L("member") then
      return
    end
    update_member()
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
      }
    },
    event = on_guild_menu_event,
    popup = "y2x2",
    source = ctrl,
    dx = ctrl.parent.dx
  }
  local npc_guild_index = ui.npc_guild_mb_id()
  for j = 0, bo2.gv_npc_hall_define.size - 1 do
    local n = bo2.gv_npc_hall_define:get(j)
    if n.disable == 0 and n.guild_id == npc_guild_index then
      riddling_member_menu.items[#riddling_member_menu.items + 1] = {
        text = n.hall_name,
        callback = on_set_hall,
        id = n.hall_number
      }
    end
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
  update_member()
end
function on_status_current_con(ctrl)
  option = "current_con"
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
  sort_by = "pos"
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
function on_total_con_sort(ctrl)
  sort_by = "total_con"
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
    local member = ui.guild_find_member(id.text)
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
  elseif option == "current_con" then
    text = tostring(member.current_con)
  end
  ui_widget.tip_make_view(tip.view, text)
end
function on_leave()
  local on_leave_msg = function(msg)
    if msg == nil then
      return
    end
    if msg.result == 1 then
      local v = sys.variant()
      bo2.send_variant(packet.eCTS_Guild_Leave, v)
      ui_npc_guild_mod.ui_npc_guild.w_win.visible = false
    end
  end
  local msg = {
    callback = on_leave_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    show_sound = 578,
    hide_sound = 579
  }
  msg.text = ui.get_text("org|leave_msg")
  ui_widget.ui_msg_box.show_common(msg)
end
function on_show_offline(ctrl)
  if g_show_check.check == true then
    online = not g_show_check.check
  else
    online = not g_show_check.check
  end
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
  if excel.kick == 0 or member == self then
    menu_remove(member_menu.items, "member")
  end
  if excel.dismiss == 0 then
    menu_remove(member_menu.items, "contribute")
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
  end
  if hall_id > 0 then
    local hall = ui.guild_get_hall(hall_id - 1)
    if hall ~= nil and member.hall_id == hall.id then
      return true
    end
    return false
  end
end
local cs_int_disable_text = SHARED("--")
local function make_int_text(i)
  if i < 0 then
    return cs_int_disable_text
  end
  return i
end
function set_riddlingitem(item, member)
  local id = item:search("id")
  id.text = member.id
  local name = item:search("name")
  name.text = member.name
  local level = item:search("level")
  level.text = make_int_text(member.level)
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
    if ui.npc_guild_mb_id() ~= 0 then
      local npc_hall = bo2.gv_npc_hall_define:find(guild_hall.weekcon)
      if npc_hall ~= nil then
        hall_item.text = npc_hall.hall_name
      else
        hall_item.text = guild_hall.name
      end
    else
      hall_item.text = guild_hall.name
    end
  else
    hall_item.text = "--"
  end
  local pos = item:search("pos")
  pos.text = bo2.gv_level_list:find(member.guild_pos).title
  local current_con = item:search("current_con")
  local c_con = member.current_con
  if c_con > 10000 then
    arg:clear()
    arg:set(L("con"), math.floor(c_con / 10000))
    current_con.text = sys.mtf_merge(arg, ui.get_text("guild|con"))
  else
    current_con.text = make_int_text(c_con)
  end
  local total_con = item:search("total_con")
  local t_con = member.total_con
  if t_con > 10000 then
    arg:clear()
    arg:set(L("con"), math.floor(t_con / 10000))
    total_con.text = sys.mtf_merge(arg, ui.get_text("guild|con"))
  else
    total_con.text = make_int_text(t_con)
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
  current_con.color = to_color
  total_con.color = to_color
  hall_item.color = to_color
  if select_id ~= nil and id.text == select_id then
    select = item
    item:search("fig_highlight_sel").visible = true
  else
    item:search("fig_highlight_sel").visible = false
  end
end
function update_list_page()
  local item_file = SHARED("$frame/npc_guild/member_n.xml")
  local item_style = SHARED("guild_item")
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
    if c <= i - _begin then
      item = g_member_list:item_append()
      item:load_style(item_file, item_style)
    else
      item = g_member_list:item_get(i - _begin)
    end
    item.visible = true
    set_riddlingitem(item, insert_item)
  end
end
function update_hall_membersize_init()
  hall_member_size:clear()
  local v = sys.variant()
  v:set("id", 0)
  v:set("leader", "")
  v:set("size", 0)
  hall_member_size:push_back(v)
  for i = 0, ui.guild_hall_size() - 1 do
    local hall = ui.guild_get_hall(i)
    local hall_v = sys.variant()
    hall_v:set("id", hall.id)
    hall_v:set("leader", "--")
    hall_v:set("size", 0)
    hall_member_size:push_back(hall_v)
  end
end
function find_hall(id)
  for i = 0, hall_member_size.size - 1 do
    local v = sys.variant()
    v = hall_member_size:get(i)
    if v:get("id").v_string == id then
      return v
    end
  end
  return nil
end
function online_filter(member)
  if online then
    return member.status == 1
  end
  return true
end
function update_select_member()
  riddling_member_list, riddling_member_list_size = ui.guild_select_member(online_filter, sort_by, sort_asc, true)
end
function update_member()
  if not ui_npc_guild_mod.ui_npc_guild.w_win.visible then
    return
  end
  local page = ui_widget.ui_tab.get_show_page(ui_npc_guild_mod.ui_npc_guild.w_win)
  if page.name ~= L("member") then
    return
  end
  local slider_y = g_member_list.slider_y.scroll
  select = nil
  local item_file = "$frame/npc_guild/member_n.xml"
  local item_style = "guild_item"
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
function get_hall_name(id)
  local hall_name = ui.guild_get_hall_name(id)
  if sys.check(hall_name) == false then
    hall_name = ui.get_text("guild|null")
  end
  return hall_name
end
function get_welfare_need_con(id)
  local line = bo2.gv_guild_welfare:find(id)
  local re_value = 0
  if line ~= nil then
    re_value = line.totalc
  end
  return re_value
end
function update_page()
  local arg = sys.variant()
  arg:set("cur_page", cur_page)
  arg:set("max_page", max_page)
  local page_text = sys.mtf_merge(arg, ui.get_text("guild|member_page"))
  g_member_page.text = page_text
end
function on_title_item_select(item, sel)
  ui_guild_mod.ui_guild.update_highlight(item)
  item:search("fig_highlight_sel").visible = item.selected or item.inner_hover
end
function sort_title(t)
  local mysort = function(a, b)
    return a.sort_id > b.sort_id
  end
  table.sort(t, mysort)
end
