function ctip_make_pet_skill(stk, excel_id)
  local excel = bo2.gv_skill_group:find(excel_id)
  if excel == nil then
    return
  end
  local function get_excel(num)
    if num > -100000 then
      return bo2.gv_skill_group:find(excel_id)
    elseif num < -100000 then
      local excel
      local group_id = math.abs(num) - 100000
      for i = 0, bo2.gv_skill_data_swap.size - 1 do
        excel = bo2.gv_skill_data_swap:get(i)
        return excel
      end
    end
    return nil
  end
  ctip_push_unwrap(stk, excel.name, "00B050")
  if excel.distance_min ~= 0 or excel.distance_max ~= 0 then
    stk:raw_push("\n")
  end
  if excel.distance_min ~= 0 then
    stk:raw_push("<a:l>")
    ctip_push_unwrap(stk, ui.get_text("skill|minimum_distance"), "FFFFFF")
    ctip_push_unwrap(stk, excel.distance_min, "FFFFFF")
  end
  if excel.distance_max ~= 0 then
    stk:raw_push("<a:r>")
    ctip_push_unwrap(stk, ui.get_text("skill|maximum_distance"), "FFFFFF")
    ctip_push_unwrap(stk, excel.distance_max, "FFFFFF")
  end
  if excel.desc ~= nil then
    stk:raw_push("\n")
    stk:raw_push("<a:l>")
    ctip_push_text(stk, excel.desc, "FFFFFF")
    stk:raw_push("\n")
  end
  stk:raw_push("<a:l>")
  if excel.damage_type == 0 then
    ctip_push_text(stk, ui.get_text("skill|wuli"), SHARED("ffffff"))
  elseif excel.damage_type == 1 then
    ctip_push_text(stk, ui.get_text("skill|fashu"), SHARED("ffffff"))
  elseif excel.damage_type == 2 then
  end
  stk:raw_push("\n")
  local damage_text = ui.get_text("skill|damage_text")
  local damage_text1 = ui.get_text("skill|damage_text1")
  local damage_text2 = ui.get_text("skill|damage_text2")
  local type1 = ui.get_text("skill|damage_type_shanghai")
  local type2 = ui.get_text("skill|damage_type_zhiliao")
  local wuli = ui.get_text("skill|wuli")
  local fashu = ui.get_text("skill|fashu")
  local comma_flag = false
  if 0 < excel.weapon_damage then
    local v = sys.variant()
    v:set("equip_damage", excel.weapon_damage .. "%")
    ctip_push_text(stk, sys.mtf_merge(v, damage_text), SHARED("00B050"))
    comma_flag = true
  end
  if 0 < get_excel(excel.skill_damage).skill_damage then
    local v = sys.variant()
    v:set("point", get_excel(excel.skill_damage).skill_damage)
    v:set("type", type1)
    if comma_flag == true then
      stk:raw_push(",")
    end
    ctip_push_text(stk, sys.mtf_merge(v, damage_text1), SHARED("00B050"))
    comma_flag = true
  elseif 0 > get_excel(excel.skill_damage).skill_damage then
    local v = sys.variant()
    v:set("point", math.abs(get_excel(excel.skill_damage).skill_damage))
    v:set("type", type2)
    if comma_flag == true then
      stk:raw_push(",")
    end
    ctip_push_text(stk, sys.mtf_merge(v, damage_text1), SHARED("00B050"))
    comma_flag = true
  end
  if 0 < excel.dps_addrate then
    local v = sys.variant()
    v:set("damage", excel.dps_addrate .. "%")
    if damage_type == 0 then
      v:set("type", wuli)
    elseif damage_type == 1 then
      v:set("type", fashu)
    end
    if comma_flag == true then
      stk:raw_push(",")
    end
    ctip_push_text(stk, sys.mtf_merge(v, damage_text2), SHARED("00B050"))
    comma_flag = false
  end
  local passive_skill = bo2.gv_pet_passive_skill:find(excel.id)
  if passive_skill ~= nil then
    stk:raw_push("<a:l>")
    stk:raw_push("\n")
    local txt
    local txt_target = ui.get_text("pet|pet_target_text")
    local v = sys.variant()
    if passive_skill.target_kind == bo2.ePet_TargetKind_Self then
      v:set("name", ui.get_text("skill|pet"))
      txt = sys.mtf_merge(v, txt_target)
    elseif passive_skill.target_kind == bo2.ePet_TargetKind_Owner then
      v:set("name", ui.get_text("skill|owner"))
      txt = sys.mtf_merge(v, txt_target)
    end
    ctip_push_unwrap(stk, txt, SHARED("00B050"))
    local s1 = get_excel(excel.data_state1)
    if s1 ~= nil then
      ctip_make_pet_state(stk, s1.data_state1)
      ctip_make_pet_state(stk, s1.data_state2)
      ctip_make_pet_state(stk, s1.data_state3)
    end
    local s2 = get_excel(excel.data_state2)
    if s2 ~= nil then
      ctip_make_pet_state(stk, s2.data_state1)
      ctip_make_pet_state(stk, s2.data_state2)
      ctip_make_pet_state(stk, s2.data_state3)
    end
    local s3 = get_excel(excel.data_state3)
    if s3 ~= nil then
      ctip_make_pet_state(stk, s3.data_state1)
      ctip_make_pet_state(stk, s3.data_state2)
      ctip_make_pet_state(stk, s3.data_state3)
    end
  end
end
function ctip_make_pet_state(stk, excel_id)
  local excel = bo2.gv_state_container:find(excel_id)
  if excel == nil then
    return
  end
  ctip_push_text(stk, excel.desc, SHARED("FFFFFF"))
end
function ctip_make_pet_ability(stk, excel_id)
  local excel = bo2.gv_pet_ability:find(excel_id)
  if excel == nil then
    return
  end
  stk:raw_push("<a:l>")
  ctip_push_unwrap(stk, excel.name, "00B050")
  stk:raw_push("<a:r>")
  local txt_level = sys.format("        %s:%d ", ui.get_text("common|level"), excel.level)
  ctip_push_unwrap(stk, txt_level, "00B050")
  stk:raw_push("<a:l>")
  local ability_desc = bo2.gv_text:find(excel.intro_txt)
  if ability_desc ~= nil then
    stk:raw_push("\n")
    local text = ability_desc.text
    local v = sys.variant()
    if excel.atb1 > 0 then
      v:set("atb1", excel.param1)
    end
    if 0 < excel.atb2 then
      v:set("atb2", excel.param2)
    end
    if 0 < excel.atb3 then
      v:set("atb3", excel.param3)
    end
    if 0 < excel.atb4 then
      v:set("atb4", excel.param4)
    end
    if 0 < excel.atb5 then
      v:set("atb5", excel.param5)
    end
    local txt_t = sys.mtf_merge(v, text)
    ctip_push_text(stk, txt_t, "FFFFFF")
  end
end
