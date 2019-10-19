local g_init_flag = false
local g_group_id = 22
local item_tb = {}
function check_fn()
  return true
end
function check_all()
  local valid = false
  local line = bo2.gv_gift_award_owner:find(g_group_id)
  if line == nil then
    return valid
  end
  local gifts = line.gift
  if gifts == nil or gifts.size == 0 then
    return valid
  end
  for i = 0, gifts.size - 1 do
    local per_id = gifts[i]
    local n = bo2.gv_gift_award:find(per_id)
    if bo2.player:get_flag_bit(n.flag_id) == 0 and ui_gift_award.ui_svrbeg2.check_on_visible(n) == true then
      return true
    end
  end
  return false
end
function check_and_get_once()
  local line = bo2.gv_gift_award_owner:find(g_group_id)
  if line == nil then
    return valid
  end
  local gifts = line.gift
  if gifts == nil or gifts.size == 0 then
    return
  end
  for i = 0, gifts.size - 1 do
    local per_id = gifts[i]
    local n = bo2.gv_gift_award:find(per_id)
    if bo2.player:get_flag_bit(n.flag_id) == 0 and ui_gift_award.ui_svrbeg2.check_on_visible(n) == true then
      local btn = {}
      btn.svar = {}
      btn.svar.id = per_id
      on_btn_click_getgift(btn)
    end
  end
end
function on_init()
  g_init_flag = false
  g_group_id = 22
  item_tb = {}
  ui_gift_award.push_check_timer("comeback_gift", check_all)
  ui_gift_award.push_check_get_all("comeback_gift", check_and_get_once)
end
function on_btn_click_getgift(btn)
  local id = btn.svar.id
  if id ~= nil and id > 0 then
    local v = sys.variant()
    v:set(packet.key.cmn_id, id)
    bo2.send_variant(packet.eCTS_GiftAward_Get, v)
    local function reset_sel()
      set_item_state(id, item_tb[id])
    end
    if sys.type(btn) ~= "ui_button" then
      return
    end
    bo2.AddTimeEvent(10, reset_sel)
  end
end
local c_style_file = L("$frame/giftaward_v2/comeback_gift/comeback_gift.xml")
local c_style_item = L("cmn_item")
local c_cell_item = L("item_cell")
local c_cell_size = 52
function set_item_state(id, item)
  if item == nil then
    return
  end
  if sys.type(item) ~= "ui_list_item" then
    return
  end
  local btn = item:search("btn_getgift")
  if btn == nil then
    return
  end
  local line = bo2.gv_gift_award:find(id)
  if line == nil then
    return
  end
  if line.check_type[0] == 1 then
    local mylevel = ui.safe_get_atb(2)
    local minlevel = line.check_min[0]
    local v = sys.variant()
    v:set("cur_level", mylevel)
    v:set("level", minlevel)
    local item_show = item:search("item_show")
    item_show.mtf = sys.mtf_merge(v, ui.get_text("gift_award|level_show_gift"))
    if mylevel >= minlevel then
      local comp = bo2.player:get_flag_bit(line.flag_id)
      if comp == 1 then
        btn.enable = false
        btn.text = ui.get_text("gift_award|get_btn_over")
      else
        btn.enable = true
        btn.text = ui.get_text("gift_award|get_btn")
      end
    else
      btn.enable = false
      btn.text = ui.get_text("gift_award|get_btn")
    end
  end
end
function on_vis(mainpanel, vis)
  if vis == false then
    return
  end
  if g_init_flag == true then
    on_level_update(lv)
    return
  end
  g_init_flag = true
  local line = bo2.gv_gift_award_owner:find(g_group_id)
  if line == nil then
    return
  end
  local comment_ctrl = mainpanel:search("comment_mtf")
  if comment_ctrl ~= nil then
    comment_ctrl.mtf = line.desc
  end
  if sys.check(comeback_list) ~= true then
    return
  end
  local comeback_gifts = line.gift
  if comeback_gifts == nil or comeback_gifts.size == 0 then
    return
  end
  for i = 0, comeback_gifts.size - 1 do
    local comeback_item = comeback_list:item_append()
    comeback_item:load_style(c_style_file, c_style_item)
    local per_id = comeback_gifts[i]
    local per_line = bo2.gv_gift_award:find(per_id)
    if per_line ~= nil then
      local btn = comeback_item:search("btn_getgift")
      if btn ~= nil then
        btn.svar.id = per_line.id
      end
      local gift_items = per_line.award_items
      local items_count = per_line.items_count
      if gift_items ~= nil and gift_items.size > 0 and items_count.size == gift_items.size then
        for j = 0, gift_items.size - 1 do
          local ctop = comeback_item:search("citems")
          local ctrl = ui.create_control(ctop, "panel")
          ctrl:load_style(c_style_file, c_cell_item)
          ctrl.offset = ui.point(j * c_cell_size, 0)
          local card = ctrl:search("card")
          card.excel_id = gift_items[j]
          if items_count[j] > 1 then
            local count = ctrl:search("item_count")
            count.text = items_count[j]
          end
        end
      end
      set_item_state(per_id, comeback_item)
      item_tb[per_id] = comeback_item
    end
  end
end
function on_level_update(lv)
  local p_lv = bo2.player:get_atb(bo2.eAtb_Level)
  local line = bo2.gv_gift_award_owner:find(g_group_id)
  if line == nil then
    return
  end
  local comeback_gifts = line.gift
  if comeback_gifts == nil or comeback_gifts.size == 0 then
    return
  end
  for i = 0, comeback_gifts.size - 1 do
    local per_id = comeback_gifts[i]
    local per_line = bo2.gv_gift_award:find(per_id)
    if per_line ~= nil then
      local thelevel = per_line.check_min[0]
      if p_lv >= thelevel then
        local comp = bo2.player:get_flag_bit(per_line.flag_id)
        if comp ~= 1 then
          local item = item_tb[per_id]
          set_item_state(per_id, item)
        end
      end
    end
  end
end
