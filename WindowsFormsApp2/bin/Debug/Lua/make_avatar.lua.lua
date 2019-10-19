local ui_make_avatar = ui_npcfunc.ui_make_avatar
local ui_tree2 = ui_widget.ui_tree2
local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local g_scn_player
function update_node_highlight(item)
  local vis = item.selected or item.inner_hover
  local fig = item.title:search("pic_highlight")
  fig.visible = vis
end
function on_toggle_node_init(pn)
  local p = pn
  while true do
    if p == nil or sys.is_type(p, "ui_tree_item") then
      break
    end
    p = p.parent
  end
  if p == nil then
    return
  end
  local pic_highlight = pn:search("pic_avatar_highlight")
  local function on_tree_node_toggle(item, expanded)
    if expanded then
      pic_highlight.visible = true
    else
      pic_highlight.visible = false
    end
  end
  p.expanded = false
  p:insert_on_expanded(on_tree_node_toggle)
end
local get_avatar_type_card = function()
  local avatar_type_tab = {
    w_card_hat_m,
    w_card_hat_f,
    w_card_clothes_m,
    w_card_clothes_f
  }
  for idx, val in ipairs(avatar_type_tab) do
    if val:search("ava_highlight").visible == true then
      return val
    end
  end
end
local get_item_sex_req = function(excel)
  if excel == nil then
    return nil
  end
  local requires = excel.requires
  for i = 1, requires.size - 1, 2 do
    if requires[i - 1] == bo2.eItemReq_Sex then
      return requires[i]
    end
  end
  return nil
end
local GetOrderFactory = function()
  local order = 0
  local function fn(ava)
    for i = 3, 0, -1 do
      local id = ava.reg_id[i]
      if id ~= 0 then
        local c = ui.item_get_count(id, true)
        if c == 0 then
          return
        end
        local old = order
        order = order + 1
        return old
      end
    end
  end
  return fn
end
function build_list(ptype, pgender)
  local GetOrder = GetOrderFactory()
  for k = 0, bo2.gv_make_avatar.size - 1 do
    local avatar = bo2.gv_make_avatar:get(k)
    if avatar.disable == 0 then
      local item_excel = ui.item_get_excel(avatar.item_id)
      if item_excel == nil then
        return nil
      end
      local ava_type = item_excel.type
      local ava_gender = get_item_sex_req(item_excel)
      local ava_name = item_excel.name
      local ava_money = avatar.money
      if ptype == ava_type and (ava_gender == nil or pgender == ava_gender) then
        local node = ui_tree2.insert(w_avatar_view.root, GetOrder(avatar))
        node:search("pdt_card").excel_id = item_excel.id
        node:search("lb_money").money = ava_money
        ui_tree2.set_text(node, ava_name)
        node.svar.make_avatar = avatar
        for i = 0, 3 do
          local src_id = avatar.reg_id[i]
          if src_id ~= 0 then
            local src_excel = ui.item_get_excel(src_id)
            local leaf = ui_tree2.insert(node)
            local card = leaf:search("src_card")
            card.excel_id = src_excel.id
            card.require_count = avatar.reg_num[i]
            ui_tree2.set_text(leaf, src_excel.name, src_excel.plootlevel_star.color)
          end
        end
      end
    end
  end
end
local last_sel_card
function on_btn_ava_type_mouse(card, msg, pos, wheel)
  if msg ~= ui.mouse_lbutton_click then
    return
  end
  if last_sel_card ~= nil then
    last_sel_card:search("ava_highlight").visible = false
  end
  local fig_highlight = card:search("ava_highlight")
  if fig_highlight.visible == false then
    fig_highlight.visible = true
  end
  last_sel_card = card
  w_avatar_view.root:item_clear()
  local ptype1 = card.svar.type1
  local ptype2 = card.svar.type2
  local pgender = card.svar.gender
  build_list(ptype1, pgender)
  build_list(ptype2, pgender)
  local idx = card.svar.item_sel_idx
  if idx ~= nil then
    local item = w_avatar_view.root:item_get(idx)
    item:select(true, false)
    item:scroll_to_visible()
  else
    w_avatar_view.slider_y.scroll = 0
  end
  do_product_update()
end
function on_toggle_node_sel(item, sel)
  item.expanded = not item.expanded
  update_node_highlight(item)
  local money_label = item:search("lb_money")
  money_label.visible = not money_label.visible
  if sel == true then
    local avatar_type_ctrl = get_avatar_type_card()
    avatar_type_ctrl.svar.item_sel_idx = item.index
    local scroll_ratio = w_avatar_view.slider_y.scroll
    item:scroll_to_visible()
    w_avatar_view.slider_y.scroll = scroll_ratio
    do_product_update()
    if g_scn_player == nil then
      return
    end
    local avatar = item.svar.make_avatar
    local sex = bo2.player:get_atb(bo2.eAtb_Sex)
    local item_excel = ui.item_get_excel(avatar.item_id)
    local sex2 = get_item_sex_req(item_excel)
    if sex2 ~= nil and sex ~= sex2 then
      return
    end
    g_scn_player:equip_item(item_excel.id)
  end
end
function on_toggle_node_mouse(title, msg)
  local item = title.item
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    update_node_highlight(item)
  elseif msg == ui.mouse_lbutton_click then
  end
end
function on_toggle_icon_mouse(ctrl, msg)
  if msg ~= ui.mouse_lbutton_click then
    return
  end
  local item = ctrl.parent.item
  if sys.type(item) ~= "ui_tree_item" then
    return
  end
  item:select(true, false)
end
function on_ava_type_card_tip_show(tip)
  local stk = sys.mtf_stack()
  local owner = tip.owner
  if owner.name == L("hat_m") then
    ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|mk_ava_m_head"))
  elseif owner.name == L("clothes_m") then
    ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|mk_ava_m_body"))
  elseif owner.name == L("hat_f") then
    ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|mk_ava_f_head"))
  elseif owner.name == L("clothes_f") then
    ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|mk_ava_f_body"))
  else
    return
  end
  ui_tool.ctip_show(tip.owner, stk)
end
function on_btn_make_click(btn)
  local item = w_avatar_view.item_sel
  if not sys.check(item) then
    return
  end
  local avatar = item.svar.make_avatar
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_MakeAvatar)
  v:set(packet.key.item_excelid, avatar.id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function do_product_update()
  w_btn_make.enable = false
  local item = w_avatar_view.item_sel
  if item == nil then
    return
  end
  local make_enable = true
  local avatar = item.svar.make_avatar
  for i = 0, 3 do
    local id = avatar.reg_id[i]
    if id ~= 0 then
      local leaf = item:item_get(i)
      local c = ui.item_get_count(id, true)
    end
  end
  if make_enable == true then
    w_btn_make.enable = true
  end
end
function post_product_update()
  w_avatar_view:insert_post_invoke(do_product_update, "ui_make_avatar.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  post_product_update()
end
function on_init(ctrl)
end
function on_doll_rotl_press(btn, press)
  ui_widget.doll_rotl_press(w_scn, press)
end
function on_doll_rotr_press(btn, press)
  ui_widget.doll_rotr_press(w_scn, press)
end
function on_doll_reset_press(btn)
  w_card_hat_m.svar.item_sel_idx = nil
  w_card_hat_f.svar.item_sel_idx = nil
  w_card_clothes_m.svar.item_sel_idx = nil
  w_card_clothes_f.svar.item_sel_idx = nil
  w_btn_make.enable = false
  w_avatar_view:clear_selection()
  w_avatar_view.slider_y.scroll = 0
  g_scn_player:clear_view_equip()
end
function bind_camera_full()
  local scn = w_scn.scn
  scn:modify_camera_view_type(g_scn_player, bo2.eCameraInitNoAlpha)
  scn:set_radius(4)
  scn:set_fov(0.6)
end
function bind_camera_half()
  local scn = w_scn.scn
  scn:modify_camera_view_type(g_scn_player, bo2.eCameraFace)
  scn:set_radius(4)
  scn:set_fov(0.2)
end
function on_doll_full_check(btn, chk)
  if g_scn_player == nil or not sys.check(w_scn) then
    return
  end
  if chk then
    bind_camera_full()
  else
    bind_camera_half()
  end
end
function on_visible(ctrl, vis)
  if not vis then
    local scn = w_scn.scn
    scn:clear_obj(bo2.eScnObjKind_Player)
    return
  end
  local sex = bo2.player:get_atb(bo2.eAtb_Sex)
  w_card_hat_m.svar.type1 = 153
  w_card_hat_m.svar.type2 = 155
  w_card_hat_m.svar.gender = 1
  w_card_hat_m.svar.item_sel_idx = nil
  if sex == 1 then
    w_card_hat_m:search("ava_highlight").visible = true
    last_sel_card = w_card_hat_m
  else
    w_card_hat_m:search("ava_highlight").visible = false
  end
  w_card_hat_f.svar.type1 = 153
  w_card_hat_f.svar.type2 = 155
  w_card_hat_f.svar.gender = 2
  w_card_hat_f.svar.item_sel_idx = nil
  if sex == 2 then
    w_card_hat_f:search("ava_highlight").visible = true
    last_sel_card = w_card_hat_f
  else
    w_card_hat_f:search("ava_highlight").visible = false
  end
  w_card_clothes_m.svar.type1 = 154
  w_card_clothes_m.svar.type2 = 156
  w_card_clothes_m.svar.gender = 1
  w_card_clothes_m.svar.item_sel_idx = nil
  w_card_clothes_m:search("ava_highlight").visible = false
  w_card_clothes_f.svar.type1 = 154
  w_card_clothes_f.svar.type2 = 156
  w_card_clothes_f.svar.gender = 2
  w_card_clothes_f.svar.item_sel_idx = nil
  w_card_clothes_f:search("ava_highlight").visible = false
  w_avatar_view.root:item_clear()
  build_list(153, sex)
  build_list(155, sex)
  g_scn_player = nil
  w_btn_full_view.check = true
  w_avatar_view.slider_y.scroll = 0
  local obj = bo2.player
  if not sys.check(obj) then
    return
  end
  local scn = w_scn.scn
  scn:clear_obj(bo2.eScnObjKind_Player)
  scn:clear_obj(bo2.eScnObjKind_Npc)
  local p = scn:create_obj(bo2.eScnObjKind_Player, obj.excel.id)
  local bg = scn:create_obj(bo2.eScnObjKind_Npc, 4877)
  p.view_target = obj
  g_scn_player = p
  p:SetNoActionAnim(6, true)
  p:ViewPlayerAnimPlay(1, true)
  bind_camera_full()
end
function show_tip(tip, excel)
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item(stk, excel)
  local stk_use
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_pdt_tip_show(tip)
  local item = tip.owner.parent.item
  if sys.type(item) ~= "ui_tree_item" then
    return
  end
  local avatar = item.svar.make_avatar
  local item_excel = ui.item_get_excel(avatar.item_id)
  show_tip(tip, item_excel)
end
function on_src_tip_show(tip)
  local card = tip.owner:search("src_card")
  local excel = card.excel
  if excel == nil then
    return
  end
  show_tip(tip, excel)
end
