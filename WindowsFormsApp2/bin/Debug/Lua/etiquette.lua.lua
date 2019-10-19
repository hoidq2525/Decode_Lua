function update_page(current, total)
  local s = sys.format("%d/%d", current, total)
  w_etiquette:search("page_text").text = s
end
function get_skill_excel(excel_id, type)
  local excel
  if type == 0 then
    excel = bo2.gv_passive_skill:find(excel_id)
  elseif type == 1 then
    excel = bo2.gv_skill_group:find(excel_id)
  else
    return
  end
  return excel
end
function on_eti_mouse(card, msg)
  if msg == ui.mouse_lbutton_click then
    local info = ui.skill_find(card.excel_id)
    if info == nil then
      return
    end
    bo2.use_skill(card.excel_id)
    ui_qchat.w_etiquette.visible = false
    ui_qchat.w_qchat.visible = false
  end
end
function on_eti_tip_show(tip)
  local card = tip.owner
  if card.excel_id == 0 then
    return
  end
  local stk = sys.mtf_stack()
  local skill_info = ui.skill_find(card.excel_id)
  ui_tool.ctip_make_shortcut_skill(stk, skill_info)
  ui_tool.ctip_show(card, stk)
end
local eti_count = 0
local current_page = 1
local total_page = 1
function on_prev_etiquette(btn)
  if current_page > 1 then
    current_page = current_page - 1
    local page_index = (current_page - 1) * 24
    for i = 0, 23 do
      local item = w_etiquette_list:search("skill" .. i)
      if page_index + i < eti_count then
        local liyi_item = ui_skill.w_liyi:search("skill" .. page_index + i + 1)
        item:search("skill_card").excel_id = liyi_item:search("skill_card").excel_id
      else
        item:search("skill_card").excel_id = 0
      end
    end
    update_page(current_page, total_page)
  end
end
function on_next_etiquette(btn)
  if current_page < total_page then
    current_page = current_page + 1
    local page_index = (current_page - 1) * 24
    for i = 0, 23 do
      local item = w_etiquette_list:search("skill" .. i)
      if page_index + i < eti_count then
        local liyi_item = ui_skill.w_liyi:search("skill" .. page_index + i + 1)
        item:search("skill_card").excel_id = liyi_item:search("skill_card").excel_id
      else
        item:search("skill_card").excel_id = 0
      end
    end
    update_page(current_page, total_page)
  end
end
function on_etiquette(btn)
  eti_count = ui_skill.temp_flag - 1
  total_page = math.ceil(eti_count / 24)
  current_page = 1
  for i = 0, 23 do
    local item = w_etiquette_list:search("skill" .. i)
    if i < eti_count then
      local liyi_item = ui_skill.w_liyi:search("skill" .. i + 1)
      item:search("skill_card").excel_id = liyi_item:search("skill_card").excel_id
    else
      item:search("skill_card").excel_id = 0
    end
  end
  update_page(current_page, total_page)
  ui_widget.ui_popup.show(ui_qchat.w_etiquette, btn, "y1x2", btn)
end
function on_etiquette_click(ctrl)
  eti_count = ui_skill.temp_flag - 1
  total_page = math.ceil(eti_count / 24)
  current_page = 1
  for i = 0, 23 do
    local item = w_etiquette_list:search("skill" .. i)
    if i < eti_count then
      local liyi_item = ui_skill.w_liyi:search("skill" .. i + 1)
      item:search("skill_card").excel_id = liyi_item:search("skill_card").excel_id
    else
      item:search("skill_card").excel_id = 0
    end
  end
  update_page(current_page, total_page)
  ui_widget.ui_popup.show(ctrl, ui_shortcut.w_create_msg, "y1x2", ui_shortcut.w_create_msg)
end
function on_etiquette_init(panel)
  local item
  local uri = "$frame/qbar/etiquette.xml"
  local style = "etiquette_item"
  for i = 0, 23 do
    item = ui.create_control(w_etiquette_list, "divider")
    item:load_style(uri, style)
    item.name = "skill" .. i
    local skill = item:search("skill_card")
  end
end
