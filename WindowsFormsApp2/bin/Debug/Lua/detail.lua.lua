local cValueMax = 255
function build_portrait_item_update_highlight(pn)
  local vis = pn.inner_hover
  local fig = pn:search("fig_highlight")
  fig.visible = vis
  if sys.check(build_info.portrait_hl) and fig == build_info.portrait_hl then
    fig.visible = true
  end
end
function on_build_portrait_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_inner or msg == ui.mouse_outer or msg == ui.mouse_leave then
    build_portrait_item_update_highlight(item)
    return
  end
  if msg == ui.mouse_lbutton_click then
    bo2.PlaySound2D(540, false)
    build_info.portrait_excel = item.svar.excel
    if sys.check(build_info.portrait_hl) then
      build_info.portrait_hl.visible = false
    end
    build_info.portrait_hl = item:search("fig_highlight")
  end
end
function init_portrait()
  local sex = 1
  if build_info.sex == 1 then
    sex = 1
  elseif build_info.sex == 2 then
    sex = 2
  end
  local c = 0
  for i = 0, bo2.gv_portrait.size - 1 do
    local excel = bo2.gv_portrait:get(i)
    if excel.kind == sex and excel.init == 1 then
      local w = ui.create_control(w_portrait_list, "divider")
      w.svar.excel = excel
      w:load_style("$gui/phase/choice1/choice.xml", "build_portrait_item")
      w:search("pic_icon").image = sys.format("$icon/portrait/%s.png", excel.icon)
      c = c + 1
      w.name = "portrait" .. c
      if c == 1 then
        build_info.portrait_excel = w.svar.excel
        if sys.check(build_info.portrait_hl) then
          build_info.portrait_hl.visible = false
        end
        build_info.portrait_hl = w:search("fig_highlight")
        build_info.portrait_hl.visible = true
      end
    end
  end
  local a = 0
  if 0 < c % 4 then
    a = 1
  end
  local r = math.floor(c / 4) + a
  w_portrait_list.parent.dy = r * 72
  w_portrait_list:set_divide(4, r)
  w_portrait_list.parent.parent.dy = 40 + r * 72
  w_portrait_list.parent.parent.parent.dy = 40 + r * 72
  w_portrait_list.parent:apply_dock(true)
  w_portrait_list.parent.parent:apply_dock(true)
  w_portrait_list.parent.visible = true
  cur_detail_btn = w_portrait_list.parent.parent:search("btn")
end
function portrait_clear()
  w_portrait_list:control_clear()
  build_info.portrait_hl = nil
  build_info.portrait_excel = nil
end
function on_init_portrait(btn)
  if btn.parent.dy == 40 then
    btn.parent.dy = 40 + w_portrait_list.parent.dy
    btn.parent.parent.dy = 40 + w_portrait_list.parent.dy
    w_portrait_list.parent.visible = true
    w_portrait_list.parent:apply_dock(true)
    w_portrait_list.parent.parent:apply_dock(true)
    if cur_detail_btn ~= btn then
      close_other_btn()
      cur_detail_btn = btn
    end
    set_whole_body(true)
    btn.parent:search("arrow_up").visible = true
    btn.parent:search("arrow_down").visible = false
  elseif btn.parent.dy == 40 + w_portrait_list.parent.dy then
    btn.parent.dy = 40
    btn.parent.parent.dy = 40
    w_portrait_list.parent.visible = false
    w_portrait_list.parent:apply_dock(true)
    w_portrait_list.parent.parent:apply_dock(true)
    cur_detail_btn = nil
    btn.parent:search("arrow_up").visible = false
    btn.parent:search("arrow_down").visible = true
  end
  auto_bg()
end
function on_init_choice_body(btn)
  if build_info.model_excel.disable_pinch == 1 and state == "on_detail" then
    ui_tool.note_insert(ui.get_text("choice|no_pinch"), "FF0000")
    return
  end
  if btn.parent.dy == 40 then
    btn.parent.dy = 254
    w_choice_detail:search("choice_body").dy = 254
    w_body_detail.visible = true
    close_other_btn()
    cur_detail_btn = btn
    set_whole_body(true)
    btn.parent:search("arrow_up").visible = true
    btn.parent:search("arrow_down").visible = false
  elseif btn.parent.dy == 254 then
    btn.parent.dy = 40
    w_choice_detail:search("choice_body").dy = 40
    w_body_detail.visible = false
    cur_detail_btn = nil
    btn.parent:search("arrow_up").visible = false
    btn.parent:search("arrow_down").visible = true
  end
  auto_bg()
end
function update_body()
  for name, value in pairs(slider_type) do
    value.init_value = build_info.player:get_flag_int8(value.flag)
    value.curr_value = value.init_value
    local parent = w_body_detail:search(name)
    if parent == nil then
      parent = w_face_detail:search(name)
    end
    if parent ~= nil then
      local ctrl = parent:search(L("slider"))
      if ctrl ~= nil then
        value.slider_ctrl = ctrl
        ctrl.scroll = value.curr_value / cValueMax
      end
      local btn = parent:search(L("btn_undo"))
      value.undo_ctrl = btn
      parent:search("value").text = value.curr_value
    end
  end
end
function init_body()
  slider_type[L("waist")] = {
    flag = bo2.ePlayerFlagInt8_BoneOffsetWaist,
    packet_key = packet.key.body_waist,
    init_value = 0,
    curr_value = 0,
    slider_ctrl = nil
  }
  slider_type[L("neck")] = {
    flag = bo2.ePlayerFlagInt8_BoneOffsetNeck,
    packet_key = packet.key.body_neck,
    init_value = 0,
    curr_value = 0,
    slider_ctrl = nil
  }
  slider_type[L("up_arm")] = {
    flag = bo2.ePlayerFlagInt8_BoneOffsetUpperArm,
    packet_key = packet.key.body_up_arm,
    init_value = 0,
    curr_value = 0,
    slider_ctrl = nil,
    undo_ctrl = nil
  }
  slider_type[L("front_arm")] = {
    flag = bo2.ePlayerFlagInt8_BoneOffsetForearm,
    packet_key = packet.key.body_front_arm,
    init_value = 0,
    curr_value = 0,
    slider_ctrl = nil,
    undo_ctrl = nil
  }
  slider_type[L("thigh")] = {
    flag = bo2.ePlayerFlagInt8_BoneOffsetUpperLeg,
    packet_key = packet.key.body_thigh,
    init_value = 0,
    curr_value = 0,
    slider_ctrl = nil,
    undo_ctrl = nil
  }
  slider_type[L("leg")] = {
    flag = bo2.ePlayerFlagInt8_BoneOffsetShank,
    packet_key = packet.key.body_leg,
    init_value = 0,
    curr_value = 0,
    slider_ctrl = nil,
    undo_ctrl = nil
  }
  slider_type[L("eye_size")] = {
    flag = bo2.ePlayerFlagInt8_EyeSize,
    slider_ctrl = nil
  }
  slider_type[L("eye_distance")] = {
    flag = bo2.ePlayerFlagInt8_EyeWide,
    slider_ctrl = nil
  }
  slider_type[L("eyebrow_height")] = {
    flag = bo2.ePlayerFlagInt8_EyeBrow,
    slider_ctrl = nil
  }
  slider_type[L("nose_size")] = {
    flag = bo2.ePlayerFlagInt8_NostrilSize,
    slider_ctrl = nil
  }
  slider_type[L("nose_height")] = {
    flag = bo2.ePlayerFlagInt8_NoseBridgePos,
    slider_ctrl = nil
  }
  slider_type[L("nose_quatation")] = {
    flag = bo2.ePlayerFlagInt8_NoseGuard,
    slider_ctrl = nil
  }
  slider_type[L("mouth_width")] = {
    flag = bo2.ePlayerFlagInt8_MouthSize,
    slider_ctrl = nil
  }
  slider_type[L("mouth_height")] = {
    flag = bo2.ePlayerFlagInt8_PhiltrumLen,
    slider_ctrl = nil
  }
  slider_type[L("mouth_tickness")] = {
    flag = bo2.ePlayerFlagInt8_MouthLipSize,
    slider_ctrl = nil
  }
end
function on_slider_move(ctrl)
  local name = ctrl.parent.parent.name
  local value = slider_type[name]
  if value ~= nil then
    local var = ctrl.scroll * cValueMax
    build_info.player:set_flag_int8(value.flag, var)
    value.curr_value = build_info.player:get_flag_int8(value.flag)
    ctrl.parent.parent:search("value").text = value.curr_value
  end
end
function on_btn_undo(ctrl)
  local name = ctrl.parent.name
  local value = slider_type[name]
  if value ~= nil then
    value.slider_ctrl.scroll = value.init_value / cValueMax
    build_info.player:set_flag_int8(value.flag, value.init_value)
    value.curr_value = value.init_value
    ctrl.parent.parent:search("value").text = value.curr_value
  end
end
function on_btn_reset()
  if build_info.player == nil then
    return
  end
  local player = build_info.player
  for name, value in pairs(slider_type) do
    local ctrl = value.slider_ctrl
    if ctrl ~= nil then
      ctrl.scroll = value.init_value / cValueMax
      ctrl.parent.parent:search("value").text = value.curr_value
      if player ~= nil then
        player:set_flag_int8(value.flag, value.init_value)
      end
    end
  end
end
function on_detail_confirm()
end
function on_init_choice_face(btn)
  if build_info.model_excel.disable_pinch == 1 and state == "on_detail" then
    ui_tool.note_insert(ui.get_text("choice|no_pinch"), "FF0000")
    return
  end
  if btn.parent.dy == 40 then
    btn.parent.dy = 448
    w_choice_detail:search("choice_face").dy = 448
    w_face_detail.visible = true
    close_other_btn()
    cur_detail_btn = btn
    set_whole_body(false)
    btn.parent:search("arrow_up").visible = true
    btn.parent:search("arrow_down").visible = false
  elseif btn.parent.dy == 448 then
    btn.parent.dy = 40
    w_choice_detail:search("choice_face").dy = 40
    w_face_detail.visible = false
    cur_detail_btn = nil
    btn.parent:search("arrow_up").visible = false
    btn.parent:search("arrow_down").visible = true
  end
  auto_bg()
end
function build_hair_item_update_highlight(pn)
  local vis = pn.inner_hover
  local fig = pn:search("fig_highlight")
  fig.visible = vis
  if sys.check(build_info.hair_hl) and fig == build_info.hair_hl then
    fig.visible = true
  end
end
function on_build_hair_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_inner or msg == ui.mouse_outer or msg == ui.mouse_leave then
    build_hair_item_update_highlight(item)
    return
  end
  if msg == ui.mouse_lbutton_click then
    bo2.PlaySound2D(540, false)
    build_info.hair_id = item.svar.hair_id
    if sys.check(build_info.hair_hl) then
      build_info.hair_hl.visible = false
    end
    build_info.hair_hl = item:search("fig_highlight")
    build_info.player:set_equip_model(bo2.eEquipData_Hair, build_info.hair_id)
  end
end
function init_hair()
  if build_info.model_excel == nil then
    return
  end
  local excel = build_info.model_excel
  local c = build_info.model_excel.hair.size
  for i = 0, c - 1 do
    local w = ui.create_control(w_hair_list, "divider")
    w.svar.hair_id = excel.hair[i]
    w:load_style("$gui/phase/choice1/choice.xml", "build_hair_item")
    w:search("pic_icon").image = sys.format("$gui/image/phase/choice/hair/%s_%s.png", excel.id, excel.hair[i])
    if i == 0 then
      build_info.hair_id = w.svar.hair_id
      if sys.check(build_info.hair_hl) then
        build_info.hair_hl.visible = false
      end
      build_info.hair_hl = w:search("fig_highlight")
      build_info.hair_hl.visible = true
      build_info.player:set_equip_model(bo2.eEquipData_Hair, build_info.hair_id)
    end
  end
  build_info.player:set_equip_model(bo2.eEquipData_Hat, 0)
  local a = 0
  if 0 < c % 4 then
    a = 1
  end
  local r = math.floor(c / 4) + a
  w_hair_list.parent.dy = r * 72
  w_hair_list:set_divide(4, r)
  w_hair_list.parent.parent.dy = 40
  w_hair_list.parent.parent.parent.dy = 40
  w_hair_list.parent:apply_dock(true)
  w_hair_list.parent.parent:apply_dock(true)
  w_hair_list.parent.visible = false
end
function hair_clear()
  w_hair_list:control_clear()
  build_info.hair_id = 0
  build_info.hair_hl = nil
end
function on_init_hair(btn)
  if btn.parent.dy == 40 then
    btn.parent.dy = 40 + w_hair_list.parent.dy
    btn.parent.parent.dy = 40 + w_hair_list.parent.dy
    w_hair_list.parent.visible = true
    w_hair_list.parent:apply_dock(true)
    w_hair_list.parent.parent:apply_dock(true)
    set_whole_body(false)
    close_other_btn()
    cur_detail_btn = btn
    btn.parent:search("arrow_up").visible = true
    btn.parent:search("arrow_down").visible = false
  elseif btn.parent.dy == 40 + w_hair_list.parent.dy then
    btn.parent.dy = 40
    btn.parent.parent.dy = 40
    w_hair_list.parent.visible = false
    w_hair_list.parent:apply_dock(true)
    w_hair_list.parent.parent:apply_dock(true)
    cur_detail_btn = nil
    btn.parent:search("arrow_up").visible = false
    btn.parent:search("arrow_down").visible = true
  end
  auto_bg()
end
function build_faces_item_update_highlight(pn)
  local vis = pn.inner_hover
  local fig = pn:search("fig_highlight")
  fig.visible = vis
  if sys.check(build_info.faces_hl) and fig == build_info.faces_hl then
    fig.visible = true
  end
end
function on_build_faces_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_inner or msg == ui.mouse_outer or msg == ui.mouse_leave then
    build_faces_item_update_highlight(item)
    return
  end
  if msg == ui.mouse_lbutton_click then
    bo2.PlaySound2D(540, false)
    build_info.face_id = item.svar.faces_id
    if sys.check(build_info.faces_hl) then
      build_info.faces_hl.visible = false
    end
    build_info.faces_hl = item:search("fig_highlight")
    build_info.player:set_equip_model(bo2.eEquipData_Face, build_info.face_id)
  end
end
function init_faces()
  if build_info.model_excel == nil then
    return
  end
  local excel = build_info.model_excel
  local c = build_info.model_excel.face.size
  for i = 0, c - 1 do
    local w = ui.create_control(w_faces_list, "divider")
    w.svar.faces_id = excel.face[i]
    w:load_style("$gui/phase/choice1/choice.xml", "build_faces_item")
    w:search("pic_icon").image = sys.format("$gui/image/phase/choice/faces/%s_%s.png", excel.id, excel.face[i])
    if i == 0 then
      build_faces_item_update_highlight(w)
      build_info.face_id = w.svar.faces_id
      if sys.check(build_info.faces_hl) then
        build_info.faces_hl.visible = false
      end
      build_info.faces_hl = w:search("fig_highlight")
      build_info.faces_hl.visible = true
    end
  end
  local a = 0
  if 0 < c % 4 then
    a = 1
  end
  local r = math.floor(c / 4) + a
  w_faces_list.parent.dy = r * 72
  w_faces_list:set_divide(4, r)
  w_faces_list.parent.parent.dy = 40
  w_faces_list.parent.parent.parent.dy = 40
  w_faces_list.parent:apply_dock(true)
  w_faces_list.parent.parent:apply_dock(true)
  w_faces_list.parent.visible = false
end
function faces_clear()
  w_faces_list:control_clear()
  build_info.faces_id = 0
  build_info.faces_hl = nil
end
function on_init_faces(btn)
  if btn.parent.dy == 40 then
    btn.parent.dy = 40 + w_faces_list.parent.dy
    btn.parent.parent.dy = 40 + w_faces_list.parent.dy
    w_faces_list.parent.visible = true
    w_faces_list.parent:apply_dock(true)
    w_faces_list.parent.parent:apply_dock(true)
    set_whole_body(false)
    close_other_btn()
    cur_detail_btn = btn
    btn.parent:search("arrow_up").visible = true
    btn.parent:search("arrow_down").visible = false
  elseif btn.parent.dy == 40 + w_faces_list.parent.dy then
    btn.parent.dy = 40
    btn.parent.parent.dy = 40
    w_faces_list.parent.visible = false
    w_faces_list.parent:apply_dock(true)
    w_faces_list.parent.parent:apply_dock(true)
    cur_detail_btn = nil
    btn.parent:search("arrow_up").visible = false
    btn.parent:search("arrow_down").visible = true
  end
  auto_bg()
end
function build_dress_item_update_highlight(pn)
  local vis = pn.inner_hover
  local fig = pn:search("fig_highlight")
  fig.visible = vis
  if sys.check(build_info.dress_hl) and fig == build_info.dress_hl then
    fig.visible = true
  end
end
function on_build_dress_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_inner or msg == ui.mouse_outer or msg == ui.mouse_leave then
    build_dress_item_update_highlight(item)
    return
  end
  if msg == ui.mouse_lbutton_click then
    bo2.PlaySound2D(540, false)
    build_info.body_id = item.svar.dress_id
    if sys.check(build_info.dress_hl) then
      build_info.dress_hl.visible = false
    end
    build_info.dress_hl = item:search("fig_highlight")
    build_info.player:set_equip_model(bo2.eEquipData_Body, build_info.body_id)
    build_info.player:set_equip_model(bo2.eEquipData_Legs, build_info.body_id)
  end
end
function init_dress()
  if build_info.model_excel == nil then
    return
  end
  local excel = build_info.career_excel
  local c = excel.equip.size
  for i = 0, c - 1 do
    local w = ui.create_control(w_dress_list, "divider")
    w.svar.dress_id = excel.equip[i]
    w:load_style("$gui/phase/choice1/choice.xml", "build_dress_item")
    local sex = build_info.sex
    w:search("pic_icon").image = sys.format("$gui/image/phase/choice/dress/%s_%s.png", excel.equip[i], sex)
    if i == 0 then
      build_dress_item_update_highlight(w)
      build_info.body_id = w.svar.dress_id
      if sys.check(build_info.dress_hl) then
        build_info.dress_hl.visible = false
      end
      build_info.dress_hl = w:search("fig_highlight")
      build_info.dress_hl.visible = true
      build_info.player:set_equip_model(bo2.eEquipData_Body, build_info.body_id)
      build_info.player:set_equip_model(bo2.eEquipData_Legs, build_info.body_id)
    end
  end
  local a = 0
  if 0 < c % 4 then
    a = 1
  end
  local r = math.floor(c / 4) + a
  w_dress_list.parent.dy = r * 72
  w_dress_list:set_divide(4, r)
  w_dress_list.parent.parent.dy = 40
  w_dress_list.parent.parent.parent.dy = 40
  w_dress_list.parent:apply_dock(true)
  w_dress_list.parent.parent:apply_dock(true)
  w_dress_list.parent.visible = false
end
function dress_clear()
  w_dress_list:control_clear()
  build_info.dress_id = 0
  build_info.dress_hl = nil
end
function on_init_dress(btn)
  if btn.parent.dy == 40 then
    btn.parent.dy = 40 + w_dress_list.parent.dy
    btn.parent.parent.dy = 40 + w_dress_list.parent.dy
    w_dress_list.parent.visible = true
    w_dress_list.parent:apply_dock(true)
    w_dress_list.parent.parent:apply_dock(true)
    close_other_btn()
    cur_detail_btn = btn
    set_whole_body(true)
    btn.parent:search("arrow_up").visible = true
    btn.parent:search("arrow_down").visible = false
  elseif btn.parent.dy == 40 + w_dress_list.parent.dy then
    btn.parent.dy = 40
    btn.parent.parent.dy = 40
    w_dress_list.parent.visible = false
    w_dress_list.parent:apply_dock(true)
    w_dress_list.parent.parent:apply_dock(true)
    cur_detail_btn = nil
    btn.parent:search("arrow_up").visible = false
    btn.parent:search("arrow_down").visible = true
  end
  auto_bg()
end
function auto_bg()
  w_detail_bg.dy = 30 + w_detail_text.dy + w_detail_portrait_btn.dy + w_detail_hair_btn.dy + w_detail_faces_btn.dy + w_detail_dress_btn.dy + w_detail_body_btn.parent.dy + w_detail_face_btn.parent.dy
end
function close_other_btn()
  if sys.check(cur_detail_btn) then
    cur_detail_btn:click()
  end
end
function set_whole_body(b, dis)
  local pos = bo2.GetFacePos(build_info.player)
  local mark_pos = w_scn_view.scn:getmarkpos("xrjm_shexiangji")
  if cur_body_dis == nil then
    cur_body_dis = 0
  end
  if b == true and dis == nil then
    w_scn_view.scn:MoveToScnDisAndAngle("xrjm_shexiangji", test_posx, test_posy, test_posz, angelx, angely, angelz)
    cur_body_dis = 0
  elseif b == false and dis == nil then
    w_scn_view.scn:MoveToScnDisAndAngle("xrjm_shexiangji", pos.x - mark_pos.x + 0.18, pos.y - mark_pos.y, pos.z - mark_pos.z - 1, angelx, angely, angelz)
    cur_body_dis = 1
  else
    cur_body_dis = cur_body_dis - dis
    if cur_body_dis <= 0 then
      w_scn_view.scn:MoveToScnDisAndAngle("xrjm_shexiangji", test_posx, test_posy, test_posz, angelx, angely, angelz)
      cur_body_dis = 0
    elseif cur_body_dis >= 1 then
      w_scn_view.scn:MoveToScnDisAndAngle("xrjm_shexiangji", pos.x - mark_pos.x + 0.18, pos.y - mark_pos.y, pos.z - mark_pos.z - 1, angelx, angely, angelz)
      cur_body_dis = 1
    else
      w_scn_view.scn:MoveToScnDisAndAngle("xrjm_shexiangji", test_posx + (pos.x - mark_pos.x + 0.18 - test_posx) * cur_body_dis, test_posy + (pos.y - mark_pos.y - test_posy) * cur_body_dis, test_posz + (pos.z - mark_pos.z - 1 - test_posz) * cur_body_dis, angelx, angely, angelz)
    end
  end
end
player_name_error = {
  [bo2.eNameCheck_ErrLength] = ui.get_text("phase|name_error1"),
  [bo2.eNameCheck_ErrAllNum] = ui.get_text("phase|name_error2"),
  [bo2.eNameCheck_ErrUnLawful] = ui.get_text("phase|name_error3"),
  [bo2.eNameCheck_ErrSensitive] = ui.get_text("phase|name_error4"),
  [bo2.eNameCheck_ErrNpcName] = ui.get_text("phase|name_error5")
}
function on_create_confirm()
  bo2.PlaySound2D(537, false)
  local input_name = w_build_input_name.text.trim
  w_build_input_name.text = input_name
  local rst, new_name = ui.check_name(input_name)
  if rst ~= bo2.eNameCheck_ErrNone then
    local err
    if rst == bo2.eNameCheck_ErrLength and input_name.size < bo2.NAME_LENGTH_MIN then
      if input_name.empty then
        err = ui.get_text("phase|name_error6")
      else
        err = ui_widget.merge_mtf({
          num = bo2.NAME_LENGTH_MIN
        }, ui.get_text("phase|name_error7"))
      end
    else
      err = player_name_error[rst]
      if err == nil then
        err = ui.get_text("phase|name_error8")
      end
      w_build_input_name.text = new_name
    end
    ui_tool.note_insert(err, "FF0000")
    return
  end
  local model_excel = build_info.model_excel
  if not sys.check(model_excel) then
    ui_tool.note_insert(ui.get_text("phase|choice_model"), "FF0000")
    return
  end
  local career_excel = build_info.career_excel
  if not sys.check(career_excel) then
    ui_tool.note_insert(ui.get_text("phase|choice_carrer_tip"), "FF0000")
    return
  end
  local portrait_excel = build_info.portrait_excel
  if not sys.check(portrait_excel) then
    ui_tool.note_insert(ui.get_text("phase|choice_head_tip"), "FF0000")
    return
  end
  local camp = 0
  if ui_widget.get_define_int(50015) == 0 then
    camp = build_info.camp
    if camp == 0 then
      ui_tool.note_insert(ui.get_text("phase|choice_camp_tip"), "FF0000")
      return
    end
  else
    camp = bo2.eCamp_Blade
  end
  local pro_id = 0
  for i = 0, bo2.gv_profession_list.size - 1 do
    local pro = bo2.gv_profession_list:get(i)
    if career_excel.id == pro.career then
      pro_id = pro.id
      break
    end
  end
  local player = build_info.player
  if not sys.check(player) then
    return
  end
  task_cha_create({
    name = input_name,
    camp = camp,
    profession = pro_id,
    model = model_excel.id,
    protrait = portrait_excel.id,
    hair = build_info.hair_id,
    face = build_info.face_id,
    equip = build_info.body_id,
    face_detail_eyesize = player:get_flag_int8(bo2.ePlayerFlagInt8_EyeSize),
    face_detail_eyewide = player:get_flag_int8(bo2.ePlayerFlagInt8_EyeWide),
    face_detail_eyebrow = player:get_flag_int8(bo2.ePlayerFlagInt8_EyeBrow),
    face_detail_nostrilsize = player:get_flag_int8(bo2.ePlayerFlagInt8_NostrilSize),
    face_detail_nosebridgepos = player:get_flag_int8(bo2.ePlayerFlagInt8_NoseBridgePos),
    face_detail_noseguard = player:get_flag_int8(bo2.ePlayerFlagInt8_NoseGuard),
    face_detail_mouthsize = player:get_flag_int8(bo2.ePlayerFlagInt8_MouthSize),
    face_detail_philtrumlen = player:get_flag_int8(bo2.ePlayerFlagInt8_PhiltrumLen),
    face_detail_mouthlipsize = player:get_flag_int8(bo2.ePlayerFlagInt8_MouthLipSize),
    body_detail_waist = player:get_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetWaist),
    body_detail_neck = player:get_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetNeck),
    body_detail_upperArm = player:get_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetUpperArm),
    body_detail_forearm = player:get_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetForearm),
    body_detail_upperLeg = player:get_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetUpperLeg),
    body_detail_shank = player:get_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetShank)
  })
end
