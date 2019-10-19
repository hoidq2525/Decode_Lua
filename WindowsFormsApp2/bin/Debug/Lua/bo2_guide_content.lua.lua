g_page_view = nil
function push_new_line(stk)
  stk:push(L("\n"))
end
function on_init_page_view()
  if g_page_view == nil then
    g_page_view = {}
  end
end
function on_init_data()
  on_init_mb_view()
  on_init_theme_data()
  on_init_page_view()
end
function on_query_by_text(text, on_found)
  if g_theme_data == nil then
    return
  end
  if text.empty == true then
    return
  end
  local var = sys.variant()
  var:set(L("0"), text)
  local text_table = var:get(L("0")):split_to_no_repeat_array(L(" "))
  local function on_found_text(_name)
    local found_class = 0
    local found_times = 0
    local re_text
    for i = 0, text_table.size - 1 do
      local n = text_table[i]
      if 0 < n.size and n ~= L(" ") then
        local find_text_idx = _name:find(n)
        if find_text_idx > 0 then
          found_class = class_type_found
        elseif find_text_idx == 0 then
          if n.size == _name.size then
            found_class = class_type_equal
            return found_class, sys.format(L("<c+:FFFF88>%s<c->"), _name)
          else
            found_class = class_type_found
          end
        end
        if find_text_idx >= 0 then
          local sp_text = re_text
          if re_text == nil then
            sp_text = _name
          end
          local sub_front, sub_data = sp_text:split(n)
          if sp_text.size >= 2 then
            sub_data = sub_data:substr(n.size - 1, sub_data.size)
          end
          re_text = sys.format(L("%s<c+:FFFF88>%s<c->%s"), sub_front, n, sub_data)
          found_times = found_times + 1
        end
      end
    end
    return found_class, re_text, found_times
  end
  local pArraySearchResult = {}
  for i = class_type_begin, class_type_end - 1 do
    pArraySearchResult[i] = sys.variant()
  end
  for iTheme, v in pairs(g_theme_data) do
    local view = v.mb_view
    local base_view = view
    if v.search_view ~= nil then
      view = v.search_view
    end
    local size_count = view.size
    local while_list = v.while_list
    for i = 0, size_count - 1 do
      local mb_data = view:get(i)
      local found_while_data = true
      if while_list ~= nil then
        local while_excel = while_list:find(mb_data.id)
        if while_excel == nil then
          found_while_data = false
        end
      end
      if found_while_data ~= false then
        local _name = v.get_name(mb_data)
        local found_class, insert_text, found_times = on_found_text(_name)
        if found_class ~= 0 then
          local insert_data_var = sys.variant()
          insert_data_var:set(packet.key.cmn_type, iTheme)
          insert_data_var:set(packet.key.cmn_id, mb_data.id)
          insert_data_var:set(packet.key.cmn_dataobj, insert_text)
          insert_data_var:set(packet.key.cmn_rst, found_times)
          pArraySearchResult[found_class]:push_back(insert_data_var)
        end
      end
    end
  end
  local sort_poriority = function(left, right)
    if left:get(packet.key.cmn_rst).v_int <= right:get(packet.key.cmn_rst).v_int then
      return false
    end
    return true
  end
  for i = class_type_begin, class_type_end - 1 do
    local var = pArraySearchResult[i]
    if i ~= class_type_equal then
      var:sort(sort_poriority)
    end
    local var_size = var.size
    for i = 0, var_size - 1 do
      local v = var:get(i)
      local insert_data = {}
      insert_data.var = v
      insert_data.text = v:get(packet.key.cmn_dataobj).v_string
      on_found(insert_data)
    end
  end
  pArraySearchResult = nil
end
function on_select_item_by_var(var)
  if sys.check(var) ~= true then
    return
  end
  local theme = var:get(packet.key.cmn_type).v_int
  if theme == 0 or g_theme_data == nil or g_theme_data[theme] == nil then
    return
  end
  local id = var:get(packet.key.cmn_id).v_int
  local theme_table = g_theme_data[theme]
  local mb_data = theme_table.get_mb(theme_table, id)
  if mb_data == nil then
    return
  end
  local page = {}
  page.var = var
  page.theme = theme
  page.id = id
  on_insert_page(page)
end
function found_page(page)
  local idx = 0
  for i, v in pairs(g_page_view) do
    if v.theme == page.theme and v.id == page.id then
      return v, idx
    end
    idx = idx + 1
  end
  return nil
end
function get_index_page(_idx)
  local idx = 0
  for i, v in pairs(g_page_view) do
    if _idx == idx then
      return v
    end
    idx = idx + 1
  end
  return nil
end
function on_insert_page(page_data)
  local page_found = found_page(page_data)
  if page_found == nil then
    page_found = page_data
    table.insert(g_page_view, page_data)
  end
  on_view_page(page_data)
end
function remove_page(idx)
  table.remove(g_page_view, idx + 1)
end
function on_close_single_page()
  local wnd = ui_bo2_guide.wnd_guide
  local iCount = #g_page_view
  for i = 0, 4 do
    do
      local btn = wnd:search(sys.format(L("%d"), i))
      if btn.visible == true and btn.press == true then
        local idx = btn.svar
        remove_page(idx)
        if iCount == 1 then
          local function on_disable_page()
            btn.visible = false
            btn_close.visible = false
            rb_context.mtf = L("")
          end
          on_disable_page()
          return
        end
        local view_index = 0
        if iCount <= idx + 1 then
          view_index = idx - 1
        else
          view_index = idx
        end
        local page = get_index_page(view_index)
        on_view_page(page)
        return
      end
    end
  end
end
function on_view_page(page_data)
  local page_found, idx = found_page(page_data)
  if page_found == nil then
    return
  end
  btn_close.visible = true
  local count = #g_page_view
  local function update_page_btn(btn, page_data, idx)
    if page_data.theme == 0 then
      return
    end
    local theme_table = g_theme_data[page_data.theme]
    local mb_data = theme_table.get_mb(theme_table, page_data.id)
    if mb_data == nil then
      return
    end
    local _name = mb_data.name
    btn.text = _name
    btn.visible = true
    btn.tip.text = sys.format(L("%s %d/%d"), _name, idx + 1, count)
    btn.press = true
    btn.svar = idx
  end
  local function update_page_content(idx, page_idx)
    local wnd = ui_bo2_guide.wnd_guide
    local btn = wnd:search(sys.format(L("%d"), idx))
    if sys.check(btn) ~= true then
      return
    end
    ui_bo2_guide.rb_item.visible = false
    if page_data.theme == 0 then
      return
    else
    end
    local theme_table = g_theme_data[page_data.theme]
    local mb_data = theme_table.get_mb(theme_table, page_data.id)
    if mb_data == nil then
      return
    end
    update_page_btn(btn, page_data, page_idx)
    local stk = sys.mtf_stack()
    local function on_push_auto_data(text, type, theme)
      local tmp_stk = sys.mtf_stack()
      if sys.check(type) and type.size > 0 then
        push_new_line(tmp_stk)
        local title_make = sys.format(L("<lb:art,18,full,D3A75E|%s%s%s>"), guide_space, text, guide_space)
        tmp_stk:raw_push(title_make)
        local size = type.size
        if size == 0 then
          push_new_line(stk)
        else
          for i = 0, size - 1 do
            push_new_line(stk)
            local mtf_text = sys.format(L("<guide:%d,%d>"), theme, type[i])
            stk:raw_push(mtf_text)
          end
        end
      end
    end
    if page_data.theme == theme_type_cha_list then
      if 0 < mb_data.head_icon.size then
        local text = sys.format(L("<img:$icon/portrait/%s>"), mb_data.head_icon)
        stk:raw_push(text)
        stk:raw_push(ui_widget.merge_mtf({
          name = mb_data.name
        }, ui.get_text("guide|cha_name")))
      end
      push_new_line(stk)
      local cha_auto_excel = theme_table.find_auto(page_data.id)
      if cha_auto_excel ~= nil then
        on_push_auto_data(ui.get_text("guide|inc_area_id"), cha_auto_excel.inc_area_id, theme_type_area_list)
        on_push_auto_data(ui.get_text("guide|drop_item"), cha_auto_excel.drop_item, theme_type_item_list)
        on_push_auto_data(ui.get_text("guide|quest_begin"), cha_auto_excel.quest_begin, theme_type_quest_list)
        on_push_auto_data(ui.get_text("guide|quest_end"), cha_auto_excel.quest_end, theme_type_quest_list)
        on_push_auto_data(ui.get_text("guide|quest_query"), cha_auto_excel.quest_end, theme_type_quest_list)
        on_push_auto_data(ui.get_text("guide|kill_finish_quest"), cha_auto_excel.kill_finish_quest, theme_type_quest_list)
        on_push_auto_data(ui.get_text("guide|milestone_end"), cha_auto_excel.milestone_end, 0)
        on_push_auto_data(ui.get_text("guide|kill_finish_milestone"), cha_auto_excel.kill_finish_milestone, 0)
        on_push_auto_data(ui.get_text("guide|sell_item"), cha_auto_excel.sell_item, theme_type_item_list)
      else
      end
      ui_bo2_guide.rb_context.mtf = stk.text
      ui_bo2_guide.rb_context.visible = true
      ui_bo2_guide.rb_context.slider_y.scroll = 0
    elseif page_data.theme == theme_type_quest_list then
      stk:raw_push(mb_data.name)
      ui_bo2_guide.rb_context.mtf = stk.text
      ui_bo2_guide.rb_context.visible = true
      ui_bo2_guide.rb_context.slider_y.scroll = 0
    elseif page_data.theme == theme_type_item_list then
      do
        local plootlevel_star, title_name
        plootlevel_star = mb_data.plootlevel_star
        title_name = mb_data.name
        local color = ui_tool.cs_tip_color_white
        if plootlevel_star ~= nil then
          color = plootlevel_star.color
        end
        function item_title_on_reset()
          local w = ui_bo2_guide.rb_item
          w.visible = true
          local card = w:search(L("card"))
          local text = w:search(L("rb_text"))
          card.excel_id = mb_data.id
          if sys.is_type(color, "number") then
            text.mtf = sys.format(L("<c+:%x>%s<c->"), color, title_name)
          else
            local stk_new = sys.mtf_stack()
            stk_new:raw_format(ui_tool.cs_tip_title_enter_s, color)
            stk_new:push(title_name)
            stk_new:raw_format(ui_tool.cs_tip_title_leave)
            text.mtf = stk_new.text
          end
          return true
        end
        item_title_on_reset()
        local item_auto_excel = theme_table.find_auto(page_data.id)
        if item_auto_excel ~= nil then
          on_push_auto_data(ui.get_text("guide|recive_quest_id"), item_auto_excel.recive_quest_id, theme_type_quest_list)
          on_push_auto_data(ui.get_text("guide|finish_quest_id"), item_auto_excel.finish_quest_id, theme_type_quest_list)
          on_push_auto_data(ui.get_text("guide|award_quest_id"), item_auto_excel.award_quest_id, theme_type_quest_list)
          on_push_auto_data(ui.get_text("guide|drop_npc_id"), item_auto_excel.drop_npc_id, theme_type_cha_list)
          on_push_auto_data(ui.get_text("guide|sell_npc_id"), item_auto_excel.sell_npc_id, theme_type_cha_list)
          on_push_auto_data(ui.get_text("guide|exchange_item_id"), item_auto_excel.exchange_item_id, theme_type_item_list)
          on_push_auto_data(ui.get_text("guide|blueprint_item_id"), item_auto_excel.blueprint_item_id, theme_type_item_list)
          on_push_auto_data(ui.get_text("guide|finish_milestone_id"), item_auto_excel.finish_milestone_id, theme_type_quest_list)
          on_push_auto_data(ui.get_text("guide|award_milestone_id"), item_auto_excel.award_milestone_id, theme_type_quest_list)
          on_push_auto_data(ui.get_text("guide|exchange_from_item_id"), item_auto_excel.exchange_from_item_id, theme_type_item_list)
          on_push_auto_data(ui.get_text("guide|gift_item_id"), item_auto_excel.gift_item_id, theme_type_item_list)
          on_push_auto_data(ui.get_text("guide|give_gift_item"), item_auto_excel.give_gift_item, theme_type_item_list)
          ui_tool.ctip_push_sep(stk)
        end
        ui_bo2_guide.rb_context.mtf = stk.text
        ui_bo2_guide.rb_context.visible = true
        ui_bo2_guide.rb_context.slider_y.scroll = 0
      end
    elseif page_data.theme == theme_type_area_list then
      stk:raw_push(theme_table.get_name(mb_data))
      local mb_scn = bo2.gv_scn_list:find(mb_data.in_scn)
      if mb_scn ~= nil then
        local mtf_text = ui_widget.merge_mtf({
          scn_name = mb_scn.name,
          theme = _theme
        }, ui.get_text("guide|scn_name"))
        stk:raw_push(mtf_text)
      end
      local excel_auto = find_area_auto_excel(mb_data.id)
      if excel_auto ~= nil then
        on_push_auto_data(ui.get_text("guide|inc_cha_id"), excel_auto.inc_cha_id, theme_type_cha_list)
      end
      ui_bo2_guide.rb_context.mtf = stk.text
      ui_bo2_guide.rb_context.visible = true
      ui_bo2_guide.rb_context.slider_y.scroll = 0
    end
  end
  if count <= 5 then
    update_page_content(idx, idx)
    local wnd = ui_bo2_guide.wnd_guide
    for i = count, 4 do
      local btn = wnd:search(sys.format(L("%d"), i))
      btn.visible = false
    end
  else
    local _tab_index = 2
    if count <= idx + 2 then
      _tab_index = 4 - (count - idx - 1)
    elseif idx < 2 then
      _tab_index = idx
    end
    for i = 0, 4 do
      if i ~= _tab_index then
        local page_idx = idx - _tab_index + i
        if i > _tab_index then
          page_idx = idx - _tab_index + i
        end
        local page = get_index_page(page_idx)
        local wnd = ui_bo2_guide.wnd_guide
        local btn = wnd:search(sys.format(L("%d"), i))
        update_page_btn(btn, page, page_idx)
      end
    end
    update_page_content(_tab_index, idx)
  end
end
function on_click_page_btn(btn)
  local page = get_index_page(btn.svar)
  on_view_page(page)
end
function on_click_close_page_btn(btn)
  local parent_btn = btn.parent
  if sys.check(parent_btn) ~= true then
    return
  end
  if parent_btn.visible == true and parent_btn.press == true then
    on_close_single_page()
  else
    local wnd = ui_bo2_guide.wnd_guide
    local iCount = #g_page_view
    for i = 0, ciMaxTableCount - 1 do
      local btn_2 = wnd:search(sys.format(L("%d"), i))
      if btn_2.visible == true and btn_2.press == true then
        local view_index = parent_btn.svar
        local idx = parent_btn.svar
        remove_page(idx)
        if iCount <= view_index + 1 then
          view_index = view_index - 1
        else
        end
        local page = get_index_page(view_index)
        on_view_page(page)
        return
      end
    end
  end
end
function on_esc_stk_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis == true then
    on_init_data()
    ui_handson_teach.on_test_visible_set_proprity(w)
  else
    w.priority = 110
  end
end
function on_view_mtf(theme, id, text)
  local var = sys.variant()
  var:set(packet.key.cmn_type, theme)
  var:set(packet.key.cmn_id, id)
  ui_bo2_guide.w_main.visible = true
  on_select_item_by_var(var)
  if theme == theme_type_topic then
    on_select_item_by_content_idx(id)
  end
end
function on_get_mtf_text(theme, id, text)
  on_init_data()
  if theme == 0 or id == 0 then
    return text
  end
  local _text
  local _theme = sys.format(L("guide|theme_%d"), theme)
  _theme = ui.get_text(_theme)
  local theme_table = g_theme_data[theme]
  _text = theme_table.get_mtf_text(theme_table, id)
  return ui_widget.merge_mtf({name = _text, theme = _theme}, ui.get_text("guide|mtf"))
end
function on_card_tip_show(tip)
  return ui_item.on_card_tip_show(tip)
end
