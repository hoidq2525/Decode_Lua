local c_image_qt_offline = L("$image/guild/qt_sound.png|19,301,16,20")
local c_image_qt_online = L("$image/guild/qt_sound.png|19,187,16,20")
local c_image_qt_speaking = L("$image/guild/qt_sound.png|19,226,16,20")
local c_image_qt_masked = L("$image/guild/qt_sound.png|19,261,16,20")
warining_color = L("FFFF0000")
local ui_tab = ui_widget.ui_tab
local disable_qt = bo2.gv_define:find(1106).value.v_int
function check_has_union()
  local ctrl = w_union_list:item_get(0)
  if ctrl == nil or ctrl:search("member_count").text == L("") then
    return false
  else
    return true
  end
end
function insert_tab(name)
  local btn_uri = "$frame/team/team.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/team/team.xml"
  local page_sty = name
  ui_tab.insert_suit(w_main, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_main, name)
  btn.text = ui.get_text("team|" .. name)
end
function on_init()
  ui.log("on_init")
  ui_tab.clear_tab_data(w_main)
  insert_tab("team_tab")
  insert_tab("union_tab")
  ui_tab.show_page(w_main, "team_tab", true)
  local team_tab = ui_tab.get_page(w_main, "team_tab")
  ui_widget.ui_combo_box.clear(w_team_alloc)
  local item = {
    text = ui.get_text("menu|group_alloc_free"),
    callback = ui_team.send_group_alloc,
    combox = w_team_alloc,
    id = 0
  }
  ui_widget.ui_combo_box.append(w_team_alloc, item)
  item = {
    text = ui.get_text("menu|group_alloc_captain"),
    combox = w_team_alloc,
    callback = ui_team.send_group_alloc,
    id = 2
  }
  ui_widget.ui_combo_box.append(w_team_alloc, item)
  ui_widget.ui_combo_box.clear(w_toos_level)
  local function init_level(i)
    local lvlExcel = bo2.gv_lootlevel:find(i)
    item_color = ui.make_color(lvlExcel.color)
    item = {
      text = ui.get_text(sys.format("team|toos_level_%d", i)),
      color = item_color,
      id = i,
      callback = ui_team.send_group_alloc_toos_level
    }
    ui_widget.ui_combo_box.append(w_toos_level, item)
  end
  for i = 11, 15 do
    init_level(i)
  end
  init_level(100)
  ui_widget.ui_combo_box.select(w_team_alloc, 0)
  ui_widget.ui_combo_box.select(w_toos_level, 12)
  w_team_alloc.svar.on_select = ui_team.send_group_alloc
  w_toos_level.svar.on_select = ui_team.send_group_alloc_toos_level
  local btn_alloc = w_team_alloc:search("btn_drop_down")
  btn_alloc.enable = false
  local btn_toos = w_toos_level:search("btn_drop_down")
  btn_toos.enable = false
  w_invite_btn.enable = false
  w_inform_btn.enable = false
  w_group_0:item_clear()
  w_group_1:item_clear()
  w_group_2:item_clear()
  w_group_3:item_clear()
  local item_file = L("$frame/team/team.xml")
  local item_style = L("member")
  for i = 0, 4 do
    local item = w_group_0:item_append()
    item:load_style(item_file, item_style)
    item.size = ui.point(200, 26)
    local t = item:search("top_panel")
    t.visible = false
    item.var:set("g_index", i)
    item = w_group_1:item_append()
    item:load_style(item_file, item_style)
    item.size = ui.point(200, 26)
    local t = item:search("top_panel")
    t.visible = false
    item.var:set("g_index", i + 5)
    item = w_group_2:item_append()
    item:load_style(item_file, item_style)
    item.size = ui.point(200, 26)
    local t = item:search("top_panel")
    t.visible = false
    item.var:set("g_index", i + 10)
    item = w_group_3:item_append()
    item:load_style(item_file, item_style)
    item.size = ui.point(200, 26)
    local t = item:search("top_panel")
    t.visible = false
    item.var:set("g_index", i + 15)
  end
  for i = 0, 19 do
    local member_info = ui.member_get_by_idx(i)
    member_info:insert_on_update("ui_team.on_member_update", "ui_team:on_member_update")
  end
end
function on_visible(w, vis)
  if vis then
    bo2.PlaySound2D(578)
    ui_widget.esc_stk_push(w)
    update_qt_status()
    if ui.get_team_captain_id() ~= bo2.player.only_id then
      w_qt_together.visible = false
    else
      w_qt_together.visible = true
    end
  else
    bo2.PlaySound2D(579)
    ui_widget.esc_stk_pop(w)
  end
end
function update_qt_status()
  for i = 0, 19 do
    local info = ui.member_get_by_idx(i)
    on_member_update(info)
  end
end
function set_visible(vis)
  local w = ui.find_control("$frame:team")
  w.visible = vis
end
function set_career_icon(pic, career_idx)
  pic.image = sys.format("$image/personal/32x32/%d.png|0,0,27,30", career_idx + 1)
end
function set_career_color(pic, career_idx)
  local pro = bo2.gv_profession_list:find(career_idx)
  if pro ~= nil then
    ui_portrait.make_career_color(pic, pro)
  end
end
function get_roll_color(roll_lev)
  local roll_color = "FFFFFFFF"
  local lvlExcel = bo2.gv_lootlevel:find(roll_lev)
  if lvlExcel == nil then
    return roll_color
  end
  roll_color = lvlExcel.color
  return ui.make_color(roll_color)
end
function set_config(data)
  if ui.get_team_id() == sys.wstring(0) then
    if ui_portrait.w_team_btn ~= nil then
      ui_portrait.w_team_btn.visible = false
    end
    return
  end
  local captain_id = ui.get_team_captain_id()
  local cap_info = ui.member_find(captain_id)
  local member_count = data:get(packet.key.group_max_member_count).v_int
  ui.log("membercout:%d", member_count)
  if member_count > 5 then
    for i = 0, 19 do
      local member_info = ui.member_get_by_idx(i)
      if member_info.only_id ~= sys.wstring(0) then
        on_member_update(member_info)
      end
    end
  end
  local alloc_mode = data:get(packet.key.group_alloc_mode).v_int
  local roll_lev = data:get(packet.key.group_alloc_rolllevel).v_int
  local btn_toos = w_toos_level:search("btn_drop_down")
  local btn_alloc = w_team_alloc:search("btn_drop_down")
  local mode_i = ui_widget.ui_combo_box.selected(w_team_alloc)
  local level_i = ui_widget.ui_combo_box.selected(w_toos_level)
  local level_i_id = 0
  if level_i ~= nil then
    local level_i_id = level_i.id
  end
  local mode_v = 0
  local mode_t
  if alloc_mode == packet.key.group_alloc_free then
    mode_v = 0
    mode_t = ui.get_text("menu|group_alloc_free")
  elseif alloc_mode == packet.key.group_alloc_roll then
    mode_v = 1
    mode_t = ui.get_text("menu|group_alloc_roll")
  elseif alloc_mode == bo2.eLootMod_GroupCaptainAssign then
    mode_v = 2
    mode_t = ui.get_text("menu|group_alloc_captain")
  end
  local level_v = roll_lev
  if bo2.scn.scn_excel.nogroup ~= 1 and sys.check(mode_i) and (mode_i.id ~= mode_v or level_v ~= level_i_id) then
    local lvlExcel = bo2.gv_lootlevel:find(roll_lev)
    local v = sys.variant()
    local level_t = ui.get_text(sys.format("team|toos_level_%d", roll_lev))
    v:set("mode", mode_t)
    v:set("level", level_t)
    local text = sys.mtf_merge(v, ui.get_text("team|alloc_note"))
    if mode_v == 2 then
      text = sys.mtf_merge(v, ui.get_text("team|alloc_note_captain"))
    end
    if roll_lev == 100 then
      text = sys.mtf_merge(v, ui.get_text("team|alloc_note_free"))
    end
    if bo2.player.only_id ~= captain_id then
      ui_tool.note_insert(text, "FF00FF00")
    end
  end
  ui_widget.ui_combo_box.select(w_team_alloc, mode_v)
  local roll_color = get_roll_color(roll_lev)
  ui_widget.ui_combo_box.set_selected_color(w_team_alloc, roll_color)
  if bo2.player.only_id == ui.get_team_captain_id() then
    ui_widget.ui_combo_box.clear(w_toos_level)
    local init_level = function(i)
      local lvlExcel = bo2.gv_lootlevel:find(i)
      item_color = ui.make_color(lvlExcel.color)
      item = {
        text = ui.get_text(sys.format("team|toos_level_%d", i)),
        color = item_color,
        id = i,
        callback = ui_team.send_group_alloc_toos_level
      }
      ui_widget.ui_combo_box.append(w_toos_level, item)
    end
    for i = 11, 15 do
      init_level(i)
    end
    if alloc_mode ~= bo2.eLootMod_GroupCaptainAssign then
      init_level(100)
    end
    btn_toos.enable = true
    btn_alloc.enable = true
    w_invite_btn.enable = true
    w_inform_btn.enable = true
    if check_has_union() then
      w_leave_union_btn.enable = true
    end
    w_invite_union_btn.enable = true
  else
    btn_toos.enable = false
    btn_alloc.enable = false
    w_invite_btn.enable = false
    w_inform_btn.enable = false
    w_leave_union_btn.enable = false
    w_invite_union_btn.enable = false
  end
  ui_widget.ui_combo_box.select(w_toos_level, roll_lev)
  if ui_portrait.w_team_btn ~= nil then
    ui_portrait.w_team_btn.visible = true
  end
end
function set_captain(only_id)
  if ui.get_team_id() == sys.wstring(0) then
    return
  end
  local cap_info = ui.member_find(only_id)
  local btn_alloc = w_team_alloc:search("btn_drop_down")
  local btn_toos = w_toos_level:search("btn_drop_down")
  if only_id == bo2.player.only_id then
    btn_alloc.enable = true
    btn_toos.enable = true
    local s_item = ui_widget.ui_combo_box.selected(w_team_alloc)
    w_invite_btn.enable = true
    w_inform_btn.enable = true
    if check_has_union() then
      w_leave_union_btn.enable = true
    end
    w_invite_union_btn.enable = true
  else
    btn_alloc.enable = false
    btn_toos.enable = false
    w_inform_btn.enable = false
    w_invite_btn.enable = false
    w_leave_union_btn.enable = false
    w_invite_union_btn.enable = false
  end
end
function release_group()
  local btn_alloc = w_team_alloc:search("btn_drop_down")
  local btn_toos = w_toos_level:search("btn_drop_down")
  btn_alloc.enable = false
  btn_toos.enable = false
  w_inform_btn.enable = false
  w_invite_btn.enable = false
  w_leave_union_btn.enable = false
  w_invite_union_btn.enable = false
  for i = 0, 9 do
    local ctrl = w_union_list:item_get(i)
    if ctrl ~= nil then
      ctrl:search("team_number").color = ui.make_color("444444")
      ctrl:search("captain").text = ""
      ctrl:search("member_count").text = ""
      ctrl:search("bg_fader").alpha = 0.5
    end
  end
  for i = 0, 4 do
    local item = w_group_0:item_get(i)
    local t = item:search("top_panel")
    t.visible = false
    item.var:set("g_index", i)
    item = w_group_1:item_get(i)
    local t = item:search("top_panel")
    t.visible = false
    item.var:set("g_index", i + 5)
    item = w_group_2:item_get(i)
    local t = item:search("top_panel")
    t.visible = false
    item.var:set("g_index", i + 10)
    item = w_group_3:item_get(i)
    local t = item:search("top_panel")
    t.visible = false
    item.var:set("g_index", i + 15)
  end
  if ui_portrait.w_team_btn ~= nil then
    ui_portrait.w_team_btn.visible = false
  end
  set_visible(false)
  ui_team.ui_team_watch.set_visible(false)
  ui_widget.ui_combo_box.select(w_team_alloc, 0)
  ui_widget.ui_combo_box.select(w_toos_level, 12)
  ui_portrait.g_alloc_mode = 0
  ui_portrait.g_roll_level = 0
end
function get_member_index(index)
  if index >= 0 and index <= 4 then
    return 0
  elseif index <= 9 then
    return 1
  elseif index <= 14 then
    return 2
  elseif index <= 19 then
    return 3
  end
  return -1
end
function get_list_view(index)
  if index == 0 then
    return w_group_0
  elseif index == 1 then
    return w_group_1
  elseif index == 2 then
    return w_group_2
  elseif index == 3 then
    return w_group_3
  end
  return nil
end
function get_item_index(index)
  if index >= 0 and index <= 4 then
    return index
  elseif index <= 9 then
    return index - 5
  elseif index <= 14 then
    return index - 10
  elseif index <= 19 then
    return index - 15
  end
  return -1
end
c_status_offline = "FF555555"
c_status_online = "FFFFFFFF"
c_status_slef = "FF0CF700"
c_status_dead = "FFFF0000"
function set_ctrl_onoffline(ctrl, b)
  ctrl.visible = b
  if ctrl.parent.mouse_able ~= nil then
    ctrl.parent.mouse_able = b
  end
end
function on_member_update(member_info)
  if ui.get_team_id() == sys.wstring(0) then
    return
  end
  local list_view = get_list_view(get_member_index(member_info.index))
  if list_view == nil then
    return
  end
  local i_index = get_item_index(member_info.index)
  if i_index == -1 then
    return
  end
  local item = list_view:item_get(i_index)
  local only_id = member_info.only_id
  local t = item:search("top_panel")
  if only_id == sys.wstring(0) then
    t.visible = false
  else
    t.visible = true
  end
  local captain = item:search("captain")
  local career = item:search("career")
  local career_idx = ui_portrait.get_career_idx(member_info.career)
  set_career_icon(career, career_idx)
  set_career_color(career, member_info.career)
  local name = item:search("name")
  name.text = member_info.name
  local level = item:search("level")
  local param = sys.variant()
  param:set("level", member_info.level)
  level.text = sys.mtf_merge(param, ui.get_text("team|member_level"))
  item.var:set("only_id", only_id)
  if member_info.is_captain == true then
    captain.visible = true
  else
    captain.visible = false
    local select = item:search("select")
    select.visible = false
  end
  local btn_check = item:search("btn_watch")
  if ui_team.ui_team_watch.is_already_exist(only_id) then
    btn_check.check = true
  else
    btn_check.check = false
  end
  local tint
  if member_info.status == 1 then
    name.xcolor = c_status_online
    set_ctrl_onoffline(career, true)
    set_ctrl_onoffline(level, true)
  end
  local qt_state = item:search("qt_state")
  if disable_qt ~= 1 then
    qt_state.visible = true
  end
  if 0 >= member_info.hp then
    name.xcolor = c_status_dead
  end
  if member_info.status == 0 then
    name.xcolor = c_status_offline
    set_ctrl_onoffline(career, false)
    set_ctrl_onoffline(level, false)
    if disable_qt ~= 1 then
      qt_state.visible = false
    end
  end
  if member_info.only_id == bo2.player.only_id then
    local param = sys.variant()
    param:set("level", bo2.player:get_atb(bo2.eAtb_Level))
    level.text = sys.mtf_merge(param, ui.get_text("team|member_level"))
    if member_info.status == 1 then
      name.xcolor = ui_team.c_status_slef
    end
    if 0 >= bo2.player:get_atb(bo2.eAtb_HP) then
      name.xcolor = ui_team.c_status_dead
    end
    if member_info.status == 0 then
      name.xcolor = ui_team.c_status_offline
    end
    local career_idx = ui_portrait.get_career_idx(bo2.player:get_atb(bo2.eAtb_Cha_Profession))
    set_career_icon(career, career_idx)
    set_career_color(career, bo2.player:get_atb(bo2.eAtb_Cha_Profession))
  end
  local ready = item:search("ready")
  if member_info.ready == 1 then
    ready.visible = true
  else
    ready.visible = false
  end
  local qt_image = qt_state:search("qt_image")
  if disable_qt ~= 1 then
    qt_state.visible = true
    if member_info.qt_state == 0 then
      qt_image.image = c_image_qt_masked
    elseif member_info.qt_state == 1 then
      qt_image.image = c_image_qt_online
    elseif member_info.qt_state == 2 then
      qt_image.image = c_image_qt_speaking
    elseif member_info.qt_state == 4 then
      qt_image.image = c_image_qt_offline
    else
      qt_image.image = c_image_qt_offline
    end
    if member_info.only_id == bo2.player.only_id then
      qt_image.image = ""
    end
  else
    qt_state.visible = false
  end
  ui_team_watch.on_member_update(member_info)
end
function on_member_delete(member_info)
end
function group_ready()
  if w_timer.suspended == false then
    w_timer.suspended = true
  end
  w_timer.suspended = false
end
function on_timer(timer)
  ui.team_clear_ready()
  timer.suspended = true
end
function on_member_insert(member_info)
  if member_info == nil then
    return
  end
  add_member(member_info)
end
function on_member_remove(member_info)
  ui.log("remove member")
  if member_info == nil then
    return
  end
  local index = get_member_index(member_info.index)
  if index == -1 then
    ui.log("member pos ERROR")
    return
  end
  local list_view = get_list_view(index)
  if list_view == nil then
    ui.log("group list_view ERROR")
    return
  end
  local i_index = get_item_index(member_info.index)
  if i_index == -1 then
    return
  end
  local item = list_view:item_get(i_index)
  if item ~= nil then
    local t = item:search("top_panel")
    t.visible = false
    item.var:set("only_id", 0)
    if member_info.name == ui_tool.get_menu_name() then
      ui_tool.hide_menu()
    end
  end
  ui_team_watch.del_member(member_info.only_id)
end
function add_member(member_info)
  if ui.get_team_id() == sys.wstring(0) then
    return
  end
  local item_file = L("$frame/team/team.xml")
  local item_style = L("member")
  local index = get_member_index(member_info.index)
  if index == -1 then
    ui.log("member pos ERROR")
    return
  end
  local list_view = get_list_view(index)
  if list_view == nil then
    ui.log("group list_view ERROR")
    return
  end
  if list_view.item_count > 5 then
    ui.log("item_count ERROR")
    return
  end
  local i_index = get_item_index(member_info.index)
  if i_index == -1 then
    return
  end
  local item = list_view:item_get(i_index)
  local t = item:search("top_panel")
  t.visible = true
  local level = item:search("level")
  local param = sys.variant()
  param:set("level", member_info.level)
  level.text = sys.mtf_merge(param, ui.get_text("team|member_level"))
  local career = item:search("career")
  local career_idx = ui_portrait.get_career_idx(member_info.career)
  set_career_icon(career, career_idx)
  set_career_color(career, member_info.career)
  local name = item:search("name")
  name.text = member_info.name
  local captain = item:search("captain")
  if member_info.is_captain then
    captain.visible = true
  else
    captain.visible = false
  end
  item.var:set("only_id", member_info.only_id)
  item.var:set("member_pos", member_info.index)
  ui.log("add:" .. member_info.only_id)
  if member_info.only_id == bo2.player.only_id then
    local param = sys.variant()
    param:set("level", bo2.player:get_atb(bo2.eAtb_Level))
    level.text = sys.mtf_merge(param, ui.get_text("team|member_level"))
    career_idx = ui_portrait.get_career_idx(bo2.player:get_atb(bo2.eAtb_Cha_Profession))
    set_career_icon(career, career_idx)
    set_career_color(career, bo2.player:get_atb(bo2.eAtb_Cha_Profession))
    if member_info.status == 1 then
      name.xcolor = ui_team.c_status_online
    elseif member_info.status == 0 then
      name.xcolor = ui_team.c_status_offline
    elseif 0 >= bo2.player:get_atb(bo2.eAtb_HP) then
      name.xcolor = ui_team.c_status_dead
    end
    local btn_alloc = w_team_alloc:search("btn_drop_down")
    local btn_toos = w_toos_level:search("btn_drop_down")
    if ui.get_team_captain_id() == bo2.player.only_id then
      if member_info.status == 1 then
        name.xcolor = ui_team.c_status_slef
      end
      btn_toos.enable = true
      btn_alloc.enable = true
      w_invite_btn.enable = true
      w_inform_btn.enable = true
      if check_has_union() then
        w_leave_union_btn.enable = true
      end
      w_invite_union_btn.enable = true
      ui.log("aaaaaaaaaaa" .. member_info.name)
      captain.visible = true
    else
      w_leave_union_btn.enable = false
    end
    return
  end
  if member_info.status == 1 then
    name.xcolor = ui_team.c_status_online
    set_ctrl_onoffline(career, true)
    set_ctrl_onoffline(level, true)
  elseif member_info.status == 0 then
    name.xcolor = ui_team.c_status_offline
    set_ctrl_onoffline(career, false)
    set_ctrl_onoffline(level, false)
  elseif 0 >= bo2.player:get_atb(bo2.eAtb_HP) then
    name.xcolor = ui_team.c_status_dead
  end
  return
end
function set_check_false(id)
  local size = w_group_0.item_count
  for i = 0, size - 1 do
    local item = w_group_0:item_get(i)
    local only_id = item.var:get("only_id").v_string
    if only_id == id then
      local btn_check = item:search("btn_watch")
      btn_check.check = false
      return
    end
  end
  size = w_group_1.item_count
  for i = 0, size - 1 do
    local item = w_group_1:item_get(i)
    local only_id = item.var:get("only_id").v_string
    if only_id == id then
      local btn_check = item:search("btn_watch")
      btn_check.check = false
      return
    end
  end
  size = w_group_2.item_count
  for i = 0, size - 1 do
    local item = w_group_2:item_get(i)
    local only_id = item.var:get("only_id").v_string
    if only_id == id then
      local btn_check = item:search("btn_watch")
      btn_check.check = false
      return
    end
  end
  size = w_group_3.item_count
  for i = 0, size - 1 do
    local item = w_group_3:item_get(i)
    local only_id = item.var:get("only_id").v_string
    if only_id == id then
      local btn_check = item:search("btn_watch")
      btn_check.check = false
      return
    end
  end
end
function on_member_career_tip_make(tip)
  local parent = tip.owner.parent
  local name = parent:search("name").text
  local info = ui.member_get_by_name(name)
  local pro_list
  if info.only_id == bo2.player.only_id then
    pro_list = bo2.gv_profession_list:find(bo2.player:get_atb(bo2.eAtb_Cha_Profession))
  else
    pro_list = bo2.gv_profession_list:find(info.career)
  end
  local text
  if pro_list ~= nil then
    local damage = ui.get_text(sys.format("portrait|damage_type_%d", pro_list.damage))
    text = sys.format("%s(%s)", pro_list.name, damage)
    ui_widget.tip_make_view(tip.view, text)
  end
end
function on_member_ready_tip_make(tip)
  local parent = tip.owner.parent
  local text = ui.get_text("team|member_ready_tip")
  ui_widget.tip_make_view(tip.view, text)
end
function on_captain_tip_show(tip)
  local text = ui.get_text("portrait|captain")
  local stk = sys.stack()
  stk:push(text)
  local item = tip.owner.parent.parent.parent.parent
  local only_id = item.var:get("only_id").v_string
  if ui.get_team_captain_id() == only_id then
    ui_tool.ctip_show(tip.owner, stk)
  end
end
function on_captain_tip_make(tip)
  local text = ui.get_text("portrait|captain")
  ui_widget.tip_make_view(tip.view, text)
end
function on_drag_tip_show(tip)
  local text = ui.get_text("portrait|team_member_drag")
  local stk = sys.stack()
  stk:push(text)
  local item = tip.owner.parent
  local only_id = item.var:get("only_id").v_string
  if only_id == sys.wstring(0) or only_id == sys.wstring("") then
    return
  end
  if ui.get_team_captain_id() == bo2.player.only_id then
    ui_tool.ctip_show(tip.owner, stk)
  end
end
function on_team_watch_member(btn)
  local parent = btn.parent.parent
  if btn.check == true then
  else
  end
end
function on_watch_member(btn)
  local parent = btn.parent.parent.parent.parent.parent
  local only_id = parent.var:get("only_id").v_string
  local member_info = ui.member_find(only_id)
  if member_info == nil then
    return
  end
  if btn.check == true then
    if ui_team_watch.add_member(member_info) == false then
      btn.check = false
      return
    end
    ui_team_watch.set_visible(true)
  else
    ui_team_watch.del_member(only_id)
  end
end
function on_member_event(item)
  if item.callback then
    item.callback(item)
  end
end
function on_member_drop(panel, msg, pos, data)
  if ui.get_team_captain_id() ~= bo2.player.only_id then
    return
  end
  if msg == ui.mouse_enter then
    local select = panel:search("select")
    select.visible = true
  end
  if msg == ui.mouse_rbutton_down or msg == ui.mouse_rbutton_up then
    ui.clean_drop()
    local old_pos = data:get("mem_pos").v_int
    local list_view = get_list_view(math.floor(old_pos / 5))
    local item = list_view:item_get(old_pos % 5)
    local old_drag_fram = item:search("drag_frame")
    old_drag_fram.visible = false
    return
  end
  if msg == ui.mouse_leave then
    local select = panel:search("select")
    select.visible = false
  end
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  if msg == ui.mouse_lbutton_up or msg == ui.mouse_lbutton_down then
    local old_pos = data:get("mem_pos").v_int
    local new_pos = panel.parent.var:get("g_index").v_int
    bo2.send_AdjustPosition(old_pos, new_pos)
    ui.clean_drop()
    local select = panel:search("select")
    select.visible = false
    local list_view = get_list_view(math.floor(old_pos / 5))
    local item = list_view:item_get(old_pos % 5)
    local old_drag_fram = item:search("drag_frame")
    old_drag_fram.visible = false
    local drag_frame = panel:search("drag_frame")
    drag_frame.visible = false
  end
end
function on_member_mouse(panel, msg, pos, wheel)
  local item = panel.parent
  if msg == ui.mouse_enter then
    if ui.get_team_id() == sys.wstring(0) then
      return
    end
    local only_id = item.var:get("only_id").v_string
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local highlight = panel:search("highlight")
    highlight.visible = true
  end
  if msg == ui.mouse_leave then
    local highlight = panel:search("highlight")
    highlight.visible = false
  end
  if ui.get_team_captain_id() ~= bo2.player.only_id then
    return
  end
  if msg == ui.mouse_lbutton_drag then
    local data = sys.variant()
    data:set("mem_pos", item.var:get("g_index").v_int)
    local only_id = item.var:get("only_id").v_string
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local on_drop_hook = function(w, msg, pos, data)
    end
    ui_tool.w_view_floater_box.target = panel
    ui_tool.w_view_floater.size = panel.size
    ui_tool.w_view_floater.alpha = 0.6
    ui.setup_drop(ui_tool.w_view_floater, data, on_drop_hook)
    ui.reset_drop(panel:control_to_parent(panel, pos))
    local drag_frame = panel:search("drag_frame")
    drag_frame.visible = true
  end
  if msg == ui.mouse_rbutton_click then
    if ui.get_team_id() == sys.wstring(0) then
      return
    end
    local only_id = item.var:get("only_id").v_string
    ui.log(only_id)
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local m_pos = item.var:get("g_index").v_int
    local name = panel:search("name").text
    local tmp_items = {}
    if only_id == ui.get_team_captain_id() then
      tmp_items = {
        {
          text = ui.get_text("menu|del_team_member"),
          callback = send_del_member,
          id = bo2.ePortraitMenu_DelTeamMember
        },
        {
          text = ui.get_text("menu|change_member_pos"),
          callback = send_change_member_pos,
          id = bo2.ePortratiMenu_ChgMemberPos
        }
      }
    else
      tmp_items = {
        {
          text = ui.get_text("menu|set_team_captain"),
          callback = send_set_captain,
          id = bo2.ePortraitMenu_SetTeamCaptain
        },
        {
          text = ui.get_text("menu|del_team_member"),
          callback = send_del_member,
          id = bo2.ePortraitMenu_DelTeamMember
        },
        {
          text = ui.get_text("menu|change_member_pos"),
          callback = send_change_member_pos,
          id = bo2.ePortratiMenu_ChgMemberPos
        }
      }
    end
    local data = {
      items = tmp_items,
      event = on_member_event,
      info = {member_pos = m_pos, name = name},
      panel = panel,
      pos = pos,
      dx = 100,
      dy = 50,
      name = name,
      offset = panel.abs_area.p1 + pos
    }
    ui_tool.show_menu(data)
  end
end
function on_level_mouse(ctrl, msg, pos, wheel)
  local panel = ctrl.parent.parent
  local item = panel.parent
  if msg == ui.mouse_enter then
    if ui.get_team_id() == sys.wstring(0) then
      return
    end
    local only_id = item.var:get("only_id").v_string
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local highlight = panel:search("highlight")
    highlight.visible = true
  end
  if msg == ui.mouse_leave then
    local highlight = panel:search("highlight")
    highlight.visible = false
  end
  if ui.get_team_captain_id() ~= bo2.player.only_id then
    return
  end
  if msg == ui.mouse_lbutton_drag then
    local data = sys.variant()
    data:set("mem_pos", item.var:get("g_index").v_int)
    local only_id = item.var:get("only_id").v_string
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local on_drop_hook = function(w, msg, pos, data)
    end
    ui_tool.w_view_floater_box.target = panel
    ui_tool.w_view_floater.size = panel.size
    ui_tool.w_view_floater.alpha = 0.6
    ui.setup_drop(ui_tool.w_view_floater, data, on_drop_hook)
    ui.reset_drop(panel:control_to_parent(panel, pos))
    local drag_frame = panel:search("drag_frame")
    drag_frame.visible = true
  end
  if msg == ui.mouse_rbutton_click then
    if ui.get_team_id() == sys.wstring(0) then
      return
    end
    local only_id = item.var:get("only_id").v_string
    ui.log(only_id)
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local m_pos = item.var:get("g_index").v_int
    local name = panel:search("name").text
    local data = {
      items = {
        {
          text = ui.get_text("menu|set_team_captain"),
          callback = send_set_captain,
          id = bo2.ePortraitMenu_SetTeamCaptain
        },
        {
          text = ui.get_text("menu|del_team_member"),
          callback = send_del_member,
          id = bo2.ePortraitMenu_DelTeamMember
        },
        {
          text = ui.get_text("menu|change_member_pos"),
          callback = send_change_member_pos,
          id = bo2.ePortratiMenu_ChgMemberPos
        }
      },
      event = on_member_event,
      info = {member_pos = m_pos, name = name},
      panel = panel,
      pos = pos,
      dx = 100,
      dy = 50,
      name = name,
      offset = ctrl.abs_area.p1 + pos
    }
    ui_tool.show_menu(data)
  end
end
function on_captain_mouse(ctrl, msg, pos, wheel)
  local panel = ctrl.parent.parent.parent
  local item = panel.parent
  if msg == ui.mouse_enter then
    if ui.get_team_id() == sys.wstring(0) then
      return
    end
    local only_id = item.var:get("only_id").v_string
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local highlight = panel:search("highlight")
    highlight.visible = true
  end
  if msg == ui.mouse_leave then
    local highlight = panel:search("highlight")
    highlight.visible = false
  end
  if ui.get_team_captain_id() ~= bo2.player.only_id then
    return
  end
  if msg == ui.mouse_lbutton_drag then
    local data = sys.variant()
    data:set("mem_pos", item.var:get("g_index").v_int)
    local only_id = item.var:get("only_id").v_string
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local on_drop_hook = function(w, msg, pos, data)
    end
    ui_tool.w_view_floater_box.target = panel
    ui_tool.w_view_floater.size = panel.size
    ui_tool.w_view_floater.alpha = 0.6
    ui.setup_drop(ui_tool.w_view_floater, data, on_drop_hook)
    ui.reset_drop(panel:control_to_parent(panel, pos))
    local drag_frame = panel:search("drag_frame")
    drag_frame.visible = true
  end
  if msg == ui.mouse_rbutton_click then
    if ui.get_team_id() == sys.wstring(0) then
      return
    end
    local only_id = item.var:get("only_id").v_string
    ui.log(only_id)
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local m_pos = item.var:get("g_index").v_int
    local name = panel:search("name").text
    local data = {
      items = {
        {
          text = ui.get_text("menu|set_team_captain"),
          callback = send_set_captain,
          id = bo2.ePortraitMenu_SetTeamCaptain
        },
        {
          text = ui.get_text("menu|del_team_member"),
          callback = send_del_member,
          id = bo2.ePortraitMenu_DelTeamMember
        },
        {
          text = ui.get_text("menu|change_member_pos"),
          callback = send_change_member_pos,
          id = bo2.ePortratiMenu_ChgMemberPos
        }
      },
      event = on_member_event,
      info = {member_pos = m_pos, name = name},
      panel = panel,
      pos = pos,
      dx = 100,
      dy = 50,
      name = name,
      offset = ctrl.abs_area.p1 + pos
    }
    ui_tool.show_menu(data)
  end
end
function on_career_mouse(ctrl, msg, pos, wheel)
  local panel = ctrl.parent.parent.parent
  local item = panel.parent
  if msg == ui.mouse_enter then
    if ui.get_team_id() == sys.wstring(0) then
      return
    end
    local only_id = item.var:get("only_id").v_string
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local highlight = panel:search("highlight")
    highlight.visible = true
  end
  if msg == ui.mouse_leave then
    local highlight = panel:search("highlight")
    highlight.visible = false
  end
  if ui.get_team_captain_id() ~= bo2.player.only_id then
    return
  end
  if msg == ui.mouse_lbutton_drag then
    local data = sys.variant()
    data:set("mem_pos", item.var:get("g_index").v_int)
    local only_id = item.var:get("only_id").v_string
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local on_drop_hook = function(w, msg, pos, data)
    end
    ui_tool.w_view_floater_box.target = panel
    ui_tool.w_view_floater.size = panel.size
    ui_tool.w_view_floater.alpha = 0.6
    ui.setup_drop(ui_tool.w_view_floater, data, on_drop_hook)
    ui.reset_drop(panel:control_to_parent(panel, pos))
    local drag_frame = panel:search("drag_frame")
    drag_frame.visible = true
  end
  if msg == ui.mouse_rbutton_click then
    if ui.get_team_id() == sys.wstring(0) then
      return
    end
    local only_id = item.var:get("only_id").v_string
    ui.log(only_id)
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local m_pos = item.var:get("g_index").v_int
    local name = panel:search("name").text
    local data = {
      items = {
        {
          text = ui.get_text("menu|set_team_captain"),
          callback = send_set_captain,
          id = bo2.ePortraitMenu_SetTeamCaptain
        },
        {
          text = ui.get_text("menu|del_team_member"),
          callback = send_del_member,
          id = bo2.ePortraitMenu_DelTeamMember
        },
        {
          text = ui.get_text("menu|change_member_pos"),
          callback = send_change_member_pos,
          id = bo2.ePortratiMenu_ChgMemberPos
        }
      },
      event = on_member_event,
      info = {member_pos = m_pos, name = name},
      panel = panel,
      pos = pos,
      dx = 100,
      dy = 50,
      name = name,
      offset = ctrl.abs_area.p1 + pos
    }
    ui_tool.show_menu(data)
  end
end
function on_ready_mouse(ctrl, msg, pos, wheel)
  local panel = ctrl.parent.parent.parent.parent
  local item = panel.parent
  if msg == ui.mouse_enter then
    if ui.get_team_id() == sys.wstring(0) then
      return
    end
    local only_id = item.var:get("only_id").v_string
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local highlight = panel:search("highlight")
    highlight.visible = true
  end
  if msg == ui.mouse_leave then
    local highlight = panel:search("highlight")
    highlight.visible = false
  end
  if ui.get_team_captain_id() ~= bo2.player.only_id then
    return
  end
  if msg == ui.mouse_lbutton_drag then
    local data = sys.variant()
    data:set("mem_pos", item.var:get("g_index").v_int)
    local only_id = item.var:get("only_id").v_string
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local on_drop_hook = function(w, msg, pos, data)
    end
    ui_tool.w_view_floater_box.target = panel
    ui_tool.w_view_floater.size = panel.size
    ui_tool.w_view_floater.alpha = 0.6
    ui.setup_drop(ui_tool.w_view_floater, data, on_drop_hook)
    ui.reset_drop(panel:control_to_parent(panel, pos))
    local drag_frame = panel:search("drag_frame")
    drag_frame.visible = true
  end
  if msg == ui.mouse_rbutton_click then
    if ui.get_team_id() == sys.wstring(0) then
      return
    end
    local only_id = item.var:get("only_id").v_string
    ui.log(only_id)
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local m_pos = item.var:get("g_index").v_int
    local name = panel:search("name").text
    local data = {
      items = {
        {
          text = ui.get_text("menu|set_team_captain"),
          callback = send_set_captain,
          id = bo2.ePortraitMenu_SetTeamCaptain
        },
        {
          text = ui.get_text("menu|del_team_member"),
          callback = send_del_member,
          id = bo2.ePortraitMenu_DelTeamMember
        },
        {
          text = ui.get_text("menu|change_member_pos"),
          callback = send_change_member_pos,
          id = bo2.ePortratiMenu_ChgMemberPos
        }
      },
      event = on_member_event,
      info = {member_pos = m_pos, name = name},
      panel = panel,
      pos = pos,
      dx = 100,
      dy = 50,
      name = name,
      offset = ctrl.abs_area.p1 + pos
    }
    ui_tool.show_menu(data)
  end
end
g_member_pos = 0
function on_invite_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    ui_group.send_invite_cha(msg.input)
  end
end
function on_invite_click(btn)
  local member_info = {
    only_id = 123321321,
    level = 10,
    is_captain = true,
    name = "test",
    index = g_member_pos
  }
  local msg = {
    callback = on_invite_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui.get_text("team|invite_player_name")
  msg.input = ""
  ui_widget.ui_msg_box.show_common(msg)
end
function on_watch_click(btn)
  if ui_team_watch.is_visible() then
    ui_team_watch.set_visible(false)
  else
    ui_team_watch.set_visible(true)
  end
end
function on_ready_msg(msg)
  if msg == nil then
    return
  end
  local data = sys.variant()
  if msg.result == 1 then
    data:set(packet.key.group_readygo, 1)
  else
    data:set(packet.key.group_readygo, 0)
  end
  bo2.send_variant(packet.eCTS_Group_ReadyGo, data)
end
function popo_group_ready(def, data, duration_time)
  local text = data:get(packet.key.group_ready_text).v_string
  ui.log("ready text :%s", text)
  local msg = {
    callback = on_ready_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    title = ui.get_text("team|team_inform_title")
  }
  msg.text = text
  msg.timeout = duration_time
  ui_widget.ui_msg_box.show_common(msg)
end
function group_send_ready(msg)
  local data = sys.variant()
  data:set(packet.key.group_ready_text, msg.input)
  bo2.send_variant(packet.eCTS_Group_Ready, data)
end
function on_inform_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    if msg.input == sys.wstring("") then
      ui_tool.note_insert(ui.get_text("team|inform_text_null"), ui_team.warining_color)
      return
    end
    group_send_ready(msg)
  end
end
function on_inform_click(btn)
  if ui.get_team_captain_id() ~= bo2.player.only_id then
    ui_tool.note_insert(ui.get_text("team|inform_not_captain"), ui_team.warining_color)
    return
  end
  local msg = {
    callback = on_inform_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    title = ui.get_text("team|team_inform_title"),
    limit = 300
  }
  msg.input = ui.get_text("team|inform_default_content")
  msg.text = ""
  ui_widget.ui_msg_box.show_common(msg)
end
function on_qt_state(tip)
  local parent = tip.owner.parent
  local name = parent:search("name").text
  local info = ui.member_get_by_name(name)
  if info.status == 0 then
    return
  end
  if name ~= bo2.player.name then
    local state = info.qt_state
    local text = L("")
    if state == 0 then
      text = ui.get_text("qt|team_chat_enable")
    elseif state == 1 then
      text = ui.get_text("qt|team_chat_disable")
    elseif state == 2 then
      text = ui.get_text("qt|team_chat_disable_now")
    elseif state == 4 then
      text = ui.get_text("qt|team_not_in")
    else
      text = ui.get_text("qt|team_not_in")
    end
    if 0 == bo2.qt_is_loaded() then
      text = ui.get_text("qt|team_no_voice")
    end
    if 0 == info.status then
      text = ui.get_text("qt|team_not_online")
    end
    local room_id = bo2.qt_cur_room_id()
    if room_id ~= -1 then
      text = ui.get_text("qt|team_self_not_in")
    end
    local stk = sys.stack()
    stk:push(text)
    ui_tool.ctip_show(tip.owner, stk)
  end
end
function on_qt_get_together(btn)
  if ui.get_team_captain_id() ~= bo2.player.only_id then
    ui_tool.note_insert(ui.get_text("team|inform_not_captain"), ui_team.warining_color)
    return
  end
  if bo2.qt_cur_room_id() ~= -1 then
    ui_tool.note_insert(ui.get_text("team|inform_not_in_team_room"), ui_team.warining_color)
    return
  end
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_Team_QTGetTogether, v)
end
function on_qt_icon_mouse(panel, msg, pos, wheel)
  local panel = panel.parent.parent.parent
  local item = panel.parent
  if msg == ui.mouse_enter or msg == ui.mouse_inner then
    if ui.get_team_id() == sys.wstring(0) then
      return
    end
    local only_id = item.var:get("only_id").v_string
    if only_id == sys.wstring(0) or only_id == sys.wstring("") then
      return
    end
    local highlight = panel:search("highlight")
    highlight.visible = true
  end
  if msg == ui.mouse_leave or msg == ui.mouse_outer then
    local highlight = panel:search("highlight")
    highlight.visible = false
  end
  if msg == ui.mouse_lbutton_down then
    local parent = panel.parent
    local name = parent:search("name").text
    if name == bo2.player.name then
      return
    end
    local info = ui.member_get_by_name(name)
    if info == nil then
      return
    end
    local state = info.qt_state
    local text = L("")
    if state == 0 then
      bo2.qt_cancel_mask(0, info.name)
    elseif state == 1 then
      bo2.qt_mask(0, info.name)
    elseif state == 2 then
      bo2.qt_mask(0, info.name)
    elseif state == 4 then
    end
  else
  end
end
ui.insert_on_member_insert(on_member_insert, "ui_team:on_member_insert")
ui.insert_on_member_remove(on_member_remove, "ui_team:on_member_remove")
