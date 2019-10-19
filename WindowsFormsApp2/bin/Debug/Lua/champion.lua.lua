g_portrait_path = "$icon/portrait/"
local g_tick_times = 150
local g_index = 0
local g_select_table = {}
local g_count_table = {}
local g_selected_data_count = 0
local g_default_portrait_uri = L("$icon/portrait/zj/0000.png")
local g_ci_max_portrait_size = 19
local cRandomState_Begin = 0
local cRandomState_R19 = 1
local cRandomState_R3 = 2
local cRandomState_Anime = 3
local g_random_state = cRandomState_Begin
local g_r19_tick_0 = 40
local g_r19_tick_1 = 70
local g_r19_tick_2 = 110
g_sound_r19 = 608
g_sound_r3 = 609
g_sound_mover = 610
local g_temp_count = {}
g_temp_count[0] = g_r19_tick_2
g_temp_count[1] = g_r19_tick_1
g_temp_count[2] = g_r19_tick_0
local g_r19_tick = 110
local g_r3_tick = 30
local g_anime_tick = 10
local g_timer_count = 150
local g_final_selected_index = 0
local g_server_select_index = 0
local g_server_select_index_1 = 0
local g_server_random_2 = 0
g_current_act = 0
local g_enter_count = 0
local g_enter_battle_id = 0
local g_default_tip_text = L("???")
g_award_money = 0
g_award_exp = 0
g_open_champion = false
function on_get_portrait_icon(id)
  local portrait_list = bo2.gv_portrait:find(id)
  if portrait_list ~= nil then
    return g_portrait_path .. portrait_list.icon .. ".png"
  end
end
function on_click_enter_battle()
  do return end
  local act_excel = bo2.gv_cavalier_championship_act:find(g_current_act)
  if act_excel ~= nil and act_excel.player_act ~= 0 then
    local v = sys.variant()
    v:set(packet.key.battlegroup_id, g_enter_battle_id)
    bo2.send_variant(packet.eCTS_CavalierChampionship_UIEnterBattle, v)
    return
  end
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_CavalierChampionship_EnterBattle, v)
end
function set_act_portrait(act, obj)
  local old_name = sys.format("r%d", act - 1)
  local act_list = ui_champion.w_main:search("act_list")
  local old_control = act_list:search(old_name)
  if sys.check(old_control) ~= true then
    ui.log("set_act_portrait fatal!")
    return
  end
  local strPortaitName = sys.format("$icon/item/tz/tz000%d.png", act)
  local portrait_control = old_control:search("portrait")
  local close_control = old_control:search("close")
  local tips_control = old_control:search("tips_control")
  if sys.check(portrait_control) ~= true or sys.check(close_control) ~= true or sys.check(tips_control) ~= true then
    return
  end
  tips_control.visible = false
  close_control.visible = false
  portrait_control.effect = ""
  if act < g_current_act then
    old_control.visible = true
    local iData = obj:get_flag_int32(bo2.ePlayerFlagInt32_ChampionshipAct1 + act - 1)
    if iData == 0 then
      return
    end
    local varData = bo2.ChampionGetPortaitFromData(iData)
    if varData:has(packet.key.cha_onlyid) then
      local iExcelId = varData:get(packet.key.action_acc).v_int
      portrait_control.visible = true
      portrait_control.image = on_get_portrait_icon(iExcelId)
      portrait_control.effect = "gray"
      close_control.visible = true
    else
      local iExcelId = varData:get(packet.key.action_acc).v_int
      local excel_data = bo2.gv_cavalier_championship_npc:find(iExcelId)
      if sys.check(excel_data) then
        local cha_list_data = bo2.gv_cha_list:find(excel_data.cha_list_id)
        if sys.check(cha_list_data) then
          local cha_pic = bo2.gv_cha_pic:find(cha_list_data.pic)
          if sys.check(cha_pic) then
            strPortaitName = g_portrait_path .. cha_pic.head_icon
            portrait_control.visible = true
            portrait_control.image = strPortaitName
            portrait_control.effect = "gray"
            close_control.visible = true
            tips_control.visible = true
            if cha_list_data.name.empty ~= true then
              tips_control.tip.text = cha_list_data.name
            end
          end
        end
      end
    end
  else
    portrait_control.visible = false
  end
end
function on_set_curent_act_portrait()
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return
  end
  set_act_portrait(g_current_act, obj)
end
function init_act_portrait()
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return
  end
  for i = 1, 8 do
    set_act_portrait(i, obj)
  end
end
function init_act_data_by_index(iAct)
  local act_excel = bo2.gv_cavalier_championship_act:find(iAct + 1)
  if sys.check(act_excel) ~= true then
    return
  end
  local act_award_data = bo2.gv_cavalier_championship_award:find(act_excel.act_award)
  if sys.check(act_award_data) ~= true then
    return
  end
  local obj_level = ui.safe_get_atb(bo2.eAtb_Level)
  local make_act_common_award = function(act_award_data, obj_level, bDouble)
    local iAwardMoney = act_award_data.award_base_money + obj_level * act_award_data.award_money_persent
    local iAwardExp = act_award_data.award_base_exp + obj_level * act_award_data.award_exp_persent
    local iAwardMoney = sys.format(L("<m:%d>"), iAwardMoney)
    if bDouble ~= true then
      return ui_widget.merge_mtf({exp = iAwardExp, money = iAwardMoney}, ui.get_text("fate|tip_desc"))
    else
      return ui_widget.merge_mtf({exp = iAwardExp, money = iAwardMoney}, ui.get_text("fate|tip_double_award"))
    end
  end
  local common_award_text = make_act_common_award(act_award_data, obj_level, false)
  local size = bo2.gv_cavalier_championship_npc.size
  for i = 0, size - 1 do
    local excel_data = bo2.gv_cavalier_championship_npc:get(i)
    local in_pos_index = -1
    if excel_data.in_act[iAct] ~= 0 then
      in_pos_index = excel_data.in_pos[iAct]
    end
    if in_pos_index >= 0 and in_pos_index <= g_ci_max_portrait_size then
      local cha_list_data = bo2.gv_cha_list:find(excel_data.cha_list_id)
      if sys.check(cha_list_data) then
        local cha_pic = bo2.gv_cha_pic:find(cha_list_data.pic)
        if sys.check(cha_pic) then
          local pos_index = sys.format(L("c%d"), in_pos_index)
          local npc_list = ui_champion.w_main:search("npc_list")
          local item_control = npc_list:search(pos_index)
          if sys.check(item_control) then
            local function init_tip_text(tip, name, npc_excel)
              local stk_push_new_line = function(stk)
                stk:push("\n")
              end
              local stk = sys.stack()
              stk:push(name)
              stk_push_new_line(stk)
              stk:push([[
<tf+:micro>
<sep>
<tf->]])
              if npc_excel.client_mark then
                local npc_award_data = bo2.gv_cavalier_championship_award:find(npc_excel.award_index)
                if sys.check(npc_award_data) then
                  local new_award_text = make_act_common_award(npc_award_data, obj_level, true)
                  stk:push(new_award_text)
                  tip.text = stk.text
                  return
                end
              end
              stk:push(common_award_text)
              tip.text = stk.text
            end
            init_tip_text(item_control.tip, cha_list_data.name, excel_data)
            local item_protrait = item_control:search("portrait")
            if sys.check(item_protrait) then
              item_protrait.image = g_portrait_path .. cha_pic.head_icon
              item_protrait.var:set(packet.key.cha_id, excel_data.cha_list_id)
            end
            local back_color = item_control:search("back_pic")
            if sys.check(back_color) then
              if excel_data.client_mark ~= 0 then
                back_color.visible = true
                back_color.color = ui.make_color("FFFF00")
                back_color.var:set("name", cha_list_data.name)
              else
                back_color.color = ui.make_color("FFFFFF")
                back_color.visible = false
              end
            end
          end
        end
      end
    end
  end
  init_act_portrait()
  local iMoney = 0
  local iExp = 0
  if sys.check(bo2.player) then
    iMoney = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_ChampionshipFightAwardMoney)
    iExp = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_ChampionshipFightAwardExp)
  end
  local lb_award_data = ui_champion.w_main:search("lb_award_data")
  local mtf_data = {}
  mtf_data.act = iAct
  mtf_data.exp = iExp
  mtf_data.money = sys.format(L("<m:%d>"), iMoney)
  lb_award_data.mtf = ui_widget.merge_mtf(mtf_data, ui.get_text("fate|desc0"))
  lb_award_data.parent:tune("lb_award_data")
end
function on_init_three_one()
  local selected_list = ui_champion.w_main:search("selected_list")
  for i = 0, 2 do
    local rand_name = sys.format("random%d", i)
    local rand_control = selected_list:search(rand_name)
    if sys.check(rand_control) then
      rand_control.tip.text = g_default_tip_text
      rand_control.visible = false
      local rand_portrait = rand_control:search("portrait")
      if sys.check(rand_portrait) then
        rand_portrait.image = g_default_portrait_uri
        rand_portrait.effect = ""
      end
      local rand_hightlight = rand_control:search("highlight_select")
      if sys.check(rand_hightlight) then
        rand_hightlight.visible = false
      end
    end
  end
end
function init_can_not_challenge()
  on_init_act_data()
  g_current_act = 0
  init_act_portrait()
  on_init_three_one()
  local lb_award_data = ui_champion.w_main:search("lb_award_data")
  lb_award_data.mtf = ui.get_text("clonedbattle|battle_limit_today")
  lb_award_data.parent:tune("lb_award_data")
end
function on_init_act_data()
  local npc_list = ui_champion.w_main:search("npc_list")
  for i = 0, 19 do
    local pos_index = sys.format("c%d", i)
    local item_control = npc_list:search(pos_index)
    if sys.check(item_control) then
      item_control.tip.text = g_default_tip_text
      local item_protrait = item_control:search("portrait")
      if sys.check(item_protrait) then
        item_protrait.image = g_default_portrait_uri
        item_protrait.effect = ""
      end
      local item_highlight = item_control:search("highlight_select")
      if sys.check(item_highlight) then
        item_highlight.visible = false
      end
      local back_color = item_control:search("back_pic")
      if sys.check(back_color) then
        back_color.visible = false
      end
    end
  end
end
function on_vis_champion()
  if ui_champion.g_timer_second.suspended == false then
    return
  end
  local var = sys.variant()
  bo2.send_variant(packet.eCTS_UI_CavalierChampionship_GetClientData, v)
  on_vis_enter_button(false)
  local champion_time = ui_champion.w_main:search("champion_time")
  local w_champion_time_0 = champion_time:search("time0")
  local w_champion_time_1 = champion_time:search("time1")
  w_champion_time_0.visible = false
  w_champion_time_1.visible = false
  local new_challenger = ui_champion.w_main:search("new_challenger")
  new_challenger.visible = false
end
function init_scn_data(scn_data)
  if sys.check(scn_data) ~= true then
    return
  end
  scn_data:set_excel_id(1000)
  local obj = bo2.player
  local scn = scn_data.scn
  scn:set_fov(1)
  local view_player = scn:create_obj(bo2.eScnObjKind_Player, obj.excel.id)
  view_player.view_target = obj
  scn:bind_camera(view_player)
  scn:modify_camera_view_type(view_player, bo2.eCameraFace)
end
function init_target_data(scn_data, char_id)
  scn_data:set_excel_id(1000)
  local scn = scn_data.scn
  scn:set_fov(1)
  local p_target_npc = scn:create_obj(bo2.eScnObjKind_Npc, char_id)
  if sys.check(p_target_npc) ~= true then
    return
  end
  p_target_npc:set_as_npc()
  scn:bind_camera(p_target_npc)
  scn:modify_camera_view_type(p_target_npc, bo2.eCameraFace)
end
function init_target_data_by_variant(scn_data, v)
  scn_data:set_excel_id(1000)
  local scn = scn_data.scn
  scn:set_fov(1)
  local cha_id = v:get(bo2.eClondeBattle_eEquipData_ChaListID).v_int
  local p_target_npc = scn:create_obj(bo2.eScnObjKind_Player, cha_id)
  if sys.check(p_target_npc) ~= true then
    return
  end
  scn:bind_camera(p_target_npc)
  scn:modify_camera_view_type(p_target_npc, bo2.eCameraFace)
  p_target_npc:equip_clear()
  p_target_npc:set_equip_model(bo2.eEquipData_Hair, v:get(bo2.eClondeBattle_eEquipData_HairOrHat).v_int)
  p_target_npc:set_equip_model(bo2.eEquipData_Face, v:get(bo2.eClondeBattle_eEquipData_Face).v_int)
  p_target_npc:set_equip_model(bo2.eEquipData_Body, v:get(bo2.eClondeBattle_eEquipData_BodyOrAvatarBody).v_int)
  p_target_npc:set_view_equip(bo2.eEquipData_MainWeapon, v:get(bo2.eClondeBattle_eEquipData_MainWeapon).v_int)
end
function on_esc_stk_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis ~= true then
  else
    on_vis_champion()
  end
end
function on_init_champion()
  g_current_act = 0
end
function on_vis_enter_button(vis)
  if vis then
    local champion_time = ui_champion.w_main:search("champion_time")
    local w_champion_time_0 = champion_time:search("time0")
    local w_champion_time_1 = champion_time:search("time1")
    w_champion_time_0.visible = false
    w_champion_time_1.visible = false
  else
    local champion_time = ui_champion.w_main:search("champion_time")
    champion_time.visible = true
    g_enter_count = 0
    ui_champion.g_timer_enter.suspended = true
  end
end
function on_begin_random_data(iSelect)
  local new_challenger = ui_champion.w_main:search("new_challenger")
  new_challenger.visible = false
  on_vis_enter_button(false)
  g_timer_count = 150
  g_tick_times = g_r19_tick
  g_random_state = cRandomState_R19
  g_selected_data_count = 0
  g_server_select_index = iSelect
  g_select_table = {}
  g_count_table = {}
  g_count_table[0] = bo2.rand(g_r19_tick_1, g_r19_tick_2)
  g_count_table[1] = bo2.rand(g_r19_tick_0, g_r19_tick_1)
  g_count_table[2] = bo2.rand(0, g_r19_tick_0)
  local _temp_count = {}
  _temp_count[0] = g_r19_tick_1
  _temp_count[1] = g_r19_tick_0
  _temp_count[2] = 0
  g_index = bo2.rand(0, 19)
  local iSelectSection = bo2.rand(0, 2)
  on_init_three_one()
  g_server_random_2 = bo2.rand(0, 1)
  if iSelectSection == 1 then
    g_server_random_2 = 0
  end
  g_count_table[iSelectSection] = _temp_count[iSelectSection]
  g_server_select_index_1 = iSelectSection
  local npc_list = ui_champion.w_main:search("npc_list")
  for i = 0, g_ci_max_portrait_size do
    local old_name = sys.format("c%d", i)
    local old_control = npc_list:search(old_name)
    if sys.check(old_control) then
      old_control:search("highlight_select").visible = false
      old_control:search("portrait").effect = ""
    end
  end
  init_act_portrait()
end
function on_click_close()
  w_main.visible = false
end
function on_click_send_application()
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_CavalierChampionship_AddApplication, v)
  g_open_champion = false
end
function on_timer_anime()
  g_tick_times = g_tick_times - 1
  if g_tick_times <= 0 then
    local new_name = sys.format("random%d", g_index)
    local selected_list = ui_champion.w_main:search("selected_list")
    local new_control = selected_list:search(new_name)
    local new_portrait = new_control:search("portrait")
    local act_name = sys.format("r%d", g_current_act - 1)
    local act_list = ui_champion.w_main:search("act_list")
    local act_control = act_list:search(act_name)
    local act_portrait = act_control:search("portrait")
    act_portrait.visible = true
    act_portrait.image = new_portrait.image
    act_control.tip.text = new_control.tip.text
    new_control:search("highlight_select").visible = false
    for i = 0, 19 do
      local old_name = sys.format("c%d", i)
      local npc_list = ui_champion.w_main:search("npc_list")
      local old_control = npc_list:search(old_name)
      if sys.check(old_control) then
        old_control:search("portrait").effect = "gray"
      end
    end
    on_vis_enter_button(true)
    ui_champion.g_timer_second.suspended = true
  end
end
function on_timer_tick_three_select_one()
  local new_name = sys.format("random%d", g_index)
  local selected_list = ui_champion.w_main:search("selected_list")
  local new_control = selected_list:search(new_name)
  new_control:search("highlight_select").visible = true
  local new_portrait = new_control:search("portrait")
  g_tick_times = g_tick_times - 1
  if g_tick_times <= 3 and g_index == g_server_select_index_1 then
    g_tick_times = 0
  end
  if ui_champion.w_main.visible == true then
    bo2.PlaySound2D(g_sound_r3)
  end
  if g_tick_times <= 0 then
    local function on_init_anime_data()
      g_tick_times = g_anime_tick
      g_random_state = cRandomState_Anime
      g_final_selected_index = g_index
      for i = 0, 19 do
        local old_name = sys.format("c%d", i)
        local npc_list = ui_champion.w_main:search("npc_list")
        local old_control = npc_list:search(old_name)
        if sys.check(old_control) then
          old_control:search("portrait").effect = "gray"
        end
      end
      for i = 0, 3 do
        local rand_old_name = sys.format("random%d", i)
        local selected_list = ui_champion.w_main:search("selected_list")
        local rand_old_control = selected_list:search(rand_old_name)
        if sys.check(rand_old_control) and new_control ~= rand_old_control then
          rand_old_control:search("portrait").effect = "gray"
        end
      end
      if ui_champion.w_main.visible ~= true then
        return
      end
      ui_qbar.ui_hide_anim.w_hide_anim:frame_clear()
      ui_qbar.ui_hide_anim.w_hide_anim.visible = true
      local w_move_target = new_portrait
      local w_move_pos_name = sys.format("r%d", g_current_act - 1)
      local act_list = ui_champion.w_main:search("act_list")
      local w_move_pos = act_list:search(w_move_pos_name):search("portrait")
      local f = ui_qbar.ui_hide_anim.w_hide_anim:frame_insert(1000, w_move_target)
      local bs = w_move_target.size
      local ws = w_move_pos.size
      local pos = w_move_pos:control_to_window(ui.point(0, 0)) + bs * 0.5
      local src = w_move_pos.offset + ws * 0.5
      local dis = pos - src
      local dis1 = w_move_target:control_to_window(ui.point(0, 0))
      f:set_translate1(dis1.x, dis1.y)
      f:set_translate2(dis.x, dis.y)
      if ui_champion.w_main.visible == true then
        bo2.PlaySound2D(g_sound_mover)
      end
    end
    on_init_anime_data()
    return
  end
  g_index = g_index + 1
  if g_index >= 3 then
    g_index = 0
  end
end
function on_timer_random_19()
  g_index = g_index + 1
  while g_select_table[g_index] ~= nil do
    g_index = g_index + 1
    if g_index > 19 then
      g_index = 0
    end
  end
  if g_index > 19 then
    g_index = 0
  end
  if ui_champion.w_main.visible == true then
    bo2.PlaySound2D(g_sound_r19)
  end
  local new_name = sys.format("c%d", g_index)
  local npc_list = ui_champion.w_main:search("npc_list")
  local new_control = npc_list:search(new_name)
  if sys.check(new_control) then
    new_control:search("highlight_select").visible = true
  end
  local compare_index = 3
  if g_tick_times >= g_r19_tick_1 then
    compare_index = 0
  elseif g_tick_times >= g_r19_tick_0 then
    compare_index = 1
  else
    compare_index = 2
  end
  if g_tick_times < g_temp_count[g_selected_data_count] and g_index == g_server_select_index and g_selected_data_count == g_server_select_index_1 then
    if g_server_random_2 > 0 then
      g_server_random_2 = g_server_random_2 - 1
    else
      g_count_table[compare_index] = g_tick_times
    end
  end
  local bFind = false
  if g_count_table[compare_index] ~= nil and g_tick_times <= g_count_table[compare_index] then
    if g_server_select_index == g_index and g_selected_data_count ~= g_server_select_index_1 then
      bFind = false
    else
      bFind = true
    end
  end
  if bFind then
    g_select_table[g_index] = g_index
    g_count_table[compare_index] = nil
    local rand_name = sys.format("random%d", compare_index)
    local selected_list = ui_champion.w_main:search("selected_list")
    local rand_control = selected_list:search(rand_name)
    local new_portrait = new_control:search("portrait")
    local rand_portrait = rand_control:search("portrait")
    rand_portrait.image = new_portrait.image
    rand_control.visible = true
    rand_control.tip.text = new_control.tip.text
    local back_color = new_control:search("back_pic")
    if ui_champion.w_main.visible == true and sys.check(back_color) and back_color.visible == true then
      local name = back_color.var:get("name").v_string
      if name.empty ~= true then
        local msg = ui_widget.merge_mtf({name = name}, ui.get_text("fate|select_desc"))
        ui_tool.note_insert(msg, L("FF00FF00"))
      end
    end
    if ui_champion.w_main.visible == true then
      bo2.PlaySound2D(g_sound_mover)
    end
    new_portrait.effect = "gray"
    rand_portrait.var:set(packet.key.cha_id, new_portrait.var:get(packet.key.cha_id))
    g_selected_data_count = g_selected_data_count + 1
  end
  if g_selected_data_count >= 3 then
    local function on_init_three_select_one_data()
      g_tick_times = g_r3_tick + g_tick_times
      g_random_state = cRandomState_R3
      g_index = bo2.rand(0, 2)
    end
    on_init_three_select_one_data()
  end
  g_tick_times = g_tick_times - 1
end
function on_timer_set_random_data()
  local champion_time = ui_champion.w_main:search("champion_time")
  local w_champion_time_0 = champion_time:search("time0")
  local w_champion_time_1 = champion_time:search("time1")
  w_champion_time_0.visible = true
  w_champion_time_1.visible = true
  for i = 0, g_ci_max_portrait_size do
    local old_name = sys.format("c%d", i)
    local npc_list = ui_champion.w_main:search("npc_list")
    local old_control = npc_list:search(old_name)
    if sys.check(old_control) then
      old_control:search("highlight_select").visible = false
    end
  end
  for i = 0, 2 do
    local rand_old_name = sys.format("random%d", i)
    local selected_list = ui_champion.w_main:search("selected_list")
    local rand_old_control = selected_list:search(rand_old_name)
    if sys.check(rand_old_control) then
      rand_old_control:search("highlight_select").visible = false
    end
  end
  if g_timer_count % 10 == 0 then
    local iCurrentSecond = g_timer_count / 10
    local iSecond0 = math.floor(g_timer_count / 100)
    local iSecond1 = math.fmod(iCurrentSecond, 10)
    local get_time_pos_data = function(iSecond)
      return sys.format("$image/champion/new_num/%d.png", iSecond)
    end
    local champion_time = ui_champion.w_main:search("champion_time")
    local w_champion_time_0 = champion_time:search("time0")
    local w_champion_time_1 = champion_time:search("time1")
    w_champion_time_0.image = get_time_pos_data(iSecond0)
    w_champion_time_1.image = get_time_pos_data(iSecond1)
  end
  if g_random_state == cRandomState_R19 then
    on_timer_random_19()
  elseif g_random_state == cRandomState_R3 then
    on_timer_tick_three_select_one()
  elseif g_random_state == cRandomState_Anime then
    on_timer_anime()
  else
    ui_champion.g_timer_second.suspended = true
  end
  g_timer_count = g_timer_count - 1
end
function on_timer_enter_scene()
  g_enter_count = g_enter_count - 1
  if g_enter_count <= 0 then
    ui_champion.g_timer_enter.suspended = true
  end
end
function run()
  ui_champion.w_main.visible = true
end
function begin_random_npc(iSelect)
  ui_champion.g_timer_second.suspended = false
  if ui_champion.g_timer_second.suspended == false then
    local excel_npc = bo2.gv_cavalier_championship_npc:find(iSelect)
    if sys.check(excel_npc) then
      local iServerSelectNpc = excel_npc.in_pos[g_current_act - 1]
      on_begin_random_data(iServerSelectNpc)
    end
  end
end
function on_challenger_anime()
  if ui_champion.w_main.visible ~= true then
    return
  end
  local rand_name = sys.format("random1")
  local selected_list = ui_champion.w_main:search("selected_list")
  local rand_control = selected_list:search(rand_name)
  local new_portrait = rand_control:search("portrait")
  ui_qbar.ui_hide_anim.w_hide_anim:frame_clear()
  ui_qbar.ui_hide_anim.w_hide_anim.visible = true
  local w_move_target = new_portrait
  local w_move_pos_name = sys.format("r%d", g_current_act - 1)
  local act_list = ui_champion.w_main:search("act_list")
  local w_move_pos = act_list:search(w_move_pos_name):search("portrait")
  local f = ui_qbar.ui_hide_anim.w_hide_anim:frame_insert(1000, w_move_target)
  local bs = w_move_target.size
  local ws = w_move_pos.size
  local pos = w_move_pos:control_to_window(ui.point(0, 0)) + bs * 0.5
  local src = w_move_pos.offset + ws * 0.5
  local dis = pos - src
  local dis1 = w_move_target:control_to_window(ui.point(0, 0))
  f:set_translate1(dis1.x, dis1.y)
  f:set_translate2(dis.x, dis.y)
  local set_portrait_data = function()
    local new_name = sys.format("random%d", 1)
    local selected_list = ui_champion.w_main:search("selected_list")
    local new_control = selected_list:search(new_name)
    local new_portrait = new_control:search("portrait")
    local act_name = sys.format("r%d", g_current_act - 1)
    local act_list = ui_champion.w_main:search("act_list")
    local act_control = act_list:search(act_name)
    local act_portrait = act_control:search("portrait")
    act_portrait.visible = true
    act_portrait.image = new_portrait.image
  end
  bo2.AddTimeEvent(25, set_portrait_data)
end
function test_begin_random_npc()
  g_current_act = 1
  begin_random_npc(1)
end
function on_handle_Championship_BeginRandomNpc(cmd, data)
  if sys.check(bo2.player) ~= true then
    return
  end
  local iFlagData = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_ChampionshipNpcIndex)
  if iFlagData ~= 0 then
    ui_champion.w_main.visible = true
    local iAct = data:get(packet.key.chat_show).v_int
    g_current_act = iAct
    init_act_data_by_index(iAct - 1)
    on_set_curent_act_portrait()
    begin_random_npc(iFlagData)
  end
end
function on_handle_Championship_GetData(cmd, data)
  local iAct = data:get(packet.key.chat_show).v_int
  if iAct ~= g_current_act and iAct > 0 and iAct < 9 then
    g_current_act = iAct
    init_act_data_by_index(iAct - 1)
  elseif iAct >= 9 then
    init_can_not_challenge()
  elseif g_current_act > 0 then
    init_act_data_by_index(g_current_act - 1)
  end
  local function on_init_rank_data()
    local obj = bo2.player
    local total_player_count = data:get(packet.key.total_time).v_int
    local current_stage = data:get(packet.key.ranklist_id).v_int
    local current_persent = 0
    if total_player_count ~= 0 then
      current_persent = current_stage / total_player_count * 100 - 0.1
      if current_persent >= 100 then
        current_persent = 99.9
      elseif current_persent < 0 then
        current_persent = 0
      end
    end
    if sys.check(obj) then
      local count = obj:get_flag_int32(bo2.ePlayerFlagInt32_ChampionshipWinTimes)
      local lb_history_data = ui_champion.w_main:search("lb_history_data")
      local mtf = {}
      mtf.count = count
      mtf.persent = sys.format("%.1f", current_persent)
      lb_history_data.mtf = ui_widget.merge_mtf(mtf, ui.get_text("fate|over_desc"))
      lb_history_data.parent:tune("lb_history_data")
    end
  end
  on_init_rank_data()
end
function on_handle_Championship_PlayerMatchData(cmd, data)
  ui_champion.g_timer_second.suspended = true
  local champion_time = ui_champion.w_main:search("champion_time")
  local w_champion_time_0 = champion_time:search("time0")
  local w_champion_time_1 = champion_time:search("time1")
  w_champion_time_0.visible = false
  w_champion_time_1.visible = false
  for i = 0, 19 do
    local old_name = sys.format("c%d", i)
    local npc_list = ui_champion.w_main:search("npc_list")
    local old_control = npc_list:search(old_name)
    if sys.check(old_control) then
      old_control:search("portrait").effect = "gray"
      old_control:search("highlight_select").visible = false
    end
  end
  g_enter_battle_id = data:get(packet.key.battlegroup_id).v_string
  for i = 0, 2 do
    local rand_old_name = sys.format("random%d", i)
    local selected_list = ui_champion.w_main:search("selected_list")
    local rand_old_control = selected_list:search(rand_old_name)
    if sys.check(rand_old_control) then
      local highlight_select_control = rand_old_control:search("highlight_select")
      highlight_select_control.visible = false
      if i == 1 then
        highlight_select_control.visible = true
        rand_old_control.visible = true
        local rand_portrait = rand_old_control:search("portrait")
        rand_portrait.image = on_get_portrait_icon(data:get(packet.key.cha_portrait).v_int)
      else
        rand_old_control.visible = false
      end
    end
  end
  local new_challenger = ui_champion.w_main:search("new_challenger")
  new_challenger.visible = true
  on_challenger_anime()
  on_vis_enter_button(true)
end
function on_champion_self_enter()
  ui_champion.w_main.visible = g_open_champion
  ui_champion.g_timer_second.suspended = true
  g_open_champion = false
  local obj = bo2.player
  if sys.check(obj) then
    g_award_money = obj:get_flag_int32(bo2.ePlayerFlagInt32_ChampionshipFightAwardMoney)
    g_award_exp = obj:get_flag_int32(bo2.ePlayerFlagInt32_ChampionshipFightAwardExp)
  end
end
local sig_name = "ui_champion:on_handle_Championship_GetData"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Cavalier_Championship_GetData, on_handle_Championship_GetData, sig_name)
sig_name = "ui_champion:on_handle_Championship_PlayerMatchData"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Cavalier_Championship_PlayerMatchData, on_handle_Championship_PlayerMatchData, sig_name)
sig_name = "ui_champion:on_handle_Championship_BeginRandomNpc"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Cavalier_Championship_BeginRandomNpc, on_handle_Championship_BeginRandomNpc, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_champion_self_enter, "ui_cloned_battle.on_self_enter_finish")
