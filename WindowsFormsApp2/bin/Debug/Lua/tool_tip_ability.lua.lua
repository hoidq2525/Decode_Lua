local find_ability = function(pre_group, pre_level)
  local size = bo2.gv_pet_ability.size
  for i = 0, size - 1 do
    local ability = bo2.gv_pet_ability:get(i)
    if ability.group == pre_group and ability.level == pre_level then
      return ability
    end
  end
  return nil
end
local function ctip_make_info(stk, ability)
  local modify1 = bo2.gv_modify_pet:find(ability.atb1)
  if modify1 ~= nil then
    local name = modify1.name
    local value = ability.param1
    local text
    if ability.cent1 == 1 then
      text = sys.format(" %s +%d", name, value)
      text = text .. "%"
    else
      text = sys.format(" %s +%d", name, value)
    end
    stk:push(text)
    stk:push("\n")
  end
  local modify2 = bo2.gv_modify_pet:find(ability.atb2)
  if modify2 ~= nil then
    local name = modify2.name
    local value = ability.param2
    local text
    if ability.cent2 == 1 then
      text = sys.format(" %s +%d", name, value)
      text = text .. "%"
    else
      text = sys.format(" %s +%d", name, value)
    end
    stk:push(text)
    stk:push("\n")
  end
  local modify3 = bo2.gv_modify_pet:find(ability.atb3)
  if modify3 ~= nil then
    local name = modify3.name
    local value = ability.param3
    local text
    if ability.cent3 == 1 then
      text = sys.format(" %s +%d", name, value)
      text = text .. "%"
    else
      text = sys.format(" %s +%d", name, value)
    end
    stk:push(text)
    stk:push("\n")
  end
  local modify4 = bo2.gv_modify_pet:find(ability.atb4)
  if modify4 ~= nil then
    local name = modify4.name
    local value = ability.param4
    local text
    if ability.cent4 == 1 then
      text = sys.format(" %s +%d", name, value)
      text = text .. "%"
    else
      text = sys.format(" %s +%d", name, value)
    end
    stk:push(text)
    stk:push("\n")
  end
  local modify5 = bo2.gv_modify_pet:find(ability.atb5)
  if modify5 ~= nil then
    local name = modify5.name
    local value = ability.param5
    local text
    if ability.cent5 == 1 then
      text = sys.format(" %s +%d", name, value)
      text = text .. "%"
    else
      text = sys.format(" %s +%d", name, value)
    end
    stk:push(text)
    stk:push("\n")
  end
  ctip_push_sep(stk)
  local size = ability.pre_group.size
  for i = 0, size - 1 do
    local pre_ability = find_ability(ability.pre_group[i], ability.pre_level[i])
    if pre_ability ~= nil then
      local text = ui_widget.merge_mtf({
        name = pre_ability.name,
        level = pre_ability.level
      }, ui.get_text("tool|tip_ability_learned"))
      stk:push(text)
      stk:push("\n")
    end
  end
  if 0 < ability.pet_level then
    local text = sys.format("%s%d\n", ui.get_text("pet|pre_pet_level"), ability.pet_level)
    stk:push(text)
  end
  if 0 < ability.vit_growth then
    local text = sys.format("%s%d\n", ui.get_text("pet|pre_vit_growth"), ability.vit_growth)
    stk:push(text)
  end
  if 0 < ability.str_growth then
    local text = sys.format("%s%d\n", ui.get_text("pet|pre_str_growth"), ability.str_growth)
    stk:push(text)
  end
  if 0 < ability.int_growth then
    local text = sys.format("%s%d\n", ui.get_text("pet|pre_int_growth"), ability.int_growth)
    stk:push(text)
  end
  if 0 < ability.ske_growth then
    local text = sys.format("%s%d\n", ui.get_text("pet|pre_ske_growth"), ability.ske_growth)
    stk:push(text)
  end
  if 0 < ability.agi_growth then
    local text = sys.format("%s%d\n", ui.get_text("pet|pre_agi_growth"), ability.agi_growth)
    stk:push(text)
  end
  ctip_push_sep(stk)
  local remark = ability.remark
  stk:push(text)
end
local ctip_make_icon = function(stk, excel)
  local uri = "$gui/icon/skill/cmn/001.png"
  stk:push(ui_widget.merge_mtf({
    name = excel.name,
    level = excel.level
  }, ui.get_text("tool|tip_ability_icon")))
  ctip_push_sep(stk)
end
function ctip_make_ability(tip, excel)
  local stk = sys.mtf_stack()
  ctip_make_icon(stk, excel)
  ctip_make_info(stk, excel)
  ui_widget.tip_make_view(tip.view, stk.text)
end
