local player_life_lose = 0
local pk_time_use = 0
local pk_bisha_use_times = 0
local pk_time_start = 0
local pk_time_end = 0
local player_life_last = 0
local is_knight_fight = false
knight_list = nil
function get_knight_pk_data()
  return pk_time_use, player_life_lose, pk_bisha_use_times
end
local on_temp_msg = function(msg)
  return
end
function handle_life_chg(obj, ft, idx)
  local player_life_cur = bo2.player:get_atb(bo2.eAtb_HP)
  local player_life_chg = player_life_last - player_life_cur
  local player_life_max = bo2.player:get_atb(bo2.eAtb_HPMax)
  if player_life_chg > 0 and player_life_max >= player_life_last then
    player_life_lose = player_life_lose + player_life_chg
  end
  if is_knight_fight and ui_knight.can_click() then
    local player_life_max = bo2.player:get_atb(bo2.eAtb_HPMax)
    if player_life_cur < player_life_max / 2 then
      ui_knight.w_seekhelp_button.enable = true
      if ui_knight.w_seekhelp_flash.visible == false then
        ui_knight.w_seekhelp_flash:reset()
      end
      ui_knight.w_seekhelp_flash.visible = true
    else
      ui_knight.w_seekhelp_button.enable = false
      ui_knight.w_seekhelp_flash.visible = false
    end
  end
  player_life_last = player_life_cur
end
function on_pk_start(cmd, data)
  player_life_lose = 0
  pk_time_use = 0
  pk_bisha_use_times = 0
  pk_time_start = os.time()
  player_life_last = bo2.player:get_atb(bo2.eAtb_HP)
  local match_id = data:get(packet.key.scnmatch_id)
  ui_knight.set_match_id(match_id)
  is_knight_fight = data:has(packet.key.is_knight_fight)
  bo2.player:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, handle_life_chg, "ui_deathui:handle_life_chg")
  if is_knight_fight then
    ui_knight.w_seekhelp_main.visible = true
    ui_knight.w_seekhelp_button.enable = false
    ui_knight.w_seekhelp_flash.visible = false
  end
end
function on_pk_end(cmd, _data)
  local time_start = 0
  if _data ~= nil and _data:has(packet.key.knight_pk_time_use) then
    pk_time_use = _data:get(packet.key.knight_pk_time_use).v_int
  else
    time_start = pk_time_start
    pk_time_use = pk_time_end - time_start
  end
  pk_time_end = os.time()
  bo2.player:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, "ui_deathui:handle_life_chg")
  is_knight_fight = false
end
function on_bisha_used(cmd, data)
  pk_bisha_use_times = pk_bisha_use_times + 1
  ui_match.on_bisha_used(cmd, data)
end
function on_get_knight(cmd, data)
  knight_list = data:get(packet.key.knight_npc_list)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_deathui.packet_handle"
reg(packet.eSTC_UI_PK_KnightPKStart, on_pk_start, sig)
reg(packet.eSTC_UI_PK_KnightPKEnd, on_pk_end, sig)
reg(packet.eSTC_UI_PK_KnightPKUseBisha, on_bisha_used, sig)
reg(packet.eSTC_UI_Knight_List, on_get_knight, sig)
