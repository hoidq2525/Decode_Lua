if ui_phase ~= nil then
  w_top = ui_phase.w_tool
end
function tool_clear()
  w_tip_common.visible = false
  w_tip_popup.visible = false
  w_tip_tag.visible = false
  local card_tip = ui.find_control("$tip:card")
  if card_tip then
    card_tip.visible = false
  end
  hide_menu()
  msg_queue = {}
  local con = w_msg_top.control_head
  while con do
    con = con.control_head
  end
  w_msg_top.visible = false
  ui_tool.ui_keyboard.keyboard_hide()
end
function on_check_dpk(uri)
  ui.log("on_check_dpk %s.", uri)
  ui_widget.ui_msg_box.show_common({
    text = sys.format(ui.get_text("tool|check_dpk_err") .. uri),
    modal = true,
    btn_cancel = false
  })
end
function on_stat_view_check(btn, v)
  local w = rawget(_M, "w_stat_view")
  if w ~= nil then
    w:enable_view(btn.name, v)
  end
end
function on_stat_view_toggle_mouse(btn, msg)
  if msg == ui.mouse_rbutton_click then
    ui_widget.ui_popup.show(w_stat_view_setting, btn, "y_auto", btn)
  end
end
function on_stat_view_init(w)
  local h = w_stat_view_setting.control_head
  while h ~= nil do
    w_stat_view:enable_view(h.name, h.check)
    h = h.next
  end
end
function ui_view_on_done(w, alias_v, info)
  if info.empty then
    ui.console_print("ui_view update done : %s", alias_v)
    return
  end
  ui.console_print([[
ui_view update error : %s
%s]], alias_v, info)
end
function init()
  ui.log("ui_phase:tool : loading enter")
  w_top:load_style("$gui/phase/tool/tool.xml", "w_tool")
  ui.log("ui_phase:tool : loading leave")
  w_top.visible = true
  ui_widget.ui_msg_box.init()
  ui_widget.ui_system_dir.init()
  bo2.insert_on_check_dpk(on_check_dpk, "ui_tool.on_check_dpk")
end
function config_init()
  w_top:load_style("$gui/phase/tool/tool_config.xml", "w_tool")
  w_top.visible = true
end
