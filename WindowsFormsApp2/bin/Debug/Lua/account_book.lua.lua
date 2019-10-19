function show_book()
  if ui.quest_find(5001) ~= nil then
    w_main:search("lb_title").text = ui.get_text("sociality|guild_account_book_title")
  elseif ui.quest_find(5011) ~= nil then
    w_main:search("lb_title").text = ui.get_text("sociality|world_account_book_title")
  end
  local player = bo2.player
  local money = player:get_flag_int32(bo2.ePlayerFlagInt32_GFarmMoney)
  w_main:search("money"):search("value_text").money = money
  if 1 == bo2.gv_define_org:find(115).value.v_int then
    w_main:search("money"):search("value_text").bounded = true
  end
  local sell_num = player:get_flag_int32(bo2.ePlayerFlagInt32_GFarmAccountTime)
  local max_sell_num = player:get_flag_int16(bo2.ePlayerFlagInt16_FarmSellNumMax)
  w_main:search("left_sell_num"):search("value_text").text = max_sell_num - sell_num
  w_main:search("sell_num_max"):search("value_text").text = max_sell_num
  local player_name = bo2.player.name
  w_main:search("owner"):search("value_text").text = player_name
  local guild_name = ui.guild_name()
  w_main:search("guild"):search("value_text").text = guild_name
  w_main.visible = true
end
function on_close_click(btn)
  w_main.visible = false
end
function on_show_click(btn)
  if w_main.visible == true then
    w_main.visible = false
  else
    show_book()
  end
  close_flicker()
end
function on_make_show_btn_tip(tip)
  if ui.quest_find(5001) ~= nil then
    ui_widget.tip_make_view(tip.view, ui.get_text("sociality|guild_account_book_title"))
  elseif ui.quest_find(5011) ~= nil then
    ui_widget.tip_make_view(tip.view, ui.get_text("sociality|world_account_book_title"))
  end
end
function on_show_btn_timer(timer)
  on_show_btn()
end
function on_show_btn()
  local player = bo2.player
  if player ~= nil and sys.check(player) == true then
    local have_farm_quest = player:get_flag_bit(bo2.ePlayerFlagBit_IsHaveFarmQuest)
    if have_farm_quest == 1 then
    end
  else
  end
end
function on_flicker_timer(timer)
  close_flicker()
end
function close_flicker()
  w_show_btn_flicker.visible = false
  w_show_btn_flicker.suspended = true
  w_flicker_timer.suspended = true
end
function on_move(ctrl, pos)
  if ctrl.x + ctrl.dx > 870 then
    ctrl.x = 870 - ctrl.dx
  end
  if ctrl.x < 50 then
    ctrl.x = 50
  end
  if ctrl.y + ctrl.dy > 660 then
    ctrl.y = 660 - ctrl.dy
  end
  if ctrl.y < 30 then
    ctrl.y = 30
  end
end
