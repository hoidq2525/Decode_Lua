g_page = 0
g_maxpage = 0
g_playerCount = 0
g_cts_ui_cmn = packet.eCTS_UI_ArenaViewerListReq
g_arena_id = 0
function getIntPart(x)
  if x <= 0 then
    return math.ceil(x)
  end
  if math.ceil(x) == x then
    x = math.ceil(x)
  else
    x = math.ceil(x) - 1
  end
  return x
end
function requestViewerPage()
  update_btn_enable()
  local v = sys.variant()
  v:set(packet.key.request_page, page)
  v:set(packet.key.arena_id, g_arena_id)
  bo2.send_variant(g_cts_ui_cmn, v)
end
function OpenViewerPage(cmn, arena_id)
  if gx_mainWin.visible == true then
    gx_mainWin.visible = false
    return
  end
  g_page = 0
  g_maxpage = 0
  g_playerCount = 0
  g_cts_ui_cmn = cmn
  g_arena_id = arena_id
  requestViewerPage()
end
function RenderViewPlayerItem(item, var)
  local name = var:get(packet.key.cha_name).v_string
  local level = var:get(packet.key.cha_level).v_int
  local career = var:get(packet.key.player_profession).v_int
  item:search("player_name").text = name
  item:search("level").text = sys.format("LV%d", level)
  local cline = bo2.gv_profession_list:find(career)
  if cline then
    item:search("job").text = cline.name
  else
    item:search("job").text = career
  end
end
function OnRecvViewerData(data)
  local players = data:get(packet.key.arena_players)
  g_playerCount = players.size
  data:set("count", g_playerCount)
  gx_playerCount.text = sys.mtf_merge(data, ui.get_text("match|viewer_count"))
  g_maxpage = getIntPart(g_playerCount / 10)
  gx_viewerlist:item_clear()
  for i = 0, players.size - 1 do
    local playerData = players:fetch_v(i)
    local item = gx_viewerlist:item_append()
    item:load_style("$frame/match/viewlist.xml", "view_player_item")
    RenderViewPlayerItem(item, playerData)
  end
  gx_mainWin:search("lb_text").text = sys.format("%d/%d", g_page + 1, g_maxpage + 1)
  update_btn_enable()
  gx_mainWin.visible = true
end
function update_btn_enable()
  local btn_head = true
  local btn_foot = true
  local btn_prev = true
  local btn_next = true
  if g_page == g_maxpage then
    btn_next = false
    btn_foot = false
  end
  if g_page == 0 then
    btn_head = false
    btn_prev = false
  end
  gx_mainWin:search("btn_head").enable = btn_head
  gx_mainWin:search("btn_foot").enable = btn_foot
  gx_mainWin:search("btn_prev").enable = btn_prev
  gx_mainWin:search("btn_next").enable = btn_next
end
function on_stepping_head(btn)
  g_page = 0
  requestViewerPage()
end
function on_stepping_foot(btn)
  g_page = g_maxpage
  requestViewerPage()
end
function on_stepping_prev(btn)
  g_page = g_page - 1
  requestViewerPage()
end
function on_stepping_next(btn)
  g_page = g_page + 1
  requestViewerPage()
end
