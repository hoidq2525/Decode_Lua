local p_view_player
local ciViewPlayerAnim = 545
local f_rot_angle = 90
local cValueMax = 255
local view_edit_scn = {}
view_edit_scn[1] = {scn_id = 1031, fov = 0.35}
view_edit_scn[2] = {scn_id = 1031, fov = 0.35}
local ciPlayerSex = 0
local slider_type = {}
function on_page_step(var)
  update_page(var.index)
end
function on_init(ctrl)
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
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis == true then
    local player = ui_choice.build_info.player
    if player == nil then
      return
    end
    if w_scn.scn ~= nil then
      w_scn.scn:clear_obj(bo2.eScnObjKind_Player)
    end
    ciPlayerSex = ui_choice.build_info.model_excel.sex
    local ref_view_edit_scn = view_edit_scn[ciPlayerSex]
    w_scn:set_excel_id(ref_view_edit_scn.scn_id)
    p_view_player = w_scn.scn:create_obj(bo2.eScnObjKind_Player, player.excel.id)
    p_view_player.view_target = player
    p_view_player:set_view_equip(bo2.eEquipData_MainWeapon, 1)
    p_view_player:set_view_equip(bo2.eEquipData_FuMo_MainWeapon, 1)
    p_view_player:set_view_equip(bo2.eEquipData_2ndWeapon, 1)
    p_view_player:set_view_equip(bo2.eEquipData_FuMo_2ndWeapon, 1)
    p_view_player:ViewPlayerAnimPlay(ciViewPlayerAnim, true, false)
    w_scn.scn:bind_camera(p_view_player)
    w_scn.scn:modify_camera_view_type(p_view_player, bo2.eCameraInitNoAlpha)
    for name, value in pairs(slider_type) do
      value.init_value = player:get_flag_int8(value.flag)
      value.curr_value = value.init_value
      local parent = w_main:search(name)
      if parent ~= nil then
        local ctrl = parent:search(L("slider"))
        if ctrl ~= nil then
          value.slider_ctrl = ctrl
          ctrl.scroll = value.curr_value / cValueMax
        end
        local btn = parent:search(L("btn_undo"))
        value.undo_ctrl = btn
      end
      p_view_player:set_flag_int8(value.flag, value.curr_value)
    end
  elseif w_scn.scn ~= nil then
    w_scn.scn:destory_obj(p_view_player)
    p_view_player = nil
  end
end
function on_slider_move(ctrl)
  local name = ctrl.parent.parent.name
  local value = slider_type[name]
  if value ~= nil then
    local var = ctrl.scroll * cValueMax
    p_view_player:set_flag_int8(value.flag, var)
    value.curr_value = p_view_player:get_flag_int8(value.flag)
  end
end
function on_btn_undo(ctrl)
  local name = ctrl.parent.name
  local value = slider_type[name]
  if value ~= nil then
    value.slider_ctrl.scroll = value.init_value / cValueMax
  end
end
function on_btn_enter(btn)
  local player = ui_choice.build_info.player
  if player == nil then
    return
  end
  for _, value in pairs(slider_type) do
    local var = value.slider_ctrl.scroll * cValueMax
    player:set_flag_int8(value.flag, var)
  end
  local data = ui_widget.ui_msg_box.get_data(btn)
  if data == nil then
    return
  end
  data.result = 1
  ui_widget.ui_msg_box.invoke(data)
end
function on_btn_reset()
  for name, value in pairs(slider_type) do
    value.curr_value = value.init_value
    value.slider_ctrl.scroll = value.init_value / cValueMax
  end
end
function on_btn_rot_left(btn, press)
  if press then
    w_scn.rotate_angle = -f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
end
function on_btn_rot_right(btn, press)
  if press then
    w_scn.rotate_angle = f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
end
function on_sld_init(sld, data)
  local fig_hi = sld:search("fig_hi")
  local lb_name
  if data ~= nil then
    lb_name = sld.parent:search(data)
  end
  local function set_color(c, ct, vis)
    fig_hi.visible = vis
    if lb_name ~= nil then
      if sys.is_type(lb_name, "ui_label") then
        lb_name.color = c
      elseif sys.is_type(lb_name, "ui_button") then
        local lb = lb_name:search("btn_lb_text")
        if lb ~= nil then
          lb.tint_normal = ct
        end
      end
    end
  end
  local function on_mouse(ctrl, msg)
    if msg == ui.mouse_inner then
      set_color(c_sld_hi, c_sld_hi_tint, true)
    elseif msg == ui.mouse_outer then
      set_color(c_sld_orig, c_sld_orig_tint, false)
    end
  end
  local parent = sld.parent
  parent:insert_on_mouse(on_mouse, "ui_choice.body_detail.on_sld_init:on_mouse")
end
