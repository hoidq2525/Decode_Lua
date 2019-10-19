local g_cfg_uri = L("$cfg/client/setting_im.xml")
group_msg_tip = L("false")
send_type = 1
dialog_font_size = 14
forbid_search_myinfo = 0
save_friend_msg = L("true")
function on_im_setup_visible(ctrl)
  if ctrl.visible == true then
    load_setup()
  end
end
function set_checkbox_value(name, value)
  local btn = w_imsetup:search(name)
  if btn == nil then
    return
  end
  if value == L("true") then
    btn.check = true
  else
    btn.check = false
  end
end
function send_forbidfriendsearch(value)
  local v = sys.variant()
  v:set(packet.key.sociality_setup_forbidFrdSch, value)
  bo2.send_variant(packet.eCTS_Sociality_ChgForbidFrdSrh, v)
end
function setup_on_ok(btn)
  local x = sys.xnode()
  if not x:load(g_cfg_uri) then
    return
  end
  if w_imsetup:search("show_group_tip").check then
    group_msg_tip = L("true")
  else
    group_msg_tip = L("false")
  end
  local im_cfg_new = 0
  if w_imsetup:search("forbid_search_myinfo").check then
    im_cfg_new = im_cfg_new + 1
  end
  if not w_imsetup:search("can_add").check then
    im_cfg_new = im_cfg_new + 2
  end
  if not w_imsetup:search("can_call").check then
    im_cfg_new = im_cfg_new + 4
  end
  if im_cfg_new ~= forbid_search_myinfo then
    forbid_search_myinfo = im_cfg_new
    send_forbidfriendsearch(forbid_search_myinfo)
  end
  if w_imsetup:search("send_type1").check then
    send_type = 1
  elseif w_imsetup:search("send_type2").check then
    send_type = 2
  else
    send_type = 3
  end
  if w_imsetup:search("save_friend_msg").check then
    save_friend_msg = L("true")
  else
    save_friend_msg = L("false")
  end
  ui_im.btn_im_msg_mgr.enable = w_imsetup:search("save_friend_msg").check
  local t = x:get("show_group_tip")
  t:set_attribute("value", group_msg_tip)
  t = x:get("send_type")
  t:set_attribute("value", send_type)
  t = x:get("save_friend_msg")
  t:set_attribute("value", save_friend_msg)
  x:save(g_cfg_uri)
  btn.topper.visible = false
end
function load_setup()
  set_checkbox_value("show_group_tip", group_msg_tip)
  w_imsetup:search("send_type" .. send_type).check = true
  if bo2.bit_and(forbid_search_myinfo, 1) == 0 then
    w_imsetup:search("forbid_search_myinfo").check = false
  else
    w_imsetup:search("forbid_search_myinfo").check = true
  end
  if bo2.bit_and(forbid_search_myinfo, 2) == 0 then
    w_imsetup:search("can_add").check = true
  else
    w_imsetup:search("can_add").check = false
  end
  if bo2.bit_and(forbid_search_myinfo, 4) == 0 then
    w_imsetup:search("can_call").check = true
  else
    w_imsetup:search("can_call").check = false
  end
  set_checkbox_value("save_friend_msg", save_friend_msg)
end
function im_save_font_size()
  local x = sys.xnode()
  if not x:load(g_cfg_uri) then
    return
  end
  local t = x:find("dialog_font_size")
  if t then
    t:set_attribute("value", dialog_font_size)
  else
    t = x:add("dialog_font_size")
    t:set_attribute("value", dialog_font_size)
  end
  x:save(g_cfg_uri)
end
function im_save_sendtype()
  local x = sys.xnode()
  if not x:load(g_cfg_uri) then
    return
  end
  local t = x:find("send_type")
  if t then
    t:set_attribute("value", send_type)
  else
    t = x:add("send_type")
    t:set_attribute("value", send_type)
  end
  x:save(g_cfg_uri)
end
function im_set_init_once()
  if rawget(_M, "g_already_init") ~= nil then
    return
  end
  g_already_init = true
  local x = sys.xnode()
  if not x:load(g_cfg_uri) then
    local t = x:add("show_group_tip")
    t:set_attribute("value", group_msg_tip)
    t = x:add("send_type")
    t:set_attribute("value", send_type)
    t = x:add("dialog_font_size")
    t:set_attribute("value", dialog_font_size)
    t = x:add("save_friend_msg")
    t:set_attribute("value", save_friend_msg)
    x:save(g_cfg_uri)
  else
    local t = x:get("show_group_tip")
    if t then
      group_msg_tip = t:get_attribute("value")
    end
    t = x:get("send_type")
    if t then
      send_type = t:get_attribute("value").v_number
    end
    t = x:get("dialog_font_size")
    if t then
      dialog_font_size = t:get_attribute("value")
    end
    t = x:get("save_friend_msg")
    if t then
      save_friend_msg = t:get_attribute("value")
    end
    ui_im.btn_im_msg_mgr.enable = save_friend_msg == L("true")
  end
end
