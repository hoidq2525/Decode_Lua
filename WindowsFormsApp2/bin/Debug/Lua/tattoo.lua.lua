local g_board_id = 0
local g_board_lvl = 0
g_board_item = 0
local g_lowidx = 0
local g_higidx = 0
function on_init(ctrl)
  rawset(_M, "g_raws", {})
  g_board_id = 0
  g_board_lvl = 0
  g_board_item = 0
  g_lowidx = 0
  g_higidx = 0
  draw_board()
  local page_uri = "$frame/personal/tattoo.xml"
  local item_name = L("var_item")
  local item = g_varlist:item_append()
  item:load_style(page_uri, item_name)
  local desc = item:search("desc")
  desc.text = ui.get_text("personal|tatraw_hig")
  item = g_varlist:item_append()
  item:load_style(page_uri, item_name)
  desc = item:search("desc")
  desc.text = ui.get_text("personal|tatraw_low")
end
function on_init_box(ctrl)
  local ctop = ctrl:search("view")
  for i = 0, 31 do
    local c = ui.create_control(ctop, "panel")
    c:load_style(L("$frame/personal/tattoo.xml"), L("raw_cell"))
    c:search("card").name = "cell" .. i
  end
end
function on_box_plus_click(btn)
  local p = btn.parent
  btn.visible = false
  p:search("btn_minus").visible = true
  p = p.parent.parent
  p:search("view").visible = true
  p.dy = 330
end
function on_box_minus_click(btn)
  local p = btn.parent
  btn.visible = false
  p:search("btn_plus").visible = true
  p = p.parent.parent
  p:search("view").visible = false
  p.dy = 26
end
function draw_board()
  g_board:control_clear()
  if g_board_id > 0 then
    local name = "_" .. g_board_id
    g_cloth:set_item(0, 0, "$icon/tattoo/" .. name .. ".png")
    g_board:load_style("$icon/tattoo/frame.xml", name)
  else
    g_cloth:set_item(0, 0, "")
  end
end
function on_observable(w, vis)
  if sys.check(w_rawmain) then
    w_rawmain.visible = vis
  end
end
function on_raw_close(btn)
  w_rawmain.visible = false
end
function on_btn_raw_click(btn)
  w_rawmain.visible = true
end
function update_raw_wnd()
  local fillwnd = ui.find_control("$frame:tatfill")
  if fillwnd.visible then
    g_title.text = ui.get_text("personal|title_tatraw2")
    local bagwnd = ui.find_control("$frame:item")
    bagwnd.visible = false
  else
    g_title.text = ui.get_text("personal|title_tatraw")
  end
end
function on_raw_visible(w, vis)
  if vis then
    w_btn_raw.enable = false
    ui_personal.w_personal.dx = ui_personal.w_major.dx + w_rawmain.dx + 2
    update_raw_wnd()
  else
    w_btn_raw.enable = true
    ui_personal.w_personal.dx = ui_personal.w_major.dx
  end
end
function on_view_tip_show(tip)
  local card = tip.owner
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_tatlvl(stk, card)
  ui_tool.ctip_show(card, stk)
end
function on_cell_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  if excel ~= nil then
    local stk = sys.mtf_stack()
    if card.lock_id == bo2.eItemLock_Deal then
      ui_tool.ctip_make_tatraw(stk, excel, ui.get_text("personal|tattoo_stat2"), ui_tool.cs_tip_color_set_has)
    else
      ui_tool.ctip_make_tatraw(stk, excel, nil, "")
    end
    ui_tool.ctip_show(card, stk)
  end
end
function on_awd_tip_make(tip)
  local excel = ui.item_get_excel(g_board_item)
  if excel ~= nil then
    local stk = sys.mtf_stack()
    ui_tool.ctip_make_tatawd(stk, excel)
    ui_widget.tip_make_view(tip.view, stk.text)
  end
end
function on_rawcard_mouse(card, msg, pos, wheel)
  local fillwnd = ui.find_control("$frame:tatfill")
  if fillwnd.visible == false then
    return
  end
  local icon = card.icon
  if icon == nil then
    return
  end
  if msg == ui.mouse_lbutton_click then
    ui_npcfunc.ui_tatfill.set_rawcard(card)
  elseif msg == ui.mouse_rbutton_click then
    ui_npcfunc.ui_tatfill.clear_rawcard()
  end
end
function on_tattoo(cmd, data)
  local key = data:get(packet.key.item_key).v_int
  local itemid = data:get(packet.key.item_excelid).v_int
  if key == 1 then
    if g_board_item ~= itemid then
      local n = ui.item_get_excel(itemid)
      if n == nil or 1 > n.use_par.size then
        return
      end
      g_board_id = n.use_par[0]
      g_board_item = itemid
      draw_board()
    end
    g_board_lvl = data:get(packet.key.itemdata_idx).v_int
    ui_npcfunc.ui_tatequip.update_desc()
    local cap = g_board:search("40")
    if cap ~= nil then
      cap.visible = g_board_lvl < 3
    end
  else
    local idx = data:get(packet.key.itemdata_idx).v_int
    add_raw(key, itemid, idx)
  end
end
function add_raw(key, itemid, idx)
  local n = bo2.gv_tattoo_variety:find(key)
  if n == nil then
    return
  end
  local raw = g_raws[key]
  if raw == nil then
    local hig_view = g_varlist:item_get(0):search("view")
    local low_view = g_varlist:item_get(1):search("view")
    local card
    if n.type < bo2.eItemType_TattooRawHig then
      local cname = "cell" .. g_lowidx
      card = low_view:search(cname)
      g_lowidx = g_lowidx + 1
    else
      local cname = "cell" .. g_higidx
      card = hig_view:search(cname)
      g_higidx = g_higidx + 1
    end
    if card == nil then
      return
    end
    raw = {}
    raw.in_card = nil
    raw.out_card = card
    g_raws[key] = raw
  end
  raw.itemid = itemid
  raw.out_card.excel_id = itemid
  if idx == 0 then
    raw.out_card.lock_id = 0
    if raw.in_card ~= nil then
      raw.in_card.excel_id = 0
      raw.in_card = nil
    end
  else
    raw.out_card.lock_id = bo2.eItemLock_Deal
    raw.in_card = g_board:search(tostring(idx))
    if raw.in_card ~= nil then
      raw.in_card.excel_id = itemid
    end
  end
end
function get_board_excel()
  if g_board_id ~= 0 then
    return bo2.gv_tattoo_board:find(g_board_id)
  end
  return nil
end
function get_board_lvl()
  return g_board_lvl
end
