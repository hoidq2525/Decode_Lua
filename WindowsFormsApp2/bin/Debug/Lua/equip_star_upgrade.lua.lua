local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
local per_count = 10000
local cell_count = 0
local function clear_all()
  if sys.check(w_detail) then
    ui_cell.batch_clear(w_detail, {
      "mat_equip",
      "mat_ass_equip0",
      "mat_ass_equip1",
      "mat_ass_equip2",
      "mat_ass_equip3",
      "mat_reg_0",
      "mat_reg_1",
      "mat_reg_2"
    })
  end
  w_pdt_prev.mtf = L("")
  w_prob_desc.mtf = L("")
  w_prob_desc0.mtf = L("")
  w_btn_upgrade.enable = false
  cell_count = 0
  local card_vis = function(name)
    local mat_reg_cell = w_detail:search(name)
    local card = mat_reg_cell:search("card_pure")
    card.visible = false
  end
  card_vis("mat_reg_0")
  card_vis("mat_reg_1")
  card_vis("mat_reg_2")
  clear_all_highlight()
end
local get_equip_star_upgrade_line = function(info, item_id)
  if info == nil then
    return nil
  end
  local upgrade_line = bo2.gv_equip_star_upgrade:find(item_id)
  if upgrade_line == nil then
    return nil
  end
  local star = info.star
  local n_size = upgrade_line.inc_upgrade.size
  for i = 0, n_size - 1 do
    local id = upgrade_line.inc_upgrade[i]
    local param = bo2.gv_equip_star_upgrade_param:find(id)
    if param == nil then
      return nil
    end
    if param.pre_star == star then
      return param
    end
  end
  return nil
end
local is_valid_ass_equip = function(tgt_info, ass_info)
  local ass_item_id = ass_info.excel_id
  local ass_line = bo2.gv_equip_star_upgrade:find(ass_item_id)
  if ass_line == nil then
    return false
  end
  if tgt_info:get_data_8(bo2.eItemByte_Star) ~= ass_info:get_data_8(bo2.eItemByte_Star) or tgt_info.excel.reqlevel ~= ass_info.excel.reqlevel then
    return false
  end
  return true
end
function clear_all_highlight()
  for i = 0, 3 do
    local name = sys.format(L("mat_ass_equip%d"), i)
    local ass_equip = w_ass_equip:search(name)
    local fig_highlight = ass_equip:search("ass_flicker")
    fig_highlight.visible = false
  end
end
function check_mat()
  local update = false
  if get_mat_count(w_mat_reg) > get_mat_max_count(w_mat_reg) then
    set_mat_count(w_mat_reg, 0)
    update = true
  end
  if get_mat_count(w_mat_reg0) > get_mat_max_count(w_mat_reg0) then
    set_mat_count(w_mat_reg0, 0)
    update = true
  end
  if get_mat_count(w_mat_reg2) > get_mat_max_count(w_mat_reg2) then
    set_mat_count(w_mat_reg2, 0)
    update = true
  end
  if update == false then
    return
  end
  local card_equip = w_cell_equip:search("card")
  local info = card_equip.info
  if info == nil then
    return
  end
  local upgrade_line = get_equip_star_upgrade_line(info, info.excel_id)
  local c_total_count = get_mat_total_count()
  on_refresh_prob_desc(upgrade_line, c_total_count)
end
local event
function do_product_update()
  if not sys.check(w_btn_upgrade) then
    return
  end
  w_btn_upgrade.enable = false
  local card_equip = w_cell_equip:search("card")
  local info_equip = card_equip.info
  if info_equip == nil or info_equip:identify_finished() == false then
    clear_all()
    return
  end
  local function on_time_check()
    event = nil
    if sys.check(ui_npcfunc.ui_equip_star_upgrade.w_main) ~= true then
      return
    end
    check_mat()
    local check_ass_equip = function(name)
      local ass_equip = w_ass_equip:search(name)
      if sys.check(ass_equip) ~= true then
        return nil
      end
      local card = ass_equip:search(L("card"))
      if card.info == nil then
        return nil
      end
      return ass_equip
    end
    for i = 0, 3 do
      local name = sys.format(L("mat_ass_equip%d"), i)
      if check_ass_equip(name) == nil then
        return
      end
    end
    w_btn_upgrade.enable = true
  end
  if sys.check(event) then
    bo2.RemoveTimeEvent(event)
  end
  event = bo2.AddTimeEvent(5, on_time_check)
end
function post_product_update()
  w_main:insert_post_invoke(do_product_update, "ui_npcfunc.ui_equip_star_upgrade.do_product_update")
end
function get_mat_count(mat_reg_cell)
  local card = w_cell_equip:search(L("card"))
  if sys.check(card) ~= true then
    return 0
  end
  local info = card.info
  if sys.check(info) ~= true then
    return 0
  end
  local card_pure = mat_reg_cell:search("card_pure")
  return card_pure.count
end
function set_mat_count(mat_reg_cell, count)
  local card_pure = mat_reg_cell:search("card_pure")
  card_pure.count = count
end
function get_mat_max_count(mat_reg_cell)
  local card = mat_reg_cell:search("card")
  local max_count = card.count
  return max_count
end
function get_mat_total_count()
  local count0 = 0
  count0 = get_mat_count(w_mat_reg)
  count0 = count0 + get_mat_count(w_mat_reg0)
  return count0
end
function notify_leak_mat(card, max_count)
  local mtf = {}
  mtf.item = sys.format(L("<i:%d>"), card.excel_id)
  mtf.count = max_count
  local txt = ui_widget.merge_mtf(mtf, ui.get_text("equip|leak_item"))
  ui_tool.note_insert(txt, L("FF0000"))
end
function modify_mat_count(count, mat)
  if count < 0 then
    return
  end
  local mat_count = get_mat_count(mat)
  if mat_count == count then
    return
  end
  local card = w_cell_equip:search(L("card"))
  if sys.check(card) ~= true then
    return
  end
  local info = card.info
  if sys.check(info) ~= true then
    return
  end
  local upgrade_line = get_equip_star_upgrade_line(info, info.excel_id)
  if upgrade_line == nil then
    return
  end
  local mat_reg_cell = mat
  local card = mat_reg_cell:search("card")
  local max_count = card.count
  local card_pure = mat_reg_cell:search("card_pure")
  local modify_count = count
  if max_count < modify_count then
    modify_count = max_count
    if max_count ~= upgrade_line.req_item_max then
      notify_leak_mat(card, max_count)
    end
  end
  if modify_count < 0 then
    modify_count = 0
  end
  if modify_count > upgrade_line.req_item_max then
    modify_count = upgrade_line.req_item_max
  end
  card_pure.count = modify_count
  local c_total_count = get_mat_total_count()
  if c_total_count > upgrade_line.req_item_max then
    local other_mat = w_mat_reg
    if mat == w_mat_reg then
      other_mat = w_mat_reg0
    end
    local c = get_mat_count(other_mat)
    if c > 0 then
      local new_c = c_total_count - upgrade_line.req_item_max
      new_c = c - new_c
      if new_c < 0 then
        new_c = 0
      end
      set_mat_count(other_mat, new_c)
    end
  end
  c_total_count = get_mat_total_count()
  on_refresh_prob_desc(upgrade_line, c_total_count)
end
function on_click_mat_minus(btn)
  local mat_parent = btn:upsearch_name(L("mat"))
  if sys.check(mat_parent) ~= true then
    return
  end
  local type0 = mat_parent:search(L("mat_reg_0"))
  local mat_type
  if type0 ~= nil and sys.check(type0) ~= nil then
    mat_type = type0
  else
    mat_type = mat_parent:search(L("mat_reg_1"))
  end
  local count = get_mat_count(mat_type)
  modify_mat_count(count - 1, mat_type)
end
function on_click_mat_plus(btn)
  local mat_parent = btn:upsearch_name(L("mat"))
  if sys.check(mat_parent) ~= true then
    return
  end
  local type0 = mat_parent:search(L("mat_reg_0"))
  local mat_type
  if type0 ~= nil and sys.check(type0) ~= nil then
    mat_type = type0
  else
    mat_type = mat_parent:search(L("mat_reg_1"))
  end
  local count = get_mat_count(mat_type)
  modify_mat_count(count + 1, mat_type)
end
function on_check_lock_item(btn)
  if btn.check == true then
    on_click_lock_mat_max(btn)
  else
    set_mat_count(w_mat_reg2, 0)
  end
end
function on_click_lock_mat_max(btn)
  local card = w_cell_equip:search(L("card"))
  if sys.check(card) ~= true then
    return
  end
  local info = card.info
  if sys.check(info) ~= true then
    return
  end
  local upgrade_line = get_equip_star_upgrade_line(info, info.excel_id)
  if upgrade_line == nil then
    return
  end
  local count = get_mat_max_count(w_mat_reg2)
  if count >= upgrade_line.req_lock_item_max then
    set_mat_count(w_mat_reg2, upgrade_line.req_lock_item_max)
  else
    local q_buy = w_mat_reg2:search(L("q_buy"))
    if sys.check(q_buy) and q_buy.visible == true then
      local mtf = {}
      mtf.item_count = upgrade_line.req_lock_item_max
      mtf.item_has = count
      mtf.item_name = sys.format(L("<i:%d>"), upgrade_line.req_lock_item_id)
      local txt = ui_widget.merge_mtf(mtf, ui.get_text("equip|leak_of_lock_mat_text"))
      ui_tool.note_insert(txt, "00FF00")
      q_buy.svar.count = upgrade_line.req_lock_item_max - count
      on_quick_buy(q_buy)
      q_buy.svar.count = 0
      btn.check = false
    end
  end
end
function on_click_mat_max(btn)
  local mat_parent = btn:upsearch_name(L("mat"))
  if sys.check(mat_parent) ~= true then
    return
  end
  local type0 = mat_parent:search(L("mat_reg_0"))
  local mat_type
  if type0 ~= nil and sys.check(type0) ~= nil then
    mat_type = type0
  else
    mat_type = mat_parent:search(L("mat_reg_1"))
  end
  local card = mat_type:search("card")
  local max_count = card.count
  if max_count == 0 then
    notify_leak_mat(card, max_count)
  else
    modify_mat_count(max_count, mat_type)
  end
end
function on_item_count(card, excel_id, bag, all)
  local c = ui_cell.top_of(card)
  local name = c.name
  if name ~= L("mat_reg_0") and name ~= L("mat_reg_1") and name ~= L("mat_reg_2") then
    return
  end
  local btn_quick_buy = c.parent:search(L("q_buy"))
  btn_quick_buy.visible = false
  local w_mat_minus = c:search(L("btn_minus"))
  local w_mat_plus = c:search(L("btn_plus"))
  w_mat_minus.visible = false
  w_mat_plus.visible = false
  local w_mat_max = c.parent:search(L("btn_max"))
  if sys.check(w_mat_max) then
    w_mat_max.visible = false
  end
  if excel_id == 0 then
    return
  end
  local mat_max = true
  if name == L("mat_reg_2") then
    local check = c.parent:search(L("btn_check"))
    check.check = false
    mat_max = false
  else
    w_mat_minus.visible = true
    w_mat_plus.visible = true
  end
  if sys.check(w_mat_max) then
    w_mat_max.visible = mat_max
  end
  local goods_id = ui_supermarket2.shelf_quick_buy_id(excel_id)
  if goods_id ~= 0 then
    btn_quick_buy.svar.name = sys.format(L("%s"), goods_id)
    btn_quick_buy.visible = true
  end
end
function on_refresh_prob_desc(upgrade_line, count)
  local stk = sys.mtf_stack()
  local prob = {}
  local base = upgrade_line.base_prob / per_count
  prob.base = sys.format(L("<c+:FFFFFF>%.2f<c->"), base)
  prob.add_prob = sys.format(L("<c+:FFFFFF>%.2f<c->"), upgrade_line.add_prob / per_count)
  if count > 0 then
    local add_data = upgrade_line.add_prob * count / per_count
    prob.add = sys.format(L("<c+:00FF00>%.2f<c->"), add_data)
    prob.persent = sys.format(L("<c+:00FF00>%.2f<c->"), base + add_data)
  else
    prob.add = sys.format(L("<c+:FFFFFF>0<c->"))
    prob.persent = prob.base
  end
  local txt = ui_widget.merge_mtf(prob, ui.get_text("equip|current_prob"))
  stk:raw_push(txt)
  stk:raw_push("\n")
  stk:raw_push(ui_widget.merge_mtf(prob, ui.get_text("equip|detal_prob")))
  w_prob_desc.mtf = stk.text
  w_prob_desc0.mtf = ui_widget.merge_mtf(prob, ui.get_text("equip|add_item_prob"))
end
function on_equip_change(card)
  post_product_update()
  w_pdt_prev.mtf = L("")
  cell_count = 0
  local info = card.info
  if info == nil then
    return
  end
  local upgrade_line = get_equip_star_upgrade_line(info, info.excel_id)
  if upgrade_line == nil then
    return
  end
  ui_cell.batch_clear(w_detail, {
    "mat_ass_equip0",
    "mat_ass_equip1",
    "mat_ass_equip2",
    "mat_ass_equip3"
  })
  ui_cell.batch_clear(w_detail, {
    "mat_reg_0",
    "mat_reg_1",
    "mat_reg_2"
  })
  local function update_req_item(name, id, max)
    local mat_id = id
    local mat_reg_cell = w_detail:search(name)
    ui_cell.set(mat_reg_cell, mat_id, max)
    local card = mat_reg_cell:search("card_pure")
    card.excel_id = mat_id
    card.require_count = max
    card.count = 0
    card.visible = true
  end
  update_req_item(L("mat_reg_0"), upgrade_line.req_item_id, upgrade_line.req_item_max)
  update_req_item(L("mat_reg_1"), upgrade_line.req_item_bound_id, upgrade_line.req_item_bound_max)
  update_req_item(L("mat_reg_2"), upgrade_line.req_lock_item_id, upgrade_line.req_lock_item_max)
  local function on_refresh_prev()
    local star = info.star + 1
    local stk = sys.mtf_stack()
    local star_text = sys.format(L("<star:%d>"), star)
    stk:raw_push(ui.get_text("equip|upgraded_star"))
    stk:raw_push(star_text)
    w_pdt_prev.mtf = stk.text
  end
  on_refresh_prev()
  on_refresh_prob_desc(upgrade_line, 0)
end
function on_ass_equip_change(card)
  if ui_npcfunc.ui_equip_star_upgrade.w_main.visible ~= true then
    return
  end
  local info = card.info
  if info == nil then
    local lb = ui_cell.top_of(card):search("lb_item")
    if lb then
      lb.text = L("")
    end
    local on_time_check_mat = function()
      check_mat()
    end
    bo2.AddTimeEvent(1, on_time_check_mat)
  end
  do_product_update()
end
function on_equip_drop(pn, msg, pos, data)
  if ui_cell.check_drop(pn, msg, pos, data) == false then
    return
  end
  local card = pn:search("card")
  local info = ui.item_of_only_id(data:get("only_id"))
  if info.box < bo2.eItemBox_BagBeg or info.box >= bo2.eItemBox_BagEnd then
    return
  end
  local upgrade_line = get_equip_star_upgrade_line(info, info.excel_id)
  if upgrade_line == nil then
    local txt = ui.get_text("npcfunc|eu_invalid_tgt_equip")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  if info:identify_finished() == false then
    local txt = ui.get_text("npcfunc|eu_identify_first")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  ui_cell.drop(pn, info)
end
function on_ass_equip_drop(pn, msg, pos, data)
  if ui_cell.check_drop(pn, msg, pos, data) == false then
    return
  end
  local card = pn:search("card")
  local info = ui.item_of_only_id(data:get("only_id"))
  if info.box < bo2.eItemBox_BagBeg or info.box >= bo2.eItemBox_BagEnd then
    return
  end
  local tgt_info = w_cell_equip:search("card").info
  if tgt_info == nil then
    local txt = ui.get_text("npcfunc|eu_tgt_equip_first")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  if info:identify_finished() == false then
    local txt = ui.get_text("npcfunc|eu_identify_first")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  if is_valid_ass_equip(tgt_info, info) == false then
    local txt = ui.get_text("npcfunc|eu_invalid_ass_equip")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  for idx = 0, info:get_data_8(bo2.eItemByte_Holes) - 1 do
    if info:get_data_32(bo2.eItemUInt32_GemBeg + idx) ~= 0 then
      local txt = ui.get_text("npcfunc|eu_gem_tip")
      ui_tool.note_insert(txt, "FF0000")
      return
    end
  end
  ui_cell.drop(pn, info)
end
function on_equip_card_mouse(ctrl, msg)
  if msg ~= ui.mouse_rbutton_down then
    return
  end
  clear_all()
end
function on_ass_equip_card_mouse(ctrl, msg)
  if msg ~= ui.mouse_rbutton_down then
    return
  end
  do_product_update()
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
function on_ass_mat_card_mouse()
end
function on_quick_buy(btn)
  ui_supermarket2.shelf_singleBuy(btn)
end
function on_upgrade_click()
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  local upgrade_line = get_equip_star_upgrade_line(info, info.excel_id)
  if upgrade_line == nil then
    return
  end
  local check_ass_equip = function(name)
    local ass_equip = w_ass_equip:search(name)
    if sys.check(ass_equip) ~= true then
      return nil
    end
    local card = ass_equip:search(L("card"))
    if card.info == nil then
      return nil
    end
    return card.info, card.info:get_data_8(bo2.eItemByte_Bound) == 1
  end
  local ass_bound = false
  for i = 0, 3 do
    local name = sys.format(L("mat_ass_equip%d"), i)
    local item, _bound = check_ass_equip(name)
    if item == nil then
      return
    end
    ass_bound = ass_bound or _bound
    if i == 0 then
      only_id1 = item.only_id
    elseif i == 1 then
      only_id2 = item.only_id
    elseif i == 2 then
      only_id3 = item.only_id
    elseif i == 3 then
      only_id4 = item.only_id
    end
  end
  local current_count = get_mat_total_count()
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_EquipStarUpgrade)
  v:set64(packet.key.item_key, info.only_id)
  v:set64(packet.key.item_key1, only_id1)
  v:set64(packet.key.item_key2, only_id2)
  v:set64(packet.key.item_key3, only_id3)
  v:set64(packet.key.item_key4, only_id4)
  v:set(packet.key.item_key5, get_mat_count(w_mat_reg))
  local bound_item = get_mat_count(w_mat_reg0)
  v:set(packet.key.item_key6, bound_item)
  local lack_lock_item = upgrade_line.req_lock_item_max ~= get_mat_count(w_mat_reg2)
  if lack_lock_item == true then
    v:set(packet.key.item_key7, 0)
  else
    v:set(packet.key.item_key7, 1)
  end
  ass_bound = ass_bound or bound_item ~= 0
  local bound = info:get_data_8(bo2.eItemByte_Bound) == 1 or ass_bound
  local pdt_bd = 0
  if bound then
    pdt_bd = 1
  end
  local is_bound = pdt_bd == 1
  local leck_req = upgrade_line.req_item_max ~= current_count
  local function on_msg_callback(msg_call)
    if msg_call.result ~= 1 then
      return
    end
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  end
  local stk = sys.stack()
  if is_bound == true then
    if ass_bound then
      stk:push(ui.get_text("equip|en_bound_req_item"))
    else
      stk:push(ui.get_text("equip|en_bound_main_item"))
    end
    stk:push("\n")
  end
  if leck_req == true then
    local prob = {}
    prob.count = current_count
    local base = upgrade_line.base_prob / per_count
    local add_data = upgrade_line.add_prob * prob.count / per_count
    prob.persent = sys.format(L("<c+:00FF00>%.2f<c->"), base + add_data)
    local mtf
    if lack_lock_item == true then
      mtf = ui_widget.merge_mtf(prob, ui.get_text("equip|en_lack_mat0"))
    else
      mtf = ui_widget.merge_mtf(prob, ui.get_text("equip|en_lack_mat"))
    end
    stk:push(mtf)
    stk:push(L("\n"))
  end
  if lack_lock_item == true then
    stk:push(ui.get_text("equip|en_lack_lock_mat"))
    stk:push(L("\n"))
  end
  if leck_req == true then
    stk:push(ui.get_text("equip|confirm_consume_lack"))
  end
  if lack_lock_item == true then
    stk:push(ui.get_text("equip|confirm_consume0"))
  else
    stk:push(ui.get_text("equip|confirm_consume"))
  end
  stk:push(L("\n"))
  stk:push(ui.get_text("equip|confirm"))
  local text_show = stk.text
  local msg = {callback = on_msg_callback, text = text_show}
  ui_widget.ui_msg_box.show_common(msg)
end
function on_visible(w, vis)
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
  clear_all()
  if vis then
    ui.item_mark_show("equip_star_upgrade", true)
  else
    ui.item_mark_show("equip_star_upgrade", false)
  end
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|eu_rclick_to_place")
end
function item_rbutton_check(info)
  return true
end
function item_rbutton_use(info)
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  if info:identify_finished() == false then
    local txt = ui.get_text("npcfunc|eu_identify_first")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  local tgt_info = w_cell_equip:search("card").info
  if tgt_info == nil then
    local upgrade_line = get_equip_star_upgrade_line(info, excel.id)
    if upgrade_line == nil then
      local txt = ui.get_text("equip|eu_invalid_tgt_equip")
      ui_tool.note_insert(txt, "FF0000")
      return
    end
    ui_cell.drop(w_cell_equip, info)
  else
    for idx = 0, info:get_data_8(bo2.eItemByte_Holes) - 1 do
      if info:get_data_32(bo2.eItemUInt32_GemBeg + idx) ~= 0 then
        local txt = ui.get_text("npcfunc|eu_gem_tip")
        ui_tool.note_insert(txt, "FF0000")
        return
      end
    end
    if is_valid_ass_equip(tgt_info, info) == false then
      local txt = ui.get_text("npcfunc|eu_invalid_ass_equip")
      ui_tool.note_insert(txt, "FF0000")
      return
    end
    do
      local get_ass_equip = function(name)
        local ass_equip = w_ass_equip:search(name)
        if sys.check(ass_equip) ~= true then
          return nil
        end
        local card = ass_equip:search(L("card"))
        if card.info == nil then
          return ass_equip
        end
        return nil
      end
      clear_all_highlight()
      for i = 0, 3 do
        local name = sys.format(L("mat_ass_equip%d"), i)
        local ass_equip = get_ass_equip(name)
        if ass_equip ~= nil then
          ui_cell.drop(ass_equip, info)
          do
            local fig_highlight = ass_equip:search("ass_flicker")
            fig_highlight.visible = true
            local function on_time_disable()
              if sys.check(fig_highlight) then
                fig_highlight.visible = false
              end
            end
            bo2.AddTimeEvent(25, on_time_disable)
            return
          end
        end
      end
      local name = sys.format(L("mat_ass_equip%d"), cell_count)
      local ass_equip = w_ass_equip:search(name)
      ui_cell.drop(ass_equip, info)
      local fig_highlight = ass_equip:search("ass_flicker")
      fig_highlight.visible = true
      local function on_time_disable()
        if sys.check(fig_highlight) then
          fig_highlight.visible = false
        end
      end
      bo2.AddTimeEvent(25, on_time_disable)
      local txt = ui_widget.merge_mtf({
        count = cell_count + 1
      }, ui.get_text("equip|exchange_item_count"))
      ui_tool.note_insert(txt, "00FF00")
      cell_count = cell_count + 1
      if cell_count > 3 then
        cell_count = 0
      end
    end
  end
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
