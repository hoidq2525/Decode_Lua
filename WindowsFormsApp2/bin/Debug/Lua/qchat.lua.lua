function on_init(panel)
  enter_flag = false
  person_name_list = {}
end
function on_timer()
  if not ui_qchat.w_input.focus and not ui_qchat.w_person_input.focus and ui_qchat.w_qchat.visible then
    ui_qchat.w_qchat.visible = false
  end
end
function on_channel(btn)
  ui_widget.ui_popup.show(ui_chat.w_chat_channel, w_qchat, "y1x1", btn)
  if ui_chat.w_chat_channel.visible == false then
    local channel_list = windows_list[1].control.var:ref("channel_list")
    for i, v in ipairs(windows_list[1].list) do
      if channel_list:has(i) then
        v.enable = channel_list:ref(i):get("check").v_object.check
      end
      display(windows_list[1])
    end
  end
end
function on_personal_list(box, ch)
  ui_chat.on_person_list(box)
end
function insert_person_list_item(target_name, color)
  local item = ui.create_control(ui_chat.w_personal_list, "panel")
  item:load_style("$frame/chat/cha_console.xml", "person_list_item")
  item:search("btn_color").text = target_name
  if color then
    item:search("btn_color").color = ui.make_color(color)
  end
  ui_chat.w_personal_list.dy = ui_chat.w_personal_list.control_size * 22 + 5
end
function on_personal_key(box, key, flag)
  ui_chat.on_personal_key_qchat(box, key, flag)
end
function on_personal_char(box, ch)
  ui_chat.on_personal_char(box, ch)
  ui_qchat.w_personal_list.visible = false
end
function on_personal_focus(box)
  ui_chat.on_personal_focus(box)
end
function on_input(box, key, flag)
  ui_chat.on_input(box, key, flag)
  if key == 17 then
    ui_main.on_key(ui_main, key, flag)
  end
end
function remember_name(target_name)
  if target_name ~= nil then
    for i, v in iparis(person_name_list) do
      if v == target_name then
        return
      end
    end
    table.insert(person_name_list, target_name)
    while #person_name_list > 6 do
      table.remove(person_name_list, 1)
    end
  end
end
function on_char(box, ch)
  ui_chat.on_char(box, ch)
  ui_qchat.w_personal_list.visible = false
  ui_chat.w_personal_list.visible = false
end
function on_ime_click(btn)
  ui_tool.ui_ime.show_profiles(btn)
end
function on_ime_update(ime_p, ime_d)
  local ime_icon = ime_d.icon
  if ime_icon.empty then
    w_ime_fig.visible = true
    w_ime_icon.visible = false
    w_ime_lb.visible = true
    local sn = ime_d.short_name
    if sn.empty then
      w_ime_lb.text = "A"
    else
      w_ime_lb.text = sn
    end
  else
    w_ime_fig.visible = false
    w_ime_icon.visible = true
    w_ime_lb.visible = false
    w_ime_icon.image = ime_icon
  end
  local n = ime_d.name
  if n.empty then
    ime_p.owner.tip.text = ui.get_text("qbar|eng_input")
  else
    ime_p.owner.tip.text = n
  end
end
function on_qchat_visible(ctrl)
  if ctrl.visible == false then
    ui_qchat.w_personal_list.visible = false
    ui_qchat.w_etiquette.visible = false
    ui_qchat.w_expression.visible = false
    if ui_chat.w_chat_channel ~= nil then
      ui_chat.w_chat_channel.visible = false
    end
    if ui_chat.w_personal_list ~= nil then
      ui_chat.w_personal_list.visible = false
    end
  end
end
