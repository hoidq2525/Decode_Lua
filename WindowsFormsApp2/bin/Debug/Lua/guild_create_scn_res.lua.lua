local g_up_res_num = 0
local g_up_res_max = 0
local g_build_type = 0
local g_iscomplete = true
res_table = {}
function add_item(excel_id, needres_count, max_count)
  local item = g_res_list:item_append()
  item:load_style("$frame/guild/guild_create_scn_res.xml", "resitem")
  local res_name = ""
  if excel_id == bo2.BuildSpecialRes_Money then
    res_name = ui.get_text("guild|res_name_money2")
  else
    res_name = bo2.gv_item_list:find(excel_id).name
  end
  item:search("res_name").mtf = res_name
  local arg = sys.variant()
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
    res_count = sys.mtf_merge(arg, ui.get_text("guild|res_count_mtf2"))
  else
    res_count = sys.mtf_merge(arg, ui.get_text("guild|res_count_mtf"))
  end
  item:search("res_count").mtf = res_count
  item.svar.type = excel_id
  item.svar.needres = needres_count
  local btn_item = item:search("btn_item")
  local btn_money = item:search("btn_money")
  local btn_develop = item:search("btn_develop")
  if excel_id < bo2.BuildSpecialRes_Max then
    btn_item.enable = true
    btn_develop.enable = false
    btn_money.enable = false
  else
    btn_item.enable = true
    btn_money.enable = true
    btn_develop.enable = true
  end
  return max_count <= cur_num
end
function on_build_res_visible(w, vis)
end
function close_win()
  w_main.visible = false
  if sys.check(res_send) then
    res_send.visible = false
  end
end
function on_money_btnclick(btn)
  local item = btn.parent
  local des_text = ""
  local type = item.svar.type
  local change_count = 1
  local group_num = 1
  if type == bo2.BuildSpecialRes_Money then
    des_text = ui.get_text("guild|res_des_money")
  else
    change_count = bo2.gv_guild_resources_def:find(type).money2item
    group_num = bo2.gv_guild_resources_def:find(type).num
    change_count = math.floor(change_count / group_num)
    local arg = sys.variant()
    arg:set("item", type)
    arg:set("money", change_count)
    des_text = sys.mtf_merge(arg, ui.get_text("guild|res_des_item_money2"))
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
    v:set(packet.key.guild_res_excel_id, type)
    v:set(packet.key.guild_res_count, res_num)
    bo2.send_variant(packet.eCTS_UI_GuildCreateScnRes, v)
  end
  local function init_res_num()
    local needres_count = item.svar.needres
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
      if needres_count < cur_num then
        cur_num = needres_count
      end
      g_up_res_max = cur_num
    end
  end
  ui_widget.ui_msg_box.show_common({
    style_uri = "$frame/guild/guild_create_scn_res.xml",
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
          text_name = "guild|res_send_des_sure_money2item2"
          arg:set("money", g_up_res_num * change_count)
          arg:set("item", type)
          arg:set("count", g_up_res_num)
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
    change_count = math.floor(change_count / group_num)
    local arg = sys.variant()
    arg:set("item", type)
    arg:set("develop", change_count)
    arg:set("count", group_num)
    des_text = sys.mtf_merge(arg, ui.get_text("guild|res_des_item_develop2"))
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
    v:set(packet.key.guild_res_excel_id, type)
    v:set(packet.key.guild_res_count, res_num)
    bo2.send_variant(packet.eCTS_UI_GuildCreateScnRes, v)
  end
  local function init_res_num()
    local needres_count = item.svar.needres
    g_up_res_num = 0
    if type == bo2.BuildSpecialRes_Develop then
      g_up_res_max = ui.guild_get_develop()
      if needres_count < g_up_res_max then
        g_up_res_max = needres_count
      end
    else
      local develop = ui.guild_get_develop()
      local cur_num = math.floor(develop / change_count)
      if needres_count < cur_num then
        cur_num = needres_count
      end
      g_up_res_max = cur_num
    end
  end
  ui_widget.ui_msg_box.show_common({
    style_uri = "$frame/guild/guild_create_scn_res.xml",
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
          text_name = "guild|res_send_des_sure_develop2item2"
          arg:set("develop", g_up_res_num * change_count)
          arg:set("item", type)
          arg:set("count", g_up_res_num)
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
  local type = item.svar.type
  local des_text = ""
  if type == bo2.BuildSpecialRes_Money then
    local arg = sys.variant()
    arg:set("cur_num", 1000000)
    des_text = sys.mtf_merge(arg, ui.get_text("guild|res_des_money2"))
  else
    local arg = sys.variant()
    des_text = sys.mtf_merge(arg, ui.get_text("guild|res_des_item2"))
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
    v:set(packet.key.guild_res_excel_id, type)
    v:set(packet.key.guild_res_count, res_num)
    bo2.send_variant(packet.eCTS_UI_GuildCreateScnRes, v)
  end
  local function init_res_num()
    local needres_count = item.svar.needres
    g_up_res_num = 0
    if type == bo2.BuildSpecialRes_Money then
      g_up_res_max = bo2.player:get_flag_int32(bo2.eFlagInt32_BoundedMoney) + bo2.player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
      if needres_count < g_up_res_max then
        g_up_res_max = math.modf(needres_count / 10000)
      else
        g_up_res_max = math.modf(g_up_res_max / 10000)
      end
      if g_up_res_max > 100 then
        g_up_res_max = 100
      end
    else
      local cur_num = ui.item_get_count(type, true)
      if needres_count < cur_num then
        cur_num = needres_count
      end
      g_up_res_max = cur_num
    end
  end
  ui_widget.ui_msg_box.show_common({
    style_uri = "$frame/guild/guild_create_scn_res.xml",
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
        local err_text = 1875
        if type == bo2.BuildSpecialRes_Money then
          err_text = 2015
        end
        g_up_res_num = tonumber(tostring(w_input.text))
        if g_up_res_num <= 0 then
          ui_chat.show_ui_text_id(err_text)
          return
        end
        if g_up_res_num > g_up_res_max then
          g_up_res_num = g_up_res_max
        end
        if type == bo2.BuildSpecialRes_Money then
          res_name = ui.get_text("guild|res_name_money2")
          text_name = "guild|res_send_des_sure4"
        else
          res_name = bo2.gv_item_list:find(type).name
          text_name = "guild|res_send_des_sure3"
        end
        local arg = sys.variant()
        arg:set("num", g_up_res_num)
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
  g_iscomplete = true
  g_res_list:item_clear()
  local dataobj = data:get(packet.key.cmn_dataobj)
  if dataobj.size == 0 then
    return
  end
  local item_over = false
  for i = 0, dataobj.size - 1 do
    local res = dataobj:get(i)
    local type = res:get(packet.key.guild_res_excel_id).v_int
    local count = res:get(packet.key.guild_res_count).v_int
    item_over = add_item(type, count, res_table[type])
    g_iscomplete = g_iscomplete and item_over
  end
  if g_iscomplete == false then
    w_main.visible = true
  end
  local self = ui.guild_get_self()
  local line = bo2.gv_guild_auth:find(self.guild_pos)
  if line.levelup == 1 then
    w_main.dx = 456
    g_pos_title.visible = true
  else
    w_main.dx = 329
    g_pos_title.visible = false
  end
end
function on_init(win)
  for i, v in string.gmatch(tostring(bo2.gv_define_org:find(58).value), "(%w+)*(%w+)") do
    res_table[tonumber(i)] = tonumber(v)
  end
  res_table[bo2.BuildSpecialRes_Money] = tonumber(tostring(bo2.gv_define_org:find(57).value))
end
