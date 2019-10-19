local ui_tree2 = ui_widget.ui_tree2
local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local get_med_id = function(variety, level)
  local med_id
  if variety.arr_med_id.size ~= 0 then
    med_id = variety.arr_med_id[level - 1]
  end
  return med_id
end
local get_med_cnt = function(variety, level)
  local med_cnt
  if variety.arr_med_cnt.size ~= 0 then
    med_cnt = variety.arr_med_cnt[level - 1]
  end
  return med_cnt
end
function product_count()
  local item = w_variety_view.item_sel
  if item == nil or item.depth ~= 2 then
    return 0
  end
  local variety = item.owner.svar.stuff_variety
  local item_excel = item.svar.item_excel
  local level = item_excel.varlevel
  local pdt_id = variety.inc_items[level]
  local raw_id = variety.inc_items[level - 1]
  local raw_cnt = variety.count
  local count = math.floor(ui.item_get_count(raw_id, true) / raw_cnt)
  local med_id = get_med_id(variety, level)
  local med_req_cnt = get_med_cnt(variety, level)
  if med_id ~= nil and med_id ~= 0 then
    local med_cnt = math.floor(ui.item_get_count(med_id, true) / med_req_cnt)
    if count > med_cnt then
      count = med_cnt
    end
  end
  local player = ui_personal.ui_equip.safe_get_player()
  local money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney) + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
  if variety.is_circulated ~= 0 then
    money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
  end
  t = math.floor(money / variety.arr_money[level - 1])
  if count > t then
    count = t
  end
  return count, pdt_id
end
function do_product_update()
  local count = product_count()
  if count == 0 then
    w_btn_stuff_upgrade.enable = false
    w_btn_max.enable = false
  else
    w_btn_stuff_upgrade.enable = true
    w_btn_max.enable = true
  end
  ui_widget.ui_count_box.set_range(w_count_box, 1, count)
end
function post_product_update()
  w_variety_view:insert_post_invoke(do_product_update, "ui_npcfunc.ui_stuff_upgrade.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  local c = ui_cell.top_of(card)
  if c.name == L("product") then
    return
  end
  post_product_update()
end
local function detail_clear()
  ui_cell.batch_clear(w_detail, {
    "product",
    "mat_raw",
    "mat_med"
  })
end
function on_item_sel(item, sel)
  local depth = item.depth
  if depth ~= 2 then
    return
  end
  post_product_update()
  if not sel then
    detail_clear()
    return
  end
  local variety = item.owner.svar.stuff_variety
  local item_excel = item.svar.item_excel
  local level = item_excel.varlevel
  ui_cell.set_n(w_detail, "product", variety.inc_items[level])
  local raw_id = variety.inc_items[level - 1]
  local raw_cnt = variety.count
  ui_cell.set_n(w_detail, "mat_raw", raw_id, raw_cnt)
  local med_id = get_med_id(variety, level)
  if med_id == nil or med_id == 0 then
    ui_cell.batch_clear(w_detail, {"mat_med"})
  else
    local med_req_cnt = get_med_cnt(variety, level)
    ui_cell.set_n(w_detail, "mat_med", med_id, med_req_cnt)
  end
  local lb_money = w_detail:search("lb_money")
  lb_money.bounded = true
  if variety.is_circulated ~= 0 then
    lb_money.bounded = false
  end
  ui_cmn.money_set(w_detail, variety.arr_money[level - 1])
end
function on_visible(w, vis)
  do_product_update()
  ui_npcfunc.on_visible(w, vis)
end
function on_stuff_upgrade_click(btn)
  local count, pdt_id = product_count()
  if count == 0 then
    return
  end
  count = ui_widget.ui_count_box.get_value(w_count_box)
  if count == 0 then
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_StuffUpgrade)
  v:set(packet.key.item_count, count)
  v:set(packet.key.item_excelid, pdt_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function on_max_click(btn)
  ui_widget.ui_count_box.set_max(w_count_box)
end
local function build_node(variety)
  local t = variety.type
  if t == 0 then
    return nil
  end
  local item = ui_tree2.insert(w_variety_view.root)
  item.svar.stuff_variety = variety
  ui_tree2.set_text(item, variety.name)
  return item
end
local function build_leaf(id, node)
  if id == 0 then
    return
  end
  local item_excel = ui.item_get_excel(id)
  if item_excel == nil then
    return
  end
  local level = item_excel.varlevel
  if level == 0 then
    return
  end
  local item = ui_tree2.insert(node, level)
  item.svar.item_excel = item_excel
  ui_tree2.set_text(item, item_excel.name, item_excel.plootlevel.color)
end
function on_init(ctrl)
  for i = 0, bo2.gv_stuff_variety.size - 1 do
    local variety = bo2.gv_stuff_variety:get(i)
    local node = build_node(variety)
    if node ~= nil then
      for k = 0, variety.inc_items.size - 1 do
        build_leaf(variety.inc_items[k], node)
      end
    end
  end
end
