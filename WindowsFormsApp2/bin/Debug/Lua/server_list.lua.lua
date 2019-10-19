function create_gzs_list(list)
  server_list_update(list)
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
local server_item_uri = SHARED("$gui/phase/choice1/choice.xml")
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
  local info = player_select_info.info
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
function on_channel_choose_msg_callback(msg)
  if msg.result == 0 then
    return
  end
  local item_sel = w_server_list.item_sel
  if item_sel == nil then
    ui_tool.note_insert(ui.get_text("phase|choice_line"), ui.make_color("FF0000"))
    return
  end
  player_select_info.line = item_sel.svar.server_data.id
  send_enter_game()
end
