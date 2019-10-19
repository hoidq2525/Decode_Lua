fit_equip_excl = nil
if rawget(_M, "g_tip_frames") == nil then
  g_tip_frames = {}
  w_tip_top = 0
  g_tip_prev = 0
  w_gain_top = 0
  g_gain_timer = 0
  t_gain_data = {}
  t_gain_queue = {}
  c_gain_limit = 3
  c_gain_delay = 400
  c_gain_wait = 5000
  g_gain_update_tick = 0
end
local c_tip_frame_max = 20
local print_frames = function()
  local idx = 0
  for i, v in ipairs(g_tip_frames) do
    ui.log("frames %d, %s.", i, v)
  end
end
local update_frames = function(wnd)
  wnd:move_to_head()
  wnd.dock = "pin_xy"
  w_tip_top:apply_dock(false)
  local vis_cnt = 0
  for i, v in ipairs(g_tip_frames) do
    if v.visible then
      vis_cnt = vis_cnt + 1
    end
  end
  if vis_cnt == 1 then
    return
  end
  local midx = ui_main.w_top.dx * 0.5
  local midy = ui_main.w_top.dy * 0.5
  local wnd1 = g_tip_frames[1]
  if wnd1 == nil or not wnd1.visible then
    return
  end
  wnd1.dock = "none"
  wnd1.offset = ui.point(midx - wnd1.dx - 4, midy - wnd1.dy * 0.5)
  local wnd2 = g_tip_frames[2]
  if wnd2 == nil or not wnd2.visible then
    return
  end
  wnd2.dock = "none"
  wnd2.offset = ui.point(midx + 4, midy - wnd2.dy * 0.5)
end
function show_tip_frame(txt, excel, info)
  txt = L(txt)
  local function init_btn_fitting_value(wnd, excel)
    local panel_btn = wnd:search(L("fitting"))
    panel_btn.visible = false
    local function try_add_variant(excel)
      local bFitting, iEquipType = ui_fitting_room.test_item_may_suit(excel)
      if bFitting ~= false and iEquipType ~= nil then
        panel_btn.visible = true
        panel_btn.var:set(1, iEquipType)
        panel_btn.var:set(2, excel.model)
      end
    end
    panel_btn.var:clear()
    if info then
      if excel.id == 58212 then
        local id = info:get_data_32(bo2.eItemInt32_BarberShopProp1)
        local pExcel = bo2.gv_equip_item:find(id)
        if sys.is_type(pExcel, ui_tool.cs_tip_mb_data_equip_item) then
          try_add_variant(pExcel)
        elseif sys.check(pExcel) and pExcel.fitting_index then
          local equip_excel = bo2.gv_equip_item:find(pExcel.fitting_index)
          if sys.check(equip_excel) then
            try_add_variant(equip_excel)
          end
        end
      elseif excel.id == 58210 then
        local id1 = info:get_data_32(bo2.eItemInt32_BarberShopProp1)
        local id2 = info:get_data_32(bo2.eItemInt32_BarberShopProp2)
        if id1 > 0 then
          local pExcel = bo2.gv_barber_shop:find(id1)
          if pExcel == nil then
            return
          end
          panel_btn.visible = true
          panel_btn.var:set(1, bo2.eEquipData_Face)
          panel_btn.var:set(2, pExcel._data)
        end
        if id2 > 0 then
          local pExcel = bo2.gv_barber_shop:find(id2)
          if pExcel == nil then
            return
          end
        end
      elseif excel.id == 58211 then
        local id1 = info:get_data_32(bo2.eItemInt32_BarberShopProp1)
        local id2 = info:get_data_32(bo2.eItemInt32_BarberShopProp2)
        if id1 > 0 then
          local pExcel = bo2.gv_barber_shop:find(id1)
          if pExcel == nil then
            return
          end
          panel_btn.visible = true
          panel_btn.var:set(1, bo2.eEquipData_Hair)
          panel_btn.var:set(2, pExcel._data)
        end
        if id2 > 0 then
          local pExcel = bo2.gv_barber_shop:find(id2)
          if pExcel == nil then
            return
          end
          panel_btn.visible = true
          panel_btn.var:set(3, bo2.eBarberShop_HairColor)
          panel_btn.var:set(4, pExcel._hex_data)
        end
      end
    end
    if sys.is_type(excel, ui_tool.cs_tip_mb_data_equip_item) then
      try_add_variant(excel)
    elseif sys.check(excel) and excel.fitting_index then
      local equip_excel = bo2.gv_equip_item:find(excel.fitting_index)
      if sys.check(equip_excel) then
        try_add_variant(equip_excel)
      end
    end
  end
  local wnd
  local idx = 0
  for i, v in ipairs(g_tip_frames) do
    if not sys.check(v) then
      g_tip_frames = {}
      g_tip_prev = 0
      break
    end
    if not v.visible then
      idx = i
      wnd = v
      break
    end
    if excel and v.svar.tip_frame_text == txt then
      init_btn_fitting_value(v, excel, info)
      ui_handson_teach.test_complate_view_item_tip(excel.id, true)
      update_frames(v)
      return
    end
  end
  if wnd == nil then
    idx = #g_tip_frames
    if idx >= c_tip_frame_max then
      wnd = g_tip_frames[1]
      table.remove(g_tip_frames, 1)
    else
      idx = idx + 1
      if not sys.check(w_tip_top) then
        w_tip_top = ui.create_control(ui_main.w_top)
        w_tip_top.dock = "fill_xy"
        w_tip_top.dock_solo = true
        w_tip_top.priority = 124
        w_tip_top.size = ui_main.w_top.size
      end
      wnd = ui.create_control(w_tip_top)
      wnd.visible = false
      wnd:load_style("$frame/item/item.xml", "frame_tip")
    end
    table.insert(g_tip_frames, idx, wnd)
  end
  if excel then
    init_btn_fitting_value(wnd, excel, info)
  end
  local slider_y = wnd:search("rb_text").slider_y
  slider_y.visible = false
  ui_widget.tip_make_view(wnd, txt)
  if wnd.dx < 192 then
    wnd.dx = 192
    wnd:tune_y("rb_text")
  end
  if excel == nil and wnd.dy > 600 then
    wnd.dy = 600
    slider_y.visible = true
  end
  wnd.svar.tip_frame_text = txt
  wnd.visible = true
  local qb = wnd:search("quick_buy_ref").parent
  local goods_id = 0
  if excel then
    goods_id = ui_supermarket2.shelf_quick_buy_id(excel.id)
  end
  if goods_id > 0 then
    qb.visible = true
    qb.name = goods_id
  else
    qb.visible = false
  end
  local title = wnd:search("tip_title")
  title.text = ui.get_text("tip|item_title")
  update_frames(wnd)
  if excel then
    ui_handson_teach.test_complate_view_item_tip(excel.id, true)
  end
  return wnd
end
function show_ridepet_tip_frame(txt)
  local wnd = show_tip_frame(txt)
  if wnd ~= nil then
    local title = wnd:search("tip_title")
    title.text = ui.get_text("tip|ridepet_title")
  end
end
function show_tip_frame_card(card)
  local excel = card.excel
  if excel == nil then
    return
  end
  fit_equip_excl = excel
  local info = card.info
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item(stk, excel, info, card)
  show_tip_frame(stk.text, excel, info)
end
function on_frame_tip_visible(ctrl, vis)
  ui_widget.on_esc_stk_visible(ctrl, vis)
  if vis then
    return
  end
  local idx = 0
  for i, v in ipairs(g_tip_frames) do
    if v == ctrl then
      idx = i
      break
    end
  end
  if idx > 0 then
    table.remove(g_tip_frames, idx)
    table.insert(g_tip_frames, ctrl)
  end
end
function on_frame_tip_close_all(btn)
  local frames = {}
  for i, v in ipairs(g_tip_frames) do
    if v.visible then
      table.insert(frames, v)
    end
  end
  for i, v in ipairs(frames) do
    v.visible = false
  end
end
function on_frame_tip_close_other(btn)
  local t = btn.topper
  local frames = {}
  for i, v in ipairs(g_tip_frames) do
    if v.visible and v ~= t then
      table.insert(frames, v)
    end
  end
  for i, v in ipairs(frames) do
    v.visible = false
  end
end
function on_click_fitting_item(btn)
  local _panel = btn.parent
  local iEquipType = _panel.var:get(1).v_int
  local iExcelData = _panel.var:get(2).v_int
  ui_fitting_room.on_click_fitting_item(iEquipType, iExcelData, fit_equip_excl)
  local iHair = _panel.var:get(3).v_int
  if iHair == 3 then
    local iHairColor = _panel.var:get(4).v_int
    ui_fitting_room.on_set_hair_color(iHairColor)
  end
end
function on_gain_timer(t)
  local tick = sys.tick()
  local dtick = sys.dtick(tick, g_gain_update_tick)
  if dtick < c_gain_delay then
    return
  end
  if #t_gain_queue == 0 then
    if dtick > c_gain_wait then
      w_gain_top.visible = false
      g_gain_timer.suspended = true
      for i = 1, c_gain_limit do
        t_gain_data[i].view.visible = false
      end
    end
    return
  end
  g_gain_update_tick = tick
  local d = t_gain_data[1]
  table.remove(t_gain_data, 1)
  table.insert(t_gain_data, d)
  local v = d.view
  v:reset()
  v:move_to_head()
  v.visible = true
  local excel_id = t_gain_queue[1]
  table.remove(t_gain_queue, 1)
  d.card.excel_id = excel_id
end
function gain_insert(excel_id)
  if ui_loading.w_top.visible then
    return
  end
  table.insert(t_gain_queue, excel_id)
  while #t_gain_queue > c_gain_limit do
    table.remove(t_gain_queue, 1)
  end
  if ui_qbar ~= nil then
    local off = ui_qbar.w_btn_item:control_to_window(ui.point(22, 36)) - w_gain_top.size
    w_gain_top.offset = off
  end
  if not w_gain_top.visible then
    w_gain_top.visible = true
    g_gain_update_tick = sys.tick() - c_gain_delay
    g_gain_timer.suspended = false
  end
end
function play_sound_del(excel)
  if excel == nil then
    return
  end
  local item_type = excel.ptype
  if item_type == nil then
    return
  end
  local s = item_type.sound_del
  if s == 0 then
    return
  end
  bo2.PlaySound2D(s)
end
function play_sound_add(excel)
  if excel == nil then
    return
  end
  local item_type = excel.ptype
  if item_type == nil then
    return
  end
  local s = item_type.sound_add
  if s == 0 then
    return
  end
  bo2.PlaySound2D(s)
end
function on_gain(info, cnt)
  if not ui_main.w_top.visible then
    return
  end
  if ui_loading.w_top.visible then
    return
  end
  if not sys.check(w_gain_top) then
    return
  end
  local box = info.box
  if not (box >= bo2.eItemBox_BagBeg) or not (box <= bo2.eItemBox_Quest) then
    return
  end
  ui_personal.ui_equip.on_gain_item_event(info.excel.id)
  ui_tempshortcut.on_gain_item_event(info, cnt > 0)
  local excel = info.excel
  if cnt <= 0 then
    play_sound_del(excel)
    return
  end
  ui_handson_teach.test_complate_gain_item(excel.id)
  gain_insert(excel.id)
  play_sound_add(excel)
end
function gain_init()
  if sys.check(w_gain_top) then
    return
  end
  ui.insert_on_item_gain(on_gain, "ui_item.on_gain")
  w_gain_top = ui.create_control(ui_main.w_top)
  w_gain_top:load_style(c_text_item_file, "gain_top")
  g_gain_timer = w_gain_top:find_plugin("timer")
  local v
  for i = 1, c_gain_limit do
    v = ui.create_control(w_gain_top, "transition_view")
    v:load_style(c_text_item_file, "gain_transition")
    v.visible = false
    local c = v:search("card")
    local d = {view = v, card = c}
    t_gain_data[i] = d
  end
end
