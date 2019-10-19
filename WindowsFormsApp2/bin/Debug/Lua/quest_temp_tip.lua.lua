function on_show(bool)
  quest_temp_tip_main.visible = bool
  if bool then
    ui_quest.w_quest_flash.visible = true
    ui_quest.w_quest_flash.suspended = false
  end
end
function on_click(btn)
  on_show(false)
end
function on_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
  else
    ui_widget.esc_stk_pop(w)
  end
end
function on_quest_tip_show(cmd, data)
  local quest_id = data:get(packet.key.quest_id).v_int
  local mstone_id = data:get(packet.key.milestone_id).v_int
  ui_quest.update_quest_tip_id(quest_id, mstone_id)
  on_show(true)
end
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_quest_temp_tip:on_signal"
reg(packet.eSTC_UI_QuestTip, on_quest_tip_show, sig)
