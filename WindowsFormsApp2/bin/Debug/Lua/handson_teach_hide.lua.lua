local _popup_windows_common = 1
local _popup_windows_qlink = 2
local _popup_windows_item = 3
cs_tip_newline = SHARED("\n")
local c_flicker_uri = L("$gui/frame/help/tool_handson.xml")
local c_flicker_style = L("tool_handson_flicker")
g_hide_atb_monitor = false
function on_init_hide_quest_data()
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HideFriends] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HideFriends][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HideFriends,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest,
    flag = false
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HideFriends] = {
    finish_id = bo2.ePlayerFlagInt16_HideFriends,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HideNpcSearchList] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HideNpcSearchList][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HideNpcSearchList,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HideNpcSearchList] = {
    finish_id = bo2.ePlayerFlagInt16_HideNpcSearchList,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOnNpcSearchList] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOnNpcSearchList][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOnNpcSearchList,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOnNpcSearchList] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOnNpcSearchList,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HideArema] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HideArema][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HideArema,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HideArema] = {
    finish_id = bo2.ePlayerFlagInt16_HideArema,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HideGuid] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HideGuid][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HideGuid,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HideGuid] = {
    finish_id = bo2.ePlayerFlagInt16_HideGuid,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HidePersonals] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HidePersonals][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HidePersonals,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HidePersonals] = {
    finish_id = bo2.ePlayerFlagInt16_HidePersonals,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HideConvene] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HideConvene][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HideConvene,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HideConvene] = {
    finish_id = bo2.ePlayerFlagInt16_HideConvene,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HideClonedBattle] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HideClonedBattle][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HideClonedBattle,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HideClonedBattle] = {
    finish_id = bo2.ePlayerFlagInt16_HideClonedBattle,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOnAddFriend] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOnAddFriend][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOnAddFriend,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOnAddFriendResult] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOnAddFriendResult][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOnAddFriendResult,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOnAddFriendResult] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOnAddFriendResult,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOnFindPersonals] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOnFindPersonals][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOnFindPersonals,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOnFindPersonals] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOnFindPersonals,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOnSearchGuild] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOnSearchGuild][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOnSearchGuild,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOnSearchGuild] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOnSearchGuild,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOnSignUpMatch] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOnSignUpMatch][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOnSignUpMatch,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOnSignUpMatch] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOnSignUpMatch,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
end
on_init_hide_quest_data()
function on_search_npc_list_item(handson_teach)
  if handson_teach == nil or handson_teach.search_npc_view == nil or sys.check(handson_teach.search_npc_view) ~= true then
    return nil
  end
  for i = 0, handson_teach.item_max do
    local item = handson_teach.search_npc_view:item_get(i)
    if sys.check(item) ~= true then
      return nil
    end
    local item_id = item.svar
    if item_id == handson_teach.check_id then
      return item
    end
  end
  return nil
end
function on_init_hide_windows_define()
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HideFriends] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    handson_teach = {
      view_type = _popup_windows_qlink,
      view = ui_handson_teach.w_handson_qlink,
      timer = ui_handson_teach.timer_qlink_handson,
      target = ui_handson_teach.w_hide_im,
      popup = L("x1"),
      margin = ui.rect(0, -20, 0, 0),
      fn = ui_handson_teach.fn_hide_window,
      fn_param = true,
      flicker = ui_handson_teach.w_flicker_im
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HideNpcSearchList] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      view_type = _popup_windows_qlink,
      view = ui_handson_teach.w_handson_qlink,
      timer = ui_handson_teach.timer_qlink_handson,
      target = ui_minimap.btn_npc_list,
      popup = L("y1"),
      fn = ui_handson_teach.fn_hide_window,
      fn_param = true
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOnNpcSearchList] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      view_type = _popup_windows_qlink,
      view = ui_handson_teach.w_handson_qlink,
      timer = ui_handson_teach.timer_qlink_handson,
      search_npc_view = ui_minimap.w_npc_list_view,
      set_topper = ui_minimap.w_npc_panel,
      on_search_target = on_search_npc_list_item,
      popup = L("y1"),
      item_max = 1,
      check_id = 79
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HideArema] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    handson_teach = {
      view_type = _popup_windows_qlink,
      view = ui_handson_teach.w_handson_qlink,
      timer = ui_handson_teach.timer_qlink_handson,
      target = ui_handson_teach.w_btn_arena,
      popup = L("x1"),
      margin = ui.rect(0, -20, 0, 0),
      fn = ui_handson_teach.fn_hide_window,
      fn_param = true,
      flicker = ui_handson_teach.w_flicker_arena
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HideGuid] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    handson_teach = {
      view_type = _popup_windows_qlink,
      view = ui_handson_teach.w_handson_qlink,
      timer = ui_handson_teach.timer_qlink_handson,
      target = ui_handson_teach.w_btn_guild,
      popup = L("x1"),
      margin = ui.rect(0, -20, 0, 0),
      fn = ui_handson_teach.fn_hide_window,
      fn_param = true,
      flicker = ui_handson_teach.w_flicker_guild
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HidePersonals] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    handson_teach = {
      view_type = _popup_windows_qlink,
      view = ui_handson_teach.w_handson_qlink,
      timer = ui_handson_teach.timer_qlink_handson,
      popup = L("x1"),
      margin = ui.rect(0, -20, 0, 0),
      fn = ui_handson_teach.fn_hide_window,
      fn_param = true,
      flicker = ui_handson_teach.w_flicker_advertise
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HideClonedBattle] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    handson_teach = {
      view_type = _popup_windows_qlink,
      view = ui_handson_teach.w_handson_qlink,
      timer = ui_handson_teach.timer_qlink_handson,
      target = ui_handson_teach.w_btn_cloned_battle,
      popup = L("x1"),
      margin = ui.rect(0, -20, 0, 0),
      fn = ui_handson_teach.fn_hide_window,
      fn_param = true,
      flicker = ui_handson_teach.w_flicker_cloned_battle
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOnAddFriend] = {
    popup_type = cPopupTypeWindows,
    handson_teach = {
      view_type = _popup_windows_common,
      view = ui_handson_teach.w_handson_common,
      timer = ui_handson_teach.timer_common_handson,
      target = ui_handson_teach.btn_im_search,
      popup = L("y1x1"),
      flicker = ui_handson_teach.flicker_im_search
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOnAddFriendResult] = {
    popup_type = cPopupTypeWindows,
    handson_teach = {
      view_type = _popup_windows_common,
      view = ui_handson_teach.w_handson_common,
      timer = ui_handson_teach.timer_common_handson,
      target = ui_handson_teach.btn_im_search_confirm,
      popup = L("y1x1"),
      flicker = ui_handson_teach.flicker_im_search_confirm
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOnFindPersonals] = {
    popup_type = cPopupTypeWindows,
    handson_teach = {
      view_type = _popup_windows_common,
      view = ui_handson_teach.w_handson_common,
      timer = ui_handson_teach.timer_common_handson,
      target_name = "advertise_want_ad",
      target_parent = ui_advertise.gx_main_win,
      popup = L("y1x1"),
      disable_flicker = true
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOnSearchGuild] = {
    popup_type = cPopupTypeWindows,
    handson_teach = {
      view_type = _popup_windows_common,
      view = ui_handson_teach.w_handson_common,
      timer = ui_handson_teach.timer_common_handson,
      target = ui_guild_mod.ui_guild_search.g_guild_applym_btn,
      popup = L("y1x1")
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOnSignUpMatch] = {
    popup_type = cPopupTypeWindows,
    handson_teach = {
      view_type = _popup_windows_common,
      view = ui_handson_teach.w_handson_common,
      timer = ui_handson_teach.timer_common_handson,
      target = ui_match.w_btn_apply_request,
      popup = L("y1x1")
    }
  }
end
function on_init_hide()
  g_hide_windows_data = {}
  on_init_hide_windows_define()
  g_hide_windows_data[bo2.ePlayerFlagInt16_HideFriends] = {
    check_idx = bo2.ePlayerFlagInt16_HideFriends,
    teach_type = cQuestTeachType_Add,
    hide_target = ui_handson_teach.w_hide_im,
    fn_param = false,
    active_level = 5,
    not_scn_id = -1,
    msg_idx = 1669
  }
  g_hide_windows_data[bo2.ePlayerFlagInt16_HideNpcSearchList] = {
    check_idx = bo2.ePlayerFlagInt16_HideNpcSearchList,
    teach_type = cQuestTeachType_Add,
    hide_target = ui_minimap.btn_npc_list,
    view_target = ui_minimap.w_npc_list_mask,
    fn_param = false,
    active_level = 6,
    scn_id = 101,
    msg_idx = 1670
  }
  g_hide_windows_data[bo2.ePlayerFlagInt16_HideArema] = {
    check_idx = bo2.ePlayerFlagInt16_HideArema,
    teach_type = cQuestTeachType_Add,
    hide_target = ui_handson_teach.w_btn_arena,
    fn_param = false,
    active_level = ui_widget.get_define_int(79),
    not_scn_id = -1,
    msg_idx = 1674,
    fn = fn_check_level_hide_window
  }
  g_hide_windows_data[bo2.ePlayerFlagInt16_HideGuid] = {
    check_idx = bo2.ePlayerFlagInt16_HideGuid,
    teach_type = cQuestTeachType_Add,
    hide_target = ui_handson_teach.w_btn_guild,
    fn_param = false,
    active_level = 20,
    not_scn_id = -1,
    msg_idx = 1673
  }
  g_hide_windows_data[bo2.ePlayerFlagInt16_HideClonedBattle] = {
    check_idx = bo2.ePlayerFlagInt16_HideClonedBattle,
    teach_type = cQuestTeachType_Add,
    hide_target = ui_handson_teach.w_btn_cloned_battle,
    fn_param = false,
    active_level = 1500,
    not_scn_id = -1,
    msg_idx = 71486
  }
end
function fn_hide_window(idx, vis)
  local hide_data = g_hide_windows_data[idx]
  if hide_data == nil then
    return
  end
  local hide_target = hide_data.hide_target
  local view_target = hide_data.view_target
  if sys.check(hide_target) ~= false then
    hide_target.visible = vis
  end
  if sys.check(view_target) ~= false then
    view_target.visible = not vis
  end
  if vis ~= false and hide_data.msg_idx ~= nil then
    local msg_text = bo2.gv_text:find(hide_data.msg_idx)
    if msg_text ~= nil then
      ui_tool.note_insert(msg_text.text)
    end
  end
end
function fn_check_level_hide_window(idx, vis)
  local hide_data = g_hide_windows_data[idx]
  if hide_data == nil then
    return
  end
  ui.log("fn_check_level_hide_window 0 %s", hide_data.active_level)
  local player = bo2.player
  if player ~= nil and player:get_atb(bo2.eAtb_Level) < hide_data.active_level then
    return
  end
  fn_hide_window(idx, vis)
end
function init_hide_window(obj)
  g_hide_atb_monitor = false
  for i, v in pairs(g_hide_windows_data) do
    if v ~= nil and v.check_idx ~= nil then
      local flag_value = obj:get_flag_int16(v.check_idx)
      if flag_value == 0 then
        if v.fn ~= nil then
          v.fn(v.check_idx, v.fn_param)
        else
          fn_hide_window(v.check_idx, v.fn_param)
        end
        g_hide_atb_monitor = true
      end
    end
  end
end
function try_to_finish_hide_window(obj, iLevel)
  local scn = bo2.scn
  if sys.check(scn) ~= true then
    return
  end
  local scn_id = scn.excel.id
  for i, v in pairs(g_hide_windows_data) do
    if v ~= nil and (v.scn_id ~= nil and scn_id == v.scn_id or v.not_scn_id ~= nil and scn_id ~= v.not_scn_id) and iLevel >= v.active_level then
      g_hide_windows_data[i].flag = true
      ui_handson_teach.on_teach_quest(v.check_idx, v.teach_type)
    end
  end
end
