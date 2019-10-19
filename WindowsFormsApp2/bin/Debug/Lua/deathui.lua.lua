inviteID = nil
local deathtext
deathCD = nil
local is_use_relive_scn = false
local is_use_relive_prison = false
function get_visible()
  local w = ui.find_control("$frame:deathui")
  return w.visible
end
function set_visible(vis)
  local w = ui.find_control("$frame:deathui")
  w.visible = vis
end
function getInviteID(data)
  inviteID = data:get(packet.key.ui_invite_id).v_int
  deathtext = data:get(packet.key.ui_text)
  is_use_relive_scn = data:has(packet.key.ui_death_relive_scn)
  is_use_relive_prison = data:has(packet.key.ui_death_send_to_jail)
  if is_use_relive_prison == true then
    g_remain_text.text = ui.get_text("common|remain_time_relive_prison")
  elseif is_use_relive_scn == true then
    g_remain_text.text = ui.get_text("common|remain_time_relive_scn")
  else
    g_remain_text.text = ui.get_text("common|remain_time")
  end
  deathchoice.mtf = deathtext
  local is_currelive = data:get(packet.key.ui_death_cur_enable)
  if is_currelive ~= nil and is_currelive.v_int == 0 then
    g_curplace_btn.enable = false
  elseif item_ishave == 0 then
    g_curplace_btn.enable = false
  else
    deathCD = data:get(packet.key.ui_deathCD)
    if deathCD ~= nil and deathCD.v_int ~= 0 then
      deathCD = deathCD.v_int
      local text = ui.get_text("common|relive_curplace") .. "(" .. deathCD .. ui.get_text("common|remain_second") .. ")"
      g_curplace_btn.text = text
      g_curplace_btn.enable = false
    end
  end
end
function set_ui_visible(isvisible)
  set_visible(isvisible)
  if msg_box_bg == nil or msg_box_window == nil then
    return
  end
  if msg_box_bg.visible == true or msg_box_window.visible == true then
    msg_box_bg.visible = isvisible
    msg_box_window.visible = isvisible
  end
end
function on_timer()
  timer_countdown = timer_countdown - 1
  countdown.text = timer_countdown
  if timer_countdown <= 0 then
    g_timer.suspended = true
    local v = sys.variant()
    v:set(packet.key.ui_invite_id, inviteID)
    v:set(packet.key.cmn_agree_ack, 0)
    bo2.send_variant(packet.eCTS_UI_CommonInviteAck, v)
    set_ui_visible(false)
  end
end
local text1 = ui.get_text("common|relive_curplace")
local text2 = ui.get_text("common|remain_second")
function on_timerCD()
  local text = text1 .. "(" .. deathCD .. text2 .. ")"
  g_curplace_btn.text = text
  if deathCD <= 0 then
    g_timerCD.suspended = true
    g_curplace_btn.enable = true
    g_curplace_btn.text = text1
    if g_relive_item.visible == true then
      g_click_buy_item.enable = true
      g_curplace_btn.enable = false
    end
  end
  deathCD = deathCD - 1
end
function on_click_curplace(ctrl)
  g_timer.suspended = true
  local v = sys.variant()
  v:set(packet.key.ui_invite_id, inviteID)
  v:set(packet.key.cmn_agree_ack, 1)
  bo2.send_variant(packet.eCTS_UI_CommonInviteAck, v)
  set_ui_visible(false)
end
function on_click_othplace(ctrl)
  g_timer.suspended = true
  local v = sys.variant()
  v:set(packet.key.ui_invite_id, inviteID)
  v:set(packet.key.cmn_agree_ack, 0)
  bo2.send_variant(packet.eCTS_UI_CommonInviteAck, v)
  set_ui_visible(false)
end
function on_mouse_item(btn, msg)
  if msg == ui.mouse_enter then
    btn.parent:search("highlight").visible = true
    btn.parent:search("encircle").visible = false
  end
  if msg == ui.mouse_leave then
    btn.parent:search("highlight").visible = false
    btn.parent:search("encircle").visible = true
  end
  if msg == ui.mouse_lbutton_click then
    on_click_buy_item(btn)
  end
end
function search_item_by_excelid(id)
end
function on_make_tip(tip)
  local btn = tip.owner
  if btn == nil then
    return
  end
  local var = sys.variant()
  local choice = btn.svar.id
  if choice == 1 then
    var:set("choice", ui.get_text("common|relive_new_cur_1"))
  elseif choice == 2 then
    var:set("choice", ui.get_text("common|relive_new_cur_2"))
  end
  var:set("num", btn.svar.relive_num)
  local text = sys.mtf_merge(var, ui.get_text("common|btn_tip_fee"))
  if btn.svar.relive_num >= 11 then
    text = sys.mtf_merge(var, ui.get_text("common|btn_tip_fee_new"))
  end
  ui_widget.tip_make_view(tip.view, text)
end
function on_reset_make_tip(tip)
  local btn = tip.owner
  if btn == nil then
    return
  end
  local var = sys.variant()
  var:set("text", g_othplace_btn.text)
  local text = sys.mtf_merge(var, ui.get_text("common|btn_tip_reset"))
  ui_widget.tip_make_view(tip.view, text)
end
function check_is_bound(info)
  if info:get_data_8(bo2.eItemByte_Bound) == 1 then
    return true
  end
  return false
end
function on_relive_item_vis(btn, vis)
  if vis == false then
    return
  end
  local rate_need = btn.svar.rate
  local money_need = btn.svar.money
  local count_need = btn.svar.count
  local total_count = 0
  local tb_rank = {}
  local size = bo2.gv_relive_value.size
  for i = size - 1, 0, -1 do
    local line = bo2.gv_relive_value:get(i)
    local id = line.itemID
    local rate = line.datas_rate
    if rate == rate_need then
      local count2 = ui.item_get_count(id, true)
      if count2 > 0 then
        local tb = {}
        tb.excelid = id
        tb.count = count2
        local info = ui.item_of_excel_id(id)
        tb.bound = check_is_bound(info)
        table.insert(tb_rank, tb)
        total_count = total_count + count2
      end
    end
  end
  btn.svar.rank_tb = tb_rank
  local money_total = 0
  if total_count == 0 then
    money_total = count_need * money_need
    local rmb = ui_supermarket2.g_rmb
    if money_total > rmb then
      btn.enable = false
    end
  elseif total_count > 0 and count_need > total_count then
    money_total = (count_need - total_count) * money_need
    local rmb = ui_supermarket2.g_rmb
    if money_total > rmb then
      btn.enable = false
    end
  end
  return btn.enable
end
function set_stop_action()
  bo2.player:SetNoMove(bo2.eStopType_Dead, false)
end
function on_click_buy_item(btn)
  local rate_need = btn.svar.rate
  local money_need = btn.svar.money
  local count_need = btn.svar.count
  local type = btn.svar.id
  local rank_tb = btn.svar.rank_tb
  for i, v in pairs(rank_tb) do
    for j, k in pairs(rank_tb) do
      if rank_tb[j].bound == false and rank_tb[j + 1] ~= nil and rank_tb[j + 1].bound == true then
        local tmp = {}
        tmp.excelid = rank_tb[j + 1].excelid
        tmp.count = rank_tb[j + 1].count
        tmp.bound = rank_tb[j + 1].bound
        rank_tb[j + 1].excelid = rank_tb[j].excelid
        rank_tb[j + 1].count = rank_tb[j].count
        rank_tb[j + 1].bound = rank_tb[j].bound
        rank_tb[j].excelid = tmp.excelid
        rank_tb[j].count = tmp.count
        rank_tb[j].bound = tmp.bound
      end
    end
  end
  local total_count = 0
  local tb_rank_end = {}
  for i, v in pairs(rank_tb) do
    tb_rank_end[i] = {}
    tb_rank_end[i].excelid = v.excelid
    tb_rank_end[i].count = v.count
    tb_rank_end[i].bound = v.bound
    total_count = total_count + v.count
    if count_need <= total_count then
      tb_rank_end[i].count = tb_rank_end[i].count - (total_count - count_need)
      break
    end
  end
  local text_conform = L("")
  local impl_var = sys.variant()
  local v = sys.variant()
  if total_count == 0 then
    v:set("money", count_need * money_need)
    if type == 1 then
      text_conform = sys.mtf_merge(v, ui.get_text("common|relive_new_money"))
    else
      text_conform = sys.mtf_merge(v, ui.get_text("common|relive_new_money_2"))
    end
    impl_var:set(packet.key.cmn_money, count_need * money_need)
  elseif total_count > 0 then
    local text_new = L("")
    local v_all = sys.variant()
    for i, v in pairs(tb_rank_end) do
      local tmpv = sys.variant()
      text_new = text_new .. sys.format("<i:%d> x %d,", v.excelid, v.count)
      tmpv:set(packet.key.ui_death_relive_item, v.excelid)
      tmpv:set(packet.key.item_count, v.count)
      v_all:push_back(tmpv)
    end
    impl_var:set(packet.key.multi_item, v_all)
    if count_need > total_count then
      v:set("money", (count_need - total_count) * money_need)
      text_new = text_new .. sys.mtf_merge(v, ui.get_text("common|relive_new_money_more"))
      impl_var:set(packet.key.cmn_money, (count_need - total_count) * money_need)
    end
    local var = sys.variant()
    local choice = btn.svar.id
    if choice == 1 then
      var:set("choice", ui.get_text("common|relive_new_cur_1"))
    elseif choice == 2 then
      var:set("choice", ui.get_text("common|relive_new_cur_2"))
    end
    var:set("num", btn.svar.relive_num)
    var:set("text", text_new)
    if btn.svar.relive_num >= 11 then
      text_conform = sys.mtf_merge(var, ui.get_text("common|relive_new_new_item"))
    else
      text_conform = sys.mtf_merge(var, ui.get_text("common|relive_new_item"))
    end
  end
  local function send_impl()
    impl_var:set(packet.key.ui_invite_id, inviteID)
    impl_var:set(packet.key.cmn_id, btn.svar.id)
    impl_var:set(packet.key.cmn_agree_ack, 1)
    bo2.send_variant(packet.eCTS_UI_CommonInviteAck, impl_var)
    set_ui_visible(false)
  end
  ui_widget.ui_msg_box.show_common({
    style_uri = L("$widget/msg_box.xml"),
    style_name = L("cmn_msg_box_common"),
    btn2 = true,
    text = text_conform,
    modal = true,
    close_on_leavascn = true,
    init = function(data)
      local w = data.window
      w.dock = g_death.dock
      w.margin = ui.rect(g_death.margin.x1, g_death.margin.y1, g_death.margin.x2, g_death.margin.y2)
      g_death.svar.msg_box = w
    end,
    callback = function(ret)
      local window = ret.window
      if ret.result == 1 then
        send_impl(window, 1)
      elseif ret.result == 0 then
      end
    end
  })
end
function on_click_relive_scn(ctrl)
  g_timer.suspended = true
  local v = sys.variant()
  v:set(packet.key.ui_invite_id, inviteID)
  v:set(packet.key.cmn_agree_ack, 2)
  bo2.send_variant(packet.eCTS_UI_CommonInviteAck, v)
  set_ui_visible(false)
end
function on_click_to_jail(ctrl)
  g_timer.suspended = true
  local v = sys.variant()
  v:set(packet.key.ui_invite_id, inviteID)
  v:set(packet.key.cmn_agree_ack, 3)
  bo2.send_variant(packet.eCTS_UI_CommonInviteAck, v)
  set_ui_visible(false)
end
function main_on_visible(panel, bool)
  if bool == false then
    g_timer.suspended = true
    local msg_box = panel.svar.msg_box
    if msg_box ~= nil then
      msg_box.visible = false
    end
    bo2.player:SetNoMove(bo2.eStopType_Dead, false)
  else
    panel.svar.msg_box = nil
  end
end
function on_close_click(ctrl)
  if is_use_relive_prison == true then
    on_click_to_jail(ctrl)
  elseif is_use_relive_scn == true then
    on_click_relive_scn(ctrl)
  else
    on_click_othplace(ctrl)
  end
end
