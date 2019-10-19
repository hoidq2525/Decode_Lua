local reg = ui_packet.game_recv_signal_insert
local sig = "ui_account_bank_safe.packet_handle"
function notify(text_id)
  local tt = bo2.gv_text:find(text_id)
  if tt == nil then
    return
  end
  local targets = tt.targets
  if targets.size > 0 then
    local chat = bo2.gv_chat_list:find(targets[0])
    if chat ~= nil then
      ui_tool.note_insert(tt.text, chat.color)
      return
    end
  end
  ui_tool.note_insert(tt.text)
end
function check_len(pw)
  if pw.size == 0 then
    notify(1389)
    return false
  elseif pw.size < 6 then
    notify(1383)
    return false
  elseif pw.size > 12 then
    notify(1370)
    return false
  end
  return true
end
function on_newaccbankpass()
  local on_msg_callback = function(ret)
    if ret.result == 1 then
      local ctrl = ret.window
      local input_ctrl = ctrl:search("input")
      local repeat_ctrl = ctrl:search("repeat")
      if input_ctrl.text == repeat_ctrl.text then
        if check_len(input_ctrl.text) then
          local v = sys.variant()
          v:set(packet.key.cmn_type, 0)
          v:set(packet.key.cmn_md5, input_ctrl.text.v_code)
          bo2.send_variant(packet.eCTS_UI_AccBankPassSet, v)
        end
      else
        notify(1380)
      end
    end
  end
  local msg = {
    detail = L("passwd_new_input"),
    style_uri = "$frame/account_bank/account_bank_safe.xml",
    style_name = "passwd_new_input",
    callback = on_msg_callback
  }
  ui_widget.ui_msg_box.show(msg)
end
function on_chgaccbankcode()
  local on_msg_callback = function(ret)
    if ret.result == 1 then
      local ctrl = ret.window
      local input_ctrl = ctrl:search("input")
      local repeat_ctrl = ctrl:search("repeat")
      if input_ctrl.text == repeat_ctrl.text then
        if check_len(input_ctrl.text) then
          local old_ctrl = ctrl:search("old")
          local v = sys.variant()
          v:set(packet.key.cmn_type, 2)
          v:set(packet.key.cmn_name, old_ctrl.text.v_code)
          v:set(packet.key.cmn_md5, input_ctrl.text.v_code)
          bo2.send_variant(packet.eCTS_UI_AccBankPassSet, v)
        end
      else
        notify(1380)
      end
    end
  end
  local msg = {
    detail = "passwd_chg_input",
    style_name = "passwd_chg_input",
    style_uri = "$frame/account_bank/account_bank_safe.xml",
    callback = on_msg_callback
  }
  ui_widget.ui_msg_box.show(msg)
end
function on_unlockaccbank()
  local on_msg_callback = function(ret)
    if ret.result == 1 then
      local ctrl = ret.window
      local input_ctrl = ctrl:search("input")
      if check_len(input_ctrl.text) then
        local v = sys.variant()
        v:set(packet.key.cmn_type, 1)
        v:set(packet.key.cmn_md5, input_ctrl.text.v_code)
        bo2.send_variant(packet.eCTS_UI_AccBankPassSet, v)
      end
    end
  end
  local msg = {
    detail = "passwd_enter_input",
    style_name = "passwd_enter_input",
    style_uri = "$frame/account_bank/account_bank_safe.xml",
    callback = on_msg_callback
  }
  ui_widget.ui_msg_box.show(msg)
end
function issetaccbankcode()
  if bo2.player ~= nil and bo2.player:get_flag_bit(bo2.ePlayerFlagBit_AccBankCode) == 1 then
    return true
  end
  return false
end
function isaccbankopen()
  if bo2.player ~= nil and bo2.player:get_flag_bit(bo2.ePlayerFlagBit_AccBankOpen) == 1 then
    return true
  end
  return false
end
function on_click_show_accbank()
  local define = bo2.gv_define:find(1096)
  if define ~= nil and define.value ~= L("1") then
    ui_account_bank.show_bank()
    return
  end
  if issetaccbankcode() then
    if isaccbankopen() then
      ui_account_bank.show_bank()
    else
      on_unlockaccbank()
    end
  else
    on_newaccbankpass()
  end
end
function on_keyboard_click(btn)
  local focus = ui.get_focus()
  local data = {input_ctrl = btn, popup = "y2"}
  ui_tool.ui_keyboard.show_keyboard(data)
end
function on_keyboard_click_new_input(btn)
  local parent = btn.parent.parent.parent
  local input = parent:search("input")
  local rep = parent:search("repeat")
  local in_ctrl
  if input.focus then
    in_ctrl = input
  elseif rep.focus then
    in_ctrl = rep
  end
  local data = {
    input_ctrl = in_ctrl,
    btn = btn,
    popup = "y2"
  }
  ui_tool.ui_keyboard.show_keyboard(data)
end
function on_keyboard_click_chg_input(btn)
  local parent = btn.parent.parent.parent
  local old = parent:search("old")
  local input = parent:search("input")
  local rep = parent:search("repeat")
  local in_ctrl
  if old.focus then
    in_ctrl = old
  elseif input.focus then
    in_ctrl = input
  elseif rep.focus then
    in_ctrl = rep
  end
  local data = {
    input_ctrl = in_ctrl,
    btn = btn,
    popup = "y2"
  }
  ui_tool.ui_keyboard.show_keyboard(data)
end
function on_keyboard_click_enter_input(btn)
  local parent = btn.parent.parent
  local input = parent:search("input")
  local in_ctrl
  if input.focus then
    in_ctrl = input
  end
  local data = {
    input_ctrl = in_ctrl,
    btn = btn,
    popup = "y2"
  }
  ui_tool.ui_keyboard.show_keyboard(data)
end
function on_forget_pass(btn)
  notify(1384)
end
function on_click_chg_pass(btn)
  on_chgaccbankcode()
end
function on_init(ctrl)
end
function on_focus(ctrl, vis)
  if not vis then
    return
  end
  local old = ctrl:search("old")
  local input = ctrl:search("input")
  local rep = ctrl:search("repeat")
  if old then
    old.focus = true
  elseif input then
    input.focus = true
  end
end
function on_ok(old, input, rep)
  if old then
    if not check_len(old.text) then
      old.focus = true
      return false
    end
    if input.text ~= rep.text then
      input.focus = true
      notify(1380)
      return false
    end
    if not check_len(input.text) then
      input.focus = true
      return false
    end
  elseif input and rep then
    if input.text ~= rep.text then
      input.focus = true
      notify(1380)
      return false
    end
    if not check_len(input.text) then
      input.focus = true
      return false
    end
  elseif input and not check_len(input.text) then
    input.focus = true
    return false
  end
  return true
end
function on_confirm_click(btn)
  local parent = btn.parent.parent.parent
  local old = parent:search("old")
  local input = parent:search("input")
  local rep = parent:search("repeat")
  if on_ok(old, input, rep) then
    ui_widget.ui_msg_box.on_confirm_click(btn)
  end
end
function on_input_enter(w)
  local parent = w.parent.parent.parent.parent
  local old = parent:search("old")
  local input = parent:search("input")
  local rep = parent:search("repeat")
  if on_ok(old, input, rep) then
    ui_widget.ui_msg_box.on_input_enter(w)
  end
end
function on_input_key(w, key, flag)
  if key == ui.VK_TAB and not flag.down and not flag.alt then
    local parent = w.parent.parent.parent.parent
    local old = parent:search("old")
    local input = parent:search("input")
    local rep = parent:search("repeat")
    if old and old.focus then
      old.focus = false
      input.focus = true
    elseif input and rep and input.focus then
      input.focus = false
      rep.focus = true
    elseif rep and rep.focus and input then
      if old then
        old.focus = true
      else
        input.focus = true
      end
    end
  else
    ui_widget.ui_msg_box.on_input_key(w, key, flag)
  end
end
function handleOpenAccBank(cmd, data)
  ui_account_bank.show_bank()
end
reg(packet.eSTC_UI_OpenAccBank, handleOpenAccBank, sig)
