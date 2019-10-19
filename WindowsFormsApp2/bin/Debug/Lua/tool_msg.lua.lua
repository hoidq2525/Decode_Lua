if msg_window_id == nil then
  msg_window_id = 0
end
if msg_queue == nil then
  msg_queue = {}
end
local c_state_queue = 1
local c_state_show = 2
local c_state_invoke = 3
function show_msg(data)
  data.window = w_msg_common
  if data.detail == nil then
    data.detail = L("msg_cmn_input")
  end
  if data.detail_uri == nil then
    data.detail_uri = L("$gui/phase/tool/tool_msg.xml")
  end
  msg_window_id = msg_window_id + 1
  data.id = msg_window_id
  if data.result == nil then
    data.result = 0
  end
  if data.btn_confirmtext == nil then
    data.btn_confirmtext = ui.get_text("tool|msg_confirm")
  end
  if data.btn_canceltext == nil then
    data.btn_canceltext = ui.get_text("tool|msg_cancel")
  end
  msg_queue_insert(data)
  msg_show_top()
end
function msg_toggle_button(data, name, def)
  local btn = data[name]
  if btn == nil then
    data.window:search(name).visible = def
  elseif btn then
    data.window:search(name).visible = true
  else
    data.window:search(name).visible = false
  end
end
function msg_queue_insert(data)
  table.insert(msg_queue, data)
  data.state = c_state_queue
end
function msg_queue_remove(data)
  for i, v in ipairs(msg_queue) do
    if data == v then
      table.remove(msg_queue, i)
      break
    end
  end
end
function msg_show_top()
  if table.maxn(msg_queue) == 0 then
    return
  end
  local data
  while table.maxn(msg_queue) > 0 do
    data = msg_queue[1]
    if sys.check(data.window) then
      break
    end
    table.remove(msg_queue, 1)
  end
  local data = msg_queue[1]
  if data == nil then
    ui.log("bad msg_queue, not found head data.")
    return
  end
  if data.state ~= 1 then
    return
  end
  data.state = 2
  local window = data.window
  window.visible = false
  window.var:set("msg_id", data.id)
  window:search("lb_title").text = data.title
  if data.text ~= nil then
    window:search("rv_text").mtf = data.text
  end
  w_msg_detail:control_clear()
  w_msg_detail:load_style(data.detail_uri, data.detail)
  w_msg_detail.visible = true
  data.detail = w_msg_detail
  local frm_input = window:search("frm_input")
  if frm_input ~= nil then
    if data.input ~= nil then
      frm_input.visible = true
      local input = frm_input:search("box_input")
      input.focus = true
      input.text = data.input
      if data.limit ~= nil then
        input.limit = data.limit
      else
        input.limit = -1
      end
    else
      frm_input.visible = false
      w_msg_detail.visible = false
    end
  end
  msg_toggle_button(data, "btn_confirm", true)
  msg_toggle_button(data, "btn_cancel", true)
  msg_toggle_button(data, "btn_close", false)
  data.window:search("btn_confirm").text = data.btn_confirmtext
  data.window:search("btn_cancel").text = data.btn_canceltext
  if data.modal == nil then
    data.modal = true
  end
  if data.modal then
    w_msg_bg.visible = true
  else
    w_msg_bg.visible = false
  end
  w_msg_top.visible = true
  window.visible = true
  w_msg_top.size = w_msg_top.parent.size
  w_msg_top:apply_dock(false)
  ui.post_mouse_move()
end
function msg_get_data(ctrl)
  local p = ctrl.topper
  if p == nil then
    return nil
  end
  local msg_id = p.var:get("msg_id").v_int
  local data
  for i, v in ipairs(msg_queue) do
    if v.id == msg_id then
      data = v
      break
    end
  end
  return data
end
function msg_hide_window(data)
  local window = data.window
  if not sys.check(window) then
    return
  end
  if not window.visible then
    return
  end
  local id = window.var:get("msg_id").v_int
  if id == data.id then
    window.var:set("msg_id", 0)
    w_msg_bg.visible = false
    w_msg_top.visible = false
    window.visible = false
    w_msg_top:insert_post_invoke(msg_show_top, "ui_tool.show_next_msg")
  end
end
function msg_invoke(data)
  msg_queue_remove(data)
  if data.state == c_state_invoke then
    msg_hide_window(data)
    return
  end
  data.state = c_state_invoke
  msg_hide_window(data)
  if data.callback ~= nil then
    data.callback(data)
  end
end
local s_rv_text = SHARED("rv_text")
function tip_try_tune(view, dx, dy)
  view.dx = dx
  view:tune_y(s_rv_text)
  if dy < view.dy then
    return false
  end
  return true
end
function on_msg_visible(ctrl, vis)
  local data = msg_get_data(ctrl)
  if data == nil then
    return
  end
  local function tune()
    local d = msg_get_data(ctrl)
    if d ~= data then
      return
    end
    local w = data.window
    local r = w:search(s_rv_text)
    if r == nil then
      return
    end
    w.size = ui.point(200, 800)
    r.dock = "fill_xy"
    if not tip_try_tune(w, 200, 200) and not tip_try_tune(w, 240, 240) and not tip_try_tune(w, 320, 320) and not tip_try_tune(w, 400, 400) then
      tip_try_tune(w, 600, 600)
    end
    r.dock = "pin_y1"
    r.size = r.extent
  end
  if vis then
    if data.text ~= nil then
      ctrl:insert_post_invoke(tune, "ui_tool.on_msg_visible")
    end
  else
    w_msg_bg.visible = false
    w_msg_top.visible = false
    msg_invoke(data)
    w_msg_top:insert_post_invoke(msg_show_top, "ui_tool.show_next_msg")
  end
end
function on_msg_confirm_click(btn)
  local data = msg_get_data(btn)
  if data == nil then
    return
  end
  if data.input ~= nil then
    local frm_input = data.window:search("frm_input")
    if frm_input ~= nil then
      data.input = frm_input:search("box_input").text
    end
  end
  data.result = 1
  msg_invoke(data)
end
function on_msg_cancel_click(btn)
  local data = msg_get_data(btn)
  if data == nil then
    return
  end
  data.result = 0
  msg_invoke(data)
end
function on_test_msg_click(btn)
  show_msg({
    text = L("haiegqr"),
    btn_close = true
  })
  show_msg({
    text = L("haiegqr2"),
    btn_close = true,
    input = "hello"
  })
  show_msg({
    text = "money and number",
    detail = "money_and_number_input"
  })
  show_msg({
    text = "money input",
    detail = "money_input"
  })
end
