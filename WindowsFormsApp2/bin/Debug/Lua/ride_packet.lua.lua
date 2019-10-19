function handle_ridepet_add(cmd, var)
end
function handle_ridepet_refine_save(cmd, var)
  ui_ridepet.ui_refine.refine_save(var)
end
function handle_ridepet_blood_refine(cmd, var)
  ui_ridepet.ui_blood_refine.blood_refine_update(var)
end
function handle_ridepet_open_zhenfa(cmd, var)
  ui_ridepet.ui_zhenfa.w_main.visible = not ui_ridepet.ui_zhenfa.w_main.visible
end
function handle_ridepet_open_zhenjiao(cmd, var)
  ui_ridepet.ui_zhenfa.clear_kill_ridepet()
  ui_ridepet.ui_zhenfa.update_zhenfa()
end
function handle_ridepet_del(cmd, var)
  select_ridepet(-1)
  local sel_horse = ui_npcfunc.ui_sellhorse.w_list_view.item_sel
  if sel_horse then
    ui_npcfunc.ui_sellhorse.w_list_view:item_remove(sel_horse.index)
    ui_npcfunc.ui_sellhorse.w_main.visible = false
  end
end
function handle_ridepet_identify(cmd, var)
  select_ridepet(-1)
end
function handle_ridepet_transfer(cmd, var)
  select_ridepet(-1)
end
function handle_ridepet_chg(cmd, var)
  local info = find_info_from_pos(ui.ride_get_select())
  if info == nil then
    return
  end
  local cur_info = find_info_from_onlyid(var:get(packet.key.ridepet_onlyid).v_string)
  if info == cur_info then
    update_ui_flag(info)
  end
end
function handle_ridepet_exp_chg(cmd, var)
  local info = find_info_from_pos(ui.ride_get_select())
  if info == nil then
    return
  end
  local cur_info = find_info_from_onlyid(var:get(packet.key.ridepet_onlyid).v_string)
  if info == cur_info then
    update_ui_exp(info)
  end
end
function handle_ridepet_pos_chg(cmd, var)
  local cur_info = find_info_from_onlyid(var:get(packet.key.ridepet_onlyid).v_string)
  update_ridepet(cur_info)
  local cur_pos = ui.ride_get_select()
  if cur_info.grid == cur_pos then
    update_select_ui(cur_info)
  end
end
function handle_ridepet_skill(cmd, var)
  local info = find_info_from_pos(ui.ride_get_select())
  if info == nil then
    return
  end
  local cur_info = find_info_from_onlyid(var:get(packet.key.ridepet_onlyid).v_string)
  if info == cur_info then
    local type = var:get(packet.key.ridepet_type).v_int
    if type == 0 then
      add_ui_skill(info)
    elseif type == 1 then
      del_ui_skill(info)
    elseif type == 2 then
      chg_ui_skill(info)
    end
  end
end
function handle_ridepet_skill_slot(cmd, var)
  local info = find_info_from_pos(ui.ride_get_select())
  if info == nil then
    return
  end
  local cur_info = find_info_from_onlyid(var:get(packet.key.ridepet_onlyid).v_string)
  if info == cur_info then
    chg_ui_skill(info)
  end
end
function handle_ridepet_equip(cmd, var)
  local function on_time()
    local info = find_info_from_pos(ui.ride_get_select())
    if info == nil then
      return
    end
    local cur_info = find_info_from_onlyid(var:get(packet.key.ridepet_onlyid).v_string)
    if info == cur_info then
      update_ui_equip(info)
    end
  end
  bo2.AddTimeEvent(1, on_time)
end
function handle_ridepet_select(cmd, var)
  local nPos = var:get(packet.key.ridepet_pos).v_int
  local nShowUI = var:get(packet.key.ridepet_show_ui).v_int
  if nPos == -1 then
    nPos = 0
  end
  select_ridepet(nPos)
  if nShowUI ~= 0 then
    show_ridepet_window()
  end
end
function InitRide(obj, msg)
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetAdd, handle_ridepet_add, "ui_ridepet.handle_ridepet_add")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetDel, handle_ridepet_del, "ui_ridepet.handle_ridepet_del")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetIdentify, handle_ridepet_identify, "ui_ridepet.handle_ridepet_identify")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetTransfer, handle_ridepet_transfer, "ui_ridepet.handle_ridepet_transfer")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetUIAtbChg, handle_ridepet_chg, "ui_ridepet.handle_ridepet_atb_chg")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetUIFlagChg, handle_ridepet_chg, "ui_ridepet.handle_ridepet_flag_chg")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetExp, handle_ridepet_exp_chg, "ui_ridepet.handle_ridepet_exp_chg")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetPosChg, handle_ridepet_pos_chg, "ui_ridepet.handle_ridepet_pos_chg")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetSkill, handle_ridepet_skill, "ui_ridepet.handle_ridepet_skill")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetEquip, handle_ridepet_equip, "ui_ridepet.handle_ridepet_equip")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetSelect, handle_ridepet_select, "ui_ridepet.handle_ridepet_select")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetSkillSlot, handle_ridepet_skill_slot, "ui_ridepet.handle_ridepet_skill_slot")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetRefineSave, handle_ridepet_refine_save, "ui_ridepet.handle_ridepet_refine_save")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetOpenZhenFa, handle_ridepet_open_zhenfa, "ui_ridepet.handle_ridepet_open_zhenfa")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetOpenZhenJiao, handle_ridepet_open_zhenjiao, "ui_ridepet.handle_ridepet_open_zhenjiao")
  ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_RidePetBloodRefine, handle_ridepet_blood_refine, "ui_ridepet.handle_ridepet_blood_refine")
end
function ClearRide(obj, msg)
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, InitRide, "on_enter_scn:InitRide")
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_leave, ClearRide, "on_leave_scn:ClearRide")
function send_call_ride(onlyid)
  if not bo2.player:enable_ride() then
    return
  end
  local var = sys.variant()
  var:set(packet.key.ridepet_onlyid, onlyid)
  bo2.send_variant(packet.eCTS_UI_RidePetCall, var)
end
function send_del_ride(onlyid)
  local var = sys.variant()
  var:set(packet.key.ridepet_onlyid, onlyid)
  bo2.send_variant(packet.eCTS_UI_RidePetDel, var)
end
function send_jipo_ride(onlyid)
  local id = 1
  local var = sys.variant()
  var:set(packet.key.ridepet_onlyid, onlyid)
  bo2.send_variant(packet.eCTS_UI_RidePetjipo, var)
end
function send_save_refine(var)
  bo2.send_variant(packet.eCTS_UI_RidePetRefineSave, var)
end
function send_skill_up_ride(onlyid, skill_id)
  local var = sys.variant()
  var:set(packet.key.ridepet_onlyid, onlyid)
  var:set(packet.key.ridepet_skill_id, skill_id)
  bo2.send_variant(packet.eCTS_UI_RidePetSkillUp, var)
end
function send_skill_unlock_ride(onlyid, skill_group)
  local var = sys.variant()
  var:set(packet.key.ridepet_onlyid, onlyid)
  var:set(packet.key.ridepet_skill_group, skill_group)
  bo2.send_variant(packet.eCTS_UI_RidePetSkillUnlock, var)
end
function send_refine_ride(onlyid, use_onlyid, natural_type)
  local var = sys.variant()
  var:set(packet.key.ridepet_onlyid, onlyid)
  var:set(packet.key.ridepet_use_onlyid, use_onlyid)
  var:set(packet.key.ridepet_refine_use_item_id, 0)
  var:set(packet.key.ridepet_natural_type, natural_type)
  var:set(packet.key.cmn_type, bo2.eRidepet_Refine)
  bo2.send_variant(packet.eCTS_UI_RidePetRefine, var)
end
function send_blood_refine_ride(onlyid, use_item_id, natural_type)
  local var = sys.variant()
  var:set(packet.key.ridepet_onlyid, onlyid)
  var:set(packet.key.ridepet_refine_use_item_id, use_item_id)
  var:set(packet.key.ridepet_natural_type, natural_type)
  var:set(packet.key.cmn_type, bo2.eRidepet_BloodRefine)
  bo2.send_variant(packet.eCTS_UI_RidePetRefine, var)
end
function send_refine_ride_use_item(onlyid, use_item_id, natural_type)
  local var = sys.variant()
  var:set(packet.key.ridepet_onlyid, onlyid)
  var:set(packet.key.ridepet_use_onlyid, 0)
  var:set(packet.key.ridepet_refine_use_item_id, use_item_id)
  var:set(packet.key.ridepet_natural_type, natural_type)
  var:set(packet.key.cmn_type, bo2.eRidepet_Refine)
  bo2.send_variant(packet.eCTS_UI_RidePetRefine, var)
end
function send_open_zhenfa_use_item(onlyid)
  local var = sys.variant()
  var:set(packet.key.ridepet_onlyid, onlyid)
  bo2.send_variant(packet.eCTS_UI_RidePetOpenZhenFa, var)
end
function send_open_zhenjiao(zhenyan_onlyid, zhenjiao_onlyid)
  local var = sys.variant()
  var:set(packet.key.ridepet_onlyid, zhenyan_onlyid)
  var:set(packet.key.ridepet_kill_ride_id, zhenjiao_onlyid)
  bo2.send_variant(packet.eCTS_UI_RidePetOpenZhenJiao, var)
end
function send_skill_delete_ride(onlyid, skill_id)
  local var = sys.variant()
  var:set(packet.key.ridepet_onlyid, onlyid)
  var:set(packet.key.ridepet_skill_id, skill_id)
  bo2.send_variant(packet.eCTS_UI_RidePetSkillDelete, var)
end
function send_ride_equip(info, grid)
  local ride_info = find_info_from_pos(ui.ride_get_select())
  if ride_info == nil then
    return
  end
  local state = get_ridepet_jipo_state(ride_info)
  if state then
    ui_chat.show_ui_text_id(2628)
    return
  end
  local function sendmsg()
    local v = sys.variant()
    v:set64(packet.key.item_key, info.only_id)
    v:set64(packet.key.ridepet_onlyid, ride_info.onlyid)
    if grid ~= nil then
      v:set(packet.key.item_grid, grid)
    end
    bo2.send_variant(packet.eCTS_UI_EquipRideItem, v)
    bo2.PlaySound2D(586)
  end
  if info:get_data_8(bo2.eItemByte_Bound) == 0 and ui.ride_get_select() ~= nil and (info.excel.bound_mode == bo2.eItemBoundMod_Equip or info.excel.bound_mode == bo2.eItemBoundMod_Acquire) then
    local arg = sys.variant()
    local item_name = sys.format("<i:%d>", info.excel_id)
    arg:set("item_name", item_name)
    ui_widget.ui_msg_box.show_common({
      text = sys.mtf_merge(arg, ui.get_text("item|bound_equip")),
      modal = true,
      btn_confirm = true,
      btn_cancel = true,
      callback = function(msg)
        if msg.result == 1 then
          sendmsg()
        end
      end
    })
  else
    sendmsg()
  end
end
function send_ride_unequip(only_id, box, grid)
  local v = sys.variant()
  v:set64(packet.key.item_key, only_id)
  if grid ~= nil then
    v:set(packet.key.item_box, box)
    v:set(packet.key.item_grid, grid)
  end
  bo2.send_variant(packet.eCTS_UI_UnEquipRideItem, v)
  bo2.PlaySound2D(586)
end
function show_ridepet_window()
  w_ridepet.visible = true
end
