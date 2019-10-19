function on_init()
end
function on_window_visible(w, vis)
  ui_widget.on_border_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if not vis then
    ui_xinshou.w_list_view:clear_selection()
  end
  local item_sel = ui_xinshou.w_list_view.item_sel
  if item_sel == nil then
    return
  end
  local btn = item_sel:search("btn_quickjoinin")
  local cpn_state = item_sel:search("campaign_state")
  local circle = btn:search("visible_hl")
  w_btn_joinin.enable = btn.enable
  w_btn_joinin.visible = btn.visible
  w_btn_joinin:search("visible_hl").visible = circle.visible
  w_label_state.visible = cpn_state.visible
  w_label_state.text = cpn_state.text
end
function on_close_click(btn)
  ui_widget.on_close_click(btn)
end
