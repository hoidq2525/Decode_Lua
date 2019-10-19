function handle_borrow_life_ask(cmd, data)
  show_borrow_life_ui(true, data)
end
function handle_player_dead(cmd, data)
  local leftlife = data:get(packet.key.arcade_dungeon_player_life).v_int
  local can_borrow_life = data:get(packet.key.packet.key.arcade_dungeon_may_borrow_life).v_int
  local time = data:get(packet.key.packet.key.arcade_dungeon_left_time).v_int
  self_dead(leftlife, can_borrow_life, time)
end
function handle_player_life_info(cmd, data)
  local data_size = data.size
  local self_life = 0
  local teammate_life = 0
  for i = 1, data_size do
    local player_data = data:get(i)
    local player_name = player_data:get(packet.key.arcade_dungeon_player_name).v_string
    local player_life = player_data:get(packet.key.arcade_dungeon_player_life).v_int
    if player_name == bo2.player.name then
      self_life = player_life
    else
      teammate_life = player_life
      set_teammate_name(player_name)
    end
  end
  set_life(self_life, teammate_life)
  update_life_info()
end
function handle_level_start(cmd, data)
  local cur_lvl = data:get(packet.key.arcade_dungeon_cur_level).v_int
  local cur_target = data:get(packet.key.arcade_dungeon_cur_target).v_string
  set_level(cur_lvl)
  set_target(cur_target)
  g_life_info.visible = true
end
function handle_fuben_end(cmd, data)
  g_life_info.visible = false
  g_death.visible = false
  g_borrow_life.visible = false
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_arcade_dungeon.packet_handle"
reg(packet.eSTC_ArcadeDungeon_BorrowLifeAsk, handle_borrow_life_ask, sig)
reg(packet.eSTC_ArcadeDungeon_PlayerDead, handle_player_dead, sig)
reg(packet.eSTC_ArcadeDungeon_PlayerLifeInfo, handle_player_life_info, sig)
reg(packet.eSTC_ArcadeDungeon_Start, handle_level_start, sig)
reg(packet.eSTC_ArcadeDungeon_End, handle_fuben_end, sig)
