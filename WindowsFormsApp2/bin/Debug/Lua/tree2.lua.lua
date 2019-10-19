local c_do_view_move = SHARED("ui_widget.ui_tree2.do_view_move")
local c_lb_text = SHARED("lb_text")
local c_lb_text_exp = SHARED("lb_text_exp")
function update_leaf_highlight(item)
  local vis = item.selected or item.inner_hover
  local fig = item.title:search("fig_highlight")
  fig.visible = vis
end
function on_leaf_sel(item, sel)
  update_leaf_highlight(item)
end
function on_node_expaned(item, expanded)
  if item.depth ~= 1 then
    return
  end
  local t = item.title
  t:search(c_lb_text).visible = not expanded
  t:search(c_lb_text_exp).visible = expanded
end
function on_leaf_mouse(title, msg)
  if msg ~= ui.mouse_enter and msg ~= ui.mouse_leave and msg ~= ui.mouse_inner and msg ~= ui.mouse_outer then
    return
  end
  update_leaf_highlight(title.item)
end
local function do_view_move(w)
  w:update()
  local root = w.root
  for i = 0, root.item_count - 1 do
    local node = root:item_get(i)
    for j = 0, node.item_count - 1 do
      local item = node:item_get(j)
      item.title:tune(c_lb_text)
    end
  end
end
function on_view_move(w)
  w:insert_post_invoke(do_view_move, c_do_view_move)
end
function on_view_init(w, cfg)
  local d = {}
  w.svar.tree2_data = d
  local style, node1, node2 = cfg:split("?")
  d.style = style
  d.node1 = node1
  d.node2 = node2
end
function insert(node, key, unique)
  local d = node.view.svar.tree2_data
  local depth = node.depth
  local style_n
  if depth == 0 then
    style_n = d.node1
  elseif depth == 1 then
    style_n = d.node2
  else
    return nil
  end
  if key == nil then
    local item = node:item_append()
    item:load_style(d.style, style_n)
    return item, false
  end
  if unique == nil then
    unique = false
  end
  local cnt = node.item_count
  local idx = cnt
  for i = 0, cnt - 1 do
    local item = node:item_get(i)
    local key2 = item.svar.tree2_key
    if key2 == key and unique then
      return item
    end
    if not key2 or key < key2 then
      idx = i
      break
    end
  end
  local item = node:item_insert(idx)
  item:load_style(d.style, style_n)
  item.svar.tree2_key = key
  return item, true
end
function set_text(node, text, color, color_exp)
  local lb = node.title:search(c_lb_text)
  lb.text = text
  if color ~= nil then
    lb.color = ui.make_color(color)
  end
  local lb_exp = node.title:search(c_lb_text_exp)
  if lb_exp == nil then
    return
  end
  lb_exp.text = text
  if color_exp ~= nil then
    lb_exp.color = ui.make_color(color_exp)
  end
end
