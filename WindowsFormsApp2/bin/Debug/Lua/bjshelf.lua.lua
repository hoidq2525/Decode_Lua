local ui_tab = ui_widget.ui_tab
local g_sel_goods
function on_init()
  rawset(_M, "d_all_bjgoods", {})
  ui_tab.clear_tab_data(w_main)
  ui_supermarket.ui_shelf.insert_tab_1st(w_main, "bjshelf_1")
  ui_supermarket.ui_shelf.insert_tab_1st(w_main, "bjshelf_2")
  ui_tab.show_page(w_main, "bjshelf_1", true)
  local wnd = ui_tab.get_page(w_main, "bjshelf_1")
  insert_tab_2nd(wnd, "bjshelf_11")
  ui_tab.show_page(wnd, "bjshelf_11", true)
  wnd = ui_tab.get_page(w_main, "bjshelf_2")
  insert_tab_2nd(wnd, "bjshelf_21")
  ui_tab.show_page(wnd, "bjshelf_21", true)
  ui_supermarket.ui_search.insert_tab_search(w_main, "bjshelf_")
  wnd = ui_tab.get_page(w_main, "bjshelf_")
  insert_tab_2nd(wnd, "bjshelf_101")
  insert_tab_2nd(wnd, "bjshelf_102")
  insert_tab_2nd(wnd, "bjshelf_103")
  insert_tab_2nd(wnd, "bjshelf_201")
  ui_supermarket.ui_search.hide_all(wnd, "bjshelf_")
end
function insert_tab_2nd(wnd, name)
  local btn_uri = "$frame/supermarket/supermarket.xml"
  local btn_sty = "mini_tab_btn"
  local page_uri = "$frame/supermarket/bjshelf.xml"
  local page_sty = "bjshelf_page"
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
    page_data.page.index = var.index * page_data.page.limit
    ui_supermarket.ui_shelf.update_page(page_data)
  end
  ui_widget.ui_stepping.set_event(page_data.step, on_page_step)
end
function on_ClearBJGoods(data)
  rawset(_M, "d_all_bjgoods", {})
  ui_supermarket.ui_shelf.clear_page_data(d_bjshelf_11)
  ui_supermarket.ui_shelf.clear_page_data(d_bjshelf_21)
  ui_supermarket.ui_shelf.clear_page_data(d_bjshelf_101)
  ui_supermarket.ui_shelf.clear_page_data(d_bjshelf_102)
  ui_supermarket.ui_shelf.clear_page_data(d_bjshelf_103)
  ui_supermarket.ui_shelf.clear_page_data(d_bjshelf_201)
end
function get_goods_data(goods_id)
  return d_all_bjgoods[goods_id]
end
function on_AddBJGoods(data)
  ui_supermarket.ui_rank.add_goods(data)
  local goods_id = data:get(packet.key.cmn_id).v_int
  d_all_bjgoods[goods_id] = data
  local v = data:get(packet.key.goods_page)
  local a = v:split_to_int_array("*")
  for i = 0, a.size - 1 do
    local page_id = a:get(i).v_int
    local page_data = rawget(_M, "d_bjshelf_" .. page_id)
    if page_data ~= nil then
      ui_supermarket.ui_shelf.insert_to_page(page_data, data)
    end
  end
  v = data:get(packet.key.goods_search)
  a = v:split_to_int_array("*")
  for i = 0, a.size - 1 do
    local page_id = a:get(i).v_int
    local page_data = rawget(_M, "d_bjshelf_" .. page_id)
    if page_data ~= nil then
      ui_supermarket.ui_shelf.insert_to_page(page_data, data)
    end
  end
end
function req_buygoods(goodsID)
  local data = d_all_bjgoods[goodsID]
  local name = data:get(packet.key.cmn_name).v_string
  local function send_impl(cnt)
    local szGoods = sys.format("%d*%d", goodsID, cnt)
    local money = data:get(packet.key.cmn_price).v_int * cnt
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eSupermarket_BuyBJGoods)
    v:set(packet.key.multi_goods, szGoods)
    v:set(packet.key.cmn_money, money)
    bo2.send_variant(packet.eCTS_UI_Supermarket, v)
  end
  g_sel_goods = data
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/supermarket/bjshelf.xml",
    style_name = "bjgoods_buy_input_box",
    init = function(msg)
      local window = msg.window
      on_goods_buy_init(window)
      local mtf = ui.get_text("supermarket|buygoods_desc") .. sys.format(ui.get_text("supermarket|bjgoods_cfm_buy"), name)
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
function on_count_change(tb, txt)
  local money = g_sel_goods:get(packet.key.cmn_price).v_int * txt.v_int
  local wnd = ui_mall.find_parent(tb, L("msg_box"))
  wnd:search("money").text = money
end
function on_goods_buy_init(ctrl)
  local input = ctrl:search("box_input")
  input.text = 1
  on_count_change(input, input.text)
end
function req_allgoods()
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eSupermarket_BrowseBJGoods)
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
end
