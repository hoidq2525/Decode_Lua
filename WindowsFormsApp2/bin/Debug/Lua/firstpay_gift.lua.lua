local g_init_flag = false
local g_firstpay_id = 903
local g_firstcost_id = 912
local g_item_score = {
  1011,
  928,
  843
}
function check_all()
  local n = bo2.gv_gift_award:find(g_firstpay_id)
  local n_cost = bo2.gv_gift_award:find(g_firstcost_id)
  if bo2.player:get_flag_bit(n.flag_id) == 0 and ui_gift_award.ui_svrbeg2.check_on_visible(n) == true or bo2.player:get_flag_bit(n_cost.flag_id) == 0 and ui_gift_award.ui_svrbeg2.check_on_visible(n_cost) == true then
    return true
  end
  return false
end
function check_and_get_once()
  local n = bo2.gv_gift_award:find(g_firstpay_id)
  if bo2.player:get_flag_bit(n.flag_id) == 0 and ui_gift_award.ui_svrbeg2.check_on_visible(n) == true then
    local btn = {}
    btn.svar = {}
    btn.svar.id = g_firstpay_id
    on_btn_click_getgift(btn)
  end
  local n_cost = bo2.gv_gift_award:find(g_firstcost_id)
  if bo2.player:get_flag_bit(n_cost.flag_id) == 0 and ui_gift_award.ui_svrbeg2.check_on_visible(n_cost) == true then
    local btn = {}
    btn.svar = {}
    btn.svar.id = g_firstcost_id
    on_btncost_click_getgift(btn)
  end
end
function on_init()
  g_init_flag = false
  g_firstpay_id = 903
  g_firstcost_id = 912
  ui_gift_award.push_check_timer("firstpay_gift", check_all)
  ui_gift_award.push_check_get_all("firstpay_gift", check_and_get_once)
end
function on_btn_click_getgift(btn)
  if ui_gift_award.ui_svrbeg2.check_first_buyrmb(0, 1) == false then
    if sys.type(btn) ~= "ui_button" then
      return
    end
    ui_supermarket2.money_BuyRMB(btn)
    return
  end
  local id = btn.svar.id
  if id ~= nil and id > 0 then
    local v = sys.variant()
    v:set(packet.key.cmn_id, id)
    bo2.send_variant(packet.eCTS_GiftAward_Get, v)
    local function reset_sel()
      local n = bo2.gv_gift_award:find(id)
      local comp = bo2.player:get_flag_bit(n.flag_id)
      if comp == 1 then
        btn.enable = false
        btn.text = ui.get_text("gift_award|get_btn_over")
      end
    end
    if sys.type(btn) ~= "ui_button" then
      return
    end
    bo2.AddTimeEvent(10, reset_sel)
  end
end
function on_btncost_click_getgift(btn)
  if ui_gift_award.ui_svrbeg2.check_player_cost(0, 1) == false then
    if ui_supermarket2.CanOpen() then
      ui_supermarket2.w_main.visible = not ui_supermarket2.w_main.visible
    end
    return
  end
  local id = btn.svar.id
  if id ~= nil and id > 0 then
    local v = sys.variant()
    v:set(packet.key.cmn_id, id)
    bo2.send_variant(packet.eCTS_GiftAward_Get, v)
    local function reset_sel()
      local n = bo2.gv_gift_award:find(id)
      local comp = bo2.player:get_flag_bit(n.flag_id)
      if comp == 1 then
        btn.enable = false
        btn.text = ui.get_text("gift_award|get_btn_over")
      end
    end
    bo2.AddTimeEvent(10, reset_sel)
  end
end
local c_style_file = L("$frame/giftaward_v2/firstpay_gift/firstpay_gift.xml")
local c_cell_item = L("item_cell")
local c_cell_item_cost = L("item_cell_buy")
local c_cell_size = 115
local c_cell_size_cost = 60
function set_pay_panel(mainpanel)
  local line = bo2.gv_gift_award:find(g_firstpay_id)
  if line ~= nil then
    local gift_items = line.award_items
    local items_count = line.items_count
    if gift_items ~= nil and gift_items.size > 0 and items_count.size == gift_items.size then
      local ctop = mainpanel:search("citems")
      for j = 0, gift_items.size - 1 do
        if j >= 3 then
          return
        end
        local ctrl = ui.create_control(ctop, "panel")
        ctrl:load_style(c_style_file, c_cell_item)
        ctrl.offset = ui.point(j * c_cell_size, 0)
        local card = ctrl:search("card")
        card.excel_id = gift_items[j]
        ctrl:search("item_score").text = g_item_score[j + 1]
        if items_count[j] > 1 then
          local count = ctrl:search("item_count")
          count.text = items_count[j]
        end
      end
    end
  end
  local btn = mainpanel:search("btn_getgift")
  if btn ~= nil then
    btn.svar.id = g_firstpay_id
    local comp = bo2.player:get_flag_bit(line.flag_id)
    if comp == 1 then
      btn.enable = false
      btn.text = ui.get_text("gift_award|get_btn_over")
    end
  end
end
function set_cost_panel(mainpanel)
  local line = bo2.gv_gift_award:find(g_firstcost_id)
  if line ~= nil then
    local gift_items = line.award_items
    local items_count = line.items_count
    if gift_items ~= nil and gift_items.size > 0 and items_count.size == gift_items.size then
      local ctop = mainpanel:search("citems_buy")
      for j = 0, gift_items.size - 1 do
        if j >= 5 then
          return
        end
        local ctrl = ui.create_control(ctop, "panel")
        ctrl:load_style(c_style_file, c_cell_item_cost)
        ctrl.offset = ui.point(j * c_cell_size_cost, 0)
        local card = ctrl:search("card")
        card.excel_id = gift_items[j]
        if items_count[j] > 1 then
          local count = ctrl:search("item_count")
          count.text = items_count[j]
        end
      end
    end
  end
  local btn = mainpanel:search("btn_getcost")
  if btn ~= nil then
    btn.svar.id = g_firstcost_id
    local comp = bo2.player:get_flag_bit(line.flag_id)
    if comp == 1 then
      btn.enable = false
      btn.text = ui.get_text("gift_award|get_btn_over")
    end
  end
end
function on_vis(mainpanel, vis)
  if vis == false then
    return
  end
  if g_init_flag == true then
    return
  end
  set_pay_panel(mainpanel)
  set_cost_panel(mainpanel)
end
