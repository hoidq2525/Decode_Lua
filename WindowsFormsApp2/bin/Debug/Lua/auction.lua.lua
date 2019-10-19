local g_item_cnt = 1
local g_items = {}
local g_showstate = "init"
local g_updateKey
local g_page_items = {}
local g_curpage = 1
local g_last_refresh = 0
local g_my_bid = {}
function open_add_item_box(btn, info)
  local box = ui.find_control("$ui_auction:add_item_box")
  if box and box.visible then
    if info then
      box:search("item").only_id = info.only_id
    end
    return
  end
  ui_widget.ui_msg_box.show_common({
    modal = false,
    style_uri = "$frame/auction/auction.xml",
    style_name = "add_item_box",
    init = function(data)
      local w = data.window
      if info then
        w:search("item").only_id = info.only_id
      end
    end,
    callback = function(data)
      if data.result ~= 1 then
        return
      end
      local w = data.window
      local v = sys.variant()
      v:set(packet.key.cmn_type, bo2.eSupermarket_UpAHItem)
      v:set(packet.key.rmb_amount, w:search("rmb").text)
      v:set(packet.key.item_count, w:search("count").text)
      v:set(packet.key.item_key, w:search("item").only_id)
      v:set(packet.key.auction_days, 1)
      bo2.send_variant(packet.eCTS_UI_Supermarket, v)
    end
  })
  ui_item.w_item:move_to_head()
end
local item_cannot_sell = function(info)
  if info:get_data_8(bo2.eItemByte_Bound) == 1 and info:get_data_8(bo2.eItemByte_ReleaseBoundLock) == 0 or not bo2.CheckItemDealType(info.excel_id, bo2.DealTypeBit_Jade) then
    return true
  end
end
function on_drop_item(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down then
    return
  end
  ui.clean_drop()
  local id = data:get("only_id").v_string
  local info = ui.item_of_only_id(id)
  if item_cannot_sell(info) then
    ui_chat.show_ui_text_id(72034)
    return
  end
  if ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    card.only_id = id
  end
end
function show_browse_item(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eSupermarket_SearchAHItem)
  v:set(packet.key.goods_search, g_updateKey)
  local datakey = sys.variant()
  local dataflag = sys.variant()
  for i = 1, w_item_list.item_count do
    local item = w_item_list:item_get(i - 1).svar
    datakey:push_back(item.key)
    dataflag:push_back(item.info and 0 or 1)
  end
  if w_item_list.item_count > 0 then
    v:set(packet.key.itemdata_all, datakey)
    v:set(packet.key.itemdata_flag, dataflag)
  end
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
  if btn then
    g_last_refresh = os.time()
    btn.enable = false
  end
end
function on_visible(ctrl, vis)
  if vis then
    show_browse_item()
    ui_item.w_item.visible = true
  end
  ui_widget.on_esc_stk_visible(ctrl, vis)
end
function switch_tag(btn, p)
  if not p then
    return
  end
  if btn.name == L("all") then
    g_page_items = btn.svar or g_page_items
    w_search_btn.enable = true
    if #g_page_items >= 5 then
      re_update_list(1)
    else
      search_item()
    end
  else
    w_search_btn.enable = false
    w_showalllist.svar = g_page_items
    g_page_items = {}
    for k, item in pairs(g_items) do
      if bo2.player and item.owner == bo2.player.name then
        table.insert(g_page_items, k)
      end
    end
    for k, _ in pairs(g_my_bid) do
      if g_items[k] then
        table.insert(g_page_items, k)
      end
    end
    re_update_list(1)
  end
end
function on_timer()
  if w_mainwin.visible then
    local rmb = ui_supermarket2.g_rmb or 0
    w_rmb.text = rmb
    if os.time() - g_last_refresh > 3 then
      w_refresh_btn.enable = true
    end
    local box = ui.find_control("$ui_auction:add_item_box")
    local info = box and box:search("item").info
    if info then
      local cntedit = box:search("count")
      if cntedit.text.v_int > info.count then
        cntedit.text = info.count
      end
      cntedit.enable = info.count > 1
    end
  end
end
function max_sell_count()
  local box = ui.find_control("$ui_auction:add_item_box")
  local info = box and box:search("item").info
  if info then
    box:search("count").text = info.count
  end
end
function down_item(btn)
  local ti = btn.topper
  ui_widget.ui_msg_box.show_common({
    modal = true,
    text = ui_widget.merge_mtf({
      itemid = ti.svar.excel.id
    }, ui.get_text("auction|removeitem")),
    callback = function(data)
      if data.result == 1 then
        local v = sys.variant()
        v:set(packet.key.item_key, ti.svar.key)
        v:set(packet.key.cmn_type, bo2.eSupermarket_DownAHItem)
        v:set(packet.key.item_excelid, ti.svar.excel.id)
        v:set(packet.key.item_count, ti.svar.info.count)
        bo2.send_variant(packet.eCTS_UI_Supermarket, v)
      end
    end
  })
end
function on_list_item_mouse(ti, msg)
  if msg == ui.mouse_lbutton_down then
    if w_showmylist.press then
      down_item(ti)
    else
      ui_widget.ui_msg_box.show_common({
        modal = true,
        style_uri = "$frame/auction/auction.xml",
        style_name = "buy_item_box",
        init = function(data)
          local w = data.window
          local card = ti:search("item")
          w:search("item").only_id = card.only_id
          local curprice = ti:search("rmb").text
          w:search("price").text = ui_widget.merge_mtf({rmb = curprice}, ui.get_text("auction|curprice"))
          w:search("myprice").text = tonumber(tostring(curprice)) + 100
          w:search("name").text = card.info.excel.name
          local tip = ui_widget.merge_mtf({
            count = ti.svar.hot
          }, ui.get_text("auction|buyertip"))
          if ti.svar.hot > 0 then
            local t = math.ceil((ti.svar.last - bo2.get_server_time()) / 60)
            tip = tip .. ui_widget.merge_mtf({time = t}, ui.get_text("auction|buyertip2"))
          end
          w:search("tip").text = tip
          w:search("tip").dx = 320
        end,
        callback = function(data)
          if data.result ~= 1 then
            return
          end
          local w = data.window
          local v = sys.variant()
          v:set(packet.key.rmb_amount, w:search("myprice").text)
          v:set(packet.key.item_key, w:search("item").only_id)
          v:set(packet.key.cmn_type, bo2.eSupermarket_BuyAHItem)
          bo2.send_variant(packet.eCTS_UI_Supermarket, v)
        end
      })
    end
  end
end
function create_search_filter()
  local schname = w_search_box:search("schname").text
  local function filter_name(item)
    if schname.empty then
      return item
    end
    if item.excel.name:find(schname) ~= -1 then
      return item
    end
  end
  local schseller = w_search_box:search("schseller").text
  local function filter_seller(item)
    if schseller.empty then
      return item
    end
    if item and item.owner:find(schseller) ~= -1 then
      return item
    end
  end
  local schjob = w_search_box:search("schjob"):search("text").text
  local function filter_job(item)
    if schjob.empty then
      return item
    end
    if item and schjob:find(item.job) ~= -1 then
      return item
    end
  end
  local schtype = w_search_box:search("schtype"):search("text").text
  local function filter_type(item)
    if schtype.empty then
      return item
    end
    if item and item.excel.ptype.auction:find(schtype) ~= -1 then
      return item
    end
  end
  local lvmin = w_search_box:search("schlevelmin").text.v_int
  local lvmax = w_search_box:search("schlevelmax").text.v_int
  local function filter_level(item)
    if item and lvmin <= item.excel.reqlevel and item.excel.reqlevel <= lvmax then
      return item
    end
  end
  return function(item)
    item = filter_name(item)
    item = filter_seller(item)
    item = filter_type(item)
    item = filter_job(item)
    item = filter_level(item)
    if w_showmylist.press then
      return item and item.owner == bo2.player.name and item
    end
    return item
  end
end
function search_item()
  local filter = create_search_filter()
  g_page_items = {}
  for k, item in pairs(g_items) do
    item = filter(item)
    if item then
      table.insert(g_page_items, k)
    end
  end
  re_update_list(1)
end
local function fix_page(page)
  if page < 1 then
    page = 1
  end
  local maxpage = math.ceil(#g_page_items / 5)
  if maxpage < 1 then
    maxpage = 1
  end
  if page > maxpage then
    page = maxpage
  end
  g_curpage = page
  return page, maxpage
end
function re_update_list(page)
  w_item_list:item_clear()
  local page, maxpage = fix_page(page)
  w_pager.text = sys.format("%d/%d", page, maxpage)
  local pos = (page - 1) * 5 + 1
  local cnt = 5
  local rm_keys = {}
  for i = pos, #g_page_items do
    local key = g_page_items[i]
    if g_items[key] and cnt > 0 then
      local ti = w_item_list:item_append()
      ti:load_style("$frame/auction/auction.xml", "item_list_item")
      show_item(ti, g_items[key], w_item_list.item_count)
      cnt = cnt - 1
    end
    if cnt <= 0 then
      break
    end
    if not g_items[key] then
      table.insert(rm_keys, i)
    end
  end
  for i, idx in ipairs(rm_keys) do
    table.remove(g_page_items, idx - (i - 1))
  end
  show_browse_item()
  g_showstate = "refresh"
end
function change_page(btn)
  re_update_list(g_curpage + btn.name.v_int)
end
function sort_items(btn)
  local function cmn_sort(f)
    table.sort(g_page_items, function(k1, k2)
      local a = g_items[k1]
      local b = g_items[k2]
      if a and b then
        return f(a, b)
      end
      if a then
        return true
      end
      if b then
        return true
      end
      return k2 < k1
    end)
  end
  btn.svar.order = btn.svar.order or 1
  if btn.name == L("lv") then
    if btn.svar.order == 1 then
      cmn_sort(function(a, b)
        return a.excel.reqlevel > b.excel.reqlevel
      end)
    else
      cmn_sort(function(a, b)
        return a.excel.reqlevel < b.excel.reqlevel
      end)
    end
  elseif btn.name == L("price") then
    if btn.svar.order == 1 then
      cmn_sort(function(a, b)
        return a.price > b.price
      end)
    else
      cmn_sort(function(a, b)
        return a.price < b.price
      end)
    end
  end
  btn.svar.order = btn.svar.order * -1
  re_update_list(1)
end
function create_search_menu(name, menus, dx)
  table.insert(menus, 1, {
    text = ui.get_text("auction|menuany")
  })
  local schjob = w_search_box:search(name)
  schjob:insert_on_mouse(function(ctrl, msg)
    if msg == ui.mouse_lbutton_down then
      ui_tool.show_menu({
        items = menus,
        event = function(item)
          schjob:search("text").text = item.data and item.text
          schjob.svar = item.data
        end,
        source = schjob,
        dx = dx
      })
    end
  end, "auction")
end
function init()
  local jobmenus = {}
  for i = 1, bo2.gv_profession_list.size do
    if (i - 1) % 3 ~= 0 then
      local p = bo2.gv_profession_list:get(i - 1)
      table.insert(jobmenus, {
        text = p.name,
        data = p
      })
    end
  end
  create_search_menu("schjob", jobmenus, 140)
  local types = {}
  for i = 1, bo2.gv_item_type.size do
    local p = bo2.gv_item_type:get(i - 1)
    if 0 < p.auction.size then
      types[p.auction] = 1
    end
  end
  local typemenus = {}
  for k, _ in pairs(types) do
    table.insert(typemenus, {text = k, data = 1})
  end
  create_search_menu("schtype", typemenus, 200)
  g_showstate = "init"
  g_updateKey = nil
  g_page_items = {}
  g_items = {}
  w_showalllist.press = true
  ui_item.insert_rbutton_data(w_mainwin, function(info)
    return w_mainwin.visible
  end, function(info)
    if not item_cannot_sell(info) then
      open_add_item_box(nil, info)
    else
      ui_chat.show_ui_text_id(72034)
    end
  end, function(info)
    if not item_cannot_sell(info) then
      return ui.get_text("auction|boxtip")
    end
  end)
  w_search_box:search("schname"):insert_on_input_enter(search_item)
  w_search_box:search("schseller"):insert_on_input_enter(search_item)
end
local cliptext = function(name)
  if name.size > 5 then
    return name:substr(0, 5) .. ".."
  end
  return name
end
local get_item_job = function(excel)
  for i = 1, excel.requires.size, 2 do
    local job = excel.requires[i - 1]
    if job == bo2.eItemReq_Profession then
      local p = bo2.gv_profession_list:find(excel.requires[i])
      if p then
        return p.name
      end
    elseif job == bo2.eItemReq_Career then
      local p = bo2.gv_career:find(excel.requires[i])
      if p then
        return p.name
      end
    end
  end
  return "-"
end
local item_bgs = {
  "$image/supermarket/item_fig.png|129,83,104,71",
  "$image/supermarket/item_fig.png|129,11,104,72"
}
function show_item(ti, item, i)
  local card = ti:search("item")
  if item.info then
    card.only_id = item.key
    card:set_count_mode("auto")
  else
    card.excel_id = item.excel.id
    card:set_count_mode("none")
  end
  local rmb = ti:search("rmb")
  rmb.text = item.price
  if item.bider == bo2.player.only_id then
    rmb.xcolor = "FF22FF22"
  elseif item.hot == 0 then
    rmb.xcolor = "FFFFFFFF"
  elseif item.hot <= 5 then
    rmb.xcolor = "FFFFFF55"
  else
    rmb.xcolor = "FFFF2222"
  end
  ti:search("owner").text = cliptext(item.owner)
  ti:search("name").text = cliptext(item.excel.name)
  ti:search("type").text = item.excel.ptype.auction
  ti:search("level").text = item.excel.reqlevel
  ti:search("job").text = item.job
  ti:search("bg").image = item_bgs[i % 2 + 1]
  ti:search("btn_close").visible = w_showmylist.press and item.owner == bo2.player.name
  ti.svar = item
  item.ti = ti
end
local function add_item(data)
  local key = data:get(packet.key.item_key).v_string
  if not g_items[key] then
    g_updateKey = key
    if g_showstate == "init" then
      table.insert(g_page_items, key)
      local page, maxpage = fix_page(g_curpage)
      w_pager.text = sys.format("%d/%d", page, maxpage)
    end
  end
  local eid = data:get(packet.key.item_excelid).v_int
  if not g_items[key] then
    local item = {
      key = key,
      excel = ui.item_get_excel(eid),
      owner = data:get(packet.key.cha_name).v_string,
      begin = data:get(packet.key.auction_days).v_int
    }
  end
  item.price = data:get(packet.key.rmb_amount).v_int
  item.job = get_item_job(item.excel)
  item.hot = data:get(packet.key.auction_nego).v_int
  item.bider = data:get(packet.key.action_target_id).v_string
  item.last = data:get(packet.key.total_time).v_int
  if item.bider == bo2.player.only_id then
    g_my_bid[key] = true
  end
  if data:has(packet.key.itemdata_all) then
    if not item.info then
      item.boxpos = g_item_cnt
      g_item_cnt = g_item_cnt + 1
    end
    if item.info then
      ui.item_remove(key)
    end
    item.info = ui.item_create_data(bo2.eItemBox_AH_Sell, item.boxpos, data:get(packet.key.itemdata_all))
  end
  g_items[key] = item
  if g_showstate == "init" then
    if w_item_list.item_count < 5 and not sys.check(item.ti) then
      local ti = w_item_list:item_append()
      ti:load_style("$frame/auction/auction.xml", "item_list_item")
      show_item(ti, item, w_item_list.item_count)
    end
  elseif sys.check(item.ti) then
    show_item(item.ti, item, item.ti.index + 1)
  else
    local filter = create_search_filter()
    item = filter(item)
    if item then
      table.insert(g_page_items, key)
      if w_item_list.item_count < 5 then
        local ti = w_item_list:item_append()
        ti:load_style("$frame/auction/auction.xml", "item_list_item")
        show_item(ti, item, w_item_list.item_count)
        if not item.info then
          show_browse_item()
        end
      end
    end
  end
end
local function remove_item(data)
  local key = data:get(packet.key.item_key).v_string
  local item = g_items[key]
  if item.ti then
    w_item_list:item_remove(item.ti.index)
  end
  local info = ui.item_of_only_id(key)
  if info and info.box == bo2.eItemBox_AH_Sell then
    ui.item_remove(key)
  end
  g_items[key] = nil
  if key == g_updateKey then
    local old = 0
    for k, item in pairs(g_items) do
      if old < item.begin then
        old = item.begin
        g_updateKey = k
      end
    end
    if old == 0 then
      g_updateKey = nil
    end
  end
end
local function handle_packet(cmd, data)
  local op = data:get(packet.key.cmn_type).v_int
  if op == bo2.eSupermarketUI_ClearAHItem then
    remove_item(data)
  elseif op == bo2.eSupermarketUI_AddAHItem then
    add_item(data)
  elseif op == bo2.eSupermarketUI_MayRefresh then
    show_browse_item()
  end
end
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_auction"
reg(packet.eSTC_Supermarket, handle_packet, sig)
