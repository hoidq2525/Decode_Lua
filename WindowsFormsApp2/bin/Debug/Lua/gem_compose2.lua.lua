function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  for i = 1, 2 do
    local card = w_main2:search("g_gem" .. i)
    ui_npcfunc.clear_card(card)
  end
  for i = 1, 1 do
    local card = w_main2:search("r_gem" .. i)
    ui_npcfunc.clear_card(card)
  end
end
function on_ok(ctrl)
  local pdt_bd = 0
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_ComposeGem2)
  local keybeg = packet.key.item_key
  for i = 1, 2 do
    local card = w_main2:search("g_gem" .. i)
    if card.info ~= nil then
      v:set64(keybeg, card.only_id)
      keybeg = keybeg + 1
      local src_bd = card.info:get_data_8(bo2.eItemByte_Bound)
      if src_bd == 1 then
        pdt_bd = 1
      end
    end
  end
  if pdt_bd == 1 then
    local function on_msg_callback(msg_call)
      if msg_call.result ~= 1 then
        return
      end
      bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
    end
    local text_show = ui.get_text("npcfunc|gem_com_bd_hint")
    local msg = {callback = on_msg_callback, text = text_show}
    ui_widget.ui_msg_box.show_common(msg)
  else
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  end
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|gem_com_rclick")
end
function item_rbutton_check(info)
  local excel = bo2.gv_gem_item:find(info.excel_id)
  return excel ~= nil
end
function item_rbutton_use(info)
  for i = 1, 2 do
    local card = w_main2:search("g_gem" .. i)
    if card.excel_id == 0 then
      card.only_id = info.only_id
      local check_all = false
      if 1 >= info.count then
        check_all = true
      elseif info.count == 2 then
        for i = 1, 2 do
          local card = w_main2:search("g_gem" .. i)
          if card.info == nil or card.only_id ~= info.only_id then
            check_all = false
          end
        end
      end
      if check_all == true then
        info:insert_lock(bo2.eItemLock_UI)
      end
      return
    end
  end
end
function on_init(ctrl)
  ui_npcfunc.ui_cmn.succ_rate_set(w_succ_rate, 0)
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  for i = 1, 2 do
    local card = w_main2:search("g_gem" .. i)
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
  local compose_t5 = false
  local iVariety = 0
  local iVarLevel = 0
  local type = 0
  local excel_id = 0
  local quality = 0
  local vGems = {}
  for i = 1, 1 do
    local card = w_main2:search("r_gem" .. i)
    ui_npcfunc.clear_card(card)
  end
  local vGems_key = {}
  for i = 1, 2 do
    local card = w_main2:search("g_gem" .. i)
    if card.info ~= nil then
      local info_id = card.info.only_id
      if vGems_key[info_id] == nil then
        vGems_key[info_id] = 1
      else
        vGems_key[info_id] = vGems_key[info_id] + 1
        if card.info.count < vGems_key[info_id] then
          ui_npcfunc.clear_card(card)
          return
        end
      end
      local pGemExcel = bo2.gv_gem_item:find(card.excel_id)
      if pGemExcel ~= nil then
        local pGemVar = bo2.gv_gem_variety:find(pGemExcel.variety)
        if pGemVar == nil then
          ui_tool.note_insert(ui.get_text("npcfunc|gem_com_undef_var"), "ffff0000")
          ui_npcfunc.clear_card(card)
          return
        end
        if pGemVar.no_compose_gem_two ~= 0 then
          ui_tool.note_insert(ui.get_text("npcfunc|gem_com_invalid"), "ffff0000")
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
    compose_t5 = true
  else
    return
  end
  local pGemCom = bo2.gv_gem_compose:find(iVarLevel)
  if pGemCom == nil then
    ui_tool.note_insert(ui.get_text("npcfunc|gem_com_reach_level_peak"), "ffff0000")
    return
  end
  if compose_t5 == true then
    local pdt_bound = false
    for i = 1, 2 do
      local card = w_main2:search("g_gem" .. i)
      if card.info ~= nil then
        local src_bd = card.info:get_data_8(bo2.eItemByte_Bound)
        if src_bd == 1 then
          pdt_bound = true
        end
      end
    end
    local idx = iVarLevel
    local excel_id = 0
    if pdt_bound then
      excel_id = idx + 91930
    else
      excel_id = idx + 91900
    end
    w_main2:search("r_gem1").excel_id = excel_id
  end
  if pGemCom then
    ui_npcfunc.ui_cmn.money_set(w_money, pGemCom.money)
  end
  compose_ok.enable = true
end
