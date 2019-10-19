local cartList = {}
local function UpdateCartSum()
  local m = 0
  local sum = 0
  for _id, data in pairs(cartList) do
    if 0 < data.cnt then
      sum = sum + 1
    end
    m = m + data.data.price * data.cnt
  end
  w_cartmoney.text = m
  local v = sys.variant()
  v:set("count", sum)
  w_cartitemcount.text = sys.mtf_merge(v, ui.get_text("supermarket|cartnumlb"))
  return m, sum
end
function cart_Add(item, offset)
  local cartData = cartList[item.id]
  if cartData then
    cartData.data = item
    cartData.cnt = cartData.cnt + offset
  else
    do
      local itempnl = w_cartlist:item_append()
      itempnl:load_style("$frame/supermarket_v2/cart.xml", "cartitem")
      itembox_Show(itempnl:search("itembox"), item, true)
      itempnl:search("itemname").text = itembox_GetTitleColor(item)
      cartData = {
        data = item,
        ctrl = itempnl,
        cnt = offset
      }
      cartList[item.id] = cartData
      itempnl:search("itemnum"):insert_on_change(function(ctrl)
        cartData.cnt = tonumber(tostring(ctrl.text))
        itempnl:search("itempricesum").text = cartData.data.price * cartData.cnt
        UpdateCartSum()
      end)
      local function f(offset2)
        return function(ctrl)
          cartData.cnt = cartData.cnt + offset2
          if cartData.cnt < 0 then
            cartData.cnt = 0
          end
          if cartData.cnt > 999 then
            cartData.cnt = 999
          end
          itempnl:search("itemnum").text = cartData.cnt
          itempnl:search("itempricesum").text = cartData.data.price * cartData.cnt
          UpdateCartSum()
        end
      end
      itempnl:search("delbtn"):insert_on_click(f(-1))
      itempnl:search("addbtn"):insert_on_click(f(1))
      itempnl:search("rm"):insert_on_click(function()
        cartList[item.id] = nil
        itempnl:self_remove()
        UpdateCartSum()
      end)
    end
  end
  local poptip = ui.get_text("supermarket|addcarttip")
  poptip = ui_widget.merge_mtf({
    item = item.name
  }, poptip)
  ui_tool.note_insert(poptip, ui_quest.c_inform_color)
  local itempnl = cartData.ctrl
  itempnl:search("price").text = item.price
  itempnl:search("itemnum").text = cartData.cnt
  itempnl:search("itempricesum").text = cartData.data.price * cartData.cnt
  UpdateCartSum()
end
function cart_Buy()
  for id, data in pairs(cartList) do
    if data.cnt > 0 then
      local v = sys.variant()
      v:set(packet.key.cmn_price, data.data.price * data.cnt)
      v:set(packet.key.cmn_money, data.data.price * data.cnt)
      v:set(packet.key.multi_goods, "" .. id .. "*" .. data.cnt)
      v:set(packet.key.cmn_type, bo2.eSupermarket_BuyGoods)
      bo2.send_variant(packet.eCTS_UI_Supermarket, v)
    end
  end
  w_cartlist:item_clear()
  cartList = {}
end
local reg = ui_packet.recv_wrap_signal_insert
reg(packet.eSTC_Supermarket, function(cmd, data)
  local subcmd = data:get(packet.key.cmn_type).v_int
  if subcmd == bo2.eSupermarketUI_Announce then
    for id, _item in pairs(cartList) do
      if g_allGoods[id] then
        cart_Add(g_allGoods[id], 0)
      end
    end
  end
end, "ui_supermarket2.cart")
function cart_NotifyHaveItems()
  if not w_main.visible then
    return
  end
  w_cart_notify.visible = UpdateCartSum() > 0
end
function cart_Init()
  cartList = {}
end
