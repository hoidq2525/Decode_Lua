local config_file = SHARED("setting_input.xml")
local c_enable_local_config = false
function init_once()
  if rawget(_M, "g_already_init") ~= nil then
    return
  end
  g_already_init = true
  g_hotkey_notify_table = {}
  sys.load_xcode("ui_setting.ui_input", "$script/client/xcode/op_id.h")
  op_def = {
    move_front = {
      id = op_id_move_front,
      key0 = "UP",
      key1 = "W",
      dup_down = true,
      db_index = 0,
      viedo_enable = 1
    },
    move_back = {
      id = op_id_move_back,
      key0 = "DOWN",
      key1 = "S",
      dup_down = true,
      db_index = 1,
      viedo_enable = 1
    },
    move_left = {
      id = op_id_move_left,
      key0 = "LEFT",
      key1 = "A",
      dup_down = true,
      db_index = 2,
      viedo_enable = 1
    },
    move_right = {
      id = op_id_move_right,
      key0 = "RIGHT",
      key1 = "D",
      dup_down = true,
      db_index = 3,
      viedo_enable = 1
    },
    jink = {
      id = op_id_jink,
      key0 = "SHIFT",
      db_index = 4
    },
    run = {id = op_id_run, db_index = 5},
    follow = {
      id = op_id_follow,
      event = event_follow_target,
      db_index = 6
    },
    fast_move = {
      id = op_id_fast_move,
      key0 = "CONTROL",
      event = event_teach_fast_move,
      db_index = 7
    },
    defend = {
      id = op_id_defend,
      key0 = "SPACE",
      dup_down = true,
      db_index = 8
    },
    jump = {
      id = op_id_jump,
      key0 = "Q",
      dup_down = true,
      db_index = 9
    },
    printscreen = {
      id = op_id_sys_screen,
      key0 = "SNAPSHOT",
      scope = "tool",
      db_index = 10
    },
    lock_enemy = {
      id = op_id_lock_enemy,
      key0 = "TAB",
      db_index = 11
    },
    ridefight = {
      id = op_id_ridefight_tab,
      key0 = "T",
      db_index = 19
    },
    run_x = {id = op_id_run_x, key0 = "F9"},
    camera_home = {
      id = op_id_camera_home,
      key0 = "NUMPAD5",
      key1 = "HOME",
      db_index = 12,
      viedo_enable = 1
    },
    camera_in = {
      id = op_id_camera_in,
      key0 = "NUMPAD9",
      key1 = "PRIOR",
      db_index = 13,
      viedo_enable = 1
    },
    camera_out = {
      id = op_id_camera_out,
      key0 = "NUMPAD7",
      key1 = "NEXT",
      db_index = 14,
      viedo_enable = 1
    },
    camera_left = {
      id = op_id_camera_right,
      key0 = "NUMPAD4",
      key1 = "INSERT",
      db_index = 15,
      viedo_enable = 1
    },
    camera_right = {
      id = op_id_camera_left,
      key0 = "NUMPAD6",
      key1 = "DELETE",
      db_index = 16,
      viedo_enable = 1
    },
    camera_up = {
      id = op_id_camera_down,
      key0 = "NUMPAD8",
      db_index = 17,
      viedo_enable = 1
    },
    camera_down = {
      id = op_id_camera_up,
      key0 = "NUMPAD2",
      db_index = 18,
      viedo_enable = 1
    },
    camera_lock = {
      id = op_id_camera_lock,
      key0 = "F",
      key1 = "J",
      db_index = 39,
      viedo_enable = 1
    },
    hold_move_front = {
      id = op_id_hold_move_front,
      key0 = "MENU+UP",
      dup_down = true,
      gray = true
    },
    hold_move_back = {
      id = op_id_hold_move_back,
      key0 = "MENU+DOWN",
      dup_down = true,
      gray = true
    },
    hold_move_left = {
      id = op_id_hold_move_left,
      key0 = "MENU+LEFT",
      dup_down = true,
      gray = true
    },
    hold_move_right = {
      id = op_id_hold_move_right,
      key0 = "MENU+RIGHT",
      dup_down = true,
      gray = true
    },
    window_equip = {
      id = 2000,
      key0 = "C",
      event = event_window_toggle,
      window_name = "$frame:personal",
      db_index = 20
    },
    window_item = {
      id = 2001,
      key0 = "B",
      event = event_window_toggle,
      window_name = "$frame:item",
      db_index = 21
    },
    window_quest = {
      id = 2003,
      key0 = "L",
      event = event_window_toggle,
      window_name = "$frame:received_quest",
      db_index = 22
    },
    window_map = {
      id = 2004,
      key0 = "M",
      event = event_window_toggle,
      window_name = "$frame:map",
      db_index = 23
    },
    window_ridepet = {
      id = 2005,
      key0 = "P",
      event = event_window_toggle,
      window_name = "$frame:ridepet",
      db_index = 24
    },
    window_skill = {
      id = 2006,
      key0 = "K",
      event = event_window_toggle,
      window_name = "$frame:skill",
      db_index = 25
    },
    window_org = {
      id = 2007,
      key0 = "G",
      event = event_guild_window_toggle,
      window_name = "$frame:ui_guild",
      db_index = 26
    },
    window_md = {
      id = 2008,
      key0 = "O",
      event = event_window_toggle,
      window_name = "$frame:md",
      db_index = 27
    },
    window_market = {
      id = 2009,
      key0 = "F11",
      event = event_supermarket_window_toggle,
      window_name = "$frame:supermarket2",
      db_index = 28
    },
    window_im = {
      id = 2010,
      key0 = "I",
      event = event_im_visible,
      window_name = "$frame:im_main",
      db_index = 29
    },
    window_alpha = {
      id = 2100,
      key0 = "CONTROL+P",
      event = event_window_alpha,
      db_index = 30
    },
    chat_input = {
      id = 2051,
      key0 = "RETURN",
      event = event_chat_input,
      db_index = 31
    },
    chest_all = {
      id = 2052,
      key0 = "Z",
      event = event_chest_all,
      db_index = 32
    },
    chg_target = {
      id = 2053,
      event = event_chg_target,
      db_index = 33
    },
    fullscreen = {
      id = 2101,
      event = event_fullscreen,
      scope = "tool",
      db_index = 34
    },
    hide_player = {
      id = 2102,
      key0 = "F12",
      event = event_hide_player,
      db_index = 35
    },
    window_video = {
      id = 2054,
      key0 = "F5",
      event = event_window_toggle,
      window_name = "$frame:video",
      db_index = 36
    },
    window_battle = {
      id = 2056,
      key0 = "N",
      event = event_battle_window_toggle,
      db_index = 37
    },
    quick_personal_chat = {
      id = 2057,
      key0 = "CONTROL+R",
      event = event_open_personal_chat,
      db_index = 38
    },
    display_still_name = {
      id = 2058,
      key0 = "F6",
      event = event_display_still_name
    },
    show_cursor = {
      id = op_id_show_cursor,
      key0 = "MENU",
      db_index = 40
    },
    boss_key = {
      id = 2059,
      key0 = "CONTROL+MENU+H",
      db_index = 41,
      scope = "global",
      event = event_boss_key
    },
    shortcut0 = {
      id = 3000,
      event = event_shortcut,
      key0 = "1",
      db_index = 44
    },
    shortcut1 = {
      id = 3001,
      event = event_shortcut,
      key0 = "2",
      db_index = 45
    },
    shortcut2 = {
      id = 3002,
      event = event_shortcut,
      key0 = "3",
      db_index = 46
    },
    shortcut3 = {
      id = 3003,
      event = event_shortcut,
      key0 = "4",
      db_index = 47
    },
    shortcut4 = {
      id = 3004,
      event = event_shortcut,
      key0 = "5",
      db_index = 48
    },
    shortcut5 = {
      id = 3005,
      event = event_shortcut,
      key0 = "6",
      db_index = 49
    },
    shortcut6 = {
      id = 3006,
      event = event_shortcut,
      key0 = "7",
      db_index = 50
    },
    shortcut7 = {
      id = 3007,
      event = event_shortcut,
      key0 = "8",
      db_index = 51
    },
    shortcut8 = {
      id = 3008,
      event = event_shortcut,
      key0 = "9",
      db_index = 52
    },
    shortcut9 = {
      id = 3009,
      event = event_shortcut,
      key0 = "0",
      db_index = 53
    },
    shortcut10 = {
      id = 3010,
      event = event_shortcut,
      key0 = "OEM_MINUS",
      db_index = 54
    },
    shortcut11 = {
      id = 3011,
      event = event_shortcut,
      key0 = "OEM_PLUS",
      db_index = 55
    },
    xshortcut0 = {
      id = 3100,
      event = event_shortcut,
      key0 = "MENU+1",
      db_index = 56
    },
    xshortcut1 = {
      id = 3101,
      event = event_shortcut,
      key0 = "MENU+2",
      db_index = 57
    },
    xshortcut2 = {
      id = 3102,
      event = event_shortcut,
      key0 = "MENU+3",
      db_index = 58
    },
    xshortcut3 = {
      id = 3103,
      event = event_shortcut,
      key0 = "MENU+4",
      db_index = 59
    },
    xshortcut4 = {
      id = 3104,
      event = event_shortcut,
      key0 = "MENU+5",
      db_index = 60
    },
    xshortcut5 = {
      id = 3105,
      event = event_shortcut,
      key0 = "MENU+6",
      db_index = 61
    },
    xshortcut6 = {
      id = 3106,
      event = event_shortcut,
      key0 = "MENU+Q",
      db_index = 62
    },
    xshortcut7 = {
      id = 3107,
      event = event_shortcut,
      key0 = "OEM_3",
      db_index = 63
    },
    xshortcut8 = {
      id = 3108,
      event = event_shortcut,
      key0 = "E",
      db_index = 64
    },
    xshortcut9 = {
      id = 3109,
      event = event_shortcut,
      key0 = "R",
      db_index = 65
    },
    xshortcut10 = {
      id = 3110,
      event = event_shortcut,
      key0 = "V",
      db_index = 66
    },
    xshortcut11 = {
      id = 3111,
      event = event_shortcut,
      key0 = "X",
      db_index = 67
    },
    fshortcut0 = {
      id = 3200,
      event = event_shortcut,
      db_index = 68
    },
    fshortcut1 = {
      id = 3201,
      event = event_shortcut,
      db_index = 69
    },
    fshortcut2 = {
      id = 3202,
      event = event_shortcut,
      db_index = 70
    },
    fshortcut3 = {
      id = 3203,
      event = event_shortcut,
      db_index = 71
    },
    fshortcut4 = {
      id = 3204,
      event = event_shortcut,
      db_index = 72
    },
    fshortcut5 = {
      id = 3205,
      event = event_shortcut,
      db_index = 73
    },
    fshortcut6 = {
      id = 3206,
      event = event_shortcut,
      db_index = 74
    },
    fshortcut7 = {
      id = 3207,
      event = event_shortcut,
      db_index = 75
    },
    fshortcut8 = {
      id = 3208,
      event = event_shortcut,
      db_index = 76
    },
    fshortcut9 = {
      id = 3209,
      event = event_shortcut,
      db_index = 77
    },
    fshortcut10 = {
      id = 3210,
      event = event_shortcut,
      db_index = 78
    },
    fshortcut11 = {
      id = 3211,
      event = event_shortcut,
      db_index = 79
    },
    fshortcut12 = {
      id = 3212,
      event = event_shortcut,
      db_index = 80
    },
    fshortcut13 = {
      id = 3213,
      event = event_shortcut,
      db_index = 81
    },
    fshortcut14 = {
      id = 3214,
      event = event_shortcut,
      db_index = 82
    },
    fshortcut15 = {
      id = 3215,
      event = event_shortcut,
      db_index = 83
    },
    fshortcut16 = {
      id = 3216,
      event = event_shortcut,
      db_index = 84
    },
    fshortcut17 = {
      id = 3217,
      event = event_shortcut,
      db_index = 85
    },
    fshortcut18 = {
      id = 3218,
      event = event_shortcut,
      db_index = 86
    },
    fshortcut19 = {
      id = 3219,
      event = event_shortcut,
      db_index = 87
    },
    fshortcut20 = {
      id = 3220,
      event = event_shortcut,
      db_index = 88
    },
    fshortcut21 = {
      id = 3221,
      event = event_shortcut,
      db_index = 89
    },
    fshortcut22 = {
      id = 3222,
      event = event_shortcut,
      db_index = 90
    },
    fshortcut23 = {
      id = 3223,
      event = event_shortcut,
      db_index = 91
    },
    fshortcut24 = {
      id = 3224,
      event = event_shortcut,
      db_index = 92
    },
    fshortcut25 = {
      id = 3225,
      event = event_shortcut,
      db_index = 93
    },
    fshortcut26 = {
      id = 3226,
      event = event_shortcut,
      db_index = 94
    },
    fshortcut27 = {
      id = 3227,
      event = event_shortcut,
      db_index = 95
    },
    fshortcut28 = {
      id = 3228,
      event = event_shortcut,
      db_index = 96
    },
    fshortcut29 = {
      id = 3229,
      event = event_shortcut,
      db_index = 97
    },
    fshortcut30 = {
      id = 3230,
      event = event_shortcut,
      db_index = 98
    },
    fshortcut31 = {
      id = 3231,
      event = event_shortcut,
      db_index = 99
    },
    fshortcut32 = {
      id = 3232,
      event = event_shortcut,
      db_index = 100
    },
    fshortcut33 = {
      id = 3233,
      event = event_shortcut,
      db_index = 101
    },
    fshortcut34 = {
      id = 3234,
      event = event_shortcut,
      db_index = 102
    },
    fshortcut35 = {
      id = 3235,
      event = event_shortcut,
      db_index = 103
    }
  }
  op_group = {
    {
      name = "move",
      data = {
        "move_front",
        "move_back",
        "move_left",
        "move_right",
        "hold_move_front",
        "hold_move_back",
        "hold_move_left",
        "hold_move_right"
      }
    },
    {
      name = "func",
      data = {
        "jump",
        "jink",
        "defend",
        "run",
        "fast_move",
        "follow",
        "lock_enemy",
        "chest_all",
        "chg_target",
        "show_cursor",
        "ridefight"
      }
    },
    {
      name = "ui",
      data = {
        "window_equip",
        "window_item",
        "window_quest",
        "window_map",
        "window_ridepet",
        "window_skill",
        "window_org",
        "window_md",
        "window_market",
        "hide_player",
        "window_im",
        "window_alpha",
        "fullscreen",
        "chat_input",
        "printscreen",
        "boss_key",
        "fps_ping",
        "window_video",
        "window_battle",
        "quick_personal_chat",
        "display_still_name"
      }
    },
    {
      name = "view",
      data = {
        "camera_home",
        "camera_in",
        "camera_out",
        "camera_left",
        "camera_right",
        "camera_up",
        "camera_down",
        "camera_lock"
      }
    },
    {
      name = "shortcut",
      data = {
        "shortcut0",
        "shortcut1",
        "shortcut2",
        "shortcut3",
        "shortcut4",
        "shortcut5",
        "shortcut6",
        "shortcut7",
        "shortcut8",
        "shortcut9",
        "shortcut10",
        "shortcut11"
      }
    },
    {
      name = "xshortcut",
      data = {
        "xshortcut0",
        "xshortcut1",
        "xshortcut2",
        "xshortcut3",
        "xshortcut4",
        "xshortcut5",
        "xshortcut6",
        "xshortcut7",
        "xshortcut8",
        "xshortcut9",
        "xshortcut10",
        "xshortcut11",
        "xshortcut12",
        "xshortcut13",
        "xshortcut14",
        "xshortcut15"
      }
    },
    {
      name = "fshortcut0",
      data = {
        "fshortcut0",
        "fshortcut1",
        "fshortcut2",
        "fshortcut3",
        "fshortcut4",
        "fshortcut5",
        "fshortcut6",
        "fshortcut7"
      }
    },
    {
      name = "fshortcut1",
      data = {
        "fshortcut8",
        "fshortcut9",
        "fshortcut10",
        "fshortcut11",
        "fshortcut12",
        "fshortcut13",
        "fshortcut14",
        "fshortcut15"
      }
    },
    {
      name = "fshortcut2",
      data = {
        "fshortcut16",
        "fshortcut17",
        "fshortcut18",
        "fshortcut19",
        "fshortcut20",
        "fshortcut21",
        "fshortcut22",
        "fshortcut23"
      }
    },
    {
      name = "fshortcut3",
      data = {
        "fshortcut24",
        "fshortcut25",
        "fshortcut26",
        "fshortcut27",
        "fshortcut28",
        "fshortcut29",
        "fshortcut30",
        "fshortcut31"
      }
    },
    {
      name = "fshortcut4",
      data = {
        "fshortcut32",
        "fshortcut33",
        "fshortcut34",
        "fshortcut35"
      }
    }
  }
  if free_cam_ctr_open ~= nil then
    op_def.move_up = {id = op_id_move_up, key0 = "MENU+U"}
    op_def.move_down = {id = op_id_move_down, key0 = "MENU+E"}
    table.insert(op_group[1].data, "move_up")
    table.insert(op_group[1].data, "move_down")
  end
  op_ids = {}
  for n, v in pairs(op_def) do
    op_ids[v.id] = v
  end
  op_tmp = {}
  ui.key_load_text("setting|op_key_", "setting|op_key_simple_")
  hotkey_reload()
end
function hotkey_reload()
  local db_index_check = {}
  local key = ui.hotkey_unit()
  for n, v in pairs(op_def) do
    if v.info == nil then
      if 3000 <= v.id and v.id <= 3999 then
        local base_idx = 0
        local base_txt
        if 3000 <= v.id and v.id <= 3011 then
          base_idx = v.id - 3000
          base_txt = "shortcut"
        elseif v.id >= 3100 and v.id <= 3115 then
          base_idx = v.id - 3100
          base_txt = "xshortcut"
        elseif v.id >= 3200 and v.id <= 3207 then
          base_idx = v.id - 3200
          base_txt = "fshortcut0"
        elseif v.id >= 3208 and v.id <= 3215 then
          base_idx = v.id - 3208
          base_txt = "fshortcut1"
        elseif v.id >= 3216 and v.id <= 3223 then
          base_idx = v.id - 3216
          base_txt = "fshortcut2"
        elseif v.id >= 3224 and v.id <= 3231 then
          base_idx = v.id - 3224
          base_txt = "fshortcut3"
        elseif v.id >= 3232 and v.id <= 3235 then
          base_idx = v.id - 3232
          base_txt = "fshortcut4"
        end
        v.info = sys.format("%s[%d]", ui.get_text("setting|op_group_" .. base_txt), base_idx + 1)
      else
        v.info = ui.get_text("setting|op_def_" .. n)
        if v.info == nil then
          ui.log("failed load op_def:info of '%s'.", n)
        end
      end
    end
    local p = ui.hotkey_create(n)
    key.name = v.key0
    p:set_unit(0, key)
    key.name = v.key1
    p:set_unit(1, key)
    p.id = v.id
    if v.scope == "global" then
      p.global = true
    end
    if v.dup_down ~= nil and v.dup_down then
      p.dup_down = true
    end
    local db_index = v.db_index
    if db_index ~= nil then
      p.db_index = db_index
      if db_index_check[db_index] == nil then
        db_index_check[db_index] = 1
      else
        ui.log("[ERROR] dup db_index %d.", db_index)
      end
    end
    p:insert_on_hotkey(event_common, "ui_setting.ui_input.event_common")
    v.hotkey = p
  end
  ui.hotkey_load()
  hotkey_notify_invoke()
end
function hotkey_notify_insert(fn, name)
  g_hotkey_notify_table[name] = fn
end
function hotkey_notify_invoke()
  for n, v in pairs(g_hotkey_notify_table) do
    v()
  end
end
function event_common(info)
  local d = op_def[tostring(info.name)]
  if d == nil then
    return
  end
  if ui_skill ~= nil and ui_skill.UseSkillhotkey() then
    return
  end
  if bo2.player ~= nil and bo2.player.bIshOpen and (d.id < 2000 or d.id > 2199) then
    return
  end
  if bo2.IsVideoPlaying() ~= false and (ui_phase == nil or ui_phase.w_outer_config == nil or d.viedo_enable == nil) then
    return
  end
  local s = d.scope
  if s == nil or s == "scene" then
    if not ui.in_game() then
      return
    end
    local mon = ui.hotkey_get_monitor()
    if mon == nil or not mon.focus then
      if ui_qchat.w_qchat.visible and info.id == 2057 then
        local e = d.event
        if e ~= nil then
          e(info)
          return
        end
        local var = sys.variant()
        var:set("id", info.id)
        if info.down then
          var:set("down", 1)
        else
          var:set("down", 0)
        end
        if info.double then
          var:set("dbl", 1)
        else
          var:set("dbl", 0)
        end
        bo2.notify_on_op(var)
      end
      return
    end
  end
  local e = d.event
  if e ~= nil then
    e(info)
    return
  end
  local var = sys.variant()
  var:set("id", info.id)
  if info.down then
    var:set("down", 1)
  else
    var:set("down", 0)
  end
  if info.double then
    var:set("dbl", 1)
  else
    var:set("dbl", 0)
  end
  bo2.notify_on_op(var)
end
function event_shortcut(info)
  ui_shortcut.shortcut_on_op(info.id - 3000, info.down)
end
function event_window_alpha(info)
  if info.down then
    return
  end
  ui_main.toggle_alpha()
end
function event_fullscreen(info)
  if info.down then
    return
  end
  local cfg = bo2.get_config()
  if cfg:get("fullscreen").v_string == L("0") then
    cfg:set("fullscreen", L("1"))
  else
    cfg:set("fullscreen", L("0"))
  end
  bo2.set_config(cfg)
end
function event_window_toggle(info)
  if info.down then
    return
  end
  local op = op_def[tostring(info.name)]
  local wn = op.window_name
  if wn == nil then
    return
  end
  local v = ui_tool.tool_disable_window[op.window_name]
  if v ~= nil then
    return
  end
  local w = ui.find_control(op.window_name)
  if w == nil then
    return
  end
  w.visible = not w.visible
end
function event_battle_window_toggle(info)
  ui_battle_common.open_info_win()
end
function event_supermarket_window_toggle(info)
  if info.down then
    return
  end
  if ui_supermarket2.CanOpen() then
    ui_supermarket2.w_main.visible = not ui_supermarket2.w_main.visible
  end
end
function event_guild_window_toggle(info)
  if info.down then
    return
  end
  local op = op_def[tostring(info.name)]
  local wn = op.window_name
  if wn == nil then
    return
  end
  local v = ui_tool.tool_disable_window[op.window_name]
  if v ~= nil then
    return
  end
  local w = ui.find_control(op.window_name)
  if w == nil then
    return
  end
  if bo2.is_in_guild() == sys.wstring(0) then
    local ui_search_visible = ui_guild_mod.ui_guild_search.w_guild_search.visible
    if bo2.player:get_atb(bo2.eAtb_Level) < 20 then
      return
    end
    if ui_search_visible == false then
      ui_chat.show_ui_text_id(70251)
      ui_guild_mod.ui_guild_search.set_win_open(0)
    else
      ui_guild_mod.ui_guild_search.w_guild_search.visible = false
    end
    return
  else
    ui_handson_teach.test_complate_guild(true)
    if ui.npc_guild_mb_id() ~= 0 then
      w = ui.find_control("$frame:ui_npc_guild")
    end
    for i = 0, bo2.gv_npc_guild.size - 1 do
      local line = bo2.gv_npc_guild:get(i)
      if line ~= nil and (ui.guild_name() == line.name or ui.guild_name() == line.show_name) then
        w = ui.find_control("$frame:ui_npc_guild")
        break
      end
    end
    if w == nil then
      return
    end
  end
  w.visible = not w.visible
end
function event_chat_input(info)
  if info.down then
    return
  end
  ui_qchat.w_qchat.visible = true
  ui_qchat.w_input.focus = true
  ui_qchat.w_qchat.top_level = true
end
function event_open_personal_chat(info)
  if info.down then
    return
  end
  ui_chat.set_channel(bo2.eChatChannel_PersonalChat)
end
function event_hide_player(info)
  if info.down then
    return
  end
  ui_net_delay.hide_player_toggle()
end
function event_boss_key(info)
  if not info.down then
    return
  end
  local vis = ui.main_window_is_visible()
  ui.main_window_show(not vis)
end
function do_auto_chest_all()
  if ui_npcfunc.ui_chest.get_visible() then
    ui_npcfunc.ui_chest.on_all()
    return
  end
  bo2.player:auto_chest_all()
end
function event_chest_all(info)
  if info.down then
    return
  end
  if bo2.player == nil then
    return
  end
  do_auto_chest_all()
end
function event_chg_target(info)
  if info.down then
    return
  end
  if bo2.player == nil then
    return
  end
  local target = bo2.scn:get_scn_obj(bo2.player.target_handle)
  if target == nil then
    return
  end
  if target.kind ~= bo2.eScnObjKind_Player then
    return
  end
  local tot = bo2.scn:get_scn_obj(target.target_handle)
  if tot == nil then
    return
  end
  if tot == bo2.player then
    return
  end
  bo2.send_target_packet(tot.sel_handle)
end
function event_display_still_name(info)
  if info.down ~= true then
    return
  end
  local v_data = bo2.get_single_config(L("display_still_name")).v_int
  if v_data == 0 then
    bo2.set_single_config(L("display_still_name"), 1)
  else
    bo2.set_single_config(L("display_still_name"), 0)
  end
end
function event_follow_target(info)
  if info.down then
    return
  end
  if bo2.player == nil then
    return
  end
  local target = bo2.scn:get_scn_obj(bo2.player.target_handle)
  if target == nil then
    return
  end
  bo2.send_follow(target.sel_handle)
end
function event_teach_fast_move(info)
  local var = sys.variant()
  var:set("id", info.id)
  if info.down then
    var:set("down", 1)
  else
    var:set("down", 0)
  end
  if info.double then
    var:set("dbl", 1)
  else
    var:set("dbl", 0)
  end
  bo2.notify_on_op(var)
  ui_handson_teach.test_complate_ctrl_teach(false)
end
function tree_update_item(tmp)
  local item = tmp.def.item
  if not sys.check(item) then
    return
  end
  local function update_button(idx)
    local btn = item:search("btn_key" .. idx)
    btn.text = tmp["cfg" .. idx].text
    btn.group = w_op_tree
    local d = {}
    d.data = tmp
    d.index = idx
    btn.svar = d
  end
  update_button(0)
  update_button(1)
end
function tree_load(cfg_name)
  op_tmp = {}
  local fn_name = "get_" .. cfg_name
  for n, v in pairs(op_def) do
    local t = {}
    op_tmp[n] = t
    t.def = v
    local hotkey = v.hotkey
    local fn = hotkey[fn_name]
    t.cfg0 = fn(hotkey, 0)
    t.cfg1 = fn(hotkey, 1)
    tree_update_item(t)
  end
end
function tree_save()
  local save = {}
  for n, t in pairs(op_tmp) do
    local hotkey = t.def.hotkey
    hotkey:set_cell(0, t.cfg0)
    hotkey:set_cell(1, t.cfg1)
  end
  if c_enable_local_config then
    local cfg_uri = ui_main.player_cfg_make_uri(config_file)
    ui.hotkey_save(cfg_uri)
  end
  local var_cfg = ui.hotkey_save_var()
  bo2.send_variant(packet.eCTS_UI_KeyboardConfig, var_cfg)
  hotkey_notify_invoke()
end
function on_init(ctrl)
  hotkey_reload()
  if c_enable_local_config then
    local cfg_uri = ui_main.player_cfg_make_uri(config_file)
    ui.hotkey_load(cfg_uri)
  end
end
function on_btn_defalt_click(btn)
  tree_load("unit")
end
function on_btn_confirm_click(btn)
  w_input.visible = false
  tree_save()
end
function on_btn_cancel_click(btn)
  w_input.visible = false
end
function on_input_visible(ctrl, vis)
  if not vis then
    return
  end
  if w_op_tree == nil then
    return
  end
  if w_op_tree.root.item_count == 0 then
    local root = w_op_tree.root
    local style_uri = L("$gui/frame/central/setting_input.xml")
    local style_name_g = L("input_node_group")
    local style_name_k = L("input_node_key")
    for ig, vg in ipairs(op_group) do
      local item_g = root:item_append()
      item_g:load_style(style_uri, style_name_g)
      item_g:search("lb_text").text = ui.get_text("setting|op_group_" .. vg.name)
      for ik, vk in ipairs(vg.data) do
        local op = op_def[vk]
        if op ~= nil and (op.window_name == nil or ui_tool.tool_disable_window[op.window_name] == nil) then
          local item_k = item_g:item_append()
          item_k:load_style(style_uri, style_name_k)
          item_k:search("lb_text").text = op.info
          if op.gray == true then
            item_k:search("btn_key0").enable = false
            item_k:search("btn_key1").enable = false
          end
          op.item = item_k
        end
      end
    end
  end
  tree_load("cell")
end
function on_btn_key_press(btn, press)
  if press then
    w_key_button = btn
    w_key_panel.focus = true
    w_btn_clear.enable = true
  elseif btn == w_key_button then
    w_key_button = nil
    w_btn_clear.enable = false
  end
end
function on_btn_clear_click(btn_clear)
  local btn = w_key_button
  local d = btn.svar
  local idx = d.index
  local tmp = d.data
  local cfg_idx = "cfg" .. idx
  tmp[cfg_idx] = ""
  btn.text = ""
  btn.press = false
end
function on_key_panel_hotkey(plugin)
  if rawget(_M, "w_key_button") == nil then
    w_key_panel.focus = false
    return
  end
  local cfg = plugin.hotkey
  if not plugin.done then
    w_key_button.text = cfg.text
    return
  end
  local btn = w_key_button
  local d = btn.svar
  local idx = d.index
  local tmp = d.data
  local cfg_idx = "cfg" .. idx
  if cfg.empty then
    btn.text = tmp[cfg_idx].text
    return
  end
  local function do_set_key()
    ui.log("do_set_key tmp.def.id %d.", tmp.def.id)
    tmp[cfg_idx] = cfg
    btn.text = cfg.text
    btn.press = false
  end
  local op_v = 0
  local cfg_name = cfg.name
  local function on_msg_box(data)
    if data.result ~= 1 then
      btn.text = tmp[cfg_idx].text
      return
    end
    do_set_key()
    if op_v.cfg0.name == cfg_name then
      op_v.cfg0 = ui.hotkey_unit()
    else
      op_v.cfg1 = ui.hotkey_unit()
    end
    tree_update_item(op_v)
  end
  for n, v in pairs(op_tmp) do
    if v.def.id ~= tmp.def.id and (v.cfg0.name == cfg_name or v.cfg1.name == cfg_name) then
      btn.press = false
      if v.def.gray then
        btn.text = tmp[cfg_idx].text
        local text = ui_widget.merge_mtf({
          op0 = tmp.def.info,
          op1 = v.def.info
        }, ui.get_text("setting|ui_input_msg_key_dup_gray"))
        ui_widget.ui_msg_box.show_common({text = text, btn_confirm = false})
        return
      end
      op_v = v
      local text = ui_widget.merge_mtf({
        op0 = v.def.info,
        op1 = tmp.def.info
      }, ui.get_text("setting|ui_input_msg_key_dup"))
      ui_widget.ui_msg_box.show_common({text = text, callback = on_msg_box})
      return
    end
  end
  do_set_key()
end
function on_stc_config(cmd, cfg)
  ui.hotkey_load_var(cfg)
  hotkey_notify_invoke()
end
function get_op_simple_text(id)
  local op = ui_setting.ui_input.op_ids[id]
  if op == nil then
    return nil
  end
  local hk = op.hotkey
  local txt = hk:get_cell(0).simple_text
  if txt.empty then
    txt = hk:get_cell(1).simple_text
  end
  return txt
end
function get_op_text(id)
  local op = ui_setting.ui_input.op_ids[id]
  if op == nil then
    return nil
  end
  local hk = op.hotkey
  local txt = hk:get_cell(0).text
  if txt.empty then
    txt = hk:get_cell(1).text
  end
  return txt
end
function event_im_visible(info)
  if info.down then
    return
  end
  ui_im.on_qlink_friend()
end
init_once()
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_KeyboardConfig, on_stc_config, "ui_setting.ui_setting_input")
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_AutoPick, do_auto_chest_all, "ui_setting.do_auto_chest_all")
