local g_Select
function build_ride_list()
  local ride_list = {}
  local cnt = 0
  local cnt_max = w_ride_list.control_size
  for i = 0, 11 do
    local ride_info = ui.find_ride_info(bo2.eRidePetBox_Slot, i)
    if ride_info ~= nil and ride_info:get_flag(bo2.eRidePetFlagInt32_Blood) == 0 then
      ride_list[cnt] = ride_info:get_flag(bo2.eRidePetFlagInt32_Pos)
      cnt = cnt + 1
      if cnt_max <= cnt then
        break
      end
    end
  end
  for i = 0, cnt_max - 1 do
    local ctr = w_ride_list:control_get(i)
    if ctr ~= nil then
      local card = ctr:search("ride_pet")
      local select = ctr:search("select")
      if card ~= nil then
        if i < cnt then
          card.grid = ride_list[i]
          if select ~= nil then
            if g_Select == i then
              select.visible = true
              w_btn_identify.enable = true
            else
              select.visible = false
            end
          end
        else
          card.grid = -1
          if select ~= nil then
            select.visible = false
          end
        end
      end
    end
  end
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis == true then
    w_btn_identify.enable = false
    g_Select = 0
    build_ride_list()
    local item_id = bo2.gv_define:find(742).value.v_int
    local item_count = bo2.gv_define:find(743).value.v_int
    local money = bo2.gv_define:find(744).value.v_int
    local item = bo2.gv_item_list:find(item_id)
    if item ~= nil then
      w_good.text = sys.format("[%s]\161\193%d", item.name, item_count)
    else
      w_good.text = ui.get_text("npcfunc|id_ride_none")
    end
    ui_npcfunc.ui_cmn.money_set(w_money, money)
  end
end
function on_card_tip_show(tip)
  local card = tip.owner
  local stk = sys.mtf_stack()
  local item_id = bo2.gv_define:find(742).value.v_int
  local excel = bo2.gv_item_list:find(item_id)
  if excel == nil then
    return
  end
  ui_tool.ctip_make_item(stk, excel)
  ui_tool.ctip_show(card, stk)
end
function on_ride_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_mbutton_click then
    ui_ridepet.ridepet_msgbox(card.info)
    return
  elseif msg == ui.mouse_lbutton_click then
    if card.grid == -1 then
      return
    end
    for i = 0, w_ride_list.control_size - 1 do
      local ctr = w_ride_list:control_get(i)
      if ctr ~= nil then
        local c = ctr:search("ride_pet")
        if c ~= nil and c == card then
          g_Select = i
          build_ride_list()
          return
        end
      end
    end
  end
end
function on_identify_click()
  if g_Select >= w_ride_list.control_size then
    return
  end
  local ctr = w_ride_list:control_get(g_Select)
  if ctr == nil then
    return
  end
  local card = ctr:search("ride_pet")
  local info = card.info
  if info == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_IdentifyRide)
  v:set64(packet.key.item_key, info.onlyid)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function on_updata_ui()
  if w_main.visible == false then
    return
  end
  w_btn_identify.enable = false
  g_Select = 0
  build_ride_list()
end
function on_updata_type()
  if w_main.visible == false then
    return
  end
  on_updata_ui()
  local w = ui.find_control("$frame:personal")
  if w ~= nil then
    w.visible = true
    ui_widget.ui_tab.show_page(w, "ridepet", true)
  end
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetAdd, on_updata_ui, "ui_npcfunc.ui_identify_ride.on_updata_ui")
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetDel, on_updata_ui, "ui_npcfunc.ui_identify_ride.on_updata_ui")
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetIdentify, on_updata_ui, "ui_npcfunc.ui_identify_ride.on_updata_ui")
function on_init(ctrl)
end
