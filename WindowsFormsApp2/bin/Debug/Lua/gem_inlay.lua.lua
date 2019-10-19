local ITEMGEM_NUM = 4
function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  if vis == false then
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    ui_npcfunc.ui_cell.clear(g_gem.parent.parent)
  end
end
function on_ok()
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_InlayGem)
  v:set64(packet.key.item_key, g_equip.only_id)
  v:set64(packet.key.item_key1, g_gem.only_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function item_rbutton_tip(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel then
    return ui.get_text("npcfunc|gem_inlay_rclick_equip")
  else
    excel = bo2.gv_gem_item:find(info.excel_id)
    if excel then
      return ui.get_text("npcfunc|gem_inlay_rclick_gem")
    end
  end
end
function item_rbutton_check(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel then
    return true
  else
    excel = bo2.gv_gem_item:find(info.excel_id)
    if excel then
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
    excel = bo2.gv_gem_item:find(info.excel_id)
    if excel then
      ui.log("inlay gem use in")
      ui_npcfunc.ui_cell.drop(g_gem, info)
    end
  end
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  g_tool.require_count = 1
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  g_equip:insert_on_item_only_id(on_card_chg, "ui_geminlay.on_card_chg")
  g_gem:insert_on_item_only_id(on_card_chg, "ui_geminlay.on_card_chg")
end
function on_card_chg(card, onlyid, info)
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  ui_npcfunc.ui_cell.clear(g_tool.parent.parent)
  if g_gem.excel_id == 0 then
    ui_npcfunc.ui_cell.clear(g_gem.parent.parent)
  end
  inlay_ok.enable = false
  if g_equip.info ~= nil and g_gem.info ~= nil then
    inlay_ok.enable = true
  end
  if g_gem.info == nil then
    return
  end
  local pGemExcel = bo2.gv_gem_item:find(g_gem.info.excel_id)
  if pGemExcel == nil then
    return
  end
  local pGemVar = bo2.gv_gem_variety:find(pGemExcel.variety)
  if pGemVar == nil then
    return
  end
  local pGemInl = bo2.gv_gem_inlay:find(pGemExcel.varlevel)
  if pGemInl == nil then
    return
  end
  ui_npcfunc.ui_cmn.money_set(w_money, pGemInl.money)
  local tool = pGemInl.tool[0]
  for i = pGemInl.tool.size - 1, 0, -1 do
    local info = ui.item_of_excel_id(pGemInl.tool[i], bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
    if info ~= nil then
      tool = pGemInl.tool[i]
      break
    end
  end
  ui_npcfunc.ui_cell.set(g_tool.parent.parent, tool, 1)
  if g_equip.info == nil then
    return
  end
end
