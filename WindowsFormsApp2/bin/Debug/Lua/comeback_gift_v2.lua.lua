local item_tb = {}
function show_by_id(id)
  local excel = bo2.gv_back_world_gift:find(id)
  if excel == nil then
    return
  end
  if check_fn() ~= true then
    return
  end
  if sys.check(w_award_list) ~= true then
    return
  end
  local modify_list_item = function(v_value, name)
    local p_cell = w_award_list:search(name)
    if sys.check(p_cell) ~= true then
      return
    end
    p_cell.visible = true
    local size_value = #v_value
    if size_value < 0 then
      p_cell.visible = false
      return
    end
    local function set_card_item(item_name, value)
      local item = p_cell:search(item_name)
      if sys.check(item) ~= true then
        return
      end
      local card = item:search(L("card"))
      card.excel_id = value
      item.visible = true
    end
    for i = 0, 5 do
      local item_name = L("item") .. i
      local item = p_cell:search(item_name)
      if sys.check(item) ~= true then
        return
      end
      item.visible = false
    end
    for i = 0, size_value do
      set_card_item(L("item") .. i, v_value[i])
    end
  end
  local set_all_item_as_one = function(t_a, t_b)
    local size_tablea = t_a.size
    if size_tablea == nil then
      size_tablea = 0
    end
    local size_tableb = t_b.size
    if size_tableb < 0 then
      return
    end
    for i = 0, size_tableb - 1 do
      table.insert(t_a, size_tablea + i, t_b[i])
    end
  end
  local items = {}
  set_all_item_as_one(items, excel.exp_desc)
  set_all_item_as_one(items, excel.equip_desc)
  set_all_item_as_one(items, excel.title_desc)
  modify_list_item(items, L("exp_desc"))
  ui_gift_comeback.w_main.visible = true
  local on_modify_flag = function()
    local flag_award = bo2.player:get_flag_int8(bo2.ePlayerFlag8_BackWorldGiftAward)
    if flag_award == 0 then
      ui_gift_comeback.btn_get_gift.enable = false
      bo2.player:remove_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlag8_BackWorldGiftAward, "ui_gift_comeback.flag8")
    end
  end
  if flag_award ~= 0 then
    ui_gift_comeback.btn_get_gift.enable = true
    bo2.player:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlag8_BackWorldGiftAward, on_modify_flag, "ui_gift_comeback.flag8")
  else
    ui_gift_comeback.btn_get_gift.enable = false
  end
end
function r()
  show_by_id(1)
end
function check_fn()
  if sys.check(bo2.player) ~= true then
    return false
  end
  local flag = bo2.player:get_flag_int8(bo2.ePlayerFlag8_GiftAward)
  local flag_award = bo2.player:get_flag_int8(bo2.ePlayerFlag8_BackWorldGiftAward)
  return flag ~= 0 and flag_award ~= 0
end
function check_all()
  return false
end
function check_and_get_once()
end
function on_init()
  r()
end
function on_btn_click_getgift(btn)
  local id = bo2.player:get_flag_int8(bo2.ePlayerFlag8_BackWorldGiftAward)
  local excel = bo2.gv_back_world_gift:find(id)
  if excel == nil then
    return
  end
  local id = excel.award_id
  if id > 0 then
    local v = sys.variant()
    v:set(packet.key.cmn_id, id)
    bo2.send_variant(packet.eCTS_GiftAward_Get, v)
  end
end
local c_style_file = L("$frame/giftaward_v2/comeback_gift/comeback_gift.xml")
local c_style_item = L("cmn_item")
local c_cell_item = L("item_cell")
local c_cell_size = 52
function on_vis(w, vis)
  if vis == false then
    return
  end
  if check_fn() ~= true then
    w.visible = false
    return
  end
  local flag = bo2.player:get_flag_int8(bo2.ePlayerFlag8_GiftAward)
  show_by_id(flag)
  local flag_award = bo2.player:get_flag_int8(bo2.ePlayerFlag8_BackWorldGiftAward)
  if flag_award ~= 0 then
    ui_gift_comeback.btn_get_gift.enable = true
  else
    ui_gift_comeback.btn_get_gift.enable = false
  end
end
local sig = L("ui_gift_comeback:sig_data")
local reg = ui_packet.game_recv_signal_insert
function handle_open_window(cmd, data)
  local win_type = data:get(packet.key.ui_window_type).v_string
  if win_type ~= L("back_world_gift") then
    return
  end
  local id = data[packet.key.cmn_id]
  show_by_id(id)
end
reg(packet.eSTC_UI_OpenWindow, handle_open_window, sig)
