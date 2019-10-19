local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
local c_count = 3
local c_lock_idx = 4
local lock_level = bo2.gv_define:find(50022).value.v_int
local sound_exp = 537
local sound_ex = 617
local sound_new_stage = 616
local quick_buy_table = {
  {item_id = 50299, goods_id = 9025},
  {item_id = 50323, goods_id = 9063}
}
local function get_goods_id(item_id)
  for key, val in ipairs(quick_buy_table) do
    if val.item_id == item_id then
      return val.goods_id
    end
  end
  return 0
end
local function clear_all()
  ui_cell.batch_clear(w_detail, {
    "product",
    "mat_equip",
    "mat_ass_equip"
  })
  local clear_list = function(list)
    local i_count = list.item_count
    for i = 0, i_count - 1 do
      local item = list:item_get(i)
      item.visible = false
    end
  end
  clear_list(w_pro_anime_list)
  clear_list(w_pro_base_anime_list)
  ui_cmn.money_set(w_req_money, 0)
  w_pro_list:item_clear()
  w_pro_base_list:item_clear()
  w_btn_upgrade.enable = false
  w_list_bg.visible = false
  w_stage.visible = false
  w_mat_quick_buy1.visible = false
  on_init_trait_text()
end
function get_equip_upgrade_line(item_id)
  return bo2.gv_equip_trait_upgrade:find(item_id)
end
function get_equip_upgrade_param(info, line)
  if info == nil or line == nil then
    return nil
  end
  local star = info:get_data_8(bo2.eItemByte_Star)
  local param_size = line.v_param.size
  for i = 0, param_size - 1 do
    local excel = bo2.gv_equip_trait_upgrade_param:find(line.v_param[i])
    if excel ~= nil and excel.star == star then
      return excel
    end
  end
  return nil
end
local get_ass_item_excel = function(tgt_info, ass_info)
  local upgrade_line = get_equip_upgrade_line(tgt_info.excel_id)
  if upgrade_line == nil then
    return nil
  end
  local datas = bo2.gv_equip_trait_upgrade_items.size - 1
  local ass_item_id = ass_info.excel_id
  for i = 0, datas do
    local line = bo2.gv_equip_trait_upgrade_items:get(i)
    if line.item == ass_item_id then
      return line
    end
  end
  return nil
end
local function is_valid_ass_item(tgt_info, ass_info)
  local excel = get_ass_item_excel(tgt_info, ass_info)
  return excel ~= nil
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
  refresh_trait()
  refresh_stage()
  local card_ass_equip = w_cell_ass_equip:search("card")
  local info_ass_equip = card_ass_equip.info
  if info_ass_equip == nil then
    return
  end
  w_btn_upgrade.enable = true
end
function post_product_update()
  w_main:insert_post_invoke(do_product_update, "ui_npcfunc.ui_equip_trait_upgrade.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  return
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
  local copy_flag32 = {}
  for i = bo2.eItemUInt32_EnchantBeg, bo2.eItemUInt32_EnchantEnd - 1 do
    copy_flag32[bo2.eItemUInt32_EnchantBeg] = 1
  end
  copy_flag32[bo2.eItemUInt32_CurWearout] = 1
  copy_flag32[bo2.eItemUInt32_MaxWearout] = 1
  local copy_val32 = {}
  copy_val32[bo2.eItemUint32_EquipTraitExp] = info_base:get_data_32(bo2.eItemUint32_EquipTraitExp)
  local card_ass_equip = w_cell_ass_equip:search("card")
  local info_ass_equip = card_ass_equip.info
  if info_ass_equip ~= nil then
    local excel = get_ass_item_excel(info_base, info_ass_equip)
    if sys.check(excel) then
      copy_val32[bo2.eItemUint32_EquipTraitExp] = copy_val32[bo2.eItemUint32_EquipTraitExp] + excel.score
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
      return info_base:get_data_8(val)
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
      return info_base:get_data_32(val)
    end,
    get_identify_state = function()
      return info_base:get_identify_state()
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
function on_lock_btn_tip(tip)
  local stk = sys.mtf_stack()
  local function push_new_line()
    stk:raw_push(L("\n"))
  end
  local item = tip.owner
  local svar = item.svar
  ui_tool.ctip_push_text(stk, ui.get_text("equip|eu_trait_indentify"), ui_tool.cs_tip_color_green, ui_tool.cs_tip_a_add_m)
  ui_tool.ctip_push_sep(stk)
  stk:raw_push(svar.base_trait_desc)
  push_new_line()
  ui_tool.ctip_push_text(stk, ui.get_text("tool|property_rank"))
  stk:raw_push(L("<space:2.0>"))
  ui_tool.ctip_push_text(stk, svar.base_score, ui_tool.cs_tip_color_bound, ui_tool.cs_tip_a_add_r)
  if svar.upgrade_score ~= nil then
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("equip|eu_tip_upgrade_trait"), ui_tool.cs_tip_color_green, ui_tool.cs_tip_a_add_m)
    ui_tool.ctip_push_sep(stk)
    stk:raw_push(svar.trait_desc)
    push_new_line()
    ui_tool.ctip_push_text(stk, ui.get_text("tool|property_rank"))
    ui_tool.ctip_push_text(stk, svar.upgrade_score, ui_tool.cs_tip_color_bound, ui_tool.cs_tip_a_add_r)
  end
  ui_tool.ctip_show(tip.owner, stk)
end
function on_init_trait_text()
  local stk = sys.mtf_stack()
  stk:raw_push(L("<a:left>"))
  stk:raw_push(ui.get_text("equip|init_text"))
  w_prob_desc0.mtf = stk.text
  w_prob_desc0.visible = true
  if sys.check(w_prob_desc) then
    w_prob_desc.visible = false
  end
end
local g_post_info
function get_stage_value(param, cur)
  if cur == 0 then
    return 0, 0
  end
  if cur >= param.level_exp * param.level_max then
    return param.level_max, param.level_exp
  else
    local stage = math.floor(cur / param.level_exp)
    local cur_value = math.floor(cur % param.level_exp)
    return stage, cur_value
  end
end
function get_stage_text(stage)
  local text = sys.format(L("equip|stage%d"), stage)
  return ui.get_text(text)
end
function refresh_stage()
  local card = w_cell_equip:search(L("card"))
  if sys.check(card) ~= true then
    return false
  end
  local info = card.info
  if sys.check(info) ~= true then
    return false
  end
  local upgrade_line = get_equip_upgrade_line(info.excel_id)
  if upgrade_line == nil then
    return
  end
  local param = get_equip_upgrade_param(info, upgrade_line)
  if param == nil then
    return
  end
  local stk = sys.stack()
  local exp = info:get_data_32(bo2.eItemUint32_EquipTraitExp)
  local mtf_stage = {}
  local cur_stage, cur_value = get_stage_value(param, exp)
  local old_cur_value = cur_value
  local old_stage = cur_stage
  if exp == 0 then
    mtf_stage.stage_text = ui.get_text(L("equip|stage_disable"))
  else
    mtf_stage.stage_text = get_stage_text(cur_stage)
  end
  local card_ass_equip = w_cell_ass_equip:search("card")
  local info_ass_equip = card_ass_equip.info
  local progress_value = cur_value
  local use_add = false
  if info_ass_equip ~= nil then
    local excel = get_ass_item_excel(info, info_ass_equip)
    local mat_add_value = excel.score
    mtf_stage.add_value = mat_add_value
    progress_value = mat_add_value + cur_value
    local new_exp = mat_add_value + exp
    cur_stage, cur_value = get_stage_value(param, new_exp)
    ui_cmn.money_set(w_req_money, excel.money)
    w_prob_desc.mtf = ui_widget.merge_mtf(mtf_stage, ui.get_text("equip|eu_add_exp"))
    w_prob_desc.visible = true
    mtf_stage.stage_text = get_stage_text(cur_stage)
    use_add = true
  else
    stk:push(ui_widget.merge_mtf(mtf_stage, ui.get_text("equip|cur_stage")))
    w_prob_desc.visible = false
    ui_cmn.money_set(w_req_money, 0)
  end
  local exp_stage_value = cur_value % param.level_exp
  if exp_stage_value == 0 and cur_value ~= 0 then
    exp_stage_value = param.level_exp
  end
  local base_trait_level_value = param.level_exp / param.level_stage
  for i = 0, 2 do
    local star_text = sys.format(L("st%d"), i)
    local star = w_stage_tip:search(star_text)
    if sys.check(star) then
      local anime = star:search("animation")
      local bg = star:search(L("bg_star"))
      if cur_stage ~= nil and cur_stage > i then
        anime:reset()
        anime:move_to_head()
        anime.visible = true
        bg.visible = true
      else
        anime.visible = false
        bg.visible = false
      end
    end
  end
  mtf_stage.exp = progress_value
  mtf_stage.level_exp = param.level_exp
  local tip_stage = math.floor(exp_stage_value / base_trait_level_value)
  mtf_stage.cur_base_count = tip_stage
  mtf_stage.max_base_count = param.level_stage
  if mtf_stage.cur_base_count > mtf_stage.max_base_count then
    mtf_stage.cur_base_count = mtf_stage.max_base_count
  end
  mtf_stage.val = param.level_exp / param.level_stage
  local tip_stk = sys.stack()
  tip_stk:push(ui_widget.merge_mtf(mtf_stage, ui.get_text("equip|tip_trait_stage")))
  tip_stk:push(ui_widget.merge_mtf(mtf_stage, ui.get_text("equip|tip_trait_exp")))
  tip_stk:push(ui_widget.merge_mtf(mtf_stage, ui.get_text("equip|tip_trait_exp1")))
  tip_stk:push(ui_widget.merge_mtf(mtf_stage, ui.get_text("equip|tip_trait_exp2")))
  w_exp_tip.tip.text = tip_stk.text
  w_stage_tip.tip.text = tip_stk.text
  local c_exp_count = 5
  local dx_persent = mtf_stage.level_exp / c_exp_count
  local c_base_dx = 56
  local dx_plus = dx_persent * c_base_dx
  local function set_progress(val, color_val)
    local dx = val * c_base_dx
    local flicker_dx = color_val * c_base_dx
    for i = 0, 4 do
      local fmt_prog = sys.format(L("prog%d"), i)
      local fmt_flicker_prog = sys.format(L("prog_f%d"), i)
      local function calc_dx(prog, in_dx)
        if in_dx > 0 then
          prog.visible = true
          if in_dx > dx_plus then
            prog.dx = c_base_dx
          else
            prog.dx = c_base_dx * in_dx / dx_plus
          end
          return in_dx - dx_plus, prog.dx
        else
          prog.visible = false
          return in_dx, 0
        end
      end
      local w_prog = w_process:search(fmt_prog)
      local prog_dx = 0
      dx, prog_dx = calc_dx(w_prog, dx)
      local w_flicker_prog = w_process:search(fmt_flicker_prog)
      if use_add ~= true then
        w_flicker_prog.visible = false
      else
        w_flicker_prog.visible = true
        local flicker_prog_dx = 0
        flicker_dx, flicker_prog_dx = calc_dx(w_flicker_prog, flicker_dx)
        local w_color = w_flicker_prog:search(L("color"))
        local w_base = w_flicker_prog:search(L("base"))
        w_color.visible = true
        w_base.visible = false
      end
    end
  end
  if use_add then
    if old_stage ~= cur_stage then
      cur_value = param.level_exp
    end
    if cur_value < old_cur_value + 10 then
      cur_value = old_cur_value + 10
    end
  end
  set_progress(old_cur_value, cur_value)
  w_stage.visible = true
end
function trait_grow_anime_ex(val)
  local card = w_cell_equip:search(L("card"))
  if sys.check(card) ~= true then
    return false
  end
  local info = card.info
  if sys.check(info) ~= true then
    return false
  end
  local upgrade_line = get_equip_upgrade_line(info.excel_id)
  if upgrade_line == nil then
    return
  end
  local excel = info.excel
  local star = info:get_data_8(bo2.eItemByte_Star)
  local build_packet, param
  local ex_data = {}
  ex_data.add_value = val
  local upgrade_data = ui_tool.get_equip_upgrade_data(info, excel, ex_data)
  if upgrade_data == nil then
    return
  end
  local base_data = ui_tool.get_equip_upgrade_data(info, excel)
  if base_data ~= nil and base_data.cur_stage == upgrade_data.cur_stage and base_data.base_persent == upgrade_data.base_persent then
    return
  end
  if base_data == nil then
    base_data = {}
    base_data.base_persent = 0
    base_data.cur_stage = 0
    base_data.trait_packet = nil
    base_data.build_packet = upgrade_data.build_packet
  end
  local exp = info:get_data_32(bo2.eItemUint32_EquipTraitExp)
  local base_count = 0
  local trait_count = 0
  local anime_insert = function(anime_list, t_trait)
    local anime_item = anime_list:item_get(t_trait.count)
    if sys.check(anime_item) ~= true then
      return
    end
    local v = anime_item:search("view_flash")
    local lb = anime_item:search("anime_text")
    anime_item.visible = true
    lb.text = t_trait.anime_name
    lb.color = ui.make_color(t_trait.anime_color)
    lb.visible = true
    v:reset()
    v:move_to_head()
    v.visible = true
  end
  if base_data.base_persent ~= upgrade_data.base_persent then
    local datas = excel.datas
    local cnt = datas.size
    if cnt == 0 then
      return
    end
    local fAddChg = 0
    if info ~= nil and star > 0 then
      local pStarAddition = bo2.gv_equip_star_addition:find(excel.reqlevel)
      if pStarAddition ~= nil then
        fAddChg = pStarAddition.rate[star - 1]
      end
    end
    local fOldAddChg = fAddChg
    fOldAddChg = fOldAddChg + base_data.base_persent / 1000000
    fAddChg = fAddChg + upgrade_data.base_persent / 1000000
    local atb_old_set = ui_tool.ctip_atb_set_create()
    local atb_new_set = ui_tool.ctip_atb_set_create()
    for i = 0, cnt - 1 do
      ui_tool.ctip_atb_set_insert(atb_old_set, datas[i], fOldAddChg * 100 + 100)
      ui_tool.ctip_atb_set_insert(atb_new_set, datas[i], fAddChg * 100 + 100)
    end
    local color
    local plootlevel_star = info.plootlevel_star
    if plootlevel_star ~= nil then
      color = plootlevel_star.color
    end
    for n, d in ipairs(atb_old_set) do
      local set_d = get_trait_set_data(d)
      local t_trait = {}
      local new_d = atb_new_set[n]
      if fAddChg ~= fOldAddChg and new_d ~= nil then
        local plus_set = get_trait_set_data(d, new_d)
        if plus_set ~= nil then
          t_trait.anime_name = plus_set.name
        end
      end
      t_trait.count = base_count
      t_trait.anime_color = color
      anime_insert(w_pro_base_anime_list, t_trait)
      base_count = base_count + 1
    end
  end
  if base_data.cur_stage == upgrade_data.cur_stage then
    return
  end
  local function ind_trait_anime(id)
    if id <= 0 then
      return
    end
    local trait = bo2.gv_trait_list:find(id)
    if trait == nil then
      return
    end
    local modify_id = trait.modify_id
    local val = trait.modify_value
    if base_data.trait_packet ~= nil then
      modify_id, val = ui_tool.get_trait_upgrade(base_data.build_packet, base_data.trait_packet, trait.modify_id, trait.modify_value)
    end
    local new_id, new_val = ui_tool.get_trait_upgrade(upgrade_data.build_packet, upgrade_data.trait_packet, trait.modify_id, trait.modify_value)
    local plus_val = math.abs(val - new_val)
    if plus_val <= 0 then
      return
    end
    local t_trait = {}
    t_trait.count = trait_count
    t_trait.anime_name = ui_tool.ctip_trait_text_ex(modify_id, plus_val)
    t_trait.anime_color = ui_tool.get_trait_color(base_data.build_packet, trait.modify_id, trait.modify_value)
    anime_insert(w_pro_anime_list, t_trait)
    trait_count = trait_count + 1
  end
  for i = bo2.eItemUInt32_IdentTraitBeg, bo2.eItemUInt32_IdentTraitEnd - 1 do
    local id = info:get_data_32(i)
    ind_trait_anime(id)
  end
end
function get_trait_set_data(d, new_d)
  local get_gs_score = function(id, value)
    local excel = {}
    excel[id] = value
    local gs = ui_tool.ctip_calculate_item_rank(excel, nil, 2)
    return gs
  end
  if d == nil then
    return nil
  end
  local rst_set = {}
  local desc, val_min, val_max
  rst_set.gs_score = 0
  rst_set.plus_name = nil
  if d.count == 1 then
    desc = d.desc
    if new_d ~= nil then
      local val = math.abs(new_d.modify_value - d.modify_value)
      rst_set.plus_name = sys.format(L("+%d"), val)
      rst_set.gs_score = get_gs_score(d.modify_id, d.modify_value)
      desc = ui_tool.ctip_trait_text_ex(d.modify_id, val)
    end
    rst_set.gs_score = get_gs_score(d.modify_id, d.modify_value)
  elseif d.min == nil then
    desc = ui_tool.ctip_trait_text_ex(d.range.max, d.max)
    val_max = d.max
    if new_d ~= nil then
      val_max = math.abs(val_max - new_d.max)
      rst_set.plus_name = sys.format(L("+%d"), val_max)
      desc = ui_tool.ctip_trait_text_ex(d.range.max, val_max)
    end
  elseif d.max == nil then
    desc = ui_tool.ctip_trait_text_ex(d.range.min, d.min)
    val_min = d.min
    if new_d ~= nil then
      val_min = math.abs(val_min - new_d.min)
      rst_set.plus_name = sys.format(L("+%d"), val_min)
      desc = ui_tool.ctip_trait_text_ex(d.range.min, val_min)
    end
  else
    desc = sys.format("%s%d-%d", d.range.desc, d.min, d.max)
    val_max = d.max
    val_min = d.min
    if new_d ~= nil then
      val_max = math.abs(val_max - new_d.max)
      val_min = math.abs(val_min - new_d.min)
      rst_set.plus_name = sys.format(L("+%d-%d"), val_min, val_max)
      desc = sys.format("%s+%d-%d", d.range.desc, val_min, val_max)
    end
  end
  if val_min ~= nil then
    rst_set.gs_score = get_gs_score(d.range.min, val_min)
  end
  if val_max ~= nil then
    rst_set.gs_score = rst_set.gs_score + get_gs_score(d.range.min, val_max)
  end
  rst_set.name = desc
  return rst_set
end
function refresh_trait()
  local card = w_cell_equip:search(L("card"))
  if sys.check(card) ~= true then
    return false
  end
  local info = card.info
  if sys.check(info) ~= true then
    return false
  end
  local upgrade_line = get_equip_upgrade_line(info.excel_id)
  if upgrade_line == nil then
    return
  end
  w_pro_list:item_clear()
  w_pro_base_list:item_clear()
  w_list_bg.visible = true
  local excel = info.excel
  local star = info:get_data_8(bo2.eItemByte_Star)
  local build_packet, param, cur_stage, cur_value
  local exp = info:get_data_32(bo2.eItemUint32_EquipTraitExp)
  local ex_data = {}
  local card_ass_equip = w_cell_ass_equip:search("card")
  local info_ass_equip = card_ass_equip.info
  if info_ass_equip ~= nil then
    local excel = get_ass_item_excel(info, info_ass_equip)
    if sys.check(excel) then
      ex_data.add_value = excel.score
    end
  end
  local upgrade_data = ui_tool.get_equip_upgrade_data(info, excel, ex_data)
  local pdt_packet, new_build_packet
  if upgrade_data == nil then
    build_packet = ui_tool.get_trait_color_packet(excel, star)
    param = get_equip_upgrade_param(info, upgrade_line)
  else
    param = upgrade_data.param
    pdt_packet = upgrade_data.trait_packet
    build_packet = upgrade_data.build_packet
    local exp = info:get_data_32(bo2.eItemUint32_EquipTraitExp)
    local cur_stage, cur_value = get_stage_value(param, exp)
    if cur_stage > 0 then
      if cur_stage == upgrade_data.cur_stage then
        new_build_packet = upgrade_data.trait_packet
      else
        local new_upgrade = ui_tool.get_equip_upgrade_data(info, excel)
        new_build_packet = new_upgrade.trait_packet
      end
    end
  end
  if param == nil then
    return
  end
  local add_single_trait = function(pro, t_trait)
    local name = t_trait.name
    local color = t_trait.color
    local trait_id = t_trait.upgrade_id
    local base_trait = t_trait.id
    local upgrade_trait_name = t_trait.upgrade_name
    if upgrade_trait_name == nil then
      upgrade_trait_name = name
    end
    local item_file = "$frame/npcfunc/equip_trait_upgrade.xml"
    local item_style = "trait_item"
    local item = pro:item_append()
    item:load_style(item_file, item_style)
    local t_color = 0
    if color == nil then
      color = ui_tool.cs_tip_color_green
    end
    t_color = ui.make_color(color)
    local property_name = item:search("property_text")
    item.svar.trait_id = trait_id
    item.svar.base_trait = base_trait
    local desc_color = color
    if sys.is_type(color, "number") then
      desc_color = sys.format(L("<c+:%.6X>"), color)
    else
      desc_color = sys.format(L("<c+:%s>"), color)
    end
    item.svar.base_trait_desc = sys.format(L("%s%s<c->"), desc_color, name)
    item.svar.trait_desc = sys.format(L("%s%s<c->"), desc_color, upgrade_trait_name)
    item.svar.base_score = t_trait.base_score
    item.svar.upgrade_score = t_trait.upgrade_score
    if t_trait.plus_name ~= nil then
      property_name.text = sys.format(L("%s(%s)"), name, t_trait.plus_name)
      item.svar.anime_name = t_trait.anime_name
      item.svar.anime_color = t_color
    else
      property_name.text = name
    end
    property_name.color = t_color
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
    local get_gs_score = function(id, value)
      local excel = {}
      excel[id] = value
      local gs = ui_tool.ctip_calculate_item_rank(excel, nil, 2)
      return gs
    end
    local add_val = trait.modify_value
    if new_build_packet ~= nil then
      modify_id, val, trait_id = ui_tool.get_trait_upgrade(build_packet, new_build_packet, trait.modify_id, trait.modify_value)
      add_val = val
    end
    t_trait.name = ui_tool.ctip_trait_text_ex(modify_id, val)
    if pdt_packet ~= nil then
      modify_id, val, trait_id = ui_tool.get_trait_upgrade(build_packet, pdt_packet, trait.modify_id, trait.modify_value)
      local plus_val = math.abs(val - add_val)
      if plus_val > 0 then
        t_trait.plus_name = sys.format(L("+%d"), plus_val)
        t_trait.upgrade_score = get_gs_score(modify_id, val)
        t_trait.upgrade_name = ui_tool.ctip_trait_text_ex(modify_id, val)
        t_trait.anime_name = ui_tool.ctip_trait_text_ex(modify_id, plus_val)
      end
    end
    t_trait.base_score = get_gs_score(trait.modify_id, add_val)
    t_trait.color = ui_tool.get_trait_color(build_packet, trait.modify_id, trait.modify_value)
    t_trait.upgrade_id = trait_id
    t_trait.id = id
    if trait_id == nil then
      trait_id = id
    end
    add_single_trait(w_pro_list, t_trait)
  end
  local function load_info_all_trait()
    for i = bo2.eItemUInt32_IdentTraitBeg, bo2.eItemUInt32_IdentTraitEnd - 1 do
      local id = info:get_data_32(i)
      add_trait_by_id(id)
    end
  end
  load_info_all_trait()
  local function load_item_base_trait()
    local datas = excel.datas
    local cnt = datas.size
    if cnt == 0 then
      return
    end
    local fAddChg = 0
    if info ~= nil and star > 0 then
      local pStarAddition = bo2.gv_equip_star_addition:find(excel.reqlevel)
      if pStarAddition ~= nil then
        fAddChg = pStarAddition.rate[star - 1]
      end
    end
    local fOldAddChg = fAddChg
    if ex_data.add_value ~= nil and upgrade_data ~= nil then
      local only_data = {}
      only_data.only_base = true
      local old_upgrade = ui_tool.get_equip_upgrade_data(info, excel, only_data)
      if old_upgrade ~= nil then
        fOldAddChg = fOldAddChg + old_upgrade.base_persent / 1000000
      end
      fAddChg = fAddChg + upgrade_data.base_persent / 1000000
    elseif upgrade_data ~= nil then
      fOldAddChg = fOldAddChg + upgrade_data.base_persent / 1000000
      fAddChg = fOldAddChg
    end
    local atb_old_set = ui_tool.ctip_atb_set_create()
    local atb_new_set = ui_tool.ctip_atb_set_create()
    for i = 0, cnt - 1 do
      ui_tool.ctip_atb_set_insert(atb_old_set, datas[i], fOldAddChg * 100 + 100)
      ui_tool.ctip_atb_set_insert(atb_new_set, datas[i], fAddChg * 100 + 100)
    end
    local color
    local plootlevel_star = info.plootlevel_star
    if plootlevel_star ~= nil then
      color = plootlevel_star.color
    end
    for n, d in ipairs(atb_old_set) do
      local set_d = get_trait_set_data(d)
      local t_trait = {}
      t_trait.name = set_d.name
      t_trait.base_score = set_d.gs_score
      local new_d = atb_new_set[n]
      if fAddChg ~= fOldAddChg and new_d ~= nil then
        local plus_set = get_trait_set_data(d, new_d)
        if plus_set ~= nil then
          local new_set = get_trait_set_data(new_d)
          t_trait.plus_name = plus_set.plus_name
          t_trait.anime_name = plus_set.name
          t_trait.upgrade_name = new_set.name
          t_trait.upgrade_score = new_set.gs_score
        end
      end
      local function push_traits(t_trait)
        if t_trait.name == nil then
          return
        end
        local t_color = cs_tip_color_green
        if color then
          t_color = color
        end
        t_trait.color = color
        add_single_trait(w_pro_base_list, t_trait)
      end
      push_traits(t_trait)
    end
  end
  load_item_base_trait()
  local i_count = w_pro_base_list.item_count
  if i_count == 1 then
    w_pro_base_list.margin = ui.rect(0, 20, 0, 0)
  else
    w_pro_base_list.margin = ui.rect(0, 7, 0, 0)
  end
end
function refresh_quick_buy()
  local excel_id = 66258
  w_mat_quick_buy1.visible = false
  local goods_id = ui_supermarket2.shelf_quick_buy_id(excel_id)
  if goods_id == 0 then
    return
  end
  w_mat_quick_buy1.name = tostring(goods_id)
  w_mat_quick_buy1.visible = true
  w_mat_quick_buy1.visible = true
end
function on_equip_change(card)
  local info = card.info
  if info == nil then
    g_post_info = nil
    return
  end
  local upgrade_line = get_equip_upgrade_line(info.excel_id)
  if upgrade_line == nil then
    return
  end
  local param = get_equip_upgrade_param(info, upgrade_line)
  if param == nil then
    local txt = ui.get_text("equip|eu_invalid_tgt_equip0")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  local exp = info:get_data_32(bo2.eItemUint32_EquipTraitExp)
  local max = param.level_exp * param.level_max
  if exp >= max then
    ui_cell.set(w_cell_equip, 0)
    return
  end
  if g_post_info ~= nil and info == g_post_info then
    post_product_update()
    return
  end
  g_post_info = info
  local upgrade_line = get_equip_upgrade_line(info.excel_id)
  if upgrade_line == nil then
    return
  end
  local pdt_cell = w_detail:search("product")
  ui_cell.set(pdt_cell, upgrade_line.id)
  local lb = pdt_cell:search("lb_item")
  if sys.check(lb) and info.plootlevel_star then
    lb.color = ui.make_color(info.plootlevel_star.color)
  end
  refresh_trait()
  refresh_stage()
  refresh_quick_buy()
end
function on_ass_equip_change(card)
  local info = card.info
  local card = card:search(L("card"))
  if info == nil or sys.check(card) ~= true or card.count <= 0 then
    ui_cell.batch_clear(w_detail, {
      "mat_ass_equip"
    })
  end
  post_product_update()
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
  local upgrade_line = get_equip_upgrade_line(info.excel_id)
  if upgrade_line == nil then
    local txt = ui.get_text("equip|eu_invalid_tgt_equip0")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  local param = get_equip_upgrade_param(info, upgrade_line)
  if param == nil then
    local txt = ui.get_text("equip|eu_invalid_tgt_equip0")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  if info:identify_finished() == false then
    local txt = ui.get_text("npcfunc|eu_identify_first")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  local exp = info:get_data_32(bo2.eItemUint32_EquipTraitExp)
  local max = param.level_exp * param.level_max
  if exp >= max then
    local txt = bo2.gv_text:find(5495)
    if txt then
      ui_tool.note_insert(txt.text, "FF0000")
    end
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
    local txt = ui.get_text("npcfunc|only_item_from_bag")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  local tgt_info = w_cell_equip:search("card").info
  if tgt_info == nil then
    local txt = ui.get_text("equip|eu_tgt_equip_first")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  if is_valid_ass_item(tgt_info, info) == false then
    local txt = ui.get_text("equip|eu_invalid_ass_item")
    ui_tool.note_insert(txt, "FF0000")
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
function on_ass_equip_card_mouse(ctrl, msg)
  if msg ~= ui.mouse_rbutton_down then
    return
  end
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
  local info1 = w_cell_ass_equip:search("card").info
  if info1 == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_EquipTraitUpgrade)
  v:set64(packet.key.item_key, info.only_id)
  v:set64(packet.key.item_key1, info1.only_id)
  local confirm = false
  local stk = sys.stack()
  local function on_msg_callback(msg_call)
    if msg_call.result ~= 1 then
      return
    end
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  end
  local msg = {
    callback = on_msg_callback,
    text = text_show,
    result = 1
  }
  on_msg_callback(msg)
end
function on_visible(w, vis)
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
  clear_all()
  g_post_info = nil
  if vis then
    ui.item_mark_show("item_mark_equip_trait_upgrade", true)
  else
    ui.item_mark_show("item_mark_equip_trait_upgrade", false)
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
    local upgrade_line = get_equip_upgrade_line(excel.id)
    if upgrade_line == nil then
      local txt = ui.get_text("equip|eu_invalid_tgt_equip0")
      ui_tool.note_insert(txt, "FF0000")
      return
    end
    local param = get_equip_upgrade_param(info, upgrade_line)
    if param == nil then
      local txt = ui.get_text("equip|eu_invalid_tgt_equip0")
      ui_tool.note_insert(txt, "FF0000")
      return
    end
    local exp = info:get_data_32(bo2.eItemUint32_EquipTraitExp)
    local max = param.level_exp * param.level_max
    if exp >= max then
      local txt = bo2.gv_text:find(5495)
      if txt then
        ui_tool.note_insert(txt.text, "FF0000")
      end
      return
    end
    ui_cell.drop(w_cell_equip, info)
  else
    if is_valid_ass_item(tgt_info, info) == false then
      local txt = ui.get_text("equip|eu_invalid_ass_item")
      ui_tool.note_insert(txt, "FF0000")
      return
    end
    ui_cell.drop(w_cell_ass_equip, info)
  end
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  w_pro_list:item_clear()
  w_pro_base_list:item_clear()
  on_init_trait_text()
  local init_list = function(list, count)
    list:item_clear()
    for i = 0, count - 1 do
      local item_file = "$frame/npcfunc/equip_trait_upgrade.xml"
      local item_style = "trait_anime_item"
      local item = list:item_append()
      item:load_style(item_file, item_style)
      item.visible = true
    end
  end
  init_list(w_pro_base_anime_list, 2)
  init_list(w_pro_anime_list, 8)
end
function exp_grow_anime(val, ex)
  local v
  if ex > 0 then
    local mtf_stage = {}
    mtf_stage.val = val
    anime_text2.text = ui_widget.merge_mtf(mtf_stage, ui.get_text("equip|grow_ex"))
    anime_text2.color = ui.make_color("F1A30B")
    v = w_gain_anime2
  else
    local mtf_stage = {}
    mtf_stage.val = val
    anime_text.text = ui_widget.merge_mtf(mtf_stage, ui.get_text("equip|grow_text"))
    anime_text.color = ui.make_color("FFFFFF")
    v = w_gain_anime
  end
  local sound = sound_exp
  if ex > 0 then
    sound = sound_ex
  end
  bo2.PlaySound2D(sound)
  if v == nil then
    return
  end
  anime_text.visible = true
  anime_text2.visible = true
  v:reset()
  v:move_to_head()
  v.visible = true
end
function trait_grow_anime(val, ex)
  local has_anime = false
  local function update_list(list, anime_list)
    local i_count = list.item_count
    for i = 0, i_count - 1 do
      local item = list:item_get(i)
      local anime_item = anime_list:item_get(i)
      if sys.check(item) and sys.check(anime_item) and sys.check(item.svar.anime_name) then
        has_anime = true
        local v = anime_item:search("view_flash")
        local lb = anime_item:search("anime_text")
        anime_item.visible = true
        lb.text = item.svar.anime_name
        lb.color = item.svar.anime_color
        lb.visible = true
        v:reset()
        v:move_to_head()
        v.visible = true
      end
    end
  end
  update_list(w_pro_base_list, w_pro_base_anime_list)
  update_list(w_pro_list, w_pro_anime_list)
  if ex ~= 0 and has_anime == false then
    trait_grow_anime_ex(val)
  end
end
function g()
  exp_grow_anime(100, 0)
  trait_grow_anime(100, 0)
  exp_grow_anime(100, 0)
  trait_grow_anime(100, 0)
  exp_grow_anime(200, 1)
  trait_grow_anime(200, 1)
  exp_grow_anime(100, 0)
  trait_grow_anime(100, 0)
end
function on_handle_grow_rst(cmd, data)
  local val = data[packet.key.gs_score]
  local ex = data:get(packet.key.extra_exp).v_int
  exp_grow_anime(val, ex)
  trait_grow_anime(val, ex)
end
local sig_name = "ui_npcfunc:on_signal_cooldown_token"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_EquipGrow, on_handle_grow_rst, sig_name)
