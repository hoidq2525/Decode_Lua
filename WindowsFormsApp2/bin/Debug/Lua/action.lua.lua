function on_tip_make(tip)
  local action = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_action_yes)
  local stk = sys.mtf_stack()
  local cfm_text = ui.get_text("personal|action_desc")
  local arg = sys.variant()
  arg:set("count", action)
  stk:raw_format(sys.mtf_merge(arg, cfm_text))
  ui_widget.tip_make_view(tip.view, stk.text)
end
function get_prize(id)
  ui.log("get_prize %s %s %s", id, packet.key.prize_id, packet.eCTS_UI_Active_GetPrize)
  local v = sys.variant()
  v:set(packet.key.prize_id, id)
  bo2.send_variant(packet.eCTS_UI_Active_GetPrize, v)
end
function on_btn_prize1(btn)
  get_prize(1)
end
function on_btn_prize2(btn)
  get_prize(2)
end
function on_btn_prize3(btn)
  get_prize(3)
end
function on_btn_prize4(btn)
  get_prize(4)
end
function on_get_prize1(btn, msg)
  if msg == ui.mouse_lbutton_click then
    get_prize(1)
    update()
  end
end
function on_get_prize2(btn, msg)
  if msg == ui.mouse_lbutton_click then
    get_prize(2)
  end
end
function on_get_prize3(btn, msg)
  if msg == ui.mouse_lbutton_click then
    get_prize(3)
  end
end
function on_get_prize4(btn, msg)
  if msg == ui.mouse_lbutton_click then
    get_prize(4)
  end
end
function hight_light_prize(w, b)
  if b == true then
    w:search("lb_item").color = ui.make_color("ffffff")
    w:search("lb_1").color = ui.make_color("ffffff")
    w:search("lb_2").color = ui.make_color("ffffff")
    w:search("pic_grid").effect = ""
    w:search("active_prize").color = ui.make_color("d2b48c")
    w:search("active_count").color = ui.make_color("d2b48c")
    w:search("prize_btn").enable = true
  elseif b == false then
    w:search("lb_item").color = ui.make_color("808080")
    w:search("lb_1").color = ui.make_color("808080")
    w:search("lb_2").color = ui.make_color("808080")
    w:search("pic_grid").effect = "gray"
    w:search("active_prize").color = ui.make_color("808080")
    w:search("active_count").color = ui.make_color("808080")
    w:search("prize_btn").enable = false
  end
end
function on_exchange_visible()
  local player = bo2.player
  if bo2.player == nil then
    return
  end
  local level = bo2.player:get_atb(bo2.eAtb_Level)
  if level <= 20 then
    ui_tool.ui_tool.note_insert(ui.get_text("action|change_limit"), "ffff00")
    w_exchange.visible = false
    return
  end
  update()
  w_item1:search("button").enable = false
  w_item2:search("button").enable = false
  w_item3:search("button").enable = false
  if sys.check(cur_select) then
    cur_select.visible = false
    cur_select = nil
  end
  cur_select_change = {}
end
function update()
  local player = bo2.player
  if bo2.player == nil then
    return
  end
  local action = player:get_flag_int32(bo2.ePlayerFlagInt32_action)
  local action_yes = player:get_flag_int32(bo2.ePlayerFlagInt32_action_yes)
  local cbattle_yes = player:get_flag_int8(bo2.ePlayerFlagInt8_ClonedBattleYesterdayCount)
  local knight_yes = player:get_flag_int8(bo2.ePlayerFlagInt8_KnightYesCount)
  local battle_yes = player:get_flag_int8(bo2.ePlayerFlagInt8_BattleYesCount)
  w_item1:search("remain").text = ui_widget.merge_mtf({count = action_yes}, ui.get_text("action|point"))
  w_item2:search("remain").text = ui_widget.merge_mtf({
    count = cbattle_yes + knight_yes
  }, ui.get_text("action|ci"))
  w_item3:search("remain").text = ui_widget.merge_mtf({count = battle_yes}, ui.get_text("action|ci"))
  if action_yes == 0 then
    w_item1:search("button").enable = false
    w_item1.enable = false
    w_item1:search("item1").color = ui.make_color("999999")
    w_item1:search("item2").color = ui.make_color("999999")
    w_item1:search("item3").color = ui.make_color("999999")
  else
    w_item1:search("button").enable = true
    w_item1.enable = true
    w_item1:search("item1").color = ui.make_argb("00000000")
    w_item1:search("item2").color = ui.make_argb("00000000")
    w_item1:search("item3").color = ui.make_argb("00000000")
  end
  if cbattle_yes + knight_yes == 0 then
    w_item2:search("button").enable = false
    w_item2.enable = false
    w_item2:search("item4").color = ui.make_color("999999")
    w_item2:search("item5").color = ui.make_color("999999")
    w_item2:search("item6").color = ui.make_color("999999")
  else
    w_item2:search("button").enable = true
    w_item2.enable = true
    w_item2:search("item4").color = ui.make_argb("00000000")
    w_item2:search("item5").color = ui.make_argb("00000000")
    w_item2:search("item6").color = ui.make_argb("00000000")
  end
  if battle_yes == 0 then
    w_item3:search("button").enable = false
    w_item3.enable = false
    w_item3:search("item7").color = ui.make_color("999999")
    w_item3:search("item8").color = ui.make_color("999999")
    w_item3:search("item9").color = ui.make_color("999999")
  else
    w_item3:search("button").enable = true
    w_item3.enable = true
    w_item3:search("item7").color = ui.make_argb("00000000")
    w_item3:search("item8").color = ui.make_argb("00000000")
    w_item3:search("item9").color = ui.make_argb("00000000")
  end
  local index = bo2.player:get_atb(bo2.eAtb_Level)
  local excel = bo2.gv_action_exchange:find(index)
  if excel == nil then
    return
  end
  sys.fp_pcall(function()
    w_item1:search("money1").money = math.ceil(excel.money * action_yes)
    w_item1:search("exp1").text = excel.exp * action_yes
    w_item1:search("money2").text = math.ceil(excel.rmb * action_yes)
    w_item1:search("exp2").text = excel.rmb_exp * action_yes
    w_item1:search("money3").text = math.ceil(excel.rmb1 * action_yes)
    w_item1:search("exp3").text = excel.rmb1_exp * action_yes
    w_item2:search("money1").money = math.floor(excel.xinxiu_money * cbattle_yes + excel.knight_money * knight_yes)
    w_item2:search("exp1").text = excel.xinxiu_exp * cbattle_yes + excel.knight_exp * knight_yes
    w_item2:search("money2").text = math.floor(excel.xinxiu1_money * cbattle_yes + excel.knight1_money * knight_yes)
    w_item2:search("exp2").text = excel.xinxiu1_exp * cbattle_yes + excel.knight1_exp * knight_yes
    w_item2:search("money3").text = math.floor(excel.xinxiu2_money * cbattle_yes + excel.knight2_money * knight_yes)
    w_item2:search("exp3").text = excel.xinxiu2_exp * cbattle_yes + excel.knight2_exp * knight_yes
    w_item3:search("money1").money = math.floor(excel.battle_money * battle_yes)
    w_item3:search("exp1").text = excel.battle_exp * battle_yes
    w_item3:search("money2").text = math.floor(excel.battle1_money * battle_yes)
    w_item3:search("exp2").text = excel.battle1_exp * battle_yes
    w_item3:search("money3").text = math.floor(excel.battle2_money * battle_yes)
    w_item3:search("exp3").text = excel.battle2_exp * battle_yes
    local n = bo2.gv_define:find(554)
    local total = tonumber(tostring(n.value))
    if total == 0 then
      return
    end
    local text_str = sys.format("%s%s/%s", ui.get_text("personal|action"), action, total)
    ui_personal.ui_equip.w_action.text = text_str
    local gift_str = sys.format("%s/%s", action, total)
    ui_gift_login.w_action.text = gift_str
  end)
end
cur_select = nil
cur_select_change = {}
function on_confirm(msg)
  if msg.result == 0 then
    return
  end
  local v = sys.variant()
  v:set(packet.key.cmn_type, cur_select_change.item)
  v:set(packet.key.cmn_index, cur_select_change.index)
  bo2.send_variant(packet.eCTS_UI_ActionExchange, v)
end
function on_change1(btn)
  if cur_select_change.index ~= 1 then
    return
  end
  local player = bo2.player
  if bo2.player == nil then
    return
  end
  local action_yes = player:get_flag_int32(bo2.ePlayerFlagInt32_action_yes)
  local index = bo2.player:get_atb(bo2.eAtb_Level)
  local excel = bo2.gv_action_exchange:find(index)
  if excel == nil then
    return
  end
  local msg = {
    callback = on_confirm,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  sys.fp_pcall(function()
    if cur_select_change.item == 1 then
      msg.text = ui_widget.merge_mtf({
        count = action_yes,
        money = math.ceil(excel.money * action_yes),
        exp = excel.exp * action_yes
      }, ui.get_text("action|chg_action_bmoney"))
    elseif cur_select_change.item == 2 then
      msg.text = ui_widget.merge_mtf({
        count = action_yes,
        money = math.ceil(excel.rmb * action_yes),
        exp = excel.rmb_exp * action_yes
      }, ui.get_text("action|chg_action_brmb"))
    elseif cur_select_change.item == 3 then
      msg.text = ui_widget.merge_mtf({
        count = action_yes,
        money = math.ceil(excel.rmb1 * action_yes),
        exp = excel.rmb1_exp * action_yes
      }, ui.get_text("action|chg_action_rmb"))
    end
  end)
  ui_widget.ui_msg_box.show_common(msg)
end
function on_change2(btn)
  if cur_select_change.index ~= 2 then
    return
  end
  local player = bo2.player
  if bo2.player == nil then
    return
  end
  local cbattle_yes = player:get_flag_int8(bo2.ePlayerFlagInt8_ClonedBattleYesterdayCount)
  local knight_yes = player:get_flag_int8(bo2.ePlayerFlagInt8_KnightYesCount)
  local index = bo2.player:get_atb(bo2.eAtb_Level)
  local excel = bo2.gv_action_exchange:find(index)
  if excel == nil then
    return
  end
  local msg = {
    callback = on_confirm,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  if cur_select_change.item == 1 then
    msg.text = ui_widget.merge_mtf({
      money = math.floor(excel.xinxiu_money * cbattle_yes) + excel.knight_money * knight_yes,
      exp = excel.xinxiu_exp * cbattle_yes + excel.knight_exp * knight_yes
    }, ui.get_text("action|chg_action_money1"))
  elseif cur_select_change.item == 2 then
    msg.text = ui_widget.merge_mtf({
      money = math.floor(excel.xinxiu1_money * cbattle_yes) + excel.knight1_money * knight_yes,
      exp = excel.xinxiu1_exp * cbattle_yes + excel.knight1_exp * knight_yes
    }, ui.get_text("action|chg_action_brmb1"))
  elseif cur_select_change.item == 3 then
    msg.text = ui_widget.merge_mtf({
      money = math.floor(excel.xinxiu2_money * cbattle_yes) + excel.knight2_money * knight_yes,
      exp = excel.xinxiu2_exp * cbattle_yes + excel.knight2_exp * knight_yes
    }, ui.get_text("action|chg_action_rmb1"))
  end
  ui_widget.ui_msg_box.show_common(msg)
end
function on_change3(btn)
  if cur_select_change.index ~= 3 then
    return
  end
  local player = bo2.player
  if bo2.player == nil then
    return
  end
  local battle_yes = player:get_flag_int8(bo2.ePlayerFlagInt8_BattleYesCount)
  local index = bo2.player:get_atb(bo2.eAtb_Level)
  local excel = bo2.gv_action_exchange:find(index)
  if excel == nil then
    return
  end
  local msg = {
    callback = on_confirm,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  if cur_select_change.item == 1 then
    msg.text = ui_widget.merge_mtf({
      money = math.floor(excel.battle_money * battle_yes),
      exp = excel.battle_exp * battle_yes
    }, ui.get_text("action|chg_action_money1"))
  elseif cur_select_change.item == 2 then
    msg.text = ui_widget.merge_mtf({
      money = math.floor(excel.battle1_money * battle_yes),
      exp = excel.battle1_exp * battle_yes
    }, ui.get_text("action|chg_action_brmb1"))
  elseif cur_select_change.item == 3 then
    msg.text = ui_widget.merge_mtf({
      money = math.floor(excel.battle2_money * battle_yes),
      exp = excel.battle2_exp * battle_yes
    }, ui.get_text("action|chg_action_rmb1"))
  end
  ui_widget.ui_msg_box.show_common(msg)
end
function on_mouse1(btn, msg)
  if ui.mouse_lbutton_click == msg then
    if sys.check(cur_select) then
      cur_select.visible = false
    end
    cur_select = btn:search("figure")
    btn:search("figure").visible = true
    cur_select_change = {index = 1, item = 1}
    w_item1:search("button").enable = true
    w_item2:search("button").enable = false
    w_item3:search("button").enable = false
  end
end
function on_mouse2(btn, msg)
  if ui.mouse_lbutton_click == msg then
    if sys.check(cur_select) then
      cur_select.visible = false
    end
    cur_select = btn:search("figure")
    btn:search("figure").visible = true
    cur_select_change = {index = 1, item = 2}
    w_item1:search("button").enable = true
    w_item2:search("button").enable = false
    w_item3:search("button").enable = false
  end
end
function on_mouse3(btn, msg)
  if ui.mouse_lbutton_click == msg then
    if sys.check(cur_select) then
      cur_select.visible = false
    end
    cur_select = btn:search("figure")
    btn:search("figure").visible = true
    cur_select_change = {index = 1, item = 3}
    w_item1:search("button").enable = true
    w_item2:search("button").enable = false
    w_item3:search("button").enable = false
  end
end
function on_mouse4(btn, msg)
  if ui.mouse_lbutton_click == msg then
    if sys.check(cur_select) then
      cur_select.visible = false
    end
    cur_select = btn:search("figure")
    btn:search("figure").visible = true
    cur_select_change = {index = 2, item = 1}
    w_item1:search("button").enable = false
    w_item2:search("button").enable = true
    w_item3:search("button").enable = false
  end
end
function on_mouse5(btn, msg)
  if ui.mouse_lbutton_click == msg then
    if sys.check(cur_select) then
      cur_select.visible = false
    end
    cur_select = btn:search("figure")
    btn:search("figure").visible = true
    cur_select_change = {index = 2, item = 2}
    w_item1:search("button").enable = false
    w_item2:search("button").enable = true
    w_item3:search("button").enable = false
  end
end
function on_mouse6(btn, msg)
  if ui.mouse_lbutton_click == msg then
    if sys.check(cur_select) then
      cur_select.visible = false
    end
    cur_select = btn:search("figure")
    btn:search("figure").visible = true
    cur_select_change = {index = 2, item = 3}
    w_item1:search("button").enable = false
    w_item2:search("button").enable = true
    w_item3:search("button").enable = false
  end
end
function on_mouse7(btn, msg)
  if ui.mouse_lbutton_click == msg then
    if sys.check(cur_select) then
      cur_select.visible = false
    end
    cur_select = btn:search("figure")
    btn:search("figure").visible = true
    cur_select_change = {index = 3, item = 1}
    w_item1:search("button").enable = false
    w_item2:search("button").enable = false
    w_item3:search("button").enable = true
  end
end
function on_mouse8(btn, msg)
  if ui.mouse_lbutton_click == msg then
    if sys.check(cur_select) then
      cur_select.visible = false
    end
    cur_select = btn:search("figure")
    btn:search("figure").visible = true
    cur_select_change = {index = 3, item = 2}
    w_item1:search("button").enable = false
    w_item2:search("button").enable = false
    w_item3:search("button").enable = true
  end
end
function on_mouse9(btn, msg)
  if ui.mouse_lbutton_click == msg then
    if sys.check(cur_select) then
      cur_select.visible = false
    end
    cur_select = btn:search("figure")
    btn:search("figure").visible = true
    cur_select_change = {index = 3, item = 3}
    w_item1:search("button").enable = false
    w_item2:search("button").enable = false
    w_item3:search("button").enable = true
  end
end
function on_action_move()
  update()
end
function on_window_visible(dlg)
  if dlg.visible == true then
    update()
  end
end
function insert_item(w, text, count, cur_count, id, color)
  local item = w:item_append()
  item:load_style("$frame/action/action.xml", "item")
  item:search("item_text").text = text
  item:search("item_count").text = sys.format("%d/%d", cur_count, count)
  item.name = "lb_count" .. id
  item:search("item_text").color = color
  item:search("item_count").color = color
  item.var:set("id", id)
end
function notice()
  local player = bo2.player
  if bo2.player == nil then
    return
  end
  local action = player:get_flag_int32(bo2.ePlayerFlagInt32_action)
  if action > 0 then
    return
  end
  local v = sys.variant()
  v:set(packet.key.ui_text_id, 10353)
  ui_chat.show_ui_text(nil, v)
end
function init_actions(obj)
  if obj == bo2.player then
    obj:insert_on_flagmsg(bo2.eFlagType_Int64, bo2.ePlayerFlagInt64_ActionFlag, update, "ui_action:on_action_flag64")
    obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_action, update, "ui_action:ePlayerFlagInt32_action")
    obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_active1, update, "ui_action:ePlayerFlagInt32_active1")
    obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_active2, update, "ui_action:ePlayerFlagInt32_active2")
    obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_active3, update, "ui_action:ePlayerFlagInt32_active3")
    obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_action, notice, "ui_action:ePlayerFlagInt32_action:notice")
    obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_action_yes, update, "ui_action:ePlayerFlagInt32_action_yes")
    obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_ClonedBattleYesterdayCount, update, "ui_action:ePlayerFlagInt8_ClonedBattleYesterdayCount")
    obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_KnightYesCount, update, "ui_action:ePlayerFlagInt8_KnightYesCount")
    obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_BattleYesCount, update, "ui_action:ePlayerFlagInt8_BattleYesCount")
    update()
  end
end
function on_btn_show_action_click(btn)
  w_action.visible = not w_action.visible
end
function on_action_item_tip(tip)
  local owner = tip.owner
  local stk = sys.mtf_stack()
  local id = owner.parent.var:get("id").v_int
  stk:raw_push(item_list[id].des)
  ui_tool.ctip_show(owner, stk)
end
function on_init(dlg)
  item_list = {}
  local mb = bo2.gv_active_list
  for i = 0, mb.size - 1 do
    item_list[mb:get(i).id] = {
      id = mb:get(i).id,
      count = mb:get(i).count,
      text = mb:get(i).text,
      item = nil,
      cur_count = 0,
      color = ui.make_color("ffffff"),
      des = mb:get(i).des
    }
  end
  local excel = bo2.gv_active_prize_list:find(1)
  w_prize1:search("lb_item").text = excel.text
  w_prize1:search("pic_grid").effect = "gray"
  w_prize1:search("active_prize").text = excel.active .. ui.get_text("action|active")
  w_prize1:search("active_count").text = excel.count
  excel = bo2.gv_active_prize_list:find(2)
  w_prize2:search("lb_item").text = excel.text
  w_prize2:search("pic_grid").effect = "gray"
  w_prize2:search("active_prize").text = excel.active .. ui.get_text("action|active")
  w_prize2:search("active_count").text = excel.count
  excel = bo2.gv_active_prize_list:find(3)
  w_prize3:search("lb_item").text = excel.text
  w_prize3:search("pic_grid").effect = "gray"
  w_prize3:search("active_prize").text = excel.active .. ui.get_text("action|active")
  w_prize3:search("active_count").text = excel.count
  excel = bo2.gv_active_prize_list:find(4)
  w_prize4:search("lb_item").text = excel.text
  w_prize4:search("pic_grid").effect = "gray"
  w_prize4:search("active_prize").text = excel.active .. ui.get_text("action|active")
  w_prize4:search("active_count").text = excel.count
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enter_scn, init_actions, "on_enter_scn:init_actions")
