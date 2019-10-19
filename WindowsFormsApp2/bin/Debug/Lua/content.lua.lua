g_sound_id = 0
function on_window_visible(w, vis)
  ui_widget.on_border_visible(w, vis)
  if w.visible then
    local length = w.size.x
    local w_md = ui_md.gx_window
    w.x = w_md.x + w_md.dx
    w.y = w_md.y
    w.top_level = true
    gx_main.alpha = 0
    gx_main:reset(gx_main.alpha, 1, 1000)
    m_timer.suspended = true
  end
end
function on_init()
  insert_tab(gx_window, "view")
  insert_tab(gx_window, "content")
  ui_widget.ui_tab.show_page(gx_window, "view", true)
  g_sound_id = 0
end
function insert_tab(tab, name)
  local btn_file = L("$frame/discover/content.xml")
  local btn_style = L("tab_btn")
  local page_file = L("$frame/discover/content.xml")
  local page_style = name
  ui_widget.ui_tab.insert_suit(tab, name, btn_file, btn_style, page_file, page_style)
  local btn = ui_widget.ui_tab.get_button(tab, name)
  local text = ui.get_text(sys.format("discover|%s", name))
  btn.text = text
  btn.name = name
  btn:insert_on_press(on_tab_press, "ui_quest.on_tab_press")
end
function on_close()
  gx_window.visible = false
end
function on_timer()
  gx_window.visible = false
  gx_main.alpha = 0
  m_timer.suspended = true
end
local ui_tab = ui_widget.ui_tab
local ui_text_list = ui_widget.ui_text_list
local p_fitting_player
local b_first_init = true
function box_insert_text(box, text)
  local rank = ui.mtf_rank_system
  local content = sys.format("<tf:text>%s", text)
  box:insert_mtf(content, rank)
end
function get_title(excel)
  local type = excel.main_type
  if type == bo2.eDiscoverMT_World then
    local sub = bo2.gv_discover_world:find(excel.sub_type)
    if sub == nil then
      return nil
    end
    return sub.name
  elseif type == bo2.eDiscoverMT_Monster then
    local sub = bo2.gv_discover_monster:find(excel.sub_type)
    if sub == nil then
      return nil
    end
    return sub.name
  elseif type == bo2.eDiscoverMT_Pet then
    local sub = bo2.gv_discover_pet:find(excel.sub_type)
    if sub == nil then
      return nil
    end
    return sub.name
  elseif type == bo2.eDiscoverMT_Mount then
    local sub = bo2.gv_discover_mount:find(excel.sub_type)
    if sub == nil then
      return nil
    end
    return sub.name
  end
  return nil
end
function on_sure_click()
  if w_scn.scn ~= nil then
    local height = m_height.text.v_number
    w_scn.scn:set_target_height(height)
    local radius = m_radius.text.v_number
    w_scn.scn:set_radius(radius)
  end
end
function show_active_popo(click, data)
  local id = data:get(packet.key.quest_id).v_int
  ui.log("discover = " .. id)
  local excel = bo2.gv_discover_list:find(id)
  if excel == nil then
    return
  end
  local title = get_title(excel)
  if title ~= nil then
    set_title(title)
  end
  if excel.model_id ~= 0 then
    bind_modle(excel)
    w_model.visible = true
    w_text.visible = false
  elseif excel.text.size ~= 0 then
    w_box:item_clear()
    box_insert_text(w_box, excel.text)
    w_model.visible = false
    w_text.visible = true
    w_box.slider_y.scroll = 0
  else
    return
  end
  set_visible(true)
end
function set_title(txt)
  w_title.text = txt
end
function set_visible(vis)
  local w = ui.find_control("$frame:ds_view")
  w.visible = vis
end
function bind_modle(excel)
  local kind = 0
  if excel.main_type == bo2.eDiscoverMT_Monster or excel.main_type == bo2.eDiscoverMT_World then
    kind = bo2.eScnObjKind_Npc
  elseif excel.main_type == bo2.eDiscoverMT_Pet or excel.main_type == bo2.eDiscoverMT_Mount then
    kind = bo2.eScnObjKind_Pet
  end
  if kind == 0 then
    return
  end
  local scn = w_scn.scn
  scn:clear_obj(-1)
  local p = scn:create_obj(kind, excel.model_id)
  if p == nil then
    return
  end
  scn:bind_camera(p)
end
local f_rot_angle = 90
function on_doll_rotl_click(btn, press)
  if press then
    w_scn.rotate_angle = -f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
  if w_scn.scn ~= nil then
    local radius = tostring(w_scn.scn:get_camera_angle(2))
    radius = string.sub(radius, 1, 4)
    m_radius.text = radius
    local height = tostring(w_scn.scn:get_target_height())
    height = string.sub(height, 1, 4)
    m_height.text = height
  end
end
function on_doll_rotr_click(btn, press)
  if press then
    w_scn.rotate_angle = f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
  if w_scn.scn ~= nil then
    local radius = tostring(w_scn.scn:get_camera_angle(2))
    radius = string.sub(radius, 1, 4)
    m_radius.text = radius
    local height = tostring(w_scn.scn:get_target_height())
    height = string.sub(height, 1, 4)
    m_height.text = height
  end
end
function on_window_visible(w, vis)
  ui_widget.on_border_visible(w, vis)
  ui_main.w_top:apply_dock(true)
  if w.visible then
    local length = w.size.x
    local w_md = ui_md.gx_window
    w.x = w_md.x + w_md.dx
    w.y = w_md.y
    w.top_level = true
    gx_main.alpha = 0
    gx_main:reset(gx_main.alpha, 1, 1000)
    w_scn:set_excel_id(3000)
    m_timer.suspended = true
    local item = ui_md.ui_discover.w_discover_tree.item_sel
    if item then
      local excel_id = item.var:get("excel_id").v_int
      local study = item.var:get("study").v_int
      local excel = bo2.gv_discover_list:find(excel_id)
      if excel.model_id == 0 then
        ui_widget.ui_tab.get_button(gx_window, "view").enable = false
        ui_widget.ui_tab.show_page(gx_window, "content", true)
        w_model.visible = false
        return
      else
        ui_widget.ui_tab.get_button(gx_window, "view").enable = true
      end
      local show_page = ui_widget.ui_tab.get_show_page(gx_window)
      if show_page == w_model.parent then
        w_model.visible = true
        local scn = w_scn.scn
        p_fitting_player = scn:create_obj(bo2.eScnObjKind_Npc, excel.model_id)
        scn:modify_disccamera_view_type(p_fitting_player, bo2.eCameraDiscovery, excel.id, excel.radius, 0, excel.height)
        local radius = tostring(w_scn.scn:get_camera_angle(2))
        radius = string.sub(radius, 1, 4)
        m_radius.text = radius
        local height = tostring(w_scn.scn:get_target_height())
        height = string.sub(height, 1, 4)
        m_height.text = height
      else
        local data = {excel_id = excel_id, study = study}
        ui_md.ui_discover.update_content(data)
      end
    end
  else
    gx_main.alpha = 1
    ui.clean_drop()
    on_destroy_scn()
  end
end
function update_preview(excel)
  on_destroy_scn()
  w_scn:set_excel_id(3000)
  local scn = w_scn.scn
  if excel.model_id == 0 then
    ui_widget.ui_tab.get_button(gx_window, "view").enable = false
    ui_widget.ui_tab.show_page(gx_window, "content", true)
    w_model.visible = false
    return
  else
    ui_widget.ui_tab.get_button(gx_window, "view").enable = true
    if gx_window.visible and gx_main.alpha < 1 then
      ui_md.gx_window.visible = true
      gx_window.visible = true
      gx_main:reset(gx_main.alpha, 1, 1000)
      m_timer.suspended = true
    else
      ui_md.gx_window.visible = true
      gx_window.visible = true
      gx_main.alpha = 0
      gx_main:reset(gx_main.alpha, 1, 1000)
      m_timer.suspended = true
    end
  end
  local show_page = ui_widget.ui_tab.get_show_page(gx_window)
  if show_page == w_model.parent then
    w_model.visible = true
    p_fitting_player = scn:create_obj(bo2.eScnObjKind_Npc, excel.model_id)
    scn:modify_disccamera_view_type(p_fitting_player, bo2.eCameraDiscovery, excel.id, excel.radius, 0, excel.height)
    local radius = tostring(w_scn.scn:get_camera_angle(2))
    radius = string.sub(radius, 1, 4)
    m_radius.text = radius
    local height = tostring(w_scn.scn:get_target_height())
    height = string.sub(height, 1, 4)
    m_height.text = height
  end
end
function on_tab_press(btn, press)
  if press then
    if not sys.check(ui_md.ui_discover.w_discover_tree) then
      return
    end
    local item = ui_md.ui_discover.w_discover_tree.item_sel
    if item == nil then
      return
    end
    local excel_id = item.var:get("excel_id").v_int
    local study = item.var:get("study").v_int
    if btn.name == L("view") then
      local excel = bo2.gv_discover_list:find(excel_id)
      w_model.visible = true
      w_scn:set_excel_id(3000)
      local scn = w_scn.scn
      p_fitting_player = scn:create_obj(bo2.eScnObjKind_Npc, excel.model_id)
      scn:modify_disccamera_view_type(p_fitting_player, bo2.eCameraDiscovery, excel.id, excel.radius, 0, excel.height)
    elseif btn.name == L("content") then
      local data = {excel_id = excel_id, study = study}
      ui_md.ui_discover.update_content(data)
    end
  end
end
function on_destroy_scn()
  if w_scn ~= nil then
    w_scn:set_excel_id(0)
  end
  p_fitting_player = nil
end
function on_play_sound(btn)
  local item = btn.parent
  local tree_item = ui_md.ui_discover.w_discover_tree.item_sel
  if tree_item == nil then
    return
  end
  local excel_id = tree_item.var:get("excel_id").v_int
  local excel = bo2.gv_discover_list:find(excel_id)
  if excel == nil then
    return
  end
  local index = item.index
  if g_sound_id ~= 0 then
    bo2.StopSound2D(g_sound_id)
  end
  bo2.PlaySound2D(excel.sound_id[index])
  g_sound_id = excel.sound_id[index]
end
