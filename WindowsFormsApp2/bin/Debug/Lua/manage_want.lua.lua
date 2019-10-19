function on_init(ctrl)
  local box_panel = w_main:search("want_panel")
  ui_mall.create_box(box_panel, 6, 6, "$frame/mall/manage_want.xml", bo2.eItemBox_Mall_Want)
  box_panel = w_main:search("acq_panel")
  ui_mall.create_box(box_panel, 6, 6, "$frame/mall/manage_want.xml", bo2.eItemBox_Mall_Acquire)
end
function MayWant(excel)
  if excel == nil or bo2.bit_and(excel.deal_type, bo2.DealTypeBit_Want) == 0 then
    return 72031
  end
  return 0
end
function req_upwant(grid, excel_id)
  local function send_impl(ctrl)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallManage_UpWant)
    v:set(packet.key.item_excelid, excel_id)
    v:set(packet.key.item_grid, grid)
    v:set(packet.key.item_count, 1)
    local money_ctrl = ctrl:search("money")
    local money = ui_widget.ui_money_box.get_money(money_ctrl)
    v:set(packet.key.cmn_money, money)
    local num_ctrl = ctrl:search("box_input")
    if num_ctrl then
      v:set(packet.key.item_count, num_ctrl.text.v_int)
    end
    bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  end
  local excel = ui.item_get_excel(excel_id)
  local rst = MayWant(excel)
  if rst ~= 0 then
    ui_mall.ui_manage_sell.notify(rst)
    return
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/mall/common.xml",
    style_name = "money_input_box",
    init = function(msg)
      local window = msg.window
      window:search("count_pn").visible = true
      window:search("box_input").text = 1
      local mtf = ui.get_text("mall|purchase_input")
      window:search("rv_text").mtf = mtf
      window:tune_y("rv_text")
    end,
    callback = function(msg)
      if msg.result == 1 then
        local window = msg.window
        send_impl(window)
      end
    end
  })
end
function req_downwant(grid)
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallManage_DownWant)
  v:set(packet.key.item_grid, grid)
  bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
end
function on_drop(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down then
    return
  end
  ui.clean_drop()
  if ui_widget.check_drop(data, ui_widget.c_drop_type_item) and card.box == bo2.eItemBox_Mall_Want then
    local item_info = ui.item_of_only_id(data:get("only_id").v_string)
    local want = MayWant(item_info.excel)
    if want == 0 then
      req_upwant(card.grid, item_info.excel_id)
    else
      ui_mall.ui_manage_sell.notify(want)
    end
  end
end
function on_mouse(card, msg, pos, wheel)
  local info = card.info
  if info == nil then
    return
  end
  if msg ~= ui.mouse_rbutton_click then
    return
  end
  if card.info ~= nil then
    if card.box == bo2.eItemBox_Mall_Want then
      req_downwant(card.grid)
    else
      ui_mall.ui_manage_sell.req_downgoods(card)
    end
  end
end
function on_card_tip_show(tip)
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item_without_price(stk, excel, card.info)
  if card.box == bo2.eItemBox_Mall_Want then
    ui_tool.ctip_push_text(stk, L("\n") .. ui.get_text("common|stall_purchase_tip"))
    stk:raw_format("<m:%d>", card.info:get_data_32(bo2.eItemUInt32_ShopPrice))
  end
  ui_tool.ctip_push_operation(stk, ui.get_text("common|stall_owner_clear"))
  local stk_use
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_clear(ctrl)
  local name = sys.format("box:%d", bo2.eItemBox_Mall_Want)
  local box_panel = w_main:search(name)
  local ctrl = box_panel.control_head
  while ctrl do
    local card = ctrl:search("card")
    if card.info ~= nil then
      req_downwant(card.grid)
    end
    ctrl = ctrl.next
  end
end
function on_takeall(ctrl)
  local name = sys.format("box:%d", bo2.eItemBox_Mall_Acquire)
  local box_panel = w_main:search(name)
  local ctrl = box_panel.control_head
  while ctrl do
    ui_mall.ui_manage_sell.req_downgoods(ctrl:search("card"))
    ctrl = ctrl.next
  end
end
function on_search(ctrl)
  local input = g_input.text
  if input.empty then
    return
  end
  local id = ui.itemid_of_name(input)
  if id == 0 then
    ui_mall.ui_manage_sell.notify(72131)
    return
  end
  local name = sys.format("box:%d", bo2.eItemBox_Mall_Want)
  local box_panel = w_main:search(name)
  local ctrl = box_panel.control_head
  while ctrl do
    local card = ctrl:search("card")
    if card.info == nil then
      req_upwant(card.grid, id)
      return
    end
    ctrl = ctrl.next
  end
  ui_mall.ui_manage_sell.notify(10247)
end
function on_keydown_return(ctrl, key, keyflag)
  if key == ui.VK_RETURN and keyflag.down and ui_tool.ui_search.get_visible() then
    g_input.text = ui_tool.ui_search.get_selected()
    ui_tool.ui_search.search_hide()
  else
  end
  if key == ui.VK_TAB and keyflag.down then
    g_input.text = ui_tool.ui_search.get_selected()
    ui_tool.ui_search.search_hide()
  end
  if key == ui.VK_UP and keyflag.down then
    ui_tool.ui_search.select_up()
  end
  if key == ui.VK_DOWN and keyflag.down then
    ui_tool.ui_search.select_down()
  end
end
function on_input_change(tb, txt)
  if txt.empty then
    ui_tool.ui_search.search_hide()
    return
  end
  local list = get_match_name(txt)
  local data = {
    btn = tb,
    input_ctrl = g_input,
    popup = "y2",
    list = list
  }
  ui_tool.ui_search.show_search(data)
  input_mask.visible = g_input.text.empty
end
function get_match_name(txt)
  local list = {}
  local size = bo2.gv_item_list.size
  for i = 0, size - 1 do
    local excel = bo2.gv_item_list:get(i)
    if MayWant(excel) == 0 and string.find(tostring(excel.name), tostring(txt)) ~= nil then
      table.insert(list, {
        name = excel.name
      })
    end
  end
  size = bo2.gv_quest_item.size
  for i = 0, size - 1 do
    local excel = bo2.gv_quest_item:get(i)
    if MayWant(excel) == 0 and string.find(tostring(excel.name), tostring(txt)) ~= nil then
      table.insert(list, {
        name = excel.name
      })
    end
  end
  size = bo2.gv_equip_item.size
  for i = 0, size - 1 do
    local excel = bo2.gv_equip_item:get(i)
    if MayWant(excel) == 0 and string.find(tostring(excel.name), tostring(txt)) ~= nil then
      table.insert(list, {
        name = excel.name
      })
    end
  end
  size = bo2.gv_gem_item.size
  for i = 0, size - 1 do
    local excel = bo2.gv_gem_item:get(i)
    if MayWant(excel) == 0 and string.find(tostring(excel.name), tostring(txt)) ~= nil then
      table.insert(list, {
        name = excel.name
      })
    end
  end
  return list
end
