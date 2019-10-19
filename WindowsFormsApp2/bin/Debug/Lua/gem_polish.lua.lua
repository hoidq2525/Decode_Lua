function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  if vis == false then
    ui_npcfunc.ui_cell.clear(g_gem.parent.parent)
    ui_npcfunc.ui_cell.clear(g_tool.parent.parent)
  end
end
function on_ok(ctrl)
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_PolishGem)
  v:set64(packet.key.item_key, g_gem.only_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|gem_pol_rclick")
end
function item_rbutton_check(info)
  local excel = bo2.gv_gem_item:find(info.excel_id)
  return excel ~= nil
end
function item_rbutton_use(info)
  ui_npcfunc.ui_cell.drop(g_gem, info)
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  g_tool.require_count = 1
  ui_npcfunc.ui_cmn.succ_rate_set(w_succ_rate, 0)
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  g_gem:insert_on_item_only_id(on_card_chg, "ui_gempolish.on_card_chg")
end
function on_card_chg(card, onlyid, info)
  ui_npcfunc.ui_cell.clear(g_tool.parent.parent)
  ui_npcfunc.ui_cmn.succ_rate_set(w_succ_rate, 0)
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  polish_ok.enable = false
  if g_gem.excel_id == 0 then
    ui_npcfunc.ui_cell.clear(g_gem.parent.parent)
  end
  if g_gem.excel_id ~= 0 then
    polish_ok.enable = true
  end
  if info == nil then
    return
  end
  local pGemExcel = bo2.gv_gem_item:find(info.excel_id)
  if pGemExcel == nil or pGemExcel.polished == 1 then
    return
  end
  local pGemVar = bo2.gv_gem_variety:find(pGemExcel.variety)
  if pGemVar == nil then
    return
  end
  local pGemPol = bo2.gv_gem_polish:find(pGemExcel.varlevel)
  if pGemPol == nil then
    return
  end
  ui_npcfunc.ui_cmn.money_set(w_money, pGemPol.money)
  local tool = pGemPol.tool[0]
  for i = pGemPol.tool.size - 1, 0, -1 do
    local info = ui.item_of_excel_id(pGemPol.tool[i], bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
    if info ~= nil then
      tool = pGemPol.tool[i]
      break
    end
  end
  ui_npcfunc.ui_cell.set(g_tool.parent.parent, tool, 1)
  ui_npcfunc.ui_cmn.succ_rate_set(w_succ_rate, 1)
end
