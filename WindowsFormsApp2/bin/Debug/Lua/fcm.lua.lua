t_show_time_1 = 10
t_show_time_2 = 60
t_show_time_3 = 0
local start_time = 0
local interval_time = 0
ctrl = nil
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_fcm.packet_handle"
function text_info(Parentctrl, excelId)
  local Sonctrl = Parentctrl:search("lb_fcm")
  if excelId == 0 then
    Sonctrl.text = ui.get_text("tool|fcm_msg0")
    interval_time = t_show_time_1
  elseif excelId == 1 then
    Sonctrl.text = ui.get_text("tool|fcm_msg1")
    interval_time = t_show_time_2
  elseif excelId == 2 then
    Sonctrl.text = ui.get_text("tool|fcm_msg2")
    interval_time = t_show_time_2
  elseif excelId == 3 then
    Sonctrl.text = ui.get_text("tool|fcm_msg3")
    interval_time = t_show_time_3
  elseif excelId == 4 then
    Sonctrl.text = ui.get_text("tool|fcm_msg4")
    interval_time = t_show_time_3
  elseif excelId == 5 then
    Sonctrl.text = ui.get_text("tool|fcm_msg5")
    interval_time = t_show_time_3
  end
end
function update()
  local cur_time = os.time()
  if interval_time > 0 and ctrl and os.difftime(cur_time, start_time) > interval_time and ctrl.visible then
    ui.log("destroy")
    ctrl:control_clear()
    ctrl = nil
  end
end
function handleShowFcmInfo(cmd, data)
  ui.log("test")
  local excelId = data:get(packet.key.ui_text_id).v_int
  if not ctrl then
    ui.log("first")
    ctrl = ui.create_control()
    ctrl:load_style("$gui/phase/tool/fcm.xml", "fcm")
    text_info(ctrl, excelId)
    ctrl.visible = true
  else
    ui.log("second")
    ctrl:control_clear()
    ctrl = nil
    ctrl = ui.create_control()
    ctrl:load_style("$gui/phase/tool/fcm.xml", "fcm")
    text_info(ctrl, excelId)
    ctrl.visible = true
  end
  start_time = os.time()
end
function handexitclient(cmd, data)
  local tp = data:get(packet.key.ui_text_id).v_string
  local function on_msg_callback(ret)
    if ret.result == 0 then
      local msg = {
        detail = L("exitgame"),
        style_uri = "$gui/phase/tool/fcm.xml",
        style_name = "exitgame",
        callback = on_msg_callback
      }
      ui_widget.ui_msg_box.show(msg)
    else
      bo2.app_quit()
    end
  end
  local msg = {
    detail = L("exitgame"),
    style_uri = "$gui/phase/tool/fcm.xml",
    style_name = "exitgame",
    callback = on_msg_callback
  }
  ui_widget.ui_msg_box.show(msg)
end
function on_exitgames(btn)
  bo2.app_quit()
end
function on_kickexitgames(btn)
  kick_callback()
end
function handleShowTips(cmd, data)
  local function on_msg_callback(ret)
    if data:get(packet.key.cmn_state).v_int == 1 then
      bo2.app_quit()
    end
  end
  msg = {
    btn_confirm = true,
    modal = true,
    btn_cancel = false,
    text = data:get(packet.key.ui_text_id).v_string,
    callback = on_msg_callback
  }
  ui_widget.ui_msg_box.show_common(msg)
end
ui_packet.game_recv_signal_insert(packet.eSTC_UI_ShowTips, handleShowTips, sig)
reg(packet.eSTC_UI_ExitClient, handexitclient, sig)
reg(packet.eSTC_UI_ShowFcmInfo, handleShowFcmInfo, sig)
