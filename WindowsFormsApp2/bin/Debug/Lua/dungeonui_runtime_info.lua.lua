local remain_time = 0
local use_time = 0
local g_init_runtime_label = false
local color_type = {
  time_color_cfg = {
    next_color = 1440,
    score_per = 0,
    init_color = "ff00ff00",
    color = "ffff0000"
  },
  kill_color_cfg = {
    next_color = 120,
    score_per = 20,
    init_color = "ffff0000",
    color = "ff00ff00"
  },
  skill_color_cfg = {
    next_color = 10,
    score_per = 60,
    init_color = "ffff0000",
    color = "ff00ff00"
  },
  dead_color_cfg = {
    next_color = 2,
    score_per = -20,
    init_color = "ff00ff00",
    color = "ffff0000"
  }
}
g_init_runtime_info = false
function get_color(_type, _val)
  if _type == nil then
    return
  end
  if _val >= _type.next_color then
    return _type.color
  end
  return _type.init_color
end
function get_score_per(_type, _val)
  if _type == nil then
    return
  end
  return _type.score_per
end
function init_label()
  if g_init_runtime_info ~= false then
    return
  end
  local ref_kill = {
    color = color_type.kill_color_cfg.init_color,
    count = 0
  }
  kill_label:search("rb_text").mtf = ui_widget.merge_mtf(ref_kill, sys.format(ui.get_text("dungeonui|dungeon_kills")))
  local ref_skill = {
    color = color_type.skill_color_cfg.init_color,
    count = 0
  }
  skill_label:search("rb_text").mtf = ui_widget.merge_mtf(ref_skill, sys.format(ui.get_text("dungeonui|dungeon_skills")))
  local ref_dead = {
    color = color_type.dead_color_cfg.init_color,
    count = 0
  }
  dead_label:search("rb_text").mtf = ui_widget.merge_mtf(ref_dead, sys.format(ui.get_text("dungeonui|dungeon_dead_times")))
end
function show_runtime_label(bShow)
  remain_time_label.visible = not bShow
  time_label.visible = bShow
  kill_label.visible = bShow
  skill_label.visible = bShow
  dead_label.visible = bShow
  timer.suspended = not bShow
  remain_timer.suspended = bShow
end
function close_runtime_panel()
  ui_quest.ui_tracing.on_close_runtime_info()
  timer.suspended = true
  remain_timer.suspended = true
  g_init_runtime_label = false
end
function open_runtime_panel()
  if g_init_runtime_label ~= true then
    g_init_runtime_label = true
    ui_quest.ui_tracing.on_show_dungeon_runtime_info()
    init_label()
  end
end
function terminal_panel()
  if ui_quest ~= nil and ui_quest.ui_tracing ~= nil then
    close_runtime_panel()
  end
end
function show_ui(cmd, data)
  local show_type = data:get(packet.key.dungeon_runtime_info_show_type).v_int
  local show_time = 0
  if show_type == bo2.eDungeonRuntime_ShowType_RemainTime then
  elseif show_type == bo2.eDungeonRuntime_ShowType_Close then
    close_runtime_panel()
    g_init_runtime_info = false
  elseif show_type == bo2.eDungeonRuntime_ShowType_BingXueBao then
    bingxuebao_info(data)
  end
end
function HandleUpdateRuntimeInfo(cmd, data)
  local iKill = data:get(packet.key.dungeon_runtime_info_kill).v_int
  local iSkill = data:get(packet.key.dungeon_runtime_info_skill).v_int
  local kill_color = get_color(color_type.kill_color_cfg, iKill)
  local kill_score = get_score_per(color_type.kill_color_cfg, iKill) * iKill
  local skill_color = get_color(color_type.skill_color_cfg, iSkill)
  local skill_score = get_score_per(color_type.skill_color_cfg, iSkill) * iSkill
  local ref_kill = {color = kill_color, count = kill_score}
  kill_label:search("rb_text").mtf = ui_widget.merge_mtf(ref_kill, sys.format(ui.get_text("dungeonui|dungeon_kills")))
  local ref_skill = {color = skill_color, count = skill_score}
  skill_label:search("rb_text").mtf = ui_widget.merge_mtf(ref_skill, sys.format(ui.get_text("dungeonui|dungeon_skills")))
  if iKill ~= 0 or iSkill ~= 0 then
    g_init_runtime_info = true
  end
end
function HandleUpdateRuntimeTeamInfo(cmd, data)
  local iDead = data:get(packet.key.dungeon_runtime_info_dead).v_int
  if iDead > 0 then
    local dead_color = get_color(color_type.dead_color_cfg, iDead)
    local dead_score = get_score_per(color_type.dead_color_cfg, iDead) * iDead
    local ref_dead = {color = dead_color, count = dead_score}
    dead_label:search("rb_text").mtf = ui_widget.merge_mtf(ref_dead, sys.format(ui.get_text("dungeonui|dungeon_dead_times")))
  else
    local ref_dead = {
      color = color_type.dead_color_cfg.init_color,
      count = 0
    }
    dead_label:search("rb_text").mtf = ui_widget.merge_mtf(ref_dead, sys.format(ui.get_text("dungeonui|dungeon_dead_times")))
  end
end
function remain_timer_update(t)
  if t == nil then
    remain_time = remain_time - 1
  else
    remain_time = t
  end
  local h, m, s, v
  h = math.floor(remain_time / 3600)
  v = math.fmod(remain_time, 3600)
  m = math.floor(v / 60)
  s = math.fmod(v, 60)
  local ref_time = {
    _h = h,
    _m = m,
    _s = s
  }
  remain_time_label:search("rb_text").mtf = ui_widget.merge_mtf(ref_time, sys.format(ui.get_text("dungeonui|dungeon_begin_time")))
end
function on_remain_timer()
  remain_timer_update()
end
function on_timer()
  time_update()
end
function time_update(t)
  if t == nil then
    use_time = use_time + 1
  else
    use_time = t
  end
  local h, m, s, v
  h = math.floor(use_time / 3600)
  v = math.fmod(use_time, 3600)
  m = math.floor(v / 60)
  s = math.fmod(v, 60)
  local ref_time = {
    _h = h,
    _m = m,
    _s = s
  }
  ref_time.color = get_color(color_type.time_color_cfg, use_time)
  time_label:search("rb_text").mtf = ui_widget.merge_mtf(ref_time, sys.format(ui.get_text("dungeonui|dungeon_time")))
end
function update_bxb_info(cmd, data)
  update_bxb_num(cmd, data)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "dungeonui_runtime_info.packet_handle"
reg(packet.eSTC_UI_DungeonTime, show_ui, sig)
reg(packet.eSTC_UI_Dungeon_bxb, update_bxb_info, sig)
