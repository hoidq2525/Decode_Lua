local select_build
local mb_table = {}
function on_init(ctrl)
  select_build = nil
  g_build_list:item_clear()
  mb_table[1] = bo2.gv_guild_hall
  ui.insert_on_guild_build_refresh("ui_org.ui_guild_view.on_guild_build_refresh", "on_guild_build_refresh")
end
function on_guild_build_refresh()
  if bo2.is_in_guild() == sys.wstring(0) then
    ui_org.ui_guild_view.w_guild_view.visible = false
  end
  local select_type
  if g_build_list.item_sel ~= nil then
    select_type = g_build_list.item_sel:search("type").text
  end
  g_build_list:item_clear()
  select_build = nil
  g_desc_box.mtf = nil
  local arg = sys.variant()
  arg:clear()
  arg:set("cur_num", ui.guild_member_size())
  arg:set("max_num", ui.guild_max_member())
  g_member_num.text = sys.mtf_merge(arg, ui.get_text("org|data_member_num"))
  arg:clear()
  arg:set("guild_level", ui.guild_get_level())
  g_guild_level.text = sys.mtf_merge(arg, ui.get_text("org|guild_item_level"))
  arg:clear()
  g_guild_money.money = ui.guild_get_money()
  g_guild_develop.text = tostring(ui.guild_get_develop())
  g_guild_energy.text = ui.guild_get_energy()
  g_guild_drawmoney.money = ui.guild_get_alldrawmoney()
  g_guild_keepmoney.money = ui.guild_get_keepmoney()
  g_guild_drawcon.text = tostring(ui.guild_get_drawcontri())
  local energy_h = bo2.gv_define_org:find(25).value
  local energy_l = bo2.gv_define_org:find(26).value
  local energy = ui.guild_get_energy()
  local renqi = ""
  if energy * 3600 > energy_h.v_int then
    renqi = ui.get_text("org|energy_h")
  elseif energy * 3600 > energy_l.v_int then
    renqi = ui.get_text("org|energy_m")
  else
    renqi = ui.get_text("org|energy_l")
  end
  arg:clear()
  arg:set("renqi", renqi)
  g_guild_renqi.text = sys.mtf_merge(arg, ui.get_text("org|data_renqi"))
  local item_file = "$frame/org/guild_view.xml"
  local item_style = "guild_build_item"
  for i = 1, 8 do
    if bo2.gv_guild_build:find(i) ~= nil then
      local item = g_build_list:item_append()
      item:load_style(item_file, item_style)
      local ui_guild_build = ui.guild_get_build(i)
      local type = item:search("type")
      type.text = i
      local name = item:search("name")
      name.text = bo2.gv_guild_build:find(i).name
      local level = item:search("level")
      local level_text = item:search("level_text")
      if ui_guild_build == nil then
        level.text = 0
        level_text.text = ui.get_text("org|notbuild")
      else
        level.text = ui_guild_build.level
        if ui_guild_build.state == bo2.BuildState_None then
          local v = sys.variant()
          v:set("guild_level", ui_guild_build.level)
          level_text.text = sys.mtf_merge(v, ui.get_text("org|guild_item_level"))
        elseif ui_guild_build.state == bo2.BuildState_Collect then
          level_text.text = sys.format(ui.get_text("org|guild_item_level_res"), ui_guild_build.level, ui_guild_build.level + 1)
        elseif ui_guild_build.state == bo2.BuildState_Build then
          level_text.text = sys.format(ui.get_text("org|guild_item_level_build"), ui_guild_build.level, ui_guild_build.level + 1)
        end
      end
    end
  end
  if select_type ~= nil then
    for n = 0, g_build_list.item_count - 1 do
      local item = g_build_list:item_get(n)
      local type = item:search("type")
      if type.text == select_type then
        item.selected = true
        select_build = item
      end
    end
  end
end
function on_guild_view_visible(w, vis)
  if vis == true then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    on_guild_build_refresh()
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_Guild_BuildReq, v)
  else
    ui_widget.esc_stk_pop(w)
  end
end
function on_build_item_select(ctrl)
  ui_org.ui_guild.update_highlight(ctrl)
  if select_build ~= nil then
    select_build:search("fig_highlight_sel").visible = false
  end
  select_build = ctrl
  select_build:search("fig_highlight_sel").visible = true
  g_desc_box.mtf = nil
  local build_level = select_build:search("level").text
  local type = select_build:search("type")
  local ui_guild_build = ui.guild_get_build(type.text.v_int)
  local desc_text = bo2.gv_guild_build:find(type.text.v_int).desc
  desc_text = desc_text .. "\n"
  local build_table = bo2.gv_build_level
  local line_id = type.text.v_int * 100 + build_level.v_int + 1
  if build_table == nil or build_table:find(line_id) == nil then
    desc_text = desc_text .. ui.get_text("org|desc_max")
    g_desc_box.mtf = desc_text
    g_desc_box.parent:tune_y("desc")
    return
  end
  local arg = sys.variant()
  if ui_guild_build == nil then
    arg:set("build_state", ui.get_text("org|buildstate_nil"))
  elseif ui_guild_build.state == bo2.BuildState_None then
    arg:set("build_state", ui.get_text("org|buildstate_none"))
  elseif ui_guild_build.state == bo2.BuildState_Collect then
    arg:set("build_state", ui.get_text("org|buildstate_collect"))
  elseif ui_guild_build.state == bo2.BuildState_Build then
    arg:set("build_state", ui.get_text("org|buildstate_build"))
  end
  req_text = sys.mtf_merge(arg, ui.get_text("org|desc_buildstate"))
  desc_text = desc_text .. req_text
  desc_text = desc_text .. "\n"
  arg:clear()
  if type.text.v_int == 1 then
    local keepmoney_req = bo2.gv_guild_hall:find(build_level.v_int + 1).keepmoney
    arg:set("guild_keepmoney", sys.format("%d", keepmoney_req))
    req_text = sys.mtf_merge(arg, ui.get_text("org|desc_keepmoney"))
    if keepmoney_req > ui.guild_get_money() then
      desc_text = desc_text .. "<c+:FF0000>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
    else
      desc_text = desc_text .. "<c+:00FF00>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
    end
  else
    local need_level = bo2.gv_build_level:find(line_id).guild_level
    arg:set("build_name", bo2.gv_guild_build:find(1).name)
    arg:set("build_level", need_level)
    local req_text = sys.mtf_merge(arg, ui.get_text("org|desc_req"))
    local ui_guild_build
    result = ui.guild_get_build(1)
    if result == nil or need_level > result.level then
      desc_text = desc_text .. "<c+:FF0000>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
    else
      desc_text = desc_text .. "<c+:00FF00>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
    end
  end
  desc_text = desc_text .. "\n"
  if ui_guild_build == nil or ui_guild_build.state ~= bo2.BuildState_Build then
    arg:clear()
    local money_req = build_table:find(line_id).money
    arg:set("guild_money", money_req)
    req_text = sys.mtf_merge(arg, ui.get_text("org|desc_money"))
    if money_req > ui.guild_get_money() then
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
    req_text = sys.mtf_merge(arg, ui.get_text("org|desc_develop"))
    if develop_req > ui.guild_get_develop() then
      desc_text = desc_text .. "<c+:FF0000>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
    else
      desc_text = desc_text .. "<c+:00FF00>"
      desc_text = desc_text .. req_text
      desc_text = desc_text .. "<c->"
    end
    desc_text = desc_text .. "\n"
    desc_text = desc_text .. "\n"
    local resources = build_table:find(line_id).resources
    if resources.size ~= 0 and resources.size ~= 1 then
      desc_text = desc_text .. ui.get_text("org|desc_res")
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
        req_text = sys.mtf_merge(arg, ui.get_text("org|desc_res_item"))
        if count > hasres_count then
          desc_text = desc_text .. "<c+:FF0000>"
          desc_text = desc_text .. req_text
          desc_text = desc_text .. "<c->"
        else
          desc_text = desc_text .. "<c+:00FF00>"
          desc_text = desc_text .. req_text
          desc_text = desc_text .. "<c->"
        end
      end
    end
  end
  desc_text = desc_text .. "\n"
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
  req_text = sys.mtf_merge(arg, ui.get_text("org|desc_buildprocess"))
  desc_text = desc_text .. req_text
  g_desc_box.mtf = desc_text
  g_desc_box.parent:tune_y("desc")
  gx_guild_build_list.slider_y.scroll = 0
end
function on_build_levelup(ctrl)
  if select_build == nil then
    local msg = {
      btn_confirm = true,
      btn_cancel = false,
      modal = true
    }
    msg.text = ui.get_text("org|select_build")
    ui_tool.show_msg(msg)
  else
    local msg = {
      callback = on_build_levelup_msg,
      btn_confirm = true,
      btn_cancel = true,
      modal = true
    }
    msg.text = ui.get_text("org|build_levelup_msg")
    ui_tool.show_msg(msg)
  end
end
function on_build_close(ctrl)
  w_guild_build.visible = false
end
function on_build_levelup_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local v = sys.variant()
    local type = select_build:search("type")
    v:set(packet.key.guild_build, type.text)
    bo2.send_variant(packet.eCTS_Guild_LevelUp, v)
  end
end
