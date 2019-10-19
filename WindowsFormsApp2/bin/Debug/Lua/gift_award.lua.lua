local page_visible = {}
local g_tick = 0
g_cur_gifts = {
  [L("new_page")] = 0,
  [L("serverbegin_main1")] = 0,
  [L("serverbegin_main2")] = 0
}
function on_tips_init()
  w_tips:search("richbox").mtf = sys.format(L("<handson:,5,%s>"), ui.get_text("gift_award|tips"))
end
function on_tips_timer(t)
  if w_tips.visible and sys.check(w_flicker) then
    local pos = w_flicker.abs_area
    w_tips.offset = ui.point((pos.x1 + pos.x2) * 0.5 - 28, pos.y2)
  end
end
function set_tips_visible(vis)
  if vis then
    local pos = w_flicker.abs_area
    w_tips.offset = ui.point((pos.x1 + pos.x2) * 0.5 - 28, pos.y2)
  end
  w_tips.visible = vis
end
function on_tab_press(btn, press)
  if press and page_visible[btn.name] ~= nil then
    page_visible[btn.name](nil, press)
  end
end
function insert_tab(name, style, msg)
  local btn_uri = "$frame/giftaward/giftaward.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/giftaward/" .. name .. ".xml"
  local page_sty = style
  ui_widget.ui_tab.insert_suit(w_win, style, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_widget.ui_tab.get_button(w_win, style)
  btn.name = name
  local page = ui_widget.ui_tab.get_page(w_win, style)
  page.name = name
  btn.text = ui.get_text(sys.format("gift_award|tab_btn_%s", name))
  btn:insert_on_press(on_tab_press, "ui_gift_award.on_tab_press")
  if name == "new_page" then
    btn.press = true
  end
end
function on_init()
  insert_tab("new_page", "new_page_main")
  insert_tab("serverbegin1", "serverbegin_main1")
  insert_tab("serverbegin2", "serverbegin_main2")
  page_visible = {
    [L("new_page")] = ui_gift_award.new_page.on_visible,
    [L("serverbegin1")] = ui_gift_award.ui_svrbeg1.on_visible,
    [L("serverbegin2")] = ui_gift_award.ui_svrbeg2.on_visible
  }
end
function on_visible(w, v)
  local page = ui_widget.ui_tab.get_show_page(w_win)
  ui.log("name is %s", page.name)
  local fn = page_visible[page.name]
  if fn ~= nil then
    fn(page, v)
  end
  if v == true then
    ui_widget.esc_stk_push(w)
  else
    ui_widget.esc_stk_pop(w)
  end
end
function on_show_win()
  w_win.visible = not w_win.visible
end
function on_tip_show(tip)
  ui_widget.tip_make_view(tip.view, text)
end
function flicker_visible()
  if g_cur_gifts[L("new_page")] ~= 0 or g_cur_gifts[L("serverbegin1")] ~= 0 or g_cur_gifts[L("serverbegin2")] ~= 0 then
    w_tips.visible = true
    w_tips:tune("richbox")
    w_flicker2.visible = true
    w_flicker2.suspended = false
  else
    w_tips.visible = false
    w_flicker2.visible = false
    w_flicker2.suspended = true
  end
end
function on_timer()
  local delta = sys.dtick(sys.tick(), g_tick)
  local seconds = math.floor(delta / 1000)
  if seconds >= 10 then
    g_tick = sys.tick()
    ui_gift_award.new_page.on_gift_timer()
    ui_gift_award.ui_svrbeg1.on_timer()
    ui_gift_award.ui_svrbeg2.on_timer()
    flicker_visible()
  end
end
