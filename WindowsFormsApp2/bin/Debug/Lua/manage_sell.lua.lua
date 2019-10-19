local ui_tab = ui_widget.ui_tab
function on_init(ctrl)
  ui_tab.clear_tab_data(w_main)
  insert_tab("sell_box1")
  insert_tab("sell_box2")
  insert_tab("sell_box3")
  insert_pettab()
  insert_tab("sell_jade_box")
  ui_tab.show_page(w_main, "sell_box1", true)
  init_sell_box("sell_box1", bo2.eItemBox_Mall_Sell1)
  init_sell_box("sell_box2", bo2.eItemBox_Mall_Sell2)
  init_sell_box("sell_box3", bo2.eItemBox_Mall_Sell3)
  init_sell_box("sell_jade_box", bo2.eItemBox_Mall_SellJade)
  g_total_val.money = 0
end
function insert_tab(name)
  local btn_uri = "$frame/mall/common.xml"
  local btn_sty = "mini_tab_btn"
  local page_uri = "$frame/mall/common.xml"
  local page_sty = name
  ui_tab.insert_suit(w_main, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_main, name)
  btn.text = ui.get_text("mall|" .. name)
  btn.dx = 113
end
function insert_pettab()
  local name = "sell_pet_box"
  local btn_uri = "$frame/mall/common.xml"
  local btn_sty = "mini_tab_btn"
  local page_uri = "$frame/mall/manage_sell.xml"
  local page_sty = name
  ui_tab.insert_suit(w_main, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_main, name)
  btn.text = ui.get_text("mall|" .. name)
  btn.dx = 113
end
function on_pet_select(ctrl, v)
  ctrl:search("select").visible = v
  g_downpet.enable = v
end
function clear_data()
  ui.item_box_clear(bo2.eItemBox_Mall_Sell1)
  ui.item_box_clear(bo2.eItemBox_Mall_Sell2)
  ui.item_box_clear(bo2.eItemBox_Mall_Sell3)
  ui.item_box_clear(bo2.eItemBox_Mall_SellJade)
  ui_mall.clear_mall_pet(g_pet_list)
end
function notify(text_id)
  local tt = bo2.gv_text:find(text_id)
  if tt == nil then
    return
  end
  local targets = tt.targets
  if targets.size > 0 then
    local chat = bo2.gv_chat_list:find(targets[0])
    if chat ~= nil then
      ui_tool.note_insert(tt.text, chat.color)
      return
    end
  end
  ui_tool.note_insert(tt.text)
end
function MayDeal(item_info, bitmask)
  local excel = item_info.excel
  if excel == nil or bo2.bit_and(excel.deal_type, bitmask) == 0 then
    return 72034
  end
  if bo2.bit_and(excel.deal_type, bo2.DealTypeBit_IgnoreBound) == 0 and item_info:get_data_8(bo2.eItemByte_Bound) ~= 0 then
    return 10188
  end
  return 0
end
function GetOldPrice(excel, box_beg, box_end)
  if excel.consume_mode == bo2.eItemConsumeMod_Stack or bo2.bit_and(excel.deal_type, bo2.DealTypeBit_DiffPrice) == 0 then
    local old_info = ui.item_of_excel_id(excel.id, box_beg, box_end)
    if old_info ~= nil then
      return old_info:get_data_32(bo2.eItemUInt32_ShopPrice)
    end
  end
  return 0
end
function req_upgoods(box, grid, onlyid)
  local function send_impl(count, money)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallManage_UpGoods)
    v:set(packet.key.item_key, onlyid)
    v:set(packet.key.item_box, box - bo2.eItemBox_Mall_Sell1)
    v:set(packet.key.item_grid, grid)
    v:set(packet.key.item_count, count)
    v:set(packet.key.cmn_money, money)
    bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  end
  local item_info = ui.item_of_only_id(onlyid)
  local bitmask = bo2.DealTypeBit_Money
  if box == bo2.eItemBox_Mall_SellJade then
    bitmask = bo2.DealTypeBit_Jade
  end
  local rst = MayDeal(item_info, bitmask)
  if rst ~= 0 then
    notify(rst)
    return
  end
  local oldprice = 0
  if box == bo2.eItemBox_Mall_SellJade then
    oldprice = GetOldPrice(item_info.excel, bo2.eItemBox_Mall_SellJade, bo2.eItemBox_Mall_Want)
  else
    oldprice = GetOldPrice(item_info.excel, bo2.eItemBox_Mall_Sell1, bo2.eItemBox_Mall_SellJade)
  end
  if oldprice == 0 then
    if box == bo2.eItemBox_Mall_SellJade then
      ui_widget.ui_msg_box.show({
        style_uri = "$frame/mall/manage_sell.xml",
        style_name = "jade_input_box",
        init = function(msg)
          local window = msg.window
          local mtf = ui.get_text("mall|sale_input1")
          window:search("rv_text").mtf = mtf
          window:tune_y("rv_text")
          window:search("box_input").text = item_info.count
          window:search("box_input").focus_able = item_info.count > 1
        end,
        callback = function(msg)
          if msg.result == 1 then
            local window = msg.window
            local money = window:search("money").text.v_int
            send_impl(window:search("box_input").text.v_int, money)
          end
        end
      })
    else
      ui_widget.ui_msg_box.show({
        style_uri = "$frame/mall/common.xml",
        style_name = "money_input_box",
        init = function(msg)
          local window = msg.window
          window:search("count_pn").visible = true
          window:search("box_input").text = item_info.count
          window:search("box_input").focus_able = item_info.count > 1
          local mtf = ui.get_text("mall|sale_input1")
          window:search("rv_text").mtf = mtf
          window:tune_y("rv_text")
        end,
        callback = function(msg)
          if msg.result == 1 then
            local window = msg.window
            local money_ctrl = window:search("money")
            local money = ui_widget.ui_money_box.get_money(money_ctrl)
            send_impl(window:search("box_input").text.v_int, money)
          end
        end
      })
    end
  else
    notify(72060)
    if item_info.count == 1 then
      send_impl(1, oldprice)
    else
      ui_widget.ui_msg_box.show_common({
        text = ui.get_text("common|stall_get_purchase"),
        input = item_info.count,
        callback = function(ret)
          if ret.result == 1 then
            send_impl(ret.input.v_int, oldprice)
          end
        end
      })
    end
  end
end
function req_downgoods(card)
  local function send_impl(cnt)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallManage_DownGoods)
    v:set(packet.key.item_box, card.box - bo2.eItemBox_Mall_Sell1)
    v:set(packet.key.item_key, card.only_id)
    v:set(packet.key.item_count, cnt)
    v:set(packet.key.item_excelid, card.excel_id)
    bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  end
  if card == nil or card.info == nil then
    return
  end
  local cnt = card.info.count
  if cnt == 1 then
    send_impl(1)
  else
    ui_widget.ui_msg_box.show_common({
      text = ui.get_text("mall|downgoods_input"),
      input = cnt,
      callback = function(ret)
        if ret.result == 1 then
          send_impl(ret.input.v_int)
        end
      end
    })
  end
end
function on_drop(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down then
    return
  end
  ui.clean_drop()
  if ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    req_upgoods(card.box, card.grid, data:get("only_id").v_string)
  end
end
function on_mouse(card, msg, pos, wheel)
  local info = card.info
  if info == nil then
    return
  end
  if msg ~= ui.mouse_rbutton_click then
    return
  end
  if card.info ~= nil then
    req_downgoods(card)
  end
end
function init_sell_box(name, box)
  local box_panel = ui_tab.get_page(w_main, name):search("box_panel")
  ui_mall.create_box(box_panel, 8, 7, "$frame/mall/manage_sell.xml", box)
end
function on_card_tip_show(tip)
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item_without_price(stk, excel, card.info)
  ui_tool.ctip_push_text(stk, L("\n") .. ui.get_text("common|stall_sale_tip"))
  if card.box == bo2.eItemBox_Mall_SellJade then
    stk:raw_format(ui.get_text("supermarket|jade_label"), card.info:get_data_32(bo2.eItemUInt32_ShopPrice))
  else
    stk:raw_format("<m:%d>", card.info:get_data_32(bo2.eItemUInt32_ShopPrice))
  end
  ui_tool.ctip_push_operation(stk, ui.get_text("common|stall_owner_clear"))
  local stk_use
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_card_chg(card, index, info)
  local root = card.parent.parent
  local oldval = root.svar.total
  local newval = 0
  if info ~= nil and card.box ~= bo2.eItemBox_Mall_SellJade then
    newval = info:get_data_32(bo2.eItemUInt32_ShopPrice) * info.count
    root.svar.total = newval
    g_total_val.money = g_total_val.money + newval - oldval
  end
end
function get_view_box()
  for box = bo2.eItemBox_Mall_Sell1, bo2.eItemBox_Mall_SellJade do
    local name = sys.format("box:%d", box)
    local box_panel = w_main:search(name)
    if box_panel ~= nil and box_panel.parent.visible then
      return box_panel
    end
  end
  return nil
end
function on_clear(ctrl)
  local box_panel = get_view_box()
  if box_panel == nil then
    local root = g_pet_list
    for i = 0, root.item_count - 1 do
      local item = root:item_get(i)
      local v = sys.variant()
      v:set(packet.key.cmn_type, bo2.eMallManage_DownPet)
      v:set64(packet.key.pet_only_id, item.svar.id)
      bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
    end
  else
    local ctrl = box_panel.control_head
    while ctrl do
      req_downgoods(ctrl:search("card"))
      ctrl = ctrl.next
    end
  end
end
function req_uppet(pet_only_id, data)
  local function send_impl(money)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallManage_UpPet)
    v:set64(packet.key.pet_only_id, pet_only_id)
    v:set(packet.key.cmn_money, money)
    bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/mall/common.xml",
    style_name = "money_input_box",
    init = function(msg)
      local window = msg.window
      local mtf = ui.get_text("mall|sale_input1")
      window:search("rv_text").mtf = mtf
      window:tune_y("rv_text")
    end,
    callback = function(msg)
      if msg.result == 1 then
        local window = msg.window
        local money_ctrl = window:search("money")
        local money = ui_widget.ui_money_box.get_money(money_ctrl)
        send_impl(money)
      end
    end
  })
end
function on_petlist_observable(w, vis)
  if vis then
    local data = sys.variant()
    data:set("keep_show", 1)
    data:set("ok_text", ui.get_text("mall|tab_shop_sell"))
    ui_pet.ui_pet_list.show_pet_list(req_uppet, data)
  else
    local w = ui.find_control("$frame:pet_list")
    w.visible = vis
  end
  g_downpet.visible = vis
end
function on_downpet(ctrl)
  local g_select = g_pet_list.item_sel
  if g_select == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallManage_DownPet)
  v:set64(packet.key.pet_only_id, g_select.svar.id)
  bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
end
