local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
local c_count = 3
local g_post_info, g_lock_excel_recognized, g_lock_excel
local g_trait_total = {}
function on_npcfunc_open_window(npcfunc_id)
  g_npcfunc_id = npcfunc_id
end
function clear_money()
  ui_cmn.money_set(w_req_money0, 0)
  ui_cmn.money_set(w_req_money1, 0)
  w_req_money0.visible = true
  w_req_money1.visible = false
end
local function clear_all()
  ui_cell.batch_clear(w_detail, {
    "product",
    "mat_equip",
    "mat_reg_0",
    "mat_reg_1",
    "mat_reg_2",
    "mat_reg_3",
    "mat_reg_4",
    "mat_reg_5"
  })
  clear_money()
  w_btn_upgrade.enable = false
  btn_lock_item.check = false
  btn_lock_item_recognized.check = false
end
local get_equip_upgrade_line = function(item_id)
  local upgrade_line
  for i = 0, bo2.gv_tianzi_equip_upgrade.size - 1 do
    local line = bo2.gv_tianzi_equip_upgrade:get(i)
    if line.a_item_id == item_id then
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
  local card_equip = w_cell_equip:search("card")
  local info_equip = card_equip.info
  if info_equip == nil then
    clear_all()
    return
  end
  local upgrade_line = get_equip_upgrade_line(info_equip.excel_id)
  for i = 0, c_count do
    local id = upgrade_line.reg_id[i]
    if id ~= 0 then
      local c = ui.item_get_count(id, true)
      if c < upgrade_line.reg_num[i] then
        return
      end
    end
  end
  local player = bo2.player
  local money_type = upgrade_line.money_type
  local monye_total = 0
  if money_type == 0 then
    monye_total = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
  elseif money_type == 1 then
    monye_total = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney) + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
  end
  if monye_total < upgrade_line.money then
    return
  end
  w_btn_upgrade.enable = true
end
function post_product_update()
  w_main:insert_post_invoke(do_product_update, "ui_npcfunc.ui_tianzi_equip_upgrade.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  post_product_update()
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
  local btn_check = btn_lock_item.check
  local btn_check_recognized = btn_lock_item_recognized.check
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
  copy_flag32[bo2.eItemUInt32_RecognizedMasterTimes] = 1
  copy_flag32[bo2.eItemUInt32_RecognizedMasterVal] = 1
  local copy_val32 = {}
  local base_star = info_base:get_data_8(bo2.eItemByte_Star)
  for i = 0, base_star - 2 do
    if g_trait_total[i].upgrade_id ~= 0 and g_trait_total[i].upgrade_id ~= nil then
      ui.log("g_trait_total[i].trait_id::" .. g_trait_total[i].upgrade_id)
      copy_val32[bo2.eItemUInt32_IdentTraitBeg + i] = g_trait_total[i].upgrade_id
    else
      break
    end
  end
  local info = {
    name = excel.name,
    plootlevel_star = bo2.gv_lootlevel:find(excel.lootlevel),
    get_data_8 = function(info, val)
      if val == bo2.eItemByte_Star then
        return excel.fix_star
      end
      if btn_check_recognized == true and (val == bo2.eItemByte_RecognizedCounted or val == bo2.eItemByte_RecognizedMaxCount) then
        local v = 0
        v = info_base:get_data_8(val)
        return v
      end
      if btn_check == true and copy_babe[val] ~= nil then
        local v = 0
        if val == bo2.eItemByte_EnforcePre then
          v = ui.item_get_total_enforce_data(info_base)
        elseif val ~= bo2.eItemByte_RecognizedCounted and val ~= bo2.eItemByte_RecognizedMaxCount then
          v = info_base:get_data_8(val)
        end
        return v
      end
      return 0
    end,
    star = excel.fix_star,
    get_data_s = function()
      return L("")
    end,
    box = bo2.eItemBox_BagBeg,
    get_data_32 = function(info, val)
      if btn_check_recognized == true then
        if val == bo2.eItemUInt32_RecognizedMasterTimes or val == bo2.eItemUInt32_RecognizedMasterVal then
          local v = 0
          v = info_base:get_data_32(val)
          return v
        end
      elseif val == bo2.eItemUInt32_RecognizedMasterTimes or val == bo2.eItemUInt32_RecognizedMasterVal then
        return 0
      end
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
function get_lock_excel(info, upgrade_line)
  if info == nil or upgrade_line == nil then
    return nil
  end
  local size_lock = upgrade_line.v_lock_enforce_ids.size
  if size_lock <= 0 then
    return nil
  end
  local maxCount = info:get_data_8(bo2.eItemByte_EnforceMaxCount)
  local function process_lock(excel)
    if excel == nil then
      return false
    end
    if excel.enforce_max == maxCount then
      return true
    end
    return false
  end
  for i = 0, size_lock - 1 do
    local lock_excel_id = upgrade_line.v_lock_enforce_ids[i]
    local lock_excel = bo2.gv_tianzi_lock_enforce_rules:find(lock_excel_id)
    if process_lock(lock_excel) == true then
      return lock_excel
    end
  end
  return nil
end
function get_lock_excel_recognized(info, upgrade_line)
  if info == nil or upgrade_line == nil then
    return nil
  end
  local size_lock = upgrade_line.v_lock_recognized_ids.size
  if size_lock <= 0 then
    return nil
  end
  local maxCount = info:get_data_8(bo2.eItemByte_RecognizedMaxCount)
  local function process_lock(excel)
    if excel == nil then
      return false
    end
    if excel.recognized_max == maxCount then
      return true
    end
    return false
  end
  for i = 0, size_lock - 1 do
    local lock_excel_id = upgrade_line.v_lock_recognized_ids[i]
    local lock_excel = bo2.gv_tianzi_lock_recognized_rules:find(lock_excel_id)
    if process_lock(lock_excel) == true then
      return lock_excel
    end
  end
  return nil
end
function on_equip_change(card)
  local info = card.info
  if info == nil then
    g_post_info = nil
    return
  end
  if g_post_info ~= nil and info == g_post_info then
    do_product_update()
    return
  end
  g_post_info = info
  local upgrade_line = get_equip_upgrade_line(info.excel_id)
  if upgrade_line == nil then
    return
  end
  local pdt_cell = w_detail:search("product")
  ui_cell.set(pdt_cell, upgrade_line.p_item_id)
  local lb = pdt_cell:search("lb_item")
  if sys.check(lb) and info.plootlevel_star then
    lb.color = ui.make_color(info.plootlevel_star.color)
  end
  ui_cell.batch_clear(w_detail, {
    "mat_reg_0",
    "mat_reg_1",
    "mat_reg_2",
    "mat_reg_3",
    "mat_reg_4",
    "mat_reg_5"
  })
  for i = 0, c_count do
    if upgrade_line.reg_id[i] then
      local mat_reg_cell = w_detail:search("mat_reg_" .. i)
      ui_cell.set(mat_reg_cell, upgrade_line.reg_id[i], upgrade_line.reg_num[i])
    end
  end
  g_lock_excel = nil
  g_lock_excel = get_lock_excel(info, upgrade_line)
  if lock_excel ~= nil and btn_lock_item.check == true then
    local mat_reg_cell = w_detail:search("mat_reg_4")
    ui_cell.set(mat_reg_cell, lock_excel.reg_id, lock_excel.reg_num)
  end
  g_lock_excel_recognized = nil
  g_lock_excel_recognized = get_lock_excel_recognized(info, upgrade_line)
  if g_lock_excel_recognized ~= nil and btn_lock_item_recognized.check == true then
    local mat_reg_cell = w_detail:search("mat_reg_5")
    ui_cell.set(mat_reg_cell, g_lock_excel_recognized.reg_id, g_lock_excel_recognized.reg_num)
  end
  local money_type = upgrade_line.money_type
  if money_type == 0 then
    w_req_money0.visible = true
    w_req_money1.visible = false
    ui_cmn.money_set(w_req_money0, upgrade_line.money)
  elseif money_type == 1 then
    w_req_money0.visible = false
    w_req_money1.visible = true
    ui_cmn.money_set(w_req_money1, upgrade_line.money)
  end
  on_check_lock_item(btn_lock_item)
  on_check_lock_item_recognized(btn_lock_item_recognized)
  g_trait_total = {}
  local index = 0
  local excel = info.excel
  local star = info:get_data_8(bo2.eItemByte_Star)
  local build_packet = ui_tool.get_trait_color_packet(excel, star)
  local pdt_excel = bo2.gv_equip_item:find(upgrade_line.p_item_id)
  local pdt_packet = {}
  if pdt_excel ~= nil then
    pdt_packet = ui_tool.get_trait_color_packet(pdt_excel, pdt_excel.fix_star)
  end
  local function add_single_trait(t_trait)
    g_trait_total[index] = t_trait
    index = index + 1
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
end
function on_equip_drop(pn, msg, pos, data)
  if ui_cell.check_drop(pn, msg, pos, data) == false then
    return
  end
  local card = pn:search("card")
  local info = ui.item_of_only_id(data:get("only_id"))
  if info.box < bo2.eItemBox_BagBeg or info.box >= bo2.eItemBox_BagEnd then
    local txt = ui.get_text("npcfunc|only_item_from_bag")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  for idx = 0, info:get_data_8(bo2.eItemByte_Holes) - 1 do
    if info:get_data_32(bo2.eItemUInt32_GemBeg + idx) ~= 0 then
      local txt = ui.get_text("npcfunc|tianzi_eu_gem_tip")
      ui_tool.note_insert(txt, "FF0000")
      return
    end
  end
  if info:identify_finished() == false then
    local txt = ui.get_text("npcfunc|eu_identify_first")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  local star = info:get_data_8(bo2.eItemByte_Star)
  local upgrade_line = get_equip_upgrade_line(info.excel_id)
  if upgrade_line == nil or star < upgrade_line.equip_star then
    local txt = ui.get_text("npcfunc|tianzi_eu_invalid_tgt_equip")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  local pdt_excel_id = upgrade_line.p_item_id
  local pdt_excel = bo2.gv_equip_item:find(pdt_excel_id)
  if sys.check(pdt_excel) ~= true then
    local txt = bo2.gv_text:find(78160)
    if sys.check(txt) then
      ui_tool.note_insert(txt.text, "FF0000")
    end
    return
  end
  ui_cell.drop(pn, info)
end
function on_equip_card_mouse(ctrl, msg)
  if msg ~= ui.mouse_rbutton_down then
    return
  end
  clear_all()
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
function on_upgrade_click()
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  local upgrade_line = get_equip_upgrade_line(info.excel.id)
  if upgrade_line == nil then
    return
  end
  local pdt_bd = 0
  if info:get_data_8(bo2.eItemByte_Bound) == 1 then
    pdt_bd = 1
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_TianziEquipUpgrade)
  v:set64(packet.key.item_key, info.only_id)
  local stk = sys.stack()
  if pdt_bd == 1 then
    stk:push(ui.get_text("npcfunc|eu_bound_tip"))
    stk:push(L("\n"))
  end
  local use_lock = btn_lock_item.check
  if use_lock ~= true then
    stk:push(ui.get_text("equip|lack_lock_enforce_text"))
    stk:push(L("\n"))
  else
    v:set64(packet.key.item_key1, 1)
  end
  local btn_check_recognized = btn_lock_item_recognized.check
  if btn_check_recognized ~= true then
    stk:push(ui.get_text("equip|lack_lock_recognized_text"))
    stk:push(L("\n"))
  else
    v:set64(packet.key.item_key2, 1)
  end
  stk:push(L([[
<sep>

]]))
  stk:push(ui.get_text("equip|confirm"))
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
function on_try_set_check(btn, lock_excel, name)
  if lock_excel == nil or name == nil then
    return false
  end
  local c = ui.item_get_count(lock_excel.reg_id, true)
  if c < lock_excel.reg_num then
    local var = sys.variant()
    var:set(L("item_id"), lock_excel.reg_id)
    var:set(L("num"), lock_excel.reg_num)
    local data = sys.variant()
    data:set(packet.key.ui_text_id, 2664)
    data:set(packet.key.ui_text_arg, var)
    ui_chat.show_ui_text(0, data)
    return false
  end
  local mat_reg_cell = w_detail:search(name)
  ui_cell.set(mat_reg_cell, lock_excel.reg_id, lock_excel.reg_num)
  return true
end
function on_check_lock_item(btn)
  if btn.check == true then
    if on_try_set_check(btn, g_lock_excel, "mat_reg_4") ~= true then
      btn.check = false
    end
  else
    local mat_reg_cell = w_detail:search("mat_reg_4")
    ui_cell.clear(mat_reg_cell)
    btn.check = false
  end
end
function on_check_lock_item_recognized(btn)
  if btn.check == true then
    if on_try_set_check(btn, g_lock_excel_recognized, "mat_reg_5") ~= true then
      btn.check = false
    end
  else
    local mat_reg_cell = w_detail:search("mat_reg_5")
    ui_cell.clear(mat_reg_cell)
    btn.check = false
  end
end
function on_visible(w, vis)
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
  clear_all()
  g_post_info = nil
  g_lock_excel_recognized = nil
  g_lock_excel = nil
end
function item_rbutton_tip(info)
  return true
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
  for idx = 0, info:get_data_8(bo2.eItemByte_Holes) - 1 do
    if info:get_data_32(bo2.eItemUInt32_GemBeg + idx) ~= 0 then
      local txt = ui.get_text("npcfunc|tianzi_eu_gem_tip")
      ui_tool.note_insert(txt, "FF0000")
      return
    end
  end
  if info:identify_finished() == false then
    local txt = ui.get_text("npcfunc|eu_identify_first")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  local star = info:get_data_8(bo2.eItemByte_Star)
  local upgrade_line = get_equip_upgrade_line(excel.id)
  if upgrade_line == nil or star < upgrade_line.equip_star then
    local txt = ui.get_text("npcfunc|tianzi_eu_invalid_tgt_equip")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  local pdt_excel_id = upgrade_line.p_item_id
  local pdt_excel = bo2.gv_equip_item:find(pdt_excel_id)
  if sys.check(pdt_excel) ~= true then
    local txt = bo2.gv_text:find(78160)
    if sys.check(txt) then
      ui_tool.note_insert(txt.text, "FF0000")
    end
    return
  end
  ui_cell.drop(w_cell_equip, info)
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
