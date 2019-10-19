function item_recognized_master(cmd, data)
  local value = data:get(packet.key.cmn_val).v_int
  local count = data:get(packet.key.cmn_id).v_int
  ui_widget.ui_msg_box.show_common({
    text = ui_widget.merge_mtf({count = count, value = value}, ui.get_text("item|info_saveitem_recognizedmaster")),
    modal = true,
    btn_confirm = true,
    btn_cancel = true,
    callback = function(msg)
      if msg.result == 1 then
        bo2.send_variant(packet.eCTS_UI_Save_Item_RecognizedMaster, data)
      elseif msg.result == 0 then
        ui_chat.show_ui_text_id(2661)
      end
    end
  })
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_Item_RecognizedMaster, item_recognized_master, "ui_item.item_recognized_master")
