local G_WIN_SCORE = 4
local G_LOS_SCORE = 2
local G_TIE_SCORE = 1
function OnSelectItem(item, sel)
  item:search("select").visible = sel
end
function OnDelMember(btn)
  local item = gx_memberlist.item_sel
  if item == nil then
    return
  end
  local var = sys.variant()
  var:set(packet.key.cha_onlyid, item.svar.onlyid)
  bo2.send_variant(packet.eCTS_DooAltar_DelMember, var)
end
function OnChgCaptain(btn)
  local item = gx_memberlist.item_sel
  if item == nil then
    return
  end
  local var = sys.variant()
  var:set(packet.key.cha_onlyid, item.svar.onlyid)
  bo2.send_variant(packet.eCTS_DooAltar_ChgCaptain, var)
end
function on_menu_event(item)
  if item.callback then
    item:callback()
  end
end
function on_item_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_rbutton_click then
    if gx_memberlist.item_sel ~= nil then
      gx_memberlist.item_sel.selected = false
    end
    panel.selected = true
    local data = {
      items = {
        {
          text = ui.get_text("match|btn_delmember"),
          callback = OnDelMember
        },
        {
          text = ui.get_text("match|btn_chgcaptain"),
          callback = OnChgCaptain
        }
      },
      event = on_menu_event,
      parent = panel.parent,
      dx = 100,
      dy = 50
    }
    ui_tool.show_menu(data)
    data.window.offset = panel.abs_area.p1 + pos
  end
end
function on_msg(msg)
  if msg.result == 0 then
    return
  end
  local var = sys.variant()
  var:set(packet.key.dooaltar_single, 1)
  bo2.send_variant(packet.eCTS_DooAltar_DelMember, var)
end
function onQuitGroupClick(btn)
  local msg = {
    callback = on_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = sys.format(ui.get_text("match|quitgroup_msg_box"), gx_group_mng_window:search("my_title").text)
  ui_widget.ui_msg_box.show_common(msg)
end
function onAddMemberClick(btn)
  local dialog = {
    text = ui.get_text("match|groupmng_addmember"),
    modal = true,
    btn_confirm = 1,
    btn_cancel = 1,
    callback = function(data)
      if data.result == 1 then
        local var = sys.variant()
        var:set(packet.key.cha_name, data.input)
        bo2.send_variant(packet.eCTS_DooAltar_AddMember, var)
        gx_apply_window.visible = false
      end
    end
  }
  dialog.input = ui.get_text("match|input_chaname")
  dialog.limit = 25
  ui_widget.ui_msg_box.show_common(dialog)
end
function get_score(win, los, tie)
  return win * G_WIN_SCORE + los * G_LOS_SCORE + tie * G_TIE_SCORE
end
function get_rate(win, los, tie)
  local rate = 0
  if win > 0 then
    rate = math.ceil(win / (win + los + tie) * 100)
  end
  return rate .. "%"
end
function CreateTeamInfo(team_info)
  local win = team_info:get(packet.key.dooaltar_win).v_int
  local los = team_info:get(packet.key.dooaltar_lost).v_int
  local tie = team_info:get(packet.key.dooaltar_tie).v_int
  gx_group_mng_window:search("my_title").text = team_info:get(packet.key.cmn_name).v_string
  gx_group_mng_window:search("team_win").text = sys.format(ui.get_text("match|groupmng_title_win"), win)
  gx_group_mng_window:search("team_los").text = sys.format(ui.get_text("match|groupmng_title_los"), los)
  gx_group_mng_window:search("team_tie").text = sys.format(ui.get_text("match|groupmng_title_tie"), tie)
  gx_group_mng_window:search("team_rate").text = sys.format(ui.get_text("match|groupmng_title_rate"), get_rate(win, los, tie))
  gx_group_mng_window:search("team_score").text = sys.format(ui.get_text("match|groupmng_title_score"), get_score(win, los, tie))
end
function get_career_name(val)
  local pro = bo2.gv_profession_list:find(val)
  if pro == nil then
    return 0
  end
  return pro.name
end
function CreateMemberInfo(member_info)
  local win = member_info:get(packet.key.dooaltar_win).v_int
  local los = member_info:get(packet.key.dooaltar_lost).v_int
  local tie = member_info:get(packet.key.dooaltar_tie).v_int
  local onlyid = member_info:get(packet.key.cha_onlyid)
  local item = gx_memberlist:item_append()
  item:load_style("$frame/match/group_mng.xml", "memberitem")
  item:search("name").text = member_info:get(packet.key.cmn_name).v_string
  local level = member_info:get(packet.key.cha_level).v_int
  item:search("level").text = sys.format(ui.get_text("match|groupmng_title_level"), level)
  local portrait = member_info:get(packet.key.cha_portrait).v_int
  local por_list = bo2.gv_portrait:find(portrait)
  if por_list ~= nil then
    item:search("portrait").image = sys.format("$icon/portrait/%s.png", por_list.icon)
  end
  local career = member_info:get(packet.key.player_profession).v_int
  item:search("job").text = get_career_name(career)
  item:search("win").text = sys.format(ui.get_text("match|groupmng_title_win"), win)
  item:search("los").text = sys.format(ui.get_text("match|groupmng_title_los"), los)
  item:search("tie").text = sys.format(ui.get_text("match|groupmng_title_tie"), tie)
  item:search("rate").text = sys.format(ui.get_text("match|groupmng_title_rate"), get_rate(win, los, tie))
  item:search("score").text = sys.format(ui.get_text("match|groupmng_title_score"), get_score(win, los, tie))
  item.svar.onlyid = onlyid
end
function handleShowGroupMngWin(data)
  gx_memberlist:item_clear()
  local teamData = data:get(packet.key.dooaltar_team)
  CreateTeamInfo(teamData)
  local singleData = data:get(packet.key.group_all_members)
  for i = 0, singleData.size - 1 do
    CreateMemberInfo(singleData:get(i))
  end
  gx_group_mng_window.visible = true
end
function handleUpdateGroupMng(data)
  if gx_group_mng_window.visible == true then
    bo2.send_variant(packet.eCTS_DooAltar_GetScore)
  end
end
function handleCloseGroupMng(data)
  gx_group_mng_window.visible = false
end
function AckGroupInvite(click, data)
  local v = sys.variant()
  v:set(packet.key.dooaltar_single, 1)
  if click == "yes" then
    v:set(packet.key.cmn_agree_ack, 1)
  else
    v:set(packet.key.cmn_agree_ack, 0)
  end
  bo2.send_variant(packet.eCTS_DooAltar_AddMember, v)
end
