function on_play(cmd, data)
  local id = data:get(packet.key.cmn_id).v_int
  if id > 0 then
    play_by_id(id)
  end
end
function play(name, stop)
  g_avi_player.visible = true
  g_avi_player.focus = true
  if stop == true then
    stop_flag = true
  else
    stop_flag = false
  end
  local function playbegin()
    bo2.playvideo(name)
    cur_id = id
  end
  bo2.AddTimeEvent(10, playbegin)
end
function play_by_id(id)
  local excel = bo2.gv_avi_list:find(id)
  if excel == nil then
    on_stop()
    return
  end
  if excel.bstop ~= 0 then
    stop_flag = true
  else
    stop_flag = false
  end
  g_avi_player.visible = true
  g_avi_player.focus = true
  local function playbegin()
    if bo2.playvideobyindex(id) == true then
      w_timer.suspended = false
      cur_id = id
    else
      g_avi_player.visible = false
      g_avi_player.focus = false
      w_timer.suspended = true
    end
  end
  bo2.AddTimeEvent(1, playbegin)
end
function on_timer()
  g_avi_player.focus = true
end
function on_key()
end
function on_stop()
  stop_flag = false
  w_timer.suspended = true
  local v = sys.variant()
  v:set(packet.key.cmn_id, cur_id)
  bo2.send_variant(packet.eCTS_UI_AviOver, v)
  cur_id = 0
  local scn = bo2.scn
  if scn and scn.excel.sight_dummy == 1 then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_ClientLoadOver, v)
  end
  local on_visible_false = function()
    g_avi_player.visible = false
    g_avi_player.focus = false
  end
  bo2.AddTimeEvent(15, on_visible_false)
end
local on_msg = function(msg)
  if msg.result == 0 then
    g_avi_player.visible = true
    bo2.continue_video()
    return
  end
  bo2.stopvideo()
end
function on_pause()
  local function mask_false()
    local msg = {callback = on_msg, modal = true}
    msg.text = ui.get_text("film|skip_film")
    msg.btn2 = true
    msg.text_confirm = ui.get_text("film|skip")
    msg.text_cancel = ui.get_text("film|cancel_skip")
    msg.style_uri = L("$data/gui/phase/tool/tool_avi_player.xml")
    msg.style_name = L("cmn_msg_box_common")
    ui_widget.ui_msg_box.show_common(msg)
    g_avi_player.visible = false
  end
  bo2.AddTimeEvent(10, mask_false)
end
function on_char(box, ch)
  if stop_flag ~= true then
    return
  end
  if ch == ui.VK_ESCAPE then
    bo2.stopvideo()
  end
end
function on_init()
  stop_flag = false
  cur_id = 0
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_Fake_Stop_Avi, on_stop, "ui_tool.ui_avi_player.on_stop")
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_PlayAvi, on_play, "ui_tool.ui_avi_player.on_play")
