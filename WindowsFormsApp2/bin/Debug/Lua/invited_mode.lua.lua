local iWaitPKMinDeposit = bo2.gv_define:find(927).value.v_int
local iWaitPKMaxDeposit = bo2.gv_define:find(928).value.v_int
local check_player_money_enough = function(target_money)
  if bo2.player then
    local money = bo2.player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    if target_money <= money then
      return true
    end
  end
  ui_safe.notify(2141)
  return false
end
function chg_invited_mode(obj, ft, idx)
  if obj == nil then
    return
  end
  local v = obj:get_flag_objmem(idx)
  if v == 1 then
    obj:setstopflag(bo2.eObjStopFlag_NoMove, bo2.eStopType_Skill, true)
    obj:setstopflag(bo2.eObjStopFlag_NoSkill, bo2.eStopType_Skill, true)
    obj:setstopflag(bo2.eObjStopFlag_NoJink, bo2.eStopType_Skill, true)
    obj:setstopflag(bo2.eObjStopFlag_NoJump, bo2.eStopType_Skill, true)
    obj:setstopflag(bo2.eObjStopFlag_NoDefend, bo2.eStopType_Skill, true)
  elseif v == 0 then
    obj:setstopflag(bo2.eObjStopFlag_NoMove, bo2.eStopType_Skill, false)
    obj:setstopflag(bo2.eObjStopFlag_NoSkill, bo2.eStopType_Skill, false)
    obj:setstopflag(bo2.eObjStopFlag_NoJink, bo2.eStopType_Skill, false)
    obj:setstopflag(bo2.eObjStopFlag_NoJump, bo2.eStopType_Skill, false)
    obj:setstopflag(bo2.eObjStopFlag_NoDefend, bo2.eStopType_Skill, false)
  end
end
function on_invited_input_change(w, key)
  local data = ui_widget.ui_msg_box.get_data(w)
  if data == nil then
    w.visible = false
    return
  end
  if key == ui.VK_ESCAPE then
    data.result = 0
    ui_widget.ui_msg_box.invoke(data)
  end
end
function on_invited_input_enter(w)
  local data = ui_widget.ui_msg_box.get_data(w)
  if data == nil then
    w.visible = false
    return
  end
  data.result = 1
  ui_widget.ui_msg_box.invoke(data)
end
function on_btn_invited_click(btn)
  local player = bo2.player
  local state = player:get_flag_objmem(bo2.eFlagObjMemory_WaitPK_Deposit)
  local isFighting = player:get_flag_objmem(bo2.eFlagObjMemory_FightState)
  if isFighting == 1 then
    ui_tool.note_insert(ui.get_text("map|err_cant_open_pk"), "FFFF00")
    return
  end
  if state ~= 0 then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_UI_On_Invited_PK, v)
    return
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/minimap/invited_mode.xml",
    style_name = "confirm_pk_msg_box",
    callback = function(msg)
      if msg.result == 1 then
        local frm_input = msg.window:search("frm_input")
        local input_money = 0
        if frm_input ~= nil then
          input_money = frm_input:search("g").text.v_int * 10000 + frm_input:search("s").text.v_int * 100
        end
        if input_money > iWaitPKMaxDeposit or input_money < iWaitPKMinDeposit then
          ui_safe.notify(2136)
          return
        end
        if check_player_money_enough(input_money) == false then
          return
        end
        local v = sys.variant()
        v:set(packet.key.pk_deposit, input_money)
        bo2.send_variant(packet.eCTS_UI_On_Invited_PK, v)
      end
    end,
    modal = true
  })
end
function on_player_enter(obj)
  ui.log("on_player_enter")
  bo2.player:insert_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_WaitPK_Deposit, chg_invited_mode, "ui_minimap.insert_on_invited")
end
function on_player_leave(obj)
  ui.log("on_player_level")
  obj:remove_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_WaitPK_Deposit, "ui_minimap.remove_on_invited")
end
function handleAskPlayer(cmd, data)
  if data:get(packet.key.ui_window_type).v_int == packet.key.waitpk_win_type then
    do
      local deposit = data:get(packet.key.pk_deposit).v_int
      local function on_msg(msg)
        if check_player_money_enough(deposit) == false then
          return
        end
        local var = sys.variant()
        var:set(packet.key.scnmatch_id, data:get(packet.key.scnmatch_id))
        var:set(packet.key.cmn_agree_ack, msg.result)
        bo2.send_variant(packet.eCTS_UI_ReplyScnMatchAsk, var)
      end
      local msg = {
        callback = on_msg,
        btn_confirm = true,
        btn_cancel = true,
        modal = false,
        close_on_leavascn = true
      }
      msg.text = ui_widget.merge_mtf({money = deposit}, ui.get_text("map|continue_pk_msg_des"))
      ui_widget.ui_msg_box.show_common(msg)
    end
  end
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_OpenWindow, handleAskPlayer, "ui_minmap:handleAskPlayer")
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_player_enter, "ui_minmap:on_player_enter")
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_leave, on_player_leave, "ui_minmap:on_player_leave")
