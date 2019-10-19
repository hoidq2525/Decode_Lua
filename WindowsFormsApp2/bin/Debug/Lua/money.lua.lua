local UpdateMoney = function()
  if bo2.player then
    local money = bo2.player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    w_gamemoneylb.money = money
    money = bo2.player:get_flag_int32(bo2.eFlagInt32_CirculatedJade)
    w_pixelmoneylb.text = money
  end
end
function money_Init()
  bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, function()
    bo2.player:insert_on_flagmsg(bo2.bo2.eFlagType_Int32, bo2.eFlagInt32_CirculatedMoney, UpdateMoney, "supermarket.money")
    bo2.player:insert_on_flagmsg(bo2.bo2.eFlagType_Int32, bo2.eFlagInt32_CirculatedJade, UpdateMoney, "supermarket.money")
  end, "supermarket.money")
end
function money_BuyJade()
  local msgbox = {
    detail_uri = "$frame/supermarket_v2/money.xml",
    detail = "buyjadebox",
    title = ui.get_text("supermarket|buyyb"),
    btn_confirm = true,
    btn_cancel = true
  }
  function msgbox.callback(rst)
    if rst.result == 1 then
      local n = w_jadebox_jadeqb.text.v_int
      moneyDirectBuyJade(n)
    end
  end
  ui_tool.show_msg(msgbox)
end
local get_recharge_url = function()
  local n = sys.xnode()
  n:load("$cfg/client/res.xml")
  local v = n:find("recharge")
  local url = v and v.inner_xml or L("")
  if bo2.get_zone() == L("ko_kr") or bo2.get_zone() == L("vi_vn") then
    url = url .. bo2.account()
  elseif bo2.get_zone() == L("zh_tw") then
    local ip = L("")
    local v = bo2.getcommandline()
    for i = 1, v.size - 1 do
      local s = tostring(v:get(i))
      if s == "-g" then
        ip = tostring(v:get(i + 1))
      end
    end
    url = url .. sys.format(L("?game_id=37&gameacc=%s&server=%s&charname=%s"), bo2.account(), ip, bo2.player.only_id)
  end
  return url
end
function money_BuyRMB(btn)
  local url = get_recharge_url()
  local cfg = bo2.get_config()
  local wnd = cfg:get("fullscreen").v_int
  local zone = bo2.get_zone()
  if wnd == 1 or zone ~= L("zh_cn") then
    ui.shell_execute("open", url)
    return
  end
  local parent = w_rmbMain:search("iewrap")
  local refresh, vis
  if btn.name == L("r") then
    vis = true
    refresh = true
  else
    vis = not w_rmbMain.visible
    refresh = vis and parent:search("ie_wnd") == nil
  end
  if refresh then
    parent:control_clear()
    local c = ui.create_control(parent, "wnd_html_view")
    c:load_style("$frame/supermarket_v2/supermarket.xml", "rmb_ie")
  end
  parent:search("ie_wnd"):set_url(url)
  w_rmbMain.visible = vis
  if vis then
    update_rmb_window()
  end
end
function update_rmb_window()
  if not w_rmbMain.visible then
    return
  end
  local ie_wnd = w_rmbMain:search("ie_wnd")
  if ie_wnd == nil then
    return
  end
  ie_wnd.pixel_size = ui.point(590, 416)
  local s = ie_wnd.size
  w_rmbMain.size = ui.point(s.x + 14, s.y + 40)
  ui.log("on_update_rmb_window : %f,%f", w_rmbMain.dx, w_rmbMain.dy)
end
function on_rmb_window_device_reset(ctrl)
  ctrl.visible = false
end
function moneyDirectBuyJade(n)
  local v = sys.variant()
  if n <= 0 then
    return
  end
  v:set(packet.key.buy_jade, n)
  v:set(packet.key.cmn_money, n)
  v:set(packet.key.multi_goods, "0*" .. n)
  v:set(packet.key.cmn_type, bo2.eSupermarket_BuyJade)
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
end
g_rate = 1
function money_UpdateBoxJade()
  w_jadebox_rate.text = "1:" .. g_rate
  w_jadebox_qb.text = w_qqmoneylb.text
  local n = tonumber(tostring(w_jadebox_jadeqb.text))
  local allCnt = tonumber(tostring(w_jadebox_qb.text))
  if n == 0 then
    n = 1
  end
  if allCnt < n then
    n = allCnt
  end
  w_jadebox_jade.text = n * g_rate
  w_jadebox_jadeqb.text = n
end
if rawget(_M, "g_rmb") == nil then
  g_rmb = 0
end
local reg = ui_packet.recv_wrap_signal_insert
reg(packet.eSTC_SupermarketRMB, function(cmd, data)
  local m = data:get(packet.key.rmb_amount).v_int
  w_qqmoneylb.text = m
  g_rmb = m
  local w_remake_main = ui_npcfunc.ui_remake.w_main
  if sys.check(w_remake_main) and w_remake_main.visible then
    ui_npcfunc.ui_remake.w_btn_remake_enable()
  end
end, "supermarket.money")
reg(packet.eSTC_Supermarket, function(cmd, data)
  if data:get(packet.key.cmn_type).v_int == bo2.eSupermarketUI_Announce then
    g_rate = data[packet.key.rmb_info]
    UpdateMoney()
  end
end, "supermarket.money")
local _refreshTime = os.time()
function money_refreshQB()
  if os.difftime(os.time(), _refreshTime) > 5 then
    _refreshTime = os.time()
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eSupermarket_Browse)
    v:set(packet.key.player_view_flag, 1)
    bo2.send_variant(packet.eCTS_UI_Supermarket, v)
  end
end
