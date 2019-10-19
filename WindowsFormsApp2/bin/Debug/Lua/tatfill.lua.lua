local g_rawcard
function on_init(ctrl)
  g_rawcard = nil
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  local bw = ui.find_control("$frame:personal")
  bw.visible = vis
  if vis then
    ui_widget.ui_tab.show_page(bw, "tattoo", false)
    ui_widget.ui_tab.show_page(bw, "tattoo", true)
  else
    ui_widget.ui_tab.show_page(bw, "equip", true)
    clear_rawcard()
    if w.var:get("server_close_talk").v_int == 1 then
      return
    end
    local d = sys.variant()
    d:set("kind", bo2.eTalkSel_Null)
    d:set("id", 1)
    bo2.send_wrap(packet.eSTC_Fake_talk_sel, d)
  end
end
function set_rawcard(newcard)
  if newcard.lock_id ~= 0 then
    return
  end
  clear_rawcard()
  g_rawcard = newcard
  g_rawcard.lock_id = bo2.eItemLock_Drop
  on_rawcard_chg()
end
function clear_rawcard()
  if g_rawcard ~= nil then
    if g_rawcard.lock_id == bo2.eItemLock_Drop then
      g_rawcard.lock_id = 0
    end
    g_rawcard = nil
    on_rawcard_chg()
  end
end
function on_rawcard_chg()
  if g_rawcard == nil then
    w_main:search("lb_money").money = 0
    tatfill_ok.enable = false
    return
  end
  tatfill_ok.enable = true
  local tatExcel = bo2.gv_tattoo_variety:find(g_rawcard.excel.variety)
  if tatExcel == nil then
    return
  end
  w_main:search("lb_money").money = tatExcel.money
end
function on_ok(ctrl)
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_FillTattoo)
  v:set(packet.key.item_key, g_rawcard.excel_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  clear_rawcard()
end
