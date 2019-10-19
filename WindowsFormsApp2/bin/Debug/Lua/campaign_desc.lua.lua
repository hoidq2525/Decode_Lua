function on_init()
end
function on_window_visible(ctrl, vis)
  ui_widget.on_border_visible(ctrl, vis)
  ui_widget.on_esc_stk_visible(ctrl, vis)
  if vis == false then
    local page = ui_widget.ui_tab.get_show_page(ui_campaign.w_core)
    local campaign_listview = page:search("campaign_listview")
    campaign_listview:clear_selection()
  end
end
function on_close_click(btn)
  ui_widget.on_close_click(btn)
end
