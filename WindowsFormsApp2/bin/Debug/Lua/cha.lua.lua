function cha_create(data)
  local ok = true
  local state = false
  ui.log("cha_create in")
  local function on_cha_create(cmd, data)
    state = true
    local rst = data:get("result").v_int
    ui.log("on_cha_create in")
    if rst ~= ui_packet.rst_ok then
      ui.log("on_cha_create error: code %d.", rst)
      ok = false
    end
  end
  local function on_check()
    return state or check_break_state()
  end
  local function do_cha_create()
    ui_packet.cha_create(data)
    ui.log("do_cha_create")
    ui_choice.w_msglabe = ui.get_text("phase|lb_waiting_state")
    if not ui_common.wait(on_check) then
      ok = false
      return
    end
    ok = ok and g_connected
  end
  local sig_name = "ui_startup.cha_create:on_signal"
  ui_packet.recv_wrap_signal_insert(ui_packet.bo2wc_create_cha, on_cha_create, sig_name)
  ui_choice.w_chaname.enable = false
  ui_choice.on_confirm_chaname = false
  ui_choice.on_cha_return_gzs = false
  pcall(do_cha_create)
  ui_packet.recv_wrap_signal_remove(ui_packet.bo2wc_create_cha, sig_name)
  ui_choice.w_chaname.enable = true
  ui_choice.on_confirm_chaname = true
  ui_choice.on_cha_return_gzs = true
  return ok
end
function cha_list_text()
  local list = cha_list()
  if list == nil then
    return nil
  end
  local stk = sys.stack()
  stk:format("count : %d.", list.size)
  for i = 0, list.size - 1 do
    local c = list:get(i)
    stk:format([[

    only_id %.16I64X, name %s, excel_id %d.]], c:get("cha_onlyid").v_string, c:get("cha_name"), c:get("excel_id").v_int)
  end
  return stk.str
end
function cha_delete(data)
  local ok = true
  local state = false
  ui.log("cha_delete in")
  local function on_cha_delete(cmd, data)
    state = true
    local rst = data:get("result").v_int
    ui.log("on_cha_delete in code %d", rst)
    if rst ~= ui_packet.rst_ok then
      ui.log("on_cha_delete error: code %d.", rst)
      ok = false
    end
  end
  local function on_check()
    return state or check_break_state()
  end
  local function do_cha_delete()
    ui_packet.cha_delete(data)
    ui.log("do_cha_delete")
    ui_choice.w_msglabe = ui.get_text("phase|lb_waiting_state")
    if not ui_common.wait(on_check) then
      ok = false
      return
    end
    ok = ok and g_connected
  end
  local sig_name = "ui_startup.cha_delete:on_signal"
  ui_packet.recv_wrap_signal_insert(ui_packet.bo2wc_delete_cha, on_cha_delete, sig_name)
  ui_choice.enable = false
  pcall(do_cha_create)
  ui_packet.recv_wrap_signal_remove(ui_packet.bo2wc_delete_cha, sig_name)
  ui_choice.enable = true
  return ok
end
