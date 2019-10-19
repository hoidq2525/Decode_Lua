local ui_cell = ui_npcfunc.ui_cell
function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  for i = 1, 5 do
    local card = w_main5:search("g_gem" .. i)
    ui_npcfunc.clear_card(card)
  end
  for i = 1, 1 do
    local cell = w_main5:search("r_gem" .. i)
    ui_cell.clear(cell)
  end
end
function on_ok(ctrl)
  local pdt_bd = 0
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_ComposeGem5)
  local keybeg = packet.key.item_key
  for i = 1, 5 do
    local card = w_main5:search("g_gem" .. i)
    if card.info ~= nil then
      v:set64(keybeg, card.only_id)
      keybeg = keybeg + 1
      local src_bd = card.info:get_data_8(bo2.eItemByte_Bound)
      if src_bd == 1 then
        pdt_bd = 1
      end
    end
  end
  local r_gem1 = w_main5:search("r_gem1")
  if pdt_bd == 1 then
    local function on_msg_callback(msg_call)
      if msg_call.result ~= 1 then
        return
      end
      bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
      ui_item.post_card_flash(r_gem1:search("card"))
    end
    local text_show = ui.get_text("npcfunc|gem_com_bd_hint")
    local msg = {callback = on_msg_callback, text = text_show}
    ui_widget.ui_msg_box.show_common(msg)
  else
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
    ui_item.post_card_flash(r_gem1:search("card"))
  end
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|gem_com_rclick")
end
function item_rbutton_check(info)
  local excel = bo2.gv_gem_item:find(info.excel_id)
  return excel ~= nil
end
function update_lock(info)
  if sys.check(info) ~= true then
    return
  end
  local check_all = true
  if info.count <= 1 then
    check_all = true
  elseif info.count <= 5 then
    local info_count = 5
    for i = 1, 5 do
      local card = w_main5:search("g_gem" .. i)
      if card.info == nil or card.only_id ~= info.only_id then
        info_count = info_count - 1
      end
    end
    if info_count >= info.count then
      check_all = true
    else
      check_all = false
    end
  else
    check_all = false
  end
  if check_all == true then
    info:insert_lock(bo2.eItemLock_UI)
  end
end
function item_rbutton_use(info)
  for i = 1, 5 do
    local card = w_main5:search("g_gem" .. i)
    if card.excel_id == 0 then
      card.only_id = info.only_id
      update_lock(info)
      return
    end
  end
end
function on_init(ctrl)
  ui_npcfunc.ui_cmn.succ_rate_set(w_succ_rate, 0)
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  for i = 1, 5 do
    local card = w_main5:search("g_gem" .. i)
    card:insert_on_item_only_id(on_card_chg, "ui_gemcompose.on_card_chg")
  end
end
function GetGemByVariety(var, varlv, bound)
  local item_line
  for kk = 0, bo2.gv_gem_item.size - 1 do
    local line = bo2.gv_gem_item:get(kk)
    if line.variety == var and line.varlevel == varlv then
      if bound == true and line.bound_mode ~= 0 then
        item_line = line
      elseif bound ~= true and line.bound_mode == 0 then
        item_line = line
      end
    end
  end
  if item_line == nil then
    ui_tool.note_insert(ui.get_text("npcfunc|gem_com_no_higher_level"), "ffff0000")
    return
  end
  return item_line.id
end
function on_card_chg(card, onlyid, info)
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  compose_ok.enable = false
  local num = 0
  local compose_t1 = true
  local iVariety = 0
  local iVarLevel = 0
  local type = 0
  local excel_id = 0
  local quality = 0
  local vGems = {}
  local vGems_key = {}
  local r_gem1 = w_main5:search("r_gem1")
  ui_cell.clear(r_gem1)
  local compose_tool = w_main5:search("compose_tool")
  ui_cell.clear(compose_tool)
  w_tool_quick_buy.visible = false
  for i = 1, 5 do
    local card = w_main5:search("g_gem" .. i)
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
        if excel_id == 0 then
          excel_id = card.excel_id
          iVariety = pGemVar.id
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
          if iVariety ~= pGemVar.id then
            compose_t1 = false
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
  if num == 5 then
  else
    return
  end
  local pGemCom = bo2.gv_gem_compose:find(iVarLevel)
  if pGemCom == nil then
    ui_tool.note_insert(ui.get_text("npcfunc|gem_com_reach_level_peak"), "ffff0000")
    return
  end
  if compose_t1 == true then
    local pdt_bound = false
    for i = 1, 5 do
      local card = w_main5:search("g_gem" .. i)
      if card.info ~= nil then
        local src_bd = card.info:get_data_8(bo2.eItemByte_Bound)
        if src_bd == 1 then
          pdt_bound = true
        end
      end
    end
    local idx = iVarLevel + 1
    local iGemVar = bo2.gv_gem_item:find(excel_id).variety
    local iNewGem = GetGemByVariety(iGemVar, idx, pdt_bound)
    ui_cell.set(r_gem1, iNewGem)
  else
    return
  end
  if pGemCom then
    ui_cell.set(compose_tool, pGemCom.tool, 1)
    ui_npcfunc.ui_cmn.money_set(w_money, pGemCom.money)
    local tool_goods_id = ui_supermarket2.shelf_quick_buy_id(pGemCom.tool)
    if tool_goods_id ~= 0 then
      w_tool_quick_buy.name = tool_goods_id
      w_tool_quick_buy.visible = true
    end
  end
  compose_ok.enable = true
end
function on_tool_quick_buy(btn)
  ui_supermarket2.shelf_singleBuy(btn)
end
