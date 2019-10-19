c_search_mouse_filter_name = "ui_tool.ui_search.on_search_mouse_filter"
g_max = 6
g_up_index = 0
function on_init()
end
function show_search(data)
  local style_uri = "$gui/phase/tool/tool_search.xml"
  local style_name = "item"
  if #data.list == 0 then
    return
  end
  g_data = data
  w_search.visible = true
  w_search:move_to_head()
  w_list:item_clear()
  for i = 1, #data.list do
    local item = w_list:item_append()
    item:load_style(style_uri, style_name)
    local lb = item:search("lb")
    lb.text = data.list[i].name
  end
  local item = w_list:item_get(0)
  item.selected = true
  local sel = item:search("select")
  sel.visible = true
  if data.input_ctrl == nil then
    w_search:show_popup(data.btn, data.popup)
  else
    w_search:show_popup(data.input_ctrl, data.popup)
  end
  ui.insert_mouse_filter_prev(on_search_mouse_filter, c_search_mouse_filter_name)
end
g_search_valid_msg = {
  [ui.mouse_lbutton_down] = 1,
  [ui.mouse_rbutton_down] = 1,
  [ui.mouse_lbutton_dbl] = 1,
  [ui.mouse_rbutton_dbl] = 1
}
function on_search_mouse_filter(ctrl, msg, pos, wheel)
  if g_search_valid_msg[msg] == nil then
    return
  end
  while sys.check(ctrl) do
    if ctrl == w_search then
      return
    end
    ctrl = ctrl.parent
  end
  ui.remove_mouse_filter_prev(c_search_mouse_filter_name)
  search_hide()
end
function search_hide()
  w_search.visible = false
  w_list:item_clear()
  g_up_index = 0
end
function on_select_mouse(p, msg, pos, wheel)
  local select = p.parent:search("select")
  if msg == ui.mouse_enter then
    select.visible = true
    p.parent.selected = true
  end
  if msg == ui.mouse_leave then
    select.visible = false
    p.parent.selected = false
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_down then
    local lb = p:search("lb")
    g_data.input_ctrl.text = lb.text
    w_search.visible = false
  end
end
function get_selected()
  local item = w_list.item_sel
  if item == nil then
    return nil
  end
  local lb = item:search("lb")
  return lb.text
end
function select_up()
  local item = w_list.item_sel
  if item == nil then
    return
  end
  if item.index == 0 then
    return
  end
  local select = item:search("select")
  select.visible = false
  local new_item = w_list:item_get(item.index - 1)
  new_item.selected = true
  new_select = new_item:search("select")
  new_select.visible = true
  if w_list.scroll == 0 then
    return
  end
  if new_item.index >= g_up_index then
    return
  end
  if w_list.item_count <= g_max then
    return
  end
  g_up_index = g_up_index - 1
  if 0 >= g_up_index then
    g_up_index = 0
  end
  w_list.scroll = w_list.scroll - 1 / (w_list.item_count - g_max)
end
function select_down()
  local item = w_list.item_sel
  if item == nil then
    return
  end
  if item.index == w_list.item_count - 1 then
    return
  end
  local select = item:search("select")
  select.visible = false
  local new_item = w_list:item_get(item.index + 1)
  new_item.selected = true
  local new_select = new_item:search("select")
  new_select.visible = true
  if new_item.index < g_max then
    return
  end
  if w_list.scroll == 1 then
    return
  end
  g_up_index = g_up_index + 1
  w_list.scroll = w_list.scroll + 1 / (w_list.item_count - g_max)
end
function get_visible()
  return w_search.visible
end
