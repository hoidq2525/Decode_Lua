local reg = ui_packet.game_recv_signal_insert
local sig = "ui_knight_cmn.packet_handler"
local time_num1 = 0
local time_num2 = 0
local time_num3 = 0
local TIMER_IMAGE_FORMAT = L("$image/match_cmn/%s.png|14,0,50,64")
local g_cur_target, g_cur_tot
function on_timer()
  if time_num3 == 0 and time_num2 == 0 and time_num1 == 0 then
    gx_timer.suspended = true
    return
  end
  if time_num3 == 0 then
    if time_num2 == 0 then
      if time_num1 == 0 then
        return
      else
        time_num1 = time_num1 - 1
      end
      time_num2 = 9
    else
      time_num2 = time_num2 - 1
    end
    time_num3 = 9
  else
    time_num3 = time_num3 - 1
  end
  gx_time_info_image1.image = sys.format(TIMER_IMAGE_FORMAT, time_num1)
  gx_time_info_image2.image = sys.format(TIMER_IMAGE_FORMAT, time_num2)
  gx_time_info_image3.image = sys.format(TIMER_IMAGE_FORMAT, time_num3)
end
function on_career_tip_make(tip)
  local panel = tip.owner.parent
  local career_panel = panel:search("job")
  local pro_list = bo2.gv_profession_list:find(career_panel.svar)
  text = sys.format("%s", pro_list.name)
  ui_widget.tip_make_view(tip.view, text)
end
function get_career_idx(val)
  local pro = bo2.gv_profession_list:find(val)
  if pro == nil then
    return 0
  end
  return pro.career - 1
end
function clear_player_item(item)
  item:search("player_name").text = ""
  item:search("portrait").visible = false
  item:search("job").visible = false
  item:search("hp_val").text = ""
  item:search("cur_hp").parent.dx = 0
end
function render_player_item(item, obj, type)
  item:search("player_name").text = obj.name
  local portrait
  if type == nil then
    portrait = obj:get_flag_int32(bo2.ePlayerFlagInt32_Portrait)
    local por_list = bo2.gv_portrait:find(portrait)
    portrait = item:search("portrait")
    portrait.image = sys.format("$icon/portrait/%s.png", por_list.icon)
  elseif type == 1 then
    local por_list = ui_scn_knightunit.g_knight_members[obj.name]:search("portrait").svar
    portrait = item:search("portrait")
    portrait.image = sys.format("$icon/portrait/%s", por_list)
  end
  portrait.visible = true
  local career
  if type == nil then
    career = obj:get_atb(bo2.eAtb_Cha_Profession)
  elseif type == 1 then
    career = ui_scn_knightunit.g_knight_members[obj.name]:search("job").svar
  end
  local career_panel = item:search("job")
  local career_idx = get_career_idx(career)
  career_panel.irect = ui.rect(career_idx * 21, 0, (career_idx + 1) * 21, 32)
  career_panel.svar = career
  career_panel.visible = true
  local cur_hp = obj:get_atb(bo2.eAtb_HP)
  local max_hp = obj:get_atb(bo2.eAtb_HPMax)
  item:search("hp_val").text = sys.format("%d/%d", cur_hp, max_hp)
  item:search("cur_hp").parent.dx = 350 * (cur_hp / max_hp)
end
function update_target(obj)
  if obj == bo2.player then
    return
  end
  local cur_hp = obj:get_atb(bo2.eAtb_HP)
  local max_hp = obj:get_atb(bo2.eAtb_HPMax)
  gx_player_item_left:search("hp_val").text = sys.format("%d/%d", cur_hp, max_hp)
  gx_player_item_left:search("cur_hp").parent.dx = 350 * (cur_hp / max_hp)
end
function update_tot(obj)
  if obj == bo2.player then
    return
  end
  local cur_hp = obj:get_atb(bo2.eAtb_HP)
  local max_hp = obj:get_atb(bo2.eAtb_HPMax)
  gx_player_item_right:search("hp_val").text = sys.format("%d/%d", cur_hp, max_hp)
  gx_player_item_right:search("cur_hp").parent.dx = 350 * (cur_hp / max_hp)
end
function set_tot_info(target)
  if target == nil then
    return
  end
  local obj = bo2.scn:get_scn_obj(target.target_handle)
  if obj == bo2.player then
    return
  end
  if g_cur_tot ~= nil then
    g_cur_tot:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, "ui_knight_cmn:update_tot")
    g_cur_tot = nil
  end
  if obj == g_cur_target then
    clear_player_item(gx_player_item_right)
    return
  end
  if obj ~= nil and obj.kind == bo2.eScnObjKind_Player then
    render_player_item(gx_player_item_right, obj)
    g_cur_tot = obj
    obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, update_tot, "ui_knight_cmn:update_tot")
  elseif obj ~= nil and obj.kind == bo2.eScnObjKind_Npc then
    render_player_item(gx_player_item_right, obj, 1)
    g_cur_tot = obj
    obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, update_tot, "ui_knight_cmn:update_tot")
  else
    clear_player_item(gx_player_item_right)
  end
end
function set_target_info(obj)
  if obj == bo2.player then
    return
  end
  if obj.kind ~= bo2.eScnObjKind_Player then
    return
  end
  if g_cur_target ~= nil then
    g_cur_target:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, "ui_knight_cmn:update_target")
    g_cur_target:remove_on_scnmsg(bo2.scnmsg_set_target, "ui_knight_cmn:set_tot_info")
  end
  if obj ~= nil and obj.kind == bo2.eScnObjKind_Player then
    render_player_item(gx_player_item_left, obj)
    g_cur_target = obj
    set_tot_info(g_cur_target)
    obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, update_target, "ui_knight_cmn:update_target")
    obj:insert_on_scnmsg(bo2.scnmsg_set_target, set_tot_info, "ui_knight_cmn:set_tot_info")
  else
    clear_player_item(gx_player_item_left)
  end
end
function on_knight_cmn_visible(panel, vis)
  ui_net_delay.w_main.visible = not vis
  ui_qbar.w_qbar.visible = not vis
  ui_portrait.w_main.visible = not vis
  if vis == false then
    clear_player_item(gx_player_item_left)
    clear_player_item(gx_player_item_right)
    gx_timer.suspended = true
    if g_cur_target ~= nil then
      g_cur_target:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, "ui_knight_cmn:update_target")
      g_cur_target:remove_on_scnmsg(bo2.scnmsg_set_target, "ui_knight_cmn:set_tot_info")
      g_cur_target = nil
    end
    if g_cur_tot ~= nil then
      g_cur_tot:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, "ui_knight_cmn:update_tot")
      g_cur_tot = nil
    end
  else
    clear_player_item(gx_player_item_right)
    clear_player_item(gx_player_item_left)
    gx_begin_timer.suspended = false
  end
end
function on_knight_cmn_init()
end
function on_begin_timer()
  if g_cur_target == nil then
    return
  end
  if g_cur_tot ~= nil then
    gx_begin_timer.suspended = true
    return
  end
  set_tot_info(g_cur_target)
  gx_begin_timer.suspended = true
end
function set_timer(num1, num2, num3)
  time_num1 = num1
  time_num2 = num2
  time_num3 = num3
  gx_time_info_image1.image = sys.format(TIMER_IMAGE_FORMAT, time_num1)
  gx_time_info_image2.image = sys.format(TIMER_IMAGE_FORMAT, time_num2)
  gx_time_info_image3.image = sys.format(TIMER_IMAGE_FORMAT, time_num3)
  gx_timer.suspended = false
end
function set_visible(vis)
  gx_knight_cmn.visible = vis
end
function is_match_enable()
  return gx_knight_cmn.visible
end
function knight_pk_info_show(cmn, var)
  local fighter_name = var:get(packet.key.knight_pk_fighter_name).v_string
  if fighter_name == bo2.player.name then
    return
  end
  ui_deathui.set_knight_pk_info_visible(var, true)
end
reg(packet.eSTC_Knight_PK_Info, knight_pk_info_show, sig)
