local reg = ui_packet.game_recv_signal_insert
local sig = "ui_console.packet_handler"
local show_gm_act = function(cmd, data)
  local t, v = data:fetch_nv(0)
  local txt = tostring(t.v_string)
  if txt == "" then
    return
  end
  if txt == "ShowGroup" then
    ui.console_print("---------------------------------------------")
    ui.console_print([[
GroupID:%s
MaxMemberCount=%s
CaptainName=%s]], v:get("GroupID").v_string, v:get("MaxMemberCount").v_string, v:get("CaptainName").v_string)
    local mv = sys.variant()
    mv = v:get("Members")
    if not mv.empty then
      for i = 0, mv.size - 1 do
        local m = sys.variant()
        m = mv:get(i)
        ui.console_print("%d %s", m:get("MemberID").v_int, m:get("MemberName").v_string)
      end
    end
  elseif txt == "ListGroup" then
    for i = 0, v.size - 1 do
      local cv = sys.variant()
      cv = v:get(i)
      ui.console_print("---------------------------------------------")
      ui.console_print([[
GroupID:%s
MaxMemberCount=%s
CaptainName=%s]], cv:get("GroupID").v_string, cv:get("MaxMemberCount").v_string, cv:get("CaptainName").v_string)
    end
  elseif txt == "ShowFlag" then
    local tp = v:get("TYPE").v_int
    if tp == bo2.eFlagType_Atb then
      ui.console_print("atb(%d) = %d", v:get("ID").v_int, v:get("VAL").v_int)
    elseif tp == bo2.eFlagType_ObjMemory then
      ui.console_print("memoryflag(%d) = %d", v:get("ID").v_int, v:get("VAL").v_int)
    end
  elseif txt == "getpos" then
    local obj = bo2.findobj(v:get("handle").v_string)
    if not obj then
      ui.log("Client not found obj")
      return
    end
    local v0, v1, v2 = obj:get_position()
    local Clienthigh = obj:get_high()
    ui.console_print([[
%s:client--> id:%u ,
               pos( %f,
                       %f,
                       %f)
]], obj.name, v2, v0, Clienthigh, v1)
    ui.console_print([[
%s:server--> id:%s ,
               pos( %f,
                       %f,
                       %f)
]], obj.name, v:get("id").v_string, v:get("x").v_number, v:get("y").v_number, v:get("z").v_number)
  elseif txt == "ShowAllBattleTable" then
    ui.console_print("--------\213\189------\179\161--------")
    for i = 0, v.size - 1 do
      local p = v:get(i)
      local battle_packets = p:get(packet.key.cmn_dataobj)
      ui.console_print("State %d Have %d Battles : ", p:get(packet.key.cmn_type).v_int, battle_packets.size)
      for j = 0, battle_packets.size - 1 do
        local battle = battle_packets:get(j)
        ui.console_print("OnlyID:%s, Level:%d, Count:%d\n", battle:get(packet.key.battlegroup_id).v_string, battle:get(packet.key.battle_level).v_int * 10, battle:get(packet.key.battle_player_count).v_int)
      end
    end
  elseif txt == "ShowAllBattleApply" then
    ui.console_print("--------\213\189------\179\161--------")
    for i = 0, v.size - 1 do
      local p = v:get(i)
      ui.console_print("OnlyID:%s, Name:%s, Level:%d\n", p:get(packet.key.cha_onlyid).v_string, p:get(packet.key.cha_name).v_string, p:get(packet.key.cha_level).v_int)
    end
  elseif txt == "ShowBattleTableInfo" then
    ui.console_print("--------\213\189------\179\161--------")
    ui.console_print("#TableInfo")
    ui.console_print([[
OnlyID:%s
Level:%d
Count:%d
]], v:get(packet.key.battlegroup_id).v_string, v:get(packet.key.battle_level).v_int * 10, v:get(packet.key.battle_player_count).v_int)
    ui.console_print("#PlayersInfo")
    local players = v:get(packet.key.battlegroup_players)
    for i = 0, players.size - 1 do
      local p = players:get(i)
      ui.console_print("[%d] OnlyID:%s, Name:%s, Level:%d, Side:%d\n", i, p:get(packet.key.cha_onlyid).v_string, p:get(packet.key.cha_name).v_string, p:get(packet.key.cha_level).v_int, p:get(packet.key.arena_side).v_int)
    end
  elseif txt == "reloadmb" then
    bo2.mb_reload()
  elseif txt == "lookstate" then
    local vStates = v:get("states")
    local name = v:get("name").v_string
    ui.console_print("-->%s:state num %d", name, vStates.size)
    if 0 < vStates.size then
      ui.console_print("{")
      for i = 0, vStates.size - 1 do
        local id = vStates:get(i).v_int
        local pExcel = bo2.gv_state_container:find(id)
        ui.console_print("    id:%d %s", id, pExcel.name)
      end
      ui.console_print("}")
    end
  elseif txt == "ShowCampaignTime" then
    ui.console_print("---------\187\238\182\175\183\254\202\177\188\228----------")
    ui.console_print(os.date("%Y/%m/%d %H:%M:%S", v:get(0).v_int))
  end
  ui.console_print("-->" .. txt .. "--------\205\234------\179\201--------")
end
function cmd_init()
  reg(packet.eSTC_GM_Ack, show_gm_act, sig)
end
function my_format(str)
  for v in string.gmatch(str, "%%%a") do
    if v == "%m" then
      str = string.gsub(str, "%%m", tostring(bo2.player.name))
    elseif v == "%t" then
      local target_handle = bo2.player.target_handle
      if not target_handle then
        return
      end
      local target = bo2.scn:get_scn_obj(target_handle)
      if not target then
        return
      end
      str = string.gsub(str, "%%t", tostring(target.name))
    end
  end
  return str
end
function cmd_exec_exp(text)
  for v in string.gmatch(text, "[%%%w%s_]+") do
    local cmd = my_format(v)
    if cmd ~= nil then
      cmd_exec(cmd)
    end
  end
end
function cmd_exec(text)
  local vcmd = bo2_command.common_check_text(text)
  if vcmd == nil then
    ui.log("client_exec vcmd is nil. text %s.", text)
    ui.console_log(ui_console.log_error, "empty command")
    return string.format("empty command")
  end
  local name = tostring(vcmd:get("name").v_string)
  if string.sub(name, 1, 1) == "$" then
    name = string.sub(name, 2)
    vcmd:set("name", name)
    local stk = sys.stack()
    stk:push(name)
    if vcmd:has("opt") then
      local opt = vcmd:get("opt")
      for i, k, v in vpairs(opt) do
        stk:format(" /%s", k)
        if v.size > 0 then
          stk:push(":")
          sys.write_command(stk, v)
        end
      end
    end
    if vcmd:has("arg") then
      local arg = vcmd:get("arg")
      for i, k, v in vpairs(arg) do
        local t = v
        if t == L("%m") then
          t = bo2.player.name
          arg:set(k, t)
        elseif t == L("%t") then
          local target_handle = bo2.player.target_handle
          if not target_handle then
            return
          end
          local target = bo2.scn:get_scn_obj(target_handle)
          if not target then
            return
          end
          t = target.name
          arg:set(k, t)
        end
        stk:push(" ")
        sys.write_command(stk, t)
      end
    end
    text = stk.text
  end
  local data = bo2_command.command_client[name]
  if data ~= nil then
    if not bo2_command.common_check_command(data, vcmd) then
      ui.console_log(ui_console.log_error, [[
bad command format for '%s'. usage :
%s]], name, data.info)
      return string.format([[
bad command format for '%s'. usage :
%s]], name, data.info)
    end
    local fn = ui_console["on_cmd_" .. name]
    if fn == nil then
      ui.console_log(ui_console.log_error, "not define command handler for '%s'.", "on_cmd_" .. name)
    else
      vcmd:set("text", text)
      sys.pcall(fn, vcmd, vcmd:get("opt"), vcmd:get("arg"):unpack())
    end
    return
  end
  data = bo2_command.command_server[name]
  if data == nil then
    local help_data = bo2_command.command_client.help
    if help_data then
      local fn = ui_console.on_cmd_help
      if fn then
        sys.pcall(fn, nil, nil, vcmd:get("name"))
      end
    end
    ui.console_log(ui_console.log_error, "not find command '%s'.", name)
    return string.format("not find command '%s'.", name)
  end
  if not bo2_command.common_check_command(data, vcmd) then
    ui.console_log(ui_console.log_error, [[
bad command format for '%s'. usage :
%s]], name, data.info)
    return string.format([[
bad command format for '%s'. usage :
%s]], name, data.info)
  end
  local gmpacket = sys.variant()
  gmpacket:set(packet.key.tool_gmcommand, text)
  bo2.send_variant(packet.eCTS_GM_Command, gmpacket)
end
function cmd_recv(info)
end
function on_cmd_cls(cmd)
  ui_console.clear()
end
function on_cmd_print(cmd, opt, txt)
  ui.console_print("%s", txt)
end
function on_cmd_reloadcm(cmd, opt, mod)
  local s = sys.reload_module(mod)
  if s.empty then
    ui.console_print("reload module '%s' succeeded.", mod)
  else
    ui.console_print([[
reload module '%s' finished. error info:
%s]], mod, s)
  end
end
function on_cmd_reanim(cmd, opt, uri)
  if ui.reload_animation(uri) then
    ui.console_print("succeeded reload %s", uri)
  else
    ui.console_print("failed reload %s", uri)
  end
end
function on_cmd_retrans(cmd, opt, uri)
  if ui.reload_transition(uri) then
    ui.console_print("succeeded reload %s", uri)
  else
    ui.console_print("failed reload %s", uri)
  end
end
function on_cmd_run(vcmd)
  local arg = vcmd:get("arg")
  local file = L("$cfg/tool/batch/") .. arg:get(0).v_string .. ".lua"
  ui.console_print("loading script file '%s'.", file)
  if not sys.load_script(file) then
    ui.console_print("run script '%s' failed.", file)
    return
  end
  ui.console_print("run script '%s' succeeded.", file)
end
function on_cmd_login(cmd, opt, v_username, v_password)
  ui.console_print("login start.")
  if ui_startup.login({
    username = v_username.v_string,
    password = v_password.v_string
  }) then
    ui_phase.w_startup.visible = false
    ui_phase.ui_choice.show_top(true)
    ui_tool.ui_console.input_focus()
  else
    ui.console_print("login failed.")
    return
  end
  ui.console_print("login ok.")
  if opt.empty then
    return
  end
  local cha_create = opt:get("c")
  if not cha_create.empty then
    local v = cha_create:split_to_array(",")
    local name = v:get(0).v_string
    local excel_id = v:get(1).v_int
    local career = v:get(2).v_int
    if not do_cmd_createcha({
      name = name,
      excel_id = excel_id,
      career = career
    }) then
      return
    end
  end
  local gzs_enter = opt:get("n")
  if not gzs_enter.empty then
    local v = gzs_enter:split_to_array(",")
    local cha = v:get(0).v_string
    local gzs = v:get(1).v_int
    ui.console_print("cha %s, gzs %s, v %s, g %s.", cha, gzs, v, gzs_enter)
    if not do_cmd_entergzs({cha = cha, gzs = gzs}) then
      return
    end
  end
end
function do_cmd_createcha(data)
  ui.console_print("createcha start.")
  if ui_startup.cha_create(data) then
    ui_phase.ui_choice.show_top(true)
    ui_tool.ui_console.input_focus()
    ui.console_print("createcha '%s' ok.", data.name)
    return true
  else
    ui.console_print("createcha '%s' failed.", data.name)
    return false
  end
end
function on_cmd_createcha(vcmd)
  local arg = vcmd:get("arg")
  local name = arg:get(0).v_string
  local excel_id = arg:get(1).v_int
  local career = arg:get(2).v_int
  do_cmd_createcha({
    name = name,
    excel_id = excel_id,
    career = career
  })
end
function on_cmd_listcha(vcmd)
  local text = ui_startup.cha_list_text()
  ui.console_print([[
list cha:
%s]], text)
end
function do_cmd_entergzs(data)
  ui.console_print("entergzs start.")
  ui_phase.ui_choice.show_top(false)
  ui_phase.ui_loading.show_top(true)
  if ui_startup.gzs_enter_id(data) then
    ui.console_print("entergzs '%s' ok.", data.gzs)
    ui_tool.ui_console.input_focus()
    return true
  else
    ui_phase.ui_choice.show_top(true)
    ui_phase.ui_loading.show_top(false)
    ui_tool.ui_console.input_focus()
    ui.console_print("entergzs '%s' failed.", data.gzs)
    return false
  end
end
function on_cmd_entergzs(vcmd)
  local arg = vcmd:get("arg")
  local cha = arg:get(0).v_string
  local gzs = arg:get(1).v_string.v_int
  do_cmd_entergzs({cha = cha, gzs = gzs})
end
function on_cmd_entergzsn(vcmd)
  local arg = vcmd:get("arg")
  local cha = arg:get(0).v_string
  local gzs = arg:get(1).v_string
  ui_startup.gzs_enter_name({cha = cha, gzs = gzs})
end
function on_cmd_listgzs(vcmd)
  local text = ui_startup.gzs_list_text()
  ui.console_print([[
list gzs:
%s]], text)
end
function on_cmd_zhong18(vcmd, opt, name)
  if name.v_int == 0 then
    ui_tool.tool_cfg_inner_utility = false
    ui.console_print("close close close")
  else
    ui_tool.tool_cfg_inner_utility = true
    ui.console_print("open open open")
  end
end
function on_cmd_groupadd(cmd, opt, cha_name)
  ui_group.send_invite_cha(cha_name)
end
function on_cmd_groupsetteam()
  ui_group.send_setteam()
end
function on_cmd_runf(cmd, opt, func_name, ...)
  local func = sys.get(func_name)
  if func then
    func(...)
  else
    ui.console_print("bad function name '%s'", text)
  end
end
function on_cmd_groupop(cmd, opt, operate, ...)
  local t = {
    captain = ui_group.send_change_captain,
    delete = ui_group.send_delete_member,
    release = ui_group.send_release,
    setgroup = ui_group.send_setgroup,
    adjust = ui_group.send_AdjustPosition,
    merge = ui_group.send_merge
  }
  local op = t[tostring(operate.v_string)]
  if ui_group.id and op then
    op(...)
  end
end
function on_cmd_chat(vcmd)
  local arg = vcmd:get("arg")
  local channel_id = arg:get(0).v_int
  local text = arg:get(1).v_string
  local target_name = arg:get(2).v_string
  local v = sys.variant()
  v:set(packet.key.chat_channel_id, channel_id)
  v:set(packet.key.chat_text, text)
  v:set(packet.key.target_name, target_name)
  bo2.send_variant(packet.eCTS_UI_Chat, v)
end
function on_cmd_quest(cmd, opt, operate, ...)
  local t = {
    add = ui_quest.add,
    giveup = ui_quest.giveup,
    next = ui_quest.next,
    complete = ui_quest.complete,
    listall = ui_quest.listall,
    show = ui_quest.show,
    talk_npc = ui_quest.talk_npc
  }
  local op = t[tostring(operate.v_string)]
  if op then
    op(...)
  end
end
function on_cmd_talksel(cmd, opt, kind, id)
  ui_packet.talk_sel(kind, id)
end
function on_cmd_sdeb(cmd, opt, port)
  bo2.sdeb(port.v_int)
end
function on_cmd_ui_reload(cmd, opt, frame, uri, style)
  local w = ui.find_control(frame)
  if not sys.check(w) then
    ui.console_print("reload frame '%s' failed: not found frame.", frame)
    return
  end
  ui.clear_skin()
  local vis = w.visible
  w:control_clear()
  local s = w:load_style_with_info(uri, style)
  if vis then
    w.visible = vis
  end
  if s.empty then
    ui.console_print("reload frame '%s' ok.", frame)
    return
  end
  ui.console_print([[
reload frame '%s' failed with info:
%s.]], frame, s)
end
function on_cmd_ui_retext(cmd, opt)
  ui.reload_text()
end
function on_cmd_ui_realias(cmd, opt, alias)
  local s = ui.reload_alias(alias)
  if s.empty then
    ui.console_print("reload alias '%s' ok.", alias)
    return
  end
  ui.console_print([[
reload alias '%s' failed with info:
%s.]], alias, s)
end
function on_cmd_ui_view(cmd, opt, alias)
  alias = alias.v_string
  if alias == L("*") then
    local s = ui_tool.plugin_ui_view.alias
    ui.console_print("ui_view alias list : %s", s)
    return
  end
  if alias == L("-") then
    ui_tool.plugin_ui_view:alias_clear()
    ui.console_print("ui_view alias clear")
    return
  end
  ui_tool.plugin_ui_view:alias_insert(alias)
  ui.console_print("ui_view alias insert : %s", alias)
end
function on_cmd_ui_wuguanlist(cmd, opt)
  ui_dungeonui.ui_dungeoninfo.set_visible()
end
function on_cmd_ui_viewplayer(cmd, opt, name)
  local v = sys.variant()
  v:set(packet.key.cha_name, name)
  bo2.send_variant(packet.eCTS_UI_PlayerView, v)
  ui.console_print("send viewplayer message for '%s'.", name)
end
function on_cmd_cperf(cmd, opt, sub, arg)
  local handlers = {
    host = function()
      bo2.perf_host(arg)
    end,
    enable = function()
    end,
    clear = function()
      bo2.perf_clear(arg)
    end,
    list = function()
    end
  }
  local fn = handlers[tostring(sub)]
  if fn == nil then
    ui.console_print("bad cperf sub command.")
    return
  end
  fn()
end
function on_cmd_show(cmd, opt, ntype, b)
  if not bo2.show_entity(ntype.v_int, b.v_int) then
    ui.console_print(bo2_command.command_client.show.info)
  else
    ui.console_print("-->\178\217\215\247\179\201\185\166!")
  end
end
function on_cmd_scene_black(gm, opt, nFps, fAlpha, b)
  bo2.scene_black(nFps.v_int, fAlpha.v_number, b.v_int)
end
function on_cmd_deal_create(cmd, opt, target_name)
  local v = sys.variant()
  v:set(packet.key.target_name, target_name)
  v:set(packet.key.ui_invite_type, bo2.INVITE_TYPE_Deal)
  bo2.send_variant(packet.eCTS_UI_CommonInvite, v)
end
function on_cmd_chgtwrelation(cmd, opt, request_name, target_name, chgtype)
  ui.console_print("chgtwrelation")
  local v = sys.variant()
  v:set(packet.key.sociality_srcplayername, request_name)
  v:set(packet.key.sociality_tarplayername, target_name)
  v:set(packet.key.sociality_twrelationchgtype, chgtype)
  bo2.send_variant(2502, v)
  ui.console_print("eCTS_Sociality_ChgTWRelation is %d", packet.eCTS_Sociality_ChgTWRelation)
  ui.console_print("send_variant over")
end
function on_cmd_responserelation(cmd, opt, request_id, accept)
  ui.console_print("responserelation")
  local v = sys.variant()
  v:set(packet.key.sociality_requestid, request_id)
  ui.console_print("packet.key.sociality_requestid is %d ", packet.key.sociality_requestid)
  ui.console_print("request_id is %s ", request_id)
  v:set(packet.key.sociality_acceptrequest, accept)
  bo2.send_variant(2504, v)
  ui.console_print("send_variant over")
end
function on_cmd_showrelation(cmd, opt, request_name)
  ui.console_print("showrelation")
  local v = sys.variant()
  v:set(packet.key.sociality_srcplayername, request_name)
  bo2.send_variant(2505, v)
  ui.console_print("showrelation over")
end
function on_cmd_addrelationdepth(cmd, opt, request_name, target_name, chgpoint)
  ui.console_print("addrelationdepth")
  local v = sys.variant()
  v:set(packet.key.sociality_srcplayername, request_name)
  v:set(packet.key.sociality_tarplayername, target_name)
  v:set(packet.key.sociality_adddepthpoint, chgpoint)
  bo2.send_variant(2506, v)
  ui.console_print("addrelationdepth over")
end
function on_cmd_endtwrelation(cmd, opt, request_name, target_name)
  ui.console_print("endtwrelation")
  local v = sys.variant()
  v:set(packet.key.sociality_srcplayername, request_name)
  v:set(packet.key.sociality_tarplayername, target_name)
  bo2.send_variant(2503, v)
  ui.console_print("endtwrelation over")
end
function on_cmd_showhit(cmd, opt, chaname, open)
  ui.console_print("showhit")
  bo2.showhit(chaname.v_string, open.v_int)
end
function on_cmd_camerashaker(cmd, opt, fps, id)
  ui.console_print("camera shaker")
  bo2.camera_shaker(fps.v_int, id.v_int)
end
function on_cmd_cameradata(cmd, opt)
  local vData = bo2.GetCameraData()
  ui.console_print("---------begin---------\n")
  ui.console_print("free camera:\n")
  local free_x = vData:get(packet.key.cha_pos_x).v_number
  local free_y = vData:get(packet.key.cha_pos_y).v_number
  local free_z = vData:get(packet.key.cha_pos_z).v_number
  local free_yaw = vData:get(packet.key.cha_min_level).v_number
  local free_pitch = vData:get(packet.key.cha_max_level).v_number
  local free_text = sys.format("%.3f;%.3f;%.3f\n", free_x, free_y, free_z)
  ui.console_print(free_text)
  free_text = sys.format("%.3f;%.3f;0.000\n", free_yaw, free_pitch)
  ui.console_print(free_text)
  local free_diff = vData:get(packet.key.cls_ping_diff).v_number
  local free_diff_text = sys.format("fdiff:%.3f;\n", free_diff)
  local satellite_x = vData:get(packet.key.action_target_x).v_number
  local satellite_y = vData:get(packet.key.action_target_y).v_number
  local satellite_z = vData:get(packet.key.action_target_z).v_number
  ui.console_print("-----\n")
  ui.console_print("satellite camera:\n")
  local satellite_yaw = vData:get(packet.key.action_target_id).v_number
  local satellite_pitch = vData:get(packet.key.action_distance).v_number
  local satellite_radius = vData:get(packet.key.action_speed).v_number
  local satellite_text = sys.format("%.3f;%.3f;%.3f\n", satellite_x, satellite_y, satellite_z)
  ui.console_print(satellite_text)
  local satellite_text = sys.format("%.3f;%.3f;0.0\n", satellite_yaw, satellite_pitch)
  ui.console_print(satellite_text)
  local satellite_text = sys.format("%.3f;\n", satellite_radius)
  ui.console_print(satellite_text)
  ui.console_print(free_diff_text)
  ui.console_print("---------end---------\n")
end
function on_cmd_camerajump(cmd, opt, excel_id, target)
  local iHandle = 0
  if target ~= nil and target.v_int == 1 then
    iHandle = bo2.player.target_handle
  end
  local scn = bo2.scn
  local excel_data = excel_id.v_int
  scn:SetCameraControl(excel_data, iHandle)
  local camera_excel = bo2.gv_camera_control:find(excel_data)
  if sys.check(camera_excel) then
    local v = sys.variant()
    v:set(packet.key.cmn_type, camera_excel.ui_mask_control)
    v:set(packet.key.cmn_index, camera_excel.id)
    ui_mask.on_handle_vis_window(nil, v)
  end
end
function on_cmd_addfriend(cmd, opt, player_name, player_signature, player_state, relation_depth, relation_type)
  ui.console_print("on_cmd_addfriend player_name is %s, sig = %s, player_state = %s, depth = %s, type is %s", player_name, player_signature, player_state, relation_depth, relation_type)
  ui_sociality.add_friend(player_name, player_signature, player_state, relation_depth, relation_type)
  ui.console_print("addfriend over")
end
function on_cmd_removefriend(cmd, opt, player_name)
  ui.console_print("on_cmd_removefriend name is %s", player_name)
  ui_sociality.remove_tree_item(player_name)
  ui.console_print("removefriend over")
end
function on_cmd_buildfamily(cmd, opt, family_name)
  ui.console_print("on_cmd_build_family name is %s", family_name)
  local v = sys.variant()
  v:set(packet.key.org_name, family_name)
  bo2.send_variant(packet.eCTS_Family_Build, v)
  ui.console_print("buildfamily over")
end
function on_cmd_applyfamily(cmd, opt, family_name, apply_text)
  ui.console_print("on_cmd_apply_family name is %s", family_name)
  local v = sys.variant()
  v:set(packet.key.org_name, family_name)
  v:set(packet.key.org_vartext, apply_text)
  bo2.send_variant(packet.eCTS_Family_Apply, v)
  ui.console_print("applyfamily over")
end
function on_cmd_buildguild(cmd, opt, guild_name)
  ui.console_print("on_cmd_build_guild name is %s", guild_name)
  local v = sys.variant()
  v:set(packet.key.org_name, guild_name)
  bo2.send_variant(packet.eCTS_Guild_Build, v)
  ui.console_print("buildguild over")
end
function on_cmd_applyguild(cmd, opt, guild_name, apply_text)
  ui.console_print("on_cmd_apply_guild name is %s", guild_name)
  local v = sys.variant()
  v:set(packet.key.org_name, guild_name)
  v:set(packet.key.org_vartext, apply_text)
  bo2.send_variant(packet.eCTS_Guild_ApplyM, v)
  ui.console_print("applyguild over")
end
function on_cmd_applyguildmember(cmd, opt, guild_name, apply_text)
  ui.console_print("on_cmd_apply_guild_member name is %s", guild_name)
  local v = sys.variant()
  v:set(packet.key.org_name, guild_name)
  v:set(packet.key.org_vartext, apply_text)
  bo2.send_variant(packet.eCTS_Guild_ApplyM, v)
  ui.console_print("applyguildmember over")
end
function on_cmd_arenaapply(cmd, opt, arenamode, arenacount)
  local v = sys.variant()
  v:set(packet.key.cmn_type, arenamode)
  v:set(packet.key.cmn_state, arenacount)
  bo2.send_variant(packet.eCTS_Arena_ApplyRequest, v)
end
function on_cmd_gc()
  collectgarbage("collect")
  local memUsed = collectgarbage("count")
  ui.console_print(memUsed)
end
function on_cmd_renderlogic(cmd, opt, nType, nBool)
  bo2.logicRender(nType.v_int, nBool.v_int)
end
function on_cmd_setsearchroad(cmd, opt, nBool)
  bo2.searchRoad(nBool.v_int)
end
function on_cmd_coloreffect(cmd, opt, nFps, nType, strColor)
  if not bo2.setcoloreffect(nFps.v_int, nType.v_int, strColor.v_string) then
    ui.console_print("wrong color format, eg.0xffffffff")
  end
end
function on_cmd_help(cmd, opt, read_info, helptype)
  local strOutputClientCommand = [[
Client Commands: 
-------
]]
  local srtOutputServerCommand = [[
GM Commands: 
-------
]]
  local ihelptype = 0
  local read_argc
  if helptype ~= nil then
    ihelptype = helptype.v_int
  end
  if read_info ~= nil then
    read_argc = read_info.v_string
  end
  if bo2_command == nil or bo2_command.command_client == nil or type(bo2_command.command_client) ~= "table" then
    strOutputClientCommand = "Can't get the client command!"
  else
    local idx = 1
    local argc_idx = 1
    for i, v in pairs(bo2_command.command_client) do
      if type(i) == "string" then
        if read_argc ~= nil then
          if string.find(i, tostring(read_argc)) ~= nil then
            if v.info ~= nil then
              strOutputClientCommand = strOutputClientCommand .. argc_idx .. "." .. v.info .. [[

-------
]]
            else
              strOutputClientCommand = strOutputClientCommand .. argc_idx .. "." .. i .. [[

-------
]]
            end
            argc_idx = argc_idx + 1
          end
        else
          strOutputClientCommand = strOutputClientCommand .. idx .. "." .. i .. "\n"
        end
      else
        strOutputClientCommand = strOutputClientCommand .. idx .. ".can not get this command, please check command_client.txt ."
      end
      idx = idx + 1
    end
    if ihelptype ~= 2 then
      ui.console_print(strOutputClientCommand)
    end
  end
  if bo2_command == nil or bo2_command.command_server == nil or type(bo2_command.command_server) ~= "table" then
    srtOutputServerCommand = "Can't get the client command!"
  else
    local idx = 1
    local argc_idx = 1
    for i, v in pairs(bo2_command.command_server) do
      if type(i) == "string" then
        if read_argc ~= nil then
          if string.find(i, tostring(read_argc)) ~= nil then
            if v.info ~= nil then
              srtOutputServerCommand = srtOutputServerCommand .. argc_idx .. "." .. v.info .. [[

-------
]]
            else
              srtOutputServerCommand = srtOutputServerCommand .. argc_idx .. "." .. i .. [[

-------
]]
            end
            argc_idx = argc_idx + 1
          end
        else
          srtOutputServerCommand = srtOutputServerCommand .. idx .. "." .. i .. "\n"
        end
      else
        srtOutputServerCommand = srtOutputServerCommand .. idx .. ".can not get this command, please check command_server.txt"
      end
      idx = idx + 1
    end
    if ihelptype ~= 1 then
      ui.console_print(srtOutputServerCommand)
    end
  end
end
function on_cmd_man(cmd, opt, arg1)
  local name = arg1.v_string
  ui.log("-------------------------------------------class '" .. name .. "' registry table begin--------------------------------------")
  ui.console_print("------class '" .. name .. "'  begin------")
  local _strMember = sys.get_class_info(tostring(name))
  ui.log(_strMember)
  ui.console_print(strMethod)
  ui.log("------------------------------------------- end--------------------------------------")
end
function on_cmd_openguild()
  local guild_view = ui.find_control("$frame:guild")
  guild_view.visible = not guild_view.visible
end
function on_cmd_openhd()
  local campaign_view = ui.find_control("$frame:campaign")
  campaign_view.visible = not campaign_view.visible
end
function on_cmd_openrank()
  local rank_view = ui.find_control("$frame:rank")
  rank_view.visible = not rank_view.visible
end
function on_cmd_chglocalweather(cmd, opt, typename, uTime)
  ui.console_print("change client weather to " .. typename.v_string .. " in [" .. uTime.v_int .. "] seconds")
  bo2.chglocalweather(typename.v_string, uTime.v_int)
end
function on_cmd_showfriend()
  ui.console_print("on_cmd_showfriend ")
  local w = ui.find_control("$frame:friends_main")
  w.visible = not w.visible
end
function on_cmd_settime(cmd, opt, idx, fSecond, bLocalTime)
  if idx ~= nil then
    ui.console_print("modify time :" .. idx.v_int)
    if bLocalTime == nil then
      bo2.chglocaltime(idx.v_int, 0, 1)
    elseif bLocalTime.v_int < 1 then
      bo2.chglocaltime(idx.v_int, 0, false)
    else
      bo2.chglocaltime(idx.v_int, 0, true)
    end
    return
  end
  if idx == nil then
    bo2.chglocaltime(0, fSecond.v_double, 1)
    return
  end
end
function on_cmd_chgcamera(cmd, opt, type)
  bo2.chgcamera(type.v_int)
end
function on_cmd_chgcamera_speed(cmd, opt, speed)
  bo2.chgcamera_speed(speed.v_number)
end
function on_cmd_addmethodunit(cmd, opt, id, bdest)
  local usedest = false
  if bdest.v_int == 1 then
    usedest = true
  end
  bo2.add_methodunit(id.v_int, usedest)
end
function on_cmd_delenemy(cmd, opt, name)
  local v = sys.variant()
  v:set(packet.key.sociality_tarplayername, name)
  bo2.send_variant(packet.eCTS_Sociality_DelEnemy, v)
end
function on_cmd_video(cmd, opt, action, filename)
  action = action.v_string
  if action == L("rec") then
    bo2.VideoRecord(L("$app/video/") .. filename.v_string)
  elseif action == L("close") then
    bo2.VideoClose()
  elseif action == L("Replay") then
    bo2.VideoReplay(L("$app/video/") .. filename.v_string)
  elseif action == L("Stop") then
    bo2.VideoStop()
  else
    ui_video.w_main.visible = true
  end
end
function on_cmd_addanimal(cmd, opt, name, count)
  bo2.addanimal(name.v_int, count.v_int)
end
function on_cmd_scode_request(cmd, opt, kind)
  local data = sys.variant()
  data:set(packet.key.cha_onlyid, bo2.player.only_id)
  data:set(packet.key.check_code_kind, kind)
  bo2.send_variant(packet.eCTS_SecurityCode_Request, data)
end
function on_cmd_scode_check(cmd, opt, only_id, kind, code)
  local data = sys.variant()
  data:set(packet.cha_onlyid, bo2.player.only_id)
  data:set(packet.key.check_code, code)
  data:set(packet.key.check_code_kind, kind)
  data:set(packet.key.check_code_only_id, only_id)
  data:set(packet.key.cha_onlyid, bo2.player.only_id)
  bo2.send_variant(packet.eCTS_SecurityCode_Check, data)
end
function on_cmd_addgfx(cmd, opt, filename, cnt)
  local c = 1
  if cnt ~= nil then
    c = cnt.v_int
  end
  for i = 1, c do
    bo2.addgfx(filename.v_string)
  end
end
function on_cmd_qfunc(cmd, opt, kind)
  bo2.qfunc_set_kind(kind.v_int)
end
function on_cmd_openwindow(cmd, opt, name)
  local w = ui.find_control(name)
  if w ~= nil then
    w.visible = true
  end
end
function on_cmd_setfriendgroup(cmd, opt, group_id, group_name)
  local group_v = sys.variant()
  group_v:set(group_id, group_name)
  local v = sys.variant()
  v:set(packet.key.sociality_friendgroup, group_v)
  bo2.send_variant(packet.eCTS_Sociality_ChgFriendGroup, v)
end
function on_cmd_addfriendtofg(cmd, opt, friend_name, group_id)
  local v = sys.variant()
  v:set(packet.key.sociality_tarplayername, friend_name)
  v:set(packet.key.sociality_friendgroup_id, group_id)
  bo2.send_variant(packet.eCTS_Sociality_ChgPlayersFG, v)
end
function on_cmd_shownpctarget(cmd, opt, arg)
  if arg.v_int == 0 then
    ui_portrait.on_cmd_shownpc_target(false)
  else
    ui_portrait.on_cmd_shownpc_target(true)
  end
end
function on_cmd_lookskill(cmd, opt, arg)
  local str
  if arg == nil then
    str = sys.wstring(0)
  else
    str = arg.v_string
  end
  local skillId = 0
  local strname
  if str == sys.wstring(0) then
    skillId = bo2.get_using_skill()
    strname = bo2.player.cha_name
  else
    local target = bo2.scn:get_scn_obj(bo2.player.target_handle)
    if target then
      skillId = target:GetCurSkill()
      strname = target.cha_name
    else
      ui.console_print("please choose a target!")
    end
  end
  if skillId == 0 then
    ui.console_print(strname .. ":no skill is used.")
  else
    local skillname = bo2.gv_skill_group:find(skillId).name
    ui.console_print(strname .. ":use skill->(" .. skillname .. "," .. skillId .. ")")
  end
end
function on_cmd_getflagvalue(cmd, opt, type, id)
  local t = type.v_int
  local name, value
  if t == 0 then
    value = bo2.palyer:get_flag_bit(id.v_int)
    name = "flagbit"
  elseif t == 1 then
    value = bo2.player:get_flag_int8(id.v_int)
    name = "flagint8"
  elseif t == 2 then
    value = bo2.player:get_flag_int16(id.v_int)
    name = "flagint16"
  elseif t == 3 then
    value = bo2.player:get_flag_int32(id.v_int)
    name = "flagint32"
  elseif t == 4 then
    value = bo2.player:get_flag_int64(id.v_int)
    name = "flagint64"
  elseif t == 5 then
    value = bo2.player:get_flag_objmem(id.v_int)
    name = "flagmemory"
  end
  if value == nil then
    return
  end
  ui.console_print("%s id:%d  value:%d", name, id.v_int, value)
end
function on_cmd_setfog(cmd, opt, b)
  bo2.setfog(b.v_int)
end
function on_cmd_setfar(cmd, opt, n)
  bo2.SetCamfar(n.v_int)
end
function on_cmd_storyboard_render(cmd, opt, type)
  local t = type.v_int
  if t == 0 then
    bo2.set_storyboard_render(false)
  else
    bo2.set_storyboard_render(true)
  end
end
function on_cmd_setcamtarget(cmd, opt, b)
  bo2.setCamTarget(b.v_int)
end
function on_cmd_openbattle(cmd, opt, arg1)
  ui_battle_common.battle_common_win.visible = true
end
function on_cmd_setcamanglespeed(cmd, opt, num)
  bo2.setcamanglespeed(num.v_number)
end
function on_cmd_uploadpersonals(cmd, opt, name, ptype, top, topmultiple, toptime)
  local v = sys.variant()
  v:set(packet.key.sociality_personals_type, ptype)
  v:set(packet.key.sociality_personals_istop, top)
  v:set(packet.key.sociality_personals_topmultiple, topmultiple)
  v:set(packet.key.sociality_personals_toptime, toptime)
  bo2.send_variant(packet.eCTS_Sociality_UploadPersonals, v)
end
function on_cmd_send_senior_task_request(cmd, opt, quest_list_id)
  ui_im.send_senior_task_request(quest_list_id.v_int)
end
function on_cmd_createnpcblacklist(cmd, opt, filepath)
  local abp = sys.get_abs_path(filepath.v_string)
  local f = io.open(tostring(abp), "w")
  local sz = bo2.gv_cha_list.size
  for i = 1, sz do
    local ln = bo2.gv_cha_list:get(i - 1)
    local blackNPC = ln.boss > 0 or 0 < ln.special_npc_id or 0 < ln.is_knight or 0 < ln.world_boss
    if blackNPC then
      f:write(tostring(ln.name), "\n")
    end
  end
  f:close()
end
function on_cmd_tickstat(cmd, opt, arg)
  bo2.enable_tick_stat(arg.v_int ~= 0)
end
function on_cmd_net_recv_count(cmd, opt, arg)
  bo2.net_recv_count(arg.v_int ~= 0)
end
function on_cmd_film_fps_limit(cmd, opt, arg)
  bo2.film_fps_limit(arg.v_int ~= 0)
end
function on_cmd_anime_fps_lock(cmd, opt, arg)
  bo2.anime_fps_lock(arg.v_int)
end
function on_cmd_only_anime_fps_lock(cmd, opt, arg, addfps)
  bo2.only_anime_fps_lock(arg.v_int, addfps.v_int)
end
function on_cmd_setpettyaction(cmd, opt, value)
  local t = value.v_int
  if t == 0 then
    bo2.SetPettyAction(false)
    ui.console_print("Set player's petty action false!")
  else
    bo2.SetPettyAction(true)
    ui.console_print("Set player's petty action true!")
  end
end
function on_cmd_add_still_spectator(cmd, opt, name, count)
  local function set_still(target)
    if sys.check(target) then
      target:GM_AddStillSpectator(name.v_string, count.v_int)
    end
  end
  bo2.scn:ForEachScnObj(bo2.eScnObjKind_Still, set_still)
end
function on_cmd_showselgfx(cmd, opt, show)
  bo2.ShowSelGfx(show.v_int ~= 0)
end
function on_cmd_showstatecolor(cmd, opt, show)
  bo2.EnableStateColor(show.v_int ~= 0)
end
function on_cmd_luaregstat(cmd, opt)
  sys.registry_stat()
end
function on_cmd_statres(cmd, opt, name, dir)
  local var = ui.stat_res_dir(name, dir)
  local cnt = var.size
  ui.console_print("stat res on : %s, %s", name, dir)
  for i = 0, cnt - 1 do
    local v = var:fetch_v(i)
    ui.console_print("%s : %d/%d", v:get("name").v_string, v:get("size").v_int, v:get("count").v_int)
  end
end
function on_cmd_targetinfo(cmd, opt)
  local player = bo2.player
  if player == nil then
    return
  end
  local target = bo2.scn:get_scn_obj(player.target_handle)
  if target == nil then
    ui.console_print("error : you should select a target npc.")
    return
  end
  local excel = target.excel
  local x, y = target:get_position()
  ui.console_print("### target info :")
  ui.console_print("# name = %s", target.name)
  ui.console_print("# excel id = %d", excel.id)
  ui.console_print("# position = %.1f,%.1f", x, y)
end
function on_cmd_setnpcprompt(cmd, opt, show)
  bo2.setnpcprompt(show.v_int ~= 0)
end
function on_cmd_dislock(cmd, opt, show)
  bo2.disable_fps_lock(show.v_int ~= 0)
end
function on_cmd_anime_play(cmd, opt, show)
  if sys.check(bo2.player) ~= true then
    return
  end
  bo2.player:AnimPlayFadeIn(show.v_int, false, false, 2, 0)
end
local io_mb = function(cmdname, cmd, opt, tb, id, name)
  local has_s = true
  local has_c = true
  if opt:has("s") then
    has_c = false
  elseif opt:has("c") then
    has_s = false
  end
  if has_s then
    local gmpacket = sys.variant()
    gmpacket:set(packet.key.tool_gmcommand, cmd:get("text"))
    bo2.send_variant(packet.eCTS_GM_Command, gmpacket)
  end
  if not has_c then
    return nil
  end
  local view = bo2["gv_" .. tostring(tb)]
  if view == nil then
    ui.console_print("# client %s : bad table %s", cmdname, tb)
    return nil
  end
  local excel = view:find(id.v_int)
  if excel == nil then
    ui.console_print("# client %s : bad excel id %s", cmdname, id)
    return nil
  end
  local oldval, ok = excel:get_field(name)
  if not ok then
    ui.console_print("# client %s : bad excel field name %s", cmdname, name)
    return nil
  end
  return excel, oldval
end
function on_cmd_setmb(cmd, opt, tb, id, name, value)
  local excel, oldval = io_mb("setmb", cmd, opt, tb, id, name)
  if excel == nil then
    return
  end
  excel:set_field(name, value)
  ui.console_print("# client setmb : %s[%s].%s = %s -> %s", tb, id, name, oldval, value)
end
function on_cmd_getmb(cmd, opt, tb, id, name)
  local excel, oldval = io_mb("getmb", cmd, opt, tb, id, name)
  if excel == nil then
    return
  end
  ui.console_print("# client getmb : %s[%s].%s = %s", tb, id, name, oldval)
end
function on_cmn_reloadmb_c(cmd, opt)
  bo2.mb_reload()
end
function on_cmd_worldevent_init(cmd, opt)
  bo2.world_event_init()
  ui.console_print("on_cmd_worldevent_init\205\234\179\201!")
end
function on_cmd_test_path(cmd, opt, self, target, count, name, target_name)
  ui.console_print("on_cmd_test_path begin!")
  local function find_path()
    bo2.GTEST_FindPath(self.v_int, target.v_int, count.v_int, name.v_string, target_name.v_string)
  end
  sys.cpu_pcall("on_cmd_test_path", find_path)
  ui.console_print("on_cmd_test_path end!")
end
function on_cmd_elo(cmd, opt, type)
  local c_type = type.v_int
  local str_message
  if c_type == 0 then
    local score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_ArenaElo_1V1_Score)
    local win = bo2.player:get_flag_int16(163)
    local lost = bo2.player:get_flag_int16(164)
    local enclises_win = bo2.player:get_flag_int16(165)
    str_message = sys.format("score = %d,win = %d,lost = %d,enclises_win = %d", score, win, lost, enclises_win)
  end
  if str_message ~= nil then
    ui.console_print(str_message)
  end
end
