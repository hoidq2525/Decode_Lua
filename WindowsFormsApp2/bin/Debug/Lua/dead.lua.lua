g_flag = false
c_image_url_30 = "$image/cha/portrait/dead.png"
c_image_url_10 = "$image/cha/portrait/dead2.png"
function show(vis, lower)
  if lower == true then
    w_dead_pic.image = c_image_url_10
  else
    w_dead_pic.image = c_image_url_30
  end
  if vis then
    w_flicker.visible = true
    w_flicker.suspended = false
    w_timer.suspended = false
    if g_flag == false then
      ui_widget.safe_play_sound(506)
      g_flag = true
    end
  else
    w_flicker.visible = false
    w_flicker.suspended = true
    w_timer.suspended = true
    bo2.StopSound2D(506)
    g_flag = false
  end
end
function on_timer(timer)
  bo2.StopSound2D(506)
  ui_widget.safe_play_sound(506)
end
