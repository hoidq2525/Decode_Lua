local g_pro_list = {}
local g_teach_skill = {}
local g_all_skill = {}
local g_hightlight = 0
local g_view_fn
local g_max_divider_count = 5
local g_init = true
function on_view_career()
  w_main_career.visible = not w_main_career.visible
end
function c()
  w_main_career.visible = true
end
function vis_c(fn)
  g_view_fn = fn
  w_main_career.visible = true
end
function m()
end
function on_select_career()
  w_main_career.visible = false
end
function clear_note()
  ui_handson_teach.note_insert(L(" "), 0, 4000, 1, 4000)
end
function is_passive_skill(iSkillId)
  return iSkillId ~= nil and iSkillId >= 130001 and iSkillId <= 135000
end
function on_skill_card_mouse(card, msg, pos, wheel)
  if sys.check(card) ~= true then
    return
  end
  if card.excel_id == 0 then
    return
  end
  local icon
  if card.icon then
    icon = card.icon
  else
    return
  end
  local excel_id = card.excel_id
  if msg == ui.mouse_lbutton_down or msg == ui.mouse_lbutton_drag then
    if is_passive_skill(excel_id) then
      return
    end
    local score = get_skill_unlock_score(excel_id)
    local current_score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouScore)
    if score > current_score then
      return
    end
    ui.set_cursor_icon(icon.uri)
    local on_drop_hook = function(w, msg, pos, data)
      if msg == ui.mouse_drop_clean then
      end
      if msg == ui.mouse_drop_setup then
      end
    end
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_teachskill)
    data:set("excel_id", card.excel_id)
    data:set("card", card)
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  elseif msg == ui.mouse_rbutton_click then
  end
end
function get_skill_unlock_score(skill_id)
  if g_teach_skill == nil then
    return 0
  end
  local teach = g_teach_skill[g_hightlight]
  if teach == nil then
    return 0
  end
  local tab = g_all_skill
  for i = 0, tab.size - 1 do
    local excel = tab[i]
    if teach.career == excel.career then
      local excel_size = excel.skills.size
      for j = 0, excel_size - 1 do
        local temp_skill_id = excel.skills[j]
        if skill_id == temp_skill_id then
          return excel.score
        end
      end
    end
  end
  return 0
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel_id = card.excel_id
  if excel_id == nil or excel_id == 0 then
    return
  end
  local stk = sys.mtf_stack()
  local excel
  if is_passive_skill(excel_id) then
    excel = bo2.gv_passive_skill:find(excel_id)
  else
    excel = bo2.gv_skill_group:find(excel_id)
  end
  if sys.check(excel) ~= true then
    return
  end
  local append_data = sys.mtf_stack()
  local score = get_skill_unlock_score(excel_id)
  local current_score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouScore)
  if score <= current_score then
    append_data:raw_push(L("<c+:00FF00><a+:right>"))
  else
    append_data:raw_push(L("<c+:FF0000><a+:right>"))
  end
  local text = ui_widget.merge_mtf({score = score}, ui.get_text("warrior_arena|skill_unlock"))
  if is_passive_skill(excel_id) then
    append_data:raw_push(L("<a-><a+:left>\n"))
  end
  append_data:raw_push(text)
  if score <= current_score then
    append_data:raw_push(ui.get_text("warrior_arena|skill_unlocked"))
  end
  if is_passive_skill(excel_id) then
  else
    append_data:raw_push(ui_tool.cs_tip_sep)
  end
  append_data:raw_push(L("<c-><a->"))
  if is_passive_skill(excel_id) then
    ui_tool.ctip_make_passive_skill(stk, info, excel, append_data)
  else
    ui_tool.ctip_make_skill(stk, info, excel, append_data)
  end
  ui_tool.ctip_show(card, stk)
end
function on_press_btn(btn)
  on_mouse_career(btn.parent.parent, ui.mouse_lbutton_click)
end
function set_career_panel_vis(w, vis)
  local w_highlight = w:search(L("highlight"))
  if sys.check(w_highlight) then
    w_highlight.visible = vis
  end
  local bg_c = w:search(L("bg_c"))
  local bg_c0 = w:search(L("bg_c0"))
  bg_c.visible = not vis
  bg_c0.visible = vis
end
function on_mouse_career(w, msg, pos, wheel)
  if msg == ui.mouse_inner then
    set_career_panel_vis(w, true)
  elseif msg == ui.mouse_outer then
    set_career_panel_vis(w, false)
  elseif msg == ui.mouse_lbutton_click then
    if g_anime_lock == true then
      return
    end
    do
      local new_high_light = 0
      if w.name == L("career_data0") then
        new_high_light = 0
      else
        new_high_light = 1
      end
      local c_flag = 1
      if bo2.player ~= nil then
        c_flag = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_TeachSkillCareer)
      end
      if new_high_light ~= g_hightlight or c_flag == 0 and c_flag == g_hightlight then
        do
          local obj = bo2.player
          if sys.check(obj) ~= true then
            return
          end
          local i = new_high_light
          if sys.check(g_pro_list[i]) ~= true then
            return
          end
          local c = g_pro_list[i].id
          bo2.send_flag_int8(bo2.ePlayerFlagInt8_TeachSkillCareer, c)
          local function on_career_switch(obj, flag)
            clear_note()
            g_hightlight = new_high_light
            refresh_career_panel()
            if sys.check(g_pro_list[i]) then
              local msg = ui_widget.merge_mtf({
                career = g_pro_list[i].name
              }, ui.get_text("warrior_arena|career_note"))
              ui_tool.note_insert(msg, L("FF00FF00"))
            end
            obj:remove_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_TeachSkillCareer, "ui_warrior_arena.on_career_switch")
            anime_view.visible = false
          end
          obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_TeachSkillCareer, on_career_switch, "ui_warrior_arena.on_career_switch")
        end
      else
        if sys.check(g_pro_list[g_hightlight]) ~= true then
          return
        end
        local on_msg_callback = function(msg)
          if msg.result == 1 then
            w_main_career.visible = false
            return
          end
        end
        local c_name = g_pro_list[g_hightlight].name
        local mtf_text = ui_widget.merge_mtf({career = c_name}, ui.get_text("warrior_arena|continue_use"))
        local msg = {
          callback = on_msg_callback,
          text = mtf_text,
          modal = true
        }
        ui_widget.ui_msg_box.show_common(msg)
      end
    end
  end
end
local cell_style_uri = L("$frame/warrior_arena/warrior_arena_career.xml")
local cell_style = L("career_skill_divider")
local max_socre = 800
local max_slot = 122
function clear_shortcut()
  for i = 100, max_slot do
    local info = ui.shortcut_get(i)
    if info ~= nil then
      ui.shortcut_set(i, 0, 0)
    end
  end
end
g_anime_frame = {}
g_anime_frame_param = {}
g_anime_lock = false
function reset_anime_param()
  g_anime_frame_param = {}
  g_anime_frame_param.count = 0
  g_anime_lock = false
end
function skill_move_anime(id, base)
  local w = base
  local btn = ui_shortcut.w_shortcut:search(id)
  if btn == nil then
    return
  end
  local frame
  local size_frame = #g_anime_frame
  local reload = function()
    if g_anime_frame_param.count == nil then
      g_anime_frame_param.count = 0
    end
    local frame = ui.create_control(ui_main.w_top, "dynamic_animation")
    frame:load_style(L("$frame/warrior_arena/warrior_arena_career.xml"), L("hide_anim"))
    g_anime_frame_param.count = g_anime_frame_param.count + 1
    return frame
  end
  if size_frame == nil or g_anime_frame_param == nil or g_anime_frame_param.count == nil or size_frame <= g_anime_frame_param.count then
    frame = reload()
  else
    frame = g_anime_frame[g_anime_frame_param.count + 1]
    g_anime_frame_param.count = g_anime_frame_param.count + 1
  end
  if frame == nil then
    frame = reload()
  end
  frame:frame_clear()
  frame.visible = true
  local f = frame:frame_insert(1000, w)
  local dis1 = w:control_to_window(ui.point(0, 0))
  local pos = btn:control_to_window(ui.point(0, 0))
  f:set_translate1(dis1.x, dis1.y)
  f:set_translate2(pos.x, pos.y)
  table.insert(g_anime_frame, frame)
end
function update_all_shortcut(c_tab, m_tab, current_score, c_name)
  local iterator_tab = function(tab, fun)
    for m = 0, tab.size - 1 do
      local v = tab[m]
      if v == nil or v.skills == nil then
        return false
      end
      local rst, val, idx = fun(v)
      if rst == true then
        return true, val, idx
      end
    end
    return false
  end
  local play_anime = false
  local function set_index_anime(idx, type, new_skill)
    if g_init == false then
      ui.shortcut_set(idx, type, new_skill)
      return
    end
    local function on_play_anime()
      for i = 0, 3 do
        local found = false
        local item = lv_career_skill:item_get(i)
        if sys.check(item) then
          for count = 0, 4 do
            local item_name = sys.format(L("s%d"), count)
            local new_item = item:search(item_name)
            if sys.check(new_item) then
              do
                local card = new_item:search(L("skill_card"))
                if card.excel_id == new_skill then
                  local function on_run()
                    skill_move_anime(idx, card)
                  end
                  bo2.AddTimeEvent(1, on_run)
                  return true
                else
                end
              end
            end
          end
        else
        end
      end
      return false
    end
    local rst = on_play_anime()
    if rst == true then
      play_anime = true
      ui.shortcut_set(idx, 0, 0)
      local function set_skill()
        ui.shortcut_set(idx, type, new_skill)
      end
      bo2.AddTimeEvent(25, set_skill)
    else
      ui.shortcut_set(idx, type, new_skill)
    end
  end
  local function found_combat()
    for i = 100, max_slot do
      local info = ui.shortcut_get(i)
      if info ~= nil and info.excel ~= nil and info.kind == bo2.eShortcut_LianZhao then
        return info, i
      end
    end
    return nil
  end
  local cb_info, cb_idx
  cb_info, cb_idx = found_combat()
  if cb_info == nil then
    local function fix_cb()
      for i = 112, max_slot do
        local info = ui.shortcut_get(i)
        if info ~= nil and info.excel == nil then
          ui.shortcut_set(i, bo2.eShortcut_LianZhao, 6)
          return i
        end
      end
      for i = 100, 111 do
        local info = ui.shortcut_get(i)
        if info ~= nil and info.excel == nil then
          ui.shortcut_set(i, bo2.eShortcut_LianZhao, 6)
          return i
        end
      end
    end
    cb_idx = fix_cb()
  end
  local load_skill = {}
  local function add_loaded(id)
    if id ~= nil then
      load_skill[id] = 1
    else
    end
  end
  local earse_tab = {}
  earse_tab.size = 0
  earse_tab.itr = 0
  local function add_erase_slot(info_idx)
    ui.shortcut_set(info_idx, 0, 0)
    earse_tab[earse_tab.size] = info_idx
    earse_tab.size = earse_tab.size + 1
  end
  for i = 100, max_slot do
    do
      local info = ui.shortcut_get(i)
      local info_idx = i
      local function process_shortcut_load()
        if sys.check(info) ~= true then
          return
        end
        if info.kind ~= bo2.eShortcut_Skill then
          return
        end
        local excel = info.excel
        if excel == nil then
          return
        end
        local id = excel.id
        local function check_in_tab(tab, id)
          local function fun0(v)
            for j = 0, v.skills.size - 1 do
              local skill_id = v.skills[j]
              if skill_id == id then
                return true, v, j
              end
            end
          end
          return iterator_tab(tab, fun0)
        end
        local function found_same_score_slot(tab, excel1, j0)
          local function fun1(v)
            if v.score == excel1.score then
              local new_skill = 0
              if v.skills.size <= j0 then
                new_skill = 0
              else
                new_skill = v.skills[j0]
              end
              if new_skill == nil then
              end
              return true, new_skill
            end
          end
          return iterator_tab(tab, fun1)
        end
        local check0, excel0 = check_in_tab(c_tab, id)
        if check0 == true then
          add_loaded(id)
          return
        end
        local check1, excel1, j0 = check_in_tab(m_tab, id)
        if check1 == true then
          local check2, new_skill = found_same_score_slot(c_tab, excel1, j0)
          if check2 == true and new_skill ~= -1 and is_passive_skill(new_skill) ~= true and load_skill[new_skill] == nil then
            set_index_anime(info_idx, info.kind, new_skill)
            add_loaded(new_skill)
            return
          end
        end
        add_erase_slot(info_idx)
      end
      process_shortcut_load()
    end
  end
  local empty_slot = {}
  empty_slot.size = 0
  empty_slot.iter = 0
  local function calc_empty_shortcut_slot()
    for i = 100, max_slot do
      local add_empty = false
      local info = ui.shortcut_get(i)
      local info_idx = i
      if info ~= nil and (info.excel == nil or info.kind == bo2.eShortcut_Skill) then
        local excel = info.excel
        if excel == nil then
          if cb_idx == nil or cb_idx ~= i then
            add_empty = true
          end
        else
          for k = 0, earse_tab.size - 1 do
            local km = earse_tab[k]
            if km == info_idx then
              add_empty = true
            end
          end
        end
      end
      if add_empty == true then
        empty_slot[empty_slot.size] = info_idx
        empty_slot.size = empty_slot.size + 1
      end
    end
  end
  calc_empty_shortcut_slot()
  local function add_shortcut_skill(new_skill)
    if empty_slot.iter >= empty_slot.size then
      return
    end
    local idx = empty_slot[empty_slot.iter]
    empty_slot.iter = empty_slot.iter + 1
    set_index_anime(idx, bo2.eShortcut_Skill, new_skill)
  end
  local c_send_flag = 0
  local function notify_new_skill(v)
    if v.score <= 0 then
      return
    end
    if sys.check(bo2.player) ~= true then
      return
    end
    local c_flag = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_TeachSkillNotifyIndex)
    local c_skill_flag = 0
    local tab_new_skill = {}
    local function fun_new_check(iter_v)
      if iter_v.score == 0 then
        return false
      end
      if iter_v == v then
        if c_skill_flag >= c_flag then
          for j = 0, v.skills.size - 1 do
            local excel_id = v.skills[j]
            local excel
            if is_passive_skill(skill_id) then
              excel = bo2.gv_passive_skill:find(excel_id)
            else
              excel = bo2.gv_skill_group:find(excel_id)
            end
            if sys.check(excel) then
              local _skill_name = excel.name
              local text = ui_widget.merge_mtf({
                score = v.score,
                skill_name = _skill_name
              }, ui.get_text("warrior_arena|skill_unlock_notify"))
              ui_tool.note_insert(text, L("FF00FF00"))
            end
          end
          c_skill_flag = c_skill_flag + 1
          c_send_flag = c_skill_flag
        end
        return true
      end
      c_skill_flag = c_skill_flag + 1
      return false
    end
    iterator_tab(c_tab, fun_new_check)
  end
  local function fun2(v)
    if current_score >= v.score then
      notify_new_skill(v)
      for j = 0, v.skills.size - 1 do
        local skill_id = v.skills[j]
        if load_skill[skill_id] == nil and is_passive_skill(skill_id) ~= true then
          add_shortcut_skill(skill_id)
        end
      end
    end
  end
  iterator_tab(c_tab, fun2)
  if c_send_flag ~= 0 then
    bo2.send_flag_int8(bo2.ePlayerFlagInt8_TeachSkillNotifyIndex, c_send_flag)
  end
  if play_anime ~= true or g_init == false then
    g_init = true
    return
  end
  g_anime_lock = true
  local function AnimeLockRelease()
    reset_anime_param()
    if w_main_career.visible ~= true then
      return
    end
    local on_msg_callback = function(msg)
      if msg.result == 1 then
        w_main_career.visible = false
        return
      end
    end
    local mtf_text = ui_widget.merge_mtf({career = c_name}, ui.get_text("warrior_arena|confirm_msg"))
    local msg = {
      callback = on_msg_callback,
      text = mtf_text,
      modal = true
    }
    ui_widget.ui_msg_box.show_common(msg)
  end
  bo2.AddTimeEvent(25, AnimeLockRelease)
end
function update_all_skill(skills, title, gray)
  local career = title.id
  local career_name = title.name
  lv_career_skill:item_clear()
  local current_score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouScore)
  if current_score > max_socre then
    current_score = max_socre
  end
  w_cur_score.text = sys.format(L("%d/%d"), current_score, max_socre)
  w_score_progress.dx = current_score / max_socre * 574
  local count = 0
  local las_item
  local function set_item_data(skill, score)
    local divider = last_divider
    if count == 0 or divider == nil then
      divider = lv_career_skill:item_append()
      divider:load_style(cell_style_uri, cell_style)
    end
    local item_name = sys.format(L("s%d"), count)
    local item = divider:search(item_name)
    item.visible = true
    local card = item:search(L("skill_card"))
    if gray == true then
      card.visible = false
      local base_pic = item:search(L("base"))
      base_pic.effect = "gray"
    else
      card.excel_id = skill
      card.visible = true
      if score > current_score then
        card.draw_gray = true
      else
        card.draw_gray = false
      end
      local base_pic = item:search(L("base"))
      base_pic.effect = ""
    end
    count = count + 1
    last_divider = divider
    if count >= g_max_divider_count then
      count = 0
    end
  end
  if skills == nil or 0 >= skills.size then
    return
  end
  local n_size = skills.size - 1
  local c_tab = {}
  local m_tab = {}
  c_tab.size = 0
  m_tab.size = 0
  for i = 0, n_size - 1 do
    local v = skills[i]
    if v then
      local score = v.score
      if v.career == career then
        for j = 0, v.skills.size - 1 do
          local skill_id = v.skills[j]
          set_item_data(skill_id, score)
        end
      end
      if current_score >= score then
        if v.career == career then
          c_tab[c_tab.size] = v
          c_tab.size = c_tab.size + 1
        else
          m_tab[m_tab.size] = v
          m_tab.size = m_tab.size + 1
        end
      end
    end
  end
  if gray == true then
    clear_shortcut()
  else
    update_all_shortcut(c_tab, m_tab, current_score, title.name)
  end
end
function set_career_panel_data(panel, title, desc, hightlight, skills)
  if sys.check(panel) ~= true then
    return
  end
  local encircle = panel:search("encircle")
  local cmn_btn = panel:search("cmn_btn")
  local color = L("9C9C9C")
  local color_text = color
  local gray = false
  local obj = bo2.player
  if sys.check(obj) then
    local c_flag = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_TeachSkillCareer)
    if c_flag == 0 and c_flag ~= title.id then
      gray = true
    end
  end
  if hightlight ~= nil and hightlight == true and gray == false then
    color = L("17A6DB")
    color_text = L("FFFFFF")
    encircle.visible = true
  else
    encircle.visible = false
  end
  local career_desc = panel:search(L("career_desc"))
  if desc == nil then
    career_desc.mtf = L("")
  else
    local text = bo2.gv_text:find(desc.skill_desc_id)
    if sys.check(text) then
      career_desc.mtf = sys.format(L("<c:%s>%s"), color_text, text.text)
    end
  end
  local career_title = panel:search(L("career_title"))
  if title == nil then
    career_title.text = L("")
  else
    career_title.mtf = sys.format(L("<c+:%s><a+:mid>%s<c-><a->"), color, title.name)
    if hightlight ~= nil and hightlight == true then
      update_all_skill(skills, title, gray)
    end
  end
end
function on_update_skills()
end
function get_pro_list(base_id)
  local pro_list = {}
  local teach_skill = {}
  local all_skill = {}
  pro_list.size = 0
  teach_skill.size = 0
  all_skill.size = 0
  local size_pro = bo2.gv_profession_list.size
  local count = 0
  local c_flag = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_TeachSkillCareer)
  for i = 0, size_pro - 1 do
    local excel = bo2.gv_profession_list:get(i)
    if sys.check(excel) and excel.career == base_id then
      if count ~= 0 then
        pro_list[pro_list.size] = excel
        pro_list.size = pro_list.size + 1
        if pro_list.size == 2 then
          if c_flag ~= 0 then
            if pro_list[0].id == c_flag then
              g_hightlight = 0
              break
            end
            g_hightlight = 1
            break
          end
          g_hightlight = 0
          break
        end
      end
      count = count + 1
    end
  end
  local size_teach_skill = bo2.gv_teach_skill.size
  for i = 0, size_teach_skill - 1 do
    local excel = bo2.gv_teach_skill:get(i)
    for j = 0, pro_list.size - 1 do
      if excel.career == pro_list[j].id then
        if excel.score == 0 then
          teach_skill[teach_skill.size] = excel
          teach_skill.size = teach_skill.size + 1
        end
        all_skill[all_skill.size] = excel
        all_skill.size = all_skill.size + 1
      end
    end
  end
  return pro_list, teach_skill, all_skill
end
local function check()
  if g_pro_list == nil or g_teach_skill == nil or g_pro_list.size == nil or g_teach_skill.size == nil then
    return false
  end
  return true
end
function refresh_career_panel()
  if check() ~= true then
    return
  end
  for i = 0, 1 do
    local item = sys.format(L("career_data%d"), i)
    local panel = w_career_data:search(item)
    local hight = g_hightlight == i
    set_career_panel_data(panel, g_pro_list[i], g_teach_skill[i], hight, g_all_skill)
  end
end
function refresh_career()
  if check() ~= true then
    local obj = bo2.player
    local pro_value = obj:get_atb(bo2.eAtb_Cha_Profession)
    local pro = bo2.gv_profession_list:find(pro_value)
    if pro == nil then
      return
    end
    g_pro_list, g_teach_skill, g_all_skill = get_pro_list(pro.career)
  end
  refresh_career_panel()
end
function assign_default_career()
  local obj = bo2.player
  local pro_value = obj:get_atb(bo2.eAtb_Cha_Profession)
  local pro = bo2.gv_profession_list:find(pro_value)
  if pro == nil then
    return
  end
  local size_pro = bo2.gv_profession_list.size
  local count = 0
  for i = 0, size_pro - 1 do
    local excel = bo2.gv_profession_list:get(i)
    if sys.check(excel) and excel.career == pro.career then
      if count ~= 0 then
        bo2.send_flag_int8(bo2.ePlayerFlagInt8_TeachSkillCareer, excel.id)
        return
      end
      count = count + 1
    end
  end
end
function on_close(btn)
  local c_flag = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_TeachSkillCareer)
  if c_flag == 0 then
    return
  end
  ui_widget.on_close_click(btn)
end
function on_visible_career(w, vis)
  local c_flag = 0
  if sys.check(bo2.player) then
    c_flag = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_TeachSkillCareer)
  end
  if c_flag ~= 0 then
    ui_widget.on_esc_stk_visible(w, vis)
  end
  if vis then
    local msg
    msg = ui.get_text(L("warrior_arena|select_career"))
    ui_handson_teach.note_insert(msg, L("FF00FF00"), 4000, 2000000, 4000)
    anime_view.visible = true
    if c_flag ~= 0 then
      g_init = false
    end
    refresh_career()
    if c_flag ~= 0 then
      g_init = true
    end
    ui_shortcut.set_teach_view(true)
    ui_handson_teach.on_test_visible_set_proprity(w)
  else
    if c_flag == 0 then
      assign_default_career()
    end
    ui_shortcut.set_teach_view(false)
    if g_view_fn ~= nil then
      g_view_fn()
      g_view_fn = nil
    end
    w.priority = 110
    clear_note()
    local xzlvl = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_XuezhanLevel)
    if 1 == xzlvl then
      ui_tool.ui_xinshou_animation_xz.on_career_seleted()
    end
  end
  show_mask(vis)
end
function m()
  w_main_career_mask.visible = true
  w_main_career_mask.dock = L("fill_xy")
end
function show_mask(visible)
  w_main_career_mask.visible = visible
  w_main_career_mask.dock = L("fill_xy")
  w_main_career_mask.focus = visible
  if visible == true then
    local val = w_main_career.priority
    if w_main_career.priority < 200 then
      w_main_career.priority = 200
      val = 200
    end
    w_main_career_mask.priority = -5
  else
    w_main_career_mask.priority = -1
  end
end
function on_c_self_enter()
  if g_c_last_player ~= bo2.player then
    g_pro_list = nil
    g_teach_skill = nil
    g_all_skill = nil
    g_hightlight = 0
    g_anime_frame = {}
    g_init = true
  end
  reset_anime_param()
  g_c_last_player = bo2.player
  local on_time_enable_skill = function()
    if sys.check(bo2.player) == true and bo2.player:get_flag_bit(bo2.ePlayerFlagBit_TeachSkillMode) == 1 then
      refresh_career()
    end
  end
  bo2.AddTimeEvent(5, on_time_enable_skill)
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_c_self_enter, "ui_warrior_arena.on_c_self_enter")
