c_anime_present = 1500
g_current_anime_present = c_anime_present
function init_anime()
  local player = bo2.player
  if sys.check(player) ~= true then
    return
  end
  g_anime.suspended = true
  local camp_id = player:get_atb(bo2.eAtb_Camp)
  local sword_persent = 0
  local blade_present = 0
  if camp_id == bo2.eCamp_Sword then
    sword_persent = 1
  else
    blade_present = 1
  end
  fg_blade_score_pic.svar.start = 360 * blade_present * 100
  fg_sword_score_pic.svar.start = 360 * sword_persent * 100
  g_current_anime_present = c_anime_present
  blade_core_pic.visible = false
  sword_core_pic.visible = false
  g_anime.suspended = false
end
function on_anime_visible(vis)
  if vis == true then
  else
    stop_anime()
  end
end
function playe_anime()
  init_anime()
end
function stop_anime()
  if sys.check(g_anime) then
    g_anime.suspended = true
  end
  execute_frame(1)
end
function execute_frame(frame_present)
  if sys.check(lb_blade_score_data) ~= true then
    return
  end
  if sys.check(bo2.player) ~= true then
    return
  end
  local sector_value = 0
  local blade_value = lb_blade_score_data.svar.value * frame_present
  local sword_value = lb_sword_score_data.svar.value * frame_present
  lb_blade_score_data.text = sys.format(L("%.1f%%"), blade_value)
  lb_sword_score_data.text = sys.format(L("%.1f%%"), sword_value)
  local sector_value = sword_value
  local camp_id = bo2.player:get_atb(bo2.eAtb_Camp)
  if camp_id == bo2.eCamp_Sword then
    sector_value = blade_value
  end
  local set_sector_persent = function(sector, value, anti_clock)
    local start = sector.svar.start
    local c_value = 0
    if start == nil then
      return
    end
    if start > 0 then
      c_value = 36000 * value / 10000
    else
      c_value = 36000 * value / 10000
    end
    if anti_clock == true then
      sector.angle_b = -c_value
      sector.angle_e = 0
    else
      sector.angle_e = c_value
    end
  end
  set_sector_persent(fg_blade_score_pic, blade_value, true)
  set_sector_persent(fg_sword_score_pic, sword_value, false)
  fg_blade_score_pic.visible = true
  fg_sword_score_pic.visible = true
  if frame_present >= 1 then
    if blade_value >= sword_value then
      blade_core_pic.visible = true
    else
      sword_core_pic.visible = true
    end
  end
  g_current_anime_present = g_current_anime_present - g_anime.period
end
function execute()
  if g_current_anime_present <= 0 then
    stop_anime()
    return
  end
  local frame_present = (c_anime_present - g_current_anime_present) / c_anime_present
  execute_frame(frame_present)
end
function on_persent_anime(timer)
  if sys.check(w_main) ~= true or w_main.visible ~= true then
    return
  end
  execute()
end
