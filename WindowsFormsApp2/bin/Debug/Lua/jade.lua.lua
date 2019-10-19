function on_init()
end
function on_confirm()
  local on_msg = function(data)
    local v = sys.variant()
    v:set(packet.key.itemdata_val, data.count)
    bo2.send_variant(packet.eCTS_UI_MakeJade, v)
  end
  local count2 = w_count2.text.v_int
  local count1 = w_count1.text.v_int
  local count0 = w_count0.text.v_int
  local count = count2 * 10000 + count1 * 100 + count0
  local s = sys.variant()
  local t = sys.format("<m:%d>", count)
  s:set("count", t)
  local text = sys.mtf_merge(s, ui.get_text("npcfunc|make_jade"))
  local data = {
    callback = on_msg,
    modal = true,
    count = count,
    text = text
  }
  ui_widget.ui_msg_box.show_common(data)
  set_visible(false)
end
function on_cancel()
  set_visible(false)
end
function set_visible(vis)
  w_main.visible = vis
end
