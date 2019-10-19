log_all = 0
log_error = 1
log_info = 2
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_console.show_console_handle"
local ui_tab = ui_widget.ui_tab
local ui_text_list = ui_widget.ui_text_list
function input_focus()
  w_console:search("input").focus = true
end
function on_toggle()
  local v = not w_console.visible
  w_console.visible = v
  w_console:search("input").focus = v
end
function on_hide(ctrl)
  w_console.visible = false
end
function on_show_gm()
  ui_gm_cammond.ui_gm_main.visible = not ui_gm_cammond.ui_gm_main.visible
  w_console.visible = false
end
function on_toggle_stat(ctrl)
  local w = ui.find_control("$frame:tool_stat")
  w.visible = not w.visible
end
function on_toggle_test_editor(ctrl)
  local w = ui_tool.ui_test_editor.w_top
  w.visible = not w.visible
end
function on_item_mouse(item, msg, pos, wheel)
  if msg == ui.mouse_lbutton_dbl then
    local t = item:search("text")
    ui.cb_copy(t.text)
    insert_text(item.view, "copy text to clipboard.")
  end
end
function insert_text(view, text)
  ui_text_list.insert_text(view, text)
  view.scroll = 1
end
function on_print(txt)
  insert_text(w_text_list_all, txt)
end
function on_log(t, txt)
  if t == log_error then
    insert_text(w_text_list_error, txt)
  elseif t == log_info then
    insert_text(w_text_list_info, txt)
  end
  insert_text(w_text_list_all, txt)
end
function on_key(box, key, flag)
  if flag.down then
    return
  end
  if key == ui.VK_RETURN then
    local text = box.text
    if text.empty then
      return
    end
    box.text = nil
    input_data_add(text)
    cmd_exec(text)
  elseif key == ui.VK_UP then
    input_data_roll(-1)
  elseif key == ui.VK_DOWN then
    input_data_roll(1)
  end
end
function on_timer(timer)
end
function on_config_load(cfg, root)
  input_data_load(root)
end
function on_config_save(cfg, root)
  input_data_save(root)
end
function insert_tab_group(name)
  local btn_uri = "$gui/phase/tool/console.xml"
  local btn_sty = "con_btn"
  local page_uri = "$gui/phase/tool/console.xml"
  local page_sty = "con_page"
  ui_tab.insert_suit(w_console, name, btn_uri, btn_sty, page_uri, page_sty)
  ui_console["w_text_list_" .. name] = ui_tab.get_page(w_console, name):search("text_list")
  ui_tab.get_button(w_console, name).text = ui.get_text("phase|btn_console_page_" .. name)
end
function clear()
  ui_text_list.clear(w_text_list_all)
  ui_text_list.clear(w_text_list_error)
  ui_text_list.clear(w_text_list_info)
end
function on_init(con)
  w_console = con
  insert_tab_group("all")
  insert_tab_group("error")
  insert_tab_group("info")
  if ui_view == nil then
    ui.insert_on_console_toggle("ui_console.on_toggle")
    ui.insert_on_console_print("ui_console.on_print")
    ui.insert_on_console_log("ui_console.on_log")
  end
  ui_tab.show_page(w_console, "all", true)
  cmd_init()
  if ui_view == nil then
    local bmod = "$gui/phase/tool/batch.mod.xml"
    if sys.is_file(bmod) then
      ui.log("load batch module %s.", bmod)
      sys.load_script(bmod)
      return true
    end
    ui.log("w_console init")
  end
end
function show_console_ui_text(cmd, data)
  local text = data:get(packet.key.ui_text).v_string
  ui.console_log(ui_console.log_error, text)
end
reg(packet.eSTC_UI_ShowConsoleText, show_console_ui_text, sig)
