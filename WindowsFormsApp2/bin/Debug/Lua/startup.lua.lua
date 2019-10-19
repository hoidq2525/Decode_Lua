if ui_phase == nil then
  w_top = nil
else
  w_top = ui_phase.w_startup
end
local user = {}
local loginTryReplace
if g_login_wait_deal == nil then
  g_login_wait_deal = false
end
if g_connecting == nil then
  g_connecting = false
end
if g_connected == nil then
  g_connected = false
end
local function try_proxy_login()
  local v = bo2.get_proxy_data()
  local kind = v:get(bo2.login_proxy_kind).v_int
  if kind == bo2.login_proxy_kind_common then
    return
  end
  user.username = v:get(bo2.login_proxy_user).v_string
  user.password = v:get(bo2.login_proxy_pass).v_string
  task_insert_login({
    username = user.username,
    password = user.password,
    type = 1
  })
  local disable_qt = bo2.gv_define:find(1106).value.v_int
  if disable_qt == 1 then
    bo2.notify_proxy()
  end
end
function on_go_back(is_first)
  if g_login_wait_deal == false then
    ui_loading.show_top(false)
  end
  if bo2.get_proxy_data():get(bo2.login_proxy_kind).v_int ~= bo2.login_proxy_kind_common then
    if is_first then
      try_proxy_login()
    elseif g_login_wait_deal == false then
      bo2.notify_proxyRt()
    end
  else
    w_top.visible = true
    w_top.focus = true
    w_username.focus = true
    w_username.text = ""
    w_password.text = ""
  end
end
function show_top(vis, is_first)
  if vis then
    ui_main.show_top(false)
    ui_choice.show_top(false)
    ui_tool.tool_clear()
    ui_main.g_player_cfg_username = nil
    ui_main.g_player_cfg_playername = nil
    if g_connected then
      ui_packet.disconnet()
    end
    on_go_back(is_first)
    if ui_fcm.ctrl then
      ui.log("destroy fcm_info")
      ui_fcm.ctrl:control_clear()
      ui_fcm.ctrl = nil
    end
  else
    g_login_wait_deal = false
    w_top.visible = false
    w_msglabel.visible = false
    set_login_msg("")
    user = {}
    ui.log("ui_startup.show_top(false)")
  end
end
function init()
  ui.log("ui_phase:startup : loading enter")
  w_top:load_style("$gui/phase/startup/startup.xml", "w_startup")
  ui.log("ui_phase:startup : loading leave")
  getcommandlines()
  if get_cfg_ip().empty and getcommand(LINE_CONNECT_ADDRESS) == nil then
    bo2.app_quit()
  end
end
function fake_init()
  ui.log("ui_phase:fake_startup : loading enter")
  w_top:load_style("$gui/phase/startup/startup.xml", "w_startup")
  ui.log("ui_phase:fake_startup : loading leave")
  getcommandlines()
  ui_startup.w_core_panel.visible = false
  if bo2.video_tiny_window ~= nil and bo2.video_tiny_window == 1 then
    ui_video.w_main_replay.visible = false
  else
    ui_video.w_main_replay.visible = true
  end
end
function continue_game()
  ui.log("continue_game")
  task_insert_login({
    username = user.username,
    password = user.password,
    type = 1
  })
  g_login_wait_deal = false
end
function relogin_game()
  ui.log("relogin_game in")
  ui_startup.show_top(false)
  ui_startup.show_top(true)
  ui_loading.show_top(false)
  g_login_wait_deal = false
end
function login_retry()
  ui.log("login_retry in")
  ui.log(user.username)
  task_insert_login({
    username = user.username,
    password = user.password,
    type = 1
  })
  g_login_wait_deal = false
end
function return_login()
  ui.log("return_login in")
  ui_startup.show_top(false)
  ui_startup.show_top(true)
  ui_loading.show_top(false)
  g_login_wait_deal = false
end
function on_disconnnet_btn()
  ui.log("disconnet")
  ui_startup.show_top(false)
  ui_startup.show_top(true)
  ui_loading.show_top(false)
end
function on_top_key(w, key, flag)
  if ui_loading.w_continue_game.visible and key == ui.VK_RETURN and flag.down then
    continue_game()
  end
end
function check_break_state()
  if g_connecting then
    return false
  end
  if g_connected then
    return false
  end
  return true
end
local function ShowLoginTryReplace()
  if not loginTryReplace then
    return
  end
  local tid = loginTryReplace:get(packet.key.ui_text_id).v_int
  msg = {
    btn_confirm = true,
    modal = true,
    btn_cancel = false,
    text = bo2.gv_text:find(tid).text
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function kick_callback(btn)
  ui_startup.show_top(true)
  ShowLoginTryReplace()
  if btn then
    ui_widget.ui_msg_box.on_confirm_click(btn)
  end
end
function on_disconnect(cmd, data)
  g_connected = false
  local rst = data:get("result").v_int
  ui.log("on_disconnect. code %d.", rst)
  if rst == ui_packet.goto_login_succeed then
    ui.log("goto_login_succeed")
  elseif rst == ui_packet.goto_login_kick then
    ui.log("goto_login_kick")
    if ui_portrait ~= nil then
      ui_portrait.force_to_release()
    end
    if ui_prompt and ui_prompt.w_offline_prompt and sys.check(ui_prompt.w_offline_prompt) and ui_prompt.w_offline_prompt.visible or loginTryReplace then
      kick_callback(nil)
      return
    end
    local on_msg_callback = function(ret)
      kick_callback(nil)
    end
    if ui_phase.w_tool:search("st_exitgame") then
      return
    end
    local msg = {
      detail = L("kickexitgame"),
      style_uri = "$gui/phase/tool/fcm.xml",
      style_name = "kickexitgame",
      callback = on_msg_callback
    }
    local msg_data = {
      text = ui_widget.merge_mtf({
        tm = os.date("%c")
      }, ui.get_text("tool|fcm_err_msg2")),
      callback = function(ret)
        kick_callback(nil)
      end
    }
    ui_widget.ui_msg_box.show_common(msg_data)
  elseif rst == ui_packet.service_intermit then
    ui.log("service_intermit")
    ui_tool.note_insert(ui.get_text("phase|service_intermit"), "ffffff00")
    g_connected = true
    ui_chat.add_chat({
      channel = bo2.eChatChannel_Notice,
      text = ui.get_text("phase|service_intermit")
    })
  elseif rst == ui_packet.network_intermit then
    ui.log("network_intermit")
    ui_tool.note_insert(ui.get_text("phase|network_intermit"), "ffffff00")
  else
    ui_loading.show_top(true, 1)
    ui_loading.loading_dlg("disconnect")
    ui_tool.note_insert(ui.get_text("phase|network_intermit"), "ffffff00")
  end
  loginTryReplace = nil
end
function on_goout_gzs()
  ui.log("on_goout_gzs")
  ui_loading.show_top(true)
  task_goto_choice()
end
function OnLoginKickByOtherPlayer(cmd, data)
  local msg_data = {
    text = ui_widget.merge_mtf({
      tm = os.date("%c")
    }, ui.get_text("phase|double_login")),
    callback = function(ret)
      kick_callback(nil)
    end
  }
  ui_widget.ui_msg_box.show_common(msg_data)
end
if ui_packet ~= nil then
  local sig_name = "ui_startup:on_signal"
  ui_packet.recv_wrap_signal_insert(ui_packet.bo2wc_disconnect, on_disconnect, sig_name)
  ui_packet.recv_wrap_signal_insert(ui_packet.bo2wc_enter_gzs, on_gzs_enter, sig_name)
  ui_packet.recv_wrap_signal_insert(ui_packet.bo2wc_goout_gzs, on_goout_gzs, sig_name)
  ui_packet.recv_wrap_signal_insert(packet.eSTC_Fake_LoginKick, OnLoginKickByOtherPlayer, sig_name)
end
function on_btn_login(btn)
  if string.find(tostring(w_username.text), "\\") ~= nil then
    set_login_msg(ui.get_text("phase|illegal_character"))
    w_msglabel.visible = true
    w_username.focus = true
    return
  end
  user.username = w_username.text
  user.password = w_password.text
  task_insert_login({
    username = w_username.text,
    password = w_password.text,
    type = 1
  })
end
function on_btn_quit()
  bo2.app_quit()
end
function note_quit()
  local on_msg = function(msg)
    bo2.app_quit()
  end
  local msg = {
    text = ui.get_text("phase|more_client"),
    callback = on_msg,
    btn_cancel = false
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_key_username(box, key, flag)
  if key == ui.VK_TAB then
    w_password.focus = true
  end
  if key == ui.VK_RETURN and flag.down then
    on_btn_login(w_loginbtn)
  end
end
function on_key_password(box, key, flag)
  if key == ui.VK_RETURN and flag.down then
    on_btn_login(w_loginbtn)
  end
end
function set_login_msg(msg)
  w_msglabel.visible = true
  w_msglabel.text = msg
end
