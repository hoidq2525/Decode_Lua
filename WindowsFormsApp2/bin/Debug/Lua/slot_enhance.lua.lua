local enhance_item_return_rate = bo2.gv_define:find(906).value
local enhance_item_id = bo2.gv_define:find(907).value.v_int
local enhance_item_success_rate = bo2.gv_define:find(920).value
local new_slot_enhance_lv_max = bo2.gv_define:find(1283).value.v_int
local enhance_item_return_vec = {}
local enhance_item_success_vec = {}
local GetVecFromString = function(str)
  if str == nil then
    return nil
  end
  if #str == 0 then
    return nil
  end
  local vec = {}
  local data, leftStr = str:split2("*")
  while #leftStr ~= 0 do
    table.insert(vec, data.v_int)
    data, leftStr = leftStr:split2("*")
  end
  table.insert(vec, data.v_int)
  return vec
end
enhance_item_return_vec = GetVecFromString(enhance_item_return_rate)
enhance_item_success_vec = GetVecFromString(enhance_item_success_rate)
local slot_index
local enhance_lv = 0
local new_open = false
local color_invalid = SHARED("FF0000")
local color_valid = SHARED("008000")
local select_pic
local get_use_count = function()
  local count = w_input_count.text.v_int
  return count
end
local get_db_item_id = function(id)
  local item_excel = ui.item_get_excel(id)
  local ref_excel = bo2.gv_refine_variety:find(item_excel.variety)
  if ref_excel == nil then
    ref_excel = bo2.gv_refine_med_variety:find(item_excel.variety)
  end
  if ref_excel == nil then
    return 0
  end
  local bd_excel_id = ref_excel.inc_bd_items[item_excel.varlevel]
  return bd_excel_id
end
local function update_enhance_des()
  local slot_enhance_excel = bo2.gv_slot_enhance_lv:find(enhance_lv + 1)
  if slot_enhance_excel == nil then
    return
  end
  local money_type_str = "<m:%d>"
  if slot_enhance_excel.money_type == 1 then
    money_type_str = "<bm:%d>"
  end
  local stk_en = sys.mtf_stack()
  local use_count = get_use_count()
  local add_success_rate = slot_enhance_excel.per_success_rate * use_count
  stk_en:push(ui.get_text("personal|enhance_success_rate"))
  local total_success_rate = slot_enhance_excel.min_success_rate + add_success_rate
  if total_success_rate > 100 then
    total_success_rate = 100
  end
  if add_success_rate ~= 0 then
    stk_en:raw_push(sys.format("<c+:#yellow>%d%%<c->", total_success_rate, slot_enhance_excel.min_success_rate, add_success_rate))
  else
    stk_en:raw_push(sys.format("%d%%", total_success_rate))
  end
  stk_en:raw_push("\n")
  stk_en:push(ui.get_text("personal|enhance_cost"))
  stk_en:raw_format(money_type_str, slot_enhance_excel.money)
  stk_en:raw_push("\n")
  local new_open = is_new_equip_slot_enhance_open(slot_index)
  stk_en:push(ui.get_text("personal|failed_return"))
  local failed_return_rate = 0
  if not new_open and add_success_rate ~= 0 then
    failed_return_rate = enhance_item_return_vec[use_count]
  end
  if failed_return_rate == nil then
    failed_return_rate = 0
  end
  if failed_return_rate > 100 then
    failed_return_rate = 100
  end
  stk_en:raw_format(money_type_str, slot_enhance_excel.money * failed_return_rate / 100)
  stk_en:push(sys.format("(%d%%)", failed_return_rate))
  w_se_detail:search("se_enhance_des").mtf = stk_en.text
  local need_item_text = ui_widget.merge_mtf({
    min_num = slot_enhance_excel.min_item_count,
    max_num = slot_enhance_excel.max_item_count
  }, ui.get_text("personal|slot_enhance_need_count"))
  w_se_detail:search("need_item_count").text = need_item_text
  local item_id = slot_enhance_excel.item_id
  local item_cnt = ui.item_get_count(item_id, true)
  if w_use_bound_mat.check then
    item_id = get_db_item_id(item_id)
    local b_item_cnt = ui.item_get_count(item_id, true)
    item_cnt = item_cnt + b_item_cnt
  end
  ui_npcfunc.ui_cell.set(w_se_detail:search("item"), item_id)
  local b_valid = is_need_level_true()
  local val1, val2 = math.modf((enhance_lv + 1) / 10)
  local btn_enhance_text = ui.get_text("personal|btn_enhance")
  if val2 == 0 then
    local val1, val2 = math.modf((enhance_lv + 1) / 100)
    if val2 == 0 then
      btn_enhance_text = ui.get_text("personal|btn_enhance100")
    else
      btn_enhance_text = ui.get_text("personal|btn_enhance10")
    end
  end
  w_btn_enhance.text = btn_enhance_text
  if b_valid and use_count <= item_cnt and use_count >= slot_enhance_excel.min_item_count and use_count <= slot_enhance_excel.max_item_count then
    w_btn_enhance.enable = true
  else
    w_btn_enhance.enable = false
  end
end
function is_need_level_true()
  local obj = bo2.player
  local player_level = obj:get_atb(bo2.eAtb_Level)
  local b_valid = false
  local lv_request_color = color_invalid
  local need_level = enhance_lv + 1 + enhance_lv_difference
  local line = bo2.gv_slot_enhance_lv:find(enhance_lv + 1)
  if new_open then
    if line and line.need_level then
      need_level = line.need_level
    end
    if player_level >= line.need_level then
      lv_request_color = color_valid
      b_valid = true
    end
  elseif enhance_lv + 1 <= player_level - enhance_lv_difference then
    lv_request_color = color_valid
    b_valid = true
  end
  return b_valid, lv_request_color, need_level
end
local function set_new_slot_enhance_trait(level, stk, color)
  if new_open then
    local index = get_slot_trait_list_id(slot_index, level)
    if index == -1 then
      return
    end
    local excelTrait = bo2.gv_slot_enhance_trait_list:find(index)
    if excelTrait ~= nil and excelTrait.vTraitList.size > 0 then
      local nSizeTrait = excelTrait.vTraitList.size
      for i = 0, nSizeTrait - 1 do
        local trait = bo2.gv_trait_list:find(excelTrait.vTraitList[i])
        if trait ~= nil then
          local desc = trait.desc
          if desc.size == 0 then
            local modify = bo2.gv_modify_player:find(trait.modify_id)
            if modify == nil then
              return
            end
            desc = sys.format("%s%+d", modify.name, trait.modify_value)
          end
          stk:raw_push("\n")
          ui_tool.ctip_push_unwrap(stk, desc, color)
        end
      end
    end
  end
end
local function update_detail_below_panel(enhance_lv)
  local stk = sys.mtf_stack()
  ui_tool.ctip_push_unwrap(stk, sys.format(ui.get_text("personal|cur_enhance_lv"), enhance_lv))
  local old_enhance_lv_val = enhance_lv
  if new_open then
    old_enhance_lv_val = 79 - enhance_lv_difference
  end
  if enhance_lv >= get_slotenhance_maxLv() then
    w_se_detail:search("btn_close2").visible = true
    w_se_detail:search("function_panel").visible = false
    w_se_detail.dy = 280
    stk:raw_push("<a:r>")
    ui_tool.ctip_push_unwrap(stk, ui.get_text("personal|max_level"), SHARED("FFCC33"))
    stk:raw_push("<a:l>")
    stk:raw_push("\n")
    ui_tool.ctip_push_unwrap(stk, sys.format(ui.get_text("personal|cur_property_add"), enhance_val_perLv * old_enhance_lv_val))
    set_new_slot_enhance_trait(enhance_lv, stk)
    w_se_detail:search("se_detail").mtf = stk.text
    return
  else
    w_se_detail:search("btn_close2").visible = false
    w_se_detail:search("function_panel").visible = true
    w_se_detail.dy = 498
  end
  stk:raw_push("\n")
  ui_tool.ctip_push_unwrap(stk, sys.format(ui.get_text("personal|cur_property_add"), enhance_val_perLv * old_enhance_lv_val))
  set_new_slot_enhance_trait(enhance_lv, stk)
  stk:raw_push([[


]])
  ui_tool.ctip_push_unwrap(stk, sys.format(ui.get_text("personal|after_enhance_lv"), enhance_lv + 1), SHARED("F7F534"))
  stk:raw_push("<a:r>")
  local b_valid, lv_request_color, need_level = is_need_level_true()
  ui_tool.ctip_push_unwrap(stk, sys.format(ui.get_text("personal|lv_request"), need_level), lv_request_color)
  stk:raw_push("<a:l>")
  stk:raw_push("\n")
  local next_level_val = old_enhance_lv_val + 1
  if new_open then
    next_level_val = old_enhance_lv_val
  end
  ui_tool.ctip_push_unwrap(stk, sys.format(ui.get_text("personal|after_property_add"), enhance_val_perLv * next_level_val), SHARED("F7F534"))
  set_new_slot_enhance_trait(enhance_lv + 1, stk, SHARED("F7F534"))
  w_se_detail:search("se_detail").dy = 120
  w_se_detail:search("se_detail").mtf = stk.text
  local line = bo2.gv_slot_enhance_lv:find(enhance_lv + 1)
  w_input_count.text = line.max_item_count
  update_enhance_des()
end
function on_se_detail_init(ctrl)
  w_input_count.text = 0
  select_pic = nil
end
function open_slot_enhance_detail(panel)
  if select_pic == panel:search("select") then
    w_se_detail:move_to_head()
  end
  slot_index = nil
  enhance_lv = 0
  new_open = false
  for key, val in ipairs(slot_name_tab) do
    if tostring(panel.name) == val.ctrl_name then
      slot_index = val.index - bo2.ePlayerFlagInt8_EquipSlotEnhanceBegin + bo2.eItemSlot_EquipBeg
      enhance_lv = val.value
      if val.flicker_control ~= nil then
        val.flicker_control:post_release()
        val.flicker_control = nil
      end
      break
    end
  end
  if slot_index ~= nil then
    local part_des = ui.get_text("item|slot" .. slot_index)
    w_se_detail:search("se_title").mtf = sys.format(ui.get_text("personal|slot_enhance_tiptitle"), part_des)
    local info = ui.item_of_coord(bo2.eItemArray_InSlot, slot_index)
    if info ~= nil then
      w_se_detail:search("card").image = "$icon/item/" .. info.excel.icon .. ".png"
    else
      w_se_detail:search("card").image = panel:search("bg_pic").image
      w_se_detail:search("card").irect = panel:search("bg_pic").irect
    end
    local stk_detail = sys.mtf_stack()
    stk_detail:push(sys.format("%s%s\n", ui.get_text("personal|slot_enhance_parts"), part_des))
    new_open = is_new_equip_slot_enhance_open(slot_index)
    if not new_open then
      stk_detail:push(sys.format(ui.get_text("personal|slot_enhance_pers"), enhance_val_perLv))
    end
    local text = w_se_detail:search("rb_text")
    text.mtf = stk_detail.text
    update_detail_below_panel(enhance_lv)
  end
  if select_pic ~= nil then
    select_pic.visible = false
  end
  select_pic = panel:search("select")
  if select_pic ~= nil then
    select_pic.visible = true
  end
  w_se_detail.visible = true
  w_se_detail:move_to_head()
  ui_handson_teach.test_complate_slotenhance_click_enhance(true)
end
function on_click_enhance(btn)
  ui_handson_teach.test_complate_slotenhance_click_enhance(false)
  if slot_index == nil then
    return
  end
  local slot_enhance_excel = bo2.gv_slot_enhance_lv:find(enhance_lv + 1)
  if slot_enhance_excel == nil then
    return
  end
  local item_cnt = get_use_count()
  local bound = 0
  if w_use_bound_mat.check then
    bound = 1
  end
  local function confirm_enhance()
    local v = sys.variant()
    v:set(packet.key.slot_enhance_part, slot_index)
    v:set(packet.key.slot_enhance_value, enhance_lv + 1)
    v:set(packet.key.itemdata_val, bound)
    v:set(packet.key.slot_enhance_item, item_cnt)
    bo2.send_variant(packet.eCTS_UI_SlotEnhanceUp, v)
  end
  local item_id = slot_enhance_excel.item_id
  if w_use_bound_mat.check then
    item_id = get_db_item_id(item_id)
  end
  if slot_enhance_excel.money_type ~= 1 then
    local msg = {
      text = ui_widget.merge_mtf({
        money = slot_enhance_excel.money,
        cnt = item_cnt,
        item_id = item_id
      }, ui.get_text("personal|confirm_enhance_des")),
      modal = true,
      btn_confirm = true,
      btn_cancel = true,
      callback = function(data)
        if data.result == 1 then
          confirm_enhance()
        end
      end
    }
    ui_widget.ui_msg_box.show_common(msg)
  else
    confirm_enhance()
  end
end
function update_slot_enhance_detail_panel()
  if w_se_detail.visible == false then
    return
  end
  if slot_index == nil then
    return
  end
  for key, val in ipairs(slot_name_tab) do
    if slot_index == val.index - bo2.ePlayerFlagInt8_EquipSlotEnhanceBegin + bo2.eItemSlot_EquipBeg then
      enhance_lv = val.value
      break
    end
  end
  new_open = is_new_equip_slot_enhance_open(slot_index)
  if select_pic ~= nil and new_open then
    open_slot_enhance_detail(select_pic.parent)
  else
    update_detail_below_panel(enhance_lv)
  end
end
function on_gain_item_event(excel_id)
  local line = bo2.gv_slot_enhance_lv:find(enhance_lv + 1)
  local item_id = line.item_id
  local bd_item_id = get_db_item_id(item_id)
  if excel_id == item_id or excel_id == bd_item_id then
    update_slot_enhance_detail_panel()
  end
end
function on_enhance_detail_visible(ctrl, vis)
  if vis == false and select_pic ~= nil then
    select_pic.visible = false
    select_pic = nil
  end
end
function get_slotenhance_maxLv()
  return new_slot_enhance_lv_max
end
function update(count)
  local line = bo2.gv_slot_enhance_lv:find(enhance_lv + 1)
  local item_id = line.item_id
  local item_cnt = ui.item_get_count(item_id, true)
  if w_use_bound_mat.check then
    item_id = get_db_item_id(item_id)
    local b_item_cnt = ui.item_get_count(item_id, true)
    item_cnt = item_cnt + b_item_cnt
  end
  if count <= 0 or not line or item_cnt == 0 then
    return 0
  end
  if count < 0 then
    count = 0
  elseif count > line.max_item_count then
    count = line.max_item_count
  end
  if item_cnt < count then
    count = item_cnt
  end
  return count
end
function on_item_count(btn)
  local name = tostring(btn.name)
  local count = w_input_count.text.v_int
  if name == "plus" then
    count = count + 1
  elseif name == "minus" then
    count = count - 1
  elseif name == "max" then
    count = 9999
  end
  local r = update(count)
  w_input_count.text = r
end
function on_timer(t)
  local count = w_input_count.text.v_int
  local r = update(count)
  if r ~= count then
    w_input_count.text = r
  end
  update_enhance_des()
end
function on_check_bound_mat_click(ctrl)
  update_detail_below_panel(enhance_lv)
end
