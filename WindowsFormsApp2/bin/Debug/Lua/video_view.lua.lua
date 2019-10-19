local time_num1 = 0
local time_num2 = 0
local time_num3 = 0
local TIMER_IMAGE_FORMAT = L("$image/match_cmn/%s.png|14,0,50,64")
local c_player_nq_max = 10000
local g_match_watch_mode = false
local g_match_watch_mode_set_player = false
function on_make_atb(obj, i, v)
  local cur_atb = obj:get_atb(i)
  local cur_atb_max = obj:get_atb(v.limit)
  v.bind_pic.dx = v.max_length * cur_atb / cur_atb_max
  v.bind_label.text = sys.format(v.make_text, cur_atb, cur_atb_max)
end
function on_make_self_atb(obj, i, v)
  on_make_atb(obj, i, v)
  render_player_item(gx_player_item_left, obj)
end
function on_make_star(obj, i, v)
  local cur_atb = obj:get_atb(i)
  local cur_nq_max = obj:get_atb(v.limit)
  if cur_nq_max < c_player_nq_max then
    ui_video_view.fg_bg_star.visible = false
    ui_video_view.fg_blue_star.visible = false
    ui_video_view.fg_red_star.visible = false
    return
  end
  ui_video_view.fg_blue_star.visible = true
  ui_video_view.fg_red_star.visible = true
  ui_video_view.fg_bg_star.visible = true
  local cur_nq_num = math.floor(cur_nq_max / c_player_nq_max)
  for index = 0, cur_nq_num - 1 do
    local cur_figure = ui_video_view.fg_bg_star:search(sys.format(L("dot_bg%d"), index))
    cur_figure.dx = 16
  end
  local dot_num = math.floor(cur_atb / c_player_nq_max)
  local red_dot_num = dot_num - 1
  local blue_num = cur_atb % c_player_nq_max
  for index = 0, 2 do
    local cur_figure = ui_video_view.fg_red_star:search(sys.format(L("dot_red%d"), index))
    local cur_blue_figure = ui_video_view.fg_blue_star:search(sys.format(L("dot%d"), index))
    if index <= red_dot_num then
      cur_figure.dx = 16
    else
      cur_figure.dx = 0
    end
    if sys.check(cur_figure) then
      if index == dot_num then
        cur_blue_figure.dx = 16 * blue_num / c_player_nq_max
      else
        cur_blue_figure.dx = 0
      end
    end
  end
end
function init_once()
  ui_video_view.atb_def = {}
  ui_video_view.atb_def[bo2.eAtb_HP] = {
    reg = bo2.eAtb_HP,
    limit = bo2.eAtb_HPMax,
    bind_pic = ui_video_view.fg_cur_hp,
    bind_label = ui_video_view.lb_cur_hp,
    max_length = 350,
    on_make = on_make_self_atb,
    make_text = L("%d/%d")
  }
  ui_video_view.atb_def[bo2.eAtb_Cha_ST] = {
    reg = bo2.eAtb_Cha_ST,
    limit = bo2.eAtb_Cha_STMax,
    bind_pic = ui_video_view.fg_cur_sp,
    bind_label = ui_video_view.lb_cur_sp,
    max_length = 275,
    on_make = on_make_atb,
    make_text = L("%d/%d")
  }
  ui_video_view.atb_def[bo2.eAtb_Cha_NQ] = {
    reg = bo2.eAtb_Cha_NQ,
    value = bo2.eAtb_Cha_NQ,
    limit = bo2.eAtb_Cha_NQMax,
    on_make = on_make_star
  }
  ui_video_view.atb_def_target = {}
  ui_video_view.atb_def_target[bo2.eAtb_HP] = {
    value = bo2.eAtb_HP,
    limit = bo2.eAtb_HPMax,
    bind_pic = ui_video_view.fg_target_hp,
    bind_label = ui_video_view.lb_target_hp,
    on_make = on_make_atb,
    max_length = 350,
    make_text = L("%d/%d")
  }
end
function set_timer(num1, num2, num3)
  time_num1 = num1
  time_num2 = num2
  time_num3 = num3
  if sys.check(ui_video_view.gx_time_info_image1) and sys.check(ui_video_view.gx_time_info_image2) and sys.check(ui_video_view.gx_time_info_image3) then
    ui_video_view.gx_time_info_image1.image = sys.format(TIMER_IMAGE_FORMAT, time_num1)
    ui_video_view.gx_time_info_image2.image = sys.format(TIMER_IMAGE_FORMAT, time_num2)
    ui_video_view.gx_time_info_image3.image = sys.format(TIMER_IMAGE_FORMAT, time_num3)
  end
end
function clear_player_item(item)
  item:search("player_name").text = ""
  item:search("portrait").visible = false
  item:search("job").visible = false
  item:search("hp_val").text = ""
  item:search("cur_hp").parent.dx = 0
end
function on_career_tip_make(tip)
  local panel = tip.owner.parent
  local career_panel = panel:search("job")
  local pro_list = bo2.gv_profession_list:find(career_panel.svar)
  if sys.check(pro_list) then
    text = sys.format("%s", pro_list.name)
    ui_widget.tip_make_view(tip.view, text)
  end
end
function get_career_idx(val)
  local pro = bo2.gv_profession_list:find(val)
  if pro == nil then
    return 0
  end
  return pro.career - 1
end
function render_player_item(item, obj)
  if item == gx_player_item_left then
    if g_match_watch_mode ~= nil and g_match_watch_mode == false then
      ui_video_view.g_fg_sp_text.visible = true
      ui_video_view.g_fg_sp_pic.visible = true
      ui_video_view.fg_sp_bg.visible = true
      ui_video_view.fg_bg_star.visible = true
    else
      ui_video_view.g_fg_sp_text.visible = false
      ui_video_view.g_fg_sp_pic.visible = false
      ui_video_view.fg_sp_bg.visible = false
      ui_video_view.fg_bg_star.visible = false
    end
  end
  item:search("player_name").text = obj.name
  local career = obj:get_atb(bo2.eAtb_Cha_Profession)
  local career_panel = item:search("job")
  if sys.check(career) then
    local career_idx = get_career_idx(career)
    career_panel.irect = ui.rect(career_idx * 21, 0, (career_idx + 1) * 21, 32)
    career_panel.svar = career
    career_panel.visible = true
  end
  local portrait = obj:get_flag_int32(bo2.ePlayerFlagInt32_Portrait)
  local por_list = bo2.gv_portrait:find(portrait)
  local portrait = item:search("portrait")
  if obj.kind == bo2.eScnObjKind_Player then
    if por_list ~= nil then
      portrait.image = sys.format("$icon/portrait/%s.png", por_list.icon)
      portrait.visible = true
    end
  else
    por_list = obj.pic_excel.head_icon
    if por_list ~= nil then
      local pic = sys.format("$icon/portrait/%s", por_list)
      portrait.image = pic
      portrait.visible = true
    end
  end
  local cur_hp = obj:get_atb(bo2.eAtb_HP)
  local max_hp = obj:get_atb(bo2.eAtb_HPMax)
  item:search("hp_val").text = sys.format("%d/%d", cur_hp, max_hp)
  item:search("cur_hp").parent.dx = 350 * (cur_hp / max_hp)
  ui_state.set_mini_handle(item:search("state"), obj.sel_handle)
end
function update_player_atb(obj, ft, idx)
  if obj == nil then
    ui.log("ui_video_view.update_player_atb obj nil")
    return
  end
  local v = ui_video_view.atb_def[idx]
  if sys.check(v) and sys.check(v.on_make) then
    v.on_make(obj, idx, v)
  end
end
function update_player_target_atb(obj, ft, idx)
  if obj == nil then
    ui.log("ui_video_view.update_player_atb obj nil")
    return
  end
  local v = ui_video_view.atb_def_target[idx]
  if sys.check(v) and sys.check(v.on_make) then
    v.on_make(obj, idx, v)
  end
end
function update_match_mode_tot(obj)
  gx_player_item_right.visible = false
  if sys.check(g_current_target) then
    g_current_target:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, "ui_video_view.update_target_hp")
  end
  local target = bo2.scn:get_scn_obj(obj.target_handle)
  if sys.check(target) then
    gx_player_item_right.visible = true
    g_current_target = target
    g_current_target:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, update_player_target_atb, "ui_video_view.update_target_hp")
    render_player_item(gx_player_item_right, g_current_target)
    update_player_target_atb(target, 0, bo2.eAtb_HP)
  else
    clear_player_item(gx_player_item_right)
  end
end
function update_player_target_match_mode(obj)
  if g_match_watch_mode_set_player == true then
    return
  end
  bo2.ChgCamera(obj.sel_handle)
  local target = obj
  gx_player_item_left.visible = true
  render_player_item(gx_player_item_left, target)
  for i, v in pairs(ui_video_view.atb_def) do
    if sys.check(v) and sys.check(v.reg) then
      v.on_make(obj, i, v)
      target:insert_on_flagmsg(bo2.eFlagType_Atb, v.reg, update_player_atb, "ui_video_view.update_player_atb")
    end
  end
  target:insert_on_scnmsg(bo2.scnmsg_set_target, update_match_mode_tot, "ui_video_view.update_match_mode_tot")
  g_match_watch_mode_set_player = true
  gx_player_item_right.visible = false
  if sys.check(g_current_target) then
    g_current_target:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, "ui_video_view.update_target_hp")
  end
  local target = bo2.scn:get_scn_obj(obj.target_handle)
  if sys.check(target) then
    gx_player_item_right.visible = true
    g_current_target = target
    g_current_target:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, update_player_target_atb, "ui_video_view.update_target_hp")
    render_player_item(gx_player_item_right, g_current_target)
    update_player_target_atb(target, 0, bo2.eAtb_HP)
  else
    clear_player_item(gx_player_item_right)
  end
end
function on_mouse_match_change_target(w, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    ui.log("click?")
    if g_match_watch_mode == true and sys.check(g_current_target) then
      local bPlayer = g_current_target.kind == bo2.eScnObjKind_Player
      if bPlayer ~= true then
        return
      end
      local target = bo2.scn:get_scn_obj(g_current_target.target_handle)
      if sys.check(target) ~= true or target.kind ~= bo2.eScnObjKind_Player then
        return
      end
      g_current_target:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, "ui_video_view.update_target_hp")
      target:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, "ui_video_view.update_player_atb")
      render_player_item(gx_player_item_left, g_current_target)
      g_current_target:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, update_player_atb, "ui_video_view.update_player_atb")
      for i, v in pairs(ui_video_view.atb_def) do
        if sys.check(v) and sys.check(v.reg) then
          v.on_make(g_current_target, i, v)
        end
      end
      render_player_item(gx_player_item_right, target)
      target:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, update_player_target_atb, "ui_video_view.update_target_hp")
      update_player_target_atb(target, 0, bo2.eAtb_HP)
      bo2.ChgCamera(g_current_target.sel_handle)
      g_current_target = target
    end
  end
end
function update_player_target(obj)
  if g_match_watch_mode == true then
    local target = bo2.scn:get_scn_obj(obj.target_handle)
    if sys.check(target) then
      update_player_target_match_mode(target)
    end
    return
  end
  gx_player_item_right.visible = false
  if sys.check(g_current_target) then
    g_current_target:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, "ui_video_view.update_target_hp")
  end
  local target = bo2.scn:get_scn_obj(obj.target_handle)
  if sys.check(target) then
    gx_player_item_right.visible = true
    g_current_target = target
    g_current_target:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, update_player_target_atb, "ui_video_view.update_target_hp")
    render_player_item(gx_player_item_right, g_current_target)
    update_player_target_atb(target, 0, bo2.eAtb_HP)
  else
    clear_player_item(gx_player_item_right)
  end
end
function set_match_watch_mode(obj, bWatch)
  g_match_watch_mode = bWatch
  obj:SetShow(bo2.eShowType_MatchSpectator, not bWatch)
  bo2.SetMatchSpectator(bWatch)
  g_match_watch_mode = bWatch
end
function on_set_self_watch_mode(obj, val)
  local bMatch = obj:get_flag_bit(bo2.ePlayerFlagBit_VisionTransparent)
  if bMatch == 1 then
    set_match_watch_mode(obj, true)
    g_match_watch_mode = true
    g_match_watch_mode_set_player = false
    update_player_target(bo2.player)
  end
end
function on_self_enter()
  if bo2.video_mode == nil then
    return
  end
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return false
  end
  init_once()
  local bMatch = obj:get_flag_bit(bo2.ePlayerFlagBit_VisionTransparent)
  g_match_watch_mode = false
  if bMatch == 1 then
    set_match_watch_mode(obj, true)
    obj:insert_on_scnmsg(bo2.scnmsg_set_target, update_player_target, "ui_video_view.update_player_target")
    g_match_watch_mode_set_player = false
  else
    set_match_watch_mode(obj, false)
    render_player_item(gx_player_item_left, obj)
    clear_player_item(gx_player_item_right)
    for i, v in pairs(ui_video_view.atb_def) do
      if sys.check(v) and sys.check(v.reg) then
        v.on_make(obj, i, v)
        obj:insert_on_flagmsg(bo2.eFlagType_Atb, v.reg, update_player_atb, "ui_video_view.update_player_atb")
      end
    end
    obj:insert_on_scnmsg(bo2.scnmsg_set_target, update_player_target, "ui_video_view.update_player_target")
    obj:insert_on_flagmsg(bo2.eFlagType_Bit, bo2.ePlayerFlagBit_VisionTransparent, on_set_self_watch_mode, "ui_video_view.on_set_self_watch_mode")
  end
end
function on_init()
  if bo2.video_mode == nil then
    return
  end
  if ui_phase.w_outer_config ~= nil and sys.check(ui_video.w_video_cover) then
    ui_video.w_video_cover.dock = L("pin_xy")
  end
end
function on_visible_set_text_timer(w, vis)
  ui_video.lb_pause_replay.visible = vis
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_video_view.on_self_enter")
