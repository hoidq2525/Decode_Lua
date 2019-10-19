cs_tip_newline = SHARED("\n")
local c_flicker_uri = L("$gui/frame/help/tool_handson.xml")
local c_flicker_style = L("tool_handson_flicker")
function on_move(handson)
  local card = handson.owner
  if card.topper == nil or card.topper.visible == false then
    return
  end
  if handson.view == nil then
    return
  end
  handson.view:show_popup(card, handson.popup, handson.margin)
end
function on_show(handson)
  local card = handson.owner
  if card.topper == nil or card.topper.visible == false then
    return
  end
  local card_parent = card.parent
  if handson.flicker == nil then
    local flicker_control = ui.create_control(card_parent, "panel")
    flicker_control:load_style(c_flicker_uri, c_flicker_style)
    flicker_control:move_to_head()
    flicker_control.size = card.size
    flicker_control.margin = card.margin
    flicker_control.dock = card.dock
    handson.flicker = flicker_control
  end
  handson.view.visible = true
  if handson.text.size <= 0 then
    return
  end
  ui_widget.tip_make_view(handson.view, handson.text)
  local current_priority = card.topper.priority + 5
  handson.view.parent.priority = current_priority
  handson.view.priority = current_priority
  handson.view:show_popup(card, handson.popup, handson.margin)
end
function on_move_quest_traceing(handson)
  local card = handson.owner
  if handson.view == nil then
    return
  end
  handson.view:show_popup(card, handson.popup, handson.margin)
end
function on_show_quest_traceing(handson)
  local card = handson.owner
  if ui_quest.ui_tracing.w_tracing_panel.visible ~= true then
    return
  end
  local card_parent = card.parent
  handson.view.visible = true
  if handson.text.size <= 0 then
    return
  end
  ui_widget.tip_make_view(handson.view, handson.text)
  handson.view:show_popup(card, handson.popup, handson.margin)
end
function on_show_link(handson)
  handson.view.visible = true
  if handson.text.size <= 0 then
    return
  end
  local parent_control = ui.find_control("$frame:qlink_side")
  handson.view.priority = parent_control.priority + 10
  ui_widget.tip_make_view(handson.view, handson.text)
  handson.view:show_popup(handson.owner, handson.popup, handson.margin)
end
function on_test_visible_set_proprity(window)
  local priority = 0
  if ui_tool.w_handson_common.visible ~= false then
    priority = ui_tool.w_handson_top.priority
  elseif ui_tool.w_handson_popup.visible ~= false then
    priority = ui_tool.w_handson_top.priority
  elseif ui_tool.w_handson_qlink_item.visible ~= false then
    priority = ui_tool.w_handson_top_item
  end
  if priority > 0 then
    window.priority = priority
  end
end
