function on_init(ctrl)
  local c = w_main:search("mat_raw")
  local card = c:search("card")
  card.grid = bo2.eItemSlot_Avatar_Imprint
  card.box = bo2.eItemArray_InSlot
end
function on_card_chg()
  w_main:insert_post_invoke(do_raw_update, "ui_npcfunc.ui_impclear.do_raw_update")
end
function do_raw_update()
  impclear_ok.enable = false
  w_main:search("lb_money").money = 0
  local c = w_main:search("mat_raw")
  local card = c:search("card")
  local info = card.info
  if info == nil or info.excel == nil then
    c:search("lb_item").text = ""
    return
  end
  c:search("lb_item").color = ui.make_color(info.excel.plootlevel.color)
  c:search("lb_item").text = info.excel.name
  impclear_ok.enable = true
  w_main:search("lb_money").money = 50000
end
function on_ok(ctrl)
  local info = w_main:search("mat_raw"):search("card").info
  if info == nil then
    return
  end
  local send_impl = function()
    local v = sys.variant()
    v:set(packet.key.talk_excel_id, bo2.eNpcFunc_ClearImprint)
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
    w_main.visible = false
  end
  local cfm_text = ui.get_text("npcfunc|cfm_impclear")
  local arg = sys.variant()
  local item_name = sys.format("<fi:%s>", info.code)
  arg:set("item_name", item_name)
  local bdmoney = sys.format("<bm:%d>", w_main:search("lb_money").money)
  arg:set("bdmoney", bdmoney)
  ui_widget.ui_msg_box.show_common({
    text = sys.mtf_merge(arg, cfm_text),
    callback = function(ret)
      if ret.result == 1 then
        send_impl()
      end
    end
  })
end
function on_tip_show(tip)
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|impclear_cur_equip"), ui_tool.cs_tip_color_operation, ui_tool.cs_tip_a_add_m)
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_make_item_without_price(stk, excel, card.info)
  ui_tool.ctip_show(tip.owner, stk)
end
