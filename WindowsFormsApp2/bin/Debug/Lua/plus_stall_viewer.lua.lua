local item_file = "$gui/frame/stall/plus_stall_viewer.xml"
local item_style = "stall_item"
local type_item_style = L("type_list_item")
local view_scn = 0
local sig_data = "ui_stall.scan_data"
local g_list_data = {}
local g_item_list = {}
local g_scan_data = {}
g_market_statistics = {}
function on_clear_item_info()
  if sys.check(g_list) then
    g_list:item_clear()
  end
  for i, v in pairs(g_item_list) do
    local key = i
    if key ~= nil then
      ui.item_remove(key)
      ui.ride_remove_view(key)
    end
  end
  g_item_list = {}
  g_market_statistics = {}
end
g_filter_data = {
  type_level = 100,
  may_use = false,
  item_type = 1,
  min = 0,
  max = 99,
  down_money = false
}
function remove_list_key(key)
  market_statistics_remove(g_item_list[key])
  g_item_list[key] = nil
end
function on_init_list()
  g_list_data = {
    request = -1,
    scan = false,
    scan_count = 10,
    item_count = 0,
    ride_count = 50
  }
  g_scan_data = {}
  on_clear_item_info()
end
function get_ride_pet_name(onlyid)
  local ride_info = ui.get_ride_info(onlyid)
  local ridepet_excel = bo2.gv_ridepet_list:find(ride_info:get_flag(bo2.eRidePetFlagInt32_RidePetListId))
  return ridepet_excel.name
end
function market_statistics_remove(item)
  if item == nil then
    return
  end
  local only_id = item.key
  local base_name = item.name
  local name = ui_stall.get_item_record_name(base_name, info)
  if g_market_statistics[name] == nil then
    return
  end
  local data = g_market_statistics[name]
  local all_info = data.key_list[only_id]
  if all_info == nil then
    return
  end
  local info_money = all_info.money
  local high = data.high
  local low = data.low
  local update_price = false
  if info_money == low or info_money == high then
    update_price = true
  end
  if data.total >= all_info.money and data.count >= all_info.cnt then
    data.total = data.total - all_info.money * all_info.cnt
    data.count = data.count - all_info.cnt
    if data.count > 0 then
      data.average = math.floor(data.total / data.count)
    else
      data.average = 0
    end
  end
  data.cmn_average = 0
  data.key_list[only_id] = nil
  if update_price then
    do
      local count = 0
      for i, v in pairs(data.key_list) do
        do
          local function process_refind_high_low()
            if v == nil then
              return
            end
            local v_money = v.money
            if count == 0 then
              if info_money == low then
                data.low = v_money
              end
              if info_money == high then
                data.high = v_money
              end
            else
              if v_money < data.low then
                data.low = v_money
              end
              if v_money > data.high then
                data.high = v_money
              end
            end
            count = count + 1
          end
          process_refind_high_low()
        end
      end
      if count <= 0 then
        g_market_statistics[name] = nil
      end
    end
  end
end
function update_market_statistics(item, money, cnt)
  local info = item.info
  if sys.check(info) ~= true then
    return false
  end
  local only_id = info.only_id
  local base_name = item.name
  local name = ui_stall.get_item_record_name(base_name, info)
  if g_market_statistics[name] == nil then
    g_market_statistics[name] = {
      high = money,
      low = money,
      average = money,
      total = money * cnt,
      count = cnt,
      cmn_average = 0,
      key_list = {}
    }
    g_market_statistics[name].key_list[only_id] = item
    return
  end
  local data = g_market_statistics[name]
  local c = data.key_list[only_id]
  if c ~= nil then
    if c.cnt ~= nil then
      local total_money = c.cnt * c.money
      if total_money <= data.total then
        data.total = data.total - total_money
      else
        data.total = 0
      end
      if data.count >= c.cnt then
        data.count = data.count - c.cnt
      else
        data.count = 0
      end
      data.total = data.total + money * cnt
      data.count = data.count + cnt
      if data.count ~= 0 then
        data.average = math.floor(data.total / data.count)
      else
        data.average = 0
      end
      data.cmn_average = 0
      data.key_list[only_id] = item
      return
    else
      data.key_list[only_id] = item
      return
    end
  end
  data.total = data.total + money * cnt
  data.count = data.count + cnt
  data.average = math.floor(data.total / data.count)
  data.cmn_average = 0
  if money > data.high then
    data.high = money
  elseif money < data.low then
    data.low = money
  end
  data.key_list[only_id] = item
end
function calc_cmn_average(name)
  local record_name = ui_stall.get_item_record_name(name, info)
  if g_market_statistics[record_name] == nil then
    return 0
  end
  local data = g_market_statistics[record_name]
  local total_money = data.total
  local total_count = data.count
  for i, v in pairs(data.key_list) do
    if sys.check(v.info) and v.money > data.average * 8 then
      total_money = total_money - v.money * v.cnt
      total_count = total_count - v.cnt
    end
  end
  if data.count == 0 then
    data.cmn_average = 0
  else
    data.cmn_average = math.floor(total_money / total_count)
  end
  return data.cmn_average
end
function get_item_market_statistics(name, info)
  local record_name = ui_stall.get_item_record_name(name, info)
  if g_market_statistics[record_name] == nil then
    return 0, 0, 0, 0, 0
  end
  local data = g_market_statistics[record_name]
  return data.low, data.high, data.average, data.count, data.cmn_average
end
function on_level_input_change(tb, txt)
  local tb_name = tb.name
  local min = 0
  local max = 0
  local type = 0
  if tb_name == L("num0") then
    min = txt.v_int
  else
    max = txt.v_int
    type = 1
  end
  if type == 0 then
    if g_filter_data.min == min then
      return
    end
    g_filter_data.min = min
    if min > g_filter_data.max then
      if min < 99 then
        plus_stall_viewer.w_max.text = min + 1
        g_filter_data.max = min + 1
      else
        plus_stall_viewer.w_min.text = 0
        g_filter_data.min = 0
      end
    end
  end
  if type == 1 then
    if g_filter_data.max == max then
      return
    end
    g_filter_data.max = max
    if max < g_filter_data.min then
      if max > 0 then
        plus_stall_viewer.w_min.text = max - 1
        g_filter_data.min = max - 1
      else
        g_filter_data.max = 99
        plus_stall_viewer.w_max.text = 99
      end
    end
  end
  on_refresh_result()
end
function on_init_filter_type_list()
  local insert_type = function(type_idx)
    local _text = sys.format("stall|item_type_%d", type_idx)
    local _tip_text = sys.format("stall|item_type_tip_%d", type_idx)
    _text = ui.get_text(_text)
    _tip_text = ui.get_text(_tip_text)
    g_filter_data.list[g_filter_data.list_count] = {
      type = type_idx,
      text = _text,
      tip_text = _tip_text
    }
    local tab = g_filter_data.list[g_filter_data.list_count]
    if type_idx == 1 then
      tab.fun = check_item_type_all
    elseif type_idx == 2 or type_idx == 3 or type_idx == 4 then
      tab.fun = check_equip_type
    elseif type_idx == 5 then
      tab.fun = check_item_ride_pet
    elseif type_idx == 6 then
      tab.fun = check_is_gem
    elseif type_idx == 7 then
      tab.fun = check_material
    elseif type_idx == 8 then
      tab.fun = check_scroll
    elseif type_idx == 9 then
      tab.fun = check_item_idx
    elseif type_idx == 10 then
      tab.fun = check_cmn_bag
    elseif type_idx == 11 then
      tab.fun = process_all_check
    end
    g_filter_data.list_count = g_filter_data.list_count + 1
  end
  g_filter_data.list_count = 1
  g_filter_data.list = {}
  for i = 1, g_max_check_type do
    insert_type(i)
  end
end
on_init_filter_type_list()
function on_refresh_result()
  on_click_search()
end
function set_filter_item_type(type)
  if g_filter_data.item_type == type then
    return
  end
  g_filter_data.item_type = type
  on_refresh_result()
end
function set_filter_may_use(use)
  if g_filter_data.may_use == use then
    return
  end
  g_filter_data.may_use = use
  on_refresh_result()
end
function set_filter_type_level(level)
  if g_filter_data.type_level == level then
    return
  end
  g_filter_data.type_level = level
  local lootlevel = bo2.gv_lootlevel:find(level)
  if lootlevel == nil then
    return
  end
  btn_filter_item_level.text = lootlevel.name
  btn_filter_item_level.color = ui.make_color(lootlevel.color)
  on_refresh_result()
end
function on_click_set_check(btn)
  set_filter_may_use(btn.check)
end
function on_click_set_low_price(btn)
  dm(btn.check)
end
function on_esc_stk_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis then
    UpdateMoney()
  else
  end
end
function get_sorce(info)
  if info == nil then
    return
  end
end
function on_rb_sel(box, msg)
  local item = box:upsearch_name(L("stall_item"))
  if sys.check(item) then
    on_cmn_item_mouse(item, msg)
  end
  if msg == ui.mouse_lbutton_click then
    item.selected = true
  end
end
function update_highlight(item)
  item:search("fig_highlight").visible = item.selected or item.inner_hover
end
function on_cmn_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    update_highlight(item)
  end
  if msg == ui.mouse_lbutton_dbclick then
  elseif msg == ui.mouse_lbutton_dbl then
    on_open_stall()
  end
end
function on_down_money_mouse(p, msg)
  if msg == ui.mouse_lbutton_down then
  end
end
function on_click_set_type_filter(item)
  set_filter_item_type(item.svar.id)
end
function on_init()
  lv_item_type_list:item_clear()
  local function insert_type_item(idx, value)
    local item = lv_item_type_list:item_append()
    item:load_style(item_file, type_item_style)
    local btn = item:search(L("btn"))
    btn.text = value.text
    btn.svar.id = idx
    btn.group = lv_item_type_list
    btn.tip.text = value.tip_text
    if idx == 1 then
      btn.press = true
    end
  end
  for i = 1, g_filter_data.list_count - 1 do
    insert_type_item(i, g_filter_data.list[i])
  end
end
function on_item_select(item, sel)
  item:search("fig_highlight").visible = sel
  item:search("fig_highlight_sel").visible = sel
end
function on_open_stall(btn)
  local item = g_list.item_sel
  if item == nil then
    return
  end
  local card = item:search("card")
  if sys.check(card) then
    ui_stall.viewer.insert_flick_item(card.only_id)
  end
  local v = sys.variant()
  v:set(packet.key.scnobj_handle, item.svar.handle)
  bo2.send_variant(packet.eCTS_UI_GetStallSur, v)
end
function set_list_data(item, data)
  local card = item:search("card")
  card.only_id = data.key
  local item_name = item:search("item")
  local item_level = item:search("level")
  local item_score = item:search(L("score"))
  local item_owner = item:search("name")
  local item_cnt = item:search("count")
  local item_money = item:search("money")
  if data.level > 0 then
    item_level.text = data.level
    item_level.visible = true
  else
    item_level.visible = false
  end
  if sys.check(data.info) ~= true then
    return
  end
  if data.plus_ride ~= nil then
    local ride_info = ui.get_ride_info(data.key)
    item_name.mtf = sys.format(ui.get_text("plus_stall_viewer|mtf_ride"), ui.ride_encode(ride_info))
  else
    item_name.mtf = sys.format(ui.get_text("plus_stall_viewer|mtf_item"), data.info.code)
  end
  local score = 0
  if data.score == nil then
    data.score = ui_tool.ctip_calculate_item_rank(data.excel, data.info)
  end
  score = data.score
  item_score.mtf = sys.format(ui.get_text("plus_stall_viewer|mtf_sorce"), score)
  local t = get_key_table(data.handle)
  item_owner.mtf = sys.format(ui.get_text("plus_stall_viewer|mtf_name"), t.cha_name)
  item_cnt.mtf = sys.format(ui.get_text("plus_stall_viewer|mtf_count"), data.cnt)
  item_money.mtf = sys.format(ui.get_text("plus_stall_viewer|mtf_money"), data.money)
  item.svar.handle = data.handle
  item.svar.score = data.score
  item.svar.count = data.cnt
  item.svar.money = data.money
  item.svar.level = data.level
  item.svar.type_level = data.plootlevel
end
local g_mode_data = {
  items = {},
  auto_size = true,
  dx = 120,
  dy = 50,
  event = function(item)
    local cb = item.callback
    if cb == nil then
      return
    end
    cb(item)
  end
}
local function insert_level(i)
  local md = g_mode_data
  local lootlevel = bo2.gv_lootlevel:find(i)
  if lootlevel == nil then
    return
  end
  local md = g_mode_data
  local item_text = lootlevel.name
  local item_color = ui.make_color(lootlevel.color)
  table.insert(md.items, {
    text = item_text,
    color = item_color,
    callback = function()
      set_filter_type_level(i)
    end
  })
end
function init_menu_item()
  insert_level(100)
  for i = 11, 17 do
    insert_level(i)
  end
end
init_menu_item()
function on_show_item_level_menu(btn)
  local menu = g_mode_data
  menu.source = btn
  ui_tool.show_menu(menu)
  menu.consult = btn
end
function on_add_item_0(item, inner)
  on_add_item(item)
end
function on_add_list_item(item, list_idx)
  local list_count = g_list.item_count
  local item_ctrl
  if list_idx >= list_count then
    item_ctrl = g_list:item_append()
    item_ctrl:load_style(item_file, item_style)
  else
    item_ctrl = g_list:item_get(list_idx)
    item_ctrl.visible = true
  end
  item.ctrl = item_ctrl
  set_list_data(item_ctrl, item)
end
function on_add_item(item)
  local key = item.key
  local t = item_v[key]
  local list_item = list_table[key]
  if list_item == nil then
    list_item = g_list:item_append()
    list_item:load_style(item_file, item_style)
    list_table[key] = list_item
  end
  set_item(list_item, t)
end
function check_reqire(kind, val)
  if kind == bo2.eItemReq_Career then
    local prof = ui.safe_get_atb(bo2.eAtb_Cha_Profession)
    local profExcel = bo2.gv_profession_list:find(prof)
    if profExcel == nil then
      return false
    end
    if profExcel.career ~= val then
      return false
    end
  elseif kind == bo2.eItemReq_Profession then
    local color
    if ui.safe_get_atb(bo2.eAtb_Cha_Profession) ~= val then
      return false
    end
  elseif kind == bo2.eItemReq_MaxLevel then
    if val > ui.safe_get_atb(bo2.eAtb_Level) then
      return false
    end
  elseif kind == bo2.eItemReq_Sex then
    if ui.safe_get_atb(bo2.eAtb_Sex) ~= val then
      return false
    end
  elseif kind == bo2.eItemReq_XinFaLevel then
    local xinfaLv = bo2.GetZhuZhiXinFaLevel()
    if val > xinfaLv then
      return false
    end
  elseif kind == bo2.eItemReq_GuildTitle then
    local color
    local member_self = ui.guild_get_self()
    if sys.check(member_self) ~= true or val > member_self.title then
      return false
    end
  end
  return true
end
function process_info(item)
  local function process_ride()
    if item.plus_ride ~= nil then
      local ride_info = ui.get_ride_info(item.key)
      if ride_info == nil or sys.check(ride_info) ~= true then
        ui.ride_insert_view(item.plus_ride)
      end
    end
  end
  if item.info ~= nil and sys.check(item.info) then
    process_ride()
    return true
  end
  local info = ui.item_of_only_id(item.key)
  if info == nil then
    item.info = ui.item_create_data(bo2.eItemList_Mall_SellPet, 0, item.item_data)
  else
    item.info = info
  end
  process_ride()
  return info ~= nil
end
function process_filter(item)
  local info = item.info
  if sys.check(info) ~= true then
    return false
  end
  local excel = info.excel
  if g_filter_data.type_level ~= 100 then
    local type_level = info.plootlevel_star
    if type_level == nil then
      type_level = excel.plootlevel_star
    end
    type_level = type_level.id
    local g_type_level = g_filter_data.type_level
    if type_level < g_type_level then
      return false
    end
  end
  local req_level = excel.reqlevel
  if req_level < g_filter_data.min or req_level > g_filter_data.max then
    return false
  end
  if g_filter_data.may_use == true then
    local lv = info.excel.reqlevel
    local self_level = ui.safe_get_atb(bo2.eAtb_Level)
    if lv > self_level then
      return false
    end
    if sys.is_type(info.excel, ui_tool.cs_tip_mb_data_equip_item) then
      local pro = ui.safe_get_atb(bo2.eAtb_Cha_Profession)
      local prof_excel = bo2.gv_profession_list:find(pro)
      local career = prof_excel.career
      local damage = prof_excel.damage
      local requires = excel.requires
      local cnt = requires.size
      for i = 0, cnt - 1 do
        if check_reqire(requires[i - 1], requires[i]) ~= true then
          return false
        end
      end
    end
  end
  if g_filter_data.item_type ~= 1 then
    local tab = g_filter_data.list[g_filter_data.item_type]
    if tab ~= nil and tab.fun ~= nil and tab.fun(info, g_filter_data.item_type, item) ~= true then
      return false
    end
  end
  if g_filter_data.down_money == true and check_low_price(item) ~= true then
    return false
  end
  return true
end
function search_item(name)
  local text_table
  local t_size = 0
  if 0 < name.size and name ~= L(" ") then
    local var = sys.variant()
    var:set(L("0"), name)
    text_table = var:get(L("0")):split_to_no_repeat_array(L(" "))
    t_size = text_table.size - 1
  end
  local function on_found_text(_name)
    if text_table == nil then
      return true
    else
      for i = 0, t_size do
        local n = text_table[i]
        if 0 < n.size and n ~= L(" ") then
          local find_text_idx = _name:find(n)
          if find_text_idx < 0 then
            return false
          end
        end
      end
    end
    return true
  end
  local item_count = 0
  for i, v in pairs(g_scan_data) do
    for m, item in pairs(v.all_item) do
      if process_info(item) and process_filter(item) then
        local name = item.name
        if on_found_text(name) ~= false then
          on_add_list_item(item, item_count)
          item_count = item_count + 1
        end
      end
    end
  end
  if item_count <= 0 and name.empty ~= true then
    local text = ui.get_text("stall|no_found")
    ui_tool.note_insert(text, L("FFFF0000"))
  end
  local total_count = g_list.item_count
  for i = item_count, total_count - 1 do
    local item_ctrl = g_list:item_get(i)
    item_ctrl.visible = false
  end
  on_sort(nil, 1)
  local item = g_list.item_sel
  if item ~= nil and sys.check(item) then
    item.selected = false
  end
end
function on_click_search()
  search_item(g_keyword_box.text)
end
function on_click_cliear()
  g_list:item_clear()
  item_v = {}
  list_table = {}
  item_money = {}
  g_down_panel.visible = false
end
function on_input_change(tb, txt)
  input_mask.visible = g_keyword_box.text.empty
end
function on_keydown_return(ctrl, key, keyflag)
  if key == ui.VK_RETURN and keyflag.down then
    on_click_search(ctrl)
  end
end
function on_click_cliear_search()
end
local stk_push_new_line = function(stk)
  stk:push("\n")
end
function finish_stk_value(stk, name, info, type)
  local min_mony = 0
  local max_mony = 0
  local average_mony = 0
  local total_count = 0
  if name ~= nil then
    min_mony, max_mony, average_mony, total_count = get_item_market_statistics(name, info)
  end
  if type ~= 2 then
    stk:push(sys.format(L("<c+:%s>"), ui_tool.cs_tip_color_operation))
    stk:push(L("<a+:mid>"))
    stk:push(ui.get_text("stall|sale_market_title"))
    stk:push(sys.format(L("<c->")))
    stk:push(ui_tool.cs_tip_sep)
  else
    stk:push(L("<a+:mid>"))
    stk:push(ui.get_text("stall|sale_market_title"))
    stk_push_new_line(stk)
  end
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
  stk:push(ui.get_text("stall|total_count"))
  stk:push(total_count)
  return average_mony, min_mony, max_mony
end
function on_card_market_statistics_show(tip)
  local stk = sys.stack()
  local function fill_stk()
    local item = g_list.item_sel
    if item == nil then
      stk:push(ui.get_text(L("stall|unsel_tip")))
      return
    end
    local card = item:search("card")
    local info = ui.item_of_only_id(card.only_id)
    local name
    if info:is_ridepet() then
      name = get_ride_pet_name(card.only_id)
    else
      name = info.excel.name
    end
    finish_stk_value(stk, name, info, 1)
  end
  fill_stk()
  ui_tool.ctip_show(tip.owner, stk, nil)
end
function check_may_use_stk2()
  if sys.check(bo2.scn) ~= true then
    return false
  end
  if bo2.scn.excel.id ~= view_scn then
    return false
  end
  if ui_stall.owner.gx_main_window.visible == false and ui_stall.viewer.g_viewer.visible == false then
    return false
  end
  return true
end
function get_item_stk2_plus(excel, info)
  local name = excel.name
  if info:is_ridepet() then
    name = get_ride_pet_name(info.only_id)
  end
  local stk_use = sys.stack()
  finish_stk_value(stk_use, name, info, 1)
  return stk_use
end
function get_item_stk2(excel, info)
  local stk_use0 = get_item_stk2_plus(excel, info)
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    local stk_use_c = ui_item.tip_get_using_equip(excel)
    if stk_use_c ~= nil then
      stk_use0:push(ui_tool.cs_tip_sep)
      stk_use0:push(stk_use_c.text)
    end
    return stk_use0
  end
  return stk_use0
end
function show_tip(card)
  local excel = card.excel
  if not excel then
    return
  end
  local stallitem = g_item_list[card.only_id]
  if stallitem == nil then
    return
  end
  local info = card.info
  if info == nil then
    return
  end
  local stk = sys.mtf_stack()
  stk:raw_push(L("<a+:mid>"))
  ui_stall.make_price_tip(stk, stallitem, card.svar)
  stk:raw_push(L("<a->"))
  ui_tool.ctip_push_sep(stk)
  if info:is_ridepet() == false then
    ui_tool.ctip_make_item_without_price(stk, excel, card.info)
  else
    local ride_info = ui.get_ride_info(info.only_id)
    if ride_info == nil then
      return
    end
    ui_personal.ui_ridepet.build_ridepet_tip(stk, ride_info)
  end
  if stallitem.card_op_tip_leftkey ~= nil then
    ui_tool.ctip_push_operation(stk, stallitem.card_op_tip_leftkey)
  end
  ui_tool.ctip_push_operation(stk, ui.get_text("stall|dbl_click"))
  if ui_fitting_room.test_item_may_suit(excel) ~= false then
    ui_tool.ctip_push_operation(stk, ui.get_text("stall|ctrl_and_mclick"))
  elseif excel.fitting_index then
    local equip_excel = bo2.gv_equip_item:find(excel.fitting_index)
    if sys.check(equip_excel) then
      ui_tool.ctip_push_operation(stk, ui.get_text("stall|ctrl_and_mclick"))
    end
  end
  local stk_use = get_item_stk2(excel, info)
  ui_tool.ctip_show(card, stk, stk_use)
end
function on_tip_show(tip)
  local owner = tip.owner
  local card = owner.parent:search("card")
  show_tip(card)
end
function on_card_tip_show(tip)
  local card = tip.owner
  show_tip(card)
end
function on_widget_mouse(box, data, msg, pt)
  if msg == ui.mouse_mbutton_click and ui.is_key_down(ui.VK_CONTROL) then
    ui_widget.ui_chat_list.on_widget_mouse(box, data, msg, pt)
  end
end
local g_last_btn
function on_sort(base_btn, base_order)
  local btn = base_btn
  if base_order ~= nil then
    if g_last_btn == nil then
      g_last_btn = btn_default
      btn = btn_default
    else
      btn = g_last_btn
    end
  end
  if base_btn ~= nil then
    g_last_btn = base_btn
  end
  if btn.svar.sort == nil then
    btn.svar.sort = false
  end
  if base_order == nil then
    btn.svar.sort = not btn.svar.sort
  end
  local order = btn.svar.sort
  btn_down.visible = order
  btn_up.visible = not order
  local margin = ui.rect(btn.x + btn.dx - 20, 0, 0, 0)
  btn_down.margin = margin
  btn_up.margin = margin
  local fn
  local function cmn_sort(a, b)
    if order then
      if b < a then
        return -1
      elseif a == b then
        return 0
      else
        return 1
      end
    elseif b < a then
      return 1
    elseif a == b then
      return 0
    else
      return -1
    end
  end
  local function score_sort(a, b)
    return cmn_sort(a.svar.score, b.svar.score)
  end
  local function money_sort(a, b)
    return cmn_sort(a.svar.money, b.svar.money)
  end
  local function count_sort(a, b)
    return cmn_sort(a.svar.count, b.svar.count)
  end
  local function type_level_sort(a, b)
    return cmn_sort(a.svar.type_level, b.svar.type_level)
  end
  fn = money_sort
  if btn.name == L("score") then
    fn = score_sort
  elseif btn.name == L("money") then
    fn = money_sort
  elseif btn.name == L("count") then
    fn = count_sort
  elseif btn.name == L("lootlevel") then
    fn = type_level_sort
  end
  g_list:item_sort(fn)
end
function dm(check)
  g_filter_data.down_money = check
  on_refresh_result()
end
function UpdateMoney()
  if bo2.player then
    local money = bo2.player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    w_gamemoneylb.money = money
  end
end
function on_self_enter()
  view_scn = bo2.gv_define:find(592).value.v_int
  g_last_btn = nil
  on_init_list()
  bo2.player:insert_on_flagmsg(bo2.bo2.eFlagType_Int32, bo2.eFlagInt32_CirculatedMoney, UpdateMoney, "plus_stall_viewer.money")
  ui_packet.game_recv_signal_remove(packet.eSTC_Stall_SendList, sig_data)
end
function refresh_data(check_cd)
  if check_cd ~= nil and bo2.IsCoolDownOver(30122) ~= true then
    return
  end
  local req = g_list_data.request
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_StallScan)
  v:set(bo2.eRequestModelType_StaticData, req)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  g_list_data.tick = sys.tick()
  g_list_data.item_count = 0
end
function on_close()
  w_main.visible = false
end
function on_click_refresh_data()
  refresh_data()
end
function on_open()
  w_main.visible = true
  refresh_data(true)
end
function get_key_table(key)
  if g_scan_data[key] == nil then
    g_scan_data[key] = {
      request = 0,
      s_request = 0,
      cha_name = 0,
      all_item = {}
    }
  end
  return g_scan_data[key]
end
function handle_client_static_data(key, data)
  local t = get_key_table(key)
  t.s_request = data:get(packet.key.ui_request_id).v_int
  local key_data = data:get(packet.key.stall_items_key)
  local packet_data = key_data:get(packet.key.append_data)
  t.cha_name = packet_data:get(packet.key.cha_name).v_string
  t.client_id = key
end
local do_post_count = 0
function relink_info(key, cnt, disable_post)
  if cnt == 0 then
    if g_item_list[key] ~= 0 then
      local item = g_item_list[key]
      local t = get_key_table(item.handle)
      if t.all_item[key] ~= nil then
        local info = t.all_item[key].info
        if sys.check(info) and info.box == bo2.eItemList_Mall_SellPet then
          remove_list_key(key)
          ui_stall.stall_item_remove(key)
        end
      end
      t.all_item[key] = nil
      remove_list_key(key)
    end
    if disable_post == nil and do_post_count == 0 then
      do_post_count = 1
      local function do_post()
        do_post_count = 0
        if w_main.visible == true then
          on_click_search()
        end
      end
      bo2.AddTimeEvent(5, do_post)
    else
    end
    return
  end
  if key ~= nil and g_item_list[key] then
    local item = g_item_list[key]
    process_info(item)
    update_market_statistics(item, item.money, cnt)
    item.cnt = cnt
  end
  if disable_post == nil and do_post_count == 0 then
    do_post_count = 1
    local function do_post()
      do_post_count = 0
      if w_main.visible == true then
        on_click_search()
      end
    end
    bo2.AddTimeEvent(5, do_post)
  else
  end
end
function build_item_info(data)
  local item = data
  if data.plus_ride ~= nil then
    data.plus_ride:set(packet.key.item_grid, g_list_data.ride_count)
    g_list_data.ride_count = g_list_data.ride_count + 1
    ui.ride_insert_view(data.plus_ride)
  end
  item.info = ui.item_of_only_id(data.key)
  if item.info == nil then
    item.info = ui.item_create_data(bo2.eItemList_Mall_SellPet, 0, data.item_data)
  end
  if item.info:is_ridepet() then
    item.name = get_ride_pet_name(item.info.only_id)
  else
    item.name = item.info.excel.name
  end
  item.level = item.info.excel.reqlevel
  item.excel = item.info.excel
  local type_level = item.info.plootlevel_star.id
  if type_level == nil then
    type_level = item.info.excel.plootlevel_star.id
  end
  item.plootlevel = type_level
end
function fill_packet(client_id, data)
  local cnt = data:get(packet.key.item_count).v_int
  if cnt <= 0 then
    return
  end
  local t = get_key_table(client_id)
  local item = {}
  item.key = data:get(packet.key.item_key).v_string
  item.cnt = cnt
  item.money = data:get(packet.key.cmn_money).v_int
  item.item_data = data:get(packet.key.itemdata_all)
  item.plus_ride = nil
  if data:has(packet.key.ridepet_item_val) == true then
    item.plus_ride = data:get(packet.key.ridepet_item_val)
  end
  item.handle = client_id
  build_item_info(item)
  item.is_sale = true
  update_market_statistics(item, item.money, cnt)
  t.all_item[item.key] = item
  g_item_list[item.key] = item
  g_list_data.item_count = g_list_data.item_count + 1
end
function handle_client_run_time_data(key, data)
  local t = get_key_table(key)
  t.request = data:get(packet.key.ui_request_id).v_int
  for i, v in pairs(t.all_item) do
    if i ~= nil then
      remove_list_key(i)
    end
    if sys.check(v.info) and v.info.box == bo2.eItemList_Mall_SellPet then
      ui_stall.stall_item_remove(i)
    end
  end
  t.all_item = {}
  local itemdata_all = data:get(packet.key.itemdata_all)
  local detal_data = itemdata_all:get(packet.key.append_data)
  local c_item = detal_data.size
  for i = 0, c_item - 1 do
    local n, v = detal_data:fetch_nv(i)
    fill_packet(key, v)
  end
end
function find_item_info(key)
  if key == nil then
    return false
  end
  return g_item_list[key] ~= nil
end
local update_tab = {}
update_tab[bo2.eRequestModelType_StaticData] = handle_client_static_data
update_tab[bo2.eRequestModelType_RuntimeData] = handle_client_run_time_data
function make_scan_over()
  ui_packet.game_recv_signal_remove(packet.eSTC_Stall_SendList, sig_data)
  g_list_data.scan = false
  g_mask_panel.visible = false
  local mtf = {}
  if g_list_data.item_count > 0 then
    mtf.time = sys.dtick(sys.tick(), g_list_data.tick)
    mtf.time = sys.format(L("%.3f"), mtf.time / 1000)
    mtf.count = g_list_data.item_count
    local text = ui_widget.merge_mtf(mtf, ui.get_text("stall|finish_scan_text"))
    ui_tool.note_insert(text, L("FF00FF00"))
  else
    mtf.time = sys.dtick(sys.tick(), g_list_data.tick)
    mtf.time = sys.format(L("%.3f"), mtf.time / 1000)
    local text = ui_widget.merge_mtf(mtf, ui.get_text("stall|finish_scan"))
    ui_tool.note_insert(text, L("FF00FF00"))
  end
  on_click_search()
end
function process_erase_closed_stall(all_packet)
  local client_count = all_packet.size - 1
  local g_temp_client_table = {}
  for m = 0, client_count do
    local n, v_data = all_packet:fetch_nv(m)
    local client = v_data:get(packet.key.cha_client_id).v_int
    g_temp_client_table[client] = 1
  end
  for i, v in pairs(g_scan_data) do
    if i ~= nil and g_temp_client_table[i] == nil then
      for key, value in pairs(v.all_item) do
        relink_info(key, 0, true)
      end
      g_scan_data[i].all_item = nil
      g_scan_data[i] = nil
    end
  end
end
function refresh_notify_text(c_current_count, count)
  local mtf = {}
  mtf.persent = 50
  if count > 0 then
    mtf.persent = c_current_count / count * 100
    mtf.persent = sys.format(L("%.2f"), mtf.persent)
  end
  lb_refresh_text.text = ui_widget.merge_mtf(mtf, ui.get_text("stall|refresh_text"))
end
function handle_scan_data(cmd, data)
  if data:has(packet.key.goods_vip) then
    ui_tool.note_insert(ui.get_text(L("stall|vip_desc")), L("FFFF0000"))
    return
  end
  if data:has(packet.key.ranklist_data) ~= true then
    if data:has(packet.key.scnobj_flag) then
      make_scan_over()
      return
    end
    return
  end
  if g_list_data.scan == true then
    return
  end
  local req0 = data:get(packet.key.ranklist_data)
  local req = req0:get(bo2.eRequestModelType_StaticData)
  g_list_data.request = req:get(packet.key.ui_request_id).v_int
  local data = req:get(packet.key.item_list)
  local push_data = data:get(packet.key.append_data)
  local count = push_data.size
  process_erase_closed_stall(push_data)
  if count <= 0 then
    make_scan_over()
    return
  end
  g_list_data.scan = true
  g_mask_panel.visible = true
  local c_current_count = 0
  refresh_notify_text(c_current_count, count)
  local function on_process_next()
    if c_current_count >= count then
      make_scan_over()
      return false
    end
    local send_packet = sys.variant()
    local c_count = 0
    local new_count = count - 1
    for m_i = c_current_count, new_count do
      if g_list_data.scan_count == nil or c_count >= g_list_data.scan_count then
        break
      end
      local n, v_data = push_data:fetch_nv(m_i)
      local client = v_data:get(packet.key.cha_client_id).v_int
      local run_request = v_data:get(bo2.eRequestModelType_RuntimeData).v_int
      local insert = false
      local client_tab = get_key_table(client)
      if client_tab.request ~= run_request then
        insert = true
      end
      if insert == true then
        c_count = c_count + 1
        local new_data = v_data
        new_data:set(bo2.eRequestModelType_StaticData, client_tab.s_request)
        new_data:set(bo2.eRequestModelType_RuntimeData, 0)
        send_packet:push_back(new_data)
      end
      c_current_count = c_current_count + 1
    end
    refresh_notify_text(c_current_count, count)
    if 0 < send_packet.size then
      local v = sys.variant()
      v:set(packet.key.talk_excel_id, bo2.eNpcFunc_StallScan)
      v:set(packet.key.ranklist_data, send_packet)
      bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
      return true
    else
      make_scan_over()
      return false
    end
  end
  local rst = on_process_next()
  if rst == false then
    return
  end
  ui_packet.game_recv_signal_remove(packet.eSTC_Stall_SendList, sig_data)
  local function scan_all_data(cmd, data)
    if data:has(packet.key.ranklist_data) then
      return
    end
    local size = data.size
    for i = 0, size - 1 do
      local n, m_data = data:fetch_nv(i)
      local client_id = m_data[packet.key.cha_client_id]
      local val_packet = m_data:get(packet.key.append_data)
      for key, fun in pairs(update_tab) do
        if val_packet:has(key) then
          local s_data = val_packet:get(key)
          fun(client_id, s_data)
        end
      end
    end
    on_process_next()
  end
  ui_packet.game_recv_signal_insert(packet.eSTC_Stall_SendList, scan_all_data, sig_data)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_stall.scan"
reg(packet.eSTC_Stall_SendList, handle_scan_data, sig)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "plus_stall_viewer.money")
function r()
  w_main.visible = true
  g_list:item_clear()
  on_self_enter()
  on_click_open_stall()
end
local g_surround_info_list = {}
function on_click_open_stall()
  local list = ui_stall.surround.gx_stalllist
  local count = list.item_count
  local search_table = {}
  local reg = ui_packet.game_recv_signal_insert
  local sig = L("ui_stall0:sig_data")
  ui_packet.game_recv_signal_remove(packet.eSTC_UI_AddStallItem, sig)
  ui_packet.game_recv_signal_remove(packet.eSTC_UI_OpenWindow, sig)
  local function on_msg_callback(msg)
    g_search_count = false
    ui_packet.game_recv_signal_remove(packet.eSTC_UI_AddStallItem, sig)
    ui_packet.game_recv_signal_remove(packet.eSTC_UI_OpenWindow, sig)
    search_table = {}
  end
  local quit_text = sys.format(L("Process Data size????!!!!"))
  local g_second_confirm_data = {text = quit_text, callback = on_msg_callback}
  ui_widget.ui_msg_box.show_common(g_second_confirm_data)
  local g_process_list = {}
  g_process_list.size = 0
  local function on_finish()
    local window = g_second_confirm_data.window
    if sys.check(window) then
      window.visible = false
    end
    ui_packet.game_recv_signal_remove(packet.eSTC_UI_AddStallItem, sig)
    ui_packet.game_recv_signal_remove(packet.eSTC_UI_OpenWindow, sig)
    on_refresh_result()
    ui_tool.note_insert(sys.format(L("Process finish")), L("FF00FF00"))
  end
  for i = 0, count - 1 do
    local idx = i
    local ctr = list:item_get(idx)
    if sys.check(ctr) then
      local parent = ctr:upsearch_name("show_info")
      if sys.check(parent) then
        local cb = parent
        local svar = cb.svar
        local stall_key = svar.stall_key
        if g_surround_info_list[stall_key] == nil then
          g_process_list[g_process_list.size] = ctr
          g_process_list.size = g_process_list.size + 1
        end
      end
    end
  end
  local totoal_count = g_process_list.size
  local idx = 0
  local stall_key = 0
  local function on_scan_all()
    local ctr = g_process_list[idx]
    if sys.check(ctr) then
      ui_stall.surround.stall_item_on_mouse(ctr, ui.mouse_lbutton_dbl)
      local parent = ctr:upsearch_name("show_info")
      if sys.check(parent) then
        local cb = parent
        local svar = cb.svar
        stall_key = svar.stall_key
        g_surround_info_list[stall_key] = 1
      end
    end
    local window = g_second_confirm_data.window
    if sys.check(window) then
      local mtf = window:search("rv_text")
      mtf.text = sys.format(L("Process %d/%d..."), idx + 1, totoal_count, idx + 1)
    end
    if idx >= totoal_count - 1 then
      g_search_count = false
      on_finish()
    end
    idx = idx + 1
  end
  on_scan_all()
  local function handle_open_window(cmd, data)
    local win_type = data:get(packet.key.ui_window_type).v_string
    if win_type ~= L("stall_view") then
      return
    end
    local function on_time()
      on_scan_all()
    end
    handle_client_static_data(stall_key, data)
    bo2.AddTimeEvent(25, on_time)
  end
  local function handle_add_stall_item(cmd, data)
    local function on_time()
      fill_packet(stall_key, data)
    end
    bo2.AddTimeEvent(1, on_time)
  end
  reg(packet.eSTC_UI_AddStallItem, handle_add_stall_item, sig)
  reg(packet.eSTC_UI_OpenWindow, handle_open_window, sig)
end
function on_mask_mouse(w, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    w.visible = false
  end
end
