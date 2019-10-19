function top_of(c)
  while c ~= nil do
    if c.name == L("cell_base") then
      return c.parent
    end
    c = c.parent
  end
  return nil
end
function data_of(c)
  local p = top_of(c)
  if p == nil then
    return nil
  end
  return p.svar.cell_data
end
function clear(c)
  ui_npcfunc.clear_card(c:search("card"))
  local lb = c:search("lb_item")
  if lb then
    lb.text = ""
  end
end
function clear_n(w, name)
  local c = w:search(name)
  clear(c)
end
function batch_clear(w, names)
  for i, v in pairs(names) do
    clear_n(w, v)
  end
end
function set(c, id, req)
  local excel = ui.item_get_excel(id)
  if excel == nil then
    clear(c)
    return
  end
  local card = c:search("card")
  card.excel_id = id
  if req == nil then
    card.require_count = 0
  else
    card.require_count = req
  end
  local item_name
  if card.info ~= nil then
    item_name = card.info.name
  else
    item_name = excel.name
  end
  local lb = c:search("lb_item")
  if lb then
    lb.color = ui.make_color(excel.plootlevel.color)
    lb.text = item_name
  end
end
function set_n(w, n, id, req)
  local c = w:search(n)
  set(c, id, req)
end
function drop(pn, info)
  if info == nil then
    return
  end
  local card = pn:search("card")
  ui_npcfunc.set_card(card, info.only_id)
  local excel = info.excel
  local lb = top_of(card):search("lb_item")
  if lb then
    local plootlevel_star = info.plootlevel_star
    if plootlevel_star ~= nil then
      lb.color = ui.make_color(info.plootlevel_star.color)
    else
      lb.color = ui.make_color(SHARED("FFFFFF"))
    end
    lb.text = info.name
  end
end
function check_drop(pn, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return false
  end
  ui.clean_drop()
  if not ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    return false
  end
  local info = ui.item_of_only_id(data:get("only_id"))
  if (bo2.eItemBox_BagBeg > info.box or info.box > bo2.eItemBox_Quest) and (bo2.eItemBox_RidePetBegin > info.box or info.box > bo2.eItemBox_RidePetEnd) and bo2.eItemArray_InSlot ~= info.box then
    return
  end
  return true
end
function on_drop(pn, msg, pos, data)
  if check_drop(pn, msg, pos, data) == false then
    return
  end
  local info = ui.item_of_only_id(data:get("only_id"))
  drop(pn, info)
end
function on_card_mouse(card, msg, pos, wheel)
  local icon = card.icon
  if icon == nil then
    return
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_drag then
    ui.set_cursor_icon(icon.uri)
    local function on_drop_hook(w, msg, pos, data)
      if msg == ui.mouse_drop_clean then
        clear(card.parent.parent)
      end
    end
    local data = sys.variant()
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  elseif msg == ui.mouse_rbutton_click then
    clear(card.parent.parent)
  end
end
function on_view_mouse(card, msg, pos, wheel)
end
function on_tip_show(tip)
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item(stk, excel, card.info, card)
  local stk_use
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
