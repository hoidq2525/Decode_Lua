local c_lvup_manual_menu_style_uri = L("$gui/frame/help/levelup_manual_kit.xml")
local c_lvup_manual_menu_window_style = L("lvup_menu_window")
local c_lvup_manual_menu_item_style = L("menu_item")
local c_lvup_manual_menu_mouse_filter_name = L("ui_tool.on_menu_mouse_filter")
local g_lvup_manual_select_id = 0
local c_manual_title_color = L("FF0000")
local c_manual_end_space = L([[


]])
function on_init_levelup_manual()
  on_init_level_combo_box()
end
function on_init_level_combo_box()
  local w = w_lvup_manual_combo_box:search("lv_item")
  local mb_data_size = bo2.gv_levelup_manual.size
  local id
  for i = 0, mb_data_size - 1 do
    id = bo2.gv_levelup_manual:get(i).id
    combo_box_append_item(w, id)
  end
end
function on_init_combo_box(cb)
end
function on_fix_manual_content(id)
  local mb_data = bo2.gv_levelup_manual:find(id)
  if mb_data ~= nil then
    local function init_mtf_text(_type_text, _type_name)
      if _type_text.empty == true then
        return L("")
      end
      local _append_title_text = L("")
      if _type_name ~= nil then
        _append_title_text = sys.format(L("<lb:plain,14,none,%s|[%s]>\n"), c_manual_title_color, _type_name)
      end
      local _append_text = sys.format(L("%s%s%s"), _append_title_text, _type_text, c_manual_end_space)
      return _append_text
    end
    local _mtf_text = L("")
    _mtf_text = _mtf_text .. init_mtf_text(mb_data.manual_prologue, nil)
    _mtf_text = _mtf_text .. init_mtf_text(mb_data.manual_skill_learn, ui.get_text("help|manual_skill_learn"))
    _mtf_text = _mtf_text .. init_mtf_text(mb_data.manual_quest_tip, ui.get_text("help|manual_quest_tip"))
    _mtf_text = _mtf_text .. init_mtf_text(mb_data.manual_change_equip_tip, ui.get_text("help|manual_change_equip_tip"))
    _mtf_text = _mtf_text .. init_mtf_text(mb_data.manual_suitable_gain_level_area, ui.get_text("help|manual_suitable_gain_level_area"))
    _mtf_text = _mtf_text .. init_mtf_text(mb_data.manual_worldevent, ui.get_text("help|manual_worldevent"))
    _mtf_text = _mtf_text .. init_mtf_text(mb_data.manual_dungeon_tip, ui.get_text("help|manual_dungeon_tip"))
    _mtf_text = _mtf_text .. init_mtf_text(mb_data.manual_conclusion, ui.get_text("help|manual_conclusion"))
    rb_manual_content.mtf = _mtf_text
    rb_manual_content.parent:tune("rb_manual_content")
  end
end
function select_combo_box_item(id)
  g_lvup_manual_select_id = id
  local title_text = sys.format(L("%d\188\182"), id)
  btn_level_combo_box.text = title_text
  on_fix_manual_content(id)
end
function combo_box_append_item(w, id)
  local _append_text = sys.format(L("%d\188\182"), id)
  local w_item = w:item_append()
  w_item:load_style(c_lvup_manual_menu_style_uri, c_lvup_manual_menu_item_style)
  w_item.svar.id = id
  w_item:search(L("btn_item")).text = _append_text
end
function on_click_bo2_guide()
  bo2_guide.w_main.visible = true
end
local g_menu_valid_msg = {
  [ui.mouse_lbutton_down] = 1,
  [ui.mouse_rbutton_down] = 1,
  [ui.mouse_lbutton_dbl] = 1,
  [ui.mouse_rbutton_dbl] = 1
}
function on_menu_mouse_filter(ctrl, msg, pos, wheel)
  if g_menu_valid_msg[msg] == nil then
    return
  end
  while sys.check(ctrl) do
    if ctrl.name == L("btn_drop_down") or ctrl.name == L("lv_item") then
      return
    end
    ctrl = ctrl.parent
  end
  hide_lv_up_manual_menu()
end
function hide_lv_up_manual_menu()
  ui.remove_mouse_filter_prev(c_lvup_manual_menu_mouse_filter_name)
  w_lvup_manual_combo_box.visible = false
end
function on_click_menu_item(btn)
  local svar = btn.parent.svar
  local id = svar.id
  select_combo_box_item(id)
  hide_lv_up_manual_menu()
end
function on_btn_drop_down_click(btn)
  if w_lvup_manual_combo_box.visible ~= false then
    hide_lv_up_manual_menu()
    return
  end
  w_lvup_manual_combo_box.visible = true
  ui.insert_mouse_filter_prev(on_menu_mouse_filter, c_lvup_manual_menu_mouse_filter_name)
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    if g_lvup_manual_select_id == 0 and bo2.player ~= nil then
      local player_level = bo2.player:get_atb(bo2.eAtb_Level)
      select_combo_box_item(player_level)
    end
  else
    ui_widget.esc_stk_pop(w)
  end
end
