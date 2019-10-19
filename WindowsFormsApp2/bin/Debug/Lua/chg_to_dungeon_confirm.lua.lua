function get_payment_text_by_payid(scn_payid, payflag)
  local payexcel = bo2.gv_payment_in_scn:find(scn_payid)
  if payexcel == nil then
    return
  end
  local payment_text = ""
  local payment_addtext = ""
  local money_text = ""
  local exp_text = ""
  local rep_text = ""
  local item_text = ""
  local pay_money = payexcel.pay_money
  if pay_money == 1 then
    local money_type = payexcel.money_type
    local money_num = payexcel.money_num
    if money_num > 0 then
      if money_type == 1 then
        money_text = sys.format("<bm:%d>", money_num) .. ","
      elseif money_type == 2 then
        money_text = sys.format("<m:%d>", money_num) .. ","
      end
    end
  end
  local pay_exp = payexcel.pay_exp
  if pay_exp == 1 then
    local exp_num = payexcel.exp_num
    if exp_num > 0 then
      local text_par = sys.variant()
      text_par:set("exp_num", exp_num)
      exp_text = sys.mtf_merge(text_par, ui.get_text("dungeonui|payment_exp")) .. ","
    end
  end
  local pay_rep = payexcel.pay_reputation
  if pay_rep == 1 then
    local rep_id = payexcel.reputation_id
    local rep_num = payexcel.reputation_num
    if rep_num > 0 then
      local repexcel = bo2.gv_repute_list:find(rep_id)
      if repexcel ~= nil then
        local repname = repexcel.name
        local text_par = sys.variant()
        text_par:set("rep", repname)
        text_par:set("num", rep_num)
        rep_text = sys.mtf_merge(text_par, ui.get_text("dungeonui|payment_rep")) .. ","
      end
    end
  end
  local pay_item = payexcel.pay_item
  if pay_item == 1 then
    local item_ids = payexcel.item_type
    local item_nums = payexcel.item_num
    local idsize = item_ids.size
    if idsize == item_nums.size and idsize > 0 then
      for i = 0, idsize - 1 do
        local item_id = item_ids[i]
        local item_num = item_nums[i]
        item_text = item_text .. sys.format("<i:%d> x %d", item_id, item_num)
      end
    end
  end
  payment_text = money_text .. exp_text .. rep_text .. item_text
  local pay_by_who = ""
  if pay_item == 1 or pay_exp == 1 or pay_rep == 1 or pay_item == 1 then
    if payexcel.pay_by == 0 then
      pay_by_who = ui.get_text("dungeonui|pay_captain")
    else
      pay_by_who = ui.get_text("dungeonui|pay_everyone")
    end
    if payflag == 1 then
      pay_by_who = ""
    end
    local text2 = ui.get_text("dungeonui|payment_chg_scn_in")
    local par = sys.variant()
    par:set("pay_text", payment_text)
    par:set("payname", pay_by_who)
    payment_text = sys.mtf_merge(par, text2)
  end
  if payexcel.pay_text ~= L("") then
    payment_addtext = payexcel.pay_text
  end
  return payment_text, payment_addtext
end
function get_payment_text(scn_id)
  local scn_info = bo2.gv_scn_list:find(scn_id)
  local scn_name = scn_info.name
  local scn_payid = scn_info.pay_in_scn
  if scn_payid == 0 then
    return
  end
  return get_payment_text_by_payid(scn_payid)
end
function ui_for_fuben(scn_info, data)
  local rich_box = w_main:search("tip_text")
  local btn_ok = w_main:search("btn_ok")
  local btn_cancil = w_main:search("btn_cancil")
  local btn_know = w_main:search("btn_know")
  local scn_name = scn_info.name
  local minlevel = data:get(packet.key.cha_min_level).v_int
  local maxlevel = data:get(packet.key.cha_max_level).v_int
  local text = ui_dungeonui.ui_dungeonsel.set_level_text(minlevel, maxlevel)
  local text2 = bo2.gv_text:find(73221).text
  local v = sys.variant()
  v:set("level", text)
  local temp_text = ui.get_text("dungeonui|confirm_to_dungeon")
  local text_par = sys.variant()
  text_par:set("scn", scn_name)
  local tip_text = sys.mtf_merge(v, text2) .. sys.mtf_merge(text_par, temp_text)
  rich_box.mtf = tip_text
  w_title.text = ui.get_text("dungeonui|chg_title")
  btn_ok.visible = true
  btn_cancil.visible = true
  btn_know.visible = false
end
function ui_for_moyu(scn_info)
  local rich_box = w_main:search("tip_text")
  local btn_ok = w_main:search("btn_ok")
  local btn_cancil = w_main:search("btn_cancil")
  local btn_know = w_main:search("btn_know")
  local scn_name = scn_info.name
  local scn_payid = scn_info.pay_in_scn
  w_title.text = ui.get_text("dungeonui|payment_title")
  local pay_text, pay_addtext = get_payment_text_by_payid(scn_payid)
  local line = bo2.gv_payment_in_scn:find(scn_payid)
  if line == nil then
    return
  end
  local text2 = ui.get_text("dungeonui|payment_chg_scn")
  local par = sys.variant()
  par:set("scn", scn_name)
  par:set("num", line.min_num)
  local payment_text = sys.mtf_merge(par, text2) .. pay_text .. "\n" .. pay_addtext
  local obj = bo2.player
  if obj == nil then
    return
  end
  rich_box.mtf = payment_text .. tip_text
  btn_ok.visible = true
  btn_cancil.visible = true
  btn_know.visible = false
end
local on_msg = function(leave_msg)
  if leave_msg.result == 0 then
    return
  end
  local var = sys.variant()
  var:set(packet.key.ui_area_chgscn_ack, 1)
  bo2.send_variant(packet.eSTC_UI_AreaChgScnAck, var)
end
function ui_for_leave()
  leave_msg = {
    callback = on_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = false,
    close_on_leavascn = true
  }
  leave_msg.text = ui.get_text("common|leave_scn")
  ui_widget.ui_msg_box.show_common(leave_msg)
end
function handle_area_chg_to_dungeon(cmd, data)
  local visible = data:get(packet.key.ui_area_chgscn_visible).v_int
  if visible == 1 then
    local scn_id = data:get(packet.key.scn_excel_id).v_int
    local area_id = data:get(packet.key.cha_area).v_int
    local area_info = bo2.gv_area_list:find(area_id)
    if area_info == nil then
      return
    end
    local scn_info
    if scn_id ~= -1 then
      scn_info = bo2.gv_scn_list:find(scn_id)
      if scn_info == nil then
        return
      end
    end
    local uitype = area_info.trans_uitype
    if uitype == bo2.eAreaChgUIType_MoYu then
      ui_for_moyu(scn_info)
      w_main.visible = true
    elseif uitype == bo2.eAreaChgUIType_FuBen then
      ui_for_fuben(scn_info, data)
      w_main.visible = true
    elseif uitype == bo2.eAreaChgUIType_Leave then
      ui_for_leave()
    end
  else
    w_main.visible = false
    if leave_msg ~= nil then
      leave_msg.result = 0
      ui_widget.ui_msg_box.invoke(leave_msg)
    end
  end
end
function on_ok(btn)
  local var = sys.variant()
  var:set(packet.key.ui_area_chgscn_ack, 1)
  bo2.send_variant(packet.eSTC_UI_AreaChgScnAck, var)
  w_main.visible = false
end
function on_cancel(btn)
  local var = sys.variant()
  var:set(packet.key.ui_area_chgscn_ack, 0)
  bo2.send_variant(packet.eSTC_UI_AreaChgScnAck, var)
  w_main.visible = false
end
