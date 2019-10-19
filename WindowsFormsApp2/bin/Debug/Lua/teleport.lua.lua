g_portrait_path = "$icon/portrait/"
eConveneStatus_None = 0
eConveneStatus_Open = 1
eConveneStatus_TelePending = 2
eConveneStatus_TeleSucced = 3
eConveneStatus_TeleFailed = 4
eTeleStatus_None = 0
eTeleStatus_Accept = 1
eTeleStatus_Pending = 2
eTeleStatus_Reject = 3
local max_member = {
  [1] = 2,
  [2] = 5,
  [3] = 5,
  [4] = 10
}
if rawget(_M, "member_data") == nil then
  member_data = {
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {},
    {}
  }
end
function on_teleport_propose()
  if bo2.get_captain_id() == bo2.player.only_id then
    w_teleport_view_main.visible = not w_teleport_view_main.visible
    ui_handson_teach.test_complete_convene_teleport()
  else
    w_teleport_view_main.visible = false
    if w_teleport_invite_timeout:is_running() == true then
      w_teleport_invite_main.visible = not w_teleport_invite_main.visible
    else
      w_teleport_invite_main.visible = false
      w_teleport_proposal.visible = false
    end
  end
  w_flicker_teleport.visible = false
  w_flicker_teleport.suspended = true
end
function on_teleport_btn_tip_make(tip)
  local text = ui.get_text("convene|tele_btn_tip")
  ui_widget.tip_make_view(tip.view, text)
end
function on_teleport_member_show(tip)
  local name = tip.owner:search("player_name")
  if tip.owner:search("portrait").visible == false then
    return
  end
  local text = name.text
  local stk = sys.stack()
  stk:push(text)
  ui_tool.ctip_show(tip.owner, stk)
end
function member_data_init(idx, w)
  local d = member_data[idx]
  d.lb_name = w:search("player_name")
  d.pn_caption = w:search("captain_flag")
  d.pic_portrait = w:search("portrait")
  d.pic_accept = w:search("accept")
  d.pic_reject = w:search("reject")
  d.lb_pending = w:search("pending")
end
function on_teleport_view_init(ctrl)
  member_data_init(1, w_team_member_1)
  member_data_init(2, w_team_member_2)
  member_data_init(3, w_team_member_3)
  member_data_init(4, w_team_member_4)
  member_data_init(5, w_team_member_5)
  member_data_init(6, w_team_member_6)
  member_data_init(7, w_team_member_7)
  member_data_init(8, w_team_member_8)
  member_data_init(9, w_team_member_9)
  member_data_init(10, w_team_member_10)
end
function on_teleport_launch_click(btn)
  local group_id = bo2.get_group_id()
  local type = w_invite_view_main.svar.type
  if type == bo2.eConveneType_Misc then
    return
  end
  local scn_id = w_invite_view_main.svar.scn_id
  ui_dungeonui.ui_dungeonsel.init_all_need()
  ui_dungeonui.ui_dungeonsel.insert_page_items(type)
  local scn_tb = ui_dungeonui.ui_dungeonsel.get_table_by_scnid(type, scn_id)
  local data_table = scn_tb.data_table
  local state = ui_dungeonui.ui_dungeonsel.check_other_state(data_table)
  local state_level = ui_dungeonui.ui_dungeonsel.check_other_state_levels(data_table)
  if state == false or state_level == false then
    ui_tool.note_insert(ui.get_text("convene|tele_unreach_condition"), L("FFFF0000"))
    local data = sys.variant()
    data:set(packet.key.group_id, group_id)
    data:set(packet.key.convene_tele_disable, 1)
    ui_convene.send_teleport_reject(data)
    return
  elseif ui_convene.check_cd(type, scn_tb) == false then
    ui_tool.note_insert(ui.get_text("convene|tele_cd_out"), L("FFFF0000"))
    local data = sys.variant()
    data:set(packet.key.group_id, group_id)
    data:set(packet.key.convene_tele_cd_out, 1)
    ui_convene.send_teleport_reject(data)
    return
  end
  local player = bo2.player
  local isFighting = player:get_flag_objmem(bo2.eFlagObjMemory_FightState)
  if isFighting == 1 then
    ui_tool.note_insert(ui.get_text("convene|tele_rej_fighting"), "FF0000")
    return
  end
  local alloc_line = bo2.gv_scn_alloc:find(bo2.scn.scn_excel.id)
  if alloc_line.type ~= bo2.eScnType_OneWorld then
    ui_tool.note_insert(ui.get_text("convene|tele_rej_bigworld"), "FF0000")
    return
  end
  if player:IsDead() then
    ui_tool.note_insert(ui.get_text("convene|tele_rej_dead"), "FF0000")
    return
  end
  local isInPrison = player:get_flag_objmem(bo2.eFlagObjMemory_Prison)
  if isInPrison == 1 then
    ui_tool.note_insert(ui.get_text("convene|tele_rej_inprison"), "FF0000")
    return
  end
  send_teleport_launch(group_id)
end
function member_update(idx, members)
  local d = member_data[idx]
  if idx > members.size then
    d.lb_name.text = ""
    d.pn_caption.visible = false
    d.pic_portrait.visible = false
    d.pic_accept.visible = false
    d.pic_reject.visible = false
    d.lb_pending.visible = false
    return
  end
  local member = members:fetch_v(idx - 1)
  local cha_id = member:get(packet.key.cha_onlyid).v_string
  local is_accept = member:get(packet.key.convene_tele_acceped).v_int
  local info = ui.member_find(cha_id)
  d.lb_name.text = info.name
  local only_id = info.only_id
  if only_id == bo2.get_captain_id() then
    d.pn_caption.visible = true
  else
    d.pn_caption.visible = false
  end
  local por_list = bo2.gv_portrait:find(info:get_flag_int32(bo2.ePlayerFlagInt32_Portrait))
  if por_list ~= nil then
    d.pic_portrait.image = sys.format("%s%s.png", g_portrait_path, por_list.icon)
    d.pic_portrait.visible = true
  end
  d.pic_accept.visible = false
  d.pic_reject.visible = false
  d.lb_pending.visible = false
  if is_accept == eTeleStatus_Accept then
    d.pic_accept.visible = true
  elseif is_accept == eTeleStatus_Pending then
    d.lb_pending.visible = true
  elseif is_accept == eTeleStatus_Reject then
    d.pic_reject.visible = true
  end
end
function update_members(data)
  local type = data:get(packet.key.convene_type).v_int
  if type == bo2.eConveneType_Misc then
    return
  end
  local scn_id = data:get(packet.key.convene_scn_id).v_int
  show_teleport_button(type, scn_id)
  local status = data:get(packet.key.convene_status).v_int
  if status == eConveneStatus_Open then
    w_teleport_status_text.text = ui.get_text(sys.format("convene|tele_not_launch"))
    w_teleport_status_text.color = ui.make_color("00ff00")
    w_teleport_launch_btn.visible = true
    w_teleport_waiting_text.visible = false
  elseif status == eConveneStatus_TelePending then
    w_teleport_status_text.text = ui.get_text(sys.format("convene|tele_already_launch"))
    w_teleport_status_text.color = ui.make_color("00ff00")
    w_teleport_launch_btn.visible = false
    w_teleport_waiting_text.visible = true
  elseif status == eConveneStatus_TeleFailed then
    w_teleport_status_text.text = ui.get_text(sys.format("convene|tele_launch_fail"))
    w_teleport_status_text.color = ui.make_color("ff0000")
    w_teleport_launch_btn.visible = true
    w_teleport_waiting_text.visible = false
  end
  local members = data:get(packet.key.group_all_members)
  for i = 1, table.getn(member_data) do
    member_update(i, members)
  end
  if members.size > 5 then
    w_teleport_view_main.dy = 390
  else
    w_teleport_view_main.dy = 270
  end
  if 1 >= members.size then
    w_teleport_launch_btn.enable = false
    w_teleport_status_text.text = ui.get_text(sys.format("convene|tele_need_2member"))
    w_teleport_status_text.color = ui.make_color("ff0000")
  elseif members.size > max_member[type] then
    w_teleport_launch_btn.enable = false
    w_teleport_status_text.text = ui.get_text(sys.format("convene|tele_out_max_member"))
    w_teleport_status_text.color = ui.make_color("ff0000")
  else
    w_teleport_launch_btn.enable = true
  end
  if members.size == max_member[type] then
    w_flicker_teleport.visible = true
    w_flicker_teleport.suspended = false
  end
end
function check_cd(type, scn_tb)
  if type == bo2.eConveneType_Misc then
    return
  end
  if type == 3 or type == 1 then
    local cdtb = ui_dungeonui.ui_dungeonsel.get_share_cd_tb(type)
    local cd_line = bo2.gv_cooldown_list:find(cdtb.id)
    if cd_line ~= nil then
      local max_count = cd_line.token
      if max_count <= cdtb.cur_count then
        return false
      end
    end
  end
  if scn_tb.cd_max == nil then
    return true
  end
  if scn_tb.cd_count < scn_tb.cd_max then
    return true
  end
  return false
end
function on_teleport_ask(click, data)
  w_teleport_invite_main.visible = true
end
function on_teleport_accept_click(btn)
  local player = bo2.player
  local isFighting = player:get_flag_objmem(bo2.eFlagObjMemory_FightState)
  if isFighting == 1 then
    ui_tool.note_insert(ui.get_text("convene|tele_rej_fighting"), "FF0000")
    return
  end
  local alloc_line = bo2.gv_scn_alloc:find(bo2.scn.scn_excel.id)
  if alloc_line.type ~= bo2.eScnType_OneWorld then
    ui_tool.note_insert(ui.get_text("convene|tele_rej_bigworld"), "FF0000")
    return
  end
  if player:IsDead() then
    ui_tool.note_insert(ui.get_text("convene|tele_rej_dead"), "FF0000")
    return
  end
  local isInPrison = player:get_flag_objmem(bo2.eFlagObjMemory_Prison)
  if isInPrison == 1 then
    ui_tool.note_insert(ui.get_text("convene|tele_rej_inprison"), "FF0000")
    return
  end
  local group_id = bo2.get_group_id()
  send_teleport_accept(group_id)
  w_teleport_invite_main.visible = false
  w_teleport_proposal.visible = false
  ui_convene.w_teleport_invite_timeout.left_time = 0
end
function on_teleport_reject_click(btn)
  local group_id = bo2.get_group_id()
  local data = sys.variant()
  data:set(packet.key.group_id, group_id)
  send_teleport_reject(data)
  w_teleport_invite_main.visible = false
  w_teleport_proposal.visible = false
  ui_convene.w_teleport_invite_timeout.left_time = 0
end
function on_teleport_proposal_visible(w, vis)
  if vis == true and bo2.get_captain_id() == bo2.player.only_id then
    local obj = bo2.player
    if sys.check(obj) == true then
      local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_ConveneTeleport)
      if flag_value == 0 then
        ui_handson_teach.on_teach_quest(bo2.ePlayerFlagInt16_HandsOn_ConveneTeleport, ui_handson_teach.cQuestTeachType_Add)
      end
    end
  end
end
