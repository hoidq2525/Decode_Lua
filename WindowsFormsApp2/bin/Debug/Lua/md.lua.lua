local ui_tab = ui_widget.ui_tab
local ui_text_list = ui_widget.ui_text_list
c_warning_color = L("FFFF0000")
function insert_tab(tab, name)
  local btn_file = L("$frame/discover/md.xml")
  local btn_style = L("tab_btn")
  local page_file = L("$frame/discover/") .. name .. ".xml"
  local page_style = name
  ui_tab.insert_suit(tab, name, btn_file, btn_style, page_file, page_style)
  local btn = ui_tab.get_button(tab, name)
  local text = ui.get_text(sys.format("discover|%s", name))
  btn.text = text
end
function on_init()
  insert_tab(gx_window, "discover")
  insert_tab(gx_window, "medal")
  ui_tab.show_page(gx_window, "discover", true)
  ui_tab.get_button(gx_window, "medal").enable = false
  ui_md.ui_discover.on_discover_init()
  ui_md.ui_medal.on_medal_init()
end
function box_insert_text(box, text)
  local rank = ui.mtf_rank_system
  local content = sys.format("<tf:text>%s", text)
  box:insert_mtf(content, rank)
end
function on_md_init()
end
function on_esc_stk_visible(w, vis)
  ui_widget.on_border_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  ui_main.w_top:apply_dock(true)
  if vis then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    ui_widget.safe_play_sound(517)
    ui_md.ui_content.gx_window.visible = true
    ui_md.m_timer.suspended = false
  else
    ui_widget.safe_play_sound(518)
    ui_widget.esc_stk_pop(w)
    ui_md.ui_content.gx_window.visible = false
  end
  ui_md.ui_discover.on_window_visible(w, vis)
end
function dock_offset_load()
  local w_md = gx_window
  ui_md.ui_content.gx_window.x = w_md.x + w_md.dx
  ui_md.ui_content.gx_window.y = w_md.y
end
function on_device_reset()
  ui_main.w_top:insert_post_invoke(dock_offset_load, "ui_md.dock_offset_load")
end
function on_popo_ack(popo_def, data, duration_time)
  gx_window.visible = true
  ui_discover.on_popo_ack(popo_def, data, duration_time)
end
function on_timer1()
end
function on_timer()
  ui_md.ui_content.gx_main.alpha = 1
  ui_md.ui_content.gx_main:reset(ui_md.ui_content.gx_main.alpha, 0, 1000)
  ui_md.ui_content.m_timer.suspended = false
  ui_md.m_timer.suspended = true
end
function on_tab_click(btn, msg)
  local name = btn.text
  local name_text = ui.get_text("discover|discover")
  if name == name_text then
    ui_md.m_title.visible = true
  else
    ui_md.m_title.visible = false
  end
end
function on_btn_main_shut_btn(btn)
  ui_md.gx_window.visible = false
end
