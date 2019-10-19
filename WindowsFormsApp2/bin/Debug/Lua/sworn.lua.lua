sworn_request_id = 0
local input_text
local input_enter_max = 1
function request_sworn()
  local temp_text = ui.get_text("sociality|confirm_sworn_begin")
  local money_num = tonumber(tostring(bo2.gv_define_sociality:find(35).value))
  local currency = tonumber(tostring(bo2.gv_define_sociality:find(47).value))
  local money_text
  if currency == bo2.eCurrency_CirculatedMoney then
    money_text = sys.format("<m:%d>", money_num)
  elseif currency == bo2.eCurrency_BoundedMoney then
    money_text = sys.format("<bm:%d>", money_num)
  end
  local confirm_text = ui_widget.merge_mtf({money = money_text}, temp_text)
  p_begin_confirm_text.mtf = confirm_text
  w_confirm_begin.visible = true
end
function on_confirm_begin_ok(btn)
  w_confirm_begin.visible = false
  send_sworn_quest()
end
function cancel_sworn()
  w_confirm_begin.visible = false
end
function on_confirm_begin_cancel(btn)
  cancel_sworn()
end
function send_sworn_quest()
  local d = sys.variant()
  d:set(packet.key.sociality_swornstep, 1)
  d:set(packet.key.sociality_npcfuncid, bo2.eNpcFunc_Sworn)
  bo2.send_variant(packet.eCTS_UI_ChgRelation, d)
end
function begin_promise(cmd, data)
  w_promise.visible = true
  sworn_request_id = data:get(packet.key.sociality_requestid)
  local time = data:get(packet.key.sociality_swornquesttime)
  ui_sociality.init_timer(promise_timing, time, "")
  ui_sociality.init_timer(confirm_promise_timing, time, "")
end
function sworn_suc()
  w_together.visible = true
end
function sworn_failed()
  w_promise_failed.visible = true
end
function sworn_timeout(cmd, data)
  w_promise.visible = false
  w_together.visible = false
  w_promise_failed.visible = false
  ui_sociality.end_timer(promise_timing)
  ui_sociality.end_timer(confirm_promise_timing)
end
function sworn_ondelete(cmd, data)
  w_promise.visible = false
  w_together.visible = false
  w_promise_failed.visible = false
  ui_sociality.end_timer(promise_timing)
  ui_sociality.end_timer(confirm_promise_timing)
end
function on_promise_ok(btn)
  local text = promise_input:search(L("input")).text
  w_confirm_promise.visible = true
  w_promise.visible = false
  the_promise_text.text = text
end
function on_promise_clear(btn)
  promise_input:search(L("input")).text = L("")
end
function on_my_will_ok(btn)
  w_confirm_promise.visible = false
  local promise = the_promise_text.text
  local v = sys.variant()
  v:set(packet.key.sociality_twrelationchgtype, bo2.TWR_ChgType_BecomeSworn)
  v:set(packet.key.sociality_swornstep, bo2.eSwornStep_Promise)
  v:set(packet.key.sociality_requestid, sworn_request_id)
  v:set(packet.key.sociality_swornpromise, promise)
  v:set(packet.key.sociality_acceptrequest, 0)
  ui_sociality.end_timer(promise_timing)
  ui_sociality.end_timer(confirm_promise_timing)
  bo2.send_variant(packet.eCTS_Sociality_ChgTWRelation, v)
end
function on_correct_promise(btn)
  local text = the_promise_text.text
  w_confirm_promise.visible = false
  w_promise.visible = true
  promise_input:search(L("input")).text = text
end
function on_together_ok(btn)
  w_together.visible = false
end
function on_failed_promise_ok(btn)
  w_promise_failed.visible = false
end
function on_timer(timer)
  local main = timer.owner
  ui_sociality.set_timer_text(main)
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
function on_close_click(btn)
  local main = btn.parent.parent
  local function send_cancel(ctr)
    local v = sys.variant()
    v:set(packet.key.sociality_requestid, sworn_request_id)
    v:set(packet.key.sociality_srcplayerid, bo2.player.only_id)
    bo2.send_variant(packet.eCTS_Sociality_CancelRequest, v)
    main.visible = false
  end
  local cancel_sworn_text = ui.get_text(L("sociality|cancel_sworn"))
  local confirm_text = ui.get_text(L("sociality|ok"))
  local cancel_text = ui.get_text(L("sociality|cancel"))
  ui_widget.ui_msg_box.show_common({
    text = cancel_sworn_text,
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
function on_close_click_beg(btn)
end
function get_win_vis()
  if w_confirm_begin.visible == true then
    return w_confirm_begin
  elseif w_promise.visible == true then
    return w_promise
  elseif w_confirm_promise.visible == true then
    return w_confirm_promise
  elseif w_together.visible == true then
  end
end
function close_win()
  local win = get_win_vis()
  if win == nil then
    return
  end
  win.visible = false
  local v = sys.variant()
  v:set(packet.key.sociality_requestid, sworn_request_id)
  v:set(packet.key.sociality_srcplayerid, bo2.player.only_id)
  bo2.send_variant(packet.eCTS_Sociality_CancelRequest, v)
  ui_chat.show_ui_text_id(73272)
end
