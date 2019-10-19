function on_click_btn(btn)
  local send_impl = function(cnt)
    local vset = sys.variant()
    vset:set(packet.key.cmn_money, cnt)
    bo2.send_variant(packet.eCTS_UI_PointCmd_Set, vset)
  end
  local vget = sys.variant()
  bo2.send_variant(packet.eCTS_UI_PointCmd_Get, vget)
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/supermarket/recharge.xml",
    style_name = "recharge_input_box",
    init = function(msg)
      local window = msg.window
      window:search("box_input").text = 1
      local mtf = ui.get_text("supermarket|recharge_text")
      window:search("rv_text").mtf = mtf
      window:tune_y("rv_text")
    end,
    callback = function(msg)
      if msg.result == 1 then
        local window = msg.window
        send_impl(window:search("box_input").text.v_int)
      end
    end
  })
end
function on_point(cmd, data)
  if g_input_wnd ~= nil and g_input_wnd.visible == true then
    g_input_wnd:search("point").text = data:get(packet.key.cmn_money).v_int
  end
end
local sig_name = "ui_supermarket.ui_recharge:on_signal"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_PointCmd_Rst_Get, on_point, sig_name)
