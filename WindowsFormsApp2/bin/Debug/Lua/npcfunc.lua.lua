g_npcfunc_wnd = {}
g_cur_funcid = bo2.eNpcFunc_Null
function on_init(ctrl)
  g_npcfunc_wnd[bo2.eNpcFunc_EnforceEquipV20150115] = {
    w_main = ui_npcfunc.ui_enforce20150115.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_EnforceEquipV201418] = {
    w_main = ui_npcfunc.ui_enforce201418.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_RefineStack] = {
    w_main = ui_npcfunc.ui_refine.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_MakeEquip] = {
    w_main = ui_npcfunc.ui_make.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_MakeAvatar] = {
    w_main = ui_npcfunc.ui_make_avatar.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ComposeGem2] = {
    w_main = ui_npcfunc.ui_gemcompose2.w_main2
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ComposeGem5] = {
    w_main = ui_npcfunc.ui_gemcompose5.w_main5
  }
  g_npcfunc_wnd[bo2.eNpcFunc_IdentifyRide] = {
    w_main = ui_npcfunc.ui_identify_ride.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_FaceLifting] = {
    w_main = ui_npcfunc.ui_face_lifting.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_BodyLifting] = {
    w_main = ui_npcfunc.ui_body_lifting.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PolishGem] = {
    w_main = ui_npcfunc.ui_gempolish.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PunchEquip] = {
    w_main = ui_npcfunc.ui_gempunch.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_InlayGem] = {
    w_main = ui_npcfunc.ui_geminlay.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PullOutGem] = {
    w_main = ui_npcfunc.ui_gempullout.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PetOpenHole] = {
    w_main = nil,
    open = on_open_hole_open,
    close = on_pet_common_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PetReOpenHole] = {
    w_main = nil,
    open = on_reopen_hole_open,
    close = on_pet_common_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PetLearnSkill] = {
    w_main = nil,
    open = on_learn_skill_open,
    close = on_pet_common_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PetToBaby] = {
    w_main = nil,
    open = on_to_baby_open,
    close = on_pet_common_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PetLearnGenius] = {
    w_main = nil,
    open = on_learn_genius_open,
    close = on_pet_common_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_CombineEquip] = {
    w_main = ui_npcfunc.ui_combine.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_DExpView] = {
    w_main = ui_dexp.w_dexpView_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_XinfaLearn] = {
    w_main = ui_skill.w_skill
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ZhuzhiXinfaLearn] = {
    w_main = ui_skill_learn.w_skill,
    open = ui_skill_learn.on_skill_learn_open
  }
  g_npcfunc_wnd[bo2.eNpcFunc_FuzhiXinfaLearn] = {
    w_main = ui_skill_learn.w_skill,
    open = ui_skill_learn.on_skill_learn_open
  }
  g_npcfunc_wnd[bo2.eNpcFunc_LiShi] = {
    w_main = ui_skill_learn.w_skill,
    open = ui_skill_learn.on_skill_learn_open
  }
  g_npcfunc_wnd[bo2.eNpcFunc_CiKe] = {
    w_main = ui_skill_learn.w_skill,
    open = ui_skill_learn.on_skill_learn_open
  }
  g_npcfunc_wnd[bo2.eNpcFunc_JianKe] = {
    w_main = ui_skill_learn.w_skill,
    open = ui_skill_learn.on_skill_learn_open
  }
  g_npcfunc_wnd[bo2.eNpcFunc_SanXian] = {
    w_main = ui_skill_learn.w_skill,
    open = ui_skill_learn.on_skill_learn_open
  }
  g_npcfunc_wnd[bo2.eNpcFunc_QiangKe] = {
    w_main = ui_skill_learn.w_skill,
    open = ui_skill_learn.on_skill_learn_open
  }
  g_npcfunc_wnd[bo2.eNpcFunc_GongShou] = {
    w_main = ui_skill_learn.w_skill,
    open = ui_skill_learn.on_skill_learn_open
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PetRefine] = {
    w_main = nil,
    open = on_pet_refine_open,
    close = on_pet_common_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ApplyGuild] = {w_main = nil, open = on_guild_search_open}
  g_npcfunc_wnd[bo2.eNpcFunc_Bank] = {
    w_main = nil,
    open = on_bank,
    close = on_bank_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_NewBank] = {
    w_main = nil,
    open = on_newbank,
    close = on_newbank_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PetBreed] = {
    w_main = nil,
    open = on_pet_breed_open,
    close = on_pet_common_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PetBreedSearch] = {
    w_main = nil,
    open = on_pet_breed_search,
    close = on_pet_breed_search_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_Marry] = {
    w_main = nil,
    open = on_marry,
    close = on_marry_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_Sworn] = {
    w_main = nil,
    open = on_sworn,
    close = on_sworn_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_BuildGuild] = {
    w_main = nil,
    open = on_build_guild,
    close = on_build_guild_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_DismissGuild] = {
    w_main = nil,
    open = on_dismiss_guild,
    close = on_dismiss_guild_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_CancelGuild] = {
    w_main = nil,
    open = on_cancel_guild,
    close = on_cancel_guild_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_BuyBuild] = {
    w_main = nil,
    open = on_Buy_Build,
    close = on_Buy_Build_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_GuildDelate] = {
    w_main = nil,
    open = on_guild_delete,
    close = on_guild_delete_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_GuildSalary] = {
    w_main = ui_guild_mod.ui_salary.w_salary_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_GuildSalaryLevel] = {
    w_main = ui_guild_mod.ui_salary_level.w_salary_level_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_GuildBuild] = {
    w_main = ui_guild_mod.ui_build.w_guild_build
  }
  g_npcfunc_wnd[bo2.eNpcFunc_GuildDepot] = {
    w_main = ui_guild_mod.ui_guild_depot.w_depot_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_GuildDeliver] = {
    w_main = ui_guild_mod.ui_guild_yizhan.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_GuildMakeItem] = {
    w_main = ui_npcfunc.ui_makeitem.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_GuildJiaoTou] = {
    w_main = ui_guild_mod.ui_guild_jiaotou.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_GuildAdorn] = {
    w_main = ui_guild_mod.ui_guild_adorn.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ChgGuildScn] = {w_main = nil, open = on_chgguildscn}
  g_npcfunc_wnd[bo2.eNpcFunc_GuildDonateMoney] = {
    w_main = nil,
    open = ui_guild_mod.ui_guild_depot.on_donatemoney_click
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PetClearAbility] = {
    w_main = nil,
    open = on_clear_ability_open,
    close = on_pet_common_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_MasterAndAppren] = {
    w_main = nil,
    open = on_master_and_appren,
    close = on_master_and_appren_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PetSkillLevelUp] = {
    w_main = nil,
    open = on_skill_levelup_open,
    close = on_pet_common_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_PetToToy] = {
    w_main = nil,
    open = on_to_toy_open,
    close = on_pet_common_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_BuildMall] = {
    w_main = ui_mall.ui_build.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ManageMall] = {
    w_main = ui_mall.ui_manage.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_BrowseMall] = {
    w_main = ui_mall.ui_browse.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ConsultRemoveSworn] = {
    w_main = nil,
    open = on_consult_remove_sworn,
    close = on_consult_remove_sworn_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_EnforceRemoveSworn] = {
    w_main = nil,
    open = on_enforce_remove_sworn,
    close = on_enforce_remove_sworn_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ConsultDivorce] = {
    w_main = nil,
    open = on_consult_divorce,
    close = on_consult_divorce_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_EnforceDivorce] = {
    w_main = nil,
    open = on_enforce_divorce,
    close = on_enforce_divorce_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_RemoveAppren] = {
    w_main = nil,
    open = on_remove_appren,
    close = on_remove_appren_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_RemoveMaster] = {
    w_main = nil,
    open = on_remove_master,
    close = on_remove_master_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_Plus] = {
    w_main = ui_npcfunc.ui_plus.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_AssRefine] = {
    w_main = ui_npcfunc.ui_assrefine.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_AssReAdd] = {
    w_main = ui_npcfunc.ui_assreadd.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_AssRegeneration] = {
    w_main = ui_npcfunc.ui_regeneration.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_AssConcise] = {
    w_main = ui_npcfunc.ui_concise.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ReMakeSecond] = {
    w_main = ui_npcfunc.ui_remakesecond.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_BarbershopFacial] = {
    w_main = ui_barbershop.ui_facial.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_BarbershopHaircut] = {
    w_main = ui_barbershop.ui_haircut.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_EquipImprint] = {
    w_main = ui_npcfunc.ui_imprint.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ClearImprint] = {
    w_main = ui_npcfunc.ui_impclear.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_BarbershopHairColor] = {
    w_main = ui_barbershop.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_BarbershopFace] = {
    w_main = ui_barbershop.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_BarbershopNothing] = {w_main = nil}
  g_npcfunc_wnd[bo2.eNpcFunc_MasterLevelUp] = {
    w_main = nil,
    open = on_open_masterlevel_up,
    close = on_close_masterlevel_up
  }
  g_npcfunc_wnd[bo2.eNpcFunc_BattleApply] = {w_main = nil, open = on_battle_click_apply}
  g_npcfunc_wnd[bo2.eNpcFunc_BattleTeamApply] = {w_main = nil, open = on_battle_click_apply_team}
  g_npcfunc_wnd[bo2.eNpcFunc_BattleCancel] = {w_main = nil, open = on_battle_click_cancel}
  g_npcfunc_wnd[bo2.eNpcFunc_MakeJade] = {
    w_main = ui_npcfunc.ui_jade.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_MatConvert] = {
    w_main = ui_npcfunc.ui_mat_convert.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_EnchantUpgrades] = {
    w_main = ui_npcfunc.ui_enchant_upgrades.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_MakeSpecialEquip] = {
    w_main = ui_npcfunc.ui_make_special_equip.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_StuffUpgrade] = {
    w_main = ui_npcfunc.ui_stuff_upgrade.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ManufEquip] = {
    w_main = ui_npcfunc.ui_manuf_equip.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ManufEquipGeneral] = {
    w_main = ui_npcfunc.ui_manuf_equip.w_main,
    open = ui_npcfunc.ui_manuf_equip.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ManufEquipShogun] = {
    w_main = ui_npcfunc.ui_manuf_equip.w_main,
    open = ui_npcfunc.ui_manuf_equip.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ManufEquipAuxiliary] = {
    w_main = ui_npcfunc.ui_manuf_equip.w_main,
    open = ui_npcfunc.ui_manuf_equip.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ManufEquipDuhu] = {
    w_main = ui_npcfunc.ui_manuf_equip.w_main,
    open = ui_npcfunc.ui_manuf_equip.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ManufEquipBawang] = {
    w_main = ui_npcfunc.ui_manuf_equip.w_main,
    open = ui_npcfunc.ui_manuf_equip.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ManufEquipDuhuDown] = {
    w_main = ui_npcfunc.ui_manuf_equip_down.w_main,
    open = ui_npcfunc.ui_manuf_equip_down.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ChgPrfShenBingSwap] = {
    w_main = ui_npcfunc.ui_chgprf_shenbingswap.w_main,
    open = ui_npcfunc.ui_chgprf_shenbingswap.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ChgPrfEquipSwap] = {
    w_main = ui_npcfunc.ui_chgprf_equipswap.w_main,
    open = ui_npcfunc.ui_chgprf_equipswap.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ChgPrfGemSwap] = {
    w_main = ui_npcfunc.ui_chgprf_gemswap.w_main,
    open = ui_npcfunc.ui_chgprf_gemswap.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_LivingSkillCaoyao] = {
    w_main = nil,
    open = ui_skill.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_LivingSkillCaikuang] = {
    w_main = nil,
    open = ui_skill.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_LivingSkillShoulie] = {
    w_main = nil,
    open = ui_skill.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_LivingSkillFangshu] = {
    w_main = nil,
    open = ui_skill.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_LivingSkillPengren] = {
    w_main = nil,
    open = ui_skill.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_LivingSkillJianding] = {
    w_main = nil,
    open = ui_skill.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_LivingSkillCaoyaoLevelup] = {
    w_main = nil,
    open = ui_skill.on_npcfunc_open_window_levelup
  }
  g_npcfunc_wnd[bo2.eNpcFunc_LivingSkillCaikuangLevelup] = {
    w_main = nil,
    open = ui_skill.on_npcfunc_open_window_levelup
  }
  g_npcfunc_wnd[bo2.eNpcFunc_LivingSkillShoulieLevelup] = {
    w_main = nil,
    open = ui_skill.on_npcfunc_open_window_levelup
  }
  g_npcfunc_wnd[bo2.eNpcFunc_LivingSkillFangshuLevelup] = {
    w_main = nil,
    open = ui_skill.on_npcfunc_open_window_levelup
  }
  g_npcfunc_wnd[bo2.eNpcFunc_LivingSkillPengrenLevelup] = {
    w_main = nil,
    open = ui_skill.on_npcfunc_open_window_levelup
  }
  g_npcfunc_wnd[bo2.eNpcFunc_LivingSkillJiandingLevelup] = {
    w_main = nil,
    open = ui_skill.on_npcfunc_open_window_levelup
  }
  g_npcfunc_wnd[bo2.eNpcFunc_TianziEquipUpgrade] = {
    w_main = ui_npcfunc.ui_tianzi_equip_upgrade.w_main,
    open = ui_npcfunc.ui_tianzi_equip_upgrade.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ChangeProfession] = {
    w_main = ui_npcfunc.ui_change_profession.w_main,
    open = ui_npcfunc.ui_change_profession.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_EquipUpgrade] = {
    w_main = ui_npcfunc.ui_equip_upgrade.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_EquipStarUpgrade] = {
    w_main = ui_npcfunc.ui_equip_star_upgrade.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_EquipTraitUpgrade] = {
    w_main = ui_npcfunc.ui_equip_trait_upgrade.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_Battle02Apply] = {w_main = nil, open = on_battle02_click_apply}
  g_npcfunc_wnd[bo2.eNpcFunc_Battle02TeamApply] = {w_main = nil, open = on_battle02_click_apply_team}
  g_npcfunc_wnd[bo2.eNpcFunc_Battle02Cancel] = {w_main = nil, open = on_battle02_click_cancel}
  g_npcfunc_wnd[bo2.eNpcFunc_Battle03Apply] = {w_main = nil, open = on_battle03_click_apply}
  g_npcfunc_wnd[bo2.eNpcFunc_Battle03Cancel] = {w_main = nil, open = on_battle03_click_cancel}
  g_npcfunc_wnd[bo2.eNpcFunc_AccBank] = {
    w_main = nil,
    open = on_accbank,
    close = on_accbank_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_JoinNpcGuild] = {w_main = nil, open = on_join_npc_guild}
  g_npcfunc_wnd[bo2.eNpcFunc_XinfaEquip] = {w_main = nil, open = on_equip_xinfa_equip}
  g_npcfunc_wnd[bo2.eNpcFunc_ReMake] = {
    w_main = ui_npcfunc.ui_remake.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_SellHorse] = {
    w_main = ui_npcfunc.ui_sellhorse.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_ExchangeAction] = {
    w_main = ui_action.w_exchange
  }
  g_npcfunc_wnd[bo2.eNpcFunc_Errantry2Exp] = {
    w_main = ui_errantry.w_exchange
  }
  g_npcfunc_wnd[bo2.eNpcFunc_DoBarbershopFacial] = {w_main = nil, open = on_DoBarbershopFacial}
  g_npcfunc_wnd[bo2.eNpcFunc_DoBarbershopHaircut] = {w_main = nil, open = on_DoBarbershopHaircut}
  g_npcfunc_wnd[bo2.eNpcFunc_DoImprint] = {w_main = nil, open = on_DoImprint}
  g_npcfunc_wnd[bo2.eNpcFunc_BodyLiftingFacial] = {w_main = nil, open = on_DoBodyLifting}
  g_npcfunc_wnd[bo2.eNpcFunc_CrossLineScore] = {
    w_main = nil,
    open = on_cross_line_open,
    close = on_cross_line_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_CrossLineYesterdayScore] = {
    w_main = nil,
    open = on_cross_line_yesterday_open,
    close = on_cross_line_close
  }
  g_npcfunc_wnd[bo2.eNpcFunc_MapDeliver] = {
    w_main = ui_npcfunc.ui_map_deliver.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_RidePetWeaponAddExp] = {
    w_main = ui_npcfunc.ui_ridepet_exp.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_RidePetWeaponAddSlot] = {
    w_main = ui_npcfunc.ui_ridepet_unseal.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_RidePetWeaponAddSkillExp] = {
    w_main = ui_npcfunc.ui_ridepet_skill_exp.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_RidePetWeaponAddSkill] = {
    w_main = ui_npcfunc.ui_ridepet_skill_add.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_StallScan] = {
    w_main = nil,
    open = on_open_stall_scan,
    close = on_close_stall_scan
  }
  g_npcfunc_wnd[bo2.eNpcFunc_Refine2014516] = {
    w_main = ui_npcfunc.ui_refine_2014516.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_TianwuUpgrade] = {
    w_main = ui_npcfunc.ui_tianwu_upgrade.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_GemFuse] = {
    w_main = ui_npcfunc.ui_gemfuse.w_main
  }
  g_npcfunc_wnd[bo2.eNpcFunc_EquipExchangeSaveSomeAtb] = {
    w_main = ui_npcfunc.ui_equip_exchange_save_some_atb.w_main,
    open = ui_npcfunc.ui_equip_exchange_save_some_atb.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_TianwuSwap] = {
    w_main = ui_npcfunc.ui_tianwu_swap.w_main,
    open = ui_npcfunc.ui_tianwu_swap.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_2ndWeaponSwapGaoDing] = {
    w_main = ui_npcfunc.ui_tianwu_swap.w_main,
    open = ui_npcfunc.ui_tianwu_swap.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_Cuiqu] = {
    w_main = ui_npcfunc.ui_cuiqu.w_main,
    open = ui_npcfunc.ui_cuiqu.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_Diaowen] = {
    w_main = ui_npcfunc.ui_diaowen.w_main,
    open = ui_npcfunc.ui_diaowen.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_SmeltGem] = {
    w_main = ui_npcfunc.ui_smelt_gem.w_main,
    open = ui_npcfunc.ui_smelt_gem.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_JingpoGuanzhu] = {
    w_main = ui_npcfunc.ui_jingpo_guanzhu.w_main,
    open = ui_npcfunc.ui_jingpo_guanzhu.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_TitleSwap] = {
    w_main = ui_npcfunc.ui_title_swap.w_main,
    open = ui_npcfunc.ui_title_swap.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_JingpoGuanzhu] = {
    w_main = ui_npcfunc.ui_jingpo_guanzhu.w_main,
    open = ui_npcfunc.ui_jingpo_guanzhu.on_npcfunc_open_window
  }
  g_npcfunc_wnd[bo2.eNpcFunc_SecondWeaponUpgrade] = {
    w_main = ui_npcfunc.ui_second_upgrade.w_main
  }
  for i = bo2.eNpcFunc_Deliver1, bo2.eNpcFunc_DeliverMAX do
    g_npcfunc_wnd[i] = {
      w_main = ui_npcfunc.ui_deliver.w_main,
      open = on_deliver_open
    }
  end
  for i = bo2.eNpcFunc_AskTheWay1, bo2.eNpcFunc_AskTheWayMax do
    g_npcfunc_wnd[i] = {
      w_main = nil,
      open = function()
        ui_askway.show_wnd(i)
      end,
      close = function()
        ui_askway.close_wnd()
      end
    }
  end
  for i = bo2.eNpcFunc_LineUp1, bo2.eNpcFunc_LineUpMax do
    g_npcfunc_wnd[i] = {
      w_main = nil,
      open = function()
        lineup_request_add(i)
      end,
      close = nil
    }
  end
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis then
    local w = ui.find_control("$frame:item")
    if w ~= nil then
      w.visible = vis
    end
  else
    if w.var:get("server_close_talk").v_int == 1 then
      return
    end
    local d = sys.variant()
    d:set("kind", bo2.eTalkSel_Null)
    d:set("id", 1)
    bo2.send_wrap(packet.eSTC_Fake_talk_sel, d)
  end
end
function openwindow(cmd, data)
  local funcid = data:get(packet.key.talk_excel_id).v_int
  local w = g_npcfunc_wnd[funcid]
  if w == nil then
    return
  end
  if w.w_main ~= nil then
    w.w_main.visible = true
  end
  if w.open then
    w.open(funcid)
  end
  g_cur_funcid = funcid
  ui.log("openwindow %s %s", funcid, w.w_main)
end
function closewindow(cmd, data)
  local funcid = data:get(packet.key.talk_excel_id).v_int
  local w = g_npcfunc_wnd[funcid]
  if w == nil then
    return
  end
  if w.w_main ~= nil then
    w.w_main.var:set("server_close_talk", 1)
    w.w_main.visible = false
    w.w_main.var:set("server_close_talk", 0)
  end
  if w.close then
    w.close()
  end
  g_cur_funcid = bo2.eNpcFunc_Null
end
function set_card(card, onlyid, lock)
  local info = ui.item_of_only_id(onlyid)
  if info == nil then
    return
  end
  if (bo2.eItemBox_BagBeg > info.box or info.box > bo2.eItemBox_Quest) and (bo2.eItemBox_RidePetBegin > info.box or info.box > bo2.eItemBox_RidePetEnd) and bo2.eItemArray_InSlot ~= info.box then
    return
  end
  clear_card(card)
  card.only_id = onlyid
  if lock == nil or lock == true then
    info:insert_lock(bo2.eItemLock_UI)
  end
end
function on_card_drop(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  ui.clean_drop()
  if not ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    return
  end
  set_card(card, data:get("only_id"))
end
function on_card_drop_nolock(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  ui.clean_drop()
  if not ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    return
  end
  set_card(card, data:get("only_id"), false)
end
function clear_card(card)
  local info = card.info
  if info ~= nil then
    info:remove_lock(bo2.eItemLock_UI)
  end
  card.only_id = 0
end
function on_card_mouse(card, msg, pos, wheel)
  local icon = card.icon
  if icon == nil then
    return
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_drag then
    ui.set_cursor_icon(icon.uri)
    local function on_drop_hook(w, msg, pos, data)
      if msg == ui.mouse_drop_clean then
        clear_card(card)
      end
    end
    local data = sys.variant()
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  elseif msg == ui.mouse_rbutton_click then
    clear_card(card)
  end
end
function set_succ_rate(ctrl, prob)
  if prob == 0 then
    ctrl.color = ui.make_color("FF0000")
    ctrl.text = ui.get_text("npcfunc|succ_rate")
    return
  end
  prob = prob / 10000
  if prob > 66 then
    ctrl.color = ui.make_color("00FF00")
  elseif prob > 33 then
    ctrl.color = ui.make_color("FFFF00")
  end
  ctrl.text = sys.format("%d%%", prob)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_npcfunc.packet_handle"
reg(packet.eSTC_UI_OpenNpcFunc, openwindow, sig)
reg(packet.eSTC_UI_CloseNpcFunc, closewindow, sig)
function on_guild_search_open()
  ui_guild_mod.ui_guild_search.set_win_open(0)
end
function on_bank()
  ui_stall.owner.set_visible(false)
  ui_deal.set_visible(false)
  ui_bank.show_bank()
end
function on_bank_close()
  ui_bank.close_bank()
end
function on_newbank()
  ui_stall.owner.set_visible(false)
  ui_deal.set_visible(false)
  ui_newbank.show_bank()
end
function on_newbank_close()
  ui_newbank.close_bank()
end
function on_pet_breed_open()
  ui_pet.ui_pet_breed.on_pet_breed()
end
function on_pet_breed_search()
  ui_pet.ui_pet_search.on_pet_breed_search()
end
function on_pet_breed_search_close()
  ui_pet.ui_pet_search.set_visible(false)
end
function on_to_toy_open()
  ui_pet.ui_pet_common.set_visible(true, bo2.ePet_Func_ToToy)
end
function on_learn_genius_open()
  ui_pet.ui_pet_common.set_visible(true, bo2.ePet_Func_Train)
end
function on_to_baby_open()
  ui_pet.ui_pet_common.set_visible(true, bo2.ePet_Func_ToBaby)
end
function on_pet_refine_open()
  ui_pet.ui_pet_common.set_visible(true, bo2.ePet_Func_Refine)
end
function on_clear_ability_open()
  ui_pet.ui_pet_common.set_visible(true, bo2.ePet_Func_ClearAbility)
end
function on_open_hole_open()
  ui_pet.ui_pet_common.set_visible(true, bo2.ePet_Func_OpenHole)
end
function on_reopen_hole_open()
  ui_pet.ui_pet_common.set_visible(true, bo2.ePet_Func_ReOpenHole)
end
function on_learn_skill_open()
  ui_pet.ui_pet_common.set_visible(true, bo2.ePet_Func_LearnSkill)
end
function on_skill_levelup_open()
  ui_pet.ui_pet_common.set_visible(true, bo2.ePet_Func_SkillLevelUp)
end
function on_pet_common_close()
  ui_pet.ui_pet_common.set_visible(false)
  ui_pet.ui_pet_genius.set_visible(false)
end
function on_marry()
  local d = sys.variant()
  d:set(packet.key.sociality_marrystep, 1)
  d:set(packet.key.sociality_npcfuncid, bo2.eNpcFunc_Marry)
  bo2.send_variant(packet.eCTS_UI_ChgRelation, d)
end
function on_marry_close()
end
function on_sworn()
  ui_sociality.ui_sworn.request_sworn()
end
function on_sworn_close()
  ui_sociality.ui_sworn.cancel_sworn()
end
function on_cancel_guild()
  if bo2.is_in_guild() ~= sys.wstring(0) then
    ui_guild_mod.ui_manage.on_guild_cancel_dismiss(nil)
  else
    ui_tool.note_insert(ui.get_text("org|noguild"), "FF0000")
  end
end
function on_cancel_guild_close()
end
function on_Buy_Build()
  if bo2.is_in_guild() ~= sys.wstring(0) then
    ui_guild_mod.ui_manage.on_guild_BuyBuild(nil)
  else
    ui_tool.note_insert(ui.get_text("org|noguild"), "FF0000")
  end
end
function on_Buy_Build_close()
end
function on_join_npc_guild_confirm(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local camp_id = bo2.player:get_atb(bo2.eAtb_Camp)
    local guild_id = camp_id - 1
    local excel = bo2.gv_npc_guild:find(guild_id)
    local v = sys.variant()
    v:set(packet.key.org_name, excel.name)
    bo2.send_variant(packet.eCTS_NpcGuild_ApplyM, v)
  end
end
function on_join_npc_guild()
  local excel = bo2.gv_npc_guild:find(1)
  local msg = {
    callback = on_join_npc_guild_confirm,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    text = ui_widget.merge_mtf({
      npc_guild_name = excel.show_name
    }, ui.get_text("npcfunc|confirm_join_guild"))
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_guild_delete()
  if bo2.is_in_guild() ~= sys.wstring(0) then
    ui_guild_mod.ui_guild_delate.w_delate_main.visible = true
  else
    ui_tool.note_insert(ui.get_text("org|noguild"), "FF0000")
  end
end
function on_guild_delete_close()
end
function on_build_guild()
  ui_guild_mod.ui_manage.on_build_guild(nil)
end
function on_build_guild_close()
end
function on_dismiss_guild()
  if bo2.is_in_guild() ~= sys.wstring(0) then
    ui_guild_mod.ui_manage.on_guild_dismiss(nil)
  else
    ui_tool.note_insert(ui.get_text("org|noguild"), "FF0000")
  end
end
function on_dismiss_guild_close()
end
function on_guild_salary()
  if bo2.is_in_guild() ~= sys.wstring(0) then
    ui_guild_mod.ui_salary.w_salary_main.visible = true
  else
    ui_tool.note_insert(ui.get_text("org|noguild"), "FF0000")
  end
end
function on_guild_salary_close()
end
function on_salary_level()
  if bo2.is_in_guild() ~= sys.wstring(0) then
    ui_guild_mod.ui_salary_level.w_salary_level_main.visible = true
  else
    ui_tool.note_insert(ui.get_text("org|noguild"), "FF0000")
  end
end
function on_salary_level_close()
end
function on_guild_build()
  if bo2.is_in_guild() ~= sys.wstring(0) then
    ui_guild_mod.ui_build.w_guild_build.visible = true
  else
    ui_tool.note_insert(ui.get_text("org|noguild"), "FF0000")
  end
end
function on_guild_build_close()
end
function on_guild_depot()
  if bo2.is_in_guild() ~= sys.wstring(0) then
    ui_guild_mod.ui_guild_depot.w_depot_main.visible = true
  else
    ui_tool.note_insert(ui.get_text("org|noguild"), "FF0000")
  end
end
function on_guild_depot_close()
end
function on_guild_yizhan()
  if bo2.is_in_guild() ~= sys.wstring(0) then
    ui_guild_mod.ui_guild_yizhan.w_main.visible = true
  else
    ui_tool.note_insert(ui.get_text("org|noguild"), "FF0000")
  end
end
function on_guild_yizhan_close()
  ui_guild_mod.ui_guild_yizhan.w_main = false
end
function on_guild_makeitem()
  if bo2.is_in_guild() ~= sys.wstring(0) then
    ui_npcfunc.ui_makeitem.w_main.visible = true
  else
    ui_tool.note_insert(ui.get_text("org|noguild"), "FF0000")
  end
end
function on_guild_makeitem_close()
end
function on_guild_jiaotou()
  if bo2.is_in_guild() ~= sys.wstring(0) then
    ui_guild_mod.ui_guild_jiaotou.w_main.visible = true
  else
    ui_tool.note_insert(ui.get_text("org|noguild"), "FF0000")
  end
end
function on_guild_jiaotou_close()
end
function on_chgguildscn()
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_ChgGuildScn, v)
end
function on_master_and_appren()
  local d = sys.variant()
  d:set(packet.key.sociality_mastep, 1)
  d:set(packet.key.sociality_npcfuncid, bo2.eNpcFunc_MasterAndAppren)
  bo2.send_variant(packet.eCTS_UI_ChgRelation, d)
end
function on_master_and_appren_close()
end
function on_consult_remove_sworn()
  local d = sys.variant()
  d:set(packet.key.sociality_removestep, 1)
  d:set(packet.key.sociality_twrelationtype, bo2.TWR_Type_Sworn)
  d:set(packet.key.sociality_npcfuncid, bo2.eNpcFunc_ConsultRemoveSworn)
  bo2.send_variant(packet.eCTS_UI_ChgRelation, d)
end
function on_consult_remove_sworn_close()
end
function on_enforce_remove_sworn()
  local d = sys.variant()
  d:set(packet.key.sociality_removestep, 1)
  d:set(packet.key.sociality_twrelationtype, bo2.TWR_Type_Sworn)
  d:set(packet.key.sociality_npcfuncid, bo2.eNpcFunc_EnforceRemoveSworn)
  bo2.send_variant(packet.eCTS_UI_ChgRelation, d)
end
function on_enforce_remove_sworn_close()
  ui_sociality.ui_remove_relation.on_enforce_remove_close()
end
function on_consult_divorce()
  local d = sys.variant()
  d:set(packet.key.sociality_removestep, 1)
  d:set(packet.key.sociality_twrelationtype, bo2.TWR_Type_Couple)
  d:set(packet.key.sociality_npcfuncid, bo2.eNpcFunc_ConsultDivorce)
  bo2.send_variant(packet.eCTS_UI_ChgRelation, d)
end
function on_consult_divorce_close()
end
function on_enforce_divorce()
  local d = sys.variant()
  d:set(packet.key.sociality_removestep, 1)
  d:set(packet.key.sociality_twrelationtype, bo2.TWR_Type_Couple)
  d:set(packet.key.sociality_npcfuncid, bo2.eNpcFunc_EnforceDivorce)
  bo2.send_variant(packet.eCTS_UI_ChgRelation, d)
end
function on_enforce_divorce_close()
  ui_sociality.ui_remove_relation.on_enforce_remove_close()
end
function on_remove_appren()
  local d = sys.variant()
  d:set(packet.key.sociality_removestep, 1)
  d:set(packet.key.sociality_twrelationtype, bo2.TWR_Type_MasterAndApp)
  d:set(packet.key.sociality_npcfuncid, bo2.eNpcFunc_RemoveAppren)
  bo2.send_variant(packet.eCTS_UI_ChgRelation, d)
end
function on_remove_appren_close()
  ui_sociality.ui_remove_relation.on_enforce_remove_close()
end
function on_remove_master()
  local d = sys.variant()
  d:set(packet.key.sociality_removestep, 1)
  d:set(packet.key.sociality_twrelationtype, bo2.TWR_Type_MasterAndApp)
  d:set(packet.key.sociality_npcfuncid, bo2.eNpcFunc_RemoveMaster)
  bo2.send_variant(packet.eCTS_UI_ChgRelation, d)
end
function on_remove_master_close()
  ui_sociality.ui_remove_relation.on_enforce_remove_close()
end
function on_deliver_open(id)
  ui_deliver.set_id(id)
end
local on_init_barbershop_list = function(show_name, hide_name1, hide_name2)
end
function on_open_barbershop_hair()
  on_init_barbershop_list("hair")
end
function on_open_barbershop_hair_color()
  on_init_barbershop_list("hair_color")
end
function on_open_barbershop_face()
  on_init_barbershop_list("face")
end
function on_open_masterlevel_up()
  local main = ui_sociality.ui_masterandappren.w_masterlevel_buy
  ui_sociality.ui_masterandappren.refresh_masterlevel_up()
  main.visible = true
end
function on_close_masterlevel_up()
  local main = ui_sociality.ui_masterandappren.w_masterlevel_buy
  main.visible = false
end
function lineup_request_add(lineup_id)
  local v = sys.variant()
  v:set(packet.key.lineup_type_id, lineup_id)
  bo2.send_variant(packet.eCTS_Lineup_RequestAdd, v)
end
function on_battle_click_apply(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 0)
  v:set(packet.key.battle_type, bo2.eBattleType_A)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function on_battle_click_apply_team(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 1)
  v:set(packet.key.battle_type, bo2.eBattleType_A)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function on_battle_click_cancel(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 1)
  v:set(packet.key.battle_type, bo2.eBattleType_A)
  bo2.send_variant(packet.eCTS_UI_Battle_Cancel, v)
end
function on_battle02_click_apply(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 0)
  v:set(packet.key.battle_type, bo2.eBattleType_B)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function on_battle02_click_apply_team(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 1)
  v:set(packet.key.battle_type, bo2.eBattleType_B)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function on_battle02_click_cancel(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 1)
  v:set(packet.key.battle_type, bo2.eBattleType_B)
  bo2.send_variant(packet.eCTS_UI_Battle_Cancel, v)
end
function on_battle03_click_apply(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 0)
  v:set(packet.key.battle_type, bo2.eBattleType_C)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function on_battle03_click_cancel(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 1)
  v:set(packet.key.battle_type, bo2.eBattleType_C)
  bo2.send_variant(packet.eCTS_UI_Battle_Cancel, v)
end
function on_accbank()
  ui_account_bank.ui_account_bank_safe.on_click_show_accbank()
end
function on_accbank_close()
  ui_account_bank.close_bank()
end
function on_equip_xinfa_equip()
  ui_skill.on_cangku_window_visible(ui_skill.w_skill)
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item(stk, excel, card.info)
  local stk_use
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
local BARBERSHOP_TYPE_FACIAL = 1
local BARBERSHOP_TYPE_HAIRCUT = 2
local BARBERSHOP_TYPE_BODY_DIY = 4
local DoBarbershopConfirm = function(msg)
  if msg.result == 1 then
    local v = sys.variant()
    v:set(packet.key.talk_excel_id, msg.talk_id)
    if msg.barbertype then
      v:set(packet.key.cmn_type, msg.barbertype)
    end
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  end
end
function on_cross_line_close()
  ui_cross_line.w_main_score.visible = false
end
function on_close_stall_scan()
  plus_stall_viewer.w_main.visible = false
end
function on_open_stall_scan()
  plus_stall_viewer.on_open()
end
function on_cross_line_yesterday_open()
  ui_cross_line.runf_yesterday()
end
function on_cross_line_open()
  ui_cross_line._runf()
end
function on_DoBarbershopFacial()
  local quan = ui.item_of_excel_id(58210, bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
  if quan == nil then
    local msg = {
      btn_cancel = false,
      text = ui_widget.merge_mtf({item = 58210, mark_id = 1028}, sys.format(ui.get_text("barbershop|no_quan")))
    }
    ui_widget.ui_msg_box.show_common(msg)
    return
  end
  local excel_id1 = quan:get_data_32(bo2.eItemInt32_BarberShopProp1)
  local excel_id2 = quan:get_data_32(bo2.eItemInt32_BarberShopProp2)
  local excel1 = bo2.gv_barber_shop:find(excel_id1)
  local excel2 = bo2.gv_barber_shop:find(excel_id2)
  local money = 0
  local mtf_text = {}
  if excel1 then
    money = excel1.cast_money
    if excel1.type == 2 then
      local face_change_itemId = bo2.gv_define:find(999).value.v_int
      local face_change_itemCount = bo2.gv_define:find(1000).value.v_int
      if face_change_itemCount > ui.item_get_count(face_change_itemId, true) then
        face_change_itemId = excel1.cast_item_id
        face_change_itemCount = excel1.cast_item_cnt
      end
      mtf_text.item1 = face_change_itemId
      mtf_text.item1_num = L("x") .. face_change_itemCount
    else
      mtf_text.item1 = excel1.cast_item_id
      mtf_text.item1_num = L("x") .. excel1.cast_item_cnt
    end
  end
  if excel2 then
    mtf_text.item2 = excel2.cast_item_id
    mtf_text.item2_num = L("x") .. excel2.cast_item_cnt
    money = money + excel2.cast_money
  end
  local eye_value = quan:get_data_32(bo2.eItemInt32_BarberShopFace_Eye)
  local nose_value = quan:get_data_32(bo2.eItemInt32_BarberShopFace_Nose)
  local mouth_value = quan:get_data_32(bo2.eItemInt32_BarberShopFace_Mouth)
  if eye_value ~= 0 or nose_value ~= 0 or mouth_value ~= 0 then
    local face_diy_money = bo2.gv_define:find(793).value.v_int
    local face_diy_itemId = bo2.gv_define:find(997).value.v_int
    local face_diy_itemCount = bo2.gv_define:find(998).value.v_int
    if face_diy_itemCount > ui.item_get_count(face_diy_itemId, true) then
      face_diy_itemId = bo2.gv_define:find(794).value.v_int
      face_diy_itemCount = bo2.gv_define:find(795).value.v_int
    end
    money = money + face_diy_money
    mtf_text.item3 = face_diy_itemId
  end
  if money > 0 then
    mtf_text.money = money
  end
  local msg = {
    callback = DoBarbershopConfirm,
    text = ui_widget.merge_mtf(mtf_text, sys.format(ui.get_text("barbershop|do_change"))),
    talk_id = bo2.eNpcFunc_DoBarbershopFacial,
    barbertype = BARBERSHOP_TYPE_FACIAL
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_DoBarbershopHaircut()
  local quan = ui.item_of_excel_id(58211, bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
  if quan == nil then
    local msg = {
      btn_cancel = false,
      text = ui_widget.merge_mtf({item = 58211, mark_id = 1029}, sys.format(ui.get_text("barbershop|no_quan")))
    }
    ui_widget.ui_msg_box.show_common(msg)
    return
  end
  local excel_id1 = quan:get_data_32(bo2.eItemInt32_BarberShopProp1)
  local excel_id2 = quan:get_data_32(bo2.eItemInt32_BarberShopProp2)
  local excel1 = bo2.gv_barber_shop:find(excel_id1)
  local excel2 = bo2.gv_barber_shop:find(excel_id2)
  local mtf_text = {}
  if excel1 then
    mtf_text.item1 = excel1.cast_item_id
    mtf_text.item1_num = L("x") .. excel1.cast_item_cnt
    mtf_text.money = excel1.cast_money
  end
  if excel2 then
    mtf_text.item2 = excel2.cast_item_id
    mtf_text.item2_num = L("x") .. excel2.cast_item_cnt
    if excel1 then
      mtf_text.money = excel1.cast_money + excel2.cast_money
    else
      mtf_text.money = excel2.cast_money
    end
  end
  mtf_text.item3 = 58211
  local msg = {
    callback = DoBarbershopConfirm,
    text = ui_widget.merge_mtf(mtf_text, sys.format(ui.get_text("barbershop|do_change"))),
    talk_id = bo2.eNpcFunc_DoBarbershopHaircut,
    barbertype = BARBERSHOP_TYPE_HAIRCUT
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_DoImprint()
  local quan = ui.item_of_excel_id(58212, bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
  if quan == nil then
    local msg = {
      btn_cancel = false,
      text = ui_widget.merge_mtf({item = 58212, mark_id = 1030}, sys.format(ui.get_text("barbershop|no_quan")))
    }
    ui_widget.ui_msg_box.show_common(msg)
    return
  end
  local excel_id1 = quan:get_data_32(bo2.eItemInt32_BarberShopProp1)
  local excel1 = bo2.gv_equip_item:find(excel_id1)
  if excel_id1 == nil then
    return
  end
  local mtf_text = {}
  if excel1 then
    mtf_text.item1 = excel_id1
    mtf_text.money = excel1.use_par[0]
  end
  mtf_text.item3 = 58212
  local cfm_text
  local old_info = ui.item_of_coord(bo2.eItemArray_InSlot, bo2.eItemSlot_Avatar_Imprint)
  if old_info ~= nil then
    mtf_text.old_item = sys.format("<fi:%s>", old_info.code)
    cfm_text = ui_widget.merge_mtf(mtf_text, sys.format(ui.get_text("barbershop|do_imprint")))
  else
    cfm_text = ui_widget.merge_mtf(mtf_text, sys.format(ui.get_text("barbershop|do_change")))
  end
  local msg = {
    callback = DoBarbershopConfirm,
    text = cfm_text,
    talk_id = bo2.eNpcFunc_DoImprint
  }
  ui_widget.ui_msg_box.show_common(msg)
end
local DoBodyLiftingConfirm = function(msg)
  if msg.result == 1 then
    local v = sys.variant()
    if msg.barbertype then
      v:set(packet.key.cmn_type, msg.barbertype)
    end
    v:set(packet.key.talk_excel_id, msg.talk_id)
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  end
end
function on_DoBodyLifting()
  local resultItemId = bo2.gv_define:find(403).value.v_int
  local quan = ui.item_of_excel_id(resultItemId, bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
  if quan == nil then
    local msg = {
      btn_cancel = false,
      text = ui_widget.merge_mtf({item = resultItemId, mark_id = 1028}, sys.format(ui.get_text("barbershop|no_quan")))
    }
    ui_widget.ui_msg_box.show_common(msg)
    return
  end
  local money = bo2.gv_define:find(399).value.v_int
  local money_type = bo2.gv_define:find(400).value.v_int
  local itemId = bo2.gv_define:find(404).value.v_int
  local itemCount = bo2.gv_define:find(405).value.v_int
  if itemCount > ui.item_get_count(itemId, true) then
    itemId = bo2.gv_define:find(401).value.v_int
    itemCount = bo2.gv_define:find(402).value.v_int
  end
  local mtf_text = {}
  mtf_text.item1 = itemId
  mtf_text.item1_num = L("x") .. itemCount
  mtf_text.money = money
  local msg_value = ui.get_text("barbershop|do_change")
  if money_type ~= 0 then
    msg_value = ui.get_text("barbershop|do_change_unbound")
  end
  local msg = {
    callback = DoBodyLiftingConfirm,
    text = ui_widget.merge_mtf(mtf_text, sys.format(msg_value)),
    talk_id = bo2.eNpcFunc_BodyLiftingFacial,
    barbertype = BARBERSHOP_TYPE_BODY_DIY
  }
  ui_widget.ui_msg_box.show_common(msg)
end
