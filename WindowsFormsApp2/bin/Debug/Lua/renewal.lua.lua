local ui_combo = ui_widget.ui_combo_box
local g_renewals
function on_init(ctrl)
  renewal_ok.enable = true
end
function on_ok(ctrl)
  local info = w_main:search("mat_raw"):search("card").info
  if info == nil then
    return
  end
  local cb = w_main:search("cb_days")
  local item = ui_combo.selected(cb)
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eSupermarket_BuyRenewal)
  v:set(packet.key.item_key, info.only_id)
  v:set(packet.key.item_excelid, info.excel_id)
  v:set(packet.key.cmn_id, g_renewals:get(item.id).v_int)
  v:set(packet.key.cmn_money, g_renewals:get(item.id + 1).v_int)
  v:set(packet.key.goods_days, g_renewals:get(item.id + 2).v_int)
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
  ui_widget.on_close_click(ctrl)
end
function on_day_select(item)
  w_main:search("price").mtf = sys.format(ui.get_text("supermarket|goods_lb_curprice"), g_renewals:get(item.id + 1).v_int)
end
function on_OpenRenewal(data)
  local only_id = data:get(packet.key.item_key).v_string
  local info = ui.item_of_only_id(only_id)
  if info == nil then
    return
  end
  ui_npcfunc.ui_cell.drop(w_main:search("mat_raw"), info)
  local szText = data:get(packet.key.multi_goods)
  g_renewals = szText:split_to_int_array("*")
  local cb = w_main:search("cb_days")
  ui_combo.clear(cb)
  for i = 0, g_renewals.size - 1, 3 do
    local days = g_renewals:get(i + 2).v_int
    if days > 0 then
      ui_combo.append(cb, {
        id = i,
        text = sys.format(ui.get_text("supermarket|days_lb"), days)
      })
    else
      ui_combo.append(cb, {
        id = i,
        text = ui.get_text("supermarket|days_forever")
      })
    end
  end
  ui_combo.select(cb, 0)
  cb.svar.on_select = on_day_select
  cb.svar.on_select(ui_combo.selected(cb))
  w_main.visible = true
end
