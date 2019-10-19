function notify(text_id)
  local tt = bo2.gv_text:find(text_id)
  if tt == nil then
    return
  end
  local targets = tt.targets
  if targets.size > 0 then
    local chat = bo2.gv_chat_list:find(targets[0])
    if chat ~= nil then
      ui_tool.note_insert(tt.text, chat.color)
      return
    end
  end
  ui_tool.note_insert(tt.text)
end
function check_len(pw)
  if pw.size == 0 then
    return true
  elseif pw.size < 6 then
    notify(1383)
    return false
  elseif pw.size > 12 then
    notify(1370)
    return false
  end
  return true
end
function on_newitemcode()
  local on_msg_callback = function(ret)
    if ret.result == 1 then
      local ctrl = ret.window
      local input_ctrl = ctrl:search("input")
      local repeat_ctrl = ctrl:search("repeat")
      if input_ctrl.text == repeat_ctrl.text then
        if check_len(input_ctrl.text) then
          local v = sys.variant()
          v:set(packet.key.cmn_md5, input_ctrl.text.v_code)
          bo2.send_variant(packet.eCTS_Safe_SetItemCode, v)
        end
      else
        notify(1380)
      end
    end
  end
  local on_msg_init = function(data)
    local window = data.window
    window:tune_y("lb_desc")
  end
  local msg = {
    detail = L("passwd_new_input"),
    style_uri = "$frame/safe/safe.xml",
    style_name = "passwd_new_input",
    callback = on_msg_callback,
    init = on_msg_init
  }
  ui_widget.ui_msg_box.show(msg)
end
function on_chgitemcode()
  local on_msg_callback = function(ret)
    if ret.result == 1 then
      local ctrl = ret.window
      local input_ctrl = ctrl:search("input")
      local repeat_ctrl = ctrl:search("repeat")
      if input_ctrl.text == repeat_ctrl.text then
        if check_len(input_ctrl.text) then
          local old_ctrl = ctrl:search("old")
          local v = sys.variant()
          v:set(packet.key.cmn_name, old_ctrl.text.v_code)
          v:set(packet.key.cmn_md5, input_ctrl.text.v_code)
          bo2.send_variant(packet.eCTS_Safe_SetItemCode, v)
        end
      else
        notify(1380)
      end
    end
  end
  local msg = {
    detail = "passwd_chg_input",
    style_name = "passwd_chg_input",
    style_uri = "$frame/safe/safe.xml",
    callback = on_msg_callback
  }
  ui_widget.ui_msg_box.show(msg)
end
function on_setmintues()
  local on_msg_callback = function(ret)
    if ret.result == 1 then
      local ctrl = ret.window
      local input_ctrl = ctrl:search("minutes")
      local v = sys.variant()
      v:set(packet.key.cooldown_keepSec, input_ctrl.text.v_int)
      bo2.send_variant(packet.eCTS_Safe_SetMintues, v)
    end
  end
  local msg = {
    detail = L("mintues_enter_input"),
    style_uri = "$frame/safe/safe.xml",
    style_name = "mintues_enter_input",
    callback = on_msg_callback
  }
  ui_widget.ui_msg_box.show(msg)
end
function on_lockitemcode()
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_Safe_LockItemCode, v)
end
function on_unlockitemcode()
  local on_msg_callback = function(ret)
    if ret.result == 1 then
      local ctrl = ret.window
      local input_ctrl = ctrl:search("input")
      if check_len(input_ctrl.text) then
        local v = sys.variant()
        v:set(packet.key.cmn_name, input_ctrl.text.v_code)
        bo2.send_variant(packet.eCTS_Safe_UnlockItemCode, v)
      end
    end
  end
  local msg = {
    detail = "passwd_enter_input",
    style_name = "passwd_enter_input",
    style_uri = "$frame/safe/safe.xml",
    callback = on_msg_callback
  }
  ui_widget.ui_msg_box.show(msg)
end
function req_freezeitem(info)
  if info == nil then
    return
  end
  local item_name = sys.format("<fi:%s>", info.code)
  local arg = sys.variant()
  arg:set("item_name", item_name)
  ui_tool.show_msg({
    text = sys.mtf_merge(arg, ui.get_text("safe|freezeitem_confirm")),
    callback = function(ret)
      if ret.result == 1 then
        local v = sys.variant()
        v:set(packet.key.cmn_type, 1)
        v:set64(packet.key.item_key, info.only_id)
        bo2.send_variant(packet.eCTS_Safe_FreezeItem, v)
      end
    end
  })
end
function req_unfreezeitem(info)
  if info == nil then
    return
  end
  local item_name = sys.format("<fi:%s>", info.code)
  local arg = sys.variant()
  arg:set("item_name", item_name)
  ui_tool.show_msg({
    text = sys.mtf_merge(arg, ui.get_text("safe|unfreezeitem_confirm")),
    callback = function(ret)
      if ret.result == 1 then
        local v = sys.variant()
        v:set(packet.key.cmn_type, 0)
        v:set64(packet.key.item_key, info.only_id)
        bo2.send_variant(packet.eCTS_Safe_FreezeItem, v)
      end
    end
  })
end
function req_freezeridepet(info)
  if info == nil then
    return
  end
  local ridepet_name = sys.format("<ridepet:%s>", ui.ride_encode(info))
  local arg = sys.variant()
  arg:set("ridepet_name", ridepet_name)
  ui_tool.show_msg({
    text = sys.mtf_merge(arg, ui.get_text("safe|freezeridepet_confirm")),
    callback = function(ret)
      if ret.result == 1 then
        local v = sys.variant()
        v:set(packet.key.cmn_type, 1)
        v:set64(packet.key.item_key, info.onlyid)
        bo2.send_variant(packet.eCTS_Safe_FreezeRidePet, v)
      end
    end
  })
end
function req_unfreezeridepet(info)
  if info == nil then
    return
  end
  local ridepet_name = sys.format("<ridepet:%s>", ui.ride_encode(info))
  local arg = sys.variant()
  arg:set("ridepet_name", ridepet_name)
  ui_tool.show_msg({
    text = sys.mtf_merge(arg, ui.get_text("safe|unfreezeridepet_confirm")),
    callback = function(ret)
      if ret.result == 1 then
        local v = sys.variant()
        v:set(packet.key.cmn_type, 0)
        v:set64(packet.key.item_key, info.onlyid)
        bo2.send_variant(packet.eCTS_Safe_FreezeRidePet, v)
      end
    end
  })
end
function req_freezepet(only_id)
  local pet = ui.pet_find(only_id)
  local arg = sys.variant()
  arg:set("pet_name", pet.name)
  ui_tool.show_msg({
    text = sys.mtf_merge(arg, ui.get_text("safe|freezepet_confirm")),
    callback = function(ret)
      if ret.result == 1 then
        local v = sys.variant()
        v:set(packet.key.cmn_type, 1)
        v:set64(packet.key.pet_only_id, only_id)
        bo2.send_variant(packet.eCTS_Safe_FreezePet, v)
      end
    end
  })
end
function req_unfreezepet(only_id)
  local pet = ui.pet_find(only_id)
  local arg = sys.variant()
  arg:set("pet_name", pet.name)
  ui_tool.show_msg({
    text = sys.mtf_merge(arg, ui.get_text("safe|unfreezepet_confirm")),
    callback = function(ret)
      if ret.result == 1 then
        local v = sys.variant()
        v:set(packet.key.cmn_type, 0)
        v:set64(packet.key.pet_only_id, only_id)
        bo2.send_variant(packet.eCTS_Safe_FreezePet, v)
      end
    end
  })
end
function on_freezeitem()
  local w = ui.find_control("$frame:item")
  if w == nil then
    return
  end
  w.visible = true
  ui.clean_drop()
  local data = sys.variant()
  data:set("drop_type", ui_widget.c_drop_type_freezeitem)
  ui.setup_drop(ui_tool.w_open_floater, data)
end
function on_unfreezeitem()
  local w = ui.find_control("$frame:item")
  if w == nil then
    return
  end
  w.visible = true
  ui.clean_drop()
  local data = sys.variant()
  data:set("drop_type", ui_widget.c_drop_type_unfreezeitem)
  ui.setup_drop(ui_tool.w_open_floater, data)
end
function on_freezeridepet()
  local w = ui.find_control("$frame:ridepet")
  if w == nil then
    return
  end
  w.visible = true
  ui.clean_drop()
  local data = sys.variant()
  data:set("drop_type", ui_widget.c_drop_type_freezeridepet)
  ui.setup_drop(ui_tool.w_open_floater, data)
end
function on_unfreezeridepet()
  local w = ui.find_control("$frame:ridepet")
  if w == nil then
    return
  end
  w.visible = true
  ui.clean_drop()
  local data = sys.variant()
  data:set("drop_type", ui_widget.c_drop_type_unfreezeridepet)
  ui.setup_drop(ui_tool.w_open_floater, data)
end
function on_freezepet()
  local w = ui.find_control("$frame:pet_list")
  if w == nil then
    return
  end
  w.visible = false
  local data = sys.variant()
  data:set("ok_text", ui.get_text("safe|btn_freeze"))
  ui_pet.ui_pet_list.show_pet_list(req_freezepet, data)
end
function on_unfreezepet()
  local w = ui.find_control("$frame:pet_list")
  if w == nil then
    return
  end
  w.visible = false
  local data = sys.variant()
  data:set("ok_text", ui.get_text("safe|btn_unfreeze"))
  ui_pet.ui_pet_list.show_pet_list(req_unfreezepet, data)
end
function on_help()
end
function on_menu_event(item)
  if item.callback then
    item:callback()
  end
end
function haveitemcode()
  if bo2.player ~= nil and bo2.player:get_flag_bit(bo2.ePlayerFlagBit_SafeHaveItemCode) == 1 then
    return true
  end
  return false
end
function iscodeexd()
  if bo2.player ~= nil and bo2.player:get_flag_bit(bo2.ePlayerFlagBit_SafeCodeExd) == 1 then
    return true
  end
  return false
end
function on_click_show_menu(btn)
  if haveitemcode() then
    local data = {
      items = {
        {
          text = ui.get_text("menu|safe_chgitemcode"),
          callback = on_chgitemcode,
          id = 0
        },
        {
          text = ui.get_text("menu|safe_setmintues"),
          callback = on_setmintues,
          id = 1
        },
        {
          text = ui.get_text("menu|safe_unlockitemcode"),
          callback = on_unlockitemcode,
          id = 2
        },
        {
          text = ui.get_text("menu|safe_freezeitem"),
          callback = on_freezeitem,
          id = 3
        },
        {
          text = ui.get_text("menu|safe_unfreezeitem"),
          callback = on_unfreezeitem,
          id = 4
        },
        {
          text = ui.get_text("menu|safe_freezeridepet"),
          callback = on_freezeridepet,
          id = 5
        },
        {
          text = ui.get_text("menu|safe_unfreezeridepet"),
          callback = on_unfreezeridepet,
          id = 6
        }
      },
      event = on_menu_event,
      source = btn,
      dx = 140
    }
    if iscodeexd() then
      data.items[3].text = ui.get_text("menu|safe_lockitemcode")
      data.items[3].callback = on_lockitemcode
    end
    ui_tool.show_menu(data)
  else
    local data = {
      items = {
        {
          text = ui.get_text("menu|safe_newitemcode"),
          callback = on_newitemcode,
          id = 0
        },
        {
          text = ui.get_text("menu|safe_setmintues"),
          callback = on_setmintues,
          id = 1
        },
        {
          text = ui.get_text("menu|safe_freezeitem"),
          callback = on_freezeitem,
          id = 2
        },
        {
          text = ui.get_text("menu|safe_unfreezeitem"),
          callback = on_unfreezeitem,
          id = 3
        },
        {
          text = ui.get_text("menu|safe_freezeridepet"),
          callback = on_freezeridepet,
          id = 4
        },
        {
          text = ui.get_text("menu|safe_unfreezeridepet"),
          callback = on_unfreezeridepet,
          id = 5
        }
      },
      event = on_menu_event,
      source = btn,
      dx = 140
    }
    ui_tool.show_menu(data)
  end
end
function on_keyboard_click(btn)
  local focus = ui.get_focus()
  local data = {input_ctrl = btn, popup = "y2"}
  ui_tool.ui_keyboard.show_keyboard(data)
end
function on_keyboard_click_new_input(btn)
  local parent = btn.parent.parent.parent
  local input = parent:search("input")
  local rep = parent:search("repeat")
  local in_ctrl
  if input.focus then
    in_ctrl = input
  elseif rep.focus then
    in_ctrl = rep
  end
  local data = {
    input_ctrl = in_ctrl,
    btn = btn,
    popup = "y2"
  }
  ui_tool.ui_keyboard.show_keyboard(data)
end
function on_keyboard_click_chg_input(btn)
  local parent = btn.parent.parent.parent
  local old = parent:search("old")
  local input = parent:search("input")
  local rep = parent:search("repeat")
  local in_ctrl
  if old.focus then
    in_ctrl = old
  elseif input.focus then
    in_ctrl = input
  elseif rep.focus then
    in_ctrl = rep
  end
  local data = {
    input_ctrl = in_ctrl,
    btn = btn,
    popup = "y2"
  }
  ui_tool.ui_keyboard.show_keyboard(data)
end
function on_keyboard_click_enter_input(btn)
  local parent = btn.parent.parent
  local input = parent:search("input")
  local in_ctrl
  if input.focus then
    in_ctrl = input
  end
  local data = {
    input_ctrl = in_ctrl,
    btn = btn,
    popup = "y2"
  }
  ui_tool.ui_keyboard.show_keyboard(data)
end
function on_init()
end
function on_focus(ctrl, vis)
  if not vis then
    return
  end
  local old = ctrl:search("old")
  local input = ctrl:search("input")
  local rep = ctrl:search("repeat")
  local minutes = ctrl:search("minutes")
  if old then
    old.focus = true
  elseif input then
    input.focus = true
  elseif minutes then
    minutes.focus = true
  end
end
function on_ok(old, input, rep)
  if old then
    if not check_len(old.text) then
      old.focus = true
      return false
    end
    if input.text ~= rep.text then
      input.focus = true
      notify(1380)
      return false
    end
    if not check_len(input.text) then
      input.focus = true
      return false
    end
  elseif input and rep then
    if input.text ~= rep.text then
      input.focus = true
      notify(1380)
      return false
    end
    if not check_len(input.text) then
      input.focus = true
      return false
    end
  elseif input and not check_len(input.text) then
    input.focus = true
    return false
  end
  return true
end
function on_confirm_click(btn)
  local parent = btn.parent.parent.parent
  local minutes = parent:search("minutes")
  if minutes then
    ui_widget.ui_msg_box.on_confirm_click(btn)
  else
    local old = parent:search("old")
    local input = parent:search("input")
    local rep = parent:search("repeat")
    if on_ok(old, input, rep) then
      ui_widget.ui_msg_box.on_confirm_click(btn)
    end
  end
end
function on_input_enter(w)
  local parent = w.parent.parent.parent.parent
  local old = parent:search("old")
  local input = parent:search("input")
  local rep = parent:search("repeat")
  if on_ok(old, input, rep) then
    ui_widget.ui_msg_box.on_input_enter(w)
  end
end
function on_input_key(w, key, flag)
  if key == ui.VK_TAB and not flag.down and not flag.alt then
    local parent = w.parent.parent.parent.parent
    local old = parent:search("old")
    local input = parent:search("input")
    local rep = parent:search("repeat")
    if old and old.focus then
      old.focus = false
      input.focus = true
    elseif input and rep and input.focus then
      input.focus = false
      rep.focus = true
    elseif rep and rep.focus and input then
      if old then
        old.focus = true
      else
        input.focus = true
      end
    end
  else
    ui_widget.ui_msg_box.on_input_key(w, key, flag)
  end
end
function on_display_mouse(panel, msg)
  if msg == ui.mouse_enter then
    if w_flicker_safe_display.visible == true then
      w_flicker_safe_display.visible = false
      w_flicker_safe_display.suspended = true
      w_flicker_timer.suspended = true
    end
    w_safe_display_bg.visible = true
  elseif msg == ui.mouse_leave then
    w_safe_display_bg.visible = false
  end
end
function on_display_time_mouse(panel, msg)
  w_safe_display_bg.visible = true
end
function on_display_config_load(cfg, root)
  if root == nil then
    w_safe_display.dock = "ext_x2y1"
    w_safe_display.margin = ui.rect(0, 48, 10, 0)
    return
  end
  local display_data = root:find("safe_display")
  if display_data == nil then
    w_safe_display.dock = "ext_x2y1"
    w_safe_display.margin = ui.rect(0, 48, 10, 0)
    return
  end
  local position = display_data:get("position")
  local x = position:get_attribute("x")
  local y = position:get_attribute("y")
  if not x.empty and not y.empty and x.v_int ~= 0 and y.v_int ~= 0 then
    w_safe_display.dock = "none"
    w_safe_display.offset = ui.point(x.v_int, y.v_int)
  else
    w_safe_display.dock = "ext_x2y1"
    w_safe_display.margin = ui.rect(0, 48, 10, 0)
  end
end
function on_display_config_save(cfg, root)
  if root == nil then
    return
  end
  local display_data = root:find("safe_display")
  if display_data == nil then
    root:add("safe_display")
    display_data = root:find("safe_display")
  end
  local position = display_data:get("position")
  if position == nil then
    display_data:add("position")
    position = display_data:get("position")
  end
  position:set_attribute("x", w_safe_display.x)
  position:set_attribute("y", w_safe_display.y)
end
function on_flicker_timer()
  w_flicker_safe_display.visible = false
  w_flicker_safe_display.suspended = true
  w_flicker_timer.suspended = true
end
function on_safe(cmd, data)
  local safe = data:get(packet.key.total_time).v_int
  if safe > 0 then
    ui_reciprocal.del_reciproca("safetime")
    local insert_sub = {}
    insert_sub.time = safe
    insert_sub.name = ui.get_text("safe|leftsafe_time")
    insert_sub.close = true
    insert_sub.callback = nil
    insert_sub.icon = L("$image/qbar/pic_safe.png|0,0,20,20")
    ui_reciprocal.add_reciproca("safetime", insert_sub)
  elseif safe == 0 then
    ui_reciprocal.del_reciproca("safetime")
  end
end
function on_qqsafe(cmd, data)
  local msg_data = {
    text = ui.get_text("safe|qqsafe"),
    callback = function(ret)
      if ret.result == 1 then
        ui.shell_execute("open", "http://gamesafe.qq.com/safe_mode_remove.shtml?gameid=32")
      end
    end
  }
  ui_widget.ui_msg_box.show_common(msg_data)
end
local sig = "ui_safe.packet_handle"
ui_packet.game_recv_signal_insert(packet.eSTC_SafeTime_Show, on_safe, sig)
ui_packet.game_recv_signal_insert(packet.eSTC_UI_SafeNotice, on_qqsafe, sig)
