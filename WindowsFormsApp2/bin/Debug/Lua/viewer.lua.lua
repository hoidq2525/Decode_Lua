local g_flicker_item = {}
function clear_flicker()
  g_flicker_item = {}
end
function has_filcker()
  for i, v in pairs(g_flicker_item) do
    if v ~= nil then
      return true
    end
  end
  return false
end
function insert_flick_item(key)
  g_flicker_item[key] = 1
end
function found_flick_item(key)
  if g_flicker_item[key] ~= nil then
    return true
  end
  return false
end
function remove_flick_item(key)
  g_flicker_item[key] = nil
end
local ui_tab = ui_widget.ui_tab
function on_init(main_win)
  g_data = {}
  gx_SelectedCard = nil
  gx_SelectedPet = nil
  the_view_stall_open = false
  g_data.card_op_tip_leftkey = ui.get_text("common|lclick_sel")
  g_data.card_op_tip = ui.get_text("common|stall_viewer_get")
  gx_sale_grid = main_win:search("item_panel")
  g_data.sale_cards = ui_stall.create_item(ui_stall.viewer.gx_sale_grid, L("cmn_item"), 8, 6, nil, on_sale_item_mouse)
  for i, c in ipairs(g_data.sale_cards) do
    c:search("card").draw_equiplevel = true
  end
end
function set_visible(vis)
  ui_stall.viewer.g_viewer.visible = vis
  if vis == true then
    ui_stall.viewer.g_viewer:move_to_head()
    ui_stall.viewer.tip_label.text = ui.get_text("stall|viewer_tip_label")
    local total_count = get_total_count()
    ui_stall.viewer.item_label.text = total_count .. ui.get_text("stall|viewer_tip_label_2")
  end
end
function on_esc_stk_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis ~= true and sys.check(ui_stall.surround.gx_main_window) then
    ui_stall.surround.gx_main_window.visible = false
  end
end
function get_visible()
  return ui_stall.viewer.g_viewer.visible
end
function get_total_count()
  local total_count = 0
  if ui_stall.g_stall_item ~= nil or ui_stall.g_stall_pet ~= nil then
    local item_count = 0
    local pet_count = 0
    for i, v in ipairs(ui_stall.viewer.g_data.sale_cards) do
      local card = v:search("card")
      if card.only_id ~= L("0") then
        local itemdata = ui_stall.g_stall_item[card.only_id]
        item_count = item_count + itemdata.count
      end
    end
    local thectrl
    if thectrl ~= nil then
      local petsize = thectrl.item_count
      for i = 0, petsize - 1 do
        local petitem = thectrl:item_get(i)
        local id = petitem:search("cardpet").only_id
        local petdata = ui_stall.g_stall_pet[id]
        pet_count = pet_count + 1
      end
    end
    total_count = item_count + pet_count
  end
  return total_count
end
local request_get_stall_item = function(card, itemid, sale, tip)
  local obj = bo2.player
  if obj == nil then
    return
  end
  if obj:get_flag_objmem(bo2.eFlagObjMemory_Stalling) ~= 0 then
    ui_chat.show_ui_text_id(85933)
    return
  end
  local function send_impl(cnt)
    local v = sys.variant()
    if sale then
      v:set(packet.key.stall_sale, 1)
    end
    v:set(packet.key.item_key, itemid)
    v:set(packet.key.item_count, cnt)
    v:set(packet.key.cha_onlyid, g_data.stall_owner_id)
    bo2.send_variant(packet.eCTS_UI_GetStallItem, v)
  end
  local function send_impl_all(card, cnt)
    local onlyid = card.only_id
    local excelid = card.excel.id
    local item = ui_stall.g_stall_item[onlyid]
    local money = item.money
    local max_money = bo2.gv_define:find(300).value.v_int
    local info = ui.item_of_only_id(onlyid)
    if not info then
      return
    end
    local fmt
    local param = sys.variant()
    if info:is_ridepet() == false then
      param:set("code", info.code)
      param:set("money", money * cnt)
      param:set("count", cnt)
      fmt = ui.get_text("stall|buy_info")
      if item.rmb then
        fmt = ui.get_text("stall|buy_info_rmb")
      end
    else
      local ride_info = ui.get_ride_info(info.only_id)
      if ride_info == nil then
        return
      end
      param:set("code", ui.ride_encode(ride_info))
      param:set("money", money * cnt)
      param:set("count", cnt)
      fmt = ui.get_text("stall|buy_ridepet")
      if item.rmb then
        fmt = ui.get_text("stall|buy_ridepet_rmb")
      end
    end
    local str = sys.mtf_merge(param, fmt)
    ui_widget.ui_msg_box.show({
      style_uri = "$frame/stall/msg_box.xml",
      style_name = "buy_info",
      init = function(data)
        local w = data.window
        w.size = ui.point(250, 180)
        w:search("rv_text").mtf = str
      end,
      callback = function(ret)
        if ret.result == 1 then
          send_impl(cnt)
        end
      end
    })
  end
  local cnt = card.info.count
  if cnt == 1 then
    send_impl_all(card, 1)
  else
    ui_widget.ui_msg_box.show({
      style_uri = "$frame/deal/deal_msgbox.xml",
      style_name = "deal_count",
      init = function(data)
        local w = data.window
        data.max_count = cnt
        w.svar.deal_data = data
        w:search("rv_text").mtf = ui.get_text("common|stall_get_sale")
        w:search("rv_text").margin = ui.rect(20, 0, 0, 0)
        w:search("box_input").focus_able = cnt > 1
        w:search("box_input").text = 1
        w:search("count_all").text = ui.get_text("stall|btn_buy_all")
      end,
      callback = function(ret)
        if ret.result == 1 then
          local input_num = ret.window:search("box_input").text.v_int
          if input_num > cnt then
            input_num = cnt
          end
          send_impl_all(card, input_num)
        end
      end
    })
  end
end
local request_get_stall_pet = function(card, petid, petmoney, sale, tip)
  local function send_impl(cnt)
    local v = sys.variant()
    if sale then
    end
    v:set(packet.key.pet_only_id, petid)
    v:set(packet.key.cmn_money, petmoney)
    v:set(packet.key.item_count, cnt)
    v:set(packet.key.cha_onlyid, g_data.stall_owner_id)
    bo2.send_variant(packet.eCTS_UI_GetStallPet, v)
  end
  local cnt = 1
  if cnt == 1 then
    send_impl(1)
  end
end
function SetSelectedCard(s)
  if sys.check(gx_selectedCard) then
    gx_selectedCard:search("hilight").visible = false
  end
  gx_selectedCard = s
  if gx_selectedCard then
    ui_stall.viewer.gx_buyBtn.enable = true
    gx_selectedCard:search("hilight").visible = true
  end
end
function on_sale_item_mouse(card, msg, pos, wheel)
  if not card.info then
    return
  end
  if msg == ui.mouse_rbutton_click then
    request_get_stall_item(card, card.only_id, true, ui.get_text("common|stall_get_sale"))
  elseif msg == ui.mouse_mbutton_click then
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
  elseif msg == ui.mouse_lbutton_click then
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
    else
      SetSelectedCard(card:upsearch_name("cardunit"))
    end
  end
end
function ClickBuyItem()
  if ui_stall.viewer.gx_sale_grid.visible then
    if gx_selectedCard then
      local card = gx_selectedCard:search("card")
      if card.info then
        request_get_stall_item(card, card.only_id, true, ui.get_text("common|stall_get_sale"))
      end
    end
  elseif ui_stall.viewer.gx_sale_grid_pet.visible and gx_SelectedPet then
    local card = gx_SelectedPet:search("cardpet")
    local money = gx_SelectedPet:search("petmoney").money
    local card_info = ui.pet_find(card.only_id)
    if card_info then
      request_get_stall_pet(card, card.only_id, money, true, ui.get_text("common|stall_get_sale"))
    end
  end
end
function ExamineSelectedCard()
end
function on_purchase_item_mouse(card, msg, pos, wheel)
  if msg ~= ui.mouse_rbutton_click then
    return
  end
  if not card.info then
    return
  end
  request_get_stall_item(card, card.excel_id, false, ui.get_text("common|stall_get_purchase"))
end
function on_click_chat_button()
  local vis = ui_stall.chat.get_visible() == false
  if vis == true then
    ui_stall.chat.refresh_chat_info(g_data.chat_id)
    ui_stall.chat.ResetFloor(false)
    local w_chat = ui_stall.chat.get_main_ctl()
    local w = ui.find_control("$frame:main_top")
    w_chat.dock = w.dock
    w_chat.margin = ui.rect(w.margin.x1, w.margin.y1, w.margin.x2 + w.dx, w.margin.y2)
  end
  ui_stall.chat.set_visible(vis)
end
function OnSelectPet(ctr, sel)
  ctr:search("hilight").visible = sel
  if sel then
    ui_stall.viewer.gx_buyBtn.enable = true
    gx_SelectedPet = ctr:upsearch_name("petunit")
  end
end
function on_click_stallsurround_button(btn)
  local enable = ui_stall.owner.get_scn_can_stall()
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
function view_on_visible(panel, bool)
  if bool == false then
    ui_stall.chat.gx_chat_main.visible = false
    ui_stall.chat.g_data.last_index = 0
    ui_widget.ui_chat_list.clear(ui_stall.chat.gx_chat_list)
    ui_stall.viewer.gx_buyBtn.enable = false
    for i, v in ipairs(ui_stall.viewer.g_data.sale_cards) do
      local card = v:search("card")
      if card.only_id ~= L("0") then
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
end
