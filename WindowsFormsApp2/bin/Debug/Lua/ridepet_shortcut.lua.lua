local reg = ui_packet.game_recv_signal_insert
local sig = "ui_ridepet_shortcut.packet_handle"
local shortcut_idx_begin = 1000
local cur_shortcut_count = 0
local max_shortcut_count = 6
local active_ridepet = false
function on_init()
  cur_shortcut_count = 0
  active_ridepet = false
end
function handle_open_window(cmd, data)
  local win_type = data:get(packet.key.ui_window_type).v_int
  if win_type ~= packet.key.ui_wintype_ridepet_skill then
    return
  end
  if cur_shortcut_count < max_shortcut_count then
    local skill_id = data:get(packet.key.ui_ridepet_skill_id).v_int
    if skill_id == 0 and ui.skill_find(skill_id) ~= nil then
      return
    end
    ui.skill_insert(skill_id, 1, 3)
    ui.shortcut_set(shortcut_idx_begin + cur_shortcut_count, bo2.eShortcut_Skill, skill_id)
    cur_shortcut_count = cur_shortcut_count + 1
  end
end
function init_ridepet_shortcut()
  for i = shortcut_idx_begin, shortcut_idx_begin + max_shortcut_count do
    local info = ui.shortcut_get(i)
    if info ~= nil and info.kind == bo2.eShortcut_Skill and info.excel ~= nil then
      ui.shortcut_set(i, bo2.eShortcut_None, 0)
      ui.skill_remove(skill_id, 3)
    end
  end
  cur_shortcut_count = 0
end
function handle_close_window(cmd, data)
  local win_type = data:get(packet.key.ui_window_type).v_int
  if win_type ~= packet.key.ui_wintype_ridepet_skill then
    return
  end
  if data:has(packet.key.ridepet_atb_speed) then
    init_ridepet_shortcut()
    return
  end
  local skill_id = data:get(packet.key.ui_ridepet_skill_id).v_int
  local index
  for i = shortcut_idx_begin, shortcut_idx_begin + max_shortcut_count do
    local info = ui.shortcut_get(i)
    if info ~= nil and info.kind == bo2.eShortcut_Skill and info.excel ~= nil and info.excel.id == skill_id then
      ui.shortcut_set(i, bo2.eShortcut_None, 0)
      ui.skill_remove(skill_id, 3)
      cur_shortcut_count = cur_shortcut_count - 1
      index = i - shortcut_idx_begin
      break
    end
  end
  if index == nil then
    return
  end
  for i = shortcut_idx_begin + index, shortcut_idx_begin + max_shortcut_count do
    local info = ui.shortcut_get(i + 1)
    if info ~= nil and info.kind == bo2.eShortcut_Skill and info.excel ~= nil then
      ui.shortcut_set(i, bo2.eShortcut_Skill, info.excel.id)
      ui.shortcut_set(i + 1, bo2.eShortcut_None, 0)
    end
  end
end
function on_card_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    if ui.is_key_down(ui.VK_CONTROL) then
      local info = ui.shortcut_get(card.index)
      if info == nil then
        return
      end
      local excel = info.excel
      if excel == nil then
        return
      end
      if info.kind == bo2.eShortcut_Skill then
        local skill_info = ui.skill_find(excel.id)
        if skill_info == nil then
          return
        end
        ui_chat.insert_skill(skill_info.excel_id, skill_info.level, skill_info.type)
        return
      end
    end
    ui_shortcut.shortcut_use(card.index)
  elseif msg == ui.mouse_rbutton_down then
    ui_shortcut.shortcut_use(card.index)
  elseif msg == ui.mouse_rbutton_up then
    ui_shortcut.shortcut_up(card.index)
  end
end
function active()
  active_ridepet = true
  w_ridepet_shortcut.visible = true
  ui_shortcut.w_shortcut.visible = false
  ui_shortcut.hotkey_update()
  if bo2.player == nil then
  else
    local pRide = bo2.player:get_ridepet()
    if pRide == nil then
    else
      ridepet_pos = pRide:get_flag_int32(bo2.eRidePetFlagInt32_Pos)
      local info = ui_ridepet.find_info_from_pos(ridepet_pos)
      if info == nil then
      else
        local excel_id = info:get_flag(bo2.eRidePetFlagInt32_RidePetListId)
        local ridepet_list_excel = bo2.gv_ridepet_list:find(excel_id)
        if ridepet_list_excel == nil then
        else
          local image = "$icon/item/" .. ridepet_list_excel.strIcon .. ".png"
          ui_portrait.w_ridepet_portrait.image = image
          ui_portrait.w_ridepet_portrait.visible = true
          ui_portrait.w_portrait.visible = false
        end
      end
    end
  end
end
function deactive()
  active_ridepet = false
  w_ridepet_shortcut.visible = false
  ui_shortcut.w_shortcut.visible = true
  ui_shortcut.hotkey_update()
  ui_portrait.w_ridepet_portrait.image = ""
  ui_portrait.w_ridepet_portrait.visible = false
  ui_portrait.w_portrait.visible = true
end
function is_active()
  return active_ridepet
end
function on_click_ridepet_down()
  if bo2.player == nil then
    return
  end
  bo2.player:leaveBus()
end
reg(packet.eSTC_UI_OpenWindow, handle_open_window, sig)
reg(packet.eSTC_UI_CloseWindow, handle_close_window, sig)
