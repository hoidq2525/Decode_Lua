local bo2_mb = {
  scn_list = bo2.gv_scn_list,
  still_list = bo2.gv_still_list,
  cha_list = bo2.gv_cha_list,
  xinfa_list = bo2.gv_xinfa_list,
  pet_list = bo2.gv_pet_list,
  state_container = bo2.gv_state_container,
  equip_set = bo2.gv_equip_set,
  item_list = bo2.gv_item_list,
  campaign_list = bo2.gv_campaign_list,
  skill_group = bo2.gv_skill_group,
  atb_player = bo2.gv_atb_player,
  equip_item = bo2.gv_equip_item,
  scroll_item = bo2.gv_scroll_item,
  ridepet_star = bo2.gv_ridepet_star_init,
  ridepet_type = bo2.gv_ridepet_type_init,
  ridepet_skill = bo2.gv_ridepet_skill,
  quest_item = bo2.gv_quest_item,
  senior_npc_list = bo2.gv_senior_npc_list,
  guild_schedule = bo2.gv_guild_schedule,
  ridepet_blood_telent = bo2.gv_ridepet_blood_telent,
  temp_skill = bo2.temp_skill
}
local cammond_table = bo2.gv_command
cammond_train_table = bo2.gv_command_sort
local table_list = {}
cur_para = nil
record = {
  i = 10000,
  j = 10000,
  k = 10000,
  quest_id,
  milestone_id
}
g_select_reward_idx = nil
local c_init_lang = bo2.get_lang()
function on_init()
end
function set_milestone_quest_value(mstone_id, quest_id)
  local excel = cammond_table:find(mstone_id)
  if excel == nil then
    return
  end
  local para = {
    excel.para1,
    excel.para2,
    excel.para3,
    excel.para4,
    excel.para5,
    excel.para6
  }
  local para_xml = {
    para_1,
    para_2,
    para_3,
    para_4,
    para_5,
    para_6
  }
  for i = 1, 6 do
    if para[i].size == 0 then
      para_xml[i].visible = false
    else
      for i = 1, 6 do
        if excel["para" .. i .. "_file"].size ~= 0 then
          para_xml[i]:search("search_btn").visible = true
        else
          para_xml[i]:search("search_btn").visible = false
        end
      end
      para_xml[i]:search("output").text = para[i]
      if para_xml[i]:search("output").text == ui.get_text("gm_command|player") then
        local player = bo2.player
        if player ~= nil then
          para_xml[i]:search("input").text = player.name
        end
      else
        para_xml[i]:search("input").text = nil
      end
      para_xml[i]:search("id_list"):item_clear()
      para_xml[i].visible = true
    end
  end
  para_1:search("input").focus = true
  cur_para = para_1
  cmn_info:search("desc").text = ui.get_text("gm_command|explain") .. "\n" .. excel.info
end
function on_current_init()
end
function insert_child_item(item, text, mstone_id, quest_id)
  local child_item_uri = "$frame/gm/cmn.xml"
  local child_item_style = "quest_tree_item_child"
  local child_item = item:item_append()
  child_item.obtain_title:load_style(child_item_uri, child_item_style)
  child_item:search("item_text").text = text
  child_item:search("mstone_id").text = mstone_id
  child_item:search("excel_id").text = quest_id
  ui_quest.tree_select_change_update(w_current_quest_tree)
  child_item:search("select").visible = true
end
function is_theme_exist(theme_id)
  local root = w_current_quest_tree.root
  local root_size = root.item_count
  for i = 0, root_size - 1 do
    local item = root:item_get(i)
    local excel_id = item:search("excel_id").text.v_int
    local in_theme = ui.quest_find(excel_id).excel.in_theme
    if in_theme == theme_id then
      return i
    end
  end
  return nil
end
function test_insert_tree_item(id)
  local excel_id = id
  local item_uri = "$frame/gm/current.xml"
  local item_style = "quest_tree_item"
  local root = w_current_quest_tree.root
  local list = cammond_train_table:find(id)
  local app_item = root:item_append()
  app_item.obtain_title:load_style(item_uri, item_style)
  app_item.obtain_title:search("title_name").text = list.name
  app_item.obtain_title:search("excel_id").text = list.id
  local size = list.cammond_list.size
  ui_widget.on_tree_node_toggle_click(app_item)
  for i = 0, size - 1 do
    local milestone = cammond_table:find(list.cammond_list[i])
    if milestone ~= nil then
      insert_child_item(app_item, milestone.name, milestone.id, list.id)
    end
  end
end
function on_child_item_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    close_all_list()
    ui_quest.tree_select_change_update(w_current_quest_tree)
    local parent = panel
    parent:search("select").visible = true
    record.quest_id = parent:search("excel_id").text.v_int
    local mstone_id = parent:search("mstone_id").text.v_int
    set_milestone_quest_value(mstone_id, record.quest_id)
    record.milestone_id = mstone_id
  end
end
function on_tree_item_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    close_all_list()
    ui_quest.tree_select_change_update(w_current_quest_tree)
    local parent = panel
    parent:search("select").visible = true
    record.quest_id = parent:search("excel_id").text.v_int
    record.milestone_id = nil
    local btn = panel:search("btn_minus")
    ui_widget.on_tree_node_toggle_click(btn)
  end
end
function on_keydown_input(ctrl, key, keyflag)
  if key == ui.VK_TAB and keyflag.down then
    local para_xml = {
      para_1,
      para_2,
      para_3,
      para_4,
      para_5,
      para_6
    }
    for i = 1, 6 do
      if para_xml[i]:search("input") == ctrl then
        if para_xml[i + 1].visible ~= false then
          para_xml[i + 1]:search("input").focus = true
          cur_para = para_xml[i + 1]
        else
          para_xml[1]:search("input").focus = true
          cur_para = para_xml[i + 1]
        end
        return
      end
    end
  elseif key == ui.VK_RETURN and keyflag.down then
    on_ok_click()
  end
end
function search_key(src, key)
  src = src.lower
  key = key.lower
  return src:find(key) >= 0
end
function on_keydown_find(ctrl, key, keyflag)
  if cur_para == nil then
    return
  end
  if not cur_para:search("search_list").visible then
    return
  end
  local search_list = cur_para:search("id_list")
  if key == ui.VK_RETURN and keyflag.down then
    local find_text = find:search("input").text
    if find_text.size == 0 then
      search_list:item_clear()
      local para_xml = {
        para_1,
        para_2,
        para_3,
        para_4,
        para_5,
        para_6
      }
      local excel = cammond_table:find(record.milestone_id)
      local table_path
      for i, v in pairs(para_xml) do
        if cur_para == v then
          table_path = excel["para" .. i .. "_file"]
          break
        end
      end
      local list = bo2_mb[tostring(table_path)]
      for i = 0, list.size - 1 do
        local line = list:get(i)
        local item
        item = search_list:item_insert(search_list.item_count)
        item:load_style("$frame/gm/current.xml", "finditem")
        item:search("text").text = line.name
        item.svar = line.id
      end
    else
      if find_text == ui.get_text("gm_command|find_text") then
        return
      end
      local cnt = search_list.item_count - 1
      local del_items = {}
      for i = 0, cnt do
        local item = search_list:item_get(i)
        if not search_key(item:search("text").text, find_text) then
          table.insert(del_items, item)
        end
      end
      for _, item in ipairs(del_items) do
        item:self_remove()
      end
    end
  elseif keyflag.down and find:search("input").text == ui.get_text("gm_command|find_text") then
    find:search("input").text = nil
  end
end
function on_ok_click(bnt)
  local para_xml = {
    para_1,
    para_2,
    para_3,
    para_4,
    para_5,
    para_6
  }
  local cmn = tostring(cammond_table:find(record.milestone_id).fun)
  local excel = cammond_table:find(record.milestone_id)
  local para_str = tostring(excel.info)
  if string.sub(para_str, 1, 1) == "#" then
    for id in string.gmatch(para_str, "%d+") do
      cmn_info:search("desc").text = ui_console.cmd_exec(string.format(cmn, tostring(para_xml[1]:search("input").text), id))
    end
  elseif string.sub(para_str, 1, 1) == "!" then
    for v in string.gmatch(cmn, "[%w%s%%]+") do
      cmn_info:search("desc").text = ui_console.cmd_exec(string.format(v, tostring(bo2.player.name)))
    end
  else
    for i = 1, 6 do
      if para_xml[i].visible ~= false then
        cmn = cmn .. " " .. para_xml[i]:search("input").text
      end
    end
    cmn_info:search("desc").text = ui_console.cmd_exec(cmn)
  end
  cmn_info:search("input").text = cmn
end
function on_mouse_find(panel, msg)
  if msg == ui.mouse_lbutton_down and find:search("input").text == ui.get_text("gm_command|find_text") then
    find:search("input").text = nil
  end
end
function on_mouse_cmn(panel, msg)
  if msg == ui.mouse_lbutton_down and cmn_info:search("input").text == ui.get_text("gm_command|cmn_text") then
    cmn_info:search("input").text = nil
  end
end
function on_keydown_cmn(ctrl, key, keyflag)
  if key == ui.VK_RETURN and keyflag.down then
    local cmn = cmn_info:search("input").text
    cmn_info:search("desc").text = ui_console.cmd_exec(cmn)
  end
end
function item_on_mouse(item, msg)
  if msg == ui.mouse_enter then
    item.parent:search("select").visible = true
  end
  if msg == ui.mouse_leave then
    item.parent:search("select").visible = false
  end
end
function item_on_click(btn)
  cur_para:search("input").text = btn.parent.svar
  cur_para:search("search_list").visible = false
  cur_para:search("input").focus = true
  find.visible = false
end
function close_all_list()
  local para_xml = {
    para_1,
    para_2,
    para_3,
    para_4,
    para_5,
    para_6
  }
  for _, v in pairs(para_xml) do
    v:search("search_list").visible = false
  end
  find.visible = false
end
function on_show_list(btn, msg)
  cur_para = btn.parent.parent.parent
  local search_list = cur_para:search("search_list")
  if search_list.visible then
    search_list.visible = not search_list.visible
    find.visible = false
    return
  end
  local id_list = search_list:search("id_list")
  id_list:item_clear()
  local excel = cammond_table:find(record.milestone_id)
  if excel == nil then
    return
  end
  local para_xml = {
    para_1,
    para_2,
    para_3,
    para_4,
    para_5,
    para_6
  }
  local para_file
  for i, v in pairs(para_xml) do
    if cur_para ~= v then
      v:search("search_list").visible = false
    else
      para_file = excel["para" .. i .. "_file"]
    end
  end
  if para_file.size ~= 0 then
    local list = bo2_mb[tostring(para_file)]
    for i = 0, list.size - 1 do
      local line = list:get(i)
      local item = id_list:item_insert(id_list.item_count)
      item:load_style("$frame/gm/current.xml", "finditem")
      item:search("text").text = line.name
      item.svar = line.id
    end
    if list == bo2_mb.item_list then
      list = bo2.gv_gem_item
      for i = 0, list.size - 1 do
        local line = list:get(i)
        local item = id_list:item_insert(id_list.item_count)
        item:load_style("$frame/gm/current.xml", "finditem")
        item:search("text").text = line.name
        item.svar = line.id
      end
      list = bo2.gv_scroll_item
      for i = 0, list.size - 1 do
        local line = list:get(i)
        local item = id_list:item_insert(id_list.item_count)
        item:load_style("$frame/gm/current.xml", "finditem")
        item:search("text").text = line.name
        item.svar = line.id
      end
      list = bo2.gv_quest_item
      for i = 0, list.size - 1 do
        local line = list:get(i)
        local item = id_list:item_insert(id_list.item_count)
        item:load_style("$frame/gm/current.xml", "finditem")
        item:search("text").text = line.name
        item.svar = line.id
      end
    end
    find.visible = true
    find:search("input").text = ui.get_text("gm_command|find_text")
    find:search("input").focus = true
    search_list.visible = true
  end
end
function on_mouse_input(panel, msg)
  if msg == ui.mouse_lbutton_down then
    close_all_list()
  end
end
