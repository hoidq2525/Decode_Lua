function create_item(parent, style, dx, dy, on_drop, on_mouse, myStall)
  local function create(x, y)
    local ctrl = ui.create_control(parent, "panel")
    ctrl:load_style("$frame/stall/item_cmn.xml", style)
    local L = ctrl.size.x
    ctrl.offset = ui.point(x * L, y * L)
    local card = ctrl:search("card")
    card.svar = myStall
    if on_drop then
      card:insert_on_drop(on_drop)
    end
    if on_mouse then
      card:insert_on_mouse(on_mouse)
    end
    return ctrl
  end
  parent:control_clear()
  local t = {}
  for y = 1, dy do
    for x = 1, dx do
      local c = create(x - 1, y - 1)
      table.insert(t, c)
    end
  end
  return t
end
function create_petsctr(parent)
  local t = {}
  local ctrl = parent:search("g_petlist")
  if ctrl ~= nil then
    table.insert(t, ctrl)
  end
  return t
end
function make_price_tip(stk, stallitem, myStall)
  ui_tool.ctip_push_sep(stk)
  stk:raw_push(sys.format(L("<c+:%s>"), ui_tool.cs_tip_color_operation))
  if stallitem.is_sale then
    ui_tool.ctip_push_text(stk, ui.get_text("common|stall_sale_tip"))
  else
    ui_tool.ctip_push_text(stk, ui.get_text("common|stall_purchase_tip"))
  end
  stk:raw_push(sys.format(L("<c->")))
  if myStall and ui_stall.owner.g_rmb_stall or stallitem.rmb then
    ui_tool.ctip_push_text(stk, stallitem.money)
    if myStall and ui_stall.owner.g_rmb_stall then
      stk:raw_push("<brmb:16>")
    else
      stk:raw_push("<rmb:16>")
    end
  else
    stk:raw_format("<m:%d>", stallitem.money)
  end
end
local get_item_stk2 = function(excel)
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    stk_use = ui_item.tip_get_using_equip(excel)
    return stk_use
  end
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  if not excel then
    return
  end
  local stallitem = g_stall_item[card]
  if not stallitem then
    return
  end
  local info = card.info
  if info == nil then
    return
  end
  local stk = sys.mtf_stack()
  stk:raw_push(L("<a+:mid>"))
  ui_stall.make_price_tip(stk, stallitem, card.svar)
  stk:raw_push(L("<a->"))
  ui_tool.ctip_push_sep(stk)
  if info:is_ridepet() == false then
    ui_tool.ctip_make_item_without_price(stk, excel, card.info)
  else
    local ride_info = ui.get_ride_info(info.only_id)
    if ride_info == nil then
      return
    end
    ui_ridepet.build_ridepet_tip(stk, ride_info)
  end
  if stallitem.card_op_tip_leftkey ~= nil then
    ui_tool.ctip_push_operation(stk, stallitem.card_op_tip_leftkey)
  end
  ui_tool.ctip_push_operation(stk, ui.get_text("item|middle_click"))
  if ui_fitting_room.test_item_may_suit(excel) ~= false then
    ui_tool.ctip_push_operation(stk, ui.get_text("stall|ctrl_and_mclick"))
  elseif excel.fitting_index then
    local equip_excel = bo2.gv_equip_item:find(excel.fitting_index)
    if sys.check(equip_excel) then
      ui_tool.ctip_push_operation(stk, ui.get_text("stall|ctrl_and_mclick"))
    end
  end
  local btn = ui_stall.owner.gx_open_btn
  if ui_stall.owner.g_owner.opening ~= true then
    ui_tool.ctip_push_operation(stk, stallitem.card_op_tip)
  end
  local stk_use = plus_stall_viewer.get_item_stk2(excel, info)
  ui_tool.ctip_show(card, stk, stk_use)
end
g_stall_item = {}
g_stall_pet = {}
table_stall_item = ui_tool.ui_tool_cookies.table_stall_item
table_stall_pet = ui_tool.ui_tool_cookies.table_stall_pet
local ui_tab = ui_widget.ui_tab
function CreateShelfPages(main_win)
  ui_tab.clear_tab_data(main_win)
  local styurl = "$frame/stall/item_cmn.xml"
  local pages = {
    {
      name = "item_panel",
      txt = ui.get_text("stall|item_tab")
    }
  }
  for _i, v in ipairs(pages) do
    ui_tab.insert_suit(main_win, v.name, styurl, "tab_button", styurl, v.name)
    ui_tab.get_button(main_win, v.name).text = v.txt
  end
end
function on_click_show_pet(ctr)
  local showpet = ctr:upsearch_name("petunit")
  local card = showpet:search("cardpet")
  ui_pet.ui_pet_info.set_visible(true, card.only_id)
end
function on_petlist_observable(w, vis)
  if ui_stall.viewer.the_view_stall_open == true then
    return
  end
  if vis then
    local data = sys.variant()
    data:set("keep_show", 1)
    data:set("ok_text", ui.get_text("stall|pet_onstall"))
    ui_pet.ui_pet_list.show_pet_list(ui_stall.owner.request_add_pet_to_sale, data)
  else
    local w = ui.find_control("$frame:pet_list")
    w.visible = vis
  end
end
function get_stall_cookies()
  if ui_tool.ui_tool_cookies.g_Database == nil then
    return
  end
  local all_item_Cookies = ui_tool.ui_tool_cookies.g_Database[ui_stall.table_stall_item]
  local all_pet_Cookies = ui_tool.ui_tool_cookies.g_Database[ui_stall.table_stall_pet]
  local item_size = 0
  local pet_size = 0
  if all_item_Cookies ~= nil then
    item_size = table.maxn(all_item_Cookies)
  end
  if all_pet_Cookies ~= nil then
    pet_size = table.maxn(all_pet_Cookies)
  end
  local v = sys.variant()
  v:set(packet.key.stall_sale, 1)
  local keys = sys.variant()
  for i = 1, item_size do
    local item_table = all_item_Cookies[i]
    local v_id = sys.variant()
    v_id:set(packet.key.item_key, item_table.item_card_onlyid)
    v_id:set(packet.key.item_count, item_table.count)
    v_id:set(packet.key.cmn_money, item_table.money)
    keys:push_back(v_id)
  end
  v:set(packet.key.stall_items_key, keys)
  v:set(packet.key.rmb_info, g_rmb_stall)
  bo2.send_variant(packet.eCTS_UI_AddStallItem, v)
  for i = 1, pet_size do
    local pet_table = all_pet_Cookies[i]
    local v = sys.variant()
    v:set(packet.key.pet_only_id, pet_table.key)
    v:set(packet.key.item_count, pet_table.count)
    v:set(packet.key.cmn_money, pet_table.money)
    bo2.send_variant(packet.eCTS_UI_AddStallPet, v)
  end
end
function stall_chg_scn()
  is_Send_To_Sev = 1
  if ui_stall.owner.g_owner.is_recover == 1 then
    return
  end
  for i, v in ipairs(ui_stall.owner.g_owner.sale_cards) do
    local card = v:search("card")
    if card.only_id ~= L("0") then
      ui.item_remove(card.only_id)
      local itemdata = ui_stall.g_stall_item[card.only_id]
      ui_stall.g_stall_item[itemdata.card] = nil
      ui_stall.g_stall_item[card.only_id] = nil
      card.only_id = 0
    end
  end
  ui_stall.owner.item_label_money.money = 0
  local petsize = 0
  for i = 0, petsize - 1 do
    local petitem = thectrl:item_get(0)
    local id = petitem:search("cardpet").only_id
    local petdata = ui_stall.g_stall_pet[id]
    thectrl:item_remove(0)
    ui_stall.g_stall_pet[petdata.card] = nil
    ui_stall.g_stall_pet[id] = nil
  end
  if ui_stall.owner.gx_main_window.visible or ui_stall.owner.g_owner.opening then
    get_stall_cookies()
    is_Send_To_Sev = 0
    if ui_stall.owner.g_owner.opening then
      local v = sys.variant()
      v:set(packet.key.cmn_state, bo2.eStallState_Opening)
      v:set(packet.key.cmn_name, ui_stall.owner.gx_stallname.text)
      bo2.send_variant(packet.eCTS_UI_SetStall_Req, v)
    end
  end
  if ui_stall.viewer.gx_main_window.visible then
    ui_stall.viewer.gx_main_window.visible = false
  end
end
g_history_price = {}
function get_item_record_name(name, info)
  local record_name = name
  if sys.check(info) and sys.is_type(info, "ui_ride_info") ~= true and sys.check(info.excel) and sys.is_type(info.excel, ui_tool.cs_tip_mb_data_equip_item) then
    local star = info.star
    record_name = sys.format(L("%s%d"), name, star)
  end
  return record_name
end
function get_item_history(name, info)
  local record_name = get_item_record_name(name, info)
  if g_history_price[record_name] == nil then
    return 0, 0, 0, 0
  end
  local data = g_history_price[record_name]
  return data.low, data.high, data.average, data.recent
end
function on_add_history_price(card, money, data)
  if sys.check(card) ~= true then
    return
  end
  local name
  if data:has(packet.key.ridepet_item_val) then
    local ride_item_val = data:get(packet.key.ridepet_item_val)
    local id = ride_item_val:get(packet.key.player_view_flag):get(packet.key.ridepet_excelid).v_int
    local ridepet_excel = bo2.gv_ridepet_list:find(id)
    if ridepet_excel == nil then
      return
    end
    name = ridepet_excel.name
  else
    if sys.check(card.info) ~= true or sys.check(card.info.excel) ~= true then
      return
    end
    name = card.info.excel.name
  end
  name = get_item_record_name(name, card.info)
  if g_history_price[name] == nil then
    g_history_price[name] = {
      high = money,
      low = money,
      average = money,
      recent = money,
      total = money,
      count = 1
    }
    return
  end
  local data = g_history_price[name]
  data.recent = money
  data.total = data.total + money
  data.count = data.count + 1
  data.average = math.floor(data.total / data.count)
  if money > data.high then
    data.high = money
  elseif money < data.low then
    data.low = money
  end
end
function on_config_load(cfg, root)
  local root = ui_main.player_cfg_load("stall.rec")
  if root == nil then
    return
  end
  local n = root:get(L("history"))
  for i = 0, n.size - 1 do
    local x = n:get(i)
    local name = x:get_attribute("n")
    g_history_price[name] = {
      high = x:get_attribute_int("h"),
      low = x:get_attribute_int("l"),
      average = x:get_attribute_int("av"),
      recent = x:get_attribute_int("r"),
      total = x:get_attribute_int("to"),
      count = x:get_attribute_int("c")
    }
  end
end
function save_stall_data(x)
  local uri = ui_main.player_cfg_make_uri("stall.rec")
  x:bin_save(uri)
end
function on_config_save(cfg, root)
  local root = ui_main.player_cfg_load("stall.rec")
  if root == nil then
    root = sys.xnode()
  end
  local n = root:get(L("history"))
  n:clear()
  for i, v in pairs(g_history_price) do
    local item = n:add(L("item"))
    item:set_attribute(L("n"), i)
    item:set_attribute(L("h"), v.high)
    item:set_attribute(L("l"), v.low)
    item:set_attribute(L("av"), v.average)
    item:set_attribute(L("r"), v.recent)
    item:set_attribute(L("c"), v.count)
    item:set_attribute(L("to"), v.total)
  end
  save_stall_data(root)
end
function stall_item_remove(only_id)
  if plus_stall_viewer.find_item_info(only_id) ~= true then
    ui.item_remove(only_id)
    ui.ride_remove_view(only_id)
  end
end
function on_click_clear_history()
  local on_msg_callback = function(msg)
    if msg.result == 1 then
      g_history_price = {}
      on_config_save()
    end
  end
  local text_show = ui.get_text("stall|refresh_my_price_tip")
  local msg = {callback = on_msg_callback, text = text_show}
  ui_widget.ui_msg_box.show_common(msg)
end
