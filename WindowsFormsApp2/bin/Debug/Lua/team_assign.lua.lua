g_time = 20
g_total_time = g_time * 1000
g_assign_tab = {}
g_msg_data = nil
g_second_confirm_list = {}
g_vis_roll = false
g_roll_index = 1
function run()
  w_main_assign.visible = true
  update_show()
end
function set_assgin_visible(vis)
  w_main_assign.visible = vis
end
function on_mouse_item_select(w, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    if sys.check(w) ~= true then
      return
    end
    local btn = w:search("btn_watch")
    btn.check = true
  end
end
function get_assign_list_view(index)
  if index == 0 then
    return w_group_assign_0
  elseif index == 1 then
    return w_group_assign_1
  elseif index == 2 then
    return w_group_assign_2
  elseif index == 3 then
    return w_group_assign_3
  end
  return nil
end
function on_update_member_item(_count)
  local obj = bo2.player
  local self_only_id = 0
  if sys.check(obj) then
    self_only_id = obj.only_id
  end
  for i = 0, _count do
    local base_item
    if _count == 4 then
      base_item = w_group_assign:item_get(i)
    else
      base_item = get_assign_list_view(get_member_index(i))
      if sys.check(base_item) then
        base_item = base_item:item_get(i % 5)
      end
    end
    if sys.check(base_item) then
      local t = base_item:search("top_panel")
      t.visible = false
    end
  end
  local function on_update_data(member_info, item)
    if sys.check(member_info) ~= true then
      return
    end
    local only_id = member_info.only_id
    local v = g_assign_tab.group_tab
    if only_id == sys.wstring(0) or v == nil then
      item.visible = false
      return
    else
      item.visible = true
    end
    local name = item:search("name")
    name.text = member_info.name
    local career = item:search("career")
    local career_idx = ui_portrait.get_career_idx(member_info.career)
    set_career_icon(career, career_idx)
    local level = item:search("level")
    level.text = sys.format("Lv%d", member_info.level)
    local btn_watch = item:search("btn_watch")
    if only_id == self_only_id then
      btn_watch.check = true
    else
      btn_watch.check = false
    end
    item.var:set(packet.key.scn_onlyid, only_id)
  end
  for i = 0, _count do
    local info = ui.member_get_by_idx(i)
    local base_item
    if _count == 4 then
      base_item = w_group_assign:item_get(i)
    else
      base_item = get_assign_list_view(get_member_index(i))
      if sys.check(base_item) then
        base_item = base_item:item_get(i % 5)
      end
    end
    if sys.check(base_item) then
      local item = base_item:search("top_panel")
      if info ~= nil then
        on_update_data(info, item)
      end
    end
  end
end
function on_set_raid_window()
  ui_team.w_main_assign.dx = 660
  ui_team.w_main_assign.dy = 530
  w_confirm.dy = 30
  w_confirm.margin = ui.rect(0, 15, 0, 0)
  ui_team.w_team_assign.visible = false
  ui_team.w_raid_assign.visible = true
  on_update_member_item(19)
end
function on_set_common_window()
  ui_team.w_main_assign.dx = 340
  ui_team.w_main_assign.dy = 350
  w_confirm.dy = 50
  ui_team.w_team_assign.visible = true
  ui_team.w_raid_assign.visible = false
  on_update_member_item(4)
end
function on_update_assign_item()
  local mtf_data = {}
  local item_excelid = g_assign_tab.id
  local count = g_assign_tab.count
  if g_assign_tab.item_name then
    mtf_data.item = g_assign_tab.item_name
  elseif count > 1 then
    mtf_data.item = sys.format(L("<i:%d> x %d"), item_excelid, count)
  else
    mtf_data.item = sys.format(L("<i:%d> x %d"), item_excelid, count)
  end
  rb_assign_item.mtf = ui_widget.merge_mtf(mtf_data, ui.get_text("team|assign_item"))
end
function update_show()
  if g_assign_tab == nil or g_assign_tab.enable == nil then
    set_assgin_visible(false)
    return
  end
  set_assgin_visible(true)
  on_update_assign_item()
  if bo2.is_team(bo2.player) == true then
    on_set_raid_window()
  else
    on_set_common_window()
  end
end
function send_assign(t, member_info)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 1)
  v:set(packet.key.cmn_index, t.cmnindex)
  v:set(packet.key.scnobj_handle, t.handle)
  v:set(packet.key.item_excelid, t.id)
  v:set(packet.key.item_count, t.count)
  v:set(packet.key.cmn_agree_ack, 0)
  v:set(packet.key.scn_onlyid, member_info.only_id)
  bo2.send_variant(packet.eCTS_UI_RollItem, v)
  g_assign_tab = {}
  update_show()
end
function on_visible_team_assign(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
end
function on_close_click(btn)
end
function runf()
  local v = sys.variant()
  v:set(packet.key.item_excelid, 58422)
  v:set(packet.key.item_count, 1)
  v:set(packet.key.scnobj_handle, 1)
  v:set(packet.key.cmn_index, 1)
  local v0 = sys.variant()
  for i = 0, 4 do
    local info = ui.member_get_by_idx(i)
    if info.only_id ~= sys.wstring(0) then
      v0:set(info.only_id, 1)
    end
  end
  v:set(packet.key.cmn_dataobj, v0)
  on_assign(0, v)
end
function on_assign(cmd, data)
  local function on_process()
    local _id = data:get(packet.key.item_excelid).v_int
    local excel = ui.item_get_excel(_id)
    if excel == nil then
      return
    end
    g_assign_tab = {
      id = _id,
      count = data:get(packet.key.item_count).v_int,
      handle = data:get(packet.key.scnobj_handle).v_int,
      cmnindex = data:get(packet.key.cmn_index).v_int,
      iTime = g_total_time,
      scn_onlyid = data:get(packet.key.scn_onlyid),
      enable = true,
      group_data = data:get(packet.key.cmn_dataobj),
      group_tab = {}
    }
    g_assign_tab.group_count = g_assign_tab.group_data.size
    for i = 0, g_assign_tab.group_count - 1 do
      local data = g_assign_tab.group_data:fetch_nv(i)
      g_assign_tab.group_tab[data.v_string] = 1
    end
    update_show()
  end
  bo2.AddTimeEvent(1, on_process)
end
function on_click_confirm_assign()
  if g_assign_tab == nil then
    return
  end
  local member_info
  local on_find_member_info = function(_count)
    local only_id = 0
    for i = 0, _count do
      local base_item
      if _count == 4 then
        base_item = w_group_assign:item_get(i)
      else
        base_item = get_assign_list_view(get_member_index(i))
        if sys.check(base_item) then
          base_item = base_item:item_get(i % 5)
        end
      end
      local t = base_item:search("top_panel")
      if t.visible == true then
        local btn = t:search("btn_watch")
        if btn.check == true then
          only_id = t.var:get(packet.key.scn_onlyid).v_string
          break
        end
      end
    end
    if only_id == 0 then
      return nil
    end
    for i = 0, _count do
      local info = ui.member_get_by_idx(i)
      if info.only_id == only_id then
        return info
      end
    end
    return nil
  end
  if bo2.is_team(bo2.player) == true then
    member_info = on_find_member_info(19)
  else
    member_info = on_find_member_info(4)
  end
  if member_info == nil then
    ui_tool.note_insert(ui.get_text("team|assign_faild"), "FFFF0000")
    g_assign_tab = {}
    update_show()
    return
  end
  local on_msg_callback = function(msg)
    if msg.result ~= 1 then
      return
    end
    send_assign(g_assign_tab, msg.info)
  end
  local mtf_data = {}
  local item_excelid = g_assign_tab.id
  local count = g_assign_tab.count
  if g_assign_tab.item_name then
    mtf_data.item = g_assign_tab.item_name
  elseif count > 1 then
    mtf_data.item = sys.format(L("<i:%d> x %d"), item_excelid, count)
  else
    mtf_data.item = sys.format(L("<i:%d> x %d"), item_excelid, count)
  end
  mtf_data.level = member_info.level
  local pro_list = bo2.gv_profession_list:find(member_info.career)
  if pro_list ~= nil then
    local damage = ui.get_text(sys.format("portrait|damage_type_%d", pro_list.damage))
    mtf_data.career = sys.format("%s(%s)", pro_list.name, damage)
  end
  mtf_data.cha_name = member_info.name
  local msg = {
    callback = on_msg_callback,
    text = ui_widget.merge_mtf(mtf_data, ui.get_text("team|assign_2nd_confirm")),
    info = member_info
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_self_enter()
  g_second_confirm_list = {}
  g_assign_tab = {}
end
local sig_name = "ui_team.on_assign"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_ChestCaptainAssign, on_assign, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_team.on_self_enter")
