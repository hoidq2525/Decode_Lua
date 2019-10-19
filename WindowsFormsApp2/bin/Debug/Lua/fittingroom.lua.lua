local cvalue_color_red = L("FF0000")
local cvalue_color_green = L("00FF00")
local p_fitting_player
local c_scn_excel_id = 1020
local g_tattoo_first = {}
g_tattoo_first[1] = 1
g_tattoo_first[2] = 619
local bFeature = false
local bWeapon = false
local bTattoo = false
local bHat = false
local bMouseFitting = false
local g_view_item = {}
local g_resume_tattoo_list = {}
g_resume_tattoo_list[1] = bo2.eEquipData_Avatar_Body
g_resume_tattoo_list[2] = bo2.eEquipData_Body
local g_resume_weapon_list = {}
g_resume_weapon_list[1] = bo2.eEquipData_MainWeapon
g_resume_weapon_list[2] = bo2.eEquipData_2ndWeapon
g_resume_weapon_list[3] = bo2.eEquipData_HWeapon
local g_resume_hat_list = {}
g_resume_hat_list[1] = bo2.eEquipData_Avatar_Hat
g_slot_to_equip = {}
function init_once()
  g_slot_to_equip[bo2.eItemSlot_MainWeapon] = bo2.eEquipData_MainWeapon
  g_slot_to_equip[bo2.eItemSlot_2ndWeapon] = bo2.eEquipData_2ndWeapon
  g_slot_to_equip[bo2.eItemSlot_Avatar_Imprint] = bo2.eEquipData_Imprint
  g_slot_to_equip[bo2.eItemSlot_Avatar_Hat] = bo2.eEquipData_Avatar_Hat
  g_slot_to_equip[bo2.eItemSlot_Avatar_Body] = bo2.eEquipData_Avatar_Body
  g_slot_to_equip[bo2.eItemSlot_HWeapon] = bo2.eEquipData_HWeapon
end
init_once()
function clear_view_item()
  g_view_item = {}
end
function insert_view_item(iType, iVal)
  g_view_item[iType] = iVal
end
function on_create_fitting_player()
  local obj = bo2.player
  if obj == nil then
    return
  end
  w_scn:set_excel_id(c_scn_excel_id)
  local scn = w_scn.scn
  p_fitting_player = scn:create_obj(bo2.eScnObjKind_Player, obj.excel.id)
  p_fitting_player.view_target = obj
  scn:modify_camera_view_type(p_fitting_player, bo2.eCameraInit)
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
  else
    ui.clean_drop()
    clear_view_item()
    on_destroy_scn()
    ui_widget.esc_stk_pop(w)
  end
end
function on_init_fitting_room()
  bFeature = false
  bWeapon = false
  bTattoo = false
  bHat = false
end
function on_destroy_scn()
  if w_scn ~= nil then
    w_scn:set_excel_id(0)
  end
  p_fitting_player = nil
end
function on_fitting_item(iType, iVal, excl)
  if iType == nil then
    return
  end
  insert_view_item(iType, iVal)
  if w_main.visible == false then
    w_main.visible = true
    on_create_fitting_player()
    on_click_display_tattoo(nil)
    on_click_display_main_weapon(nil)
    on_click_display_feature(nil)
    on_click_display_hat(nil)
  end
  local function view_tattoo(view)
    if bTattoo ~= view then
      ui_fitting_room.btn_view_tattoo.check = view
      on_click_display_tattoo(ui_fitting_room.btn_view_tattoo)
    end
  end
  local function view_feature(view)
    if bFeature ~= view then
      ui_fitting_room.btn_view_feature.check = view
      on_click_display_feature(ui_fitting_room.btn_view_feature)
    end
  end
  local function view_equip(view)
    if bWeapon ~= view then
      ui_fitting_room.btn_view_weapon.check = view
      on_click_display_main_weapon(ui_fitting_room.btn_view_weapon)
    end
  end
  if bo2.eEquipData_Imprint == iType then
    view_tattoo(true)
    view_feature(true)
  elseif iType == bo2.eEquipData_Body or iType == bo2.eEquipData_Avatar_Body then
    view_tattoo(false)
    view_feature(false)
  elseif iType == bo2.eEquipData_MainWeapon or iType == bo2.eEquipData_2ndWeapon then
    view_equip(false)
    view_feature(false)
  end
  if iType == bo2.eEquipData_Avatar_Hat then
    bHat = true
    w_btn_toggle_hat_equip.visible = false
    w_btn_toggle_hat_avatar.visible = true
    display_hat_or_hair()
    view_feature(true)
    return
  end
  if excl and bo2.gv_state_container:find(excl.fitting_room) then
    p_fitting_player:AddState(10651, p_fitting_player)
  end
  p_fitting_player:set_view_equip(iType, iVal)
end
function on_set_hair_color(v)
  p_fitting_player:set_hair_color(v)
  local msg = sys.format(ui.get_text("item|fitting_item_successed"))
  ui_tool.note_insert(msg, cvalue_color_green)
end
function on_click_fitting_item(iType, iVal, excl)
  on_fitting_item(iType, iVal, excl)
  local msg = sys.format(ui.get_text("item|fitting_item_successed"))
  ui_tool.note_insert(msg, cvalue_color_green)
end
function on_click_set_mouse_icon()
  local data = sys.variant()
  data:set("drop_type", ui_widget.c_drop_type_fitting)
  local on_click_hook = function(w, msg, pos, data)
  end
  ui.setup_drop(ui_tool.w_fitting_floater, data, on_click_hook)
end
function on_click_reset()
  for i in pairs(g_view_item) do
    local _set_val = p_fitting_player:get_target_equip(i)
    p_fitting_player:set_view_equip(i, _set_val)
  end
  p_fitting_player:set_hair_color(0)
  clear_view_item()
  on_click_display_tattoo(nil)
  on_click_display_main_weapon(nil)
  on_click_display_hat(nil)
end
function on_click_close()
  w_main.visible = false
end
local function resume_view_equip(view_list)
  local bSuccessed = false
  for i, v in pairs(view_list) do
    if g_view_item[v] ~= nil then
      p_fitting_player:set_view_equip(v, g_view_item[v])
      bSuccessed = true
    elseif v == bo2.eEquipData_Avatar_Body then
      p_fitting_player:set_view_equip(v, 0)
    end
  end
  return bSuccessed
end
function on_click_display_tattoo(btn)
  if btn ~= nil then
    bTattoo = not bTattoo
  end
  if bTattoo ~= true then
    local r = resume_view_equip(g_resume_tattoo_list)
    if r ~= false then
      return
    end
    local avatar_body_idx = p_fitting_player:get_target_equip(bo2.eEquipData_Avatar_Body)
    if avatar_body_idx ~= 0 then
      p_fitting_player:set_view_equip(bo2.eEquipData_Avatar_Body, avatar_body_idx)
    else
      p_fitting_player:set_view_equip(bo2.eEquipData_Avatar_Body, 0)
      local body_idx = p_fitting_player:get_target_equip(bo2.eEquipData_Body)
      p_fitting_player:set_view_equip(bo2.eEquipData_Body, body_idx)
    end
  else
    local cur_sex = ui.safe_get_atb(bo2.eAtb_Sex)
    if cur_sex ~= 1 and cur_sex ~= 2 then
      ui.log("cur_sex" .. cur_sex)
      return
    end
    local set_idx = g_tattoo_first[cur_sex]
    p_fitting_player:set_view_equip(bo2.eEquipData_Avatar_Body, set_idx)
    p_fitting_player:set_view_equip(bo2.eEquipData_Body, set_idx)
  end
end
function display_hat_or_hair()
  if bHat ~= true then
    local view_player_hair_idx = p_fitting_player:get_target_equip(bo2.eEquipData_Hair)
    p_fitting_player:set_view_equip(bo2.eEquipData_Hair, view_player_hair_idx)
  else
    local r = resume_view_equip(g_resume_hat_list)
    if r ~= false then
      return
    end
    local obj = bo2.player
    local view_player_hat_idx = p_fitting_player:get_target_equip(bo2.eEquipData_Avatar_Hat)
    p_fitting_player:set_view_equip(bo2.eEquipData_Avatar_Hat, view_player_hat_idx)
  end
end
function on_click_display_hat(btn)
  if btn ~= nil then
    bHat = not bHat
    w_btn_toggle_hat_equip.visible = not bHat
    w_btn_toggle_hat_avatar.visible = bHat
  end
  display_hat_or_hair()
end
function on_click_display_main_weapon(btn)
  if btn ~= nil then
    bWeapon = not bWeapon
  end
  if bWeapon ~= true then
    local obj = bo2.player
    local view_player_weapon_idx = p_fitting_player:get_target_equip(bo2.eEquipData_MainWeapon)
    local view_player_2nd_weapon_idx = p_fitting_player:get_target_equip(bo2.eEquipData_2ndWeapon)
    local view_player_hide_weapon_idx = p_fitting_player:get_target_equip(bo2.eEquipData_HWeapon)
    p_fitting_player:set_view_equip(bo2.eEquipData_MainWeapon, view_player_weapon_idx)
    p_fitting_player:set_view_equip(bo2.eEquipData_2ndWeapon, view_player_2nd_weapon_idx)
    p_fitting_player:set_view_equip(bo2.eEquipData_HWeapon, view_player_hide_weapon_idx)
    resume_view_equip(g_resume_weapon_list)
  else
    p_fitting_player:set_view_equip(bo2.eEquipData_MainWeapon, -1)
    p_fitting_player:set_view_equip(bo2.eEquipData_2ndWeapon, -1)
    p_fitting_player:set_view_equip(bo2.eEquipData_HWeapon, -1)
  end
end
function on_click_display_feature(btn)
  if btn ~= nil then
    bFeature = not bFeature
  end
  if bFeature ~= true then
    local scn = w_scn.scn
    scn:modify_camera_view_type(p_fitting_player, bo2.eCameraInit)
  else
    local scn = w_scn.scn
    scn:modify_camera_view_type(p_fitting_player, bo2.eCameraFace)
  end
end
function test_item_may_suit(excel)
  if excel == nil then
    return false
  end
  local pExcel = excel
  local cur_sex = ui.safe_get_atb(bo2.eAtb_Sex)
  local require_size = pExcel.requires.size - 1
  for i = 0, require_size, 2 do
    if pExcel.requires[i] == bo2.eItemReq_Sex and require_size >= i + 1 and cur_sex ~= pExcel.requires[i + 1] then
      return false
    end
  end
  local pModelType = bo2.gv_item_type:find(pExcel.type)
  if pModelType == nil then
    return false
  end
  local iEquipType = g_slot_to_equip[pModelType.equip_slot]
  if iEquipType ~= nil then
    return true, iEquipType
  end
  return false
end
function req_fitting_quan(excel, info)
  if info then
    if excel.id == 58212 then
      local id = info:get_data_32(bo2.eItemInt32_BarberShopProp1)
      local pExcel = bo2.gv_equip_item:find(id)
      req_fitting_item_by_excel(pExcel)
    elseif excel.id == 58210 then
      local id1 = info:get_data_32(bo2.eItemInt32_BarberShopProp1)
      local id2 = info:get_data_32(bo2.eItemInt32_BarberShopProp2)
      if id1 > 0 then
        local pExcel = bo2.gv_barber_shop:find(id1)
        if pExcel == nil then
          return
        end
        on_fitting_item(bo2.eEquipData_Face, pExcel._data)
      end
      if id2 > 0 then
        local pExcel = bo2.gv_barber_shop:find(id2)
        if pExcel == nil then
          return
        end
      end
    elseif excel.id == 58211 then
      local id1 = info:get_data_32(bo2.eItemInt32_BarberShopProp1)
      local id2 = info:get_data_32(bo2.eItemInt32_BarberShopProp2)
      if id1 > 0 then
        local pExcel = bo2.gv_barber_shop:find(id1)
        if pExcel == nil then
          return
        end
        on_fitting_item(bo2.eEquipData_Hair, pExcel._data)
      end
      if id2 > 0 then
        local pExcel = bo2.gv_barber_shop:find(id2)
        if pExcel == nil then
          return
        end
        p_fitting_player:set_hair_color(pExcel._hex_data)
      end
    end
  end
end
function req_fitting_item_by_excel(excel, info)
  if excel.ptype.id == bo2.eItemtype_BarberQuan then
    req_fitting_quan(excel, info)
    return
  end
  local bFitting, iEquipType = test_item_may_suit(excel)
  if bFitting ~= false and iEquipType ~= nil then
    on_click_fitting_item(iEquipType, excel.model, excel)
    return
  elseif excel.fitting_index.size > 0 then
    local bFittingRst = true
    local size = excel.fitting_index.size
    for i = 0, size - 1 do
      local v = excel.fitting_index[i]
      local equip_excel = bo2.gv_equip_item:find(v)
      if sys.check(equip_excel) then
        bFitting, iEquipType = test_item_may_suit(equip_excel)
        bFittingRst = bFittingRst and bFitting
        if bFitting ~= false and iEquipType ~= nil then
          on_click_fitting_item(iEquipType, equip_excel.model)
        end
      end
    end
    if bFittingRst == true then
      return
    end
  end
  local msg = sys.format(ui.get_text("item|fitting_item_faild"))
  ui_tool.note_insert(msg, cvalue_color_red)
end
local f_rot_angle = 90
function on_doll_rotl_click(btn, press)
  if press then
    w_scn.rotate_angle = -f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
end
function on_doll_rotr_click(btn, press)
  if press then
    w_scn.rotate_angle = f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
end
function on_self_enter(obj, msg)
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_fittion_room.on_self_enter")
