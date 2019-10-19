local c_build_uri = SHARED("$gui/phase/choice/build.xml")
function build_init_once()
  if rawget(_M, "g_build_already_init") ~= nil then
    return
  end
  g_build_already_init = true
  w_build_model_item_sel = 0
  w_build_career_item_sel = 0
  build_info = {}
  career_items = {}
end
function build_show(vis)
  w_cha_panel.visible = not vis
  w_build_player.visible = vis
end
local s_face = ui.get_text("phase|xiangmao")
local s_hair = ui.get_text("phase|faxing")
local s_body = ui.get_text("phase|fushi")
function build_clear()
  build_info = {
    hair_id = 0,
    face_id = 0,
    body_id = 0,
    player = 0
  }
  build_info.model_excel = 0
  w_build_model_item_sel = 0
  w_build_camp_0.check = false
  w_build_camp_1.check = false
  w_build_input_name.text = nil
  build_career_clear()
end
function bar_text_set(p, t)
  p:search("lb_bar_text").text = t
end
function build_career_clear()
  w_build_input_name.text = ""
  local career_item_sel = w_build_career_item_sel
  w_build_career_item_sel = 0
  build_info.career_excel = 0
  if sys.check(career_item_sel) then
    build_career_item_update_highlight(career_item_sel)
  end
  w_portrait_result_icon.image = nil
  w_build_detail_portrait.visible = false
  w_build_detail_camp_group.visible = false
  build_detail_clear()
end
function build_detail_clear()
  build_info.portrait_excel = 0
  w_build_select_portrait.visible = false
  build_info.hair_id = 0
  build_info.face_id = 0
  build_info.body_id = 0
  bar_text_set(w_detail_face, s_face)
  bar_text_set(w_detail_hair, s_hair)
  bar_text_set(w_detail_body, s_body)
end
function detail_info_check_get(v, n)
  local c = v.size
  local i = build_info[n]
  if i < 0 then
    build_info[n] = c - 1
    return v[c - 1]
  end
  local c = v.size
  if i >= c then
    build_info[n] = 0
    return v[0]
  end
  return v[i]
end
function build_default_player_view(scn_view, excel, use_view_cfg)
  local scn = scn_view.scn
  scn:clear_obj(-1)
  local player = scn:create_obj(bo2.eScnObjKind_Player, excel.id)
  if use_view_cfg then
    scn:bind_camera(player, excel.view_eye_height, excel.view_camera_radius, -0.4)
    player:set_flag_int8(bo2.ePlayerFlagInt8_Hat, 1)
  else
    scn:bind_camera(player)
  end
  player:EquipClear()
  player:set_equip_model(bo2.eEquipData_Hat, excel.hat_def)
  player:set_equip_model(bo2.eEquipData_Face, excel.face_def)
  player:set_equip_model(bo2.eEquipData_Body, excel.body[0])
  player:set_equip_model(bo2.eEquipData_Legs, excel.crura[0])
  return player
end
function update_build_info_detail()
  local p = build_info.player
  if not sys.check(p) then
    return
  end
  local model_excel = build_info.model_excel
  local career_excel = build_info.career_excel
  ui.log("career_excel %s", career_excel)
  if not sys.check(career_excel) then
    w_build_career_text.visible = false
    return
  end
  p:EquipClear()
  p:set_equip_model(bo2.eEquipData_Hair, detail_info_check_get(model_excel.hair, "hair_id"))
  p:set_equip_model(bo2.eEquipData_Face, detail_info_check_get(model_excel.face, "face_id"))
  if sys.check(career_excel) then
    w_build_career_text.visible = true
    w_build_career_title.text = sys.format("<%s>", career_excel.name)
    w_build_career_desc.mtf = career_excel.desc
    p:set_equip_model(bo2.eEquipData_Body, detail_info_check_get(career_excel.equip, "body_id"))
    p:set_equip_model(bo2.eEquipData_Legs, detail_info_check_get(career_excel.equip, "body_id"))
  else
    w_build_career_text.visible = false
    build_info.body_id = 0
    p:set_equip_model(bo2.eEquipData_Body, model_excel.body[0])
    p:set_equip_model(bo2.eEquipData_Legs, model_excel.crura[0])
  end
  bar_text_set(w_detail_face, sys.format("%s%d", s_face, build_info.face_id + 1))
  bar_text_set(w_detail_hair, sys.format("%s%d", s_hair, build_info.hair_id + 1))
  bar_text_set(w_detail_body, sys.format("%s%d", s_body, build_info.body_id + 1))
  local pro = bo2.gv_profession_list:find((build_info.career_excel.id - 1) * 3 + 1).id
  p:set_view_player_profession(pro)
  p:set_equip_model(bo2.eEquipData_MainWeapon, build_info.career_excel.weapon)
end
function update_build_info_pro()
  if build_info.player == nil then
    local model_excel = build_info.model_excel
    build_career_clear()
    build_info.player = build_default_player_view(w_build_player_view, model_excel, false)
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
      career_items[career_excel.id].visible = vis
    end
  end
  update_build_info_detail()
end
function on_build_popup_portrait_click(btn)
  w_build_portrait_divider:control_clear()
  bo2.PlaySound2D(537, false)
  w_build_select_portrait.visible = true
  local sex = build_info.model_excel.sex
  local pc = 0
  for i = 0, bo2.gv_portrait.size - 1 do
    local excel = bo2.gv_portrait:get(i)
    if excel.kind == sex and excel.init == 1 then
      local w = ui.create_control(w_build_portrait_divider)
      w.svar.excel = excel
      w:load_style(c_build_uri, "build_portrait_item")
      w:search("pic_icon").image = sys.format("$icon/portrait/%s.png", excel.icon)
      pc = pc + 1
    end
  end
  local yc = 1
  if pc >= 4 then
    yc = 2
  end
  local xc = math.ceil(pc / yc)
  w_build_portrait_divider:set_divide(xc, 2)
  local mg = w_build_portrait_divider.margin
  local sp = w_build_portrait_divider.space
  w_build_select_portrait.dx = xc * (sp.x + 72) + mg.x1 + mg.x2
  w_build_select_portrait.dy = yc * (sp.y + 72) + mg.y1 + mg.y2
  ui_widget.ui_popup.show(w_build_select_portrait, btn, "y2x1")
end
function build_portrait_item_update_highlight(pn)
  local vis = pn.inner_hover
  local fig = pn:search("fig_highlight")
  fig.visible = vis
end
function on_build_portrait_item_mouse(pn, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_inner or msg == ui.mouse_outer or msg == ui.mouse_leave then
    build_portrait_item_update_highlight(pn)
    return
  end
  if msg == ui.mouse_lbutton_click then
    bo2.PlaySound2D(540, false)
    build_info.portrait_excel = pn.svar.excel
    w_build_select_portrait.visible = false
    w_portrait_result_icon.image = sys.format("$icon/portrait/%s.png", build_info.portrait_excel.icon)
  end
end
function build_career_item_update_highlight(item)
  local vis = item == w_build_career_item_sel or item.inner_hover
  local fig = item:search("fig_highlight")
  fig.visible = vis
end
function on_build_career_item_tip(tip)
  local item = tip.owner.parent.parent
  local pre, id = item.name:split2("_")
  local career = bo2.gv_career:find(id.v_int)
  local pro = bo2.gv_profession_list:find((career.id - 1) * 3 + 1)
  ui_widget.tip_make_view(tip.view, pro.desc)
end
function on_build_career_item_mouse(pn, msg)
  local item = pn.parent.parent
  if msg == ui.mouse_enter or msg == ui.mouse_inner or msg == ui.mouse_outer or msg == ui.mouse_leave then
    build_career_item_update_highlight(item)
    return
  end
  if msg == ui.mouse_lbutton_click then
    local sel = w_build_career_item_sel
    if sel == item then
      return
    end
    if sys.check(sel) then
      w_build_career_item_sel = 0
      build_career_item_update_highlight(sel)
    end
    w_build_career_item_sel = item
    build_career_item_update_highlight(item)
    local pre, id = item.name:split2("_")
    ui.log("pre %s id %s", pre, id)
    build_info.career_excel = bo2.gv_career:find(id.v_int)
    ui.log("build_info.career_excel %s", build_info.career_excel)
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
    p:SetEquipIsHandle(true, false)
    p:set_equip_model(bo2.eEquipData_MainWeapon, build_info.career_excel.weapon)
  end
end
function on_build_career_item_init(pic)
  local pre, id = pic.parent.name:split2("_")
  pic.image = sys.format("$image/phase/career/%s.png", id)
  career_items[id.v_int] = pic.parent
end
function on_detail_toggle_click(btn)
  bo2.PlaySound2D(539, false)
  local w = btn.parent
  local n_id = tostring(w.name) .. "_id"
  local step = 1
  if btn.name == L("prev") then
    step = -1
  end
  build_info[n_id] = build_info[n_id] + step
  update_build_info_detail()
end
function on_build_visible(ctrl, vis)
  if vis then
  elseif sys.check(build_info.player) then
    build_info.player:terminate_skill()
  end
end
function build_model_item_update_highlight(item)
  local fig = item:search("fig_highlight")
  fig.visible = item.inner_hover
  local fig2 = item:search("fig_highlight2")
  fig2.visible = item == w_build_model_item_sel
end
function on_build_model_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_inner or msg == ui.mouse_outer or msg == ui.mouse_leave then
    build_model_item_update_highlight(item)
    return
  end
  if msg == ui.mouse_lbutton_click then
    local sel = w_build_model_item_sel
    if sel == item then
      return
    end
    if sys.check(sel) then
      w_build_model_item_sel = 0
      build_model_item_update_highlight(sel)
    end
    w_build_next_btn.enable = true
    w_build_model_item_sel = item
    build_info.model_excel = item.svar.model_data.excel
    build_info.player = nil
    build_model_item_update_highlight(item)
  end
end
local player_name_error = {
  [bo2.eNameCheck_ErrLength] = ui.get_text("phase|name_error1"),
  [bo2.eNameCheck_ErrAllNum] = ui.get_text("phase|name_error2"),
  [bo2.eNameCheck_ErrUnLawful] = ui.get_text("phase|name_error3"),
  [bo2.eNameCheck_ErrSensitive] = ui.get_text("phase|name_error4"),
  [bo2.eNameCheck_ErrNpcName] = ui.get_text("phase|name_error5")
}
function on_camp_check(btn, flag)
  if flag == false then
    return
  end
  bo2.PlaySound2D(539, false)
  local msg = {
    btn_confirm = true,
    btn_cancel = false,
    modal = true,
    input = nil
  }
  msg.title = ui.get_text("phase|camp_confirm")
  local v = sys.variant()
  if w_build_camp_0.check then
    v:set("camp", w_build_camp_0.text)
  elseif w_build_camp_1.check then
    v:set("camp", w_build_camp_1.text)
  end
  local fmt = ui.get_text("phase|camp_confirm_text")
  msg.text = sys.mtf_merge(v, fmt)
  ui_widget.ui_msg_box.show_common(msg)
end
function on_build_confirm_click(btn)
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
  if ui_tool.tool_disable_window.player_build_camp_group == nil then
    if w_build_camp_0.check then
      camp = w_build_camp_0.svar
    elseif w_build_camp_1.check then
      camp = w_build_camp_1.svar
    else
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
    hair = model_excel.hair[build_info.hair_id],
    face = model_excel.face[build_info.face_id],
    equip = career_excel.equip[build_info.body_id],
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
math.randomseed(os.time())
local tab_player_name = sys.load_table("$mb/etc/player_name.xml")
local tab_name_combo = sys.load_table("$mb/etc/player_name_combo.xml")
function rand_name_combo()
  local tab_combo_size = tab_name_combo.size
  local num = math.random(1, 100)
  local tab_ratio = {}
  tab_ratio[-1] = 0
  for i = 0, tab_combo_size - 1 do
    local ratio = tab_name_combo:get(i).ratio
    tab_ratio[i] = tab_ratio[i - 1] + ratio
    if num <= tab_ratio[i] then
      return i
    end
  end
  return -1
end
function rand_char(name_type)
  local tab_size = tab_player_name.size
  local character
  while character == nil or character == L("") do
    local name_line_idx = math.random(0, tab_size - 1)
    local name_line = tab_player_name:get(name_line_idx)
    local name_key = tostring(name_type)
    if name_key ~= "family_name" then
      if build_info.model_excel.sex == bo2.eSex_Male then
        name_key = "male_" .. name_key
      elseif build_info.model_excel.sex == bo2.eSex_Female then
        name_key = "fem_" .. name_key
      end
    end
    character = name_line[name_key]
  end
  return character
end
function on_rand_name_click(btn)
  bo2.PlaySound2D(537, false)
  local combo_idx = rand_name_combo()
  if combo_idx == -1 then
    ui.log("player_name_combo.txt\204\238\177\237\180\237\206\243\163\172\199\235\215\208\207\184\186\203\178\233")
    return
  end
  local combo_array = tab_name_combo:get(combo_idx).combo
  local player_name, rst
  repeat
    player_name = nil
    for i = 0, combo_array.size - 1 do
      local name_type = combo_array[i]
      player_name = player_name .. rand_char(name_type)
    end
    rst = ui.check_name(player_name)
  until rst == bo2.eNameCheck_ErrNone
  w_build_input_name.text = player_name
end
function on_build_input_name_key(box, key, flag)
  if key ~= ui.VK_RETURN or not flag.down then
  end
end
function on_build_back_click(btn)
  build_show(false)
end
function on_build_next_click(btn)
  w_build_model.visible = false
  w_build_detail.visible = true
  build_info.player = nil
  update_build_info_pro()
end
function on_modify_face_detail_click(btn)
  local modify_face_detail_msg = {
    style_uri = SHARED("$gui/phase/choice/face_detail.xml"),
    style_name = "face_detail",
    modal = true
  }
  ui_widget.ui_msg_box.show(modify_face_detail_msg)
end
function on_modify_body_detail_click(btn)
  local modify_body_detail_msg = {
    style_uri = SHARED("$gui/phase/choice/body_detail.xml"),
    style_name = "body_detail",
    modal = true
  }
  ui_widget.ui_msg_box.show(modify_body_detail_msg)
end
build_init_once()
