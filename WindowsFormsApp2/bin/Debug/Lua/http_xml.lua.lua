local fmt_image_dir = L("$cfg/client/user/http/image/%s")
function get_http_xml(t_xml)
  if t_xml == nil or t_xml.url == nil or t_xml.file_name == nil or t_xml.default_url == nil then
    debug_log("get_http_xml : error t_xml")
    return false
  end
  local url = t_xml.url
  if ui_tool.http.is_url_finished(url) == false then
    return
  end
  local req = {}
  req.url = url
  req.default_url = t_xml.default_url
  req.file_name = t_xml.file_name
  req.file_base_name = t_xml.file_base_name
  req.t_refresh_fn = t_xml.t_refresh_fn
  req.new_req_fn = t_xml.new_req_fn
  local _root = load_local_file_config(req)
  if _root == nil then
    debug_log("error root")
  else
    req.local_list = ui_tool.http.generate_list_by_xml_root(_root)
  end
  req.on_finish_job = on_finish_job
  req.check_local_file = check_local_file
  local function faild()
    ui_tool.http.finish_url(req.url)
  end
  req.request_faild = faild
  ui_tool.http.request_files(req)
end
function debug_log(str)
  ui_tool.http.debug_log(str)
end
function load_local_file_config(request)
  return ui_main.player_cfg_load(request.file_base_name)
end
function is_image_sucess(v)
  return v.rst == nil
end
function save_request_image_config(request)
  if request.file_list == nil then
    debug_log("error")
    return
  end
  local root
  local function process_file_list(v, key)
    if v == nil or v.type == nil then
      return
    end
    if v.type ~= L("image") then
      return
    end
    if v.rst ~= nil then
      return
    end
    if root == nil then
      root = sys.xnode()
    end
    local add_nod = root:add("data")
    add_nod:set_attribute("url", v.url)
    add_nod:set_attribute("key", key)
    add_nod:set_attribute("type", L("image"))
    add_nod:set_attribute("index", v.index)
  end
  for i, v in pairs(request.file_list) do
    process_file_list(v, i)
  end
  if root ~= nil then
    ui_main.player_cfg_save(root, request.file_base_name)
  end
end
function check_finish_job(request, type)
  for i, v in pairs(request.file_list) do
    local check = false
    if type ~= nil then
      if type == v.type then
        check = true
      end
    else
      check = true
    end
    if check == true and (v.finish == nil or v.finish ~= true) then
      return false
    end
  end
  return true
end
function on_finish_job(request, v)
  local function fn_bad_xml()
    request.request_faild()
  end
  local function fn_bad_request()
    if check_finish_job(request) == true then
      request.request_faild()
    end
  end
  error_pross = {}
  error_pross[ui_tool.http.g_error_code_bad_xml] = fn_bad_xml
  error_pross[ui_tool.http.g_error_code_bad_url] = fn_bad_request
  error_pross[ui_tool.http.g_error_code_time_out] = fn_bad_request
  if request == nil then
    call_faild_fn()
    return
  end
  if v == nil then
    call_faild_fn()
    return
  end
  if v.rst ~= nil and error_pross[v.rst] ~= nil then
    error_pross[v.rst]()
    return
  end
  if v.type == nil then
    return
  end
  local refresh_tab = request.t_refresh_fn
  if refresh_tab[v.type] ~= nil then
    refresh_tab[v.type](v)
  end
  if check_finish_job(request, L("image")) and request.save_image == nil then
    request.save_image = 1
    save_request_image_config(request)
  end
  if check_finish_job(request) == true then
    ui_tool.http.finish_url(request.url)
  end
end
function check_local_file(request, v)
  if request.local_list == nil or request.file_list == nil then
    return false
  end
  if v.type ~= L("image") then
    return false
  end
  local list_base = request.local_list[v.key]
  local list_remote = request.file_list[v.key]
  if list_base == nil or list_remote == nil then
    request.new_req_fn()
    return false
  end
  if list_base.file_name ~= nil and list_base.url == list_remote.url then
    local file_path = sys.format(fmt_image_dir, list_base.file_name)
    if sys.is_file(file_path) then
      return true
    end
  end
  request.new_req_fn()
  return false
end
