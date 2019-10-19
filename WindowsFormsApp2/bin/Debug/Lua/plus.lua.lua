local res_id = 0
function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  ui_npcfunc.clear_card(g_input)
  ui_npcfunc.clear_card(g_raw1)
  ui_npcfunc.clear_card(g_raw2)
end
function on_ok()
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_Plus)
  local key1 = packet.key.item_key
  local key2 = packet.key.item_key1
  v:set64(key1, g_input.only_id)
  v:set64(key2, g_raw1.only_id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function on_init()
  g_input:insert_on_item_only_id(on_card_chg, "ui_plus.on_card_chg")
  g_raw1:insert_on_item_only_id(on_raw_chg1, "ui_plus.on_raw_chg1")
end
function on_card_chg(card, onlyid, info)
  if card.excel_id == 0 then
    res_id = 0
    ui_npcfunc.clear_card(g_raw1)
    ui_npcfunc.clear_card(g_raw2)
    plus_ok.enable = false
    return
  end
  ui.log("on_card_chg in")
  flag = false
  local excel
  for i = 0, bo2.gv_equip_plus.size - 1 do
    excel = bo2.gv_equip_plus:get(i)
    for i = 0, excel.plus_raw.size - 1 do
      ui.log("%s %s", card.excel_id, excel.plus_raw[i])
      if card.excel_id == excel.plus_raw[i] then
        if g_raw1.excel_id == 0 then
          flag = true
          break
        elseif g_raw1.excel_id == excel.plus_burden1 then
          flag = true
          g_raw2.excel_id = excel.plus_burden2
          res_id = excel.id
          break
        end
      end
    end
    if flag == true then
      break
    end
  end
  if flag == false then
    ui_tool.note_insert(ui.get_text("npcfunc|plus_place_right_mat"), "ffff0000")
    ui_npcfunc.clear_card(g_input)
    ui.log("on_card_chg 1")
    return
  end
  g_raw1.excel_id = excel.plus_burden1
  g_raw2.excel_id = excel.plus_burden2
  g_raw1.require_count = excel.burden_count1
  g_raw2.require_count = excel.burden_count2
  g_res.excel_id = excel.plus_id
  if g_input.excel_id ~= 0 and g_raw1.excel_id ~= 0 and g_raw2.excel_id ~= 0 then
    plus_ok.enable = true
  end
end
function on_raw_chg1(card, onlyid)
  if card.excel_id == 0 then
    res_id = 0
    plus_ok.enable = false
    return
  end
  ui.log("on_raw_chg1 in")
  flag = false
  local excel
  for i = 0, bo2.gv_equip_plus.size - 1 do
    excel = bo2.gv_equip_plus:get(i)
    if g_input.excel_id == 0 then
      if card.excel_id == excel.plus_burden1 then
        flag = true
        break
      end
    else
      for i = 0, excel.plus_raw.size - 1 do
        if g_input.excel_id == excel.plus_raw[i] and card.excel_id == excel.plus_burden1 then
          flag = true
          g_raw2.excel_id = excel.plus_burden2
          res_id = excel.id
          break
        end
      end
    end
    if flag == true then
      break
    end
  end
  if flag == false then
    ui_tool.note_insert(ui.get_text("npcfunc|plus_place_right_mat"), "ffff0000")
    ui_npcfunc.clear_card(card)
    return
  end
  g_raw1.require_count = excel.burden_count1
  if g_input.excel_id ~= 0 and g_raw1.excel_id ~= 0 and g_raw2.excel_id ~= 0 then
    plus_ok.enable = true
  end
end
function on_raw_chg2(card)
  if card.excel_id == 0 then
    ui_npcfunc.clear_card(card)
    return
  end
end
