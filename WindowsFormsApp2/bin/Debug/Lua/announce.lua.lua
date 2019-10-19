local ui_tab = ui_widget.ui_tab
function on_Announce(data)
  w_main:search("desc").mtf = data:get(packet.key.ui_text).v_string
  if data:get(packet.key.cmn_state).v_int == 1 then
    ui_tab.show_page(ui_supermarket.w_main, "announce", true)
  end
  ui_supermarket.ui_trolly.update_goods()
  ui_supermarket.ui_preview.update_goods()
end
function on_observable(w, vis)
  ui_supermarket.ui_recharge.w_main.visible = vis
  if vis then
    ui_supermarket.ui_rank.showall()
  end
end
