local max_count = 50
function send_comment(text)
  local v = sys.variant()
  v:set(packet.key.ui_text, text)
  bo2.send_variant(packet.eCTS_UI_BattleComment, v)
end
function handle_battle_comment(cmd, data)
  send_btn.enable = false
  comment_input.mtf = ui.get_text("battle|please_input")
  bo2.AddTimeEvent(5, function()
    main_window.visible = true
  end)
end
function on_input_keydown(ctrl, key, keyflag)
  if key == ui.VK_RETURN then
    bo2.AddTimeEvent(5, function()
      on_send_click()
    end)
    return
  end
  local size = comment_input.text.size
  char_left_lb.visible = size >= max_count
  send_btn.enable = size > 0 and size <= max_count
end
function on_input_focus(ctrl, vis)
  local text = ui.get_text("battle|please_input")
  if text == comment_input.text then
    comment_input.mtf = ""
    send_btn.enable = false
  elseif comment_input.text.size == 0 then
    comment_input.mtf = text
    send_btn.enable = false
  end
end
function on_send_click(btn)
  local text = comment_input.text
  local size = text.size
  if size <= 0 or size > max_count then
    return
  end
  send_comment(text)
  main_window.visible = false
end
function auto_close(ctrl, vis)
  ui_widget.on_esc_stk_visible(ctrl, vis)
  ui_widget.on_leavescn_stk_visible(ctrl, vis)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_battle_comment.packet_handle"
reg(packet.eSTC_UI_BattleComment, handle_battle_comment, sig)
