local g_select_item = {
  item = nil,
  idx = 0,
  _type = 0
}
local c_excel_id = 1
local c_excel_data = 2
local g_current_search_text
g_content_select = {}
g_history_selected = {}
g_history_search = {}
function on_init_history_selected()
  g_history_selected = {
    size = 0,
    index = -1,
    gap_index = -1,
    limit = 3
  }
end
function on_init_history_search()
  g_history_search = {
    size = 0,
    index = -1,
    gap_index = -1,
    limit = 20
  }
end
function on_insert_history(val)
  local size = g_history_selected.size
  local limit = g_history_selected.limit
  if size < limit then
    g_history_selected[size] = val
    g_history_selected.index = size
    g_history_selected.size = g_history_selected.size + 1
  else
    local gap_index = g_history_selected.gap_index
    if gap_index < 0 then
      gap_index = 0
    end
    g_history_selected[gap_index] = val
    g_history_selected.index = gap_index
    g_history_selected.gap_index = gap_index + 1
    if limit <= g_history_selected.gap_index then
      g_history_selected.gap_index = 0
    end
  end
end
function on_insert_history_search(val)
  local size = g_history_search.size
  local limit = g_history_search.limit
  if size < limit then
    g_history_search[size] = val
    g_history_search.index = size
    g_history_search.size = g_history_search.size + 1
  else
    local gap_index = g_history_search.gap_index
    if gap_index < 0 then
      gap_index = 0
    end
    g_history_search[gap_index] = val
    g_history_search.index = gap_index
    g_history_search.gap_index = gap_index + 1
    if limit <= g_history_search.gap_index then
      g_history_search.gap_index = 0
    end
  end
end
function on_history_search_roll_back()
  local index = -1
  if g_history_search.index < 0 then
    return index
  end
  if 0 <= g_history_search.index - 1 then
    return g_history_search.index - 1
  else
    return g_history_search.size - 1
  end
end
function on_history_search_roll_front()
  local index = -1
  if g_history_search.index < 0 then
    return index
  end
  if g_history_search.index + 1 >= g_history_search.size then
    return 0
  else
    return g_history_search.index + 1
  end
end
function on_history_roll_back()
  local index = -1
  if g_history_selected.index < 0 then
    return index
  end
  local size = g_history_selected.size
  local limit = g_history_selected.limit
  local gap_index = g_history_selected.gap_index
  if size < limit or gap_index < 0 then
    if g_history_selected.index > 0 then
      return g_history_selected.index - 1
    end
  else
    local gap_index = g_history_selected.gap_index
    if g_history_selected.index == gap_index then
      return index
    elseif 0 <= g_history_selected.index - 1 then
      return g_history_selected.index - 1
    else
      return g_history_selected.limit - 1
    end
  end
  return index
end
function on_history_roll_front()
  local index = -1
  if g_history_selected.index < 0 then
    return index
  end
  local size = g_history_selected.size
  local limit = g_history_selected.limit
  local gap_index = g_history_selected.gap_index
  if size < limit or gap_index < 0 then
    if size > g_history_selected.index + 1 then
      return g_history_selected.index + 1
    end
  elseif g_history_selected.index + 1 == gap_index or gap_index == 0 and limit <= g_history_selected.index + 1 then
    return index
  elseif limit <= g_history_selected.index + 1 then
    return 0
  else
    return g_history_selected.index + 1
  end
  return index
end
function on_init_content_link(idx, _parent_item, _child_item, page_idx)
  g_content_select[idx] = {
    level_one_item = _parent_item,
    level_two_item = _child_item,
    page_idx = page_idx
  }
end
function on_init_guide_list()
  g_select_item = {}
  g_content_select = {}
  on_init_history_selected()
  on_init_history_search()
  local init_index_size = bo2.gv_bo2_guide_index.size
  for i = 0, init_index_size - 1 do
    local mb_guide_index = bo2.gv_bo2_guide_index:get(i)
    if mb_guide_index.index_type == 0 then
      on_init_guide_list_level_1_item(ui_bo2_guide.w_bo2_guide_tree_root, mb_guide_index)
    end
  end
end
function on_init_guide_list_level_1_item(_parent, _mb_data)
  if _parent == nil then
    return false
  end
  local item_uri = "$frame/help/bo2_guide_kit.xml"
  local item_style = "guide_list_item"
  local app_item = _parent:item_append()
  app_item.obtain_title:load_style(item_uri, item_style)
  local desc_label = app_item.obtain_title:search("desc_label")
  desc_label.text = _mb_data.index_name
  if _mb_data.expansion ~= 0 then
    app_item.expanded = true
    app_item:search("btn_minus").visible = true
    app_item:search("btn_plus").visible = false
  else
    app_item.expanded = false
  end
  app_item.obtain_title.var:set(c_excel_id, _mb_data.id)
  local inc_index_size = _mb_data.inc_index.size
  for i = 0, inc_index_size - 1 do
    local inc_mb_data = bo2.gv_bo2_guide_index:find(_mb_data.inc_index[i])
    if inc_mb_data ~= nil then
      on_init_guide_list_level_2_item(app_item, inc_mb_data, i, app_item)
    end
  end
  local inc_content_size = _mb_data.inc_content.size
  for i = 0, inc_content_size - 1 do
    local link_content_idx = _mb_data.inc_content[i]
    local inc_mb_data = bo2.gv_bo2_guide_content:find(link_content_idx)
    if inc_mb_data ~= nil then
      on_init_content_link(link_content_idx, app_item.obtain_title, nil, i)
    end
  end
end
function on_init_guide_list_level_2_item(_parent, _inc_mb_data, i, app_item)
  local child_item_uri = "$frame/help/bo2_guide_kit.xml"
  local child_item_style = "guide_list_item_child"
  local child_item = _parent:item_append()
  child_item.obtain_title:load_style(child_item_uri, child_item_style)
  local lb = child_item:search("item_text")
  lb.text = _inc_mb_data.index_name
  local set_value_panel = child_item:search("child_panel")
  set_value_panel.var:set(c_excel_id, _inc_mb_data.id)
  local inc_content_size = _inc_mb_data.inc_content.size
  for i = 0, inc_content_size - 1 do
    local link_content_idx = _inc_mb_data.inc_content[i]
    local inc_mb_data = bo2.gv_bo2_guide_content:find(link_content_idx)
    if inc_mb_data ~= nil then
      on_init_content_link(link_content_idx, app_item.obtain_title, set_value_panel, i)
    end
  end
end
function on_mutex_select_item(select_item, _type, idx)
  if g_select_item.item == nil then
    g_select_item.item = select_item
  elseif g_select_item.item ~= select_item then
    g_select_item.item.visible = false
    g_select_item.item = select_item
  else
    return false
  end
  if g_select_item.item ~= nil then
    if _type == 1 and select_item.parent.parent.parent.expanded == true then
      select_item.visible = true
      return true
    end
    g_select_item.idx = idx
    g_select_item._type = _type
  end
  select_item.visible = not select_item.visible
  return false
end
function on_update_content_text(item_excel_id, record_history)
  local mb_guide_index = bo2.gv_bo2_guide_index:find(item_excel_id)
  if mb_guide_index == nil or mb_guide_index.inc_content.size <= 0 then
    return false
  end
  local mb_data = bo2.gv_bo2_guide_content:find(mb_guide_index.inc_content[0])
  if mb_data then
    on_view_mtf(theme_type_topic, mb_data.id)
  end
end
function on_set_default_text()
  ui_bo2_guide.rb_context.mtf = L("")
end
function on_set_content_text(title, content_text)
  ui_bo2_guide.rb_context.mtf = content_text
end
function on_show_text()
  if g_select_item == nil or g_select_item.item == nil then
    if ui_bo2_guide.rb_context ~= nil then
      ui_bo2_guide.rb_context.mtf = L("")
    end
  else
    ui_bo2_guide.rb_context.mtf = L("")
  end
end
function on_list_item_child_mouse(item, msg)
  if msg == ui.mouse_lbutton_click then
    local child_item = item:search(L("select"))
    local item_excel_id = item.var:get(c_excel_id).v_int
    on_mutex_select_item(child_item, 0, 1)
    on_update_content_text(item_excel_id, 1)
  end
end
function on_list_plus_click(btn)
  local p = btn.parent
  local select_item = p.parent:search(L("select"))
  local bset = on_mutex_select_item(select_item, 1, 2)
  local item_excel_id = p.parent.var:get(c_excel_id).v_int
  on_update_content_text(item_excel_id, 1)
  p:search("btn_minus").visible = true
  btn.visible = false
  local p_item = p.parent.parent
  p_item.expanded = true
  p_item:scroll_to_visible()
end
function on_list_minus_click(btn)
  local p = btn.parent
  local select_item = p.parent:search(L("select"))
  local bset = on_mutex_select_item(select_item, 1, 2)
  local item_excel_id = p.parent.var:get(c_excel_id).v_int
  on_update_content_text(item_excel_id, 1)
  p:search("btn_plus").visible = true
  btn.visible = false
  local p_item = p.parent.parent
  p_item.expanded = false
  p_item:scroll_to_visible()
end
function runf_select_item(...)
  local idx = arg[1].v_int
  on_select_item_by_content_idx(idx)
end
function run()
  w_main.visible = true
  local var = sys.variant()
  var:set(packet.key.cmn_type, 2)
  var:set(packet.key.cmn_id, 17021)
  on_select_item_by_var(var)
end
function on_select_item_by_content_idx(idx, record)
  if g_content_select == nil or g_content_select[idx] == nil then
    return false
  end
  local parent_item = g_content_select[idx].level_one_item
  local child_item = g_content_select[idx].level_two_item
  local page_idx = g_content_select[idx].page_idx
  local set_expanded_btn = function(p)
    p:search("btn_minus").visible = true
    p:search("btn_plus").visible = false
    local p_p = p.parent
    p_p.expanded = true
    p_p:scroll_to_visible()
  end
  if child_item == nil then
    local function _on_list_plus_click(p, idx)
      local select_item = p:search(L("select"))
      local bset = on_mutex_select_item(select_item, 1, 2)
      local item_excel_id = p.var:get(c_excel_id).v_int
      set_expanded_btn(p)
    end
    _on_list_plus_click(parent_item, page_idx)
    return
  end
  set_expanded_btn(parent_item)
  local select_item = parent_item:search(L("select"))
  local bset = on_mutex_select_item(select_item, 1, 2)
  local _child_item = child_item:search(L("select"))
  local item_excel_id = child_item.var:get(c_excel_id).v_int
  on_mutex_select_item(_child_item, 0, 1)
  return true
end
function on_click_roll_back()
  local val = on_history_roll_back()
  if val ~= -1 then
    g_history_selected.index = val
    on_select_item_by_content_idx(g_history_selected[val])
  end
end
function on_click_roll_front()
  local val = on_history_roll_front()
  if val ~= -1 then
    g_history_selected.index = val
    on_select_item_by_content_idx(g_history_selected[val])
  end
end
function select_data_load(root)
  if root == nil then
    return
  end
  local n = root:find("history")
  if n == nil then
    return
  end
  for i = 0, n.size - 1 do
    local t = n:get(i)
    local s = t:get_attribute_int("value")
    if s >= 0 then
      on_insert_history(s)
    end
  end
  g_history_selected.index = n:get_attribute_int("index")
  g_history_selected.gap_index = n:get_attribute_int("gap_index")
  g_history_selected.limit = n:get_attribute_int("limit")
  if 0 >= g_history_selected.limit then
    g_history_selected.limit = 20
  end
end
function search_data_load(root)
  if root == nil then
    return
  end
  local n = root:find("search")
  if n == nil then
    return
  end
  for i = 0, n.size - 1 do
    local t = n:get(i)
    local s = t:get_attribute("value")
    if not s.empty then
      on_insert_history_search(s)
    end
  end
  g_history_search.index = n:get_attribute_int("index")
  g_history_search.gap_index = n:get_attribute_int("gap_index")
  g_history_search.limit = n:get_attribute_int("limit")
end
function select_data_save(root)
  if root == nil then
    return
  end
  local n = root:get("history")
  n:clear()
  local size = g_history_selected.size
  for i = 0, size - 1 do
    n:add("item"):set_attribute("value", g_history_selected[i])
  end
  n:set_attribute("index", g_history_selected.index)
  n:set_attribute("gap_index", g_history_selected.gap_index)
  n:set_attribute("limit", g_history_selected.limit)
end
function search_data_save(root)
  if root == nil then
    return
  end
  local n = root:get("search")
  n:clear()
  local size = g_history_search.size
  for i = 0, size - 1 do
    n:add("item"):set_attribute("value", g_history_search[i])
  end
  n:set_attribute("index", g_history_search.index)
  n:set_attribute("gap_index", g_history_search.gap_index)
  n:set_attribute("limit", g_history_search.limit)
end
function on_config_load(cfg, root)
  select_data_load(root)
  search_data_load(root)
end
function on_config_save(cfg, root)
  select_data_save(root)
  search_data_save(root)
end
function on_mouse_search_item(item, msg)
  if msg == ui.mouse_enter then
    item.parent:search("select").visible = true
  end
  if msg == ui.mouse_leave then
    item.parent:search("select").visible = false
  end
end
function on_click_search_item(btn)
  p_search_list.visible = false
  w_text_box.focus = false
  local var = btn.parent.svar
  on_select_item_by_var(var)
end
function on_key_down_search_roll_back()
  local idx = on_history_search_roll_back()
  if idx >= 0 then
    g_history_search.index = idx
    w_text_box.text = g_history_search[idx]
    on_search_help(g_history_search[idx])
  end
end
function on_key_down_search_roll_front()
  local idx = on_history_search_roll_front()
  if idx >= 0 then
    g_history_search.index = idx
    w_text_box.text = g_history_search[idx]
    on_search_help(g_history_search[idx])
  end
end
function on_key_down_find_box(ctrl, key, keyflag)
  if keyflag.down ~= true then
    return
  end
  if key == ui.VK_ESCAPE then
    w_text_box:search("input").text = ui.get_text("guide|default_search_text")
    reset_search()
  elseif key == ui.VK_RETURN then
    on_click_dump_search_result(btn_search_data)
  elseif key == ui.VK_UP then
  elseif key == ui.VK_DOWN then
  end
end
function reset_search()
  w_find_list:item_clear()
  p_search_list.visible = false
end
function append_item(list, text, var)
  local item = list:item_insert(list.item_count)
  item:load_style("$frame/help/bo2_guide.xml", "finditem")
  item:search("text").text = text
  item.svar = var
end
function on_update_search_hent(text)
  reset_search()
  local append_data = function(var)
    local item = w_find_list:item_append()
    item:load_style("$frame/help/bo2_guide.xml", "finditem")
    item:search(L("mtf_text")).mtf = var.text
    item.svar = var.var
  end
  on_query_by_text(text, append_data)
end
function on_click_dump_search_result(btn)
  ui_bo2_guide.p_search_list.visible = false
  local search_text = w_text_box.text
  if search_text.size <= 0 then
    return
  end
  if search_text == ui.get_text("guide|default_search_text") then
    return
  end
  local var = sys.variant()
  var:set(packet.key.cmn_type, theme_type_search_result)
  local _text = ui_bo2_guide.w_text_box.text
  local idx = get_search_result_index(_text)
  var:set(packet.key.cmn_id, idx)
  g_search_result[idx] = {
    name = ui_widget.merge_mtf({text = _text}, ui.get_text("guide|search_result")),
    key = _text
  }
  on_select_item_by_var(var)
end
function on_search_help(text, record)
end
local c_menu_mouse_filter_name = L("ui_tool.on_menu_mouse_filter")
function on_menu_mouse_filter(ctrl, msg, pos, wheel)
  if ui_tool.g_menu_valid_msg[msg] == nil then
    return
  end
  while sys.check(ctrl) do
    if ctrl == p_search_list or ctrl == ui_bo2_guide.w_text_box then
      return
    end
    ctrl = ctrl.parent
  end
  p_search_list.visible = false
end
function on_visible_search_list(w, vis)
  if vis == true then
    ui.insert_mouse_filter_prev(on_menu_mouse_filter, c_menu_mouse_filter_name)
  else
    ui.remove_mouse_filter_prev(c_menu_mouse_filter_name)
  end
end
function on_change_find_box(panel, text)
  if text ~= nil and text ~= g_current_search_text then
    if text.size > 0 then
      on_update_search_hent(text)
      p_search_list.visible = true
    else
      reset_search()
    end
  end
end
function on_mouse_find_box(panel, msg)
  if msg == ui.mouse_lbutton_down then
    if w_text_box:search("input").text == ui.get_text("guide|default_search_text") then
      w_text_box:search("input").text = nil
      p_search_list.visible = false
    else
      p_search_list.visible = true
    end
    g_current_search_text = nil
  end
end
