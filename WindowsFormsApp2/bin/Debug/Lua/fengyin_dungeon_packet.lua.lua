local text1_win, text1_lose, text2_win, text2_lose, text_giveup, text_end, text_end_btn, text_timecd
local send_impl = function(ctr, ack)
  local v = sys.variant()
  v:set(packet.key.cmn_agree_ack, ack)
  bo2.send_variant(packet.eCTS_UI_FenYinBen_Confirm, v)
end
function handle_FengYinBen_UIShow(cmd, data)
  local vis = data:get(packet.key.reload_ui_visible).v_int
  if vis == 0 then
    return
  end
  if text1_win == nil then
    text1_win = ui.get_text("dungeonui|fengyin_win")
    text1_lose = ui.get_text("dungeonui|fengyin_lose")
    text2_win = ui.get_text("dungeonui|fengyin_continue")
    text2_lose = ui.get_text("dungeonui|fengyin_con_lose")
    text_giveup = ui.get_text("dungeonui|fengyin_giveup")
    text_end = ui.get_text("dungeonui|fengyin_end")
    text_end_btn = ui.get_text("dungeonui|fengyin_end_btn")
    text_timecd = ui.get_text("dungeonui|fengyin_timecd")
  end
  local level = data:get(packet.key.scn_level).v_int
  local award = data:get(packet.key.packet.key.cmn_money).v_int
  local iswin = data:get(packet.key.packet.key.cmn_type).v_int
  local conti_num = data:get(packet.key.packet.key.cmn_id).v_int
  local consu_num = data:get(packet.key.packet.key.fengyin_consu_level).v_int
  local money_next_level = data:get(packet.key.packet.key.fengyin_next_level_award).v_int
  local time = data:get(packet.key.packet.key.total_time).v_int
  local money_max = data:get(packet.key.packet.key.fengyin_money_max).v_int
  local old_time = data:has(packet.key.packet.key.ui_comtimer_starttime)
  if old_time == true then
    old_time = data:get(packet.key.packet.key.ui_comtimer_starttime).v_int
    local time_now = ui_main.get_os_time()
    local interval = os.difftime(time_now, old_time)
    if time <= interval then
      return
    else
      time = time - interval
    end
  end
  local flag1 = conti_num > 0
  local flag2 = true
  local text1 = ""
  local text2 = ""
  local text3 = text_giveup
  if iswin == 0 then
    text1 = text1_lose
    text2 = text2_lose
    local v = sys.variant()
    v:set("num", conti_num)
    text2 = sys.mtf_merge(v, text2)
  elseif iswin == 1 then
    text1 = text1_win
    text2 = text2_win
    flag1 = true
  elseif iswin == 3 then
    flag2 = false
    text1 = text_end
    text2 = text_end_btn
  end
  local v = sys.variant()
  v:set("level", level)
  v:set("money", award)
  v:set("num", consu_num)
  v:set("money_next", money_next_level)
  v:set("money_max", money_max)
  text1 = sys.mtf_merge(v, text1)
  local v_2 = sys.variant()
  local tick, msg_data
  local function on_timer(t)
    local s = math.floor(sys.dtick(sys.tick(), tick) / 1000)
    local d = time - s
    if d < 0 then
      d = 0
      msg_data.result = 1
      ui_widget.ui_msg_box.invoke(msg_data)
    end
    v_2:set("time", d)
    t.owner.mtf = text1 .. "\n" .. sys.mtf_merge(v_2, text_timecd)
  end
  ui_widget.ui_msg_box.show_common({
    style_uri = L("$widget/msg_box.xml"),
    style_name = L("cmn_msg_box_common"),
    btn2 = true,
    text = text1 .. "\n" .. text_timecd,
    modal = true,
    close_on_leavascn = true,
    init = function(data)
      tick = sys.tick()
      msg_data = data
      local w = data.window
      w:search("rv_text").margin = ui.rect(4, 8, 4, 24)
      w:search("rv_text").dock = "fill_xy"
      w:search("rv_text").dock_solo = true
      w:search("btn_confirm2").visible = flag2
      w:search("btn_confirm2").text = text3
      w:search("btn_confirm2").dock = "pin_x2"
      w:search("btn_confirm2").margin = ui.rect(0, 0, 8, 0)
      w:search("btn_confirm2").enable = flag1
      w:search("btn_cancel2").dock = "pin_x1"
      w:search("btn_cancel2").text = text2
      w:search("btn_cancel2").margin = ui.rect(8, 0, 0, 0)
      if flag2 == false then
        w:search("btn_cancel2").dock = "pin_xy"
      end
      local t = w:search("rv_text").timer
      t.period = 200
      t.suspended = false
      t:insert_on_timer(on_timer, "fengyin_timer")
      on_timer(t)
      w.size = ui.point(320, 250)
    end,
    callback = function(ret)
      local window = ret.window
      if ret.result == 1 then
        if ret.is_input_enter == 1 then
          send_impl(window, 1)
        else
          send_impl(window, 0)
        end
      elseif ret.result == 0 then
        send_impl(window, 1)
      end
    end
  })
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_dungeonui.ui_fengyin.packet_handle"
reg(packet.eSTC_UI_FengYinBen, handle_FengYinBen_UIShow, sig)
