TOP_REFERESH_TIME_INTERVAL = 15000
MANUAL_REFERESH_TIME_INTERVAL = 15000
REFERESH_TIME_INTERVAL = 900000
page_list = {}
page_data = {}
function init_page_data()
  function init(type)
    page_data[type] = {}
    page_data[type][bo2.ePersonalsListType_Normal] = {}
    page_data[type][bo2.ePersonalsListType_Normal].cur_page = 0
    page_data[type][bo2.ePersonalsListType_Normal].total_page = 0
  end
  for i = bo2.PersonalsType_PlayerBegin + 1, bo2.PersonalsType_PlayerEnd - 1 do
    init(i)
  end
  for j = bo2.PersonalsType_GuildBegin + 1, bo2.PersonalsType_GuildEnd - 1 do
    init(j)
  end
end
init_page_data()
local tab_type_text_list = {}
tab_type_text_list[bo2.PersonalsType_FindHusband] = "find_men"
tab_type_text_list[bo2.PersonalsType_FindWife] = "find_women"
tab_type_text_list[bo2.PersonalsType_FindSworn] = "find_sworn"
tab_type_text_list[bo2.PersonalsType_JoinGuild] = "find_guild"
tab_type_text_list[bo2.PersonalsType_FindMaster] = "find_master"
tab_type_text_list[bo2.PersonalsType_FindAppren] = "find_appren"
tab_type_text_list[bo2.PersonalsType_FindGuildMember] = "find_member"
function insert_page_data(list_type, tab_type, data_var, page_num, page_total, plus_data)
  local tab_data = page_data[tab_type]
  local list_data = tab_data[list_type]
  if list_type == bo2.ePersonalsListType_Top then
    list_data = {}
    list_data.refresh_time = sys.tick()
    list_data.data = data_var
  elseif list_type == bo2.ePersonalsListType_Normal then
    list_data[page_num] = {}
    list_data[page_num].refresh_time = sys.tick()
    list_data[page_num].manual_refresh_time = sys.tick()
    list_data[page_num].data = data_var
    list_data.cur_page = page_num
    list_data.total_page = page_total
  elseif list_type == bo2.ePersonalsListType_My then
    list_data = data_var
  end
end
player_addition_data_key = {}
table.insert(player_addition_data_key, packet.key.sociality_personals_name)
table.insert(player_addition_data_key, packet.key.sociality_personals_topmultiple)
guild_addition_data_key = {}
table.insert(guild_addition_data_key, packet.key.sociality_personals_guild_leader_name)
table.insert(guild_addition_data_key, packet.key.sociality_personals_guild_onlyid)
table.insert(guild_addition_data_key, packet.key.sociality_personals_topmultiple)
function match_addition_data_key(type, key)
  if type > bo2.PersonalsType_PlayerBegin and type < bo2.PersonalsType_PlayerEnd then
    for i, v in pairs(player_addition_data_key) do
      if v == key then
        return true
      end
    end
  elseif type > bo2.PersonalsType_GuildBegin and type < bo2.PersonalsType_GuildEnd then
    for i, v in pairs(guild_addition_data_key) do
      if v == key then
        return true
      end
    end
  end
  return false
end
unvisible_data_key = {}
table.insert(unvisible_data_key, packet.key.sociality_personals_guild_onlyid)
table.insert(unvisible_data_key, packet.key.sociality_personals_topmultiple)
function match_unvisible_data(key)
  for i, v in pairs(unvisible_data_key) do
    if v == key then
      return true
    end
  end
  return false
end
function insert_list_item(list, tab_type, data_var, list_type)
  local size = data_var.size
  local tab_type_text = tab_type_text_list[tab_type]
  if tab_type_text == nil then
    return
  end
  local uri = "$frame/advertise/" .. tab_type_text .. ".xml"
  local style = "cmn_item"
  cur_row = list:item_append()
  cur_row:load_style(uri, style)
  local item_id = 1
  for i = 0, size - 1 do
    local data = data_var:fetch_v(i)
    local key = data:get(packet.key.sociality_personals_infokey).v_int
    local value = data:get(packet.key.sociality_personals_infovar)
    if match_addition_data_key(tab_type, key) == true then
      local svar = cur_row.svar
      if svar.addition_data == nil then
        svar.addition_data = {}
      end
      local addition_data = svar.addition_data
      addition_data[key] = value
    end
    if match_unvisible_data(key) == false then
      local text = item_create[key](value)
      local item_name = L("item_") .. item_id
      local label = cur_row:search(item_name)
      label.text = text
      item_id = item_id + 1
    end
  end
  if list_type == bo2.ePersonalsListType_My then
    cur_row.mouse_able = false
  end
end
function refresh_page_ui(tab_ctrl, page, total_page)
  local parent_ctrl = tab_ctrl.parent.parent.parent
  local page_label = parent_ctrl:search("page_text")
  local temp_text = ui.get_text("advertise|page_display")
  local arg = sys.variant()
  local page_text = page + 1
  if total_page < page_text then
    page_text = total_page
  end
  arg:set("page", page_text)
  arg:set("total_page", total_page)
  local text = sys.mtf_merge(arg, temp_text)
  page_label.text = text
end
function refresh_list(tab_type, list_type, data)
  if data == nil then
    return
  end
  local page = page_list[tab_type]
  local list
  if list_type == bo2.ePersonalsListType_Top then
    list = page:search("top_list")
  elseif list_type == bo2.ePersonalsListType_Normal then
    list = page:search("normal_list")
    local page_data = page_data[tab_type][list_type]
    refresh_page_ui(page, page_data.cur_page, page_data.total_page)
  elseif list_type == bo2.ePersonalsListType_My then
    list = page:search("my_info")
  end
  if list == nil then
    return
  end
  list:item_clear()
  if data == nil then
    return
  end
  local size = data.size
  for i = 0, size - 1 do
    local item_data = data:fetch_v(i)
    insert_list_item(list, tab_type, item_data, list_type)
  end
end
function on_item_lb_menu()
end
