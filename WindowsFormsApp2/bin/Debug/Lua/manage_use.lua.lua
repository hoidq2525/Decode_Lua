function req_upusing(card, only_id)
  local function send_impl()
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallManage_UpUsing)
    v:set(packet.key.item_key, only_id)
    v:set(packet.key.item_count, 1)
    v:set(packet.key.item_grid, card.grid)
    bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  end
  local item_info = ui.item_of_only_id(only_id)
  if card.info == nil then
    send_impl()
  else
    local item_old = sys.format("<fi:%s>", card.info.code)
    local item_new = sys.format("<fi:%s>", item_info.code)
    local arg = sys.variant()
    arg:set("item_old", item_old)
    arg:set("item_new", item_new)
    ui_widget.ui_msg_box.show_common({
      text = sys.mtf_merge(arg, ui.get_text("mall|upuse_confirm")),
      callback = function(ret)
        if ret.result == 1 then
          send_impl()
        end
      end
    })
  end
end
function on_drop(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down then
    return
  end
  ui.clean_drop()
  if ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    req_upusing(card, data:get("only_id"))
  end
end
function on_card_tip_show(tip)
  local card = tip.owner:search("card")
  local excel = card.excel
  local stk = sys.mtf_stack()
  ui_tool.ctip_push_text(stk, ui.get_text(sys.format(L("mall|slot%d"), card.grid)), nil, "<a+:m>")
  if excel ~= nil then
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_make_item_without_price(stk, excel, card.info)
  end
  ui_tool.ctip_show(card, stk)
end
