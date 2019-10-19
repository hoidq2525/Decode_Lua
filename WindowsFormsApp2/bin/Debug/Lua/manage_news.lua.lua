local ui_chat_list = ui_widget.ui_chat_list
function clear_data()
  ui_chat_list.clear(g_deal_news)
  ui_chat_list.clear(g_clerk_news)
  g_deal_news:search("mask").visible = true
  g_clerk_news:search("mask").visible = true
end
function on_news(data)
  local time = data:get(packet.key.org_time).v_int
  local str = data:get(packet.key.org_szname1).v_string
  local news = sys.format(ui.get_text("mall|news_format"), os.date("%X", time), str)
  local type = data:get(packet.key.org_newstype).v_int
  if type == bo2.eMallNews_Deal then
    ui_chat_list.insert(g_deal_news, {text = news}, 0)
    g_deal_news:search("mask").visible = false
  elseif type == bo2.eMallNews_Clerk then
    ui_chat_list.insert(g_clerk_news, {text = news}, 0)
    g_clerk_news:search("mask").visible = false
  end
end
function on_clear(data)
  local type = data:get(packet.key.org_newstype).v_int
  if type == bo2.eMallNews_Deal then
    ui_chat_list.clear(g_deal_news)
    g_deal_news:search("mask").visible = true
  elseif type == bo2.eMallNews_Clerk then
    ui_chat_list.clear(g_clerk_news)
    g_clerk_news:search("mask").visible = true
  end
end
function on_clear_deal_news(ctrl)
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallManage_ClearNews)
  v:set(packet.key.org_newstype, bo2.eMallNews_Deal)
  bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
end
function on_clear_clerk_news(ctrl)
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallManage_ClearNews)
  v:set(packet.key.org_newstype, bo2.eMallNews_Clerk)
  bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
end
