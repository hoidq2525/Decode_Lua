function handleUpdataPlayer(data)
  info_list.updata_player(data)
end
function handleResetIner(data)
  iner.reset_top_tip(data)
  info_list.reset_inner()
end
function handleCloseIner(data)
  iner.gx_top_tip.visible = false
  info_list.gx_info_list_win.visible = false
  local info = {}
  ui_map.update_temp_point_map(info)
end
function handleSetClock(data)
  iner.set_clock(data)
end
function handleShowResult(data)
  info_list.show_result(data)
end
function handleUpdatePoint(data)
  local info = {}
  local players = data:get(packet.key.battlegroup_players)
  for i = 0, players.size - 1 do
    local player = {}
    local myinfo = players:get(i)
    player.name = myinfo:get(packet.key.cmn_name).v_string
    player.pos_x = myinfo:get(packet.key.cha_pos_x).v_number
    player.pos_z = myinfo:get(packet.key.cha_pos_z).v_number
    table.insert(info, player)
  end
  ui_map.update_temp_point_map(info)
end
function open_info_win()
  if info_list.g_battle_state == 1 then
    return
  end
  info_list.gx_info_list_win.visible = not info_list.gx_info_list_win.visible
end
