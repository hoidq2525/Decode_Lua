local flicker_count = 0
local item_size = 40
local g_popo_name = {
  [bo2.eWaitList_Arena] = "arena_dooaltar",
  [bo2.eWaitList_Match] = "arena",
  [bo2.eWaitList_BattleA] = "battle_0",
  [bo2.eWaitList_BattleB] = "battle_1",
  [bo2.eWaitList_BattleC] = "battle_2",
  [bo2.eWaitList_BattleD] = "battle_3",
  [bo2.eWaitList_HorseRacing] = "battle_4",
  [bo2.eWaitList_Battle12p] = "battle_5",
  [bo2.eWaitList_Battle5v5] = "battle_6",
  [bo2.eWaitList_FlyRacing] = "battle_7",
  [bo2.eWaitList_Battle5v5green] = "battle_8",
  [bo2.eWaitList_Battle5v5green2] = "battle_9",
  [bo2.eWaitList_BattleCiwangshajia] = "battle_ciwangshajia",
  [bo2.eWaitList_Trans_dungeon] = "jiaobenpopo",
  [bo2.eWaitList_TheBestFighter] = "the_best_fighter",
  [bo2.eWaitList_Act3v3] = "arena_3v3",
  [bo2.eWaitList_BattleTeam] = "battle_10"
}
local g_tip_text = {
  [bo2.eWaitList_Arena] = "wait_list|item_type_7",
  [bo2.eWaitList_Match] = "wait_list|item_type_6",
  [bo2.eWaitList_BattleA] = "wait_list|item_type_0",
  [bo2.eWaitList_BattleB] = "wait_list|item_type_1",
  [bo2.eWaitList_BattleC] = "wait_list|item_type_2",
  [bo2.eWaitList_BattleD] = "wait_list|item_type_3",
  [bo2.eWaitList_HorseRacing] = "wait_list|item_type_10",
  [bo2.eWaitList_Battle12p] = "wait_list|battle_12p",
  [bo2.eWaitList_Battle5v5] = "wait_list|battle_5v5",
  [bo2.eWaitList_FlyRacing] = "wait_list|fly_racing",
  [bo2.eWaitList_Battle5v5green] = "wait_list|battle_5v5green",
  [bo2.eWaitList_Battle5v5green2] = "wait_list|battle_5v5green",
  [bo2.eWaitList_BattleCiwangshajia] = "wait_list|ciwangshajia",
  [bo2.eWaitList_Trans_dungeon] = "wait_list|item_type_8",
  [bo2.eWaitList_TheBestFighter] = "wait_list|the_best_fighter",
  [bo2.eWaitList_Act3v3] = "wait_list|item_type_6",
  [bo2.eWaitList_BattleTeam] = "wait_list|item_type_9"
}
function on_waitlist_visible(btn)
  ui_widget.ui_popup.show(gx_win_waitlist, panel, "y1")
  ui_tool.ui_xinshou_animation_xz.gx_waitlist_popo.visible = false
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
function on_timer()
  local wait_count = 0
  local remove_table = {}
  local cur_time = 0
  if gx_waitlist.item_count == 0 then
    gx_timer.suspended = true
    gx_btn_light.suspended = true
    gx_btn_light.visible = false
    return
  end
  for i = 1, gx_waitlist.item_count do
    local item = gx_waitlist:item_get(i - 1)
    if item.svar.countdown == true then
      if 0 >= item.svar.waittime then
        item.svar.countdown = false
        table.insert(remove_table, item.svar)
      else
        wait_count = wait_count + 1
        item.svar.waittime = item.svar.waittime - 1
        cur_time = get_time(item.svar.waittime, "wait_list|wait_time_2")
      end
    else
      item.svar.waittime = item.svar.waittime + 1
      cur_time = get_time(item.svar.waittime, "wait_list|wait_time")
    end
    item:search("time").text = cur_time
  end
  for i, v in pairs(remove_table) do
    remove_item(v)
  end
  if wait_count ~= 0 then
    gx_btn_light.suspended = false
    gx_btn_light.visible = true
  else
    gx_btn_light.suspended = true
    gx_btn_light.visible = false
  end
end
function win_on_visible(panel, vis)
  if vis == true then
    local remove_table = {}
    local cur_time = 0
    local cur_true_time = os.time()
    for i = 1, gx_waitlist.item_count do
      local item = gx_waitlist:item_get(i - 1)
      if item.svar.countdown == true then
        item.svar.waittime = item.svar.cd_time - (cur_true_time - item.svar.begintime)
        if 0 >= item.svar.waittime then
          item.svar.waittime = 0
          table.insert(remove_table, item.svar)
        end
        cur_time = get_time(item.svar.waittime, "wait_list|wait_time_2")
        item:search("time").text = cur_time
      else
        item.svar.waittime = cur_true_time - item.svar.begintime
        cur_time = get_time(item.svar.waittime, "wait_list|wait_time")
        item:search("time").text = cur_time
      end
    end
    for i, v in pairs(remove_table) do
      remove_item(v)
    end
    gx_timer.suspended = false
  end
end
function reset_list_size(count)
  local win_dy = gx_win_waitlist.dy
  local raise_dy = 0
  raise_dy = item_size * count
  gx_win_waitlist.dy = win_dy + raise_dy
end
function find_item_by_type(msg_type)
  for i = 1, gx_waitlist.item_count do
    local item = gx_waitlist:item_get(i - 1)
    if item.svar.type == msg_type then
      return item
    end
  end
end
function insert_item(msg)
  local item = find_item_by_type(msg.type)
  if item ~= nil then
    return
  end
  item = gx_waitlist:item_insert(0)
  item:load_style("$frame/minimap/waitlist.xml", "wait_item")
  item:search("title").text = ui.get_text(g_tip_text[msg.type])
  item:search("time").text = "00:00"
  if msg.btn_text ~= nil then
    item:search("item_btn").text = msg.btn_text
  else
    item:search("item_btn").text = ui.get_text("wait_list|wait_list_leave")
  end
  item.svar.type = msg.type
  item.svar.message = msg.message
  item.svar.msg_packet = msg.msg_packet
  item.svar.waittime = 0
  if msg.begin_time ~= nil then
    item.svar.begintime = msg.begin_time
  else
    item.svar.begintime = os.time()
  end
  if msg.countdown == 1 then
    item.svar.countdown = true
    item.svar.cd_time = msg.cd_time
  end
  reset_list_size(1)
  if gx_waitlist.item_count ~= 0 then
    ui_minimap.gx_waitlist_minibtn.visible = true
  end
  return item
end
function remove_item(msg)
  local item = find_item_by_type(msg.type)
  if item == nil then
    return
  end
  if item.svar.type == bo2.eWaitList_Match then
    ui_popo.del_popo_by_name("arena")
  elseif item.svar.type == bo2.eWaitList_Arena then
    ui_popo.del_popo_by_name("arena_dooaltar")
  elseif item.svar.type == bo2.eWaitList_Act3v3 then
    ui_popo.del_popo_by_name("arena_3v3")
  end
  item:self_remove()
  reset_list_size(-1)
  if gx_waitlist.item_count == 0 then
    ui_minimap.gx_waitlist_minibtn.visible = false
    gx_win_waitlist.visible = false
    gx_btn_light.suspended = true
    gx_btn_light.visible = false
    ui_tool.ui_xinshou_animation_xz.gx_waitlist_popo.visible = false
  end
end
function set_cd_info(item, max_time)
  item.svar.begintime = os.time()
  item.svar.cd_time = max_time
  item.svar.waittime = max_time
  item.svar.countdown = true
  gx_btn_light.suspended = false
  gx_btn_light.visible = true
  gx_timer.suspended = false
end
function updata_item(msg)
  local item = find_item_by_type(msg.type)
  if item == nil and msg.type ~= bo2.eWaitList_BattleTeam and msg.type ~= bo2.eWaitList_TheBestFighter then
    return
  end
  if msg.type == bo2.eWaitList_BattleTeam or msg.type == bo2.eWaitList_TheBestFighter then
    item = insert_item(msg)
  end
  if msg.btn_text ~= nil then
    item:search("item_btn").text = msg.btn_text
  else
    item:search("item_btn").text = ui.get_text("wait_list|wait_list_enter")
  end
  if msg.countdown ~= nil then
    set_cd_info(item, msg.cd_time)
  elseif msg.type == bo2.eWaitList_Match then
    set_cd_info(item, 30)
  elseif msg.type == bo2.eWaitList_Arena then
    set_cd_info(item, 30)
  elseif msg.type == bo2.eWaitList_Act3v3 then
    set_cd_info(item, 60)
  elseif msg.type < bo2.eWaitList_Battle_End then
    set_cd_info(item, 60)
  elseif msg.type == bo2.eWaitList_BattleTeam then
    set_cd_info(item, 60)
  end
  item.svar.message = msg.message
  item.svar.msg_packet = msg.msg_packet
end
function on_btn_click(btn)
  local item = btn.parent
  local msg = item.svar.message
  local msg_packet = item.svar.msg_packet
  bo2.send_variant(msg, msg_packet)
  local popo_name = g_popo_name[item.svar.type]
  if popo_name ~= nil then
    ui_popo.del_popo_by_name(popo_name)
  end
  gx_win_waitlist.visible = false
end
function on_btn_light_timer()
end
function on_wait_list_init(panel)
  gx_waitlist:item_clear()
  ui_minimap.gx_waitlist_minibtn.visible = false
  gx_win_waitlist.visible = false
end
