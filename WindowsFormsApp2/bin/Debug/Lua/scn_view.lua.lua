MODULE_NUM = 5
local POINT_START = L("cam_start")
local MODULE_START = L("cam_xuanren_start")
c_choice_weapon = "$image/phase/choice_weapon"
local FLIGHT_SELECT = L("flr_line_jscj_001")
local FLIGHT_SELECT_BACK = L("flr_line_jscj_008")
POINT_JUSE1 = L("juese_01")
POINT_JUSE2 = L("juese_02")
POINT_JUSE3 = L("juese_03")
POINT_JUSE4 = L("juese_04")
POINT_JUSE5 = L("juese_05")
point_juse_list = {
  POINT_JUSE5,
  POINT_JUSE4,
  POINT_JUSE3,
  POINT_JUSE2,
  POINT_JUSE1
}
local ANIM_REST = 546
local ANIM_SELECTED = 547
local ANIM_SELECTED_REST = 548
local ANIM_BACK = 549
local ANIM_PRO_SELECTED = 550
local ANIM_EXPECT = 545
local ANIM_FIGHT_REST = 4
local ANIM_FIGHT = 1001
ANIM_GET_WEAPON = 86
local ANIM_SET_WEAPON = 88
local SELECT_MOON = -1
local SELECT_PLAYER = 0
local SELECT_EXPECT = 1
local SELECT_MODULE = 2
local SELECT_PRO = 3
local SELECT_JUMP_IN = 4
local CUR_STAGE = SELECT_MOON
local PLAYER_REST = 0
local PLAYER_GET = 1
local PLAYER_FIGHT = 2
local PLAYER_FIGHT_REST = 3
local PLAYER_SET = 4
local PLAYER_BACK = 5
local last_flight
local sounds = {}
sounds.anim = {}
sounds.anim[1] = {
  {7212, 7213},
  {7214, 7215},
  {7216, 7217},
  {7218, 7219},
  {7220, 7221},
  {7222, 7223},
  {7224, 7225},
  {7224, 7225}
}
sounds.anim[2] = {
  {7184, 7185},
  {7186, 7187},
  {7188, 7189},
  {7190, 7191},
  {7192, 7193},
  {7194, 7195},
  {7196, 7197},
  {7196, 7197}
}
sounds.anim[6] = {
  {7155, 7156},
  {7157, 7158},
  {7159, 7160},
  {7161, 7162},
  {7163, 7164},
  {7165, 7166},
  {7167, 7168},
  {7167, 7168}
}
sounds.anim[7] = {
  {7170, 7171},
  {7172, 7173},
  {7174, 7175},
  {7176, 7177},
  {7178, 7179},
  {7180, 7181},
  {7182, 7183},
  {7182, 7183}
}
sounds.anim[11] = {
  {7198, 7199},
  {7200, 7201},
  {7202, 7203},
  {7204, 7205},
  {7206, 7207},
  {7208, 7209},
  {7210, 7211},
  {7210, 7211}
}
sounds.anim[12] = {
  {7212, 7213},
  {7214, 7215},
  {7216, 7217},
  {7218, 7219},
  {7220, 7221},
  {7222, 7223},
  {7224, 7225},
  {7224, 7225}
}
sounds.move = {}
sounds.move[1] = {7153, 7154}
sounds.move[2] = {7149, 7150}
sounds.move[6] = {7145, 7146}
sounds.move[7] = {7147, 7148}
sounds.move[11] = {7151, 7152}
sounds.move[12] = {7153, 7154}
local sil_red_color = ui.make_color("FF0000")
local sil_gold_color = ui.make_color("FFC54D")
function set_player_selected_sil(player, show)
  if select_player_list[player] then
    local info = select_player_list[player].info
    if info and info.retain_second == 0 then
      if show == true then
        player:setSilEffect(sil_gold_color)
      else
        player:setSilEffect(0)
      end
    end
  end
end
function set_stage(stage)
  CUR_STAGE = stage
end
function get_stage(stage)
  return CUR_STAGE
end
function create_scn_view(arg)
  ui.log("create_scn_view")
  if not sys.check(w_scn_view_top) then
    local p = ui.create_control(w_top, "panel")
    p:load_style("$gui/phase/choice/scn_view.xml", "choice_scn_view")
    w_scn_view:load_scn(21)
    w_scn_view.scn:ScnSetCurCamera(0)
  end
  if sys.check(w_scn_view_top) then
    scn_view_init()
  end
  local scn = w_scn_view.scn
  target_point = scn:create_obj(bo2.eScnObjKind_Player, 4816, POINT_START)
  update_scn_view_player_list()
  local function fn()
    local function fn1()
      set_stage(SELECT_PLAYER)
      update_all_state()
    end
    ui.log("START_MOON_FLASH %s", START_MOON_FLASH)
    if START_MOON_FLASH then
      scn:SetCameraControl(45, target_point.sel_handle, fn1)
    else
      scn:SetCameraControl(55, target_point.sel_handle, fn1)
    end
    START_MOON_FLASH = false
  end
  local function show_choice()
    ui_loading.show_top(false)
    ui_tool.tool_clear()
    w_scn_view.focus = true
    ui.set_default_focus(w_scn_view)
    if arg == "login notice" then
      ui.log("show notice.")
      ui_widget.ui_wnd.show_notice({
        text = ui.get_text("phase|queue_over"),
        timeout = 3600,
        force_timeout = false
      })
    end
  end
  local function SetCameraControl()
    scn:SetCameraControl(40, target_point.sel_handle, fn, false, false)
    w_scn_view.focus = true
    ui.set_default_focus(w_scn_view)
    bo2.AddTimeEvent(1, show_choice)
  end
  local function load_res(f, str)
    if str == L("ResLoad leave") then
      if cha_count == 0 then
        set_stage(SELECT_EXPECT)
        update_all_state()
        update_buttons()
        bo2.AddTimeEvent(1, show_choice)
      else
        set_stage(SELECT_MOON)
        START_MOON_FLASH = true
        bo2.AddTimeEvent(1, SetCameraControl)
        update_all_state()
        update_buttons()
        w_scn_view.mouse_able = false
      end
    end
  end
  scn:start_res_load(target_point, load_res)
end
function destroy_scn_view()
  if sys.check(w_scn_view_top) then
    w_scn_view_top:post_release()
  end
end
function update_scn_view_player_list()
  cha_count = 0
  local tmp_name_list = {}
  if sys.check(w_scn_view_top) then
    for k, v in pairs(player_list_data) do
      tmp_name_list[v.only_id] = scn_view_player_build(k, v)
      cha_count = cha_count + 1
    end
    for k, v in pairs(select_player_list) do
      if tmp_name_list[v.info.only_id] == nil and sys.check(k) then
        w_scn_view.scn:destory_obj(k)
        select_player_list[k] = nil
      end
    end
  end
  if sys.check(w_scn_view) then
    set_stage(SELECT_PLAYER)
    update_all_state()
    w_scn_view.scn:MoveToScnPoint(POINT_START)
  end
end
function scn_view_init()
  ui.log("scn_view_init")
  w_scn_view.scn:ScnSetCurCamera(0)
  w_scn_view.scn:SetCameraHandShaker(true)
  w_scn_view.scn:SetCamFar(800)
  w_scn_view.scn:bind_soundmgr()
  w_scn_view.scn:use_camera_update_sound_area(true)
  w_scn_view.scn:use_camera_update_music_area(true)
  w_scn_view.scn:clear_obj(-1)
  module_list = {}
  select_player_list = {}
  select_info = {}
  select_player_id_list = {}
  if sys.check(curent_select_player) then
    curent_select_player:sethighlum(false)
    set_player_selected_sil(curent_select_player, false)
    curent_select_player = nil
  end
  local c = bo2.gv_init_cha.size
  for i = 1, c do
    local excel = bo2.gv_init_cha:get(i - 1)
    if excel.disable ~= 1 then
      local player = w_scn_view.scn:create_obj(bo2.eScnObjKind_Player, excel.id, excel.mark_point)
      if excel.equip_hand == 1 then
        bWeaponInHand = true
      elseif excel.equip_hand == 0 then
        bWeaponInHand = false
      end
      if excel.second_equip_hand == 1 then
        b2ndWeaponInHand = true
      elseif excel.second_equip_hand == 0 then
        b2ndWeaponInHand = false
      end
      player:SetEquipIsHandle(bWeaponInHand, b2ndWeaponInHand)
      player:EquipClear()
      player:set_flag_int8(bo2.ePlayerFlagInt8_Hat, 1)
      player:set_equip_model(bo2.eEquipData_Hat, excel.hat_def)
      player:set_equip_model(bo2.eEquipData_Face, excel.face_def)
      player:set_equip_model(bo2.eEquipData_Body, excel.body[0])
      player:set_equip_model(bo2.eEquipData_Legs, excel.crura[0])
      player:set_equip_model(bo2.eEquipData_MainWeapon, excel.equip)
      player:set_equip_model(bo2.eEquipData_2ndWeapon, excel.second_equip)
      player:set_flag_int8(bo2.ePlayerFlagInt8_EyeSize, 128)
      player:set_flag_int8(bo2.ePlayerFlagInt8_EyeWide, 128)
      player:set_flag_int8(bo2.ePlayerFlagInt8_EyeBrow, 128)
      player:set_flag_int8(bo2.ePlayerFlagInt8_NostrilSize, 128)
      player:set_flag_int8(bo2.ePlayerFlagInt8_NoseBridgePos, 128)
      player:set_flag_int8(bo2.ePlayerFlagInt8_NoseGuard, 128)
      player:set_flag_int8(bo2.ePlayerFlagInt8_MouthSize, 128)
      player:set_flag_int8(bo2.ePlayerFlagInt8_PhiltrumLen, 128)
      player:set_flag_int8(bo2.ePlayerFlagInt8_MouthLipSize, 128)
      player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetWaist, excel.boneOffset[0])
      player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetNeck, excel.boneOffset[1])
      player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetUpperArm, excel.boneOffset[2])
      player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetForearm, excel.boneOffset[3])
      player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetUpperLeg, excel.boneOffset[4])
      player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetShank, excel.boneOffset[5])
      player:SetNoActionAnim(6, true)
      module_list[player] = {
        id = excel.id,
        obj = player,
        point = excel.mark_point,
        flight = excel.flight_line,
        excel = excel,
        state = "rest",
        move = "none",
        rest_times = 0
      }
      player:ViewPlayerAnimPlay(ANIM_REST, false)
    end
  end
  c = bo2.gv_init_choice.size
  for i = 1, c do
    local excel = bo2.gv_init_choice:get(i - 1)
    select_info[i] = {
      id = excel.id,
      anim1 = excel.anim1,
      anim2 = excel.anim2,
      anim3 = excel.anim3,
      anim4 = excel.anim4,
      anim5 = excel.anim5,
      anim6 = excel.anim6,
      anim7 = excel.anim7,
      anim8 = excel.anim8,
      point = excel.point
    }
  end
end
function scn_view_player_build(n, info)
  local scn = w_scn_view.scn
  n = n + 1
  local player = select_player_id_list[info.only_id]
  if player then
    player = select_player_id_list[info.only_id]
    bo2.set_view_player_postion(player, select_info[n].point)
  else
    player = scn:create_obj(bo2.eScnObjKind_Player, info.atb:bget_int(bo2.eAtb_ExcelID), select_info[n].point)
  end
  player:set_flag_int8(bo2.ePlayerFlagInt8_Hat, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_Hat))
  player:set_flag_int8(bo2.ePlayerFlagInt8_Body, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_Body))
  player:set_flag_int8(bo2.ePlayerFlagInt8_Legs, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_Legs))
  player:set_flag_int8(bo2.ePlayerFlagInt8_EyeSize, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_EyeSize))
  player:set_flag_int8(bo2.ePlayerFlagInt8_EyeWide, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_EyeWide))
  player:set_flag_int8(bo2.ePlayerFlagInt8_EyeBrow, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_EyeBrow))
  player:set_flag_int8(bo2.ePlayerFlagInt8_NostrilSize, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_NostrilSize))
  player:set_flag_int8(bo2.ePlayerFlagInt8_NoseGuard, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_NoseGuard))
  player:set_flag_int8(bo2.ePlayerFlagInt8_MouthLipSize, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_MouthLipSize))
  player:set_flag_int8(bo2.ePlayerFlagInt8_MouthSize, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_MouthSize))
  player:set_flag_int8(bo2.ePlayerFlagInt8_PhiltrumLen, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_PhiltrumLen))
  player:set_flag_int8(bo2.ePlayerFlagInt8_NoseBridgePos, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_NoseBridgePos))
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetWaist, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_BoneOffsetWaist))
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetNeck, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_BoneOffsetNeck))
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetUpperArm, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_BoneOffsetUpperArm))
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetForearm, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_BoneOffsetForearm))
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetUpperLeg, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_BoneOffsetUpperLeg))
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetShank, info.flag_int8:bget_int8(bo2.ePlayerFlagInt8_BoneOffsetShank))
  player:set_flag_int32(bo2.ePlayerFlagInt32_EquipSet, info.flag_int32:bget_int(bo2.ePlayerFlagInt32_EquipSet))
  player:set_hair_color(info.flag_int32:bget_int(bo2.ePlayerFlagInt32_HairColor))
  player:EquipClear()
  local equip = info.equip
  for i = 0, bo2.eEquipData_Number - 1 do
    player:set_equip_model(i, equip:bget_int(i))
  end
  player:set_view_player_profession(info.atb:bget_int(bo2.eAtb_Cha_Profession))
  local pro_excel = bo2.gv_profession_list:find(info.atb:bget_int(bo2.eAtb_Cha_Profession))
  local career
  if pro_excel then
    career = bo2.gv_profession_list:find(info.atb:bget_int(bo2.eAtb_Cha_Profession)).career
  end
  player:SetNoActionAnim(6, true)
  select_player_id_list[info.only_id] = player
  select_player_list[player] = {
    id = info.atb:bget_int(bo2.eAtb_ExcelID),
    obj = player,
    point = point_juse_list[n],
    item = player_list_item[n - 1],
    info = info,
    state = PLAYER_REST,
    career = career,
    select_info = select_info[n],
    move = "none",
    pos_id = n
  }
  player:ViewPlayerAnimPlay(select_player_list[player].select_info.anim1, true)
  if info.retain_second ~= 0 then
    player:setSilEffect(sil_red_color)
  else
    player:setSilEffect(0)
  end
  return player
end
function playselectsound(player, action, flag)
  if player == nil then
    return
  end
  local info = select_player_list[player].info
  if info == nil then
    return
  end
  local pro_excel = bo2.gv_profession_list:find(info.atb:bget_int(bo2.eAtb_Cha_Profession))
  playsound(info.atb:bget_int(bo2.eAtb_ExcelID), pro_excel.career, action, flag)
end
function playmodelsound(player, action, flag)
  local id = module_list[player].id
  if id == nil then
    return
  end
  ui.log("id %s", id)
  if action == "move" then
    bo2.PlaySound2D(sounds.move[id][flag])
  elseif action == "anim" then
    local career_id = build_info.career_excel.id
    bo2.PlaySound2D(sounds.anim[id][career_id][flag], false)
  end
end
function playsound(model, career, action, flag)
  ui.log("model %s career %s action %s", model, career, action)
  if action == "anim" then
    bo2.PlaySound2D(sounds.anim[model][career][flag], false)
  elseif action == "move" then
    bo2.PlaySound2D(sounds.move[model][flag])
  end
end
function playeranim(player, anim, b)
  local function end_skill(index, player)
    if select_player_list[player].state == PLAYER_GET then
      player:ViewPlayerAnimPlay(ANIM_FIGHT_REST, true)
    elseif select_player_list[player].state == PLAYER_SET then
      player:ViewPlayerAnimPlay(ANIM_REST, true)
    end
  end
  local end_module_skill = function(index, player)
    if module_list[player] and build_info and build_info.player == player then
      player:ViewPlayerAnimPlay(1, true)
    end
  end
  if player == build_info.player and get_stage() == SELECT_PRO then
    local career = build_info.career_excel.id
    if career == 1 then
      player:use_skill(4057, target_point.sel_handle, nil, 100, end_module_skill, false, false, false, false)
    elseif career == 2 then
      player:use_skill(2049, target_point.sel_handle, nil, 100, end_module_skill, false, false, false, false)
    elseif career == 3 then
      player:use_skill(28, target_point.sel_handle, nil, 100, end_module_skill, false, false, false, false)
    elseif career == 4 then
      player:use_skill(6022, target_point.sel_handle, nil, 100, end_module_skill, false, false, false, false)
    elseif career == 5 then
      player:use_skill(8021, target_point.sel_handle, nil, 100, end_module_skill, false, false, false, false)
    elseif career == 6 then
      player:use_skill(10027, target_point.sel_handle, nil, 100, end_module_skill, false, false, false, false)
    end
    return
  end
end
function on_select_player(item)
  for k, v in pairs(select_player_list) do
    if v.item.bar == item then
      v.item.bar.visible = true
      if sys.check(curent_select_player) then
        select_player_list[curent_select_player].move = "moving_back"
        curent_select_player:sethighlum(false)
        set_player_selected_sil(curent_select_player, false)
      end
      curent_select_player = k
      v.move = "moving_front"
      curent_select_player:sethighlum(true)
      set_player_selected_sil(curent_select_player, true)
    else
      v.item.bar.visible = false
    end
  end
end
function on_scn_view_mouse(btn, msg, pos)
  if msg == ui.mouse_move then
    if get_stage() == SELECT_PLAYER then
      return
    end
    local obj = w_scn_view.scn:GetScnObjSelected(pos.x, pos.y, w_scn_view.dx, w_scn_view.dy)
    if module_list[obj] == nil then
      for k, v in pairs(module_list) do
        if k ~= build_info.player then
          k:setlum(false)
        end
      end
      return
    end
    for k, v in pairs(module_list) do
      if obj == k then
        k:setlum(true)
      elseif k ~= build_info.player then
        k:setlum(false)
      end
    end
    obj:setlum(true)
  elseif msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_dbl then
    local obj = w_scn_view.scn:GetScnObjSelected(pos.x, pos.y, w_scn_view.dx, w_scn_view.dy)
    if module_list[obj] then
      if get_stage() == SELECT_PLAYER then
        return
      end
      if obj == build_info.player and msg == ui.mouse_lbutton_click then
        return
      end
      if module_list[obj].move == "back_moving" and msg == ui.mouse_lbutton_click then
        return
      end
      if sys.check(build_info.player) and obj ~= build_info.player then
        module_list[build_info.player].state = "ready_back"
      end
      build_info.model_excel = module_list[obj].excel
      build_info.player = obj
      if msg == ui.mouse_lbutton_dbl then
        show_choice_weapon()
        return
      end
      if msg == ui.mouse_lbutton_click then
        module_list[obj].state = "ready_front"
        set_stage(SELECT_MODULE)
        update_all_state()
      end
    elseif select_player_list[obj] then
      on_player_item_mouse(select_player_list[obj].item.bar, msg)
    end
  end
end
function set_pos()
  if sys.check(build_info.player) then
    local excel = module_list[build_info.player].excel
    w_scn_view.scn:MoveToScnDisAndAngle(module_list[build_info.player].point, excel.view_x, excel.view_y, excel.view_z, excel.angle_x, excel.angle_y, excel.angle_z)
    angelx = excel.angle_x
    angely = excel.angle_y
    angelz = excel.angle_z
    test_posx = excel.view_x
    test_posy = excel.view_y
    test_posz = excel.view_z
  end
end
local f_rot_angle = 90
local frq = 50
function on_build_doll_rotl_press(btn, press)
  if press then
    doll_rotl = true
    w_rot_timer.period = 1000 / frq
    w_rot_timer.suspended = false
  else
    doll_rotl = false
    w_rot_timer.suspended = true
  end
end
function on_build_doll_rotr_press(btn, press)
  if press then
    doll_rotr = true
    w_rot_timer.period = 1000 / frq
    w_rot_timer.suspended = false
  else
    doll_rotr = false
    w_rot_timer.suspended = true
  end
end
function on_module_rot()
  if doll_rotl == true and build_info.player then
    build_info.player.angle = build_info.player.angle + 0.0785
  end
  if doll_rotr == true and build_info.player then
    build_info.player.angle = build_info.player.angle - 0.0785
  end
end
eTask_AnimShowWeapon = 9
function on_timer()
  for k, v in pairs(module_list) do
    if v.state == "ready_pro" then
      v.state = "rest"
      v.move = "none"
      k:ViewPlayerAnimPlayFadeIn(ANIM_REST, 0, 1, true)
    end
    if v.state == "ready_front" and v.move ~= "front_moving" and v.move ~= "back_moving" and get_stage() ~= SELECT_PRO then
      k:ViewPlayerAnimPlay(ANIM_SELECTED, false)
      if v.move ~= "ready_back" then
        v.state = "none"
      end
      playmodelsound(k, "move", 1)
      v.move = "front_moving"
    end
    if v.state == "ready_back" and v.move ~= "front_moving" and v.move ~= "back_moving" and get_stage() ~= SELECT_PRO then
      k:ViewPlayerAnimPlay(ANIM_BACK, false)
      if v.move ~= "ready_back" then
        v.state = "none"
      end
      playmodelsound(k, "move", 2)
      v.move = "back_moving"
    end
    if k:IsAnimPlay() == false then
      if k == build_info.player and get_stage() ~= SELECT_PRO then
        k:ViewPlayerAnimPlay(ANIM_SELECTED_REST, false)
        v.move = "none"
        v.state = "selected_rest"
      elseif k ~= build_info.player and get_stage() ~= SELECT_PRO and v.move == "front_moving" then
        v.state = "ready_back"
        v.move = "none"
      elseif get_stage() == SELECT_PRO then
        if v.state == "pro_flight" then
          k:ViewPlayerAnimPlay(ANIM_FIGHT_REST, false)
          v.rest_times = v.rest_times + 1
          if 2 <= v.rest_times then
            v.state = "ready_get"
          end
        elseif v.state == "ready_get" then
          k:show_weapon(false)
          playmodelsound(k, "anim", 2)
          v.state = "ready_rest"
        elseif v.state == "ready_rest" then
          if bo2.getactiontask(k, eTask_AnimShowWeapon) == false then
            return
          elseif v.id == 7 then
            k:ViewPlayerAnimPlay(ANIM_REST, true)
          else
            k:ViewPlayerAnimPlay(1, true)
          end
        elseif v.state ~= "flight_rest" then
          k:ViewPlayerAnimPlay(ANIM_REST, false)
          v.state = "rest"
          v.move = "none"
        end
      elseif v.state == "none" then
        k:ViewPlayerAnimPlayFadeIn(ANIM_REST, 0, 1, true)
        v.move = "none"
        v.state = "rest"
      end
    end
  end
  for k, v in pairs(select_player_list) do
    if v.move == "moving_front" and v.state == PLAYER_REST then
      k:ViewPlayerAnimPlayFadeIn(v.select_info.anim2, 0.5, 1, false)
      v.state = PLAYER_GET
    end
    if v.move == "moving_back" and v.state == PLAYER_FIGHT_REST then
      k:ViewPlayerAnimPlayFadeIn(v.select_info.anim4, 0.5, 1, false)
      v.state = PLAYER_SET
    end
    if k:IsAnimPlay() == false then
      if v.state == PLAYER_GET then
        k:ViewPlayerAnimPlayFadeIn(v.select_info.anim3, 0.2, 1, true)
        v.state = PLAYER_FIGHT_REST
      elseif v.state == PLAYER_SET then
        k:ViewPlayerAnimPlayFadeIn(v.select_info.anim1, 0.2, 1, true)
        v.state = PLAYER_REST
      end
    end
  end
end
function disable_buttons()
  w_entergame.visible = false
  w_return_startup.visible = false
  w_delcha.visible = false
  w_rescha.visible = false
  w_newcha.visible = false
  w_next.visible = false
  w_player_list.visible = false
  w_scn_view.mouse_able = false
  w_select_desc.visible = false
end
function ObjStartFlight(line, speed)
  local v_speed = 1
  if speed then
    v_speed = speed
  end
  w_scn_view.scn:ScnStartMove(line, v_speed, false, true, false, flight_call_back)
  last_flight = line
  disable_buttons()
end
function on_back(btn)
  bo2.PlaySound2D(537, false)
  if get_stage() == SELECT_PLAYER then
    ui_phase.ui_startup.show_top(true)
    return
  end
  if get_stage() == SELECT_EXPECT then
    ui.image_cache_remove(c_choice_weapon)
    do
      local scn = w_scn_view.scn
      local function fn()
        local function fn1()
          set_stage(SELECT_PLAYER)
          update_all_state()
        end
        scn:SetCameraControl(55, target_point.sel_handle, fn1, false, false)
      end
      local scn = w_scn_view.scn
      disable_buttons()
      scn:SetCameraControl(41, target_point.sel_handle, fn, true)
      w_scn_view.scn:SetCameraHandShaker(false)
      return
    end
  end
  if get_stage() == SELECT_MODULE then
    do
      local scn = w_scn_view.scn
      local function fn()
        local function fn1()
          set_stage(SELECT_PLAYER)
          update_all_state()
        end
        scn:SetCameraControl(55, target_point.sel_handle, fn1, false, false)
      end
      local scn = w_scn_view.scn
      disable_buttons()
      scn:SetCameraControl(41, target_point.sel_handle, fn, true)
      w_scn_view.scn:SetCameraHandShaker(false)
      return
    end
  end
  if get_stage() == SELECT_PRO then
    show_choice_weapon()
    return
  end
  disable_buttons()
  w_scn_view.scn:ScnStartMove(last_flight, 1, true, false, false, flight_call_back)
end
function on_select_next(btn)
  bo2.PlaySound2D(537, false)
  show_choice_weapon()
end
function auto_size_desc()
  local scale = w_top.dx / 3 / 624
  if scale > w_top.dy / 2 / 512 then
    scale = w_top.dy / 2 / 512
  end
  w_select_desc.dx = 624 * scale
  w_select_desc.dy = 512 * scale
  w_choice_desc_1.dx = 512 * scale
  w_choice_desc_1.dy = 512 * scale
  w_choice_desc_2.dx = 112 * scale
  w_choice_desc_2.dy = 512 * scale
  w_select_desc.parent:apply_dock()
end
function init_models()
  w_build_player.visible = false
  w_cha_panel.visible = true
  local player = build_info.player
  if not sys.check(player) then
    return
  end
  player:EquipClear()
  local excel = module_list[player].excel
  if excel.equip_hand == 1 then
    bWeaponInHand = true
  elseif excel.equip_hand == 0 then
    bWeaponInHand = false
  end
  if excel.second_equip_hand == 1 then
    b2ndWeaponInHand = true
  elseif excel.second_equip_hand == 0 then
    b2ndWeaponInHand = false
  end
  player:SetEquipIsHandle(bWeaponInHand, b2ndWeaponInHand)
  player:set_flag_int8(bo2.ePlayerFlagInt8_Hat, 1)
  player:set_equip_model(bo2.eEquipData_Hat, excel.hat_def)
  player:set_equip_model(bo2.eEquipData_Face, excel.face_def)
  player:set_equip_model(bo2.eEquipData_Body, excel.body[0])
  player:set_equip_model(bo2.eEquipData_Legs, excel.crura[0])
  player:set_equip_model(bo2.eEquipData_MainWeapon, excel.equip)
  player:set_equip_model(bo2.eEquipData_2ndWeapon, excel.second_equip)
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetWaist, excel.boneOffset[0])
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetNeck, excel.boneOffset[1])
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetUpperArm, excel.boneOffset[2])
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetForearm, excel.boneOffset[3])
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetUpperLeg, excel.boneOffset[4])
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetShank, excel.boneOffset[5])
  player:ViewPlayerAnimPlay(ANIM_REST, false)
  module_list[player].state = "rest"
  module_list[player].move = "none"
end
function update_all_state()
  local stage = get_stage()
  if stage == SELECT_MOON then
    w_player_list.visible = false
    w_entergame.visible = false
    w_return_startup.visible = false
    w_delcha.visible = false
    w_rescha.visible = false
    w_newcha.visible = false
    w_select_desc.visible = false
    w_next.visible = false
  elseif stage == SELECT_PLAYER then
    w_player_list.visible = true
    w_entergame.visible = true
    w_return_startup.visible = true
    w_delcha.visible = true
    w_rescha.visible = true
    w_newcha.visible = true
    w_select_desc.visible = false
    w_next.visible = false
    if sys.check(curent_select_player) then
      select_player_list[curent_select_player].move = "moving_back"
      select_player_list[curent_select_player].item.bar.visible = false
      if curent_select_player ~= nil then
        curent_select_player:sethighlum(false)
        set_player_selected_sil(curent_select_player, false)
        curent_select_player = nil
      end
    end
    if sys.check(player_item_sel) then
      player_item_sel:search("fig_highlight").visible = false
      player_item_sel = nil
    end
    init_models()
    build_info = {}
    for k, v in pairs(module_list) do
      module_visible(k, true)
      k.angle = 0
      k:ViewPlayerAnimPlayFadeIn(ANIM_REST, 0, 1, false)
      v.state = "none"
      v.move = "none"
      v.rest_times = 0
      k:setlum(false)
    end
    update_buttons()
    last_flight = nil
    w_scn_view.scn:SetCameraHandShaker(true)
  elseif stage == SELECT_EXPECT then
    init_models()
    auto_size_desc()
    build_info = {}
    w_player_list.visible = false
    w_entergame.visible = false
    w_return_startup.visible = true
    w_delcha.visible = false
    w_rescha.visible = false
    w_newcha.visible = false
    w_next.visible = false
    w_select_desc.visible = true
    for k, v in pairs(module_list) do
      module_visible(k, true)
      k.angle = 0
      k:ViewPlayerAnimPlayFadeIn(ANIM_REST, 0, 1, false)
      v.state = "none"
      v.move = "none"
      v.rest_times = 0
      k:setlum(false)
    end
    if sys.check(build_info.player) then
      build_info.player:setlum(true)
    end
    w_scn_view.scn:MoveToScnPoint(MODULE_START)
    w_scn_view.scn:SetCameraHandShaker(true)
    last_flight = FLIGHT_SELECT
  elseif stage == SELECT_MODULE then
    w_next.visible = true
    w_entergame.visible = false
    w_return_startup.visible = true
    w_delcha.visible = false
    w_rescha.visible = false
    w_newcha.visible = false
    w_select_desc.visible = true
    last_flight = FLIGHT_SELECT
    for k, v in pairs(module_list) do
      k:setlum(false)
    end
    if sys.check(build_info.player) then
      build_info.player:setlum(true)
    end
  elseif stage == SELECT_PRO then
    ui.log("%s", build_info.players)
    ui.log("%s", module_list[build_info.player])
    module_list[build_info.player].move = "none"
    module_list[build_info.player].state = "ready_pro"
    show_create()
    set_pos()
    bo2.AddTimeEvent(10, on_rot_reset)
  end
  w_scn_view.mouse_able = true
end
function flight_call_back(name, back)
  if name == FLIGHT_SELECT and back == true then
    set_stage(SELECT_PLAYER)
  elseif name == FLIGHT_SELECT and back == false then
    set_stage(SELECT_EXPECT)
  elseif name ~= FLIGHT_SELECT and back == false then
    set_stage(SELECT_PRO)
  elseif name ~= FLIGHT_SELECT and back == true then
    set_stage(SELECT_EXPECT)
  end
  update_all_state()
end
function module_visible(module, b)
  if sys.check(module) then
    module:SetVisible(b)
  end
end
function on_rot_reset()
  local p = w_scn_view.scn:GetScreenXYFromScnUnit(build_info.player, w_scn_view.dx, w_scn_view.dy)
  w_btn_rotl.x = p.x - 150
  w_btn_rotr.x = p.x + 150
  w_btn_rotl.y = p.y - 200
  w_btn_rotr.y = p.y - 200
end
function show_create()
  local random_camp = function()
    if math.random(1, 2) == 1 then
      w_build_detail_camp_group:search("camp_0").text = ui.get_text("phase|camp_blade")
      w_build_detail_camp_group:search("camp_1").text = ui.get_text("phase|camp_sword")
      w_build_detail_camp_group:search("camp_0").svar = bo2.eCamp_Blade
      w_build_detail_camp_group:search("camp_1").svar = bo2.eCamp_Sword
    else
      w_build_detail_camp_group:search("camp_0").text = ui.get_text("phase|camp_sword")
      w_build_detail_camp_group:search("camp_1").text = ui.get_text("phase|camp_blade")
      w_build_detail_camp_group:search("camp_0").svar = bo2.eCamp_Sword
      w_build_detail_camp_group:search("camp_1").svar = bo2.eCamp_Blade
    end
  end
  w_build_player.visible = true
  w_cha_panel.visible = false
  local model_excel = build_info.model_excel
  build_career_clear()
  local init_excel = bo2.gv_init_cha:find(model_excel.id)
  local sex = init_excel.sex
  for i = 0, bo2.gv_career.size - 1 do
    local career_excel = bo2.gv_career:get(i)
    local vis = true
    if career_excel.disable ~= 0 then
      vis = false
    elseif career_excel.sex ~= 0 then
      vis = career_excel.sex == sex
    end
  end
  update_build_info_detail()
  for k, v in pairs(module_list) do
    if k ~= build_info.player then
      module_visible(k, false)
    end
  end
  build_info.career_excel = cur_career_excel
  update_build_info_pro()
  w_build_detail_portrait.visible = true
  local camp_dis = ui_tool.tool_disable_window.player_build_camp_group
  if camp_dis == nil then
    w_build_detail_camp_group.visible = true
  end
  local p = build_info.player
  module_list[p].state = "pro_flight"
  module_list[p].rest_times = 0
  build_info.player:terminate_skill()
  p:ViewPlayerAnimPlay(ANIM_GET_WEAPON, false)
  playmodelsound(p, "anim", 1)
  p:SetEquipIsHandle(true, false)
  p:set_equip_model(bo2.eEquipData_MainWeapon, build_info.career_excel.weapon)
  random_camp()
end
function on_build_back_model_click()
  on_back()
end
function create_cha()
  ui.image_cache_insert(c_choice_weapon)
  local scn = w_scn_view.scn
  local function fn()
    local function fn1()
      set_stage(SELECT_EXPECT)
      update_all_state()
    end
    scn:SetCameraControl(54, target_point.sel_handle, fn1, false, false)
  end
  disable_buttons()
  local scn = w_scn_view.scn
  scn:SetCameraControl(41, target_point.sel_handle, fn)
  w_scn_view.scn:SetCameraHandShaker(false)
end
function on_esc_key(c, key, flag)
  if flag.down then
    return
  end
  if key == ui.VK_ESCAPE then
    local scn = w_scn_view.scn
    START_MOON_FLASH = false
    scn:SetCameraControl(46, target_point.sel_handle)
    if get_stage() == SELECT_JUMP_IN then
      scn:SetCameraControl(46, curent_select_player.sel_handle)
    end
  end
end
function on_scn_view_init()
  module_list = {}
  select_player_list = {}
end
function on_test_angelx_plus(btn)
  if sys.check(build_info.player) then
    local excel = module_list[build_info.player].excel
    angelx = angelx + 1
    w_scn_view.scn:MoveToScnDisAndAngle(module_list[build_info.player].point, test_posx, test_posy, test_posz, angelx, angely, angelz)
    w_test_angelx.text = sys.format("X\189\199\182\200:%s y\189\199\182\200:%s z\189\199\182\200:%s", angelx, angely, angelz)
  end
end
function on_test_angelx_sub(btn)
  if sys.check(build_info.player) then
    local excel = module_list[build_info.player].excel
    angelx = angelx - 1
    w_scn_view.scn:MoveToScnDisAndAngle(module_list[build_info.player].point, test_posx, test_posy, test_posz, angelx, angely, angelz)
    w_test_angelx.text = sys.format("X\189\199\182\200:%s y\189\199\182\200:%s z\189\199\182\200:%s", angelx, angely, angelz)
  end
end
function on_test_angely_plus(btn)
  if sys.check(build_info.player) then
    local excel = module_list[build_info.player].excel
    angely = angely + 1
    w_scn_view.scn:MoveToScnDisAndAngle(module_list[build_info.player].point, test_posx, test_posy, test_posz, angelx, angely, angelz)
    w_test_angelx.text = sys.format("X\189\199\182\200:%s y\189\199\182\200:%s z\189\199\182\200:%s", angelx, angely, angelz)
  end
end
function on_test_angely_sub(btn)
  if sys.check(build_info.player) then
    local excel = module_list[build_info.player].excel
    angely = angely - 1
    w_scn_view.scn:MoveToScnDisAndAngle(module_list[build_info.player].point, test_posx, test_posy, test_posz, angelx, angely, angelz)
    w_test_angelx.text = sys.format("X\189\199\182\200:%s y\189\199\182\200:%s z\189\199\182\200:%s", angelx, angely, angelz)
  end
end
function on_test_angelz_plus(btn)
  if sys.check(build_info.player) then
    local excel = module_list[build_info.player].excel
    angelz = angelz + 1
    w_scn_view.scn:MoveToScnDisAndAngle(module_list[build_info.player].point, test_posx, test_posy, test_posz, angelx, angely, angelz)
    w_test_angelx.text = sys.format("X\189\199\182\200:%s y\189\199\182\200:%s z\189\199\182\200:%s", angelx, angely, angelz)
  end
end
function on_test_angelz_sub(btn)
  if sys.check(build_info.player) then
    local excel = module_list[build_info.player].excel
    angelz = angelz - 1
    w_scn_view.scn:MoveToScnDisAndAngle(module_list[build_info.player].point, test_posx, test_posy, test_posz, angelx, angely, angelz)
    w_test_angelx.text = sys.format("X\189\199\182\200:%s y\189\199\182\200:%s z\189\199\182\200:%s", angelx, angely, angelz)
  end
end
function on_test_1()
  if sys.check(build_info.player) then
    local excel = module_list[build_info.player].excel
    test_posx = test_posx + 0.1
    w_scn_view.scn:MoveToScnDisAndAngle(module_list[build_info.player].point, test_posx, test_posy, test_posz, angelx, angely, angelz)
    w_test_pos.text = sys.format("X\198\171\210\198:%s y\198\171\210\198:%s z\198\171\210\198:%s", test_posx, test_posy, test_posz)
  end
end
function on_test_11()
  if sys.check(build_info.player) then
    local excel = module_list[build_info.player].excel
    test_posx = test_posx - 0.1
    w_scn_view.scn:MoveToScnDisAndAngle(module_list[build_info.player].point, test_posx, test_posy, test_posz, angelx, angely, angelz)
    w_test_pos.text = sys.format("X\198\171\210\198:%s y\198\171\210\198:%s z\198\171\210\198:%s", test_posx, test_posy, test_posz)
  end
end
function on_test_2()
  if sys.check(build_info.player) then
    local excel = module_list[build_info.player].excel
    test_posy = test_posy + 0.1
    w_scn_view.scn:MoveToScnDisAndAngle(module_list[build_info.player].point, test_posx, test_posy, test_posz, angelx, angely, angelz)
    w_test_pos.text = sys.format("X\198\171\210\198:%s y\198\171\210\198:%s z\198\171\210\198:%s", test_posx, test_posy, test_posz)
  end
end
function on_test_21()
  if sys.check(build_info.player) then
    local excel = module_list[build_info.player].excel
    test_posy = test_posy - 0.1
    w_scn_view.scn:MoveToScnDisAndAngle(module_list[build_info.player].point, test_posx, test_posy, test_posz, angelx, angely, angelz)
    w_test_pos.text = sys.format("X\198\171\210\198:%s y\198\171\210\198:%s z\198\171\210\198:%s", test_posx, test_posy, test_posz)
  end
end
function on_test_3()
  if sys.check(build_info.player) then
    local excel = module_list[build_info.player].excel
    test_posz = test_posz + 0.1
    w_scn_view.scn:MoveToScnDisAndAngle(module_list[build_info.player].point, test_posx, test_posy, test_posz, angelx, angely, angelz)
    w_test_pos.text = sys.format("X\198\171\210\198:%s y\198\171\210\198:%s z\198\171\210\198:%s", test_posx, test_posy, test_posz)
  end
end
function on_test_31()
  if sys.check(build_info.player) then
    local excel = module_list[build_info.player].excel
    test_posz = test_posz - 0.1
    w_scn_view.scn:MoveToScnDisAndAngle(module_list[build_info.player].point, test_posx, test_posy, test_posz, angelx, angely, angelz)
    w_test_pos.text = sys.format("X\198\171\210\198:%s y\198\171\210\198:%s z\198\171\210\198:%s", test_posx, test_posy, test_posz)
  end
end
function on_test_visible()
  w_test_panel.visible = not w_test_panel.visible
  w_test2_panel.visible = not w_test2_panel.visible
end
