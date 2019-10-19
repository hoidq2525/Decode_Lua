g_excel_id = nil
g_mstone_id = nil
g_select_reward = nil
function set_milestone_quest_value(mstone_id, quest_id)
  local excel = bo2.gv_milestone_list:find(mstone_id)
  local qi = ui.quest_find(quest_id)
  if qi == nil then
    return
  end
  if excel == nil then
    return
  end
  set_current_quest_desc_stone(excel)
  local can_finish = set_current_quest_aim_stone(qi, mstone_id)
  set_current_quest_reward(excel, true)
  set_current_quest_select_reward(excel, true)
  return can_finish
end
function set_current_quest_desc_stone(excel)
  ui_quest.w_quest_desc:item_clear()
  ui_quest.w_desc_title.text = excel.name
  set_quest_desc_txt(excel.details)
end
function set_current_quest_aim_stone(quest_info, mstone_id)
  local mstone = bo2.gv_milestone_list:find(mstone_id)
  if mstone == nil then
    ui_quest.w_quest_aim:item_clear()
    return
  end
  local item = get_item("quest_aim")
  local comp = quest_info.mstone_comp
  ui_quest.w_quest_aim:item_clear()
  local quest_obj = bo2.gv_quest_object:find(mstone.req_obj)
  local excel = ui.quest_get_qobj_excel(mstone.req_obj, mstone.req_id)
  local name
  local brief = mstone.brief
  local all_text = ""
  if brief ~= L("") then
    all_text = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, brief)
  end
  if excel ~= nil then
    name = excel.name
  end
  if mstone_id ~= quest_info.mstone_id then
    comp = ui_quest.get_aim_max_num(mstone.req_obj, mstone, 0, true)
  end
  local total_num = ui_quest.get_aim_max_num(mstone.req_obj, mstone, 0, true)
  comp = ui_quest.reset_value(mstone.req_obj, comp, total_num)
  local obj_name
  if quest_obj then
    obj_name = quest_obj.name
  end
  if excel ~= nil then
    local v = sys.variant()
    v:set("color", ui_quest.c_aim_color)
    v:set("do", obj_name)
    v:set("something", name)
    v:set("cur_num", comp)
    v:set("total_num", total_num)
    local content = sys.mtf_merge(v, ui.get_text("quest|quest_object_text"))
    all_text = sys.format([[
%s
%s]], all_text, content)
  end
  ui_quest.box_insert_text(ui_quest.w_quest_aim, all_text)
  ui_quest.w_quest_aim.parent:tune("aim_box")
  if total_num > comp then
    return false
  end
  return true
end
function is_milestone_selected(id, view_type_name)
  local root = ui_quest.w_quest_tree.root:search(view_type_name)
  local root_size = root.item_count
  for i = 0, root_size - 1 do
    local item = root:item_get(i)
    local item_size = item.item_count
    for j = 0, item_size - 1 do
      local child_item = item:item_get(j)
      if child_item.obtain_title:search("select").visible == true then
        local mstone_id = child_item.var:get("mstone_id").v_int
        if mstone_id == id then
          return true
        end
      end
    end
  end
  return false
end
function insert_child_item(item, text, mstone_id, quest_id, item_type)
  local child_item_uri = "$frame/quest/quest.xml"
  local child_item_style = "quest_tree_item2"
  local child_item = item:item_append()
  child_item.obtain_title:load_style(child_item_uri, child_item_style)
  local title = child_item:search("item_text")
  title.text = text
  if sys.is_file("$cfg/tool/pix_dj2_config.xml") then
    child_item:search("mstone_id").text = mstone_id
    child_item:search("mstone_id").visible = true
  else
    child_item:search("mstone_id").visible = false
  end
  if item_type == nil then
    item_type = item.var:get("item_type").v_int
  end
  child_item.var:set("mstone_id", mstone_id)
  child_item.var:set("excel_id", quest_id)
  child_item.var:set("item_type", item_type)
  local quest_info = ui.quest_find(quest_id)
  local cur_is_completed = false
  if item_type == ui_quest.QUEST_FINISHED_ITEM or mstone_id ~= quest_info.mstone_id then
    title.text = sys.format("%s(%s)", text, ui.get_text("quest|quest_complete"))
    cur_is_completed = true
  end
  child_item.obtain_title:search("quest_cur_finished").visible = cur_is_completed
  child_item.obtain_title:search("quest_cur_unfinished").visible = not cur_is_completed
  return child_item
end
function on_milestone_update(quest_info)
  local view_type_name = get_view_type_name(quest_info)
  update_milestone(quest_info, view_type_name)
end
function update_milestone(quest_info, view_type_name)
  local milestone = bo2.gv_milestone_list:find(quest_info.mstone_id)
  if milestone ~= nil then
    local obj = bo2.gv_quest_object:find(milestone.req_obj)
    local content
    if obj ~= nil then
      local name1 = obj.name
      local name_repute = ui_quest.get_repute_req_name(milestone.req_obj)
      name1 = name1 .. name_repute
      local obj_excel = ui.quest_get_qobj_excel(milestone.req_obj, milestone.req_id)
      local name2 = ""
      if obj_excel ~= nil then
        name2 = obj_excel.name
      end
      local total_num = ui_quest.get_aim_max_num(milestone.req_obj, milestone, 0, true)
      local cur_num = 0
      if quest_info == nil then
        cur_num = 0
      else
        cur_num = quest_info.mstone_comp
      end
      if total_num <= cur_num then
        cur_num = total_num
      end
      cur_num = ui_quest.reset_value(milestone.req_obj, cur_num, total_num)
      local v = sys.variant()
      v:set("color", ui_quest.c_aim_color)
      v:set("do", name1)
      v:set("something", name2)
      v:set("cur_num", cur_num)
      v:set("total_num", total_num)
      content = sys.mtf_merge(v, ui.get_text("quest|quest_object_text"))
      if is_milestone_selected(quest_info.mstone_id, view_type_name) then
        set_current_quest_aim_stone(quest_info, quest_info.mstone_id)
      end
    end
    if 0 <= quest_info.mstone_comp and quest_info.mstone_comp >= milestone.req_num or 0 > quest_info.mstone_comp and quest_info.mstone_comp == milestone.req_num then
      ui.log("cur comp %d,req_num %d", quest_info.mstone_comp, milestone.req_num)
      ui_quest.quest_paly_sound(g_sound_milestone_finish)
      if milestone.avi_id ~= 0 then
        ui_quest.quest_play_cg(milestone.avi_id)
      end
      ui_quest.send_next_milestone(quest_info.excel_id, 0)
      if content ~= nil then
        ui_quest.quest_show_text(content, ui_quest.c_inform_color)
      end
      if quest_info.excel_id == 2036 then
        ui_personal.ui_equip.update_slotenhance_milestone(quest_info.mstone_id)
      end
    end
  end
  local excel = quest_info.excel
  local tab_wnd = ui_widget.ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local root = tab_wnd:search("quest_tree").root
  local size = root.item_count
  local last_mtone_id
  if excel.type == bo2.eQuestType_Loop then
    for i = 0, size - 1 do
      local item = root:item_get(i)
      local excel_id = item.var:get("excel_id").v_int
      if excel_id == quest_info.excel_id then
        item:item_clear()
        local milestone = bo2.gv_milestone_list:find(quest_info.mstone_id)
        if milestone == nil then
          break
        end
        local c_item = insert_child_item(item, milestone.name, milestone.id, quest_info.excel_id)
        set_milestone_quest_value(milestone.id, quest_info.excel_id)
        c_item.selected = true
        break
      end
    end
  else
    local flag = false
    local flag_item
    for i = 0, size - 1 do
      local item = root:item_get(i)
      local excel_id = item.var:get("excel_id").v_int
      if excel_id == quest_info.excel_id then
        flag_item = item
        local item_size = item.item_count
        for j = 0, item_size - 1 do
          local child_item = item:item_get(j)
          local id = child_item.var:get("mstone_id").v_int
          if id == quest_info.mstone_id then
            flag = true
          else
            local mstone_excel = bo2.gv_milestone_list:find(id)
            local title = child_item:search("item_text")
            title.text = sys.format("%s(%s)", mstone_excel.name, ui.get_text("quest|quest_complete"))
            child_item:search("quest_cur_finished").visible = true
            child_item:search("quest_cur_unfinished").visible = false
          end
          last_mtone_id = id
        end
      end
    end
    if flag == false then
      local milestone = bo2.gv_milestone_list:find(quest_info.mstone_id)
      if milestone == nil then
        return
      end
      local c_item = insert_child_item(flag_item, milestone.name, milestone.id, quest_info.excel_id)
      ui_quest.ui_milestone.show_inform_milestone(quest_info.excel_id, milestone.id)
      set_milestone_quest_value(milestone.id, quest_info.excel_id)
      c_item.selected = true
    end
  end
  local item = get_list_item(quest_info.excel_id, quest_info.mstone_id, view_type_name)
  if item == nil then
    return
  end
  local fader = item:search("fader")
  local t = {
    quest_id = quest_info.excel_id,
    mstone_id = quest_info.mstone_id,
    fader = fader
  }
  if milestone ~= nil and quest_info.mstone_comp >= milestone.req_num and 0 <= quest_info.mstone_comp then
    ui_quest.w_timer.suspended = false
    fader_add(t)
  elseif 0 > quest_info.mstone_comp and quest_info.mstone_comp == milestone.req_num then
    ui_quest.w_timer.suspended = false
    fader_add(t)
  else
    fader_remove(t)
  end
end
