local g_npcfunc_id = 0
local g_profession_id = 0
local g_career_id = 0
local g_select_profession_id = 0
function Clear_BoxList(box)
  if box ~= nil then
    ui_widget.ui_combo_box.clear(box)
  end
end
function Check_True()
  if g_npcfunc_id ~= bo2.eNpcFunc_ChangeProfession then
    return false
  end
  local def_level = bo2.gv_define:find(1255).value.v_int
  local player = bo2.player
  local my_level = player:get_atb(bo2.eAtb_Level)
  if def_level > my_level then
    local var = sys.variant()
    var:set(L("level"), def_level)
    local data = sys.variant()
    data:set(packet.key.ui_text_id, 2639)
    data:set(packet.key.ui_text_arg, var)
    ui_chat.show_ui_text(0, data)
    return false
  end
  if bo2.IsCoolDownOver(55038) ~= true then
    ui_chat.show_ui_text_id(2640)
    return false
  end
  local item_id = bo2.gv_define:find(1256).value.v_int
  local item_id_str = tostring(item_id)
  local count = 0
  local useItemnum = 1
  if item_id > 0 then
    count = ui.item_get_count(item_id_str, true)
  else
    useItemnum = 0
  end
  if useItemnum == 1 and count == 0 then
    local var = sys.variant()
    var:set(L("item_id"), item_id)
    local data = sys.variant()
    data:set(packet.key.ui_text_id, 2638)
    data:set(packet.key.ui_text_arg, var)
    ui_chat.show_ui_text(0, data)
    return false
  end
  local slot_pross = w_profession_panel:search("slot_sel")
  local box_pross = slot_pross:search("box")
  g_select_profession_id = ui_widget.ui_combo_box.selected(box_pross).id
  if g_select_profession_id <= 0 or g_select_profession_id == g_profession_id then
    ui_chat.show_ui_text_id(2641)
    return false
  end
  if g_select_profession_id <= 0 or g_select_profession_id > 24 or g_select_profession_id % 3 == 1 then
    return false
  end
  local player = bo2.player
  local fs = player:get_flag_objmem(bo2.eFlagObjMemory_FightState)
  if fs ~= 0 then
    ui_chat.show_ui_text_id(2652)
    return false
  end
  return true
end
function UpdataTraits(g_profession_id)
  local slot_career = w_career_panel:search("slot_sel")
  local box_career = slot_career:search("box")
  local career_id = ui_widget.ui_combo_box.selected(box_career).id
  local slot_pross = w_profession_panel:search("slot_sel")
  local box_pross = slot_pross:search("box")
  Clear_BoxList(box_pross)
  local pro_id = career_id + 1
  local pro = bo2.gv_profession_list:find(pro_id)
  if pro == nil then
    return
  end
  ui_widget.ui_combo_box.append(box_pross, {
    id = pro_id,
    text = pro.name
  })
  pro_id = career_id + 2
  pro = bo2.gv_profession_list:find(pro_id)
  if pro == nil then
    return
  end
  ui_widget.ui_combo_box.append(box_pross, {
    id = pro_id,
    text = pro.name
  })
  if g_profession_id > 0 then
    ui_widget.ui_combo_box.select(box_pross, g_profession_id)
  else
    ui_widget.ui_combo_box.select(box_pross, career_id + 1)
  end
end
function OnSelItem()
  UpdataTraits(-1)
end
function handCheckCampaignOn(cmd, data)
  local campaign_eventid = data:get(packet.key.campaign_eventid).v_int
  local talk_excel_id = data:get(packet.key.talk_excel_id).v_int
  if campaign_eventid ~= 17359 or talk_excel_id ~= bo2.eNpcFunc_ChangeProfession then
    return
  end
  local campaign_eventstate = data:get(packet.key.campaign_eventstate).v_int
  if campaign_eventstate == 1 then
    local my_w = ui_npcfunc.ui_change_profession.w_main
    my_on_visible(my_w, true)
  else
    ui_chat.show_ui_text_id(2651)
  end
end
function on_npcfunc_open_window(npcfunc_id)
  ui.log("npcfunc_id:" .. npcfunc_id)
  g_npcfunc_id = npcfunc_id
  if g_npcfunc_id ~= bo2.eNpcFunc_ChangeProfession then
    return
  end
  ui_npcfunc.ui_change_profession.w_main.visible = false
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_ChangeProfession)
  v:set(packet.key.campaign_eventid, 17359)
  bo2.send_variant(packet.eCTS_UI_Check_Campaign_ON, v)
end
function on_btn_mk_click()
  if not Check_True() then
    return
  end
  local function on_msg_callback(m_data)
    if m_data.result ~= 1 then
      return
    end
    local v = sys.variant()
    v:set(packet.key.player_profession, g_select_profession_id)
    bo2.send_variant(packet.eCTS_UI_Change_Profession, v)
  end
  local name = bo2.gv_profession_list:find(g_profession_id).name
  local name1 = bo2.gv_profession_list:find(g_select_profession_id).name
  local msg = {
    callback = on_msg_callback,
    text = ui_widget.merge_mtf({profession_name = name, profession_name1 = name1}, ui.get_text("npcfunc|config_info_chgprf_profession"))
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_visible(w, vis)
end
function my_on_visible(w, vis)
  local player = bo2.player
  g_profession_id = player:get_atb(bo2.eAtb_Cha_Profession)
  local index = -1
  for i = 0, 7 do
    if 3 * i + 1 <= g_profession_id and g_profession_id < 3 * (i + 1) + 1 then
      index = i
      break
    end
  end
  if index < 0 or index > 7 then
    return
  end
  g_career_id = 3 * index + 1
  local slot_sel = w_career_panel:search("slot_sel")
  local box = slot_sel:search("box")
  Clear_BoxList(box)
  local slot_pross = w_profession_panel:search("slot_sel")
  local box_pross = slot_pross:search("box")
  Clear_BoxList(box_pross)
  box.svar.on_select = OnSelItem
  for i = 0, 7 do
    local p_id = 3 * i + 1
    local pro = bo2.gv_profession_list:find(p_id)
    if pro == nil then
      return
    end
    ui_widget.ui_combo_box.append(box, {
      id = p_id,
      text = pro.name
    })
  end
  ui_widget.ui_combo_box.select(box, g_career_id)
  UpdataTraits(g_profession_id)
  w.visible = true
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
end
function on_init(ctrl)
end
local sig = "ui_npcfunc.ui_change_profession:on_signal"
ui_packet.game_recv_signal_insert(packet.eSTC_UI_Campaign_Check_Campaign_On, handCheckCampaignOn, sig)
