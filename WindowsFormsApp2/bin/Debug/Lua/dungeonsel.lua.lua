local reg = ui_packet.game_recv_signal_insert
local sig = "ui_areaquest.packet_handler"
local ui_combo = ui_widget.ui_combo_box
local ui_dungeonsel = ui_dungeonui.ui_dungeonsel
local ui_tab = ui_widget.ui_tab
local item_uri = SHARED("$frame/dungeonui/dungeonsel.xml")
local item_style1 = SHARED("sel_tree_item1")
local item_style2 = SHARED("sel_tree_item2")
local scenetype_for_double1 = "no_need_pay"
local scenetype_for_double2 = "need_pay"
local scenelevel_for_double = 60
local update_time = 10
local quest_table = sys.load_table("$mb/wuguan_trans/wuguan_trans.xml")
local g_sel_tb, g_sel_tb_by_scnid, last_obj_level_higher, obj_level_higher
local level_have_changed = false
local award_idx_get = false
local init_tab_name_value
local share_cd_t = 0
local cd_share_tb = {
  [3] = {
    id = 55010,
    max_count = 0,
    cur_count = 0
  }
}
local double_gaoji_share_cd = {
  id = 55012,
  max_count = 0,
  cur_count = 0
}
local tab_name_table = {}
local g_othertable1_for_rank = {}
local g_othertable2_for_rank = {}
local g_othertable3_for_rank = {}
function on_init()
  g_sel_tb = nil
  g_sel_tb_by_scnid = nil
  last_obj_level_higher = nil
  obj_level_higher = nil
  level_have_changed = false
  award_idx_get = false
  share_cd_t = bo2.gv_define:find(1097).value.v_int
  cd_share_tb = {
    [1] = {
      id = share_cd_t,
      max_count = 0,
      cur_count = 0
    },
    [3] = {
      id = 55010,
      max_count = 0,
      cur_count = 0
    }
  }
  init_tab_name_value = nil
end
function insert_tab(idx, text)
  local tab_uri = item_uri
  local btn_sty = "tab_btn"
  local page_sty = "tab_page"
  ui_tab.insert_suit(g_sel_main, idx, tab_uri, btn_sty, tab_uri, page_sty)
  local btn = ui_tab.get_button(g_sel_main, idx)
  btn:search("tab_btn_name").text = text
  btn.svar.type = idx
  btn:insert_on_click(on_tab_click, "ui_dungeonui.ui_dungeonsel.on_tab_click")
  local page = ui_tab.get_page(g_sel_main, idx)
  page.svar.type = idx
end
function on_tab_click(btn, click)
  local cur_page = ui_tab.get_show_page(g_sel_main)
  if cur_page == nil then
    return
  end
  local type = btn.svar.type
  local root = cur_page:search("w_sel_root")
  if root == nil or root.item_count == 0 then
    insert_page_items(type)
  end
  check_for_whole_state(type)
end
function init_tab_page()
  for i = 1, 4 do
    if g_sel_tb[i] ~= nil then
      local name = ui.get_text("dungeonui|dungeon_name_" .. i)
      tab_name_table[i] = name
    end
  end
  for i, v in pairs(tab_name_table) do
    insert_tab(i, v)
    g_othertable1_for_rank[i] = {}
    g_othertable2_for_rank[i] = {}
    g_othertable3_for_rank[i] = {}
  end
  ui_tab.show_page(g_sel_main, 1, true)
end
function init_global_tb()
  local sel_tb = bo2.gv_dungeon_info
  if sel_tb == nil then
    return
  end
  local index_1 = 1
  local index_2 = 1
  local index_3 = 1
  local index_4 = 1
  for i = 0, sel_tb.size - 1 do
    local sel_line = sel_tb:get(i)
    if sel_line == nil then
      return
    end
    if sel_line.isopen == 0 then
      local type = sel_line.scene_type
      if g_sel_tb[type] == nil then
        g_sel_tb[type] = {}
      end
      if g_sel_tb_by_scnid[type] == nil then
        g_sel_tb_by_scnid[type] = {}
      end
      local ID = sel_line.sceneID
      local scnlist_tb = bo2.gv_scn_list:find(ID)
      if scnlist_tb == nil then
        break
      end
      local min_level = scnlist_tb.min_level
      local temp_tb = {
        id = ID,
        line = sel_line,
        min_level = min_level
      }
      if type == 1 then
        g_sel_tb[type][index_1] = temp_tb
        index_1 = index_1 + 1
      elseif type == 2 then
        g_sel_tb[type][index_2] = temp_tb
        index_2 = index_2 + 1
      elseif type == 3 then
        g_sel_tb[type][index_3] = temp_tb
        index_3 = index_3 + 1
      elseif type == 4 then
        g_sel_tb[type][index_4] = temp_tb
        index_4 = index_4 + 1
      end
      g_sel_tb_by_scnid[type][ID] = temp_tb
    end
  end
end
function check_mil_idx(questid, milid)
  local flag = -1
  local quest_line = bo2.gv_quest_list:find(questid)
  if quest_line == nil then
    return flag
  end
  local milIDs = quest_line.milestones
  local size = milIDs.size
  for i = 0, size - 1 do
    local milID = milIDs[i]
    if milID == milid then
      flag = i
      break
    end
  end
  return flag
end
function check_other_state_levels(datatable)
  local obj = bo2.player
  if obj == nil then
    return false
  end
  local level = ui.safe_get_atb(2)
  local max_level1 = datatable.rank_max_level
  local min_level1 = datatable.rank_min_level
  if min_level1 ~= 0 or max_level1 ~= 0 then
    if min_level1 == 0 then
      if level > max_level1 then
        return false
      end
    elseif max_level1 == 0 then
      if level < min_level1 then
        return false
      end
    elseif max_level1 ~= nil and min_level1 ~= nil and (level > max_level1 or level < min_level1) then
      return false
    end
  end
  return true
end
function check_other_state(datatable)
  local obj = bo2.player
  if obj == nil then
    return false
  end
  local level = ui.safe_get_atb(2)
  local max_level = datatable.show_max_level
  local min_level = datatable.show_min_level
  if min_level ~= 0 or max_level ~= 0 then
    if min_level == 0 then
      if level > max_level then
        return false
      end
    elseif max_level == 0 then
      if level < min_level then
        return false
      end
    elseif max_level ~= nil and min_level ~= nil and (level > max_level or level < min_level) then
      return false
    end
  end
  local questid = datatable.rank_quest_id
  if questid ~= nil then
    local state = ui.quest_get_qobj_value(bo2.eQuestObj_Quest, questid)
    if state == -1 then
      return false
    elseif state > 0 then
      local milid = datatable.rank_mil_id
      if milid ~= nil then
        local cur_mil_idx = state
        local idx = check_mil_idx(questid, milid)
        if cur_mil_idx > idx then
          return false
        end
      end
    end
  end
  return true
end
function check_for_whole_state(type)
  local typetable = get_type_table(type)
  for i, v in pairs(typetable) do
    local data_table = v.data_table
    if data_table ~= nil then
      local state = data_table.whole_state
      if state == nil or state == false then
        state = check_other_state(data_table)
        data_table.whole_state = state
      end
      local state_1 = check_other_state_levels(data_table)
      set_ctrl_data(v.item, i, state, state_1)
    end
  end
end
function set_ctrl_data(ctrl, idx, vis, vis_1)
  local s = ctrl:search("c_panel")
  if idx % 2 == 0 then
    s.color = ui.make_argb("15000000")
  else
    s.color = ui.make_argb("65000000")
  end
  local new_vis = vis and vis_1
  ctrl:search("scninfo_numin").visible = new_vis
  ctrl:search("sel_cd").visible = new_vis
  ctrl:search("scn_state_no").visible = not new_vis
  if vis_1 == false then
    ctrl:search("scn_state_no").text = ui.get_text("dungeonui|dungeon_levels_no")
  end
end
function set_rank_tb_by_level()
  for i, v in pairs(g_sel_tb) do
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
          g_sel_tb_by_scnid[i][scnid_1] = v[k]
          g_sel_tb_by_scnid[i][scnid_2] = v[k + 1]
        end
      end
    end
  end
end
function init_cd_share_tb()
  for i = 1, 4 do
    if g_sel_tb[i] == nil then
      cd_share_tb[i] = nil
    end
  end
  if cd_share_tb[1] ~= nil and cd_share_tb[1].id == 0 then
    cd_share_tb[1] = nil
  end
end
function init_all_need()
  for i, v in pairs(g_othertable1_for_rank) do
    g_othertable1_for_rank[i] = {}
    g_othertable2_for_rank[i] = {}
    g_othertable3_for_rank[i] = {}
  end
  if g_sel_tb == nil then
    g_sel_tb = {}
    g_sel_tb_by_scnid = {}
    init_global_tb()
    set_rank_tb_by_level()
    tab_name_table = {}
    init_tab_page()
    init_cd_share_tb()
  end
  init_tab_name()
  local data = sys.variant()
  if award_idx_get == false then
    data:set(packet.key.has_award, 1)
  end
  local add_v = sys.variant()
  for i, k in pairs(cd_share_tb) do
    local v = sys.variant()
    v:set(packet.key.ui_cd_view_id, k.id)
    add_v:push_back(v)
  end
  data:set(packet.key.ui_cd_view_total_cddata, add_v)
  bo2.send_variant(packet.eCTS_UI_FubenListCD, data)
end
function set_rank_item_by_level()
end
function update_on_visible(type)
  local page = ui_tab.get_page(g_sel_main, tostring(type))
  if page == nil then
    return
  end
  local root = page:search("w_sel_root")
  if root == nil or root.item_count == 0 then
    insert_page_items(type)
  end
  check_for_whole_state(type)
end
function set_visible()
  local vis = g_sel_main.visible
  g_sel_main.visible = not vis
  if vis == true then
    return
  end
  init_all_need()
  local cur_page = ui_tab.get_show_page(g_sel_main)
  if cur_page == nil then
    return
  end
  local type = cur_page.svar.type
  local root = cur_page:search("w_sel_root")
  if root == nil or root.item_count == 0 then
    insert_page_items(type)
  end
  check_for_whole_state(type)
  if get_info_time ~= nil then
    local cur_time = os.time()
    local span = cur_time - get_info_time
    if span < update_time then
      return
    end
  end
  get_info_time = os.time()
end
function set_level_text(min_level, max_level)
  local text2
  local param = sys.variant()
  if min_level == 0 and max_level == 0 then
    text2 = ui.get_text("dungeonui|scninfo_level_no")
  elseif min_level == 0 and max_level ~= 0 then
    text2 = ui.get_text("dungeonui|scninfo_level_max")
    param:set("max_level", max_level)
  elseif min_level ~= 0 and max_level == 0 then
    text2 = ui.get_text("dungeonui|scninfo_level_min")
    param:set("min_level", min_level)
  elseif min_level ~= 0 and max_level ~= 0 then
    text2 = ui.get_text("dungeonui|scninfo_level")
    param:set("min_level", min_level)
    param:set("max_level", max_level)
  end
  local str2 = sys.mtf_merge(param, text2)
  return str2
end
function set_cd_text(cur_num, total_num, type)
  if type == 3 then
    local str3 = ui.get_text("dungeonui|dungeon_cd_no")
    return str3
  else
    local text3 = ui.get_text("dungeonui|scninfo_cd")
    local param = sys.variant()
    param:set("cur_num", cur_num)
    param:set("total_num", total_num)
    local str3 = sys.mtf_merge(param, text3)
    return str3
  end
end
function set_sel_item_info(ctrl, tb, type, idx)
  if tb == nil or tb.line == nil then
    return
  end
  local line = tb.line
  if line == nil then
    return
  end
  local scnid = line.sceneID
  if scnid == 0 then
    return
  end
  local for_rank_table = {}
  local scnlist_tb = bo2.gv_scn_list:find(scnid)
  if scnlist_tb == nil then
    return
  end
  local scnname = scnlist_tb.name
  if scnname ~= nil then
    ctrl:search("aq_name").text = scnname
  end
  local min_level = scnlist_tb.min_level
  local max_level = scnlist_tb.max_level
  local str2 = set_level_text(min_level, max_level)
  ctrl:search("sel_level").text = str2
  for_rank_table.show_min_level = min_level
  for_rank_table.show_max_level = max_level
  local pic_name = line.imageUrl
  if pic_name ~= L("") then
    ctrl:search("sel_pic").image = "$image/dungeonui/icon/" .. pic_name .. ".png|0,0,200,100"
  end
  local scnalloc_tb = bo2.gv_scn_alloc:find(scnid)
  local max_num = 0
  if scnalloc_tb ~= nil then
    max_num = scnalloc_tb.player
    local text1 = ui.get_text("dungeonui|scninfo_player")
    local param = sys.variant()
    param:set("num", max_num)
    local str1 = sys.mtf_merge(param, text1)
    ctrl:search("sel_p_num").text = str1
  end
  cur_num = "-"
  total_num = "-"
  if tb.cd_max ~= nil then
    cur_num = tb.cd_count
    total_num = tb.cd_max
  end
  local str3 = set_cd_text(cur_num, total_num, type)
  ctrl:search("sel_cd").text = str3
  local diff = line.difficulty
  if diff ~= 0 then
    local star_num = math.ceil(diff / 2)
    local half_num = math.mod(diff, 2)
    if half_num > 1 then
      half_num = 1
    end
    ctrl:search("star").dx = 22 * star_num
    ctrl:search("star_half").dx = 22 * half_num
  end
  local svar = ctrl.svar
  svar.index = idx
  svar.scnid = scnid
  svar.type = type
  svar.markid = line.markid
  svar.textid = line.intro
  svar.name = scnname
  svar.num = max_num
  svar.lowlevel_index = line.lowlevel_index
  svar.hilevel_index = line.hilevel_index
  svar.award_index = line.award_index
  if tb.award_level_max ~= nil then
    svar.award_level_min = tb.award_level_min
    svar.award_level_max = tb.award_level_max
  end
  if type == 1 then
    local new_tb = get_data_for_rank(svar)
    if new_tb ~= nil then
      new_tb.show_min_level = min_level
      new_tb.show_max_level = max_level
      tb.data_table = new_tb
    else
      tb.data_table = for_rank_table
    end
  else
    tb.data_table = for_rank_table
  end
end
function get_table_by_scnid(type, scnid)
  local tb = g_sel_tb_by_scnid[type]
  if tb ~= nil then
    return tb[scnid]
  end
end
function get_type_table(type)
  local table = g_sel_tb[type]
  return table
end
function insert_tree_item(idx, type, table)
  local page = ui_tab.get_page(g_sel_main, tostring(type))
  local root = page:search("sel_tree").root
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
  set_sel_item_info(the_title, table, type, idx)
  table.item = app_item
end
function insert_page_items(type)
  local typetable = get_type_table(type)
  if typetable == nil then
    return
  end
  local page = ui_tab.get_page(g_sel_main, tostring(type))
  local root = page:search("sel_tree").root
  root:item_clear()
  for i, v in pairs(typetable) do
    insert_tree_item(i, type, v)
    local line = v.line
    if v.line ~= nil then
      local sceneID = line.sceneID
      if g_sel_tb_by_scnid[type] == nil then
        g_sel_tb_by_scnid[type] = {}
      end
      g_sel_tb_by_scnid[type][sceneID] = v
    end
  end
end
function init_tab_name()
  for i, v in pairs(tab_name_table) do
    local cdtb = get_share_cd_tb(i)
    if cdtb ~= 0 and (i == 1 or i == 3) then
      local btn = ui_tab.get_button(g_sel_main, tostring(i))
      update_tab_cdtext(i, cdtb.id, cdtb.cur_count)
      btn:search("tab_btn_name").margin = ui.rect(0, 2, 30, 0)
      btn:search("share_cd").margin = ui.rect(28, 2, 0, 0)
      btn:search("share_cd").visible = true
    end
  end
end
function get_data_for_rank(svar)
  local ref_idx = 0
  ref_idx = svar.hilevel_index
  local line = quest_table:find(ref_idx)
  if line == nil then
    return
  end
  local for_rank_tb = {}
  local level = line.level
  local size = level.size
  if size == 2 then
    local minlevel = level[0]
    local maxlevel = level[1]
    for_rank_tb.rank_min_level = minlevel
    for_rank_tb.rank_max_level = maxlevel
  elseif size == 0 then
    for_rank_tb.rank_min_level = 0
    for_rank_tb.rank_max_level = 0
  end
  local quest = line.quest
  local size = quest.size
  if size == 0 then
    return for_rank_tb
  end
  if size % 3 ~= 0 then
    print("wuguan_trans|quest|error!")
    return for_rank_tb
  end
  local size1 = size / 3
  local quest_state_1 = -1
  local quest_state_2 = -1
  local quest_state_3 = -1
  for i = 0, size1 - 1 do
    local state = quest[3 * i + 2]
    if state == 1 then
      quest_state_1 = i
    elseif state == 2 then
      quest_state_2 = i
    elseif state == 3 then
      quest_state_3 = i
    end
    local quest_id = quest[3 * i]
    local quest_line = bo2.gv_quest_list:find(quest_id)
    if quest_line == nil then
      break
    end
    local quest_need = quest_line.pre_obj[0]
    if quest_need == bo2.eQuestObj_Profession then
      local obj = bo2.player
      if obj == nil then
        return
      end
      local my_profession = obj:get_atb(bo2.eAtb_Cha_Profession)
      if my_profession == quest_line.pre_min[0] or my_profession == quest_line.pre_max[0] then
        break
      end
    end
  end
  local id
  if quest_state_2 ~= -1 then
    id = quest_state_2 * 3
  elseif quest_state_3 ~= -1 then
    id = quest_state_3 * 3
  elseif quest_state_1 ~= -1 and quest_state_3 == -1 then
    id = quest_state_1 * 3
  end
  if quest[id + 0] ~= 0 then
    for_rank_tb.rank_quest_id = quest[id + 0]
    if quest[id + 1] ~= 0 then
      for_rank_tb.rank_mil_id = quest[id + 1]
    end
  end
  for_rank_tb.rank_pay_id = line.pay_id
  return for_rank_tb
end
function set_quest_ctrl_text(title, svar, item)
  local type = svar.type
  if type ~= 1 then
    return
  end
  local quest_text = ""
  local level_text = ""
  local need_pay_text = ""
  if svar.lowlevel_index == 0 and svar.hilevel_index == 0 then
    return
  end
  local text1, text2, text3 = get_quest_state(line, svar, item)
  level_text = text1
  quest_text = text2
  need_pay_text = text3
  local quest_ctrl = title:search("quest_info")
  quest_ctrl.mtf = sys.format("<c+:00DB00>%s<c->", quest_text .. "\n" .. need_pay_text)
end
function insert_info_item(item, svar)
  local child_item = item:item_append()
  local title = child_item.obtain_title
  title:load_style(item_uri, item_style2)
  local btn_recruit = title:search("find_team")
  btn_recruit.svar = {}
  btn_recruit.svar.num = svar.num
  btn_recruit.svar.name = svar.name
  btn_recruit.enable = svar.num > 1
  local btn_way = title:search("find_way")
  btn_way.svar.markid = svar.markid
  if svar.markid == 0 then
    btn_way.text = ui.get_text("dungeonui|findway_no")
    btn_way.enable = false
  end
  local info_ctrl = title:search("sel_info")
  info_ctrl.svar.textid = svar.textid
  local textline = bo2.gv_text:find(svar.textid)
  if textline ~= nil then
    info_ctrl.mtf = textline.text
  end
  set_quest_ctrl_text(title, svar, item)
  if svar.award_level_max ~= nil then
    local min = svar.award_level_min
    local max = svar.award_level_max
    local str = set_level_text(min, max)
    local ctrl = title:search("quest_info")
    ctrl.mtf = sys.format("<c+:00DB00>%s<c->", ui.get_text("dungeonui|dungeon_level") .. str)
  end
  local scnid = svar.scnid
  local type = svar.type
  if type == 3 then
    local text1, addtext = ui_dungeonui.ui_chg_to_dungeon_confirm.get_payment_text(scnid)
    local ctrl = title:search("quest_info")
    ctrl.mtf = sys.format("<c+:00DB00>%s<c->", text1 .. "\n" .. addtext)
  end
end
function get_quest_state(line, svar, item)
  local level_text = ""
  local quest_text = ""
  local need_pay_text = ""
  local type = svar.type
  local scnid = svar.scnid
  local table = get_type_table(type)
  if table == nil then
    return level_text, quest_text, need_pay_text
  end
  local idx = svar.index
  local scnline = table[idx]
  if scnline == nil then
    return level_text, quest_text, need_pay_text
  end
  local data_table = scnline.data_table
  if data_table == nil then
    return level_text, quest_text, need_pay_text
  end
  local quest_t = ""
  local mil_t = ""
  local questid = data_table.rank_quest_id
  local milid = data_table.rank_mil_id
  if questid ~= nil then
    quest_t = sys.format("<quest:%d>", questid)
    if milid ~= nil then
      mil_t = sys.format("-<milestone:%d>", milid)
    end
  end
  if quest_t ~= "" then
    quest_text = ui.get_text("dungeonui|sel_quest") .. quest_t .. mil_t
  end
  local pay_id = data_table.rank_pay_id
  local pay_line = bo2.gv_payment_in_scn:find(pay_id)
  if pay_line ~= nil then
    need_pay_text = ui_dungeonui.ui_chg_to_dungeon_confirm.get_payment_text_by_payid(pay_id, 1)
  end
  return level_text, quest_text, need_pay_text
end
function on_item_expanded(ctrl, v)
  ctrl:search("aq_select").visible = v
  if v == true then
    local svar = ctrl.obtain_title.svar
    if svar.child_init == nil then
      svar.child_init = true
      insert_info_item(ctrl, svar)
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
  local color1 = COLOR_red
  local color2 = COLOR_red
  if v == true then
    s.color = ui.make_argb("88441111")
    ctrl.expanded = true
    ctrl:search("aq_name").color = ui.make_argb("FFD2BA19")
  else
    local index = ctrl.index
    if index % 2 == 0 then
      s.color = ui.make_argb("15000000")
    else
      s.color = ui.make_argb("65000000")
    end
    ctrl.expanded = false
    color1 = COLOR_white
    color2 = COLOR_blue
    ctrl:search("aq_name").color = ui.make_argb("FFFFFFFF")
  end
end
function on_find_teammate(ctrl)
  ui_convene.on_btn_show_recruit_edit_click()
  ui_widget.ui_combo_box.select(ui_convene.w_type_list, 4)
  local svar = ctrl.svar
  ui_widget.ui_combo_box.select(ui_convene.w_num_list, svar.num - 1)
  local player = bo2.player
  local need_mem = 0
  local cur_team_num = player.group_cur_num
  if cur_team_num == 0 then
    cur_team_num = 1
  end
  need_mem = ctrl.svar.num - cur_team_num
  local text = ui.get_text("dungeonui|findteaminfo")
  local param = sys.variant()
  param:set("scn_name", svar.name)
  param:set("cha_num", need_mem)
  local str3 = sys.mtf_merge(param, text)
  ui_convene.w_recruit_edit_desc.mtf = str3
  ui_convene.w_show_desc.visible = false
  ui_convene.w_type_list_desc.visible = false
  ui_convene.w_num_list_desc.visible = false
end
function on_find_way(btn)
  local svar = btn.svar
  if svar == nil then
    return
  end
  local markid = svar.markid
  local excel = bo2.gv_mark_list:find(markid)
  if excel then
    ui_widget.ui_chat_list.on_click_mark_id(markid, excel)
  end
end
function main_on_visible(ctr, vis)
  if vis == true then
    bo2.PlaySound2D(578)
  else
    bo2.PlaySound2D(579)
  end
end
function on_share_cd_tip(tip)
  local p_btn = tip.owner
  local svar = p_btn.svar
  local type = svar.type
  local name = tab_name_table[type]
  if name == nil then
    return
  end
  local cdtb = get_share_cd_tb(type)
  if cdtb ~= 0 then
    local cur_count = cdtb.cur_count
    local max_count = cdtb.max_count
    local v = sys.variant()
    v:set("name", name)
    v:set("cur_count", max_count - cur_count)
    v:set("max_count", max_count)
    local text = sys.mtf_merge(v, bo2.gv_text:find(73165).text)
    ui_widget.tip_make_view(tip.view, text)
  else
    ui_widget.tip_make_view(tip.view, name)
  end
end
function item_update(cell_data)
  local scnid = cell_data:get(packet.key.cmn_index).v_int
  local line = bo2.gv_dungeon_info:find(scnid)
  if line == nil then
    return
  end
  local type = line.scene_type
  local scn_line_table = get_table_by_scnid(type, scnid)
  if scn_line_table == nil then
    return
  end
  local t = scn_line_table
  local level_max = 0
  local level_min = 0
  local cd_count = cell_data:get(packet.key.ui_cd_view_count).v_int
  local cd_max = cell_data:get(packet.key.ui_cd_view_max).v_int
  t.cd_count = cd_count
  t.cd_max = cd_max
  local data_table = scn_line_table.data_table
  if data_table ~= nil then
    data_table.rank_cd_count = cd_count
    data_table.rank_cd_max = cd_max
  end
  if cell_data:has(packet.key.cha_max_level) == true then
    level_max = cell_data:get(packet.key.cha_max_level).v_int
    level_min = cell_data:get(packet.key.cha_min_level).v_int
    t.award_level_max = level_max
    t.award_level_min = level_min
    award_idx_get = true
  end
  local item = scn_line_table.item
  if item ~= nil then
    local title = item.obtain_title
    title.svar.cd_max = cd_max
    title.svar.cd_count = cd_count
    local str = set_cd_text(cd_count, cd_max, type)
    title:search("sel_cd").text = str
    if cd_count == cd_max then
      title:search("sel_cd").color = ui.make_color("c0c0c0")
    else
      title:search("sel_cd").color = ui.make_color("0080FF")
    end
    if level_max ~= 0 then
      local str = set_level_text(level_min, level_max)
      local ctrl = title:search("quest_info")
      if ctrl ~= nil then
        ctrl.mtf = sys.format("<c+:00DB00>%s<c->", str)
      end
    end
  end
end
function get_share_cd_type(id)
  for i, v in pairs(cd_share_tb) do
    if v.id == id then
      return i
    end
  end
  return 0
end
function get_share_cd_tb(type)
  for i, v in pairs(cd_share_tb) do
    if i == type then
      return v
    end
  end
  return 0
end
function set_share_cd_count(id, curcount, maxcount)
  for i, v in pairs(cd_share_tb) do
    if v.id == id then
      v.cur_count = curcount
      v.max_count = maxcount
    end
  end
end
function update_tab_cdtext(type, cdid, curcount)
  local cd_line = bo2.gv_cooldown_list:find(cdid)
  if cd_line == nil then
    return
  end
  local max_count = cd_line.token
  if curcount > max_count then
    curcount = max_count
  end
  set_share_cd_count(cdid, curcount, max_count)
  local text = tab_name_table[type]
  local btn = ui_tab.get_button(g_sel_main, type)
  local count_text = sys.format("(%d/%d)", curcount, max_count)
  local cd_btn_label = btn:search("share_cd")
  cd_btn_label.text = count_text
  if curcount == max_count then
    cd_btn_label.color = ui.make_color("c0c0c0")
  else
    cd_btn_label.color = ui.make_color("0080FF")
  end
end
function share_cd_update(data)
  if data:has(packet.key.ui_cd_view_total_cddata) == true then
    local share_v = data:get(packet.key.ui_cd_view_total_cddata)
    if share_v.empty then
      return
    end
    local share_size = share_v.size
    for i = 0, share_size - 1 do
      local v = share_v:get(i)
      local cd_id = v:get(packet.key.ui_cd_view_id).v_int
      local cd_count = v:get(packet.key.ui_cd_view_count).v_int
      local cd_type = get_share_cd_type(cd_id)
      if cd_type == 0 then
        break
      end
      update_tab_cdtext(cd_type, cd_id, cd_count)
    end
  else
    local cd_id = data:get(packet.key.ui_cd_view_id).v_int
    local cd_count = data:get(packet.key.ui_cd_view_count).v_int
    local cd_type = get_share_cd_type(cd_id)
    if cd_type == 0 then
      return
    end
    update_tab_cdtext(cd_type, cd_id, cd_count)
  end
end
function handleFubenListCD(cmd, data)
  local has_arr_data = data:has(packet.key.ui_cd_view_arr_data)
  if has_arr_data == true then
    local arr_data = data:get(packet.key.ui_cd_view_arr_data)
    if arr_data.empty then
      return
    end
    local data_size = arr_data.size
    for i = 0, data_size - 1 do
      local cell_data = arr_data:get(i)
      item_update(cell_data)
    end
  else
    if g_sel_main.visible == false then
      return
    end
    item_update(data)
  end
  share_cd_update(data)
end
