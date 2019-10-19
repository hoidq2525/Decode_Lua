local g_taxBuyJade = 0
local g_taxSellJade = 0
local g_tmpPrice = 0
function on_init(ctrl)
  g_req_timer.suspended = true
end
function req_buyjade()
  function send_impl(price, hands)
    local money = math.floor(hands * price * (100 + g_taxBuyJade) / 100)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eSupermarket_UpMnySwap)
    v:set(packet.key.currency, bo2.eCurrency_CirculatedMoney)
    v:set(packet.key.cmn_price, price)
    v:set(packet.key.mnyswap_hands, hands)
    v:set(packet.key.cmn_money, money)
    bo2.send_variant(packet.eCTS_UI_Supermarket, v)
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/supermarket/mnyswap.xml",
    style_name = "buyjade_input_box",
    init = function(msg)
      local window = msg.window
      on_buyjade_init(window)
      local mtf = ui.get_text("supermarket|mnyswap_cfm_buy")
      window:search("rv_text").mtf = mtf
      window:tune_y("rv_text")
    end,
    callback = function(msg)
      if msg.result == 1 then
        local window = msg.window
        local money_ctrl = window:search("money")
        local price = ui_widget.ui_money_box.get_money(money_ctrl)
        local hands = window:search("box_input").text.v_int
        send_impl(price, hands)
      end
    end
  })
end
function on_buyjade_change(tb, txt)
  local ctrl = ui_mall.find_parent(tb, L("msg_box"))
  local money_ctrl = ctrl:search("money")
  local price = ui_widget.ui_money_box.get_money(money_ctrl)
  local hands = ctrl:search("box_input").text.v_int
  ctrl:search("total").money = hands * price
  ctrl:search("tax").money = hands * g_taxBuyJade
end
function on_buyjade_init(ctrl)
  local input = ctrl:search("box_input")
  input.text = 1
  ui_widget.ui_money_box.set_money(ctrl:search("money"), g_tmpPrice)
  g_tmpPrice = 0
  on_buyjade_change(input, input.text)
end
function req_selljade()
  function send_impl(price, hands)
    local money = hands * (100 + g_taxSellJade)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eSupermarket_UpMnySwap)
    v:set(packet.key.currency, bo2.eCurrency_CirculatedJade)
    v:set(packet.key.cmn_price, price)
    v:set(packet.key.mnyswap_hands, hands)
    v:set(packet.key.cmn_money, money)
    bo2.send_variant(packet.eCTS_UI_Supermarket, v)
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/supermarket/mnyswap.xml",
    style_name = "selljade_input_box",
    init = function(msg)
      local window = msg.window
      on_selljade_init(window)
      local mtf = ui.get_text("supermarket|mnyswap_cfm_sell")
      window:search("rv_text").mtf = mtf
      window:tune_y("rv_text")
    end,
    callback = function(msg)
      if msg.result == 1 then
        local window = msg.window
        local money_ctrl = window:search("money")
        local price = ui_widget.ui_money_box.get_money(money_ctrl)
        local hands = window:search("box_input").text.v_int
        send_impl(price, hands)
      end
    end
  })
end
function on_selljade_change(tb, txt)
  local ctrl = ui_mall.find_parent(tb, L("msg_box"))
  local money_ctrl = ctrl:search("money")
  local price = ui_widget.ui_money_box.get_money(money_ctrl)
  local hands = ctrl:search("box_input").text.v_int
  ctrl:search("total").money = hands * price
  ctrl:search("tax").text = sys.format(ui.get_text("supermarket|jade_label"), hands * g_taxSellJade)
end
function on_selljade_init(ctrl)
  local input = ctrl:search("box_input")
  input.text = 1
  ui_widget.ui_money_box.set_money(ctrl:search("money"), g_tmpPrice)
  g_tmpPrice = 0
  on_selljade_change(input, input.text)
end
function on_buyjade_item(ctrl)
  g_tmpPrice = ctrl:search("price").money
  req_selljade()
end
function on_selljade_item(ctrl)
  g_tmpPrice = ctrl:search("price").money
  req_buyjade()
end
function on_downmy_item(ctrl)
  local leaf_item = ui_mall.find_parent(ctrl, L("leaf_item"))
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eSupermarket_DownMnySwap)
  v:set(packet.key.cmn_id, leaf_item.svar.id)
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
end
function on_btn_selljade(btn)
  req_selljade()
end
function on_btn_buyjade(btn)
  req_buyjade()
end
function on_btn_my(btn)
  local jade_page = w_main:search("jade_page")
  jade_page.visible = false
  local my_page = w_main:search("my_page")
  my_page.visible = true
end
function on_btn_main(btn)
  local jade_page = w_main:search("jade_page")
  jade_page.visible = true
  local my_page = w_main:search("my_page")
  my_page.visible = false
end
function on_ClearSwap(data)
  g_buyjade_list:item_clear()
  g_selljade_list:item_clear()
  g_taxBuyJade = data:get(packet.key.item_key1).v_int
  g_taxSellJade = data:get(packet.key.item_key2).v_int
  g_mnyswap_desc:search("desc").mtf = sys.format(ui.get_text("supermarket|hands_desc"), g_taxBuyJade, g_taxSellJade)
end
function on_AddBuyJade(data)
  local root = g_buyjade_list
  local style_uri = L("$frame/supermarket/mnyswap.xml")
  local leaf_name = L("buyjade_item")
  local leaf_item = root:item_append()
  leaf_item:load_style(style_uri, leaf_name)
  leaf_item:search("price").money = data:get(packet.key.cmn_price).v_int
  leaf_item:search("hands").text = sys.format(ui.get_text("supermarket|mnyswap_onhands"), data:get(packet.key.mnyswap_hands).v_int)
end
function on_AddSellJade(data)
  local root = g_selljade_list
  local style_uri = L("$frame/supermarket/mnyswap.xml")
  local leaf_name = L("selljade_item")
  local leaf_item = root:item_append()
  leaf_item:load_style(style_uri, leaf_name)
  leaf_item:search("price").money = data:get(packet.key.cmn_price).v_int
  leaf_item:search("hands").text = sys.format(ui.get_text("supermarket|mnyswap_onhands"), data:get(packet.key.mnyswap_hands).v_int)
end
function on_ClearMySwap(data)
  g_mybuy_list:item_clear()
  g_mysell_list:item_clear()
end
function on_AddMySwap(data)
  local root = g_mysell_list
  if data:get(packet.key.currency).v_int == bo2.eCurrency_CirculatedMoney then
    root = g_mybuy_list
  end
  local style_uri = L("$frame/supermarket/mnyswap.xml")
  local leaf_name = L("my_item")
  local leaf_item = root:item_append()
  leaf_item:load_style(style_uri, leaf_name)
  leaf_item.svar.id = data:get(packet.key.cmn_id).v_string
  leaf_item:search("price").money = data:get(packet.key.cmn_price).v_int
  local total = data:get(packet.key.mnyswap_hands).v_int
  local done = data:get(packet.key.item_count).v_int
  leaf_item:search("hands").text = sys.format(ui.get_text("supermarket|mnyswap_myhands"), done, total)
end
function req_allswap()
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eSupermarket_BrowseJadeSwap)
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
end
function req_allmyswap()
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eSupermarket_BrowseMySwap)
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
end
function on_main_observable(w, vis)
  if vis then
    req_allswap()
  end
end
function on_my_observable(w, vis)
  if vis then
    req_allmyswap()
  end
end
function on_observable(w, vis)
  g_mnyswap_desc.visible = vis
  g_req_timer.suspended = not vis
  ui_supermarket.ui_rank.w_main.parent.visible = not vis
  if vis then
    ui_supermarket.ui_rank.showall()
    on_req_timer(timer)
  end
end
function on_req_timer(timer)
  local jade_page = w_main:search("jade_page")
  if jade_page.visible then
    req_allswap()
    return
  end
  local my_page = w_main:search("my_page")
  if my_page.visible then
    req_allmyswap()
    return
  end
end
