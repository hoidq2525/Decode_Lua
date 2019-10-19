local reg = ui_packet.game_recv_signal_insert
local sig = "ui_qbar.packet_handle"
local shortcut_idx_begin = 1050
local shortcut_idx_end = 1059
local cur_shortcut_idx = 1050
local cur_shortcut_count = 0
local max_shortcut_count = 10
local use_hotkey = 0
function on_init()
  cur_shortcut_idx = 1050
  cur_shortcut_count = 0
end
function exist_item(item_excel, item_type)
  if cur_shortcut_count == 0 then
    return false
  end
  for i = shortcut_idx_begin, cur_shortcut_idx do
    local info = ui.shortcut_get(i)
    if info ~= nil and info.kind == item_type and info.excel ~= nil and info.excel.id == item_excel then
      return true
    end
  end
  return false
end
function on_playerout(obj)
  if obj == bo2.player then
    for i = shortcut_idx_begin, shortcut_idx_end do
      local info = ui.shortcut_get(i)
      if info ~= nil and info.excel ~= nil then
        ui.skill_remove(info.excel.id, 3)
      end
      ui.shortcut_set(i, bo2.eShortcut_None, 0)
    end
    cur_shortcut_idx = shortcut_idx_begin
    cur_shortcut_count = 0
    use_hotkey = 0
    gx_win.visible = false
    ui_shortcut.hotkey_update()
  end
end
function on_win_visible(panel, vis)
  if vis == false then
    bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_leave_scn, sig)
  else
    bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_leave_scn, on_playerout, sig)
  end
end
function On_shortcut_hotkey_updata(id)
  if not sys.check(gx_win) then
    return
  end
  if gx_win.visible and id >= 0 and id <= 9 then
    local name = "" .. id
    local ctr = gx_win:search(name)
    local h = ctr:search("hotkey")
    local info = ui.shortcut_get(id + 1050)
    if info ~= nil and info.excel ~= nil and use_hotkey > 0 then
      local op = ui_setting.ui_input.op_ids[3000 + id]
      if op ~= nil then
        local hk = op.hotkey
        local txt = hk:get_cell(0).simple_text
        if txt.empty then
          txt = hk:get_cell(1).simple_text
        end
        h.text = txt
        return true
      end
    end
    h.text = ""
  end
  return false
end
function is_active()
  return gx_win.visible and use_hotkey > 0
end
function update_shortcut()
  cur_shortcut_count = 0
  cur_shortcut_idx = shortcut_idx_begin
  for i = shortcut_idx_begin, shortcut_idx_end do
    local info = ui.shortcut_get(i)
    if info ~= nil and info.excel ~= nil then
      cur_shortcut_idx = shortcut_idx_begin + cur_shortcut_count
      if i ~= cur_shortcut_idx then
        ui.shortcut_set(cur_shortcut_idx, info.kind, info.excel.id)
        ui.shortcut_set(i, bo2.eShortcut_None, 0)
      end
      cur_shortcut_count = cur_shortcut_count + 1
    else
      ui.shortcut_set(i, bo2.eShortcut_None, 0)
    end
  end
  if cur_shortcut_count == 0 then
    gx_win.visible = false
    ui_shortcut.hotkey_update()
    return
  end
  cur_shortcut_idx = cur_shortcut_idx + 1
  gx_win:search("fader_slot").dx = 39 * cur_shortcut_count
  gx_win.visible = true
  ui_shortcut.hotkey_update()
end
function handle_open_window(cmd, data)
  local win_type = data:get(packet.key.ui_window_type).v_int
  if win_type ~= packet.key.ui_wintype_temp_bar then
    return
  end
  local hot_key = data:get(packet.key.ui_temp_skill_data).v_int
  if hot_key ~= 0 then
    use_hotkey = use_hotkey + 1
  end
  if cur_shortcut_idx <= shortcut_idx_end then
    local item_excel = data:get(packet.key.ui_temp_skill_id).v_int
    local item_type = bo2.eShortcut_Skill
    if item_type == bo2.eShortcut_Skill then
      ui.skill_insert(item_excel, 1, 3)
      ui_handson_teach.on_add_sysshortcut(item_excel)
    end
    ui.shortcut_set(cur_shortcut_idx, item_type, item_excel)
    cur_shortcut_idx = cur_shortcut_idx + 1
    cur_shortcut_count = cur_shortcut_count + 1
  end
  if cur_shortcut_count ~= 0 then
    gx_win:search("fader_slot").dx = 39 * cur_shortcut_count
    gx_win.visible = true
    ui_shortcut.hotkey_update()
  end
end
function handle_close_window(cmd, data)
  local win_type = data:get(packet.key.ui_window_type).v_int
  if win_type ~= packet.key.ui_wintype_temp_bar then
    return
  end
  local items = data:get(packet.key.cmn_dataobj)
  local hot_key = data:get(packet.key.ui_temp_skill_data).v_int
  if hot_key ~= 0 then
    use_hotkey = use_hotkey - 1
  end
  local item_excel = data:get(packet.key.ui_temp_skill_id).v_int
  local item_type = bo2.eShortcut_Skill
  for i = shortcut_idx_begin, cur_shortcut_idx do
    local info = ui.shortcut_get(i)
    if info ~= nil and info.kind == item_type and info.excel ~= nil and info.excel.id == item_excel then
      ui.shortcut_set(i, bo2.eShortcut_None, 0)
      if item_type == bo2.eShortcut_Skill and not exist_item(item_excel, item_type) then
        ui.skill_remove(item_excel, 3)
      end
      break
    end
  end
  update_shortcut()
end
reg(packet.eSTC_UI_OpenWindow, handle_open_window, sig)
reg(packet.eSTC_UI_CloseWindow, handle_close_window, sig)
