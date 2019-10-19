function on_xinshou_init()
  w_xinshouaward_time.visible = true
  w_xinshouaward_time.left_time = 0
end
function on_self_enter()
end
function on_visible(ctrl, vis)
  if vis then
    local cur_index = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouOLAwardIndex)
    if cur_index >= bo2.gv_xinshou_olaward.size then
      xinshou_xindow.visible = false
    end
  end
end
function on_has_xinshou_olaward(cmd, data)
  xinshou_window.visible = true
  w_award_flicker.visible = true
  w_award_flicker.suspended = false
  w_xinshouaward_time.left_time = 0
  w_xinshouaward_time.visible = false
  w_text_canget.visible = true
end
function on_xinshou_olaward_start(cmd, data)
  xinshou_window.visible = true
  w_award_flicker.visible = false
  w_award_flicker.suspended = true
  w_xinshouaward_time.left_time = 0
  local time = data:get(packet.key.cmn_id).v_int
  w_xinshouaward_time.left_time = time
  w_xinshouaward_time.visible = true
  w_text_canget.visible = false
end
function on_btn_award_mouse(btn, msg)
  local parent = btn.parent
  local card = parent:search("card")
  if card == nil then
    return
  end
  local cur_index = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouOLAwardIndex)
  local cur_excel = bo2.gv_xinshou_olaward:find(cur_index + 1)
  if cur_excel == nil then
    return
  end
  card.excel_id = cur_excel.item
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item(stk, excel, card.info, card)
  local stk_use
  local info = card.info
  if card.box == bo2.eItemBox_OtherSlot then
    stk_use = ui_item.tip_get_using_equip(excel)
  else
  end
  local tip_text = ui.get_text("timeaward|lclick_to_get")
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, tip_text, ui_tool.cs_tip_color_operation)
  if msg == ui.mouse_enter or msg == ui.mouse_inner then
    ui_tool.ctip_show(card, stk)
  elseif msg == ui.mouse_leave or msg == ui.mouse_outer then
    ui_tool.ctip_show(card, nil)
  end
end
function on_btn_get_award()
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_GetXinshouOLAward, v)
end
function on_get_olaward_success(cmd, data)
  w_award_flicker.visible = false
  w_award_flicker.suspended = true
end
function on_xinshou_olaward_finish(cmd, data)
  xinshou_window.visible = false
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_timeaward.ui_xinshou_award.on_self_enter")
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_timeaward1.packet_handle"
reg(packet.eSTC_UI_XinshouOLAwardStart, on_xinshou_olaward_start, sig)
reg(packet.eSTC_UI_XinshouOLAwardOver, on_has_xinshou_olaward, sig)
reg(packet.eSTC_UI_XinshouOLGetOLAward, on_get_olaward_success, sig)
reg(packet.eSTC_UI_XinshouOLAwardFinish, on_xinshou_olaward_finish, sig)
