function on_timer(t)
end
local cfg_enable = true
local bind_sig = SHARED("ui_qbar.ui_hide_anim.bind_on_visible")
function play(w_src, w_dst)
  w_hide_anim.svar.target = w_src
  w_hide_anim:frame_clear()
  w_hide_anim.visible = true
  local bs = w_dst.size
  local ws = w_src.size
  local pos = w_dst:control_to_window(ui.point(0, 0)) + bs * 0.5
  local src = w_src.offset + ws * 0.5
  local dis = pos - src
  local tick = math.sqrt(math.sqrt(dis.x * dis.x + dis.y * dis.y)) * 14
  if tick < 100 then
    tick = 100
  end
  local init_pos = w_src:control_to_window(ui.point(0, 0)) - w_src.offset
  f = w_hide_anim:frame_insert(tick, w_src)
  f.color1 = "CCFFFFFF"
  f.color2 = "99FFFFFF"
  f:set_scale1(1, 1)
  f:set_scale2(bs.x / ws.x, bs.y / ws.y)
  f:set_translate1(init_pos.x, init_pos.y)
  f:set_translate2(dis.x, dis.y)
  f = w_hide_anim:frame_insert(100, w_src)
  f.color1 = "99FFFFFF"
  f.color2 = "00FFFFFF"
  f:set_scale1(bs.x / ws.x, bs.y / ws.y)
  f:set_scale2(bs.x / ws.x, bs.y / ws.y)
  f:set_translate1(dis.x, dis.y)
  f:set_translate2(dis.x, dis.y)
end
function bind(w, btn, chk_fn, anim_fn, is_quest)
  local function on_visible(ctrl, vis)
    if not cfg_enable then
      return
    end
    if not sys.check(w) or not sys.check(btn) then
      return
    end
    if chk_fn ~= nil and not chk_fn() then
      return
    end
    if vis then
      if w_hide_anim.svar.target == w then
        w_hide_anim:frame_clear()
        w_hide_anim.visible = false
      end
      return
    end
    w_hide_anim.svar.target = w
    w_hide_anim:frame_clear()
    w_hide_anim.visible = true
    if anim_fn ~= nil then
      anim_fn(w_hide_anim, w, btn)
      return
    end
    local bs = btn.size
    local ws = w.size
    local pos = btn:control_to_window(ui.point(0, 0)) + bs * 0.5
    local src = w.offset + ws * 0.5
    local dis = pos - src
    local tick = math.sqrt(math.sqrt(dis.x * dis.x + dis.y * dis.y)) * 14
    if tick < 100 then
      tick = 100
    end
    if is_quest then
      local f = w_hide_anim:frame_insert(200, w)
      f.color1 = "FFFFFFFF"
      f.color2 = "CCFFFFFF"
      f:set_scale1(1, 1)
      f:set_scale2(0.25, 0.25)
      f = w_hide_anim:frame_insert(tick, w)
      f.color1 = "CCFFFFFF"
      f.color2 = "99FFFFFF"
      f:set_scale1(0.25, 0.25)
      f:set_scale2(bs.x / ws.x, bs.y / ws.y)
      f:set_translate2(dis.x, dis.y)
    else
      local f = w_hide_anim:frame_insert(200, w)
      f.color1 = "FFFFFFFF"
      f.color2 = "CCFFFFFF"
      f:set_scale1(1, 1)
      f:set_scale2(bs.x * 2 / ws.x, bs.y * 2 / ws.y)
      f = w_hide_anim:frame_insert(tick, w)
      f.color1 = "CCFFFFFF"
      f.color2 = "99FFFFFF"
      f:set_scale1(bs.x * 2 / ws.x, bs.y * 2 / ws.y)
      f:set_scale2(bs.x / ws.x, bs.y / ws.y)
      f:set_translate2(dis.x, dis.y)
    end
    f = w_hide_anim:frame_insert(100, w)
    f.color1 = "99FFFFFF"
    f.color2 = "00FFFFFF"
    f:set_scale1(bs.x / ws.x, bs.y / ws.y)
    f:set_scale2(bs.x / ws.x, bs.y / ws.y)
    f:set_translate1(dis.x, dis.y)
    f:set_translate2(dis.x, dis.y)
  end
  if w ~= nil then
    w:insert_on_visible(on_visible, bind_sig)
  end
end
function update_cfg()
  cfg_enable = ui_setting.ui_game.cfg_def.hide_anim.value == L("1")
end
function central_check()
  return not ui_central.is_mutex_window_visible()
end
function reg()
  update_cfg()
  bind(ui_personal.w_personal, ui_qbar.qlink_btn.personal)
  bind(ui_item.w_item, ui_qbar.qlink_btn.item)
  bind(ui_quest.w_main, ui_qbar.qlink_btn.quest)
  bind(ui_skill.w_skill, ui_qbar.qlink_btn.skill)
  bind(gx_match_win, ui_qbar.qlink_btn.arena)
  bind(ui.find_control("$frame:md"), ui_qbar.qlink_btn.colect)
  bind(ui.find_control("$frame:ui_guild"), ui_qbar.qlink_btn.guild)
  bind(ui.find_control("$frame:im_main"), ui_qbar.qlink_btn.friend)
  bind(ui.find_control("$frame:supermarket2"), ui_qbar.qlink_btn.shop)
  bind(ui_central.w_central, ui_qbar.qlink_btn.setting, central_check)
  bind(ui_ridepet.w_ridepet, ui_qbar.qlink_btn.ridepet)
  bind(ui.find_control("$frame:ui_mail"), ui_mail.gx_toggle)
  bind(ui.find_control("$frame:master_quest"), ui_quest.ui_tracing.w_quest_tracing, nil, nil, true)
  bind(ui.find_control("$frame:tip_quest"), ui_quest.ui_tracing.w_quest_tracing, nil, nil, true)
  bind(ui.find_control("$frame:milestone_quest"), ui_quest.ui_tracing.w_quest_tracing, nil, nil, true)
  bind(ui.find_control("$frame:complete_quest"), ui_quest.ui_tracing.w_quest_tracing, nil, nil, true)
  bind(ui.find_control("$frame:come_true"), ui_mail.gx_toggle, nil, nil, true)
  local xinshou_btn = ui_qbar.w_qlink:search("xinshou")
  bind(ui.find_control("$frame:xinshou"), xinshou_btn)
  bind(ui_warrior_arena.w_main_career, ui_warrior_arena.ls_wa_career)
end
