local DEFAULT_SECONDS = 30000
local timestart, timeleft
function on_timer(timer)
  local data = ui_widget.ui_msg_box.get_data(timer.owner)
  if data == nil then
    return
  end
  if timestart == nil then
    return
  end
  local dtime = timeleft - sys.dtick(sys.tick(), timestart)
  if dtime > 0 then
    local rich_box = timer.owner:search("rv_text")
    if rich_box ~= nil then
      rich_box.mtf = ui_widget.merge_mtf({
        second = math.floor(dtime / 1000)
      }, ui.get_text("autoshudn|shutdown_des"))
    end
  else
    data.result = 2
    ui_widget.ui_msg_box.invoke(data)
  end
end
function on_init(data)
  local window = data.window
  local timer = window.timer
  if timer ~= nil then
    timer.suspended = false
  end
  local rich_box = window:search("rv_text")
  if rich_box ~= nil then
    rich_box.mtf = ui_widget.merge_mtf({
      second = math.floor(timeleft / 1000)
    }, ui.get_text("autoshudn|shutdown_des"))
  end
end
function activate(left_time)
  if timestart == nil then
    timestart = sys.tick()
  else
    return
  end
  if left_time ~= nil then
    timeleft = math.floor(left_time * 1000)
  else
    timeleft = DEFAULT_SECONDS
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/auto_shutdown/auto_shutdown.xml",
    style_name = "auto_shutdown",
    init = on_init,
    callback = function(msg)
      if msg.result == 1 or msg.result == 2 then
        bo2.app_quit()
        sys.shutdown()
      end
      timer.suspended = true
      timestart = nil
    end,
    modal = true
  })
end
