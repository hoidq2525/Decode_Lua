g_exit = false
g_wait = true
function wait(con, ...)
  if not sys.check(con) then
    error("bad conditional handler.")
    return false
  end
  repeat
    if not g_wait then
      g_wait = true
      return false
    end
    if con(...) then
      return true
    end
  until not bo2.process_message()
  g_exit = true
  return false
end
function time_wait(long)
  local t1 = os.time()
  return _MODULE.wait(function()
    local t2 = os.time()
    return os.difftime(t2, t1) > long
  end)
end
function wait_break()
  g_wait = false
end
function signal_insert(sig, func, name, index)
  if sig == nil or name == nil then
    error("signal_insert: bad parameter")
    return
  end
  local w = L(name)
  signal_remove(sig, w)
  local d = sig.datas
  if d == nil then
    d = {}
    sig.datas = d
  end
  local n = sig.names
  if n == nil then
    n = sys.variant()
    sig.names = n
  end
  d[w] = func
  if index == nil then
    n:push_back(w)
  else
    n:insert(index, w)
  end
end
function signal_remove(sig, name)
  if sig == nil or name == nil then
    error("signal_insert: bad parameter")
    return
  end
  local d = sig.datas
  if d == nil then
    return
  end
  local n = sig.names
  if n == nil then
    return
  end
  local w = L(name)
  d[w] = nil
  n:erase(n:index(w))
end
function signal_insert_into(sig_table, sig_name, func, name)
  if sig_table == nil or sig_name == nil then
    ui.log("signal_insert_into: sig_table %s, sig_name %s.", sig_table, sig_name)
    error("signal_insert_into: bad parameter.")
    return
  end
  local sig = sig_table[sig_name]
  if sig == nil then
    sig = {}
    sig_table[sig_name] = sig
  end
  signal_insert(sig, func, name)
end
function signal_remove_from(sig_table, sig_name, name)
  if sig_table == nil or sig_name == nil then
    error("signal_remove_from: bad parameter")
    return
  end
  local sig = sig_table[sig_name]
  if sig == nil then
    return
  end
  signal_remove(sig, name)
end
function signal_invoke(sig, ...)
  local d = sig.datas
  if d == nil then
    return
  end
  local n = sig.names
  if n == nil then
    return
  end
  if n.empty then
    return
  end
  for i = 0, n.size - 1 do
    local name = n:get(i).v_string
    local func = d[name]
    if func ~= nil then
      sys.pcall(func, ...)
    end
  end
end
function signal_invoke_into(sigs, name, ...)
  local sig = sigs[name]
  if sig == nil then
    return
  end
  signal_invoke(sig, ...)
end
function init()
end
