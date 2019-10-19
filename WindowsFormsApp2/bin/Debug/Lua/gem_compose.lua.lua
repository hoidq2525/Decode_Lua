function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  for i = 1, 5 do
    local card = w_main:search("g_gem" .. i)
    ui_npcfunc.clear_card(card)
  end
  for i = 1, 10 do
    local card = w_main:search("r_gem" .. i)
    ui_npcfunc.clear_card(card)
  end
end
function on_ok(ctrl)
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_ComposeGem)
  local keybeg = packet.key.item_key
  for i = 1, 5 do
    local card = w_main:search("g_gem" .. i)
    if card.info ~= nil then
      ui.log("gem onlyid %s", card.only_id)
      v:set64(keybeg, card.only_id)
      keybeg = keybeg + 1
    end
  end
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|gem_com_rclick")
end
function item_rbutton_check(info)
  local excel = bo2.gv_gem_item:find(info.excel_id)
  return excel ~= nil
end
function item_rbutton_use(info)
  for i = 1, 5 do
    local card = w_main:search("g_gem" .. i)
    if card.excel_id == 0 then
      card.only_id = info.only_id
      info:insert_lock(bo2.eItemLock_UI)
      return
    end
  end
end
function on_init(ctrl)
  ui_npcfunc.ui_cmn.succ_rate_set(w_succ_rate, 0)
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  for i = 1, 5 do
    local card = w_main:search("g_gem" .. i)
    card:insert_on_item_only_id(on_card_chg, "ui_gemcompose.on_card_chg")
  end
end
function GetGemByVariety(quality, idx, pGemVar)
  if quality == 0 then
    if idx >= pGemVar.inc_unpolished_gems.size then
      ui_tool.note_insert(ui.get_text("npcfunc|gem_com_no_higher_level"), "ffff0000")
      return 0
    end
    return pGemVar.inc_unpolished_gems[idx]
  elseif quality == 1 then
    if idx >= pGemVar.inc_polished_gems.size then
      ui_tool.note_insert(ui.get_text("npcfunc|gem_com_no_higher_level"), "ffff0000")
      return 0
    end
    return pGemVar.inc_polished_gems[idx]
  end
  return 0
end
function on_card_chg(card, onlyid, info)
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  compose_ok.enable = false
  local num = 0
  local compose_t1 = true
  local compose_t2 = true
  local compose_t3 = true
  local compose_t4 = false
  local compose_t5 = false
  local iVariety = 0
  local iVarLevel = 0
  local type = 0
  local excel_id = 0
  local quality = 0
  local vGems = {}
  for i = 1, 10 do
    local card = w_main:search("r_gem" .. i)
    ui_npcfunc.clear_card(card)
  end
  for i = 1, 5 do
    local card = w_main:search("g_gem" .. i)
    if card.info ~= nil then
      local pGemExcel = bo2.gv_gem_item:find(card.excel_id)
      if pGemExcel ~= nil then
        local pGemVar = bo2.gv_gem_variety:find(pGemExcel.variety)
        if pGemVar == nil then
          ui_tool.note_insert(ui.get_text("npcfunc|gem_com_undef_var"), "ffff0000")
          ui_npcfunc.clear_card(card)
          return
        end
        if excel_id == 0 then
          excel_id = card.excel_id
          iVariety = pGemVar.type
          iVarLevel = pGemExcel.varlevel
          quality = pGemExcel.polished
          vGems[i] = excel_id
          type = pGemVar.gem_type
        else
          if iVarLevel ~= pGemExcel.varlevel then
            ui_tool.note_insert(ui.get_text("npcfunc|gem_com_diff_level"), "ffff0000")
            ui_npcfunc.clear_card(card)
            return
          end
          if excel_id ~= card.excel_id then
            compose_t1 = false
          end
          if iVariety ~= pGemVar.type then
            compose_t2 = false
          end
          if type ~= pGemVar.gem_type then
            compose_t3 = false
          end
          if pGemExcel.polished == 0 then
            quality = 0
          end
          vGems[i] = excel_id
        end
        num = num + 1
      else
        ui_tool.note_insert(ui.get_text("npcfunc|gem_com_place_gem"), "ffff0000")
        ui_npcfunc.clear_card(card)
        return
      end
    end
  end
  if num == 2 then
    compose_t1 = false
    compose_t2 = false
    compose_t3 = false
    compose_t4 = false
    compose_t5 = true
  elseif num == 5 then
    if compose_t1 == false and compose_t2 == false and compose_t3 == false then
      compose_t4 = true
    end
  else
    return
  end
  local pGemCom = bo2.gv_gem_compose:find(iVarLevel)
  if pGemCom == nil then
    ui_tool.note_insert(ui.get_text("npcfunc|gem_com_reach_level_peak"), "ffff0000")
    return
  end
  ui.log("iVariety %s iVarLevel %s quality %s type %s", iVariety, iVarLevel, quality, type)
  if compose_t1 == true then
    local idx = iVarLevel + 1
    local pVar = bo2.gv_gem_variety:find(bo2.gv_gem_item:find(excel_id).variety)
    local iNewGem = GetGemByVariety(quality, idx, pVar)
    w_main:search("r_gem1").excel_id = iNewGem
  elseif compose_t2 == true then
    local idx = iVarLevel + 1
    for i = 0, bo2.gv_gem_variety.size - 1 do
      if bo2.gv_gem_variety:get(i).type == iVariety then
        local iNewGem = GetGemByVariety(quality, idx, bo2.gv_gem_variety:get(i))
        for j = 1, 10 do
          local excel_id = w_main:search("r_gem" .. j).excel_id
          if excel_id == 0 then
            w_main:search("r_gem" .. j).excel_id = iNewGem
            break
          end
        end
      end
    end
  elseif compose_t3 == true then
    local pGemType = bo2.gv_gem_type:find(type)
    if pGemType == nil then
      return
    end
    local idx = iVarLevel + 1
    for i = 1, pGemType.inc_variety_gems.size - 1 do
      local iVariety = pGemType.inc_variety_gems[i]
      local pVar = bo2.gv_gem_variety:find(iVariety)
      local iNewGem = GetGemByVariety(quality, idx, pVar)
      for j = 1, 10 do
        local excel_id = w_main:search("r_gem" .. j).excel_id
        if excel_id == 0 then
          w_main:search("r_gem" .. j).excel_id = iNewGem
          break
        end
      end
    end
  elseif compose_t4 == true then
    local idx = iVarLevel + 1
    local excel_id = idx + 91900
    w_main:search("r_gem1").excel_id = excel_id
  elseif compose_t5 == true then
    local idx = iVarLevel
    local excel_id = idx + 91900
    w_main:search("r_gem1").excel_id = excel_id
  end
  if pGemCom then
    ui_npcfunc.ui_cmn.money_set(w_money, pGemCom.money)
  end
  compose_ok.enable = true
end
