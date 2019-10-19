local _popup_windows_common = 1
local _popup_windows_qlink = 2
local _popup_windows_item = 3
local iActiveHandsOn = 16
local iFinishHandsOn = 17
local iBeginNotifyItemLevel = 10
g_handson_freshers_item = {}
function on_init_once_freshers_item()
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_NotifyFrishersItem] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_NotifyFrishersItem][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_NotifyFrishersItem,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest,
    flag = false
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_NotifyFrishersItem] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_NotifyFrishersItem,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_FrishersItem_5] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_FrishersItem_5][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_FrishersItem_5,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest,
    flag = false
  }
  g_handsonhelp_finish[bo2.ePlayerFlagInt16_HandsOn_FrishersItem_5] = {
    finish_id = bo2.ePlayerFlagInt16_HandsOn_FrishersItem_5,
    finish_case = bo2.ActiveHandsOnTeach_CaseQuest
  }
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_FrishersItem_8] = {}
  g_handsonhelp_quest[bo2.ePlayerFlagInt16_HandsOn_FrishersItem_8][cQuestTeachType_Add] = {
    active_idx = bo2.ePlayerFlagInt16_HandsOn_FrishersItem_8,
    active_case = bo2.ActiveHandsOnTeach_CaseQuest,
    flag = false
  }
  g_handson_freshers_item = {
    flag = bo2.ePlayerFlagInt16_HandsOn_FrishersItem_3,
    item_id_begin = 57901,
    item_id_end = 57999,
    temp_flag = false
  }
end
on_init_once_freshers_item()
function on_init_freshers_item_windows()
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_NotifyFrishersItem] = {
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
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_FrishersItem_3] = {
    popup_type = cPopupTypeWindows,
    handson_teach = {
      view_type = _popup_windows_item,
      view = ui_handson_teach.w_handson_item,
      timer = ui_handson_teach.timer_item_handson,
      search_target = ui_item.w_item,
      search_box = ui_item.g_boxs,
      search_id_begin = 57901,
      search_id_end = 58000,
      level_check = 1,
      popup = L("y1x1"),
      disable_flicker = true
    }
  }
  local item_excel = bo2.gv_item_list:find(57901)
  if item_excel then
    local use_par_size = item_excel.use_par.size
    if use_par_size > 2 then
      g_handson_freshers_item.gain_item = item_excel.use_par[use_par_size - 2]
    end
  end
  g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_FrishersItem_5] = {
    popup_type = cPopupTypeWindows,
    handson_teach = {
      view_type = _popup_windows_item,
      view = ui_handson_teach.w_handson_item,
      timer = ui_handson_teach.timer_item_handson,
      search_target = ui_item.w_item,
      search_box = ui_item.g_boxs,
      search_id = g_handson_freshers_item.gain_item,
      popup = L("y1x1"),
      disable_flicker = true,
      margin = ui.rect(0, -10, 0, 0)
    }
  }
end
function on_levelup_modify_freshers_item(obj, iLevel, check_quest)
  local flag_item = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_NotifyFrishersItem)
  if flag_item == iFinishHandsOn then
    return
  end
  if iLevel < iBeginNotifyItemLevel then
    return
  end
  if check_quest == nil or check_quest == true then
    local quest_flag = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_FrishersItem_8)
    if quest_flag == 0 then
      return
    end
  end
  if iLevel == iBeginNotifyItemLevel and flag_item ~= iActiveHandsOn then
    ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_NotifyFrishersItem, ui_handson_teach.cQuestTeachType_Add)
  end
  local iFindItem = false
  local iItemId = 0
  function on_find_item()
    local iItemId = 0
    local iItemBegin = g_handson_freshers_item.item_id_begin
    local iItemEnd = g_handson_freshers_item.item_id_end
    for i, v in pairs(ui_item.g_boxs) do
      for j, k in pairs(v.cells) do
        if k.card.excel ~= nil then
          iItemId = k.card.excel.id
          if iItemBegin <= iItemId and iItemEnd >= iItemId then
            return k.card.excel
          end
        end
      end
    end
    return nil
  end
  local check_faild_end_popo = function()
    local tips = g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_FrishersItem_3]
    on_finish_windows(tips)
  end
  local check_item = on_find_item()
  if check_item == nil then
    check_faild_end_popo()
    return
  end
  if iLevel < check_item.reqlevel then
    check_faild_end_popo()
    return
  end
  g_handson_freshers_item.temp_flag = true
  if ui_item.w_item.visible == true then
    on_try_popoup_item()
  else
    local iExcelId = bo2.ePlayerFlagInt16_HandsOn_NotifyFrishersItem - bo2.ePlayerFlagInt16_HandsOn
    local pExcel = bo2.gv_handson_teach:find(iExcelId)
    if pExcel == nil then
      return
    end
    PopupHandsOnTips(bo2.ePlayerFlagInt16_HandsOn_NotifyFrishersItem, pExcel)
  end
end
function on_try_popoup_item()
  if g_handson_freshers_item.temp_flag == false then
    return
  end
  local tips = g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_NotifyFrishersItem]
  if tips ~= nil then
    on_finish_windows(tips)
  end
  local iExcelId = bo2.ePlayerFlagInt16_HandsOn_FrishersItem_3 - bo2.ePlayerFlagInt16_HandsOn
  local pExcel = bo2.gv_handson_teach:find(iExcelId)
  if pExcel == nil then
    return
  end
  local cur_tips = g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_FrishersItem_3]
  if ui_handson_teach.w_handson_item.visible == true and g_handson_popup_item ~= cur_tips then
    return
  end
  PopupHandsOnTips(bo2.ePlayerFlagInt16_HandsOn_FrishersItem_3, pExcel)
end
function on_vis_freshers_item_notifies(vis)
  if vis then
    on_try_popoup_item()
  else
    if g_handson_freshers_item.temp_flag == true then
      local try_finish_tips = function(tips)
        if tips ~= nil then
          on_finish_windows(tips)
        end
      end
      local tips = g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_FrishersItem_3]
      try_finish_tips(tips)
      tips = g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_NotifyFrishersItem]
      try_finish_tips(tips)
      g_handson_freshers_item.temp_flag = false
    end
    if ui_handson_teach.on_finish_teach_quest ~= nil then
      ui_handson_teach.on_finish_teach_quest(bo2.ePlayerFlagInt16_HandsOn_FrishersItem_5)
    end
  end
end
