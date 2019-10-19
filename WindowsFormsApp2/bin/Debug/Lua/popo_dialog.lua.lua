local wait_time = 30
local match_info = 0
local g_agree_bool = false
function tell_friend()
  if match_info == 0 or match_info == nil then
    return
  end
  local match_type_s = match_info:get(packet.key.arena_mode).v_int
  if match_type_s == bo2.eMatchType_Act3V3 then
    return
  end
  if gx_popo_dialog_radio.check == false then
    return
  end
  local match_id = match_info:get(packet.key.arena_id)
  local match_type = simple_GetMatchType(match_info)
  local group1 = match_info:get(packet.key.arena_a_turn)
  local group2 = match_info:get(packet.key.arena_b_turn)
  local text = sys.format("%s:%s VS %s", match_type, group1, group2)
  local stk = sys.format("<arena:%s,%s>", match_id, text)
  local v = sys.variant()
  v:set(packet.key.chat_channel_id, 11)
  v:set(packet.key.chat_text, stk)
  bo2.send_variant(packet.eCTS_UI_Chat, v)
end
function agree_popo(click, data)
  ui_match.on_click_apply_enter()
  tell_friend()
  g_agree_bool = true
  gx_popo_dialog_win.visible = false
end
function cancel_popo(click, data)
  gx_popo_dialog_win.visible = false
end
function on_popo_dialog_init()
end
function on_popo_dialog_vis(panel, vis)
  if vis == false and g_agree_bool == false then
    local v = sys.variant()
    v:set(packet.key.cmn_agree_ack, 0)
    bo2.send_variant(packet.eCTS_UI_Arena_ReplyMatchAsk, v)
  else
    g_agree_bool = false
  end
end
function match_popo(cmd, data)
  wait_time = 30
  match_info = data:get(packet.key.cmn_dataobj)
  local type = data:get(packet.key.ui_popo_type).v_string
  if type == L("arena") then
    gx_popo_dialog_win.visible = true
    gx_popo_dialog_win:search("btn_comfirm").text = ui.get_text("match|popo_text_new_confirm")
    gx_popo_dialog_win:search("btn_cancel").text = ui.get_text("match|popo_text_new_cancel")
    do
      local mtf = {second = 6}
      local function on_time_set_text()
        if sys.check(gx_popo_dialog_win) ~= true or gx_popo_dialog_win.visible ~= true then
          return
        end
        mtf.second = mtf.second - 1
        if mtf.second < 0 then
          gx_popo_dialog_win.visible = false
          return
        end
        ui_match.gx_text.text = ui_widget.merge_mtf(mtf, sys.format(ui.get_text("match|popo_text_new")))
        bo2.AddTimeEvent(25, on_time_set_text)
      end
      on_time_set_text()
    end
  else
    gx_popo_dialog_win.visible = true
    gx_popo_dialog_win:search("btn_comfirm").text = ui.get_text("common|confirm")
    gx_popo_dialog_win:search("btn_cancel").text = ui.get_text("common|cancel")
    gx_popo_dialog_radio.visible = true
    ui_match.gx_text.text = ui.get_text("match|popo_dialog_text_2")
  end
end
function match3v3_popo(cmd, data)
  gx_popo_dialog_win.visible = true
  gx_popo_dialog_win:search("btn_comfirm").text = ui.get_text("match|join_immediate")
  gx_popo_dialog_win:search("btn_cancel").text = ui.get_text("match|join_later")
end
function popo_timeout()
  g_agree_bool = true
  gx_popo_dialog_win.visible = false
end
function set_visible(vis)
  gx_popo_dialog_win.visible = vis
end
