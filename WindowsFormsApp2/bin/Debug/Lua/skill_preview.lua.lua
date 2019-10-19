local p_skill_preview_player, p_target_npc, g_skill_preview_id, g_combo_skill
local g_display_skill_list = {}
local g_loading_per = 0
local g_skill_increase_per = 0.08
local g_combol_increase_per = 0.08
local g_cur_increase_per = g_skill_increase_per
local g_scn_loading_begin_per = 0
local gci_scn_id = 999
local g_terminating_scn = true
g_loaded_scn = false
local g_cur_group_skill_id = 0
local g_cur_group_skill_size = 0
local g_cur_group_skill_index = 0
function revert_group_skill_id()
  g_cur_group_skill_id = 0
end
local g_cur_skill_index = 0
local g_p_skill_preview, g_model_excel
local g_using_skill = false
local g_loading_skill_preview = false
g_auto_play_skill = true
g_auto_next_scene_play = false
g_wait_for_skill = false
local g_replay_camera
g_iMaxSeiveSkill = 4
g_auto_play_all_skill = false
g_auto_play_all_skill_idx = -1
function create_preview_scene_object()
  if g_p_skill_preview == nil then
    return
  end
  local scn = w_scn.scn
  if scn == nil then
    return
  end
  scn:clear_obj(bo2.eScnObjKind_Player)
  scn:clear_obj(bo2.eScnObjKind_Npc)
  scn:clear_obj(bo2.eScnObjKind_Lone)
  scn:clear_client_scnobj()
  local actor_id = g_p_skill_preview.actor_id
  local use_current_player = false
  if ui_skill_preview.btn_actor2.check == true then
    actor_id = bo2.player.excel.id
    use_current_player = true
  end
  local _cha_list = bo2.gv_cha_list:find(g_p_skill_preview.actor_id)
  if _cha_list == nil then
    return
  end
  local career_id = _cha_list.nCareer
  local p_skill_preview_camera = g_p_skill_preview.p_camera_id
  if p_skill_preview_camera == nil then
    return
  end
  p_skill_preview_player = scn:create_obj(bo2.eScnObjKind_Player, actor_id, g_p_skill_preview.actor_portal)
  if use_current_player == true then
    p_skill_preview_player.view_target = bo2.player
  end
  p_skill_preview_player:SetPlayerSelectParticle(true)
  if g_p_skill_preview.summon_unit_skill ~= 0 and g_p_skill_preview.summon_unit_skill_interval ~= 0 then
    p_skill_preview_player:set_summon_unit_skill_preview(g_p_skill_preview.summon_unit_skill, g_p_skill_preview.summon_unit_skill_interval)
  end
  if use_current_player ~= true then
    p_skill_preview_player:set_equip_model(bo2.eEquipData_Hair, g_model_excel.hair_id)
    p_skill_preview_player:set_equip_model(bo2.eEquipData_Face, g_model_excel.face_id)
    p_skill_preview_player:set_equip_model(bo2.eEquipData_Body, g_model_excel.body_id)
    p_skill_preview_player:set_equip_model(bo2.eEquipData_Legs, g_model_excel.legs_id)
    p_skill_preview_player:equip_clear()
    p_skill_preview_player:load_default_equip(g_p_skill_preview)
  else
  end
  if 0 < g_p_skill_preview.actor_main_weapon then
    p_skill_preview_player:set_view_equip(bo2.eEquipData_MainWeapon, g_p_skill_preview.actor_main_weapon)
  elseif use_current_player == true then
    p_skill_preview_player:set_view_equip(bo2.eEquipData_MainWeapon, -1)
  end
  if 0 < g_p_skill_preview.actor_2nd_weapon then
    p_skill_preview_player:set_view_equip(bo2.eEquipData_2ndWeapon, g_p_skill_preview.actor_2nd_weapon)
  end
  if 0 < g_p_skill_preview.actor_hide_weapon then
    p_skill_preview_player:set_view_equip(bo2.eEquipData_HWeapon, g_p_skill_preview.actor_hide_weapon)
  end
  p_skill_preview_player:set_view_player_career(career_id)
  p_skill_preview_player:set_flag_objmem(bo2.eFlagObjMemory_Run, 1)
  if g_replay_camera == nil then
    scn:bind_camera(p_skill_preview_player, p_skill_preview_camera.eye_high, p_skill_preview_camera.radius, p_skill_preview_camera.pitch, p_skill_preview_camera.yaw)
    scn:active_trangle_camera(ui_skill_preview.btn_locked_camera.check)
  else
    scn:bind_camera(p_skill_preview_player, p_skill_preview_camera.eye_high, g_replay_camera.radius, g_replay_camera.pitch, g_replay_camera.yaw)
    scn:active_trangle_camera(ui_skill_preview.btn_locked_camera.check)
  end
  p_target_npc = scn:create_obj(bo2.eScnObjKind_Npc, g_p_skill_preview.target_id, g_p_skill_preview.target_portal)
  p_target_npc:set_as_npc()
  p_target_npc:set_flag_objmem(bo2.eFlagObjMemory_Run, 1)
  p_skill_preview_player:set_target(p_target_npc.sel_handle)
  if g_p_skill_preview.target_special_state == bo2.eSkillPreview_NpcSpecialState_Fall or g_p_skill_preview.target_special_state == bo2.eSkillPreview_NpcSpecialState_Defend then
    p_target_npc:set_special_state(g_p_skill_preview.target_special_state)
  end
  local other_target_size = g_p_skill_preview.other_target_id.size
  local other_target_portal_size = g_p_skill_preview.other_target_portal.size
  if other_target_size > 0 and other_target_size == other_target_portal_size then
    for i = 0, other_target_size - 1 do
      local other_target_boj = scn:create_obj(bo2.eScnObjKind_Npc, g_p_skill_preview.other_target_id[i], g_p_skill_preview.other_target_portal[i])
      other_target_boj:set_as_npc()
      other_target_boj:set_flag_objmem(bo2.eFlagObjMemory_Run, 1)
    end
  end
end
function on_call_back_end_progress(hide_visible, load_visible)
  if hide == true then
    skill_preview_hello_world.visible = hide
    skill_preview_loading.visible = false
    skill_preview_view.visible = false
  else
    if sys.check(skill_preview_hello_world) ~= true then
      return
    end
    skill_preview_hello_world.visible = hide
    skill_preview_loading.visible = load_visible
    skill_preview_view.visible = not load_visible
  end
end
function call_back_set_progress(per, bUseSkill)
  local function on_call_back_scn_progress(per, msg)
    if g_loading_per < 0.46 then
      g_loading_per = per + g_loading_per
      w_progress_picture.dx = g_loading_per * 96 * progress_panel.dx / 128
    end
    bo2.draw_scngui()
  end
  set_loading_tips()
  set_preview_tips()
  if w_scn.scn == nil then
    on_call_back_end_progress(false, true)
    w_scn:load_scn(gci_scn_id, on_call_back_scn_progress)
    w_scn.scn:bind_soundmgr()
    bo2.set_disable_scn_music(true)
    g_loading_per = 0.46
  end
  create_preview_scene_object()
  if p_skill_preview_player ~= nil and w_scn.scn ~= nil then
    local function on_call_back_scn_progree()
      if g_loading_per < 0.96 then
        g_loading_per = g_loading_per + g_cur_increase_per
        w_progress_picture.dx = g_loading_per * 96 * progress_panel.dx / 128
      end
      bo2.draw_scngui()
    end
    if g_loaded_scn ~= false then
      g_loaded_scn = false
      w_scn.scn:start_res_load(p_skill_preview_player, on_call_back_scn_progree)
    else
      w_scn.scn:start_object_res_load(on_call_back_scn_progree)
    end
  end
  g_loading_per = 0.96
  local display_skill_or_destroy_scn = function()
    if w_skill_preview.visible ~= true then
      on_destroy_scn()
    else
      on_click_use_skill()
    end
  end
  display_skill_or_destroy_scn()
  g_loading_per = 0
  g_loading_skill_preview = false
  on_call_back_end_progress(false, false)
end
function on_load_scn()
  g_loading_per = 0
  g_loading_skill_preview = true
  call_back_set_progress(g_loading_per, true)
end
function on_timer_loading_progress()
  ui.log("call loading?")
end
function set_loading_new_scene()
  next_preview_scene.suspended = false
end
function on_timer_loading_new_scene()
  next_preview_scene.suspended = true
  if g_auto_next_scene_play ~= true then
    return false
  end
  g_auto_next_scene_play = false
  on_clean_preview_scene()
  set_preview_skill(g_cur_group_skill_id, g_cur_group_skill_index)
end
function on_destroy_scn()
  bo2.revert_soundmgr()
  if sys.check(ui_skill_preview.skill_preview_view) and ui_skill_preview.skill_preview_view.visible ~= false then
    w_scn:set_excel_id(0)
  end
  p_skill_preview_player = nil
  p_target_npc = nil
end
function on_clean_preview_scene()
  if p_skill_preview_player ~= nil then
    p_skill_preview_player:terminate_skill()
    terminate_skill_call_back()
  end
  if skill_preview_view.visible ~= false and nil ~= ui_skill_preview.w_scn and nil ~= ui_skill_preview.w_scn.scn then
    w_scn.scn:clear_obj(bo2.eScnObjKind_Player)
    w_scn.scn:clear_obj(bo2.eScnObjKind_Npc)
  end
  p_skill_preview_player = nil
  p_target_npc = nil
end
function on_int_once()
  g_model_excel = {
    hair_id = 1,
    face_id = 1,
    body_id = 1,
    legs_id = 1
  }
  if blowup == nil then
    sys.load_script_dir(L("$script/scene/skill_script/cmn"))
  end
end
function runf_set_preview_skill(...)
  local _group_id = arg[1].v_int
  local _idx = arg[2].v_int
  set_preview_skill(_group_id, _idx)
end
function set_preview_skill(_group_id, _idx)
  if g_loading_skill_preview ~= false then
    return false
  end
  if sys.check(ui_npcfunc) and sys.check(ui_npcfunc.ui_talk.w_talk) and ui_npcfunc.ui_talk.w_talk.visible == true then
    return
  end
  if sys.check(ui_mask.w_main) and ui_mask.w_main.visible == true then
    return
  end
  local bSucess = test_may_init_skill(_group_id, _idx)
  if bSucess ~= true then
    return false
  end
  on_clean_preview_scene()
  on_init_skill(_group_id, _idx)
  ui_skill_preview.g_auto_next_scene_play = false
  set_panel_title()
  g_terminating_scn = false
  if ui_skill_preview.w_skill_preview.visible ~= true then
    ui_skill_preview.w_skill_preview.visible = true
  end
  on_reverse_link_select(g_cur_group_skill_id)
  on_load_scn()
end
function test_may_init_skill(_iGroupid, _idx)
  local _group_skill_size = ui.get_preview_skill_size(_iGroupid)
  if _group_skill_size <= 0 then
    return false
  end
  local _p_skill_preview = ui.get_preview_skill(_iGroupid, _idx)
  if _p_skill_preview == nil then
    return false
  end
  return true
end
function on_init_skill(_iGroupid, _idx)
  g_cur_group_skill_size = ui.get_preview_skill_size(_iGroupid)
  if g_cur_group_skill_size <= 0 then
    return false
  end
  g_cur_group_skill_index = _idx
  g_p_skill_preview = ui.get_preview_skill(_iGroupid, g_cur_group_skill_index)
  if g_p_skill_preview == nil then
    return false
  end
  g_cur_group_skill_id = _iGroupid
  local _action_type = g_p_skill_preview._action_type
  g_cur_skill_index = 0
  if _action_type == 0 then
    local _skill_id = g_p_skill_preview._action_param[g_cur_skill_index]
    on_init_single_skill(_skill_id)
  elseif _action_type == 1 then
    local _combo_skill_size = g_p_skill_preview._action_param.size
    local v_skill = sys.variant()
    local display_skill_list = {}
    for i = 0, _combo_skill_size - 1 do
      display_skill_list[i + 1] = g_p_skill_preview._action_param[i]
      v_skill:push_back(g_p_skill_preview._action_param[i])
    end
    on_init_combo_skill(v_skill, display_skill_list)
  end
  return true
end
function on_init_single_skill(_skill_id)
  g_skill_preview_id = _skill_id
  g_combo_skill = nil
  g_display_skill_list = {}
  g_cur_increase_per = g_skill_increase_per
end
function on_init_combo_skill(v_skill_id, display_skill_list)
  g_combo_skill = v_skill_id
  g_display_skill_list = display_skill_list
  g_skill_preview_id = nil
  g_cur_increase_per = g_combol_increase_per
end
function display_single_skill(_skill_id)
  local display_skill = function(num, image)
    if num ~= nil then
      w_display:search("pic" .. num).image = image
      w_display:reset(0, 1, 1, 0)
      w_display.visible = true
      return true
    end
  end
  g_display_skill_list = {}
  local icon = ui.get_skill_icon(_skill_id)
  if icon ~= nil then
    display_skill(1, nil)
    display_skill(2, nil)
    display_skill(3, icon.uri)
    display_skill(4, nil)
    display_skill(5, nil)
    display_skill(6, nil)
  end
end
function disable_display_arrow()
  for i = 1, 6 do
    w_display:search("next" .. i).visible = false
  end
end
function display_combo_skill(_id)
  local display_skill = function(num, image, itr, size)
    if size ~= nil and itr < size and num < 6 then
      w_display:search("next" .. num).visible = true
    end
    if num ~= nil then
      w_display:search("pic" .. num).image = image
    end
  end
  local combo_skill_size = #g_display_skill_list
  disable_display_arrow()
  if combo_skill_size <= 0 or _id >= combo_skill_size then
    end_skill()
    return
  end
  local i_end = _id - 2
  for i = 1, 6 do
    local itr = i_end + i
    if itr >= 1 and combo_skill_size >= itr then
      local icon = ui.get_skill_icon(g_display_skill_list[itr])
      display_skill(i, icon.uri, itr, combo_skill_size)
    else
      display_skill(i, nil)
    end
  end
end
function on_display_combo_skill()
  w_display:reset(1, 1, 1, 0)
  w_display.visible = true
  display_combo_skill(0)
end
function end_combo_skill(_id)
  display_combo_skill(_id)
end
function on_canel_auto_play_all_skill()
end
function on_may_active_auto_play_all_skill()
  return g_auto_play_all_skill
end
function on_active_auto_play_all_skill()
end
function on_canel_auto_play()
  g_auto_play_skill = false
  ui_skill_preview.btn_auto_play.check = false
end
function on_click_toggle_sex(btn)
  btn.visible = false
  if btn == w_toggle_sex0 then
    w_toggle_sex1.visible = true
  else
    w_toggle_sex0.visible = true
  end
end
function on_click_active_trangle_camera()
  if sys.check(ui_skill_preview.w_scn) and sys.check(ui_skill_preview.w_scn.scn) then
    ui_skill_preview.w_scn.scn:active_trangle_camera(ui_skill_preview.btn_locked_camera.check)
  end
end
function on_active_auto_play()
  g_auto_play_skill = true
  ui_skill_preview.btn_auto_play.check = true
end
function on_timer_end_skill()
  wait_for_end_skill.suspended = true
  if g_wait_for_skill ~= true then
    return
  end
  g_wait_for_skill = false
  if g_auto_play_skill ~= false and g_terminating_scn ~= true and g_p_skill_preview ~= nil and g_cur_group_skill_index + 1 < g_cur_group_skill_size then
    g_cur_group_skill_index = g_cur_group_skill_index + 1
    g_auto_next_scene_play = true
    set_loading_new_scene()
    return
  end
  if g_auto_play_all_skill ~= false and g_terminating_scn ~= true and g_p_skill_preview ~= nil then
    local function get_cur_skill_idx()
      if g_cur_group_skill_id == 0 then
        return -1
      end
      local iSize = bo2.gv_skill_preview.size
      iSize = iSize - 1
      local i = 0
      if g_auto_play_all_skill_idx ~= -1 then
        i = g_auto_play_all_skill_idx
        if iSize < i then
          i = 0
        end
      end
      local pCurExcel
      for idx = i, iSize do
        local pExcel = bo2.gv_skill_preview:get(idx)
        if pExcel ~= nil and pExcel._group_id == g_p_skill_preview._group_id then
          local find_idx = idx
          for nIdx = find_idx, iSize do
            pCurExcel = bo2.gv_skill_preview:get(nIdx)
            if pCurExcel ~= nil and pCurExcel._group_id ~= g_p_skill_preview._group_id then
              break
            elseif pCurExcel == nil then
              break
            end
            pCurExcel = nil
          end
          break
        end
      end
      if pCurExcel == nil then
        pCurExcel = bo2.gv_skill_preview:get(0)
      end
      g_cur_group_skill_id = pCurExcel._group_id
      g_cur_group_skill_index = 0
    end
    get_cur_skill_idx()
    g_auto_next_scene_play = true
    set_loading_new_scene()
  end
end
function terminate_skill_call_back()
  wait_for_end_skill.suspended = true
  g_wait_for_skill = false
end
function end_skill()
  w_display:reset(1, 0, 500)
  g_using_skill = false
  wait_for_end_skill.suspended = false
  g_wait_for_skill = true
end
function on_click_show_angle(w)
  local _scn = w_scn.scn
  local yaw = _scn:get_camera_angle(0)
  local pitch = _scn:get_camera_angle(1)
  local radius = _scn:get_camera_angle(2)
  ui_skill_preview.rb_show_angle.mtf = "yaw : " .. yaw .. [[

pitch : ]] .. pitch .. [[

radius]] .. radius
end
function on_click_use_skill()
  local _enable_value = function(_value)
    if _value ~= nil and _value > 0 then
      return true
    else
      return false
    end
    return false
  end
  if g_skill_preview_id ~= nil then
    if g_p_skill_preview ~= nil then
      local bEnablePassive = _enable_value(g_p_skill_preview.enable_jump_passive_skill)
      local bEnableState = _enable_value(g_p_skill_preview.enable_jump_state)
      local bEnableDamageState = _enable_value(g_p_skill_preview.enable_damage_jump_state)
      ui.log("g_p_skill_preview.enable_damage_jump_state " .. g_p_skill_preview.enable_jump_passive_skill .. " " .. g_p_skill_preview.id)
      p_skill_preview_player:use_skill(g_skill_preview_id, p_target_npc.sel_handle, nil, 100, end_skill, bEnablePassive, bEnableState, bEnableState, bEnableDamageState)
      g_using_skill = true
      if _enable_value(g_p_skill_preview.target_skill) ~= false then
        local _tmp_end_skill = function()
          return true
        end
        p_target_npc:use_skill(g_p_skill_preview.target_skill, p_skill_preview_player.sel_handle, nil, 100, _tmp_end_skill, bEnablePassive, bEnableState, bEnableState, bEnableDamageState)
      end
    else
      ui.log("g_p_skill_preview. ")
      p_skill_preview_player:use_skill(g_skill_preview_id, p_target_npc.sel_handle, nil, 100, end_skill, true, true, true)
      g_using_skill = true
    end
    display_single_skill(g_skill_preview_id)
  elseif g_combo_skill ~= nil then
    if g_p_skill_preview ~= nil then
      local bEnablePassive = _enable_value(g_p_skill_preview.enable_jump_passive_skill)
      local bEnableState = _enable_value(g_p_skill_preview.enable_jump_state)
      if _enable_value(g_p_skill_preview.target_skill) ~= false then
        local _tmp_end_skill = function()
          return true
        end
        p_target_npc:use_skill(g_p_skill_preview.target_skill, p_skill_preview_player.sel_handle, nil, 100, _tmp_end_skill, bEnablePassive, bEnableState, bEnableState, bEnableDamageState)
      end
      p_skill_preview_player:use_combo_skill(g_combo_skill, p_target_npc.sel_handle, nil, 100, end_combo_skill, bEnablePassive, bEnableState, bEnableState)
      g_using_skill = true
    else
      p_skill_preview_player:use_combo_skill(g_combo_skill, p_target_npc.sel_handle, nil, 100, end_combo_skill, true, true, true)
      g_using_skill = true
    end
    on_display_combo_skill()
  end
end
function on_click_terminate_skill()
  if p_skill_preview_player ~= nil then
    g_terminating_scn = true
    p_skill_preview_player:terminate_skill()
    terminate_skill_call_back()
  end
end
function on_close_click(btn)
  if g_loading_skill_preview ~= false then
    return
  end
  w_skill_preview.visible = false
  set_level_one_panel(g_select_xinfa, false)
  set_level_two_panel(g_select_skill, false)
end
function on_visible_skill_preview(w, vis)
  if vis then
    on_init_skill_preview_list()
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    g_replay_camera = nil
    on_reverse_link_select(g_cur_group_skill_id)
    on_active_auto_play()
    g_loaded_scn = true
  else
    g_wait_for_skill = false
    if g_loading_skill_preview ~= true then
      on_click_terminate_skill()
      on_destroy_scn()
      on_call_back_end_progress(true, false, nil)
    end
    ui_widget.esc_stk_pop(w)
  end
end
function set_panel_title()
  if g_p_skill_preview == nil then
    return
  end
  local mtf_param = {
    skill_name = g_p_skill_preview.desc,
    idx = g_cur_group_skill_index + 1,
    total = g_cur_group_skill_size
  }
  local set_msg = ui_widget.merge_mtf(mtf_param, ui.get_text("skill|skill_preview_title"))
  lb_preview_title.text = set_msg
end
function set_loading_tips()
  if g_p_skill_preview ~= nil then
    local w_loading_tips = w_skill_preview:search("loadind_tips")
    w_loading_tips.text = g_p_skill_preview.loading_text
  end
end
function set_preview_tips()
  if g_p_skill_preview ~= nil then
    show_preview_tips.mtf = g_p_skill_preview.preview_text
    show_preview_tips.parent:tune("skill_tips")
  end
end
function on_click_play_skill(btn)
  local pParent = btn.parent.parent
  local idx = pParent.var:get(set_var_skill_id).v_int
  if idx == 0 then
    return
  end
  g_replay_camera = nil
  ui_skill_preview.g_auto_next_scene_play = false
  set_preview_skill(idx, 0)
  on_active_auto_play()
end
function on_click_replay_skill(btn)
  if g_loading_skill_preview ~= false or g_cur_group_skill_id == nil or g_p_skill_preview == nil then
    return
  end
  if w_scn ~= nil and w_scn.scn ~= nil then
    local _scn = w_scn.scn
    g_replay_camera = {}
    g_replay_camera.yaw = _scn:get_camera_angle(0)
    g_replay_camera.pitch = _scn:get_camera_angle(1)
    g_replay_camera.radius = _scn:get_camera_angle(2)
  end
  set_preview_skill(g_cur_group_skill_id, g_cur_group_skill_index)
  on_canel_auto_play()
  on_canel_auto_play_all_skill()
end
function on_click_set_auto_play(btn)
  g_auto_play_skill = not g_auto_play_skill
end
function on_click_set_auto_play_all_skill(btn)
  g_auto_play_all_skill = not g_auto_play_all_skill
end
function on_click_set_next_stage()
  if g_loading_skill_preview ~= false or g_cur_group_skill_id == nil then
    return
  end
  local iNextIdx = g_cur_group_skill_index + 1
  if iNextIdx >= g_cur_group_skill_size then
    iNextIdx = 0
  end
  local _p_skill_preview_execl = ui.get_preview_skill(g_cur_group_skill_id, iNextIdx)
  if _p_skill_preview_execl == nil then
    return false
  end
  g_replay_camera = nil
  g_cur_group_skill_index = iNextIdx
  g_p_skill_preview = _p_skill_preview_execl
  set_panel_title()
  set_preview_skill(g_cur_group_skill_id, g_cur_group_skill_index)
  on_canel_auto_play()
  on_canel_auto_play_all_skill()
end
function on_click_set_prev_stage()
  if g_loading_skill_preview ~= false or g_cur_group_skill_id == nil then
    return
  end
  local iNextIdx = g_cur_group_skill_index - 1
  if iNextIdx < 0 then
    iNextIdx = g_cur_group_skill_size - 1
  end
  local _p_skill_preview_execl = ui.get_preview_skill(g_cur_group_skill_id, iNextIdx)
  if _p_skill_preview_execl == nil then
    return false
  end
  g_replay_camera = nil
  g_cur_group_skill_index = iNextIdx
  g_p_skill_preview = _p_skill_preview_execl
  set_panel_title()
  set_preview_skill(g_cur_group_skill_id, g_cur_group_skill_index)
  on_canel_auto_play()
  on_canel_auto_play_all_skill()
end
function on_click_show_combo_panel()
  local bVisible = ui_skill_preview.combo_skill_div.parent.visible
  ui_skill_preview.combo_skill_div.parent.visible = not bVisible
  on_canel_auto_play()
end
function on_click_close_combo_skill()
  ui_skill_preview.combo_skill_div.parent.visible = false
end
function save_combo_skill(combo_idx, skill_preview_excel)
  local generate = function(msg)
    if msg.result == 0 then
      return
    end
    bo2.send_variant(packet.eCTS_ScnObj_SeriesSkill, msg.data)
  end
  local var = sys.variant()
  local skill = sys.variant()
  local iSize = skill_preview_excel._action_param.size
  for i = 0, iSize - 1 do
    local iSkillId = skill_preview_excel._action_param[i]
    local skill_info = ui.skill_find(iSkillId)
    if sys.check(skill_info) ~= true or 0 >= skill_info.level then
      local pExcel = bo2.gv_skill_group:find(iSkillId)
      if sys.check(pExcel) then
        local name = pExcel.name
        local error_text = ui_widget.merge_mtf({skill_name = name}, ui.get_text("skill|create_serie_faild"))
        ui_tool.note_insert(error_text, L("FFFF0000"))
      else
        local error_text = ui.get_text("skill|create_serie_faild_unknow_name")
        ui_tool.note_insert(error_text, L("FFFF0000"))
      end
      return
    end
    skill:push_back(iSkillId)
  end
  local text = ui_skill_preview.lb_preview_title.text
  var:set(packet.key.series_skill_id, combo_idx)
  var:set(packet.key.series_skill_data, skill)
  var:set(packet.key.series_skill_desc, text)
  local msg = {
    callback = generate,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.title = ui.get_text("skill|create_serie")
  msg.text = sys.format("<lb:,,,ffff00|" .. ui.get_text("skill|lianzhao_desc") .. ">%s", text)
  msg.data = var
  ui_widget.ui_msg_box.show_common(msg)
end
function on_click_save_combo_skill()
  local iIdx = -1
  for i = 0, 4 do
    local cell_name = sys.format("cell" .. i)
    local _cell = ui_skill_preview.combo_skill_div:search(cell_name)
    if _cell:search("highlight").visible ~= false then
      iIdx = i
    end
  end
  if iIdx < 0 then
    local text = sys.format(ui.get_text("skill|select_default"))
    ui_tool.note_insert(text, L("FFFF0000"))
    return
  end
  local _p_skill_preview_execl = ui.get_preview_skill(g_cur_group_skill_id, g_cur_group_skill_index)
  if _p_skill_preview_execl == nil or _p_skill_preview_execl._action_type ~= 1 then
    local text = sys.format(ui.get_text("skill|select_combo_skill"))
    ui_tool.note_insert(text, L("FFFF0000"))
    return false
  end
  save_combo_skill(iIdx + 1, _p_skill_preview_execl)
end
function cancel_all_combo_skill_item_hight_light()
  for i = 0, 4 do
    local cell_name = sys.format("cell" .. i)
    local _cell = ui_skill_preview.combo_skill_div:search(cell_name)
    _cell:search("highlight").visible = false
  end
end
function on_click_combo_skill_item(btn, msg)
  if msg == ui.mouse_lbutton_down then
    local hight_light = btn:search("highlight")
    if hight_light.visible ~= true then
      cancel_all_combo_skill_item_hight_light()
      hight_light.visible = true
    else
      hight_light.visible = false
    end
  end
end
function on_init_combo_skill_item()
  local iSizeSerieSkill = bo2.gv_serie_skill.size
  local iCount = 0
  for i = 0, iSizeSerieSkill - 1 do
    local p_serie_skill = bo2.gv_serie_skill:find(i)
    if p_serie_skill ~= nil and p_serie_skill.type == 1 then
      local cell_name = sys.format("cell" .. iCount)
      local item = ui_skill_preview.combo_skill_div:search(cell_name)
      iCount = iCount + 1
      item:search("lianzhao_icon").image = "$icon/skill/lianzhao/" .. p_serie_skill.icon .. ".png"
    end
    if iCount > g_iMaxSeiveSkill then
      break
    end
  end
end
function on_init_bind_data()
  lb_preview_title = ui_skill_preview.w_skill_preview:search("lb_title")
end
on_int_once()
