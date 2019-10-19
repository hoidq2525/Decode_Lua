local g_chgct = 0
local g_lastApptime = 0
local lastDelay = 0
local g_get_logicPing = 0
local g_ping = 0
local g_logic_ping, g_net1, g_net2, g_net3, g_net
local g_net_check_count = 0
local arr_bar_color = {
  "b62909",
  "b17008",
  "cbb718",
  "97ca0e",
  "1aae2b"
}
local g_renown_clicked = false
local function update_delay_bar(net_ping)
  local get_delay_level = function(ping)
    if ping >= 0 and ping < 150 then
      return 5
    elseif ping >= 150 and ping < 300 then
      return 4
    elseif ping >= 300 and ping < 600 then
      return 3
    elseif ping >= 600 and ping < 1500 then
      return 2
    elseif ping >= 1500 then
      return 1
    elseif ping < 0 then
      return 0
    end
  end
  local delay_level = get_delay_level(net_ping)
  if delay_level == 0 then
    w_red_cross.visible = true
    w_bar.visible = false
  else
    w_red_cross.visible = false
    w_bar.visible = true
    w_bar.color = ui.make_color(arr_bar_color[delay_level])
    w_bar.dx = 3 * delay_level
  end
end
function on_timer2()
  local delay = ui.get_delay()
  local ping = (delay + lastDelay) / 2
  ping = math.floor(ping)
  update_delay_bar(ping)
  if ping == -1 then
    g_ping = ui.get_text("portrait|tip_offline")
  else
    g_ping = tostring(ping)
  end
  lastDelay = delay
  local net_var = ui.get_net()
  local function make_net(i)
    local v = net_var[i]
    if v == nil then
      return nil
    end
    return {
      ping = v[1],
      good = v[2]
    }
  end
  g_net1 = make_net(1)
  g_net2 = make_net(2)
  g_net3 = make_net(3)
  g_net = net_var[0]
  check_ping()
end
local check_ping_ok = function(s, n)
  if s == n then
    return false
  end
  local nping = n.ping
  if nping < 0 then
    return false
  end
  local sping = s.ping
  if sping < 0 then
    return true
  end
  return nping < sping
end
function check_ping()
  if not common_tip_check() then
    w_tip_note_net.visible = false
    g_net_check_count = 0
    return
  end
  if w_tip_note.visible then
    w_tip_note_net.visible = false
    g_net_check_count = 0
    return
  end
  local s
  if g_net == 1 then
    s = g_net1
  elseif g_net == 2 then
    s = g_net2
  elseif g_net == 3 then
    s = g_net3
  end
  if s == nil then
    w_tip_note_net.visible = false
    g_net_check_count = 0
    return
  end
  if s.ping < 500 and 0 <= s.ping then
    w_tip_note_net.visible = false
    g_net_check_count = 0
    return
  end
  if check_ping_ok(s, g_net1) or check_ping_ok(s, g_net2) or check_ping_ok(s, g_net3) then
    g_net_check_count = g_net_check_count + 1
    if g_net_check_count >= 15 then
      g_net_check_count = 0
      if ui_setting.ui_game.cfg_def.net_ping_note.value == L("1") then
        w_tip_note_net.size = ui.point(240, 400)
        w_tip_note_net:search("rb_text").mtf = ui.get_text("setting|sg_note_tip_net_ping")
        w_tip_note_net:tune_y("rb_text")
        w_tip_note_net.visible = true
        local pos = w_net_delay_flicker.abs_area
        local x = (pos.x1 + pos.x2) * 0.5 - 28
        if x < 0 then
          x = 0
        end
        w_tip_note_net.offset = ui.point(x, pos.y2)
      end
    end
  end
end
function on_note_net_none_click(btn)
  w_tip_note_net.visible = false
  local on_msg = function(msg)
    if msg.result == 0 then
      return
    end
    local w = ui_setting.ui_game.w_top
    if sys.check(w) then
      w.visible = false
    end
    local cfg_def = ui_setting.ui_game.cfg_def
    cfg_def.net_ping_note.value = L("0")
    local v = bo2.get_config()
    v:set("net_ping_note", L("0"))
    ui_setting.ui_game.save_config()
  end
  ui_widget.ui_msg_box.show_common({
    text = ui.get_text("setting|msg_net_ping_note"),
    callback = on_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  })
end
function on_note_net_set_click(btn)
  w_tip_note_net.visible = false
  ui_setting.ui_game.show_top("tab_video")
end
function on_timer3()
  local ping = ui.get_delay()
  lastDelay = ping
  update_delay_bar(ping)
  if ping == -1 then
    g_ping = ui.get_text("portrait|tip_offline")
  else
    g_ping = tostring(ping)
  end
  local v = sys.variant()
  v:set(packet.key.ping_test, "1")
  bo2.send_variant(packet.eCTS_UI_PingTest, v)
  g_get_logicPing = 1
end
function update_logic_ping(cmd, data)
  local curApptime = data:get(packet.key.ping_test).v_int
  if g_get_logicPing == 1 then
    g_lastApptime = curApptime
    local v = sys.variant()
    v:set(packet.key.ping_test, "1")
    bo2.send_variant(packet.eCTS_UI_PingTest, v)
    g_get_logicPing = 2
  elseif g_get_logicPing == 2 then
    local logic_ping = (curApptime - g_lastApptime) / 2
    logic_ping = math.floor(logic_ping)
    g_logic_ping = tostring(logic_ping)
    g_lastApptime = curApptime
    g_get_logicPing = 0
  else
    g_lastApptime = curApptime
  end
end
function on_init_by_lang()
  if ui_widget.get_define_int(50028) == 1 then
    w_flicker_cross_line.visible = false
  else
    w_flicker_cross_line.visible = true
  end
end
function on_init()
  w_main.visible = true
  local w = rawget(_M, "w_tip_note")
  if not sys.check(w) then
    w = ui.create_control(ui_main.w_top, "panel")
    w_tip_note = w
    w:load_style("$frame/net_delay/net_delay.xml", "tip_note")
  end
  w = rawget(_M, "w_tip_note_net")
  if not sys.check(w) then
    w = ui.create_control(ui_main.w_top, "panel")
    w_tip_note_net = w
    w:load_style("$frame/net_delay/net_delay.xml", "tip_note_net")
  end
  if bo2.IsOpenIsh() then
    w_insidehang_btn.visible = true
  end
  g_temp_note_low_cfg = true
  g_temp_note_hide_player = true
  g_net_check_count = 0
  local define = bo2.gv_define:find(1096)
  if define ~= nil and define.value ~= L("1") then
    ui_net_delay.w_safe_btn.visible = false
  end
end
function on_net_delay_tip_show(tip)
  local stk = sys.mtf_stack()
  stk:merge({
    fps = ui.get_fps(),
    ping = g_ping,
    logic_ping = g_logic_ping
  }, ui.get_text("setting|tip_net_delay_info"))
  local function add_net(net, idx)
    if net == nil then
      return
    end
    if g_net == idx then
      stk:raw_push([[

<c+:00FF00>]])
    else
      stk:raw_push([[

<c+:FFFF00>]])
    end
    stk:merge({
      net = sys.format("%dms,%d%%", net.ping, net.good)
    }, ui.get_text("setting|net_" .. idx))
  end
  add_net(g_net1, 1)
  add_net(g_net2, 2)
  add_net(g_net3, 3)
  ui_tool.ctip_show(tip.owner, stk)
end
function on_net_delay_click(btn)
  ui_setting.ui_game.show_default_menu(btn, true)
end
function chg_vis()
  g_chgct = g_chgct + 1
  if g_chgct > 1 then
    g_chgct = 0
    w_main.visible = not w_main.visible
  end
end
function hide_player_reset()
  bo2.SetPlayerDisplay(2)
  ui_net_delay.hide_player_update()
end
function on_hide_player_make_tip(tip)
  local t = bo2.GetPlayerDisplay()
  local text
  if t == 0 then
    text = ui.get_text("setting|tip_hide_player_type0")
  elseif t == 3 then
    text = ui.get_text("setting|tip_hide_player_type3")
  else
    text = ui.get_text("setting|tip_hide_player_type_")
  end
  local v = ui_setting.ui_input.op_def.hide_player.hotkey
  local k = v:get_cell(0).text
  if k.size == 0 then
    k = v:get_cell(1).text
  end
  if 0 < k.size then
    text = sys.format([[
%s
%s]], text, ui_widget.merge_mtf({k = k}, ui.get_text("setting|tip_hide_player_key")))
  end
  ui_widget.tip_make_view(tip.view, text)
end
function on_hide_player_click()
  local t = bo2.GetPlayerDisplay()
  local player = bo2.player
  if player ~= nil then
    local fs = player:get_flag_objmem(bo2.eFlagObjMemory_FightState)
    if fs ~= 0 then
      t = 2
      bo2.SetPlayerDisplay(t)
      ui_tool.note_insert_normal(ui.get_text("setting|note_hide_player_type_none"))
      return
    end
  end
  if t == 0 then
    t = 2
    ui_tool.note_insert_normal(ui.get_text("setting|note_hide_player_type_"))
  elseif t == 3 then
    t = 0
    ui_tool.note_insert_normal(ui.get_text("setting|note_hide_player_type0"))
  else
    t = 3
    ui_tool.note_insert_normal(ui.get_text("setting|note_hide_player_type3"))
  end
  bo2.SetPlayerDisplay(t)
  hide_player_update()
end
local hide_player_tick = 0
local last_fps_tick = 0
local note_show_tick = 0
local note_btn_sig = "ui_net_delay.on_note_btn_click"
function on_note_visible(ctrl, vis)
  local var = w_tip_note.svar
  local btn = var.btn_hook
  if btn == nil then
    return
  end
  if vis then
    btn.parent.suspended = false
  else
    btn.parent.suspended = true
    var.btn_hook = nil
  end
end
local function on_note_btn_click(btn)
  btn:remove_on_click(note_btn_sig)
  local svar = w_tip_note.svar
  if btn == svar.btn_hook then
    w_tip_note.visible = false
  end
end
function show_note(data)
  w_tip_note.size = ui.point(240, 400)
  w_tip_note:search("rb_text").mtf = data.text
  w_tip_note:tune_y("rb_text")
  local btn = data.button
  local svar = w_tip_note.svar
  svar.btn_hook = btn
  btn:insert_on_click(on_note_btn_click, note_btn_sig)
  svar.cfg = data.cfg
  w_tip_note.visible = true
  local pos = btn.abs_area
  local x = (pos.x1 + pos.x2) * 0.5 - 28
  if x < 0 then
    x = 0
  end
  w_tip_note.offset = ui.point(x, pos.y2)
end
function on_note_close_click(btn)
  w_tip_note.visible = false
end
function on_note_none_click(btn)
  w_tip_note.visible = false
  local svar = w_tip_note.svar
  local cfg = svar.cfg
  if cfg == nil then
    return
  end
  local function on_msg(msg)
    if msg.result == 0 then
      return
    end
    local w = ui_setting.ui_game.w_top
    if sys.check(w) then
      w.visible = false
    end
    local cfg_def = ui_setting.ui_game.cfg_def
    cfg_def[cfg].value = L("0")
    local v = bo2.get_config()
    v:set(cfg, L("0"))
    ui_setting.ui_game.save_config()
  end
  ui_widget.ui_msg_box.show_common({
    text = ui.get_text("setting|msg_" .. cfg),
    callback = on_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  })
end
local check_is_low_cfg = function()
  local cfg_def = ui_setting.ui_game.cfg_def
  for n, v in pairs(ui_setting.ui_game.key_cfg_level) do
    local t = cfg_def[n].value.v_int
    if v < t then
      return false
    end
  end
  return true
end
function on_note_temp_click(btn)
  w_tip_note.visible = false
  local svar = w_tip_note.svar
  if svar.cfg == "low_cfg_note" then
    g_temp_note_low_cfg = false
  elseif svar.cfg == "hide_player_note" then
    g_temp_note_hide_player = false
  end
end
local hide_player_note_visible = function()
  if not w_tip_note.visible then
    return false
  end
  return w_tip_note.svar.cfg == "hide_player_note"
end
function common_tip_check()
  if not ui.main_window_is_focus() then
    return false
  end
  local scn = bo2.scn
  if not sys.check(scn) then
    return false
  end
  local player = bo2.player
  if not sys.check(player) or player:get_flag_objmem(bo2.eFlagObjMemory_FightState) == 1 then
    return false
  end
  if ui_loading.w_top.visible then
    return false
  end
  return true
end
function on_hide_player_timer(t)
  w_npc_drop_btn.visible = ui_tool.tool_cfg_inner_utility
  local tick = sys.tick()
  if not w_hide_player_flicker.suspended then
    local d = sys.dtick(tick, hide_player_tick)
    if d >= 5000 and not hide_player_note_visible() then
      w_hide_player_flicker.suspended = true
    end
  end
  if not common_tip_check() then
    w_tip_note.visible = false
    last_fps_tick = tick
    return
  end
  if w_tip_note_net.visible then
    w_tip_note.visible = false
    last_fps_tick = tick
    return
  end
  local fps = ui.get_fps()
  if fps >= 20 then
    last_fps_tick = tick
    if w_tip_note.visible and sys.dtick(sys.tick(), note_show_tick) > 10000 then
      w_tip_note.visible = false
    end
    return
  end
  note_show_tick = sys.tick()
  if w_tip_note.visible then
    last_fps_tick = tick
    return
  end
  if not w_net_delay.enable then
    last_fps_tick = tick
    return
  end
  local d = sys.dtick(tick, last_fps_tick)
  if d < 20000 then
    return
  end
  local player_count = bo2.scn:GetScnObjCount(bo2.eScnObjKind_Player)
  if player_count > 20 and g_temp_note_hide_player and ui_setting.ui_game.cfg_def.hide_player_note.value == L("1") and bo2.GetPlayerDisplay() == 2 then
    show_note({
      cfg = "hide_player_note",
      text = ui.get_text("setting|sg_note_tip_hide_player"),
      button = w_hide_player_btn
    })
    return
  end
  if not g_temp_note_low_cfg or ui_setting.ui_game.cfg_def.low_cfg_note.value == L("1") then
  end
end
function hide_player_toggle()
  on_hide_player_click()
  hide_player_tick = sys.tick()
  w_hide_player_flicker.suspended = false
end
function hide_player_update()
  last_fps_tick = sys.tick()
  local btn = w_hide_player_btn
  local t = bo2.GetPlayerDisplay()
  local pic = btn:search("pic")
  if t == 0 then
    pic.image = "$image/qbar/qbar_lt.png|75,1,24,88"
    btn.tip.text = ""
  elseif t == 3 then
    pic.image = "$image/qbar/qbar_lt.png|49,1,24,88"
  else
    pic.image = "$image/qbar/qbar_lt.png|101,0,27,108"
    return
  end
  if hide_player_note_visible() then
    w_tip_note.visible = false
  end
end
function on_hide_player_init(btn)
  hide_player_update()
end
function on_init_camera_mode()
  camera_mode_update()
end
function on_camera_mode_make_tip(tip)
  local v_data = bo2.get_single_config(L("trangle_camera")).v_int
  local v_data_enable = bo2.get_single_config(L("trangle_camera_enable")).v_int
  local get_camera_mode_type = function(v_data)
    local text
    if v_data == 3 then
      text = ui.get_text("central|follow_model")
    elseif v_data == 1 then
      text = ui.get_text(L("central|focus_model"))
    elseif v_data == 2 then
      text = ui.get_text(L("central|symmetrical_model"))
    end
    return text
  end
  local camera_type_text = get_camera_mode_type(v_data)
  local text
  if v_data_enable == 0 then
    text = "setting|msg_camera_type_close"
  else
    text = "setting|msg_camera_type_mode"
  end
  text = ui_widget.merge_mtf({mode = camera_type_text}, ui.get_text(text))
  ui_widget.tip_make_view(tip.view, text)
end
function camera_mode_update()
  local v_data = bo2.get_single_config(L("trangle_camera")).v_int
  local v_data_enable = bo2.get_single_config(L("trangle_camera_enable")).v_int
  ui.log(v_data .. " " .. v_data_enable)
  if v_data == 0 then
    w_camera_mode_flicker.visible = false
    w_camera_mode_flicker_1.visible = false
    return
  else
    w_camera_mode_flicker.visible = true
    w_camera_mode_flicker_1.visible = true
  end
  if v_data_enable == 0 then
    local pic = w_camera_mode_btn:search("pic")
    pic.image = "$image/qbar/camera_disable.png|0,0,25,128"
    w_camera_mode_flicker_1.visible = false
  elseif v_data == 3 or v_data == 1 then
    local pic = w_camera_mode_btn:search("pic")
    pic.image = "$image/qbar/camera_data.png|0,0,25,128"
    w_camera_mode_flicker_1.visible = false
  elseif v_data == 2 then
    local pic = w_camera_mode_btn_1:search("pic")
    pic.image = "$image/qbar/camera_data.png|28,0,34,128"
    w_camera_mode_flicker.visible = false
  end
end
function on_camera_mode_click(btn)
  local v_data = bo2.get_single_config(L("trangle_camera_enable")).v_int
  if v_data == 0 then
    on_enable_camera_auto_move()
  else
    on_disable_camera_auto_move()
  end
  camera_mode_update()
end
function on_setting_trangle_camera()
  camera_mode_update()
end
function on_enable_camera_auto_move()
  local v_data = bo2.get_single_config(L("trangle_camera_enable")).v_int
  if v_data == 0 then
    bo2.set_single_config(L("trangle_camera_enable"), 1)
    camera_mode_update()
  end
end
function on_disable_camera_auto_move()
  local v_data = bo2.get_single_config(L("trangle_camera_enable")).v_int
  if v_data == 1 then
    bo2.set_single_config(L("trangle_camera_enable"), 0)
    camera_mode_update()
  end
end
function on_make_run_tip(tip)
  local v = ui_setting.ui_input.op_def.run.hotkey
  local k = v:get_cell(0).text
  if k.size == 0 then
    k = v:get_cell(1).text
  end
  if bo2.player == nil then
    return
  end
  local mode = bo2.player:get_flag_objmem(bo2.eFlagObjMemory_Run)
  local speed = bo2.player:get_atb(bo2.eAtb_MoveSpeedMax)
  local text1, text2
  if mode == 0 then
    text1 = ui.get_text("setting|move_type_walk")
    text2 = ui.get_text("setting|move_type_run")
  elseif mode == 1 then
    text1 = ui.get_text("setting|move_type_run")
    text2 = ui.get_text("setting|move_type_walk")
  end
  if 0 < k.size then
    local arg = sys.variant()
    arg:set("current", text1)
    arg:set("speed", speed)
    arg:set("hotkey", k)
    arg:set("next", text2)
    local level_text = sys.mtf_merge(arg, ui.get_text("setting|tip_move_state1"))
    ui_widget.tip_make_view(tip.view, level_text)
    return
  end
  local arg = sys.variant()
  arg:set("current", text1)
  arg:set("speed", speed)
  arg:set("next", text2)
  local level_text = sys.mtf_merge(arg, ui.get_text("setting|tip_move_state2"))
  ui_widget.tip_make_view(tip.view, level_text)
end
function on_show_npc_drop(btn)
  ui_npcfunc.ui_npc_drop.on_show_npc_drop(btn)
end
function on_show_renown(btn)
  ui_personal.ui_renown.on_show_renown(btn)
  w_renown_tips.visible = false
  g_renown_clicked = true
end
function on_renown_tips_init()
  w_renown_tips:search("richbox").mtf = sys.format(L("<handson:,5,%s>"), ui.get_text("knight|renown_on"))
end
function on_renown_tips_timer(t)
  if w_renown_tips.visible and sys.check(w_renown_btn) then
    local pos = w_renown_btn.abs_area
    w_renown_tips.offset = ui.point((pos.x1 + pos.x2) * 0.5 - 28, pos.y2)
  end
end
function on_show_ranklist(btn)
  ui_ranklist.on_show_ranklist(btn)
end
function on_hotkey_click(btn)
  ui_qbar.ui_keyboard.toggle()
end
function on_show_insidehang(btn)
  ui_InSideHang.on_show_insidehang(btn)
end
function on_crossline_click(btn)
  ui_camp_repute.set_visible()
end
function on_self_enter()
  on_init_camera_mode()
end
function on_level_update(lv)
  local p_lv = bo2.player:get_atb(bo2.eAtb_Level)
  w_renown_btn.visible = p_lv >= 15
  if p_lv == 15 and w_renown_btn.visible == true and g_renown_clicked == false then
    w_renown_tips.visible = true
  end
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_net_delay.packet_handle"
reg(packet.eSTC_UI_PingTest, update_logic_ping, sig)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_disable_trangle_camera, on_disable_camera_auto_move, "ui_net_delay.on_disable_camera_auto_move")
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enable_trangle_camera, on_enable_camera_auto_move, "ui_net_delay.on_disable_camera_auto_move")
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_net_delay.on_self_enter")
