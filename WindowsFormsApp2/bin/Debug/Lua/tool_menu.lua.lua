c_menu_style_uri = L("$gui/phase/tool/tool_menu.xml")
c_menu_window_style = L("menu_window")
c_menu_item_style = L("menu_item")
c_menu_mouse_filter_name = L("ui_tool.on_menu_mouse_filter")
c_menu_observable_name = L("ui_tool.on_menu_observable")
function menu_sort(items)
  for i = 1, table.maxn(items) do
    for j = i + 1, table.maxn(items) do
      if items[i].id > items[j].id then
        local temp
        temp = items[i]
        items[i] = items[j]
        items[j] = temp
      end
    end
  end
end
function insert_items(id, info, callback)
end
function show_cha_menu(menu)
  local callback = function(item)
    if item.callback then
      item.callback(item)
    end
  end
  menu.event = callback
  if menu.menu_change then
    menu.menu_change(menu.items)
  end
  if menu.sort == true then
    menu_sort(menu.items)
  end
  show_menu(menu)
end
function show_menu(menu)
  hide_menu()
  t_menu_data = menu
  if menu.consult == nil then
    menu.consult = menu.source
  end
  if menu.popup == nil then
    menu.popup = "y_auto"
  end
  local function on_hide()
    if t_menu_data == menu then
      hide_menu()
    end
  end
  local source = menu.source
  if source ~= nil then
    source.mouse_able = false
    source:insert_on_observable(on_hide, c_menu_observable_name)
  end
  ui.insert_mouse_filter_prev(on_menu_mouse_filter, c_menu_mouse_filter_name)
  menu_init(menu)
end
function get_menu_name()
  local t = rawget(_M, "t_menu_data")
  if t == nil then
    return nil
  end
  return t.name
end
function get_menu_pos()
  local t = rawget(_M, "t_menu_data")
  if t == nil then
    return nil
  end
  return t.window.offset
end
g_menu_valid_msg = {
  [ui.mouse_lbutton_down] = 1,
  [ui.mouse_rbutton_down] = 1,
  [ui.mouse_lbutton_dbl] = 1,
  [ui.mouse_rbutton_dbl] = 1
}
function on_menu_mouse_filter(ctrl, msg, pos, wheel)
  if g_menu_valid_msg[msg] == nil then
    return
  end
  if rawget(_M, "t_menu_data") == nil then
    ui.remove_mouse_filter(c_menu_mouse_filter_name)
    return
  end
  while sys.check(ctrl) do
    if ctrl == w_menu_top then
      return
    end
    ctrl = ctrl.parent
  end
  ui.remove_mouse_filter_prev(c_menu_mouse_filter_name)
  hide_menu()
end
local post_hidden = function()
  if rawget(_M, "w_menu_hidden") == nil then
    w_menu_hidden = ui.create_control(w_menu_top.parent)
    w_menu_hidden.visible = false
  end
  local do_release = function()
    w_menu_hidden:control_clear()
  end
  w_menu_hidden:insert_post_invoke(do_release, "ui_tool_menu.hide_menu")
end
function hide_menu(src)
  local t = rawget(_M, "t_menu_data")
  if t == nil then
    return
  end
  if src ~= nil and t.source ~= src then
    return
  end
  t_menu_data = nil
  if sys.check(t.source) then
    t.source.mouse_able = true
  end
  post_hidden()
  local w = w_menu_top.control_head
  while sys.check(w) do
    local t = w
    w = w.next
    t.parent = w_menu_hidden
  end
end
function do_hide_sub_menu(owner_menu, w, t)
  for i, p in ipairs(owner_menu.items) do
    local sub_menu = p.sub_menu
    if sub_menu ~= nil and p ~= t then
      local window = sub_menu.window
      if sys.check(window) then
        do_hide_sub_menu(sub_menu, w, t)
        table.insert(w, window)
        sub_menu.window = nil
      end
    end
  end
end
function hide_sub_menu(t, owner_menu)
  local w = {}
  if t ~= nil then
    do_hide_sub_menu(t.owner_menu, w, t)
  else
    do_hide_sub_menu(owner_menu, w, t)
  end
  if #w == 0 then
    return
  end
  post_hidden()
  for i, v in ipairs(w) do
    v.parent = w_menu_hidden
  end
end
function menu_init(menu, parent_item)
  local w = ui.create_control(ui_tool.w_menu_top)
  w.mouse_able = true
  local bg_uri = c_menu_style_uri
  local bg_style = c_menu_window_style
  if menu.bg_uri ~= nil and menu.bg_style ~= nil then
    bg_uri = menu.bg_uri
    bg_style = menu.bg_style
  end
  w:load_style(bg_uri, bg_style)
  menu.root_menu = t_menu_data
  menu.parent_item = parent_item
  menu.window = w
  menu.list_view = w:search("lv_item")
  if menu.items ~= nil then
    for i, v in ipairs(menu.items) do
      menu_insert_item(menu, v)
    end
  end
  local dx = menu.dx
  if dx == nil then
    dx = t_menu_data.dx
    if dx == nil then
      dx = 120
    end
  end
  local max_dx = menu.max_dx
  if max_dx ~= nil and dx < max_dx then
    dx = max_dx
  end
  if menu.vs then
    w:search("cmn_vs").visible = true
    dx = dx + 24
    local dy = menu.dy
    w.dy = dy
  end
  w.dx = dx
  if menu.vs == nil then
    w:tune_y("lv_item")
  end
  w:move_to_head()
  if parent_item == nil then
    if menu.margin == nil then
      menu.margin = ui.rect(0, 0, 0, 0)
    end
    if t_menu_data.offset then
      w:show_popup(t_menu_data.offset, t_menu_data.popup, menu.margin)
    else
      w:show_popup(t_menu_data.consult, t_menu_data.popup, menu.margin)
    end
  else
    local mainw = t_menu_data.window
    local mainp = mainw.parent
    local center = mainw.x + mainw.dx * 0.5
    local centerp = mainp.x + mainp.dx * 0.5
    if menu.margin == nil then
      menu.margin = ui.rect(0, 4, 0, 4)
    end
    if center < centerp then
      w:show_popup(parent_item, "x2", menu.margin)
    else
      w:show_popup(parent_item, "x1", menu.margin)
    end
  end
  if menu.on_show ~= nil then
    menu.on_show(menu)
  end
end
function menu_insert_item(m, d)
  local item = m.list_view:item_append()
  local style_uri = d.style_uri
  if style_uri == nil then
    style_uri = c_menu_style_uri
  end
  local style = d.style
  if style == nil then
    style = c_menu_item_style
  end
  item:load_style(style_uri, style)
  d.list_item = item
  d.owner_menu = m
  d.root_menu = t_menu_data
  if d.text_color ~= nil then
    item:search("btn_color").color = d.text_color
  end
  local function on_click(btn)
    menu_item_on_click(btn, d)
  end
  local function on_mouse(btn, msg)
    if msg == ui.mouse_enter then
      hide_sub_menu(d)
      if sys.check(d.sub_menu.list_view) then
        return
      end
      menu_init(d.sub_menu, d.list_item)
    elseif msg == ui.mouse_leave then
      do
        local sm = d.sub_menu
        if sm == nil then
          return
        end
        local lv = d.sub_menu.list_view
        if not sys.check(lv) then
          return
        end
        local w = d.sub_menu.list_view.parent
        local t = w.timer
        t.period = 50
        local tick = sys.tick()
        local function on_leave_timer()
          if sys.dtick(sys.tick(), tick) < 500 then
            return
          end
          t.suspended = true
          local h = ui.get_hover()
          while h ~= nil do
            if h == w or h == item then
              return
            end
            h = h.parent
          end
          hide_sub_menu(nil, d.sub_menu)
        end
        local function on_sub_mouse(sw, msg)
          if msg == ui.mouse_inner then
            t.suspended = truey
          end
        end
        w:insert_on_mouse(on_sub_mouse, "ui_tool.menu_on_sub_mouse")
        t:insert_on_timer(on_leave_timer, "ui_tool.menu_on_leave_timer")
        t.suspended = false
      end
    end
  end
  function on_mouse_no_sub(btn, msg)
    if msg == ui.mouse_enter then
      hide_sub_menu(d)
    end
  end
  local btn = item:search("btn_item")
  if btn ~= nil then
    btn.text = d.text
    if d.image ~= nil and btn:search("btn_image") ~= nil then
      btn:search("btn_image").visible = true
      btn:search("btn_image").image = d.image
    end
    if d.enable ~= nil then
      btn.enable = d.enable
    end
    if d.color ~= nil and btn:search("btn_color") ~= nil then
      btn:search("btn_color").color = d.color
    end
    if d.sub_menu ~= nil then
      btn:insert_on_mouse(on_mouse)
      local btn_a = btn:search("btn_arrow")
      if btn_a ~= nil then
        btn_a.visible = true
      end
    else
      btn:insert_on_mouse(on_mouse_no_sub)
      btn:insert_on_click(on_click)
    end
    if d.press == true then
      btn.press = true
    end
    local check = d.check
    if check ~= nil then
      btn.btype = "check"
      btn.check = sys.check(check)
      local btn0 = btn:search("btn_check_0")
      local btn1 = btn:search("btn_check_1")
      btn0.visible = true
      btn1.visible = true
      d.check_dx = btn0.dx
    end
  end
  local fn = d.get_extent
  if fn == nil and t_menu_data.auto_size then
    function fn(d)
      local p = d.list_item
      local dx = p:search("btn_color").dx + 40
      if d.sub_menu ~= nil then
        dx = dx + 20
      end
      if d.check ~= nil then
        dx = dx + d.check_dx * 1.5
      end
      return dx
    end
  end
  if fn ~= nil then
    local dx = fn(d)
    local odx = m.max_dx
    if odx == nil or dx > odx then
      m.max_dx = dx
    end
  end
end
function menu_item_on_click(btn, d)
  hide_menu()
  local e = d.root_menu.event
  if e ~= nil then
    e(d)
  end
end
function on_menu_event_test(item)
  ui.log("item %s click.", item.text)
end
function on_menu_test_click()
  local subsub = {
    items = {
      {text = "sub sub 0"},
      {text = "sub sub 1"},
      {text = "sub sub 2"}
    }
  }
  local sub = {
    items = {
      {text = "sub 0", sub_menu = subsub},
      {text = "sub 1"},
      {text = "sub 2"}
    }
  }
  show_menu({
    items = {
      {text = "fafe0"},
      {text = "fafe1", sub_menu = sub},
      {text = "fafe2"}
    },
    event = on_menu_event_test
  })
end
