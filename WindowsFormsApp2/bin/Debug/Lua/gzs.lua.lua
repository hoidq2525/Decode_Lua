function on_gzs_enter(cmd, data)
  local rst = data:get("result").v_int
  if rst == 9 then
    ui_tool.note_insert(ui.get_text("phase|server_full"), "ffffff00")
    ui_choice.show_top(true)
    return
  elseif rst == 10 then
    ui_tool.note_insert(ui.get_text("phase|camp_conflict"), "ffffff00")
    ui_choice.show_top(true)
    return
  elseif rst ~= 1 and rst ~= 2 then
    ui.log("on_gzs_enter: error %d.", rst)
    ui_choice.show_top(true)
    return
  end
  ui_loading.insert_msg(ui.get_text("phase|yanzhengjuesesucc"))
end
function gzs_enter(data)
  ui_loading.insert_msg(ui.get_text("phase|yanzhengjuese"))
  rst = ui_packet.gzs_enter(data)
  if rst ~= ui_packet.rst_ok then
    ui.log("gzs_enter error : code %d", rst)
    ui_loading.insert_msg(ui.get_text("phase|yanzhengjuesefailed"))
    return false
  end
  ui_loading.insert_msg(ui.get_text("phase|yanzhengjuesesucc"))
  return true
end
function gzs_enter_field(data, gzs_field)
  ui.log("enter gzs: cha '%s', gzs '%s' %s.", data.cha, data.gzs, gzs_field)
  local list = cha_list()
  if list == nil then
    return false
  end
  local cha = list:find("cha_name", data.cha)
  if cha.empty then
    ui.log("cannot find cha '%s'.", data.cha)
    return false
  end
  ui.log("find cha '%s'. only_id %.16I64X", data.cha, cha:get("cha_onlyid"))
  list = gzs_list()
  if list == nil then
    return false
  end
  local gzs = list:find(gzs_field, data.gzs)
  if gzs.empty then
    ui.log("cannot find gzs '%s'.", data.gzs)
    return false
  end
  ui.log("find gzs '%s'. id %d", gzs:get("GZS_Name").v_string, gzs:get("GZS_ID").v_int)
  gzs_enter({
    cha_id = cha:get("cha_onlyid").v_string,
    gzs_id = gzs:get("GZS_ID").v_int
  })
  return true
end
function gzs_enter_name(data)
  return gzs_enter_field(data, "GZS_Name")
end
function gzs_enter_id(data)
  return gzs_enter_field(data, "GZS_ID")
end
function gzs_list_text()
  local list = gzs_list()
  if list == nil then
    return nil
  end
  local stk = sys.stack()
  stk:format("count : %d.", list.size)
  for i = 0, list.size - 1 do
    local c = list:get(i)
    stk:format([[

    id %d, name %s.]], c:get("GZS_ID").v_int, c:get("GZS_Name").v_string)
  end
  return stk.str
end
function goto_gzs()
  local ok = true
  local state = false
  function on_unload_scn(cmd, data)
    local rst = data:get("result").v_int
    if rst ~= ui_packet.goto_gzs_succeed then
      ui.log("on_unload_scn failed")
      ok = false
    end
    state = true
  end
  local function on_check()
    return state or check_break_state()
  end
  function do_unload_scn()
    ui_packet.gzs_out()
    if not ui_common.wait(on_check) then
      ok = false
      return
    end
    ok = ok and g_connected
  end
  local sig_name = "ui_startup.goto_gzs:on_signal"
  ui_packet.recv_wrap_signal_insert(ui_packet.bo2wc_goout_gzs, on_unload_scn, sig_name)
  pcall(do_unload_scn)
  ui_packet.recv_wrap_signal_remove(ui_packet.bo2wc_goout_gzs, sig_name)
  return ok
end
function disconnect()
  local ok = true
  local state = false
  function on_disconnect(cmd, data)
    local rst = data:get("result").v_int
    if rst ~= ui_packet.goto_login_succeed then
      ui.log("on_disconnect failed")
      ok = false
    end
    state = true
  end
  local function on_check()
    return state or check_break_state()
  end
  function do_disconnect()
    ui_packet.login_out()
    if not ui_common.wait(on_check) then
      ok = false
      return
    end
    ok = ok and g_connected
  end
  local sig_name = "ui_startup.disconnect:on_signal"
  ui_packet.recv_wrap_signal_insert(ui_packet.bo2wc_goout_login, on_disconnect, sig_name)
  pcall(do_disconnect)
  ui_packet.recv_wrap_signal_remove(ui_packet.bo2wc_goout_login, sig_name)
  return ok
end
