local commend_root_name = "tuijian"
local recommend_area = ui.get_text("quest|recommend_area")
local recommend_repute = ui.get_text("quest|recommend_repute")
local recommend_scn = ui.get_text("quest|recommend_scn")
local recommend_task = ui.get_text("quest|recommend_task")
g_fit_quests = {
  count = 0,
  value = {}
}
g_not_fit_quests = {
  count = 0,
  value = {}
}
g_commend_type_def = {}
function on_commend_init()
  g_commend_type_def[ui_quest.COMMEND_SCN_ITEM] = {
    content = on_commend_scn,
    sel = on_commend_scn_sel,
    item_name = recommend_scn
  }
  g_commend_type_def[ui_quest.COMMEND_QUEST_ITEM] = {
    content = on_commend_quest,
    sel = on_commend_quest_sel,
    item_name = recommend_task
  }
  add_commend()
end
function add_commend()
  insert_tree_item(nil, commend_root_name, ui_quest.COMMEND_SCN_ITEM)
  insert_tree_item(nil, commend_root_name, ui_quest.COMMEND_QUEST_ITEM)
end
function on_commend_update()
  local tab_wnd = ui_widget.ui_tab.get_page(ui_quest.w_quest_list, commend_root_name)
  if tab_wnd == nil then
    return
  end
  local root = tab_wnd:search("quest_tree").root
  local item_area, item_rep, item_scn, item_quest
  for i = 0, root.item_count - 1 do
    local item = root:item_get(i)
    local item_type = item.var:get("item_type").v_int
    if item_type == ui_quest.COMMEND_QUEST_ITEM then
      item_quest = item
    end
  end
  local level = bo2.player:get_atb(bo2.eAtb_Level)
  on_commend_quest(item_quest)
  local item_size = item_quest.item_count
end
function insert_commend_child(item, data)
  local item_uri = "$frame/quest/quest.xml"
  local item_style = "quest_tree_item2"
  local child_item = item:item_append()
  child_item.obtain_title:load_style(item_uri, item_style)
  local item_type = item.var:get("item_type").v_int
  local cur_finished_panel = child_item.obtain_title:search("cur_finished_panel")
  cur_finished_panel.visible = false
  local lb = child_item.obtain_title:search("item_text")
  if item_type == ui_quest.COMMEND_AREA_ITEM then
    local text = ui.get_text("quest|quest_commend_area")
    lb.text = text
  elseif item_type == ui_quest.COMMEND_REPU_ITEM then
    local excel = bo2.gv_quest_commend_reputation:find(data.rep_id)
    if excel ~= nil then
      lb.text = excel.name
    end
    child_item.var:set("rep_id", data.rep_id)
  elseif item_type == ui_quest.COMMEND_SCN_ITEM then
  elseif item_type == ui_quest.COMMEND_QUEST_ITEM then
    local excel = bo2.gv_quest_list:find(data.quest_id)
    if excel ~= nil then
      lb.text = excel.name
    end
    child_item.var:set("excel_id", data.quest_id)
  end
  child_item.var:set("item_type", item_type)
end
function on_commend_area(item)
end
function on_commend_reputation(item)
  local size = bo2.gv_quest_commend_reputation.size
  for i = 1, size do
    local data = {rep_id = i}
    insert_commend_child(item, data)
  end
end
function on_commend_scn(item)
end
function on_commend_quest(item)
  item:item_clear()
  g_fit_quests.count = 0
  g_not_fit_quests.count = 0
  if bo2.player == nil then
    return
  end
  local level = bo2.player:get_atb(bo2.eAtb_Level)
  local size = bo2.gv_quest_list.size
  for i = 0, size - 1 do
    local excel = bo2.gv_quest_list:get(i)
    if excel.gps_target_id ~= 0 and ui.quest_check_insert(excel.id) and bo2.is_cooldown_over(excel.cooldown) == true and level >= excel.difficulty - 5 and level <= excel.difficulty + 5 and excel.in_recommend == 0 then
      local data = {
        quest_id = excel.id
      }
      insert_commend_child(item, data)
    end
  end
end
function insert_area_item(list, text)
  local item_uri = L("$frame/quest/quest.xml")
  local item_style = L("area_item")
  local item = list:item_append()
  item:load_style(item_uri, item_style)
  item.size = ui.point(327, 38)
  item.dy = 38
  local color_text = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, text)
  local box = item:search("box")
  box:item_clear()
  ui_quest.box_insert_text(box, color_text)
  box.parent:tune("box")
  local idx = item.index
  local bg = item:search("bg")
  if math.fmod(idx, 2) == 0 then
    bg.visible = false
  end
end
function on_commend_area_sel(item)
  local item_type = item.var:get("item_type").v_int
  local w_commend_parent_list = ui_quest.w_commend_parent_list
  w_commend_parent_list:item_clear()
  ui_quest.w_desc_title.text = ui.get_text("quest|nick_area")
  local size = bo2.gv_quest_commend_area.size
  for i = 0, size - 1 do
    local excel = bo2.gv_quest_commend_area:get(i)
    local level = excel.level
    local p_level = bo2.player:get_atb(bo2.eAtb_Level)
    if p_level <= level + 2 and p_level >= level - 2 then
      insert_area_item(w_commend_parent_list, excel.text)
    end
  end
end
function on_commend_reputation_sel(item)
  ui_quest.w_desc_title.text = quest_place
  ui_quest.w_quest_desc:item_clear()
  ui_quest.w_talk_box:item_clear()
  local rep_id = item.var:get("rep_id").v_int
  local excel = bo2.gv_quest_commend_reputation:find(rep_id)
  if excel == nil then
    return
  end
  local t_text = ""
  t_text = sys.format("%s%s\n", t_text, excel.text)
  set_quest_desc_txt(t_text)
  if excel.desc == nil then
    return
  end
  local text = excel.desc
  text = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, text)
  ui_quest.box_insert_text(ui_quest.w_talk_box, text)
  ui_quest.w_talk_box.parent:tune_y("box")
end
function on_commend_scn_sel(item)
  ui_quest.w_desc_title.text = ui.get_text("quest|copy_area")
end
function on_commend_quest_sel(item)
  set_receive_quest_value(record.quest_id, item)
end
