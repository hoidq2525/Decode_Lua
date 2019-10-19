kuafu_pre_time = 0
kuafu_cur_time = 0
has_kuafu_msg = false
has_main_msg = false
main_pre_time = 0
main_cur_time = 0
ui_text_list = ui_widget.ui_text_list
ui_tab = ui_widget.ui_tab
local cs_chat_list_style_uri = SHARED("$widget/chat_list.xml")
local cs_chat_list_style_16 = SHARED("cmn_chat_list_item_font_size_16")
local cs_chat_list_style_20 = SHARED("cmn_chat_list_item_font_size_20")
local init_once = function()
  if rawget(_M, "g_alrealy_init") ~= nil then
    return
  end
  g_alrealy_init = true
end
local amount_limit_warning = ui.get_text("chat|amount_limit_warning")
local ime_tip = ui.get_text("chat|ime_tip")
local get_page_list = function(wnd)
  local view = wnd.svar.page_list
  if view == nil or sys.check(view) == false then
    view = wnd:search("page_list")
    wnd.svar.page_list = view
  end
  return view
end
local get_chat_list = function(wnd)
  local view = wnd.svar.chat_list
  if view == nil or sys.check(view) == false then
    view = wnd:search("chat_list")
    wnd.svar.chat_list = view
  end
  return view
end
function on_person_list(btn)
  ui_chat.w_personal_list:control_clear()
  for i, v in ipairs(person_name_list) do
    insert_person_list_item(v, "00ffff")
  end
  ui_widget.ui_popup.show(ui_chat.w_personal_list, btn, "y1x2")
end
function on_main_mouse(card, msg, pos, wheel)
  if ui_tab.get_show_page(w_chat_page):search("chat_list").scroll == 1 then
    main_flicker.visible = false
  end
end
function on_extra_mouse(card, msg, pos, wheel)
  if w_extra_chat:search("page_list").parent:search("chat_list").scroll == 1 then
    extra_flicker.visible = false
  end
end
function on_kuafu_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_wheel and w_main_kuafu:search("page_list").parent:search("chat_list").scroll == 1 then
    kuafu_flicker.visible = false
  end
end
function on_scroll_bottom(btn)
  ui_tab.get_show_page(w_chat_page):search("chat_list").scroll = 1
  ui_tab.get_show_page(w_chat_page):search("page_list").svar.chat_list_data.bottom = true
  if main_flicker.visible then
    main_flicker.visible = false
  end
end
function on_scroll_top(btn)
  ui_tab.get_show_page(w_chat_page):search("chat_list").scroll = 0
  ui_tab.get_show_page(w_chat_page):search("page_list").svar.chat_list_data.top = true
end
function on_scroll_bottom_not_main(btn)
  local bpp = btn.parent.parent
  if not sys.check(btn) then
    return
  end
  get_chat_list(bpp).scroll = 1
  get_page_list(bpp).svar.chat_list_data.bottom = true
  if extra_flicker.visible then
    extra_flicker.visible = false
  end
end
function on_scroll_top_not_main(btn)
  btn.parent.parent:search("chat_list").scroll = 0
  btn.parent.parent:search("page_list").svar.chat_list_data.top = true
end
function on_person_list_item(btn)
  ui_qchat.w_personal_name:search("text").text = btn:search("btn_color").text
  ui_chat.w_personal_list.visible = false
end
function insert_person_list_item(target_name, color)
  local item = ui.create_control(ui_chat.w_personal_list, "panel")
  item:load_style("$frame/chat/cha_console.xml", "person_list_item")
  item:search("btn_color").text = target_name
  if color then
    item:search("btn_color").color = ui.make_color(color)
  end
  item:search("btn_color").parent.tip.text = target_name
  ui_chat.w_personal_list.dy = ui_chat.w_personal_list.control_size * 22 + 5
end
function on_personal_key_qchat(box, key, flag)
  if flag.down then
    return
  end
  local text = box.text
  if key == ui.VK_RETURN and personal_enter_flag == true then
    box.focus = false
    ui_qchat.w_input.focus = true
    personal_enter_flag = false
    on_person_list(ui_qchat.w_personal_btn)
    ui_qchat.w_personal_list.visible = false
  elseif key == ui.VK_ESCAPE then
    box.focus = false
    ui_qchat.w_personal_list.visible = false
  elseif key == ui.VK_TAB then
    on_input(box, key, flag)
  elseif key == ui.VK_MENU then
    on_input(box, key, flag)
  end
end
function on_personal_key(box, key, flag)
  if flag.down then
    return
  end
  local text = box.text
  if key == ui.VK_RETURN and personal_enter_flag == true then
    box.focus = false
    ui_qchat.w_input.focus = true
    personal_enter_flag = false
    on_person_list(ui_qchat.w_personal_btn)
    ui_qchat.w_personal_list.visible = false
  else
    if key == ui.VK_ESCAPE then
      box.focus = false
      ui_qchat.w_personal_list.visible = false
    else
    end
  end
end
function on_personal_char(box, ch)
  if ch == 13 then
    personal_enter_flag = true
  end
end
function on_personal_focus(box)
  if box.focus == true then
  else
    ui_qchat.w_personal_list.visible = false
  end
end
function on_channel(panel, msg)
  ui_widget.ui_popup.show(w_chat_channel, panel, "y1x1")
  if w_chat_channel.visible == false then
    local channel_list = windows_list[1].control.var:ref("channel_list")
    for i, v in ipairs(windows_list[1].list) do
      if channel_list:has(i) then
        v.enable = channel_list:ref(i):get("check").v_object.check
      end
      display(windows_list[1])
    end
  end
end
function on_channel_visible(ctrl)
  if ctrl.visible == true then
    if bo2.get_group_id() == sys.wstring(0) then
      w_channel_list:search(bo2.eChatChannel_Group).enable = false
    else
      w_channel_list:search(bo2.eChatChannel_Group).enable = true
    end
    if ui.guild_get_self() == nil then
      w_channel_list:search(bo2.eChatChannel_Guild).enable = false
    else
      w_channel_list:search(bo2.eChatChannel_Guild).enable = true
    end
  end
end
function create_channel(index, wnd)
  wnd.control.visible = true
  local channel_list = wnd.control.var:ref("channel_list")
  local item = ui.create_control(wnd.control, "divider")
  item:load_style("$frame/chat/cha_console.xml", "channel_group")
  item:search("btn_channel").text = channels_list[index].name
  if channels_list[index].symbol ~= nil then
    item:search("btn_channel").text = item:search("btn_channel").text .. "(/" .. channels_list[index].symbol .. ")"
  end
  item:search("btn_check").check = wnd.list[index].enable
  channel_list:ref(index):set("check", item:search("btn_check"))
  local btn = item:search("btn_channel")
  local channel = btn.var:ref("chat")
  channel:set("channel", index)
  btn.name = channels_list[index].id
  table.insert(channel_btns, {
    id = channels_list[index].id,
    tab_order = channels_list[index].tab_order
  })
end
function on_extra_channel_visible(ctrl)
  if ctrl.visible then
    ui_widget.esc_stk_push(ctrl)
  else
    ui_widget.esc_stk_pop(ctrl)
  end
  if ctrl.visible == false then
    return
  end
  local channel_list = windows_list[#windows_list].control.var:ref("channel_list")
  for i, v in ipairs(windows_list[#windows_list].list) do
    if channel_list:has(i) then
      channel_list:ref(i):get("check").v_object.check = windows_list[#windows_list].list[i].enable
    end
  end
end
function on_cmn_channel_visible(ctrl)
  if ctrl.visible then
    ui_widget.esc_stk_push(ctrl)
  else
    ui_widget.esc_stk_pop(ctrl)
  end
  if ctrl.visible == false then
    return
  end
  local page = setup_window
  local flag = false
  local index
  for i, v in ipairs(windows_list) do
    if v.window == page then
      if v.define == 1 then
        flag = true
      end
      index = i
      break
    end
  end
  if index == nil then
    return
  end
  for i, v in ipairs(windows_list[index].list) do
    channels_list[i].item:search("btn_check").check = v.enable
    channels_list[i].item:search("btn_check").enable = flag
    if channels_list[i].always_display == 1 then
      channels_list[i].item:search("btn_check").enable = false
    end
    if channels_list[i].item:search("btn_check").enable == true then
      channels_list[i].item:search("channel_text").color = ui.make_color("ffffff")
    else
      channels_list[i].item:search("channel_text").color = ui.make_color("808080")
    end
  end
  w_setup_btns.visible = flag
  b_define_setup = flag
  cur_define_window = index
end
function setup_font(item)
  font_size = item.size
  for k, v in pairs(windows_list) do
    display(v)
    local view = v.window:search("chat_list")
    view.scroll = 1
    v.window:search("page_list").svar.chat_list_data.bottom = true
  end
  local view = w_main_kuafu:search("chat_list")
  view.scroll = 1
  w_main_kuafu:search("page_list").svar.chat_list_data.bottom = true
  chat_save()
end
function set_font(item)
  font_size = item.size
  for k, v in pairs(windows_list) do
    display(v)
    local view = v.window:search("chat_list")
    view.scroll = 1
    v.window:search("page_list").svar.chat_list_data.bottom = true
  end
  local view = w_main_kuafu:search("chat_list")
  view.scroll = 1
  w_main_kuafu:search("page_list").svar.chat_list_data.bottom = true
end
function setup_display(item)
  local flag = item.value
  if flag == true then
    w_timer.suspended = true
    w_timer2.suspended = true
    for i, v in ipairs(hide_windows) do
      v:reset(1, 1, 0)
    end
    for i, v in ipairs(hide_windows1) do
      v:reset(1, 1, 0)
    end
    for i, v in ipairs(hide_windows2) do
      v:reset(1, 1, 0)
    end
    w_channel_btns:reset(w_channel_btns.alpha, 1, 0)
    tab_fader:reset(tab_fader.alpha, 1, 0)
    extra_corner_btn:reset(extra_corner_btn, 1, 0)
    extra_undetach_btn:reset(extra_undetach_btn, 1, 0)
    extra_scroll_bottom:reset(extra_scroll_bottom, 1, 0)
    extra_scroll_top:reset(extra_scroll_top, 1, 0)
    main_scroll_bottom:reset(main_scroll_bottom, 1, 0)
    main_scroll_top:reset(main_scroll_top, 1, 0)
    main_lock_btn:reset(main_lock_btn, 1, 0)
    w_slider_page:reset(w_slider_page, 1, 0)
    setup_display_flag = 1
  elseif flag == false then
    w_timer.suspended = false
    w_timer2.suspended = false
    mouse_in_main = true
    mouse_in_kuafu = true
    setup_display_flag = 0
  end
  chat_save()
end
function setup_channel(item)
  setup_window = item.window
  chat_cmn_setup.visible = true
  on_cmn_channel_visible(chat_cmn_setup, true)
end
function on_event(item)
  if item.callback then
    item:callback()
  end
end
function on_setup_mouse(btn, msg, pos, wheel)
  if msg == ui.ui.mouse_lbutton_up then
    local menu = {}
    local item = {}
    local channel_item = {}
    for k, v in pairs(windows_list) do
      if v.main_window == true then
        table.insert(channel_item, {
          text = v.name,
          window = v.window,
          callback = setup_channel,
          style_uri = "$frame/chat/cha_console.xml",
          style = "setup_menu_item_no_arrow"
        })
      end
    end
    local channel_menu = {
      items = channel_item,
      event = on_event,
      dx = 80,
      dy = 60,
      bg_uri = "$frame/chat/cha_console.xml",
      bg_style = "setup_menu"
    }
    local font_item = {}
    if font_size == "20" then
      table.insert(font_item, {
        text = ui.get_text("chat|lager"),
        size = "20",
        callback = setup_font,
        style_uri = "$frame/chat/cha_console.xml",
        style = "setup_menu_item_no_arrow",
        press = true
      })
    else
      table.insert(font_item, {
        text = ui.get_text("chat|lager"),
        size = "20",
        callback = setup_font,
        style_uri = "$frame/chat/cha_console.xml",
        style = "setup_menu_item_no_arrow"
      })
    end
    if font_size == "16" then
      table.insert(font_item, {
        text = ui.get_text("chat|middle"),
        size = "16",
        callback = setup_font,
        style_uri = "$frame/chat/cha_console.xml",
        style = "setup_menu_item_no_arrow",
        press = true
      })
    else
      table.insert(font_item, {
        text = ui.get_text("chat|middle"),
        size = "16",
        callback = setup_font,
        style_uri = "$frame/chat/cha_console.xml",
        style = "setup_menu_item_no_arrow"
      })
    end
    if font_size == "12" then
      table.insert(font_item, {
        text = ui.get_text("chat|small"),
        size = "12",
        callback = setup_font,
        style_uri = "$frame/chat/cha_console.xml",
        style = "setup_menu_item_no_arrow",
        press = true
      })
    else
      table.insert(font_item, {
        text = ui.get_text("chat|small"),
        size = "12",
        callback = setup_font,
        style_uri = "$frame/chat/cha_console.xml",
        style = "setup_menu_item_no_arrow"
      })
    end
    local font_menu = {
      items = font_item,
      event = on_event,
      dx = 60,
      dy = 60,
      bg_uri = "$frame/chat/cha_console.xml",
      bg_style = "setup_menu"
    }
    local display_item = {}
    if setup_display_flag == 1 then
      table.insert(display_item, {
        text = ui.get_text("chat|always_display"),
        value = true,
        callback = setup_display,
        style_uri = "$frame/chat/cha_console.xml",
        style = "setup_menu_item_no_arrow",
        press = true
      })
    else
      table.insert(display_item, {
        text = ui.get_text("chat|always_display"),
        value = true,
        callback = setup_display,
        style_uri = "$frame/chat/cha_console.xml",
        style = "setup_menu_item_no_arrow"
      })
    end
    if setup_display_flag == 0 then
      table.insert(display_item, {
        text = ui.get_text("chat|fade-out"),
        value = false,
        callback = setup_display,
        style_uri = "$frame/chat/cha_console.xml",
        style = "setup_menu_item_no_arrow",
        press = true
      })
    else
      table.insert(display_item, {
        text = ui.get_text("chat|fade-out"),
        value = false,
        callback = setup_display,
        style_uri = "$frame/chat/cha_console.xml",
        style = "setup_menu_item_no_arrow"
      })
    end
    local display_menu = {
      items = display_item,
      event = on_event,
      dx = 100,
      dy = 60,
      bg_uri = "$frame/chat/cha_console.xml",
      bg_style = "setup_menu"
    }
    table.insert(item, {
      text = ui.get_text("chat|font"),
      sub_menu = font_menu,
      style_uri = "$frame/chat/cha_console.xml",
      style = "setup_menu_item"
    })
    table.insert(item, {
      text = ui.get_text("chat|display_menu"),
      sub_menu = display_menu,
      style_uri = "$frame/chat/cha_console.xml",
      style = "setup_menu_item"
    })
    table.insert(item, {
      text = ui.get_text("chat|channel_menu"),
      sub_menu = channel_menu,
      style_uri = "$frame/chat/cha_console.xml",
      style = "setup_menu_item"
    })
    menu = {
      items = item,
      event = on_event,
      dx = 150,
      dy = 80,
      consult = btn,
      popup = "y1",
      bg_uri = "$frame/chat/cha_console.xml",
      bg_style = "setup_menu"
    }
    ui_tool.show_menu(menu)
  end
end
function on_extra_setup(btn)
  setup_window = windows_list[#windows_list - 1].window
  chat_cmn_setup.visible = true
end
function on_cmn_channel_confirm(btn)
  local update_config = function(w)
    for i, v in ipairs(w.list) do
      v.enable = channels_list[i].item:search("btn_check").check
    end
    display(w)
    local view = w.window:search("chat_list")
    view.scroll = 1
    w.window:search("page_list").svar.chat_list_data.bottom = true
  end
  chat_cmn_setup.visible = false
  update_config(windows_list[cur_define_window])
  if cur_define_window == #windows_list - 1 then
    update_config(windows_list[#windows_list])
  end
  chat_save()
end
function on_cmn_channel_cannel(btn)
  chat_cmn_setup.visible = false
  b_define_setup = false
end
function init_setup_window()
  for i, v in ipairs(channels_list) do
    local item = ui.create_control(w_cmn_channel_list, "divider")
    item:load_style("$frame/chat/cha_console.xml", "extra_channel_group")
    item:search("channel_text").text = v.name
    item:search("btn_check").check = false
    v.item = item
  end
end
function on_detach(btn)
  windows_list[#windows_list].window.visible = true
  display(windows_list[#windows_list])
  ui_tab.get_button(w_chat_page, windows_list[CUSTOM_INDEX].name).visible = false
  if ui_tab.get_show_page(w_chat_page) == ui_tab.get_page(w_chat_page, windows_list[CUSTOM_INDEX].name) then
    ui_tab.show_page(w_chat_page, windows_list[COMPOSITE_INDEX].name, true)
    on_tab_btn(ui_tab.get_button(w_chat_page, windows_list[COMPOSITE_INDEX].name))
    w_btn_detach.visible = false
  end
  w_extra_chat.visible = true
  chat_save()
end
function on_detach_set(btn)
  windows_list[#windows_list].window.visible = true
  display(windows_list[#windows_list])
  ui_tab.get_button(w_chat_page, windows_list[CUSTOM_INDEX].name).visible = false
  if ui_tab.get_show_page(w_chat_page) == ui_tab.get_page(w_chat_page, windows_list[CUSTOM_INDEX].name) then
    ui_tab.show_page(w_chat_page, windows_list[COMPOSITE_INDEX].name, true)
    w_btn_detach.visible = false
  end
  w_extra_chat.visible = true
end
function on_extra_undetach(btn)
  windows_list[#windows_list].window.visible = false
  ui_tab.get_button(w_chat_page, windows_list[CUSTOM_INDEX].name).visible = true
  on_tab_btn(ui_tab.get_button(w_chat_page, windows_list[COMPOSITE_INDEX].name))
  chat_save()
end
function on_extra_undetach_set(btn)
  windows_list[#windows_list].window.visible = false
  ui_tab.get_button(w_chat_page, windows_list[CUSTOM_INDEX].name).visible = true
end
function on_extra_channel_confirm(btn)
  local channel_list = windows_list[#windows_list].control.var:ref("channel_list")
  for i, v in ipairs(windows_list[#windows_list].list) do
    if channel_list:has(i) then
      v.enable = channel_list:ref(i):get("check").v_object.check
    end
    display(windows_list[#windows_list])
  end
  channel_list = windows_list[#windows_list - 1].control.var:ref("channel_list")
  for i, v in ipairs(windows_list[#windows_list - 1].list) do
    if channel_list:has(i) then
      v.enable = channel_list:ref(i):get("check").v_object.check
    end
    display(windows_list[#windows_list - 1])
  end
  w_extra_setup.visible = false
end
function on_extra_channel_cannel(btn)
  w_extra_setup.visible = false
end
function on_lb_channel()
end
function create_extra_channel(index, wnd)
  local channel_list = wnd.control.var:ref("channel_list")
  local item = ui.create_control(wnd.control, "divider")
  item:load_style("$frame/chat/cha_console.xml", "extra_channel_group")
  item:search("channel_text").text = channels_list[index].name
  item:search("btn_check").check = wnd.list[index].enable
  channel_list:ref(index):set("check", item:search("btn_check"))
end
function create_channellist(wnd)
  for i, v in ipairs(channels_list) do
    if v.click_able == true then
      create_channel(i, wnd)
    end
  end
end
function create_extra_channellist(wnd)
  for i, v in ipairs(channels_list) do
    create_extra_channel(i, wnd)
  end
end
function set_channel(id, name, real_name)
  local excel = bo2.gv_chat_list:find(id)
  if excel == nil then
    return
  end
  for i, v in ipairs(channels_list) do
    if v.id == id then
      if v.click_able == false then
        return
      end
      ui_qchat.w_personal_name.visible = false
      ui_qchat.w_qchat.visible = true
      current_channel = i
      ui_qchat.w_channel_select:search("btn_color").text = v.name
      if channels_list[current_channel].id == bo2.eChatChannel_PersonalChat then
        ui_qchat.w_personal_name.visible = true
        if name then
          ui_qchat.w_personal_name:search("text").text = name
        else
          ui_qchat.w_personal_name:search("text").text = target_name
        end
        ui_qchat.w_personal_name.var:set("real_name", real_name)
        if ui_qchat.w_person_input.text.empty then
          ui_qchat.w_person_input.focus = true
          return
        end
      end
      ui_qchat.w_input.focus = true
      return
    end
  end
end
function select_channel(btn)
  btn.parent.parent.parent.visible = false
  local index = btn.var:ref("chat"):get("channel").v_int
  local id = channels_list[index].id
  set_channel(id)
end
function on_chat_page(panel, msg)
  if msg == ui.mouse_enter then
    panel:search("page_bg").visible = true
  elseif msg == ui.mouse_outer then
    panel:search("page_bg").visible = false
  end
end
function insert_kuafu(txt, wnd)
  local stk = txt
  local view = get_page_list(wnd)
  local data = {text = stk}
  if font_size == "16" then
    ui_widget.ui_chat_list.insert(view, data, nil, cs_chat_list_style_uri, cs_chat_list_style_16)
  elseif font_size == "20" then
    ui_widget.ui_chat_list.insert(view, data, nil, cs_chat_list_style_uri, cs_chat_list_style_20)
  else
    ui_widget.ui_chat_list.insert(view, data)
  end
  kuafu_pre_time = os.time()
  has_kuafu_msg = true
  set_kuafu_visible(true)
  local chat_list = get_chat_list(view.parent)
  local scroll = chat_list.scroll
  if scroll == 0 then
    scroll = 1
  end
  if scroll == 1 then
    chat_list.scroll = 1
    on_scroll_bottom_not_main(extra_scroll_bottom)
  else
    kuafu_flicker.visible = true
  end
end
function on_scroll_bottom_not_main_mouse()
  if kuafu_flicker.visible then
    kuafu_flicker.visible = false
  end
end
function insert_text(data, window, flash)
  local wnd = window.window
  local view = get_page_list(wnd)
  if data.channel == bo2.eChatChannel_Fight or flash then
    local txt = data.text
    if window.last_fight_msg == txt and window.last_fight_flag == true then
      local list = view.svar.chat_list_data.view
      if list.item_count - 1 > 0 then
        local fader = list:item_get(list.item_count - 1):search("fader")
        fader.visible = true
        fader:reset(1, 0, 1000)
        return
      end
    end
    window.last_fight_msg = txt
    window.last_fight_flag = true
  else
    window.last_fight_flag = false
  end
  if font_size == "16" then
    ui_widget.ui_chat_list.insert(view, data, nil, cs_chat_list_style_uri, cs_chat_list_style_16)
  elseif font_size == "20" then
    ui_widget.ui_chat_list.insert(view, data, nil, cs_chat_list_style_uri, cs_chat_list_style_20)
  else
    ui_widget.ui_chat_list.insert(view, data)
  end
end
function on_flash_stop(con)
  con.visible = false
end
function cmd_transport_exec(text, pos, id, name)
  local v = sys.variant()
  v:set(packet.key.chat_channel_id, id)
  v:set(packet.key.chat_text, text)
  if id == bo2.eChatChannel_PersonalChat and name ~= nil then
    if name == bo2.player.name and channels_list[current_channel].id == bo2.eChatChannel_PersonalChat then
      show_ui_msg(ui.get_text("chat|say_self"))
      return
    end
    v:set(packet.key.target_name, name)
  end
  bo2.send_variant(packet.eCTS_UI_Chat, v)
end
function test_transport(text)
  if text:substr(0, 1) == sys.wstring("/") then
    local trim_pos = text:find(sys.wstring(" "))
    if trim_pos ~= -1 then
      local str = text:substr(1, trim_pos - 1)
      for i, v in ipairs(channels_list) do
        if v.transport == 1 and (v.name == str or tostring(v.symbol) == tostring(str) or string.upper(tostring(v.symbol)) == tostring(str)) then
          local str1 = text:substr(trim_pos + 1)
          if v.id == bo2.eChatChannel_PersonalChat then
            local tmp = text:substr(trim_pos + 1)
            local name, send_text = tmp:split2(sys.wstring(" "))
            if name == nil or name.empty then
              return false
            else
              cmd_transport_exec(send_text, trim_pos, v.id, name)
              return true
            end
          else
            cmd_transport_exec(text:substr(trim_pos + 1), trim_pos, v.id)
          end
          return true
        end
      end
    else
      for i, v in ipairs(channels_list) do
        local str = text:substr(1, text.size)
        if v.transport == 1 and (str == v.name or tostring(v.symbol) == tostring(str) or string.upper(tostring(v.symbol)) == tostring(str)) then
          set_channel(v.id)
          return true
        end
      end
      local str2 = text:substr(1, text.size)
      for i = 0, bo2.gv_skill_group.size - 1 do
        local excel = bo2.gv_skill_group:get(i)
        if excel == nil then
          return true
        end
        if excel.xinfa and excel.xinfa ~= 0 then
          local type = bo2.gv_xinfa_list:find(excel.xinfa).type_id
          if bo2.eXinFaType_Etiquette == type and excel.name == str2 then
            local info = ui.skill_find(excel.id)
            if info == nil then
              return
            end
            bo2.use_skill(excel.id)
            return true
          end
        end
      end
    end
  end
  return false
end
function cmd_exec(text)
  if text.size > 500 then
    show_ui_msg(ui.get_text("chat|too_more_char"))
    return
  end
  if test_transport(text) == true then
    return
  end
  if channels_list[current_channel].id == bo2.eChatChannel_PersonalChat then
    if target_name.empty then
      show_ui_msg(ui.get_text("chat|no_target_name"))
      return
    elseif target_name == bo2.player.name then
      show_ui_msg(ui.get_text("chat|say_self"))
      return
    end
  end
  local v = sys.variant()
  v:set(packet.key.chat_channel_id, channels_list[current_channel].id)
  v:set(packet.key.chat_text, text)
  if target_name ~= nil then
    v:set(packet.key.target_name, target_name)
    ui_chat.w_personal_list.visible = false
    local target_masked = ui_qchat.w_personal_name:search("text").text
  end
  bo2.send_variant(packet.eCTS_UI_Chat, v)
end
function remember_name(target_name)
  ui_qchat.remember_name(target_name)
end
function check_limit(c, s, im)
  if s >= c.limit then
    if im then
      ui_im.insert_msg(c.topper, ui.get_text("chat|too_many_char"))
    else
      show_ui_msg(ui.get_text("chat|too_many_char"))
    end
  end
end
function insert_mtf_link(stk, rank)
  if rank == nil then
    rank = ui.mtf_rank_system
  end
  if ui_im.find_focus_dialog() ~= nil then
    local box = ui_im.friend_dialog_list[ui_im.find_focus_dialog()].item:search("input")
    if stk.size + box.mtf.size < 500 then
      box:insert_mtf(stk, rank)
    else
      ui_im.insert_msg(box.topper, amount_limit_warning)
    end
  elseif ui_qchat.w_input.focus then
    if 500 > stk.size + ui_qchat.w_input.mtf.size then
      ui_qchat.w_input:insert_mtf(stk, rank)
    else
      show_ui_msg(amount_limit_warning)
    end
  elseif ui_stall.chat.gx_chat_inputbox.focus then
    if 500 > stk.size + ui_qchat.w_input.mtf.size then
      ui_stall.chat.gx_chat_inputbox:insert_mtf(stk, rank)
    else
      show_ui_msg(amount_limit_warning)
    end
  end
end
function insert_item(excel_id, code)
  local stk
  if code == nil then
    stk = sys.format("<i:%d>", excel_id)
  else
    local excel = ui.item_get_excel(excel_id)
    if excel.consume_mode == bo2.eItemConsumeMod_Stack then
      stk = sys.format("<i:%d>", excel_id)
    else
      stk = sys.format("<fi:%s>", code)
    end
  end
  local rank = ui.mtf_rank_system
  insert_mtf_link(stk, rank)
end
function insert_ridepet(code)
  local stk = sys.format("<ridepet:%s>", code)
  insert_mtf_link(stk)
end
function insert_skill(excel_id, level, type)
  ui.log("insert_skill id = %s, level %s type %s", excel_id, level, type)
  local stk = sys.format("<skill:%s,%s,%s>", excel_id, level, type)
  local rank = ui.mtf_rank_system
  if ui_im.find_focus_dialog() ~= nil then
    local box = ui_im.friend_dialog_list[ui_im.find_focus_dialog()].item:search("input")
    check_limit(box, stk.size + box.text.size, 1)
    box:insert_mtf(stk, rank)
  elseif ui_qchat.w_input.focus then
    check_limit(ui_qchat.w_input, stk.size + ui_qchat.w_input.text.size)
    ui_qchat.w_input:insert_mtf(stk, rank)
  end
end
function insert_xinfa(excel_id, level)
  local stk = sys.format("<xinfa:%s,%s>", excel_id, level)
  local rank = ui.mtf_rank_system
  if ui_im.find_focus_dialog() ~= nil then
    local box = ui_im.friend_dialog_list[ui_im.find_focus_dialog()].item:search("input")
    check_limit(box, stk.size + box.text.size, 1)
    box:insert_mtf(stk, rank)
  elseif ui_qchat.w_input.focus then
    check_limit(ui_qchat.w_input, stk.size + ui_qchat.w_input.text.size)
    ui_qchat.w_input:insert_mtf(stk, rank)
  end
end
function insert_arena(arena_id, name)
  local stk = sys.format("<arena:%s,%s>", arena_id, name)
  local rank = ui.mtf_rank_system
  if ui_im.find_focus_dialog() ~= nil then
    local box = ui_im.friend_dialog_list[ui_im.find_focus_dialog()].item:search("input")
    check_limit(box, stk.size + box.text.size, 1)
    box:insert_mtf(stk, rank)
  elseif ui_qchat.w_input.focus then
    check_limit(ui_qchat.w_input, stk.size + ui_qchat.w_input.text.size)
    ui_qchat.w_input:insert_mtf(stk, rank)
  else
    ui_qchat.w_qchat.visible = true
    ui_qchat.w_input.focus = true
    check_limit(ui_qchat.w_input, stk.size + ui_qchat.w_input.text.size)
    ui_qchat.w_input:insert_mtf(stk, rank)
  end
end
function insert_matchscn(arena_id, name)
  local stk = sys.format("<matchscn:%s,%s>", arena_id, name)
  local rank = ui.mtf_rank_system
  if ui_im.find_focus_dialog() ~= nil then
    local box = ui_im.friend_dialog_list[ui_im.find_focus_dialog()].item:search("input")
    check_limit(box, stk.size + box.text.size, 1)
    box:insert_mtf(stk, rank)
  elseif ui_qchat.w_input.focus then
    check_limit(ui_qchat.w_input, stk.size + ui_qchat.w_input.text.size)
    ui_qchat.w_input:insert_mtf(stk, rank)
  else
    ui_qchat.w_qchat.visible = true
    ui_qchat.w_input.focus = true
    check_limit(ui_qchat.w_input, stk.size + ui_qchat.w_input.text.size)
    ui_qchat.w_input:insert_mtf(stk, rank)
  end
end
function insert_quest(excel_id)
  local stk = sys.format("<quest:%d>", excel_id)
  local rank = ui.mtf_rank_system
  if ui_im.find_focus_dialog() ~= nil then
    local box = ui_im.friend_dialog_list[ui_im.find_focus_dialog()].item:search("input")
    check_limit(box, stk.size + box.text.size, 1)
    box:insert_mtf(stk, rank)
  elseif ui_qchat.w_input.focus then
    check_limit(ui_qchat.w_input, stk.size + ui_qchat.w_input.text.size)
    ui_qchat.w_input:insert_mtf(stk, rank)
  end
end
function insert_copycontent(content)
  local rank = ui.mtf_rank_system
  if ui_im.find_focus_dialog() ~= nil then
    local box = ui_im.friend_dialog_list[ui_im.find_focus_dialog()].item:search("input")
    check_limit(box, content.size + box.text.size, 1)
    box:insert_mtf(content, rank)
  else
    ui_qchat.w_qchat.visible = true
    ui_qchat.w_input.focus = true
    check_limit(ui_qchat.w_input, content.size + ui_qchat.w_input.text.size)
    ui_qchat.w_input:insert_mtf(content, rank)
  end
end
function insert_milestone(quest_id, milestone_id)
  local stk = sys.format("<quest:%d>-<milestone:%d>", quest_id, milestone_id)
  local rank = ui.mtf_rank_system
  if ui_im.find_focus_dialog() ~= nil then
    local box = ui_im.friend_dialog_list[ui_im.find_focus_dialog()].item:search("input")
    check_limit(box, stk.size + box.text.size, 1)
    box:insert_mtf(stk, rank)
  elseif ui_qchat.w_input.focus then
    check_limit(ui_qchat.w_input, stk.size + ui_qchat.w_input.text.size)
    ui_qchat.w_input:insert_mtf(stk, rank)
  end
end
function on_char(box, ch)
  if ch == ui.VK_RETURN then
    enter_flag = true
  end
end
function translate_face(input_box)
  local text = input_box.mtf
  local txt_len = #text
  local index = text:rfind("/", txt_len)
  if index ~= -1 and txt_len - index < 8 then
    local src_str = text:substr(0, index)
    local face_str = text:substr(index, #text)
    local size = chat_expression_table.size
    for i = 0, size - 1 do
      local line = chat_expression_table:get(i)
      if line ~= nil and line.command == face_str then
        input_box.mtf = sys.format("%s<f:%d>", src_str, line.id)
        break
      end
    end
  end
end
function on_input(box, key, flag)
  if key == ui.VK_ESCAPE then
    ui_chat.w_personal_list.visible = false
  end
  if flag.down then
    return
  end
  local text = box.mtf
  check_limit(box, box.text.size)
  if key == ui.VK_RETURN and enter_flag == true then
    if text.empty then
      box.mtf = nil
      box.focus = false
      enter_flag = false
      ui_qchat.w_input.focus = false
      ui_qchat.w_qchat.visible = false
      return
    end
    box.mtf = nil
    target_name = ui_qchat.w_personal_name:search("text").text
    cmd_exec(text)
    box.focus = false
    enter_flag = false
    ui_qchat.w_input.focus = false
    ui_qchat.w_qchat.visible = false
    if target_name.empty and channels_list[current_channel].id == bo2.eChatChannel_PersonalChat then
      return
    end
    input_data_add(text)
    if target_name ~= nil and channels_list[current_channel].id == bo2.eChatChannel_PersonalChat then
      local input_name = target_name.trim
      for i, v in ipairs(person_name_list) do
        if v == input_name then
          return
        end
      end
      local rst, new_name = ui.check_name(input_name)
      if rst == bo2.eNameCheck_ErrNone then
        table.insert(person_name_list, new_name)
        ui_qchat.w_personal_name:search("text").text = input_name
        while #person_name_list > 6 do
          table.remove(person_name_list, 1)
        end
      end
    end
  elseif key == ui.VK_ESCAPE then
    box.focus = false
  elseif key == ui.VK_UP then
    input_data_roll(-1)
  elseif key == ui.VK_DOWN then
    input_data_roll(1)
  elseif key == ui.VK_TAB then
    ui_chat.w_personal_list.visible = false
    local tab_order = channels_list[current_channel].tab_order
    for i, v in ipairs(channel_btns) do
      if tab_order == #channel_btns then
        set_channel(channel_btns[1].id)
        break
      end
      if v.tab_order == tab_order + 1 then
        set_channel(channel_btns[i].id)
        break
      end
    end
  elseif key == ui.VK_MENU then
    ui_chat.w_personal_list.visible = false
    local tab_order = channels_list[current_channel].tab_order
    if tab_order == 1 then
      tab_order = #channel_btns + 1
    end
    for i, v in ipairs(channel_btns) do
      if v.tab_order == tab_order - 1 then
        set_channel(v.id)
        break
      end
    end
  else
    translate_face(box)
  end
end
function on_new_window(btn)
  local config = {
    area = ui.rect(0, 200, 290, 350),
    list = {}
  }
  create_extra_window(config)
  w_chat_channel.visible = false
  display(windows_list[#windows_list])
end
function on_hide_window(btn)
end
function create_extra_window(window_config)
  local item = ui.create_control(ui.find_control("$phase:main"), panel)
  item:load_style("$frame/chat/cha_console.xml", "extra_chat_console")
  local list = {}
  if window_config.area == nil then
    window_config.area = ui.rect(0, 0, 400, 150)
  end
  item.area = window_config.area
  local twnd = {}
  twnd.control = w_extra_channel_list
  twnd.window = item
  item.svar.chat_list = item:search("chat_list")
  twnd.define = 1
  local drag = item:search("drag_mover"):find_plugin("drag")
  drag.target = item
  for i, v in ipairs(channels_list) do
    table.insert(list, {
      name = channels_list[i].name,
      enable = channels_list[i].enable
    })
    local name = v.name
    if window_config.list[name] then
      list[i].enable = window_config.list[name].enable
    end
  end
  twnd.list = windows_list[#windows_list].list
  table.insert(windows_list, twnd)
  create_extra_channellist(windows_list[#windows_list])
  item.visible = true
  table.insert(hide_windows, item:search("extra_corner"))
  table.insert(hide_windows, item:search("extra_bg"))
end
function find_index(id)
  for i, v in ipairs(channels_list) do
    if v.id == id then
      return i
    end
  end
end
function on_extra_channel(btn, msg, flag)
  local current_chat = btn.topper
  if msg == ui.mouse_enter then
    current_chat:search("extra_chat_channel").image = "$image/phase/btn_option_1.png"
  end
  if msg == ui.mouse_leave then
    current_chat:search("extra_chat_channel").image = "$image/phase/btn_option_0.png"
  end
  if msg == ui.mouse_lbutton_down then
    local index = btn.var:ref("window_index"):get("window_index").v_int
    current_chat:search("extra_chat_channel").visible = not current_chat:search("extra_chat_channel").visible
    if current_chat:search("extra_chat_channel").visible == false then
      local channel_list = windows_list[index].control.var:ref("channel_list")
      for i, v in ipairs(windows_list[index].list) do
        if channel_list:has(i) then
          v.enable = channel_list:ref(i):get("check").v_object.check
        end
      end
      display(windows_list[index])
    end
  end
end
function on_close_window(btn)
  btn.topper:post_release()
end
function on_extra_chat_close(win)
end
function insert_tab(tab, name)
  local btn_uri = "$frame/chat/cha_console.xml"
  local btn_sty = "btn_chat_tab"
  local page_uri = "$frame/chat/cha_console.xml"
  local page_sty = "con_page"
  ui_tab.insert_suit(tab, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(tab, name)
  btn:search("text").text = name
  return ui_tab.get_page(tab, name)
end
function on_tab_btn(btn)
  local flag = true
  for i, v in ipairs(windows_list) do
    if i < #windows_list then
      local temp_btn = ui_tab.get_button(w_chat_page, v.name)
      temp_btn:search("figure").visible = false
      temp_btn:search("text").text = v.name
    end
  end
  if btn == ui_tab.get_button(w_chat_page, windows_list[#windows_list - 1].name) then
    flag = false
  end
  btn:search("figure").visible = true
  if flag == true then
    w_btn_detach.visible = false
  else
    w_btn_detach.visible = true
  end
  chat_cmn_setup.visible = false
end
function on_lock_btn(btn)
  w_corner.enable = not w_corner.enable
  w_corner.visible = not w_corner.visible
  extra_corner_btn.enable = w_corner.enable
  extra_corner_btn.visible = w_corner.visible
  w_sys_corner.enable = w_corner.enable
  w_sys_corner.visible = w_corner.visible
  btn_lock.visible = not btn_lock.visible
  btn_unlock.visible = not btn_unlock.visible
  chat_save()
end
function set_main_visible(b)
  for i, v in ipairs(hide_windows) do
    if b then
      v:reset(v.alpha, 1, 1000)
    else
      v:reset(v.alpha, 0, 1000)
    end
  end
  for i, v in ipairs(hide_windows2) do
    if b then
      v:reset(v.alpha, 1, 1000)
    else
      v:reset(v.alpha, 0, 1000)
    end
  end
  if b then
    w_channel_btns:reset(w_channel_btns.alpha, 1, 1000)
    tab_fader:reset(tab_fader.alpha, 1, 1000)
    extra_corner_btn:reset(extra_corner_btn, 1, 1000)
    drag_btn:reset(drag_btn, 1, 1000)
    extra_undetach_btn:reset(extra_undetach_btn, 1, 1000)
    extra_scroll_bottom:reset(extra_scroll_bottom, 1, 1000)
    extra_scroll_top:reset(extra_scroll_top, 1, 1000)
    main_scroll_bottom:reset(main_scroll_bottom, 1, 1000)
    main_scroll_top:reset(main_scroll_top, 1, 1000)
    main_lock_btn:reset(main_lock_btn, 1, 1000)
    w_slider_page:reset(w_slider_page, 1, 1000)
  else
    w_channel_btns:reset(w_channel_btns.alpha, 0, 1000)
    tab_fader:reset(tab_fader.alpha, 0, 1000)
    extra_corner_btn:reset(extra_corner_btn, 0, 1000)
    drag_btn:reset(drag_btn, 0, 1000)
    extra_undetach_btn:reset(extra_undetach_btn, 0, 1000)
    extra_scroll_bottom:reset(extra_scroll_bottom, 0, 1000)
    extra_scroll_top:reset(extra_scroll_top, 0, 1000)
    main_scroll_bottom:reset(main_scroll_bottom, 0, 1000)
    main_scroll_top:reset(main_scroll_top, 0, 1000)
    main_lock_btn:reset(main_lock_btn, 0, 1000)
    w_slider_page:reset(w_slider_page, 0, 1000)
  end
end
function set_kuafu_visible(b)
  for i, v in ipairs(hide_windows1) do
    if b then
      v:reset(v.alpha, 1, 1000)
    else
      v:reset(v.alpha, 0, 1000)
    end
  end
end
function set_main_mouse_able(b)
  w_corner.mouse_able = b
end
function on_stop(con)
  if con.alpha == 1 then
    set_main_mouse_able(true)
  else
    set_main_mouse_able(false)
  end
end
function on_timer2()
  local b = w_main_kuafu:test_mouse_in()
  if mouse_in_kuafu == false then
    if b == true then
      mouse_in_kuafu = true
      set_kuafu_visible(true)
    end
  elseif mouse_in_kuafu == true and b == false then
    mouse_in_kuafu = false
    kuafu_pre_time = os.time()
    has_kuafu_msg = true
  end
  if has_kuafu_msg then
    kuafu_cur_time = os.time()
    if b then
      mouse_in_kuafu = true
      set_kuafu_visible(true)
      has_kuafu_msg = false
    end
    if kuafu_cur_time - kuafu_pre_time >= 10 then
      set_kuafu_visible(false)
      has_kuafu_msg = false
    else
      set_kuafu_visible(true)
    end
  end
end
function on_timer()
  local b = w_main_chat:test_mouse_in()
  local be = w_extra_chat:test_mouse_in()
  b = b or be
  if mouse_in_main == false then
    if b == true then
      mouse_in_main = true
      set_main_visible(true)
    end
  elseif mouse_in_main == true then
    if b == false then
      mouse_in_main = false
      has_main_msg = true
      main_pre_time = os.time()
    elseif b then
      main_pre_time = os.time()
    end
  end
  if has_main_msg then
    main_cur_time = os.time()
    if main_cur_time - main_pre_time >= 10 then
      set_main_visible(false)
      has_main_msg = false
    end
  end
end
function on_ime_click(btn)
  ui_tool.ui_ime.show_profiles(btn)
end
function on_ime_update(ime_p, ime_d)
  local ime_icon = ime_d.icon
  if ime_icon.empty then
    w_ime_fig.visible = true
    w_ime_icon.visible = false
    w_ime_lb.visible = true
    local sn = ime_d.short_name
    if sn.empty then
      w_ime_lb.text = "A"
    else
      w_ime_lb.text = sn
    end
  else
    w_ime_fig.visible = false
    w_ime_icon.visible = true
    w_ime_lb.visible = false
    w_ime_icon.image = ime_icon
  end
  local n = ime_d.name
  if n.empty then
    ime_p.owner.tip.text = ime_tip
  else
    ime_p.owner.tip.text = n
  end
end
function init_channels_list()
  for i = 0, bo2.gv_chat_list.size - 1 do
    local excel = bo2.gv_chat_list:get(i)
    if excel.display == 1 then
      local b_click_able = true
      if excel.click_able == 0 then
        b_click_able = false
      end
      table.insert(channels_list, {
        name = excel.name,
        enable = true,
        click_able = b_click_able,
        id = excel.id,
        always_display = excel.always_display,
        item = nil,
        transport = excel.transport,
        symbol = excel.symbol,
        tab_order = excel.tab_order
      })
    end
  end
end
function init_main_window()
  ui_tab.make_data(w_chat_page).tokey = function(s)
    return s
  end
  for i = 0, bo2.gv_chat_combined_channel.size - 1 do
    local excel = bo2.gv_chat_combined_channel:get(i)
    local main_config = {}
    for i, v in ipairs(channels_list) do
      table.insert(main_config, {
        name = v.name,
        enable = false
      })
    end
    for j = 0, excel.channels.size - 1 do
      local chat_excel = bo2.gv_chat_list:find(excel.channels[j])
      if chat_excel then
        local index = find_index(chat_excel.id)
        if index then
          main_config[find_index(chat_excel.id)].enable = true
        else
          ui.log("init_main_window index not find .id:%s", chat_excel.id)
        end
      else
        ui.log("%s:channels:id:%s not find in chat_list", excel.name, excel.channels[j])
      end
    end
    local page = insert_tab(w_chat_page, excel.name)
    page.svar.chat_list = page:search("chat_list")
    table.insert(windows_list, {
      name = excel.name,
      window = page,
      control = w_channel_list,
      list = main_config,
      define = excel.define,
      main_window = true
    })
    table.insert(hide_windows, page:search("slider"))
  end
end
function on_init()
  enter_flag = false
  channels_list = {}
  windows_list = {}
  chat_data = {}
  person_name_list = {}
  person_name_size = 0
  channel_btns = {}
  current_channel = 1
  b_define_setup = false
  mouse_in_main = false
  mouse_in_kuafu = false
  mouse_in_extra = false
  hide_windows = {}
  hide_windows = {w_main_bg, w_corner}
  hide_windows2 = {}
  hide_windows2 = {w_default_btns}
  hide_windows1 = {}
  hide_windows1 = {
    w_sys_main_bg,
    w_sys_corner,
    w_con_page,
    w_slider_page,
    kuafu_scroll_bottom,
    kuafu_scroll_top
  }
  table.insert(hide_windows1, w_sys_page:search("slider_fader"))
  init_channels_list()
  init_main_window()
  init_setup_window()
  font_size = 12
  last_fight_msg = nil
  g_is_loading = true
  g_is_loading = false
  local extra_setup = ui.create_control(ui.find_control("$phase:main"), "panel")
  extra_setup:load_style("$frame/chat/cha_console.xml", "chat_extra_setup")
  windows_list[#windows_list].control = w_extra_channel_list
  create_channellist(windows_list[1])
  ui_tab.show_page(w_chat_page, windows_list[COMPOSITE_INDEX].name, true)
  on_tab_btn(ui_tab.get_button(w_chat_page, windows_list[COMPOSITE_INDEX].name))
  on_new_window()
  w_extra_chat.visible = false
  set_kuafu_visible(false)
  set_main_visible(false)
  set_main_mouse_able(false)
  ui_tab.get_show_page(w_chat_page):search("chat_list").scroll = 1
  ui_tab.get_show_page(w_chat_page):search("page_list").svar.chat_list_data.bottom = true
  w_main_kuafu:search("page_list").parent:search("chat_list").scroll = 1
  w_main_kuafu:search("page_list").svar.chat_list_data.bottom = true
  on_scroll_bottom_not_main(extra_scroll_bottom)
  sys.pcall(chat_load)
end
function chat_load()
  local cfg = ui_main.player_cfg_load("chat.xml")
  local chat
  if cfg ~= nil then
    chat = cfg:find("chat")
    local xnode, x
    if chat then
      xnode = chat:find("setup")
      x = xnode:get_attribute("font_size")
      set_font({
        size = tostring(x)
      })
      x = xnode:get_attribute("setup_display_flag")
      if tostring(x) == "1" then
        setup_display({value = true})
      elseif tostring(x) == "0" then
        setup_display({value = false})
      end
      x = xnode:get_attribute("drag_lock_flag")
      if tostring(x) == "true" then
        w_corner.enable = true
        w_corner.visible = true
        extra_corner_btn.enable = true
        extra_corner_btn.visible = true
        w_sys_corner.enable = true
        w_sys_corner.visible = true
        btn_lock.visible = true
        btn_unlock.visible = false
      elseif tostring(x) == "false" then
        w_corner.enable = false
        w_corner.visible = false
        extra_corner_btn.enable = false
        extra_corner_btn.visible = false
        w_sys_corner.enable = false
        w_sys_corner.visible = false
        btn_lock.visible = false
        btn_unlock.visible = true
      end
      local extra_node, extra_x, extra_y, extra_x0, extra_y0, extra_v
      extra_node = chat:find("extra")
      extra_x = extra_node:get_attribute("size_x")
      extra_y = extra_node:get_attribute("size_y")
      extra_x0 = extra_node:get_attribute("start_x")
      extra_y0 = extra_node:get_attribute("start_y")
      extra_v = extra_node:get_attribute("visible")
      if tostring(extra_v) == "true" then
        w_extra_chat.visible = true
        on_detach_set()
      elseif tostring(extra_v) == "false" then
        w_extra_chat.visible = false
        on_extra_undetach_set()
      end
      w_extra_chat.dx = tonumber(tostring(extra_x))
      w_extra_chat.dy = tonumber(tostring(extra_y))
      w_extra_chat.x = tonumber(tostring(extra_x0))
      w_extra_chat.y = tonumber(tostring(extra_y0))
      local main_node, main_x, main_y
      main_node = chat:find("main")
      if not main_node then
        return
      end
      main_x = main_node:get_attribute("size_x")
      main_y = main_node:get_attribute("size_y")
      w_main_chat.dx = tonumber(tostring(main_x))
      w_main_chat.dy = tonumber(tostring(main_y))
      local kuafu_node, kuafu_x, kuafu_y
      kuafu_node = chat:find("kuafu")
      kuafu_x = kuafu_node:get_attribute("size_x")
      kuafu_y = kuafu_node:get_attribute("size_y")
      w_main_kuafu.dx = tonumber(tostring(kuafu_x))
      w_main_kuafu.dy = tonumber(tostring(kuafu_y))
      w_chat_panel.dx = tonumber(tostring(kuafu_x))
      w_chat_panel.dy = w_main_chat.dy + w_main_kuafu.dy + 26
      for i = 1, #windows_list do
        local xnode = chat:find(sys.format("window%d", i))
        if not xnode then
          return
        end
        for index = 1, #channels_list do
          local x
          local ch = channels_list[index]
          if xnode:has_attribute(ch.name) then
            x = xnode:get_attribute(ch.name)
          else
            x = xnode:get_attribute("c" .. ch.id)
          end
          if tostring(x) == "true" then
            windows_list[i].list[index].enable = true
          elseif tostring(x) == "false" then
            windows_list[i].list[index].enable = false
          end
        end
      end
    end
  end
  ui_tab.get_show_page(w_chat_page):search("chat_list").scroll = 1
  ui_tab.get_show_page(w_chat_page):search("page_list").svar.chat_list_data.bottom = true
  w_main_kuafu:search("page_list").parent:search("chat_list").scroll = 1
  w_main_kuafu:search("page_list").svar.chat_list_data.bottom = true
end
function on_kuafu_corner_click(btn)
  chat_save()
end
function on_corner_click(btn)
  chat_save()
end
function chat_save()
  if g_is_loading then
    return
  end
  local root = ui_main.player_cfg_load("chat.xml")
  if root == nil then
    root = sys.xnode()
  end
  local chat = root:get("chat")
  chat:clear()
  local x = chat:add("setup")
  x:set_attribute("font_size", font_size)
  x:set_attribute("setup_display_flag", setup_display_flag)
  x:set_attribute("drag_lock_flag", w_corner.visible)
  for i = 1, #windows_list do
    local x = chat:add(sys.format("window%d", i))
    for index = 1, #channels_list do
      x:set_attribute("c" .. channels_list[index].id, windows_list[i].list[index].enable)
    end
  end
  local extra = chat:add("extra")
  extra:set_attribute("size_x", w_extra_chat.size.x)
  extra:set_attribute("size_y", w_extra_chat.size.y)
  extra:set_attribute("start_x", w_extra_chat.x)
  extra:set_attribute("start_y", w_extra_chat.y)
  extra:set_attribute("visible", w_extra_chat.visible)
  local main = chat:add("main")
  main:set_attribute("size_x", w_main_chat.size.x)
  main:set_attribute("size_y", w_main_chat.size.y)
  local kuafu = chat:add("kuafu")
  kuafu:set_attribute("size_x", w_main_kuafu.size.x)
  kuafu:set_attribute("size_y", w_main_kuafu.size.y)
  ui_main.player_cfg_save(root, "chat.xml")
end
function on_main_corner(btn, msg)
  if msg == ui.mouse_enter then
    corner_flag_main = true
    corner_flag_kuafu = false
  end
end
function on_kuafu_corner(btn, msg)
  if msg == ui.mouse_enter then
    corner_flag_kuafu = true
    corner_flag_main = false
  end
end
function on_main_moving(v)
  if corner_flag_main == true then
    w_main_chat.dy = w_chat_panel.dy - w_main_kuafu.dy - 26
    w_main_chat:apply_dock(true)
    if w_main_chat.dy <= 128 then
      w_chat_panel.dy = w_main_kuafu.dy + 154
      w_main_chat.dy = 128
    end
    for k, v in pairs(windows_list) do
      local view = v.window:search("chat_list")
      view.scroll = 1
      v.window:search("page_list").svar.chat_list_data.bottom = true
    end
  elseif corner_flag_kuafu == true then
    w_main_kuafu.dy = w_chat_panel.dy - w_main_chat.dy - 26
    w_main_kuafu:apply_dock(true)
    if w_main_kuafu.dy <= 100 then
      w_chat_panel.dy = w_main_chat.dy + 126
      w_main_kuafu.dy = 100
    end
    w_main_kuafu:search("chat_list").scroll = 1
    w_main_kuafu:search("page_list").svar.chat_list_data.bottom = true
  end
  chat_save()
end
function on_extra_move(v)
  local b = w_extra_chat:test_mouse_in()
  if not b then
    return
  end
  chat_save()
end
init_once()
