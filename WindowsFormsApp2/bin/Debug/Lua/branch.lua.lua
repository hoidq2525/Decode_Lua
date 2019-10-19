branch_id = nil
function on_branch_quest_init()
  ui.log("branch_quest_init")
end
function set_branch_quest(excel)
  branch_id = excel.id
  set_branch_quest_desc(excel)
  set_branch_quest_aim(excel)
  set_branch_quest_rewards(excel)
  set_branch_quest_select_rewards(excel)
  ui_quest.set_all_not_visible()
  set_visible(true)
end
function set_visible(b)
  local w = ui.find_control("$frame:branch_quest")
  w.visible = b
end
function set_branch_quest_desc(desc)
  if excel ~= nil then
    local text = excel.text
    if text ~= nil then
      ui_quest.set_quest_desc(w_quest_desc_list, text.details)
    end
  end
end
function set_branch_quest_aim(aim)
  ui_quest.set_quest_aim(w_quest_aim_list, aim)
end
function set_branch_quest_rewards(rewards)
  ui_quest.set_quest_rewards(w_reward_list, rewards)
end
function set_branch_quest_select_rewards(s_rewards)
  ui_quest.set_quest_select_rewards(w_select_reward_list, s_rewards)
end
function on_branch_close(btn)
  set_visible(false)
end
function on_receive_branch_quest(btn)
  set_visible(false)
  ui_quest.add(branch_id)
end
