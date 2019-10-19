local p_info, ui_tab, ui_member
function on_cmn_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    update_highlight(item)
  end
end
function update_highlight(item)
  item:search("fig_highlight").visible = item.selected or item.inner_hover
end
function on_visible(w, vis)
  local page = ui_tab.get_show_page(w_win)
  if vis then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    if ui.guild_get_self() == nil then
      return
    end
    bo2.PlaySound2D(519)
    bo2.send_variant(packet.eCTS_NpcGuild_GetList)
    p_info.on_visible(w, vis)
    p_member.on_visible(w, vis)
  else
    ui_tool.hide_menu()
    ui_widget.esc_stk_pop(w)
    bo2.PlaySound2D(520)
  end
end
function insert_tab(name, style, msg)
  local btn_uri = "$frame/npc_guild/guild_n.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/npc_guild/" .. name .. "_n.xml"
  local page_sty = style
  ui_tab.insert_suit(w_win, style, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_win, style)
  btn.name = name
  local page = ui_tab.get_page(w_win, style)
  page.name = name
  btn.text = ui.get_text(sys.format("guild|tab_btn_%s", name))
  btn:insert_on_press(on_tab_press, "ui_npc_guild_mod.on_tab_press")
end
function on_tab_press(btn, press)
  if press then
    if btn.name == L("personal_info") then
      p_info.update()
    elseif btn.name == L("member") then
      p_member.update_member()
    end
  end
end
function on_init()
  ui_tab = ui_widget.ui_tab
  p_info = ui_npc_guild_mod.ui_npc_guild_personal
  p_member = ui_npc_guild_mod.ui_member
  insert_tab("personal_info", "personal_info_main")
  insert_tab("member", "member_main")
  p_info.on_init()
  ui_tab.show_page(w_win, "personal_info_main", true)
  ui.insert_on_guild_refresh("ui_npc_guild_mod.ui_npc_guild.post_update")
  p_member.on_init()
end
function post_update(cmd)
  if bo2.is_in_guild() == sys.wstring(0) then
    w_win.visible = false
  end
  hotkey_update()
  if cmd == packet.eSTC_Guild_HallList then
    p_info.update_personal_info()
    p_member.update_member()
  end
  if cmd == packet.eSTC_Guild_MemberList or cmd == packet.eSTC_Guild_SelfData or cmd == packet.eSTC_Guild_Appoint or cmd == packet.eSTC_Guild_MemberData then
    p_member.update_member()
  end
end
function hotkey_update()
  local hotkey_txt = ui_setting.ui_input.get_op_simple_text(2007)
  if not sys.check(g_title) then
    return
  end
  if hotkey_txt ~= nil and not hotkey_txt.empty then
    g_title.text = ui_widget.merge_mtf({
      guild_name = ui.guild_name(),
      hotkey = hotkey_txt
    }, ui.get_text("guild|title_hotkey"))
  else
    g_title.text = ui_widget.merge_mtf({
      guild_name = ui.guild_name()
    }, ui.get_text("guild|title"))
  end
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_guild_self_enter, "ui_guild_mod.ui_guild.on_guild_self_enter")
ui_setting.ui_input.hotkey_notify_insert(hotkey_update, "ui_npc_guild_mod.ui_npc_guild.hotkey_update")
