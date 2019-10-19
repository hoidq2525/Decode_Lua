local cur_sel_ctrl, last_sel_ctrl
local g_data = {}
if rawget(_M, "g_dataout") == nil then
  g_dataout = {}
end
function show(data)
  g_data = data
  g_dataout.dir_tree_view = w_dir_view
  g_dataout.top_panel = w_system_dir
  g_dataout.abs_path = nil
  g_dataout.rel_path = nil
  if data.dir_tab == nil or #data.dir_tab <= 0 then
    data.dir_tab = {
      "A:",
      "B:",
      "C:",
      "D:",
      "E:",
      "F:",
      "G:",
      "H:",
      "I:",
      "J:",
      "K:",
      "L:",
      "M:",
      "N:",
      "O:",
      "P:",
      "Q:",
      "R:",
      "S:",
      "T:",
      "U:",
      "V:",
      "W:",
      "X:",
      "Y:",
      "Z:"
    }
  end
  w_dir_view.root:item_clear()
  for idx, val in ipairs(data.dir_tab) do
    local dir_list = sys.get_dirs(val)
    if dir_list.size ~= 0 then
      local cur_node = insert_tree_node(w_dir_view.root)
      local title = cur_node.title
      cur_node.svar.full_dir = val
      local beg_idx = string.find(string.reverse(val), "/")
      local text_show
      if beg_idx ~= nil then
        text_show = string.sub(val, -beg_idx + 1)
      else
        text_show = val
      end
      cur_node.svar.rel_dir = text_show
      cur_node:search("lb_text").text = text_show
    end
  end
  w_path_text.text = ""
  cur_sel_ctrl = nil
  last_sel_ctrl = nil
  if data.btn_confirm_show == false then
    yes_btn.visible = false
  else
    yes_btn.visible = true
  end
  if data.btn_cancel_show == false then
    cancel_btn.visible = false
  else
    cancel_btn.visible = true
  end
  w_system_dir.visible = true
end
function insert_tree_node(node, key, unique)
  local d = node.view.svar.tree2_data
  local depth = node.depth
  local style_n
  if depth == 0 then
    style_n = d.node1
  else
    style_n = d.node2
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
    if key < key2 then
      idx = i
      break
    end
  end
  local item = node:item_insert(idx)
  item:load_style(d.style, style_n)
  item.svar.tree2_key = key
  return item, true
end
function on_dir_click(ctrl)
  ui_widget.on_tree_node_toggle_click(ctrl)
  local dir_item = ctrl.parent.parent
  cur_sel_ctrl = dir_item:search("fig_sel")
  cur_sel_ctrl.visible = true
  if last_sel_ctrl ~= nil and last_sel_ctrl ~= cur_sel_ctrl then
    last_sel_ctrl.visible = false
  end
  last_sel_ctrl = cur_sel_ctrl
  w_path_text.text = dir_item.svar.full_dir
  g_dataout.abs_path = dir_item.svar.full_dir
  g_dataout.rel_path = dir_item.svar.rel_dir
  if g_data.callback_sel ~= nil then
    g_data.callback_sel()
  end
  if dir_item.expanded == true then
    local dir_uri = dir_item.svar.full_dir
    local sub_dir_list = sys.get_dirs(dir_uri)
    if sub_dir_list.size == 0 then
      return
    end
    for idx = 0, sub_dir_list.size - 1 do
      local cur_node = insert_tree_node(dir_item)
      cur_node.svar.full_dir = sub_dir_list:get(idx).v_string
      local full_dir_str = cur_node.svar.full_dir
      local dir_name = full_dir_str
      while dir_name:find("/") ~= -1 do
        _, dir_name = dir_name:split2("/")
      end
      cur_node.svar.rel_dir = dir_name
      cur_node:search("lb_text").text = dir_name
      local cur_title = cur_node.title
      local owner_title = dir_item.title
      local cur_dep = 0
      local cur_dir_name = full_dir_str
      while cur_dir_name:find("/") ~= -1 do
        cur_dep = cur_dep + 1
        _, cur_dir_name = cur_dir_name:split2("/")
      end
      local owner_dep = 0
      if sys.type(dir_item.svar.full_dir) == "wstring" then
        local owner_dir_name = dir_item.svar.full_dir
        while owner_dir_name:find("/") ~= -1 do
          owner_dep = owner_dep + 1
          _, owner_dir_name = owner_dir_name:split2("/")
        end
      elseif sys.type(dir_item.svar.full_dir) == "string" then
        owner_dep = select(2, string.gsub(dir_item.svar.full_dir, "/", "/"))
      end
      cur_title.margin = ui.rect(owner_title.margin.x1 + 20 * (cur_dep - owner_dep), 0, 0, 0)
    end
  else
    dir_item:item_clear()
  end
end
function on_init(ctrl)
  w_system_dir.visible = false
end
function on_yes_btn_click(ctrl)
  w_system_dir.visible = false
  if g_data.callback_confirm ~= nil then
    g_data.callback_confirm()
  end
end
function on_cancel_btn_click(ctrl)
  w_system_dir.visible = false
  if g_data.callback_cancel ~= nil then
    g_data.callback_cancel()
  end
end
function on_path_textbox_key(ctrl)
  local path_text = ""
  if cur_sel_ctrl ~= nil then
    local dir_item = cur_sel_ctrl.parent.parent
    path_text = dir_item.svar.full_dir
  end
  ctrl.text = path_text
end
function on_tree_node_toggle_init(pn)
  local p = pn
  while true do
    if p == nil or sys.is_type(p, "ui_tree_item") then
      break
    end
    p = p.parent
  end
  if p == nil then
    return
  end
  local btn_plus = pn:search("btn_plus")
  local btn_minus = pn:search("btn_minus")
  local function on_tree_node_toggle(item, expanded)
    if expanded then
      btn_plus.visible = false
      btn_minus.visible = true
    else
      btn_plus.visible = true
      btn_minus.visible = false
    end
  end
  p.expanded = false
  p:insert_on_expanded(on_tree_node_toggle)
end
function init()
  system_dir_panel = ui.create_control(ui_phase.w_tool, "panel")
  system_dir_panel:load_style("$widget/system_dir.xml", "system_dir")
end
local msg_create_dir = function(parent_item, dirs, enum_child)
  local c = dirs.size
  dirs:sort()
  for i = 0, c - 1 do
    local abs_path = sys.get_abs_path(dirs:get(i))
    local name_sep = sys.variant(abs_path):split_to_array("/")
    local cnt_sep = name_sep.size
    local name = name_sep:get(cnt_sep - 1).v_string
    if name.empty then
      name = name_sep:get(cnt_sep - 2).v_string
    end
    local item = parent_item:item_append()
    item.expanded = false
    item:load_style("$widget/system_dir.xml", "msg_tree_item")
    item:search("lb_text").text = name
    local sv = item.svar
    sv.dir_name = name
    sv.dir_full = abs_path
    sv.dir_init = true
    if enum_child == true then
      sv.dir_enum_child = true
      sv.dir_has_child = not sys.get_dirs(abs_path).empty
    else
      sv.dir_enum_child = false
      sv.dir_has_child = true
    end
    if not sv.dir_has_child then
      local title = item.title
      title:search("btn_minus").visible = false
      title:search("btn_plus").visible = false
    end
  end
end
function update_msg_item_hilight(item)
  local t = item.title
  local hi = item.selected or t.hover
  t:search("fig_highlight").visible = hi
end
function on_msg_item_sel(item, sel)
  update_msg_item_hilight(item)
  if sel then
    item.topper:search("rb_dir_value").text = item.svar.dir_full
  end
end
function on_msg_item_expanded(item, sel)
  local sv = item.svar
  if sv.dir_init == nil or sv.dir_clicked ~= nil then
    return
  end
  sv.dir_clicked = true
  msg_create_dir(item, sys.get_dirs(sv.dir_full), true)
end
function on_msg_title_mouse(title, msg, pos, wheel)
  if msg == ui.mouse_inner or msg == ui.mouse_outer then
    update_msg_item_hilight(title.item)
  elseif msg == ui.mouse_lbutton_dbl or msg == ui.mouse_lbutton_click then
    local item = title.item
    if item.svar.dir_has_child then
      item.expanded = not item.expanded
    end
  end
end
function on_msg_init(ctrl)
  local tree = ctrl:search("dir_tree")
  msg_create_dir(tree.root, sys.get_drives(), false)
end
function show_open_dir(on_msg_callback, init_dir)
  local function on_msg(msg)
    if msg.result ~= 0 then
      msg.input = msg.window:search("rb_dir_value").text
      if msg.input == nil or msg.input.empty then
        msg.result = 0
      end
    end
    on_msg_callback(msg)
  end
  local msg = {
    callback = on_msg,
    modal = true,
    style_uri = "$widget/system_dir.xml",
    style_name = "msg_system_dir"
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_new_dir_confirm_click(btn)
  local topper = btn.topper
  local fig_input = topper:search("fig_input_dir")
  fig_input.visible = false
  fig_input.focus = false
  local rb_new_dir = fig_input:search("rb_new_dir")
  local new_dir = rb_new_dir.text
  if new_dir.empty then
    return
  end
  local item_sel = topper:search("dir_tree").item_sel
  if item_sel == nil then
    return
  end
  local svar = item_sel.svar
  local parent_path = svar.dir_full
  local full_path = parent_path .. "/" .. new_dir
  if not sys.create_dir(full_path) then
    return
  end
  local item = item_sel:item_append()
  item.expanded = false
  item:load_style("$widget/system_dir.xml", "msg_tree_item")
  item:search("lb_text").text = new_dir
  local sv = item.svar
  sv.dir_name = new_dir
  sv.dir_full = full_path
  sv.dir_init = true
  sv.dir_has_child = false
  item:search("btn_minus").visible = false
  item:search("btn_plus").visible = false
  item.selected = true
  svar.dir_clicked = true
  item_sel.expanded = true
  item:scroll_to_visible()
end
function on_new_dir_cancel_click(btn)
  local fig_input = btn.topper:search("fig_input_dir")
  fig_input.visible = false
  fig_input.focus = false
end
local max_cnt_new_dir = 20
function new_tree_item(parent, dir_name)
  local full_path = parent.svar.dir_full .. "/" .. dir_name
  local item = parent:item_append()
  item.expanded = false
  item:load_style("$widget/system_dir.xml", "msg_tree_item")
  item:search("lb_text").text = dir_name
  local sv = item.svar
  sv.dir_name = dir_name
  sv.dir_full = full_path
  sv.dir_init = true
  sv.dir_has_child = false
  item:search("btn_minus").visible = false
  item:search("btn_plus").visible = false
  item.selected = true
  item:scroll_to_visible()
end
g_menu_valid_msg = {
  [ui.mouse_lbutton_down] = 1,
  [ui.mouse_rbutton_down] = 1,
  [ui.mouse_lbutton_dbl] = 1,
  [ui.mouse_rbutton_dbl] = 1
}
local c_menu_mouse_filter_name = SHARED("ui_widget.ui_system_dir.on_menu_mouse_filter")
function on_new_dir_btn_click(btn)
  local topper = btn.topper
  local tree = topper:search("dir_tree")
  if tree.item_sel == nil then
    return
  end
  local fig_input = topper:search("fig_input_dir")
  local rb_new_dir = fig_input:search("rb_new_dir")
  rb_new_dir.text = ui.get_text("widget|dao2_printscreen")
  rb_new_dir:sel_set(0, rb_new_dir.item_count)
  rb_new_dir.focus = true
  fig_input:show_popup()
  local function on_menu_mouse_filter(ctrl, msg, pos, wheel)
    if g_menu_valid_msg[msg] == nil then
      return
    end
    if not sys.check(fig_input) then
      ui.remove_mouse_filter_prev(c_menu_mouse_filter_name)
      return
    end
    while sys.check(ctrl) do
      if ctrl == fig_input then
        return
      end
      ctrl = ctrl.parent
    end
    ui.remove_mouse_filter_prev(c_menu_mouse_filter_name)
    fig_input.visible = false
  end
  ui.insert_mouse_filter_prev(on_menu_mouse_filter, c_menu_mouse_filter_name)
end
