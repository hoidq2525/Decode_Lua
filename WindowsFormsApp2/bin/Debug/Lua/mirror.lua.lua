function mirror_UpdateMirrorInfo()
  if not w_mirror_info.visible then
    return
  end
  local scn = w_mirror.scn
  local x = scn:get_camera_angle(0)
  local y = scn:get_camera_angle(1)
  local z = scn:get_camera_angle(2)
  w_mirror_info.text = string.format("x=%f,y=%f,z=%f", x, y, z)
end
local mirrorPlayer
function mirror_OpenMirror(ctrl, visible, npc)
  if not visible or mirrorPlayer and not npc then
    return
  end
  ResetEquip(g_npc)
end
function mirror_RotateMirror(ctrl, msg)
  if msg == ui.mouse_lbutton_down and w_mirror.rotate_angle == 0 then
    w_mirror.rotate_angle = tostring(ctrl.name)
  elseif msg == ui.mouse_lbutton_up and w_mirror.rotate_angle ~= 0 then
    w_mirror.rotate_angle = 0
  end
end
function mirror_ResetEquip()
  ResetEquip(g_npc)
end
function ResetEquip(npc)
  local scn = w_mirror.scn
  scn:clear_obj(-1)
  local house = scn:create_obj(bo2.eScnObjKind_Npc, 4877)
  house:SetScale(2.5, 0, 1)
  if bo2.player and not npc then
    mirrorPlayer = scn:create_obj(bo2.eScnObjKind_Player, bo2.player.excel.id, "playerbegin")
    mirrorPlayer.view_target = bo2.player
  else
    npc = npc and npc.v_int or 6
    mirrorPlayer = scn:create_obj(bo2.eScnObjKind_Npc, npc, "playerbegin")
  end
  local mirrorSetting = bo2.gv_cha_mirror:find(mirrorPlayer.excel.id)
  if mirrorSetting then
    local h = mirrorSetting.h
    if not w_mirror_height.text.empty then
      h = tonumber(tostring(w_mirror_height.text))
    end
    scn:bind_camera(mirrorPlayer, h, mirrorSetting.z, mirrorSetting.y, mirrorSetting.x)
  else
    scn:bind_camera(mirrorPlayer)
  end
  mirrorPlayer:SetNoActionAnim(bo2.eStopType_UI, true)
  if npc then
    scn:set_fov(1)
    scn:change_angle_x(-1.57)
    mirrorPlayer:SetScale(0.5, 0, 1)
  else
    mirrorPlayer:ViewPlayerAnimPlay(545, true, false)
    scn:set_fov(0.8)
  end
  scn:modify_camera_view_type(mirrorPlayer, bo2.eCameraInitNoAlpha)
end
function mirror_Init()
  mirrorPlayer = nil
end
function mirror_SetEquip(slot, model)
  if g_npc then
    g_npc = nil
    ResetEquip()
  end
  w_mirrorMain.visible = true
  w_mirrorMain:insert_post_invoke(function()
    mirrorPlayer:set_view_equip(slot, model)
  end)
  w_mirrorMain:move_to_head()
end
function mirror_ShowNPC(npc)
  g_npc = {v_int = npc}
  ResetEquip(g_npc)
  w_mirrorMain.visible = true
  w_mirrorMain:move_to_head()
end
