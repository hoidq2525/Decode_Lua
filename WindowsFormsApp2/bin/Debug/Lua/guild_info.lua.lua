local ui_chat_list = ui_widget.ui_chat_list
local g_build_list = sys.variant()
local g_cur_page = 1
local g_page_count = 8
local g_max_page = 0
local select_build
function update_info()
  local arg = sys.variant()
  g_leader_name.text = ui.guild_leader_name()
  arg:clear()
  arg:set("cur_num", ui.guild_member_size())
  arg:set("max_num", ui.guild_max_member())
  g_member_num.text = sys.mtf_merge(arg, ui.get_text("guild|data_member_num"))
  local level = ui.guild_get_level()
  arg:clear()
  arg:set("level", level)
  g_guild_level.text = sys.mtf_merge(arg, ui.get_text("guild|guild_item_level"))
  local cur_money = ui.guild_get_money()
  g_guild_money.color = ui.make_color("ffffff")
  local ctrl = g_guild_info_list:search("i_guild_money")
  local label = ctrl:search("l_lable_name")
  label.text = ui.get_text("guild|tag_money")
  label.color = ui.make_color("ffa2a2a2")
  if cur_money < 0 then
    cur_money = -cur_money
    g_guild_money.color = ui.make_color("FF0000")
    local ctrl = g_guild_info_list:search("i_guild_money")
    local label = ctrl:search("l_lable_name")
    label.text = ui.get_text("guild|debt")
    label.color = ui.make_color("FF0000")
  end
  local mod_moeny = math.fmod(cur_money, 10000)
  g_guild_money.tip.visible = false
  if mod_moeny ~= 0 then
    g_guild_money.tip.visible = true
    cur_money = cur_money - mod_moeny
  end
  g_guild_money.money = cur_money
  g_guild_develop.text = ui.guild_get_develop()
  g_guild_energy.text = ui.guild_get_energy()
  g_guild_keepmoney.tip.visible = true
  g_guild_keepmoney.money = ui.guild_get_keepmoney()
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_Guild_GetBanner_Keeymoney, v)
  local hall_line = bo2.gv_guild_hall:find(level)
  if hall_line ~= nil then
    local cur_weekmoney = ui.guild_get_week_money()
    local mod_weekmoney = math.fmod(cur_weekmoney, 10000)
    g_guild_weekmoney.tip.visible = false
    if mod_weekmoney ~= 0 then
      g_guild_weekmoney.tip.visible = true
      cur_weekmoney = cur_weekmoney - mod_weekmoney
    end
    g_guild_weekmoney.money = cur_weekmoney
    g_guild_weekmoneymax.money = hall_line.weekmny
    g_guild_weekdevelop.text = ui.guild_get_week_develop()
    g_guild_weekdevelopmax.text = hall_line.weekdev
  end
  local energy_h = bo2.gv_define_org:find(25).value
  local energy_l = bo2.gv_define_org:find(26).value
  local energy = ui.guild_get_energy()
  local renqi = ""
  if energy * 3600 > energy_h.v_int then
    renqi = ui.get_text("guild|energy_h")
  elseif energy * 3600 > energy_l.v_int then
    renqi = ui.get_text("guild|energy_m")
  else
    renqi = ui.get_text("guild|energy_l")
  end
  arg:clear()
  arg:set("renqi", renqi)
  g_guild_renqi.text = sys.mtf_merge(arg, ui.get_text("guild|data_renqi"))
end
function on_make_tip(tip)
  local cur_money = ui.guild_get_money()
  if cur_money < 0 then
    cur_money = -cur_money
    tip.popup = "x2_auto"
    tip.text = sys.format(L("<c+:#red>%s<m:%d><c->"), "-", cur_money)
    ui_widget.tip_make_view(tip.view, tip.text)
  else
    tip.popup = "x2_auto"
    tip.text = sys.format(L("<m:%d>"), cur_money)
    ui_widget.tip_make_view(tip.view, tip.text)
  end
end
function on_make_tip1(tip)
  tip.popup = "x2_auto"
  tip.text = ui.get_text("guild|keep_and_banner_money")
  ui_widget.tip_make_view(tip.view, tip.text)
end
function on_make_tip2(tip)
  local cur_money = ui.guild_get_week_money()
  if math.fmod(cur_money, 10000) ~= 0 then
    tip.popup = "x2_auto"
    tip.text = sys.format(L("<m:%d>"), cur_money)
    ui_widget.tip_make_view(tip.view, tip.text)
  end
end
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
  bo2.send_variant(packet.eCTS_Guild_SetInfo, v)
end
function on_info_confirm_info(ctrl)
  g_info_box.focus_able = false
  g_info_box.focus = false
  g_change_btn.visible = true
  g_confirm_btn.visible = false
end
function update_notice()
  g_info_box.focus_able = false
  g_info_box.focus = false
  g_info_box.mouse_able = false
  g_change_btn.visible = true
  g_confirm_btn.visible = false
  local self = ui.guild_get_self()
  if self == nil then
    return
  end
  local line = bo2.gv_guild_auth:find(self.guild_pos)
  if line.info ~= 1 then
    g_change_btn.visible = false
  end
  local dst = ui.filter_text(ui.guild_get_info())
  g_info_box.text = dst
  g_info_box.size = g_info_box.extent
end
function update_news()
  local slider_y = g_news_list:search("chat_list").slider_y.scroll
  ui_chat_list.clear(g_news_list)
  for i = 0, ui.guild_news_size() - 1 do
    ui_chat_list.insert(g_news_list, {
      text = ui.guild_get_news(i)
    }, 0, "$widget/chat_list.xml", "cmn_chat_list_item_not_force_full_line")
  end
  g_news_list:search("chat_list").slider_y.scroll = slider_y
end
function update_builds()
  local build_size = g_build_list.size
  local star_num = (g_cur_page - 1) * g_page_count + 1
  if build_size < star_num then
    g_cur_page = 1
    star_num = 1
  end
  for i = 1, 8 do
    local item = g_build_card_list:search("build_card_" .. i)
    local idx = star_num + i - 2
    if idx > build_size - 1 then
      item.visible = false
    else
      local build_type = g_build_list:get(idx).v_int
      local ui_guild_build = ui.guild_get_build(build_type)
      local line = bo2.gv_guild_build:find(build_type)
      local build_text = item:search("item_text")
      local level_text = item:search("level_text")
      local build_icon = item:search("item_picture")
      if ui_guild_build == nil then
        build_icon.image = sys.format("$icon/portrait/%s.png?gray|3,3,58,58", line.icon)
        level_text.text = ui.get_text("guild|notbuild")
        level_text.color = ui.make_color("646464")
        build_text.text = line.name
        build_text.color = ui.make_color("646464")
        item.svar.state = ""
      else
        level_text.text = sys.format(ui.get_text("guild|what_level"), ui_guild_build.level)
        level_text.color = ui.make_color("16bfe9")
        build_icon.image = sys.format("$icon/portrait/%s.png|3,3,58,58", line.icon)
        if ui_guild_build.state == bo2.BuildState_None then
          build_text.text = line.name
          build_text.color = ui.make_color("ffffff")
          item.svar.state = ""
        elseif ui_guild_build.state == bo2.BuildState_Collect then
          build_text.text = ui.get_text("guild|build_state_collect")
          build_text.color = ui.make_color("82c016")
          item.svar.state = build_text.text
        elseif ui_guild_build.state == bo2.BuildState_Build then
          build_text.text = ui.get_text("guild|build_state_build")
          build_text.color = ui.make_color("16bfe9")
          item.svar.state = build_text.text
        end
      end
      item.visible = true
      item.svar.type = build_type
      item.svar.name = line.name
      item.svar.level = level_text.text
    end
  end
  if g_cur_page == 1 then
    w_win:search("btn_prev").enable = false
  else
    w_win:search("btn_prev").enable = true
  end
  if g_cur_page == g_max_page then
    w_win:search("btn_next").enable = false
  else
    w_win:search("btn_next").enable = true
  end
  if select_build ~= nil then
    on_build_info(select_build, ui.mouse_lbutton_down)
  end
end
function on_stepping_left(btn)
  g_cur_page = g_cur_page - 1
  update_builds()
end
function on_stepping_right(btn)
  g_cur_page = g_cur_page + 1
  update_builds()
end
function on_build_info(ctrl, msg)
  if msg ~= ui.mouse_lbutton_down then
    return
  end
  local build_type = ctrl.svar.type
  if select_build ~= nil then
    select_build:search("fig_highlight_sel").visible = false
  end
  select_build = ctrl
  select_build:search("fig_highlight_sel").visible = true
  g_desc_box.mtf = nil
  local desc_text = ""
  local ui_guild_build = ui.guild_get_build(build_type)
  local build_level = 0
  if ui_guild_build ~= nil then
    build_level = ui_guild_build.level
  end
  local build_table = bo2.gv_build_level
  local line_id = build_type * 100 + build_level + 1
  if build_level ~= 0 and (build_table == nil or build_table:find(line_id) == nil) then
    local max_desc = bo2.gv_guild_build:find(build_type).maxlevel_desc
    desc_text = desc_text .. ui.get_text("guild|desc_max")
    desc_text = desc_text .. "\n"
    desc_text = desc_text .. max_desc
    g_desc_box.mtf = desc_text
    g_desc_box.parent:tune_y("desc")
    return
  end
  local arg = sys.variant()
  if ui_guild_build == nil then
    arg:set("build_state", ui.get_text("guild|buildstate_nil"))
  elseif ui_guild_build.state == bo2.BuildState_None then
    arg:set("build_state", ui.get_text("guild|buildstate_none"))
  elseif ui_guild_build.state == bo2.BuildState_Collect then
    arg:set("build_state", ui.get_text("guild|buildstate_collect"))
  elseif ui_guild_build.state == bo2.BuildState_Build then
    arg:set("build_state", ui.get_text("guild|buildstate_build"))
  end
  req_text = sys.mtf_merge(arg, ui.get_text("guild|desc_buildstate"))
  desc_text = desc_text .. req_text
  arg:clear()
  if build_type == 1 then
    local keepmoney_req = bo2.gv_guild_hall:find(build_level + 1).keepmoney
    arg:set("guild_keepmoney", sys.format("%d", keepmoney_req))
    req_text = sys.mtf_merge(arg, ui.get_text("guild|desc_keepmoney"))
    if keepmoney_req > ui.guild_get_money() then
      desc_text = desc_text .. "<c+:FF0000>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
    else
      desc_text = desc_text .. "<c+:00FF00>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
    end
    desc_text = desc_text .. "\n"
  end
  local build_level_line = bo2.gv_build_level:find(line_id)
  arg:clear()
  local need_guild_level = build_level_line.guild_level
  if need_guild_level ~= 0 then
    arg:set("guild_level", need_guild_level)
    local req_text = sys.mtf_merge(arg, ui.get_text("guild|desc_req2"))
    local cur_guild_level = ui.guild_get_level()
    if cur_guild_level == 0 or need_guild_level > cur_guild_level then
      desc_text = desc_text .. "<c+:FF0000>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
      levelup_enable = false
    else
      desc_text = desc_text .. "<c+:00FF00>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
    end
    desc_text = desc_text .. "\n"
  end
  if build_level_line.build_level.size ~= 0 then
    local need_build_level = build_level_line.build_level
    for i = 0, need_build_level.size - 1, 2 do
      arg:clear()
      arg:set("build_name", bo2.gv_guild_build:find(need_build_level[i]).name)
      arg:set("build_level", need_build_level[i + 1])
      local req_text = sys.mtf_merge(arg, ui.get_text("guild|desc_req"))
      local result = ui.guild_get_build(need_build_level[i])
      if result == nil or result.level < need_build_level[i + 1] then
        desc_text = desc_text .. "<c+:FF0000>"
        desc_text = desc_text .. req_text
        desc_text = desc_text .. "<c->"
        levelup_enable = false
      else
        desc_text = desc_text .. "<c+:00FF00>"
        desc_text = desc_text .. req_text
        desc_text = desc_text .. "<c->"
      end
      desc_text = desc_text .. "\n"
    end
  end
  arg:clear()
  local need_process = build_table:find(line_id).time
  if ui_guild_build ~= nil and ui_guild_build.state == bo2.BuildState_Build then
    need_process = ui_guild_build.process
  end
  local day = math.modf(need_process / 86400)
  need_process = need_process % 86400
  local hour = math.modf(need_process / 3600)
  need_process = need_process % 3600
  local minute = math.modf(need_process / 60)
  arg:set("day", sys.format("%d", day))
  arg:set("hour", sys.format("%d", hour))
  arg:set("minute", sys.format("%d", minute))
  req_text = sys.mtf_merge(arg, ui.get_text("guild|desc_buildprocess"))
  desc_text = desc_text .. req_text
  if ui_guild_build == nil or ui_guild_build.state ~= bo2.BuildState_Build then
    arg:clear()
    local money_req = build_table:find(line_id).money
    arg:set("guild_money", money_req)
    req_text = sys.mtf_merge(arg, ui.get_text("guild|desc_money"))
    local money_over = true
    local develop_over = true
    if ui_guild_build ~= nil then
      money_over = ui_guild_build:needres_count(bo2.BuildSpecialRes_Money) ~= 0
      develop_over = ui_guild_build:needres_count(bo2.BuildSpecialRes_Develop) ~= 0
    end
    if money_over then
      desc_text = desc_text .. "<c+:FF0000>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
    else
      desc_text = desc_text .. "<c+:00FF00>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
    end
    desc_text = desc_text .. "\n"
    arg:clear()
    local develop_req = build_table:find(line_id).develop
    arg:set("guild_develop", sys.format("%d", develop_req))
    req_text = sys.mtf_merge(arg, ui.get_text("guild|desc_develop"))
    if develop_over then
      desc_text = desc_text .. "<c+:FF0000>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
    else
      desc_text = desc_text .. "<c+:00FF00>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
    end
    desc_text = desc_text .. "\n"
    local resources = build_table:find(line_id).resources
    if resources.size ~= 0 and resources.size ~= 1 then
      desc_text = desc_text .. ui.get_text("guild|desc_res")
      for i = 0, resources.size - 1, 2 do
        local res_id = resources[i]
        local count = resources[i + 1]
        local hasres_count = 0
        if ui_guild_build ~= nil and ui_guild_build:needres_count(res_id) ~= -1 then
          hasres_count = count - ui_guild_build:needres_count(res_id)
        end
        arg:clear()
        arg:set("item_id", sys.format("%d", res_id))
        arg:set("count", sys.format("%d", count))
        arg:set("has_count", sys.format("%d", hasres_count))
        req_text = sys.mtf_merge(arg, ui.get_text("guild|desc_res_item"))
        if count > hasres_count then
          desc_text = desc_text .. "<c+:FF0000>"
          desc_text = desc_text .. req_text
          desc_text = desc_text .. "<c->"
        else
          desc_text = desc_text .. "<c+:00FF00>"
          desc_text = desc_text .. req_text
          desc_text = desc_text .. "<c->"
        end
        desc_text = desc_text .. "<c+:00FF00>; <c->"
      end
    end
  end
  desc_text = desc_text .. "\n"
  desc_text = desc_text .. "\n"
  g_desc_box.mtf = desc_text
  g_desc_box.parent:tune_y("desc")
  gx_guild_build_list.slider_y.scroll = 0
end
function on_build_showtip(tip)
  local panel = tip.owner
  if panel == nil then
    return
  end
  local build_type = panel.svar.type
  local ui_guild_build = ui.guild_get_build(build_type)
  local build_level = 0
  local text
  local stk = sys.mtf_stack()
  ui_tool.ctip_push_text(stk, panel.svar.name, "FFFFFF", ui_tool.cs_tip_a_add_l)
  if panel.svar.state ~= "" then
    ui_tool.ctip_push_text(stk, panel.svar.state, "FFFFFF", ui_tool.cs_tip_a_add_r)
  else
    ui_tool.ctip_push_text(stk, panel.svar.level, "FFFFFF", ui_tool.cs_tip_a_add_r)
  end
  ui_tool.ctip_push_sep(stk)
  if ui_guild_build ~= nil then
    build_level = ui_guild_build.level
  end
  local max_tag = false
  local build_table = bo2.gv_build_level
  local line_id = build_type * 100 + build_level + 1
  if build_level ~= 0 and (build_table == nil or build_table:find(line_id) == nil) then
    ui_tool.ctip_push_text(stk, ui.get_text("guild|build_max"), "CAFF70")
    ui_tool.ctip_push_newline(stk)
    max_tag = true
  end
  ui_tool.ctip_push_text(stk, ui.get_text("guild|build_function"), "CAFF70")
  ui_tool.ctip_push_newline(stk)
  ui_tool.ctip_push_text(stk, bo2.gv_guild_build:find(build_type).func)
  if max_tag == false then
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("guild|build_lvup"), "CAFF70")
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, bo2.gv_guild_build:find(build_type).lvup)
  end
  ui_tool.ctip_show(tip.owner, stk)
end
function update(cmd, init)
  if w_win.visible == false and init == false then
    return
  end
  update_info()
  update_notice()
  update_news()
  update_builds()
end
function on_visible(w, v)
  if v == true then
    update()
  end
end
function on_build_init()
  g_cur_page = 1
  g_page_count = 8
  g_build_list:clear()
  select_build = nil
  local cult_type = ui.guild_cult_type()
  if cult_type == 0 then
    for i = 1, 8 do
      local n = bo2.gv_guild_build:find(i)
      if n ~= nil then
        g_build_list:push_back(n.type)
      end
    end
  else
    local n = bo2.gv_guild_cult:find(cult_type)
    if n == nil then
      return
    end
    for i = 0, n.builds.size - 1 do
      local build_id = n.builds[i]
      local build_excel = bo2.gv_guild_build:find(build_id)
      if build_excel ~= nil then
        g_build_list:push_back(build_excel.type)
      end
    end
  end
  g_max_page = math.ceil(g_build_list.size / g_page_count)
end
function on_init()
  on_build_init()
end
function update_selfinfo(cmd, data)
  update_info()
end
function handGuildBannerKeepmoney(cmd, data)
  local guild_keepmoney = data:get(packet.key.guild_banner_keepmoney).v_int
  g_guild_keepmoney.money = guild_keepmoney + ui.guild_get_keepmoney()
end
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_guild_mod.ui_guild_info:on_signal"
reg(packet.eSTC_Guild_SelfData, update_selfinfo, sig)
ui_packet.game_recv_signal_insert(packet.eSTC_UI_Guild_Banner_Keepmoney, handGuildBannerKeepmoney, ui_guild_mod.ui_guild_info.handGuildBannerKeepmoney)
