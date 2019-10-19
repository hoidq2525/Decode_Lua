ma_request_id = 0
ma_target_id = 0
function ma_ondelete(cmd, data)
  w_confirm_window.visible = false
  w_ma_suc_window.visible = false
  w_ma_failed_window.visible = false
  ui_sociality.end_timer(confirm_timing)
end
function ma_timeout(cmd, data)
  w_confirm_window.visible = false
  w_ma_suc_window.visible = false
  w_ma_failed_window.visible = false
  ui_sociality.end_timer(confirm_timing)
end
function begin_ma(cmd, data)
  w_confirm_window.visible = true
  ma_request_id = data:get(packet.key.sociality_requestid)
  local target_id = data:get(packet.key.sociality_marequesttarget).v_int
  ma_target_id = target_id
  ui.console_print("target_id is %d.", target_id)
  if target_id == 1 then
    confirm_lb.mtf = ui.get_text("sociality|became_master")
    confirm_ok_btn:search(L("ma_btn")).text = ui.get_text("sociality|confirm_get_appren")
    confirm_no_btn:search(L("ma_btn")).text = ui.get_text("sociality|refuse_appren")
  elseif target_id == 2 then
    confirm_lb.mtf = ui.get_text("sociality|became_appren")
    confirm_ok_btn:search(L("ma_btn")).text = ui.get_text("sociality|confirm_get_master")
    confirm_no_btn:search(L("ma_btn")).text = ui.get_text("sociality|refuse_master")
  end
  local time = data:get(packet.key.sociality_maquesttime)
  ui_sociality.init_timer(confirm_timing, time, "")
  ui.console_print("sworn_request_id is %d.", ma_request_id)
end
function sworn_suc(cmd, data)
  w_ma_suc_window.visible = true
end
function sworn_failed(cmd, data)
  w_ma_failed_window.visible = true
end
function on_timer(timer)
  local main = timer.owner
  ui_sociality.set_timer_text(main)
end
function on_confirm_get_appren(btn)
  send_answer(0)
end
function on_refuse_appren(btn)
  local main = btn.parent.parent.parent
  on_stop_ma(btn, main)
end
function send_answer(accept)
  w_confirm_window.visible = false
  local v = sys.variant()
  v:set(packet.key.sociality_twrelationchgtype, bo2.TWR_ChgType_BecomeMA)
  v:set(packet.key.sociality_mastep, bo2.eMAStep_Promise)
  v:set(packet.key.sociality_requestid, ma_request_id)
  v:set(packet.key.sociality_acceptrequest, accept)
  bo2.send_variant(packet.eCTS_Sociality_ChgTWRelation, v)
  ui_sociality.end_timer(confirm_timing)
end
function on_ma_suc_ok(btn)
  w_ma_suc_window.visible = false
end
function on_ma_failed_ok(btn)
  w_ma_failed_window.visible = false
end
function refresh_masterlevel_up()
  ui.console_print("refresh_masterlevel_up begin.")
  local main = w_masterlevel_buy
  local errantry = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Errantry)
  local errantry_lable = main:search(L("errantry_text")):search(L("frm_lb_text"))
  errantry_lable.text = errantry
  local masterlevel = bo2.player:get_atb(bo2.eAtb_Cha_MasterLevel)
  local neederrantry = 0
  local next_app_num = 0
  local masterlevel_name
  if masterlevel == 0 then
    masterlevel_name = ui.get_text("sociality|masterlevel_0")
    next_app_num = bo2.gv_define_sociality:find(8).value
  elseif masterlevel == 1 then
    neederrantry = bo2.gv_define:find(197).value
    masterlevel_name = ui.get_text("sociality|masterlevel_1")
    next_app_num = bo2.gv_define_sociality:find(9).value
  elseif masterlevel == 2 then
    neederrantry = bo2.gv_define:find(198).value
    masterlevel_name = ui.get_text("sociality|masterlevel_2")
    next_app_num = bo2.gv_define_sociality:find(10).value
  elseif masterlevel == 3 then
    neederrantry = bo2.gv_define:find(199).value
    masterlevel_name = ui.get_text("sociality|masterlevel_3")
    next_app_num = bo2.gv_define_sociality:find(11).value
  elseif masterlevel == 4 then
    neederrantry = bo2.gv_define:find(200).value
    masterlevel_name = ui.get_text("sociality|masterlevel_4")
    next_app_num = bo2.gv_define_sociality:find(12).value
  elseif masterlevel == 5 then
    masterlevel_name = ui.get_text("sociality|masterlevel_5")
    next_app_num = "-"
  end
  local masterlevel_lable = main:search(L("masterlevel_text")):search(L("frm_lb_text"))
  masterlevel_lable.text = masterlevel_name
  local need_text
  if neederrantry == 0 then
    need_text = ui.get_text("sociality|noneed_masterlevel_up")
  else
    need_text = neederrantry
  end
  ui.console_print("errantry is " .. errantry .. " masterlevel_name is " .. masterlevel_name .. " need text is " .. need_text)
  local neederrantry_lable = main:search(L("nextlevel_neederrantry_text")):search(L("frm_lb_text"))
  neederrantry_lable.text = need_text
  local app_num_lable = main:search(L("app_num_text")):search(L("frm_lb_text"))
  app_num_lable.text = next_app_num
  ui.console_print("refresh_masterlevel_up end.")
end
function on_masterlevel_up(btn)
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_MasterLevelUp, v)
end
function on_atb_flag_chg(obj, ft, idx)
  if w_masterlevel_buy.visible == true then
    refresh_masterlevel_up()
  end
end
function show_fgml_win()
  w_first_get_master_level.visible = true
end
function on_get_master_level_ok(btn)
  w_first_get_master_level.visible = false
end
function on_self_enter(obj, msg)
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Cha_MasterLevel, on_atb_flag_chg, "ui_sociality.ui_masterandappren.on_atb_flag_chg")
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_Errantry, on_atb_flag_chg, "ui_sociality.ui_masterandappren.on_atb_flag_chg")
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_sociality.ui_masterandappren.on_self_enter")
function on_stop_ma(btn, main)
  local function send_cancel(ctr)
    local v = sys.variant()
    v:set(packet.key.sociality_requestid, ma_request_id)
    v:set(packet.key.sociality_srcplayerid, bo2.player.only_id)
    bo2.send_variant(packet.eCTS_Sociality_CancelRequest, v)
    main.visible = false
  end
  local cancel_ma_text
  if ma_target_id == 1 then
    cancel_ma_text = ui.get_text(L("sociality|cancel_master"))
  elseif ma_target_id == 2 then
    cancel_ma_text = ui.get_text(L("sociality|cancel_app"))
  end
  local confirm_text = ui.get_text(L("sociality|ok"))
  local cancel_text = ui.get_text(L("sociality|cancel"))
  ui_widget.ui_msg_box.show_common({
    text = cancel_ma_text,
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
  on_stop_ma(btn, main)
end
function on_close_click_beg(btn)
end
