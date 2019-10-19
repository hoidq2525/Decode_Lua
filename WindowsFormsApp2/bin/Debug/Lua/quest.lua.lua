local ui_tab = ui_widget.ui_tab
local ui_text_list = ui_widget.ui_text_list
c_warning_color = L("FFFF0000")
function insert_tab()
  local name = "current"
  local btn_uri = "$frame/gm/gm.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/gm/" .. name .. ".xml"
  local page_sty = name
  ui_tab.insert_suit(w_quest_list, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_quest_list, name)
  name = ui.get_text("gm_command|title")
  btn.text = name
  ui.insert_quest_on_insert(on_current_quest_insert, "ui_quest.on_current_quest_insert")
end
function on_received_quest_init()
  ui_tab.clear_tab_data(w_quest_list)
  insert_tab()
  ui_tab.show_page(w_quest_list, "current", true)
  for i = 1, ui_current.cammond_train_table.size do
    ui_current.test_insert_tree_item(i)
  end
end
