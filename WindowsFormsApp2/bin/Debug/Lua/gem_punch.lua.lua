local ITEMGEM_NUM = 4
function item_rbutton_tip(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel then
    return ui.get_text("npcfunc|gem_punch_rclick")
  else
    excel = bo2.gv_item_list:find(info.excel_id)
    if excel and (excel.type == bo2.eItemType_NormPuncher or excel.type == bo2.eItemType_ExtrPuncher) then
      return ui.get_text("npcfunc|gem_punch_rclick_for_tool")
    end
  end
end
function item_rbutton_check(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel then
    return true
  else
    excel = bo2.gv_item_list:find(info.excel_id)
    if excel and (excel.type == bo2.eItemType_NormPuncher or excel.type == bo2.eItemType_ExtrPuncher) then
      return true
    end
  end
  return false
end
function item_rbutton_use(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel then
    ui_npcfunc.ui_cell.drop(g_equip, info)
  else
    excel = bo2.gv_item_list:find(info.excel_id)
    if excel and (excel.type == bo2.eItemType_NormPuncher or excel.type == bo2.eItemType_ExtrPuncher) then
      ui_npcfunc.ui_cell.drop(g_tool, info)
    end
  end
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  g_tool.require_count = 1
  ui_npcfunc.ui_cmn.succ_rate_set(w_succ_rate, 0)
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  g_equip:insert_on_item_only_id(on_card_chg, "ui_gempunch.on_card_chg")
  g_tool:insert_on_item_only_id(on_card_chg, "ui_gempunch.on_card_chg")
end
function on_card_chg(card, onlyid, info)
  ui_npcfunc.ui_cmn.succ_rate_set(w_succ_rate, 0)
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  punch_ok.enable = false
  if info == nil then
    ui_npcfunc.ui_cell.clear(card.parent.parent)
    return
  end
  if g_equip.info ~= nil and g_tool.info ~= nil then
    punch_ok.enable = true
  end
  if g_equip.info == nil or g_tool.info == nil then
    return
  end
  local pEquExcel = bo2.gv_equip_item:find(g_equip.info.excel_id)
  if pEquExcel == nil then
    return
  end
  local iPunId = math.floor((pEquExcel.reqlevel + 10) / 10)
  local pEquPun = bo2.gv_equip_punch:find(iPunId)
  if pEquPun == nil then
    return
  end
  local holes = g_equip.info:get_data_8(bo2.eItemByte_Holes)
  if holes >= pEquPun.max_num then
    return
  end
  if holes < ITEMGEM_NUM then
    ui_npcfunc.ui_cmn.succ_rate_set(w_succ_rate, pEquPun.prob[holes] / 1000000)
    ui_npcfunc.ui_cmn.money_set(w_money, pEquPun.money)
  end
end
function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  if vis == false then
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    ui_npcfunc.ui_cell.clear(g_tool.parent.parent)
  end
end
function on_ok()
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_PunchEquip)
  v:set64(packet.key.item_key, g_equip.only_id)
  v:set64(packet.key.item_key1, g_tool.only_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
