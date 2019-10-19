local p_view_player
local ciViewPlayerAnim = 545
local f_rot_angle = 90
local cValueMax = 255
local view_edit_scn = {}
view_edit_scn[1] = {scn_id = 1003, fov = 0.35}
view_edit_scn[2] = {scn_id = 1004, fov = 0.35}
local ciPlayerSex = 0
local ciDefaultValue = 128
local face_diy_money = 0
local face_diy_itemId = 0
local face_diy_itemCount = 0
local face_diy_itemId_Free = 0
local face_diy_itemCount_Free = 0
local face_change_itemId_Free = 0
local face_change_itemCount_Free = 0
local slider_type = {}
local step_ctrl
local face_scn = {}
local face_page_entitys = 3
local face_page_count = -1
local face_page_current = 0
local face_current = -1
local face_select = -1
local face_list = {}
function on_page_step(var)
  update_page(var.index)
end
function on_init(ctrl)
  face_diy_money = bo2.gv_define:find(793).value.v_int
  face_diy_itemId = bo2.gv_define:find(794).value.v_int
  face_diy_itemCount = bo2.gv_define:find(795).value.v_int
  face_diy_itemId_Free = bo2.gv_define:find(997).value.v_int
  face_diy_itemCount_Free = bo2.gv_define:find(998).value.v_int
  face_change_itemId_Free = bo2.gv_define:find(999).value.v_int
  face_change_itemCount_Free = bo2.gv_define:find(1000).value.v_int
  local parent = w_main:search(L("change_face"))
  step_ctrl = parent:search(L("step"))
  ui_widget.ui_stepping.set_event(step_ctrl, on_page_step)
  slider_type[L("eye_size")] = {
    flag = bo2.ePlayerFlagInt8_EyeSize,
    packet_key = packet.key.face_eye_size,
    init_value = {},
    curr_value = {},
    slider_ctrl = nil
  }
  slider_type[L("eye_distance")] = {
    flag = bo2.ePlayerFlagInt8_EyeWide,
    packet_key = packet.key.face_eye_width,
    init_value = {},
    curr_value = {},
    slider_ctrl = nil
  }
  slider_type[L("eyebrow_height")] = {
    flag = bo2.ePlayerFlagInt8_EyeBrow,
    packet_key = packet.key.face_eye_brow,
    init_value = {},
    curr_value = {},
    slider_ctrl = nil,
    undo_ctrl = nil
  }
  slider_type[L("nose_size")] = {
    flag = bo2.ePlayerFlagInt8_NostrilSize,
    packet_key = packet.key.face_nose_size,
    init_value = {},
    curr_value = {},
    slider_ctrl = nil,
    undo_ctrl = nil
  }
  slider_type[L("nose_height")] = {
    flag = bo2.ePlayerFlagInt8_NoseBridgePos,
    packet_key = packet.key.face_nose_height,
    init_value = {},
    curr_value = {},
    slider_ctrl = nil,
    undo_ctrl = nil
  }
  slider_type[L("nose_quatation")] = {
    flag = bo2.ePlayerFlagInt8_NoseGuard,
    packet_key = packet.key.face_nose_quat,
    init_value = {},
    curr_value = {},
    slider_ctrl = nil,
    undo_ctrl = nil
  }
  slider_type[L("mouth_width")] = {
    flag = bo2.ePlayerFlagInt8_MouthSize,
    packet_key = packet.key.face_mouth_size,
    init_value = {},
    curr_value = {},
    slider_ctrl = nil,
    undo_ctrl = nil
  }
  slider_type[L("mouth_height")] = {
    flag = bo2.ePlayerFlagInt8_PhiltrumLen,
    packet_key = packet.key.face_mouth_height,
    init_value = {},
    curr_value = {},
    slider_ctrl = nil,
    undo_ctrl = nil
  }
  slider_type[L("mouth_tickness")] = {
    flag = bo2.ePlayerFlagInt8_MouthLipSize,
    packet_key = packet.key.face_mouth_tickness,
    init_value = {},
    curr_value = {},
    slider_ctrl = nil,
    undo_ctrl = nil
  }
  face_scn[0] = {
    name = L("face_scn1"),
    index = 0,
    player = nil,
    scn_ctrl = nil,
    sel_ctrl = nil,
    curr_ctrl = nil
  }
  face_scn[1] = {
    name = L("face_scn2"),
    index = 0,
    player = nil,
    scn_ctrl = nil,
    sel_ctrl = nil,
    curr_ctrl = nil
  }
  face_scn[2] = {
    name = L("face_scn3"),
    index = 0,
    player = nil,
    scn_ctrl = nil,
    sel_ctrl = nil,
    curr_ctrl = nil
  }
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis == true then
    local player = bo2.player
    if player == nil then
      return
    end
    if w_scn.scn ~= nil then
      w_scn.scn:clear_obj(bo2.eScnObjKind_Player)
    end
    ciPlayerSex = ui.safe_get_atb(bo2.eAtb_Sex)
    local ref_view_edit_scn = view_edit_scn[ciPlayerSex]
    w_scn:set_excel_id(ref_view_edit_scn.scn_id)
    p_view_player = w_scn.scn:create_obj(bo2.eScnObjKind_Player, player.excel.id)
    p_view_player.view_target = player
    p_view_player:set_view_equip(bo2.eEquipData_MainWeapon, 1)
    p_view_player:set_view_equip(bo2.eEquipData_FuMo_MainWeapon, 1)
    p_view_player:set_view_equip(bo2.eEquipData_2ndWeapon, 1)
    p_view_player:set_view_equip(bo2.eEquipData_FuMo_2ndWeapon, 1)
    p_view_player:ViewPlayerAnimPlay(ciViewPlayerAnim, true, false)
    w_scn.scn:set_fov(ref_view_edit_scn.fov)
    w_scn.scn:bind_camera(p_view_player)
    w_scn.scn:modify_camera_view_type(p_view_player, bo2.eCameraFoot)
    for i = 0, face_page_entitys - 1 do
      local data = face_scn[i]
      local parent = w_main:search(data.name)
      data.scn_ctrl = parent:search(L("scn_view"))
      data.scn_ctrl:set_excel_id(ref_view_edit_scn.scn_id)
      data.sel_ctrl = parent:search(L("highlight_select"))
      data.curr_ctrl = parent:search(L("highlight_current"))
    end
    face_current = p_view_player:get_target_equip(bo2.eEquipData_Face)
    face_select = face_current
    local bodily_form = ui.safe_get_atb(bo2.eAtb_ExcelID)
    local barber_shop = bo2.gv_barber_shop
    local barber_shop_size = barber_shop.size
    local face_cnt = 0
    for i = 0, barber_shop_size - 1 do
      local p_mb_data = barber_shop:get(i)
      if p_mb_data.type == 2 and bodily_form == p_mb_data.restrict_type then
        face_list[face_cnt] = {
          idx = face_cnt,
          excel_id = p_mb_data.id,
          face_id = p_mb_data._data,
          item_id = p_mb_data.cast_item_id,
          item_cnt = p_mb_data.cast_item_cnt,
          money = p_mb_data.cast_money
        }
        face_cnt = face_cnt + 1
      end
    end
    for i = 0, face_page_entitys - 1 do
      face_scn[i].index = 0
    end
    face_page_count = math.floor(face_cnt / face_page_entitys)
    face_page_current = math.floor(face_current / face_page_entitys)
    update_page(face_page_current)
    for name, value in pairs(slider_type) do
      for i, face_value in pairs(face_list) do
        if face_value.face_id == face_current then
          value.init_value[face_value.face_id] = player:get_flag_int8(value.flag)
          value.curr_value[face_value.face_id] = value.init_value[face_value.face_id]
        else
          value.init_value[face_value.face_id] = ciDefaultValue
          value.curr_value[face_value.face_id] = ciDefaultValue
        end
      end
      local parent = w_main:search(name)
      if parent ~= nil then
        local ctrl = parent:search(L("slider"))
        if ctrl ~= nil then
          value.slider_ctrl = ctrl
          ctrl.scroll = value.curr_value[face_select] / cValueMax
        end
        local btn = parent:search(L("btn_undo"))
        value.undo_ctrl = btn
      end
      p_view_player:set_flag_int8(value.flag, value.curr_value[face_select])
    end
  elseif w_scn.scn ~= nil then
    w_scn.scn:destory_obj(p_view_player)
    p_view_player = nil
  end
end
function on_card_item()
end
function select_face(face_id)
  update_select(face_id)
  local page = face_page_current
  local face = get_face_from_id(face_id)
  if face ~= nil then
    page = math.floor(face.idx / face_page_entitys)
  end
  update_page(page)
end
function on_select_face(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local scn_ctrl = card:search("scn_view")
    for i = 0, face_page_entitys - 1 do
      local scn = face_scn[i]
      if scn.scn_ctrl == scn_ctrl then
        if 0 < scn.index then
          select_face(scn.index)
        end
        break
      end
    end
  elseif msg == ui.mouse_rbutton_click then
    select_face(face_current)
  end
end
function update_select(face_id)
  if face_id == face_select then
    return
  end
  face_select = face_id
  p_view_player:set_view_equip(bo2.eEquipData_Face, face_id)
  for name, value in pairs(slider_type) do
    value.slider_ctrl.scroll = value.curr_value[face_select] / cValueMax
  end
  on_modify_value()
end
function update_scn(page)
  face_page_current = page
  local player = bo2.player
  if player == nil then
    return
  end
  for idx = 0, face_page_entitys - 1 do
    local data = face_scn[idx]
    local scn = data.scn_ctrl.scn
    local p
    data.curr_ctrl.visible = false
    data.sel_ctrl.visible = false
    local list_idx = page * face_page_entitys + idx
    local face_data = face_list[list_idx]
    if face_data ~= nil then
      if face_data.face_id ~= data.index then
        scn:destory_obj(data.player)
        data.player = scn:create_obj(bo2.eScnObjKind_Player, player.excel.id)
        p = data.player
        p.view_target = player
        p:set_view_equip(bo2.eEquipData_MainWeapon, 1)
        p:set_view_equip(bo2.eEquipData_FuMo_MainWeapon, 1)
        p:set_view_equip(bo2.eEquipData_2ndWeapon, 1)
        p:set_view_equip(bo2.eEquipData_FuMo_2ndWeapon, 1)
        p:ViewPlayerAnimPlay(ciViewPlayerAnim, true, false)
        local ref_view_edit_scn = view_edit_scn[ciPlayerSex]
        scn:set_fov(ref_view_edit_scn.fov)
        scn:bind_camera(p_view_player)
        scn:modify_camera_view_type(p_view_player, bo2.eCameraFoot)
        data.index = face_data.face_id
        p:set_view_equip(bo2.eEquipData_Face, data.index)
      end
      if data.index == face_current then
        data.curr_ctrl.visible = true
      end
      if data.index == face_select then
        data.sel_ctrl.visible = true
      end
    else
      data.index = 0
      scn:destory_obj(data.player)
    end
  end
end
function update_page(page)
  ui_widget.ui_stepping.set_page(step_ctrl, page, face_page_count)
  update_scn(page)
end
function get_face_from_id(face_id)
  for i, face_value in pairs(face_list) do
    if face_value.face_id == face_id then
      return face_value
    end
  end
  return nil
end
function on_modify_value()
  local money = 0
  local change_item_id = 0
  local change_item_cnt = 0
  local diy_item_id = 0
  local diy_item_count = 0
  if face_select ~= face_current then
    local face_data = get_face_from_id(face_select)
    if face_data ~= nil then
      money = face_data.money
      change_item_id = face_change_itemId_Free
      change_item_cnt = face_change_itemCount_Free
      if change_item_cnt > ui.item_get_count(change_item_id, true) then
        change_item_id = face_data.item_id
        change_item_cnt = face_data.item_cnt
      end
    end
  end
  for name, value in pairs(slider_type) do
    if value.init_value[face_select] ~= value.curr_value[face_select] then
      money = money + face_diy_money
      diy_item_id = face_diy_itemId_Free
      diy_item_count = face_diy_itemCount_Free
      if diy_item_count > ui.item_get_count(diy_item_id, true) then
        diy_item_id = face_diy_itemId
        diy_item_count = face_diy_itemCount
      end
      break
    end
  end
  ui_npcfunc.ui_cell.set(w_item_change, change_item_id, change_item_cnt)
  w_money.money = money
  ui_npcfunc.ui_cell.set(w_item_diy, diy_item_id, diy_item_count)
end
function on_slider_move(ctrl)
  local name = ctrl.parent.parent.name
  local value = slider_type[name]
  if value ~= nil then
    local var = ctrl.scroll * cValueMax
    p_view_player:set_flag_int8(value.flag, var)
    value.curr_value[face_select] = p_view_player:get_flag_int8(value.flag)
    on_modify_value()
  end
end
function on_btn_undo(ctrl)
  local name = ctrl.parent.name
  local value = slider_type[name]
  if value ~= nil then
    value.slider_ctrl.scroll = value.init_value[face_select] / cValueMax
  end
end
function on_btn_enter()
  if p_view_player == nil then
    return
  end
  local data = face_list[face_select - 1]
  local v = sys.variant()
  local bModify = false
  if face_select ~= face_current then
    v:set(packet.key.ui_barbershop_excel_id, data.excel_id)
    bModify = true
  end
  for name, value in pairs(slider_type) do
    local init_value = value.init_value[face_select]
    local curr_value = value.curr_value[face_select]
    if init_value ~= curr_value then
      v:set(value.packet_key, curr_value)
      bModify = true
    end
  end
  if bModify == true then
    bo2.send_variant(packet.eCTS_UI_FaceLifting, v)
  end
end
function on_reset_confirm(msg)
  if msg.result == 0 then
    return
  end
  for i, face_value in pairs(face_list) do
    face_select = face_value.face_id
    for name, value in pairs(slider_type) do
      value.curr_value[face_value.face_id] = value.init_value[face_value.face_id]
    end
  end
  face_select = -1
  select_face(face_current)
  update_page(face_page_current)
end
function on_btn_reset()
  if p_view_player == nil then
    return
  end
  local msg = {
    callback = on_reset_confirm,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.title = ui.get_text("npcfunc|face_confirm")
  msg.text = ui.get_text("npcfunc|face_reset_note")
  ui_widget.ui_msg_box.show_common(msg)
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
  parent:insert_on_mouse(on_mouse, "ui_npcfunc.ui_face_lifting.on_sld_init:on_mouse")
end
function update_quick_buy(btn, item_id)
  btn.visible = false
  local goods_id = ui_supermarket2.shelf_quick_buy_id(item_id)
  if goods_id == 0 then
    return
  end
  btn.name = goods_id
  btn.visible = true
end
function on_chg_item_count(card)
  if sys.check(w_chg_quick_buy) then
    update_quick_buy(w_chg_quick_buy, card.excel_id)
  end
end
function on_diy_item_count(card)
  if sys.check(w_diy_quick_buy) then
    update_quick_buy(w_diy_quick_buy, card.excel_id)
  end
end
function on_quick_buy_click(btn)
  ui_supermarket2.shelf_singleBuy(btn)
end
