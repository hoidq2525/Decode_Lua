Beckon_CD_Time = 600
local start_tick = 0
BtnTipText = nil
TimeTipText1 = nil
local TimeTipText
local CD_ID = 55011
function on_beckon_knpc_tip_make(tip)
  local Text = BtnTipText
  if g_tip_timer.suspended == false and TimeTipText ~= nil then
    local v = sys.variant()
    v:set("time", TimeTipText)
    Text = BtnTipText .. sys.mtf_merge(v, TimeTipText1)
  end
  ui_widget.tip_make_view(tip.view, Text)
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  if not excel then
    return
  end
  local stk = sys.mtf_stack()
  if excel ~= nil then
    ui_tool.ctip_make_item(stk, excel)
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("knight|rbtn_tip"), ui_tool.cs_tip_color_operation)
    ui_tool.ctip_show(card, stk, stk_use)
  end
end
function on_item_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    ui.clean_drop()
    if ui.is_key_down(ui.VK_CONTROL) then
      ui_chat.insert_item(card.excel_id, nil)
      return
    end
  elseif msg == ui.mouse_rbutton_click then
    local excel_id = card.excel_id
    if ui.item_get_count(excel_id, true) > 0 then
      local v = sys.variant()
      v:set(packet.key.item_excelid, excel_id)
      bo2.send_variant(packet.eCTS_UI_Beckon_KNpc, v)
    else
      local data = sys.variant()
      data[packet.key.ui_text_id] = 73133
      local v = sys.variant()
      v:set("itemid", excel_id)
      data[packet.key.ui_text_arg] = v
      ui_chat.show_ui_text(0, data)
    end
    g_mainpanel.visible = false
  end
end
function on_drop_item()
end
function on_beckon_knpc(btn)
  local remain_time = bo2.get_cooldown_remain_time(CD_ID)
  if remain_time > 0 then
    ui_chat.show_ui_text_id(73134)
    return
  end
  local scn_id = btn.svar.id
  if scn_id == nil then
    return
  end
  local scn_line = bo2.gv_scn_list:find(scn_id)
  if scn_line == nil then
    ui.log("beckon_knpc_scn excel id is error!!")
    return
  end
  local items = scn_line.beckon_knpc_items
  local size = items.size
  local card_table = btn.svar.card_table
  local cur_index = 1
  for i = 0, size - 1 do
    local itemid = items[i]
    card_table[cur_index].excel_id = items[i]
    cur_index = cur_index + 1
  end
  g_mainpanel.visible = true
end
function on_init()
  local card_table = {}
  local ctop = g_mainpanel:search("ctop1")
  for r = 0, 1 do
    for i = 0, 3 do
      local childctrl = ui.create_control(ctop, "panel")
      childctrl:load_style("$frame/knight/beckon_k_npc.xml", "item_cell")
      childctrl.offset = ui.point(i * 36, r * 36)
      local card = childctrl:search("card")
      table.insert(card_table, card)
    end
  end
  w_beckon_knpc_btn.svar = {}
  w_beckon_knpc_btn.svar.card_table = card_table
end
function on_tip_timer(timer)
  local remain_time = bo2.get_cooldown_remain_time(CD_ID)
  remain_time = math.floor(remain_time / 1000)
  TimeTipText = ui_tool.ctip_time_text(remain_time)
  if remain_time <= 0 then
    g_tip_timer.suspended = true
    w_beckon_knpc_main.enable = true
    TimeTipText = nil
    ui_widget.tip_make_view(w_beckon_knpc_btn.tip.view, BtnTipText)
  end
end
function backon_set_timer_on(data)
  g_tip_timer.suspended = false
end
function main_on_vis(main, vis)
  if vis == false then
  end
end
