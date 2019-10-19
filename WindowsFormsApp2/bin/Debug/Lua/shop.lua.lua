local ui_tab = ui_widget.ui_tab
local g_shop_update = {}
local g_shop_id = 0
if rawget(_M, "g_shop_labels") == nil then
  g_shop_labels = {}
end
function insert_tab(name)
  local btn_uri = "$frame/mall/shop.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/mall/" .. name .. ".xml"
  local page_sty = name
  ui_tab.insert_suit(w_main, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_main, name)
  btn.text = ui.get_text("mall|tab_" .. name)
end
function on_init(ctrl)
  ui_tab.clear_tab_data(w_main)
  insert_tab("shop_main")
  insert_tab("shop_sell")
  insert_tab("shop_want")
  insert_tab("shop_news")
  ui_tab.show_page(w_main, "shop_main", true)
  g_shop_update[bo2.eMallManage_UI_Open] = on_UI_Open
  g_shop_update[bo2.eMallManage_UI_Close] = on_UI_Close
  g_shop_update[bo2.eMallManage_UI_News] = on_UI_News
  g_shop_update[bo2.eMallManage_UI_SetMoney] = on_UI_SetMoney
  g_shop_update[bo2.eMallManage_UI_AddItem] = on_UI_AddItem
  g_shop_update[bo2.eMallManage_UI_AddPet] = on_UI_AddPet
  g_shop_update[bo2.eMallManage_UI_DelPet] = on_UI_DelPet
  g_shop_update[bo2.eMallManage_UI_Collect] = on_UI_Collect
  g_shop_update[bo2.eMallManage_UI_SetBoxSize] = on_UI_SetBoxSize
  g_shop_id = 0
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis == false then
    if w.var:get("server_close_shop").v_int == 1 then
      return
    end
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallEnter_Detach)
    bo2.send_variant(packet.eCTS_UI_Mall_Enter, v)
  end
end
function on_UI_Open(data)
  ui_tab.show_page(w_main, "shop_main", true)
  w_main.visible = true
  g_shop_id = data:get(packet.key.mall_shop_id).v_string
  local name = ""
  if data:get(packet.key.cmn_state).v_int == 1 then
    name = ui.get_text("mall|hotmall_name") .. data:get(packet.key.cmn_name).v_string
  else
    name = ui.get_text("mall|mall_name") .. data:get(packet.key.cmn_name).v_string
  end
  local lb1 = ui.get_text("mall|tab_label" .. data:get(packet.key.item_key1).v_int)
  local lb2 = ui.get_text("mall|tab_label" .. data:get(packet.key.item_key2).v_int)
  for n, v in pairs(g_shop_labels) do
    v.name.mtf = name
    v.lb1.text = lb1
    v.lb2.text = lb2
  end
  ui_mall.ui_shop_main.w_main:search("collect").text = data:get(packet.key.item_count).v_int
  g_intro_view.mtf = data:get(packet.key.family_intro).v_string
  local acq_money = data:get(packet.key.mall_acqmoney).v_int
  ui_mall.ui_shop_main.g_mny_acquire.money = acq_money
  ui_mall.ui_shop_want.g_mny_acquire.money = acq_money
  ui_mall.ui_shop_sell.clear_data()
  ui_mall.ui_shop_news.clear_data()
end
function on_UI_Close(data)
  w_main.var:set("server_close_shop", 1)
  w_main.visible = false
  w_main.var:set("server_close_shop", 0)
end
function on_UI_News(data)
  ui_mall.ui_shop_news.on_news(data)
end
function on_UI_SetMoney(data)
  local slot = data:get(packet.key.item_grid).v_int
  if slot == 0 then
  else
    local acq_money = data:get(packet.key.cmn_money).v_int
    ui_mall.ui_shop_main.g_mny_acquire.money = acq_money
    ui_mall.ui_shop_want.g_mny_acquire.money = acq_money
  end
end
function on_UI_AddItem(data)
  local box = data:get(packet.key.item_box).v_int + bo2.eItemBox_Mall_Sell1
  local grid = data:get(packet.key.item_grid).v_int
  ui.item_create_data(box, grid, data:get(packet.key.itemdata_all))
end
function on_UI_AddPet(data)
  ui.pet_create_data(data:get(packet.key.pet_unit), bo2.ePetBox_Mall)
  ui_mall.insert_mall_pet(ui_mall.ui_shop_sell.g_pet_list)
end
function on_UI_DelPet(data)
  local id = data:get(packet.key.pet_only_id).v_string
  ui.pet_remove(id)
  ui_mall.erase_mall_pet(ui_mall.ui_shop_sell.g_pet_list, id)
end
function on_UI_Collect(data)
  g_collects.text = data:get(packet.key.item_count).v_int
end
function on_UI_SetBoxSize(data)
  local box = data:get(packet.key.item_box).v_int + bo2.eItemBox_Mall_Sell1
  local cnt = data:get(packet.key.itemdata_val).v_int
  local name = sys.format("box:%d", box)
  if box < bo2.eItemBox_Mall_Want then
    local box_panel = ui_mall.ui_shop_sell.w_main:search(name)
    ui_mall.box_resize(box_panel, 56, cnt)
  elseif box == bo2.eItemBox_Mall_Want then
    local box_panel = ui_mall.ui_shop_want.w_main:search(name)
    ui_mall.box_resize(box_panel, 36, cnt)
  end
end
function shop_data(cmd, data)
  local op = data:get(packet.key.cmn_type).v_int
  local fn = g_shop_update[op]
  if fn == nil then
    return
  end
  fn(data)
end
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_mall.ui_shop:on_signal"
reg(packet.eSTC_Mall_Shop, shop_data, sig)
function on_collect(ctrl)
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallShop_Collect)
  bo2.send_variant(packet.eCTS_UI_Mall_Shop, v)
end
function on_label_close(w)
  g_shop_labels[w] = nil
end
function on_label_init(w)
  local d = {
    top = w,
    name = w:search("mall_name"),
    lb1 = w:search("mall_lb1"),
    lb2 = w:search("mall_lb2")
  }
  g_shop_labels[w] = d
end
