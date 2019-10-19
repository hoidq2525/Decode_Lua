g_pet_only_id = nil
g_excel_id = nil
function update_pet_info(pet)
  local w = ui.find_control("$frame:pet_genius")
  if w.visible == false then
    return
  end
  if pet.only_id ~= g_pet_only_id then
    return
  end
  set_select(g_pet_only_id)
  set_money()
  set_ability_point()
  set_title(g_pet_only_id)
end
function set_money()
  local excel = bo2.gv_pet_money_consume:find(bo2.ePet_Money_LearnAbility)
  if excel == nil then
    return
  end
  w_req_money.money = excel.money
end
function set_title(pet_only_id)
  local pet = ui.pet_find(pet_only_id)
  if pet == nil then
    return
  end
  w_title.text = sys.format("%s:%s", ui.get_text("pet|pet_genius_title"), pet.name)
end
function set_ability_point()
  local pet = ui.pet_find(g_pet_only_id)
  if pet == nil then
    return
  end
  w_point.text = sys.format("\204\236\184\179\181\227:%d/%d", pet:get_atb(bo2.eFlag_Pet_UseableGeniusPoint), pet:get_atb(bo2.eFlag_Pet_SumGeniusPoint))
end
function is_already_learn(ability)
  local pet = ui.pet_find(g_pet_only_id)
  if pet == nil then
    return false
  end
  if ability == nil then
    return false
  end
  for i = bo2.eFlag_Pet_AbilityMin, bo2.eFlag_Pet_AbilityMax - 1 do
    local id = pet:get_atb(i)
    local learn_ability = bo2.gv_pet_ability:find(id)
    if learn_ability ~= nil then
      if id == ability.id then
        return true
      end
      if learn_ability.group == ability.group and learn_ability.level >= ability.level then
        return true
      end
    end
  end
  return false
end
function find_ability(pre_group, pre_level)
  local size = bo2.gv_pet_ability.size
  for i = 0, size - 1 do
    local ability = bo2.gv_pet_ability:get(i)
    if ability.group == pre_group and ability.level == pre_level then
      return ability
    end
  end
  return nil
end
function satisfy_by_group_level(ability)
  local size = ability.pre_group.size
  for i = 0, size - 1 do
    local pre_ability = find_ability(ability.pre_group[i], ability.pre_level[i])
    if pre_ability == nil then
      return true
    end
    if not is_already_learn(pre_ability) then
      return false
    end
  end
  return true
end
function satisfy_by_pet_level(ability)
  local pet = ui.pet_find(g_pet_only_id)
  if pet == nil then
    return
  end
  local pet_level = pet:get_atb(bo2.eFlag_Pet_Level)
  local point = pet:get_atb(bo2.eFlag_Pet_UseableGeniusPoint)
  if pet_level >= ability.pet_level and point >= ability.consume_gen_point then
    return true
  end
  return false
end
function satisfy_by_growth(ability)
  local pet = ui.pet_find(g_pet_only_id)
  if pet == nil then
    return
  end
  local vit_growth = pet:get_atb(bo2.eFlag_Pet_VitGrowth)
  local ske_growth = pet:get_atb(bo2.eFlag_Pet_SkeGrowth)
  local str_growth = pet:get_atb(bo2.eFlag_Pet_StrGrowth)
  local int_growth = pet:get_atb(bo2.eFlag_Pet_IntGrowth)
  local agi_growth = pet:get_atb(bo2.eFlag_Pet_AgiGrowth)
  local pl = bo2.gv_pet_list:find(pet:get_atb(eFlag_Pet_ExcelID))
  local tmpl = bo2.gv_pet_tmpl:find(pl.liability)
  local vit_atb = {
    value = bo2.eFlag_Pet_VitGrowth
  }
  local agi_atb = {
    value = bo2.eFlag_Pet_AgiGrowth
  }
  local int_atb = {
    value = bo2.eFlag_Pet_IntGrowth
  }
  local str_atb = {
    value = bo2.eFlag_Pet_StrGrowth
  }
  local ske_atb = {
    value = bo2.eFlag_Pet_SkeGrowth
  }
  local vit_star_num = ui_pet.get_star_num(pet, vit_atb)
  local agi_star_num = ui_pet.get_star_num(pet, agi_atb)
  local int_star_num = ui_pet.get_star_num(pet, int_atb)
  local str_star_num = ui_pet.get_star_num(pet, str_atb)
  local ske_star_num = ui_pet.get_star_num(pet, ske_atb)
  if vit_star_num < ability.vit_growth or ske_star_num < ability.ske_growth or str_star_num < ability.str_growth or int_star_num < ability.int_growth or agi_star_num < ability.agi_growth then
    return false
  end
  return true
end
g_list = {}
function on_tab_click(btn)
  local list = get_select_ability_k()
  clear_desc()
  g_excel_id = nil
  for i = 1, 3 do
    local c_list = g_list[i]
    if c_list ~= list then
      clear_select(c_list)
    end
  end
  if list == w_ability_can_learn then
    w_learn_btn.enable = true
  else
    w_learn_btn.enable = false
  end
end
local ui_tab = ui_widget.ui_tab
function insert_tab(tab, name)
  local btn_uri = "$frame/pet/pet_genius.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/pet/pet_genius.xml"
  local page_sty = name
  ui_tab.insert_suit(tab, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(tab, name)
  btn.text = ui.get_text(sys.format("pet|%s", name))
  btn.size = ui.point(81, 22)
  btn:insert_on_click(on_tab_click, "ui_pet.ui_pet_genius.on_click")
end
function on_init()
  insert_tab(w_pet_ability, "ability_already_learn")
  insert_tab(w_pet_ability, "ability_can_learn")
  insert_tab(w_pet_ability, "ability_cannot_learn")
  ui_tab.show_page(w_pet_ability, "ability_can_learn", true)
  g_list = {
    w_ability_already_learn,
    w_ability_can_learn,
    w_ability_cannot_learn
  }
end
function get_select_ability_k()
  local btn = ui_tab.get_button(w_pet_ability, "ability_already_learn")
  if btn.press == true then
    return w_ability_already_learn
  end
  btn = ui_tab.get_button(w_pet_ability, "ability_can_learn")
  if btn.press == true then
    return w_ability_can_learn
  end
  btn = ui_tab.get_button(w_pet_ability, "ability_cannot_learn")
  if btn.press == true then
    return w_ability_cannot_learn
  end
end
function set_select(only_id)
  g_pet_only_id = only_id
  clear_all()
  ability_already_learn_init()
  ability_can_learn_init()
  ability_cannot_learn_init()
end
function ability_already_learn_init()
  local pet = ui.pet_find(g_pet_only_id)
  if pet == nil then
    return
  end
  for i = bo2.eFlag_Pet_AbilityMin, bo2.eFlag_Pet_AbilityMax - 1 do
    local id = pet:get_atb(i)
    local ability = bo2.gv_pet_ability:find(id)
    if ability ~= nil and is_already_learn(ability) then
      item_insert_to(id, bo2.ePet_Ability_AlreadyLearn)
    end
  end
end
function ability_can_learn_init()
  local pet = ui.pet_find(g_pet_only_id)
  if pet == nil then
    return
  end
  local size = bo2.gv_pet_ability.size
  for i = 0, size - 1 do
    local ability = bo2.gv_pet_ability:get(i)
    if satisfy_by_group_level(ability) and satisfy_by_pet_level(ability) and satisfy_by_growth(ability) and not is_already_learn(ability) then
      item_insert_to(ability.id, bo2.ePet_Ability_CanLearn)
    end
  end
end
function ability_cannot_learn_init()
  local size = bo2.gv_pet_ability.size
  local group = 1
  ui.log("pet_ability size:%s", size)
  for i = 0, size - 1 do
    local ability = bo2.gv_pet_ability:get(i)
    if not is_already_learn(ability) and ability.group == group then
      if not satisfy_by_group_level(ability) then
        item_insert_to(ability.id, bo2.ePet_Ability_CannotLearn)
        group = group + 1
      elseif not satisfy_by_pet_level(ability) then
        item_insert_to(ability.id, bo2.ePet_Ability_CannotLearn)
        group = group + 1
      elseif not satisfy_by_growth(ability) then
        item_insert_to(ability.id, bo2.ePet_Ability_CannotLearn)
        group = group + 1
      end
    end
  end
end
function item_insert_to(id, kind)
  local w_list
  if kind == bo2.ePet_Ability_AlreadyLearn then
    w_list = w_ability_already_learn
  elseif kind == bo2.ePet_Ability_CanLearn then
    w_list = w_ability_can_learn
  elseif kind == bo2.ePet_Ability_CannotLearn then
    w_list = w_ability_cannot_learn
  end
  if w_list == nil then
    return
  end
  local excel = bo2.gv_pet_ability:find(id)
  if excel == nil then
    return
  end
  local item_uri = L("$frame/pet/pet_genius.xml")
  local item_style = L("item")
  local item = w_list:item_append()
  item:load_style(item_uri, item_style)
  item.size = ui.point(250, 25)
  local name = item:search("name")
  name.text = sys.format("%s(%d\188\182)", excel.name, excel.level)
  local num = item:search("num")
  num.text = sys.format("%s%d", ui.get_text("pet|pet_genius_num"), excel.consume_gen_point)
  item.var:set("excel_id", id)
end
function item_remove_from(id, kind)
  local w_list
  if kind == bo2.ePet_Ability_AlreadyLearn then
    w_list = w_ability_already_learn
  elseif kind == bo2.ePet_Ability_CanLearn then
    w_list = w_ability_can_learn
  elseif kind == bo2.ePet_Ability_CannotLearn then
    w_list = w_ability_cannot_learn
  end
  if w_list == nil then
    return
  end
  if id == 0 then
    return
  end
  local size = w_list.item_count
  for i = 0, size - 1 do
    local item = w_list:item_get(i)
    if item ~= nil then
      local excel_id = item.var:get("excel_id").v_int
      if excel_id == id then
        w_pet_genius:item_remove(i)
      end
    end
  end
end
function clear_desc()
  w_card.excel_id = 0
  w_name.text = ""
  w_level.text = ""
  w_attribute.text = ""
  w_req_pre_list:item_clear()
end
function clear_all()
  w_ability_already_learn:item_clear()
  w_ability_can_learn:item_clear()
  w_ability_cannot_learn:item_clear()
  clear_desc()
  g_excel_id = nil
end
function insert_item(id)
  local excel = bo2.gv_pet_ability:find(id)
  if excel == nil then
    return
  end
  local item_uri = L("$frame/pet/pet_genius.xml")
  local item_style = L("item")
  local item = w_pet_genius:item_append()
  item:load_style(item_uri, item_style)
  item.size = ui.point(260, 25)
  local name = item:search("name")
  name.text = excel.name
  local level = item:search("level")
  level.text = sys.format("(%d\188\182)", excel.level)
  local num = item:search("num")
  num.text = excel.consume_gen_point
  item.var:set("excel_id", id)
end
function remove_item(id)
  if id == 0 then
    return
  end
  local size = w_pet_genius.item_count
  for i = 0, size - 1 do
    local item = w_pet_genius:item_get(i)
    if item ~= nil then
      local excel_id = item.var:get("excel_id").v_int
      if excel_id == id then
        w_pet_genius:item_remove(i)
      end
    end
  end
end
function is_already_exist(id)
  if id == 0 then
    return
  end
  local size = w_pet_genius.item_count
  for i = 0, size - 1 do
    local item = w_pet_genius:item_get(i)
    if item ~= nil then
      local excel_id = item.var:get("excel_id").v_int
      if excel_id == id then
        return true
      end
    end
  end
  return false
end
function insert_text(view, text)
  ui_widget.ui_text_list.insert_text(view, text)
  view.scroll = 1
end
function update_remark(ability)
  local all_text = ""
  local modify1 = bo2.gv_modify_pet:find(ability.atb1)
  if modify1 ~= nil then
    local name = modify1.name
    local value = ability.param1
    local text
    if ability.cent1 == 1 then
      text = sys.format(" %s +%d%", name, value)
    else
      text = sys.format(" %s +%d", name, value)
    end
    all_text = sys.format("%s", text)
  end
  local modify2 = bo2.gv_modify_pet:find(ability.atb2)
  if modify2 ~= nil then
    local name = modify2.name
    local value = ability.param2
    local text
    if ability.cent2 == 1 then
      text = sys.format(" %s +%d%", name, value)
    else
      text = sys.format(" %s +%d", name, value)
    end
    all_text = sys.format("%s %s", all_text, text)
  end
  local modify3 = bo2.gv_modify_pet:find(ability.atb3)
  if modify3 ~= nil then
    local name = modify3.name
    local value = ability.param3
    local text
    if ability.cent3 == 1 then
      text = sys.format(" %s +%d%", name, value)
    else
      text = sys.format(" %s +%d", name, value)
    end
    all_text = sys.format("%s %s", all_text, text)
  end
  local modify4 = bo2.gv_modify_pet:find(ability.atb4)
  if modify4 ~= nil then
    local name = modify4.name
    local value = ability.param4
    local text
    if ability.cent4 == 1 then
      text = sys.format(" %s +%d%", name, value)
    else
      text = sys.format(" %s +%d", name, value)
    end
    all_text = sys.format("%s %s", all_text, text)
  end
  local modify5 = bo2.gv_modify_pet:find(ability.atb5)
  if modify5 ~= nil then
    local name = modify5.name
    local value = ability.param5
    local text
    if ability.cent5 == 1 then
      text = sys.format(" %s +%d%", name, value)
    else
      text = sys.format(" %s +%d", name, value)
    end
    all_text = sys.format("%s %s", all_text, text)
  end
  w_attribute.text = all_text
end
function set_desc(excel_id)
  local item_file = L("$frame/pet/pet_genius.xml")
  local item_style = L("req_item")
  local ability = bo2.gv_pet_ability:find(excel_id)
  w_card.excel_id = excel_id
  w_name.text = ability.name
  w_level.text = sys.format("\181\200\188\182\163\186%d", ability.level)
  w_req_pre_list:item_clear()
  local item = w_req_pre_list:item_append()
  item:load_style(item_file, item_style)
  item.size = ui.point(250, 15)
  local desc = item:search("desc")
  local v = sys.variant()
  local text = ui.get_text("pet|req_pet_level")
  v:set("level", ability.pet_level)
  desc.text = sys.mtf_merge(v, text)
  local size = ability.pre_group.size
  for i = 0, size - 1 do
    local pre_ability = find_ability(ability.pre_group[i], ability.pre_level[i])
    if pre_ability ~= nil then
      local item = w_req_pre_list:item_append()
      item:load_style(item_file, item_style)
      item.size = ui.point(250, 15)
      local desc = item:search("desc")
      desc.text = sys.format("             \210\209\209\167\207\176%s %d\188\182", pre_ability.name, pre_ability.level)
    end
  end
  if 0 < ability.vit_growth then
    local item = w_req_pre_list:item_append()
    item:load_style(item_file, item_style)
    item.size = ui.point(250, 15)
    local desc = item:search("desc")
    local star = item:search("star")
    desc.text = sys.format("             %s", ui.get_text("pet|vit_growth"))
    local val = ability.vit_growth / 2
    star.dx = 16 * val
    star.visible = true
  end
  if 0 < ability.str_growth then
    local item = w_req_pre_list:item_append()
    item:load_style(item_file, item_style)
    item.size = ui.point(250, 15)
    local desc = item:search("desc")
    local star = item:search("star")
    desc.text = sys.format("             %s", ui.get_text("pet|str_growth"))
    local val = ability.str_growth / 2
    star.dx = 16 * val
    star.visible = true
  end
  if 0 < ability.int_growth then
    local item = w_req_pre_list:item_append()
    item:load_style(item_file, item_style)
    item.size = ui.point(250, 15)
    local desc = item:search("desc")
    local star = item:search("star")
    desc.text = sys.format("             %s", ui.get_text("pet|int_growth"))
    local val = ability.int_growth / 2
    star.dx = 16 * val
    star.visible = true
  end
  if 0 < ability.ske_growth then
    local item = w_req_pre_list:item_append()
    item:load_style(item_file, item_style)
    item.size = ui.point(250, 15)
    local desc = item:search("desc")
    local star = item:search("star")
    desc.text = sys.format("             %s", ui.get_text("pet|ske_growth"))
    local val = ability.ske_growth / 2
    star.dx = 16 * val
    star.visible = true
  end
  if 0 < ability.agi_growth then
    local item = w_req_pre_list:item_append()
    item:load_style(item_file, item_style)
    item.size = ui.point(250, 15)
    local desc = item:search("desc")
    local star = item:search("star")
    desc.text = sys.format("             %s", ui.get_text("pet|agi_growth"))
    local val = ability.agi_growth / 2
    star.dx = 16 * val
    star.visible = true
  end
  update_remark(ability)
end
function update_desc()
  local size = w_pet_genius.item_count
  local flag = false
  for i = 0, size - 1 do
    local item = w_pet_genius:item_get(i)
    if item ~= nil then
      local select = item:search("select")
      if select.visible == true then
        local excel_id = item.var:get("excel_id").v_int
        set_desc(excel_id)
        flag = true
        break
      end
    end
  end
  if flag == false then
    clear_desc()
  end
end
function clear_select(w_list)
  if w_list == nil then
    return
  end
  local size = w_list.item_count
  for i = 0, size - 1 do
    local item = w_list:item_get(i)
    item.selected = false
  end
end
function on_card_mouse(card, msg, pos, wheel)
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  if excel == nil then
    return
  end
  local size = bo2.gv_pet_ability.size
  local num = 0
  for i = 0, size - 1 do
    local ability = bo2.gv_pet_ability:get(i)
    if ability.group == excel.group then
      num = num + 1
    end
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_pet_ability(stk, excel.id)
  ui_tool.ctip_show(card, stk)
end
function on_al_item_sel(ctrl, vis)
  ctrl:search("select").visible = vis
  if vis then
    local excel_id = ctrl.var:get("excel_id").v_int
    g_excel_id = excel_id
    set_desc(excel_id)
  end
end
function on_cl_item_sel(ctrl, vis)
  ctrl:search("select").visible = vis
  if vis then
    local excel_id = ctrl.var:get("excel_id").v_int
    g_excel_id = excel_id
    set_desc(excel_id)
  end
end
function on_ctl_item_sel(ctrl, vis)
  ctrl:search("select").visible = vis
  if vis then
    local excel_id = ctrl.var:get("excel_id").v_int
    g_excel_id = excel_id
    set_desc(excel_id)
  end
end
function on_item_tip_show(tip)
end
function on_visible_init()
  local pet = ui.pet_find(g_pet_only_id)
  if pet == nil then
    return
  end
end
function set_visible(vis, pet_only_id)
  local w = ui.find_control("$frame:pet_genius")
  w.visible = vis
  if vis == false then
    return
  end
  g_pet_only_id = pet_only_id
  set_select(pet_only_id)
  set_money()
  set_ability_point()
  set_title(pet_only_id)
  ui_tab.show_page(w_pet_ability, "ability_can_learn", true)
  w_learn_btn.enable = true
  w:move_to_head()
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
    on_visible_init()
  else
    ui_widget.esc_stk_pop(w)
    clear_all()
  end
end
function on_observable(w, vis)
  if not vis then
    return
  end
  if g_pet_only_id ~= nil then
    set_ability_point()
  end
end
function on_cancel_click(btn)
  set_visible(false)
end
function on_learn_click(btn)
  if g_excel_id == nil then
    ui_tool.note_insert(ui.get_text("pet|pet_select_ability_warning"), ui_pet.c_warning_color)
    return
  end
  if g_pet_only_id == nil then
    return
  end
  ui_pet.send_learn_ability(g_pet_only_id, g_excel_id)
end
function succeed_learn_ability(ability_id)
end
