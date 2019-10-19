function on_test_visible()
  w_test_panel.visible = not w_test_panel.visible
  w_test2_panel.visible = not w_test2_panel.visible
  w_test3_panel.visible = not w_test3_panel.visible
  local pos = bo2.GetFacePos(build_info.player)
  local mark_pos = w_scn_view.scn:getmarkpos("xrjm_shexiangji")
  ui.log("%s %s %s", pos.x, pos.y, pos.z)
  ui.log("%s %s %s", mark_pos.x, mark_pos.y, mark_pos.z)
  if w_test_panel.visible then
    w_scn_view.scn:MoveToScnDisAndAngle("xrjm_shexiangji", pos.x - mark_pos.x + 0.18, pos.y - mark_pos.y, pos.z - mark_pos.z - 1, angelx, angely, angelz)
  else
    w_scn_view.scn:MoveToScnDisAndAngle("xrjm_shexiangji", test_posx, test_posy, test_posz, angelx, angely, angelz)
  end
end
function on_device_reset()
  local x = w_top.dx
  local y = w_top.dy
  if x == 0 and y == 0 then
    return
  end
  if x / y > 2 then
    w_scn_display.dx = y * 2
    w_scn_display.dy = y
  else
    w_scn_display.dx = x
    w_scn_display.dy = y
  end
  if w_scn_veiw then
    w_scn_view.scn:set_fov(0.7954)
  end
end
function on_move()
  local x = w_top.dx
  local y = w_top.dy
  if x == 0 and y == 0 then
    return
  end
  if x / y > 2 then
    w_scn_display.dx = y * 2
    w_scn_display.dy = y
  else
    w_scn_display.dx = x
    w_scn_display.dy = y
  end
  if w_scn_veiw then
    w_scn_view.scn:set_fov(0.7954)
  end
end
