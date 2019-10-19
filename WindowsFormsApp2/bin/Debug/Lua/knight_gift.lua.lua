local g_init_flag = false
local g_any_knight_id = 901
local g_win_knight_id = 902
local item_tb = {}
local ids_tb = {g_any_knight_id, g_win_knight_id}
function check_all()
  if bo2.player == false then
    return false
  end
  local valid = false
  for i = 1, #ids_tb do
    local per_id = ids_tb[i]
    local n = bo2.gv_gift_award:find(per_id)
    if bo2.player:get_flag_bit(n.flag_id) == 0 and ui_gift_award.ui_svrbeg2.check_on_visible(n) == true then
      return true
    end
  end
  return false
end
function check_and_get_once()
  for i = 1, #ids_tb do
    local per_id = ids_tb[i]
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
  g_any_knight_id = 901
  g_win_knight_id = 902
  ids_tb = {g_any_knight_id, g_win_knight_id}
  item_tb = {}
  ui_gift_award.push_check_timer("knight_gift", check_all)
  ui_gift_award.push_check_get_all("knight_gift", check_and_get_once)
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
local c_style_file = L("$frame/giftaward_v2/knight_gift/knight_gift.xml")
local c_cell_item = L("item_cell")
local c_cell_size = 104
function set_item_state(id, item)
  if item == nil then
    return
  end
  local btn = item:search("btn_knight")
  if btn == nil then
    return
  end
  local cdlabel = item:search("knight_num")
  if cdlabel == nil then
    return
  end
  local knight_line = bo2.gv_gift_award:find(id)
  if knight_line == nil then
    return
  end
  local cd_id = knight_line.check_max[0]
  local cdline = bo2.gv_cooldown_list:find(cd_id)
  if cdline == nil then
    return
  end
  local num = bo2.get_cooldown_token(cd_id)
  local token = cdline.token
  if num > 0 then
    num = token - num
  else
    local isover = bo2.is_cooldown_over(cd_id)
    if isover == false then
      num = token - num
    else
      num = 0
    end
  end
  cdlabel.text = sys.format("(%d/%d)", num, token)
  if token > num then
    btn.enable = false
  else
    btn.enable = true
    local cooldown = knight_line.cooldown
    if cooldown ~= nil and 0 < cooldown.size then
      for i = 0, cooldown.size - 1 do
        if not bo2.is_cooldown_over(cooldown[i]) then
          btn.text = ui.get_text("gift_award|get_btn_over")
          btn.enable = false
        end
      end
    end
  end
end
function update_count(iswin)
  local valid = false
  for i = 1, #ids_tb do
    local id = ids_tb[i]
    local item = item_tb[id]
    if item ~= nil then
      set_item_state(id, item)
      ui_gift_award.set_new_mark("knight_gift")
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
    local knight_item = knight_list:item_get(i - 1)
    if knight_item == nil then
      return
    end
    local per_knight_line = bo2.gv_gift_award:find(ids_tb[i])
    if per_knight_line ~= nil then
      local knight_ctrl = knight_item:search("knight_name")
      knight_ctrl.text = per_knight_line.name
      local cd_id = per_knight_line.check_max[0]
      local cdline = bo2.gv_cooldown_list:find(cd_id)
      if cdline ~= nil then
        local count = cdline.token
        local v = sys.variant()
        v:set("num", count)
        local comment = knight_item:search("knight_comment")
        comment.text = sys.mtf_merge(v, per_knight_line.desc)
      end
      local btn = knight_item:search("btn_knight")
      if btn ~= nil then
        btn.svar.id = per_knight_line.id
      end
      local gift_items = per_knight_line.award_items
      local items_count = per_knight_line.items_count
      if gift_items ~= nil and 0 < gift_items.size and items_count.size == gift_items.size then
        for j = 0, gift_items.size - 1 do
          if j >= 3 then
            return
          end
          local ctop = knight_item:search("citems")
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
      set_item_state(ids_tb[i], knight_item)
      item_tb[ids_tb[i]] = knight_item
    end
  end
end
