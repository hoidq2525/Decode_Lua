G_MAX_WATCH = 5
G_HP_MAX_LENGTH = 237
function set_career_icon(pic, career_idx)
  pic.image = sys.format("$image/personal/32x32/%d.png|0,0,27,30", career_idx + 1)
end
function set_career_color(pic, career_idx)
  local pro = bo2.gv_profession_list:find(career_idx)
  if pro ~= nil then
    ui_portrait.make_career_color(pic, pro)
  end
end
function is_already_exist(only_id)
  local size = w_member_list.item_count
  for i = 0, size - 1 do
    local item = w_member_list:item_get(i)
    local id = item.var:get("only_id").v_string
    if id == only_id then
      return true
    end
  end
  return false
end
function on_member_update(member_info)
  local size = w_member_list.item_count
  for i = 0, size - 1 do
    local item = w_member_list:item_get(i)
    local only_id = item.var:get("only_id").v_string
    if member_info.only_id == only_id then
      local name = item:search("name")
      name.text = member_info.name
      local level = item:search("level")
      local param = sys.variant()
      param:set("level", member_info.level)
      level.text = sys.mtf_merge(param, ui.get_text("team|member_level"))
      local captain = item:search("captain")
      local career = item:search("career")
      local career_idx = ui_portrait.get_career_idx(member_info.career)
      set_career_icon(career, career_idx)
      set_career_color(career, member_info.career)
      if member_info.is_captain then
        captain.visible = true
      else
        captain.visible = false
      end
      local hp = item:search("hp")
      hp.dx = G_HP_MAX_LENGTH * (member_info.hp / member_info.hp_max)
      if member_info.only_id == bo2.player.only_id then
        local param = sys.variant()
        param:set("level", bo2.player:get_atb(bo2.eAtb_Level))
        level.text = sys.mtf_merge(param, ui.get_text("team|member_level"))
        hp.dx = G_HP_MAX_LENGTH * (bo2.player:get_atb(bo2.eAtb_HP) / bo2.player:get_atb(bo2.eAtb_HPMax))
        if member_info.status == 1 then
          name.xcolor = ui_team.c_status_slef
          break
        end
        if member_info.status == 0 then
          name.xcolor = ui_team.c_status_offline
          break
        end
        if 0 >= bo2.player:get_atb(bo2.eAtb_HP) then
          name.xcolor = ui_team.c_status_dead
        end
        break
      end
      if member_info.status == 1 then
        name.xcolor = ui_team.c_status_online
        ui_team.set_ctrl_onoffline(level, true)
        ui_team.set_ctrl_onoffline(career, true)
      end
      if 0 >= member_info.hp then
        name.xcolor = ui_team.c_status_dead
        ui_team.set_ctrl_onoffline(level, true)
        ui_team.set_ctrl_onoffline(career, true)
      end
      if member_info.status == 0 then
        name.xcolor = ui_team.c_status_offline
        hp.dx = G_HP_MAX_LENGTH
        ui_team.set_ctrl_onoffline(level, false)
        ui_team.set_ctrl_onoffline(career, false)
      end
      break
    end
  end
end
function add_member(member_info)
  local size = w_member_list.item_count
  if size >= G_MAX_WATCH then
    ui_tool.note_insert(ui.get_text("team|watch_max_warning"), ui_team.warning_color)
    return false
  end
  if is_already_exist(member_info.only_id) then
    ui_tool.note_insert(ui.get_text("team|already_watched"), ui_team.warning_color)
    return false
  end
  local item_file = L("$frame/team/watch.xml")
  local item_style = L("member")
  local item = w_member_list:item_append()
  item:load_style(item_file, item_style)
  local name = item:search("name")
  name.text = member_info.name
  local level = item:search("level")
  local param = sys.variant()
  param:set("level", member_info.level)
  level.text = sys.mtf_merge(param, ui.get_text("team|member_level"))
  local career = item:search("career")
  local career_idx = ui_portrait.get_career_idx(member_info.career)
  set_career_icon(career, career_idx)
  set_career_color(career, member_info.career)
  local captain = item:search("captain")
  if member_info.is_captain then
    captain.visible = true
  else
    captain.visible = false
  end
  local hp = item:search("hp")
  hp.dx = G_HP_MAX_LENGTH * (member_info.hp / member_info.hp_max)
  item.var:set("only_id", member_info.only_id)
  local btn_check = item:search("btn_watch")
  btn_check.check = true
  if member_info.only_id == bo2.player.only_id then
    local param = sys.variant()
    param:set("level", bo2.player:get_atb(bo2.eAtb_Level))
    level.text = sys.mtf_merge(param, ui.get_text("team|member_level"))
    hp.dx = G_HP_MAX_LENGTH * (bo2.player:get_atb(bo2.eAtb_HP) / bo2.player:get_atb(bo2.eAtb_HPMax))
    career_idx = ui_portrait.get_career_idx(bo2.player:get_atb(bo2.eAtb_Cha_Profession))
    set_career_icon(career, career_idx)
    set_career_color(career, bo2.player:get_atb(bo2.eAtb_Cha_Profession))
    if member_info.status == 1 then
      name.xcolor = ui_team.c_status_slef
      ui_team.set_ctrl_onoffline(level, true)
      ui_team.set_ctrl_onoffline(career, true)
    elseif member_info.status == 0 then
      name.xcolor = ui_team.c_status_offline
      hp.dx = G_HP_MAX_LENGTH
      ui_team.set_ctrl_onoffline(level, false)
      ui_team.set_ctrl_onoffline(career, false)
    elseif bo2.player:get_atb(bo2.eAtb_HP) <= 0 then
      name.xcolor = ui_team.c_status_dead
      ui_team.set_ctrl_onoffline(level, true)
      ui_team.set_ctrl_onoffline(career, true)
    end
    return true
  end
  if member_info.status == 1 then
    name.xcolor = ui_team.c_status_online
    ui_team.set_ctrl_onoffline(level, true)
    ui_team.set_ctrl_onoffline(career, true)
  elseif member_info.status == 0 then
    name.xcolor = ui_team.c_status_offline
    hp.dx = G_HP_MAX_LENGTH
    ui_team.set_ctrl_onoffline(level, false)
    ui_team.set_ctrl_onoffline(career, false)
  elseif member_info.hp <= 0 then
    name.xcolor = ui_team.c_status_dead
    ui_team.set_ctrl_onoffline(level, true)
    ui_team.set_ctrl_onoffline(career, true)
  end
  return true
end
function del_member(id)
  if id == sys.wstring(0) then
    return
  end
  local size = w_member_list.item_count
  for i = 0, size - 1 do
    local item = w_member_list:item_get(i)
    if item ~= nil then
      local only_id = item.var:get("only_id").v_string
      if id == only_id then
        w_member_list:item_remove(i)
      end
    end
  end
end
function set_visible(vis)
  local w = ui.find_control("$frame:team_watch")
  w.visible = vis
end
function is_visible()
  local w = ui.find_control("$frame:team_watch")
  return w.visible
end
function on_del_click(btn)
  ui.log("del_watch")
  local parent = btn.parent.parent
  local only_id = parent.var:get("only_id").v_string
  ui_team.set_check_false(only_id)
  del_member(only_id)
end
function on_member_watch(btn)
  local item = btn.parent.parent.parent
  local only_id = item.var:get("only_id").v_string
  if btn.check == false then
    del_member(only_id)
    ui_team.set_check_false(only_id)
  end
end
function clear_all()
  w_member_list:item_clear()
end
