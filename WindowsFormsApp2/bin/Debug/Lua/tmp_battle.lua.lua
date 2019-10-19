local second = 100
local tick_update
local battle_list = {
  guild1 = "1234567890123456",
  guild2 = "1234567890123456",
  sum1 = "20",
  sum2 = "15",
  cds = 123,
  times = "sj",
  curtag = true,
  pasttag = false,
  pastguild = "",
  pastsum = 0,
  pasttext = ""
}
local ending = {
  [1] = ui.get_text(L("info_tip|win1")),
  [2] = ui.get_text(L("info_tip|win2")),
  [3] = ui.get_text(L("info_tip|win3")),
  [0] = ui.get_text(L("info_tip|tie")),
  [4] = ui.get_text(L("info_tip|forcecut"))
}
local tm = {
  yy = ui.get_text(L("info_tip|year")),
  mm = ui.get_text(L("info_tip|month")),
  dd = ui.get_text(L("info_tip|day")),
  HH = ui.get_text(L("info_tip|hour")),
  MM = ui.get_text(L("info_tip|minute"))
}
function counting(tms)
  local ss = tms % 60
  local text = ""
  local mm = (tms - ss) / 60
  if mm < 10 then
    text = text .. "0"
  end
  text = text .. mm .. ":"
  if ss < 10 then
    text = text .. "0"
  end
  text = text .. ss
  return text
end
function date_chg(tms)
  local f = function(x)
    local text = ""
    if x > 9 then
      text = x
    else
      text = "0" .. x
    end
    return text
  end
  return tms.year .. tm.yy .. tms.month .. tm.mm .. tms.day .. tm.dd .. f(tms.hour) .. tm.HH .. f(tms.min) .. tm.MM
end
function on_tmpbattle_show(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
end
function on_timer()
  if tick_update == nil then
    if ui_info_tip.find_item(ui_info_tip.tmp_battle.tmpbattle_cd) == false then
      ui_info_tip.tmp_battle.tmpbattle_cd.visible = false
    end
    return
  end
  if battle_list.curtag == false then
    return
  end
  local ds = math.floor(sys.dtick(sys.tick(), tick_update) / 1000)
  ds = battle_list.cds - ds
  tmpbattle_cd:search("s_cd"):search("title_text").text = counting(ds)
  if ds == 0 then
    ui_info_tip.schedule_cd.sch_cd.visible = false
    tick_update = nil
  end
end
function on_update_data()
  curinfo_null.visible = not battle_list.curtag
  curinfo.visible = battle_list.curtag
  local text = ""
  if battle_list.pasttag == false then
    text = ui.get_text(L("info_tip|pastinfonull"))
  else
    text = battle_list.times .. ui.get_text(L("info_tip|past1")) .. battle_list.pastguild .. ui.get_text(L("info_tip|past2"))
    if battle_list.pastsum == 0 then
      text = text .. ui.get_text("info_tip|tie")
    elseif battle_list.pastsum == 4 then
      text = text .. ui.get_text("info_tip|forcecut")
    elseif battle_list.pastsum > 0 then
      text = text .. ui.get_text("info_tip|us") .. ending[battle_list.pastsum] .. ui.get_text("info_tip|ended")
    else
      text = text .. ui.get_text("info_tip|they") .. ending[0 - battle_list.pastsum] .. ui.get_text("info_tip|ended")
    end
  end
  tmpbattle_cd:search("pastinfo").mtf = text
  if battle_list.curtag == true then
    tmpbattle_cd:search("guildname1"):search("title_text2").text = battle_list.guild1
    tmpbattle_cd:search("guildname2"):search("title_text2").text = battle_list.guild2
    tmpbattle_cd:search("s_sum1"):search("title_text").text = battle_list.sum1
    tmpbattle_cd:search("s_sum2"):search("title_text").text = battle_list.sum2
    tmpbattle_cd:search("kill"):search("title_text").text = ui.get_text(L("info_tip|kills"))
  end
  ui_info_tip.on_click_add_msg(ui_info_tip.info_tip_inc.tmpbattle_info)
end
function get_tmpbattle_curflag()
  return battle_list.curtag
end
function on_set_data(cmd, data)
  local curtmpbattle = data:get(packet.key.guild_curtmpbattletag).v_int == 1
  if curtmpbattle == false then
    battle_list.curtag = false
  else
    battle_list.curtag = true
    battle_list.guild2 = data:get(packet.key.guild_tmpbattleguild)
    local function make_time()
      battle_list.cds = data:get(packet.key.guild_tmpbattleendtime).v_int - ui_main.get_os_time()
      ui.log(battle_list.cds)
      tick_update = sys.tick()
    end
    sys.fp_pcall(make_time)
  end
  battle_list.sum1 = data:get(packet.key.guild_tmpbattlekill1).v_int
  battle_list.sum2 = data:get(packet.key.guild_tmpbattlekill2).v_int
  if data:get(packet.key.guild_pasttmpbattletag).v_int == 0 then
    battle_list.pasttag = false
  else
    battle_list.pasttag = true
    battle_list.pastguild = data:get(packet.key.guild_lasttmpbattle_guildID)
    battle_list.times = date_chg(os.date("*t", data:get(packet.key.guild_pasttmpbattletime).v_int))
  end
  battle_list.pastsum = data:get(packet.key.guild_lasttmpbattle_ending).v_int
  battle_list.guild1 = ui.guild_name()
  ui_info_tip.on_click_add_msg(6)
  on_update_data()
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_info_tip.tmp_battle:on_signal"
reg(packet.eSTC_Guild_TempBattleInfo, on_set_data, sig)
