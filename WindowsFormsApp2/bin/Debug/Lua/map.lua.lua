g_cur_area_name = nil
g_init_open = false
c_mark_deliver = 13
function insert_child_item(item, text)
  local child_item_uri = L("$frame/map/map.xml")
  local child_item_style = L("map_item_child")
  local child_item = item:item_append()
  child_item:load_style(child_item_uri, child_item_style)
  child_item:search("item_text").text = text
  return child_item
end
function on_child_item_click()
end
function get_deliver_map(point)
  local map_excel = bo2.gv_map_list:find(g_map_level.cur_map_id)
  if map_excel == nil then
    return 0
  end
  local scn_id = map_excel.scn_id
  local area = bo2.map_mark_point_area(scn_id, point.x, point.y)
  if area == 0 then
    return 0
  end
  local area_excel = bo2.gv_area_list:find(area)
  if area_excel == nil then
    return 0
  end
  local scn_id = area_excel.trans_scn
  local scn_excel = bo2.gv_scn_list:find(scn_id)
  if scn_excel == nil then
    return 0
  end
  local new_map = scn_excel.map_id
  local new_map_excel = bo2.gv_map_list:find(new_map)
  if new_map_excel == nil then
    return 0
  end
  return scn_id
end
local deliver_operator = function(btn)
  if btn.svar.scn_id == nil or btn.svar.scn_id == 0 then
    return false
  end
  local scn_id = btn.svar.scn_id
  local scn_excel = bo2.gv_scn_list:find(scn_id)
  if sys.check(scn_excel) ~= true then
    return false
  end
  local function do_some()
    if sys.check(btn) then
      local id = scn_excel.map_id
      change_map({
        id = id,
        scn = scn_id,
        op = 2
      })
    end
  end
  bo2.AddTimeEvent(1, do_some)
  return true
end
local check_deliver = function(btn)
  if btn.svar.scn_id == nil or btn.svar.scn_id == 0 then
    return false
  end
  return true
end
function on_misc(btn, msg)
  if msg == ui.mouse_lbutton_down then
    do
      local point = btn.parent.svar
      btn.svar.c = true
      local function on_time()
        if sys.check(btn) ~= true then
          return
        end
        if btn.svar.c ~= true then
          return
        end
        btn.svar.c = false
        find_path_byid(point.id)
      end
      local type = point.type
      if c_mark_deliver == type and check_deliver(btn.parent) == true then
        bo2.AddTimeEvent(10, on_time)
      else
        find_path_byid(point.id)
      end
    end
  elseif msg == ui.mouse_lbutton_dbl then
    local point = btn.parent.svar
    local type = point.type
    if c_mark_deliver == type and deliver_operator(btn.parent) == true then
      btn.svar.c = false
      return
    end
  end
end
function insert_tree_node(text)
  for i, v in ipairs(marks_type) do
    if v.name == text then
      return v.item
    end
  end
  local root = ui_map.w_op_tree.root
  local style_uri = L("$gui/frame/map/map.xml")
  local style_name_g = L("map_node_group1")
  local style_name_k = L("map_item_child")
  local item_g = root:item_append()
  item_g:load_style(style_uri, style_name_g)
  item_g:search("title_label").text = text
  table.insert(marks_type, {name = text, item = item_g})
  return item_g
end
function clear_mark_tree()
  ui_map.w_op_tree.root:item_clear()
  marks_type = {}
end
function on_close(btn)
  ui.find_control("$frame:map").visible = false
end
function reload_area(scn_id)
  ui_widget.ui_combo_box.clear(w_cb_map_area)
  local excel = bo2.gv_scn_list:find(scn_id)
  if excel == nil then
    return nil
  end
  for i = 0, bo2.gv_map_list.size - 1 do
    local excel = bo2.gv_map_list:get(i)
    if excel.scn_id == scn_id then
      ui_widget.ui_combo_box.append(w_cb_map_area, {
        id = excel.id,
        text = excel.name,
        scn = scn_id
      })
    end
  end
  ui_widget.ui_combo_box.select(w_cb_map_area, g_map_level.cur_map_id)
end
function change_scn(item)
  local scn_id = item.id
  local excel = bo2.gv_scn_list:find(scn_id)
  if excel == nil then
    return nil
  end
  local t_map = {}
  t_map.id = excel.map_id
  t_map.scn_id = scn_id
  t_map.level = c_level_scn
  load_map_byid(t_map)
end
function change_map(item)
  local map_id = item.id
  local scn_id = item.scn
  local level = item.level
  if level == nil then
    level = c_level_scn
  end
  local t_map = {}
  t_map.id = map_id
  t_map.scn_id = scn_id
  t_map.level = level
  t_map.stack_op = item.op
  load_map_byid(t_map)
end
function cb_init()
  ui_widget.ui_combo_box.clear(w_cb_map_scnce)
  for i = 0, bo2.gv_scn_list.size - 1 do
    local scn_excel = bo2.gv_scn_list:get(i)
    if scn_excel.map_id ~= 0 and scn_excel.in_map_list ~= 0 then
      ui_widget.ui_combo_box.append(w_cb_map_scnce, {
        id = scn_excel.id,
        text = scn_excel.name
      })
    elseif scn_excel.map_id ~= 0 and scn_excel.in_map_list == 0 and cur_scn_id ~= nil and scn_excel.map_id == cur_scn_id then
      ui_widget.ui_combo_box.append(w_cb_map_scnce, {
        id = scn_excel.id,
        text = scn_excel.name
      })
    end
  end
  w_cb_map_scnce.svar.on_select = change_scn
  w_cb_map_area.svar.on_select = change_map
end
function on_init()
  cb_init()
  current_scn = nil
  object = nil
  marks_type = {}
  links = readgraph()
  path = {}
  local scale_x
  scale_y = nil
  map_base = 0.78125
  g_patch = 0
  map_x1 = 0
  map_y1 = 0
  map_x2 = 0
  map_y2 = 0
  last_highlight_ctrl = nil
  cur_scn_id = nil
  g_map_level.cur_map_id = nil
  cur_prov_id = 0
  flag_open = false
  if sys.check(bo2.scn) then
    local scn_excel = bo2.scn.excel
    if sys.check(scn_excel) then
      load_scn(scn_excel.id)
    end
  end
end
function t()
  ui_map.on_init()
end
function load_map(obj)
  g_init_open = true
  if obj == bo2.player then
    path_data = {}
    last_highlight_ctrl = nil
    object = obj
    g_cur_area_name = nil
    object:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_AreaID, update_map, "ui_map:update_map")
    local mb_current_scn = bo2.scn.scn_excel
    ui_minimap.w_current_scn.text = mb_current_scn.name
    if ui_map.load_scn(mb_current_scn.id) == false then
      return false
    end
  end
end
function name2node(graph, name)
  if not graph[name] then
    graph[name] = {
      name = name,
      adj = {}
    }
  end
  return graph[name]
end
function readgraph()
  local graph = {}
  for i = 0, bo2.gv_scn_link.size - 1 do
    local from = name2node(graph, bo2.gv_scn_link:get(i).Srcid)
    local to = name2node(graph, bo2.gv_scn_link:get(i).targetid)
    from.adj[to] = bo2.gv_scn_link:get(i).markname
  end
  return graph
end
function findlink(curr, to, visited)
  if curr.visited then
    return nil
  end
  curr.visited = true
  path[#path + 1] = curr
  if curr == to then
    for i, v in ipairs(path) do
      if i ~= 1 then
      end
    end
    tmp_path[#tmp_path + 1] = {}
    for i, v in ipairs(path) do
      table.insert(tmp_path[#tmp_path], path[i])
    end
    return path
  end
  for node in pairs(curr.adj) do
    local p = findlink(node, to, visited)
    if p then
      path[#path].visited = false
      path[#path] = nil
    end
  end
  path[#path].visited = false
  path[#path] = nil
end
local on_reset_map = function()
  local map_id = bo2.gv_scn_list:find(cur_scn_id).map_id
  local id = bo2.player:get_atb(bo2.eAtb_AreaID)
  local area_excel = bo2.gv_area_list:find(id)
  if area_excel then
    local prov_excel = bo2.gv_prov_list:find(area_excel.in_prov)
    if prov_excel then
      map_id = prov_excel.map_id
    end
  end
  change_map({id = map_id, scn = cur_scn_id})
  ui_widget.ui_combo_box.select(w_cb_map_scnce, cur_scn_id)
  if w_cb_map_scnce.svar.btn.text == L("") then
    w_cb_map_scnce.svar.btn.text = ui_minimap.w_current_scn.text
  end
  ui_widget.ui_combo_box.select(w_cb_map_area, g_map_level.cur_map_id)
  if w_cb_map_area.svar.btn.text == L("") then
    w_cb_map_area.svar.btn.text = ui_minimap.w_current_scn.text
  end
  if global_map == false then
    ctrl.visible = false
    ui_tool.note_insert(ui.get_text("map|err_no_map"), "ffff00")
    return false
  end
  return true
end
function on_visible(ctrl, vis)
  if ctrl.visible == true then
    if g_init_open then
      g_init_open = false
      if on_reset_map() ~= true then
        return
      end
    end
    flag_open = true
    ui_handson_teach.on_test_visible_set_proprity(ui_map.w_main)
  else
    flag_open = false
    ui_map.w_main.priority = 110
  end
  bo2.SendUIEvent(bo2.eUIEvent_Map, ctrl.visible)
  for k, v in pairs(links) do
    for m, n in pairs(v.adj) do
    end
  end
  on_vis_send_dynamic_pos_data(vis)
end
function btn_change_map(btn)
  if btn.text == ui.get_text("map|world_map") then
    btn.text = ui.get_text("map|current_map")
    load_world_map()
  else
    btn.text = ui.get_text("map|world_map")
    local map_id = bo2.gv_scn_list:find(cur_scn_id).map_id
    local id = bo2.player:get_atb(bo2.eAtb_AreaID)
    local area_excel = bo2.gv_area_list:find(id)
    if area_excel then
      local prov_excel = bo2.gv_prov_list:find(area_excel.in_prov)
      if prov_excel then
        map_id = prov_excel.map_id
      end
    end
    change_map({id = map_id, scn = cur_scn_id})
  end
end
local load_map_id = 0
function on_map_detail(btn, msg, pos)
  if msg == ui.mouse_lbutton_click then
    local map_id = btn.parent.svar
    if map_id ~= nil and map_id ~= 0 then
      load_map_id = map_id
      btn:insert_post_invoke(on_load_map_id, "ui_map.on_load_map_id")
    end
  elseif msg == ui.mouse_inner then
    btn.parent:search("bg_fold").visible = true
  elseif msg == ui.mouse_outer then
    btn.parent:search("bg_fold").visible = false
  end
end
function on_load_map_id()
  change_map({id = load_map_id, scn = cur_scn_id})
end
function s()
  find_path(722, 1024)
end
function run()
  load_map(bo2.player)
end
local sig_name = "ui_map:on_signal"
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enter_scn, load_map, sig_name)
