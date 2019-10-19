function on_init()
  id = nil
end
function ack_request_popo(click, data)
  bo2.send_groupack(data:get(packet.key.group_request_id).v_string, "yes" == click)
end
function may_invite(name)
  local target = bo2.findobj(name)
  if target ~= nil and (target.kind ~= bo2.eScnObjKind_Player or target == bo2.player) then
    return false
  end
  if ui.member_get_by_name(name) ~= nil then
    return false
  end
  if ui_portrait.is_nogroup_scn() == true then
    return false
  end
  if bo2.get_group_id() ~= L("0") and bo2.get_captain_id() ~= bo2.player.only_id then
    return false
  end
  return true
end
function send_invite_cha(cha_name)
  if may_invite(name) == false then
    ui_chat.show_ui_text_id(1000)
    return
  end
  local v = sys.variant()
  v:set(packet.key.cha_name, cha_name)
  bo2.send_variant(packet.eCTS_Group_AddRequest, v)
end
function send_change_captain(cha_name)
  local dialog = {
    modal = 1,
    btn_confirm = 1,
    btn_cancel = 1,
    callback = function(msg)
      if msg.result == 1 then
        local v = sys.variant()
        v:set(packet.key.group_id, _MODULE.id)
        v:set(packet.key.group_member_name, cha_name)
        bo2.send_variant(packet.eCTS_Group_SetCaptain, v)
      end
    end
  }
  local data = sys.variant()
  data:set("name", cha_name)
  dialog.text = sys.mtf_merge(data, ui.get_text("team|set_captain_msg"))
  ui_widget.ui_msg_box.show_common(dialog)
end
function send_delete_member(cha_name)
  if cha_name == bo2.player.name then
    local v = sys.variant()
    v:set(packet.key.group_id, _MODULE.id)
    v:set(packet.key.group_member_name, cha_name)
    bo2.send_variant(packet.eCTS_Group_DeleteMember, v)
    return
  end
  local dialog = {
    modal = 1,
    btn_confirm = 1,
    btn_cancel = 1,
    name = cha_name,
    callback = function(msg)
      if msg.result == 1 then
        local v = sys.variant()
        v:set(packet.key.group_id, _MODULE.id)
        v:set(packet.key.group_member_name, msg.name)
        bo2.send_variant(packet.eCTS_Group_DeleteMember, v)
      end
    end
  }
  local data = sys.variant()
  data:set("name", cha_name)
  dialog.text = sys.mtf_merge(data, ui.get_text("team|del_member_msg"))
  ui_widget.ui_msg_box.show_common(dialog)
end
function send_release()
  bo2.send_grouprelease(_MODULE.id)
end
function send_setteam()
  bo2.send_groupsetteam()
end
function send_setgroup()
  bo2.send_groupsetgroup()
end
function send_AdjustPosition(p1, p2)
  bo2.send_AdjustPosition(p1.v_int, p2.v_int)
end
function send_merge(cha_name)
  local v = sys.variant()
  v:set(packet.key.cha_name, cha_name)
  bo2.send_variant(packet.eCTS_Group_Merge, v)
end
function merge_ack_request_popo(click, data)
  bo2.send_mergeack(data:get(packet.key.group_request_id).v_string, "yes" == click)
end
function union_ack_request_popo(click, data)
  bo2.send_unionack(data:get(packet.key.group_union_request_id).v_string, "yes" == click)
end
