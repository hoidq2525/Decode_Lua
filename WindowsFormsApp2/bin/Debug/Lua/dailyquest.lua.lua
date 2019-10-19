local STATE_NO_ACCEPT = 1
local STATE_GOING = 2
local STATE_FINISH = 3
local STATE_CD = 4
local cur_select_index = 0
local cur_select_id = 0
local is_in_animation = false
local animation_idx = 1
local path_level_award = SHARED("$mb/quest/level_match_award/level_match_award.xml")
local path_award = SHARED("$mb/quest/level_match_award/")
function on_init()
  animation_idx = 1
  w_animation_list.scroll = 0.99
  is_in_animation = false
  cur_select_index = 0
  cur_select_id = 0
end
function update_state(item, state)
  local title_panel = item:search("title_panel")
  local exp_panel = item:search("exp_panel")
  local money_panel = item:search("money_panel")
  local item_btn = item:search("item_btn")
  local button_tri = item:search("button_tri")
  local is_visible = true
  if state == STATE_NO_ACCEPT then
    is_visible = false
    item_btn.enable = false
  elseif state == STATE_GOING then
    is_visible = true
    item_btn.enable = true
  elseif state == STATE_FINISH then
    is_visible = true
    item_btn.enable = true
  elseif state == STATE_CD then
    is_visible = false
    item_btn.enable = false
  end
  button_tri.visible = item_btn.enable
  title_panel.visible = false
  exp_panel.visible = false
  money_panel.visible = false
end
function remove_item(quest_id)
  for i = 0, 2 do
    local item_name = L("item") .. i
    local item = w_item_list:search(item_name)
    if item == nil then
      return
    end
    if item.svar.quest_id == quest_id then
      ui_quest.set_daily_no_accept(item)
      item.svar.quest_id = 0
      update_state(item, STATE_NO_ACCEPT)
      return
    end
  end
end
function on_item_sel(ctrl, vis)
end
function update_item(quest_id, item_id)
  local item_name = L("item") .. item_id
  local item = w_item_list:search(item_name)
  if item == nil then
    return
  end
  local aim_box = item:search("aim_box")
  aim_box:item_clear()
  local info = ui.quest_find(quest_id)
  if info == nil and quest_id == 0 then
    ui_quest.set_daily_no_accept(item)
    item.svar.quest_id = 0
    update_state(item, STATE_NO_ACCEPT)
  elseif info == nil and quest_id ~= 0 then
    item.svar.quest_id = quest_id
    ui_quest.set_daily_aim(item, quest_id)
    ui_quest.set_daily_rewards(item, quest_id)
    update_state(item, STATE_CD)
  elseif info ~= nil and quest_id == 0 then
    return
  elseif info ~= nil and quest_id ~= 0 then
    item.svar.quest_id = quest_id
    ui_quest.set_daily_aim(item, quest_id)
    ui_quest.set_daily_rewards(item, quest_id)
    if info.completed then
      update_state(item, STATE_FINISH)
    else
      update_state(item, STATE_GOING)
    end
  end
  update_select_button()
  update_reset_button()
end
function update_reset_button()
  local reset_time = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_DailyQuestResetTime)
  if reset_time == 0 then
    w_btn_reset.enable = false
  else
    w_btn_reset.enable = true
  end
  local t_reset = ui.get_text("dailyquest|reset")
  w_btn_reset.text = t_reset .. "(" .. reset_time .. ")"
  local begin32 = bo2.ePlayerFlagInt32_DailyQuestBegin
  local end32 = bo2.ePlayerFlagInt32_DailyQuestEnd
  for i = begin32, end32 do
    local id = bo2.player:get_flag_int32(i)
    local info = ui.quest_find(id)
    if id ~= 0 and info == nil then
      w_btn_reset.enable = false
      return
    end
  end
  local select_time = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_DailyQuestSelectTime)
  local times = bo2.gv_define:find(1029).value.v_int
  if select_time == times then
    w_btn_reset.enable = false
    return
  end
end
function update_select_button()
  local select_time = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_DailyQuestSelectTime)
  local t_select = ui.get_text("dailyquest|select")
  w_btn_select.text = t_select .. "(" .. select_time .. ")"
  if select_time == 0 then
    w_btn_select.enable = false
  else
    w_btn_select.enable = true
  end
end
function on_visible(ctrl, vis)
  if vis then
    ui_widget.esc_stk_push(ctrl)
    update_reset_button()
    local begin32 = bo2.ePlayerFlagInt32_DailyQuestBegin
    local end32 = bo2.ePlayerFlagInt32_DailyQuestEnd
    for j = begin32, end32 do
      local q_id = bo2.player:get_flag_int32(j)
      update_item(q_id, j - begin32)
    end
  else
    if sys.check(w_detail_panel) then
      w_detail_panel.visible = false
      w_item_list.visible = true
    end
    ui_widget.esc_stk_pop(ctrl)
  end
end
function on_btn_select(btn)
  if not w_next.suspended or not w_over.suspended or not w_block.suspended then
    return
  end
  local left_time = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_DailyQuestSelectTime)
  if left_time == 0 then
    return
  end
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_SelectDailyQuest, v)
end
function on_btn_reset(btn)
  local select_time = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_DailyQuestSelectTime)
  local left_time = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_DailyQuestResetTime)
  if left_time == 0 then
    return
  end
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_ResetDailyQuest, v)
end
function on_btn_get_reward(btn)
  local quest_id = btn.svar.quest_id
  local select_id = ui_quest.g_select_reward_idx
  if select_id == nil then
    ui_quest.quest_show_text(ui.get_text("quest|reward_select_warning"), ui_quest.c_warning_color)
    return
  else
    ui_quest.send_quest_complete(quest_id, select_id)
  end
  w_detail_panel.visible = false
  w_item_list.visible = true
end
function on_daily_quest_reset(cmd, data)
  for i = 0, 2 do
    local item_name = L("item") .. i
    local item = w_item_list:search(item_name)
    if item == nil then
      return
    end
    ui_quest.set_daily_no_accept(item)
    item.svar.quest_id = 0
    update_state(item, STATE_NO_ACCEPT)
    ui_quest.ui_tracing.insert_daily_item(0, i)
  end
  update_select_button()
  update_reset_button()
  w_detail_panel.visible = false
  w_item_list.visible = true
end
function on_daily_quest_select(cmd, data)
  local quest_id = data:get(packet.key.quest_id).v_int
  local quest_index = data:get(packet.key.cmn_index).v_int
  w_btn_select.enable = false
  w_btn_reset.enable = false
  w_detail_panel.visible = false
  w_item_list.visible = true
  w_next.suspended = false
  w_over.suspended = false
  w_animation.visible = true
  animation_idx = 1
  local rand_quest = {}
  for i = 0, bo2.gv_quest_list.size - 1 do
    local excel = bo2.gv_quest_list:get(i)
    if excel.in_theme == bo2.eThemeType_Daily and excel.id ~= quest_id then
      table.insert(rand_quest, {
        id = excel.id
      })
    end
  end
  math.randomseed(tostring(os.time()):reverse():sub(1, 6))
  for i = 1, 10 do
    local item = w_animation_list:search("block" .. i)
    local pic = item:search("picture")
    local label = item:search("label")
    label.color = ui.make_color("FFFFFF")
    if i < 4 then
      pic.dx = 185
    else
      pic.dx = 200 - 5 * math.abs(7 - i)
    end
    if i ~= 4 then
      local rand_idx = math.random(#rand_quest)
      local rand_excel = bo2.gv_quest_list:find(rand_quest[rand_idx].id)
      label.text = rand_excel.name
      if #rand_quest > 1 then
        table.remove(rand_quest, rand_idx)
      end
    end
  end
  local select_item = w_animation_list:search("block4")
  local select_excel = bo2.gv_quest_list:find(quest_id)
  local select_label = select_item:search("label")
  select_label.text = select_excel.name
  cur_select_index = quest_index
  cur_select_id = quest_id
end
function on_hide_detail(btn)
  w_detail_panel.visible = false
  w_item_list.visible = true
end
function on_show_detail(btn)
  w_detail_panel.visible = true
  w_item_list.visible = false
  local item = btn.parent.parent
  if item == nil then
    return
  end
  show_quest_detail(item.svar.quest_id)
end
function show_quest_detail(id)
  local excel = bo2.gv_quest_list:find(id)
  if excel == nil then
    w_detail_panel.visible = false
    w_item_list.visible = true
  else
    w_detail_panel.visible = true
    w_item_list.visible = false
  end
  set_quest_desc(id)
  set_quest_aim(id)
  set_quest_reward(id)
  local btn_finish = w_detail_panel:search("btn_finish")
  local info = ui.quest_find(id)
  if info == nil then
    btn_finish.enable = false
    btn_finish.svar.quest_id = id
  else
    btn_finish.enable = info.completed
    btn_finish.svar.quest_id = id
  end
end
function on_animation_next()
  w_animation_picture.image = "$image/dailyquest/animation/" .. animation_idx .. ".png"
  animation_idx = animation_idx + 1
  if animation_idx > 12 then
    animation_idx = 1
  end
end
function on_animation_over()
  w_next.suspended = true
  w_over.suspended = true
  animation_idx = 1
  w_block.suspended = false
  w_animation_list.scroll = 0.99
  w_animation.visible = false
end
function on_animation_block()
  w_animation_list.scroll = w_animation_list.scroll - 0.03
  for i = 2, 4 do
    local item = w_animation_list:search("block" .. i)
    local pic = item:search("picture")
    if w_animation_list.scroll < 0.33 * (i - 1) and pic.dx < 200 then
      pic.dx = pic.dx + 0.45
    end
  end
  for i = 5, 6 do
    local item = w_animation_list:search("block" .. i)
    local pic = item:search("picture")
    if w_animation_list.scroll > 0.33 * (i - 4) then
      if pic.dx < 200 then
        pic.dx = pic.dx + 0.45
      end
    elseif pic.dx > 185 then
      pic.dx = pic.dx - 0.45
    end
  end
  for i = 7, 9 do
    local item = w_animation_list:search("block" .. i)
    local pic = item:search("picture")
    if pic.dx > 185 then
      pic.dx = pic.dx - 0.45
    end
  end
  if w_animation_list.scroll <= 0.01 then
    w_block.suspended = true
    w_next.suspended = true
    w_over.suspended = true
    if gx_window.visible then
      update_item(cur_select_id, cur_select_index)
    end
    ui_quest.ui_tracing.insert_daily_item(cur_select_id, cur_select_index)
    cur_select_id = 0
    cur_select_index = 0
    update_select_button()
    update_reset_button()
    local item = w_animation_list:search("block4")
    local label = item:search("label")
    label.color = ui.make_color("00D8FF")
  end
end
function set_quest_desc(quest_id)
  g_desc_box:item_clear()
  local excel = bo2.gv_quest_list:find(quest_id)
  if excel == nil then
    return
  end
  w_quest_name.text = excel.name
  local rank = ui.mtf_rank_system
  local content = sys.format("<tf:text>%s", excel.text.details)
  g_desc_box:insert_mtf(content, rank)
  g_desc_box.dy = g_desc_box.extent.y
  g_desc_box.parent.dy = g_desc_box.extent.y + 22
end
function set_quest_aim(quest_id)
  local quest_info = ui.quest_find(quest_id)
  g_aim_box:item_clear()
  local excel = bo2.gv_quest_list:find(quest_id)
  if excel == nil then
    return
  end
  local goal = excel.text.goal
  local all_text = ""
  all_text = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, goal)
  for i = 0, 3 do
    local cur_num = 0
    if quest_info ~= nil then
      cur_num = quest_info.comp[i]
    end
    local obj = bo2.gv_quest_object:find(excel.req_obj[i])
    if obj ~= nil then
      local name1 = obj.name
      local name_repute = ui_quest.get_repute_req_name(excel.req_obj[i])
      name1 = name1 .. name_repute
      local list = ui.quest_get_qobj_excel(excel.req_obj[i], excel.req_id[i])
      local name2 = L("")
      if list ~= nil then
        name2 = list.name
      end
      if excel.req_obj[i] == bo2.eQuestObj_Quest then
        name2 = ui.get_text("quest|milestone_step")
      end
      local total_num = ui_quest.get_aim_max_num(excel.req_obj[i], excel, i, false)
      cur_num = ui_quest.reset_value(excel.req_obj[i], cur_num, total_num)
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
  local rank = ui.mtf_rank_system
  local content = sys.format("<tf:text>%s", all_text)
  g_aim_box:insert_mtf(content, rank)
  g_aim_box.dy = g_aim_box.extent.y
  g_aim_box.parent.dy = g_aim_box.extent.y + 22
end
function set_quest_reward(quest_id)
  w_rewards_list:item_clear()
  local excel = bo2.gv_quest_list:find(quest_id)
  if excel == nil then
    return
  end
  local rewards_uri = "$frame/quest/cmn.xml"
  local has_reward = false
  if ui_quest.insert_select_goods(w_rewards_list, excel) then
    has_reward = true
  end
  w_desc_list:search("quest_rewards").dy = w_rewards_list.extent.y + 20
  w_desc_list.dy = w_rewards_list.extent.y + 42
  w_reward_title.visible = has_reward
end
function on_daily_quest_start(cmd, data)
  ui_quest.ui_tracing.w_daily_tracing.visible = true
  ui_quest.ui_tracing.w_daily_tracing.dy = 34
  ui_quest.ui_tracing.quest_daily_panel.dy = 0
  for i = 0, 2 do
    ui_quest.ui_tracing.insert_daily_item(0, i)
  end
  gx_window.visible = true
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_dailyquest.packet_handle"
reg(packet.eSTC_UI_DailyQuestReset, on_daily_quest_reset, sig)
reg(packet.eSTC_UI_DailyQuestSelect, on_daily_quest_select, sig)
reg(packet.eSTC_UI_DailyQuestStart, on_daily_quest_start, sig)
