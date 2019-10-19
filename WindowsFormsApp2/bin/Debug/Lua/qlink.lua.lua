local qlink_window_name = {
  item = "$frame:item",
  personal = "$frame:personal",
  ridepet = "$frame:ridepet",
  quest = "$frame:received_quest",
  shop = "$frame:supermarket2",
  friend = "$frame:im_main",
  guild = "$frame:ui_guild",
  skill = "$frame:skill",
  colect = "$frame:md",
  thebestfighter = "$frame:ui_thebestfighter",
  huodong = "$frame:campaign"
}
local g_qlink_clicks = {
  pet = function()
    ui_pet.set_visible()
  end,
  setting = function()
    ui_central.toggle_central()
  end,
  arena = function()
    ui_match.on_click_apply_btn()
  end,
  friend = function()
    ui_im.on_qlink_friend()
  end,
  thebestfighter = function()
    ui_thebestfighter.on_click_win_btn()
  end,
  wuguanlist = function()
    ui_dungeonui.ui_dungeonsel.set_visible()
  end,
  convene = function()
    local w = ui.find_control("$frame:convene")
    w.visible = not w.visible
  end,
  campaign1 = function(btn)
    ui_campaign.on_btn_dynamic_campaign_click(btn)
  end,
  campaign2 = function(btn)
    ui_campaign.on_btn_dynamic_campaign_click(btn)
  end,
  campaign3 = function(btn)
    ui_campaign.on_btn_dynamic_campaign_click(btn)
  end,
  xinshou = function(btn)
    ui_xinshou.set_visible()
  end,
  activation = function(btn)
    ui_activation.set_visible()
  end,
  areaquest = function()
    ui_areaquest.set_visible()
  end,
  shop = function()
    if ui_supermarket2.CanOpen() then
      ui_supermarket2.w_main.visible = not ui_supermarket2.w_main.visible
    end
  end
}
function on_qlink_click(btn)
  ui_campaign.close_btn_popo(btn)
  local n = tostring(btn.name)
  local fn = g_qlink_clicks[n]
  if fn ~= nil then
    fn(btn)
    return
  end
  local window_name = qlink_window_name[n]
  if window_name ~= nil then
    local w = ui.find_control(window_name)
    if n == tostring("guild") then
      if bo2.is_in_guild() == sys.wstring(0) then
        local ui_search_visible = ui_guild_mod.ui_guild_search.w_guild_search.visible
        if ui_search_visible == false then
          ui_chat.show_ui_text_id(70251)
          ui_guild_mod.ui_guild_search.set_win_open(0)
        else
          ui_guild_mod.ui_guild_search.w_guild_search.visible = false
        end
        return
      else
        ui_handson_teach.test_complate_guild(true)
        if ui.npc_guild_mb_id() ~= 0 then
          w = ui.find_control("$frame:ui_npc_guild")
        end
        for i = 0, bo2.gv_npc_guild.size - 1 do
          local line = bo2.gv_npc_guild:get(i)
          if line ~= nil and (ui.guild_name() == line.name or ui.guild_name() == line.show_name) then
            w = ui.find_control("$frame:ui_npc_guild")
            break
          end
        end
      end
    end
    if n == tostring("skill") and w.visible == false then
      local obj = bo2.player
      if obj then
        local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_Skill)
        if flag_value == 16 then
          ui_handson_teach.test_complate_skill_choose()
        end
        flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_Skill_SkillTudun)
        if flag_value == 16 then
          ui_handson_teach.test_complate_skill_choose_qita()
        end
      end
    end
    w.visible = not w.visible
  end
end
function on_qlink_visible(ctrl, vis)
  if not vis then
    if not ui_campaign then
      return
    end
    ui_campaign.close_btn_popo(ctrl)
  end
end
local qlink_op_name = {
  item = "window_item",
  personal = "window_equip",
  ridepet = "window_ridepet",
  quest = "window_quest",
  shop = "window_market",
  pet = "window_pet",
  friend = "window_im",
  guild = "window_org",
  skill = "window_skill",
  colect = "window_md",
  btn_world_map = "window_map"
}
function on_make_qlink_tip(tip)
  local op = qlink_op_name[tostring(tip.owner.name)]
  if op ~= nil then
    local v = ui_setting.ui_input.op_def[op].hotkey
    local k = v:get_cell(0).text
    if k.size == 0 then
      k = v:get_cell(1).text
    end
    if 0 < k.size then
      ui_widget.tip_make_view(tip.view, sys.format("%s<space:0.4><key:%s>", tip.text, k))
      return
    end
  end
  ui_widget.tip_make_view(tip.view, tip.text)
end
if rawget(_M, "qlink_btn") == nil then
  qlink_btn = {}
end
function on_qlink_init(btn)
  local n = tostring(btn.name)
  qlink_btn[n] = btn
  local w = qlink_window_name[n]
  local v = ui_tool.tool_disable_window[w]
  if v == nil then
    return
  end
  if v == 0 then
    btn.visible = false
  else
    btn.enable = false
  end
end
function on_vis_champion(vis)
end
function set_areaquest_vis(vis)
  if vis == true then
    w_qlink:search("areaquest").visible = vis
  else
    local flag = ui.safe_get_atb(2) >= 30 or ui.quest_get_qobj_value(bo2.eQuestObj_Quest, 1007) == -2
    w_qlink:search("areaquest").visible = flag
  end
end
function on_level_update(lv)
  local p_lv = bo2.player:get_atb(bo2.eAtb_Level)
  w_qlink:search("wuguanlist").visible = p_lv >= 15
  w_qlink:search("convene").visible = p_lv >= 15
  set_areaquest_vis(p_lv >= 30)
  w_qlink:search("huodong").visible = p_lv >= 20
  w_qlink:search("arena").visible = p_lv >= ui_widget.get_define_int(79)
  w_qlink:search("activation").visible = p_lv >= ui_widget.get_define_int(1131)
end
function on_click_cloned_battle()
  ui_cloned_battle.on_click_vis_window()
end
function on_prepare_ridepet_fight(obj, type, idx)
  local val = obj:get_flag_objmem(idx)
  if val ~= 0 then
    w_ridepet_fight.visible = true
  else
    w_ridepet_fight.visible = false
  end
end
function on_ridepet_fight(obj, type, idx)
  local val = obj:get_flag_objmem(idx)
  if val ~= 0 then
    bo2.check_front_sight(0, 0)
    w_ridepet_sight.visible = true
    w_ridepet_fight_open.visible = false
    w_ridepet_fight_close.visible = true
    w_timer.suspended = false
    on_ridepet_sight_update()
    ui_ridepet_shortcut.active()
    bo2.set_fastmove_switch(true)
  else
    w_ridepet_fight_open.visible = true
    w_ridepet_fight_close.visible = false
    w_ridepet_sight.visible = false
    w_timer.suspended = true
    ui_ridepet_shortcut.deactive()
    bo2.set_fastmove_switch(false)
  end
end
function newCounter()
  local n = 0
  return function()
    n = n + 1
    return n
  end
end
local nCounter = newCounter()
function on_fastmove(obj, type, idx)
  if bo2.player_Create_finish() and bo2.IsSwitchFastMove() and nCounter() <= 2 then
    local keyName = ui_setting.ui_input.get_op_text(ui_setting.ui_input.op_def.fast_move.id)
    local vp = sys.variant()
    vp:set(L("key"), keyName)
    local v = sys.variant()
    v:set(packet.key.ui_text_arg, vp)
    local val = obj:get_flag_objmem(idx)
    if val == 0 then
      v:set(packet.key.ui_text_id, 5489)
    else
      v:set(packet.key.ui_text_id, 5488)
    end
    ui_packet.recv_wrap(packet.eSTC_UI_ShowText, v)
  end
end
function on_visible_ridepet_sight(w, vis)
  ui_handson_teach.enable_ride_sight(vis)
end
function on_visible_btn_fight_open(w, vis)
  ui_handson_teach.enable_ride(vis)
end
function on_ridepet_fight_tip(tip)
  local keyName = ui_setting.ui_input.get_op_text(ui_setting.ui_input.op_def.ridefight.id)
  local keyName1 = ui_setting.ui_input.get_op_text(ui_setting.ui_input.op_def.fast_move.id)
  local keyName2 = ui_setting.ui_input.get_op_text(ui_setting.ui_input.op_def.show_cursor.id)
  ui_widget.tip_make_view(tip.view, ui_widget.merge_mtf({
    key = keyName,
    key1 = keyName1,
    key2 = keyName2
  }, tip.text))
end
function on_click_ridepet_fight()
  local var = sys.variant()
  bo2.send_variant(packet.eCTS_UI_ChangeRideFightMode, var)
  ui_handson_teach.enable_ride(false)
end
function InitPlayer(obj, msg)
  bo2.player:insert_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_RideFightPrepare, on_prepare_ridepet_fight, "ui_qbar:on_prepare_ridepet_fight")
  bo2.player:insert_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_RideFight, on_ridepet_fight, "ui_qbar:on_ridepet_fight")
  bo2.player:insert_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_FastMove, on_fastmove, "ui_qbar:on_fastmove")
end
function DestroyPlayer(obj, msg)
  bo2.player:remove_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_RideFightPrepare, on_prepare_ridepet_fight, "ui_qbar:on_prepare_ridepet_fight")
  bo2.player:remove_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_RideFight, on_ridepet_fight, "ui_qbar:on_ridepet_fight")
  bo2.player:remove_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_FastMove, on_fastmove, "ui_qbar:on_fastmove")
end
function on_ridepet_sight_update()
  local area = w_ridepet_sight.abs_area
  local x = area.x1 + (area.x2 - area.x1) * 0.5
  local y = area.y1 + (area.y2 - area.y1) * 0.5
  bo2.check_front_sight(x, y)
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, InitPlayer, "on_enter_scn:InitPlayer")
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_leave, DestoryPlayer, "on_leave_scn:DestoryPlayer")
