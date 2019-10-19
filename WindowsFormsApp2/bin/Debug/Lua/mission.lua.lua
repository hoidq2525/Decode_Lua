local root_filted = {
  btn_node_shiming = {
    name = "btn_node_shiming",
    quest_num = 0
  },
  btn_node_shengwang = {
    name = "btn_node_shengwang",
    quest_num = 0
  },
  btn_node_putong = {
    name = "btn_node_putong",
    quest_num = 0
  },
  btn_node_chongfu = {
    name = "btn_node_chongfu",
    quest_num = 0
  }
}
local quest_list_complete = {}
local g_sound_aim_finish = 503
local quest_text_empty = ui.get_text("quest|quest_text_empty")
local quest_liezhuan = ui.get_text("quest|quest_liezhuan")
local inprogress_num = ui.get_text("quest|inprogress_num")
local finish_num = ui.get_text("quest|finish_num")
local rcv_num = ui.get_text("quest|rcv_num")
local tracing_tip1 = ui.get_text("quest|tracing_tip1")
local tracing_tip2 = ui.get_text("quest|tracing_tip2")
local giveup_quest = ui.get_text("quest|giveup_quest")
local giveup_confirm = ui.get_text("quest|giveup_confirm")
filted_show_type = 0
record = {
  i = 10000,
  j = 10000,
  k = 10000,
  quest_id,
  milestone_id
}
local g_faders = {}
local quest_finished_num = 0
local quest_accept_num = 0
local fader_tracing_y = 1
local fader_tracing_n = 0.5
local color_tracing_y = ui.make_argb("FFFFFFFF")
local color_tracing_n = ui.make_argb("88FFFFFF")
local ui_tab = ui_widget.ui_tab
function get_item(name)
  local item = ui_quest.quest_info:search(name)
  return item
end
function get_view_type_name(quest_info, excel_id)
  local excel
  if quest_info == nil then
    excel = bo2.gv_quest_list:find(excel_id)
  else
    excel = quest_info.excel
  end
  if excel == nil then
    print("mission::get_view_type_name excel is nil")
    return
  end
  local type = excel.in_theme
  local insert_name = "shiming"
  if type == 2 or type == 7 or type == 8 or type == 11 or type == 12 then
    insert_name = "shiming"
  elseif type == 4 or type == 16 then
    insert_name = "shengwang"
  elseif type == 15 then
    insert_name = "banghui"
  elseif excel.type == 0 then
    insert_name = "putong"
  else
    insert_name = "chongfu"
  end
  return insert_name
end
function is_theme_exist(theme_id, view_type_name)
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local root = tab_wnd:search("quest_tree").root
  local root_size = root.item_count
  for i = 0, root_size - 1 do
    local item = root:item_get(i)
    local excel_id = item.var:get("excel_id").v_int
    local in_theme = ui.quest_find(excel_id).excel.in_theme
    if in_theme == theme_id then
      return i
    end
  end
  return nil
end
function fader_add(t)
  for i, v in ipairs(g_faders) do
    if v.quest_id == t.quest_id then
      v.mstone_id = t.mstone_id
      v.fader = t.fader
      return
    end
  end
  table.insert(g_faders, t)
end
function fader_remove(t)
  for i, v in ipairs(g_faders) do
    if v.quest_id == t.quest_id then
      if sys.check(v.fader) then
        v.fader:search("select").visible = false
        v.fader:reset(1, 0, 100)
      end
      table.remove(g_faders, i)
      break
    end
  end
end
function get_list_item(quest_id, mstone_id, view_type_name)
  local view_type_name = get_view_type_name(quest_info, quest_id)
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local root = tab_wnd:search("quest_tree").root
  local size = root.item_count
  for i = 0, size - 1 do
    local item = root:item_get(i)
    local excel_id = item.var:get("excel_id").v_int
    if excel_id == quest_id then
      local item_size = item.item_count
      for j = 0, item_size - 1 do
        local child_item = item:item_get(j)
        local id_m = child_item.var:get("mstone_id").v_int
        if id_m == mstone_id then
          return child_item
        end
      end
    end
  end
  return nil
end
function set_quest_value(excel_id)
  if excel_id == nil then
    return
  end
  local excel = bo2.gv_quest_list:find(excel_id)
  local quest_info = ui.quest_find(excel_id)
  if quest_info == nil then
    quest_info = ui.guild_quest_find(excel_id)
    if quest_info == nil then
      return
    end
  end
  local list = quest_info.excel
  set_current_quest_desc(list)
  set_current_quest_aim(quest_info)
  set_current_quest_reward(list)
  set_current_quest_select_reward(list)
  local item = ui_quest.w_parent_list:search("reward_panel_all")
  local reward = item:search("quest_rewards")
  local select = item:search("quest_select_rewards")
  if select.dy > reward.dy then
    item.dy = select.dy
    item:search("select").dy = select.dy
  else
    item.dy = reward.dy
    item:search("reward").dy = reward.dy
  end
end
function set_quest_desc_txt(text)
  if text ~= nil then
    ui_quest.w_quest_desc:item_clear()
    local details
    details = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, text)
    ui_quest.box_insert_text(ui_quest.w_quest_desc, details)
    ui_quest.w_quest_desc.parent:tune_y("desc")
  end
end
function set_current_quest_desc(list)
  ui_quest.w_desc_title.text = list.name
  ui_quest.w_quest_desc:item_clear()
  if list.text ~= nil then
    set_quest_desc_txt(list.text.details)
  end
end
function set_current_quest_aim(quest_info)
  if quest_info.completed then
  else
  end
  local list = quest_info.excel
  ui_quest.w_quest_aim:item_clear()
  if list.text ~= nil then
    local item = get_item("quest_aim")
    local goal = list.text.goal
    local all_text = ""
    all_text = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, goal)
    for i = 0, 3 do
      local cur_num = quest_info.comp[i]
      local obj = bo2.gv_quest_object:find(list.req_obj[i])
      if obj ~= nil and obj.id ~= bo2.eQuestObj_NpcCollect then
        local name1 = obj.name
        local name_repute = ui_quest.get_repute_req_name(list.req_obj[i])
        name1 = name1 .. name_repute
        local excel = ui.quest_get_qobj_excel(list.req_obj[i], list.req_id[i])
        local name2 = ""
        if excel ~= nil then
          name2 = excel.name
        end
        if list.req_obj[i] == bo2.eQuestObj_Quest then
          name2 = ui.get_text("quest|milestone_step")
        end
        local total_num = ui_quest.get_aim_max_num(list.req_obj[i], list, i, false)
        cur_num = ui_quest.reset_value(list.req_obj[i], cur_num, total_num)
        local v = sys.variant()
        v:set("color", ui_quest.c_aim_color)
        v:set("do", name1)
        v:set("something", name2)
        v:set("cur_num", cur_num)
        v:set("total_num", total_num)
        local content = sys.mtf_merge(v, ui.get_text("quest|quest_object_text"))
        all_text = sys.format([[
%s
%s]], all_text, content)
      end
    end
    ui_quest.box_insert_text(ui_quest.w_quest_aim, all_text)
    ui_quest.w_quest_aim.parent:tune_y("aim_box")
  else
    ui_tool.note_insert(quest_text_empty, "FFFF0000")
  end
end
function set_current_quest_reward(list, m)
  ui_quest.set_quest_rewards(ui_quest.w_rewards_list, list, ui_quest.w_parent_list, "quest_rewards", m)
end
function set_current_quest_select_reward(list, m)
  ui_quest.set_quest_select_rewards(ui_quest.w_select_rewards_list, list, ui_quest.w_parent_list, "quest_select_rewards", m)
end
function add_mission_quest(quest_info)
  local view_type_name = get_view_type_name(quest_info)
  insert_tree_item(quest_info, view_type_name, ui_quest.QUEST_GOING_ITEM)
  update_milestone(quest_info, view_type_name)
end
function add_finished_quest(excel_id)
  ui.log("add_finished_quest" .. excel_id)
  local view_type_name = get_view_type_name(nil, excel_id)
  insert_tree_item(excel_id, view_type_name, ui_quest.QUEST_FINISHED_ITEM)
  ui_minimap.read_misc()
end
function clear_quest_info()
  ui_quest.w_quest_aim:item_clear()
  ui_quest.w_quest_desc:item_clear()
  ui_quest.w_rewards_list:item_clear()
  ui_quest.w_select_rewards_list:item_clear()
  ui_quest.w_talk_box:item_clear()
  local talk_content = get_item("talk_content")
  talk_content.visible = false
  ui_quest.w_desc_title.text = ""
  record.quest_id = nil
  record.milestone_id = nil
  set_quest_info_vis()
end
function update_quest_num(view_type_name)
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local root = tab_wnd:search("quest_tree").root
  local finished_num = root.var:get("finished_num").v_int
  local accept_num = root.var:get("accept_num").v_int
  local pic_finished_all = root:search("quest_all_finished")
  if accept_num == finished_num and accept_num ~= 0 then
    pic_finished_all.visible = true
  else
    pic_finished_all.visible = false
  end
end
function delete_current_quest(quest_info, quest_id)
  local excel_id = 0
  if quest_info == nil then
    excel_id = quest_id
  else
    excel_id = quest_info.excel_id
  end
  local view_type_name = get_view_type_name(quest_info, excel_id)
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local root = tab_wnd:search("quest_tree").root
  local root_size = root.item_count
  for i = 0, root_size - 1 do
    local item = root:item_get(i)
    local excel_id_item = item.var:get("excel_id").v_int
    if excel_id_item == excel_id then
      root:item_remove(i)
      if record.quest_id == excel_id then
        record.quest_id = 0
        record.milestone_id = 0
      end
      recover_root_style(view_type_name)
      return
    end
  end
end
function insert_tree_item(quest_info, view_type_name, item_type)
  local item_uri = "$frame/quest/quest.xml"
  local item_style = "quest_tree_item1"
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  if tab_wnd == nil then
    return
  end
  local root = tab_wnd:search("quest_tree").root
  local excel_id, list
  local finished_vis = false
  if item_type >= ui_quest.COMMEND_START and item_type <= ui_quest.COMMEND_END then
  elseif item_type == ui_quest.QUEST_FINISHED_ITEM then
    excel_id = quest_info
    list = bo2.gv_quest_list:find(excel_id)
    finished_vis = true
  elseif item_type == ui_quest.QUEST_RECEIVE_ITEM then
    list = quest_info
    excel_id = list.id
    finished_vis = false
  else
    excel_id = quest_info.excel_id
    list = quest_info.excel
    finished_vis = quest_info.completed
  end
  local app_item = root:item_append()
  local the_title = app_item.obtain_title
  the_title:load_style(item_uri, item_style)
  app_item.var:set("item_type", item_type)
  app_item.expanded = false
  local tracing_pic = the_title:search("pic_tracing_not")
  tracing_pic.visible = false
  tracing_pic.color = color_tracing_n
  if item_type >= ui_quest.COMMEND_START and item_type <= ui_quest.COMMEND_END then
    the_title:search("title_label").text = g_commend_type_def[item_type].item_name
    the_title:search("title_name").text = ""
    the_title:search("quest_cur_finished").visible = false
    the_title:search("quest_cur_unfinished").visible = false
    if g_commend_type_def[item_type].content ~= nil then
      g_commend_type_def[item_type].content(app_item)
    end
  else
    if item_type == ui_quest.QUEST_GOING_ITEM then
      local t_info = ui.tracing_find(list.id)
      tracing_pic.visible = true
      if t_info ~= nil then
        tracing_pic.color = color_tracing_y
        tracing_pic.var:set("is_trace", 1)
      else
        tracing_pic.var:set("is_trace", 0)
      end
      if view_type_name == "banghui" then
        tracing_pic.visible = false
      end
    end
    local is_show = false
    if 0 < filted_show_type then
      if item_type == filted_show_type then
        app_item.display = true
        is_show = true
      else
        app_item.display = false
      end
    end
    local awd_exp_new = ui_quest.exp_weaken(list, list.awd_exp)
    if awd_exp_new ~= list.awd_exp and awd_exp_new == 500 then
      the_title:search("title_label").color = ui.make_color("6C5661")
      the_title:search("title_name").color = ui.make_color("6C5661")
    end
    the_title:search("title_label").text = ui_quest.get_quest_type(list)
    the_title:search("title_name").text = list.name
    if sys.is_file("$cfg/tool/pix_dj2_config.xml") then
      the_title:search("quest_id").text = list.id
      the_title:search("quest_id").visible = true
    else
      the_title:search("quest_id").visible = false
    end
    the_title:search("quest_cur_finished").visible = finished_vis
    the_title:search("quest_cur_unfinished").visible = not finished_vis
    if item_type == ui_quest.QUEST_RECEIVE_ITEM then
      the_title:search("quest_cur_finished").visible = false
      the_title:search("quest_cur_unfinished").visible = false
    end
    app_item.var:set("excel_id", list.id)
    if quest_list_complete[view_type_name] == nil then
      quest_list_complete[view_type_name] = {}
    end
    local milestones = list.milestones
    local size = milestones.size
    local accept_num_add = 0
    local finished_num_add = 0
    if item_type == ui_quest.QUEST_RECEIVE_ITEM then
      table.insert(receive_item_tbl, app_item)
    elseif item_type == ui_quest.QUEST_FINISHED_ITEM then
      finished_num_add = finished_num_add + 1
      accept_num_add = accept_num_add + 1
      for i = 0, size - 1 do
        local milestone = bo2.gv_milestone_list:find(list.milestones[i])
        if milestone ~= nil then
          insert_child_item(app_item, milestone.name, milestone.id, list.id, item_type)
        end
      end
    elseif list.type == bo2.eQuestType_Loop then
      accept_num_add = accept_num_add + 1
      local milestone_list = bo2.gv_milestone_list:find(quest_info.mstone_id)
      if milestone_list ~= nil then
        insert_child_item(app_item, milestone_list.name, milestone_list.id, excel_id, item_type)
      end
    else
      accept_num_add = accept_num_add + 1
      for i = 0, size - 1 do
        local milestone_list = bo2.gv_milestone_list:find(milestones[i])
        if milestones[i] == quest_info.mstone_id then
          insert_child_item(app_item, milestone_list.name, milestone_list.id, excel_id, item_type)
          break
        end
        insert_child_item(app_item, milestone_list.name, milestone_list.id, excel_id, item_type)
      end
    end
  end
  if item_type == ui_quest.COMMEND_QUEST_ITEM then
    return
  end
  local item_size = app_item.item_count
  if item_size == 0 or item_type == ui_quest.QUEST_RECEIVE_ITEM then
    local btn_minus = the_title:search("btn_minus")
    local btn_plus = the_title:search("btn_plus")
    local minus_pic = btn_minus:search("btn_pic")
    local plus_pic = btn_plus:search("btn_pic")
    minus_pic.visible = false
    plus_pic.visible = false
  end
end
function is_selected(id, view_type_name)
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local root = tab_wnd:search("quest_tree").root
  local root_size = root.item_count
  for i = 0, root_size - 1 do
    local item = root:item_get(i)
    if item.obtain_title:search("select").visible == true then
      local excel_id = item.var:get("excel_id").v_int
      if excel_id == id then
        return true
      end
    end
  end
  return false
end
function is_milestone_selected(id, view_type_name)
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local root = tab_wnd:search("quest_tree").root
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
function on_current_update(quest_info)
  local view_type_name = get_view_type_name(quest_info)
  if is_selected(quest_info.excel_id, view_type_name) then
    set_current_quest_aim(quest_info)
    set_current_quest_reward(quest_info.excel)
  end
  if is_milestone_selected(quest_info.mstone_id, view_type_name) then
    set_current_quest_aim_stone(quest_info, quest_info.mstone_id)
  end
  if quest_info.completed then
    local excel = quest_info.excel
    if excel.type == bo2.eQuestType_Repeat then
      for i = 0, 3 do
        if 0 < quest_info.comp[i] and (quest_info.comp[i] == excel.req_min[i] or quest_info.comp[i] == excel.req_max[i]) then
          ui_quest.quest_paly_sound(g_sound_aim_finish)
        end
      end
    else
      ui_quest.quest_paly_sound(g_sound_aim_finish)
    end
  end
end
function set_sort_root_val()
  ui_quest.w_desc_title.text = quest_liezhuan
  ui_quest.w_quest_desc:item_clear()
end
function on_num_mouse(ctrl, msg)
  if msg ~= ui.mouse_lbutton_click then
    return
  end
  local item = ctrl.parent.parent.item
  if item == nil then
    return
  end
  on_tree_node_toggle_click(ctrl)
end
function on_btn_move(ctrl, msg, pos, wheel)
  local item = ctrl.parent.item
  local pic_move = item:search("pic_move")
  if pic_move == nil then
    return
  end
  if msg == ui.mouse_inner and item.selected == false then
    local fader = item:search("fader")
    fader.visible = true
    pic_move.visible = true
  end
  if msg == ui.mouse_outer or item.selected then
    pic_move.visible = false
  end
end
function on_tree_node_toggle_click(btn)
  local item = btn.parent.parent.item
  if ui.is_key_down(ui.VK_CONTROL) then
    local milestone_id = item.var:get("mstone_id").v_int
    if milestone_id ~= 0 then
      local quest_id = item.var:get("excel_id").v_int
      ui_chat.insert_milestone(quest_id, milestone_id)
    else
      ui_chat.insert_quest(item.var:get("excel_id").v_int)
    end
    return
  end
  ui_widget.on_tree_node_toggle_click(btn)
  item.selected = true
  local item_child = item:item_get(0)
  if item_child == nil then
    return
  end
  item_child:scroll_to_visible()
end
function on_item_expanded(ctrl, v)
end
function on_item_sel(ctrl, v)
  local s = ctrl:search("select")
  s.visible = v
  s.parent.visible = v
  s.parent.alpha = 1
  if v then
    local pic_move = ctrl:search("pic_move")
    if pic_move then
      pic_move.visible = not v
    end
    local item_type = ctrl.var:get("item_type").v_int
    set_quest_info_vis(item_type)
    record.quest_id = ctrl.var:get("excel_id").v_int
    record.milestone_id = nil
    local excel = bo2.gv_quest_list:find(record.quest_id)
    if item_type >= ui_quest.COMMEND_START and item_type <= ui_quest.COMMEND_END then
      g_commend_type_def[item_type].sel(ctrl)
    elseif item_type == ui_quest.QUEST_FINISHED_ITEM then
      local mstone_id = ctrl.var:get("mstone_id").v_int
      if mstone_id == 0 then
        set_finished_quest_desc(record.quest_id)
      else
        set_finished_milestone_desc(mstone_id, record.quest_id)
      end
    elseif item_type == ui_quest.QUEST_RECEIVE_ITEM then
      set_receive_quest_value(record.quest_id)
    elseif item_type == ui_quest.QUEST_SORT_ROOT then
      local name = ctrl.name
      local tag_name = string.sub(tostring(name), 10)
      ui_quest.quest_tag_txt.text = ui.get_text("quest|retsuden_" .. tag_name)
      set_sort_root_val()
    elseif excel.in_theme == bo2.eThemeType_Guild_Shd then
      local var = sys.variant()
      var:set(packet.key.quest_id, record.quest_id)
      bo2.send_variant(packet.eCTS_Guild_UpdateShdQuest, var)
    else
      set_quest_value(record.quest_id)
    end
    if 1 > record.quest_id then
      return
    end
    if excel.in_theme == bo2.eThemeType_Guild_Shd then
      ui_quest.w_btn_complete.visible = false
      ui_quest.w_btn_share.visible = false
      ui_quest.w_btn_giveup.visible = false
      return
    end
    if excel.in_theme == bo2.eThemeType_Mission then
      ui_quest.w_btn_share.enable = false
      ui_quest.w_btn_giveup.enable = false
    else
      ui_quest.w_btn_share.enable = true
      ui_quest.w_btn_giveup.enable = true
    end
    if excel.no_share == 1 then
      ui_quest.w_btn_share.enable = false
    end
    if excel.type == bo2.eQuestType_Loop then
      ui_quest.w_btn_share.enable = false
    end
    if excel.in_theme == bo2.eThemeType_Daily or excel.in_theme == bo2.eThemeType_NoGiveup or excel.in_theme == bo2.eThemeType_IMNoGiveUp or excel.in_theme == bo2.eThemeType_Consign or excel.in_theme == bo2.eThemeType_Tutorial then
      ui_quest.w_btn_giveup.enable = false
    end
    local quest_info = ui.quest_find(record.quest_id)
    if quest_info == nil then
      return
    end
    local mstone_id = ctrl.var:get("mstone_id").v_int
    if mstone_id > 0 then
      local can_finish = false
      record.milestone_id = mstone_id
      if item_type == ui_quest.QUEST_FINISHED_ITEM then
        set_finished_milestone_desc(mstone_id, record.quest_id)
        ui_quest.w_btn_share.visible = false
        ui_quest.w_btn_giveup.visible = false
      else
        can_finish = set_milestone_quest_value(mstone_id, record.quest_id)
        ui_quest.w_btn_share.visible = true
        ui_quest.w_btn_giveup.visible = true
        ui_quest.w_btn_share.enable = false
        ui_quest.w_btn_giveup.enable = false
      end
      if quest_info.mstone_id ~= mstone_id then
        ui_quest.w_btn_complete.enable = false
        return
      end
      if can_finish then
        ui_quest.w_btn_complete.enable = can_finish
        return
      end
    end
    if excel.end_obj ~= bo2.eQuestObj_Null and excel.end_obj ~= bo2.eQuestObj_IMHero then
      ui_quest.w_btn_complete.enable = false
    else
      ui_quest.w_btn_complete.enable = quest_info.completed
    end
    if excel.type == bo2.eQuestType_Loop and quest_info.mstone_id then
      ui_quest.w_btn_complete.enable = false
    end
  end
end
function on_num_tip_make(tip)
  local ctrl = tip.owner
  local stk = sys.mtf_stack()
  local show_text = ""
  if filted_show_type == ui_quest.QUEST_GOING_ITEM then
    show_text = inprogress_num
  elseif filted_show_type == ui_quest.QUEST_FINISHED_ITEM then
    show_text = finish_num
  elseif filted_show_type == ui_quest.QUEST_RECEIVE_ITEM then
    show_text = rcv_num
  else
    return
  end
  ui_widget.tip_make_view(tip.view, show_text)
end
function filtitem_by_type(item_type_show)
  local function item_filting(key, val)
    local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, key)
    local root = tab_wnd:search("quest_tree").root
    val.num = 0
    for i = 0, root.item_count - 1 do
      local item = root:item_get(i)
      local item_type = item.var:get("item_type").v_int
      item.display = item_type == item_type_show
      for j = 0, item.item_count - 1 do
        local sub_item = item:item_get(j)
        if sub_item ~= nil then
          sub_item.display = item.display
        end
      end
    end
  end
  table.foreach(root_filted, item_filting)
  filted_show_type = item_type_show
  local tab_wnd = ui_tab.get_show_page(ui_quest.w_quest_list)
  if tab_wnd == nil then
    return
  end
  local sel_item = tab_wnd:search("quest_tree").item_sel
  if sel_item ~= nil and sel_item.display then
    on_item_sel(sel_item, true)
  else
    clear_quest_info()
    set_sort_root_val()
  end
end
function on_filting_click(btn)
  local name = btn.name
  if tostring(name) == "radio_quest_going" then
    filtitem_by_type(ui_quest.QUEST_GOING_ITEM)
  elseif tostring(name) == "radio_quest_finished" then
    filtitem_by_type(ui_quest.QUEST_FINISHED_ITEM)
  elseif tostring(name) == "radio_quest_receive" then
    filtitem_by_type(ui_quest.QUEST_RECEIVE_ITEM)
  end
  local cur_page = ui_tab.get_show_page(ui_quest.w_quest_list)
  recover_root_style(cur_page.name)
  ui_quest.update_quest_num_tip(L("shiming"))
  ui_quest.update_quest_num_tip(L("putong"))
  ui_quest.update_quest_num_tip(L("shengwang"))
  ui_quest.update_quest_num_tip(L("chongfu"))
end
function on_tab_chg(btn, press)
  if press then
    recover_root_style(btn.name)
    if btn.name == L("tuijian") or btn.name == L("banghui") then
      ui_quest.ui_mission.radio_going.visible = false
      ui_quest.ui_mission.radio_finished.visible = false
      ui_quest.ui_mission.radio_receive.visible = false
    else
      ui_quest.ui_mission.radio_going.visible = true
      ui_quest.ui_mission.radio_finished.visible = true
      ui_quest.ui_mission.radio_receive.visible = true
    end
    if btn.name == L("tuijian") then
      ui_quest.ui_mission.on_commend_update()
    end
  end
end
function recover_root_style(style_name)
  clear_quest_info()
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, style_name)
  local root = tab_wnd:search("quest_tree")
  local item_sel = root.item_sel
  if item_sel == nil or item_sel.selected == false then
    set_quest_info_vis(ui_quest.QUEST_SORT_ROOT)
    ui_quest.quest_tag_txt.text = ui.get_text("quest|retsuden_" .. style_name)
    set_sort_root_val()
  else
    on_item_sel(item_sel, true)
  end
end
function on_ui_init()
  root_filted = {
    shiming = {
      name = "btn_node_shiming",
      quest_num = 0
    },
    shengwang = {
      name = "btn_node_shengwang",
      quest_num = 0
    },
    putong = {
      name = "btn_node_putong",
      quest_num = 0
    },
    chongfu = {
      name = "btn_node_chongfu",
      quest_num = 0
    }
  }
  ui_quest.ui_mission.radio_going.check = true
  on_filting_click(ui_quest.ui_mission.radio_going)
  clear_quest_info()
  set_sort_root_val()
end
function update_tracing(quest_id, is_tracing)
  local view_type_name = get_view_type_name(nil, quest_id)
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local root = tab_wnd:search("quest_tree").root
  local root_size = root.item_count
  for i = 0, root_size - 1 do
    do
      local item = root:item_get(i)
      local excel_id = item.var:get("excel_id").v_int
      if quest_id == excel_id then
        local tracing_pic = item.obtain_title:search("pic_tracing_not")
        if is_tracing then
          tracing_pic.color = color_tracing_y
          tracing_pic.var:set("is_trace", 1)
        else
          tracing_pic.color = color_tracing_n
          tracing_pic.var:set("is_trace", 0)
          local obj = bo2.player
          if sys.check(obj) ~= true then
            return
          end
          local check_flag = bo2.ePlayerFlagInt16_HandsOn_Trace_Quest
          local iFlag = obj:get_flag_int16(check_flag)
          if iFlag == 0 then
            local tb = ui_handson_teach.g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Trace_Quest]
            if tb and tb.handson_teach then
              tb.handson_teach.target = tracing_pic
              do
                local flicker_control = ui.create_control(tracing_pic.parent, "panel")
                flicker_control:load_style(L("$gui/frame/quest/cmn.xml"), L("flicker_handson"))
                flicker_control:move_to_head()
                flicker_control.margin = tracing_pic.margin
                flicker_control.dock = tracing_pic.dock
                tb.handson_teach.flicker = flicker_control
                local quest_tree = tab_wnd:search("quest_tree")
                local function handson_time_check()
                  if sys.check(item) ~= true or sys.check(quest_tree) ~= true then
                    return false
                  end
                  if item.observable and item.abs_area.y1 > quest_tree.abs_area.y1 then
                    return true
                  end
                  return false
                end
                tb.handson_teach.timer_check = handson_time_check
              end
            end
            ui_handson_teach.test_complate_trace_quest(true)
            show_quest_id(excel_id)
            tracing_pic.var:set("is_handon", 1)
          end
        end
      end
    end
  end
end
function on_tracing_tips(tip)
  local ctrl = tip.owner
  local stk = sys.mtf_stack()
  local is_tracing = ctrl.var:get("is_trace").v_int
  local tips_text = ""
  if is_tracing == 0 then
    tips_text = tracing_tip1
  else
    tips_text = tracing_tip2
  end
  ui_widget.tip_make_view(tip.view, tips_text)
  if ctrl.var:has("is_handon") then
    ui_handson_teach.test_complate_trace_quest(false)
  end
end
function on_trace_click(ctrl, msg)
  if msg ~= ui.mouse_lbutton_click then
    return
  end
  local item = ctrl.parent.parent.item
  local quest_id = item.var:get("excel_id").v_int
  local view_type_name = get_view_type_name(nil, quest_id)
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local quest_tree = tab_wnd:search("quest_tree")
  local tracing_pic = ctrl
  local quest_info = ui.quest_find(quest_id)
  local t_info = ui.tracing_find(quest_id)
  local is_tracing = ctrl.var:get("is_trace").v_int
  if is_tracing == 1 then
    ui.tracing_quest_remove(quest_id)
    tracing_pic.color = color_tracing_n
    ctrl.var:set("is_trace", 0)
  else
    ui.tracing_quest_insert(quest_info)
    tracing_pic.color = color_tracing_y
    ctrl.var:set("is_trace", 1)
  end
  ui_quest.ui_tracing.set_visible(true)
  ui_quest.ui_tracing.update_tracing(quest_info)
end
function on_share_click()
  if record.quest_id < 1 then
    return
  end
  local view_type_name = get_view_type_name(nil, record.quest_id)
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local quest_tree = tab_wnd:search("quest_tree")
  local item_sel = quest_tree.item_sel
  if item_sel == nil then
    ui_tool.note_insert(ui.get_text("quest|quest_share_warning"), ui_quest.c_warning_color)
    return
  end
  if record.quest_id == nil then
    return
  end
  local data = sys.variant()
  data:set(packet.key.quest_id, record.quest_id)
  bo2.send_variant(packet.eCTS_UI_ShareQuest, data)
end
function on_give_up_quest(data)
  if data.result == 1 then
    ui_quest.giveup(record.quest_id)
  end
end
function on_drop_click(btn)
  if record.quest_id < 1 then
    return
  end
  local view_type_name = get_view_type_name(nil, record.quest_id)
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local quest_tree = tab_wnd:search("quest_tree")
  local item_sel = quest_tree.item_sel
  if item_sel ~= nil then
    local list = bo2.gv_quest_list:find(record.quest_id)
    local v = sys.variant()
    v:set("quest_name", list.name)
    msg_text = sys.mtf_merge(v, ui.get_text("quest|giveup_confirm"))
    local data = {
      title = giveup_quest,
      text = msg_text,
      callback = on_give_up_quest
    }
    ui_widget.ui_msg_box.show_common(data)
  else
    ui_tool.note_insert(ui.get_text("quest|give_up_warning"), ui_quest.c_warning_color)
  end
end
function on_complete_click(btn)
  if record.quest_id < 1 then
    return
  end
  local view_type_name = get_view_type_name(nil, record.quest_id)
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local quest_tree = tab_wnd:search("quest_tree")
  local item_sel = quest_tree.item_sel
  if item_sel == nil then
    ui_tool.note_insert(ui.get_text("quest|quest_sfc_warning"), ui_quest.c_warning_color)
    return
  end
  if ui_quest.w_select_rewards_list.item_count ~= 0 and ui_quest.g_select_reward_idx == nil and record.milestone_id == nil then
    ui_tool.note_insert(ui.get_text("quest|reward_select_warning"), ui_quest.c_warning_color)
    return
  end
  if record.milestone_id == nil then
    ui_quest.send_quest_complete(record.quest_id, ui_quest.g_select_reward_idx)
  else
    ui_quest.send_next_milestone(record.quest_id, ui_quest.g_select_reward_idx)
  end
end
function on_visible_fader_tip()
  local tab_wnd = ui_tab.get_show_page(ui_quest.w_quest_list)
  if tab_wnd == nil then
    return
  end
  local sel_item = tab_wnd:search("quest_tree").item_sel
  if sel_item ~= nil and sel_item.display then
    on_item_sel(sel_item, true)
  end
  local info = ui.quest_find(id)
  if info == nil then
    return
  end
  local view_type_name = get_view_type_name(quest_info)
  local view_type_name = get_view_type_name(nil, quest_id)
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local root = tab_wnd:search("quest_tree").root
  local size = root.item_count
  local id = 0
  for i, v in ipairs(g_faders) do
    id = v.quest_id
    break
  end
  local item
  for i = 0, size - 1 do
    item = root:item_get(i)
    local e_id = item.var:get("excel_id").v_int
    if id == e_id then
      break
    end
  end
  if item == nil then
    return
  end
  item.expanded = true
  local item_m = item:item_get(item.item_count - 1)
  local mstone_id = item_m.var:get("mstone_id").v_int
  record.quest_id = id
  record.milestone_id = mstone_id
  item_m.selected = true
  set_milestone_quest_value(mstone_id, id)
  item_m:scroll_to_visible()
end
function show_quest_id(id, mstone_id)
  local info = ui.quest_find(id)
  if info == nil then
    return
  end
  local view_type_name = get_view_type_name(info)
  local tab_wnd = ui_tab.get_page(ui_quest.w_quest_list, view_type_name)
  local root = tab_wnd:search("quest_tree").root
  local size = root.item_count
  local item, child_item
  for i = 0, size - 1 do
    item = root:item_get(i)
    local e_id = item.var:get("excel_id").v_int
    if id == e_id then
      local item_size = item.item_count
      for j = 0, item_size - 1 do
        child_item = item:item_get(j)
        local ms_id = child_item.var:get("mstone_id").v_int
        if mstone_id == ms_id then
          break
        end
      end
      break
    end
  end
  if item == nil then
    return
  end
  ui_tab.show_page(ui_quest.w_quest_list, view_type_name, true)
  ui_quest.w_main.visible = true
  item.expanded = true
  item:scroll_to_visible()
  if child_item ~= nil then
    child_item.selected = true
  else
    item.selected = true
  end
  ui.log("item count %s", item.item_count)
  ui_quest.ui_mission.radio_going.check = true
  on_filting_click(ui_quest.ui_mission.radio_going)
end
function set_finished_quest_desc(id)
  if id == nil then
    return
  end
  local excel = bo2.gv_quest_list:find(id)
  if excel == nil then
    return
  end
  ui_quest.w_desc_title.text = excel.name
  ui_quest.w_quest_desc:item_clear()
  local q_text = bo2.gv_quest_text:find(excel.id)
  if q_text == nil then
    return
  end
  set_quest_desc_txt(q_text.details)
  ui_quest.w_talk_box:item_clear()
end
function set_finished_milestone_desc(m_id, q_id)
  local m_excel = bo2.gv_milestone_list:find(m_id)
  if m_excel == nil then
    return
  end
  ui_quest.w_desc_title.text = m_excel.name
  ui_quest.w_quest_desc:item_clear()
  ui_quest.w_talk_box:item_clear()
  local t_text = ""
  t_text = sys.format("%s%s\n", t_text, m_excel.details)
  set_quest_desc_txt(t_text)
  local q_talk = bo2.gv_quest_talk:find(m_excel.talk_id)
  local divide = get_item("divide")
  if q_talk == nil then
    return
  end
  local text = "\n"
  local content = q_talk.talk
  local size = content.size
  for i = 0, size - 1 do
    if i == 0 then
      text = sys.format("%s%s", text, content[i])
    else
      text = sys.format([[
%s
%s]], text, content[i])
    end
  end
  text = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, text)
  ui_quest.box_insert_text(ui_quest.w_talk_box, text)
  ui_quest.w_talk_box.parent:tune_y("box")
end
function set_quest_info_vis(item_type)
  local detail_vis = false
  local story_vis = false
  local feihua_vis = false
  local receive_vis = false
  local commend_area_vis = false
  if item_type == nil then
    feihua_vis = true
  elseif item_type == ui_quest.QUEST_SORT_ROOT then
    feihua_vis = true
  elseif item_type == ui_quest.QUEST_GOING_ITEM then
    detail_vis = true
  elseif item_type == ui_quest.QUEST_FINISHED_ITEM then
    story_vis = true
  elseif item_type == ui_quest.QUEST_RECEIVE_ITEM then
    receive_vis = true
  elseif item_type == ui_quest.COMMEND_AREA_ITEM then
    commend_area_vis = true
  elseif item_type == ui_quest.COMMEND_REPU_ITEM then
    story_vis = true
  elseif item_type == ui_quest.COMMEND_SCN_ITEM then
  else
    if item_type == ui_quest.COMMEND_QUEST_ITEM then
      receive_vis = true
    else
    end
  end
  local quest_aim = get_item("quest_aim")
  local quest_rewards = get_item("quest_rewards")
  local quest_select_rewards = get_item("quest_select_rewards")
  local quest_describe = get_item("quest_describe")
  local talk_content = get_item("talk_content")
  local lbl_desc_title = quest_describe:search("lbl_desc_title")
  ui_quest.w_info_for_quest.visible = true
  ui_quest.quest_info.visible = detail_vis or story_vis or receive_vis
  ui_quest.quest_commend_panel.visible = commend_area_vis
  ui_quest.quest_tag_panel.visible = feihua_vis
  quest_aim.visible = detail_vis or receive_vis
  quest_rewards.visible = detail_vis or receive_vis
  quest_select_rewards.visible = detail_vis or receive_vis
  quest_describe.visible = detail_vis or story_vis
  talk_content.visible = story_vis
  lbl_desc_title.visible = detail_vis
  ui_quest.w_btn_complete.visible = detail_vis
  ui_quest.w_btn_share.visible = detail_vis
  ui_quest.w_btn_giveup.visible = detail_vis
end
function on_guild_quest_update(cmd, data)
  local quest_id = data:get(packet.key.quest_id).v_int
  set_quest_value(quest_id)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_quest:signal"
reg(packet.eSTC_Guild_UpdateShdQuest, on_guild_quest_update, sig)
