local c_notify_time = 200000
g_last_jump_text = {}
g_jump_param = {}
local c_notify_index = 1102
local c_jump_area_id = 130
local c_jump_milestone_id = 129
local c_color_correct = L("FF00FF00")
local c_color_wrong = L("FFFF0000")
local c_jump_disappear_time = 1000
function on_init_jump()
  g_last_jump_text = {}
  g_jump_param = {}
end
g_jump_param = {}
g_jump_rand = 0
local jump_sig_name = "ui_handson_teach:jump"
local jump_end_sig_name = "ui_handson_teach:jump_end"
function check_jump_is_corrent(jump_id)
  if g_jump_param == nil or g_jump_param.chain == nil then
    return false
  end
  if g_jump_param.fun ~= nil then
    local rst, re = g_jump_param.fun(jump_id)
    if re == true then
      return rst
    end
  end
  return false
end
function common_check_redo()
  local scn = bo2.scn
  if sys.check(scn) and scn.scn_excel.id == 101 then
    local redo = check_redo_jump_quest()
    if redo ~= true then
      return false
    end
  end
  return g_jump_param.finish ~= true
end
function jump_check_a(jump_id)
  if g_jump_param.faild == true or g_jump_param.finish then
    return false, true
  end
  if g_jump_param.index >= g_jump_param.max_chain then
    return false, true
  end
  local jump_index = g_jump_param.index
  g_jump_param.index = g_jump_param.index + 1
  local v_check = g_jump_param.chain[jump_index]
  if v_check == 0 or v_check == nil then
    g_jump_param.finish = true
    return true, true
  else
    for i, m in pairs(v_check) do
      if m == jump_id then
        local jump_next = g_jump_param.param[m]
        if jump_next == nil or jump_next == 0 then
          g_jump_param.finish = true
          return true, true, m, true
        end
        return true, false, m
      end
    end
    if g_jump_param.index <= g_jump_param.min then
      g_jump_param.faild = true
    else
      g_jump_param.finish = true
      return false, true, g_jump_param.finish_text, true
    end
    return false, true
  end
end
function init_jump_param(rand)
  g_jump_param = {}
  g_jump_param.text_param = {}
  g_jump_param.param = {}
  g_jump_param.chain = {}
  g_jump_param.index = 0
  g_jump_param.max_chain = 0
  g_jump_param.finish = false
  g_jump_param.faild = false
  g_jump_param.min = 0
  g_jump_param.finish_text = 10
  g_jump_param.fun = jump_check_a
  g_jump_param.check_redo = common_check_redo
  local add_sequence = function(jump_idx, param, add_phase)
    g_jump_param.param[jump_idx] = param
    table.insert(g_jump_param.text_param, jump_idx)
    if add_phase == nil then
      local idx = g_jump_param.max_chain
      g_jump_param.chain[idx] = param
      g_jump_param.max_chain = g_jump_param.max_chain + 1
    end
  end
  if rand == 0 then
    add_sequence(99, {21, 5})
    add_sequence(21, {8})
    add_sequence(5, {8}, 1)
    add_sequence(8, {
      24,
      25,
      26,
      27
    })
    add_sequence(24, {10})
    add_sequence(25, {10}, 1)
    add_sequence(26, {10}, 1)
    add_sequence(27, {10}, 1)
    add_sequence(10, 0)
    g_jump_param.min = 3
    g_jump_rand = L("a_")
  elseif rand == 1 then
    add_sequence(99, {21, 5})
    add_sequence(21, {24})
    add_sequence(5, {24}, 1)
    add_sequence(24, {25})
    add_sequence(25, {26})
    add_sequence(26, {10})
    add_sequence(10, 0)
    g_jump_param.min = 5
    g_jump_rand = L("b_")
  elseif rand == 2 then
    add_sequence(99, {21, 5})
    add_sequence(21, {
      24,
      25,
      26,
      27
    })
    add_sequence(5, {
      24,
      25,
      26,
      27
    }, 1)
    add_sequence(24, {10})
    add_sequence(25, {10}, 1)
    add_sequence(26, {10}, 1)
    add_sequence(27, {10}, 1)
    add_sequence(10, 0)
    g_jump_param.min = 3
    g_jump_rand = L("c_")
  end
end
function begin_jump_teach(mb)
  if sys.check(mb) ~= true then
    return
  end
  if ui_setting.ui_game.get_jump_teach() ~= true then
    bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_jump, jump_sig_name)
    bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_jump_end, jump_end_sig_name)
    return
  end
  local jump_key = L("Q")
  local v = ui_setting.ui_input.op_def.jump.hotkey
  local k = v:get_cell(0).text
  local text = mb.popo_text
  text = ui_widget.merge_mtf({jump = k}, text)
  g_last_jump_text.text = text
  g_last_jump_text.id = mb.milestone_id
  g_last_jump_text.confirm = 99
  note_insert(text, nil, mb.milestone_id, mb.mark_id)
  init_jump_param(2)
  bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_jump, jump_sig_name)
  bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_jump, on_jump_teach, jump_sig_name)
  bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_jump_end, jump_end_sig_name)
  bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_jump_end, on_jump_end, jump_end_sig_name)
end
function on_jump_teach(obj)
  if obj ~= bo2.player then
    return
  end
  local v = obj:get_jump_param()
  local idx = v:get(packet.key.skill_id).v_int
  if sys.check(g_jump_param.fun) ~= true then
    return
  end
  local right_jump, clear, next_idx, finish = g_jump_param.fun(idx)
  if g_last_jump_text.text ~= nil then
    local color = c_color_correct
    if right_jump ~= true then
      color = c_color_wrong
    end
    note_insert(g_last_jump_text.text, color, g_last_jump_text.id, c_jump_disappear_time, 1)
    g_last_jump_text.text = nil
  end
  if clear == true then
    note_insert(L(" "), nil, c_notify_index, c_notify_time)
  end
  if next_idx ~= nil then
    for i, v in pairs(g_jump_param.text_param) do
      if v == next_idx then
        local _get_text = sys.format("jump|%s%d", g_jump_rand, next_idx)
        local text = ui.get_text(_get_text)
        if finish ~= nil then
          note_insert(text, c_color_correct, c_notify_index, 1500)
          break
        end
        note_insert(text, nil, c_notify_index, c_notify_time)
        g_last_jump_text.text = text
        g_last_jump_text.id = c_notify_index
        break
      end
    end
  end
end
function redo_jump()
  on_notify_text(nil, 114)
end
function sys_check_redo()
  if g_jump_param == nil or g_jump_param.check_redo == nil then
    return false
  end
  return g_jump_param.check_redo()
end
function view_jump_popo()
  if ui_setting.ui_game.get_jump_teach() ~= true then
    return
  end
  local mb = g_handson_quest_mb:find(115)
  if sys.check(mb) then
    add_popo(mb.milestone_id, mb.popo_text)
  end
end
function on_jump_end(obj)
  local function add_time()
    if sys.check(obj) ~= true or sys.check(bo2.scn) ~= true then
      return
    end
    local v = obj:get_jump_param()
    local idx = v:get(packet.key.skill_id).v_int
    if idx == 0 then
      note_insert(L(" "), nil, c_notify_index, c_notify_time)
      if sys_check_redo() ~= true then
        if bo2.scn.scn_excel.id ~= 225 then
          view_jump_popo()
        end
        bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_jump, jump_sig_name)
        bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_jump_end, jump_end_sig_name)
        return
      end
      redo_jump()
    end
  end
  bo2.AddTimeEvent(1, add_time)
end
function on_clear_jump_teach()
  note_insert(L(" "), nil, c_notify_index, c_notify_time)
  bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_jump, jump_sig_name)
  bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_jump_end, jump_end_sig_name)
end
function check_redo_jump_quest()
  local get_quest_ms = function(quest_id)
    if ui.quest_find_c(quest_id) then
      return nil
    end
    local quest_info = ui.quest_find(quest_id)
    if quest_info ~= nil then
      return quest_info.mstone_id
    end
  end
  local ms_id = get_quest_ms(10)
  if ms_id == nil then
    return false
  end
  local ms_tab = {129, 121}
  local redo = false
  for i, v in pairs(ms_tab) do
    if v == ms_id then
      redo = true
      break
    end
  end
  return redo
end
function on_time_begin_jump_teach()
  if sys.check(bo2.player) ~= true or sys.check(bo2.scn) ~= true then
    return
  end
  on_clear_jump_teach()
  local excel = bo2.scn.excel.id
  if excel ~= 101 then
    return
  end
  local function check_begin()
    if sys.check(bo2.player) ~= true or sys.check(bo2.scn) ~= true then
      return
    end
    local excel = bo2.scn.excel.id
    if excel ~= 101 then
      return
    end
    local id = bo2.player:get_atb(bo2.eAtb_AreaID)
    if id ~= c_jump_area_id then
      return
    end
    local redo = check_redo_jump_quest()
    if redo ~= true then
      return
    end
    redo_jump()
  end
  bo2.AddTimeEvent(125, check_begin)
end
