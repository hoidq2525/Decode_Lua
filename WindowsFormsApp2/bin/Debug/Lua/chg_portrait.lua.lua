local cwstr_style_uri = L("$frame/im/chg_portrait.xml")
local cwstr_style_name = L("barbershop_edit_item")
local cwstr_cell_name = L("cell%d")
local portrait_data_table = {}
local current_index = 0
local total_count = 0
local n_page_limit = 6
local current_select
function on_chg_portrait_visible(ctrl, vis)
  if vis == false then
    return
  end
  local viw_panel = ctrl:search("view")
  local step = ctrl:search("step")
  local _v_barber_shop = bo2.gv_barber_shop
  local _size_barbershop = _v_barber_shop.size
  local player = bo2.player
  if player == nil then
    return
  end
  local _bodily_form = ui.safe_get_atb(bo2.eAtb_ExcelID)
  local _sex = ui.safe_get_atb(bo2.eAtb_Sex)
  portrait_data_table = {}
  current_index = 0
  total_count = 0
  current_select = nil
  for i = 0, _size_barbershop - 1 do
    local p_mb_data = _v_barber_shop:get(i)
    if p_mb_data.type == 4 and _sex == p_mb_data.restrict_type then
      table.insert(portrait_data_table, {
        index = p_mb_data.id,
        id = p_mb_data._data,
        icon = p_mb_data.icon_name
      })
    end
  end
  total_count = #portrait_data_table
  local function on_init_cell_box()
    for i = 0, n_page_limit - 1 do
      local cname = sys.format(cwstr_cell_name, i)
      local cell = ui.create_control(w_chgpor_divview, "panel")
      cell:load_style(cwstr_style_uri, cwstr_style_name)
      cell.name = cname
    end
  end
  on_init_cell_box()
  local function on_page_step(var)
    current_index = var.index * 6
    update_page(w_chgpor_divview, step)
  end
  ui_widget.ui_stepping.set_event(step, on_page_step)
  update_page(w_chgpor_divview, step)
end
function update_page(w_chgpor_divview, step_ctrl)
  local p_idx = math.floor(current_index / n_page_limit)
  local p_cnt = math.floor((total_count + n_page_limit - 1) / n_page_limit)
  ui_widget.ui_stepping.set_page(step_ctrl, p_idx, p_cnt)
  local player_portrait = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Portrait)
  for i = 0, n_page_limit - 1 do
    local cname = sys.format(cwstr_cell_name, i)
    local cell = w_chgpor_divview:search(cname)
    local idx = current_index + i + 1
    if idx <= total_count then
      local card = cell:search("barbershop_icon")
      card.icon_name = portrait_data_table[idx].icon
      card.excel_id = portrait_data_table[idx].index
      card.visible = true
      local highlight_current = cell:search("highlight_current")
      highlight_current.visible = player_portrait == portrait_data_table[idx].id
      local highlight_select = cell:search("highlight_select")
      highlight_select.visible = current_select == portrait_data_table[idx].index
    else
      local set_cell_visible_border = function(cell)
        local card = cell:search("barbershop_icon")
        card.visible = false
        local highlight_select = cell:search("highlight_select")
        highlight_select.visible = false
      end
      set_cell_visible_border(cell)
    end
  end
end
function on_portrait_card_show(tip)
  local stk = sys.mtf_stack()
  local stk_use
  local data = bo2.gv_barber_shop:find(tip.owner.excel_id)
  ui_barbershop.ui_facial.on_card_show(tip, data, stk)
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function update_quick_buy(btn, item_id)
  btn.visible = false
  local goods_id = ui_supermarket2.shelf_quick_buy_id(item_id)
  if goods_id == 0 then
    return
  end
  btn.name = goods_id
  btn.visible = true
end
function on_mouse_portrait_card(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local barber_line = bo2.gv_barber_shop:find(card.excel_id)
    update_quick_buy(w_chg_portrait_quick_buy, barber_line.cast_item_id)
    for i = 0, n_page_limit - 1 do
      local cname = sys.format(cwstr_cell_name, i)
      local cell = w_chgpor_divview:search(cname)
      local highlight_select = cell:search("highlight_select")
      highlight_select.visible = false
    end
    if card.excel_id ~= 0 then
      local _excel_data = bo2.gv_barber_shop:find(card.excel_id)
      current_select = card.excel_id
      local card_item = consume_item_card:search("consume_item")
      local item_count = ui.item_get_count(_excel_data.cast_item_id, true)
      local need_count = _excel_data.cast_item_cnt
      card_item.visible = true
      card_item.excel_id = _excel_data.cast_item_id
      card_item.require_count = need_count
      local pItemExcel = ui.item_get_excel(_excel_data.cast_item_id)
      local color_str = "<c+:FFFFFF>%s<c->"
      if item_count < need_count then
        color_str = "<c+:6C6C6C>%s<c->"
      end
      consume_item_card:search("confirm_item_text").mtf = sys.format(color_str, pItemExcel.name)
      local money_panel = need_money_panel:search("money_label")
      local money_lack_panel = need_money_panel:search("money_lack_label")
      money_panel.money = _excel_data.cast_money
      money_lack_panel.money = _excel_data.cast_money
      local _has_money = 0
      local player = bo2.player
      if player ~= nil then
        _has_money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
        _has_money = _has_money + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
      end
      if _has_money < _excel_data.cast_money then
        money_panel.visible = false
        money_lack_panel.visible = true
      else
        money_panel.visible = true
        money_lack_panel.visible = false
      end
    end
    local highlight_select = card.parent.parent:search("highlight_select")
    highlight_select.visible = true
  end
end
function on_chg_portrait_enter(btn)
  if current_select ~= nil then
    local _excel_data = bo2.gv_barber_shop:find(current_select)
    if _excel_data ~= nil then
      if _excel_data._data == bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Portrait) then
        local text = sys.format(ui.get_text("personal|barbershop_same_portrait"))
        ui_tool.note_insert(text, L("FFFF0000"))
        return
      elseif _excel_data.cast_item_cnt > ui.item_get_count(_excel_data.cast_item_id, true) then
        local pItemExcel = ui.item_get_excel(_excel_data.cast_item_id)
        local text = sys.format(ui.get_text("personal|barbershop_lackof_item"), pItemExcel.name)
        ui_tool.note_insert(text, L("FFFF0000"))
        return
      else
        local v = sys.variant()
        v:set(packet.key.ui_barbershop_excel_id, current_select)
        bo2.send_variant(packet.eCTS_UI_IMChgPortrait, v)
      end
    end
  end
  local data = ui_widget.ui_msg_box.get_data(btn)
  if data == nil then
    return
  end
  data.result = 1
  ui_widget.ui_msg_box.invoke(data)
end
function on_chg_portrait_reset(btn)
  w_chg_portrait_quick_buy.visible = false
  current_select = nil
  for i = 0, n_page_limit - 1 do
    local cname = sys.format(cwstr_cell_name, i)
    local cell = w_chgpor_divview:search(cname)
    local highlight_select = cell:search("highlight_select")
    highlight_select.visible = false
  end
  local card_item = consume_item_card:search("consume_item")
  card_item.visible = false
  consume_item_card:search("confirm_item_text").mtf = ""
  local money_panel = need_money_panel:search("money_label")
  local money_lack_panel = need_money_panel:search("money_lack_label")
  money_panel.money = 0
  money_lack_panel.money = 0
  money_panel.visible = true
  money_lack_panel.visible = false
end
function on_quick_buy_click(btn)
  ui_supermarket2.shelf_singleBuy(btn)
end
