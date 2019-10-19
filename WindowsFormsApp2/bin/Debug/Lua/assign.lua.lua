local assign_type = 0
local assign_id, family_id, family_menu
function family_menu_init(ctrl)
  family_menu = {
    items = {},
    event = on_assign_menu_event,
    popup = "y2x2",
    source = ctrl
  }
  for i = 0, ui.guild_family_count() - 1 do
    local ui_guild_member
    member = ui.guild_get_family(i)
    if member.cur_num >= member.max_member then
      family_menu.items[#family_menu.items + 1] = {
        text = member.name,
        enable = false,
        callback = on_set_one_family,
        id = member.id
      }
    else
      family_menu.items[#family_menu.items + 1] = {
        text = member.name,
        callback = on_set_one_family,
        id = member.id
      }
    end
  end
end
function on_assign_menu_event(item)
  if item.callback then
    item:callback()
  end
end
function on_set_one_family(item)
  family_id = item.id
  g_family_name.text = item.text
end
function on_init(ctrl)
end
function set_assign_type(type, id, name)
  assign_type = type
  assign_id = id
  g_player_name.text = name
  g_player_name.enable = true
  if assign_type == 1 then
    g_player_name.enable = false
  end
  g_player_name.focus = false
  if assign_type == 2 then
    g_player_name.focus = true
  end
end
function on_assign_visible(w, vis)
  if vis == true then
    local min = 1000000
    for i = 0, ui.guild_family_size() - 1 do
      local ui_guild_member
      member = ui.guild_get_family(i)
      if member.status == 2 and min > member.cur_num then
        min = member.cur_num
        family_id = member.id
        g_family_name.text = member.name
      end
    end
  end
end
function on_set_family(ctrl)
  family_menu_init(ctrl)
  ui_tool.show_menu(family_menu)
end
function on_confirm(ctrl)
  local v = sys.variant()
  if assign_type == 1 then
    ui.log(assign_id)
    local ui_family_apply
    member = ui.guild_find_apply(assign_id)
    if member ~= nil then
      v:set(packet.key.org_tarplayerid, member.id)
      v:set(packet.key.guild_tarfamilyid, family_id)
      v:set(packet.key.org_acceptrequest, 1)
      bo2.send_variant(packet.eCTS_Guild_ApproveM, v)
    end
  end
  if assign_type == 2 then
    v:set(packet.key.org_tarplayername, g_player_name.text)
    v:set(packet.key.guild_tarfamilyid, family_id)
    bo2.send_variant(packet.eCTS_Guild_InviteM, v)
  end
  w_assign_main.visible = false
end
function on_cancel(ctrl)
  w_assign_main.visible = false
end
