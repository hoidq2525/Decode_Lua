function item_rbutton_tip(info)
  local rclick_to_reborn = ui.get_text("assistant|rclick_to_reborn")
  return rclick_to_reborn
end
function item_rbutton_check(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel == nil then
    return false
  end
  local type_excel = bo2.gv_item_type:find(excel.type)
  if type_excel == nil then
    return false
  end
  if type_excel.equip_slot ~= bo2.eItemSlot_2ndWeapon then
    return false
  end
  local ass_id = excel.ass_id
  if ass_id == 0 then
    return false
  end
  local ass_t_excel = bo2.gv_second_equip_template:find(ass_id)
  if ass_t_excel == nil then
    return false
  end
  local prize_excel = bo2.gv_assistant_prize:find(ass_t_excel.prize_id)
  if prize_excel == nil then
    return false
  end
  return true
end
function item_rbutton_use(info)
  ui_npcfunc.ui_cell.drop(g_equip.parent.parent, info)
end
function on_ok()
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_AssReborn)
  v:set64(packet.key.item_key, g_equip.only_id)
  v:set64(packet.key.item_key1, sel_index)
  v:set64(packet.key.item_key2, g_tool.only_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function display_prop(excel, info)
  local root = w_prop_view
  local style_uri = L("$frame/assistant/assistant.xml")
  local style_name_g = L("prop")
  local function insert_prop(text)
    local item_g = root:item_append()
    item_g:load_style(style_uri, style_name_g)
    item_g:search("label").text = text
    return item_g
  end
  root:item_clear()
  if excel == 0 then
    prop_nums = 0
    return
  end
  for i = 0, excel.grow_prop_level.size - 1 do
    local trait_id = info:get_data_32(bo2.eItemUInt32_IdentTraitBeg + i)
    local item
    if trait_id == 0 then
      local unactive = ui.get_text("assistant|unactive")
      item = insert_prop(unactive)
    else
      local trait = bo2.gv_trait_list:find(trait_id)
      local index = i + 1
      local pool_id = excel["prop_pool_stage" .. index][0]
      local pool_excel = bo2.gv_prop_pool:find(pool_id)
      if 0 < trait.desc.size then
        item = insert_prop(trait.desc)
      else
        item = insert_prop(ui_tool.ctip_trait_text_ex(trait.modify_id, trait.modify_value) .. " " .. ui_tool.get_sec_quality(pool_excel, trait_id))
      end
    end
    item.name = "prop" .. i
  end
  prop_nums = excel.grow_prop_level.size - 1
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  sel_prop = nil
  prop_nums = 0
  sel_index = 0
  prize_excel = 0
  g_equip:insert_on_item_only_id(on_card_chg, "ui_assrefine.on_card_chg")
end
function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  sel_prop = nil
  sel_index = 0
  if vis == false then
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    ui_npcfunc.ui_cell.clear(g_tool.parent.parent)
  end
  reborn_ok.enable = false
end
function on_mouse(panel, msg)
  if msg == ui.mouse_enter then
    panel:search("bg").visible = true
  end
  if msg == ui.mouse_leave and panel.name ~= sel_prop then
    panel:search("bg").visible = false
  end
  if msg == ui.mouse_lbutton_down then
    for i = 0, prop_nums do
      local item = w_prop_view:search("prop" .. i)
      item:search("bg").visible = false
      if item.name == panel.name then
        sel_index = i
      end
    end
    if sel_prop == panel.name then
      sel_prop = nil
      reborn_ok.enable = false
      ui_npcfunc.ui_cmn.money_set(w_money, 0)
    else
      sel_prop = panel.name
      panel:search("bg").visible = true
      if g_equip.excel_id ~= 0 and g_tool.excel_id ~= 0 then
        ui_npcfunc.ui_cmn.money_set(w_money, prize_excel.regeneration_prize[sel_index])
        reborn_ok.enable = true
      end
    end
  end
end
function on_card_chg(card, onlyid, info)
  if card.excel_id == 0 then
    ui_npcfunc.ui_cell.clear(g_tool.parent.parent)
    ui_npcfunc.ui_cmn.money_set(w_money, 0)
    reborn_ok.enable = false
    return
  end
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  ui_npcfunc.ui_cell.clear(g_tool.parent.parent)
  reborn_ok.enable = true
  display_prop(0)
  sel_index = 0
  sel_prop = 0
  if info == nil then
    return
  end
  local excel = bo2.gv_equip_item:find(card.excel_id)
  if excel == nil then
    return
  end
  local type_excel = bo2.gv_item_type:find(excel.type)
  if type_excel == nil then
    return
  end
  if type_excel.equip_slot ~= bo2.eItemSlot_2ndWeapon then
    return
  end
  local ass_id = excel.ass_id
  if ass_id == 0 then
    return
  end
  local ass_t_excel = bo2.gv_second_equip_template:find(ass_id)
  if ass_t_excel == nil then
    return
  end
  prize_excel = bo2.gv_assistant_prize:find(ass_t_excel.prize_id)
  if prize_excel == nil then
    return
  end
  display_prop(ass_t_excel, info)
  ui_npcfunc.ui_cell.set(g_tool.parent.parent, prize_excel.regeneration_item, 1)
end
