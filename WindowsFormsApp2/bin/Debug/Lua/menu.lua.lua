function send_set_captain(item)
  local info = item.owner_menu.info
  ui_group.send_change_captain(info.name)
end
function send_del_member(item)
  local info = item.owner_menu.info
  ui_group.send_delete_member(info.name)
end
function send_change_member_pos(item)
  local info = item.owner_menu.info
  local panel = item.owner_menu.panel
  local pos = item.owner_menu.pos
  local data = sys.variant()
  data:set("mem_pos", info.member_pos)
  local on_drop_hook = function(w, msg, pos, data)
  end
  ui_tool.w_view_floater_box.target = panel
  ui_tool.w_view_floater.size = panel.size
  ui_tool.w_view_floater.alpha = 0.6
  ui.setup_drop(ui_tool.w_view_floater, data, on_drop_hook)
  ui.reset_drop(panel:control_to_parent(panel, pos))
end
function send_group_alloc(item)
  local id = item.id
  local data = sys.variant()
  if id == 0 then
    local level_i = ui_widget.ui_combo_box.selected(w_toos_level)
    if level_i == nil then
      data:set(packet.key.group_alloc_rolllevel, 12)
    else
      data:set(packet.key.group_alloc_rolllevel, level_i.id)
    end
    data:set(packet.key.group_alloc_mode, packet.key.group_alloc_free)
  elseif id == 1 then
    data:set(packet.key.group_alloc_mode, packet.key.group_alloc_roll)
  elseif id == 2 then
    data:set(packet.key.group_alloc_rolllevel, 12)
    data:set(packet.key.group_alloc_mode, bo2.eLootMod_GroupCaptainAssign)
  end
  bo2.send_variant(packet.eCTS_Group_SetConfig, data)
  ui.log("alloc mod:%d", id)
end
function send_group_alloc_toos_level(item)
  local level = item.id
  local data = sys.variant()
  data:set(packet.key.group_alloc_rolllevel, level)
  ui.log("toos level:%d", level)
  bo2.send_variant(packet.eCTS_Group_SetConfig, data)
end
