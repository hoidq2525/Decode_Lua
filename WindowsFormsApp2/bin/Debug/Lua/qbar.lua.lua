function on_card_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    ui.set_cursor_icon(ctrl.icon)
    ui.setup_drop(ui_tool.w_drop_floater, nil)
  end
end
function on_lang_init()
  if ui_widget.get_define_int(50031) == 1 then
    btn_qq_hd.visible = false
  else
    btn_qq_hd.visible = true
  end
end
function on_click_qq_hd(btn)
  w_flicker_qq_hd.visible = false
  ui_gift_award.w_http_win.visible = true
end
function on_card_tip_show(tip)
  ui_widget.tip_make_view(tip.view, tip.owner.excel.name)
  local tgt = tip.target
  if not sys.check(tgt) then
    tgt = tip.owner
  end
  tip.view:show_popup(tgt, tip.popup, tip.margin)
end
