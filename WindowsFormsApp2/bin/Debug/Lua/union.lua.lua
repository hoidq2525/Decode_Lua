local REG = ui_packet.game_recv_signal_insert
local sig = "union.packet"
local MAX_UNION_COUNT = 10
local function HandleActiveUnion(cmd, data)
  local btn = ui_widget.ui_tab.get_button(w_main, "union_tab")
  local id = data:get(packet.key.group_union_id).v_string
  if id == sys.wstring(0) then
    ui_widget.ui_tab.show_page(w_main, "team_tab", true)
    w_leave_union_btn.enable = false
    for i = 0, MAX_UNION_COUNT - 1 do
      local ctrl = w_union_list:item_get(i)
      ctrl:search("team_number").color = ui.make_color("444444")
      ctrl:search("captain").text = ""
      ctrl:search("member_count").text = ""
      ctrl:search("bg_fader").alpha = 0.8
    end
    btn.text = ui.get_text("team|union_tab")
  elseif ui.get_team_captain_id() == bo2.player.only_id then
    w_leave_union_btn.enable = true
  else
    w_leave_union_btn.enable = false
  end
  SendRequestUnionInfo()
end
REG(packet.eSTC_Group_UpdataUnion, HandleActiveUnion, sig)
local function HandleGetUnionInfo(cmd, data)
  w_union_refresh.enable = true
  if data.size == 0 then
    w_leave_union_btn.enable = false
  elseif ui.get_team_captain_id() == bo2.player.only_id then
    w_leave_union_btn.enable = true
    if check_has_union() == false then
      ui_widget.ui_tab.show_page(w_main, "union_tab", true)
      w_main.visible = true
    end
  else
    w_leave_union_btn.enable = false
  end
  for i = 0, data.size - 1 do
    local unionData = data:fetch_v(i)
    local ctrl = w_union_list:item_get(i)
    ctrl:search("team_number").color = ui.make_color("FFFFFF")
    ctrl:search("captain").text = sys.format("%s", unionData:get(packet.key.cmn_name).v_string)
    ctrl:search("member_count").text = sys.format("%s/20", unionData:get(packet.key.group_cur_member_count).v_int)
    ctrl:search("bg_fader").alpha = 1
  end
  for i = data.size, MAX_UNION_COUNT - 1 do
    local ctrl = w_union_list:item_get(i)
    ctrl:search("team_number").color = ui.make_color("444444")
    ctrl:search("captain").text = ""
    ctrl:search("member_count").text = ""
    ctrl:search("bg_fader").alpha = 0.8
  end
  local btn = ui_widget.ui_tab.get_button(w_main, "union_tab")
  if data.size ~= 0 then
    btn.text = sys.format("%s (%d/%d)", ui.get_text("team|union_tab"), data.size, MAX_UNION_COUNT)
  else
    btn.text = ui.get_text("team|union_tab")
  end
end
REG(packet.eSTC_Group_UnionInfo, HandleGetUnionInfo, sig)
function SendRequestUnionInfo()
  bo2.send_variant(packet.eCTS_Group_UnionInfo)
  w_union_refresh.enable = false
end
function InitUnion()
  local btn = ui_widget.ui_tab.get_button(w_main, "union_tab")
  btn:insert_on_click(SendRequestUnionInfo)
  w_leave_union_btn.enable = false
  w_invite_union_btn.enable = false
  w_union_list:item_clear()
  MAX_UNION_COUNT = bo2.gv_define:find(633).value.v_int
  for i = 0, MAX_UNION_COUNT - 1 do
    local ctrl = w_union_list:item_append()
    ctrl:load_style("$frame/team/team.xml", "union_member")
    ctrl:search("team_number").text = sys.format("%d%s", i + 1, ui.get_text("team|team_name"))
    ctrl:search("team_number").color = ui.make_color("444444")
    ctrl:search("captain").text = ""
    ctrl:search("member_count").text = ""
    ctrl:search("bg_fader").alpha = 0.8
  end
end
function SendLeaveUnion()
  ui_widget.ui_msg_box.show_common({
    callback = function(msg)
      if msg.result == 1 then
        bo2.send_variant(packet.eCTS_Group_UnionLeave)
      end
    end,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    text = ui.get_text("team|union_leaveunion")
  })
end
function SendInviteUnion()
  ui_widget.ui_msg_box.show_common({
    callback = function(msg)
      if msg.result == 1 and msg.input ~= L("") then
        local data = sys.variant()
        data:set(packet.key.cha_name, msg.input)
        bo2.send_variant(packet.eCTS_Group_UnionRequest, data)
      end
    end,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    limit = 27,
    text = ui.get_text("team|union_invite_txt"),
    title = ui.get_text("team|union_invite_title"),
    input = ui.get_text("team|union_invite_name")
  })
end
