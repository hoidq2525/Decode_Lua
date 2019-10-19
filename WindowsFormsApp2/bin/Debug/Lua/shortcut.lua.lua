function init_once()
  if rawget(_M, "g_already_init") ~= nil then
    return
  end
  g_already_init = true
end
function shortcut_up(id)
  local info = ui.shortcut_get(id)
  if info == nil then
    return
  end
  local excel = info.excel
  if excel == nil then
    return
  end
  if info.kind == bo2.eShortcut_Skill then
    ui_skill.on_shortcut_up(excel.id)
  elseif info.kind == bo2.eShortcut_Item then
    local only_id = info.only_id
    if not only_id.empty then
      local item_info = ui.item_of_only_id(only_id)
      if item_info == nil then
        item_info = ui.item_of_excel_id(excel.id, bo2.eItemBox_BagBeg, bo2.eItemArray_InSlot)
      end
      if item_info ~= nil then
        local excel = info.excel
        local puse = excel.iuse
        if puse ~= nil and puse.model == bo2.eUseMod_UseSkill then
          ui_skill.on_shortcut_up(excel.use_par[0])
        end
      end
    end
  end
end
function set_teach_view(vis)
  if vis then
    w_shortcut0_t.visible = true
    w_shortcut1_t.visible = true
    w_shortcut0.visible = false
    w_shortcut1.visible = false
  else
    if sys.check(bo2.player) and bo2.player:get_flag_bit(bo2.ePlayerFlagBit_TeachSkillMode) == 1 then
      return
    end
    w_shortcut0_t.visible = false
    w_shortcut1_t.visible = false
    w_shortcut0.visible = true
    w_shortcut1.visible = true
  end
end
function set_teach_skill()
  if sys.check(bo2.player) and bo2.player:get_flag_bit(bo2.ePlayerFlagBit_TeachSkillMode) == 1 then
    set_teach_view(true)
  else
    set_teach_view(false)
  end
end
function on_self_enter()
  if sys.check(bo2.player) then
    bo2.player:insert_on_flagmsg(bo2.eFlagType_Bit, bo2.ePlayerFlagBit_TeachSkillMode, set_teach_skill, "ui_shortcut.set_teach_skill")
  end
end
local sig = "ui_shortcut.on_self_enter"
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, sig)
function shortcut_on_op(id, down)
  local idx = 0
  if id >= 0 and id <= 11 then
    idx = 10 + id
  elseif id >= 100 and id <= 111 then
    idx = 30 + id - 100
  elseif id >= 200 and id <= 207 then
    idx = 2 + id - 200
  elseif id >= 208 and id <= 215 then
    idx = 50 + id - 208
  elseif id >= 216 and id <= 223 then
    idx = 22 + id - 216
  elseif id >= 224 and id <= 231 then
    idx = 42 + id - 224
  elseif id >= 232 and id <= 235 then
    idx = 79 + id - 232
  end
  if idx == 0 then
    return
  end
  if bo2.player and bo2.player:get_flag_bit(bo2.ePlayerFlagBit_TeachSkillMode) == 1 then
    if idx >= 10 and idx <= 21 then
      idx = idx - 10 + 100
    elseif idx >= 30 and idx <= 41 then
      idx = idx - 30 + 12 + 100
    end
  end
  if ui_ridepet_shortcut.is_active() then
    if idx >= 10 and idx <= 15 then
      idx = idx - 10 + 1000
    elseif idx >= 16 and idx <= 21 then
      return
    elseif idx >= 30 and idx <= 41 then
      return
    end
  elseif ui_temp_bar.is_active() and idx >= 10 and idx < 19 then
    idx = idx + 1040
  end
  local info = ui.shortcut_get(idx)
  if down then
    if info ~= nil then
      info.op_press = true
    end
    local use = shortcut_use(idx)
    if info ~= nil and use ~= nil and use == 1 then
      info.op_press = false
    end
  else
    if info ~= nil then
      info.op_press = false
    end
    shortcut_up(idx)
  end
end
function hotkey_update()
  if not sys.check(w_shortcut) then
    return
  end
  for i, d in pairs(g_slots) do
    local h = d.hotkey
    if sys.check(h) then
      h.dx = 64
      local idx = d.index
      local id = -1
      if idx >= 10 and idx <= 21 then
        id = idx - 10
      elseif idx >= 30 and idx <= 41 then
        id = idx - 30 + 100
      elseif idx >= 2 and idx <= 9 then
        id = idx - 2 + 200
      elseif idx >= 50 and idx <= 57 then
        id = idx - 50 + 208
      elseif idx >= 22 and idx <= 29 then
        id = idx - 22 + 216
      elseif idx >= 42 and idx <= 49 then
        id = idx - 42 + 224
      elseif idx >= 79 and idx <= 82 then
        id = idx - 79 + 232
      elseif idx >= 100 and idx <= 111 then
        id = idx - 100
      elseif idx >= 112 and idx <= 123 then
        id = idx - 112 + 100
      elseif idx >= 1000 and idx <= 1005 then
        id = idx - 1000
      end
      if id < 0 then
      elseif ui_temp_bar ~= nil and ui_temp_bar.On_shortcut_hotkey_updata(id) == true then
        h.text = ""
      elseif ui_ridepet_shortcut.is_active() and idx >= 10 and idx <= 15 then
        h.text = ""
      else
        local op = ui_setting.ui_input.op_ids[3000 + id]
        if op ~= nil then
          local hk = op.hotkey
          local txt = hk:get_cell(0).simple_text
          if txt.empty then
            txt = hk:get_cell(1).simple_text
          end
          h.text = txt
        end
      end
    end
  end
  if sys.check(ui_qbar) then
    ui_qbar.flight_route_shortcut_update()
  end
end
function shortcut_do_drop(idx, kind, id)
  local info = ui.shortcut_get(idx)
  if info == nil then
    return
  end
  ui.clean_drop()
  if info.kind == kind and info.only_id == L(id) then
    return
  end
  ui.shortcut_set(idx, kind, id)
  shortcut_create_drop(bo2.eShortcut_SlotPseudoDrop, 1)
end
function shortcut_check_drop(data)
  local drop_type = data:get("drop_type").v_string
  if drop_type == ui_widget.c_drop_type_shortcut then
    return true
  end
  if drop_type == ui_widget.c_drop_type_item then
    return true
  end
  if drop_type == ui_widget.c_drop_type_skill then
    return true
  end
  if drop_type == ui_widget.c_drop_type_PetSkill then
    return true
  end
  if drop_type == ui_widget.c_drop_type_PetPortrait then
    return true
  end
  if drop_type == ui_widget.c_drop_type_lianzhao then
    return true
  end
  if drop_type == ui_widget.c_drop_type_ride then
    return true
  end
  if drop_type == ui_widget.c_drop_type_equippack then
    return true
  end
  return false
end
function get_bar_lock(bar)
  return bar:search("btn_unlock").visible
end
function set_bar_lock(bar, lock)
  local function set_group_lock(n)
    local g = bar:search(n)
    if lock then
      g:search("btn_unlock").visible = true
      g:search("btn_toggle").visible = false
      g:search("fig_mover").visible = false
    else
      g:search("btn_unlock").visible = false
      g:search("btn_toggle").visible = true
      g:search("fig_mover").visible = true
    end
  end
  set_group_lock("group_0")
  set_group_lock("group_1")
  set_group_lock("group_2")
end
function check_card_locked(card)
  local is_main_shortcut = card.svar.is_main_shortcut
  local locked = false
  if is_main_shortcut ~= nil and is_main_shortcut then
    locked = btn_unlock.visible
  else
    locked = get_bar_lock(card.topper)
  end
  return locked
end
function on_card_drop_logic(card, msg, pos, data)
  local drop_type = data:get("drop_type").v_string
  local idx_dst = card.index
  local info_dst = ui.shortcut_get(idx_dst)
  if info_dst == nil then
    return
  end
  local icon_dst = info_dst.icon
  local kind_dst = info_dst.kind
  local id_dst = info_dst.only_id
  if drop_type == ui_widget.c_drop_type_shortcut then
    local idx_src = data:get("index").v_int
    if idx_src == idx_dst then
      return
    end
    ui.clean_drop()
    local info_src = ui.shortcut_get(idx_src)
    if info_src == nil then
      return
    end
    local kind_src = info_src.kind
    local id_src = info_src.only_id
    if card.index >= 100 and card.index < 124 and kind_src ~= bo2.eShortcut_Skill and kind_src ~= bo2.eShortcut_LianZhao then
      ui_tool.note_insert(ui.get_text("warrior_arena|unvalid_skill"), "FF0000")
      return
    end
    ui.shortcut_set(idx_dst, kind_src, id_src)
    if idx_src == bo2.eShortcut_SlotPseudoDrop then
      ui.shortcut_set(bo2.eShortcut_SlotPseudoDrop, kind_dst, id_dst)
      shortcut_create_drop(bo2.eShortcut_SlotPseudoDrop, 1)
    elseif idx_src >= 79 and idx_src <= 82 and idx_dst >= 79 and idx_dst <= 82 then
      ui.shortcut_set(idx_src, kind_dst, id_dst)
    elseif idx_src < 79 or idx_src > 82 then
      ui.shortcut_set(idx_src, kind_dst, id_dst)
    end
    if idx_src >= 50 then
      ui_tempshortcut.ListRemove(data)
    end
    return
  end
  if card.index >= 100 and card.index < 124 then
    if drop_type ~= ui_widget.c_drop_type_teachskill then
      local idx = data:get("excel_id").v_int
      if drop_type == ui_widget.c_drop_type_lianzhao then
        shortcut_do_drop(card.index, bo2.eShortcut_LianZhao, idx)
        return
      end
      ui_tool.note_insert(ui.get_text("warrior_arena|unvalid_skill"), "FF0000")
      return
    else
      shortcut_do_drop(card.index, bo2.eShortcut_Skill, data:get("excel_id").v_int)
      return
    end
  end
  if drop_type == ui_widget.c_drop_type_item then
    local item_info = ui.item_of_only_id(data:get("only_id"))
    if item_info ~= nil and item_info.excel.type >= bo2.eItemtype_UseHWeapon and item_info.excel.type <= bo2.eItemType_UseHWeaponEnd then
      local skill = item_info.excel.use_par[0]
      ui.skill_insert(skill, 1)
      shortcut_do_drop(card.index, bo2.eShortcut_Skill, skill)
      return
    end
    shortcut_do_drop(card.index, bo2.eShortcut_Item, data:get("only_id"))
    return
  end
  if drop_type == ui_widget.c_drop_type_skill then
    shortcut_do_drop(card.index, bo2.eShortcut_Skill, data:get("excel_id").v_int)
    return
  end
  if drop_type == ui_widget.c_drop_type_PetSkill then
    shortcut_do_drop(card.index, bo2.eShortcut_PetSkill, data:get("excel_id").v_int)
  end
  if drop_type == ui_widget.c_drop_type_PetPortrait then
    shortcut_do_drop(card.index, bo2.eShortcut_Pet, data:get("only_id"))
    return
  end
  if drop_type == ui_widget.c_drop_type_lianzhao then
    shortcut_do_drop(card.index, bo2.eShortcut_LianZhao, data:get("id").v_int)
    return
  end
  if drop_type == ui_widget.c_drop_type_equippack then
    shortcut_do_drop(card.index, bo2.eShortcut_EquipPack, data:get("pack_id").v_int)
    return
  end
  if drop_type == ui_widget.c_drop_type_ride then
    shortcut_do_drop(card.index, bo2.eShortcut_Ridepet, data:get("only_id"))
    return
  end
end
function on_card_drop(card, msg, pos, data)
  if msg == ui.mouse_lbutton_up then
    if data:get("disable_lbutton_up").v_int == 1 then
      return
    end
  elseif msg ~= ui.mouse_lbutton_down then
    return
  end
  if check_card_locked(card) and card.excel ~= nil then
    ui_chat.show_ui_text_id(1256)
    return
  end
  if card.index >= 79 and card.index <= 82 then
    local drop_type = data:get("drop_type").v_string
    if drop_type ~= ui_widget.c_drop_type_shortcut then
      ui_tool.note_insert(ui.get_text("qbar|sw_error"), "FFFF00")
      return
    end
    local item_info = ui.item_of_coord(bo2.eItemArray_InSlot, bo2.eItemSlot_2ndWeapon)
    if item_info == nil then
      ui_tool.note_insert(ui.get_text("qbar|sw_error"), "FFFF00")
      return
    else
      local idx_src = data:get("index").v_int
      if idx_src < 79 or idx_src > 82 then
        ui_tool.note_insert(ui.get_text("qbar|sw_error"), "FFFF00")
        return
      end
    end
  end
  on_card_drop_logic(card, msg, pos, data)
end
local handle_use_equip = function(id)
  local skill_info = ui.skill_find(id)
  if skill_info == nil then
    ui_chat.show_ui_text_id(76001)
    return
  end
  local data = sys.variant()
  data:set("drop_type", ui_widget.c_drop_type_skilltoitem)
  data:set("skill_id", id)
  ui.set_cursor_icon("$gui/cursor/c19.png")
  local on_drop_hook = function(w, msg, pos, data)
    if msg == ui.mouse_drop_clean then
      ui.item_mark_show("equip_resolve", false)
    end
  end
  ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  ui.item_mark_show("equip_resolve", true)
  ui_item.w_item.visible = true
end
local handle_use_transto = function(id)
  ui_qbar.ui_tudun.show(id)
end
local handle_use_livingskill = function(id)
  local skill_info = ui.skill_find(id)
  if skill_info == nil then
    ui_chat.show_ui_text_id(76001)
    return
  end
  ui_npcfunc.ui_livingskill_peifang.show(id)
end
local use_handlers = {
  [100042] = handle_use_equip,
  [100113] = handle_use_equip,
  [110027] = handle_use_transto,
  [100282] = handle_use_livingskill,
  [100283] = handle_use_livingskill,
  [100284] = handle_use_equip,
  [100285] = handle_use_livingskill,
  [100287] = handle_use_equip
}
function shortcut_use_skill(id)
  local h = use_handlers[id]
  if h ~= nil then
    h(id)
  elseif not ui_skill.IsCurXuliSkill(id) then
    bo2.use_skill(id)
  end
end
function shortcut_use(idx)
  if ui_qbar.on_test_use_skill(idx) == true then
    return
  end
  local info = ui.shortcut_get(idx)
  if info == nil then
    return
  end
  local excel = info.excel
  if excel == nil then
    return
  end
  if info.kind == bo2.eShortcut_Skill then
    shortcut_use_skill(excel.id)
    return
  end
  if info.kind == bo2.eShortcut_Item then
    item_info = ui.item_of_excel_id(excel.id, bo2.eItemArray_InSlot, bo2.eItemArray_InSlot + 1)
    if item_info ~= nil then
      if item_info.excel.type >= bo2.eItemType_SecondWeaponBegin and item_info.excel.type <= bo2.eItemType_SecondWeaponEnd and item_info.excel.iuse ~= 0 and item_info.excel.iuse.model == bo2.eUseMod_UseHWeapon then
        bo2.use_skill(item_info.excel.use_par[0])
        return
      end
      ui_item.use_item(item_info, true)
      return
    end
    local only_id = info.only_id
    if not only_id.empty then
      local item_info = ui.item_of_only_id(only_id)
      if item_info ~= nil then
        ui_item.use_item(item_info, true)
        return
      end
    end
    local item_info = ui.item_of_excel_id(excel.id, bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
    if item_info ~= nil then
      ui_item.use_item(item_info, true)
      return
    end
    ui_tool.note_insert_error(ui_widget.merge_mtf({
      excel_id = excel.id
    }, ui.get_text("qbar|item_out")))
    return
  end
  if info.kind == bo2.eShortcut_PetSkill then
    bo2.pet_use_skill(excel.id)
    return
  end
  if info.kind == bo2.eShortcut_Pet then
    local pet = ui.pet_find(info.only_id)
    local state = pet:get_atb(bo2.eFlag_Pet_State)
    if state == bo2.ePet_StateRelax then
      ui_pet.send_open_pet(bo2.player.cha_name, info.only_id)
    elseif state == bo2.ePet_StateWorking then
      ui_pet.send_close_pet()
    elseif state == bo2.ePet_StateReproduction then
      ui_tool.note_insert(ui.get_text(sys.format("pet|pet_breed_warning")))
    end
    return
  end
  if info.kind == bo2.eShortcut_LianZhao then
    bo2.use_seriesskill(excel.id)
    return
  end
  if info.kind == bo2.eShortcut_Ridepet then
    ui_ridepet.send_call_ride(info.only_id)
    return
  end
  if info.kind == bo2.eShortcut_EquipPack then
    ui_personal.ui_equip.quickequip_replace(info.excel.id)
    return
  end
end
function shortcut_create_drop(index, disable_lbutton_up)
  local info = ui.shortcut_get(index)
  if info == nil then
    return
  end
  local icon = info.icon
  if icon == nil then
    return
  end
  local data = sys.variant()
  data:set("drop_type", ui_widget.c_drop_type_shortcut)
  data:set("index", index)
  if disable_lbutton_up == 1 then
    data:set("disable_lbutton_up", 1)
  end
  ui.set_cursor_icon(icon.uri)
  ui.setup_drop(ui_tool.w_drop_floater, data)
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
      elseif info.kind == bo2.eShortcut_Item then
        local only_id = info.only_id
        if not only_id.empty then
          local item_info = ui.item_of_only_id(only_id)
          ui_chat.insert_item(item_info.excel_id, item_info.code)
        end
        return
      elseif info.kind == bo2.eShortcut_Ridepet then
        local ridepet_info = ui.get_ride_info(info.only_id)
        if ridepet_info == nil then
          return
        end
        ui_chat.insert_ridepet(ui.ride_encode(ridepet_info))
        return
      end
    end
    shortcut_use(card.index)
  elseif msg == ui.mouse_rbutton_down then
    shortcut_use(card.index)
  elseif msg == ui.mouse_rbutton_up then
    shortcut_up(card.index)
  elseif msg == ui.mouse_lbutton_drag and not check_card_locked(card) then
    shortcut_create_drop(card.index)
  end
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_shortcut(stk, excel, card.info)
  local stk_use
  ui_tool.ctip_show(card, stk, stk_use)
end
function on_main_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_shortcut(stk, excel, card.info)
  ui_tool.ctip_show(card, stk)
  local tip = card.tip
  local view = tip.view
  local sz = ui_main.w_top.size
  local view_sz = view.size
  local view_off = ui.point(sz.x - 40 - view_sz.x, sz.y - 100 - view_sz.y)
  card_off = card:control_to_window(ui.point(0, 0))
  card_sz = card.size
  if card_off.x >= view_off.x + view_sz.x or card_off.y >= view_off.y + view_sz.y or card_off.x + card_sz.x <= view_off.x or card_off.y + card_sz.y <= view_off.y then
    view.offset = view_off
  end
end
g_bars = nil
c_bar_count = 5
c_bar_size = 8
c_sw_bar_size = 4
c_bar_base = {
  [0] = 2,
  [1] = 50,
  [2] = 22,
  [3] = 42,
  [4] = 79
}
c_bar_group_count = 3
c_bar_def_cfg = {
  [0] = {
    dock = L("x2y2"),
    offset = L("45,108"),
    group = 1,
    visible = false,
    sw = false
  },
  [1] = {
    dock = L("x2y2"),
    offset = L("84,108"),
    group = 1,
    visible = false,
    sw = false
  },
  [2] = {
    dock = L("x2y2"),
    offset = L("123,108"),
    group = 1,
    visible = false,
    sw = false
  },
  [3] = {
    dock = L("x2y2"),
    offset = L("162,108"),
    group = 1,
    visible = false,
    sw = false
  },
  [4] = {
    dock = L("x2y2"),
    offset = L("201,108"),
    group = 1,
    visible = false,
    sw = true
  }
}
g_is_loading = false
function window_load(w, cfg)
  if w ~= nil then
    local s_x, s_y = cfg.offset:split2(",")
    local x, y = s_x.v_number, s_y.v_number
    local dx, dy = w.parent.dx, w.parent.dy
    local dock = cfg.dock
    if dock == L("x1y1") then
      w.offset = ui.point(x, y)
    elseif dock == L("x1y2") then
      w.offset = ui.point(x, dy - y - w.dy)
    elseif dock == L("x2y1") then
      w.offset = ui.point(dx - x - w.dx, y)
    elseif dock == L("x2y2") then
      w.offset = ui.point(dx - x - w.dx, dy - y - w.dy)
    end
    w.visible = cfg.visible
  end
end
function window_save(w, cfg)
  local cx = w.x + w.dx * 0.5
  local cy = w.y + w.dy * 0.5
  local px = w.parent.dx
  local py = w.parent.dy
  local dock, offset
  if cx < px * 0.5 then
    dock = L("x1")
    offset = w.x
  else
    dock = L("x2")
    offset = px - (w.x + w.dx)
  end
  if cy < py * 0.5 then
    cfg.dock = dock .. L("y1")
    cfg.offset = sys.format("%d,%d", offset, w.y)
  else
    cfg.dock = dock .. L("y2")
    cfg.offset = sys.format("%d,%d", offset, py - (w.y + w.dy))
  end
  cfg.visible = w.visible
end
function on_bar_close()
  w_shortcut:remove_post_invoke("ui_shortcut.shortcut_post_save")
  shortcut_save()
  g_bars = nil
end
function on_drop_filter(w, msg, pos, data)
  if g_bars == nil then
    return
  end
  if msg == ui.mouse_drop_setup then
    if not shortcut_check_drop(data) then
      return
    end
    for i = 0, c_bar_count - 1 do
      local d = g_bars[i]
      d.widget_next = d.widget.next
      d.widget:move_to_head()
    end
  elseif msg == ui.mouse_drop_clean then
    if not shortcut_check_drop(data) then
      return
    end
    for i = c_bar_count - 1, 0, -1 do
      local d = g_bars[i]
      d.widget:move_to_prev(d.widget_next)
    end
  end
end
function on_bar_reload()
  g_is_loading = true
  for i = 0, c_bar_count - 1 do
    local d = g_bars[i]
    window_load(d.widget, d.cfg)
  end
  g_is_loading = false
end
function on_bar_move(w, r)
  if g_is_loading then
    return
  end
  window_save(w, w.svar.cfg)
  shortcut_post_save()
end
function on_bar_visible(w, vis)
  if g_is_loading then
    return
  end
  local cfg = w.svar.cfg
  cfg.visible = vis
  shortcut_post_save()
end
function on_bar_init(w)
  local d = w.svar
  d.widget = w
  d.groups = {}
  for i = 0, c_bar_group_count - 1 do
    local g = {}
    g.index = i
    g.owner = d
    g.group = w:search(sys.format("group_%d", i))
    g.group.svar = g
    local btn = g.group:search("btn_toggle")
    btn.svar = g
    btn = g.group:search("btn_unlock")
    btn.svar = g
    local lb = g.group:search("lb_index")
    lb.text = d.index + 1
    local idx = c_bar_base[d.index]
    local size = c_bar_size
    if d.cfg.sw == true then
      size = c_sw_bar_size
    end
    for i = 0, size - 1 do
      local slot = g.group:search(i)
      local card = slot:search("card")
      card.index = idx + i
      slots_insert(slot)
    end
    d.groups[i] = g
  end
  bar_toggle_group(d, d.cfg.group)
  window_load(w, d.cfg)
end
function bar_toggle_group(d, i)
  for n, v in pairs(d.groups) do
    v.group.visible = false
  end
  d.cfg.group = i
  local g = d.groups[i]
  g.group.visible = true
  d.widget.size = g.group.size
end
function on_bar_toggle_click(btn)
  local g = btn.svar
  local d = g.owner
  local function on_lock()
    local bar = btn.topper
    set_bar_lock(bar, true)
    shortcut_post_save()
  end
  local function on_toggle(item)
    bar_toggle_group(d, item.index)
  end
  local on_event = function(item)
    item:callback()
  end
  ui_tool.show_menu({
    items = {
      {
        text = ui.get_text("qbar|lock_pos"),
        callback = on_lock
      },
      {
        text = ui.get_text("qbar|wangge"),
        callback = on_toggle,
        index = 2
      },
      {
        text = ui.get_text("qbar|zhongxiang"),
        callback = on_toggle,
        index = 1
      },
      {
        text = ui.get_text("qbar|hengxiang"),
        callback = on_toggle,
        index = 0
      }
    },
    event = on_event,
    source = btn,
    dx = 120,
    dy = 50,
    popup = "y_auto"
  })
  do return end
  local g = btn.svar
  local d = g.owner
  local index = g.index + 1
  if index >= c_bar_group_count then
    index = 0
  end
  bar_toggle_group(d, index)
end
function on_bar_unlock_click(btn)
  local bar = btn.topper
  set_bar_lock(bar, false)
  shortcut_post_save()
end
function on_btn_lock_click(btn)
  btn_lock.visible = false
  btn_unlock.visible = true
  shortcut_post_save()
end
function on_btn_unlock_click(btn)
  btn_lock.visible = true
  btn_unlock.visible = false
  shortcut_post_save()
end
function on_shortcut_0_check(btn, chk)
  local w = g_bars[0].widget
  w.visible = chk
end
function on_shortcut_1_check(btn, chk)
  local w = g_bars[1].widget
  w.visible = chk
end
function on_shortcut_2_check(btn, chk)
  local w = g_bars[2].widget
  w.visible = chk
end
function on_shortcut_3_check(btn, chk)
  local w = g_bars[3].widget
  w.visible = chk
end
function on_shortcut_4_check(btn, chk)
  local w = g_bars[4].widget
  w.visible = chk
end
function on_shortcut_lock_main_check(btn, chk)
end
function on_bar_show_bar_click(btn)
  if w_setting_window.svar.extent_init == nil then
    w_setting_window.svar.extent_init = true
    local p = w_setting_window.control_head
    local dx = 0
    while p ~= nil do
      local t = p:search("btn_lb_text")
      if t ~= nil then
        local pdx = t.extent.x
        if dx < pdx then
          dx = pdx
        end
      end
      p = p.next
    end
    dx = dx + 50
    if dx > w_setting_window.dx then
      w_setting_window.dx = dx
    end
  end
  w_setting_check_bar_0.check = g_bars[0].widget.visible
  w_setting_check_bar_1.check = g_bars[1].widget.visible
  w_setting_check_bar_2.check = g_bars[2].widget.visible
  w_setting_check_bar_3.check = g_bars[3].widget.visible
  w_setting_check_bar_4.check = g_bars[4].widget.visible
  ui_widget.ui_popup.show(w_setting_window, btn, "y1x2", btn)
end
function on_create_msg_dlg(btn)
  ui_qchat.on_etiquette_click(ui_qchat.w_etiquette)
end
function on_shortcut_toggle_click(btn)
  local idx = 0
  if btn.name == L("btn_show_suit1") then
    idx = 1
  end
end
function shortcut_load()
  g_bars = {}
  local cfg = ui_main.player_cfg_load("shortcut.xml")
  local bar
  if cfg ~= nil then
    bar = cfg:find("bar")
  end
  for i = 0, c_bar_count - 1 do
    local d = {}
    d.index = i
    d.name = sys.format("$frame:shortcut_bar:%d", i)
    d.cfg = {}
    for n, v in pairs(c_bar_def_cfg[i]) do
      d.cfg[n] = v
    end
    local lock = false
    if bar ~= nil then
      local x = bar:find(sys.format("bar%d", i))
      if x ~= nil then
        d.cfg.dock = x:get_attribute("dock")
        d.cfg.offset = x:get_attribute("offset")
        d.cfg.group = x:get_attribute_int("group")
        d.cfg.visible = x:get_attribute_bool("visible")
        lock = x:get_attribute_bool("lock")
      end
    end
    local w = ui.find_control(d.name)
    if w == nil then
      w = ui.create_control(ui_phase.w_main)
      w.name = d.name
    else
      w:control_clear()
    end
    w.svar = d
    if d.cfg.sw == true then
      w:load_style("$frame/qbar/shortcut.xml", "sw_shortcut_bar")
    else
      w:load_style("$frame/qbar/shortcut.xml", "shortcut_bar")
    end
    g_bars[i] = d
    set_bar_lock(w, lock)
  end
  local major
  if cfg ~= nil then
    major = cfg:find("major")
  end
  local index = 0
  if major ~= nil then
    index = major:get_attribute_int("index")
    if index < 0 then
      index = 0
    elseif index > 1 then
      index = 1
    end
    local lock = major:get_attribute_bool("lock")
    btn_lock.visible = not lock
    btn_unlock.visible = lock
  end
  ui_phase.w_main:insert_on_move(on_bar_reload, "ui_shortcut.on_bar_reload")
  ui.insert_drop_filter(on_drop_filter, "ui_shortcut.on_drop_filter")
end
function shortcut_save()
  if g_is_loading then
    return
  end
  local root = ui_main.player_cfg_load("shortcut.xml")
  if root == nil then
    root = sys.xnode()
  end
  local bar = root:get("bar")
  bar:clear()
  for i = 0, c_bar_count - 1 do
    local d = g_bars[i]
    local b = d.cfg
    local x = bar:add(sys.format("bar%d", i))
    x:set_attribute("dock", b.dock)
    x:set_attribute("offset", b.offset)
    x:set_attribute("group", b.group)
    x:set_attribute("visible", b.visible)
    x:set_attribute("lock", d.widget:search("btn_unlock").visible)
    x:set_attribute("sw", b.sw)
  end
  local major = root:get("major")
  for i = 0, 1 do
    local w = ui_shortcut["w_shortcut" .. i]
    if w.visible then
      major:set_attribute("index", i)
      break
    end
  end
  major:set_attribute("lock", btn_unlock.visible)
  ui_main.player_cfg_save(root, "shortcut.xml")
end
function shortcut_post_save()
  if g_is_loading then
    return
  end
  w_shortcut:insert_post_invoke(shortcut_save, "ui_shortcut.shortcut_post_save")
end
function slots_insert(slot)
  local d = {}
  d.slot = slot
  d.card = slot:search("card")
  d.hotkey = slot:search("hotkey")
  d.index = d.card.index
  table.insert(g_slots, d)
end
function lb_slots_insert(slot)
  local d = {}
  d.slot = slot
  local card = slot:search("card")
  d.card = card
  card.svar.is_main_shortcut = true
  d.hotkey = slot:search("hotkey")
  d.index = d.card.index
  table.insert(g_slots, d)
end
function on_lb_slot_init(ctrl)
  lb_slots_insert(ctrl)
end
function on_prev_init()
  g_slots = {}
end
function on_init()
  g_is_loading = true
  sys.pcall(shortcut_load)
  g_is_loading = false
  ui_setting.ui_input.hotkey_notify_insert(hotkey_update, "ui_shortcut.hotkey_update")
  hotkey_update()
end
