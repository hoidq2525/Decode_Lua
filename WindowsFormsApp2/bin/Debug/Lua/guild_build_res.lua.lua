local reg = ui_packet.game_recv_signal_insert
local sig = "ui_guild_mod.ui_build_res.packet_handler"
local g_up_res_num = 0
local g_up_res_max = 0
local g_build_type = 0
local g_iscomplete = true
function add_item(build, excel_id, max_count)
  local item = g_res_list:item_append()
  item:load_style("$frame/guild/guild_build_res.xml", "resitem")
  local res_name = ""
  if excel_id == bo2.BuildSpecialRes_Develop then
    res_name = ui.get_text("guild|res_name_develop")
  elseif excel_id == bo2.BuildSpecialRes_Money then
    res_name = ui.get_text("guild|res_name_money")
  else
    res_name = bo2.gv_item_list:find(excel_id).name
  end
  item:search("res_name").mtf = res_name
  local arg = sys.variant()
  local needres_count = build:needres_count(excel_id)
  local cur_num = max_count - needres_count
  if cur_num < 0 then
    cur_num = 0
  end
  if needres_count <= 0 then
    item:search("btn_item").visible = false
    item:search("btn_money").visible = false
    item:search("btn_develop").visible = false
  end
  arg:set("cur_num", cur_num)
  arg:set("max_num", max_count)
  local res_count = ""
  if excel_id == bo2.BuildSpecialRes_Money then
    res_count = sys.mtf_merge(arg, ui.get_text("guild|res_count_mtf1"))
  else
    res_count = sys.mtf_merge(arg, ui.get_text("guild|res_count_mtf"))
  end
  item:search("res_count").mtf = res_count
  item.svar.type = excel_id
  local btn_item = item:search("btn_item")
  local btn_money = item:search("btn_money")
  local btn_develop = item:search("btn_develop")
  if excel_id < bo2.BuildSpecialRes_Max then
    btn_item.enable = false
    if excel_id == bo2.BuildSpecialRes_Money then
      btn_money.enable = true
      btn_develop.enable = false
    elseif excel_id == bo2.BuildSpecialRes_Develop then
      btn_money.enable = false
      btn_develop.enable = true
    end
  else
    btn_item.enable = true
    btn_money.enable = true
    btn_develop.enable = true
  end
  return max_count <= cur_num
end
function set_build_info(data)
  local type = data:get(packet.key.guild_build).v_int
  local ui_guild_build = ui.guild_get_build(type)
  if ui_guild_build == nil then
    return
  end
  local level = ui_guild_build.level
  local line = bo2.gv_build_level:find(type * 100 + level + 1)
  if line == nil then
    return
  end
  g_res_list:item_clear()
  g_build_type = type
  g_iscomplete = true
  local item_over = false
  local arg = sys.variant()
  arg:set("build_name", bo2.gv_guild_build:find(type).name)
  arg:set("build_level", level + 1)
  g_build_level.text = sys.mtf_merge(arg, ui.get_text("guild|build_res_win_des"))
  item_over = add_item(ui_guild_build, bo2.BuildSpecialRes_Develop, line.develop)
  g_iscomplete = g_iscomplete and item_over
  item_over = add_item(ui_guild_build, bo2.BuildSpecialRes_Money, line.money)
  g_iscomplete = g_iscomplete and item_over
  local resources = line.resources
  if resources.size ~= 0 and resources.size ~= 1 then
    for i = 0, resources.size - 1, 2 do
      item_over = add_item(ui_guild_build, resources[i], resources[i + 1])
      g_iscomplete = g_iscomplete and item_over
    end
  end
  local self = ui.guild_get_self()
  local line = bo2.gv_guild_auth:find(self.guild_pos)
  if line.levelup == 1 then
    w_build_res.dx = 456
    g_pos_title.visible = true
  else
    w_build_res.dx = 329
    g_pos_title.visible = false
  end
end
function on_build_res_visible(w, vis)
end
function on_init(win)
  local arg = sys.variant()
  arg:set(packet.key.guild_build, 1)
  arg:set(packet.key.guild_level, 4)
  set_build_info(arg)
end
function close_win()
  w_build_res.visible = false
  if sys.check(res_send) == true then
    res_send.visible = false
  end
end
function on_money_btnclick(btn)
  local item = btn.parent
  local des_text = ""
  local type = item.svar.type
  local change_count = 0
  local group_num = 1
  if type == bo2.BuildSpecialRes_Money then
    des_text = ui.get_text("guild|res_des_money")
  else
    change_count = bo2.gv_guild_resources_def:find(type).money2item
    group_num = bo2.gv_guild_resources_def:find(type).num
    local arg = sys.variant()
    arg:set("item", type)
    arg:set("money", change_count)
    arg:set("count", group_num)
    des_text = sys.mtf_merge(arg, ui.get_text("guild|res_des_item_money"))
  end
  local function send_to_server()
    local res_num = g_up_res_num
    if res_num < 0 then
      return
    end
    if res_num > g_up_res_max then
      res_num = g_up_res_max
    end
    local v = sys.variant()
    v:set(packet.key.guild_money, 1)
    v:set(packet.key.guild_build, g_build_type)
    v:set(packet.key.guild_res_excel_id, type)
    v:set(packet.key.guild_res_count, res_num)
    bo2.send_variant(packet.eCTS_UI_GuildBuildRes, v)
  end
  local function init_res_num()
    local ui_guild_build = ui.guild_get_build(g_build_type)
    if ui_guild_build == nil then
      return
    end
    local needres_count = ui_guild_build:needres_count(type)
    g_up_res_num = 0
    if type == bo2.BuildSpecialRes_Money then
      g_up_res_max = ui.guild_get_money()
      if needres_count < g_up_res_max then
        g_up_res_max = math.modf(needres_count / 10000)
      else
        g_up_res_max = math.modf(g_up_res_max / 10000)
      end
    else
      local money = ui.guild_get_money()
      local cur_num = math.floor(money / change_count)
      if cur_num > math.floor(needres_count / group_num) then
        cur_num = math.floor(needres_count / group_num)
      end
      g_up_res_max = cur_num
    end
  end
  ui_widget.ui_msg_box.show_common({
    style_uri = "$frame/guild/guild_build_res.xml",
    style_name = "res_send",
    init = function(data)
      data.window:search("res_send_des").mtf = des_text
      init_res_num()
      w_input.text = g_up_res_num
    end,
    callback = function(ret)
      if ret.result == 1 then
        local res_name = ""
        local text_name = "guild|res_send_des_sure1"
        g_up_res_num = tonumber(tostring(w_input.text))
        if g_up_res_num <= 0 then
          ui_chat.show_ui_text_id(1875)
          return
        end
        if g_up_res_num > g_up_res_max then
          g_up_res_num = g_up_res_max
        end
        if g_up_res_num <= 0 then
          ui_chat.show_ui_text_id(1875)
          return
        end
        local arg = sys.variant()
        if type == bo2.BuildSpecialRes_Money then
          res_name = ui.get_text("guild|res_name_money")
          text_name = "guild|res_send_des_sure2"
          arg:set("num", g_up_res_num * group_num)
          arg:set("res_name", res_name)
        else
          text_name = "guild|res_send_des_sure_money2item"
          arg:set("money", g_up_res_num * change_count)
          arg:set("item", type)
          arg:set("count", group_num * g_up_res_num)
        end
        local msg = {
          text = sys.mtf_merge(arg, ui.get_text(text_name)),
          modal = true,
          btn_confirm = 1,
          btn_cancel = 1,
          callback = function(data)
            if data.result == 1 then
              send_to_server()
            end
          end
        }
        ui_widget.ui_msg_box.show_common(msg)
      end
    end
  })
end
function on_develop_btnclick(btn)
  local item = btn.parent
  local des_text = ""
  local type = item.svar.type
  local change_count = 0
  local group_num = 1
  if type == bo2.BuildSpecialRes_Develop then
    des_text = ui.get_text("guild|res_des_develop")
  else
    change_count = bo2.gv_guild_resources_def:find(type).develop2item
    group_num = bo2.gv_guild_resources_def:find(type).num
    local arg = sys.variant()
    arg:set("item", type)
    arg:set("develop", change_count)
    arg:set("count", group_num)
    des_text = sys.mtf_merge(arg, ui.get_text("guild|res_des_item_develop"))
  end
  local function send_to_server()
    local res_num = g_up_res_num
    if res_num < 0 then
      return
    end
    if res_num > g_up_res_max then
      res_num = g_up_res_max
    end
    local v = sys.variant()
    v:set(packet.key.guild_develop, 1)
    v:set(packet.key.guild_build, g_build_type)
    v:set(packet.key.guild_res_excel_id, type)
    v:set(packet.key.guild_res_count, res_num)
    bo2.send_variant(packet.eCTS_UI_GuildBuildRes, v)
  end
  local function init_res_num()
    local ui_guild_build = ui.guild_get_build(g_build_type)
    if ui_guild_build == nil then
      return
    end
    local needres_count = ui_guild_build:needres_count(type)
    g_up_res_num = 0
    if type == bo2.BuildSpecialRes_Develop then
      g_up_res_max = ui.guild_get_develop()
      if needres_count < g_up_res_max then
        g_up_res_max = needres_count
      end
    else
      local develop = ui.guild_get_develop()
      local cur_num = math.floor(develop / change_count)
      if cur_num > math.floor(needres_count / group_num) then
        cur_num = math.floor(needres_count / group_num)
      end
      g_up_res_max = cur_num
    end
  end
  ui_widget.ui_msg_box.show_common({
    style_uri = "$frame/guild/guild_build_res.xml",
    style_name = "res_send",
    init = function(data)
      data.window:search("res_send_des").mtf = des_text
      init_res_num()
      w_input.text = g_up_res_num
    end,
    callback = function(ret)
      if ret.result == 1 then
        local res_name = ""
        local text_name = "guild|res_send_des_sure1"
        g_up_res_num = tonumber(tostring(w_input.text))
        if g_up_res_num <= 0 then
          ui_chat.show_ui_text_id(1875)
          return
        end
        if g_up_res_num > g_up_res_max then
          g_up_res_num = g_up_res_max
        end
        if g_up_res_num <= 0 then
          ui_chat.show_ui_text_id(1875)
          return
        end
        local arg = sys.variant()
        if type == bo2.BuildSpecialRes_Develop then
          res_name = ui.get_text("guild|res_name_develop")
          text_name = "guild|res_send_des_sure3"
          arg:set("num", g_up_res_num * group_num)
          arg:set("res_name", res_name)
        else
          text_name = "guild|res_send_des_sure_develop2item"
          arg:set("develop", g_up_res_num * change_count)
          arg:set("item", type)
          arg:set("count", group_num * g_up_res_num)
        end
        local msg = {
          text = sys.mtf_merge(arg, ui.get_text(text_name)),
          modal = true,
          btn_confirm = 1,
          btn_cancel = 1,
          callback = function(data)
            if data.result == 1 then
              send_to_server()
            end
          end
        }
        ui_widget.ui_msg_box.show_common(msg)
      end
    end
  })
end
function on_item_btnclick(btn)
  local item = btn.parent
  local des_text = ""
  local type = item.svar.type
  if type == bo2.BuildSpecialRes_Develop then
    des_text = ui.get_text("guild|res_des_develop")
  elseif type == bo2.BuildSpecialRes_Money then
    des_text = ui.get_text("guild|res_des_money")
  else
    local arg = sys.variant()
    arg:set("group", bo2.gv_guild_resources_def:find(type).num)
    des_text = sys.mtf_merge(arg, ui.get_text("guild|res_des_item"))
  end
  local function send_to_server()
    local res_num = g_up_res_num
    if res_num < 0 then
      return
    end
    if res_num > g_up_res_max then
      res_num = g_up_res_max
    end
    local v = sys.variant()
    v:set(packet.key.guild_build, g_build_type)
    v:set(packet.key.guild_res_excel_id, type)
    v:set(packet.key.guild_res_count, res_num)
    bo2.send_variant(packet.eCTS_UI_GuildBuildRes, v)
  end
  local function init_res_num()
    local ui_guild_build = ui.guild_get_build(g_build_type)
    if ui_guild_build == nil then
      return
    end
    local needres_count = ui_guild_build:needres_count(type)
    g_up_res_num = 0
    if type == bo2.BuildSpecialRes_Develop then
      g_up_res_max = ui.guild_get_develop()
      if needres_count < g_up_res_max then
        g_up_res_max = needres_count
      end
    elseif type == bo2.BuildSpecialRes_Money then
      g_up_res_max = ui.guild_get_money()
      if needres_count < g_up_res_max then
        g_up_res_max = math.modf(needres_count / 10000)
      else
        g_up_res_max = math.modf(g_up_res_max / 10000)
      end
    else
      local cur_num = ui.item_get_count(type, true)
      if needres_count < cur_num then
        cur_num = needres_count
      end
      local res_group = 1
      local line = bo2.gv_guild_resources_def:find(type)
      if line ~= nil then
        res_group = line.num
      end
      g_up_res_max = math.modf(cur_num / res_group)
    end
  end
  ui_widget.ui_msg_box.show_common({
    style_uri = "$frame/guild/guild_build_res.xml",
    style_name = "res_send",
    init = function(data)
      data.window:search("res_send_des").text = des_text
      init_res_num()
      w_input.text = g_up_res_num
    end,
    callback = function(ret)
      if ret.result == 1 then
        local res_name = ""
        local group_num = 1
        local text_name = "guild|res_send_des_sure1"
        g_up_res_num = tonumber(tostring(w_input.text))
        if g_up_res_num <= 0 then
          ui_chat.show_ui_text_id(1875)
          return
        end
        if g_up_res_num > g_up_res_max then
          g_up_res_num = g_up_res_max
        end
        if g_up_res_num <= 0 then
          ui_chat.show_ui_text_id(1875)
          return
        end
        if type == bo2.BuildSpecialRes_Develop then
          res_name = ui.get_text("guild|res_name_develop")
        elseif type == bo2.BuildSpecialRes_Money then
          res_name = ui.get_text("guild|res_name_money")
          text_name = "guild|res_send_des_sure2"
        else
          res_name = bo2.gv_item_list:find(type).name
          group_num = bo2.gv_guild_resources_def:find(type).num
          text_name = "guild|res_send_des_sure3"
        end
        local arg = sys.variant()
        arg:set("num", g_up_res_num * group_num)
        arg:set("res_name", res_name)
        local msg = {
          text = sys.mtf_merge(arg, ui.get_text(text_name)),
          modal = true,
          btn_confirm = 1,
          btn_cancel = 1,
          callback = function(data)
            if data.result == 1 then
              send_to_server()
            end
          end
        }
        ui_widget.ui_msg_box.show_common(msg)
      end
    end
  })
end
function on_stepping_head()
  g_up_res_num = tonumber(tostring(w_input.text))
  if g_up_res_num == 0 then
    return
  end
  g_up_res_num = 0
  w_input.text = g_up_res_num
end
function on_stepping_prev()
  g_up_res_num = tonumber(tostring(w_input.text))
  if g_up_res_num == 0 then
    return
  end
  if g_up_res_num > g_up_res_max then
    g_up_res_num = g_up_res_max
  else
    g_up_res_num = g_up_res_num - 1
  end
  w_input.text = g_up_res_num
end
function on_stepping_foot()
  g_up_res_num = tonumber(tostring(w_input.text))
  if g_up_res_num == g_up_res_max then
    return
  end
  g_up_res_num = g_up_res_max
  w_input.text = g_up_res_num
end
function on_stepping_next()
  g_up_res_num = tonumber(tostring(w_input.text))
  if g_up_res_num == g_up_res_max then
    return
  end
  if g_up_res_num > g_up_res_max then
    g_up_res_num = g_up_res_max
  else
    g_up_res_num = g_up_res_num + 1
  end
  w_input.text = g_up_res_num
end
function handleOpenResWin(cmd, data)
  if data:has(packet.key.cmn_system_flag) then
    ui_guild_mod.ui_create_scn_res.handleOpenResWin(cmd, data)
  else
    set_build_info(data)
    w_build_res.visible = true
  end
end
function handleBuildRes(cmd, data)
  if w_build_res.visible == false then
    return
  end
  local type = data:get(packet.key.guild_build).v_int
  if type ~= g_build_type then
    return
  end
  set_build_info(data)
  if g_iscomplete == true then
    w_build_res.visible = false
  end
end
reg(packet.eSTC_Guild_OpenResWin, handleOpenResWin, sig)
reg(packet.eSTC_Guild_BuildRes, handleBuildRes, sig)
function onSelfEnterScn(obj)
  if sys.check(bo2.scn) == false then
    return
  end
  local scn_type = bo2.gv_scn_alloc:find(bo2.scn.scn_excel.id).type
  if scn_type == 4 then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_Guild_BuildReq, v)
  end
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, onSelfEnterScn, "ui_guild_mod.ui_build_res:onSelfEnterScn")
