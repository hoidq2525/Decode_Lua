function show()
  local send_level_up = function(ctr)
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_ScnObj_LevelUp, v)
  end
  local temp_text = ui.get_text(L("sociality|will_finish_app"))
  local finish_app_level = bo2.gv_define_sociality:find(37).value
  local finish_app_text = ui_widget.merge_mtf({level = finish_app_level}, temp_text)
  local confirm_text = ui.get_text(L("sociality|ok"))
  local cancel_text = ui.get_text(L("sociality|cancel"))
  ui_widget.ui_msg_box.show_common({
    text = finish_app_text,
    text_confirm = confirm_text,
    text_cancel = cancel_text,
    modal = true,
    init = function(data)
      local w = data.window
      w.size = ui.point(300, 200)
      w.margin = ui.rect(0, 0, 0, 100)
      w:search("btn_confirm").size = ui.point(130, 30)
      w:search("btn_cancel").size = ui.point(130, 30)
      local bg = w.parent
      msg_box_bg = bg
      msg_box_window = w
    end,
    callback = function(ret)
      if ret.result == 1 then
        send_level_up(ret.window)
      end
    end
  })
end
