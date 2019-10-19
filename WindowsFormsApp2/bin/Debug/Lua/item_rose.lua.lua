local check_opt = {
  1,
  9,
  19,
  99,
  199,
  999
}
local function init()
  if sys.check(rawget(_M, "w_core")) then
    return
  end
  w_top:load_style("$frame/item/item_rose.xml", "main")
  w_top:apply_dock(true)
  local chk_txt = ui.get_text("item_rose|count")
  for i, v in ipairs(check_opt) do
    local chk = _M["w_check_count_" .. i]
    chk.tip.text = ui.get_text("item_rose|count_tip_" .. v)
    chk:search("btn_lb_text").text = ui_widget.merge_mtf({n = v}, chk_txt)
  end
  local svar = w_top.svar
  if not sys.check(rawget(_M, "w_top_note")) then
    w_top_note = ui.create_control(ui_main.w_top, "panel")
    w_top_note:load_style("$frame/item/item_rose.xml", "note")
    w_top_note.visible = false
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
function on_opt_tip(tip)
  ui_widget.tip_make_view(tip.view, tip.text)
end
function on_opt_check(btn, chk)
  if not chk then
    return
  end
  if btn == w_check_count_6 then
    local x1 = w_top.x
    local x2 = x1 + w_top.dx
    local sx = ui_main.w_top.dx
    local dx = w_top_note.dx
    local x
    if x1 > sx - x2 then
      x = x1 - dx
    else
      x = x2
    end
    w_top_note.offset = ui.point(x, w_top.y)
    w_top_note.visible = true
    info_make(w_note_desc)
  else
    w_top_note.visible = false
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
function on_visible(ctrl, vis)
  if not vis then
    w_top_note.visible = false
    return
  end
  init()
end
function on_input_focus(ctrl, focus)
  local lb = ctrl:search("lb_input_desc")
  if focus then
    lb.visible = false
  else
    lb.visible = ctrl.item_count == 0
  end
end
function on_rank_click(btn)
  ui_ranklist.g_rank_list.visible = true
  local ft = ui_ranklist.g_first_tab.next
  ft:click()
  ft.press = true
  local rank_id = btn.topper.svar.rank_id
  local btn_panel = ui_ranklist.g_ranklist_border:search("btns_panel")
  local ctrl = btn_panel:search("rank_list").control_head
  while ctrl ~= nil do
    if ctrl.var.v_int == rank_id then
      ctrl:click()
      ctrl.press = true
      break
    end
    ctrl = ctrl.next
  end
end
function on_back_confirm_click(btn)
  w_top_back.visible = false
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
local t_scns = {
  101,
  102,
  103
}
local function is_main_scn(id)
  for i, v in ipairs(t_scns) do
    if v == id then
      return true
    end
  end
  return false
end
function check_give(svar)
  local scn = bo2.scn
  local scn_id = scn.excel.id
  if not is_main_scn(scn_id) then
    local stk = sys.mtf_stack()
    stk:push(ui.get_text("item_rose|send_limit_scn"))
    for i, v in pairs(t_scns) do
      local x = bo2.gv_scn_list:find(v)
      if x ~= nil then
        stk:format("[%s]", x.name)
      end
    end
    ui_tool.note_insert_error(stk.text)
    return false
  end
  local player = bo2.player
  local target_handle
  if svar ~= nil then
    target_handle = svar.target_handle
  else
    target_handle = player.target_handle
  end
  local target = bo2.findobj(target_handle)
  if target == nil or target.kind ~= bo2.eScnObjKind_Player or target == player or svar ~= nil and svar.target_only_id ~= target.only_id then
    ui_tool.note_insert_error(ui.get_text("item_rose|send_limit_target"))
    return false
  end
  if target:get_flag_objmem(bo2.eFlagObjMemory_FightState) > 0 then
    ui_tool.note_insert_error(ui.get_text("item_rose|send_limit_fight"))
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
function init_give()
  local player = bo2.player
  local target = bo2.findobj(player.target_handle)
  w_send_info.mtf = L("<a:m>") .. ui_widget.merge_mtf({
    u = sys.format("<u:%s>", target.name)
  }, ui.get_text("item_rose|send_info_target_name"))
  w_send_info:update()
  w_send_info.dy = w_send_info.extent.y
  local svar = w_top.svar
  svar.target_handle = target.sel_handle
  svar.target_only_id = target.only_id
  svar.target_name = target.name
end
function show(info, excel_id)
  if not check_give() then
    return
  end
  w_top.visible = true
  w_top:move_to_head()
  clear_input(w_input)
  clear_input(w_input_note)
  w_top_note.visible = false
  for i, v in ipairs(check_opt) do
    local chk = _M["w_check_count_" .. i]
    chk.check = false
  end
  local svar = w_top.svar
  if info ~= nil then
    svar.excel_id = info.excel_id
  else
    svar.excel_id = excel_id
  end
  init_give()
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
  local count = v[packet.key.item_count]
  for i, v in ipairs(check_opt) do
    local chk = _M["w_check_count_" .. i]
    if count == v then
      chk.check = true
      break
    end
  end
end
function on_give_click(btn)
  local svar = w_top.svar
  if not check_give(svar) then
    return
  end
  local count = 0
  for i, v in ipairs(check_opt) do
    local chk = _M["w_check_count_" .. i]
    if chk.check then
      count = v
      break
    end
  end
  if count == 0 then
    ui_tool.note_insert_error(ui.get_text("item_rose|send_limit_set_count"))
    return
  end
  local item_info = ui.item_of_excel_id(svar.excel_id)
  if item_info == nil or count > item_info.count then
    local goods_id = ui_supermarket2.shelf_quick_buy_id(svar.excel_id)
    if goods_id > 0 then
      if item_info ~= nil then
        count = count - item_info.count
      end
      w_btn_give.svar.count = count
      ui_widget.ui_msg_box.show_common({
        text = ui_widget.merge_mtf({
          item = sys.format("<i:%d>", svar.excel_id)
        }, ui.get_text("item_rose|send_limit_buy")),
        callback = function(msg)
          if msg.result == 1 then
            ui_supermarket2.shelf_quick_buy(w_btn_give, svar.excel_id)
          end
        end
      })
    else
      ui_tool.note_insert_error(ui_widget.merge_mtf({
        item = sys.format("<i:%d>", svar.excel_id)
      }, ui.get_text("item_rose|send_limit_more")))
    end
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
  if 0 < text.size then
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
  if count >= 999 then
    text = w_input_note.text
    if 0 < text.size then
      v[packet.key.chat_text] = text
      stk:raw_push([[


<c:FF9A9A>]])
      stk:raw_push(ui.get_text("item_rose|send_broadcast_msg"))
      stk:push(text)
    else
      stk:raw_push([[


<c:FF0000>]])
      stk:raw_push(ui.get_text("item_rose|send_broadcast_no"))
    end
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
function mtf_rank(box, data, mtf)
  local w = data.widget
  if not w:load_style("$frame/item/item_rose.xml", "rank") then
    return false
  end
  return true
end
local make_list = function()
  local name = bo2.player.name
  if name == rawget(_M, "g_self_name") then
    return
  end
  g_self_name = name
  g_recv_list = {}
  g_send_list = {}
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
  }, ui.get_text("item_rose|recv_sender"))
  stk:push("\n")
  stk:merge({
    n = data[packet.key.item_count]
  }, ui.get_text("item_rose|recv_this_count"))
  stk:push("\n")
  stk:merge({
    n = player:get_flag_int32(bo2.ePlayerFlagInt32_RoseRecv)
  }, ui.get_text("item_rose|recv_desc"))
  svar.info_text = stk.text
  local rank = ui_ranklist.g_my_rank_info[bo2.eRankIndex_shouhua]
  if rank ~= nil then
    rank = rank.rank
    stk:push("\n")
    stk:merge({n = rank}, ui.get_text("item_rose|recv_rank"))
    stk:raw_push("<space:0.2><ext:ui_item_rose.mtf_rank,,>")
  else
    stk:push("\n")
    stk:push(ui.get_text("item_rose|recv_rank_no"))
  end
  svar.rank = rank
  svar.rank_id = bo2.eRankIndex_shouhua
  svar.sender_name = sender_name
  svar.excel_id = data[packet.key.item_excelid]
  stk:push("\n")
  stk:merge({
    n = player:get_flag_int32(bo2.ePlayerFlagInt32_RoseRecvTotal)
  }, ui.get_text("item_rose|recv_total"))
  local title = data[packet.key.ui_title]
  if title ~= nil then
    stk:push("\n")
    stk:merge({
      t = sys.format("<table_idx_info:title_list,%d,_name>", title)
    }, ui.get_text("item_rose|recv_player_title"))
  else
    stk:push("\n")
    stk:push(ui.get_text("item_rose|recv_player_title_no"))
  end
  info_make(svar.rb_recv_info, stk.text)
end
function on_recv_timer(t)
  local rank = ui_ranklist.g_my_rank_info[bo2.eRankIndex_shouhua]
  if rank == nil then
    return
  end
  rank = rank.rank
  local top = t.owner
  local svar = top.svar
  if svar.rank == rank then
    return
  end
  svar.rank = rank
  update_recv(top)
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
function show_recv(data)
  local top = ui.create_control(ui_main.w_top, "panel")
  top:load_style("$frame/item/item_rose.xml", "recv")
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
  local count = data[packet.key.item_count]
  make_list()
  table.insert(g_recv_list, 1, {
    name = data[packet.key.cha_name],
    count = count
  })
  local note = data[packet.key.ui_text]
  if note == nil then
    note = ui_widget.merge_mtf({n = count}, ui.get_text("item_rose|recv_chat_def"))
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
local function update_back()
  local svar = w_top_back.svar
  local data = svar.msg_data
  local player = bo2.player
  local stk = sys.mtf_stack()
  stk:merge({
    u = sys.format("<u:%s>", data[packet.key.cha_name])
  }, ui.get_text("item_rose|back_target"))
  stk:push("\n")
  stk:merge({
    n = data[packet.key.item_count]
  }, ui.get_text("item_rose|back_this_count"))
  stk:push("\n")
  stk:merge({
    n = player:get_flag_int32(bo2.ePlayerFlagInt32_RoseSend)
  }, ui.get_text("item_rose|send_desc"))
  local rank = ui_ranklist.g_my_rank_info[bo2.eRankIndex_songhua]
  if rank ~= nil then
    rank = rank.rank
    stk:push("\n")
    stk:merge({n = rank}, ui.get_text("item_rose|send_rank"))
    stk:raw_push("<space:0.2><ext:ui_item_rose.mtf_rank,,>")
  else
    stk:push("\n")
    stk:push(ui.get_text("item_rose|send_rank_no"))
  end
  svar.rank = rank
  svar.rank_id = bo2.eRankIndex_songhua
  stk:push("\n")
  stk:merge({
    n = player:get_flag_int32(bo2.ePlayerFlagInt32_RoseSendTotal)
  }, ui.get_text("item_rose|send_total"))
  local title = data[packet.key.ui_title]
  if title ~= nil then
    stk:push("\n")
    stk:merge({
      t = sys.format("<table_idx_info:title_list,%d,_name>", title)
    }, ui.get_text("item_rose|send_player_title"))
  else
    stk:push("\n")
    stk:push(ui.get_text("item_rose|send_player_title_no"))
  end
  info_make(w_back_info, stk.text)
end
function on_back_timer(t)
  local rank = ui_ranklist.g_my_rank_info[bo2.eRankIndex_songhua]
  if rank == nil then
    return
  end
  rank = rank.rank
  local svar = w_top_back.svar
  if svar.rank == rank then
    return
  end
  svar.rank = rank
  update_back()
end
function show_back(data)
  if not sys.check(rawget(_M, "w_top_back")) then
    w_top_back = ui.create_control(ui_main.w_top, "panel")
    w_top_back:load_style("$frame/item/item_rose.xml", "back")
    w_top_back:apply_dock(true)
  end
  w_top_back.visible = true
  w_top_back:move_to_head()
  w_input_back:update()
  w_input_back.dy = w_input_back.extent.y
  local count = data[packet.key.item_count]
  make_list()
  table.insert(g_send_list, 1, {
    name = data[packet.key.cha_name],
    count = count
  })
  local svar = w_top_back.svar
  svar.msg_data = data
  update_back()
end
local more_fill = function(name, list)
  local item = ui.get_text("item_rose|rose_item")
  local stk = sys.mtf_stack()
  for i, d in ipairs(list) do
    if i > 1 then
      stk:push("\n")
    end
    stk:merge({
      u = sys.format("<u:%s>", d.name),
      n = d.count
    }, item)
  end
  w_top_more:search(name).mtf = stk.text
end
function on_more_list_click(btn)
  if not sys.check(rawget(_M, "w_top_more")) then
    w_top_more = ui.create_control(ui_main.w_top, "panel")
    w_top_more:load_style("$frame/item/item_rose.xml", "more_list")
    w_top_more:apply_dock(true)
  end
  w_top_more.visible = true
  w_top_more:move_to_head()
  btn.topper.visible = false
  more_fill("rb_send_list", g_send_list)
  more_fill("rb_recv_list", g_recv_list)
end
function mtf_more_list(box, data, mtf)
  local w = data.widget
  if not w:load_style("$frame/item/item_rose.xml", "open_more_list") then
    return false
  end
  local init, reset, arg = data.value:split(",", 3)
  local p = w:search("lb_text")
  p.color = mtf.color
  p.font = mtf.format.font
  p.text = arg
  data.edge_size = p.font.edge_size
  w.size = p.extent
  return true
end
function mtf_more_list_send(box, data, mtf)
  if not mtf_more_list(box, data, mtf) then
    return false
  end
  local w = data.widget
  w.svar.is_send = true
  return true
end
function mtf_more_list_recv(box, data, mtf)
  if not mtf_more_list(box, data, mtf) then
    return false
  end
  local w = data.widget
  w.svar.is_send = false
  return true
end
function make_list_tip(stk)
  local s = rawget(_M, "g_send_list")
  local r = rawget(_M, "g_recv_list")
  if s == nil or r == nil then
    return
  end
  ui_tool.ctip_push_sep(stk)
  local cs = #s
  local cr = #r
  local max = 4
  local more = false
  local item = ui.get_text("item_rose|rose_item")
  if cs > 0 then
    stk:push(ui.get_text("item_rose|send_more_list"))
    if cs > max then
      cs = max
      more = true
    end
    for i = 1, cs do
      local d = g_send_list[i]
      stk:push("\n")
      stk:merge({
        u = sys.format("<u:%s>", d.name),
        n = d.count
      }, item)
    end
  end
  if cr > 0 then
    if cs > 0 then
      stk:push("\n")
    end
    stk:push(ui.get_text("item_rose|recv_more_list"))
    if cr > max then
      cr = max
      more = true
    end
    for i = 1, cr do
      local d = g_recv_list[i]
      stk:push("\n")
      stk:merge({
        u = sys.format("<u:%s>", d.name),
        n = d.count
      }, item)
    end
  end
  if more then
    stk:raw_format([[

<ext:ui_item_rose.mtf_more_list,,]])
    stk:push(ui.get_text("item_rose|click_show_more"))
    stk:raw_push(">")
  end
end
function on_rose(cmd, data)
  local tp = data[packet.key.cmn_type]
  if tp == 0 then
    show_back(data)
  elseif tp == 1 then
    show_recv(data)
  elseif tp == 2 then
    show_reload(data)
  end
end
function test_recv()
  local v = sys.variant()
  v[packet.key.item_excelid] = 57992
  v[packet.key.cha_name] = "sender_name"
  v[packet.key.item_count] = 999
  v[packet.key.cmn_rank] = 18
  show_recv(v)
end
function test_back()
  local v = sys.variant()
  v[packet.key.item_excelid] = 57992
  v[packet.key.cha_name] = "recver_name"
  v[packet.key.item_count] = 999
  v[packet.key.cmn_rank] = 18
  show_back(v)
end
function test_anim()
  local pn = w_top:search("luohua_panel")
  local p = pn.control_head
  while p ~= nil do
    p:reload()
    p = p.next
  end
end
local reg = ui_packet.game_recv_signal_insert
reg(packet.eSTC_UI_ItemRose, on_rose, "ui_item_rose.on_rose")
