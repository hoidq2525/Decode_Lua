local ui_tree2 = ui_widget.ui_tree2
local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
function product_count()
  local item = w_variety_view.item_sel
  if item == nil or item.depth ~= 2 then
    return 0
  end
  local item_excel = item.svar.item_excel
  local convert_excel = item.svar.convert_excel
  local raw_id = convert_excel.raw_id
  local raw_num = convert_excel.raw_num
  local count = math.floor(ui.item_get_count(raw_id, true) / raw_num)
  local medium_id = convert_excel.medium_id
  local medium_num = convert_excel.medium_num
  if medium_id > 0 then
    local t = math.floor(ui.item_get_count(medium_id, true) / medium_num)
    if count > t then
      count = t
    end
  end
  local player = ui_personal.ui_equip.safe_get_player()
  local money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney) + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
  t = math.floor(money / convert_excel.money)
  if count > t then
    count = t
  end
  local convert_id = convert_excel.id
  return count, convert_id
end
function do_product_update()
  local count = product_count()
  if count == 0 then
    w_btn_mat_convert.enable = false
    w_btn_max.enable = false
  else
    w_btn_mat_convert.enable = true
    w_btn_max.enable = true
  end
  ui_widget.ui_count_box.set_range(w_count_box, 1, count)
end
function post_product_update()
  w_variety_view:insert_post_invoke(do_product_update, "ui_npcfunc.ui_mat_convert.do_product_update")
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
    "mat_medium"
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
  local convert_excel = item.svar.convert_excel
  local item_excel = item.svar.item_excel
  ui_cell.set_n(w_detail, "product", convert_excel.pdt_id)
  ui_cell.set_n(w_detail, "mat_raw", convert_excel.raw_id, convert_excel.raw_num)
  ui_cell.set_n(w_detail, "mat_medium", convert_excel.medium_id, convert_excel.medium_num)
  ui_cmn.money_set(w_detail, convert_excel.money)
end
function on_visible(w, vis)
  do_product_update()
  ui_npcfunc.on_visible(w, vis)
end
function on_mat_convert_click(btn)
  local count, convert_id = product_count()
  if count == 0 then
    return
  end
  count = ui_widget.ui_count_box.get_value(w_count_box)
  if count == 0 then
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_MatConvert)
  v:set(packet.key.item_count, count)
  v:set(packet.key.mat_convert_excel_id, convert_id)
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
  item.svar.refine_variety = variety
  ui_tree2.set_text(item, variety.name)
  return item
end
local function build_leaf(convert_excel, node)
  if convert_excel == nil then
    return
  end
  local id = convert_excel.pdt_id
  if id == 0 then
    return
  end
  local item_excel = ui.item_get_excel(id)
  if item_excel == nil then
    return
  end
  local item = ui_tree2.insert(node, level)
  item.svar.item_excel = item_excel
  ui_tree2.set_text(item, item_excel.name, item_excel.plootlevel.color)
  item.svar.convert_excel = convert_excel
end
function on_init(ctrl)
  for i = 0, bo2.gv_refine_variety.size - 1 do
    local variety = bo2.gv_refine_variety:get(i)
    local node = build_node(variety)
    if node ~= nil then
      for j = 0, bo2.gv_mat_convert.size - 1 do
        local convert_excel = bo2.gv_mat_convert:get(j)
        local item_list_excel = ui.item_get_excel(convert_excel.pdt_id)
        if item_list_excel.variety == node.svar.refine_variety.id then
          build_leaf(convert_excel, node)
        end
      end
    end
  end
end
