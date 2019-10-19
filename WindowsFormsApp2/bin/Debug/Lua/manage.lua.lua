local MaxEnemyNum = bo2.gv_define_org:find(65).value.v_int
local MaxUnionNum = bo2.gv_define_org:find(63).value.v_int - 1
local d_delate_time = bo2.gv_define_org:find(21).value.v_int
local d_del_enemy_money = bo2.gv_define_org:find(66).value.v_int
function on_input_keydown(ctrl, key, keyflag)
  if key == ui.VK_RETURN then
    inputtext = g_info_box.text
  end
end
function on_input_char(ctrl, ch)
  if ch == ui.VK_RETURN then
    g_info_box:remove_on_widget_mouse(ch)
    g_info_box.text = inputtext
    return
  end
end
function on_info_change(ctrl)
  g_info_box.focus_able = true
  g_info_box.focus = true
  g_info_box.mouse_able = true
  g_change_btn.visible = false
  g_confirm_btn.visible = true
  input_mun = 0
  inputtext = g_info_box.text
end
function on_info_confirm(ctrl)
  if sys.findwchar(g_info_box.text, L("\r")) > 1 then
    g_info_box.text = ""
    return
  end
  g_info_box.focus_able = false
  g_info_box.focus = false
  g_info_box.mouse_able = false
  g_change_btn.visible = true
  g_confirm_btn.visible = false
  local v = sys.variant()
  v:set(packet.key.org_vartext, g_info_box.text)
  bo2.send_variant(packet.eCTS_Guild_SetIntro, v)
end
function on_info_confirm_info(ctrl)
  g_info_box.focus_able = false
  g_info_box.focus = false
  g_change_btn.visible = true
  g_confirm_btn.visible = false
end
function updata_notice()
  local dst = ui.filter_text(ui.guild_get_intro())
  g_info_box.text = dst
  g_info_box.size = g_info_box.extent
end
function on_union_btn_click(btn)
  local state = btn.svar.state
  if state == 0 then
    ui_guild_mod.ui_guild_search.set_win_open(1)
  elseif state == 1 then
    local v = sys.variant()
    v:set(packet.key.org_id, btn.svar.guild.org_id)
    bo2.send_variant(packet.eCTS_Guild_EnterTargetGuild, v)
  end
end
function on_leave_union(btn)
  local dialog = {
    text = ui.get_text("guild|guild_manage_leave_union_sure"),
    modal = true,
    btn_confirm = 1,
    btn_cancel = 1,
    callback = function(data)
      if data.result == 1 then
        local v = sys.variant()
        bo2.send_variant(packet.eCTS_Guild_QuitUnion, v)
      end
    end
  }
  ui_widget.ui_msg_box.show_common(dialog)
end
function on_enemy_btn_click(btn)
  local state = btn.svar.state
  if state == 0 then
    ui_guild_mod.ui_guild_search.set_win_open(2)
  elseif state == 1 then
    local dialog = {
      modal = true,
      btn_confirm = 1,
      btn_cancel = 1,
      callback = function(data)
        if data.result == 1 then
          local v = sys.variant()
          v:set(packet.key.org_name, btn.svar.guild.name)
          bo2.send_variant(packet.eCTS_Guild_DelEnemy, v)
        end
      end
    }
    local arg = sys.variant()
    arg:set("name", btn.svar.guild.name)
    arg:set("money", d_del_enemy_money)
    dialog.text = sys.mtf_merge(arg, ui.get_text("guild|guild_manage_del_enemy"))
    ui_widget.ui_msg_box.show_common(dialog)
  end
end
function updata_union()
  local self = ui.guild_get_self()
  if self == nil then
    return
  end
  local cd_begin = ui_guild_mod.ui_guild.g_union_cd_begin
  local cd_end = ""
  if cd_begin ~= 0 then
    local cd_time = bo2.gv_define_org:find(64).value.v_int + cd_begin
    local cur_time = ui_main.get_os_time()
    if cd_time > cur_time then
      local m = os.date("*t", cd_time)
      cd_end = sys.format(ui.get_text("guild|guild_union_cd"), m.month, m.day, m.hour, m.min)
    end
  end
  g_union_manage:search("title").mtf = sys.format(ui.get_text("guild|guild_union_title"), cd_end)
  for i = 1, MaxUnionNum do
    local item = g_union_manage:search("union_" .. i)
    item.visible = true
    item:search("guild_name").visible = false
    item:search("level").visible = false
    item:search("number").visible = false
    local btn = item:search("btn")
    btn.svar.state = 0
    btn.text = ui.get_text("guild|guild_manage_invite_union")
    btn.enable = true
    if cd_end ~= "" then
      btn.enable = false
    end
    local fight = item:search("fight")
    fight.visible = false
    fight.suspended = true
    if self.guild_pos == bo2.Guild_Leader then
      item.visible = true
    else
      item.visible = false
    end
  end
  local union_list = ui_guild_mod.ui_guild.union_list
  if #union_list ~= 0 and self.guild_pos == bo2.Guild_Leader then
    gx_btn_union.visible = true
  else
    gx_btn_union.visible = false
  end
  if #union_list == 0 then
    if self.guild_pos == bo2.Guild_Leader then
      g_union_manage.visible = true
    else
      g_union_manage.visible = false
    end
    return
  end
  g_union_manage.visible = true
  for i = 1, #union_list do
    local guild = union_list[i]
    local item = g_union_manage:search("union_" .. i)
    local guild_name = item:search("guild_name")
    guild_name.text = guild.name
    guild_name.visible = true
    local level = item:search("level")
    level:search("value").text = guild.level
    level.visible = true
    local number = item:search("number")
    number:search("value").text = sys.format("%d/%d", guild.number, guild.maxnum)
    number.visible = true
    local btn = item:search("btn")
    btn.visible = true
    btn.svar.state = 1
    btn.svar.guild = guild
    btn.text = ui.get_text("guild|guild_manage_enter_union")
    if guild.state == 1 then
      local fight = item:search("fight")
      fight.visible = true
      fight.suspended = false
    end
    item.visible = true
  end
end
function updata_enemy()
  local self = ui.guild_get_self()
  if self == nil then
    return
  end
  for i = 1, MaxEnemyNum do
    local item = g_enemy_manage:search("enemy_" .. i)
    item.visible = true
    item:search("guild_name").visible = false
    item:search("level").visible = false
    item:search("number").visible = false
    local btn = item:search("btn")
    btn.svar.state = 0
    btn.text = ui.get_text("guild|guild_manage_add_enemy_btn")
    if self.guild_pos == bo2.Guild_Leader then
      item.visible = true
      btn.enable = true
    else
      item.visible = false
      btn.enable = false
    end
  end
  local enemy_list = ui_guild_mod.ui_guild.enemy_list
  if #enemy_list == 0 then
    if self.guild_pos == bo2.Guild_Leader then
      g_enemy_manage.visible = true
    else
      g_enemy_manage.visible = false
    end
    return
  end
  g_enemy_manage.visible = true
  for i = 1, #enemy_list do
    local guild = enemy_list[i]
    local item = g_enemy_manage:search("enemy_" .. i)
    local guild_name = item:search("guild_name")
    guild_name.text = guild.name
    guild_name.visible = true
    local level = item:search("level")
    level:search("value").text = guild.level
    level.visible = true
    local number = item:search("number")
    number:search("value").text = sys.format("%d/%d", guild.number, guild.maxnum)
    number.visible = true
    local btn = item:search("btn")
    btn.svar.state = 1
    btn.svar.guild = guild
    btn.text = ui.get_text("guild|guild_manage_del_enemy_btn")
    item.visible = true
  end
end
function updata_delate()
  gx_btn_delate.visible = true
  local info = ui.guild_get_delate()
  local self = ui.guild_get_self()
  if info == nil then
    local leader = ui.guild_leader()
    if leader.status == 0 and leader.leave > d_delate_time then
      gx_text_delate.text = ui.get_text("guild|guild_manage_delate_tip1")
    else
      gx_btn_delate.visible = false
      gx_text_delate.text = ui.get_text("guild|guild_manage_delate_tip2")
    end
  elseif self.guild_pos == 5 then
    gx_text_delate.text = ui.get_text("guild|guild_manage_delate_tip3")
  else
    gx_text_delate.text = ui.get_text("guild|guild_manage_delate_tip4")
  end
end
function updata_build()
  for i = 1, 8 do
    local item = gx_build_item:search("build_info_" .. 1)
    item.visible = false
  end
  local item_idx = 1
  local function do_it(line)
    local item = gx_build_item:search("build_info_" .. item_idx)
    item_idx = item_idx + 1
    local name = item:search("name")
    local value = item:search("value")
    name.text = line.name
    local ui_guild_build = ui.guild_get_build(line.type)
    local text = ""
    local color = ui.make_color("ffffff")
    if ui_guild_build == nil then
      color = ui.make_color("646464")
      text = ui.get_text("guild|buildstate_nil")
    elseif ui_guild_build.state == bo2.BuildState_None then
      text = sys.format(ui.get_text("guild|guild_manage_build_tip"), ui_guild_build.level, ui.get_text("guild|buildstate_none"))
    elseif ui_guild_build.state == bo2.BuildState_Collect then
      color = ui.make_color("82c016")
      text = sys.format(ui.get_text("guild|guild_manage_build_tip"), ui_guild_build.level, ui.get_text("guild|guild_manage_build_collect"))
    elseif ui_guild_build.state == bo2.BuildState_Build then
      color = ui.make_color("16bfe9")
      text = sys.format(ui.get_text("guild|guild_manage_build_tip"), ui_guild_build.level, ui.get_text("guild|guild_manage_build_building"))
    end
    value.text = text
    value.color = color
    item.visible = true
  end
  local cult_type = ui.guild_cult_type()
  if cult_type == 0 then
    for i = 1, 8 do
      local line = bo2.gv_guild_build:find(i)
      if line ~= nil then
        do_it(line)
      end
    end
  else
    local n = bo2.gv_guild_cult:find(cult_type)
    if n == nil then
      return
    end
    for i = 0, n.builds.size - 1 do
      local build_id = n.builds[i]
      local line = bo2.gv_guild_build:find(build_id)
      if line ~= nil then
        do_it(line)
      end
    end
  end
end
function updata_pos_visible()
  local self = ui.guild_get_self()
  if self == nil then
    return
  end
  gx_quit_item.visible = true
  gx_title_item.visible = true
  gx_hall_item.visible = true
  gx_apply_item.visible = true
  gx_build_item.visible = true
  g_info_box.focus_able = false
  g_info_box.focus = false
  g_info_box.mouse_able = false
  g_change_btn.visible = true
  g_confirm_btn.visible = false
  local line = bo2.gv_guild_auth:find(self.guild_pos)
  if self.guild_pos == bo2.Guild_Leader then
    gx_quit_item.visible = false
  end
  if line.info ~= 1 then
    g_change_btn.visible = false
  end
  if line.invite ~= 1 then
    gx_apply_item.visible = false
  end
  if line.approve ~= 1 then
    gx_apply_item.visible = false
  end
  if line.appoint ~= 1 then
    gx_title_item.visible = false
  end
  if line.levelup ~= 1 or ui.guild_get_build(1) == nil then
    gx_build_item.visible = false
  end
  if line.hallrename ~= 1 then
    gx_hall_item.visible = false
  end
end
function on_visible(w, v)
  if v == true then
    updata_pos_visible()
    updata_notice()
    updata_delate()
    updata_build()
    bo2.send_variant(packet.eCTS_Guild_GetUnionList, v)
    bo2.send_variant(packet.eCTS_Guild_GetEnemyList, v)
  end
end
function on_apply_click(btn)
  ui_guild_mod.ui_apply.w_guild_apply_mgr.visible = not ui_guild_mod.ui_apply.w_guild_apply_mgr.visible
end
function on_title_click(btn)
  ui_guild_mod.ui_title.w_guild_title_mgr.visible = not ui_guild_mod.ui_title.w_guild_title_mgr.visible
end
function on_hall_click(btn)
  ui_guild_mod.ui_hall.w_guild_hall_mgr.visible = not ui_guild_mod.ui_hall.w_guild_hall_mgr.visible
end
function on_delate_click(btn)
  ui_guild_mod.ui_delate.w_delate_main.visible = not ui_guild_mod.ui_delate.w_delate_main.visible
end
function on_build_click(btn)
  ui_guild_mod.ui_build.w_guild_build.visible = not ui_guild_mod.ui_build.w_guild_build.visible
end
function on_invite_member(ctrl)
  local on_invite_member_msg = function(msg)
    if msg == nil then
      return
    end
    if msg.result == 1 then
      local v = sys.variant()
      v:set(packet.key.org_tarplayername, msg.input)
      bo2.send_variant(packet.eCTS_Guild_InviteM, v)
    end
  end
  local msg = {
    callback = on_invite_member_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    show_sound = 578,
    hide_sound = 579,
    limit = 32
  }
  msg.text = ui.get_text("guild|name")
  msg.input = L("")
  ui_widget.ui_msg_box.show_common(msg)
end
function ack_guild_invite_popo(click, data)
  ui.console_print("ack_guild_invite_popo.")
  local v = sys.variant()
  ui.console_print("guild_requestid is %s", data:get(packet.key.org_requestid).v_string)
  v:set(packet.key.org_requestid, data:get(packet.key.org_requestid))
  accept = 0
  if "yes" ~= click then
    accept = 1
  end
  v:set(packet.key.org_acceptrequest, accept)
  v:set(packet.key.cmn_type, bo2.eSociality_ResponseType_GuildInvite)
  bo2.send_variant(packet.eCTS_Guild_Response, v)
end
function on_leave()
  local on_leave_msg = function(msg)
    if msg == nil then
      return
    end
    if msg.result == 1 then
      local v = sys.variant()
      bo2.send_variant(packet.eCTS_Guild_Leave, v)
      ui_guild_mod.ui_guild.w_win.visible = false
    end
  end
  local text = ui.get_text("guild|leave_msg2")
  if ui.npc_guild_mb_id() ~= 0 then
    text = ui.get_text("guild|leave_msg")
  end
  local msg = {
    callback = on_leave_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    show_sound = 578,
    hide_sound = 579,
    text = text
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_build_guild(ctrl)
  local on_build_guild_msg = function(msg)
    if msg == nil then
      return
    end
    if msg.result == 1 then
      local v = sys.variant()
      v:set(packet.key.org_name, msg.input)
      bo2.send_variant(packet.eCTS_Guild_Build, v)
    end
  end
  local msg = {
    callback = on_build_guild_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    limit = 16
  }
  local define_org = bo2.gv_define_org:find(30)
  local arg = sys.variant()
  local money = define_org.value
  arg:set("money", money)
  msg.text = sys.mtf_merge(arg, ui.get_text("guild|guild_build_msg"))
  msg.input = L("")
  ui_widget.ui_msg_box.show_common(msg)
end
function on_guild_dismiss(ctrl)
  local on_dismiss_msg = function(msg)
    if msg == nil then
      return
    end
    if msg.result == 1 then
      local v = sys.variant()
      bo2.send_variant(packet.eCTS_Guild_Dismiss, v)
    end
  end
  local msg = {
    callback = on_dismiss_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui.get_text("guild|guild_dismiss_msg")
  ui_widget.ui_msg_box.show_common(msg)
end
function on_guild_cancel_dismiss(ctrl)
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_Guild_Cancel, v)
end
function on_guild_BuyBuild(ctrl)
  local on_BuyBuild_msg = function(msg)
    if msg == nil then
      return
    end
    if msg.result == 1 then
      local v = sys.variant()
      bo2.send_variant(packet.eCTS_Guild_BuyBuild, v)
    end
  end
  local msg = {
    callback = on_BuyBuild_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui.get_text("guild|guild_buybuild_msg")
  ui_widget.ui_msg_box.show_common(msg)
end
