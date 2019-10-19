local use_time = 0
local color_cfg = {
  {time_slash = 0, color = "ff00ff00"},
  {time_slash = 900, color = "ffffff00"},
  {time_slash = 1800, color = "ffff0000"},
  size = 3
}
function get_color(t)
  for i = color_cfg.size, 1, -1 do
    if t >= color_cfg[i].time_slash then
      return color_cfg[i].color
    end
  end
end
function show_ui(cmd, data)
  local b = data:get(packet.key.dungenTimeWndState).v_int
  local t = data:get(packet.key.dungenUseTime).v_int
  if b == 0 then
    wnd.visible = false
  elseif b == 1 then
    wnd.visible = true
  elseif b == 2 then
    time_update(tonumber(t))
  elseif b == 3 then
    timer.suspended = false
  else
    if b == 4 then
      timer.suspended = true
    else
    end
  end
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
  time_label.mtf = sys.format("<c+:%s>\184\177\177\190\210\209\191\170\202\188:%02d\208\161\202\177%02d\183\214%02d\195\235<c->", get_color(use_time), h, m, s)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_dungeontimewnd.packet_handle"
