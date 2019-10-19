function on_visible()
  ui_outer.w_main.visible = true
end
function on_toggle()
  if ui_outer.w_main.visible == true then
    ui_outer.w_main.visible = false
    return
  end
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_OuterConfig_Confirm, v)
end
function on_click_unlockcamera()
  bo2.chgcamera(0)
end
function on_open_pettyaction()
  bo2.SetPettyAction(true)
end
function on_close_pettyaction()
  bo2.SetPettyAction(false)
end
function on_click_vis_camera_control()
  if sys.check(ui_video.ui_camera_control.w_video_camera) then
    ui_video.ui_camera_control.w_video_camera.visible = true
  end
end
function on_click_lockcamera()
  bo2.chgcamera(1)
end
function on_click_chgcameraspeed()
  local text = ui_outer.rb_camera_speed.text
  bo2.chgcamera_speed(text.v_number)
end
function on_click_enablefog()
  bo2.setfog(1)
end
function on_click_disablefog()
  bo2.setfog(0)
end
function on_click_setfar()
  bo2.SetCamfar(ui_outer.rb_far.text.v_int)
end
function on_click_enabletarget()
  bo2.setCamTarget(1)
end
function on_click_disabletarget()
  bo2.setCamTarget(0)
end
function on_click_setanglespeed()
  bo2.setcamanglespeed(ui_outer.rb_angle_speed.text.v_number)
end
function on_click_settime()
  bo2.chglocaltime(ui_outer.rb_time.text.v_number, 0, 1)
end
function on_set_camera_max_radius()
  bo2.set_camera_max_radius(ui_outer.ib_camera_dis.text.v_number)
end
function on_init()
  local outer_config = "$cfg/tool/outer_config.xml"
  if sys.is_file(outer_config) then
    ui.insert_on_outer_toggle("ui_outer.on_toggle")
  end
end
function on_click_showselgfx()
  bo2.ShowSelGfx(1)
end
function on_click_disshowselgfx()
  bo2.ShowSelGfx(false)
end
function on_click_showstatecolor()
  bo2.EnableStateColor(1)
end
function on_click_disshowstatecolor()
  bo2.EnableStateColor(false)
end
function on_click_setnpcprompt()
  bo2.setnpcprompt(1)
end
function on_click_disablesetnpcprompt()
  bo2.setnpcprompt(false)
end
function on_show_note()
  ui_tool.w_note_list.visible = true
end
function on_disable_note()
  ui_tool.w_note_list.visible = false
end
