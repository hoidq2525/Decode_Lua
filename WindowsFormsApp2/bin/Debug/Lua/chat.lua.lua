g_data = {
  id = 0,
  last_index = 0,
  md5 = 0
}
chat_table = {}
log_list_limit = 20
function get_main_ctl()
  local w = ui.find_control("$frame:top_win")
  return w
end
function set_visible(vis)
  local w = ui.find_control("$frame:top_win")
  w.visible = vis
  if vis == true then
  end
end
function get_visible()
  local w = ui.find_control("$frame:top_win")
  return w.visible
end
function reset(id)
  g_data.id = id
  g_data.last_index = 0
  g_data.md5 = 0
end
function refresh_chat_info(id)
  ui_widget.ui_chat_list.clear(gx_chat_list)
  ui_widget.ui_chat_list.clear(gx_chat_list_items)
  gx_chatFloor.text = ""
  if ui_stall.chat.chat_table ~= nil then
    ui_stall.chat.chat_table[id] = nil
  end
  reset(id)
  if id ~= L("0") then
    local v = sys.variant()
    v:set(packet.key.cmn_id, g_data.id)
    v:set(packet.key.cmn_index, g_data.last_index)
    v:set(packet.key.cmn_md5, g_data.md5)
    bo2.send_variant(packet.eCTS_Newsgroup_GetUpdateReq, v)
  end
end
local append_chatlist = function(data)
  local str
  local record_info = sys.format("<a+:l>%s<a->", ui.get_text("stall|record_info"))
  local text2 = sys.format("%s", os.date("%H:%M", os.time()))
  if data:has(packet.key.cmn_system_flag) then
    local theinfo = ""
    if data:has(L("money")) then
      if data:has(packet.key.ride_petid) == false then
        theinfo = sys.mtf_merge(data, ui.get_text("common|stall_system_tag"))
      else
        local param = data:get(packet.key.ride_petid)
        local txt_r = sys.format(ui.get_text("common|stall_system_ridepet_tag"), ui.ride_encode_1(param:get(packet.key.ride_excelid).v_int, param:get(packet.key.ride_onlyid).v_string, data:get("get_item").v_string))
        theinfo = sys.mtf_merge(data, txt_r)
      end
    elseif data:has(L("rmb")) then
      if data:has(packet.key.ride_petid) == false then
        theinfo = sys.mtf_merge(data, ui.get_text("stall|rmb_info_systag"))
      else
        local param = data:get(packet.key.ride_petid)
        local txt_r = sys.format(ui.get_text("stall|rmb_info_ridepet_systag"), ui.ride_encode_1(param:get(packet.key.ride_excelid).v_int, param:get(packet.key.ride_onlyid).v_string, data:get("get_item").v_string))
        theinfo = sys.mtf_merge(data, txt_r)
      end
    end
    ui_widget.ui_chat_list.insert(gx_chat_list_items, {text = theinfo}, 0, SHARED("$frame/stall/chat.xml"), SHARED("stall_chat_list_item"))
  else
    local stk = sys.mtf_stack()
    local thetime = sys.mtf_merge(data, ui.get_text("common|stall_chat_time"))
    stk:push(thetime)
    stk:raw_format("<c+:BB2222><u:%s><c-> : ", data:get(packet.key.cha_name).v_string)
    stk:raw_push(data:get(packet.key.chat_text).v_string)
    str = stk.text
    ui_widget.ui_chat_list.insert(gx_chat_list, {text = str}, 0, SHARED("$frame/stall/chat.xml"), SHARED("stall_chat_list_item"))
  end
  local id = bo2.player:get_qwordtemp(bo2.ePFlagQwordTemp_StallNewsgroup)
  if chat_table[id] ~= nil then
    while #chat_table[id] > log_list_limit do
      table.remove(chat_table[id], 1)
    end
  else
    chat_table[id] = {}
  end
  table.insert(chat_table[id], str)
end
local set_chatlist_firstfloor = function(data)
  g_data.md5 = data:get(packet.key.cmn_md5).v_int
  gx_chatFloor.mtf = data:get(packet.key.chat_text).v_string
end
function add_chat_info(data)
  local idx = data:get(packet.key.cmn_index).v_int
  if idx == 0 then
    set_chatlist_firstfloor(data)
  end
  if idx > g_data.last_index then
    append_chatlist(data)
    g_data.last_index = idx
  end
end
function send_stall_chat()
  local txt = gx_chat_inputbox.mtf
  if txt.empty then
    return
  end
  local v = sys.variant()
  v:set(packet.key.cmn_id, g_data.id)
  v:set(packet.key.chat_text, txt)
  bo2.send_variant(packet.eCTS_Newsgroup_AddInfo, v)
  gx_chat_inputbox.text = nil
  refresh_chat_info(g_data.id)
end
function on_keydown_return(ctrl, key, keyflag)
  if key == ui.VK_RETURN and keyflag.down then
    send_stall_chat()
  end
end
function on_click_sendchat_btn()
  send_stall_chat()
end
function on_click_refreshchat_btn()
  refresh_chat_info(g_data.id)
end
function ClickFloorEditBtn(btn)
  gx_chatFloor.focus_able = not gx_chatFloor.focus_able
  gx_chatFloor.focus = gx_chatFloor.focus_able
  local ctr = btn:upsearch_name("fig_frm")
  if ctr ~= nil then
    ctr:search("fig_input").visible = gx_chatFloor.focus_able
  end
  if not gx_chatFloor.focus_able then
    local v = sys.variant()
    v:set(packet.key.cmn_id, g_data.id)
    v:set(packet.key.chat_text, gx_chatFloor.mtf)
    v:set(packet.key.cmn_theme, 1)
    bo2.send_variant(packet.eCTS_Newsgroup_AddInfo, v)
  end
end
function ResetFloor(isOwner)
  gx_chatFloor.focus_able = false
  gx_chatFloor.focus = false
  gx_chatFloorBtn.visible = isOwner
end
