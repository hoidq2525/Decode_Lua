local scale = 1
local PIC_NAME = "qy_zhongyuan_"
local PRE_PIC_SIZE = 256
local PIC_PATH = "$image/map/minimap/qy_zhongyuan/"
local cur_index_x, cur_index_y, object, cur_map
local mark_icon_uri = "$icon/npc/"
local npc_find_path_big_dy = 200
local npc_find_path_small_dy = 40
local b_is_above = false
local g_map_trace = {}
local g_player_trace = {}
local g_max_trace = 20
function trace_init_once()
  g_map_trace = {}
end
trace_init_once()
function load_all_trace()
  w_foot_trace:control_clear()
  for i = 0, g_max_trace - 1 do
    local item = ui.create_control(w_foot_trace, "panel")
    item:load_style("$frame/minimap/minimap.xml", "foot_trace")
    item.visible = false
    item.svar = {}
    local pic = item:search("w_foot_trace")
    if sys.check(pic) then
      pic.image = sys.format(L("$image/qbar/btn_cross_line.png|8,21,17,20"))
      pic.dx = 17
      pic.dy = 20
    end
  end
end
function clean_trace()
  if sys.check(w_foot_trace) then
    for i = 0, g_max_trace - 1 do
      local item = w_foot_trace:control_get(i)
      if sys.check(item) then
        item.visible = false
        item.svar = {}
      end
    end
  end
  g_player_trace = {}
end
local init_once = function()
  if rawget(_M, g_alrealy_init) ~= nil then
    return
  end
  g_alrealy_init = true
end
function on_huodong(btn)
  local campaign_view = ui.find_control("$frame:campaign")
  campaign_view.visible = not campaign_view.visible
end
function on_huodong_start()
end
function on_huodong_end()
end
function on_btn_find_npc()
  w_npc_panel.visible = not w_npc_panel.visible
  if w_npc_panel.visible == true then
    ui_handson_teach.test_complate_npc_list()
  else
    ui_handson_teach.test_complate_npc_view_list()
  end
end
function get_empty_item()
  for i = 0, g_max_trace - 1 do
    local item = w_foot_trace:control_get(i)
    if sys.check(item) and item.visible ~= true then
      return item, i
    end
  end
  return nil
end
function on_trace_player_update(obj)
  if obj == bo2.player then
    return
  end
  if obj.kind ~= bo2.eScnObjKind_Player then
    return
  end
  local item = g_player_trace[obj.only_id]
  if item == nil then
    return
  end
  if item.svar.player ~= obj then
    return
  end
  set_item_by_player(item, obj)
end
function set_trace_tip_text(player)
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
  local camp = player:get_atb(bo2.eAtb_Camp)
  if camp == bo2.eCamp_Sword then
    camp_name = ui.get_text("phase|camp_sword")
  else
    camp_name = ui.get_text("phase|camp_blade")
  end
  local mtf = {
    cha_name = player.name
  }
  local point = player:get_flag_int32(bo2.ePlayerFlagInt32_CampReputeTotalPoint)
  local camp_excel = ui_camp_repute.get_grade_excel(point)
  mtf.title, c_color = set_title_text(camp_excel, camp)
  if c_color ~= nil then
    mtf.c_begin = sys.format(L("<c+:%s>"), c_color)
    mtf.camp_id = camp_name
  else
    mtf.camp_id = camp_name
  end
  return ui_widget.merge_mtf(mtf, ui.get_text("map|cross_line"))
end
function set_item_by_player(item, player, is_new)
  local pos_x, pos_z = player:get_position()
  if is_new == nil then
    local x = item.svar.pos_x
    local z = item.svar.pos_z
    local dist = (pos_x - x) ^ 2 + (pos_z - z) ^ 2
    if dist < 4 then
      return
    end
  end
  item.svar.pos_x = pos_x
  item.svar.pos_z = pos_z
  item.offset = ui.point((pos_x - (cur_index_x - 1) * 256) * scale - 8, (768 - (pos_z - (cur_index_y - 1) * 256)) * scale - 8)
  if is_new ~= nil then
    local tip = item:search("w_foot_trace").tip
    if sys.check(tip) then
      tip.text = set_trace_tip_text(player)
    end
    item.svar.player = player
    g_player_trace[player.only_id] = item
    item.visible = true
  end
end
function load_foot_trace(player_set)
  local function process_data(item)
    if sys.check(item) ~= true or item.visible ~= true then
      return
    end
    local function on_faild(c_player)
      item.visible = false
      item.svar.player = nil
      if c_player ~= nil then
        g_player_trace[c_player.only_id] = nil
      end
    end
    if sys.check(item.svar.player) ~= true then
      on_faild()
      return
    end
    local c_player = item.svar.player
    if player_set[c_player.only_id] == nil then
      on_faild(c_player)
      return
    end
    set_item_by_player(item, c_player)
    player_set[c_player.only_id] = nil
  end
  for i = 0, g_max_trace - 1 do
    local item = w_foot_trace:control_get(i)
    process_data(item)
  end
  local function on_new_item()
    for i, v in pairs(player_set) do
      if v ~= nil then
        local item, count = get_empty_item()
        if item == nil then
          return
        end
        set_item_by_player(item, v, true)
      end
    end
  end
  on_new_item()
end
function update_map_trace()
  if sys.check(w_default_image) and w_default_image.visible == true then
    return
  end
  local time = ui_main.get_os_time()
  if g_map_trace.os_time == nil then
    g_map_trace.os_time = time
  else
    if time - g_map_trace.os_time < 3 then
      return
    end
    g_map_trace.os_time = time
  end
  local scn = bo2.scn
  if scn == nil then
    return
  end
  local player_set = {}
  local has_trace = false
  local function find_trace_player(player)
    if sys.check(player) ~= true then
      return
    end
    if bo2.player == player then
      return
    end
    local flag = player:get_flag_objmem(bo2.eFlagObjMemory_TraceFlag)
    if flag ~= 2 then
      return
    end
    if player:get_atb(bo2.eAtb_Camp) == bo2.player:get_atb(bo2.eAtb_Camp) then
      return
    end
    has_trace = true
    player_set[player.only_id] = player
  end
  scn:ForEachScnObj(bo2.eScnObjKind_Player, find_trace_player)
  if has_trace ~= true then
    clean_trace()
    return
  end
  load_foot_trace(player_set)
end
function on_find_path_visible(w, vis)
  if vis == true then
    w_npc_panel.x = gx_minimap_win.x - 100
    local dy = gx_minimap_win.y - npc_find_path_big_dy
    if dy < 0 then
      dy = gx_minimap_win.y + gx_minimap_win.dy
      w_npc_panel:search("npc_search_panel").dock = L("fill_y1")
      b_is_above = false
    else
      dy = gx_minimap_win.y - w_npc_panel.dy
      w_npc_panel:search("npc_search_panel").dock = L("fill_y2")
      b_is_above = true
    end
    w_npc_panel.y = dy
  else
    w_npc_panel.dy = npc_find_path_big_dy
    w_npc_panel:search("npc_list_panel").visible = true
    w_npc_panel:move_to_head()
  end
  ui_widget.on_visible_sound(w, vis)
end
function on_zoom()
  w_fun_btns.visible = true
  w_main_panel.visible = true
  w_btn_display_map.visible = false
end
function on_shrink()
  w_npc_panel.visible = false
  w_hide_convene_mask = false
  w_fun_btns.visible = false
  w_main_panel.visible = false
  w_btn_display_map.visible = true
end
function on_show_map()
  local map_view = ui.find_control("$frame:map")
  map_view.visible = not map_view.visible
end
function update_camere(obj)
  if obj == bo2.player then
    local angle = bo2.GetCamereAngel()
    w_player_sector:angle(angle)
  end
end
function update_member_minimap(only_id)
  local function set_member_mise(info)
    if info.only_id == sys.wstring(0) then
      return
    end
    if info.name == bo2.player.name then
      return
    end
    if info.status == 0 then
      return
    end
    if info.gzs_id ~= bo2.player:get_flag_objmem(bo2.eFlagObjMemory_GZSId) then
      return
    end
    if info.pos_x == 0 and info.pos_z == 0 then
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
    if scn_excel.id == ui_map.cur_scn_id then
      local radius = math.sqrt((info.pos_x - player_pos_x) ^ 2 + (info.pos_z - player_pos_y) ^ 2)
      if radius < 55 then
        if member_list[info.only_id] and sys.check(member_list[info.only_id].item) then
          local item = member_list[info.only_id].item
          item.offset = ui.point((info.pos_x - (cur_index_x - 1) * 256) * scale - 8, (768 - (info.pos_z - (cur_index_y - 1) * 256)) * scale - 8)
          item.svar = {
            x = info.pos_x,
            y = info.pos_z
          }
        else
          local style = "member"
          if ui_map.isOneTeam(info.only_id) then
            style = "team"
          end
          local item = ui.create_control(w_member, "panel")
          item:load_style("$frame/minimap/minimap.xml", style)
          item.offset = ui.point((info.pos_x - (cur_index_x - 1) * 256) * scale - 8, (768 - (info.pos_z - (cur_index_y - 1) * 256)) * scale - 8)
          item:search("w_misc").tip.text = info.name
          item.svar = {
            x = info.pos_x,
            y = info.pos_z
          }
          member_list[info.only_id] = {item = item}
        end
      else
        if member_list[info.only_id] and sys.check(member_list[info.only_id].item) then
          local item = member_list[info.only_id].item
          item:post_release()
        end
        if member_out_list[info.only_id] and sys.check(member_out_list[info.only_id].item) then
          local item = member_out_list[info.only_id].item
          item.offset = ui.point((player_pos_x - 55 * (player_pos_x - info.pos_x) / radius - (cur_index_x - 1) * 256) * scale - 8, (768 - (player_pos_y - 55 * (player_pos_y - info.pos_z) / radius - (cur_index_y - 1) * 256)) * scale - 8)
          local angle = math.asin((info.pos_x - player_pos_x) / radius)
          if info.pos_z > player_pos_y then
            item:search("misc"):angle(angle * 180 / math.pi)
          else
            item:search("misc"):angle(180 - angle * 180 / math.pi)
          end
          item.svar = {
            x = info.pos_x,
            y = info.pos_z
          }
        else
          local item = ui.create_control(w_member, "panel")
          item:load_style("$frame/minimap/minimap.xml", "arrow_member")
          item.offset = ui.point((player_pos_x - 55 * (player_pos_x - info.pos_x) / radius - (cur_index_x - 1) * 256) * scale - 8, (768 - (player_pos_y - 55 * (player_pos_y - info.pos_z) / radius - (cur_index_y - 1) * 256)) * scale - 8)
          local angle = math.asin((info.pos_x - player_pos_x) / radius)
          if info.pos_z > player_pos_y then
            item:search("misc"):angle(angle * 180 / math.pi)
          else
            item:search("misc"):angle(180 - angle * 180 / math.pi)
          end
          item:search("misc").tip.text = info.name
          item.svar = {
            x = info.pos_x,
            y = info.pos_z
          }
          member_out_list[info.only_id] = {item = item}
        end
      end
    elseif scn_excel.in_scn_id == ui_map.cur_scn_id then
      local excel = bo2.gv_scn_list:find(ui_map.cur_scn_id)
      if excel.map_id ~= ui_map.g_map_level.cur_map_id then
        return
      end
      local point = bo2.markrandpoint(scn_excel.in_scn_point)
      if point then
        local radius = math.sqrt((point.x - player_pos_x) ^ 2 + (point.y - player_pos_y) ^ 2)
        if radius < 55 then
          if member_list[info.only_id] and sys.check(member_list[info.only_id].item) then
            local item = member_list[info.only_id].item
            item.offset = ui.point((point.x - (cur_index_x - 1) * 256) * scale - 8, (768 - (point.y - (cur_index_y - 1) * 256)) * scale - 8)
            item.svar = {
              x = point.x,
              y = point.y
            }
          else
            local style = "member"
            if ui_map.isOneTeam(info.only_id) then
              style = "team"
            end
            local item = ui.create_control(w_member, "panel")
            item:load_style("$frame/minimap/minimap.xml", style)
            item.offset = ui.point((point.x - (cur_index_x - 1) * 256) * scale - 8, (768 - (point.y - (cur_index_y - 1) * 256)) * scale - 8)
            item:search("w_misc").tip.text = info.name .. "(" .. scn_excel.name .. ")"
            item.svar = {
              x = point.x,
              y = point.y
            }
            member_list[info.only_id] = {item = item}
          end
        else
          if member_list[info.only_id] and sys.check(member_list[info.only_id].item) then
            local item = member_list[info.only_id].item
            item:post_release()
          end
          if member_out_list[info.only_id] and sys.check(member_out_list[info.only_id].item) then
            local item = member_out_list[info.only_id].item
            item.offset = ui.point((player_pos_x - 55 * (player_pos_x - point.x) / radius - (cur_index_x - 1) * 256) * scale - 8, (768 - (player_pos_y - 55 * (player_pos_y - point.y) / radius - (cur_index_y - 1) * 256)) * scale - 8)
            local angle = math.asin((point.x - player_pos_x) / radius)
            if point.y > player_pos_y then
              item:search("misc"):angle(angle * 180 / math.pi)
            else
              item:search("misc"):angle(180 - angle * 180 / math.pi)
            end
            item.svar = {
              x = point.x,
              y = point.y
            }
          else
            local item = ui.create_control(w_member, "panel")
            item:load_style("$frame/minimap/minimap.xml", "arrow_member")
            item.offset = ui.point((player_pos_x - 55 * (player_pos_x - point.x) / radius - (cur_index_x - 1) * 256) * scale - 8, (768 - (player_pos_y - 55 * (player_pos_y - point.y) / radius - (cur_index_y - 1) * 256)) * scale - 8)
            local angle = math.asin((point.x - player_pos_x) / radius)
            if point.y > player_pos_y then
              item:search("misc"):angle(angle * 180 / math.pi)
            else
              item:search("misc"):angle(180 - angle * 180 / math.pi)
            end
            item:search("misc").tip.text = info.name .. "(" .. scn_excel.name .. ")"
            item.svar = {
              x = point.x,
              y = point.y
            }
            member_out_list[info.only_id] = {item = item}
          end
        end
      end
    end
  end
  local info
  if only_id ~= nil then
    info = ui.member_find(only_id)
  end
  if info then
    set_member_mise(info)
    return
  else
    w_member:control_clear()
    member_list = {}
    member_out_list = {}
    for i = 0, 19 do
      local info = ui.member_get_by_idx(i)
      set_member_mise(info)
    end
  end
end
function read_misc()
  local function set_misc(x, y, type, content, id)
    if x >= (cur_index_x - 2) * 256 and x <= (cur_index_x + 2) * 256 and y >= (cur_index_y - 2) * 256 and y <= (cur_index_y + 2) * 256 then
      local item = ui.create_control(w_misc, "panel")
      item:load_style("$frame/minimap/minimap.xml", "misc")
      item.offset = ui.point((x - (cur_index_x - 1) * 256) * scale - 8, (768 - (y - (cur_index_y - 1) * 256)) * scale - 8)
      item:search("w_misc").tip.text = content
      local type_excel = bo2.gv_mark_type:find(type)
      local uri
      if type_excel then
        uri = type_excel.icon
        item:search("w_misc").image = mark_icon_uri .. uri
      end
      item.svar = {
        x = x,
        y = y,
        id = id
      }
    end
  end
  w_misc:control_clear()
  local id = cur_map
  local map_excel = bo2.gv_map_list:find(id)
  if map_excel == nil then
    return
  end
  for i = 0, bo2.gv_quest_list.size - 1 do
    local excel = bo2.gv_quest_list:get(i)
    local info = ui.quest_find(excel.id)
    if info ~= nil and info.completed then
      local excel2 = bo2.gv_mark_list:find(excel.end_obj_mark)
      if excel2 ~= nil and excel2.scn_id == map_excel.scn_id then
        local point = bo2.mapmark_nametopoint(bo2.gv_mark_list:find(excel.end_obj_mark).enter_point)
        if point.x ~= -1 then
          set_misc(math.floor(point.x), math.floor(point.y), 16, bo2.gv_mark_list:find(excel.end_obj_mark).name, excel.end_obj_mark)
        end
      end
    end
  end
  for i = 0, bo2.gv_quest_list.size - 1 do
    local excel = bo2.gv_quest_list:get(i)
    if excel.gps_target_id ~= 0 and ui.quest_check_insert(excel.id) and bo2.is_cooldown_over(excel.cooldown) == true then
      local excel2 = bo2.gv_mark_list:find(excel.gps_target_id)
      if excel2 ~= nil and excel2.scn_id == map_excel.scn_id then
        local point = bo2.mapmark_nametopoint(bo2.gv_mark_list:find(excel.gps_target_id).enter_point)
        if point.x ~= -1 then
          set_misc(math.floor(point.x), math.floor(point.y), 15, bo2.gv_mark_list:find(excel.gps_target_id).name, excel.gps_target_id)
        end
      end
    end
  end
  for i = 0, bo2.gv_mark_list.size - 1 do
    local mark_excel = bo2.gv_mark_list:get(i)
    if mark_excel.scn_id == map_excel.scn_id and mark_excel.minimap == 1 and ui_map.check_mark_visible(mark_excel.visible_conds) then
      local point = bo2.mapmark_nametopoint(mark_excel.enter_point)
      if point.x ~= -1 then
        set_misc(math.floor(point.x), math.floor(point.y), mark_excel.mark_type, mark_excel.name, mark_excel.id)
      end
    end
  end
end
function reset_pos()
end
function update_pic(x, y)
  local getIntPart = function(x)
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
  local index_x, index_y
  index_x = getIntPart(x / 256)
  index_y = getIntPart(y / 256)
  if index_x == cur_index_x and index_y == cur_index_y then
    return
  else
    cur_index_x = index_x
    cur_index_y = index_y
    local excel = bo2.gv_scn_list:find(ui_map.cur_scn_id)
    if excel and excel.not_show_minimap == 1 then
      for i = -1, 1 do
        for j = -1, 1 do
          w_backcloth:set_item(i + 1, j + 1, "$image/widget/fig/256x256/bg4.png")
        end
      end
      w_default_image.visible = true
      w_misc:control_clear()
      return
    end
    local i, j
    local map_cnt = 0
    local grid_x = excel.map_size / 256
    local grid_y = excel.map_size / 256
    for i = -1, 1 do
      for j = -1, 1 do
        local image_title = PIC_PATH .. PIC_NAME .. index_x + i .. "_" .. index_y - j
        local image_path = image_title .. ".dds"
        local is_file = sys.is_file(image_path)
        if not is_file then
          image_path = image_title .. ".png"
          is_file = sys.is_file(image_path)
        end
        if is_file then
          w_backcloth:set_item(i + 1, j + 1, image_path)
          w_default_image.visible = false
          w_move_front.visible = true
          map_cnt = map_cnt + 1
        else
          local path_error = false
          if grid_x > index_x + i and index_x + i >= 0 and grid_y > index_y - j and index_y + j >= 0 then
            path_error = true
          end
          if path_error then
            w_default_image.visible = true
          end
          w_backcloth:set_item(i + 1, j + 1, "$image/widget/fig/256x256/bg4.png")
        end
      end
    end
    if cur_index_x == nil or cur_index_y == nil then
      return
    end
    set_find_path()
    read_misc()
  end
end
function read_other_player(obj)
end
function update_player(obj)
  object = obj
  local function update_other_player(object)
    local x, y = obj:get_position()
    local item = ui.create_control(w_misc, "panel")
    item:load_style("$frame/minimap/minimap.xml", "misc")
    item.offset = ui.point(x * scale, y * scale)
    item:search("w_misc").tip.text = "other_player"
  end
  local function set_position(x, y)
    w_move_back.offset = ui.point(-(math.floor(x) % 256 - 128) * scale, (math.floor(y) % 256 - 128) * scale)
  end
  if obj == bo2.player then
    local x, y = obj:get_position()
    player_pos_x = x
    player_pos_y = y
    local angle = obj.angle
    set_position(x, y)
    w_arrow:angle(angle * 180 / math.pi - 180)
    w_arrow.tip.text = sys.format("%s", obj.name)
    update_pic(x, y)
    w_coordinate.text = sys.format("%d  %d", x, y)
    update_member_minimap()
    update_camere(obj)
    update_map_trace()
  end
end
function r()
  set_path(bo2.player)
end
function set_path(obj)
  local mb_current_scn = bo2.scn.scn_excel
  clean_trace()
  PIC_PATH = "$res/scn/" .. mb_current_scn.load_path .. "/preview/"
  PIC_NAME = "p_"
  cur_index_x = nil
  cur_index_y = nil
  update_player(obj)
end
function update_misc(obj)
  read_misc()
end
function send_position(x, y)
  ui.log("send_position %d,%d", x, y)
end
function update_btn_hide_map()
  if w_btn_hide_map.hover or w_minimap_shape.inner_hover then
    w_btn_hide_map:search("pic").visible = true
  else
    w_btn_hide_map:search("pic").visible = false
  end
end
local post_btn_hide_map = function()
  w_minimap_shape:insert_post_invoke(update_btn_hide_map, "ui_minimap.update_btn_hide_map")
end
function minimap_on_mouse(panel, msg, pos)
  if msg == ui.mouse_lbutton_click then
    local x, y = object:get_position()
    local radius = math.sqrt(math.abs(pos.x - 67) * math.abs(pos.x - 67) + math.abs(pos.y - 67) * math.abs(pos.y - 67))
    if radius <= 67 then
      ui_map.find_path(x + (pos.x - 67) / scale, y - (pos.y - 67) / scale)
    end
  elseif msg == ui.mouse_inner then
    post_btn_hide_map()
  elseif msg == ui.mouse_outer then
    post_btn_hide_map()
  end
end
function btn_hide_map_mouse(panel, msg, pos)
  if msg == ui.mouse_enter or msg == ui.mouse_leave then
    post_btn_hide_map()
  end
end
function find_path(x, y)
  ui_set_dot(w_drawdots, (x - (cur_index_x - 1) * 256) * scale, (768 - (y - (cur_index_y - 1) * 256)) * scale, 1)
end
function set_find_path()
  ui_dots_clear(w_drawdots)
  for i, v in ipairs(ui_map.path_data) do
    if math.mod(i, 2) == 0 then
      ui_set_dot(w_drawdots, (v.x - (cur_index_x - 1) * 256) * scale, (768 - (v.y - (cur_index_y - 1) * 256)) * scale, 1)
    end
  end
  w_drawdot_des:control_clear()
  local path_data = ui_map.path_data
  if #path_data > 0 then
    local x = path_data[#path_data].x
    local y = path_data[#path_data].y
    local item = ui.create_control(w_drawdot_des, "panel")
    item:load_style("$frame/map/map.xml", "destination")
    item.offset = ui.point((x - (cur_index_x - 1) * 256) * scale - 8, (768 - (y - (cur_index_y - 1) * 256)) * scale - 15)
  end
end
function item_on_mouse(item, msg)
  if msg == ui.mouse_enter then
    item.parent:search("select").visible = true
  end
  if msg == ui.mouse_leave then
    item.parent:search("select").visible = false
  end
end
function get_gzs_on_click(btn)
  ui_choice.task_update_gzs()
  gzs_show = true
end
function set_cur_gzs()
end
function init_gzs()
  ui_choice.task_update_gzs()
end
function update_gzs_list(list)
  if list == nil then
    ui.log("update_gzs_list: list empty")
    return
  end
  server_list_data = {}
  gx_gzs_list:item_clear()
  for i = 0, list.size - 1 do
    local info = list:get(i)
    local item_data = {
      name = info:get("GZS_Name").v_string,
      id = info:get("GZS_ID").v_int,
      info = info
    }
    table.insert(server_list_data, item_data)
  end
  for i, v in ipairs(server_list_data) do
    item = gx_gzs_list:item_insert(gx_gzs_list.item_count)
    item:load_style("$frame/minimap/minimap.xml", "gzs_list_item")
    item:search("text").text = v.name
    item.svar.id = v.id
  end
  set_cur_gzs()
  if gzs_show == true then
    local menu = {}
    local item = {}
    for i, v in ipairs(server_list_data) do
      table.insert(item, {
        text = v.name,
        id = v.id,
        callback = gzs_on_click
      })
    end
    menu = {
      items = item,
      dx = 150,
      dy = 50,
      consult = w_show_gzs_btn,
      popup = "y2"
    }
    ui_tool.show_cha_menu(menu)
    gzs_show = false
  end
end
function on_gzs_confirm(msg)
  if msg.result == 0 then
    return
  end
  local v = sys.variant()
  v:set(packet.key.gzs_id, msg.gzsid)
  bo2.send_variant(packet.eCTS_UI_ChgGZS, v)
end
function gzs_on_click(item)
  local id = item.id
  local msg = {
    gzsid = id,
    callback = on_gzs_confirm,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.title = ui.get_text("map|chg_line_msg_title")
  msg.text = ui_widget.merge_mtf({
    channel = item.text
  }, ui.get_text("map|chg_line_msg_des"))
  ui_widget.ui_msg_box.show_common(msg)
end
function on_visable_npc_list(w, vis)
  if vis ~= true then
  end
end
function on_char(box, ch)
  if ch == 13 then
    enter_flag = true
  end
end
function set_fader()
  w_find_path_fader.visible = true
  w_find_path_fader:reset(1, 0, 1000)
end
function on_input(box, key, flag)
  if flag.down then
    return
  end
  if key == 13 and enter_flag == true then
    local s = tostring(w_input.text)
    if string.find(s, "^%d+,%d+$") then
      local x, y = string.match(s, "(%d+),(%d+)")
      ui_map.find_path(x, y)
      cur_find_id = nil
      cur_find_x = x
      cur_find_y = y
    else
      ui_tool.note_insert(ui.get_text("map|minimap_err_format"), "FFFF00")
      w_npc_panel:search("npc_list_panel").visible = true
    end
    enter_flag = false
    box.focus = false
  end
end
function npc_on_click(btn)
  w_input.text = btn.text
  ui_map.find_path_byid(btn.parent.svar)
  if id ~= cur_find_id then
    set_fader()
  end
  cur_find_id = btn.parent.svar
  gx_npc_list.parent.visible = false
  w_input.focus = false
end
function set_path_npc(id, x, y)
  if id then
    local excel = bo2.gv_mark_list:find(id)
    if excel == nil then
      return
    end
    w_input.text = excel.name
    cur_find_id = id
    w_input.focus = false
    gx_npc_list.parent.visible = false
  elseif x and y then
    cur_find_id = nil
    if x ~= cur_find_x or y ~= cur_find_y then
      set_fader()
    end
    cur_find_x = x
    cur_find_y = y
    w_input.text = sys.format("%s,%s", x, y)
    w_input.focus = false
    gx_npc_list.parent.visible = false
  else
    w_input.text = ""
    w_npc_panel.visible = false
  end
end
function on_focus(box)
  w_npc_panel:search("npc_list_panel").visible = true
end
function insert_menu_item(id, text)
  local child_item_uri = L("$frame/minimap/minimap.xml")
  local child_item_style = L("menu_item")
  local child_item = w_npc_list_view:item_append()
  child_item:load_style(child_item_uri, child_item_style)
  child_item:search("btn_color").text = text
  child_item.svar = id
  return child_item
end
function update_find_npc(id, s)
  cur_map = id
  read_misc()
  w_npc_list_view:item_clear()
  if id == 0 then
    return
  end
  local sort_name_tb = {}
  for j = 0, bo2.gv_mark_list.size - 1 do
    for i = 0, bo2.gv_mark_list:get(j).map_id.size do
      local mark_excel = bo2.gv_mark_list:get(j)
      if mark_excel.map_id[i] == id and 0 < mark_excel.find and ui_map.check_mark_visible(mark_excel.visible_conds) then
        local item, name
        if mark_excel.data ~= L("") then
          name = sys.format("%s(%s)", mark_excel.name, mark_excel.data)
        else
          name = mark_excel.name
        end
        if s == nil then
          item = insert_menu_item(mark_excel.id, name)
        else
          local sname = tostring(name)
          if string.find(sname, s) then
            item = insert_menu_item(mark_excel.id, name)
          end
        end
        if item ~= nil then
          table.insert(sort_name_tb, {
            tb_item = item,
            priority = mark_excel.find
          })
        end
      end
    end
  end
  local npc_priority_sort = function(a, b)
    return a.priority > b.priority
  end
  table.sort(sort_name_tb, npc_priority_sort)
  for i, n in ipairs(sort_name_tb) do
    n.tb_item.index = i - 1
  end
end
function on_goon_find(btn)
  if cur_find_id then
    ui_map.find_path_byid(cur_find_id)
  elseif cur_find_x and cur_find_y then
    ui_map.find_path(cur_find_x, cur_find_y)
  end
end
function on_vis_leave_help(w, vis)
  if vis ~= true then
    gx_leave_help_mask.visible = false
  end
end
function on_leave_copyunit(btn)
  local on_msg = function(msg)
    if msg.result == 0 then
      return
    end
    if sys.check(bo2.player) and bo2.player:get_flag_objmem(bo2.eFlagObjMemory_FightState) == 0 then
      ui_video.on_auto_end_rec_match_video()
    end
    bo2.send_variant(packet.eCTS_UI_LeaveDungeonScn)
  end
  local msg = {
    callback = on_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = false,
    close_on_leavascn = true
  }
  msg.text = ui.get_text("common|leave_scn")
  ui_widget.ui_msg_box.show_common(msg)
  set_leave_help_visible(false)
end
function test()
  gx_leave_copyunit.visible = true
  ui_minimap.set_leave_help_visible(true, true)
end
function set_leave_visible()
  local scn_type = bo2.gv_scn_alloc:find(bo2.scn.scn_excel.id).type
  if bo2.scn.scn_excel.id == 3 then
    gx_leave_copyunit.visible = false
    return
  end
  if scn_type ~= 0 and scn_type ~= 2 then
    gx_leave_copyunit.visible = true
  else
    gx_leave_copyunit.visible = false
    set_leave_help_visible(false)
  end
end
function on_btn_show_boss_list_click(ctrl)
  ui_boss_list.on_btn_show_boss_list_click(ctrl)
end
function on_btn_show_action_click()
  ui_action.on_btn_show_action_click()
end
function on_btn_show_video()
  ui_video.on_btn_show_video()
end
function on_leave_help_timer()
  set_leave_help_visible(false)
end
local mini_priority = 0
function set_leave_help_visible(vis, enable_mask)
  if vis then
    gx_leave_help.visible = true
    do
      local flicker = gx_leave_copyunit:search(L("hs_flicker"))
      flicker.visible = true
      local rb = gx_leave_help:search("leave_help")
      rb.mtf = L("<handson:71,4>")
      local function on_time_tune()
        if sys.check(rb) then
          rb.parent:tune("leave_help")
        end
      end
      bo2.AddTimeEvent(1, on_time_tune)
      local function show()
        if sys.check(gx_leave_help_view) then
          gx_leave_help_view:show_popup(ui_minimap.gx_leave_copyunit, L("y1x1"), ui.rect(rb.dx / 2 - 10, -17, 0, 0))
        end
      end
      bo2.AddTimeEvent(2, show)
      mini_priority = ui_minimap.gx_minimap_win.priority
      if enable_mask ~= nil and enable_mask == true then
        gx_leave_help_mask.visible = true
        gx_leave_help_mask.priority = 500
        ui_minimap.gx_minimap_win.priority = 510
      end
      gx_leave_help.priority = ui_minimap.gx_minimap_win.priority + 5
      gx_leave_help_timer.suspended = false
    end
  else
    local flicker = gx_leave_copyunit:search(L("hs_flicker"))
    flicker.visible = false
    gx_leave_help_timer.suspended = true
    gx_leave_help.visible = false
    ui_minimap.gx_minimap_win.priority = mini_priority
  end
end
function on_make_video_tip(tip)
  local v = ui_setting.ui_input.op_def.window_video.hotkey
  local k = v:get_cell(0).text
  if k.size == 0 then
    k = v:get_cell(1).text
  end
  if 0 < k.size then
    ui_widget.tip_make_view(tip.view, sys.format("%s<space:0.4><key:%s>", tip.text, k))
    return
  end
  ui_widget.tip_make_view(tip.view, tip.text)
end
function on_init()
  scale = 1
  PRE_PIC_SIZE = 256
  cur_index_x = nil
  cur_index_y = nil
  cur_find_id = nil
  cur_find_x = nil
  cur_find_y = nil
  object = nil
  member_list = {}
  w_move_front.visible = true
  w_default_image.visible = false
  on_make_tip = ui_map.make_tip_factory(w_member)
  load_all_trace()
end
function on_minimap_move(v)
  w_npc_panel.visible = false
end
function on_npc_list_visible(ctrl, vis)
  if vis then
    w_npc_panel.dy = npc_find_path_big_dy
  else
    w_npc_panel.dy = npc_find_path_small_dy
  end
  if b_is_above then
    w_npc_panel.y = gx_minimap_win.y - w_npc_panel.dy
  end
end
function on_show_npc_list(btn)
  local vis = w_npc_panel:search("npc_list_panel").visible
  w_npc_panel:search("npc_list_panel").visible = not vis
end
function on_select_npc(btn)
  local id = btn.parent.svar
  w_input.text = btn:search("btn_color").text
  ui_map.find_path_byid(id)
  if id ~= cur_find_id then
    set_fader()
  end
  cur_find_id = id
  w_npc_panel:search("npc_list_panel").visible = false
  w_input.focus = false
  ui_handson_teach.test_complate_npc_view_list()
end
function r()
  set_path(bo2.player)
  update_misc()
  ui.log("ui_map.g_map_level.cur_map_id" .. ui_map.g_map_level.cur_map_id)
  update_find_npc(ui_map.g_map_level.cur_map_id)
end
local sig_name = "ui_minimap:on_signal"
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, set_path, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_position, update_player, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_camere_angel, update_camere, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_position, on_trace_player_update, "ui_minimap:on_trace_player_update")
