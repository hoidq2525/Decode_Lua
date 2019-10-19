local ui_tab = ui_widget.ui_tab
local ui_text_list = ui_widget.ui_text_list
c_disable_color = L("FF6C5661")
g_qtable = {}
g_npc = {
  5158,
  6048,
  6049
}
local reputation_can_rcv = ui.get_text("quest|reputation_can_rcv")
local reputation_cooldown = ui.get_text("quest|reputation_cooldown")
local reputation_in_progress = ui.get_text("quest|reputation_in_progress")
function show(medium, kind, id)
  if w_main.visible == true then
    return
  end
  local size = medium.size
  for i = 0, size - 1 do
    local excel = bo2.gv_quest_list:find(medium[i])
    local is_insert = true
    for j = 0, 1 do
      if 0 ~= ui.quest_check_qobj_value(excel.pre_obj[j], excel.pre_id[j], excel.pre_min[j], excel.pre_max[j]) then
        is_insert = false
      end
    end
    if 0 ~= ui.quest_check_qobj_value(bo2.eQuestObj_PlayerAtb, bo2.eAtb_Level, excel.level_min, excel.level_max) then
      is_insert = false
    end
    if is_insert and excel.beg_obj == kind and excel.beg_id == id then
      insert_item(medium[i])
      table.insert(g_qtable, medium[i])
    end
  end
  set_select(0)
  if w_quest_list.item_count == 0 then
    set_visible(false)
  else
    set_visible(true)
    local excel = bo2.gv_cha_list:find(id)
    w_title.text = excel.name
  end
end
function may_show(medium, kind, id)
  local size = medium.size
  for i = 0, size - 1 do
    local excel = bo2.gv_quest_list:find(medium[i])
    if 0 == ui.quest_check_qobj_value(bo2.eQuestObj_PlayerAtb, bo2.eAtb_Level, excel.level_min, excel.level_max) and excel.beg_obj == kind and excel.beg_id == id then
      return true
    end
  end
  return false
end
function is_reputation_npc(id)
  local size = #g_npc
  for i = 1, size do
    if id == g_npc[i] then
      return true
    end
  end
  return false
end
function on_init()
end
function insert_item(excel_id)
  local excel = bo2.gv_quest_list:find(excel_id)
  if excel == nil then
    return
  end
  local style_uri = "$frame/quest/reputation.xml"
  local style_name = "item"
  local quest_info = ui.quest_find(excel_id)
  if excel.type == bo2.eQuestType_Normal and quest_info ~= nil then
    return
  end
  local item = w_quest_list:item_append()
  item:load_style(style_uri, style_name)
  local lb = item:search("item_text")
  lb.text = excel.name
  if not ui.quest_check_insert(excel_id) then
    lb.xcolor = ui_quest.c_milestone_complete_color
  end
  local over = bo2.is_cooldown_over(excel.cooldown)
  if not over then
    lb.xcolor = ui_quest.c_milestone_complete_color
  end
  item.var:set("excel_id", excel_id)
end
function del_item(excel_id)
  local size = w_quest_list.item_count
  for i = 0, size - 1 do
    local item = w_quest_list:item_get(i)
    local id = item.var:get("excel_id").v_int
    if id == excel_id then
      local excel = bo2.gv_quest_list:find(excel_id)
      if excel.type == bo2.eQuestType_Normal then
        w_quest_list:item_remove(i)
      else
        item:search("item_text").xcolor = ui_quest.c_milestone_complete_color
      end
      return true
    end
  end
  return false
end
function get_item(index)
  local size = w_parent_list.item_count
  if index > size then
    return nil
  end
  local item = w_parent_list:item_get(index)
  return item
end
function set_select(index)
  local item = w_quest_list:item_get(index)
  if item == nil then
    return
  end
  item.selected = true
  local id = item.var:get("excel_id").v_int
  set_quest_value(id)
end
function set_visible(vis)
  w_main.visible = vis
end
function set_title(list)
  w_desc_title.text = list.name
end
function set_quest_value(excel_id)
  local list = bo2.gv_quest_list:find(excel_id)
  if list == nil then
    return
  end
  set_quest_desc(list)
  set_title(list)
  set_quest_aim(list)
  set_quest_reward(list)
  set_quest_select_reward(list)
  for i = 0, w_quest_list.item_count - 1 do
    local item = w_quest_list:item_get(i)
    item.visible = true
  end
  local quest_info = ui.quest_find(list.id)
  if list.type == bo2.eQuestType_Normal then
    w_quest_cooldown_panel.visible = false
  else
    w_quest_cooldown_panel.visible = true
  end
end
function on_get_cd_token(cmd, data)
  local token = data:get(packet.key.item_key).v_int
  local state = L("")
  local color = L("")
  local item = w_quest_list.item_sel
  local excel_id = item.var:get("excel_id").v_int
  local list = bo2.gv_quest_list:find(excel_id)
  if list == nil then
    return
  end
  if ui.quest_check_insert(excel_id) then
    local over = bo2.is_cooldown_over(list.cooldown)
    if over then
      state = reputation_can_rcv
      color = "FF00FF00"
      w_btn.enable = true
    else
      state = reputation_cooldown
      color = "FFFF0000"
      w_btn.enable = false
    end
  else
    state = reputation_in_progress
    color = "FFFFFF00"
    w_btn.enable = false
  end
  local cd = bo2.gv_cooldown_list:find(list.cooldown)
  if cd == nil then
    return
  end
  local count = cd.token
  local time = 0
  if cd.mode == 2 then
    time = cd.time
  end
  local data = sys.variant()
  data:set("color", color)
  data:set("state", state)
  data:set("num", count - token)
  data:set("count", count)
  data:set("time", time)
  local fmt = ui.get_text("quest|repute_quest_cooldown")
  w_quest_cooldown.mtf = sys.mtf_merge(data, fmt)
end
function set_quest_desc(list)
  w_desc_title.text = list.name
  w_quest_desc:item_clear()
  if list.text ~= nil then
    local details = list.text.details
    ui_quest.box_insert_text(w_quest_desc, details)
    w_quest_desc.slider_y.scroll = 0
  end
end
function set_quest_aim(list)
  if list == nil then
    return
  end
  w_quest_aim:item_clear()
  if list.text ~= nil then
    local item = get_item(2)
    local aim = item:search("aim")
    local goal = list.text.goal
    local all_text = ""
    all_text = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, goal)
    for i = 0, 3 do
      local cur_num = 0
      local quest_info = ui.quest_find(list.id)
      if quest_info ~= nil then
        cur_num = quest_info.comp[i]
      end
      local obj = bo2.gv_quest_object:find(list.req_obj[i])
      if obj ~= nil then
        local name1 = obj.name
        local name_repute = ui_quest.get_repute_req_name(list.req_obj[i])
        name1 = name1 .. name_repute
        local excel = ui.quest_get_qobj_excel(list.req_obj[i], list.req_id[i])
        local name2 = ""
        if excel ~= nil then
          name2 = excel.name
        end
        if list.req_obj[i] == bo2.eQuestObj_CompleteMilestones then
          name2 = ui.get_text("quest|milestone_step")
        end
        local total_num = ui_quest.get_aim_max_num(list.req_obj[i], list, i, false)
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
    ui_quest.box_insert_text(w_quest_aim, all_text)
    w_quest_aim.parent:tune_y("aim_box")
  end
end
function set_quest_rewards(list_view, list, parent_list, index)
  list_view:item_clear()
  if list == nil then
    return
  end
  local rewards_uri = "$frame/quest/cmn.xml"
  local p_item = parent_list:item_get(index)
  local p_panel = p_item:search("rewards_panel")
  if list.awd_id[0] == 0 then
    p_item.visible = false
    return
  end
  p_item.visible = true
  p_item.size = ui.point(300, 35)
  p_panel.size = ui.point(p_panel.dx, 35)
  local item = list_view:item_append()
  item:load_style(rewards_uri, "title_text")
  item.size = ui.point(300, 20)
  local title = item:search("title")
  title.text = ui.get_text("quest|awd_goods")
  if ui_quest.insert_goods(list_view, list, false, m) then
    p_item.dy = p_item.dy + 45
    p_panel.dy = p_panel.dy + 45
  else
    p_item.visible = false
  end
end
function set_money(excel)
  if excel.type == bo2.eQuestType_Repeat then
    w_money.bounded = true
  elseif excel.awd_money_kind == bo2.eCurrency_CirculatedMoney then
    w_money.bounded = false
  else
    w_money.bounded = true
  end
  w_money.money = excel.awd_money
  w_money.parent.parent.visible = true
end
function set_reputation(excel)
  w_rep.text = L("0")
  for i = 0, 3 do
    local questobj = excel.awd_obj[i]
    if questobj == bo2.eQuestObj_ReputePoint then
      local rep_e = bo2.gv_repute_list:find(excel.awd_id[i])
      if rep_e ~= nil and rep_e.disable == 0 then
        w_rep.text = sys.format("(%s) %d", rep_e.name, excel.awd_num[i])
        w_rep.parent.parent.visible = true
      end
    end
  end
end
function set_exp(excel)
  local awd_exp = ui_quest.exp_weaken(excel, excel.awd_exp)
  w_exp.text = awd_exp
  w_exp.parent.parent.visible = true
end
function set_quest_reward(list, m)
  set_money(list)
  set_reputation(list)
  set_exp(list)
  set_quest_rewards(w_rewards_list, list, w_parent_list, 6, m)
end
function set_quest_select_reward(list, m)
  ui_quest.set_quest_select_rewards(w_select_rewards_list, list, w_parent_list, "quest_select_rewards", m)
end
function on_add_quest()
  local item = w_quest_list.item_sel
  if item == nil then
    ui_quest.quest_show_text(ui.get_text("quest|quest_sel_warning"), ui_quest.c_warning_color)
    return
  end
  local id = item.var:get("excel_id").v_int
  ui_quest.add(id)
end
function on_close()
  set_visible(false)
end
function on_item_sel(ctrl, v)
  local id = ctrl.var:get("excel_id").v_int
  local select = ctrl:search("select")
  select.visible = v
  if v then
    local pic_move = ctrl:search("pic_move")
    if pic_move then
      pic_move.visible = not v
    end
    local var = sys.variant()
    local excel = bo2.gv_quest_list:find(id)
    if excel == nil then
      return
    end
    var:set(packet.key.item_key, excel.cooldown)
    bo2.send_variant(packet.eCTS_UI_CDToken, var)
    set_quest_value(id)
  end
end
function on_btn_move(ctrl, msg, pos, wheel)
  local pic_move = ctrl:search("pic_move")
  if pic_move == nil then
    return
  end
  local lbl_text = ctrl:search("item_text")
  if msg == ui.mouse_inner and ctrl.selected == false then
    pic_move.visible = true
  end
  if msg == ui.mouse_outer or ctrl.selected then
    pic_move.visible = false
  end
end
function clear()
  g_qtable = {}
  if not sys.check(w_quest_list) then
    return
  end
  w_quest_list:item_clear()
  w_money.money = 0
  w_exp.text = "0"
  w_rep.text = "0"
  w_desc_title.text = ""
  w_title.text = ""
  w_quest_aim:item_clear()
  w_exp.parent.parent.visible = true
  w_rep.parent.parent.visible = true
  w_money.parent.parent.visible = true
  if w_common == nil then
    return
  end
  local btn = w_common:search("btn_fit_commend")
  btn.check = false
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
  else
    ui_widget.esc_stk_pop(w)
    clear()
  end
end
function add_current_quest(info)
  if w_main.visible == false then
    return
  end
  if del_item(info.excel_id) == true then
    set_select(0)
  end
  if w_quest_list.item_count == 0 then
    set_visible(false)
  end
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_quest.ui_reputation.packet_handle"
reg(packet.eSTC_UI_CDToken, on_get_cd_token, sig)
