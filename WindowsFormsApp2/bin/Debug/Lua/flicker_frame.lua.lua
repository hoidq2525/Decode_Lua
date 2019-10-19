function on_timer(t)
  local p = t.owner.parent
  local f = p.svar.flicker_frame_data
  local d = sys.dtick(sys.tick(), f.tick)
  if d < f.period then
    return
  end
  t.suspended = true
  f.window.visible = false
  p:insert_post_invoke(on_stop, "ui_widget.ui_flicker_frame.on_stop")
end
function on_stop(p)
  local f = p.svar.flicker_frame_data
  if f == nil then
    return
  end
  local d = sys.dtick(sys.tick(), f.tick)
  if d < f.period then
    return
  end
  p.svar.flicker_frame_data = nil
  f.window:post_release()
end
function attach(p, color, d)
  if color == nil then
    color = "FFFFFF"
  end
  if d == nil then
    d = 10000
  end
  local tick = sys.tick()
  local f = p.svar.flicker_frame_data
  if f == nil then
    local w = ui.create_control(p, "flicker")
    w:load_style("$widget/flicker_frame.xml", "cmn_flicker_frame")
    f = {
      window = w,
      timer = w:find_plugin("timer"),
      color_frame = w:search("fig_color_frame")
    }
    p.svar.flicker_frame_data = f
  else
    f.window.visible = true
    f.timer.suspended = false
  end
  f.tick = tick
  f.period = d
  f.color_frame.color = ui.make_color(color)
end
