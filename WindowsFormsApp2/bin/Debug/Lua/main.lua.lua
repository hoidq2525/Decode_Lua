bo2.randsetseed(os.time())
w_top = ui_phase.w_main
local perf_stat = sys.perf_stat()
local loading_time = 0
local init_once = function()
  if rawget(_M, g_alrealy_init) ~= nil then
    return
  end
  g_alrealy_init = true
  ui_main.g_reload_windows = false
end
local c_video_replay_ui_group_pk_mode = 1
local c_video_replay_ui_group_common_mode = 2
local c_video_replay_ui_group_all_mode = 3
local c_lang_ch = L("zh_cn")
local c_lang_other = L("other")
config_windows = {
  {
    style = "activitydesc",
    uri = "$frame/activitydesc/activitydesc.xml"
  },
  {
    style = "desc_window",
    uri = "$frame/activitydesc/activitydesc.xml"
  },
  {
    style = "reciprocal",
    uri = "$frame/reciprocal/reciprocal.xml"
  },
  {
    style = "bo2_guide",
    uri = "$frame/help/bo2_guide.xml"
  },
  {
    style = "action",
    uri = "$frame/action/action.xml"
  },
  {
    style = "item",
    uri = "$frame/item/item.xml"
  },
  {
    style = "ridepet",
    uri = "$frame/ridepet/ridepet.xml"
  },
  {
    style = "ridepet_refine",
    uri = "$frame/ridepet/ridepet_refine.xml"
  },
  {
    style = "ridepet_blood_refine",
    uri = "$frame/ridepet/ridepet_blood_refine.xml"
  },
  {
    style = "ridepet_zhenfa",
    uri = "$frame/ridepet/ridepet_zhenfa.xml"
  },
  {
    style = "ridepet_view",
    uri = "$frame/ridepet/ridepet_view.xml"
  },
  {
    style = "tutorial",
    uri = "$frame/help/tutorial.xml"
  },
  {
    style = "popo",
    uri = "$frame/popo/popo.xml"
  },
  {
    style = "timer_popo",
    uri = "$frame/popo/popo.xml"
  },
  {
    style = "group",
    uri = "$frame/group/group.xml",
    video = 1,
    video_group = c_video_replay_ui_group_common_mode
  },
  {
    style = "safe",
    uri = "$frame/safe/safe.xml"
  },
  {
    style = "safe_display",
    uri = "$frame/safe/safe.xml"
  },
  {
    style = "supermarket_rmb",
    uri = "$frame/supermarket_v2/supermarket.xml"
  },
  {
    style = "dm",
    uri = "$frame/supermarket_v2/supermarket.xml",
    widget = "dynamic_animation"
  },
  {
    style = "supermarket",
    uri = "$frame/supermarket_v2/supermarket.xml"
  },
  {
    style = "privilege",
    uri = "$frame/supermarket_v2/privilege.xml"
  },
  {
    style = "discount",
    uri = "$frame/supermarket_v2/discount.xml"
  },
  {
    style = "mirror_main",
    uri = "$frame/supermarket_v2/mirror.xml"
  },
  {
    style = "fitting_room",
    uri = "$frame/item/fittingroom.xml"
  },
  {
    style = "bank",
    uri = "$frame/bank/bank.xml"
  },
  {
    style = "newbank",
    uri = "$frame/newbank/newbank.xml"
  },
  {
    style = "account_bank",
    uri = "$frame/account_bank/account_bank.xml"
  },
  {
    style = "portrait",
    uri = "$frame/portrait/portrait.xml",
    video = 1,
    video_group = c_video_replay_ui_group_common_mode
  },
  {
    style = "skill",
    uri = "$frame/skill/skill.xml"
  },
  {
    style = "item_lottery",
    uri = "$frame/item/item_lottery.xml"
  },
  {
    style = "item_model",
    uri = "$frame/item/item_model.xml"
  },
  {
    style = "item_equip_model",
    uri = "$frame/item/item_equip_model.xml"
  },
  {
    style = "item_secondweapon_exp",
    uri = "$frame/item/item_secondweapon_exp.xml"
  },
  {
    style = "item_rose",
    uri = "$frame/item/item_rose.xml"
  },
  {
    style = "item_compose",
    uri = "$frame/item/item_compose.xml"
  },
  {
    style = "item_card",
    uri = "$frame/item/item_card.xml"
  },
  {
    style = "skill_master",
    uri = "$frame/skill/skill_master.xml"
  },
  {
    style = "text_book",
    uri = "$frame/text_book/text_book.xml"
  },
  {
    style = "damage_analyze",
    uri = "$frame/damage_analyze/damage_analyze.xml"
  },
  {
    style = "main",
    uri = "$frame/personal/broken.xml"
  },
  {config = cfgwnd_qbar},
  {
    style = "personal",
    uri = "$frame/personal/personal.xml"
  },
  {
    style = "atb_monitor",
    uri = "$frame/personal/atb_monitor.xml"
  },
  {
    style = "quest",
    uri = "$frame/quest/quest.xml",
    widget = "fader",
    video_widget = "panel"
  },
  {
    style = "dead",
    uri = "$frame/dead/dead.xml"
  },
  {
    style = "main",
    uri = "$frame/deal/deal.xml"
  },
  {
    style = "main",
    uri = "$frame/editor/editor.xml"
  },
  {
    style = "map",
    uri = "$frame/map/map.xml"
  },
  {
    style = "title1",
    uri = "$frame/minimap/minimap.xml"
  },
  {
    style = "npc_list",
    uri = "$frame/minimap/minimap.xml"
  },
  {
    style = "gzs_list",
    uri = "$frame/minimap/minimap.xml"
  },
  {
    style = "find_path",
    uri = "$frame/minimap/minimap.xml"
  },
  {
    style = "minimap",
    uri = "$frame/minimap/minimap.xml",
    video = 1,
    video_group = c_video_replay_ui_group_common_mode
  },
  {
    style = "main",
    uri = "$frame/minimap/leave_help.xml"
  },
  {
    style = "leave_mask",
    uri = "$frame/minimap/leave_help.xml"
  },
  {
    style = "dexp_display",
    uri = "$frame/dexp/dexp.xml"
  },
  {config = cfgwnd_guild},
  {
    style = "lianzhao",
    uri = "$frame/skill/lianzhao.xml"
  },
  {
    style = "huazhao",
    uri = "$frame/skill/huazhao.xml"
  },
  {
    style = "skill_preview",
    uri = "$frame/skill/skill_preview.xml"
  },
  {
    style = "main",
    uri = "$frame/stall/stall.xml"
  },
  {
    style = "main",
    uri = "$frame/stall/viewer.xml"
  },
  {
    style = "main",
    uri = "$frame/stall/chat.xml"
  },
  {
    style = "friend_info",
    uri = "$frame/sociality/friend_list.xml"
  },
  {
    style = "friend_list",
    uri = "$frame/sociality/friend_list.xml"
  },
  {
    style = "sociality",
    uri = "$frame/sociality/sociality.xml"
  },
  {
    style = "state",
    uri = "$frame/state/state.xml"
  },
  {
    style = "team",
    uri = "$frame/team/team.xml"
  },
  {
    style = "score",
    uri = "$frame/scncopy/score.xml"
  },
  {
    style = "scncopy_lottery",
    uri = "$frame/scncopy/lottery.xml"
  },
  {
    style = "lottery_msg",
    uri = "$frame/scncopy/lottery_msg.xml"
  },
  {
    style = "scnbidding",
    uri = "$frame/scncopy/scnbidding.xml"
  },
  {
    style = "online_prompt",
    uri = "$frame/prompt/prompt.xml"
  },
  {
    style = "marquee",
    uri = "$frame/marquee/marquee.xml"
  },
  {
    style = "mall",
    uri = "$frame/mall/mall.xml"
  },
  {
    style = "offline_prompt",
    uri = "$frame/prompt/prompt.xml"
  },
  {
    style = "main",
    uri = "$frame/errantry/errantry.xml"
  },
  {config = cfgwnd_npcfunc},
  {
    style = "main",
    uri = "$frame/discover/content.xml"
  },
  {
    style = "md",
    uri = "$frame/discover/md.xml"
  },
  {
    style = "campaign_desc",
    uri = "$frame/campaign/campaign_desc.xml"
  },
  {
    style = "campaign",
    uri = "$frame/campaign/campaign.xml"
  },
  {
    style = "chat",
    uri = "$frame/chat/chat.xml",
    widget = "fader"
  },
  {
    style = "im_main",
    uri = "$frame/im/im.xml"
  },
  {
    style = "chg_portrait",
    uri = "$frame/im/chg_portrait.xml"
  },
  {
    style = "im_setup",
    uri = "$frame/im/im_setup.xml"
  },
  {
    style = "im_msg_control",
    uri = "$frame/im/msg_control.xml"
  },
  {
    style = "chatgroup",
    uri = "$frame/im/chatgroup.xml"
  },
  {
    style = "input_custom",
    uri = "$frame/im/dialog.xml"
  },
  {
    style = "main",
    uri = "$frame/dooaltar/apply.xml"
  },
  {
    style = "main",
    uri = "$frame/dooaltar/select.xml"
  },
  {
    style = "main",
    uri = "$frame/dooaltar/score.xml"
  },
  {
    style = "convene",
    uri = "$frame/convene/convene.xml"
  },
  {
    style = "teleport_proposal",
    uri = "$frame/convene/teleport.xml"
  },
  {
    style = "teleport_view",
    uri = "$frame/convene/teleport.xml"
  },
  {
    style = "teleport_invite",
    uri = "$frame/convene/teleport.xml"
  },
  {
    style = "invite_view",
    uri = "$frame/convene/invite.xml"
  },
  {
    style = "rank",
    uri = "$frame/rank/rank.xml"
  },
  {
    style = "main",
    uri = "$frame/mail/mail.xml"
  },
  {
    style = "dungeonui",
    uri = "$frame/dungeonui/dungeonui.xml"
  },
  {
    style = "quest",
    uri = "$frame/gm/gm.xml",
    outer_config = 1,
    video = 1,
    video_widget = "fader",
    video_group = c_video_replay_ui_group_all_mode
  },
  {
    style = "serie_hits",
    uri = "$frame/skill/serie_hits.xml",
    widget = "fader"
  },
  {
    style = "SeekHelp",
    uri = "$frame/knight/seek_help.xml"
  },
  {
    style = "deathui",
    uri = "$frame/deathui/deathui.xml"
  },
  {
    style = "ui_askway",
    uri = "$frame/askway/askway.xml"
  },
  {
    style = "scode",
    uri = "$frame/scode/scode.xml"
  },
  {
    style = "serie_display",
    uri = "$frame/skill/display.xml",
    widget = "fader"
  },
  {
    style = "ui_quest_temp_tip",
    uri = "$frame/levelten/quest_temp_tip.xml"
  },
  {
    style = "stall_surround",
    uri = "$frame/stall/stall_surround.xml"
  },
  {
    style = "guildfarm",
    uri = "$frame/guildfarm/guildfarm.xml"
  },
  {
    style = "prison",
    uri = "$frame/prison/prison.xml"
  },
  {
    style = "find",
    uri = "$frame/im/find.xml"
  },
  {
    style = "f_of_f",
    uri = "$frame/im/foff.xml"
  },
  {
    style = "leaveword",
    uri = "$frame/im/leaveword.xml"
  },
  {
    style = "group_list",
    uri = "$frame/im/group_list.xml"
  },
  {
    style = "main",
    uri = "$frame/match/match.xml"
  },
  {
    style = "main",
    uri = "$frame/match/select_turn.xml"
  },
  {
    style = "main",
    uri = "$frame/match/status.xml"
  },
  {
    style = "main",
    uri = "$frame/match/minimum.xml"
  },
  {
    style = "main",
    uri = "$frame/match/viewlist.xml"
  },
  {
    style = "main",
    uri = "$frame/match/animation.xml",
    widget = "fader"
  },
  {
    style = "main",
    uri = "$frame/match/group_mng.xml"
  },
  {
    style = "main",
    uri = "$frame/match/watch_guess.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle01/info.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle01/top_tip.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle02/info.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle02/top_tip.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle03/info.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle03/top_tip.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle_12p/info.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle_12p/top_tip.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle_5v5/info.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle_5v5/top_tip.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle_5v5green/info.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle_5v5green/top_tip.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle_assassin/info.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle_assassin/top_tip.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle04/info.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle04/top_tip.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battleteam/info.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battleteam/top_tip.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/horse_racing/top_tip.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/fly_racing/top_tip.xml"
  },
  {
    style = "main",
    uri = "$frame/horse_racing/horse_racing.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/battle_common.xml"
  },
  {
    style = "main",
    uri = "$frame/battle/plugin/battle_comment.xml"
  },
  {
    style = "main",
    uri = "$frame/stall/plus_stall_viewer.xml"
  },
  {
    style = "main",
    uri = "$frame/scn_matchunit/scn_matchunit.xml"
  },
  {
    style = "main",
    uri = "$frame/scn_matchunit/minimum.xml"
  },
  {
    style = "main",
    uri = "$frame/minimap/waitlist.xml"
  },
  {
    style = "main",
    uri = "$frame/match/popo_dialog.xml"
  },
  {
    style = "advertise",
    uri = "$frame/advertise/advertise_all.xml"
  },
  {
    style = "zdteach",
    uri = "$frame/help/zdteach.xml"
  },
  {
    style = "teach_info",
    uri = "$frame/help/zdteach.xml"
  },
  {
    style = "deathui_countdown",
    uri = "$frame/deathui/deathui_countdown.xml"
  },
  {
    style = "main",
    uri = "$frame/film/film.xml",
    widget = "fader"
  },
  {
    style = "main",
    uri = "$frame/dungeonui/trans_dungeonui.xml"
  },
  {
    style = "tool_handson",
    uri = "$frame/help/tool_handson.xml"
  },
  {
    style = "tool_handson_common2",
    uri = "$frame/help/tool_handson.xml",
    widget = "fader"
  },
  {
    style = "tool_handson_qlink",
    uri = "$frame/help/tool_handson.xml"
  },
  {
    style = "tool_handson_item",
    uri = "$frame/help/tool_handson.xml"
  },
  {
    style = "tool_handson_flicker_0",
    uri = "$frame/help/tool_handson.xml"
  },
  {
    style = "main",
    uri = "$frame/info_tip/info_tip.xml"
  },
  {
    style = "infos",
    uri = "$frame/info_tip/info_tip.xml"
  },
  {
    style = "schedule_cd",
    uri = "$frame/info_tip/schedule_cd.xml"
  },
  {
    style = "tmpbattle_cd",
    uri = "$frame/info_tip/tmp_battle.xml"
  },
  {
    style = "boss_list",
    uri = "$frame/boss_list/boss_list.xml"
  },
  {
    style = "net_delay",
    uri = "$frame/net_delay/net_delay.xml"
  },
  {
    style = "renown_tips",
    uri = "$frame/net_delay/net_delay.xml"
  },
  {
    style = "main",
    uri = "$frame/timeaward/xinshou_time_award.xml"
  },
  {
    style = "main",
    uri = "$frame/match_cmn/match_cmn.xml"
  },
  {
    style = "knight_over_countdown",
    uri = "$frame/deathui/deathui_countdown.xml"
  },
  {
    style = "video_view",
    uri = "$frame/video_view/video_view.xml",
    video = 1,
    video_only = 1,
    widget = "fader",
    video_group = c_video_replay_ui_group_pk_mode
  },
  {
    style = "video_cover",
    uri = "$frame/video_view/video_view.xml",
    video = 1,
    video_only = 1,
    widget = "fader",
    video_group = c_video_replay_ui_group_all_mode
  },
  {
    style = "main",
    uri = "$frame/item/log_deal.xml"
  },
  {
    style = "xf_cangku",
    uri = "$frame/skill/xf_cangku.xml"
  },
  {
    style = "cloned_battle",
    uri = "$frame/clonedbattle/clonedbattle_en.xml"
  },
  {
    style = "cloned_battle_friend_assist",
    uri = "$frame/clonedbattle/clonedbattle_en.xml"
  },
  {
    style = "warrior_arena_mask",
    uri = "$frame/warrior_arena/warrior_arena_career.xml"
  },
  {
    style = "main",
    uri = "$frame/pixelmouse/pixelmouse.xml"
  },
  {
    style = "main",
    uri = "$frame/pixelmouse/ui_pixelmouse.xml"
  },
  {
    style = "scratch_skill_show",
    uri = "$frame/skill/scratch_skill_effect.xml"
  },
  {
    style = "main",
    uri = "$frame/scn_knightunit/knight_cmn.xml"
  },
  {
    style = "main",
    uri = "$frame/scn_knightunit/scn_knightunit.xml"
  },
  {
    style = "knight_gift",
    uri = "$frame/personal/renown.xml"
  },
  {
    style = "renown_rank_wnd",
    uri = "$frame/personal/renown.xml"
  },
  {
    style = "wlt_death_ui",
    uri = "$frame/dungeonui/wlt_death_ui.xml"
  },
  {
    style = "wlt_borrow_ui",
    uri = "$frame/dungeonui/wlt_death_ui.xml"
  },
  {
    style = "wlt_life_info_ui",
    uri = "$frame/dungeonui/wlt_life_info_ui.xml"
  },
  {
    style = "main",
    uri = "$frame/common_border/border.xml"
  },
  {
    style = "champion",
    uri = "$frame/champion/champion.xml"
  },
  {
    style = "fate",
    uri = "$frame/fate_2/fate_2.xml"
  },
  {
    style = "fate_rank",
    uri = "$frame/fate_2/fate_2.xml"
  },
  {
    style = "main",
    uri = "$frame/dungeonui/chg_to_dungeon_confirm.xml"
  },
  {
    style = "mask",
    uri = "$frame/mask/mask.xml",
    widget = "fader"
  },
  {
    style = "cloned_battle_over_countdown",
    uri = "$frame/deathui/deathui_countdown.xml"
  },
  {
    style = "main",
    uri = "$frame/match/statistics.xml"
  },
  {
    style = "arc_death_ui",
    uri = "$frame/dungeonui/arcade_dungeon_death_ui.xml"
  },
  {
    style = "arc_borrow_ui",
    uri = "$frame/dungeonui/arcade_dungeon_death_ui.xml"
  },
  {
    style = "main",
    uri = "$frame/thebestfighter/thebestfighter.xml"
  },
  {
    style = "dungeonsel",
    uri = "$frame/dungeonui/dungeonsel.xml"
  },
  {
    style = "arc_life_info_ui",
    uri = "$frame/dungeonui/arcade_dungeon_life_info.xml"
  },
  {
    style = "ui_levelup",
    uri = "$frame/levelup/levelup.xml"
  },
  {
    style = "first_in_prison_scn",
    uri = "$frame/prison/prison.xml"
  },
  {
    style = "fight_route_shortcut_bar",
    uri = "$frame/qbar/fight_route_shortcut.xml"
  },
  {
    style = "rand_event_show",
    uri = "$frame/rand_event/rand_event.xml"
  },
  {
    style = "rand_event_monitor",
    uri = "$frame/rand_event/rand_event_monitor.xml"
  },
  {
    style = "rand_event_result",
    uri = "$frame/rand_event/rand_event_result.xml"
  },
  {
    style = "ui_practice",
    uri = "$frame/practice/practice.xml"
  },
  {
    style = "ui_training",
    uri = "$frame/practice/practice.xml"
  },
  {
    style = "slot_enhance_detail",
    uri = "$frame/personal/slot_enhance.xml"
  },
  {
    style = "areaquest",
    uri = "$frame/areaquest/areaquest_ui.xml"
  },
  {
    style = "cross_line",
    uri = "$frame/cross_line/cross_line.xml"
  },
  {
    style = "cross_line_score",
    uri = "$frame/cross_line/cross_line.xml"
  },
  {
    style = "cross_line_online_info",
    uri = "$frame/cross_line/cross_line_online_info.xml"
  },
  {
    style = "main",
    uri = "$frame/cross_line/camp_repute.xml"
  },
  {
    style = "auto_shutdown",
    uri = "$frame/auto_shutdown/auto_shutdown.xml"
  },
  {
    style = "beckon_knpc",
    uri = "$frame/knight/beckon_k_npc.xml"
  },
  {
    style = "tips",
    uri = "$frame/giftaward_v2/top_tip.xml"
  },
  {
    style = "main",
    uri = "$frame/giftaward_v2/http_url.xml"
  },
  {
    style = "main",
    uri = "$frame/giftaward_v2/top_tip.xml"
  },
  {
    style = "edit",
    uri = "$frame/giftaward_v2/http_url.xml"
  },
  {
    style = "giftaward_rmb",
    uri = "$frame/giftaward_v2/qq_style/qq_style_vip.xml"
  },
  {
    style = "main",
    uri = "$frame/qt/qt.xml"
  },
  {
    style = "main",
    uri = "$frame/http/http_xml.xml"
  },
  {
    style = "central",
    uri = "$frame/central/central.xml",
    video_style = "video_central",
    video_widget = "fader",
    video = 1,
    video_group = c_video_replay_ui_group_all_mode
  },
  {
    style = "ui_vote",
    uri = "$frame/vote/vote.xml"
  },
  {
    style = "buff_exchange",
    uri = "$frame/action/buff_exchange.xml"
  },
  {
    style = "knight_event_show",
    uri = "$frame/rand_event/rand_event_knight.xml"
  },
  {
    style = "question",
    uri = "$frame/question/question.xml"
  },
  {
    style = "question_conclusion",
    uri = "$frame/question/question_conclusion.xml"
  },
  {
    style = "campaign_special",
    uri = "$frame/campaign/campaign_special.xml"
  },
  {
    style = "push_ui",
    uri = "$frame/areaquest/push_event.xml"
  },
  {
    style = "team_assign",
    uri = "$frame/team/team_assign.xml"
  },
  {
    style = "xinshou",
    uri = "$frame/xinshou/xinshou.xml"
  },
  {
    style = "xinshou_desc",
    uri = "$frame/xinshou/xinshou_desc.xml"
  },
  {
    style = "auction_win",
    uri = "$frame/auction/auction.xml"
  },
  {
    style = "main",
    uri = "$frame/ranklist/ranklist.xml"
  },
  {
    style = "refresh_ui",
    uri = "$frame/refresh_ui/refresh_ui.xml"
  },
  {
    style = "warrior_arena_list",
    uri = "$frame/warrior_arena/warrior_arena.xml"
  },
  {
    style = "warrior_arena_select",
    uri = "$frame/warrior_arena/warrior_arena.xml"
  },
  {
    style = "help_note",
    uri = "$frame/help_note/help_note.xml"
  },
  {
    style = "history_name",
    uri = "$frame/im/history_name.xml"
  },
  {
    style = "warrior_arena_career",
    uri = "$frame/warrior_arena/warrior_arena_career.xml"
  },
  {
    style = "fb_token",
    uri = "$frame/facebook/fb.xml"
  },
  {
    style = "fb_share",
    uri = "$frame/facebook/fb.xml"
  },
  {
    style = "vn_vedio",
    uri = "$frame/facebook/fb.xml"
  },
  {
    style = "main",
    uri = "$frame/knight/kchallenge_item.xml"
  },
  {
    style = "main",
    uri = "$frame/knight/kchallenge_rand.xml"
  },
  {
    style = "kitem_msgbox",
    uri = "$frame/knight/kchallenge_item.xml"
  },
  {
    style = "InSideHang",
    uri = "$frame/ish/ish.xml"
  },
  {
    style = "main",
    uri = "$frame/jump/jumpteach.xml"
  },
  {
    style = "wish",
    uri = "$frame/wish/wish.xml"
  },
  {
    style = "come_true",
    uri = "$frame/wish/come_true.xml"
  },
  {
    style = "activation",
    uri = "$frame/activation/activation.xml"
  }
}
function video_disable_top()
  if bo2.video_mode ~= nil then
    local config_windows = ui_main.config_windows
    for i, v in ipairs(config_windows) do
      if sys.check(v.panel) then
        v.panel.visible = false
      end
    end
  end
end
function check_video_visble(vis_group)
  if bo2.video_mode ~= nil and bo2.VideoUIMode ~= vis_group then
    return true
  end
  return false
end
function video_disable_window()
  ui_quest.ui_tracing.w_tracing_quest.visible = false
  ui_qbar.w_qlink.visible = false
  ui_qbar.w_qlink.visible = false
  if bo2.VideoUIMode == c_video_replay_ui_group_pk_mode then
    ui_qbar.w_qbar.visible = false
    ui_portrait.w_player_show.visible = false
  else
    ui_qbar.w_qbar.visible = true
    ui_portrait.w_player_show.visible = true
  end
end
function video_show_top()
  if bo2.video_mode ~= nil then
    if ui_video.is_jump() then
      return
    end
    local config_windows = ui_main.config_windows
    for i, v in ipairs(config_windows) do
      if sys.check(v.panel) ~= false then
        if v.video == nil or v.video_group ~= nil and v.video_group ~= c_video_replay_ui_group_all_mode and v.video_group ~= bo2.VideoUIMode then
          v.panel.visible = false
        elseif v.outer_config ~= nil and ui_phase.w_outer_config == nil and ui_phase.w_inner_config == nil then
          v.panel.visible = false
        else
          v.panel.visible = true
        end
      end
    end
    video_disable_window()
    video_replay_toggle_alpha(0, 1)
  end
end
local function merge_cfgwnd(cw, src)
  local weight_all = 0
  for i, v in ipairs(src) do
    local cfg = v.config
    if cfg ~= nil then
      weight_all = weight_all + merge_cfgwnd(cw, cfg)
    else
      local w = v.weight
      if w == nil then
        w = 100
      end
      weight_all = weight_all + w
      table.insert(cw, v)
    end
  end
  return weight_all
end
local stat_enter = function(d, v)
  if d == nil then
    return
  end
  d.tick = sys.tick()
  d.controls_count = ui.stat_controls_count()
end
local stat_leave = function(d, v)
  if d == nil then
    return
  end
  local dt = sys.tick() - d.tick
  local dc = ui.stat_controls_count() - d.controls_count
  ui.log("ui(%s,%s): %d(ms). %d(controls)", v.uri, v.style, dt, dc)
end
local function do_show_top(fn)
  dock_offset_reset()
  ui.enter_game()
  ui.tag_text_reset(w_top)
  ui_widget.esc_stk_clear()
  ui.log("ui_phase:main : loading enter")
  w_top:load_style("$gui/phase/main/main.xml", "w_main")
  local cw = {}
  local weight_all = merge_cfgwnd(cw, config_windows)
  local stat
  local weight = 0
  local bLoad = true
  local c_init_lang = bo2.get_lang()
  for i, v in ipairs(cw) do
    do
      local function process_load()
        if v == nil then
          return
        end
        if v.lang ~= nil and v.lang ~= c_init_lang and (c_init_lang == c_lang_ch or v.lang ~= c_lang_other) then
          return
        end
        if fn ~= nil then
          fn(weight / weight_all, sys.format("ui(%s,%s)", v.uri, v.style))
        end
        local w = v.weight
        if w == nil then
          w = 100
        end
        weight = weight + w
        local wt = v.widget
        local bSetAlphaSolo = false
        if wt == nil then
          wt = "panel"
          if bo2.video_mode ~= nil then
            if v.video_widget ~= nil then
              wt = v.video_widget
              bSetAlphaSolo = true
            elseif v.video_group ~= nil then
              wt = "fader"
              bSetAlphaSolo = true
            end
          end
        end
        bLoad = true
        if v.video_only ~= nil then
          if bo2.video_mode ~= nil then
            bLoad = true
          else
            bLoad = false
          end
        end
        if bLoad == true then
          stat_enter(stat, v)
          local p = ui.create_control(w_top, wt)
          if p ~= nil then
            local _style = v.style
            if bo2.video_mode ~= nil and v.video_style ~= nil then
              _style = v.video_style
            end
            p:load_style(v.uri, _style)
            if bo2.video_mode ~= nil then
              p.visible = false
              if wt == "fader" and v.video == nil then
                p.alpha_solo = false
              end
            end
            v.panel = p
            if bSetAlphaSolo then
              p.alpha_solo = true
            end
          else
            ui.log("ui_phase:main : failed create control %s.", wt)
          end
          stat_leave(stat, v)
        end
      end
      if v.event == nil then
        process_load()
      else
        sys.pcall(sys.get(v.event))
      end
    end
  end
  sys.pcall(ui_qbar.ui_hide_anim.reg)
  on_init(w_top)
  ui.log("ui_phase:main : loading leave")
  w_top.visible = true
  w_top:apply_dock(true)
  dock_offset_load()
end
function show_top(vis, fn)
  ui.log("show_top")
  if vis then
    ui_startup.show_top(false)
    ui_choice.show_top(false)
    ui_tool.tool_clear()
    if w_top.visible then
      video_show_top()
      return
    end
    sys.pcall(do_show_top, fn)
    return
  end
  if not w_top.visible then
    return
  end
  ui_loading.show_top(true, 2)
  ui.log("main clear")
  dock_offset_reset()
  ui.clean_drop()
  bo2.unload_scn()
  w_top:control_clear()
  w_top.visible = false
  ui_tool.w_progress_fader.visible = false
  ui.leave_game()
  ui.log("main out")
end
g_player_cfg_username = nil
g_player_cfg_playername = nil
function player_cfg_make_uri(file, user)
  local stk = sys.stack()
  stk:push("$cfg/user/")
  if g_player_cfg_username ~= nil then
    stk:format("%s/", g_player_cfg_username)
  else
    stk:push("@user/")
  end
  if user == nil then
    if g_player_cfg_playername ~= nil then
      stk:format("%s/", g_player_cfg_playername)
    else
      stk:push("@player/")
    end
  end
  stk:push(file)
  local uri = stk.text
  return uri
end
function player_cfg_load(file, user)
  local uri = player_cfg_make_uri(file, user)
  local x = sys.xnode()
  if not x:load(uri) then
    return nil
  end
  return x
end
function player_cfg_save(x, file, user)
  local uri = player_cfg_make_uri(file, user)
  x:save(uri)
end
function on_main_focus(ctrl, focus)
  bo2.notify_on_focus(focus)
end
function on_mouse(w, msg, pos, wheel)
  if msg == ui.mouse_rbutton_down then
    ui_chat.w_chat_channel.visible = false
  elseif msg == ui.mouse_rbutton_up or msg == ui.mouse_leave then
  end
  if bo2.IsVideoPlaying() ~= false then
    if msg == ui.mouse_lbutton_click then
      ui_video.on_click_pause_video()
    end
    if msg ~= ui.mouse_wheel and msg ~= ui.mouse_move and msg ~= ui.mouse_rbutton_down and msg ~= ui.mouse_rbutton_up and msg ~= ui.mouse_rbutton_click then
      return
    end
  end
  bo2.notify_on_mouse(msg, pos, wheel)
end
function on_key(w, key, flag)
  if bo2.video_mode ~= nil and bo2.IsVideoPlaying() ~= false and sys.check(ui_central) and sys.check(ui_central.w_central) and flag.down then
    if key == ui.VK_ESCAPE then
      ui_central.w_central.visible = not ui_central.w_central.visible
    elseif key == ui.VK_SPACE then
      ui_video.on_click_pause_video()
    end
    return
  end
  if key == ui.VK_ESCAPE then
    if flag.down then
      if ui.check_drop() then
        ui.clean_drop()
        return
      end
      local w = ui_widget.esc_stk_pop()
      if w == nil then
        ui_central.show_central()
      else
        w.visible = false
      end
    end
    return
  end
  if key == ui.VK_CONTROL and false == flag.down then
    local var = sys.variant()
    var:set("id", 1023)
    var:set("down", 0)
    var:set("dbl", 0)
    bo2.notify_on_op(var)
  end
end
local g_is_drop_down = false
function on_drop(obj, msg, pos, data)
  if msg == ui.mouse_move then
    return
  end
  if msg == ui.mouse_lbutton_down then
    g_is_drop_down = true
    return
  end
  if msg == ui.mouse_rbutton_down then
    g_is_drop_down = false
    ui.clean_drop()
    return
  end
  if msg == ui.mouse_drop_clean or msg == ui.mouse_enter or msg == ui.mouse_leave then
    g_is_drop_down = false
    return
  end
  if msg ~= ui.mouse_lbutton_up then
    return
  end
  if not g_is_drop_down then
    return
  end
  g_is_drop_down = false
  ui.clean_drop()
  if ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    ui_item.box_destroy_drop(data)
    return
  end
  if ui_widget.check_drop(data, ui_widget.c_drop_type_shortcut) then
    ui.shortcut_set(data:get("index").v_int, bo2.eShortcut_None, 0)
    if data:get("index").v_int >= 58 and data:get("index").v_int <= 61 then
      ui_tempshortcut.ListRemove(data)
    end
    return
  end
  if ui_widget.check_drop(data, ui_widget.c_drop_type_lianzhao) then
    data:get("card").v_object.excel_id = 0
  end
end
function goto_choice()
  bo2.sync_cfg()
  ui_packet.gzs_out()
end
function goto_startup()
  bo2.sync_cfg()
  ui_packet.login_out()
end
function set_progress(per, msg)
  ui_loading.set_progress(per)
end
local self_per = 0.9
if rawget(_M, "g_scn_connected") == nil then
  g_scn_connected = 0
end
function on_load_scn(cmd, data)
  g_scn_connected = 1
  on_cmd_sever_os_time(cmd, data)
  local bLoad = bo2.pre_load_scn(data)
  loading_time = os.clock()
  if not bLoad then
    ui_loading.show_top(true, 2)
    ui_loading.taskbar_show()
  end
  ui_widget.on_player_leave()
  ui_tool.tool_clear()
  local base_per = 0
  local function on_load_scn_progress(per, msg)
    local now_per = base_per + per * (self_per - base_per)
    set_progress(now_per, msg)
  end
  local ui_per = 0.1
  local function on_load_ui_progress(per, msg)
    local now_per = ui_per * per
    set_progress(now_per, nil)
  end
  w_top.cursor = nil
  if ui_queueing.gx_window then
    ui_queueing.gx_window.visible = false
    ui_queueing.reset_time()
  end
  if not w_top.visible then
    bo2.post_prefetch_scn(data:get(packet.key.scn_excel_id).v_int)
    ui_loading.insert_msg(ui.get_text("phase|main_loading_ui"), true)
    g_player_cfg_playername = data:get(packet.key.cha_name).v_string
    show_top(true, on_load_ui_progress)
    base_per = ui_per
  end
  ui_loading.insert_msg(ui.get_text("phase|main_loading_scn"), true)
  ui_loading.set_progress(base_per)
  ui.log("on_load_scn: excel_id %d.", data:get(packet.key.scn_excel_id).v_int)
  local function do_load_scn()
    bo2.load_scn(data, on_load_scn_progress)
  end
  if perf_stat ~= nil then
    perf_stat:invoke(do_load_scn)
    perf_stat:save("$app/log/perf_scn.txt")
  else
    do_load_scn()
  end
  if bo2.scn then
    bo2.scn.view = w_top
  end
end
function on_disconnect_scn(cmd, data)
  local tp = data:get(packet.key.subserver_type).v_int
  local show = ui_chat.show_ui_text_id
  if tp == bo2.eSvrType_Scn then
    g_scn_connected = 0
    show(1406)
    if ui_dungeonruntimeinfo ~= nil then
      ui_dungeonruntimeinfo.terminal_panel()
    end
    return
  end
  if tp == bo2.eSvrType_GlobalMisc then
    show(1401)
    return
  end
  if tp == bo2.eSvrType_Sociality then
    show(1403)
    return
  end
  if tp == bo2.eSvrType_Campaign then
    show(1405)
    return
  end
end
function on_load_self(obj)
  ui_loading.insert_msg(ui.get_text("phase|main_loading_cha"), true)
  ui.log("on_load_self: name %s.", obj.cha_excel.name)
end
function createfinished()
  if self_per < 1 and ui_loading.w_top.visible then
    local function on_draw_scn(per)
      local now_per = self_per + per * (1 - self_per)
      ui_loading.set_progress(now_per)
    end
    bo2.draw_scn(4, 8, on_draw_scn)
  end
  ui_loading.show_scn()
  ui_stall.stall_chg_scn()
  ui_minimap.set_leave_visible()
  ui_scncopy.set_vis(false)
  ui_battle_common.set_topinfo_vis()
  ui_match_cmn.match_visible_check()
  if bo2.qt_is_loaded() ~= 1 then
    bo2.qt_load_app_qt()
  end
  set_main_focus()
  ui_prompt.set_start_time()
  video_show_top()
  local player = bo2.player
  local isDead = player:get_flag_int32(bo2.ePlayerFlagInt32_DeadRemainTime)
  if isDead > 0 then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_UI_DeadLoad_finish, v)
  end
  ui.log("ui_main.createfinished")
end
function set_main_focus()
  if not w_top.visible then
    return
  end
  ui.hotkey_set_monitor(w_top)
  ui.set_default_focus(w_top)
  w_top.focus = true
end
function on_window_close_check()
  if not w_top.visible or ui_loading.w_top.visible then
    return true
  end
  ui.main_window_show(true)
  if bo2.video_mode == nil and (inner_config_quick_close == nil or not inner_config_quick_close) then
    goto_startup()
    return false
  end
  local quit_text = ui.get_text("phase|main_exit_query")
  if bo2.video_mode ~= nil then
    ui_video.on_click_stop_video()
    quit_text = ui.get_text("phase|main_exit_video_query")
  end
  ui_widget.ui_msg_box.show_common({
    text = quit_text,
    callback = function(msg)
      if msg.result == 1 then
        bo2.app_quit()
      end
    end
  })
  return false
end
function init()
  bo2.insert_on_close_check(on_window_close_check, "ui_main.on_window_close_check")
end
function video_replay_toggle_alpha(v, period)
  local a = w_top.alpha
  if period == nil then
    period = math.abs(v - a) * 1000
  end
  w_top:reset(a, v, period)
end
function toggle_alpha_v(v, period)
  local a = w_top.alpha
  if period == nil then
    period = math.abs(v - a) * 1000
  end
  w_top:reset(a, v, period)
  ui_tool.w_note_top:reset(a, v, period)
  if v < 0.001 then
    bo2.qt_hide()
  else
    bo2.qt_show()
  end
end
local w_show_ui_count = 0
local g_show_tab = {}
function ShowUI(b, period, n)
  if b then
    w_show_ui_count = w_show_ui_count - 1
    if w_show_ui_count == 0 then
      toggle_alpha_v(1, period)
    elseif w_show_ui_count < 0 then
      w_show_ui_count = 0
    end
  else
    w_show_ui_count = w_show_ui_count + 1
    if w_show_ui_count == 1 then
      toggle_alpha_v(0, period)
    end
  end
  ui.log("w_show_ui_count" .. w_show_ui_count)
end
function toggle_alpha()
  local v = 1
  local e = w_top.alpha_leave
  if e > 0.701 then
    v = 0.7
  elseif e > 0.301 then
    v = 0.3
  elseif e > 0.001 then
    v = 0
  else
    v = 1
  end
  toggle_alpha_v(v)
end
function on_main_visible(ctrl, vis)
  if vis then
    if ui_loading.w_top.visible then
      ui.set_default_focus(ui_loading.w_top)
    else
      ui.hotkey_set_monitor(ctrl)
    end
  elseif ui.get_default_focus() == ctrl then
    ui.hotkey_set_monitor(nil)
    w_top.alpha = 1
    ui_tool.w_note_top.alpha = 1
  end
end
function dock_offset_reset()
  w_top.svar.dock_offset_data = {}
  w_top.svar.dock_offset_is_load = false
  w_top.svar.dock_offset_is_post = false
end
function dock_offset_restore()
  local d = w_top.svar.dock_offset_data
  for n, item in pairs(d) do
    local w = item.window
    if sys.check(w) then
      w.dock = item.dock
    end
  end
  dock_offset_post()
end
function dock_offset_load()
  w_top.svar.dock_offset_is_load = true
  w_top.svar.dock_offset_is_post = false
  if not w_top.visible then
    return
  end
  local cfg = player_cfg_load("dock_offset.xml")
  if cfg == nil then
    return
  end
  local d = w_top.svar.dock_offset_data
  for i = 0, cfg.size - 1 do
    local n = cfg:get(i)
    local item = d[n.name]
    local w = item.window
    if sys.check(w) then
      local s_x, s_y = n:get_attribute("offset"):split2(",")
      local x, y = s_x.v_number, s_y.v_number
      local dx, dy = w.parent.dx, w.parent.dy
      local dock = n:get_attribute("dock")
      if dock == L("x1y1") then
        w.offset = ui.point(x, y)
      elseif dock == L("x1y2") then
        w.offset = ui.point(x, dy - y - w.dy)
      elseif dock == L("x2y1") then
        w.offset = ui.point(dx - x - w.dx, y)
      elseif dock == L("x2y2") then
        w.offset = ui.point(dx - x - w.dx, dy - y - w.dy)
      end
      w.dock = "none"
    end
  end
end
function dock_offset_update()
  if not w_top.svar.dock_offset_is_post then
    return
  end
  w_top.svar.dock_offset_is_post = false
  if not w_top.svar.dock_offset_is_load then
    return
  end
  local d = w_top.svar.dock_offset_data
  cfg = sys.xnode()
  for n, item in pairs(d) do
    local w = item.window
    if sys.check(w) and w.dock == L("none") then
      local t = cfg:get(n)
      local cx = w.x + w.dx * 0.5
      local cy = w.y + w.dy * 0.5
      local px = w.parent.dx
      local py = w.parent.dy
      local dock, offset
      if cx < px * 0.5 then
        dock = L("x1")
        offset = w.x
      else
        dock = L("x2")
        offset = px - (w.x + w.dx)
      end
      if cy < py * 0.5 then
        t:set_attribute("dock", dock .. L("y1"))
        t:set_attribute("offset", sys.format("%d,%d", offset, w.y))
      else
        t:set_attribute("dock", dock .. L("y2"))
        t:set_attribute("offset", sys.format("%d,%d", offset, py - (w.y + w.dy)))
      end
    end
  end
  player_cfg_save(cfg, "dock_offset.xml")
end
function dock_offset_post()
  if w_top.svar.dock_offset_is_post then
    return
  end
  w_top.svar.dock_offset_is_post = true
  w_top:insert_post_invoke(dock_offset_update, "ui_main.dock_offset_update")
end
function on_dock_offset_reg(ctrl, name)
  local d = w_top.svar.dock_offset_data
  d[name] = {
    window = ctrl,
    dock = ctrl.dock
  }
  ctrl:insert_on_move(dock_offset_post, "ui_main.dock_offset_update")
  dock_offset_post()
end
function on_main_move(ctrl)
  w_top:insert_post_invoke(dock_offset_load, "ui_main.dock_offset_load")
  if ui_item ~= nil and sys.check(ui_item.w_item) then
    ui_item.box_post_tune()
  end
end
function on_init(w)
  w:reset(1, 1)
end
local area_trans_time = 0
local area_trans_time_max = 1000
function on_area_trans(cmd, data)
  local areaTransLoad = data:get(packet.key.cha_area).v_int
  if areaTransLoad ~= 0 then
    ui_loading.show_top(true, 2)
    area_trans_loading_time.suspended = false
  end
  bo2.CameraReset()
end
function on_area_trans_timing(timer)
  area_trans_time = area_trans_time + 25
  local now_per = area_trans_time / area_trans_time_max
  set_progress(now_per, nil)
  if area_trans_time >= area_trans_time_max then
    timer.suspended = true
    area_trans_time = 0
    ui_loading.show_scn()
    bo2.qt_show()
  end
end
init_once()
g_server_os_time = {}
function on_init_server_os_time()
  g_server_os_time = {
    bValid = false,
    current_time = 0,
    server_time = 0,
    os_time = 0
  }
end
on_init_server_os_time()
function get_os_time()
  if g_server_os_time == nil or g_server_os_time.bValid ~= true then
    return os.time()
  end
  local _time = bo2.get_server_time()
  return _time
end
function on_cmd_sever_os_time(cmd, data)
  local _time = data:get(packet.key.org_time).v_int
  if _time ~= 0 then
    g_server_os_time.bValid = true
    bo2.record_server_time(data)
  end
end
local sig_name = "ui_main:on_signal"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Game_LoadScn, on_load_scn, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_Svr_Disconnect, on_disconnect_scn, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, createfinished, sig_name .. "ui_main.packet.createfinished")
ui_packet.recv_wrap_signal_insert(packet.eSTC_Game_AreaTrans, on_area_trans, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_load_self, sig_name)
