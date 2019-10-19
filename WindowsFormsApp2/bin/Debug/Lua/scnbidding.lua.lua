local sel_bidding_item, sel_scn_item
function show_panel()
  local data = sys.variant()
  bo2.send_variant(packet.eCTS_ScnBiddingList_Query, data)
  w_scnbidding.visible = true
end
function refresh_scnbidding_list(sceneId)
  w_bidding_list:item_clear()
  sel_bidding_item = nil
  local data = sys.variant()
  data:set(L("scene_id"), sceneId)
  bo2.send_variant(packet.eCTS_ScnBidding_Query, data)
end
function on_click_bidding_item(ctrl)
  if sel_bidding_item ~= nil then
    sel_bidding_item:search("highlight").visible = false
  end
  sel_bidding_item = ctrl
  sel_bidding_item:search("highlight").visible = true
end
function on_click_scn_item(ctrl)
  if sel_scn_item ~= nil then
    sel_scn_item:search("highlight").visible = false
  end
  if sel_scn_item ~= ctrl then
    refresh_scnbidding_list(ctrl.var.v_int)
  end
  sel_scn_item = ctrl
  sel_scn_item:search("highlight").visible = true
end
function cmp_int_item(i1, i2, name)
  local k1 = i1:search(name).text.v_int
  local k2 = i2:search(name).text.v_int
  if k1 < k2 then
    return -1
  elseif k1 == k2 then
    return 0
  else
    return 1
  end
end
function cmp_str_item(i1, i2, name)
  local k1 = i1:search(name).text
  local k2 = i2:search(name).text
  if k1 < k2 then
    return -1
  elseif k1 == k2 then
    return 0
  else
    return 1
  end
end
function on_click_rank(ctrl)
  local sort = function(i1, i2)
    return cmp_int_item(i1, i2, "rank")
  end
  w_bidding_list:item_sort(sort)
end
function on_click_price(ctrl)
  local sort = function(i1, i2)
    return cmp_int_item(i1, i2, "price")
  end
  w_bidding_list:item_sort(sort)
end
function on_click_guild_name(ctrl)
end
function on_click_guild_camp(ctrl)
  local sort = function(i1, i2)
    return cmp_str_item(i1, i2, "camp")
  end
  w_bidding_list:item_sort(sort)
end
function on_click_bidding(ctrl)
  if sel_scn_item ~= nil then
    local function on_price_input(ret)
      if ret.result == 1 then
        local price = ret.detail:search("box_input").text.v_int
        local var = sys.variant()
        var:set("scene_id", sel_scn_item.var.v_int)
        var:set("price", price)
        bo2.send_variant(packet.eCTS_ScnBidding_Join, var)
        refresh_scnbidding_list(sel_scn_item.var.v_int)
      end
    end
    local msg = {
      title = "",
      text = ui.get_text("scncopy|scnbidding_msg"),
      detail_uri = "$frame/scncopy/scnbidding.xml",
      detail = "price_input",
      input = "100",
      callback = on_price_input
    }
    if sel_bidding_item ~= nil then
      msg.input = sel_bidding_item:search("price").text
    elseif w_bidding_list.item_count > 0 then
      msg.input = w_bidding_list:item_get(0):search("price").text
    end
    ui_tool.show_msg(msg)
  end
end
function on_click_refresh(ctrl)
  if sel_scn_item ~= nil then
    refresh_scnbidding_list(sel_scn_item.var.v_int)
  end
end
function handle_scnbidding_query(cmd, data)
  local item_uri = "$frame/scncopy/scnbidding.xml"
  local item_style = "bidding_item"
  w_bidding_list:item_clear()
  sel_bidding_item = nil
  for i = 1, data.size do
    do
      local var = data:get(i - 1)
      local item = w_bidding_list:item_append()
      item:load_style(item_uri, item_style)
      local name = var:get("name").v_string
      local clr = "ffffffff"
      local camp
      if name.empty then
        name = "XXXXXX"
        clr = "ffff0000"
      end
      if var:get("camp").v_int == bo2.eCamp_Blade then
        camp = ui.get_text("scncopy|blade_camp")
      else
        camp = ui.get_text("scncopy|sword_camp")
      end
      local function set_clr_text(n, t, c)
        local wnd = item:search(n)
        wnd.text = t
        wnd.color = ui.make_color(c)
      end
      set_clr_text("rank", var:get("rank").v_string, clr)
      set_clr_text("name", name, clr)
      set_clr_text("price", var:get("price").v_string, clr)
      set_clr_text("camp", camp, clr)
    end
  end
end
function handle_scnbidding_list(cmd, data)
  local item_uri = "$frame/scncopy/scnbidding.xml"
  local item_style = "scn_item"
  w_scn_list:item_clear()
  w_bidding_list:item_clear()
  sel_scn_item = nil
  sel_bidding_item = nil
  for i = 1, data.size do
    local var = data:get(i - 1)
    local item = w_scn_list:item_append()
    item:load_style(item_uri, item_style)
    item:search("btn").var = var
    local title = "unknown"
    local excel = bo2.gv_scn_list:find(var.v_int)
    if excel ~= nil then
      title = excel.name
    end
    item:search("title").text = title
  end
end
ui_packet.game_recv_signal_insert(packet.eSTC_ScnBidding_QueryResult, handle_scnbidding_query, "ui_scnbidding:query")
ui_packet.game_recv_signal_insert(packet.eSTC_ScnBidding_List, handle_scnbidding_list, "ui_scnbidding:list")
