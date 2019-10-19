function on_close_click(btn)
  wnd_close(btn.topper)
end
function on_border_visible(ctrl, vis)
end
function on_show_game_click(btn)
  wnd_close(btn.topper)
  ui.main_window_show(true)
end
function wnd_close(w)
  w.visible = false
  w:post_release()
end
local notice_timeout_def = 20
local notice_timeout_min = 5
local notice_timeout_max = 60
local notice_post_period = 2000
function show_notice(data)
  local def = ui_setting.ui_game.cfg_def.popup_notice.value
  if def == L("0") then
    return
  end
  if data.sound == nil then
    data.sound = L("$sound/im_msg.wav")
  end
  local p = ui.create_control(NULL, "panel")
  p:load_style("$widget/wnd.xml", "wnd_notice")
  p.visible = false
  p.svar.notice_data = data
  if post_notice(p, data) then
    return
  end
  do_show_notice(p, data)
end
function post_notice(p, data)
  if data.force_show then
    return false
  end
  if not ui.main_window_is_focus() then
    return false
  end
  data.post_tick = sys.tick()
  if ui_popo then
    data.work_panel = ui_popo.m_work_panel
  end
  return true
end
function do_show_notice(p, data)
  data.mouse_tick = sys.tick()
  local timeout = data.timeout
  if timeout == nil then
    data.timeout = 20
  elseif timeout < notice_timeout_min then
    timeout = notice_timeout_min
  elseif timeout > notice_timeout_max then
    timeout = notice_timeout_max
  end
  local title = data.title
  if title == nil then
    title = ui.get_text("common|wnd_title")
  end
  p:search("lb_title").text = title
  local player = bo2.player
  if player ~= nil then
    p:search("player_info").visible = true
    p:search("player_name").text = ui_widget.merge_mtf({
      n = player.name
    }, ui.get_text("common|wnd_recv_msg"))
    p:search("player_icon").image = ui_portrait.make_icon_uri(player)
  end
  local rb = p:search("rb_text")
  rb.mtf = data.text
  p:search("lb_text").text = rb.text
  p:tune("lb_text")
  if p.dx < 220 then
    p.dx = 220
  end
  if p.dy < 180 then
    p.dy = 180
  end
  local w = p:find_plugin("window")
  w:make_popup_position()
  p.visible = true
  if #data.sound > 0 then
    ui.play_sound(data.sound)
  end
end
function on_notice_timer(timer)
  local p = timer.owner
  local data = p.svar.notice_data
  if data.keep_show == nil and ui.main_window_is_focus() then
    wnd_close(p)
  end
  local post_tick = data.post_tick
  if post_tick ~= nil then
    local d = sys.tick() - post_tick
    if d > notice_post_period then
      local wp = data.work_panel
      data.post_tick = nil
      if wp ~= nil and sys.check(wp) and not ui.main_window_is_focus() then
        do_show_notice(p, data)
        return
      end
      wnd_close(p)
    end
    return
  end
  if p.inner_hover then
    if not sys.check(data.force_timeout) then
      data.mouse_tick = sys.tick()
    end
  else
    local d = sys.tick() - data.mouse_tick
    if d > data.timeout * 1000 then
      wnd_close(p)
    end
  end
end
local handle_notice = function(cmd, data)
  local key = packet.key
  local v = {}
  if data:has(key.ui_title) then
    v.title = bo2.gv_text:find(data[key.ui_title]).text
  end
  local text
  if data:has(key.ui_text_id) then
    text = bo2.gv_text:find(data[key.ui_text_id]).text
  end
  if data:has(key.ui_text_arg) then
    text = sys.merge_mtf(data[key.ui_text_arg], text)
  end
  v.text = text
  show_notice(v)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "player_notice.packet_handle"
reg(packet.eSTC_UI_Notice, handle_notice, sig)
