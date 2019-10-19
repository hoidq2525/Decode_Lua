local g_init_flag = false
local item_tb = {}
local ids_tb = {
  3001,
  3002,
  3003,
  3004,
  3005,
  3006,
  3007,
  3008,
  3016
}
local id_for_big_gift = {
  3009,
  3010,
  3011,
  3012,
  3013,
  3014,
  3015,
  3016
}
local g_big_gift_id = 3016
local new_for_big_gift = 3017
function check_fn()
  if bo2.player == nil then
    return false
  end
  local valid = false
  for i = 1, #ids_tb do
    local per_id = ids_tb[i]
    local n = bo2.gv_gift_award:find(per_id)
    if bo2.player:get_flag_bit(n.flag_id) == 0 then
      valid = true
      break
    end
  end
  if valid == false then
    local create_time = bo2.player:get_flag_objmem(bo2.eFlagObjMemory_CreatePlayerTime)
    if create_time == 0 then
      return false
    end
    local is_old = bo2.is_old_obj(create_time, 2014, 3, 20, 6)
    if is_old == true then
      local n_new = bo2.gv_gift_award:find(new_for_big_gift)
      if bo2.player:get_flag_bit(n_new.flag_id) == 0 then
        valid = true
      end
    end
  end
  if valid == false then
    return false
  end
end
function check_all()
  if bo2.player == nil then
    return false
  end
  local valid = false
  for i = 1, #ids_tb do
    local per_id = ids_tb[i]
    local n = bo2.gv_gift_award:find(per_id)
    if per_id ~= g_big_gift_id and bo2.player:get_flag_bit(n.flag_id) == 0 and ui_gift_award.ui_svrbeg2.check_on_visible(n) == true then
      return true
    end
  end
  local create_time = bo2.player:get_flag_objmem(bo2.eFlagObjMemory_CreatePlayerTime)
  if create_time == 0 then
    return false
  end
  local is_old = bo2.is_old_obj(create_time, 2014, 3, 20, 6)
  local line = 0
  if is_old == false then
    line = bo2.gv_gift_award:find(g_big_gift_id)
  else
    line = bo2.gv_gift_award:find(new_for_big_gift)
  end
  if bo2.player:get_flag_bit(line.flag_id) == 0 and ui_gift_award.ui_svrbeg2.check_on_visible(line) == true then
    return true
  end
  return false
end
function on_init()
  g_init_flag = false
  g_big_gift = 3016
  ids_tb = {
    3001,
    3002,
    3003,
    3004,
    3005,
    3006,
    3007,
    3008,
    3016
  }
  id_for_big_gift = {
    3009,
    3010,
    3011,
    3012,
    3013,
    3014,
    3015,
    3016
  }
  item_tb = {}
  ui_gift_award.push_check_timer("newer_gift", check_all)
end
function find_right_id(id)
  if id == new_for_big_gift then
    return g_big_gift_id
  end
  for i, v in pairs(id_for_big_gift) do
    if id == v then
      return g_big_gift_id
    end
  end
end
function on_btn_click_getgift(btn)
  local id = btn.svar.id
  if id ~= nil and id > 0 then
    local v = sys.variant()
    v:set(packet.key.cmn_id, id)
    bo2.send_variant(packet.eCTS_GiftAward_Get, v)
    local function reset_sel()
      local item = item_tb[id]
      if item ~= nil then
        set_item_state(id, item)
      else
        local theid = find_right_id(id)
        item = item_tb[theid]
        set_item_state(theid, item)
      end
    end
    bo2.AddTimeEvent(10, reset_sel)
  end
end
local c_style_file = L("$frame/giftaward_v2/newer_gift/newer_gift.xml")
local c_cell_item = L("item_cell")
local c_cell_size = 54
function set_item_state(id, item)
  if item == nil then
    return
  end
  local btn = item:search("btn_newer")
  if btn == nil then
    return
  end
  local newer_line = bo2.gv_gift_award:find(id)
  if newer_line == nil then
    return
  end
  local num = newer_line.check_min[0]
  local cur_num = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_LoginCount)
  if id == g_big_gift_id then
    local check_in_month = cur_num
    local create_time = bo2.player:get_flag_objmem(bo2.eFlagObjMemory_CreatePlayerTime)
    if create_time == 0 then
      return false
    end
    local is_old = bo2.is_old_obj(create_time, 2014, 3, 20, 6)
    if is_old == true then
      cur_num = 35
      item:search("text_for_new").visible = false
      item:search("text_for_old").visible = true
      btn.svar.id = new_for_big_gift
      newer_line = bo2.gv_gift_award:find(new_for_big_gift)
    else
      item:search("text_for_new").visible = true
      item:search("text_for_old").visible = false
      local cur_time = ui_main.get_os_time()
      cur_num = bo2.get_obj_create_day(create_time, cur_time)
      local day_lable = item:search("day_num")
      if day_lable == nil then
        return
      end
      day_lable.text = cur_num
      local login_label = item:search("login_num")
      if login_label == nil then
        return
      end
      login_label.text = check_in_month
      if check_in_month > 8 then
        check_in_month = 8
      end
      btn.svar.id = id_for_big_gift[check_in_month]
      local cards_tb = item.svar.cards
      for i = #cards_tb, 0, -1 do
        if i >= check_in_month then
          cards_tb[i].draw_gray = true
        end
      end
    end
  end
  if num <= cur_num then
    local comp = bo2.player:get_flag_bit(newer_line.flag_id)
    if comp == 1 then
      btn.text = ui.get_text("gift_award|get_btn_over")
      btn.enable = false
    else
      btn.text = ui.get_text("gift_award|get_btn")
      btn.enable = true
    end
  else
    btn.text = ui.get_text("gift_award|get_btn")
    btn.enable = false
  end
end
function update_count()
  local valid = false
  for i = 1, #ids_tb do
    local id = ids_tb[i]
    local item = item_tb[id]
    if item ~= nil then
      set_item_state(id, item)
      ui_gift_award.set_new_mark("newer_gift")
    end
  end
end
function on_vis(mainpanel, vis)
  if vis == false then
    return
  end
  if g_init_flag == true then
    update_count()
    return
  end
  g_init_flag = true
  for i = 1, #ids_tb do
    local newer_item = newer_list:item_get(i - 1)
    if newer_item == nil then
      if ids_tb[i] == g_big_gift_id then
        newer_item = g_big_gift_item
      else
        return
      end
    end
    local per_newer_line = bo2.gv_gift_award:find(ids_tb[i])
    if per_newer_line ~= nil then
      local newer_ctrl = newer_item:search("newer_name")
      if newer_ctrl ~= nil then
        local need_num = per_newer_line.check_min[0]
        local v = sys.variant()
        v:set("num", need_num)
        newer_ctrl.text = sys.mtf_merge(v, ui.get_text("gift_award|newer_day"))
      end
      local btn = newer_item:search("btn_newer")
      if btn ~= nil then
        btn.svar.id = per_newer_line.id
      end
      local gift_items = per_newer_line.award_items
      local items_count = per_newer_line.items_count
      if gift_items ~= nil and 0 < gift_items.size and items_count.size == gift_items.size then
        for j = 0, gift_items.size - 1 do
          local ctop = newer_item:search("citems")
          local ctrl = ui.create_control(ctop, "panel")
          ctrl:load_style(c_style_file, c_cell_item)
          ctrl.offset = ui.point(j * c_cell_size, 0)
          local card = ctrl:search("card")
          card.excel_id = gift_items[j]
          if items_count[j] > 1 then
            local count = ctrl:search("item_count")
            count.text = items_count[j]
          end
          if ids_tb[i] == g_big_gift_id then
            if newer_item.svar.cards == nil then
              newer_item.svar.cards = {}
            end
            newer_item.svar.cards[j] = card
          end
        end
      end
      set_item_state(ids_tb[i], newer_item)
      item_tb[ids_tb[i]] = newer_item
    end
  end
end
