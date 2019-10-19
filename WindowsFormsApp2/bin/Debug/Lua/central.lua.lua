local t_mutex_window = {
  L("$frame:setting:input"),
  L("$frame:setting:game"),
  L("$frame:central"),
  L("$frame:bo2_guide")
}
function is_mutex_window_visible()
  for i, v in ipairs(t_mutex_window) do
    local p = ui.find_control(v)
    if p ~= nil and p.visible then
      return true
    end
  end
  return false
end
function show_mutex_window(n)
  local wn = L(n)
  local w = ui.find_control(wn)
  if w == nil then
    return
  end
  if w.visible then
    return
  end
  w.visible = true
  for i, v in ipairs(t_mutex_window) do
    if v ~= wn then
      local p = ui.find_control(v)
      if p ~= nil then
        p.visible = false
      end
    end
  end
end
function on_main_btn_help_click()
  show_mutex_window("$frame:bo2_guide")
end
function on_central_visible(ctrl, vis)
  if vis then
    bo2.PlaySound2D(525)
  else
    bo2.PlaySound2D(526)
  end
end
function on_main_btn_game_click()
  show_mutex_window("$frame:setting:game")
end
function on_main_btn_key_click()
  show_mutex_window("$frame:setting:input")
end
function on_main_btn_choice_click(btn)
  if ui_main.g_scn_connected == 0 then
    w_central.visible = false
    ui_chat.show_ui_text_id(1399)
    return
  end
  function do_main_btn_choice_click()
    local wish_idx = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_TodayWishID)
    local level = bo2.player:get_atb(bo2.eAtb_Level)
    if wish_idx == 0 and level >= 5 then
      ui_wish.set_visible(0)
      w_central.visible = false
    else
      w_central.visible = false
      ui_main.goto_choice()
    end
  end
  btn:insert_post_invoke(do_main_btn_choice_click, "ui_central.do_main_btn_choice_click")
end
function on_main_btn_back_click()
  w_central.visible = false
end
function on_main_btn_exit_click(btn)
  function do_main_btn_back_click()
    local wish_idx = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_TodayWishID)
    local level = bo2.player:get_atb(bo2.eAtb_Level)
    if wish_idx == 0 and level >= 5 then
      ui_wish.set_visible(1)
      w_central.visible = false
    else
      w_central.visible = false
      ui_main.goto_startup()
    end
  end
  btn:insert_post_invoke(do_main_btn_back_click, "ui_central.do_main_btn_back_click")
end
function on_main_btn_video_exit_click(btn)
  w_central.visible = false
  if bo2.video_mode ~= nil then
    ui_video.on_click_stop_video()
    quit_text = ui.get_text("central|confirm_quit_video")
  end
  ui_widget.ui_msg_box.show_common({
    text = quit_text,
    callback = function(msg)
      if msg.result == 1 then
        bo2.app_quit()
      end
    end
  })
end
function on_main_btn_video_back_click()
  w_central.visible = false
  ui_video.on_resume_replay()
end
function toggle_central()
  if w_central.visible then
    w_central.visible = false
    return
  end
  show_central()
end
function show_central()
  show_mutex_window("$frame:central")
end
function on_frame_visible(ctrl, vis)
  if sys.check(w_central) and not vis then
    w_central.visible = true
  end
end
