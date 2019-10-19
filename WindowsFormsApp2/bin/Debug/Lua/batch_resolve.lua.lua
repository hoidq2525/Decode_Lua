local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
local g_item_count = 0
local DefItemNumMax = 14
function on_npcfunc_open_window(npcfunc_id)
end
function do_update()
  local num = 0
  for i = 0, DefItemNumMax - 1 do
    local cell = w_item_list:search("cell" .. i)
    if cell:search("card").info ~= nil then
      num = num + 1
    end
  end
  g_item_count = num
  w_btn_mk.enable = false
  if g_item_count > 0 then
    w_btn_mk.enable = true
  end
end
function check_decompose(info)
  local box = info.box
  if box < bo2.eItemBox_BagBeg or box > bo2.eItemBox_Quest then
    return false
  end
  local excel = info.excel
  local d = bo2.gv_item_decompose:find(excel.id)
  if d == nil or size_id == 0 then
    return false
  end
  local size_id = d.v_item_rands.size
  if size_id == 0 then
    return false
  end
  for i = 0, size_id - 1 do
    local r = bo2.gv_item_rand:find(d.v_item_rands[i])
    if r == nil then
      return false
    end
  end
  return true
end
function is_in_slot_equip(group, info)
  local box = info.box
  if box == bo2.eItemArray_InSlot and (group == bo2.eItemGroup_Equip or group == eItemGroup_Avata) then
    return true
  end
  if box >= bo2.eItemBox_RidePetBegin and box < bo2.eItemBox_RidePetEnd then
    return true
  end
  return false
end
function get_cur_traits_count(info)
  local s1 = 0
  for i = bo2.eItemUInt32_IdentTraitBeg, bo2.eItemUInt32_IdentTraitEnd - 1 do
    local v = info:get_data_32(i)
    if v then
      s1 = s1 + 1
    end
  end
  return s1
end
function identify_equip_finished(info)
  local t_stars = info:get_data_8(bo2.eItemByte_Star)
  local cur_holes = info:get_data_8(bo2.eItemByte_Holes)
  local t_holes = info:get_data_8(bo2.eItemByte_HolesTotle)
  local s1 = get_cur_traits_count(info)
  local cur_stars = s1 + 1
  local excel = info.excel
  if excel then
    if excel.ass_upgrade.size > 0 then
      local ass_upgrade_id = info:get_data_8(bo2.eItemByte_AssUpgradeID)
      if ass_upgrade_id <= 0 then
        if excel.ptype ~= 0 and excel.ptype.equip_slot ~= bo2.eItemSlot_RidePetWeapon then
          if 0 < excel.ass_id then
            return false
          end
        else
          return false
        end
      end
    end
    if excel.ptype and excel.ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
      local nSkillCount = info:get_data_32(bo2.eItemUInt32_RideFightSkillSlot)
      if nSkillCount == 0 and excel.ridepet_identify ~= 0 then
        return false
      end
    end
    if excel.ident_star ~= 0 then
      if t_stars <= 0 then
        return false
      else
        if t_stars > cur_stars then
          return false
        end
        if cur_holes < t_holes then
          return false
        end
      end
    elseif excel.identifypunch ~= 0 and cur_holes < t_holes then
      return false
    end
  end
  return true
end
function item_get_star(info, excel)
  local star = info:get_data_8(bo2.eItemByte_Star)
  if star == 0 then
    return excel.fix_star
  end
  if excel.ptype.equip_slot == bo2.eItemSlot_2ndWeapon then
    return star
  end
  if excel.ptype.equip_slot == bo2.eItemSlot_HWeapon then
    return star
  end
  local s1 = 0
  for i = bo2.eItemUInt32_IdentTraitBeg, bo2.eItemUInt32_IdentTraitEnd - 1 do
    local v = info:get_data_32(i)
    if v then
      s1 = s1 + 1
    end
  end
  local s2 = excel.indie_traits.size
  star = s1 + s2 + 1
  return star
end
function check_resolve(info)
  local excel_id = info.excel_id
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel == nil then
    excel = bo2.gv_item_list:find(info.excel_id)
  end
  if excel == nil then
    ui_chat.show_ui_text_id(19096)
    return false
  end
  local ptype = excel.ptype
  if ptype == nil then
    return false
  end
  local group = ptype.group
  if group == bo2.eItemGroup_Equip then
    if excel.unresolve == 1 then
      ui_chat.show_ui_text_id(19110)
      return false
    end
    if is_in_slot_equip(group, info) then
      ui_chat.show_ui_text_id(19094)
      return false
    end
    local star = info:get_data_8(bo2.eItemByte_Star)
    if excel.ident_star ~= 0 and istar == 0 then
      ui_chat.show_ui_text_id(19095)
      return false
    end
    if not identify_equip_finished(info) then
      ui_chat.show_ui_text_id(19095)
      return false
    end
    for i = bo2.eItemUInt32_GemBeg, bo2.eItemUInt32_GemEnd - 1 do
      if info:get_data_32(i) ~= 0 then
        ui_chat.show_ui_text_id(19117)
        return false
      end
    end
    local resolve_excel
    local level = math.modf(excel.reqlevel / 10 + 1)
    local star = item_get_star(info, excel)
    for i = 0, bo2.gv_equip_resolve.size - 1 do
      local e = bo2.gv_equip_resolve:get(i)
      if e.level == level and e.star == star then
        resolve_excel = e
        break
      end
    end
    local resolve_sp = bo2.gv_equip_resolve:find(excel_id)
    if resolve_excel == nil and (resolve_sp == nil or star < resolve_sp.star) then
      ui_chat.show_ui_text_id(10161)
      return false
    end
  else
    local n = bo2.gv_item_list:find(excel_id)
    if n == nil then
      ui_chat.show_ui_text_id(19096)
      return false
    end
    if info.box == bo2.eItemArray_InSlot then
      ui_chat.show_ui_text_id(19094)
      return false
    end
    local excel = bo2.gv_equip_resolve:find(excel_id)
    if excel == nil then
      ui_chat.show_ui_text_id(19096)
      return false
    end
  end
  return true
end
function check_drop(info, num)
  if not check_decompose(info) and not check_resolve(info) then
    return false
  end
  if not check_is_in(info) then
    return false
  end
  if num == 1 and g_item_count >= DefItemNumMax then
    ui_chat.show_ui_text_id(20326)
    return false
  end
  return true
end
function clear_item_list()
  for i = 0, DefItemNumMax - 1 do
    local cell = w_item_list:search("cell" .. i)
    ui_cell.clear(cell.parent)
  end
end
function check_is_in(info)
  for i = 0, DefItemNumMax - 1 do
    local cell = w_item_list:search("cell" .. i)
    if cell:search("card").info ~= nil and info.only_id == cell:search("card").info.only_id then
      ui_chat.show_ui_text_id(20325)
      return false
    end
  end
  return true
end
function set_item_list(pn, info)
  local c_item
  if pn == nil then
    local c_null_num = -1
    for i = 0, DefItemNumMax - 1 do
      local cell = w_item_list:search("cell" .. i)
      if cell:search("card").info == nil then
        c_null_num = i
        break
      end
    end
    if c_null_num ~= -1 then
      c_item = w_item_list:search("cell" .. c_null_num)
    end
  else
    local c_name = pn:search("name")
    if c_name == nil then
      return
    end
    c_item = w_item_list:search("name")
  end
  if c_item then
    ui_cell.clear(c_item.parent)
    ui_cell.drop(c_item.parent, info)
  end
  do_update()
end
function on_equip_mouse(pn, msg, pos, data)
  if msg == ui.mouse_rbutton_click then
    ui_npcfunc.ui_cell.on_card_mouse(pn, msg, pos, data)
    do_update()
  end
end
function on_equip_drop(pn, msg, pos, data)
end
function item_rbutton_use(info)
  if not check_drop(info, 1) then
    return
  end
  set_item_list(nil, info)
end
function on_btn_mk_click()
  local data = sys.variant()
  local item_count = 0
  for i = 0, DefItemNumMax - 1 do
    local only_id = 0
    local cell = w_item_list:search("cell" .. i)
    if cell:search("card").info ~= nil then
      only_id = cell:search("card").info.only_id
    end
    if only_id ~= 0 then
      data:set64(packet.key.item_key + item_count, only_id)
      item_count = item_count + 1
    end
  end
  local function on_msg_callback(m_data)
    if m_data.result ~= 1 then
      return
    end
    if item_count > g_item_count then
      g_item_count = item_count
    end
    data:set(packet.key.talk_excel_id, bo2.eNpcFunc_BatchResolve)
    data:set(packet.key.cmn_count, g_item_count)
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, data)
    clear_item_list()
    g_item_count = 0
    w_btn_mk.enable = false
  end
  local msg = {
    callback = on_msg_callback,
    text = ui.get_text("npcfunc|batch_resolve_confim")
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_visible(w, vis)
  clear_item_list()
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
  g_item_count = 0
  w_btn_mk.enable = false
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|manuf_rclick_to_place")
end
function item_rbutton_check(info)
  return true
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
