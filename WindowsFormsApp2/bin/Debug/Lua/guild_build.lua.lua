local select_build
local mb_table = {}
local select_id = 0
function on_init(ctrl)
  select_build = nil
  mb_table[1] = bo2.gv_guild_hall
  create_build_list()
  ui.insert_on_guild_build_refresh("ui_guild_mod.ui_build.on_guild_build_refresh", "ui_guild_build")
end
function create_build_list()
  g_build_list:item_clear()
  select_build = nil
  local item_file = "$frame/guild/guild_build.xml"
  local item_style = "guild_build_item"
  local cult_type = ui.guild_cult_type()
  if cult_type == 0 then
    for i = 1, 8 do
      local build_excel = bo2.gv_guild_build:find(i)
      if build_excel ~= nil then
        local item = g_build_list:item_append()
        item:load_style(item_file, item_style)
        item.svar.type = build_excel.type
        local name = item:search("name")
        name.text = build_excel.name
        local level = item:search("level")
        local level_text = item:search("level_text")
        level.text = 0
        level_text.text = ui.get_text("guild|notbuild")
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
        local item = g_build_list:item_append()
        item:load_style(item_file, item_style)
        item.svar.type = build_excel.type
        local name = item:search("name")
        name.text = build_excel.name
        local level = item:search("level")
        local level_text = item:search("level_text")
        level.text = 0
        level_text.text = ui.get_text("guild|notbuild")
      end
    end
  end
end
function on_guild_build_refresh()
  if bo2.is_in_guild() == sys.wstring(0) then
    w_guild_build.visible = false
  end
  create_build_list()
  g_desc_box.mtf = nil
  g_build_level.text = nil
  local cur_money = ui.guild_get_money()
  g_guild_money.color = ui.make_color("ffffff")
  local ctrl = g_follow:search("gx_guild_money")
  local label1 = ctrl:search("l_lable_left1")
  local label2 = ctrl:search("l_lable_left2")
  label1.visible = true
  label2.visible = false
  if cur_money < 0 then
    cur_money = -cur_money
    g_guild_money.color = ui.make_color("FF0000")
    label1.visible = false
    label2.visible = true
  end
  g_guild_money.money = cur_money
  g_guild_develop.text = ui.guild_get_develop()
  local ui_guild_build
  hall = ui.guild_get_build(1)
  for n = 0, g_build_list.item_count - 1 do
    local item = g_build_list:item_get(n)
    local ui_guild_build = ui.guild_get_build(item.svar.type)
    local level = item:search("level")
    local level_text = item:search("level_text")
    if ui_guild_build == nil then
      level.text = 0
      level_text.text = ui.get_text("guild|notbuild")
    else
      level.text = ui_guild_build.level
      if ui_guild_build.state == bo2.BuildState_None then
        local v = sys.variant()
        v:set("level", ui_guild_build.level)
        level_text.text = sys.mtf_merge(v, ui.get_text("guild|guild_item_level"))
      elseif ui_guild_build.state == bo2.BuildState_Collect then
        level_text.text = sys.format(ui.get_text("guild|guild_item_level_res"), ui_guild_build.level, ui_guild_build.level + 1)
      elseif ui_guild_build.state == bo2.BuildState_Build then
        level_text.text = sys.format(ui.get_text("guild|guild_item_level_build"), ui_guild_build.level, ui_guild_build.level + 1)
      end
    end
  end
  local item = g_build_list:item_get(select_id)
  item.selected = true
  ui_guild_mod.ui_guild_info.update_builds()
end
function on_guild_build_visible(w, vis)
  if bo2.is_in_guild() == sys.wstring(0) then
    ui_chat.show_ui_text_id(70251)
    w_guild_build.visible = false
  end
  if vis == true then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    on_guild_build_refresh()
    g_build_list:item_get(select_id).selected = true
    select_build = g_build_list:item_get(select_id)
    gx_guild_build_list.slider_y.scroll = 0
  else
    ui_widget.esc_stk_pop(w)
    select_id = 0
    if g_build_list.item_sel ~= nil then
      g_build_list.item_sel:search("fig_highlight_sel").visible = false
      g_build_list.item_sel:search("fig_highlight").visible = false
      g_build_list.item_sel.selected = false
    end
    select_build = nil
    g_desc_box.mtf = nil
    g_build_level.text = nil
  end
end
function showbuild_desc(item)
  local build_level = item:search("level").text
  local build_type = item.svar.type
  local ui_guild_build = ui.guild_get_build(build_type)
  local desc_text = ""
  local levelup_enable = true
  local arg = sys.variant()
  local level_text = item:search("level_text")
  arg:set("build_name", bo2.gv_guild_build:find(build_type).name)
  arg:set("build_level", level_text.text)
  g_build_level.text = sys.mtf_merge(arg, ui.get_text("guild|view_build_level"))
  local build_table = bo2.gv_build_level
  local line_id = build_type * 100 + build_level.v_int + 1
  if build_table == nil or build_table:find(build_type * 100 + build_level.v_int + 1) == nil then
    local max_desc = bo2.gv_guild_build:find(build_type).maxlevel_desc
    desc_text = desc_text .. ui.get_text("guild|desc_max")
    desc_text = desc_text .. "\n"
    desc_text = desc_text .. max_desc
    g_desc_box.mtf = desc_text
    g_desc_box.parent:tune_y("desc")
    g_build_levelup_btn.enable = false
    return
  end
  arg:clear()
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
    local keepmoney_req = bo2.gv_guild_hall:find(build_level.v_int + 1).keepmoney
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
      desc_text = desc_text .. "\n"
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
        desc_text = desc_text .. "\n"
      end
    end
  end
  desc_text = desc_text .. "\n"
  desc_text = desc_text .. bo2.gv_guild_build:find(build_type).desc
  g_desc_box.mtf = desc_text
  g_desc_box.parent:tune_y("desc")
  if ui_guild_build ~= nil and ui_guild_build.state ~= bo2.BuildState_None then
    g_build_levelup_btn.enable = false
  else
    g_build_levelup_btn.enable = levelup_enable
  end
  gx_guild_build_list.slider_y.scroll = 0
end
function on_build_item_select(item, sel)
  if not sel then
    return
  end
  if select_build ~= nil then
    select_build:search("fig_highlight").visible = false
    select_build:search("fig_highlight_sel").visible = false
  end
  select_build = item
  for i = 0, g_build_list.item_count - 1 do
    if item == g_build_list:item_get(i) then
      select_id = i
    end
  end
  select_build:search("fig_highlight_sel").visible = true
  showbuild_desc(select_build)
end
function on_build_levelup(ctrl)
  if select_build == nil then
    local msg = {
      btn_confirm = true,
      btn_cancel = false,
      modal = true
    }
    msg.text = ui.get_text("guild|select_build")
    ui_tool.show_msg(msg)
  else
    ui_widget.ui_msg_box.show_common({
      callback = on_build_levelup_msg,
      text = ui.get_text("guild|build_levelup_msg")
    })
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
    local type = select_build.svar.type
    v:set(packet.key.guild_build, type)
    bo2.send_variant(packet.eCTS_Guild_LevelUp, v)
  end
end
function depot_updatamoney(cmd, data)
  local cur_money = ui.guild_get_money()
  local ctrl = g_follow:search("gx_guild_money")
  local label1 = ctrl:search("l_lable_left1")
  local label2 = ctrl:search("l_lable_left2")
  label1.visible = true
  label2.visible = false
  g_guild_money.color = ui.make_color("ffffff")
  if cur_money < 0 then
    cur_money = -cur_money
    g_guild_money.color = ui.make_color("FF0000")
    label1.visible = false
    label2.visible = true
  end
  g_guild_money.money = cur_money
  g_guild_develop.text = ui.guild_get_develop()
  if select_build ~= nil then
    showbuild_desc(select_build)
  end
end
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_guild_mod.ui_build:on_signal"
reg(packet.eSTC_Guild_SelfData, depot_updatamoney, sig)
