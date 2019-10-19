cvalue_color_red = L("FFFF0000")
cvalue_color_green = L("FF00FF00")
g_init_atb_monitor_value = false
local award_msg_index = 33
local lost_msg_index = 34
local msg_addition = {size = 0}
local msg_reduce = {size = 0}
local c_award_msg = 0
local c_lost_msg = 1
local g_out_put_info = {
  reduce_index = 0,
  add_index = 0,
  cur_stack = 1,
  stack = {}
}
g_earn_money = {}
function init_earn_money_data()
  g_earn_money = {
    stack = {},
    cur_stack = 1,
    push_stack = 1,
    size = 0,
    timer = false
  }
end
function on_earn_money(data)
  local function on_time_out_put_message()
    if g_earn_money == nil or sys.check(bo2.player) ~= true then
      return
    end
    if g_earn_money.cur_stack > g_earn_money.size then
      g_earn_money.timer = false
      return
    end
    bo2.PlaySound2D(593, false, false)
    bo2.player:LogTag(bo2.eTagID_EarnMoney, g_earn_money.stack[g_earn_money.cur_stack])
    g_earn_money.cur_stack = g_earn_money.cur_stack + 1
    bo2.AddTimeEvent(5, on_time_out_put_message)
  end
  g_earn_money.size = g_earn_money.size + 1
  g_earn_money.stack[g_earn_money.push_stack] = data
  g_earn_money.push_stack = g_earn_money.push_stack + 1
  if g_earn_money.timer == false then
    g_earn_money.timer = true
    bo2.AddTimeEvent(25, on_time_out_put_message)
  end
end
function reset_out_put_info()
  g_out_put_info = {
    add_index = 0,
    reduce_index = 0,
    cur_stack = 1,
    stack = {}
  }
end
function resert_msg()
  msg_addition = {size = 0}
  msg_reduce = {size = 0}
end
local init_once = function()
  atb_monitor_base = {}
  atb_monitor_base[0] = {
    idx = bo2.eAtb_HPMax,
    value = 0
  }
  atb_monitor_base[1] = {
    idx = bo2.eAtb_MPMax,
    value = 0
  }
  atb_monitor_base[2] = {
    idx = bo2.eAtb_Vit,
    value = 0
  }
  atb_monitor_base[3] = {
    idx = bo2.eAtb_Ske,
    value = 0
  }
  atb_monitor_base[4] = {
    idx = bo2.eAtb_Agi,
    value = 0
  }
  atb_monitor_base[5] = {
    idx = bo2.eAtb_Str,
    value = 0
  }
  atb_monitor_base[6] = {
    idx = bo2.eAtb_Int,
    value = 0
  }
  atb_monitor_base[7] = {
    idx = bo2.eAtb_AntiPuzzle,
    value = 0
  }
  atb_monitor_base[8] = {
    idx = bo2.eAtb_AntiRestricted,
    value = 0
  }
  atb_monitor_base[9] = {
    idx = bo2.eAtb_AntiDrain,
    value = 0
  }
  atb_monitor_base[10] = {
    idx = bo2.eAtb_AntiEbb,
    value = 0
  }
  atb_monitor_base[11] = {
    idx = bo2.eAtb_Cha_AntiTumble,
    value = 0
  }
  atb_monitor_base[12] = {
    idx = bo2.eAtb_Cha_AntiFloat,
    value = 0
  }
  atb_monitor_base[13] = {
    idx = bo2.eAtb_Cha_AntiRideDown,
    value = 0
  }
  atb_monitor_base[14] = {
    idx = bo2.eAtb_Cha_AntiHitBack,
    value = 0
  }
  atb_monitor_base[15] = {
    idx = bo2.eAtb_Cha_AntiHitFly,
    value = 0
  }
  atb_monitor_base[16] = {
    idx = bo2.eAtb_TenacityLv,
    value = 0
  }
  atb_monitor_base[17] = {
    idx = bo2.eAtb_TransferLv,
    value = 0
  }
  atb_monitor_base[18] = {
    idx = bo2.eAtb_NicetyLv,
    value = 0
  }
  atb_monitor_base[19] = {
    idx = bo2.eAtb_PhyDmgMin,
    value = 0
  }
  atb_monitor_base[20] = {
    idx = bo2.eAtb_PhyDmgMax,
    value = 0
  }
  atb_monitor_base[21] = {
    idx = bo2.eAtb_PhyDefendLv,
    value = 0
  }
  atb_monitor_base[22] = {
    idx = bo2.eAtb_PhyAttackLv,
    value = 0
  }
  atb_monitor_base[23] = {
    idx = bo2.eAtb_PhyHitLv,
    value = 0
  }
  atb_monitor_base[24] = {
    idx = bo2.eAtb_PhyDeadLv,
    value = 0
  }
  atb_monitor_base[25] = {
    idx = bo2.eAtb_IgnorePhyDefend,
    value = 0
  }
  atb_monitor_base[26] = {
    idx = bo2.eAtb_MgcDmgMin,
    value = 0
  }
  atb_monitor_base[27] = {
    idx = bo2.eAtb_MgcDmgMax,
    value = 0
  }
  atb_monitor_base[28] = {
    idx = bo2.eAtb_MgcDefendLv,
    value = 0
  }
  atb_monitor_base[29] = {
    idx = bo2.eAtb_MgcAttackLv,
    value = 0
  }
  atb_monitor_base[30] = {
    idx = bo2.eAtb_MgcHitLv,
    value = 0
  }
  atb_monitor_base[31] = {
    idx = bo2.eAtb_MgcDeadLv,
    value = 0
  }
  atb_monitor_base[32] = {
    idx = bo2.eAtb_IgnoreMgcDefend,
    value = 0
  }
  atb_monitor_base[33] = {
    idx = bo2.eAtb_TransferRate,
    value = 0,
    odds = 1
  }
  atb_monitor_base[34] = {
    idx = bo2.eAtb_MgcHit,
    value = 0,
    odds = 1
  }
  atb_monitor_base[35] = {
    idx = bo2.eAtb_PhyHit,
    value = 0,
    odds = 1
  }
  atb_monitor_base[36] = {
    idx = bo2.eAtb_PhyHitRate,
    value = 0,
    odds = 1
  }
  atb_monitor_base[37] = {
    idx = bo2.eAtb_MgcHitRate,
    value = 0,
    odds = 1
  }
  atb_monitor_base[38] = {
    idx = bo2.eAtb_MgcDmgRemit,
    value = 0
  }
  atb_monitor_base[39] = {
    idx = bo2.eAtb_Cha_CutTotalTransferRate,
    value = 0,
    odds = 1
  }
  atb_monitor_base[40] = {
    idx = bo2.eAtb_Cha_CutTotalTransferEffect,
    value = 0,
    odds = 1
  }
  local fix_atb_monitor_base_name = function()
    for i, v in pairs(atb_monitor_base) do
      local pAtbExcel = bo2.gv_atb_player:find(v.idx)
      if pAtbExcel ~= nil then
        atb_monitor_base[i].name = pAtbExcel.name
      end
    end
  end
  fix_atb_monitor_base_name()
  atb_monitor = {}
  init_earn_money_data()
end
function build_atb_monitor_base(obj)
  for i, v in pairs(atb_monitor_base) do
    local atb_idx = v.idx
    local atb_value = obj:get_atb(atb_idx)
    v.value = atb_value
  end
end
function on_timer_log_atb_msg()
  local player = bo2.player
  if sys.check(player) ~= true then
    reset_out_put_info()
    resert_msg()
    g_timer_log_atb_msg.suspended = true
    return
  end
  local function on_call_back_log_msg()
    local cur_stack = g_out_put_info.stack[g_out_put_info.cur_stack]
    if sys.check(cur_stack) ~= true then
      g_timer_log_atb_msg.suspended = true
      return false
    end
    local _index = cur_stack.index
    if _index == nil then
      g_timer_log_atb_msg.suspended = true
      return false
    end
    _index = _index - 1
    if _index <= 0 then
      g_out_put_info.cur_stack = g_out_put_info.cur_stack + 1
    else
      g_out_put_info.stack[g_out_put_info.cur_stack].index = _index
    end
    function on_log_tag(table_msg, index, msg_index, add_index)
      for i = index, table_msg.size - 1 do
        if sys.check(table_msg[i]) and table_msg[i].empty ~= true then
          player:LogTag(msg_index, 1, table_msg[i])
          if add_index ~= true then
            g_out_put_info.reduce_index = i + 1
          else
            g_out_put_info.add_index = i + 1
          end
          return true
        end
      end
    end
    local index = g_out_put_info.add_index
    local msg_index = award_msg_index
    if cur_stack._type == c_lost_msg then
      index = g_out_put_info.reduce_index
      msg_index = lost_msg_index
      return on_log_tag(msg_reduce, index, msg_index, false)
    else
      return on_log_tag(msg_addition, index, msg_index, true)
    end
  end
  g_timer_log_atb_msg.suspended = false
  if on_call_back_log_msg() ~= true then
    reset_out_put_info()
    resert_msg()
    ui_atb_monitor.g_timer_log_atb_msg.suspended = true
    return
  end
  if g_out_put_info.reduce_index >= msg_reduce.size and g_out_put_info.add_index >= msg_addition.size then
    reset_out_put_info()
    resert_msg()
    g_timer_log_atb_msg.suspended = true
  end
end
function _on_timer_msg_atb_changed()
  local msg_addition, msg_reduce
  local msg_insert = function(insert_msg, _msg)
    if _msg == nil then
      return insert_msg
    else
      return _msg .. L("\n") .. insert_msg
    end
  end
  local msg
  for i = 0, #atb_monitor_base - 1 do
    if atb_monitor[i] ~= nil then
      local _out_put_value = atb_monitor_base[i].value - atb_monitor[i].value
      if _out_put_value < 0 then
        local msg
        if atb_monitor_base[i].odds ~= nil then
          msg = sys.format("%s %d%%", atb_monitor_base[i].name, _out_put_value / 100)
        else
          msg = sys.format("%s %d", atb_monitor_base[i].name, _out_put_value)
        end
        msg_addition = msg_insert(msg, msg_addition)
      elseif _out_put_value > 0 then
        local msg
        if atb_monitor_base[i].odds ~= nil then
          msg = sys.format("%s +%d%%", atb_monitor_base[i].name, _out_put_value / 100)
        else
          msg = sys.format("%s +%d", atb_monitor_base[i].name, _out_put_value)
        end
        msg_reduce = msg_insert(msg, msg_reduce)
      end
      atb_monitor[i] = nil
    end
  end
  if msg_reduce ~= nil then
    ui_tool.note_insert(msg_reduce, cvalue_color_green)
  end
  if msg_addition ~= nil then
    ui_tool.note_insert(msg_addition, cvalue_color_red)
  end
end
function on_msg_atb_changed()
  local player = bo2.player
  if sys.check(player) ~= true then
    return
  end
  local msg_insert = function(table_msg, msg, value)
    if table_msg == nil then
      table_msg = {}
      table_msg.size = 0
    elseif value < 0 then
      table_msg[table_msg.size] = sys.format("%s %d", msg, value)
    else
      table_msg[table_msg.size] = sys.format("%s +%d", msg, value)
    end
  end
  local cur_add_size = 0
  local cur_reduce_size = 0
  for i = 0, #atb_monitor_base do
    if atb_monitor[i] ~= nil then
      local _out_put_value = atb_monitor_base[i].value - atb_monitor[i].value
      if _out_put_value < 0 then
        local msg
        if atb_monitor_base[i].odds ~= nil then
          msg = sys.format("%s %d%%", atb_monitor_base[i].name, _out_put_value / 100)
        else
          msg = sys.format("%s %d", atb_monitor_base[i].name, _out_put_value)
        end
        msg_reduce[msg_reduce.size] = msg
        msg_reduce.size = msg_reduce.size + 1
        cur_reduce_size = cur_reduce_size + 1
      elseif _out_put_value > 0 then
        local msg
        if atb_monitor_base[i].odds ~= nil then
          msg = sys.format("%s +%d%%", atb_monitor_base[i].name, _out_put_value / 100)
        else
          msg = sys.format("%s +%d", atb_monitor_base[i].name, _out_put_value)
        end
        msg_addition[msg_addition.size] = msg
        msg_addition.size = msg_addition.size + 1
        cur_add_size = cur_add_size + 1
      end
      atb_monitor[i] = nil
    end
  end
  if cur_add_size > 0 then
    table.insert(g_out_put_info.stack, {_type = c_award_msg, index = cur_add_size})
  end
  if cur_reduce_size > 0 then
    table.insert(g_out_put_info.stack, {_type = c_lost_msg, index = cur_reduce_size})
  end
  local function output_msg(player, table_msg, add)
    if table_msg == nil or table_msg.size <= 0 then
      return false
    end
    local msg_index = award_msg_index
    if add == false then
      msg_index = lost_msg_index
    end
    for i = 0, table_msg.size - 1 do
      if sys.check(table_msg[i]) and table_msg[i].empty ~= true then
        on_timer_log_atb_msg()
        return true
      end
    end
    return false
  end
  if g_timer_log_atb_msg.suspended == true then
    local bLog = output_msg(player, msg_addition, true)
    if bLog ~= true then
      output_msg(player, msg_reduce, false)
    end
  end
end
function enable_timer_atb_monitor()
  g_timer_atb_monitor.suspended = true
end
function update_atb_monitor_base(obj)
  for i = 0, #atb_monitor_base do
    local v = atb_monitor_base[i]
    if v ~= nil then
      local atb_idx = v.idx
      local atb_value = obj:get_atb(atb_idx)
      if atb_value ~= v.value then
        if atb_monitor[i] == nil then
          atb_monitor[i] = {
            idx = bo2.eAtb_PhyDefendLv,
            value = v.value,
            monitor_time = 0
          }
        elseif atb_monitor[i].value == atb_value then
          atb_monitor[i] = nil
        end
        v.value = atb_value
      end
    end
  end
  on_msg_atb_changed()
end
function on_self_atb(obj, ft, idx)
  if true ~= g_init_atb_monitor_value then
    local obj = bo2.player
    if sys.check(obj) then
      build_atb_monitor_base(obj)
    end
    g_init_atb_monitor_value = true
  end
  update_atb_monitor_base(obj)
end
function on_self_enter()
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return false
  end
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, -1, on_self_atb, "ui_atb_monitor.on_self_atb")
  local clean_date = function()
    g_timer_atb_monitor.suspended = true
    g_init_atb_monitor_value = false
    atb_monitor = {}
  end
  clean_date()
end
function on_self_enter_clear()
  local clean_date = function()
    g_timer_atb_monitor.suspended = true
    g_init_atb_monitor_value = false
    atb_monitor = {}
  end
  clean_date()
  init_earn_money_data()
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter_clear, "ui_atb_monitor.on_self_enter")
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_atb_monitor.on_self_enter")
init_once()
