if rawget(_M, "g_money_datas") == nil then
  g_money_datas = {}
end
function on_self_atb(obj, ft, idx)
  local m
  if idx == bo2.eFlagInt32_CirculatedMoney then
    m = "money"
  else
    m = "bmoney"
  end
  local c = obj:get_flag_int32(idx)
  for n, v in pairs(g_money_datas) do
    v[m].money = c
  end
end
function on_self_enter(obj, msg)
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.eFlagInt32_CirculatedMoney, on_self_atb, "ui_widget.ui_money_view.on_self_atb")
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.eFlagInt32_BoundedMoney, on_self_atb, "ui_widget.ui_money_view.on_self_atb")
  local money = obj:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
  local bmoney = obj:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
  for n, v in pairs(g_money_datas) do
    v.money.money = money
    v.bmoney.money = bmoney
  end
end
function on_view_close(w)
  g_money_datas[w] = nil
end
function on_make_tip(tip)
  local player = bo2.player
  local bounded = tip.owner.bounded
  local mt
  if bounded then
    mt = "bm"
  else
    mt = "m"
  end
  local m = 0
  if player ~= nil then
    local levelup = bo2.gv_player_levelup:find(player:get_atb(bo2.eAtb_Level))
    if levelup ~= nil then
      if bounded then
        m = levelup.max_money2
      else
        m = levelup.max_money1
      end
    end
  end
  local t = sys.format([[

%s<%s:%d>]], ui.get_text("widget|money_carry_limit"), mt, m)
  ui_widget.tip_make_view(tip.view, tip.text .. t)
end
function on_view_init(w)
  local d = {
    top = w,
    money = w:search("lb_money"),
    bmoney = w:search("lb_bmoney")
  }
  g_money_datas[w] = d
  local player = bo2.player
  if player ~= nil then
    d.money.money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    d.bmoney.money = player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
  end
  if bo2 ~= nil then
    bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_widget.ui_money_view.on_self_enter")
  end
end
if bo2 ~= nil then
  bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_widget.ui_money_view.on_self_enter")
end
