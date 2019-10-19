_popup_windows_common = 1
_popup_windows_qlink = 2
_popup_windows_item = 3
_popup_windows_common2 = 4
cs_tip_newline = SHARED("\n")
c_flicker_uri = L("$gui/frame/help/tool_handson.xml")
c_flicker_style = L("tool_handson_flicker")
ciMBLevel = 50
local g_quest_flicker_target
local g_skill_next = false
function hs_get_quest_ms(quest_id)
  if ui.quest_find_c(quest_id) then
    return nil
  end
  local quest_info = ui.quest_find(quest_id)
  if quest_info ~= nil then
    return quest_info.mstone_id
  end
end
function in_select_career_quest()
  local ms_count = 0
  for i = 10007, 10013 do
    local c_ms = 80386 + ms_count
    ms_count = ms_count + 1
    local ms = hs_get_quest_ms(i)
    if ms ~= nil and ms == c_ms then
      return true
    end
  end
  return false
end
function on_init_open_windows()
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_FastMove] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOnPickupPrize,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
end
function group_check()
  local player = bo2.player
  if player == nil then
    return false
  end
  local info = ui.member_find(player.only_id)
  if info ~= nil then
    ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_Group)
    return false
  end
  return true
end
function timer_levelup_check()
  if sys.check(ui_portrait.w_leveluop_flick) ~= true or ui_portrait.w_leveluop_flick.visible == false then
    return false
  end
  local iLevel = ui.safe_get_atb(bo2.eAtb_Level)
  if iLevel >= 10 and iLevel < 15 then
    local obj = bo2.player
    if sys.check(obj) ~= true then
      return false
    end
    local player_career = obj:get_atb(bo2.eAtb_Cha_Profession)
    local mb_self = bo2.gv_profession_list:find(player_career)
    if sys.check(mb_self) ~= true then
      return false
    end
    local c_size = bo2.gv_profession_list.size
    for i = 0, c_size - 1 do
      local excel = bo2.gv_profession_list:get(i)
      if sys.check(excel) and excel.career == mb_self.career then
        if excel.id == mb_self.id then
          return false
        else
          return true
        end
      end
    end
    return true
  end
  return false
end
function on_levelup_vis(w, vis)
  if vis and timer_levelup_check() then
    local iExcelId = bo2.ePlayerFlagInt16_HandsOn_LevelUp - bo2.ePlayerFlagInt16_HandsOn
    local pExcel = bo2.gv_handson_teach:find(iExcelId)
    if pExcel == nil then
      return
    end
    PopupHandsOnTips(bo2.ePlayerFlagInt16_HandsOn_LevelUp, pExcel)
  end
end
function get_talk_text(id)
  if g_handson_quest_mb == nil then
    return nil
  end
  local mb_data = g_handson_quest_mb:find(id)
  if sys.check(mb_data) ~= true then
    return nil
  end
  return mb_data.popo_text
end
function on_get_quest_talk_item(target)
  if sys.check(target) ~= true then
    return nil
  end
  return target.parent
end
function on_get_quest_trace_margin(handson_teach, target)
  if sys.check(handson_teach.search_list) ~= true or handson_teach.skill_id == 0 then
    return handson_teach.margin
  end
  local size = handson_teach.search_list.item_count
  for i = 0, size - 1 do
    local item = handson_teach.search_list:item_get(i)
    if sys.check(item) ~= false then
      local target_item = item:search(handson_teach.target_name)
      if sys.check(target_item) ~= false and handson_teach.skill_id ~= 0 and handson_teach.active_skill ~= nil then
        local skill_id = target_item.var:get(packet.key.skill_id).v_int
        if skill_id ~= 0 and skill_id == handson_teach.skill_id then
          return nil
        end
      end
    end
  end
  return handson_teach.margin
end
function on_get_quest_trace_target(handson, target)
  if sys.check(target) ~= true then
    return nil
  end
  local scn_id = handson.mark_scn_id
  local link_scn_id = handson.mark_link_scn_id
  local scn = bo2.scn
  local c_scn_id = 0
  if sys.check(scn) and sys.check(scn.excel) then
    c_scn_id = scn.excel.id
  end
  if (c_scn_id == 0 or scn_id ~= c_scn_id) and handson.skill_id ~= 0 and handson.active_skill ~= 0 then
    local skill_id = target.var:get(packet.key.skill_id).v_int
    if skill_id ~= 0 and skill_id == handson.skill_id then
      local skill_info = ui.skill_find(skill_id)
      if sys.check(skill_info) and 0 >= skill_info.cooldown then
        return target:search(L("useskill"))
      else
        return nil
      end
    end
  end
  local var_id = target.var:get(packet.key.ui_text_id)
  local size = var_id.size - 1
  local check_mark_id = handson.mark_id
  if c_scn_id ~= 0 and scn_id ~= c_scn_id and link_scn_id == c_scn_id then
    check_mark_id = handson.linked_mark_id
  end
  for i = 0, size do
    local n, data = var_id:fetch_nv(i)
    if data.v_int == check_mark_id then
      local p_target_name = sys.format(L("h_m%d"), i)
      local p_target = target:search(p_target_name)
      if sys.check(p_target) then
        return p_target.parent:search(L("mark"))
      else
        return target:search(L("mark"))
      end
    end
  end
  return nil
end
function on_finish_quest_mb_by_mark_id(mark_id, link_id)
  if g_quest_data == nil then
    return
  end
  local idx = g_teaching_quest_trace[mark_id]
  if idx == nil then
    if link_id ~= nil then
      idx = g_teaching_quest_trace[link_id]
    end
    if idx == nil then
      return
    end
  end
  local quest_data = g_quest_data[idx]
  if quest_data == nil or quest_data.init == false then
    return
  end
  quest_data.init = false
  quest_data.handson_teach.flicker = nil
  g_quest_flicker_target = nil
  w_handson_flicker0.visible = false
  on_finish_windows(quest_data)
end
function disable_all_quest_trace()
  local bFound = false
  for i, v in pairs(g_teaching_quest_trace) do
    local quest_data = g_quest_data[v]
    if quest_data ~= nil and quest_data.init ~= false then
      quest_data.init = false
      if bFound == false then
        bFound = true
        on_finish_windows(quest_data)
      end
    end
  end
  g_teaching_quest_trace = {}
end
function on_active_quest_trace(milestone_id)
  on_jump_teach_milestone(milestone_id)
  if g_quest_trace_data == nil or g_quest_data == nil then
    return
  end
  local idx = g_quest_trace_data[milestone_id]
  if idx == nil then
    return
  end
  disable_all_quest_trace()
  local quest_data = g_quest_data[idx]
  if quest_data == nil or quest_data.init == true then
    return
  end
  local mark_id = quest_data.handson_teach.mark_id
  g_teaching_quest_trace[mark_id] = idx
  quest_data.init = true
  on_popup_windows(quest_data, nil, nil, quest_data.handson_teach.make_text_id)
end
function check_teaching_quest(_teaching_quest_talk)
  if _teaching_quest_talk == nil or _teaching_quest_talk.valid == false or _teaching_quest_talk.index < 0 then
    return false
  end
  return true
end
function on_init_talk()
  on_close_talk()
end
function on_close_talk()
  if check_teaching_quest(g_teaching_quest_talk) ~= true then
    return
  end
  local index = g_teaching_quest_talk.index
  reset_teaching_quest_talk()
  if g_quest_data == nil or g_quest_data[index] == nil then
    return
  end
  on_finish_windows(g_quest_data[index])
end
function on_active_quest_talk(talk_id)
  if g_teaching_quest_talk == nil or g_quest_talk_data == nil then
    return nil
  end
  if g_teaching_quest_talk.valid ~= false or g_teaching_quest_talk.index > 0 then
    return nil
  end
  local idx = g_quest_talk_data[talk_id]
  if idx == nil then
    return nil
  end
  local quest_data = g_quest_data[idx]
  if quest_data == nil or quest_data.handson_teach == nil or quest_data.handson_teach.target_name == nil then
    return nil
  end
  if talk_id == 127 and in_select_career_quest() ~= true then
    return nil
  end
  if quest_data.handson_teach.on_active_id ~= nil and quest_data.handson_teach.on_active_id ~= 0 then
    ui_handson_teach.on_finish_teach_quest(quest_data.handson_teach.on_active_id)
  end
  g_teaching_quest_talk.valid = true
  g_teaching_quest_talk.index = idx
  on_popup_windows(quest_data, nil, nil, quest_data.handson_teach.make_text_id)
  return quest_data.handson_teach.target_name
end
function on_set_npc_talk(scn, obj, quest_scn)
  if quest_scn == nil then
    return
  end
  for i, v_data in pairs(quest_scn.data) do
    ui_handson_teach.on_teach_quest(v_data.flag, v_data.add_type)
  end
end
function on_mb_quest_scn_in()
  if g_quest_scn == nil then
    return
  end
  local scn = bo2.scn
  if sys.check(scn) ~= true then
    return
  end
  local scn_id = scn.excel.id
  local quest_scn = g_quest_scn[scn_id]
  if quest_scn == nil then
    return
  end
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return
  end
  if quest_scn.on_npc_talk ~= nil then
    quest_scn.on_npc_talk(scn, obj, quest_scn)
  end
end
function on_check_temp_skill_enable(theme, id)
  local index = theme.active_page.index
  if g_quest_data == nil or g_quest_data[index] == nil then
    return false
  end
  if g_quest_data[index].check_id ~= id then
    return false
  end
  return true
end
function on_active_next(quest_data)
  if quest_data == nil or quest_data.handson_teach == nil then
    return
  end
  local next_idx = quest_data.handson_teach.next
  local _quest_data = g_quest_data[next_idx]
  if _quest_data == nil or _quest_data.handson_teach == nil then
    return nil
  end
  local theme_id = _quest_data.handson_teach.theme_id
  local theme = g_theme[theme_id]
  if theme == nil then
    return
  end
  on_theme_visible(theme, _quest_data.handson_teach.active_id, true)
end
function reset_theme(theme)
  theme.reset()
  theme.active_page.valid = false
  theme.active_page.index = -1
end
function on_theme_visible(theme, id, vis, disable_check)
  if vis then
    if sys.check(theme) ~= true or theme.page == nil then
      return nil
    end
    local idx = theme.page[id]
    if idx == nil then
      if theme.on_faild ~= nil then
        theme.on_faild(theme, idx)
      end
      return nil
    end
    if theme.on_found ~= nil then
      theme.on_found(theme, idx)
      return 1
    end
    local quest_data = g_quest_data[idx]
    if quest_data == nil or quest_data.handson_teach == nil then
      return nil
    end
    theme.active_page.valid = true
    theme.active_page.index = idx
    on_popup_windows(quest_data, nil, nil, quest_data.handson_teach.make_text_id)
    return 1
  else
    if sys.check(theme) ~= true or theme.active_page == nil or check_teaching_quest(theme.active_page) ~= true then
      return nil
    end
    if disable_check ~= nil and theme.check ~= nil and theme.check(theme, id) ~= true then
      return nil
    end
    local index = theme.active_page.index
    reset_theme(theme)
    if g_quest_data == nil or g_quest_data[index] == nil then
      return nil
    end
    on_finish_windows(g_quest_data[index])
    if theme.on_finish_data ~= nil then
      theme.on_finish_data(g_quest_data[index])
    end
    return 1
  end
end
function on_talk_page_visible(talk_id, vis)
  local theme = g_theme[3]
  if theme == nil or theme.page == nil or g_quest_data == nil then
    return
  end
  on_theme_visible(theme, talk_id, vis)
end
function on_vis_box_popo(vis, id)
  local theme = g_theme[9]
  if theme == nil or theme.page == nil or g_quest_data == nil then
    return
  end
  on_theme_visible(theme, id, vis)
end
function on_add_zhuama_sysshortcut(id, vis)
  local theme = g_theme[11]
  if theme == nil or theme.page == nil or g_quest_data == nil then
    return
  end
  on_theme_visible(theme, id, vis)
end
function on_vis_item_popo(vis, id)
  local theme
  if vis == false then
    theme = g_theme[17]
    on_theme_visible(theme, id, false)
    if id == 10004 then
      ui_zdteach.zhuama_popo()
    end
  end
end
function on_vis_personal_page(vis)
  local theme
  if vis == true then
    theme = g_theme[9]
  else
    theme = g_theme[10]
  end
  if theme == nil or theme.page == nil or g_quest_data == nil then
    return
  end
  on_theme_visible(theme, skill_id, false)
end
function on_temp_skill_visible(skill_id, vis, disable_check)
  local function on_vis_skill(id)
    if g_theme == nil then
      return
    end
    local theme = g_theme[id]
    if theme == nil or theme.page == nil or g_quest_data == nil then
      return
    end
    on_theme_visible(theme, skill_id, vis, disable_check)
  end
  on_vis_skill(4)
  if vis then
    on_vis_skill(9)
    local function on_time0()
      on_vis_skill(25)
    end
    bo2.AddTimeEvent(5, on_time0)
  end
end
function on_search_main_skill(handson_teach)
  if sys.check(handson_teach.search_skill) ~= true then
    return nil
  end
  local name = sys.format("%d", handson_teach.check_id)
  local shortcut = handson_teach.search_skill:search(name)
  return shortcut
end
function on_search_temp_sysshortcut(handson_teach)
  if sys.check(handson_teach.search_skill) ~= true then
    return nil
  end
  if handson_teach.check_id == 135028 and g_skill_next == false then
    return nil
  end
  for i = 0, 9 do
    local info = ui.shortcut_get(1050 + i)
    if info ~= nil then
      local excel = info.excel
      local kind = info.kind
      if kind == bo2.eShortcut_Skill and sys.check(excel) and handson_teach.check_id == excel.id then
        local name = sys.format(L("%d"), i)
        local item = handson_teach.search_skill:search(name)
        return item
      end
    end
  end
  return nil
end
function on_search_temp_skill(handson_teach)
  if sys.check(handson_teach.search_skill) ~= true then
    return nil
  end
  for i = 0, 3 do
    local info = ui.shortcut_get(58 + i)
    if info ~= nil then
      local excel = info.excel
      local kind = info.kind
      if kind == bo2.eShortcut_Skill and sys.check(excel) and handson_teach.check_id == excel.id then
        local name = sys.format(L("%d"), i)
        return handson_teach.search_skill:search(name)
      end
    end
  end
  return nil
end
function is_in_mstone(quest_id, milestone_id)
  if ui.quest_find_c(quest_id) then
    return false
  end
  local quest_info = ui.quest_find(quest_id)
  if quest_info ~= nil and quest_info.mstone_id == milestone_id then
    return true
  end
  return false
end
function on_search_identifyable_equip(handson_teach)
  for i, v in pairs(ui_item.g_boxs) do
    for j, k in pairs(v.cells) do
      if k.card.info then
        local info = k.card.info
        local src_excel = ui.item_get_excel(ui_handson_teach.g_ei_item_id)
        if src_excel.use_par and src_excel.use_par[0] >= info.excel.reqlevel and info:identify_finished() == false then
          return k.card
        end
      end
    end
  end
  return nil
end
function on_found_leave_btn()
  ui_minimap.set_leave_help_visible(true, true)
end
function on_finish_npc_milestone(theme, idx)
  if theme.active_page == nil or check_teaching_quest(theme.active_page) ~= true then
    return nil
  end
  local idx = theme.active_page.index
  local h = theme.active_page.h
  reset_theme(theme)
  local quest_data = g_quest_data[idx]
  if quest_data == nil or h == nil then
    return false
  end
  local scn = bo2.scn
  if sys.check(scn) ~= true or scn.excel.id ~= quest_data.scn_excel_id then
    return nil
  end
  scn:UnValidNpcHandsonTips(h)
end
function on_found_npc_milestone(theme, idx)
  local quest_data = g_quest_data[idx]
  if quest_data == nil then
    return false
  end
  local scn = bo2.scn
  if sys.check(scn) ~= true or scn.excel.id ~= quest_data.scn_excel_id then
    return nil
  end
  local _handson_teach_text = sys.format(L("<handson:0,4,0,%d>"), idx)
  local iHandle = scn:SetNpcHandsonTips(quest_data.npc_excel_id, _handson_teach_text)
  theme.active_page.valid = true
  theme.active_page.index = idx
  theme.active_page.h = iHandle
  if (quest_data.npc_excel_id == 25388 or quest_data.next_data ~= 0) and sys.check(bo2.player) then
    do
      local sig_name = L("ui_handson_teach:on_tips_target")
      local obj = bo2.player
      local function on_target_disable_npc_tip(new_obj)
        if new_obj ~= obj or sys.check(obj) ~= true then
          return
        end
        local target_handle = obj.target_handle
        if target_handle == iHandle then
          scn:UnValidNpcHandsonTips(target_handle)
          obj:remove_on_scnmsg(bo2.scnmsg_set_target, sig_name)
          if quest_data.next_data == 102 then
            g_skill_next = true
          end
        end
      end
      obj:insert_on_scnmsg(bo2.scnmsg_set_target, on_target_disable_npc_tip, sig_name)
    end
  end
  return 1
end
function on_theme_quest_award(quest_id, vis)
  if g_theme == nil then
    return
  end
  on_theme_visible(g_theme[8], quest_id, vis)
  if vis == true then
    on_theme_visible(g_theme[20], quest_id, vis)
  end
end
function on_theme_milestone_vis(milestone_id)
  if g_theme == nil then
    return
  end
  local on_fun = function(run_id, milestone_id)
    local theme = g_theme[run_id]
    if theme == nil or theme.page == nil or g_quest_data == nil then
      return nil
    end
    return on_theme_visible(theme, milestone_id, true)
  end
  local run_table = {
    5,
    6,
    19,
    22
  }
  for i, v in pairs(run_table) do
    on_fun(v, milestone_id)
  end
end
function on_skill_active_use()
  if g_skill_use == nil or g_quest_data == nil then
    return
  end
  local player = bo2.player
  if sys.check(player) ~= true then
    return
  end
  for i, v in pairs(g_skill_use) do
    do
      local quest_data = g_quest_data[v]
      if quest_data == nil or quest_data.handson_teach == nil then
        return
      end
      local info = ui.shortcut_get(i)
      if info ~= nil and info.kind == bo2.eShortcut_Skill then
        on_popup_windows(quest_data, nil, nil, quest_data.handson_teach.make_text_id)
        do
          local fight_name = L("ui_handson_teach:on_skill_active_use")
          local function on_fight_state(obj, ft, idx)
            local val = obj:get_flag_objmem(idx)
            if val == 0 then
              on_finish_windows(quest_data)
              obj:remove_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_FightState, fight_name)
            end
          end
          player:insert_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_FightState, on_fight_state, fight_name)
          return true
        end
      end
    end
  end
end
function on_search_award_item(handson_teach)
  if sys.check(handson_teach.search_view_list) ~= true then
    return nil
  end
  local item = handson_teach.search_view_list:item_get(1)
  if sys.check(item) ~= true then
    return nil
  end
  for i = 0, 3 do
    local panel = item:search(sys.format("panel_%d", i + 1))
    if sys.check(panel) ~= true then
      return nil
    end
    local card = panel:search("card")
    if sys.check(card) ~= true or card.excel_id == 0 then
      return nil
    end
    local player = bo2.player
    if sys.check(player) ~= true then
      return nil
    end
    local cha_obj = player:get_atb(bo2.eAtb_Cha_Profession)
    if cha_obj == 0 then
      return nil
    end
    local excel = bo2.gv_equip_item:find(card.excel_id)
    if excel ~= nil then
      local req_size = excel.requires.size
      for i = 1, req_size - 1, 2 do
        local req_obj = excel.requires[i - 1]
        if req_obj == bo2.eItemReq_Profession then
          local req_value = excel.requires[i]
          if req_value == cha_obj then
            return card
          end
        end
      end
    end
  end
  return nil
end
function on_add_sysshortcut(id)
  local theme = g_theme[11]
  if theme == nil or theme.page == nil or g_quest_data == nil then
    return
  end
  if id ~= ui_zdteach.zhuama_skill_id then
    on_theme_visible(theme, id, true)
  end
end
function runf_sysshortcut(id)
  local v_id = id.v_int
  on_add_sysshortcut(v_id)
end
function on_init_quest_mb_help_data()
  on_init_mb_quest_help()
  if g_handson_quest_mb == nil then
    return
  end
  local player = bo2.player
  if sys.check(player) ~= true or player:get_atb(eAtb_Level) > ciMBLevel then
    return
  end
  local mb_excel_size = g_handson_quest_mb.size
  for i = 0, mb_excel_size - 1 do
    local mb_excel = g_handson_quest_mb:get(i)
    if mb_excel.popo_type == 0 then
      g_quest_trace_data[mb_excel.milestone_id] = mb_excel.id
      if mb_excel.quest_id ~= 0 then
        g_update_milestone_data[mb_excel.milestone_id] = mb_excel.id
      end
      local mark_list = bo2.gv_mark_list:find(mb_excel.mark_id)
      local mark_linked_list = bo2.gv_mark_list:find(mb_excel.next_data)
      local scn_id = 0
      local link_scn_id = 0
      if sys.check(mark_list) then
        scn_id = mark_list.scn_id
      end
      if sys.check(mark_linked_list) then
        link_scn_id = mark_linked_list.scn_id
      end
      g_quest_data[mb_excel.id] = {
        popup_type = cPopupTypeWindows,
        init = false,
        handson_teach = {
          view_type = _popup_windows_common,
          view = ui_handson_teach.w_handson_common,
          timer = ui_handson_teach.timer_common_handson,
          search_list = ui_quest.ui_tracing.w_tracing_list,
          get_target_item = on_get_quest_trace_target,
          target_name = L("m_aim_box_1"),
          on_show = ui_handson_teach.on_show_quest_traceing_windows,
          popup = mb_excel.popup,
          mark_id = mb_excel.mark_id,
          linked_mark_id = mb_excel.next_data,
          mark_scn_id = scn_id,
          mark_link_scn_id = link_scn_id,
          make_text_id = mb_excel.id,
          skill_id = mb_excel.quest_id,
          get_margin = on_get_quest_trace_margin,
          new_flicker = true
        }
      }
      if mb_excel.text_margin.size == 4 then
        g_quest_data[mb_excel.id].handson_teach.margin = ui.rect(-mb_excel.text_margin[0], -mb_excel.text_margin[1], mb_excel.text_margin[2], mb_excel.text_margin[3])
      end
    elseif mb_excel.popo_type == 1 then
      local id = mb_excel.id
      g_quest_talk_data[mb_excel.milestone_id] = id
      g_quest_data[id] = {
        popup_type = cPopupTypeWindows,
        popo_type = 5,
        handson_teach = {
          view_type = _popup_windows_common2,
          view = ui_handson_teach.w_view_handson_common,
          timer = ui_handson_teach.timer_common_handson2,
          target_parent = ui_npcfunc.ui_talk.w_view,
          on_active_id = mb_excel.quest_id,
          disable_flicker = true,
          set_topper = ui_npcfunc.ui_talk.w_talk,
          target_name = sys.format(L("handson_talk_%d"), id),
          get_target_item = on_get_quest_talk_item,
          popup = mb_excel.popup,
          make_text_id = id
        }
      }
      if mb_excel.text_margin.size == 4 then
        g_quest_data[id].handson_teach.margin = ui.rect(-mb_excel.text_margin[0], -mb_excel.text_margin[1], mb_excel.text_margin[2], mb_excel.text_margin[3])
      end
    elseif mb_excel.popo_type == 2 then
      if mb_excel.quest_id ~= 0 then
        local scn_id = mb_excel.mark_id
        local milestone_id = mb_excel.milestone_id
        local quest_id = mb_excel.quest_id
        if g_quest_scn[scn_id] == nil then
          g_quest_scn[scn_id] = {
            on_npc_talk = on_set_npc_talk,
            data = {}
          }
        end
        local add_theme = cQuestTeachType_Add
        local insert_data = {
          flag = mb_excel.quest_id,
          add_type = add_theme
        }
        table.insert(g_quest_scn[scn_id].data, insert_data)
        g_handsonhelp_data[quest_id] = {
          popup_type = cPopupTypeNpcTips,
          scn_excel_id = scn_id,
          npc_excel_id = milestone_id
        }
        g_handsonhelp_quest[quest_id] = {}
        g_handsonhelp_quest[quest_id][add_theme] = {
          active_idx = quest_id,
          active_case = bo2.ActiveHandsOnTeach_CaseQuest,
          flag = false
        }
      end
    elseif mb_excel.popo_type == 3 then
      local id = mb_excel.id
      g_quest_talk_page[mb_excel.milestone_id] = id
      g_quest_data[id] = {
        popup_type = cPopupTypeWindows,
        handson_teach = {
          view_type = _popup_windows_common,
          view = ui_handson_teach.w_handson_common,
          timer = ui_handson_teach.timer_common_handson,
          target = ui_quest.ui_quest_talk.w_next_btn,
          disable_flicker = true,
          popup = mb_excel.popup,
          make_text_id = id
        }
      }
    elseif mb_excel.popo_type == 4 then
      local id = mb_excel.id
      g_temp_new_skill[mb_excel.milestone_id] = id
      g_quest_data[id] = {
        popup_type = cPopupTypeWindows,
        check_id = mb_excel.milestone_id,
        handson_teach = {
          view_type = _popup_windows_common2,
          view = ui_handson_teach.w_view_handson_common,
          timer = ui_handson_teach.timer_common_handson2,
          disable_flicker = true,
          on_search_target = on_search_temp_skill,
          search_skill = ui_tempshortcut.ui_tempshortcut.skill_slot,
          check_id = mb_excel.milestone_id,
          popup = mb_excel.popup,
          make_text_id = id
        }
      }
    elseif mb_excel.popo_type == 5 then
      local id = mb_excel.id
      g_leave_scene[mb_excel.milestone_id] = id
      g_quest_data[id] = {popup_type = cPopupTypeWindows}
    elseif mb_excel.popo_type == 6 then
      local id = mb_excel.id
      local milestone_id = mb_excel.milestone_id
      local scn_id = mb_excel.mark_id
      local quest_id = mb_excel.quest_id
      g_milestone_notify_npc[milestone_id] = id
      g_quest_data[id] = {
        scn_excel_id = scn_id,
        npc_excel_id = quest_id,
        next_data = mb_excel.next_data
      }
    elseif mb_excel.popo_type == 7 then
      local id = mb_excel.id
      g_skill_use[mb_excel.milestone_id] = id
      g_quest_data[id] = {
        popup_type = cPopupTypeWindows,
        check_id = mb_excel.milestone_id,
        handson_teach = {
          view_type = _popup_windows_common2,
          view = ui_handson_teach.w_view_handson_common,
          timer = ui_handson_teach.timer_common_handson2,
          disable_flicker = true,
          on_search_target = on_search_main_skill,
          search_skill = ui_shortcut.w_shortcut,
          set_topper = ui_shortcut.w_shortcut,
          priority = 500,
          check_id = mb_excel.milestone_id,
          popup = mb_excel.popup,
          make_text_id = id
        }
      }
    elseif mb_excel.popo_type == 8 then
      local id = mb_excel.id
      g_award_item_select[mb_excel.milestone_id] = id
      g_quest_data[id] = {
        popup_type = cPopupTypeWindows,
        popo_type = 5,
        check_id = mb_excel.milestone_id,
        handson_teach = {
          view_type = _popup_windows_common2,
          view = ui_handson_teach.w_view_handson_common,
          timer = ui_handson_teach.timer_common_handson2,
          disable_flicker = true,
          on_search_target = on_search_award_item,
          search_view_list = ui_quest.ui_complete.w_select_rewards_list,
          set_topper = ui_quest.ui_complete.w_complete,
          check_id = mb_excel.milestone_id,
          popup = mb_excel.popup,
          make_text_id = id,
          margin = ui.rect(10, 0, 0, 0)
        }
      }
    elseif mb_excel.popo_type == 9 then
      local id = mb_excel.id
      local add_skill_id = mb_excel.milestone_id
      g_qlink_skill[add_skill_id] = id
      g_quest_data[id] = {
        popup_type = cPopupTypeWindows,
        popo_type = 6,
        handson_teach = {
          view_type = _popup_windows_qlink,
          view = ui_handson_teach.w_handson_qlink,
          timer = ui_handson_teach.timer_qlink_handson,
          disable_flicker = true,
          target = ui_qbar.w_btn_personal,
          check_id = add_skill_id,
          popup = mb_excel.popup,
          make_text_id = id,
          next = mb_excel.next_data
        }
      }
    elseif mb_excel.popo_type == 10 then
      local id = mb_excel.id
      g_personal_search[id] = id
      g_quest_data[id] = {
        popup_type = cPopupTypeWindows,
        handson_teach = {
          view_type = _popup_windows_common,
          view = ui_handson_teach.w_handson_common,
          timer = ui_handson_teach.timer_common_handson,
          disable_flicker = true,
          target = ui_handson_teach.btn_equip_wq,
          popup = mb_excel.popup,
          make_text_id = id,
          theme_id = mb_excel.popo_type,
          active_id = id
        }
      }
    elseif mb_excel.popo_type == 11 then
      local id = mb_excel.id
      local add_skill_id = mb_excel.milestone_id
      g_temp_sysshortcut[add_skill_id] = id
      g_quest_data[id] = {
        popup_type = cPopupTypeWindows,
        check_id = mb_excel.milestone_id,
        handson_teach = {
          view_type = _popup_windows_common2,
          view = ui_handson_teach.w_view_handson_common,
          timer = ui_handson_teach.timer_common_handson2,
          disable_flicker = true,
          on_search_target = on_search_temp_sysshortcut,
          search_skill = ui_temp_bar.gx_win,
          set_topper = ui_temp_bar.gx_win,
          check_id = mb_excel.milestone_id,
          popup = mb_excel.popup,
          make_text_id = id
        }
      }
    elseif mb_excel.popo_type == 12 then
      local id = mb_excel.id
      local npc_id = mb_excel.milestone_id
      g_target_protrait[npc_id] = id
      g_quest_data[id] = {
        popup_type = cPopupTypeWindows,
        popo_type = 5,
        check_id = mb_excel.milestone_id,
        handson_teach = {
          view_type = _popup_windows_common2,
          view = ui_handson_teach.w_view_handson_common,
          timer = ui_handson_teach.timer_common_handson2,
          disable_flicker = true,
          on_visible_check = on_visible_check_quest,
          target = ui_portrait.w_target_icon,
          set_topper = ui_portrait.w_target_show,
          check_id = mb_excel.quest_id,
          popup = mb_excel.popup,
          make_text_id = id
        }
      }
    elseif mb_excel.popo_type == 13 then
      local id = mb_excel.id
      g_quest_talk_data[mb_excel.milestone_id] = id
      g_quest_data[id] = {
        popup_type = cPopupTypeWindows,
        popo_type = 5,
        handson_teach = {
          view_type = _popup_windows_common2,
          view = ui_handson_teach.w_view_handson_common,
          timer = ui_handson_teach.timer_common_handson2,
          target_parent = ui_npcfunc.ui_talk.w_view,
          disable_flicker = true,
          set_topper = ui_npcfunc.ui_talk.w_talk,
          on_visible_check = on_visible_check_quest,
          check_id = mb_excel.quest_id,
          target_name = sys.format(L("handson_talk_%d"), id),
          get_target_item = on_get_quest_talk_item,
          popup = mb_excel.popup,
          make_text_id = id
        }
      }
      if mb_excel.text_margin.size == 4 then
        g_quest_data[id].handson_teach.margin = ui.rect(-mb_excel.text_margin[0], -mb_excel.text_margin[1], mb_excel.text_margin[2], mb_excel.text_margin[3])
      end
    elseif mb_excel.popo_type == 14 then
      local id = mb_excel.id
      local scn_id = mb_excel.milestone_id
      local npc_id = mb_excel.quest_id
      g_scn_notify_npc[scn_id] = id
      g_quest_data[id] = {scn_excel_id = scn_id, npc_excel_id = npc_id}
    elseif mb_excel.popo_type == 16 then
      local id = mb_excel.id
      local add_skill_id = mb_excel.milestone_id
      g_qlink_skill[add_skill_id] = id
      g_quest_data[id] = {
        popup_type = cPopupTypeWindows,
        popo_type = 6,
        handson_teach = {
          view_type = _popup_windows_qlink,
          view = ui_handson_teach.w_handson_qlink,
          timer = ui_handson_teach.timer_qlink_handson,
          disable_flicker = true,
          target = ui_qbar.w_btn_item,
          check_id = add_skill_id,
          popup = mb_excel.popup,
          make_text_id = id,
          next = mb_excel.next_data
        }
      }
    elseif mb_excel.popo_type == 17 then
      local id = mb_excel.id
      local add_id = mb_excel.milestone_id
      g_item_box[add_id] = id
      g_quest_data[id] = {
        popup_type = cPopupTypeWindows,
        popo_type = 6,
        handson_teach = {
          view_type = _popup_windows_common,
          view = ui_handson_teach.w_handson_common,
          timer = ui_handson_teach.timer_common_handson,
          disable_flicker = true,
          search_target_id = add_id,
          on_search_target = find_card_by_item_id,
          popup = mb_excel.popup,
          make_text_id = id,
          theme_id = mb_excel.popo_type,
          active_id = add_id,
          margin = ui.rect(0, -20, 0, 0),
          next = mb_excel.next_data
        }
      }
      if mb_excel.text_margin.size == 4 then
        g_quest_data[id].handson_teach.margin = ui.rect(-mb_excel.text_margin[0], -mb_excel.text_margin[1], mb_excel.text_margin[2], mb_excel.text_margin[3])
      end
    else
      init_beta_data(mb_excel)
    end
  end
  local on_reset = function()
  end
  g_theme = {}
  g_theme[3] = {
    page = g_quest_talk_page,
    active_page = g_teaching_quest_talk_page,
    reset = reset_teaching_quest_talk_page
  }
  g_theme[4] = {
    page = g_temp_new_skill,
    active_page = g_teaching_temp_new_skill,
    reset = reset_teaching_quest_new_skill,
    check = on_check_temp_skill_enable
  }
  g_theme[5] = {page = g_leave_scene, on_found = on_found_leave_btn}
  g_theme[6] = {
    page = g_milestone_notify_npc,
    on_faild = on_finish_npc_milestone,
    on_found = on_found_npc_milestone,
    active_page = g_teaching_milestone_notify_npc,
    reset = reset_teaching_quest_milestone_notify_npc
  }
  g_theme[7] = {
    page = g_skill_use,
    active_page = g_teaching_skill_use,
    reset = reset_teaching_skill_use
  }
  g_theme[8] = {
    page = g_award_item_select,
    active_page = g_teaching_award_item_select,
    reset = reset_teaching_award_item_select
  }
  g_theme[9] = {
    page = g_qlink_skill,
    active_page = g_teaching_qlink_skill,
    reset = reset_teaching_qlink_skill,
    on_finish_data = on_active_next
  }
  g_theme[10] = {
    page = g_personal_search,
    active_page = g_teaching_personal_search,
    reset = reset_teaching_personal_search
  }
  g_theme[11] = {
    page = g_temp_sysshortcut,
    active_page = g_teaching_temp_sysshortcut,
    reset = reset_teaching_sysshortcut,
    check = on_check_temp_skill_enable
  }
  reset_theme(g_theme[11])
  g_theme[17] = {
    page = g_item_box,
    active_page = g_item_box_search,
    reset = reset_item_box_search,
    on_finish_data = on_active_next
  }
  fill_beta_data()
  g_skill_next = false
end
function open_wasd(vis)
  if vis == true then
    ui_zdteach.handle_open_ui()
  end
end
function close_wasd(vis)
  if vis == true then
    ui_zdteach.handle_close_ui()
  end
end
function find_other_skill_by_id(hands)
  for i = 1, 15 do
    local item = ui_skill.w_qita:search("skill" .. i)
    if item ~= nil and item:search("skill_card").excel_id == hands.search_target_id then
      return item:search("flicker_handson")
    end
  end
  return nil
end
function find_card_by_item_id(hands)
  for i, v in pairs(ui_item.g_boxs) do
    for j, k in pairs(v.cells) do
      if k.card.info then
        local info = k.card.info
        if info ~= nil and info.excel_id == hands.search_target_id then
          return k.card
        end
      end
    end
  end
end
function find_hp_item()
  local g_index = {}
  table.insert(g_index, {_begin = 10, _end = 21})
  table.insert(g_index, {_begin = 30, _end = 41})
  for i, v in pairs(g_index) do
    for idx = v._begin, v._end do
      local info = ui.shortcut_get(idx)
      if sys.check(info) and sys.check(info.excel) and info.kind == bo2.eShortcut_Item and info.excel.id == 53301 then
        local idx_name = sys.format(L("%d"), idx)
        local found = ui_shortcut.w_shortcut:search(idx_name)
        return found
      end
    end
  end
  return nil
end
function on_init_popup_windows()
  g_handson_popup_common = nil
  g_handson_popup_common2 = nil
  g_handson_popup_qlink = nil
  g_handson_popup_item = nil
  on_init_quest_mb_help_data()
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_NpcTalkSelItem] = {
    popup_type = cPopupTypeWindows,
    popo_type = 5,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_npcfunc.ui_talk.w_view,
      popup = L("y1x1"),
      disable_flicker = true,
      set_topper = ui_npcfunc.ui_talk.w_talk,
      margin = ui.rect(-50, -150, 0, 0),
      popup_function = close_wasd
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_FastMove] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_handson_teach.pic_ctrl_teach,
      popup_function = ui_handson_teach.on_test_complate_ctrl_teach,
      popup = L("x1"),
      disable_flicker = true
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_LevelUp] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_portrait.w_leveluop_flick,
      popup = L("y1"),
      disable_flicker = true,
      set_topper = ui_qbar.w_qbar,
      timer_check = ui_handson_teach.timer_levelup_check
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Group] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_portrait.w_group_btn_pic,
      popup = L("y1"),
      disable_flicker = true,
      set_topper = ui_qbar.w_qbar,
      timer_check = ui_handson_teach.group_check
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_MiddleMouseClick] = {
    popup_type = cPopupTypeWindows,
    handson_teach = {
      view_type = _popup_windows_item,
      view = ui_handson_teach.w_handson_item,
      timer = ui_handson_teach.timer_item_handson,
      search_target = ui_item.w_item,
      search_box = ui_item.g_boxs,
      search_id_begin = 2002,
      search_id_end = 2002,
      level_check = 1,
      popup = L("y1x1"),
      disable_flicker = true
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_GainQuestItem] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    handson_teach = {
      view_type = _popup_windows_qlink,
      view = ui_handson_teach.w_handson_qlink,
      timer = ui_handson_teach.timer_qlink_handson,
      target = ui_qbar.w_btn_item,
      popup = L("x1"),
      margin = ui.rect(0, -20, 0, 0),
      flicker = ui_handson_teach.w_flicker_item
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_WASDMove] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_zdteach.pic_flicker,
      popup = L("y1x1"),
      disable_flicker = true,
      set_topper = ui_zdteach.w_main,
      margin = ui.rect(-10, -50, 0, 0),
      popup_function = open_wasd
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_ReputationShop_Qbar] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    flicker = ui_handson_teach.w_flicker_personal,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_qbar.w_btn_personal,
      popup = L("x1"),
      margin = ui.rect(0, -20, 0, 0),
      set_topper = ui_qbar.w_qlink
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_ReputationShop_PeronalButton] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_personal.w_personal:search("repute"),
      popup = L("y1"),
      set_topper = ui_personal.w_personal,
      disable_flicker = true
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_ReputationShop_ReputationButton] = {
    popup_type = cPopupTypeWindows,
    popo_type = 5,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_widget.ui_tab.get_button(ui_personal.ui_repute.w_main, "camp"),
      popup = L("y2"),
      set_topper = ui_personal.ui_repute.w_repute_panel,
      check_observable = true,
      priority = 120,
      disable_flicker = true
    }
  }
  local target_shop_button = ui_personal.ui_repute.w_repute_panel:search("rp_list")
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_ReputationShop_ShopButton] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_personal.ui_repute.w_repute_panel:search("rp_list"),
      popup = L("y1"),
      set_topper = ui_personal.ui_repute.w_repute_panel:search("rp_list"),
      check_observable = true,
      priority = 120,
      disable_flicker = true,
      margin = ui.rect(-390, -20, 0, 0)
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_JumpSkill_Qbar] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    flicker = ui_skill.w_flicker_skill,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_qbar.w_btn_skill,
      popup = L("x1"),
      margin = ui.rect(0, -20, 0, 0),
      on_show = ui_handson_teach.on_show_quest_traceing_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_JumpSkill_Other] = {
    popup_type = cPopupTypeWindows,
    popo_type = 8,
    flicker = ui_widget.ui_tab.get_button(ui_skill.w_skill, "qita"):search("flicker_handson"),
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_widget.ui_tab.get_button(ui_skill.w_skill, "qita"),
      popup = L("y1x2"),
      margin = ui.rect(0, -10, 40, 0),
      disable_flicker = true,
      on_show = ui_handson_teach.on_show_common_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_JumpSkill_NewSkill] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      search_target_id = 130010,
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      on_search_target = find_other_skill_by_id,
      popup = L("y1"),
      margin = ui.rect(12, 0, 0, 0),
      disable_flicker = true,
      set_topper = ui_skill.w_skill
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_JumpSkill_Qbar2] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    flicker = ui_skill.w_flicker_skill,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_qbar.w_btn_skill,
      popup = L("x1"),
      margin = ui.rect(0, -20, 0, 0),
      on_show = ui_handson_teach.on_show_quest_traceing_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_JumpSkill_Other2] = {
    popup_type = cPopupTypeWindows,
    popo_type = 8,
    flicker = ui_widget.ui_tab.get_button(ui_skill.w_skill, "qita"):search("flicker_handson"),
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_widget.ui_tab.get_button(ui_skill.w_skill, "qita"),
      popup = L("y1x2"),
      margin = ui.rect(0, -10, 40, 0),
      disable_flicker = true,
      on_show = ui_handson_teach.on_show_common_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_JumpSkill_NewSkill2] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      search_target_id = 130011,
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      on_search_target = find_other_skill_by_id,
      popup = L("y1"),
      margin = ui.rect(12, 0, 0, 0),
      disable_flicker = true,
      set_topper = ui_skill.w_skill
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_UseItem] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      search_target_id = 130011,
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      on_search_target = find_hp_item,
      popup = L("y1"),
      margin = ui.rect(0, 0, 0, 0),
      disable_flicker = true,
      set_topper = ui_shortcut.w_shortcut,
      priority = 120
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_YouXuanValley_DungeonInfo] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_quest.ui_tracing.g_quest_tab_btn,
      popup = L("x1"),
      margin = ui.rect(-5, -20, 0, 0),
      disable_flicker = true,
      on_show = ui_handson_teach.on_show_quest_traceing_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_MonsterSealPlace_DungeonInfo] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_quest.ui_tracing.g_quest_tab_btn,
      popup = L("x1"),
      margin = ui.rect(-5, -20, 0, 0),
      disable_flicker = true,
      on_show = ui_handson_teach.on_show_quest_traceing_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Areaquest_Info] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_quest.ui_tracing.g_quest_tab_btn,
      popup = L("x1"),
      margin = ui.rect(-5, -20, 0, 0),
      disable_flicker = true,
      on_show = ui_handson_teach.on_show_quest_traceing_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Manual_LevelUp] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_portrait.w_levelup_btn,
      popup = L("y1"),
      margin = ui.rect(12, 0, 0, 0),
      disable_flicker = true,
      on_show = ui_handson_teach.on_show_quest_traceing_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Skill] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    flicker = ui_skill.w_flicker_skill,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_qbar.w_btn_skill,
      popup = L("x1"),
      margin = ui.rect(0, -20, 0, 0),
      on_show = ui_handson_teach.on_show_quest_traceing_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Skill_Choose] = {
    popup_type = cPopupTypeWindows,
    popo_type = 8,
    flicker = ui_skill.w_zhuzhi_xinfa_list:item_get(2):search("flicker_handson"),
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_skill.w_zhuzhi_xinfa_list:item_get(2),
      popup = L("y1x2"),
      margin = ui.rect(0, -10, 40, 0),
      disable_flicker = true,
      on_show = ui_handson_teach.on_show_common_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Anger_LevelUp] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    flicker = ui_handson_teach.w_flicker_levelup,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_skill.w_btn_zhuzhi_xinfa_levelup,
      popup = L("y1"),
      margin = ui.rect(0, 0, 0, 0),
      disable_flicker = true,
      on_show = ui_handson_teach.on_show_common_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Pause_Train] = {
    popup_type = cPopupTypeWindows,
    handson_teach = {
      view_type = _popup_windows_common,
      view = ui_handson_teach.w_handson_common,
      timer = ui_handson_teach.timer_common_handson,
      target = ui_skill.w_btn_equip_xinfa,
      popup = L("y1x1")
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_SecWeapon_Continue_Train] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    handson_teach = {
      view_type = _popup_windows_common,
      view = ui_handson_teach.w_handson_common,
      timer = ui_handson_teach.timer_common_handson,
      target = ui_xf_cangku.w_btn_equip_xinfa,
      popup = L("x1")
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_3V3_Teammate_Delation] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      view_type = _popup_windows_common,
      view = ui_handson_teach.w_handson_common,
      timer = ui_handson_teach.timer_common_handson,
      target = ui_match.statistic_players,
      popup = L("y1")
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Trace_To_Quest] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    handson_teach = {
      view_type = _popup_windows_common,
      view = ui_handson_teach.w_handson_common,
      timer = ui_handson_teach.timer_common_handson,
      search_list = ui_quest.ui_tracing.w_tracing_list,
      target_name = L("aim_box"),
      check_targetItem = ui_quest.ui_tracing.on_check_target_item,
      popup = L("x1y1"),
      on_show = ui_handson_teach.on_show_quest_traceing_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_Personal] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    flicker = ui_handson_teach.w_flicker_personal,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_qbar.w_btn_personal,
      popup = L("x1"),
      margin = ui.rect(0, -20, 0, 0),
      on_show = ui_handson_teach.on_show_quest_traceing_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotView] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      view_type = _popup_windows_common,
      view = ui_handson_teach.w_handson_common,
      timer = ui_handson_teach.timer_common_handson,
      target = ui_personal.ui_equip.w_equip:search("btn_slot_enhance"),
      popup = L("y1"),
      set_topper = ui_personal.ui_equip.w_equip_slots
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Open_SlotEn] = {
    popup_type = cPopupTypeWindows,
    popo_type = 7,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_personal.ui_equip.w_equip:search("se_hf"),
      popup = L("x2"),
      set_topper = ui_personal.ui_equip.w_equip_slots_enhance
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_SlotEnhance_Click_Enhance] = {
    popup_type = cPopupTypeWindows,
    popo_type = 7,
    handson_teach = {
      view_type = _popup_windows_common,
      view = ui_handson_teach.w_handson_common,
      timer = ui_handson_teach.timer_common_handson,
      target = ui_personal.ui_equip.w_btn_enhance,
      popup = L("x2")
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Skill_SkillTudun] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    flicker = ui_skill.w_flicker_skill,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_qbar.w_btn_skill,
      popup = L("x1"),
      margin = ui.rect(0, -20, 0, 0),
      on_show = ui_handson_teach.on_show_quest_traceing_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Skill_Qita] = {
    popup_type = cPopupTypeWindows,
    popo_type = 8,
    flicker = ui_widget.ui_tab.get_button(ui_skill.w_skill, "qita"):search("flicker_handson"),
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_widget.ui_tab.get_button(ui_skill.w_skill, "qita"),
      popup = L("y1x2"),
      margin = ui.rect(0, -10, 40, 0),
      disable_flicker = true,
      on_show = ui_handson_teach.on_show_common_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Skill_Tudun] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    flicker = ui_skill.find_tudun_skill_flicker(),
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_skill.find_tudun_skill(),
      popup = L("y1"),
      margin = ui.rect(12, 0, 0, 0),
      disable_flicker = true,
      on_show = ui_handson_teach.on_show_quest_traceing_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Open_UI] = {
    popup_type = cPopupTypeWindows,
    popo_type = 6,
    flicker = ui_handson_teach.w_flicker_item,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_qbar.w_btn_item,
      popup = L("x1"),
      margin = ui.rect(0, -20, 0, 0),
      on_show = ui_handson_teach.on_show_quest_traceing_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action1] = {
    popup_type = cPopupTypeWindows,
    handson_teach = {
      view_type = _popup_windows_item,
      view = ui_handson_teach.w_handson_item,
      timer = ui_handson_teach.timer_item_handson,
      search_target = ui_item.w_item,
      search_box = ui_item.g_boxs,
      search_id = ui_handson_teach.g_ei_item_id,
      popup = L("y1x1"),
      disable_flicker = false,
      margin = ui.rect(0, -10, 0, 0)
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_EquipIdentify_Action2] = {
    popup_type = cPopupTypeWindows,
    handson_teach = {
      view_type = _popup_windows_item,
      view = ui_handson_teach.w_handson_item,
      timer = ui_handson_teach.timer_item_handson,
      search_target = ui_item.w_item,
      on_search_target = on_search_identifyable_equip,
      popup = L("y1x1"),
      disable_flicker = false,
      margin = ui.rect(0, -10, 0, 0)
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Trace_Quest] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      popup = L("y1")
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_XinfaMasterShowUI] = {
    popup_type = cPopupTypeWindows,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_skill.w_btn_xinfa_master,
      set_topper = ui_skill.w_zhuzhi_tab,
      priority = 120,
      popup = L("y1"),
      margin = ui.rect(0, -10, 230, 0)
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_FoodMeterHighlight] = {
    popup_type = cPopupTypeWindows,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_portrait.w_food_fig,
      popup = L("y1x1"),
      margin = ui.rect(5, 15, 0, 0),
      disable_flicker = true,
      on_show = ui_handson_teach.on_show_quest_traceing_windows
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_ConveneShowup] = {
    popup_type = cPopupTypeWindows,
    popo_type = 3,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_qbar.w_btn_convene,
      popup = L("y2"),
      margin = ui.rect(0, 0, 0, 0),
      set_topper = ui_qbar.w_qlink,
      disable_flicker = true
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_ConveneRecruit] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_convene.w_btn_show_recruit,
      popup = L("y1"),
      margin = ui.rect(0, 0, 0, 0),
      set_topper = ui_convene.w_convene_main,
      disable_flicker = true
    }
  }
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_ConveneTeleport] = {
    popup_type = cPopupTypeWindows,
    popo_type = 4,
    handson_teach = {
      view_type = _popup_windows_common2,
      view = ui_handson_teach.w_view_handson_common,
      timer = ui_handson_teach.timer_common_handson2,
      target = ui_convene.w_teleport_btn,
      popup = L("y1"),
      margin = ui.rect(0, 0, 0, 0),
      set_topper = ui_convene.w_teleport_proposal,
      disable_flicker = true
    }
  }
end
function runf_win(id)
  if id == nil then
    return
  end
  local v_id = id.v_int
  local tips = g_quest_data[v_id]
  on_popup_windows(tips, nil, nil, v_id)
end
function on_popup_windows(tips, pExcel, text, text_id)
  if tips.flicker ~= nil then
    tips.flicker.visible = true
  end
  local handson_teach = tips.handson_teach
  if sys.check(handson_teach) ~= false and sys.check(handson_teach.view) ~= false then
    local _handson_teach_text
    if sys.check(pExcel) then
      if tips.popo_type ~= 0 then
        _handson_teach_text = sys.format(L("<handson:%d,%d>"), pExcel.id, tips.popo_type)
      else
        _handson_teach_text = sys.format(L("<handson:%d>"), pExcel.id)
      end
    elseif tips.popo_type ~= 0 then
      _handson_teach_text = sys.format(L("<handson:0,%d,%s,%d>"), tips.popo_type, text, text_id)
    else
      _handson_teach_text = sys.format(L("<handson:0,0,%s,%d>"), text, text_id)
    end
    if handson_teach.view_type == _popup_windows_common then
      handson_teach.timer.suspended = false
      g_handson_popup_common = handson_teach
      g_handson_popup_common.text = _handson_teach_text
    elseif handson_teach.view_type == _popup_windows_qlink then
      handson_teach.timer.suspended = false
      g_handson_popup_qlink = handson_teach
      g_handson_popup_qlink.text = _handson_teach_text
    elseif handson_teach.view_type == _popup_windows_item then
      handson_teach.timer.suspended = false
      g_handson_popup_item = handson_teach
      g_handson_popup_item.text = _handson_teach_text
    elseif handson_teach.view_type == _popup_windows_common2 then
      handson_teach.timer.suspended = false
      g_handson_popup_common2 = handson_teach
      g_handson_popup_common2.text = _handson_teach_text
    end
  else
  end
end
function on_finish_windows(tips)
  local handson_teach = tips.handson_teach
  if sys.check(handson_teach) ~= false then
    if sys.check(handson_teach) and sys.check(handson_teach.popup_function) then
      handson_teach.popup_function(false)
    end
    if sys.check(handson_teach.view) ~= false then
      handson_teach.view.visible = false
    end
    if sys.check(handson_teach.timer) ~= false then
      handson_teach.timer.suspended = true
    end
    if sys.check(handson_teach.flicker) ~= false then
      handson_teach.flicker.visible = false
    end
    if sys.check(tips.flicker) ~= false then
      tips.flicker.visible = false
    end
    if handson_teach.view_type == _popup_windows_common then
      g_handson_popup_common = nil
    elseif handson_teach.view_type == _popup_windows_qlink then
      g_handson_popup_qlink = nil
    elseif handson_teach.view_type == _popup_windows_item then
      g_handson_popup_item = nil
    elseif handson_teach.view_type == _popup_windows_common2 then
      g_handson_popup_common2 = nil
    end
  elseif sys.check(g_handson_popup_common) ~= false then
    if sys.check(g_handson_popup_common.flicker) ~= false then
      g_handson_popup_common.flicker.visible = false
    end
    g_handson_popup_common = nil
  elseif sys.check(g_handson_popup_qlink) ~= false then
    if sys.check(g_handson_popup_qlink.flicker) ~= false then
      g_handson_popup_common.flicker.visible = false
    end
    g_handson_popup_item = nil
  elseif sys.check(g_handson_popup_item) ~= false then
    if sys.check(g_handson_popup_item.flicker) ~= false then
      g_handson_popup_common.flicker.visible = false
    end
    g_handson_popup_common = nil
  end
end
function on_timer_common_handson2()
  local on_target_check_faild = function(handson_teach)
    handson_teach.view.visible = false
  end
  local handson_teach = g_handson_popup_common2
  if sys.check(handson_teach) ~= false and sys.check(handson_teach.view) ~= false then
    local target = handson_teach.target
    if sys.check(target) ~= true then
      if sys.check(handson_teach.search_list) ~= false then
        local size = handson_teach.search_list.item_count
        if size == 0 then
          on_target_check_faild(handson_teach)
          return
        end
        for i = 0, size - 1 do
          local item = handson_teach.search_list:item_get(i)
          if sys.check(item) ~= false then
            local target_item = item:search(handson_teach.target_name)
            if sys.check(target_item) ~= false then
              if sys.check(handson_teach.check_targetItem) ~= false then
                if handson_teach.check_targetItem(target_item) then
                  target = target_item
                  break
                end
              elseif sys.check(handson_teach.get_target_item) ~= false then
                local item = handson_teach.get_target_item(handson_teach, target_item)
                if item ~= nil then
                  target = item
                  break
                end
              else
                target = target_item
                break
              end
            end
          end
        end
      end
      if sys.check(handson_teach.target_parent) ~= false then
        local _current_target = handson_teach.target_parent:search(handson_teach.target_name)
        if sys.check(_current_target) ~= false then
          target = _current_target
        end
        if sys.check(handson_teach.get_target_item) then
          target = handson_teach.get_target_item(_current_target)
        end
      end
      if handson_teach.on_search_target then
        target = handson_teach.on_search_target(handson_teach)
      end
      if sys.check(target) ~= true then
        on_target_check_faild(handson_teach)
        return
      end
    end
    if sys.check(handson_teach.on_show) ~= true then
      on_show_common_windows(handson_teach, target)
    else
      handson_teach.on_show(handson_teach, target)
    end
  else
    g_handson_popup_common2 = nil
    if sys.check(ui_handson_teach.timer_common_handson2) ~= false then
      ui_handson_teach.timer_common_handson2.suspended = true
    end
  end
end
function on_timer_common_handson()
  local on_target_check_faild = function(handson_teach)
    handson_teach.view.visible = false
  end
  local handson_teach = g_handson_popup_common
  if sys.check(handson_teach.view) ~= true then
  end
  if sys.check(handson_teach) ~= false and sys.check(handson_teach.view) ~= false then
    local target = handson_teach.target
    if sys.check(target) ~= true then
      if sys.check(handson_teach.search_list) ~= false then
        local size = handson_teach.search_list.item_count
        if size == 0 then
          on_target_check_faild(handson_teach)
          return
        end
        for i = 0, size - 1 do
          local item = handson_teach.search_list:item_get(i)
          if sys.check(item) ~= false then
            local target_item = item:search(handson_teach.target_name)
            if sys.check(target_item) ~= false then
              if sys.check(handson_teach.check_targetItem) ~= false then
                if handson_teach.check_targetItem(target_item) then
                  target = target_item
                  break
                end
              elseif sys.check(handson_teach.get_target_item) ~= false then
                local item = handson_teach.get_target_item(handson_teach, target_item)
                if item ~= nil then
                  target = item
                  break
                end
              else
                target = target_item
                break
              end
            end
          end
        end
      end
      if sys.check(handson_teach.target_parent) ~= false then
        local _current_target = handson_teach.target_parent:search(handson_teach.target_name)
        if sys.check(_current_target) ~= false then
          target = _current_target
        end
      end
      if handson_teach.on_search_target then
        target = handson_teach.on_search_target(handson_teach)
      end
      if sys.check(target) ~= true then
        on_target_check_faild(handson_teach)
        return
      end
    end
    if sys.check(handson_teach.on_show) ~= true then
      on_show_common_windows(handson_teach, target)
    else
      handson_teach.on_show(handson_teach, target)
    end
  else
    g_handson_popup_common = nil
    if sys.check(ui_handson_teach.timer_common_handson) ~= false then
      ui_handson_teach.timer_common_handson.suspended = true
    end
  end
end
function on_timer_qlink_handson()
  local on_target_check_faild = function(handson_teach)
    handson_teach.view.visible = false
  end
  local handson_teach = g_handson_popup_qlink
  if sys.check(handson_teach) ~= false and sys.check(handson_teach.view) ~= false then
    local target = handson_teach.target
    if handson_teach.on_search_target then
      target = handson_teach.on_search_target(handson_teach)
    end
    if sys.check(target) ~= true then
      on_target_check_faild(handson_teach)
      return
    end
    if sys.check(handson_teach.on_show) ~= true then
      on_show_link_windows(handson_teach, target)
    else
      handson_teach.on_show(handson_teach, target)
    end
  else
    g_handson_popup_qlink = nil
    if sys.check(ui_handson_teach.timer_qlink_handson) ~= false then
      ui_handson_teach.timer_qlink_handson.suspended = true
    end
  end
end
function on_timer_item_handson()
  local on_target_check_faild = function(handson_teach)
    handson_teach.view.visible = false
    if sys.check(handson_teach.flicker) ~= false then
      handson_teach.flicker.visible = false
    end
  end
  local handson_teach = g_handson_popup_item
  if sys.check(handson_teach) ~= false and sys.check(handson_teach.view) ~= false then
    local target
    if sys.check(handson_teach.search_target) ~= true or handson_teach.search_target.visible ~= true then
      on_target_check_faild(handson_teach)
      return
    end
    if sys.check(handson_teach.search_box) ~= false then
      for i, v in pairs(handson_teach.search_box) do
        for j, k in pairs(v.cells) do
          if k.card.excel then
            local iItemID = k.card.excel.id
            if iItemID == handson_teach.search_id or iItemID == handson_teach.search_id1 then
              target = k.card
              break
            end
            if handson_teach.search_id_begin and iItemID >= handson_teach.search_id_begin and iItemID <= handson_teach.search_id_end then
              target = k.card
              break
            end
          end
        end
        if sys.check(target) ~= false then
          break
        end
      end
      if sys.check(target) ~= true then
        on_target_check_faild(handson_teach)
        return
      end
    end
    if handson_teach.on_search_target then
      target = handson_teach.on_search_target(handson_teach)
      if sys.check(target) ~= true then
        on_target_check_faild(handson_teach)
        return
      end
    end
    if sys.check(handson_teach.on_show) ~= true then
      on_show_common_windows(handson_teach, target.parent)
    else
      handson_teach.on_show(handson_teach, target.parent)
    end
  else
    g_handson_popup_item = nil
    if sys.check(ui_handson_teach.timer_item_handson) ~= false then
      ui_handson_teach.timer_item_handson.suspended = true
    end
  end
end
function on_show_common_windows(handson_teach, target)
  local topper = target.topper
  if handson_teach.set_topper ~= nil then
    topper = handson_teach.set_topper
  end
  if sys.check(topper) ~= true or topper.visible ~= true then
    handson_teach.view.visible = false
    return
  end
  if handson_teach.check_observable == true and (sys.check(topper) ~= true or topper.observable ~= true) then
    handson_teach.view.visible = false
    return
  end
  if handson_teach.check_alpha ~= nil and handson_teach.check_alpha == true and (sys.check(topper) ~= true or topper.alpha < 0.5) then
    handson_teach.view.visible = false
    return
  end
  if handson_teach.timer_check ~= nil and handson_teach.timer_check() ~= true then
    handson_teach.view.visible = false
    return
  end
  local card_parent = target.parent
  if handson_teach.flicker == nil and handson_teach.disable_flicker ~= true then
    local flicker_control
    if sys.check(handson_teach.search_target) and handson_teach.search_target == ui_item.w_item then
      flicker_control = ui.create_control(target, "panel")
    else
      flicker_control = ui.create_control(card_parent, "panel")
    end
    flicker_control:load_style(c_flicker_uri, c_flicker_style)
    flicker_control:move_to_head()
    flicker_control.size = target.size
    flicker_control.margin = target.margin
    flicker_control.dock = target.dock
    handson_teach.flicker = flicker_control
  end
  handson_teach.view.visible = true
  if handson_teach.text.size <= 0 then
    return
  end
  ui_widget.tip_make_view(handson_teach.view, handson_teach.text)
  local current_priority = topper.priority + 5
  if handson_teach.priority ~= nil then
    current_priority = handson_teach.priority
  end
  handson_teach.view.parent.priority = current_priority
  handson_teach.view.priority = current_priority
  local margin = handson_teach.margin
  if handson_teach.get_margin ~= nil then
    margin = handson_teach.get_margin(handson_teach)
  end
  handson_teach.view:show_popup(target, handson_teach.popup, margin)
end
function on_show_quest_traceing_windows(handson_teach, target)
  if ui_quest.ui_tracing.w_tracing_panel.visible ~= true or ui_quest.ui_tracing.w_plus.visible == true or ui_quest.ui_tracing.quest_tracing_panel.visible == false then
    handson_teach.view.visible = false
    ui_handson_teach.w_handson_flicker0.visible = false
    return
  end
  local card = target
  if handson_teach.text.size <= 0 then
    return
  end
  if handson_teach.new_flicker == true then
    do
      local p_target = target.parent
      local var = p_target.var
      if var:get(L("m")).v_int ~= 1 then
        var:set(L("m"), 1)
        g_quest_flicker_target = p_target
        do
          local function on_set_pos()
            if sys.check(p_target) ~= true then
              return false
            end
            ui_handson_teach.w_handson_flicker0.dx = p_target.dx
            ui_handson_teach.w_handson_flicker0.dy = p_target.dy
            ui_handson_teach.w_handson_flicker0.visible = true
            w_handson_flicker0.dx = p_target.dx + 6
            w_handson_flicker0.dy = p_target.dy + 6
            local y = p_target.size.y
            w_handson_flicker0:show_popup(card, L("y1"), ui.rect(0, -y - 2, 0, 0))
            w_handson_flicker0.parent.priority = ui_quest.ui_tracing.w_tracing_quest.priority + 5
            return true
          end
          on_set_pos()
          local c_time = 1
          local c_time_max = 10
          local function on_time_disable_flicker()
            if on_set_pos() then
              if sys.check(handson_teach) and sys.check(handson_teach.view) and handson_teach.view.visible == false then
                var:set(L("m"), 0)
                w_handson_flicker0.visible = false
                return
              end
              if c_time > c_time_max then
                w_handson_flicker0.visible = false
                return
              end
              c_time = c_time + 1
              w_handson_flicker0.visible = true
              bo2.AddTimeEvent(25, on_time_disable_flicker)
            else
              w_handson_flicker0.visible = false
            end
          end
          bo2.AddTimeEvent(25, on_time_disable_flicker)
        end
      end
    end
  end
  handson_teach.view.visible = true
  local current_priority = ui_quest.ui_tracing.w_tracing_quest.priority + 5
  handson_teach.view.parent.priority = current_priority
  handson_teach.view.priority = current_priority
  ui_widget.tip_make_view(handson_teach.view, handson_teach.text)
  local margin = handson_teach.margin
  if handson_teach.get_margin ~= nil then
    margin = handson_teach.get_margin(handson_teach)
  end
  handson_teach.view:show_popup(card, handson_teach.popup, margin)
end
function on_show_link_windows(handson_teach, target)
  if handson_teach.text.size <= 0 then
    return
  end
  if handson_teach.set_topper ~= nil then
    local topper = handson_teach.set_topper
    if sys.check(topper) ~= true or topper.visible ~= true then
      handson_teach.view.visible = false
      return
    end
  end
  handson_teach.view.visible = true
  local parent_control = ui_qbar.w_qlink
  handson_teach.view.priority = parent_control.priority + 10
  if handson_teach.flicker ~= nil then
    handson_teach.flicker.visible = true
  end
  ui_widget.tip_make_view(handson_teach.view, handson_teach.text)
  handson_teach.view:show_popup(target, handson_teach.popup, handson_teach.margin)
end
function on_test_visible_set_proprity(window)
  local priority = 0
  if ui_handson_teach.w_handson_common.visible ~= false then
    priority = ui_handson_teach.w_handson_top.priority
  elseif ui_handson_teach.w_view_handson_common.visible ~= false then
    priority = ui_handson_teach.w_handson_top2.priority
  elseif ui_handson_teach.w_handson_qlink.visible ~= false then
    priority = ui_handson_teach.w_handson_top_qlink.priority
  elseif ui_handson_teach.w_handson_item.visible ~= false then
    priority = ui_handson_teach.w_handson_item.parent.priority
  end
  if priority > 0 then
    window.priority = priority
  end
end
