receive_item_tbl = {}
function is_hide(id)
  local hide = bo2.gv_define_v:find(3)
  if hide == nil then
    return false
  end
  local q_v = hide.value
  local size = q_v.size
  for i = 0, size - 1 do
    if id == q_v[i] then
      return true
    end
  end
  return false
end
function check_insert(excel)
  if is_hide(excel.id) == true then
    return false
  end
  local excel = bo2.gv_quest_list:find(excel.id)
  if excel == nil then
    return false
  end
  if excel.in_theme == bo2.eThemeType_GuildLeader and bo2.player ~= nil then
    local info = ui.guild_find_member(bo2.player.only_id)
    if info ~= nil and info.guild_pos == bo2.Guild_Leader then
      return true
    else
      return false
    end
  end
  if excel.in_theme == bo2.eThemeType_Guild and bo2.player ~= nil then
    local info = ui.guild_find_member(bo2.player.only_id)
    if info ~= nil then
      return true
    else
      return false
    end
  end
  return true
end
function on_quest_list_observable(ctrl, vis)
  if not vis then
    return
  end
  local svar = ui_quest.w_quest_list.svar
  if not sys.check(svar.update_receive_done) then
    svar.update_receive_done = true
    do_update_receive()
  end
end
function update_receive()
  local w = ui_quest.w_quest_list
  local svar = w.svar
  if w.observable then
    svar.update_receive_done = true
    do_update_receive()
  else
    svar.update_receive_done = false
  end
end
function do_update_receive()
  table.foreach(receive_item_tbl, function(key, val)
    if sys.check(val) then
      val:self_remove()
    end
  end)
  receive_item_tbl = {}
  local size = bo2.gv_quest_list.size
  for i = 0, size - 1 do
    local excel = bo2.gv_quest_list:get(i)
    if excel.gps_target_id ~= 0 and ui.quest_check_insert(excel.id) and bo2.is_cooldown_over(excel.cooldown) == true and bo2.MayAddQuest(excel) and check_insert(excel) == true then
      local view_type_name = get_view_type_name(nil, excel.id)
      insert_tree_item(excel, view_type_name, ui_quest.QUEST_RECEIVE_ITEM)
    end
  end
  if filted_show_type == ui_quest.QUEST_RECEIVE_ITEM then
    filtitem_by_type(filted_show_type)
    clear_quest_info()
    set_sort_root_val()
  end
end
function set_receive_aim(list)
  ui_quest.w_quest_aim:item_clear()
  local v = sys.variant()
  v:set("n", list.gps_target_id)
  local n = bo2.gv_mark_list:find(list.gps_target_id)
  local text = ui.get_text("quest|commend_quest_gps")
  text = sys.mtf_merge(v, text)
  text = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, text)
  ui_quest.box_insert_text(ui_quest.w_quest_aim, text)
end
function set_receive_quest_value(id, item)
  if id == nil then
    return
  end
  local list = bo2.gv_quest_list:find(id)
  if list == nil then
    ui_quest.w_desc_title.text = ui.get_text("quest|quest_commend_3")
    local p_item = ui_quest.ui_complete.w_parent_list:search("quest_rewards")
    local lbl_rewards_spe = ui_quest.ui_complete.w_parent_list:search("lbl_rewards_spe")
    local p_item1 = ui_quest.ui_complete.w_parent_list:search("quest_select_rewards")
    p_item.visible = false
    lbl_rewards_spe.visible = false
    p_item1.visible = false
    ui_quest.w_quest_aim:item_clear()
    ui_quest.w_rewards_list:item_clear()
    ui_quest.w_select_rewards_list:item_clear()
    return
  end
  ui_quest.w_desc_title.text = list.name
  set_receive_aim(list)
  ui_quest.set_quest_rewards(ui_quest.w_rewards_list, list, ui_quest.w_parent_list, "quest_rewards")
  ui_quest.set_quest_select_rewards(ui_quest.w_select_rewards_list, list, ui_quest.w_parent_list, "quest_select_rewards")
end
