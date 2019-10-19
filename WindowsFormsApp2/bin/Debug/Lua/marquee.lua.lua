g_marquee_info = nil
c_box_x = 520
function on_init()
  local val = bo2.rand(15, 20)
  ui_quest.w_serect_timer.period = val * 1000
  ui_quest.w_serect_timer.suspended = false
end
function set_visible(vis)
  local w = ui.find_control("$frame:marquee")
  if w == nil then
    return
  end
  w.visible = vis
end
function on_marquee_close_click(btn)
  if g_marquee_info == nil then
    return
  end
  local txt = g_marquee_info.text
  repeat
    ui.marquee_next(g_marquee_info)
  until g_marquee_info == nil or g_marquee_info.text ~= txt
end
function get_period_time(marquee_info)
  return math.floor(1000 / marquee_info.speed)
end
function set_marquee(marquee_info)
  local par = ui.find_control("$frame:marquee")
  if par == nil then
    return
  end
  local parent = par:search("marquee_panel")
  local rich_box = parent:search("r_box")
  rich_box:item_clear()
  rich_box:insert_mtf(sys.format("<tf:text>%s", marquee_info.text), ui.mtf_rank_system)
  rich_box.x = c_box_x
  local timer = parent:find_plugin("timer")
  timer.period = marquee_info.wait_time
  timer.suspended = false
  g_marquee_info = marquee_info
  ui_marquee.set_visible(true)
end
function marquee_cycle()
  local par = ui.find_control("$frame:marquee")
  local parent = par:search("marquee_panel")
  local timer = parent:find_plugin("timer")
  local rich_box = parent:search("r_box")
  timer.suspended = false
  timer.period = g_marquee_info.cycle_time
  rich_box:item_clear()
  rich_box:insert_mtf(sys.format("<tf:text>%s", g_marquee_info.text), ui.mtf_rank_system)
  rich_box.x = c_box_x
end
function on_marquee_restart()
  local marquee_info = ui.get_new_marquee()
  if marquee_info == nil then
    ui_marquee.set_visible(false)
    return
  end
  local par = ui.find_control("$frame:marquee")
  local parent = par:search("marquee_panel")
  local rich_box = parent:search("r_box")
  local timer = parent:find_plugin("timer")
  rich_box:item_clear()
  rich_box:insert_mtf(sys.format("<tf:text>%s", marquee_info.text), ui.mtf_rank_system)
  rich_box.x = c_box_x
  timer.period = marquee_info.wait_time
  timer.suspended = false
  g_marquee_info = marquee_info
  set_visible(true)
end
function on_marquee_next()
  local marquee_info = ui.get_new_marquee()
  if marquee_info == nil then
    ui_marquee.set_visible("false")
    return
  end
  local par = ui.find_control("$frame:marquee")
  if par == nil then
    return
  end
  local parent = par:search("marquee_panel")
  local rich_box = parent:search("r_box")
  local timer = parent:find_plugin("timer")
  rich_box:item_clear()
  rich_box:insert_mtf(sys.format("<tf:text>%s", marquee_info.text), ui.mtf_rank_system)
  rich_box.x = c_box_x
  timer.suspended = false
  timer.period = marquee_info.wait_time
  g_marquee_info = marquee_info
end
function on_marquee_end()
  local par = ui.find_control("$frame:marquee")
  local parent = par:search("marquee_panel")
  local timer = parent:find_plugin("timer")
  timer.suspended = true
  g_marquee_info = nil
  ui_marquee.set_visible(false)
end
function on_marquee_gm_cmd(marquee_info)
  if marquee_info == nil then
    return
  end
  g_marquee_info = marquee_info
  local par = ui.find_control("$frame:marquee")
  if par == nil then
    return
  end
  local parent = par:search("marquee_panel")
  local rich_box = parent:search("r_box")
  local timer = parent:find_plugin("timer")
  rich_box:item_clear()
  rich_box:insert_mtf(sys.format("<tf:text>%s", marquee_info.text), ui.mtf_rank_system)
  rich_box.x = c_box_x
  timer.suspended = true
  timer.period = marquee_info.wait_time
  timer.suspended = false
end
ui.insert_on_marquee_restart(on_marquee_restart, "ui_marquee:on_marquee_restart")
ui.insert_on_marquee_end(on_marquee_end, "ui_marquee:on_marquee_end")
ui.insert_on_marquee_next(on_marquee_next, "ui_marquee:on_marquee_next")
ui.insert_on_marquee_gm_cmd(on_marquee_gm_cmd, "ui_marquee:on_marquee_gm_cmd")
function test()
  ui.marquee_insert(1)
  ui.marquee_insert(2)
end
function on_marquee_mouse(panel, msg, pos, wheel)
end
function on_timer(timer)
  if g_marquee_info == nil then
    return
  end
  timer.period = math.floor(1000 / g_marquee_info.speed)
  local parent = timer.owner
  local box = parent:search("r_box")
  if box.x + box.extent.x <= 0 then
    timer.suspended = true
    g_marquee_info.times = g_marquee_info.times - 1
    if 0 >= g_marquee_info.times then
      ui.marquee_next(g_marquee_info)
      return
    end
    marquee_cycle()
    return
  end
  box.x = box.x - 1.6
end
function on_show_marquee(cmd, data)
  local text = data:get(packet.key.marquee_txt).v_string
  ui_chat.add_sys(text)
end
function on_show_exp(cmd, data)
  local textID = data:get(L("text_id")).v_int
  local excel = bo2.gv_text:find(textID)
  if excel == nil then
    return
  end
  local v = sys.variant()
  v:set("friend", data:get("friend").v_string)
  v:set("npc", data:get("npc").v_string)
  local base_exp = data:get("base_exp").v_int
  local infatuate_rate = data:get("infatuate_rate").v_int
  local double_rate = data:get("double_rate").v_int
  local global_rate = data:get("global_rate").v_int
  local final_exp = data:get("final_exp").v_int
  local lock_exp = data:get("lock_exp").v_int
  if infatuate_rate > 0 then
    base_exp = base_exp * infatuate_rate / 100
  end
  v:set("exp", base_exp)
  if base_exp == 0 then
    return
  end
  if final_exp == 0 then
    return
  end
  local text = sys.mtf_merge(v, excel.text)
  if base_exp == final_exp then
    text = sys.format("<c+:FFFFFF00>%s<c->", text)
    if data:has(packet.key.ui_text_targets) then
      local targets = data:get(packet.key.ui_text_targets)
      for i = 0, targets.size - 1 do
        local target = targets:get(i).v_int
        ui_chat.add_info(text, target)
      end
    else
      local targets = excel.targets
      for i = 0, targets.size - 1 do
        local target = targets[i]
        ui_chat.add_info(text, target)
      end
    end
    return
  end
  local final_t = ""
  local vip_rate = data:get("vip_rate").v_int
  if vip_rate > 0 then
    local orig_base = base_exp
    base_exp = base_exp * (100 + vip_rate) / 100
    final_t = sys.format("+%dvip", base_exp - orig_base)
  end
  local cha_exp = final_exp - base_exp
  if double_rate ~= 0 then
    local r = ui.get_text("portrait|double_rate")
    final_t = sys.format("%s+%s%d", final_t, r, base_exp)
    cha_exp = cha_exp - base_exp
  end
  if global_rate ~= 0 then
    local global_exp = final_exp * (1 - 100 / global_rate)
    local r = ui.get_text("portrait|global_rate")
    final_t = sys.format("%s+%s%d", final_t, r, global_exp)
    cha_exp = cha_exp - global_exp
  end
  if lock_exp ~= 0 then
    local r = ui.get_text("portrait|lock_exp")
    final_t = sys.format("%s+%s%d", final_t, r, lock_exp)
    cha_exp = cha_exp - lock_exp
  end
  if cha_exp ~= 0 then
    local r = ui.get_text("portrait|cha_rate")
    final_t = sys.format("%s+%s%d", final_t, r, cha_exp)
  end
  local v = sys.variant()
  final_t = sys.format("<c+:FFFFFF00>%s%s<c->", text, final_t)
  if data:has(packet.key.ui_text_targets) then
    local targets = data:get(packet.key.ui_text_targets)
    for i = 0, targets.size - 1 do
      local target = targets:get(i).v_int
      ui_chat.add_info(final_t, target)
    end
  else
    local targets = excel.targets
    for i = 0, targets.size - 1 do
      local target = targets[i]
      ui_chat.add_info(final_t, target)
    end
  end
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_marquee.packet_handle"
reg(packet.eSTC_UI_MarqueeTXT, on_show_marquee, sig)
reg(packet.eSTC_UI_Exp, on_show_exp, sig)
