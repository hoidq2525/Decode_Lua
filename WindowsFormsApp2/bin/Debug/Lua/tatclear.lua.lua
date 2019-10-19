function on_init(ctrl)
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis then
    local bdExcel = ui_personal.ui_tattoo.get_board_excel()
    if bdExcel ~= nil then
      tatclear_ok.enable = true
      w_main:search("lb_money").money = bdExcel.clear_money
    else
      w_main:search("lb_money").money = 0
      tatclear_ok.enable = false
    end
  else
    if w.var:get("server_close_talk").v_int == 1 then
      return
    end
    local d = sys.variant()
    d:set("kind", bo2.eTalkSel_Null)
    d:set("id", 1)
    bo2.send_wrap(packet.eSTC_Fake_talk_sel, d)
  end
end
function on_ok(ctrl)
  local send_impl = function()
    local v = sys.variant()
    v:set(packet.key.talk_excel_id, bo2.eNpcFunc_ClearTattoo)
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
    w_main.visible = false
  end
  local cfm_text = ui.get_text("npcfunc|cfm_tatclear")
  local arg = sys.variant()
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
