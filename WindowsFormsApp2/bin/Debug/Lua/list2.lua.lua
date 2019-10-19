local c_do_view_move = SHARED("ui_widget.ui_list2.do_view_move")
local c_lb_text = SHARED("lb_text")
local c_lb_text_exp = SHARED("lb_text_exp")
function update_leaf_highlight(item)
  local vis = item.selected or item.inner_hover
  local fig = item:search("fig_highlight")
  fig.visible = vis
end
function on_leaf_sel(item, sel)
  update_leaf_highlight(item)
  local on_sel = item.svar.data2.list2_data.on_item_sel
  if on_sel ~= nil then
    on_sel(item, sel)
  end
end
function on_node_expaned(item, expanded)
  if item.depth ~= 1 then
    return
  end
  local t = item.title
  t:search(c_lb_text).visible = not expanded
  t:search(c_lb_text_exp).visible = expanded
end
function on_leaf_mouse(item, msg)
  if msg ~= ui.mouse_enter and msg ~= ui.mouse_leave and msg ~= ui.mouse_inner and msg ~= ui.mouse_outer then
    return
  end
  update_leaf_highlight(item)
end
local c_node1_dy = 26
function set_expanded(node1, expanded)
  local d1 = node1.svar.data1
  if not expanded then
    d1.node2_list.visible = false
    d1.node2_list:clear_selection()
    d1.btn_plus.visible = true
    d1.btn_minus.visible = false
    d1.lb_text.visible = true
    d1.lb_text_exp.visible = false
    node1.dy = c_node1_dy
    return
  end
  local root = node1.view
  for i = 0, root.item_count - 1 do
    local n = root:item_get(i)
    set_expanded(n, false)
  end
  root:update()
  local dy = root.dy - root.extent.y
  d1.node2_list.visible = true
  d1.btn_plus.visible = false
  d1.btn_minus.visible = true
  d1.lb_text.visible = false
  d1.lb_text_exp.visible = true
  node1.dy = dy + c_node1_dy
end
function on_toggle_click(btn)
  local node1 = btn.parent.parent
  local d1 = node1.svar.data1
  if btn == d1.btn_plus then
    set_expanded(node1, true)
  else
    set_expanded(node1, false)
  end
end
local function load_item1(item, d)
  item:load_style(d.style, d.node1)
  local d1 = {
    list2_data = d,
    lb_text = item:search(c_lb_text),
    lb_text_exp = item:search(c_lb_text_exp),
    btn_minus = item:search("btn_minus"),
    btn_plus = item:search("btn_plus"),
    node2_list = item:search("node2_list")
  }
  d1.title = d1.lb_text.parent
  item.svar.data1 = d1
end
function insert1(w, key, unique)
  local d = w.svar.list2_data
  if key == nil then
    local item = w:item_append()
    load_item1(item, d)
    return item, true
  end
  if unique == nil then
    unique = false
  end
  local cnt = w.item_count
  local idx = cnt
  for i = 0, cnt - 1 do
    local item = w:item_get(i)
    local key2 = item.svar.list2_key
    if key2 == key and unique then
      return item
    end
    if key < key2 then
      idx = i
      break
    end
  end
  local item = w:item_insert(idx)
  load_item1(item, d)
  item.svar.list2_key = key
  return item, true
end
function set_text1(node, text, color, color_exp)
  local d1 = node.svar.data1
  d1.lb_text.text = text
  if color ~= nil then
    d1.lb_text.color = ui.make_color(color)
  end
  d1.lb_text_exp.text = text
  if color_exp ~= nil then
    d1.lb_text_exp.color = ui.make_color(color_exp)
  end
end
local function load_item2(item, d)
  item:load_style(d.style, d.node2)
  local d2 = {
    list2_data = d,
    lb_text = item:search(c_lb_text),
    fig_highlight = item:search("fig_highlight")
  }
  item.svar.data2 = d2
end
function insert2(node1, key, unique)
  local d1 = node1.svar.data1
  local d = d1.list2_data
  local node2_list = d1.node2_list
  if key == nil then
    local item = node2_list:item_append()
    load_item2(item, d)
    return item, true
  end
  if unique == nil then
    unique = false
  end
  local cnt = node2_list.item_count
  local idx = cnt
  for i = 0, cnt - 1 do
    local item = node2_list:item_get(i)
    local key2 = item.svar.list2_key
    if key2 == key and unique then
      return item
    end
    if key < key2 then
      idx = i
      break
    end
  end
  local item = node2_list:item_insert(idx)
  load_item2(item, d)
  item.svar.list2_key = key
  return item, true
end
function set_text2(node, text, color)
  local d2 = node.svar.data2
  d2.lb_text.text = text
  if color ~= nil then
    d1.lb_text.color = ui.make_color(color)
  end
end
local do_view_move = function(root)
  for i = 0, root.item_count - 1 do
    local n = root:item_get(i)
    if n.svar.data1.node2_list.visible then
      set_expanded(n, true)
      break
    end
  end
end
function on_view_move(w)
  w:insert_post_invoke(do_view_move, c_do_view_move)
end
function on_view_init(w, cfg)
  local d = {}
  local svar = w.svar
  svar.list2_data = d
  local style, node1, node2 = cfg:split("?")
  d.style = style
  d.node1 = node1
  d.node2 = node2
end
function on_view_init2(w, cfg)
  if not cfg.empty then
    local d = w.svar.list2_data
    d.on_item_sel = sys.get(cfg)
  end
end
