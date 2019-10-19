local cNpcOnMouseText = L("<handson:5,4>")
local cCheckScnExcelId = {}
local g_active_ctrl_move_teach = false
g_quest_item_gain = false
function init_once()
  cCheckScnExcelId[6] = bo2.ePlayerFlagInt16_HandsOn_YouXuanValley_DungeonInfo
  cCheckScnExcelId[202] = bo2.ePlayerFlagInt16_HandsOn_MonsterSealPlace_DungeonInfo
end
init_once()
function test_complate_move(area_id)
  if handson_teach_move ~= area_id then
    return
  end
end
function test_complate_milestone_visible(milestone_id)
  on_theme_milestone_vis(milestone_id)
  if milestone_id == ui_handson_teach.handson_teach_manual_levelup then
    ui_handson_teach.on_teach_quest(ui_handson_teach.handson_teach_manual_levelup, ui_handson_teach.cQuestTeachType_Add)
  end
  local on_fun = function(milestone_id)
    local theme = g_theme[18]
    if milestone_id == 1021 then
      return
    elseif milestone_id == 1022 then
      if g_new_item_notify ~= nil and g_new_item_notify == true then
        return
      end
      g_new_item_notify = true
    end
    if g_theme[18] == nil or g_theme[18].page == nil or g_quest_data == nil then
      return nil
    end
    return on_theme_visible(g_theme[18], milestone_id, true)
  end
  on_fun(milestone_id)
end
function test_complate_on_insert_quest(quest_id)
  if quest_id == 2039 then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_Group, ui_handson_teach.cQuestTeachType_Add)
  end
end
function test_complate_milestone_update(milestone_id)
  local id = g_update_milestone_data[milestone_id]
  if id ~= nil then
    local quest_data = g_quest_data[id]
    if quest_data ~= nil then
      local skill_info = ui.skill_find(g_quest_data[id].handson_teach.skill_id)
      if skill_info ~= nil and skill_info.cooldown <= 0 then
        g_quest_data[id].handson_teach.active_skill = 1
      else
        g_quest_data[id].handson_teach.active_skill = 0
      end
    end
    on_active_quest_trace(milestone_id)
  end
  local g_update_milestone_id = {}
  for i, v in pairs(g_update_milestone_id) do
    if v == milestone_id then
      on_active_quest_trace(milestone_id)
    end
  end
  if milestone_id == 1025 then
    local on_time_milestone = function()
      if sys.check(bo2.scn) ~= true then
        return
      end
      if g_milestone1025_update == false then
        g_milestone1025_update = true
        on_theme_milestone_vis(25)
        ui_handson_teach.on_add_sysshortcut(135028)
      end
    end
    bo2.AddTimeEvent(5, on_time_milestone)
  end
end
function run_1()
  test_complate_milestone_close(1025)
end
function test_complate_milestone_close(milestone_id)
  if g_update_milestone_data[milestone_id] == nil then
    on_active_quest_trace(milestone_id)
  end
end
function test_complate_mark_list(mark_id, link_id)
  on_finish_quest_mb_by_mark_id(mark_id, link_id)
  if mark_id == 79 then
    on_theme_visible(g_theme[24], 2002, false)
  elseif mark_id == 3207 then
    mouse_wheel_teach()
  end
end
function test_complate_quest_talk(talk_id, vis)
  on_talk_page_visible(talk_id, vis)
end
function test_complate_chest(excel_id)
end
function test_complate_view_item_tip(item_excel_id, vis)
  on_theme_visible(g_theme[24], item_excel_id, vis)
end
function test_complate_npc_Lum(pExcel, v)
  if ui_handson_teach.handson_teach_active_on_mouse_npc == 0 then
    return
  end
  if pExcel.id == ui_handson_teach.handson_teach_active_on_mouse_npc or ui_handson_teach.handson_teach_active_on_mouse_npc1 ~= nil and pExcel.id == ui_handson_teach.handson_teach_active_on_mouse_npc1 then
    local scn = bo2.scn
    if sys.check(scn) ~= true or scn.excel.id ~= ui_handson_teach.cHandson_Teach_Scn_Id then
      return
    end
    local cur_idx = v:get(packet.key.scnobj_handle).v_int
    local is_dead = v:get(packet.key.ui_deathCD).v_number
    if handson_teach_active_on_mouse_npc_handle ~= 0 then
      if cur_idx == handson_teach_active_on_mouse_npc_handle then
        if is_dead ~= 0 then
          scn:UnValidNpcHandsonTips(handson_teach_active_on_mouse_npc_handle)
          handson_teach_active_on_mouse_npc_handle = 0
        end
        return
      end
      scn:UnValidNpcHandsonTips(handson_teach_active_on_mouse_npc_handle)
    end
    if is_dead ~= 0 then
      handson_teach_active_on_mouse_npc_handle = 0
      return false
    end
    handson_teach_active_on_mouse_npc_handle = cur_idx
    scn:SetNpcHandsonTipsByHandle(handson_teach_active_on_mouse_npc_handle, cNpcOnMouseText)
  end
end
function test_complate_level_monitor(vis)
  on_vis_personal_page(vis)
  if vis ~= false then
    local obj = bo2.player
    if sys.check(obj) == true then
      local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_ReputationShop_Qbar)
      if flag_value == 16 then
        ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_ReputationShop_PeronalButton, ui_handson_teach.cQuestTeachType_Add)
      end
    end
  else
  end
end
function test_complate_gain_item(item_id)
  if g_handson_freshers_item ~= nil then
    local iItemBegin = g_handson_freshers_item.item_id_begin
    local iItemEnd = g_handson_freshers_item.item_id_end
    if item_id >= iItemBegin and item_id < iItemEnd then
      local quest_flag = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_FrishersItem_8)
      ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_FrishersItem_8, ui_handson_teach.cQuestTeachType_Add)
      if quest_flag == 0 and sys.check(bo2.player) then
        local eCurLevel = bo2.player:get_atb(bo2.eAtb_Level)
        on_levelup_modify_freshers_item(bo2.player, eCurLevel, false)
      end
    end
  end
  if item_id == 2002 then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_GainQuestItem, ui_handson_teach.cQuestTeachType_Add)
    g_quest_item_gain = true
  end
end
function test_complate_item_mclick()
  if g_quest_item_gain == true then
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_MiddleMouseClick)
  end
end
function test_complate_item_monitor(vis)
  on_vis_freshers_item_notifies(vis)
  if vis == true and g_quest_item_gain == true then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_MiddleMouseClick, ui_handson_teach.cQuestTeachType_Add)
  end
end
function test_complate_equip_item(item_id)
end
function test_complate_im(vis)
  if vis ~= false then
    if g_hide_windows_data[bo2.ePlayerFlagInt16_HideFriends].flag ~= false then
      ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HideFriends)
      g_hide_windows_data[bo2.ePlayerFlagInt16_HideFriends].flag = false
      g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOnAddFriend].flag = true
      ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOnAddFriend, ui_handson_teach.cQuestTeachType_Add)
    elseif g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOnAddFriend].flag ~= false then
      g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOnAddFriend].flag = false
      g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOnAddFriendResult].flag = true
      ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOnAddFriendResult, ui_handson_teach.cQuestTeachType_Add)
    end
  end
end
function test_complate_im_find(vis)
  if vis == false and g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOnAddFriendResult].flag == true then
    g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOnAddFriendResult].flag = false
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOnAddFriendResult)
  end
end
function test_complate_npc_view_list()
  ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOnNpcSearchList)
end
function test_complate_npc_list()
  ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HideNpcSearchList)
end
function test_complate_advertise(vis)
  if vis ~= false then
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HidePersonals)
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOnFindPersonals, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOnFindPersonals)
  end
end
function test_complate_convene()
  ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HideConvene)
end
function test_complate_guild(vis)
  if vis ~= false then
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HideGuid)
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOnSearchGuild, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOnSearchGuild)
  end
end
function test_complate_match(vis)
  if vis ~= false then
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HideArema)
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOnSignUpMatch, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOnSignUpMatch)
    test_complate_arena(false)
  end
end
function runf_test_complate_ctrl_teach()
  test_complate_ctrl_teach(true)
end
function on_test_complate_ctrl_teach(vis)
  ui_zdteach.on_show_ctrl_pic(vis)
  g_active_ctrl_move_teach = vis
end
function test_complate_ctrl_teach(vis)
  if g_active_ctrl_move_teach == true or ui_handson_teach.pic_ctrl_teach.visible == true then
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_FastMove)
    on_test_complate_ctrl_teach(vis)
  end
end
function test_complate_scn_teach(bFinish)
  local scn = bo2.scn
  if sys.check(scn) ~= true then
    return
  end
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return
  end
  local scn_id = scn.excel.id
  if cCheckScnExcelId == nil or cCheckScnExcelId[scn_id] == nil then
    return
  end
  local check_flag = cCheckScnExcelId[scn_id]
  local iFlag = obj:get_flag_int16(check_flag)
  if bFinish ~= true then
    if iFlag == 0 or iFlag == 16 then
      ui_handson_teach.on_teach_quest(check_flag, ui_handson_teach.cQuestTeachType_Add)
      ui_quest.ui_tracing.set_disable_fader(true)
    end
  elseif iFlag == 16 then
    ui_handson_teach.on_finish_teach_quest(check_flag)
    ui_quest.ui_tracing.set_disable_fader(false)
  end
end
function test_complate_hide_cloned_battle()
  ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HideClonedBattle, ui_handson_teach.cQuestTeachType_Add)
end
function test_complate_finish_cloned_battle()
  ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HideClonedBattle)
end
function test_complate_areaquest_teach(bFinish, data)
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return
  end
  local check_flag = bo2.ePlayerFlagInt16_HandsOn_Areaquest_Info
  local iFlag = obj:get_flag_int16(check_flag)
  if bFinish ~= true then
    if iFlag == 0 or iFlag == 16 then
      local inArea = data:has(packet.key.areaquest_inArea)
      if inArea == false then
        ui_handson_teach.on_teach_quest(check_flag, ui_handson_teach.cQuestTeachType_Add)
        ui_quest.ui_tracing.set_disable_fader(true)
      else
        ui_handson_teach.on_finish_teach_quest(check_flag)
        ui_quest.ui_tracing.set_disable_fader(false)
      end
    end
  elseif iFlag == 16 then
    ui_handson_teach.on_finish_teach_quest(check_flag)
    ui_quest.ui_tracing.set_disable_fader(false)
  end
end
function test_complate_manual_levelup_finish()
  ui_handson_teach.on_finish_teach_quest(ui_handson_teach.handson_teach_manual_levelup)
end
function test_complate_anger_skill_quest(flag)
  if flag == true then
    ui_handson_teach.on_teach_quest(ui_handson_teach.handson_teach_skill_quest_id, ui_handson_teach.cQuestTeachType_Add)
  else
  end
end
function test_complate_skill_choose()
  ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_Skill_Choose, ui_handson_teach.cQuestTeachType_Add)
end
function test_complate_skill_quest_forTudun()
  ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_Skill_SkillTudun, ui_handson_teach.cQuestTeachType_CompleteQuest)
end
function test_complate_skill_choose_qita()
  ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_Skill_Qita, ui_handson_teach.cQuestTeachType_CompleteQuest)
end
function test_complate_skill_tudun(flag)
  if flag == true then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_Skill_Tudun, ui_handson_teach.cQuestTeachType_CompleteQuest)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_Skill_Tudun)
  end
end
function test_complate_anger_level_up(flag)
  if flag == true then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_Anger_LevelUp, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_Anger_LevelUp)
  end
end
function test_complate_xinfacangku_monitor(bActive)
  if bActive ~= false then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Pause_Train, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Pause_Train)
  end
end
function test_complate_xinfacangku_continue_monitor(bActive)
  if bActive ~= false then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Continue_Train, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Continue_Train)
  end
end
function test_complate_match_statistic_teammate_delation(bActive)
  if bActive ~= false then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_3V3_Teammate_Delation, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_3V3_Teammate_Delation)
  end
end
function test_complate_trace_to_questui(bActive)
  if bActive ~= false then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_Trace_To_Quest, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_Trace_To_Quest)
  end
end
function test_complate_slotenhance_open_personal(bActive)
  if bActive ~= false then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_Personal, ui_handson_teach.cQuestTeachType_Add)
  end
end
function test_complate_slotenhance_open_slotview(bActive)
  if bActive ~= false then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotView, ui_handson_teach.cQuestTeachType_Add)
  end
end
function test_complate_slotenhance_open_sloten(bActive)
  if bActive ~= false then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotEn, ui_handson_teach.cQuestTeachType_Add)
  end
end
function test_complate_slotenhance_click_enhance(bActive)
  if bActive ~= false then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Click_Enhance, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Click_Enhance)
  end
end
function test_complate_equipidentify_open_ui(bActive)
  if bActive ~= false then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Open_UI, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Open_UI)
  end
end
function test_complate_equipidentify_action1(bActive)
  if bActive ~= false then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action1, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action1)
  end
end
function test_complate_equipidentify_action2(bActive)
  if bActive ~= false then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action2, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action2)
  end
end
function test_complate_trace_quest(flag)
  if flag == true then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_Trace_Quest, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_Trace_Quest)
  end
end
function test_complate_xinfamaster_showui(bActive)
  if bActive ~= false then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_XinfaMasterShowUI, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_XinfaMasterShowUI)
  end
end
function test_complate_foodmeter_highlight(bActive)
  if bActive ~= false then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_FoodMeterHighlight, ui_handson_teach.cQuestTeachType_Add)
  else
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_FoodMeterHighlight)
  end
end
function test_complate_reputation_shop(vis)
  local on_time = function()
    local obj = bo2.player
    if sys.check(obj) == true then
      local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_ReputationShop_PeronalButton)
      if flag_value == 16 then
        local btn = ui_widget.ui_tab.get_button(ui_personal.ui_repute.w_main, "camp")
        if sys.check(btn) and btn.press == true then
          ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_ReputationShop_PeronalButton)
          ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_ReputationShop_ShopButton, ui_handson_teach.cQuestTeachType_Add)
        else
          ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_ReputationShop_ReputationButton, ui_handson_teach.cQuestTeachType_Add)
        end
      end
    end
  end
  if vis then
    bo2.AddTimeEvent(1, on_time)
  end
end
function test_complate_camp_reputation_shop(vis)
  if vis then
    local obj = bo2.player
    if sys.check(obj) == true then
      local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_ReputationShop_ReputationButton)
      if flag_value == 16 then
        ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_ReputationShop_ShopButton, ui_handson_teach.cQuestTeachType_Add)
      end
    end
  end
end
function test_complate_click_reputation_shop()
  ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_ReputationShop_ShopButton)
end
function test_complate_on_finish_quest(quest_id)
  if quest_id == 2041 then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_JumpSkill_Qbar, ui_handson_teach.cQuestTeachType_Add)
  elseif quest_id == 2042 then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_JumpSkill_Qbar2, ui_handson_teach.cQuestTeachType_Add)
  end
end
function test_complate_keyboard(vis, val)
  on_theme_visible(g_theme[29], val, vis)
end
function test_complate_deliver(vis)
  if vis then
    local in_quest = in_select_career_quest()
    if in_quest == true then
      on_theme_visible(g_theme[27], 1200, true)
    else
      local tab = {}
      tab[10] = {ms = 122, t = 101}
      for i, v in pairs(tab) do
        local ms = hs_get_quest_ms(10)
        if ms ~= nil and ms == v.ms then
          on_theme_visible(g_theme[27], v.t, true)
        end
      end
    end
  else
    on_theme_visible(g_theme[27], 1200, false)
  end
end
function test_complate_on_skill_visible(vis)
  if vis then
    local check_flag = {}
    table.insert(check_flag, bo2.ePlayerFlagInt16_HandsOn_JumpSkill_Qbar)
    table.insert(check_flag, bo2.ePlayerFlagInt16_HandsOn_JumpSkill_Qbar2)
    local obj = bo2.player
    if sys.check(obj) == true then
      for i, v in pairs(check_flag) do
        local flag_value = obj:get_flag_int16(v)
        if flag_value == 16 then
          ui_handson_teach.on_teach_quest(v + 1, ui_handson_teach.cQuestTeachType_Add)
        end
      end
    end
  else
    local check_flag = {}
    table.insert(check_flag, bo2.ePlayerFlagInt16_HandsOn_JumpSkill_NewSkill)
    table.insert(check_flag, bo2.ePlayerFlagInt16_HandsOn_JumpSkill_NewSkill2)
    local obj = bo2.player
    if sys.check(obj) == true then
      for i, v in pairs(check_flag) do
        local flag_value = obj:get_flag_int16(v)
        if flag_value == 16 then
          ui_handson_teach.on_finish_teach_quest(v)
        end
      end
    end
  end
end
function test_complate_on_skill_qita_visible(vis)
  local check_flag = {}
  if vis then
    table.insert(check_flag, bo2.ePlayerFlagInt16_HandsOn_JumpSkill_Other)
    table.insert(check_flag, bo2.ePlayerFlagInt16_HandsOn_JumpSkill_Other2)
    local obj = bo2.player
    if sys.check(obj) == true then
      for i, v in pairs(check_flag) do
        local flag_value = obj:get_flag_int16(v)
        if flag_value == 16 then
          ui_handson_teach.on_teach_quest(v + 1, ui_handson_teach.cQuestTeachType_Add)
        end
      end
    end
  end
end
local g_active_dead_show = false
function test_complate_dead_show(vis)
  local eLevel = ui.safe_get_atb(bo2.eAtb_Level)
  if eLevel >= 10 then
    if g_active_dead_show == true then
      g_active_dead_show = false
      on_finish_handson_teach(bo2.player, bo2.ePlayerFlagInt16_HandsOn_UseItem)
    end
    return
  end
  if vis ~= true then
    g_active_dead_show = false
    on_finish_handson_teach(bo2.player, bo2.ePlayerFlagInt16_HandsOn_UseItem)
  elseif g_active_dead_show == false then
    g_active_dead_show = true
    local iExcelId = bo2.ePlayerFlagInt16_HandsOn_UseItem - bo2.ePlayerFlagInt16_HandsOn
    local pExcel = bo2.gv_handson_teach:find(iExcelId)
    if pExcel == nil then
      return
    end
    PopupHandsOnTips(bo2.ePlayerFlagInt16_HandsOn_UseItem, pExcel)
  end
end
function test_complete_convene_recruit()
  ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_ConveneRecruit)
end
function test_complete_convene_teleport()
  ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_ConveneTeleport)
end
function run0()
  test_complate_dead_show(true)
end
local g_ride_item, g_ride_sight_item
local g_ride_notify = true
function enable_ride_help(idx, item, vis)
  on_theme_visible(g_theme[26], idx, vis)
  if sys.check(item) then
    bo2.RemoveTimeEvent(item)
  end
  if vis then
    local function on_disable()
      on_theme_visible(g_theme[26], idx, false)
    end
    item = bo2.AddTimeEvent(125, on_disable)
    return item
  else
    return nil
  end
end
function enable_ride(vis)
  g_ride_item = enable_ride_help(122, g_ride_item, vis)
end
local g_ride_skill, g_enable_ride_skill
function enable_ride_sight(vis)
  if g_ride_notify ~= true then
    return
  end
  g_ride_sight_item = enable_ride_help(123, g_ride_sight_item, vis)
  if sys.check(g_ride_skill) then
    bo2.RemoveTimeEvent(g_ride_skill)
  end
  if sys.check(g_enable_ride_skill) then
    bo2.RemoveTimeEvent(g_enable_ride_skill)
  end
  local sig = "ui_handson_teach.on_packet_ride_teaching"
  if vis then
    local function on_time_add_enable()
      local text = ui.get_text(L("qbar|ride_skill"))
      note_insert(text, L("FFFFFFFF"), g_ride_skill_id, g_ride_time, g_ride_skill_id)
      local function on_packet_ride_teaching(cmd, data)
        local cmn_type = data:get(packet.key.cmn_type).v_int
        if cmn_type ~= 3 then
          return
        end
        note_insert(text, L("FF00FF00"), g_ride_skill_id, ride_dis_time, g_ride_skill_id)
        ui_packet.game_recv_signal_remove(packet.eSTC_ScnObj_Skill, sig)
        g_ride_notify = false
      end
      local function on_time()
        ui_packet.game_recv_signal_remove(packet.eSTC_ScnObj_Skill, sig)
      end
      g_ride_skill = bo2.AddTimeEvent(125, on_time)
      ui_packet.game_recv_signal_insert(packet.eSTC_ScnObj_Skill, on_packet_ride_teaching, sig)
    end
    g_enable_ride_skill = bo2.AddTimeEvent(125, on_time_add_enable)
  else
    note_insert(L(""), L("FF00FF00"), g_ride_skill_id, 0, g_ride_skill_id)
    ui_packet.game_recv_signal_remove(packet.eSTC_ScnObj_Skill, sig)
  end
end
function test_complate_arena(vis)
  local quest_data = g_quest_data[145]
  if quest_data == nil then
    return
  end
  if vis then
    on_popup_windows(quest_data, nil, nil, quest_data.handson_teach.make_text_id)
  else
    on_finish_windows(quest_data)
  end
  if sys.check(quest_data.handson_teach.flicker) then
    quest_data.handson_teach.flicker.visible = vis
  end
end
