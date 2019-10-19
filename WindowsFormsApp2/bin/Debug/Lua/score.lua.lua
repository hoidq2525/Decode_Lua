gx_grade = 1
local sig = "ui_scncopy:score"
local reg = ui_packet.game_recv_signal_insert
local star_name = {}
local star_max_dx = {}
local star_index = 1
local animation_step = 0
function set_star_and_inf(name, score, max_score)
  table.insert(star_name, name)
  table.insert(star_max_dx, score / max_score * 128)
end
function set_other_inf(name, child_name, text)
  local info_panel = g_score_wnd:search(name)
  if info_panel ~= nil then
    info_panel:search(child_name).text = "+" .. text .. "%"
  end
end
function set_mtf(name, child_name, text)
  local info_panel = g_score_wnd:search(name)
  if info_panel ~= nil then
    info_panel:search(child_name).mtf = text
  end
end
function star_animation()
  if animation_step ~= 1 then
    return true
  end
  local info_panel = g_score_wnd:search(star_name[star_index])
  if info_panel ~= nil and star_max_dx[star_index] ~= 0 then
    info_panel:search("star").dx = 4 + info_panel:search("star").dx
  end
  if info_panel:search("star").dx >= star_max_dx[star_index] and star_index == 5 then
    g_score_wnd:search("addmod_text").visible = true
    local panel = g_score_wnd:search("gread_picture").parent
    panel.dx = 256
    panel.dy = 256
    panel.visible = true
    animation_step = 2
    return true
  elseif info_panel:search("star").dx >= star_max_dx[star_index] then
    star_index = star_index + 1
  end
  return false
end
function gread_animation()
  if animation_step ~= 2 then
    return true
  end
  local panel = g_score_wnd:search("gread_picture").parent
  if panel.dx <= 128 then
    animation_step = 3
    return true
  else
    panel.dx = panel.dx - 8
    panel.dy = panel.dy - 8
    return false
  end
end
function on_timer()
  if star_animation() == false then
    return
  end
  if gread_animation() == false then
    return
  end
  g_score_wnd:search("good_info"):search("rich_text").visible = true
  g_score_wnd:search("money_info"):search("rich_text").visible = true
  g_score_wnd:search("exp_info"):search("rich_text").visible = true
  open_btn.enable = true
  g_timer.suspended = true
end
function show_score_panel(data)
  local values = {
    money = data:get("money").v_int,
    exp = data:get("exp").v_int,
    get_item = data:get("items"),
    speed = data:get("speed").v_int,
    event = data:get("complete").v_int,
    kill = data:get("kill_score").v_int,
    item = data:get("item_score").v_int,
    skill = data:get("skill_score").v_int,
    addmod = data:get("add_mod").v_int,
    grade = data:get("grade").v_int,
    dungeon_info_excel_id = data:get(packet.key.dungeon_info_excel_id).v_int
  }
  local dungeon_info_excel = bo2.gv_dungeon_define:find(values.dungeon_info_excel_id)
  if dungeon_info_excel == nil then
    dungeon_info_excel = bo2.gv_dungeon_define:find(1)
  end
  set_star_and_inf("speed_info", values.speed, dungeon_info_excel._Speed_Max)
  set_star_and_inf("event_info", values.event, dungeon_info_excel._Event_Max)
  set_star_and_inf("kill_info", values.kill, dungeon_info_excel._Kill_Max)
  set_star_and_inf("item_info", values.item, dungeon_info_excel._Item_Max)
  set_star_and_inf("skill_info", values.skill, dungeon_info_excel._Skill_Max)
  set_other_inf("addmod_info", "addmod_text", values.addmod)
  gx_grade = values.grade
  g_score_wnd:search("gread_picture").image = SHARED(sys.format("$image/scncopy/gread/%d.png", gx_grade))
  local item_mtf = ""
  for i = 0, values.get_item.size do
    local v = values.get_item:get(i)
    if v:get("num").v_int ~= 0 then
      local item_real = bo2.gv_item_list:find(v:get("excelId").v_int)
      if item_real == nil then
        return
      end
      local image_uri = sys.format("$icon/item/%s.png|0,0,64,64*22,22", tostring(item_real.icon))
      item_mtf = item_mtf .. sys.format("<a:r>%dx<img:%s>", v:get("num").v_int, image_uri)
    end
  end
  set_mtf("good_info", "rich_text", item_mtf)
  set_mtf("money_info", "rich_text", sys.format("<a:r><m:%d>", values.money))
  set_mtf("exp_info", "rich_text", sys.format("<a:r>%d ", values.exp))
  g_score_wnd:search("gread_picture").parent.visible = false
  animation_step = 1
  g_score_wnd.visible = true
  g_timer.suspended = false
end
function handle_openwindow(cmd, data)
  if data:get(packet.key.ui_window_type).v_string == L("scncopy_score") then
  end
end
function open_lottery_msg(btn)
  g_ui_lottery.visible = false
  g_ui_lottery_msg.visible = true
end
reg(packet.eSTC_UI_OpenWindow, handle_openwindow, sig)
function leave_scncopy(btn)
  g_ui_lottery_msg.visible = false
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_LeaveDungeonScn, v)
end
function close_scncopy(btn)
  ui_minimap.set_leave_help_visible(true)
  g_ui_lottery_msg.visible = false
end
function on_score_visible(panel, bool)
  if bool == false then
    for k, v in pairs(star_name) do
      local info_panel = g_score_wnd:search(v)
      if info_panel ~= nil then
        info_panel:search("star").dx = 0
      end
    end
    star_max_dx = {}
    star_name = {}
    star_index = 1
    g_score_wnd:search("addmod_text").visible = false
    g_score_wnd:search("gread_picture").parent.visible = false
    g_score_wnd:search("good_info"):search("rich_text").visible = false
    g_score_wnd:search("money_info"):search("rich_text").visible = false
    g_score_wnd:search("exp_info"):search("rich_text").visible = false
    open_btn.enable = false
  end
end
function set_vis(vis)
  g_score_wnd.visible = vis
  g_ui_lottery.visible = vis
  g_ui_lottery_msg.visible = vis
end
