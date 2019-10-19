local boss_scn_list
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_boss_list.status_refresh"
local leaf_item_list = {}
local g_drop_item_list = {}
local g_cur_tick = 0
local group_weapon = ui.get_text("boss_list|weapon")
local group_armor = ui.get_text("boss_list|armor")
local group_others = ui.get_text("boss_list|others")
local tb_drop_group = {
  [93] = group_weapon,
  [94] = group_weapon,
  [95] = group_weapon,
  [96] = group_weapon,
  [97] = group_weapon,
  [98] = group_weapon,
  [99] = group_weapon,
  [100] = group_weapon,
  [112] = group_weapon,
  [113] = group_weapon,
  [114] = group_weapon,
  [115] = group_weapon,
  [116] = group_weapon,
  [117] = group_weapon,
  [118] = group_weapon,
  [119] = group_weapon,
  [120] = group_weapon,
  [121] = group_weapon,
  [103] = group_armor,
  [104] = group_armor,
  [105] = group_armor,
  [106] = group_armor,
  [107] = group_armor,
  [151] = group_armor,
  [152] = group_armor,
  [153] = group_armor,
  [154] = group_armor,
  [101] = group_armor,
  [102] = group_armor,
  [108] = group_armor,
  [109] = group_armor,
  [110] = group_armor,
  [111] = group_armor
}
local text_uninit = ui.get_text("boss_list|state_uninit")
local text_live = ui.get_text("boss_list|state_live")
local text_fight = ui.get_text("boss_list|state_fight")
local color_uninit = ui.make_color("FFFFCD")
local color_live = ui.make_color("00FF00")
local color_fight = ui.make_color("FF0000")
function get_status_text(n)
  if n == 0 then
    return text_uninit, color_uninit
  elseif n == 1 then
    return text_live, color_live
  elseif n == 2 then
    return text_fight, color_fight
  end
end
function show_desc_and_drop_list()
  local weapon_idx = -1
  local armor_idx = -1
  local others_idx = -1
  local line_cnt = 5
  local function insert_drop_item(item_id)
    local item_excel = ui.item_get_excel(item_id)
    if item_excel == nil then
      local err_node = ui_widget.ui_tree2.insert(w_drop_tree.root)
      local err = "error:" .. item_id
      err_node.title:search("lb_text").text = err
      return
    end
    if item_excel.lootlevel < 13 then
      return
    end
    local item_name = item_excel.name
    local item_type = item_excel.type
    local toggle_name = tb_drop_group[item_type]
    if toggle_name == nil then
      toggle_name = group_others
    end
    local drop_toggle
    for i = 0, w_drop_tree.root.item_count - 1 do
      local m = w_drop_tree.root:item_get(i)
      if m.title:search("lb_text").text == toggle_name then
        drop_toggle = m
      end
    end
    if drop_toggle == nil then
      if toggle_name == group_weapon then
        drop_toggle = ui_widget.ui_tree2.insert(w_drop_tree.root, 1)
      elseif toggle_name == group_armor then
        drop_toggle = ui_widget.ui_tree2.insert(w_drop_tree.root, 2)
      elseif toggle_name == group_others then
        drop_toggle = ui_widget.ui_tree2.insert(w_drop_tree.root, 3)
      end
      drop_toggle.title:search("lb_text").text = toggle_name
    end
    local leaf_idx
    if toggle_name == group_weapon then
      weapon_idx = weapon_idx + 1
      leaf_idx = weapon_idx
    elseif toggle_name == group_armor then
      armor_idx = armor_idx + 1
      leaf_idx = armor_idx
    elseif toggle_name == group_others then
      others_idx = others_idx + 1
      leaf_idx = others_idx
    end
    local drop_leaf
    local card_idx = leaf_idx % line_cnt
    if card_idx == 0 then
      drop_leaf = ui_widget.ui_tree2.insert(drop_toggle)
    else
      drop_leaf = drop_toggle:item_get(drop_toggle.item_count - 1)
    end
    drop_leaf.title:search(L("card") .. card_idx).excel_id = item_id
  end
  local function insert_drop_list(drops)
    for i = 0, drops.size - 1 do
      local drop_type = drops[i]
      local drop_list = bo2.item_drop_list_find(drop_type)
      if drop_list ~= nil then
        for j = 0, drop_list.size - 1 do
          insert_drop_item(drop_list:get(j))
        end
      end
    end
  end
  w_boss_desc.visible = true
  w_drop_list.visible = true
  w_bg_info.visible = false
  if w_boss_tree.item_sel == nil then
    return
  end
  local svar = w_boss_tree.item_sel.svar
  local boss_list_line = bo2.gv_boss_list:find(svar.boss_id)
  if boss_list_line == nil then
    ui.log("can't find the exact item from gv_boss_list")
    return
  end
  local boss_name = boss_list_line.name
  local cha_list_id = svar.cha_list_id
  local cha_line = bo2.gv_cha_list:find(cha_list_id)
  w_pic_boss.image = L("$data/gui/icon/portrait/") .. cha_line.head_icon
  local text_id = boss_list_line.intro_text_id
  local text_line = bo2.gv_text:find(text_id)
  if text_line == nil then
    ui.log("can't find the exact item from gv_text")
    return
  end
  w_richbox_desc:item_clear()
  w_richbox_desc.mtf = text_line.text
  w_richbox_desc.slider_y.scroll = 0
  w_drop_tree.root:item_clear()
  local cha_drop_line = bo2.gv_cha_list:find(boss_list_line.cha_drop_id)
  if cha_drop_line == nil then
    cha_drop_line = cha_line
  end
  local scn_list_line = w_boss_tree.item_sel.owner.svar.scn_list_line
  if scn_list_line.use_cha_copy == 1 then
    local cha_id = cha_drop_line.id
    for i = 0, bo2.gv_cha_list_copy.size - 1 do
      local tmp_line = bo2.gv_cha_list_copy:get(i)
      if tmp_line.copy_id == cha_id then
        local scn = tmp_line.scn_id
        for i = 0, scn.size - 1 do
          if scn[i] == scn_list_line.id then
            cha_drop_line = tmp_line
            break
          end
        end
      end
    end
  end
  local arr_quest_drop = cha_drop_line.quest_drop
  for i = 0, arr_quest_drop.size - 1, 3 do
    insert_drop_item(arr_quest_drop[i])
  end
  local arr_feature_drop = cha_drop_line.feature_drop
  for i = 0, arr_feature_drop.size - 1 do
    local rand_excel = bo2.gv_item_rand:find(arr_feature_drop[i])
    if rand_excel ~= nil then
      for j = 0, 9 do
        local drop_kind = rand_excel.drop_kind[j]
        if drop_kind == 1 then
          local item_id = rand_excel.drop_id[j]
          item_id = item_id[0]
          if item_id > 0 then
            insert_drop_item(item_id)
          end
        elseif drop_kind == 2 then
          insert_drop_list(rand_excel.drop_id[j])
        end
      end
    end
  end
  w_drop_tree.slider_y.scroll = 0
end
function on_card_mouse(card, msg, pos, wheel)
  if (msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_drag) and ui.is_key_down(ui.VK_CONTROL) then
    ui_chat.insert_item(card.excel_id)
    return
  end
end
function init_tree()
  boss_scn_list = {}
  for i = 0, bo2.gv_boss_list.size - 1 do
    local boss_info = bo2.gv_boss_list:get(i)
    local scn_node
    if boss_info.disable == 0 then
      local scn_id = boss_info.scn_id
      scn_node = boss_scn_list[scn_id]
      if scn_node == nil and scn_id > 0 then
        local scn_excel = bo2.gv_scn_list:find(scn_id)
        if scn_excel == nil then
          ui.log("boss_list bad scn_id %d", scn_id)
          return
        end
        scn_node = ui_widget.ui_tree2.insert(w_boss_tree.root)
        scn_node.expanded = false
        boss_scn_list[scn_id] = scn_node
        scn_node.svar.scn_list_line = scn_excel
        ui_widget.ui_tree2.set_text(scn_node, scn_excel.name)
      end
    end
    if scn_node ~= nil then
      local leaf_node = ui_widget.ui_tree2.insert(scn_node)
      leaf_node.expanded = false
      local title = leaf_node.title
      local svar = leaf_node.svar
      title:search("lb_text").text = boss_info.name
      svar.boss_id = boss_info.id
      svar.cha_list_id = boss_info.cha_list_id[0]
      local scn_alloc_line = bo2.gv_scn_alloc:find(boss_info.scn_id)
      if scn_alloc_line == nil then
        ui.log("boss_list bad scn_alloc_id %d", boss_info.scn_id)
        return
      end
      local lb_text_status = title:search("lb_text_status")
      svar.scn_count = scn_alloc_line.count
      if scn_alloc_line.count == 1 then
        lb_text_status.text = text_uninit
      else
        lb_text_status.text = ""
      end
      leaf_item_list[boss_info.id] = leaf_node
    end
  end
end
function on_init(ctrl)
  g_cur_tick = 0
end
function on_item_leaf_sel(item, sel)
  ui_widget.ui_tree2.on_leaf_sel(item, sel)
  show_desc_and_drop_list()
end
function on_leaf_title_mouse(title, msg)
  local item = title.item
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    ui_widget.ui_tree2.update_leaf_highlight(item)
  elseif msg == ui.mouse_lbutton_dbl then
  end
end
function on_view_drop_btn_click(btn)
end
function on_hide_btn_click()
  for idx, val in pairs(leaf_item_list) do
    if w_hide_boss.check then
      if val.title:search("lb_text_status").text == text_uninit then
        val.display = false
      end
    else
      val.display = true
    end
  end
end
function on_view_equip_btn_click(btn)
  if w_drop_tree.item_sel == nil then
    return
  end
  local item_sel = w_drop_tree.item_sel
  local excel = item_sel.svar.excel
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item(stk, excel)
  ui_item.show_tip_frame(stk.text, excel)
end
function on_major_visible(ctrl, vis)
  ui_widget.on_esc_stk_visible(ctrl, vis)
  ui_widget.on_border_visible(ctrl, vis)
  if vis then
    local svar = w_boss_tree.svar
    if svar.init_done == nil then
      svar.init_done = true
      init_tree()
    end
    local var = sys.variant()
    var:set(0, g_cur_tick)
    bo2.send_variant(packet.eCTS_UI_BossListRefresh, var)
  end
end
function on_btn_show_boss_list_click(ctrl)
  ui_boss_list.w_major_panel.visible = not ui_boss_list.w_major_panel.visible
end
function show_boss_status(cmd, var)
  g_cur_tick = var[0]
  for key, item in pairs(leaf_item_list) do
    local svar = item.svar
    local boss_id = svar.boss_id
    local lb_text_status = item.title:search("lb_text_status")
    local boss_data = var[boss_id]
    local status = 0
    local count = 0
    if boss_data ~= nil then
      status = boss_data[packet.key.cmn_state]
      count = boss_data[packet.key.cmn_count]
    end
    if svar.scn_count == 1 then
      local status_text, status_color = get_status_text(status)
      lb_text_status.color = status_color
      lb_text_status.text = status_text
      if w_hide_boss.check and status == 0 then
        item.display = false
      else
        item.display = true
      end
    else
      lb_text_status.color = color_uninit
      if count >= 1 then
        lb_text_status.text = "x" .. count
      else
        lb_text_status.text = ""
      end
    end
  end
end
function on_refresh_timer()
  local var = sys.variant()
  var:set(0, g_cur_tick)
  bo2.send_variant(packet.eCTS_UI_BossListRefresh, var)
  if w_hide_boss.check then
    for idx, val in pairs(leaf_item_list) do
      if val.title:search("lb_text_status").text ~= text_uninit and val.display == false then
        val.display = true
      end
    end
  end
end
reg(packet.eSTC_UI_BossListRefresh, show_boss_status, sig)
