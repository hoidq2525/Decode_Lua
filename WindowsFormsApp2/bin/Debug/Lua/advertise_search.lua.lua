g_search_data = {}
g_search_var = {}
sel_btn_nil_id = -1
type_advance_search = 100
local MAX_HOBBYNUM_EACHROW = 5
create_sel_data = {}
on_item_select = {}
local hobby_max_num = 3
local hobby_selected_list = {}
local is_advance_search_clearing = false
function create_nil_sel(ctrl, tab, type)
  ui_widget.ui_combo_box.append(ctrl, {
    id = sel_btn_nil_id,
    text = ui.get_text("advertise|no_search"),
    search_type = type,
    search_var = nil,
    tab_id = tab
  })
end
create_sel_data[bo2.ePersonalsSearchType_Identity] = function(ctrl, tab)
  for i = bo2.Guild_Punish, bo2.Guild_Leader do
    local excel = bo2.gv_guild_auth:find(i)
    if excel ~= nil then
      ui_widget.ui_combo_box.append(ctrl, {
        id = excel.id,
        text = excel.remark,
        search_type = bo2.ePersonalsSearchType_Identity,
        search_var = excel.id,
        tab_id = tab
      })
    end
  end
end
create_sel_data[bo2.ePersonalsSearchType_Provinces] = function(ctrl, tab)
  for i = 2, 50 do
    local excel = bo2.gv_im_info:find(i)
    if excel ~= nil then
      ui_widget.ui_combo_box.append(ctrl, {
        id = excel.id,
        text = excel.name,
        search_type = bo2.ePersonalsSearchType_Provinces,
        search_var = excel.id,
        tab_id = tab
      })
    end
  end
end
create_sel_data[bo2.ePersonalsSearchType_Region] = function(ctrl, tab)
  local parent = ctrl.parent.parent
  local svar = parent.svar
  svar[bo2.ePersonalsSearchType_Region] = ctrl
end
create_sel_data[bo2.ePersonalsSearchType_Level] = function(ctrl, tab)
  for i = 2, 30 do
    local excel = bo2.gv_personals_search:find(i)
    if excel ~= nil then
      local par_table = {}
      par_table[1] = excel.pram[0]
      par_table[2] = excel.pram[1]
      ui_widget.ui_combo_box.append(ctrl, {
        id = excel.id,
        text = excel.name,
        par = par_table,
        search_type = bo2.ePersonalsSearchType_Level,
        search_var = par_table,
        tab_id = tab
      })
    end
  end
end
create_sel_data[bo2.ePersonalsSearchType_Profession] = function(ctrl, tab)
  local size = bo2.gv_profession_list.size
  for i = 0, size - 1 do
    local excel = bo2.gv_profession_list:get(i)
    if excel ~= nil then
      ui_widget.ui_combo_box.append(ctrl, {
        id = excel.id,
        text = excel.name,
        search_type = bo2.ePersonalsSearchType_Profession,
        search_var = excel.id,
        tab_id = tab
      })
    end
  end
end
create_sel_data[bo2.ePersonalsSearchType_Sex] = function(ctrl, tab)
  for i = 81, 83 do
    local excel = bo2.gv_im_info:find(i)
    if excel ~= nil then
      ui_widget.ui_combo_box.append(ctrl, {
        id = excel.id,
        text = excel.name,
        search_type = bo2.ePersonalsSearchType_Sex,
        search_var = excel.id,
        tab_id = tab
      })
    end
  end
end
create_sel_data[bo2.ePersonalsSearchType_MasterLevel] = function(ctrl, tab)
  for i = 0, 5 do
    local get_text_str = "sociality|masterlevel_" .. i
    local masterlevel_text = ui.get_text(get_text_str)
    ui_widget.ui_combo_box.append(ctrl, {
      id = i,
      text = masterlevel_text,
      search_type = bo2.ePersonalsSearchType_MasterLevel,
      search_var = i,
      tab_id = tab
    })
  end
end
create_sel_data[bo2.ePersonalsSearchType_GuildProportion] = function(ctrl, tab)
  for i = 31, 70 do
    local excel = bo2.gv_personals_search:find(i)
    if excel ~= nil then
      local par_table = {}
      par_table[1] = excel.pram[0]
      par_table[2] = excel.pram[1]
      ui_widget.ui_combo_box.append(ctrl, {
        id = excel.id,
        text = excel.name,
        par = par_table,
        search_type = bo2.ePersonalsSearchType_GuildProportion,
        search_var = par_table,
        tab_id = tab
      })
    end
  end
end
create_sel_data[bo2.ePersonalsSearchType_GuildLevel] = function(ctrl)
  for i = 71, 100 do
    local excel = bo2.gv_personals_search:find(i)
    if excel ~= nil then
      ui_widget.ui_combo_box.append(ctrl, {
        id = excel.id,
        text = excel.name,
        search_type = bo2.ePersonalsSearchType_GuildLevel,
        search_var = excel.pram[0],
        tab_id = tab
      })
    end
  end
end
create_sel_data[bo2.ePersonalsSearchType_GuildPopularity] = function(ctrl, tab)
  for i = 101, 130 do
    local excel = bo2.gv_personals_search:find(i)
    if excel ~= nil then
      local par_table = {}
      par_table[1] = excel.pram[0]
      par_table[2] = excel.pram[1]
      ui_widget.ui_combo_box.append(ctrl, {
        id = excel.id,
        text = excel.name,
        par = par_table,
        search_type = bo2.ePersonalsSearchType_GuildPopularity,
        search_var = par_table,
        tab_id = tab
      })
    end
  end
end
create_sel_data[bo2.ePersonalsSearchType_GuildDev] = function(ctrl, tab)
  for i = 131, 160 do
    local excel = bo2.gv_personals_search:find(i)
    if excel ~= nil then
      local par_table = {}
      par_table[1] = excel.pram[0]
      par_table[2] = excel.pram[1]
      ui_widget.ui_combo_box.append(ctrl, {
        id = excel.id,
        text = excel.name,
        par = par_table,
        search_type = bo2.ePersonalsSearchType_GuildDev,
        search_var = par_table,
        tab_id = tab
      })
    end
  end
end
create_sel_data[bo2.ePersonalsSearchType_Constellation] = function(ctrl, tab)
  for i = 61, 73 do
    local excel = bo2.gv_im_info:find(i)
    if excel ~= nil then
      local par_table = {}
      ui_widget.ui_combo_box.append(ctrl, {
        id = excel.id,
        text = excel.name,
        search_type = bo2.ePersonalsSearchType_Constellation,
        search_var = excel.id,
        tab_id = tab
      })
    end
  end
end
create_sel_data[bo2.ePersonalsSearchType_Age] = function(ctrl, tab)
  for i = 51, 58 do
    local excel = bo2.gv_im_info:find(i)
    if excel ~= nil then
      local par_table = {}
      ui_widget.ui_combo_box.append(ctrl, {
        id = excel.id,
        text = excel.name,
        search_type = bo2.ePersonalsSearchType_Age,
        search_var = excel.id,
        tab_id = tab
      })
    end
  end
end
create_sel_data[bo2.ePersonalsSearchType_Married] = function(ctrl, tab)
  for i = 161, 163 do
    local excel = bo2.gv_personals_search:find(i)
    if excel ~= nil then
      ui_widget.ui_combo_box.append(ctrl, {
        id = excel.id,
        text = excel.name,
        search_type = bo2.ePersonalsSearchType_Married,
        search_var = excel.pram[0],
        tab_id = tab
      })
    end
  end
end
local function create_hobby_selection(main)
  local uri = "$frame/advertise/advance_search.xml"
  local row_style = "hobby_row"
  local hobby_item_style = "hobby_item_cell"
  w_hobby_row_list:item_clear()
  local cur_row = w_hobby_row_list:item_append()
  cur_row:load_style(uri, row_style)
  local hobby_num_eachrow = 0
  local search_data = g_search_data[type_advance_search]
  search_data[bo2.ePersonalsSearchType_Hobby] = {}
  search_data[bo2.ePersonalsSearchType_Hobby].ctrl = {}
  for i = 101, 200 do
    local hobby_excel_line = bo2.gv_im_info:find(i)
    if hobby_excel_line == nil then
      break
    end
    local ctrl = ui.create_control(cur_row, "panel")
    ctrl:load_style(uri, hobby_item_style)
    local hobby_text = hobby_excel_line.name
    local name = ctrl:search("name")
    name.text = hobby_text
    local check_btn = ctrl:search("check_btn")
    check_btn.var = i
    search_data[bo2.ePersonalsSearchType_Hobby].ctrl[i] = check_btn
    hobby_num_eachrow = hobby_num_eachrow + 1
    if hobby_num_eachrow == MAX_HOBBYNUM_EACHROW then
      cur_row = w_hobby_row_list:item_append()
      cur_row:load_style(uri, row_style)
      hobby_num_eachrow = 0
    end
  end
end
function create_search_variant(type, search_data)
  local search_v = sys.variant()
  if type == bo2.ePersonalsSearchType_Identity or type == bo2.ePersonalsSearchType_Provinces or type == bo2.ePersonalsSearchType_Region or type == bo2.ePersonalsSearchType_Profession or type == bo2.ePersonalsSearchType_Sex or type == bo2.ePersonalsSearchType_MasterLevel or type == bo2.ePersonalsSearchType_GuildLevel or type == bo2.ePersonalsSearchType_Constellation or type == bo2.ePersonalsSearchType_Age or type == bo2.ePersonalsSearchType_Married or type == bo2.ePersonalsSearchType_GuildName then
    search_v = search_data
  elseif type == bo2.ePersonalsSearchType_Level or type == bo2.ePersonalsSearchType_GuildProportion or type == bo2.ePersonalsSearchType_GuildPopularity or type == bo2.ePersonalsSearchType_GuildDev then
    if search_data == nil then
      search_v = search_data
    else
      search_v:set(packet.key.sociality_personals_search_min, search_data[1])
      search_v:set(packet.key.sociality_personals_search_max, search_data[2])
    end
  elseif type == bo2.ePersonalsSearchType_Hobby then
    for k, v in ipairs(hobby_selected_list) do
      search_v:push_back(v.id)
    end
  end
  return search_v
end
function on_reset_region(ctrl, tab, province_id)
  ui_widget.ui_combo_box.clear(ctrl)
  create_nil_sel(ctrl, tab, bo2.ePersonalsSearchType_Region)
  if province_id == nil then
    return
  end
  local select_flag = false
  for i = 1000, 2000 do
    local excel = bo2.gv_im_info:find(i)
    if excel and excel.pram == province_id then
      ui_widget.ui_combo_box.append(ctrl, {
        id = excel.id,
        text = excel.name,
        search_type = bo2.ePersonalsSearchType_Region,
        search_var = excel.id,
        tab_id = tab
      })
      if select_flag == false then
        ui_widget.ui_combo_box.select(ctrl, excel.id)
        on_search_item_select(ctrl, tab, bo2.ePersonalsSearchType_Region, excel.id, excel.name)
        select_flag = true
      end
    end
  end
end
function on_search_item_select(combo_box, tab_id, search_type, search_var, text)
  local lable = combo_box:search(L("search_text"))
  if lable ~= nil then
    lable.text = text
  end
  local data = g_search_data[tab_id]
  local search_v = create_search_variant(search_type, search_var)
  data[search_type].value = search_v
  data[search_type].text = text
  if search_type == bo2.ePersonalsSearchType_Provinces then
    local parent = combo_box.parent.parent
    local parent_svar = parent.svar
    local region_ctrl = parent_svar[bo2.ePersonalsSearchType_Region]
    if region_ctrl ~= nil then
      on_reset_region(region_ctrl, tab_id, search_var)
    end
  end
  if tab_id == type_advance_search then
    local tab_type = w_advance_search.svar.belong_tab_id
    local tab_search_data = g_search_data[tab_type]
    if tab_search_data[search_type] == nil then
      tab_search_data[search_type] = {}
    end
    tab_search_data[search_type].value = search_var
    tab_search_data[search_type].text = text
    if tab_search_data[search_type].ctrl ~= nil then
      local lable_x = tab_search_data[search_type].ctrl:search(L("search_text"))
      lable_x.text = text
    end
  end
end
function on_sel_init(ctrl)
  ui_widget.ui_combo_box.on_init(ctrl)
  local name = tostring(ctrl.name)
  local tab_id, type
  for k, v in string.gmatch(name, "(%d+)_(%d+)") do
    tab_id = tonumber(k)
    type = tonumber(v)
    break
  end
  if create_sel_data[type] ~= nil then
    create_nil_sel(ctrl, tab_id, type)
    create_sel_data[type](ctrl, tab_id)
    local data = g_search_data[tab_id]
    if data == nil then
      data = {}
      g_search_data[tab_id] = data
    end
    if data[type] == nil then
      data[type] = {}
    end
    data[type].ctrl = ctrl
    data[type].text = L("")
  end
end
function on_advance_search_init(ctrl)
  create_hobby_selection(ctrl)
  local search_data = g_search_data[type_advance_search]
  search_data[bo2.ePersonalsSearchType_BelongGuildName] = {}
  search_data[bo2.ePersonalsSearchType_BelongGuildName].ctrl = w_belong_guild_name
end
function fix_hobby_selected_list(where_start)
  for i = where_start, hobby_max_num do
    if hobby_selected_list[i + 1] == nil then
      break
    else
      hobby_selected_list[i] = hobby_selected_list[i + 1]
      hobby_selected_list[i + 1] = nil
    end
  end
end
function on_hobby_check(ctrl, is_checked)
  local hobby_id = ctrl.var
  if is_checked == true then
    local list_size = #hobby_selected_list
    if list_size >= hobby_max_num then
      local hobby_first = hobby_selected_list[1]
      hobby_first.ctrl.check = false
    end
    local list_new_size = #hobby_selected_list
    local hobby_data = {}
    hobby_data.id = hobby_id
    hobby_data.ctrl = ctrl
    hobby_selected_list[list_new_size + 1] = hobby_data
  else
    for k, v in ipairs(hobby_selected_list) do
      if v.id == hobby_id then
        hobby_selected_list[k] = nil
        fix_hobby_selected_list(k)
        break
      end
    end
  end
  local hobby_data = create_search_variant(bo2.ePersonalsSearchType_Hobby, hobby_selected_list)
  local search_data = g_search_data[type_advance_search]
  if search_data[bo2.ePersonalsSearchType_Hobby] == nil then
    search_data[bo2.ePersonalsSearchType_Hobby] = {}
  end
  search_data[bo2.ePersonalsSearchType_Hobby].value = hobby_data
  if is_advance_search_clearing == false then
    local tab_type = w_advance_search.svar.belong_tab_id
    local tab_search_data = g_search_data[tab_type]
    if tab_search_data[bo2.ePersonalsSearchType_Hobby] == nil then
      tab_search_data[bo2.ePersonalsSearchType_Hobby] = {}
    end
    tab_search_data[bo2.ePersonalsSearchType_Hobby].value = hobby_data
  end
end
function clear_advance_search(is_as_clearing)
  is_advance_search_clearing = is_as_clearing
  local advence_search_data = g_search_data[type_advance_search]
  local tab_type = w_advance_search.svar.belong_tab_id
  local tab_search_data = g_search_data[tab_type]
  for k, n in pairs(advence_search_data) do
    if k == bo2.ePersonalsSearchType_Hobby then
      advence_search_data[bo2.ePersonalsSearchType_Hobby].value = nil
      for k, n in pairs(advence_search_data[bo2.ePersonalsSearchType_Hobby].ctrl) do
        n.check = false
      end
    elseif k == bo2.ePersonalsSearchType_BelongGuildName then
      advence_search_data[k].value = nil
      advence_search_data[k].ctrl.text = ""
      if is_as_clearing == false and tab_search_data[k] ~= nil then
        tab_search_data[k].value = nil
      end
    else
      n.value = nil
      n.text = nil
      local lable = n.ctrl:search(L("search_text"))
      lable.text = n.text
      if is_as_clearing == true and tab_search_data[k] ~= nil then
        tab_search_data[k].value = nil
        if tab_search_data[k].ctrl ~= nil then
          tab_search_data[k].ctrl:search(L("search_text")).text = ""
        end
      end
    end
  end
  is_advance_search_clearing = false
end
function refresh_advance_search(tab_search_data)
  local advence_search_data = g_search_data[type_advance_search]
  for k, n in pairs(tab_search_data) do
    if k == bo2.ePersonalsSearchType_Hobby then
      local hobby_var = tab_search_data[bo2.ePersonalsSearchType_Hobby].value
      if hobby_var ~= nil then
        advence_search_data[bo2.ePersonalsSearchType_Hobby].value = hobby_var
        local hobby_size = hobby_var.size
        for i = 0, hobby_size - 1 do
          local v = hobby_var:fetch_v(i)
          advence_search_data[bo2.ePersonalsSearchType_Hobby].ctrl[v.v_int].check = true
        end
      end
    elseif k == bo2.ePersonalsSearchType_BelongGuildName then
      if tab_search_data[bo2.ePersonalsSearchType_BelongGuildName] ~= nil then
        local guild_name = tab_search_data[bo2.ePersonalsSearchType_BelongGuildName].value
        if guild_name ~= nil then
          advence_search_data[bo2.ePersonalsSearchType_BelongGuildName].value = guild_name
          advence_search_data[bo2.ePersonalsSearchType_BelongGuildName].ctrl.text = guild_name
        end
      end
    else
      advence_search_data[k].value = n.value
      advence_search_data[k].text = n.text
      local lable_x = advence_search_data[k].ctrl:search(L("search_text"))
      lable_x.text = n.text
    end
  end
end
function on_advance_search_click(btn)
  w_advance_search.visible = true
  local tab_type = cur_visible_tab.var.v_int
  if g_search_data[tab_type] == nil then
    g_search_data[tab_type] = {}
  end
  w_advance_search.svar.belong_tab_id = tab_type
  local advence_search_data = g_search_data[type_advance_search]
  clear_advance_search(true)
  refresh_advance_search(g_search_data[tab_type])
end
function generate_search_var(tab_type)
  local data = g_search_data[tab_type]
  local search_var = sys.variant()
  if data ~= nil then
    for k, n in pairs(data) do
      if n.value ~= nil then
        search_var:set(k, n.value)
      end
    end
  end
  g_search_var[tab_type] = search_var
end
function on_advance_search_confirm_click(btn)
  save_belong_guild_name()
  local tab_type = w_advance_search.svar.belong_tab_id
  local cur_page = page_data[tab_type][bo2.ePersonalsListType_Normal].cur_page
  generate_search_var(tab_type)
  send_refresh_packet(tab_type, bo2.ePersonalsListType_Normal, cur_page)
  w_advance_search.visible = false
  on_progress_start(cur_visible_tab:search("panel_search"):search("btn"))
end
function on_advance_search_cancel_click(btn)
  save_belong_guild_name()
  w_advance_search.visible = false
  w_advance_search.svar.belong_tab_id = 0
end
function save_belong_guild_name()
  local search_data = g_search_data[type_advance_search]
  if search_data ~= nil then
    if search_data[bo2.ePersonalsSearchType_BelongGuildName] == nil then
      search_data[bo2.ePersonalsSearchType_BelongGuildName] = {}
    end
    if w_belong_guild_name.text.empty == true then
      search_data[bo2.ePersonalsSearchType_BelongGuildName].value = nil
    else
      search_data[bo2.ePersonalsSearchType_BelongGuildName].value = w_belong_guild_name.text
    end
    local tab_type = w_advance_search.svar.belong_tab_id
    local tab_search_data = g_search_data[tab_type]
    if tab_search_data[bo2.ePersonalsSearchType_BelongGuildName] == nil then
      tab_search_data[bo2.ePersonalsSearchType_BelongGuildName] = {}
    end
    if w_belong_guild_name.text.empty == false then
      tab_search_data[bo2.ePersonalsSearchType_BelongGuildName].value = w_belong_guild_name.text
      tab_search_data[bo2.ePersonalsSearchType_BelongGuildName].text = w_belong_guild_name.text
    end
    if tab_search_data[bo2.ePersonalsSearchType_BelongGuildName].ctrl ~= nil then
      local lable_x = tab_search_data[search_type].ctrl:search(L("search_text"))
      lable_x.text = text
    end
  end
end
function on_clear_search_option(btn)
  local tab_type = cur_visible_tab.var.v_int
  local data = g_search_data[tab_type]
  if data ~= nil then
    for k, n in pairs(data) do
      n.value = nil
      if n.text ~= nil then
        n.text = nil
      end
      if n.ctrl ~= nil then
        n.ctrl:search(L("search_text")).text = ""
      end
    end
  end
end
function on_clear_advance_search_option(btn)
  clear_advance_search(false)
end
