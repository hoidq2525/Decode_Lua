function init_give()
  local player = bo2.player
  local target = bo2.findobj(player.target_handle)
  w_send_info.mtf = L("<a:m>") .. ui_widget.merge_mtf({
    u = sys.format("<u:%s>", target.name)
  }, ui.get_text("item_rose|send_card_target_name"))
  w_send_info:update()
  w_send_info.dy = w_send_info.extent.y
  local svar = w_top.svar
  svar.target_handle = target.sel_handle
  svar.target_only_id = target.only_id
  svar.target_name = target.name
end
function check_give(svar)
  local player = bo2.player
  if sys.check(player) == false then
    return
  end
  local target_handle
  if svar ~= nil then
    target_handle = svar.target_handle
  else
    target_handle = player.target_handle
  end
  local target = bo2.findobj(target_handle)
  if target == nil or target.kind ~= bo2.eScnObjKind_Player or target == player or svar ~= nil and svar.target_only_id ~= target.only_id then
    ui_tool.note_insert_error(ui.get_text("item_rose|send_card_limit_target"))
    return false
  end
  if target:get_flag_objmem(bo2.eFlagObjMemory_FightState) > 0 then
    ui_tool.note_insert_error(ui.get_text("item_rose|send_card_limit_fight"))
    return false
  end
  return true
end
local clear_input = function(rb)
  rb.text = ""
  local lb = rb:search("lb_input_desc")
  if lb ~= nil then
    lb.visible = true
  end
end
function on_input_focus(ctrl, focus)
  local lb = ctrl:search("lb_input_desc")
  if focus then
    lb.visible = false
  else
    lb.visible = ctrl.item_count == 0
  end
end
function on_cmn_visible(ctrl, vis)
  ui_widget.on_esc_stk_visible(ctrl, vis)
  if not vis then
    return
  end
  local pn = ctrl:search("luohua_panel")
  local p = pn.control_head
  while p ~= nil do
    p:reset()
    p = p.next
  end
end
function show(info, excel_id)
  if not check_give() then
    return
  end
  w_top.visible = true
  w_top:move_to_head()
  clear_input(w_input)
  local svar = w_top.svar
  if info ~= nil then
    svar.excel_id = info.excel_id
  else
    svar.excel_id = excel_id
  end
  init_give()
end
local init = function()
end
function on_visible(ctrl, vis)
  if vis then
    if sys.check(rawget(_M, "w_core")) then
      return
    end
    w_top:load_style("$frame/item/item_card.xml", "main")
    w_top:apply_dock(true)
  end
end
function on_send_timer(t)
  if not check_give() then
    w_top.visible = false
    return
  end
  local player = bo2.player
  local target = bo2.findobj(player.target_handle)
  local svar = w_top.svar
  if target.only_id ~= svar.target_only_id then
    init_give()
  end
end
function on_give_click()
  local svar = w_top.svar
  if not check_give(svar) then
    return
  end
  local count = 1
  local item_info = ui.item_of_excel_id(svar.excel_id)
  if item_info == nil or count > item_info.count then
    w_top.visible = false
    ui_chat.show_ui_text_id(73301)
    return
  end
  local stk = sys.mtf_stack()
  stk:merge({
    u = sys.format("<u:%s>", svar.target_name),
    n = count,
    item = sys.format("<i:%d>", svar.excel_id)
  }, ui.get_text("item_rose|send_msg_desc"))
  local v = sys.variant()
  v[packet.key.item_count] = count
  v[packet.key.scnobj_handle] = svar.target_handle
  v[packet.key.cha_onlyid] = svar.target_only_id
  local text = w_input.text
  if text.size > 0 then
    v[packet.key.ui_text] = text
    stk:raw_push([[


<c:FF9A9A>]])
    stk:raw_push(ui.get_text("item_rose|send_chat_msg"))
    stk:push(text)
  else
    stk:raw_push([[


<c:FF0000>]])
    stk:raw_push(ui.get_text("item_rose|send_chat_no"))
  end
  ui_widget.ui_msg_box.show_common({
    text = stk.text,
    callback = function(msg)
      if msg.result == 1 then
        w_top.visible = false
        ui_item.send_use(item_info, v)
      end
    end
  })
end
function on_recv_close(w)
  local recv_windows = rawget(_M, "g_recv_windows")
  if recv_windows == nil then
    return
  end
  for i, win in ipairs(recv_windows) do
    if w == win then
      table.remove(recv_windows, i)
      break
    end
  end
end
function on_recv_visible(w, v)
  if not v then
    on_recv_close(w)
    w:post_release()
  end
end
local info_make = function(info, txt)
  local x_limit = 220
  info.size = ui.point(x_limit, 400)
  if txt ~= nil then
    info.mtf = txt
    info:update()
  end
  local ext = info.extent
  local dx = ext.x
  if x_limit < dx then
    dx = x_limit
  end
  info.size = ui.point(dx, ext.y)
end
local function update_recv(top)
  local svar = top.svar
  local data = svar.msg_data
  local player = bo2.player
  local stk = sys.mtf_stack()
  local sender_name = data[packet.key.cha_name]
  local stk = sys.mtf_stack()
  stk:merge({
    u = sys.format("<u:%s>", sender_name)
  }, ui.get_text("item_rose|recv_card_sender"))
  stk:push("\n")
  svar.info_text = stk.text
  svar.rank_id = bo2.eRankIndex_shouhua
  svar.sender_name = sender_name
  svar.excel_id = data[packet.key.item_excelid]
  stk:push("\n")
  info_make(svar.rb_recv_info, stk.text)
end
function show_recv(data)
  local top = ui.create_control(ui_main.w_top, "panel")
  top:load_style("$frame/item/item_card.xml", "recv")
  top.visible = true
  top:move_to_head()
  local recv_windows = rawget(_M, "g_recv_windows")
  if recv_windows == nil then
    recv_windows = {}
    g_recv_windows = recv_windows
  end
  table.insert(recv_windows, top)
  local cnt = #recv_windows
  if cnt == 2 then
    local w1 = recv_windows[1]
    local w2 = recv_windows[2]
    w1.dock = "none"
    w2.dock = "none"
    local mt = ui_main.w_top
    local cx = mt.dx * 0.5
    local cy = mt.dy * 0.5 - w1.dy * 0.5
    local dx = w1.dx
    w1.offset = ui.point(cx - dx, cy)
    w2.offset = ui.point(cx, cy)
  end
  local count = 1
  local note = data[packet.key.ui_text]
  if note == nil then
    note = ui_widget.merge_mtf({n = count}, ui.get_text("item_rose|recv_chat_card"))
  end
  top:search("rb_recv_chat").text = note
  local svar = top.svar
  svar.msg_data = data
  svar.rb_recv_info = top:search("rb_recv_info")
  update_recv(top)
end
function on_give_back_click(btn)
  local top = btn.topper
  local svar = top.svar
  local sender = bo2.get_scn_obj_by_name(svar.sender_name)
  if sender == nil then
    ui_tool.note_insert_error(ui_widget.merge_mtf({
      name = svar.sender_name
    }, ui.get_text("item_rose|dist_max")))
    return
  end
  top.visible = false
  bo2.player:SetTarget(sender.sel_handle)
  show(nil, svar.excel_id)
end
function on_thanks_click(btn)
  ui_qchat.w_qchat.visible = true
  ui_qchat.w_input.focus = true
  local top = btn.topper
  local svar = top.svar
  ui_chat.set_channel(bo2.eChatChannel_PersonalChat, svar.sender_name)
  ui_qbar.ui_hide_anim.play(btn, ui_qchat.w_input)
end
local set_input = function(rb, txt)
  rb.text = txt
  local lb = rb:search("lb_input_desc")
  if lb ~= nil then
    if txt == nil or txt.size == 0 then
      lb.visible = true
    else
      lb.visible = false
    end
  end
end
function show_reload(v)
  ui_tool.note_insert_error(ui.get_text("item_rose|send_badword"))
  local target_handle = v[packet.key.scnobj_handle]
  local target_only_id = v[packet.key.cha_onlyid]
  local player = bo2.player
  if target_handle ~= player.target_handle then
    return false
  end
  local target = bo2.findobj(player.target_handle)
  if target == nil or target.only_id ~= target_only_id then
    return false
  end
  local excel_id = v[packet.key.item_excelid]
  show(nil, excel_id)
  local text = v[packet.key.ui_text]
  if text ~= nil then
    set_input(w_input, text)
  end
  local note = v[packet.key.chat_text]
  if note ~= nil then
    set_input(w_input_note, note)
  end
end
function on_show_card(cmd, data)
  local tp = data[packet.key.cmn_type]
  if tp == 1 then
    show_recv(data)
  elseif tp == 2 then
    show_reload(data)
  end
end
local reg = ui_packet.game_recv_signal_insert
reg(packet.eSTC_Greeting_Card, on_show_card, "ui_item_card.on_show_card")
