local ui_combo = ui_widget.ui_combo_box
local g_show_my = false
function on_init(ctrl)
  g_show_my = false
  local cb = w_main:search("cb_mainlb")
  for i = bo2.eAHLabel_Null, bo2.eAHLabel_Max - 1 do
    ui_combo.append(cb, {
      id = i,
      text = ui.get_text("supermarket|ah_mainlb_" .. i)
    })
  end
  ui_combo.select(cb, 0)
  cb.svar.on_select = on_mainlb_select
  cb.svar.on_select(ui_combo.selected(cb))
end
function on_req_refresh(ctrl)
  local v = sys.variant()
  if g_show_my then
    v:set(packet.key.cmn_type, bo2.eSupermarket_BrowseMyAHItem)
  else
    v:set(packet.key.cmn_type, bo2.eSupermarket_SearchAHItem)
    v:set(packet.key.cmn_name, w_main:search("itemname").text)
    v:set(packet.key.cha_name, w_main:search("ownername").text)
    if w_main:search("minlvl").text == L("") then
      v:set(packet.key.item_key3, -1)
    else
      v:set(packet.key.item_key3, w_main:search("minlvl").text.v_int)
    end
    if w_main:search("maxlvl").text == L("") then
      v:set(packet.key.item_key4, -1)
    else
      v:set(packet.key.item_key4, w_main:search("maxlvl").text.v_int)
    end
    if w_main:search("admall").check == true then
      v:set(packet.key.auction_admall, 1)
    end
    local item = ui_combo.selected(w_main:search("cb_mainlb"))
    if item ~= nil then
      v:set(packet.key.item_key1, item.id)
    end
    item = ui_combo.selected(w_main:search("cb_sublb"))
    if item ~= nil then
      v:set(packet.key.item_key2, item.id)
    end
  end
  local var = ui_supermarket.ui_ahitem.g_step.svar.stepping
  v:set(packet.key.mall_page_cur, var.index)
  local root = ui_supermarket.ui_ahitem.w_main:search("sort_title")
  local sort = root.svar.sort
  if sort ~= nil then
    v:set(packet.key.sort_name, sort.name)
    v:set(packet.key.sort_dir, sort.dir)
  end
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
end
function on_req_search(ctrl)
  g_show_my = false
  on_req_refresh(ctrl)
end
function on_req_my(ctrl)
  g_show_my = true
  on_req_refresh(ctrl)
end
function on_mainlb_select(item)
  local cb = w_main:search("cb_sublb")
  ui_combo.clear(cb)
  ui_combo.append(cb, {
    id = 0,
    text = ui.get_text("supermarket|ah_mainlb_0")
  })
  ui_combo.select(cb, 0)
  local group = 0
  if item.id == bo2.eAHLabel_Equip then
    for k = 0, bo2.gv_item_type.size - 1 do
      local type = bo2.gv_item_type:get(k)
      if type.group == bo2.eItemGroup_Equip then
        ui_combo.append(cb, {
          id = type.id,
          text = type.name
        })
      end
    end
    group = bo2.eItemGroup_Avata
  elseif item.id == bo2.eAHLabel_Medicine then
    group = bo2.eItemGroup_Medicine
  elseif item.id == bo2.eAHLabel_Precious then
    group = bo2.eItemGroup_Precious
  elseif item.id == bo2.eAHLabel_Pet then
    group = bo2.eItemGroup_Pet
  elseif item.id == bo2.eAHLabel_Book then
    group = bo2.eItemGroup_Book
  else
    return
  end
  for k = 0, bo2.gv_item_type.size - 1 do
    local type = bo2.gv_item_type:get(k)
    if type.group == group then
      ui_combo.append(cb, {
        id = type.id,
        text = type.name
      })
    end
  end
end
