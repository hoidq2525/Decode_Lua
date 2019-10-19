local eWishKind_Item = 1
local eWishKind_Money = 2
local eWishKind_Exp = 3
local a = -60
local v0 = 360
local s = 0
function on_init()
end
function on_visible(ctrl, vis)
  local level = bo2.player:get_atb(bo2.eAtb_Level)
  if vis then
    ui_widget.esc_stk_push(ctrl)
    if level < 5 then
      gx_window.visible = false
    end
  else
    ui_widget.esc_stk_pop(ctrl)
  end
  local wish_idx = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_TodayWishID)
  if wish_idx ~= 0 then
    rand_animation_finish()
  else
    rand_animation_ready()
  end
end
function on_click_choose_kind(btn)
  local name = btn.parent.parent.name
  local wish_kind = 0
  if name == L("item") then
    wish_kind = eWishKind_Item
  elseif name == L("money") then
    wish_kind = eWishKind_Money
  elseif name == L("exp") then
    wish_kind = eWishKind_Exp
  end
  local v = sys.variant()
  v:set(packet.key.cmn_id, wish_kind)
  bo2.send_variant(packet.eCTS_UI_MakeAWish, v)
end
function rand_animation_ready()
  m_main_card.visible = false
  m_wishing_text.visible = false
  m_bg_figure.visible = false
  m_btn_panel.visible = true
  m_main_cover.visible = true
  m_quit_panel.visible = true
  local item_panel = m_btn_panel:search("item")
  local money_panel = m_btn_panel:search("money")
  local exp_panel = m_btn_panel:search("exp")
  item_panel:search("btn_panel").visible = true
  item_panel:search("result_panel").visible = false
  money_panel:search("btn_panel").visible = true
  money_panel:search("result_panel").visible = false
  exp_panel:search("btn_panel").visible = true
  exp_panel:search("result_panel").visible = false
  local btn_item = m_btn_panel:search("item"):search("btn")
  local btn_money = m_btn_panel:search("money"):search("btn")
  local btn_exp = m_btn_panel:search("exp"):search("btn")
  btn_item.enable = true
  btn_money.enable = true
  btn_exp.enable = true
  m_timer.suspended = true
end
function rand_animation_finish()
  local wish_idx = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_TodayWishID)
  local wish_kind = get_wish_kind(wish_idx)
  local wish_table = get_wish_table(wish_idx)
  if wish_table == nil then
    return
  end
  local final_excel = wish_table:find(wish_idx)
  local wish_panel = m_btn_panel:search(wish_kind)
  local btn_panel = wish_panel:search("btn_panel")
  local result_panel = wish_panel:search("result_panel")
  m_main_card.visible = false
  m_wishing_text.visible = false
  m_bg_figure.visible = false
  btn_panel.visible = false
  m_btn_panel.visible = true
  m_main_cover.visible = true
  m_quit_panel.visible = true
  result_panel.visible = true
  local btn_item = m_btn_panel:search("item"):search("btn")
  local btn_money = m_btn_panel:search("money"):search("btn")
  local btn_exp = m_btn_panel:search("exp"):search("btn")
  btn_item.enable = false
  btn_money.enable = false
  btn_exp.enable = false
  local wish_come_true_time = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_WishComeTrueTime)
  local cur_time = bo2.get_server_time()
  if wish_come_true_time > cur_time and wish_idx ~= 0 then
    local time_label = result_panel:search("time_label")
    time_label.left_time = wish_come_true_time - cur_time
    local card = result_panel:search("card")
    local count = result_panel:search("count")
    card.excel_id = final_excel.award[0]
    if final_excel.award.size == 1 then
      count.text = 1
    else
      count.text = final_excel.award[1]
    end
  end
  m_timer.suspended = true
end
function rand_animation_start()
  m_btn_panel.visible = false
  m_main_cover.visible = false
  m_quit_panel.visible = false
  m_main_card.visible = true
  m_wishing_text.visible = true
  m_bg_figure.visible = true
  local btn_i_know = m_wishing_text:search("btn_i_know")
  btn_i_know.enable = false
  m_wishing_text:search("lbl").mtf = ui.get_text("wish|wishing_text")
  m_timer.suspended = false
  local card = m_main_card:search("card1")
  card.margin = ui.rect(-32, 0, 0, 0)
  a = -60
  v0 = 360
  s = 0
end
function set_visible(index)
  gx_window.visible = true
  if index == 0 then
    ui_chat.show_ui_text_id(2551)
    local btn_quit = m_quit_panel:search("btn_quit")
    local btn_re_sel = m_quit_panel:search("btn_re_select")
    btn_quit.visible = false
    btn_re_sel.visible = true
  elseif index == 1 then
    ui_chat.show_ui_text_id(2551)
    local btn_quit = m_quit_panel:search("btn_quit")
    local btn_re_sel = m_quit_panel:search("btn_re_select")
    btn_quit.visible = true
    btn_re_sel.visible = false
  else
    local btn_quit = m_quit_panel:search("btn_quit")
    local btn_re_sel = m_quit_panel:search("btn_re_select")
    btn_quit.visible = false
    btn_re_sel.visible = false
  end
end
function on_click_back_to_game(btn)
  gx_window.visible = false
end
function on_click_re_select_cha(btn)
  ui_main.goto_choice()
end
function on_click_quit_game(btn)
  ui_main.goto_startup()
end
function on_timer()
  local t = m_timer.period / 1000
  local vt = v0 + a * t
  local card = m_main_card:search("card1")
  if card == nil then
    return
  end
  local margin = card.margin
  local s = 0.5 * a * t * t + v0 * t
  v0 = vt
  card.margin = ui.rect(margin.x1 - s, margin.y1, margin.x2, margin.y2)
  if v0 < 0 then
    m_timer.suspended = true
    local wish_idx = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_TodayWishID)
    if wish_idx ~= 0 then
      local btn_i_know = m_wishing_text:search("btn_i_know")
      btn_i_know.enable = true
      local v = sys.variant()
      local card_panel = m_main_card:search("card_final")
      local item = card_panel:search("item")
      local count = card_panel:search("count")
      v:set("id", item.excel_id)
      v:set("count", count.text)
      m_wishing_text:search("lbl").mtf = sys.mtf_merge(v, ui.get_text("wish|come_true_text"))
    end
  end
end
function on_click_i_know(btn)
  local wish_idx = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_TodayWishID)
  if wish_idx ~= 0 then
    rand_animation_finish()
  else
    rand_animation_ready()
  end
end
function get_wish_kind(excel_id)
  if excel_id < 1000 then
    return L("exp")
  elseif excel_id < 2000 then
    return L("item")
  elseif excel_id < 3000 then
    return L("money")
  else
    return L("")
  end
end
function get_wish_table(id)
  if id < 1000 then
    return bo2.gv_wish_list_exp
  elseif id < 2000 then
    return bo2.gv_wish_list_item
  elseif id < 3000 then
    return bo2.gv_wish_list_money
  else
    return nil
  end
end
function on_wish_come_true(cmd, data)
  local id = data:get(packet.key.cmn_id).v_int
  local count = data:get(packet.key.cmn_count).v_int
  ui_come_true.set_visible(id, count)
  if gx_window.visible then
    rand_animation_ready()
  end
end
function on_rand_wish_excel(cmd, data)
  local excel_id = data:get(packet.key.cmn_id).v_int
  local card_panel = m_main_card:search("card_final")
  if card_panel == nil then
    return
  end
  local card = card_panel:search("item")
  local count = card_panel:search("count")
  if card == nil then
    return
  end
  if count == nil then
    return
  end
  local wish_table = get_wish_table(excel_id)
  if wish_table == nil then
    return
  end
  local final_excel = wish_table:find(excel_id)
  if final_excel == nil then
    return
  end
  card.excel_id = final_excel.award[0]
  if final_excel.award.size == 1 then
    count.text = 1
  else
    count.text = final_excel.award[1]
  end
  local rand_item = {}
  for i = 0, wish_table.size - 1 do
    local temp = wish_table:get(i)
    if temp.award.size == 1 then
      table.insert(rand_item, {
        id = temp.award[0],
        count = 1
      })
    else
      table.insert(rand_item, {
        id = temp.award[0],
        count = temp.award[1]
      })
    end
  end
  math.randomseed(tostring(os.time()):reverse():sub(1, 6))
  for i = 1, 21 do
    local idx = math.random(#rand_item)
    local temp_panel = m_main_card:search("card" .. i)
    local temp_card = temp_panel:search("item")
    local temp_count = temp_panel:search("count")
    temp_card.excel_id = rand_item[idx].id
    temp_count.text = rand_item[idx].count
    if #rand_item > 1 then
      table.remove(rand_item, idx)
    end
  end
  bo2.AddTimeEvent(5, rand_animation_start)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_wish.packet_handle"
reg(packet.eSTC_UI_RandWishExcel, on_rand_wish_excel, sig)
reg(packet.eSTC_UI_WishComeTrue, on_wish_come_true, sig)
