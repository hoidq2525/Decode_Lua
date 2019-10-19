function textlink_show(ctrl, title)
  local w = ctrl:search("link")
  w.text = title
end
function textlink_Click(jumpType)
  jumpType = jumpType or L("0")
  if jumpType == L("0") then
    w_btn_tab_jade:click()
  else
    w_btn_tab_ingot:click()
  end
end
