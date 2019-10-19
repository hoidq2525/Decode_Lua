function get_can_exchange()
  local player = bo2.player
  if player == nil then
    return 0
  end
  local line = bo2.gv_errantry_exchange:find(player:get_atb(bo2.eAtb_Level))
  if line == nil then
    return 0
  end
  local max = player:get_flag_int32(bo2.ePlayerFlagInt32_Errantry2ExpMax)
  local cur = player:get_flag_int32(bo2.ePlayerFlagInt32_Errantry)
  max = line.max - max
  if cur < 10 or max == 0 then
    return 0
  else
    local num_cur = math.floor(cur / 10)
    local num_max = math.floor(max / 10)
    local num = num_cur
    if num_cur > num_max then
      num = num_max
    end
    return num * 10
  end
end
function send_to_server(send_type)
  local count = tonumber(tostring(w_input.text))
  local v = sys.variant()
  v:set(packet.key.cmn_type, send_type)
  v:set(packet.key.cmn_dataobj, count)
  bo2.send_variant(packet.eCTS_UI_ErrantryExchange, v)
end
function on_exchange_exp()
  local num = tonumber(tostring(w_input.text))
  local can_num = get_can_exchange()
  if num > can_num then
    num = can_num
  end
  local count = math.floor(num / 10)
  num = count * 10
  w_input.text = num
  if num < 10 then
    return
  end
  local line = bo2.gv_errantry_exchange:find(bo2.player:get_atb(bo2.eAtb_Level))
  local text_name = "errantry|makesure_exp2"
  local arg = sys.variant()
  arg:set("count", num)
  arg:set("exp", line.exp * count)
  if line.moneytype ~= 0 then
    text_name = "errantry|makesure_exp" .. line.moneytype
    arg:set("money", line.money * num)
  end
  local msg = {
    text = sys.mtf_merge(arg, ui.get_text(text_name)),
    modal = true,
    btn_confirm = 1,
    btn_cancel = 1,
    callback = function(data)
      if data.result == 1 then
        send_to_server(1)
      end
    end
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_exchange_money()
  local num = tonumber(tostring(w_input.text))
  local can_num = get_can_exchange()
  if num > can_num then
    num = can_num
  end
  local count = math.floor(num / 10)
  num = count * 10
  w_input.text = num
  if num < 10 then
    return
  end
  local line = bo2.gv_errantry_exchange:find(bo2.player:get_atb(bo2.eAtb_Level))
  local text_name = "errantry|makesure_money"
  local arg = sys.variant()
  arg:set("count", num)
  arg:set("money", line.formoney * count)
  local msg = {
    text = sys.mtf_merge(arg, ui.get_text(text_name)),
    modal = true,
    btn_confirm = 1,
    btn_cancel = 1,
    callback = function(data)
      if data.result == 1 then
        send_to_server(2)
      end
    end
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_min_click()
  local can_exchange = get_can_exchange()
  if can_exchange > 0 then
    w_input.text = 10
  else
    w_input.text = 0
  end
  local num = tonumber(tostring(w_input.text))
  if num < 10 then
    w_btn_exp.enable = false
    w_btn_money.enable = false
  else
    w_btn_exp.enable = true
    w_btn_money.enable = true
  end
end
function on_max_click()
  local can_exchange = get_can_exchange()
  if can_exchange > 0 then
    w_input.text = can_exchange
  else
    w_input.text = 0
  end
  local num = tonumber(tostring(w_input.text))
  if num < 10 then
    w_btn_exp.enable = false
    w_btn_money.enable = false
  else
    w_btn_exp.enable = true
    w_btn_money.enable = true
  end
end
function on_num_check(tb, txt)
  local num = tonumber(tostring(w_input.text))
  local can_num = get_can_exchange()
  if num > can_num then
    num = can_num
  end
  if num < 10 then
    w_btn_exp.enable = false
    w_btn_money.enable = false
  else
    w_btn_exp.enable = true
    w_btn_money.enable = true
  end
  w_input.text = num
end
function on_max_chg()
  local line = bo2.gv_errantry_exchange:find(bo2.player:get_atb(bo2.eAtb_Level))
  if line == nil then
    return
  end
  local max = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Errantry2ExpMax)
  max = line.max - max
  local arg = sys.variant()
  arg:set(L("count"), max)
  exchange_text.text = sys.mtf_merge(arg, ui.get_text("errantry|tip2"))
  w_input.text = 0
  w_btn_exp.enable = false
  w_btn_money.enable = false
end
function on_errantry_chg()
  local cur_count = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Errantry)
  local arg = sys.variant()
  arg:set(L("count"), cur_count)
  r_box.mtf = sys.mtf_merge(arg, ui.get_text("errantry|tip1"))
end
function on_exchange_visible(panel, vis)
  local player = bo2.player
  if bo2.player == nil then
    return
  end
  local max = player:get_flag_int32(bo2.ePlayerFlagInt32_Errantry2ExpMax)
  local cur_count = player:get_flag_int32(bo2.ePlayerFlagInt32_Errantry)
  local line = bo2.gv_errantry_exchange:find(bo2.player:get_atb(bo2.eAtb_Level))
  if line == nil then
    return
  end
  if vis == false then
    player:remove_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_Errantry2ExpMax, "ui_errantry:on_max_chg")
    player:remove_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_Errantry, "ui_errantry:on_errantry_chg")
    return
  end
  player:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_Errantry, on_errantry_chg, "ui_errantry:on_errantry_chg")
  player:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_Errantry2ExpMax, on_max_chg, "ui_errantry:on_max_chg")
  local arg = sys.variant()
  arg:set(L("count"), cur_count)
  r_box.mtf = sys.mtf_merge(arg, ui.get_text("errantry|tip1"))
  max = line.max - max
  arg:set(L("count"), max)
  exchange_text.text = sys.mtf_merge(arg, ui.get_text("errantry|tip2"))
  local can_exchange = get_can_exchange()
  if can_exchange == 0 then
    w_input.text = 0
    w_btn_exp.enable = false
    w_btn_money.enable = false
  else
    w_input.text = can_exchange
    w_btn_exp.enable = true
    w_btn_money.enable = true
  end
end
