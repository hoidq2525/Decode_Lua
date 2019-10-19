local reg = ui_packet.game_recv_signal_insert
local sig = "ui_battle_common.packet_handler"
local g_cur_battle_type = -1
local model_function = {
  [bo2.eBattleType_A] = {
    [packet.eSTC_UI_Battle_Updata_Player] = ui_battle_01.handleUpdataPlayer,
    [packet.eSTC_UI_Battle_Init_Iner] = ui_battle_01.handleResetIner,
    [packet.eSTC_UI_Battle_Close_Iner] = ui_battle_01.handleCloseIner,
    [packet.eSTC_UI_Battle_Updata_Occupy] = ui_battle_01.handleUpdataOccupy,
    [packet.eSTC_UI_Battle_Clock] = ui_battle_01.handleSetClock,
    [packet.eSTC_UI_Battle_Result] = ui_battle_01.handleShowResult
  },
  [bo2.eBattleType_B] = {
    [packet.eSTC_UI_Battle_Updata_Player] = ui_battle_02.handleUpdataPlayer,
    [packet.eSTC_UI_Battle_Init_Iner] = ui_battle_02.handleResetIner,
    [packet.eSTC_UI_Battle_Close_Iner] = ui_battle_02.handleCloseIner,
    [packet.eSTC_UI_Battle_Updata_Occupy] = ui_battle_02.handleUpdataOccupy,
    [packet.eSTC_UI_Battle_Clock] = ui_battle_02.handleSetClock,
    [packet.eSTC_UI_Battle_Result] = ui_battle_02.handleShowResult,
    ["open_info_win"] = ui_battle_02.open_info_win
  },
  [bo2.eBattleType_C] = {
    [packet.eSTC_UI_Battle_Updata_Player] = ui_battle_03.handleUpdataPlayer,
    [packet.eSTC_UI_Battle_Init_Iner] = ui_battle_03.handleResetIner,
    [packet.eSTC_UI_Battle_Close_Iner] = ui_battle_03.handleCloseIner,
    [packet.eSTC_UI_Battle_Clock] = ui_battle_03.handleSetClock,
    [packet.eSTC_UI_Battle_Result] = ui_battle_03.handleShowResult,
    [packet.eSTC_UI_Battle_ShowPlayer] = ui_battle_03.handleUpdatePoint,
    ["open_info_win"] = ui_battle_03.open_info_win
  },
  [bo2.eBattleType_D] = {
    [packet.eSTC_UI_Battle_Updata_Player] = ui_battle_04.handleUpdataPlayer,
    [packet.eSTC_UI_Battle_Init_Iner] = ui_battle_04.handleResetIner,
    [packet.eSTC_UI_Battle_Close_Iner] = ui_battle_04.handleCloseIner,
    [packet.eSTC_UI_Battle_Updata_Occupy] = ui_battle_04.handleUpdataOccupy,
    [packet.eSTC_UI_Battle_Clock] = ui_battle_04.handleSetClock,
    [packet.eSTC_UI_Battle_Result] = ui_battle_04.handleShowResult,
    ["open_info_win"] = ui_battle_04.open_info_win
  },
  [bo2.eBattleType_HorseRacing] = {
    [packet.eSTC_UI_Battle_Init_Iner] = ui_battle_horse_racing.handleResetIner,
    [packet.eSTC_UI_Battle_Updata_Player] = ui_battle_horse_racing.handleUpdataPlayer,
    [packet.eSTC_UI_Battle_Clock] = ui_battle_horse_racing.handleSetClock,
    [packet.eSTC_UI_Battle_Close_Iner] = ui_battle_horse_racing.handleCloseIner,
    [packet.eSTC_UI_Battle_Result] = ui_horse_racing.on_player_comp
  },
  [bo2.eBattleType_12p] = {
    [packet.eSTC_UI_Battle_Updata_Player] = ui_battle_12p.handleUpdataPlayer,
    [packet.eSTC_UI_Battle_Init_Iner] = ui_battle_12p.handleResetIner,
    [packet.eSTC_UI_Battle_Close_Iner] = ui_battle_12p.handleCloseIner,
    [packet.eSTC_UI_Battle_Clock] = ui_battle_12p.handleSetClock,
    [packet.eSTC_UI_Battle_Result] = ui_battle_12p.handleShowResult,
    [packet.eSTC_UI_Battle_ShowPlayer] = ui_battle_12p.handleUpdatePoint,
    ["open_info_win"] = ui_battle_12p.open_info_win
  },
  [bo2.eBattleType_5v5] = {
    [packet.eSTC_UI_Battle_Updata_Player] = ui_battle_5v5.handleUpdataPlayer,
    [packet.eSTC_UI_Battle_Init_Iner] = ui_battle_5v5.handleResetIner,
    [packet.eSTC_UI_Battle_Close_Iner] = ui_battle_5v5.handleCloseIner,
    [packet.eSTC_UI_Battle_Clock] = ui_battle_5v5.handleSetClock,
    [packet.eSTC_UI_Battle_Result] = ui_battle_5v5.handleShowResult,
    [packet.eSTC_UI_Battle_ShowPlayer] = ui_battle_5v5.handleUpdatePoint,
    ["open_info_win"] = ui_battle_5v5.open_info_win
  },
  [bo2.eBattleType_Team] = {
    [packet.eSTC_UI_Battle_Updata_Player] = ui_battle_team.handleUpdataPlayer,
    [packet.eSTC_UI_Battle_Init_Iner] = ui_battle_team.handleResetIner,
    [packet.eSTC_UI_Battle_Close_Iner] = ui_battle_team.handleCloseIner,
    [packet.eSTC_UI_Battle_Clock] = ui_battle_team.handleSetClock,
    [packet.eSTC_UI_Battle_Result] = ui_battle_team.handleShowResult,
    [packet.eSTC_UI_Battle_ShowPlayer] = ui_battle_team.handleUpdatePoint,
    [packet.eSTC_UI_Battle_Updata_Occupy] = ui_battle_team.handleUpdataOccupy,
    ["open_info_win"] = ui_battle_team.open_info_win
  },
  [bo2.eBattleType_FlyRacing] = {
    [packet.eSTC_UI_Battle_Init_Iner] = ui_battle_fly_racing.handleResetIner,
    [packet.eSTC_UI_Battle_Updata_Player] = ui_battle_fly_racing.handleUpdataPlayer,
    [packet.eSTC_UI_Battle_Clock] = ui_battle_fly_racing.handleSetClock,
    [packet.eSTC_UI_Battle_Close_Iner] = ui_battle_fly_racing.handleCloseIner
  },
  [bo2.eBattleType_5v5green] = {
    [packet.eSTC_UI_Battle_Updata_Player] = ui_battle_5v5green.handleUpdataPlayer,
    [packet.eSTC_UI_Battle_Init_Iner] = ui_battle_5v5green.handleResetIner,
    [packet.eSTC_UI_Battle_Close_Iner] = ui_battle_5v5green.handleCloseIner,
    [packet.eSTC_UI_Battle_Clock] = ui_battle_5v5green.handleSetClock,
    [packet.eSTC_UI_Battle_Result] = ui_battle_5v5green.handleShowResult,
    [packet.eSTC_UI_Battle_ShowPlayer] = ui_battle_5v5green.handleUpdatePoint,
    ["open_info_win"] = ui_battle_5v5green.open_info_win
  },
  [bo2.eBattleType_5v5green2] = {
    [packet.eSTC_UI_Battle_Updata_Player] = ui_battle_5v5green.handleUpdataPlayer,
    [packet.eSTC_UI_Battle_Init_Iner] = ui_battle_5v5green.handleResetIner,
    [packet.eSTC_UI_Battle_Close_Iner] = ui_battle_5v5green.handleCloseIner,
    [packet.eSTC_UI_Battle_Clock] = ui_battle_5v5green.handleSetClock,
    [packet.eSTC_UI_Battle_Result] = ui_battle_5v5green.handleShowResult,
    [packet.eSTC_UI_Battle_ShowPlayer] = ui_battle_5v5green.handleUpdatePoint,
    ["open_info_win"] = ui_battle_5v5green.open_info_win
  },
  [bo2.eBattleType_ciwangshajia] = {
    [packet.eSTC_UI_Battle_Updata_Player] = ui_battle_assassin.handleUpdataPlayer,
    [packet.eSTC_UI_Battle_Init_Iner] = ui_battle_assassin.handleResetIner,
    [packet.eSTC_UI_Battle_Close_Iner] = ui_battle_assassin.handleCloseIner,
    [packet.eSTC_UI_Battle_Clock] = ui_battle_assassin.handleSetClock,
    [packet.eSTC_UI_Battle_Result] = ui_battle_assassin.handleShowResult,
    [packet.eSTC_UI_Battle_ShowPlayer] = ui_battle_assassin.handleUpdatePoint,
    ["open_info_win"] = ui_battle_assassin.open_info_win
  }
}
function handleBattleCmd(cmd, data)
  local my_type = data:get(packet.key.battle_type).v_int
  local fn = model_function[my_type][cmd]
  if fn ~= nil then
    fn(data)
  end
  if cmd == packet.eSTC_UI_Battle_Init_Iner then
    g_cur_battle_type = my_type
  elseif cmd == packet.eSTC_UI_Battle_Close_Iner then
    g_cur_battle_type = -1
  end
end
reg(packet.eSTC_UI_Battle_Updata_Player, handleBattleCmd, sig)
reg(packet.eSTC_UI_Battle_Init_Iner, handleBattleCmd, sig)
reg(packet.eSTC_UI_Battle_Close_Iner, handleBattleCmd, sig)
reg(packet.eSTC_UI_Battle_Updata_Occupy, handleBattleCmd, sig)
reg(packet.eSTC_UI_Battle_Clock, handleBattleCmd, sig)
reg(packet.eSTC_UI_Battle_Result, handleBattleCmd, sig)
reg(packet.eSTC_UI_Battle_ShowPlayer, handleBattleCmd, sig)
function open_info_win()
  if g_cur_battle_type == -1 then
    return
  end
  local fn = model_function[g_cur_battle_type].open_info_win
  if fn == nil then
    return
  end
  fn()
end
function btn01_apply_click(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 0)
  v:set(packet.key.battle_type, 1)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function btn01_team_click(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 0)
  v:set(packet.key.battle_type, 2)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function btn02_apply_click(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 0)
  v:set(packet.key.battle_type, 3)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function btn02_team_click(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 0)
  v:set(packet.key.battle_type, 4)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function btn03_apply_click(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 0)
  v:set(packet.key.battle_type, 5)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function btn03_team_click(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 0)
  v:set(packet.key.battle_type, 6)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function btn_flyracing_click(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 0)
  v:set(packet.key.battle_type, 7)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function btn_5v5green_click(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 0)
  v:set(packet.key.battle_type, 8)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function btn_5v5green_click2(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 0)
  v:set(packet.key.battle_type, 9)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function btn_ciwangshajia_click(btn)
  local v = sys.variant()
  v:set(packet.key.cmn_type, 0)
  v:set(packet.key.battle_type, 10)
  bo2.send_variant(packet.eCTS_UI_Battle_Apply, v)
end
function set_topinfo_vis()
  local scn_type = bo2.gv_scn_alloc:find(bo2.scn.scn_excel.id).type
  if scn_type == 0 then
    g_cur_battle_type = -1
    for _, fun in pairs(model_function) do
      fun[packet.eSTC_UI_Battle_Close_Iner]()
    end
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
  players:push_back(ui_battle_common.test_build_player())
  players:push_back(ui_battle_common.test_build_player())
  v:set(packet.key.battlegroup_players, players)
  v:set(packet.key.battle_usetime, 100)
  ui_battle_assassin.info_list.show_result(v)
end
function show()
  battle_common_win.visible = true
end
