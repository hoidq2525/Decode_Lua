local p_view_player
local ciViewPlayerAnim = 545
local f_rot_angle = 90
local cValueMax = 255
local view_edit_scn = {}
view_edit_scn[1] = {scn_id = 1031, fov = 0.35}
view_edit_scn[2] = {scn_id = 1031, fov = 0.35}
local ciPlayerSex = 0
local ciDefaultValue = 128
local body_diy_money = 0
local body_diy_itemId = 0
local body_diy_itemCount = 0
local body_diy_itemIdFree = 0
local body_diy_itemCountFree = 0
local slider_type = {}
function on_page_step(var)
  update_page(var.index)
end
function on_init(ctrl)
  body_diy_money = bo2.gv_define:find(399).value.v_int
  body_diy_money_type = bo2.gv_define:find(400).value.v_int
  body_diy_itemId = bo2.gv_define:find(401).value.v_int
  body_diy_itemCount = bo2.gv_define:find(402).value.v_int
  body_diy_itemIdFree = bo2.gv_define:find(404).value.v_int
  body_diy_itemCountFree = bo2.gv_define:find(405).value.v_int
  if body_diy_money_type ~= 0 then
    w_money.bounded = false
  end
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
function on_modify_value()
  local money = 0
  local diy_item_id = 0
  local diy_item_count = 0
  for name, value in pairs(slider_type) do
    if value.init_value ~= value.curr_value then
      money = body_diy_money
      diy_item_id = body_diy_itemIdFree
      diy_item_count = body_diy_itemCountFree
      if diy_item_count > ui.item_get_count(diy_item_id, true) then
        diy_item_id = body_diy_itemId
        diy_item_count = body_diy_itemCount
      end
      break
    end
  end
  ui_npcfunc.ui_cell.set(w_item_change, diy_item_id, diy_item_count)
  w_money.money = money
end
function on_slider_move(ctrl)
  local name = ctrl.parent.parent.name
  local value = slider_type[name]
  if value ~= nil then
    local var = ctrl.scroll * cValueMax
    p_view_player:set_flag_int8(value.flag, var)
    value.curr_value = p_view_player:get_flag_int8(value.flag)
    on_modify_value()
  end
end
function on_btn_undo(ctrl)
  local name = ctrl.parent.name
  local value = slider_type[name]
  if value ~= nil then
    value.slider_ctrl.scroll = value.init_value / cValueMax
  end
end
function on_btn_enter()
  if p_view_player == nil then
    return
  end
  local v = sys.variant()
  local bModify = false
  for name, value in pairs(slider_type) do
    local init_value = value.init_value
    local curr_value = value.curr_value
    if init_value ~= curr_value then
      v:set(value.packet_key, curr_value)
      bModify = true
    end
  end
  if bModify == true then
    bo2.send_variant(packet.eCTS_UI_BodyLifting, v)
  end
end
function on_reset_confirm(msg)
  if msg.result == 0 then
    return
  end
  for name, value in pairs(slider_type) do
    value.curr_value = value.init_value
    value.slider_ctrl.scroll = value.init_value / cValueMax
  end
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
  parent:insert_on_mouse(on_mouse, "ui_npcfunc.ui_body_lifting.on_sld_init:on_mouse")
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
