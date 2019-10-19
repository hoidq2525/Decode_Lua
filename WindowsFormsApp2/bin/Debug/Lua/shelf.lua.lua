local ui_tab = ui_widget.ui_tab
local g_discount = sys.variant()
local g_sel_goods
corner_def = {
  corner_1 = "$image/widget/pic/star_full.png",
  corner_2 = "$image/widget/pic/star_half.png",
  corner_3 = "$image/widget/pic/star_null.png",
  corner_4 = "$image/widget/pic/star_full.png"
}
function on_init()
  rawset(_M, "d_all_goods", {})
  ui_tab.clear_tab_data(w_main)
  insert_tab_1st(w_main, "shelf_1")
  insert_tab_1st(w_main, "shelf_2")
  ui_tab.show_page(w_main, "shelf_1", true)
  local wnd = ui_tab.get_page(w_main, "shelf_1")
  insert_tab_2nd(wnd, "shelf_11")
  insert_tab_2nd(wnd, "shelf_12")
  insert_tab_2nd(wnd, "shelf_13")
  ui_tab.show_page(wnd, "shelf_11", true)
  wnd = ui_tab.get_page(w_main, "shelf_2")
  insert_tab_2nd(wnd, "shelf_21")
  ui_tab.show_page(wnd, "shelf_21", true)
  ui_supermarket.ui_search.insert_tab_search(w_main, "shelf_")
  wnd = ui_tab.get_page(w_main, "shelf_")
  insert_tab_2nd(wnd, "shelf_101")
  insert_tab_2nd(wnd, "shelf_102")
  insert_tab_2nd(wnd, "shelf_103")
  insert_tab_2nd(wnd, "shelf_201")
  ui_supermarket.ui_search.hide_all(wnd, "shelf_")
end
function insert_tab_1st(wnd, name)
  local btn_uri = "$frame/supermarket/supermarket.xml"
  local btn_sty = "mini_tab_btn"
  local page_uri = "$frame/supermarket/shelf.xml"
  local page_sty = "shelf_frm"
  ui_tab.insert_suit(wnd, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(wnd, name)
  btn.text = ui.get_text("supermarket|tab_" .. name)
  local page = ui_tab.get_page(wnd, name)
  if page ~= nil then
    page.name = name
  end
end
function insert_tab_2nd(wnd, name)
  local btn_uri = "$frame/supermarket/supermarket.xml"
  local btn_sty = "mini_tab_btn"
  local page_uri = "$frame/supermarket/shelf.xml"
  local page_sty = "shelf_page"
  ui_tab.insert_suit(wnd, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(wnd, name)
  btn.text = ui.get_text("supermarket|tab_" .. name)
  local page_data = {}
  rawset(_M, "d_" .. name, page_data)
  page_data.tab = ui_tab.get_page(wnd, name)
  if page_data.tab ~= nil then
    page_data.view = page_data.tab:search("view")
    page_data.step = page_data.tab:search("step")
  end
  local list = {}
  page_data.list = list
  local page = {
    index = 0,
    count = 0,
    limit = 12
  }
  page_data.page = page
  local function on_page_step(var)
    page_data.page.index = var.index * n_page_limit
    update_page(page_data)
  end
  ui_widget.ui_stepping.set_event(page_data.step, on_page_step)
end
function set_cell(cell, data)
  if cell == nil then
    return
  end
  local goods_id = data:get(packet.key.cmn_id).v_int
  local card = cell:search("goods_icon")
  card.excel_id = goods_id
  card.icon_name = data:get(packet.key.goods_icon).v_string
  cell:search("goods_name").text = data:get(packet.key.cmn_name).v_string
  cell:search("corner_disc").visible = false
  local old_price = data:get(packet.key.goods_oldprice).v_int
  local cur_price = data:get(packet.key.cmn_price).v_int
  local days_desc = L("")
  local limit_desc = L("")
  local price_desc = L("")
  local days = data:get(packet.key.goods_days).v_int
  if days > 0 then
    days_desc = ui.get_text("supermarket|renewal_lb") .. sys.format(ui.get_text("supermarket|days_lb"), days) .. ui_tool.cs_tip_newline
  elseif days == -1 then
    days_desc = ui.get_text("supermarket|renewal_lb") .. ui.get_text("supermarket|days_forever") .. ui_tool.cs_tip_newline
  end
  local limit = data:get(packet.key.goods_limit).v_int
  if limit > 0 then
    local remain = data:get(packet.key.goods_remain).v_int
    if remain > 0 then
      limit_desc = sys.format(ui.get_text("supermarket|limit_lb_remain"), limit, remain)
    else
      limit_desc = sys.format(ui.get_text("supermarket|limit_lb_over"), limit)
    end
  end
  if goods_id < ui_supermarket.BJGOODS_ID_MAX then
    if old_price == 0 then
      price_desc = sys.format(ui.get_text("supermarket|bjgoods_lb_curprice"), cur_price)
    else
      price_desc = sys.format(ui.get_text("supermarket|bjgoods_lb_oldprice"), old_price, cur_price)
      local disc = math.ceil(cur_price * 10 / old_price)
      if disc > 0 and disc < 10 then
        cell:search("corner_disc").visible = true
        cell:search("corner_disc").text = sys.format(ui.get_text("supermarket|corner_disc"), disc)
      end
    end
  else
    if old_price == 0 then
      price_desc = sys.format(ui.get_text("supermarket|goods_lb_curprice"), cur_price)
    else
      price_desc = sys.format(ui.get_text("supermarket|goods_lb_oldprice"), old_price, cur_price)
      local disc = math.ceil(cur_price * 10 / old_price)
      if disc > 0 and disc < 10 then
        cell:search("corner_disc").visible = true
        cell:search("corner_disc").text = sys.format(ui.get_text("supermarket|corner_disc"), disc)
      end
    end
    local rebate = data:get(packet.key.goods_rebate).v_int
    if rebate > 0 then
      price_desc = price_desc .. sys.format(ui.get_text("supermarket|goods_lb_rebate"), rebate)
    end
  end
  if cell:search("desc") ~= nil then
    cell:search("desc").mtf = days_desc .. limit_desc .. price_desc
  end
  card:control_clear()
  local corner_id = data:get(packet.key.goods_corner).v_int
  if corner_id ~= 0 then
    local pic = corner_def["corner_" .. corner_id]
    if pic ~= nil then
      local c = ui.create_control(card, "picture")
      c:load_style("$frame/supermarket/shelf.xml", "corner_pic")
      c.image = pic
    end
  end
  local rank = data:get(packet.key.ranklist_id).v_int
  if rank > 0 then
    cell:search("corner_rank").visible = true
    cell:search("corner_rank").text = sys.format(ui.get_text("supermarket|corner_rank"), rank)
  else
    cell:search("corner_rank").visible = false
  end
  local szText = data:get(packet.key.item_excelid)
  local v = szText:split_to_int_array("*")
  local title_color = ui_tool.cs_tip_color_white
  if 0 < v.size then
    local item_id = v:get(0).v_int
    local excel = ui.item_get_excel(item_id)
    if excel ~= nil then
      title_color = excel.plootlevel_star.color
    end
  end
  cell:search("goods_name").color = ui.make_color(title_color)
  card.var:set("preivew", 0)
  for i = 1, v.size - 1, 2 do
    local item_id = v:get(i - 1).v_int
    local item_excel = ui.item_get_excel(item_id)
    if item_excel ~= nil and ui_supermarket.ui_preview.MaySuit(item_excel) then
      card.var:set("preivew", 1)
      break
    end
  end
end
function clear_page_data(page_data)
  local page = page_data.page
  page.index = 0
  page.count = 0
  for i = 0, page.limit - 1 do
    local cname = sys.format("cell%d", i)
    local cell = page_data.view:search(cname)
    cell.visible = false
  end
end
function on_ClearGoods(data)
  rawset(_M, "d_all_goods", {})
  g_discount:clear()
  clear_page_data(d_shelf_11)
  clear_page_data(d_shelf_12)
  clear_page_data(d_shelf_13)
  clear_page_data(d_shelf_21)
  clear_page_data(d_shelf_101)
  clear_page_data(d_shelf_102)
  clear_page_data(d_shelf_103)
  clear_page_data(d_shelf_201)
  ui_supermarket.ui_rank.add_ranklist(data:get(packet.key.ranklist_data))
end
function get_goods_data(goods_id)
  return d_all_goods[goods_id]
end
function add_goods_data(goods_id, data)
  d_all_goods[goods_id] = data
end
function update_page(page_data)
  local page = page_data.page
  local p_idx = math.floor(page.index / page.limit)
  local p_cnt = math.floor((page.count + page.limit - 1) / page.limit)
  ui_widget.ui_stepping.set_page(page_data.step, p_idx, p_cnt)
  for i = 0, page.limit - 1 do
    local cname = sys.format("cell%d", i)
    local cell = page_data.view:search(cname)
    local idx = page.index + i
    if idx < page.count then
      set_cell(cell, page_data.list[idx])
      cell.visible = true
    else
      cell.visible = false
    end
  end
end
function insert_to_page(page_data, data)
  local i = page_data.page.count
  page_data.page.count = i + 1
  page_data.list[i] = data
  update_page(page_data)
end
function on_AddGoods(data)
  ui_supermarket.ui_rank.add_goods(data)
  local goods_id = data:get(packet.key.cmn_id).v_int
  d_all_goods[goods_id] = data
  local v = data:get(packet.key.goods_page)
  local a = v:split_to_int_array("*")
  for i = 0, a.size - 1 do
    local page_id = a:get(i).v_int
    local page_data = rawget(_M, "d_shelf_" .. page_id)
    if page_data ~= nil then
      insert_to_page(page_data, data)
    end
  end
  v = data:get(packet.key.goods_search)
  a = v:split_to_int_array("*")
  for i = 0, a.size - 1 do
    local page_id = a:get(i).v_int
    local page_data = rawget(_M, "d_shelf_" .. page_id)
    if page_data ~= nil then
      insert_to_page(page_data, data)
    end
  end
end
function on_AddDiscount(data)
  g_discount:push_back(data)
end
function req_buygoods(goodsID)
  local data = d_all_goods[goodsID]
  local name = data:get(packet.key.cmn_name).v_string
  local function send_impl(cnt)
    local szGoods = sys.format("%d*%d", goodsID, cnt)
    local price = data:get(packet.key.cmn_price).v_int * cnt
    local rate, money, gift = get_discount(price)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eSupermarket_BuyGoods)
    v:set(packet.key.multi_goods, szGoods)
    v:set(packet.key.cmn_price, price)
    v:set(packet.key.cmn_money, money)
    bo2.send_variant(packet.eCTS_UI_Supermarket, v)
  end
  g_sel_goods = data
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/supermarket/shelf.xml",
    style_name = "goods_buy_input_box",
    init = function(msg)
      local window = msg.window
      on_goods_buy_init(window)
      local mtf = ui.get_text("supermarket|buygoods_desc") .. sys.format(ui.get_text("supermarket|goods_cfm_buy"), name)
      window:search("rv_text").mtf = mtf
      window:tune_y("rv_text")
    end,
    callback = function(msg)
      if msg.result == 1 then
        local window = msg.window
        send_impl(window:search("box_input").text.v_int)
      end
    end
  })
end
function on_click_buygoods(btn)
  local cell = btn.parent.parent
  local goodsID = cell:search("goods_icon").excel_id
  req_buygoods(goodsID)
end
function on_click_addtotrolly(btn)
  local card = btn.parent.parent:search("goods_icon")
  local data = d_all_goods[card.excel_id]
  ui_supermarket.ui_trolly.on_insert(data)
end
function on_count_change(tb, txt)
  local price = g_sel_goods:get(packet.key.cmn_price).v_int * txt.v_int
  local rate, money, gift = get_discount(price)
  local wnd = ui_mall.find_parent(tb, L("msg_box"))
  wnd:search("price").text = price
  if rate == 100 then
    wnd:search("rate").text = ui.get_text("supermarket|none_label")
  else
    wnd:search("rate").text = rate
  end
  wnd:search("money").text = money
  wnd:search("gift").excel_id = gift
  wnd:search("rebate").text = g_sel_goods:get(packet.key.goods_rebate).v_int * txt.v_int
end
function get_discount(price)
  local rate = 100
  local gift = 0
  for i = 0, g_discount.size - 1 do
    local data = g_discount:get(i)
    local id = data:get(packet.key.cmn_id).v_int
    if price < id then
      break
    else
      rate = data:get(packet.key.cmn_index).v_int
      gift = data:get(packet.key.item_excelid).v_int
    end
  end
  local mny = math.floor(price * rate / 100)
  return rate, mny, gift
end
function on_goods_buy_init(ctrl)
  local input = ctrl:search("box_input")
  input.text = 1
  on_count_change(input, input.text)
end
function on_frm_observable(w, vis)
  if vis then
    ui_supermarket.ui_rank.filter(tostring(w.name))
  end
end
function on_observable(w, vis)
  ui_supermarket.ui_preview.w_main.visible = vis
end
