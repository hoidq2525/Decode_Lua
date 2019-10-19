local g_charactor_view_type = 0
local g_charactor_name
local g_history_name_data = {}
local item_uri = "$gui/frame/im/history_name.xml"
local item_style = L("item_history_name")
function init_global_data()
  g_charactor_view_type = 0
  g_charactor_name = nil
  g_history_name_data = {}
end
function on_init_list_data()
  local lt
  if g_charactor_view_type ~= 0 then
    lt = ui_im.self_history:search("lt_name")
  else
    lt = w_main:search("lt_name")
  end
  if sys.check(lt) ~= true then
    return nil
  end
  lt:item_clear()
  return lt
end
function on_show_list()
  local packet_data = g_history_name_data.data
  if sys.check(packet_data) ~= true then
    return
  end
  local lt = on_init_list_data()
  if lt == nil then
    return
  end
  local function app_item(id, name, time)
    local app_item = lt:item_append()
    app_item:load_style(item_uri, item_style)
    local mtf_data = {}
    mtf_data.id = id
    mtf_data.year = os.date("%Y", time)
    mtf_data.month = os.date("%m", time)
    mtf_data.day = os.date("%d", time)
    mtf_data.hour = os.date("%H", time)
    mtf_data.minute = os.date("%M", time)
    mtf_data.name = name
    local rb_desc = app_item:search("rb_item_name")
    rb_desc.mtf = ui_widget.merge_mtf(mtf_data, ui.get_text("im|history_name_mtf"))
  end
  local packet_size = packet_data.size
  for i = 0, packet_size - 1 do
    local n, v = packet_data:fetch_nv(i)
    if sys.check(v) then
      local idx = i + 1
      local name = v:get(packet.key.cha_name).v_string
      local time = v:get(packet.key.org_time).v_int
      app_item(idx, name, time)
    end
  end
end
function on_vis_send_packet()
  local v = sys.variant()
  if g_charactor_name ~= nil then
    v:set(packet.key.cha_onlyid, g_charactor_name)
  end
  bo2.send_variant(packet.eCTS_Sociality_ViewHistoryName, v)
end
function on_esc_stk_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis then
  else
  end
end
function view_self_history_name()
  if sys.check(bo2.player) ~= true then
    return
  end
  set_history_name_visible(0, bo2.player.name)
end
function set_history_name_visible(view_type, name)
  g_charactor_view_type = view_type
  if g_charactor_view_type ~= 0 then
    on_init_list_data()
  end
  g_charactor_name = name
  local lb_title = w_main:search("lb_title")
  lb_title.text = ui_widget.merge_mtf({cha_name = name}, ui.get_text("im|history_name_title"))
  on_vis_send_packet()
end
function on_click_confirm()
  w_main.visible = false
end
function on_handle_view_history_name(cmd, data)
  if data.size >= 1 then
    g_history_name_data.data = data
    if g_charactor_view_type == 0 then
      w_main.visible = true
    end
    on_show_list()
  elseif g_charactor_view_type == 0 and sys.check(g_charactor_name) and sys.check(bo2.player) and g_charactor_name ~= bo2.player.name then
    local text = ui_widget.merge_mtf({cha_name = g_charactor_name}, ui.get_text("im|no_history_name"))
    ui_tool.note_insert(text, "FFFF0000")
  end
end
local sig_name = "ui_history_name:on_handle_view_history_name"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Sociality_ViewHistoryName, on_handle_view_history_name, sig_name)
function on_self_enter()
  init_global_data()
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_history_name.on_self_enter")
