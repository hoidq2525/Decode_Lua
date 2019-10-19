local ui_tree2 = ui_widget.ui_tree2
local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
math.randomseed(os.time())
function is_raw_var(var, t_ref_var)
  for i = 0, t_ref_var.size - 1 do
    if t_ref_var[i] == var then
      return true
    end
  end
  return false
end
function on_btn_make_click(btn)
  local item = w_variety_view.item_sel
  if item == nil then
    return
  end
  local info = w_detail:search("mat_raw"):search("card").info
  if info == nil then
    return
  end
  local pdt_bd = 0
  if info:get_data_8(bo2.eItemByte_Bound) == 1 then
    pdt_bd = 1
  end
  local variety = item.svar.make_variety
  local mat_count = variety.raw_var_count
  local cur_count = ui.item_get_count(info.excel.id, true)
  local text_result = L("")
  if mat_count > cur_count then
    local bd_count = 0
    local cir_count = 0
    local other_id = info.excel.datas[0]
    local tb_param = {
      first_item = info.excel.id,
      num = mat_count - cur_count,
      second_item = other_id
    }
    local text_model = ui.get_text("npcfunc|make_bd_msg")
    text_result = ui_widget.merge_mtf(tb_param, text_model)
    pdt_bd = 1
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_MakeEquip)
  v:set(packet.key.item_excelid, variety.id)
  v:set64(packet.key.item_key, info.only_id)
  if pdt_bd == 1 then
    local function on_msg_callback(msg_call)
      if msg_call.result ~= 1 then
        return
      end
      bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
    end
    local text_show = ui.get_text("npcfunc|make_bd_tip")
    local msg = {
      callback = on_msg_callback,
      text = text_result .. text_show
    }
    ui_widget.ui_msg_box.show_common(msg)
  else
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  end
end
function on_level(obj, ft, idx)
  update_view()
end
function detail_clear()
  ui_cell.batch_clear(w_detail, {
    "product",
    "mat_raw",
    "mat_reg_0",
    "mat_reg_1",
    "mat_reg_2",
    "mat_reg_3"
  })
  local card = w_mat_raw:search(L("card"))
  card.require_count = 0
  w_detail:search("lb_money").money = 0
  w_detail:search("raw_mat_con"):control_clear()
  w_btn_make.enable = false
  w_detail:search("mat_raw"):search("lb_item").text = L("")
end
function on_item_mouse(title, msg)
  local fig_highlight = title:search("fig_highlight")
  local fig_hover = title:search("fig_hover")
  if msg == ui.mouse_inner then
    if fig_highlight.visible == false then
      fig_hover.visible = true
    else
      fig_hover.visible = false
    end
  elseif msg == ui.mouse_outer then
    fig_hover.visible = false
  end
end
function on_item_sel(item, sel)
  if item.depth ~= 2 then
    return
  end
  if sel then
    item.title:search("fig_hover").visible = false
  end
  if not sel then
    detail_clear()
    return
  end
  variety = item.svar.make_variety
  for i = 0, 3 do
    local id = variety.reg_id[i]
    if id ~= 0 then
      local c = w_detail:search("mat_reg_" .. i)
      ui_cell.set(c, id, variety.reg_num[i])
    end
  end
  local t_ref_var = variety.raw_var
  local raw_prt = w_detail:search("raw_mat_con")
  for j = 0, t_ref_var.size - 1 do
    local r_variety = bo2.gv_refine_variety:find(t_ref_var[j])
    if r_variety == nil then
      r_variety = bo2.gv_refine_med_variety:find(t_ref_var[j])
    end
    local txt_raw = sys.format("[%s]", r_variety.name)
    local lb_raw = ui.create_control(raw_prt, "label")
    lb_raw:load_style("$frame/npcfunc/make.xml", "lb_raw_var")
    lb_raw.text = txt_raw .. "x" .. variety.raw_var_count
    lb_raw.svar.ref_id = t_ref_var[j]
  end
  w_detail:search("lb_money").money = variety.money
end
function do_product_update()
  local item = w_variety_view.item_sel
  if item == nil then
    return
  end
  local c = w_detail:search("product")
  w_btn_make.enable = false
  ui_cell.clear(c)
  local info = w_detail:search("mat_raw"):search("card").info
  if info == nil or info.excel_id == 0 then
    w_detail:search("mat_raw"):search("lb_item").text = L("")
    return
  end
  local variety = item.svar.make_variety
  if is_raw_var(info.excel.variety, variety.raw_var) == false then
    return
  end
  local inc_items = variety.inc_items
  local size = inc_items.size
  if size > 0 then
    local id = 0
    local level = info.excel.varlevel
    if size > level then
      id = inc_items[level]
    else
      id = inc_items[size - 1]
    end
    if id == 0 then
      return
    end
    ui_cell.set(c, id)
  end
  for i = 0, 3 do
    local id = variety.reg_id[i]
    if id ~= 0 then
      local c = ui.item_get_count(id, true)
      if c < variety.reg_num[i] then
        return
      end
    end
  end
  w_btn_make.enable = true
end
function post_product_update()
  w_variety_view:insert_post_invoke(do_product_update, "ui_npcfunc.ui_make.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  local c = ui_cell.top_of(card)
  if c.name == L("product") then
    return
  end
  post_product_update()
end
function on_mat_raw_change()
  post_product_update()
end
local item_type_affix = 902
local color_error = ui.make_color("ff0000")
local color_normal = ui.make_color("00DC00")
function find_affix_line(item_id)
  for i = 0, bo2.gv_enchant_property.size - 1 do
    local line = bo2.gv_enchant_property:get(i)
    if line.item_id == item_id then
      return line
    end
  end
end
function on_lb_raw_tip_show(tip)
  local owner = tip.owner
  local stk = sys.mtf_stack()
  local ref_id = owner.svar.ref_id
  local txt_show = bo2.gv_refine_variety:find(ref_id).tip
  stk:raw_format("%s", txt_show)
  ui_tool.ctip_show(owner, stk)
end
function on_mat_affix_change()
  local item_sel = w_variety_view.item_sel
  if item_sel == nil then
    return
  end
  local cell_affix = w_detail:search("mat_affix")
  local card = cell_affix:search("card")
  local lb_desc = w_detail:search("lb_affix_range")
  if lb_desc == nil then
    return
  end
  if card.excel_id == 0 then
    lb_desc.text = L("")
    cell_affix:search("lb_item").text = L("")
    return
  end
  local item_type = card.excel.type
  if item_type ~= item_type_affix then
    lb_desc.color = color_error
    lb_desc.text = ui.get_text("npcfunc|make_not_enchant_item")
    return
  end
  local affix_excel = find_affix_line(card.excel_id)
  if affix_excel == nil then
    return
  end
  if affix_excel.req_level < item_sel.svar.make_variety.reqlevel then
    lb_desc.color = color_error
    lb_desc.text = ui.get_text("npcfunc|make_not_enchant_level")
    return
  end
  local equip_type = item_sel.svar.make_variety.type
  local equip_slot = bo2.gv_item_type:find(equip_type).equip_slot
  local req_slot = false
  for j = 0, affix_excel.equip_slot.size - 1 do
    if affix_excel.equip_slot[j] == equip_slot then
      req_slot = true
      break
    end
  end
  if req_slot == false then
    lb_desc.color = color_error
    lb_desc.text = ui.get_text("npcfunc|make_not_enchant_slot")
    return
  end
  local trait_list_id = affix_excel.trait_list_id
  local trait_excel_tmp = bo2.gv_trait_list:find(trait_list_id[0])
  local property_name = bo2.gv_modify_player:find(trait_excel_tmp.modify_id).name
  local property_min = trait_excel_tmp.modify_value
  local property_max = trait_excel_tmp.modify_value
  for i = 1, trait_list_id.size - 1 do
    local trait_excel = bo2.gv_trait_list:find(trait_list_id[i])
    if property_min > trait_excel.modify_value then
      property_min = trait_excel.modify_value
    end
    if property_max < trait_excel.modify_value then
      property_max = trait_excel.modify_value
    end
  end
  lb_desc.color = color_normal
  lb_desc.text = property_name .. " " .. property_min .. "-" .. property_max
end
function on_visible(w, vis)
  if vis then
    do_init()
  end
  ui_npcfunc.on_visible(w, vis)
  if vis == false then
    detail_clear()
    w_variety_view:clear_selection()
    w_btn_limit.check = true
  end
end
function update_view()
  if w_main.svar.make_data_init == nil then
    return
  end
  local check = w_btn_limit.check
  local level = ui_personal.ui_equip.safe_get_player():get_atb(bo2.eAtb_Level)
  local root = w_variety_view.root
  for i = 0, root.item_count - 1 do
    local node = root:item_get(i)
    for k = 0, node.item_count - 1 do
      local leaf = node:item_get(k)
      if check then
        local lv = leaf.svar.make_variety.reqlevel
        if level < lv or lv < level - 10 then
          leaf.selected = false
          leaf.display = false
        else
          leaf.display = true
        end
        local pro_id = ui_personal.ui_equip.safe_get_player():get_atb(bo2.eAtb_Cha_Profession)
        if pro_id == 0 then
          return
        end
        local requires = leaf.svar.make_variety.requires
        local career = bo2.gv_profession_list:find(pro_id).career
        local damage = bo2.gv_profession_list:find(pro_id).damage
        local dmg = leaf.svar.make_variety.damage
        if damage == dmg and leaf.display then
          leaf.display = true
        else
          leaf.selected = false
          leaf.display = false
        end
        if requires ~= 0 and requires[0] == 1 then
          if leaf.display and career == requires[1] then
            leaf.display = true
          else
            leaf.selected = false
            leaf.display = false
          end
        end
      else
        leaf.display = true
      end
    end
  end
end
function on_limit_check(btn, check)
  update_view()
end
function item_rbutton_tip(info)
  local item = w_variety_view.item_sel
  if item == nil then
    return nil
  end
  local variety = item.svar.make_variety
  if is_raw_var(info.excel.variety, variety.raw_var) == true then
    return ui.get_text("npcfunc|make_rclick_for_mat")
  end
  if info.excel.type == item_type_affix then
    return ui.get_text("npcfunc|make_rclick_for_enchant")
  end
  return nil
end
function item_rbutton_check(info)
  local txt = item_rbutton_tip(info)
  return txt ~= nil
end
function item_rbutton_use(info)
  local item = w_variety_view.item_sel
  if item == nil then
    return nil
  end
  local variety = item.svar.make_variety
  if is_raw_var(info.excel.variety, variety.raw_var) == true then
    ui_cell.drop(w_mat_raw, info)
    local card = w_mat_raw:search(L("card"))
    card.require_count = variety.raw_var_count
    return
  end
  if info.excel.type == item_type_affix then
    ui_cell.drop(w_mat_affix, info)
    return
  end
end
local group_wq = ui.get_text("npcfunc|make_group_wq")
local group_fj = ui.get_text("npcfunc|make_group_fj")
local group_sp = ui.get_text("npcfunc|make_group_sp")
local group_qt = ui.get_text("npcfunc|make_group_qt")
local variety_group = {
  [93] = group_wq,
  [94] = group_wq,
  [95] = group_wq,
  [96] = group_wq,
  [97] = group_wq,
  [98] = group_wq,
  [99] = group_wq,
  [100] = group_wq,
  [112] = group_wq,
  [113] = group_wq,
  [114] = group_wq,
  [115] = group_wq,
  [116] = group_wq,
  [117] = group_wq,
  [118] = group_wq,
  [119] = group_wq,
  [120] = group_wq,
  [121] = group_wq,
  [103] = group_fj,
  [104] = group_fj,
  [105] = group_fj,
  [106] = group_fj,
  [107] = group_fj,
  [151] = group_fj,
  [152] = group_fj,
  [153] = group_fj,
  [154] = group_fj,
  [101] = group_sp,
  [102] = group_sp,
  [108] = group_sp,
  [109] = group_sp,
  [110] = group_sp,
  [111] = group_sp
}
function build_node(variety)
  local t = variety.type
  if t == 0 then
    return nil
  end
  local g = variety_group[t]
  if g == nil then
    g = group_qt
  end
  local item, inst = ui_tree2.insert(w_variety_view.root, g, true)
  if inst then
    item.svar.item_group = g
    item.expanded = false
    ui_tree2.set_text(item, g)
  end
  return item
end
function build_leaf(variety, node)
  local level = variety.reqlevel
  local item = ui_tree2.insert(node, level)
  item.svar.make_variety = variety
  local title = item.title
  title:search("lb_text").text = variety.name
  title:search("lb_level").text = "lv." .. level
end
function do_init()
  local svar = w_main.svar
  if svar.make_data_init ~= nil then
    return
  end
  svar.make_data_init = true
  for k = 0, bo2.gv_make_variety.size - 1 do
    local variety = bo2.gv_make_variety:get(k)
    if variety.disable == 0 then
      local node = build_node(variety)
      if node ~= nil then
        build_leaf(variety, node)
      end
    end
  end
  update_view()
  ui_item.insert_rbutton_data(w_main, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
function on_init(ctrl)
end
function on_tip_show_product(tip)
  local card_base = w_mat_raw:search(L("card"))
  if not sys.check(card_base) then
    return false
  end
  local info_base = card_base.info
  if not sys.check(info_base) then
    return false
  end
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    return false
  end
  local stk = sys.mtf_stack()
  local item = w_variety_view.item_sel
  if item == nil then
    return false
  end
  local make_var = item.svar.make_variety
  if not is_raw_var(info_base.excel.variety, make_var.raw_var) then
    return false
  end
  local inc_items = variety.inc_items
  local size = inc_items.size
  if size > 0 then
    do
      local id = 0
      local level = excel.varlevel
      if size > level then
        id = inc_items[level]
      else
        id = inc_items[level - 1]
      end
      if id == 0 then
        return false
      end
      local bound = info_base:get_data_8(bo2.eItemByte_Bound)
      local copy_base = {}
      copy_base[bo2.eItemByte_Bound] = bound
      copy_base[bo2.eItemByte_Star] = 0
      local copy_flag32 = {}
      copy_flag32[bo2.eItemUInt32_EnchantEquipRawExcelID] = info_base.excel_id
      copy_flag32[bo2.eItemUInt32_CurWearout] = 300
      copy_flag32[bo2.eItemUInt32_MaxWearout] = 300
      local prefix_name = L("")
      local trait_id = 0
      for i = 0, bo2.gv_enchant_property.size - 1 do
        local en_pro = bo2.gv_enchant_property:get(i)
        local is_found = false
        for j = 0, en_pro.raw_item_id.size - 1 do
          if info_base.excel_id == en_pro.raw_item_id[j] then
            prefix_name = en_pro.prefix_name
            trait_id = en_pro.org_trait_id[0]
            is_found = true
          end
        end
        if is_found then
          break
        end
      end
      copy_flag32[bo2.eItemUInt32_EnchantBeg] = trait_id
      local info = {
        name = prefix_name .. excel.name,
        box = bo2.eItemBox_BagBeg,
        get_data_8 = function(info, val)
          if copy_base[val] ~= nil then
            return copy_base[val]
          end
          return 0
        end,
        star = 0,
        get_data_s = function()
          return L("")
        end,
        get_data_32 = function(info, val)
          if copy_flag32[val] ~= nil then
            return copy_flag32[val]
          end
          return 0
        end,
        get_identify_state = function()
          return bo2.eIdentifyEquip_Ready
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
  end
end
function do_product_updatet()
  local item = w_variety_view.item_sel
  if item == nil then
    return
  end
  local variety = item.svar.make_variety
  if is_raw_var(info.excel.variety, variety.raw_var) == false then
    return
  end
  local inc_items = variety.inc_items
  local size = inc_items.size
  if size > 0 then
    local id = 0
    local level = info.excel.varlevel
    if size > level then
      id = inc_items[level]
    else
      id = inc_items[size - 1]
    end
    if id == 0 then
      return
    end
    ui_cell.set(c, id)
  end
  for i = 0, 3 do
    local id = variety.reg_id[i]
    if id ~= 0 then
      local c = ui.item_get_count(id, true)
      if c < variety.reg_num[i] then
        return
      end
    end
  end
  w_btn_make.enable = true
end
function on_self_enter(obj, msg)
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Level, on_level, "ui_make:on_level")
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_make:on_self_enter")
