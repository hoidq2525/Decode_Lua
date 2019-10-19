local logo_ids = 0
local cgchg = 0
local st = 0
local update_progress = false
local hide_scn_over = false
local use_taskbar_progress = false
function on_init(con)
  logo_ids = 0
  cgchg = 0
  st = 0
  update_progress = false
  hide_scn_over = false
  pall.visible = false
end
function on_loading_visible(ctrl, vis)
  if vis then
    update_tip()
    ui.log("on_loading_visible true")
    w_top.focus = true
  else
    ui.log("on_loading_visible false")
    ui_main.set_main_focus()
    st = 0
  end
end
local set_bg_rand = function()
  local dir
  local tick = math.floor(sys.tick() / 41)
  local mtick = math.mod(tick, 12)
  if mtick < 2 then
    dir = L("$icon/loading/chenkun")
  elseif mtick < 4 then
    dir = L("$icon/loading/chenkun1")
  elseif mtick < 6 then
    dir = L("$icon/loading/chenkun2")
  end
  if dir == nil or not sys.is_dir(dir) then
    local dirs = sys.get_dirs("$icon/loading")
    local cnt = dirs.size
    if cnt == 0 then
      return
    end
    dir = dirs:fetch_v(math.mod(tick, cnt)).v_string
  end
  local function set_item(x, y, n)
    local u = sys.format("%s/%d.dds", dir, n)
    if not sys.is_file(u) then
      u = sys.format("%s/%d.png", dir, n)
    end
    bg_rand:set_item(x, y, u)
  end
  bg_rand.visible = true
  pall.visible = false
  if sys.is_file(dir .. "/7.dds") or sys.is_file(dir .. "/7.png") then
    bg_rand:set_range(4, 2)
    set_item(0, 0, 0)
    set_item(1, 0, 1)
    set_item(2, 0, 2)
    set_item(3, 0, 3)
    set_item(0, 1, 4)
    set_item(1, 1, 5)
    set_item(2, 1, 6)
    set_item(3, 1, 7)
  else
    bg_rand:set_range(2, 2)
    set_item(0, 0, 0)
    set_item(1, 0, 1)
    set_item(0, 1, 2)
    set_item(1, 1, 3)
  end
end
function taskbar_show()
  use_taskbar_progress = true
  ui.set_taskbar_progress(2, 0)
end
function show_top(vis, show_type)
  if use_taskbar_progress then
    use_taskbar_progress = false
    ui.set_taskbar_progress(0, 0)
  end
  if vis then
    w_top.visible = true
    tmr_logo.suspended = false
    tmr_tip.suspended = false
    tmr_refresh.suspended = false
    tmr_speed.suspended = false
    bo2.qt_hide()
    ui.log("loading show")
  else
    ui.log("loading hide")
    w_top.visible = false
    w_progress.visible = false
    pall.visible = false
    tmr_logo.suspended = true
    tmr_tip.suspended = true
    tmr_refresh.suspended = true
    tmr_speed.suspended = true
    if sys.check(bo2.scn) then
      bo2.qt_show()
    end
  end
  w_msg_list:item_clear()
  ui_loading.w_continue_game.visible = false
  ui_loading.w_login_failed.visible = false
  ui_loading.w_disconnect.visible = false
  ui_loading.w_login_failed_return.visible = false
  if show_type == 1 then
    fg.image = ""
    mg.image = "$image/loading/loading001.png"
    bg.image = ""
    bg_rand.visible = false
    hide_scn()
  elseif show_type == 2 then
    fg.image = ""
    bg.image = ""
    set_bg_rand()
    hide_scn()
  else
    if show_type ~= nil then
      st = show_type
    end
    fg.image = ""
    mg.image = ""
    bg.image = "$image/loading/loading001.png"
    bg_rand.visible = false
  end
end
function loading_dlg(dlg)
  loading_insert = {
    contine_game = ui_loading.w_continue_game,
    login_failed = ui_loading.w_login_failed,
    disconnect = ui_loading.w_disconnect,
    login_failed_return = ui_loading.w_login_failed_return
  }
  ui.log(dlg)
  for k, v in pairs(loading_insert) do
    ui.log("%s %s", dlg, k)
    if dlg == k then
      v.visible = true
      if ui_queueing.gx_window.visible then
        ui_queueing.gx_window.visible = false
      end
    else
      v.visible = false
    end
  end
end
function btn_click(btn)
  local btn_func = {
    btn_continue_game = ui_startup.continue_game,
    btn_relogin_game = ui_phase.ui_startup.relogin_game,
    btn_login_retry = ui_phase.ui_startup.login_retry,
    btn_return_login = ui_phase.ui_startup.return_login,
    btn_disconnect = ui_phase.ui_startup.on_disconnnet_btn
  }
  local name = tostring(btn.name)
  for k, v in pairs(btn_func) do
    if name == k then
      v()
      if ui_queueing.gx_window.visible then
        ui_queueing.gx_window.visible = false
        ui_queueing.reset_time()
      end
      return
    end
  end
end
function set_progress(f)
  w_progress_picture.dx = f * 96 * progress_panel.dx / 128
  w_progress_picture.dy = progress_panel.dx / 4
  if use_taskbar_progress then
    ui.set_taskbar_progress(f * 1000, 1000)
  end
  update_progress = true
  w_progress.visible = true
  if w_top.visible then
    bo2.draw_gui()
  end
end
function do_logo_init()
  w_async_logo_top:control_clear()
  if not w_progress.visible then
    return
  end
  w_async_logo_top:load_style("$gui/phase/tool/loading.xml", "async_logo")
  local container = w_async_logo.container
  w_async_logo:invoke(function()
    container:load_style("$gui/phase/tool/loading.xml", "async_seq")
  end)
end
function on_progress_visible(ctrl, vis)
  if not vis then
    w_async_logo_top:control_clear()
  else
    ctrl:insert_post_invoke(do_logo_init, "do_logo_init")
  end
end
function insert_msg(msg, b_draw)
  local view = w_msg_list
  local size = view.item_count
  local item
  if size >= 1 then
    view:item_remove(0)
    item = view:item_append()
    item:load_style("$gui/phase/tool/loading.xml", "loading_item")
  else
    item = view:item_append()
    item:load_style("$gui/phase/tool/loading.xml", "loading_item")
  end
  local t = item:search("text")
  t.text = msg
  item:tune_y("text")
  if b_draw and w_top.visible then
    bo2.draw_gui()
  end
  return true
end
function setitemtext(text, pos)
  local view = w_msg_list
  local size = view.item_count
  if pos == nil then
    pos = size - 1
  end
  local item = view:item_get(pos)
  local t = item:search("text")
  t.text = text
  item:tune_y("text")
  if w_top.visible then
    bo2.draw_gui()
  end
end
function update_logo()
  logo_ids = logo_ids + 1
  if logo_ids > 19 then
    logo_ids = 0
  end
end
function update_tip()
  local excel_tip = bo2.gv_loading_tip
  if excel_tip == nil then
    bo2.output("excel_tip::nil")
  end
  local max_idx = excel_tip.size
  local rand_idx = bo2.rand(0, max_idx - 1)
  local line_data = excel_tip:get(rand_idx)
  if line_data ~= nil then
    tip.mtf = line_data.text
  end
end
function update_move()
  if st == -1 then
    return
  end
  cgchg = cgchg + 10
  if cgchg >= 150 then
    cgchg = 0
    if st ~= 2 then
      st = st + 1
      if st > 3 then
        st = 0
        update_progress = false
        hide_scn_over = false
        show_top(false)
      end
    end
  end
end
function hide_scn()
  cgchg = 0
  st = 1
  w_progress.visible = false
end
function show_scn()
  cgchg = 0
  st = 3
  fg.image = ""
  mg.image = "$image/loading/loading001.png"
  bg.image = ""
  bg_rand.visible = false
  w_progress.visible = false
  w_msg_list:item_clear()
end
function update_bg()
  if st < 1 or st > 3 then
    if st == -1 then
      return
    end
    w_top.visible = false
  end
  pall.dx = w_top.dx - w_top.dx / 120 * cgchg + 150
  pall.dy = w_top.dy
  mgpic.dx = w_top.dx
  mgpic.dy = w_top.dy
  logo_panel.dx = 128
  logo_panel.dy = logo_panel.dx
  progress_panel.dx = logo_panel.dx
  progress_panel.dy = progress_panel.dx / 4
  if st == 1 then
    mgpanel.dock = "pin_x1"
    mgpic.dock = "pin_x1"
    mgpanel.dx = w_top.dx / 120 * cgchg
    mgpanel.dy = w_top.dy
    if update_progress then
      w_progress.visible = true
    end
  elseif st == 2 then
    mgpanel.dx = w_top.dx
    mgpanel.dy = w_top.dy
    if w_top ~= nil and w_top.visible == true then
      hide_scn_over = true
    end
    if update_progress then
      w_progress.visible = true
    end
    pall.visible = false
  else
    mgpanel.dock = "pin_x2"
    mgpic.dock = "pin_x2"
    mgpanel.dx = w_top.dx - w_top.dx / 120 * cgchg
    mgpanel.dy = w_top.dy
    w_progress.visible = false
    w_msg_list:item_clear()
    pall.visible = true
  end
end
