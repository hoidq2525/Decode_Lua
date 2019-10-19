local sig_name = "ui_horse_racing:update_player"
local rank_comp = 10000
local scn_inc = {
  [112] = {
    check_pos = {
      [1] = {
        count = 1,
        x = 2598,
        y = 1447,
        x1 = 2545,
        y1 = 1949,
        x2 = 2969,
        y2 = 1447
      },
      [2] = {
        count = 2,
        x = 1710,
        y = 1269,
        x1 = 1710,
        y1 = 1448,
        x2 = 2700,
        y2 = 1201
      },
      [3] = {
        count = 3,
        x = 1542,
        y = 1880,
        x1 = 1400,
        y1 = 1880,
        x2 = 1709,
        y2 = 1180
      },
      [4] = {
        count = 4,
        x = 1731,
        y = 2443,
        x1 = 1475,
        y1 = 2560,
        x2 = 1825,
        y2 = 1881
      }
    }
  },
  [153] = {
    check_pos = {
      [1] = {
        count = 1,
        x = 570,
        y = 1752,
        x1 = 514,
        y1 = 2105,
        x2 = 1742,
        y2 = 1752
      },
      [2] = {
        count = 2,
        x = 688,
        y = 1243,
        x1 = 460,
        y1 = 1753,
        x2 = 888,
        y2 = 1243
      },
      [3] = {
        count = 3,
        x = 595,
        y = 1244,
        x1 = 366,
        y1 = 1244,
        x2 = 906,
        y2 = 285
      }
    }
  }
}
local COLOR_COMP = ui.make_color(SHARED("4D4D4D"))
local check_pos = {}
local area_max = 0
function shadow_item(item, obj, rank)
  item:search("name").text = obj.name
  local image1 = math.floor(rank / 10)
  local image2 = rank % 10
  item:search("rank_image1").image = sys.format(L("$image/match_cmn/match_count/%d.png|6,10,30,30"), image1)
  item:search("rank_image2").image = sys.format(L("$image/match_cmn/match_count/%d.png|6,10,30,30"), image2)
  item.svar.obj = obj
  item.svar.dis = 100000
  item.svar.step = 1
  item.svar.comp = false
end
function reshow()
  for i = 0, g_my_list.item_count - 1 do
    local item = g_my_list:item_get(i)
    local rank = i + 1
    local image1 = math.floor(rank / 10)
    local image2 = rank % 10
    item:search("rank_image1").image = sys.format(L("$image/match_cmn/match_count/%d.png|6,10,30,30"), image1)
    item:search("rank_image2").image = sys.format(L("$image/match_cmn/match_count/%d.png|6,10,30,30"), image2)
    if item:search("name").text == bo2.player.name then
      horse_racing_win:search("myinfo_rank_image1").image = sys.format(L("$image/match_cmn/match_count/%d.png|6,10,30,30"), image1)
      horse_racing_win:search("myinfo_rank_image2").image = sys.format(L("$image/match_cmn/match_count/%d.png|6,10,30,30"), image2)
    end
  end
end
function on_playerin(obj)
  for i = 0, g_my_list.item_count - 1 do
    local item = g_my_list:item_get(i)
    if item.svar.obj.name == obj.name then
      return
    end
  end
  local item = g_my_list:item_append()
  item:load_style("$frame/horse_racing/horse_racing.xml", "cmn_item")
  shadow_item(item, obj, g_my_list.item_count)
end
function on_playerout(obj)
  if obj == bo2.player then
    on_self_leave(obj)
    return
  end
  for i = 0, g_my_list.item_count - 1 do
    local item = g_my_list:item_get(i)
    if item.svar.obj == obj and item.svar.comp ~= true then
      g_my_list:item_remove(i)
      break
    end
  end
  reshow()
end
function dis_sort(v1, v2)
  local svar1, svar2 = v1.svar, v2.svar
  if svar1.step < svar2.step then
    return 1
  elseif svar1.step > svar2.step then
    return -1
  else
    local dis1, dis2 = math.abs(svar1.dis), math.abs(svar2.dis)
    if dis1 < dis2 then
      return -1
    elseif dis1 == dis2 then
      return 0
    else
      return 1
    end
  end
end
function get_area(x, y)
  local i = area_max
  while i > 0 do
    local area = check_pos[i]
    if x > area.x1 and x < area.x2 and y < area.y1 and y > area.y2 then
      return area
    end
    i = i - 1
  end
  return nil
end
function update_dis(step, x, y, src_dis)
  local pos = check_pos[step]
  local area = get_area(x, y)
  if area == nil then
    return 0, 1000000
  end
  local dx = area.x - x
  local dy = area.y - y
  local dis = dx * dx + dy * dy
  return area.count, dis
end
function on_tick()
  local dis_table = {}
  for i = 0, g_my_list.item_count - 1 do
    local item = g_my_list:item_get(i)
    if item.svar.step < 1000 then
      local x, y = item.svar.obj:get_position()
      item.svar.step, item.svar.dis = update_dis(item.svar.step, x, y, item.svar.dis)
    end
    if item.svar.comp == true then
      item:search("rank_image1").color = COLOR_COMP
      item:search("rank_image2").color = COLOR_COMP
      item:search("name").color = COLOR_COMP
    end
  end
  g_my_list:item_sort(dis_sort)
  reshow()
end
function on_player_comp(data)
  local name = data:get(packet.key.cmn_name).v_string
  for i = 0, g_my_list.item_count - 1 do
    local item = g_my_list:item_get(i)
    if item.svar.obj.name == name then
      item.svar.step = rank_comp
      item.svar.dis = 0
      item.svar.comp = true
      rank_comp = rank_comp - 1
      return
    end
  end
end
function on_self_leave(obj)
  if sys.check(bo2.scn) == false then
    return
  end
  local scnid = bo2.scn.scn_excel.id
  if scn_inc[scnid] ~= nil then
    horse_racing_win.visible = false
    g_my_list:item_clear()
    g_timer.suspended = true
    bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enter_scn, sig_name)
    bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_leave_scn, sig_name)
  end
end
function on_self_in(obj)
  local scnid = bo2.scn.scn_excel.id
  if scn_inc[scnid] ~= nil then
    check_pos = scn_inc[scnid].check_pos
    area_max = #check_pos
    rank_comp = 10000
    horse_racing_win:search("myinfo_name").text = bo2.player.name
    horse_racing_win:search("myinfo_rank_image1").image = sys.format(L("$image/match_cmn/match_count/%d.png|6,10,30,30"), 0)
    horse_racing_win:search("myinfo_rank_image2").image = sys.format(L("$image/match_cmn/match_count/%d.png|6,10,30,30"), 0)
    horse_racing_win.visible = true
    g_my_list:item_clear()
    on_playerin(obj)
    g_timer.suspended = false
    bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enter_scn, on_playerin, sig_name)
    bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_leave_scn, on_playerout, sig_name)
  end
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_in, sig_name)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_leave, on_self_leave, sig_name)
