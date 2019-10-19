local g_cfg_uri = L("$cfg/client/setting_game.xml")
local display_item_uri = L("$frame/config/config.xml")
local display_item_name = L("display_mode_item")
local g_cfg_def_uri = L("$cfg/client/setting_game_default.xml")
local g_cfg_uri_stage = {}
local iConfigStage = 1
local bIdentifiedStage = false
local iCpuStage = {}
local iMemoryStage = {}
local iGraphicsStage = {}
local iUseDefaultDisplayMode = true
local mutex_window_name = {
  "display_mode_detail",
  "window_mode",
  "global_setting"
}
local g_window_config = {}
local g_global_config = {}
local g_config_size = 4
local g_global_setting_size = 4
local key_mode = 13
function on_init_config_data()
  g_window_config[1] = {
    key = 0,
    text = ui.get_text("central|window_mode")
  }
  g_window_config[2] = {
    key = 2,
    text = ui.get_text("central|full_window")
  }
  g_window_config[3] = {
    key = 3,
    text = ui.get_text("central|largest_window")
  }
  g_window_config[4] = {
    key = 1,
    text = ui.get_text("central|full_screen_mode")
  }
  g_global_config[1] = {
    key = L("default"),
    text = ui.get_text("config|default_setup")
  }
  g_global_config[2] = {
    key = L("data"),
    text = ui.get_text("central|equilibrium_effect")
  }
  g_global_config[3] = {
    key = L("dataLow"),
    text = ui.get_text("central|efficiency_priority")
  }
  g_global_config[4] = {
    key = L("dataHigh"),
    text = ui.get_text("central|quality_priority")
  }
  g_window_mode_text.text = g_window_config[1].text
  g_global_mode_text.text = g_global_config[1].text
  ui_config.btn_sound.check = true
  ui_config.btn_music.check = true
end
local g_default_config = {}
local g_set_config_lable = {}
function init_once()
  iCpuStage[1] = 1
  iCpuStage[2] = 3
  iCpuStage[3] = 4
  iMemoryStage[1] = 1024
  iMemoryStage[2] = 2048
  iMemoryStage[3] = 3072
  iGraphicsStage[1] = 256
  iGraphicsStage[2] = 512
  iGraphicsStage[3] = 1024
  g_default_config[1] = {}
  g_default_config[2] = {}
  g_default_config[3] = {}
end
init_once()
function on_set_result(stage)
  iConfigStage = stage
  local stage_data = g_default_config[iConfigStage]
  for i, v in pairs(stage_data) do
    local item = ui_config.gx_config_detail:search(i)
    if sys.check(item) then
      local item_pic = item:search("detail_pic_curse")
      item_pic.margin = ui.rect(v, 1, 0, 0)
    end
  end
end
function on_click_calculate_system_score(btn)
  local vSysConfig = bo2.GetSystemConfig()
  local strCpu = vSysConfig:get(L("cpu")).v_string
  local strMemory = vSysConfig:get(L("memory")).v_string
  local vGraphics = vSysConfig:get(L("graphics"))
  local nSize = vGraphics.size
  local i_graphics_memory = 0
  if nSize > 0 then
    for i = 0, nSize - 1 do
      local vInfo = vGraphics:get(i)
      local graphics_desc = vInfo:get(L("graphics_info")).v_string
      local graphics_memory = vInfo:get(L("graphics_memory")).v_string
      i_graphics_memory = graphics_memory.v_int
    end
  end
  local str_cpu_length = strCpu.size
  local str_cpu_pos = strCpu:find(L("CPUs"))
  local i_cpu_num = 1
  if str_cpu_length > str_cpu_pos and 0 < str_cpu_pos - 2 then
    local sub_str = strCpu:substr(str_cpu_pos - 2)
    i_cpu_num = sub_str.v_int
  end
  local i_memory = strMemory.v_int
  local function identify_config_stage(i_cpu_num, i_memory, i_graphics_memory)
    iConfigStage = 3
    local fn_check_stage = function(stage_table, i_config, iStage)
      for i, v in pairs(stage_table) do
        if iStage < i then
          return iStage
        elseif i_config <= v then
          return i
        end
      end
      return 3
    end
    iConfigStage = fn_check_stage(iCpuStage, i_cpu_num, iConfigStage)
    iConfigStage = fn_check_stage(iMemoryStage, i_memory, iConfigStage)
    iConfigStage = fn_check_stage(iGraphicsStage, i_graphics_memory, iConfigStage)
    bIdentifiedStage = true
  end
  identify_config_stage(i_cpu_num, i_memory, i_graphics_memory)
  if iConfigStage == 1 then
    g_lb_suggest.text = ui.get_text("config|low_config")
    local btn = g_btn_group:search("low_config")
    btn.press = true
  elseif iConfigStage == 2 then
    g_lb_suggest.text = ui.get_text("config|mid_config")
    local btn = g_btn_group:search("average_config")
    btn.press = true
  else
    g_lb_suggest.text = ui.get_text("config|high_config")
    local btn = g_btn_group:search("high_config")
    btn.press = true
  end
  on_set_result(iConfigStage)
end
function load_default_config()
end
function load_config()
  local x = sys.xnode()
  if not x:load(g_cfg_uri) then
    return
  end
  local e = x
  if sys.check(e) ~= true then
    return
  end
  local music_data = e:find("music_enable")
  if sys.check(music_data) then
    local set_value = music_data:get_attribute("value")
    if sys.check(set_value) == nil or set_value.empty or set_value == L("0") then
      ui_config.btn_music.check = false
    end
  end
  local sound_data = e:find("sound_enable")
  if sys.check(sound_data) then
    local set_value = sound_data:get_attribute("value")
    if sys.check(set_value) == nil or set_value.empty or set_value == L("0") then
      ui_config.btn_sound.check = false
    end
  end
  local display_mode = e:find("display_mode")
  if sys.check(display_mode) then
    local set_value = display_mode:get_attribute("value")
    if sys.check(set_value) and set_value.empty ~= true then
      g_display_mode_text.text = set_value
    end
  end
  local window_mode = e:find("fullscreen")
  if sys.check(window_mode) then
    local set_value = window_mode:get_attribute("value")
    if sys.check(set_value) and set_value.empty ~= true then
      local string_value = tostring(set_value)
      for i, v in pairs(g_window_config) do
        local key = tostring(v.key)
        if key == string_value then
          g_window_mode_text.text = v.text
          break
        end
      end
    end
  end
end
function save_config()
  local x = sys.xnode()
  if not x:load(g_cfg_def_uri) then
    return
  end
  local x_save = sys.xnode()
  local function get_fullscreen_key()
    local current_text = g_window_mode_text.text
    for i = 1, g_config_size do
      local config = g_window_config[i]
      if config ~= nil and config.text == current_text then
        return config.key
      end
    end
    return 0
  end
  local get_btn_check = function(btn)
    if btn.check == true then
      return 1
    else
      return 0
    end
    return 1
  end
  local s = x:find("sys")
  if s ~= nil then
    for i = 0, s.size - 1 do
      local t = s:get(i)
      local t_name = tostring(t.name)
      local add_nod = x_save:add(t.name)
      if t_name == "music_enable" then
        add_nod:set_attribute("value", get_btn_check(ui_config.btn_music))
      elseif t_name == "sound_enable" then
        add_nod:set_attribute("value", get_btn_check(ui_config.btn_sound))
      elseif t_name == "fullscreen" then
        add_nod:set_attribute("value", get_fullscreen_key())
      else
        add_nod:set_attribute("value", t:get_attribute("value"))
      end
    end
  end
  local e = x:find("effect")
  if e ~= nil then
    local edef
    local function get_effect_key()
      local current_text = g_global_mode_text.text
      for i = 1, g_global_setting_size do
        local config = g_global_config[i]
        if config ~= nil and config.text == current_text then
          local key = config.key
          if key == L("default") then
            key = bo2.get_default_global_setting()
          end
          return key
        end
      end
      return "data"
    end
    local edef_key = get_effect_key()
    edef = e:find(edef_key)
    if edef ~= nil then
      for i = 0, edef.size - 1 do
        local t = edef:get(i)
        local add_nod = x_save:add(t.name)
        local t_name = tostring(t.name)
        if iUseDefaultDisplayMode == false and t_name == "display_mode" then
          add_nod:set_attribute("value", g_display_mode_text.text)
        else
          add_nod:set_attribute("value", t:get_attribute("value"))
        end
      end
    end
  end
  local add_nod = x_save:add("display_mode")
  add_nod:set_attribute("value", g_display_mode_text.text)
  x_save:save(g_cfg_uri)
end
function on_click_save_config()
  save_config()
  on_click_quit()
end
function on_click_quit()
  bo2.app_quit()
end
function on_click_save_low_config()
end
function on_click_save_middle_config()
end
function on_click_save_high_config()
end
function on_click_use_config()
end
function on_config_init()
  on_init_config_data()
  load_config()
end
function show_mutex_window(name)
  for i, v in pairs(mutex_window_name) do
    local w_panel = w_main:search(v)
    if sys.check(w_panel) then
      if name == v then
        w_panel.visible = not w_panel.visible
      else
        w_panel.visible = false
      end
    end
  end
end
function on_click_show_display_mode(btn)
  show_mutex_window("display_mode_detail")
end
function on_click_show_window_mode(btn)
  show_mutex_window("window_mode")
end
function on_click_show_global_mode(btn)
  show_mutex_window("global_setting")
end
function on_click_selected_global_mode(btn)
  w_global_setting.visible = false
  g_global_mode_text.text = btn.text
end
function on_vis_global_setting(w, vis)
  if vis then
    local function global_mode_append_item(lv, data)
      local item = lv:item_append()
      item:load_style(display_item_uri, "global_mode_item")
      local btn_text = item:search("btn_text")
      btn_text.text = data.text
    end
    if vis then
      lv_global_setting:item_clear()
      for i = 1, g_global_setting_size do
        local g_data = g_global_config[i]
        if g_data ~= nil then
          global_mode_append_item(lv_global_setting, g_data)
        end
      end
    end
  end
end
function on_click_selected_window_mode(btn)
  w_window_mode.visible = false
  g_window_mode_text.text = btn.text
end
function on_vis_window_mode(w, vis)
  local function window_mode_append_item(lv, data)
    local item = lv:item_append()
    item:load_style(display_item_uri, "window_mode_item")
    local btn_text = item:search("btn_text")
    btn_text.text = data.text
  end
  if vis then
    lv_window_mode:item_clear()
    for i = 1, g_config_size do
      local g_data = g_window_config[i]
      if g_data ~= nil then
        window_mode_append_item(lv_window_mode, g_data)
      end
    end
  end
end
function on_click_selected_display_mode(btn)
  w_display_mode_detail.visible = false
  g_display_mode_text.text = btn.text
  iUseDefaultDisplayMode = false
end
function on_vis_display_mode_detail(w, vis)
  local function display_mode_append_item(data)
    local item = lv_display_mode_detail:item_append()
    item:load_style(display_item_uri, display_item_name)
    local btn_text = item:search("btn_text")
    btn_text.text = data.v_string
  end
  if vis then
    local v_data = bo2.SystemConfigEnumResolution()
    lv_display_mode_detail:item_clear()
    for i = 0, v_data.size - 1 do
      local data = v_data:get(i)
      display_mode_append_item(data)
    end
  end
end
local g_move_window = false
local g_mover_pos
function on_mouse_set_window_pos(w, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    g_move_window = true
    g_mover_pos = pos
  elseif msg == ui.mouse_move then
    if g_move_window == true and g_mover_pos ~= nil then
      local dx = g_mover_pos.x - pos.x
      local dy = g_mover_pos.y - pos.y
      g_mover_pos = pos
      if dx ~= 0 or dy ~= 0 then
        g_mover_pos = ui.point(g_mover_pos.x + dx, g_mover_pos.y + dy)
        bo2.set_windows_pos(-dx, -dy)
      end
    end
  elseif msg == ui.mouse_lbutton_up then
    g_move_window = false
    g_mover_pos = pos
  elseif msg == ui.mouse_outer then
    g_move_window = false
    g_mover_pos = pos
  end
end
