function on_btn_design1_click(btn)
  local curID = bo2.player:get_flag_int8(bo2.ePlayerFlag8_PlayerShortcutID)
  if 0 == curID then
    return
  end
  local v = sys.variant()
  v:set(packet.key.shortcut_id, 0)
  bo2.send_variant(packet.eCTS_UI_ChangeShortcut, v)
end
function on_btn_design2_click(btn)
  local curID = bo2.player:get_flag_int8(bo2.ePlayerFlag8_PlayerShortcutID)
  if 1 == curID then
    return
  end
  ui_skill.update_sw_bar()
  local v = sys.variant()
  v:set(packet.key.shortcut_id, 1)
  bo2.send_variant(packet.eCTS_UI_ChangeShortcut, v)
end
function on_btn_design3_click(btn)
  local curID = bo2.player:get_flag_int8(bo2.ePlayerFlag8_PlayerShortcutID)
  if 2 == curID then
    return
  end
  local v = sys.variant()
  v:set(packet.key.shortcut_id, 2)
  bo2.send_variant(packet.eCTS_UI_ChangeShortcut, v)
end
function on_btn_design4_click(btn)
  local curID = bo2.player:get_flag_int8(bo2.ePlayerFlag8_PlayerShortcutID)
  if 3 == curID then
    return
  end
  local v = sys.variant()
  v:set(packet.key.shortcut_id, 3)
  bo2.send_variant(packet.eCTS_UI_ChangeShortcut, v)
end
