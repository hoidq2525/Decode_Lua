function on_init(ctrl)
  ui.console_print("on_init")
  local uri = "$frame/quest/multiple_choice_quest.xml"
  local style = "quest_info"
  cur_row = w_quest_list:item_append()
  cur_row:load_style(uri, style)
  cur_row = w_quest_list:item_append()
  cur_row:load_style(uri, style)
end
function on_confirm_click(btn)
  local selected_item = w_quest_list.item_sel
  local quest_id = selected_item.var.v_int
  local quest_info = sys.variant()
  quest_info:set(packet.key.quest_id, quest_id)
  bo2.send_variant(packet.eCTS_UI_ChoiceMultiQuest, quest_info)
  w_main.visible = false
end
function on_cancel_click(btn)
  w_main.visible = false
end
function quest_highlight(ctrl, is_highlight)
  local hl = ctrl:search("high_light")
  if hl ~= nil then
    hl.visible = is_highlight
  end
end
function on_quest_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_enter then
    quest_highlight(ctrl, true)
  elseif msg == ui.mouse_leave then
    quest_highlight(ctrl, false)
  end
end
function on_quest_select(item, is_select)
  item:search("select_high_light").visible = is_select
  btn_confirm.enable = true
end
function show_main(data)
  local text = data:get(packet.key.mcq_quest_text).v_string
  w_main:search("tip_label").mtf = text
  w_quest_list:item_clear()
  local quest_info_array = data:get(packet.key.mcq_quest_info)
  for i = 0, quest_info_array.size - 1 do
    local quest_info = quest_info_array:fetch_v(i)
    local uri = "$frame/quest/multiple_choice_quest.xml"
    local style = "quest_info"
    new_row = w_quest_list:item_append()
    new_row:load_style(uri, style)
    new_row:search("quest_name").text = quest_info:get(packet.key.ui_text).v_string
    new_row.var = quest_info:get(packet.key.quest_id).v_int
  end
  w_main.visible = true
end
