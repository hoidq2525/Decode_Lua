g_only_id = nil
g_pet_info = nil
g_p_card_parent = nil
g_f_skill_parent = w_pet_fight_skill_box
g_zb_skill_parent = w_pet_zb_skill_box
g_genius_parent = w_pet_genius_box
g_pet_func = nil
local g_func = {}
function on_pet_insert(pet)
  if g_only_id ~= nil then
    return
  end
  if g_pet_func == nil then
    return
  end
  g_pet_info = pet
  g_only_id = pet.only_id
  set_pet_name(pet)
  update_pet_atb(pet)
  set_pet_skill(0, pet.box)
  update_hole(pet)
  if g_func[g_pet_func].func ~= nil then
    g_func[g_pet_func].func(pet)
  end
end
function on_pet_remove(pet_info)
  if pet_info.only_id ~= g_only_id then
    local pet = ui.pet_find(g_only_id)
    set_select_by_only_id(g_only_id)
    return
  end
  local box_s = ui.pet_get_box_size(bo2.ePetBox_Player)
  if box_s == 0 then
    clear_pet_info()
    if g_func[g_pet_func].delpet ~= nil then
      g_func[g_pet_func].delpet(pet_info)
    end
    return
  end
  on_visible_init(g_pet_func)
  update_select()
  on_visible()
  if g_func[g_pet_func].delpet ~= nil then
    g_func[g_pet_func].delpet(pet_info)
  end
end
function on_pet_update(pet_info)
  if g_pet_func == nil then
    return
  end
  if g_func[g_pet_func].update ~= nil then
    g_func[g_pet_func].update(pet_info)
  end
end
function init_once()
  atb_def = {
    atb_name = {},
    atb_sex = {
      value = bo2.eFlag_Pet_Sex,
      on_make_text = on_make_sex_text
    },
    atb_level = {
      value = bo2.eFlag_Pet_Level
    },
    atb_kidney = {
      value = bo2.eFlag_Pet_Kidney,
      on_make_text = on_make_kidney_text
    },
    atb_exp = {
      value = bo2.eFlag_Pet_Exp,
      on_make_text = on_make_exp_text
    },
    atb_gen_gro = {
      value = bo2.eFlag_Pet_GenGrowth,
      basic = bo2.eFlag_Pet_GenGrowth,
      on_make_text = on_make_star_text
    }
  }
  for n, v in pairs(atb_def) do
    v.name = n
    v.title = ui.get_text("pet|name_" .. n)
    v.tip = ui.get_text("pet|tip_" .. n)
    if v.on_make_text == nil then
      if v.limit ~= nil then
        v.on_make_text = ui_pet.on_make_limit_text
      elseif v.range ~= nil then
        v.on_make_text = ui_pet.on_make_range_text
      else
        v.on_make_text = ui_pet.on_make_value_text
      end
    end
    if v.on_make_tip == nil then
      if v.basic ~= nil then
        v.on_make_tip = ui_pet.on_make_basic_tip
      else
        v.on_make_tip = ui_pet.on_make_tip
      end
    end
  end
  atb_reg = {}
  init_pet = {
    [bo2.eFlag_Pet_Sex] = 0,
    ["get_atb"] = function(obj, idx)
      local v = obj[idx]
      if v == nil then
        return 0
      end
      return v
    end
  }
  g_func[bo2.ePet_Func_ToBaby] = {
    money = ui_pet.ui_to_baby.set_money,
    func = on_to_baby_func
  }
  g_func[bo2.ePet_Func_ToToy] = {
    money = ui_pet.ui_to_toy.set_money,
    func = on_to_toy_func
  }
  g_func[bo2.ePet_Func_Refine] = {
    money = ui_pet.ui_refine.set_money,
    func = on_refine_func
  }
  g_func[bo2.ePet_Func_Train] = {
    money = nil,
    func = on_train_func,
    update = on_train_update,
    delpet = on_train_delpet
  }
  g_func[bo2.ePet_Func_ClearAbility] = {
    money = ui_pet.ui_clear_genius.set_money,
    func = on_clear_ability_func,
    close = ui_pet.ui_clear_genius.on_close
  }
  g_func[bo2.ePet_Func_PetBreed] = {
    money = ui_pet.ui_pet_breed.set_money,
    func = on_pet_breed_func
  }
  g_func[bo2.ePet_Func_OpenHole] = {
    money = ui_pet.ui_open_hole.set_money,
    func = on_open_hole_func,
    item = ui_pet.ui_open_hole.set_item,
    delpet = on_open_hole_delpet
  }
  g_func[bo2.ePet_Func_ReOpenHole] = {
    money = ui_pet.ui_reopen_hole.set_money,
    func = on_reopen_hole_func,
    item = ui_pet.ui_reopen_hole.set_item,
    delpet = on_reopen_hole_delpet
  }
  g_func[bo2.ePet_Func_LearnSkill] = {money = nil, func = on_learn_skill_func}
  g_func[bo2.ePet_Func_SkillLevelUp] = {
    money = ui_pet.ui_skill_lvup.set_money,
    func = on_skill_levelup_func,
    delpet = on_skill_levelup_delpet
  }
end
function set_self_title(pet)
  local name = pet.excel.name
  local val = pet:get_atb(bo2.eFlag_Pet_Kind)
  local v = sys.variant()
  local kind = ui.get_text(sys.format("common|pet_kind%d", val))
  v:set("name", name)
  local show = sys.mtf_merge(v, kind)
  w_title.text = show
  local color = ui_pet.get_name_color(pet)
  w_title.xcolor = color
end
function on_train_delpet()
  local w = ui.find_control("$frame:pet_genius")
  w.visible = false
end
function on_open_hole_delpet()
  ui_pet.ui_open_hole.set_open_hole_odds(g_only_id)
end
function on_reopen_hole_delpet()
  set_hole_no_select()
end
function on_skill_levelup_delpet()
  set_hole_no_select()
end
function on_to_baby_func(pet)
  set_self_title(pet)
end
function on_to_toy_func(pet)
  set_self_title(pet)
end
function on_refine_func(pet)
  local sum_exp = ui_pet.ui_refine.get_sum_exp(pet.only_id)
  ui_pet.ui_refine.set_exp(sum_exp)
end
function on_train_func(pet)
end
function on_clear_ability_func(pet)
end
function on_pet_breed_func(pet)
end
function on_open_hole_func(pet)
  ui_pet.ui_open_hole.set_open_hole_odds(pet.only_id)
end
function on_reopen_hole_func(pet)
  set_hole_no_select()
  ui_pet.ui_reopen_hole.set_index(nil)
end
function on_learn_skill_func(pet)
  set_hole_no_select()
end
function on_skill_levelup_func(pet)
  ui_pet.ui_skill_lvup.set_skill_id(-1, -1)
  set_hole_no_select()
  ui_pet.ui_skill_lvup.set_no_select()
end
function on_train_update(pet)
  ui_pet.ui_pet_genius.update_pet_info(pet)
end
function on_atb_init(p)
  local n = tostring(p.name)
  local d = atb_def[n]
  if d == nil then
    ui.log("bad atb name %s.", n)
    return
  end
  local lb_name = p:search("lb_name")
  local lb_value = p:search("lb_value")
  if lb_name ~= nil then
    lb_name.text = d.title
  end
  if lb_value ~= nil then
    d.label = lb_value
  end
  atb_reg[n] = d
end
function on_make_tip(pet, atb)
  return atb.tip
end
function on_make_basic_tip(pet, atb)
  if pet == nil then
    ui.log("tip:pet is nil")
    return
  end
  local basic = atb.basic
  if basic == nil then
    return atb.tip
  end
  local v_atb = pet:get_atb(atb.value)
  local b_atb = pet:get_atb(basic)
  local stk = sys.stack()
  stk:push(atb.title)
  if v_atb > b_atb then
    stk:format(ui_pet.c_format_add, v_atb, b_atb, v_atb - b_atb)
  elseif v_atb < b_atb then
    stk:format(ui_pet.c_format_sub, v_atb, b_atb, b_atb - v_atb)
  else
    stk:format(ui_pet.c_format_equ, v_atb)
  end
  stk:push("\n")
  stk:push(atb.tip)
  return stk.text
end
function on_make_value_text(pet, atb)
  local basic = atb.basic
  local v_atb = pet:get_atb(atb.value)
  if basic == nil then
    return L(v_atb), ui_pet.value_color_cmn
  end
  local b_atb = pet:get_atb(basic)
  if v_atb > b_atb then
    return L(v_atb), ui_pet.value_color_add
  end
  if v_atb < b_atb then
    return L(v_atb), ui_pet.value_color_sub
  end
  return L(v_atb), ui_pet.value_color_equ
end
function on_make_sex_text(pet, atb)
  local sex = pet:get_atb(atb.value)
  if sex == 1 then
    w_pet_sex_img.image = "$gui/image/pet/male.png"
  else
    w_pet_sex_img.image = "$gui/image/pet/female.png"
  end
  return nil
end
function on_make_kidney_text(pet, atb)
  local kidney = pet:get_atb(atb.value)
  local t = ui.get_text(sys.format("common|pet_kidney%d", kidney))
  return t
end
function on_make_exp_text(pet, atb)
  local lev = pet:get_atb(bo2.eFlag_Pet_Level)
  local exp_current = pet:get_atb(bo2.eFlag_Pet_Exp)
  local exp_total = 0
  if lev == 0 then
    exp_current = 0
  else
    local level = bo2.gv_pet_levelup:find(lev)
    if level == nil then
      exp_total = 10000000
    else
      exp_total = level.exp
    end
    w_pet_exp.dx = 240 * (exp_current / exp_total)
  end
  return sys.format("%d/%d", exp_current, exp_total)
end
function on_make_star_text(pet, atb)
  local val = pet:get_atb(atb.value)
  local reg = atb_reg[tostring(atb.name)]
  local star_num = ui_pet.get_star_num(pet, atb)
  local star_max = 5
  if reg ~= nil then
    local star = reg.label.parent:search("star")
    star.dx = 16 * star_num / 2
    local star_bg = reg.label.parent:search("star_max")
    star_bg.dx = 16 * star_max
  end
  return val
end
function update_pet_atb(pet)
  if pet.only_id ~= g_only_id then
    return
  end
  for n, v in pairs(atb_reg) do
    if pet == nil then
      ui.log("pet is nil in update_pet_atb")
    else
      local s, t, c = sys.pcall(v.on_make_text, pet, v)
      local lb = v.label
      if lb ~= nil then
        lb.text = t
      end
      if c ~= nil and lb ~= nil then
        lb.xcolor = c
      end
    end
  end
  if g_func[g_pet_func].update ~= nil then
    g_func[g_pet_func].update(pet)
  end
end
function on_atb_tip_make(tip)
  local atb = atb_def[tostring(tip.owner.name)]
  if atb == nil then
    return
  end
  local text = atb.on_make_tip(g_pet_info, atb)
  ui_widget.tip_make_view(tip.view, text)
end
init_once()
c_box_size_x = ui_pet.c_box_size_x
c_box_size_y = ui_pet.c_box_size_y
c_cell_size = ui_pet.c_cell_size
c_text_item_file = ui_pet.c_text_item_file
c_text_item_cell = ui_pet.c_text_item_cell
c_skill_cell = ui_pet.c_skill_cell
c_ability_cell = ui_pet.c_ability_cell
c_hole_file = ui_pet.c_hole_file
c_hole_cell = ui_pet.c_hole_cell
c_box_count = ui_pet.c_box_count
c_box_margin = ui_pet.c_box_margin
c_box_fight_skill_size_x = ui_pet.c_box_fight_skill_size_x
c_box_fight_skill_size_y = ui_pet.c_box_fight_skill_size_y
c_box_zb_skill_size_x = ui_pet.c_box_zb_skill_size_x
c_box_zb_skill_size_y = ui_pet.c_box_zb_skill_size_y
c_box_genius_size_x = ui_pet.c_box_genius_size_x
c_box_genius_size_y = ui_pet.c_box_genius_size_y
c_fight_skill = ui_pet.c_fight_skill
c_zb_skill = ui_pet.c_zb_skill
c_genius_skill = ui_pet.c_genius_skill
function set_skill_view(parent)
  ui.log("parent:" .. parent.name)
  local p_skill = parent:search("p_skill")
  local p_genius = parent:search("p_genius")
  local p_f_skill = p_skill:search("p_f_skill")
  local p_zb_skill = p_skill:search("p_zb_skill")
  local p_g_genius = p_genius:search("p_g_genius")
  g_f_skill_parent = p_f_skill
  g_zb_skill_parent = p_zb_skill
  g_genius_parent = p_g_genius
end
function update_select()
  for i = 0, c_box_size_x * c_box_size_y - 1 do
    local card = w_pet_portrait_box:search("grid:" .. i)
    local select = card.parent:search("select")
    select.visible = false
  end
end
function update_hole(pet)
  if pet == nil then
    ui.log("pet is nil in update_hole:pet_common.lua")
    return
  end
  for i = 0, c_box_fight_skill_size_x - 1 do
    local enable = pet:get_skill_enable(c_fight_skill, i)
    if w_pet_fight_skill_box == nil then
      return
    end
    local hole = w_pet_fight_skill_box:search("w_cells"):search("hole:" .. i)
    if enable == 0 then
      hole.visible = false
    else
      hole.visible = true
    end
  end
  for i = 0, c_box_zb_skill_size_y - 1 do
    for j = 0, c_box_zb_skill_size_x - 1 do
      local index = j + i * c_box_zb_skill_size_x
      local enable = pet:get_skill_enable(c_zb_skill, index)
      local hole = w_pet_zb_skill_box:search("w_cells"):search("hole:" .. index)
      local card = w_pet_zb_skill_box:search("w_cells"):search("grid:" .. index)
      if enable == 0 then
        hole.visible = false
      else
        ui.log("---")
        local kidney = card.kidney
        hole.image = sys.format("$image/pet/kidney%d.png", kidney)
        hole.visible = true
      end
    end
  end
end
function set_index_select(idx)
  for i = 0, c_box_size_x * c_box_size_y - 1 do
    local card = w_pet_portrait_box:search("grid:" .. i)
    local select = card.parent:search("select")
    if i == idx then
      if card.only_id ~= 0 then
        select.visible = true
        g_only_id = card.only_id
        g_pet_info = ui.pet_find(g_only_id)
      end
    else
      select.visible = false
    end
  end
end
function on_card_tip_show(tip)
  local card = tip.owner
  if card.kind == 0 then
    local excel = card.excel
    if excel == nil then
      return
    end
    local stk = sys.mtf_stack()
    ui_tool.ctip_make_pet_skill(stk, card.excel.id)
    ui_tool.ctip_show(card, stk)
    return
  end
  local kidney = card.kidney
  local hole = w_pet_zb_skill_box:search("w_cells"):search("hole:" .. card.index)
  if hole.visible == false then
    return
  end
  if card.open == 0 then
    return
  end
  if kidney == 0 then
    return
  end
  if card.excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_pet_skill(stk, card.excel.id)
  ui_tool.ctip_show(card, stk)
end
function on_card_tip_ability_show(tip)
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
function on_card_mouse(card, msg, pos, wheel)
  local parent = card.parent
  local icon = card.icon
  if icon == nil then
    return
  end
  if msg == ui.mouse_lbutton_click then
    update_select()
    local select = card.parent:search("select")
    select.visible = true
    local pet = ui.pet_find(card.only_id)
    g_pet_info = pet
    g_only_id = pet.only_id
    g_p_card_parent = card.parent.parent
    set_pet_name(pet)
    update_pet_atb(pet)
    set_pet_skill(card.index, pet.box)
    update_hole(pet)
    if g_func[g_pet_func].func ~= nil then
      g_func[g_pet_func].func(pet)
    end
  end
end
function on_fight_skill_mouse(card, msg, pos, wheel)
  if g_pet_func ~= bo2.ePet_Func_SkillLevelUp then
    return
  end
  if card.excel == nil then
    return
  end
  local parent = card.parent
  if msg == ui.mouse_lbutton_click then
    set_hole_no_select()
    local select = parent:search("select")
    select.visible = true
    ui_pet.ui_skill_lvup.set_skill_id(0, card.index)
  end
end
function on_zb_skill_mouse(card, msg, pos, wheel)
  if g_pet_func == bo2.ePet_Func_ReOpenHole then
    if card.open == 0 then
      return
    end
    if card.index == 0 then
      return
    end
    if card.excel ~= nil then
      return
    end
    local parent = card.parent
    if msg == ui.mouse_lbutton_click then
      set_hole_no_select()
      local select = parent:search("select")
      select.visible = true
      ui_pet.ui_reopen_hole.set_skill_index(card.index)
    end
  end
  if g_pet_func == bo2.ePet_Func_SkillLevelUp then
    if card.excel == nil then
      return
    end
    local parent = card.parent
    if msg == ui.mouse_lbutton_click then
      set_hole_no_select()
      local select = parent:search("select")
      select.visible = true
      ui_pet.ui_skill_lvup.set_skill_id(1, card.index)
    end
  end
end
function on_init_pet_box(ctrl, data)
  local w_cells = ctrl:search("w_cells")
  if w_cells == nil then
    ui.log("failed get w_cells---pet_box")
    return
  end
  w_cells.size = ui.point(c_box_size_x * c_cell_size + c_box_size_x * c_box_margin, c_box_size_y * c_cell_size + c_box_size_y * c_box_margin)
  local box = data.v_int
  for r = 0, c_box_size_y - 1 do
    for i = 0, c_box_size_x - 1 do
      local c = ui.create_control(w_cells, "panel")
      c:load_style(c_text_item_file, c_text_item_cell)
      c.offset = ui.point(i * c_cell_size + i * c_box_margin, r * c_cell_size + r * c_box_margin)
      local grid = r * c_box_size_x + i
      c.name = grid
      local d = c:search("card")
      d.index = grid
      d.name = sys.format("grid:%d", grid)
      d.box = box
      d:insert_on_mouse(on_card_mouse, "ui_pet.ui_pet_common.on_card_mouse")
    end
  end
  ctrl.name = sys.format("box:%d", box)
end
function on_init_pet_fight_skill_box(ctrl, data)
  local w_cells = ctrl:search("w_cells")
  if w_cells == nil then
    ui.log("failed get w_cells--fight_skill")
    return
  end
  w_cells.size = ui.point(c_box_fight_skill_size_x * c_cell_size + c_box_fight_skill_size_x * c_box_margin, c_box_zb_skill_size_y * c_cell_size + c_box_zb_skill_size_y * c_box_margin)
  local box = data.v_int
  for r = 0, c_box_zb_skill_size_y - 1 do
    for i = 0, c_box_fight_skill_size_x - 1 do
      local c = ui.create_control(w_cells, "panel")
      c:load_style(c_text_item_file, c_skill_cell)
      c.offset = ui.point(i * c_cell_size + i * c_box_margin, r * c_cell_size + r * c_box_margin)
      local grid = r * c_box_fight_skill_size_x + i
      c.name = grid
      local d = c:search("card")
      d.kind = 0
      d.owner_index = 0
      d.index = grid
      d.name = sys.format("grid:%d", grid)
      d:insert_on_mouse(on_fight_skill_mouse, "ui_pet.ui_pet_common.on_fight_skill_mouse")
      local tip = d:find_plugin("tip")
      tip:insert_on_show(ui_pet.ui_pet_common.on_card_tip_show, "ui_pet.ui_pet_common.on_card_tip_show")
      local bg = ui.create_control(w_cells, "panel")
      bg:load_style(c_hole_file, c_hole_cell)
      bg.offset = ui.point(i * c_cell_size + i * c_box_margin, r * c_cell_size + r * c_box_margin)
      local hole = bg:search("hole")
      hole.name = sys.format("hole:%d", grid)
      hole.visible = false
    end
  end
end
function on_init_pet_zb_skill_box(ctrl, data)
  local w_cells = ctrl:search("w_cells")
  if w_cells == nil then
    ui.log("failed get w_cells---zb_skill")
    return
  end
  w_cells.size = ui.point(c_box_zb_skill_size_x * c_cell_size + c_box_zb_skill_size_x * c_box_margin, c_box_zb_skill_size_y * c_cell_size + c_box_zb_skill_size_y * c_box_margin)
  local box = data.v_int
  for r = 0, c_box_zb_skill_size_y - 1 do
    for i = 0, c_box_zb_skill_size_x - 1 do
      local c = ui.create_control(w_cells, "panel")
      c:load_style(c_text_item_file, c_skill_cell)
      c.offset = ui.point(i * c_cell_size + i * c_box_margin, r * c_cell_size + r * c_box_margin)
      local grid = r * c_box_zb_skill_size_x + i
      c.name = grid
      local d = c:search("card")
      d.kind = 1
      d.owner_index = 0
      d.index = grid
      d.name = sys.format("grid:%d", grid)
      d:insert_on_mouse(on_zb_skill_mouse, "ui_pet.ui_pet_common.on_zb_skill_mouse")
      local tip = d:find_plugin("tip")
      tip:insert_on_show(ui_pet.ui_pet_common.on_card_tip_show, "ui_pet.ui_pet_common.on_card_tip_show")
      local bg = ui.create_control(w_cells, "panel")
      bg:load_style(c_hole_file, c_hole_cell)
      bg.offset = ui.point(i * c_cell_size + i * c_box_margin, r * c_cell_size + r * c_box_margin)
      local hole = bg:search("hole")
      hole.name = sys.format("hole:%d", grid)
      hole.visible = false
    end
  end
end
function on_init_pet_genius_box(ctrl, data)
  local w_cells = ctrl:search("w_cells")
  if w_cells == nil then
    ui.log("failed get w_cells---pet_genius_box")
    return
  end
  w_cells.size = ui.point(c_box_genius_size_x * c_cell_size + c_box_genius_size_x * c_box_margin, c_box_genius_size_y * c_cell_size + c_box_genius_size_y * c_box_margin)
  local box = data.v_int
  for r = 0, c_box_genius_size_y - 1 do
    for i = 0, c_box_genius_size_x - 1 do
      local c = ui.create_control(w_cells, "panel")
      c:load_style(c_text_item_file, c_ability_cell)
      c.offset = ui.point(i * c_cell_size + i * c_box_margin, r * c_cell_size + r * c_box_margin)
      local grid = r * c_box_genius_size_x + i
      c.name = grid
      local d = c:search("card")
      d.kind = 0
      d.owner_index = 0
      d.index = grid
      d.name = sys.format("grid:%d", grid)
    end
  end
end
w_pet_fight_skill_box = ui_pet.ui_pet_common.w_pet_fight_skill_box
w_pet_zb_skill_box = ui_pet.ui_pet_common.w_pet_zb_skill_box
w_pet_genius_box = ui_pet.ui_pet_common.w_pet_genius_box
function set_pet_figth_skill(owner_index, box)
  for i = 0, c_box_fight_skill_size_x * c_box_fight_skill_size_y - 1 do
    local card = w_pet_fight_skill_box:search("w_cells"):search("grid:" .. i)
    card.owner_index = owner_index
    card.box = box
  end
end
function set_pet_zb_skill(owner_index, box)
  for i = 0, c_box_zb_skill_size_x * c_box_zb_skill_size_y - 1 do
    local card = w_pet_zb_skill_box:search("w_cells"):search("grid:" .. i)
    card.owner_index = owner_index
    card.box = box
  end
end
function set_pet_genius(owner_index, box)
  for i = 0, c_box_genius_size_x * c_box_genius_size_y - 1 do
    local card = w_pet_genius_box:search("w_cells"):search("grid:" .. i)
    card.owner_index = owner_index
    card.box = box
  end
end
function set_pet_skill(owner_index, box)
  set_pet_figth_skill(owner_index, box)
  set_pet_zb_skill(owner_index, box)
  set_pet_genius(owner_index, box)
end
function set_pet_name(pet)
  if pet == nil then
    return
  end
  if pet.only_id ~= g_only_id then
    return
  end
  w_pet_name.text = pet.name
end
function clear_select()
  g_pet_info = nil
  g_only_id = nil
  update_select()
end
function get_select()
  return g_only_id
end
function set_hole_no_select()
  for i = 0, c_box_fight_skill_size_x * c_box_fight_skill_size_y - 1 do
    local card = w_pet_fight_skill_box:search("w_cells"):search("grid:" .. i)
    local parent = card.parent
    local select = parent:search("select")
    select.visible = false
  end
  for i = 0, c_box_zb_skill_size_x * c_box_zb_skill_size_y - 1 do
    local card = w_pet_zb_skill_box:search("w_cells"):search("grid:" .. i)
    local parent = card.parent
    local select = parent:search("select")
    select.visible = false
  end
end
function set_pet_hole_select(kind)
  set_hole_no_select()
  if g_pet_func ~= bo2.ePet_Func_OpenHole then
    return
  end
  if kind == 0 then
    for i = 0, c_box_fight_skill_size_x * c_box_fight_skill_size_y - 1 do
      local card = w_pet_fight_skill_box:search("w_cells"):search("grid:" .. i)
      local id = card.index
      if card.open == 0 then
        ui.log("card.index:" .. card.index)
        local parent = card.parent
        local select = parent:search("select")
        select.visible = true
        return
      end
    end
    return
  end
  for i = 0, c_box_zb_skill_size_x * c_box_zb_skill_size_y - 3 do
    local card = w_pet_zb_skill_box:search("w_cells"):search("grid:" .. i)
    local id = card.index
    if card.open == 0 then
      local parent = card.parent
      local select = parent:search("select")
      select.visible = true
      return
    end
  end
end
function set_hole_select_index(kind, idx)
  set_hole_no_select()
  if idx < 0 then
    return
  end
  if kind == 0 then
    local card = w_pet_fight_skill_box:search("w_cells"):search("grid:" .. idx)
    local select = card.parent:search("select")
    select.visible = true
    return
  end
  local card = w_pet_zb_skill_box:search("w_cells"):search("grid:" .. idx)
  local select = card.parent:search("select")
  select.visible = true
end
function on_free_pet_click(btn)
end
function on_open_skill_panel(btn)
  local close = btn.parent:search("btn_close_skill")
  close.visible = true
  local w = ui.find_control("$frame:pet_common")
  local p_skill_view = w:search("p_skill_view")
  p_skill_view.visible = true
  btn.visible = false
end
function on_close_skill_panel(btn)
  local open = btn.parent:search("btn_open_skill")
  open.visible = true
  local w = ui.find_control("$frame:pet_common")
  local p_skill_view = w:search("p_skill_view")
  p_skill_view.visible = false
  btn.visible = false
end
function on_pet_init()
end
function on_btn_func_click()
end
function on_close_skill(btn)
  local parent = btn.parent.parent
  ui.log("name:" .. parent.name)
  parent.visible = false
end
function on_close()
  local w = ui.find_control("$frame:pet_common")
  w.visible = false
end
function set_visible(vis, kind)
  local w = ui.find_control("$frame:pet_common")
  if w.visible == vis then
    return
  end
  g_pet_func = kind
  if w.visible == true then
    w.visible = false
  end
  w.visible = vis
  if vis == true then
    local p_pet = w:search("p_pet")
    p_pet.visible = true
    local p_skill_view = w:search("p_skill_view")
    p_skill_view.visible = true
    on_visible_init(kind)
    on_visible()
  end
  w:move_to_head()
end
function on_visible_init(kind)
  set_title(kind)
  set_money(kind)
  set_func(kind)
  set_item(kind)
  set_special(kind)
end
function set_title(kind)
  local title = ui.get_text(sys.format("pet|title_%d", kind))
  w_title.text = title
  w_title.xcolor = "FFFFFFFF"
end
function set_money(kind)
  local func = g_func[kind]
  if func == nil then
    return
  end
  if func.money ~= nil then
    func.money()
  end
end
function set_item(kind)
  local func = g_func[kind]
  if func == nil then
    return
  end
  if func.item ~= nil then
    func.item()
  end
end
function set_func(kind)
  ui.log(kind)
  local w = ui.find_control("$frame:pet_common")
  local parent = w:search("p_pet")
  for i = bo2.ePet_Func_Start, bo2.ePet_Func_End do
    local name = sys.format("p_%d", i)
    local p = parent:search(name)
    if p ~= nil then
      if i == kind then
        p.visible = true
      else
        p.visible = false
      end
    end
  end
end
function get_index_by_only_id(only_id)
  for i = 0, c_box_size_x * c_box_size_y do
    local card = w_pet_portrait_box:search("grid:" .. i)
    if card.only_id == only_id then
      return card.index
    end
  end
  return nil
end
function set_select_by_only_id(only_id)
  local pet = ui.pet_find(only_id)
  if pet == nil then
    return
  end
  g_pet_info = pet
  set_pet_name(pet)
  update_pet_atb(pet)
  local idx = get_index_by_only_id(only_id)
  set_pet_skill(idx, pet.box)
  update_hole(pet)
  for i = 0, c_box_size_x * c_box_size_y - 1 do
    local card = w_pet_portrait_box:search("grid:" .. i)
    local select = card.parent:search("select")
    if card.only_id == only_id then
      select.visible = true
    else
      select.visible = false
    end
  end
end
function set_special(kind)
  if kind == bo2.ePet_Func_Train then
  end
end
function clear_pet_skill_info()
  if w_pet_fight_skill_box ~= nil then
    for i = 0, c_box_fight_skill_size_x - 1 do
      local hole = w_pet_fight_skill_box:search("w_cells"):search("hole:" .. i)
      hole.visible = false
    end
  end
  if w_pet_zb_skill_box ~= nil then
    for i = 0, c_box_zb_skill_size_y - 1 do
      for j = 0, c_box_zb_skill_size_x - 1 do
        local index = j + i * c_box_zb_skill_size_x
        local hole = w_pet_zb_skill_box:search("w_cells"):search("hole:" .. index)
        hole.visible = false
        local card = w_pet_zb_skill_box:search("w_cells"):search("grid:" .. index)
        card.kidney = ui_pet.c_card_data_init
      end
    end
  end
end
function clear_pet_info()
  set_hole_no_select()
  clear_pet_skill_info()
  clear_select()
  w_pet_name.text = ""
  g_only_id = nil
  g_pet_info = nil
  update_pet_atb(init_pet)
end
function clear_all()
  ui_pet.ui_clear_genius.clear_all()
  ui_pet.ui_open_hole.clear_all()
  ui_pet.ui_reopen_hole.clear_all()
  ui_pet.ui_learn_skill.clear_all()
  ui_pet.ui_skill_lvup.clear_all()
  ui_pet.ui_to_baby.clear_all()
  clear_select()
  set_hole_no_select()
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
  else
    ui_widget.esc_stk_pop(w)
    clear_all()
  end
end
function on_visible()
  local box_s = ui.pet_get_box_size(bo2.ePetBox_Player)
  if box_s == 0 then
    return
  end
  set_index_select(0)
  local pet = ui.pet_find(g_only_id)
  if pet == nil then
    return
  end
  g_pet_info = pet
  set_pet_name(pet)
  update_pet_atb(pet)
  set_pet_skill(0, pet.box)
  update_hole(pet)
  if g_func[g_pet_func].func ~= nil then
    g_func[g_pet_func].func(pet)
  end
end
