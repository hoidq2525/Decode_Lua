local ui_tab = ui_widget.ui_tab
local g_cfg_uri = L("$cfg/client/setting_game.xml")
local g_cfg_def_uri = L("$cfg/client/setting_game_default.xml")
function init_once()
  if rawget(_M, "g_already_init") ~= nil then
    return
  end
  g_already_init = true
  cfg_def = {
    fullscreen = {
      sys = true,
      def = L("2"),
      widget = L("cb_fullscreen"),
      event = event_combo_fullscreen
    },
    display_mode = {
      sys = true,
      def = L("1024x768"),
      widget = L("cb_display_mode"),
      event = event_combo_box
    },
    multisample = {
      sys = true,
      def = L("24x0"),
      widget = L("cb_multisample"),
      event = event_combo_box
    },
    adapter = {
      sys = true,
      def = L("0"),
      widget = L("cb_adapter"),
      event = event_combo_box_index,
      need_restart = true,
      title = ui.get_text("central|current_video_card")
    },
    fps_lock = {
      sys = true,
      def = L("1"),
      widget = L("btn_fps_lock"),
      event = event_check_box
    },
    back_draw = {
      sys = true,
      def = L("0"),
      widget = L("btn_back_draw"),
      event = event_check_box
    },
    hdr = {
      sys = true,
      def = L("0"),
      widget = L("btn_hdr"),
      event = event_check_box
    },
    low_cfg_note = {
      sys = true,
      def = L("1"),
      widget = L("btn_low_cfg_note"),
      event = event_check_box
    },
    hide_player_note = {
      sys = true,
      def = L("1"),
      widget = L("btn_hide_player_note"),
      event = event_check_box
    },
    net_ping_note = {
      sys = true,
      def = L("1"),
      widget = L("btn_net_ping_note"),
      event = event_check_box
    },
    draw_vsync = {
      sys = true,
      def = L("1"),
      widget = L("btn_draw_vsync"),
      event = event_check_box
    },
    bloom_factor = {
      sys = true,
      def = L("0"),
      widget = L("sld_bloom_factor"),
      event = event_slider
    },
    water_effect = {
      sys = true,
      base = 1,
      def = L("1"),
      widget = L("cb_water_effect"),
      text = ui.get_text("central|waterwave_effect"),
      event = event_combo_tri
    },
    tex_effect = {
      sys = true,
      def = L("1"),
      widget = L("cb_tex_effect"),
      text = ui.get_text("central|material_precision"),
      event = event_combo_tri
    },
    particle_effect = {
      sys = true,
      def = L("1"),
      widget = L("cb_particle_effect"),
      text = ui.get_text("central|particle_effect"),
      event = event_combo_tri
    },
    render_level = {
      sys = true,
      def = L("0"),
      widget = L("cb_render_level"),
      text = ui.get_text("central|rendering_grade"),
      event = event_combo_four_level
    },
    silhouette = {
      sys = true,
      def = L("1"),
      widget = L("btn_silhouette"),
      event = event_check_box
    },
    soft_particle = {
      sys = true,
      def = L("1"),
      widget = L("btn_soft_particle"),
      event = event_check_box
    },
    DistViewBlur = {
      sys = true,
      def = L("1"),
      widget = L("btn_DistViewBlur"),
      event = event_check_box
    },
    ssao_state = {
      sys = true,
      def = L("0"),
      widget = L("btn_ssao_state"),
      event = event_check_box
    },
    shadow_effect = {
      sys = true,
      def = L("1"),
      widget = L("cb_shadow_effect"),
      text = ui.get_text("central|shadow_effect"),
      event = event_combo_four
    },
    imposter_level = {
      sys = true,
      def = L("1"),
      widget = L("cb_imposter_level"),
      text = ui.get_text("central|view_details"),
      event = event_combo_imposter_level
    },
    enable_animal = {
      sys = true,
      def = L("1"),
      widget = L("btn_enable_animal"),
      event = event_check_box
    },
    enable_jump_teach = {
      sys = true,
      def = L("1"),
      widget = L("btn_enable_jump_teach"),
      event = event_check_box
    },
    enable_auto_rec_video = {
      sys = true,
      def = L("1"),
      widget = L("btn_enable_auto_rec_video"),
      event = event_check_box
    },
    select_gfx = {
      sys = true,
      def = L("0"),
      widget = L("btn_select_gfx"),
      event = event_check_box
    },
    bind_cam = {
      sys = true,
      def = L("0"),
      widget = L("btn_bind_cam"),
      event = event_check_box
    },
    cam_shaker = {
      sys = true,
      def = L("1"),
      widget = L("btn_cam_shaker"),
      event = event_check_box
    },
    cam_inertial = {
      sys = true,
      def = L("1"),
      widget = L("btn_cam_inertial"),
      event = event_check_box
    },
    cam_roll = {
      sys = true,
      def = L("1"),
      widget = L("btn_cam_roll"),
      event = event_check_box
    },
    cam_bigfov = {
      sys = true,
      def = L("0"),
      widget = L("btn_cam_bigfov"),
      event = event_check_box
    },
    ksxl_ride = {
      sys = true,
      def = L("1"),
      widget = L("btn_ksxl_ride"),
      event = event_check_box
    },
    keyboard_move = {
      sys = true,
      def = L("0"),
      widget = L("btn_keyboard_move"),
      event = event_check_box
    },
    fastmove_mode = {
      sys = true,
      def = L("0"),
      widget = L("btn_fastmove_mode"),
      event = event_check_box
    },
    trangle_camera = {
      sys = true,
      def = L("0"),
      widget = L("cb_trangle_camera"),
      text = ui.get_text("central|automatic_camera"),
      event = event_combo_trangle_camera
    },
    trangle_camera_enable = {
      sys = true,
      def = L("0")
    },
    trangle_camera_angle = {
      sys = true,
      def = L("45"),
      widget = L("sld_trangle_camera_angle"),
      event = event_slider
    },
    net = {
      sys = true,
      def = L("0"),
      widget = L("cb_net"),
      event = event_combo_net,
      need_restart = true,
      title = ui.get_text("central|net_group")
    },
    max_people_cnt = {
      sys = true,
      def = L("1"),
      widget = L("sld_max_people_cnt"),
      event = event_slider
    },
    grass_area = {
      sys = true,
      def = L("50"),
      widget = L("sld_grass_area"),
      event = event_slider
    },
    lighteness = {
      sys = true,
      def = L("0"),
      widget = L("sld_lighteness"),
      event = event_slider
    },
    contrast = {
      sys = true,
      def = L("1"),
      widget = L("sld_contrast"),
      event = event_slider
    },
    light_shaft = {
      sys = true,
      def = L("1"),
      widget = L("btn_light_shaft"),
      event = event_check_box
    },
    visibility = {
      sys = true,
      def = L("400"),
      widget = L("sld_visibility"),
      event = event_slider
    },
    ik = {
      sys = true,
      def = L("1"),
      widget = L("btn_ik"),
      event = event_check_box
    },
    cam_radius = {
      sys = true,
      def = L("10"),
      widget = L("sld_cam_radius"),
      event = event_slider_cam_radius
    },
    cam_radius_enable = {
      sys = true,
      def = L("0"),
      widget = L("btn_cam_radius_enable"),
      event = event_check_box
    },
    sound_enable = {
      sys = true,
      def = L("1"),
      widget = L("btn_sound_enable"),
      event = event_check_box
    },
    sound_volume = {
      sys = true,
      def = L("500"),
      widget = L("bar_sound_volume"),
      event = event_barrier
    },
    music_enable = {
      sys = true,
      def = L("1"),
      widget = L("btn_music_enable"),
      event = event_check_box
    },
    music_volume = {
      sys = true,
      def = L("500"),
      widget = L("bar_music_volume"),
      event = event_barrier
    },
    focus_sound = {
      sys = true,
      def = L("0"),
      widget = L("btn_focus_sound"),
      event = event_check_box
    },
    ui_scale_enable = {
      sys = true,
      def = L("0"),
      widget = L("btn_ui_scale_enable"),
      event = event_check_box
    },
    ui_scale_factor = {
      sys = true,
      def = L("1"),
      widget = L("sld_ui_scale_factor"),
      event = event_slider
    },
    ui_screenshot = {
      sys = true,
      def = L(""),
      widget = L("lb_ui_screenshot"),
      event = event_screenshot
    },
    ime_ui_less = {
      sys = true,
      def = L("0"),
      widget = L("btn_ime_ui_less"),
      event = event_check_box
    },
    hide_anim = {
      sys = true,
      def = L("1"),
      widget = L("btn_hide_anim"),
      event = event_check_box
    },
    popup_notice = {
      sys = true,
      def = L("1"),
      widget = L("btn_popup_notice"),
      event = event_check_box
    },
    wide_item_box = {
      sys = true,
      def = L("0"),
      widget = L("btn_wide_item_box"),
      event = event_check_box
    },
    hp_tag_limit = {
      sys = true,
      def = L("0"),
      widget = L("btn_hp_tag_limit"),
      event = event_check_box
    },
    popo_num = {
      sys = true,
      def = L("10")
    },
    display_still_name = {
      sys = true,
      def = L("1")
    }
  }
  copy_cfg_def = {
    video_display_mode = {
      def = L("430x440")
    }
  }
  for i = 0, 16 do
    local d = {
      sys = true,
      def = L("1"),
      widget = sys.format("btn_tagshow_%d", i),
      event = event_check_box
    }
    cfg_def["tagshow_" .. i] = d
  end
  for n, v in pairs(cfg_def) do
    v.name = n
    v.value = v.def
  end
  for n, v in pairs(copy_cfg_def) do
    v.name = n
    v.value = v.def
  end
  local x = sys.xnode()
  if x:load(g_cfg_def_uri) then
    local s = x:find("sys")
    if s ~= nil then
      for i = 0, s.size - 1 do
        local t = s:get(i)
        local cfg_name = tostring(t.name)
        local d = cfg_def[cfg_name]
        if d ~= nil then
          d.def = t:get_attribute("value")
        else
          local d2 = copy_cfg_def[cfg_name]
          if d2 ~= nil then
            d2.value = t:get_attribute("value")
          end
        end
      end
    end
    local e = x:find("effect")
    if e ~= nil then
      local edef = e:find("data")
      if edef ~= nil then
        for i = 0, edef.size - 1 do
          local t = edef:get(i)
          local cfg_name = tostring(t.name)
          local d = cfg_def[cfg_name]
          if d ~= nil then
            d.def = t:get_attribute("value")
          end
        end
      end
    end
  end
  load_config()
  ui.log("setting_game.on_init")
  ime_ui_less_update()
end
function search_widget(d)
  if d.widget == nil then
    return nil
  end
  return w_core:search(d.widget)
end
event_check_box = {
  load = function(d)
    local btn = search_widget(d)
    if btn == nil then
      return
    end
    if d.value == L("1") then
      btn.check = true
    else
      btn.check = false
    end
  end,
  save = function(d)
    local btn = search_widget(d)
    if btn == nil then
      return
    end
    if btn.check then
      d.value = L("1")
    else
      d.value = L("0")
    end
  end
}
event_screenshot = {
  load = function(d)
    local lb = search_widget(d)
    if lb == nil then
      return
    end
    if d.value == L("") then
      lb.text = sys.get_abs_path("$cfg/screenshots")
    else
      lb.text = d.value
    end
  end,
  save = function(d)
    local lb = search_widget(d)
    if lb == nil then
      return
    end
    local sv = lb.svar
    if sv.screenshot_uri ~= nil then
      d.value = sv.screenshot_uri
      sv.screenshot_uri = nil
    end
  end
}
function barrier_make(d, bar)
  local d2 = cfg_def[d.name]
  local f = d2.min + (d2.max - d2.min) * bar.position
  return sys.format("%g", f)
end
event_barrier = {
  load = function(d)
    local bar = search_widget(d)
    if bar == nil then
      return
    end
    local d2 = cfg_def[d.name]
    bar.svar.loading = true
    bar.position = (d.value.v_number - d2.min) / (d2.max - d2.min)
    bar.svar.loading = false
  end,
  save = function(d)
    local bar = search_widget(d)
    if bar == nil then
      return
    end
    d.value = barrier_make(d, bar)
  end,
  init = function(d, ranges)
    local bar = search_widget(d)
    if bar == nil then
      return
    end
    bar.svar.def = d
    local range = ranges:get(d.name)
    if range == nil then
      d.min = 0
      d.max = 1
      return
    end
    d.min = range:get(0).v_number
    d.max = range:get(1).v_number
  end
}
event_combo_box = {
  load = function(d)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    ui_widget.ui_combo_box.clear(cb)
    local range = op_range:get(d.name)
    for i = 0, range.size - 1 do
      local r = range:get(i).v_string
      ui_widget.ui_combo_box.append(cb, {id = r, text = r})
    end
    ui_widget.ui_combo_box.select(cb, d.value)
  end,
  save = function(d)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    local item = ui_widget.ui_combo_box.selected(cb)
    if item ~= nil then
      d.value = item.id
    end
  end
}
event_combo_box_index = {
  load = function(d)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    ui_widget.ui_combo_box.clear(cb)
    local range = op_range:get(d.name)
    for i = 0, range.size - 1 do
      local r = range:get(i).v_string
      ui_widget.ui_combo_box.append(cb, {
        id = L(i),
        text = r
      })
    end
    ui_widget.ui_combo_box.select(cb, d.value)
  end,
  save = function(d)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    local item = ui_widget.ui_combo_box.selected(cb)
    if item ~= nil then
      d.value = item.id
    end
  end
}
function combo_tri_item(d, cb, id, txt)
  local a = sys.variant()
  a:set("lv", txt)
  ui_widget.ui_combo_box.append(cb, {
    id = id,
    text = sys.mtf_merge(a, d.text)
  })
end
event_combo_four_level = {
  load = function(d)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    ui_widget.ui_combo_box.select(cb, d.value.v_int)
  end,
  save = function(d)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    local item = ui_widget.ui_combo_box.selected(cb)
    if item ~= nil then
      d.value = L(item.id)
    end
  end,
  init = function(d, ranges)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    ui_widget.ui_combo_box.clear(cb)
    local base = d.base
    if base == nil then
      base = 0
    end
    combo_tri_item(d, cb, base + 0, ui.get_text("central|low"))
    combo_tri_item(d, cb, base + 1, ui.get_text("central|middle"))
    combo_tri_item(d, cb, base + 2, ui.get_text("central|high"))
    combo_tri_item(d, cb, base + 3, ui.get_text("central|best"))
  end
}
event_combo_tri = {
  load = function(d)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    ui_widget.ui_combo_box.select(cb, d.value.v_int)
  end,
  save = function(d)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    local item = ui_widget.ui_combo_box.selected(cb)
    if item ~= nil then
      d.value = L(item.id)
    end
  end,
  init = function(d, ranges)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    ui_widget.ui_combo_box.clear(cb)
    local base = d.base
    if base == nil then
      base = 0
    end
    combo_tri_item(d, cb, base + 0, ui.get_text("central|low"))
    combo_tri_item(d, cb, base + 1, ui.get_text("central|middle"))
    combo_tri_item(d, cb, base + 2, ui.get_text("central|high"))
  end
}
event_combo_tri_2 = {
  load = function(d)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    ui_widget.ui_combo_box.select(cb, d.value.v_int)
  end,
  save = function(d)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    local item = ui_widget.ui_combo_box.selected(cb)
    if item ~= nil then
      d.value = L(item.id)
    end
  end,
  init = function(d, ranges)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    ui_widget.ui_combo_box.clear(cb)
    local base = d.base
    if base == nil then
      base = 0
    end
    combo_tri_item(d, cb, base + 0, ui.get_text("central|close"))
    combo_tri_item(d, cb, base + 1, ui.get_text("central|middle"))
    combo_tri_item(d, cb, base + 2, ui.get_text("central|high"))
  end
}
event_combo_four = {
  load = event_combo_tri.load,
  save = event_combo_tri.save,
  init = function(d, ranges)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    ui_widget.ui_combo_box.clear(cb)
    combo_tri_item(d, cb, 0, ui.get_text("central|close"))
    combo_tri_item(d, cb, 1, ui.get_text("central|low"))
    combo_tri_item(d, cb, 2, ui.get_text("central|middle"))
    combo_tri_item(d, cb, 3, ui.get_text("central|high"))
  end
}
event_combo_imposter_level = {
  load = event_combo_tri.load,
  save = event_combo_tri.save,
  init = function(d, ranges)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    ui_widget.ui_combo_box.clear(cb)
    combo_tri_item(d, cb, 2, ui.get_text("central|low"))
    combo_tri_item(d, cb, 1, ui.get_text("central|middle"))
    combo_tri_item(d, cb, 0, ui.get_text("central|high"))
  end
}
event_combo_fullscreen = {
  load = event_combo_tri.load,
  save = event_combo_tri.save,
  init = function(d, ranges)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    ui_widget.ui_combo_box.clear(cb)
    ui_widget.ui_combo_box.append(cb, {
      id = 0,
      text = ui.get_text("central|window_mode")
    })
    ui_widget.ui_combo_box.append(cb, {
      id = 2,
      text = ui.get_text("central|full_window")
    })
    ui_widget.ui_combo_box.append(cb, {
      id = 3,
      text = ui.get_text("central|largest_window")
    })
    ui_widget.ui_combo_box.append(cb, {
      id = 1,
      text = ui.get_text("central|full_screen_mode")
    })
  end
}
event_combo_trangle_camera = {
  load = event_combo_tri.load,
  save = event_combo_tri.save,
  init = function(d, ranges)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    ui_widget.ui_combo_box.clear(cb)
    local function insert(id, s)
      ui_widget.ui_combo_box.append(cb, {id = id, text = s})
    end
    insert(0, ui.get_text("central|closed"))
    insert(3, ui.get_text("central|follow_model"))
    insert(1, ui.get_text("central|focus_model"))
    insert(2, ui.get_text("central|symmetrical_model"))
  end
}
event_combo_net = {
  load = event_combo_tri.load,
  save = event_combo_tri.save,
  init = function(d, ranges)
    local cb = search_widget(d)
    if cb == nil then
      return
    end
    ui_widget.ui_combo_box.clear(cb)
    ui_widget.ui_combo_box.append(cb, {
      id = 0,
      text = ui.get_text("setting|net_name_0")
    })
    local net_var = ui.get_net()
    for i = 1, 3 do
      local n = net_var[i]
      if n ~= nil and 0 < n.size then
        ui_widget.ui_combo_box.append(cb, {
          id = i,
          text = ui.get_text("setting|net_name_" .. i)
        })
      end
    end
  end
}
event_slider = {
  load = function(d)
    local sld = search_widget(d)
    if sld == nil then
      return
    end
    if op_range:has(d.name) then
      local range = op_range:get(d.name)
      d.range_min = range:get(0).v_number
      d.range_max = range:get(1).v_number
      if d.range_max - d.range_min < 0.1 then
        d.range_max = d.range_min + 0.1
      end
    else
      d.range_min = 0
      d.range_max = 1
    end
    local f = d.value.v_number
    if f < d.range_min then
      f = d.range_min
    elseif f > d.range_max then
      f = d.range_max
    end
    sld.scroll = (f - d.range_min) / (d.range_max - d.range_min)
  end,
  save = function(d)
    local sld = search_widget(d)
    if sld == nil then
      return
    end
    d.value = d.range_min + (d.range_max - d.range_min) * sld.scroll
  end
}
event_slider_cam_radius = {
  load = function(d)
    local sld = search_widget(d)
    if sld == nil then
      return
    end
    if op_range:has(d.name) then
      local range = op_range:get(d.name)
      d.range_min = range:get(0).v_number
      d.range_max = range:get(1).v_number
      if d.range_max - d.range_min < 0.1 then
        d.range_max = d.range_min + 0.1
      end
    else
      d.range_min = 0
      d.range_max = 1
    end
    local f = d.value.v_number
    if f < d.range_min then
      f = d.range_min
    elseif f > d.range_max then
      f = d.range_max
    end
    sld.scroll = (f - d.range_min) / (d.range_max - d.range_min)
  end,
  save = function(d)
    local sld = search_widget(d)
    if sld == nil then
      return
    end
    d.value = d.range_min + (d.range_max - d.range_min) * sld.scroll
    local check = w_core:search("btn_cam_radius_enable").check
    if not check then
      d.value = cfg_def[d.name].def
    end
  end
}
function on_ui_scale_factor_position(ctrl)
  local btn = w_btn_ui_scale_enable
  btn:search("btn_lb_text").text = ui_widget.merge_mtf({
    pre = math.floor((0.5 + ctrl.scroll * 0.5) * 100)
  }, ui.get_text("central|interface_scaling"))
end
function on_max_people_cnt(ctrl)
  local label = w_label_max_people_cnt
  if ctrl.scroll == 1 then
    label.text = ui.get_text("central|video_player_number_unlimit")
  else
    local c_count = 1 + math.floor(199 * ctrl.scroll)
    label.text = ui_widget.merge_mtf({count = c_count}, ui.get_text("central|video_player_number"))
  end
end
function save_single_config(name, value)
  value = L(value)
  local cfg_def = ui_setting.ui_game.cfg_def
  cfg_def[name].value = value
  local v = bo2.get_config()
  v:set(name, value)
  ui_setting.ui_game.save_config()
end
function copy_cfg(cfg)
  local dst = {}
  for n, v in pairs(cfg) do
    local t = {}
    t.name = n
    t.value = v.value
    t.event = v.event
    t.widget = v.widget
    dst[n] = t
  end
  return dst
end
function widget_load(cfg)
  for n, v in pairs(cfg) do
    local e = v.event
    if e ~= nil and e.load ~= nil then
      sys.pcall(e.load, v)
    end
  end
end
local c_sld_hi = ui.make_color("d3a75e")
local c_sld_hi_tint = ui.tint(c_sld_hi, ui.make_color("000000"))
local c_sld_orig = ui.make_color("ffffff")
local c_sld_orig_tint = ui.tint(c_sld_orig, ui.make_color("000000"))
function on_sld_init(sld, data)
  local lb_lo = sld:search("lb_lo")
  local lb_hi = sld:search("lb_hi")
  local fig_hi = sld:search("fig_hi")
  local lb_name
  if data ~= nil then
    lb_name = sld.parent:search(data)
  end
  local function set_color(c, ct, vis)
    if vis then
      lb_lo.color = c
      lb_hi.color = c
    end
    lb_lo.visible = vis
    lb_hi.visible = vis
    fig_hi.visible = vis
    if lb_name ~= nil then
      if sys.is_type(lb_name, "ui_label") then
        lb_name.color = c
      elseif sys.is_type(lb_name, "ui_button") then
        local lb = lb_name:search("btn_lb_text")
        if lb ~= nil then
          lb.tint_normal = ct
        end
      end
    end
  end
  local function on_mouse(ctrl, msg)
    if msg == ui.mouse_inner then
      set_color(c_sld_hi, c_sld_hi_tint, true)
    elseif msg == ui.mouse_outer then
      set_color(c_sld_orig, c_sld_orig_tint, false)
    end
  end
  local parent = sld.parent
  parent:insert_on_mouse(on_mouse, "ui_setting.ui_game.on_sld_init:on_mouse")
end
function load_default_cfg(tmp, item)
  if item == nil then
    return
  end
  for i = 0, item.size - 1 do
    local n = item:get(i)
    local name = tostring(n.name)
    local v = cfg_def[name]
    if v ~= nil then
      local t = {}
      t.name = name
      t.value = n:get_attribute("value")
      t.event = v.event
      t.widget = v.widget
      tmp[name] = t
    end
  end
end
function show_top(tab)
  ui_central.show_mutex_window("$frame:setting:game")
  w_top:move_to_head()
  if tab ~= nil then
    ui_tab.show_page(w_core, "tab_video", true)
  end
end
function show_default_menu(btn, quick)
  local function on_menu_select(item)
    local cfg = item.cfg
    if cfg == "open" then
      show_top()
      return
    end
    local tmp = {}
    local x = sys.xnode()
    if x:load(g_cfg_def_uri) then
      if not quick then
        load_default_cfg(tmp, x:find("sys"))
      end
      local e = x:find("effect")
      if e ~= nil then
        load_default_cfg(tmp, e:find(cfg))
      end
    end
    if quick then
      if not w_top.visible then
        w_top.visible = true
      end
      widget_load(tmp)
      on_btn_confirm_click()
      ui_central.w_central.visible = false
      return
    end
    widget_load(tmp)
  end
  local cfg_menu = {
    items = {
      {
        text = ui.get_text("central|quality_priority"),
        cfg = "dataHigh"
      },
      {
        text = ui.get_text("central|efficiency_priority"),
        cfg = "dataLow"
      },
      {
        text = ui.get_text("central|equilibrium_effect"),
        cfg = "data"
      }
    },
    source = btn,
    event = on_menu_select,
    auto_size = true
  }
  local x = sys.xnode()
  if x:load(g_cfg_def_uri) then
    local e = x:find("effect")
    for i, v in pairs(cfg_menu.items) do
      check_cfg_level(v, e)
    end
  end
  if quick then
    table.insert(cfg_menu.items, {
      text = ui.get_text("central|open_setting_game"),
      cfg = "open"
    })
  end
  ui_tool.show_menu(cfg_menu)
end
local key_cfg_level = {
  water_effect = 1,
  shadow_effect = 0,
  tex_effect = 0,
  particle_effect = 0,
  render_level = 0,
  grass_area = 0,
  visibility = 300,
  material_state = 1,
  DistViewBlur = 0,
  enable_animal = 0,
  imposter_level = 2,
  ik = 0,
  multisample = L("24x0")
}
local key_cfg_is_text = {multisample = true}
function check_cfg_low()
  for n, v in pairs(key_cfg_level) do
    if not key_cfg_is_text[n] then
      if cfg_def[n].value ~= nil then
        local t = cfg_def[n].value.v_number
        if math.abs(t - v) > 0.01 then
          return false
        end
      end
    elseif cfg_def[n] ~= v then
      return false
    end
  end
  return true
end
function check_cfg_level(menu_item, eff)
  local item = eff:find(menu_item.cfg)
  if item == nil then
    return
  end
  for i = 0, item.size - 1 do
    local n = item:get(i)
    local name = tostring(n.name)
    if key_cfg_level[name] ~= nil then
      local v = cfg_def[name]
      if v ~= nil then
        if not key_cfg_is_text[n] then
          local v0 = v.value.v_number
          local v1 = n:get_attribute("value").v_number
          if math.abs(v1 - v0) > 0.01 then
            return
          end
        elseif v.value ~= n:get_attribute("value") then
          return
        end
      end
    end
  end
  menu_item.check = true
end
function on_btn_defalt_click(btn)
  show_default_menu(btn)
end
function on_btn_confirm_click(btn)
  w_top.visible = false
  local cfgs = {}
  for n, v in pairs(cfg_tmp) do
    local e = v.event
    if e ~= nil and e.save ~= nil then
      e.save(v)
    end
    local d = cfg_def[n]
    local s = v.value
    if d.value ~= s then
      d.value = s
      if d.need_restart then
        table.insert(cfgs, d)
      end
    end
  end
  save_sys_cfg()
  save_config()
  if #cfgs == 0 then
    return
  end
  local stk = sys.mtf_stack()
  stk:raw_push(ui.get_text("setting|msg_need_restart"))
  stk:raw_push("<c+:FF8844><a+:m>")
  for i, v in pairs(cfgs) do
    stk:raw_format([[

%s]], v.title)
  end
  stk:raw_push("<a-><c->")
  ui_widget.ui_msg_box.show_common({
    text = stk.text,
    btn_confirm = true,
    btn_cancel = false
  })
end
function on_ui_screenshot_click(btn)
  local lb = btn.parent:search("lb_ui_screenshot")
  local sv = lb.svar
  local uri = sv.screenshot_uri
  local function on_msg(msg)
    if msg.result == 0 then
      return
    end
    lb.text = msg.input
    sv.screenshot_uri = msg.input
  end
  ui_widget.ui_system_dir.show_open_dir(on_msg, lb.text)
end
function on_dock_offset_restore_click()
  ui_main.dock_offset_restore()
end
function on_btn_cancel_click(btn)
  w_top.visible = false
end
function load_sys_cfg()
  local cfg_sys = bo2.get_config()
  for i = 0, cfg_sys.size - 1 do
    local n, v = cfg_sys:fetch_nv(i)
    local d = cfg_def[tostring(n)]
    if d ~= nil then
      if not d.sys then
        ui.log("config '%s' is not system value.", d.name)
      end
      d.value = v.v_string
    end
  end
end
function ime_ui_less_update()
  if cfg_def.fullscreen.value == L("1") then
    ui.ime_set_ui_less(true)
    return
  end
  if cfg_def.ime_ui_less.value == L("1") then
    ui.ime_set_ui_less(true)
  else
    ui.ime_set_ui_less(false)
  end
end
function hide_anim_update()
  local qbar = rawget(_G, "ui_qbar")
  if qbar == nil then
    return
  end
  qbar.ui_hide_anim.update_cfg()
end
function item_box_update()
  local item = rawget(_G, "ui_item")
  if item == nil then
    return
  end
  item.wide_update()
end
function save_sys_cfg()
  local cfg_sys = sys.variant()
  for n, v in pairs(cfg_def) do
    if v.sys then
      cfg_sys:set(n, v.value)
    end
  end
  bo2.set_config(cfg_sys)
  ime_ui_less_update()
  hide_anim_update()
  item_box_update()
  if sys.check(ui_net_delay) then
    ui_net_delay.on_setting_trangle_camera()
  end
end
function on_top_visible(ctrl, vis)
  if not vis then
    return
  end
  if sys.check(w_core) and w_core.svar.is_tab_loaded == nil then
    w_core.svar.is_tab_loaded = true
    w_core:load_style("$frame/central/setting_game.xml", "setting_game_core")
    insert_tab("tab_video")
    insert_tab("tab_scene")
    insert_tab("tab_sound")
    insert_tab("tab_ui")
    op_range = bo2.get_config_range()
    for n, v in pairs(cfg_def) do
      local e = v.event
      if e ~= nil and e.init ~= nil then
        sys.pcall(e.init, v, op_range)
      end
    end
    ui_tab.show_page(w_core, "tab_video", true)
    ui_tab.set_button_sound(w_core, 578)
  end
  load_sys_cfg()
  cfg_tmp = copy_cfg(cfg_def)
  widget_load(cfg_tmp)
end
function load_config()
  local x = sys.xnode()
  if not x:load(g_cfg_uri) then
    return
  end
  for i = 0, x.size - 1 do
    local t = x:get(i)
    local d = cfg_def[tostring(t.name)]
    if d ~= nil then
      d.value = t:get_attribute("value")
    end
  end
end
function save_config()
  if bo2.video_mode ~= nil then
    return
  end
  load_sys_cfg()
  local x = sys.xnode()
  for n, v in pairs(cfg_def) do
    local t = x:add(n)
    t:set_attribute("value", v.value)
  end
  for n, v in pairs(copy_cfg_def) do
    local t = x:add(n)
    t:set_attribute("value", v.value)
  end
  x:save(g_cfg_uri)
end
function on_volume_position(bar, pos)
  if bar.svar.loading then
    return
  end
  local d = bar.svar.def
  local f = d.min + (d.max - d.min) * bar.position
  bo2.set_single_config(d.name, f)
end
function on_volume_check(btn, chk)
  local pre, name = btn.name:split2("_")
  local d = cfg_def[tostring(name)]
  bo2.set_single_config(d.name, chk)
end
function insert_tab(name)
  local btn_uri = "$frame/central/setting_game.xml"
  local btn_sty = "common_btn_tab"
  local page_uri = "$frame/central/setting_game.xml"
  local page_sty = name
  ui_tab.insert_suit(w_core, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_core, name)
  btn.text = ui.get_text("setting|" .. name)
end
function on_init(ctrl)
end
function get_cfg_auto_rec_video()
  local cfg = cfg_def.enable_auto_rec_video
  if cfg == nil then
    return false
  end
  return cfg.value == L("1")
end
function get_jump_teach()
  local cfg = cfg_def.enable_jump_teach
  if cfg == nil then
    return false
  end
  return cfg.value == L("1")
end
init_once()
