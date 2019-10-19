local p_barbershop_player
local n_page_limit = 32
local n_page_limit_color = n_page_limit
local barbershop_list = {}
barbershop_list._selfRef = {
  view_hair = nil,
  view_hair_color = nil,
  view_face = nil,
  view_hair_panel = nil
}
local ui_tab = ui_widget.ui_tab
local hair_page_data = {}
local hair_color_page_data = {}
local face_page_data = {}
local bFeature = false
local bInitItem = false
local barbershop_item_list_name = {}
barbershop_item_list_name[0] = L("hair")
barbershop_item_list_name[1] = L("hair_color")
barbershop_item_list_name[2] = L("face")
local cn_default_item_num = 1
local cstr_default_text_color = L("<c+:FFFFFF>")
local cstr_lack_text_color = L("<c+:6C6C6C>")
local cstr_default_text_color_end = L("<c->")
local ciViewPlayerAnim = 545
function insert_item(name, idx)
  local page_uri = "$frame/personal/barbershop_plus.xml"
  local page_sty = name
  local item = g_barbershoplist:item_append()
  item:load_style(page_uri, name)
  local label = item:search("desc_label")
  local full_text_name = "personal|barbershop_" .. name
  label.text = ui.get_text(full_text_name)
  if idx == 1 then
    set_barbershop_view(item, hair_page_data)
  elseif idx == 2 then
    set_barbershop_view_color(item, hair_color_page_data)
  elseif idx == 3 then
    set_barbershop_view(item, face_page_data)
  end
end
function on_init(ctrl)
  p_barbershop_player = nil
  bInitItem = false
end
function on_init_cell_box(view)
  for i = 0, n_page_limit - 1 do
    local cname = sys.format("cell%d", i)
    local cell = ui.create_control(view, "panel")
    cell:load_style(L("$frame/personal/barbershop_plus.xml"), L("cell_item"))
    cell.name = cname
    cell.visible = true
  end
end
function on_init_color_cell_box(view)
  for i = 0, n_page_limit - 1 do
    local cname = sys.format("cell%d", i)
    local cell = ui.create_control(view, "panel")
    cell:load_style(L("$frame/personal/barbershop_plus.xml"), L("color_cell_item"))
    cell.name = cname
  end
end
function set_barbershop_view(item, page_data)
  page_data.view = item:search("view")
  on_init_cell_box(page_data.view)
  if page_data.view == nil then
    ui.log("error init page_data.view")
    return
  end
  page_data.list = {}
  local page = {index = 0, count = 0}
  page_data.page = page
end
function set_barbershop_view_color(item, page_data)
  page_data.view = item:search("view")
  on_init_color_cell_box(page_data.view)
  if page_data.view == nil then
    ui.log("error init page_data.view")
    return
  end
  local list = {}
  page_data.list = list
  local page = {index = 0, count = 0}
  page_data.page = page
end
function on_close()
  local w = ui.find_control("$frame:barbershop")
  w.visible = false
end
function on_close_barbershop_edit()
  ui_barbershop.btn_show_edit_core.visible = true
end
function on_click_show_edit_core(btn)
  local p_edit = ui_barbershop.w_panel_edit
  p_edit.visible = true
  btn.visible = false
end
function on_esc_stk_visible(w, vis)
  local p_barbershop_main = w:search("barbershop_main")
  local p_barbershop_edit = w:search("barbershop_edit")
end
local f_rot_factor = 0.16
local f_rot_angle = 90
function on_doll_rotl_click(btn, press)
  if press then
    w_scn.rotate_angle = -f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
end
function on_doll_rotr_click(btn, press)
  if press then
    w_scn.rotate_angle = f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
end
function on_self_enter(obj, msg)
  bind_player(obj)
end
function on_feature_click(btn)
  if bFeature ~= true then
    bFeature = true
    local scn = w_scn.scn
    scn:modify_camera_view_type(p_barbershop_player, bo2.eCameraInit)
  else
    bFeature = false
    local scn = w_scn.scn
    scn:modify_camera_view_type(p_barbershop_player, bo2.eCameraFace)
  end
end
function bind_player(obj)
  local scn = w_scn.scn
  scn:clear_obj(bo2.eScnObjKind_Player)
  p_barbershop_player = scn:create_obj(bo2.eScnObjKind_Player, obj.excel.id)
  p_barbershop_player.view_target = obj
  p_barbershop_player:ViewPlayerAnimPlay(ciViewPlayerAnim, true, false)
  scn:bind_camera(p_barbershop_player)
  scn:modify_camera_view_type(p_barbershop_player, bo2.eCameraFace)
end
function bind_player_d(obj)
  local scn = w_scn.scn
  scn:clear_obj(bo2.eScnObjKind_Player)
  p_barbershop_player = scn:create_obj(bo2.eScnObjKind_Player, obj.excel.id)
  p_barbershop_player.view_target = obj
  scn:bind_camera_d(p_barbershop_player, 0)
end
function on_init_barbershop_item()
  local _v_barber_shop = bo2.gv_barber_shop
  local _size_barbershop = _v_barber_shop.size
  local player = bo2.player
  if player == nil then
    return
  end
  local _bodily_form = ui.safe_get_atb(bo2.eAtb_ExcelID)
  local _sex = ui.safe_get_atb(bo2.eAtb_Sex)
  for i = 0, _size_barbershop - 1 do
    local p_mb_data = _v_barber_shop:get(i)
    if p_mb_data.type == 1 then
      if _sex == p_mb_data.restrict_type then
        insert_to_page(hair_page_data, p_mb_data)
      end
    elseif p_mb_data.type == 2 then
      if _bodily_form == p_mb_data.restrict_type then
        insert_to_page(face_page_data, p_mb_data)
      end
    elseif p_mb_data.type == 3 then
      insert_to_page_color(hair_color_page_data, p_mb_data)
    end
  end
end
function insert_to_page(page_data, data)
  local i = page_data.page.count
  page_data.page.count = i + 1
  page_data.list[i] = data
  update_page_insert_cell(page_data, i)
end
function set_cell(cell, data)
  if cell == nil or data == nil then
    return
  end
  local card = cell:search("barbershop_icon")
  card.excel_id = data.id
  card.icon_name = data.icon_name
  card.visible = true
  barbershop_list[data.id] = {}
  barbershop_list[data.id].excel_data = data
end
function update_page_insert_cell(page_data, i)
  local view = page_data.view
  local cname = sys.format("cell%d", i)
  local cell = view:search(cname)
  set_cell(cell, page_data.list[i])
end
function insert_to_page_color(page_data, data)
  local i = page_data.page.count
  page_data.page.count = i + 1
  page_data.list[i] = data
  updata_page_insert_color(page_data, i)
end
function set_cell_color(cell, data)
  if cell == nil or data == nil then
    return
  end
  local card = cell:search("barbershop_icon")
  local cell_border = cell:search("cell_border")
  cell_border:search("color_item").color = data._hex_data
  local cell_selcet = cell:search("cell_border_select")
  cell_selcet:search("color_item").color = data._hex_data
  card.excel_id = data.id
  card.visible = true
  barbershop_list[data.id] = {}
  barbershop_list[data.id].excel_data = data
end
function updata_page_insert_color(page_data, i)
  local view = page_data.view
  local cname = sys.format("cell%d", i)
  local cell = view:search(cname)
  local cell_color_card = cell:search("color_card")
  cell_color_card.visible = true
  set_cell_color(cell, page_data.list[i])
end
function on_set_total_money()
  panel_total_money.visible = true
  local total_money_panel = panel_total_money:search("money_label")
  local total_lack_money_panel = panel_total_money:search("money_lack_label")
  local totoal_money = 0
  if barbershop_list._selfRef.view_hair ~= nil then
    totoal_money = totoal_money + barbershop_list._selfRef.view_hair.cast_money
  end
  if barbershop_list._selfRef.view_face ~= nil then
    totoal_money = totoal_money + barbershop_list._selfRef.view_face.cast_money
  end
  if barbershop_list._selfRef.view_hair_color ~= nil then
    totoal_money = totoal_money + barbershop_list._selfRef.view_hair_color.cast_money
  end
  local rb_need_money_text = panel_total_money:search("need_money_text")
  local mtf_tex = sys.format(ui.get_text("personal|barbershop_total_need_money"))
  if totoal_money <= 0 then
    totoal_money = 0
    rb_need_money_text.mtf = cstr_default_text_color .. mtf_tex .. cstr_default_text_color_end
    total_money_panel.visible = true
    total_money_panel.money = totoal_money
    total_lack_money_panel.visible = false
    total_lack_money_panel.money = totoal_money
    return true
  end
  local _has_money = 0
  local player = bo2.player
  if player ~= nil then
    _has_money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    _has_money = _has_money + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
  end
  if totoal_money < _has_money then
    rb_need_money_text.mtf = cstr_default_text_color .. mtf_tex .. cstr_default_text_color_end
    total_money_panel.visible = true
    total_money_panel.money = totoal_money
    total_lack_money_panel.visible = false
    total_lack_money_panel.money = totoal_money
  else
    rb_need_money_text.mtf = cstr_lack_text_color .. mtf_tex .. L("")
    total_money_panel.visible = false
    total_money_panel.money = totoal_money
    total_lack_money_panel.visible = true
    total_lack_money_panel.money = totoal_money
  end
end
function on_mouse_barbershop_card(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    if card.excel_id ~= 0 then
      on_view_card_value(card.excel_id)
    end
  elseif msg == ui.mouse_rbutton_click and card.excel_id ~= 0 then
    on_mouse_barbershop_card_canel_value(card.excel_id)
  end
end
function on_mouse_confirm_card(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    if card.excel_id ~= 0 then
      on_req_use_card(card.excel_id)
    end
  elseif msg == ui.mouse_rbutton_click and card.excel_id ~= 0 then
    on_canel_view_card_value(card.excel_id)
  end
end
function on_mouse_color_cell_item(panel, msg, pos, wheel)
  if panel == nil then
    ui.log("panel nil")
    return false
  end
  if msg == ui.mouse_inner then
    panel:search("cell_border").visible = false
    panel:search("cell_border_select").visible = true
  elseif msg == ui.mouse_outer then
    panel:search("cell_border").visible = true
    panel:search("cell_border_select").visible = false
  end
end
function item_count(item_id)
  local _item_size = ui.item_get_count(item_id, true)
  return _item_size
end
local SendChgEquipModelPacket = function(idx)
  local v = sys.variant()
  v:set(packet.key.ui_barbershop_excel_id, idx)
  bo2.send_variant(packet.eCTS_UI_BarberShopChgEquipModel, v)
end
function on_box_plus_click(btn)
  local function _hide_list_item(show_name)
    for i = 0, 2 do
      local _list_item = ui_barbershop.w_main:search(barbershop_item_list_name[i])
      local _btn = _list_item:search("btn_minus")
      ui_barbershop.on_box_minus_click(_btn)
    end
  end
  _hide_list_item()
  local p = btn.parent
  local p_parent = p.parent.parent.parent
  btn.visible = false
  p:search("btn_minus").visible = true
  p = p.parent.parent
  p:search("view").visible = true
  p.parent.dy = 334
end
function on_box_minus_click(btn)
  local p = btn.parent
  btn.visible = false
  p:search("btn_plus").visible = true
  p = p.parent.parent
  p:search("view").visible = false
  p.parent.dy = 26
end
function on_click_cancel_confirm_item(btn)
  local p_parent = btn.parent.parent
  local p_card = p_parent:search("barbershop_icon")
  if p_card ~= nil and p_card.excel_id ~= 0 then
    on_canel_view_card_value(p_card.excel_id)
  end
end
function on_click_trigge_avater_hair_show(btn)
  if btn.check ~= false then
    btn.text = ui.get_text("personal|barbershop_hairtype_show_hair")
  else
    btn.text = ui.get_text("personal|barbershop_hairtype_show_avater")
  end
  if nil ~= p_barbershop_player then
    p_barbershop_player:set_hair_mode(btn.check)
  else
    local obj = bo2.player
    bind_player(obj)
  end
end
function on_set_confirm_item_card(item_panel, card_panel, text_panel, data)
  item_panel.visible = true
  local card = card_panel:search("barbershop_icon")
  local image = card_panel:search("image_filcker")
  local pItemExcel = ui.item_get_excel(data.cast_item_id)
  if pItemExcel == nil then
    ui.log("BarberShop: Check Excel Item " .. data.cast_item_id)
    return false
  end
  card.excel_id = data.id
  card.icon_name = pItemExcel.icon
  card.visible = true
  local _label = card_panel:search("item_count_label")
  _label.visible = true
  local item_get_count = item_count(pItemExcel.id)
  local need_item = pItemExcel.name
  text_panel.mtf = need_item
  local text = sys.format(ui.get_text("personal|barbershop_item_count"), item_get_count, cn_default_item_num)
  _label.text = text
  if item_get_count >= cn_default_item_num then
    text_panel.mtf = cstr_default_text_color .. need_item .. cstr_default_text_color_end
    image.image = nil
    image.visible = false
  else
    image.image = L("$icon/item/") .. pItemExcel.icon .. ".png"
    image.visible = true
    text_panel.mtf = cstr_lack_text_color .. need_item .. cstr_default_text_color_end
  end
  local money_panel = item_panel:search("money_label")
  local money_lack_panel = item_panel:search("money_lack_label")
  money_panel.money = data.cast_money
  money_lack_panel.money = data.cast_money
  local rb_need_money_text = item_panel:search("need_money_text")
  local _has_money = 0
  local player = bo2.player
  if player ~= nil then
    _has_money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
  end
  mtf_tex = sys.format(ui.get_text("personal|barbershop_need_money"))
  if _has_money > data.cast_money then
    rb_need_money_text.mtf = cstr_default_text_color .. mtf_tex .. cstr_default_text_color_end
    money_panel.visible = true
    money_lack_panel.visible = false
  else
    rb_need_money_text.mtf = cstr_lack_text_color .. mtf_tex .. cstr_default_text_color_end
    money_panel.visible = false
    money_lack_panel.visible = true
  end
  on_set_total_money(_has_money)
end
function on_view_card_value(_excel_id)
  if p_barbershop_player == nil then
    local obj = bo2.player
    bind_player(obj)
  end
  if _excel_id ~= nil and barbershop_list[_excel_id] ~= nil then
    _excel_data = barbershop_list[_excel_id].excel_data
    local _type = _excel_data.type
    local _set_type = 0
    if _type == 1 then
      _set_type = bo2.eEquipData_Hair
      barbershop_list._selfRef.view_hair = _excel_data
      local text_panel = ui_barbershop.panel_hair_card:search(L("confirm_item_text"))
      on_set_confirm_item_card(ui_barbershop.panel_hair_card, ui_barbershop.confirm_hair_card, text_panel, _excel_data)
    elseif _type == 2 then
      _set_type = bo2.eEquipData_Face
      barbershop_list._selfRef.view_face = _excel_data
      local text_panel = ui_barbershop.panel_face_card:search(L("confirm_item_text"))
      on_set_confirm_item_card(ui_barbershop.panel_face_card, ui_barbershop.confirm_face_card, text_panel, _excel_data)
    elseif _type == 3 then
      barbershop_list._selfRef.view_hair_color = _excel_data
      local text_panel = ui_barbershop.panel_hair_color_card:search(L("confirm_item_text"))
      on_set_confirm_item_card(ui_barbershop.panel_hair_color_card, ui_barbershop.confirm_hair_color_card, text_panel, _excel_data)
      p_barbershop_player:set_hair_color(_excel_data._hex_data)
      return true
    end
    p_barbershop_player:set_view_equip(_set_type, _excel_data._data)
    return true
  end
end
function on_clear_confirm_panel_value(card_panel)
  local icon_card = card_panel:search("barbershop_icon")
  icon_card.excel_id = 0
  icon_card.icon_name = L("")
  icon_card.visible = false
  local _label = card_panel:search("item_count_label")
  _label.visible = false
  local image = card_panel:search("image_filcker")
  image.visible = false
  local rich_box_text = card_panel:search("confirm_item_text")
  rich_box_text.text = L("")
  local cast_mtf = card_panel:search("")
  local rb_need_money_text = card_panel:search("need_money_text")
  local mtf_tex = sys.format(ui.get_text("personal|barbershop_need_money"))
  rb_need_money_text.mtf = cstr_default_text_color .. mtf_tex .. cstr_default_text_color_end
  local money_label = card_panel:search("money_label")
  local money_lack_panel = card_panel:search("money_lack_label")
  money_label.money = 0
  money_lack_panel.money = 0
  money_label.visible = true
  money_lack_panel.visible = false
end
function on_canel_view_card_value(_excel_id)
  if _excel_id ~= nil and barbershop_list[_excel_id] ~= nil then
    _excel_data = barbershop_list[_excel_id].excel_data
    local _type = _excel_data.type
    local _set_type = 0
    if _type == 1 then
      p_barbershop_player:set_view_equip(bo2.eEquipData_Hair, 0)
      barbershop_list._selfRef.view_hair = nil
      on_clear_confirm_panel_value(ui_barbershop.panel_hair_card)
    elseif _type == 2 then
      p_barbershop_player:set_view_equip(bo2.eEquipData_Face, 0)
      barbershop_list._selfRef.view_face = nil
      on_clear_confirm_panel_value(ui_barbershop.panel_face_card)
    elseif _type == 3 then
      p_barbershop_player:set_hair_color(0)
      barbershop_list._selfRef.view_hair_color = nil
      on_clear_confirm_panel_value(ui_barbershop.panel_hair_color_card)
    end
    on_set_total_money()
  end
end
function on_mouse_barbershop_card_canel_value(_excel_id)
  if _excel_id ~= nil and barbershop_list[_excel_id] ~= nil then
    _excel_data = barbershop_list[_excel_id].excel_data
    local _type = _excel_data.type
    local _set_type = 0
    if _type == 1 then
      local icon_card = ui_barbershop.panel_hair_card:search("barbershop_icon")
      if icon_card.excel_id ~= _excel_id then
        return false
      end
      p_barbershop_player:set_view_equip(bo2.eEquipData_Hair, 0)
      barbershop_list._selfRef.view_hair = nil
      on_clear_confirm_panel_value(ui_barbershop.panel_hair_card)
    elseif _type == 2 then
      local icon_card = ui_barbershop.panel_face_card:search("barbershop_icon")
      if icon_card.excel_id ~= _excel_id then
        return false
      end
      p_barbershop_player:set_view_equip(bo2.eEquipData_Face, 0)
      barbershop_list._selfRef.view_face = nil
      on_clear_confirm_panel_value(ui_barbershop.panel_face_card)
    elseif _type == 3 then
      local icon_card = ui_barbershop.panel_hair_color_card:search("barbershop_icon")
      if icon_card.excel_id ~= _excel_id then
        return false
      end
      p_barbershop_player:set_hair_color(0)
      barbershop_list._selfRef.view_hair_color = nil
      on_clear_confirm_panel_value(ui_barbershop.panel_hair_color_card)
    end
    on_set_total_money()
  end
end
local function on_check_use_card(_excel_id)
  if _excel_id ~= nil and barbershop_list[_excel_id] ~= nil then
    local _excel_data = barbershop_list[_excel_id].excel_data
    local _type = _excel_data.type
    local _set_type = 0
    local item_get_count = 0
    local _has_money = 0
    if _type == 1 then
      local target_hair = p_barbershop_player:get_target_equip(bo2.eEquipData_Hair)
      if target_hair == _excel_data._data then
        local text = sys.format(ui.get_text("personal|barbershop_same_hair"))
        ui_tool.note_insert(text)
        return false
      end
      item_get_count = item_count(_excel_data.cast_item_id)
      if item_get_count <= 0 then
        local pItemExcel = ui.item_get_excel(_excel_data.cast_item_id)
        local text = sys.format(ui.get_text("personal|barbershop_lackof_item"), pItemExcel.name)
        ui_tool.note_insert(text)
        return false
      end
      local player = bo2.player
      if player ~= nil then
        _has_money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
      else
        return false
      end
      if _has_money < _excel_data.cast_money then
        local text = sys.format(ui.get_text("personal|barbershop_lackof_money"))
        ui_tool.note_insert(text)
        return false
      end
    elseif _type == 2 then
      local target_face = p_barbershop_player:get_target_equip(bo2.eEquipData_Face)
      if target_face == _excel_data._data then
        local text = sys.format(ui.get_text("personal|barbershop_same_face"))
        ui_tool.note_insert(text)
        return false
      end
      item_get_count = item_count(_excel_data.cast_item_id)
      if item_get_count <= 0 then
        local pItemExcel = ui.item_get_excel(_excel_data.cast_item_id)
        local text = sys.format(ui.get_text("personal|barbershop_lackof_item"), pItemExcel.name)
        ui_tool.note_insert(text)
        return false
      end
      local player = bo2.player
      if player ~= nil then
        _has_money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
      else
        return false
      end
      if _has_money < _excel_data.cast_money then
        local text = sys.format(ui.get_text("personal|barbershop_lackof_money"))
        ui_tool.note_insert(text)
        return false
      end
    elseif _type == 3 then
      local target_hair_color = p_barbershop_player:get_target_hair_color()
      if target_hair_color == _excel_data._hex_data then
        local text = sys.format(ui.get_text("personal|barbershop_same_hair_color"))
        ui_tool.note_insert(text)
        return false
      end
      item_get_count = item_count(_excel_data.cast_item_id)
      if item_get_count <= 0 then
        local pItemExcel = ui.item_get_excel(_excel_data.cast_item_id)
        local text = sys.format(ui.get_text("personal|barbershop_lackof_item"), pItemExcel.name)
        ui_tool.note_insert(text)
        return false
      end
      local player = bo2.player
      if player ~= nil then
        _has_money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
      else
        return false
      end
      if _has_money < _excel_data.cast_money then
        local text = sys.format(ui.get_text("personal|barbershop_lackof_money"))
        ui_tool.note_insert(text)
        return false
      end
    else
      return false
    end
  end
  return true
end
function on_req_use_card(_excel_id)
  local _check_result = on_check_use_card(_excel_id)
  if _check_result ~= true then
    return false
  end
  local _excel_data = barbershop_list[_excel_id].excel_data
  local function on_msg_callback(msg)
    if msg.result ~= 1 then
      return false
    end
    SendChgEquipModelPacket(msg._excel_id)
  end
  local mtf_text = sys.format(ui.get_text("personal|barbershop_single_msg_text"))
  local msg = {
    callback = on_msg_callback,
    _excel_id = _excel_data.id,
    text = mtf_text
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_barbershop_confirm(btn)
  local view_hair = barbershop_list._selfRef.view_hair
  local view_hair_color = barbershop_list._selfRef.view_hair_color
  local view_face = barbershop_list._selfRef.view_face
  if view_hair == nil and view_hair_color == nil and view_face == nil then
    return false
  end
  local totoal_money = 0
  if barbershop_list._selfRef.view_hair ~= nil then
    totoal_money = totoal_money + barbershop_list._selfRef.view_hair.cast_money
  end
  if barbershop_list._selfRef.view_face ~= nil then
    totoal_money = totoal_money + barbershop_list._selfRef.view_face.cast_money
  end
  if barbershop_list._selfRef.view_hair_color ~= nil then
    totoal_money = totoal_money + barbershop_list._selfRef.view_hair_color.cast_money
  end
  local player = bo2.player
  if player ~= nil then
    _has_money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
  else
    return false
  end
  if totoal_money > _has_money then
    local text = sys.format(ui.get_text("personal|barbershop_lackof_money"))
    ui_tool.note_insert(text)
    return false
  end
  if view_hair ~= nil then
    local _check_result = on_check_use_card(view_hair.id)
    if _check_result ~= true then
      return false
    end
  end
  if view_hair_color ~= nil then
    local _check_result = on_check_use_card(view_hair_color.id)
    if _check_result ~= true then
      return false
    end
  end
  if view_face ~= nil then
    local _check_result = on_check_use_card(view_face.id)
    if _check_result ~= true then
      return false
    end
  end
  local _mtf_text = sys.format(ui.get_text("personal|barbershop_single_msg_text"))
  local function on_msg_callback(msg)
    if msg.result ~= 1 then
      return
    end
    local view_hair = barbershop_list._selfRef.view_hair
    local view_hair_color = barbershop_list._selfRef.view_hair_color
    local view_face = barbershop_list._selfRef.view_face
    if view_hair ~= nil then
      SendChgEquipModelPacket(view_hair.id)
    end
    if view_hair_color ~= nil then
      SendChgEquipModelPacket(view_hair_color.id)
    end
    if view_face ~= nil then
      SendChgEquipModelPacket(view_face.id)
    end
  end
  local msg = {callback = on_msg_callback, text = _mtf_text}
  ui_widget.ui_msg_box.show_common(msg)
end
function on_barbershop_cancel()
  if p_barbershop_player ~= nil and barbershop_list ~= nil and barbershop_list._selfRef ~= nil then
    if barbershop_list._selfRef.view_hair ~= nil then
      p_barbershop_player:set_view_equip(bo2.eEquipData_Hair, 0)
    end
    if barbershop_list._selfRef.view_hair_color ~= nil then
      p_barbershop_player:set_hair_color(0)
    end
    if barbershop_list._selfRef.view_face ~= nil then
      p_barbershop_player:set_view_equip(bo2.eEquipData_Face, 0)
    end
  end
  barbershop_list._selfRef.view_hair = nil
  barbershop_list._selfRef.view_hair_color = nil
  barbershop_list._selfRef.view_face = nil
  on_clear_confirm_panel_value(ui_barbershop.panel_hair_card)
  on_clear_confirm_panel_value(ui_barbershop.panel_hair_color_card)
  on_clear_confirm_panel_value(ui_barbershop.panel_face_card)
  on_set_total_money()
end
function on_card_show(tip, data, stk)
  local szTitle = sys.format("%s", data.name_text)
  stk:raw_format(ui_tool.cs_tip_title_enter_n, ui_tool.cs_tip_color_white)
  stk:push(szTitle)
  stk:raw_push(ui_tool.cs_tip_title_leave)
  local tip_id = data.text_id
  local szTipText = bo2.gv_text:find(tip_id)
  if szTipText ~= nil then
    ui_tool.ctip_push_sep(stk)
    if data.icon_name.size > 0 then
      stk:raw_format("<img:%s*36,36><c+:FF0000>%s<c->", data.icon_name, szTipText.text)
    else
      stk:raw_format("<c+:FF0000>%s<c->", szTipText.text)
    end
  end
  local item_id = data.cast_item_id
  local excel = ui.item_get_excel(item_id)
  if excel ~= nil then
    ui_tool.ctip_push_sep(stk)
    local count = sys.format(ui.get_text("personal|barbershop_confirm_text"), data.cast_item_cnt)
    ui_tool.ctip_push_text(stk, ui_tool.cs_tip_newline .. count, ui_tool.cs_tip_color_green)
    ui_tool.ctip_make_title(stk, excel, excel.plootlevel.color)
    ui_tool.ctip_make_item_icon(stk, excel, nil)
  end
  ui_tool.ctip_push_sep(stk)
  local tip_id = excel.tip
  local tip_x = bo2.gv_text:find(tip_id)
  if tip_id ~= nil and tip_x ~= nil then
    stk:raw_format("<c+:9F601B>%s<c->", tip_x.text)
    ui_tool.ctip_push_sep(stk)
  end
end
function on_hair_card_show(tip)
  local card = tip.owner:search("barbershop_icon")
  if card.excel_id == 0 then
    return
  end
  local data = barbershop_list[card.excel_id].excel_data
  local stk = sys.mtf_stack()
  local stk_use
  on_card_show(tip, data, stk)
end
function on_confirm_card_show(tip)
  local card = tip.owner:search("barbershop_icon")
  if card.excel_id == 0 then
    return
  end
  local stk = sys.mtf_stack()
  local stk_use
  local data = barbershop_list[card.excel_id].excel_data
  on_card_show(tip, data, stk)
  ui_tool.ctip_push_operation(stk, ui.get_text("personal|barbershop_left_click_use"))
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_operation(stk, ui.get_text("personal|barbershop_right_click_cancel"))
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_handle_result(cmd, data)
  local excel_id = data:get(packet.key.ui_barbershop_excel_id).v_int
  local result_type = data:get(packet.key.ui_barbershop_result).v_int
  ui.log("handle result" .. excel_id .. " " .. result_type .. " " .. bo2.eBarberShopResult_UnknowError .. " ")
  if result_type == bo2.eBarberShopResult_UnknowError or result_type == bo2.eBarberShopResult_WrongBodilyForm or result_type == bo2.eBarberShopResult_WrongSex then
    local text = sys.format(L("personal|barbershop_unknow_error"))
    ui_tool.note_insert(text)
    on_barbershop_cancel()
    return
  end
  if result_type == bo2.eBarberShopResult_SameValue then
    local text = sys.format(ui.get_text("personal|barbershop_same_face"))
    ui_tool.note_insert(text)
    on_canel_view_card_value(excel_id)
    return
  end
  if result_type == bo2.eBarberShopResult_LackOfMoney then
    local text = sys.format(ui.get_text("personal|barbershop_lackof_money"))
    ui_tool.note_insert(text)
    on_canel_view_card_value(excel_id)
    return
  end
  if result_type == bo2.eBarberShopResult_LackOfItem then
    local pItemExcel = ui.item_get_excel(_excel_data.cast_item_id)
    local text = sys.format(ui.get_text("personal|barbershop_lackof_item"), pItemExcel.name)
    ui_tool.note_insert(text)
    on_canel_view_card_value(excel_id)
    return
  end
  local text = sys.format(ui.get_text("personal|barbershop_succeed"))
  ui_tool.note_insert(text)
  on_canel_view_card_value(excel_id)
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_barbershop.on_self_enter")
local sig_name = "ui_barbershop:on_signal"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_BarberShopResult, on_handle_result, sig_name)
