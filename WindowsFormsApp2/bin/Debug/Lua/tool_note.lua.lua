function note_insert(text, color, font_size, time)
  ui_widget.ui_note_list.insert(w_note_list, text, color, font_size, time)
end
local c_color_normal = ui.make_color("00FF00")
function note_insert_normal(text)
  ui_widget.ui_note_list.insert(w_note_list, text, c_color_normal)
end
local c_color_error = ui.make_color("FF0000")
function note_insert_error(text)
  ui_widget.ui_note_list.insert(w_note_list, text, c_color_error)
end
local c_color_hint = ui.make_color("FFFF00")
function note_insert_hint(text)
  ui_widget.ui_note_list.insert(w_note_list, text, c_color_hint)
end
