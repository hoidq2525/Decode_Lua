g_cd_id = 5695
local mess_it_up = function(t)
  for k = 1, #t - 1 do
    local r_idx = bo2.rand(k + 1, #t)
    local temp = t[k]
    t[k] = t[r_idx]
    t[r_idx] = temp
  end
end
local function beg_cur_question()
  w_answer_tree:clear_selection()
  w_answer_tree.enable = true
  local cur_idx = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_TodayQuestionIDIdx)
  local cur_question_id = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_TodayQuestionIDBeg + cur_idx)
  local cur_question_excel = bo2.gv_question_list:find(cur_question_id)
  w_rb_question.mtf = cur_question_excel.question_entry
  w_lb_result.visible = false
  w_lb_correct_answer.visible = false
  w_rb_correct_answer.visible = false
  local t_idx = {
    0,
    1,
    2,
    3
  }
  mess_it_up(t_idx)
  local answer_root = w_answer_tree.root
  for j = 0, answer_root.item_count - 1 do
    local item = answer_root:item_get(j)
    local answer_idx = t_idx[j + 1]
    item.title:search("lb_text").text = cur_question_excel.answer[answer_idx]
    item.svar.answer_idx = answer_idx
  end
  w_btn_ok.text = ui.get_text("question|btn_ok")
end
local end_cur_question = function()
  w_answer_tree.enable = false
  w_lb_result.visible = true
  w_btn_ok.text = ui.get_text("question|next_question")
  local cur_idx = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_TodayQuestionIDIdx) - 1
  local cur_question_id = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_TodayQuestionIDBeg + cur_idx)
  local cur_question_excel = bo2.gv_question_list:find(cur_question_id)
  local item_sel = w_answer_tree.item_sel
  local cor_idx = 0
  if cor_idx == item_sel.svar.answer_idx then
    w_lb_result.text = ui.get_text("question|result_correct")
    w_lb_result.color = ui.make_color("00ff00")
  else
    w_lb_result.text = ui.get_text("question|result_wrong")
    w_lb_result.color = ui.make_color("ff0000")
    w_lb_correct_answer.visible = true
    w_rb_correct_answer.visible = true
    w_rb_correct_answer.mtf = cur_question_excel.answer[cor_idx]
  end
end
function on_init()
end
function send_generate_question()
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_GenerateQuestions, v)
end
function on_btn_ok(btn)
  if btn.text == ui.get_text("question|btn_ok") then
    local item_sel = w_answer_tree.item_sel
    if item_sel == nil then
      ui_tool.note_insert(ui.get_text("question|choose_answer"), "FFFF00")
      return
    end
    local v = sys.variant()
    v:set(packet.key.question_asw_idx, item_sel.svar.answer_idx)
    bo2.send_variant(packet.eCTS_UI_CheckQuestionAnswer, v)
  elseif btn.text == ui.get_text("question|next_question") then
    local cur_q_idx = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_TodayQuestionIDIdx)
    if bo2.ePlayerFlagInt16_TodayQuestionIDBeg + cur_q_idx >= bo2.ePlayerFlagInt16_TodayQuestionIDEnd then
      w_main.visible = false
      ui_question_conclusion.w_main.visible = true
    else
      beg_cur_question()
    end
  end
end
function on_btn_cancel(btn)
  w_main.visible = false
end
function on_visible(ctrl, vis)
  if not vis then
    return
  end
  beg_cur_question()
end
function on_answer_title_mouse(title, msg)
end
function on_answer_item_sel(item, sel)
  local title = item.title
  local fig = title:search("fig_highlight")
  fig.visible = sel
end
function on_cur_question_finished(cmd, var)
  w_main.visible = true
  end_cur_question()
end
function on_generate_question_finished(cmd, var)
  w_main.visible = true
  beg_cur_question()
end
ui_packet.game_recv_signal_insert(packet.eSTC_UI_GenerateQuestionFinished, on_generate_question_finished, "ui_question.on_generate_question_finished")
ui_packet.game_recv_signal_insert(packet.eSTC_UI_CurQuestionFinished, on_cur_question_finished, "ui_question.on_cur_question_finished")
function on_self_enter(obj, msg)
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_question.on_self_enter")
