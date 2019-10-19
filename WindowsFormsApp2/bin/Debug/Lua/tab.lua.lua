function make_data(tab)
  local v = tab.svar
  local d = v.ui_tab_data
  if d == nil then
    d = {
      pages = {},
      tokey = tostring
    }
    v.ui_tab_data = d
  end
  return d
end
function make_adaptive(tab, v)
  local d = make_data(tab)
  d.adaptive = v
end
function make_on_press(tab, page)
  function on_press(btn, vis)
    page.visible = vis
    if vis then
      local td = make_data(tab)
      td.cur_page = page
      if tab.svar.tab_play_sound and tab.observable and sys.check(bo2.PlaySound2D) then
        bo2.PlaySound2D(tab.svar.tab_button_sound)
      end
    end
  end
  return on_press
end
function insert_suit(tab, name, btn_uri, btn_style, page_uri, page_style)
  local d = make_data(tab)
  local pages = d.pages
  name = d.tokey(name)
  local pd = pages[name]
  if pd ~= nil then
    ui.console_print("duplicated tab name %s.", name)
    return
  end
  pd = {}
  pages[name] = pd
  local bar = tab:search("cmn_tab_bar")
  local btn = ui.create_control(bar, "button")
  btn:load_style(btn_uri, btn_style)
  btn.group = bar
  pd.button = btn
  local view = tab:search("cmn_tab_view")
  local page = ui.create_control(view, "panel")
  page:load_style(page_uri, page_style)
  pd.page = page
  page.visible = false
  btn:insert_on_press(make_on_press(tab, page))
  if d.adaptive then
    do
      local function on_button_adaptive()
        local cnt = 0
        for n, v in pairs(pages) do
          if v.button.visible then
            cnt = cnt + 1
          end
        end
        if cnt == 0 then
          return
        end
        local dx = bar.dx / cnt
        for n, v in pairs(pages) do
          v.button.dx = dx
        end
      end
      local function on_button_visible()
        btn:insert_post_invoke(on_button_adaptive, "ui_tab_button.on_button_adaptive")
      end
      local function on_bar_size()
        btn:insert_post_invoke(on_button_adaptive, "ui_tab_button.on_button_adaptive")
      end
      bar:insert_on_move(on_bar_size, "ui_tab_button.on_bar_size")
      btn:insert_on_visible(on_button_visible, "ui_tab_button.on_button_visible")
      btn:insert_post_invoke(on_button_adaptive, "ui_tab_button.on_button_adaptive")
    end
  end
end
function clear_tab_data(tab)
  tab.svar.ui_tab_data = nil
end
function get_page(tab, name)
  local td = make_data(tab)
  name = td.tokey(name)
  local pd = td.pages[name]
  if pd == nil then
    return nil
  end
  local page = pd.page
  return page
end
function get_button(tab, name)
  local td = make_data(tab)
  name = td.tokey(name)
  local pd = td.pages[name]
  if pd == nil then
    return nil
  end
  local btn = pd.button
  return btn
end
function set_button_sound(tab, sound)
  tab.svar.tab_button_sound = sound
  tab.svar.tab_play_sound = true
end
local do_show_page = function(tab, name, vis)
  get_button(tab, name).press = vis
end
function show_page(tab, name, vis, play_sound)
  tab.svar.tab_play_sound = play_sound
  sys.pcall(do_show_page, tab, name, vis)
  tab.svar.tab_play_sound = true
end
function get_show_page(tab)
  if tab == nil then
    return nil
  end
  local td = make_data(tab)
  return td.cur_page
end
