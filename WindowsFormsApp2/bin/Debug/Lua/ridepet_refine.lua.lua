local m_ridepet_page_current = 0
local m_ridepet_page_count = 7
local step_ctrl
local m_target_onlyid = 0
local m_kill_onlyid = 0
local m_natural_idx = -1
local natural_map = {}
local m_natural_array_item
local m_item_id = 0
function on_ride_del(cmd, v)
  local del_id = v:get(packet.key.ridepet_onlyid).v_string
  if del_id == m_kill_onlyid then
    clear_btn_natural()
    clear_kill()
    clear_result()
  end
end
function init_once()
  natural_map[0] = {
    flag = bo2.eRidePetFlagInt32_NaturalVit,
    refine = bo2.eRidePetFlagInt32_RefineVit,
    refine_cnt = bo2.eRidePetFlagInt32_RefineVitCount,
    name = L("pet|ridepet_vit")
  }
  natural_map[1] = {
    flag = bo2.eRidePetFlagInt32_NaturalAgi,
    refine = bo2.eRidePetFlagInt32_RefineAgi,
    refine_cnt = bo2.eRidePetFlagInt32_RefineAgiCount,
    name = L("pet|ridepet_agi")
  }
  natural_map[2] = {
    flag = bo2.eRidePetFlagInt32_NaturalStr,
    refine = bo2.eRidePetFlagInt32_RefineStr,
    refine_cnt = bo2.eRidePetFlagInt32_RefineStrCount,
    name = L("pet|ridepet_str")
  }
  natural_map[3] = {
    flag = bo2.eRidePetFlagInt32_NaturalInt,
    refine = bo2.eRidePetFlagInt32_RefineInt,
    refine_cnt = bo2.eRidePetFlagInt32_RefineIntCount,
    name = L("pet|ridepet_int")
  }
  natural_map[4] = {
    flag = bo2.eRidePetFlagInt32_NaturalSpeedMax,
    refine = bo2.eRidePetFlagInt32_RefineSpeedMax,
    refine_cnt = bo2.eRidePetFlagInt32_RefineSpeedMaxCount,
    name = L("pet|ridepet_speedmax")
  }
  natural_map[5] = {
    flag = bo2.eRidePetFlagInt32_NaturalSTMax,
    refine = bo2.eRidePetFlagInt32_RefineSTMax,
    refine_cnt = bo2.eRidePetFlagInt32_RefineSTMaxCount,
    name = L("pet|ridepet_stmax")
  }
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetDel, on_ride_del, "ui_ridepet.ridepet_refine.on_ride_del")
end
function on_page_step(var)
  update_page(var.index)
end
function update_page(page)
  ui_widget.ui_stepping.set_page(step_ctrl, page, m_ridepet_page_count)
  set_ridepet_page(page)
end
function clear_ridepetlist_pic()
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      ctr:search("kill_pic").visible = false
      ctr:search("target_pic").visible = false
    end
  end
end
function update_ridepetlist_pic()
  clear_ridepetlist_pic()
  local info_kill = ui_ridepet.find_info_from_onlyid(m_kill_onlyid)
  update_ridepet_kill(info_kill)
  local info_target = ui_ridepet.find_info_from_onlyid(m_target_onlyid)
  update_ridepet_target(info_target)
end
function update_ridepet_kill(info)
  if info == nil then
    return
  end
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      if ctr:search("ridepet").grid == info.grid and m_kill_onlyid ~= 0 and m_kill_onlyid == info.onlyid then
        ctr:search("kill_pic").visible = true
      else
        ctr:search("kill_pic").visible = false
      end
    end
  end
end
function update_ridepet_target(info)
  if info == nil then
    return
  end
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      if ctr:search("ridepet").grid == info.grid and m_target_onlyid ~= 0 and m_target_onlyid == info.onlyid then
        ctr:search("target_pic").visible = true
      else
        ctr:search("target_pic").visible = false
      end
    end
  end
end
function set_ridepet_page(page)
  m_ridepet_page_current = page
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      ctr:search("ridepet").grid = page + i
    end
  end
  update_ridepetlist_pic()
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  m_target_onlyid = 0
  m_kill_onlyid = 0
  m_natural_array_item = nil
  m_item_id = 0
  clear_item()
  if vis == true then
    clear_btn_natural()
    clear_target()
    clear_kill()
    clear_result()
    clear_ridepetlist_pic()
    clear_item()
  end
end
function ridepet_item_visibale()
  local ctr2 = w_ridepet_kill_panel:control_get(2)
  local ctr3 = w_ridepet_kill_panel:control_get(3)
  if w_btn_use_item.check then
    ctr2.visible = false
    ctr3.visible = true
  else
    ctr2.visible = true
    ctr3.visible = false
  end
end
function on_init(ctrl)
  local parent = w_main:search(L("ridepet_list"))
  step_ctrl = parent:search(L("step"))
  ui_widget.ui_stepping.set_event(step_ctrl, on_page_step)
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      ctr:search("ridepet").grid = i
    end
  end
  ridepet_item_visibale()
  update_page(m_ridepet_page_current)
end
function on_ride_card_mouse(card, msg, pos, wheel)
  if card.info == nil then
    return
  end
  if msg == ui.mouse_lbutton_click then
    if ui.is_key_down(ui.VK_CONTROL) then
      ui_chat.insert_ridepet(ui.ride_encode(card.info))
    end
    return
  end
  if msg == ui.mouse_lbutton_drag then
    local onlyid = card.info.onlyid
    local value_jipo = card.info:get_flag(bo2.eRidePetFlagInt32_RideJopo)
    if 1 == value_jipo then
      ui_chat.show_ui_text_id(2623)
      return
    end
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
    ui_ridepet.ridepet_msgbox(card.info)
  end
end
function on_target_drop2(only_id)
  if tostring(only_id) == tostring(m_kill_onlyid) then
    ui_chat.show_ui_text_id(2627)
    return
  end
  local info = ui_ridepet.find_info_from_onlyid(only_id)
  if info == nil then
    return
  end
  update_target(info)
  update_btn_natural()
  update_result()
  ui.clean_drop()
  clear_ridepetlist_pic()
  update_ridepet_target(info)
  if w_btn_use_item.check then
    return
  end
  auto_add_kill_ridepet(only_id)
end
function on_target_drop(card, msg, pos, data)
  if msg == ui.mouse_rbutton_down or msg == ui.mouse_rbutton_up then
    ui.clean_drop()
    return
  end
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  local only_id = data:get("only_id")
  on_target_drop2(only_id)
end
function auto_add_target_ridepet(only_id)
  on_target_drop2(only_id)
end
function auto_add_kill_ridepet(only_id)
  if only_id == 0 then
    return
  end
  if m_kill_onlyid ~= 0 then
    local info = ui_ridepet.find_info_from_onlyid(m_kill_onlyid)
    if info == nil then
      return
    end
    update_ridepet_kill(info)
    return
  end
  local best_kill_onlyid = ui.get_best_kill_refine(only_id, m_kill_onlyid)
  on_kill_drop2(best_kill_onlyid)
end
function on_btn_ok(ctrl)
  local value = natural_map[m_natural_idx]
  if value == nil then
    return
  end
  ui_widget.ui_msg_box.show_common({
    text = ui.get_text("pet|ridepet_refine_recomend"),
    modal = true,
    btn_confirm = true,
    btn_cancel = true,
    callback = function(msg)
      if msg.result == 1 then
        if w_btn_use_item.check then
          ui_ridepet.send_refine_ride_use_item(m_target_onlyid, m_item_id, value.flag)
        else
          ui_ridepet.send_refine_ride(m_target_onlyid, m_kill_onlyid, value.flag)
        end
      end
    end
  })
end
function on_btn_natural(ctrl)
  local parent = ctrl.parent
  local control_cnt = parent.control_size
  for i = 0, control_cnt - 1 do
    local ctr = parent:control_get(i)
    if ctr == ctrl then
      if m_natural_idx ~= i then
        m_natural_idx = i
        update_result()
      else
        return
      end
    end
  end
end
function refine_save(var)
  local num = var:get(packet.key.ridepet_refine_save_value).v_int
  local only_id = var:get(packet.key.ridepet_onlyid).v_string
  auto_add_target_ridepet(only_id)
  if num <= 0 then
    return
  end
  local ridepet_type = var:get(packet.key.ridepet_natural_type).v_int
  local type_id = ridepet_type - bo2.eRidePetFlagInt32_NaturalVit
  if type_id == 4 then
    type_id = 5
  elseif type_id == 5 then
    type_id = 4
  end
  local name_map = natural_map[type_id].name
  local name = ui.get_text(name_map)
  ui_widget.ui_msg_box.show_common({
    text = ui_widget.merge_mtf({name = name, num = num}, ui.get_text("pet|ride_refine_save")),
    modal = true,
    btn_confirm = true,
    btn_cancel = true,
    callback = function(msg)
      if msg.result == 1 then
        ui_ridepet.send_save_refine(var)
      elseif msg.result == 0 then
        var:set(packet.key.ridepet_refine_save_value, 0)
        ui_ridepet.send_save_refine(var)
      end
    end
  })
end
function on_target_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_mbutton_click then
    local info = card.info
    if info == nil then
      return
    end
    ui_ridepet.ridepet_msgbox(info)
  end
  if msg == ui.mouse_rbutton_up then
    m_target_onlyid = 0
    local info = card.info
    if info == nil then
      return
    end
    clear_btn_natural()
    clear_target()
    clear_result()
    update_ridepetlist_pic()
  end
end
function on_kill_drop2(only_id)
  if tostring(only_id) == tostring(m_target_onlyid) and only_id ~= 0 then
    ui_chat.show_ui_text_id(2626)
    return
  end
  local info = ui_ridepet.find_info_from_onlyid(only_id)
  if info == nil then
    return
  end
  update_kill(info)
  update_btn_natural()
  update_result()
  ui.clean_drop()
  update_ridepet_kill(info)
end
function on_kill_drop(card, msg, pos, data)
  if msg == ui.mouse_rbutton_down or msg == ui.mouse_rbutton_up then
    ui.clean_drop()
    return
  end
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  local only_id = data:get("only_id")
  on_kill_drop2(only_id)
end
function on_kill_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_mbutton_click then
    local info = card.info
    if info == nil then
      return
    end
    ui_ridepet.ridepet_msgbox(info)
  end
  if msg == ui.mouse_rbutton_up then
    local info = card.info
    if info == nil then
      return
    end
    clear_btn_natural()
    clear_kill()
    clear_result()
    update_ridepetlist_pic()
  end
end
function on_result_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_mbutton_click then
    local info = card.info
    if info == nil then
      return
    end
    ui_ridepet.ridepet_msgbox(info)
  end
end
function update_btn_natural()
  clear_btn_natural()
  local info = ui_ridepet.find_info_from_onlyid(m_target_onlyid)
  local use_info = ui_ridepet.find_info_from_onlyid(m_kill_onlyid)
  if info == nil then
    return
  end
  local blood_id = info:get_flag(bo2.eRidePetFlagInt32_Blood)
  if blood_id == 0 then
    w_result_text.text = ui.get_text("pet|ridepet_refine_identify_recomend")
    return
  end
  local type_id = info:get_flag(bo2.eRidePetFlagInt32_Type)
  if type_id == 0 then
    return
  end
  local type_excel = bo2.gv_ridepet_type_init:find(type_id)
  if type_excel == nil then
    return
  end
  if type_excel.nNoGrow ~= 0 then
    w_result_text.text = ui.get_text("pet|ridepet_refine_ungrow_recomend")
    return
  end
  local refine = info:get_flag(bo2.eRidePetFlagInt32_Refine)
  local refine_max = info:get_flag(bo2.eRidePetFlagInt32_RefineMax)
  if refine >= refine_max then
    w_result_text.text = ui.get_text("pet|ridepet_refine_count_max")
    return
  end
  if w_btn_use_item.check then
    if m_natural_array_item == nil then
      return
    end
    local natural = natural_map[m_natural_idx]
    if natural ~= nil then
      local star = info:get_flag(natural.flag)
      local use_item_star = m_natural_array_item[m_natural_idx][0]
      if use_item_info == nil then
        return
      end
      if star > use_item_star then
        w_result_text.text = ui.get_text("pet|item_star_islower")
        return
      end
    end
  else
    if use_info == nil then
      return
    end
    local use_blood_id = use_info:get_flag(bo2.eRidePetFlagInt32_Blood)
    if use_blood_id == 0 then
      w_result_text.text = ui.get_text("pet|ridepet_refine_identify_recomend_use")
      return
    end
    local use_type_id = use_info:get_flag(bo2.eRidePetFlagInt32_Type)
    if use_type_id == 0 then
      return
    end
    local use_type_excel = bo2.gv_ridepet_type_init:find(use_type_id)
    if use_type_excel == nil then
      return
    end
    if use_type_excel.nNoGrow ~= 0 then
      w_result_text.text = ui.get_text("pet|ridepet_refine_ungrow_recomend_use")
      return
    end
  end
  local control_cnt = w_btn_natural.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_btn_natural:control_get(i)
    local natural = natural_map[i]
    local idx = natural.flag
    local natural = info:get_flag(idx)
    if not w_btn_use_item.check then
      local natural_use = use_info:get_flag(idx)
      if natural <= natural_use then
        ctr.enable = true
      end
    else
      ctr.enable = true
    end
  end
end
function clear_btn_natural()
  if m_target_onlyid ~= 0 then
    return
  end
  local control_cnt = w_btn_natural.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_btn_natural:control_get(i)
    ctr.enable = false
  end
  m_natural_idx = -1
  w_result_text.text = ""
end
function clear_target()
  w_target.grid = -1
  m_target_onlyid = 0
  w_flag_str.text = ""
  w_flag_int.text = ""
  w_flag_vit.text = ""
  w_flag_agi.text = ""
  w_flag_speedmax.text = ""
  w_flag_stmax.text = ""
  w_natural_vit.visible = true
  w_natural_vit:search("current").dx = 0
  w_natural_vit:search("max").dx = 85
  w_natural_agi.visible = true
  w_natural_agi:search("current").dx = 0
  w_natural_agi:search("max").dx = 85
  w_natural_str.visible = true
  w_natural_str:search("current").dx = 0
  w_natural_str:search("max").dx = 85
  w_natural_int.visible = true
  w_natural_int:search("current").dx = 0
  w_natural_int:search("max").dx = 85
  w_natural_speedmax.visible = true
  w_natural_speedmax:search("current").dx = 0
  w_natural_speedmax:search("max").dx = 85
  w_natural_stmax.visible = true
  w_natural_stmax:search("current").dx = 0
  w_natural_stmax:search("max").dx = 85
end
function clear_kill()
  w_kill.grid = -1
  m_kill_onlyid = 0
  w_flag_str_kill.text = ""
  w_flag_int_kill.text = ""
  w_flag_vit_kill.text = ""
  w_flag_agi_kill.text = ""
  w_flag_speedmax_kill.text = ""
  w_flag_stmax_kill.text = ""
  w_natural_vit_kill.visible = true
  w_natural_vit_kill:search("current").dx = 0
  w_natural_vit_kill:search("max").dx = 85
  w_natural_agi_kill.visible = true
  w_natural_agi_kill:search("current").dx = 0
  w_natural_agi_kill:search("max").dx = 85
  w_natural_str_kill.visible = true
  w_natural_str_kill:search("current").dx = 0
  w_natural_str_kill:search("max").dx = 85
  w_natural_int_kill.visible = true
  w_natural_int_kill:search("current").dx = 0
  w_natural_int_kill:search("max").dx = 85
  w_natural_speedmax_kill.visible = true
  w_natural_speedmax_kill:search("current").dx = 0
  w_natural_speedmax_kill:search("max").dx = 85
  w_natural_stmax_kill.visible = true
  w_natural_stmax_kill:search("current").dx = 0
  w_natural_stmax_kill:search("max").dx = 85
end
function clear_result()
  w_btn_ok.enable = false
  w_money.money = 0
  w_result.grid = -1
  w_result_text.text = ""
end
function update_target(info)
  clear_target()
  if info == nil then
    return
  end
  local type_id = info:get_flag(bo2.eRidePetFlagInt32_Type)
  local type_excel = bo2.gv_ridepet_type_init:find(type_id)
  w_target.grid = info:get_flag(bo2.eRidePetFlagInt32_Pos)
  m_target_onlyid = info.onlyid
  w_flag_str.text = info:get_flag(bo2.eRidePetFlagInt32_BaseStr)
  w_flag_int.text = info:get_flag(bo2.eRidePetFlagInt32_BaseInt)
  w_flag_vit.text = info:get_flag(bo2.eRidePetFlagInt32_BaseVit)
  w_flag_agi.text = info:get_flag(bo2.eRidePetFlagInt32_BaseAgi)
  w_flag_speedmax.text = info:get_flag(bo2.eRidePetFlagInt32_BaseSpeedMaxRun)
  w_flag_stmax.text = info:get_flag(bo2.eRidePetFlagInt32_BaseSTMax)
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
end
function update_kill(info)
  clear_kill()
  if info == nil then
    return
  end
  local type_id = info:get_flag(bo2.eRidePetFlagInt32_Type)
  local type_excel = bo2.gv_ridepet_type_init:find(type_id)
  w_kill.grid = info:get_flag(bo2.eRidePetFlagInt32_Pos)
  m_kill_onlyid = info.onlyid
  w_flag_str_kill.text = info:get_flag(bo2.eRidePetFlagInt32_BaseStr)
  w_flag_int_kill.text = info:get_flag(bo2.eRidePetFlagInt32_BaseInt)
  w_flag_vit_kill.text = info:get_flag(bo2.eRidePetFlagInt32_BaseVit)
  w_flag_agi_kill.text = info:get_flag(bo2.eRidePetFlagInt32_BaseAgi)
  w_flag_speedmax_kill.text = info:get_flag(bo2.eRidePetFlagInt32_BaseSpeedMaxRun)
  w_flag_stmax_kill.text = info:get_flag(bo2.eRidePetFlagInt32_BaseSTMax)
  if type_id == 0 then
  elseif type_excel.nNoGrow ~= 0 then
  else
    w_natural_vit_kill.visible = true
    w_natural_vit_kill:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalVit) * 17
    w_natural_vit_kill:search("max").dx = 85
    w_natural_agi_kill.visible = true
    w_natural_agi_kill:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalAgi) * 17
    w_natural_agi_kill:search("max").dx = 85
    w_natural_str_kill.visible = true
    w_natural_str_kill:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalStr) * 17
    w_natural_str_kill:search("max").dx = 85
    w_natural_int_kill.visible = true
    w_natural_int_kill:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalInt) * 17
    w_natural_int_kill:search("max").dx = 85
    w_natural_speedmax_kill.visible = true
    w_natural_speedmax_kill:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalSpeedMax) * 17
    w_natural_speedmax_kill:search("max").dx = 85
    w_natural_stmax_kill.visible = true
    w_natural_stmax_kill:search("current").dx = info:get_flag(bo2.eRidePetFlagInt32_NaturalSTMax) * 17
    w_natural_stmax_kill:search("max").dx = 85
  end
end
function update_result()
  clear_result()
  local natural = natural_map[m_natural_idx]
  if natural == nil then
    return
  end
  if m_target_onlyid == 0 then
    return
  end
  local info = ui_ridepet.find_info_from_onlyid(m_target_onlyid)
  local use_info = {}
  if info == nil then
    return
  end
  if w_btn_use_item.check then
    if m_natural_array_item == nil then
      return
    end
    local use_item_info = m_natural_array_item[m_natural_idx][0]
    if use_item_info == nil then
      return
    end
  else
    if m_kill_onlyid == 0 then
      return
    end
    use_info = ui_ridepet.find_info_from_onlyid(m_kill_onlyid)
    if use_info == nil then
      return
    end
  end
  local refine = info:get_flag(bo2.eRidePetFlagInt32_Refine)
  local refine_max = info:get_flag(bo2.eRidePetFlagInt32_RefineMax)
  if refine >= refine_max then
    return
  end
  local refine_count = info:get_flag(natural.refine_cnt)
  local refine_excel = bo2.gv_ridepet_refine:find(refine_count + 1)
  if refine_excel == nil then
    return
  end
  local star = info:get_flag(natural.flag)
  local use_star = 0
  if w_btn_use_item.check then
    local use_item_star = m_natural_array_item[m_natural_idx][0]
    if star > use_item_star then
      w_result_text.text = ui.get_text("pet|item_star_islower")
      return
    end
    use_star = use_item_star
  else
    use_star = use_info:get_flag(natural.flag)
  end
  w_btn_ok.enable = true
  w_money.money = refine_excel.nMoney
  w_result.grid = info:get_flag(bo2.eRidePetFlagInt32_Pos)
  local pct = (use_star - star + 1) * refine_excel.nBasePercent
  local text = ui_widget.merge_mtf({
    flag = ui.get_text(natural.name),
    percent = pct,
    min = refine_excel.nMin,
    max = refine_excel.nMax
  }, ui.get_text("pet|ridepet_refine_percent"))
  w_result_text.text = text
end
function on_ridepet_natural_tip(tip)
  local info = ui_ridepet.find_info_from_onlyid(m_target_onlyid)
  if info == nil then
    return
  end
  local stk = sys.mtf_stack()
  local ctr = tip.owner.parent
  local ctr_name = tip.owner.parent.name
  ui_ridepet.build_ridepet_natural_tip(ctr_name, stk, info)
  ui_tool.ctip_show(tip.owner, stk)
end
function on_ridepet_natural_use_tip(tip)
  local info = ui_ridepet.find_info_from_onlyid(m_kill_onlyid)
  if info == nil then
    return
  end
  local stk = sys.mtf_stack()
  local ctr = tip.owner.parent
  local ctr_name = tip.owner.parent.name
  ui_ridepet.build_ridepet_natural_tip(ctr_name, stk, info)
  ui_tool.ctip_show(tip.owner, stk)
end
function clear_item()
  local card = w_ridepet_kill_panel:search("card")
  if card ~= nil then
    ui_npcfunc.clear_card(card)
  end
end
function get_ridepetmodel_by_item(item_id)
  local mode_id = 0
  local id = 0
  local ridepet_id_arr = {}
  for i, v in string.gmatch(tostring(bo2.gv_define:find(1223).value), "(%w+)*(%w+)") do
    if tonumber(v) == tonumber(item_id) then
      id = i
      break
    end
  end
  for i, v in string.gmatch(tostring(bo2.gv_define:find(1224).value), "(%w+)*(%w+)") do
    ridepet_id_arr[tonumber(i)] = tonumber(v)
  end
  model_id = ridepet_id_arr[tonumber(id)]
  return model_id
end
function update_kill_use_item_info(item_id)
  clear_kill()
  local model_id = get_ridepetmodel_by_item(item_id)
  if model_id == 0 then
    return
  end
  local model_line = bo2.gv_item_list:find(model_id)
  if model_line == nil then
    return
  end
  local use_par = model_line.use_par
  if use_par == nil then
    return
  end
  local ridepet_identify_id = use_par[1]
  if ridepet_identify_id == 0 then
    return
  end
  local identify_line = bo2.gv_ridepet_identify_custom:find(ridepet_identify_id)
  if identify_line == nil then
    return
  end
  local natural_array = identify_line.vNaturalArray
  if natural_array.size ~= 6 then
    return
  end
  m_natural_array_item = natural_array
  w_natural_vit_kill.visible = true
  w_natural_vit_kill:search("current").dx = natural_array[0][0] * 17
  w_natural_vit_kill:search("max").dx = 85
  w_natural_agi_kill.visible = true
  w_natural_agi_kill:search("current").dx = natural_array[1][0] * 17
  w_natural_agi_kill:search("max").dx = 85
  w_natural_str_kill.visible = true
  w_natural_str_kill:search("current").dx = natural_array[2][0] * 17
  w_natural_str_kill:search("max").dx = 85
  w_natural_int_kill.visible = true
  w_natural_int_kill:search("current").dx = natural_array[3][0] * 17
  w_natural_int_kill:search("max").dx = 85
  w_natural_speedmax_kill.visible = true
  w_natural_speedmax_kill:search("current").dx = natural_array[5][0] * 17
  w_natural_speedmax_kill:search("max").dx = 85
  w_natural_stmax_kill.visible = true
  w_natural_stmax_kill:search("current").dx = natural_array[4][0] * 17
  w_natural_stmax_kill:search("max").dx = 85
end
function is_kill_item(item_id)
  for i, v in string.gmatch(tostring(bo2.gv_define:find(1223).value), "(%w+)*(%w+)") do
    if tonumber(v) == tonumber(item_id) then
      return true
    end
  end
  return false
end
function update_ridepet_item()
  if w_btn_use_item.check then
    clear_kill()
    update_ridepetlist_pic()
  else
    clear_item()
    auto_add_kill_ridepet(m_target_onlyid)
  end
end
function btn_use_item_click(btn)
  ridepet_item_visibale()
  update_ridepet_item()
  update_result()
end
function on_item_card_tip_show(tip)
  local stk = sys.mtf_stack()
  local card = tip.owner
  if card.info == nil then
    local text = ui.get_text("pet|item_name")
    stk:push(text)
    ui_tool.ctip_show(card, stk)
    return
  end
  ui_item.on_card_tip_show(tip)
end
function on_use_item_drop(card, msg, pos, data)
  if msg == ui.mouse_rbutton_down or msg == ui.mouse_rbutton_up then
    ui.clean_drop()
    return
  end
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  local info = ui.item_of_only_id(data:get("only_id"))
  if info == nil then
    return
  end
  local item_id = info.excel.id
  m_item_id = item_id
  if is_kill_item(item_id) then
    ui_npcfunc.on_card_drop(card, msg, pos, data)
  else
    ui_chat.show_ui_text_id(2631)
    return
  end
  update_kill_use_item_info(item_id)
  update_btn_natural()
  update_result()
end
function on_use_item_card_mouse(card, msg, pos, wheel)
  ui_npcfunc.on_card_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_rbutton_up then
    clear_kill()
    update_result()
    m_natural_array_item = nil
    m_item_id = 0
  end
end
function on_timer()
  if w_btn_use_item.check then
    local card = w_ridepet_kill_panel:search("card")
    if card == nil or card.info == nil or ui.item_get_count(card.info.excel.id, true) < 1 then
      clear_result()
      clear_item()
      clear_kill()
    end
  end
end
init_once()
