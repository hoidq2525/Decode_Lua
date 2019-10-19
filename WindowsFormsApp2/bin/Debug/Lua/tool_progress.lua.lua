local g_progress_op = {}
local g_step = 0
local g_cur = 0
function on_progress_init(ctrl)
  g_progress_op[0] = on_start
  g_progress_op[1] = on_complete
  g_progress_op[2] = on_break
  g_progress_op[3] = on_pk_start
  g_progress_op[4] = on_pk_complete
  g_progress_op[5] = on_pk_break
  g_step = 0
  g_cur = 0
  g_progress_timer.suspended = true
end
function set_progress(ctrl, f)
  local frm = ctrl:search("frm")
  local pic = ctrl:search("pic")
  local dx = frm.dx * f
  if dx < 0 then
    dx = 0
  end
  pic.dx = dx
end
function on_progress_timer(timer)
  g_cur = g_cur + g_step
  set_progress(w_progress, g_cur)
  if g_cur > 1 then
    g_progress_timer.suspended = true
  end
end
function on_start(data)
  local lb = w_progress_fader:search("lb_text")
  lb.text = data:get(packet.key.cmn_name).v_string
  g_cur = 0
  set_progress(w_progress, 0)
  local ms = data:get(packet.key.cmn_dataobj).v_int - 1000
  if ms > 0 then
    g_step = g_progress_timer.period / ms
    g_progress_timer.suspended = false
  end
  w_progress_fader.visible = true
  w_progress_fader:reset(1, 1, 1, 1)
end
function on_complete(data)
  set_progress(w_progress, 100)
  g_progress_timer.suspended = true
  w_progress_fader:reset(1, 0, 2000, 1000)
end
function on_break(data)
  local lb = w_progress_fader:search("lb_text")
  lb.text = ui.get_text("tool|progress_break")
  g_progress_timer.suspended = true
  w_progress_fader:reset(1, 0, 2000, 1000)
end
function on_progress(cmd, data)
  local op = data:get(packet.key.cmn_msg_cmd).v_int
  local fn = g_progress_op[op]
  if fn ~= nil then
    fn(data)
  end
  if op == 0 then
    bo2.LoadingCamLock(true)
  elseif op == 1 or op == 2 then
    bo2.LoadingCamLock(false)
  end
end
function on_pk_start(data)
  ui_portrait.on_start(data)
end
function on_pk_complete(data)
  ui_portrait.on_complete(data)
end
function on_pk_break(data)
  ui_portrait.on_break(data)
end
local sig_name = "ui_tool:on_signal"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_Progress, on_progress, sig_name)
