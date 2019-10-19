function on_select_model(btn, msg)
  if msg == ui.mouse_lbutton_click then
    w_scn_view.scn:destory_obj(build_info.player)
    build_info.player = nil
    local id = btn.svar.id
    local excel = bo2.gv_init_cha:find(id)
    if excel.disable ~= 1 then
      local player = w_scn_view.scn:create_obj(bo2.eScnObjKind_Player, excel.id, position)
      player:SetEquipIsHandle(false, false)
      player:EquipClear()
      player:set_flag_int8(bo2.ePlayerFlagInt8_Hat, 1)
      player:set_equip_model(bo2.eEquipData_Face, excel.face_def)
      local career_excel = build_info.career_excel
      if build_info.career_excel then
        for i = 0, excel.body.size - 1, 2 do
          if excel.body[i] == career_excel.id then
            player:set_equip_model(bo2.eEquipData_Body, excel.body[i + 1])
            break
          end
        end
        for i = 0, excel.crura.size - 1, 2 do
          if excel.crura[i] == career_excel.id then
            player:set_equip_model(bo2.eEquipData_Legs, excel.crura[i + 1])
            break
          end
        end
        for i = 0, excel.hat_def.size - 1, 2 do
          if excel.hat_def[i] == career_excel.id then
            player:set_equip_model(bo2.eEquipData_Hat, excel.hat_def[i + 1])
            break
          end
        end
      else
        player:set_equip_model(bo2.eEquipData_Body, excel.body[1])
        player:set_equip_model(bo2.eEquipData_Legs, excel.crura[1])
        player:set_equip_model(bo2.eEquipData_Hat, excel.hat_def[1])
      end
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
      build_info.player = player
      local init_excel = bo2.gv_init_cha:find(excel.id)
      local sex = init_excel.sex
      build_info.sex = sex
      bo2.cannel_SpaceCB(player)
      player:ViewPlayerAnimPlayFadeIn(1, 0, 1, true, false)
      if sys.check(build_info.model_btn) then
        build_info.model_btn.press = false
        build_info.model_btn.parent:search("loop_picture").visible = false
      end
      build_info.model_btn = btn
      build_info.model_excel = excel
      build_info.model_btn.parent:search("loop_picture").visible = true
      if sys.check(build_info.career_btn) then
        show_select_career(build_info.career_btn)
      end
      update_body()
      set_whole_body(true)
    end
  elseif msg == ui.mouse_enter then
    build_info.career_mouse_btn = btn
  elseif msg == ui.mouse_leave then
    build_info.career_mouse_btn = nil
  end
end
function init_choice_form()
  w_choice_form:control_clear()
  form_list = {}
  local c = bo2.gv_init_cha.size
  local count = 0
  for i = 1, c do
    local excel = bo2.gv_init_cha:get(i - 1)
    if excel.disable ~= 1 then
      local p = ui.create_control(w_choice_form, "panel")
      p:load_style("$gui/phase/choice1/choice.xml", "xbtn")
      p:search("btn_image").image = "$image/phase/choice/btn_cf_" .. excel.id .. ".png|0,0,440,190"
      p:search("btn").svar = {
        id = excel.id
      }
      p:search("btn").svar.priority = excel.sort
      p:search("btn"):insert_on_mouse(on_select_model)
      p.dx = 77
      p.dy = 133
      p.dock = "none"
      p.dock_solo = "true"
      count = count + 1
      p.x = 800 - 77 * count
      if excel.sort == 1 or not sys.check(default_model_btn) then
        default_model_btn = p:search("btn")
      end
      table.insert(form_list, p)
    end
  end
  local sort = function(a, b)
    return a:search("btn").svar.priority < b:search("btn").svar.priority
  end
  table.sort(form_list, sort)
  for i = #form_list, 1, -1 do
    form_list[i]:move_to_head()
  end
end
local anims = {}
function end_module_skill1()
end
function use_skill()
  if build_info.player == nil then
    return
  end
  if build_info.career == nil then
    return
  end
  if build_info.sex == 1 then
    build_info.player:use_skill(anims[build_info.career].anim1, w_target.sel_handle, nil, 1, end_module_skill1, false, false, false, false)
  else
    build_info.player:use_skill(anims[build_info.career].anim3, w_target.sel_handle, nil, 1, end_module_skill1, false, false, false, false)
  end
end
function end_module_skill()
  if build_info.player == nil then
    return
  end
  bo2.set_bo2_player()
  if state == "on_detail" then
    build_info.player:ViewPlayerAnimPlay(1, true)
    return
  end
  build_info.timeevent = bo2.AddTimeEvent(1, use_skill)
end
local b_length = 73
local s_length = 61
local dis_gap = (b_length - s_length) / 2
function show_select_career(btn)
  local id = btn.svar.id
  local career_excel = bo2.gv_career:find(id)
  if career_excel == nil then
    return
  end
  if not build_info.career or build_info.career ~= id then
    build_info.video = 0
  end
  build_info.career = id
  build_info.career_excel = career_excel
  build_info.player:SetEquipIsHandle(true, false)
  build_info.player:set_equip_model(bo2.eEquipData_MainWeapon, career_excel.weapon)
  build_info.player:set_view_player_career(id)
  build_info.career_btn = btn
  build_info.career_btn.press = true
  w_career_info:search("career_text").image = "$image/phase/choice/title" .. id .. ".png"
  w_career_text.mtf = career_excel.desc
  build_info.career_btn.parent:search("loop_picture").visible = true
  build_info.player:set_atb(bo2.eAtb_Cha_Profession, career_excel.id)
  bo2.set_bo2_player(build_info.player)
  local player = build_info.player
  local model_excel = build_info.model_excel
  if model_excel then
    for i = 0, model_excel.body.size - 1, 2 do
      if model_excel.body[i] == career_excel.id then
        player:set_equip_model(bo2.eEquipData_Body, model_excel.body[i + 1])
        break
      end
    end
    for i = 0, model_excel.hat_def.size - 1, 2 do
      if model_excel.hat_def[i] == career_excel.id then
        player:set_equip_model(bo2.eEquipData_Hat, model_excel.hat_def[i + 1])
        break
      end
    end
  else
    player:set_equip_model(bo2.eEquipData_Body, model_excel.body[1])
    player:set_equip_model(bo2.eEquipData_Hat, model_excel.hat_def[1])
  end
  if build_info.player then
    build_info.player:terminate_skill()
    bo2.RemoveTimeEvent(build_info.timeevent)
  end
  if build_info.sex == 1 then
    build_info.player:use_skill(anims[id].anim2, w_target.sel_handle, nil, 100, end_module_skill, false, false, false, false)
  else
    build_info.player:use_skill(anims[id].anim4, w_target.sel_handle, nil, 100, end_module_skill, false, false, false, false)
  end
end
function on_select_career(btn, msg)
  if msg == ui.mouse_lbutton_click then
    local id = btn.svar.id
    if btn.svar.disable == true then
      ui_tool.note_insert(ui.get_text("phase|more_career"), "FFFF00")
      return
    end
    if btn == build_info.career_btn then
      return
    end
    if sys.check(build_info.career_btn) then
      build_info.career_btn.press = false
      build_info.career_btn.parent.dx = s_length
      build_info.career_btn.parent.dy = s_length
      build_info.career_btn.parent.parent.dx = s_length
      build_info.career_btn.parent.parent.dy = s_length
      local count = build_info.career_btn.svar.count
      build_info.career_btn.parent.parent.x = dis_gap + count % 4 * s_length
      build_info.career_btn.parent.parent.y = dis_gap + math.floor(count / 4) * s_length
      build_info.career_btn.parent:search("loop_picture").visible = false
    end
    btn.parent.dx = b_length
    btn.parent.dy = b_length
    btn.parent.parent.dx = b_length
    btn.parent.parent.dy = b_length
    local count = btn.svar.count
    btn.parent.parent.x = count % 4 * s_length
    btn.parent.parent.y = math.floor(count / 4) * s_length
    show_select_career(btn)
    build_info.career_btn.parent.parent:move_to_head()
  elseif msg == ui.mouse_enter then
    local id = btn.svar.id
    btn.parent.dx = b_length
    btn.parent.dy = b_length
    btn.parent.parent.dx = b_length
    btn.parent.parent.dy = b_length
    local count = btn.svar.count
    btn.parent.parent.x = count % 4 * s_length
    btn.parent.parent.y = math.floor(count / 4) * s_length
    btn.parent.parent:move_to_head()
  elseif msg == ui.mouse_leave then
    if btn == build_info.career_btn then
      return
    end
    btn.parent.dx = s_length
    btn.parent.dy = s_length
    btn.parent.parent.dx = s_length
    btn.parent.parent.dy = s_length
    local count = btn.svar.count
    btn.parent.parent.x = dis_gap + count % 4 * s_length
    btn.parent.parent.y = dis_gap + math.floor(count / 4) * s_length
    build_info.career_btn.parent.parent:move_to_head()
  end
end
local choice_weapon_enable = function(excel)
  local p = bo2.gv_career:find(excel.career)
  if p == nil then
    return false
  end
  return p.disable == 0
end
function init_choice_career()
  w_choice_career:control_clear()
  local c = bo2.gv_init_choice_weapon.size
  local count = 0
  for i = 1, c do
    local excel = bo2.gv_init_choice_weapon:get(i - 1)
    local p = ui.create_control(w_choice_career, "panel")
    p:load_style("$gui/phase/choice1/choice.xml", "career_btn")
    p.dock = "none"
    local svar = {
      id = excel.career,
      count = count
    }
    local icon_idx
    if choice_weapon_enable(excel) then
      icon_idx = excel.career
    else
      svar.disable = true
      icon_idx = 0
    end
    p:search("btn_image").image = "$image/phase/choice/btn_cc_" .. icon_idx .. ".png|0,0,292,73"
    p:search("btn").svar = svar
    p:search("btn"):insert_on_mouse(on_select_career)
    p.dx = s_length
    p.dy = s_length
    p.x = dis_gap + count % 4 * s_length
    p.y = dis_gap + math.floor(count / 4) * s_length
    p:search("btn").parent.dx = s_length
    p:search("btn").parent.dy = s_length
    anims[excel.career] = {}
    anims[excel.career].anim1 = excel.anim1
    anims[excel.career].anim2 = excel.anim2
    anims[excel.career].anim3 = excel.anim3
    anims[excel.career].anim4 = excel.anim4
    count = count + 1
    if count == 1 then
      default_career_btn = p:search("btn")
    end
  end
  w_choice_career:apply_dock(true)
end
function random_camp()
  if math.random(1, 2) == 1 then
    w_camp_1:search("btn_image").image = "$image/phase/choice/camp1.png|0,0,440,190"
    w_camp_1.parent.name = "camp_1"
    w_camp_2:search("btn_image").image = "$image/phase/choice/camp2.png|0,0,440,190"
    w_camp_2.parent.name = "camp_2"
  else
    w_camp_1:search("btn_image").image = "$image/phase/choice/camp2.png|0,0,440,190"
    w_camp_1.parent.name = "camp_2"
    w_camp_2:search("btn_image").image = "$image/phase/choice/camp1.png|0,0,440,190"
    w_camp_2.parent.name = "camp_1"
  end
  w_camp_text.visible = false
end
function on_camp_check(btn)
  bo2.PlaySound2D(614, false)
  local msg = {
    btn_confirm = true,
    btn_cancel = false,
    modal = true,
    input = nil
  }
  msg.title = ui.get_text("phase|camp_confirm")
  local v = sys.variant()
  if btn.parent.name == L("camp_1") then
    v:set("camp", ui.get_text("phase|camp_blade"))
    w_camp_text.image = "$image/phase/choice/camp1.png|110,0,110,190"
    build_info.camp = bo2.eCamp_Blade
    if sys.check(build_info.camp_btn) then
      build_info.camp_btn.press = false
    end
    build_info.camp_btn = btn
    build_info.camp_btn.press = true
  elseif btn.parent.name == L("camp_2") then
    v:set("camp", ui.get_text("phase|camp_sword"))
    w_camp_text.image = "$image/phase/choice/camp2.png|110,0,110,190"
    build_info.camp = bo2.bo2.eCamp_Sword
    if sys.check(build_info.camp_btn) then
      build_info.camp_btn.press = false
    end
    build_info.camp_btn = btn
    build_info.camp_btn.press = true
  end
  w_camp_text.visible = true
  local fmt = ui.get_text("phase|camp_confirm_text")
  msg.text = sys.mtf_merge(v, fmt)
  ui_widget.ui_msg_box.show_common(msg)
end
