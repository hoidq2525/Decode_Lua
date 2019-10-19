function InitApply()
  g_allRadios = {
    {
      ctrl = gx_apply_btn_1,
      num = 1,
      txt = ui.get_text("dooaltar|apply_txt_1")
    },
    {
      ctrl = gx_apply_btn_3,
      num = 3,
      txt = ui.get_text("dooaltar|apply_txt_3")
    },
    {
      ctrl = gx_apply_btn_5,
      num = 5,
      txt = ui.get_text("dooaltar|apply_txt_5")
    }
  }
  gx_apply_btn_1.check = true
  gx_apply_btn_3.enable = false
  gx_apply_btn_5.enable = false
end
function ClickApplyBtn()
  for _, radio in ipairs(g_allRadios) do
    if radio.ctrl.check then
      local dialog = {
        text = radio.txt,
        modal = true,
        btn_confirm = 1,
        btn_cancel = 1,
        callback = function(data)
          if data.result == 1 then
            local var = sys.variant()
            var:set(packet.key.arena_mode, radio.num)
            var:set(packet.key.cmn_name, data.input)
            bo2.send_variant(packet.eCTS_UI_DooAltarSignIn, var)
            gx_apply_window.visible = false
          end
        end
      }
      if radio.num ~= 1 then
        dialog.input = ui.get_text("dooaltar|input_teamname")
        dialog.limit = 25
      end
      ui_widget.ui_msg_box.show_common(dialog)
      return
    end
  end
end
function ClickCancelBtn()
  gx_apply_window.visible = false
end
function AckTeamInvite(click, data)
  local v = sys.variant()
  v:set(packet.key.cmn_id, data:get(packet.key.cmn_id))
  if click == "yes" then
    v:set(packet.key.cmn_agree_ack, 1)
  end
  bo2.send_variant(packet.eCTS_DooAltar_TeamAck, v)
end
