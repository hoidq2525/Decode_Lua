function on_init(ctrl)
  local box_panel = w_main:search("want_panel")
  ui_mall.create_box(box_panel, 6, 6, "$frame/mall/shop_want.xml", bo2.eItemBox_Mall_Want)
end
function req_sellwant(card)
  local function send_impl(cnt, only_id)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallShop_SellWant)
    v:set(packet.key.item_key, only_id)
    v:set(packet.key.item_count, cnt)
    v:set(packet.key.item_excelid, card.excel_id)
    local price = card.info:get_data_32(bo2.eItemUInt32_ShopPrice)
    local money = price * cnt
    v:set(packet.key.cmn_money, money)
    v:set(packet.key.item_key1, card.only_id)
    bo2.send_variant(packet.eCTS_UI_Mall_Shop, v)
  end
  if card == nil or card.info == nil then
    return
  end
  local item_info = ui.item_of_excel_id(card.excel_id, bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
  if item_info == nil then
    return
  end
  local reqcnt = card.info.count
  local cnt = item_info.count
  if reqcnt < cnt then
    cnt = reqcnt
  end
  if cnt == 1 then
    send_impl(1, item_info.only_id)
  else
    ui_widget.ui_msg_box.show_common({
      text = ui.get_text("common|stall_get_purchase"),
      input = cnt,
      callback = function(ret)
        if ret.result == 1 then
          send_impl(ret.input.v_int, item_info.only_id)
        end
      end
    })
  end
end
function on_mouse(card, msg, pos, wheel)
  local info = card.info
  if info == nil then
    return
  end
  if msg == ui.mouse_rbutton_click then
    req_sellwant(card)
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
  ui_tool.ctip_push_text(stk, L("\n") .. ui.get_text("common|stall_purchase_tip"))
  stk:raw_format("<m:%d>", card.info:get_data_32(bo2.eItemUInt32_ShopPrice))
  ui_tool.ctip_push_operation(stk, ui.get_text("common|stall_viewer_get"))
  local stk_use
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
