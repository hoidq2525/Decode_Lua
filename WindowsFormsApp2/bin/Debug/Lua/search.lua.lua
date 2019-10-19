local ui_tab = ui_widget.ui_tab
function insert_tab_search(wnd, name)
  local btn_uri = "$frame/supermarket/search.xml"
  local btn_sty = "search_btn"
  local page_uri = "$frame/supermarket/shelf.xml"
  local page_sty = "shelf_frm"
  ui_tab.insert_suit(wnd, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(wnd, name)
  btn.text = ui.get_text("supermarket|tab_search")
  btn.name = name
end
function hide_all(wnd, name)
  ui_tab.get_button(wnd, name .. 101).visible = false
  ui_tab.get_button(wnd, name .. 102).visible = false
  ui_tab.get_button(wnd, name .. 103).visible = false
  ui_tab.get_button(wnd, name .. 201).visible = false
  ui_tab.get_page(wnd, name .. 101).visible = false
  ui_tab.get_page(wnd, name .. 102).visible = false
  ui_tab.get_page(wnd, name .. 103).visible = false
  ui_tab.get_page(wnd, name .. 201).visible = false
end
function update_search(topwnd, id)
  local name = tostring(topwnd.name) .. "_"
  local wnd = ui_tab.get_page(topwnd, name)
  hide_all(wnd, name)
  wnd.name = name .. id
  ui_supermarket.ui_rank.filter(tostring(wnd.name))
  if id == 10 then
    ui_tab.get_button(wnd, name .. 101).visible = true
    ui_tab.get_button(wnd, name .. 102).visible = true
    ui_tab.get_button(wnd, name .. 103).visible = true
    ui_tab.get_page(wnd, name .. 101).visible = true
    ui_tab.get_page(wnd, name .. 102).visible = true
    ui_tab.get_page(wnd, name .. 103).visible = true
    ui_tab.show_page(wnd, name .. 101, true)
  elseif id == 20 then
    ui_tab.get_button(wnd, name .. 201).visible = true
    ui_tab.get_page(wnd, name .. 201).visible = true
    ui_tab.show_page(wnd, name .. 201, true)
  end
end
function on_menu_event(item)
  update_search(item.topwnd, item.id)
end
function on_btn_click(btn)
  local name = tostring(btn.name)
  local wnd = ui_supermarket.ui_shelf.w_main
  if name == "bjshelf_" then
    wnd = ui_supermarket.ui_bjshelf.w_main
  end
  local data = {
    items = {
      {
        text = ui.get_text("supermarket|search_1"),
        topwnd = wnd,
        id = 10
      },
      {
        text = ui.get_text("supermarket|search_2"),
        topwnd = wnd,
        id = 20
      }
    },
    event = on_menu_event,
    source = btn,
    dx = 160
  }
  ui_tool.show_menu(data)
end
