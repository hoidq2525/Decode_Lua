local quick_buy_item = {51207, 51205}
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  w_equip_target:insert_on_item_only_id(on_target_onlyid, "ui_ridepet_exp.on_target_onlyid")
  w_equip_material:insert_on_item_only_id(on_material_onlyid, "ui_ridepet_exp.on_material_onlyid")
  for _, id in ipairs(quick_buy_item) do
    local goods_id = ui_supermarket2.shelf_quick_buy_id(id)
    if goods_id > 0 then
      w_material_quick_buy.visible = true
      w_material_quick_buy.name = goods_id
      break
    end
  end
end
function item_rbutton_check(info)
  if info == nil then
    return false
  end
  local excel = info.excel
  if excel == nil then
    return false
  end
  local ptype = excel.ptype
  if ptype == nil then
    return false
  end
  if ptype.id == bo2.eItemtype_ReMake then
    return true
  end
  if ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
    return true
  end
  return false
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
  if ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
    ui_npcfunc.ui_ridepet_cmn.drop(w_equip_target, info)
  end
  if ptype.id == bo2.eItemtype_ReMake then
    ui_npcfunc.ui_cell.drop(w_equip_material, info)
  end
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|ridepet_weapon_rclick_to_place")
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  if vis == false then
    ui_npcfunc.ui_ridepet_cmn.clear(w_equip_target)
    ui_npcfunc.ui_ridepet_cmn.clear(w_equip_preview)
    ui_npcfunc.ui_cell.clear(w_equip_material.parent.parent)
    ui.item_mark_show("ridepet_weapon_level_up", false)
  else
    ui.item_mark_show("ridepet_weapon_level_up", true)
  end
end
function on_target_onlyid(card, onlyid, info)
end
function on_material_onlyid(card, onlyid, info)
  if info == nil then
    ui_widget.ui_count_box.set_range(w_count_box, 0, 0)
  else
    ui_widget.ui_count_box.set_range(w_count_box, 1, info.count)
  end
end
function on_timer_ui()
  on_update_preview()
end
function is_ready()
  if w_equip_target.info == nil then
    return false
  end
  local info = w_equip_material.info
  if info == nil then
    return false
  end
  local excel = info.excel
  if excel == nil then
    return false
  end
  if excel.type ~= bo2.eItemtype_ReMake then
    return false
  end
  if excel.datas.size ~= 1 then
    return false
  end
  local idx = excel.datas[0]
  local ridepet_exp_excel = bo2.gv_equip_ridepet_exp:find(idx)
  if ridepet_exp_excel == nil then
    return false
  end
  return true
end
function get_level_exp_expmax_money()
  local cur_level = w_equip_target.info:get_data_32(bo2.eItemUInt32_SecondLevel)
  local cur_exp = w_equip_target.info:get_data_32(bo2.eItemUInt32_SecondExp)
  local player_level = bo2.player:get_atb(bo2.eAtb_Level)
  local upgrade_id = w_equip_target.info:get_data_8(bo2.eItemByte_AssUpgradeID)
  if upgrade_id == 0 or cur_level >= player_level then
    local excel = bo2.gv_assistant_level:find(cur_level)
    return cur_level, cur_exp, excel.exp[0], 0
  end
  local idx = w_equip_material.info.excel.datas[0]
  local ridepet_exp_excel = bo2.gv_equip_ridepet_exp:find(idx)
  local count = ui_widget.ui_count_box.get_value(w_count_box)
  local money = ridepet_exp_excel.nMoney * count
  local exp = ridepet_exp_excel.nExp * count
  cur_exp = cur_exp + exp
  local ass_upgrade_id = w_equip_target.info:get_data_8(bo2.eItemByte_AssUpgradeID)
  if ass_upgrade_id > 0 then
    local ae = bo2.gv_assistant_upgrade:find(ass_upgrade_id)
    while true do
      if ae ~= nil then
        local excel = bo2.gv_assistant_level:find(cur_level)
        if cur_level >= player_level then
          local excel = bo2.gv_assistant_level:find(cur_level)
          return cur_level, cur_exp, excel.exp[ae.exp_id], money
        end
        if cur_exp >= excel.exp[ae.exp_id] then
          cur_level = cur_level + 1
          cur_exp = cur_exp - excel.exp[ae.exp_id]
        else
          return cur_level, cur_exp, excel.exp[ae.exp_id], money
        end
      end
    end
  end
end
function on_tip_show(tip)
  local card = tip.owner:search("card")
  local info = card.info
  local level = info:get_data_32(bo2.eItemUInt32_SecondLevel)
  local cur_exp = info:get_data_32(bo2.eItemUInt32_SecondExp)
  local level1, cur_exp1, exp_max, money = get_level_exp_expmax_money()
  info:set_data_32(bo2.eItemUInt32_SecondLevel, level1)
  info:set_data_32(bo2.eItemUInt32_SecondExp, cur_exp1)
  if level ~= level1 then
    local ass_upgrade_id = info:get_data_8(bo2.eItemByte_AssUpgradeID)
    local temp_excel = bo2.gv_assistant_upgrade:find(ass_upgrade_id)
    if temp_excel ~= nil then
      local nMin = 0
      local nMax = 0
      for n = level + 1, level1 do
        if n % 5 == 0 then
          nMin = nMin + temp_excel.up_min_5
          nMax = nMax + temp_excel.up_max_5
        else
          nMin = nMin + temp_excel.up_min
          nMax = nMax + temp_excel.up_max
        end
      end
      info:set_xdata_32(bo2.eItemXData32_GrowPointMin, nMin)
      info:set_xdata_32(bo2.eItemXData32_GrowPointMax, nMax)
    end
  end
  ui_npcfunc.ui_cell.on_tip_show(tip)
  info:set_xdata_32(bo2.eItemXData32_GrowPointMin, 0)
  info:set_xdata_32(bo2.eItemXData32_GrowPointMax, 0)
  info:set_data_32(bo2.eItemUInt32_SecondLevel, level)
  info:set_data_32(bo2.eItemUInt32_SecondExp, cur_exp)
end
function on_update_preview()
  if is_ready() then
    ui_npcfunc.ui_ridepet_cmn.drop(w_equip_preview, w_equip_target.info)
    local level, exp, exp_max, money = get_level_exp_expmax_money()
    local equip_card = w_equip_preview.parent.parent.parent.parent
    equip_card:search("level").text = level
    equip_card:search("exp_text").text = exp .. "/" .. exp_max
    local value = exp / exp_max
    value = math.min(value, 1)
    equip_card:search("exp_cur").dx = value * 85
    w_money.money = money
    w_btn_ok.enable = true
  else
    ui_npcfunc.ui_ridepet_cmn.clear(w_equip_preview)
    w_money.money = 0
    w_btn_ok.enable = false
  end
end
function on_btn_ok()
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_RidePetWeaponAddExp)
  v:set64(packet.key.item_key, w_equip_target.info.only_id)
  v:set(packet.key.item_key1, w_equip_material.info.excel_id)
  v:set(packet.key.item_key2, ui_widget.ui_count_box.get_value(w_count_box))
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  ui_npcfunc.ui_ridepet_cmn.clear(w_equip_target)
  ui_npcfunc.ui_ridepet_cmn.clear(w_equip_preview)
  ui_npcfunc.ui_cell.clear(w_equip_material.parent.parent)
end
function on_material_drop(pn, msg, pos, data)
  if ui_npcfunc.ui_cell.check_drop(pn, msg, pos, data) == false then
    return
  end
  local info = ui.item_of_only_id(data:get("only_id"))
  if info.excel.type ~= bo2.eItemtype_ReMake then
    ui_safe.notify(5491)
    return
  end
  ui_npcfunc.ui_cell.drop(pn, info)
end
