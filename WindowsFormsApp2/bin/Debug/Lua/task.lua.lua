local delete_code = {
  [33] = "BO2_CHARCMD_RST_CHARINGUILD",
  [252] = "BO2_CHARCMD_RST_CHARIDNOTEXIST",
  [255] = "BO2_CHARCMD_RST_UNKNOWNERR",
  [34] = "BO2_CHARCMD_RST_CHARINGUILDAPPLY",
  [35] = "BO2_CHARCMD_RST_ENGAGEMENT",
  [36] = "BO2_CHARCMD_RST_COUPLE",
  [37] = "BO2_CHARCMD_RST_SWORN",
  [38] = "BO2_CHARCMD_RST_MASTERANDAPP"
}
local create_code = {
  [0] = "BO2_CHARCMD_RST_OK",
  [1] = "BO2_CHARCMD_RST_CC_NAMEFORBIDDEN",
  [2] = "BO2_CHARCMD_RST_CC_NAMEDUP",
  [3] = "BO2_CHARCMD_RST_CC_SLOTFULL",
  [4] = "BO2_CHARCMD_RST_CC_BADNAME",
  [5] = "BO2_CHARCMD_RST_CC_GLOBALFAIL",
  [6] = "BO2_CHARCMD_RST_CC_NAMEBADLEN",
  [7] = "BO2_CHARCMD_RST_CC_NAMEIS_NUMERIC",
  [8] = "BO2_CHARCMD_RST_CC_BADGZS",
  [9] = "BO2_CHARCMD_RST_CC_INVALID_TEMPLATE",
  [10] = "BO2_CHARCMD_RST_CC_GCSERR",
  [16] = "BO2_CHARCMD_RST_BAD_PASSWD",
  [17] = "BO2_CHARCMD_RST_RESTRICTED",
  [18] = "BO2_CHARCMD_RST_RELATION",
  [19] = "BO2_CHARCMD_RST_LVL_REFUSED",
  [245] = "BO2_CHARCMD_RST_TOOMANYRETRY",
  [246] = "BO2_CHARCMD_RST_TRANSACTION_TIMEOUT",
  [250] = "BO2_CHARCMD_RST_NOSERVICE",
  [251] = "BO2_CHARCMD_RST_OUTOFTRANSACTION",
  [252] = "BO2_CHARCMD_RST_CHARIDNOTEXIST",
  [253] = "BO2_CHARCMD_RST_PRECVCMDNOTEND",
  [254] = "BO2_CHARCMD_RST_REFUSED",
  [255] = "BO2_CHARCMD_RST_UNKNOWNERR"
}
local select_code = {
  [17] = "BO2_CHARCMD_RST_RESTRICTED"
}
BO2_CHARCMD_RST_RESTRICTED = 17
local code_init = function(t)
  for n, v in pairs(t) do
    t[n] = ui.get_text("phase|" .. v)
  end
end
code_init(delete_code)
code_init(create_code)
code_init(select_code)
function task_item_cha_create(cha)
  local item = {is_owner = false}
  local sig_name = "ui_startup.task_item_cha_create:on_signal"
  local function on_cha_create(cmd, data)
    local rst = data:get("result").v_int
    if rst ~= ui_packet.rst_ok then
      ui.log("task_item_cha_create: error %d , %s.", rst, create_code[rst])
      ui_choice.set_create_msg(create_code[rst])
      ui_choice.w_build_input_name:select(0, w_build_input_name.text.size)
      w_build_input_name.focus = true
      item.result = ui_tool.c_task_result_failed
      return
    end
    item.result = ui_tool.c_task_result_finish_item
    item.owner.cha_create_finish = true
  end
  local function on_enter(item)
    if not ui_startup.g_connected then
      ui.log("task_item_cha_create: not connected.")
      item.result = ui_tool.c_task_result_failed
      return
    end
    item.is_owner = true
    ui.log("task_item_cha_create: on_enter.")
    w_build_input_name.enable = false
    ui_packet.recv_wrap_signal_insert(ui_packet.bo2wc_create_cha, on_cha_create, sig_name)
    ui_packet.cha_create(cha)
  end
  local function on_leave(item)
    if not item.connect_owner then
      return
    end
    ui_packet.recv_wrap_signal_remove(ui_packet.bo2wc_create_cha, sig_name)
    ui_choice.w_build_input_name.enable = true
    ui_choice.on_confirm_chaname = true
    ui_choice.on_cha_return_gzs = true
    ui.log("task_item_cha_create: on_leave.")
  end
  local on_tick = function(item)
    if not ui_startup.g_connected then
      item.result = ui_tool.c_task_result_failed
    end
  end
  item.on_enter = on_enter
  item.on_leave = on_leave
  item.on_tick = on_tick
  return item
end
function task_item_cha_create_gate()
  local item = {}
  local sig_name = "ui_startup.task_item_cha_create_gate:on_signal"
  local on_insert = function(item)
    ui.log("task_item_cha_create_gate: on_insert.")
    w_build_input_name.enable = false
    w_build_confirm_btn.enable = false
    w_build_back_model_btn.enable = false
  end
  local on_remove = function(item)
    w_build_input_name.enable = true
    w_build_confirm_btn.enable = true
    w_build_back_model_btn.enable = true
    if item.owner.cha_create_finish ~= nil then
      ui_choice.build_show(false)
    else
    end
    ui.log("task_item_cha_create_gate: on_leave.")
  end
  item.on_insert = on_insert
  item.on_remove = on_remove
  return item
end
function task_item_cha_delete(cha)
  local item = {is_owner = false}
  local sig_name = "ui_startup.task_item_cha_delete:on_signal"
  local function on_cha_delete(cmd, data)
    local rst = data:get("result").v_int
    if rst ~= ui_packet.rst_ok then
      ui.log("task_item_cha_delete: error %d.", rst)
      ui_choice.set_create_msg(delete_code[rst])
      item.result = ui_tool.c_task_result_failed
      return
    end
    item.result = ui_tool.c_task_result_finish_item
  end
  local function on_enter(item)
    if not ui_startup.g_connected then
      ui.log("task_item_cha_delete: not connected.")
      item.result = ui_tool.c_task_result_failed
      return
    end
    item.is_owner = true
    ui.log("task_item_cha_delete: on_enter.")
    ui_choice.enable = false
    ui_packet.recv_wrap_signal_insert(packet.eSTC_Fake_delete_cha, on_cha_delete, sig_name)
    ui.log("cha_id %s", cha)
    ui_packet.cha_delete(cha)
  end
  local function on_leave(item)
    if not item.is_owner then
      return
    end
    ui_packet.recv_wrap_signal_remove(packet.eSTC_Fake_delete_cha, sig_name)
    ui_choice.enable = true
    ui.log("task_item_cha_delete: on_leave.")
  end
  local on_tick = function(item)
    if not ui_startup.g_connected then
      item.result = ui_tool.c_task_result_failed
    end
  end
  item.on_enter = on_enter
  item.on_leave = on_leave
  item.on_tick = on_tick
  return item
end
function task_item_cha_restore(cha)
  local item = {is_owner = false}
  local sig_name = "ui_startup.task_item_cha_restore:on_signal"
  local function on_cha_restore(cmd, data)
    local rst = data:get("result").v_int
    if rst ~= ui_packet.rst_ok then
      ui.log("task_item_cha_restore: error %d.", rst)
      item.result = ui_tool.c_task_result_failed
      return
    end
    item.result = ui_tool.c_task_result_finish_item
  end
  local function on_enter(item)
    if not ui_startup.g_connected then
      ui.log("task_item_cha_restore: not connected.")
      item.result = ui_tool.c_task_result_failed
      return
    end
    item.is_owner = true
    ui.log("task_item_cha_restore: on_enter.")
    ui_choice.enable = false
    ui_packet.recv_wrap_signal_insert(packet.eSTC_Fake_restore_cha, on_cha_restore, sig_name)
    ui.log("cha_id %s", cha)
    local v = sys.variant()
    v:set("cha_id", cha)
    bo2.send_wrap(packet.eSTC_Fake_restore_cha, v)
  end
  local function on_leave(item)
    if not item.is_owner then
      return
    end
    ui_packet.recv_wrap_signal_remove(packet.eSTC_Fake_restore_cha, sig_name)
    ui_choice.enable = true
    ui.log("task_item_cha_restore: on_leave.")
  end
  local on_tick = function(item)
    if not ui_startup.g_connected then
      item.result = ui_tool.c_task_result_failed
    end
  end
  item.on_enter = on_enter
  item.on_leave = on_leave
  item.on_tick = on_tick
  return item
end
function task_item_cha_select(cha)
  local item = {is_owner = false}
  local sig_name = "ui_startup.task_item_cha_select:on_signal"
  local function on_cha_select(cmd, data)
    local rst = data:get("result").v_int
    if rst ~= ui_packet.rst_ok then
      ui.log("on_cha_select: error %d.", rst)
      if rst == BO2_CHARCMD_RST_RESTRICTED then
        local leftTime = data:get("extr").v_int
        local minutes = math.floor(leftTime / 60)
        local hours = math.floor(minutes / 60)
        minutes = minutes % 60
        if minutes == 0 then
          minutes = 1
        end
        local txt = ui_widget.merge_mtf({hour = hours, min = minutes}, ui.get_text("phase|jiefeng2"))
        ui_choice.set_create_msg(select_code[rst] .. txt)
      else
        ui_choice.set_create_msg(select_code[rst])
      end
      item.result = ui_tool.c_task_result_failed
      return
    end
    item.result = ui_tool.c_task_result_finish_item
  end
  local function on_enter(item)
    item.result = ui_tool.c_task_result_finish_item
    if not player_item_sel then
      item.result = ui_tool.c_task_result_failed
      return
    end
    on_player_item_mouse(player_item_sel.svar.player_item.bar, ui.mouse_lbutton_click)
    local info = player_item_sel.svar.player_data
    if info.retain_second ~= 0 then
      item.result = ui_tool.c_task_result_failed
      return
    end
    ui_packet.recv_wrap_signal_insert(packet.eSTC_Fake_select_cha, on_cha_select, sig_name)
    local v = sys.variant()
    v:set("cha_id", cha)
    bo2.send_wrap(packet.eSTC_Fake_select_cha, v)
    ui_choice.enable = false
  end
  local function on_leave(item)
    if not item.is_owner then
      return
    end
    ui_packet.recv_wrap_signal_remove(packet.eSTC_Fake_select_cha, sig_name)
    ui_choice.enable = true
  end
  item.on_enter = on_enter
  item.on_leave = on_leave
  return item
end
function task_item_update_gzs(glist)
  local item = {is_owner = false}
  local function on_enter(item)
    item.result = ui_tool.c_task_result_finish_item
    ui_minimap.update_gzs_list(glist)
  end
  item.on_enter = on_enter
  return item
end
function task_cha_delete(cha)
  if cha == nil then
    return
  end
  local clist = sys.variant()
  local glist = sys.variant()
  ui_tool.task_insert({
    items = {
      task_item_cha_delete(cha),
      ui_startup.task_item_cha_list(clist),
      ui_startup.task_item_show_choice(clist, nil)
    }
  })
end
function task_cha_restore(cha)
  if cha == nil then
    return
  end
  local clist = sys.variant()
  local glist = sys.variant()
  ui_tool.task_insert({
    items = {
      task_item_cha_restore(cha),
      ui_startup.task_item_cha_list(clist),
      ui_startup.task_item_show_choice(clist, nil),
      task_item_cha_select(cha)
    }
  })
end
function task_cha_create(cha)
  local clist = sys.variant()
  ui_tool.task_insert({
    items = {
      task_item_cha_create(cha),
      ui_startup.task_item_cha_list(clist),
      task_item_cha_create_gate(),
      ui_startup.task_item_show_choice(clist, nil)
    }
  })
end
function task_cha_selected(cha)
  local glist = sys.variant()
  ui_tool.task_insert({
    items = {
      task_item_cha_select(cha),
      ui_startup.task_item_gzs_list(glist),
      ui_startup.task_item_show_choice(nil, glist)
    }
  })
end
function task_update_gzs()
  local glist = sys.variant()
  ui_tool.task_insert({
    items = {
      ui_startup.task_item_gzs_list(glist),
      task_item_update_gzs(glist)
    }
  })
end
