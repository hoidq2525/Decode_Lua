local ui_chat_list = ui_widget.ui_chat_list
function clear_data()
  ui_chat_list.clear(g_shop_news)
  g_shop_news:search("mask").visible = true
end
function on_news(data)
  local type = data:get(packet.key.org_newstype).v_int
  local time = data:get(packet.key.org_time).v_int
  local str = data:get(packet.key.org_szname1).v_string
  local news = sys.format(ui.get_text("mall|news_format"), os.date("%X", time), str)
  ui_chat_list.insert(g_shop_news, {text = news}, 0)
  g_shop_news:search("mask").visible = false
end
function send_leave_msg(btn)
  local txt = g_input.text
  if txt.empty then
    return
  end
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallShop_LeaveMsg)
  v:set(packet.key.chat_text, txt)
  bo2.send_variant(packet.eCTS_UI_Mall_Shop, v)
  g_input.text = nil
end
function on_keydown_return(ctrl, key, keyflag)
  if key == ui.VK_RETURN and keyflag.down then
    send_leave_msg(ctrl)
  end
end
