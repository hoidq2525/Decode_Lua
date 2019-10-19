g_info = nil
g_transinfo = nil
g_select_item = nil
local item_uri = "$gui/frame/npcfunc/markpos.xml"
local item_style = "item_trans"
local polymorph_item_style = "item_polymorph"
function on_send_bound()
  if g_info == nil then
    return
  end
  local data = sys.variant()
  data:set(packet.key.item_key, g_info.only_id)
  bo2.send_variant(packet.eCTS_UI_MarkPos, data)
  set_visible(false)
end
function on_markpos()
  if g_info == nil then
    return
  end
  if g_info.excel ~= nil and g_info.excel.bound_mode then
    local bound = g_info:get_data_8(bo2.eItemByte_Bound)
    local on_msg_callback = function(msg)
      if msg.result ~= 1 then
        return false
      end
      on_send_bound()
    end
    local txt = ui.get_text("npcfunc|markpos_note_item_bound")
    if bound ~= 0 then
      local mtf_data = {}
      if sys.check(bo2.scn) and sys.check(bo2.player) then
        mtf_data.scn_name = bo2.scn.excel.name
        mtf_data.x, mtf_data.y = bo2.player:get_position()
        mtf_data.x = math.floor(mtf_data.x)
        mtf_data.y = math.floor(mtf_data.y)
        txt = ui_widget.merge_mtf(mtf_data, ui.get_text("item|mark_confirm_mtf"))
      else
        txt = ui.get_text("item|mark_confirm")
      end
    end
    local msg = {callback = on_msg_callback, text = txt}
    ui_widget.ui_msg_box.show_common(msg)
  end
end
function on_transpos()
  if g_info == nil then
    return
  end
  ui_item.send_use(g_info)
  set_visible(false)
end
function show(info)
  g_info = info
  if info == nil then
    return
  end
  local areaID = info:get_data_32(bo2.eItemUInt32_AreaID)
  local x = info:get_data_32(bo2.eItemUInt32_PosX)
  x = x / 1000
  x = math.floor(x)
  local y = info:get_data_32(bo2.eItemUInt32_PosZ)
  y = y / 1000
  y = math.floor(y)
  local lf = info:get_data_32(bo2.eItemUInt32_CurWearout)
  local left = sys.variant()
  left:set("num", lf)
  local l_text = sys.mtf_merge(left, ui.get_text("npcfunc|mark_pos_left"))
  w_left.text = l_text
  if areaID == 0 and x == 0 and y == 0 then
    w_area.text = ui.get_text("npcfunc|mark_pos_null")
    w_main.var:set("only_id", info.only_id)
    w_pos.visible = false
    set_visible(true)
    return
  end
  w_pos.visible = true
  w_title.text = info.excel.name
  local al = bo2.gv_area_list:find(areaID)
  local area_name = " "
  if al ~= nil then
    area_name = al.name
  end
  local area = sys.variant()
  area:set("area", area_name)
  local pos = sys.variant()
  pos:set("pos_x", x)
  pos:set("pos_y", y)
  local area_t = sys.mtf_merge(area, ui.get_text("npcfunc|mark_area_lb"))
  local pos_t = sys.mtf_merge(pos, ui.get_text("npcfunc|mark_pos_lb"))
  w_area.text = area_t
  w_pos.text = pos_t
  w_main.var:set("only_id", onlyID)
  set_visible(true)
end
function set_visible(vis)
  w_main.visible = vis
  if vis == false then
    g_info = nil
  end
end
function on_click_use_transport()
  local send_impl = function(info, excel)
    local v = sys.variant()
    v:set64(packet.key.item_key, info.only_id)
    v:set(packet.key.scnobj_excel_id, excel)
    bo2.send_variant(packet.eCTS_UI_UseItem, v)
  end
  local info = g_transinfo
  if info == nil or g_select_item == nil then
    return
  end
  local excel = g_select_item.var:get(packet.key.scnobj_excel_id).v_int
  send_impl(info, excel)
  set_transport_visible(false)
end
g_polymorph = nil
g_polymorph_select_item = nil
g_init_polymorph = false
function on_click_use_polymorph()
  local send_impl = function(info, excel)
    local v = sys.variant()
    v:set64(packet.key.item_key, info.only_id)
    v:set(packet.key.cha_client_id, excel)
    bo2.send_variant(packet.eCTS_UI_UseItem, v)
  end
  local info = g_polymorph
  if info == nil or g_polymorph_select_item == nil then
    return
  end
  local excel = g_polymorph_select_item.var:get(packet.key.scnobj_excel_id).v_int
  if excel ~= 0 then
    send_impl(info, excel)
    set_polymorph_visible(false)
  end
end
function on_show_polymorph_list()
  if g_init_polymorph == true then
    if sys.check(g_polymorph_select_item) then
      local current_hightlight = g_polymorph_select_item:search("highlight_select")
      current_hightlight.visible = false
    end
    g_polymorph_select_item = nil
    return
  end
  g_init_polymorph = true
  ui_npcfunc.ui_markpos.lt_polymorph:item_clear()
  local nChaList = bo2.gv_cha_list.size
  local pre_cha_list = {
    60938,
    60948,
    60928,
    60932,
    60934,
    60940,
    50612,
    5115,
    60926,
    60944,
    60942,
    60911,
    60921,
    60909,
    60919,
    60905,
    60907,
    60901,
    60903,
    60923,
    60913
  }
  local ignore_cha_list = {}
  for i, v in pairs(pre_cha_list) do
    ignore_cha_list[v] = 1
  end
  local function app_item(id, pExcel)
    local app_item = ui_npcfunc.ui_markpos.lt_polymorph:item_append()
    app_item:load_style(item_uri, polymorph_item_style)
    local rb_desc = app_item:search("rb_item_name")
    app_item.var:set(packet.key.scnobj_excel_id, pExcel.id)
    rb_desc.mtf = sys.format("%d . %s(%d)", id, pExcel.name, pExcel.id)
  end
  local idx = 0
  for i, v in pairs(pre_cha_list) do
    local pExcel = bo2.gv_cha_list:find(v)
    if pExcel ~= nil then
      app_item(i, pExcel)
      idx = i
    end
  end
  for i = 0, nChaList - 1 do
    local pExcel = bo2.gv_cha_list:get(i)
    if pExcel and ignore_cha_list[pExcel.id] == nil then
      app_item(i + idx, pExcel)
    end
  end
end
function set_polymorph_visible(vis)
  ui_npcfunc.ui_markpos.w_main_polymorph.visible = vis
  if vis then
    on_show_polymorph_list()
  else
    local clear_polymorph = function()
      if sys.check(g_polymorph_select_item) then
        local current_hightlight = g_polymorph_select_item:search("highlight_select")
        current_hightlight.visible = false
      end
      g_polymorph = nil
      g_polymorph_select_item = nil
    end
    clear_polymorph()
  end
  ui_npcfunc.ui_markpos.w_main_polymorph.visible = vis
end
function show_polymorph(info)
  g_polymorph = info
  set_polymorph_visible(true)
end
function on_mouse_item_polymorph(w, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local fig_highlight = w:search("highlight_select")
    if sys.check(g_polymorph_select_item) ~= false then
      local current_hightlight = g_polymorph_select_item:search("highlight_select")
      if current_hightlight ~= fig_highlight then
        current_hightlight.visible = false
        fig_highlight.visible = true
        g_polymorph_select_item = w
      else
      end
    else
      fig_highlight.visible = true
      g_polymorph_select_item = w
    end
  elseif msg == ui.mouse_lbutton_dbl then
    g_polymorph_select_item = w
    on_click_use_polymorph()
  end
end
function on_mouse_item_trans(w, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local fig_highlight = w:search("highlight_select")
    if sys.check(g_select_item) ~= false then
      local current_hightlight = g_select_item:search("highlight_select")
      if current_hightlight ~= fig_highlight then
        current_hightlight.visible = false
        fig_highlight.visible = true
        g_select_item = w
      else
      end
    else
      fig_highlight.visible = true
      g_select_item = w
    end
  elseif msg == ui.mouse_lbutton_dbl then
    g_select_item = w
    on_click_use_transport()
  end
end
function on_show_transport_list()
  ui_npcfunc.ui_markpos.lt_trans:item_clear()
  local function app_item(id, pExcel, fill_name)
    local app_item = ui_npcfunc.ui_markpos.lt_trans:item_append()
    app_item:load_style(item_uri, item_style)
    local rb_desc = app_item:search("rb_item_name")
    app_item.var:set(packet.key.scnobj_excel_id, pExcel.id)
    if fill_name ~= nil then
      rb_desc.mtf = fill_name(id, pExcel)
    else
      rb_desc.mtf = sys.format("%d . %s", id, pExcel.name)
    end
  end
  local scn_list
  if sys.check(g_transinfo) and g_transinfo.excel ~= nil then
    local item_excel = g_transinfo.excel
    if item_excel.use_par.size > 0 then
      scn_list = item_excel.use_par
    end
  end
  if scn_list ~= nil then
    local fill_mtf_name = function(id, pExcel)
      return sys.format(L("%d . %s"), id, pExcel.des)
    end
    local scn_count = scn_list.size
    for i = 0, scn_count - 1 do
      local v = scn_list[i]
      local pExcel = bo2.gv_deliver_list:find(v)
      if sys.check(pExcel) then
        app_item(i + 1, pExcel, fill_mtf_name)
      end
    end
    return
  end
  local nSizeScnAlloc = bo2.gv_scn_alloc.size
  local nSizeScnList = bo2.gv_scn_list.size
  local pre_scn_list = {
    101,
    102,
    103,
    1047,
    1046,
    1045,
    141,
    142,
    138,
    112
  }
  local ignore_scn_list = {}
  ignore_scn_list[101] = 1
  ignore_scn_list[102] = 1
  ignore_scn_list[103] = 1
  ignore_scn_list[301] = 1
  ignore_scn_list[302] = 1
  ignore_scn_list[1047] = 1
  ignore_scn_list[1046] = 1
  ignore_scn_list[1045] = 1
  ignore_scn_list[141] = 1
  ignore_scn_list[142] = 1
  ignore_scn_list[138] = 1
  ignore_scn_list[112] = 1
  for i, v in pairs(pre_scn_list) do
    local pExcel = bo2.gv_scn_list:find(v)
    if pExcel ~= nil then
      app_item(i, pExcel)
    end
  end
  for i = 0, nSizeScnAlloc - 1 do
    local pAllocExcel = bo2.gv_scn_alloc:get(i)
    if pAllocExcel ~= nil and ignore_scn_list[pAllocExcel.id] == nil and pAllocExcel.id < 900 then
      local pExcel = bo2.gv_scn_list:find(pAllocExcel.id)
      if pExcel then
        app_item(i + 3, pExcel)
      end
    end
  end
end
function show_transport(info)
  g_transinfo = info
  set_transport_visible(true)
end
function clear_transport()
  g_transinfo = nil
  g_select_item = nil
end
function set_transport_visible(vis)
  if vis then
    on_show_transport_list()
  else
    clear_transport()
  end
  ui_npcfunc.ui_markpos.w_main_transport.visible = vis
end
function on_markpos_enter_scn()
  g_init_polymorph = false
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_markpos_enter_scn, "ui_npcfunc.ui_markpos.on_markpos_enter_scn")
