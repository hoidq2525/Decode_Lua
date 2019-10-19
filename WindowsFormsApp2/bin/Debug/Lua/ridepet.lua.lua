local f_rot_factor = 0.16
local f_rot_angle = 90
local m_skill_type = 0
local m_ridepet
local m_ridepet_page_current = 0
local m_ridepet_page_count = 7
local step_ctrl
local m_bInit = false
local flag_map = {}
local define_pet_jipo_num = bo2.gv_define:find(1212).value.v_int
local g_blood_refine_max = bo2.gv_define:find(1288).value.v_int
local define_jipo_type = bo2.gv_define:find(1282).value
local define_jipo_type_vec = {}
function GetVecFromString(str)
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
function init_once()
  t_ridepet_rbutton_data = {}
  flag_map[L("ridepet_vit")] = {
    flag = bo2.eRidePetFlagInt32_BaseVit,
    natural = bo2.eRidePetFlagInt32_NaturalVit,
    refine = bo2.eRidePetFlagInt32_RefineVit,
    refine_cnt = bo2.eRidePetFlagInt32_RefineVitCount,
    blood_refine = bo2.eRidePetFlagInt32_RefineBloodVit,
    blood_refine_cnt = bo2.eRidePetFlagInt32_RefineBloobVitCount
  }
  flag_map[L("ridepet_agi")] = {
    flag = bo2.eRidePetFlagInt32_BaseAgi,
    natural = bo2.eRidePetFlagInt32_NaturalAgi,
    refine = bo2.eRidePetFlagInt32_RefineAgi,
    refine_cnt = bo2.eRidePetFlagInt32_RefineAgiCount,
    blood_refine = bo2.eRidePetFlagInt32_RefineBloodAgi,
    blood_refine_cnt = bo2.eRidePetFlagInt32_RefineBloobAgiCount
  }
  flag_map[L("ridepet_str")] = {
    flag = bo2.eRidePetFlagInt32_BaseStr,
    natural = bo2.eRidePetFlagInt32_NaturalStr,
    refine = bo2.eRidePetFlagInt32_RefineStr,
    refine_cnt = bo2.eRidePetFlagInt32_RefineStrCount,
    blood_refine = bo2.eRidePetFlagInt32_RefineBloodStr,
    blood_refine_cnt = bo2.eRidePetFlagInt32_RefineBloobStrCount
  }
  flag_map[L("ridepet_int")] = {
    flag = bo2.eRidePetFlagInt32_BaseInt,
    natural = bo2.eRidePetFlagInt32_NaturalInt,
    refine = bo2.eRidePetFlagInt32_RefineInt,
    refine_cnt = bo2.eRidePetFlagInt32_RefineIntCount,
    blood_refine = bo2.eRidePetFlagInt32_RefineBloodInt,
    blood_refine_cnt = bo2.eRidePetFlagInt32_RefineBloobIntCount
  }
  flag_map[L("ridepet_speedmax")] = {
    flag = bo2.eRidePetFlagInt32_BaseSpeedMaxRun,
    natural = bo2.eRidePetFlagInt32_NaturalSpeedMax,
    refine = bo2.eRidePetFlagInt32_RefineSpeedMax,
    refine_cnt = bo2.eRidePetFlagInt32_RefineSpeedMaxCount
  }
  flag_map[L("ridepet_stmax")] = {
    flag = bo2.eRidePetFlagInt32_BaseSTMax,
    natural = bo2.eRidePetFlagInt32_NaturalSTMax,
    refine = bo2.eRidePetFlagInt32_RefineSTMax,
    refine_cnt = bo2.eRidePetFlagInt32_RefineSTMaxCount
  }
  bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnsmg_obj_callride, on_ride_call, "ui_ridepet.callride")
  define_jipo_type_vec = GetVecFromString(define_jipo_type)
end
function insert_ridepet_rbutton_data(w, check, use, tip)
  local d = {
    name = w.name,
    widget = w,
    check = check,
    use = use,
    tip = tip
  }
  t_ridepet_rbutton_data[d.name] = d
end
function search_rbutton_data(info)
  local h = ui_phase.w_main.control_head
  while h ~= nil do
    if h.visible then
      local d = t_ridepet_rbutton_data[h.name]
      if d ~= nil and d.check(info) then
        return d
      end
    end
    h = h.next
  end
  return nil
end
function use_tip(info)
  local d = search_rbutton_data(info)
  if d == nil then
    return nil
  end
  return d.tip(info)
end
function use_ridepet(info)
  local d = search_rbutton_data(info)
  if d == nil then
    return nil
  end
  d.use(info)
end
function on_doll_rotl_press(btn, press)
  if press then
    w_scn.rotate_angle = -f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
end
function on_doll_rotr_press(btn, press)
  if press then
    w_scn.rotate_angle = f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
end
function on_page_step(var)
  update_page(var.index)
end
function update_page(page)
  ui_widget.ui_stepping.set_page(step_ctrl, page, m_ridepet_page_count)
  set_ridepet_page(page)
end
function set_ridepet_page(page)
  local info = find_info_from_pos(ui.ride_get_select())
  if info == nil then
    return
  end
  set_jipo_image(info)
  if 0 == define_pet_jipo_num then
    w_jipo_on.visible = false
    w_jipo_off.visible = true
  end
  m_ridepet_page_current = page
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      ctr:search("ridepet").grid = page + i
    end
  end
  update_ridepet(info)
end
function item_rbutton_check(info)
  if info == nil then
    return false
  end
  local excel = info.excel
  if excel == nil then
    return false
  end
  local ptype = excel.ptype
  if ptype == nil then
    return false
  end
  if ptype.equip_slot >= bo2.eItemSlot_RidePetBegin and ptype.equip_slot < bo2.eItemSlot_RidePetEnd then
    return true
  end
  return false
end
function item_rbutton_use(info)
  ui_item.use_item_bag(info)
end
function item_rbutton_tip(info)
  return ui.get_text("common|rclick_ridepet_equip")
end
function on_init(ctrl)
  w_jipo_on.visible = false
  w_jipo_off.visible = true
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  local parent = w_ridepet:search(L("ridepet_list"))
  step_ctrl = parent:search(L("step"))
  ui_widget.ui_stepping.set_event(step_ctrl, on_page_step)
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      ctr:search("ridepet").grid = i
    end
  end
  if not bo2.IsOpenRideFight() then
    local ride_fight_btn = w_skill_type:search(L("ridepet_skill_type_3"))
    if ride_fight_btn then
      ride_fight_btn.visible = false
    end
  end
end
function on_ride_call()
  local info = find_info_from_pos(ui.ride_get_select())
  if info ~= nil then
    send_call_ride(info.onlyid)
  end
end
function on_ride_del()
  local info = find_info_from_pos(ui.ride_get_select())
  if info ~= nil then
    local ridepet_excel = bo2.gv_ridepet_list:find(info:get_flag(bo2.eRidePetFlagInt32_RidePetListId))
    if ridepet_excel ~= nil then
      ui_widget.ui_msg_box.show_common({
        text = sys.format(ui.get_text("personal|ride_del"), ridepet_excel.name),
        modal = true,
        btn_confirm = true,
        btn_cancel = true,
        callback = function(msg)
          if msg.result == 1 then
            send_del_ride(info.onlyid)
          end
        end
      })
    end
  end
end
function get_ridepet_jipo_state(info)
  local value_jipo = info:get_flag(bo2.eRidePetFlagInt32_RideJopo)
  if 1 == value_jipo then
    return true
  else
    return false
  end
end
function get_ridepet_zhenfa_state(info)
  local value_jipo = info:get_flag(bo2.eRidePetFlagInt32_ZhenFa)
  if 0 == value_jipo then
    return false
  else
    return true
  end
end
function set_jipo_image(info)
  local state = get_ridepet_jipo_state(info)
  if state then
    w_jipo_on.visible = true
    w_jipo_off.visible = false
  else
    w_jipo_on.visible = false
    w_jipo_off.visible = true
  end
end
function may_jipo(info)
  local define_pet_jipo_num = bo2.gv_define:find(1212).value.v_int
  if 0 == define_pet_jipo_num then
    ui_chat.show_ui_text_id(2651)
    return false
  end
  local value_jipo = info:get_flag(bo2.eRidePetFlagInt32_RideJopo)
  if 1 == value_jipo then
    return true
  end
  local cur_pet_jipo = ui.ridepet_jipo_get_count()
  if define_pet_jipo_num <= 0 or define_pet_jipo_num <= cur_pet_jipo then
    local var = sys.variant()
    var:set(L("pet_num"), define_pet_jipo_num)
    local data = sys.variant()
    data:set(packet.key.ui_text_id, 2616)
    data:set(packet.key.ui_text_arg, var)
    ui_chat.show_ui_text(0, data)
    return false
  end
  local define_pet_potential = bo2.gv_define:find(1222).value.v_int
  local potential = info:get_flag(bo2.eRidePetFlagInt32_Potential)
  if define_pet_potential > potential then
    ui_chat.show_ui_text_id(2630)
    return
  end
  local blood_id = info:get_flag(bo2.eRidePetFlagInt32_Blood)
  local blood_excel = bo2.gv_ridepet_blood_telent:find(blood_id)
  local cur_pet_star = blood_excel.nStar
  local define_pet_jipo_star = bo2.gv_define:find(1213).value.v_int
  if cur_pet_star < define_pet_jipo_star then
    local var = sys.variant()
    var:set(L("pet_star"), define_pet_jipo_star)
    local data = sys.variant()
    data:set(packet.key.ui_text_id, 2617)
    data:set(packet.key.ui_text_arg, var)
    ui_chat.show_ui_text(0, data)
    return false
  end
  local item_id_must = bo2.gv_define:find(1214).value.v_int
  local item_id_NOmust = bo2.gv_define:find(1215).value.v_int
  local item_id_must_str = tostring(item_id_must)
  local item_id_NOmust_str = tostring(item_id_NOmust)
  local count_must = ui.item_get_count(item_id_must_str, true)
  local count_NOmust = ui.item_get_count(item_id_NOmust_str, true)
  if 0 == item_id_must and 0 == item_id_NOmust then
    return false
  end
  if 0 == count_must and 0 == count_NOmust then
    local pItemListMust = bo2.gv_item_list:find(item_id_must_str)
    local pItemListNOMust = bo2.gv_item_list:find(item_id_NOmust_str)
    local var = sys.variant()
    var:set(L("item_id_must"), item_id_must)
    var:set(L("item_id_nomust"), item_id_NOmust)
    local data = sys.variant()
    data:set(packet.key.ui_text_id, 2618)
    data:set(packet.key.ui_text_arg, var)
    ui_chat.show_ui_text(0, data)
    return false
  end
  local item_id
  if count_must > 0 then
    item_id = item_id_must
  elseif count_NOmust > 0 then
    item_id = item_id_NOmust
  end
  return true, item_id
end
function on_ride_jipo()
  local info = find_info_from_pos(ui.ride_get_select())
  if info ~= nil then
    local ridepet_excel = bo2.gv_ridepet_list:find(info:get_flag(bo2.eRidePetFlagInt32_RidePetListId))
    local value_jipo = info:get_flag(bo2.eRidePetFlagInt32_RideJopo)
    if 1 == value_jipo then
      ui_widget.ui_msg_box.show_common({
        text = ui_widget.merge_mtf({
          item_id = item_id,
          pet_name = ridepet_excel.name
        }, ui.get_text("pet|ride_jipo_cancel")),
        modal = true,
        btn_confirm = true,
        btn_cancel = true,
        callback = function(msg)
          if msg.result == 1 then
            send_jipo_ride(info.onlyid)
          end
        end
      })
    elseif ridepet_excel ~= nil then
      local b_flag, item_id = may_jipo(info)
      if not b_flag or item_id == nil then
        return
      end
      ui_widget.ui_msg_box.show_common({
        text = ui_widget.merge_mtf({
          item_id = item_id,
          pet_name = ridepet_excel.name
        }, ui.get_text("pet|ride_jipo")),
        modal = true,
        btn_confirm = true,
        btn_cancel = true,
        callback = function(msg)
          if msg.result == 1 then
            send_jipo_ride(info.onlyid)
          end
        end
      })
    end
  end
end
function on_ride_refine()
  ui_refine.w_main.visible = not ui_refine.w_main.visible
end
function on_ride_blood_refine()
  ui_blood_refine.w_main.visible = not ui_blood_refine.w_main.visible
end
function ridepet_can_open_zhenfa(info)
  local ridepet_list_id = info:get_flag(bo2.eRidePetFlagInt32_RidePetListId)
  local ridepet_identify = info:get_flag(bo2.eRidePetFlagInt32_IdentifyCustom)
  local size = bo2.gv_open_zhenfa_ridepet_whitelist.size
  local open_zhenfa_ridepet_whitelist
  local res = false
  for i = 0, size do
    open_zhenfa_ridepet_whitelist = bo2.gv_open_zhenfa_ridepet_whitelist:find(i)
    if open_zhenfa_ridepet_whitelist and open_zhenfa_ridepet_whitelist.ridepet_list_id == ridepet_list_id and open_zhenfa_ridepet_whitelist.ridepet_identify_custom_id == ridepet_identify then
      res = true
      break
    end
  end
  return res
end
function check_open_zhenfa_item()
  local size = bo2.gv_open_zhenfa_whitelist.size
  local open_zhenfa_whitelist
  local item_id = 0
  local count = 0
  for i = 0, size do
    open_zhenfa_whitelist = bo2.gv_open_zhenfa_whitelist:find(i)
    if open_zhenfa_whitelist and open_zhenfa_whitelist.item_id then
      count = ui.item_get_count(open_zhenfa_whitelist.item_id, true)
      if count >= open_zhenfa_whitelist.count then
        item_id = open_zhenfa_whitelist.item_id
        count = open_zhenfa_whitelist.count
        break
      end
    end
  end
  return item_id, count
end
function on_ride_zhenfa()
  local info = find_info_from_pos(ui.ride_get_select())
  if get_ridepet_zhenfa_state(info) then
    ui_zhenfa.w_main.visible = not ui_zhenfa.w_main.visible
  else
    if get_ridepet_jipo_state(info) then
      ui_chat.show_ui_text_id(2683)
      return
    end
    if not ridepet_can_open_zhenfa(info) then
      ui_chat.show_ui_text_id(2694)
      return
    end
    local item_id, count = check_open_zhenfa_item()
    if count == 0 then
      ui_chat.show_ui_text_id(2695)
      return
    end
    local whitelist = bo2.gv_open_zhenfa_whitelist:find(1)
    if whitelist == nil then
      return
    end
    ui_widget.ui_msg_box.show_common({
      text = ui_widget.merge_mtf({
        item_id = whitelist.item_id
      }, ui.get_text("pet|ridepet_openzhenfa")),
      modal = true,
      btn_confirm = true,
      btn_cancel = true,
      callback = function(msg)
        if msg.result == 1 then
          send_open_zhenfa_use_item(info.onlyid)
        end
      end
    })
  end
end
function on_ride_skill_up(ctrl)
  local skill_card = ctrl.parent.parent:search("skill")
  if skill_card == nil then
    return
  end
  local info = find_info_from_pos(ui.ride_get_select())
  local state = get_ridepet_jipo_state(info)
  if info == nil then
    return
  end
  if state then
    ui_chat.show_ui_text_id(2628)
  else
    send_skill_up_ride(info.onlyid, skill_card.excelid)
  end
end
function on_ride_skill_unlock(ctrl)
  local item_id = bo2.gv_define:find(978).value.v_int
  local item_count = bo2.gv_define:find(979).value.v_int
  local skill_card = ctrl.parent.parent:search("skill")
  if skill_card == nil then
    return
  end
  local info = find_info_from_pos(ui.ride_get_select())
  local state = get_ridepet_jipo_state(info)
  if state then
    ui_chat.show_ui_text_id(2628)
    return
  end
  if info ~= nil then
    ui_widget.ui_msg_box.show_common({
      text = ui_widget.merge_mtf({cnt = item_count, item_id = item_id}, ui.get_text("pet|ridepet_unlock_recomend")),
      modal = true,
      btn_confirm = true,
      btn_cancel = true,
      callback = function(msg)
        if msg.result == 1 then
          send_skill_unlock_ride(info.onlyid, m_skill_type)
        end
      end
    })
  end
end
function on_ride_skill_delete(ctrl)
  local item_id = bo2.gv_define:find(980).value.v_int
  local item_count = bo2.gv_define:find(981).value.v_int
  local skill_card = ctrl.parent.parent:search("skill")
  if skill_card == nil then
    return
  end
  local skill_excel = bo2.gv_ridepet_skill:find(skill_card.excelid)
  if skill_excel == nil then
    return
  end
  local info = find_info_from_pos(ui.ride_get_select())
  local state = get_ridepet_jipo_state(info)
  if state then
    return
  end
  if info ~= nil then
    ui_widget.ui_msg_box.show_common({
      text = ui_widget.merge_mtf({
        cnt = item_count,
        item_id = item_id,
        skill_name = skill_excel.name
      }, ui.get_text("pet|ridepet_delete_recomend")),
      modal = true,
      btn_confirm = true,
      btn_cancel = true,
      callback = function(msg)
        if msg.result == 1 then
          send_skill_delete_ride(info.onlyid, skill_card.excelid)
        end
      end
    })
  end
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
end
function update_select_ui(info)
  clear_ui()
  set_jipo_image(info)
  if 0 == define_pet_jipo_num then
    w_jipo_on.visible = false
    w_jipo_off.visible = true
  end
  update_ui_cmn(info)
  update_ui_scn(info)
  update_ui_equip(info)
  update_ui_flag(info)
  update_ui_blood(info)
  update_ui_exp(info)
  update_ui_skill(info)
  select_skill_type(m_skill_type)
  local pos_min = m_ridepet_page_current
  local pos_max = m_ridepet_page_current + 6
  local pos = info.grid
  if pos_min > pos or pos_max <= pos then
    if pos < 6 then
      m_ridepet_page_current = 0
    else
      m_ridepet_page_current = 6
    end
  end
  update_page(m_ridepet_page_current)
end
function select_ridepet(pos)
  local cur_pos = ui.ride_get_select()
  local info = find_info_from_pos(pos)
  if info ~= nil then
    ui.ride_set_select(pos)
    update_ridepet(info)
    update_select_ui(info)
  else
    clear_ui()
    ui.ride_set_select(-1)
  end
end
function find_info_from_pos(pos)
  local info = ui.find_ride_info(bo2.eRidePetBox_Slot, pos)
  return info
end
function find_info_from_onlyid(onlyid)
  local info = ui.get_ride_info(onlyid)
  return info
end
function clear_ui()
  w_name.text = ""
  w_title.text = ui.get_text("pet|ridepet_name")
  w_flag_startype.text = ""
  w_flag_sex.text = ""
  w_flag_potential.text = ""
  w_flag_str.text = ""
  w_flag_int.text = ""
  w_flag_vit.text = ""
  w_flag_agi.text = ""
  w_flag_speedmax.text = ""
  w_flag_stmax.text = ""
  w_flag_skillpoint.text = ""
  w_loyal:search("current").dx = 0
  w_loyal:search("max").dx = 0
  w_level:search("level").text = ""
  w_level:search("exp_text").text = ""
  w_level:search("exp_cur").dx = 0
  if bo2.IsOpenRideFight() then
    w_equip:search("ridepet_weapon").visible = true
  else
    w_equip:search("ridepet_weapon").visible = false
  end
  w_equip:search("ridepet_center"):update()
  w_refine.text = ""
  w_blood_refine.text = ""
  w_multi_ride.text = ""
  w_natural_vit.visible = false
  w_natural_vit:search("current").dx = 0
  w_natural_vit:search("max").dx = 0
  w_natural_agi.visible = false
  w_natural_agi:search("current").dx = 0
  w_natural_agi:search("max").dx = 0
  w_natural_str.visible = false
  w_natural_str:search("current").dx = 0
  w_natural_str:search("max").dx = 0
  w_natural_int.visible = false
  w_natural_int:search("current").dx = 0
  w_natural_int:search("max").dx = 0
  w_natural_speedmax.visible = false
  w_natural_speedmax:search("current").dx = 0
  w_natural_speedmax:search("max").dx = 0
  w_natural_stmax.visible = false
  w_natural_stmax:search("current").dx = 0
  w_natural_stmax:search("max").dx = 0
  w_blood_picture.image = ""
  w_blood_generation.text = ""
  w_blood_telent.text = ""
  w_blood_star.visible = false
  w_blood_star_text.visible = false
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      ctr:search("select").visible = false
    end
  end
  if m_ridepet ~= nil then
    w_scn.scn:destory_obj(m_ridepet)
    m_ridepet = nil
  end
  w_skill_list:item_clear()
end
function update_ridepet(info)
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      if ctr:search("ridepet").grid == info.grid then
        ctr:search("select").visible = true
      else
        ctr:search("select").visible = false
      end
    end
  end
end
function on_ride_card_mouse(card, msg, pos, wheel)
  if card.info == nil then
    return
  end
  if msg == ui.mouse_lbutton_click then
    if ui.is_key_down(ui.VK_CONTROL) then
      ui_chat.insert_ridepet(ui.ride_encode(card.info))
    else
      local pos = card.grid
      select_ridepet(pos)
    end
    return
  end
  if msg == ui.mouse_rbutton_click then
    use_ridepet(card.info)
    return
  end
  if msg == ui.mouse_lbutton_drag then
    if card.info:get_item_flag(bo2.eRidePetItemFlag_Lock) ~= 0 then
      return
    end
    ui.clean_drop()
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_ride)
    data:set("only_id", card.info.onlyid)
    ui.set_cursor_icon(card.icon.uri)
    ui.setup_drop(ui_tool.w_drop_floater, data)
  end
  if msg == ui.mouse_mbutton_click then
    ridepet_msgbox(card.info)
  end
end
function on_ride_card_drop(card, msg, pos, data)
  if msg == ui.mouse_rbutton_down or msg == ui.mouse_rbutton_up then
    ui.clean_drop()
    return
  end
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  local info = card.info
  if info == nil then
    return
  end
  if ui_widget.check_drop(data, ui_widget.c_drop_type_ride) then
    local srcInfo = ui.get_ride_info(data:get("only_id").v_string)
    if srcInfo ~= info then
      local v = sys.variant()
      v:push_back(info.grid)
      v:push_back(srcInfo.grid)
      bo2.send_variant(packet.eCTS_UI_RideSwapPos, v)
      ui.ride_set_select(info.grid)
    end
    ui.clean_drop()
    return
  end
  if ui_widget.check_drop(data, ui_widget.c_drop_type_freezeridepet) then
    ui_safe.req_freezeridepet(info)
  elseif ui_widget.check_drop(data, ui_widget.c_drop_type_unfreezeridepet) then
    ui_safe.req_unfreezeridepet(info)
  end
end
function update_ui_cmn(info)
  w_name.text = ui_widget.merge_mtf({
    name = bo2.player.name
  }, ui.get_text("pet|ridepet_player_name"))
end
function update_ui_scn(info)
  if m_ridepet ~= nil then
    w_scn.scn:destory_obj(m_ridepet)
    m_ridepet = nil
  end
  if info == nil then
    return
  end
  local ridepet_excel = bo2.gv_ridepet_list:find(info:get_flag(bo2.eRidePetFlagInt32_RidePetListId))
  if ridepet_excel == nil then
    return
  end
  local excel = bo2.gv_ride_list:find(ridepet_excel.nRideId)
  if excel == nil then
    return
  end
  m_ridepet = w_scn.scn:create_obj(bo2.eScnObjKind_RidePet, excel.chaid)
  if excel.rideStateId > 0 then
    m_ridepet:AddState(0, excel.rideStateId)
  end
  m_ridepet.angle = 0.5 * math.pi
  w_title.text = ridepet_excel.name
end
function update_ui_equip(info)
  if info == nil then
    return
  end
  local type_id = info:get_flag(bo2.eRidePetFlagInt32_Type)
  local type_excel = bo2.gv_ridepet_type_init:find(type_id)
  if type_excel ~= nil and type_excel.nNoGrow ~= 0 then
    w_equip:search("ridepet_weapon").visible = false
    w_equip:search("ridepet_center"):update()
  end
  local nBox = info:get_flag(bo2.eRidePetFlagInt32_EquipPos) + bo2.eItemBox_RidePetBegin
  w_equip:search("ridepet_weapon"):search("card").box = nBox
  w_equip:search("ridepet_hair"):search("card").box = nBox
  w_equip:search("ridepet_body"):search("card").box = nBox
  w_equip:search("ridepet_leg"):search("card").box = nBox
  for i = bo2.eItemSlot_RidePetBegin, bo2.eItemSlot_RidePetEnd - 1 do
    m_ridepet:set_equip_model(i, info:get_equip_model(i))
  end
end
function IsTransferedBloodTelent(nId)
  if nId >= 20001 and nId <= 30000 then
    return true
  end
  return false
end
function update_ui_blood(info)
  if info == nil then
    return
  end
  local blood_id = info:get_flag(bo2.eRidePetFlagInt32_Blood)
  local blood_excel = bo2.gv_ridepet_blood_telent:find(blood_id)
  if blood_id ~= 0 then
    w_blood_picture.visible = true
    w_blood_picture.image = "$icon/item/" .. blood_excel.strIcon .. ".png"
    w_blood_generation.text = blood_excel.strGeneration
    local mtf_data = {}
    if IsTransferedBloodTelent(blood_id) then
      w_blood_telent.mtf = ui_widget.merge_mtf(mtf_data, blood_excel.name .. ui.get_text("pet|ridepet_transfer_yes"))
    else
      w_blood_telent.mtf = ui_widget.merge_mtf(mtf_data, blood_excel.name .. ui.get_text("pet|ridepet_transfer_no"))
    end
    w_blood_star.visible = true
    w_blood_star.dx = 13.6 * blood_excel.nStar
    w_blood_star_text.visible = false
    w_blood_star_text.text = ""
  else
    w_blood_picture.visible = false
    w_blood_picture.image = ""
    w_blood_generation.text = ui.get_text("pet|ridepet_blood_unknown")
    w_blood_telent.text = ui.get_text("pet|ridepet_blood_unknown")
    w_blood_star.visible = false
    w_blood_star.dx = 0
    w_blood_star_text.visible = true
    w_blood_star_text.text = ui.get_text("pet|ridepet_blood_unknown")
  end
end
function update_ui_flag(info)
  if info == nil then
    return
  end
  local star_id = info:get_flag(bo2.eRidePetFlagInt32_Star)
  local type_id = info:get_flag(bo2.eRidePetFlagInt32_Type)
  local name = ""
  local star_excel = bo2.gv_ridepet_star_init:find(star_id)
  if star_excel ~= nil then
    name = name .. star_excel.name
  end
  local type_excel = bo2.gv_ridepet_type_init:find(type_id)
  if type_excel ~= nil then
    if type_excel.nNoGrow ~= 0 then
      name = type_excel.name
    else
      name = name .. type_excel.name
    end
  end
  w_flag_startype.text = name
  local sex = info:get_flag(bo2.eRidePetFlagInt32_Sex)
  if sex == 0 then
    w_flag_sex.text = ui.get_text("pet|ridepet_sex_none")
  elseif sex == 1 then
    w_flag_sex.text = ui.get_text("pet|ridepet_sex_boy")
  elseif sex == 2 then
    w_flag_sex.text = ui.get_text("pet|ridepet_sex_girl")
  end
  w_flag_potential.text = info:get_flag(bo2.eRidePetFlagInt32_Potential)
  w_flag_str.text = info:get_flag(bo2.eRidePetFlagInt32_BaseStr)
  w_flag_int.text = info:get_flag(bo2.eRidePetFlagInt32_BaseInt)
  w_flag_vit.text = info:get_flag(bo2.eRidePetFlagInt32_BaseVit)
  w_flag_agi.text = info:get_flag(bo2.eRidePetFlagInt32_BaseAgi)
  w_flag_speedmax.text = info:get_flag(bo2.eRidePetFlagInt32_BaseSpeedMaxRun)
  w_flag_stmax.text = info:get_flag(bo2.eRidePetFlagInt32_BaseSTMax)
  w_flag_skillpoint.text = info:get_flag(bo2.eRidePetFlagInt32_FreeSkillPoint)
  w_loyal:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_Loyal) * 20
  w_loyal:search("max").dx = info:get_flag(bo2.eRidePetFlagInt32_LoyalMax) * 20
  if type_id == 0 then
  elseif type_excel.nNoGrow ~= 0 then
  else
    w_natural_vit.visible = true
    w_natural_vit:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalVit) * 17
    w_natural_vit:search("max").dx = 85
    w_natural_agi.visible = true
    w_natural_agi:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalAgi) * 17
    w_natural_agi:search("max").dx = 85
    w_natural_str.visible = true
    w_natural_str:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalStr) * 17
    w_natural_str:search("max").dx = 85
    w_natural_int.visible = true
    w_natural_int:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalInt) * 17
    w_natural_int:search("max").dx = 85
    w_natural_speedmax.visible = true
    w_natural_speedmax:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalSpeedMax) * 17
    w_natural_speedmax:search("max").dx = 85
    w_natural_stmax.visible = true
    w_natural_stmax:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalSTMax) * 17
    w_natural_stmax:search("max").dx = 85
  end
  local level = info:get_flag(bo2.eRidePetFlagInt32_Level)
  local exp = info:get_flag(bo2.eRidePetFlagInt32_Exp)
  local level_excel = bo2.gv_ridepet_level:find(level)
  if level_excel ~= nil then
    local exp_max = level_excel.nExpMax
    local exp_text = tostring(exp) .. "/" .. tostring(exp_max)
    w_level:search("exp_text").text = exp_text
    w_level:search("exp_cur").dx = exp / exp_max * 220
  else
    w_level:search("exp_text").text = ""
    w_level:search("exp_cur").dx = 0
  end
  w_level:search("level").text = level
  local refine = info:get_flag(bo2.eRidePetFlagInt32_Refine)
  local refine_max = info:get_flag(bo2.eRidePetFlagInt32_RefineMax)
  w_refine.text = tostring(refine) .. "/" .. tostring(refine_max)
  local blood_refine = info:get_flag(bo2.eRidePetFlagInt32_BloobRefineCount)
  w_blood_refine.text = tostring(blood_refine) .. "/" .. tostring(g_blood_refine_max)
  local ridepet_excel = bo2.gv_ridepet_list:find(info:get_flag(bo2.eRidePetFlagInt32_RidePetListId))
  if ridepet_excel == nil then
    return
  end
  local ride_excel = bo2.gv_ride_list:find(ridepet_excel.nRideId)
  if ride_excel == nil then
    return
  end
  local multiRide = info:get_flag_8(bo2.eRidePetFlagInt8_MultiRide) ~= 0 or ride_excel.multiRide ~= 0
  if multiRide ~= false then
    w_multi_ride.text = ui.get_text("pet|ridepet_multi_ride_yes")
  else
    w_multi_ride.text = ui.get_text("pet|ridepet_multi_ride_no")
  end
end
function update_ui_exp(info)
  if info == nil then
    return
  end
  local level = info:get_flag(bo2.eRidePetFlagInt32_Level)
  local level_excel = bo2.gv_ridepet_level:find(level)
  local exp = info:get_flag(bo2.eRidePetFlagInt32_Exp)
  if level_excel ~= nil then
    local exp_max = level_excel.nExpMax
    local exp_text = tostring(exp) .. "/" .. tostring(exp_max)
    w_level:search("exp_text").text = exp_text
    w_level:search("exp_cur").dx = exp / exp_max * 220
  else
    w_level:search("exp_text").text = ""
    w_level:search("exp_cur").dx = 0
  end
end
function update_ui_skill(info)
  if info == nil then
    return
  end
  local page_uri = "$frame/ridepet/ridepet.xml"
  local list_name = "ridepet_skill"
  w_skill_list:item_clear()
  local type = info:get_flag(bo2.eRidePetFlagInt32_Type)
  local type_excel = bo2.gv_ridepet_type_init:find(type)
  if type_excel == nil then
    return
  end
  local cnt = 0
  local unlock_cnt = 0
  if m_skill_type == bo2.eRidePetSlot_BaZhan then
    cnt = type_excel.nFinalSkillSlot0
    unlock_cnt = info:get_flag(bo2.eRidePetFlagInt32_SkillSlot0)
    w_flag_skillpoint.parent.visible = true
  elseif m_skill_type == bo2.eRidePetSlot_YouZhu then
    cnt = type_excel.nFinalSkillSlot1
    unlock_cnt = info:get_flag(bo2.eRidePetFlagInt32_SkillSlot1)
    w_flag_skillpoint.parent.visible = true
  elseif m_skill_type == bo2.eRidePetSlot_ZhuiFeng then
    cnt = type_excel.nFinalSkillSlot2
    unlock_cnt = info:get_flag(bo2.eRidePetFlagInt32_SkillSlot2)
    w_flag_skillpoint.parent.visible = true
  elseif m_skill_type == bo2.eRidePetSlot_RideFight then
    cnt = type_excel.nFinalSkillSlot3
    unlock_cnt = info:get_flag(bo2.eRidePetFlagInt32_SkillSlot3)
    w_flag_skillpoint.parent.visible = false
  end
  for i = 0, cnt - 1 do
    local list_item = w_skill_list:item_append()
    list_item:load_style(page_uri, list_name)
    if i >= unlock_cnt then
      local skill_back_lock = list_item:search("skill_back_lock")
      skill_back_lock.visible = true
      if i == unlock_cnt then
        local ridepet_skill_unlock = list_item:search("ridepet_skill_unlock")
        ridepet_skill_unlock.visible = true
        local state = get_ridepet_jipo_state(info)
        if state then
          ridepet_skill_unlock.visible = false
        end
      end
    else
      local skill_back_normal = list_item:search("skill_back_normal")
      skill_back_normal.visible = true
    end
  end
  local index = 0
  cnt = info:get_skill_cnt()
  for i = 0, cnt - 1 do
    local skill_info = info:get_skill(i)
    if skill_info ~= nil then
      local ridepet_skill_excel = bo2.gv_ridepet_skill:find(skill_info.excel_id)
      local skill_name = ridepet_skill_excel.name
      local skill_max_level = ridepet_skill_excel.nMaxLevel
      if ridepet_skill_excel.nSkillGroup == m_skill_type then
        local list_item = w_skill_list:item_get(index)
        local skill_ctr = list_item:search("skill")
        skill_ctr.excelid = skill_info.excel_id
        skill_ctr.onlyid = info.onlyid
        local name_text_ctr = list_item:search("name_text")
        name_text_ctr.visible = true
        name_text_ctr.text = skill_name
        local skill_btn_ctr = list_item:search("ridepet_skill_up")
        if skill_info.lock == 0 and skill_max_level > skill_info.level then
          skill_btn_ctr.visible = true
        end
        local level_text_ctr = list_item:search("level_text")
        level_text_ctr.visible = true
        level_text_ctr.text = tostring(skill_info.level) .. "/" .. tostring(skill_max_level)
        if ridepet_skill_excel.nSkillGroup == bo2.eRidePetSlot_RideFight then
          skill_btn_ctr.visible = false
        else
          local ridepet_skill_delete = list_item:search("ridepet_skill_delete")
          ridepet_skill_delete.visible = true
        end
        local ridepet_skill_unlock = list_item:search("ridepet_skill_unlock")
        ridepet_skill_unlock.visible = false
        local state = get_ridepet_jipo_state(info)
        if state then
          skill_btn_ctr.visible = false
          local ridepet_skill_delete = list_item:search("ridepet_skill_delete")
          ridepet_skill_delete.visible = false
          local ridepet_skill_unlock = list_item:search("ridepet_skill_unlock")
          ridepet_skill_unlock.visible = false
        end
        index = index + 1
      end
    end
  end
end
function add_ui_skill(info)
  update_ui_skill(info)
end
function del_ui_skill(info)
  chg_ui_skill(info)
end
function chg_ui_skill(info)
  if info == nil then
    return
  end
  local type = info:get_flag(bo2.eRidePetFlagInt32_Type)
  local type_excel = bo2.gv_ridepet_type_init:find(type)
  if type_excel == nil then
    return
  end
  local cnt = w_skill_list.item_count
  local unlock_cnt = 0
  if m_skill_type == bo2.eRidePetSlot_BaZhan then
    unlock_cnt = info:get_flag(bo2.eRidePetFlagInt32_SkillSlot0)
  elseif m_skill_type == bo2.eRidePetSlot_YouZhu then
    unlock_cnt = info:get_flag(bo2.eRidePetFlagInt32_SkillSlot1)
  elseif m_skill_type == bo2.eRidePetSlot_ZhuiFeng then
    unlock_cnt = info:get_flag(bo2.eRidePetFlagInt32_SkillSlot2)
  elseif m_skill_type == bo2.eRidePetSlot_RideFight then
    unlock_cnt = info:get_flag(bo2.eRidePetFlagInt32_SkillSlot3)
  end
  for i = 0, cnt - 1 do
    local list_item = w_skill_list:item_get(i)
    local skill_ctr = list_item:search("skill")
    skill_ctr.excelid = 0
    skill_ctr.onlyid = 0
    local skill_back_lock = list_item:search("skill_back_lock")
    skill_back_lock.visible = false
    local ridepet_skill_unlock = list_item:search("ridepet_skill_unlock")
    ridepet_skill_unlock.visible = false
    local skill_back_normal = list_item:search("skill_back_normal")
    skill_back_normal.visible = false
    local name_text_ctr = list_item:search("name_text")
    name_text_ctr.visible = false
    local skill_btn_ctr = list_item:search("ridepet_skill_up")
    skill_btn_ctr.visible = false
    local level_text_ctr = list_item:search("level_text")
    level_text_ctr.visible = false
    local ridepet_skill_delete = list_item:search("ridepet_skill_delete")
    ridepet_skill_delete.visible = false
    local ridepet_skill_unlock = list_item:search("ridepet_skill_unlock")
    ridepet_skill_unlock.visible = false
    if i >= unlock_cnt then
      skill_back_lock.visible = true
      if i == unlock_cnt then
        ridepet_skill_unlock.visible = true
        local state = get_ridepet_jipo_state(info)
        if state then
          ridepet_skill_unlock.visible = false
        end
      end
    else
      skill_back_normal.visible = true
    end
  end
  local index = 0
  cnt = info:get_skill_cnt()
  for i = 0, cnt - 1 do
    local skill_info = info:get_skill(i)
    if skill_info ~= nil then
      local ridepet_skill_excel = bo2.gv_ridepet_skill:find(skill_info.excel_id)
      local skill_name = ridepet_skill_excel.name
      local skill_max_level = ridepet_skill_excel.nMaxLevel
      if ridepet_skill_excel.nSkillGroup == m_skill_type then
        local list_item = w_skill_list:item_get(index)
        local skill_ctr = list_item:search("skill")
        skill_ctr.excelid = skill_info.excel_id
        skill_ctr.onlyid = info.onlyid
        local name_text_ctr = list_item:search("name_text")
        name_text_ctr.visible = true
        name_text_ctr.text = skill_name
        local skill_btn_ctr = list_item:search("ridepet_skill_up")
        if skill_info.lock == 0 and skill_max_level > skill_info.level then
          skill_btn_ctr.visible = true
        end
        local level_text_ctr = list_item:search("level_text")
        level_text_ctr.visible = true
        level_text_ctr.text = tostring(skill_info.level) .. "/" .. tostring(skill_max_level)
        if ridepet_skill_excel.nSkillGroup == bo2.eRidePetSlot_RideFight then
          skill_btn_ctr.visible = false
        else
          local ridepet_skill_delete = list_item:search("ridepet_skill_delete")
          ridepet_skill_delete.visible = true
        end
        local ridepet_skill_unlock = list_item:search("ridepet_skill_unlock")
        ridepet_skill_unlock.visible = false
        local state = get_ridepet_jipo_state(info)
        if state then
          skill_btn_ctr.visible = false
          local ridepet_skill_delete = list_item:search("ridepet_skill_delete")
          ridepet_skill_delete.visible = false
          local ridepet_skill_unlock = list_item:search("ridepet_skill_unlock")
          ridepet_skill_unlock.visible = false
        end
        index = index + 1
      end
    end
  end
end
function select_skill_type(skill_type)
  local control_cnt = w_skill_type.control_size
  if skill_type > control_cnt then
    return
  end
  local ctr = w_skill_type:control_get(skill_type)
  ctr.press = true
end
function on_skill_type(btn)
  local parent = btn.parent
  local control_cnt = parent.control_size
  for i = 0, control_cnt - 1 do
    local ctr = parent:control_get(i)
    if ctr == btn then
      if m_skill_type ~= i then
        m_skill_type = i
      else
        return
      end
    end
  end
  local info = find_info_from_pos(ui.ride_get_select())
  update_ui_skill(info)
end
function on_ride_update_curent()
  local ridepet_pos = -1
  if bo2.player ~= nil then
    local pRide = bo2.player:get_ridepet()
    if pRide ~= nil then
      ridepet_pos = pRide:get_flag_int32(bo2.eRidePetFlagInt32_Pos)
    end
  end
  if info ~= nil then
  end
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      if ctr:search("ridepet").grid == ridepet_pos then
        ctr:search("current").visible = true
      else
        ctr:search("current").visible = false
      end
    end
  end
end
function on_ridepet_equip_tip(tip)
  local stk = sys.mtf_stack()
  local ctr = tip.owner
  local ctr_name = tostring(tip.owner.parent.name)
  local tip_name = "pet|tip_" .. ctr_name
  text = ui.get_text(tip_name)
  stk:push(text)
  ui_tool.ctip_show(ctr, stk)
end
function on_ridepet_cmn_tip(tip)
  local stk = sys.mtf_stack()
  local ctr = tip.owner
  local ctr_name = tostring(tip.owner.name)
  local tip_name = "pet|tip_" .. ctr_name
  local text = ui.get_text(tip_name)
  if tip.owner.name == L("ridepet_jipo_off") or tip.owner.name == L("ridepet_jipo_on") then
    local arg = sys.variant()
    arg:set("max", define_pet_jipo_num)
    local max_text = sys.mtf_merge(arg, ui.get_text("pet|tip_ridepet_jipo_max"))
    if define_jipo_type_vec.size == 0 then
      return false
    end
    local type_text = ui.get_text("pet|tip_ridepet_jipo_type")
    for i, v in ipairs(define_jipo_type_vec) do
      if tonumber(v) ~= 0 then
        local var = sys.variant()
        var:set("num", v)
        local type_text_tmp = sys.mtf_merge(var, ui.get_text("pet|tip_ridepet_jipo_type" .. i))
        type_text = type_text .. type_text_tmp
      end
    end
    text = text .. max_text .. type_text
  end
  stk:push(text)
  ui_tool.ctip_show(ctr, stk)
end
function on_ridepet_flag_tip(tip)
  function insertItem(stk, name, text)
    stk:raw_push("<a+:l>")
    ui_tool.ctip_push_text(stk, name, SHARED("ffffff"))
    stk:raw_push("<a->")
    ui_tool.ctip_push_text(stk, text, SHARED("dccdb0"))
    stk:raw_push(SHARED("\n"))
  end
  local stk = sys.mtf_stack()
  local ctr = tip.owner.parent
  local ctr_name = tostring(tip.owner.parent.name)
  ctr_flag = ctr:search("flag")
  local text = ui.get_text("pet|" .. ctr_name)
  insertItem(stk, text .. ":", ctr_flag.text)
  local tip_name = "pet|tip_" .. ctr_name
  text = ui.get_text(tip_name)
  stk:push(text)
  ui_tool.ctip_show(tip.owner, stk)
end
function build_ridepet_natural_tip(ctr_name, stk, info)
  function insertItem(stk, name, text)
    stk:raw_push("<a+:l>")
    ui_tool.ctip_push_text(stk, name, SHARED("ffffff"))
    stk:raw_push("<a->")
    ui_tool.ctip_push_text(stk, text, SHARED("dccdb0"))
    stk:raw_push(SHARED("\n"))
  end
  local flag_value = flag_map[ctr_name]
  if flag_value ~= nil then
    local name = ui.get_text("pet|" .. ctr_name) .. ui.get_text("pet|ridepet_type")
    local natural_id = info:get_flag(flag_value.natural)
    local natural_excel = bo2.gv_ridepet_natural:find(natural_id)
    if natural_excel == nil then
      return
    end
    insertItem(stk, name .. ":", natural_excel.name)
    name = ui.get_text("pet|ridepet_refine_add")
    local refine_value = info:get_flag(flag_value.refine)
    refine_value = refine_value .. "%"
    insertItem(stk, name .. ":", refine_value)
    name = ui.get_text("pet|ridepet_refine_count")
    local refine_cnt = info:get_flag(flag_value.refine_cnt)
    insertItem(stk, name .. ":", refine_cnt)
    if flag_value.blood_refine then
      name = ui.get_text("pet|ridepet_blood_refine_add")
      refine_value = info:get_flag(flag_value.blood_refine)
      insertItem(stk, name .. ":", refine_value)
      name = ui.get_text("pet|ridepet_blood_refine_count")
      refine_cnt = info:get_flag(flag_value.blood_refine_cnt)
      insertItem(stk, name .. ":", refine_cnt)
    end
    local tip_name = "pet|tip_ridepet_refine_text"
    text = ui.get_text(tip_name)
    stk:push(text)
  end
end
function on_ridepet_natural_tip(tip)
  local owner = tip.owner
  local info
  if owner.topper == ui_ridepet_view.w_ridepet then
    info = ui.ride_find_cur_view()
  else
    local pos = ui.ride_get_select()
    info = find_info_from_pos(pos)
    if info == nil then
      return
    end
  end
  if info == nil or sys.check(info) ~= true then
    return
  end
  local stk = sys.mtf_stack()
  local ctr = tip.owner.parent
  local ctr_name = tip.owner.parent.name
  build_ridepet_natural_tip(ctr_name, stk, info)
  ui_tool.ctip_show(tip.owner, stk)
end
function on_ridepet_tip(tip)
  local stk = sys.mtf_stack()
  local card = tip.owner
  if card.info == nil then
    local text = ui.get_text("pet|ridepet_name")
    stk:push(text)
    ui_tool.ctip_show(card, stk)
    return
  end
  ctip_make_ridepet(stk, card.info)
  ui_tool.ctip_show_custom(card, stk, 200)
end
function build_ridepet_tip(stk, info)
  function insertItem(stk, name, text)
    stk:raw_push("<a+:l>")
    ui_tool.ctip_push_text(stk, name, SHARED("00FF00"))
    stk:raw_push("<a->")
    stk:raw_push("<a+:r>")
    ui_tool.ctip_push_text(stk, "    " .. text, SHARED("FFFFFF"))
    stk:raw_push("<a->")
  end
  local ridepet_excel = bo2.gv_ridepet_list:find(info:get_flag(bo2.eRidePetFlagInt32_RidePetListId))
  stk:raw_format("<imt:$icon/item/%s.png*42,42*", ridepet_excel.strIcon)
  do
    local stkhead = sys.mtf_stack()
    ui_tool.ctip_push_text(stkhead, " " .. ridepet_excel.name, SHARED("FFD800"))
    stk:push(stkhead.text)
    stk:raw_push(">")
    stk:raw_push(SHARED("\n"))
  end
  do
    local level = ui.safe_get_atb(bo2.eAtb_Level)
    local ride_level = info:get_flag(bo2.eRidePetFlagInt32_Level)
    if level >= ride_level then
    else
      ui_tool.ctip_push_sep(stk)
      local arg = sys.variant()
      arg:set("level", ride_level)
      local level_text = sys.mtf_merge(arg, ui.get_text("pet|tip_ridepet_master_level"))
      stk:raw_push(level_text)
    end
  end
  local blood_excel = bo2.gv_ridepet_blood_telent:find(info:get_flag(bo2.eRidePetFlagInt32_Blood))
  local star_excel = bo2.gv_ridepet_star_init:find(info:get_flag(bo2.eRidePetFlagInt32_Star))
  local type_excel = bo2.gv_ridepet_type_init:find(info:get_flag(bo2.eRidePetFlagInt32_Type))
  ui_tool.ctip_push_sep(stk)
  insertItem(stk, ui.get_text("pet|ridepet_level"), info:get_flag(bo2.eRidePetFlagInt32_Level))
  stk:raw_push(SHARED("\n"))
  do
    local text = ""
    text = blood_excel.name
    insertItem(stk, ui.get_text("pet|ridepet_blood_telent_text"), text)
    stk:raw_push(SHARED("\n"))
    text = blood_excel.strGeneration
    insertItem(stk, ui.get_text("pet|ridepet_blood_generation_text"), text)
    stk:raw_push(SHARED("\n"))
    text = ""
    if star_excel ~= nil and type_excel.nNoGrow == 0 then
      text = text .. star_excel.name
    end
    if type_excel ~= nil then
      text = text .. type_excel.name
    end
    insertItem(stk, ui.get_text("pet|ridepet_type"), text)
    stk:raw_push(SHARED("\n"))
    local sex = info:get_flag(bo2.eRidePetFlagInt32_Sex)
    if sex == 0 then
      text = ui.get_text("pet|ridepet_sex_none")
    elseif sex == 1 then
      text = ui.get_text("pet|ridepet_sex_boy")
    elseif sex == 2 then
      text = ui.get_text("pet|ridepet_sex_girl")
    end
    insertItem(stk, ui.get_text("pet|ridepet_sex"), text)
    stk:raw_push(SHARED("\n"))
    insertItem(stk, ui.get_text("pet|ridepet_potential"), info:get_flag(bo2.eRidePetFlagInt32_Potential))
    stk:raw_push(SHARED("\n"))
    text = tostring(info:get_flag(bo2.eRidePetFlagInt32_Loyal)) .. "/" .. tostring(info:get_flag(bo2.eRidePetFlagInt32_LoyalMax))
    insertItem(stk, ui.get_text("pet|ridepet_loyal"), text)
    stk:raw_push(SHARED("\n"))
    insertItem(stk, ui.get_text("pet|ridepet_vit"), info:get_flag(bo2.eRidePetFlagInt32_BaseVit))
    stk:raw_push(SHARED("\n"))
    insertItem(stk, ui.get_text("pet|ridepet_agi"), info:get_flag(bo2.eRidePetFlagInt32_BaseAgi))
    stk:raw_push(SHARED("\n"))
    insertItem(stk, ui.get_text("pet|ridepet_str"), info:get_flag(bo2.eRidePetFlagInt32_BaseStr))
    stk:raw_push(SHARED("\n"))
    insertItem(stk, ui.get_text("pet|ridepet_int"), info:get_flag(bo2.eRidePetFlagInt32_BaseInt))
    stk:raw_push(SHARED("\n"))
    insertItem(stk, ui.get_text("pet|ridepet_speedmax"), info:get_flag(bo2.eRidePetFlagInt32_BaseSpeedMaxRun))
    stk:raw_push(SHARED("\n"))
    insertItem(stk, ui.get_text("pet|ridepet_stmax"), info:get_flag(bo2.eRidePetFlagInt32_BaseSTMax))
    stk:raw_push(SHARED("\n"))
    local ride_excel = bo2.gv_ride_list:find(ridepet_excel.nRideId)
    if ride_excel == nil then
      return
    end
    local multiRide = info:get_flag_8(bo2.eRidePetFlagInt8_MultiRide) ~= 0 or ride_excel.multiRide ~= 0
    if multiRide ~= false then
      insertItem(stk, ui.get_text("pet|ridepet_multi_ride_text"), ui.get_text("pet|ridepet_multi_ride_yes"))
    else
      insertItem(stk, ui.get_text("pet|ridepet_multi_ride_text"), ui.get_text("pet|ridepet_multi_ride_no"))
    end
  end
  if info == nil then
  else
    local lock = info:get_flag(bo2.eRidePetFlagInt32_SafeFrozen)
    if lock == 0 then
    elseif lock == 1 then
      ui_tool.ctip_push_sep(stk)
      stk:raw_format(ui.get_text("tool|item_safe_frozen"))
    else
      local txt = ui.get_text("tool|item_unfreeze_remain")
      local life_second = 0
      local life_sec = math.floor(info:get_item_flag(bo2.eRidePetItemFlag_UnfreezeRemain))
      local span_sec = math.floor(sys.dtick(sys.tick(), info:get_item_flag(bo2.eRidePetItemFlag_UnfreezeUpdate)) / 1000)
      if life_sec <= span_sec then
        life_second = 0
      else
        life_second = life_sec - span_sec
      end
      ui_tool.ctip_push_sep(stk)
      stk:raw_push("<c+:FFFF00><lb:,,,|")
      stk:push(txt)
      stk:push(ui_tool.ctip_time_text(life_second))
      stk:raw_push("><c->")
    end
  end
  if 0 >= type_excel.strText.size then
  else
    ui_tool.ctip_push_sep(stk)
    stk:raw_format("<c+:9F601B>%s<c->", type_excel.strText)
  end
end
function ctip_make_ridepet(stk, info)
  build_ridepet_tip(stk, info)
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("item|middle_click"), ui_tool.cs_tip_color_operation)
  stk:raw_push(SHARED("\n"))
  ui_tool.ctip_push_text(stk, ui.get_text("ridepet|lclick_drag"), ui_tool.cs_tip_color_operation)
  if info.box == bo2.eRidePetBox_Slot then
    local txt = use_tip(info)
    if txt ~= nil then
      stk:raw_push(SHARED("\n"))
      ui_tool.ctip_push_text(stk, txt, ui_tool.cs_tip_color_operation)
    end
  end
end
function ridepet_msgbox(info)
  if info == nil then
    return
  end
  local stk = sys.mtf_stack()
  build_ridepet_tip(stk, info)
  ui_item.show_ridepet_tip_frame(stk.text)
end
function build_ridepet_skill_tip(stk, info)
  if info == nil then
    return
  end
  local ridepet_info = find_info_from_onlyid(info.onlyid)
  local skill_excel = bo2.gv_ridepet_skill:find(info.excel_id)
  if skill_excel ~= nil then
    stk:raw_push("<a+:m>")
    stk:raw_push(sys.format("<lb:art,16,,%s|", "ffffff"))
    stk:push(sys.format("%s", skill_excel.name))
    stk:raw_push(">")
    stk:raw_push("<a->")
    stk:raw_push(SHARED("\n"))
    stk:raw_format("<ridepet_skill_icon:$icon/skill/%s.png*", skill_excel.strIcon)
    local stkhead = sys.mtf_stack()
    stkhead:raw_push("<a+:r>")
    ui_tool.ctip_push_text(stkhead, info.level, SHARED("ffffff"))
    ui_tool.ctip_push_text(stkhead, ui.get_text("pet|tip_ridepet_level_sub"), SHARED("00ff00"))
    stkhead:raw_push("<a->")
    stkhead:push("*")
    stkhead:raw_push("<a+:r>")
    if info.lock ~= 0 then
      ui_tool.ctip_push_text(stkhead, ui.get_text("pet|tip_ridepet_skill_lock_no"), SHARED("ff0000"))
    else
      ui_tool.ctip_push_text(stkhead, ui.get_text("pet|tip_ridepet_skill_lock_yes"), SHARED("00ff00"))
    end
    stkhead:raw_push("<a->")
    stk:push(stkhead.text)
    stk:raw_push(">")
    stk:raw_push(SHARED("\n"))
    if info.lock ~= 0 then
    elseif info.level == 0 then
      ui_tool.ctip_push_sep(stk)
      ui_tool.ctip_push_text(stk, ui.get_text("pet|tip_ridepet_skill_init"), SHARED("00ff00"))
    else
      local idx = info.level - 1
      if idx < 10 then
        idx = skill_excel.nLevelIdArray[idx]
        local skill_level_excel = bo2.gv_ridepet_skill_level:find(idx)
        if skill_level_excel ~= nil then
          local nSkillGroup = skill_excel.nLinkSkillId
          local pSkillGroup = bo2.gv_skill_group:find(nSkillGroup)
          if pSkillGroup ~= nil then
            ui_tool.ctip_push_sep(stk)
            stk:raw_push("<a:l>")
            stk:raw_push(pSkillGroup.desc)
            stk:raw_push("\n")
          end
          ui_tool.ctip_push_sep(stk)
          stk:push(ui.get_text("pet|tip_ridepet_current_effect"))
          ui_tool.ctip_push_text(stk, skill_level_excel.strTip, SHARED("00ff00"))
        end
      end
    end
    ui_tool.ctip_push_sep(stk)
    if info.lock ~= 0 then
      ui_tool.ctip_push_text(stk, ui.get_text("pet|tip_ridepet_skill_lock_condition"), SHARED("ffffff"))
      stk:raw_push(SHARED("\n"))
      local cnt = skill_excel.vLockId.size
      for i = 0, cnt - 1 do
        local lock_excel = bo2.gv_ridepet_skill_lock:find(skill_excel.vLockId[i])
        if lock_excel then
          if lock_excel.nLockType == 0 and lock_excel.vParam1.size == 1 then
            local color = SHARED("ff0000")
            if ridepet_info ~= nil and ridepet_info:get_flag(bo2.eRidePetFlagInt32_Level) >= lock_excel.vParam1[0] then
              color = SHARED("00ff00")
            end
            local arg = sys.variant()
            arg:set("level", lock_excel.vParam1[0])
            local level_text = sys.mtf_merge(arg, ui.get_text("pet|tip_ridepet_level_need"))
            ui_tool.ctip_push_text(stk, level_text, color)
            stk:raw_push(SHARED("\n"))
          elseif lock_excel.nLockType == 1 then
            local color = SHARED("ff0000")
            local temp_skill_cnt = lock_excel.vParam1.size
            for cur = 0, temp_skill_cnt - 1 do
              local temp_skill_id = lock_excel.vParam1[cur]
              temp_skill_excel = bo2.gv_ridepet_skill:find(temp_skill_id)
              if temp_skill_excel ~= nil and (ridepet_info ~= nil and ridepet_info:get_flag(bo2.eRidePetFlagInt32_Type) == temp_skill_excel.nType or temp_skill_excel.nType == 0) then
                local temp_skill_info = ridepet_info:find_skill(temp_skill_id)
                if temp_skill_info ~= nil and temp_skill_info.level >= lock_excel.nParam2 then
                  color = SHARED("00ff00")
                end
                local arg = sys.variant()
                arg:set("name", temp_skill_excel.name)
                arg:set("level", lock_excel.nParam2)
                local level_text = sys.mtf_merge(arg, ui.get_text("pet|tip_ridepet_skill_level_need"))
                ui_tool.ctip_push_text(stk, level_text, color)
                stk:raw_push(SHARED("\n"))
                break
              end
            end
          end
        end
      end
    else
      stk:push(ui.get_text("pet|tip_ridepet_skill_next_level"))
      stk:raw_push("<a+:r>")
      if info.level < skill_excel.nMaxLevel then
        ui_tool.ctip_push_text(stk, info.level + 1, SHARED("ffffff"))
        ui_tool.ctip_push_text(stk, ui.get_text("pet|tip_ridepet_level_sub"), SHARED("00ff00"))
      else
        ui_tool.ctip_push_text(stk, ui.get_text("pet|tip_ridepet_level_top"), SHARED("ff0000"))
      end
      stk:raw_push("<a->")
      if info.lock == 0 and info.level < skill_excel.nMaxLevel and skill_excel.nSkillGroup ~= bo2.eRidePetSlot_RideFight then
        stk:raw_push(SHARED("\n"))
      end
    end
    if info.lock == 0 and info.level < skill_excel.nMaxLevel and skill_excel.nSkillGroup ~= bo2.eRidePetSlot_RideFight then
      stk:push(ui.get_text("pet|tip_ridepet_skill_level_consume"))
      stk:raw_push("<a+:r>")
      ui_tool.ctip_push_text(stk, skill_excel.nCostSkillPoint, SHARED("ffffff"))
      ui_tool.ctip_push_text(stk, ui.get_text("pet|tip_riddpet_skill_point"), SHARED("00ff00"))
      stk:raw_push("<a->")
    end
    local idx = info.level
    if idx < 10 then
      idx = skill_excel.nLevelIdArray[idx]
      local skill_level_excel = bo2.gv_ridepet_skill_level:find(idx)
      if skill_level_excel ~= nil then
        ui_tool.ctip_push_sep(stk)
        stk:push(ui.get_text("pet|tip_ridepet_next_effect"))
        ui_tool.ctip_push_text(stk, skill_level_excel.strTip, SHARED("ffffff"))
      end
    end
  end
end
function on_ridepet_skill_tip(tip)
  local stk = sys.mtf_stack()
  local card = tip.owner
  local info = card.info
  if info == nil then
    return
  end
  build_ridepet_skill_tip(stk, info)
  ui_tool.ctip_show(card, stk)
end
init_once()
