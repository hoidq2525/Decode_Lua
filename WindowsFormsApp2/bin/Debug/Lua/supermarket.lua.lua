local ui_tab = ui_widget.ui_tab
local g_update = {}
BJGOODS_ID_MAX = 5000
function on_init()
  ui_tab.clear_tab_data(w_main)
  insert_tab(w_main, "announce")
  insert_tab(w_main, "shelf")
  insert_tab(w_main, "trolly")
  insert_tab(w_main, "mnyswap")
  insert_tab(w_main, "bjshelf")
  insert_tab(w_main, "ahitem")
  ui_tab.show_page(w_main, "shelf", true)
  g_update[bo2.eSupermarketUI_Announce] = ui_supermarket.ui_announce.on_Announce
  g_update[bo2.eSupermarketUI_ClearGoods] = ui_supermarket.ui_shelf.on_ClearGoods
  g_update[bo2.eSupermarketUI_AddGoods] = ui_supermarket.ui_shelf.on_AddGoods
  g_update[bo2.eSupermarketUI_AddDiscount] = ui_supermarket.ui_shelf.on_AddDiscount
  g_update[bo2.eSupermarketUI_ClearSwap] = ui_supermarket.ui_mnyswap.on_ClearSwap
  g_update[bo2.eSupermarketUI_AddBuyJade] = ui_supermarket.ui_mnyswap.on_AddBuyJade
  g_update[bo2.eSupermarketUI_AddSellJade] = ui_supermarket.ui_mnyswap.on_AddSellJade
  g_update[bo2.eSupermarketUI_ClearMySwap] = ui_supermarket.ui_mnyswap.on_ClearMySwap
  g_update[bo2.eSupermarketUI_AddMySwap] = ui_supermarket.ui_mnyswap.on_AddMySwap
  g_update[bo2.eSupermarketUI_ClearBJGoods] = ui_supermarket.ui_bjshelf.on_ClearBJGoods
  g_update[bo2.eSupermarketUI_AddBJGoods] = ui_supermarket.ui_bjshelf.on_AddBJGoods
  g_update[bo2.eSupermarketUI_ClearAHItem] = ui_supermarket.ui_ahitem.on_ClearAHItem
  g_update[bo2.eSupermarketUI_AddAHItem] = ui_supermarket.ui_ahitem.on_AddAHItem
  g_update[bo2.eSupermarketUI_MayRefresh] = ui_supermarket.ui_ahitem.on_MayRefresh
  g_update[bo2.eSupermarketUI_ClearExpress] = ui_supermarket.ui_express.on_ClearExpress
  g_update[bo2.eSupermarketUI_AddExpressGoods] = ui_supermarket.ui_express.on_AddExpressGoods
  g_update[bo2.eSupermarketUI_OpenRenewal] = ui_supermarket.ui_renewal.on_OpenRenewal
end
function insert_tab(wnd, name)
  local btn_uri = "$frame/supermarket/supermarket.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/supermarket/" .. name .. ".xml"
  local page_sty = name
  ui_tab.insert_suit(wnd, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(wnd, name)
  btn.text = ui.get_text("supermarket|main_tab_" .. name)
end
function supermarket_data(cmd, data)
  local op = data:get(packet.key.cmn_type).v_int
  local fn = g_update[op]
  if fn == nil then
    return
  end
  fn(data)
end
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_supermarket:on_signal"
reg(packet.eSTC_Supermarket, supermarket_data, sig)
function on_visible(w, vis)
  if vis then
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eSupermarket_Browse)
    bo2.send_variant(packet.eCTS_UI_Supermarket, v)
  end
  ui_widget.on_esc_stk_visible(w, vis)
end
function on_click_open(btn)
  w_main.visible = not w_main.visible
end
function get_goods_data(goods_id)
  if goods_id < BJGOODS_ID_MAX then
    return ui_supermarket.ui_bjshelf.get_goods_data(goods_id)
  else
    return ui_supermarket.ui_shelf.get_goods_data(goods_id)
  end
end
function addTryGoods(goods_id)
  local data = get_goods_data(goods_id)
  if data == nil then
    return
  end
  local szText = data:get(packet.key.item_excelid)
  local v = szText:split_to_int_array("*")
  for i = 1, v.size - 1, 2 do
    ui_supermarket.ui_preview.addTryItem(goods_id, v:get(i - 1).v_int)
  end
end
function reqBuygoods(goods_id)
  if goods_id < BJGOODS_ID_MAX then
    return ui_supermarket.ui_bjshelf.req_buygoods(goods_id)
  else
    return ui_supermarket.ui_shelf.req_buygoods(goods_id)
  end
end
function on_goods_card_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    if card.excel_id ~= 0 and card.var:get("preivew").v_int == 1 then
      addTryGoods(card.excel_id)
    end
  elseif msg == ui.mouse_rbutton_click and card.excel_id ~= 0 then
    reqBuygoods(card.excel_id)
  end
end
function make_goods_tip(tip, stk, stk_use)
  local card = tip.owner:search("goods_icon")
  local goods_id = card.excel_id
  if goods_id == 0 then
    return
  end
  local data = get_goods_data(goods_id)
  local szText = data:get(packet.key.item_excelid)
  local v = szText:split_to_int_array("*")
  local color = ui_tool.cs_tip_color_white
  if 0 < v.size then
    local item_id = v:get(0).v_int
    local excel = ui.item_get_excel(item_id)
    if excel ~= nil then
      color = excel.plootlevel_star.color
    end
  end
  local fmt = ui_tool.cs_tip_title_enter
  if not sys.is_type(color, "number") then
    fmt = ui_tool.cs_tip_title_enter_s
  end
  stk:raw_format(fmt, color)
  stk:push(data:get(packet.key.cmn_name))
  stk:raw_push(ui_tool.cs_tip_title_leave)
  local tip_id = data:get(packet.key.goods_tip).v_int
  local tt = bo2.gv_text:find(tip_id)
  if tt ~= nil then
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_newline(stk)
    stk:raw_format("<c+:9F601B>%s<c->", tt.text)
  end
  ui_tool.ctip_push_sep(stk)
  local days = data:get(packet.key.goods_days).v_int
  if days > 0 then
    stk:raw_push(ui.get_text("supermarket|renewal_lb"))
    stk:raw_format(ui.get_text("supermarket|days_lb"), days)
    ui_tool.ctip_push_newline(stk)
  elseif days == -1 then
    stk:raw_push(ui.get_text("supermarket|renewal_lb"))
    stk:raw_push(ui.get_text("supermarket|days_forever"))
    ui_tool.ctip_push_newline(stk)
  end
  local limit = data:get(packet.key.goods_limit).v_int
  if limit > 0 then
    local remain = data:get(packet.key.goods_remain).v_int
    if remain > 0 then
      stk:raw_format(ui.get_text("supermarket|limit_lb_remain"), limit, remain)
    else
      stk:raw_format(ui.get_text("supermarket|limit_lb_over"), limit)
    end
  end
  local old_price = data:get(packet.key.goods_oldprice).v_int
  local cur_price = data:get(packet.key.cmn_price).v_int
  if goods_id < ui_supermarket.BJGOODS_ID_MAX then
    if old_price == 0 then
      stk:raw_format(ui.get_text("supermarket|bjgoods_lb_curprice"), cur_price)
    else
      stk:raw_format(ui.get_text("supermarket|bjgoods_lb_oldprice"), old_price, cur_price)
    end
  else
    if old_price == 0 then
      stk:raw_format(ui.get_text("supermarket|goods_lb_curprice"), cur_price)
    else
      stk:raw_format(ui.get_text("supermarket|goods_lb_oldprice"), old_price, cur_price)
    end
    local rebate = data:get(packet.key.goods_rebate).v_int
    if rebate > 0 then
      stk:raw_format(ui.get_text("supermarket|goods_lb_rebate"), rebate)
    end
  end
  if v.size == 2 then
    local item_id = v:get(0).v_int
    local excel = ui.item_get_excel(item_id)
    if excel ~= nil then
      ui_tool.ctip_push_sep(stk)
      stk:raw_format(ui.get_text("supermarket|tip_item_count"), v:get(1).v_int)
      ui_tool.ctip_make_item_without_price(stk, excel, nil)
      local ptype = excel.ptype
      if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
        stk_use = ui_item.tip_get_using_equip(excel)
      end
    end
  else
    for i = 1, v.size - 1, 2 do
      local item_id = v:get(i - 1).v_int
      local excel = ui.item_get_excel(item_id)
      if excel ~= nil then
        ui_tool.ctip_push_sep(stk)
        stk:raw_format(ui.get_text("supermarket|tip_item_count"), v:get(i).v_int)
        ui_tool.ctip_make_item_without_price(stk, excel, nil)
      end
    end
  end
end
function on_goods_card_tip_show(tip)
  local stk = sys.mtf_stack()
  local stk_use
  make_goods_tip(tip, stk, stk_use)
  ui_tool.ctip_push_sep(stk)
  local card = tip.owner:search("goods_icon")
  if card.var:get("preivew").v_int == 1 then
    ui_tool.ctip_push_text(stk, ui.get_text("supermarket|tip_lclick"), ui_tool.cs_tip_color_operation)
    ui_tool.ctip_push_operation(stk, ui.get_text("supermarket|tip_rclick"))
  else
    ui_tool.ctip_push_text(stk, ui.get_text("supermarket|tip_rclick"), ui_tool.cs_tip_color_operation)
  end
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
