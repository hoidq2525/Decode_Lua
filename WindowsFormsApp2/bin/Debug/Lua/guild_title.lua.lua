function on_guild_title_mgr_visible(w, vis)
  if vis == true then
    w:move_to_head()
  elseif g_title_list.item_sel ~= nil then
    g_title_list.item_sel:search("fig_highlight_sel").visible = false
    g_title_list.item_sel.selected = false
  end
end
function set_title_item(item, member)
  local id = item:search("id")
  id.text = member.id
  local name = item:search("name")
  name.text = member.name
  local level = item:search("level")
  level.text = member.level
  local n = bo2.gv_profession_list:find(member.career)
  local dmg = n.damage
  local f = item:search("job")
  if dmg == 1 then
    f.xcolor = "FF608CD9"
  else
    f.xcolor = "FFEE5544"
  end
  f.image = sys.format("$image/personal/32x32/%d.png|0,0,27,30", n.career)
  item:search("title_cur").text = bo2.gv_guild_title:find(member.title).name
  item:search("title_apply").text = bo2.gv_guild_title:find(member.title_apply).name
  item:search("total_con").text = member.total_con
  if member.status == 0 then
    name.color = ui.make_color("808080")
    level.color = ui.make_color("808080")
  end
end
function updata_apply()
  if bo2.is_in_guild() == sys.wstring(0) then
    w_guild_title_mgr.visible = false
    ui_guild_mod.ui_guild.w_win.visible = false
    return
  end
  local self = ui.guild_get_self()
  if g_title_list.item_sel ~= nil then
    g_title_list.item_sel:search("fig_highlight_sel").visible = false
    g_title_list.item_sel.selected = false
  end
  local item_file = "$frame/guild/guild_title.xml"
  local item_style = "guild_title_item"
  g_title_list:item_clear()
  for i = 0, ui.guild_member_size() - 1 do
    local member = ui.guild_get_member(i)
    local line = bo2.gv_guild_title:find(member.title_apply)
    if line ~= nil and self.guild_pos > member.guild_pos and self.guild_pos > line.status and (self.guild_pos == bo2.Guild_Leader or self.hall_id == member.hall_id) then
      local item = g_title_list:item_append()
      item:load_style(item_file, item_style)
      set_title_item(item, member)
    end
  end
  local manage_text = ui_guild_mod.ui_manage.gx_text_title
  local manage_btn = ui_guild_mod.ui_manage.gx_btn_title
  if g_title_list.item_count ~= 0 then
    manage_text.text = sys.format(ui.get_text("guild|guild_title_manage_tip"), g_title_list.item_count)
    manage_btn.visible = true
  else
    manage_text.text = ui.get_text("guild|guild_title_manage_null_tip")
    manage_btn.visible = false
  end
end
function on_title_item_select(item, sel)
  ui_guild_mod.ui_guild.update_highlight(item)
  item:search("fig_highlight_sel").visible = item.selected or item.inner_hover
end
function on_check_all(ctrl)
  for i = 0, g_title_list.item_count - 1 do
    local item = g_title_list:item_get(i)
    item:search("delselect").check = true
  end
end
function on_reverse_check(ctrl)
  for i = 0, g_title_list.item_count - 1 do
    local item = g_title_list:item_get(i)
    item:search("delselect").check = not item:search("delselect").check
  end
end
function on_accept(ctrl)
  local ischeck = false
  for i = 0, g_title_list.item_count - 1 do
    local item = g_title_list:item_get(i)
    if item:search("delselect").check == true then
      on_apply_msg(item:search("id").text)
      ischeck = true
    end
  end
  if ischeck == false and g_title_list.item_sel ~= nil then
    on_apply_msg(g_title_list.item_sel:search("id").text)
  end
end
function on_refuse(ctrl)
  local ischeck = false
  for i = 0, g_title_list.item_count - 1 do
    local item = g_title_list:item_get(i)
    if item:search("delselect").check == true then
      on_refuse_apply_msg(item:search("id").text)
      ischeck = true
    end
  end
  if ischeck == false and g_title_list.item_sel ~= nil then
    on_refuse_apply_msg(g_title_list.item_sel:search("id").text)
  end
end
function on_apply_msg(assign_id)
  local v = sys.variant()
  v:set(packet.key.cmn_id, assign_id)
  v:set(packet.key.cmn_agree_ack, 1)
  bo2.send_variant(packet.eCTS_Guild_TitleApplyAsk, v)
end
function on_refuse_apply_msg(assign_id)
  local v = sys.variant()
  v:set(packet.key.cmn_id, assign_id)
  v:set(packet.key.cmn_agree_ack, 0)
  bo2.send_variant(packet.eCTS_Guild_TitleApplyAsk, v)
end
function on_delmember()
  for i = 0, g_title_list.item_count - 1 do
    local item = g_title_list:item_get(i)
    local member = ui.guild_find_member(item:search("id").text)
    if member == nil then
      item:self_remove()
      break
    end
  end
  local manage_text = ui_guild_mod.ui_manage.gx_text_title
  local manage_btn = ui_guild_mod.ui_manage.gx_btn_title
  if g_title_list.item_count ~= 0 then
    manage_text.text = sys.format(ui.get_text("guild|guild_title_manage_tip"), g_title_list.item_count)
    manage_btn.visible = true
  else
    manage_text.text = ui.get_text("guild|guild_title_manage_null_tip")
    manage_btn.visible = false
    w_guild_title_mgr.visible = false
  end
end
function on_item_name_mouse(item, msg)
  local tar = item.parent.parent
  on_cmn_item_mouse_sp(tar, msg)
end
function on_cmn_item_mouse_sp(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    ui_guild_mod.ui_guild.update_highlight(item)
  end
  if msg == ui.mouse_lbutton_click then
    local cur_item = ui_guild_mod.ui_title.g_title_list.item_sel
    if cur_item ~= nil and cur_item ~= item then
      cur_item.selected = false
    end
    item.selected = true
  end
end
