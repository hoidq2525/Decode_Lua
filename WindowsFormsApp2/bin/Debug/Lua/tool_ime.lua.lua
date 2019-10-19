local c_space = SHARED(" ")
function on_ime_update(p, ime_d)
  if not ime_d.composition_visible then
    w_top.visible = false
    return
  end
  local focus = ui.get_focus()
  if focus == nil or not focus.ime_able then
    w_top.visible = false
    return
  end
  w_top.visible = true
  w_top.dx = 400
  w_top.dy = 400
  w_composition_text.text = nil
  w_candidate_text.text = nil
  w_composition_icon.image = ime_d.icon
  if w_composition_icon.extent.x <= 16 then
    w_composition_icon.size = ui.point(16, 16)
  else
    w_composition_icon.size = ui.point(24, 24)
  end
  w_composition_text.text = ime_d.composition
  w_composition_caret.x = w_composition_text:measure(0, ime_d.caret).x + 6
  if not ime_d.candidate_visible then
    w_candidate_text.parent.visible = false
    w_top.dx = w_composition_text.dx + 40
    w_top.dy = w_composition_text.parent.dy
    w_top:show_popup(focus, "y_auto")
    return
  end
  w_candidate_text.parent.visible = true
  local stk = sys.mtf_stack()
  local candidate_list = ime_d.candidate_list
  for i = 0, candidate_list.size - 1 do
    if ime_d.candidate_index == i then
      stk:raw_push("<c+:FF0000>")
    end
    local d = i + 1
    if d >= 10 then
      d = d - 10
    end
    if i > 0 then
      stk:raw_format([[

%d. ]], d)
    else
      stk:raw_format("%d. ", d)
    end
    local txt = candidate_list[i]
    if txt == c_space then
      stk:raw_push("<img:$image/mtf/pic_sel_3.png>")
    else
      stk:push(txt)
    end
    if ime_d.candidate_index == i then
      stk:raw_push("<c->")
    end
  end
  w_candidate_text.mtf = stk.text
  w_top:tune("rb_text")
  if w_top.dx < 160 then
    w_top.dx = 160
  end
  local minw = w_composition_text.dx + 40
  if minw > w_top.dx then
    w_top.dx = minw
  end
  w_top:show_popup(focus, "y_auto")
end
function show_profiles(btn)
  local on_event = function(item)
    ui.get_ime_data():set_profile(item.key)
  end
  local profiles = ui.get_ime_data().profiles
  local items = {}
  for i = 0, profiles.size - 1 do
    do
      local pro = profiles:get(i)
      local item = {
        style_uri = "$gui/phase/tool/tool_ime.xml",
        style = "ime_profile_item",
        text = pro:get("name").v_string,
        icon = pro:get("icon").v_string,
        key = pro:get("key").v_string,
        get_extent = function(d)
          local p = d.list_item
          local pic = p:search("pic_icon")
          pic.image = d.icon
          local active = pro:get("active").v_int == 1
          p:search("enc_0").visible = active
          p:search("enc_1").visible = active
          local lb = p:search("lb_text")
          return lb.dx + 48
        end
      }
      table.insert(items, item)
    end
  end
  ui_tool.show_menu({
    items = items,
    event = on_event,
    source = btn,
    dx = 120,
    dy = 50,
    popup = "y_auto"
  })
end
