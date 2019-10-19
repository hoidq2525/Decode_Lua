local idx_begin = 58
local idx_count = 4
local temp_list
local g_sys_hook = false
local g_hook_item_tab = {}
g_hook_item_tab[45118] = 1
local function IsAreadyInList(_kind, v_id)
  if temp_list == nil then
    return false
  end
  local first = temp_list.first
  local last = temp_list.last
  if first > last then
    return false
  end
  for i = first, last do
    if temp_list[i].kind == _kind and temp_list[i].vid == v_id then
      return true
    end
  end
  return false
end
function run()
  ui_tempshortcut.w_main_mask.visible = false
  ui_tempshortcut.w_main_mask:post_release()
end
function set_hook_visible(c, vis)
  c.visible = vis
  c.focus = vis
  if vis then
    c:move_to_head()
  else
    c:post_release()
  end
  local function on_time_set_priority()
    if vis then
      ui_tempshortcut.main_wnd.priority = 500
      c.priority = 495
      c:move_to_head()
      ui_tempshortcut.w_main_mask:move_to_head()
    else
      ui_tempshortcut.main_wnd.priority = 0
    end
  end
  bo2.AddTimeEvent(1, on_time_set_priority)
end
function set_hook(item_id, vis)
  if g_sys_hook == vis or item_id == nil or g_hook_item_tab[item_id] == nil then
    return false
  end
  g_sys_hook = vis
  if vis then
    local c = ui.create_control(ui_main.w_top, "panel")
    c:load_style(L("$frame/qbar/tempshortcut.xml"), L("tempshortcut_mask"))
    set_hook_visible(c, vis)
  else
    set_hook_visible(ui_tempshortcut.w_main_mask, vis)
    local on_time_quest_visible = function()
      ui_quest.ui_milestone.set_visible(true)
    end
    bo2.AddTimeEvent(2, on_time_quest_visible)
  end
end
function lianzhao_move(pos0, c)
  local name = sys.format(L("%d"), c)
  local w = ui_tempshortcut.ui_tempshortcut.skill_slot:search(name)
  if w == nil then
    return false
  end
  name = sys.format(L("%d"), pos0)
  local btn = ui_shortcut.w_shortcut:search(name)
  if btn == nil then
    return false
  end
  local reload = function()
    local frame = ui.create_control(ui_main.w_top, "dynamic_animation")
    frame:load_style(L("$frame/warrior_arena/warrior_arena_career.xml"), L("hide_anim"))
    return frame
  end
  local frame = g_tempskill_frame_anime
  if sys.check(frame) ~= true then
    g_tempskill_frame_anime = reload()
    frame = g_tempskill_frame_anime
  end
  frame:frame_clear()
  frame.visible = true
  local fps = 15
  local f = frame:frame_insert(fps * 40, w)
  local dis1 = w:control_to_window(ui.point(0, 0))
  local pos = btn:control_to_window(ui.point(0, 0))
  f:set_translate1(dis1.x, dis1.y)
  f:set_translate2(pos.x, pos.y)
  local function on_time()
    ui.shortcut_set(pos0, bo2.eShortcut_LianZhao, 6)
    ui_tempshortcut.main_wnd.visible = false
  end
  bo2.AddTimeEvent(fps, on_time)
end
function ListAdd(_kind, _id, v_id)
  if IsAreadyInList(_kind, v_id) then
    return
  end
  if temp_list == nil then
    temp_list = {}
    temp_list.first = 0
    temp_list.last = -1
  end
  local last = temp_list.last + 1
  temp_list.last = last
  temp_list[last] = {
    kind = _kind,
    id = _id,
    vid = v_id
  }
  if _kind == bo2.eShortcut_Item then
    local idx = v_id
    set_hook(idx, true)
  end
  slot_update()
  if _kind == bo2.eShortcut_Skill then
    ui_handson_teach.on_temp_skill_visible(v_id, true)
  elseif _kind == bo2.eShortcut_Item then
    ui_handson_teach.on_temp_item_visible(v_id, true)
  end
  if _kind == bo2.eShortcut_LianZhao and _id.v_int == 6 then
    local A1Slot = 30
    lianzhao_move(A1Slot, last)
  end
end
function ListRemove(data)
  local _kind = data:get("kind").v_int
  local _id = data:get("excel_id").v_int
  local _onlyId = data:get("only_id").v_string
  if temp_list == nil then
    return
  end
  local first = temp_list.first
  local last = temp_list.last
  if first > last then
    return
  end
  local b = false
  local pos = 0
  for i = first, last do
    if temp_list[i].kind == _kind and (temp_list[i].id == _onlyId or temp_list[i].vid == _id) then
      temp_list[i] = nil
      b = true
      pos = i
      break
    end
  end
  if not b then
    return
  end
  for i = pos, first, -1 do
    if first > i - 1 then
      temp_list[i] = nil
    else
      temp_list[i] = temp_list[i - 1]
    end
  end
  temp_list.first = first + 1
  if _kind == bo2.eShortcut_Item then
    set_hook(_id, false)
  end
  slot_update()
  if _kind == bo2.eShortcut_Skill then
    ui_handson_teach.on_temp_skill_visible(_id, false, 1)
  elseif _kind == bo2.eShortcut_Item then
    ui_handson_teach.on_temp_item_visible(_id, false, 1)
  end
end
function on_init()
end
function on_learn_new(cmd, data)
  local ntype = data:get(packet.key.ui_shortcut_type).v_int
  local id = data:get(packet.key.ui_shortcut_onlyid).v_string
  local excel_id = data:get(packet.key.ui_shortcut_onlyid).v_int
  local excel = bo2.gv_skill_group:find(excel_id)
  if excel ~= nil and excel.xinfa and excel.xinfa ~= 0 then
    local type = bo2.gv_xinfa_list:find(excel.xinfa).type_id
    if type == bo2.eXinFaType_Etiquette then
      return
    end
  end
  bo2.PlaySound2D(596)
  ListAdd(ntype, id, data:get(packet.key.ui_shortcut_onlyid).v_int)
end
function slot_update()
  timer.suspended = false
  local b = false
  local first = temp_list.first
  for i = 0, idx_count - 1 do
    local kind, id = bo2.eShortcut_None, 0
    if temp_list[first + i] ~= nil then
      kind = temp_list[first + i].kind
      id = temp_list[first + i].id
      b = true
    end
    ui.shortcut_set(idx_begin + i, kind, id)
  end
  if not b then
    timer_delay_close.suspended = false
    show_wnd(false)
  else
    show_wnd(true)
  end
  return
end
function show_wnd(b)
  if temp_list == nil then
    main_wnd.visible = false
    return
  end
  if b then
    main_wnd.visible = true
  else
    main_wnd.visible = false
  end
end
function on_close(btn)
  if g_sys_hook ~= true then
    ui_widget.on_close_click(btn)
  end
end
function on_visible_chg(w, b)
  if g_sys_hook ~= true then
    ui_widget.on_esc_stk_visible(w, b)
  end
  if b == true then
    return
  end
  timer_delay_close.suspended = true
  timer.suspended = true
  for i = 0, idx_count - 1 do
    local kind, id = bo2.eShortcut_None, 0
    ui.shortcut_set(idx_begin + i, kind, id)
  end
  temp_list = nil
  if _kind == bo2.eShortcut_Skill then
    ui_handson_teach.on_temp_skill_visible(_id, false)
  elseif _kind == bo2.eShortcut_Item then
    ui_handson_teach.on_temp_item_visible(_id, false)
  end
end
function on_timer()
  slot_update()
end
function on_timer_delay_close()
  if g_sys_hook == true then
    return
  end
  timer_delay_close.suspended = true
  timer.suspended = true
  for i = 0, idx_count - 1 do
    local kind, id = bo2.eShortcut_None, 0
    ui.shortcut_set(idx_begin + i, kind, id)
  end
  temp_list = nil
  show_wnd(false)
end
function on_card_tip_show(tip)
  ui_shortcut.on_main_card_tip_show(tip)
end
function shortcut_create_drop(card)
  local info = ui.shortcut_get(card.index)
  if info == nil then
    return
  end
  local icon = info.icon
  if icon == nil then
    return
  end
  local data = sys.variant()
  data:set("drop_type", ui_widget.c_drop_type_shortcut)
  data:set("index", card.index)
  data:set("kind", info.kind)
  data:set("excel_id", card.excel_id)
  data:set("only_id", info.only_id)
  ui.set_cursor_icon(icon.uri)
  ui.setup_drop(ui_tool.w_drop_floater, data)
end
function on_card_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_rbutton_click then
    if msg == ui.mouse_lbutton_click and ui.is_key_down(ui.VK_CONTROL) then
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
      elseif info.kind == bo2.eShortcut_Item then
        local only_id = info.only_id
        if not only_id.empty then
          local item_info = ui.item_of_only_id(only_id)
          ui_chat.insert_item(item_info.excel_id, item_info.code)
        end
        return
      end
    end
    ui_shortcut.shortcut_use(card.index)
    return
  end
  if msg == ui.mouse_lbutton_drag then
    shortcut_create_drop(card)
    return
  end
end
function on_gain_item_event(info, bAdd)
  if info == nil then
    return
  end
  if bAdd then
    local excel = info.excel
    if excel ~= nil then
      local ptype = excel.ptype
      if ptype ~= nil then
        if ptype.group == bo2.eItemGroup_Equip then
          if info:check_effective() == true then
            local current_info = ui.item_of_coord(bo2.eItemArray_InSlot, ptype.equip_slot)
            if current_info == nil or ui_tool.ctip_calculate_item_rank(info.excel, info) > ui_tool.ctip_calculate_item_rank(current_info.excel, current_info) then
              ListAdd(bo2.eShortcut_Item, info.only_id, info.excel_id)
            end
          end
        elseif ptype.group == bo2.eItemGroup_Quest and excel.use_id ~= 0 then
          ListAdd(bo2.eShortcut_Item, info.only_id, info.excel_id)
        end
      end
    end
  else
    local data = sys.variant()
    data:set("kind", bo2.eShortcut_Item)
    data:set("excel_id", info.excel_id)
    data:set("only_id", info.only_id)
    ListRemove(data)
  end
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_tempskill.packet_handle"
reg(packet.eSTC_UI_SkillStudy, on_learn_new, sig)
