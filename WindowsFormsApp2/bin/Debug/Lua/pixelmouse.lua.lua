READ_SAMPLES = -1
READ_EOF = -2
READ_DONE = -3
m_iScorePlaying = READ_DONE
local g_selected_file
function on_init(mainctl)
  bo2.on_PM_init(ui_pixelmouse.on_init_piano, ui_pixelmouse.on_get_noteinfo)
end
function get_visible()
  local w = ui.find_control("$frame:ui_pixelmouse")
  if w ~= nil then
    return w.visible
  end
end
function set_visivle(vis)
  local w = ui.find_control("$frame:ui_pixelmouse")
  if w ~= nil then
    w.visible = vis
  end
end
function on_click_mouse(btn)
  local vis = get_visible()
  set_visivle(not vis)
end
function on_ui_init()
end
function on_open_file(btn)
  local ctr = g_selected_file
  if ctr == nil then
    return
  end
  local filename = ctr:search("file_pm_name").text
  local v = sys.variant()
  v:set(packet.key.pm_file_name, filename)
  bo2.send_variant(packet.eCTS_PM_PlaySolo, v)
end
function play_by_myself(btn)
  local panel = ui.create_control(ui.find_control("$phase:main"), "panel")
  panel:load_style("$frame/pixelmouse/ui_pixelmouse.xml", "file_list")
  local dirs = sys.get_abs_path("$bin/res/pm_res")
  local files = sys.get_files(dirs)
  for i = 0, files.size - 1 do
    local file = tostring(files:get(i).v_string)
    local index = string.find(file, ".mds")
    if index ~= nil then
      local file_info = g_file_list:item_append()
      file_info:load_style("$frame/pixelmouse/ui_pixelmouse.xml", L("file_pm"))
      file_info:search("file_pm_name").text = file
    end
  end
end
function play_with_others(btn)
end
function on_init_piano(v)
  local bg = ui.find_control("$frame:ui_bg_pm")
  if bg ~= nil then
    bg.visible = false
  end
  local octaveRange = v:get(packet.key.pm_octaves_range).v_int
  m_numOctaves = v:get(packet.key.pm_num_octaves).v_int
  set_piano_range(v)
  local validKeyNum = v:get(packet.key.pm_valid_key_num).v_int
  drawPiano(v)
  m_iScorePlaying = READ_SAMPLES
end
function on_close_bg(btn)
  local parent = btn.parent
  if parent ~= nil then
    parent.visible = false
  end
  g_pm_timer.suspended = true
  for i, v in ipairs(m_aScoreBuff) do
    v = nil
  end
  bo2.on_PM_close()
end
function on_close_file_list(btn)
  local parent = btn.parent
  if parent ~= nil then
    parent.visible = false
  end
end
function on_select_file(ctr, vis)
  g_selected_file = ctr
  ctr:search("hilight").visible = vis
end
function DrawLastLogic()
  return false
end
function DrawOneSample()
  if m_iScorePlaying > READ_DONE then
    if m_iScorePlaying == READ_EOF then
      if DrawLastLogic() == true then
        m_iScorePlaying = iSamples * m_iFramesPerSample + m_iTimeCount + 1
        return
      end
    elseif DrawLogic() then
      bo2.on_PM_next_note()
    end
  end
end
function pm_logic()
  DrawOneSample()
end
function pm_display()
  if m_iScorePlaying > READ_DONE then
    DrawSerpentineLine()
  end
end
function on_pm_timer()
  if m_bFirstWaittime > 0 then
    m_bFirstWaittime = m_bFirstWaittime - 1
    return
  end
  pm_logic()
  pm_display()
end
