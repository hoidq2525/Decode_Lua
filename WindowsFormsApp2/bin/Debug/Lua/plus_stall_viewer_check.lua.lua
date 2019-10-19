g_max_check_type = 11
function check_item_type_all()
  return true
end
function check_material(info)
  if info == nil then
    return false
  end
  if info.excel.ptype == nil then
    return false
  end
  local type_idx = info.excel.type
  if type_idx ~= bo2.eItemType_Material and type_idx ~= 353 then
    return false
  end
  return true
end
local g_second_weapon = {}
g_second_weapon[60100] = 1
g_second_weapon[60101] = 1
g_second_weapon[60102] = 1
g_second_weapon[60103] = 1
g_second_weapon[60104] = 1
g_second_weapon[60105] = 1
g_second_weapon[50037] = 1
function check_equip_type(info, type_idx)
  if info == nil then
    return false
  end
  if type_idx == 3 and g_second_weapon[info.excel.id] ~= nil then
    return true
  end
  if sys.is_type(info.excel, ui_tool.cs_tip_mb_data_equip_item) ~= true then
    return false
  end
  local item_type_excel = bo2.gv_item_type:find(info.excel.type)
  if item_type_excel == nil then
    return false
  end
  if type_idx <= 3 then
    local slot = type_idx - 2
    if item_type_excel.equip_slot ~= bo2.eItemSlot_MainWeapon + slot then
      return false
    end
  else
    local equip_slot = item_type_excel.equip_slot
    if equip_slot == bo2.eItemSlot_MainWeapon or equip_slot == bo2.eItemSlot_2ndWeapon then
      return false
    end
    if info.excel.ptype == nil then
      return false
    end
    if info.excel.ptype.group ~= bo2.eItemGroup_Equip then
      return false
    end
  end
  return true
end
local gem_tab = {}
gem_tab[57019] = 1
gem_tab[50300] = 1
function check_is_gem(info)
  if info == nil then
    return false
  end
  if sys.is_type(info.excel, ui_tool.cs_tip_mb_data_gem_item) ~= true then
    local excel_id = info.excel.id
    if excel_id == nil or gem_tab[excel_id] == nil then
      return false
    end
  end
  return true
end
function check_cmn_bag(info)
  if info == nil then
    return false
  end
  if info.excel.type ~= bo2.eItemType_CmnBag then
    return false
  end
  return true
end
function check_scroll(info)
  if info == nil then
    return false
  end
  if info.excel.type ~= bo2.eItemType_Scroll then
    return false
  end
  return true
end
function check_item_idx(info)
  if info == nil then
    return false
  end
  local excel_id = info.excel_id
  if excel_id >= 56001 and excel_id <= 56500 then
    return true
  end
  if excel_id >= 50240 and excel_id <= 50243 then
    return true
  end
  if excel_id >= 50248 and excel_id <= 50254 then
    return true
  end
  if info.excel == nil then
    return false
  end
  if info.excel.ptype == nil then
    return false
  end
  if sys.is_type(info.excel, ui_tool.cs_tip_mb_data_equip_item) ~= true then
    return false
  end
  if info.excel.ptype.group ~= bo2.eItemGroup_Avata then
    return false
  end
  return true
end
function check_item_ride_pet(info)
  if info == nil then
    return false
  end
  if info.excel and info.excel.ptype and info.excel.ptype.group == bo2.eItemGroup_RidePet then
    return true
  end
  if info:is_ridepet() ~= true then
    return false
  end
  return true
end
function process_all_check(info)
  if info == nil then
    return false
  end
  for i = 2, g_max_check_type do
    local tab = g_filter_data.list[i]
    if tab == nil then
      break
    end
    if i ~= 11 and tab.fun and tab.fun ~= process_all_check and tab.fun(info, i) == true then
      return false
    end
  end
  return true
end
function check_low_price(item)
  local name = item.name
  local min_mony = 0
  local max_mony = 0
  local average_mony = 0
  local total_count = 0
  if name ~= nil then
    min_mony, max_mony, average_mony, total_count, cmn_average = get_item_market_statistics(name, item.info)
  end
  local cmn_money = item.money
  if cmn_money == 0 or cmn_money == nil then
    return false
  end
  if cmn_average == 0 then
    cmn_average = calc_cmn_average(name)
  end
  if cmn_average / cmn_money >= 2 then
    return true
  else
    return false
  end
end
