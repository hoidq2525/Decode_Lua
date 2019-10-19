local m_ridepet_page_current = 0
local m_ridepet_page_count = 7
local step_ctrl
local m_target_onlyid = 0
local m_natural_idx = -1
local natural_map = {}
local m_item_id = 0
local g_blood_refine_max = bo2.gv_define:find(1288).value.v_int
local g_refine_min_cnt = bo2.gv_define:find(1286).value.v_int
local g_blood_refine_level = bo2.gv_define:find(1287).value.v_int
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
    refine = bo2.eRidePetFlagInt32_RefineBloodVit,
    refine_cnt = bo2.eRidePetFlagInt32_RefineBloobVitCount,
    name = L("pet|ridepet_vit")
  }
  natural_map[1] = {
    flag = bo2.eRidePetFlagInt32_NaturalAgi,
    refine = bo2.eRidePetFlagInt32_RefineBloodAgi,
    refine_cnt = bo2.eRidePetFlagInt32_RefineBloobAgiCount,
    name = L("pet|ridepet_agi")
  }
  natural_map[2] = {
    flag = bo2.eRidePetFlagInt32_NaturalStr,
    refine = bo2.eRidePetFlagInt32_RefineBloodStr,
    refine_cnt = bo2.eRidePetFlagInt32_RefineBloobStrCount,
    name = L("pet|ridepet_str")
  }
  natural_map[3] = {
    flag = bo2.eRidePetFlagInt32_NaturalInt,
    refine = bo2.eRidePetFlagInt32_RefineBloodInt,
    refine_cnt = bo2.eRidePetFlagInt32_RefineBloobIntCount,
    name = L("pet|ridepet_int")
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
function set_ridepet_page(page)
  m_ridepet_page_current = page
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      ctr:search("ridepet").grid = page + i
    end
  end
end
function on_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  m_item_id = 0
  m_target_onlyid = 0
  clear_btn_natural()
  clear_target()
  clear_kill()
  clear_result()
  clear_ridepetlist_pic()
  clear_item()
end
function update_ridepet_kill(info)
  if info == nil then
    return
  end
  local control_cnt = w_ridelist.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_ridelist:control_get(i)
    if ctr ~= nil then
      if ctr:search("ridepet").grid == info.grid then
        ctr:search("kill_pic").visible = true
      else
        ctr:search("kill_pic").visible = false
      end
    end
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
    if onlyid == m_target_onlyid then
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
function on_btn_ok(ctrl)
  local value = natural_map[m_natural_idx]
  if value == nil then
    return
  end
  ui_widget.ui_msg_box.show_common({
    text = ui.get_text("pet|ridepet_blood_refine_recomend"),
    modal = true,
    btn_confirm = true,
    btn_cancel = true,
    callback = function(msg)
      if msg.result == 1 then
        ui_ridepet.send_blood_refine_ride(m_target_onlyid, m_item_id, value.flag)
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
function update_ridepetlist_pic()
  clear_ridepetlist_pic()
  local info_target = ui_ridepet.find_info_from_onlyid(m_target_onlyid)
  update_ridepet_target(info_target)
end
function may_blood_refine(info)
  local level = info:get_flag(bo2.eRidePetFlagInt32_Level)
  local refine_cnt = info:get_flag(bo2.eRidePetFlagInt32_Refine)
  if level < g_blood_refine_level then
    local var = sys.variant()
    var:set(L("level"), g_blood_refine_level)
    local data = sys.variant()
    data:set(packet.key.ui_text_id, 2700)
    data:set(packet.key.ui_text_arg, var)
    ui_chat.show_ui_text(0, data)
    return false
  end
  if refine_cnt < g_refine_min_cnt then
    local var = sys.variant()
    var:set(L("num"), g_refine_min_cnt)
    local data = sys.variant()
    data:set(packet.key.ui_text_id, 2701)
    data:set(packet.key.ui_text_arg, var)
    ui_chat.show_ui_text(0, data)
    return false
  end
  return true
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
  local info = ui_ridepet.find_info_from_onlyid(only_id)
  if info == nil then
    return
  end
  if not may_blood_refine(info) then
    return
  end
  update_target(info)
  update_btn_natural()
  update_result()
  ui.clean_drop()
  clear_ridepetlist_pic()
  update_ridepet_target(info)
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
  if info == nil or m_item_id == nil then
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
  local refine = info:get_flag(bo2.eRidePetFlagInt32_BloobRefineCount)
  if refine >= g_blood_refine_max then
    w_result_text.text = ui.get_text("pet|ridepet_refine_blood_count_max")
    return
  end
  local control_cnt = w_btn_natural.control_size
  for i = 0, control_cnt - 1 do
    local ctr = w_btn_natural:control_get(i)
    ctr.enable = true
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
end
function clear_kill()
  w_flag_str_kill.text = ""
  w_flag_int_kill.text = ""
  w_flag_vit_kill.text = ""
  w_flag_agi_kill.text = ""
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
end
function clear_result()
  w_btn_ok.enable = false
  w_money.money = 0
  w_money.bounded = false
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
  end
end
function get_othen_rate(level)
  if level == 1 then
    return 1.125
  elseif level == 2 then
    return 4.5
  elseif level == 3 then
    return 18
  elseif level == 4 then
    return 60
  elseif level == 5 then
    return 100
  else
    return 0
  end
end
function update_result()
  clear_result()
  if m_target_onlyid == 0 then
    clear_target()
    clear_btn_natural()
    clear_item()
    clear_kill()
    return
  end
  if m_item_id == 0 then
    clear_item()
    clear_kill()
    return
  end
  local natural = natural_map[m_natural_idx]
  if natural == nil then
    return
  end
  local info = ui_ridepet.find_info_from_onlyid(m_target_onlyid)
  local excel = bo2.gv_item_list:find(m_item_id)
  if info == nil or excel == nil then
    return
  end
  local star = info:get_flag(natural.flag)
  local excel_trait = bo2.gv_ridepet_blood_refine_trait:find(star)
  if excel_trait == nil then
    return
  end
  local blood_refine = info:get_flag(bo2.eRidePetFlagInt32_BloobRefineCount)
  if blood_refine >= g_blood_refine_max then
    return
  end
  local refine_excel = bo2.gv_ridepet_blood_refine:find(blood_refine + 1)
  if refine_excel == nil then
    return
  end
  w_money.bounded = false
  local have_money = bo2.player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
  if refine_excel.money_type == bo2.eFlagInt32_BoundedMoney then
    w_money.bounded = true
    have_money = bo2.player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
  end
  local varlevel = excel.varlevel
  w_money.money = refine_excel.v_moneys[varlevel - 1]
  w_result.grid = info:get_flag(bo2.eRidePetFlagInt32_Pos)
  local othen_rate = get_othen_rate(varlevel)
  percent = string.format("%.1f", (refine_excel.success_rate * othen_rate + 0.05) / 100)
  local text = ui_widget.merge_mtf({
    flag = ui.get_text(natural.name),
    percent = percent,
    value = excel_trait.value
  }, ui.get_text("pet|ridepet_refine_blood_percent"))
  w_result_text.text = text
  local chek_btn_enable = true
  local item_count = ui.item_get_count(m_item_id, true)
  if item_count < 1 then
    chek_btn_enable = false
  end
  if have_money < refine_excel.v_moneys[varlevel - 1] then
    chek_btn_enable = false
  end
  if chek_btn_enable then
    w_btn_ok.enable = true
  end
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
function on_use_item_card_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_rbutton_up then
    clear_item()
    clear_kill()
    update_result()
  end
end
function update_kill_use_item_info(item_id)
  clear_kill()
  local excel = bo2.gv_item_list:find(item_id)
  if excel == nil then
    return
  end
  local varlevel = excel.varlevel
  if varlevel == nil then
    return
  end
  local item_count = ui.item_get_count(item_id, true)
  if item_count < 1 then
    return
  end
  w_natural_vit_kill.visible = true
  w_natural_vit_kill:search("current").dx = varlevel * 17
  w_natural_vit_kill:search("max").dx = 85
  w_natural_agi_kill.visible = true
  w_natural_agi_kill:search("current").dx = varlevel * 17
  w_natural_agi_kill:search("max").dx = 85
  w_natural_str_kill.visible = true
  w_natural_str_kill:search("current").dx = varlevel * 17
  w_natural_str_kill:search("max").dx = 85
  w_natural_int_kill.visible = true
  w_natural_int_kill:search("current").dx = varlevel * 17
  w_natural_int_kill:search("max").dx = 85
end
function clear_item()
  local card = w_ridepet_kill_panel:search("card")
  m_item_id = 0
  if card ~= nil then
    ui_npcfunc.clear_card(card)
  end
end
function is_kill_item(item_id)
  local excel = bo2.gv_item_list:find(item_id)
  if excel ~= nil and excel.varlevel and excel.variety == 2175 then
    return true
  end
  return false
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
    ui_chat.show_ui_text_id(2699)
    return
  end
  update_kill_use_item_info(item_id)
  update_btn_natural()
  update_result()
end
function succes_update()
  local item_count = ui.item_get_count(m_item_id, true)
  if item_count < 1 then
    clear_item()
    m_item_id = 0
  end
  update_kill_use_item_info(m_item_id)
  update_btn_natural()
  update_result()
end
function blood_refine_update(var)
  local info = ui_ridepet.find_info_from_onlyid(m_target_onlyid)
  update_target(info)
  update_btn_natural()
  update_kill_use_item_info(m_item_id)
  update_result()
  succes_update()
end
init_once()
