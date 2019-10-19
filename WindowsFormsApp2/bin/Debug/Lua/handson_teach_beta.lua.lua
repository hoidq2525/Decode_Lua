g_help_note_index = 0
g_help_note_text_copy = nil
g_active_quest_trace_help = true
local g_move_teach_quest_id = 78
function get_handson_window_data(view_type)
  if view_type == _popup_windows_common then
    return view_type, ui_handson_teach.w_handson_common, ui_handson_teach.timer_common_handson
  elseif view_type == _popup_windows_common2 then
    return view_type, ui_handson_teach.w_view_handson_common, ui_handson_teach.timer_common_handson2
  elseif view_type == _popup_windows_item then
    return view_type, ui_handson_teach.w_handson_item, ui_handson_teach.timer_item_handson
  elseif view_type == _popup_windows_qlink then
    return view_type, ui_handson_teach.w_handson_qlink, ui_handson_teach.timer_qlink_handson
  end
end
local move_sig_name = "ui_handson_teach:update_player"
local angle_sig_name = "ui_handson_teach:update_camera_angle"
local angle_idx = 1230
local angle_time = 20000
local angle_dis_time = 900
local first_teach_finish_time = 3500
g_ride_skill_id = 10001
g_ride_time = 10000
ride_dis_time = 900
function update_camere(obj)
  if obj ~= bo2.player then
    return
  end
  if g_help_note_text_copy ~= nil then
    note_insert(g_help_note_text_copy, L("FF00FF00"), angle_idx, angle_dis_time, angle_idx)
    local text = ui.get_text(L("help|finish_move_teach"))
    note_insert(text, L("FF00FF00"), 122, first_teach_finish_time, 122)
    g_active_quest_trace_help = false
    on_active_quest_trace(1021)
  end
  bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_camere_angel, angle_sig_name)
end
function on_player_move(obj)
  if obj ~= bo2.player then
    return
  end
  if g_help_note_index == 1021 and g_help_note_text_copy ~= nil then
    note_insert(g_help_note_text_copy, L("FF00FF00"), 1022, 900)
    ui_qbar.ui_keyboard.show_mini(false)
    local text = ui.get_text(L("help|camera_help"))
    note_insert(text, L("FFFFFFFF"), angle_idx, angle_time, angle_idx)
    g_help_note_text_copy = text
    bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_camere_angel, update_camere, angle_sig_name)
  end
  bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_position, move_sig_name)
end
function on_temp_item_visible(skill_id, vis, disable_check)
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
  on_vis_skill(21)
end
function on_finish_still_milestone(theme, idx)
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
  scn:UnValidStillHandsonTips(h)
end
function on_found_still_milestone(theme, idx)
  local quest_data = g_quest_data[idx]
  if quest_data == nil then
    return false
  end
  local function on_time_do()
    local scn = bo2.scn
    if sys.check(scn) ~= true or scn.excel.id ~= quest_data.scn_excel_id then
      return nil
    end
    local _handson_teach_text = sys.format(L("<handson:0,4,0,%d>"), idx)
    local iHandle = scn:SetStillHandsonTips(quest_data.npc_excel_id, _handson_teach_text)
    theme.active_page.valid = true
    theme.active_page.index = idx
    theme.active_page.h = iHandle
  end
  bo2.AddTimeEvent(5, on_time_do)
  return 1
end
function on_search_item_tip(handson_teach)
  if ui_item.g_tip_frames == nil then
    return nil
  end
  for i, v in ipairs(ui_item.g_tip_frames) do
    if sys.check(v) then
      local rb_text = v:search("rb_text")
      if sys.check(rb_text) then
        local var_id = rb_text.var:get(packet.key.ui_text_id)
        for i = 0, var_id.size - 1 do
          local n, data = var_id:fetch_nv(i)
          if data.v_int == handson_teach.mark_id0 then
            local p_target_name = sys.format(L("h_m%d"), i)
            local p_target = target:search(p_target_name)
            if sys.check(p_target) then
              return p_target.parent:search(L("mark"))
            else
              return target:search(L("mark"))
            end
          end
        end
      end
    end
  end
  return nil
end
local g_key_map = {}
g_key_map[70] = {
  key = "space",
  x1 = true,
  y1 = true,
  x2 = false,
  y2 = false
}
g_key_map[71] = {
  key = "shift",
  x1 = false,
  y1 = true,
  x2 = true,
  y2 = false,
  x2_val = 30
}
g_key_map[72] = {
  key = "w",
  x1 = false,
  y1 = true,
  x2 = true,
  y2 = false,
  x2_val = -20
}
g_key_map[73] = {
  key = "shift",
  x1 = false,
  y1 = true,
  x2 = true,
  y2 = false,
  x2_val = 30
}
g_key_map[175] = {
  key = "w",
  x1 = false,
  y1 = true,
  x2 = true,
  y2 = false,
  x2_val = -20
}
function on_get_key_margin(handson_teach)
  if handson_teach == nil then
    return nil
  end
  local key = handson_teach.key_id
  if key == nil or g_key_map[key] == nil then
    return nil
  end
  local val_key = g_key_map[key]
  local kd = ui_qbar.ui_keyboard.key_def[tostring(val_key.key)]
  if kd == nil then
    return nil
  end
  local val_x1 = -kd[1]
  local val_y1 = -kd[2]
  local val_x2 = -kd[3]
  local val_y2 = -kd[4]
  if val_key.x1 ~= true then
    val_x1 = 0
  end
  if val_key.y1 ~= true then
    val_y1 = 0
  end
  if val_key.x2 == true then
    val_x1 = val_key.x2_val
  end
  if val_key.y2 ~= true then
    val_y2 = 0
  end
  return ui.rect(val_x1, val_y1, val_x2, val_y2)
end
function on_search_key(handson_teach)
  if sys.check(handson_teach.set_topper) ~= true then
    return nil
  end
  local key = handson_teach.key_id
  if key == nil or g_key_map[key] == nil then
    return nil
  end
  return handson_teach.set_topper
end
function on_search_map_deliver(handson_teach)
  if sys.check(handson_teach.set_topper) ~= true then
    return nil
  end
  local id = handson_teach.trans_id
  local btn = ui_npcfunc.ui_map_deliver.w_btns:search(id)
  local btn_b = btn:search("button")
  if sys.check(btn_b) and btn_b.enable ~= true then
    return nil
  end
  return btn
end
function on_search_temp_item(handson_teach)
  if sys.check(handson_teach.search_skill) ~= true then
    return nil
  end
  for i = 0, 3 do
    local info = ui.shortcut_get(58 + i)
    if info ~= nil then
      local excel = info.excel
      local kind = info.kind
      if kind == bo2.eShortcut_Item and sys.check(excel) and handson_teach.check_id == excel.id then
        local name = sys.format(L("%d"), i)
        return handson_teach.search_skill:search(name)
      end
    end
  end
  return nil
end
g_wheel_teach = false
function mouse_wheel_teach()
  if g_wheel_teach == true then
    return
  end
  g_wheel_teach = true
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return
  end
  local mb = g_handson_quest_mb:find(128)
  if sys.check(mb) ~= true then
    return
  end
  local text = mb.popo_text
  note_insert(text, nil, mb.milestone_id, angle_time, mb.milestone_id)
  local wheel_sig_name = "ui_handson_teach:wheel_sig_name"
  local function on_wheel_mouse()
    note_insert(text, L("FF00FF00"), mb.milestone_id, angle_dis_time, mb.milestone_id)
    bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_camera_wheel, wheel_sig_name)
  end
  bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_camera_wheel, on_wheel_mouse, wheel_sig_name)
  local function on_time_remove_sig()
    bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_camera_wheel, wheel_sig_name)
  end
  bo2.AddTimeEvent(250, on_time_remove_sig)
end
function on_text_function(idx, mb_id)
  local move_idx = 1021
  if idx == move_idx then
    do
      local mb = g_handson_quest_mb:find(mb_id)
      if sys.check(mb) ~= true then
        return
      end
      local function on_time_move()
        if sys.check(bo2.scn) ~= true then
          return
        end
        if sys.check(mb) then
          add_popo(mb.milestone_id, mb.popo_text)
        end
      end
      ui_qbar.ui_keyboard.show_mini(true, ui.rect(-6, 30, 300, 220))
      ui_qbar.ui_keyboard.flash_clear()
      ui_qbar.ui_keyboard.flash_insert_keys({
        "w",
        "a",
        "s",
        "d"
      })
      bo2.AddTimeEvent(mb.quest_id, on_time_move)
      bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_position, on_player_move, move_sig_name)
    end
  elseif idx == 1022 then
    on_theme_visible(g_theme[6], 0, true)
  elseif idx == 121 then
  end
end
local g_tempskill_frame_anime
function on_found_tempskill(theme, idx)
  local quest_data = g_quest_data[idx]
  if quest_data == nil then
    return false
  end
  for i = 0, 3 do
    local info = ui.shortcut_get(58 + i)
    if info ~= nil then
      local excel = info.excel
      local kind = info.kind
      if kind == bo2.eShortcut_Skill and sys.check(excel) and excel.id == quest_data.skill_id then
        local name = sys.format(L("%d"), i)
        local w = ui_tempshortcut.ui_tempshortcut.skill_slot:search(name)
        if w == nil then
          return false
        end
        name = sys.format(L("%d"), quest_data.shortcut_id)
        local btn = ui_shortcut.w_shortcut:search(name)
        if btn == nil then
          return false
        end
        local reload = function()
          local frame = ui.create_control(ui_main.w_top, "dynamic_animation")
          frame:load_style(L("$frame/warrior_arena/warrior_arena_career.xml"), L("hide_anim"))
          return frame
        end
        local frame = g_tempskill_frame_anime
        if sys.check(frame) ~= true then
          g_tempskill_frame_anime = reload()
          frame = g_tempskill_frame_anime
        end
        frame:frame_clear()
        frame.visible = true
        local fps = 15
        local f = frame:frame_insert(fps * 40, w)
        local dis1 = w:control_to_window(ui.point(0, 0))
        local pos = btn:control_to_window(ui.point(0, 0))
        f:set_translate1(dis1.x, dis1.y)
        f:set_translate2(pos.x, pos.y)
        local function on_time()
          ui.shortcut_set(quest_data.shortcut_id, bo2.eShortcut_Skill, quest_data.skill_id)
          ui_tempshortcut.main_wnd.visible = false
        end
        bo2.AddTimeEvent(fps, on_time)
        return true
      end
    end
  end
  return false
end
function on_notify_text(theme, idx)
  local mb = g_handson_quest_mb:find(idx)
  if sys.check(mb) then
    local text = mb.popo_text
    if idx == 114 then
      begin_jump_teach(mb)
      return
    end
    note_insert(text, nil, mb.milestone_id, mb.mark_id)
    on_text_function(mb.milestone_id, mb.quest_id)
  end
end
function init_beta_data(mb_excel)
  if sys.check(mb_excel) ~= true then
    return false
  end
  if mb_excel.popo_type == 18 then
    local id = mb_excel.id
    local milestone_id = mb_excel.milestone_id
    local scn_id = mb_excel.mark_id
    local quest_id = mb_excel.quest_id
    g_notify_text[milestone_id] = id
  elseif mb_excel.popo_type == 19 then
    local id = mb_excel.id
    g_quest_milestone_confirm[mb_excel.milestone_id] = id
    g_quest_data[id] = {
      popup_type = cPopupTypeWindows,
      popo_type = 4,
      handson_teach = {
        disable_flicker = true,
        view_type = _popup_windows_common2,
        view = ui_handson_teach.w_view_handson_common,
        timer = ui_handson_teach.timer_common_handson2,
        target = ui_quest.ui_milestone.w_inform_btn,
        popup = mb_excel.popup,
        make_text_id = id
      }
    }
  elseif mb_excel.popo_type == 20 then
    local id = mb_excel.id
    g_quest_complete_confirm[mb_excel.milestone_id] = id
    g_quest_data[id] = {
      popup_type = cPopupTypeWindows,
      popo_type = 4,
      handson_teach = {
        disable_flicker = true,
        view_type = _popup_windows_common,
        view = ui_handson_teach.w_handson_common,
        timer = ui_handson_teach.timer_common_handson,
        target = ui_quest.ui_complete.w_complete:search(L("handson_button")),
        popup = mb_excel.popup,
        make_text_id = id
      }
    }
  elseif mb_excel.popo_type == 21 then
    local id = mb_excel.id
    g_temp_new_item[mb_excel.milestone_id] = id
    g_quest_data[id] = {
      popup_type = cPopupTypeWindows,
      check_id = mb_excel.milestone_id,
      handson_teach = {
        view_type = _popup_windows_common2,
        view = ui_handson_teach.w_view_handson_common,
        timer = ui_handson_teach.timer_common_handson2,
        disable_flicker = true,
        on_search_target = on_search_temp_item,
        search_skill = ui_tempshortcut.ui_tempshortcut.skill_slot,
        check_id = mb_excel.milestone_id,
        popup = mb_excel.popup,
        make_text_id = id
      }
    }
  elseif mb_excel.popo_type == 22 then
    local id = mb_excel.id
    local milestone_id = mb_excel.milestone_id
    local scn_id = mb_excel.mark_id
    local quest_id = mb_excel.quest_id
    g_milestone_notify_still[milestone_id] = id
    g_quest_data[id] = {scn_excel_id = scn_id, npc_excel_id = quest_id}
  elseif mb_excel.popo_type == 24 then
    local id = mb_excel.id
    local milestone_id = mb_excel.milestone_id
    local mark_id = mb_excel.mark_id
    g_item_tip[milestone_id] = id
    g_quest_data[id] = {
      popup_type = cPopupTypeWindows,
      check_id = mb_excel.milestone_id,
      handson_teach = {
        view_type = _popup_windows_common2,
        view = ui_handson_teach.w_view_handson_common,
        timer = ui_handson_teach.timer_common_handson2,
        disable_flicker = true,
        on_search_target = on_search_item_tip,
        check_id = mb_excel.milestone_id,
        mark_id0 = mark_id,
        popup = mb_excel.popup,
        make_text_id = id,
        priority = 125
      }
    }
  elseif mb_excel.popo_type == 25 then
    local id = mb_excel.id
    g_temp_auto_move_new_skill[mb_excel.milestone_id] = id
    g_quest_data[id] = {
      popup_type = cPopupTypeWindows,
      shortcut_id = mb_excel.quest_id,
      skill_id = mb_excel.milestone_id
    }
  elseif mb_excel.popo_type == 26 then
    local id = mb_excel.id
    g_ride_index[mb_excel.milestone_id] = id
    g_quest_data[id] = {
      popup_type = cPopupTypeWindows,
      popo_type = 6,
      handson_teach = {
        view_type = _popup_windows_common2,
        view = ui_handson_teach.w_view_handson_common,
        timer = ui_handson_teach.timer_common_handson2,
        disable_flicker = true,
        target = ui_qbar.w_ridepet_fight_open,
        set_topper = ui_qbar.w_ridepet_fight_open,
        popup = mb_excel.popup,
        make_text_id = id,
        priority = 200
      }
    }
    if mb_excel.text_margin.size == 4 then
      g_quest_data[id].handson_teach.margin = ui.rect(-mb_excel.text_margin[0], -mb_excel.text_margin[1], mb_excel.text_margin[2], mb_excel.text_margin[3])
    end
  elseif mb_excel.popo_type == 27 then
    local id = mb_excel.id
    g_ride_index[mb_excel.milestone_id] = id
    g_quest_data[id] = {
      popup_type = cPopupTypeWindows,
      popo_type = 6,
      handson_teach = {
        view_type = _popup_windows_common2,
        view = ui_handson_teach.w_view_handson_common,
        timer = ui_handson_teach.timer_common_handson2,
        disable_flicker = true,
        target = ui_qbar.w_ridepet_sight,
        set_topper = ui_qbar.w_ridepet_sight,
        popup = mb_excel.popup,
        make_text_id = id
      }
    }
    g_quest_data[id].handson_teach.margin = ui.rect(-mb_excel.text_margin[0], -mb_excel.text_margin[1], mb_excel.text_margin[2], mb_excel.text_margin[3])
  elseif mb_excel.popo_type == 28 then
    local id = mb_excel.id
    g_deliver_tab[mb_excel.milestone_id] = id
    g_quest_data[id] = {
      popup_type = cPopupTypeWindows,
      popo_type = 4,
      handson_teach = {
        view_type = _popup_windows_common2,
        view = ui_handson_teach.w_view_handson_common,
        timer = ui_handson_teach.timer_common_handson2,
        disable_flicker = true,
        trans_id = mb_excel.milestone_id,
        on_search_target = on_search_map_deliver,
        set_topper = ui_npcfunc.ui_map_deliver.w_main,
        popup = mb_excel.popup,
        make_text_id = id
      }
    }
  elseif mb_excel.popo_type == 29 then
    local id = mb_excel.id
    g_key_monitor_tab[mb_excel.milestone_id] = id
    g_quest_data[id] = {
      popup_type = cPopupTypeWindows,
      popo_type = 4,
      handson_teach = {
        view_type = _popup_windows_common2,
        view = ui_handson_teach.w_view_handson_common,
        timer = ui_handson_teach.timer_common_handson2,
        disable_flicker = true,
        key_id = mb_excel.milestone_id,
        on_search_target = on_search_key,
        set_topper = ui_qbar.ui_keyboard.w_mini,
        get_margin = on_get_key_margin,
        popup = mb_excel.popup,
        make_text_id = id
      }
    }
  elseif mb_excel.popo_type == 30 then
    local area_list = gx_match_win:search(L("arena"))
    local btn = area_list:search(L("btn_sign_in"))
    local flicker = btn:search(L("flicker_m"))
    local id = mb_excel.id
    g_quest_data[id] = {
      popup_type = cPopupTypeWindows,
      handson_teach = {
        view_type = _popup_windows_common,
        view = ui_handson_teach.w_handson_common,
        timer = ui_handson_teach.timer_common_handson,
        target = btn,
        popup = L("y1x1"),
        flicker = flicker,
        popup = mb_excel.popup,
        make_text_id = id
      }
    }
  end
end
function fill_beta_data()
  g_theme[18] = {page = g_notify_text, on_found = on_notify_text}
  g_theme[19] = {
    page = g_quest_milestone_confirm,
    active_page = g_teaching_milestone_confirm,
    reset = reset_teaching_milestone_view
  }
  g_theme[20] = {
    page = g_quest_complete_confirm,
    active_page = g_teaching_complete_confirm,
    reset = reset_teaching_complete_confirm
  }
  g_theme[21] = {
    page = g_temp_new_item,
    active_page = g_teaching_temp_new_item,
    reset = reset_teaching_quest_new_item,
    check = on_check_temp_skill_enable
  }
  g_theme[22] = {
    page = g_milestone_notify_still,
    on_faild = on_finish_still_milestone,
    on_found = on_found_still_milestone,
    active_page = g_teaching_milestone_notify_still,
    reset = reset_teaching_quest_milestone_notify_still
  }
  g_theme[24] = {
    page = g_item_tip,
    active_page = g_teaching_item_tip,
    reset = reset_teaching_item_tip
  }
  g_theme[25] = {page = g_temp_auto_move_new_skill, on_found = on_found_tempskill}
  g_theme[26] = {
    page = g_ride_index,
    active_page = g_teaching_ride_idex,
    reset = reset_ride_idex
  }
  g_theme[27] = {
    page = g_deliver_tab,
    active_page = g_teaching_deliver_tab,
    reset = reset_deliver_tab
  }
  g_theme[29] = {
    page = g_key_monitor_tab,
    active_page = g_teaching_key_monitor_tab,
    reset = reset_key_monitor_tab
  }
  g_wheel_teach = false
end
function on_enter_beta()
  g_new_item_notify = false
  g_milestone1025_update = false
  on_init_jump()
  local on_time_quest_trace = function()
    if sys.check(bo2.scn) ~= true then
      return
    end
    local scn_excel_id = bo2.scn.scn_excel.id
    for i, v in pairs(g_teaching_quest_trace) do
      local quest_data = g_quest_data[v]
      if quest_data ~= nil and quest_data.init ~= false then
        return
      end
    end
    local quest_tab = {
      {c = 10, scn = 101},
      {c = 78, scn = 176}
    }
    for i = 10007, 10013 do
      table.insert(quest_tab, {c = i, scn = 101})
      table.insert(quest_tab, {c = i, scn = 1200})
    end
    local get_quest_ms = function(quest_id)
      if ui.quest_find_c(quest_id) then
        return nil
      end
      local quest_info = ui.quest_find(quest_id)
      if quest_info ~= nil then
        return quest_info.mstone_id
      end
    end
    for i, v in pairs(quest_tab) do
      local scn = v.scn
      local ms
      if scn == scn_excel_id then
        ms = get_quest_ms(v.c)
      end
      if ms ~= nil and ms ~= 1021 and g_quest_trace_data[ms] ~= nil then
        on_active_quest_trace(ms)
        return
      end
    end
  end
  bo2.AddTimeEvent(25, on_time_quest_trace)
  local function on_time()
    if sys.check(bo2.scn) ~= true then
      return
    end
    local excel = bo2.scn.excel.id
    if excel ~= 176 then
      return
    end
    local quest_info = ui.quest_find(g_move_teach_quest_id)
    if quest_info == nil then
      return
    end
    local on_fun = function(milestone_id)
      local theme = g_theme[18]
      if g_theme[18] == nil or g_theme[18].page == nil or g_quest_data == nil then
        return nil
      end
      return on_theme_visible(g_theme[18], milestone_id, true)
    end
    on_fun(quest_info.mstone_id)
  end
  bo2.AddTimeEvent(50, on_time)
  on_time_begin_jump_teach()
  g_active_quest_trace_help = true
end
function run_t()
  test_complate_milestone_update(1024)
end
function on_init_beta_window()
end
function note_insert(msg, color, idx, time, _group)
  local function insert(text, color, span, show_scn, limit_group, limit_count)
    local group = ui_help_note.c_limit_group_help
    if _group ~= nil then
      group = _group
    end
    ui_help_note.insert(ui_help_note.w_note_list, text, color, span, show_scn, group, 1)
  end
  if time == nil then
    time = 10000
  end
  insert(msg, color, time)
  g_help_note_index = idx
  if idx == 1021 then
    g_help_note_text_copy = msg
  end
end
function add_popo(page_id, text)
  do return end
  local data = sys.variant()
  data:set(L("page"), page_id)
  data:set(packet.key.ui_text, text)
  ui_popo.AddPopo("help", data)
end
function on_jump_teach_milestone(ms_id)
  if ms_id ~= 192 then
    return
  end
  local scn = bo2.scn
  if sys.check(scn) ~= true then
    return
  end
  local npc = bo2.SearchNpcByChaListID(5360)
  if sys.check(npc) then
    scn:UnValidNpcHandsonTips(npc.sel_handle)
  end
  redo_jump()
end
function r_guide()
  add_popo(4, L("\178\233\191\180\189\204\209\167"))
end
function run_clear()
  note_insert(nil, nil)
end
function on_skill_used(cmd, data)
  if sys.check(data) ~= true then
    return
  end
  local idx = data:get(packet.key.cmn_id).v_int
  local cmn_type = data:get(packet.key.cmn_type).v_int
  if idx == 0 then
    return
  end
  if cmn_type ~= 1 then
    return
  end
  local theme = g_theme[11]
  if theme == nil or theme.page == nil or g_quest_data == nil then
    return
  end
  on_theme_visible(theme, idx, false, true)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_handson_teach.packet_handle"
reg(packet.eSTC_ScnObj_Skill, on_skill_used, sig)
