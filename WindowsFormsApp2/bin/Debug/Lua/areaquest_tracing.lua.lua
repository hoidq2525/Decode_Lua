local ui_tab = ui_widget.ui_tab
local ui_tracing = ui_quest.ui_tracing
local ui_areaquest = ui_quest.ui_areaquest
local w_tracing_tab = ui_tracing.w_tracing_tab
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_quest.ui_areaquest.packet_handler"
local remain_time = 0
local fmt
local added_item_num = 0
local areaquest_id = 0
local item_dy = 20
local target_size = 0
local comment_size = 0
local stage_init = false
local areaquest_tracing_init = {}
targets_table = {}
local function bad_name(name)
  if not name then
    return true
  end
  if areaquest_tracing_init[name] then
    return true
  end
  return false
end
local function aq_item_init(item)
  if bad_name(item.name) then
    return
  end
  local newitem = {
    index = item.index,
    name = item.name,
    itemindex = item.itemindex or -1,
    itemvalue = item.itemvalue or 0,
    text = item.text or ui.get_text(item.name),
    box = item.box or 0,
    value = item.value or 0,
    cur_num = item.cur_num or 0,
    total_num = item.total_num or 0,
    stage_count_item = item.stage_count_item or nil,
    stage_note_item = item.stage_note_item or nil
  }
  areaquest_tracing_init[item.index] = newitem
end
aq_item_init({
  index = 1,
  name = "quest|resetting_name"
})
aq_item_init({
  index = 2,
  name = "quest|areaquest_cur"
})
aq_item_init({
  index = 3,
  name = "quest|stage_text"
})
aq_item_init({
  index = 4,
  name = "quest|aim_text",
  stage_count_item = true
})
aq_item_init({
  index = 5,
  name = "quest|areaquest_note",
  stage_note_item = true
})
aq_item_init({
  index = 6,
  name = "quest|my_rank"
})
aq_item_init({
  index = 7,
  name = "quest|my_contri"
})
aq_item_init({
  index = 8,
  name = "quest|my_cur_contri"
})
aq_item_init({
  index = 9,
  name = "quest|my_award"
})
aq_item_init({
  index = 10,
  name = "quest|my_exp"
})
aq_item_init({
  index = 11,
  name = "quest|my_money"
})
function find_init_tb_index(item)
  local init_tb = areaquest_tracing_init
  for i, v in ipairs(init_tb) do
    if v.itemvalue == item then
      return v
    end
  end
  return nil
end
local get_table_areaquest = function(questid)
  local areaquest_tb = bo2.gv_quest_areaquest:find(questid)
  return areaquest_tb
end
local get_table_areaquest_stage = function(stageid)
  local stage_tb = bo2.gv_quest_areaquest_stage:find(stageid)
  return stage_tb
end
local c_list_uri = SHARED("$frame/quest/areaquest_info.xml")
local c_list_style = SHARED("panel_display_info")
local c_name_list_style = SHARED("name_info")
local c_rank_list_style = SHARED("rank_list")
function set_target_table(name_item, name_text, name, begin_num, num, box, target_id)
  local tagetdata_table = {}
  tagetdata_table.item = name_item
  tagetdata_table.stringtext = name_text
  tagetdata_table.name = name
  tagetdata_table.begin_num = begin_num
  tagetdata_table.num = num
  tagetdata_table.box = box
  tagetdata_table.target_id = target_id
  return tagetdata_table
end
function set_aim_text_item(item, data, v)
  item:load_style(c_list_uri, c_name_list_style)
  v.itemindex = item.index
  v.itemvalue = item
  local name_list = item:search("name_list")
  local count = name_list.item_count
  if count > 0 then
    name_list:item_clear()
    targets_table = {}
  end
  local name_tb = {}
  local stageid = data:get(packet.key.areaquest_stageID).v_int
  local stage_tb = get_table_areaquest_stage(stageid)
  if stage_tb == nil then
    return
  end
  local aim_num = stage_tb.num
  local targets = stage_tb.target
  local begin_nums = stage_tb.begin_num
  local aim_item_size = 0
  if begin_nums.size ~= 0 and begin_nums.size ~= aim_num.size then
    ui.log("areaquest_stage table begin num is error!")
    return
  end
  if aim_num.size == 1 and targets.size > aim_num.size then
    local name = stage_tb.target_name
    if name ~= L("") then
    end
    local name_item = name_list:item_append()
    name_item:load_style(c_list_uri, c_list_style)
    local begin_num = 0
    if begin_nums.size == 0 then
      begin_num = 0
    else
      begin_num = begin_nums[0]
    end
    local num = stage_tb.num[0]
    local box = name_item:search("rb_text")
    local tb = {}
    tb.begin_num = begin_num
    tb.total_num = num
    tb.aim_name = name
    local name_text = format_text_table(tb, v.name)
    box.mtf = name_text
    local tagetdata_table = {}
    tagetdata_table = set_target_table(name_item, v.name, name, begin_num, num, box)
    for i = 0, targets.size - 1 do
      targets_table[targets[i]] = tagetdata_table
    end
    target_size = 1
  else
    if targets.size ~= aim_num.size then
      return
    end
    aim_item_size = aim_num.size
    target_size = aim_item_size
    local dy = item.dy
    item.dy = dy * aim_item_size
    for i = 0, aim_item_size - 1 do
      local target_id = targets[i]
      local cha_tb = bo2.gv_cha_list:find(target_id)
      if cha_tb == nil then
        return
      end
      local name_item = name_list:item_append()
      name_item:load_style(c_list_uri, c_list_style)
      local aim_name = cha_tb.name
      local num = aim_num[i]
      local begin_num = 0
      if begin_nums.size == 0 then
        begin_num = 0
      else
        begin_num = begin_nums[i]
      end
      local box = name_item:search("rb_text")
      local tb = {}
      tb.begin_num = begin_num
      tb.total_num = num
      tb.aim_name = aim_name
      local name_text = format_text_table(tb, v.name)
      box.mtf = name_text
      local tagetdata_table = {}
      tagetdata_table = set_target_table(name_item, v.name, aim_name, begin_num, num, box, target_id)
      targets_table[target_id] = tagetdata_table
    end
  end
end
function format_text(i, v, string2)
  local param = sys.variant()
  param:set(i, v)
  local fmt = ui.get_text(string2)
  local str = sys.mtf_merge(param, fmt)
  text = sys.format("%s", str)
  return text
end
function get_last_stageid(questid, idx)
  if idx < 0 then
    return
  end
  local quest_tb = get_table_areaquest(questid)
  if quest_tb == nil then
    ui.log("areaquest_stage table is error!")
    return
  end
  local stagesize = quest_tb.stageIDs.size
  for i = 0, stagesize - 1 do
    if i == idx then
      return quest_tb.stageIDs[i]
    end
  end
end
local s_dy = SHARED("areaquest_list")
function common_try_tune(view, dy)
  view:tune_y(s_dy)
  if dy > view.dy then
    return false
  end
  return true
end
function set_items_dy()
  g_areaquest_list.dy = 220
  if not common_try_tune(g_areaquest_list, 200) and not common_try_tune(g_areaquest_list, 180) and not common_try_tune(g_areaquest_list, 160) and not common_try_tune(g_areaquest_list, 140) then
    common_try_tune(g_areaquest_list, 120)
  end
end
function stage_new_init(data)
  set_stage_item(data)
  local stage_idx = data:get(packet.key.areaquest_stageIDx).v_int
  local stageid = data:get(packet.key.areaquest_stageID).v_int
  local stage_tb = get_table_areaquest_stage(stageid)
  if stage_tb == nil then
    ui.log("areaquest_stage table is error!")
    return
  end
  local questid = data:get(packet.key.areaquest_excelID).v_int
  local last_stage_id = get_last_stageid(questid, stage_idx - 1)
  if last_stage_id == nil then
    return
  end
  local last_stage_tb = get_table_areaquest_stage(last_stage_id)
  if last_stage_tb == nil then
    ui.log("areaquest_stage table is error!")
    return
  end
  local last_stage_count_item = last_stage_tb.no_count ~= 1
  local last_stage_note_item = last_stage_tb.aim_text ~= L("")
  local no_count = stage_tb.no_count
  local aim_text = stage_tb.aim_text
  local list_ctrl = g_areaquest_info:search("areaquest_list")
  local aim_text_table = areaquest_tracing_init[4]
  aim_text_table.stage_count_item = no_count ~= 1
  if last_stage_count_item == true and aim_text_table.stage_count_item == false then
    local item = aim_text_table.itemvalue
    local index = item.index
    list_ctrl:item_remove(index)
    aim_text_table.itemvalue = 0
  elseif last_stage_count_item == false and aim_text_table.stage_count_item == true then
    local item = list_ctrl:item_insert(3)
    set_aim_text_item(item, data, aim_text_table)
  elseif last_stage_count_item == true and aim_text_table.stage_count_item == true then
    local item = aim_text_table.itemvalue
    set_aim_text_item(item, data, aim_text_table)
  end
  if no_count == 1 then
    target_size = 0
  end
  local areaquest_note_table = areaquest_tracing_init[5]
  areaquest_note_table.stage_note_item = aim_text ~= L("")
  if aim_text == L("") then
    comment_size = 0
  else
    comment_size = 1
  end
  if last_stage_note_item == true and areaquest_note_table.stage_note_item == false then
    local item = areaquest_note_table.itemvalue
    local index = item.index
    list_ctrl:item_remove(index)
    areaquest_note_table.itemvalue = 0
    local ii = item
  elseif areaquest_note_table.stage_note_item == true then
    local item
    if last_stage_note_item == false then
      if aim_text_table.stage_count_item == true then
        item = list_ctrl:item_insert(4)
      else
        item = list_ctrl:item_insert(3)
      end
      item:load_style(c_list_uri, c_list_style)
    else
      item = areaquest_note_table.itemvalue
    end
    areaquest_note_table.itemindex = item.index
    areaquest_note_table.itemvalue = item
    local box = item:search("rb_text")
    box.mtf = ""
    areaquest_note_table.box = box
    local stringtext = format_text("note_text", aim_text, areaquest_note_table.name)
    areaquest_note_table.text = stringtext
    box.margin = ui.rect(20, 0, 0, 0)
    box.mtf = areaquest_note_table.text
  end
  set_items_dy()
end
function set_rank_list_item(list_ctrl, data, v)
  local item = list_ctrl:item_append()
  item:load_style(c_list_uri, c_rank_list_style)
  item.dy = g_areaquest_info.dy - item_dy * (9 + target_size + comment_size)
  if g_areaquest_info.dy < 400 then
    item.dy = 180
  end
  v.itemindex = item.index
  v.itemvalue = item
end
function find_stage_item(name)
  for i, v in ipairs(areaquest_tracing_init) do
    if v.name == name then
      return v.itemvalue
    end
  end
end
function init_stage_info(data)
  local stage_idx = data:get(packet.key.areaquest_stageIDx).v_int
  local stageid = data:get(packet.key.areaquest_stageID).v_int
  local stage_tb = get_table_areaquest_stage(stageid)
  local no_count, aim_text
  if stage_tb ~= nil then
    no_count = stage_tb.no_count
    aim_text = stage_tb.aim_text
    if aim_text == L("") then
      comment_size = 0
    else
      comment_size = 1
    end
    if no_count == 1 then
      target_size = 0
    end
  end
  local list_ctrl = g_areaquest_info:search("areaquest_list")
  for i, v in ipairs(areaquest_tracing_init) do
    if v.name == "quest|areaquest_note" and aim_text == L("") then
      v.stage_note_item = false
    elseif v.name == "quest|aim_text" then
      if no_count == 1 then
        v.stage_count_item = false
      else
        local item = list_ctrl:item_append()
        set_aim_text_item(item, data, v)
      end
    elseif v.name == "quest|rank_list" then
    else
      local item = list_ctrl:item_append()
      item:load_style(c_list_uri, c_list_style)
      v.itemindex = item.index
      v.itemvalue = item
      local box = item:search("rb_text")
      v.box = box
      if v.name == "quest|areaquest_note" and aim_text ~= nil then
        local stringtext = format_text("note_text", aim_text, v.name)
        v.text = stringtext
        box.margin = ui.rect(20, 0, 0, 0)
      end
      box.mtf = v.text
    end
  end
  if stage_tb == nil then
    local item = find_stage_item("quest|areaquest_note")
    if item ~= 0 then
      list_ctrl:item_remove(item.index)
      item = 0
    end
    item = find_stage_item("quest|aim_text")
    if item ~= 0 then
      list_ctrl:item_remove(item.index)
      item = 0
    end
    item = find_stage_item("quest|stage_text")
    if item ~= 0 then
      list_ctrl:item_remove(item.index)
      item = 0
    end
  end
  set_items_dy()
  stage_init = true
end
local least_number = function(src_num, n, direction)
  src_num = tostring(src_num)
  local len = #src_num
  local output = src_num
  if n > len then
    if direction == "R" then
      for i = 1, n - len do
        output = output .. "0"
      end
    else
      for i = 1, n - len do
        output = "0" .. output
      end
    end
  end
  return output
end
local ONE_MINUTE = 60
local ONE_HOUR = 60 * ONE_MINUTE
function get_time(wait_time, text_ui)
  local hour = math.floor(wait_time / ONE_HOUR)
  wait_time = wait_time % ONE_HOUR
  local minute = math.floor(wait_time / ONE_MINUTE)
  local second = wait_time % ONE_MINUTE
  local s = sys.format(ui.get_text(text_ui), least_number(hour, 2), least_number(minute, 2), least_number(second, 2))
  return s
end
function get_cd_time(data)
  local showtime = data:has(packet.key.areaquest_countdown_time1)
  local cd_time = 0
  if showtime == true then
    local time = data:get(packet.key.areaquest_countdown_time1).v_int
    local questid = data:get(packet.key.areaquest_excelID).v_int
    local state = data:get(packet.key.areaquest_stagestate).v_int
    local quest_tb = get_table_areaquest(questid)
    if quest_tb == nil then
      return
    end
    local total_time = 0
    if state == bo2.eState_Reset then
      local resetstate = data:get(packet.key.areaquest_reset_state).v_int
      if resetstate == 2 then
        total_time = quest_tb.overtime_cd
      elseif resetstate == 1 then
        total_time = quest_tb.questend_cd
      end
    else
      total_time = quest_tb.time_total
    end
    cd_time = total_time * 60 - time
    if state == bo2.eState_Ready then
      cd_time = 0
    end
  end
  return cd_time
end
function set_time_item(data)
  local cd_time = get_cd_time(data)
  areaquest_total_cd_time = cd_time
  if timer_1.suspended == true then
    timer_1.suspended = false
  end
  local item = areaquest_tracing_init[1]
  local state = data:get(packet.key.areaquest_stagestate).v_int
  item.string_text = "quest|areaquest_cd"
  if state == bo2.eState_Reset then
    item.string_text = "quest|areaquest_reset_cd"
  end
  local cur_time = get_time(cd_time, item.string_text)
  item.box.mtf = cur_time
  if areaquest_total_cd_time <= 0 then
    areaquest_total_cd_time = 0
    ui_areaquest.timer_1.suspended = true
  end
  item.value = areaquest_total_cd_time
end
function format_text_table(string_tb, string2)
  local param = sys.variant()
  for i, v in pairs(string_tb) do
    param:set(i, v)
  end
  local fmt = ui.get_text(string2)
  local str = sys.mtf_merge(param, fmt)
  text = sys.format("%s", str)
  return text
end
function set_stage_item(data)
  local item = areaquest_tracing_init[2]
  local state = data:get(packet.key.areaquest_stagestate).v_int
  local text
  if state == bo2.eState_Reset then
    local name = ui.get_text("quest|resetting_name")
    text = format_text("cur_state", name, "quest|areaquest_resetting")
  else
    local questid = data:get(packet.key.areaquest_excelID).v_int
    local quest_tb = get_table_areaquest(questid)
    local stagesize = quest_tb.stageIDs.size
    local stageidx = data:get(packet.key.areaquest_stageIDx).v_int
    local tb = {}
    tb.cur_stage = stageidx + 1
    tb.total_stage = stagesize
    text = format_text_table(tb, "quest|areaquest_cur")
    item.cur_num = stageidx + 1
    item.total_num = stagesize
  end
  item.box.mtf = text
end
function set_target_item_text(victimid, count, data)
  local target_info = targets_table[victimid]
  local item = target_info.item
  local name = target_info.name
  local stringtext = target_info.stringtext
  local num = target_info.num
  local begin_num = target_info.begin_num
  local tb = {}
  local num_type = data:has(packet.key.areaquest_tarnum_chgtype)
  if num_type == false then
    tb.begin_num = count
    tb.total_num = num
    target_info.begin_num = count
  else
    tb.begin_num = begin_num
    tb.total_num = count
    target_info.num = count
  end
  targets_table[victimid] = target_info
  tb.aim_name = name
  local text = format_text_table(tb, stringtext)
  target_info.box.mtf = text
end
function set_count_item(data)
  local item = areaquest_tracing_init[4]
  if item.stage_count_item == false then
    return
  end
  local state = data:get(packet.key.areaquest_stagestate).v_int
  if state == bo2.eState_Reset then
    return
  end
  local ishave = data:has(packet.key.areaquest_vicitimID)
  if ishave == true then
    local victim_id = data:get(packet.key.areaquest_vicitimID).v_int
    local targetNum = data:get(packet.key.areaquest_count).v_int
    set_target_item_text(victim_id, targetNum, data)
  else
    local counts = data:get(packet.key.areaquest_counts)
    if counts.empty then
      return
    end
    for i = 0, counts.size - 1 do
      local v = counts:get(i)
      local ishave = v:has(packet.key.areaquest_vicitimID)
      local targetNum = v:get(packet.key.areaquest_count).v_int
      if ishave == true then
        local victim_id = v:get(packet.key.areaquest_vicitimID).v_int
        set_target_item_text(victim_id, targetNum, data)
      end
    end
  end
end
function set_my_rank_item(data)
  local rank = data:get(packet.key.areaquest_player_rank).v_int
  local item = areaquest_tracing_init[6]
  local tb = {}
  tb.cha_name = bo2.player.name
  tb.rank_idx = rank
  local text = format_text_table(tb, item.text)
  item.box.mtf = text
  item.value = rank
end
function set_my_totalcontri_item(data)
  local total_contri = data:get(packet.key.areaquest_contri).v_int
  local item = areaquest_tracing_init[7]
  local text = format_text("total_contri", total_contri, item.text)
  item.box.mtf = text
  item.value = total_contri
end
function set_my_curcontri_item(data)
  local cur_contri = data:get(packet.key.areaquest_curcontri).v_int
  local item = areaquest_tracing_init[8]
  local text = format_text("cur_contri", cur_contri, item.text)
  item.box.mtf = text
  item.value = cur_contri
  set_my_curaward_item(data, cur_contri)
end
function set_my_curaward_item(data, cur_contri)
  if cur_contri == nil then
    return
  end
  if data:has(packet.key.areaquest_stageID) == false then
    return
  end
  local stage_id = data:get(packet.key.areaquest_stageID).v_int
  local stage_tb = bo2.gv_quest_areaquest_stage:find(stage_id)
  if stage_tb == nil then
    return
  end
  local baseExp = stage_tb.base_exp
  local baseMoney = stage_tb.base_money
  local perExp = stage_tb.exchange_exp
  local perMoney = stage_tb.exchange_money
  local p_exp = cur_contri * perExp + baseExp
  local p_money = cur_contri * perMoney + baseMoney
  if cur_contri == 0 then
    p_exp = 0
    p_money = 0
  end
  local item1 = areaquest_tracing_init[10]
  local item2 = areaquest_tracing_init[11]
  local text1 = format_text("exp", p_exp, item1.text)
  local text2 = format_text("money", p_money, item2.text)
  item1.box.mtf = text1
  item2.box.mtf = text2
end
function set_rank_list_item_info(data)
  local rank_list = areaquest_list
  rank_list:item_clear()
  local players = data:get(packet.key.areaquest_players)
  if players.empty then
    return
  end
  for i = 0, players.size - 1 do
    local v = players:get(i)
    local item = rank_list:item_append()
    item:load_style("$frame/quest/areaquest_info.xml", L("rank_info"))
    local name = v:get(packet.key.areaquest_player_name).v_string
    local contri = v:get(packet.key.areaquest_contri).v_int
    item:search("player_rank").text = i + 1
    item:search("player_contri").text = contri
    item:search("player_name").text = name
    if bo2.player.name == name then
      item:search("player_rank").color = ui.make_color("FF8000")
      item:search("player_contri").color = ui.make_color("FF8000")
      item:search("player_name").color = ui.make_color("FF8000")
    end
  end
  set_rank(areaquest_id)
end
function set_rank(questid)
  if areaquest_id ~= 0 and questid == areaquest_id then
    ui_quest.ui_mission.set_rank(questid, rank_list)
  end
end
function set_items_info(data)
  set_time_item(data)
  set_stage_item(data)
  set_count_item(data)
  set_my_rank_item(data)
  set_my_totalcontri_item(data)
  set_my_curcontri_item(data)
  set_my_curaward_item(data)
  set_rank_list_item_info(data)
end
function area_show(data)
  local state = data:get(packet.key.areaquest_stagestate).v_int
  if state == bo2.eState_Reset then
    local list_ctrl = g_areaquest_info:search("areaquest_list")
    list_ctrl:item_clear()
    init_stage_info(data)
    set_items_info(data)
  else
    if stage_init == false then
      local list_ctrl = g_areaquest_info:search("areaquest_list")
      list_ctrl:item_clear()
      init_stage_info(data)
    end
    set_items_info(data)
  end
  local quest_excelID = data:get(packet.key.areaquest_excelID).v_int
  areaquest_id = quest_excelID
  if not data:has(packet.key.cmn_system_flag) then
    ui_tracing.on_show_areaquest_info(quest_excelID)
  end
  if data:has(packet.key.areaquest_time_stage) then
    local stage_time = data:get(packet.key.areaquest_time_stage).v_int
    local textid = data:get(packet.key.areaquest_time_textid).v_int
    local type = data:get(packet.key.ui_comtimer_type).v_string
    if stage_time >= 0 then
      if textid == 0 then
        return
      end
      local info = bo2.gv_text:find(textid).text
      ui_dungeonui.open_one_timer(info, stage_time, type, ui_main.get_os_time())
    end
  end
end
function areaquest_area(cmd, data)
  local inArea = data:has(packet.key.areaquest_inArea)
  if inArea == true then
    areaquest_id = 0
    local isInArea = data:get(packet.key.areaquest_inArea).v_int
    if isInArea == 0 then
      stage_init = false
      ui_tracing.on_close_areaquest_info()
      if timer_1.suspended == false then
        timer_1.suspended = true
      end
      ui_dungeonui.ui_common_timer.close_common_timerui(nil, data)
    end
  else
    area_show(data)
  end
end
function areaquest_show(cmd, data)
  area_show(data)
end
function areaquest_count(cmd, data)
  set_count_item(data)
end
function remove_some_items()
  local item = find_stage_item("quest|areaquest_note")
  local list_ctrl = g_areaquest_info:search("areaquest_list")
  if item ~= 0 then
    list_ctrl:item_remove(item.index)
    item = 0
  end
  item = find_stage_item("quest|aim_text")
  if item ~= 0 then
    list_ctrl:item_remove(item.index)
    item = 0
  end
  item = find_stage_item("quest|stage_text")
  if item ~= 0 then
    list_ctrl:item_remove(item.index)
    item = 0
  end
end
function areaquest_stage_new(cmd, data)
  local stageidx = data:get(packet.key.areaquest_stageIDx).v_int
  local state = data:get(packet.key.areaquest_stagestate).v_int
  if stageidx == 0 and state == bo2.eState_Ready then
    stage_init = false
    area_show(data)
  else
    set_time_item(data)
    stage_new_init(data)
    set_count_item(data)
    set_my_curcontri_item(data)
  end
  if state == bo2.eState_Reset then
    remove_some_items()
    set_items_dy()
  end
  if not data:has(packet.key.areaquest_time_stage) then
    ui_dungeonui.ui_common_timer.close_common_timerui()
  end
end
function on_init()
end
function check_update_questUI()
end
function on_timer_1()
  areaquest_total_cd_time = areaquest_total_cd_time - 1
  local item = areaquest_tracing_init[1]
  local cur_time = get_time(areaquest_total_cd_time, item.string_text)
  item.box.mtf = cur_time
  if areaquest_total_cd_time <= 0 then
    areaquest_total_cd_time = 0
    ui_areaquest.timer_1.suspended = true
  end
end
function on_player_tip_make(tip)
  local panel = tip.owner
  if panel == nil then
    return
  end
  local svar_name = panel:search("player_name").text
  ui_widget.tip_make_view(tip.view, svar_name)
end
function on_timer()
end
function areaquest_close(cmd, data)
  local questid = data:get(packet.key.areaquest_excelID).v_int
  local item = areaquest_tracing_init[2]
  local name = ui.get_text("quest|close_time")
  text = format_text("cur_state", name, "quest|areaquest_resetting")
  item.box.mtf = text
  ui_areaquest.timer_1.suspended = true
  local table = get_table_areaquest(questid)
  if table == nil then
    ui.log("areaquest_stage table is error!")
    return
  end
  local beg_time = table.aq_beg_time
  if beg_time.size ~= 2 then
    ui.log("areaquest_stage table aq_beg_time size is error!")
    return
  end
  local hour = beg_time[0]
  local min = beg_time[1]
  if min < 10 then
    min = "0" .. min
  end
  local time = hour .. ":" .. min
  local item = areaquest_tracing_init[1]
  item.box.mtf = format_text("time", time, "quest|close_comment")
  remove_some_items()
end
reg(packet.eSTC_UI_AreaQuest_Area, areaquest_area, sig)
reg(packet.eSTC_UI_AreaQuest_Show, areaquest_show, sig)
reg(packet.eSTC_UI_AreaQuest_Count, areaquest_count, sig)
reg(packet.eSTC_UI_AreaQuest_Update, areaquest_stage_new, sig)
reg(packet.eSTC_UI_AreaQuest_Close, areaquest_close, sig)
