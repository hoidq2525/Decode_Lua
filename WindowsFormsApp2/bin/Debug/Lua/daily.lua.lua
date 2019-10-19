local STATE_NO_ACCEPT = 1
local STATE_GOING = 2
local STATE_FINISH = 3
local STATE_CD = 4
function update_state(item, state)
  local state_item = item:search("quest_state")
  local title_panel = item:search("title_panel")
  local exp_panel = item:search("exp_panel")
  local money_panel = item:search("money_panel")
  local is_visible = true
  if state == STATE_NO_ACCEPT then
    is_visible = false
    state_item.visible = is_visible
    title_panel.visible = is_visible
    exp_panel.visible = is_visible
    money_panel.visible = is_visible
  elseif state == STATE_GOING then
    is_visible = false
    state_item.visible = is_visible
    title_panel.visible = is_visible
    exp_panel.visible = is_visible
    money_panel.visible = is_visible
  elseif state == STATE_FINISH then
    is_visible = true
    state_item.text = ui.get_text("dailyquest|can_finish")
    state_item.visible = is_visible
    title_panel.visible = is_visible
    exp_panel.visible = is_visible
    money_panel.visible = is_visible
  elseif state == STATE_CD then
    is_visible = true
    state_item.text = ui.get_text("dailyquest|finished")
    state_item.visible = false
    title_panel.visible = false
    exp_panel.visible = false
    money_panel.visible = false
  end
end
function remove_daily_item(quest_id)
  for i = 0, 2 do
    local item_name = L("item") .. i
    local item = w_daily_list:search(item_name)
    if item == nil then
      return
    end
    if item.svar.quest_id == quest_id then
      ui_quest.set_daily_no_accept(item)
      item.svar.quest_id = 0
      item.dy = 20
      update_state(item, STATE_NO_ACCEPT)
      tune_daily_quest()
      return
    end
  end
end
function on_open_main_window(btn, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    local quest_id = btn.parent.svar.quest_id
    local info = ui.quest_find(quest_id)
    ui_dailyquest.gx_window.visible = true
    if info ~= nil then
      ui_dailyquest.show_quest_detail(quest_id)
    else
      ui_dailyquest.show_quest_detail(0)
    end
  elseif msg == ui.mouse_enter then
    btn.color = ui.make_color("66ffff")
  elseif msg == ui.mouse_leave then
    btn.color = L("00ffffff")
  end
end
function insert_daily_item(id, idx)
  local item_name = L("item") .. idx
  local item = w_daily_list:search(item_name)
  if item == nil then
    return
  end
  local state_item = item:search("quest_state")
  local info = ui.quest_find(id)
  if info == nil and id == 0 then
    ui_quest.set_daily_no_accept(item)
    item.dy = 20
    item.svar.quest_id = 0
    update_state(item, STATE_NO_ACCEPT)
  elseif info == nil and id ~= 0 then
    ui_quest.set_daily_aim(item, id)
    ui_quest.set_daily_rewards_tracing(item, id)
    item.dy = 20
    item.svar.quest_id = id
    update_state(item, STATE_CD)
  elseif info ~= nil and quest_id == 0 then
    return
  elseif info ~= nil and id ~= 0 then
    ui_quest.set_daily_aim(item, id)
    ui_quest.set_daily_rewards_tracing(item, id)
    item.svar.quest_id = id
    if info.completed then
      update_state(item, STATE_FINISH)
    else
      item.dy = 20
      update_state(item, STATE_GOING)
    end
  end
  tune_daily_quest()
end
function tune_daily_quest()
  quest_daily_panel.dy = 0
  for i = 0, 2 do
    local name = L("item") .. i
    local item = w_daily_list:search(name)
    quest_daily_panel.dy = quest_daily_panel.dy + item.dy
  end
  if quest_daily_panel.visible then
    w_daily_tracing.dy = quest_daily_panel.dy + 34
  else
    w_daily_tracing.dy = 34
  end
end
