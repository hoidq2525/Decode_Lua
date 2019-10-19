local c_state_queue = 1
local c_state_show = 2
local c_state_invoke = 3
local c_state_finish = 4
function init()
  msg_window_id = 0
  msg_queue = {}
  msg_modal_bg = ui.create_control(ui_phase.w_tool, "panel")
  msg_modal_bg:load_style("$widget/msg_box.xml", "cmn_msg_box_modal_bg")
  msg_basic_bg = ui.create_control(ui_phase.w_tool)
  msg_basic_bg:load_style("$widget/msg_box.xml", "cmn_msg_box_basic_bg")
  msg_post_util = ui.create_control(ui_phase.w_tool, "panel")
  msg_post_util.visible = false
end
function show(data)
  if (data.style_uri == nil or data.style_name == nil) and data.window == nil then
    error("bad input data for msg_box")
    return
  end
  msg_window_id = msg_window_id + 1
  data.id = msg_window_id
  data.internal = {}
  local owner = data.owner
  if owner == nil then
    w = data.window
    if w ~= nil then
      owner = w.parent
    end
  end
  if owner == nil and ui_phase.w_main ~= nil then
    if ui_phase.w_main.visible then
      owner = ui_phase.w_main
    elseif ui_phase.w_choice.visible then
      owner = ui_phase.w_choice
    elseif ui_phase.w_startup.visible then
      owner = ui_phase.w_startup
    end
  end
  if owner ~= nil then
    data.owner = owner
    local oc = owner.svar.msg_box_owner_close
    if oc == nil then
      oc = ui.create_control(owner)
      oc:insert_on_close(on_owner_close, "ui_widget.ui_msg_box.on_owner_close")
      oc:insert_on_close(on_owner_visible, "ui_widget.ui_msg_box.on_owner_visible")
      owner.svar.msg_box_owner_close = oc
      oc.svar.parent = owner
    end
  end
  if data.result == nil then
    data.result = 0
  end
  if data.modal == nil then
    data.modal = true
  end
  if not data.modal then
    show_top(data)
    return
  end
  queue_insert(data)
  if #msg_queue == 1 then
    show_top()
  end
end
function show_common(data)
  local orig_init = data.init
  local function common_init(d)
    do_common_init(d, orig_init)
  end
  data.init = common_init
  local orig_callback = data.callback
  local function common_callback(d)
    do_common_callback(d, orig_callback)
  end
  data.callback = common_callback
  if data.text_confirm == nil then
    data.text_confirm = ui.get_text("widget|msgbox_confirm")
  end
  if data.text_cancel == nil then
    data.text_cancel = ui.get_text("widget|msgbox_cancel")
  end
  if data.window == nil and data.style_uri == nil and data.style_name == nil then
    data.style_uri = L("$widget/msg_box.xml")
    data.style_name = L("cmn_msg_box_common")
  end
  if data.close_on_leavascn == nil then
    data.close_on_leavascn = false
  end
  show(data)
end
function common_toggle_button(data, name, def)
  local p = data.window:search(name)
  if p == nil then
    return
  end
  local btn = data[name]
  if btn == nil then
    p.visible = def
  elseif btn then
    p.visible = true
  else
    p.visible = false
  end
end
function do_common_init(data, orig_init)
  local window = data.window
  if data.title ~= nil then
    local lb_title = window:search("lb_title")
    if lb_title ~= nil then
      lb_title.text = data.title
    end
  end
  if data.text ~= nil then
    local rv_text = window:search("rv_text")
    local font = data.font
    if font ~= nil then
      rv_text.font = font
    end
    rv_text.mtf = data.text
  end
  local frm_input = window:search("frm_input")
  while frm_input ~= nil do
    if data.input == nil then
      frm_input.visible = false
      break
    end
    frm_input.visible = true
    local input = frm_input:search("box_input")
    if data.input_unfocus == nil then
      input.focus = true
    end
    local text = L(data.input)
    input.text = text
    input:select(0, text.size)
    if data.limit ~= nil then
      input.limit = data.limit
    else
      input.limit = -1
    end
    input.number_only = data.number_only
    break
  end
  if data.btn2 ~= nil and data.btn2 == true then
    local btn_confirm = window:search("btn_confirm")
    local btn_cancel = window:search("btn_cancel")
    btn_confirm.visible = false
    btn_cancel.visible = false
    local btn_confirm2 = window:search("btn_confirm2")
    btn_confirm2.visible = true
    btn_confirm2.text = data.text_confirm
    local btn_cancel2 = window:search("btn_cancel2")
    btn_cancel2.visible = true
    btn_cancel2.text = data.text_cancel
  else
    common_toggle_button(data, "btn_confirm", true)
    common_toggle_button(data, "btn_cancel", true)
    common_toggle_button(data, "btn_close", true)
    local btn_confirm2 = window:search("btn_confirm2")
    if btn_confirm2 then
      btn_confirm2.visible = false
    end
    local btn_cancel2 = window:search("btn_cancel2")
    if btn_cancel2 then
      btn_cancel2.visible = false
    end
  end
  common_tune(data)
  if orig_init ~= nil then
    orig_init(data)
  end
end
function do_common_callback(data, orig_callback)
  if data.input ~= nil then
    local frm_input = data.window:search("frm_input")
    if frm_input ~= nil then
      data.input = frm_input:search("box_input").text
    end
  end
  if orig_callback ~= nil then
    orig_callback(data)
  end
end
local s_rv_text = SHARED("rv_text")
function common_try_tune(view, dx, dy)
  view.dx = dx
  view:tune_y(s_rv_text)
  if dy < view.dy then
    return false
  end
  return true
end
function common_tune(data)
  local tune = data.tune_window
  if tune ~= nil then
    tune(data)
    return
  end
  local w = data.window
  local r = w:search(s_rv_text)
  if r == nil then
    return
  end
  w.size = ui.point(300, 800)
  r.dock = "fill_xy"
  if not common_try_tune(w, 276, 200) and not common_try_tune(w, 320, 240) and not common_try_tune(w, 360, 320) and not common_try_tune(w, 400, 400) then
    common_try_tune(w, 600, 600)
  end
  if w.dy < 160 then
    w.dy = 160
  end
  r.dock = "pin_xy"
  r.size = r.extent
end
function queue_insert(data)
  table.insert(msg_queue, data)
  data.state = c_state_queue
end
function queue_remove(data)
  for i, v in ipairs(msg_queue) do
    if data == v then
      table.remove(msg_queue, i)
      return true
    end
  end
  return false
end
function on_owner_close(w)
  local p = w.svar.parent
  if p == nil then
    return
  end
  while #msg_queue > 0 do
    local d
    for i, v in ipairs(msg_queue) do
      if v.owner == p then
        d = v
        break
      end
    end
    if d == nil then
      break
    end
    cancel(d)
  end
end
function on_owner_visible(w, vis)
  if vis then
    return
  end
  on_owner_close(w)
end
function show_top(data)
  local in_queue
  if data == nil then
    data = msg_queue[1]
    in_queue = true
  else
    in_queue = false
  end
  local window, internal, bg
  while data ~= nil do
    window = data.window
    internal = data.internal
    if data.modal ~= nil and data.modal then
      bg = msg_modal_bg
    else
      bg = msg_basic_bg
    end
    if sys.check(window) then
      local parent = window.parent
      internal.window_create = false
      internal.window_parent = parent
      window.parent = bg
      if data.style_uri ~= nil and data.style_name ~= nil then
        window:load_style(data.style_uri, data.style_name)
      end
      break
    else
      internal.window_create = true
      if data.style_uri ~= nil and data.style_name ~= nil then
        window = ui.create_control(bg)
        data.window = window
        window:load_style(data.style_uri, data.style_name)
        break
      else
        ui.log("bad msg_box style.")
      end
    end
    if not in_queue then
      return
    end
    table.remove(msg_queue, 1)
    data = msg_queue[1]
  end
  if data == nil then
    return
  end
  if data.modal and data.state ~= c_state_queue then
    return
  end
  data.state = 2
  bg.visible = false
  window.visible = false
  window.svar.msg_box_data = data
  bg.visible = true
  bg.size = bg.parent.size
  bg.focus = true
  window:insert_on_visible(on_window_visible, "ui_widget.ui_msg_box.on_window_visible")
  if data.close_on_leavascn == true then
    window:insert_on_visible(ui_widget.on_leavescn_stk_visible, "ui_widget.on_leavescn_stk_visible")
  end
  window.visible = true
  bg:apply_dock(false)
  local init = data.init
  if init ~= nil then
    sys.pcall(init, data)
  end
  if data.on_show then
    data.on_show(data)
  end
  local show_sound = data.show_sound
  if show_sound ~= nil then
    bo2.PlaySound2D(show_sound)
  end
  ui.post_mouse_move()
end
function next_show_top()
  msg_post_util:control_clear()
  show_top()
end
function util_clear()
  msg_post_util:control_clear()
end
function hide(data)
  local window = data.window
  if not sys.check(window) then
    return
  end
  local d = window.svar.msg_box_data
  if d ~= data then
    return
  end
  window.svar.msg_box_data = nil
  window.visible = false
  if data.internal.window_create then
    window.parent = msg_post_util
    msg_post_util:insert_post_invoke(util_clear, "ui_widget.ui_msg_box.util_clear")
  else
    window.parent = data.window_parent
  end
  if data.modal then
    msg_modal_bg.visible = false
  elseif msg_basic_bg.control_head == nil then
    msg_basic_bg.visible = false
  end
  local hide_sound = data.hide_sound
  if hide_sound ~= nil then
    bo2.PlaySound2D(hide_sound)
  end
end
function invoke(data)
  queue_remove(data)
  if data.state == c_state_finish then
    return
  end
  if data.modal then
    local d = msg_queue[1]
    if d ~= nil then
      msg_post_util:insert_post_invoke(next_show_top, "ui_widget.ui_msg_box.next_show_top")
    end
  end
  if data.state == c_state_invoke then
    hide(data)
    return
  end
  data.state = c_state_invoke
  hide(data)
  if data.callback ~= nil then
    sys.pcall(data.callback, data)
    data.state = c_state_finish
  end
end
function cancel(data)
  queue_remove(data)
  data.state = c_state_invoke
  hide(data)
end
function get_data(ctrl)
  local p = ctrl.topper
  if p == nil then
    return nil
  end
  local data = p.svar.msg_box_data
  return data
end
function on_bg_visible(ctrl, vis)
  if vis then
    ctrl.svar.msg_bg_default_focus = ui.get_default_focus()
    ui.set_default_focus(ctrl)
  elseif ui.get_default_focus() == ctrl then
    ui.set_default_focus(ctrl.svar.msg_bg_default_focus)
    ctrl.svar.msg_bg_default_focus = nil
  end
end
function on_bg_key(w, key, flag)
  if flag.down then
    return
  end
  local data = msg_queue[1]
  if data == nil then
    return
  end
  if key == ui.VK_RETURN then
    data.result = 1
    data.is_input_enter = 1
    invoke(data)
  elseif key == ui.VK_ESCAPE then
    data.result = 0
    invoke(data)
  end
end
function on_input_enter(w)
  local data = get_data(w)
  if data == nil then
    w.visible = false
    return
  end
  data.result = 1
  data.is_input_enter = 1
  invoke(data)
end
function on_input_key(w, key, flag)
  if flag.down then
    return
  end
  local data = get_data(w)
  if data == nil then
    w.visible = false
    return
  end
  if key == ui.VK_ESCAPE then
    data.result = 0
    invoke(data)
  end
end
function on_window_visible(ctrl, vis)
  local data = get_data(ctrl)
  if data == nil then
    return
  end
  if not vis then
    invoke(data)
  end
end
function on_confirm_click(btn)
  local data = get_data(btn)
  if data == nil then
    return
  end
  data.result = 1
  invoke(data)
end
function on_cancel_click(btn)
  local data = get_data(btn)
  if data == nil then
    return
  end
  data.result = 0
  invoke(data)
end
function on_timer(t)
  local data = get_data(t.owner)
  if data == nil then
    return
  end
  if data.timeout == nil then
    return
  end
  if data.timestart == nil then
    data.timestart = sys.tick()
    return
  end
  if sys.dtick(sys.tick(), data.timestart) < data.timeout then
    return
  end
  data.result = 0
  invoke(data)
end
function test()
  show_common({text = "haha"})
end
function test2()
  show_common({text = "haha", modal = false})
end
