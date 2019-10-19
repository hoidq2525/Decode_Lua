c_file = L("$frame/discover/medal.xml")
c_item_style = L("tree_item")
c_child_item_style = L("tree_child_item")
c_progress_max = 248
g_type_max = {}
g_sel_item = nil
function on_medal_init()
  g_type_max[bo2.bo2.eMedalType_Copy] = 0
  g_type_max[bo2.eMedalType_Friend] = 0
  g_type_max[bo2.eMedalType_Collect] = 0
  g_type_max[bo2.eMedalType_Activity] = 0
  insert_item(bo2.eMedalType_Copy)
  insert_item(bo2.eMedalType_Friend)
  insert_item(bo2.eMedalType_Collect)
  insert_item(bo2.eMedalType_Activity)
  local size = bo2.gv_medal_list.size
  for i = 0, size - 1 do
    local excel = bo2.gv_medal_list:get(i)
    g_type_max[excel.type] = g_type_max[excel.type] + 1
    local data = {
      excel_id = excel.id,
      level = 0,
      value = 0,
      trait = 0
    }
    insert_child_item(data)
  end
end
function on_item_sel(ctrl, v)
  local select = ctrl:search("select")
  if select == nil then
    return
  end
  select.visible = v
  if v == true then
    g_sel_item = ctrl
    update_adorn_sel()
    local excel_id = ctrl.var:get("excel_id").v_int
    local value = ctrl.var:get("value").v_int
    local level = ctrl.var:get("level").v_int
    local trait = ctrl.var:get("trait").v_int
    local data = {
      excel_id = excel_id,
      value = value,
      level = level,
      trait = trait
    }
    update_value(data)
  end
end
function update_adorn_sel()
  for i = 1, 3 do
    local p = w_adorn_p:search("adorn" .. i)
    local select = p:search("select")
    select.visible = false
  end
end
function on_adorn_sel(panel, msg, pos, wheel)
  local card = panel:search("card")
  if card.excel_id == 0 then
    return
  end
  update_adorn_sel()
  local level = card.var:get("level").v_int
  local value = card.var:get("value").v_int
  local trait = card.var:get("trait").v_int
  local data = {
    excel_id = card.excel_id,
    level = level,
    value = value,
    trait = trait
  }
  local select = panel:search("select")
  select.visible = true
  if g_sel_item ~= nil then
    g_sel_item.selected = false
  end
  update_value(data)
end
function on_adorn1_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    on_adorn_sel(panel, msg, pos, wheel)
  end
end
function on_adorn2_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    on_adorn_sel(panel, msg, pos, wheel)
  end
end
function on_adorn3_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    on_adorn_sel(panel, msg, pos, wheel)
  end
end
function on_card1_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    on_adorn_sel(card.parent.parent, msg, pos, wheel)
  end
end
function on_card2_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    on_adorn_sel(card.parent.parent, msg, pos, wheel)
  end
end
function on_card3_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    on_adorn_sel(card.parent.parent, msg, pos, wheel)
  end
end
function on_tree_node_toggle_click(btn)
  ui_widget.on_tree_node_toggle_click(btn)
end
function check_insert_child_item(data)
  local excel = bo2.gv_medal_list:find(data.excel_id)
  if excel == nil then
    return -1
  end
  local root = w_medal_tree.root
  local item = root:item_get(excel.type - 1)
  if item == nil then
    return -1
  end
  local size = item.item_count
  if size == 0 then
    return -2
  end
  for i = 0, size - 1 do
    local child_item = item:item_get(i)
    local excel_id = child_item.var:get("excel_id").v_int
    if excel_id == data.excel_id then
      return i
    end
  end
  return -2
end
function insert_item(type)
  local root = w_medal_tree.root
  local item = root:item_append()
  item.obtain_title:load_style(c_file, c_item_style)
  local title = item.obtain_title:search("title_label")
  title.text = ui.get_text(sys.format("medal|medal_type_%d", type))
  local val = item.obtain_title:search("title_val")
  val.text = sys.format("(%d/%d)", 0, g_type_max[type])
  item.var:set("type", type)
end
function update_num(excel, data)
  if excel == nil then
    return
  end
  local item = w_medal_tree.root:item_get(excel.type - 1)
  local size = item.item_count
  local value = 0
  for i = 0, size - 1 do
    local child_item = item:item_get(i)
    if 0 < child_item.var:get("level").v_int then
      value = value + 1
    end
  end
  local val = item.obtain_title:search("title_val")
  val.text = sys.format("(%d/%d)", value, size)
end
function insert_child_item(data)
  local excel = bo2.gv_medal_list:find(data.excel_id)
  if excel == nil then
    return
  end
  local root = w_medal_tree.root
  local item = root:item_get(excel.type - 1)
  if item == nil then
    return
  end
  local flag = check_insert_child_item(data)
  if flag == -1 then
    return
  elseif flag == -2 then
    local child_item = item:item_append()
    child_item.obtain_title:load_style(c_file, c_child_item_style)
    local lb = child_item.obtain_title:search("lb")
    lb.text = excel.name
    local level = child_item.obtain_title:search("level")
    level.text = sys.format("Lv.%d", data.level)
    child_item.var:set("excel_id", excel.id)
    child_item.var:set("value", data.value)
    child_item.var:set("level", data.level)
    child_item.var:set("trait", data.trait)
    if data.level > 0 then
      lb.xcolor = ui_md.ui_discover.c_enable_color
      level.xcolor = ui_md.ui_discover.c_enable_color
    else
      lb.xcolor = ui_md.ui_discover.c_disable_color
      level.xcolor = ui_md.ui_discover.c_disable_color
    end
  else
    local child_item = item:item_get(flag)
    if child_item == nil then
      return
    end
    local lb = child_item.obtain_title:search("lb")
    lb.text = excel.name
    local level = child_item.obtain_title:search("level")
    level.text = sys.format("LV.%d", data.level)
    child_item.var:set("excel_id", data.excel_id)
    child_item.var:set("value", data.value)
    child_item.var:set("level", data.level)
    child_item.var:set("trait", data.trait)
    if data.level > 0 then
      lb.xcolor = ui_md.ui_discover.c_enable_color
      level.xcolor = ui_md.ui_discover.c_enable_color
    else
      lb.xcolor = ui_md.ui_discover.c_disable_color
      level.xcolor = ui_md.ui_discover.c_disable_color
    end
    if child_item.selected then
      update_value(data)
    end
  end
  update_num(excel, data)
end
function get_nlevel_info(excel, data)
  local trait = 0
  local value = data.value
  local max = bo2.get_medal_level_max()
  local text_all = ""
  if data.level == max - 1 then
    text_all = ui.get_text("medal|levelup_max")
  else
    trait = excel.trait[data.level + 1]
    ui.log("trait:%d", trait)
    local t_excel = bo2.gv_trait_list:find(trait)
    if t_excel == nil then
      return text_all
    end
    text_all = sys.format("%s%s\n", ui.get_text("medal|next_level_attri"), t_excel.remark)
    text_all = sys.format("%s%s%s", text_all, ui.get_text("medal|levelup_req"), excel.req_desc[data.level])
  end
  return text_all
end
function update_value(data)
  w_sel_medal.excel_id = data.excel_id
  local lb_1 = w_sel_p:search("lb_1")
  local lb_2 = w_sel_p:search("lb_2")
  local value = w_sel_p:search("value")
  value.text = data.value
  local excel = bo2.gv_medal_list:find(data.excel_id)
  if excel == nil then
    return
  end
  local text_1 = excel.name
  text_1 = sys.format("%s  Lv.%d", text_1, data.level)
  lb_1.text = text_1
  ui.log("cur_trait:%d", data.trait)
  local t_excel = bo2.gv_trait_list:find(data.trait)
  if t_excel ~= nil then
    lb_2.text = t_excel.remark
  else
    lb_2.text = ""
  end
  w_nlevel_box:item_clear()
  local n_text = get_nlevel_info(excel, data)
  ui_md.box_insert_text(w_nlevel_box, n_text)
  local max = bo2.get_medal_level_max() - 1
  w_progress_txt.text = sys.format("%d/%d", data.level, max)
  w_progress_fig.dx = c_progress_max * (data.level / max)
  for i = 1, 3 do
    local cell = w_adorn_p:search("adorn" .. i)
    local card = cell:search("card")
    if card.excel_id == data.excel_id then
      g_btn_unadorn.enable = true
      g_btn_adorn.enable = false
      return
    end
  end
  g_btn_unadorn.enable = false
  g_btn_adorn.enable = true
  if data.level == 0 then
    g_btn_adorn.enable = false
  end
end
function get_medal_info(excel_id)
  local data = {
    excel_id = excel_id,
    value = 0,
    level = 0,
    trait = 0
  }
  local excel = bo2.gv_medal_list:find(excel_id)
  if excel == nil then
    return data
  end
  local root = w_medal_tree.root
  local item = root:item_get(excel.type - 1)
  if item == nil then
    return data
  end
  local size = item.item_count
  for i = 0, size - 1 do
    local child_item = item:item_get(i)
    local id = child_item.var:get("excel_id").v_int
    if excel_id == id then
      data.value = child_item.var:get("value").v_int
      data.level = child_item.var:get("level").v_int
      data.trait = child_item.var:get("trait").v_int
      return data
    end
  end
  return data
end
function set_cell(cell, data)
  if cell == nil then
    return
  end
  local card = cell:search("card")
  card.excel_id = data.excel_id
  card.var:set("value", data.value)
  card.var:set("level", data.level)
  card.var:set("trait", data.trait)
  local lb_1 = cell:search("lb_1")
  local lb_2 = cell:search("lb_2")
  local value = cell:search("value")
  ui.log("_level")
  if card.excel == nil then
    lb_1.text = ""
    lb_2.text = ""
    value.text = ""
  else
    lb_1.text = sys.format("%s  Lv.%d", card.excel.name, data.level)
    local tl = bo2.gv_trait_list:find(data.trait)
    if tl ~= nil then
      lb_2.text = tl.remark
    else
      lb_2.text = ""
    end
  end
  value.text = data.value
end
function on_click_adorn(btn)
  if w_sel_medal.excel_id > 0 then
    local v = sys.variant()
    v:set(packet.key.item_key, w_sel_medal.excel_id)
    v:set(packet.key.itemdata_idx, 1)
    bo2.send_variant(packet.eCTS_UI_AdornMedal, v)
  else
    ui_tool.note_insert(ui.get_text("medal|adorn_warning"), ui_md.c_warning_color)
  end
end
function on_click_unadorn(btn)
  if w_sel_medal.excel_id > 0 then
    local v = sys.variant()
    v:set(packet.key.item_key, w_sel_medal.excel_id)
    v:set(packet.key.itemdata_idx, 0)
    bo2.send_variant(packet.eCTS_UI_AdornMedal, v)
  else
    ui_tool.note_insert(ui.get_text("medal|adorn_warning"), ui_md.c_warning_color)
  end
  update_adorn_sel()
end
function on_adorn(cmd, data)
  local iExcelID = data:get(packet.key.item_key).v_int
  local idx = data:get(packet.key.itemdata_idx).v_int
  local cname = sys.format("adorn%d", idx)
  local cell = w_adorn_p:search(cname)
  if iExcelID == 0 then
    local oldcard = cell:search("card")
    if oldcard.excel_id ~= 0 and w_sel_medal.excel_id == oldcard.excel_id then
      g_btn_adorn.enable = true
      g_btn_unadorn.enable = false
    end
  elseif w_sel_medal.excel_id == iExcelID then
    g_btn_adorn.enable = false
    g_btn_unadorn.enable = true
  end
  local d = get_medal_info(iExcelID)
  set_cell(cell, d)
end
function on_medal(cmd, data)
  local iExcelID = data:get(packet.key.item_key).v_int
  local cur = data:get(packet.key.itemdata_val).v_int
  local level = data:get(packet.key.itemdata_idx).v_int
  local trait = data:get(packet.key.item_excelid).v_int
  local n = bo2.gv_medal_list:find(iExcelID)
  if n == nil then
    return
  end
  local data = {
    excel_id = iExcelID,
    value = cur,
    level = level,
    trait = trait
  }
  insert_child_item(data)
end
function on_score(obj, ft, idx)
  local c = obj:get_flag_int32(idx)
  w_card_score.text = sys.format(ui.get_text("medal|score"), c)
end
function on_self_enter(obj, msg)
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.eFlagInt32_MedalScore, on_score, "ui_medal.on_score")
end
local sig_name = "ui_medal:on_signal"
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_AdornMedal, on_adorn, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_Medal, on_medal, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_md.ui_medal.on_self_enter")
