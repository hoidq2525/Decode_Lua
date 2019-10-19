local f_rot_angle = 90
local m_skill_type = 0
local m_ridepet
local m_bInit = false
local m_grid = 0
local m_ridepet_page_current = 0
local m_ridepet_page_count = 7
local g_blood_refine_max = bo2.gv_define:find(1288).value.v_int
local step_ctrl
function init_once()
end
function on_doll_rotl_press(btn, press)
  if press then
    w_scn.rotate_angle = -f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
end
function on_doll_rotr_press(btn, press)
  if press then
    w_scn.rotate_angle = f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
end
function on_page_step(var)
  update_page(var.index)
end
function update_page(page)
  ui_widget.ui_stepping.set_page(step_ctrl, page, m_ridepet_page_count)
  set_ridepet_page(page)
end
function find_info_from_pos_view(pos)
  local info = ui.find_ride_info(bo2.eRidePetBox_View, pos)
  return info
end
function set_ridepet_page(page)
  local info = find_info_from_pos_view(ui.ride_get_select_view())
  if info == nil then
    return
  end
  m_ridepet_page_current = page
  local control_cnt = w_ridelist_view.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist_view:control_get(i)
    if ctr ~= nil then
      ctr:search("ridepet_view").grid = page + i
    end
  end
  update_ridepet(info)
end
function update_ridepet(info)
  local control_cnt = w_ridelist_view.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist_view:control_get(i)
    if ctr ~= nil then
      if ctr:search("ridepet_view").grid == info.grid then
        ctr:search("select").visible = true
      else
        ctr:search("select").visible = false
      end
    end
  end
end
function on_init(ctrl)
  local parent = w_ridepet:search(L("ridepet_view_list"))
  step_ctrl = parent:search(L("step"))
  ui_widget.ui_stepping.set_event(step_ctrl, on_page_step)
  local control_cnt = w_ridelist_view.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist_view:control_get(i)
    if ctr ~= nil then
      ctr:search(L("ridepet_view")).grid = i
    end
  end
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if not vis then
    ui.ride_clear_view()
  end
end
function update_view()
  clear_ui()
  local info = find_info_view()
  if info ~= nil then
    update_ui_cmn(info)
    update_ui_scn(info)
    update_ui_equip(info)
    update_ui_flag(info)
    update_ui_blood(info)
    update_ui_exp(info)
    update_ui_skill(info)
    select_skill_type(m_skill_type)
    local pos_min = m_ridepet_page_current
    local pos_max = m_ridepet_page_current + 6
    local pos = info.grid
    if pos_min > pos or pos_max <= pos then
      if pos < 6 then
        m_ridepet_page_current = 0
      else
        m_ridepet_page_current = 6
      end
    end
    update_page(m_ridepet_page_current)
  end
end
function show(box, grid)
  ui.ride_set_cur_view_coord(box, grid)
  update_view()
  w_ridepet.visible = true
end
function send_ridepet_view(var)
  w_ridepet.visible = false
  bo2.send_variant(packet.eCTS_UI_RidePetView, var)
end
function handle_ridepet_view_packet(cmd, var)
  local box = var:get(packet.key.item_box).v_int
  local grid = var:get(packet.key.item_grid).v_int
  local view_end = var:get(packet.key.ridepet_view_end).v_int
  if box == bo2.eRidePetBox_View and view_end == 1 then
    show(box, grid)
  else
    ui.ride_insert_view(var)
  end
end
function InitRideView(obj, msg)
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetView, handle_ridepet_view_packet, "ui_ridepet.handle_ridepet_add")
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, InitRideView, "on_enter_scn:InitRideView")
function find_info_view()
  local info = ui.ride_find_cur_view()
  return info
end
function clear_ui()
  w_name.text = ""
  w_title.text = ui.get_text("pet|ridepet_name")
  w_flag_startype.text = ""
  w_flag_sex.text = ""
  w_flag_potential.text = ""
  w_flag_str.text = ""
  w_flag_int.text = ""
  w_flag_vit.text = ""
  w_flag_agi.text = ""
  w_flag_speedmax.text = ""
  w_flag_stmax.text = ""
  w_flag_skillpoint.text = ""
  w_loyal:search("current").dx = 0
  w_loyal:search("max").dx = 0
  w_level:search("level").text = ""
  w_level:search("exp_text").text = ""
  w_level:search("exp_cur").dx = 0
  w_equip:search("ridepet_weapon").visible = true
  w_equip:search("ridepet_center"):update()
  w_refine.text = ""
  w_blood_refine.text = ""
  w_multi_ride.text = ""
  w_natural_vit.visible = false
  w_natural_vit:search("current").dx = 0
  w_natural_vit:search("max").dx = 0
  w_natural_agi.visible = false
  w_natural_agi:search("current").dx = 0
  w_natural_agi:search("max").dx = 0
  w_natural_str.visible = false
  w_natural_str:search("current").dx = 0
  w_natural_str:search("max").dx = 0
  w_natural_int.visible = false
  w_natural_int:search("current").dx = 0
  w_natural_int:search("max").dx = 0
  w_natural_speedmax.visible = false
  w_natural_speedmax:search("current").dx = 0
  w_natural_speedmax:search("max").dx = 0
  w_natural_stmax.visible = false
  w_natural_stmax:search("current").dx = 0
  w_natural_stmax:search("max").dx = 0
  w_blood_picture.image = ""
  w_blood_generation.text = ""
  w_blood_telent.text = ""
  w_blood_star.visible = false
  w_blood_star_text.visible = false
  if m_ridepet ~= nil then
    w_scn.scn:destory_obj(m_ridepet)
    m_ridepet = nil
  end
  w_skill_list:item_clear()
  w_jipo.visible = false
end
function update_ui_cmn(info)
  w_name.text = ui_widget.merge_mtf({
    name = info.player_name
  }, ui.get_text("pet|ridepet_other_player_name"))
end
function update_ui_scn(info)
  if m_ridepet ~= nil then
    w_scn.scn:destory_obj(m_ridepet)
    m_ridepet = nil
  end
  if info == nil then
    return
  end
  local ridepet_excel = bo2.gv_ridepet_list:find(info:get_flag(bo2.eRidePetFlagInt32_RidePetListId))
  if ridepet_excel == nil then
    return
  end
  local excel = bo2.gv_ride_list:find(ridepet_excel.nRideId)
  if excel == nil then
    return
  end
  m_ridepet = w_scn.scn:create_obj(bo2.eScnObjKind_RidePet, excel.chaid)
  if excel.rideStateId > 0 then
    m_ridepet:AddState(0, excel.rideStateId)
  end
  m_ridepet.angle = 0.5 * math.pi
  w_title.text = ridepet_excel.name
  if ui_ridepet.get_ridepet_jipo_state(info) then
    w_jipo.visible = true
  end
end
function update_ui_equip(info)
  if info == nil then
    return
  end
  local type_id = info:get_flag(bo2.eRidePetFlagInt32_Type)
  local type_excel = bo2.gv_ridepet_type_init:find(type_id)
  if type_excel ~= nil and type_excel.nNoGrow ~= 0 then
    w_equip:search("ridepet_weapon").visible = false
    w_equip:search("ridepet_center"):update()
  end
  for i = bo2.eItemSlot_RidePetBegin, bo2.eItemSlot_RidePetEnd - 1 do
    m_ridepet:set_equip_model(i, info:get_equip_model(i))
  end
end
function update_ui_blood(info)
  if info == nil then
    return
  end
  local blood_id = info:get_flag(bo2.eRidePetFlagInt32_Blood)
  local blood_excel = bo2.gv_ridepet_blood_telent:find(blood_id)
  if blood_id ~= 0 then
    w_blood_picture.visible = true
    w_blood_picture.image = "$icon/item/" .. blood_excel.strIcon .. ".png"
    w_blood_generation.text = blood_excel.strGeneration
    local mtf_data = {}
    if ui_ridepet.IsTransferedBloodTelent(blood_id) then
      w_blood_telent.mtf = ui_widget.merge_mtf(mtf_data, blood_excel.name .. ui.get_text("pet|ridepet_transfer_yes"))
    else
      w_blood_telent.mtf = ui_widget.merge_mtf(mtf_data, blood_excel.name .. ui.get_text("pet|ridepet_transfer_no"))
    end
    w_blood_star.visible = true
    w_blood_star.dx = 13.6 * blood_excel.nStar
    w_blood_star_text.visible = false
    w_blood_star_text.text = ""
  else
    w_blood_picture.visible = false
    w_blood_picture.image = ""
    w_blood_generation.text = ui.get_text("pet|ridepet_blood_unknown")
    w_blood_telent.text = ui.get_text("pet|ridepet_blood_unknown")
    w_blood_star.visible = false
    w_blood_star.dx = 0
    w_blood_star_text.visible = true
    w_blood_star_text.text = ui.get_text("pet|ridepet_blood_unknown")
  end
end
function update_ui_flag(info)
  if info == nil then
    return
  end
  local star_id = info:get_flag(bo2.eRidePetFlagInt32_Star)
  local type_id = info:get_flag(bo2.eRidePetFlagInt32_Type)
  local name = ""
  local star_excel = bo2.gv_ridepet_star_init:find(star_id)
  if star_excel ~= nil then
    name = name .. star_excel.name
  end
  local type_excel = bo2.gv_ridepet_type_init:find(type_id)
  if type_excel ~= nil then
    if type_excel.nNoGrow ~= 0 then
      name = type_excel.name
    else
      name = name .. type_excel.name
    end
  end
  w_flag_startype.text = name
  local sex = info:get_flag(bo2.eRidePetFlagInt32_Sex)
  if sex == 0 then
    w_flag_sex.text = ui.get_text("pet|ridepet_sex_none")
  elseif sex == 1 then
    w_flag_sex.text = ui.get_text("pet|ridepet_sex_boy")
  elseif sex == 2 then
    w_flag_sex.text = ui.get_text("pet|ridepet_sex_girl")
  end
  w_flag_potential.text = info:get_flag(bo2.eRidePetFlagInt32_Potential)
  w_flag_str.text = info:get_flag(bo2.eRidePetFlagInt32_BaseStr)
  w_flag_int.text = info:get_flag(bo2.eRidePetFlagInt32_BaseInt)
  w_flag_vit.text = info:get_flag(bo2.eRidePetFlagInt32_BaseVit)
  w_flag_agi.text = info:get_flag(bo2.eRidePetFlagInt32_BaseAgi)
  w_flag_speedmax.text = info:get_flag(bo2.eRidePetFlagInt32_BaseSpeedMaxRun)
  w_flag_stmax.text = info:get_flag(bo2.eRidePetFlagInt32_BaseSTMax)
  w_flag_skillpoint.text = info:get_flag(bo2.eRidePetFlagInt32_FreeSkillPoint)
  w_loyal:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_Loyal) * 20
  w_loyal:search("max").dx = info:get_flag(bo2.eRidePetFlagInt32_LoyalMax) * 20
  if type_id == 0 then
  elseif type_excel.nNoGrow ~= 0 then
  else
    w_natural_vit.visible = true
    w_natural_vit:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalVit) * 17
    w_natural_vit:search("max").dx = 85
    w_natural_agi.visible = true
    w_natural_agi:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalAgi) * 17
    w_natural_agi:search("max").dx = 85
    w_natural_str.visible = true
    w_natural_str:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalStr) * 17
    w_natural_str:search("max").dx = 85
    w_natural_int.visible = true
    w_natural_int:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalInt) * 17
    w_natural_int:search("max").dx = 85
    w_natural_speedmax.visible = true
    w_natural_speedmax:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalSpeedMax) * 17
    w_natural_speedmax:search("max").dx = 85
    w_natural_stmax.visible = true
    w_natural_stmax:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalSTMax) * 17
    w_natural_stmax:search("max").dx = 85
  end
  local level = info:get_flag(bo2.eRidePetFlagInt32_Level)
  local exp = info:get_flag(bo2.eRidePetFlagInt32_Exp)
  local level_excel = bo2.gv_ridepet_level:find(level)
  if level_excel ~= nil then
    local exp_max = level_excel.nExpMax
    local exp_text = tostring(exp) .. "/" .. tostring(exp_max)
    w_level:search("exp_text").text = exp_text
    w_level:search("exp_cur").dx = exp / exp_max * 220
  else
    w_level:search("exp_text").text = ""
    w_level:search("exp_cur").dx = 0
  end
  w_level:search("level").text = level
  local refine = info:get_flag(bo2.eRidePetFlagInt32_Refine)
  local refine_max = info:get_flag(bo2.eRidePetFlagInt32_RefineMax)
  w_refine.text = tostring(refine) .. "/" .. tostring(refine_max)
  local blood_refine = info:get_flag(bo2.eRidePetFlagInt32_BloobRefineCount)
  w_blood_refine.text = tostring(blood_refine) .. "/" .. tostring(g_blood_refine_max)
  local ridepet_excel = bo2.gv_ridepet_list:find(info:get_flag(bo2.eRidePetFlagInt32_RidePetListId))
  if ridepet_excel == nil then
    return
  end
  local ride_excel = bo2.gv_ride_list:find(ridepet_excel.nRideId)
  if ride_excel == nil then
    return
  end
  local multiRide = info:get_flag_8(bo2.eRidePetFlagInt8_MultiRide) ~= 0 or ride_excel.multiRide ~= 0
  if multiRide ~= false then
    w_multi_ride.text = ui.get_text("pet|ridepet_multi_ride_yes")
  else
    w_multi_ride.text = ui.get_text("pet|ridepet_multi_ride_no")
  end
end
function update_ui_exp(info)
  if info == nil then
    return
  end
  local level = info:get_flag(bo2.eRidePetFlagInt32_Level)
  local level_excel = bo2.gv_ridepet_level:find(level)
  local exp = info:get_flag(bo2.eRidePetFlagInt32_Exp)
  if level_excel ~= nil then
    local exp_max = level_excel.nExpMax
    local exp_text = tostring(exp) .. "/" .. tostring(exp_max)
    w_level:search("exp_text").text = exp_text
    w_level:search("exp_cur").dx = exp / exp_max * 220
  else
    w_level:search("exp_text").text = ""
    w_level:search("exp_cur").dx = 0
  end
end
function update_ui_skill(info)
  if info == nil then
    return
  end
  local page_uri = "$frame/ridepet/ridepet.xml"
  local list_name = "ridepet_skill"
  w_skill_list:item_clear()
  local type = info:get_flag(bo2.eRidePetFlagInt32_Type)
  local type_excel = bo2.gv_ridepet_type_init:find(type)
  if type_excel == nil then
    return
  end
  local cnt = 0
  local unlock_cnt = 0
  if m_skill_type == bo2.eRidePetSlot_BaZhan then
    cnt = type_excel.nFinalSkillSlot0
    unlock_cnt = info:get_flag(bo2.eRidePetFlagInt32_SkillSlot0)
    w_flag_skillpoint.parent.visible = true
  elseif m_skill_type == bo2.eRidePetSlot_YouZhu then
    cnt = type_excel.nFinalSkillSlot1
    unlock_cnt = info:get_flag(bo2.eRidePetFlagInt32_SkillSlot1)
    w_flag_skillpoint.parent.visible = true
  elseif m_skill_type == bo2.eRidePetSlot_ZhuiFeng then
    cnt = type_excel.nFinalSkillSlot2
    unlock_cnt = info:get_flag(bo2.eRidePetFlagInt32_SkillSlot2)
    w_flag_skillpoint.parent.visible = true
  elseif m_skill_type == bo2.eRidePetSlot_RideFight then
    cnt = type_excel.nFinalSkillSlot3
    unlock_cnt = info:get_flag(bo2.eRidePetFlagInt32_SkillSlot3)
    w_flag_skillpoint.parent.visible = false
  end
  for i = 0, cnt - 1 do
    local list_item = w_skill_list:item_append()
    list_item:load_style(page_uri, list_name)
    if i >= unlock_cnt then
      local skill_back_lock = list_item:search("skill_back_lock")
      skill_back_lock.visible = true
    else
      local skill_back_normal = list_item:search("skill_back_normal")
      skill_back_normal.visible = true
    end
  end
  local index = 0
  cnt = info:get_skill_cnt()
  for i = 0, cnt - 1 do
    local skill_info = info:get_skill(i)
    if skill_info ~= nil then
      local ridepet_skill_excel = bo2.gv_ridepet_skill:find(skill_info.excel_id)
      local skill_name = ridepet_skill_excel.name
      local skill_max_level = ridepet_skill_excel.nMaxLevel
      if ridepet_skill_excel.nSkillGroup == m_skill_type then
        local list_item = w_skill_list:item_get(index)
        local skill_ctr = list_item:search("skill")
        skill_ctr.excelid = skill_info.excel_id
        skill_ctr.onlyid = info.onlyid
        local name_text_ctr = list_item:search("name_text")
        name_text_ctr.visible = true
        name_text_ctr.text = skill_name
        local level_text_ctr = list_item:search("level_text")
        level_text_ctr.visible = true
        level_text_ctr.text = tostring(skill_info.level) .. "/" .. tostring(skill_max_level)
        index = index + 1
      end
    end
  end
end
function select_skill_type(skill_type)
  local control_cnt = w_skill_type.control_size
  if skill_type > control_cnt then
    return
  end
  local ctr = w_skill_type:control_get(skill_type)
  ctr.press = true
end
function on_skill_type(btn)
  local parent = btn.parent
  local control_cnt = parent.control_size
  for i = 0, control_cnt - 1 do
    local ctr = parent:control_get(i)
    if ctr == btn then
      if m_skill_type ~= i then
        m_skill_type = i
      else
        return
      end
    end
  end
  local info = find_info_view()
  update_ui_skill(info)
end
function on_ridepet_natural_tip(tip)
  local info = find_info_view()
  if info == nil then
    return
  end
  local stk = sys.mtf_stack()
  local ctr = tip.owner.parent
  local ctr_name = tip.owner.parent.name
  build_ridepet_natural_tip(ctr_name, stk, info)
  ui_tool.ctip_show(tip.owner, stk)
end
function on_ridepet_skill_tip(tip)
  local stk = sys.mtf_stack()
  local card = tip.owner
  local info = card.info
  if info == nil then
    return
  end
  build_ridepet_skill_tip(stk, info)
  ui_tool.ctip_show(card, stk)
end
function update_select_ui(info)
  clear_ui()
  update_ui_cmn(info)
  update_ui_scn(info)
  update_ui_equip(info)
  update_ui_flag(info)
  update_ui_blood(info)
  update_ui_exp(info)
  update_ui_skill(info)
  select_skill_type(m_skill_type)
  local pos_min = m_ridepet_page_current
  local pos_max = m_ridepet_page_current + 6
  local pos = info.grid
  if pos_min > pos or pos_max <= pos then
    if pos < 6 then
      m_ridepet_page_current = 0
    else
      m_ridepet_page_current = 6
    end
  end
  update_page(m_ridepet_page_current)
end
function select_ridepet_view(pos)
  local cur_pos = ui.ride_get_select_view()
  local info = find_info_from_pos_view(pos)
  if info ~= nil then
    ui.ride_set_select_view(pos)
    update_ridepet(info)
    update_select_ui(info)
  end
end
function on_ride_card_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local pos = card.grid
    select_ridepet_view(pos)
  end
end
function on_ride_card_drop(card, msg, pos, data)
end
init_once()
