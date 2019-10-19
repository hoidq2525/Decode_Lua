w_tool = nil
w_startup = nil
w_choice = nil
w_main = nil
w_inner_config = nil
w_outer_config = nil
function init_phase_window(top)
  w_tool = ui.create_control(top)
  w_startup = ui.create_control(top)
  w_startup.visible = false
  w_choice = ui.create_control(top)
  w_choice.visible = false
  w_main = ui.create_control(top, "fader")
  w_main.visible = false
end
function init_phase_common_module()
  sys.load_script("$widget/common.mod.xml")
  pcall(ui_common.init)
  sys.load_script("$script/common/packet.mod.xml")
  pcall(packet.init)
  sys.load_script("$widget/packet.mod.xml")
  pcall(ui_packet.init)
  sys.load_script("$script/common/command.mod.xml")
  sys.load_script("$frame/knight/knight.mod.xml")
  sys.load_xcode("bo2", "$script/client/xcode/scnmsg_id.h")
end
function init_phase_widget_module(fake)
  sys.load_script("$gui/phase/tool/tool.mod.xml")
  pcall(ui_tool.init)
  sys.load_script("$gui/phase/tool/video/video.mod.xml")
  sys.load_script("$gui/phase/help/help.mod.xml")
  pcall(ui_help.init)
  sys.load_script("$gui/phase/startup/startup.mod.xml")
  if fake ~= nil then
    pcall(ui_startup.fake_init)
  else
    pcall(ui_startup.init)
  end
  sys.load_script("$gui/phase/choice1/choice.mod.xml")
  pcall(ui_choice.init)
  sys.load_script("$gui/phase/main/main.mod.xml")
  pcall(ui_main.init)
  sys.load_script("$gui/phase/zone/zone.mod.xml")
end
function init_ui_view()
  if g_data_for_ui_view_init ~= nil then
    return
  end
  g_data_for_ui_view_init = true
  init_phase_window(ui_view.w_view)
  init_phase_common_module()
  sys.load_script("$gui/phase/tool/tool.mod.xml")
  pcall(ui_tool.init)
end
local xget_bool = function(x, n)
  return x:xget_attribute(n .. "@value").v_int
end
local function xload_bool(x, n)
  _G[n] = xget_bool(x, n) ~= 0
end
local function load_inner_config()
  local inner_config = "$cfg/tool/pix_dj2_config.xml"
  if not sys.is_file(inner_config) then
    return
  end
  local x = sys.xnode()
  if not x:load(inner_config) then
    return
  end
  local cfg = sys.variant()
  cfg:set(1, 1)
  cfg:set(2, xget_bool(x, "debugger_log"))
  cfg:set(3, xget_bool(x, "trace_log"))
  cfg:set(4, xget_bool(x, "ui_console"))
  cfg:set(5, xget_bool(x, "text_log"))
  bo2.set_config(cfg)
  xload_bool(x, "free_cam_ctr_open")
  xload_bool(x, "ride_pet_wnd")
  xload_bool(x, "inner_config_quick_close")
  return true
end
local function load_outer_config()
  local outer_config = "$cfg/tool/outer_config.xml"
  if not sys.is_file(outer_config) then
    return false
  end
  local x = sys.xnode()
  if not x:load(outer_config) then
    return false
  end
  local cfg = sys.variant()
  cfg:set(1, 1)
  cfg:set(65536, xget_bool(x, "camera_console"))
  bo2.set_config(cfg)
  return true
end
local function basic_init()
  load_inner_config()
  load_outer_config()
  init_phase_window(nil)
  init_phase_common_module()
  init_phase_widget_module()
  ui.set_on_free("ui_phase.free")
  ui_startup.show_top(true, true)
end
function init()
  local is_u = false
  local client_max = bo2.gv_define:find(77)
  if client_max ~= nil then
    client_max = client_max.value.v_int
    if client_max < 1 then
      client_max = 1
    elseif client_max > 32 then
      client_max = 32
    end
  else
    client_max = 4
  end
  for i = 1, client_max do
    if ui.create_u(sys.format("PG_UtilityMessageWindowSet_%d", i)) then
      is_u = true
      break
    end
  end
  sys.pcall(basic_init)
  local starting = "$cfg/tool/ui_init.lua"
  if sys.is_file(starting) then
    ui.log("load starting script %s.", starting)
    sys.load_script(starting)
  end
  if is_u then
    return true
  end
  w_startup.visible = false
  w_choice.visible = false
  w_main.visible = false
  w_main = nil
  w_tool:insert_post_invoke(ui_startup.note_quit)
  return true
end
function free()
end
function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end
function fake_init()
  if load_inner_config() then
    w_inner_config = 1
  end
  if load_outer_config() then
    w_outer_config = 1
  end
  init_phase_window(nil)
  init_phase_common_module()
  init_phase_widget_module(1)
  ui.set_on_free("ui_phase.free")
  local bShow_Top = true
  if bo2.video_tiny_window == 1 then
    bShow_Top = false
  end
  ui_startup.show_top(bShow_Top, bShow_Top)
  local starting = "$cfg/tool/ui_init.lua"
  if sys.is_file(starting) then
    ui.log("load starting script %s.", starting)
    sys.load_script(starting)
  end
  return true
end
function init_config_phase_widget_module()
  init_phase_common_module()
  sys.load_script("$gui/phase/tool/tool_config.mod.xml")
  pcall(ui_tool.config_init)
  sys.load_script("$script/common/command.mod.xml")
end
function init_config_main()
  sys.load_script("$gui/phase/config_main/config_main.mod.xml")
  pcall(ui_config_main.show_top)
end
function config_init()
  local is_u = false
  for i = 1, 1 do
    if ui.create_u(sys.format("PG_CONGIFG_UtilityMessageWindowSet_%d", i)) then
      is_u = true
      break
    end
  end
  load_inner_config()
  init_phase_window(nil)
  init_config_main()
  if is_u then
    return true
  end
  bo2.app_quit()
  return true
end
