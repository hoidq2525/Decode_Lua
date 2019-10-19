g_excel_id = nil
g_select_reward = nil
g_is_milestone = false
opt_award_list = {}
g_sound_finish = 502
function set_complete_quest_title(excel)
  if excel == nil then
    return
  end
  w_desc_title.text = excel.name
end
function set_complete_quest_desc(excel)
  w_quest_desc_list:item_clear()
  if excel ~= nil then
    local text = excel.text
    if text ~= nil then
      local details
      details = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, text.complete)
      ui_quest.box_insert_text(w_quest_desc_list, details)
      w_quest_desc_list.parent:tune_y("desc")
    end
  end
end
function set_complete_quest_rewards(excel)
  ui_quest.set_quest_rewards_big_icon(w_reward_list, excel, w_parent_list, "quest_rewards")
end
function set_complete_quest_select_rewards(excel, m)
  complete_select_rewards(w_select_rewards_list, excel, w_parent_list, "quest_select_rewards", m)
end
function show_complete(excel)
  set_visible(false)
  g_excel_id = excel.id
  set_complete_quest_title(excel)
  set_complete_quest_desc(excel)
  local lbl_rewards_spe = w_parent_list:search("lbl_rewards_spe")
  if lbl_rewards_spe ~= nil then
    lbl_rewards_spe.visible = false
  end
  set_complete_quest_rewards(excel)
  opt_award_list = {}
  set_complete_quest_select_rewards(excel)
  ui_quest.set_all_not_visible()
  set_visible(true)
  ui_handson_teach.on_theme_quest_award(g_excel_id, true)
end
function clear_all()
  w_quest_desc_list:item_clear()
  w_reward_list:item_clear()
  w_select_rewards_list:item_clear()
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
  else
    ui_handson_teach.on_theme_quest_award(0, false)
    ui_widget.esc_stk_pop(w)
    g_select_reward = nil
    opt_award_list = {}
    clear_all()
  end
end
function set_visible(vis)
  local w = ui.find_control("$frame:complete_quest")
  w.visible = vis
end
g_num = 1
function on_complete(btn)
  local quest_info = ui.quest_find(g_excel_id)
  if quest_info == nil then
    quest_info = ui.guild_quest_find(g_excel_id)
    if quest_info == nil then
      ui.log("on_complete:quest_info nil nil nil")
      return
    end
  end
  local has_select_reward = false
  local excel = quest_info.excel
  for i = 0, 3 do
    if excel.opt_obj[i] > bo2.eQuestObj_Null and excel.opt_obj[i] < bo2.eQuestObj_ItemEnd then
      has_select_reward = true
      break
    end
  end
  if not has_select_reward then
    opt_award_list = {}
  elseif g_select_reward == nil then
    local size = #opt_award_list
    if size == 1 then
      g_select_reward = opt_award_list[1].index
    elseif size > 1 then
      ui_quest.quest_show_text(ui.get_text("quest|reward_select_warning"), ui_quest.c_warning_color)
      return
    end
  end
  if ui_npcfunc.ui_talk.g_talk_sel_id == ui_quest.ui_master.master_id and ui_npcfunc.ui_talk.talk_obj ~= nil then
    if not ui_npcfunc.ui_talk.talk_obj:playsound(bo2.eSE_Talk_FinishQuestCloseTalk) then
      ui_quest.quest_paly_sound(g_sound_finish)
    end
  else
    ui_quest.quest_paly_sound(g_sound_finish)
  end
  ui_quest.send_quest_complete(g_excel_id, g_select_reward)
  set_visible(false)
  ui.log("send quest complete:%d", g_excel_id)
end
function update_select_rewards(parent)
  for i = 1, 4 do
    local panel = parent:search(sys.format("panel_%d", i))
    local select = panel:search("select")
    select.visible = false
  end
end
function get_select(parent, panel)
  for i = 1, 4 do
    local p_panel = parent:search(sys.format("panel_%d", i))
    if p_panel == panel then
      return i - 1
    end
  end
end
function on_select_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local parent = card.parent
    update_select_rewards(parent.parent)
    local select = parent:search("select")
    select.visible = true
    local card = parent:search("card")
    g_select_reward = get_select(parent.parent, parent)
    if g_is_milestone == true then
      ui_quest.ui_milestone.g_select_reward = g_select_reward
    end
    ui.log(g_select_reward)
  end
end
function complete_select_rewards(list_view, list, parent_list, name, m)
  local rewards_uri = "$frame/quest/cmn.xml"
  list_view:item_clear()
  local p_item = parent_list:search(name)
  if list.opt_id[0] == 0 then
    p_item.visible = false
    return
  end
  p_item.visible = true
  local item = list_view:item_append()
  item:load_style(rewards_uri, "title_text")
  item.size = ui.point(300, 20)
  local title = item:search("title")
  title.text = ui.get_text("quest|awd_select_goods")
  local flag = insert_complete_select_goods(list_view, list, m)
  if flag then
  end
  title.visible = flag
end
function insert_complete_select_goods(list_view, excel, m)
  local goods_uri = "$frame/quest/cmn.xml"
  local goods_style = "complete_goods_rewards"
  local item = list_view:item_append()
  item:load_style(goods_uri, goods_style)
  item.size = ui.point(327, 75)
  local flag = false
  for i = 0, 3 do
    local panel = item:search(sys.format("panel_%d", i + 1))
    local card = panel:search("card")
    local num = panel:search("num")
    local text
    if excel.opt_id[i] ~= 0 and excel.opt_obj[i] <= bo2.eQuestObj_ItemEnd then
      if ui.quest_is_opt_fit(excel.opt_obj[i], excel.opt_id[i]) then
        card.excel_id = excel.opt_id[i]
        if 1 <= excel.opt_num[i] then
          text = sys.format("x%d", excel.opt_num[i])
        else
          text = ""
        end
        num.text = text
        flag = true
        panel.visible = true
        table.insert(opt_award_list, {
          index = i,
          id = card.excel_id
        })
      else
        panel.visible = false
      end
    else
      panel.visible = false
    end
  end
  if not flag then
    list_view:item_remove(item.index)
  end
  return flag
end
function set_milestone_flag(flag)
  g_is_milestone = flag
end
