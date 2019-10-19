local knight_match_id = 0
local knight_help_clicked = false
function on_seekhelp()
  if 0 ~= knight_match_id then
    local var = sys.variant()
    var:set(packet.key.arena_id, knight_match_id)
    bo2.send_variant(packet.eCTS_Knight_SeekHelp, var)
    ui_knight.w_seekhelp_button.enable = false
    ui_knight.w_seekhelp_flash.visible = false
    knight_help_clicked = true
  end
end
function set_match_id(match_id)
  knight_match_id = match_id
  knight_help_clicked = false
end
function can_click()
  return knight_help_clicked == false
end
function on_seekhelp_tip_make(tip)
  local text
  if knight_help_clicked then
    text = ui.get_text("sociality|knight_help_once")
  elseif ui_knight.w_seekhelp_button.enable == false then
    text = ui.get_text("sociality|knight_help_hp")
  else
    text = ui.get_text("sociality|knight_help")
  end
  ui_widget.tip_make_view(tip.view, text)
end
