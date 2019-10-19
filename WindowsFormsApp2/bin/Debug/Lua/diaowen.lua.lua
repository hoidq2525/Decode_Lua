local ui_diaowen = ui_npcfunc.ui_diaowen
local ui_tree2 = ui_widget.ui_tree2
local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local g_scn_player
local reg = ui_packet.game_recv_signal_insert
local gv_diaowen_category = bo2.load_table_lang("$mb/item/diaowen_catagory.xml")
local g_sig = "ui_npcfunc.ui_diaowen.count_refresh"
local g_drop_items = {
  shiban_info = 0,
  jingshi_info = {},
  num = 0
}
local g_select_hole = -1
local DIAOWEN_RULES_MAX = 8
function on_npcfunc_open_window(npcfunc_id)
  ui.log("npcfunc_id:" .. npcfunc_id)
end
function on_btn_make_click(btn)
  if not g_drop_items_jingshi_check() then
    return
  end
  local data = sys.variant()
  for i = 0, DIAOWEN_RULES_MAX - 1 do
    if g_drop_items.jingshi_info[i] ~= 0 then
      local tmpv = sys.variant()
      tmpv:set(packet.key.item_key, g_drop_items.jingshi_info[i].only_id)
      data:push_back(tmpv)
    end
  end
  local item = w_special_view.svar.leaf_item_sel
  local diaowen = item.svar.diaowen
  local v = sys.variant()
  local function on_btn_msg(msg)
    if msg.result == 1 then
      v:set(packet.key.talk_excel_id, bo2.eNpcFunc_Diaowen)
      v:set(packet.key.cmn_type, bo2.eFuncTypeDiaozhuo)
      v:set(packet.key.cmn_dataobj, data)
      v:set(packet.key.skill_id, diaowen.skill_id)
      v:set(packet.key.item_key, g_drop_items.shiban_info.only_id)
      bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
    end
  end
  local msg = {
    callback = on_btn_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui.get_text("npcfunc|diaowen_diaozhuo_confirm_info")
  ui_widget.ui_msg_box.show_common(msg)
end
function on_btn_pullout(btn)
  local function on_btn_msg(msg)
    if msg.result == 1 then
      local v = sys.variant()
      v:set(packet.key.talk_excel_id, bo2.eNpcFunc_Diaowen)
      v:set(packet.key.cmn_type, bo2.eFuncTypeBachu)
      v:set(packet.key.cmn_val, g_select_hole)
      v:set(packet.key.item_key, g_drop_items.shiban_info.only_id)
      bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
    end
  end
  if g_select_hole < 0 or g_select_hole >= DIAOWEN_RULES_MAX then
    return
  end
  local wearout = g_drop_items.shiban_info:get_data_32(bo2.eItemUInt32_JingshiCurWearoutBeg + g_select_hole)
  local msg = {
    callback = on_btn_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  local excel_id = g_drop_items.shiban_info:get_data_32(bo2.eItemUInt32_DiaowenBeg + g_select_hole)
  local arg = sys.variant()
  arg:clear()
  arg:set("item_id", excel_id)
  if wearout ~= 1 then
    msg.text = sys.mtf_merge(arg, ui.get_text("npcfunc|diaowen_bachu_confirm_info"))
  else
    msg.text = sys.mtf_merge(arg, ui.get_text("npcfunc|diaowen_bachu_confirm_info_del"))
  end
  ui_widget.ui_msg_box.show_common(msg)
end
function do_update_pullout_btn()
  w_btn_pullout.enable = false
  if g_drop_items.shiban_info == 0 then
    return
  end
  if g_select_hole < 0 or g_select_hole >= DIAOWEN_RULES_MAX then
    return
  end
  local id = g_drop_items.shiban_info:get_data_32(bo2.eItemUInt32_DiaowenBeg + g_select_hole)
  if id == 0 then
    return
  end
  w_btn_pullout.enable = true
end
function do_update_make_btn()
  if not g_drop_items_jingshi_check() then
    w_btn_make.enable = false
    return
  end
  w_btn_make.enable = true
end
function g_drop_items_jingshi_check()
  if g_drop_items.num == 0 then
    return false
  end
  for i = 0, DIAOWEN_RULES_MAX - 1 do
    if g_drop_items.jingshi_info[i] ~= 0 then
      flag = true
    end
  end
  if flag then
    return true
  end
  return false
end
function g_drop_items_find(id)
  if g_drop_items.num == 0 then
    return false
  end
  local jingshi = g_drop_items.jingshi_info
  for i = 0, DIAOWEN_RULES_MAX - 1 do
    if jingshi[i] ~= 0 and jingshi[i].excel_id == id then
      return true
    end
  end
  return false
end
function g_drop_items_del_jingshi(info)
  if not g_drop_items_find(info.excel_id) then
    return
  end
  local jingshi = g_drop_items.jingshi_info
  for i = 0, DIAOWEN_RULES_MAX - 1 do
    if jingshi[i] ~= 0 and jingshi[i].excel_id == info.excel_id then
      jingshi[i] = 0
      break
    end
  end
  g_drop_items.num = g_drop_items.num - 1
  g_drop_items.jingshi_data = jingshi
end
function g_drop_items_add_jingshi(info)
  if g_drop_items_find(info.excel_id) then
    return
  end
  local jingshi = g_drop_items.jingshi_info
  for i = 0, DIAOWEN_RULES_MAX - 1 do
    if jingshi[i] == 0 then
      jingshi[i] = info
      break
    end
  end
  g_drop_items.num = g_drop_items.num + 1
  g_drop_items.jingshi_info = jingshi
end
function g_drop_items_clear()
  g_drop_items.shiban_info = 0
  for i = 0, DIAOWEN_RULES_MAX - 1 do
    g_drop_items.jingshi_info[i] = 0
  end
  g_drop_items.num = 0
end
function detail_clear()
  update_shiban(false, 0, false)
  update_skill(false, 0, false)
  update_jingshi_pic(2)
end
function do_update_2(info)
  if info == nil then
    return
  end
  local holesMax = info:get_data_8(bo2.eItemByte_DiaowenMaxHolesTotle)
  if holesMax <= 0 then
    return
  end
  local is_holes_full = true
  local jingshi_pic = w_top_right:search("jingshi_pic_" .. holesMax)
  update_jingshi_state_lock()
  update_jingshi_state()
  for i = 0, holesMax - 1 do
    local id = info:get_data_32(bo2.eItemUInt32_DiaowenBeg + i)
    if id ~= 0 then
      local item = jingshi_pic:search("item_" .. i)
      local card = item:search("card")
      clear_item_state_lock(item)
      update_item_state_lock(item)
      update_card_draw_cover(card, false)
    else
      is_holes_full = false
    end
  end
  local skill_item = w_skill:search("skill_card")
  update_card_draw_cover(skill_item, true)
  if is_holes_full then
    local item = w_skill:search("skill_card")
    update_card_draw_cover(skill_item, false)
  end
  g_select_hole = -1
  do_update_pullout_btn()
  do_update_make_btn()
end
function on_shiban_equip_drop(ctrl, msg, pos, data)
  if ui_cell.check_drop(ctrl, msg, pos, data) == false then
    return
  end
  local card = ctrl:search("card")
  local info = ui.item_of_only_id(data:get("only_id"))
  local item = w_special_view.svar.leaf_item_sel
  if not sys.check(item) or not item.selected then
    ui_chat.show_ui_text_id(76207)
    return
  end
  local diaowen = w_special_view.svar.leaf_item_sel.svar.diaowen
  local size_dw = diaowen.v_item_ids.size
  local find_flag = false
  for i = 0, size_dw - 1 do
    if info.excel_id == diaowen.v_item_ids[i] and (diaowen.skill_id == info:get_data_32(bo2.eItemUInt32_DiaowenSkillID) or check_jingshi_is_same(diaowen, info)) then
      find_flag = true
      break
    end
  end
  if not find_flag then
    ui_chat.show_ui_text_id(76207)
    return
  end
  do_update()
  ui_cell.drop(card, info)
  update_card_draw_cover(card, false)
  g_drop_items_clear()
  g_drop_items.shiban_info = info
  do_update_2(info)
  g_select_hole = -1
  do_update_pullout_btn()
end
function on_shiban_card_mouse(ctrl, msg, pos, data)
  if msg == ui.mouse_rbutton_down then
    local item = w_special_view.svar.leaf_item_sel
    if not sys.check(item) or not item.selected then
      return
    end
    local diaowen = w_special_view.svar.leaf_item_sel.svar.diaowen
    update_shiban(false, 0, false)
    update_skill(false, 0, false)
    update_jingshi_pic(diaowen.hole_num)
    do_update()
    g_drop_items_clear()
  elseif msg == ui.mouse_lbutton_down then
    g_select_hole = -1
    update_jingshi_state()
    do_update_pullout_btn()
  end
end
function check_jingshi_drop(card_excelid, info_excelid)
  local item = w_special_view.svar.leaf_item_sel
  if not sys.check(item) or not item.selected then
    return
  end
  local diaowen = w_special_view.svar.leaf_item_sel.svar.diaowen
  for i = 0, DIAOWEN_RULES_MAX - 1 do
    local size_js = diaowen.v_cuiqu_stone[i].size
    local flag = false
    for j = 0, size_js - 1 do
      if diaowen.v_cuiqu_stone[i][j] ~= info_excelid then
        flag = true
        break
      end
    end
    if not flag then
      return false
    end
    flag = false
  end
  return false
end
function find_jingshi_index(excel_id)
  local diaowen = w_special_view.svar.leaf_item_sel.svar.diaowen
  if diaowen == nil then
    return -1
  end
  for i = 0, diaowen.hole_num - 1 do
    local size_js = diaowen.v_cuiqu_stone[i].size
    for j = 0, size_js - 1 do
      if diaowen.v_cuiqu_stone[i][j] == excel_id then
        return i
      end
    end
  end
  return -1
end
function check_is_have_jingshi(shiban_info, excel_id)
  if shiban_info == 0 then
    return false
  end
  local idx = find_jingshi_index(excel_id)
  if idx == -1 then
    return false
  end
  local info = ui.item_of_only_id(shiban_info.only_id)
  local id = info:get_data_32(bo2.eItemUInt32_DiaowenBeg + idx)
  if id ~= 0 then
    return true
  end
  return false
end
function on_equip_drop(ctrl, msg, pos, data)
  if ui_cell.check_drop(ctrl, msg, pos, data) == false then
    return
  end
  local shiban_item = w_shiban:search("shiban")
  local shiban_info = shiban_item:search("card").info
  if g_drop_items.shiban_info == 0 or g_drop_items.shiban_info.excel_id ~= shiban_info.excel_id then
    ui_chat.show_ui_text_id(76209)
    return
  end
  local card = ctrl:search("card")
  local info = ui.item_of_only_id(data:get("only_id"))
  if 0 >= shiban_info:get_data_32(bo2.eItemUInt32_CurWearout) then
    local var = sys.variant()
    var:set(L("item_id"), shiban_info.excel_id)
    local data = sys.variant()
    data:set(packet.key.ui_text_id, 20323)
    data:set(packet.key.ui_text_arg, var)
    ui_chat.show_ui_text(0, data)
    return
  end
  if check_is_have_jingshi(shiban_info, info.excel_id) then
    ui_chat.show_ui_text_id(76210)
    return
  end
  if card.excel_id ~= info.excel_id and not check_jingshi_drop(card.excel_id, info.excel_id) then
    ui_chat.show_ui_text_id(76208)
    return
  end
  ui_cell.drop(card, info)
  update_card_draw_cover(card, false)
  g_select_hole = -1
  g_drop_items_add_jingshi(info)
  update_jingshi_state()
  do_update_pullout_btn()
  do_update_make_btn()
end
function on_equip_card_mouse(ctrl, msg, pos, data)
  if msg == ui.mouse_rbutton_down then
    local shiban_item = w_shiban:search("shiban")
    local shiban_info = shiban_item:search("card")
    if g_drop_items.shiban_info == 0 or g_drop_items.shiban_info.excel_id ~= shiban_info.excel_id then
      return
    end
    local card = ctrl.parent:search("card")
    local excel_id = card.excel_id
    if not g_drop_items_find(excel_id) then
      return
    end
    g_drop_items_del_jingshi(card.info)
    update_card_draw_cover(card, true)
    ui_cell.clear(card)
    g_select_hole = -1
    update_jingshi_state()
    do_update_pullout_btn()
    do_update_make_btn()
    ui_cell.set(card, excel_id)
  elseif msg == ui.mouse_lbutton_down then
    if ctrl.excel_id == 0 then
      return
    end
    update_jingshi_state()
    local idx = find_jingshi_index(ctrl.excel_id)
    local card = ctrl.parent:search("card")
    if idx == -1 then
      return true
    else
      update_jingshi_state()
      update_item_state(ctrl.parent.parent, 1)
    end
    g_select_hole = idx
    do_update_pullout_btn()
    do_update_make_btn()
  end
end
function item_rbutton_use(info)
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  if g_select_hole == -1 then
    local item = w_special_view.svar.leaf_item_sel
    if not sys.check(item) or not item.selected then
      ui_chat.show_ui_text_id(76207)
      return
    end
    local diaowen = w_special_view.svar.leaf_item_sel.svar.diaowen
    local size_dw = diaowen.v_item_ids.size
    local find_flag = false
    for i = 0, size_dw - 1 do
      if info.excel_id == diaowen.v_item_ids[i] and (diaowen.skill_id == info:get_data_32(bo2.eItemUInt32_DiaowenSkillID) or check_jingshi_is_same(diaowen, info)) then
        find_flag = true
        break
      end
    end
    if not find_flag then
      ui_chat.show_ui_text_id(76207)
      return
    end
    local item = w_shiban:search("shiban")
    local card = item:search("card")
    do_update()
    ui_cell.drop(card, info)
    update_card_draw_cover(card, false)
    g_drop_items_clear()
    g_drop_items.shiban_info = info
    do_update_2(info)
    g_select_hole = -1
  else
    local shiban_item = w_shiban:search("shiban")
    local shiban_info = shiban_item:search("card").info
    local diaowen = w_special_view.svar.leaf_item_sel.svar.diaowen
    local jingshi_pic = w_top_right:search("jingshi_pic_" .. diaowen.hole_num)
    local item = jingshi_pic:search("item_" .. g_select_hole)
    local card = item:search("card")
    if g_drop_items.shiban_info == 0 or g_drop_items.shiban_info.excel_id ~= shiban_info.excel_id then
      ui_chat.show_ui_text_id(76209)
      return
    end
    if 0 >= shiban_info:get_data_32(bo2.eItemUInt32_CurWearout) then
      local var = sys.variant()
      var:set(L("item_id"), shiban_info.excel_id)
      local data = sys.variant()
      data:set(packet.key.ui_text_id, 20323)
      data:set(packet.key.ui_text_arg, var)
      ui_chat.show_ui_text(0, data)
      return
    end
    if card.excel_id ~= info.excel_id and not check_jingshi_drop(card.excel_id, info.excel_id) then
      ui_chat.show_ui_text_id(76208)
      return
    end
    if check_is_have_jingshi(shiban_info, info.excel_id) then
      ui_chat.show_ui_text_id(76210)
      return
    end
    ui_cell.drop(card, info)
    update_card_draw_cover(card, false)
    g_drop_items_add_jingshi(info)
    update_jingshi_state()
    do_update_pullout_btn()
    do_update_make_btn()
  end
end
function on_shiban_equip_card_tip_show(tip)
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    local item = w_special_view.svar.leaf_item_sel
    if sys.check(item) and item.selected then
      local diaowen = item.svar.diaowen
      local stk = sys.mtf_stack()
      stk:raw_push(ui.get_text("npcfunc|diaowen_tip_input_item"))
      local items = diaowen.v_item_ids
      for i = 0, items.size - 1 do
        local excel_id = items[i]
        local item = ui.item_get_excel(excel_id)
        if item ~= nil then
          stk:raw_format([[

<i:%d>]], excel_id)
        end
      end
      ui_tool.ctip_show(tip.owner, stk, nil)
      return
    end
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item(stk, excel, card.info)
  local stk_use
  if g_drop_items.shiban_info ~= 0 then
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|manuf_rclick_to_clear"), ui_tool.cs_tip_color_operation)
  end
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_diaozhuo_jingshi_tip(tip, excel)
  local info_base = g_drop_items.shiban_info
  local index = find_jingshi_index(excel.id)
  if index == -1 then
    return
  end
  local info = {
    name = excel.name,
    plootlevel_star = bo2.gv_lootlevel:find(excel.lootlevel),
    get_data_8 = function(info, val)
      if val == bo2.eItemByte_Bound then
        return info_base:get_data_8(bo2.eItemByte_Bound)
      end
      return 0
    end,
    get_data_s = function()
      return L("")
    end,
    box = bo2.eItemBox_BagBeg,
    get_data_32 = function(info, val)
      if val == bo2.eItemUInt32_CurWearout then
        local v = 0
        v = info_base:get_data_32(bo2.eItemUInt32_JingshiCurWearoutBeg + index)
        return v
      end
      if val == bo2.eItemUInt32_MaxWearout then
        local v = 0
        v = info_base:get_data_32(bo2.eItemUInt32_JingshiMaxWearoutBeg + index)
        return v
      end
      return 0
    end
  }
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item(stk, excel, info, card)
  local stk_use
  local ptype = excel.ptype
  if ptype ~= nil then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_equip_card_tip_show(tip)
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    return
  end
  if check_is_have_jingshi(g_drop_items.shiban_info, card.excel_id) then
    on_diaozhuo_jingshi_tip(tip, excel)
  else
    ui_npcfunc.ui_cell.on_tip_show(tip)
  end
end
function on_skill_card_tip_show(tip)
  local card = tip.owner
  local excel_id = card.excel_id
  if excel_id == nil or excel_id == 0 then
    return
  end
  local info = {}
  info.excel_id = excel_id
  info.level = 1
  if bo2.gv_skill_group:find(excel_id) ~= nil then
    type = 1
  elseif bo2.gv_passive_skill:find(excel_id) ~= nil then
    type = 0
  else
    return
  end
  info.type = type
  local stk = sys.mtf_stack()
  if info.type == 1 then
    ui_tool.ctip_make_skill(stk, info)
  elseif info.type == 0 then
    ui_tool.ctip_make_passive_skill(stk, info)
  else
    return
  end
  ui_tool.ctip_show(card, stk)
end
function on_equip_change(card, onlyid, info)
  if card == nil or info == nil or onlyid == 0 then
    g_drop_items_clear()
    update_jingshi_state_lock()
    update_jingshi_state()
    g_select_hole = -1
    do_update()
    return
  end
  g_drop_items_clear()
  local item = w_special_view.svar.leaf_item_sel
  local diaowen = item.svar.diaowen
  update_jingshi_item(diaowen)
  g_drop_items.shiban_info = info
  do_update_2(info)
end
function update_shiban(flag, v_item_ids, flag1)
  local item = w_shiban:search("shiban")
  if not item then
    return
  end
  local card = item:search("card")
  ui_cell.clear(card)
  if flag and v_item_ids.size == 1 then
  else
    ui_cell.clear(card)
  end
  update_card_draw_cover(card, flag1)
end
function update_skill(flag, id, flag1)
  local item = w_skill:search("skill_card")
  if not item then
    return
  end
  item.excel_id = 0
  if flag then
    item.excel_id = id
  end
  update_card_draw_cover(item, flag1)
end
function update_jingshi_state()
  local item = w_special_view.svar.leaf_item_sel
  if not sys.check(item) or not item.selected then
    return
  end
  local diaowen = item.svar.diaowen
  local jingshi_pic = w_top_right:search("jingshi_pic_" .. diaowen.hole_num)
  for i = 0, diaowen.hole_num - 1 do
    local item = jingshi_pic:search("item_" .. i)
    local card = item:search("card")
    if check_is_have_jingshi(g_drop_items.shiban_info, card.excel_id) or g_drop_items_find(card.excel_id) then
      update_item_state(item, 0)
    else
      update_item_state(item, -1)
    end
  end
end
function update_jingshi_state_lock()
  local item = w_special_view.svar.leaf_item_sel
  if not sys.check(item) or not item.selected then
    return
  end
  local diaowen = item.svar.diaowen
  local jingshi_pic = w_top_right:search("jingshi_pic_" .. diaowen.hole_num)
  for i = 0, diaowen.hole_num - 1 do
    local item = jingshi_pic:search("item_" .. i)
    local card = item:search("card")
    clear_item_state_lock(item)
  end
end
function clear_item_state_lock(item)
  if not item then
    return
  end
  local pic_item = item:search("lock")
  pic_item.visible = false
end
function update_item_state_lock(item)
  if not item then
    return
  end
  local pic_item = item:search("lock")
  pic_item.visible = false
  local card = item:search("card")
  if check_is_have_jingshi(g_drop_items.shiban_info, card.excel_id) then
    pic_item.visible = true
  end
end
function update_item_state(item, state_id)
  local item0 = item:search("state_0")
  local item1 = item:search("state_1")
  if state_id == -1 then
    item0.visible = false
    item1.visible = false
    return
  end
  if state_id == 1 then
    item0.visible = false
    item1.visible = true
  else
    item0.visible = true
    item1.visible = false
  end
end
function update_card_draw_cover(card, flag)
  if not card then
    return
  end
  local mengban_pic = card.parent:search("mengban")
  mengban_pic.visible = flag
end
function clear_jingshi_item(jingshi_pic, hole_num)
  if hole_num < 2 or hole_num > DIAOWEN_RULES_MAX then
    return
  end
  for i = 0, hole_num - 1 do
    local item = jingshi_pic:search("item_" .. i)
    local card = item:search("card")
    update_card_draw_cover(card, true)
    ui_cell.clear(card)
    update_item_state(item, -1)
  end
end
function update_jingshi_item(diaowen)
  local hole_num = diaowen.hole_num
  local jingshi_pic = w_top_right:search("jingshi_pic_" .. hole_num)
  for i = 0, hole_num - 1 do
    local item = jingshi_pic:search("item_" .. i)
    local card = item:search("card")
    ui_cell.clear(card)
    update_card_draw_cover(card, true)
    ui_cell.set(card, diaowen.v_cuiqu_stone[i][0])
  end
end
function update_jingshi_pic(hole_num)
  if hole_num < 2 or hole_num > DIAOWEN_RULES_MAX then
    return
  end
  for i = 2, DIAOWEN_RULES_MAX do
    local jingshi_pic = w_top_right:search("jingshi_pic_" .. i)
    if not jingshi_pic then
      return
    end
    if hole_num == i then
      jingshi_pic.visible = true
    else
      jingshi_pic.visible = false
    end
    clear_jingshi_item(jingshi_pic, i)
  end
end
function do_update()
  local item = w_special_view.svar.leaf_item_sel
  if not sys.check(item) or not item.selected then
    return
  end
  update_jingshi_state_lock()
  local diaowen = item.svar.diaowen
  update_shiban(true, diaowen.v_item_ids, true)
  update_skill(true, diaowen.skill_id, true)
  update_jingshi_item(diaowen)
  do_update_pullout_btn()
  do_update_make_btn()
end
function on_item_sel(item, sel)
  if not sel then
    detail_clear()
    return
  end
  g_drop_items_clear()
  g_select_hole = -1
  w_special_view.svar.leaf_item_sel = item
  local diaowen = item.svar.diaowen
  update_shiban(false, 0, false)
  update_skill(false, 0, false)
  update_jingshi_pic(diaowen.hole_num)
  do_update()
  update_jingshi_state_lock()
end
function build_node(line)
  local node = ui_tree2.insert(w_special_view.root)
  ui_tree2.set_text(node, line.name)
  node.svar.diaowen_category = line
  node.expanded = true
  return node
end
function build_leaf(diaowen, node, item_excel)
  local item = ui_tree2.insert(node)
  item.svar.diaowen = diaowen
  local skill = bo2.gv_skill_group:find(diaowen.skill_id)
  if skill == nil then
    skill = bo2.gv_passive_skill:find(diaowen.skill_id)
  end
  ui_tree2.set_text(item, skill.name)
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|manuf_rclick_to_place")
end
function item_rbutton_check(info)
  return true
end
function on_init(ctrl)
  local size_cat = gv_diaowen_category.size
  for j = 0, size_cat - 1 do
    local category_line = gv_diaowen_category:get(j)
    local node = build_node(category_line)
    local size_diaowen = bo2.gv_diaowen.size
    for k = 0, size_diaowen - 1 do
      local diaowen = bo2.gv_diaowen:get(k)
      if node.svar.diaowen_category.id == diaowen.type then
        build_leaf(diaowen, node, nil)
      end
    end
  end
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  w_shiban_item:insert_on_item_only_id(on_equip_change, "ui_npcfunc.ui_diaowen.on_equip_change")
end
function on_visible(ctrl, vis)
  g_select_hole = -1
  g_drop_items_clear()
  ui_npcfunc.on_visible(ctrl, vis)
  detail_clear()
  w_btn_make.enable = false
  w_btn_pullout.enable = false
  if w_special_view.svar.leaf_item_sel then
    on_item_sel(w_special_view.svar.leaf_item_sel, true)
  end
end
function check_jingshi_is_same(diaowen, info)
  local hole_num = info:get_data_8(bo2.eItemByte_DiaowenMaxHolesTotle)
  for i = 0, hole_num - 1 do
    local excel_id = info:get_data_32(bo2.eItemUInt32_DiaowenBeg + i)
    if excel_id > 0 then
      local size_js = diaowen.v_cuiqu_stone[i].size
      local flag = false
      for j = 0, size_js - 1 do
        if diaowen.v_cuiqu_stone[i][j] == excel_id then
          flag = true
          break
        end
      end
      if not flag then
        return false
      end
      flag = false
    end
  end
  return true
end
