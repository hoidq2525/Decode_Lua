local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
local mat_ass_name1_count = 0
local mat_ass_name2_count = 0
local max_enforce_level = 18
local function clear_all(name)
  local ass_vis = function(name)
    local ass_reg_cell = w_detail:search(name)
    local card = ass_reg_cell:search("card_pure")
    card.visible = false
    local btn_min = ass_reg_cell.parent:search("btn_min")
    btn_min.visible = false
    local btn_minus = ass_reg_cell.parent:search("btn_minus")
    btn_minus.visible = false
    local btn_plus = ass_reg_cell.parent:search("btn_plus")
    btn_plus.visible = false
    local btn_max = ass_reg_cell.parent:search("btn_max")
    btn_max.visible = false
    w_quick_buy_1.visible = false
    w_quick_buy_2.visible = false
  end
  local mat_vis = function(name)
    local mat_reg_cell = w_detail:search(name)
    local card = mat_reg_cell:search("card_pure")
    card.visible = false
  end
  ass_vis("mat_ass_name1")
  ass_vis("mat_ass_name2")
  mat_vis("mat_reg_0")
  mat_vis("mat_reg_1")
  mat_vis("mat_reg_2")
  mat_vis("mat_reg_3")
  local prob = w_detail:search("prob")
  local mtf = {}
  mtf.val = 0
  prob.mtf = ui_widget.merge_mtf(mtf, ui.get_text("equip|add_prob"))
  local total = w_detail:search("total")
  mtf = {}
  mtf.val = 0
  mtf.cur = 0
  total.mtf = ui_widget.merge_mtf(mtf, ui.get_text("equip|add_total"))
  ui_cell.batch_clear(w_detail, {
    "mat_ass_name1",
    "mat_ass_name2"
  })
  ui_cell.batch_clear(w_detail, {
    "mat_reg_0",
    "mat_reg_1",
    "mat_reg_2",
    "mat_reg_3"
  })
end
local get_line = function(level, sel_id)
  for i = 0, bo2.gv_equip_enforce_new.size - 1 do
    local excel = bo2.gv_equip_enforce_new:get(i)
    local l_min = excel.level_seg[0]
    local l_max = excel.level_seg[1]
    local enf_idx = excel.enf_idx
    if sel_id == enf_idx and level >= l_min and level <= l_max then
      return excel
    end
  end
  return nil
end
local function update_enforce_info(line, info)
  local function update_ass_item(name, ass_id, max)
    local ass_reg_cell = w_detail:search(name)
    ui_cell.set(ass_reg_cell, ass_id, max)
    local card = ass_reg_cell:search("card_pure")
    card.excel_id = ass_id
    card.require_count = max
    card.count = 0
    card.visible = true
    local card2 = ass_reg_cell:search("card")
    local max_count = card2.count
    local quick_ctrl
    if name == L("mat_ass_name1") then
      quick_ctrl = w_quick_buy_1
      if max_count < mat_ass_name1_count then
        card.count = max_count
      else
        card.count = mat_ass_name1_count
      end
    elseif name == L("mat_ass_name2") then
      quick_ctrl = w_quick_buy_2
      if max_count < mat_ass_name2_count then
        card.count = max_count
      else
        card.count = mat_ass_name2_count
      end
    end
    if quick_ctrl ~= nil then
      local tool_goods_id = ui_supermarket2.shelf_quick_buy_id(ass_id)
      if tool_goods_id ~= 0 then
        quick_ctrl.visible = true
        quick_ctrl.name = tostring(tool_goods_id)
      else
        quick_ctrl.visible = false
      end
    end
    local btn_min = ass_reg_cell.parent:search("btn_min")
    btn_min.visible = true
    local btn_minus = ass_reg_cell.parent:search("btn_minus")
    btn_minus.visible = true
    local btn_plus = ass_reg_cell.parent:search("btn_plus")
    btn_plus.visible = true
    local btn_max = ass_reg_cell.parent:search("btn_max")
    btn_max.visible = true
  end
  local function update_mat_item(idx, excel)
    local mat_reg_cell = w_detail:search("mat_reg_" .. idx)
    local excel_id = excel.mat[idx][0]
    local max = excel.mat[idx][1]
    if excel_id ~= 0 and max ~= 0 then
      local item_excel = ui.item_get_excel(excel_id)
      local ref_excel = bo2.gv_refine_variety:find(item_excel.variety)
      if ref_excel == nil then
        ref_excel = bo2.gv_refine_med_variety:find(item_excel.variety)
      end
      if w_use_bound_mat.check and ref_excel then
        local bd_excel_id = ref_excel.inc_bd_items[item_excel.varlevel]
        excel_id = bd_excel_id
      end
      ui_cell.set(mat_reg_cell, excel_id, max)
    end
  end
  local get_this_time_max = function(line, idx)
    local this_time_max = 0
    for i = 0, 3 do
      local r_h_limit = line.r_h_limit[i]
      if this_time_max < r_h_limit then
        this_time_max = r_h_limit
      end
    end
    return this_time_max
  end
  ui_cmn.money_set(w_money, line.money)
  if line.kind == 1 then
    w_bounded.bounded = true
  elseif line.kind == 0 then
    w_bounded.bounded = false
  end
  for i = 1, max_enforce_level do
    local s_panel = w_panel_enforce_grid:search("grid" .. i)
    s_panel.svar.id = i
    local encircle = s_panel:search("encircle")
    encircle.visible = false
    local max_enforce_count = info:get_data_8(bo2.eItemByte_EnforceMaxCount)
    local cur_enforce = s_panel:search("cur_enforce")
    local lock = s_panel:search("lock")
    if i > max_enforce_count then
      cur_enforce.mtf = ""
      lock.visible = true
    else
      local enforce_data = ui.item_get_enforce_data(info, i)
      local enf_line = get_line(info.excel.reqlevel, i)
      if enf_line == nil then
        return
      end
      cur_enforce.mtf = "<a:m><c+:00FF00>" .. enforce_data .. "<c->/<c+:FFFF00>" .. get_this_time_max(enf_line) .. "<c->"
      lock.visible = false
    end
  end
  for i = 0, 1 do
    update_ass_item(L("mat_ass_name") .. i + 1, line.ass_item[i], line.ass_max)
  end
  for i = 0, 3 do
    update_mat_item(i, line)
  end
  local sel_ctrl = w_panel_enforce_grid:search("grid" .. line.enf_idx)
  sel_ctrl:search("encircle").visible = true
  local prob = w_detail:search("prob")
  local mtf = {}
  mtf.val = 0
  prob.mtf = ui_widget.merge_mtf(mtf, ui.get_text("equip|add_prob"))
  local total = w_detail:search("total")
  mtf = {}
  mtf.val = line.ass_max
  mtf.cur = 0
  total.mtf = ui_widget.merge_mtf(mtf, ui.get_text("equip|add_total"))
end
function on_single_enforce_mouse(ctrl, msg)
  if msg ~= ui.mouse_lbutton_click then
    return
  end
  local card_equip = w_cell_equip:search("card")
  local info = card_equip.info
  if info == nil then
    return
  end
  local enforce_max = info:get_data_8(bo2.eItemByte_EnforceMaxCount)
  if enforce_max < ctrl.svar.id then
    return
  end
  w_panel_enforce_grid.svar.sel_id = ctrl.svar.id
  local enf_line = get_line(info.excel.reqlevel, ctrl.svar.id)
  if enf_line == nil then
    return
  end
  update_enforce_info(enf_line, info)
end
function on_item_count(card, excel_id, bag, all)
  post_product_update()
end
function getequipslot(type)
  local n = bo2.gv_item_type:find(type)
  if n ~= nil then
    return n.equip_slot
  end
  return 0
end
function get_equip_enforce(info)
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  local ptype = excel.ptype
  if ptype == nil then
    return nil
  end
  if ptype.equip_slot >= bo2.eItemSlot_EquipBeg and ptype.equip_slot <= bo2.eItemSlot_EquipEnd and ptype.equip_slot ~= bo2.eItemSlot_HWeapon and ptype.equip_slot ~= bo2.eItemSlot_Ornament then
    return true
  end
  if ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
    return true
  end
  if ptype.id == bo2.eItemtype_Enforce then
    return true
  end
  if excel.id == bo2.gv_define:find(1091).value.v_int then
    return true
  end
  return false
end
function on_equip_card_mouse(ctrl, msg)
end
function on_equip_card_tip_show(tip)
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item(stk, excel, card.info)
  local stk_use
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|enforce_rclick_to_clear"), ui_tool.cs_tip_color_operation)
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_enforce_confirm(msg)
  if msg.result == 0 then
    return
  end
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  local info1 = w_cell_tool:search("card").info
  if info1 == nil then
    return
  end
  local info2 = w_cell_ensure:search("card").info
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_EnforceEquipV20150115)
  v:set64(packet.key.item_key, info.only_id)
  v:set64(packet.key.item_key1, info1.only_id)
  local id = w_panel_enforce_grid.svar.sel_id
  v:set(packet.key.cmn_id, id)
  if info2 ~= nil then
    v:set64(packet.key.item_key2, info2.only_id)
  end
  if w_money:search("rmbchk").check then
    v:set(packet.key.rmb_amount, 1)
  end
  local max_count = info:get_data_8(bo2.eItemByte_EnforceMaxCount)
  local cur_sel_id = w_panel_enforce_grid.svar.sel_id
  if max_count < cur_sel_id then
    return
  end
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function on_keep_click(btn)
end
function on_enforce_click(btn)
  local text_show = L("")
  local bMsg = false
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  local enf_line = get_line(info.excel.reqlevel, w_panel_enforce_grid.svar.sel_id)
  if enf_line == nil then
    return
  end
  for i = 0, 3 do
    local excel_id = enf_line.mat[i][0]
    local item_count = enf_line.mat[i][1]
    if excel_id ~= 0 and item_count ~= 0 then
      local item_excel = ui.item_get_excel(excel_id)
      local ref_excel = bo2.gv_refine_variety:find(item_excel.variety)
      if ref_excel == nil then
        ref_excel = bo2.gv_refine_med_variety:find(item_excel.variety)
      end
      if w_use_bound_mat.check and ref_excel then
        local bd_item_id = ref_excel.inc_bd_items[item_excel.varlevel]
        local bd_item_excel = ui.item_get_excel(bd_item_id)
        local cir_item_excel = ui.item_get_excel(id)
        local bd_item_cnt = ui.item_get_count(bd_item_id, true)
        local cir_item_cnt = ui.item_get_count(cir_item_id, true)
        local req_cnt = item_count
        if bd_item_cnt < req_cnt then
          local tb_param1 = {
            bd_item = bd_item_id,
            cir_num = req_cnt - bd_item_cnt,
            cir_item = id
          }
          local text_model1 = ui.get_text("npcfunc|refine_bd_msg")
          local txt_result1 = ui_widget.merge_mtf(tb_param1, text_model1)
          text_show = text_show .. txt_result1 .. L("\n")
          bMsg = true
        end
      end
    end
  end
  local use_bd_mat = 0
  if w_use_bound_mat.check then
    use_bd_mat = 1
  end
  local ass_reg_cell1 = w_detail:search("mat_ass_name1")
  local card1 = ass_reg_cell1:search("card_pure")
  local ass_reg_cell2 = w_detail:search("mat_ass_name2")
  local card2 = ass_reg_cell2:search("card_pure")
  local sel_id = w_panel_enforce_grid.svar.sel_id
  if sel_id == 0 then
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_EnforceEquipV20150115)
  v:set64(packet.key.item_key, info.only_id)
  v:set(packet.key.item_key1, card1.count)
  v:set(packet.key.item_key2, card2.count)
  v:set(packet.key.cmn_id, sel_id)
  v:set(packet.key.itemdata_val, use_bd_mat)
  if w_money:search("rmbchk").check then
    v:set(packet.key.rmb_amount, 1)
  end
  if bMsg then
    local function on_msg_callback(msg_call)
      if msg_call.result ~= 1 then
        return
      end
      bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
    end
    local msg = {callback = on_msg_callback, text = text_show}
    ui_widget.ui_msg_box.show_common(msg)
  else
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  end
end
function on_ass_quick_buy(btn)
  ui_supermarket2.shelf_singleBuy(btn)
end
function on_visible(w, vis)
  if vis then
    mat_ass_name1_count = 0
    mat_ass_name2_count = 0
  end
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
  ui_cell.clear(w_cell_equip.parent.parent)
  if sys.check(w_tool_quick_buy) then
    w_tool_quick_buy.visible = false
  end
  if sys.check(w_money) then
    ui_cmn.money_set(w_money, 0, 0)
  end
  for i = 1, 18 do
    local s_panel = w_panel_enforce_grid:search("grid" .. i)
    s_panel.svar.id = i
    local cur_enforce = s_panel:search("cur_enforce")
    local lock = s_panel:search("lock")
    local encircle = s_panel:search("encircle")
    encircle.visible = false
    lock.visible = true
    cur_enforce.mtf = ""
  end
  clear_all()
  w_panel_enforce_grid.svar.sel_id = 1
end
function on_ensure_drop(pn, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  ui.clean_drop()
  local info = ui.item_of_only_id(data:get("only_id"))
  if info.excel.id == bo2.gv_define:find(1091).value.v_int then
    ui_npcfunc.ui_cell.drop(pn, info)
  end
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|enforce_rclick_to_place")
end
function item_rbutton_check(info)
  local enf = get_equip_enforce(info)
  return enf
end
function item_rbutton_use(info)
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  local ptype = excel.ptype
  if ptype == nil then
    return nil
  end
  if ptype.equip_slot >= bo2.eItemSlot_EquipBeg and ptype.equip_slot <= bo2.eItemSlot_EquipEnd and ptype.equip_slot ~= bo2.eItemSlot_HWeapon and ptype.equip_slot ~= bo2.eItemSlot_Ornament then
    ui_cell.drop(w_cell_equip, info)
  end
  if ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
    ui_cell.drop(w_cell_equip, info)
  end
  if ptype.id == bo2.eItemtype_Enforce then
  end
  if ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
    ui_cell.drop(w_cell_equip, info)
  end
  if info.excel.id == bo2.gv_define:find(1091).value.v_int then
    ui_cell.drop(w_cell_ensure, info)
  end
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
function on_equip_change(card, onlyid, info)
  if not w_main.visible then
    mat_ass_name1_count = nil
    mat_ass_name2_count = nil
    return
  end
  local info = card.info
  if sys.check(w_tool_quick_buy) then
    w_tool_quick_buy.visible = false
  end
  if sys.check(w_money) then
    ui_cmn.money_set(w_money, 0, 0)
  end
  for i = 1, max_enforce_level do
    local s_panel = w_panel_enforce_grid:search("grid" .. i)
    s_panel.svar.id = i
    local cur_enforce = s_panel:search("cur_enforce")
    local lock = s_panel:search("lock")
    local encircle = s_panel:search("encircle")
    encircle.visible = false
    lock.visible = true
    cur_enforce.mtf = ""
  end
  clear_all()
  if info == nil then
    w_panel_enforce_grid.svar.sel_id = 0
    return
  end
  if not sys.check(w_panel_enforce_grid.svar.sel_id) or w_panel_enforce_grid.svar.sel_id == 0 then
    w_panel_enforce_grid.svar.sel_id = 1
  end
  local enf_line = get_line(info.excel.reqlevel, w_panel_enforce_grid.svar.sel_id)
  if enf_line == nil then
    return
  end
  update_enforce_info(enf_line, info)
end
function on_check_bound_mat_click(btn)
  local card_equip = w_cell_equip:search("card")
  local info = card_equip.info
  if info == nil then
    return
  end
  local sel_id = w_panel_enforce_grid.svar.sel_id
  local enf_line = get_line(info.excel.reqlevel, sel_id)
  if enf_line == nil then
    return
  end
  update_enforce_info(enf_line, info)
end
local play_animation = function(frame, w_src, w_dst)
  frame.svar.target = w_src
  frame:frame_clear()
  frame.visible = true
  local bs = w_dst.size
  local ws = w_src.size
  local pos = w_dst:control_to_window(ui.point(0, 0)) + bs * 0.5
  local src = w_src.offset + ws * 0.5
  local dis = pos - src
  local tick = math.sqrt(math.sqrt(dis.x * dis.x + dis.y * dis.y)) * 24
  if tick < 100 then
    tick = 100
  end
  local init_pos = w_src:control_to_window(ui.point(0, 0)) - w_src.offset
  f = frame:frame_insert(tick, w_src)
  f.color1 = "CCFFFFFF"
  f.color2 = "99FFFFFF"
  f:set_scale1(1, 1)
  f:set_scale2(bs.x / ws.x, bs.y / ws.y)
  f:set_translate1(init_pos.x, init_pos.y)
  f:set_translate2(dis.x, dis.y)
  f = frame:frame_insert(100, w_src)
  f.color1 = "99FFFFFF"
  f.color2 = "00FFFFFF"
  f:set_scale1(bs.x / ws.x, bs.y / ws.y)
  f:set_scale2(bs.x / ws.x, bs.y / ws.y)
  f:set_translate1(dis.x, dis.y)
  f:set_translate2(dis.x, dis.y)
  return tick + 100
end
function showenforceinfo20150115(cmd, data)
  local svr_sel_id = data:get(packet.key.cmn_id).v_int
  local cli_sel_id = w_panel_enforce_grid.svar.sel_id
  local this_value = data:get(packet.key.cmn_index).v_int
  local key = data:get(packet.key.item_key).v_string
  if svr_sel_id ~= cli_sel_id then
    return
  end
  local info = ui.item_of_only_id(key)
  local before_value = ui.item_get_enforce_data(info, svr_sel_id)
  local function on_msg_callback(msg_call)
    local info = w_cell_equip:search("card").info
    local v = sys.variant()
    v:set(packet.key.item_key, info.only_id)
    if msg_call.result ~= 1 then
      bo2.send_variant(packet.eCTS_UI_EnforceCancel20150115, v)
    else
      bo2.send_variant(packet.eCTS_UI_EnforceConfirm20150115, v)
      local w_mover_target = w_panel_enforce_grid:search("grid" .. svr_sel_id)
      local mat1 = w_detail:search("mat_reg_0")
      local mat2 = w_detail:search("mat_reg_1")
      local mat3 = w_detail:search("mat_reg_2")
      local mat4 = w_detail:search("mat_reg_3")
      local ass1 = w_detail:search("mat_ass_name1")
      local ass2 = w_detail:search("mat_ass_name2")
      local time = play_animation(w_hide_anim1, mat1, w_mover_target)
      play_animation(w_hide_anim2, mat2, w_mover_target)
      play_animation(w_hide_anim3, mat3, w_mover_target)
      play_animation(w_hide_anim4, mat4, w_mover_target)
      play_animation(w_hide_anim5, ass1, w_mover_target)
      play_animation(w_hide_anim6, ass2, w_mover_target)
    end
  end
  local mtf = {}
  mtf.cur = this_value
  mtf.prev = before_value
  text_show = ui_widget.merge_mtf(mtf, ui.get_text("equip|msg_notice"))
  local msg = {callback = on_msg_callback, text = text_show}
  ui_widget.ui_msg_box.show_common(msg)
end
function notify_leak_ass(card, max_count)
  local mtf = {}
  mtf.item = sys.format(L("<i:%d>"), card.excel_id)
  mtf.count = max_count
  local txt = ui_widget.merge_mtf(mtf, ui.get_text("equip|leak_item"))
  ui_tool.note_insert(txt, L("FF0000"))
end
local function set_ass_count(ass, count)
  local ass_type = w_detail:search("mat_ass_name1")
  local card_pure = ass:search("card_pure")
  card_pure.count = count
  if ass == ass_type then
    mat_ass_name1_count = count
  else
    mat_ass_name2_count = count
  end
end
local get_ass_count = function(ass_type)
  local card = w_cell_equip:search(L("card"))
  if not sys.check(card) then
    return 0
  end
  local info = card.info
  if not sys.check(info) then
    return 0
  end
  local card_pure = ass_type:search("card_pure")
  return card_pure.count
end
local function get_ass_total_count()
  local count = 0
  local ass1 = w_detail:search("mat_ass_name1")
  local ass2 = w_detail:search("mat_ass_name2")
  count = get_ass_count(ass1)
  count = count + get_ass_count(ass2)
  return count
end
local function modify_ass_count(count, ass_type, btn)
  if count < 0 then
    return
  end
  local ass_count = get_ass_count(ass_type)
  if ass_count == count then
    return
  end
  local card = w_cell_equip:search(L("card"))
  if not sys.check(card) then
    return
  end
  local info = card.info
  if not sys.check(info) then
    return
  end
  local sel_id = w_panel_enforce_grid.svar.sel_id
  local enf_line = get_line(info.excel.reqlevel, sel_id)
  if enf_line == nil then
    return
  end
  local card = ass_type:search("card")
  local max_count = card.count
  local modify_count = count
  local card_pure = ass_type:search("card_pure")
  local ass_parent = btn:upsearch_name(L("ass"))
  local type = ass_parent:search("mat_ass_name1")
  if ass_type == type then
    modify_count = mat_ass_name1_count
  else
    modify_count = mat_ass_name2_count
  end
  if max_count < modify_count then
    modify_count = max_count
    if max_count ~= enf_line.ass_max then
      notify_leak_ass(card, max_count)
    end
  end
  if modify_count < 0 then
    modify_count = 0
  end
  if modify_count > enf_line.ass_max then
    modify_count = enf_line.ass_max
  end
  card_pure.count = modify_count
  local c_total_count = get_ass_total_count()
  if c_total_count > enf_line.ass_max then
    local other_ass = w_detail:search("mat_ass_name1")
    if other_ass == ass_type then
      other_ass = w_detail:search("mat_ass_name2")
    end
    local c = get_ass_count(other_ass)
    if c > 0 then
      local new_c = c_total_count - enf_line.ass_max
      new_c = c - new_c
      if new_c < 0 then
        new_c = 0
      end
      set_ass_count(other_ass, new_c)
    end
  end
  c_total_count = get_ass_total_count()
  local prob = w_detail:search("prob")
  local mtf = {}
  local ass_reg_cell1 = w_detail:search("mat_ass_name1")
  local card1 = ass_reg_cell1:search("card_pure")
  local ass_reg_cell2 = w_detail:search("mat_ass_name2")
  local card2 = ass_reg_cell2:search("card_pure")
  local add_prob = card1.count * enf_line.ass_prob[0] + card2.count * enf_line.ass_prob[1]
  mtf.val = math.floor(add_prob / 10000)
  prob.mtf = ui_widget.merge_mtf(mtf, ui.get_text("equip|add_prob"))
  local total = w_detail:search("total")
  mtf = {}
  local total_count = enf_line.ass_max
  mtf.val = total_count
  mtf.cur = c_total_count
  total.mtf = ui_widget.merge_mtf(mtf, ui.get_text("equip|add_total"))
end
function on_click_ass_minus(btn)
  local ass_parent = btn:upsearch_name(L("ass"))
  if not sys.check(ass_parent) then
    return
  end
  local type = ass_parent:search("mat_ass_name1")
  local ass_type
  if type ~= nil and sys.check(type) ~= nil then
    ass_type = type
  else
    ass_type = ass_parent:search("mat_ass_name2")
  end
  if ass_type == nil then
    return
  end
  local count = get_ass_count(ass_type)
  modify_mat_ass_count(count - 1, btn)
  modify_ass_count(count - 1, ass_type, btn)
end
function on_click_ass_plus(btn)
  local ass_parent = btn:upsearch_name(L("ass"))
  if not sys.check(ass_parent) then
    return
  end
  local type = ass_parent:search("mat_ass_name1")
  local ass_type
  if type ~= nil and sys.check(type) ~= nil then
    ass_type = type
  else
    ass_type = ass_parent:search("mat_ass_name2")
  end
  if ass_type == nil then
    return
  end
  local count = get_ass_count(ass_type)
  modify_mat_ass_count(count + 1, btn)
  modify_ass_count(count + 1, ass_type, btn)
end
function on_ass_btn_max(btn)
  local ass_parent = btn:upsearch_name(L("ass"))
  if not sys.check(ass_parent) then
    return
  end
  local type = ass_parent:search("mat_ass_name1")
  local ass_type
  if type ~= nil and sys.check(type) ~= nil then
    ass_type = type
  else
    ass_type = ass_parent:search("mat_ass_name2")
  end
  if ass_type == nil then
    return
  end
  local card = ass_type:search("card")
  local max_count = card.count
  if max_count == 0 then
    notify_leak_ass(card, max_count)
  else
    modify_mat_ass_count(max_count, btn)
    modify_ass_count(max_count, ass_type, btn)
  end
end
function on_ass_btn_min(btn)
  local ass_parent = btn:upsearch_name(L("ass"))
  if not sys.check(ass_parent) then
    return
  end
  local type = ass_parent:search("mat_ass_name1")
  local ass_type
  if type ~= nil and sys.check(type) ~= nil then
    ass_type = type
  else
    ass_type = ass_parent:search("mat_ass_name2")
  end
  if ass_type == nil then
    return
  end
  modify_mat_ass_count(0, btn)
  modify_ass_count(0, ass_type, btn)
end
function modify_mat_ass_count(count, btn)
  local card = w_cell_equip:search(L("card"))
  if not sys.check(card) then
    return
  end
  local info = card.info
  if not sys.check(info) then
    return
  end
  local sel_id = w_panel_enforce_grid.svar.sel_id
  local enf_line = get_line(info.excel.reqlevel, sel_id)
  if enf_line == nil then
    return
  end
  local max_count = enf_line.ass_max
  if count > max_count then
    count = max_count
    if count ~= enf_line.ass_max then
      notify_leak_ass(card, count)
    end
  end
  local ass_parent = btn:upsearch_name(L("ass"))
  local type = ass_parent:search("mat_ass_name1")
  if type ~= nil and sys.check(type) ~= nil then
    if mat_ass_name1_count ~= count and max_count >= count and count >= 0 then
      mat_ass_name1_count = count
    end
  elseif mat_ass_name2_count ~= count and max_count >= count and count >= 0 then
    mat_ass_name2_count = count
  end
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_npcfun.equip_enforce"
reg(packet.eSTC_UI_ShowEnforceInfo20150115, showenforceinfo20150115, sig)
