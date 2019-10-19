function packet_equip_xinfa(id, b)
  local v = sys.variant()
  v:set(packet.key.xinfa_levelup_id, id)
  v:set(packet.key.equip_xinfa, b)
  bo2.send_variant(packet.eCTS_UI_EquipXinfa, v)
end
function xinfa_not_chosen_err()
  local v = sys.variant()
  v:set(packet.key.ui_text_id, 76067)
  ui_packet.recv_wrap(packet.eSTC_UI_ShowText, v)
end
function set_highlight(ctrl, xinfa)
  ui.log("set_highlight")
  if ctrl == last_highlight_ctrl then
    return
  end
  function set_highlight_in(ctrl, flag)
    if not sys.check(ctrl) then
      return
    end
    local highlight = ctrl:search("highlight")
    if sys.check(highlight) then
      highlight.visible = flag
    end
  end
  set_highlight_in(ctrl, true)
  set_highlight_in(last_highlight_ctrl, false)
  last_highlight_ctrl = ctrl
end
function on_equip_xinfa()
  if sys.check(last_highlight_ctrl) then
    ui_handson_teach.test_complate_xinfacangku_continue_monitor(false)
    ui_widget.ui_msg_box.show_common({
      text = ui.get_text("skill|continue_practise_xinfa"),
      callback = function(ret)
        if ret.result == 1 then
          local id = last_highlight_ctrl:search("xinfa_card").excel_id
          ui.log("id %s", id)
          ui.log("id %s", id)
          packet_equip_xinfa(id, 1)
        end
      end
    })
  else
    xinfa_not_chosen_err()
  end
end
function on_window_visible(ctrl)
  ui_widget.on_esc_stk_visible(ctrl, vis)
  if ctrl.visible == true then
    ui_skill.visible = true
    local length = ctrl.parent.size.x
    local w_skill = ui_skill.w_skill
    local w_lianzhao = ui_lianzhao.w_lianzhao
    if w_skill.x + w_skill.dx / 2 > length / 2 then
      ctrl.x = w_skill.x - ctrl.dx
      ctrl.y = w_skill.y
    else
      ctrl.x = w_skill.x + w_skill.dx
      ctrl.y = w_skill.y
    end
    local cur_fuxinfaNum = ui_skill.w_fuzhi_xinfa_list.item_count + ui_xf_cangku.w_cangku_xinfa_list.item_count
    local xinfa_limited = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_OtherXinFa)
    if xinfa_limited == cur_fuxinfaNum then
      ui_handson_teach.test_complate_xinfacangku_monitor(true)
    end
  else
    ui_skill.w_skill.visible = false
    ui_handson_teach.test_complate_xinfacangku_monitor(false)
    ui_handson_teach.test_complate_xinfacangku_continue_monitor(false)
  end
end
function on_init()
end
