local begin_word_over = false
local start_word_over = false
local gx_begin_stop_time = 0
local gx_start_stop_time = 0
function on_begin_back_timer()
  if g_begin_word.dx <= 738 and begin_word_over == false then
    g_begin_word.dx = 738
    g_begin_word.dy = 512
    g_begin_word_1.dx = 512
    g_begin_word_1.dy = 512
    g_begin_word_2.dx = 256
    g_begin_word_2.dy = 512
    begin_word_over = true
  end
  if begin_word_over == true then
    gx_begin_stop_time = gx_begin_stop_time + 1
  end
  if 738 <= g_begin_back.dx then
    g_match_animation.visible = g_match_animation_cd.visible
    g_match_animation_beg.visible = false
    g_begin_back_timer.suspended = true
  end
  if gx_begin_stop_time >= 10 then
    g_begin_back.dx = g_begin_back.dx + 64
  end
  if begin_word_over ~= true then
    g_begin_word.dx = g_begin_word.dx - 307
    g_begin_word.dy = g_begin_word.dy - 213
    g_begin_word_1.dx = g_begin_word_1.dx - 213
    g_begin_word_1.dy = g_begin_word_1.dy - 213
    g_begin_word_2.dx = g_begin_word_2.dx - 106
    g_begin_word_2.dy = g_begin_word_2.dy - 213
  end
end
local countdown_time_count = 1
function on_countdown_timer()
  local dx = countdown_time_count * 48
  g_countdown_pic.image = sys.format("$image/match/number.png|%s,0,%s,128", 190 - dx, 238 - dx)
  countdown_time_count = countdown_time_count + 1
  if countdown_time_count == 5 then
    countdown_time_count = 0
    g_match_animation.visible = false
    g_match_animation_cd.visible = false
    g_countdown_timer.suspended = true
    handleMatchStart()
  end
end
function on_result_timer()
  g_match_animation.visible = false
  g_match_animation_rst.visible = false
  g_result_timer.suspended = true
end
function cmn_show_result(rst)
  if rst == 1 then
    g_result_pic.dy = 256
    g_result_pic.image = "$image/match/win.png"
  elseif rst == 0 then
    g_result_pic.dy = 290
    g_result_pic.image = "$image/match/los.png|0,0,256,290"
  else
    g_result_pic.dy = 512
    g_result_pic.image = "$image/match/tie.png"
  end
  g_match_animation.visible = true
  g_match_animation_rst.visible = true
  g_match_animation_rst:move_to_head()
  g_result_timer.suspended = false
end
function handleMatchResult(cmd, data)
  local rst = data:get(packet.key.cmn_rst).v_int
  if rst == bo2.eMatchResult_Win then
    g_result_pic.dy = 256
    g_result_pic.image = "$image/match/win.png"
  elseif rst == bo2.eMatchResult_Lose then
    g_result_pic.dy = 290
    g_result_pic.image = "$image/match/los.png|0,0,256,290"
  else
    g_result_pic.dy = 512
    g_result_pic.image = "$image/match/tie.png"
  end
  g_match_animation.visible = true
  g_match_animation_rst.visible = true
  g_result_timer.suspended = false
  ui_video.on_auto_end_rec_match_video()
end
function handleMatchBegin(cmd, data)
  gx_begin_stop_time = 0
  g_begin_back.dx = 0
  g_begin_word.dx = 4368
  g_begin_word.dy = 3072
  g_begin_word_1.dx = 3072
  g_begin_word_1.dy = 3072
  g_begin_word_2.dx = 1536
  g_begin_word_2.dy = 3072
  begin_word_over = false
  g_match_animation.visible = true
  g_match_animation_beg.visible = true
  g_begin_back_timer.suspended = false
  local scn = bo2.scn
  if sys.check(scn) and scn.excel and scn.excel.id > 300 and scn.excel.id < 400 then
    return
  end
  local is_knight = data:has(packet.key.is_knight_fight)
  if is_knight then
    return
  end
  ui_video.on_auto_rec_match_video()
end
function handleRecVideo(cmd, data)
  if bo2.IsVideoRecording() then
    local target_handle = data:get(packet.key.scnobj_handle).v_int
    if sys.check(bo2.scn) ~= true then
      return
    end
    local obj = bo2.scn:get_scn_obj(target_handle)
    if sys.check(obj) and sys.check(bo2.player) then
      local target_name = bo2.GetTargetName(obj)
      local self_name = bo2.GetTargetName(bo2.player)
      bo2.AddVideoActorName(self_name, target_name)
    end
  end
end
function handleMatchTime(cmd, data)
  countdown_time_count = 1
  g_countdown_pic.image = sys.format("$image/match/number.png|%s,0,%s,128", 190, 238)
  g_match_animation.visible = true
  g_match_animation_cd.visible = true
  g_countdown_timer.suspended = false
  ui_widget.ui_wnd.show_notice({
    text = ui.get_text("match|match_notice"),
    timeout = 10,
    force_timeout = true
  })
end
function on_start_back_timer()
  g_match_animation.visible = false
  g_match_animation_str.visible = false
  g_start_back_timer.suspended = true
end
function handleMatchStart(cmd, data)
  g_match_animation.visible = true
  g_match_animation_str.visible = true
  g_start_back_timer.suspended = false
end
