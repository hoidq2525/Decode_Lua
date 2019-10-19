local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local ui_tab = ui_widget.ui_tab
local color_white = ui.make_color("FFFFFF")
local color_green = ui.make_color("179317")
local color_red = ui.make_color("FF0000")
local g_money_type = 0
local g_flag = true
function on_npcfunc_open_window(npcfunc_id)
end
function clear_money()
  g_money_type = 0
  if sys.check(w_money) and w_money:search("lb_req_money") then
    w_money:search("lb_req_money").money = 0
    w_money:search("lb_req_money").bounded = false
  end
end
function do_product_update()
  if not w_frm_top then
    return
  end
  local cuiqu = w_frm_top:search("mat_reg_0")
  local cuiquji_info = cuiqu:search("card").info
  clear_money()
  set_list()
  clear_frm_mat_reg()
  if cuiquji_info == nil then
    clear_frm_top()
    return
  end
  w_btn_mk.enable = false
  local cuiqu_excel = get_excel(cuiquji_info.excel.id)
  for i = 0, 4 do
    local id = cuiqu_excel.reg_id[i]
    if id ~= 0 then
      local mat_reg_cell = w_frm_mat_reg:search("mat_reg_" .. i + 2)
      ui_cell.set(mat_reg_cell, cuiqu_excel.reg_id[i], cuiqu_excel.reg_num[i])
      local cell_num_bag = ui.item_get_count(cuiqu_excel.reg_id[i], true)
      if cell_num_bag < cuiqu_excel.reg_num[i] then
        g_flag = false
      end
    end
  end
  local money_type = cuiqu_excel.money_type
  g_money_type = money_type
  w_money:search("lb_req_money").money = cuiqu_excel.money
  local player = ui_personal.ui_equip.safe_get_player()
  if money_type == bo2.eCurrency_BoundedMoney then
    w_money:search("lb_req_money").bounded = true
    w_money:search("lb_own_money").money = player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
    w_money:search("lb_own_money").bounded = true
  elseif money_type == bo2.eCurrency_CirculatedMoney then
    w_money:search("lb_req_money").bounded = false
    w_money:search("lb_own_money").money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    w_money:search("lb_own_money").bounded = false
  end
  local money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney) + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
  if money_type == bo2.eCurrency_CirculatedMoney then
    money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
  end
  if money < cuiqu_excel.money then
    g_flag = false
  end
  if g_flag then
    w_btn_mk.enable = true
  end
end
function post_product_update()
  w_main:insert_post_invoke(do_product_update, "ui_npcfunc.ui_cuiqu.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  post_product_update()
end
function get_excel(excel_id)
  local excel
  local size = bo2.gv_cuiqu.size
  for i = 0, size - 1 do
    local tmp_excel = bo2.gv_cuiqu:get(i)
    if tmp_excel.item_id == excel_id then
      excel = tmp_excel
      break
    end
  end
  return excel
end
function on_equip_change(card)
  do_product_update()
end
function check_weapon2nd_type(weapon2nd_type_list, weapon2nd_type)
  if weapon2nd_type_list == nil or weapon2nd_type == nil then
    return false
  end
  local size = weapon2nd_type_list.size
  for i = 0, size - 1 do
    if weapon2nd_type_list[i] == weapon2nd_type then
      return true
    end
  end
  return false
end
function item_rbutton_use(info)
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  local cuiqu = w_frm_top:search("mat_reg_0")
  local cuiquji_info = cuiqu:search("card").info
  if cuiquji_info == nil then
    local cuiqu_excel = get_excel(excel.id)
    if cuiqu_excel == nil then
      ui_chat.show_ui_text_id(20320)
      return
    end
    clear_all()
    set_list()
    ui_cell.drop(cuiqu, info)
  else
    local weapon2nd = w_frm_top:search("mat_reg_1")
    local cuiqu_excel = get_excel(cuiquji_info.excel.id)
    local weapon2nd_type_list = cuiqu_excel.v_weapon2nd_type
    if weapon2nd_type_list == nil then
      return
    end
    local weapon2nd_type = excel.type
    if not check_weapon2nd_type(weapon2nd_type_list, weapon2nd_type) then
      ui_chat.show_ui_text_id(20321)
      return
    end
    if info:identify_finished() == false then
      local txt = ui.get_text("npcfunc|eu_identify_first")
      ui_tool.note_insert(txt, "FF0000")
      return
    end
    local holesnum = info:get_data_8(bo2.eItemByte_Holes)
    for idx = 0, holesnum - 1 do
      if info:get_data_32(bo2.eItemUInt32_GemBeg + idx) ~= 0 then
        local txt = ui.get_text("npcfunc|eu_gem_tip")
        ui_tool.note_insert(txt, "FF0000")
        return
      end
    end
    ui_cell.drop(weapon2nd, info)
  end
  set_list()
end
function on_med_card_count()
  do_product_update()
end
function on_equip_card_mouse_cuiqu(ctrl, msg, pos, data)
  if msg ~= ui.mouse_rbutton_down then
    return
  end
  clear_all()
  set_list()
end
function on_equip_card_drop_cuiqu(ctrl, msg, pos, data)
  if ui_cell.check_drop(ctrl, msg, pos, data) == false then
    return
  end
  local card = ctrl:search("card")
  local info = ui.item_of_only_id(data:get("only_id"))
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  local cuiqu = w_frm_top:search("mat_reg_0")
  local cuiqu_excel = get_excel(excel.id)
  if cuiqu_excel == nil then
    ui_chat.show_ui_text_id(20320)
    return
  end
  clear_all()
  set_list()
  ui_cell.drop(cuiqu, info)
end
function on_equip_card_drop_weapon2nd(ctrl, msg, pos, data)
  if ui_cell.check_drop(ctrl, msg, pos, data) == false then
    return
  end
  local card = ctrl:search("card")
  local info = ui.item_of_only_id(data:get("only_id"))
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  local cuiqu = w_frm_top:search("mat_reg_0")
  local cuiquji_info = cuiqu:search("card").info
  if cuiquji_info == nil then
    ui_chat.show_ui_text_id(20320)
    return
  end
  local weapon2nd = w_frm_top:search("mat_reg_1")
  local cuiqu_excel = get_excel(cuiquji_info.excel.id)
  local weapon2nd_type_list = cuiqu_excel.v_weapon2nd_type
  if weapon2nd_type_list == nil then
    return
  end
  local weapon2nd_type = excel.type
  if not check_weapon2nd_type(weapon2nd_type_list, weapon2nd_type) then
    ui_chat.show_ui_text_id(20321)
    return
  end
  if info:identify_finished() == false then
    local txt = ui.get_text("npcfunc|eu_identify_first")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  local holesnum = info:get_data_8(bo2.eItemByte_Holes)
  for idx = 0, holesnum - 1 do
    if info:get_data_32(bo2.eItemUInt32_GemBeg + idx) ~= 0 then
      local txt = ui.get_text("npcfunc|eu_gem_tip")
      ui_tool.note_insert(txt, "FF0000")
      return
    end
  end
  ui_cell.drop(weapon2nd, info)
  set_list()
end
function on_equip_card_mouse_weapon2nd(ctrl, msg, pos, data)
  if msg ~= ui.mouse_rbutton_down then
    return
  end
  local item = w_frm_top:search("mat_reg_1")
  ui_cell.clear(item)
  set_list()
end
function on_fix_card_mouse(ctrl, msg)
end
function on_equip_card_tip_show(tip)
  local card = tip.owner:search("card")
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item(stk, excel, card.info)
  local stk_use
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|manuf_rclick_to_clear"), ui_tool.cs_tip_color_operation)
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_btn_mk_click()
  local cuiqu = w_frm_top:search("mat_reg_0")
  local cuiquji_info = cuiqu:search("card").info
  if cuiquji_info == nil then
    return
  end
  local weapon2nd = w_frm_top:search("mat_reg_1")
  local weapon2nd_info = weapon2nd:search("card").info
  if weapon2nd_info == nil then
    return
  end
  local grade = ui_tool.ctip_calculate_item_rank(weapon2nd_info.excel, weapon2nd_info, nil, nil)
  local function on_btn_msg(msg)
    if msg.result == 1 then
      local v = sys.variant()
      v:set(packet.key.talk_excel_id, bo2.eNpcFunc_Cuiqu)
      v:set64(packet.key.item_key, cuiquji_info.only_id)
      v:set64(packet.key.item_key1, weapon2nd_info.only_id)
      v:set(packet.key.cmn_val, grade)
      bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
      do_product_update()
      set_list()
    end
  end
  local msg = {
    callback = on_btn_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui.get_text("npcfunc|cuiqu_confirm_info")
  ui_widget.ui_msg_box.show_common(msg)
end
function clear_frm_top()
  local item = w_frm_top:search("mat_reg_0")
  if item ~= nil then
    ui_cell.clear(item)
  end
  item = w_frm_top:search("mat_reg_1")
  if item ~= nil then
    ui_cell.clear(item)
  end
end
function clear_frm_mat_reg()
  if not w_frm_mat_reg then
    return
  end
  for i = 0, 4 do
    local item = w_frm_mat_reg:search("mat_reg_" .. i + 2)
    if item ~= nil then
      ui_cell.clear(item)
    end
  end
end
function clear_all()
  clear_money()
  clear_frm_top()
  clear_frm_mat_reg()
  set_list()
end
function set_list()
  local weapon2nd = w_frm_top:search("mat_reg_1")
  if not weapon2nd or not w_frm_top then
    return
  end
  g_flag = true
  local cuiqu = w_frm_top:search("mat_reg_0")
  local cuiquji_info = cuiqu:search("card").info
  local weapon2nd_info = weapon2nd:search("card").info
  local level_color = color_white
  local grade_color = color_white
  local secondLevel_color = color_white
  local cuiqu_grade = "--"
  local cuiqu_level_min = "--"
  local cuiqu_level_max = "--"
  local cuiqu_secondLevel = "--"
  local weapon2nd_grade = "--"
  local weapon2nd_level = "--"
  local weapon2nd_level = "--"
  local weapon2nd_secondLevel = "--"
  local cuiqu_excel
  if cuiquji_info ~= nil then
    cuiqu_excel = get_excel(cuiquji_info.excel.id)
    cuiqu_grade = cuiqu_excel.weapon2nd_grade
    cuiqu_level_min = cuiqu_excel.weapon2nd_level_min
    cuiqu_level_max = cuiqu_excel.weapon2nd_level_max
    cuiqu_secondLevel = cuiqu_excel.weapon2nd_secondLevel
    if weapon2nd_info ~= nil then
      weapon2nd_grade = ui_tool.ctip_calculate_item_rank(weapon2nd_info.excel, weapon2nd_info, nil, nil)
      weapon2nd_level = weapon2nd_info.excel.reqlevel
      weapon2nd_secondLevel = weapon2nd_info:get_data_32(bo2.eItemUInt32_SecondLevel)
      level_color = color_red
      if cuiqu_level_min <= weapon2nd_level and cuiqu_level_max >= weapon2nd_level then
        level_color = color_green
      else
        g_flag = false
      end
      grade_color = color_red
      if cuiqu_grade <= weapon2nd_grade then
        grade_color = color_green
      else
        g_flag = false
      end
      secondLevel_color = color_red
      if cuiqu_secondLevel <= weapon2nd_secondLevel then
        secondLevel_color = color_green
      else
        g_flag = false
      end
    else
      g_flag = false
    end
  end
  if w_list == nil then
    return
  end
  w_list:item_clear()
  local grade_item = w_list:item_append()
  if grade_item == nil then
    return
  end
  grade_item:load_style("$frame/npcfunc/cuiqu.xml", "list_lable")
  grade_item:search("need").text = ui.get_text("npcfunc|grade_need")
  grade_item:search("result").text = weapon2nd_grade .. "/" .. cuiqu_grade
  grade_item:search("result").color = grade_color
  level_item = w_list:item_append()
  level_item:load_style("$frame/npcfunc/cuiqu.xml", "list_lable")
  level_item:search("need").text = ui.get_text("npcfunc|equip_level_need")
  if cuiquji_info == nil then
    level_item:search("result").text = weapon2nd_level .. "/" .. cuiqu_level_min
  elseif cuiqu_level_min == cuiqu_level_max then
    level_item:search("result").text = weapon2nd_level .. "/" .. cuiqu_level_min
  else
    level_item:search("result").text = weapon2nd_level .. "/" .. "(" .. cuiqu_level_min .. "~" .. cuiqu_level_max .. ")"
  end
  level_item:search("result").color = level_color
  level_item = w_list:item_append()
  level_item:load_style("$frame/npcfunc/cuiqu.xml", "list_lable")
  level_item:search("need").text = ui.get_text("npcfunc|equip_weapon2ndlevel_need")
  level_item:search("result").text = weapon2nd_secondLevel .. "/" .. cuiqu_secondLevel
  level_item:search("result").color = secondLevel_color
end
function on_visible(w, vis)
  clear_all()
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
  w_btn_mk.enable = false
  set_list()
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|manuf_rclick_to_place")
end
function item_rbutton_check(info)
  return true
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
function on_timer()
  local player = ui_personal.ui_equip.safe_get_player()
  if g_money_type == bo2.eCurrency_BoundedMoney then
    w_money:search("lb_own_money").money = player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
    w_money:search("lb_own_money").bounded = true
  elseif g_money_type == bo2.eCurrency_CirculatedMoney then
    w_money:search("lb_own_money").money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    w_money:search("lb_own_money").bounded = false
  end
end
