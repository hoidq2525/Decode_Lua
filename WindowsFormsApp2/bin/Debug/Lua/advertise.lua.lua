cur_visible_tab = nil
local top_repay = 0
local cd_each_step = 0.0015
local timer_tab = {}
function insert_tab(name)
  local btn_uri = "$frame/advertise/advertise.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/advertise/" .. name .. ".xml"
  local page_sty = name
  ui_widget.ui_tab.insert_suit(gx_main_win, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_widget.ui_tab.get_button(gx_main_win, name)
  name = ui.get_text(sys.format("advertise|%s", name))
  btn.text = name
end
function on_init()
  ui_widget.ui_tab.clear_tab_data(gx_main_win)
  insert_tab("tab_item_1")
  insert_tab("tab_item_2")
  insert_tab("tab_item_3")
  insert_tab("tab_item_4")
  ui_widget.ui_tab.show_page(gx_main_win, "tab_item_1", true)
  ui_widget.ui_tab.set_button_sound(gx_main_win, 578)
  timer_tab[bo2.PersonalsType_FindHusband] = {}
  timer_tab[bo2.PersonalsType_FindHusband].timer = find_men_timer
  timer_tab[bo2.PersonalsType_FindHusband].step = 0
  timer_tab[bo2.PersonalsType_FindWife] = {}
  timer_tab[bo2.PersonalsType_FindWife].timer = find_women_timer
  timer_tab[bo2.PersonalsType_FindWife].step = 0
  timer_tab[bo2.PersonalsType_FindSworn] = {}
  timer_tab[bo2.PersonalsType_FindSworn].timer = find_sworn_timer
  timer_tab[bo2.PersonalsType_FindSworn].step = 0
  timer_tab[bo2.PersonalsType_JoinGuild] = {}
  timer_tab[bo2.PersonalsType_JoinGuild].timer = find_guild_timer
  timer_tab[bo2.PersonalsType_JoinGuild].step = 0
  timer_tab[bo2.PersonalsType_FindMaster] = {}
  timer_tab[bo2.PersonalsType_FindMaster].timer = find_master_timer
  timer_tab[bo2.PersonalsType_FindMaster].step = 0
  timer_tab[bo2.PersonalsType_FindAppren] = {}
  timer_tab[bo2.PersonalsType_FindAppren].timer = find_appren_timer
  timer_tab[bo2.PersonalsType_FindAppren].step = 0
  timer_tab[bo2.PersonalsType_FindGuildMember] = {}
  timer_tab[bo2.PersonalsType_FindGuildMember].timer = find_member_timer
  timer_tab[bo2.PersonalsType_FindGuildMember].step = 0
  local cd_line = bo2.gv_cooldown_list:find(50003)
  if cd_line ~= nil then
    cd_each_step = 50 / (cd_line.time * 1000) - 5.0E-4
  end
end
function insert_inner_tab(name, tab_bind, tab_type)
  local btn_uri = "$frame/advertise/advertise.xml"
  local btn_sty = "tab_btn_2"
  local page_uri = "$frame/advertise/" .. name .. ".xml"
  local page_sty = name
  ui_widget.ui_tab.insert_suit(tab_bind, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_widget.ui_tab.get_button(tab_bind, name)
  local page = ui_widget.ui_tab.get_page(tab_bind, name)
  name = ui.get_text(sys.format("advertise|%s", name))
  btn.text = name
  page.var = tab_type
  page_list[tab_type] = page
  local tab_var = tab_bind.svar
  tab_var[tab_type] = page
end
function on_tab_item_1_init()
  insert_inner_tab("find_women", gx_tab_item_1, bo2.PersonalsType_FindWife)
  insert_inner_tab("find_men", gx_tab_item_1, bo2.PersonalsType_FindHusband)
  ui_widget.ui_tab.show_page(gx_tab_item_1, "find_women", true)
  ui_widget.ui_tab.set_button_sound(gx_tab_item_1, 578)
end
function on_tab_item_2_init()
  insert_inner_tab("find_guild", gx_tab_item_2, bo2.PersonalsType_JoinGuild)
  insert_inner_tab("find_member", gx_tab_item_2, bo2.PersonalsType_FindGuildMember)
  ui_widget.ui_tab.show_page(gx_tab_item_2, "find_guild", true)
  ui_widget.ui_tab.set_button_sound(gx_tab_item_2, 578)
end
function on_tab_item_3_init()
  insert_inner_tab("find_master", gx_tab_item_3, bo2.PersonalsType_FindMaster)
  insert_inner_tab("find_appren", gx_tab_item_3, bo2.PersonalsType_FindAppren)
  ui_widget.ui_tab.show_page(gx_tab_item_3, "find_master", true)
  ui_widget.ui_tab.set_button_sound(gx_tab_item_3, 578)
end
function on_tab_item_4_init()
  insert_inner_tab("find_sworn", gx_tab_item_4, bo2.PersonalsType_FindSworn)
  ui_widget.ui_tab.show_page(gx_tab_item_4, "find_sworn", true)
  ui_widget.ui_tab.set_button_sound(gx_tab_item_4, 578)
end
function send_upload_my_info(find_type, is_top, top_multiple, toptime)
  local v = sys.variant()
  v:set(packet.key.sociality_personals_type, find_type)
  v:set(packet.key.sociality_personals_istop, is_top)
  v:set(packet.key.sociality_personals_topmultiple, top_multiple)
  v:set(packet.key.sociality_personals_toptime, toptime)
  bo2.send_variant(packet.eCTS_Sociality_UploadPersonals, v)
end
function send_del_my_info(find_type)
end
function on_click_upload_data(btn)
  local parent_page = ui_widget.ui_tab.get_show_page(gx_main_win)
  if parent_page == nil then
    return
  end
  local cur_page = ui_widget.ui_tab.get_show_page(parent_page)
  send_upload_my_info(cur_page.var.v_int, false, 0, 0)
  ui_handson_teach.test_complate_advertise(false)
  bo2.PlaySound2D(578)
end
function on_click_to_top(btn)
  local parent_page = ui_widget.ui_tab.get_show_page(gx_main_win)
  if parent_page == nil then
    return
  end
  local cur_page = ui_widget.ui_tab.get_show_page(parent_page)
  local v = sys.variant()
  v:set(packet.key.sociality_personals_type, cur_page.var.v_int)
  bo2.send_variant(packet.eCTS_Sociality_ApplyTop, v)
end
function create_list_item(data_table)
end
function upload_self(ps_type)
end
function send_refresh_packet(tab_type, list_type, page, refresh_type)
  local v = sys.variant()
  v:set(packet.key.sociality_personals_type, tab_type)
  v:set(packet.key.sociality_personals_listtype, list_type)
  v:set(packet.key.sociality_personals_page, page)
  v:set(packet.key.sociality_personals_refresh_type, refresh_type)
  local data = g_search_var[tab_type]
  if data ~= nil then
    v:set(packet.key.sociality_personals_searchvar, data)
  else
    local empty_search_var = sys.variant()
    v:set(packet.key.sociality_personals_searchvar, empty_search_var)
  end
  bo2.send_variant(packet.eCTS_Sociality_RefreshPersonals, v)
end
function on_main_visible(ctrl, vis)
  ui_widget.on_esc_stk_visible(ctrl, vis)
  local v = sys.variant()
  v:set(packet.key.sociality_uitype, bo2.eSocialUI_Personals)
  if vis == true then
    v:set(packet.key.sociality_personals_uiopen, 1)
    bo2.PlaySound2D(523)
  else
    v:set(packet.key.sociality_personals_uiopen, 0)
    bo2.PlaySound2D(524)
  end
  bo2.send_variant(packet.eCTS_Sociality_UISwitch, v)
  ui_handson_teach.test_complate_advertise(vis)
end
function on_tab_visible(ctrl, vis)
  if vis == false then
    return
  end
  local tab_var = ctrl.svar
  for k, v in pairs(tab_var) do
    if v ~= nil and sys.type(v) == "ui_panel" and v.visible == true then
      on_page_visible(v, true)
    end
  end
end
function show_normal_page(ctrl, tab_data, refresh_type)
  local tab_type = ctrl.var.v_int
  local normal_list_data = tab_data[bo2.ePersonalsListType_Normal]
  local page = normal_list_data.cur_page
  local cur_page_data = normal_list_data[page]
  if page == nil or cur_page_data == nil then
    send_refresh_packet(tab_type, bo2.ePersonalsListType_Normal, page, refresh_type)
  else
    if sys.tick() - cur_page_data.refresh_time > REFERESH_TIME_INTERVAL then
      send_refresh_packet(tab_type, bo2.ePersonalsListType_Normal, page, refresh_type)
    end
    refresh_list(tab_type, bo2.ePersonalsListType_Normal, cur_page_data.data, refresh_type)
  end
end
function on_page_visible(ctrl, vis)
  if vis == false then
    return
  end
  cur_visible_tab = ctrl
  local tab_type = ctrl.var.v_int
  local tab_data = page_data[tab_type]
  if tab_data == nil then
    return
  end
  local top_list_data = tab_data[bo2.ePersonalsListType_Top]
  if top_list_data == nil then
    send_refresh_packet(tab_type, bo2.ePersonalsListType_Top, 0, bo2.ePersonalsRefreshType_Refresh)
  else
    if sys.tick() - top_list_data.refresh_time > TOP_REFERESH_TIME_INTERVAL then
      send_refresh_packet(tab_type, bo2.ePersonalsListType_Top, 0, bo2.ePersonalsRefreshType_Refresh)
    end
    refresh_list(tab_type, bo2.ePersonalsListType_Top, top_list_data.data)
  end
  show_normal_page(ctrl, tab_data, bo2.ePersonalsRefreshType_Refresh)
  local my_info_data = tab_data[bo2.ePersonalsListType_My]
  if my_info_data ~= nil then
    refresh_list(tab_type, bo2.ePersonalsListType_My, my_info_data)
  end
end
function on_ad_combo_box(btn)
  local cb = btn.parent
  local items = {}
  local svar = cb.svar
  local t = svar.list
  for i, v in ipairs(t) do
    local item = {
      id = v.id,
      color = v.color,
      text = v.text,
      style_uri = v.style_uri,
      style = v.style,
      data = v
    }
    table.insert(items, item)
  end
  local function on_event_list_select(item)
    ui_widget.ui_combo_box.select(cb, item.id)
    local text = item.text
    if item.id == sel_btn_nil_id then
      text = ""
    end
    on_search_item_select(cb, item.data.tab_id, item.data.search_type, item.data.search_var, text)
  end
  local size = #t
  local vs
  if size > 7 then
    size = 7
    vs = true
  end
  local dy = size * 28 + 20
  ui_tool.show_menu({
    items = items,
    event = on_event_list_select,
    source = btn,
    popup = "y",
    dx = cb.dx + 40,
    dy = dy,
    vs = vs
  })
end
function on_refresh_click(btn)
  local ctrl = cur_visible_tab
  if ctrl == nil then
    return
  end
  local tab_type = ctrl.var.v_int
  local tab_data = page_data[tab_type]
  if tab_data == nil then
    return
  end
  local normal_list_data = tab_data[bo2.ePersonalsListType_Normal]
  local page = normal_list_data.cur_page
  local cur_page_data = normal_list_data[page]
  generate_search_var(tab_type)
  send_refresh_packet(tab_type, bo2.ePersonalsListType_Normal, page, bo2.ePersonalsRefreshType_Search)
  on_progress_start(btn)
end
function refresh_top_text(rate, time_day)
  local time_temp_text = ui.get_text("advertise|end_time")
  local v = bo2.cur_time_add_span(time_day, 0, 0, 0)
  local date_text = sys.mtf_merge(v, time_temp_text)
  local end_time_label = w_confirm_top:search("time_text")
  end_time_label.text = date_text
  local money_line = bo2.gv_define_sociality:find(59)
  local money_each_hour = tonumber(tostring(money_line.value))
  local money = money_each_hour * 24 * rate * time_day
  local money_lable = w_confirm_top:search("money_text")
  if top_repay > 0 then
    local repay_temp_text = ui.get_text("advertise|repay_text")
    local repay_money = sys.variant()
    repay_money:set("money", top_repay)
    local repay_text = sys.mtf_merge(repay_money, repay_temp_text)
    money_lable.mtf = "<bm:" .. money .. ">" .. "\n" .. repay_text
  else
    money_lable.mtf = [[

<bm:]] .. money .. ">"
  end
end
function show_top_confirm(type, min_multi, repay)
  local svar = w_confirm_top.svar
  svar.min_multi = min_multi
  svar.type = type
  local rate_lable = w_confirm_top:search("rate_input")
  rate_lable.text = min_multi
  local init_time = 1
  local time_lable = w_confirm_top:search("time_input")
  time_lable.text = init_time
  top_repay = repay
  refresh_top_text(min_multi, init_time)
  w_confirm_top.visible = true
  w_modal_bg.visible = true
end
function on_top_rate_chg(ctrl)
  local rate_lable = w_confirm_top:search("rate_input")
  local rate = tonumber(tostring(rate_lable.text))
  if rate == nil or rate < 0 then
    rate = 0
  end
  local max_rate_line = bo2.gv_define_sociality:find(61)
  local max_rate = tonumber(tostring(max_rate_line.value))
  if rate > max_rate then
    rate = max_rate
  end
  rate_lable.text = rate
  local time_lable = w_confirm_top:search("time_input")
  local time = tonumber(tostring(time_lable.text))
  if time == nil then
    time = 0
  end
  refresh_top_text(rate, time)
end
function on_top_time_chg(ctrl)
  local time_lable = w_confirm_top:search("time_input")
  if time_lable.text == nil or time_lable.text == L("") then
    time_lable.text = 0
  end
  local time = tonumber(tostring(time_lable.text))
  if time == nil or time < 0 then
    time = 0
  end
  local max_time_line = bo2.gv_define_sociality:find(58)
  local max_time = tonumber(tostring(max_time_line.value)) / 24
  if time > max_time then
    time = max_time
    time_lable.text = time
  end
  local rate_lable = w_confirm_top:search("rate_input")
  local rate = tonumber(tostring(rate_lable.text))
  if rate == nil then
    rate = 0
  end
  refresh_top_text(rate, time)
end
function on_top_confirm_click(btn)
  local time_lable = w_confirm_top:search("time_input")
  if time_lable.text == nil or time_lable.text == L("") then
    time_lable.text = 0
  end
  local time = tonumber(tostring(time_lable.text)) * 24
  local rate_lable = w_confirm_top:search("rate_input")
  local rate = tonumber(tostring(rate_lable.text))
  local svar = w_confirm_top.svar
  local type = svar.type
  send_upload_my_info(type, true, rate, time)
  w_confirm_top.visible = false
end
function on_top_cancel_click(btn)
  w_confirm_top.visible = false
end
function on_confirm_win_visible(ctrl, is_vis)
  w_modal_bg.visible = is_vis
end
function on_advance_search_visible(ctrl, is_vis)
  w_modal_bg.visible = is_vis
end
function on_page_btn_click(btn, chg_func)
  local parent_page = ui_widget.ui_tab.get_show_page(gx_main_win)
  if parent_page == nil then
    return
  end
  local cur_page = ui_widget.ui_tab.get_show_page(parent_page)
  local type = cur_page.var.v_int
  local tab_data = page_data[type]
  if tab_data == nil then
    return
  end
  local normal_list_data = tab_data[bo2.ePersonalsListType_Normal]
  normal_list_data.cur_page = chg_func(normal_list_data.cur_page, normal_list_data.total_page)
  show_normal_page(cur_page, tab_data, bo2.ePersonalsRefreshType_ChgPage)
  refresh_page_ui(cur_page, normal_list_data.cur_page, normal_list_data.total_page)
end
function on_click_head(btn)
  function to_head()
    return 0
  end
  on_page_btn_click(btn, to_head)
end
function on_click_prev(btn)
  function to_prev(page)
    local new_page = page - 1
    if new_page < 0 then
      new_page = 0
    end
    return new_page
  end
  on_page_btn_click(btn, to_prev)
end
function on_click_foot(btn)
  function to_foot(page, total_page)
    new_page = total_page - 1
    if new_page < 0 then
      new_page = 0
    end
  end
  on_page_btn_click(btn, to_foot)
end
function on_click_next(btn)
  function to_next(page, total_page)
    local new_page = page + 1
    if total_page <= new_page then
      new_page = total_page - 1
      if new_page < 0 then
        new_page = 0
      end
    end
    return new_page
  end
  on_page_btn_click(btn, to_next)
end
function on_ad_item_select(ctrl, is_select)
end
function product_highlight(ctrl, is_vis)
  ctrl:search("high_light").visible = is_vis
end
function tip_show(ctrl, vis, pos)
  local tip = main_tip
  if vis == true then
    local svar = ctrl.svar
    local addition_data = svar.addition_data
    local top_mul = addition_data[packet.key.sociality_personals_topmultiple]
    if top_mul ~= nil and top_mul.v_int > 0 then
      local tip_temp_text = ui.get_text("advertise|multi_tip")
      local text_par = sys.variant()
      text_par:set("mul", top_mul)
      local tip_text = sys.mtf_merge(text_par, tip_temp_text)
      local tip_text_rich = tip:search("tip_text")
      tip_text_rich.mtf = tip_text
      local tip_pos = ui.point(ctrl.abs_area.x1 - gx_main_win.abs_area.x1, ctrl.abs_area.y1 - gx_main_win.abs_area.y1)
      tip.x = tip_pos.x
      tip.y = tip_pos.y
      tip.visible = true
    else
      tip.visible = false
    end
  else
    tip.visible = false
  end
end
function on_item_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_enter then
    product_highlight(ctrl, true)
    tip_show(ctrl, true, pos)
  elseif msg == ui.mouse_leave then
    product_highlight(ctrl, false)
    tip_show(ctrl, false, pos)
  elseif msg == ui.mouse_lbutton_dbl then
  elseif msg == ui.mouse_rbutton_click then
    ctrl:select(true)
    on_rb_click(ctrl, pos)
  end
end
function on_click_chg_info(btn)
  ui_im.create_info_dlg(bo2.player.name, true)
end
local set_progress = function(ctrl, f)
  local frm = ctrl:search("frm")
  local pic = ctrl:search("pic_progress")
  local dx = (frm.dx - 17) * f
  if dx < 0 then
    dx = 0
  end
  pic.dx = dx
end
function on_search_disable_progress_timer(timer)
  local cur_step, timer_data
  for i, v in pairs(timer_tab) do
    if v.timer == timer then
      timer_data = v
      cur_step = v.step + cd_each_step
      v.step = cur_step
    end
  end
  set_progress(timer_data.btn_search.parent, cur_step)
  set_progress(timer_data.btn_advance_search.parent, cur_step)
  if cur_step > 1 then
    timer.suspended = true
    on_progress_complete(timer)
  end
end
function on_progress_start(btn)
  local main = cur_visible_tab
  local tab_type = main.var.v_int
  local timer = timer_tab[tab_type].timer
  timer_tab[tab_type].step = 0
  local panel_search = btn.parent.parent:search(L("panel_search"))
  set_progress(panel_search, 0)
  panel_search:search(L("btn")).enable = false
  timer_tab[tab_type].btn_search = panel_search:search(L("btn"))
  panel_search:search(L("frm")).visible = true
  panel_search:search(L("fader")).visible = true
  panel_search:search(L("fader")):reset(0, 0, 0, 0)
  local panel_advance_search = btn.parent.parent:search(L("panel_advance_search"))
  set_progress(panel_advance_search, 0)
  panel_advance_search:search(L("btn")).enable = false
  timer_tab[tab_type].btn_advance_search = panel_advance_search:search(L("btn"))
  panel_advance_search:search(L("frm")).visible = true
  panel_advance_search:search(L("fader")).visible = true
  panel_advance_search:search(L("fader")):reset(0, 0, 0, 0)
  timer.suspended = false
end
function on_progress_complete(timer)
  timer.suspended = true
  local cur_step, timer_data
  for i, v in pairs(timer_tab) do
    if v.timer == timer then
      v.btn_search.enable = true
      v.btn_search.parent:search(L("frm")).visible = false
      v.btn_search.parent:search(L("fader")).visible = true
      v.btn_search.parent:search(L("fader")):reset(1, 0, 1000, 0)
      v.btn_advance_search.enable = true
      v.btn_advance_search.parent:search(L("frm")).visible = false
      v.btn_advance_search.parent:search(L("fader")).visible = true
      v.btn_advance_search.parent:search(L("fader")):reset(1, 0, 1000, 0)
    end
  end
end
