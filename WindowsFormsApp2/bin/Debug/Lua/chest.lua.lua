local n_page_limit = 4
local page_idx = 0
local page_count = 0
local g_sel_item, msg_data
local g_chest_handle = 0
local g_safe_key = false
function on_init()
  local function on_page_step(var)
    page_idx = var.index * n_page_limit
    update_page()
  end
  ui_widget.ui_stepping.set_event(g_step, on_page_step)
  g_sel_item = nil
end
function on_close(btn)
  if g_safe_key == true then
    local function on_msg_callback(msg)
      if msg.result == 1 then
        ui_widget.on_close_click(btn)
        return
      end
    end
    local mtf_text = ui.get_text("npcfunc|still_alert_msg")
    local msg = {
      callback = on_msg_callback,
      text = mtf_text,
      modal = true
    }
    ui_widget.ui_msg_box.show_common(msg)
    return
  end
  ui_widget.on_close_click(btn)
end
function on_visible(w, vis)
  if g_safe_key ~= true then
    ui_widget.on_esc_stk_visible(w, vis)
  end
  if vis then
    page_idx = 0
    if w_money_lb.money == 0 then
      update_page()
    end
    w_main.parent:apply_dock(true)
    local ct = g_onall_btn.abs_area.p1 + g_onall_btn.size / 2
    if bo2.player.auto_chest then
      w_timer.suspended = false
    else
      w_timer.suspended = true
    end
  else
    ui_npcfunc.ui_chest.w_main_mask.visible = false
    ui.item_box_clear(bo2.eItemBox_Chest)
    if w.var:get("server_close_chest").v_int == 1 then
      return
    end
    local d = sys.variant()
    d:set("kind", bo2.eTalkSel_Null)
    d:set("id", 1)
    bo2.send_wrap(packet.eSTC_Fake_talk_sel, d)
  end
end
function on_mask_key()
end
function set_mask_visible()
  ui_npcfunc.ui_chest.w_main_mask.visible = true
  ui_npcfunc.ui_chest.w_main_mask.focus = true
end
function view()
  ui_npcfunc.ui_chest.w_main_mask.visible = false
end
function openwindow(cmd, data)
  local handle = data:get(packet.key.scnobj_handle).v_int
  g_safe_key = false
  local still = bo2.findobj(handle)
  if sys.check(still) and still.kind == bo2.eScnObjKind_Still then
    local excel = still.excel
    if sys.check(excel) then
      local use_id = excel.use_id
      local use_excel = bo2.gv_use_list:find(use_id)
      if sys.check(use_excel) and use_excel.key_item_id.size > 0 and use_excel.src_keep == 0 then
        g_safe_key = true
        local msg = ui.get_text(L("npcfunc|still_alert"))
        ui_tool.note_insert(msg, L("FFFF0000"))
        set_mask_visible()
        ui_item.w_item.visible = true
      end
    end
  end
  w_main.visible = true
  g_title.color = ui.make_color("FFFFFFFF")
  w_main.var:set("notify_bound", 0)
  g_chest_handle = handle
  local mod = data:get(packet.key.group_alloc_mode).v_int
  if mod == packet.key.group_alloc_free then
    local lvl = data:get(packet.key.group_alloc_rolllevel).v_int
    local lvlExcel = bo2.gv_lootlevel:find(lvl)
    local lvlname = ""
    if lvlExcel ~= nil then
      lvlname = lvlExcel.name
      g_title.color = ui.make_color(lvlExcel.color)
    end
    g_title.text = sys.format(ui.get_text("npcfunc|chest_title_free"), lvlname)
    if data:get(packet.key.group_cur_member_count).v_int ~= 1 then
      w_main.var:set("notify_bound", lvl)
    end
  elseif mod == packet.key.group_alloc_roll then
    local lvl = data:get(packet.key.group_alloc_rolllevel).v_int
    local lvlExcel = bo2.gv_lootlevel:find(lvl)
    local lvlname = ""
    if lvlExcel ~= nil then
      lvlname = lvlExcel.name
      g_title.color = ui.make_color(lvlExcel.color)
    end
    g_title.text = sys.format(ui.get_text("npcfunc|chest_title_roll"), lvlname)
  else
    g_title.text = ui.get_text("npcfunc|chest_title")
    if data:get(packet.key.group_cur_member_count).v_int ~= 1 then
      w_main.var:set("notify_bound", 500)
    end
  end
end
function closewindow()
  w_main.var:set("server_close_chest", 1)
  w_main.visible = false
  w_main.var:set("server_close_chest", 0)
  if msg_data ~= nil then
    ui_widget.ui_msg_box.cancel(msg_data)
  end
  if ui_npcfunc.ui_roll.g_msg_data ~= nil then
    ui_widget.ui_msg_box.cancel(ui_npcfunc.ui_roll.g_msg_data)
  end
  if sys.check(ui_team) then
    ui_team.set_assgin_visible(false)
  end
end
function on_item_sel(ctrl)
  if g_sel_item ~= nil then
    g_sel_item:search("select").visible = false
    g_sel_item = nil
  end
  if ctrl ~= nil then
    ctrl:search("select").visible = true
    g_sel_item = ctrl
  end
end
function send_pick(info)
  if info == nil then
    return
  end
  if info.excel ~= nil then
  end
  local function send_impl()
    local d = sys.variant()
    d:set("kind", bo2.eTalkSel_Chest)
    d:set("id", info.grid)
    bo2.send_wrap(packet.eSTC_Fake_talk_sel, d)
    ui_npcfunc.ui_roll.insert_second_confirm_data(g_chest_handle, info.grid, info.excel.id)
  end
  local notify_b = bo2.gv_define:find(373)
  if ui_item.will_bound_item(info, bo2.eItemBoundMod_Acquire) and info.excel.lootlevel >= notify_b.value.v_int and ui_npcfunc.ui_roll.check_may_second_confirm(g_chest_handle, info.grid, info.excel.id) and ui_item.need_show_bound_ui(info.excel_id) then
    local item_name = sys.format("<i:%d>", info.excel_id)
    local arg = sys.variant()
    arg:set("item_name", item_name)
    msg_data = {
      text = sys.mtf_merge(arg, ui.get_text("item|bound_acquire")),
      callback = function(ret)
        if ret.result == 1 then
          send_impl()
        end
      end
    }
    ui_widget.ui_msg_box.show_common(msg_data)
  else
    send_impl()
  end
end
function send_pick_money()
  local send_impl = function()
    local d = sys.variant()
    d:set("kind", bo2.eTalkSel_Chest)
    d:set("id", -1)
    bo2.send_wrap(packet.eSTC_Fake_talk_sel, d)
  end
  send_impl()
end
function on_money_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_enter then
    ctrl:search("select").visible = true
  end
  if msg == ui.mouse_leave then
    ctrl:search("select").visible = false
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_rbutton_click then
    send_pick_money()
  end
end
function on_mouse(ctrl, msg, pos, wheel)
  local card = ctrl:search("card")
  local icon = card.icon
  if icon == nil then
    return
  end
  if msg == ui.mouse_enter then
    on_item_sel(ctrl)
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_rbutton_click then
    send_pick(card.info)
  end
end
function on_all(ctrl)
  page_count = ui.item_box_get_total(bo2.eItemBox_Chest)
  for i = 0, page_count - 1 do
    local info = ui.item_of_sn(bo2.eItemBox_Chest, i)
    send_pick(info)
  end
  send_pick_money()
end
function update_page()
  on_item_sel(nil)
  page_count = ui.item_box_get_total(bo2.eItemBox_Chest)
  if page_count < 1 then
    w_main.visible = false
    return
  end
  local p_idx = math.floor(page_idx / n_page_limit)
  local p_cnt = math.floor((page_count + n_page_limit - 1) / n_page_limit)
  if p_idx >= p_cnt then
    p_idx = p_cnt - 1
    page_idx = p_idx * n_page_limit
  end
  ui_widget.ui_stepping.set_page(g_step, p_idx, p_cnt)
  local arg = sys.variant()
  arg:set("cur_page", p_idx + 1)
  arg:set("total_page", p_cnt)
  local page_text = sys.mtf_merge(arg, ui.get_text("npcfunc|chest_page_num"))
  g_chest_page.text = page_text
  for i = 0, n_page_limit - 1 do
    local cname = sys.format("cell%d", i)
    local cell = w_main:search(cname)
    local card = cell:search("card")
    local info = ui.item_of_sn(bo2.eItemBox_Chest, page_idx + i)
    if info == nil then
      cell.visible = false
    else
      cell.visible = true
      card.only_id = info.only_id
      local excel = info.excel
      if excel ~= nil then
        ui_handson_teach.test_complate_chest(excel.id)
        cell:search("item_name").text = excel.name
        cell:search("item_name").color = ui.make_color(excel.plootlevel.color)
        local plootlevel_star = info.plootlevel_star
        if plootlevel_star ~= nil then
          cell:search("item_name").color = ui.make_color(info.plootlevel_star.color)
        else
          cell:search("item_name").color = ui.make_color(SHARED("FFFFFF"))
        end
        if excel.ptype ~= nil then
          cell:search("item_type").text = excel.ptype.name
        end
      end
    end
  end
end
function chest_update_page(cmd, data)
  local idx = data:get(packet.key.itemdata_idx).v_int
  if data:has(L("add_money")) then
    local p_idx = 1
    local p_cnt = 1
    ui_widget.ui_stepping.set_page(g_step, p_idx, p_cnt)
    local arg = sys.variant()
    arg:set("cur_page", 1)
    arg:set("total_page", 1)
    local page_text = sys.mtf_merge(arg, ui.get_text("npcfunc|chest_page_num"))
    g_chest_page.text = page_text
    show_money(true)
    local money = data:get(packet.key.item_count).v_int
    w_money_lb.money = money
    return
  end
  if data:has(L("del_money")) then
    show_money(false)
    w_main.visible = false
    return
  end
  show_money(false)
  update_page()
end
function show_money(b)
  for i = 0, 3 do
    local name = "cell" .. i
    local c = w_page_panel:search(name)
    c.visible = not b
  end
  local m = w_page_panel:search("cell4")
  m.visible = b
end
function on_card_tip_make(tip)
  local ctrl = tip.owner
  local card = ctrl:search("card")
  local excel = card.excel
  local stk = sys.mtf_stack()
  local stk_use
  if excel ~= nil then
    local ptype = excel.ptype
    if ptype ~= nil then
      local group = ptype.group
      if group == bo2.eItemGroup_Equip or group == bo2.eItemGroup_Avata then
        stk_use = ui_item.tip_get_using_equip(excel)
      end
    end
    ui_tool.ctip_make_item(stk, excel)
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|chest_lclick"), ui_tool.cs_tip_color_operation)
    ui_tool.ctip_push_operation(stk, ui.get_text("npcfunc|chest_rclick"))
    ui_tool.ctip_show(ctrl, stk, stk_use)
  end
end
function on_timer(timer)
  if not w_main.visible then
    return
  end
  local page_count = ui.item_box_get_total(bo2.eItemBox_Chest)
  for i = 0, page_count - 1 do
    local info = ui.item_of_sn(bo2.eItemBox_Chest, i)
    send_pick(info)
  end
  timer.suspended = true
end
function on_clearpickflag(timer)
  if sys.check(bo2.player) then
  end
end
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_npcfunc.ui_chest:on_signal"
reg(packet.eSTC_UI_OpenChest, openwindow, sig)
reg(packet.eSTC_UI_CloseChest, closewindow, sig)
reg(packet.eSTC_Fake_update_chest, chest_update_page, sig)
function AckRollInvite(click, data)
  local function send_impl()
    local v = sys.variant()
    v:set(packet.key.cmn_index, data:get(packet.key.cmn_index))
    v:set(packet.key.scnobj_handle, data:get(packet.key.scnobj_handle))
    v:set(packet.key.item_excelid, data:get(packet.key.item_excelid))
    v:set(packet.key.item_count, data:get(packet.key.item_count))
    if click == "yes" then
      v:set(packet.key.cmn_agree_ack, 1)
    end
    bo2.send_variant(packet.eCTS_UI_RollItem, v)
  end
  local excel_id = data:get(packet.key.item_excelid).v_int
  local excel = ui.item_get_excel(excel_id)
  if click == "yes" and excel ~= nil and excel.bound_mode == bo2.eItemBoundMod_Acquire and ui_item.need_show_bound_ui(excel_id) then
    local item_name = sys.format("<i:%d>", excel_id)
    local arg = sys.variant()
    arg:set("item_name", item_name)
    ui_widget.ui_msg_box.show_common({
      text = sys.mtf_merge(arg, ui.get_text("item|bound_acquire")),
      callback = function(ret)
        if ret.result ~= 1 then
          click = "no"
        end
        send_impl()
      end
    })
  else
    send_impl()
  end
end
function get_visible()
  return w_main.visible
end
