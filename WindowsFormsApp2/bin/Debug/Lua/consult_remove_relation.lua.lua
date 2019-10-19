remove_request_id = nil
npc_func_id = nil
remove_relation_type = nil
function begin_remove(cmd, data)
  local remove_player_name = data:get(packet.key.sociality_tarplayername).v_string
  remove_relation_type = data:get(packet.key.sociality_twrelationtype).v_int
  remove_request_id = data:get(packet.key.sociality_requestid)
  npc_func_id = data:get(packet.key.sociality_npcfuncid).v_int
  local relation_name = ui_sociality.get_relation_name(remove_relation_type)
  w_remove_confirm.visible = true
  local tmp_text = ui.get_text("sociality|remove_relation_confirm_text")
  local confirm_text = ui_widget.merge_mtf({player = remove_player_name, relation = relation_name}, tmp_text)
  rich_remove_confirm.mtf = confirm_text
  local time = data:get(packet.key.sociality_removetime)
  ui_sociality.init_timer(remove_confirm_timing, time, "")
end
function on_timer(timer)
  local main = timer.owner
  ui_sociality.set_timer_text(main)
end
function remove_timeout(cmd, data)
  w_remove_window.visible = false
  w_remove_confirm.visible = false
end
function on_remove_confirm_ok(btn)
  send_confirm(0)
end
function on_remove_sworn_confirm_cancel(btn)
  local main = btn.parent.parent.parent
  on_stop_removerelation(btn, main)
end
function send_confirm(accept)
  if remove_request_id ~= nil and npc_func_id ~= nil then
    local v = sys.variant()
    v:set(packet.key.sociality_removestep, bo2.eRemoveRelationStep_Accept)
    v:set(packet.key.sociality_requestid, remove_request_id)
    v:set(packet.key.sociality_acceptrequest, accept)
    v:set(packet.key.sociality_npcfuncid, npc_func_id)
    ui.console_print("sociality_requestid is %d %d.", packet.key.sociality_requestid, remove_request_id)
    if npc_func_id == bo2.eNpcFunc_ConsultRemoveSworn then
      v:set(packet.key.sociality_twrelationchgtype, bo2.TWR_ChgType_ConsultRemoveSworn)
    elseif npc_func_id == bo2.eNpcFunc_ConsultDivorce then
      v:set(packet.key.sociality_twrelationchgtype, bo2.TWR_ChgType_ConsultDivorce)
    elseif npc_func_id == bo2.eNpcFunc_ConsultRemoveMA then
      v:set(packet.key.sociality_twrelationchgtype, packet.TWR_ChgType_EnforceRemoveMA)
    end
    bo2.send_variant(packet.eCTS_Sociality_ChgTWRelation, v)
    remove_request_id = nil
    npc_func_id = nil
    w_remove_confirm.visible = false
  end
end
function on_remove_relation_suc_ok()
  w_remove_suc.visible = false
end
function on_remove_relation_failed_ok()
  w_remove_failed.visible = false
end
function remove_suc(cmd, data)
  local player_name = data:get(packet.key.sociality_tarplayername).v_string
  local old_relation_type = data:get(packet.key.sociality_twrelationtype).v_int
  local relation_name = ui_sociality.get_relation_name(old_relation_type)
  ui.console_print("remove_suc player_name is %s ,old_relation_type is %d, relation_name is  %s", player_name, old_relation_type, relation_name)
  local tmp_text = ui.get_text("sociality|remove_relation_suc")
  local suc_text = ui_widget.merge_mtf({player = player_name, relation = relation_name}, tmp_text)
  remove_suc_text.mtf = suc_text
  w_remove_suc.visible = true
end
function remove_failed(cmd, data)
  w_remove_failed.visible = true
end
function remove_ondelete(cmd, data)
  w_remove_window.visible = false
  w_remove_confirm.visible = false
end
function on_stop_removerelation(btn, main)
  local function send_cancel(ctr)
    local v = sys.variant()
    v:set(packet.key.sociality_requestid, remove_request_id)
    v:set(packet.key.sociality_srcplayerid, bo2.player.only_id)
    bo2.send_variant(packet.eCTS_Sociality_CancelRequest, v)
    main.visible = false
  end
  local relation_name = ui_sociality.get_relation_name(remove_relation_type)
  local tmp_text = ui.get_text("sociality|cancel_remove_relation")
  local cancel_remove_text = ui_widget.merge_mtf({relation = relation_name}, tmp_text)
  local confirm_text = ui.get_text(L("sociality|ok"))
  local cancel_text = ui.get_text(L("sociality|cancel"))
  ui_widget.ui_msg_box.show_common({
    text = cancel_remove_text,
    text_confirm = confirm_text,
    text_cancel = cancel_text,
    modal = true,
    init = function(data)
      local w = data.window
      w.size = ui.point(300, 200)
      w.margin = ui.rect(0, 0, 0, 100)
      w:search("btn_confirm").size = ui.point(130, 30)
      w:search("btn_cancel").size = ui.point(130, 30)
      local bg = w.parent
      msg_box_bg = bg
      msg_box_window = w
    end,
    callback = function(ret)
      if ret.result == 1 then
        send_cancel(ret.window)
      end
    end
  })
end
function on_close_click(btn)
  local main = btn.parent.parent
  on_stop_removerelation(btn, main)
end
function on_close_click_beg(btn)
end
function close_win()
  if w_remove_confirm.visible == false then
    return
  end
  w_remove_confirm.visible = false
  local v = sys.variant()
  v:set(packet.key.sociality_requestid, remove_request_id)
  v:set(packet.key.sociality_srcplayerid, bo2.player.only_id)
  bo2.send_variant(packet.eCTS_Sociality_CancelRequest, v)
  if remove_relation_type == bo2.TWR_Type_Sworn then
    ui_chat.show_ui_text_id(73272)
  elseif remove_relation_type == bo2.TWR_Type_Engagement or remove_relation_type == bo2.TWR_Type_Couple then
    ui_chat.show_ui_text_id(73273)
  end
end
