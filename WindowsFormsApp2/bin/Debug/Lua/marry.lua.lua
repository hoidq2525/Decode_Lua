marry_request_id = 0
local input_text
local input_enter_max = 1
function marry_conform_begin(cmd, data)
  w_confirm_begin.visible = true
  marry_request_id = data:get(packet.key.sociality_requestid)
  local temp_text = ui.get_text("sociality|confirm_marry_begin")
  local money_num = tonumber(tostring(bo2.gv_define_sociality:find(33).value))
  local currency = tonumber(tostring(bo2.gv_define_sociality:find(46).value))
  local money_text
  if currency == bo2.eCurrency_CirculatedMoney then
    money_text = sys.format("<m:%d>", money_num)
  elseif currency == bo2.eCurrency_BoundedMoney then
    money_text = sys.format("<bm:%d>", money_num)
  end
  local confirm_text = ui_widget.merge_mtf({money = money_text}, temp_text)
  confirm_begin_text.mtf = confirm_text
  local time = data:get(packet.key.sociality_marryquesttime)
  ui_sociality.init_timer(confirm_begin_timing, time, "")
end
function marry_waite_begin(cmd, data)
  w_waite_begin.visible = true
  marry_request_id = data:get(packet.key.sociality_requestid)
  local time = data:get(packet.key.sociality_marryquesttime)
  ui_sociality.init_timer(waite_begin_timing, time, "")
end
function marry_begin_male(cmd, data)
  w_promise.visible = true
  marry_request_id = data:get(packet.key.sociality_requestid)
  local time = data:get(packet.key.sociality_marryquesttime)
  ui_sociality.init_timer(promise_timing, time, "")
  ui_sociality.init_timer(confirm_promise_timing, time, "")
end
function marry_begin_female(cmd, data)
  w_waite_begin.visible = false
  w_wait_promise.visible = true
  local male_name = data:get(packet.key.sociality_marrymalename)
  local wait_text = ui.get_text("sociality|wait_promise")
  local text = ui_widget.merge_mtf({man_name = male_name}, wait_text)
  wait_promise_text.mtf = text
  wait_promise_text.color = ui.make_argb("AAFFFFFF")
  local time = data:get(packet.key.sociality_marryquesttime)
  ui_sociality.init_timer(wait_promise_timing, time, "")
end
function marry_respromise_female(cmd, data)
  ui_sociality.end_timer(wait_promise_timing)
  local promise = data:get(packet.key.sociality_marrypromise)
  w_responses_promise.visible = true
  the_resp_promise_text.text = promise
  marry_request_id = data:get(packet.key.sociality_requestid)
  w_wait_promise.visible = false
  local time = data:get(packet.key.sociality_marryquesttime)
  ui_sociality.init_timer(responses_promise_timing, time, "")
end
function marry_respromise_male(cmd, data)
  marry_request_id = data:get(packet.key.sociality_requestid)
  w_wait_responses.visible = true
  local time = data:get(packet.key.sociality_marryquesttime)
  ui_sociality.init_timer(wait_responses_timing, time, "")
end
function marry_suc(cmd, data)
  w_wait_responses.visible = false
  w_responses_promise.visible = false
  w_together.visible = true
  ui_sociality.end_timer(wait_responses_timing)
end
function marry_failed(cmd, data)
  w_wait_responses.visible = false
  w_responses_promise.visible = false
  w_promise_failed.visible = true
  ui_sociality.end_timer(wait_responses_timing)
end
function marry_timeout(cmd, data)
  marry_ondelete(cmd, data)
end
function marry_ondelete(cmd, data)
  w_wait_responses.visible = false
  w_responses_promise.visible = false
  w_confirm_promise.visible = false
  w_promise.visible = false
  w_wait_promise.visible = false
  w_confirm_begin.visible = false
  w_waite_begin.visible = false
  ui_sociality.end_timer(promise_timing)
  ui_sociality.end_timer(responses_promise_timing)
  ui_sociality.end_timer(confirm_promise_timing)
  ui_sociality.end_timer(wait_responses_timing)
  ui_sociality.end_timer(wait_promise_timing)
  ui_sociality.end_timer(confirm_begin_timing)
  ui_sociality.end_timer(waite_begin_timing)
end
function on_promise_ok(btn)
  local text = promise_input:search(L("input")).text
  w_confirm_promise.visible = true
  w_promise.visible = false
  the_promise_text:search(L("promise_text")).text = text
end
function on_promise_clear(btn)
  promise_input:search(L("input")).text = L("")
end
function on_my_will_ok(btn)
  w_confirm_promise.visible = false
  local promise = the_promise_text.text
  local v = sys.variant()
  v:set(packet.key.sociality_twrelationchgtype, bo2.TWR_ChgType_Engage)
  v:set(packet.key.sociality_marrystep, bo2.eMarryStep_Promise)
  v:set(packet.key.sociality_requestid, marry_request_id)
  v:set(packet.key.sociality_marrypromise, promise)
  v:set(packet.key.sociality_acceptrequest, 0)
  bo2.send_variant(packet.eCTS_Sociality_ChgTWRelation, v)
  ui_sociality.end_timer(confirm_promise_timing)
  ui_sociality.end_timer(promise_timing)
end
function on_correct_promise(btn)
  local text = the_promise_text.text
  w_confirm_promise.visible = false
  w_promise.visible = true
  promise_input:search(L("input")).text = text
end
function on_i_love_you(btn)
  local v = sys.variant()
  v:set(packet.key.sociality_twrelationchgtype, bo2.TWR_ChgType_Engage)
  v:set(packet.key.sociality_marrystep, bo2.eMarryStep_Accpet)
  v:set(packet.key.sociality_requestid, marry_request_id)
  v:set(packet.key.sociality_acceptrequest, 0)
  bo2.send_variant(packet.eCTS_Sociality_ChgTWRelation, v)
  ui_sociality.end_timer(responses_promise_timing)
end
function on_refuse(btn)
  local v = sys.variant()
  v:set(packet.key.sociality_twrelationchgtype, bo2.TWR_ChgType_Engage)
  v:set(packet.key.sociality_marrystep, bo2.eMarryStep_Accpet)
  v:set(packet.key.sociality_requestid, marry_request_id)
  v:set(packet.key.sociality_acceptrequest, 1)
  bo2.send_variant(packet.eCTS_Sociality_ChgTWRelation, v)
  ui_sociality.end_timer(responses_promise_timing)
end
function on_together_ok(btn)
  w_together.visible = false
end
function on_failed_promise_ok(cmd, data)
  w_promise_failed.visible = false
end
function on_timer(timer)
  local main = timer.owner
  ui_sociality.set_timer_text(main)
end
function on_confirm_begin_ok(btn)
  local v = sys.variant()
  v:set(packet.key.sociality_twrelationchgtype, bo2.TWR_ChgType_Engage)
  v:set(packet.key.sociality_marrystep, bo2.eMarryStep_ConfirmBegin)
  v:set(packet.key.sociality_requestid, marry_request_id)
  v:set(packet.key.sociality_acceptrequest, 0)
  bo2.send_variant(packet.eCTS_Sociality_ChgTWRelation, v)
  ui_sociality.end_timer(confirm_promise_timing)
  w_confirm_begin.visible = false
end
function on_confirm_begin_cancel(btn)
  local main = btn.parent.parent.parent
  on_stop_marry(btn, main)
end
function on_black_out_marry(btn)
  local main = btn.parent.parent.parent
  on_stop_marry(btn, main)
end
function on_input_keydown(ctrl, key, keyflag)
  if key == ui.VK_RETURN then
    input_text = promise_input.text
  end
end
function on_input_char(ctrl, ch)
  if ch == ui.VK_RETURN then
    local count = sys.findwchar(input_text, L("\r"))
    enter_input_num = count + 1
    if enter_input_num >= input_enter_max then
      promise_input:remove_on_widget_mouse(ch)
      promise_input.text = input_text
      return
    end
  end
end
function on_stop_marry(btn, main)
  local function send_cancel_marry(ctr)
    local v = sys.variant()
    v:set(packet.key.sociality_requestid, marry_request_id)
    v:set(packet.key.sociality_srcplayerid, bo2.player.only_id)
    bo2.send_variant(packet.eCTS_Sociality_CancelRequest, v)
    main.visible = false
  end
  local cancel_marry_text = ui.get_text(L("sociality|cancel_marry"))
  local confirm_text = ui.get_text(L("sociality|ok"))
  local cancel_text = ui.get_text(L("sociality|cancel"))
  ui_widget.ui_msg_box.show_common({
    text = cancel_marry_text,
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
        send_cancel_marry(ret.window)
      end
    end
  })
end
function on_close_click(btn)
  local main = btn.parent.parent
  on_stop_marry(btn, main)
end
function on_close_click_beg(btn)
end
function get_win_vis()
  if w_confirm_begin.visible == true then
    return w_confirm_begin
  elseif w_waite_begin.visible == true then
    return w_waite_begin
  elseif w_promise.visible == true then
    return w_promise
  elseif w_wait_promise.visible == true then
    return w_wait_promise
  elseif w_confirm_promise.visible == true then
    return w_confirm_promise
  elseif w_responses_promise.visible == true then
    return w_responses_promise
  elseif w_wait_responses.visible == true then
    return w_wait_responses
  end
end
function close_win()
  local win = get_win_vis()
  if win == nil then
    return
  end
  win.visible = false
  local v = sys.variant()
  v:set(packet.key.sociality_requestid, marry_request_id)
  v:set(packet.key.sociality_srcplayerid, bo2.player.only_id)
  bo2.send_variant(packet.eCTS_Sociality_CancelRequest, v)
  ui_chat.show_ui_text_id(73273)
end
