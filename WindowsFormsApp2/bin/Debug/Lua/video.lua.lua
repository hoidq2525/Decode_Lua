local item_uri = "$gui/phase/tool/video/video_replay.xml"
local item_style = "item_video_file"
local common_priority = 100
local replay_priority = 500
local cvalue_color_red = L("FFFF0000")
local cvalue_color_green = L("FF00FF00")
local cs_tip_color_operation = SHARED("FF6600")
local video_app_path = "$bin/video/"
local g_select_video_file_name = {}
local g_replay_data = {}
local g_rec_data = {}
local g_file_qbar_total_length = 345
local g_auto_rec_video = false
local g_wstr_rec_file_name
local ciVideoDataMergeIndex = 1697
g_video_info = {}
local g_speed_stage = {}
g_ui_mode = bo2.eVideoReplay_PKUIMode
function init_once()
  g_speed_stage[-25] = {add = -16, plus = -25}
  g_speed_stage[-16] = {add = -8, plus = -25}
  g_speed_stage[-8] = {add = -4, plus = -16}
  g_speed_stage[-4] = {add = -2, plus = -8}
  g_speed_stage[-2] = {add = -1, plus = -4}
  g_speed_stage[-1] = {add = 1, plus = -2}
  g_speed_stage[1] = {add = 2, plus = 1}
  g_speed_stage[2] = {add = 4, plus = 1}
  g_speed_stage[4] = {add = 8, plus = 2}
  g_speed_stage[8] = {add = 16, plus = 4}
  g_speed_stage[16] = {add = 16, plus = 8}
end
init_once()
function init_debug()
  g_speed_stage[1].plus = -1
end
function add_vido_info_data(name, actor_name, target_name)
  g_video_info[name] = {actor = actor_name, target = target_name}
end
function on_click_show_mutex_btn(hide_btn, show_btn)
  hide_btn.visible = false
  show_btn.visible = true
end
function on_vis_frame_video_rec(vis)
  ui_video.w_main_rec.visible = vis
end
function on_rec_video(full_path_name)
  local hHandle = 0
  if sys.check(ui_match_cmn) and sys.check(ui_match_cmn.gx_match_cmn) and ui_match_cmn.gx_match_cmn.visible == true and sys.check(bo2.player) then
    hHandle = bo2.player.target_handle
  end
  local bRecord = bo2.VideoRecord(full_path_name, hHandle)
  if bRecord ~= true then
    local msg = ui.get_text("video|confirm_save_video_file")
    ui_tool.note_insert(msg, cvalue_color_red)
    if bo2.IsVideoRecording() then
      on_click_show_mutex_btn(ui_video.btn_record_video, ui_video.btn_cancel_video)
    end
    return
  end
  ui_video.w_video_list.visible = false
  on_click_show_mutex_btn(ui_video.btn_record_video, ui_video.btn_cancel_video)
  timer_video.suspended = false
  g_rec_data = {}
  g_rec_data.current_second = 0
  on_set_rec_file_time()
  on_vis_frame_video_rec(true)
  if sys.check(bo2.player) then
    local self_name = bo2.GetTargetName(bo2.player)
    bo2.AddVideoActorName(self_name, target_name)
  end
end
function on_confirm_save_video()
  function on_msg_callback(msg)
    if msg.result == 1 then
      local bRewrite = false
      local var = sys.variant()
      if sys.check(msg.input) and 1 < msg.input.size then
        var:set(packet.key.cmn_name, msg.input)
        bRewrite = true
      end
      if ui_video.g_ui_mode == bo2.eVideoReplay_CommonUIMode then
        local btn_common = msg.window:search("ui_mode_common")
        if btn_common.check == true then
          var:set(packet.key.cmn_type, bo2.eVideoReplay_CommonUIMode)
          bRewrite = true
        end
      end
      if bRewrite then
        bo2.RewriteVideoFileHead(bo2.GetCurrentVideoFileName(), var, true)
      end
      return
    end
    bo2.RemoveVideoFile(bo2.GetCurrentVideoFileName())
  end
  local on_show = function(data)
    if data.window == nil then
      return
    end
    local btn_ui_mode = data.window:search("btn_ui_mode")
    if ui_video.g_ui_mode == bo2.eVideoReplay_CommonUIMode then
      btn_ui_mode.visible = true
      local btn_pk = btn_ui_mode:search("ui_mode_pk")
      btn_pk.check = true
      data.window.dx = data.window.dx + 20
      data.window.dy = data.window.dy + btn_ui_mode.dy + 20
    end
  end
  local mtf_text = ui_widget.merge_mtf({
    file_path = bo2.GetCurrentVideoFileName()
  }, ui.get_text("video|confirm_save_video_file"))
  local msg = {
    title = ui.get_text("video|save_msgbox_title"),
    input = L(""),
    limit = 100,
    callback = on_msg_callback,
    text = mtf_text,
    text_confirm = ui.get_text("video|confirm_video"),
    text_cancel = ui.get_text("video|delete_video"),
    style_uri = item_uri,
    style_name = "msg_box_save_confirm",
    input_unfocus = 1,
    on_show = on_show
  }
  ui_widget.ui_msg_box.show_common(msg)
  ui_video.rb_frm_input.focus = false
end
function on_faild_rec()
  on_click_show_mutex_btn(ui_video.btn_cancel_video, ui_video.btn_record_video)
  if sys.check(timer_video) then
    timer_video.suspended = true
  end
  g_rec_data.current_second = 0
  on_set_rec_file_time()
  on_vis_frame_video_rec(false)
end
function on_end_rec_video()
  bo2.VideoClose()
  on_click_show_mutex_btn(ui_video.btn_cancel_video, ui_video.btn_record_video)
  if sys.check(timer_video) then
    timer_video.suspended = true
  end
  g_rec_data.current_second = 0
  on_set_rec_file_time()
  on_vis_frame_video_rec(false)
  on_confirm_save_video()
end
function on_click_frame_video_rec(w, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    ui_video.w_main.visible = not ui_video.w_main.visible
  end
end
function on_click_rec_video(btn)
  local file_name = os.date("%Y-%m-%d-%H%M", os.time())
  lb_file_name.text = file_name
  local file_full_path = sys.format(L("%s%s-%s.pxf"), video_app_path, file_name, bo2.GetCurrentVideoVersion())
  on_rec_video(file_full_path)
end
function on_click_close_rec_video(btn)
  on_end_rec_video()
end
function on_click_replay_list_panel()
  if bo2.video_mode == nil then
    on_click_view_video_list()
  else
    ui_video.w_main_replay.visible = not ui_video.w_main_replay.visible
  end
end
local slider_get_time_text = function(second)
  local wstr_text
  local iHour = math.floor(second / 3600)
  local v = math.fmod(second, 3600)
  local iMinute = math.floor(v / 60)
  local iSecond = math.fmod(v, 60)
  if iHour > 0 then
    if iHour >= 10 then
      wstr_text = sys.format("%d:", iHour)
    else
      wstr_text = sys.format(L("0%d:"), iHour)
    end
  end
  if wstr_text ~= nil then
    if iMinute >= 10 then
      wstr_text = sys.format("%s%d:", wstr_text, iMinute)
    else
      wstr_text = sys.format(L("%s0%d:"), wstr_text, iMinute)
    end
  elseif iMinute >= 10 then
    wstr_text = sys.format("%d:", iMinute)
  else
    wstr_text = wstr_text .. sys.format(L("0%d:"), iMinute)
  end
  if iSecond >= 10 then
    wstr_text = sys.format("%s%d", wstr_text, iSecond)
  else
    wstr_text = sys.format(L("%s0%d"), wstr_text, iSecond)
  end
  return wstr_text
end
function on_set_replay_time_text(current_second, total_second)
  local current_text = slider_get_time_text(current_second)
  local total_text = slider_get_time_text(total_second)
  lb_file_time.text = sys.format(L("%s/%s"), current_text, total_text)
end
function on_make_slider_pos_tip(tip, percent)
  if percent == nil then
    return
  end
  if g_replay_data ~= nil and g_replay_data.total_second ~= nil and percent ~= nil then
    local total_second = g_replay_data.total_second
    local cur_second = percent * total_second
    tip.text = sys.format(L("%s (%.0f%%)"), slider_get_time_text(cur_second), percent * 100)
  end
  ui_widget.tip_make_view(tip.view, tip.text)
end
function on_make_video_pos_tip(tip)
  if g_replay_data ~= nil and g_replay_data.drag_timer ~= nil and g_replay_data.drag_timer == true and g_replay_data.total_second ~= nil then
    local total_second = g_replay_data.total_second
    local cur_second = ui_video.w_process_slider.scroll * total_second
    cur_second = getIntPart(cur_second)
    local time_per = math.abs(cur_second - g_replay_data.current_second)
    if time_per <= 1 then
      tip.text = ui_widget.merge_mtf({
        cur_pos = slider_get_time_text(cur_second)
      }, ui.get_text("video|current_position"))
    else
      tip.text = sys.format(L("%s (%.0f%%)"), slider_get_time_text(cur_second), ui_video.w_process_slider.scroll * 100)
    end
  else
    tip.text = ui.get_text("video|drag_position")
  end
  ui_widget.tip_make_view(tip.view, tip.text)
end
function on_slider_pos(w, pos)
  if g_replay_data == nil or g_replay_data.total_second == nil then
    return
  end
  local current_second = 0
  local total_second = 1
  if g_replay_data.current_second ~= nil and g_replay_data.total_second ~= nil then
    current_second = g_replay_data.current_second
    total_second = g_replay_data.total_second
  end
  if g_replay_data.drag_timer ~= nil and g_replay_data.drag_timer == true then
    current_second = pos / 512 * total_second
    local tips = ui_video.slider_mover.tip
    if sys.check(tips) then
      on_make_video_pos_tip(tips)
    end
  end
end
function on_mouse_time_slider(w, msg, pos, wheel)
  if msg == ui.mouse_inner then
  elseif msg == ui.mouse_move then
    local percent = pos.x / w.dx
    on_make_slider_pos_tip(ui_video.w_process_slider.tip, percent)
  elseif msg == ui.mouse_lbutton_down then
  elseif msg == ui.mouse_lbutton_up then
  elseif msg == ui.mouse_lbutton_click then
    local percent = pos.x / w.dx
    video_time_jump(percent)
  elseif msg == ui.mouse_outer then
  end
end
function on_mouse_slider_mover(w, msg, pos, wheel)
  if msg == ui.mouse_inner then
  elseif msg == ui.mouse_lbutton_down then
    g_replay_data.drag_timer = true
  elseif msg == ui.mouse_lbutton_up then
    g_replay_data.drag_timer = false
    local tips = ui_video.slider_mover.tip
    if sys.check(tips) then
      on_make_video_pos_tip(tips)
    end
    video_time_jump()
  elseif msg == ui.mouse_outer then
  end
end
function on_set_process(current_second, total_second)
  local current_length = g_file_qbar_total_length
  if current_second < total_second then
    current_length = current_second / total_second * g_file_qbar_total_length
  end
  ui_video.w_process_slider.scroll = current_second / total_second
end
function on_set_rec_file_time()
  local current_second = 0
  if g_rec_data.current_second ~= nil then
    current_second = g_rec_data.current_second
  end
  local get_time_text = function(second)
    local wstr_text
    local iHour = math.floor(second / 3600)
    local v = math.fmod(second, 3600)
    local iMinute = math.floor(v / 60)
    local iSecond = math.fmod(v, 60)
    if iHour >= 10 then
      wstr_text = sys.format("%d:", iHour)
    else
      wstr_text = sys.format(L("0%d:"), iHour)
    end
    if iMinute >= 10 then
      wstr_text = sys.format("%s%d:", wstr_text, iMinute)
    else
      wstr_text = sys.format(L("%s0%d:"), wstr_text, iMinute)
    end
    if iSecond >= 10 then
      wstr_text = sys.format("%s%d", wstr_text, iSecond)
    else
      wstr_text = sys.format(L("%s0%d"), wstr_text, iSecond)
    end
    return wstr_text
  end
  lb_file_length.text = get_time_text(current_second)
end
function on_set_replay_file_time()
  if ui_video_view == nil then
    return
  end
  local current_second = 0
  local total_second = 0
  if g_replay_data.current_second ~= nil and g_replay_data.total_second ~= nil then
    current_second = g_replay_data.current_second
    total_second = g_replay_data.total_second
  end
  if g_replay_data.drag_timer == nil or g_replay_data.drag_timer == false then
    on_set_process(current_second, total_second)
  end
  on_set_replay_time_text(current_second, total_second)
  local remain_time = total_second - current_second
  if remain_time <= 0 then
    ui_video_view.set_timer(0, 0, 0)
    return
  end
  local num1 = math.floor(remain_time / 100)
  local num2_remain = remain_time - num1 * 100
  local num2 = math.floor(num2_remain / 10)
  local num3 = num2_remain - num2 * 10
  if num1 > 10 then
    num1 = 9
  end
  if sys.check(ui_video_view) and sys.check(ui_video_view.set_timer) then
    ui_video_view.set_timer(num1, num2, num3)
  end
end
function on_init_replay_video_time(v)
  local iFrame = v:get(packet.key.flight_numpos).v_int
  local iTotalSecond = math.floor(iFrame / 25)
  g_replay_data.total_second = iTotalSecond
  g_replay_data.current_second = 0
  on_set_replay_file_time()
end
function fn_on_init_replay(v)
  g_replay_data = {}
  on_init_replay_video_time(v)
  timer_video_replay.suspended = false
end
function on_timer_video_replay()
  if ui_loading.w_top.visible ~= false then
    return
  end
  g_replay_data.current_second = g_replay_data.current_second + 1
  on_set_replay_file_time()
end
function on_timer_video()
  g_rec_data.current_second = g_rec_data.current_second + 1
  on_set_rec_file_time()
end
function on_click_replay_video(btn, file_full_name)
  if bo2.IsVideoPlaying() ~= false and bo2.IsVideoPause() then
    on_pause_video()
    return false
  end
  local replay_file_full_path
  local use_full_path = false
  if g_select_video_file_name ~= nil and g_select_video_file_name.mtf ~= nil then
    replay_file_full_path = sys.format(L("%s%s.pxf"), video_app_path, g_select_video_file_name.mtf)
  elseif file_full_name ~= nil then
    replay_file_full_path = file_full_name
    use_full_path = true
  end
  if replay_file_full_path ~= nil then
    local bReplay = bo2.VideoReplay(replay_file_full_path, use_full_path)
    on_disable_tiny_window_mode()
    local msg, msg_color
    if bReplay ~= true then
      msg = ui.get_text("video|error_read_file")
      msg_color = cvalue_color_red
    elseif bo2.video_mode == nil then
      msg = ui.get_text("video|succed_read_file")
      msg_color = cvalue_color_green
    else
      on_click_show_replay_btn(false)
      lb_replay_title.text = g_select_video_file_name.mtf
      ui_video.btn_setting.visible = ui_video.btn_player_qbar.visible
      return true
    end
    ui_tool.note_insert(msg, msg_color)
    w_video_list.visible = false
  else
    on_click_view_video_list()
  end
end
function on_click_replay_video_by_name(video_name, bFullPath)
  if bo2.IsVideoPlaying() == true then
    local msg = ui.get_text("video|error_video_is_replaying")
    ui_tool.note_insert(msg, cvalue_color_red)
    return
  end
  on_close_video_file_list()
  if bFullPath ~= true then
    g_select_video_file_name.mtf = video_name
    on_click_replay_video()
  else
    g_select_video_file_name.mtf = nil
    on_click_replay_video(nil, video_name)
  end
end
function on_click_view_video_list()
  if bo2.IsVideoRecording() then
    local msg = ui.get_text("video|error_view_list_recording")
    ui_tool.note_insert(msg, cvalue_color_red)
    return
  end
  if bo2.IsVideoPlaying() then
    local msg = ui.get_text("video|error_view_list_replaying")
    ui_tool.note_insert(msg, cvalue_color_red)
    return
  end
  w_video_list.visible = not w_video_list.visible
end
function on_click_stop_video()
  if bo2.IsVideoPlaying() ~= true or ui_loading.w_top.visible == true then
    return
  end
  fn_call_back_finish_play()
end
function fn_call_back_finish_play(v)
  local msg = ui.get_text("video|finish_replay")
  ui_tool.note_insert(msg, cvalue_color_green)
  if sys.check(ui_video.w_pause_cover) and ui_video.w_pause_cover.visible == true then
    on_pause_video()
  end
  on_set_video_tick_speed(1, true)
  if sys.check(ui_video.lb_speed) then
    ui_video.lb_speed.text = sys.format("x%d", 1)
  end
  on_click_show_replay_btn(true)
  timer_video_replay.suspended = true
  bo2.VideoStop()
  g_replay_data.current_second = 0
  on_set_replay_file_time()
  if ui_video_view ~= nil then
    ui_video_view.set_timer(0, 0, 0)
  end
  ui_startup.show_top(true)
  g_replay_data.current_second = 0
  on_set_replay_file_time()
  w_video_list.visible = true
end
function on_click_show_replay_btn(vis)
  ui_video.btn_replay.visible = vis
  ui_video.btn_pause_replay.visible = not vis
  ui_video.btn_replay_fast.visible = not vis
  ui_video.btn_replay_slow.visible = not vis
end
function on_show_replay_btn(vis)
  ui_video.btn_replay.visible = not ui_video.btn_replay.visible
  ui_video.btn_pause_replay.visible = not ui_video.btn_pause_replay.visible
end
function on_pause_video()
  if ui_loading.w_top.visible == true then
    return
  end
  if bo2.IsVideoPlaying() ~= false then
    bo2.PauseReplay()
    timer_video_replay.suspended = not timer_video_replay.suspended
    on_show_replay_btn()
    w_pause_cover.visible = not w_pause_cover.visible
    if timer_video_replay.suspended == false then
      ui_central.w_central.visible = false
    end
  end
end
function on_click_pause_video()
  on_pause_video()
end
function fn_call_back_finish_read_file(v)
  fn_on_init_replay(v)
end
function on_init()
  bo2.VideoInit(ui_video.fn_call_back_finish_read_file, ui_video.fn_call_back_finish_play)
  local inner_config = "$cfg/tool/pix_dj2_config.xml"
  local outer_config = "$cfg/tool/outer_config.xml"
  if sys.is_file(inner_config) or sys.is_file(outer_config) then
    init_debug()
  end
end
function on_click_close_video_replay()
  w_main_replay.visible = not w_main_replay.visible
  btn_setting.visible = not btn_setting.visible
end
function on_click_disable_ui()
  ui_video.btn_player_qbar.visible = false
  ui_video.btn_setting.visible = false
  ui_video.btn_enable_ui.visible = true
  ui_video.w_main_replay.visible = false
  ui_main.video_disable_top()
end
function on_click_enable_ui()
  ui_video.btn_player_qbar.visible = true
  if bo2.IsVideoPlaying() ~= false then
    ui_video.btn_setting.visible = true
  end
  ui_video.w_main_replay.visible = true
  ui_video.btn_enable_ui.visible = false
  ui_main.video_show_top()
end
function on_click_use_camera_model0(btn)
  on_click_use_camera_model(0)
end
function on_click_use_camera_model1(btn)
  on_click_use_camera_model(3)
end
function on_click_use_camera_model2(btn)
  on_click_use_camera_model(1)
end
function on_click_use_camera_model3(btn)
  on_click_use_camera_model(2)
end
function on_click_use_camera_model(idx)
  pn_camera_model.visible = false
  if idx == 0 then
    ui_video.btn_select_camera.text = ui.get_text("video|select_camera_type_auto")
    bo2.set_single_config("trangle_camera", idx)
  elseif idx == 3 then
    ui_video.btn_select_camera.text = ui.get_text("video|select_camera_type_follow")
    bo2.set_single_config("trangle_camera", idx)
  elseif idx == 1 then
    ui_video.btn_select_camera.text = ui.get_text("video|select_camera_type_focus")
    bo2.set_single_config("trangle_camera", idx)
  elseif idx == 2 then
    ui_video.btn_select_camera.text = ui.get_text("video|select_camera_type_symmetry")
    bo2.set_single_config("trangle_camera", idx)
  end
end
function on_click_select_camera_model()
  pn_camera_model.visible = not pn_camera_model.visible
end
function on_mouse_item_video_file(w, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local fig_highlight = w:search("highlight_select")
    if sys.check(g_select_video_file_name.item) ~= false then
      local current_hightlight = g_select_video_file_name.item:search("highlight_select")
      if current_hightlight ~= fig_highlight then
        current_hightlight.visible = false
        fig_highlight.visible = true
        g_select_video_file_name.item = w
      else
      end
    else
      fig_highlight.visible = true
      g_select_video_file_name.item = w
    end
  elseif msg == ui.mouse_rbutton_click then
  elseif msg == ui.mouse_lbutton_dbl then
    g_select_video_file_name.item = w
    on_click_replay_video_item()
  end
end
function on_mouse_item_video_file_tips_panel(w, msg, pos, wheel)
  on_mouse_item_video_file(w.parent, msg, pos, wheel)
end
function on_close_video_file_list()
  ui_video.w_video_list.visible = false
end
function on_click_replay_video_item()
  if sys.check(g_select_video_file_name.item) ~= false then
    local rb_desc = g_select_video_file_name.item:search("rb_file_name")
    g_select_video_file_name.mtf = rb_desc.mtf
    on_close_video_file_list()
    on_click_replay_video()
  else
    local msg = ui.get_text("video|select_some_item")
    ui_tool.note_insert(msg, cvalue_color_red)
  end
end
function on_click_rewrite_plus_info()
  if sys.check(g_select_video_file_name.item) ~= false then
    do
      local rb_desc = g_select_video_file_name.item:search("rb_file_name")
      local desc_mtf_text = rb_desc.mtf
      if bo2.CheckMayRewriteVideoFileHead(desc_mtf_text) ~= true then
        local msg = ui.get_text("video|check_may_rewrite")
        ui_tool.note_insert(msg, cvalue_color_red)
        return false
      end
      function on_rewrite_msg_callback(msg)
        local input = rb_editor_plus_info.mtf
        local var = sys.variant()
        local bRewrite = false
        if sys.check(input) and input.size > 1 then
          var:set(packet.key.cmn_name, input)
          msg.rb_desc.var:set(packet.key.scnobj_data, input)
          bRewrite = true
        end
        if g_ui_mode == bo2.eVideoReplay_CommonUIMode then
          local btn_ui_mode_pk = ui_video.w_save_confirm:search("ui_mode_pk")
          local btn_ui_mode_common = ui_video.w_save_confirm:search("ui_mode_common")
          if btn_ui_mode_pk.check == true then
            var:set(packet.key.cmn_type, bo2.eVideoReplay_PKUIMode)
            msg.rb_desc.var:set(packet.key.cmn_type, bo2.eVideoReplay_PKUIMode)
            bRewrite = true
          elseif btn_ui_mode_common.check == true then
            var:set(packet.key.cmn_type, bo2.eVideoReplay_CommonUIMode)
            msg.rb_desc.var:set(packet.key.cmn_type, bo2.eVideoReplay_CommonUIMode)
            bRewrite = true
          end
        end
        if bRewrite ~= true then
          return
        end
        local bRewriteRst = bo2.RewriteVideoFileHead(msg.file_name, var, false)
        if bRewriteRst then
          local insert_msg = ui.get_text("video|succed_rewrite")
          ui_tool.note_insert(insert_msg, cvalue_color_green)
          local tips_panel = msg.rb_desc.parent:search("tips_panel")
          on_make_file_item_tips(tips_panel, msg.file_name, rb_desc.var)
        else
          local insert_msg = ui.get_text("video|faild_rewrite")
          ui_tool.note_insert(insert_msg, cvalue_color_red)
        end
      end
      ui_video.rb_confirm_file_info.mtf = ui_widget.merge_mtf({file_path = desc_mtf_text}, ui.get_text("video|confirm_rewrite_file_name"))
      local video_name = rb_desc.var:get(packet.key.scnobj_data).v_string
      ui_video.rb_editor_plus_info.mtf = video_name
      ui_video.btn_save_confirm.svar.msg_box_data = {
        invoke = on_rewrite_msg_callback,
        file_name = rb_desc.mtf,
        rb_desc = rb_desc
      }
      ui_video.w_save_confirm.visible = true
      local var = g_select_video_file_name.item.var
      local _ui_mode = var:get(packet.key.cmn_type).v_int
      if _ui_mode == bo2.eVideoReplay_CommonUIMode then
        local btn_ui_mode = ui_video.w_save_confirm:search("btn_ui_mode")
        btn_ui_mode.visible = true
        g_ui_mode = bo2.eVideoReplay_CommonUIMode
        local current_ui_mode = var:get(packet.key.ui_invite_type).v_int
        local btn_ui_mode_pk = ui_video.w_save_confirm:search("ui_mode_pk")
        local btn_ui_mode_common = ui_video.w_save_confirm:search("ui_mode_common")
        if current_ui_mode == bo2.eVideoReplay_CommonUIMode then
          btn_ui_mode_pk.check = false
          btn_ui_mode_common.check = true
        else
          btn_ui_mode_pk.check = true
          btn_ui_mode_common.check = false
        end
      else
        g_ui_mode = bo2.eVideoReplay_PKUIMode
      end
    end
  else
    local msg = ui.get_text("video|select_some_item")
    ui_tool.note_insert(msg, cvalue_color_red)
  end
end
function on_click_location_video_file()
  if sys.check(g_select_video_file_name.item) ~= false then
    local rb_desc = g_select_video_file_name.item:search("rb_file_name")
    g_select_video_file_name.mtf = rb_desc.mtf
    local bOpen = bo2.LocationVideoFile(g_select_video_file_name.mtf)
    if bOpen then
      local insert_msg = ui.get_text("video|succed_open_vidoe_file")
      ui_tool.note_insert(insert_msg, cvalue_color_green)
    else
      local insert_msg = ui.get_text("video|faild_open_video_file")
      ui_tool.note_insert(insert_msg, cvalue_color_red)
    end
  else
    local msg = ui.get_text("video|select_some_item")
    ui_tool.note_insert(msg, cvalue_color_red)
  end
end
function on_click_select_item()
  if sys.check(g_select_video_file_name.item) ~= false then
    local rb_desc = g_select_video_file_name.item:search("rb_file_name")
    g_select_video_file_name.mtf = rb_desc.mtf
    lb_replay_title.text = rb_desc.mtf
    on_close_video_file_list()
  end
end
function close_replay_list(btn)
  ui_video.w_video_list.visible = false
  if bo2.video_tiny_window ~= nil then
    ui_widget.ui_msg_box.show_common({
      text = ui.get_text("video|exit_msg_text"),
      callback = function(msg)
        if msg.result == 1 then
          bo2.app_quit()
        elseif bo2.IsVideoPlaying() ~= true then
          ui_video.w_video_list.visible = true
        end
      end
    })
  end
end
function on_visible_replay_file_list(w, vis)
  if vis ~= false then
    on_click_refresh_file_list()
  end
  ui_widget.on_esc_stk_visible(w, vis)
end
function on_make_file_item_tips(tips_panel, file_name, var)
  local wstr_actor_name = var:get(packet.key.cha_name).v_string
  local wstr_fighter_actor_name = var:get(packet.key.target_name).v_string
  tips_panel.visible = true
  local stk = sys.mtf_stack()
  local check_param = function(wstr_param)
    if sys.check(wstr_param) and wstr_param.size > 1 then
      return true
    end
    return false
  end
  local function stk_add_data(stk, var, text, default_text, no_end_sep)
    if check_param(var) then
      ui_tool.ctip_push_text(stk, text, ui_tool.cs_tip_color_green)
      ui_tool.ctip_push_newline(stk)
      ui_tool.ctip_push_text(stk, var)
      if no_end_sep == nil then
        ui_tool.ctip_push_sep(stk)
      end
    elseif sys.check(default_text) then
      ui_tool.ctip_push_text(stk, text, ui_tool.cs_tip_color_green)
      ui_tool.ctip_push_newline(stk)
      ui_tool.ctip_push_text(stk, default_text)
    end
  end
  local tips_title = ui.get_text("video|record_file")
  local rec_name_text = ui.get_text("video|author")
  local fighter_name = wstr_actor_name
  local bFightVideo = false
  local view_ui_mode = bo2.eVideoReplay_PKUIMode
  if sys.check(wstr_fighter_actor_name) and wstr_fighter_actor_name.size > 1 then
    tips_title = ui.get_text("video|match_record_file")
    rec_name_text = ui.get_text("video|match_participator")
    bFightVideo = true
    tips_panel.parent.var:set(packet.key.cmn_type, bo2.eVideoReplay_PKUIMode)
  else
    tips_panel.parent.var:set(packet.key.cmn_type, bo2.eVideoReplay_CommonUIMode)
  end
  ui_tool.ctip_push_text(stk, tips_title, ui_tool.cs_tip_color_green)
  ui_tool.ctip_push_newline(stk)
  ui_tool.ctip_push_text(stk, file_name)
  ui_tool.ctip_push_sep(stk)
  local var_version = var:get(packet.key.scnobj_flag).v_string
  if check_param(var_version) then
    local tips_version = ui.get_text("video|record_version")
    ui_tool.ctip_push_text(stk, tips_version, ui_tool.cs_tip_color_green)
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, var_version)
    ui_tool.ctip_push_sep(stk)
  end
  local var_rec_time = var:get(packet.key.org_time)
  if sys.check(var_rec_time) and var_rec_time.empty ~= true then
    local set_as_full_time = function(_time)
      if _time < 10 then
        return sys.format(L("0%d"), _time)
      else
        return _time
      end
    end
    local _year = var_rec_time:get(L("year")).v_int
    if sys.check(_year) and _year > 0 then
      local p_text_time = bo2.gv_text:find(ciVideoDataMergeIndex)
      if p_text_time then
        local ref_param = {}
        ref_param.year = _year
        ref_param.month = var_rec_time:get(L("month")).v_int
        ref_param.day = var_rec_time:get(L("day")).v_int
        ref_param.hour = set_as_full_time(var_rec_time:get(L("hour")).v_int)
        ref_param.minute = set_as_full_time(var_rec_time:get(L("minute")).v_int)
        ref_param.second = set_as_full_time(var_rec_time:get(L("second")).v_int)
        local time_text = ui_widget.merge_mtf(ref_param, p_text_time.text)
        stk_add_data(stk, time_text, ui.get_text("video|record_time"))
      end
    end
  end
  if bFightVideo then
    ui_tool.ctip_push_text(stk, rec_name_text, ui_tool.cs_tip_color_green)
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, wstr_actor_name)
    ui_tool.ctip_push_text(stk, L(" VS "), ui_tool.cs_tip_color_red)
    ui_tool.ctip_push_text(stk, wstr_fighter_actor_name)
    ui_tool.ctip_push_sep(stk)
  else
    stk_add_data(stk, fighter_name, rec_name_text)
  end
  local video_view_type = var:get(packet.key.cmn_type).v_int
  local video_view_type_text
  if video_view_type == bo2.eVideoReplay_CommonUIMode then
    video_view_type_text = ui.get_text("video|ui_mode_normal")
  else
    video_view_type_text = ui.get_text("video|ui_mode_pk")
  end
  tips_panel.parent.var:set(packet.key.ui_invite_type, video_view_type)
  stk_add_data(stk, video_view_type_text, ui.get_text("video|ui_mode"))
  local plus_info = var:get(packet.key.scnobj_data).v_string
  stk_add_data(stk, plus_info, ui.get_text("video|remarks"), ui.get_text("video|none"), 1)
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("video|left_click_func"), cs_tip_color_operation)
  ui_tool.ctip_push_newline(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("video|left_double_click_func"), cs_tip_color_operation)
  tips_panel.tip.text = stk.text
end
function on_click_refresh_file_list()
  local var = bo2.GetVideoFileList()
  local size = var.size
  g_select_video_file_name = {}
  ui_video.lt_video_file:item_clear()
  if sys.check(ui_video.lb_replay_title) then
    ui_video.lb_replay_title.text = nil
  end
  if size <= 0 then
    return
  end
  for i = 0, size - 1 do
    local app_item = ui_video.lt_video_file:item_append()
    app_item:load_style(item_uri, item_style)
    local rb_desc = app_item:search("rb_file_name")
    local cur_var = var:get(i)
    local wst_file_name = cur_var:get(packet.key.cmn_name).v_string
    local wstr_new = wst_file_name:substr(0, wst_file_name.size - 4)
    rb_desc.var = cur_var
    rb_desc.mtf = wstr_new
    local var_last_time = cur_var:get(packet.key.pet_left_time).v_int
    if sys.check(var_last_time) and var_last_time > 0 then
      local totoal_second = var_last_time / 25
      local iSecond = totoal_second % 60
      local iMinute = totoal_second / 60
      local rb_time = app_item:search("rb_file_last_time")
      local strSecond
      local strMinute = L("")
      if totoal_second > 60 then
        if iMinute < 10 then
          strMinute = ui_widget.merge_mtf({
            minute = math.floor(iMinute)
          }, ui.get_text("video|time_minute_less_than_10"))
        else
          strMinute = ui_widget.merge_mtf({
            minute = math.floor(iMinute)
          }, ui.get_text("video|time_minute"))
        end
      else
        rb_time.dx = 80
      end
      if iSecond < 10 then
        strSecond = ui_widget.merge_mtf({
          second = math.floor(iSecond)
        }, ui.get_text("video|time_second_less_than_10"))
      else
        strSecond = ui_widget.merge_mtf({
          second = math.floor(iSecond)
        }, ui.get_text("video|time_second"))
      end
      local mtf_time = sys.format(L("%s%s"), strMinute, strSecond)
      rb_time.mtf = mtf_time
    end
    local tips_panel = app_item:search("tips_panel")
    on_make_file_item_tips(tips_panel, wstr_new, cur_var)
  end
end
function on_auto_rec_match_video(target_name)
  if bo2.IsVideoRecording() then
    return
  end
  local bRec = ui_setting.ui_game.get_cfg_auto_rec_video()
  if bRec ~= true then
    return
  end
  local player = bo2.player
  if sys.check(player) ~= true then
    return
  end
  g_auto_rec_video = true
  local file_name = os.date("%y-%m-%d-%H%M", os.time())
  lb_file_name.text = file_name
  local math_file_name = sys.format(L("match-%s-%s"), file_name, bo2.GetCurrentVideoVersion(true))
  local actor_name = bo2.GetTargetName(player)
  add_vido_info_data(math_file_name, actor_name, target_name)
  local file_full_path = sys.format(L("%s%s.pxf"), video_app_path, math_file_name)
  on_rec_video(file_full_path)
  g_ui_mode = bo2.eVideoReplay_PKUIMode
end
function on_auto_end_rec_match_video()
  if g_auto_rec_video ~= false then
    if bo2.IsVideoRecording() then
      on_end_rec_video()
    end
    g_auto_rec_video = false
  end
end
function on_btn_show_video()
  if bo2.video_mode == nil then
    ui_video.w_main.visible = not ui_video.w_main.visible
  end
end
function on_mouse_cover(w, msg, pos, wheel)
  ui_main.on_mouse(w, msg, pos, wheel)
end
function on_click_setting()
  if bo2.IsVideoPlaying() ~= false and timer_video_replay.suspended == false then
    on_click_pause_video()
  end
  if ui_central ~= nil then
    ui_central.w_central.visible = not ui_central.w_central.visible
  end
end
function on_resume_replay()
  if bo2.IsVideoPlaying() ~= false and timer_video_replay.suspended == true then
    on_click_pause_video()
  end
end
function on_set_speed_text(speed)
  lb_speed.text = sys.format("x%d", speed)
  local msg = sys.format("\194\188\207\241\178\165\183\197\203\217\194\202 x%d", speed)
  ui_tool.note_insert(msg, cvalue_color_green)
end
function on_set_video_tick_speed(iSpeed, reset_text)
  if bo2.video_mode == nil then
    return
  end
  if bo2.IsVideoPlaying() ~= true then
    return
  end
  bo2.SetVideoLogicTickSpeed(iSpeed)
  if sys.check(timer_video_replay) then
    timer_video_replay.period = 1000 / iSpeed
  end
  if reset_text == nil then
    on_set_speed_text(iSpeed)
  end
end
function on_click_add_video_tick_speed(btn)
  local iSpeed = bo2.GetVideoLogicTickSpeed()
  local next_speed = g_speed_stage[iSpeed].add
  on_set_video_tick_speed(next_speed)
end
function on_click_plus_video_tick_speed(btn)
  local iSpeed = bo2.GetVideoLogicTickSpeed()
  local prev_speed = g_speed_stage[iSpeed].plus
  on_set_video_tick_speed(prev_speed)
end
function getIntPart(x)
  if x <= 0 then
    return math.ceil(x)
  end
  if math.ceil(x) == x then
    x = math.ceil(x)
  else
    x = math.ceil(x) - 1
  end
  return x
end
function video_time_jump(percent)
  if bo2.IsVideoPlaying() ~= true then
    return
  end
  local current_second = 0
  local total_second = 0
  if g_replay_data.total_second == nil then
    return
  end
  if percent == nil then
    percent = ui_video.w_process_slider.scroll
  end
  total_second = g_replay_data.total_second
  local cur_second = percent * total_second
  cur_second = getIntPart(cur_second)
  local time_per = math.abs(cur_second - g_replay_data.current_second)
  if sys.check(ui_loading) and ui_loading.w_top.visible == true then
    return
  end
  if time_per > 1 then
    local bPause = false
    if bo2.IsVideoPause() then
      on_pause_video()
      bPause = true
    end
    bo2.VideoTimeJump(cur_second)
    g_replay_data.current_second = cur_second
    on_set_replay_file_time()
    if bPause then
      on_pause_video()
    end
  end
end
function runf_video_time_jump(v)
  bo2.VideoTimeJump(v.v_int)
end
function on_click_close_confirm(btn)
  if sys.check(btn.svar.msg_box_data) then
    btn.svar.msg_box_data.invoke(btn.svar.msg_box_data)
  end
  w_save_confirm.visible = false
end
function bind_video(w, btn, chk_fn)
  local function on_visible(ctrl, vis)
    if not sys.check(w) or not sys.check(btn) then
      return
    end
    if chk_fn ~= nil and not chk_fn() then
      return
    end
    if vis then
      if w_hide_anim.target == w then
        w_hide_anim:reset()
      end
      return
    end
    local bs = btn.size
    local ws = w.size
    local pos = btn:control_to_window(ui.point(0, 0)) + bs * 0.5
    local src = w.offset + ws * 0.5
    local dis = pos - src
    local tick = math.sqrt(math.sqrt(dis.x * dis.x + dis.y * dis.y)) * 14
    if tick < 100 then
      tick = 100
    end
    ui_video.w_hide_anim:set_tick(200, tick)
    ui_video.w_hide_anim:reset(w, pos.x, pos.y, bs.x * 2 / ws.x, bs.y * 2 / ws.y, bs.x / ws.x, bs.y / ws.y)
  end
  w:insert_on_visible(on_visible, bind_sig)
end
function on_init_btn_player_qbar()
  if bo2.video_mode ~= nil then
    if bo2.video_tiny_window ~= nil and bo2.video_tiny_window == 1 then
      ui_video.w_main_btn_player_qbar.visible = false
    else
      ui_video.w_main_btn_player_qbar.visible = true
    end
    ui_video.btn_setting.visible = false
  end
end
function on_init_replay()
  if bo2.video_mode ~= nil then
    bind_video(ui_video.w_main_replay, ui_video.btn_player_qbar)
    ui_video.w_video_list.visible = true
  end
end
function on_disable_tiny_window_mode()
  if bo2.video_tiny_window ~= nil and bo2.video_tiny_window == 1 then
    w_main_replay.visible = true
    ui_video.w_main_btn_player_qbar.visible = true
    ui.gfx_disable_scale(false)
    bo2.CloseVideoTinyWindowMode()
  end
end
