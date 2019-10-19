local g_cur_grid = 0
local g_mid_mtf_str = L("<a+:m>%s<a->")
function on_init(ctrl)
  ui_widget.ui_stepping.set_event(g_step, ui_supermarket.ui_ahsearch.on_req_refresh)
  rawset(_M, "d_all_ahitems", {})
end
function on_observable(w, vis)
  ui_supermarket.ui_rank.w_main.parent.visible = not vis
  ui_supermarket.ui_ahsearch.w_main.visible = vis
  if vis then
    ui_supermarket.ui_ahsearch.on_req_refresh(w)
  end
end
function on_ClearAHItem(data)
  rawset(_M, "d_all_ahitems", {})
  local root = w_main:search("ah_list")
  root:item_clear()
  g_cur_grid = 0
  local p_cur = data:get(packet.key.mall_page_cur).v_int
  local p_end = data:get(packet.key.mall_page_end).v_int
  ui_widget.ui_stepping.set_page(g_step, p_cur, p_end)
  ui_supermarket.ui_ahitemup.on_update_par(data)
end
function on_AddAHItem(data)
  local root = w_main:search("ah_list")
  local style_uri = L("$frame/supermarket/ahitem.xml")
  local leaf_name = L("ah_item")
  local leaf_item = root:item_append()
  leaf_item:load_style(style_uri, leaf_name)
  local function set_ah_rv(name, str, fmt)
    if fmt == nil then
      leaf_item:search(name).mtf = str
    else
      leaf_item:search(name).mtf = sys.format(fmt, str)
    end
    leaf_item:search(name).slider_y.scroll = 0
  end
  local name = data:get(packet.key.cha_name).v_string
  set_ah_rv("owner", name, g_mid_mtf_str)
  local player = bo2.player
  if player ~= nil and player.name == name then
    leaf_item:search("btn_down").visible = true
  else
    leaf_item:search("btn_buy").visible = true
    if data:get(packet.key.auction_nego).v_int == 1 then
      leaf_item:search("btn_nego").visible = true
    end
  end
  local info = ui.item_create_data(bo2.eItemBox_AH_Sell, g_cur_grid, data:get(packet.key.itemdata_all))
  g_cur_grid = g_cur_grid + 1
  if info ~= nil then
    local id = info.only_id
    d_all_ahitems[id] = data
    leaf_item.svar.id = id
    leaf_item:search("card").only_id = id
    set_ah_rv("name", info.excel.name)
    set_ah_rv("level", info.excel.reqlevel, g_mid_mtf_str)
    if info.excel.ptype ~= nil then
      set_ah_rv("label", info.excel.ptype.name, g_mid_mtf_str)
    end
  end
  local sec = data:get(packet.key.auction_days).v_int
  local hour = math.floor(sec / 3600)
  if hour < 1 then
    leaf_item:search("remain").mtf = ui.get_text("supermarket|hour_label_min")
  else
    leaf_item:search("remain").mtf = sys.format(ui.get_text("supermarket|hour_label"), hour)
  end
  if data:get(packet.key.auction_admall).v_int == 1 then
    leaf_item:search("mall").visible = true
  end
  if data:get(packet.key.currency).v_int == bo2.eCurrency_CirculatedMoney then
    leaf_item:search("price_money").visible = true
    leaf_item:search("price_jade").parent.visible = false
    leaf_item:search("price_money").money = data:get(packet.key.cmn_price).v_int
  else
    leaf_item:search("price_money").visible = false
    leaf_item:search("price_jade").parent.visible = true
    set_ah_rv("price_jade", data:get(packet.key.cmn_price).v_int, ui.get_text("supermarket|ahitem_jade_mtf"))
  end
end
function on_MayRefresh(data)
  ui_supermarket.ui_ahsearch.on_req_refresh(w_main)
end
function on_click_nego(ctrl)
  local leaf_item = ui_mall.find_parent(ctrl, L("leaf_item"))
  local only_id = leaf_item.svar.id
  local data = d_all_ahitems[only_id]
  if data == nil then
    return
  end
  local name = data:get(packet.key.cha_name).v_string
  ui_im.create_friend_dialog(name, id)
end
function on_click_buy(ctrl)
  local leaf_item = ui_mall.find_parent(ctrl, L("leaf_item"))
  local only_id = leaf_item.svar.id
  local info = ui.item_of_only_id(only_id)
  if info == nil then
    return
  end
  local data = d_all_ahitems[only_id]
  if data == nil then
    return
  end
  local currency = data:get(packet.key.currency).v_int
  local money = data:get(packet.key.cmn_price).v_int
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/supermarket/ahitem.xml",
    style_name = "ah_buy_input_box",
    init = function(msg)
      local window = msg.window
      ui_npcfunc.ui_cell.drop(window:search("mat_raw"), info)
      if currency == bo2.eCurrency_CirculatedMoney then
        window:search("price_money").visible = true
        window:search("price_jade").visible = false
        window:search("price_money").money = money
      else
        window:search("price_money").visible = false
        window:search("price_jade").visible = true
        window:search("price_jade").text = sys.format(ui.get_text("supermarket|jade_label"), money)
      end
      local mtf = ui.get_text("supermarket|ahitem_cfm_buy")
      window:search("rv_text").mtf = mtf
      window:tune_y("rv_text")
    end,
    callback = function(msg)
      if msg.result == 1 then
        local v = sys.variant()
        v:set(packet.key.cmn_type, bo2.eSupermarket_BuyAHItem)
        v:set(packet.key.item_key, only_id)
        v:set(packet.key.item_excelid, info.excel_id)
        v:set(packet.key.item_count, info.count)
        v:set(packet.key.currency, currency)
        v:set(packet.key.cmn_money, money)
        bo2.send_variant(packet.eCTS_UI_Supermarket, v)
      end
    end
  })
end
function on_click_down(ctrl)
  local leaf_item = ui_mall.find_parent(ctrl, L("leaf_item"))
  local only_id = leaf_item.svar.id
  local info = ui.item_of_only_id(only_id)
  if info == nil then
    return
  end
  ui_widget.ui_msg_box.show_common({
    text = ui.get_text("supermarket|ahitem_cfm_down"),
    callback = function(ret)
      if ret.result == 1 then
        local v = sys.variant()
        v:set(packet.key.cmn_type, bo2.eSupermarket_DownAHItem)
        v:set(packet.key.item_key, only_id)
        v:set(packet.key.item_excelid, info.excel_id)
        v:set(packet.key.item_count, info.count)
        bo2.send_variant(packet.eCTS_UI_Supermarket, v)
      end
    end
  })
end
function on_click_mall(ctrl)
  local leaf_item = ui_mall.find_parent(ctrl, L("leaf_item"))
  local only_id = leaf_item.svar.id
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eSupermarket_EnterAdShop)
  v:set(packet.key.item_key, only_id)
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
end
function on_req_up(ctrl)
  local w = ui_supermarket.ui_ahitemup.w_main
  if w ~= nil then
    w.visible = true
  end
end
function on_req_sort(ctrl)
  ui_mall.on_click_sort_btn(ctrl)
  ui_supermarket.ui_ahsearch.on_req_refresh(ctrl)
end
function on_item_select(ctrl, v)
  ctrl:search("select").visible = v
end
function get_ahlist_size()
  local num = 0
  for k, v in pairs(d_all_ahitems) do
    if bo2.player.name == v:get(packet.key.cha_name).v_string then
      num = num + 1
    end
  end
  return num
end
