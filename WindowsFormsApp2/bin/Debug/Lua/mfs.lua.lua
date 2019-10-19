function on_close_click(btn)
  mfs.app_quit()
end
local is_finish = false
local prev_load_tick = 0
function on_timer(t)
  if is_finish then
    local tick = sys.tick()
    if tick - prev_load_tick > 1200000 and mfs.load_progress() == 1000 then
      mfs.load_start()
      prev_load_tick = tick
    end
    return
  end
  local progress = mfs.load_progress() / 10
  w_lb_progress.text = sys.format(L("\188\211\212\216\189\248\182\200\163\186%d%%"), progress)
  w_pic_progress.dx = w_pic_progress.parent.dx * progress / 100
  if progress == 100 then
    is_finish = true
    prev_load_tick = sys.tick()
  end
end
function init()
  w_top = ui.create_control(nil, "panel")
  w_top.visible = true
  w_top:load_style("$gui/phase/mfs/mfs.xml", "mfs")
  mfs.load_start()
  ui.log("load_start")
  return true
end
