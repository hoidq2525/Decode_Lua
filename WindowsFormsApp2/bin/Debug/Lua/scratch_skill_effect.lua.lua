local g_top_step_size = 4
local g_top_min_size = 48
local g_top_cur_size = g_top_min_size
local g_empty_shortcut_idx = 78
local fade_in_uri = "$frame/skill/transition.xml|scratch_skill_in"
local fade_out_uri = "$frame/skill/transition.xml|scratch_skill_out"
function set_hud_break_mouse(bool_var)
  local top_main = ui.find_control("$phase:main")
  top_main.break_mouse = bool_var
end
function on_card_fade_stop()
  if w_scratch_skill_box.alpha == 0 then
    w_scratch_skill_box:search("skill_card").index = g_empty_shortcut_idx
  end
end
function reset_effect()
  for i, v in ipairs(scratch_particle_ctrl) do
    if v.visible then
      v.visible = false
    else
      break
    end
  end
end
function on_particle_timer(ctrl)
  ctrl.owner.visible = false
  reset_effect()
end
local function show_scratch_skill_box(cmd, data)
  w_scratch_skill_box:search("skill_card").index = g_empty_shortcut_idx
  local box_fader = w_scratch_skill_box
  box_fader:reset(box_fader.alpha, 1, 300)
  set_hud_break_mouse(true)
  w_scratch_skill_top.visible = true
  reset_effect()
end
local gen_scratch_skill_box = function(cmd, data)
  local cur_idx = data:get(packet.key.scratch_particle_cur_size).v_int
  local x1 = 0
  local y1 = 0
  local x2 = 0
  local y2 = 0
  local skill_track_id = -1
  local function make_hide_anim(anim, w, btn)
    local bs = btn.size
    local pos = btn:control_to_window(ui.point(0, 0)) + bs * 0.5
    local ws = ui.point(x2 - x1, y2 - y1)
    local src = ui.point((x1 + x2) * 0.5, (y1 + y2) * 0.5)
    local dis = pos - src
    local tick = math.sqrt(math.sqrt(dis.x * dis.x + dis.y * dis.y)) * 14
    if tick < 100 then
      tick = 100
    end
    if skill_track_id == -1 then
      local f = anim:frame_insert(400, w)
      f.color1 = "FFFFFFFF"
      f.color2 = "00FFFFFF"
      f:set_origin(src.x, src.y)
      f:set_scale1(1, 1)
      f:set_scale2(0.8, 0.8)
      return
    end
    local f = anim:frame_insert(200, w)
    f.color1 = "FFFFFFFF"
    f.color2 = "CCFFFFFF"
    f:set_origin(src.x, src.y)
    f:set_scale1(1, 1)
    f:set_scale2(bs.x * 2 / ws.x, bs.y * 2 / ws.y)
    f = anim:frame_insert(tick, w)
    f.color1 = "CCFFFFFF"
    f.color2 = "99FFFFFF"
    f:set_origin(src.x, src.y)
    f:set_scale1(bs.x * 2 / ws.x, bs.y * 2 / ws.y)
    f:set_scale2(bs.x / ws.x, bs.y / ws.y)
    f:set_translate2(dis.x, dis.y)
    f = anim:frame_insert(100, w)
    f.color1 = "99FFFFFF"
    f.color2 = "00FFFFFF"
    f:set_origin(src.x, src.y)
    f:set_scale1(bs.x / ws.x, bs.y / ws.y)
    f:set_scale2(bs.x / ws.x, bs.y / ws.y)
    f:set_translate1(dis.x, dis.y)
    f:set_translate2(dis.x, dis.y)
  end
  if cur_idx > 0 then
    local v = scratch_particle_ctrl[1]
    x1 = v.x
    y1 = v.y
    x2 = x1 + v.dx
    y2 = y1 + v.dy
    for i = 2, cur_idx do
      v = scratch_particle_ctrl[i]
      local tx1 = v.x
      local ty1 = v.y
      local tx2 = tx1 + v.dx
      local ty2 = ty1 + v.dy
      if x1 > tx1 then
        x1 = tx1
      end
      if x2 < tx2 then
        x2 = tx2
      end
      if y1 > ty1 then
        y1 = ty1
      end
      if y2 < ty2 then
        y2 = ty2
      end
    end
  end
  skill_track_id = data:get(packet.key.scratch_skill_track_id).v_int
  if skill_track_id ~= -1 then
    local list_id = bo2.gv_scratch_skill_track:find(skill_track_id).list_id
    local shortcut_idx = ui_skill.scratch_skill_edit_ctrl[list_id]:search("skill_card").index
    w_scratch_skill_box:search("skill_card").index = shortcut_idx
  end
  ui_qbar.ui_hide_anim.bind(w_scratch_skill_top, w_scratch_skill_box, nil, make_hide_anim)
  w_scratch_skill_top.visible = false
end
local function gen_scratch_particle_effect(cmd, data)
  local cur_pos_x = data:get(packet.key.scratch_cur_x).v_int
  local cur_pos_y = data:get(packet.key.scratch_cur_y).v_int
  local cur_idx = data:get(packet.key.scratch_particle_cur_size).v_int
  local particle_panel = scratch_particle_ctrl[cur_idx]
  particle_panel.visible = true
  particle_panel.offset = ui.point(cur_pos_x - g_top_min_size / 2, cur_pos_y - g_top_min_size / 2)
end
local release_skill = function(cmd, data)
  local box_fader = w_scratch_skill_box
  box_fader:reset(box_fader.alpha, 0, 300)
  set_hud_break_mouse(false)
  local shortcut_idx = w_scratch_skill_box:search("skill_card").index
  ui_shortcut.shortcut_use(shortcut_idx)
end
function on_init()
  w_scratch_skill_box:reset(w_scratch_skill_box.alpha, 0, 0)
  local ctrl_type = SHARED("picture")
  local sty_uri = SHARED("$frame/skill/scratch_skill_effect.xml")
  local sty_name = SHARED("scratch_particle")
  local parent = w_scratch_skill_top
  scratch_particle_ctrl = {}
  for i = 1, bo2.SCRATCH_SKILL_PARTICLE_MAX do
    scratch_particle_ctrl[i] = ui.create_control(parent, ctrl_type)
    scratch_particle_ctrl[i]:load_style(sty_uri, sty_name)
  end
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_scratch_skill_effect.packet_handle"
reg(packet.eSTC_UI_ShowScratchSkillBox, show_scratch_skill_box, sig)
reg(packet.eSTC_UI_GenScratchSkillBox, gen_scratch_skill_box, sig)
reg(packet.eSTC_UI_GenScratchParticleEffect, gen_scratch_particle_effect, sig)
reg(packet.eSTC_Scratch_Skill_Release, release_skill, sig)
