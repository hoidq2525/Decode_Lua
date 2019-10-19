local g_select_item = {}
local ci_test_xinfa_excel_id = 161
local ci_test_skill_excel_id = 2014
local item_uri = L("$frame/skill/skill_preview_kit.xml")
local item_style = L("skill_list_item")
local child_item_style = L("guide_list_item_child")
local tree_view = L("skill_preview_tree")
local page_sty = L("skill_preview_tree_page")
local table_btn_name = L("tab_btn_")
set_var_skill_id = 100
local ciTreeLevel1 = 0
local ciTreeLevel2 = 1
local ciTreeLevel3 = 2
local ciLevelOneCareer = 10
local g_select_xinfa, g_select_skill
local select_font_color = "ffffffcd"
local init_font_color = "ffffff00"
g_reverse_link = nil
g_loaded = false
function on_leave_game()
  g_loaded = false
end
local preview_to_career = {
  [1] = 3,
  [2] = 1,
  [3] = 2,
  [4] = 4,
  [5] = 5,
  [6] = 6,
  [7] = 7,
  [8] = 8
}
function on_init_skill_preview_list()
  if g_loaded == true then
    return
  end
  g_loaded = true
  g_reverse_link = {}
  g_select_xinfa = nil
  g_select_skill = nil
  select_font_color = ui.make_color(select_font_color)
  init_font_color = ui.make_color(init_font_color)
  ui_widget.ui_tab.clear_tab_data(ui_skill_preview.w_main_skill_tree)
  for i = 1, ciLevelOneCareer do
    local pExcel = bo2.gv_skill_preview_tree_view:find(i)
    if pExcel ~= nil and pExcel.id <= ciLevelOneCareer and pExcel.tree_level == ciTreeLevel1 then
      local career_enable = true
      local career_id = preview_to_career[pExcel.id]
      if career_id ~= nil then
        local career = bo2.gv_career:find(career_id)
        if career ~= nil then
          career_enable = career.disable == 0
        end
      end
      if career_enable then
        local page_name = sys.format(L("%s%d"), page_sty, pExcel.inc_data)
        local btn_name = sys.format(L("%s%d"), table_btn_name, pExcel.inc_data)
        insert_table(ui_skill_preview.w_main_skill_tree, page_name, btn_name, pExcel)
      end
    end
  end
  on_init_combo_skill_item()
end
function insert_table(wnd, page_name, page_btn_name, pExcel)
  ui_widget.ui_tab.insert_suit(wnd, page_name, item_uri, page_btn_name, item_uri, page_sty)
  local page = ui_widget.ui_tab.get_page(wnd, page_name)
  local btn_page = ui_widget.ui_tab.get_button(wnd, page_name)
  if page == nil or btn_page == nil then
    ui.log("page date error.." .. page_name)
    return
  end
  local lb_name = btn_page:search(L("lb_name"))
  if lb_name ~= nil then
    lb_name.text = pExcel.inc_text
  end
  btn_page.tip.text = pExcel.inc_text
  local page_root = page:search(L("skill_preview_tree_root"))
  on_init_skill_preview_list_level_1_item(page_root, pExcel, btn_page)
end
function on_init_skill_preview_list_level_1_item(pParent, pExcel, btn_page)
  if pExcel.inc_index == nil then
    return
  end
  local nSizeXinfa = pExcel.inc_index.size
  for i = 0, nSizeXinfa - 1 do
    local pNextExcel = bo2.gv_skill_preview_tree_view:find(pExcel.inc_index[i])
    if pNextExcel ~= nil and pNextExcel.tree_level == ciTreeLevel2 then
      local app_item = pParent:item_append()
      if app_item ~= nil then
        app_item.obtain_title:load_style(item_uri, item_style)
        local desc_text = app_item:search(L("desc_label"))
        local card_xinfa = app_item:search(L("xinfa_card"))
        desc_text.text = pNextExcel.inc_text
        card_xinfa.excel_id = pNextExcel.inc_data
        on_init_skill_preview_list_level_2_item(app_item, pNextExcel, btn_page)
        app_item.expanded = false
      end
    end
  end
end
function on_init_skill_preview_list_level_2_item(pParent, pExcel, btn_page)
  if pExcel.inc_index == nil then
    return
  end
  local nSizeSkill = pExcel.inc_index.size
  for i = 0, nSizeSkill - 1 do
    local pNextExcel = bo2.gv_skill_preview_tree_view:find(pExcel.inc_index[i])
    if pNextExcel ~= nil and pNextExcel.tree_level == ciTreeLevel3 then
      local child_item = pParent:item_append()
      if child_item ~= nil then
        child_item.obtain_title:load_style(item_uri, child_item_style)
        local item_text = child_item:search(L("item_text"))
        item_text.text = pNextExcel.inc_text
        local icon = ui.get_skill_icon(pNextExcel.inc_data)
        local skill_card = child_item:search(L("skill_image"))
        skill_card.image = icon.uri
        if pNextExcel.inc_index.size > 0 then
          local set_item = child_item:search(L("child_panel"))
          local idx = pNextExcel.inc_index[0]
          set_item.var:set(set_var_skill_id, idx)
          g_reverse_link[idx] = {
            btn_page = btn_page,
            btn_level_one = pParent:search(L("skill_list_item")),
            btn_level_two = set_item
          }
        end
      end
    end
  end
end
function set_level_one_panel(panel, vis)
  if panel == nil then
    return
  end
  local lb_desc = panel:search(L("desc_label"))
  local highlight_card = panel:search(L("card_xinfa_highlight"))
  local highlight_fader = panel:search(L("fader"))
  panel.expanded = vis
  highlight_card.visible = vis
  highlight_fader.visible = vis
  if vis == true then
    lb_desc.color = init_font_color
    panel:scroll_to_visible()
  else
    lb_desc.color = select_font_color
  end
end
function set_level_two_panel(panel, vis)
  if panel == nil then
    return
  end
  local lb_desc = panel:search(L("item_text"))
  local highlight_card = panel:search(L("card_skill_highlight"))
  local highlight_fader = panel:search(L("skill_fader"))
  local select_btn = panel:search(L("select_btn"))
  panel.expanded = vis
  highlight_card.visible = vis
  highlight_fader.visible = vis
  select_btn.visible = vis
  if vis == true then
    lb_desc.color = init_font_color
  else
    lb_desc.color = select_font_color
  end
end
function on_list_item_card_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    on_list_item_mouse(card.parent.parent, msg, pos, wheel)
  end
end
function on_list_item_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local pParent = panel.parent
    ui_skill_preview.on_canel_auto_play()
    ui_skill_preview.on_canel_auto_play_all_skill()
    if pParent ~= g_select_xinfa then
      set_level_one_panel(g_select_xinfa, false)
      set_level_one_panel(pParent, true)
      g_select_xinfa = pParent
    elseif g_select_xinfa ~= nil then
      set_level_one_panel(g_select_xinfa, false)
      g_select_xinfa.expanded = false
      g_select_xinfa = nil
    end
  end
end
function on_list_item_child_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local pParent = panel.parent
    if pParent ~= g_select_skill then
      set_level_two_panel(g_select_skill, false)
      set_level_two_panel(pParent, true)
      g_select_skill = pParent
      ui_skill_preview.on_canel_auto_play()
      ui_skill_preview.on_canel_auto_play_all_skill()
    end
  end
end
function on_reverse_link_select(iIdx)
  if g_reverse_link == nil or g_reverse_link[iIdx] == nil then
    return
  end
  local refReverseLink = g_reverse_link[iIdx]
  refReverseLink.btn_page.press = true
  local bActiveAllSkill = on_may_active_auto_play_all_skill()
  if g_select_xinfa ~= refReverseLink.btn_level_one.parent then
    on_list_item_mouse(refReverseLink.btn_level_one, ui.mouse_lbutton_click, nil, nil)
  end
  on_list_item_child_mouse(refReverseLink.btn_level_two, ui.mouse_lbutton_click, nil, nil)
  if bActiveAllSkill == true then
    ui_skill_preview.on_active_auto_play_all_skill()
  end
end
function on_table_btn_click(btn, vis)
  if vis == true then
    btn.dx = 21
    btn:search(L("lb_name")).visible = false
    btn.parent:tune_x(btn)
  elseif vis ~= true then
    btn.dx = 21
    btn:search(L("lb_name")).visible = false
    btn.parent:tune_x(btn)
  end
end
function on_pro_skill_preview()
  on_init_skill_preview_list()
  local bVisible = false
  local pro = bo2.player:get_atb(bo2.eAtb_Cha_Profession)
  for i = 0, bo2.gv_profession_list.size - 1 do
    local excel = bo2.gv_profession_list:get(i)
    if excel and excel.id == pro then
      local icareer = bo2.gv_profession_list:get(i).career
      if icareer == 1 then
        icareer = 2
      elseif icareer == 3 then
        icareer = 1
      elseif icareer == 2 then
        icareer = 3
      end
      local tab_name = sys.format(L("skill_preview_tree_page%d"), icareer)
      ui_widget.ui_tab.show_page(ui_skill_preview.w_main_skill_tree, tab_name, true)
      bVisible = true
      ui_skill_preview.revert_group_skill_id()
      break
    end
  end
  if bVisible ~= false then
    ui_skill_preview.w_skill_preview.visible = true
    skill_preview_hello_world.visible = true
    skill_preview_loading.visible = false
    skill_preview_view.visible = false
  end
end
