function get_visible()
  local w = ui.find_control("$frame:ui_deal_main")
  return w.visible
end
function set_visible(vis)
  local w = ui.find_control("$frame:ui_deal_main")
  w.visible = vis
end
local load_card_my = function(main_ctrl, parent_ctrl_name, remove_on_mouse)
  local ctop = main_ctrl:search("ctop1")
  if ctop == nil then
    ui.log("failed get box_ctop.")
    return
  end
  local card_set = {}
  for r = 0, 1 do
    for i = 0, 5 do
      local childctrl = ui.create_control(ctop, "panel")
      childctrl:load_style("$frame/deal/deal.xml", "item_cell")
      childctrl.offset = ui.point(i * 37, r * 37)
      table.insert(card_set, childctrl)
    end
  end
  return card_set
end
local load_card = function(main_ctrl, stylename)
  local ctop = main_ctrl:search(stylename)
  if ctop == nil then
    ui.log("failed get box_ctop.")
    return
  end
  local card_set = {}
  for r = 0, 1 do
    for i = 0, 5 do
      local childctrl = ui.create_control(ctop, "panel")
      childctrl:load_style("$frame/deal/deal.xml", "item_cell")
      childctrl.offset = ui.point(i * 37, r * 37)
      if stylename == "ctop1" then
        childctrl.name = "ctop1"
      end
      table.insert(card_set, childctrl)
    end
  end
  return card_set
end
function item_rbutton_check(info)
  local txt = item_rbutton_tip(info)
  return txt ~= nil
end
function ridepet_rbutton_check(info)
  local txt = ridepet_rbutton_tip(info)
  return txt ~= nil
end
function item_rbutton_use(info)
  local only_id = info.only_id
  request_add_item_to_deal(only_id)
end
function ridepet_rbutton_use(info)
  local only_id = info.onlyid
  request_add_ridepet_to_deal(only_id)
end
function item_rbutton_tip(info)
  if g_main_window.visible and not g_lock_btn.check then
    return ui.get_text("deal_log|deal_right_click")
  end
  return nil
end
function ridepet_rbutton_tip(info)
  if g_main_window.visible and not g_lock_btn.check then
    return ui.get_text("deal_log|deal_right_click")
  end
  return nil
end
function on_init(main_ctrl)
  local logclosebtn = main_ctrl:search()
  g_myinfo.text = "myinfo"
  g_mylev.text = "mylevel"
  g_otherinfo.text = "otherinfo"
  g_card_set = {}
  g_card_set.my_cards = load_card(main_ctrl, "ctop1")
  g_card_set.his_cards = load_card(main_ctrl, "ctop2")
  ui_item.insert_rbutton_data(main_ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  ui_ridepet.insert_ridepet_rbutton_data(main_ctrl, ridepet_rbutton_check, ridepet_rbutton_use, ridepet_rbutton_tip)
  local log_box = main_ctrl:search("log_box")
  if log_box ~= nil then
    local d = {
      limit = ui_deal.log_list_limit,
      view = log_box,
      window = main_ctrl,
      this_log_list = {}
    }
    log_box.svar.log_list_data = d
  end
end
local reset_all_cards = function()
  local reset = function(t)
    for _, ctrl in ipairs(t) do
      ctrl:search("card").only_id = 0
    end
  end
  reset(g_card_set.my_cards)
  reset(g_card_set.his_cards)
end
local get_other_playerdata = function(data)
  local function _compare(key)
    local player_data = data:get(key)
    if bo2.player.only_id ~= player_data:get(packet.key.cha_onlyid).v_string then
      return player_data
    end
  end
  return _compare(packet.key.deal_player_1) or _compare(packet.key.deal_player_2)
end
local get_my_playerdata = function(data)
  local function _compare(key)
    local player_data = data:get(key)
    if bo2.player.only_id == player_data:get(packet.key.cha_onlyid).v_string then
      return player_data
    end
  end
  return _compare(packet.key.deal_player_1) or _compare(packet.key.deal_player_2)
end
local set_title = function(player_data)
  local fmt = ui.get_text("common|deal_title_fmt")
  player_data:set("cha_name", player_data:get(packet.key.cha_name))
  g_my_box:search("lb_title").text = sys.mtf_merge(player_data, fmt)
end
local bind_control_to_player = function(player_data)
  g_card_set[bo2.player.only_id] = {
    cards = g_card_set.my_cards,
    money = function(m)
      ui_widget.ui_money_box.set_money(g_my_money, m)
    end
  }
  g_card_set.my_cards.cha_id = bo2.player.only_id
  local other_player_onlyid = player_data:get(packet.key.cha_onlyid).v_string
  g_card_set[other_player_onlyid] = {
    cards = g_card_set.his_cards,
    money = function(m)
      g_his_money.money = m
    end
  }
  g_card_set.his_cards.cha_id = other_player_onlyid
end
function open_deal_main(data)
  reset_all_cards()
  local player_data = get_other_playerdata(data)
  set_title(player_data)
  bind_control_to_player(player_data)
  ui_widget.ui_money_box.set_enable(g_my_money, true)
  g_his_money.money = 0
  g_lock_btn.enable = true
  g_exchange_btn.enable = false
  local my_player_data = get_my_playerdata(data)
  local myname = my_player_data:get(packet.key.cha_name).v_string
  local myjobid = my_player_data:get(packet.key.player_profession).v_int
  local myjobname = bo2.gv_profession_list:find(myjobid).name
  local mylevel = my_player_data:get(packet.key.cha_level).v_int
  g_myinfo.text = myname
  g_mylev.text = myjobname .. ui.get_text("common|deal_level") .. mylevel
  local othername = player_data:get(packet.key.cha_name).v_string
  local otherjobid = player_data:get(packet.key.player_profession).v_int
  local otherjobname = bo2.gv_profession_list:find(otherjobid).name
  local otherlevel = player_data:get(packet.key.cha_level).v_int
  g_otherinfo.text = othername
  g_otherlev.text = otherjobname .. ui.get_text("common|deal_level") .. otherlevel
  ui_deal.g_main_window.dock = "pin_x1"
  g_my_box.visible = true
  g_my_log.visible = true
  g_mypanel:search("lock_panel").visible = false
  g_hispanel:search("lock_panel").visible = false
  ui_stall.owner.set_visible(false)
  ui_bank.set_visible(false)
  ui_deal.set_visible(true)
  ui_item.set_visible(true)
end
function close_deal_main(data)
  local vis = get_visible()
  if vis then
    set_visible(false)
  end
  ui_item.set_visible(false)
  local clear_cards = function(t)
    for _, card in ipairs(t) do
      local id = card:search("card").only_id
      if id ~= L("0") then
        ui.item_remove(id)
        ui.ride_remove_view(id)
      end
      if t.cha_id then
        g_card_set[t.cha_id] = nil
        t.cha_id = nil
      end
    end
  end
  clear_cards(g_card_set.my_cards)
  clear_cards(g_card_set.his_cards)
  ui_widget.ui_money_box.set_money(g_my_money, 0)
  local log_box = g_my_log:search("log_box")
  log_box:item_clear()
  g_lock_btn.check = false
end
function on_deal_main_visible(ctrl, v)
  if not v then
    bo2.send_variant(packet.eCTS_UI_CloseDeal)
  end
end
function check_ridepet_jipo(only_id)
  if only_id == nil then
    return false
  end
  local info = ui_ridepet.find_info_from_onlyid(only_id)
  if info == nil then
    return false
  end
  local state = ui_ridepet.get_ridepet_jipo_state(info)
  if state then
    ui_chat.show_ui_text_id(2628)
    return true
  end
  return false
end
function on_drop_item(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down then
    return
  end
  ui.clean_drop()
  if check_ridepet_jipo(data:get("only_id")) then
    return
  end
  if ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    request_add_item_to_deal(data:get("only_id"))
  elseif ui_widget.check_drop(data, ui_widget.c_drop_type_ride) then
    request_add_ridepet_to_deal(data:get("only_id"))
  end
end
local get_item_count = function(onlyid)
  local item_info = ui.item_of_only_id(onlyid)
  if item_info then
    return true, item_info.count
  end
end
function edit_numberall(btn)
  local w = btn.topper
  local b = w:search("box_input")
  b.text = w.svar.deal_data.max_count
end
function edit_numberminus(btn)
  local w = btn.topper
  local b = w:search("box_input")
  local num = b.text.v_int
  num = num - 1
  if num <= 1 then
    num = 1
  end
  b.text = num
end
function edit_numberplus(btn)
  local w = btn.topper
  local b = w:search("box_input")
  local num = b.text.v_int
  local num_max = w.svar.deal_data.max_count
  num = num + 1
  if num_max <= num then
    num = num_max
  end
  b.text = num
end
function request_add_item_to_deal(onlyid)
  local function send_impl(cnt)
    local v = sys.variant()
    v:set(packet.key.item_key, onlyid)
    v:set(packet.key.item_count, cnt)
    bo2.send_variant(packet.eCTS_UI_AddDealItem, v)
  end
  local has_item, item_count = get_item_count(onlyid)
  if not has_item then
    return
  end
  if item_count == 1 then
    return send_impl(1)
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/deal/deal_msgbox.xml",
    style_name = "deal_count",
    modal = true,
    init = function(data)
      local w = data.window
      data.max_count = item_count
      w.svar.deal_data = data
      w:search("rv_text").mtf = ui.get_text("common|set_dealitem_count")
      w:search("box_input").focus_able = item_count > 1
      w:search("box_input").text = 1
    end,
    callback = function(ret)
      if ret.result == 1 then
        local window = ret.window
        local input = window:search("box_input").text.v_int
        send_impl(input)
      end
    end
  })
end
function request_add_ridepet_to_deal(onlyid)
  local function send_impl(cnt)
    local v = sys.variant()
    v:set(packet.key.item_key, onlyid)
    v:set(packet.key.item_count, cnt)
    bo2.send_variant(packet.eCTS_UI_AddDealItem, v)
  end
  send_impl(1)
end
function on_item_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_mbutton_click then
    local info = card.info
    if info == nil or info:is_ridepet() == false then
      ui_item.show_tip_frame_card(card)
    else
      local ride_info = ui.get_ride_info(info.only_id)
      if ride_info == nil then
        return
      end
      ui_ridepet_view.show(ride_info.box, ride_info.grid)
    end
  end
  if card.parent.name == L("ctop1") then
    if msg ~= ui.mouse_rbutton_click then
      return
    end
    if not card.info then
      return
    end
    local v = sys.variant()
    v:set(packet.key.item_key, card.info.only_id)
    bo2.send_variant(packet.eCTS_UI_RemoveDealItem, v)
  end
end
local send_money = function()
  local money = ui_widget.ui_money_box.get_money(g_my_money)
  local v = sys.variant()
  v:set(packet.key.deal_money, money)
  bo2.send_variant(packet.eCTS_UI_SetDealMoney, v)
end
function on_click_lockbtn(ctrl)
  local send_impl = function(locked)
    local v = sys.variant()
    v:set(packet.key.deal_lock, locked)
    if locked == 1 then
      local money = ui_widget.ui_money_box.get_money(g_my_money)
      v:set(packet.key.deal_money, money)
    end
    bo2.send_variant(packet.eCTS_UI_SetDealLock, v)
  end
  ctrl.enable = false
  if g_card_set[bo2.player.only_id].locked then
    send_impl(0)
  else
    send_impl(1)
  end
end
function on_click_exchagebtn(ctrl)
  ctrl.enable = false
  bo2.send_variant(packet.eCTS_UI_DealExecute)
end
function on_click_cancelbtn(ctrl)
  bo2.send_variant(packet.eCTS_UI_CloseDeal)
end
function on_common_close(ctrl)
  g_main_window.visible = false
  bo2.send_variant(packet.eCTS_UI_CloseDeal)
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  if not excel then
    return
  end
  local stk = sys.mtf_stack()
  local info = card.info
  if info == nil then
    return
  end
  if info:is_ridepet() == false then
    ui_tool.ctip_make_item(stk, excel, card.info)
    local stk_use
    ui_tool.ctip_push_operation(stk, ui.get_text("item|middle_click"))
    if card.parent.name == L("ctop1") then
      ui_tool.ctip_push_operation(stk, ui.get_text("common|stall_owner_clear"))
    end
    local ptype = excel.ptype
    if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
      stk_use = ui_item.tip_get_using_equip(excel)
    end
  else
    local ride_info = ui.get_ride_info(info.only_id)
    if ride_info == nil then
      return
    end
    ui_ridepet.ctip_make_ridepet(stk, ride_info)
  end
  ui_tool.ctip_show(card, stk, stk_use)
end
function on_disable_key(box, key, flag)
  if flag.down then
    if key == ui.VK_CONTROL then
      return
    end
    if ui.is_key_down(ui.VK_CONTROL) and ui.is_key_down(ui.VK_C) then
      return
    end
    box.enable = false
  else
    box.enable = true
  end
end
