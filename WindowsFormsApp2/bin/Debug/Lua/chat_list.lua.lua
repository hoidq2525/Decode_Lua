local c_list_limit = 80
local c_timer_limit = 8
local c_rb_text = SHARED("rb_text")
local c_chat_list_uri = SHARED("$widget/chat_list.xml")
local c_chat_list_style = SHARED("cmn_chat_list_item")
local prefix_cache = {}
local text_cache = {}
local insert_mtf = function(box, text, cache, rank)
  if text == nil then
    return
  end
  if sys.is_type(text, "mtf_parser") then
    box:insert_mtf(text, rank)
    return
  end
  local psr
  if text == cache.text then
    psr = cache.parser
  else
    psr = sys.mtf_parser(text)
    cache.text = text
    cache.parser = psr
  end
  box:insert_mtf(psr, rank)
end
local function do_insert(d, data, pos, uri, style)
  local view = d.view
  local count = view.item_count
  local item
  local pre_scroll = view.scroll
  local bottom = d.bottom
  if count >= d.limit then
    for i = 1, count - d.limit do
      if pos ~= nil then
        view:item_remove(view.item_count - 1)
      else
        view:item_remove(0)
      end
    end
    if pos ~= nil then
      item = view:item_get(view.item_count - 1)
      item.index = 0
    else
      item = view:item_get(0)
      item.index = count - 1
    end
  else
    if pos ~= nil then
      item = view:item_insert(0)
    else
      item = view:item_append()
    end
    if uri and style then
      item:load_style(uri, style)
    else
      item:load_style(c_chat_list_uri, c_chat_list_style)
    end
  end
  item.svar = data
  data.item = item
  local rank = data.rank
  if rank == nil then
    rank = ui.mtf_rank_system
    data.rank = rank
  end
  local box = item:search(c_rb_text)
  data.box = box
  box:item_clear()
  insert_mtf(box, data.prefix, prefix_cache, ui.mtf_rank_system)
  insert_mtf(box, data.text, text_cache, rank)
  item:tune_y(c_rb_text)
  if pos ~= nil then
    view.scroll = 0
  else
    if bottom == true and pre_scroll == 1 then
      view.scroll = 1
    end
    if bottom == false then
      view.scroll = 1
    end
  end
  if view.scroll == 1 then
    d.bottom = true
  end
end
function insert(w, data, pos, uri, style)
  local d = w.svar.chat_list_data
  if d == nil then
    ui.log("chat_list insert d is nil")
    return
  end
  do_insert(d, data, pos, uri, style)
end
function clear(w)
  local d = w.svar.chat_list_data
  if d == nil then
    return
  end
  d.view:item_clear()
  d.datas = {}
end
function view(w)
  local d = w.svar.chat_list_data
  if d == nil then
    return
  end
  return d.view
end
function update_items(view)
  for i = 0, view.item_count - 1 do
    local item = view:item_get(i)
    item:tune_y(c_rb_text)
  end
end
function on_move(view, area)
  function do_update()
    update_items(view)
  end
  view:insert_post_invoke(do_update, "ui_widget.ui_text_list.update")
end
local safe_get_view = function(box)
  local item = box:upsearch_type("ui_list_item")
  if item ~= nil then
    return item.view
  end
  return box
end
local mark_data = {}
local function item_mark_show_tip(box, excel, info)
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item(stk, excel, info)
  local main_top = ui_main.w_top
  if main_top.visible then
    local p = box.parent
    while p ~= nil do
      if p == main_top then
        ui_item.show_tip_frame(stk.text, excel, info)
        return
      end
      p = p.parent
    end
  end
  ui_tool.ctip_show_popup(safe_get_view(box), stk.text, "x_auto")
end
function on_player_portrait_event(item)
  if item.callback then
    item:callback()
  end
end
function copy_dialog_content(item)
  local info = item.owner_menu.info
  local content = info.content
  if content ~= nil then
    ui_chat.insert_copycontent(content)
  end
end
local function u_handler(box, data, msg, pt)
  local name, color = data.value:split2(",")
  if msg == ui.mouse_lbutton_dbl then
    ui_chat.set_channel(bo2.eChatChannel_PersonalChat, name)
  elseif msg == ui.mouse_rbutton_click then
    local items
    if name ~= bo2.player.name then
      ui_im.generate_rb(name)
      items = ui_im.im_rb_items
    else
      items = {
        {
          text = ui.get_text("menu|copy_name"),
          callback = ui_portrait.copy_the_name,
          id = bo2.ePortraitMenu_CopyName
        }
      }
    end
    local the_box = box:search(c_rb_text)
    local content
    if the_box ~= nil then
      local chat_text = box:search(c_rb_text).mtf
      local tar_text = "<u:" .. data.value .. ">"
      local pos = chat_text:find(tar_text)
      if pos ~= -1 then
        local content_tmp = chat_text:substr(pos + tar_text.size, chat_text.size - 1)
        local pos_b = content_tmp:find(": ")
        if pos_b ~= -1 then
          content = content_tmp:substr(pos_b + 2, content_tmp.size - 1)
        end
      end
      if content ~= nil then
        table.insert(items, {
          text = ui.get_text("chat|copy_content"),
          callback = copy_dialog_content
        })
      end
    end
    local datas = {
      items = items,
      info = {
        name = name,
        real_name = name,
        content = content
      },
      popup = "y_auto",
      dx = 120,
      dy = 50,
      offset = box:control_to_window(pt)
    }
    ui_tool.show_cha_menu(datas)
  end
end
g_mark_deliver = nil
function load_mark_deliver()
  if g_mark_deliver == nil then
    g_mark_deliver = sys.load_table("$mb/scn/mark_deliver.xml")
  end
end
function find_mark_deliver(i)
  load_mark_deliver()
  if g_mark_deliver ~= nil then
    return g_mark_deliver:find(i)
  end
  return nil
end
function get_mark_deliver(i)
  load_mark_deliver()
  if g_mark_deliver ~= nil then
    return g_mark_deliver:get(i)
  end
  return nil
end
function get_mark_deliver_size()
  load_mark_deliver()
  if g_mark_deliver ~= nil then
    return g_mark_deliver.size
  end
end
function get_scn_mark_deliver_id(scn, target_scn)
  local t_excel = find_mark_deliver(target_scn)
  if t_excel == nil then
    return 0
  end
  local npcfunc = t_excel.npc_func
  if npcfunc ~= nil then
    local excel = bo2.gv_npc_func:find(npcfunc)
    if excel ~= nil and excel.datas.size == 2 then
      local obj = bo2.player
      if sys.check(obj) ~= true then
        return 0
      end
      local player_lv = bo2.player:get_atb(bo2.eAtb_Level)
      if player_lv < excel.datas[1] then
        return 0
      end
    end
  end
  local b_excel = find_mark_deliver(scn)
  if sys.check(b_excel) then
    return b_excel.mark_id
  end
  return 0
end
function is_multi_server(scn_id)
  local scn_list = bo2.gv_scn_list:find(scn_id)
  if scn_list == nil then
    return
  end
  if scn_list.is_multi_scn_server == 0 then
    return true
  else
    return false
  end
end
function is_player_target_scn_id(excel)
  local server_id = bo2.player:GetPlayerServerID()
  local i
  for i = 1, bo2.gv_multi_server_cfg.size do
    local multi_server_cfg = bo2.gv_multi_server_cfg:find(i)
    if server_id == multi_server_cfg.server_id and excel.scn_group_id == multi_server_cfg.scn_group_id then
      return multi_server_cfg.multi_server_id
    end
  end
  return 0
end
function get_target_scn_id(excel)
  local target_scn_id = 0
  local i
  if excel.scn_id.size > 1 then
    local multi_server_id = is_player_target_scn_id(excel) - 1
    local scn_id = excel.scn_id[multi_server_id]
    if false == is_multi_server(scn_id) then
      target_scn_id = excel.scn_id[multi_server_id]
    end
  else
    target_scn_id = excel.scn_id[0]
  end
  return target_scn_id
end
function on_click_mark_id(id, excel, link)
  local n_id = id
  local base_id = id
  local scn = bo2.scn
  local scn_excel_id = 0
  if sys.check(scn) and scn.excel then
    scn_excel_id = scn.excel.id
  end
  local link_id = 0
  local use_link = false
  if link ~= nil and sys.check(link) then
    link_id = link.v_int
  end
  local use_deliver = false
  local target_scn_id = excel.scn_id
  if sys.check(excel) and target_scn_id ~= scn_excel_id then
    if link_id ~= 0 then
      local link_excel = bo2.gv_mark_list:find(link_id)
      if sys.check(link_excel) and link_excel.scn_id == scn_excel_id then
        n_id = link_excel.id
        use_link = true
      end
    else
      link_id = 0
    end
    if use_link ~= true and excel.disable_deliver ~= 1 then
      local new_mark_id = get_scn_mark_deliver_id(scn_excel_id, target_scn_id)
      if new_mark_id ~= 0 then
        n_id = new_mark_id
        use_deliver = true
      end
    end
  end
  ui_handson_teach.test_complate_mark_list(n_id, link_id)
  ui_map.clear_store()
  ui_map.find_path_byid(n_id)
  if use_deliver then
    ui_map.store_target_mark(base_id)
  end
end
local widget_mouse_handler = {
  [L("u")] = u_handler,
  [L("q_user")] = u_handler,
  [L("imn")] = u_handler,
  [L("i")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local excel = ui.item_get_excel(data.value.v_int)
      item_mark_show_tip(box, excel)
    elseif msg == ui.mouse_mbutton_click and ui.is_key_down(ui.VK_CONTROL) then
      local excel = ui.item_get_excel(data.value.v_int)
      ui_fitting_room.req_fitting_item_by_excel(excel)
    end
  end,
  [L("drop_type")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local stk = sys.mtf_stack()
      ui_tool.ctip_make_drop_type(stk, data.value.v_int)
      local main_top = ui_main.w_top
      if main_top.visible then
        local p = box.parent
        while p ~= nil do
          if p == main_top then
            ui_item.show_tip_frame(stk.text, nil, nil)
            return
          end
          p = p.parent
        end
      end
      ui_tool.ctip_show_popup(safe_get_view(box), stk.text, "x_auto")
    end
  end,
  [L("fi")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local excel = ui.item_get_excel(data.value.v_int)
      local info = ui.item_create(excel.id, bo2.eItemBox_Special, bo2.eItemBox_Special_Tip)
      info.code = data.value
      item_mark_show_tip(box, excel, info)
    elseif msg == ui.mouse_mbutton_click and ui.is_key_down(ui.VK_CONTROL) then
      local excel = ui.item_get_excel(data.value.v_int)
      ui_fitting_room.req_fitting_item_by_excel(excel)
    end
  end,
  [L("si")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local excel = ui.item_get_excel(data.value.v_int)
      local info = ui.item_create(excel.id, bo2.eItemBox_Special, bo2.eItemBox_Special_Tip)
      info.code = data.value
      item_mark_show_tip(box, excel, info)
    elseif msg == ui.mouse_mbutton_click and ui.is_key_down(ui.VK_CONTROL) then
      local excel = ui.item_get_excel(data.value.v_int)
      ui_fitting_room.req_fitting_item_by_excel(excel)
    end
  end,
  [L("ci")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local excel = ui.item_get_excel(data.value.v_int)
      item_mark_show_tip(box, excel)
    elseif msg == ui.mouse_enter then
      local excel = ui.item_get_excel(data.value.v_int)
      local stk = sys.mtf_stack()
      ui_tool.ctip_make_item(stk, excel, info)
      local view = ui.find_control("$tip:common")
      ui_widget.tip_make_view(view, stk.text)
      view:show_popup(data.widget, "y_auto")
    elseif msg == ui.mouse_leave then
      local view = ui.find_control("$tip:common")
      view.visible = false
    end
  end,
  [L("url")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local arg, url, txt = data.value:split("|", 3)
      ui.shell_execute("open", url)
    end
  end,
  [L("mark")] = function(box, data, msg, pt)
    if msg ~= ui.mouse_lbutton_click and msg ~= ui.mouse_lbutton_dbl then
      return
    end
    local function on_box_mark()
      if box ~= mark_data.box then
        return
      end
      local id, name, link = data.value:split(",")
      id = id.v_int
      local excel = bo2.gv_mark_list:find(id)
      if excel then
        on_click_mark_id(id, excel, link)
      else
        if id == 0 and not name.empty then
          local size = bo2.gv_mark_list.size
          for i = 0, size - 1 do
            local c_excel = bo2.gv_mark_list:get(i)
            if name == c_excel.enter_point then
              excel = c_excel
              id = c_excel.id
              break
            end
          end
        end
        on_click_mark_id(id, excel, link)
      end
      if mark_data.msg == ui.mouse_lbutton_dbl then
        bo2.startmove_k()
      end
    end
    mark_data.box = box
    mark_data.data = data
    mark_data.msg = msg
    box:insert_post_invoke(on_box_mark, "ui_widget.ui_chat_list.on_box_mark")
  end,
  [L("skill")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local excel_id, level, type = data.value:split(",", 3)
      local info = {}
      info.excel_id = excel_id.v_int
      if level == nil or level == 0 then
        info.level = 1
      else
        info.level = level.v_int
      end
      if type == nil or type == 0 then
        if bo2.gv_skill_group:find(info.excel_id) ~= nil then
          info.type = 1
        elseif bo2.gv_passive_skill:find(info.excel_id) ~= nil then
          info.type = 0
        else
          return
        end
      else
        info.type = type.v_int
      end
      local stk = sys.mtf_stack()
      if info.type == 1 then
        local excel = ui_tool.ctip_make_skill(stk, info)
        if excel ~= nil and excel.preview_id ~= 0 then
          ui_tool.ctip_show_skill_popup(safe_get_view(box), stk.text, "x_auto", excel.preview_id)
          return true
        end
      else
        ui_tool.ctip_make_passive_skill(stk, info)
      end
      ui_tool.ctip_show_popup(safe_get_view(box), stk.text, "x_auto")
    end
  end,
  [L("ridepet")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local var = ui.ride_decode(data.value)
      var:set(packet.key.ridepet_item_val, 1)
      ui_ridepet_view.send_ridepet_view(var)
    end
  end,
  [L("openui")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local _, uiid, _ = data.value:split(",", 3)
      uiid = uiid.v_int
      ui_levelup.open_ui_by_id(uiid)
    end
  end,
  [L("ch")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      ui_chat.set_channel(data.value.v_int)
    end
  end,
  [L("arena")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local v = sys.variant()
      local arena_id, name = data.value:split2(",")
      ui_match.OnLinkClick(arena_id)
    end
  end,
  [L("matchscn")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local v = sys.variant()
      local arena_id, name = data.value:split2(",")
      ui_match.OnLinkClick_Scn(arena_id)
    end
  end,
  [L("quest")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local excel = bo2.gv_quest_list:find(data.value.v_int)
      ui_quest.ui_tip.set_quest(excel)
    end
  end,
  [L("milestone")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local excel = bo2.gv_milestone_list:find(data.value.v_int)
      ui_quest.ui_tip.set_milestone(excel)
    end
  end,
  [L("position")] = function(box, data, msg, pt)
    if msg ~= ui.mouse_lbutton_click and msg ~= ui.mouse_lbutton_dbl then
      return
    end
    local function on_box_position()
      local scn_id, pos_x, pos_z = data.value:split(",", 3)
      scn_id = scn_id.v_int
      pos_x = pos_x.v_int
      pos_z = pos_z.v_int
      local v = bo2.findpath_k(scn_id, pos_x, pos_z)
      if v then
        ui_map.update_path()
        ui_minimap.set_path_npc()
        bo2.showpath_k()
        bo2.startmove_k()
      end
    end
    box:insert_post_invoke(on_box_position, "ui_widget.ui_chat_list.on_box_position")
  end,
  [L("useskill")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local function on_use_skill()
        local skill_id = data.value
        skill_id = skill_id.v_int
        local excel = bo2.gv_skill_group:find(skill_id)
        if excel == nil then
          return
        end
        local info = ui.skill_find(skill_id)
        if info == nil then
          return
        end
        if info.type == 1 and excel.weapon2nd_type >= bo2.eItemtype_UseHWeapon and excel.weapon2nd_type <= bo2.eItemType_UseHWeaponEnd then
          return
        end
        if info.xinfa ~= nil then
          local xinfa_item = bo2.gv_xinfa_list:find(info.xinfa.excel_id)
          if xinfa_item ~= nil and xinfa_item.type_id ~= bo2.eXinFaType_Etiquette then
            return
          end
        end
        ui_shortcut.shortcut_use_skill(skill_id)
      end
      box:insert_post_invoke(on_use_skill, "ui_widget.ui_chat_list.on_use_skill")
    elseif msg == ui.mouse_enter then
      local info = ui.skill_find(data.value.v_int)
      local stk = sys.mtf_stack()
      ui_tool.ctip_make_shortcut_skill(stk, info)
      local view = ui.find_control("$tip:common")
      ui_widget.tip_make_view(view, stk.text)
      view:show_popup(data.widget, "y_auto")
    elseif msg == ui.mouse_leave then
      local view = ui.find_control("$tip:common")
      view.visible = false
    end
  end,
  [L("useitem")] = function(box, data, msg, pt)
    if msg == ui.mouse_lbutton_click then
      local function on_use_item()
        local item_id = data.value
        local item_info = ui.item_of_excel_id(item_id.v_int, bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
        if item_info ~= nil then
          local excel = item_info.excel
          if excel ~= nil and excel.use_id ~= 0 then
            ui_item.use_item(item_info, true)
            return
          end
        end
        ui_tool.note_insert(ui.get_text("widget|use_item_error"), "FF0000")
      end
      box:insert_post_invoke(on_use_item, "ui_widget.ui_chat_list.on_use_item")
    elseif msg == ui.mouse_enter then
      local excel = ui.item_get_excel(data.value.v_int)
      local stk = sys.mtf_stack()
      ui_tool.ctip_make_item(stk, excel)
      local view = ui.find_control("$tip:common")
      ui_widget.tip_make_view(view, stk.text)
      view:show_popup(data.widget, "y_auto")
    elseif msg == ui.mouse_leave then
      local view = ui.find_control("$tip:common")
      view.visible = false
    end
  end
}
local copy_link = function(box, data, msg, pt)
  if not ui.in_game() then
    return
  end
  ui_chat.insert_mtf_link(sys.format("<%s:%s>", data.name, data.value))
end
local widget_copy_link_handler = {
  [L("i")] = copy_link,
  [L("fi")] = copy_link,
  [L("si")] = copy_link,
  [L("skill")] = copy_link,
  [L("mark")] = copy_link,
  [L("ridepet")] = copy_link,
  [L("quest")] = copy_link,
  [L("milestone")] = copy_link
}
function on_widget_mouse(box, data, msg, pt)
  if msg == ui.mouse_lbutton_click and ui.is_key_down(ui.VK_CONTROL) then
    local h = widget_copy_link_handler[data.name]
    if h ~= nil then
      h(box, data, msg, pt)
      return
    end
  end
  if data == nil or sys.check(data) ~= true then
    return
  end
  local h = widget_mouse_handler[data.name]
  if h == nil then
    return
  end
  h(box, data, msg, pt)
end
local item_fit = function(box, data, msg, pt)
  if msg == ui.mouse_lbutton_click then
    local excel = ui.item_get_excel(data.value.v_int)
  end
end
local widget_drop_handler = {
  [L("i")] = item_fit
}
function on_widget_drop(box, msg, pos, data)
end
function on_timer(timer)
  local w = timer.owner
  local d = w.svar.chat_list_data
  if d == nil then
    return
  end
  local datas = d.datas
  local cnt = #datas
  if cnt == 0 then
    timer.suspended = true
    return
  end
  local limit = c_timer_limit
  if not w.observable then
    limit = math.floor(limit / 3) + 1
  end
  if cnt > limit then
    cnt = limit
  end
  for i = 1, cnt do
    local data = datas[1]
    table.remove(datas, 1)
    do_insert(d, data.data, nil, data.uri, data.style)
  end
  if limit > cnt then
    timer.suspended = true
  end
end
function on_init(w)
  local d = {
    limit = c_list_limit,
    view = w:search("chat_list"),
    window = w,
    bottom = false,
    datas = {}
  }
  local timer = w.timer
  timer.suspended = true
  timer.period = 100
  timer:insert_on_timer(on_timer, "ui_widget.ui_chat_list.on_timer")
  d.timer = timer
  w.svar.chat_list_data = d
end
