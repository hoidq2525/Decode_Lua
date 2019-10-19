local c_count = 3
local c_lock_idx = 4
local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
local g_post_info
local attrs = {}
local lock_level = bo2.gv_define:find(50022).value.v_int
local clear_req_item = function(name)
  local mat_reg_cell = w_detail:search(name)
  local card = mat_reg_cell:search("card_pure")
  card.visible = false
end
local function clear_all()
  ui_cell.batch_clear(w_detail, {
    "product",
    "mat_equip",
    "mat_reg_0",
    "mat_reg_1",
    "mat_reg_2",
    "mat_reg_3"
  })
  ui_cmn.money_set(w_req_money, 0)
  w_pro_list:item_clear()
  w_btn_upgrade.enable = false
  w_list_bg.visible = false
  w_btn_trait_lock_max.check = false
  w_btn_trait_lock_min.check = false
  w_prob_desc.visible = false
  w_mat_quick_buy1.visible = false
  attrs = {}
end
local get_equip_upgrade_line = function(item_id)
  local upgrade_line
  for i = 0, bo2.gv_second_upgrade.size - 1 do
    local line = bo2.gv_second_upgrade:get(i)
    if line.src_id == item_id then
      upgrade_line = line
      break
    end
  end
  return upgrade_line
end
function do_product_update()
  if not sys.check(w_btn_upgrade) then
    return
  end
  w_btn_upgrade.enable = false
  local info_equip = g_post_info
  if info_equip == nil then
    clear_all()
    return
  end
  local upgrade_line = get_equip_upgrade_line(info_equip.excel_id)
  for i = 0, c_count do
    if upgrade_line.reg_id[i] then
      local reg_id = upgrade_line.reg_id[i]
      local c = ui.item_get_count(reg_id, true)
      if c < upgrade_line.reg_num[i] then
        return
      end
    end
  end
  w_btn_upgrade.enable = true
end
function on_item_count(card, excel_id, bag, all)
  w_main:insert_post_invoke(do_product_update, "ui_npcfunc.ui_second_upgrade.do_product_update")
end
function on_tip_show_product(tip)
  local card_base = w_cell_equip:search(L("card"))
  if sys.check(card_base) ~= true then
    return false
  end
  local info_base = card_base.info
  if sys.check(info_base) ~= true then
    return false
  end
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  local base_star = info_base:get_data_8(bo2.eItemByte_Star)
  local copy_babe = {}
  copy_babe[bo2.eItemByte_EnforceMaxCount] = 1
  copy_babe[bo2.eItemByte_EnforcePre] = 1
  copy_babe[bo2.eItemByte_EnforceLastAcount] = 1
  copy_babe[bo2.eItemByte_EnforceAcount] = 1
  copy_babe[bo2.eItemByte_EnforceLvl] = 1
  copy_babe[bo2.eItemByte_EnforceCounted] = 1
  copy_babe[bo2.eItemByte_EnforceID] = 1
  copy_babe[bo2.eItemByte_RecognizedCounted] = 1
  copy_babe[bo2.eItemByte_RecognizedMaxCount] = 1
  local copy_flag32 = {}
  for i = bo2.eItemUInt32_EnchantBeg, bo2.eItemUInt32_EnchantEnd - 1 do
    copy_flag32[bo2.eItemUInt32_EnchantBeg] = 1
  end
  copy_flag32[bo2.eItemUInt32_CurWearout] = 1
  copy_flag32[bo2.eItemUInt32_MaxWearout] = 1
  local copy_val32 = {}
  local list_size = w_pro_list.item_count
  local lock_count = 0
  for i = 0, list_size - 1 do
    local item = w_pro_list:item_get(i)
    if sys.check(item) and sys.check(item.svar.trait_id) then
      local btn = item:search(L("lock_check"))
      if sys.check(btn) and btn.check == true then
        copy_val32[bo2.eItemUInt32_IdentTraitBeg + lock_count] = item.svar.trait_id
        lock_count = lock_count + 1
      end
    end
  end
  local info = {
    name = excel.name,
    plootlevel_star = info_base.plootlevel_star,
    get_data_8 = function(info, val)
      if val == bo2.eItemByte_Star then
        return base_star
      end
      return 0
    end,
    star = base_star,
    get_data_s = function()
      return L("")
    end,
    box = bo2.eItemBox_BagBeg,
    get_data_32 = function(info, val)
      if val == bo2.eItemUInt32_CurWearout or val == bo2.eItemUInt32_MaxWearout then
        local v = 0
        v = info_base:get_data_32(val)
        return v
      end
      if copy_val32[val] ~= nil then
        local v = 0
        v = copy_val32[val]
        return v
      end
      if copy_flag32[val] ~= nil then
        local v = 0
        v = info_base:get_data_32(val)
        return v
      end
      return 0
    end,
    get_identify_state = function()
      return bo2.eIdentifyEquip_Countine
    end,
    get_xdata_32 = function(info, val)
      if val == bo2.eItemXData32_GrowPointMax then
        local v = 0
        v = info_base:get_xdata_32(val)
        return v
      end
      return 0
    end,
    get_identify_state = function()
      return bo2.eIdentifyEquip_Countine
    end
  }
  ui_tool.ctip_make_item(stk, excel, info, card)
  local stk_use
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function get_current_lock_excel(lock_count)
  local card = w_cell_equip:search(L("card"))
  if sys.check(card) ~= true then
    return nil
  end
  local info = card.info
  if info == nil then
    return nil
  end
  local upgrade_line = get_equip_upgrade_line(info.excel_id)
  if upgrade_line == nil then
    return nil
  end
  local c_lock = upgrade_line.v_trait_lock_idx.size
  for i = 0, c_lock - 1 do
    local function trait_lock_data(idx)
      local trait_lock_excel = bo2.gv_equip_upgrade_trait_lock:find(idx)
      if trait_lock_excel == nil or trait_lock_excel.lock_count ~= lock_count then
        return nil
      end
      return trait_lock_excel
    end
    local excel = trait_lock_data(upgrade_line.v_trait_lock_idx[i])
    if excel ~= nil then
      return excel
    end
  end
  return nil
end
function get_min_lock_item(lock_count)
  local excel = get_current_lock_excel(lock_count)
  if excel == nil then
    return 0
  else
    return excel.reg_num
  end
end
function on_check_min(btn)
  do_product_update()
end
function on_check_max(btn)
  do_product_update()
end
function get_lock_prob_count(lock_count, equip_prob)
  local req_count = get_mat_max()
  if equip_prob == 0 then
    return req_count
  end
  local excel = get_current_lock_excel(lock_count)
  local min_lock_count = get_min_lock_item(lock_count)
  if min_lock_count <= 0 then
    return 0
  end
  local pre_prob = 1000000 + excel.prob_decrease
  local single_prob = excel.prob
  if single_prob == 0 then
    return req_count
  end
  local total = excel.prob_base + equip_prob
  if pre_prob <= total then
    return min_lock_count
  end
  local mat_prob = pre_prob - total
  local mat_count = mat_prob / single_prob
  local floor_mat = math.floor(mat_count)
  local prob_need_count = 0
  if mat_count > floor_mat then
    prob_need_count = floor_mat + 1
  else
    prob_need_count = floor_mat
  end
  if min_lock_count > prob_need_count then
    prob_need_count = min_lock_count
  elseif req_count < prob_need_count then
    prob_need_count = req_count
  end
  return prob_need_count
end
function fill_prob_mtf(trait_lock_excel, count, lock_count, _equip_prob)
  local pre_count = 10000
  local prob = {}
  local add_prob0 = trait_lock_excel.prob / pre_count
  local prob_decrease = trait_lock_excel.prob_decrease / pre_count
  local equip_faild_prob = trait_lock_excel.prob_faild_add / pre_count * count
  local equip_prob = _equip_prob / pre_count
  local add_total_prob = add_prob0 * count
  local prob0 = trait_lock_excel.prob_base / pre_count
  local total = add_total_prob + equip_prob + prob0 - prob_decrease
  prob.prob0 = sys.format(L("%.2f"), prob0)
  prob.decease0 = total
  prob.count = count
  prob.min_count = trait_lock_excel.reg_num
  prob.add_prob = sys.format(L("%.2f"), add_prob0)
  prob.equip_add = sys.format(L("%.2f"), equip_faild_prob)
  prob.trait_count = sys.format(L("%d"), lock_count)
  prob.base_prob = sys.format(L("%.2f"), equip_prob)
  prob.add_total_prob = sys.format(L("%.2f"), add_total_prob)
  prob.persent = sys.format(L("%.2f"), total)
  prob.lock_count = lock_count
  prob.prob_decrease = sys.format(L("%.2f"), prob_decrease)
  return prob
end
function on_lock_btn_tip(tip)
  local stk = sys.mtf_stack()
  local item = tip.owner
  local attr = attrs[item.svar.attr_pos]
  ui_tool.ctip_push_text(stk, ui.get_text("equip|tip_main_equip_trait"), ui_tool.cs_tip_color_green, ui_tool.cs_tip_a_add_m)
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui_tool.ctip_trait_text_ex(attr.modify_id, attr.modify_value), attr.color, ui_tool.cs_tip_a_add_m)
  stk:raw_push(L("\n"))
  ui_tool.ctip_push_text(stk, ui.get_text("tool|property_rank"))
  ui_tool.ctip_push_text(stk, attr.score, ui_tool.cs_tip_color_bound, ui_tool.cs_tip_a_add_r)
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("equip|tip_locked_trait"), ui_tool.cs_tip_color_green, ui_tool.cs_tip_a_add_m)
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui_tool.ctip_trait_text_ex(attr.modify_id, attr.modify_value_next), attr.color_next, ui_tool.cs_tip_a_add_m)
  stk:raw_push(L("\n"))
  ui_tool.ctip_push_text(stk, ui.get_text("tool|property_rank"))
  ui_tool.ctip_push_text(stk, attr.score_next, ui_tool.cs_tip_color_bound, ui_tool.cs_tip_a_add_r)
  local btn = item:search(L("lock_check"))
  if btn.check == true then
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("equip|tip_locked"), ui_tool.cs_tip_color_operation)
  else
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("equip|tip_click_lock"), ui_tool.cs_tip_color_operation)
  end
  ui_tool.ctip_show(tip.owner, stk)
end
function on_btn_lock_pro(btn)
  local btn_check = btn.check
  local up_name = btn.parent.parent.parent
  local select = up_name:search(L("select"))
  select.visible = btn_check
end
local get_gs_score = function(id, value)
  local excel = {}
  excel[id] = value
  local gs = ui_tool.ctip_calculate_item_rank(excel, nil, 2)
  return gs
end
function refresh_all()
  do_product_update()
  local info = g_post_info
  local upgrade_line = get_equip_upgrade_line(info.excel_id)
  if upgrade_line == nil then
    return
  end
  local pdt_cell = w_detail:search("product")
  ui_cell.set(pdt_cell, upgrade_line.pdt_id)
  local lb = pdt_cell:search("lb_item")
  if sys.check(lb) and info.plootlevel_star then
    lb.color = ui.make_color(info.plootlevel_star.color)
  end
  ui_cell.batch_clear(w_detail, {
    "mat_reg_0",
    "mat_reg_1",
    "mat_reg_2",
    "mat_reg_3"
  })
  w_mat_quick_buy1.visible = false
  for i = 0, c_count do
    if upgrade_line.reg_id[i] then
      local mat_reg_cell = w_detail:search("mat_reg_" .. i)
      ui_cell.set(mat_reg_cell, upgrade_line.reg_id[i], upgrade_line.reg_num[i])
      local goods_id = ui_supermarket2.shelf_quick_buy_id(upgrade_line.reg_id[i])
      if goods_id > 0 then
        w_mat_quick_buy1.name = tostring(goods_id)
        w_mat_quick_buy1.visible = true
      end
    end
  end
  if w_req_money:search("lb_money") ~= nil then
    w_req_money:search("lb_money").bounded = upgrade_line.money_t == 1
  end
  ui_cmn.money_set(w_req_money, upgrade_line.money_n)
  w_pro_list:item_clear()
  local excel = info.excel
  local star = info:get_data_8(bo2.eItemByte_Star)
  local pdt_excel = bo2.gv_equip_item:find(upgrade_line.pdt_id)
  attrs = {}
  for i = 0, 5 do
    for j = 0, 3 do
      local id = bo2.get_sw_rand(info:get_data_32(bo2.eItemUint32_SecondRProBeg + i), j)
      if id ~= 0 then
        local str_excel = bo2.gv_sw_rand_pool:find(id)
        if str_excel ~= nil then
          local tr_excel = bo2.gv_trait_list:find(str_excel.trait_id)
          table.insert(attrs, {
            modify_id = tr_excel.modify_id,
            modify_value = tr_excel.modify_value,
            modify_value_next = tr_excel.modify_value,
            color = bo2.gv_lootlevel:find(str_excel.color).color,
            color_next = bo2.gv_lootlevel:find(str_excel.color).color,
            score = get_gs_score(tr_excel.modify_id, tr_excel.modify_value),
            score_next = get_gs_score(tr_excel.modify_id, tr_excel.modify_value)
          })
        end
      end
    end
  end
  local upgradeExcel = bo2.gv_assistant_upgrade:find(pdt_excel.ass_upgrade[0])
  local concise = info:get_data_32(eItemUint32_SecondConcise)
  local idx_all = upgradeExcel.r_prop_pool
  if concise == 1 then
    idx_all = upgradeExcel.concise_pool1_id
  elseif concise == 2 then
    idx_all = upgradeExcel.concise_pool2_id
  elseif concise == 3 then
    idx_all = upgradeExcel.concise_pool3_id
  end
  for p, v in pairs(attrs) do
    if idx_all.size == 0 then
      local sw_size = bo2.gv_sw_rand_pool:size()
      for i = 0, sw_size - 1 do
        local sw_tr = bo2.gv_sw_rand_pool:get(i)
        local tr = bo2.gv_trait_list:find(sw_tr.trait_id)
        if tr.modify_id == v.modify_id and tr.modify_value > v.modify_value and (tr.modify_value < v.modify_value_next or v.modify_value_next == v.modify_value) then
          v.modify_value_next = tr.modify_value
          v.color_next = bo2.gv_lootlevel:find(sw_tr.color).color
          v.score_next = get_gs_score(v.modify_id, v.modify_value_next)
        end
      end
    else
      local idx = p - 1
      if idx > idx_all.size - 1 then
        idx = idx_all.size - 1
      end
      local packet = bo2.gv_trait_packet:find(idx_all[idx])
      local sw_size = packet.traits.size
      for i = 0, sw_size - 1 do
        local sw_tr = bo2.gv_sw_rand_pool:find(packet.traits[i])
        local tr = bo2.gv_trait_list:find(sw_tr.trait_id)
        if tr.modify_id == v.modify_id and tr.modify_value >= v.modify_value_next and (tr.modify_value < v.modify_value_next or v.modify_value_next == v.modify_value) then
          v.modify_value_next = tr.modify_value
          v.color_next = bo2.gv_lootlevel:find(sw_tr.color).color
          v.score_next = get_gs_score(v.modify_id, v.modify_value_next)
        end
      end
    end
  end
  local item_style = "trait_item"
  local item_file = "$frame/npcfunc/second_upgrade.xml"
  for pos, v in pairs(attrs) do
    local item = w_pro_list:item_append()
    item:load_style(item_file, item_style)
    local property_name = item:search("property_text")
    property_name.text = ui_tool.ctip_trait_text_ex(v.modify_id, v.modify_value)
    property_name.color = ui.make_color(v.color)
    local post_trait = item:search("post_trait")
    post_trait.text = ui_tool.ctip_trait_text_ex(v.modify_id, v.modify_value_next)
    post_trait.color = ui.make_color(v.color_next)
    local lock_check = item:search("lock_check")
    local select = item:search("select")
    lock_check.check = upgrade_line.src_lock_trait == 1
    lock_check.mouse_able = upgrade_line.src_lock_trait ~= 1
    item.svar.attr_pos = pos
  end
  w_list_bg.visible = true
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
function on_quick_buy(btn)
  ui_supermarket2.shelf_singleBuy(btn)
end
function get_use_mat_max(name)
  local mat_reg_cell = w_detail:search(name)
  if sys.check(mat_reg_cell) ~= true then
    return
  end
  local card_pure = mat_reg_cell:search("card")
  return card_pure.count
end
function set_use_mat_count(name, count)
  local mat_reg_cell = w_detail:search(name)
  if sys.check(mat_reg_cell) ~= true then
    return
  end
  local card_pure = mat_reg_cell:search("card_pure")
  card_pure.count = count
end
function try_put_src(info)
  local excel = info.excel
  if excel == nil then
    return nil
  end
  if info.box < bo2.eItemBox_BagBeg or info.box >= bo2.eItemBox_BagEnd then
    ui_tool.note_insert(ui.get_text("npcfunc|only_item_from_bag"), "FF0000")
    return
  end
  if info:identify_finished() == false then
    ui_tool.note_insert(ui.get_text("npcfunc|eu_identify_first"), "FF0000")
    return
  end
  for idx = 0, info:get_data_8(bo2.eItemByte_Holes) - 1 do
    if info:get_data_32(bo2.eItemUInt32_GemBeg + idx) ~= 0 then
      ui_tool.note_insert(ui.get_text("npcfunc|eu_gem_tip"), "FF0000")
      return
    end
  end
  local upgrade_line = get_equip_upgrade_line(excel.id)
  if upgrade_line == nil then
    ui_tool.note_insert(ui.get_text("npcfunc|eu_invalid_tgt_equip"), "FF0000")
    return
  end
  local pdt_excel_id = upgrade_line.pdt_id
  local pdt_excel = bo2.gv_equip_item:find(pdt_excel_id)
  if sys.check(pdt_excel) ~= true or pdt_excel.reqlevel >= lock_level then
    local txt = bo2.gv_text:find(78160)
    if sys.check(txt) then
      ui_tool.note_insert(txt.text, "FF0000")
    end
    return
  end
  if info:get_data_32(bo2.eItemUInt32_SecondLevel) < upgrade_line.src_grow then
    ui_tool.note_insert(ui_widget.merge_mtf({
      level = upgrade_line.src_grow
    }, ui.get_text("npcfunc|seu_level")), "FF0000")
    return
  end
  ui_cell.drop(w_cell_equip, info)
  g_post_info = info
  refresh_all()
end
function on_equip_change(card)
  local info = card.info
  if info == nil and g_post_info ~= nil then
    g_post_info = nil
    clear_all()
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
  try_put_src(info)
end
function on_equip_drop(pn, msg, pos, data)
  if ui_cell.check_drop(pn, msg, pos, data) == false then
    return
  end
  local info = ui.item_of_only_id(data:get("only_id"))
  if info == nil then
    return nil
  end
  try_put_src(info)
end
function on_equip_card_mouse(ctrl, msg)
  if msg ~= ui.mouse_rbutton_down then
    return
  end
  g_post_info = nil
  clear_all()
end
function on_upgrade_click()
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  local pdt_bd = info:get_data_8(bo2.eItemByte_Bound)
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_SecondWeaponUpgrade)
  v:set64(packet.key.item_key, info.only_id)
  local confirm = false
  local stk = sys.mtf_stack()
  local prob = {}
  if pdt_bd == 1 then
    stk:raw_push(ui.get_text("npcfunc|eu_bound_tip"))
    stk:raw_push(L("\n"))
  end
  local has_lock = false
  for i = 1, 20 do
    v:set(packet.key.lock_index_start2 + i - 1, false)
    if i <= w_pro_list.item_count then
      local item = w_pro_list:item_get(i - 1)
      if sys.check(item) then
        local btn = item:search(L("lock_check"))
        if btn.check then
          has_lock = true
        end
      end
    end
  end
  if has_lock then
    ui_tool.ctip_push_text(stk, ui.get_text("equip|lock_notify_se"), ui_tool.cs_tip_color_white, ui_tool.cs_tip_a_add_l)
    stk:raw_push(L("\n"))
    local list_size = w_pro_list.item_count
    for i = 0, list_size - 1 do
      local item = w_pro_list:item_get(i)
      if sys.check(item) then
        local btn = item:search(L("lock_check"))
        if sys.check(btn) then
          if btn.check then
            local attr = attrs[i + 1]
            stk:raw_push(L("<space:2.0>"))
            ui_tool.ctip_push_text(stk, ui_tool.ctip_trait_text_ex(attr.modify_id, attr.modify_value_next), attr.color_next, ui_tool.cs_tip_a_add_l)
            stk:raw_push(L("\n"))
          end
          v:set(packet.key.lock_index_start2 + i, btn.check)
        end
      end
    end
    stk:raw_push(L("<sep>\n"))
    stk:raw_push(L("<space:2.0>"))
  end
  ui_tool.ctip_push_text(stk, ui.get_text("equip|confirm_se"), ui_tool.cs_tip_color_white, ui_tool.cs_tip_a_add_m)
  local text_show = stk.text
  local function on_msg_callback(msg_call)
    if msg_call.result ~= 1 then
      return
    end
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  end
  local msg = {callback = on_msg_callback, text = text_show}
  ui_widget.ui_msg_box.show_common(msg)
end
function on_visible(w, vis)
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
  clear_all()
  g_post_info = nil
  if vis then
    ui.item_mark_show("equip_upgrade", true)
  else
    ui.item_mark_show("equip_upgrade", false)
  end
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  w_pro_list:item_clear()
end
