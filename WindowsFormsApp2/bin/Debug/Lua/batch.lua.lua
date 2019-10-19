function wait(con)
  if not sys.check(con) then
    ui.console_print("null batch conditional handler.")
    error("")
  end
end
function login(data)
  ui_startup.login(data)
end
