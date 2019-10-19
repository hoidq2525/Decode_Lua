function on_init()
  update_calc()
end
function get_max(data)
  local limit = data:get(packet.key.goods_limit).v_int
  if limit < 1 then
    return 65535
  end
  local remain = data:get(packet.key.goods_remain).v_int
  if remain > 0 then
    return remain
  end
  return 0
end
function find_item(goods_id)
  local root = g_goods_list
  for i = 0, root.item_count - 1 do
    local item = root:item_get(i)
    if item.svar.id == goods_id then
      return item
    end
  end
  return nil
end
function set_item_data(leaf_item, data)
  leaf_item.svar.id = data:get(packet.key.cmn_id).v_int
  leaf_item:search("name").text = data:get(packet.key.cmn_name).v_string
  leaf_item:search("price").text = data:get(packet.key.cmn_price).v_string
  local old_price = data:get(packet.key.goods_oldprice).v_int
  if old_price > 0 then
    leaf_item:search("oldprice").text = old_price
  else
    leaf_item:search("oldprice").text = ""
  end
  local tb = leaf_item:search("count")
  on_count_change(tb, tb.text)
  local card = leaf_item:search("goods_icon")
  card.excel_id = data:get(packet.key.cmn_id).v_int
  card.icon_name = data:get(packet.key.goods_icon).v_string
end
function on_insert(data)
  local goods_id = data:get(packet.key.cmn_id).v_int
  local max = get_max(data)
  if max < 1 then
    return
  end
  local leaf_item = find_item(goods_id)
  if leaf_item == nil then
    local style_uri = L("$frame/supermarket/trolly.xml")
    local leaf_name = L("goods_item")
    leaf_item = g_goods_list:item_append()
    leaf_item:load_style(style_uri, leaf_name)
    local tb = leaf_item:search("count")
    tb.text = 1
    set_item_data(leaf_item, data)
  else
    local tb = leaf_item:search("count")
    local old_num = tb.text.v_int
    if max <= old_num then
      return
    end
    tb.text = old_num + 1
    on_count_change(tb, tb.text)
  end
  local text = sys.format(ui.get_text("supermarket|trolly_notify_add"), data:get(packet.key.cmn_name).v_string)
  ui_tool.note_insert(text)
end
function on_delete(btn)
  ui_widget.ui_msg_box.show_common({
    text = ui.get_text("supermarket|trolly_cfm_del"),
    callback = function(ret)
      if ret.result == 1 then
        local leaf_item = ui_mall.find_parent(btn, L("leaf_item"))
        local id = leaf_item.svar.id
        local root = g_goods_list
        for i = 0, root.item_count - 1 do
          local item = root:item_get(i)
          if item.svar.id == id then
            root:item_remove(i)
            update_calc()
            return
          end
        end
      end
    end
  })
end
function on_item_select(ctrl, v)
  ctrl:search("select").visible = v
end
function on_sort_name(ctrl)
  ui_mall.on_click_sort_btn(ctrl)
  local function on_sort_inc(item1, item2)
    return ui_mall.compare_str(item1, item2, ctrl.name)
  end
  local function on_sort_dec(item1, item2)
    return ui_mall.compare_str(item2, item1, ctrl.name)
  end
  local root = g_goods_list
  local cur_sort_dir = ctrl.parent.svar.sort.dir
  if cur_sort_dir == 1 then
    root:item_sort(on_sort_inc)
  else
    root:item_sort(on_sort_dec)
  end
end
function on_sort_num(ctrl)
  ui_mall.on_click_sort_btn(ctrl)
  local function on_sort_inc(item1, item2)
    return ui_mall.compare_num(item1, item2, ctrl.name)
  end
  local function on_sort_dec(item1, item2)
    return ui_mall.compare_num(item2, item1, ctrl.name)
  end
  local root = g_goods_list
  local cur_sort_dir = ctrl.parent.svar.sort.dir
  if cur_sort_dir == 1 then
    root:item_sort(on_sort_inc)
  else
    root:item_sort(on_sort_dec)
  end
end
function on_count_change(tb, txt)
  local leaf_item = ui_mall.find_parent(tb, L("leaf_item"))
  local goodsID = leaf_item.svar.id
  local data = ui_supermarket.get_goods_data(goodsID)
  if data == nil then
    return
  end
  local num = txt.v_int
  local max = get_max(data)
  if num > max then
    num = max
  end
  tb.text = num
  local price = leaf_item:search("price").text
  leaf_item:search("total").text = price.v_int * num
  update_calc()
end
function clear_trolly()
  g_goods_list:item_clear()
  update_calc()
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
function req_buytrolly()
  local price, rate, money, gift, rebate = get_calc_result()
  if price < 1 then
    return
  end
  local myMoney = ui_supermarket.ui_account.w_main:search("jade").text.v_int
  if money > myMoney then
    notify(10084)
    return
  end
  local function send_impl()
    local root = g_goods_list
    local szAllGoods = ""
    for i = 0, root.item_count - 1 do
      local item = root:item_get(i)
      local cnt = item:search("count").text.v_int
      if cnt > 0 then
        local goodsID = item.svar.id
        local szGoods = sys.format("%d*%d*", goodsID, cnt)
        szAllGoods = szAllGoods .. szGoods
      end
    end
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eSupermarket_BuyGoods)
    v:set(packet.key.multi_goods, szAllGoods)
    v:set(packet.key.cmn_price, price)
    v:set(packet.key.cmn_money, money)
    bo2.send_variant(packet.eCTS_UI_Supermarket, v)
    clear_trolly()
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/supermarket/trolly.xml",
    style_name = "trolly_buy_input_box",
    init = function(msg)
      local window = msg.window
      on_trolly_buy_init(window)
      local mtf = ui.get_text("supermarket|buygoods_desc") .. ui.get_text("supermarket|trolly_cfm_buy")
      window:search("rv_text").mtf = mtf
      window:tune_y("rv_text")
    end,
    callback = function(ret)
      if ret.result == 1 then
        send_impl()
      end
    end
  })
end
function on_buy(btn)
  req_buytrolly()
end
function on_clear(btn)
  ui_widget.ui_msg_box.show_common({
    text = ui.get_text("supermarket|trolly_cfm_clear"),
    callback = function(ret)
      if ret.result == 1 then
        clear_trolly()
      end
    end
  })
end
function on_trolly_buy_init(ctrl)
  local price, rate, money, gift, rebate = get_calc_result()
  local wnd = ctrl
  wnd:search("price").text = price
  if rate == 100 then
    wnd:search("rate").text = ui.get_text("supermarket|none_label")
  else
    wnd:search("rate").text = rate
  end
  wnd:search("money").text = money
  wnd:search("gift").excel_id = gift
  wnd:search("rebate").text = rebate
end
function update_calc()
  local root = g_goods_list
  local price = 0
  local rebate = 0
  for i = 0, root.item_count - 1 do
    local item = root:item_get(i)
    price = price + item:search("total").text.v_int
    local data = ui_supermarket.get_goods_data(item.svar.id)
    if data ~= nil then
      rebate = rebate + item:search("count").text.v_int * data:get(packet.key.goods_rebate).v_int
    end
  end
  local rate, money, gift = ui_supermarket.ui_shelf.get_discount(price)
  local wnd = g_trolly_desc
  wnd:search("price").text = price
  if rate == 100 then
    wnd:search("rate").text = ui.get_text("supermarket|none_label")
  else
    wnd:search("rate").text = rate
  end
  wnd:search("money").text = money
  wnd:search("gift").excel_id = gift
  wnd:search("rebate").text = rebate
end
function get_calc_result()
  local wnd = g_trolly_desc
  local price = wnd:search("price").text.v_int
  local rate = 100
  if wnd:search("rate").text ~= ui.get_text("supermarket|none_label") then
    rate = wnd:search("rate").text.v_int
  end
  local money = wnd:search("money").text.v_int
  local gift = wnd:search("gift").excel_id
  local rebate = wnd:search("rebate").text.v_int
  return price, rate, money, gift, rebate
end
function on_observable(w, vis)
  g_trolly_desc.visible = vis
  if vis then
    ui_supermarket.ui_rank.showall()
  end
end
function update_goods()
  local root = g_goods_list
  local price = 0
  for i = 0, root.item_count - 1 do
    local item = root:item_get(i)
    local goodsID = item.svar.id
    local data = ui_supermarket.get_goods_data(goodsID)
    set_item_data(item, data)
  end
end
function on_goods_card_tip_show(tip)
  local stk = sys.mtf_stack()
  local stk_use
  ui_supermarket.make_goods_tip(tip, stk, stk_use)
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
