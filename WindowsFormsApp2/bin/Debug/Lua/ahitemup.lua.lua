local ui_combo = ui_widget.ui_combo_box
g_taxAHUp1 = 1
g_taxAHUp2 = 3
g_taxAHUp3 = 7
g_taxAHSale = 5
g_minPriceMoney = 100
g_minPriceJade = 100
g_adFeeMoney = 10000
g_adFeeJade = 10
function on_init(ctrl)
  local cb = w_main:search("cb_currency")
  ui_combo.append(cb, {
    id = 0,
    text = ui.get_text("supermarket|ahitem_jade")
  })
  ui_combo.append(cb, {
    id = 1,
    text = ui.get_text("supermarket|ahitem_money")
  })
  ui_combo.select(cb, 0)
  cb.svar.on_select = on_currency_select
  cb.svar.on_select(ui_combo.selected(cb))
  cb = w_main:search("cb_days")
  for i = 1, 3 do
    ui_combo.append(cb, {
      id = i,
      text = ui.get_text("supermarket|ahitem_day_" .. i)
    })
  end
  ui_combo.select(cb, 1)
  cb.svar.on_select = on_day_select
  cb.svar.on_select(ui_combo.selected(cb))
end
function on_update_par(data)
  g_taxAHUp1 = data:get(packet.key.item_key1).v_int
  g_taxAHUp2 = data:get(packet.key.item_key2).v_int
  g_taxAHUp3 = data:get(packet.key.item_key3).v_int
  g_taxAHSale = data:get(packet.key.item_key4).v_int
  g_minPriceMoney = data:get(packet.key.item_key5).v_int
  g_minPriceJade = data:get(packet.key.item_key6).v_int
  g_adFeeMoney = data:get(packet.key.item_key7).v_int
  g_adFeeJade = data:get(packet.key.item_key8).v_int
  local text = ui.get_text("supermarket|ahitem_sale_tax")
  w_main:search("sale_tax").mtf = sys.format(text, g_taxAHSale)
  text = ui.get_text("supermarket|ahitemup_desc")
  w_main:search("desc").mtf = sys.format(text, g_minPriceMoney, g_adFeeMoney, g_minPriceJade, g_adFeeJade)
  on_ah_up_change(w_main)
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  ui_npcfunc.ui_cell.clear(w_main:search("mat_raw"))
  ui_supermarket.g_mask_layer.visible = vis
  local w = ui.find_control("$frame:item")
  if w ~= nil then
    w.visible = vis
  end
end
function on_raw_card_mouse(ctrl, msg)
  if msg ~= ui.mouse_rbutton_down then
    return
  end
  ui_npcfunc.ui_cell.clear(w_main:search("mat_raw"))
end
function on_card_chg()
  w_main:insert_post_invoke(do_raw_update, "ui_supermarket.ui_ahitemup.do_raw_update")
end
function do_raw_update()
  ah_up_ok.enable = false
  local item_info = w_main:search("mat_raw"):search("card").info
  if item_info == nil then
    w_main:search("box_input").text = ""
    w_main:search("box_input").focus_able = false
    ui_npcfunc.ui_cell.clear(w_main:search("mat_raw"))
    return
  end
  w_main:search("box_input").text = 1
  w_main:search("box_input").focus_able = 1 < item_info.count
  w_main:search("mat_raw"):search("card").require_count = 1
  ah_up_ok.enable = true
end
function on_count_change(ctrl, txt)
  w_main:search("mat_raw"):search("card").require_count = w_main:search("box_input").text.v_int
end
function on_ah_up_change(ctrl)
  local cb = w_main:search("cb_days")
  local item = ui_combo.selected(cb)
  local tax = get_tax(item)
  local stk = sys.mtf_stack()
  stk:raw_push(ui.get_text("supermarket|ahitem_total"))
  if w_main:search("jade").visible then
    local price = w_main:search("money_jade").text.v_int
    local fee = math.floor(price * tax / 100)
    if w_main:search("check_ad_mall").check then
      fee = fee + g_adFeeJade
    end
    stk:raw_push(get_money_mtf(bo2.eCurrency_CirculatedJade, price))
    stk:raw_push(ui.get_text("supermarket|ahitem_fee"))
    stk:raw_push(get_money_mtf(bo2.eCurrency_CirculatedJade, fee))
  else
    local money_ctrl = w_main:search("money")
    local price = ui_widget.ui_money_box.get_money(money_ctrl)
    local fee = math.floor(price * tax / 100)
    if w_main:search("check_ad_mall").check then
      fee = fee + g_adFeeMoney
    end
    stk:raw_push(get_money_mtf(bo2.eCurrency_CirculatedMoney, price))
    stk:raw_push(ui.get_text("supermarket|ahitem_fee"))
    stk:raw_push(get_money_mtf(bo2.eCurrency_CirculatedMoney, fee))
  end
  w_main:search("total").mtf = stk.text
end
function on_ok(ctrl)
  local info = w_main:search("mat_raw"):search("card").info
  if info == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eSupermarket_UpAHItem)
  v:set(packet.key.item_key, info.only_id)
  local count = w_main:search("box_input").text.v_int
  v:set(packet.key.item_count, count)
  local cb = w_main:search("cb_days")
  local item = ui_combo.selected(cb)
  local tax = get_tax(item)
  v:set(packet.key.auction_days, item.id)
  if w_main:search("check_fixed_price").check == false then
    v:set(packet.key.auction_nego, 1)
  end
  if w_main:search("jade").visible then
    local price = w_main:search("money_jade").text.v_int
    local fee = math.floor(price * tax / 100)
    if w_main:search("check_ad_mall").check then
      fee = fee + g_adFeeJade
      v:set(packet.key.auction_admall, 1)
    end
    v:set(packet.key.currency, bo2.eCurrency_CirculatedJade)
    v:set(packet.key.cmn_price, price)
    v:set(packet.key.cmn_money, fee)
  else
    local money_ctrl = w_main:search("money")
    local price = ui_widget.ui_money_box.get_money(money_ctrl)
    local fee = math.floor(price * tax / 100)
    if w_main:search("check_ad_mall").check then
      fee = fee + g_adFeeMoney
      v:set(packet.key.auction_admall, 1)
    end
    v:set(packet.key.currency, bo2.eCurrency_CirculatedMoney)
    v:set(packet.key.cmn_price, price)
    v:set(packet.key.cmn_money, fee)
  end
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
  w_main.visible = false
end
function on_currency_select(item)
  if item.id == 0 then
    w_main:search("jade").visible = true
    w_main:search("money").visible = false
  else
    w_main:search("jade").visible = false
    w_main:search("money").visible = true
  end
  on_ah_up_change(item)
end
function get_tax(item)
  if item == nil then
    return g_taxAHUp1
  end
  if item.id == 2 then
    return g_taxAHUp2
  elseif item.id == 3 then
    return g_taxAHUp3
  end
  return g_taxAHUp1
end
function on_day_select(item)
  local tax = get_tax(item)
  w_main:search("up_tax").mtf = sys.format(ui.get_text("supermarket|ahitem_up_tax"), tax)
  on_ah_up_change(item)
end
function get_money_mtf(currency, val)
  if currency == bo2.eCurrency_CirculatedMoney then
    return sys.format("<m:%d>", val)
  elseif currency == bo2.eCurrency_CirculatedJade then
    return sys.format(ui.get_text("supermarket|jade_label"), val)
  end
end
