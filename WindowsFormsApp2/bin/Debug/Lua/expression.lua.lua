function on_e_mouse(btn, msg)
  if msg == ui.mouse_lbutton_down then
    w_input:insert_mtf(btn.mtf, ui.mtf_rank_system)
    w_expression.visible = false
    w_input.focus = true
  end
end
function on_expression(btn)
  ui_widget.ui_popup.show(w_expression, btn, "y1x2")
end
function on_expression_init(panel)
  for i = 0, 95 do
    local item = ui.create_control(w_expression_list, "divider")
    item:load_style("$frame/chat/expression.xml", "e_unit")
    item:search("rb"):insert_mtf(sys.format("<f:%s>", i), ui.mtf_rank_system)
    local line = ui_chat.chat_expression_table:find(i)
    if line ~= nil then
      item:search("rb").tip.text = sys.format("%s %s", line.describe, line.command)
    end
  end
end
