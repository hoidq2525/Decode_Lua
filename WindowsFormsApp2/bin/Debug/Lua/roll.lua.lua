g_time = 20
g_total_time = g_time * 1000
g_allrolls = {}
g_msg_data = nil
g_second_confirm_list = {}
g_vis_roll = false
g_roll_index = 1
function insert_second_confirm_data(obj_handle, idx, excel_id)
  if obj_handle ~= nil and idx ~= nil and excel_id ~= nil then
    local text = obj_handle .. idx .. excel_id
    g_second_confirm_list[text] = 1
  end
end
function remove_second_confirm_data(obj_handle, idx, excel_id)
  if obj_handle ~= nil and idx ~= nil and excel_id ~= nil then
    local text = obj_handle .. idx .. excel_id
    g_second_confirm_list[text] = nil
  end
end
function check_may_second_confirm(obj_handle, idx, excel_id)
  if obj_handle ~= nil and idx ~= nil and excel_id ~= nil then
    local text = obj_handle .. idx .. excel_id
    if g_second_confirm_list[text] ~= nil then
      return false
    end
  end
  return true
end
function set_visible(vis)
  w_main.visible = vis
  if not vis then
    w_divider3.visible = false
    w_divider6.visible = false
    ui_npcfunc.ui_roll.w_timer.suspended = true
  end
end
function find_data_by_index(_index)
  for i, v in ipairs(g_allrolls) do
    if v.client_index == _index then
      return v
    end
  end
end
function remove_data_by_index(_index)
  for i, v in ipairs(g_allrolls) do
    if v.client_index == _index then
      table.remove(g_allrolls, i)
    end
  end
end
function update_cell_runtime_data(cell, t)
  local w_show_lb = cell:search("w_show_lb")
  local w_fig = cell:search("w_fig")
  local w_bg = cell:search("w_bg")
  local iTime = t.iTime
  local l = math.floor(iTime / 1000)
  w_show_lb.text = l
  w_fig.dx = w_bg.dx * ((iTime - 1000) / (g_time * 1000))
end
function show_cell_item(cell, t)
  cell.visible = true
  cell.var:set(packet.key.cmn_index, t.client_index)
  local excel = ui.item_get_excel(t.id)
  local w_card = cell:search("card")
  local w_num = cell:search("num")
  local w_name = cell:search("item_lb_name")
  local w_title = cell:search("lb_title")
  w_card.excel_id = t.id
  w_num.text = sys.format("x%d", t.count)
  w_name.text = excel.name
  w_title.text = excel.name
  local color = ui_tool.cs_tip_color_white
  if excel ~= nil and excel.plootlevel_star then
    color = excel.plootlevel_star.color
  end
  w_name.color = ui.make_color(color)
  update_cell_runtime_data(cell, t)
  w_timer.suspended = false
end
function update_show()
  local table_size = #g_allrolls
  if table_size == 0 then
    set_visible(false)
    return
  end
  set_visible(true)
  local divider_vis = function(type)
    if type <= 3 then
      w_divider3.visible = true
      w_divider6.visible = false
    else
      w_divider3.visible = false
      w_divider6.visible = true
    end
  end
  divider_vis(table_size)
  local divder
  local iCount = 3
  if table_size > 3 then
    divder = ui_npcfunc.ui_roll.w_divider6
    iCount = 6
  else
    divder = ui_npcfunc.ui_roll.w_divider3
  end
  if divder == nil then
    return
  end
  for i = 1, iCount do
    local cell_item = divder:search(sys.format(L("%d"), i))
    if sys.check(cell_item) then
      cell_item.visible = false
      cell_item.var:set(packet.key.cmn_index, 0)
    end
  end
  local cell_index = 1
  for i, v in ipairs(g_allrolls) do
    local cell_name = sys.format(L("%d"), cell_index)
    local cell_item = divder:search(cell_name)
    if sys.check(cell_item) then
      show_cell_item(cell_item, v)
    end
    cell_index = cell_index + 1
    if iCount < cell_index then
      break
    end
  end
end
function send_require(t)
  local v = sys.variant()
  v:set(packet.key.cmn_index, t.cmnindex)
  v:set(packet.key.scnobj_handle, t.handle)
  v:set(packet.key.item_excelid, t.id)
  v:set(packet.key.item_count, t.count)
  v:set(packet.key.cmn_agree_ack, 1)
  bo2.send_variant(packet.eCTS_UI_RollItem, v)
  insert_second_confirm_data(t.handle, t.cmnindex, t.id)
  remove_data_by_index(t.client_index)
  update_show()
end
function send_giveup(t)
  local v = sys.variant()
  v:set(packet.key.cmn_index, t.cmnindex)
  v:set(packet.key.scnobj_handle, t.handle)
  v:set(packet.key.item_excelid, t.id)
  v:set(packet.key.item_count, t.count)
  v:set(packet.key.cmn_agree_ack, 0)
  bo2.send_variant(packet.eCTS_UI_RollItem, v)
  remove_data_by_index(t.client_index)
  update_show()
end
function on_timer(timer)
  if #g_allrolls == 0 then
    set_visible(false)
    return
  end
  for i, v in ipairs(g_allrolls) do
    v.iTime = v.iTime - timer.period
    if v.iTime <= timer.period then
      send_giveup(v)
    end
  end
  local divder
  local iCount = 0
  if w_divider3.visible == true then
    divder = w_divider3
    iCount = 3
  elseif w_divider6.visible == true then
    iCount = 6
    divder = w_divider6
  end
  if divder == nil then
    return
  end
  for i = 1, iCount do
    local cell_item = divder:search(sys.format(L("%d"), i))
    if sys.check(cell_item) and cell_item.visible == true then
      local client_index = cell_item.var:get(packet.key.cmn_index).v_int
      local t = find_data_by_index(client_index)
      if t ~= nil then
        update_cell_runtime_data(cell_item, t)
      end
    end
  end
end
function on_esc_stk_visible(w, vis)
end
function on_require_click(btn)
  local cell_parent = btn.topper
  local client_index = cell_parent.var:get(packet.key.cmn_index).v_int
  local t = find_data_by_index(client_index)
  if t == nil then
    return
  end
  local excel = ui.item_get_excel(t.id)
  local notify_b = bo2.gv_define:find(373)
  if excel ~= nil and ui_item.check_excel_will_bound_item(excel, bo2.eItemBoundMod_Acquire) and excel.lootlevel >= notify_b.value.v_int and check_may_second_confirm(t.handle, t.cmnindex, t.id) and ui_item.need_show_bound_ui(t.id) then
    local item_name = sys.format("<i:%d>", excel.id)
    local arg = sys.variant()
    arg:set("item_name", item_name)
    g_msg_data = {
      text = sys.mtf_merge(arg, ui.get_text("item|bound_acquire")),
      callback = function(ret)
        if ret.result ~= 1 then
          return
        end
        send_require(t)
      end
    }
    ui_widget.ui_msg_box.show_common(g_msg_data)
  else
    send_require(t)
  end
end
function on_giveup_click(btn)
  local cell_parent = btn.topper
  local client_index = cell_parent.var:get(packet.key.cmn_index).v_int
  local t = find_data_by_index(client_index)
  if t == nil then
    return
  end
  send_giveup(t)
end
function on_close_click(btn)
  local cell_parent = btn.topper
  local client_index = cell_parent.var:get(packet.key.cmn_index).v_int
  local t = find_data_by_index(client_index)
  if t == nil then
    return
  end
  local function add_show_msg()
    local function on_msg_callback(msg)
      if msg.result ~= 1 then
        return
      end
      send_giveup(t)
    end
    local arg = sys.variant()
    arg:set("item_id", t.id)
    local txt_note = sys.mtf_merge(arg, ui.get_text("npcfunc|roll_item_confirm"))
    local msg = {
      callback = on_msg_callback,
      text = sys.format(txt_note)
    }
    ui_widget.ui_msg_box.show_common(msg)
  end
  add_show_msg()
end
function runf()
  local v = sys.variant()
  v:set(packet.key.item_excelid, 58422)
  v:set(packet.key.item_count, 1)
  v:set(packet.key.scnobj_handle, 1)
  v:set(packet.key.cmn_index, 1)
  on_roll(0, v)
end
function on_roll(cmd, data)
  local _id = data:get(packet.key.item_excelid).v_int
  local excel = ui.item_get_excel(_id)
  if excel == nil then
    return
  end
  local t = {
    id = _id,
    count = data:get(packet.key.item_count).v_int,
    handle = data:get(packet.key.scnobj_handle).v_int,
    cmnindex = data:get(packet.key.cmn_index).v_int,
    iTime = g_total_time,
    client_index = g_roll_index
  }
  g_roll_index = g_roll_index + 1
  table.insert(g_allrolls, t)
  update_show()
end
function on_pickup_item(cmd, data)
  local item_excelid = data:get(packet.key.item_excelid).v_int
  local text_id = data:get(packet.key.ui_text_id).v_int
  local cmn_idx = data:get(packet.key.cmn_index).v_int
  local obj = data:get(packet.key.scnobj_handle).v_int
  local count = data:get(packet.key.item_count).v_int
  local v_param = sys.variant()
  if data:has("item_name") then
    v_param:set("item_name", data:get("item_name"))
  elseif count > 1 then
    v_param:set(L("item_name"), sys.format(L("<i:%d> x %d"), item_excelid, count))
  else
    v_param:set(L("item_name"), sys.format(L("<i:%d> x %d"), item_excelid, count))
  end
  local color
  if text_id == 1529 then
  elseif text_id == 10174 then
    v_param:set(L("cha_name"), data:get(packet.key.cha_name).v_string)
  elseif text_id == 10101 and bo2.player then
    v_param:set(L("cha_name"), bo2.player.name)
  end
  local v_data = sys.variant()
  v_data:set(packet.key.ui_text_id, text_id)
  v_data:set(packet.key.ui_text_arg, v_param)
  ui_chat.show_ui_text(cmd, v_data)
  remove_second_confirm_data(obj, cmn_idx, item_excelid)
end
function on_self_enter()
  g_second_confirm_list = {}
end
local sig_name = "ui_npcfunc.ui_roll.on_roll"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_ChestRoll, on_roll, sig_name)
sig_name = "ui_npcfunc.ui_roll.on_pickup_item"
ui_packet.recv_wrap_signal_insert(packet.eSTC_ExcuteItemPickupResult, on_pickup_item, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_npcfunc.ui_roll.on_self_enter")
