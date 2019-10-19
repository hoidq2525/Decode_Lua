local cardPos = {
  {x = 303, y = 50},
  {x = 410, y = 129},
  {x = 370, y = 254},
  {x = 235, y = 254},
  {x = 196, y = 129},
  mid = {x = 303, y = 153}
}
local ringAngle2Card = {
  0,
  75,
  145,
  215,
  285
}
discountTb = {}
local ringRun = false
local requestSvr = false
function discountClickRing(btn, imm)
  if ringRun then
    return
  end
  local function run()
    if not discountPrepareGoods(run) then
      return
    end
    ringRun = true
    w_discountRing.visible = true
    local data = discountLoadCards()
    for i = 1, 5 do
      local ai = math.random(1, #data)
      local bi = math.random(1, #data)
      local a = data[ai]
      local b = data[bi]
      data[ai] = b
      data[bi] = a
    end
    for i = 1, 5 do
      local item = data[i]
      item.ctrl:move_to_tail()
    end
    discountPlay(data)
  end
  if imm then
    run()
    return
  end
  if bo2.player then
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eSupermarket_Discount)
    v:set(packet.key.cmn_system_flag, btn.name)
    bo2.send_variant(packet.eCTS_UI_Supermarket, v)
    requestSvr = true
  else
    run()
  end
end
g_ringPower = 0
function discount_updateBtns()
  g_ringPower = 0
  local cmn = bo2.is_cooldown_over(50078)
  if cmn then
    g_ringPower = g_ringPower + 1
  end
  w_discountRingBtn.enable = cmn
  if not bo2.player then
    return
  end
  local bluevip = bo2.is_cooldown_over(50080) and 0 < bo2.player:get_player_dwordtemp(bo2.ePFlagDwordTemp_BlueDiamond)
  if bluevip then
    g_ringPower = g_ringPower + 1
  end
  w_discountRingBtnBlue.enable = bluevip
  local qqvip = bo2.is_cooldown_over(50079) and 0 < bo2.player:get_player_dwordtemp(bo2.ePFlagDwordTemp_QQVIP)
  if qqvip then
    g_ringPower = g_ringPower + 1
  end
  w_discountRingBtnQQ.enable = qqvip
  if bo2.get_zone() ~= L("zh_cn") then
    w_discountRingBtnBlue.visible = false
    w_discountRingBtnQQ.visible = false
  end
end
function discountInit()
  local tmp = {}
  discountTb = {}
  local function refresh()
    local str = bo2.player:get_flag_string(bo2.ePlayerStringFlag_SupermarketDiscount)
    if not str.empty and w_discount.visible then
      if g_ringPower > 0 and requestSvr then
        discountClickRing(w_discountRingBtn, true)
        requestSvr = false
      elseif not ringRun then
        discountOnVisible(nil, true)
      end
    end
    if str.empty then
      ringRun = false
      w_discountItemParent:control_clear()
      w_discountHighLi.visible = false
      g_discountSelect = nil
    end
  end
  bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, function()
    bo2.player:insert_on_flagmsg(bo2.eFlagType_String, bo2.ePlayerStringFlag_SupermarketDiscount, refresh, "discount")
  end, "discount")
  local arr = {
    5,
    7,
    8,
    6,
    8
  }
  for i = 1, 5 do
    w_discount:search("discount" .. i).mtf = ui_widget.merge_mtf({
      discount = arr[i]
    }, ui.get_text("supermarket|discountLb"))
  end
end
function discountPrepareGoods(fn)
  local str = bo2.player:get_flag_string(bo2.ePlayerStringFlag_SupermarketDiscount)
  if str.empty then
    return true
  end
  local arr = {
    str:split("*")
  }
  local num = 0
  for i = 1, 5 do
    local itemid = arr[i].v_int
    local item = itembox_FindItem(itemid)
    if itemid > 0 and not item then
      num = num + 1
      local tag = "supermarket2.discount" .. itemid
      shelf_queryItem1(itemid, function()
        num = num - 1
        if num == 0 then
          fn()
        end
      end, tag, w_discountRingBtn)
    end
  end
  return num == 0
end
function discountLoadCards()
  w_discountHighLi.visible = false
  g_discountSelect = nil
  w_discountItemParent:control_clear()
  local items = {}
  if bo2.player then
    local str = bo2.player:get_flag_string(bo2.ePlayerStringFlag_SupermarketDiscount)
    local arr = {
      str:split("*")
    }
    for i = 1, 5 do
      local vi = arr[i].v_int
      local item = itembox_FindItem(vi, nil) or itembox_FindItem(vi, 1) or {}
      table.insert(items, item)
    end
  else
    items = {
      nil,
      nil,
      nil,
      nil,
      nil
    }
  end
  local data = {}
  for i = 1, 5 do
    local item = items[i]
    if not item or item.id then
      local wrapItem = {}
      item = item or {
        icon = "yd/yd0002",
        items = {}
      }
      setmetatable(wrapItem, {__index = item})
      local ctrl = ui.create_control(w_discountItemParent, "panel")
      ctrl:load_style("$frame/supermarket_v2/discount.xml", "itembox")
      ctrl.offset = ui.point(cardPos.mid.x, cardPos.mid.y)
      itembox_Show(ctrl, wrapItem, true)
      table.insert(data, {ctrl = ctrl, idx = i})
      ctrl:search("icon"):insert_on_mouse(discountClickCard)
    end
  end
  return data
end
function discountClickCard(icon, msg)
  if ringRun then
    return
  end
  if msg == ui.mouse_lbutton_down then
    w_discountHighLi.offset = icon.parent.offset
    w_discountHighLi.visible = true
    g_discountSelect = icon.svar
  end
end
function discountClickBuy()
  if g_discountSelect then
    ui_widget.ui_msg_box.show_common({
      text = ui_widget.merge_mtf({
        discount = g_discountSelect.discount,
        item = g_discountSelect.name
      }, ui.get_text("supermarket|buyDiscountTip")),
      callback = function(rst)
        if rst.result == 1 then
          local dummy = {svar = g_discountSelect}
          if not g_discountSelect.vip then
            shelf_BuyGood(dummy)
          else
            shelf_BuyBJGood(dummy)
          end
        end
      end,
      modal = true
    })
  end
end
function discountOnVisible(w, vis)
  if vis and bo2.player and not ringRun then
    local str = bo2.player:get_flag_string(bo2.ePlayerStringFlag_SupermarketDiscount)
    if not str.empty then
      if not discountPrepareGoods(function()
        discountOnVisible(w, vis)
      end) then
        return
      end
      local data = discountLoadCards()
      for _i, v in ipairs(data) do
        local pos = cardPos[v.idx]
        v.ctrl.offset = ui.point(pos.x, pos.y)
        v.ctrl:search("icon").svar.discount = discountTb[v.idx] or 10
      end
      w_discountRing.visible = false
    end
    w_discountFlicker.visible = false
    w_discountFlicker.suspended = true
    ringRun = false
  end
  if not vis then
    w_submv:frame_clear()
    w_submv.visible = true
    local f = w_submv:frame_insert(200, w_discount)
    f:set_scale2(0.1, 0.1)
    f = w_submv:frame_insert(300, w_discount)
    f:set_scale1(0.1, 0.1)
    f:set_scale2(0.06, 0.06)
    local x = w_main.x + w_main.dx - w_submv.dx / 2
    local y = w_main.y - w_submv.dy / 2
    f:set_translate2(x - 40, y + 40)
  end
end
function discountPlay(data)
  if #data <= 0 or not ringRun then
    ringRun = false
    return
  end
  local item = data[1]
  table.remove(data, 1)
  discountRingTo(item.idx, function()
    if #data > 1 then
      discountMoveItem(item, nil)
      discountPlay(data)
    else
      discountMoveItem(item, data[1])
    end
  end)
end
function discountMoveItem(item, nextItem)
  local pt = cardPos[item.idx]
  w_discountItemMv.visible = true
  local f = w_discountItemMv:frame_insert(400, item.ctrl)
  f:set_translate2(pt.x - cardPos.mid.x, pt.y - cardPos.mid.y)
  item.ctrl.visible = false
  local tag = "discount-" .. item.idx
  w_discountItemMv:insert_on_done(function(ctrl)
    item.ctrl.offset = ui.point(pt.x, pt.y)
    ctrl:remove_on_done(tag)
    ctrl:frame_remove(0)
    item.ctrl.visible = true
    item.ctrl:search("icon").svar.discount = discountTb[item.idx] or 10
    if nextItem then
      discountMoveItem(nextItem, nil)
      ringRun = false
      w_discountRing.visible = false
      ui_chat.show_ui_text_id(72151)
    end
  end, tag)
end
function discountRingTo(idx, cb)
  local ringSpeed = 0.3
  local ringAngle = 0
  local lastRingTick = sys.tick()
  local elaspTick = 0
  local function executeRing(timer)
    if not ringRun then
      timer.suspended = true
      timer:remove_on_timer("ring")
      return
    end
    local now = sys.tick()
    local dtick = sys.dtick(now, lastRingTick)
    elaspTick = elaspTick + dtick
    if ringSpeed <= 0.1 then
      local r2 = ringAngle % 360
      local diffAngle = r2 - ringAngle2Card[idx]
      if elaspTick > 10000 or diffAngle >= 0 and diffAngle < dtick * ringSpeed then
        timer.suspended = true
        timer:remove_on_timer("ring")
        w_discountRing:angle(ringAngle2Card[idx])
        cb()
        return
      end
    end
    ringAngle = ringAngle + dtick * ringSpeed
    w_discountRing:angle(ringAngle)
    if elaspTick >= 0 and elaspTick < 1500 then
      ringSpeed = ringSpeed + 0.02
    elseif elaspTick >= 2000 and ringSpeed > 0.1 then
      ringSpeed = ringSpeed - 0.03
    end
    lastRingTick = now
  end
  ui_widget.safe_play_sound(612)
  w_discountRingTimer:insert_on_timer(executeRing, "ring")
  w_discountRingTimer.suspended = false
end
local reg = ui_packet.recv_wrap_signal_insert
reg(packet.eSTC_Supermarket, function(cmd, data)
  local cmntype = data:get(packet.key.cmn_type).v_int
  if cmntype == bo2.eSupermarketUI_Announce then
    if data:has(packet.key.buy_discount) then
      local arr = data:get(packet.key.buy_discount):split_to_int_array(L("*"))
      discountTb = {}
      for i = 1, arr.size do
        local dc = arr:get(i - 1).v_int / 10
        table.insert(discountTb, dc)
        w_discount:search("discount" .. i).mtf = ui_widget.merge_mtf({discount = dc}, ui.get_text("supermarket|discountLb"))
      end
    end
    local str = bo2.player:get_flag_string(bo2.ePlayerStringFlag_SupermarketDiscount)
    w_discountFlicker.visible = str.empty
    w_discountFlicker.suspended = not str.empty
  end
end, "ui_supermarket2.discount")
