function open_lottory(gread)
  g_ui_lottery:search("gread_pic").image = SHARED(sys.format("$image/rand_event/%d.png", gread))
  g_score_wnd.visible = false
  g_ui_lottery.visible = true
  g_ui_lottery:search("next_btn").enable = false
  for i = 1, 10 do
    local card = g_ui_lottery:search("card_" .. i)
    card:search("box_picture_panel").visible = false
    card:search("card_btn").enable = true
    card:search("select").visible = false
  end
end
function card_on_click(btn)
  local btn_table = {
    card_1,
    card_2,
    card_3,
    card_4,
    card_5,
    card_6,
    card_7,
    card_8,
    card_9,
    card_10
  }
  for k, v in pairs(btn_table) do
    v:search("card_btn").enable = false
  end
  local i = 1
  while btn_table[i]:search("card_btn") ~= btn do
    i = i + 1
  end
  local v = sys.variant()
  v:set(packet.key.cmn_id, bo2.player.only_id)
  v:set(packet.key.lottery_btn, i)
  v:set(packet.key.cmn_type, gx_grade)
  bo2.send_variant(packet.eCTS_Lottery_Scncopy, v)
end
function lucky_draw()
  local line = bo2.gv_dungeon_lottery:find(gx_grade)
  local j = bo2.rand(1, 100) / 10
  local box = 5
  local temp = 0
  while box > 0 do
    temp = temp + line["box_" .. box]
    if j <= temp then
      break
    end
    box = box - 1
  end
  if box <= 0 then
    box = 5
  end
  return box
end
function award_infor(data)
  local item_control = {
    item_1,
    item_2,
    item_3,
    item_4,
    item_5,
    item_6
  }
  local item_string = data:get(packet.key.lottery_prop).v_string
  for i = 1, 6 do
    item_control[i].visible = false
  end
  local item_table = {}
  local i = 1
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
    item_control[i]:search("item_picture").image = SHARED("$icon/item/" .. item.icon .. ".png|3,3,58,58")
    item_control[i]:search("item_count").text = count
    item_control[i]:search("item_name").text = item.name
    item_control[i].visible = true
    i = i + 1
  end
  string.gsub(tostring(item_string), "(%d+)*(%d+)", set_control)
  g_ui_lottery:search("next_btn").enable = true
end
