g_new_refresh = true
function on_timer_refresh()
  if ui_gift_award.w_http_win.visible ~= true then
    req()
  end
end
function on_http_visible(p, v)
  ui_widget.on_esc_stk_visible(p, v)
  if v == true then
    g_new_refresh = false
    req()
  end
end
function r()
  w_http_win_edit.visible = true
  w_input.text = ui.get_text("event|today_ann")
end
function edit()
  g_scroll = w_http_ann.slider_y.scroll
end
function on_submit_click()
  local g_scroll = w_http_ann.slider_y.scroll
  w_http_ann.mtf = w_input.text
  w_http_ann.slider_y.scroll = g_scroll
end
function switch_mutex_windown(type)
  local g_window = {}
  g_window[0] = {w_http_list, w_http_list_bg}
  g_window[1] = {w_http_info}
  local switch = function(window, vis)
    for i, v in pairs(window) do
      if sys.check(v) then
        v.visible = vis
      end
    end
  end
  switch(g_window[0], false)
  switch(g_window[1], false)
  switch(g_window[type], true)
end
function on_click_announ()
  switch_mutex_windown(1)
end
function on_click_event()
  switch_mutex_windown(0)
end
function on_mouse_pic(p, msg)
  if msg == ui.mouse_lbutton_click then
    local parent = p.parent
    local btn = parent:search(L("btn_detail"))
    if sys.check(btn) then
      open_html_page(btn)
    end
  end
end
function on_fn_refresh_image(v)
  local item_name = sys.format(L("item%d"), v.index)
  local item = w_http_list:search(item_name)
  if item == nil then
    return
  end
  local pic = item:search("pic")
  local item_image = sys.format(L("$cfg/client/user/http/image/%s|0,0,272,122"), v.file_name)
  pic.image = item_image
end
function on_fn_refresh_text(v)
  if v.key ~= L("event") then
    return
  end
  local set_item_text = function(i)
    local item_name = sys.format(L("item%d"), i)
    local item = w_http_list:search(item_name)
    if item == nil then
      return false
    end
    local btn_detail = item:search(L("btn_detail"))
    btn_detail.visible = true
    local title_text = sys.format(L("event|item_title%d"), i)
    local c_title = item:search(L("title"))
    if sys.check(c_title) then
      c_title.mtf = ui.get_text(title_text)
    end
    local tip_text = sys.format(L("event|item_pic%d"), i)
    local c_pic = item:search(L("pic"))
    c_pic.tip.text = ui.get_text(tip_text)
    local detail_text = sys.format(L("event|item_detail%d"), i)
    local c_detail = item:search(L("detail"))
    if sys.check(c_detail) then
      c_detail.mtf = ui.get_text(detail_text)
      c_detail.slider_y.scroll = 0
    end
    local detail_url = sys.format(L("event|item_detail_url%d"), i)
    local btn_url = item:search(L("btn_detail"))
    if sys.check(btn_url) then
      btn_url.svar.url = ui.get_text(detail_url)
    end
    return true
  end
  w_http_ann.mtf = ui.get_text("event|today_ann")
  w_http_ann.slider_y.scroll = 0
  w_http_ann_detail.svar.url = ui.get_text("event|ann_detail_url")
  btn_more_event.svar.url = ui.get_text("event|more_event_url")
  for i = 0, 2 do
    if set_item_text(i) ~= true then
      return
    end
  end
end
function open_html_page(btn)
  if sys.check(btn) ~= true then
    return
  end
  if btn.svar.url == nil then
    return
  end
  if btn.svar.url.size <= 5 then
    return
  end
  ui.shell_execute("open", btn.svar.url)
end
function get_define_string(id)
  local x = bo2.gv_define:find(id)
  if x == nil then
    return L("")
  end
  return x.value
end
function req()
  local req = {}
  local server_id = bo2.player:GetPlayerServerID()
  local g_beta_sever = {}
  g_beta_sever[110] = 1
  g_beta_sever[111] = 1
  if g_beta_sever[server_id] ~= nil then
    req.url = get_define_string(1125)
    req.default_url = get_define_string(1126)
  else
    req.url = get_define_string(1123)
    req.default_url = get_define_string(1124)
  end
  if req.url == nil or req.url.size <= 3 then
    return
  end
  req.file_name = L("index.xml")
  req.file_base_name = L("http_config_list.xml")
  req.t_refresh_fn = {}
  req.t_refresh_fn[L("image")] = on_fn_refresh_image
  req.t_refresh_fn[L("text")] = on_fn_refresh_text
  req.new_req_fn = enable_flicker
  ui_http_xml.get_http_xml(req)
end
function on_check_view()
  return g_new_refresh
end
function enable_flicker()
  ui_qbar.w_flicker_qq_hd.visible = true
end
local player
function on_self_enter()
  if player ~= bo2.player then
    enable_flicker()
    player = bo2.player
  end
end
local sig = "ui_http.on_self_enter"
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, sig)
