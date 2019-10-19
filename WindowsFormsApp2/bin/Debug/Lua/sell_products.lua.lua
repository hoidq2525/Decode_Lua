local sell_max = 0
index_product_id = 1
index_item_id = 2
function on_init(ctrl)
  ui.console_print("on_init")
  local uri = "$frame/guildfarm/sell_products.xml"
  local style = "product_info"
  cur_row = w_product_list:item_append()
  cur_row:load_style(uri, style)
  cur_row = w_product_list:item_append()
  cur_row:load_style(uri, style)
  cur_row = w_product_list:item_append()
  cur_row:load_style(uri, style)
  cur_row = w_product_list:item_append()
  cur_row:load_style(uri, style)
  cur_row = w_product_list:item_append()
  cur_row:load_style(uri, style)
  cur_row = w_product_list:item_append()
  cur_row:load_style(uri, style)
  cur_row = w_product_list:item_append()
  cur_row:load_style(uri, style)
  cur_row = w_product_list:item_append()
  cur_row:load_style(uri, style)
  cur_row = w_product_list:item_append()
  cur_row:load_style(uri, style)
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  local stk = sys.mtf_stack()
  if excel == nil then
    ui_tool.ctip_show(card, nil)
    return
  else
    ui_tool.ctip_make_item(stk, excel, card.info)
  end
  local stk_use
  local info = card.info
  local operation_count = 0
  local function push_operation(txt)
    if operation_count == 0 then
      operation_count = 1
      ui_tool.ctip_push_sep(stk)
    else
      ui_tool.ctip_push_newline(stk)
    end
    ui_tool.ctip_push_text(stk, txt, ui_tool.cs_tip_color_operation)
  end
  ui_tool.ctip_show(card, stk, stk_use)
end
function on_confirm_click(btn)
  local selected_item = w_product_list.item_sel
  local item_name = L("<i:") .. selected_item.var:get(index_item_id).v_int .. L(">")
  local item_num_max = ui.item_get_count(selected_item.var:get(index_item_id).v_int, true)
  local player = bo2.player
  local sell_num = player:get_flag_int32(bo2.ePlayerFlagInt32_GFarmAccountTime)
  local max_sell_num = player:get_flag_int16(bo2.ePlayerFlagInt16_FarmSellNumMax)
  sell_max = max_sell_num - sell_num
  if item_num_max < sell_max then
    sell_max = item_num_max
  end
  local can_sell_num = sell_max
  local confirm_text = ui.get_text("sociality|can_sell_begin") .. can_sell_num .. ui.get_text("sociality|sell_product_already_have_end") .. item_name
  confirm_text = confirm_text .. ui.get_text("sociality|can_sell_mid") .. item_num_max .. ui.get_text("sociality|can_sell_end")
  w_sell_confirm:search("tip").mtf = confirm_text
  w_sell_confirm.var = selected_item.var
  w_input.text = "0"
  w_sell_confirm.visible = true
end
function on_cancel_click(btn)
  w_main.visible = false
end
function product_highlight(ctrl, is_highlight)
  local hl = ctrl:search("high_light")
  if hl ~= nil then
    hl.visible = is_highlight
  end
end
function on_product_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_enter then
    product_highlight(ctrl, true)
  elseif msg == ui.mouse_leave then
    product_highlight(ctrl, false)
  elseif msg == ui.mouse_lbutton_dbl then
    on_confirm_click(nil)
  end
end
function on_product_select(item, is_select)
  item:search("select_high_light").visible = is_select
  btn_confirm.enable = true
end
function on_plus_click(btn)
  local text = w_input.text
  local num = tonumber(tostring(text))
  num = num + 1
  local item_id = w_sell_confirm.var:get(index_item_id).v_int
  local max_count = ui.item_get_count(item_id, true)
  local can_sell_num = sell_max
  if max_count > can_sell_num then
    max_count = can_sell_num
  end
  if num > max_count then
    num = max_count
  end
  w_input.text = num
end
function on_minus_click(btn)
  local text = w_input.text
  local num = tonumber(tostring(text))
  num = num - 1
  if num <= 0 then
    num = 0
  end
  w_input.text = num
end
function on_max_click(btn)
  local player = bo2.player
  local item_id = w_sell_confirm.var:get(index_item_id).v_int
  local max_count = ui.item_get_count(item_id, true)
  local sell_num = player:get_flag_int32(bo2.ePlayerFlagInt32_GFarmAccountTime)
  local max_sell_num = player:get_flag_int16(bo2.ePlayerFlagInt16_FarmSellNumMax)
  local can_sell_num = max_sell_num - sell_num
  if max_count > can_sell_num then
    max_count = can_sell_num
  end
  w_input.text = max_count
end
function on_min_click(btn)
  local item_id = w_sell_confirm.var:get(index_item_id).v_int
  local max_count = ui.item_get_count(item_id, true)
  if max_count > 0 then
    w_input.text = 1
  else
    w_input.text = 0
  end
end
function on_sell_confirm_click(btn)
  local v = sys.variant()
  v:set(packet.key.farm_product_id, w_sell_confirm.var:get(index_product_id).v_int)
  v:set(packet.key.farm_item_id, w_sell_confirm.var:get(index_item_id).v_int)
  v:set(packet.key.farm_product_num, w_input.text)
  bo2.send_variant(packet.eCTS_UI_GuildFarm_SellProduct, v)
  w_sell_confirm.visible = false
end
function on_sell_cancel_click(btn)
  w_sell_confirm.visible = false
end
function on_sell_confirm_visible(w, vis)
  if vis == true then
    w_modal_bg.visible = true
  else
    w_modal_bg.visible = false
  end
end
function on_num_check(tb, txt)
  if tonumber(tostring(w_sell_confirm:search("sell_num").text)) ~= nil and tonumber(tostring(w_sell_confirm:search("sell_num").text)) > sell_max then
    w_sell_confirm:search("sell_num").text = sell_max
  end
end
function show_sell_products(data)
  local products_table = bo2.gv_gfarm_products
  local size = products_table.size
  local pop_product_id = data:get(packet.key.farm_pop_productid).v_int
  local pop_product_num = data:get(packet.key.farm_pop_productnum).v_int
  if pop_product_num == 0 then
    pop_product_id = 0
  end
  local uri = "$frame/guildfarm/sell_products.xml"
  local style = "product_info"
  w_product_list:item_clear()
  btn_confirm.enable = false
  for i = 0, size - 1 do
    local line = products_table:get(i)
    local id = line.id
    local low_quality_item = line.low_quality_item_id
    local low_quality_price = line.low_quality_item_price
    local high_quality_item = line.high_quality_item_id
    local high_quality_price = line.high_quality_item_price
    local low_quality_item_line = bo2.gv_item_list:find(low_quality_item)
    local low_quality_item_name = low_quality_item_line.name
    local high_quality_item_line = bo2.gv_item_list:find(high_quality_item)
    local high_quality_item_name = high_quality_item_line.name
    local pop_text = ui.get_text("sociality|product_normal")
    if pop_product_id == id then
      pop_text = ui.get_text("sociality|product_pop_num_beg") .. pop_product_num
      low_quality_price = low_quality_price * 2
      high_quality_price = high_quality_price * 2
    else
      pop_text = ui.get_text("sociality|product_pop_num_beg") .. ui.get_text("sociality|product_pop_num_unlimit")
    end
    local low_quality_row = w_product_list:item_append()
    low_quality_row:load_style(uri, style)
    low_quality_row:search("name").text = low_quality_item_name
    low_quality_row:search("price").money = low_quality_price
    low_quality_row:search("popular_num").text = pop_text
    low_quality_row:search("card").excel_id = low_quality_item
    low_quality_row.var:set(index_product_id, id)
    low_quality_row.var:set(index_item_id, low_quality_item)
    if pop_product_id == id then
      low_quality_row:search("popular_pic").visible = true
      low_quality_row:search("popular_text").visible = true
    end
    if 1 == bo2.gv_define_org:find(115).value.v_int then
      low_quality_row:search("price").bounded = true
    end
    if 0 < ui.item_get_count(low_quality_item, true) then
      low_quality_row:search("no_item").visible = false
    end
    local high_quality_row = w_product_list:item_append()
    high_quality_row:load_style(uri, style)
    high_quality_row:search("name").text = high_quality_item_name
    high_quality_row:search("price").money = high_quality_price
    high_quality_row:search("popular_num").text = pop_text
    high_quality_row:search("card").excel_id = high_quality_item
    high_quality_row.var:set(index_product_id, id)
    high_quality_row.var:set(index_item_id, high_quality_item)
    if pop_product_id == id then
      high_quality_row:search("popular_pic").visible = true
      high_quality_row:search("popular_text").visible = true
    end
    if 1 == bo2.gv_define_org:find(115).value.v_int then
      high_quality_row:search("price").bounded = true
    end
    if 0 < ui.item_get_count(high_quality_item, true) then
      high_quality_row:search("no_item").visible = false
    end
  end
  w_main.visible = true
end
