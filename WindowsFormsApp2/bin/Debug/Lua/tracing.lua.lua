g_quest_info = nil
g_faders = {}
g_mouse_in = false
tracing_pos = {}
g_disable_fader = false
local ui_tab = ui_widget.ui_tab
local ui_text_list = ui_widget.ui_text_list
g_quest_tab_btn = nil
g_dungeon_tab_btn = nil
g_areaquest_tab_btn = nil
g_randevent_tab_btn = nil
g_knightevent_tab_btn = nil
local quest_untrace_history = {}
function on_tab_btn(btn)
  local idx = btn.var:get("index").v_int
  if idx == 1 then
    update_show()
  elseif idx == 2 then
    update_show_dungeon_info()
  elseif idx == 3 then
    update_show_areaquest_info(0)
  elseif idx == 4 then
    update_show_randevent_info()
  elseif idx == 5 then
    update_show_knightevent_info()
  end
end
function insert_tab(name, idx)
  local btn_uri = "$frame/quest/tracing.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/quest/tracing.xml"
  local page_sty = name
  ui_tab.insert_suit(w_tracing_tab, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_tracing_tab, name)
  btn.var:set("index", idx)
  name = ui.get_text(sys.format("quest|%s", name))
  btn:insert_on_click(on_tab_btn, "ui_quest.ui_tracing.on_tab_btn")
  btn.visible = false
  return btn
end
function insert_tree_item(name)
  local item_uri = "$frame/quest/tracing.xml"
  local item_sty = name
  local root = w_main_tree.root
  local item = root:item_append()
  item.obtain_title:load_style(item_uri, item_sty)
end
function on_config_load(cfg, root)
  quest_cfg_load(root)
end
function on_config_save(cfg, root)
  quest_cfg_save(root)
end
function reset_window_to_default()
  w_tracing_quest.size = ui.point(246, 450)
  w_tracing_quest.dock = "ext_x2y1"
  w_tracing_quest.margin = ui.rect(0, 192, 40, 0)
end
function quest_cfg_load_player()
  local cfg = ui_main.player_cfg_load("tracing.xml")
  local tracing
  if cfg ~= nil then
    tracing = cfg:find("tracing")
    local xnode
    if tracing ~= nil then
      xnode = tracing:get("pos")
      if xnode == nil then
        reset_window_to_default()
        return
      end
      local x = xnode:get_attribute("x")
      local y = xnode:get_attribute("y")
      xnode = tracing:get("expanded")
      local expanded = xnode:get_attribute("value").v_int
      if expanded == 0 then
        set_minus_visible(false)
      end
      xnode = tracing:get("size")
      local dx = xnode:get_attribute("dx").v_int
      local dy = xnode:get_attribute("dy").v_int
      if dy == 0 then
        dy = 410
      end
      w_tracing_quest.size = ui.point(350, dy)
      if not x.empty and not y.empty then
        w_tracing_quest.dock = "ext_x2y1"
        w_tracing_quest.margin = ui.rect(0, y.v_int, x.v_int, 0)
      end
      if x.empty and y.empty then
        w_tracing_quest.dock = "ext_x2y1"
        w_tracing_quest.margin = ui.rect(0, 192, 40, 0)
      end
      if x.v_int == 0 and y.v_int == 0 then
        w_tracing_quest.dock = "ext_x2y1"
        w_tracing_quest.margin = ui.rect(0, 192, 40, 0)
      end
    else
      reset_window_to_default()
    end
    local untraces = cfg:find("quest_untraces")
    if untraces == nil then
      return
    end
    if untraces.size == 0 then
      return
    end
    for i = 0, untraces.size - 1 do
      local v = untraces:get(i)
      local n = v:get_attribute("value")
      if not n.empty and n.v_int ~= 0 then
        quest_untrace_history[n.v_int] = true
      end
    end
  else
    reset_window_to_default()
    return
  end
end
function reset_window_to_default()
  w_tracing_quest.size = ui.point(350, 450)
  w_tracing_quest.dock = "ext_x2y1"
  w_tracing_quest.margin = ui.rect(0, 192, 40, 0)
end
function quest_cfg_load(r)
  quest_cfg_load_player()
  local root = ui_main.player_cfg_load("chat.xml")
  if root == nil then
    return
  end
  local untraces = root:find("quest_untraces")
  if untraces == nil then
    return
  end
  if untraces.size == 0 then
    return
  end
  for i = 0, untraces.size - 1 do
    local v = untraces:get(i)
    local n = v:get_attribute("value")
    if not n.empty and n.v_int ~= 0 then
      quest_untrace_history[n.v_int] = true
    end
  end
  ui_main.player_cfg_save(root, "chat.xml")
end
function quest_cfg_save_player()
  local root = ui_main.player_cfg_load("tracing.xml")
  local tracing
  if root == nil then
    root = sys.xnode()
  end
  local tracing = root:get("tracing")
  tracing:clear()
  local pos = tracing:add("pos")
  local relative_dx = g_bk_size.x - w_tracing_quest.x - w_tracing_quest.dx
  local relative_dy = w_tracing_quest.y
  pos:set_attribute("x", relative_dx)
  pos:set_attribute("y", relative_dy)
  local expanded = tracing:add("expanded")
  if w_tracing_tab_p.visible then
    expanded:set_attribute("value", 1)
  else
    expanded:set_attribute("value", 0)
  end
  local size = tracing:add("size")
  size:set_attribute("dx", w_tracing_quest.dx)
  size:set_attribute("dy", w_tracing_quest.dy)
  ui_main.player_cfg_save(root, "tracing.xml")
end
function quest_cfg_save(r)
  quest_cfg_save_player()
end
function item_faders_remove(excel_id)
  for i, v in ipairs(g_faders) do
    if v.excel_id == excel_id then
      table.remove(g_faders, i)
    end
  end
end
function on_device_reset()
  function do_update()
    local size = w_tracing_list.item_count
    if size == 0 then
      return
    end
    for i = 0, size - 1 do
      local item = w_tracing_list:item_get(i)
      item.size = ui.point(213, 8)
      local excel_id = item.var:get("excel_id").v_int
      local quest_info = ui.tracing_find(excel_id)
      if quest_info ~= nil then
        local aim_box = item:search("aim_box")
        aim_box.parent:tune_y("aim_box")
        local aim_box_1 = item:search("aim_box_1")
        aim_box_1.parent:tune_y("aim_box_1")
        local m_aim_box = item:search("m_aim_box")
        m_aim_box.parent:tune_y("m_aim_box")
        local m_aim_box_1 = item:search("m_aim_box_1")
        local m_list_view = item:search("m_list_view")
        local m_excel = bo2.gv_milestone_list:find(quest_info.mstone_id)
        if m_excel ~= nil then
          local req_quest_list = m_excel.req_quest_list
          if req_quest_list.size ~= 0 then
            m_list_view.parent:tune_y("m_list_view")
          else
            m_aim_box_1.parent:tune_y("m_aim_box_1")
          end
        end
        if quest_info.mstone_id ~= 0 then
          aim_box_1.parent.visible = false
          item.dy = m_aim_box_1.parent.dy + aim_box.parent.dy + m_aim_box.parent.dy
          if sys.check(m_excel) and m_excel.req_quest_list.size ~= 0 then
            item.dy = item.dy + m_list_view.parent.dy
          end
        else
          m_aim_box.parent.dy = 0
          m_aim_box_1.parent.dy = 0
          aim_box_1.parent.visible = true
          item.dy = aim_box_1.parent.dy + aim_box.parent.dy
        end
      end
    end
  end
  w_tracing_list:insert_post_invoke(do_update, "ui_quest.ui_quest_tracing.on_device_reset")
end
g_bk_size = {x = 1024, y = 768}
function on_tracing_reload(rect)
  local x = ui_phase.w_main.size.x
  local y = ui_phase.w_main.size.y
  if x > g_bk_size.x and w_tracing_quest.x > g_bk_size.x * 0.5 then
    w_tracing_quest.x = w_tracing_quest.x + (x - g_bk_size.x)
  end
  if x < g_bk_size.x and w_tracing_quest.x > g_bk_size.x * 0.5 then
    w_tracing_quest.x = w_tracing_quest.x - (g_bk_size.x - x)
  end
  if y > g_bk_size.y and w_tracing_quest.y > g_bk_size.y * 0.5 then
    w_tracing_quest.y = w_tracing_quest.y + (y - g_bk_size.y)
  end
  if y < g_bk_size.y and w_tracing_quest.y > g_bk_size.y * 0.5 then
    w_tracing_quest.y = w_tracing_quest.y - (g_bk_size.y - y)
  end
  g_bk_size.x = x
  g_bk_size.y = y
  on_device_reset()
end
function on_init()
  g_quest_tab_btn = insert_tab("tab_quest_tracing", 1)
  g_dungeon_tab_btn = insert_tab("tab_copy_info", 2)
  g_areaquest_tab_btn = insert_tab("tab_areaquest_info", 3)
  g_randevent_tab_btn = insert_tab("tab_rand_event_info", 4)
  g_knightevent_tab_btn = insert_tab("tab_knight_event_info", 5)
  ui_tab.show_page(w_tracing_tab, "tab_quest_tracing", true)
  g_faders = {
    {excel_id = -1000, fader = w_slider_fader},
    {excel_id = -1000, fader = w_bg_fader},
    {excel_id = -1000, fader = w_zoomer_fader},
    {excel_id = -1000, fader = w_title_fader},
    {excel_id = -1000, fader = w_drag_icon}
  }
  for i, v in ipairs(g_faders) do
    v.fader:reset(1, 0, 3000)
  end
  g_bk_size.x = ui_phase.w_main.dx
  g_bk_size.y = ui_phase.w_main.dy
  ui_phase.w_main:insert_on_move(on_tracing_reload, "ui_quest.ui_tracing.on_tracing_reload")
  w_tracing_list:insert_on_device_reset(on_device_reset, "ui_quest.ui_tracing.on_device_reset")
end
function set_fader_visible(b)
  for i, v in ipairs(g_faders) do
    if b then
      if v.fader.alpha_enter ~= 0 then
        v.fader:reset(v.fader.alpha, 1, 1000)
      else
        v.fader:reset(0, 1, 1000)
      end
    elseif v.fader.alpha_enter ~= 1 then
      v.fader:reset(v.fader.alpha, 0, 1000)
    else
      v.fader:reset(1, 0, 1000)
    end
  end
end
function set_fader_alpha(alpha)
  for i, v in ipairs(g_faders) do
    v.fader.alpha = alpha
  end
end
function update_show()
  local total = ui.quest_get_size()
  local cur = ui.tracing_get_size()
end
function on_open_daily_quest()
  ui_dailyquest.gx_window.visible = not ui_dailyquest.gx_window.visible
end
function on_click_daily_quest()
  quest_daily_panel.visible = not quest_daily_panel.visible
  local btn_plus = w_daily_tracing:search("btn_daily"):search("name_plus")
  local btn_minus = w_daily_tracing:search("btn_daily"):search("name_minus")
  btn_plus.visible = not btn_plus.visible
  btn_minus.visible = not btn_minus.visible
  local btn = w_daily_tracing:search("btn_daily")
  if quest_daily_panel.visible then
    w_daily_tracing.dy = quest_daily_panel.dy + 34
  else
    w_daily_tracing.dy = 34
  end
  w_quest_tracing.y = w_daily_tracing.dy
  w_quest_tracing.dy = w_tracing_panel.dy - w_daily_tracing.dy
end
function on_click_tracing_quest()
  quest_tracing_panel.visible = not quest_tracing_panel.visible
  local btn_plus = w_quest_tracing:search("btn_quest"):search("name_plus")
  local btn_minus = w_quest_tracing:search("btn_quest"):search("name_minus")
  btn_plus.visible = not btn_plus.visible
  btn_minus.visible = not btn_minus.visible
  w_slider_fader.visible = not w_slider_fader.visible
end
function update_show_dungeon_info()
end
function set_disable_fader(bDisable)
  g_disable_fader = bDisable
end
function on_timer(timer)
  if g_disable_fader == true then
    set_fader_alpha(1)
    return
  end
  local c = ui_quest.ui_tracing.w_tracing_quest:test_mouse_in()
  if g_mouse_in == true then
    if c then
      g_mouse_in = false
      set_fader_visible(true)
    end
  elseif not c then
    g_mouse_in = true
    set_fader_visible(false)
  end
end
function on_wheel_timer(timer)
  if not w_slider_fader.visible then
    return
  end
end
function get_aim_text(quest_info, i)
  if quest_info == nil then
    return nil
  end
  local all_text = ""
  local excel = quest_info.excel
  local obj = bo2.gv_quest_object:find(excel.req_obj[i])
  if obj == nil then
    return nil
  end
  local name1 = obj.name
  local name_repute = ui_quest.get_repute_req_name(excel.req_obj[i])
  name1 = name1 .. name_repute
  local obj_list = ui.quest_get_qobj_excel(excel.req_obj[i], excel.req_id[i])
  local name2 = ""
  if obj_list ~= nil then
    name2 = obj_list.name
  end
  if excel.req_obj[i] == bo2.eQuestObj_CompleteMilestones then
    name2 = ui.get_text("quest|milestone_step")
  end
  local cur_num = quest_info.comp[i]
  local total_num = ui_quest.get_aim_max_num(excel.req_obj[i], excel, i, false)
  cur_num = ui_quest.reset_value(excel.req_obj[i], cur_num, total_num)
  local marks = excel.req_obj_marks
  if i < marks.size and marks[i] > 0 then
    all_text = sys.format("<c+:FFBEA232>%s<c-><c+:FF279DE9><mark:%d><c-> <c+:FFBEA232>%d/%d<c->", name1, marks[i], cur_num, total_num)
  else
    all_text = sys.format("<c+:FFBEA232>%s%s %d/%d<c->", name1, name2, cur_num, total_num)
  end
  local agency = bo2.gv_quest_agency:find(excel.id)
  if agency == nil then
    return all_text
  end
  local tip
  if i == 0 then
    tip = agency.agency_1
  elseif i == 1 then
    tip = agency.agency_2
  elseif i == 2 then
    tip = agency.agency_3
  elseif i == 3 then
    tip = agency.agency_4
  end
  if tip == nil or tip == L("") then
    return all_text
  end
  all_text = sys.format([[
%s
%s]], all_text, tip)
  return all_text
end
function get_mstone_aim_text(quest_info)
  if quest_info == nil then
    return nil
  end
  local all_text = ""
  local excel = bo2.gv_milestone_list:find(quest_info.mstone_id)
  local obj = bo2.gv_quest_object:find(excel.req_obj)
  local obj_list = ui.quest_get_qobj_excel(excel.req_obj, excel.req_id)
  local name1 = ""
  local name2 = ""
  if obj ~= nil then
    name1 = obj.name
    local name_repute = ui_quest.get_repute_req_name(excel.req_obj)
    name1 = name1 .. name_repute
  end
  if obj_list ~= nil then
    name2 = obj_list.name
  end
  comp = quest_info.mstone_comp
  local total_num = ui_quest.get_aim_max_num(excel.req_obj, excel, 0, true)
  comp = ui_quest.reset_value(excel.req_obj, comp, total_num)
  local mark = excel.obj_mark
  if mark > 0 then
    local mark2 = excel.obj_mark2
    all_text = sys.format("<c+:FFFFFFFF>%s<c-><c+:FF279DE9><mark:%d,,%d><c-> <c+:FFBEA232>%d/%d<c->", name1, mark, mark2, comp, total_num)
  elseif obj ~= nil and obj_list ~= nil then
    all_text = sys.format("<c+:FFFFFFFF>%s%s %d/%d<c->", name1, name2, comp, total_num)
  else
    all_text = sys.format("<c+:FFFFFFFF>%s<c->", excel.brief)
  end
  local agency = bo2.gv_milestone_agency:find(excel.id)
  if agency == nil then
    return all_text
  end
  local tip = agency.agency
  if tip == nil or tip == L("") then
    return all_text
  end
  all_text = sys.format([[
%s
%s]], all_text, tip)
  return all_text
end
function on_show_quest_mouse(btn, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    local item = btn.parent
    local id = item.var:get("excel_id").v_int
    local mstone_id = item.var:get("mstone_id").v_int
    ui_quest.ui_mission.show_quest_id(id, mstone_id)
  elseif msg == ui.mouse_enter then
    btn.color = ui.make_color("66ffff")
    ui_handson_teach.test_complate_trace_to_questui(true)
  elseif msg == ui.mouse_leave then
    btn.color = L("00ffffff")
  end
end
function insert_sub_item(list, quest_info, quest_id)
  if list == nil then
    return
  end
  local item_file = L("$frame/quest/tracing.xml")
  local item_style = L("sub_item")
  local item = list:item_insert(0)
  item:load_style(item_file, item_style)
  item.size = ui.point(213, 8)
  list.scroll = 0
  if quest_info ~= nil then
    local all_text = L("")
    local excel = quest_info.excel
    item.var:set("mstone_id", quest_info.mstone_id)
    item.var:set("excel_id", excel.id)
    local aim_box = item:search("aim_box")
    local q_type = ui_quest.get_quest_type(excel)
    local q_state = ui.get_text("quest|tracing_going")
    local q_d, q_c = ui_quest.get_quest_difficulty(excel.difficulty)
    ui_quest.box_insert_text(aim_box, sys.format("<c+:%s>%s%s%s<c->", q_c, q_d, q_state, excel.name))
    aim_box.parent:tune_y("aim_box")
    local aim_box_1 = item:search("aim_box_1")
    local m_aim_box = item:search("m_aim_box")
    local m_aim_box_1 = item:search("m_aim_box_1")
    for i = 0, 3 do
      if excel.req_obj[i] ~= 0 and excel.req_id[i] ~= 0 then
        local aim_text = get_aim_text(quest_info, i)
        if aim_text ~= nil then
          if i == 0 then
            all_text = sys.format("%s", aim_text)
          else
            all_text = sys.format([[
%s
%s]], all_text, aim_text)
          end
        end
      end
    end
    ui_quest.box_insert_text(aim_box_1, all_text)
    aim_box_1.parent:tune_y("aim_box_1")
    local m_excel = bo2.gv_milestone_list:find(quest_info.mstone_id)
    if m_excel ~= nil then
      local m_d, m_c = ui_quest.get_quest_difficulty(m_excel.difficulty)
      ui_quest.box_insert_text(m_aim_box, sys.format("<img:$image/quest/icons.png|18,108,20,20*16,16><c+:%s>%s%s<c->", m_c, m_d, m_excel.name))
      m_aim_box.parent:tune_y("m_aim_box")
      local aim_text_m = get_mstone_aim_text(quest_info, all_text)
      ui_quest.box_insert_text(m_aim_box_1, aim_text_m)
      m_aim_box_1.parent:tune_y("m_aim_box_1")
    end
    if quest_info.mstone_id ~= 0 then
      aim_box_1.parent.visible = false
      item.dy = m_aim_box_1.parent.dy + aim_box.parent.dy + m_aim_box.parent.dy
    else
      m_aim_box.parent.dy = 0
      m_aim_box_1.parent.dy = 0
      aim_box_1.parent.visible = true
      item.dy = aim_box_1.parent.dy + aim_box.parent.dy
    end
    update_show()
    if quest_info.completed then
      quest_complete(item, quest_info)
    end
  else
    local all_text = L("")
    local excel = bo2.gv_quest_list:find(quest_id)
    if excel == nil then
      return
    end
    local q_state = L("")
    if excel.cooldown ~= 0 then
      if bo2.is_cooldown_over(excel.cooldown) then
        q_state = ui.get_text("quest|tracing_can")
      else
        q_state = ui.get_text("quest|tracing_cooldown")
      end
    else
      local q_info = ui.quest_find_c(excel.id)
      if q_info then
        q_state = ui.get_text("quest|tracing_finish")
      else
        q_state = ui.get_text("quest|tracing_can")
      end
    end
    item.var:set("mstone_id", 0)
    item.var:set("excel_id", excel.id)
    local aim_box = item:search("aim_box")
    local q_type = ui_quest.get_quest_type(excel)
    local q_d, q_c = ui_quest.get_quest_difficulty(excel.difficulty)
    ui_quest.box_insert_text(aim_box, sys.format("<c+:%s>%s%s%s<c->", q_c, q_d, q_state, excel.name))
    aim_box.parent:tune_y("aim_box")
    local aim_box_1 = item:search("aim_box_1")
    local v = sys.variant()
    v:set("n", excel.gps_target_id)
    local n = bo2.gv_mark_list:find(excel.gps_target_id)
    all_text = ui.get_text("quest|commend_quest_gps")
    all_text = sys.mtf_merge(v, all_text)
    all_text = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, all_text)
    ui_quest.box_insert_text(aim_box_1, all_text)
    aim_box_1.parent:tune_y("aim_box_1")
    item.dy = aim_box.parent.dy + aim_box_1.parent.dy
  end
end
function insert_item(quest_info)
  local all_text = ""
  local item_file = L("$frame/quest/tracing.xml")
  local item_style = L("item")
  local item = w_tracing_list:item_insert(0)
  item:load_style(item_file, item_style)
  item.size = ui.point(213, 8)
  local excel = bo2.gv_quest_list:find(quest_info.excel_id)
  w_tracing_list.scroll = 0
  item.var:set("excel_id", quest_info.excel_id)
  item.var:set("mstone_id", quest_info.mstone_id)
  local aim_box = item:search("aim_box")
  local q_type = ui_quest.get_quest_type(excel)
  local q_d, q_c = ui_quest.get_quest_difficulty(excel.difficulty)
  ui_quest.box_insert_text(aim_box, sys.format("<c+:%s>%s%s%s<c->", q_c, q_d, q_type, excel.name))
  aim_box.parent:tune_y("aim_box")
  local aim_box_1 = item:search("aim_box_1")
  local m_aim_box = item:search("m_aim_box")
  local m_aim_box_1 = item:search("m_aim_box_1")
  local m_list_view = item:search("m_list_view")
  for i = 0, 3 do
    if excel.req_obj[i] ~= 0 and excel.req_id[i] ~= 0 then
      local aim_text = get_aim_text(quest_info, i)
      if aim_text ~= nil then
        if i == 0 then
          all_text = sys.format("%s", aim_text)
        else
          all_text = sys.format([[
%s
%s]], all_text, aim_text)
        end
      end
    end
  end
  ui_quest.box_insert_text(aim_box_1, all_text)
  aim_box_1.parent:tune_y("aim_box_1")
  local m_excel = bo2.gv_milestone_list:find(quest_info.mstone_id)
  if m_excel ~= nil then
    local m_d, m_c = ui_quest.get_quest_difficulty(m_excel.difficulty)
    ui_quest.box_insert_text(m_aim_box, sys.format("<img:$image/quest/icons.png|18,108,20,20*16,16><c+:%s>%s%s<c->", m_c, m_d, m_excel.name))
    m_aim_box.parent:tune_y("m_aim_box")
    local aim_text_m = get_mstone_aim_text(quest_info, all_text)
    ui_quest.box_insert_text(m_aim_box_1, aim_text_m)
    m_aim_box_1.parent:tune_y("m_aim_box_1")
    local req_quest_list = m_excel.req_quest_list
    if req_quest_list.size ~= 0 then
      local excel = quest_info.excel
      for i = 0, req_quest_list.size - 1 do
        local info = ui.quest_find(req_quest_list[i])
        local q_finish = ui.quest_find_c(req_quest_list[i])
        if not q_finish then
          insert_sub_item(m_list_view, info, req_quest_list[i])
          m_list_view.parent:tune_y("m_list_view")
        end
      end
    end
  end
  if quest_info.mstone_id ~= 0 then
    aim_box_1.parent.visible = false
    item.dy = m_aim_box_1.parent.dy + aim_box.parent.dy + m_aim_box.parent.dy
    if m_excel.req_quest_list.size ~= 0 then
      item.dy = item.dy + m_list_view.parent.dy
    end
  else
    m_aim_box.parent.dy = 0
    m_aim_box_1.parent.dy = 0
    aim_box_1.parent.visible = true
    item.dy = aim_box_1.parent.dy + aim_box.parent.dy
  end
  update_show()
  local close_fader = item:search("close_fader")
  if w_bg_fader.alpha_enter == 0 then
    close_fader:reset(1, w_bg_fader.alpha_leave, 500)
  else
    close_fader:reset(w_bg_fader.alpha_enter, 0, 500)
  end
  local i_fader = {
    excel_id = quest_info.excel_id,
    fader = close_fader
  }
  table.insert(g_faders, i_fader)
  if quest_info.completed then
    quest_complete(item, quest_info)
  end
end
function remove_tracing_has_mstone(quest_info)
  if quest_info == nil then
    return
  end
  local excel_id = quest_info.excel_id
  local size = w_tracing_list.item_count
  for i = 0, size - 1 do
    local item = w_tracing_list:item_get(i)
    if item ~= nil then
      local id = item.var:get("excel_id").v_int
      if id == excel_id then
        w_tracing_list:item_remove(i)
        item_faders_remove(excel_id)
      end
    end
  end
  update_show()
end
function remove_quest_item(quest_info)
  if quest_info == nil then
    return
  end
  local excel_id = quest_info.excel_id
  local size = w_tracing_list.item_count
  local excel = quest_info.excel
  if excel.mstone_req ~= 0 and ui.has_this_mstone(excel.mstone_req) then
    local id = 0
    local item
    local parent_quest_id = ui.get_parent_quest(excel.mstone_req)
    for i = 0, size - 1 do
      item = w_tracing_list:item_get(i)
      if item ~= nil then
        id = item.var:get("excel_id").v_int
        if id == parent_quest_id then
          break
        end
      end
    end
    if id == parent_quest_id then
      local m_list_view = item:search("m_list_view")
      local sub_size = m_list_view.item_count
      for j = 0, sub_size - 1 do
        local sub_item = m_list_view:item_get(j)
        if sub_item ~= nil then
          local sub_id = sub_item.var:get("excel_id").v_int
          if sub_id == excel_id then
            local item_dy = item.dy - m_list_view.parent.dy
            m_list_view:item_remove(j)
            item_faders_remove(excel_id)
            if excel.cooldown ~= 0 then
              insert_sub_item(m_list_view, info, excel_id)
            else
              insert_sub_item(m_list_view, info, excel_id)
            end
            m_list_view.parent:tune_y("m_list_view")
            local list_dy = m_list_view.parent.dy
            item.dy = item_dy + list_dy
            break
          end
        end
      end
      item.parent:tune_y("m_list_view")
    end
  else
    for i = 0, size - 1 do
      local item = w_tracing_list:item_get(i)
      if item ~= nil then
        local id = item.var:get("excel_id").v_int
        if id == excel_id then
          w_tracing_list:item_remove(i)
          item_faders_remove(excel_id)
        end
      end
    end
  end
  update_show()
end
function remove_quest_item_fake(id)
  local size = w_tracing_list.item_count
  for i = 0, size - 1 do
    local item = w_tracing_list:item_get(i)
    if id == item.var:get("excel_id").v_int then
      if item.index == 0 then
        return false
      end
      w_tracing_list:item_remove(i)
      item_faders_remove(id)
      return true
    end
  end
  return false
end
function test_remove()
  w_tracing_list:item_remove(0)
end
function quest_complete(item, quest_info)
  if quest_info == nil then
    return
  end
  w_tracing_list.scroll = 0
  local aim_box_1 = item:search("aim_box_1")
  local aim_box = item:search("aim_box")
  local m_aim_box = item:search("m_aim_box")
  local m_aim_box_1 = item:search("m_aim_box_1")
  aim_box_1:item_clear()
  local excel = quest_info.excel
  local mark = excel.end_obj_mark
  local obj = ui.quest_get_qobj_excel(excel.end_obj, excel.end_id)
  if obj == nil then
    if mark <= 0 then
      local text = ui.get_text("quest|complete_msg")
      local content = sys.mtf_merge(v, text)
      if quest_info.comp1 >= excel.req_min[0] and excel.req_max[0] > excel.req_min[0] and excel.req_max[0] ~= 65535 then
        local aim_ex = sys.format("%s", get_aim_text(quest_info, 0))
        content = sys.format([[
%s
%s]], content, aim_ex)
      end
      content = sys.format("<img:$image/quest/icons.png|0,108,16,16*16,16><c-> %s", content)
      ui_quest.box_insert_text(aim_box_1, content)
      aim_box_1.parent:tune_y("aim_box_1")
      item.dy = aim_box_1.parent.dy + m_aim_box_1.parent.dy + aim_box.parent.dy + m_aim_box.parent.dy
    end
    return
  end
  local text = ui.get_text("quest|master_quest_complete")
  local v = sys.variant()
  if mark <= 0 then
    v:set("cha_name", obj.name)
    local content = sys.mtf_merge(v, text)
    if quest_info.comp1 >= excel.req_min[0] and excel.req_max[0] > excel.req_min[0] and excel.req_max[0] ~= 65535 then
      local aim_ex = sys.format("%s", get_aim_text(quest_info, 0))
      content = sys.format([[
%s
%s]], content, aim_ex)
    end
    content = sys.format("<img:$image/quest/icons.png|0,108,16,16*16,16><c-> %s", content)
    ui_quest.box_insert_text(aim_box_1, content)
  else
    local cha_name = sys.format("<c+:FF279DE9><mark:%d><c->", mark)
    local n = bo2.gv_mark_list:find(mark)
    v:set("cha_name", cha_name)
    local content = sys.mtf_merge(v, text)
    if quest_info.comp1 >= excel.req_min[0] and excel.req_max[0] > excel.req_min[0] and excel.req_max[0] ~= 65535 then
      local aim_ex = sys.format("%s", get_aim_text(quest_info, 0))
      content = sys.format([[
%s
%s]], content, aim_ex)
    end
    content = sys.format("<img:$image/quest/icons.png|0,108,16,16*16,16><c-> <c+:FF808080>%s", content)
    ui_quest.box_insert_text(aim_box_1, content)
  end
  aim_box_1.parent:tune_y("aim_box_1")
  item.dy = aim_box_1.parent.dy + m_aim_box_1.parent.dy + aim_box.parent.dy + m_aim_box.parent.dy
end
function update_aim(item, quest_info, new_mstone)
  w_tracing_list.scroll = 0
  local aim_box = item:search("aim_box")
  aim_box:item_clear()
  local aim_box_1 = item:search("aim_box_1")
  aim_box_1:item_clear()
  local m_aim_box = item:search("m_aim_box")
  m_aim_box:item_clear()
  local m_list_view = item:search("m_list_view")
  m_list_view:item_clear()
  local m_aim_box_1 = item:search("m_aim_box_1")
  m_aim_box_1:item_clear()
  local excel = quest_info.excel
  local size = 0
  local all_text = ""
  if excel == nil then
    return
  end
  local q_d, q_c = ui_quest.get_quest_difficulty(excel.difficulty)
  local q_type = ui_quest.get_quest_type(excel)
  ui_quest.box_insert_text(aim_box, sys.format("<c+:%s>%s%s%s<c->", q_c, q_d, q_type, excel.name))
  aim_box.parent:tune_y("aim_box")
  for i = 0, 3 do
    if excel.req_obj[i] ~= 0 and excel.req_id[i] ~= 0 then
      local aim_text = get_aim_text(quest_info, i)
      if aim_text ~= nil then
        if i == 0 then
          all_text = sys.format("%s", aim_text)
        else
          all_text = sys.format([[
%s
%s]], all_text, aim_text)
        end
      end
    end
  end
  ui_quest.box_insert_text(aim_box_1, all_text)
  aim_box_1.parent:tune_y("aim_box_1")
  item.var:set("mstone_id", quest_info.mstone_id)
  local m_excel = bo2.gv_milestone_list:find(quest_info.mstone_id)
  if m_excel == nil then
    m_aim_box.parent.dy = 0
    m_aim_box_1.parent.dy = 0
    aim_box_1.parent.visible = true
    m_aim_box.parent.visible = false
    m_aim_box_1.parent.visible = false
    item.dy = aim_box.parent.dy + aim_box_1.parent.dy
    return
  end
  local m_d, m_c = ui_quest.get_quest_difficulty(m_excel.difficulty)
  ui_quest.box_insert_text(m_aim_box, sys.format("<img:$image/quest/icons.png|18,108,20,20*16,16><c+:%s>%s%s<c->", m_c, m_d, m_excel.name))
  m_aim_box.parent:tune_y("m_aim_box")
  local aim_text_m = get_mstone_aim_text(quest_info)
  ui_quest.box_insert_text(m_aim_box_1, aim_text_m)
  m_aim_box_1.parent:tune_y("m_aim_box_1")
  if m_excel ~= nil then
    local req_quest_list = m_excel.req_quest_list
    if req_quest_list.size ~= 0 then
      local excel = quest_info.excel
      for i = 0, req_quest_list.size - 1 do
        local info = ui.quest_find(req_quest_list[i])
        local q_finish = ui.quest_find_c(req_quest_list[i])
        if not q_finish then
          insert_sub_item(m_list_view, info, req_quest_list[i])
          m_list_view.parent:tune_y("m_list_view")
        end
      end
    end
  end
  if quest_info.mstone_id ~= 0 then
    aim_box_1.parent.visible = false
    item.dy = m_aim_box_1.parent.dy + aim_box.parent.dy + m_aim_box.parent.dy
    if m_excel.req_quest_list.size ~= 0 then
      item.dy = item.dy + m_list_view.parent.dy
    end
  else
    m_aim_box.parent.dy = 0
    m_aim_box_1.parent.dy = 0
    aim_box_1.parent.visible = true
    item.dy = aim_box_1.parent.dy + aim_box.parent.dy
  end
  local size = w_tracing_list.item_count
  for i = 0, size - 1 do
    local item = w_tracing_list:item_get(i)
    local id = item.var:get("excel_id").v_int
    if id == excel_id then
      update_aim(item, quest_info, false)
      if quest_info.completed then
        quest_complete(item, quest_info)
      end
      item.index = 0
    end
    local sub_list = item:search("m_list_view")
    local sub_size = sub_list.item_count
    for j = 0, sub_list.item_count - 1 do
      local sub_item = sub_list:item_get(j)
      local sub_id = sub_item.var:get("excel_id").v_int
      if sub_id == excel_id then
        local info = ui.quest_find(id)
        update_aim(item, info, false)
        item.index = 0
      end
    end
  end
end
function update_tracing(quest_info)
  if quest_info == nil then
    return
  end
  local excel_id = quest_info.excel_id
  local size = w_tracing_list.item_count
  for i = 0, size - 1 do
    local item = w_tracing_list:item_get(i)
    local id = item.var:get("excel_id").v_int
    if id == excel_id then
      update_aim(item, quest_info)
      if quest_info.completed then
        quest_complete(item, quest_info)
      end
      item.index = 0
    end
    local sub_list = item:search("m_list_view")
    local sub_size = sub_list.item_count
    for j = 0, sub_list.item_count - 1 do
      local sub_item = sub_list:item_get(j)
      local sub_id = sub_item.var:get("excel_id").v_int
      if sub_id == excel_id then
        local info = ui.quest_find(id)
        update_aim(item, info)
        item.index = 0
      end
    end
  end
end
function on_delete_tracing(btn)
  local parent = btn.parent.parent
  local excel_id = parent.var:get("excel_id").v_int
  ui.tracing_quest_remove(excel_id)
  ui_quest.ui_mission.update_tracing(excel_id, false)
end
function on_close()
  set_visible(false)
end
c_chg_value = 220
m_chg_value = 0
backup_size = nil
function on_toggle_click_minus(btn)
  w_tracing_tab_p.visible = false
  w_plus.visible = true
  w_drag_icon.visible = false
  if sys.check(ui_handson_teach.quest_tracing_aim_box1) ~= false then
    ui_handson_teach.quest_tracing_aim_box1.visible = false
  end
  bo2.PlaySound2D(585)
end
function set_minus_visible(vis)
  if vis then
    w_tracing_tab_p.visible = true
    w_plus.visible = false
  else
    w_tracing_tab_p.visible = false
    w_plus.visible = true
  end
end
function on_toggle_click_plus(btn)
  if backup_size == nil then
    backup_size = ui.point(350, 300)
  end
  w_tracing_tab_p.visible = true
  w_drag_icon.visible = true
  w_plus.visible = false
  bo2.PlaySound2D(584)
end
function set_visible(vis)
  local w = ui.find_control("$frame:tracing_quest")
  w.visible = vis
end
function on_close_runtime_info()
  on_vis_dungeon_table_btn(g_quest_tab_btn, false)
  on_vis_dungeon_table_btn(g_dungeon_tab_btn, false)
  ui_tab.show_page(w_tracing_tab, "tab_quest_tracing", true)
  update_show()
  panel_runtime_info.visible = false
end
function on_show_dungeon_runtime_info()
  on_vis_dungeon_table_btn(g_quest_tab_btn, true)
  on_vis_dungeon_table_btn(g_dungeon_tab_btn, true)
  ui_tab.show_page(w_tracing_tab, "tab_copy_info", true)
  update_show_dungeon_info()
  panel_runtime_info.visible = true
end
function on_vis_dungeon_table_btn(btn, vis)
  if sys.check(btn) ~= false then
    btn.visible = vis
  end
end
function update_show_areaquest_info(areaquest_id)
  if areaquest_id == 0 then
    local player = bo2.player
    local area_excelID = player:get_atb(bo2.eAtb_AreaID)
    local mb = bo2.gv_area_list
    areaquest_id = mb:find(area_excelID).areaquest_area
    if areaquest_id == nil then
      return
    end
  end
end
function on_close_areaquest_info()
  on_vis_dungeon_table_btn(g_quest_tab_btn, false)
  on_vis_dungeon_table_btn(g_areaquest_tab_btn, false)
  ui_tab.show_page(w_tracing_tab, "tab_quest_tracing", true)
  update_show()
  areaquest_info.visible = false
end
function on_show_areaquest_info(questID)
  on_vis_dungeon_table_btn(g_quest_tab_btn, true)
  on_vis_dungeon_table_btn(g_areaquest_tab_btn, true)
  ui_tab.show_page(w_tracing_tab, "tab_areaquest_info", true)
  update_show_areaquest_info(questID)
  areaquest_info.visible = true
end
function on_click_tab_btn(btn)
  if btn == g_quest_tab_btn then
    ui_handson_teach.test_complate_scn_teach(true)
    ui_handson_teach.test_complate_areaquest_teach(true)
  end
end
function on_quest_trace_history_add()
  local total = ui.quest_get_size()
  for i = 0, total - 1 do
    local quest_info = ui.quest_get_by_idx(i)
    if quest_untrace_history[quest_info.excel_id] ~= true then
      ui.tracing_quest_insert(quest_info)
      ui_quest.ui_mission.update_tracing(quest_info.excel_id, true)
    end
  end
  quest_untrace_history = {}
  local level = bo2.player:get_atb(bo2.eAtb_Level)
  if level >= 30 and w_daily_tracing ~= nil then
    w_daily_tracing.visible = true
    w_daily_tracing.dy = 34
    quest_daily_panel.dy = 0
    local begin32 = bo2.ePlayerFlagInt32_DailyQuestBegin
    local end32 = bo2.ePlayerFlagInt32_DailyQuestEnd
    for j = begin32, end32 do
      local q_id = bo2.player:get_flag_int32(j)
      insert_daily_item(q_id, j - begin32)
    end
    quest_daily_panel.visible = true
    quest_tracing_panel.visible = true
    w_quest_tracing.dy = w_tracing_panel.dy - w_daily_tracing.dy
  else
    w_quest_tracing.dy = w_tracing_panel.dy
  end
end
function on_check_target_item(target)
  if target.parent.color == ui.make_color("66ffff") then
    return true
  else
    return false
  end
end
local randevent_backup_dy
function on_show_randevent_info()
  on_vis_dungeon_table_btn(g_quest_tab_btn, true)
  on_vis_dungeon_table_btn(g_randevent_tab_btn, true)
  randevent_backup_dy = w_tracing_quest.dy
  w_tracing_quest.dy = ui_rand_event.g_event_mgr and 450 or 250
  ui_tab.show_page(w_tracing_tab, "tab_rand_event_info", true)
  update_show_randevent_info()
  panel_rand_event.visible = true
end
function update_show_randevent_info()
end
function on_close_randevent_info()
  on_vis_dungeon_table_btn(g_quest_tab_btn, false)
  on_vis_dungeon_table_btn(g_randevent_tab_btn, false)
  w_tracing_quest.dy = randevent_backup_dy
  ui_tab.show_page(w_tracing_tab, "tab_quest_tracing", true)
  update_show()
  panel_rand_event.visible = false
end
local knightevent_backup_dy
function on_show_knightevent_info()
  on_vis_dungeon_table_btn(g_quest_tab_btn, true)
  on_vis_dungeon_table_btn(g_knightevent_tab_btn, true)
  knightevent_backup_dy = w_tracing_quest.dy
  w_tracing_quest.dy = 250
  ui_tab.show_page(w_tracing_tab, "tab_knight_event_info", true)
  update_show_knightevent_info()
  panel_knight_event.visible = true
end
function update_show_knightevent_info()
end
function on_close_knightevent_info()
  on_vis_dungeon_table_btn(g_quest_tab_btn, false)
  on_vis_dungeon_table_btn(g_knightevent_tab_btn, false)
  w_tracing_quest.dy = knightevent_backup_dy
  ui_tab.show_page(w_tracing_tab, "tab_quest_tracing", true)
  update_show()
  panel_knight_event.visible = false
end
function on_AFK_back()
  local player_level = 0
  local player_scnId = 0
  if sys.check(bo2.player) then
    player_level = bo2.player:get_atb(bo2.eAtb_Level)
  end
  if bo2.scn and bo2.scn.scn_excel then
    player_scnId = bo2.scn.scn_excel.id
  end
  if player_level > 20 or player_scnId ~= 101 then
    return
  end
  ui_chat.show_ui_text_id(73181)
  on_toggle_click_plus()
  if w_tracing_quest.svar.flicker_control == nil then
    local flicker_control = ui.create_control(w_tracing_quest, "panel")
    flicker_control:load_style(L("$gui/frame/help/tool_handson.xml"), L("tool_handson_flicker"))
    flicker_control:move_to_head()
    flicker_control.dock = "fill_xy"
    w_tracing_quest.svar.flicker_control = flicker_control
  end
  local on_tracing_quest_mouse = function(ctrl, msg)
    w_tracing_quest.svar.flicker_control:post_release()
    w_tracing_quest.svar.flicker_control = nil
    w_tracing_quest.mouse_able = false
    w_tracing_quest:remove_on_mouse("ui_quest.ui_tracing.on_tracing_quest_mouse")
  end
  w_tracing_quest.mouse_able = true
  w_tracing_quest:insert_on_mouse(on_tracing_quest_mouse, "ui_quest.ui_tracing.on_tracing_quest_mouse")
end
function on_nextmstone(cmd, data)
  local excel_id = data:get(packet.key.quest_id).v_int
  local mstone_idx = data:get(packet.key.quest_opt).v_int
  local mstone_id = data:get(packet.key.milestone_id).v_int
  local excel = bo2.gv_quest_list:find(excel_id)
  if excel == nil then
    return
  end
  local oldmstone_id = excel.milestones[mstone_idx - 2]
  local oldmstone = bo2.gv_milestone_list:find(oldmstone_id)
  if oldmstone ~= nil then
    local req_quest_list = oldmstone.req_quest_list
    for i = 0, req_quest_list.size - 1 do
      local info = ui.quest_find(req_quest_list[i])
      if info ~= nil then
        insert_item(info)
        update_tracing(info)
      end
    end
  end
  local mstone = bo2.gv_milestone_list:find(mstone_id)
  if mstone ~= nil then
    local req_quest_list = mstone.req_quest_list
    for i = 0, req_quest_list.size - 1 do
      local info = ui.quest_find(req_quest_list[i])
      if info ~= nil then
        remove_tracing_has_mstone(info)
        update_tracing(info)
      end
    end
  end
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_quest.ui_tracing:signal"
reg(packet.eSTC_Fake_AFK_Back, on_AFK_back, sig)
reg(packet.eSTC_UI_NextMilestone, on_nextmstone, sig)
