function on_event_show(data)
  ui_rand_event.identify_event()
  ui_rand_event.monitor.show_monitor()
end
function on_event_close(data)
  ui_rand_event.monitor.close_monitor()
  ui_rand_event.clear_global()
end
