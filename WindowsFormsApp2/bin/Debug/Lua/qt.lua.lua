local online_count = 0
local room_name = L("")
function on_init()
  online_count = 0
  room_name = L("")
end
function on_bind_room(btn)
  bo2.qt_bind_room()
end
function on_change_bind(btn)
  bo2.qt_bind_room()
end
function on_start_client(btn)
  bo2.qt_start_client()
end
function on_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    local guild_room_id = ui.guild_qt_room()
    local guild_sub_room_id = ui.guild_qt_sub_room()
    if guild_room_id == 0 and guild_room_id == 0 then
      w_panel_first_bind.visible = true
      w_panel_bind.visible = false
    else
      w_panel_first_bind.visible = false
      w_panel_bind.visible = true
      bo2.qt_get_room_info(guild_room_id, guild_sub_room_id)
    end
  else
    ui_tool.hide_menu()
    ui_widget.esc_stk_pop(w)
  end
end
function on_get_guild_room_info(cmd, data)
  if data:has(packet.key.cmn_id) then
    online_count = data:get(packet.key.cmn_id).v_int
  end
  local member_count = ui.guild_member_size()
  local v = sys.variant()
  v:set("cur_num", online_count)
  v:set("total_num", member_count)
  local text = sys.mtf_merge(v, ui.get_text("qt|cur_num"))
  w_cur_num.mtf = text
  if data:has(packet.key.cmn_name) then
    room_name = data:get(packet.key.cmn_name).v_string
    w_cur_room.mtf = "<c+:2d9eba>" .. room_name .. "<c->"
  end
end
function on_guild_bind_room(cmd, data)
  local guild_room_id = ui.guild_qt_room()
  local guild_sub_room_id = ui.guild_qt_sub_room()
  w_panel_first_bind.visible = false
  w_panel_bind.visible = true
  bo2.qt_get_room_info(guild_room_id, guild_sub_room_id)
  member_count = ui.guild_member_size()
end
function on_start_qt_client_failed(cmd, data)
  local msg = {
    btn_confirm = true,
    btn_cancel = false,
    modal = true,
    text = ui.get_text("qt|start_client_failed")
  }
  ui_widget.ui_msg_box.show_common(msg)
end
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_qt:on_signal"
reg(packet.eSTC_Fake_Qt_Guild_Room_Info, on_get_guild_room_info, sig)
reg(packet.eSTC_Fake_Qt_Bind_Room, on_guild_bind_room, sig)
reg(packet.eSTC_Fake_Qt_Fail_Start_Client, on_start_qt_client_failed, sig)
