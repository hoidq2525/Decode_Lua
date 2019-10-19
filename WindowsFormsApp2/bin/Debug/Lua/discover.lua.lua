g_select_id = nil
c_item_size_x = 180
c_item_size_y = 28
c_disable_color = L("FF6C5661")
c_enable_color = L("FFFFFFFF")
c_file_path = L("$gui/image/discover/")
c_progress_max = 439
g_type_max = {}
local desc_text = ui.get_text("discover|desc_text")
function insert_text(view, text)
  ui_text_list.insert_text(view, text)
  view.scroll = 1
end
function on_popo_ack(popo_def, data, duration_time)
  discover_id = data:get(packet.key.milestone_id).v_int
  local excel = bo2.gv_discover_list:find(discover_id)
  local root = w_discover_tree.root
  local item = root:item_get(excel.main_type - 1)
  local child_item = item:item_get(excel.sub_type - 1)
  local c_size = child_item.item_count
  for i = 0, c_size - 1 do
    local grand_item = child_item:item_get(i)
    grand_item:search("select").visible = false
    local excel_id = grand_item.var:get("excel_id").v_int
    if discover_id == excel_id then
      on_item_sel(grand_item, true)
      grand_item.selected = true
      grand_item:scroll_to_visible()
      break
    end
  end
end
function on_discover_init()
  insert_tree_item(bo2.eDiscoverMT_World)
  insert_tree_item(bo2.eDiscoverMT_Monster)
  insert_tree_item(bo2.eDiscoverMT_Other)
  insert_tree_item(bo2.eDiscoverMT_Scn)
  on_title_num_init()
end
function on_title_num_init()
  local root = w_discover_tree.root
  local total_num = 0
  local cur_num = 0
  local excel_size = 0
  local world = root:item_get(bo2.eDiscoverMT_World - 1)
  excel_size = bo2.gv_discover_world.size
  for i = 0, excel_size - 1 do
    local item = world:item_get(i)
    total_num = total_num + item.item_count
    local sub_total = item.item_count
    local sub_cur = 0
    local num = item:search("num")
    num.text = sys.format("(%d/%d)", sub_cur, sub_total)
  end
  local world_num = world:search("num")
  world_num.text = sys.format("(%d/%d)", cur_num, total_num)
  g_type_max[bo2.eDiscoverMT_World] = total_num
  cur_num = 0
  total_num = 0
  local monster = root:item_get(bo2.eDiscoverMT_Monster - 1)
  excel_size = bo2.gv_discover_monster.size
  for i = 0, excel_size - 1 do
    local item = monster:item_get(i)
    total_num = total_num + item.item_count
    local sub_total = item.item_count
    local sub_cur = 0
    local num = item:search("num")
    num.text = sys.format("(%d/%d)", sub_cur, sub_total)
  end
  local monster_num = monster:search("num")
  monster_num.text = sys.format("(%d/%d)", cur_num, total_num)
  g_type_max[bo2.eDiscoverMT_Monster] = total_num
  cur_num = 0
  total_num = 0
  local other = root:item_get(bo2.eDiscoverMT_Other - 1)
  excel_size = bo2.gv_discover_other.size
  for i = 0, excel_size - 1 do
    local item = other:item_get(i)
    total_num = total_num + item.item_count
    local sub_total = item.item_count
    local sub_cur = 0
    local num = item:search("num")
    num.text = sys.format("(%d/%d)", sub_cur, sub_total)
  end
  local other_num = other:search("num")
  other_num.text = sys.format("(%d/%d)", cur_num, total_num)
  g_type_max[bo2.eDiscoverMT_Other] = total_num
  cur_num = 0
  total_num = 0
  local scn = root:item_get(bo2.eDiscoverMT_Scn - 1)
  excel_size = bo2.gv_discover_scn.size
  for i = 0, excel_size - 1 do
    local item = scn:item_get(i)
    total_num = total_num + item.item_count
    local sub_total = item.item_count
    local sub_cur = 0
    local num = item:search("num")
    num.text = sys.format("(%d/%d)", sub_cur, sub_total)
  end
  local scn_num = scn:search("num")
  scn_num.text = sys.format("(%d/%d)", cur_num, total_num)
  g_type_max[bo2.eDiscoverMT_Scn] = total_num
  w_pic.visible = true
  w_pic.image = "$image/discover/tongyong.png"
  w_study.text = ui.get_text("discover|study_disable")
  w_study_progress.dx = 0
end
function insert_tree_item(type)
  local item_uri = "$frame/discover/discover.xml"
  local item_sty = "tree_item"
  local root = w_discover_tree.root
  local item = root:item_append()
  item.obtain_title:load_style(item_uri, item_sty)
  local text
  local list_size = 0
  local list
  if type == bo2.eDiscoverMT_World then
    text = ui.get_text("discover|world")
    list_size = bo2.gv_discover_world.size
    list = bo2.gv_discover_world
  elseif type == bo2.eDiscoverMT_Monster then
    text = ui.get_text("discover|monster")
    list_size = bo2.gv_discover_monster.size
    list = bo2.gv_discover_monster
  elseif type == bo2.eDiscoverMT_Other then
    text = ui.get_text("discover|other")
    list_size = bo2.gv_discover_other.size
    list = bo2.gv_discover_other
  elseif type == bo2.eDiscoverMT_Scn then
    text = ui.get_text("discover|scn")
    list_size = bo2.gv_discover_scn.size
    list = bo2.gv_discover_scn
  end
  local title = item:search("title")
  title.text = text
  for i = 0, list_size - 1 do
    local excel = list:get(i)
    insert_tree_child_item(type, excel)
  end
  local size = bo2.gv_discover_list.size
  for i = 0, size - 1 do
    local excel = bo2.gv_discover_list:get(i)
    if excel.main_type == type then
      insert_tree_grandchild_item(excel)
    end
  end
end
function insert_tree_child_item(type, excel)
  local item_uri = "$frame/discover/discover.xml"
  local item_sty = "tree_child_item"
  local root = w_discover_tree.root
  local item = root:item_get(type - 1)
  local child_item = item:item_append()
  child_item.obtain_title:load_style(item_uri, item_sty)
  child_item.obtain_title.size = ui.point(c_item_size_x, c_item_size_y)
  local title = child_item:search("title")
  title.text = excel.name
  local num = child_item:search("num")
end
function insert_tree_grandchild_item(excel)
  local item_uri = "$frame/discover/discover.xml"
  local item_sty = "tree_grandchild_item"
  local root = w_discover_tree.root
  local item = root:item_get(excel.main_type - 1)
  local child_item = item:item_get(excel.sub_type - 1)
  local grand_item = child_item:item_append()
  grand_item.obtain_title:load_style(item_uri, item_sty)
  grand_item.obtain_title.size = ui.point(c_item_size_x, c_item_size_y)
  local title = grand_item:search("title")
  title.text = excel.name
  local discover_info = ui.discover_find(excel.id)
  if discover_info == nil then
    title.xcolor = c_disable_color
  else
    title.xcolor = c_enable_color
    local study = grand_item:search("study")
    if discover_info.study == -1 then
    end
  end
  grand_item.var:set("excel_id", excel.id)
  grand_item.var:set("study", -100)
  grand_item.display = false
end
function insert_item(text, visible)
  local item_file = L("$frame/discover/content.xml")
  local item_style = L("content_item")
  local item = ui_md.ui_content.w_content_list:item_append()
  item:load_style(item_file, item_style)
  local btn = item:search("btn")
  btn.visible = visible
  local flicker = item:search("flicker")
  flicker.visible = visible
  local box = item:search("box")
  box:item_clear()
  ui_md.box_insert_text(box, text)
  box.parent:tune_y("box")
end
function update_content(data)
  local excel = bo2.gv_discover_list:find(data.excel_id)
  if excel == nil then
    return
  end
  local sum = 0
  local step = 0
  for i = 0, excel.steps.size - 1 do
    sum = sum + excel.steps[i]
    if sum <= data.study then
      step = i
    end
    if data.study == -1 then
      step = excel.steps.size - 1
      w_lock1.visible = false
      w_lock2.visible = false
    end
  end
  ui_md.ui_content.w_content_list:item_clear()
  for i = 0, step do
    local text_excel = bo2.gv_text:find(excel.content_id[i])
    local text = text_excel.text
    local item = w_discover_tree.item_sel
    if item == nil then
      return
    end
    local excel_id = item.var:get("excel_id").v_int
    if excel_id == 0 then
      return
    end
    if excel_id == data.excel_id then
      if excel.sound_id[i] == 0 then
        insert_item(text, false)
      else
        insert_item(text, true)
      end
    end
    w_pic.visible = true
    if data.study == -1 then
    end
    if step == 0 then
      if excel.lock_1 ~= 0 then
        w_lock1.visible = true
        w_lock2.visible = false
      end
    elseif step == 1 then
      if excel.lock_2 ~= 0 then
        w_lock1.visible = false
        w_lock2.visible = true
      end
    elseif step == 2 then
      w_lock1.visible = false
      w_lock2.visible = false
    end
  end
end
function on_window_visible(w, vis)
  if vis then
    local item = w_discover_tree.item_sel
    if item then
      local excel_id = item.var:get("excel_id").v_int
      local study = item.var:get("study").v_int
      local data = {excel_id = excel_id, study = study}
      if study == 0 or study == -100 then
        w_pic.visible = true
        w_pic.image = "$image/discover/tongyong.png"
        w_lock1.visible = false
        w_lock2.visible = false
      else
        local excel = bo2.gv_discover_list:find(data.excel_id)
        if excel == nil then
          ui.log("discover excel nil")
          return
        end
        update_desc(excel)
        update_study(data)
        local show_page = ui_widget.ui_tab.get_show_page(ui_md.ui_content.gx_window)
        if show_page == ui_md.ui_content.w_content.parent then
          update_content(data)
        end
      end
    else
      w_pic.visible = true
      w_pic.image = "$image/discover/ui/res.png|0,0,435,218"
      w_lock1.visible = false
      w_lock2.visible = false
    end
  elseif ui_md.ui_content.g_sound_id ~= 0 then
    bo2.StopSound2D(ui_md.ui_content.g_sound_id)
    ui_md.ui_content.g_sound_id = 0
  end
end
function update_desc(excel)
  local text = bo2.gv_text:find(excel.desc_id)
  if text == nil then
    w_desc.text = ""
    return
  end
  local v = sys.variant()
  if excel.main_type == bo2.eDiscoverMT_World then
    local quest = bo2.gv_quest_list:find(excel.src_id)
    if quest ~= nil then
      v:set("quest_name", quest.name)
    end
  elseif excel.main_type == bo2.eDiscoverMT_Monster then
    local monster = bo2.gv_cha_list:find(excel.src_id)
    if monster ~= nil then
      v:set("monster_name", monster.name)
    end
  elseif excel.main_type == bo2.eDiscoverMT_Other then
  elseif excel.main_type == bo2.eDiscoverMT_Scn then
  end
  w_desc.text = sys.mtf_merge(v, text.text)
  if excel.pic == L("") then
    ui.log("picture nil")
    w_pic.image = "$image/discover/ui/res.png|0,0,435,218"
    w_pic.visible = true
    return
  end
  local image = sys.format("%s%s", c_file_path, excel.pic)
  w_pic.image = image
  w_pic.visible = true
end
function set_discover(data)
  local excel = bo2.gv_discover_list:find(data.excel_id)
  if excel == nil then
    ui.log("discover excel nil")
    return
  end
  if data.study == -100 then
    w_study.text = ui.get_text("discover|study_disable")
    w_study_progress.dx = 0
    w_desc.text = desc_text
    w_pic.image = "$image/discover/ui/res.png|0,0,435,218"
    w_pic.visible = true
    w_lock1.visible = false
    w_lock2.visible = false
    return
  end
  update_desc(excel)
  update_study(data)
  local show_page = ui_widget.ui_tab.get_show_page(ui_md.ui_content.gx_window)
  if show_page ~= ui_md.ui_content.w_model.parent then
    update_content(data)
  end
  update_preview(excel)
end
function update_preview(data)
  ui_md.ui_content.update_preview(data)
end
function set_title_color(item, info)
  local title = item:search("title")
  title.xcolor = c_enable_color
  local study = item:search("study")
  local excel = info.excel
  if info.study == -1 or info.study == excel.gold_study then
  else
  end
end
function on_item_sel(ctrl, vis)
  local select = ctrl:search("select")
  if select == nil then
    return
  end
  select.visible = vis
  local excel_id = ctrl.var:get("excel_id").v_int
  local study = ctrl.var:get("study").v_int
  local data = {excel_id = excel_id, study = study}
  set_discover(data)
  g_select_id = excel_id
  local excel = bo2.gv_discover_list:find(excel_id)
  if excel == nil then
    return
  end
  local v = sys.variant()
  v:set("title", excel.name)
  local disc_title = sys.mtf_merge(v, ui.get_text("discover|disc_title_text"))
  ui_md.m_title.text = disc_title
  ui_md.ui_content.m_disc_title.text = disc_title
  if ui_md.ui_content.g_sound_id ~= 0 then
    bo2.StopSound2D(ui_md.ui_content.g_sound_id)
    ui_md.ui_content.g_sound_id = 0
  end
end
function on_item_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_inner then
    local movein = panel:search("movein")
    if movein == nil then
      return
    end
    movein.visible = true
  elseif msg == ui.mouse_outer then
    local movein = panel:search("movein")
    if movein == nil then
      return
    end
    movein.visible = false
  end
end
function update_num(main_type, sub_type)
  local root = w_discover_tree.root
  local item = root:item_get(main_type - 1)
  local size = item.item_count
  local sum = 0
  for i = 0, size - 1 do
    local child_item = item:item_get(i)
    local c_size = child_item.item_count
    local num = 0
    for j = 0, c_size - 1 do
      local grand_item = child_item:item_get(j)
      local study = grand_item.var:get("study").v_int
      if study ~= -100 then
        sum = sum + 1
        num = num + 1
      end
    end
    local num_t = child_item:search("num")
    num_t.text = sys.format("(%d/%d)", num, child_item.item_count)
  end
  local r_num = item:search("num")
  r_num.text = sys.format("(%d/%d)", sum, g_type_max[main_type])
end
function update_study(data)
  local excel = bo2.gv_discover_list:find(data.excel_id)
  if excel == nil then
    return
  end
  if data.study == -100 then
    w_study.text = ui.get_text("discover|study_disable")
    w_study_progress.dx = 0
    return
  end
  local v = sys.variant()
  if data.study == -1 then
    v:set("n1", excel.gold_study)
    v:set("n2", excel.gold_study)
  else
    v:set("n1", data.study)
    v:set("n2", excel.gold_study)
  end
  w_study.text = sys.mtf_merge(v, ui.get_text("discover|study_progress"))
  if data.study == -1 then
    w_study_progress.dx = c_progress_max
  else
    w_study_progress.dx = c_progress_max * (data.study / excel.gold_study)
  end
end
function on_discover_update(data)
  local excel = bo2.gv_discover_list:find(data.excel_id)
  if excel == nil then
    return
  end
  local root = w_discover_tree.root
  if data.study == 0 then
    return
  end
  if excel == nil then
    return
  end
  local item = root:item_get(excel.main_type - 1)
  local child_item = item:item_get(excel.sub_type - 1)
  local size = child_item.item_count
  for i = 0, size - 1 do
    local grand_item = child_item:item_get(i)
    local excel_id = grand_item.var:get("excel_id").v_int
    if excel_id == data.excel_id then
      local title = grand_item:search("title")
      title.xcolor = c_enable_color
      local study = grand_item:search("study")
      if data.study == -1 or data.study == excel.gold_study then
        study.color = ui.make_color("d3a75e")
        title.color = ui.make_color("d3a75e")
      else
        study.text = ""
      end
      grand_item.var:set("study", data.study)
      update_num(excel.main_type, excel.sub_type)
      if grand_item.selected == true then
        update_desc(excel)
        update_study(data)
        update_content(data)
      end
      grand_item.display = true
      break
    end
  end
end
function set_visible(vis)
  local w = ui.find_control("$frame:discover")
  w.visible = vis
end
function on_close_click(btn)
  set_visible(false)
end
function on_discover(cmd, data)
  local excel_id = data:get(packet.key.item_key).v_int
  local study = data:get(packet.key.itemdata_val).v_int
  local data = {excel_id = excel_id, study = study}
  on_discover_update(data)
end
function on_score(obj, ft, idx)
  local v = sys.variant()
  local text = ui.get_text("discover|discover_score")
  v:set("n", obj:get_flag_int32(bo2.eFlagInt32_DiscoverScore))
end
function on_self_enter(obj, msg)
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.eFlagInt32_DiscoverScore, on_score, "ui_medal.on_score")
end
function on_unlock_discover(cmd, data)
  local lock_id = data:get(packet.key.item_key).v_int
  if lock_id == 1 then
    w_lock1.visible = false
  elseif lock_id == 2 then
    w_lock2.visible = false
  end
end
function on_content_click(btn)
  if ui_md.ui_content.gx_window.visible then
    ui_md.ui_content.gx_main.alpha = 1
    ui_md.ui_content.gx_main:reset(ui_md.ui_content.gx_main.alpha, 0, 1000)
    ui_md.ui_content.m_timer.suspended = false
  else
    ui_md.ui_content.gx_main.alpha = 0
    ui_md.ui_content.gx_window.visible = true
    ui_md.ui_content.m_timer.suspended = true
  end
end
local sig_name = "ui_md:ui_discover:on_signal"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_Discover, on_discover, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_Unlock, on_unlock_discover, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_md.ui_discover.on_self_enter")
