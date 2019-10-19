local readd_index = -1
local text_tip = L("")
local cannot_readd_tip = ui.get_text("assistant|cannot_readd_tip")
local right_click_tip = ui.get_text("assistant|right_click_tip")
function item_rbutton_tip(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel == nil then
    return cannot_readd_tip
  end
  local type_excel = bo2.gv_item_type:find(excel.type)
  if type_excel == nil then
    return cannot_readd_tip
  end
  if type_excel.equip_slot ~= bo2.eItemSlot_2ndWeapon then
    return cannot_readd_tip
  end
  local ass_id = excel.ass_id
  if ass_id == 0 then
    return cannot_readd_tip
  end
  local ass_t_excel = bo2.gv_second_equip_template:find(ass_id)
  if ass_t_excel == nil then
    return cannot_readd_tip
  end
  return right_click_tip
end
function item_rbutton_check(info)
  return true
end
function item_rbutton_use(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel == nil then
    ui_tool.note_insert(cannot_readd_tip, L("FF00FF00"))
    return
  end
  local type_excel = bo2.gv_item_type:find(excel.type)
  if type_excel == nil then
    ui_tool.note_insert(cannot_readd_tip, L("FF00FF00"))
    return
  end
  if type_excel.equip_slot ~= bo2.eItemSlot_2ndWeapon then
    ui_tool.note_insert(cannot_readd_tip, L("FF00FF00"))
    return
  end
  local ass_id = excel.ass_id
  if ass_id == 0 then
    ui_tool.note_insert(cannot_readd_tip, L("FF00FF00"))
    return
  end
  ui_npcfunc.ui_cell.drop(g_equip.parent.parent, info)
end
function on_ok()
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_AssReAdd)
  if readd_index ~= -1 then
    v:set64(packet.key.item_key, g_equip.only_id)
    v:set(packet.key.item_key1, readd_index)
    v:set(packet.key.item_key2, g_tool.excel.id)
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  else
    local unable_readd = ui.get_text("assistant|unable_readd")
    ui_tool.note_insert(Lunable_readd, L("FF00FF00"))
  end
  for i = 0, w_pro_list.item_count - 1 do
    local item = w_pro_list:item_get(i)
    local property = item:search("btn_check")
    property.check = false
    readd_index = -1
    readd_ok.enable = false
  end
end
function on_readd_btn_tip(tip)
  if text_tip == L("") then
    return
  end
  ui_widget.tip_make_view(tip.view, text_tip)
end
function on_mouse_lock_pro(btn)
  local click_to_cancel = ui.get_text("assistant|click_to_cancel")
  local click_to_select = ui.get_text("assistant|click_to_select")
  if btn.check then
    text_tip = click_to_cancel
  else
    text_tip = click_to_select
  end
  on_readd_btn_tip(w_pro_tip)
end
function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  if vis == false then
    w_pro_list:item_clear()
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    ui_npcfunc.ui_cmn.money_set(w_money, 0)
    ui_npcfunc.ui_cell.clear(g_tool.parent.parent)
    readd_index = -1
    readd_ok.enable = false
  end
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  g_equip:insert_on_item_only_id(on_card_chg, "ui_assreadd.on_card_chg")
end
function on_card_chg(card, onlyid, info)
  if card.excel_id == 0 then
    ui_npcfunc.ui_cmn.money_set(w_money, 0)
    ui_npcfunc.ui_cell.clear(g_tool.parent.parent)
    readd_ok.enable = false
    return
  end
  local excel = bo2.gv_equip_item:find(card.excel_id)
  if excel == nil then
    ui_tool.note_insert(cannot_readd_tip, L("FF00FF00"))
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    return
  end
  local type_excel = bo2.gv_item_type:find(excel.type)
  if type_excel == nil then
    ui_tool.note_insert(cannot_readd_tip, L("FF00FF00"))
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    return
  end
  if type_excel.equip_slot ~= bo2.eItemSlot_2ndWeapon then
    ui_tool.note_insert(cannot_readd_tip, L("FF00FF00"))
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    return
  end
  local ass_id = excel.ass_id
  if ass_id == 0 then
    ui_tool.note_insert(cannot_readd_tip, L("FF00FF00"))
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    return
  end
  local ass_t_excel = bo2.gv_second_equip_template:find(ass_id)
  if ass_t_excel == nil then
    ui_tool.note_insert(cannot_readd_tip, L("FF00FF00"))
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    return
  end
  w_pro_list:item_clear()
  local level = info:get_data_32(bo2.eItemUInt32_GemEnd + 1)
  for i = bo2.eItemUInt32_IdentTraitBeg, bo2.eItemUInt32_IdentTraitEnd - 1 do
    local id = info:get_data_32(i)
    if id > 0 then
      local trait = bo2.gv_trait_list:find(id)
      if trait ~= nil then
        local desc = trait.desc
        if 0 < desc.size then
          add_property(desc)
        end
      end
    end
  end
  for i = 0, w_pro_list.item_count - 1 do
    local item = w_pro_list:item_get(i)
    local property = item:search("btn_check")
    property.check = false
    readd_index = -1
    readd_ok.enable = false
  end
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
end
function on_btn_lock_pro(btn)
  if not btn.check then
    readd_index = -1
    return
  end
  if readd_index ~= -1 then
    btn.check = false
    local one_each_time = ui.get_text("assistant|one_each_time")
    ui_tool.note_insert(one_each_time, L("FF00FF00"))
  end
  for i = 0, w_pro_list.item_count - 1 do
    local item = w_pro_list:item_get(i)
    local property = item:search("btn_check")
    if property.check then
      readd_index = i
    end
  end
  check_if_can_readd()
end
function check_if_can_readd()
  local info = g_equip.info
  if info == nil then
    return
  end
  local excel = info.excel
  local n = bo2.gv_equip_item:find(excel.id)
  local ass_t_excel = bo2.gv_second_equip_template:find(n.ass_id)
  local prize = ass_t_excel.prop_money_stages
  local item = ass_t_excel.prop_item_stages
  if readd_index == -1 then
    ui_npcfunc.ui_cmn.money_set(w_money, 0)
    ui_npcfunc.ui_cell.clear(g_tool.parent.parent)
  else
    ui_npcfunc.ui_cmn.money_set(w_money, prize[readd_index])
    ui_npcfunc.ui_cell.set(g_tool.parent.parent, item[readd_index], 1)
    local count = ui.item_get_count(item[readd_index], true)
    if count >= 1 then
      readd_ok.enable = true
    else
      readd_ok.enable = false
    end
  end
end
function on_item_count()
  check_if_can_readd()
end
function add_property(name)
  local item_file = "$frame/assistant/assistant.xml"
  local item_style = "property_item"
  local item = w_pro_list:item_append()
  item:load_style(item_file, item_style)
  local property = item:search("btn_check")
  property.text = name
end
