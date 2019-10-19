function test()
  set_mask(true)
  set_transparent_area(750, 400, 200, 300)
  set_controlable(false, true)
end
function test1()
  set_mask_basedon_ctrl(true, ui_tool.ui_mask.w_focus, false, true, 10, 10, 20, 20)
end
function test2()
  set_mask(false)
end
function test3()
  set_mask_basedon_focus(true, false, true)
end
function test4()
  ui_tool.ui_mask.w_focus.dx = 500
end
function test5()
  bo2.scn:ForEachScnObj(function(obj)
    obj:setlum(true)
    obj:sethighlum(true)
  end)
end
local g_base_ctrl = {
  ctrl = nil,
  mx1 = 0,
  my1 = 0,
  mx2 = 0,
  my2 = 0
}
local g_rect = {
  x = 0,
  y = 0,
  dx = 0,
  dy = 0
}
function on_mask_move()
  if w_mask.visible then
    if g_base_ctrl.ctrl then
      set_mask_basedon_ctrl_inner(g_base_ctrl.ctrl, g_base_ctrl.mx1, g_base_ctrl.my1, g_base_ctrl.mx2, g_base_ctrl.my2)
    else
      set_transparent_area(g_rect.x, g_rect.y, g_rect.dx, g_rect.dy)
    end
  end
end
function on_mask_visible(w, vis)
  if not vis then
    g_base_ctrl.ctrl = nil
  elseif g_base_ctrl.ctrl then
    set_mask_basedon_ctrl_inner(g_base_ctrl.ctrl, g_base_ctrl.mx1, g_base_ctrl.my1, g_base_ctrl.mx2, g_base_ctrl.my2)
  else
    set_transparent_area(g_rect.x, g_rect.y, g_rect.dx, g_rect.dy)
  end
end
function get_mask_focus_ctrl()
  return w_focus
end
function set_mask_basedon_focus(vis, b_mask_ctrl, b_trans_ctrl)
  set_mask_basedon_ctrl(vis, w_focus, b_mask_ctrl, b_trans_ctrl, 0, 0, 0, 0)
end
function set_mask_basedon_ctrl(vis, ctrl, b_mask_ctrl, b_trans_ctrl, mx1, my1, mx2, my2)
  if not vis then
    set_mask(false)
  end
  if ctrl then
    g_base_ctrl.ctrl = ctrl
  end
  if mx1 and my1 and mx2 and my2 then
    g_base_ctrl.mx1 = mx1
    g_base_ctrl.my1 = my1
    g_base_ctrl.mx2 = mx2
    g_base_ctrl.my2 = my2
  end
  set_controlable(b_mask_ctrl, b_trans_ctrl)
  set_mask(true)
end
function set_mask_basedon_ctrl_inner(ctrl, mx1, my1, mx2, my2)
  mx1 = mx1 or 0
  my1 = my1 or 0
  mx2 = mx2 or 0
  my2 = my2 or 0
  w_mask:apply_dock(true)
  local pos = ctrl:control_to_window(ui.point(0, 0))
  local x = pos.x - mx1
  local y = pos.y - my1
  local dx = ctrl.dx + mx1 + mx2
  local dy = ctrl.dy + my1 + my2
  if not (x >= 0) or not x then
    x = 0
  end
  if not (y >= 0) or not y then
    y = 0
  end
  set_transparent_area(x, y, dx, dy)
end
function set_mask(vis)
  w_mask.visible = vis
end
function set_transparent_area(x, y, width, height)
  local screen_width, screen_height = w_mask.dx, w_mask.dy
  g_rect.x, g_rect.y, g_rect.dx, g_rect.dy = x, y, width, height
  w_mask_left_top.size = ui.point(x, y + height)
  w_mask_right_top.size = ui.point(screen_width - x, y)
  w_mask_right_bottom.size = ui.point(screen_width - x - width, screen_height - y)
  w_mask_left_bottom.size = ui.point(x + width, screen_height - y - height)
end
function set_controlable(b_mask, b_transparent)
  if nil ~= b_transparent then
    w_mask.mouse_able = not b_transparent
    w_mask.wheel_able = not b_transparent
    w_mask.focus_able = not b_transparent
    w_mask.focus = not b_transparent
  end
  if nil == b_mask then
    return
  end
  local mask_t = {
    w_mask_left_top,
    w_mask_right_top,
    w_mask_right_bottom,
    w_mask_left_botton
  }
  for _, v in pairs(mask_t) do
    v.mouse_able = not b_mask
    v.wheel_able = not b_mask
    v.focus_able = not b_mask
    v.focus = not b_mask
  end
end
