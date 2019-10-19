function on_init()
end
function do_refine(type)
  local v = sys.variant()
  v:set(packet.key.cmn_id, type)
  v:set(packet.key.cmn_money, 0)
  bo2.send_variant(packet.eCTS_UI_Imprint, v)
end
function do_add_time_refine(type)
  local v = sys.variant()
  v:set(packet.key.cmn_id, type)
  v:set(packet.key.cmn_money, 1)
  bo2.send_variant(packet.eCTS_UI_Imprint, v)
end
function on_visible(w, vis)
  if vis then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_UI_ImprintTimes, v)
    ui_widget.esc_stk_push(w)
  else
    ui_widget.esc_stk_pop(w)
  end
end
function on_primary_btn(btn)
  local cur_times = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_PrimerImprinted)
  local n = bo2.gv_item_imprint:find(1)
  if n == nil then
    return
  end
  local on_msg_confirm = function(data)
    if data.result == 1 then
      do_add_time_refine(1)
    end
  end
  if cur_times < n.daily_times then
    do_refine(1)
  else
    local add_times = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_PrimerImprinted)
    local left_times = n.add_times - add_times
    local currency = n.add_money[0]
    local money = n.add_money[1]
    local stk = sys.stack()
    local msg_text = ui.get_text("item|primary_msg_1")
    stk:push(sys.format(msg_text, money, left_times))
    if left_times <= 0 then
      local d = {
        text = ui.get_text("item|primary_msg_2")
      }
      ui_widget.ui_msg_box.show_common(d)
    else
      local data = {
        text = stk.text,
        callback = on_msg_confirm
      }
      ui_widget.ui_msg_box.show_common(data)
    end
  end
end
function on_senior_btn(btn)
  local cur_times = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_SeniorImprinted)
  local n = bo2.gv_item_imprint:find(2)
  if n == nil then
    return
  end
  local on_msg_confirm = function(data)
    if data.result == 1 then
      do_add_time_refine(2)
    end
  end
  if cur_times < n.daily_times then
    do_refine(2)
  else
    local add_times = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_SeniorImprint)
    local left_times = n.add_times - add_times
    local currency = n.add_money[0]
    local money = n.add_money[1]
    local stk = sys.stack()
    local msg_text = ui.get_text("item|senior_msg_1")
    stk:push(sys.format(msg_text, money, left_times))
    if left_times <= 0 then
      local d = {
        text = ui.get_text("item|senior_msg_2")
      }
      ui_widget.ui_msg_box.show_common(d)
    else
      local data = {
        text = stk.text,
        callback = on_msg_confirm
      }
      ui_widget.ui_msg_box.show_common(data)
    end
  end
end
function show_imprint(cmd, data)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_item.ui_imprint:on_signal"
reg(packet.eSTC_UI_ShowImprint, show_imprint, sig)
