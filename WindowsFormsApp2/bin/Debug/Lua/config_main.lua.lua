w_top = ui_phase.w_main
local init_once = function()
end
bo2_config_windows = {
  {
    style = "config",
    uri = "$frame/config/config.xml"
  }
}
local do_show_top = function(fn)
  ui.log("ui_phase:config_main : loading enter")
  w_top:load_style("$gui/phase/config_main/config_main.xml", "w_main")
  local weight_all = 0
  for i, v in ipairs(bo2_config_windows) do
    local w = v.weight
    if w == nil then
      w = 100
    end
    weight_all = weight_all + w
  end
  local weight = 0
  local bLoad = true
  for i, v in ipairs(bo2_config_windows) do
    if fn ~= nil then
      fn(weight / weight_all, sys.format("ui(%s,%s)", v.uri, v.style))
    end
    local w = v.weight
    if w == nil then
      w = 100
    end
    weight = weight + w
    local wt = v.widget
    if wt == nil then
      wt = "panel"
    end
    local p = ui.create_control(w_top, wt)
    if p ~= nil then
      p:load_style(v.uri, v.style)
      v.panel = p
    else
      ui.log("ui_phase:main : failed create control %s.", wt)
    end
  end
  on_init(w_top)
  ui.log("ui_phase:main : loading leave")
  w_top.visible = true
end
function show_top(vis, fn)
  do_show_top(fn)
end
function on_mouse(w, msg, pos, wheel)
  if msg == ui.mouse_rbutton_down then
    w.capture = true
    ui_chat.w_chat_channel.visible = false
  elseif msg == ui.mouse_rbutton_up or msg == ui.mouse_leave then
    w.capture = false
  end
  bo2.notify_on_mouse(msg, pos, wheel)
end
function on_key(w, key, flag)
end
function on_drop(obj, msg, pos, data)
  if msg == ui.mouse_move then
    return
  end
end
function set_progress(per, msg)
end
function set_main_focus()
end
function on_window_close_check()
  if not w_top.visible or ui_loading.w_top.visible then
    return true
  end
  if bo2.video_mode == nil and (inner_config_quick_close == nil or not inner_config_quick_close) then
    goto_startup()
    return false
  end
  local quit_text = ui.get_text("config|msg_quit")
  return false
end
function init()
  bo2.insert_on_close_check(on_window_close_check, "ui_main.on_window_close_check")
end
function on_main_visible(ctrl, vis)
  if vis then
  end
end
function on_init(w)
  w:reset(1, 1)
end
init_once()
