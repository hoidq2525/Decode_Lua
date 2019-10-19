local MAX_SKILL_LEVEL = 30
function ctip_make_state(stk, info, time)
  local excel = info.excel
  stk:raw_push("<a:m>")
  local title = sys.format("%s", excel.name)
  local state, kanr
  if excel.kanr == 0 then
    kanr = ""
  elseif excel.kanr == 1 then
    kanr = ui.get_text("skill|kanr_type_confuse")
  elseif excel.kanr == 2 then
    kanr = ui.get_text("skill|kanr_type_restrict")
  elseif excel.kanr == 3 then
    kanr = ui.get_text("skill|kanr_type_elapse")
  elseif excel.kanr == 4 then
    kanr = ui.get_text("skill|kanr_type_weaken")
  end
  local level = bo2.player:get_atb(bo2.eAtb_Level)
  local xinfa_excel = bo2.gv_xinfa_list:find(excel.xingfa)
  local xinfa_level = 0
  local modi = excel.diff_modi
  local effect_type = excel.effect_type
  local effect_type_s
  if xinfa_excel == nil then
    modi = modi + level
  else
    if ui.xinfa_find(xinfa_excel.id) then
      xinfa_level = ui.xinfa_find(xinfa_excel.id).level
    end
    if level > xinfa_level then
      modi = xinfa_level + modi
    elseif level <= xinfa_level then
      modi = level + modi
    end
  end
  if effect_type == 0 then
    effect_type_s = ui.get_text("skill|effect_type_normal")
  elseif effect_type == 1 then
    effect_type_s = ui.get_text("skill|effect_type_body")
  elseif effect_type == 2 then
    effect_type_s = ui.get_text("skill|effect_type_poison")
  elseif effect_type == 3 then
    effect_type_s = ui.get_text("skill|effect_type_disease")
  elseif effect_type == 4 then
    effect_type_s = ui.get_text("skill|effect_type_magic")
  elseif effect_type == 4 then
    effect_type_s = ui.get_text("skill|effect_type_witchcraft")
  end
  stk:raw_push("<a:m>")
  stk:raw_push("<lb:,,,00B050|")
  stk:push(title)
  stk:raw_push(">")
  stk:raw_push("<lb:,,,FFC000|")
  stk:push(state)
  stk:raw_push(">")
  stk:raw_push("<a:l>")
  stk:raw_push(sys.format([[


%s]], excel.desc))
  stk:raw_push("<a:r>")
  ctip_push_text(stk, sys.format([[


%s]], time), SHARED("FF0000"))
end
function ctip_make_liyi(stk, excel)
  local weapon_color = "00ffff"
  stk:raw_push(sys.format("<skill_icon:%s,%s,%s,%s>", excel.id, ui.get_text("skill|etiquette_skill"), weapon_color, excel.name))
  return
end
local iCheckNum = 4
local tEquipType = {
  bo2.eItemSlot_MainWeapon,
  bo2.eItemSlot_2ndWeapon,
  bo2.eItemSlot_HWeapon,
  bo2.eItemSlot_RidePetWeapon
}
function check_item_Slot(item_slot)
  local info
  if item_slot == bo2.eItemSlot_RidePetWeapon then
    local ride = bo2.player:get_ridepet()
    if ride ~= nil then
      local box = ride:get_flag_int32(bo2.eRidePetFlagInt32_EquipPos) + bo2.eItemBox_RidePetBegin
      info = ui.item_of_coord(box, item_slot)
    end
  else
    info = ui.item_of_coord(bo2.eItemArray_InSlot, item_slot)
  end
  if info == nil then
    return nil
  end
  local member_self = ui.guild_get_self()
  local requires = info.excel.requires
  local cnt = requires.size
  for i = 1, cnt - 1, 2 do
    local kind = requires[i - 1]
    local val = requires[i]
    if kind == bo2.eItemReq_GuildTitle and (sys.check(member_self) ~= true or val > member_self.title) then
      return nil
    end
  end
  return info
end
local ctip_make_skill_cd = function(stk, excel, mode)
  local cdid = excel.cd_group
  if cdid == 0 then
    return
  end
  local cooldown = bo2.gv_cooldown_list:find(cdid)
  if cooldown == nil then
    return
  end
  stk:raw_push("<a:l>")
  ctip_push_unwrap(stk, ui.get_text("tool|cooldown_time"), SHARED("8f8fff"))
  stk:raw_push("<a:r>")
  if cooldown.mode == mode then
    if cooldown.time == 0 then
      local cd_time = math.floor(bo2.gv_cooldown_list:find(cdid).time)
      ctip_push_unwrap(stk, ui_widget.merge_mtf({time = cd_time}, ui.get_text("skill|daily_reset_time")), SHARED("00f813"))
    end
  else
    ctip_push_unwrap(stk, sys.format("%s", bo2.gv_cooldown_list:find(cdid).time), SHARED("00f813"))
  end
  local cd_dt = bo2.get_skill_cd_dt(excel.id)
  if cd_dt ~= 0 then
    if cd_dt > 0 then
      ctip_push_unwrap(stk, sys.format("+%s", cd_dt), SHARED("ff0000"))
    elseif cd_dt < 0 then
      ctip_push_unwrap(stk, sys.format("%s", cd_dt), SHARED("00ffff"))
    end
  end
  local vip_cd = bo2.gv_supermarket_vip_cd:find(cdid)
  if vip_cd ~= nil then
    local vip_level = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_RMBPrivilege)
    local vip_excel = bo2.gv_supermarket_vip:find(vip_level)
    local hours = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_RMBPrivilegeHours)
    if vip_excel ~= nil and hours > 0 then
      local idx = -1
      local x_vip_level = vip_cd.vip_level
      local x_reduce_time = vip_cd.reduce_time
      for t = 0, x_vip_level.size - 1 do
        local xv = x_vip_level[t]
        if xv > 0 and vip_level >= xv then
          idx = t
        end
      end
      if idx >= 0 then
        ctip_push_unwrap(stk, sys.format("%+d(V%d)", -vip_cd.reduce_time[idx], x_vip_level[idx]), SHARED("00ffff"))
      end
    end
  end
  if cooldown.mode ~= mode then
    ctip_push_unwrap(stk, ui.get_text("skill|second"), SHARED("8f8fff"))
  end
  stk:raw_push("\n")
end
function ctip_make_skill(stk, info, base_excel, append_data)
  if stk == nil then
    return
  end
  if info == nil and base_excel == nil then
    return
  end
  local function get_excel(num)
    if num > -100000 then
      return bo2.gv_skill_group:find(info.excel_id)
    elseif num < -100000 and num > -200000 then
      local excel
      local group_id = math.abs(num) - 100000
      for i = 0, bo2.gv_skill_data_swap.size - 1 do
        excel = bo2.gv_skill_data_swap:get(i)
        if excel and excel.group_id == group_id and excel.level == info.level then
          return excel
        end
      end
    elseif num < -200000 then
      local percentage = math.abs(num) - 200000
      return nil, percentage
    end
    return nil
  end
  local excel
  if info == nil then
    excel = base_excel
  else
    excel = bo2.gv_skill_group:find(info.excel_id)
  end
  if excel == nil then
    return
  end
  local damage_type
  stk:raw_push("<a:m>")
  stk:raw_push(sys.format("<lb:art,18,,%s|", "ffffff"))
  stk:push(sys.format("%s", excel.name))
  stk:raw_push(">")
  stk:raw_push("\n")
  local flag = false
  local weapon, effect, weapon_color
  if excel.xinfa and excel.xinfa ~= 0 then
    local type = bo2.gv_xinfa_list:find(excel.xinfa).type_id
    if type == bo2.eXinFaType_Etiquette then
      ctip_make_liyi(stk, excel)
      return
    end
  end
  if excel.weapon2nd_type == 0 then
    for i = 1, iCheckNum do
      local iSlot = tEquipType[i]
      if bo2.SkillNeedEquip(excel, iSlot) then
        flag = true
        if check_item_Slot(iSlot) ~= nil then
          weapon = sys.format("%s", ui.get_text(L("item|slot" .. iSlot)))
          weapon_color = "00ff00"
        else
          weapon = sys.format("%s", ui.get_text(L("item|slot" .. iSlot)))
          weapon_color = "ff0000"
        end
      end
    end
  else
    local type = excel.weapon2nd_type
    local type_excel = bo2.gv_item_type:find(type)
    local type_name
    if type_excel then
      type_name = type_excel.name
    end
    local item_info = ui.item_of_coord(bo2.eItemArray_InSlot, bo2.eItemSlot_2ndWeapon)
    if item_info == nil then
      weapon = sys.format("%s", type_name)
      weapon_color = "ff0000"
    else
      item_type = item_info.excel.type
      if item_type == type then
        weapon = sys.format("%s", type_name)
        weapon_color = "00ff00"
      else
        weapon = sys.format("%s", type_name)
        weapon_color = "ff0000"
      end
    end
    flag = true
  end
  if flag == false then
    weapon = ui.get_text("skill|none")
    weapon_color = "00ff00"
  end
  if excel.damage_type == 0 then
    damage_type = 0
    effect = sys.format(ui.get_text("skill|physical_effect"))
  elseif excel.damage_type == 1 then
    damage_type = 1
    effect = sys.format(ui.get_text("skill|magic_effect"))
  elseif excel.damage_type == 2 then
    local career = bo2.player:get_atb(bo2.eAtb_Cha_Profession)
    local excel = bo2.gv_profession_list:find(career)
    if excel then
      if excel.damage == 0 then
        damage_type = 0
        effect = sys.format(ui.get_text("skill|physical_effect"))
      elseif excel.damage == 1 then
        damage_type = 1
        effect = sys.format(ui.get_text("skill|magic_effect"))
      end
    end
  end
  stk:raw_push(sys.format("<skill_icon:%s,%s,%s,%s>", excel.id, weapon, weapon_color, effect))
  stk:raw_push(cs_tip_sep)
  if append_data ~= nil then
    stk:raw_push(append_data.text)
  end
  flag = false
  ctip_make_skill_cd(stk, excel)
  if excel.distance_min == 0 and excel.distance_max == 0 then
  else
    stk:raw_push("<a:l>")
    ctip_push_unwrap(stk, ui.get_text("skill|use_distance"), "8f8fff")
    stk:raw_push("<a:r>")
    if excel.distance_min ~= 0 then
      ctip_push_unwrap(stk, ui_widget.merge_mtf({
        dis = excel.distance_min / 10 - excel.distance_min / 10 % 0.1
      }, ui.get_text("skill|minimum_des")), SHARED("00f813"))
    end
    if excel.distance_max ~= 0 then
      ctip_push_unwrap(stk, ui_widget.merge_mtf({
        dis = excel.distance_max / 10 - excel.distance_max / 10 % 0.1
      }, ui.get_text("skill|maximum_des")), SHARED("00f813"))
    end
    stk:raw_push("\n")
  end
  if 0 >= excel.money then
  else
    stk:raw_push("<a:l>")
    ctip_push_unwrap(stk, ui.get_text("skill|tip_skill_need_money"), "8f8fff")
    stk:raw_push("<a:r>")
    stk:raw_push("<c+:#green>")
    local money_text = sys.format("<m:%d>", excel.money)
    if excel.money_type == 1 then
      money_text = sys.format("<bm:%d>", excel.money)
    end
    stk:raw_push(money_text)
    stk:raw_push("<c->")
    stk:raw_push("\n")
  end
  if 0 >= excel.item then
  else
    stk:raw_push("<a:l>")
    ctip_push_unwrap(stk, ui.get_text("skill|tip_skill_need_item"), "8f8fff")
    stk:raw_push("<a:r>")
    stk:raw_push("<c+:#green>")
    local item_text = sys.format("<i:%d>", excel.item) .. " x " .. excel.item_count
    stk:raw_push(item_text)
    stk:raw_push("<c->")
    stk:raw_push("\n")
  end
  local locked = false
  local xinfa = excel.xinfa
  local xinfa_level = ui.xinfa_find(xinfa)
  local xinfa_excel = bo2.gv_xinfa_list:find(xinfa)
  if info and info.level == 0 then
    locked = true
    stk:raw_push("<a:l>")
    ctip_push_unwrap(stk, ui.get_text("skill|skill_locked"), "ff00000")
    local req_level = bo2.gv_skill_level:find(info.excel_id).unlock
    stk:raw_push("\n")
    ctip_push_unwrap(stk, ui_widget.merge_mtf({
      xinfa_name = xinfa_excel.name,
      level = req_level
    }, ui.get_text("skill|skill_unlock_requirement")), "ff00000")
    stk:raw_push("\n")
  end
  if locked == true then
  else
    local skill_strength = bo2.get_skill_damage(excel.id)
    if 0 < excel.fracture_add then
      stk:raw_push("<a:l>")
      ctip_push_unwrap(stk, ui.get_text("skill|ft_damage"), "8f8fff")
      stk:raw_push("<a:r>")
      ctip_push_unwrap(stk, excel.fracture_add, "00f813")
      stk:raw_push("\n")
    end
    if skill_strength ~= 0 then
      stk:raw_push("<a:l>")
      ctip_push_unwrap(stk, ui.get_text("skill|skill_intensity"), "8f8fff")
      stk:raw_push("<a:r>")
      ctip_push_unwrap(stk, skill_strength, "00f813")
      stk:raw_push("\n")
    end
    stk:raw_push("<a:l>")
    local damage_text = ui.get_text("skill|damage_text")
    local damage_text1 = ui.get_text("skill|damage_text1")
    local damage_text2 = ui.get_text("skill|damage_text2")
    local type1 = ui.get_text("skill|damage_type_shanghai")
    local type2 = ui.get_text("skill|damage_type_zhiliao")
    local wuli = ui.get_text("skill|wuli")
    local fashu = ui.get_text("skill|fashu")
    if 0 < excel.weapon_damage then
      local v = sys.variant()
      v:set("equip_damage", excel.weapon_damage .. "%")
      ctip_push_text(stk, sys.mtf_merge(v, damage_text), SHARED("00f813"))
      stk:raw_push("\n")
    end
    if 0 < excel.dps_addrate then
      v = sys.variant()
      v:set("damage", excel.dps_addrate .. "%")
      if damage_type == 0 then
        v:set("type", wuli)
      elseif damage_type == 1 then
        v:set("type", fashu)
      end
      ctip_push_text(stk, sys.mtf_merge(v, damage_text2), SHARED("00f813"))
      stk:raw_push("\n")
    end
  end
  stk:raw_push(cs_tip_sep)
  if excel.desc.empty == false then
    stk:raw_push("<a:l>")
    stk:raw_push(excel.desc)
    stk:raw_push("\n")
  end
  if excel.desc1.empty == false then
    stk:raw_push("<a:l>")
    stk:raw_push(excel.desc1)
    stk:raw_push("\n")
  end
  if excel.tag.empty == false then
    stk:raw_push("<a:l>")
    stk:raw_push(excel.tag)
    stk:raw_push("\n")
  end
  if excel.desc.empty == false or excel.desc1.empty == false or excel.tag.empty == false then
    stk:raw_push(cs_tip_sep)
  end
  for idx = 0, bo2.gv_passive_skill.size - 1 do
    local pskill_line = bo2.gv_passive_skill:get(idx)
    if pskill_line.tgt_skill.size == 2 and pskill_line.tgt_skill[0] == excel.id and pskill_line.tgt_skill[1] == 1 then
      local pskill_info = ui.skill_find(pskill_line.id)
      if pskill_info ~= nil and 0 < pskill_info.level then
        ctip_push_text(stk, ui.get_text("skill|passive_effect") .. L(":"), "8f8fff")
        ctip_push_newline(stk)
        ctip_push_text(stk, pskill_line.desc, "00f813")
        ctip_push_sep(stk)
      end
    end
  end
  if locked == true then
  else
    local sep = false
    local dps_time = excel.dps_time
    if xinfa_level == 0 or xinfa_level == nil then
    else
      local xf_level0 = xinfa_level.level
      if xf_level0 == 0 then
        xf_level0 = 1
      end
      local vbase = bo2.gv_skill_level_data:get(0)["data" .. xf_level0]
      local skill_damage = excel.skill_damage
      if skill_damage < 0 then
        skill_damage = -(skill_damage + 100000)
      end
      if vbase == 0 or skill_damage == 0 or dps_time == 0 then
      else
        stk:raw_push("<a:l>")
        ctip_push_text(stk, ui.get_text("skill|additional_damage"), "8f8fff")
        stk:raw_push("<a:r>")
        local additional_value = math.floor(vbase / 10 * skill_damage / 100 * dps_time / 25)
        ui.log("additional_value" .. additional_value)
        ctip_push_text(stk, additional_value, "00f813")
        stk:raw_push("\n")
        sep = true
      end
    end
    if excel.hp == 0 or xinfa_level == 0 or xinfa_level == nil then
    else
      local vbase = bo2.gv_skill_level_data:get(2)["data" .. xinfa_level.level]
      local fAddRate = bo2.get_skill_hp_spend_rate(excel.id) + 1
      stk:raw_push("<a:l>")
      ctip_push_unwrap(stk, ui.get_text("skill|cost_hp"), "8f8fff")
      local hp = excel.hp
      stk:raw_push("<a:r>")
      if hp < -200000 then
        hp = -(hp + 200000) * fAddRate
        ctip_push_unwrap(stk, ui_widget.merge_mtf({life = hp}, ui.get_text("skill|current_max_life")), "00f813")
      elseif hp < -100000 then
        hp = -(hp + 100000) * fAddRate
        ctip_push_text(stk, math.floor(vbase * hp / 100), "00f813")
      elseif hp > 0 then
        ctip_push_text(stk, hp * fAddRate, "00f813")
      end
      stk:raw_push("\n")
      sep = true
    end
    if excel.st ~= 0 then
      local st_dt = bo2.get_skill_st_dt(excel.id)
      if st_dt == 0 then
        stk:raw_push("<a:l>")
        ctip_push_unwrap(stk, ui.get_text("skill|cost_st"), "8f8fff")
        stk:raw_push("<a:r>")
        ctip_push_unwrap(stk, excel.st, "00f813")
        stk:raw_push("\n")
      else
        local st = math.floor(excel.st * (1 + st_dt))
        if st ~= 0 then
          stk:raw_push("<a:l>")
          ctip_push_unwrap(stk, ui.get_text("skill|cost_st"), "8f8fff")
          stk:raw_push("<a:r>")
          ctip_push_unwrap(stk, st, "00f813")
          stk:raw_push("\n")
        end
      end
      sep = true
    end
    if excel.nq ~= 0 then
      stk:raw_push("<a:l>")
      ctip_push_unwrap(stk, ui.get_text("skill|cost_nq"), "8f8fff")
      stk:raw_push("<a:r>")
      ctip_push_unwrap(stk, math.floor(excel.nq / 10000 + 1.0E-6), "00f813")
      stk:raw_push("\n")
      sep = true
    end
    if excel.ft ~= 0 then
      stk:raw_push("<a:l>")
      ctip_push_unwrap(stk, ui.get_text("skill|cost_ft"), "8f8fff")
      stk:raw_push("<a:r>")
      ctip_push_unwrap(stk, excel.ft, "00f813")
      stk:raw_push("\n")
      sep = true
    end
    if sep == true then
      stk:raw_push(cs_tip_sep)
    end
  end
  stk:raw_push("<a:l>")
  local series_excel = bo2.gv_skill_series:find(excel.id)
  if series_excel then
    ctip_push_text(stk, ui.get_text("skill|can_edit_series"), SHARED("8f8fff"))
    stk:raw_push("\n")
  else
    ctip_push_text(stk, ui.get_text("skill|can_not_edit_series"), SHARED("8f8fff"))
    stk:raw_push("\n")
  end
  if series_excel then
    stk:raw_push("<a:l>")
    ctip_push_text(stk, ui.get_text("skill|series_phase"), SHARED("00f813"))
    if series_excel.all == 1 then
      ctip_push_text(stk, "1", SHARED("ffffff"))
    else
      local num = 0
      for i = 1, 10 do
        if series_excel["data" .. i].size ~= 0 then
          num = num + 1
        end
      end
      ctip_push_text(stk, num, SHARED("ffffff"))
    end
    stk:raw_push("\n")
  end
  return excel
end
function ctip_make_shortcut_skill(stk, info, base_excel)
  if stk == nil then
    return
  end
  if info == nil and base_excel == nil then
    return
  end
  local excel
  if info == nil then
    excel = base_excel
  else
    excel = bo2.gv_skill_group:find(info.excel_id)
  end
  local excel_id = excel.id
  local function get_excel(num)
    if num > -100000 then
      return bo2.gv_skill_group:find(info.excel_id)
    elseif num < -100000 and num > -200000 then
      local excel
      local group_id = math.abs(num) - 100000
      for i = 0, bo2.gv_skill_data_swap.size - 1 do
        excel = bo2.gv_skill_data_swap:get(i)
        if excel and excel.group_id == group_id and excel.level == info.level then
          return excel
        end
      end
    elseif num < -200000 then
      local percentage = math.abs(num) - 200000
      return nil, percentage
    end
    return nil
  end
  if excel == nil then
    return
  end
  if excel.xinfa and excel.xinfa ~= 0 then
    local type = bo2.gv_xinfa_list:find(excel.xinfa).type_id
    if type == bo2.eXinFaType_Etiquette then
      stk:raw_push("<a:m>")
      ctip_push_unwrap(stk, bo2.gv_xinfa_list:find(excel.xinfa).name, "00ffff")
      stk:raw_push("\n")
      ctip_push_unwrap(stk, excel.name, "00B050")
      return
    end
  end
  local damage_type
  stk:raw_push(sys.format("<lb:art,16,,%s|", "00B050"))
  stk:push(sys.format("%s", excel.name))
  stk:raw_push(">")
  stk:raw_push("<a:r>")
  if bo2.gv_xinfa_list:find(excel.xinfa) ~= nil then
    stk:raw_push("<a:r>")
    ctip_push_unwrap(stk, bo2.gv_xinfa_list:find(excel.xinfa).name, "8f8fff")
  end
  stk:raw_push("\n")
  local skill_strength = bo2.get_skill_damage(excel_id)
  if skill_strength ~= 0 then
    stk:raw_push("<a:r>")
    if excel.damage_type == 0 then
      damage_type = 0
      ctip_push_text(stk, ui.get_text("skill|physical_damage"), SHARED("A59E1B"))
    elseif excel.damage_type == 1 then
      damage_type = 1
      ctip_push_text(stk, ui.get_text("skill|magic_damage"), SHARED("A59E1B"))
    elseif excel.damage_type == 2 then
      local career = bo2.player:get_atb(bo2.eAtb_Cha_Profession)
      local excel = bo2.gv_profession_list:find(career)
      if excel then
        if excel.damage == 0 then
          damage_type = 0
          ctip_push_text(stk, ui.get_text("skill|physical_damage"), SHARED("A59E1B"))
        elseif excel.damage == 1 then
          damage_type = 1
          ctip_push_text(stk, ui.get_text("skill|magic_damage"), SHARED("A59E1B"))
        end
      end
    end
    stk:raw_push("\n")
  end
  stk:raw_push("<a:l>")
  local flag = false
  local weapon, weapon_color
  ctip_push_unwrap(stk, ui.get_text("skill|equip_requirement"), "8f8fff")
  stk:raw_push("<a:r>")
  if excel.weapon2nd_type == 0 then
    for i = 1, iCheckNum do
      local iSlot = tEquipType[i]
      if bo2.SkillNeedEquip(excel, iSlot) then
        flag = true
        if check_item_Slot(iSlot) ~= nil then
          weapon = sys.format("%s", ui.get_text(L("item|slot" .. iSlot)))
          weapon_color = "00ff00"
        else
          weapon = sys.format("%s", ui.get_text(L("item|slot" .. iSlot)))
          weapon_color = "ff0000"
        end
      end
    end
  else
    local type = excel.weapon2nd_type
    local type_excel = bo2.gv_item_type:find(type)
    local type_name
    if type_excel then
      type_name = type_excel.name
    end
    local item_info
    if type >= bo2.eItemType_SecondWeaponBegin and type <= bo2.eItemType_SecondWeaponEnd then
      item_info = check_item_Slot(bo2.eItemSlot_2ndWeapon)
    elseif type >= bo2.eItemtype_UseHWeapon and type <= bo2.eItemType_UseHWeaponEnd then
      item_info = check_item_Slot(bo2.eItemSlot_HWeapon)
    else
      return
    end
    if item_info == nil then
      weapon = sys.format("%s", type_name)
      weapon_color = "ff0000"
    else
      item_type = item_info.excel.type
      if item_type == type then
        weapon = sys.format("%s", type_name)
        weapon_color = "00ff00"
      else
        weapon = sys.format("%s", type_name)
        weapon_color = "ff0000"
      end
    end
    flag = true
  end
  if flag == false then
    ctip_push_unwrap(stk, ui.get_text("skill|none"), "00ff00")
  else
    ctip_push_unwrap(stk, sys.format("%s", weapon), weapon_color)
  end
  flag = false
  stk:raw_push("\n")
  if excel.distance_min == 0 and excel.distance_max == 0 then
  else
    stk:raw_push("<a:l>")
    ctip_push_unwrap(stk, ui.get_text("skill|use_distance"), "8f8fff")
    stk:raw_push("<a:r>")
    if excel.distance_min ~= 0 then
      ctip_push_unwrap(stk, ui_widget.merge_mtf({
        dis = excel.distance_min / 10 - excel.distance_min / 10 % 0.1
      }, ui.get_text("skill|minimum_des")), SHARED("00f813"))
    end
    if excel.distance_max ~= 0 then
      ctip_push_unwrap(stk, ui_widget.merge_mtf({
        dis = excel.distance_max / 10 - excel.distance_max / 10 % 0.1
      }, ui.get_text("skill|maximum_des")), SHARED("00f813"))
    end
    stk:raw_push("\n")
  end
  ctip_make_skill_cd(stk, excel, 2)
  if 0 >= excel.money then
  else
    stk:raw_push("<a:l>")
    ctip_push_unwrap(stk, ui.get_text("skill|tip_skill_need_money"), "8f8fff")
    stk:raw_push("<a:r>")
    stk:raw_push("<c+:#green>")
    local money_text = sys.format("<m:%d>", excel.money)
    if excel.money_type == 1 then
      money_text = sys.format("<bm:%d>", excel.money)
    end
    stk:raw_push(money_text)
    stk:raw_push("<c->")
    stk:raw_push("\n")
  end
  if 0 >= excel.item then
  else
    stk:raw_push("<a:l>")
    ctip_push_unwrap(stk, ui.get_text("skill|tip_skill_need_item"), "8f8fff")
    stk:raw_push("<a:r>")
    stk:raw_push("<c+:#green>")
    local item_text = sys.format("<i:%d>", excel.item) .. " x " .. excel.item_count
    stk:raw_push(item_text)
    stk:raw_push("<c->")
    stk:raw_push("\n")
  end
  local locked = false
  local xinfa = excel.xinfa
  local xinfa_level = ui.xinfa_find(xinfa)
  local dps_time = excel.dps_time
  if excel.hp == 0 or xinfa_level == 0 or xinfa_level == nil then
  else
    local vbase = bo2.gv_skill_level_data:get(2)["data" .. xinfa_level.level]
    local fAddRate = bo2.get_skill_hp_spend_rate(excel_id) + 1
    stk:raw_push("<a:l>")
    ctip_push_unwrap(stk, ui.get_text("skill|cost_hp"), "8f8fff")
    local hp = excel.hp
    stk:raw_push("<a:r>")
    if hp < -200000 then
      hp = -(hp + 200000) * fAddRate
      ctip_push_unwrap(stk, ui_widget.merge_mtf({life = hp}, ui.get_text("skill|current_max_life")), "00f813")
    elseif hp < -100000 then
      hp = -(hp + 100000) * fAddRate
      ctip_push_text(stk, math.floor(vbase * hp / 100), "00f813")
    elseif hp > 0 then
      ctip_push_text(stk, hp * fAddRate, "00f813")
    end
    stk:raw_push("\n")
  end
  if excel.st ~= 0 then
    local st_dt = bo2.get_skill_st_dt(excel.id)
    if st_dt == 0 then
      stk:raw_push("<a:l>")
      ctip_push_unwrap(stk, ui.get_text("skill|cost_st"), "8f8fff")
      stk:raw_push("<a:r>")
      ctip_push_unwrap(stk, excel.st, "00f813")
      stk:raw_push("\n")
    else
      local st = math.floor(excel.st * (1 + st_dt))
      if st ~= 0 then
        stk:raw_push("<a:l>")
        ctip_push_unwrap(stk, ui.get_text("skill|cost_st"), "8f8fff")
        stk:raw_push("<a:r>")
        ctip_push_unwrap(stk, st, "00f813")
        stk:raw_push("\n")
      end
    end
  end
  if excel.nq ~= 0 then
    stk:raw_push("<a:l>")
    ctip_push_unwrap(stk, ui.get_text("skill|cost_nq"), "8f8fff")
    stk:raw_push("<a:r>")
    ctip_push_unwrap(stk, math.floor(excel.nq / 10000 + 1.0E-6), "00f813")
    stk:raw_push("\n")
  end
  if excel.ft ~= 0 then
    stk:raw_push("<a:l>")
    ctip_push_unwrap(stk, ui.get_text("skill|cost_ft"), "8f8fff")
    stk:raw_push("<a:r>")
    ctip_push_unwrap(stk, excel.ft, "00f813")
    stk:raw_push("\n")
  end
  if 0 < excel.fracture_add then
    stk:raw_push("<a:l>")
    ctip_push_unwrap(stk, ui.get_text("skill|ft_damage"), "8f8fff")
    stk:raw_push("<a:r>")
    ctip_push_unwrap(stk, excel.fracture_add, "00f813")
    stk:raw_push("\n")
  end
  if skill_strength ~= 0 then
    stk:raw_push("<a:l>")
    ctip_push_unwrap(stk, ui.get_text("skill|skill_intensity"), "8f8fff")
    stk:raw_push("<a:r>")
    ctip_push_unwrap(stk, skill_strength, "00f813")
    stk:raw_push("\n")
  end
  if excel.desc.empty == false then
    stk:raw_push("<a:l>")
    stk:raw_push(excel.desc)
    stk:raw_push("\n")
  end
  if excel.tag.empty == false then
    stk:raw_push("<a:l>")
    stk:raw_push(excel.tag)
    stk:raw_push("\n")
  end
  for idx = 0, bo2.gv_passive_skill.size - 1 do
    local pskill_line = bo2.gv_passive_skill:get(idx)
    if pskill_line.tgt_skill.size == 2 and pskill_line.tgt_skill[0] == excel.id and pskill_line.tgt_skill[1] == 1 then
      local pskill_info = ui.skill_find(pskill_line.id)
      if pskill_info ~= nil and 0 < pskill_info.level then
        ctip_push_text(stk, ui.get_text("skill|passive_effect") .. L(":"), "8f8fff")
        ctip_push_newline(stk)
        ctip_push_text(stk, pskill_line.desc, "00f813")
        ctip_push_newline(stk)
      end
    end
  end
  if sys.check(info) and info.cooldown ~= 0 then
    stk:raw_push("\n")
    stk:raw_push("<a:l>")
    local time_t
    local hour = math.floor(info.cooldown / 3600)
    local minute = math.floor(math.mod(info.cooldown, 3600) / 60)
    local second = math.mod(math.mod(info.cooldown, 3600), 60)
    if hour ~= 0 then
      time_t = ui_widget.merge_mtf({left_h = hour}, ui.get_text("skill|tip_hour"))
    end
    if minute ~= 0 then
      time_t = time_t .. ui_widget.merge_mtf({left_m = minute}, ui.get_text("skill|tip_minute"))
    end
    time_t = time_t .. ui_widget.merge_mtf({left_s = second}, ui.get_text("skill|tip_second"))
    ctip_push_text(stk, ui_widget.merge_mtf({left_time = time_t}, ui.get_text("skill|tip_left_cd_time")), SHARED("ff0000"))
  end
end
function ctip_make_passive_skill(stk, info, base_excel, append_data)
  if info == nil and base_excel == nil then
    return
  end
  local excel
  if info ~= nil then
    excel = bo2.gv_passive_skill:find(info.excel_id)
  else
    excel = base_excel
  end
  ctip_push_unwrap(stk, excel.name, "00B050")
  if sys.check(info) then
    stk:raw_push("<a:r>")
    ctip_push_unwrap(stk, ui.get_text("skill|level"), "FFFFFF")
    ctip_push_unwrap(stk, info.level, "00ffff")
  end
  stk:raw_push("\n")
  stk:raw_push("<a:l>")
  ctip_push_unwrap(stk, ui.get_text("skill|passive_skill"), "EE2299")
  if sys.check(info) and info.level ~= 0 then
    stk:raw_push("<a:l>")
    local slevel = "level" .. info.level
    if bo2.gv_xinfa_list:find(excel.xinfa) ~= nil then
      stk:raw_push("<a:r>")
      if excel[slevel].size ~= 0 then
        ctip_push_unwrap(stk, ui.get_text("skill|juese"), "00ffff")
        ctip_push_unwrap(stk, excel[slevel][0], "00ff00")
        ctip_push_unwrap(stk, ui.get_text("skill|cur_level"), "00ffff")
      else
        ctip_push_unwrap(stk, ui.get_text("skill|top_level"), "00ffff")
      end
      stk:raw_push("\n")
    end
    stk:raw_push("<a:l>")
    for i = 1, excel[slevel].size do
      local mb_trait_list = bo2.gv_trait_list:find(excel[slevel][i])
      if mb_trait_list then
        ctip_push_text(stk, ctip_trait_text(mb_trait_list.id), SHARED("88aaaa"))
        stk:raw_push("\n")
      end
    end
    local slevel = "level" .. info.level + 1
    if bo2.gv_xinfa_list:find(excel.xinfa) ~= nil then
      ctip_push_unwrap(stk, ui.get_text("skill|next_level"), "ff0000")
      stk:raw_push("<a:r>")
      if excel[slevel].size ~= 0 then
        ctip_push_unwrap(stk, ui.get_text("skill|juese"), "00ffff")
        ctip_push_unwrap(stk, excel[slevel][0], "ff0000")
        ctip_push_unwrap(stk, ui.get_text("skill|cur_level"), "00ffff")
      else
        ctip_push_unwrap(stk, ui.get_text("skill|top_level"), "00ffff")
      end
    end
    stk:raw_push("\n")
    stk:raw_push("<a:l>")
    for i = 1, excel[slevel].size do
      local mb_trait_list = bo2.gv_trait_list:find(excel[slevel][i])
      if mb_trait_list then
        ctip_push_text(stk, ctip_trait_text(mb_trait_list.id), SHARED("88aaaa"))
        stk:raw_push("\n")
      end
    end
    stk:raw_push("<a:l>")
    if excel.desc ~= 0 then
      ctip_push_text(stk, excel.desc, SHARED("00ff99"))
    else
      ctip_push_text(stk, ui.get_text("skill|none"), SHARED("00ff99"))
    end
    for idx = 0, bo2.gv_passive_skill.size - 1 do
      local pskill_line = bo2.gv_passive_skill:get(idx)
      if pskill_line.tgt_skill.size == 2 and pskill_line.tgt_skill[0] == info.excel_id and pskill_line.tgt_skill[1] == 1 then
        local pskill_info = ui.skill_find(pskill_line.id)
        if pskill_info ~= nil and pskill_info.level > 0 then
          ctip_push_newline(stk)
          ctip_push_text(stk, ui.get_text("skill|passive_effect") .. L(":"), "8f8fff")
          ctip_push_newline(stk)
          ctip_push_text(stk, pskill_line.desc, "00f813")
        end
      end
    end
  else
    if sys.check(append_data) then
      stk:raw_push(append_data.text)
    else
      stk:raw_push("<a:l>")
      ctip_push_unwrap(stk, ui.get_text("skill|not_actived"), "ff0000")
      stk:raw_push("\n")
      local slevel = "level1"
      if bo2.gv_xinfa_list:find(excel.xinfa) ~= nil then
        if excel[slevel].size ~= 0 then
          ctip_push_unwrap(stk, ui.get_text("skill|require"), "00ffff")
          ctip_push_unwrap(stk, bo2.gv_xinfa_list:find(excel.xinfa).name, "00ffff")
          ctip_push_unwrap(stk, excel[slevel][0], "ff0000")
          ctip_push_unwrap(stk, ui.get_text("skill|cur_level"), "00ffff")
        else
          ctip_push_unwrap(stk, ui.get_text("skill|top_level"), "00ffff")
        end
      end
    end
    stk:raw_push("\n")
    stk:raw_push("<a:l>")
    if excel.desc ~= 0 then
      ctip_push_text(stk, excel.desc, SHARED("00ff99"))
    else
      ctip_push_text(stk, ui.get_text("skill|none"), SHARED("00ff99"))
    end
  end
end
function ctip_make_master_passive_skill(stk, excel, skill_info)
  if excel == nil then
    return
  end
  ctip_push_unwrap(stk, excel.name, "00B050")
  if skill_info ~= nil then
    stk:raw_push("<a:r>")
    ctip_push_unwrap(stk, ui.get_text("skill|level"), "FFFFFF")
    ctip_push_unwrap(stk, skill_info.level, "00ffff")
  end
  stk:raw_push("\n")
  stk:raw_push("<a:l>")
  ctip_push_unwrap(stk, ui.get_text("skill|passive_skill"), "EE2299")
  stk:raw_push("\n")
  local xinfa_info = ui.xinfa_find(excel.xinfa)
  local unlock_lv = excel.level1[0]
  if unlock_lv > xinfa_info.mas_level then
    local arg = sys.variant()
    arg:set("level", unlock_lv)
    local txt_lv = sys.mtf_merge(arg, ui.get_text("skill|xinfa_mas_unlock_desc"))
    ctip_push_unwrap(stk, txt_lv, "FF0000")
    stk:raw_push("\n")
  end
  if skill_info == nil then
    stk:raw_push("<a:l>")
    local cons_pts = excel.extra[0]
    local txt_cons_pts = ui_widget.merge_mtf({num = cons_pts}, ui.get_text("skill|mas_skill_req_pts"))
    ctip_push_unwrap(stk, txt_cons_pts, "ff0000")
    stk:raw_push("\n")
  end
  stk:raw_push("<a:l>")
  if excel.desc ~= 0 then
    ctip_push_text(stk, excel.desc, SHARED("00ff99"))
    local trait_mod_id = excel.level1[1]
    local trait_mod_line = bo2.gv_trait_list:find(trait_mod_id)
    if trait_mod_line.tp == 1 then
      local skill_trait_line = bo2.gv_skill_trait_list:find(trait_mod_line.modify_id)
      if skill_trait_line.dmg_trait_id ~= 0 then
        local num_dmg = bo2.player:get_atb(skill_trait_line.dmg_trait_id) * skill_trait_line.dmg_trait_rate
        local txt_dmg = ui_widget.merge_mtf({num = num_dmg}, ui.get_text("skill|cur_add_num"))
        ctip_push_newline(stk)
        ctip_push_text(stk, txt_dmg, "00f813")
      end
    end
  else
    ctip_push_text(stk, ui.get_text("skill|none"), SHARED("00ff99"))
  end
end
function ctip_make_lianzhao(stk, excel)
  if ui_lianzhao.lianzhao[excel.id] then
    stk:raw_push(ui_lianzhao.lianzhao[excel.id].desc)
  else
    ctip_push_unwrap(stk, ui_widget.merge_mtf({
      id = excel.id - 5
    }, ui.get_text("skill|system_series_skill")), "ffffff")
  end
end
function ctip_make_wuxing(stk)
  local wuxing = bo2.player:get_atb(bo2.eAtb_Cha_Savvy)
  local level = bo2.player:get_atb(bo2.eAtb_Level)
  stk:raw_push(ui_widget.merge_mtf({
    level = wuxing + level
  }, ui.get_text("skill|cur_xinfa_level")))
end
function ctip_make_xinfa(stk, info)
  local excel = bo2.gv_xinfa_list:find(info.excel_id)
  if excel == nil then
    return
  end
  local mb_levelup = bo2.gv_xinfa_levelup_spend:find(info.level + 1)
  stk:raw_push(sys.format("<xinfa_icon:%s,%s>", excel.id, excel.name))
  ctip_push_sep(stk)
  ctip_push_text(stk, L("Lv.") .. info.level)
  local blevelup_text, blevelup_color
  if not mb_levelup then
    blevelup_text = ui.get_text("skill|top_level")
    blevelup_color = "ff0000"
  else
    blevelup_text = ui.get_text("skill|levelup_enable")
    blevelup_color = "00ff00"
  end
  ctip_push_text(stk, blevelup_text, blevelup_color, cs_tip_a_add_r)
  ctip_push_sep(stk)
  local desc_text = bo2.gv_text:find(excel.desc_id).text
  ctip_push_text(stk, desc_text)
  ctip_push_sep(stk)
  local modify_text
  for i = 0, info.excel.mdf_chg.size / 2 do
    local id = info.excel.mdf_chg[i * 2]
    local modify = bo2.gv_modify_player:find(id)
    if modify then
      local iDt = info.excel.mdf_chg[i * 2 + 1] * info.level
      local text = ui_tool.ctip_trait_text_ex(id, iDt)
      if i == 0 then
        modify_text = modify_text .. text
        ctip_push_text(stk, modify_text, cs_tip_color_green)
      else
        ctip_push_newline(stk)
        ctip_push_text(stk, text, cs_tip_color_green)
      end
    end
  end
  local req_exp, req_money
  if not mb_levelup then
    req_exp = ui.get_text("skill|top_level")
    req_money = 0
  else
    local exp_id = info.excel.exp_id
    local data1 = "data" .. exp_id * 2 - 1
    local data2 = "data" .. exp_id * 2
    req_exp = mb_levelup[data1]
    req_money = mb_levelup[data2]
  end
  ctip_push_sep(stk)
  ctip_push_text(stk, ui.get_text("skill|require_experience"))
  ctip_push_text(stk, req_exp, "00ff00", cs_tip_a_add_r)
  ctip_push_newline(stk)
  ctip_push_text(stk, ui.get_text("skill|expense_experience"))
  stk:raw_push(cs_tip_a_add_r)
  stk:raw_format("<bm:%d>", req_money)
  stk:raw_push(cs_tip_a_sub)
  local cur_exp = bo2.player:get_atb(bo2.eAtb_Cha_Exp)
  ctip_push_sep(stk)
  ctip_push_text(stk, ui.get_text("skill|current_experience"))
  ctip_push_text(stk, cur_exp, "00ff00", cs_tip_a_add_r)
  ctip_push_newline(stk)
  ctip_push_text(stk, ui.get_text("skill|current_bind_money"))
  stk:raw_push(cs_tip_a_add_r)
  stk:raw_format("<bm:%d>", bo2.player:get_flag_int32(bo2.eFlagInt32_BoundedMoney))
  stk:raw_push(cs_tip_a_sub)
end
function ctip_make_xinfa_livingskill(stk, info)
  local excel = bo2.gv_xinfa_list:find(info.excel_id)
  if excel == nil then
    return
  end
  local mb_levelup = bo2.gv_xinfa_levelup_spend:find(info.level + 1)
  stk:raw_push(sys.format("<xinfa_icon:%s,%s>", excel.id, excel.name))
  ctip_push_sep(stk)
  ctip_push_text(stk, L("Lv.") .. info.level)
  local blevelup_text, blevelup_color
  if not mb_levelup or info.level >= excel.level_max then
    blevelup_text = ui.get_text("skill|top_level")
    blevelup_color = "ff0000"
  else
    blevelup_text = ui.get_text("skill|levelup_enable")
    blevelup_color = "00ff00"
  end
  ctip_push_text(stk, blevelup_text, blevelup_color, cs_tip_a_add_r)
  ctip_push_sep(stk)
  local desc_text = bo2.gv_text:find(excel.desc_id).text
  ctip_push_text(stk, desc_text)
  local req_exp, req_money
  if not mb_levelup then
    req_exp = ui.get_text("skill|top_level")
    req_money = 0
  else
    local exp_id = info.excel.exp_id
    local data1 = "data" .. exp_id * 2 - 1
    local data2 = "data" .. exp_id * 2
    req_exp = mb_levelup[data1]
    req_money = mb_levelup[data2]
  end
  ctip_push_sep(stk)
  ctip_push_text(stk, ui.get_text("skill|tip_xinfa_livingskill_exp"))
  ctip_push_text(stk, req_exp, "00ff00", cs_tip_a_add_r)
  ctip_push_newline(stk)
  ctip_push_text(stk, ui.get_text("skill|tip_xinfa_livingskill_cost"))
  stk:raw_push(cs_tip_a_add_r)
  local money_type = tonumber(tostring(bo2.gv_define:find(1266).value))
  if money_type == bo2.eCurrency_CirculatedMoney then
    stk:raw_format("<m:%d>", req_money)
  else
    stk:raw_format("<bm:%d>", req_money)
  end
  stk:raw_push(cs_tip_a_sub)
end
