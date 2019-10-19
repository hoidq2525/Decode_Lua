local ui_tab = ui_widget.ui_tab
local ui_shelf = ui_supermarket.ui_shelf
function on_close(ctrl)
  ctrl.parent.parent.visible = false
end
function on_visible(w, vis)
  local top_wnd = w.topper
  local major_wnd = top_wnd:search("express_major")
  local btn = top_wnd:search("express_btn")
  if vis then
    btn.enable = false
    top_wnd.dx = major_wnd.dx + w.dx + 2
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eSupermarket_BrowseExpress)
    v:set(packet.key.goods_page, top_wnd:search("express_panel").svar.page_id)
    bo2.send_variant(packet.eCTS_UI_Supermarket, v)
  else
    btn.enable = true
    top_wnd.dx = major_wnd.dx
  end
end
function on_click(btn)
  btn.topper:search("express_border").visible = true
end
function on_item_sel(ctrl)
  local view = ui_mall.find_parent(ctrl, L("view"))
  local item = view.svar.sel_item
  if item ~= nil then
    item:search("select").visible = false
    view.svar.sel_item = nil
  end
  if ctrl ~= nil then
    ctrl:search("select").visible = true
    view.svar.sel_item = ctrl
  end
end
function on_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_enter then
    on_item_sel(ctrl)
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_rbutton_click then
    local goodsID = ctrl:search("goods_icon").excel_id
    ui_shelf.req_buygoods(goodsID)
  end
end
function on_card_tip_show(tip)
  local stk = sys.mtf_stack()
  local stk_use
  ui_supermarket.make_goods_tip(tip, stk, stk_use)
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("supermarket|tip_lclick_buy"), ui_tool.cs_tip_color_operation)
  ui_tool.ctip_push_operation(stk, ui.get_text("supermarket|tip_rclick"))
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function insert_tab(wnd, name)
  local btn_uri = "$frame/supermarket/express.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/supermarket/express.xml"
  local page_sty = "exshelf_page"
  ui_tab.insert_suit(wnd, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(wnd, name)
  btn.text = ui.get_text("supermarket|" .. name)
  local page_wnd = ui_tab.get_page(wnd, name)
  if page_wnd == nil then
    return
  end
  page_wnd.name = name
  local page_data = {}
  rawset(_M, "d_" .. name, page_data)
  page_data.view = page_wnd:search("view")
  page_data.step = page_wnd:search("step")
  local list = {}
  page_data.list = list
  local page = {
    index = 0,
    count = 3,
    limit = 8
  }
  page_data.page = page
  local function on_page_step(var)
    page_data.page.index = var.index * page_data.page.limit
    ui_shelf.update_page(page_data)
  end
  ui_widget.ui_stepping.set_event(page_data.step, on_page_step)
end
function on_ClearExpress(data)
  local page_id = data:get(packet.key.goods_page).v_int
  local page_name = "d_express_" .. page_id .. "_"
  for i = 0, 2 do
    local page_data = rawget(_M, page_name .. i)
    if page_data ~= nil then
      ui_shelf.clear_page_data(page_data)
    end
  end
end
function on_AddExpressGoods(data)
  local goods_id = data:get(packet.key.cmn_id).v_int
  ui_shelf.add_goods_data(goods_id, data)
  local page_id = data:get(packet.key.goods_page).v_int
  local tab_id = data:get(packet.key.goods_search).v_int
  local page_name = "d_express_" .. page_id .. "_" .. tab_id
  local page_data = rawget(_M, page_name)
  if page_data ~= nil then
    ui_shelf.insert_to_page(page_data, data)
  end
end
