local p_barbershop_player
local n_page_limit = 6
local barbershop_list = {}
barbershop_list._selfRef = {
  view_hair = nil,
  view_hair_color = nil,
  view_face = nil,
  view_portrait = nil
}
local ui_tab = ui_widget.ui_tab
local hair_page_data = {}
local hair_color_page_data = {}
local face_page_data = {}
local portrait_page_data = {}
local bFeature = false
local bInitItem = false
local mutex_visible_panel_name = {}
local cstr_default_text_color = L("<c+:FFFFFF>")
local cstr_lack_text_color = L("<c+:6C6C6C>")
local cstr_default_text_color_end = L("<c->")
local cwstr_confirm_item_text = L("confirm_item_text")
local ciViewPlayerAnim = 545
local ciScnViewIdx = 1000
local cwstr_style_uri = L("$frame/personal/barbershop_plus_haircut.xml")
local cwstr_style_name = L("barbershop_edit_item")
local cwstr_cell_name = L("cell%d")
local cvalue_color_red = L("FFFF0000")
local cvalue_color_green = L("FF00FF00")
local view_edit_scn = {}
view_edit_scn[1] = {
  scn_id = 1001,
  fov = 0.65,
  radius = 0.7
}
view_edit_scn[2] = {
  scn_id = 1002,
  fov = 0.65,
  radius = 0.6
}
local g_toggle_hat = 0
local g_toggle_body = 0
function on_init(ctrl)
  hair_page_data = {}
  hair_color_page_data = {}
  face_page_data = {}
  portrait_page_data = {}
  bInitItem = false
  p_barbershop_player = nil
  mutex_visible_panel_name = {}
  mutex_visible_panel_name[L("portrait")] = {
    init = false,
    idx = 0,
    page = portrait_page_data,
    set_type = -2,
    excel_type = 4
  }
  mutex_visible_panel_name[L("face")] = {
    init = false,
    idx = 3,
    page = face_page_data,
    set_type = bo2.eEquipData_Face,
    excel_type = 3
  }
  mutex_visible_panel_name[L("hair")] = {
    init = false,
    idx = 1,
    page = hair_page_data,
    set_type = bo2.eEquipData_Hair,
    excel_type = 1
  }
  mutex_visible_panel_name[L("hair_color")] = {
    init = false,
    idx = 2,
    page = hair_color_page_data,
    set_type = -1,
    excel_type = 2
  }
  for i, v in pairs(mutex_visible_panel_name) do
    init_barbershop_page_data(i, v, v.page)
  end
end
function init_barbershop_page_data(name, ref_data, page_data)
  local function on_init_cell_box(view)
    for i = 0, n_page_limit - 1 do
      local cname = sys.format(cwstr_cell_name, i)
      local cell = ui.create_control(view, "panel")
      cell:load_style(cwstr_style_uri, cwstr_style_name)
      cell.name = cname
      cell.visible = true
    end
  end
  local parent_panel = w_panel_edit:search(name)
  local viw_panel = parent_panel:search("view")
  local step = parent_panel:search("step")
  page_data.view = viw_panel
  page_data.step = step
  on_init_cell_box(page_data.view)
  page_data.list = {}
  local page = {index = 0, count = 0}
  page_data.page = page
  local _ref_data = ref_data
  local function on_page_step(var)
    page_data.page.index = var.index * n_page_limit
    update_page(page_data, _ref_data)
  end
  ui_widget.ui_stepping.set_event(page_data.step, on_page_step)
end
function on_init_barbershop_mb_item()
  bInitItem = true
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
      insert_to_page(hair_color_page_data, p_mb_data)
    elseif p_mb_data.type == 4 and _sex == p_mb_data.restrict_type then
      insert_to_page(portrait_page_data, p_mb_data)
    end
  end
end
function insert_to_page(page_data, data)
  local i = page_data.page.count
  page_data.page.count = i + 1
  page_data.list[i] = data
  page_insert_cell_item(page_data, i)
end
function page_insert_cell_item(page_data, i)
  local view = page_data.view
  local cname = sys.format(cwstr_cell_name, i)
  local function init_cell(data)
    barbershop_list[data.id] = {}
    barbershop_list[data.id].excel_data = data
  end
  init_cell(page_data.list[i])
end
function set_cell(cell, data, ref_data)
  if cell == nil or data == nil then
    return
  end
  local card = cell:search("barbershop_icon")
  card.visible = true
  card.excel_id = data.id
  local w_scn = card:search("scn_view")
  local ref
  local highlight_select = cell:search("highlight_select")
  local _type = data.type
  if _type == 1 then
    ref = barbershop_list._selfRef.view_hair
  elseif _type == 2 then
    ref = barbershop_list._selfRef.view_face
  elseif _type == 3 then
    ref = barbershop_list._selfRef.view_hair_color
  elseif _type == 4 then
    ref = barbershop_list._selfRef.view_portrait
  end
  if ref ~= nil and ref.id == data.id then
    highlight_select.visible = true
  else
    highlight_select.visible = false
  end
  if ref_data.idx == 0 then
    w_scn.visible = false
    local cur_portrait = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Portrait)
    local highlight_current = cell:search("highlight_current")
    if cur_portrait == data._data then
      highlight_current.visible = true
    else
      highlight_current.visible = false
    end
    card.icon_name = data.icon_name
    return true
  end
  local obj = bo2.player
  w_scn.visible = true
  local scn = w_scn.scn
  local _set_type = ref_data.set_type
  local _current_data = 0
  if barbershop_list[data.id].view_player ~= nil then
    view_player = barbershop_list[data.id].view_player
    view_player.view_target = obj
  else
    scn:clear_obj(bo2.eScnObjKind_Player)
    view_player = scn:create_obj(bo2.eScnObjKind_Player, obj.excel.id)
    view_player.view_target = obj
    view_player:ViewPlayerAnimPlay(ciViewPlayerAnim, true, false)
  end
  if _type == 1 then
    _current_data = view_player:get_target_equip(_set_type)
    view_player:set_view_equip(_set_type, data._data)
  elseif _type == 2 then
    _current_data = view_player:get_target_equip(_set_type)
    view_player:set_view_equip(_set_type, data._data)
  elseif _type == 3 then
    if barbershop_list._selfRef.view_hair ~= nil then
      view_player:set_view_equip(bo2.eEquipData_Hair, barbershop_list._selfRef.view_hair._data)
    end
    _current_data = view_player:get_target_hair_color()
    view_player:set_hair_color(data._hex_data)
  end
  local highlight_current = cell:search("highlight_current")
  if _current_data == data._data then
    highlight_current.visible = true
  elseif _current_data == data._hex_data then
    highlight_current.visible = true
  else
    highlight_current.visible = false
  end
  scn:modify_camera_view_type(view_player, bo2.eCameraFoot)
  local p_gender = ui.safe_get_atb(bo2.eAtb_Sex)
  local ref_cell = view_edit_scn[p_gender]
  scn:set_radius(ref_cell.radius)
  scn:set_fov(ref_cell.fov)
end
function update_page(page_data, ref_data)
  local page = page_data.page
  local p_idx = math.floor(page.index / n_page_limit)
  local p_cnt = math.floor((page.count + n_page_limit - 1) / n_page_limit)
  ui_widget.ui_stepping.set_page(page_data.step, p_idx, p_cnt)
  local p_cur_begin = p_idx * n_page_limit
  local p_cur_end = (p_idx + 1) * n_page_limit
  local count = page.count - 1
  for i = 0, n_page_limit - 1 do
    local cname = sys.format(cwstr_cell_name, i)
    local cell = page_data.view:search(cname)
    local idx = page.index + i
    if idx < page.count then
      set_cell(cell, page_data.list[idx], ref_data)
      cell.visible = true
    else
      cell.visible = true
      local set_cell_visible_border = function(cell)
        local card = cell:search("barbershop_icon")
        card.visible = false
        local highlight_current = cell:search("highlight_current")
        highlight_current.visible = false
        local highlight_select = cell:search("highlight_select")
        highlight_select.visible = false
      end
      set_cell_visible_border(cell)
    end
  end
end
function on_click_close(btn)
  local w = ui.find_control("$frame:barbershop_haircut")
  w.visible = false
end
function on_click_show_edit_core(btn)
  local p_edit = ui_barbershop.ui_haircut.w_panel_edit
  p_edit.visible = true
  btn.visible = false
end
function on_esc_stk_visible(w, vis)
  local function destroy_tiny_scn_view(btn_parent, ref)
    local idx = 0
    local fov = 0
    if ref ~= 0 then
      idx = ref.scn_id
      fov = ref.fov
    end
    for i = 0, n_page_limit - 1 do
      local cname = sys.format(cwstr_cell_name, i)
      local cell = btn_parent:search(cname)
      local cell_scn_view = cell:search("scn_view")
      cell_scn_view:set_excel_id(idx)
      if fov ~= 0 then
        cell_scn_view.scn:set_fov(fov)
      end
    end
  end
  local function set_tiny_scn_view(ref)
    for i, v in pairs(mutex_visible_panel_name) do
      if v.idx ~= 0 and v.page ~= nil and v.page.view ~= nil then
        destroy_tiny_scn_view(v.page.view, ref)
      end
    end
  end
  local function set_scn_view(vis)
    if vis then
      ui_barbershop.ui_haircut.w_scn.visible = true
      ui_barbershop.ui_haircut.w_scn:set_excel_id(ciScnViewIdx)
      local player = bo2.player
      bind_player(player)
      on_self_hat(player)
      on_self_body(player)
    else
      ui_barbershop.ui_haircut.w_scn.visible = true
      ui_barbershop.ui_haircut.w_scn:set_excel_id(0)
      p_barbershop_player = nil
    end
  end
  if vis then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    local w_core = w:search("core")
    w_core.visible = true
    local ciPlayerSex = ui.safe_get_atb(bo2.eAtb_Sex)
    local ref_view_edit_scn = view_edit_scn[ciPlayerSex]
    set_tiny_scn_view(ref_view_edit_scn)
    if bInitItem ~= true then
      on_init_barbershop_mb_item()
    end
    set_scn_view(vis)
    on_barbershop_cancel()
    local obj = bo2.player
    if obj ~= nil then
      g_toggle_hat = obj:get_flag_int8(bo2.ePlayerFlagInt8_Hat)
      g_toggle_body = obj:get_flag_int8(bo2.ePlayerFlagInt8_Body)
    end
    local btn_choose
    for idx, val in pairs(mutex_visible_panel_name) do
      local panel_choose = w_barbershop_control:search(idx)
      if panel_choose ~= nil then
        btn_choose = panel_choose:search("btn_choose")
        if btn_choose.enable == false then
          break
        end
      end
    end
    if btn_choose.enable == true then
      btn_choose = w_barbershop_control:search("hair"):search("btn_choose")
    end
    on_click_show_edit_panel(btn_choose)
  else
    set_scn_view(vis)
    if ui_barbershop.ui_haircut.w_panel_edit ~= nil then
      ui_barbershop.ui_haircut.w_panel_edit.visible = false
      set_tiny_scn_view(0)
    end
    local obj = bo2.player
    if obj ~= nil then
      if g_toggle_body ~= 0 and g_toggle_hat ~= obj:get_flag_int8(bo2.ePlayerFlagInt8_Hat) then
        bo2.send_flag_int8(bo2.ePlayerFlagInt8_Hat, g_toggle_hat)
      end
      if g_toggle_body ~= 0 and g_toggle_body ~= obj:get_flag_int8(bo2.ePlayerFlagInt8_Body) then
        bo2.send_flag_int8(bo2.ePlayerFlagInt8_Body, g_toggle_body)
      end
    end
    g_toggle_hat = 0
    g_toggle_body = 0
    ui_widget.esc_stk_pop(w)
  end
end
function on_visible_edit_core(w, vis)
  local btn_choose = w_barbershop_control:search(w.name):search("btn_choose")
  btn_choose.enable = not vis
  if vis == true then
    local w_name = w.name
    local ref_mutex_data = mutex_visible_panel_name[w_name]
    update_page(ref_mutex_data.page, ref_mutex_data)
  end
end
local f_rot_factor = 1.5707963
local f_rot_angle = 90
function on_edit_doll_rotl_click(btn)
  local btn_parent = btn.parent.parent.parent
  local name = btn_parent.name
  local page_data = mutex_visible_panel_name[name].page
  if page_data == nil then
    return false
  end
  for i = 0, n_page_limit - 1 do
    local cname = sys.format(cwstr_cell_name, i)
    local cell = btn_parent:search(cname)
    local cell_scn_view = cell:search("scn_view")
    if cell_scn_view.visible ~= false then
      local scn = cell_scn_view.scn
      scn:change_angle_x(-f_rot_factor)
    end
  end
end
function on_edit_doll_rotr_click(btn)
  local btn_parent = btn.parent.parent.parent
  local name = btn_parent.name
  local page_data = mutex_visible_panel_name[name].page
  if page_data == nil then
    return false
  end
  for i = 0, n_page_limit - 1 do
    local cname = sys.format(cwstr_cell_name, i)
    local cell = btn_parent:search(cname)
    local cell_scn_view = cell:search("scn_view")
    if cell_scn_view.visible ~= false then
      local scn = cell_scn_view.scn
      scn:change_angle_x(f_rot_factor)
    end
  end
end
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
function on_click_display_feature(btn)
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
function on_set_total_money()
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
  if barbershop_list._selfRef.view_portrait ~= nil then
    totoal_money = totoal_money + barbershop_list._selfRef.view_portrait.cast_money
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
      on_view_card_value(card.excel_id, card)
    end
  elseif msg == ui.mouse_rbutton_click then
    if card.excel_id ~= 0 then
      on_mouse_barbershop_card_canel_value(card.excel_id, card)
    end
  elseif msg == ui.mouse_lbutton_dbl and card.excel_id ~= 0 then
    on_req_use_card(card.excel_id)
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
function on_mouse_rb_confirm_panel(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local card = panel.parent:search("barbershop_icon")
    if card ~= nil and card.excel_id ~= 0 then
      on_req_use_card(card.excel_id)
    end
  elseif msg == ui.mouse_rbutton_click then
    local card = panel.parent:search("barbershop_icon")
    if card ~= nil and card.excel_id ~= 0 then
      on_canel_view_card_value(card.excel_id)
    end
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
function on_click_show_edit_panel(btn)
  local panel_name = btn.parent.parent.name
  local function disable_all_mutex_panel()
    for i, v in pairs(mutex_visible_panel_name) do
      w_panel_edit:search(i).visible = false
    end
  end
  local edit_panel_item = w_panel_edit:search(panel_name)
  if w_panel_edit.visible ~= true then
    w_panel_edit.visible = true
    disable_all_mutex_panel()
    edit_panel_item.visible = true
  else
    disable_all_mutex_panel()
    edit_panel_item.visible = true
  end
end
function on_click_cancel_confirm_item(btn)
  local p_parent = btn.parent.parent
  local p_card = p_parent:search("barbershop_icon")
  if p_card ~= nil and p_card.excel_id ~= 0 then
    on_canel_view_card_value(p_card.svar.barber_id)
  end
  local p_top = btn.parent.parent.parent.parent
  if p_top == panel_hair_card then
    w_quickbuy_hairstyle.visible = false
  elseif p_top == panel_hair_color_card then
    w_quickbuy_haircolor.visible = false
  end
end
function on_self_hat(obj, ft, idx)
  local v = obj:get_flag_int8(bo2.ePlayerFlagInt8_Hat)
  w_btn_toggle_hat_equip.visible = v == 1
  w_btn_toggle_hat_avatar.visible = v == 2
end
function on_toggle_hat_equip_click(btn)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Hat, 2)
end
function on_toggle_hat_avatar_click(btn)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Hat, 1)
end
function on_self_body(obj, ft, idx)
  local v = obj:get_flag_int8(bo2.ePlayerFlagInt8_Body)
  if v == 1 then
    w_btn_toggle_body_avatar.visible = true
    w_btn_toggle_body_equip.visible = false
  else
    w_btn_toggle_body_avatar.visible = false
    w_btn_toggle_body_equip.visible = true
  end
end
function on_toggle_body_avatar_click(btn)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Body, 0)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Legs, 0)
end
function on_toggle_body_equip_click(btn)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Body, 1)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Legs, 1)
end
function update_quick_buy(btn, item_id)
  btn.visible = false
  local goods_id = ui_supermarket2.shelf_quick_buy_id(item_id)
  if goods_id == 0 then
    return
  end
  btn.name = goods_id
  btn.visible = true
end
function on_quick_buy_click(btn)
  ui_supermarket2.shelf_singleBuy(btn)
end
function on_set_confirm_item_card(item_panel, card_panel, text_panel, data)
  local btn_quick_buy
  if item_panel == panel_hair_card then
    btn_quick_buy = w_quickbuy_hairstyle
  elseif item_panel == panel_hair_color_card then
    btn_quick_buy = w_quickbuy_haircolor
  end
  update_quick_buy(btn_quick_buy, data.cast_item_id)
  item_panel.visible = true
  local card = card_panel:search("barbershop_icon")
  local image = card_panel:search("image_filcker")
  local pItemExcel = ui.item_get_excel(data.cast_item_id)
  if pItemExcel == nil then
    ui.log("BarberShop: Check Excel Item " .. data.cast_item_id)
    return false
  end
  local req_item_cnt = data.cast_item_cnt
  local cancel_btn = item_panel:search(L("confirm_cancel_btn"))
  cancel_btn.visible = true
  local cancel_figure = item_panel:search(L("confirm_cancel_figure"))
  cancel_figure.visible = false
  card.excel_id = data.cast_item_id
  card.require_count = req_item_cnt
  card.svar.barber_id = data.id
  card.visible = true
  local item_get_count = item_count(pItemExcel.id)
  local need_item = pItemExcel.name
  text_panel.mtf = need_item
  local text = sys.format(ui.get_text("personal|barbershop_item_count"), item_get_count, req_item_cnt)
  local money_panel = item_panel:search("money_label")
  local money_lack_panel = item_panel:search("money_lack_label")
  money_panel.money = data.cast_money
  money_lack_panel.money = data.cast_money
  local rb_need_money_text = item_panel:search("need_money_text")
  local _has_money = 0
  local player = bo2.player
  if player ~= nil then
    _has_money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    _has_money = _has_money + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
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
function refresh_panel_select_hightlight(card, vis)
  local cell = card.parent.parent
  local view = cell.parent
  for i = 0, n_page_limit - 1 do
    local cell_name = sys.format(cwstr_cell_name, i)
    local cell = view:search(cell_name)
    if cell ~= nil then
      cell:search("highlight_select").visible = false
    end
  end
  if vis == true then
    local highlight_select = cell:search("highlight_select")
    highlight_select.visible = vis
  end
end
function refresh_current_highlight(idx)
  if barbershop_list[idx] == nil then
    return
  end
  local excel_data = barbershop_list[idx].excel_data
  local _current_data = 0
  local excel_type = excel_data.type
  local name
  if excel_type == 1 then
    name = L("hair")
    _current_data = excel_data._data
  elseif excel_type == 2 then
    name = L("face")
    _current_data = excel_data._data
  elseif excel_type == 3 then
    name = L("hair_color")
    _current_data = excel_data._hex_data
  elseif excel_type == 4 then
    name = L("portrait")
    _current_data = excel_data._data
  end
  local w_edit_panel = ui_barbershop.ui_haircut.w_panel_edit:search(name)
  local view = w_edit_panel:search("view")
  for i = 0, n_page_limit - 1 do
    local cell_name = sys.format(cwstr_cell_name, i)
    local cell = view:search(cell_name)
    local card = cell:search("barbershop_icon")
    local card_excel = card.excel_id
    if barbershop_list[card_excel] ~= nil then
      local data = barbershop_list[card_excel].excel_data
      if cell ~= nil then
        local highlight_current = cell:search("highlight_current")
        if _current_data == data._data then
          highlight_current.visible = true
        elseif _current_data == data._hex_data then
          highlight_current.visible = true
        else
          highlight_current.visible = false
        end
      end
    end
  end
end
function on_click_update_hair_color_view()
  local ref_mutex_data = mutex_visible_panel_name[L("hair_color")]
  update_page(ref_mutex_data.page, ref_mutex_data)
end
function on_view_card_value(_excel_id, card)
  if p_barbershop_player == nil then
    local obj = bo2.player
    bind_player(obj)
  end
  if _excel_id ~= nil and barbershop_list[_excel_id] ~= nil then
    _excel_data = barbershop_list[_excel_id].excel_data
    local _type = _excel_data.type
    local _set_type = 0
    refresh_panel_select_hightlight(card, true)
    if _type == 1 then
      _set_type = bo2.eEquipData_Hair
      barbershop_list._selfRef.view_hair = _excel_data
      local text_panel = ui_barbershop.ui_haircut.panel_hair_card:search(cwstr_confirm_item_text)
      on_set_confirm_item_card(ui_barbershop.ui_haircut.panel_hair_card, ui_barbershop.ui_haircut.confirm_hair_card, text_panel, _excel_data)
      p_barbershop_player:set_view_equip(_set_type, _excel_data._data)
      on_click_update_hair_color_view()
    elseif _type == 2 then
      _set_type = bo2.eEquipData_Face
      barbershop_list._selfRef.view_face = _excel_data
      local text_panel = ui_barbershop.ui_haircut.panel_face_card:search(cwstr_confirm_item_text)
      on_set_confirm_item_card(ui_barbershop.ui_haircut.panel_face_card, ui_barbershop.ui_haircut.confirm_face_card, text_panel, _excel_data)
      p_barbershop_player:set_view_equip(_set_type, _excel_data._data)
    elseif _type == 3 then
      barbershop_list._selfRef.view_hair_color = _excel_data
      local text_panel = ui_barbershop.ui_haircut.panel_hair_color_card:search(cwstr_confirm_item_text)
      on_set_confirm_item_card(ui_barbershop.ui_haircut.panel_hair_color_card, ui_barbershop.ui_haircut.confirm_hair_color_card, text_panel, _excel_data)
      p_barbershop_player:set_hair_color(_excel_data._hex_data)
    elseif _type == 4 then
      barbershop_list._selfRef.view_portrait = _excel_data
      local text_panel = ui_barbershop.ui_haircut.panel_portrait_card:search(cwstr_confirm_item_text)
      on_set_confirm_item_card(ui_barbershop.ui_haircut.panel_portrait_card, ui_barbershop.ui_haircut.confirm_portrait_card, text_panel, _excel_data)
    end
  end
end
function on_clear_confirm_panel_value(card_panel)
  if card_panel == nil then
    return
  end
  local icon_card = card_panel:search("barbershop_icon")
  icon_card.excel_id = 0
  icon_card.visible = false
  local rich_box_text = card_panel:search("confirm_item_text")
  rich_box_text.text = L("")
  local cancel_btn = card_panel:search(L("confirm_cancel_btn"))
  cancel_btn.visible = false
  local cancel_figure = card_panel:search(L("confirm_cancel_figure"))
  cancel_figure.visible = true
  local rb_need_money_text = card_panel:search("need_money_text")
  local mtf_tex = sys.format(ui.get_text("personal|barbershop_need_money"))
  rb_need_money_text.mtf = cstr_default_text_color .. mtf_tex .. cstr_default_text_color_end
  local money_label = card_panel:search("money_label")
  local money_lack_panel = card_panel:search("money_lack_label")
  money_label.money = 0
  money_lack_panel.money = 0
  money_label.visible = true
  money_lack_panel.visible = false
  local panel_name = card_panel.name
  local w_edit_panel = ui_barbershop.ui_haircut.w_panel_edit:search(panel_name)
  local view = w_edit_panel:search("view")
  for i = 0, n_page_limit - 1 do
    local cell_name = sys.format(cwstr_cell_name, i)
    local cell = view:search(cell_name)
    if cell ~= nil then
      cell:search("highlight_select").visible = false
    end
  end
end
function on_canel_view_card_value(_excel_id)
  if _excel_id ~= nil and barbershop_list[_excel_id] ~= nil then
    _excel_data = barbershop_list[_excel_id].excel_data
    local _type = _excel_data.type
    local _set_type = 0
    if _type == 1 then
      p_barbershop_player:set_view_equip(bo2.eEquipData_Hair, 0)
      barbershop_list._selfRef.view_hair = nil
      on_clear_confirm_panel_value(ui_barbershop.ui_haircut.panel_hair_card)
      on_click_update_hair_color_view()
    elseif _type == 2 then
      p_barbershop_player:set_view_equip(bo2.eEquipData_Face, 0)
      barbershop_list._selfRef.view_face = nil
      on_clear_confirm_panel_value(ui_barbershop.ui_haircut.panel_face_card)
    elseif _type == 3 then
      p_barbershop_player:set_hair_color(0)
      barbershop_list._selfRef.view_hair_color = nil
      on_clear_confirm_panel_value(ui_barbershop.ui_haircut.panel_hair_color_card)
    elseif _type == 4 then
      barbershop_list._selfRef.view_portrait = nil
      on_clear_confirm_panel_value(ui_barbershop.ui_haircut.panel_portrait_card)
    end
    on_set_total_money()
  end
end
function on_mouse_barbershop_card_canel_value(_excel_id, card)
  if _excel_id ~= nil and barbershop_list[_excel_id] ~= nil then
    _excel_data = barbershop_list[_excel_id].excel_data
    local _type = _excel_data.type
    local _set_type = 0
    if _type == 1 then
      local icon_card = ui_barbershop.ui_haircut.panel_hair_card:search("barbershop_icon")
      if icon_card.excel_id ~= _excel_id then
        return false
      end
      refresh_panel_select_hightlight(card, false)
      p_barbershop_player:set_view_equip(bo2.eEquipData_Hair, 0)
      barbershop_list._selfRef.view_hair = nil
      on_clear_confirm_panel_value(ui_barbershop.ui_haircut.panel_hair_card)
      on_click_update_hair_color_view()
    elseif _type == 2 then
      local icon_card = ui_barbershop.ui_haircut.panel_face_card:search("barbershop_icon")
      if icon_card.excel_id ~= _excel_id then
        return false
      end
      refresh_panel_select_hightlight(card, false)
      p_barbershop_player:set_view_equip(bo2.eEquipData_Face, 0)
      barbershop_list._selfRef.view_face = nil
      on_clear_confirm_panel_value(ui_barbershop.ui_haircut.panel_face_card)
    elseif _type == 3 then
      local icon_card = ui_barbershop.ui_haircut.panel_hair_color_card:search("barbershop_icon")
      if icon_card.excel_id ~= _excel_id then
        return false
      end
      refresh_panel_select_hightlight(card, false)
      p_barbershop_player:set_hair_color(0)
      barbershop_list._selfRef.view_hair_color = nil
      on_clear_confirm_panel_value(ui_barbershop.ui_haircut.panel_hair_color_card)
    elseif _type == 4 then
      local icon_card = ui_barbershop.ui_haircut.panel_portrait_card:search("barbershop_icon")
      if icon_card.excel_id ~= _excel_id then
        return false
      end
      refresh_panel_select_hightlight(card, false)
      barbershop_list._selfRef.view_portrait = nil
      on_clear_confirm_panel_value(ui_barbershop.ui_haircut.panel_portrait_card)
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
    local req_item_cnt = _excel_data.cast_item_cnt
    if _type == 1 then
      local target_hair = p_barbershop_player:get_target_equip(bo2.eEquipData_Hair)
      if target_hair == _excel_data._data then
        local text = sys.format(ui.get_text("personal|barbershop_same_hair"))
        ui_tool.note_insert(text, cvalue_color_red)
        return false
      end
      item_get_count = item_count(_excel_data.cast_item_id)
      if req_item_cnt > item_get_count then
        local pItemExcel = ui.item_get_excel(_excel_data.cast_item_id)
        local text = sys.format(ui.get_text("personal|barbershop_lackof_item"), pItemExcel.name)
        ui_tool.note_insert(text, cvalue_color_red)
        return false
      end
      local player = bo2.player
      if player ~= nil then
        _has_money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
        _has_money = _has_money + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
      else
        return false
      end
      if _has_money < _excel_data.cast_money then
        local text = sys.format(ui.get_text("personal|barbershop_lackof_money"))
        ui_tool.note_insert(text, cvalue_color_red)
        return false
      end
    elseif _type == 2 then
      local target_face = p_barbershop_player:get_target_equip(bo2.eEquipData_Face)
      if target_face == _excel_data._data then
        local text = sys.format(ui.get_text("personal|barbershop_same_face"))
        ui_tool.note_insert(text, cvalue_color_red)
        return false
      end
      item_get_count = item_count(_excel_data.cast_item_id)
      if req_item_cnt > item_get_count then
        local pItemExcel = ui.item_get_excel(_excel_data.cast_item_id)
        local text = sys.format(ui.get_text("personal|barbershop_lackof_item"), pItemExcel.name)
        ui_tool.note_insert(text, cvalue_color_red)
        return false
      end
      local player = bo2.player
      if player ~= nil then
        _has_money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
        _has_money = _has_money + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
      else
        return false
      end
      if _has_money < _excel_data.cast_money then
        local text = sys.format(ui.get_text("personal|barbershop_lackof_money"))
        ui_tool.note_insert(text, cvalue_color_red)
        return false
      end
    elseif _type == 3 then
      local target_hair_color = p_barbershop_player:get_target_hair_color()
      if target_hair_color == _excel_data._hex_data then
        local text = sys.format(ui.get_text("personal|barbershop_same_hair_color"))
        ui_tool.note_insert(text, cvalue_color_red)
        return false
      end
      item_get_count = item_count(_excel_data.cast_item_id)
      if req_item_cnt > item_get_count then
        local pItemExcel = ui.item_get_excel(_excel_data.cast_item_id)
        local text = sys.format(ui.get_text("personal|barbershop_lackof_item"), pItemExcel.name)
        ui_tool.note_insert(text, cvalue_color_red)
        return false
      end
      local player = bo2.player
      if player ~= nil then
        _has_money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
        _has_money = _has_money + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
      else
        return false
      end
      if _has_money < _excel_data.cast_money then
        local text = sys.format(ui.get_text("personal|barbershop_lackof_money"))
        ui_tool.note_insert(text, cvalue_color_red)
        return false
      end
    elseif _type == 4 then
      local player = bo2.player
      local cur_portrait = player:get_flag_int32(bo2.ePlayerFlagInt32_Portrait)
      if cur_portrait == _excel_data._data then
        local text = sys.format(ui.get_text("personal|barbershop_same_portrait"))
        ui_tool.note_insert(text, cvalue_color_red)
        return false
      end
      item_get_count = item_count(_excel_data.cast_item_id)
      if req_item_cnt > item_get_count then
        local pItemExcel = ui.item_get_excel(_excel_data.cast_item_id)
        local text = sys.format(ui.get_text("personal|barbershop_lackof_item"), pItemExcel.name)
        ui_tool.note_insert(text, cvalue_color_red)
        return false
      end
      if player ~= nil then
        _has_money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
        _has_money = _has_money + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
      else
        return false
      end
      if _has_money < _excel_data.cast_money then
        local text = sys.format(ui.get_text("personal|barbershop_lackof_money"))
        ui_tool.note_insert(text, cvalue_color_red)
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
  if ui_barbershop.ui_haircut.w_main.visible ~= true then
    return false
  end
  SendChgEquipModelPacket(msg._excel_id)
end
function on_barbershop_confirm(btn)
  local view_hair = barbershop_list._selfRef.view_hair
  local view_hair_color = barbershop_list._selfRef.view_hair_color
  local view_face = barbershop_list._selfRef.view_face
  local view_portrait = barbershop_list._selfRef.view_portrait
  if view_hair == nil and view_hair_color == nil and view_face == nil and view_portrait == nil then
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
  if barbershop_list._selfRef.view_portrait ~= nil then
    totoal_money = totoal_money + barbershop_list._selfRef.view_portrait.cast_money
  end
  local player = bo2.player
  if player ~= nil then
    _has_money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    _has_money = _has_money + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
  else
    return false
  end
  if totoal_money > _has_money then
    local text = sys.format(ui.get_text("personal|barbershop_lackof_money"))
    ui_tool.note_insert(text, cvalue_color_red)
    return false
  end
  local ref_cast = {money = totoal_money}
  if view_hair ~= nil then
    local _check_result = on_check_use_card(view_hair.id)
    if _check_result ~= true then
      return false
    end
    local _excel_data = barbershop_list[view_hair.id].excel_data
    ref_cast.item3 = _excel_data.cast_item_id
    ref_cast.item_cnt3 = _excel_data.cast_item_cnt
  end
  if view_hair_color ~= nil then
    local _check_result = on_check_use_card(view_hair_color.id)
    if _check_result ~= true then
      return false
    end
    local _excel_data = barbershop_list[view_hair_color.id].excel_data
    ref_cast.item4 = _excel_data.cast_item_id
    ref_cast.item_cnt4 = _excel_data.cast_item_cnt
  end
  if view_face ~= nil then
    local _check_result = on_check_use_card(view_face.id)
    if _check_result ~= true then
      return false
    end
    local _excel_data = barbershop_list[view_face.id].excel_data
    ref_cast.item2 = _excel_data.cast_item_id
    ref_cast.item_cnt2 = _excel_data.cast_item_cnt
  end
  if view_portrait ~= nil then
    local _check_result = on_check_use_card(view_portrait.id)
    if _check_result ~= true then
      return false
    end
    local _excel_data = barbershop_list[view_portrait.id].excel_data
    ref_cast.item1 = _excel_data.cast_item_id
    ref_cast.item_cnt1 = _excel_data.cast_item_cnt
  end
  if ui_barbershop.ui_haircut.w_main.visible ~= true then
    return false
  end
  local view_hair = barbershop_list._selfRef.view_hair
  local view_hair_color = barbershop_list._selfRef.view_hair_color
  local view_face = barbershop_list._selfRef.view_face
  local view_portrait = barbershop_list._selfRef.view_portrait
  if view_hair ~= nil then
    SendChgEquipModelPacket(view_hair.id)
  end
  if view_hair_color ~= nil then
    SendChgEquipModelPacket(view_hair_color.id)
  end
  if view_face ~= nil then
    SendChgEquipModelPacket(view_face.id)
  end
  if view_portrait ~= nil then
    SendChgEquipModelPacket(view_portrait.id)
  end
end
function on_barbershop_cancel()
  w_quickbuy_hairstyle.visible = false
  w_quickbuy_haircolor.visible = false
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
  barbershop_list._selfRef.view_portrait = nil
  on_clear_confirm_panel_value(ui_barbershop.ui_haircut.panel_hair_card)
  on_clear_confirm_panel_value(ui_barbershop.ui_haircut.panel_hair_color_card)
  on_clear_confirm_panel_value(ui_barbershop.ui_haircut.panel_face_card)
  on_clear_confirm_panel_value(ui_barbershop.ui_haircut.panel_portrait_card)
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
    stk:raw_format("<c+:FF0000>%s<c->", szTipText.text)
  end
  local item_id = data.cast_item_id
  local excel = ui.item_get_excel(item_id)
  if excel ~= nil then
    ui_tool.ctip_push_sep(stk)
    local count = sys.format(ui.get_text("personal|barbershop_confirm_text"), req_item_cnt)
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
  local szTitle = sys.format("%s", data.name_text)
  stk:raw_format(ui_tool.cs_tip_title_enter_n, ui_tool.cs_tip_color_white)
  stk:push(szTitle)
  stk:raw_push(ui_tool.cs_tip_title_leave)
  local tip_id = data.text_id
  local szTipText = bo2.gv_text:find(tip_id)
  if szTipText ~= nil then
    ui_tool.ctip_push_sep(stk)
    local txt_show = ui_widget.merge_mtf({
      num = data.cast_item_cnt
    }, szTipText.text)
    stk:raw_format("<c+:00FF00>%s<c->", txt_show)
  end
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("personal|barbershop_lclick"), ui_tool.cs_tip_color_operation)
  ui_tool.ctip_push_text(stk, ui.get_text("personal|barbershop_rclick"), ui_tool.cs_tip_color_operation)
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_confirm_card_show(tip)
  local card = tip.owner:search("barbershop_icon")
  if card.excel_id == 0 then
    return
  end
  local stk = sys.mtf_stack()
  local data = barbershop_list[card.svar.barber_id].excel_data
  local item_excel = ui.item_get_excel(data.cast_item_id)
  ui_tool.ctip_make_item(stk, item_excel)
  ui_tool.ctip_show(tip.owner, stk)
end
function on_handle_result(cmd, data)
  local excel_id = data:get(packet.key.ui_barbershop_excel_id).v_int
  local result_type = data:get(packet.key.ui_barbershop_result).v_int
  if result_type == bo2.eBarberShopResult_UnknowError or result_type == bo2.eBarberShopResult_WrongBodilyForm or result_type == bo2.eBarberShopResult_WrongSex then
    local text = sys.format(L("personal|barbershop_unknow_error"))
    ui_tool.note_insert(text)
    on_barbershop_cancel()
    return
  end
  if result_type == bo2.eBarberShopResult_SameValue then
    local text = sys.format(ui.get_text("personal|barbershop_same_face"))
    ui_tool.note_insert(text, cvalue_color_red)
    on_canel_view_card_value(excel_id)
    return
  end
  if result_type == bo2.eBarberShopResult_LackOfMoney then
    local text = sys.format(ui.get_text("personal|barbershop_lackof_money"))
    ui_tool.note_insert(text, cvalue_color_red)
    on_canel_view_card_value(excel_id)
    return
  end
  if result_type == bo2.eBarberShopResult_LackOfItem then
    local pItemExcel = ui.item_get_excel(_excel_data.cast_item_id)
    local text = sys.format(ui.get_text("personal|barbershop_lackof_item"), pItemExcel.name)
    ui_tool.note_insert(text, cvalue_color_red)
    on_canel_view_card_value(excel_id)
    return
  end
  local text = sys.format(ui.get_text("personal|barbershop_succeed"))
  ui_tool.note_insert(text, cvalue_color_green)
  on_canel_view_card_value(excel_id)
  refresh_current_highlight(excel_id)
end
function on_self_enter(obj, msg)
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_Body, on_self_body, "ui_barbershop.ui_haircut.on_self_body")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_Hat, on_self_hat, "ui_barbershop.ui_haircut.on_self_hat")
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_barbershop.ui_haircut.on_self_enter")
local sig_name = "ui_barbershop:on_signal"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_BarberShopResult, on_handle_result, sig_name)
