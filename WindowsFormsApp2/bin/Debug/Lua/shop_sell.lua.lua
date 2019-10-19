local ui_tab = ui_widget.ui_tab
local g_pick_item
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
  g_pick_item = nil
end
function on_item_pick(ctrl)
  if g_pick_item == ctrl then
    return
  end
  if g_pick_item ~= nil then
    g_pick_item.parent.parent:search("highlight").visible = false
  end
  g_pick_item = ctrl
  if g_pick_item == nil then
    g_btn_buyitem.enable = false
  else
    g_pick_item.parent.parent:search("highlight").visible = true
    g_btn_buyitem.enable = true
  end
end
function on_pet_select(ctrl, v)
  ctrl:search("select").visible = v
  g_btn_buypet.enable = v
end
function clear_data()
  on_item_pick(nil)
  ui.item_box_clear(bo2.eItemBox_Mall_Sell1)
  ui.item_box_clear(bo2.eItemBox_Mall_Sell2)
  ui.item_box_clear(bo2.eItemBox_Mall_Sell3)
  ui.item_box_clear(bo2.eItemBox_Mall_SellJade)
  ui.item_box_clear(bo2.eItemBox_Mall_Want)
  ui.item_box_clear(bo2.eItemBox_Mall_Acquire)
  ui_mall.clear_mall_pet(g_pet_list)
end
function insert_tab(name)
  local btn_uri = "$frame/mall/common.xml"
  local btn_sty = "mini_tab_btn"
  local page_uri = "$frame/mall/common.xml"
  local page_sty = name
  ui_tab.insert_suit(w_main, name, btn_uri, btn_sty, page_uri, page_sty)
  local page = ui_tab.get_page(w_main, name)
  page:insert_on_observable(on_sellitem_observable, "on_sellitem_observable")
  local btn = ui_tab.get_button(w_main, name)
  btn.text = ui.get_text("mall|" .. name)
end
function insert_pettab()
  local name = "sell_pet_box"
  local btn_uri = "$frame/mall/common.xml"
  local btn_sty = "mini_tab_btn"
  local page_uri = "$frame/mall/shop_sell.xml"
  local page_sty = name
  ui_tab.insert_suit(w_main, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_main, name)
  btn.text = ui.get_text("mall|" .. name)
end
function req_buygoods(card)
  local function send_impl(cnt)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallShop_BuyGoods)
    v:set(packet.key.item_box, card.box - bo2.eItemBox_Mall_Sell1)
    v:set(packet.key.item_key, card.only_id)
    v:set(packet.key.item_count, cnt)
    v:set(packet.key.item_excelid, card.excel_id)
    local price = card.info:get_data_32(bo2.eItemUInt32_ShopPrice)
    local money = price * cnt
    v:set(packet.key.cmn_money, money)
    bo2.send_variant(packet.eCTS_UI_Mall_Shop, v)
  end
  if card == nil or card.info == nil then
    return
  end
  local cnt = card.info.count
  if cnt == 1 then
    send_impl(1)
  else
    ui_widget.ui_msg_box.show_common({
      text = ui.get_text("common|stall_get_sale"),
      input = cnt,
      callback = function(ret)
        if ret.result == 1 then
          send_impl(ret.input.v_int)
        end
      end
    })
  end
end
function on_mouse(card, msg, pos, wheel)
  local info = card.info
  if info == nil then
    return
  end
  if msg == ui.mouse_lbutton_click then
    on_item_pick(card)
  elseif msg == ui.mouse_rbutton_click then
    req_buygoods(card)
  end
end
function init_sell_box(name, box)
  local box_panel = ui_tab.get_page(w_main, name):search("box_panel")
  ui_mall.create_box(box_panel, 8, 7, "$frame/mall/shop_sell.xml", box)
end
function on_click_buyitem(ctrl)
  req_buygoods(g_pick_item)
end
function on_click_buypet(ctrl)
  local g_select_pet = g_pet_list.item_sel
  if g_select_pet == nil then
    return
  end
  local card = g_select_pet:search("card")
  if card == nil then
    return
  end
  local pet_info = card.info
  if pet_info == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallShop_BuyPet)
  v:set64(packet.key.pet_only_id, g_select_pet.svar.id)
  v:set(packet.key.cmn_money, pet_info:get_atb(bo2.eFlag_Pet_ShopPrice))
  bo2.send_variant(packet.eCTS_UI_Mall_Shop, v)
end
function on_card_chg(card, index, info)
  if info == nil and g_pick_item == card then
    on_item_pick(nil)
  end
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
  ui_tool.ctip_push_operation(stk, ui.get_text("common|lclick_sel"))
  ui_tool.ctip_push_operation(stk, ui.get_text("common|rclick_buy"))
  local stk_use
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_sellitem_observable(w, vis)
  g_btn_buyitem.visible = vis
  if vis then
    on_item_pick(nil)
  end
end
function on_petlist_observable(w, vis)
  g_btn_buypet.visible = vis
end
