local http_sucess = 200
g_request_list = {}
g_download_text = {}
g_debug = false
g_error_code_bad_xml = 1
g_error_code_bad_url = 2
g_error_code_time_out = 3
function set_debug()
  g_debug = true
end
function debug_log(str)
  if g_debug ~= false then
    ui.log(str)
  end
end
function finish_url(url)
  if g_request_list[url] ~= nil then
    g_request_list[url] = nil
  end
end
function is_url_finished(url)
  return g_request_list[url] == nil
end
function request_files(t_request)
  if t_request == nil or t_request.url == nil or t_request.file_name == nil then
    debug_log("bad name :" .. url)
    return false
  end
  local url = t_request.url
  t_request.host = bo2.http_get_url_host(url)
  if t_request.host.size <= 0 then
    debug_log("bad host :" .. url)
    return false
  end
  if t_request.ignore_mode ~= nil and g_request_list[url] ~= nil then
    debug_log("ignore :" .. url)
    return false
  end
  g_request_list[url] = 1
  t_request.rst = true
  t_request.c_count = 0
  t_request.reconnect = 5
  t_request.fn_callback = request_xml_files
  t_request.fn_faild = t_request.request_faild
  t_request.data = t_request
  request_single_file(t_request)
end
function request_single_file(t_single_request)
  if t_single_request == nil or t_single_request.url == nil or t_single_request.file_name == nil or t_single_request.fn_callback == nil or t_single_request.fn_faild == nil then
    debug_log("error req " .. t_single_request.url)
    return false
  end
  local url = t_single_request.url
  local file_name = t_single_request.file_name
  local function on_http_finish(rst)
    if rst == http_sucess then
      debug_log("url = " .. url)
      t_single_request.fn_callback(t_single_request.data)
    elseif t_single_request.c_count ~= nil and t_single_request.reconnect ~= nil and t_single_request.c_count < t_single_request.reconnect then
      debug_log("reconnect .." .. t_single_request.c_count)
      t_single_request.c_count = t_single_request.c_count + 1
      bo2.http_get(url, file_name, on_http_finish)
    else
      debug_log("time out")
      t_single_request.fn_faild(rst, t_single_request.data)
    end
  end
  bo2.http_get(url, file_name, on_http_finish)
end
function generate_list_by_xml_root(root)
  if root == nil then
    return nil
  end
  local n_size = root.size - 1
  if n_size < 0 then
    return nil
  end
  local list = {}
  for i = 0, n_size do
    local x = root:get(i)
    local _key = x:get_attribute("key")
    local _url = x:get_attribute(L("url"))
    list[_key] = {
      url = _url,
      index = x:get_attribute_int(L("index")),
      type = x:get_attribute(L("type")),
      file_name = bo2.http_get_url_file(_url),
      key = _key
    }
  end
  return list
end
function generate_file_list(request)
  local file_name = sys.format(L("$cfg/client/user/http/xml/%s"), request.file_name)
  local root = sys.xnode()
  if not root:load(file_name) then
    local v = {}
    v.rst = g_error_code_bad_xml
    request.on_finish_job(request, v)
    return false
  end
  request.file_list = generate_list_by_xml_root(root)
  return true
end
function request_xml_files(request)
  if generate_file_list(request) ~= true then
    return
  end
  if request.file_list == nil then
    local v = {}
    v.rst = g_error_code_bad_xml
    request.on_finish_job(request, v)
    return
  end
  local function process_file_list(v)
    local function fn_rst(v, rst)
      v.finish = true
      v.rst = rst
      request.on_finish_job(request, v)
    end
    local url = v.url
    if url.size <= 0 then
      fn_rst(v, g_error_code_bad_url)
      return
    end
    local host = bo2.http_get_url_host(url)
    local default_host = request.default_url
    if host.size <= 0 then
      local url_host = sys.format(L("%s%s"), default_host, url)
      host = bo2.http_get_url_host(url_host)
      if host.size <= 0 then
        fn_rst(v, g_error_code_bad_url)
        return
      end
      v.url = url_host
    end
    if request.check_local_file ~= nil and request.check_local_file(request, v) == true then
      fn_rst(v)
      return
    end
    debug_log("v.url .." .. v.url)
    v.finsih = false
    local function request_faild()
      debug_log("faild" .. v.url)
      fn_rst(v, g_error_code_time_out)
    end
    local t_single_request = {}
    t_single_request.data = v
    t_single_request.url = v.url
    t_single_request.file_name = v.file_name
    t_single_request.fn_callback = fn_rst
    t_single_request.fn_faild = request_faild
    t_single_request.c_count = 0
    t_single_request.reconnect = 5
    request_single_file(t_single_request)
  end
  for i, v in pairs(request.file_list) do
    process_file_list(v)
  end
end
function t()
  g_debug = true
  local faild = function()
    debug_log(" test faild!")
  end
  local on_finish_job = function()
    local text = ui.get_text(L("event|item_title0"))
    ui.log(text)
  end
  local req = {}
  req.url = L("http://192.168.0.55/hanhongyi/http/event.txt")
  req.file_name = L("event.txt")
  req.on_finish_job = on_finish_job
  req.fn_faild = faild
  req.default_url = L("http://192.168.0.55/hanhongyi/http/")
  req.fn_callback = on_finish_job
  ui_tool.http.request_single_file(req)
end
