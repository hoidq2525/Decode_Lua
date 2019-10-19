local concise_index = -1
local text_tip = L("")
local cannot_concise_tip = ui.get_text("assistant|cannot_concise_tip")
local rclick_to_concise = ui.get_text("assistant|rclick_to_concise")
function item_rbutton_tip(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel == nil then
    return cannot_concise_tip
  end
  local type_excel = bo2.gv_item_type:find(excel.type)
  if type_excel == nil then
    return cannot_concise_tip
  end
  if type_excel.equip_slot ~= bo2.eItemSlot_2ndWeapon then
    return cannot_concise_tip
  end
  local ass_id = excel.ass_id
  if ass_id == 0 then
    return cannot_concise_tip
  end
  local ass_t_excel = bo2.gv_second_equip_template:find(ass_id)
  if ass_t_excel == nil then
    return cannot_concise_tip
  end
  return rclick_to_concise
end
function item_rbutton_check(info)
  return true
end
function item_rbutton_use(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel == nil then
    ui_tool.note_insert(cannot_concise_tip, L("FF00FF00"))
    return
  end
  local type_excel = bo2.gv_item_type:find(excel.type)
  if type_excel == nil then
    ui_tool.note_insert(cannot_concise_tip, L("FF00FF00"))
    return
  end
  if type_excel.equip_slot ~= bo2.eItemSlot_2ndWeapon then
    ui_tool.note_insert(cannot_concise_tip, L("FF00FF00"))
    return
  end
  local ass_id = excel.ass_id
  if ass_id == 0 then
    ui_tool.note_insert(cannot_concise_tip, L("FF00FF00"))
    return
  end
  ui_npcfunc.ui_cell.drop(g_equip.parent.parent, info)
end
function on_ok()
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_AssConcise)
  if concise_index ~= -1 then
    v:set64(packet.key.item_key, g_equip.only_id)
    v:set(packet.key.item_key2, g_tool.excel.id)
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  else
    local unable_concise = ui.get_text("assistant|unable_concise")
    ui_tool.note_insert(Lunable_concise, L("FF00FF00"))
  end
  for i = 0, w_pro_list.item_count - 1 do
    local item = w_pro_list:item_get(i)
    local concise = item:search("btn_check")
    concise.check = false
    concise_index = -1
    concise_ok.enable = false
  end
end
function on_concise_btn_tip(tip)
  if text_tip == L("") then
    return
  end
  ui_widget.tip_make_view(tip.view, text_tip)
end
function on_mouse_lock_concise(btn)
  local concise_click_to_cancel = ui.get_text("assistant|concise_click_to_cancel")
  local concise_click_to_select = ui.get_text("assistant|concise_click_to_select")
  if btn.check then
    text_tip = concise_click_to_cancel
  else
    text_tip = concise_click_to_select
  end
  on_concise_btn_tip(w_pro_tip)
end
function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  if vis == false then
    w_pro_list:item_clear()
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    ui_npcfunc.ui_cmn.money_set(w_money, 0)
    ui_npcfunc.ui_cell.clear(g_tool.parent.parent)
    concise_index = -1
    concise_ok.enable = false
  end
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  g_equip:insert_on_item_only_id(on_card_chg, "ui_concise.on_card_chg")
end
function on_card_chg(card, onlyid, info)
  if card.excel_id == 0 then
    ui_npcfunc.ui_cmn.money_set(w_money, 0)
    ui_npcfunc.ui_cell.clear(g_tool.parent.parent)
    concise_ok.enable = false
    return
  end
  local excel = bo2.gv_equip_item:find(card.excel_id)
  if excel == nil then
    ui_tool.note_insert(cannot_concise_tip, L("FF00FF00"))
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    return
  end
  local type_excel = bo2.gv_item_type:find(excel.type)
  if type_excel == nil then
    ui_tool.note_insert(cannot_concise_tip, L("FF00FF00"))
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    return
  end
  if type_excel.equip_slot ~= bo2.eItemSlot_2ndWeapon then
    ui_tool.note_insert(cannot_concise_tip, L("FF00FF00"))
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    return
  end
  local ass_id = excel.ass_id
  if ass_id == 0 then
    ui_tool.note_insert(cannot_concise_tip, L("FF00FF00"))
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    return
  end
  local ass_t_excel = bo2.gv_second_equip_template:find(ass_id)
  if ass_t_excel == nil then
    ui_tool.note_insert(cannot_concise_tip, L("FF00FF00"))
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    return
  end
  w_pro_list:item_clear()
  local level = info:get_data_32(bo2.eItemUInt32_GemEnd + 1)
  add_concise("\179\245\188\182\190\171\193\182")
  add_concise("\214\208\188\182\190\171\193\182")
  add_concise("\184\223\188\182\190\171\193\182")
  for i = 0, w_pro_list.item_count - 1 do
    local item = w_pro_list:item_get(i)
    local concise = item:search("btn_check")
    concise.check = false
    concise_index = -1
    concise_ok.enable = false
  end
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
end
function on_btn_lock_concise(btn)
  if not btn.check then
    concise_index = -1
    check_if_can_concise()
    return
  end
  if concise_index ~= -1 then
    btn.check = false
    local concise_one_each_time = ui.get_text("assistant|concise_one_each_time")
    ui_tool.note_insert(concise_one_each_time, L("FF00FF00"))
  end
  for i = 0, w_pro_list.item_count - 1 do
    local item = w_pro_list:item_get(i)
    local concise = item:search("btn_check")
    if concise.check then
      concise_index = i
    end
  end
  check_if_can_concise()
end
function check_if_can_concise()
  local info = g_equip.info
  if info == nil then
    return
  end
  local ass_upgrade = info:get_data_8(bo2.eItemByte_AssUpgradeID)
  if ass_upgrade == 0 then
    return false
  end
  local ass_t_excel = bo2.gv_assistant_upgrade:find(ass_upgrade)
  if ass_t_excel == nil then
    return false
  end
  local prize_excel = bo2.gv_assistant_prize:find(ass_t_excel.prize_id)
  if prize_excel == nil then
    return false
  end
  local prize = prize_excel.concise_prize
  local item = prize_excel.concise_item
  if concise_index == -1 then
    ui_npcfunc.ui_cmn.money_set(w_money, 0)
    ui_npcfunc.ui_cell.clear(g_tool.parent.parent)
    concise_ok.enable = false
  else
    ui_npcfunc.ui_cmn.money_set(w_money, prize)
    ui_npcfunc.ui_cell.set(g_tool.parent.parent, item[concise_index], 3)
    local count = ui.item_get_count(item[concise_index], true)
    if count >= 3 then
      concise_ok.enable = true
    else
      concise_ok.enable = false
    end
  end
end
function on_item_count()
  check_if_can_concise()
end
function add_concise(name)
  local item_file = "$frame/assistant/assistant.xml"
  local item_style = "concise_item"
  local item = w_pro_list:item_append()
  item:load_style(item_file, item_style)
  local concise = item:search("btn_check")
  concise.text = name
end
