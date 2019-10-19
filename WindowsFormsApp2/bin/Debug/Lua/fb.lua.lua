function ShowTokenWeb()
  if w_ie:search("ie") == nil or g_token == nil then
    local p = w_ie:search("iewrap")
    p:control_clear()
    local c = ui.create_control(p, "wnd_html_view")
    c:load_style("$frame/facebook/fb.xml", "ie")
  end
  w_ie.visible = true
end
function OnResetDevice(ctrl)
  ctrl.visible = false
end
function InitUp()
  g_token = nil
  g_peekToken = false
  g_doPost = false
  local f = function(ctrl, vis)
    if vis and sys.check(w_ie) then
      w_ie.visible = false
    end
  end
  ui_widget.ui_msg_box.msg_modal_bg:insert_on_visible(f, "ui_fb")
  ui_tool.w_msg_top:insert_on_visible(f, "ui_fb")
end
function PostSnapshot(btn)
  local path = bo2.snapshot()
  w_sharepic.image = path
  w_sharetxt.text = ""
  if g_token then
    w_share.visible = true
  else
    ShowTokenWeb()
    g_peekToken = true
  end
end
function ShareIt()
  if g_token then
    url = L("http://dj2.qq.com")
    ui.facebook_feed("graph.facebook.com:443:/me/photos", w_sharetxt.text, g_token, w_sharepic.image)
    w_share.visible = false
    bo2.send_variant(packet.eCTS_UI_Facebook)
  end
end
function test()
  PostSnapshot()
end
function PeekToken()
  local ie = w_ie:search("ie")
  if g_peekToken and w_ie.visible and ie then
    local token = ie.facebook
    if token.size > 0 then
      g_peekToken = false
      g_token = token
      w_ie.visible = false
      g_doPost = true
    end
  elseif g_doPost and w_ie.visible == false then
    g_doPost = false
    w_share.visible = true
  end
end
function AutoShowFbBtn(btn)
  btn.visible = bo2.get_zone() == L("vi_vn")
end
