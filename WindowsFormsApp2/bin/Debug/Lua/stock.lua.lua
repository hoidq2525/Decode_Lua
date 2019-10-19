local reg = ui_packet.recv_wrap_signal_insert
local g_buys = {}
local g_sells = {}
local _UpdateStockItem = function(treeitem, data)
  treeitem.svar = nil
  if data then
    treeitem:search("money").money = data.price
    local v = sys.variant()
    v:set("count", data.num)
    treeitem:search("num").text = sys.mtf_merge(v, ui.get_text("supermarket|mnyswap_onhands"))
    treeitem.svar = data
  end
  treeitem:search("money").visible = data
  treeitem:search("num").visible = data
end
function stock_Init()
  w_stock:search("stockall").press = true
  local f = function(list)
    list:item_clear()
    list:search("slider").visible = true
    list:insert_on_item_mouse(stock_RemoveSwap)
  end
  f(w_mybuylist)
  f(w_myselllist)
  w_sellstocklist:insert_on_item_mouse(stock_CopyItemPrice)
  w_buystocklist:insert_on_item_mouse(stock_CopyItemPrice)
  for i = 1, 5 do
    local ti = w_buystocklist:item_get(i - 1)
    _UpdateStockItem(ti)
  end
  for i = 1, 5 do
    local ti = w_sellstocklist:item_get(5 - i)
    _UpdateStockItem(ti)
  end
end
function stock_CopyItemPrice(ti, msg)
  if not ti:search("money").visible then
    return
  end
  if msg == ui.mouse_enter then
    ti:search("p").xcolor = "FFA0A4A9"
  elseif msg == ui.mouse_leave then
    ti:search("p").xcolor = "00A0A4A9"
  end
  if msg ~= ui.mouse_lbutton_down then
    return
  end
  if ti.svar then
    local price = ti.svar.price
    local func = ti.svar.func
    if func then
      func(nil, price)
    end
  end
end
local function _UpdateStock(price, num, datas, listctrl, sortfn, getfn)
  table.sort(datas, sortfn)
  for i = 1, 5 do
    local treeitem = listctrl:item_get(getfn(i))
    _UpdateStockItem(treeitem, datas[i])
  end
end
local g_buytax = 0
local g_selltax = 0
reg(packet.eSTC_Supermarket, function(cmd, data)
  local cmntype = data:get(packet.key.cmn_type).v_int
  if cmntype == bo2.eSupermarketUI_ClearSwap then
    g_buytax = data:get(packet.key.item_key1).v_int
    g_selltax = data:get(packet.key.item_key2).v_int
    local swaplist = data:get(packet.key.append_data)
    g_buys = {}
    g_sells = {}
    for i = 1, swaplist.size do
      local swap = swaplist:fetch_v(i - 1)
      local price = swap:get(packet.key.cmn_price).v_int
      local num = swap:get(packet.key.mnyswap_hands).v_int
      if swap:get(packet.key.cmn_type).v_int == bo2.eSupermarketUI_AddBuyJade then
        table.insert(g_buys, {
          price = price,
          num = num,
          func = stock_SendSell
        })
      else
        table.insert(g_sells, {
          price = price,
          num = num,
          func = stock_SendBuy
        })
      end
    end
    _UpdateStock(price, num, g_buys, w_buystocklist, function(t1, t2)
      return t1.price > t2.price
    end, function(i)
      return i - 1
    end)
    _UpdateStock(price, num, g_sells, w_sellstocklist, function(t1, t2)
      return t1.price < t2.price
    end, function(i)
      return i - 1
    end)
  end
end, "supermarket2.stock1")
local _GetBuyboxInput = function()
  local price = sys.add64(sys.mul64(w_stock_moneyg.text.v_int, 10000), sys.mul64(w_stock_moneyy.text.v_int, 100))
  local num = w_stock_moneyqb.text.v_int
  return price, num
end
local function _GetMoneyAndQBInput(tag, fn, price)
  ui_widget.ui_msg_box.show_common({
    style_uri = "$frame/supermarket_v2/stock.xml",
    style_name = "buybox",
    modal = true,
    init = function(data)
      local def = {
        buy = {
          title = ui.get_text("supermarket|stockbuybtn"),
          tax = g_buytax,
          tip = ui.get_text("supermarket|prebuytip")
        },
        sell = {
          title = ui.get_text("supermarket|stocksellbtn"),
          tax = g_selltax,
          tip = ui.get_text("supermarket|preselltip")
        }
      }
      local w = data.window
      w:search("lb_title").text = def[tag].title
      w:search("tip").text = def[tag].tip
      w.svar.tax = def[tag].tax
      w_stock_moneyqb.focus = true
      if price then
        local gold = sys.div64(price, 10000)
        w_stock_moneyg.text = gold
        w_stock_moneyy.text = sys.div64(price - gold.v_int * 10000, 100)
      end
    end,
    callback = function(rst)
      if rst.result == 1 then
        fn(_GetBuyboxInput())
      end
    end
  })
end
function stock_refreshBuybox()
  local price, num = _GetBuyboxInput()
  local w = w_stock_moneyqb.topper
  local total = sys.mul64(price, num)
  w:search("totalm").money = total.v_int
  local tax = sys.div64(sys.mul64(total, w.svar.tax), 100)
  w:search("taxm").money = tax.v_int
end
function stock_SendBuy(btn, pr)
  _GetMoneyAndQBInput("buy", function(price, num)
    if price.v_int > 0 and num > 0 then
      local basicMoney = sys.mul64(num, price)
      local money = sys.div64(sys.mul64(basicMoney, sys.add64(100, g_buytax)), 100)
      local v = sys.variant()
      v:set(packet.key.cmn_price, price)
      v:set(packet.key.mnyswap_hands, num)
      v:set(packet.key.currency, bo2.eCurrency_CirculatedMoney)
      v:set64(packet.key.cmn_money, money)
      v:set(packet.key.cmn_type, bo2.eSupermarket_UpMnySwap)
      bo2.send_variant(packet.eCTS_UI_Supermarket, v)
      stock_Query()
    end
  end, pr)
end
function stock_SendSell(btn, pr)
  _GetMoneyAndQBInput("sell", function(price, num)
    if price.v_int > 0 and num > 0 then
      local money = num * 100
      local v = sys.variant()
      v:set(packet.key.cmn_price, price)
      v:set(packet.key.mnyswap_hands, num)
      v:set(packet.key.currency, bo2.eCurrency_CirculatedJade)
      v:set(packet.key.cmn_money, money)
      v:set(packet.key.cmn_type, bo2.eSupermarket_UpMnySwap)
      bo2.send_variant(packet.eCTS_UI_Supermarket, v)
      stock_Query()
    end
  end, pr)
end
function stock_Query(ctrl)
  if w_stock.observable then
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eSupermarket_BrowseJadeSwap)
    bo2.send_variant(packet.eCTS_UI_Supermarket, v)
    if w_stock == ctrl then
      v:set(packet.key.cmn_type, bo2.eSupermarket_BrowseMySwap)
      bo2.send_variant(packet.eCTS_UI_Supermarket, v)
    end
  end
end
reg(packet.eSTC_Supermarket, function(cmd, data)
  local cmntype = data:get(packet.key.cmn_type).v_int
  if cmntype == bo2.eSupermarketUI_ClearMySwap then
    w_mybuylist:item_clear()
    w_myselllist:item_clear()
    local swaplist = data:get(packet.key.append_data)
    for i = 1, swaplist.size do
      local swap = swaplist:fetch_v(i - 1)
      local ti
      if swap:get(packet.key.currency).v_int == bo2.eCurrency_CirculatedMoney then
        ti = w_mybuylist:item_append()
      else
        ti = w_myselllist:item_append()
      end
      ti:load_style("$frame/supermarket_v2/stock.xml", "stockitem")
      local money = swap:get(packet.key.cmn_price).v_int
      local num = swap:get(packet.key.mnyswap_hands).v_int - swap:get(packet.key.item_count).v_int
      _UpdateStockItem(ti, {price = money, num = num})
      ti.svar = swap:get(packet.key.cmn_id).v_string
    end
  end
end, "supermarket2.stock3")
function stock_RemoveSwap(ti, msg)
  if msg == ui.mouse_lbutton_down and ti.svar then
    ti:search("p").xcolor = "FF99B2E4"
    ui_tool.show_msg({
      text = ui.get_text("supermarket|stockcancel"),
      btn_confirm = true,
      btn_cancel = true,
      callback = function(rst)
        if rst.result == 1 then
          local v = sys.variant()
          v:set(packet.key.cmn_id, ti.svar)
          v:set(packet.key.cmn_type, bo2.eSupermarket_DownMnySwap)
          bo2.send_variant(packet.eCTS_UI_Supermarket, v)
        else
          ti:search("p").xcolor = "0099B2E4"
        end
      end
    })
  end
end
function stock_switchPanel(btn, c)
  if btn.name == L("stockall") then
    stock_Query()
  end
  local n = sys.format("%s.pn", btn.name)
  w_stock:search(n).visible = c
end
