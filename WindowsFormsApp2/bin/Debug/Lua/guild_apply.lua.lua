function on_guild_apply_mgr_visible(w, vis)
  if vis == true then
    w:move_to_head()
  else
    if apply_select ~= nil then
      apply_select:search("fig_highlight_sel").visible = false
      apply_select = nil
    end
    if g_apply_list.item_sel ~= nil then
      g_apply_list.item_sel:search("fig_highlight_sel").visible = false
      g_apply_list.item_sel.selected = false
    end
  end
end
function set_apply_item(item, member)
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
  item:search("job").svar = member.career
  local status = item:search("status")
  status.text = ui.get_text("guild|status" .. member.status)
  if member.status == 0 then
    name.color = ui.make_color("808080")
    level.color = ui.make_color("808080")
    status.color = ui.make_color("808080")
  end
end
function updata_apply()
  if bo2.is_in_guild() == sys.wstring(0) then
    w_guild_apply_mgr.visible = false
    ui_guild_mod.ui_guild.w_win.visible = false
    return
  end
  if g_apply_list.item_sel ~= nil then
    g_apply_list.item_sel:search("fig_highlight_sel").visible = false
    g_apply_list.item_sel.selected = false
  end
  apply_select = nil
  g_apply_info_box.text = nil
  local item_file = "$frame/guild/guild_apply.xml"
  local item_style = "guild_apply_item"
  g_apply_list:item_clear()
  if ui.guild_apply_size() ~= 0 then
    for i = 0, ui.guild_apply_size() - 1 do
      local member = ui.guild_get_apply(i)
      local item = g_apply_list:item_append()
      item:load_style(item_file, item_style)
      set_apply_item(item, member)
    end
  end
  local manage_text = ui_guild_mod.ui_manage.gx_text_apply
  local manage_btn = ui_guild_mod.ui_manage.gx_btn_apply
  local invite_btn = ui_guild_mod.ui_manage.gx_btn_invite_member
  if g_apply_list.item_count ~= 0 then
    manage_text.text = sys.format(ui.get_text("guild|guild_apply_manage_tip"), g_apply_list.item_count)
    manage_text.visible = true
    manage_btn.visible = true
    invite_btn.margin = ui.rect(0, 0, 80, 4)
  else
    manage_text.text = ui.get_text("guild|guild_apply_manage_null_tip")
    manage_btn.visible = false
    invite_btn.margin = ui.rect(0, 0, 0, 4)
  end
end
function update_shdquest(quest_info)
  if ui_quest.quest_collect == nil then
    return
  end
  ui_quest.quest_collect.on_update(quest_info)
end
function on_apply_item_select(ctrl)
  ui_guild_mod.ui_guild.update_highlight(ctrl)
  if apply_select ~= nil then
    apply_select:search("fig_highlight_sel").visible = false
  end
  apply_select = ctrl
  apply_select:search("fig_highlight_sel").visible = true
  local ui_guild_apply
  member = ui.guild_find_apply(apply_select:search("id").text)
  if member ~= nil then
    g_apply_info_box.text = member.apply
  end
end
function on_check_all(ctrl)
  for i = 0, g_apply_list.item_count - 1 do
    local item = g_apply_list:item_get(i)
    item:search("delselect").check = true
  end
end
function on_reverse_check(ctrl)
  for i = 0, g_apply_list.item_count - 1 do
    local item = g_apply_list:item_get(i)
    item:search("delselect").check = not item:search("delselect").check
  end
end
function on_accept(ctrl)
  local ischeck = false
  for i = 0, g_apply_list.item_count - 1 do
    local item = g_apply_list:item_get(i)
    if item:search("delselect").check == true then
      on_apply_msg(item:search("id").text)
      ischeck = true
    end
  end
  if ischeck == false and apply_select ~= nil then
    on_apply_msg(apply_select:search("id").text)
  end
end
function on_refuse(ctrl)
  local ischeck = false
  for i = 0, g_apply_list.item_count - 1 do
    local item = g_apply_list:item_get(i)
    if item:search("delselect").check == true then
      on_refuse_apply_msg(item:search("id").text)
      ischeck = true
    end
  end
  if ischeck == false and apply_select ~= nil then
    on_refuse_apply_msg(apply_select:search("id").text)
  end
end
function on_apply_msg(assign_id)
  local v = sys.variant()
  local ui_guild_apply
  member = ui.guild_find_apply(assign_id)
  if member ~= nil then
    v:set(packet.key.org_tarplayerid, member.id)
    v:set(packet.key.org_acceptrequest, 1)
    bo2.send_variant(packet.eCTS_Guild_ApproveM, v)
  end
end
function on_refuse_apply_msg(assign_id)
  local v = sys.variant()
  local ui_guild_apply
  member = ui.guild_find_apply(assign_id)
  if member ~= nil then
    v:set(packet.key.org_tarplayerid, member.id)
    v:set(packet.key.org_acceptrequest, 0)
    bo2.send_variant(packet.eCTS_Guild_ApproveM, v)
  end
end
function on_guild_self_enter()
  local scn = bo2.scn
  if sys.check(scn) ~= true then
    return
  end
  bo2.send_variant(packet.eCTS_Guild_GetQuestList, v)
  local pk_limit = scn.scn_excel.pk_limit
  if pk_limit == bo2.eScnPKLmt_Guild and bo2.is_in_guild() ~= L("0") then
    bo2.send_variant(packet.eCTS_Guild_GetGuildList, v)
  end
end
function on_career_tip_make(tip)
  local panel = tip.owner.parent
  local career_panel = panel:search("job")
  local pro_list = bo2.gv_profession_list:find(career_panel.svar)
  text = sys.format("%s", pro_list.name)
  ui_widget.tip_make_view(tip.view, text)
end
