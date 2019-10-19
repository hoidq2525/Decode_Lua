local get_im_info = function(info_id)
  local excel = bo2.gv_im_info:find(info_id)
  if excel ~= nil then
    return excel.name
  else
    return ui.get_text("advertise|none_info")
  end
end
item_create = {}
item_create[packet.key.sociality_personals_name] = function(name)
  return name.v_string
end
item_create[packet.key.sociality_personals_sex] = function(var_sex)
  local sex = var_sex.v_int
  if sex == bo2.eSex_Male then
    return ui.get_text("advertise|male")
  elseif sex == bo2.eSex_Female then
    return ui.get_text("advertise|female")
  end
end
item_create[packet.key.sociality_personals_married] = function(var_is_married)
  local is_married = var_is_married.v_int
  if is_married == 1 then
    return ui.get_text("advertise|is_married")
  else
    return ui.get_text("advertise|not_married")
  end
end
item_create[packet.key.sociality_personals_region] = function(region)
  return get_im_info(region.v_int)
end
item_create[packet.key.sociality_personals_age] = function(age)
  return get_im_info(age.v_int)
end
item_create[packet.key.sociality_personals_constellation] = function(constellation)
  return get_im_info(constellation.v_int)
end
item_create[packet.key.sociality_personals_level] = function(level)
  return level.v_int
end
item_create[packet.key.sociality_personals_guild_name] = function(guild_name)
  local name = guild_name.v_string
  if name.empty == true then
    return ui.get_text("advertise|none_info")
  else
    return name
  end
end
item_create[packet.key.sociality_personals_profession] = function(profession_id)
  local excel = bo2.gv_profession_list:find(profession_id.v_int)
  if excel ~= nil then
    return excel.name
  end
end
item_create[packet.key.sociality_personals_identity] = function(id)
  if id.v_int == 0 then
    return ui.get_text("advertise|none_info")
  else
    local pos_str = ui.get_text("org|guild_pos" .. id.v_int)
    return pos_str
  end
end
item_create[packet.key.sociality_personals_team_name] = function(team_name)
  return team_name.v_string
end
item_create[packet.key.sociality_personals_team_leader] = function(leader_name)
  return leader_name.v_string
end
item_create[packet.key.sociality_personals_team_level] = function(level)
  return level.v_int
end
item_create[packet.key.sociality_personals_need_profession] = function(profession_id)
  local excel = bo2.gv_profession_list:find(profession_id.v_int)
  if excel ~= nil then
    return excel.name
  end
end
item_create[packet.key.sociality_personals_team_average_level] = function(level)
  return level.v_int
end
item_create[packet.key.sociality_personals_need_min_level] = function(level)
  return level.v_int
end
item_create[packet.key.sociality_personals_master_level] = function(master_level)
  return master_level.v_int
end
item_create[packet.key.sociality_personals_guild_level] = function(level)
  return level.v_int
end
item_create[packet.key.sociality_personals_guild_leader_name] = function(leader_name)
  return leader_name.v_string
end
item_create[packet.key.sociality_personals_guild_development] = function(development)
  return development.v_int
end
item_create[packet.key.sociality_personals_guild_extent] = function(extent)
  return extent.v_int
end
item_create[packet.key.sociality_personals_guild_popularity] = function(popularity)
  return popularity.v_int
end
