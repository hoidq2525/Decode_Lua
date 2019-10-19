local reg = ui_packet.game_recv_signal_insert
local sig = "ui_guild_mod.packet_handle"
local disable_qt = bo2.gv_define:find(1106).value.v_int
union_list = {}
enemy_list = {}
g_union_cd_begin = 0
local page_visile = {}
function on_build_guild(ctrl)
  local on_build_guild_msg = function(msg)
    if msg == nil then
      return
    end
    if msg.result == 1 then
      local v = sys.variant()
      v:set(packet.key.org_name, msg.input)
      bo2.send_variant(packet.eCTS_Guild_Build, v)
    end
  end
  local msg = {
    callback = on_build_guild_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    limit = 16
  }
  local define_org = bo2.gv_define_org:find(30)
  local arg = sys.variant()
  local money = define_org.value
  arg:set("money", money)
  msg.text = sys.mtf_merge(arg, ui.get_text("org|guild_build_msg"))
  msg.input = L("")
  ui_widget.ui_msg_box.show_common(msg)
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
function on_visible(w, vis)
  if is_multi_server(bo2.player:get_flag_objmem(bo2.eFlagObjMemory_ScnExcelID)) == false then
    ui_guild_mod.ui_guild.w_win.visible = false
    return
  end
  local page = ui_widget.ui_tab.get_show_page(w_win)
  if vis == true then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_Guild_GetGuildList, v)
    if ui.guild_get_self() == nil then
      return
    end
    post_update(packet.eSTC_Guild_MemberList)
    bo2.PlaySound2D(519)
    bo2.send_variant(packet.eCTS_Guild_GetUnionList, v)
    bo2.send_variant(packet.eCTS_Guild_GetEnemyList, v)
    local schedule_btn = ui_widget.ui_tab.get_button(w_win, "schedule_main")
    if ui.guild_get_build(1) == nil then
      schedule_btn.enable = false
    else
      schedule_btn.enable = true
    end
  else
    ui_tool.hide_menu()
    ui_widget.esc_stk_pop(w)
    bo2.PlaySound2D(520)
  end
  if page_visile[page.name] ~= nil then
    page_visile[page.name](page, vis)
  end
  ui_guild_mod.ui_guild_info.on_visible(w, vis)
  ui_guild_mod.ui_guild_personal.on_visible(w, vis)
  ui_guild_mod.ui_guild_banner.on_visible(w, vis)
  if disable_qt ~= 1 then
    local member = ui.guild_get_self()
    if member == nil then
      return
    end
    local excel = bo2.gv_guild_title:find(member.title)
    if excel == nil then
      return
    end
    if excel.qt_setting == 1 then
      w_qt_setting.visible = true
    else
      w_qt_setting.visible = false
    end
    w_qt_enter_room.visible = true
    w_open_qt_info.visible = true
  end
end
function insert_tab(name, style, msg)
  local btn_uri = "$frame/guild/guild.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/guild/" .. name .. ".xml"
  local page_sty = style
  ui_widget.ui_tab.insert_suit(w_win, style, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_widget.ui_tab.get_button(w_win, style)
  btn.name = name
  local page = ui_widget.ui_tab.get_page(w_win, style)
  page.name = name
  btn.text = ui.get_text(sys.format("guild|tab_btn_%s", name))
  btn:insert_on_press(on_tab_press, "ui_guild_mod.on_tab_press")
end
function on_tab_press(btn, press)
  if btn.name == L("personal_info") and press then
    ui_guild_mod.ui_guild_personal.update()
  elseif btn.name == L("guild_banner") and press then
    ui_guild_mod.ui_guild_banner.guild_banner_update()
  end
end
function update_guild_mng()
  ui_guild_mod.ui_hall.updata_hall()
  ui_guild_mod.ui_apply.updata_apply()
  ui_guild_mod.ui_title.updata_apply()
end
function on_init()
  page_visile = {
    [L("schedule_main")] = ui_guild_mod.ui_schedule.on_visible
  }
  insert_tab("personal_info", "personal_info_main")
  insert_tab("guild_info", "guild_info_main")
  insert_tab("schedule", "schedule_main")
  insert_tab("member", "member_main")
  insert_tab("manage", "manage_main")
  local banner_on = bo2.gv_define_org:find(120).value.v_int
  if banner_on == 1 then
    insert_tab("guild_banner", "guild_banner_main")
  end
  ui_guild_mod.ui_guild_personal.on_init()
  ui_widget.ui_tab.show_page(w_win, "personal_info_main", true)
  ui.insert_on_guild_refresh("ui_guild_mod.ui_guild.post_update", "ui_guild_mod.ui_guild.post_update")
  ui.insert_on_guild_mgr_refresh("ui_guild_mod.ui_guild.update_guild_mng", "ui_guild_mod.ui_guild.update_guild_mng")
  ui.insert_on_guild_apply_refresh("ui_guild_mod.ui_apply.updata_apply", "ui_guild_mod.ui_apply.updata_apply")
  ui_guild_mod.ui_guild_info.on_init()
  ui_guild_mod.ui_guild_info.update(0, true)
  ui_guild_mod.ui_member.on_init()
end
function hotkey_update()
  if not sys.check(g_title) then
    return
  end
  local hotkey_txt = ui_setting.ui_input.get_op_simple_text(2007)
  local cult_type = ui.guild_cult_type()
  if cult_type == 0 then
    if hotkey_txt ~= nil and not hotkey_txt.empty then
      g_title.text = ui_widget.merge_mtf({
        guild_name = ui.guild_name(),
        level = ui.guild_get_level(),
        hotkey = hotkey_txt
      }, ui.get_text("guild|title_hotkey"))
    else
      g_title.text = ui_widget.merge_mtf({
        guild_name = ui.guild_name(),
        level = ui.guild_get_level()
      }, ui.get_text("guild|title"))
    end
  else
    local n = bo2.gv_guild_cult:find(cult_type)
    if hotkey_txt ~= nil and not hotkey_txt.empty then
      g_title.text = ui_widget.merge_mtf({
        guild_name = ui.guild_name(),
        level = ui.guild_get_level(),
        cult_name = n.name,
        hotkey = hotkey_txt
      }, ui.get_text("guild|title_cult_hotkey"))
    else
      g_title.text = ui_widget.merge_mtf({
        guild_name = ui.guild_name(),
        level = ui.guild_get_level(),
        cult_name = n.name
      }, ui.get_text("guild|title_cult"))
    end
  end
end
function update(cmd)
  if bo2.is_in_guild() == sys.wstring(0) then
    w_win.visible = false
    ui_guild_mod.ui_guild_search.w_guild_search.visible = false
  end
  ui_guild_mod.ui_guild_info.update(cmd, false)
  local hotkey_txt = ui_setting.ui_input.get_op_simple_text(2007)
  local cult_type = ui.guild_cult_type()
  if cult_type == 0 then
    if hotkey_txt ~= nil and not hotkey_txt.empty then
      g_title.text = ui_widget.merge_mtf({
        guild_name = ui.guild_name(),
        level = ui.guild_get_level(),
        hotkey = hotkey_txt
      }, ui.get_text("guild|title_hotkey"))
    else
      g_title.text = ui_widget.merge_mtf({
        guild_name = ui.guild_name(),
        level = ui.guild_get_level()
      }, ui.get_text("guild|title"))
    end
  else
    local n = bo2.gv_guild_cult:find(cult_type)
    if hotkey_txt ~= nil and not hotkey_txt.empty then
      g_title.text = ui_widget.merge_mtf({
        guild_name = ui.guild_name(),
        level = ui.guild_get_level(),
        cult_name = n.name,
        hotkey = hotkey_txt
      }, ui.get_text("guild|title_cult_hotkey"))
    else
      g_title.text = ui_widget.merge_mtf({
        guild_name = ui.guild_name(),
        level = ui.guild_get_level(),
        cult_name = n.name
      }, ui.get_text("guild|title_cult"))
    end
  end
  if cmd == packet.eSTC_Guild_HallList then
    ui_guild_mod.ui_hall.updata_hall()
  end
  if cmd == packet.eSTC_Guild_MemberList or cmd == packet.eSTC_Guild_SelfData or cmd == packet.eSTC_Guild_Appoint or cmd == packet.eSTC_Guild_MemberData or cmd == packet.eSTC_Guild_DelMember then
    ui_guild_mod.ui_member.update_member()
    ui_guild_mod.ui_guild_personal.update_personal_info()
  end
  if (cmd == packet.eSTC_Guild_DelMember or cmd == packet.eSTC_Guild_Release) and bo2.is_in_guild() == sys.wstring(0) then
    ui_quest.clear_guild_quest()
  end
  if cmd == packet.eSTC_Guild_Release then
    ui_info_tip.schedule_cd.CloseSchedule()
    ui_info_tip.on_click_del_msg(6)
  end
  if cmd == packet.eSTC_Guild_DelMember then
    ui_guild_mod.ui_title.on_delmember()
  end
  if cmd == packet.eSTC_Guild_Create then
    ui_guild_mod.ui_guild_info.on_build_init()
    ui_quest.clear_guild_quest_list()
    ui_widget.ui_tab.show_page(w_win, "personal_info_main", true)
    local arg = sys.variant()
    local info_text = ui.guild_get_info()
    if info_text.empty == true then
      info_text = ui.get_text("guild|panel_title_notice_empty")
    end
    arg:set("text", info_text)
    local text = sys.mtf_merge(arg, ui.get_text("guild|chat_title_notice"))
    ui_chat.show_ui_msg(text, nil, bo2.eChatChannel_Guild, 0)
  end
end
function update_highlight(item)
  item:search("fig_highlight").visible = item.selected or item.inner_hover
end
function on_item_name_mouse(item, msg)
  local tar = item.parent.parent
  on_cmn_item_mouse_sp(tar, msg)
end
function on_cmn_item_mouse_sp(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    update_highlight(item)
  end
  if msg == ui.mouse_lbutton_click then
    local cur_item = ui_guild_mod.ui_member.g_title_list.item_sel
    if cur_item ~= nil and cur_item ~= item then
      cur_item.selected = false
    end
    item.selected = true
  end
end
function on_cmn_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    update_highlight(item)
  end
end
function post_update(cmd)
  if cmd == packet.eSTC_Guild_MemberList or cmd == packet.eSTC_Guild_SelfData then
    local function do_update()
      update(cmd)
    end
    w_win:insert_post_invoke(do_update, "ui_guild_mod.ui_guild.post_update")
  else
    update(cmd)
  end
end
function OnGetUnionList(cmd, data)
  union_list = {}
  local v = data:get(packet.key.org_listdata)
  for i = 0, v.size - 1 do
    local item = v:get(i)
    if item:get(packet.key.guild_name).v_string ~= ui.guild_name() then
      table.insert(union_list, {
        org_id = item:get(packet.key.org_id),
        name = item:get(packet.key.guild_name).v_string,
        leader = item:get(packet.key.org_srcplayername).v_string,
        energy = item:get(packet.key.org_energy).v_int,
        level = item:get(packet.key.guild_level).v_int,
        number = item:get(packet.key.org_number).v_int,
        maxnum = item:get(packet.key.guild_maxmember).v_int,
        state = item:get(packet.key.cmn_state).v_int,
        inscn = item:get(packet.key.player_count).v_int
      })
    end
  end
  g_union_cd_begin = 0
  if data:has(packet.key.cmn_state) then
    g_union_cd_begin = data:get(packet.key.cmn_state).v_int
  end
  ui_guild_mod.ui_manage.updata_union()
end
function OnGetEnemyList(cmd, data)
  enemy_list = {}
  local v = data:get(packet.key.org_listdata)
  for i = 0, v.size - 1 do
    local item = v:get(i)
    local enemy = {
      org_id = item:get(packet.key.org_id),
      name = item:get(packet.key.guild_name).v_string,
      leader = item:get(packet.key.org_srcplayername).v_string,
      energy = item:get(packet.key.org_energy).v_int,
      level = item:get(packet.key.guild_level).v_int,
      number = item:get(packet.key.org_number).v_int,
      maxnum = item:get(packet.key.guild_maxmember).v_int
    }
    table.insert(enemy_list, enemy)
  end
  ui_guild_mod.ui_manage.updata_enemy()
end
function on_qt_setting()
  if disable_qt ~= 1 then
    ui_qt.gx_window.visible = not ui_qt.gx_window.visible
  end
end
function on_qt_make_tip(tip)
  local guild_room_id = ui.guild_qt_room()
  local guild_sub_room_id = ui.guild_qt_sub_room()
  local cur_room_id = bo2.qt_cur_room_id()
  local sub_room_id = bo2.qt_cur_sub_room_id()
  local text = ui.get_text("qt|enter_guild_room_tip")
  if guild_room_id == 0 and guild_sub_room_id == 0 then
    ui_widget.tip_make_view(tip.view, text)
    return
  end
  if cur_room_id == guild_room_id or sub_room_id == guild_sub_room_id then
    local member = ui.guild_get_self()
    if member == nil then
      return
    end
    local excel = bo2.gv_guild_title:find(member.title)
    if excel == nil then
      return
    end
    if excel.qt_together == 1 then
      text = ui.get_text("qt|together_guild")
    end
  end
  ui_widget.tip_make_view(tip.view, text)
end
function on_qt_enter_guild_room()
  local guild_room_id = ui.guild_qt_room()
  local guild_sub_room_id = ui.guild_qt_sub_room()
  local cur_room_id = bo2.qt_cur_room_id()
  local sub_room_id = bo2.qt_cur_sub_room_id()
  if guild_room_id == 0 and guild_sub_room_id == 0 then
    local t = ui.get_text("qt|no_bind_msg")
    ui_tool.note_insert(t, L("FFFF0000"))
    return
  elseif cur_room_id == guild_room_id or sub_room_id == guild_sub_room_id then
    local member = ui.guild_get_self()
    if member == nil then
      return
    end
    local excel = bo2.gv_guild_title:find(member.title)
    if excel == nil then
      return
    end
    if excel.qt_together == 1 then
      local v = sys.variant()
      bo2.send_variant(packet.eCTS_Guild_QTGetTogether, v)
    else
      local msg = {
        btn_confirm = true,
        btn_cancel = false,
        modal = false,
        text = ui.get_text("qt|in_guild_room")
      }
      ui_widget.ui_msg_box.show_common(msg)
    end
  elseif cur_room_id ~= 0 then
    local v = sys.variant()
    local cur_room_name = bo2.qt_cur_room_name()
    v:set("room_name", cur_room_name)
    local text = sys.mtf_merge(v, ui.get_text("qt|enter_hasroom"))
    local enter_text = enter_text .. text
    if cur_room_name ~= "" or cur_room_name == nil then
      if cur_room_id > 0 then
        v:set("room_id", cur_room_id)
        text = sys.mtf_merge(v, ui.get_text("qt|room_id"))
        enter_text = enter_text .. text
      end
      if sub_room_id > 0 then
        v:set("sub_room_id", sub_room_id)
        text = sys.mtf_merge(v, ui.get_text("qt|sub_room_id"))
        enter_text = enter_text .. text
      end
    end
    local enter_subfix = ui.get_text("qt|enter_guild_room")
    enter_text = enter_text .. enter_subfix
    local msg = {
      style_uri = "$frame/qt/qt.xml",
      style_name = "enter_confirm_guild",
      text = enter_text,
      modal = false,
      callback = function(data)
        if data.result == 1 then
          bo2.qt_enter_room(guild_room_id, guild_sub_room_id)
        end
      end
    }
    ui_widget.ui_msg_box.show_common(msg)
  else
    bo2.qt_enter_room(guild_room_id, guild_sub_room_id)
  end
end
function on_qt_open_guild_info()
  local guild_room_id = ui.guild_qt_room()
  local guild_sub_room_id = ui.guild_qt_sub_room()
  local cur_room_id = bo2.qt_cur_room_id()
  local sub_room_id = bo2.qt_cur_sub_room_id()
  if guild_room_id == 0 or guild_sub_room_id == 0 then
    local t = ui.get_text("qt|not_in_guild_qt")
    ui_tool.note_insert(t, L("FFFF0000"))
    return
  end
  if guild_room_id ~= cur_room_id and guild_sub_room_id ~= sub_room_id then
    local t = ui.get_text("qt|not_in_guild_qt")
    ui_tool.note_insert(t, L("FFFF0000"))
    return
  end
  bo2.qt_show_cur_window()
end
function on_guild_self_enter()
  local scn = bo2.scn
  if sys.check(scn) ~= true then
    return
  end
  if bo2.is_in_guild() == L("0") then
    return
  end
  local pk_limit = scn.scn_excel.pk_limit
  if pk_limit == bo2.eScnPKLmt_Guild then
    bo2.send_variant(packet.eCTS_Guild_GetGuildList, v)
  end
end
function ack_guild_invite_popo(click, data)
  local v = sys.variant()
  v:set(packet.key.org_requestid, data:get(packet.key.org_requestid))
  accept = 0
  if "yes" ~= click then
    accept = 1
  end
  v:set(packet.key.org_acceptrequest, accept)
  v:set(packet.key.cmn_type, bo2.eSociality_ResponseType_GuildInvite)
  bo2.send_variant(packet.eCTS_Guild_Response, v)
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
function on_qt_together(cmd, data)
  local type = data:get(packet.key.cmn_type).v_int
  local cur_room_id = bo2.qt_cur_room_id()
  local sub_room_id = bo2.qt_cur_sub_room_id()
  if type == 1 then
    ui_group.on_gettogether_ack()
  else
    local guild_room_id = ui.guild_qt_room()
    local guild_sub_room_id = ui.guild_qt_sub_room()
    if cur_room_id == 0 then
      bo2.qt_enter_room(guild_room_id, guild_sub_room_id)
    elseif cur_room_id == guild_room_id or sub_room_id == guild_sub_room_id then
      return
    else
      local v = sys.variant()
      v:set(packet.key.ui_popo_type, "qttogether")
      v:set(packet.key.ui_text, ui.get_text("qt|team_popo_tip"))
      ui_popo.AddPopo("qttogether", v)
    end
  end
end
function OnCultCreate(cmd, data)
  ui_guild_mod.ui_guild_info.on_build_init()
  ui_guild_mod.ui_build.on_guild_build_refresh()
end
function OnCultRelease(cmd, data)
  ui_guild_mod.ui_guild_info.on_build_init()
  ui_guild_mod.ui_build.on_guild_build_refresh()
end
function OnSelfData(cmd, data)
  if data:has(packet.key.guild_info) then
    local arg = sys.variant()
    local info_text = ui.guild_get_info()
    if info_text.empty == true then
      info_text = ui.get_text("guild|panel_title_notice_empty")
    end
    arg:set("text", info_text)
    local text = sys.mtf_merge(arg, ui.get_text("guild|chat_title_notice"))
    ui_chat.show_ui_msg(text, nil, bo2.eChatChannel_Guild, 0)
  end
end
reg(packet.eSTC_Guild_UnionList, OnGetUnionList, sig)
reg(packet.eSTC_Guild_EnemyList, OnGetEnemyList, sig)
reg(packet.eSTC_UI_QT_Gettogether, on_qt_together, sig)
reg(packet.eSTC_Guild_Cult_Create, OnCultCreate, sig)
reg(packet.eSTC_Guild_Cult_Release, OnCultRelease, sig)
reg(packet.eSTC_Guild_SelfData, OnSelfData, sig)
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_guild_self_enter, "ui_guild_mod.ui_guild.on_guild_self_enter")
ui_setting.ui_input.hotkey_notify_insert(hotkey_update, "ui_guild_mod.ui_guild.hotkey_update")
