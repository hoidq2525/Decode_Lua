local g_init_flag = false
local g_group_id = 21
local item_tb = {}
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
    return
  end
  local gifts = line.gift
  if gifts == nil or gifts.size == 0 then
    return valid
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
  g_group_id = 21
  item_tb = {}
  ui_gift_award.push_check_timer("levelup", check_all)
  ui_gift_award.push_check_get_all("levelup", check_and_get_once)
end
function on_btn_click_getgift(btn)
  local id = btn.svar.id
  if id ~= nil and id > 0 then
    local v = sys.variant()
    v:set(packet.key.cmn_id, id)
    bo2.send_variant(packet.eCTS_GiftAward_Get, v)
    local function reset_sel()
      local n = bo2.gv_gift_award:find(id)
      set_item_state(n.check_min[0], n.flag_id, item_tb[id])
    end
    if sys.type(btn) ~= "ui_button" then
      return
    end
    bo2.AddTimeEvent(10, reset_sel)
  end
end
local c_style_file = L("$frame/giftaward_v2/levelup_gift/levelup_gift.xml")
local c_style_item = L("cmn_level_item")
local c_cell_item = L("item_cell")
local c_cell_size = 52
function set_item_state(thelevel, theflag, item)
  if item == nil then
    return
  end
  local mylevel = ui.safe_get_atb(2)
  if thelevel > mylevel then
    item:search("level_up").color = ui.make_argb("AAFFFFFF")
    item:search("level_text").color = ui.make_argb("AAFFFFFF")
    item:search("btn_getgift").enable = false
    item:search("btn_getgift").text = ui.get_text("gift_award|gift_no_open")
  else
    item:search("level_up").color = ui.make_argb("FFFFFFFF")
    item:search("level_text").color = ui.make_argb("FF0080FF")
    local comp = bo2.player:get_flag_bit(theflag)
    if comp == 1 then
      item:search("btn_getgift").enable = false
      item:search("btn_getgift").text = ui.get_text("gift_award|get_btn_over")
    else
      item:search("btn_getgift").enable = true
      item:search("btn_getgift").text = ui.get_text("gift_award|get_btn")
    end
  end
end
function on_vis(mainpanel, vis)
  if vis == false then
    return
  end
  if g_init_flag == true then
    on_level_update()
    return
  end
  g_init_flag = true
  local line = bo2.gv_gift_award_owner:find(g_group_id)
  if line == nil then
    return
  end
  local comment_ctrl = mainpanel:search("comment_text")
  if comment_ctrl ~= nil then
    comment_ctrl.text = line.desc
  end
  local level_gifts = line.gift
  if level_gifts == nil or level_gifts.size == 0 then
    return
  end
  for i = 0, level_gifts.size - 1 do
    local level_item = level_list:item_append()
    level_item:load_style(c_style_file, c_style_item)
    local per_level_id = level_gifts[i]
    local per_level_line = bo2.gv_gift_award:find(per_level_id)
    if per_level_line ~= nil then
      local level_ctrl = level_item:search("level_text")
      if level_ctrl ~= nil then
        local need_level = per_level_line.check_min[0]
        local v = sys.variant()
        v:set("level", need_level)
        level_ctrl.text = sys.mtf_merge(v, ui.get_text("gift_award|levelup_level"))
      end
      local btn = level_item:search("btn_getgift")
      if btn ~= nil then
        btn.svar.id = per_level_line.id
      end
      local gift_items = per_level_line.award_items
      local items_count = per_level_line.items_count
      if gift_items ~= nil and gift_items.size > 0 and items_count.size == gift_items.size then
        for j = 0, gift_items.size - 1 do
          local ctop = level_item:search("citems")
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
      set_item_state(per_level_line.check_min[0], per_level_line.flag_id, level_item)
      item_tb[per_level_id] = level_item
    end
  end
end
function on_level_update(lv, only_check)
  local p_lv = bo2.player:get_atb(bo2.eAtb_Level)
  local line = bo2.gv_gift_award_owner:find(g_group_id)
  if line == nil then
    return
  end
  local level_gifts = line.gift
  if level_gifts == nil or level_gifts.size == 0 then
    return
  end
  for i = 0, level_gifts.size - 1 do
    local per_level_id = level_gifts[i]
    local per_level_line = bo2.gv_gift_award:find(per_level_id)
    if per_level_line ~= nil then
      local thelevel = per_level_line.check_min[0]
      if p_lv >= thelevel then
        local comp = bo2.player:get_flag_bit(per_level_line.flag_id)
        local item = item_tb[per_level_id]
        set_item_state(per_level_line.check_min[0], per_level_line.flag_id, item)
        if comp ~= 1 then
          ui_gift_award.set_new_mark("levelup")
        end
      end
    end
  end
end
