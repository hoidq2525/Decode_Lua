g_cur_page_win = nil
function insert_tab(name, dis)
  local btn_uri = "$frame/match/match.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/match/arena_list.xml"
  local page_sty = name
  ui_widget.ui_tab.insert_suit(g_match_test, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_widget.ui_tab.get_button(g_match_test, name)
  name = ui.get_text(sys.format("match|%s", name))
  btn.text = name
  if dis ~= nil then
    btn.enable = false
  end
end
function on_match_init()
  insert_tab("arena_list")
  insert_tab("mode_3v3_list")
  insert_tab("mode_gamb_list", true)
  insert_tab("dooaltar_list")
  ui_widget.ui_tab.show_page(g_match_test, "arena_list", true)
  on_apply_init()
  ui_widget.ui_tab.set_button_sound(g_match_test, 578)
end
function on_esc_stk_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  ui_handson_teach.test_complate_match(vis)
end
function handle_openwindow(cmd, data)
  if data:get(packet.key.ui_window_type).v_string ~= L("courage") then
    return
  end
  gx_match_win.visible = true
  ui_handson_teach.test_complate_arena(true)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_match.handle_openwindow"
reg(packet.eSTC_UI_OpenWindow, handle_openwindow, sig)
