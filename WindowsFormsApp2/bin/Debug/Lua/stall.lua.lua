local ui_combo = ui_widget.ui_combo_box
local ui_tab = ui_widget.ui_tab
g_rmb_stall = false
local stall_type_item = 0
local stall_type_ridepet = 1
local clearItemByMoneyMode = function(bit, keepBit)
  if not ui_stall.owner.g_owner then
    return
  end
  for i, v in ipairs(ui_stall.owner.g_owner.sale_cards) do
    local card = v:search("card")
    if card.info ~= nil then
      local eid = card.info.excel.id
      if card.only_id ~= L("0") then
        local v = sys.variant()
        v:set(packet.key.stall_sale, 1)
        v:set(packet.key.item_key, card.info.only_id)
        bo2.send_variant(packet.eCTS_UI_RemoveStallItem, v)
      end
    end
  end
end
function setMoneyMode(btn)
  g_rmb_stall = btn.name == L("rmb")
  ui_stall.owner.item_label_money.visible = not g_rmb_stall
  ui_stall.owner.item_label_rmb.visible = g_rmb_stall
  ui_widget.ui_msg_box.show_common({
    btn_confirm = true,
    btn_cancel = false,
    modal = true,
    text = ui.get_text("stall|chgmoneymode"),
    callback = function()
      if g_rmb_stall then
        clearItemByMoneyMode(bo2.DealTypeBit_Money, 0)
      else
        clearItemByMoneyMode(bo2.DealTypeBit_Jade, 0)
      end
    end
  })
end
function get_visible()
  local w = ui_stall.owner.gx_main_window
  return w.visible
end
function get_stall_vip()
  return false
end
function get_scn_can_stall()
  local scn = bo2.scn
  local scn_excel = scn.scn_excel
  if scn_excel == nil then
    return false
  end
  local id = scn_excel.id
  local can_stall_scn_id = bo2.gv_define:find(592).value.v_int
  if id == can_stall_scn_id then
    return true
  end
  return false
end
function set_visible(vis)
  local w = ui_stall.owner.gx_main_window
  w.visible = vis
  if vis == true then
    w.dock = "pin_xy"
    w.margin = ui.rect(0, 0, 0, 0)
    if ui_stall.owner.g_owner.opening ~= true then
      if ui_stall.owner.g_owner.owner_name == nil then
        local name
        local player = bo2.player
        if player ~= nil then
          name = player.name
        end
        gx_stallname.text = name .. ui.get_text("stall|show_stall")
      else
        gx_stallname.text = ui_stall.owner.g_owner.owner_name
      end
      if get_stall_vip() == true then
      else
        local cb = ui_stall.owner.gx_style:search("style_name")
        if cb ~= nil then
          ui_combo.select(cb, 0)
        end
      end
    else
      ui_stall.chat.set_visible(true)
      local w_chat = ui_stall.chat.get_main_ctl()
      local w = ui.find_control("$frame:stallowner")
      w_chat.dock = w.dock
      w_chat.margin = ui.rect(w.margin.x1, w.margin.y1, w.margin.x2 + w.dx, w.margin.y2)
      local id = bo2.player:get_qwordtemp(bo2.ePFlagQwordTemp_StallNewsgroup)
      ui_stall.chat.refresh_chat_info(id)
      ui_stall.chat.ResetFloor(true)
    end
    ui_stall.owner.tip_label.text = ui.get_text("stall|all_price")
    updateTotalGoodsMoney()
  end
end
function on_mouse_search(ctl, msg)
  local msg1 = 0
end
function item_rbutton_check(info)
  local txt = item_rbutton_tip(info)
  return txt ~= nil
end
function ridepet_rbutton_check(info)
  local txt = ridepet_rbutton_tip(info)
  return txt ~= nil
end
function updateTotalGoodsMoney()
  local total_money = get_total_money()
  ui_stall.owner.item_label_money.money = tonumber(tostring(total_money))
  ui_stall.owner.item_label_rmb:search("rmb").text = total_money
end
function item_rbutton_use(info)
  local only_id = info.only_id
  request_add_item_to_sale(only_id)
end
function ridepet_rbutton_use(info)
  local only_id = info.onlyid
  request_add_ridepet_to_sale(only_id)
end
function item_rbutton_tip(info)
  if ui_stall.owner.get_visible() then
    return ui.get_text("stall|stall_right_click")
  end
  return nil
end
function ridepet_rbutton_tip(info)
  if ui_stall.owner.get_visible() then
    return ui.get_text("stall|stall_right_click")
  end
  return nil
end
function get_stall_style_idx(style_name)
  local name = sys.format("%s", style_name)
  local panel = gx_stallstyle:upsearch_name("panel_style")
  if not panel then
    return
  end
  local cb = panel:search("style_name")
  local t = cb.svar.list
  for i, v in ipairs(t) do
    local text = sys.format("%s", v.text)
    if text == name then
      return v.id
    end
  end
  return nil
end
function style_append()
  local panel = gx_stallstyle:upsearch_name("panel_style")
  if not panel then
    return
  end
  local cb = panel:search("style_name")
  ui_combo.append(cb, {
    id = 0,
    text = ui.get_text("stall|style_1")
  })
end
function on_init(main_win)
  g_owner = {}
  g_owner.owner_name = nil
  g_owner.is_recover = 0
  g_owner.is_close_computer = false
  g_owner.card_op_tip = ui.get_text("common|stall_owner_clear")
  gx_sale_grid = main_win:search("item_panel")
  g_owner.sale_cards = ui_stall.create_item(ui_stall.owner.gx_sale_grid, L("cmn_item"), 8, 6, on_drop_sale_item, on_saleitem_mouse, true)
  ui_item.insert_rbutton_data(main_win, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  ui_ridepet.insert_ridepet_rbutton_data(main_win, ridepet_rbutton_check, ridepet_rbutton_use, ridepet_rbutton_tip)
  local all_item_Cookies = ui_tool.ui_tool_cookies.g_Database[ui_stall.table_stall_item]
  if all_item_Cookies == nil then
    ui_tool.ui_tool_cookies.CreateTable(ui_stall.table_stall_item)
  end
  local all_pet_Cookies = ui_tool.ui_tool_cookies.g_Database[ui_stall.table_stall_pet]
  if all_pet_Cookies == nil then
    ui_tool.ui_tool_cookies.CreateTable(ui_stall.table_stall_pet)
  end
  style_append()
end
function check_is_bound(info)
  if info:get_data_8(bo2.eItemByte_Bound) == 1 then
    return true
  end
  return false
end
function search_item_by_excelid(info, flag, max_count, cur_count)
  local excelID = info.excel_id
  local onlyid = info.only_id
  local get_equip_star = function(info)
    if sys.check(info) and sys.check(info.excel) and sys.is_type(info.excel, ui_tool.cs_tip_mb_data_equip_item) then
      return info.star
    end
    return 0
  end
  local base_star = get_equip_star(info)
  local count_i = 0
  local i_table = {}
  local bag_slot_count = ui_item.c_box_size_x * ui_item.c_box_size_y
  for box = bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd - 1 do
    for grid = 0, bag_slot_count - 1 do
      do
        local item_info = ui.item_of_coord(box, grid)
        if item_info then
          local new_onlyid = item_info.only_id
          if item_info.excel_id == excelID and new_onlyid ~= only_id and item_info.lock == 0 then
            local function check_equip_star()
              if base_star ~= 0 then
                return base_star == get_equip_star(item_info)
              end
              return true
            end
            if check_is_bound(item_info) ~= true and check_equip_star() then
              count_i = count_i + 1
              table.insert(i_table, new_onlyid)
              if flag == true and (max_count <= count_i or cur_count <= count_i) then
                break
              end
            end
          end
        end
      end
    end
  end
  return count_i, i_table
end
function get_max_count(onlyid)
  local item_info = ui.item_of_only_id(onlyid)
  local max_count = 0
  local needSearch = false
  local count1 = item_info.count
  if count1 > 1 then
    max_count = count1
  elseif count1 == 1 then
    local excelID = item_info.excel_id
    local count2 = ui.item_get_count(excelID, true)
    if count1 < count2 then
      local count_i = search_item_by_excelid(item_info, false)
      local unused_count = ui_stall.get_unused_stall_card_num(g_owner.sale_cards)
      if count_i <= unused_count then
        max_count = count_i
      else
        max_count = unused_count
      end
      needSearch = max_count > 1
    elseif count2 == count1 then
      max_count = count1
    end
  end
  return max_count, needSearch
end
function edit_numberall(btn)
  local w = btn.topper
  local data_tb = w.svar.stall_data
  if data_tb.type ~= stall_type_item then
    return
  end
  local item_info = ui.item_of_only_id(data_tb.onlyid)
  local excelID = item_info.excel_id
  local max_count, needSearch = get_max_count(data_tb.onlyid)
  data_tb.itemcount = max_count
  data_tb.needSearch = needSearch
  data_tb.excelID = excelID
  w.svar.stall_data = data_tb
  local b = w:search("box_input")
  b.text = max_count
end
local send_item_impl = function(ctrl)
  local data_tb = ctrl.svar.stall_data
  if data_tb == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.stall_sale, 1)
  local money = 0
  if g_rmb_stall then
    money = ctrl:search("qb_input").text.v_int
  else
    local money_ctrl = ctrl:search("money")
    money = ui_widget.ui_money_box.get_money(money_ctrl)
    local max_money = 0
    local player = bo2.player
    if player ~= nil then
      local levelup = bo2.gv_player_levelup:find(player:get_atb(bo2.eAtb_Level))
      if levelup ~= nil then
        max_money = levelup.max_money1
      end
    end
    if money > max_money then
      local text = sys.format(L("<m:%d>"), max_money)
      ui_tool.note_insert(ui_widget.merge_mtf({max = text}, ui.get_text("stall|max_money")), L("FF0000"))
      return
    end
  end
  local num_ctrl = ctrl:search("box_input")
  local cur_num = num_ctrl.text.v_int
  if cur_num < 1 then
    ui_chat.show_ui_text_id(1447)
    return
  end
  local only_id = data_tb.onlyid
  local item_info = ui.item_of_only_id(only_id)
  local money_ctrl
  if g_rmb_stall ~= true then
    money_ctrl = ctrl:search("money")
  end
  if money_ctrl ~= nil and sys.check(money_ctrl.svar) and money_ctrl.svar.min ~= nil and money < money_ctrl.svar.min then
    local item_data
    if item_info:is_ridepet() then
      item_data = sys.format(L("<ridepet:%s>"), ui.ride_encode(ride_info))
    else
      item_data = sys.format(L("<fi:%s>"), item_info.code)
    end
    local text = sys.format(L("<m:%d>"), money)
    ui_tool.note_insert(ui_widget.merge_mtf({item = item_data, money = text}, ui.get_text("stall|min_value")), L("FF0000"))
  end
  local keys = sys.variant()
  if cur_num == 1 or 1 < item_info.count then
    local v_id = sys.variant()
    v_id:set(packet.key.item_key, only_id)
    v_id:set(packet.key.item_count, cur_num)
    v_id:set64(packet.key.cmn_money, sys.format("%d", money))
    v_id:set(packet.key.rmb_info, g_rmb_stall)
    keys:push_back(v_id)
    v:set(packet.key.stall_items_key, keys)
    bo2.send_variant(packet.eCTS_UI_AddStallItem, v)
  else
    local v_id = sys.variant()
    v_id:set(packet.key.item_key, only_id)
    v_id:set(packet.key.item_count, 1)
    v_id:set64(packet.key.cmn_money, sys.format("%d", money))
    keys:push_back(v_id)
    local bag_slot_count = ui_item.c_box_size_x * ui_item.c_box_size_y
    local item_info = ui.item_of_only_id(data_tb.onlyid)
    local maxCount = data_tb.itemcount
    local excelID = data_tb.excelID
    local _, i_table = search_item_by_excelid(item_info, true, maxCount, cur_num)
    local batchCnt = 10
    for i, k in pairs(i_table) do
      local v_id = sys.variant()
      v_id:set(packet.key.item_key, k)
      v_id:set(packet.key.item_count, 1)
      v_id:set64(packet.key.cmn_money, sys.format("%d", money))
      keys:push_back(v_id)
      batchCnt = batchCnt - 1
      if batchCnt <= 0 then
        v:set(packet.key.stall_items_key, keys)
        v:set(packet.key.rmb_info, g_rmb_stall)
        bo2.send_variant(packet.eCTS_UI_AddStallItem, v)
        keys = sys.variant()
        batchCnt = 10
      end
    end
    if 0 < keys.size then
      v:set(packet.key.stall_items_key, keys)
      v:set(packet.key.rmb_info, g_rmb_stall)
      bo2.send_variant(packet.eCTS_UI_AddStallItem, v)
    end
  end
end
local stk_push_new_line = function(stk)
  stk:push("\n")
end
function finish_stk_value(stk, name, info, type)
  if type == 1 then
    return plus_stall_viewer.finish_stk_value(stk, name, info, 2)
  end
  local min_mony = 0
  local max_mony = 0
  local average_mony = 0
  local recent = 0
  if type == 0 then
    stk:push(L("<a+:mid>"))
    stk:push(ui.get_text("stall|my_sale_title"))
    if name ~= nil then
      min_mony, max_mony, average_mony, recent = ui_stall.get_item_history(name, info)
    end
  else
    stk:push(ui.get_text("stall|sale_market_title"))
  end
  stk_push_new_line(stk)
  stk:push(L("<a+:left>"))
  stk:push(ui.get_text("stall|low"))
  stk:push(sys.format(L("<m:%d>"), min_mony))
  stk_push_new_line(stk)
  stk:push(ui.get_text("stall|high"))
  stk:push(sys.format(L("<m:%d>"), max_mony))
  stk_push_new_line(stk)
  stk:push(ui.get_text("stall|average"))
  stk:push(sys.format(L("<m:%d>"), average_mony))
  stk_push_new_line(stk)
  if type == 0 then
    stk:push(ui.get_text("stall|recent"))
    stk:push(sys.format(L("<m:%d>"), recent))
  end
  return recent, min_mony, max_mony
end
function on_click_clear_history()
  ui_stall.on_click_clear_history()
end
function modify_on_change(data)
  local w = data.w
  local money_ctrl = data.money_ctrl
  local name = data.name
  local item_info = data.item_info
  local stk_left = sys.stack()
  local recent, min, max = finish_stk_value(stk_left, name, item_info, 0)
  if recent ~= 0 then
    ui_widget.ui_money_box.set_money(money_ctrl, recent)
  end
  local my_sale = w:search("sale_item_left")
  my_sale.mtf = stk_left.text
  my_sale.parent.visible = true
  local stk_right = sys.stack()
  local market_sale = w:search("sale_item_right")
  local av, m_min, m_max = finish_stk_value(stk_right, name, item_info, 1)
  market_sale.mtf = stk_right.text
  if recent == 0 and av == 0 then
    return
  end
  if recent == 0 or recent > av then
    recent = av
  end
  if min == 0 or m_min > 0 and min < m_min then
    min = m_min
  end
  if max == 0 then
    max = m_max
  end
  money_ctrl.svar.min = min
  local c0 = ui.make_color(L("FF0000"))
  local c1 = ui.make_color(L("FFFFFF"))
  local c2 = ui.make_color(L("00FF00"))
  local c_g = money_ctrl:search("g")
  local c_s = money_ctrl:search("s")
  local c_c = money_ctrl:search("c")
  local function change(box)
    local c_money = ui_widget.ui_money_box.get_money(money_ctrl)
    if c_money < min then
      c_g.color = c0
      c_s.color = c0
      c_c.color = c0
    elseif c_money > max then
      c_g.color = c2
      c_s.color = c2
      c_c.color = c2
    elseif c_money >= recent then
      c_g.color = c1
      c_s.color = c1
      c_c.color = c1
    end
  end
  c_g:remove_on_change(L("ui_stall:change"))
  c_s:remove_on_change(L("ui_stall:change"))
  c_c:remove_on_change(L("ui_stall:change"))
  c_g:insert_on_change(change, L("ui_stall:change"))
  c_s:insert_on_change(change, L("ui_stall:change"))
  c_c:insert_on_change(change, L("ui_stall:change"))
end
function request_add_item_to_sale(onlyid)
  if ui_stall.owner.g_owner.opening == true then
    return
  end
  local item_info = ui.item_of_only_id(onlyid)
  local excelID = item_info.excel_id
  if g_rmb_stall and not bo2.CheckItemDealType(excelID, bo2.DealTypeBit_Jade) then
    ui_chat.show_ui_text_id(72140)
    return
  end
  if check_is_bound(item_info) == true then
    ui_tool.note_insert(ui.get_text("stall|band_bound_item"), L("FF0000"))
    return
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/stall/msg_box.xml",
    style_name = "money_and_number_input",
    modal = true,
    init = function(data)
      local w = data.window
      local rb = w:search("rb_text")
      local mtf = {}
      mtf.item = sys.format(L("<fi:%s>"), item_info.code)
      rb.mtf = ui_widget.merge_mtf(mtf, ui.get_text("stall|sale_input"))
      data.onlyid = onlyid
      data.excelID = excelID
      data.type = stall_type_item
      w.svar.stall_data = data
      w:search("g").focus = true
      local money_ctrl = w:search("money")
      money_ctrl.visible = not g_rmb_stall
      w:search("qb_pn").visible = g_rmb_stall
      local data = {}
      data.w = w
      data.money_ctrl = money_ctrl
      data.item_info = item_info
      if sys.check(item_info.excel) then
        data.name = item_info.excel.name
      end
      modify_on_change(data)
    end,
    callback = function(ret)
      if ret.result == 1 then
        send_item_impl(ret.window)
      end
    end
  })
end
local send_ridepet_impl = function(ctrl)
  local data_tb = ctrl.svar.stall_data
  if data_tb == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.stall_sale, 1)
  local money = 0
  if g_rmb_stall then
    money = ctrl:search("qb_input").text.v_int
  else
    local money_ctrl = ctrl:search("money")
    money = ui_widget.ui_money_box.get_money(money_ctrl)
  end
  local num_ctrl = ctrl:search("box_input")
  local cur_num = num_ctrl.text.v_int
  local only_id = data_tb.onlyid
  local keys = sys.variant()
  local v_id = sys.variant()
  v_id:set(packet.key.item_key, only_id)
  v_id:set(packet.key.item_count, cur_num)
  v_id:set(packet.key.cmn_money, money)
  keys:push_back(v_id)
  v:set(packet.key.stall_items_key, keys)
  bo2.send_variant(packet.eCTS_UI_AddStallItem, v)
end
function request_add_ridepet_to_sale(onlyid)
  if ui_stall.owner.g_owner.opening == true then
    return
  end
  local excelID = bo2.gv_define:find(916).value.v_int
  if g_rmb_stall and not bo2.CheckItemDealType(excelID, bo2.DealTypeBit_Jade) then
    ui_chat.show_ui_text_id(72140)
    return
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/stall/msg_box.xml",
    style_name = "money_and_number_input",
    modal = true,
    init = function(data)
      local w = data.window
      local rb = w:search("rb_text")
      local mtf = {}
      local ride_info = ui.get_ride_info(onlyid)
      mtf.item = sys.format("<ridepet:%s>", ui.ride_encode(ride_info))
      rb.mtf = ui_widget.merge_mtf(mtf, ui.get_text("stall|sale_input"))
      w:search("box_input").focus_able = false
      data.onlyid = onlyid
      data.itemcount = 1
      data.type = stall_type_ridepet
      w.svar.stall_data = data
      w:search("g").focus = true
      w:search("money").visible = not g_rmb_stall
      w:search("qb_pn").visible = g_rmb_stall
      local ridepet_excel = bo2.gv_ridepet_list:find(ride_info:get_flag(bo2.eRidePetFlagInt32_RidePetListId))
      local name = ridepet_excel.name
      local money_ctrl = w:search("money")
      local data = {}
      data.w = w
      data.money_ctrl = money_ctrl
      data.item_info = item_info
      data.name = name
      modify_on_change(data)
    end,
    callback = function(ret)
      if ret.result == 1 then
        send_ridepet_impl(ret.window)
      end
    end
  })
end
function on_drop_sale_item(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down then
    return
  end
  ui.clean_drop()
  if ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    request_add_item_to_sale(data:get("only_id").v_string)
  elseif ui_widget.check_drop(data, ui_widget.c_drop_type_ride) then
    request_add_ridepet_to_sale(data:get("only_id").v_string)
  end
end
function on_saleitem_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_mbutton_click then
    if ui.is_key_down(ui.VK_CONTROL) then
      ui_fitting_room.req_fitting_item_by_excel(card.info.excel)
      return
    end
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
  elseif msg == ui.mouse_lbutton_down then
    ui.clean_drop()
    if ui.is_key_down(ui.VK_CONTROL) then
      local info = card.info
      if info:is_ridepet() == false then
        ui_chat.insert_item(card.info.excel_id, card.info.code)
      else
        local ride_info = ui.get_ride_info(info.only_id)
        if ride_info == nil then
          return
        end
        ui_chat.insert_ridepet(ui.ride_encode(ride_info))
      end
      return
    end
  elseif msg == ui.mouse_rbutton_click then
    if not card.info then
      return
    end
    local v = sys.variant()
    v:set(packet.key.stall_sale, 1)
    v:set(packet.key.item_key, card.info.only_id)
    bo2.send_variant(packet.eCTS_UI_RemoveStallItem, v)
  end
end
function request_add_pet_to_sale(onlyid, data)
  local function send_impl(ctrl)
    local v = sys.variant()
    v:set(packet.key.pet_only_id, onlyid)
    local money_ctrl = ctrl:search("money")
    local money = ui_widget.ui_money_box.get_money(money_ctrl)
    v:set(packet.key.cmn_money, money)
    bo2.send_variant(packet.eCTS_UI_AddStallPet, v)
  end
  local thectrl = ui_stall.find_the_ctrl(ui_stall.owner.g_owner.sale_ctr_pets)
  local size = thectrl.item_count
  if size > 0 then
    for i = 0, size - 1 do
      local petitem = thectrl:item_get(i)
      local id = petitem:search("cardpet").only_id
      if id == onlyid then
        return
      end
    end
  end
  local pet_info = ui.pet_find(onlyid)
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/stall/msg_box.xml",
    style_name = "money_and_number_input",
    init = function(data)
      data.window:search("text_lb").text = ui.get_text("common|stall_sale_input2")
      data.window:search("box_input").enable = false
    end,
    callback = function(ret)
      if ret.result == 1 then
        send_impl(ret.window)
      end
    end
  })
end
function on_drop_pet(card, msg, pos, data)
end
function on_mouse_down(card, msg, pos, data)
end
function on_removepet_mouse(card, msg, pos, wheel)
  if msg ~= ui.mouse_rbutton_click then
    return
  end
  local card_info = ui.pet_find(card.only_id)
  if not card_info then
    return
  end
  local v = sys.variant()
  v:set(packet.key.pet_only_id, card.only_id)
  bo2.send_variant(packet.eCTS_UI_RemoveStallPet, v)
end
function request_add_item_to_purchase(excel_id)
  local function send_impl(ctrl)
    local v = sys.variant()
    v:set(packet.key.item_key, excel_id)
    v:set(packet.key.item_count, ctrl:search("box_input").text.v_int)
    local money = ui_widget.ui_money_box.get_money(ctrl:search("money"))
    v:set(packet.key.cmn_money, money)
    v:set(packet.key.rmb_info, g_rmb_stall)
    bo2.send_variant(packet.eCTS_UI_AddStallItem, v)
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/stall/msg_box.xml",
    style_name = "money_and_number_input",
    init = function(data)
      data.window:search("text_lb").text = ui.get_text("common|stall_purchase_input")
    end,
    callback = function(ret)
      if ret.result == 1 then
        send_impl(ret.window)
      end
    end
  })
end
function on_drop_purchase_item(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down then
    return
  end
  ui.clean_drop()
  if ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    local item_info = ui.item_of_only_id(data:get("only_id").v_string)
    request_add_item_to_purchase(item_info.excel_id)
  end
end
function on_purchase_item_mouse(card, msg, pos, wheel)
  if msg ~= ui.mouse_rbutton_click then
    return
  end
  local v = sys.variant()
  v:set(packet.key.item_key, card.excel_id)
  bo2.send_variant(packet.eCTS_UI_RemoveStallItem, v)
end
function get_total_money()
  local total_money = 0
  if ui_stall.g_stall_item ~= nil or ui_stall.g_stall_pet ~= nil then
    local item_money = 0
    local pet_money = 0
    for i, v in ipairs(ui_stall.owner.g_owner.sale_cards) do
      local card = v:search("card")
      if card.only_id ~= L("0") then
        local itemdata = ui_stall.g_stall_item[card.only_id]
        if sys.check(itemdata) then
          item_money = sys.add64(item_money, sys.mul64(itemdata.money, itemdata.count))
        end
      end
    end
    local thectrl
    if thectrl ~= nil then
      local petsize = thectrl.item_count
      for i = 0, petsize - 1 do
        local petitem = thectrl:item_get(i)
        local id = petitem:search("cardpet").only_id
        local petdata = ui_stall.g_stall_pet[id]
        pet_money = pet_money + petdata.money * 1
      end
    end
    total_money = sys.add64(item_money, pet_money)
  end
  return total_money
end
function on_click_stall_openclose(ctrl)
  bo2.PlaySound2D(521)
  g_owner.owner_name = gx_stallname.text
  local send_impl = function(ctrl, msg_ctrl)
    ctrl.enable = false
    if msg_ctrl ~= nil then
      g_owner.is_close_computer = msg_ctrl:search("close_radio_btn").check
    end
    local v = sys.variant()
    v:set(packet.key.rmb_info, g_rmb_stall)
    v:set(packet.key.cmn_state, g_owner.opening and bo2.eStallState_Closing or bo2.eStallState_Opening)
    local default_name = bo2.player.name .. ui.get_text("stall|show_stall")
    if gx_stallname.text ~= default_name then
      v:set(packet.key.cmn_name, gx_stallname.text)
    end
    local panel = gx_stallstyle:upsearch_name("panel_style")
    if panel ~= nil then
      local cb = panel:search("style_name")
      if cb ~= nil then
        local item = cb.svar.selected
        v:set(packet.key.stall_style, item.text)
      end
    end
    bo2.send_variant(packet.eCTS_UI_SetStall_Req, v)
    gx_stallname.enable = false
    gx_stallname.focus = false
    gx_moneyradio.enable = false
    gx_rmbradio.enable = false
  end
  if g_owner.opening ~= true then
    do
      local total_money = get_total_money()
      local param = sys.variant()
      param:set("money", total_money)
      local fmt = ui.get_text("stall|total_money_info")
      local str = sys.mtf_merge(param, fmt)
      local can_stall_text
      local scn = bo2.scn
      local scn_excel = scn.scn_excel
      if scn_excel ~= nil then
        local flag_can_stall = scn_excel.nostall
        if flag_can_stall == 1 then
          do
            local str = ui.get_text("stall|no_stall_text")
            ui_widget.ui_msg_box.show({
              style_uri = "$frame/stall/msg_box.xml",
              style_name = "buy_info",
              init = function(data)
                data.window:search("rv_text").mtf = str
                data.window:search("lb_title").text = ui.get_text("stall|stall_open_confirm")
                data.window:search("btn_cancel").visible = false
              end
            })
            return
          end
        end
        local id = scn_excel.id
        local can_stall_scn_id = bo2.gv_define:find(592).value.v_int
        if id ~= can_stall_scn_id then
          local param = sys.variant()
          local scn_tb = bo2.gv_scn_list:find(can_stall_scn_id)
          local scn_name
          if scn_tb == nil then
            scn_name = ui.get_text("stall|stall_market")
          else
            scn_name = scn_tb.name
          end
          local openstall_rate = bo2.gv_define:find(596).value.v_int
          local openstall_fee = total_money.v_int * openstall_rate / 100
          if openstall_fee < 500 then
            openstall_fee = 500
          end
          openstall_fee = math.floor(openstall_fee)
          param:set("money", openstall_fee)
          param:set("scn_name", scn_name)
          local fmt = ui.get_text("stall|can_stall_text")
          can_stall_text = sys.mtf_merge(param, fmt)
        end
      end
      if can_stall_text ~= nil then
        str = str .. can_stall_text
      else
        str = "\n" .. str
      end
      local ok = true
      if g_rmb_stall then
        str, ok = rmbStallOpenTxt(total_money)
      elseif isRMBStallArea() then
        str = ui.get_text("stall|rmb_only")
        ok = false
      end
      ui_widget.ui_msg_box.show({
        style_uri = "$frame/stall/msg_box.xml",
        style_name = "buy_info",
        init = function(data)
          data.window:search("rv_text").mtf = str
          data.window:search("btn_confirm2").enable = ok
          data.window:search("close_radio_btn").visible = true
        end,
        callback = function(ret)
          if ret.result == 1 and ok then
            send_impl(ctrl, ret.window)
          end
        end
      })
    end
  else
    send_impl(ctrl)
  end
end
function isRMBStallArea()
  local area = bo2.player:get_atb(bo2.eAtb_AreaID)
  local targetArea = bo2.gv_define:find(904).value.v_int
  return area == targetArea, bo2.gv_area_list:find(targetArea)
end
function rmbStallOpenTxt(money)
  local isRMBArea, targetAreaExcel = isRMBStallArea()
  if isRMBArea then
    local param = sys.variant()
    param:set("money", money)
    local fmt = ui.get_text("stall|total_rmb_info")
    return sys.mtf_merge(param, fmt), true
  else
    local param = sys.variant()
    param:set("scn_name", targetAreaExcel.name)
    local fmt = ui.get_text("stall|no_stall_rmb")
    return sys.mtf_merge(param, fmt), false
  end
end
function on_click_stall_chat()
  local vis = ui_stall.chat.get_visible() == false
  ui_stall.chat.set_visible(vis)
  if vis == true then
    local w_chat = ui_stall.chat.get_main_ctl()
    local w = ui.find_control("$frame:stallowner")
    w_chat.dock = w.dock
    w_chat.margin = ui.rect(w.margin.x1, w.margin.y1, w.margin.x2 + w.dx, w.margin.y2)
    local id = bo2.player:get_qwordtemp(bo2.ePFlagQwordTemp_StallNewsgroup)
    ui_stall.chat.refresh_chat_info(id)
    ui_stall.chat.ResetFloor(true)
  end
end
function on_click_stall_clear()
  local player = bo2.player
  local enable = player:get_flag_objmem(bo2.eFlagObjMemory_Stalling) ~= 0
  if enable == true then
    ui_chat.show_ui_text_id(85125)
    return
  end
  bo2.PlaySound2D(564)
  clearItemByMoneyMode(bo2.DealTypeBit_Money + bo2.DealTypeBit_Jade, 0)
end
function on_click_editname()
  local player = bo2.player
  local enable = player:get_flag_objmem(bo2.eFlagObjMemory_Stalling) ~= 0
  if enable == true then
    ui_chat.show_ui_text_id(85125)
    return
  end
  gx_stallname.focus_able = not gx_stallname.focus_able
  gx_stallname.focus = gx_stallname.focus_able
end
function remove_stall_item()
  if ui_stall.owner.g_owner then
    for i, v in ipairs(ui_stall.owner.g_owner.sale_cards) do
      local card = v:search("card")
      if card.only_id ~= L("0") then
        local v = sys.variant()
        v:set(packet.key.stall_sale, 1)
        v:set(packet.key.item_key, card.only_id)
        v:set(packet.key.stall_remove, 1)
        bo2.send_variant(packet.eCTS_UI_RemoveStallItem, v)
        ui_stall.stall_item_remove(card.only_id)
        local itemdata = ui_stall.g_stall_item[card.only_id]
        if itemdata == nil then
          return
        end
        ui_stall.g_stall_item[itemdata.card] = nil
        ui_stall.g_stall_item[card.only_id] = nil
        card.only_id = 0
      end
    end
  end
  local thectrl
  if thectrl ~= nil then
    local petsize = thectrl.item_count
    for i = 0, petsize - 1 do
      local petitem = thectrl:item_get(0)
      local id = petitem:search("cardpet").only_id
      local v = sys.variant()
      v:set(packet.key.pet_only_id, id)
      v:set(packet.key.stall_remove, 1)
      bo2.send_variant(packet.eCTS_UI_RemoveStallPet, v)
      thectrl:item_remove(0)
      local petdata = ui_stall.g_stall_pet[id]
      ui_stall.g_stall_pet[petdata.card] = nil
      ui_stall.g_stall_pet[id] = nil
    end
  end
end
function ownpet_on_visible(panel, bool)
  if bool == false then
    if ui_stall.owner.gx_open_btn.text == ui.get_text("common|stall_close_btn") then
      return
    end
    remove_stall_item()
  else
    local cur_npcfuncid = ui_npcfunc.g_cur_funcid
    local cur_t = ui_npcfunc.g_npcfunc_wnd[cur_npcfuncid]
    if cur_t ~= nil and sys.check(cur_t.w_main) then
      cur_t.w_main.visible = false
    end
  end
  ui.item_mark_show(L("item_mark_stall"), bool)
end
function on_key_1(w, key, flag)
  if key == ui.VK_TAB and flag.down then
    local ctl = w:upsearch_name("money_tb")
    ctl:search("s").focus = true
  end
end
function on_key_2(w, key, flag)
  if key == ui.VK_TAB and flag.down then
    local ctl = w:upsearch_name("money_tb")
    ctl:search("c").focus = true
  end
end
function on_key_3(w, key, flag)
  if key == ui.VK_TAB and flag.down then
    local ctl = w:upsearch_name("main_frm")
    ctl:search("box_input").focus = true
  end
end
function on_sur_btn_tip(tip)
  local btn_name = ui.get_text("stall|stall_surround")
  ui_widget.tip_make_view(tip.view, btn_name)
end
function on_click_stall_surround(btn)
  local enable = get_scn_can_stall()
  if enable == false then
    ui_chat.show_ui_text_id(85057)
    return
  end
  local vis = ui_stall.surround.get_visible() == false
  ui_stall.surround.set_visible(vis)
  if vis == true then
    local player = bo2.player
    if player ~= nil then
    end
    ui_stall.surround.search_stall(bo2.scn)
  end
  local tip = btn.tip
  ui_widget.tip_make_view(tip.view, ui.get_text("stall|stall_surround"))
end
