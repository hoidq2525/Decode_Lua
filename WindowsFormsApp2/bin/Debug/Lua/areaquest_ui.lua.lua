local reg = ui_packet.game_recv_signal_insert
local sig = "ui_areaquest.packet_handler"
local ui_combo = ui_widget.ui_combo_box
local ui_tab = ui_widget.ui_tab
local g_areaquest_tb, g_areaquest_tb_by_id
local get_info_time = 0
local update_time = 10
local item_uri = SHARED("$frame/areaquest/areaquest_ui.xml")
local item_style1 = SHARED("areaquest_tree_item1")
local item_style2 = SHARED("areaquest_tree_item2")
local tab_name_table = {}
local get_server_time = false
function insert_tab(idx, text)
  local tab_uri = item_uri
  local btn_sty = "tab_btn"
  local page_sty = "tab_page"
  ui_tab.insert_suit(g_aq_main, idx, tab_uri, btn_sty, tab_uri, page_sty)
  local btn = ui_tab.get_button(g_aq_main, idx)
  btn:search("tab_btn_name").text = text
  btn.svar.type = idx
  btn:insert_on_click(on_tab_click, "ui_areaquest.on_tab_click")
  local page = ui_tab.get_page(g_aq_main, idx)
  page.svar.type = idx
end
function init_tab_page()
  for i = 1, 2 do
    local name = ui.get_text("quest|ui_aq_name_" .. i)
    tab_name_table[i] = name
  end
  for i, v in pairs(tab_name_table) do
    insert_tab(i, v)
  end
  ui_tab.show_page(g_aq_main, 1, true)
end
function set_comment_and_award(ctrl, svar)
  local tb = get_table_by_id(svar.type, svar.id)
  if tb == nil or tb.line == nil then
    return
  end
  local line = tb.line
  local intro = line.intro
  if intro ~= L("") then
    ctrl:search("aq_info").mtf = intro
  end
  local award = line.quest_awards[0][0]
  if award ~= 0 then
    local card = ctrl:search("card")
    card.excel_id = award
  else
    local textctrl = ctrl:search("areaquest_award_info")
    textctrl.text = ui.get_text("quest|aq_no_item_award")
    local card = ctrl:search("panel_1")
    card.visible = false
  end
end
function insert_info_item(item, svar)
  local child_item = item:item_append()
  child_item.obtain_title:load_style(item_uri, item_style2)
end
local format_text = function(string_tb, string2)
  local param = sys.variant()
  for i, v in pairs(string_tb) do
    param:set(i, v)
  end
  local fmt = ui.get_text(string2)
  local str = sys.mtf_merge(param, fmt)
  text = sys.format("%s", str)
  return text
end
function get_stage_aim_info(stage_tb)
  local targets_text_tb = {}
  local aim_num = stage_tb.num
  local targets = stage_tb.target
  local aim_item_size = 0
  local info_tb = {}
  local aim_name, begin_num, total_num
  if aim_num.size == 1 and targets.size > aim_num.size then
    aim_item_size = 1
    aim_name = stage_tb.target_name
    begin_num = stage_tb.begin_num
    total_num = stage_tb.num[0]
    icon = stage_tb.aim_icon
    local tb = {}
    local targets_num_tb = {}
    tb.aim_name = aim_name
    tb.total_num = total_num
    local text = format_text(tb, "quest|quest_cur_aim")
    targets_num_tb.text = text
    targets_text_tb.aim_name = targets_num_tb
  else
    if targets.size ~= aim_num.size then
      return
    end
    aim_item_size = aim_num.size
    for i = 0, aim_item_size - 1 do
      local target_id = targets[i]
      local cha_tb = bo2.gv_cha_list:find(target_id)
      if cha_tb == nil then
        return
      end
      local aim_name = cha_tb.name
      local total_num = aim_num[i]
      local begin_num = stage_tb.begin_num
      local tb = {}
      tb.aim_name = aim_name
      tb.total_num = total_num
      local text = format_text(tb, "quest|quest_cur_aim")
      local targets_num_tb = {}
      if i < aim_item_size - 1 then
        targets_num_tb.text = text .. "\n"
      else
        targets_num_tb.text = text
      end
      targets_text_tb[i + 1] = targets_num_tb
    end
  end
  return targets_text_tb
end
function on_mainlb_select(item)
  local parent_ctr = item.data.parent_ctr
  if parent_ctr == nil then
    return
  end
  local rich_info = parent_ctr:search("stage_info")
  rich_info:item_clear()
  rich_info.mtf = item.data.aimtext
  local explaintext = item.data.explaintext
  parent_ctr:search("aq_stage_text").text = explaintext
end
function set_stage_info(ctrl, svar)
  local tb = get_table_by_id(svar.type, svar.id)
  if tb == nil then
    return
  end
  local line = tb.line
  if line == nil then
    return
  end
  local stages = line.stageIDs
  local stage_tb = bo2.gv_quest_areaquest_stage
  local size = stages.size
  for i = 0, size - 1 do
    local stageid = stages[i]
    local stage_line = stage_tb:find(stageid)
    if stage_line == nil then
      break
    end
    local stage_item = ctrl:search("aq_stage")
    if stage_item == nil then
      return
    end
    local aim_tb = get_stage_aim_info(stage_line)
    local aimtext = ""
    for i, v in pairs(aim_tb) do
      aimtext = aimtext .. v.text
    end
    local explaintext = stage_line.aim_text
    ui_combo.append(stage_item, {
      id = stageid,
      text = stage_line.name,
      parent_ctr = ctrl,
      aimtext = aimtext,
      explaintext = explaintext
    })
    stage_item.svar.on_select = on_mainlb_select
  end
  local markid = line.ui_markid
  if markid ~= 0 then
    ctrl:search("aq_findway").svar = markid
  end
end
function on_btn_drop_down_click(btn)
  local cb = btn.parent
  local items = {}
  local svar = cb.svar
  local t = svar.list
  for i, v in ipairs(t) do
    local item = {
      id = v.id,
      color = v.color,
      text = v.text,
      style_uri = v.style_uri,
      style = v.style,
      data = v
    }
    table.insert(items, item)
  end
  local function on_event_list_select(item)
    ui_combo.select(cb, item.id)
    local event = svar.on_select
    if event == nil then
      return
    end
    event(item)
  end
  ui_tool.show_menu({
    items = items,
    event = on_event_list_select,
    source = btn,
    popup = "y_auto",
    dx = cb.dx + 40
  })
  if items ~= nil then
    for i, v in ipairs(items) do
      local item = v.list_item
      local btn = item:search("btn_item")
      if btn ~= nil then
        local btn_label = btn:search("btn_color")
        btn_label.dock = "pin_x1"
        btn_label.margin = ui.rect(5, 2, 2, 1)
      end
    end
  end
end
function find_btn_by_id(id)
  for i, v in pairs(tab_name_table) do
    local page = ui_tab.get_page(g_aq_main, tostring(i))
    local root = page:search("w_sel_root")
    local item, childitem
    if root == nil or root.item_count == 0 then
      return
    end
    for j = 0, root.item_count - 1 do
      item = root:item_get(j)
      local aqid = item:search("btn_open").svar
      if aqid == id then
        return i, item
      end
    end
  end
end
function show_page_item(id)
  local type, item = find_btn_by_id(id)
  ui_tab.show_page(g_aq_main, type, true)
  if item ~= nil then
    item.selected = true
    item:scroll_to_visible()
  end
end
function set_quest_item_info(ctrl, tb, type, idx)
  if tb == nil or tb.line == nil then
    return
  end
  local line = tb.line
  if line == nil then
    return
  end
  ctrl:search("btn_open").svar = line.id
  local name = line.name
  if name ~= nil then
    ctrl:search("aq_name").text = name
  end
  local level = line.ui_level
  if level.size == 2 then
    local minLevel = level[0]
    local maxLevel = level[1]
    local v = sys.variant()
    v:set(L("level"), minLevel .. " - " .. maxLevel)
    local fmt = ui.get_text("quest|aq_new_level")
    local str = sys.mtf_merge(v, fmt)
    ctrl:search("aq_level").text = str
  end
  local pic = line.ui_pic
  if pic ~= L("") then
    ctrl:search("aq_pic").image = "$image/quest/aq/" .. pic .. ".png"
  end
  local svar = ctrl.svar
  svar.index = idx
  svar.id = line.id
  svar.type = type
end
function set_stage_info_b(ctrl, id)
  local tb = g_areaquest_tb[id]
  if tb == nil then
    return
  end
  local line = tb.line
  if line == nil then
    return
  end
  on_areaquest_item(ctrl, id)
end
function set_info_init(ctrl, svar)
  local child_item = ctrl:item_get(0)
  if child_item == nil then
    return
  end
  local the_item = child_item.obtain_title
  if the_item == nil then
    return
  end
  set_comment_and_award(the_item, svar)
  set_stage_info(the_item, svar)
end
function insert_tree_item(idx, type, table)
  local page = ui_tab.get_page(g_aq_main, tostring(type))
  local root = page:search("w_sel_root")
  if root == nil then
    return
  end
  local app_item = root:item_append()
  local the_title = app_item.obtain_title
  the_title:load_style(item_uri, item_style1)
  if idx % 2 == 0 then
    the_title:search("c_panel").color = ui.make_argb("65000000")
  end
  app_item.expanded = false
  set_quest_item_info(app_item.obtain_title, table, type, idx)
  table.item = app_item
end
function init_global_tb()
  local aq_tb = bo2.gv_quest_areaquest
  if aq_tb == nil then
    return
  end
  local index_1 = 1
  local index_2 = 1
  for i = 1, aq_tb.size - 1 do
    local aq_line = aq_tb:get(i)
    if aq_line == nil then
      return
    end
    local type = aq_line.ui_type
    if g_areaquest_tb[type] == nil then
      g_areaquest_tb[type] = {}
    end
    if g_areaquest_tb_by_id[type] == nil then
      g_areaquest_tb_by_id[type] = {}
    end
    local levels = aq_line.ui_level
    local min_level = 0
    if levels ~= nil and levels.size == 2 then
      min_level = levels[0]
    end
    local questID = aq_line.id
    local temp_tb = {
      id = questID,
      line = aq_line,
      min_level = min_level
    }
    if type == 1 then
      g_areaquest_tb[type][index_1] = temp_tb
      index_1 = index_1 + 1
    elseif type == 2 then
      g_areaquest_tb[type][index_2] = temp_tb
      index_2 = index_2 + 1
    end
    g_areaquest_tb_by_id[type][questID] = temp_tb
  end
end
function on_init()
  g_areaquest_tb = nil
  g_areaquest_tb_by_id = nil
  get_info_time = 0
end
function on_item_expanded(ctrl, v)
  local i = 0
  local j = i
  ctrl:search("aq_select").visible = v
  if v == true then
    local svar = ctrl.obtain_title.svar
    local type = svar.type
    if svar.child_init == nil then
      svar.child_init = true
      insert_info_item(ctrl, svar)
      set_info_init(ctrl, svar)
    end
    local child_item = ctrl:item_get(0)
    if child_item == nil then
      return
    end
    local the_item = child_item.obtain_title
    if the_item == nil then
      return
    end
    if type == 2 then
      local scn = bo2.scn
      if scn ~= nil and scn.scn_excel ~= nil and scn.scn_excel.id == 892 then
        the_item:search("aq_findway").enable = false
      else
        the_item:search("aq_findway").enable = true
      end
    end
    local tb = get_table_by_id(svar.type, svar.id)
    if tb ~= nil then
      local item = the_item:search("aq_stage")
      if tb.idx ~= nil then
        local line = tb.line
        local stage = line.stageIDs
        local idx = stage[tb.idx]
        ui_combo.select(item, idx)
        local getitem = ui_combo.selected(item)
        local t = {}
        t.data = {}
        t.data = getitem
        on_mainlb_select(t)
      else
        item:search("btn_drop_down").text = ui.get_text("quest|aq_new_stagetext")
      end
    end
  end
end
function on_item_mouse(btn)
  ui_widget.on_tree_node_toggle_click(btn)
  local parent = btn.parent
  local item = parent.parent.item
  item.selected = true
  local item = item:item_get(0)
  if item == nil then
    return
  end
  item:scroll_to_visible()
end
function on_item_sel(ctrl, v)
  local s = ctrl:search("c_panel")
  if s == nil then
    return
  end
  if v == true then
    s.color = ui.make_argb("88441111")
    ctrl.expanded = true
    ctrl:search("aq_name").color = ui.make_argb("FFD2BA19")
  else
    local index = ctrl.index
    if index % 2 == 0 then
      s.color = ui.make_argb("15000000")
    else
      s.color = ui.make_argb("60000000")
    end
    ctrl.expanded = false
    ctrl:search("aq_name").color = ui.make_argb("FFFFFFFF")
  end
end
function on_find_way(btn)
  local markid = btn.svar
  if markid ~= nil then
    ui_map.find_path_byid(markid)
  end
end
function on_make_tip(tip)
  local btn = tip.owner
  ui_widget.tip_make_view(tip.view, btn.text)
end
local chg_info_tip1 = ui.get_text("quest|aq_new_infotext")
local chg_info_tip2 = ui.get_text("quest|aq_new_awardtext")
function on_chg_make_tip(tip)
  if g_aq_info.visible == true then
    ui_widget.tip_make_view(tip.view, chg_info_tip2)
  else
    ui_widget.tip_make_view(tip.view, chg_info_tip1)
  end
end
function on_chg_info(btn)
  local ctrl = btn.parent
  local g_aq_info = ctrl:search("g_aq_info")
  local g_aq_award = ctrl:search("g_aq_award")
  g_aq_award.visible = g_aq_info.visible
  g_aq_info.visible = not g_aq_info.visible
  local tip = btn.tip
  if g_aq_info.visible == true then
    ui_widget.tip_make_view(tip.view, chg_info_tip2)
  else
    ui_widget.tip_make_view(tip.view, chg_info_tip1)
  end
end
function on_tab_click(btn, click)
  local cur_page = ui_tab.get_show_page(g_aq_main)
  if cur_page == nil then
    return
  end
  local type = btn.svar.type
  local root = cur_page:search("w_sel_root")
  if root == nil or root.item_count == 0 then
    insert_page_items(type)
  end
end
function set_rank_tb_by_level()
  for i, v in pairs(g_areaquest_tb) do
    local size = #v
    for j = 1, size - 1 do
      for k = 1, size - 1 do
        if v[k].min_level > v[k + 1].min_level then
          local new_t = {}
          for m, n in pairs(v[k]) do
            new_t[m] = n
          end
          v[k] = v[k + 1]
          v[k + 1] = new_t
          local scnid_1 = v[k].id
          local scnid_2 = v[k + 1].id
          g_areaquest_tb_by_id[i][scnid_1] = v[k]
          g_areaquest_tb_by_id[i][scnid_2] = v[k + 1]
        end
      end
    end
  end
end
function init_all_need()
  if g_areaquest_tb == nil then
    g_areaquest_tb = {}
    g_areaquest_tb_by_id = {}
    init_global_tb()
    set_rank_tb_by_level()
    tab_name_table = {}
    init_tab_page()
  end
end
function get_table_by_id(type, id)
  local tb = g_areaquest_tb_by_id[type]
  if tb ~= nil then
    return tb[id]
  end
end
function get_type_table(type)
  local table = g_areaquest_tb[type]
  return table
end
function insert_page_items(type)
  local typetable = get_type_table(type)
  if typetable == nil then
    return
  end
  for i, v in pairs(typetable) do
    insert_tree_item(i, type, v)
    local line = v.line
    if v.line ~= nil then
      local ID = line.id
      if g_areaquest_tb_by_id[type] == nil then
        g_areaquest_tb_by_id[type] = {}
      end
      g_areaquest_tb_by_id[type][ID] = v
    end
  end
end
function update_find_way_btn()
  local typetable = get_type_table(2)
  if typetable == nil then
    return
  end
  for i, v in pairs(typetable) do
    local item = v.item
    if item == nil then
      break
    end
    local child_item = item:item_get(0)
    if child_item == nil then
      return
    end
    local the_item = child_item.obtain_title
    if the_item == nil then
      return
    end
    local scn = bo2.scn
    if scn ~= nil and scn.scn_excel ~= nil and scn.scn_excel.id == 892 then
      the_item:search("aq_findway").enable = false
    else
      the_item:search("aq_findway").enable = true
    end
  end
end
function set_visible()
  g_aq_main.visible = not g_aq_main.visible
  init_all_need()
  local cur_page = ui_tab.get_show_page(g_aq_main)
  if cur_page == nil then
    return
  end
  local type = cur_page.svar.type
  local root = cur_page:search("w_sel_root")
  if root == nil or root.item_count == 0 then
    insert_page_items(type)
  end
  update_find_way_btn()
  if get_info_time ~= 0 then
    local cur_time = os.time()
    local span = cur_time - get_info_time
    if span < update_time and span > 0 then
      return
    end
  end
  get_info_time = os.time()
  get_server_time = false
  local data = sys.variant()
  bo2.send_variant(packet.eCTS_UI_AreaQuest_All, data)
end
local pic_url = SHARED("$image/quest/aq_state.png|")
function get_server_time_and_set_state(data)
  local hour = data:get(packet.key.areaquest_hour).v_int
  local min = data:get(packet.key.areaquest_min).v_int
  local size = bo2.gv_quest_areaquest.size
  for i = 0, size - 1 do
    local line = bo2.gv_quest_areaquest:get(i)
    if line.aq_close ~= 0 and line.aq_beg_time.size == 2 and line.aq_end_time.size == 2 then
      local tb = get_table_by_id(line.ui_type, line.id)
      local item = tb.item
      if item == nil then
        break
      end
      local obtain_title = item.obtain_title
      local pic = obtain_title:search("aq_state")
      local label = obtain_title:search("aq_text")
      local iBegHour = line.aq_beg_time[0]
      local iBegMin = line.aq_beg_time[1]
      local iEndHour = line.aq_end_time[0]
      local iEndMin = line.aq_end_time[1]
      if iBegHour < iEndHour or iBegHour == iEndHour and iBegMin < iEndMin then
        if hour < iBegHour or hour == iBegHour and min < iBegMin or hour > iEndHour or hour == iEndHour and min >= iEndMin then
          set_close_label_and_image(pic, label, line)
        end
      elseif (iBegHour > iEndHour or iBegHour == iEndHour and iBegMin > iEndMin) and (hour > iEndHour or iEndHour == hour and min >= iEndMin or hour < iBegHour or hour == iBegHour and min <= iBegMin) then
        set_close_label_and_image(pic, label, line)
      end
    end
  end
end
function set_close_label_and_image(pic, label, quest_tb)
  pic.image = pic_url .. "178,182,242,44"
  local opentime = quest_tb.aq_beg_time
  if opentime.size ~= 2 then
    ui.log("quest table open time error!!")
  end
  local hour = opentime[0]
  local minite = opentime[1]
  if hour < 10 then
    hour = "0" .. hour
  end
  if minite < 10 then
    minite = "0" .. minite
  end
  local var = sys.variant()
  var:set(L("time"), hour .. ":" .. minite)
  local fmt = ui.get_text("quest|aq_new_open")
  local str = sys.mtf_merge(var, fmt)
  label.text = str
end
function areaquest_showall(cmd, data)
  if get_server_time == false then
    get_server_time_and_set_state(data)
    get_server_time = true
  end
  local questinfo = data:get(packet.key.areaquest_group_data)
  if questinfo.empty then
    return
  end
  for i = 0, questinfo.size - 1 do
    local v = questinfo:get(i)
    local questid = v:get(packet.key.areaquest_excelID).v_int
    local state = v:get(packet.key.areaquest_stagestate).v_int
    local stageIdx = v:get(packet.key.areaquest_stageIDx).v_int
    local quest_tb = bo2.gv_quest_areaquest:find(questid)
    if quest_tb == nil then
      break
    end
    local type = quest_tb.ui_type
    local tb = get_table_by_id(type, questid)
    if tb ~= nil then
      local item = tb.item
      local obtain_title = item.obtain_title
      local pic = obtain_title:search("aq_state")
      local label = obtain_title:search("aq_text")
      local var = sys.variant()
      if state == bo2.eState_NoActive then
        pic.image = pic_url .. "178,138,242,44"
        label.text = ui.get_text("quest|aq_new_active")
      elseif state == bo2.eState_Ready or state == bo2.eState_BeingIn then
        pic.image = pic_url .. "167,6,242,44"
        var:set(L("idx"), stageIdx + 1)
        local fmt = ui.get_text("quest|aq_new_stage")
        local str = sys.mtf_merge(var, fmt)
        label.text = str
        tb.idx = stageIdx
      elseif state == bo2.eState_Reset then
        pic.image = pic_url .. "178,50,242,44"
        local total_time = 0
        local cd_time = 0
        local resetstate = v:get(packet.key.areaquest_reset_state).v_int
        if resetstate == 2 then
          total_time = quest_tb.overtime_cd
        elseif resetstate == 1 then
          total_time = quest_tb.questend_cd
        end
        local time = v:get(packet.key.areaquest_countdown_time1).v_int
        cd_time = math.ceil((total_time * 60 - time) / 60)
        var:set(L("time"), cd_time)
        local fmt = ui.get_text("quest|aq_new_time")
        local str = sys.mtf_merge(var, fmt)
        label.text = str
      elseif state == bo2.eState_Close then
        set_close_label_and_image(pic, label, quest_tb)
      end
    end
  end
end
reg(packet.eSTC_UI_AreaQuest_ShowAll, areaquest_showall, sig)
