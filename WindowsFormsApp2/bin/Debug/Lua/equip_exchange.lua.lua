local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
local c_count = 3
local c_lock_idx = 4
local g_buy_info
local lock_level = bo2.gv_define:find(50022).value.v_int
local clear_req_item = function(name)
  local mat_reg_cell = w_detail:search(name)
  local card = mat_reg_cell:search("card_pure")
  card.visible = false
end
local function clear_all()
  ui_cell.batch_clear(w_detail, {
    "mat_equip",
    "mat_reg_4",
    "mat_lock_trait_0"
  })
  local pdt_cell = w_detail:search("product")
  local lb = pdt_cell:search("lb_item")
  if sys.check(lb) then
    lb.color = ui.make_color(L("FFFFFF"))
  end
  clear_req_item(L("mat_reg_4"))
  clear_req_item(L("mat_lock_trait_0"))
  ui_cmn.money_set(w_req_money, 0)
  w_pro_list:item_clear()
  w_btn_upgrade.enable = false
  btn_lock_item.check = false
  w_list_bg.visible = false
  w_btn_trait_lock_max.check = false
  w_btn_trait_lock_min.check = false
  on_init_trait_text()
end
function get_equip_upgrade_line_by_star(info, excel)
  local size = excel.v_reg_star.size
  if size <= 0 then
    return excel
  end
  local star = info:get_data_8(bo2.eItemByte_Star)
  for i = 0, size - 1 do
    local param_excel = bo2.gv_equip_upgrade_param:find(excel.v_reg_star[i])
    if sys.check(param_excel) and param_excel.star == star then
      return param_excel
    end
  end
  return excel
end
function is_source_equip(excel, id)
  if sys.check(excel) ~= true then
    return false
  end
  local size = excel.src_id.size
  for i = 0, size - 1 do
    if excel.src_id[i] == id then
      return true
    end
  end
  return false
end
local function get_equip_upgrade_line()
  if sys.check(g_buy_info) ~= true then
    return nil
  end
  local excel = g_buy_info.excel
  local lock_excel = bo2.gv_goods_upgrade:find(excel.id)
  return lock_excel
end
function is_need_lock(excel, goods)
  local lock_excel = bo2.gv_goods_upgrade:find(excel.id)
  if lock_excel ~= nil then
    local req_obj = goods.expend_obj
    for i = 0, req_obj.size - 1 do
      if req_obj[i] ~= 0 and req_obj[i] < bo2.eQuestObj_ItemEnd then
        return true
      end
    end
    return false
  end
  return false
end
local is_valid_ass_equip = function(tgt_info, ass_info)
  local ass_item_id = ass_info.excel_id
  local ass_line
  for i = 0, bo2.gv_equip_upgrade_ass.size - 1 do
    local line = bo2.gv_equip_upgrade_ass:get(i)
    if line.item_id == ass_item_id then
      ass_line = line
      break
    end
  end
  if ass_line == nil then
    return false
  end
  if tgt_info:get_data_8(bo2.eItemByte_Star) ~= ass_info:get_data_8(bo2.eItemByte_Star) or tgt_info.excel.reqlevel ~= ass_info.excel.reqlevel then
    return false
  end
  return true
end
function do_product_update()
  if not sys.check(w_btn_upgrade) then
    return
  end
  w_btn_upgrade.enable = false
  local card_equip = w_cell_equip:search("card")
  local info_equip = card_equip.info
  if info_equip == nil then
    return
  end
  local lock_count = get_trait_lock_count()
  if lock_count > 0 then
    local min_lock_count = get_min_lock_item(lock_count)
    if min_lock_count <= 0 then
      return
    end
    local c = get_mat_current_count()
    local c_has = get_mat_has()
    if min_lock_count > c or c > c_has then
      if c > c_has then
        w_btn_trait_lock_max.check = false
        w_btn_trait_lock_min.check = false
      end
      return
    end
  end
  w_btn_upgrade.enable = true
end
function post_product_update()
  w_main:insert_post_invoke(do_product_update, "ui_npcfunc.ui_equip_exchange.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  post_product_update()
  local c = ui_cell.top_of(card)
  local c_name = c.name
  local btn_quick_buy, w_mat_minus, w_mat_plus
  if c_name == L("mat_reg_4") then
    btn_quick_buy = w_mat_quick_buy2
  elseif c_name == L("mat_reg_1") then
    btn_quick_buy = w_mat_quick_buy1
  elseif c_name == L("mat_lock_trait_0") then
    btn_quick_buy = w_mat_quick_buy3
    w_mat_minus = c:search(L("btn_minus"))
    w_mat_plus = c:search(L("btn_plus"))
    local function set_btn_visible(vis)
      local function check_set(w)
        if sys.check(w) then
          w.visible = vis
        end
      end
      check_set(w_mat_minus)
      check_set(w_mat_plus)
      check_set(w_btn_trait_lock_max)
      check_set(w_btn_trait_lock_min)
    end
    if excel_id == 0 then
      set_btn_visible(false)
    else
      set_btn_visible(true)
    end
  else
    return
  end
  btn_quick_buy.visible = false
  local goods_id = ui_supermarket2.shelf_quick_buy_id(excel_id)
  if goods_id == 0 then
    return
  end
  btn_quick_buy.name = tostring(goods_id)
  btn_quick_buy.visible = true
end
function on_tip_show_product(tip)
  local info_base = {
    get_data_8 = function(info, val)
      return 0
    end,
    plootlevel_star = nil,
    get_data_32 = function()
      return 0
    end
  }
  local function set_info_base()
    local card_base = w_cell_equip:search(L("card"))
    if sys.check(card_base) ~= true then
      return false
    end
    if sys.check(card_base.info) ~= true then
      return false
    end
    info_base = card_base.info
    return true
  end
  set_info_base()
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  local base_star = info_base:get_data_8(bo2.eItemByte_Star)
  local btn_check = btn_lock_item.check
  local copy_babe = {}
  copy_babe[bo2.eItemByte_EnforceMaxCount] = 1
  copy_babe[bo2.eItemByte_EnforcePre] = 1
  copy_babe[bo2.eItemByte_EnforceLastAcount] = 1
  copy_babe[bo2.eItemByte_EnforceAcount] = 1
  copy_babe[bo2.eItemByte_EnforceLvl] = 1
  copy_babe[bo2.eItemByte_EnforceCounted] = 1
  copy_babe[bo2.eItemByte_EnforceID] = 1
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
      if btn_check == true and copy_babe[val] ~= nil then
        local val = info_base:get_data_8(val)
        return val
      end
      return 0
    end,
    star = base_star,
    get_data_s = function()
      return L("")
    end,
    box = bo2.eItemBox_BagBeg,
    get_data_32 = function(info, val)
      if copy_flag32[val] ~= nil then
        local val = info_base:get_data_32(val)
        return val
      end
      if copy_val32[val] ~= nil then
        return copy_val32[val]
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
function get_trait_lock_count()
  local list_size = w_pro_list.item_count
  local lock_count = 0
  for i = 0, list_size - 1 do
    local item = w_pro_list:item_get(i)
    if sys.check(item) then
      local btn = item:search(L("lock_check"))
      if sys.check(btn) and btn.check == true then
        lock_count = lock_count + 1
      end
    end
  end
  return lock_count
end
function get_lock_mat_id()
  local mat_reg_cell = w_detail:search(L("mat_lock_trait_0"))
  local card = mat_reg_cell:search("card")
  return card.excel.id
end
function get_mat_max()
  local mat_reg_cell = w_detail:search(L("mat_lock_trait_0"))
  local card = mat_reg_cell:search("card_pure")
  return card.require_count
end
function get_mat_current_count()
  local mat_reg_cell = w_detail:search(L("mat_lock_trait_0"))
  local card = mat_reg_cell:search("card_pure")
  return card.count
end
function get_mat_has()
  local mat_reg_cell = w_detail:search(L("mat_lock_trait_0"))
  local card_count = mat_reg_cell:search("card")
  return card_count.count
end
function on_click_mat_minus()
  local c = get_mat_current_count()
  if c >= 1 then
    if w_btn_trait_lock_max.check == true then
      w_btn_trait_lock_max.check = false
    end
    if w_btn_trait_lock_min.check == true then
      w_btn_trait_lock_min.check = false
    end
    set_use_mat_count(L("mat_lock_trait_0"), c - 1)
    refresh_trait_lock_mat(false)
    do_product_update()
  end
end
function on_click_mat_plus()
  local c = get_mat_current_count()
  local c_has = get_mat_has()
  local c_has_check = c_has
  if c_has_check <= 0 then
    notify_lack_of_lock_item()
  end
  local card = w_cell_equip:search(L("card"))
  if sys.check(card) ~= true then
    return false
  end
  local info = card.info
  if info == nil then
    return false
  end
  local lock_count = get_trait_lock_count()
  if lock_count <= 0 then
    return false
  end
  local eq = info:get_data_32(bo2.eItemUInt32_UpgradeTraitLockProb)
  local c_max = get_lock_prob_count(lock_count, eq)
  if c_has > c_max then
    c_has = c_max
  end
  if c_has < c + 1 then
    return
  end
  if (c + 1 == c_max or c + 1 == c_has_check) and c_has_check >= c_max then
    w_btn_trait_lock_max.check = true
  else
    set_use_mat_count(L("mat_lock_trait_0"), c + 1)
    refresh_trait_lock_mat(false)
  end
  do_product_update()
end
function on_click_min_trait_lock()
  local lock_count = get_trait_lock_count()
  if lock_count <= 0 then
    return false
  end
  local min_lock_count = get_min_lock_item(lock_count)
  if min_lock_count <= 0 then
    return false
  end
  local mat_reg_cell = w_detail:search(L("mat_lock_trait_0"))
  local card_count = mat_reg_cell:search("card")
  local c = card_count.count
  if c <= 0 then
    return false
  end
  local card = mat_reg_cell:search("card_pure")
  if min_lock_count <= c then
    c = min_lock_count
  end
  card.count = c
  refresh_trait_lock_mat(false)
  return true
end
function on_check_min(btn)
  if btn.check == true then
    w_btn_trait_lock_max.check = false
    if on_click_min_trait_lock() ~= true then
      btn.check = false
      notify_lack_of_lock_item()
    else
      btn.check = true
    end
  else
    set_use_mat_count(L("mat_lock_trait_0"), 0)
    refresh_trait_lock_mat(false)
  end
  do_product_update()
end
function notify_lack_of_lock_item()
  local txt = ui.get_text("equip|error_lack_lock_item")
  ui_tool.note_insert(txt, "FF0000")
end
function on_check_max(btn)
  if btn.check == true then
    w_btn_trait_lock_min.check = false
    if on_click_max_trait_lock() ~= true then
      btn.check = false
      notify_lack_of_lock_item()
    else
      btn.check = true
    end
  else
    set_use_mat_count(L("mat_lock_trait_0"), 0)
    refresh_trait_lock_mat(false)
  end
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
function on_click_max_trait_lock()
  local card = w_cell_equip:search(L("card"))
  if sys.check(card) ~= true then
    return false
  end
  local info = card.info
  if info == nil then
    return false
  end
  local upgrade_line = get_equip_upgrade_line(info.excel_id)
  if upgrade_line == nil then
    return false
  end
  local lock_count = get_trait_lock_count()
  if lock_count <= 0 then
    return false
  end
  local mat_reg_cell = w_detail:search(L("mat_lock_trait_0"))
  local card_count = mat_reg_cell:search("card")
  local c = card_count.count
  if c <= 0 then
    return false
  end
  local eq = info:get_data_32(bo2.eItemUInt32_UpgradeTraitLockProb)
  local min_prob = get_lock_prob_count(lock_count, eq)
  if min_prob <= 0 then
    return false
  end
  if c >= min_prob then
    c = min_prob
  end
  set_use_mat_count(L("mat_lock_trait_0"), c)
  refresh_trait_lock_mat(false)
  return true
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
function on_btn_lock_pro(btn)
  local btn_check = btn.check
  local up_name = btn.parent.parent.parent
  local select = up_name:search(L("select"))
  select.visible = btn_check
  local upgrade_line = get_equip_upgrade_line()
  if upgrade_line == nil then
    return
  end
  local lock_count = get_trait_lock_count()
  if upgrade_line.lock_trait_max > 0 and lock_count > upgrade_line.lock_trait_max then
    btn.check = false
    select.visible = false
    local mtf = {}
    mtf.count = upgrade_line.lock_trait_max
    local txt = ui_widget.merge_mtf(mtf, ui.get_text("equip_exchange|max_lock"))
    ui_tool.note_insert(txt, "00FF00")
    return false
  end
  refresh_trait_lock_mat(true)
end
function refresh_trait_lock_mat(refresh)
  local card = w_cell_equip:search(L("card"))
  if sys.check(card) ~= true then
    return false
  end
  local info = card.info
  if info == nil then
    return
  end
  local upgrade_line = get_equip_upgrade_line()
  if upgrade_line == nil then
    return
  end
  local lock_count = get_trait_lock_count()
  local function clear_trait_lock_all()
    on_init_trait_text()
    if refresh == true then
      ui_cell.batch_clear(w_detail, {
        "mat_lock_trait_0"
      })
      clear_req_item(L("mat_lock_trait_0"))
      w_btn_trait_lock_max.check = false
      w_btn_trait_lock_min.check = false
    end
  end
  local function trait_lock_data(idx)
    local trait_lock_excel = bo2.gv_equip_upgrade_trait_lock:find(idx)
    if trait_lock_excel == nil or trait_lock_excel.lock_count ~= lock_count then
      return false
    end
    local mat_reg_cell = w_detail:search(L("mat_lock_trait_0"))
    local card = mat_reg_cell:search("card_pure")
    local function update_req_item(id, max)
      ui_cell.set(mat_reg_cell, id, max)
      card.excel_id = id
      card.require_count = max
      card.count = 0
      card.visible = true
    end
    if refresh ~= false then
      update_req_item(trait_lock_excel.reg_id, trait_lock_excel.reg_max)
    end
    local eq = info:get_data_32(bo2.eItemUInt32_UpgradeTraitLockProb)
    local prob = fill_prob_mtf(trait_lock_excel, card.count, lock_count, eq)
    modify_trait_lock_text(prob)
    return true
  end
  clear_trait_lock_all()
  if lock_count == 0 then
    return
  end
  local c_lock = upgrade_line.v_trait_lock_idx.size
  for i = 0, c_lock - 1 do
    local trait_lock_idx = upgrade_line.v_trait_lock_idx[i]
    if trait_lock_data(trait_lock_idx) == true then
      return true
    end
  end
end
function on_lock_btn_tip(tip)
  local stk = sys.mtf_stack()
  local function push_new_line()
    stk:raw_push(L("\n"))
  end
  local item = tip.owner
  local svar = item.svar
  ui_tool.ctip_push_text(stk, ui.get_text("equip|tip_main_equip_trait"), ui_tool.cs_tip_color_green, ui_tool.cs_tip_a_add_m)
  ui_tool.ctip_push_sep(stk)
  stk:raw_push(svar.base_trait_desc)
  push_new_line()
  ui_tool.ctip_push_text(stk, ui.get_text("tool|property_rank"))
  ui_tool.ctip_push_text(stk, svar.base_score, ui_tool.cs_tip_color_bound, ui_tool.cs_tip_a_add_r)
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("equip|tip_locked_trait"), ui_tool.cs_tip_color_green, ui_tool.cs_tip_a_add_m)
  ui_tool.ctip_push_sep(stk)
  stk:raw_push(svar.trait_desc)
  push_new_line()
  ui_tool.ctip_push_text(stk, ui.get_text("tool|property_rank"))
  ui_tool.ctip_push_text(stk, svar.upgrade_score, ui_tool.cs_tip_color_bound, ui_tool.cs_tip_a_add_r)
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
function get_lock_excel(info, upgrade_line)
  if info == nil or upgrade_line == nil then
    return nil
  end
  local size_lock = upgrade_line.v_lock_idx.size
  if size_lock <= 0 then
    return nil
  end
  local maxCount = info:get_data_8(bo2.eItemByte_EnforceMaxCount)
  local function process_lock(excel)
    if excel == nil then
      return false
    end
    if excel.enforce_max >= maxCount then
      return true
    end
    return false
  end
  for i = 0, size_lock - 1 do
    local lock_excel_id = upgrade_line.v_lock_idx[i]
    local lock_excel = bo2.gv_equip_upgrade_lock:find(lock_excel_id)
    if process_lock(lock_excel) == true then
      return lock_excel
    end
  end
  return nil
end
function modify_trait_lock_text(prob)
  local stk = sys.mtf_stack()
  local txt = ui_widget.merge_mtf(prob, ui.get_text("equip|trait_lock_item"))
  stk:raw_push(L("<a:right>"))
  stk:raw_push(txt)
  stk:raw_push("\n")
  local function show_calc()
    stk:raw_push(ui_widget.merge_mtf(prob, ui.get_text("equip|trait_lock_prob_calc")))
    stk:raw_push("\n")
    stk:raw_push(ui_widget.merge_mtf(prob, ui.get_text("equip|trait_lock_faild")))
    stk:raw_push("\n")
    stk:raw_push(ui_widget.merge_mtf(prob, ui.get_text("equip|trait_lock_prob")))
  end
  if prob.decease0 > 0 then
    show_calc()
  else
    local min_lock_count = get_min_lock_item(prob.lock_count)
    local c = get_mat_current_count()
    if min_lock_count > 0 and min_lock_count <= c then
      show_calc()
    end
  end
  w_prob_desc.mtf = stk.text
  w_prob_desc.visible = true
end
function on_init_trait_text()
  local stk = sys.mtf_stack()
  stk:raw_push(L("<a:right>"))
  stk:raw_push(ui.get_text("equip|init_triat_lock"))
  w_prob_desc.mtf = stk.text
  w_prob_desc.visible = true
end
local g_post_info
function on_equip_change(card)
  local info = card.info
  if info == nil then
    g_post_info = nil
    return
  end
  if g_post_info ~= nil and info == g_post_info then
    refresh_trait_lock_mat(false)
    do_product_update()
    return
  end
  g_post_info = info
  local upgrade_line = get_equip_upgrade_line()
  if upgrade_line == nil then
    return
  end
  local pdt_cell = w_detail:search("product")
  local lb = pdt_cell:search("lb_item")
  if sys.check(lb) and info.plootlevel_star then
    lb.color = ui.make_color(info.plootlevel_star.color)
  end
  ui_cell.batch_clear(w_detail, {"mat_reg_4"})
  ui_cell.batch_clear(w_detail, {
    "mat_lock_trait_0"
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
  local lock_excel = get_lock_excel(info, upgrade_line)
  if lock_excel ~= nil then
    update_req_item(L("mat_reg_4"), lock_excel.reg_id, lock_excel.reg_num)
  else
    clear_req_item(L("mat_reg_4"))
  end
  clear_req_item(L("mat_lock_trait_0"))
  w_pro_list:item_clear()
  local excel = info.excel
  local star = info:get_data_8(bo2.eItemByte_Star)
  local build_packet = ui_tool.get_trait_color_packet(excel, star)
  local pdt_excel = bo2.gv_equip_item:find(upgrade_line.id)
  local pdt_packet = {}
  if pdt_excel ~= nil then
    pdt_packet = ui_tool.get_trait_color_packet(pdt_excel, star)
  end
  local add_single_trait = function(t_trait)
    local name = t_trait.name
    local color = t_trait.color
    local trait_id = t_trait.upgrade_id
    local base_trait = t_trait.id
    local upgrade_trait_name = t_trait.upgrade_name
    if upgrade_trait_name == nil then
      upgrade_trait_name = name
    end
    local item_file = "$frame/npcfunc/equip_exchange.xml"
    local item_style = "trait_item"
    local item = w_pro_list:item_append()
    item:load_style(item_file, item_style)
    local t_color = 0
    if color == nil then
      color = ui_tool.cs_tip_color_green
    end
    t_color = ui.make_color(color)
    local property_name = item:search("property_text")
    item.svar.trait_id = trait_id
    item.svar.base_trait = base_trait
    item.svar.trait_desc = sys.format(L("<c+:%s>%s<c->"), color, upgrade_trait_name)
    item.svar.base_trait_desc = sys.format(L("<c+:%s>%s<c->"), color, name)
    item.svar.base_score = t_trait.base_score
    item.svar.upgrade_score = t_trait.upgrade_score
    property_name.text = name
    property_name.color = t_color
    local post_trait = item:search("post_trait")
    post_trait.text = upgrade_trait_name
    post_trait.color = t_color
    local lock_check = item:search("lock_check")
    local select = item:search("select")
    lock_check.check = false
  end
  local upgrade_data = ui_tool.get_equip_upgrade_data(info, excel)
  local new_build_packet
  if upgrade_data ~= nil then
    new_build_packet = upgrade_data.trait_packet
  end
  local function add_trait_by_id(id)
    if id <= 0 then
      return
    end
    local trait = bo2.gv_trait_list:find(id)
    if trait == nil then
      return
    end
    local t_trait = {}
    local modify_id = trait.modify_id
    local val = trait.modify_value
    if new_build_packet ~= nil then
      modify_id, val, trait_id = ui_tool.get_trait_upgrade(build_packet, new_build_packet, trait.modify_id, trait.modify_value)
      add_val = val
    end
    t_trait.name = ui_tool.ctip_trait_text_ex(modify_id, val)
    t_trait.color = ui_tool.get_trait_color(build_packet, trait.modify_id, trait.modify_value)
    if pdt_excel ~= nil then
      local modify_id = trait.modify_id
      local val = trait.modify_value
      modify_id, val, trait_id = ui_tool.get_trait_upgrade(build_packet, pdt_packet, trait.modify_id, trait.modify_value)
      t_trait.upgrade_name = ui_tool.ctip_trait_text_ex(modify_id, val)
      local get_gs_score = function(id, value)
        local excel = {}
        excel[id] = value
        local gs = ui_tool.ctip_calculate_item_rank(excel, nil, 2)
        return gs
      end
      t_trait.base_score = get_gs_score(trait.modify_id, trait.modify_value)
      t_trait.upgrade_score = get_gs_score(modify_id, val)
    end
    t_trait.upgrade_id = trait_id
    t_trait.id = id
    if trait_id == nil then
      trait_id = id
    end
    add_single_trait(t_trait)
  end
  local function load_info_all_trait()
    for i = bo2.eItemUInt32_IdentTraitBeg, bo2.eItemUInt32_IdentTraitEnd - 1 do
      local id = info:get_data_32(i)
      add_trait_by_id(id)
    end
  end
  load_info_all_trait()
  w_list_bg.visible = true
  post_product_update()
end
function on_ass_equip_change(card)
  local info = card.info
  if info == nil then
    return
  end
  do_product_update()
end
function on_ass_equip_drop(pn, msg, pos, data)
  if ui_cell.check_drop(pn, msg, pos, data) == false then
    return
  end
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
function on_quick_buy(btn)
  ui_supermarket2.shelf_singleBuy(btn)
end
function on_upgrade_click()
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  local upgrade_line = get_equip_upgrade_line()
  local lock_count = get_trait_lock_count()
  local c = get_mat_current_count()
  if lock_count > 0 and c <= 0 then
    w_btn_upgrade.enable = false
    return
  end
  local pdt_bd = 0
  if info:get_data_8(bo2.eItemByte_Bound) == 1 then
    pdt_bd = 1
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_EquipUpgrade)
  v:set64(packet.key.item_key1, info.only_id)
  local confirm = false
  local stk = sys.stack()
  local goods = g_buy_info.goods
  if goods == nil then
    return
  end
  local excel = g_buy_info.excel
  local mtf_stk = sys.mtf_stack()
  local results = {}
  ui_tool.ctip_make_goods_price(mtf_stk, excel, goods, 1, true, results)
  local arg = sys.variant()
  arg:set("item_id", upgrade_line.id)
  arg:set("price", mtf_stk.text)
  local txt_note = sys.mtf_merge(arg, ui.get_text("npcfunc|shop_precious_item_confirm"))
  local use_lock = check_use_lock_mat(L("mat_reg_4"))
  stk:push(txt_note)
  local prob = {}
  if use_lock == true then
    local lock_excel = get_lock_excel(info, upgrade_line)
    stk:push(L("<c+:#red>"))
    stk:push("+")
    stk:push(sys.format(L("%d<scii:%d>"), lock_excel.reg_num, lock_excel.reg_id))
    stk:push(L("<c->"))
  end
  local has_prob = false
  if lock_count > 0 then
    do
      local function trait_lock_data(idx)
        local trait_lock_excel = bo2.gv_equip_upgrade_trait_lock:find(idx)
        if trait_lock_excel == nil or trait_lock_excel.lock_count ~= lock_count then
          return false
        end
        local eq = info:get_data_32(bo2.eItemUInt32_UpgradeTraitLockProb)
        prob = fill_prob_mtf(trait_lock_excel, c, lock_count, eq)
        return true
      end
      local function upgrade_trait()
        local c_lock = upgrade_line.v_trait_lock_idx.size
        for i = 0, c_lock - 1 do
          if trait_lock_data(upgrade_line.v_trait_lock_idx[i]) == true then
            has_prob = true
            return true
          end
        end
      end
      upgrade_trait()
      stk:push(L("<c+:#red>"))
      stk:push("+")
      stk:push(sys.format(L("%d<scii:%d>"), prob.count, get_lock_mat_id()))
      stk:push(L("<c->"))
    end
  end
  stk:push(L("\n"))
  stk:push(L("<sep>"))
  stk:push(L("\n"))
  stk:push(L("\n"))
  if lock_count <= 0 then
    stk:push(ui.get_text("equip|en_lack_trait_lock"))
    stk:push(L("\n"))
  else
    stk:push(ui.get_text("equip|lock_notify"))
    stk:push(L("\n"))
    local key_beg = packet.key.item_key3
    local list_size = w_pro_list.item_count
    for i = 0, list_size - 1 do
      local item = w_pro_list:item_get(i)
      if sys.check(item) then
        local btn = item:search(L("lock_check"))
        if sys.check(btn) and btn.check == true then
          stk:push(L("<space:2.0>"))
          stk:push(item.svar.trait_desc)
          stk:push(L("\n"))
          v:set(key_beg, item.svar.base_trait)
          key_beg = key_beg + 1
        end
      end
    end
    v:set(packet.key.deal_lock, c)
    if has_prob then
      stk:push(ui_widget.merge_mtf(prob, ui.get_text("equip|trait_lock_item0")))
      stk:push("\n")
      stk:push(ui_widget.merge_mtf(prob, ui.get_text("equip|trait_lock_prob")))
      stk:push("\n")
    end
  end
  if use_lock ~= true then
    stk:push(L([[
<sep>

]]))
    stk:push(ui.get_text("equip|en_lack_lock_mat"))
    stk:push(L("\n"))
  else
    v:set64(packet.key.item_key2, 1)
    if lock_count > 0 then
      stk:push(L("<sep>\n"))
    end
  end
  if lock_count > 0 then
    stk:push(L("\n"))
    prob.item = sys.format(L("<i:%d>"), get_lock_mat_id())
    stk:push(ui_widget.merge_mtf(prob, ui.get_text("equip|trait_lock_faild_notify")))
    stk:push(ui_widget.merge_mtf(prob, ui.get_text("equip|faild_text2")))
    stk:push(L("\n"))
  end
  local text_show = stk.text
  local function on_msg_callback(msg_call)
    if msg_call.result ~= 1 then
      return
    end
    v:set(packet.key.item_key, g_buy_info.goods.id)
    v:set(packet.key.item_count, 1)
    bo2.send_variant(packet.eCTS_UI_BuyGoods, v)
  end
  local msg = {callback = on_msg_callback, text = text_show}
  ui_widget.ui_msg_box.show_common(msg)
end
function check_use_lock_mat(name)
  local mat_reg_cell = w_detail:search(name)
  if sys.check(mat_reg_cell) ~= true then
    return false
  end
  local card = mat_reg_cell:search("card")
  local card_pure = mat_reg_cell:search("card_pure")
  return card_pure.count >= card_pure.require_count
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
function on_try_set_check(btn)
  local card = w_cell_equip:search(L("card"))
  if sys.check(card) ~= true then
    return false
  end
  local info = card.info
  if sys.check(info) ~= true then
    return false
  end
  local excel = info.excel
  if excel == nil then
    return false
  end
  local upgrade_line = get_equip_upgrade_line(excel.id)
  if upgrade_line == nil then
    return false
  end
  local lock_excel = get_lock_excel(info, upgrade_line)
  if lock_excel == nil then
    return false
  end
  local total_count = lock_excel.reg_num
  local count = get_use_mat_max("mat_reg_4")
  if total_count <= count then
    set_use_mat_count("mat_reg_4", lock_excel.reg_num)
    return true
  else
    local q_buy = w_mat_quick_buy2
    if sys.check(q_buy) and q_buy.visible == true then
      local mtf = {}
      mtf.item_count = total_count
      mtf.item_has = count
      mtf.item_name = sys.format(L("<i:%d>"), lock_excel.reg_id)
      local txt = ui_widget.merge_mtf(mtf, ui.get_text("equip|leak_of_lock_mat_text"))
      ui_tool.note_insert(txt, "00FF00")
      q_buy.svar.count = total_count - count
      on_quick_buy(q_buy)
      q_buy.svar.count = 0
    end
  end
  return false
end
function on_check_lock_item(btn)
  if btn.check == true then
    if on_try_set_check(btn) ~= true then
      btn.check = false
    end
  else
    set_use_mat_count("mat_reg_4", 0)
  end
end
function on_visible(w, vis)
  if vis then
    ui_npcfunc.on_visible(w, vis)
  end
  clear_all()
  if vis then
    ui.item_mark_show("item_mark_equip_exchange", true)
  else
    ui.item_mark_show("item_mark_equip_exchange", false)
  end
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|eu_rclick_to_place")
end
function item_rbutton_check(info)
  return true
end
function is_info_match(info, notify)
  local function on_notify(txt)
    if notify == nil then
      return
    end
    ui_tool.note_insert(txt, "FF0000")
  end
  if sys.check(info) ~= true then
    return false
  end
  if info.box < bo2.eItemBox_BagBeg or info.box >= bo2.eItemBox_BagEnd then
    local txt = ui.get_text("npcfunc|only_item_from_bag")
    on_notify(txt)
    return false
  end
  local upgrade_line = get_equip_upgrade_line()
  if upgrade_line == nil then
    local txt = ui.get_text("equip_exchange|eu_invalid_tgt_equip")
    on_notify(txt)
    return false
  end
  if is_source_equip(upgrade_line, info.excel.id) ~= true then
    local txt = ui.get_text("equip_exchange|eu_invalid_tgt_equip")
    on_notify(txt)
    return false
  end
  if info:identify_finished() == false then
    local txt = ui.get_text("npcfunc|eu_identify_first")
    on_notify(txt)
    return false
  end
  for idx = 0, info:get_data_8(bo2.eItemByte_Holes) - 1 do
    if info:get_data_32(bo2.eItemUInt32_GemBeg + idx) ~= 0 then
      local txt = ui.get_text("npcfunc|eu_gem_tip")
      on_notify(txt)
      return false
    end
  end
  return true
end
function on_equip_drop(pn, msg, pos, data)
  if ui_cell.check_drop(pn, msg, pos, data) == false then
    return
  end
  local card = pn:search("card")
  local info = ui.item_of_only_id(data:get("only_id"))
  if is_info_match(info, 1) ~= true then
    return
  end
  ui_cell.drop(pn, info)
end
function item_rbutton_use(info)
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  if is_info_match(info, 1) ~= true then
    return
  end
  ui_cell.drop(w_cell_equip, info)
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  w_pro_list:item_clear()
  on_init_trait_text()
end
function init_product()
  local pdt_cell = w_detail:search("product")
  ui_cell.set(pdt_cell, g_buy_info.excel.id)
  for i, v in pairs(ui_item.g_boxs) do
    for j, k in pairs(v.cells) do
      if k.card.info then
        local info = k.card.info
        if is_info_match(info) == true then
          item_rbutton_use(info)
          return true
        end
      end
    end
  end
  ui_tool.note_insert(ui.get_text("equip_exchange|no_found_equip"), "FF0000")
  return false
end
function set_visible_by_info(info)
  if sys.check(info) ~= true then
    return false
  end
  g_buy_info = info
  local var = sys.variant()
  var[packet.key.cmn_id] = info.excel.id
  ui.ui_item_mark_value(var)
  w_main.visible = true
  init_product()
  do_product_update()
end
function on_rst(cmd, data)
  w_main.visible = false
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_BuyGoodsRst, on_rst, "ui_npcfunc.ui_equip_exchange.on_rst")
