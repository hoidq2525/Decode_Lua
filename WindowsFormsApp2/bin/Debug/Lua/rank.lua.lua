function add_ranklist(v)
  local root = g_ranklist
  root:item_clear()
  local rank_list = v:split_to_int_array("*")
  for i = 0, rank_list.size - 1 do
    local cell = root:item_append()
    local goods_id = rank_list:get(i).v_int
    if goods_id < ui_supermarket.BJGOODS_ID_MAX then
      cell:load_style("$frame/supermarket/rank.xml", "bjgoods_cell")
    else
      cell:load_style("$frame/supermarket/rank.xml", "goods_cell")
    end
    local card = cell:search("goods_icon")
    card.excel_id = goods_id
  end
end
function add_goods(data)
  local goods_id = data:get(packet.key.cmn_id).v_int
  local root = g_ranklist
  for i = 0, root.item_count - 1 do
    local cell = root:item_get(i)
    local card = cell:search("goods_icon")
    if card.excel_id == goods_id then
      data:set(packet.key.ranklist_id, i + 1)
      ui_supermarket.ui_shelf.set_cell(cell, data)
      cell.visible = true
      return
    end
  end
end
function showall()
  local root = g_ranklist
  for i = 0, root.item_count - 1 do
    local cell = root:item_get(i)
    cell.visible = true
  end
end
function is_in_page(goods_id, goods_page)
  local data = ui_supermarket.get_goods_data(goods_id)
  if data == nil then
    return false
  end
  local prefix = "shelf_"
  if goods_id < ui_supermarket.BJGOODS_ID_MAX then
    prefix = "bjshelf_"
  end
  local v = data:get(packet.key.goods_page)
  local a = v:split_to_int_array("*")
  for i = 0, a.size - 1 do
    local page_id = math.floor(a:get(i).v_int / 10)
    local page_name = prefix .. page_id
    if page_name == goods_page then
      return true
    end
  end
  v = data:get(packet.key.goods_search)
  a = v:split_to_int_array("*")
  for i = 0, a.size - 1 do
    local page_id = math.floor(a:get(i).v_int / 10)
    local page_name = prefix .. page_id
    if page_name == goods_page then
      return true
    end
  end
  return false
end
function filter(goods_page)
  local root = g_ranklist
  for i = 0, root.item_count - 1 do
    local cell = root:item_get(i)
    local card = cell:search("goods_icon")
    if is_in_page(card.excel_id, goods_page) then
      cell.visible = true
    else
      cell.visible = false
    end
  end
end
