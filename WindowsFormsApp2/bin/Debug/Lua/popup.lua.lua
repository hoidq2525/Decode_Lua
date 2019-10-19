local w_popup
c_mouse_filter_name = SHARED("ui_widget.ui_popup.on_mouse_filter")
c_on_visible_name = SHARED("ui_widget.ui_popup.on_visible")
t_valid_msg = {
  [ui.mouse_lbutton_down] = 1,
  [ui.mouse_rbutton_down] = 1,
  [ui.mouse_lbutton_dbl] = 1,
  [ui.mouse_rbutton_dbl] = 1
}
function on_mouse_filter(ctrl, msg, pos, wheel)
  if t_valid_msg[msg] == nil then
    return
  end
  if not sys.check(w_popup) then
    ui.remove_mouse_filter(c_mouse_filter_name)
    return
  end
  while sys.check(ctrl) do
    if ctrl == w_popup then
      return
    end
    ctrl = ctrl.parent
  end
  ui.remove_mouse_filter_prev(c_mouse_filter_name)
  local w = w_popup
  w_popup = nil
  w.visible = false
end
function show(w, c, m, btn)
  local t = w_popup
  w_popup = nil
  if sys.check(t) then
    t.visible = false
  end
  w_popup = w
  ui.insert_mouse_filter_prev(on_mouse_filter, c_mouse_filter_name)
  local function on_visible(w, vis)
    if vis then
      return
    end
    local t = w_popup
    w_popup = nil
    if btn ~= nil then
      btn.mouse_able = true
    end
    w:remove_on_visible(on_visible, c_on_visible_name)
    if w ~= t then
      return
    end
    ui.remove_mouse_filter_prev(c_mouse_filter_name)
  end
  w:insert_on_visible(on_visible, c_on_visible_name)
  if btn ~= nil then
    btn.mouse_able = false
  end
  w:show_popup(c, m)
end
