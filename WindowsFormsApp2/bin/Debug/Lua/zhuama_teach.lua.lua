local reg = ui_packet.game_recv_signal_insert
local sig = "ui_zdteach.packet_handle"
local zhuama_npc_table = {
  25401,
  25402,
  25403,
  25404,
  25405,
  25406,
  25407,
  25408,
  25409,
  25410,
  25411
}
zhuama_skill_id = 135034
function zhuama_skill_use()
end
function on_player_set_target(obj, key)
  local scn = bo2.scn
  if scn == nil then
    return
  end
  local function find_npc(npc)
    local npc_id = npc.excel.id
    for i, v in ipairs(zhuama_npc_table) do
      if npc_id == v then
        scn:UnValidNpcHandsonTips(npc.sel_handle)
      end
    end
  end
  scn:ForEachScnObj(2, find_npc)
  ui_handson_teach.on_add_zhuama_sysshortcut(zhuama_skill_id, true)
  bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_set_target, "ui_zdteach:on_player_set_target")
end
function zhuama_popo()
  local scn = bo2.scn
  if scn == nil then
    return
  end
  local function find_npc(npc)
    local npc_id = npc.excel.id
    for i, v in ipairs(zhuama_npc_table) do
      if npc_id == v then
        scn:UnValidNpcHandsonTips(npc.sel_handle)
        local text = sys.format(L("<handson:0,4,,80>"))
        scn:SetNpcHandsonTipsByHandle(npc.sel_handle, text)
      end
    end
  end
  scn:ForEachScnObj(2, find_npc)
  bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_set_target, on_player_set_target, "ui_zdteach:on_player_set_target")
end
function handle_teach_zhuama(cmd, data)
  local cmn_id = data:get(packet.key.cmn_id).v_int
  if cmn_id == 1 then
  elseif cmn_id == 0 then
    bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_set_target, "ui_zdteach:on_player_set_target")
  end
end
reg(packet.eSTC_Teach_ZhuaMa, handle_teach_zhuama, sig)
function zhuama_fail(data)
  ui_handson_teach.on_add_zhuama_sysshortcut(zhuama_skill_id, true)
  ui_qbar.ui_keyboard.show_mini(false)
end
function handle_zhuama_follow(cmd, data)
  local scn = bo2.scn
  if scn == nil then
    return
  end
  local flag = data:get(packet.key.cmn_system_flag).v_int
  if flag == 1 then
    zhuama_fail(data)
    return
  end
  local onlyid = data:get(packet.key.cmn_id).v_string
  local function find_npc(npc)
    local npc_id = npc.only_id
    if onlyid == npc_id then
      scn:UnValidNpcHandsonTips(npc.sel_handle)
      local text = sys.format(L("<handson:0,4,,82>"))
      scn:SetNpcHandsonTipsByHandle(npc.sel_handle, text)
    end
  end
  scn:ForEachScnObj(2, find_npc)
  ui_handson_teach.on_add_zhuama_sysshortcut(zhuama_skill_id, false)
  run_mini()
end
function run_mini()
  ui_qbar.ui_keyboard.show_mini(true, ui.rect(-6, 30, 300, 220))
  ui_qbar.ui_keyboard.flash_clear()
  ui_qbar.ui_keyboard.flash_insert_keys({
    "w",
    "a",
    "s",
    "d"
  })
  ui_handson_teach.test_complate_keyboard(true, 175)
end
reg(packet.eSTC_Teach_ZhuaMa_Follow, handle_zhuama_follow, sig)
function handle_zhuama_qte(cmd, data)
  local scn = bo2.scn
  if scn == nil then
    return
  end
  local onlyid = data:get(packet.key.cmn_id).v_string
  local function find_npc(npc)
    local npc_id = npc.only_id
    if onlyid == npc_id then
      scn:UnValidNpcHandsonTips(npc.sel_handle)
      local text = sys.format(L("<handson:0,4,,83>"))
      scn:SetNpcHandsonTipsByHandle(npc.sel_handle, text)
    end
  end
  scn:ForEachScnObj(2, find_npc)
  ui_qbar.ui_keyboard.show_mini(false, ui.rect(-6, 30, 300, 220))
end
reg(packet.eSTC_Teach_ZhuaMa_QTE, handle_zhuama_qte, sig)
