local text_list_limit = 2000
local c_text = SHARED("text")
function insert_text(view, text, uri, style)
  local size = view.item_count
  local item
  if size >= text_list_limit then
    for i = 1, size - text_list_limit do
      view:item_remove(0)
    end
    item = view:item_get(0)
    item.index = size - 1
  else
    item = view:item_append()
    if uri and style then
      item:load_style(uri, style)
    else
      item:load_style("$widget/text_list.xml", "cmn_text_list_item")
    end
  end
  local t = item:search(c_text)
  t.text = text
  item:tune_y(c_text)
end
function clear(view)
  view:item_clear()
end
function update_items(view)
  for i = 0, view.item_count - 1 do
    local item = view:item_get(i)
    item:tune_y(c_text)
  end
end
function post_update(view)
  function do_update()
    update_items(view)
  end
  view:insert_post_invoke(do_update, "ui_widget.ui_text_list.update")
end
function check_insert(view)
  local t = sys.tick()
  local c = 40000
  for i = 1, c do
    insert_text(view, sys.format("fjpwqiejfpiw fjpwi%d", i))
    view.scroll = 1
  end
  t = sys.dtick(sys.tick(), t)
  ui.log("text_list insert %d items. time %d.", c, t)
end
function on_move(view, area)
  post_update(view)
end
