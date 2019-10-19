local mark_icon_uri = "$icon/npc/"
local maps_uri = "$icon/map/scn/"
local default_mapid = 99999
local top_world_mapid = 99998
local map_detail_table = sys.load_table("$mb/scn/map_detail_list.xml")
local g_dynamic_pos_data = {}
local foot_trace_data = {}
local world_scnlist = {}
g_real_mark = 0
g_m_id = 0
g_map_level = {}
c_level_top = 0
c_level_scn = 1
c_level_detail = 2
c_level_area = 3
local map_dx = 16
local map_dy = 768
function clear_map_stack()
  g_map_level.stack = {}
  g_map_level.c_stack = nil
  g_map_level.c_map = nil
end
function on_init_map_level()
  g_map_level.cur_map_id = nil
  g_map_level.top_level = top_world_mapid
  g_map_level.current_level = c_level_top
  g_map_level.block = false
  g_map_level.cur_index_x = nil
  g_map_level.cur_index_y = 0
  g_map_level.detail_scale = 1
  clear_map_stack()
end
on_init_map_level()
function is_current_level(level)
  return g_map_level.current_level == level
end
function is_may_show_level(level)
  do return false end
  if level == c_level_detail then
    return g_map_level.current_level == c_level_scn or g_map_level.current_level == c_level_detail
  end
  return true
end
function is_map_block()
  return g_map_level.block == true
end
function is_map_top_level()
  return g_map_level.cur_map_id == top_world_mapid
end
function set_map_level(level)
  g_map_level.current_level = level
end
function get_mouse_to_map_pos(x, y, size_x, size_y)
  local offset
  if is_current_level(c_level_detail) then
    local cur_index_x = g_map_level.cur_index_x
    local cur_index_y = g_map_level.cur_index_y
    local scale = g_map_level.detail_scale
    local off_x = (x - (cur_index_x - 1) * 256) * scale - size_x + map_dx
    local off_y = (map_dy - (y - (cur_index_y - 1) * 256)) * scale - size_y
    offset = ui.point(off_x, off_y)
  else
    offset = ui.point(scale_x * (x - map_x1) - size_x, scale_y * (g_patch - y - map_y1) - size_y)
  end
  return offset
end
function block_mouse()
  g_map_level.block = true
  local fun_block_wheel = function()
    g_map_level.block = false
  end
  bo2.AddTimeEvent(5, fun_block_wheel)
end
function map_level_op(mouse_x, mouse_y, msg)
  local map_down = false
  local map_up = op ~= nil
  local _wheel = g_wheel
  local zoom_down = _wheel <= -1
  local zoom_up = _wheel >= 1
  map_down = zoom_down
  map_up = zoom_up or msg == ui.mouse_rbutton_click
  if map_up == true or map_down == true then
    g_wheel = 0
  end
  local load_up_level_map = function()
    local c_map_id = bo2.gv_map_list:find(g_map_level.cur_map_id)
    if c_map_id ~= nil then
      local map_id = bo2.gv_scn_list:find(c_map_id.scn_id).map_id
      local up_map = g_map_level.cur_map_id ~= map_id and map_id ~= 0
      local c_level = g_map_level.current_level
      up_map = up_map or c_level == c_level_detail
      if up_map then
        ui_widget.ui_combo_box.select(w_cb_map_area, map_id)
        change_map({id = map_id, scn = cur_scn_id})
        return
      end
    end
    load_world_map()
  end
  local function load_down_level_map()
    local map_excel = bo2.gv_map_list:find(g_map_level.cur_map_id)
    if map_excel == nil then
      return false
    end
    local scn_id = map_excel.scn_id
    local area = bo2.map_mark_point_area(scn_id, mouse_x, mouse_y)
    local area_excel = bo2.gv_area_list:find(area)
    if area_excel == nil then
      return
    end
    local prov_excel = bo2.gv_prov_list:find(area_excel.in_prov)
    if prov_excel == nil or prov_excel.map_id == 0 then
      if is_may_show_level(c_level_detail) ~= true then
        return false
      end
      local t_map = {}
      t_map.id = g_map_level.cur_map_id
      t_map.scn_id = scn_id
      t_map.level = c_level_detail
      t_map.d_x = mouse_x
      t_map.d_y = mouse_y
      load_map_byid(t_map)
      return true
    end
    if g_map_level.cur_map_id == prov_excel.map_id then
      if is_may_show_level(c_level_detail) ~= true then
        return false
      end
      local t_map = {}
      t_map.id = g_map_level.cur_map_id
      t_map.scn_id = scn_id
      t_map.level = c_level_detail
      t_map.d_x = mouse_x
      t_map.d_y = mouse_y
      load_map_byid(t_map)
      return true
    end
    local t_map = {}
    t_map.id = prov_excel.map_id
    t_map.scn_id = scn_id
    t_map.level = c_level_area
    t_map.d_x = mouse_x
    t_map.mouse_y = mouse_y
    load_map_byid(t_map)
    return true
  end
  local function fun_map_up()
    local view_up_stack = function()
      if g_map_level.c_stack == nil or g_map_level.c_stack.pre == nil then
        return false
      end
      local pre = g_map_level.c_stack.pre
      pre.stack_op = 0
      load_map_byid(g_map_level.c_stack.pre)
      g_map_level.c_stack = pre
      return true
    end
    local count = #g_map_level.stack
    if count > 0 and view_up_stack() == true then
      return
    end
    if is_map_top_level() then
      return
    end
    load_up_level_map()
  end
  local function fun_map_down()
    if is_map_top_level() ~= true and load_down_level_map() == true then
      return
    else
    end
    local view_down_stack = function()
      if g_map_level.c_stack == nil or g_map_level.c_stack.next == nil then
        return false
      end
      for i, v in pairs(g_map_level.c_stack.next) do
        local next = v
        v.stack_op = 1
        load_map_byid(v)
        g_map_level.c_stack = v
        return true
      end
    end
    local count = #g_map_level.stack
    if count > 0 and view_down_stack() == true then
      return
    end
  end
  if map_up == true then
    fun_map_up()
  elseif map_down == true then
    fun_map_down()
  elseif is_may_show_level(c_level_detail) == true then
    fun_map_down()
  end
  block_mouse()
end
function check_mark_visible(visible_conds)
  for i = 3, visible_conds.size - 1, 4 do
    local rst = ui.quest_check_qobj_value(visible_conds[i - 3], visible_conds[i - 2], visible_conds[i - 1], visible_conds[i])
    if rst ~= 0 then
      return false
    end
  end
  return true
end
function on_init_dynamic_pos_data()
  g_dynamic_pos_data = {}
  local scn = bo2.scn
  if sys.check(scn) ~= true or scn.excel.inc_foot_trace.size <= 0 then
    g_dynamic_pos_data.disable = 1
  else
    g_dynamic_pos_data.disable = 2
  end
  g_dynamic_pos_data.stamp = 0
  g_dynamic_pos_data.scn_id = scn.excel.id
  foot_trace_data = {}
end
function is_dynamic_pos_data_vaild()
  if g_dynamic_pos_data == nil or g_dynamic_pos_data.disable == nil or g_dynamic_pos_data.disable == 1 or g_dynamic_pos_data.scn_id ~= cur_scn_id then
    return false
  end
  return true
end
function on_vis_send_dynamic_pos_data(vis)
  if is_dynamic_pos_data_vaild() ~= true then
    return
  end
  local v = sys.variant()
  v:set(packet.key.cmn_type, vis)
  if vis then
    v:set(packet.key.cmn_index, g_dynamic_pos_data.stamp)
  end
  bo2.send_variant(packet.eCTS_UI_MapFootTraceData, v)
end
function load_world_map()
  local t_map = {}
  t_map.id = top_world_mapid
  t_map.scn_id = cur_scn_id
  t_map.level = c_level_top
  load_map_byid(t_map)
end
function load_scn(scn_id, op)
  local scn_excel = bo2.gv_scn_list:find(scn_id)
  if sys.check(scn_excel) ~= true then
    return
  end
  cur_scn_id = scn_id
  cb_init()
  local i, j
  local id = scn_excel.map_id
  change_map({
    id = id,
    scn = scn_id,
    op = op
  })
  return true
end
function getIntPart(x)
  local x = x / 256
  if x <= 0 then
    return math.ceil(x)
  end
  if math.ceil(x) == x then
    x = math.ceil(x)
  else
    x = math.ceil(x) - 1
  end
  return x
end
function load_detail_map(map_scnId, d_x, d_y)
  local index_x, index_y
  index_x = getIntPart(d_x)
  index_y = getIntPart(d_y)
  if g_map_level.cur_index_x ~= nil and g_map_level.cur_index_x == index_x and g_map_level.cur_index_y == index_y then
    return true
  end
  g_map_level.cur_index_x = index_x
  g_map_level.cur_index_y = index_y
  local map_cnt = 0
  for i = -1, 1 do
    for j = -1, 1 do
      local image_title = sys.format(L("$res/scn/%s/preview/p_%d_%d"), map_scnId.load_path, index_x + i, index_y - j)
      local image_path = image_title .. ".dds"
      local is_file = sys.is_file(image_path)
      if not is_file then
        image_path = image_title .. ".png"
        is_file = sys.is_file(image_path)
      end
      if is_file then
        w_backcloth_deatail:set_item(i + 1, j + 1, image_path)
        map_cnt = map_cnt + 1
      else
        w_backcloth_deatail:set_item(i + 1, j + 1, "$image/widget/fig/256x256/bg4.png")
        return false
      end
    end
  end
  return true
end
function push_map_stack(t_map)
  local c_count = 1
  for i, v in pairs(g_map_level.stack) do
    local id = v.id
    if id == t_map.id then
      g_map_level.c_stack = v
      return
    end
    c_count = c_count + 1
  end
  if g_map_level.c_map == nil then
    return
  end
  local count = #g_map_level.stack
  if count <= 0 then
    table.insert(g_map_level.stack, g_map_level.c_map)
    g_map_level.c_map.pre = nil
  end
  if g_map_level.c_map.next == nil then
    g_map_level.c_map.next = {}
    table.insert(g_map_level.c_map.next, t_map)
  end
  table.insert(g_map_level.stack, t_map)
  t_map.pre = g_map_level.c_map
  t_map.next = nil
  g_map_level.c_stack = t_map
end
function load_map_byid(t_map)
  local id = t_map.id
  local scn_id = t_map.scn_id
  local level = t_map.level
  local d_x = t_map.d_x
  local d_y = t_map.d_y
  if level ~= nil then
    set_map_level(level)
  end
  local mb_map_list = bo2.gv_map_list:find(id)
  if mb_map_list == nil then
    mb_map_list = bo2.gv_map_list:find(default_mapid)
  end
  if id == top_world_mapid then
    w_btn_chgmap.text = ui.get_text("map|current_map")
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_Guild_GetWorldScnList, v)
    clear_map_stack()
  else
    if t_map.stack_op == nil then
      clear_map_stack()
    elseif t_map.stack_op == 0 then
    elseif t_map.stack_op == 1 then
    elseif t_map.stack_op == 2 then
      push_map_stack(t_map)
    end
    w_btn_chgmap.text = ui.get_text("map|world_map")
  end
  g_map_level.c_map = t_map
  global_map = true
  g_map_level.cur_map_id = id
  local map_scnId = bo2.gv_scn_list:find(mb_map_list.scn_id)
  if map_scnId == nil then
    g_patch = bo2.get_patch()
  else
    g_patch = map_scnId.map_size
  end
  if d_x ~= nil and d_y ~= nil and load_detail_map(map_scnId, d_x, d_y) then
    w_backcloth.visible = false
    w_backcloth_deatail.visible = true
  else
    if is_current_level(c_level_detail) then
      set_map_level(c_level_scn)
    end
    map_x1 = mb_map_list.x1
    map_x2 = mb_map_list.x2
    map_y1 = mb_map_list.y1
    map_y2 = mb_map_list.y2
    scale_x = 800 / (map_x2 - map_x1)
    scale_y = 600 / (map_y2 - map_y1)
    local base_path = maps_uri
    local num = 0
    for i = 0, 2 do
      for j = 0, 3 do
        w_backcloth:set_item(j, i, base_path .. mb_map_list.path .. "/" .. mb_map_list.path .. "_" .. num .. ".png")
        num = num + 1
      end
    end
    w_backcloth.visible = true
    w_backcloth_deatail.visible = false
  end
  redraw_dots()
  load_marks(id)
  update_player(object)
  w_member:control_clear()
  on_make_tip = make_tip_factory(w_member)
  member_list = {}
  update_member_map()
  load_foot_trace(id)
  g_wheel = 0
  ui_widget.ui_combo_box.select(w_cb_map_scnce, mb_map_list.scn_id)
  reload_area(mb_map_list.scn_id)
end
function set_highlight(ctrl)
  if ctrl == last_highlight_ctrl then
    return
  end
  function set_highlight_in(ctrl, flag)
    if ctrl == nil then
      return
    end
    local highlight = ctrl:search("highlight")
    if highlight then
      highlight.visible = flag
    end
  end
  set_highlight_in(ctrl, true)
  if sys.check(last_highlight_ctrl) then
    set_highlight_in(last_highlight_ctrl, false)
  end
  last_highlight_ctrl = ctrl
end
function clear_all_marks()
  clear_mark_tree()
  w_misc:control_clear()
  w_back_desc:control_clear()
end
function is_xy_in_detail_map(x, y)
  local scale = g_map_level.detail_scale
  local cur_index_x = g_map_level.cur_index_x
  local cur_index_y = g_map_level.cur_index_y
  local min_x = scale * (cur_index_x - 2) * 256
  local max_x = scale * (cur_index_x + 2) * 256
  local min_y = scale * (cur_index_y - 2) * 256
  local max_y = scale * (cur_index_y + 2) * 256
  if x >= min_x and x <= max_x and y >= min_y and y <= max_y then
    return true
  end
  return false
end
function load_marks(id)
  local function set_misc(x, y, type, content, id)
    if type > 0 and type < 100 then
      local offset
      if is_current_level(c_level_detail) then
        local x = math.floor(x)
        local y = math.floor(y)
        if is_xy_in_detail_map(x, y) ~= true then
          return false
        end
      else
      end
      offset = get_mouse_to_map_pos(x, y, 8, 8)
      local item = ui.create_control(w_misc, "panel")
      item:load_style("$frame/map/map.xml", "misc")
      item.offset = offset
      item.svar = {
        x = x,
        y = y,
        id = id,
        type = type
      }
      local scn_id = get_deliver_map(item.svar)
      item.svar.scn_id = scn_id
      if c_mark_deliver ~= type or scn_id == 0 then
        item:search("w_misc").tip.text = content
      else
        local stk = sys.mtf_stack()
        ui_tool.ctip_push_text(stk, content, nil, ui_tool.cs_tip_a_add_m)
        ui_tool.ctip_push_operation(stk, ui.get_text("map|mlclick_open"))
        item:search("w_misc").tip.text = stk.text
      end
      local type_excel = bo2.gv_mark_type:find(type)
      local uri
      if type_excel then
        uri = type_excel.icon
        item:search("w_misc").image = mark_icon_uri .. uri
      end
    elseif type > 100 and type < 1000 then
      local offset
      local type_excel = bo2.gv_mark_type:find(type)
      if type_excel == nil then
        return
      end
      local off_x = 0
      local off_y = 0
      local off_x_size = 0
      local off_y_size = 0
      off_x_size = type_excel.size / 2
      if type_excel.icon.empty == false then
        off_y_size = type_excel.size / 2
      else
        off_y_size = type_excel.font_size / 2
      end
      if is_current_level(c_level_detail) then
        local x = math.floor(x)
        local y = math.floor(y)
        if is_xy_in_detail_map(x, y) ~= true then
          return false
        end
      end
      local off = get_mouse_to_map_pos(x, y, 0, 0)
      off_x = off.x
      off_y = off.y
      offset = ui.point(off_x - type_excel.size, off_y - off_y_size)
      local mark_excel = bo2.gv_mark_list:find(id)
      local uri
      local item = ui.create_control(w_back_desc, "panel")
      item:load_style("$frame/map/map.xml", "back_desc")
      local text_width = 14
      if 0 < type_excel.size then
        text_width = type_excel.size
      end
      item:search("w_misc").size = ui.point(type_excel.size, type_excel.size)
      local text = content
      if mark_excel.text.empty == false then
        text = mark_excel.text
      end
      local bdt = item:search("back_desc_text")
      bdt.mtf = text
      if type_excel.font_size == 0 then
        bdt.visible = false
      else
        local font_size = 14
        if 0 < type_excel.font_size then
          font_size = type_excel.font_size
        end
        local ext = bdt.extent
        if text_width < ext.x then
          text_width = ext.x
        end
        if font_size < ext.y then
          font_size = ext.y
        end
        local parent = bdt.parent
        if text_width > parent.dx then
          parent.dx = text_width
        end
        bdt.size = ui.point(text_width, font_size)
        local m1, m2, m3, m4 = type_excel.align[0], type_excel.align[1], type_excel.align[2], type_excel.align[3]
        bdt.margin = ui.rect(m1, m2, m3, m4)
      end
      if type_excel.icon.empty == false then
        uri = type_excel.icon
        item:search("w_misc").image = mark_icon_uri .. uri
        item:search("w_misc").visible = true
        item:search("w_misc").tip.text = text
        item.size = ui.point(type_excel.size, type_excel.size)
        item.offset = offset
      else
        item:search("w_misc").visible = false
        item.size = ui.point(text_width, type_excel.font_size)
        item.offset = offset
      end
      item.svar = {
        x = x,
        y = y,
        id = id,
        type = type
      }
    end
  end
  local insert_mark_type = function(id)
    local mark_excel = bo2.gv_mark_type:find(id)
    local node_panel = insert_tree_node(mark_excel.name)
    return node_panel
  end
  clear_all_marks()
  local size = map_detail_table.size
  for i = 0, size - 1 do
    local line = map_detail_table:get(i)
    if line ~= nil and line.map_id ~= 0 and line.belong_id == id then
      style_name = "map_detail_notips"
      local map_mb = bo2.gv_map_list:find(line.map_id)
      if map_mb then
        local scn_mb = bo2.gv_scn_list:find(map_mb.scn_id)
        if scn_mb and scn_mb.guildworld ~= 0 then
          style_name = "map_detail"
        end
      end
      local item = ui.create_control(w_misc, "panel")
      item:load_style("$frame/map/map.xml", style_name)
      item.size = ui.point(line.image_size[0] * scale_x, line.image_size[1] * scale_y)
      item.offset = ui.point(line.map_offset[0], line.map_offset[1])
      local image_rect = ui.rect(line.image_offset[0], line.image_offset[1], line.image_size[0], line.image_size[1])
      item:search("map_detail").image = line.image .. "|" .. tostring(image_rect)
      item:search("bg_fold").image = line.image .. "|" .. tostring(image_rect)
      item.svar = line.map_id
    end
  end
  local map_excel = bo2.gv_map_list:find(id)
  if map_excel == nil then
    return
  end
  local m_quest_list = bo2.gv_quest_list
  local f_quest_get = bo2.gv_quest_list.get
  local m_mark_list = bo2.gv_mark_list
  local f_mark_find = bo2.gv_mark_list.find
  local f_mark_get = bo2.gv_mark_list.get
  for i = 0, m_quest_list.size - 1 do
    local excel = f_quest_get(m_quest_list, i)
    local info = ui.quest_find(excel.id)
    if info ~= nil and info.completed then
      local excel2 = bo2.gv_mark_list:find(excel.end_obj_mark)
      if excel2 ~= nil and excel2.scn_id == map_excel.scn_id then
        local point = bo2.map_mark_nametopoint(map_excel.scn_id, f_mark_find(m_mark_list, excel.end_obj_mark).enter_point)
        if point.x ~= -1 then
          set_misc(point.x, point.y, 16, f_mark_find(m_mark_list, excel.end_obj_mark).name, excel.end_obj_mark)
        end
      end
    end
  end
  local mb_map_list = bo2.gv_map_list:find(id)
  for i = 0, m_mark_list.size - 1 do
    local mark_excel = f_mark_get(m_mark_list, i)
    if mark_excel and mark_excel.mark_type ~= 0 and check_mark_visible(mark_excel.visible_conds) then
      for j = 0, mark_excel.map_id.size - 1 do
        if mark_excel.map_id[j] == id then
          if 0 < mark_excel.right then
            local name
            if mark_excel.data ~= L("") then
              name = sys.format("%s(%s)", mark_excel.name, mark_excel.data)
            else
              name = mark_excel.name
            end
            local node_panel = insert_mark_type(mark_excel.mark_type)
            local child_node = insert_child_item(node_panel, name)
            local node = child_node:search("node").var
            node:set("id", bo2.gv_mark_list:get(i).id)
            child_node.svar = mark_excel.right
          end
          if mark_excel.bigmap == 1 then
            local point = bo2.map_mark_nametopoint(mark_excel.scn_id, bo2.gv_mark_list:get(i).enter_point)
            if point.x ~= -1 then
              set_misc(point.x, point.y, bo2.gv_mark_list:get(i).mark_type, bo2.gv_mark_list:get(i).name, bo2.gv_mark_list:get(i).id)
            end
          end
        end
      end
    end
  end
  local func_Npc_item
  local mark_excel = bo2.gv_mark_type:find(1)
  for i, v in ipairs(marks_type) do
    if v.name == mark_excel.name then
      func_Npc_item = v.item
    end
  end
  if func_Npc_item then
    local priority_sort = function(item1, item2)
      local var1 = item1.svar
      local var2 = item2.svar
      if var1 > var2 then
        return -1
      elseif var1 == var2 then
        return 0
      else
        return 1
      end
    end
    func_Npc_item:item_sort(priority_sort)
  end
end
function make_tip_factory(mapPanel)
  return function(tip)
    local h
    if sys.check(mapPanel) ~= nil then
      h = mapPanel.control_head
    end
    local text
    while h ~= nil do
      local pos = ui.point(ui.get_cursor_pos().x - h.abs_area.x1, ui.get_cursor_pos().y - h.abs_area.y1)
      if pos.x >= 0 and pos.x <= 16 and pos.y >= 0 and pos.y <= 16 then
        if text then
          text = sys.format([[
%s	
%s]], text, h:search("w_misc").tip.text)
        else
          text = h:search("w_misc").tip.text
        end
      end
      h = h.next
    end
    ui_widget.tip_make_view(tip.view, text)
  end
end
function isOneTeam(only_id)
  local cnt = -1
  local tar_cnt = -1
  for i = 0, 19 do
    local info = ui.member_get_by_idx(i)
    if info.only_id == bo2.player.only_id then
      cnt = i
    end
    if info.only_id == only_id then
      tar_cnt = i
    end
    if cnt ~= -1 and tar_cnt ~= -1 then
      break
    end
  end
  if math.abs(tar_cnt - cnt) < 5 then
    return true
  else
    return false
  end
end
function update_member_map(only_id)
  local set_member_mise = function(info)
    if info.only_id == sys.wstring(0) then
      return
    end
    if info.only_id == bo2.player.only_id then
      return
    end
    if info.status == 0 then
      return
    end
    if info.gzs_id ~= bo2.player:get_flag_objmem(bo2.eFlagObjMemory_GZSId) then
      return
    end
    local area_excel = bo2.gv_area_list:find(info.area_id)
    if area_excel == nil then
      return
    end
    local map_id1, map_id2
    local scn_excel = bo2.gv_scn_list:find(area_excel.in_scn)
    if scn_excel then
      map_id1 = scn_excel.map_id
    end
    local prov_excel = bo2.gv_prov_list:find(area_excel.in_prov)
    if prov_excel then
      map_id2 = prov_excel.map_id
    end
    if map_id1 == g_map_level.cur_map_id or map_id2 == g_map_level.cur_map_id then
      if member_list[info.only_id] and sys.check(member_list[info.only_id].item) then
        local item = member_list[info.only_id].item
        item.offset = ui.point(scale_x * (info.pos_x - map_x1) - 8, scale_y * (g_patch - info.pos_z - map_y1) - 8)
        item.svar = {
          x = info.pos_x,
          y = info.pos_z
        }
      else
        local style = "member"
        if isOneTeam(info.only_id) then
          style = "team"
        end
        local item = ui.create_control(w_member, "panel")
        item:load_style("$frame/map/map.xml", style)
        item.offset = ui.point(scale_x * (info.pos_x - map_x1) - 8, scale_y * (g_patch - info.pos_z - map_y1) - 8)
        item:search("w_misc").tip.text = info.name
        item.svar = {
          x = info.pos_x,
          y = info.pos_z
        }
        member_list[info.only_id] = {item = item}
      end
    elseif scn_excel.in_scn_id == cur_scn_id then
      local excel = bo2.gv_scn_list:find(cur_scn_id)
      if excel.map_id ~= g_map_level.cur_map_id then
        return
      end
      local point = bo2.markrandpoint(scn_excel.in_scn_point)
      if point then
        if member_list[info.only_id] and sys.check(member_list[info.only_id].item) then
          local item = member_list[info.only_id].item
          item.offset = ui.point(scale_x * (point.x - map_x1) - 8, scale_y * (g_patch - point.y - map_y1) - 8)
          item.svar = {
            x = point.x,
            y = point.y
          }
        else
          local style = "member"
          if isOneTeam(info.only_id) then
            style = "team"
          end
          local item = ui.create_control(w_member, "panel")
          item:load_style("$frame/map/map.xml", style)
          item.offset = ui.point(scale_x * (point.x - map_x1) - 8, scale_y * (g_patch - point.y - map_y1) - 8)
          item:search("w_misc").tip.text = info.name .. "(" .. scn_excel.name .. ")"
          item.svar = {
            x = point.x,
            y = point.y
          }
          member_list[info.only_id] = {item = item}
        end
      end
    elseif member_list[info.only_id] and sys.check(member_list[info.only_id].item) then
      member_list[info.only_id].item:post_release()
      member_list[info.only_id] = nil
    end
  end
  ui_minimap.update_member_minimap(only_id)
  if only_id then
    for i = 0, 19 do
      local info = ui.member_get_by_idx(i)
      if only_id == info.only_id then
        set_member_mise(info)
        return
      end
    end
  end
  w_member:control_clear()
  for i = 0, 19 do
    local info = ui.member_get_by_idx(i)
    set_member_mise(info)
  end
end
function update_temp_point_map(data)
  local set_member_mise = function(info)
    local item = ui.create_control(w_temp_point, "panel")
    item:load_style("$frame/map/map.xml", "member")
    item.offset = ui.point(scale_x * (info.pos_x - map_x1) - 8, scale_y * (g_patch - info.pos_z - map_y1) - 8)
    item:search("w_misc").tip.text = info.name
    item.svar = {
      x = info.pos_x,
      y = info.pos_z
    }
  end
  w_temp_point:control_clear()
  for i, v in pairs(data) do
    set_member_mise(v)
  end
end
function clear_path_data(is_break)
  path = {}
  if is_break == nil and g_m_id ~= g_real_mark then
    return
  end
  clear_store()
end
function on_self_enter(obj)
  if obj == bo2.player then
    update_player(obj)
    update_path()
  end
  if g_real_mark ~= nil and g_real_mark ~= 0 then
    ui_map.find_path_byid(g_real_mark)
    g_real_mark = 0
  end
end
function on_create_finish()
  on_init_dynamic_pos_data()
  if #path < 1 then
    return
  end
  find_path_n(last_scn_id, last_markname, last_dis)
  table.remove(table, 1)
end
function on_path_break(obj)
  if obj == bo2.player then
    clear_path_data(1)
  end
end
function on_path_end(obj)
  if obj == bo2.player then
    local _notify = g_m_id == 0 or g_real_mark == 0 or g_m_id == g_real_mark
    if last_scn_id == cur_scn_id then
      ui.log("last_dis %s", last_dis)
      if last_dis == 1 and last_markname ~= nil then
        ui_quest.send_talk_alias(last_markname)
      end
      clear_path_data()
    end
    if not bo2.player.bIshOpen and (not sys.check(last_scn_id) or last_scn_id == cur_scn_id) and _notify then
      ui_widget.ui_wnd.show_notice({
        text = ui.get_text("map|path_arrive"),
        timeout = 30,
        sound = "$sound/gps_finish.wav"
      })
    end
  end
end
function on_path_close(obj)
  if obj == bo2.player then
    ui_quest.send_talk_alias(last_markname)
  end
end
function on_path_unreached(obj)
  if obj == bo2.player then
    ui_tool.note_insert(ui.get_text("map|err_bad_location"), "00ff00")
    clear_path_data(1)
  end
end
function on_path_cantmove(obj)
  if obj == bo2.player then
    ui_tool.note_insert(ui.get_text("map|err_cant_move"), "00ff00")
  end
end
function set_map_op_visible(vis)
  if vis ~= true then
    w_coordinate_display2.visible = false
  elseif is_map_top_level() ~= true then
    w_coordinate_display2.visible = true
  else
    w_coordinate_display2.visible = false
  end
end
function update_player()
  local set_position = function(x, y)
    if is_current_level(c_level_detail) then
      local x = math.floor(x)
      local y = math.floor(y)
      if is_xy_in_detail_map(x, y) ~= true then
        w_player.visible = false
        return false
      end
    end
    w_player.offset = get_mouse_to_map_pos(x, y, 32, 32)
    w_player.visible = true
  end
  local excel = bo2.gv_map_list:find(g_map_level.cur_map_id)
  if excel == nil then
    w_player.visible = false
    w_coordinate_display.visible = false
    set_map_op_visible(true)
    return
  end
  local obj = bo2.player
  local x, y = obj:get_position()
  if excel.scn_id ~= cur_scn_id then
    do break end
    do
      local point = bo2.markrandpoint(bo2.gv_scn_list:find(cur_scn_id).in_scn_point)
      x = point.x
      y = point.y
    end
    do break end
    w_player.visible = false
    w_coordinate_display.visible = false
    set_map_op_visible(true)
    return
  end
  local angle = obj.angle
  w_coordinate_display.visible = true
  w_player_coordinate.text = ui_widget.merge_mtf({
    loc_x = math.floor(x),
    loc_y = math.floor(y)
  }, ui.get_text("map|current_location"))
  set_position(x, y)
  w_arrow:angle(angle * 180 / math.pi - 180)
  w_arrow.tip.text = obj.name
  set_map_op_visible(false)
end
function rp()
  find_path(1845, 1867)
end
function find_path(x, y)
  last_markname = nil
  local v = bo2.findpath_k(cur_scn_id, x, y)
  bo2.showpath_k()
  bo2.bo2.startmove_k()
  path_data = {}
  for i = 0, v.size - 1, 2 do
    table.insert(path_data, {
      x = v:get(i).v_int,
      y = v:get(i + 1).v_int
    })
  end
  if #path_data > 0 then
    ui_minimap.set_path_npc(nil, math.floor(x), math.floor(y))
  end
  redraw_dots()
end
function find_path_n(id, name, dis)
  for k, v in pairs(links) do
    links[k].visited = false
  end
  path = {}
  tmp_path = {}
  findlink(name2node(links, cur_scn_id), name2node(links, id))
  if #tmp_path == 0 then
    ui_tool.note_insert(ui.get_text("map|err_cant_moveto_scn"), "ff0000")
    return
  end
  local length = 0
  local shortest = 0
  local index = 0
  for i, v in ipairs(tmp_path) do
    length = #v
    if shortest == 0 then
      shortest = length
      index = i
    elseif length < shortest then
      shortest = length
      index = i
    end
  end
  path = {}
  for i, v in ipairs(tmp_path[index]) do
    table.insert(path, tmp_path[index][i])
  end
  if path == nil then
    ui_tool.note_insert(ui.get_text("map|err_cant_moveto_scn"), "ff0000")
    return
  end
  local v
  if path == nil or #path == 1 then
    last_markname = name
    last_dis = dis
    last_scn_id = id
    find_path_r(id, name, dis)
  else
    last_markname = name
    last_dis = dis
    last_scn_id = id
    find_path_r(path[1].name, path[1].adj[name2node(links, path[2].name)], dis)
    table.remove(path, 1)
  end
end
function find_path_r(id, name, dis)
  if dis == 1 then
    dis = true
  elseif dis == 0 then
    dis = false
  end
  v = bo2.findpath_n(id, name, dis)
  bo2.showpath_k()
  bo2.bo2.startmove_k()
  ui_dots_clear(w_drawdots)
  path_data = {}
  for i = 0, v.size - 1, 2 do
    table.insert(path_data, {
      x = v:get(i).v_int,
      y = v:get(i + 1).v_int
    })
  end
  redraw_dots()
  ui_minimap.set_find_path()
end
function redraw_dots()
  w_drawdot_des:control_clear()
  ui_dots_clear(w_drawdots)
  local excel = bo2.gv_map_list:find(g_map_level.cur_map_id)
  if excel == nil then
    return
  end
  if excel.scn_id ~= cur_scn_id then
    return
  end
  local count = 0
  for i, v in ipairs(path_data) do
    do
      local x = v.x
      local y = v.y
      count = count + 1
      local function draw_dot()
        if is_current_level(c_level_detail) and is_xy_in_detail_map(x, y) ~= true then
          return false
        end
        local draw_off = get_mouse_to_map_pos(x, y, 0, 0)
        ui_set_dot(w_drawdots, draw_off.x, draw_off.y, 2)
      end
      draw_dot()
    end
  end
  local size_path = #path_data
  if size_path > 0 then
    local x = path_data[size_path].x
    local y = path_data[size_path].y
    if is_current_level(c_level_detail) and is_xy_in_detail_map(x, y) ~= true then
      return false
    end
    local item = ui.create_control(w_drawdot_des, "panel")
    item:load_style("$frame/map/map.xml", "destination")
    item.offset = get_mouse_to_map_pos(x, y, 8, 20)
  end
end
local mouse_l_down = false
function map_on_mouse(panel, msg, pos, wheel)
  local mouse_x = 0
  local mouse_y = 0
  if msg == ui.mouse_lbutton_down then
    mouse_l_down = true
  elseif msg == ui.mouse_lbutton_up then
    mouse_l_down = false
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_move or msg == ui.mouse_wheel then
    if is_current_level(c_level_detail) then
      local cur_index_x = g_map_level.cur_index_x
      local cur_index_y = g_map_level.cur_index_y
      local scale = g_map_level.detail_scale
      mouse_x = (pos.x - map_dx) / scale + (cur_index_x - 1) * 256
      mouse_y = map_dy - pos.y / scale + (cur_index_y - 1) * 256
    else
      mouse_x = pos.x / scale_x + map_x1
      mouse_y = g_patch - map_y1 - pos.y / scale_y
    end
  end
  if msg == ui.mouse_lbutton_click then
    local excel = bo2.gv_map_list:find(g_map_level.cur_map_id)
    if excel == nil or excel.scn_id ~= cur_scn_id then
      return
    end
    if is_map_block() ~= true then
      find_path(mouse_x, mouse_y)
    end
  end
  if msg == ui.mouse_move then
    do
      local t_mouse_x = math.floor(mouse_x)
      local t_mouse_y = math.floor(mouse_y)
      local stk = sys.mtf_stack()
      stk:raw_push(ui_widget.merge_mtf({loc_x = t_mouse_x, loc_y = t_mouse_y}, ui.get_text("map|mouse_location")))
      local area = 0
      local function get_area_name()
        if sys.check(bo2.scn) ~= true then
          return nil
        end
        local scn_id = bo2.scn.excel.id
        local area = bo2.map_mark_point_area(scn_id, t_mouse_x, t_mouse_y)
        if area == 0 then
          return nil
        end
        local area_excel = bo2.gv_area_list:find(area)
        if area_excel == nil then
          return nil
        end
        return area_excel.display_name
      end
      local area_name = get_area_name()
      if area_name ~= nil then
        stk:raw_push(ui_widget.merge_mtf({area_name = area_name}, ui.get_text("map|mouse_area")))
      end
      w_coordinate.text = stk.text
    end
  end
  if msg == ui.mouse_rbutton_click and is_map_block() ~= true then
    map_level_op(mouse_x, mouse_y, msg)
  end
  if wheel == 0 or is_map_block() then
    g_wheel = 0
    return
  end
  g_wheel = g_wheel + wheel
  map_level_op(mouse_x, mouse_y, msg)
end
function on_world_scnlist_tip(tip)
  local item = tip.owner
  local scn_id = item.parent.svar
  local scn_m = bo2.gv_scn_list:find(scn_id)
  if world_scnlist[scn_id] and scn_m then
    local stk = sys.mtf_stack()
    local camp_name = ui.get_text("guild|null")
    if world_scnlist[scn_id].camp_id == 2 then
      camp_name = ui.get_text("phase|camp_blade")
    elseif world_scnlist[scn_id].camp_id == 3 then
      camp_name = ui.get_text("phase|camp_sword")
    end
    ui_tool.ctip_push_text(stk, ui.get_text("map|scn_area") .. scn_m.name)
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("map|scn_type"))
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("map|scn_guild") .. world_scnlist[scn_id].guild_name)
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("map|scn_leader") .. world_scnlist[scn_id].leader_name)
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("map|scn_camp") .. camp_name)
    ui_widget.tip_make_view(tip.view, stk.text)
  end
end
function on_world_scnlist(cmd, data)
  world_scnlist = {}
  for i = 0, data.size - 1 do
    local v = data:get(i)
    local id = v:get(packet.key.scn_excel_id).v_int
    local guild_name = ui.get_text("map|scn_no")
    local camp_id = 0
    local leader_name = ui.get_text("guild|null")
    if v:has(packet.key.guild_name) then
      guild_name = v:get(packet.key.guild_name).v_string
      camp_id = v:get(packet.key.camp_id).v_int
      leader_name = v:get(packet.key.cha_name).v_string
    end
    world_scnlist[id] = {}
    world_scnlist[id].guild_name = guild_name
    world_scnlist[id].camp_id = camp_id
    world_scnlist[id].leader_name = leader_name
  end
end
function on_mark_mouse(panel, msg, pos)
  if msg == ui.mouse_lbutton_click then
    local node = panel:search("node").var
    local id = node:get("id").v_int
    if id ~= nil then
      find_path_byid(id)
      ui_minimap.set_path_npc(id)
    end
    set_highlight(panel:search("highlight"))
  end
end
function find_path_byid(markid)
  local excel = bo2.gv_mark_list:find(markid)
  if excel == nil then
    ui.log("find_path_byid excel is nil %s", markid)
    return
  end
  if bo2.markrandpoint(excel.enter_point) == nil then
    ui.log("enter_point is nil")
    return
  end
  ui_minimap.set_path_npc(markid)
  find_path_n(excel.scn_id, excel.enter_point, excel.distance, excel.id)
  g_m_id = markid
end
function set_find_path(x1, y1, x2, y2)
  path_data.x1 = x1
  path_data.y1 = y1
  path_data.x2 = x2
  path_data.y2 = y2
end
function update_map(obj)
  if obj == bo2.player then
    local id = obj:get_atb(bo2.eAtb_AreaID)
    local area_excel = bo2.gv_area_list:find(id)
    if area_excel == nil then
      return
    end
    if area_excel.display_name.empty == false then
      ui_minimap.ui_minimap.w_current_scn.text = area_excel.display_name
      local is_disp_area = area_excel.show_area_on_scr
      if is_disp_area ~= 0 and is_disp_area ~= nil then
        ui_tool.note_insert(area_excel.display_name, "ffffff", nil, true)
      end
    else
      local scn_name = bo2.gv_scn_list:find(cur_scn_id).name
      ui_minimap.ui_minimap.w_current_scn.text = scn_name
    end
    ui_handson_teach.test_complate_move(area_excel.id)
    if area_excel then
      local prov_excel = bo2.gv_prov_list:find(area_excel.in_prov)
      if prov_excel then
        if prov_excel.map_id == 0 then
          ui_widget.ui_combo_box.select(w_cb_map_scnce, cur_scn_id)
          local map_id = bo2.gv_scn_list:find(cur_scn_id).map_id
          change_map({id = map_id, scn = cur_scn_id})
          reload_area(cur_scn_id)
          ui_widget.ui_combo_box.select(w_cb_map_area, g_map_level.cur_map_id)
          update_player(object)
          ui_minimap.update_find_npc(g_map_level.cur_map_id)
        else
          ui_widget.ui_combo_box.select(w_cb_map_scnce, cur_scn_id)
          change_map({
            id = prov_excel.map_id,
            scn = cur_scn_id
          })
          reload_area(cur_scn_id)
          ui_widget.ui_combo_box.select(w_cb_map_area, g_map_level.cur_map_id)
          redraw_dots()
          update_player(object)
          ui_minimap.update_find_npc(g_map_level.cur_map_id)
        end
      else
        ui_widget.ui_combo_box.select(w_cb_map_scnce, cur_scn_id)
        change_map({
          id = bo2.gv_scn_list:find(cur_scn_id).map_id,
          scn = cur_scn_id
        })
        reload_area(cur_scn_id)
        ui_widget.ui_combo_box.select(w_cb_map_area, g_map_level.cur_map_id)
        redraw_dots()
        update_player(object)
        ui_minimap.update_find_npc(g_map_level.cur_map_id)
      end
    else
      change_map({
        id = bo2.gv_scn_list:find(cur_scn_id).map_id,
        scn = cur_scn_id
      })
      update_player(object)
    end
  end
end
function handleShowPath(cmd, data)
  local id = data:get(packet.key.cmn_id).v_int
  local name = data:get(packet.key.cmn_name).v_string
  bo2.findpath_n(id, name, 2)
  bo2.showpath_k()
end
local function set_foottrace(x, y, type, npc_id, name, trace_type, c_color)
  local item = ui.create_control(w_foottrace, "panel")
  item:load_style("$frame/map/map.xml", "foot_trace")
  item.offset = ui.point(scale_x * (x - map_x1) - 8, scale_y * (g_patch - y - map_y1) - 8)
  local tip = item:search("w_foot_trace").tip
  local cha_excel = bo2.gv_cha_list:find(npc_id)
  if cha_excel ~= nil then
    tip.text = cha_excel.name
  end
  if sys.check(name) then
    tip.text = name
  end
  local type_excel = bo2.gv_mark_type:find(type)
  local uri
  if type_excel then
    if trace_type == 2 then
      local pic = item:search("w_foot_trace")
      pic.image = sys.format(L("$image/qbar/btn_cross_line.png|8,21,17,20"))
      pic.dx = 17
      pic.dy = 20
    else
      local pic = item:search("w_foot_trace")
      uri = type_excel.icon
      pic.image = mark_icon_uri .. uri
      if c_color ~= nil then
        pic.color = ui.make_color(c_color)
      end
    end
  end
  item.svar = {x = x, y = y}
end
function load_foot_trace(map_id)
  w_foottrace:control_clear()
  map_id = map_id or g_map_level.cur_map_id
  local map_excel = bo2.gv_map_list:find(map_id)
  if map_excel == nil then
    return
  end
  if map_excel.scn_id ~= cur_scn_id then
    return
  end
  for k, v in pairs(foot_trace_data) do
    local foot_excel = bo2.gv_foot_trace:find(v.id)
    if foot_excel ~= nil and cur_scn_id == foot_excel.scn_id then
      set_foottrace(v.x, v.y, foot_excel.mark_type, foot_excel.npc_id, v.name, foot_excel.trace_type, v.color)
    end
  end
end
local set_title_text = function(camp_excel, c_camp)
  local text, title_excel = ui_camp_repute.get_title_text(camp_excel, c_camp)
  if title_excel.targets.size > 0 then
    local c_excel_id = title_excel.targets[0]
    local lootlevel = bo2.gv_lootlevel:find(c_excel_id)
    if lootlevel ~= nil then
      c_color = sys.format(L("%x"), lootlevel.color)
    end
    return sys.format(L("<c+:%s>%s<c->"), c_color, text), c_color
  end
  return text, nil
end
function on_map_foot_data(cmd, data)
  if is_dynamic_pos_data_vaild() ~= true then
    return
  end
  local stamp = data:get(packet.key.cmn_index).v_int
  g_dynamic_pos_data.stamp = stamp
  local v_data = data:get(packet.key.cmn_dataobj)
  local size_vData = v_data.size
  foot_trace_data = {}
  for i = 0, size_vData - 1 do
    do
      local detail_index, v_detail_data = v_data:fetch_nv(i)
      local dx = v_detail_data:get(packet.key.cha_pos_x).v_int
      local dy = v_detail_data:get(packet.key.cha_pos_z).v_int
      local id = v_detail_data:get(packet.key.scnobj_excel_id).v_int
      local _name = v_detail_data:get(packet.key.cha_name).v_string
      local c_color
      local function check_camp()
        if v_detail_data:has(packet.key.camp_id) then
          local camp = v_detail_data:get(packet.key.camp_id).v_int
          if sys.check(bo2.player) and bo2.player:get_atb(bo2.eAtb_Camp) == camp then
            return false
          end
          local camp_name
          if bo2.player:get_atb(bo2.eAtb_Camp) == bo2.eCamp_Sword then
            camp_name = ui.get_text("phase|camp_blade")
          else
            camp_name = ui.get_text("phase|camp_sword")
          end
          local mtf = {cha_name = _name}
          local point = v_detail_data:get(packet.key.ui_title).v_int
          local camp_excel = ui_camp_repute.get_grade_excel(point)
          mtf.title, c_color = set_title_text(camp_excel, camp)
          if c_color ~= nil then
            mtf.c_begin = sys.format(L("<c+:%s>"), c_color)
            mtf.camp_id = camp_name
          else
            mtf.camp_id = camp_name
          end
          _name = ui_widget.merge_mtf(mtf, ui.get_text("map|cross_line"))
        elseif v_detail_data:has(packet.key.scnobj_flag) then
          local flag = v_detail_data:get(packet.key.scnobj_flag).v_int
          local c_camp = flag
          local mtf = {}
          local point = v_detail_data:get(packet.key.ui_title).v_int
          local camp_excel = ui_camp_repute.get_grade_excel(point)
          if c_camp == bo2.eCamp_Sword then
            mtf.camp = ui.get_text("cross_line|camp_blade")
            c_camp = bo2.eCamp_Blade
          else
            mtf.camp = ui.get_text("cross_line|camp_sword")
            c_camp = bo2.eCamp_Sword
          end
          if c_camp ~= bo2.player:get_atb(bo2.eAtb_Camp) then
            c_color = L("FF0000")
          end
          mtf.title = set_title_text(camp_excel, c_camp)
          mtf.cha_name = _name
          mtf.target_name = v_detail_data:get(packet.key.target_name).v_string
          mtf.dx = dx
          mtf.dy = dy
          _name = ui_widget.merge_mtf(mtf, ui.get_text("camp_repute|kill_tip"))
        end
        return true
      end
      if check_camp() then
        foot_trace_data[detail_index.v_int] = {
          id = id,
          x = dx,
          y = dy,
          name = _name,
          color = c_color
        }
      end
    end
  end
  load_foot_trace()
end
function on_map_foot_trace_dirty_data(cmd, data)
  if is_dynamic_pos_data_vaild() ~= true then
    return
  end
  local stamp = data:get(packet.key.cmn_index).v_int
  g_dynamic_pos_data.stamp = stamp
  local v_data = data:get(packet.key.cmn_dataobj)
  local size_vData = v_data.size
  for i = 0, size_vData - 1 do
    local v_detail_data = v_data:fetch_v(i)
    local detail_size = v_detail_data.size
    for n = 0, detail_size - 1 do
      do
        local detail_index, detail_pos_Data = v_detail_data:fetch_nv(n)
        local dx = detail_pos_Data:get(packet.key.cha_pos_x).v_int
        local dy = detail_pos_Data:get(packet.key.cha_pos_z).v_int
        local id = detail_pos_Data:get(packet.key.scnobj_excel_id).v_int
        local _name = detail_pos_Data:get(packet.key.cha_name).v_string
        local c_color
        local function check_camp()
          local v_detail_data = detail_pos_Data
          if detail_pos_Data:has(packet.key.camp_id) then
            local camp = detail_pos_Data:get(packet.key.camp_id).v_int
            if sys.check(bo2.player) and bo2.player:get_atb(bo2.eAtb_Camp) == camp then
              return false
            end
            local camp_name
            if bo2.player:get_atb(bo2.eAtb_Camp) == bo2.eCamp_Sword then
              camp_name = ui.get_text("phase|camp_blade")
            else
              camp_name = ui.get_text("phase|camp_sword")
            end
            local mtf = {cha_name = _name}
            local point = detail_pos_Data:get(packet.key.ui_title).v_int
            local camp_excel = ui_camp_repute.get_grade_excel(point)
            mtf.title, c_color = set_title_text(camp_excel, camp)
            if c_color ~= nil then
              mtf.c_begin = sys.format(L("<c+:%s>"), c_color)
              mtf.camp_id = camp_name
            else
              mtf.camp_id = camp_name
            end
            _name = ui_widget.merge_mtf(mtf, ui.get_text("map|cross_line"))
          elseif v_detail_data:has(packet.key.scnobj_flag) then
            local flag = v_detail_data:get(packet.key.scnobj_flag).v_int
            local c_camp = flag
            local mtf = {}
            local point = v_detail_data:get(packet.key.ui_title).v_int
            local camp_excel = ui_camp_repute.get_grade_excel(point)
            if c_camp == bo2.eCamp_Sword then
              mtf.camp = ui.get_text("cross_line|camp_blade")
              c_camp = bo2.eCamp_Blade
            else
              mtf.camp = ui.get_text("cross_line|camp_sword")
              c_camp = bo2.eCamp_Sword
            end
            mtf.title = set_title_text(camp_excel, c_camp)
            mtf.cha_name = _name
            mtf.target_name = v_detail_data:get(packet.key.target_name).v_string
            mtf.dx = dx
            mtf.dy = dy
            if c_camp ~= bo2.player:get_atb(bo2.eAtb_Camp) then
              c_color = L("FF0000")
            end
            _name = ui_widget.merge_mtf(mtf, ui.get_text("camp_repute|kill_tip"))
          end
          return true
        end
        if check_camp() then
          foot_trace_data[detail_index.v_int] = {
            id = id,
            x = dx,
            y = dy,
            name = _name,
            color = c_color
          }
        end
      end
    end
  end
  load_foot_trace()
end
function on_map_foot_del_data(cmd, data)
  local index = data:get(packet.key.cmn_index).v_int
  foot_trace_data[index] = nil
  load_foot_trace()
end
function on_foot_trace(btn, msg)
  if msg == ui.mouse_lbutton_down then
    local point = btn.parent.svar
    find_path(point.x, point.y)
  end
end
function on_destination_mouse(btn, msg)
  if msg == ui.mouse_lbutton_down then
    btn:insert_post_invoke(ui_minimap.on_goon_find, "ui_minimap.on_goon_find")
  end
end
function update_path()
  local v = bo2.getpath_k()
  if v.size > 0 then
    ui_dots_clear(w_drawdots)
    path_data = {}
    for i = 0, v.size - 1, 2 do
      table.insert(path_data, {
        x = v:get(i).v_int,
        y = v:get(i + 1).v_int
      })
    end
    ui_minimap.set_find_path()
    w_drawdot_des:control_clear()
    redraw_dots()
  end
end
function get_store_scn_id()
  if get_store_exist() ~= true then
    return 0
  end
  local t_mark = bo2.gv_mark_list:find(g_real_mark)
  if sys.check(t_mark) ~= true then
    return 0
  end
  return t_mark.scn_id
end
function get_store_exist()
  if g_real_mark == nil or g_real_mark == 0 then
    return false
  end
  return true
end
function clear_store()
  g_real_mark = 0
  g_m_id = 0
end
function store_target_mark(real_mark)
  clear_store()
  local t_mark = bo2.gv_mark_list:find(real_mark)
  if sys.check(t_mark) ~= true then
    return 0
  end
  g_real_mark = real_mark
end
function on_skill_use(cmd, data)
  local type = data:get(packet.key.cmn_type).v_int
  if type ~= 4 then
    return
  end
  bo2.breakmove_k()
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_Skill, on_skill_use, "ui_map:on_skill_use")
local sig_name = "ui_map:update_player"
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_position, update_player, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_path_break, on_path_break, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_path_end, on_path_end, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_path_close, on_path_close, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_path_unreached, on_path_unreached, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_path_cantmove, on_path_cantmove, sig_name)
ui_packet.game_recv_signal_insert(packet.eSTC_ScnObj_ShowPath, handleShowPath, "ui_map.packet_handler")
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_create_finish, "ui_map.on_create_finish")
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_MapFootTraceDirtyData, on_map_foot_trace_dirty_data, "ui_map:on_map_foot_trace_dirty_data")
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_MapFootTrace, on_map_foot_data, "ui_map:on_map_foot_data")
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_MapFootTraceDelData, on_map_foot_del_data, "ui_map:on_map_foot_del_data")
ui_packet.recv_wrap_signal_insert(packet.eSTC_Guild_GetWorldScnList, on_world_scnlist, "ui_map:on_world_scnlist")
