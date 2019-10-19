local ui_tab = ui_widget.ui_tab
local ui_text_list = ui_widget.ui_text_list
c_warning_color = L("FFFF0000")
function on_convene_init()
end
function on_tab_click(btn)
end
function on_key_desc(box, key, flag)
  if key == ui.VK_TAB then
  end
end
function on_key_num(box, key, flag)
  if key == ui.VK_TAB then
  end
end
function update_select()
  local size = w_main_list.item_count
  if size == 0 then
    return
  end
  for i = 0, size - 1 do
    local item = w_main_list:item_get(i)
    local select = item:search("highlight_select")
    select.visible = false
  end
end
function update_hover()
  local size = w_main_list.item_count
  if size == 0 then
    return
  end
  for i = 0, size - 1 do
    local item = w_main_list:item_get(i)
    local hover = item:search("highlight_hover")
    hover.visible = false
  end
end
function clear_all(data)
  w_main_list:item_clear()
  local type = data:get(packet.key.convene_type).v_int
  local scn_id = data:get(packet.key.convene_scn_id).v_int
  if type == 0 then
    return
  end
  ui_widget.ui_combo_box.select(w_check_type_list, type)
  w_check_type_list_desc.visible = false
  if scn_id == 0 then
    return
  end
  w_check_dungeon_name.svar.btn.enable = true
  w_check_dungeon_name_desc.visible = false
  ui_widget.ui_combo_box.clear(w_check_dungeon_name)
  local typetable = ui_dungeonui.ui_dungeonsel.get_type_table(type)
  if typetable == nil then
    return
  end
  local sel_id
  for i, v in pairs(typetable) do
    local scnid = v.id
    if scnid == scn_id then
      sel_id = i
    end
    local scnlist_tb = bo2.gv_scn_list:find(scnid)
    local scnname = scnlist_tb.name
    ui_widget.ui_combo_box.append(w_check_dungeon_name, {id = i, text = scnname})
  end
  ui_widget.ui_combo_box.select(w_check_dungeon_name, sel_id)
end
function on_menu_event(item)
  if item.callback then
    item:callback()
  end
end
function on_item_mouse(panel, msg, pos, wheel)
  if panel.parent.svar.is_member == true then
    return
  end
  if msg == ui.mouse_lbutton_down then
    ui_widget.on_tree_node_toggle_click(panel)
    local item = panel.parent.item
    item.selected = not item.selected
    local item = item:item_get(0)
    if item == nil then
      return
    end
    item:scroll_to_visible()
    return
  end
end
function get_select_item()
  local size = w_main_list.item_count
  for i = 0, size - 1 do
    local item = w_main_list:item_get(i)
    if item.selected == true then
      return item
    end
  end
  return nil
end
function on_release_click(btn)
  local name_item = ui_widget.ui_combo_box.selected(w_dungeon_name)
  local type_item = ui_widget.ui_combo_box.selected(w_type_list)
  if w_recruit_edit_desc == nil or type_item == nil then
    ui_tool.note_insert(ui.get_text("convene|info_error"), c_warning_color)
    return
  end
  local type_flag = type_item.id
  if name_item == nil and type_flag ~= bo2.eConveneType_Misc then
    ui_tool.note_insert(ui.get_text("convene|info_error"), c_warning_color)
    return
  end
  local group_id = bo2.get_group_id()
  local captain_id = bo2.get_captain_id()
  if group_id ~= L("0") and captain_id ~= bo2.player.only_id then
    ui_tool.note_insert(ui.get_text("convene|group_null"), c_warning_color)
    return
  end
  local desc = w_recruit_edit_desc.text
  if desc == L("") then
    ui_tool.note_insert(ui.get_text("convene|desc_warning"), c_warning_color)
    return
  end
  if type_flag ~= bo2.eConveneType_Misc then
    local name_flag = name_item.id
    local typetable = ui_dungeonui.ui_dungeonsel.get_type_table(type_flag)
    if typetable == nil then
      return
    end
    local scnid = typetable[name_flag].id
    ui_dungeonui.ui_dungeonsel.init_all_need()
    ui_dungeonui.ui_dungeonsel.insert_page_items(type_flag)
    local scn_tb = ui_dungeonui.ui_dungeonsel.get_table_by_scnid(type_flag, scnid)
    local data_table = scn_tb.data_table
    local state = ui_dungeonui.ui_dungeonsel.check_other_state(data_table)
    local state_level = ui_dungeonui.ui_dungeonsel.check_other_state_levels(data_table)
    if state == false or state_level == false then
      ui_tool.note_insert(ui.get_text("convene|tele_unreach_recruit"), L("FFFF0000"))
      local data = sys.variant()
      data:set(packet.key.group_id, group_id)
      data:set(packet.key.convene_tele_disable, 1)
      return
    elseif ui_convene.check_cd(type_flag, scn_tb) == false then
      ui_tool.note_insert(ui.get_text("convene|tele_cd_out_recruit"), L("FFFF0000"))
      local data = sys.variant()
      data:set(packet.key.group_id, group_id)
      data:set(packet.key.convene_tele_cd_out, 1)
      return
    end
    local wuguan_id = scn_tb.line.hilevel_index
    ui_convene.send_convene_release(type_flag, desc, group_id, scnid, wuguan_id)
  else
    ui_convene.send_convene_release(type_flag, desc, group_id, 0, 0)
  end
  ui_widget.ui_msg_box.on_confirm_click(btn)
end
function send_join_team(captain)
  if ui_group.may_invite(captain) == false then
    ui_chat.show_ui_text_id(1000)
    return
  end
  local v = sys.variant()
  v:set(packet.key.cha_name, captain)
  bo2.send_variant(packet.eCTS_Convene_JoinTeam, v)
end
function on_jion_click(btn)
  local item = get_select_item()
  if item == nil then
    ui_tool.note_insert(ui.get_text("convene|no_select_item"), c_warning_color)
    return
  end
  if bo2.get_captain_id() ~= sys.wstring(0) then
    ui_tool.note_insert(ui.get_text("convene|already_group_warning"), c_warning_color)
    return
  end
  local captain = item:search("captain").text
  ui_convene.send_join_team(captain)
end
function on_personal_chat_click(btn)
  local item = get_select_item()
  if item == nil then
    ui_tool.note_insert(ui.get_text("convene|no_select_item_chat"), c_warning_color)
    return
  end
  local captain = item:search("captain").text
  ui_chat.set_channel(bo2.eChatChannel_PersonalChat, captain)
end
function on_watch_click(btn)
  local item = get_select_item()
  if item == nil then
    ui_tool.note_insert(ui.get_text("convene|no_select_item"), c_warning_color)
    return
  end
  local i_group_id = item.var:get("group_id").v_string
  ui_convene.ui_info.clear_all()
  send_convene_group_detail(i_group_id)
end
function on_flush_click(btn)
  local type_id = 0
  local scn_id = 0
  if w_check_type_list.svar.selected ~= nil then
    type_id = w_check_type_list.svar.selected.id
    local typetable = ui_dungeonui.ui_dungeonsel.get_type_table(type_id)
    if w_check_dungeon_name.svar.selected ~= nil then
      local name_id = w_check_dungeon_name.svar.selected.id
      scn_id = typetable[name_id].id
    end
  end
  send_convene_refresh(type_id, scn_id)
end
function on_cancel_click(btn)
  local group_id = bo2.get_group_id()
  local captain_id = bo2.get_captain_id()
  if group_id == L("0") or captain_id ~= bo2.player.only_id then
    ui_tool.note_insert(ui.get_text("convene|group_null_cancel"), c_warning_color)
    return
  end
  send_convene_cancel(group_id)
end
function insert(data)
  local camp_id = data:get(packet.key.camp_id).v_int
  local my_camp_id = bo2.player:get_atb(bo2.eAtb_Camp)
  if camp_id ~= my_camp_id then
    return
  end
  local type = data:get(packet.key.convene_type).v_int
  local desc = data:get(packet.key.convene_desc).v_string
  local group_id = data:get(packet.key.group_id).v_string
  local captain_name = data:get(packet.key.cha_name).v_string
  local cha_level = data:get(packet.key.cha_level).v_int
  local group_cur_num = data:get(packet.key.group_cur_member_count).v_int
  local convene_num = data:get(packet.key.convene_num).v_int
  local career_id = data:get(packet.key.player_career).v_int
  local fight_score = data:get(packet.key.gs_score).v_int
  local group_members = data:get(packet.key.group_all_members)
  local scn_id = data:get(packet.key.convene_scn_id).v_int
  if w_check_type_list.svar.selected ~= nil and w_check_type_list.svar.selected.id ~= type then
    return
  end
  if w_check_dungeon_name.svar.selected ~= nil then
    local name_flag = w_check_dungeon_name.svar.selected.id
    local typetable = ui_dungeonui.ui_dungeonsel.get_type_table(w_check_type_list.svar.selected.id)
    local ui_scnid = typetable[name_flag].id
    if typetable == nil then
      return
    end
    if ui_scnid ~= scn_id then
      return
    end
  end
  local size = w_main_list.item_count
  for i = 0, size - 1 do
    local item = w_main_list:item_get(i)
    local list_group_id = item.var:get("group_id").v_string
    if list_group_id == group_id then
      w_main_list:item_remove(i)
      break
    end
  end
  local scnname = ""
  if type ~= bo2.eConveneType_Misc then
    local scnlist_tb = bo2.gv_scn_list:find(scn_id)
    scnname = scnlist_tb.name
  end
  local career = ""
  local pro_list = bo2.gv_profession_list:find(career_id)
  if pro_list ~= nil then
    career = pro_list.name
  end
  local item_uri = "$frame/convene/cmn.xml"
  local item_sty = "item"
  local my_group_id = bo2.get_group_id()
  local item
  item = w_main_list:item_insert(0)
  local title = item.obtain_title
  if item == nil then
    return
  end
  title:load_style(item_uri, item_sty)
  local i_desc = title:search("desc")
  i_desc.text = desc
  local i_dungeon_name = title:search("dungeon_name")
  if type ~= bo2.eConveneType_Misc then
    i_dungeon_name.text = "[" .. scnname .. "]"
  else
    i_dungeon_name.text = "[" .. ui.get_text("convene|convene_type_5") .. "]"
  end
  local i_captain = title:search("captain")
  i_captain.text = captain_name
  local i_captain_level = title:search("captain_level")
  i_captain_level.text = cha_level
  local i_group_num = title:search("group_num")
  i_group_num.text = sys.format("%d/%d", group_cur_num, convene_num)
  local i_career = title:search("captain_career")
  i_career.text = career
  local i_score = title:search("fight_score")
  i_score.text = fight_score
  local i_self_team = title:search("self_team")
  if my_group_id == group_id then
    i_self_team.visible = true
  else
    i_self_team.visible = false
  end
  item.var:set("group_id", group_id)
  item.var:set("group_members", group_members)
end
function delete(type, id)
  if w_main_list == nil or id == 0 then
    return
  end
  local size = w_main_list.item_count
  for i = 0, size - 1 do
    local item = w_main_list:item_get(i)
    local group_id = item.var:get("group_id").v_string
    if group_id == id then
      w_main_list:item_remove(i)
      return
    end
  end
end
function on_desc_change(tb, text)
  w_show_desc.visible = tb.mtf.empty
end
function on_num_change(tb, text)
  w_show_num.visible = text.empty
end
function on_convene_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  ui_handson_teach.test_complate_convene()
  if vis == true then
    ui_dungeonui.ui_dungeonsel.init_all_need()
    ui_widget.ui_combo_box.clear(w_check_type_list)
    for i = bo2.eConveneType_Start, bo2.eConveneType_End do
      local category_text = ui.get_text("convene|convene_type_" .. i)
      local typetable = ui_dungeonui.ui_dungeonsel.get_type_table(i)
      if typetable ~= nil or i == bo2.eConveneType_Misc then
        ui_widget.ui_combo_box.append(w_check_type_list, {id = i, text = category_text})
      end
    end
    ui_widget.ui_combo_box.select(w_check_type_list, nil)
    ui_widget.ui_combo_box.select(w_check_dungeon_name, nil)
    w_check_dungeon_name.svar.btn.enable = false
    w_check_type_list_desc.visible = true
    w_check_dungeon_name_desc.visible = true
    send_convene_refresh(0, 0)
    local obj = bo2.player
    if sys.check(obj) == true then
      local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_ConveneShowup)
      if flag_value == 16 then
        ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_ConveneRecruit, ui_handson_teach.cQuestTeachType_Add)
      end
    end
  end
end
function on_convene_cmobo_box_click(btn)
  local cb = btn.parent
  local items = {}
  local svar = cb.svar
  local t = svar.list
  for i, v in ipairs(t) do
    local item = {
      id = v.id,
      color = v.color,
      text = v.text,
      style_uri = v.style_uri,
      style = v.style,
      data = v
    }
    table.insert(items, item)
  end
  local function on_event_list_select(item)
    ui_widget.ui_combo_box.select(cb, item.id)
    local event = svar.on_select
    if event == nil then
      return
    end
    event(item)
  end
  local size = #t
  local vs
  if size > 7 then
    size = 7
    vs = true
  end
  local dx = cb.dx
  if vs then
    dx = dx - 20
  end
  local dy = size * 28 + 20
  ui.log("vs %s", vs)
  ui_tool.show_menu({
    items = items,
    event = on_event_list_select,
    source = btn,
    popup = "y",
    dx = dx,
    dy = dy,
    vs = vs,
    bg_uri = L("$frame/convene/cmn.xml"),
    bg_style = L("convene_menu_window")
  })
end
function insert_check_dungeon_names(dungeon_type)
  ui_widget.ui_combo_box.clear(w_check_dungeon_name)
  local typetable = ui_dungeonui.ui_dungeonsel.get_type_table(dungeon_type)
  if typetable == nil then
    return false
  end
  for i, v in pairs(typetable) do
    local scnid = v.id
    local scnlist_tb = bo2.gv_scn_list:find(scnid)
    local scnname = scnlist_tb.name
    local scnalloc_tb = bo2.gv_scn_alloc:find(scnid)
    local scn_num = scnalloc_tb.player
    if scn_num > 1 then
      ui_widget.ui_combo_box.append(w_check_dungeon_name, {id = i, text = scnname})
    end
  end
  return true
end
function on_combo_check_type_click(ctrl)
  local on_select = function(item)
    w_check_type_list_desc.visible = false
    w_check_dungeon_name_desc.visible = true
    if insert_check_dungeon_names(item.id) then
      w_check_dungeon_name.svar.btn.enable = true
    else
      w_check_dungeon_name.svar.btn.enable = false
    end
    local type_id = w_check_type_list.svar.selected.id
    send_convene_refresh(type_id, 0)
  end
  w_check_type_list.svar.on_select = on_select
  on_convene_cmobo_box_click(ctrl)
end
function on_combo_check_name_click(ctrl)
  local on_select = function(item)
    w_check_dungeon_name_desc.visible = false
    local type_id = w_check_type_list.svar.selected.id
    local typetable = ui_dungeonui.ui_dungeonsel.get_type_table(type_id)
    local scn_id = typetable[item.id].id
    send_convene_refresh(type_id, scn_id)
  end
  w_check_dungeon_name.svar.on_select = on_select
  on_convene_cmobo_box_click(ctrl)
end
function insert_dungeon_names(dungeon_type)
  ui_widget.ui_combo_box.clear(w_dungeon_name)
  local typetable = ui_dungeonui.ui_dungeonsel.get_type_table(dungeon_type)
  if typetable == nil then
    return false
  end
  for i, v in pairs(typetable) do
    local scnid = v.id
    local scnlist_tb = bo2.gv_scn_list:find(scnid)
    local scnname = scnlist_tb.name
    local scnalloc_tb = bo2.gv_scn_alloc:find(scnid)
    local scn_num = scnalloc_tb.player
    if scn_num > 1 then
      ui_widget.ui_combo_box.append(w_dungeon_name, {id = i, text = scnname})
    end
  end
  return true
end
function on_recruit_edit_init()
  for i = bo2.eConveneType_Start, bo2.eConveneType_End do
    local category_text = ui.get_text("convene|convene_type_" .. i)
    local typetable = ui_dungeonui.ui_dungeonsel.get_type_table(i)
    if typetable ~= nil or i == bo2.eConveneType_Misc then
      ui_widget.ui_combo_box.append(w_type_list, {id = i, text = category_text})
    end
  end
end
function on_combo_edit_type_click(ctrl)
  local on_select = function(item)
    w_type_list_desc.visible = false
    w_dungeon_name_desc.visible = true
    if insert_dungeon_names(item.id) then
      w_dungeon_name.svar.btn.enable = true
    else
      w_dungeon_name.svar.btn.enable = false
    end
  end
  w_type_list.svar.on_select = on_select
  on_convene_cmobo_box_click(ctrl)
end
function on_combo_edit_name_click(ctrl)
  local on_select = function(item)
    w_dungeon_name_desc.visible = false
  end
  w_dungeon_name.svar.on_select = on_select
  on_convene_cmobo_box_click(ctrl)
end
function on_recruit_edit_vis(ctrl, vis)
  if vis then
    ui_widget.ui_combo_box.select(w_type_list, nil)
    ui_widget.ui_combo_box.select(w_dungeon_name, nil)
    w_dungeon_name.svar.btn.enable = false
    w_type_list_desc.visible = true
    w_dungeon_name_desc.visible = true
    w_recruit_edit_desc.mtf = L("")
    w_show_desc.visible = true
    ui_handson_teach.test_complete_convene_recruit()
  end
end
function on_btn_show_recruit_edit_click(ctrl)
  local on_msg = function(msg)
  end
  local msg = {
    callback = on_msg,
    modal = true,
    init = ui_convene.on_recruit_edit_init,
    style_uri = "$frame/convene/recruit_edit.xml",
    style_name = "recruit_edit"
  }
  ui_widget.ui_msg_box.show(msg)
end
function on_btn_show_invite_player_click(ctrl)
  if ui_convene.w_invite_view_main.visible == false then
    local group_id = bo2.get_group_id()
    local captain_id = bo2.get_captain_id()
    if group_id == L("0") and captain_id ~= bo2.player.only_id then
      ui_tool.note_insert(ui.get_text("convene|invite_not_captain"), c_warning_color)
      return
    end
    if w_invite_view_main.svar.type == nil or w_invite_view_main.svar.scn_id == nil then
      ui_tool.note_insert(ui.get_text("convene|invite_not_convene"), c_warning_color)
      return
    end
    ui_convene.w_invite_view_main.visible = true
  else
    ui_convene.w_invite_view_main.visible = false
  end
end
function show_teleport_button(type, scn_id)
  if type == bo2.eConveneType_Misc then
    return
  end
  w_teleport_proposal.visible = true
  w_invite_view_main.svar.type = type
  w_invite_view_main.svar.scn_id = scn_id
end
function insert_team_item(ctrl, svar)
  local child_item = ctrl:item_append()
  local title = child_item.obtain_title
  local item_uri = "$frame/convene/cmn.xml"
  local expand_sty = "expanded_tree_item"
  local item_sty = "item"
  title:load_style(item_uri, expand_sty)
  local team_list = title:search("expanded_item")
  local group_id = ctrl.var:get("group_id")
  local members = ctrl.var:get("group_members")
  title.dy = members.size * 26
  for i = 0, members.size - 1 do
    local member = members:fetch_v(i)
    local name = member:get(packet.key.cha_name).v_string
    local cha_level = member:get(packet.key.cha_level).v_int
    local career_id = member:get(packet.key.player_career).v_int
    local fight_score = member:get(packet.key.gs_score).v_int
    local career = ""
    local pro_list = bo2.gv_profession_list:find(career_id)
    if pro_list ~= nil then
      career = pro_list.name
    end
    local item = team_list:item_append()
    if item == nil then
      return
    end
    item:load_style(item_uri, item_sty)
    item:search("highlight_normal").visible = false
    item:search("highlight_select").visible = true
    local i_captain = item:search("captain")
    i_captain.text = name
    local i_captain_level = item:search("captain_level")
    i_captain_level.text = cha_level
    local i_career = item:search("captain_career")
    i_career.text = career
    local i_score = item:search("fight_score")
    i_score.text = fight_score
    item.svar.is_member = true
  end
end
function on_item_sel(ctrl, v)
  if v == true then
    ctrl.expanded = true
    ctrl:search("highlight_normal").visible = false
    ctrl:search("highlight_select").visible = true
  else
    ctrl.expanded = false
    ctrl:search("highlight_normal").visible = true
    ctrl:search("highlight_select").visible = false
  end
end
function on_item_expanded(ctrl, v)
  if v == true then
    local svar = ctrl.obtain_title.svar
    if svar.child_init == nil then
      svar.child_init = true
      insert_team_item(ctrl, svar)
    end
  end
end
local g_sort_asc = false
function sort_list(list, field, is_num, asc)
  local item_cnt = list.item_count
  if item_cnt == 0 then
    return
  end
  if is_num == nil then
    is_num = false
  end
  if asc == nil then
    asc = true
  end
  local function my_sort(item1, item2)
    local var1, var2
    var1 = item1:search(field).text
    var2 = item2:search(field).text
    if is_num then
      var1 = var1.v_int
      var2 = var2.v_int
    end
    local coe = -1
    if asc then
      coe = 1
    end
    if var1 > var2 then
      return 1 * coe
    elseif var1 == var2 then
      return 0 * coe
    else
      return -1 * coe
    end
  end
  list:item_sort(my_sort)
end
function on_btn_title_level_click(btn)
  g_sort_asc = not g_sort_asc
  sort_list(w_main_list, "captain_level", true, g_sort_asc)
end
function on_btn_title_name_click(btn)
  g_sort_asc = not g_sort_asc
  sort_list(w_main_list, "captain", false, g_sort_asc)
end
function on_btn_title_members_click(btn)
  g_sort_asc = not g_sort_asc
  sort_list(w_main_list, "group_num", false, g_sort_asc)
end
function on_btn_title_career_click(btn)
  g_sort_asc = not g_sort_asc
  sort_list(w_main_list, "captain_career", false, g_sort_asc)
end
function on_btn_title_score_click(btn)
  g_sort_asc = not g_sort_asc
  sort_list(w_main_list, "fight_score", true, g_sort_asc)
end
function on_item_desc_mouse(w, msg, pos, wheel)
  if w.parent.parent.svar.is_member == true then
    w.tip.visible = false
    return
  end
  if msg == ui.mouse_enter or msg == ui.mouse_inner then
    local stk = sys.mtf_stack()
    tip_text = w:search("desc").text
    ui_tool.ctip_push_text(stk, tip_text, ui_tool.cs_tip_color_white)
    ui_tool.ctip_show(w, stk)
  elseif msg == ui.mouse_leave or msg == ui.mouse_outer then
    ui_tool.ctip_show(w, nil)
  else
    on_item_mouse(w.parent, msg, pos, wheel)
  end
end
function on_item_name_mouse(w, msg, pos, wheel)
  if msg == ui.mouse_enter or msg == ui.mouse_inner then
    local stk = sys.mtf_stack()
    tip_text = w:search("captain").text
    ui_tool.ctip_push_text(stk, tip_text, ui_tool.cs_tip_color_white)
    ui_tool.ctip_show(w, stk)
  elseif msg == ui.mouse_leave or msg == ui.mouse_outer then
    ui_tool.ctip_show(w, nil)
  else
    on_item_mouse(w.parent, msg, pos, wheel)
  end
end
