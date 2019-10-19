function on_visible(ctrl, vis)
  if vis == false then
    return
  end
  local root = w_item_tree.root
  local cor_idx = 0
  local today_score = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_TodayQuestionScore)
  local con_desc = ui_widget.merge_mtf({score = today_score}, ui.get_text("question|conclusion_desc"))
  w_lb_conclusion_desc.text = con_desc
  for k = bo2.ePlayerFlagInt16_TodayQuestionIDBeg, bo2.ePlayerFlagInt16_TodayQuestionIDEnd - 1 do
    local node_idx = k - bo2.ePlayerFlagInt16_TodayQuestionIDBeg + 1
    local node = root:item_get(node_idx)
    local q_id = bo2.player:get_flag_int16(k)
    local q_excel = bo2.gv_question_list:find(q_id)
    node:search("lb_num").text = node_idx .. "."
    node:search("lb_text").text = q_excel.question_entry
    node:search("lb_as_text").text = q_excel.answer[cor_idx]
  end
end
function on_init()
end
function on_btn_cancel(btn)
  w_main.visible = false
end
local do_view_move = function(w)
  w:update()
  local root = w.root
  for i = 1, root.item_count - 1 do
    local node = root:item_get(i)
    node.title:tune_y("lb_text")
    for j = 0, node.item_count - 1 do
      local item = node:item_get(j)
      item.title:tune_y("lb_as_text")
    end
  end
end
function on_view_move(w)
  w:insert_post_invoke(do_view_move, "ui_question_conclusion.do_view_move")
end
