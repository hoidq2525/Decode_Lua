function on_init()
end
function on_announce(data)
  w_main:search("desc").mtf = data:get(packet.key.ui_text).v_string
  w_announce_title.text = data:get(packet.key.ui_title).v_string
end
