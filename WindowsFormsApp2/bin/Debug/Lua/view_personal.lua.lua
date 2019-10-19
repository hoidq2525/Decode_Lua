local ui_tab = ui_widget.ui_tab
function insert_tab(name, x)
  local btn_uri = "$frame/personal/common.xml"
  local btn_sty = "common_tab_btn"
  local page_uri = "$frame/personal/view_" .. name .. ".xml"
  local page_sty = name
  ui_tab.insert_suit(w_view_personal, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_view_personal, name)
  btn.tip.text = ui.get_text("personal|title_" .. name)
  btn:search("tab_pic").irect = ui.rect(x, 0, x + 41, 168)
  btn:insert_on_press(on_tab_btn_press, "ui_view_personal.on_tab_btn_press")
end
g_view_count = 0
function on_init(ctrl)
  ui_tab.clear_tab_data(w_view_personal)
  insert_tab("equip", 2)
  insert_tab("match", 86)
  ui_tab.show_page(w_view_personal, "equip", true)
  g_view_count = 0
end
function on_player_view(cmd, data)
  ui_view_equip.update_data(data)
  ui_tab.show_page(w_view_personal, "equip", true)
  w_view_personal.visible = true
end
function on_visible(ctrl, vis)
  ui_widget.on_esc_stk_visible(ctrl, vis)
end
function on_tab_btn_press(btn, press)
  ui.log("on_tab_btn_press view")
  if press and w_view_personal.visible then
    bo2.PlaySound2D(592)
  end
end
function view_history_name()
  local player = ui_view_personal.ui_view_equip.safe_get_player()
  if sys.check(player) then
    ui_history_name.set_history_name_visible(0, player.name)
  end
end
local sig_name = "ui_view_personal:on_signal"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_PlayerView, on_player_view, sig_name)
