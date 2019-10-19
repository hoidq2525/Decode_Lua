local reg = function()
end
reg(packet.eSTC_Supermarket, function(cmd, data)
  local goodType = data:get(packet.key.cmn_type).v_int
  if goodType == bo2.eSupermarketUI_HotList then
    local list = data:get(packet.key.ranklist_data)
    local list = list:split_to_int_array("*")
    local tb = {}
    for i = 0, list.size - 1 do
      table.insert(tb, list:get(i).v_int)
    end
    hotlist_Show(tb)
  end
end, "ui_supermarket2.hotlist")
local btnChecker = {}
function hotlist_ShowBuyButton(ctrl, msg)
  local btn = ctrl:search("buybtn")
  local btn3 = ctrl:search("friendbtn")
  local function xxx_update()
    if sys.check(btn) and sys.check(ctrl) then
      btn.visible = ctrl.inner_hover
      if btn3 then
        btn3.visible = ctrl.inner_hover and btn3.enable
      end
    end
  end
  local function xx_update()
    xxx_update()
    table.insert(btnChecker, function()
      xxx_update()
    end)
  end
  if msg == ui.mouse_inner then
    ctrl:insert_post_invoke(xx_update)
  elseif msg == ui.mouse_outer then
    ctrl:insert_post_invoke(xx_update)
  end
  for i, f in ipairs(btnChecker) do
    f()
  end
  btnChecker = {}
end
function hotlist_Show(data)
  w_hotlist:item_clear()
  for i, v in ipairs(data) do
    local good = g_allGoods[v]
    if good then
      local ctrl = w_hotlist:item_append()
      if w_hotlist.item_count == 1 then
        ctrl:load_style("$frame/supermarket_v2/hotlist.xml", "hotbigitem")
      else
        ctrl:load_style("$frame/supermarket_v2/hotlist.xml", "hotitem")
      end
      itembox_Show(ctrl:search("itembox"), good, w_hotlist.item_count > 1)
      local name = itembox_GetTitleColor(good)
      ctrl:search("itemname").text = name
      ctrl:search("buybtn").svar = good
      if good.price then
        ctrl:search("itemprice").text = good.price
      end
    end
  end
end
