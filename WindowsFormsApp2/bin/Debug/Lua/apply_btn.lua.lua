function on_click_apply_btn(btn)
  if gx_innermng_pn.visible == true then
    return
  end
  if gx_match_win.visible == false then
    gx_match_win.visible = true
  else
    gx_match_win.visible = false
  end
end
