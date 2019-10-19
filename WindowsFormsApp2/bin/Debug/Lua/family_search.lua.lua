local select_family
function on_init(ctrl)
  select_family = nil
  g_search_list:item_clear()
  g_keyword_box.text = L("")
  ui.insert_on_family_search_refresh("ui_org.ui_family_search.on_family_search_refresh")
end
function on_family_search_refresh()
  g_search_list:item_clear()
  select_family = nil
  local item_file = "$frame/org/family_search.xml"
  local item_style = "family_search_item"
  local energy_h = bo2.gv_define_org:find(25).value
  local energy_l = bo2.gv_define_org:find(26).value
  for i = 0, ui.family_search_rst_size() - 1 do
    local item = g_search_list:item_append()
    item:load_style(item_file, item_style)
    local ui_family_search
    result = ui.family_get_search_rst(i)
    local id = item:search("id")
    id.text = result.id
    local intro = item:search("intro")
    intro.text = result.intro
    local family_name = item:search("family_name")
    family_name.text = result.name
    local leader = item:search("leader")
    leader.text = result.leader
    local energy = item:search("energy")
    if result.energy * 3600 > energy_h.v_int then
      energy.text = ui.get_text("org|energy_h")
    elseif result.energy * 3600 > energy_l.v_int then
      energy.text = ui.get_text("org|energy_m")
    else
      energy.text = ui.get_text("org|energy_l")
    end
    local guild_name = item:search("guild_name")
    guild_name.text = result.guild_name
  end
end
function on_family_search_visible(w, vis)
  if vis == true then
    g_keyword_box.focus = true
    g_keyword_box.text = L("")
    select_family = nil
    g_family_search_btn:click()
    g_guild_invite_btn.enable = false
    g_family_apply_btn.enable = true
    if bo2.is_in_family() ~= sys.wstring(0) then
      g_family_apply_btn.enable = false
    end
    local ui_family_member
    self = ui.guild_get_self()
    if self ~= nil and (self.guild_pos == 7 or self.guild_pos == 6) then
      g_guild_invite_btn.enable = true
    end
  else
    ui_org.ui_apply.w_apply_main.visible = false
  end
end
function on_search_item_select(ctrl)
  if select_family ~= nil then
    select_family:search("select").visible = false
  end
  select_family = ctrl
  select_family:search("select").visible = true
  local intro = select_family:search("intro")
  local arg = sys.variant()
  if intro.text == L("") then
    arg:set("intro", ui.get_text("org|null"))
  else
    arg:set("intro", intro.text)
  end
  local tip_text = sys.mtf_merge(arg, ui.get_text("org|intro_text"))
  ui_tool.ctip_show_popup(ctrl, tip_text, "x_auto")
end
function on_family_search(w, vis)
  local v = sys.variant()
  v:set(packet.key.org_vartext, g_keyword_box.text)
  bo2.send_variant(packet.eCTS_Family_Search, v)
  g_family_search_btn.enable = false
  g_timer.suspended = false
end
function on_guild_invite(w, vis)
  if select_family == nil then
    local msg = {
      callback = on_guild_invite_msg,
      btn_confirm = true,
      btn_cancel = false,
      modal = true
    }
    msg.text = ui.get_text("org|select_family")
    ui_tool.show_msg(msg)
  else
    local msg = {
      callback = on_guild_invite_msg,
      btn_confirm = true,
      btn_cancel = true,
      modal = true
    }
    msg.text = ui.get_text("org|guild_invite_family_msg")
    ui_tool.show_msg(msg)
  end
end
function on_family_apply(w, vis)
  if select_family == nil then
    local msg = {
      btn_confirm = true,
      btn_cancel = false,
      modal = true
    }
    msg.text = ui.get_text("org|select_family")
    ui_tool.show_msg(msg)
  else
    local msg = {
      callback = on_family_apply_msg,
      btn_confirm = true,
      btn_cancel = true,
      modal = true
    }
    msg.text = ui.get_text("org|family_apply_msg")
    ui_tool.show_msg(msg)
  end
end
function on_guild_invite_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local v = sys.variant()
    local name = select_family:search("family_name")
    v:set(packet.key.guild_tarfamilyname, name.text)
    bo2.send_variant(packet.eCTS_Guild_Invite, v)
  end
end
function on_family_apply_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local id = select_family:search("id")
    ui_org.ui_apply.set_apply_info(1, id.text)
    ui_org.ui_apply.w_apply_main.visible = true
  end
end
function on_timer(timer)
  g_family_search_btn.enable = true
  timer.suspended = true
end
