cHandson_Teach_Scn_Id = 143
local cHandson_Teach_Max_Level = 60
cPopupTypeNpcTips = 1
cPopupTypeStillTips = 2
cPopupTypeWindows = 3
cPopupTypeOnMouseNpcTips = 4
cPopupTypeOpenWindows = 5
cQuestTeachType_Add = 0
cQuestTeachType_Complete = 1
cQuestTeachType_CompleteQuest = 2
cQuestTeachType_ClickCompleteQuest = 3
g_handsonhelp_data = {}
g_handsonhelp_quest = {}
g_handsonhelp_finish = {}
g_handsonhelp_tmp_data = {}
g_theme = {}
g_handson_quest_mb = nil
function reset_teaching_quest_talk()
  g_teaching_quest_talk = {valid = false, index = -1}
end
function reset_teaching_quest_talk_page()
  g_teaching_quest_talk_page = {valid = false, index = -1}
end
function reset_teaching_quest_new_skill()
  g_teaching_temp_new_skill = {valid = false, index = -1}
end
function reset_teaching_quest_move_skill()
  g_teaching_quest_move_skill = {valid = false, index = -1}
end
function reset_teaching_quest_new_item()
  g_teaching_temp_new_item = {valid = false, index = -1}
end
function reset_teaching_item_tip()
  g_teaching_item_tip = {valid = false, index = -1}
end
function reset_ride_idex()
  g_teaching_ride_idex = {valid = false, index = -1}
end
function reset_deliver_tab()
  g_teaching_deliver_tab = {valid = false, index = -1}
end
function reset_key_monitor_tab()
  g_teaching_key_monitor_tab = {valid = false, index = -1}
end
function reset_teaching_quest_milestone_notify_npc()
  g_teaching_milestone_notify_npc = {valid = false, index = -1}
end
function reset_teaching_quest_milestone_notify_still()
  g_teaching_milestone_notify_still = {valid = false, index = -1}
end
function reset_teaching_skill_use()
  g_teaching_skill_use = {valid = false, index = -1}
end
function reset_teaching_award_item_select()
  g_teaching_award_item_select = {valid = false, index = -1}
end
function reset_teaching_qlink_skill()
  g_teaching_qlink_skill = {valid = false, index = -1}
end
function reset_teaching_personal_search()
  g_teaching_personal_search = {valid = false, index = -1}
end
function reset_item_box_search()
  g_item_box_search = {valid = false, index = -1}
end
function reset_teaching_milestone_confirm()
  g_teaching_milestone_confirm = {valid = false, index = -1}
end
function reset_teaching_complete_confirm()
  g_teaching_complete_confirm = {valid = false, index = -1}
end
function reset_teaching_sysshortcut()
  g_teaching_temp_sysshortcut = {valid = false, index = -1}
end
function on_init_mb_quest_help()
  g_quest_data = {}
  g_quest_trace_data = {}
  g_update_milestone_data = {}
  g_teaching_quest_trace = {}
  g_quest_talk_data = {}
  reset_teaching_quest_talk()
  g_quest_scn = {}
  g_item_box = {}
  reset_item_box_search()
  g_quest_talk_page = {}
  reset_teaching_quest_talk_page()
  g_temp_new_skill = {}
  reset_teaching_quest_new_skill()
  g_temp_auto_move_new_skill = {}
  reset_teaching_quest_move_skill()
  g_leave_scene = {}
  g_milestone_notify_npc = {}
  g_milestone_notify_still = {}
  reset_teaching_quest_milestone_notify_still()
  g_scn_notify_npc = {}
  reset_teaching_quest_milestone_notify_npc()
  g_skill_use = {}
  reset_teaching_skill_use()
  g_award_item_select = {}
  reset_teaching_award_item_select()
  g_qlink_skill = {}
  reset_teaching_qlink_skill()
  g_personal_search = {}
  reset_teaching_personal_search()
  g_temp_sysshortcut = {}
  reset_teaching_sysshortcut()
  g_target_protrait = {}
  g_script_talk_data = {}
  g_notify_text = {}
  g_quest_milestone_confirm = {}
  reset_teaching_milestone_confirm()
  g_quest_complete_confirm = {}
  reset_teaching_complete_confirm()
  g_temp_new_item = {}
  reset_teaching_quest_new_item()
  g_item_tip = {}
  reset_teaching_item_tip()
  g_ride_index = {}
  reset_ride_idex()
  g_deliver_tab = {}
  reset_deliver_tab()
  g_key_monitor_tab = {}
  reset_key_monitor_tab()
end
on_init_mb_quest_help()
function on_init_once()
  if g_handson_quest_mb == nil then
    g_handson_quest_mb = bo2.gv_handson_teach_quest
  end
end
on_init_once()
local iActiveHandsOn = 16
local iFinishHandsOn = 17
handson_teach_manual_levelup = 143
handson_teach_skill_quest_id = 2032
g_ei_quest_id = 2037
g_ei_mstone_id = 40040
g_ei_item_id = 50051
handson_teach_active_on_mouse_npc = 0
handson_teach_active_on_mouse_npc1 = nil
handson_teach_active_on_mouse_npc_handle = 0
function on_begin_move_teach()
  local iExcelId = bo2.ePlayerFlagInt16_HandsOn_WASDMove - bo2.ePlayerFlagInt16_HandsOn
  local pExcel = bo2.gv_handson_teach:find(iExcelId)
  if pExcel == nil then
    return
  end
  PopupHandsOnTips(bo2.ePlayerFlagInt16_HandsOn_WASDMove, pExcel)
end
function on_init_once_data()
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_NpcTalkPopo] = {
    popup_type = cPopupTypeNpcTips,
    scn_excel_id = 143,
    npc_excel_id = 68008,
    popup_function = on_begin_move_teach
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_BossHeadPopo] = {
    popup_type = cPopupTypeNpcTips,
    scn_excel_id = 143,
    npc_excel_id = 68002
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_SelNpcToAttack] = {
    popup_type = cPopupTypeOnMouseNpcTips,
    scn_excel_id = 143,
    npc_excel_id = 68025,
    npc_excel_id2 = 68026
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Roll] = {
    popup_type = cPopupTypeNpcTips,
    scn_excel_id = 143,
    npc_excel_id = 68049
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_AddUmpireTalkPopo] = {
    popup_type = cPopupTypeNpcTips,
    scn_excel_id = 113,
    npc_excel_id = 61701
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_AddUmpireTalkPopo] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_AddUmpireTalkPopo,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_TalkToStudyJumpNpc] = {
    popup_type = cPopupTypeNpcTips,
    scn_excel_id = 101,
    npc_excel_id = 5360
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_Group] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_Group,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_MiddleMouseClick] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_MiddleMouseClick,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_ReputationShop_ShopButton] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_ReputationShop_ShopButton,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_ReputationShop_PeronalButton] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_ReputationShop_ShopButton,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_JumpSkill_NewSkill] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_JumpSkill_NewSkill,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_JumpSkill_NewSkill2] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_JumpSkill_NewSkill2,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
end
on_init_once_data()
function on_init_once_quest()
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Group] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Group][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_Group,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_MiddleMouseClick] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_MiddleMouseClick][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_MiddleMouseClick,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_GainQuestItem] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_GainQuestItem][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_GainQuestItem,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  for i = bo2.ePlayerFlagInt16_HandsOn_ReputationShop_Qbar, bo2.ePlayerFlagInt16_HandsOn_ReputationShop_ShopButton do
    g_handsonhelp_quest[i] = {}
    g_handsonhelp_quest[i][cQuestTeachType_Add] = {
      active_idx = i,
      active_case = bo2.ActiveHandsOnTeach_CaseQuest
    }
  end
  for i = bo2.ePlayerFlagInt16_HandsOn_JumpSkill_Qbar, bo2.ePlayerFlagInt16_HandsOn_JumpSkill_NewSkill2 do
    g_handsonhelp_quest[i] = {}
    g_handsonhelp_quest[i][cQuestTeachType_Add] = {
      active_idx = i,
      active_case = bo2.ActiveHandsOnTeach_CaseQuest
    }
  end
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_YouXuanValley_DungeonInfo] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_YouXuanValley_DungeonInfo][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_YouXuanValley_DungeonInfo,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_MonsterSealPlace_DungeonInfo] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_MonsterSealPlace_DungeonInfo][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_MonsterSealPlace_DungeonInfo,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Areaquest_Info] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Areaquest_Info][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_Areaquest_Info,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[handson_teach_manual_levelup] = {}
  g_handsonhelp_quest[handson_teach_manual_levelup][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_Manual_LevelUp,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[handson_teach_skill_quest_id] = {}
  g_handsonhelp_quest[handson_teach_skill_quest_id][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_Skill,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Skill_Choose] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Skill_Choose][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_Skill_Choose,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Anger_LevelUp] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Anger_LevelUp][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_Anger_LevelUp,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Pause_Train] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Pause_Train][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Pause_Train,
    active_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Continue_Train] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Continue_Train][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Continue_Train,
    active_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_3V3_Teammate_Delation] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_3V3_Teammate_Delation][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_3V3_Teammate_Delation,
    active_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Trace_To_Quest] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Trace_To_Quest][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_Trace_To_Quest,
    active_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_Personal] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_Personal][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_Personal,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotView] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotView][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotView,
    active_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotEn] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotEn][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotEn,
    active_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Click_Enhance] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Click_Enhance][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Click_Enhance,
    active_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Skill_SkillTudun] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Skill_SkillTudun][cQuestTeachType_CompleteQuest] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_Skill_SkillTudun,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Skill_Qita] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Skill_Qita][cQuestTeachType_CompleteQuest] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_Skill_Qita,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Skill_Tudun] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Skill_Tudun][cQuestTeachType_CompleteQuest] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_Skill_Tudun,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Open_UI] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Open_UI][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Open_UI,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action1] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action1][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action1,
    active_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action2] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action2][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action2,
    active_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Trace_Quest] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_Trace_Quest][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_Trace_Quest,
    active_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_XinfaMasterShowUI] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_XinfaMasterShowUI][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_XinfaMasterShowUI,
    active_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_FoodMeterHighlight] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_FoodMeterHighlight][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_FoodMeterHighlight,
    active_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  for i = bo2.ePlayerFlagInt16_HandsOn_ConveneShowup, bo2.ePlayerFlagInt16_HandsOn_ConveneTeleport do
    g_handsonhelp_quest[i] = {}
    g_handsonhelp_quest[i][cQuestTeachType_Add] = {
      active_idx = i,
      active_case = bo2.ActiveHandsOnTeach_CaseQuest
    }
  end
end
on_init_once_quest()
function on_init_finish_event()
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_YouXuanValley_DungeonInfo] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_YouXuanValley_DungeonInfo,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_MonsterSealPlace_DungeonInfo] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_MonsterSealPlace_DungeonInfo,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_Areaquest_Info] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_Areaquest_Info,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[handson_teach_manual_levelup] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_Manual_LevelUp,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_Anger_LevelUp] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_Anger_LevelUp,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Pause_Train] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Pause_Train,
    finish_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Continue_Train] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Continue_Train,
    finish_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_3V3_Teammate_Delation] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_3V3_Teammate_Delation,
    finish_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_Trace_To_Quest] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_Trace_To_Quest,
    finish_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_Personal] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_Personal,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotView] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotView,
    finish_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotEn] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotEn,
    finish_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Click_Enhance] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Click_Enhance,
    finish_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_Skill_Tudun] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_Skill_Tudun,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Open_UI] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Open_UI,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action1] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action1,
    finish_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action2] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action2,
    finish_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_Trace_Quest] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_Trace_Quest,
    finish_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_XinfaMasterShowUI] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_XinfaMasterShowUI,
    finish_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_FoodMeterHighlight] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_FoodMeterHighlight,
    finish_case = bo2.ActiveHandsOnTeach_CaseOpenWindows
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_ConveneRecruit] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_ConveneRecruit,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_ConveneTeleport] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_ConveneTeleport,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
end
on_init_finish_event()
function runf_PopupHandsOnTips(v_idx)
  local idx = v_idx.v_int
  local iExcelId = idx - bo2.ePlayerFlagInt16_HandsOn
  local pExcel = bo2.gv_handson_teach:find(iExcelId)
  if pExcel == nil then
    return
  end
  PopupHandsOnTips(idx, pExcel)
end
function on_timer_set_npc_handson_tips()
  timer_set_npc_handson_tips.suspended = true
  local scn = bo2.scn
  if sys.check(scn) ~= true or scn.excel.id ~= cHandson_Teach_Scn_Id then
    return
  end
end
function PopupHandsOnTips(idx, pExcel, bInterval)
  local tips = g_handsonhelp_data[idx]
  if tips == nil or pExcel == nil then
    return
  end
  if tips.popup_type == cPopupTypeNpcTips then
    local scn = bo2.scn
    if sys.check(scn) ~= true or scn.excel.id ~= tips.scn_excel_id then
      return
    end
    if tips.popup_function ~= nil then
      tips.popup_function(true)
    end
    local _handson_teach_text = sys.format(L("<handson:%d,4>"), pExcel.id)
    local iHandle = scn:SetNpcHandsonTips(tips.npc_excel_id, _handson_teach_text)
    if iHandle ~= 0 then
      g_handsonhelp_tmp_data[idx] = {handle = iHandle, excel = pExcel}
    elseif iHandle == 0 and tips._time ~= nil and bInterval == nil then
      timer_set_npc_handson_tips.period = tips._time
      timer_set_npc_handson_tips.suspended = false
    end
    return
  end
  if tips.popup_type == cPopupTypeStillTips then
    local scn = bo2.scn
    if sys.check(scn) ~= true or scn.excel.id ~= tips.scn_excel_id then
      return
    end
    local _handson_teach_text = sys.format(L("<handson:%d,4>"), pExcel.id)
    local iHandle = scn:SetStillHandsonTips(tips.still_excel_id, _handson_teach_text)
    if iHandle ~= 0 then
      g_handsonhelp_tmp_data[idx] = {handle = iHandle, excel = pExcel}
    end
    return
  end
  if tips.popup_type == cPopupTypeWindows then
    if sys.check(tips.handson_teach) ~= false and sys.check(tips.handson_teach.fn) ~= false then
      tips.handson_teach.fn(idx, tips.handson_teach.fn_param)
    end
    if sys.check(tips.handson_teach) and sys.check(tips.handson_teach.popup_function) then
      tips.handson_teach.popup_function(true)
    end
    on_popup_windows(tips, pExcel)
    return
  end
  if tips.popup_type == cPopupTypeOnMouseNpcTips then
    local scn = bo2.scn
    if sys.check(scn) ~= true or scn.excel.id ~= tips.scn_excel_id then
      return
    end
    handson_teach_active_on_mouse_npc = tips.npc_excel_id
    handson_teach_active_on_mouse_npc1 = tips.npc_excel_id2
    return
  end
  if tips.popup_type == cPopupTypeOpenWindows and sys.check(tips.popup_function) then
    tips.popup_function(true)
  end
end
function on_finish_handson_teach(obj, idx)
  obj:remove_on_flagmsg(bo2.eFlagType_Int16, idx, "ui_handson_teach.on_self_flag_monitor")
  local tips = g_handsonhelp_data[idx]
  if tips == nil then
    return
  end
  if tips.popup_type == cPopupTypeNpcTips then
    local scn = bo2.scn
    if sys.check(scn) ~= true or scn.excel.id ~= tips.scn_excel_id then
      return
    end
    local tmp_tips = g_handsonhelp_tmp_data[idx]
    if tmp_tips == nil or tmp_tips.handle == nil then
      return
    end
    scn:UnValidNpcHandsonTips(tmp_tips.handle)
    return
  end
  if tips.popup_type == cPopupTypeStillTips then
    local scn = bo2.scn
    if sys.check(scn) ~= true or scn.excel.id ~= tips.scn_excel_id then
      return
    end
    local tmp_tips = g_handsonhelp_tmp_data[idx]
    if tmp_tips == nil or tmp_tips.handle == nil then
      return
    end
    scn:UnValidStillHandsonTips(tmp_tips.handle)
    return
  end
  if tips.popup_type == cPopupTypeWindows then
    on_finish_windows(tips)
    return
  end
  if tips.popup_type == cPopupTypeOnMouseNpcTips then
    local scn = bo2.scn
    if sys.check(scn) ~= true or scn.excel.id ~= tips.scn_excel_id then
      return
    end
    if handson_teach_active_on_mouse_npc_handle ~= 0 then
      handson_teach_active_on_mouse_npc_handle = 0
      scn:UnValidNpcHandsonTips(handson_teach_active_on_mouse_npc_handle)
    end
    handson_teach_active_on_mouse_npc = 0
    return
  end
  if tips.popup_type == cPopupTypeOpenWindows and sys.check(tips.popup_function) then
    tips.popup_function(false)
  end
end
function on_self_flag_monitor(obj, ft, idx)
  if idx <= bo2.ePlayerFlagInt16_HandsOn or idx >= bo2.ePlayerFlagInt16_HandsOnMax then
    return
  end
  local flag_value = obj:get_flag_int16(idx)
  if flag_value ~= iActiveHandsOn then
    if flag_value == iFinishHandsOn then
      on_finish_handson_teach(obj, idx)
    end
    return
  end
  local iExcelId = idx - bo2.ePlayerFlagInt16_HandsOn
  local pExcel = bo2.gv_handson_teach:find(iExcelId)
  if pExcel == nil then
    return
  end
  PopupHandsOnTips(idx, pExcel)
end
function init_flag(obj)
  local nTeachSize = bo2.gv_handson_teach.size
  local bOpenTutorial = false
  local idx = 0
  for i = 0, nTeachSize do
    local pTeachData = bo2.gv_handson_teach:get(i)
    if pTeachData ~= nil then
      local iFlagIdx = pTeachData.id + bo2.ePlayerFlagInt16_HandsOn
      local iFlag = obj:get_flag_int16(iFlagIdx)
      obj:insert_on_flagmsg(bo2.eFlagType_Int16, iFlagIdx, on_self_flag_monitor, "ui_handson_teach.on_self_flag_monitor")
      if iFlag == iActiveHandsOn and pTeachData.active_type == bo2.ActiveHandsOnTeach_CaseBorn then
        on_self_flag_monitor(obj, 0, iFlagIdx)
      end
    end
  end
end
function on_self_atb_level(obj, ft, idx)
  local eCurLevel = obj:get_atb(bo2.eAtb_Level)
  if eCurLevel ~= 1 then
    ui_handson_teach.on_levelup_vis(nil, true)
  end
  try_to_finish_hide_window(obj, eCurLevel)
  on_levelup_modify_freshers_item(obj, eCurLevel, true)
  if eCurLevel >= 30 then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_ReputationShop_Qbar, ui_handson_teach.cQuestTeachType_Add)
  end
  if eCurLevel >= 15 then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_ConveneShowup, ui_handson_teach.cQuestTeachType_Add)
  end
end
function init_atb_monitor(obj)
  local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOnCheckBagEquipment)
  if flag_value ~= 0 and g_hide_atb_monitor ~= true then
    return
  end
  local eCurLevel = obj:get_atb(bo2.eAtb_Level)
  if eCurLevel > cHandson_Teach_Max_Level then
    return
  end
  on_self_atb_level(obj, 0, 0)
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Level, on_self_atb_level, "ui_handson_teach.on_self_atb_level")
end
function on_close_all_handson_teach_pop()
  ui_handson_teach.w_handson_common.visible = false
  ui_handson_teach.w_view_handson_common.visible = false
  ui_handson_teach.w_handson_qlink.visible = false
  ui_handson_teach.w_handson_item.visible = false
  ui_handson_teach.timer_common_handson.suspended = true
  ui_handson_teach.timer_common_handson2.suspended = true
  ui_handson_teach.timer_qlink_handson.suspended = true
  ui_handson_teach.timer_item_handson.suspended = true
end
function on_self_enter()
  on_close_all_handson_teach_pop()
  on_init_popup_windows()
  on_init_beta_window()
  on_init_open_windows()
  on_init_hide_windows_define()
  on_init_hide()
  ui_handson_teach.on_init_freshers_item_windows()
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return false
  end
  init_flag(obj)
  init_hide_window(obj)
  init_atb_monitor(obj)
  ui_handson_teach.test_complate_scn_teach(false)
  ui_handson_teach.on_mb_quest_scn_in()
  ui_handson_teach.on_enter_beta()
  bo2.AddTimeEvent(25, ui_handson_teach.on_scn_npc_nofity)
end
function on_areaquest_area(cmd, data)
  ui_handson_teach.test_complate_areaquest_teach(false, data)
end
function on_self_enter_clear()
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
  else
    ui_widget.esc_stk_pop(w)
  end
end
function OnMsgActiveHandsOnTeach(iIdx, iCase)
  if iIdx == nil or iIdx <= bo2.ePlayerFlagInt16_HandsOn or iIdx >= bo2.ePlayerFlagInt16_HandsOnMax then
    return
  end
  local vSend = sys.variant()
  vSend:set(packet.key.ui_hands_on_idx, iIdx)
  vSend:set(packet.key.ui_hands_on_case, iCase)
  bo2.send_variant(packet.eCTS_UI_ActiveHandsOnTeach, vSend)
end
function OnMsgFinishHandsOnTeach(iIdx, iCase)
  if iIdx == nil or iIdx <= bo2.ePlayerFlagInt16_HandsOn or iIdx >= bo2.ePlayerFlagInt16_HandsOnMax then
    return
  end
  local vSend = sys.variant()
  vSend:set(packet.key.ui_hands_on_idx, iIdx)
  vSend:set(packet.key.ui_hands_on_case, iCase)
  bo2.send_variant(packet.eCTS_UI_FinishHandsOnTeach, vSend)
end
function on_teach_quest(iQuestId, iTeachType)
  if iTeachType == nil or iQuestId == nil then
    return
  end
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return false
  end
  if g_handsonhelp_quest[iQuestId] == nil then
    return false
  end
  local ref_quest = g_handsonhelp_quest[iQuestId][iTeachType]
  if ref_quest ~= nil and ref_quest.active_idx ~= nil then
    local idx = ref_quest.active_idx
    local iFlag = obj:get_flag_int16(idx)
    if iFlag == iActiveHandsOn or iFlag == iFinishHandsOn then
      return false
    end
    OnMsgActiveHandsOnTeach(ref_quest.active_idx, ref_quest.active_case)
  else
    ui.log(" handson::g_handsonhelp_quest ref_quest.. nil " .. iQuestId)
  end
end
function on_finish_teach_quest(event_id)
  if event_id == nil then
    return
  end
  local ref_event = g_handsonhelp_finish[event_id]
  if ref_event == nil then
    return
  end
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return false
  end
  local idx = ref_event.finish_id
  local iFlag = obj:get_flag_int16(idx)
  if iFlag == iFinishHandsOn or iFlag ~= iActiveHandsOn then
    return false
  end
  OnMsgFinishHandsOnTeach(ref_event.finish_id, ref_event.finish_case)
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter_clear, "ui_handson_teach.on_self_enter")
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_handson_teach.on_self_enter")
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_AreaQuest_Area, on_areaquest_area, "ui_handson_teach.on_areaquest_area")
