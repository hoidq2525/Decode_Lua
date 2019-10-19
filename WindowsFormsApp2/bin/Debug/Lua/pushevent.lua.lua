local reg = ui_packet.game_recv_signal_insert
local sig = "ui_quest.packet_handler"
local time = 120
function HandleShowPushEvent(cmd, data)
  local inviteID = data:get(packet.key.ui_invite_id).v_int
  local function send_impl(ctr, ack)
    local v = sys.variant()
    v:set(packet.key.cmn_agree_ack, ack)
    v:set(packet.key.ui_invite_id, inviteID)
    bo2.send_variant(packet.eCTS_UI_CommonInviteAck, v)
  end
  local scnid = data:get(packet.key.scn_excel_id).v_int
  local scnline = bo2.gv_scn_list:find(scnid)
  if scnline == nil then
    return
  end
  local pushid = data:get(packet.key.cmn_id).v_int
  local pushline = bo2.gv_push_event:find(pushid)
  if pushline == nil then
    return
  end
  local to_scnid = pushline.to_scn
  local to_scnline = bo2.gv_scn_list:find(to_scnid)
  if to_scnline == nil then
    return
  end
  local aq_id = data:get(packet.key.areaquest_excelID).v_int
  local aqline = bo2.gv_quest_areaquest:find(aq_id)
  if aqline == nil then
    return
  end
  local aqname = aqline.name
  local to_scnname = to_scnline.name
  local info = bo2.gv_text:find(73255).text
  local timeinfo = bo2.gv_text:find(73256).text
  local v = sys.variant()
  v:set("scn", to_scnname)
  v:set("aq_id", aqname)
  v:set("item", pushline.award_item)
  v:set("award_item", aqline.quest_awards[0][0])
  local newinfo = sys.mtf_merge(v, info)
  local tick, msg_data
  local function on_timer(t)
    local s = math.floor(sys.dtick(sys.tick(), tick) / 1000)
    local d = time - s
    if d < 0 then
      d = 0
      msg_data.result = 0
      ui_widget.ui_msg_box.invoke(msg_data)
    end
    local v_2 = sys.variant()
    v_2:set("time", d)
    t.owner.mtf = sys.mtf_merge(v_2, timeinfo)
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/areaquest/push_event.xml",
    style_name = "push_ui",
    modal = false,
    close_on_leavascn = true,
    init = function(data)
      tick = sys.tick()
      msg_data = data
      local w = data.window
      w.size = ui.point(500, 300)
      w:search("rv_text").mtf = newinfo
      w:search("btn_confirm2").text = ui.get_text("common|push_yes")
      w:search("btn_cancel2").text = ui.get_text("common|push_no")
      w:search("show_btn").svar = aq_id
      local t = w:search("timeshow").timer
      t.period = 200
      t.suspended = false
      t:insert_on_timer(on_timer, "pushevent_timer")
      on_timer(t)
    end,
    callback = function(ret)
      local window = ret.window
      if ret.result == 1 then
        send_impl(window, 1)
      elseif ret.result == 0 then
        send_impl(window, 0)
      end
    end
  })
end
reg(packet.eSTC_UI_Push_Event, HandleShowPushEvent, sig)
function push_show(btn)
  ui_areaquest.set_visible()
  local aq_id = btn.svar
  local aqline = bo2.gv_quest_areaquest:find(aq_id)
  if aqline == nil then
    return
  end
  ui_areaquest.show_page_item(aq_id)
end
