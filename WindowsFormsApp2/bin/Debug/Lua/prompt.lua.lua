function update()
  w_huodong:item_clear()
  w_huodong:insert_mtf(sys.format("<a:l><lb:,,,d2b48c|%s><a:r><lb:,,,d2b48c|%s>", ui.get_text("prompt|zhongyaohuodong"), 0), ui.mtf_rank_system)
  w_renwu:item_clear()
  w_renwu:insert_mtf(sys.format("<a:l><lb:,,,d2b48c|%s><a:r><lb:,,,d2b48c|%s>", ui.get_text("prompt|renwu"), 0), ui.mtf_rank_system)
  w_xiaoxi:item_clear()
  w_xiaoxi:insert_mtf(sys.format("<a:l><lb:,,,d2b48c|%s><a:r><lb:,,,d2b48c|%s>", ui.get_text("prompt|xiaoxi"), 0), ui.mtf_rank_system)
  w_jimai:item_clear()
  w_jimai:insert_mtf(sys.format("<a:l><lb:,,,d2b48c|%s><a:r><lb:,,,d2b48c|%s>", ui.get_text("prompt|jimaihang"), 0), ui.mtf_rank_system)
  w_bangpai:item_clear()
  w_bangpai:insert_mtf(sys.format("<a:l><lb:,,,d2b48c|%s><a:r><lb:,,,d2b48c|%s>", ui.get_text("prompt|bangpai"), 0), ui.mtf_rank_system)
  w_im:item_clear()
  w_im:insert_mtf(sys.format("<a:l><lb:,,,d2b48c|%s><a:r><lb:,,,d2b48c|%s>", ui.get_text("prompt|IM"), 0), ui.mtf_rank_system)
  w_cross_line:item_clear()
  w_cross_line:insert(sys.format("<a:l><lb:,,,d2b48c|%s><a:r><lb:,,,d2b48c|%s>", ui.get_text("cross_line|cross_line_rank"), 0), ui.mtf_rank_system)
end
function zhongyaohuodong()
  ui.log("zhongyaohuodong")
  local campaign_view = ui.find_control("$frame:campaign")
  campaign_view.visible = not campaign_view.visible
end
function weiwanchengrenwu()
  local w = ui.find_control("$frame:received_quest")
  w.visible = true
  ui.log("weiwanchengrenwu")
end
function lixianliuyan()
  ui.log("lixianliuyan")
  ui_mail.gx_window.visible = true
end
function jimaihangjiaoyi()
  ui.log("jimaihangjiaoyi")
  local num = ui_supermarket.ui_ahitem.get_ahlist_size()
  ui_supermarket.w_main.visible = true
  ui_widget.ui_tab.show_page(ui_supermarket.w_main, "ahitem", true)
end
function bangpaixinxi()
  ui.log("bangpaixinxi")
  if ui.guild_get_self() == nil then
    ui_chat.show_ui_text_id(70251)
    return
  end
  local campaign_view = ui.find_control("$frame:guild")
  campaign_view.visible = not campaign_view.visible
end
function TMtongzhi()
  ui.log("TMtongzhi")
end
function on_visible()
end
local event = {
  zhongyaohuodong,
  weiwanchengrenwu,
  lixianliuyan,
  jimaihangjiaoyi,
  bangpaixinxi,
  TMtongzhi
}
local info = {}
function on_init_event(ctrl, data)
  local event_id = data.v_int
  ctrl.var:set("event_id", event_id)
end
function on_online(ctrl, msg, pos, data)
  local index = ctrl.var:get("event_id").v_int
  if index == nil or index == 0 then
    return
  end
  if msg == ui.mouse_lbutton_down then
    event[index]()
  end
end
function set_start_time()
  if flag == false then
    start_time = os.clock()
    start_CirculatedMoney = bo2.player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    start_BoundedMoney = bo2.player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
    start_level = bo2.player:get_atb(bo2.eAtb_Level)
    start_exp = bo2.player:get_atb(bo2.eAtb_Cha_SumExp) + bo2.player:get_atb(bo2.eAtb_Cha_Exp)
    flag = true
  end
end
function update_org_group(cmd)
  if cmd ~= bo2.eSTC_Guild_MemberList or cmd ~= bo2.eSTC_Guild_MemberData then
    return
  end
  local org_id = bo2.is_in_guild()
  if org_id ~= sys.wstring(0) and (cur_org_id == nil or cur_org_id ~= org_id) then
    local self = ui.guild_get_self()
    if self then
      cur_org_id = org_id
      start_con = self.total_con
    end
  end
end
function get_start_time()
  return start_time
end
function insert_item_by(text, dy)
  local item = ui.create_control(w_offline_items, "panel")
  item:load_style("$frame/prompt/prompt.xml", "item")
  item.dy = dy
  local box = item:search("item")
  box:insert_mtf(text, ui.mtf_rank_system)
end
function insert_item(text)
  local item = ui.create_control(w_offline_items, "panel")
  item:load_style("$frame/prompt/prompt.xml", "item")
  local box = item:search("item")
  box:insert_mtf(text, ui.mtf_rank_system)
end
function lost_exp(cmd, data)
  local value = data:get(packet.key.ui_lost_exp).v_int
  ui.log("lost_exp %s", value)
  if lost_exp_value then
    lost_exp_value = lost_exp_value + value
  else
    lost_exp_value = value
  end
end
function set_end_time()
  w_offline_items:control_clear()
  end_time = os.clock() - start_time
  insert_item(sys.format("<a:l><lb:,,,d2b48c|%s><a:r><lb:,,,d2b48c|%s>", ui.get_text("prompt|online_time"), ui_state.cal_time(end_time * 1000)))
  end_exp = bo2.player:get_atb(bo2.eAtb_Cha_SumExp) + bo2.player:get_atb(bo2.eAtb_Cha_Exp) - start_exp + lost_exp_value
  insert_item(sys.format("<a:l><lb:,,,d2b48c|%s><a:r><lb:,,,ffffff|%s>", ui.get_text("prompt|get_exp"), end_exp))
  if lost_exp_value > 0 then
    insert_item(sys.format("<a:l><lb:,,,d2b48c|%s><a:r><lb:,,,ffffff|%s>", ui.get_text("prompt|lost_exp"), lost_exp_value))
  end
  cannel_seconds = bo2.gv_define:find(54).value.v_int
  if bo2.player.is_fight then
    cannel_seconds = bo2.gv_define:find(668).value.v_int
  end
  w_cannel_timer.suspended = false
  insert_item(sys.format("<a:l><lb:,,,d2b48c|%s><a:r><lb:,,,d2b48c|%s>", ui.get_text("prompt|view_count"), ui_view_personal.g_view_count))
  local cur_level = bo2.player:get_atb(bo2.eAtb_Level)
  if cur_level > start_level then
    insert_item(sys.format("<a:l><lb:,,,d2b48c|%s><a:r><lb:,,,d2b48c|%s>-><lb:,,,d2b48c|%s>", ui.get_text("prompt|level_up"), start_level, cur_level))
  end
  if bo2.is_in_guild() ~= sys.wstring(0) and start_con then
    local end_con = ui.guild_get_self().total_con - start_con
    insert_item(sys.format("<a:l><lb:,,,d2b48c|%s><a:r><lb:,,,d2b48c|%s>", ui.get_text("prompt|gongxian"), math.floor(end_con)))
  end
  end_CirculatedMoney = bo2.player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney) - start_CirculatedMoney
  end_BoundedMoney = bo2.player:get_flag_int32(bo2.eFlagInt32_BoundedMoney) - start_BoundedMoney
  if 0 > end_CirculatedMoney then
    insert_item(sys.format("<a:l><lb:,,,ff0000|%s><a:r><m:%s>", ui.get_text("prompt|lose_c_money"), math.abs(end_CirculatedMoney)))
  else
    insert_item(sys.format("<a:l><lb:,,,00ff00|%s><a:r><m:%s>", ui.get_text("prompt|get_c_money"), math.abs(end_CirculatedMoney)))
  end
  if 0 > end_BoundedMoney then
    insert_item(sys.format("<a:l><lb:,,,ff0000|%s><a:r><bm:%s>", ui.get_text("prompt|lose_b_money"), math.abs(end_BoundedMoney)))
  else
    insert_item(sys.format("<a:l><lb:,,,00ff00|%s><a:r><bm:%s>", ui.get_text("prompt|get_b_money"), math.abs(end_BoundedMoney)))
  end
end
function send_cannel()
  local v = sys.variant()
  v:set(packet.key.ui_exitgame_type, bo2.eExitGame_Cancel)
  bo2.send_variant(packet.eCTS_UI_PlayExitGame, v)
  w_cannel_timer.suspended = true
end
function on_close()
  w_offline_prompt.visible = false
end
function on_send_gs_rank()
  local obj_level = ui.safe_get_atb(bo2.eAtb_Level)
  if obj_level < 30 then
    return
  end
  on_handle_gs_rank()
end
function on_handle_gs_rank(cmd, data)
  ui_tool.note_insert(ui.get_text("cross_line|offline_desc"), L("FF00FF00"))
end
function on_set_wish_item()
  local wish_idx = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_TodayWishID)
  local wish_kind = ui_wish.get_wish_kind(wish_idx)
  local wish_table = ui_wish.get_wish_table(wish_idx)
  if wish_table == nil then
    w_wish_item.visible = false
    return
  end
  local final_excel = wish_table:find(wish_idx)
  if wish_idx ~= 0 then
    local time_label = w_wish_item:search("time_label")
    local wish_come_true_time = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_WishComeTrueTime)
    local cur_time = bo2.get_server_time()
    if wish_come_true_time > cur_time then
      time_label.left_time = wish_come_true_time - cur_time
    end
    local card = w_wish_item:search("card")
    local count = w_wish_item:search("count")
    card.excel_id = final_excel.award[0]
    if final_excel.award.size == 1 then
      count.text = 1
    else
      count.text = final_excel.award[1]
    end
    w_wish_item.visible = true
  else
    w_wish_item.visible = false
  end
end
function on_offline_visible(v)
  if w_offline_prompt.visible == true then
    set_end_time()
    bo2.player:SetMoveState(0)
    w_offline_prompt.focus = true
    w_cannel_time_label:search("label").text = sys.format("%d %s", cannel_seconds, ui.get_text("prompt|second"))
    if not bo2.player:have_ride() and not bo2.player:IsDead() then
      bo2.player:AnimPlayFadeIn(250, true, false, 2, 0)
    end
    on_send_gs_rank()
    on_set_wish_item()
  elseif w_offline_prompt.visible == false then
    send_cannel()
    if not bo2.player:have_ride() and not bo2.player:IsDead() then
      bo2.player:AnimPlayFadeIn(1, true, false, 2, 0)
    end
  end
end
function on_cannel()
  w_offline_prompt.visible = false
end
function on_quit()
  bo2.app_quit()
end
function on_offline(cmd, data)
  local value = data:get(packet.key.ui_exitgame_type).v_int
  if value == 0 then
    w_login_out.visible = true
    w_gzs_out.visible = false
  elseif value == 1 then
    w_login_out.visible = false
    w_gzs_out.visible = true
  end
  w_offline_prompt.visible = true
  bo2.breakmove_k()
end
function on_cannel_timer()
  w_cannel_time_label:search("label").text = sys.format("%d %s", cannel_seconds, ui.get_text("prompt|second"))
  cannel_seconds = cannel_seconds - 1
  if sys.check(ui_npcfunc.ui_talk) and sys.check(ui_npcfunc.ui_talk.w_talk) and ui_npcfunc.ui_talk.w_talk.visible == true then
    ui_npcfunc.ui_talk.w_talk.visible = false
    ui_npcfunc.ui_talk.send_close()
  end
  if cannel_seconds <= 0 then
    w_cannel_timer.suspended = true
    if sys.check(ui_skill_preview) then
      ui_skill_preview.on_leave_game()
    end
  end
end
function on_fight(obj)
  if obj == bo2.player then
    w_offline_prompt.visible = false
  end
end
function on_init(dlg)
  flag = false
  lost_exp_value = 0
  end_time = 0
  start_time = 0
  end_exp = 0
  lost_exp_value = 0
  start_exp = 0
  start_level = 0
  start_con = 0
  start_CirculatedMoney = 0
  start_BoundedMoney = 0
  end_CirculatedMoney = 0
  end_BoundedMoney = 0
  ui.log("prompt init")
  ui_widget.on_esc_stk_visible(dlg)
  ui.insert_on_guild_refresh("ui_prompt.update_org_group")
end
function on_self_enter(obj)
  if flag == false then
  end
end
local sig_name = "ui_prompt:update_player"
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_begin_fight, on_fight, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_ExitGameTimeBegin, on_offline, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_LostExp, lost_exp, sig_name)
local sig_name = "ui_prompt:on_handle_gs_rank"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Sociality_CrossLineGSRank, on_handle_gs_rank, sig_name)
