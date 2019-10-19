local c_choice_uri = SHARED("$gui/phase/choice/choice.xml")
local wait_second = 0
local perf_stat
w_top = ui_phase.w_choice
local wait_second = 0
function show_top(vis, arg)
  if vis then
    if w_top.visible == vis then
      return
    end
    ui.image_cache_remove(c_choice_weapon)
    ui_startup.show_top(false)
    ui_main.show_top(false)
    w_top.visible = true
    w_cha_panel.visible = true
    w_top.focus = true
    ui_main.g_player_cfg_playername = nil
    ui.log("perf_stat:save0")
    if perf_stat ~= nil then
      local function create_scn_view_with_arg()
        create_scn_view(arg)
      end
      perf_stat:invoke(create_scn_view_with_arg)
      perf_stat:save("$app/log/perf_choice_scn.txt")
      ui.log("perf_stat:save1")
    else
      create_scn_view(arg)
    end
  else
    w_top.visible = false
    destroy_scn_view()
  end
end
function set_create_msg(msg)
  ui_tool.note_insert(msg, "FF0000")
end
function init()
  ui.log("ui_phase:choice : loading enter")
  w_top:load_style("$gui/phase/choice/choice.xml", "w_startup")
  ui.log("ui_phase:choice : loading leave")
end
function on_cha_return_gzs(btn)
  w_cha_panel.visible = true
  w_create_cha.visible = false
end
function init_once()
  if rawget(_M, "g_already_init") ~= nil then
    return
  end
  g_already_init = true
  server_list_data = {}
  player_list_data = {}
  player_item_sel = 0
end
local c_player_count = 5
function player_list_init()
  player_list_item = {}
  for i = 0, c_player_count - 1 do
    local item = {}
    local bar = w_player_list:search(sys.format("bar_player_%d", i))
    bar.svar.player_item = item
    item.bar = bar
    item.lb_name = bar:search("lb_name")
    item.lb_info = bar:search("lb_info")
    item.lb_del = bar:search("lb_del")
    item.pic_icon = bar:search("pic_icon")
    item.fig_highlight = bar:search("fig_highlight")
    player_list_item[i] = item
    player_item_update(i)
  end
end
function player_list_clear()
  player_list_data = {}
  for i = 0, c_player_count - 1 do
    local item = player_list_item[i]
    item.bar.visible = false
    player_item_clear(item)
  end
  player_item_sel = 0
  if sys.check(curent_select_player) then
    curent_select_player:sethighlum(false)
    set_player_selected_sil(curent_select_player, false)
  end
end
function player_item_clear(item)
  item.bar.mouse_able = false
  item.lb_name.text = nil
  item.lb_info.text = nil
  item.lb_del.visible = false
  item.pic_icon.image = nil
  item.fig_highlight.visible = false
end
function player_item_update(i)
  if i >= c_player_count then
    return
  end
  local info = player_list_data[i]
  local item = player_list_item[i]
  if info == nil then
    item.bar.visible = false
    player_item_clear(item)
    return
  end
  item.bar.svar.player_data = info
  item.bar.mouse_able = true
  local camp = info.atb:bget_int(bo2.eAtb_Camp)
  if camp == bo2.eCamp_Blade then
    camp = ui.get_text("phase|camp_blade")
  elseif camp == bo2.eCamp_Sword then
    camp = ui.get_text("phase|camp_sword")
  end
  item.lb_name.text = sys.format("%s(%s)", info.name, camp)
  local pro = bo2.gv_profession_list:find(info.atb:bget_int(bo2.eAtb_Cha_Profession))
  if pro ~= nil then
    local lvl = info.atb:bget_int(bo2.eAtb_Level)
    if lvl == 0 then
      item.lb_info.text = ui_widget.merge_mtf({
        name = pro.name
      }, ui.get_text("phase|new_cha"))
    else
      item.lb_info.text = ui_widget.merge_mtf({
        name = pro.name,
        level = lvl
      }, ui.get_text("phase|new_cha_level"))
    end
  end
  local model = bo2.gv_init_cha:find(info.atb:bget_int(bo2.eAtb_ExcelID))
  if model ~= nil then
    local mb_cha_list = bo2.gv_cha_list:find(model.id)
    local mb_cha_pic = bo2.gv_cha_pic:find(mb_cha_list.pic)
    item.pic_icon.image = "$data/gui/icon/portrait/" .. string.gsub(tostring(mb_cha_pic.head_icon), ".png", ".png")
  end
  local portrait = bo2.gv_portrait:find(info.flag_int32:bget_int(bo2.ePlayerFlagInt32_Portrait))
  if portrait ~= nil then
    item.pic_icon.image = "$data/gui/icon/portrait/" .. portrait.icon .. ".png"
  else
  end
  local retain_second = info.retain_second
  if retain_second > 0 then
    item.lb_del.visible = true
    local txt
    if retain_second >= 3600 then
      txt = ui_widget.merge_mtf({
        hour = math.floor(retain_second / 3600),
        min = math.floor(math.mod(retain_second, 3600) / 60)
      }, ui.get_text("phase|delete1"))
    elseif retain_second < 60 then
      txt = ui_widget.merge_mtf({sec = retain_second}, ui.get_text("phase|delete2"))
    else
      txt = ui_widget.merge_mtf({
        sec = retain_second / 60
      }, ui.get_text("phase|delete3"))
    end
    item.lb_del.text = txt
  else
    item.lb_del.visible = false
  end
  item.bar.visible = false
end
function player_item_comp(x, y)
  return x.key < y.key
end
function player_list_update(list)
  if list == nil then
    ui.log("player_list_update: list empty")
    return
  end
  ui.log("player_list_update: cha count %d", list.size)
  player_list_clear()
  list:sort("cha_onlyid")
  for i = 0, list.size - 1 do
    local info = list:get(i)
    local item_data = {
      name = info:get("cha_name").v_string,
      only_id = info:get("cha_onlyid").v_string,
      atb = info:get("atb"),
      equip = info:get("equip"),
      flag_int32 = info:get("flag_int32"),
      flag_int8 = info:get("flag_int8"),
      retain_second = info:get("retain_second").v_int,
      info = info
    }
    item_data.key = sys.format(L("%.16I64x"), item_data.only_id)
    player_list_data[i] = item_data
  end
  table.sort(player_list_data, player_item_comp)
  for i = 0, list.size - 1 do
    player_item_update(i)
  end
  update_scn_view_player_list()
  update_buttons()
end
function player_item_update_highlight(item)
  local vis = item == player_item_sel or item.inner_hover
  local fig = item:search("fig_highlight")
  fig.visible = vis
  if vis == true then
    bo2.PlaySound2D(540, false)
  end
end
function update_gzs()
end
function on_player_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_inner or msg == ui.mouse_outer or msg == ui.mouse_leave then
    player_item_update_highlight(item)
    return
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_dbl then
    local sel = player_item_sel
    if sel ~= item then
      if sys.check(sel) then
        player_item_sel = 0
        player_item_update_highlight(sel)
      end
      player_item_sel = item
      player_item_update_highlight(item)
      update_buttons()
      on_select_player(item)
    end
    if msg == ui.mouse_lbutton_dbl then
      local player_data = player_item_sel.svar.player_data
      task_cha_selected(player_data.only_id)
    end
  end
end
function server_list_update(list)
  if list == nil then
    ui.log("server_list_update: list empty")
    return
  end
  ui.log("server_list_update: gzs count %d", list.size)
  server_list_data = {}
  for i = 0, list.size - 1 do
    local info = list:get(i)
    local item_data = {
      name = info:get("GZS_Name").v_string,
      id = info:get("GZS_ID").v_int,
      info = info
    }
    table.insert(server_list_data, item_data)
  end
  w_server_list:item_clear()
  for i, v in ipairs(server_list_data) do
    server_list_insert(v)
  end
end
function server_list_make()
end
local server_item_uri = c_choice_uri
local server_item_name = SHARED("server_item")
function server_list_insert(data)
  local item = w_server_list:item_append()
  item:load_style(server_item_uri, server_item_name)
  item.svar.server_data = data
  server_item_update(item)
end
function server_item_update(item)
  local vis = item.selected or item.inner_hover
  local fig = item:search("fig_highlight")
  fig.visible = vis
  local data = item.svar.server_data
  local stk = sys.mtf_stack()
  if sys.is_file("$cfg/tool/pix_dj2_config.xml") then
    if vis then
      stk:raw_push("<c+:FFFFFF>")
      stk:push(data.name)
      stk:raw_format("[%d]", data.id)
      stk:raw_push("<c->")
    else
      stk:push(data.name)
      stk:raw_format("[%d]", data.id)
    end
  elseif vis then
    stk:raw_push("<c+:FFFFFF>")
    stk:push(data.name)
    stk:raw_push("<c->")
  else
    stk:push(data.name)
  end
  local rb = item:search("rb_text")
  rb.mtf = stk.text
end
function on_server_item_sel(item, sel)
  server_item_update(item)
end
function on_server_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    server_item_update(item)
    return
  end
  if msg == ui.mouse_lbutton_dbl then
    server_item_update(item)
    local w = item.topper
    local d = w.svar.msg_box_data
    d.result = 1
    ui_widget.ui_msg_box.invoke(d)
  end
end
function server_list_show()
  if player_item_sel == 0 then
    return
  end
  local info = player_item_sel.svar.player_data
  if info.retain_second ~= 0 then
    return
  end
  local on_msg_init = function(msg)
    server_list_make()
  end
  local channel_choose_msg = {
    init = on_msg_init,
    callback = on_channel_choose_msg_callback,
    style_uri = server_item_uri,
    style_name = "server_list"
  }
  ui_widget.ui_msg_box.show(channel_choose_msg)
end
function play_jump_ani()
  local scn = w_scn_view.scn
  if select_player_list[curent_select_player] then
    local pos_excel = bo2.gv_init_choice:find(select_player_list[curent_select_player].pos_id)
    local camera = pos_excel.camera
    local anim = pos_excel.camera_anim
    set_player_selected_sil(curent_select_player, false)
    w_scn_view.mouse_able = true
    disable_buttons()
    set_stage(4)
    scn:SetCameraControl(camera, curent_select_player.sel_handle, send_enter_game, false, false)
    curent_select_player:ViewPlayerAnimPlay(anim, false)
  end
end
function on_channel_choose_msg_callback(msg)
  if msg.result == 0 then
    return
  end
  local item_sel = w_server_list.item_sel
  if item_sel == nil then
    ui_tool.note_insert(ui.get_text("phase|choice_line"), ui.make_color("FF0000"))
    return
  end
  cur_select_line = item_sel.svar.server_data.id
  play_jump_ani()
end
function on_wait_timer()
  if gx_wait_timer.suspended then
    return
  end
  wait_second = wait_second + 1
  local hour = 0
  local minute = 0
  local second = 0
  hour = math.floor(wait_second / 3600)
  minute = math.floor((wait_second - hour * 3600) / 60)
  second = wait_second - hour * 3600 - minute * 60
  m_wait_second.text = ui_widget.merge_mtf({
    hour = hour,
    minute = min,
    sec = second
  }, ui.get_text("phase|in_line_time"))
end
function on_queueing(msg)
  local player_data = player_item_sel.svar.player_data
  task_cha_selected(player_data.only_id)
  gx_wait_timer.suspended = true
  wait_second = 0
end
function on_enter_game_click(btn)
  local player_data = player_item_sel.svar.player_data
  task_cha_selected(player_data.only_id)
end
function delete_cha(btn)
  if player_item_sel == 0 then
    return false
  end
  local player_data = player_item_sel.svar.player_data
  local cha_id = player_data.only_id
  if cha_id then
    task_cha_delete(cha_id)
  end
end
function on_restore_cha(btn)
  if player_item_sel == 0 then
    return false
  end
  local player_data = player_item_sel.svar.player_data
  local cha_id = player_data.only_id
  if cha_id then
    task_cha_restore(cha_id)
  end
end
function update_buttons()
  w_newcha.enable = #player_list_data < 4
  local is_player_valid = false
  local is_player_deleted = false
  if sys.check(player_item_sel) then
    local info = player_item_sel.svar.player_data
    if info.retain_second == 0 then
      is_player_valid = true
    else
      is_player_deleted = true
    end
  end
  w_delcha.enable = is_player_valid
  w_rescha.enable = is_player_deleted
  w_entergame.enable = is_player_valid
end
function create_cha_list(list)
  player_list_update(list)
end
function create_gzs_list(list)
  server_list_update(list)
end
function return_startup(btn)
  ui_packet.disconnet()
end
function send_enter_game()
  if cur_select_line == 0 then
    return
  end
  local player_data = player_item_sel.svar.player_data
  w_top.visible = false
  ui_loading.show_top(true)
  local data = {
    gzs_id = cur_select_line,
    cha_id = player_data.only_id
  }
  ui.log("gzs_id %s, cha_id %s.", data.gzs_id, data.cha_id)
  ui_loading.insert_msg(ui.get_text("phase|yanzhengjuese"))
  local rst = ui_packet.gzs_enter(data)
  if rst ~= ui_packet.rst_ok then
    ui.log("enter_game : error %d", rst)
    ui_loading.insert_msg(ui.get_text("phase|yanzhengjuesefailed"))
    return false
  end
  ui_main.g_player_cfg_playername = player_data.name
  return true
end
function on_btn_sound()
  bo2.PlaySound2D(537, false)
end
function on_init()
  player_list_init()
end
init_once()
