target_handle = 0
g_portrait_path = "$icon/portrait/"
g_tot_show = false
function main_init()
  w_player_show.visible = true
  set_target_visible(false)
  set_tot_visible(false)
end
function on_pk_tip_make(tip)
  local p_mode = 0
  if bo2.player ~= nil then
    p_mode = bo2.player:get_flag_int32(bo2.eFlagInt32_PKMode)
  end
  local text = ui.get_text("portrait|pk_mode_" .. p_mode)
  if p_mode == bo2.ePKMode_Protect then
    text = text .. ui.get_text("portrait|tip_pkminlvl")
  end
  if bo2.scn.excel.pk_limit == bo2.eScnPKLmt_Guild then
    text = ui.get_text("portrait|pk_mode_3")
  elseif bo2.scn.excel.pk_limit > bo2.eScnPKLmt_Peace then
    text = ui.get_text("portrait|scn_pk_limit")
  end
  ui_widget.tip_make_view(tip.view, ui_widget.merge_mtf({text = text}, ui.get_text("portrait|cur_pk_model")))
end
function on_captain_tip_make(tip)
  local text = ui.get_text("portrait|captain")
  ui_widget.tip_make_view(tip.view, text)
end
function make_career_color(f, n)
  local dmg = n.damage
  if dmg == 1 then
    f.xcolor = "FF608CD9"
  else
    f.xcolor = "FFEE5544"
  end
end
function make_career_tip_text_i(pro)
  if pro == 0 then
    return L("NONE")
  end
  local n = bo2.gv_profession_list:find(pro)
  if n == nil then
    return L("NONE")
  end
  local dmg = n.damage
  if dmg == 1 then
    return sys.format("%s(<c+:608CD9>%s<c->)", n.name, ui.get_text("portrait|damage_type_1"))
  else
    return sys.format("%s(<c+:EE5544>%s<c->)", n.name, ui.get_text("portrait|damage_type_0"))
  end
end
function make_career_tip_text(player)
  if player == nil then
    return L("NONE")
  end
  local pro = player:get_atb(bo2.eAtb_Cha_Profession)
  return make_career_tip_text_i(pro)
end
function make_career_tip(tip, obj)
  local text = make_career_tip_text(obj)
  ui_widget.tip_make_view(tip.view, text)
end
function on_career_tip_make(tip, target)
  make_career_tip(tip, target)
end
function on_target_career_tip_make(tip)
  local player = bo2.player
  if player == nil then
    return
  end
  local target = bo2.scn:get_scn_obj(player.target_handle)
  make_career_tip(tip, target)
end
function on_target_control_state_tip_make(tip)
  local player = bo2.player
  if player == nil then
    return
  end
  local target = bo2.scn:get_scn_obj(player.target_handle)
  local text
  if target.kind == bo2.eScnObjKind_Npc then
    if target.excel.fight_body == 1 then
      text = ui.get_text("portrait|controls_state1")
    elseif target.excel.fight_body == 3 then
      text = ui.get_text("portrait|controls_state2")
    elseif target.excel.fight_body == 4 then
      text = ui.get_text("portrait|controls_state3")
    else
      return
    end
  end
  ui_widget.tip_make_view(tip.view, text)
end
function on_player_portrait_chg(obj)
  local u = make_icon_uri(obj)
  w_portrait.image = u
  if obj.target_handle == obj.sel_handle then
    w_target_icon.image = u
    w_tot_icon.image = u
  end
end
function on_player_runwalk_chg(obj, ft, idx)
  local v = obj:get_flag_objmem(idx)
  if v == 1 then
    w_run_btn.visible = true
    w_walk_btn.visible = false
  else
    w_run_btn.visible = false
    w_walk_btn.visible = true
  end
end
local food_note_flag1 = false
local food_note_flag2 = false
FOOD_LENGTH_MAX = 35
FOOD_MAX = 7500
local g_current_player_food = 0
function reset_player_food(val)
  g_current_player_food = val
end
function get_player_food()
  return g_current_player_food
end
function on_update_food(val)
  if val > 0 and val <= 1500 then
    w_food_timer.period = 300000
    w_food_timer.suspended = false
    if food_note_flag1 == false then
      ui_tool.note_insert(ui.get_text("portrait|food_hungry"), "FFFF0000")
      food_note_flag1 = true
    end
    ui_handson_teach.test_complate_foodmeter_highlight(true)
    w_food_flk.visible = true
  elseif val == 0 then
    w_food_timer.period = 60000
    w_food_timer.suspended = false
    if good_note_flag2 == false then
      ui_tool.note_insert(ui.get_text("portrait|food_veryhungry"), "FFFF0000")
      food_note_flag2 = true
    end
  else
    if val > 1500 and val <= 3000 then
    elseif val > 3000 and val <= 4500 then
    elseif val > 4500 then
    end
    w_food_timer.suspended = true
    food_note_flag1 = false
    food_note_flag2 = false
    w_food_flk.visible = false
  end
  if val >= 0 and val <= 1500 then
    w_food_fig.image = L("$image/qbar/qbar_main.png|496,161,15,35")
  elseif val >= 1501 and val <= 3000 then
    w_food_fig.image = L("$image/qbar/qbar_main.png|479,161,15,35")
  elseif val >= 3001 and val <= 4499 then
    w_food_fig.image = L("$image/qbar/qbar_main.png|462,161,15,35")
  else
    w_food_fig.image = L("$image/qbar/qbar_main.png|445,161,15,35")
  end
  w_food_fig.dy = FOOD_LENGTH_MAX * val / FOOD_MAX
end
function on_player_food_chg(obj, ft, idx)
  local val = obj:get_flag_int32(bo2.ePlayerFlagInt32_Food)
  reset_player_food(val)
  on_update_food(val)
end
function on_food_tip(tip)
  local player = bo2.player
  if player == nil then
    return
  end
  ui_handson_teach.test_complate_foodmeter_highlight(false)
  local val = get_player_food()
  local v = sys.variant()
  v:set("num", val)
  local txt
  if val == 0 then
    txt = sys.mtf_merge(v, ui.get_text("portrait|food_tip_0"))
  elseif val <= 1500 then
    txt = sys.mtf_merge(v, ui.get_text("portrait|food_tip_1"))
  elseif val <= 3000 then
    txt = sys.mtf_merge(v, ui.get_text("portrait|food_tip_2"))
  elseif val <= 4500 then
    txt = sys.mtf_merge(v, ui.get_text("portrait|food_tip_3"))
  else
    txt = sys.mtf_merge(v, ui.get_text("portrait|food_tip_4"))
  end
  ui_widget.tip_make_view(tip.view, txt)
end
function on_food_timer(timer)
  if bo2.player == nil then
    return
  end
  local val = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Food)
  if val > 1500 then
    return
  end
  if val > 0 and val <= 1500 then
    timer.period = 300000
    ui_tool.note_insert(ui.get_text("portrait|food_hungry"), "FFFF0000")
    return
  end
  if val == 0 then
    timer.period = 60000
    ui_tool.note_insert(ui.get_text("portrait|food_veryhungry"), "FFFF0000")
  end
end
function on_food_common_timer()
  if g_current_player_food > 0 then
    g_current_player_food = g_current_player_food - 1
  end
  on_update_food(g_current_player_food)
end
function on_fight_state_active_food(val)
  if val == 0 then
    w_food_common_timer.suspended = true
  else
    w_food_common_timer.suspended = false
  end
end
function on_fight_state(obj, ft, idx)
  local val = obj:get_flag_objmem(idx)
  if val == 0 then
    w_pic_player_fight.visible = false
    w_lb_player_level.visible = true
  else
    w_pic_player_fight.visible = true
    w_lb_player_level.visible = false
    ui_net_delay.hide_player_reset()
  end
  on_fight_state_active_food(val)
end
function on_hp_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_enter then
    w_player_atb_lb_hp.visible = true
  elseif msg == ui.mouse_leave then
  end
end
local c_hp_prev_hold_span = 800
local c_hp_prev_hide_span = 400
local function hp_prev_update(t, d)
  local w = t.owner
  local last = d.last
  if last ~= nil then
    local tick = sys.dtick(sys.tick(), last.tick) - c_hp_prev_hold_span
    if tick < c_hp_prev_hide_span then
      local pos1 = last.pos1
      local pos2 = last.pos2
      local pos = pos1 + (pos2 - pos1) * tick / c_hp_prev_hide_span
      w.dx = pos
      w.visible = true
      t.suspended = false
      return
    end
    d.last = nil
  end
  local curr = d.curr
  if curr == nil then
    w.visible = false
    t.suspended = true
    return
  end
  local tick = sys.dtick(sys.tick(), curr.tick)
  if tick <= c_hp_prev_hold_span then
    w.dx = curr.pos1
    w.visible = true
    t.suspended = false
    return
  end
  tick = tick - c_hp_prev_hold_span
  if tick >= c_hp_prev_hide_span then
    w.visible = false
    t.suspended = true
    d.curr = nil
    return
  end
  local pos1 = curr.pos1
  local pos2 = curr.pos2
  local pos = pos1 + (pos2 - pos1) * tick / c_hp_prev_hide_span
  w.dx = pos
  w.visible = true
  t.suspended = false
end
function hp_prev_insert(t, d, dx, new_dx)
  local curr = d.curr
  if curr ~= nil then
    local tick = sys.dtick(sys.tick(), curr.tick)
    if tick <= c_hp_prev_hold_span then
      curr.pos2 = new_dx
      curr.tick = sys.tick()
      hp_prev_update(t, d)
      return
    end
    d.last = curr
  end
  d.curr = {
    pos1 = dx,
    pos2 = new_dx,
    tick = sys.tick()
  }
  hp_prev_update(t, d)
end
local player_hp_prev_data = {}
function on_player_hp_prev_timer(t)
  hp_prev_update(w_player_hp_prev_timer, player_hp_prev_data)
end
function on_update_player_hp(obj, t, i, is_init)
  local v = obj:get_atb(bo2.eAtb_HP)
  local m = obj:get_atb(bo2.eAtb_HPMax)
  w_player_atb_lb_hp.text = sys.format("%d/%d", v, m)
  if m == 0 then
    m = 1
  end
  local per = v / m
  local new_dx = w_player_atb_pic_hp.parent.dx * per
  w_player_atb_pic_hp.dx = new_dx
  local dx = w_player_atb_pic_hp.dx
  if new_dx < dx then
    hp_prev_insert(w_player_hp_prev_timer, player_hp_prev_data, dx, new_dx)
  end
  if v <= m * 0.3 then
    w_player_atb_flicker_hp.visible = true
    if v <= m * 0.1 then
      ui_dead.show(true, true)
    else
      ui_dead.show(true)
    end
  else
    w_player_atb_flicker_hp.visible = false
    ui_dead.show(false)
  end
end
function on_st_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_enter then
    w_player_atb_lb_st.visible = true
  elseif msg == ui.mouse_leave then
  end
end
function on_update_player_st(obj)
  local v = obj:get_atb(bo2.eAtb_Cha_ST)
  local m = obj:get_atb(bo2.eAtb_Cha_STMax)
  w_player_atb_lb_st.text = sys.format("%d/%d", v, m)
  if m == 0 then
    m = 1
  end
  local per = v / m
  w_player_atb_pic_st.dx = w_player_atb_pic_st.parent.dx * per
  if m_st_flicker.visible == true then
    m_st_flicker.dx = 218 - w_player_atb_pic_st.dx
  end
end
local c_nq_max = 10000
local nq_update = c_nq_max * 5
local nq_pos = {
  27,
  38,
  49,
  49,
  49
}
local nq_tick = 0
function on_nq_timer()
  local d = sys.tick() - nq_tick
  if d >= 10000 then
    w_nq_timer.suspended = true
    w_nq_flash.visible = false
  end
end
function on_update_player_nq(obj)
  local v = obj:get_atb(bo2.eAtb_Cha_NQ)
  local m = obj:get_atb(bo2.eAtb_Cha_NQMax)
  local cnt = math.floor(v / c_nq_max)
  local cnt_max = math.floor(m / c_nq_max)
  local per = (v - cnt * c_nq_max) / c_nq_max
  local step = 22
  if cnt_max > 3 then
    step = 15
  end
  if cnt_max > 4 then
    step = 12
  end
  local orig_cnt = 0
  for i, d in ipairs(nq_data) do
    local w = d.window
    if w.visible and d.pic_full.visible then
      orig_cnt = i
    end
    if i > cnt_max then
      w.visible = false
    else
      w.visible = true
      w.x = nq_pos[cnt_max] - step * (i - 1)
      d.pic_flash.x = w.x - 5
      if i <= cnt then
        local i_nq = i * c_nq_max
        local play_anim = i_nq > nq_update and v >= i_nq
        local anim = d.anim
        if play_anim then
          anim.visible = true
          anim:reset()
        else
          anim.visible = false
        end
        d.pic_full.visible = true
        d.pic_half.visible = false
        local pic = d.pic_pos
        pic.visible = true
        pic.dy = pic.parent.dy
      elseif i == cnt + 1 then
        d.anim.visible = false
        d.pic_full.visible = false
        d.pic_half.visible = true
        local pic = d.pic_pos
        pic.visible = true
        pic.dy = pic.parent.dy * per
      else
        d.anim.visible = false
        d.pic_full.visible = false
        d.pic_half.visible = true
        d.pic_pos.visible = false
      end
    end
  end
  if cnt > orig_cnt then
    nq_tick = sys.tick()
    w_nq_timer.suspended = false
    w_nq_flash.visible = true
    for i, d in ipairs(nq_data) do
      d.pic_flash.visible = i <= cnt_max
    end
  elseif cnt < orig_cnt then
    w_nq_flash.visible = false
  end
  w_nq.visible = cnt_max > 0
  nq_update = v
end
function on_palyer_nq_tip_make(tip)
  local player = bo2.player
  if player == nil then
    return
  end
  local v = player:get_atb(bo2.eAtb_Cha_NQ)
  local m = player:get_atb(bo2.eAtb_Cha_NQMax)
  local dot_num = math.floor(v / c_nq_max)
  local dot_max = math.floor(m / c_nq_max)
  local txt = ui_widget.merge_mtf({
    nq = sys.format("%d", math.fmod(v, c_nq_max) / 100),
    nq_cur = dot_num,
    nq_max = dot_max
  }, ui.get_text("portrait|nqjl"))
  ui_widget.tip_make_view(tip.view, txt)
end
local player_nq_init_w = function(w, f)
  local d = {}
  d.window = w
  d.pic_flash = f
  d.pic_full = w:search("pic_full")
  d.pic_half = w:search("pic_half")
  d.pic_pos = w:search("pic_pos")
  d.anim = w:search("anim")
  return d
end
function on_update_player_level(obj, ft, idx)
  local v = ui_widget.level_safe_scn(obj)
  w_lb_player_level.text = v
  on_pk_lvl(obj, ft, idx)
  sys.pcall(ui_quest.ui_mission.on_commend_update)
  ui_qbar.on_level_update(v)
  ui_net_delay.on_level_update(v)
  ui_gift_levelup.on_level_update(v)
  ui_tool.ui_xinshou_animation_xz.on_player_levelup()
  ui_activation.on_level_update(v)
end
function on_player_info_init(obj)
  if obj ~= bo2.player then
    return
  end
  main_init()
  member_update()
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, on_update_player_hp, "ui_portrait:on_update_player_hp")
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HPMax, on_update_player_hp, "ui_portrait:on_update_player_hp")
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Cha_ST, on_update_player_st, "ui_portrait:on_update_player_st")
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Cha_STMax, on_update_player_st, "ui_portrait:on_update_player_st")
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Cha_NQ, on_update_player_nq, "ui_portrait:on_update_player_nq")
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Cha_NQMax, on_update_player_nq, "ui_portrait:on_update_player_nq")
  nq_update = c_nq_max * 4
  nq_data = {
    player_nq_init_w(w_nq_0, w_nq_flash_0),
    player_nq_init_w(w_nq_1, w_nq_flash_1),
    player_nq_init_w(w_nq_2, w_nq_flash_2),
    player_nq_init_w(w_nq_3, w_nq_flash_3),
    player_nq_init_w(w_nq_4, w_nq_flash_4)
  }
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Level, on_update_player_level, "ui_portrait:on_update_player_level")
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_Portrait, on_player_portrait_chg, "ui_portrait:on_player_portrait_chg")
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_Food, on_player_food_chg, "ui_portrait:on_player_food_chg")
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.eFlagInt32_PKMode, on_pk_mode, "ui_portrait:on_pk_mode")
  obj:insert_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_Run, on_player_runwalk_chg, "ui_portrait:on_player_runwalk_chg")
  obj:insert_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_FightState, on_fight_state, "ui_portrait:on_fight_state")
  obj:insert_on_scnmsg(bo2.scnmsg_set_target, on_target_info_init, "ui_portrait:on_target_info_init")
  on_update_player_st(obj)
  on_update_player_nq(obj)
  on_update_player_level(obj)
  on_player_portrait_chg(obj)
  on_player_food_chg(obj)
  on_target_info_init(obj)
  set_scn_pklimit()
  reset_player_food(obj:get_flag_int32(bo2.ePlayerFlagInt32_Food))
  on_fight_state_active_food(obj:get_flag_objmem(bo2.eFlagObjMemory_FightState))
  player_hp_prev_data = {}
  w_player_hp_prev_timer.suspended = true
  w_player_hp_prev_timer.owner.visible = false
end
function is_captain()
  if bo2.player.only_id == bo2.get_captain_id() then
    return true
  end
  return false
end
function on_player_portrait_mouse(btn, msg, pos)
  if msg == ui.mouse_lbutton_down then
    bo2.send_target_packet(bo2.player.sel_handle)
  end
  if msg == ui.mouse_rbutton_down then
    local menu = menu_make(bo2.player)
    menu.consult = btn
    ui_tool.show_menu(menu)
  end
end
function on_target_portrait(btn, msg, pos)
  if msg == ui.mouse_rbutton_down then
    if bo2.scn == nil or bo2.player == nil then
      return
    end
    local target = bo2.scn:get_scn_obj(bo2.player.target_handle)
    if target == nil then
      return
    end
    local menu = menu_make(target)
    menu.consult = btn
    menu.source = btn
    ui_tool.show_menu(menu)
    menu.window.offset = btn.abs_area.p1 + pos
  end
end
function on_tot_mouse(btn, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local target = bo2.scn:get_scn_obj(bo2.player.target_handle)
    local tot = bo2.scn:get_scn_obj(target.target_handle)
    if tot == nil or tot == bo2.player then
      return
    end
    bo2.send_target_packet(tot.sel_handle)
  elseif msg == ui.mouse_rbutton_down then
    if bo2.scn == nil or bo2.player == nil then
      return
    end
    local target = bo2.scn:get_scn_obj(bo2.player.target_handle)
    target = bo2.scn:get_scn_obj(target.target_handle)
    if target == nil then
      return
    end
    if target:get_flag_objmem(bo2.eFlagObjMemory_Masked) ~= 0 then
      return
    end
    local menu = menu_make(target)
    menu.consult = btn
    ui_tool.show_menu(menu)
    menu.window.offset = btn.abs_area.p1 + pos
  end
end
local target_hp_prev_data = {}
function on_target_hp_prev_timer(t)
  hp_prev_update(w_target_hp_prev_timer, target_hp_prev_data)
end
function on_update_target_hp(obj, t, i, is_init)
  local player = bo2.player
  if player == nil then
    return
  end
  if obj.sel_handle ~= player.target_handle then
    return
  end
  local v = obj:get_atb(bo2.eAtb_HP)
  local m = obj:get_atb(bo2.eAtb_HPMax)
  if 1 == obj:get_flag_objmem(bo2.eFlagObjMemory_HideLevelBlood) then
    w_target_atb_lb_hp.text = ""
  else
    w_target_atb_lb_hp.text = sys.format("%d/%d", v, m)
  end
  if m == 0 then
    m = 1
  end
  local per = v / m
  local new_dx = w_target_atb_pic_hp.parent.dx * per
  if is_init == nil then
    local dx = w_target_atb_pic_hp.dx
    if new_dx < dx then
      hp_prev_insert(w_target_hp_prev_timer, target_hp_prev_data, dx, new_dx)
    end
  else
    target_hp_prev_data = {}
    w_target_hp_prev_timer.suspended = true
    w_target_hp_prev_timer.owner.visible = false
  end
  w_target_atb_pic_hp.dx = new_dx
  if obj.kind == bo2.eScnObjKind_Npc and v <= 0 then
    if not w_dead_cross.visible then
      w_dead_cross.visible = true
      w_dead_cross:reset()
    end
  else
    w_dead_cross.visible = false
  end
end
function on_update_target_level(obj)
  if 1 == obj:get_flag_objmem(bo2.eFlagObjMemory_HideLevelBlood) then
    w_lb_target_level.text = ""
  else
    local v = ui_widget.level_safe_scn(obj)
    w_lb_target_level.text = sys.format(L("Lv%d"), v)
  end
end
local update_target_color = function(self, obj)
  local hp_image, hp_color
  if self:IsMyEnemy(obj) then
    hp_image = "$image/qbar/portrait.png|0,68,231,16"
    hp_color = "FFFFFFFF"
    w_target_hp_bg.xcolor = "FFFF0000"
  else
    hp_image = "$image/qbar/portrait.png|233,68,231,16"
    hp_color = "FF44AA00"
    w_target_hp_bg.xcolor = "FF00FF00"
  end
  if obj.kind == bo2.eScnObjKind_Npc then
    do
      local attacker = obj:get_flag_int64(bo2.eNPcFlagInt64_FirstAttacker)
      local function get_drop_flag()
        if bo2.scn and bo2.scn.excel then
          local scn_plus = bo2.gv_scn_list_plus:find(bo2.scn.excel.id)
          if sys.check(scn_plus) and scn_plus.multi_drop ~= 0 then
            return scn_plus.multi_drop
          end
        end
        local plus = bo2.gv_cha_list_plus:find(obj.excel.id)
        if sys.check(plus) then
          local drop_flag = plus.multi_drop
          if drop_flag == 2 then
            return 0
          elseif drop_flag == 4 then
            return drop_flag
          elseif drop_flag then
            return drop_flag
          end
        end
        return 0
      end
      local function check_free_drop()
        if sys.check(obj) ~= true or sys.check(obj.excel) ~= true then
          return false
        end
        local drop_flag = get_drop_flag()
        if drop_flag == 3 then
          return true
        elseif drop_flag == 4 then
          local camp = bo2.player:get_atb(bo2.eAtb_Camp)
          local belong_flag = obj:get_flag_objmem(bo2.eFlagObjMemory_BelongCamp)
          if belong_flag ~= 0 then
            return camp == belong_flag
          end
        end
        if obj.excel.drop_type == 1 then
          return true
        end
        return bo2.IsBelongToMe(attacker)
      end
      if attacker ~= 0 and check_free_drop() ~= true then
        hp_image = "$image/qbar/portrait.png|233,68,231,16"
        hp_color = "FF666666"
      end
    end
  end
  w_target_atb_pic_hp.image = hp_image
  w_target_atb_pic_hp.xcolor = hp_color
end
function on_update_target_attacker(obj)
  update_target_color(bo2.player, obj)
end
function on_target_timer(t)
  local scn = bo2.scn
  if scn == nil then
    return
  end
  local self = bo2.player
  if self == nil then
    return
  end
  local target = scn:get_scn_obj(self.target_handle)
  if target == nil then
    return
  end
  update_target_color(self, target)
end
function update_target_belongto()
  local player = bo2.player
  if player == nil then
    return
  end
  local target = bo2.scn:get_scn_obj(player.target_handle)
  if target == nil then
    return
  end
  on_update_target_attacker(target)
end
function on_target_space_tip_make(tip)
  local player = bo2.player
  if player == nil then
    return
  end
  local obj = bo2.scn:get_scn_obj(player.target_handle)
  if obj == nil then
    return
  end
  local text
  local fb = obj.excel.fight_body
  if fb == 1 or fb == 2 then
    local t = obj:get_flag_objmem(bo2.eFlagObjMemory_SpaceType)
    if t == bo2.eScnObjSpaceType_Up then
      text = ui_widget.merge_mtf({text = text}, ui.get_text("portrait|strfukong"))
    elseif t == bo2.eScnObjSpaceType_Down then
      text = ui_widget.merge_mtf({text = text}, ui.get_text("portrait|strdaodi"))
    else
      text = ui_widget.merge_mtf({text = text}, ui.get_text("portrait|strzhangli"))
    end
  else
    text = ui_widget.merge_mtf({text = text}, ui.get_text("portrait|strbukekong"))
  end
  ui_widget.tip_make_view(tip.view, text)
end
function on_update_target_space(obj)
  local ap = w_action_pic
  local app = ap.parent
  app.visible = true
  local fb = obj.excel.fight_body
  if fb == 1 or fb == 2 then
    ap.visible = true
    app.image = "$image/qbar/portrait.png|360,99,23,26"
    local t = obj:get_flag_objmem(bo2.eFlagObjMemory_SpaceType)
    if t == bo2.eScnObjSpaceType_Up then
      ap.image = "$image/qbar/portrait.png|413,103,15,18"
    elseif t == bo2.eScnObjSpaceType_Down then
      ap.image = "$image/qbar/portrait.png|391,103,15,18"
    else
      ap.image = "$image/qbar/portrait.png|436,108,20,6"
    end
  else
    app.visible = false
  end
end
function on_get_portrait_icon(obj, id)
  local portrait_list = bo2.gv_portrait:find(id)
  if portrait_list ~= nil then
    return g_portrait_path .. portrait_list.icon .. ".png"
  else
    return g_portrait_path .. obj.excel.head_icon
  end
end
function make_icon_uri(obj)
  if obj.kind == bo2.eScnObjKind_Player then
    local id = obj:get_flag_int32(bo2.ePlayerFlagInt32_Portrait)
    if id ~= 0 then
      return on_get_portrait_icon(obj, id)
    end
  else
    local id = obj:get_flag_objmem(bo2.eFlagObjMemory_NpcTempPortrait)
    if id ~= 0 then
      return on_get_portrait_icon(obj, id)
    end
  end
  return g_portrait_path .. obj.excel.head_icon
end
function on_target_info_init(obj)
  local target = bo2.scn:get_scn_obj(obj.target_handle)
  if ui_match_cmn.is_match_enable() then
    ui_match_cmn.set_target_info(target)
  end
  if ui_knight_cmn.is_match_enable() then
    ui_knight_cmn.set_target_info(target)
  end
  if target_handle ~= obj.target_handle and target_handle ~= 0 then
    local remove_target = bo2.scn:get_scn_obj(target_handle)
    target_handle = 0
    if remove_target ~= nil then
      remove_target:remove_on_scnmsg(bo2.scnmsg_set_target, "ui_portrait.on_tot_info_init")
      remove_target:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, "ui_portrait.on_update_target_hp")
      remove_target:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HPMax, "ui_portrait.on_update_target_hp")
      remove_target:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Level, "ui_portrait.on_update_target_level")
      remove_target:remove_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_SpaceType, "ui_portrait.on_update_target_space")
      remove_target:remove_on_flagmsg(bo2.eFlagType_Int64, bo2.eNPcFlagInt64_FirstAttacker, "ui_portrait.on_update_target_attacker")
    end
  end
  if target == nil then
    set_target_visible(false)
    set_member_selected(nil)
    return
  end
  target_handle = target.sel_handle
  if target.kind == bo2.eScnObjKind_Npc and target.excel and target.excel.hide_hp == 2 then
    set_target_visible(false)
    return
  end
  set_target_visible(true)
  set_member_selected(target)
  ui_state.set_mini_handle(w_state_group1, target_handle)
  if target.kind == bo2.eScnObjKind_Player then
    w_target_career.visible = true
    local pro_value = target:get_atb(bo2.eAtb_Cha_Profession)
    local career_idx = 0
    local pro = bo2.gv_profession_list:find(pro_value)
    if pro ~= nil then
      career_idx = pro.career - 1
      make_career_color(w_target_career, pro)
    end
    w_target_career.irect = ui.rect(career_idx * 29, 98, (career_idx + 1) * 29 - 2, 128)
  else
    w_target_career.visible = false
  end
  if target.kind == bo2.eScnObjKind_Npc then
    if target.excel.fight_body == 1 then
      w_target_control_state.image = "$image/portrait/body_1.png|2,2,27,29"
      w_target_control_state.visible = true
    elseif target.excel.fight_body == 3 then
      w_target_control_state.image = "$image/portrait/body_3.png|2,2,27,29"
      w_target_control_state.visible = true
    elseif target.excel.fight_body == 4 then
      w_target_control_state.image = "$image/portrait/body_4.png|2,2,27,29"
      w_target_control_state.visible = true
    else
      w_target_control_state.visible = false
    end
  else
    w_target_control_state.visible = false
  end
  target:insert_on_scnmsg(bo2.scnmsg_set_target, on_tot_info_init, "ui_portrait.on_tot_info_init")
  target:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, on_update_target_hp, "ui_portrait.on_update_target_hp")
  target:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HPMax, on_update_target_hp, "ui_portrait.on_update_target_hp")
  target:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Level, on_update_target_level, "ui_portrait.on_update_target_level")
  target:insert_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_SpaceType, on_update_target_space, "ui_portrait.on_update_target_space")
  target:insert_on_flagmsg(bo2.eFlagType_Int64, bo2.eNPcFlagInt64_FirstAttacker, on_update_target_attacker, "ui_portrait.on_update_target_attacker")
  on_tot_info_init(target)
  on_update_target_hp(target, bo2.eFlagType_Atb, bo2.eAtb_HP, true)
  on_update_target_level(target)
  on_update_target_attacker(target)
  on_update_target_space(target)
  w_target_icon.image = make_icon_uri(target)
  w_lb_target_name.text = bo2.GetTargetName(target)
  if bo2.player:IsMyEnemy(target) then
    w_lb_target_name.color = ui.make_argb("FFFF0000")
  else
    w_lb_target_name.color = ui.make_argb("FFFFFFFF")
  end
  w_target_show:reset(0, 1, 240)
end
function set_target_visible(v)
  if ui_match_cmn.is_match_enable() then
    return
  end
  if ui_main.check_video_visble(2) == true then
    w_target_show.visible = false
    return
  end
  w_target_show.visible = v
end
function on_tot_info_init(obj)
  if obj.kind ~= bo2.eScnObjKind_Player then
    local bReturn = false
    if sys.check(obj.excel) ~= true then
      bReturn = true
    else
      local iExcelId = obj.excel.id
      local excel_plus = bo2.gv_cha_list_plus:find(iExcelId)
      if sys.check(excel_plus) and excel_plus.show_target == 0 then
        bReturn = true
      end
    end
    if bReturn == true then
      set_tot_visible(false)
      return
    end
  end
  local tot = bo2.scn:get_scn_obj(obj.target_handle)
  if tot == nil then
    set_tot_visible(false)
    return
  end
  w_tot_icon.image = make_icon_uri(tot)
  w_tot_name.text = bo2.GetTargetName(tot)
  set_tot_visible(true)
end
function set_tot_visible(v)
  if ui_match_cmn.is_match_enable() then
    return
  end
  if ui_main.check_video_visble(2) == true then
    w_tot_show.visible = false
    return
  end
  w_tot_show.visible = v
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
    return
  end
  local parent = w.parent
  local target_panel = w_target_show
  local tar_name = target_panel.name
  if w.name == tar_name then
    bo2.send_target_packet(0)
    set_tot_visible(false)
  end
  ui_widget.esc_stk_pop(w)
end
function on_player_leave(obj)
end
function on_goout_gzs(cmd, data)
  force_to_release()
end
function on_levelup_make_tip(tip)
  local player = ui_personal.ui_equip.safe_get_player()
  local stk = sys.mtf_stack()
  stk:merge({
    name = player.name,
    level = ui_widget.level_safe_scn(player)
  }, ui.get_text("portrait|strintji"))
  local txt = ui_personal.ui_equip.make_level_tip()
  if txt == nil then
    local value = player:get_atb(bo2.eAtb_Cha_Exp)
    local limit = 0
    local levelup = bo2.gv_player_levelup:find(player:get_atb(bo2.eAtb_Level))
    if levelup == nil then
      limit = value * 2 + 1
    else
      limit = levelup.exp
    end
    if value >= limit then
      txt = tip.text
    end
  end
  local scn = bo2.scn
  if scn ~= nil then
    local excel = scn.excel
    stk:merge({
      text = excel.name
    }, ui.get_text("portrait|in_scn"))
    local area_id = player:get_atb(bo2.eAtb_AreaID)
    if area_id ~= 0 then
      local area_list = bo2.gv_area_list:find(area_id)
      if area_list ~= nil then
        local t = area_list.display_name
        if t.empty then
          t = area_list.name
        end
        stk:merge({text = t}, ui.get_text("portrait|in_scn_area"))
      end
    end
    if sys.is_file("$cfg/tool/inner_config.xml") then
      stk:merge({
        text = excel.id
      }, ui.get_text("portrait|in_scn_id"))
      local t = ui_widget.merge_mtf({
        text = excel.load_path
      }, ui.get_text("portrait|in_scn_res"))
      stk:raw_format("<lb:|%s>", t)
      local gzs = player:get_flag_objmem(bo2.eFlagObjMemory_GZSId)
      local sd = ui_choice.server_list_data
      local gsz_valid = false
      if sd ~= nil then
        for n, v in pairs(sd) do
          if gzs == v.id then
            stk:merge({
              name = v.name,
              id = gzs
            }, ui.get_text("portrait|in_gzs"))
            gsz_valid = true
            break
          end
        end
      end
      if not gsz_valid then
        stk:merge({id = gzs}, ui.get_text("portrait|in_gzs"))
      end
      local target = bo2.scn:get_scn_obj(player.target_handle)
      if target ~= nil then
        stk:merge({
          text = target.excel.id
        }, ui.get_text("portrait|player_target_id"))
      end
    end
  end
  if txt ~= nil then
    stk:raw_format([[

%s]], txt)
  end
  ui_widget.tip_make_view(tip.view, stk.text)
end
function on_group_click(btn)
  local w = ui.find_control("$frame:team")
  w.visible = not w.visible
end
function on_convene_click(btn)
  local w = ui.find_control("$frame:convene")
  w.visible = not w.visible
end
function on_levelup_click(btn)
  ui_personal.ui_equip.on_levelup_click()
  ui_handson_teach.test_complate_manual_levelup_finish()
end
function on_run_walk_click(btn)
  if bo2.player.run == true then
    bo2.send_obj_flag(bo2.eFlagObjMemory_Run, 0)
  else
    bo2.send_obj_flag(bo2.eFlagObjMemory_Run, 1)
  end
end
function on_pet_rename(cmd, data)
  local only_id = data:get(packet.key.pet_only_id).v_string
  local name = data:get(packet.key.pet_name).v_string
  local target = bo2.scn:get_scn_obj(target_handle)
  if only_id == target.only_id then
    local name_w = w_target_show:search("name")
    name_w.text = name
  end
end
function force_to_release()
  bo2.group_release()
  ui.team_clear()
end
function on_goout_gzs_login()
  force_to_release()
end
function on_cmd_shownpc_target(vis)
  local target = bo2.scn:get_scn_obj(bo2.player.target_handle)
  if vis == true then
    g_tot_show = true
    if target ~= nil and target.kind == bo2.eScnObjKind_NPC then
      target:insert_on_scnmsg(bo2.scnmsg_set_target, on_tot_info_init, "ui_portrait:on_tot_info_init")
    end
  else
    g_tot_show = false
    if target ~= nil and target.kind == bo2.eScnObjKind_NPC then
      target:remove_on_scnmsg(bo2.scnmsg_set_target, "ui_portrait:on_tot_info_init")
      set_tot_visible(false)
    end
  end
end
local IsNextLevelOpen = function(level)
  local x = bo2.gv_player_levelup:find(level)
  if x == nil then
    return false
  end
  return x.is_open ~= 0
end
function RecLevelLockInfo(cmd, data)
  local id = data:get(packet.key.cmn_id).v_int
  local num = data:get(packet.key.player_count).v_int
  local time = data:get(packet.key.total_time).v_int
  local excel = bo2.gv_level_lock:find(id)
  if excel then
    local msg = {
      modal = true,
      btn_cancel = false,
      btn_confirm = true,
      btn_close = false
    }
    msg.title = ui.get_text("portrait|levellock")
    if IsNextLevelOpen(excel.level) then
      local time_text
      local day = math.floor(time / 86400)
      local hour = math.floor((time - day * 60 * 60 * 24) / 3600)
      local min = math.floor((time - day * 60 * 60 * 24 - hour * 60 * 60) / 60)
      local sec = time - day * 60 * 60 * 24 - hour * 60 * 60 - min * 60
      if day > 0 then
        time_text = sys.format("%s%s %s%s %s%s", day, ui.get_text("time|time_day"), hour, ui.get_text("time|time_hour"), min, ui.get_text("time|time_minute"))
      elseif hour > 0 then
        time_text = sys.format("%s%s %s%s", hour, ui.get_text("time|time_hour"), min, ui.get_text("time|time_minute"))
      elseif min > 0 then
        time_text = sys.format("%s%s %s%s", min, ui.get_text("time|time_minute"), sec, ui.get_text("time|time_second"))
      else
        time_text = sys.format("%s%s", sec, ui.get_text("time|time_second"))
      end
      msg.text = ui_widget.merge_mtf({
        level = excel.level,
        time = time_text,
        level_1 = excel.level,
        info = excel.info
      }, ui.get_text("portrait|levellockinfo"))
    else
      msg.text = ui.get_text("portrait|levellock_not_open") .. "\n" .. excel.info
    end
    ui_widget.ui_msg_box.show_common(msg)
  end
end
function runf_on_player_info_init()
  local obj = bo2.player
  on_player_info_init(obj)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_portrait.packet_handle"
reg(packet.eSTC_Fake_goout_gzs, on_goout_gzs, sig)
reg(packet.eSTC_Pet_Rename, on_pet_rename, sig)
reg(packet.eSTC_Fake_goout_login, on_goout_gzs_login, sig)
reg(packet.eSTC_UI_LevelLock, RecLevelLockInfo, sig)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_player_info_init, "ui_portrait:on_player_info_init")
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_leave, on_player_leave, "ui_portrait:on_player_leave")
