local g_current_camera_excel
local g_current_camera_index = 0
local g_current_tick = 0
local g_text_count = 0
local g_skip_camera_excel
citem_url = L("$frame/mask/mask.xml")
citem_name = L("talk_item")
local g_item_display_frame = 750
local g_talk_item_data = {}
g_talk_item_index = 0
function on_init_item_data()
  on_clear_talk_data()
  on_clear_film_skip_data()
end
function on_clear_film_skip_data()
  if sys.check(g_film_skip_list_root) then
    g_film_skip_list_root:item_clear()
  end
end
function on_clear_talk_data()
  g_talk_item_index = 0
  g_talk_list_root:item_clear()
end
function on_subtitle_insert_data(main, name, text)
  if sys.check(main) ~= true then
    return false
  end
  local root_view = main:search("chat_list")
  if sys.check(root_view) ~= true then
    return
  end
  local root = root_view.root
  if sys.check(root) ~= true then
    return false
  end
  local real_text_data
  if name ~= nil and name.empty ~= true then
    real_text_data = sys.format(L("<a+:l><c+:d3a75e>%s<c->:%s<a->"), name, text)
  else
    real_text_data = sys.format(L("<a+:l>%s<a->"), text)
  end
  local function on_set_item_data(item)
    local rb_box = item:search("npc_talk_text")
    if sys.check(rb_box) then
      rb_box.mtf = real_text_data
      rb_box.parent:tune("npc_talk_text")
    end
  end
  local root_count = root.item_count
  if root_count >= 2 then
    root:item_remove(0)
  end
  local item = root:item_append()
  item.obtain_title:load_style(citem_url, citem_name)
  on_set_item_data(item)
  item:scroll_to_visible()
  local function on_timeout_remove_data()
    if sys.check(main) ~= true then
      return
    end
    if main.visible == false then
      return
    end
    if sys.check(item) ~= true then
      return
    end
    if sys.check(root_view) ~= true then
      return
    end
    root_view.scroll = 1
    item:self_remove()
  end
  bo2.AddTimeEvent(g_item_display_frame, on_timeout_remove_data)
end
function insert_talk_data(name, text)
  on_subtitle_insert_data(ui_mask.w_main, name, text)
end
function insert_film_skip_data(_cha_name)
  local root_view = ui_mask.g_film_skip_list
  if sys.check(root_view) ~= true then
    return
  end
  local root = root_view.root
  if sys.check(root) ~= true then
    return false
  end
  local real_text_data = ui_widget.merge_mtf({name = _cha_name}, ui.get_text("video|skip_film"))
  local function on_set_item_data(item)
    local rb_box = item:search("npc_talk_text")
    if sys.check(rb_box) then
      rb_box.mtf = real_text_data
      rb_box.parent:tune("npc_talk_text")
    end
  end
  local item = root:item_append()
  item.obtain_title:load_style(citem_url, "skip_item")
  on_set_item_data(item)
end
function runf_talk(v_talk)
  if v_talk == nil then
    return
  end
  local talk_excel = bo2.gv_text:find(v_talk.v_int)
  if talk_excel == nil then
    return
  end
  insert_talk_data(nil, talk_excel.text)
end
function on_window_unvisible()
  if bo2.GetCameraControlExist() == true then
    if ui_mask.w_main.visible ~= true then
      ui_mask.w_main.visible = true
    end
    return false
  else
    on_init_item_data()
    ui_main.ShowUI(true, 0, 1)
    return true
  end
end
function on_check_may_skip_film(excel_data)
  if sys.check(excel_data) ~= true then
    return false
  end
  local skip_type = excel_data.skip_type
  if skip_type == 0 then
    return false
  end
  return true
end
function on_click_skip_film()
  if on_check_may_skip_film(g_skip_camera_excel) ~= true then
    ui_mask.w_bottom_mask.visible = false
    return false
  end
  on_close_second_confirm()
end
function on_handle_FilmSkpRST(cmd, data)
  local _cha_name = data:get(packet.key.cha_name).v_string
  insert_film_skip_data(_cha_name)
end
function on_close_second_confirm()
  if sys.check(g_skip_camera_excel) and on_check_may_skip_film(g_skip_camera_excel) ~= true then
    ui_mask.w_bottom_mask.visible = false
    return
  end
  local on_msg_callback = function(msg)
    if msg.result == 1 then
      ui_mask.w_main.focus = true
      bo2.send_variant(packet.eCTS_UI_ServerFilmSkip, v)
      return
    end
    if sys.check(ui_mask.w_main) and ui_mask.w_main.visible == true then
      ui_mask.w_main.focus = true
    end
  end
  local scn = bo2.scn
  if sys.check(scn) and scn.scn_excel.id == 143 then
    local check = ui_film.check_skip()
    if check == nil or check == false then
      ui_mask.w_bottom_mask.visible = false
      return
    end
    local text_excel = bo2.gv_text:find(2043)
    if text_excel == nil then
      return
    end
    local quit_text = text_excel.text
    g_second_confirm_data = {
      text = quit_text,
      btn_confirm = ui.get_text("film|skip"),
      btn_cancel = ui.get_text("film|cancel_skip"),
      owner = ui_film.w_main,
      btn2 = true,
      callback = on_msg_callback,
      is_valid = true
    }
    ui_widget.ui_msg_box.show_common(g_second_confirm_data)
  else
    g_second_confirm_data = {
      text = ui.get_text("film|skip_film"),
      btn_confirm = ui.get_text("film|skip"),
      btn_cancel = ui.get_text("film|cancel_skip"),
      owner = ui_film.w_main,
      btn2 = true,
      callback = on_msg_callback,
      is_valid = true
    }
    ui_widget.ui_msg_box.show_common(g_second_confirm_data)
  end
end
function on_mask_key(w, key, flag)
  if key == ui.VK_ESCAPE then
    if flag.down == true then
      return
    end
    if ui_mask.w_bottom_mask.visible == false and bo2.GetCameraControlExist() == true then
      return
    end
    on_close_second_confirm()
  else
    ui_main.on_key(w, key, flag)
  end
end
function on_esc_stk_visible(w, vis)
  if vis then
    w:move_to_head()
    ui_main.ShowUI(false)
    fader_vis()
    bo2.ShowSelGfx(false)
    bo2.SetCamfar(500)
    ui_mask.w_main.focus = true
    function on_move_to_head()
      ui_mask.w_main.focus = true
      if sys.check(w) then
        w:move_to_head()
      end
    end
    bo2.AddTimeEvent(5, on_move_to_head)
  else
    local r = on_window_unvisible()
    if r == true then
      if g_second_confirm_data ~= nil and g_second_confirm_data.is_valid == true then
        ui_widget.ui_msg_box.cancel(g_second_confirm_data)
      end
      g_second_confirm_data = {is_valid = false}
      bo2.ShowSelGfx(true)
      bo2.SetCamfar(0)
    end
  end
end
function fader_vis()
  if sys.check(ui_npcfunc.ui_talk.w_talk) ~= false then
    ui_npcfunc.ui_talk.on_set_disable_fader_show(true)
    ui_npcfunc.ui_talk.on_click_close_talk()
    ui_npcfunc.ui_talk.on_set_disable_fader_show(false)
  end
  if sys.check(ui_skill_preview) then
    ui_skill_preview.w_skill_preview.visible = false
  end
  if sys.check(ui_mask.w_camera_mask) then
    ui_mask.w_camera_mask.alpha = 1
    ui_mask.w_camera_mask:reset(1, 0, 1000)
  end
  if sys.check(ui_mask.g_film_text_timer) then
    ui_mask.g_film_text_timer.suspended = false
    g_text_count = 0
  end
end
function on_timer_set_text()
  if ui_mask.w_main.visible ~= true then
    g_film_text_timer.suspended = true
    g_text_count = 0
    return
  end
  if g_text_count > 5 then
    g_text_count = 0
  end
  local get_text_name = sys.format("film|film_%d", g_text_count)
  lb_film_text.text = ui.get_text(get_text_name)
  g_text_count = g_text_count + 1
end
function run()
  ui_mask.w_main.visible = true
end
local function on_end_set_mask_timer()
  ui_mask.g_mask_timer.suspended = true
  g_current_camera_excel = nil
  g_skip_camera_excel = nil
end
function on_timer_mask_data()
  if sys.check(g_current_camera_excel) ~= true then
    ui_mask.g_mask_timer.suspended = true
    return
  end
  if g_current_camera_excel.inc_ui_mask.size <= 0 or g_current_camera_index >= g_current_camera_excel.inc_ui_mask.size then
    ui_mask.g_mask_timer.suspended = true
    return
  end
  local mask_index = g_current_camera_excel.inc_ui_mask[g_current_camera_index]
  local mask_excel = bo2.gv_ui_mask_control:find(mask_index)
  if sys.check(mask_excel) ~= true then
    ui_mask.g_mask_timer.suspended = true
    return
  end
  if g_current_tick >= mask_excel.beg_frame then
    local mask_type = mask_excel.control_type
    if mask_type == 0 then
      local begin_alpha = mask_excel._vData0.v_number
      local end_alpha = mask_excel._vData1.v_number
      local last_second = mask_excel.last_frame * 40
      ui_mask.w_camera_mask:reset(begin_alpha, end_alpha, last_second)
    elseif mask_type == 1 then
    end
    g_current_camera_index = g_current_camera_index + 1
  end
  g_current_tick = g_current_tick + 1
end
function on_handle_vis_window(cmd, data)
  local cmd_type = data:get(packet.key.cmn_type).v_int
  local function on_end_set_mask_timer()
    ui_mask.g_mask_timer.suspended = true
    g_current_camera_excel = nil
    g_skip_camera_excel = nil
  end
  if cmd_type == 1 then
    if ui_mask.w_main.visible == false then
      ui_mask.w_main.visible = true
    end
  else
    bo2.InitCameraControl()
    ui_mask.w_main.visible = false
    on_end_set_mask_timer()
    return
  end
  local cmn_index = data:get(packet.key.cmn_index).v_int
  local camera_excel = bo2.gv_camera_control:find(cmn_index)
  if sys.check(camera_excel) ~= true then
    on_end_set_mask_timer()
    return
  end
  g_skip_camera_excel = camera_excel
  local on_set_disable_buttom = function(camera_excel)
    if on_check_may_skip_film(camera_excel) ~= true then
      ui_mask.w_bottom_mask.visible = false
      return false
    end
    local scn = bo2.scn
    if sys.check(scn) and scn.scn_excel.id == 143 then
      local check = ui_film.check_skip()
      if check == nil or check == false then
        ui_mask.w_bottom_mask.visible = false
        return
      end
    end
    ui_mask.w_bottom_mask.visible = true
  end
  on_set_disable_buttom(camera_excel)
  if camera_excel.inc_ui_mask.size <= 0 then
    g_current_camera_excel = nil
    ui_mask.g_mask_timer.suspended = true
    return
  end
  g_current_camera_excel = camera_excel
  g_current_camera_index = 0
  g_current_tick = 0
  ui_mask.g_mask_timer.suspended = false
end
function on_self_enter()
  bo2.InitCameraControl()
  on_window_unvisible()
  on_init_item_data()
  ui_mask.w_main.visible = false
end
function run_test()
  local var = sys.variant()
  var:set(packet.key.cmn_type, 1)
  var:set(packet.key.cmn_index, 1)
  on_handle_vis_window(1, var)
end
local sig_name = "ui_mask:on_handle_vis_window"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_Mask, on_handle_vis_window, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_mask.on_self_enter")
ui_packet.recv_wrap_signal_insert(packet.eSTC_Scn_ServerFilmSkipRST, on_handle_FilmSkpRST, "ui_mask.on_handle_FilmSkpRST")
function on_handle_outerconfig(cmd, data)
  if sys.check(ui_outer) ~= true then
    return
  end
  ui_outer.on_visible()
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_OuterConfig_Confirm, on_handle_outerconfig, "ui_mask.on_handle_outerconfig")
