local glint = {
  gps = {
    text = ui.get_text("tool|path_found"),
    icon = "$image/widget/pic/tray_gps.png",
    sound = "$sound/gps_finish.wav"
  },
  im = {
    text = ui.get_text("tool|new_friend_msg"),
    icon = "$image/widget/pic/tray_im.png",
    sound = "$sound/im_msg.wav"
  }
}
local glint_list = {}
local icon_text = SHARED(ui.get_text("tool|dao2_title"))
function glint_reset()
  w_tray_timer.suspended = true
  w_tray_icon.glint_enable = false
  w_tray_icon.text = icon_text
  glint_list = {}
end
local glint_check = function()
  return not ui.main_window_is_visible()
end
function glint_insert(name)
  if not glint_check() then
    return
  end
  local g = glint[name]
  if g == nil then
    return
  end
  for i, v in ipairs(glint_list) do
    if v == g then
      table.remove(glint_list, i)
      break
    end
  end
  table.insert(glint_list, g)
  local cnt = #glint_list
  if cnt > 1 then
    local stk = sys.stack()
    stk:push(icon_text)
    for i = 1, cnt do
      stk:push("\n")
      stk:push(glint_list[i].text)
    end
    w_tray_icon.text = stk.text
  else
    w_tray_icon.text = sys.format(L("%s - %s"), icon_text, g.text)
  end
  w_tray_icon:glint_item_clear()
  local gi = w_tray_icon:glint_item_append()
  gi.icon = g.icon
  gi.period = 500
  local gi = w_tray_icon:glint_item_append()
  gi.icon = "$image/widget/pic/tray_empty.png"
  gi.period = 500
  w_tray_icon.glint_enable = true
  w_tray_timer.suspended = false
  if g.sound ~= nil then
    ui.play_sound(g.sound)
  end
end
function on_timer(t)
  if glint_check() then
    return
  end
  glint_reset()
end
function on_tray_icon_click(tray_icon)
  ui.main_window_show(not ui.main_window_is_visible())
end
function on_tray_icon_rclick(tray_icon)
  local vis = ui.main_window_is_visible()
  w_tray_menu_show.enable = not vis
  w_tray_menu_hide.enable = vis
  tray_icon:show_menu()
end
function on_tray_menu_show_click(tray_item)
  ui.main_window_show(true)
end
function on_tray_menu_hide_click(tray_item)
  ui.main_window_show(false)
end
function on_tray_menu_exit_click(tray_item)
  local may_close = ui_main.on_window_close_check()
  if may_close then
    bo2.app_quit()
  else
    ui.main_window_show(true)
  end
end
