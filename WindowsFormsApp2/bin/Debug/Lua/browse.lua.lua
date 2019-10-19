local ui_tab = ui_widget.ui_tab
local ui_combo = ui_widget.ui_combo_box
local g_mall_page = {}
local g_browse_update = {}
local g_view_idx = bo2.eMallList_Hot
local g_recv_idx = 0
local g_search_type = 0
local g_search_text = L("")
label_def = {
  label_0 = {
    pic = "$image/npcfunc/label_equip.png",
    text = ui.get_text("mall|tab_label0")
  },
  label_1 = {
    pic = "$image/npcfunc/label_pet.png",
    text = ui.get_text("mall|tab_label1")
  },
  label_2 = {
    pic = "$image/npcfunc/label_mat.png",
    text = ui.get_text("mall|tab_label2")
  },
  label_3 = {
    pic = "$image/mtf/pic_sel_1.png",
    text = ui.get_text("mall|tab_label3")
  },
  label_4 = {
    pic = "$image/npcfunc/label_misc.png",
    text = ui.get_text("mall|tab_label4")
  }
}
function on_init(ctrl)
  ui_tab.clear_tab_data(w_main)
  insert_tab("sell_page", "hot", bo2.eMallList_Hot)
  insert_tab("sell_page", "label0", bo2.eMallList_Equip)
  insert_tab("sell_page", "label1", bo2.eMallList_Pet)
  insert_tab("sell_page", "label2", bo2.eMallList_Material)
  insert_tab("sell_page", "label3", bo2.eMallList_Want)
  insert_tab("sell_page", "label4", bo2.eMallList_Groceries)
  insert_tab("transfer_page", "transfer", bo2.eMallList_Transfer)
  g_mall_page[bo2.eMallList_Transfer].p_insert = insert_transfer_leaf
  insert_tab("sell_page", "search", bo2.eMallList_UI_Search)
  insert_tab("sell_page", "collect", bo2.eMallList_UI_Collect)
  ui_tab.show_page(w_main, "hot", true)
  ui_widget.ui_stepping.set_event(g_step, on_refresh)
  local cb = w_main:search("cb_search")
  ui_combo.append(cb, {
    id = 0,
    text = ui.get_text("mall|search_shop")
  })
  ui_combo.append(cb, {
    id = 1,
    text = ui.get_text("mall|search_manager")
  })
  ui_combo.select(cb, 0)
  g_browse_update[bo2.eMallList_Equip] = on_InitList
  g_browse_update[bo2.eMallList_Pet] = on_InitList
  g_browse_update[bo2.eMallList_Material] = on_InitList
  g_browse_update[bo2.eMallList_Want] = on_InitList
  g_browse_update[bo2.eMallList_Groceries] = on_InitList
  g_browse_update[bo2.eMallList_Hot] = on_InitList
  g_browse_update[bo2.eMallList_Transfer] = on_InitList
  g_browse_update[bo2.eMallList_UI_Search] = on_InitList
  g_browse_update[bo2.eMallList_UI_Collect] = on_InitList
  g_browse_update[bo2.eMallList_UI_AddShop] = on_AddShop
  g_browse_update[bo2.eMallList_UI_DelShop] = on_DelShop
  g_browse_update[bo2.eMallList_UI_ShopCollect] = on_ShopCollect
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis then
    on_refresh(w)
  end
end
function insert_tab(page_sty, name, idx)
  local btn_uri = "$frame/mall/browse.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/mall/browse.xml"
  ui_tab.insert_suit(w_main, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_main, name)
  btn.text = ui.get_text("mall|tab_" .. name)
  btn.svar.id = idx
  btn:insert_on_click(on_tab_click)
  local root = ui_tab.get_page(w_main, name):search("shop_list")
  g_mall_page[idx] = {
    p_name = name,
    p_btn = btn,
    p_root = root,
    p_cur = 0,
    p_end = 0,
    p_insert = insert_sell_leaf
  }
end
function insert_sell_leaf(data)
  local root = g_mall_page[g_recv_idx].p_root
  local style_uri = L("$frame/mall/browse.xml")
  local leaf_name = L("shop_item")
  local leaf_item = root:item_append()
  leaf_item:load_style(style_uri, leaf_name)
  leaf_item.svar.id = data:get(packet.key.mall_shop_id).v_string
  local hot = data:get(packet.key.cmn_state).v_int
  if hot == 1 then
    leaf_item:search("name").color = ui.make_color("FFBA00")
  end
  leaf_item.svar.hot = hot
  leaf_item:search("name").text = data:get(packet.key.cmn_name).v_string
  leaf_item:search("manager").text = data:get(packet.key.cha_name).v_string
  leaf_item:search("collect").text = data:get(packet.key.item_count).v_int
  local label_id = data:get(packet.key.item_key1).v_int
  local def = label_def["label_" .. label_id]
  if def ~= nil then
    leaf_item:search("lb1").image = def.pic
    leaf_item:search("lb1"):find_plugin("tip").text = def.text
  else
    leaf_item:search("lb1").image = ""
    leaf_item:search("lb1"):find_plugin("tip").text = ""
  end
  label_id = data:get(packet.key.item_key2).v_int
  def = label_def["label_" .. label_id]
  if def ~= nil then
    leaf_item:search("lb2").image = def.pic
    leaf_item:search("lb2"):find_plugin("tip").text = def.text
  else
    leaf_item:search("lb2").image = ""
    leaf_item:search("lb2"):find_plugin("tip").text = ""
  end
end
function insert_transfer_leaf(data)
  local root = g_mall_page[g_recv_idx].p_root
  local style_uri = L("$frame/mall/browse.xml")
  local leaf_name = L("transfer_item")
  local leaf_item = root:item_append()
  leaf_item:load_style(style_uri, leaf_name)
  leaf_item.svar.id = data:get(packet.key.mall_shop_id).v_string
  local hot = data:get(packet.key.cmn_state).v_int
  if hot == 1 then
    leaf_item:search("name").color = ui.make_color("FFBA00")
  end
  leaf_item.svar.hot = hot
  leaf_item:search("name").text = data:get(packet.key.cmn_name).v_string
  leaf_item:search("manager").text = data:get(packet.key.cha_name).v_string
  leaf_item:search("collect").text = data:get(packet.key.item_count).v_int
  leaf_item:search("price").money = data:get(packet.key.cmn_money).v_int
end
function view_page(idx)
  g_view_idx = idx
  ui_tab.show_page(w_main, g_mall_page[idx].p_name, true)
  ui_widget.ui_stepping.set_page(g_step, g_mall_page[idx].p_cur, g_mall_page[idx].p_end)
end
function on_tab_click(btn)
  view_page(btn.svar.id)
  on_refresh(btn)
end
function on_refresh(ctrl)
  g_input.focus = false
  local var = g_step.svar.stepping
  local v = sys.variant()
  if g_view_idx == bo2.eMallList_UI_Search then
    if g_search_type == 0 then
      return
    end
    v:set(packet.key.cmn_type, g_search_type)
    v:set(packet.key.cmn_name, g_search_text)
  else
    v:set(packet.key.cmn_type, bo2.eMallEnter_Browse)
  end
  v:set(packet.key.cmn_index, g_view_idx)
  v:set(packet.key.mall_page_cur, var.index)
  local root = g_mall_page[g_view_idx].p_root.parent.parent:search("sort_title")
  local sort = root.svar.sort
  if sort ~= nil then
    v:set(packet.key.sort_name, sort.name)
    v:set(packet.key.sort_dir, sort.dir)
  end
  bo2.send_variant(packet.eCTS_UI_Mall_Enter, v)
end
function on_search(btn)
  if g_search_text.empty then
    return
  end
  local item = ui_combo.selected(w_main:search("cb_search"))
  if item ~= nil and item.id == 1 then
    g_search_type = bo2.eMallEnter_SearchManager
  else
    g_search_type = bo2.eMallEnter_SearchShop
  end
  view_page(bo2.eMallList_UI_Search)
  on_refresh(w_main)
end
function on_keydown_return(ctrl, key, keyflag)
  if key == ui.VK_RETURN and keyflag.down then
    on_search(ctrl)
  end
end
function on_input_change(tb, txt)
  g_search_text = g_input.text
  input_mask.visible = g_search_text.empty
end
function on_InitList(data)
  local idx = data:get(packet.key.cmn_type).v_int
  g_recv_idx = idx
  g_mall_page[idx].p_root:item_clear()
  g_mall_page[idx].p_cur = data:get(packet.key.mall_page_cur).v_int
  g_mall_page[idx].p_end = data:get(packet.key.mall_page_end).v_int
  view_page(idx)
end
function on_AddShop(data)
  g_mall_page[g_recv_idx].p_insert(data)
end
function on_DelShop(data)
  local id = data:get(packet.key.mall_shop_id).v_string
  local root = g_mall_page[g_view_idx].p_root
  for i = 0, root.item_count - 1 do
    local item = root:item_get(i)
    if item.svar.id == id then
      root:item_remove(i)
      return
    end
  end
end
function on_ShopCollect(data)
  local id = data:get(packet.key.mall_shop_id).v_string
  local root = g_mall_page[g_view_idx].p_root
  for i = 0, root.item_count - 1 do
    local item = root:item_get(i)
    if item.svar.id == id then
      item:search("collect").text = data:get(packet.key.item_count).v_int
      return
    end
  end
end
function browse_data(cmd, data)
  local op = data:get(packet.key.cmn_type).v_int
  local fn = g_browse_update[op]
  if fn == nil then
    return
  end
  fn(data)
end
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_mall.ui_browse:on_signal"
reg(packet.eSTC_Mall_Browse, browse_data, sig)
function on_shop_select(ctrl, vis)
  ctrl:search("select").visible = vis
  if vis then
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallEnter_Shop)
    v:set(packet.key.mall_shop_id, ctrl.svar.id)
    bo2.send_variant(packet.eCTS_UI_Mall_Enter, v)
  end
end
function on_item_select(ctrl, v)
  ctrl:search("select").visible = v
end
function on_req_sort(ctrl)
  ui_mall.on_click_sort_btn(ctrl)
  on_refresh(ctrl)
end
function on_collect(ctrl)
  local leaf_item = ui_mall.find_parent(ctrl, L("leaf_item"))
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallEnter_Collect)
  v:set(packet.key.mall_shop_id, leaf_item.svar.id)
  bo2.send_variant(packet.eCTS_UI_Mall_Enter, v)
end
function on_buy_shop(ctrl)
  local send_impl = function(leaf_item)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallEnter_BuyShop)
    v:set(packet.key.mall_shop_id, leaf_item.svar.id)
    v:set(packet.key.cmn_money, leaf_item:search("price").money)
    bo2.send_variant(packet.eCTS_UI_Mall_Enter, v)
  end
  local leaf_item = ui_mall.find_parent(ctrl, L("leaf_item"))
  ui_widget.ui_msg_box.show_common({
    text = sys.format(ui.get_text("mall|buyshop_confirm"), leaf_item:search("price").money, leaf_item:search("name").text),
    callback = function(ret)
      if ret.result == 1 then
        send_impl(leaf_item)
      end
    end
  })
end
