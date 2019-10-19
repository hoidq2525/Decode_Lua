local g_battle_state = 0
local g_my_side = 0
local player_color = {
  [0] = ui.make_color("FF8000"),
  [1] = ui.make_color("0080FF")
}
function on_click_leave(btn)
  if 1 == g_battle_state then
    bo2.send_variant(packet.eCTS_UI_LeaveDungeonScn)
  else
    bo2.send_variant(packet.eCTS_UI_Battle_Surrender)
  end
end
function set_color(item, side)
  item:search("item_1").color = player_color[side]
  item:search("item_2").color = player_color[side]
  item:search("item_3").color = player_color[side]
  item:search("item_4").color = player_color[side]
  item:search("item_5").color = player_color[side]
  item:search("item_6").color = player_color[side]
  item:search("item_7").color = player_color[side]
end
function set_text(item, player)
  item:search("item_1").text = player.name
  item:search("item_2").text = player.dead
  item:search("item_3").text = player.kill
  item:search("item_4").text = player.assist
  item:search("item_5").text = player.life
  item:search("item_6").text = player.exp
  local money_label = item:search("item_7")
  money_label.money = player.money
  if sys.check(player.money_type) and player.money_type == 1 then
    money_label.bounded = true
  end
  if player.item == "" then
    item:search("rich_text").parent.visible = false
  else
    do
      local rich_text = item:search("rich_text")
      local rich_str = ""
      local function set_control(id, count)
        local item = bo2.gv_item_list:find(id)
        if item == nil then
          item = bo2.gv_gem_item:find(id)
          if item == nil then
            item = bo2.gv_equip_item:find(id)
            if item == nil then
              return
            end
          end
        end
        local image_uri = string.format("$icon/item/%s.png|0,0,64,64*16,16", tostring(item.icon))
        rich_str = rich_str .. string.format("<img:%s>x<a:l>%d", image_uri, count)
      end
      string.gsub(tostring(player.item), "(%d+)*(%d+)", set_control)
      rich_text.mtf = rich_str
      rich_text.parent.visible = true
    end
  end
  if player.name == bo2.player.name then
    item:search("myself").visible = true
    g_my_side = player.side
  end
end
function get_player_info(data)
  local player = {}
  player.name = data:get(packet.key.item_key1).v_string
  player.dead = data:get(packet.key.item_key2).v_int
  player.kill = data:get(packet.key.item_key3).v_int
  player.exp = data:get(packet.key.item_key4).v_int
  player.money = data:get(packet.key.item_key5).v_int
  player.item = data:get(packet.key.item_key6).v_string
  player.life = data:get(packet.key.item_key7).v_int
  player.assist = data:get(packet.key.item_key8).v_int
  player.side = data:get(packet.key.battle_side).v_int
  if data:has(packet.key.deal_money) then
    player.money_type = data[packet.key.deal_money]
  else
    player.money_type = 0
  end
  return player
end
function insert_player(player)
  local side = player.side
  local item = gx_battle_all_list:item_insert(0)
  item:load_style("$frame/battle/battle_5v5/cmn_list.xml", "cmn_item")
  set_text(item, player)
  set_color(item, side)
end
function time_info(s)
  gx_battle_all_win:search("use_time").text = s
end
function count_info()
  gx_battle_all_win:search("player_count").text = sys.format(ui.get_text("battle|count_info"), ui.get_text("battle|all_list"), gx_battle_all_list.item_count)
end
function btn_visible(vis)
  local btn = gx_battle_all_win:search("leave_btn")
  btn.visible = vis
  if 1 == g_battle_state then
    btn.text = ui.get_text("battle|btn_leave")
  else
    btn.text = ui.get_text("battle|btn_surrender")
  end
end
function test_build_player()
  local player = {
    name = L("111"),
    side = 0,
    dead = 1,
    kill = 2,
    exp = 100,
    money = 300
  }
  local v = sys.variant()
  v:set(packet.key.item_key1, player.name)
  v:set(packet.key.item_key2, player.dead)
  v:set(packet.key.item_key3, player.kill)
  v:set(packet.key.item_key4, player.exp)
  v:set(packet.key.item_key5, player.money)
  v:set(packet.key.item_key7, player.life)
  v:set(packet.key.item_key8, player.assist)
  v:set(packet.key.battle_side, player.side)
  v:set(packet.key.privilegelvl, 0)
  v:set(packet.key.deal_money, 1)
  if player.money_type ~= nil then
    v:set(packet.key.deal_money, player.money_type)
  end
  return v
end
function r()
  local v = sys.variant()
  local players = sys.variant()
  players:push_back(test_build_player())
  players:push_back(test_build_player())
  v:set(packet.key.battlegroup_players, players)
  v:set(packet.key.battle_usetime, 100)
  show_result(v)
end
function show_result(data)
  gx_battle_all_list:item_clear()
  local players = data:get(packet.key.battlegroup_players)
  local usetime = data:get(packet.key.battle_usetime).v_int
  for i = 0, players.size - 1 do
    local player = get_player_info(players:get(i))
    insert_player(player)
  end
  local minute = math.floor(usetime / 60)
  local second = usetime % 60
  local time_s = sys.format(ui.get_text("battle|use_time"), minute, second)
  local win_side = data:get(packet.key.cmn_rst).v_int
  local v = g_my_side == win_side and 1 or 0
  if g_my_side == win_side then
    v = 1
  elseif 2 == win_side then
    v = -1
  else
    v = 0
  end
  ui_match.cmn_show_result(v)
  time_info(time_s)
  count_info()
  g_battle_state = 1
  btn_visible(true)
  define_compositor("item_3")
  gx_info_list_win.visible = true
end
function updata_player(data)
  gx_battle_all_list:item_clear()
  local players = data:get(packet.key.battlegroup_players)
  for i = 0, players.size - 1 do
    local player = get_player_info(players:get(i))
    insert_player(player)
    if player.name == bo2.player.name then
      ui_battle_5v5.iner.top_updata_player(player.kill, player.dead)
    end
  end
  time_info("")
  count_info()
  define_compositor("item_3")
end
function compare_str(item1, item2, field)
  local str1 = item1:search(field).text
  local str2 = item2:search(field).text
  if str1 > str2 then
    return -1
  elseif str1 == str2 then
    return 0
  end
  return 1
end
function compare_num(item1, item2, field)
  local num1 = item1:search(field).text.v_int
  local num2 = item2:search(field).text.v_int
  if num1 > num2 then
    return -1
  elseif num1 == num2 then
    return 0
  end
  return 1
end
function define_compositor(name)
  local function my_sort(item1, item2)
    if name == L("item_1") then
      return compare_str(item1, item2, name)
    else
      return compare_num(item1, item2, name)
    end
  end
  gx_battle_all_list:item_sort(my_sort)
end
function on_title_btn_click(btn)
  local name = btn.name
  local function my_sort(item1, item2)
    if name == L("item_1") then
      return compare_str(item1, item2, name)
    else
      return compare_num(item1, item2, name)
    end
  end
  gx_battle_all_list:item_sort(my_sort)
end
function insert_tab(name)
  local btn_uri = "$frame/battle/battle_5v5/info.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/battle/battle_5v5/" .. name .. ".xml"
  local page_sty = name
  ui_widget.ui_tab.insert_suit(g_info_list, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_widget.ui_tab.get_button(g_info_list, name)
  name = ui.get_text(sys.format("battle|%s", name))
  btn.text = name
end
function on_info_init()
  insert_tab("all_list")
  ui_widget.ui_tab.show_page(g_info_list, "all_list", true)
end
function reset_inner()
  g_battle_state = 0
  btn_visible(false)
  local set_btn_vis = function()
    btn_visible(true)
  end
  bo2.AddTimeEvent(8250, set_btn_vis)
end
