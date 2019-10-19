local ui_tab = ui_widget.ui_tab
local g_select
local g_depot_update = {}
local ui_chat_list = ui_widget.ui_chat_list
local cs_item_grid = SHARED("$image/item/pic_item_grid.png|0,0,36,36")
local cs_item_bad = SHARED("$image/item/pic_item_bad.png|0,0,36,36")
c_text_item_file = L("$frame/guild/guild_depot.xml")
c_text_item_cell = L("item_cell")
function get_visible()
  local w = ui.find_control("$frame:guild_depot")
  return w.visible
end
function depot_data(cmd, data)
  local op = data:get(packet.key.cmn_type).v_int
  local fn = g_depot_update[op]
  fn(data)
end
function depot_AddNews(cmd, data)
  local time_text = data:get("new_text")
  ui_chat_list.insert(g_news_list, {text = time_text}, 0)
end
function depot_updatamoney(cmd, data)
  local cur_money = ui.guild_get_money()
  g_guild_money_view.color = ui.make_color("ffffff")
  g_guild_money_view2.text = ui.get_text("guild|tag_money")
  g_guild_money_view2.color = ui.make_color("ffa2a2a2")
  if cur_money < 0 then
    cur_money = -cur_money
    g_guild_money_view.color = ui.make_color("FF0000")
    g_guild_money_view2.text = ui.get_text("guild|debt")
    g_guild_money_view2.color = ui.make_color("FF0000")
  end
  g_guild_money_view.money = cur_money
end
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_guild_mod.ui_guild_depot:on_signal"
reg(packet.eSTC_Guild_Depot, depot_data, sig)
reg(packet.eSTC_Depot_AddNews, depot_AddNews, sig)
reg(packet.eSTC_Guild_SelfData, depot_updatamoney, sig)
function on_UI_AddItem(data)
  local box = data:get(packet.key.item_box).v_int + bo2.eItemBox_Guild_Depot1
  local grid = data:get(packet.key.item_grid).v_int
  ui.item_create_data(box, grid, data:get(packet.key.itemdata_all))
end
function on_UI_SetBoxSize(data)
  local box = data:get(packet.key.item_box).v_int + bo2.eItemBox_Guild_Depot1
  local cnt = data:get(packet.key.itemdata_val).v_int
  local name = sys.format("box:%d", box)
  local box_panel = w_depot_main:search(name)
  box_resize(box_panel, 48, cnt)
end
function on_depot_visible(w, vis)
  if bo2.is_in_guild() == sys.wstring(0) then
    ui_chat.show_ui_text_id(70251)
    ui_guild_mod.ui_guild_depot.w_depot_main.visible = false
  end
  if vis == false then
    ui_widget.esc_stk_pop(w)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eDepotEnter_Detach)
    bo2.send_variant(packet.eCTS_UI_GuildDepot_Enter, v)
  else
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    ui_tab.show_page(w_depot_main, "sell_box1", true)
    ui.item_box_clear(bo2.eItemBox_Guild_Depot1)
    ui.item_box_clear(bo2.eItemBox_Guild_Depot2)
    ui.item_box_clear(bo2.eItemBox_Guild_Depot3)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eDepotEnter_Attach)
    bo2.send_variant(packet.eCTS_UI_GuildDepot_Enter, v)
    local cur_money = ui.guild_get_money()
    g_guild_money_view.color = ui.make_color("ffffff")
    g_guild_money_view2.text = ui.get_text("guild|tag_money")
    g_guild_money_view2.color = ui.make_color("ffa2a2a2")
    if cur_money < 0 then
      cur_money = -cur_money
      g_guild_money_view.color = ui.make_color("FF0000")
      g_guild_money_view2.text = ui.get_text("guild|debt")
      g_guild_money_view2.color = ui.make_color("FF0000")
    end
    g_guild_money_view.money = cur_money
    ui_chat_list.clear(ui_guild_mod.ui_guild_depot.g_news_list)
    local w = ui.find_control("$frame:item")
    if w ~= nil then
      w.visible = vis
    end
  end
end
function box_resize(w_box, max_cnt, cnt)
  if max_cnt < cnt then
    cnt = max_cnt
  end
  for i = 0, cnt - 1 do
    local ctrl = w_box:search(sys.format("grid:%d", i))
    ctrl:search("card").enable = true
    local bg = ctrl:search("bg")
    bg.visible = true
    bg.image = cs_item_grid
  end
  for i = cnt, max_cnt - 1 do
    local ctrl = w_box:search(sys.format("grid:%d", i))
    ctrl:search("card").enable = false
    local bg = ctrl:search("bg")
    bg.visible = true
    bg.image = cs_item_bad
  end
end
function insert_tab(name)
  local btn_uri = "$frame/guild/common.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/guild/common.xml"
  local page_sty = name
  ui_tab.insert_suit(w_depot_main, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_depot_main, name)
  btn.text = ui.get_text("mall|" .. name)
end
function on_allitem_click(btn)
  btn.svar.win:search("number").text = btn.svar.count
end
function req_buygoods(card, onlyid)
  local function send_impl(cnt, excel_id)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eDepotShop_FetchItem)
    v:set(packet.key.item_key, card.only_id)
    v:set(packet.key.item_count, cnt)
    v:set(packet.key.item_excelid, excel_id)
    bo2.send_variant(packet.eCTS_UI_GuildDepot_Shop, v)
  end
  if card == nil or card.info == nil then
    ui_chat.show_ui_text_id(72070)
    return
  end
  local cnt = card.info.count
  if cnt == 1 then
    send_impl(1, card.info.excel_id)
  else
    do
      local cfm_text = ui.get_text("common|guild_fetchitme")
      local arg = sys.variant()
      local stack_count = card.info.excel.consume_par
      arg:set("stack_count", stack_count)
      ui_widget.ui_msg_box.show({
        style_uri = "$frame/guild/common.xml",
        style_name = "goods_box",
        init = function(msg)
          local window = msg.window
          local btn = window:search("all_btn")
          window:search("title").mtf = sys.mtf_merge(arg, cfm_text)
          btn.text = ui.get_text("common|item_all_out")
          btn.svar.count = cnt
          btn.svar.win = window
          window:search("number").text = cnt
        end,
        callback = function(ret)
          if ret.result == 1 then
            if card == nil or card.info == nil then
              ui_chat.show_ui_text_id(70264)
              return
            end
            local window = ret.window
            send_impl(window:search("number").text.v_int, card.info.excel_id)
          end
        end
      })
    end
  end
end
function req_upgoods(card, onlyid)
  local function send_impl(count, excel_id)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eDepotShop_StoreItem)
    v:set(packet.key.item_key, onlyid)
    v:set(packet.key.item_box, card.box - bo2.eItemBox_Guild_Depot1)
    v:set(packet.key.item_grid, card.grid)
    v:set(packet.key.item_count, count)
    v:set(packet.key.item_excelid, excel_id)
    bo2.send_variant(packet.eCTS_UI_GuildDepot_Shop, v)
  end
  local item_info = ui.item_of_only_id(onlyid.v_string)
  local cnt = item_info.count
  if cnt == 1 then
    send_impl(1, item_info.excel_id)
  else
    do
      local cfm_text = ui.get_text("common|guild_storeitem")
      local arg = sys.variant()
      local stack_count = item_info.excel.consume_par * 4
      arg:set("stack_count", stack_count)
      ui_widget.ui_msg_box.show({
        style_uri = "$frame/guild/common.xml",
        style_name = "goods_box",
        excel_id = item_info.excel_id,
        init = function(msg)
          local window = msg.window
          local btn = window:search("all_btn")
          window:search("title").mtf = sys.mtf_merge(arg, cfm_text)
          btn.text = ui.get_text("common|item_all_in")
          btn.svar.count = item_info.count
          btn.svar.win = window
          window:search("number").text = item_info.count
        end,
        text = sys.mtf_merge(arg, cfm_text),
        callback = function(ret)
          if ret.result == 1 then
            local window = ret.window
            send_impl(window:search("number").text.v_int, ret.excel_id)
          end
        end
      })
    end
  end
end
function on_card_drop(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  if not ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    return
  end
  ui.clean_drop()
  local item_info = ui.item_of_only_id(data:get("only_id").v_string)
  if item_info then
    local sbox = item_info.box
    if sbox >= bo2.eItemBox_Guild_Depot1 and sbox <= bo2.eItemBox_Guild_Depot3 then
      return
    end
  end
  req_upgoods(card, data:get("only_id"))
end
function on_card_mouse(card, msg, pos, wheel)
  local icon = card.icon
  if icon == nil then
    return
  end
  local info = card.info
  if info == nil then
    return
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_drag then
    if g_select == card then
      return
    end
    if g_select ~= nil then
      g_select.parent.parent:search("highlight").visible = false
    end
    g_select = card
    g_select.parent.parent:search("highlight").visible = true
    ui.clean_drop()
    if info.lock > 0 then
      return
    end
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_item)
    data:set("only_id", card.only_id)
    data:set("count", info.count)
    ui.set_cursor_icon(icon.uri)
    local function on_drop_hook(w, msg, pos, data)
      local info = card.info
      if info == nil then
        return
      end
      if msg == ui.mouse_drop_setup then
        info:insert_lock(bo2.eItemLock_Drop)
      elseif msg == ui.mouse_drop_clean then
        g_select.parent.parent:search("highlight").visible = false
        g_select = nil
        info:remove_lock(bo2.eItemLock_Drop)
      end
    end
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  elseif msg == ui.mouse_rbutton_click then
    req_buygoods(card)
  end
end
function create_box(parent, dx, dy, uri, box)
  if parent == nil then
    return
  end
  local function create_cell(x, y)
    local ctrl = ui.create_control(parent, "panel")
    ctrl:load_style(uri, "cmn_item")
    local L = 37
    ctrl.offset = ui.point(x * L, y * L)
    local card = ctrl:search("card")
    card.box = box
    card.grid = y * (dx + 1) + x
    ctrl.name = sys.format("grid:%d", card.grid)
    local bg = ctrl:search("bg")
    bg.visible = true
    bg.image = cs_item_bad
    return ctrl
  end
  parent:control_clear()
  parent.name = sys.format("box:%d", box)
  for y = 0, dy do
    for x = 0, dx do
      create_cell(x, y)
    end
  end
end
function init_sell_box(name, box)
  local box_panel = ui_tab.get_page(w_depot_main, name):search("box_panel")
  create_box(box_panel, 7, 5, "$frame/guild/guild_depot.xml", box)
end
function on_click_buy(ctrl)
  req_buygoods(g_select)
end
function on_card_chg(card, index, info)
  if info == nil and g_select == card then
    g_select.parent.parent:search("highlight").visible = false
    g_select = nil
  end
end
function on_card_tip_show(tip)
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item_without_price(stk, excel, card.info)
  ui_tool.ctip_push_operation(stk, ui.get_text("common|lclick_sel"))
  ui_tool.ctip_push_operation(stk, ui.get_text("common|rclick_fetch"))
  local stk_use
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_init(ctrl)
  ui_tab.clear_tab_data(w_depot_main)
  insert_tab("sell_box1")
  insert_tab("sell_box2")
  insert_tab("sell_box3")
  init_sell_box("sell_box1", bo2.eItemBox_Guild_Depot1)
  init_sell_box("sell_box2", bo2.eItemBox_Guild_Depot2)
  init_sell_box("sell_box3", bo2.eItemBox_Guild_Depot3)
  g_depot_update[bo2.eDepotUI_AddItem] = on_UI_AddItem
  g_depot_update[bo2.eDepotUI_SetBoxSize] = on_UI_SetBoxSize
  g_select = nil
end
function on_donatemoney_click()
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/guild/common.xml",
    style_name = "money_input_box",
    init = function(msg)
    end,
    callback = function(msg)
      if msg.result == 1 then
        local window = msg.window
        local money_ctrl = window:search("money")
        local money = ui_widget.ui_money_box.get_money(money_ctrl)
        if money > 0 then
          local v = sys.variant()
          v:set(packet.key.cmn_type, bo2.eOrgAsync_DonateMoney)
          v:set(packet.key.cmn_money, money)
          bo2.send_variant(packet.eCTS_Guild_DonateMoney, v)
        else
          ui_chat.show_ui_text_id(70265)
        end
      end
    end
  })
end
function on_tidybox_click()
  local v = sys.variant()
  v.set(packet.key.item_box, 0)
  bo2.send_variant(packet.eCTS_Guild_TidyDepotBox, v)
end
