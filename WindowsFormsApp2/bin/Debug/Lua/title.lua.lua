local g_portrait_path = "$icon/portrait/"
local l_last_titleID = 0
local g_title_list = {}
local ci_aword_new_title_msg_id = 1582
local ci_use_title_msg_id = 1583
local ci_update_title_msg_id = 1584
local cvalue_color_red = L("FFFF0000")
local cvalue_color_green = L("FF00FF00")
local opened_color = ui.make_color("00ff00")
local unopened_color = ui.make_color("808080")
local bIsShowAllTitle = true
local g_bItemListDirty = true
local g_bItemDelID = 0
local title_category_table = bo2.gv_title_category
local cur_category
local g_view_title_trait = false
local g_total_title = 0
local gs_table = {}
local trait_table = {}
local g_refresh_title_table = true
local g_last_player
function set_data_dirty()
  g_refresh_title_table = true
  g_bItemListDirty = true
end
local send_title_pack = function(iExcelID)
  local check_may_use_title = function(iExcelID)
    local obj = bo2.player
    if obj == nil then
      return false
    end
    if obj:get_flag_int32(bo2.ePlayerFlagInt32_UsingTitle) ~= iExcelID then
      return true
    end
    if iExcelID == 0 then
      return false
    end
    local text = sys.format(ui.get_text("im|title_use_same_title"))
    ui_tool.note_insert(text, L("FFFF0000"))
    return false
  end
  if check_may_use_title(iExcelID) ~= true then
    return
  end
  local v = sys.variant()
  v:set(packet.key.item_key, iExcelID)
  bo2.send_variant(packet.eCTS_UI_Title, v)
end
local get_title_full_name = function(pExcelData)
  if pExcelData._sp_flag == 0 then
    return pExcelData._name
  else
    local player = bo2.player
    if sys.check(player) ~= true then
      return pExcelData._name
    end
    local name = player:get_title_name(pExcelData.id)
    if name.size <= 1 then
      return pExcelData._name
    end
    return name
  end
end
function on_title_init(ctrl)
  if sys.check(btn_check_title) then
    btn_check_title.check = false
  end
  l_last_titleID = 0
  g_bItemDelID = 0
  g_title_list = {}
  set_data_dirty()
  cur_category = nil
end
function on_self_title_obvisible(w, vis)
  if vis then
    update_self_title_info()
  end
end
function on_click_close_title_trait()
  on_view_trait_btn(true)
  g_view_title_trait = false
  view_mutex_page()
end
function on_click_view_title_trait()
  on_view_trait_btn(false)
  g_view_title_trait = true
  ui_personal.ui_title.w_title_trait.visible = true
  view_mutex_page()
end
function view_mutex_page()
  w_title_trait.visible = g_view_title_trait
  w_title_page.visible = not g_view_title_trait
end
function on_view_trait_btn(vis)
  ui_personal.w_view_title_trait.visible = vis
end
function get_trait_gs(id, value, v)
  local excel = {}
  excel[id] = value
  local gs = ui_tool.ctip_calculate_item_rank(excel, nil, 2)
  return gs
end
function add_grade(pExcelData, v)
  local excel = {}
  excel.datas = pExcelData._attribute
  return ui_tool.ctip_calculate_item_rank(excel, nil, 1)
end
function get_my_title_data()
  local self_count = 0
  local gs_score = 0
  gs_table = {}
  trait_table = {}
  for i, v in pairs(g_title_list) do
    if v ~= nil then
      local excel_id = v.excel_id
      local pExcelData = bo2.gv_title_list:find(excel_id)
      if pExcelData ~= nil and pExcelData.hidden ~= 1 then
        self_count = self_count + 1
        table.insert(gs_table, pExcelData)
      end
    end
  end
  for i, v in pairs(gs_table) do
    if sys.check(v) then
      gs_score = gs_score + add_grade(v, 1)
      local _insert = false
      local t_size = v._attribute.size
      for m = 0, t_size - 1 do
        local t_value = v._attribute[m]
        local trait_excel = bo2.gv_trait_list:find(t_value)
        if sys.check(trait_excel) and trait_excel.tp == bo2.eTraitListType_Modifier then
          local modify_id = trait_excel.modify_id
          local modify_value = trait_excel.modify_value
          if trait_table[modify_id] == nil then
            trait_table[modify_id] = {}
            trait_table[modify_id].tab = {}
            trait_table[modify_id].value = 0
          end
          table.insert(trait_table[modify_id].tab, v)
          trait_table[modify_id].value = trait_table[modify_id].value + modify_value
        end
      end
    end
  end
  return self_count, gs_score
end
function get_total_title()
  if g_total_title ~= 0 and g_total_title ~= nil then
    return g_total_title
  end
  g_total_title = 0
  local group_tab = {}
  local size = bo2.gv_title_list.size
  for i = 0, size - 1 do
    local pExcelData = bo2.gv_title_list:get(i)
    if pExcelData.id > 10000 then
      break
    end
    if pExcelData._sp_flag ~= 1 and pExcelData.hidden ~= 1 and group_tab[pExcelData._groupId] == nil then
      g_total_title = g_total_title + 1
      group_tab[pExcelData._groupId] = 1
    end
  end
  return g_total_title
end
function update_self_title_info()
  if g_refresh_title_table ~= true then
    return
  end
  local mtf_data = {}
  mtf_data.count, mtf_data.gs_score = get_my_title_data()
  mtf_data.total = get_total_title()
  update_self_title_mtf(mtf_data)
  update_self_title_trait_list()
  g_refresh_title_table = false
end
local c_desc = L("<c+:d3a75e>")
local c_value = L("<c:00FF00>")
local c_left = L("<a+:left>")
local c_right = L("<a+:right>")
local c_mid = L("<a+:mid>")
function update_self_title_mtf(mtf_data)
  local stk = sys.stack()
  local new_line = L("\n")
  stk:push(c_left)
  stk:push(c_desc)
  stk:push(ui.get_text("personal|acquire_title_count_desc"))
  local function push_desc_format()
    stk:push(new_line)
    stk:push(c_left)
    stk:push(c_desc)
  end
  local function push_value_format()
    stk:push(new_line)
    stk:push(c_right)
    stk:push(c_value)
  end
  push_value_format()
  if mtf_data.count > mtf_data.total then
    mtf_data.count = mtf_data.total
  end
  local mtf = ui_widget.merge_mtf(mtf_data, ui.get_text("personal|acquire_title_count"))
  stk:push(mtf)
  push_desc_format()
  stk:push(ui.get_text("personal|title_gs"))
  push_value_format()
  stk:push(mtf_data.gs_score)
  rb_self_title_desc.mtf = stk.text
end
function update_self_title_trait_list()
  local root = ui_personal.ui_title.w_title_trait_list.root
  root:item_clear()
  local style_uri = L("$gui/frame/personal/title.xml")
  local style_name_g = L("title_trait_item")
  local function insert_trait_item(v, _id)
    local item_g = root:item_append()
    item_g:load_style(style_uri, style_name_g)
    local rb_trait = item_g:search("rb_trait")
    rb_trait.mtf = sys.format(L("<c+:00FF00>%s"), v.trait_text)
    rb_trait.svar = {id = _id}
  end
  for i, v in pairs(trait_table) do
    v.trait_text = ui_tool.ctip_trait_text_ex(i, v.value, c_left, c_right)
    v.trait_gs = get_trait_gs(i, v.value)
    insert_trait_item(v, i)
  end
end
function on_title_obvisible(w, vis)
  if vis then
    if g_view_title_trait == true then
      on_view_trait_btn(false)
    else
      on_view_trait_btn(true)
    end
    view_mutex_page()
  else
    on_view_trait_btn(false)
  end
end
function modify_title_text(pExcelData)
  local stk = sys.mtf_stack()
  local text = sys.format(L("<a+:mid>%s<a->"), get_title_full_name(pExcelData))
  local cur_title = ui_widget.merge_mtf({title = text}, ui.get_text("personal|current_title"))
  stk:push(cur_title)
  gx_player_info:search("cur_title").mtf = sys.format(ui.get_text("personal|current_title"), text)
end
function on_title_visible(w, vis)
  if vis then
    local player = bo2.player
    if player == nil then
      return
    end
    gx_player_info:search("level").text = sys.format("Lv%d", player:get_atb(bo2.eAtb_Level))
    local portrait_id = player:get_flag_int32(bo2.ePlayerFlagInt32_Portrait)
    gx_player_info:search("portrait").image = g_portrait_path .. bo2.gv_portrait:find(portrait_id).icon .. ".png"
    local pro = player:get_atb(bo2.eAtb_Cha_Profession)
    local n = bo2.gv_profession_list:find(pro)
    local dmg = n.damage
    local f = gx_player_info:search("job")
    if dmg == 1 then
      f.xcolor = "FF608CD9"
    else
      f.xcolor = "FFEE5544"
    end
    f.image = sys.format("$image/personal/32x32/%d.png|0,0,27,30", n.career)
    local pExcelData = bo2.gv_title_list:find(l_last_titleID)
    if pExcelData ~= nil then
      modify_title_text(pExcelData)
    else
      gx_player_info:search("cur_title").text = ui.get_text("im|title_none")
    end
    if g_bItemListDirty then
      update_title_list()
    end
  end
end
function on_title_trait_item_tip(tip)
  local ctrl = tip.owner
  local stk = sys.mtf_stack()
  local rb_trait = ctrl:search("rb_trait")
  local empty = true
  if sys.check(rb_trait) and rb_trait.svar ~= nil and trait_table ~= nil then
    local svar = rb_trait.svar
    local m_id = svar.id
    local v_tab = trait_table[m_id]
    for i, excel in pairs(v_tab.tab) do
      if sys.check(excel) then
        local e_trait_size = excel._attribute.size
        for i_count = 0, e_trait_size - 1 do
          local t_data = excel._attribute[i_count]
          local trait_excel = bo2.gv_trait_list:find(t_data)
          if sys.check(trait_excel) and trait_excel.tp == bo2.eTraitListType_Modifier and trait_excel.modify_id == m_id then
            local trait_value = ui_tool.ctip_trait_text_ex(m_id, trait_excel.modify_value)
            if empty == false then
              ui_tool.ctip_push_newline(stk)
            end
            local title_name = sys.format(L("<%s>"), get_title_full_name(excel))
            ui_tool.ctip_push_text(stk, title_name, L("d3a75e"), c_left)
            stk:raw_push(L("\n"))
            local lb_title_value = sys.format(L("<a+:right><lb:plain,14,half,00FF00|%s>"), trait_value)
            stk:raw_push(lb_title_value)
            empty = false
          end
        end
      end
    end
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("personal|title_gs_tip"), L("d3a75e"), c_left)
    stk:raw_push(L("<space:2.0>"))
    local lb_title_value = sys.format(L("<a+:right><lb:plain,14,half,00FF00|%s>"), v_tab.trait_gs)
    stk:raw_push(lb_title_value)
  end
  if empty == true then
    return
  end
  ui_tool.ctip_show(ctrl, stk)
end
function on_title_trait_item_mouse(btn, msg)
  local bg_fold = btn:search("bg_fold")
  if bg_fold == nil then
    return
  end
  if msg == ui.mouse_inner then
    bg_fold.visible = true
  end
  if msg == ui.mouse_outer then
    bg_fold.visible = false
  end
end
function on_title_name_mouse(btn, msg)
  local bg_fold = btn:search("bg_fold")
  if bg_fold == nil then
    return
  end
  if msg == ui.mouse_inner then
    bg_fold.visible = true
  end
  if msg == ui.mouse_outer then
    bg_fold.visible = false
  end
  if msg == ui.mouse_lbutton_up then
    local p = btn
    while true do
      if p == nil or sys.is_type(p, "ui_tree_item") then
        break
      end
      p = p.parent
    end
    if p == nil then
      return
    end
    p.expanded = not p.expanded
  end
  if msg == ui.mouse_rbutton_up then
    local p = btn
    while true do
      if p == nil or sys.is_type(p, "ui_tree_item") then
        break
      end
      p = p.parent
    end
    if p == nil then
      return
    end
    if p.svar.active == true then
      send_title_pack(p.svar.titleID)
    end
  end
end
function on_click_btn_auto_title(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 1)
  bo2.send_variant(packet.eCTS_UI_Title, v)
end
function on_click_btn_show_title(btn)
  if btn.check ~= false then
    if l_last_titleID ~= 0 then
      send_title_pack(l_last_titleID)
    else
      btn.check = false
      local text = sys.format(ui.get_text("personal|no_title_show"))
      ui_tool.note_insert(text, cvalue_color_red)
    end
  else
    send_title_pack(0)
  end
end
function insert_title_item(pExcelData, bIsActive, bIsOver, v)
  if pExcelData.hidden == 1 then
    return
  end
  local root = w_title_tree.root
  local style_uri = L("$gui/frame/personal/title.xml")
  local style_name_g = L("title_name")
  local item_g = root:item_append()
  item_g:load_style(style_uri, style_name_g)
  local lb_title_name = item_g:search("title_name")
  local c_title_color = "d3a75e"
  local c_opened_color = opened_color
  local using = false
  if l_last_titleID ~= 0 and l_last_titleID == pExcelData.id then
    local ic_id = pExcelData._color
    local id_16x = sys.format(L("%x"), ic_id)
    local loot_excel = bo2.gv_lootlevel:find(id_16x.v_int)
    if loot_excel ~= nil then
      c_opened_color = ui.make_color(loot_excel.color)
      c_title_color = loot_excel.color
      using = true
    end
  end
  local stk_name = sys.mtf_stack()
  local txt = sys.format(L("<c+:%s>"), c_title_color)
  stk_name:raw_push(txt)
  stk_name:push(L("<"))
  stk_name:raw_push(get_title_full_name(pExcelData))
  stk_name:push(L(">"))
  lb_title_name.mtf = stk_name.text
  local dest_day = 0
  if v ~= nil and v.limit ~= 0 then
    local os_time = ui_main.get_os_time()
    local dest_second = os.difftime(v.limit, os_time)
    dest_day = dest_second / 86400
  end
  local wnd_title_status = item_g:search("title_status")
  if bIsActive then
    local title_status
    local status_color = c_opened_color
    if using ~= false then
      title_status = ui.get_text("personal|using")
    elseif dest_day ~= 0 then
      if dest_day >= 4 then
        status_color = ui.make_color(L("008de6"))
        title_status = ui.get_text("personal|time_limit")
      else
        status_color = ui.make_color(L("c80000"))
        title_status = ui_widget.merge_mtf({day = dest_day}, ui.get_text("personal|title_time"))
      end
    else
      title_status = ui.get_text("personal|opened")
    end
    wnd_title_status.text = title_status
    wnd_title_status.color = status_color
  else
    if bIsOver == true then
      wnd_title_status.text = ui.get_text("personal|expired")
    else
      wnd_title_status.text = ui.get_text("personal|unopened")
    end
    item_g:search("title_status").color = unopened_color
  end
  local nSizeTrait = pExcelData._attribute.size
  for i = 0, nSizeTrait - 1 do
    local trait_des = ui_tool.ctip_trait_text(pExcelData._attribute[i])
    local attribute = item_g:search("attribute_" .. i)
    if attribute then
      attribute.visible = true
      attribute.text = trait_des
      if bIsActive then
        attribute.color = c_opened_color
      else
        attribute.color = unopened_color
      end
    else
      break
    end
  end
  local child_item_uri = L("$frame/personal/title.xml")
  local child_item_style = L("title_detail")
  local child_item = item_g:item_append()
  child_item:load_style(child_item_uri, child_item_style)
  local detail_text
  if bIsActive == true then
    detail_text = pExcelData.detail_desc
  else
    detail_text = pExcelData.access_methods
  end
  local stk = sys.mtf_stack()
  stk:raw_push(detail_text)
  if v ~= nil and v.limit ~= 0 then
    stk:raw_push(L("\n"))
    local mtf = {}
    mtf.year = os.date("%Y", v.limit)
    mtf.month = os.date("%m", v.limit)
    mtf.day = os.date("%d", v.limit)
    mtf.hour = os.date("%H", v.limit)
    mtf.minute = os.date("%M", v.limit)
    local txt = ui_widget.merge_mtf(mtf, ui.get_text("personal|title_end_time"))
    stk:raw_push(txt)
  end
  child_item:search("detail_box").mtf = stk.text
  child_item.dx = 400
  child_item:tune_y("detail_box")
  child_item.title.dy = child_item.dy + 45
  item_g.expanded = false
  item_g.svar = {
    titleID = pExcelData.id,
    active = bIsActive
  }
end
function update_title()
  if bo2.player ~= nil then
    if g_bItemDelID ~= 0 and g_bItemDelID == l_last_titleID then
      l_last_titleID = 0
    end
    local iTitleIdx = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_UsingTitle)
    if iTitleIdx == 0 then
      btn_check_title.check = false
      iTitleIdx = l_last_titleID
      gx_player_info:search("cur_title").text = ui.get_text("im|title_none")
    else
      btn_check_title.check = true
    end
    local pExcelData = bo2.gv_title_list:find(iTitleIdx)
    if pExcelData ~= nil then
      modify_title_text(pExcelData)
      l_last_titleID = iTitleIdx
      g_bItemListDirty = true
    end
    if g_bItemListDirty then
      update_title_list()
    end
  end
end
function update_title_list(category)
  w_title_tree.root:item_clear()
  for i, v in pairs(g_title_list) do
    local excel_id = v.excel_id
    local pExcelData = bo2.gv_title_list:find(excel_id)
    if pExcelData ~= nil and (category == nil or pExcelData.category == category) then
      insert_title_item(pExcelData, true, nil, v)
    end
  end
  local my_sort = function(item1, item2)
    if item1.svar.titleID < item2.svar.titleID then
      return -1
    else
      return 1
    end
  end
  w_title_tree.root:item_sort(my_sort)
  if bIsShowAllTitle then
    local size = bo2.gv_title_list.size
    for i = 0, size - 1 do
      local pExcelData = bo2.gv_title_list:get(i)
      if pExcelData.id > 10000 then
        break
      end
      if pExcelData._sp_flag == 0 then
        if g_title_list[pExcelData._groupId] == nil then
          if category == nil or pExcelData.category == category then
            insert_title_item(pExcelData, false)
          end
        elseif g_title_list[pExcelData._groupId].excel_id ~= pExcelData.id and (category == nil or pExcelData.category == category) then
          insert_title_item(pExcelData, false, pExcelData._level < g_title_list[pExcelData._groupId].level)
        end
      end
    end
  end
  local title_text = ui.get_text("personal|title_info")
  if category ~= nil then
    local category_excel = title_category_table:find(category)
    if category_excel ~= nil then
      title_text = sys.format("%s - %s", title_text, category_excel.name)
    end
  end
  w_title_txt.text = title_text
  cur_category = category
  w_title_tree.scroll = 0
  g_bItemListDirty = false
end
function on_title_sort(btn)
  local title_items = {}
  local category_size = title_category_table.size
  for i = 0, category_size - 1 do
    do
      local category = title_category_table:get(i)
      if category ~= nil then
        table.insert(title_items, {
          text = category.name,
          callback = function()
            update_title_list(category.id)
          end
        })
      end
    end
  end
  table.insert(title_items, {
    text = ui.get_text("tip|channel_all"),
    callback = function()
      update_title_list()
    end
  })
  local data = {
    items = title_items,
    event = function(item)
      local callback = item.callback
      callback(info)
    end,
    auto_size = true,
    dx = 100,
    dy = 50,
    source = btn,
    consult = btn,
    popup = "y2x2"
  }
  ui_tool.show_menu(data)
end
function on_title_hide(btn)
  bIsShowAllTitle = not bIsShowAllTitle
  update_title_list(cur_category)
end
function on_title_hide_tip(tip)
  local ctrl = tip.owner
  local stk = sys.mtf_stack()
  if bIsShowAllTitle then
    stk:push(ui.get_text("personal|hide_no_open"))
  else
    stk:push(ui.get_text("personal|show_all"))
  end
  ui_tool.ctip_show(ctrl, stk)
end
function on_title_item_tip(tip)
  local ctrl = tip.owner
  local stk = sys.mtf_stack()
  ui_tool.ctip_push_text(stk, ui.get_text("personal|left_check_detail"), ui_tool.cs_tip_color_operation)
  if ctrl.parent.parent.svar ~= nil and ctrl.parent.parent.svar.active then
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("personal|right_use_title"), ui_tool.cs_tip_color_operation)
  end
  ui_tool.ctip_show(ctrl, stk)
end
function on_modify_title(cmd, data)
  local iExcelID = data:get(packet.key.item_key).v_int
  local pExcelData = bo2.gv_title_list:find(iExcelID)
  if pExcelData == nil then
    return
  end
  g_bItemDelID = 0
  local iDel = data:get(packet.key.deal_begin).v_int
  local iLoading = data:get(packet.key.cha_load_type).v_int
  if iDel ~= 0 then
    if g_title_list[pExcelData._groupId] ~= nil then
      g_title_list[pExcelData._groupId] = nil
      set_data_dirty()
      g_bItemDelID = pExcelData._groupId
    end
    return
  end
  if g_title_list[pExcelData._groupId] ~= nil and g_title_list[pExcelData._groupId].excel_id ~= iExcelID and iLoading ~= 1 then
    local old_title_id = g_title_list[pExcelData._groupId].excel_id
    local pOldExcel = bo2.gv_title_list:find(old_title_id)
    if pOldExcel ~= nil then
      local msg_title = bo2.gv_text:find(ci_update_title_msg_id).text
      local wstr_msg = ui_widget.merge_mtf({
        old_title_name = get_title_full_name(pOldExcel),
        title_name = get_title_full_name(pExcelData)
      }, msg_title)
      if wstr_msg ~= nil then
        ui_tool.note_insert(wstr_msg, cvalue_color_green)
      end
    end
  end
  if iLoading ~= 1 then
    local msg_title = bo2.gv_text:find(ci_aword_new_title_msg_id).text
    local wstr_msg = ui_widget.merge_mtf({
      title_name = get_title_full_name(pExcelData)
    }, msg_title)
    if wstr_msg ~= nil then
      ui_tool.note_insert(wstr_msg, cvalue_color_green)
    end
  end
  local time_limit = 0
  if data:has(packet.key.total_time) then
    time_limit = data:get(packet.key.total_time).v_int
  end
  g_title_list[pExcelData._groupId] = {
    excel_id = iExcelID,
    level = pExcelData._level,
    limit = time_limit
  }
  set_data_dirty()
end
function update_auto_btn()
  local iFlag = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_DisableAutoUseTitle)
  if iFlag == 1 then
    btn_auto_title.check = false
  else
    btn_auto_title.check = true
  end
end
function on_self_enter(obj, msg)
  if g_last_player == nil or sys.check(g_last_player) ~= true or g_last_player ~= obj then
    g_refresh_title_table = true
    g_last_player = obj
  end
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_UsingTitle, update_title, "ui_personal.ui_title.update_title")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_DisableAutoUseTitle, update_auto_btn, "ui_personal.ui_title.update_auto_btn")
  update_auto_btn()
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_personal.ui_title.on_self_enter")
function run()
  on_self_enter(bo2.player)
end
function t()
  on_title_init()
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_Title, on_modify_title, "ui_personal.ui_title:on_signal")
function check_title_is_active(title_id)
  if title_id == nil then
    return false
  end
  local pExcelData = bo2.gv_title_list:find(title_id)
  if pExcelData == nil then
    return false
  end
  if g_title_list[pExcelData._groupId] and g_title_list[pExcelData._groupId].excel_id == title_id then
    return true
  end
  return false
end
function check_title_is_active_lv_up(title_id)
  if title_id == nil then
    return false
  end
  local pExcelData = bo2.gv_title_list:find(title_id)
  if pExcelData == nil then
    return false
  end
  local unt = g_title_list[pExcelData._groupId]
  if unt == nil then
    return false
  end
  if unt.excel_id == title_id then
    return true, true
  end
  return unt.level >= pExcelData._level
end
function get_active_title(title_id)
  if title_id == nil then
    return nil
  end
  local pExcelData = bo2.gv_title_list:find(title_id)
  if pExcelData == nil then
    return nil
  end
  return g_title_list[pExcelData._groupId]
end
