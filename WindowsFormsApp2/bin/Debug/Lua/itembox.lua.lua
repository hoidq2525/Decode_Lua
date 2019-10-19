g_allGoods = {}
g_allBJGoods = {}
g_allJFGoods = {}
local SplitItems = function(str)
  local items = {}
  for item, cnt in string.gmatch(str, "(%d+)*(%d+)") do
    table.insert(items, {
      item = item,
      count = cnt,
      excel = ui.item_get_excel(item)
    })
  end
  return items
end
local SplitSearchs = function(str)
  local s2 = sys.wstring(str)
  return {
    s2:split("*")
  }
end
local goodElements = {
  {
    "id",
    "cmn_id",
    "v_int"
  },
  {
    "name",
    "cmn_name",
    "v_string"
  },
  {
    "price",
    "cmn_price",
    "v_int"
  },
  {
    "oldprice",
    "goods_oldprice",
    "v_int"
  },
  {
    "recharge",
    "goods_recharge",
    "v_int"
  },
  {
    "tip",
    "goods_tip",
    "v_int"
  },
  {
    "icon",
    "goods_icon",
    "v_string"
  },
  {
    "corner",
    "goods_corner",
    "v_int"
  },
  {
    "page",
    "goods_page",
    "v_string"
  },
  {
    "items",
    "item_excelid",
    "v_string",
    SplitItems
  },
  {
    "vip",
    "goods_vip",
    "v_int"
  },
  {
    "cd",
    "ui_cd_view_id",
    "v_int"
  },
  {
    "remainCount",
    "goods_remain",
    "v_int"
  },
  {
    "search",
    "goods_search",
    "v_string",
    SplitSearchs
  },
  {
    "dbmtype",
    "rmb_lock",
    "v_int"
  },
  {
    "order",
    "sort_name",
    "v_int"
  }
}
local reg = ui_packet.recv_wrap_signal_insert
reg(packet.eSTC_Supermarket, function(cmd, data)
  local goodType = data:get(packet.key.cmn_type).v_int
  local good = {}
  for i, elem in ipairs(goodElements) do
    local k1, k2, ktype, proc = unpack(elem)
    if data:has(packet.key[k2]) then
      local val = data:get(packet.key[k2])[ktype]
      if k1 ~= "name" and ktype == "v_string" then
        if not val.empty then
          good[k1] = tostring(val)
        end
      else
        good[k1] = val
      end
      if proc then
        good[k1] = proc(good[k1])
      end
    end
  end
  if goodType == bo2.eSupermarketUI_AddGoods then
    g_allGoods[good.id] = good
  elseif goodType == bo2.eSupermarketUI_AddBJGoods then
    g_allBJGoods[good.id] = good
  elseif goodType == bo2.eSupermarketUI_AddJFGoods then
    g_allJFGoods[good.id] = good
  elseif goodType == bo2.eSupermarket_Remain then
    local g = g_allGoods[good.id] or g_allBJGoods[good.id]
    g.remainCount = data:get(packet.key.goods_remain).v_int
  elseif goodType == bo2.eSupermarketUI_ClearBJGoods then
    g_allBJGoods = {}
  elseif goodType == bo2.eSupermarketUI_ClearJFGoods then
    g_allJFGoods = {}
  elseif goodType == bo2.eSupermarketUI_ClearGoods then
    g_allGoods = {}
  else
    return
  end
end, "ui_supermarket2.itembox")
local cornerPath = {
  [1] = "$image/supermarket/hot_tag.png|0,0,47,47",
  [2] = "$image/supermarket/hot_tag.png|0,52,47,95",
  ["limit"] = "$image/supermarket/soldout_tag.png|0,50,44,44",
  ["sellout"] = "$image/supermarket/soldout_tag.png|53,1,44,44",
  ["limit2"] = "$image/supermarket/limit_tag.png|2,3,44,44"
}
local HasItem = function(data)
  return data.items[1] and data.items[1].excel
end
function itembox_Show(ctrl, data, small, rebate)
  local card = ctrl:search("icon")
  card.svar = data
  if data.icon then
    card.icon_name = data.icon .. ".png"
  elseif HasItem(data) then
    card.icon_name = data.items[1].excel.icon .. ".png"
  end
  if data.corner > 0 and not small then
    local ltag = ctrl:search("ltag")
    ltag.image = cornerPath[data.corner]
    ltag.visible = true
  end
  if data.remainCount and not small and not rebate then
    local rtag = ctrl:search("rtag")
    if 0 < data.remainCount then
      rtag.image = cornerPath.limit
    elseif data.cd and 0 < data.cd then
      rtag.image = cornerPath.limit2
    else
      rtag.image = cornerPath.sellout
    end
    rtag.visible = true
  end
  if #data.items == 1 then
    card.count = data.items[1].count
  else
    card.count = 1
  end
end
function itembox_GetTitleColor(data)
  local name = data.name
  if not name and HasItem(data) then
    name = data.items[1].excel.name
  end
  return name, ui_tool.cs_tip_color_gold
end
function itembox_ShowTip(tip)
  local data = tip.owner.svar
  if data.items == nil then
    return
  end
  local stk = sys.mtf_stack()
  if #data.items > 1 then
    local title, color = itembox_GetTitleColor(data)
    ui_tool.ctip_make_title_ex(stk, title, color)
    ui_tool.ctip_push_newline(stk)
    if data.tip then
      local ln = bo2.gv_text:find(data.tip)
      if ln then
        ui_tool.ctip_push_text(stk, ln.text, nil, ui_tool.cs_tip_a_add_l)
      end
    end
    ui_tool.ctip_push_sep(stk)
  end
  if #data.items == 1 then
    ui_tool.ctip_make_item_without_price(stk, data.items[1].excel)
  else
    for i, item in ipairs(data.items) do
      stk:raw_format([[

<scii:%d,]], item.excel.id)
      stk:push(item.excel.name)
      stk:raw_push(">")
      ui_tool.ctip_push_text(stk, "x" .. item.count, nil, ui_tool.cs_tip_a_add_r)
    end
  end
  ui_tool.ctip_push_sep(stk)
  local function AddSellInfo(txtid, val)
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text(txtid), nil, ui_tool.cs_tip_a_add_l)
    ui_tool.ctip_push_text(stk, val, nil, ui_tool.cs_tip_a_add_r)
  end
  if data.price then
    do
      local function addMoneyTag()
        stk:raw_push(ui_tool.cs_tip_a_add_r)
        if is_jfgoods(data) then
          stk:raw_push("<jfrmb:17>")
        elseif not data.vip or data.vip == 0 or g_allGoods[data.id] then
          stk:raw_push("<img:$image/supermarket/qb_icon.png|4,3,20,20*16,16>")
          if 0 < data.dbmtype then
            stk:raw_push("/<brmb:17>")
          end
        else
          stk:raw_push("<img:$image/supermarket/rmb_icon.png|2,5,24,18*21,16>")
        end
        stk:raw_push(ui_tool.cs_tip_a_sub)
      end
      if data.discount then
        AddSellInfo("supermarket|pricelb", math.floor(data.price * data.discount / 10))
        addMoneyTag()
        AddSellInfo("supermarket|oldpricelb", data.price)
        addMoneyTag()
      else
        AddSellInfo("supermarket|price", data.price)
        addMoneyTag()
        do break end
        ui_tool.ctip_push_newline(stk)
        ui_tool.ctip_push_text(stk, ui.get_text("supermarket|viptip"), nil, ui_tool.cs_tip_a_add_l)
        ui_tool.ctip_push_text(stk, "VIP", ui_tool.cs_tip_color_gold, ui_tool.cs_tip_a_add_r)
        ui_tool.ctip_push_text(stk, data.vip, nil, ui_tool.cs_tip_a_add_r)
      end
    end
  end
  if data.cd then
    local excel = bo2.gv_cooldown_list:find(data.cd)
    if excel then
      AddSellInfo("supermarket|canbuy", excel.token)
    end
  end
  if data.remainCount then
    AddSellInfo("supermarket|leftcount", data.remainCount)
    if data.remainCount == 0 and data.cd and data.cd > 0 then
      AddSellInfo("supermarket|resetcdlb", "06:00")
    end
  end
  ui_tool.ctip_show(tip.owner, stk, nil)
end
function itembox_FindItem(itemid, itemtype)
  if itemtype and itemtype == 1 then
    return g_allBJGoods[itemid]
  else
    local item = g_allGoods[itemid]
    if item then
      return item
    else
      return g_allBJGoods[itemid]
    end
  end
end
