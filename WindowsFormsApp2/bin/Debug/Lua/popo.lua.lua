local popo_sound = 533
battle_time_out = 45
function on_init()
  m_popo_sets = {}
  m_dlg_sets = {}
  m_popo_location = {
    postb = {
      0,
      0,
      0,
      0,
      0,
      0
    },
    cur_pos = 1,
    vismax = 5
  }
end
function default_closedlg()
end
local show_dialog = function(popo_def, data, start_time)
  local dialog_fn = sys.get(popo_def.dialog)
  if dialog_fn then
    local last_time
    local cur_time = os.time()
    if popo_def.auto_close_dlg == true and os.difftime(cur_time, start_time) < popo_def.timeout then
      last_time = popo_def.timeout - os.difftime(cur_time, start_time)
      table.insert(m_dlg_sets, {
        begin_time = cur_time,
        last_time = last_time,
        close_fn = popo_def.close_dlg_fn
      })
    end
    if last_time ~= nil then
      last_time = last_time * 1000
    end
    if popo_def.close_fn_timer == false then
      if popo_def.name == "death_ui" then
        dialog_fn(popo_def, data, (os.difftime(cur_time, start_time)))
      else
        dialog_fn(popo_def, data)
      end
    else
      dialog_fn(popo_def, data, last_time)
    end
  end
end
local delete_popo = function(idx, popo)
  if popo.icon_ctrl then
    local index = popo.pos_index
    m_popo_location.postb[index] = 0
    popo.icon_ctrl.visible = false
    popo.icon_ctrl:post_release()
  end
  table.remove(m_popo_sets, idx)
end
local function check_popo_livetime()
  local i = 1
  local cur_time = os.time()
  while i <= #m_popo_sets do
    local popo = m_popo_sets[i]
    if os.difftime(cur_time, popo.start_time) > popo.popo_def.timeout then
      delete_popo(i, popo)
      if popo.popo_def.auto_show == true then
        show_dialog(popo.popo_def, popo.packet, popo.start_time)
      else
        ui_chat.show_ui_text_id(73034)
      end
    else
      i = i + 1
    end
  end
end
function SetTip(ctrl, popo)
  local tip = ctrl:lookup("icon/btn"):find_plugin("tip")
  if popo.packet and popo.packet:has(packet.key.ui_text) then
    tip.text = popo.packet:get(packet.key.ui_text).v_string
  else
    tip.text = popo.popo_def.tip
  end
end
function find_pos_index()
  local tb = m_popo_location.postb
  for i, v in ipairs(tb) do
    if v == 0 then
      return i
    end
  end
  return 0
end
local check_popo_need_create = function()
  for i = 1, 7 do
    local popo = m_popo_sets[i]
    if not popo then
      return
    end
    if not popo.icon_ctrl then
      local pos = find_pos_index()
      local index = 0
      local max = m_popo_location.vismax
      if pos == 0 then
        break
      elseif pos < max and pos > 0 then
        index = pos
      elseif pos >= max then
        index = pos % max + 1
      end
      local show_panel = ui.find_control("$frame:player_show")
      local subctrl = ui.create_control(m_work_panel)
      subctrl:load_style("$gui/frame/popo/popo.xml", "icon")
      local r = ui.rect(0, 0, (max - index) * 32, 7)
      subctrl.margin = r
      m_popo_location.postb[pos] = 1
      m_popo_sets[i].pos_index = pos
      if popo.popo_def.icon == "default" then
        btn_pic.image = "$image\\popo\\tip.png|2,2,202,44"
      else
        btn_pic.image = "$image\\popo\\" .. popo.popo_def.icon .. ".png|2,2,202,44"
      end
      subctrl:move_to_head()
      SetTip(subctrl, popo)
      popo.icon_ctrl = subctrl
      popo.icon_ctrl.visible = false
    end
  end
end
function update_work_panel()
  check_popo_livetime()
  check_popo_need_create()
end
function on_dlg_update()
  local i = 1
  local cur_time = os.time()
  while i <= #m_dlg_sets do
    local dlg = m_dlg_sets[i]
    if os.difftime(cur_time, dlg.begin_time) > dlg.last_time then
      local dialog_fn = sys.get(dlg.close_fn)
      if dialog_fn then
        dialog_fn(false)
      end
      table.remove(m_dlg_sets, i)
    else
      i = i + 1
    end
  end
end
local function new_icon(popo_def, data)
  table.insert(m_popo_sets, {
    start_time = os.time(),
    popo_def = popo_def,
    packet = data
  })
  check_popo_need_create()
end
local isPopoFull = function(popoDef)
  local cnt = 0
  for i, v in ipairs(m_popo_sets) do
    if v.popo_def == popoDef then
      cnt = cnt + 1
    end
  end
  return cnt >= popoDef.max_count
end
local notice_callback = function(popo_def, data)
  local timeout = popo_def.timeout
  if timeout ~= nil and timeout > 25 then
    timeout = timeout - 10
  end
  ui_widget.ui_wnd.show_notice({
    text = data[packet.key.ui_text],
    timeout = timeout,
    force_timeout = true
  })
end
function AddPopo(types, data)
  local popo_def = m_popo_def[types]
  if not popo_def then
    ui.console_print("undefined popo type,%s", types)
    return
  end
  local notice = popo_def.notice
  if notice then
    local fn = notice.callback
    if fn == nil then
      fn = notice_callback
    end
    sys.pcall(fn, popo_def, data)
  end
  if popo_def.direct_show then
    show_dialog(popo_def, data, os.time())
  elseif not isPopoFull(popo_def) then
    new_icon(popo_def, data)
  end
  bo2.PlaySound2D(popo_sound, false)
end
function no_confirm_dialog(popo_def, data, duration_time)
  local callback = sys.get(popo_def.callback)
  if sys.check(callback) then
    callback("yes", data)
  end
end
function default_dialog(popo_def, data, duration_time)
  local dialog = {
    text = data:get(packet.key.ui_text).v_string,
    modal = popo_def.modal,
    btn_confirm = 1,
    btn_cancel = 1,
    timeout = duration_time,
    callback = function(ret)
      local callback = sys.get(popo_def.callback)
      if not callback then
        return
      end
      if ret.result == 0 then
        callback("no", data)
      elseif ret.result == 1 then
        callback("yes", data)
      end
    end
  }
  ui_widget.ui_msg_box.show_common(dialog)
end
function default_fdelate_closedlg(vis)
  ui_org.ui_family_delate.w_delate_main.visible = vis
end
function default_gdelate_closedlg(vis)
  ui_guild_mod.ui_delate.w_delate_main.visible = vis
end
function delate_dialog(popo_def, data)
  if popo_def.name == "fdelate" then
    ui_org.ui_family_delate.w_delate_main.visible = true
  end
  if popo_def.name == "gdelate" then
    ui_guild_mod.ui_delate.w_delate_main.visible = true
  end
end
local m_flash_time = {}
setmetatable(m_flash_time, {__mode = "kv"})
function FlashPopo(ctrl)
  while ctrl do
    m_flash_time[ctrl] = m_flash_time[ctrl] or os.time()
    local last_time = m_flash_time[ctrl]
    local cur_time = os.time()
    if os.difftime(cur_time, last_time) > 0.8 then
      local halo = ctrl:lookup("icon/halo")
      if halo ~= nil then
        halo.visible = not halo.visible
        m_flash_time[ctrl] = cur_time
      end
    end
    ctrl = ctrl.next
  end
end
function on_flash_popo()
  local ctrl = m_work_panel.control_head
  FlashPopo(ctrl)
end
local find_popo = function(ctrl)
  for k, popo in ipairs(m_popo_sets) do
    if popo.icon_ctrl == ctrl then
      return k, popo
    end
  end
end
function on_click_popo(btn)
  local idx, popo = find_popo(btn.parent)
  if not idx then
    return
  end
  delete_popo(idx, popo)
  show_dialog(popo.popo_def, popo.packet, popo.start_time)
end
function ack_cmn_invite_popo(click, data)
  local v = sys.variant()
  v:set(packet.key.ui_invite_id, data:get(packet.key.ui_invite_id))
  if "yes" == click then
    v:set(packet.key.cmn_agree_ack, 1)
  else
    v:set(packet.key.cmn_agree_ack, 0)
  end
  bo2.send_variant(packet.eCTS_UI_CommonInviteAck, v)
end
function ack_arena_popo(click, data)
  if "yes" == click then
    ui_match.on_click_apply_enter()
  end
end
function on_battle_popo_packet(data, timeout)
  local v = sys.variant()
  v:set(packet.key.cmn_agree_ack, 1)
  if timeout == true then
    v:set(packet.key.cmn_recver_id, 1)
  end
  local my_type = data:get(packet.key.battle_type).v_int
  v:set(packet.key.battle_type, my_type)
  bo2.send_variant(packet.eCTS_UI_Battle_ReplyAsk, v)
end
function battle_dialog(popo_def, data, duration_time)
  local function on_time_event()
    on_battle_popo_packet(data, true)
  end
  local time = 25 * battle_time_out
  bo2.AddTimeEvent(time, on_time_event)
  default_dialog(popo_def, data, duration_time)
end
function ask_battle_popo(click, data)
  local agree = "yes" == click and 1 or 0
  if agree == 0 then
    return
  end
  on_battle_popo_packet(data, false)
end
function ask_battle_popo_green(click, data)
  ask_battle_popo(click, data)
  if "yes" == click then
    return
  end
  ui_tool.ui_xinshou_animation_xz.show_waitlist_popo()
end
function ask_view_help(click, data)
  if "yes" == click then
    local page = data:get(L("page")).v_int
    ui_bo2_guide.on_view_mtf(ui_bo2_guide.theme_type_topic, page)
  end
end
function ask_cavalier_championship_popo(click, data)
  if "yes" == click then
    local v = sys.variant()
    v:set(packet.key.battlegroup_id, data:get(packet.key.battlegroup_id))
    bo2.send_variant(packet.eCTS_CavalierChampionship_UIEnterBattle, v)
  end
end
function ask_cavalier_npc_championship_popo(click, data)
  if "yes" == click then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_UI_CavalierChampionship_EnterBattle, v)
  end
end
function ask_champion_group_confirm(click, data)
  if "yes" == click then
    local v = sys.variant()
    v:set(packet.key.fate_second_confirm, 1)
    bo2.send_variant(packet.eCTS_CavalierChampionship_FateTeamConfirm, v)
  else
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_CavalierChampionship_FateTeamConfirm, v)
  end
end
function ask_guild_meet_trans(click, data)
  local iAck = 0
  if "yes" == click then
    iAck = 1
  end
  local v = data
  data:set(packet.key.sociality_acceptrequest, iAck)
  bo2.send_variant(packet.eCTS_Sociality_CommonInviteAck, v)
end
function ask_maze_trans(click, data)
  local iAck = 0
  if "yes" ~= click then
    ui_tool.note_insert(ui.get_text("cross_line|refuse_maze_popo"), L("FFFF0000"))
    return
  else
    iAck = 1
  end
  local scn = bo2.scn
  if sys.check(scn) ~= true then
    return
  end
  local player_scn_id = scn.excel.id
  local scn_table = {}
  scn_table[2] = 1
  scn_table[101] = 1
  scn_table[102] = 1
  scn_table[103] = 1
  if scn_table[player_scn_id] == nil then
    ui_tool.note_insert(ui.get_text("cross_line|error_maze_scn"), L("FFFF0000"))
    return
  end
  local v = data
  data:set(packet.key.sociality_acceptrequest, iAck)
  bo2.send_variant(packet.eCTS_Globalmisc_CommonInviteAck, v)
end
function ask_cross_line_battle_trans(click, data)
  local iAck = 0
  if "yes" == click then
    iAck = 1
  else
    if bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Cross_Line_Scn_ID) == 0 then
      ui_tool.note_insert(ui.get_text("cross_line|refuse_popo"), L("FFFF0000"))
    else
      ui_tool.note_insert(ui.get_text("cross_line|refuse_popo2"), L("FFFF0000"))
      local v = data
      data:set(packet.key.sociality_acceptrequest, iAck)
      bo2.send_variant(packet.eCTS_Globalmisc_CommonInviteAck, v)
      ui_cross_line.g_cross_line_item_flag = 1
      local v2 = sys.variant()
      v2:set(packet.key.out_cl_queue, 1)
      bo2.send_variant(packet.eCTS_UI_RequestCrossLineData, v2)
    end
    return
  end
  local scn = bo2.scn
  if sys.check(scn) ~= true then
    return
  end
  local player_scn_id = scn.excel.id
  local scn_table = {}
  scn_table[101] = 1
  scn_table[102] = 1
  scn_table[103] = 1
  if scn_table[player_scn_id] == nil then
    ui_tool.note_insert(ui.get_text("cross_line|error_scn"), L("FFFF0000"))
    return
  end
  local v = data
  data:set(packet.key.sociality_acceptrequest, iAck)
  bo2.send_variant(packet.eCTS_Globalmisc_CommonInviteAck, v)
end
function battle_team_invite(click, data)
  local v = sys.variant()
  v:set(packet.key.scn_excel_id, bo2.scn.scn_excel.id)
  v:set(packet.key.ui_invite_id, data:get(packet.key.ui_invite_id))
  if "yes" == click then
    local msg = {
      text = ui.get_text("battle|battleteam_invite_sure"),
      modal = true,
      btn_confirm = 1,
      btn_cancel = 1,
      callback = function(data)
        if data.result == 1 then
          local need_money = bo2.gv_define:find(623).value.v_int
          if need_money > bo2.player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney) then
            ui_chat.show_ui_text_id(1859)
            v:set(packet.key.cmn_state, 1)
            v:set(packet.key.cmn_agree_ack, 0)
          else
            v:set(packet.key.cmn_agree_ack, 1)
          end
        else
          v:set(packet.key.cmn_agree_ack, 0)
        end
        bo2.send_variant(packet.eCTS_BattleTeam_TeamInviteAsk, v)
      end
    }
    ui_widget.ui_msg_box.show_common(msg)
  else
    v:set(packet.key.cmn_agree_ack, 0)
    bo2.send_variant(packet.eCTS_BattleTeam_TeamInviteAsk, v)
  end
end
function del_popo_by_name(name)
  for i = 1, #m_popo_sets do
    local popo = m_popo_sets[i]
    if popo.popo_def.name == name then
      delete_popo(i, popo)
      return
    end
  end
end
function find_popo_by_name(name)
  for i = 1, #m_popo_sets do
    local popo = m_popo_sets[i]
    if popo.popo_def.name == name then
      return true
    end
  end
  return false
end
function jiaoben_popo_ack(click, data)
  local v = sys.variant()
  ui.log("handle")
  ui.log(data:get(packet.key.scnobj_handle))
  v:set(packet.key.jiaoben_popo_data, data:get(packet.key.jiaoben_popo_data))
  v:set(packet.key.jiaoben_popo_sig, data:get(packet.key.jiaoben_popo_sig))
  if "yes" == click then
    v:set(packet.key.cmn_agree_ack, 1)
  else
    v:set(packet.key.cmn_agree_ack, 0)
  end
  bo2.send_variant(packet.eCTS_jiaobenpopo_ReplyAsk, v)
end
local g_current_index = 0
local g_timer_data = {}
function on_init_timer_data()
  g_timer_data = {
    current_index = 0,
    close = false,
    num = 1,
    second = 1,
    plus_second = 0
  }
end
function on_esc_vis_timer_popo(w, vis)
  if vis == true then
    ui_popo.g_timer.suspended = false
  else
    if g_timer_data.close == true then
      ui_popo.g_timer.suspended = true
      return
    end
    w.visible = true
    local function on_call_back_close(msg)
      if sys.check(msg) and msg.result == 0 then
        return true
      end
      g_timer_data.close = true
      w.visible = false
      local v = sys.variant()
      bo2.send_variant(packet.eCTS_Sociality_CancelTransRequest, v)
    end
    local msg = {
      callback = on_call_back_close,
      text = ui.get_text("tip|remove_trans")
    }
    ui_widget.ui_msg_box.show_common(msg)
  end
end
function on_timer_set_text()
  if g_timer_data.current_index == nil then
    ui_popo.g_timer.suspended = true
    return
  end
  g_timer_data.current_index = g_timer_data.current_index + 1
  if g_timer_data.current_index >= 5 then
    g_timer_data.second = g_timer_data.second - 1
    if g_timer_data.plus_second > 0 then
      g_timer_data.plus_second = g_timer_data.plus_second - 1
    end
  end
  if g_timer_data.plus_second <= 0 then
    g_timer_data.num = g_timer_data.num - 1
    if 1 >= g_timer_data.num then
      g_timer_data.num = 1
    end
  end
  if g_timer_data.current_index >= 5 then
    g_timer_data.current_index = 0
  end
  ui_popo.timer_popo_text.mtf = ui_widget.merge_mtf(g_timer_data, sys.format(ui.get_text("tip|trans_text")))
  if g_timer_data.second <= 0 then
    g_timer_data.close = true
    w_timer_popo.visible = false
  end
end
function HandleShowTimerPopo(cmd, data)
  local bShow = data:get(packet.key.chat_show).v_int
  if bShow == 0 then
    g_timer_data.close = true
    w_timer_popo.visible = false
    return
  end
  w_timer_popo.visible = true
  on_init_timer_data()
  g_timer_data.num = data:get(packet.key.cmn_id).v_int
  g_timer_data.second = data:get(packet.key.org_time).v_int
  g_timer_data.plus_second = data:get(packet.key.marquee_wait_time).v_int
  on_timer_set_text()
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_ShowTimerPopo, HandleShowTimerPopo, "ui_popo:HandleShowTimerPopo")
function ar()
  local var = sys.variant()
  var:set(packet.key.ui_popo_type, L("arena"))
  handleShowPopo(cmd, var)
end
