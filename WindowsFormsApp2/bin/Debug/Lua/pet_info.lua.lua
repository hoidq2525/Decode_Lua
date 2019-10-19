g_pet_info = nil
local ui_tab = ui_widget.ui_tab
function insert_tab(tab, name)
  local btn_uri = "$frame/pet/pet_info.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/pet/pet_info.xml"
  local page_sty = name
  ui_tab.insert_suit(tab, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(tab, name)
  btn.text = ui.get_text(sys.format("pet|%s", name))
end
function on_pet_init()
  insert_tab(w_pet_info, "attri_area1")
  insert_tab(w_pet_info, "attri_area2")
  ui_tab.show_page(w_pet_info, "attri_area1", true)
  insert_tab(w_pet_atb3, "phy_atb")
  insert_tab(w_pet_atb3, "mag_atb")
  ui_tab.show_page(w_pet_atb3, "phy_atb", true)
  local btn1 = ui_tab.get_button(w_pet_atb3, "phy_atb")
  btn1.dy = 19
  local btn2 = ui_tab.get_button(w_pet_atb3, "mag_atb")
  btn2.dy = 19
end
function set_pet_info(pet)
  on_set_default_name(pet)
  on_make_name_text(pet)
  set_pet_only_id(pet)
  set_mate_only_id(pet)
  set_pet_liability(pet)
end
function init_once()
  atb_def = {
    atb_default_name = {},
    atb_name = {},
    atb_sex = {
      value = bo2.eFlag_Pet_Sex,
      on_make_text = on_make_sex_text
    },
    atb_level = {
      value = bo2.eFlag_Pet_Level
    },
    atb_loyal = {
      value = bo2.eFlag_Pet_Loyal
    },
    atb_hp = {
      value = bo2.eFlag_Pet_HP,
      limit = bo2.eAtb_HPMax
    },
    atb_id = {},
    atb_mate_id = {},
    atb_exp = {
      value = bo2.eFlag_Pet_Exp,
      on_make_text = on_make_exp_text,
      on_make_tip = on_make_exp_tip
    },
    atb_excel_id = {
      value = bo2.eFlag_ExcelID
    },
    atb_strength = {
      value = bo2.eAtb_Str,
      basic = bo2.eFlag_Pet_BaseStr
    },
    atb_int = {
      value = bo2.eAtb_Int,
      basic = bo2.eFlag_Pet_BaseInt
    },
    atb_agi = {
      value = bo2.eAtb_Agi,
      basic = bo2.eFlag_Pet_BaseAgi
    },
    atb_vit = {
      value = bo2.eAtb_Vit,
      basic = bo2.eFlag_Pet_BaseVit
    },
    atb_ske = {
      value = bo2.eAtb_Ske,
      basic = bo2.eFlag_Pet_BaseSke
    },
    atb_strength_apt = {
      value = bo2.eFlag_Pet_StrGrowth,
      basic = bo2.eFlag_Pet_StrGrowth,
      on_make_text = on_make_star_text
    },
    atb_int_apt = {
      value = bo2.eFlag_Pet_IntGrowth,
      basic = bo2.eFlag_Pet_IntGrowth,
      on_make_text = on_make_star_text
    },
    atb_agi_apt = {
      value = bo2.eFlag_Pet_AgiGrowth,
      basic = bo2.eFlag_Pet_AgiGrowth,
      on_make_text = on_make_star_text
    },
    atb_vit_apt = {
      value = bo2.eFlag_Pet_VitGrowth,
      basic = bo2.eFlag_Pet_VitGrowth,
      on_make_text = on_make_star_text
    },
    atb_ske_apt = {
      value = bo2.eFlag_Pet_SkeGrowth,
      basic = bo2.eFlag_Pet_SkeGrowth,
      on_make_text = on_make_star_text
    },
    atb_gen_gro = {
      value = bo2.eFlag_Pet_GenGrowth,
      basic = bo2.eFlag_Pet_GenGrowth,
      on_make_text = on_make_star_text
    },
    atb_use_skill = {
      value = bo2.eFlag_Pet_UseableGeniusPoint,
      limit = bo2.eFlag_Pet_SumGeniusPoint
    },
    atb_use_pot = {
      value = bo2.eFlag_Pet_PotentialGeniusPoint
    },
    atb_take_level = {
      value = bo2.eFlag_Pet_TakeLevel
    },
    atb_kidney = {
      value = bo2.eFlag_Pet_Kidney,
      on_make_text = on_make_kidney_text
    },
    atb_phy_antilv = {
      value = bo2.eAtb_PhyDefendLv,
      on_make_tip = ui_pet.on_make_tip_defend
    },
    atb_mag_antilv = {
      value = bo2.eAtb_MgcDefendLv,
      on_make_tip = ui_pet.on_make_tip_defend
    },
    atb_phy_attacklv = {
      value = bo2.eAtb_PhyAttackLv,
      on_make_tip = ui_pet.on_make_tip_attack
    },
    atb_mag_attacklv = {
      value = bo2.eAtb_MgcAttackLv,
      on_make_tip = ui_pet.on_make_tip_attack
    },
    atb_phy_hitlv = {
      value = bo2.eAtb_PhyHitLv,
      on_make_tip = ui_pet.on_make_tip_hit
    },
    atb_mag_hitlv = {
      value = bo2.eAtb_MgcHitLv,
      on_make_tip = ui_pet.on_make_tip_hit
    },
    atb_phy_deadlv = {
      value = bo2.eAtb_PhyDeadLv,
      on_make_tip = ui_pet.on_make_tip_dead
    },
    atb_mag_deadlv = {
      value = bo2.eAtb_MgcDeadLv,
      on_make_tip = ui_pet.on_make_tip_dead
    },
    atb_mov_lev = {
      value = bo2.eAtb_TransferLv,
      on_make_tip = ui_pet.on_make_tip_transfer
    },
    atb_tou_lev = {
      value = bo2.eAtb_TenacityLv,
      on_make_tip = ui_pet.on_make_tip_tenacity
    },
    atb_nicety_lv = {
      value = bo2.eAtb_NicetyLv,
      on_make_tip = ui_pet.on_make_tip_nicety
    }
  }
  for n, v in pairs(atb_def) do
    v.name = n
    v.title = ui.get_text("pet|name_" .. n)
    v.tip = ui.get_text("pet|tip_" .. n)
    if v.on_make_text == nil then
      if v.limit ~= nil then
        v.on_make_text = on_make_limit_text
      elseif v.range ~= nil then
        v.on_make_text = on_make_range_text
      else
        v.on_make_text = on_make_value_text
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
end
function on_make_limit_text(pet, atb)
  return sys.format("%d/%d", pet:get_atb(atb.value), pet:get_atb(atb.limit))
end
function on_make_range_text(pet, atb)
  return sys.format("%d-%d", pet:get_atb(atb.value), pet:get_atb(atb.range))
end
function on_make_name_text(pet_info, atb)
  if pet_info ~= nil then
    ui_pet.ui_pet_info.w_pet_name.text = pet_info.name
  end
end
function set_pet_only_id(pet_info)
  if pet_info ~= nil then
    ui_pet.ui_pet_info.w_pet_only_id.text = sys.format("%I64X", pet_info.only_id)
  end
end
function set_mate_only_id(pet_info)
  if pet_info ~= nil then
    ui_pet.ui_pet_info.w_pet_mate_only_id.text = sys.format("%I64X", pet_info.mate_id)
  end
end
function set_pet_liability(pet_info)
  if pet_info ~= nil then
    local liability = pet_info:get_atb(bo2.eFlag_Pet_Liability)
    local text = ui.get_text(sys.format("common|pet_liability%d", liability))
    w_pet_liability.text = text
  end
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
    w_pet_exp.dx = 248 * (exp_current / exp_total)
  end
  return sys.format("%d/%d", exp_current, exp_total)
end
function on_make_exp_tip(pet, atb)
  local lev = pet:get_atb(bo2.eFlag_Pet_Level)
  local exp_current = pet:get_atb(bo2.eFlag_Pet_Exp)
  local exp_total = 0
  ui.log("11" .. exp_current)
  if lev == 0 then
    exp_current = 0
  else
    local level = bo2.gv_pet_levelup:find(lev)
    if level == nil then
      exp_total = 10000000
    else
      exp_total = level.exp
    end
  end
  local text = ui.get_text("pet|tip_atb_exp")
  ui.log("22" .. exp_current)
  return sys.format("%s: %d/%d", text, exp_current, exp_total)
end
local cs_rate_format1 = SHARED("%.2g")
local cs_rate_format10 = SHARED("%.3g")
local cs_rate_format100 = SHARED("%.4g")
local cs_rate_format1000 = SHARED("%.5g")
local cs_rate_format_minus = SHARED("-")
function make_rate(v)
  if v < 0 then
    return cs_rate_format_minus .. make_rate(-v)
  end
  if v < 1 then
    return sys.format(cs_rate_format1, v)
  elseif v < 10 then
    return sys.format(cs_rate_format10, v)
  elseif v < 100 then
    return sys.format(cs_rate_format100, v)
  else
    return sys.format(cs_rate_format1000, v)
  end
end
local c_format_rate = SHARED(sys.format(L("<c+:%s>%%s%%%%<c->"), value_color_add))
local c_format_value = SHARED(sys.format(L("<c+:%s>%%.2g<c->"), value_color_add))
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
function on_atb_tip_make(tip)
  local atb = atb_def[tostring(tip.owner.name)]
  if atb == nil then
    return
  end
  local text = atb.on_make_tip(g_pet_info, atb)
  ui_widget.tip_make_view(tip.view, text)
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
function update_pet_atb(pet)
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
end
init_once()
c_text_item_file = ui_pet.c_text_item_file
c_text_item_cell = ui_pet.c_text_item_cell
c_skill_cell = ui_pet.c_skill_cell
c_ability_cell = ui_pet.c_ability_cell
c_hole_file = ui_pet.c_hole_file
c_hole_cell = ui_pet.c_hole_cell
c_box_size_x = ui_pet.c_box_size_x
c_box_size_y = ui_pet.c_box_size_y
c_box_count = ui_pet.c_box_count
c_box_margin = ui_pet.c_box_margin
c_cell_size = ui_pet.c_cell_size
c_box_fight_skill_size_x = ui_pet.c_box_fight_skill_size_x
c_box_fight_skill_size_y = ui_pet.c_box_fight_skill_size_y
c_box_zb_skill_size_x = ui_pet.c_box_zb_skill_size_x
c_box_zb_skill_size_y = ui_pet.c_box_zb_skill_size_y
c_box_genius_size_x = ui_pet.c_box_genius_size_x
c_box_genius_size_y = ui_pet.c_box_genius_size_y
c_fight_skill = ui_pet.c_fight_skill
c_zb_skill = ui_pet.c_zb_skill
c_genius_skill = ui_pet.c_genius_skill
function update_hole(pet)
  if pet == nil then
    ui.log("pet is nil in update_pet_skill")
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
        local kidney = card.kidney
        hole.image = sys.format("$image/pet/kidney%d.png", kidney)
        hole.visible = true
      end
    end
  end
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
      local bg = ui.create_control(w_cells, "panel")
      bg:load_style(c_hole_file, c_hole_cell)
      bg.offset = ui.point(i * c_cell_size, r * c_cell_size)
      local hole = bg:search("hole")
      hole.name = sys.format("hole:%d", grid)
      hole.visible = false
    end
  end
  ctrl.name = sys.format("box:%d", box)
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
      local bg = ui.create_control(w_cells, "panel")
      bg:load_style(c_hole_file, c_hole_cell)
      bg.offset = ui.point(i * c_cell_size, r * c_cell_size)
      local hole = bg:search("hole")
      hole.name = sys.format("hole:%d", grid)
      hole.visible = false
    end
  end
  ctrl.name = sys.format("box:%d", box)
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
  ctrl.name = sys.format("box:%d", box)
end
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
function on_set_default_name(pet_info, atb)
  if pet_info ~= nil then
    local name = pet_info.excel.name
    local val = pet_info:get_atb(bo2.eFlag_Pet_Kind)
    local v = sys.variant()
    local kind = ui.get_text(sys.format("common|pet_kind%d", val))
    v:set("name", name)
    local show = sys.mtf_merge(v, kind)
    w_title.text = show
  end
  local star_num = 0
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
  local gen_atb = {
    value = bo2.eFlag_Pet_GenGrowth
  }
  local liability = pet_info:get_atb(bo2.eFlag_Pet_Liability)
  star_num = ui_pet.get_star_num(pet_info, gen_atb)
  if liability == 1 then
    star_num = star_num + ui_pet.get_star_num(pet_info, str_atb)
  elseif liability == 2 then
    star_num = star_num + ui_pet.get_star_num(pet_info, int_atb)
  elseif liability == 3 then
    star_num = star_num + ui_pet.get_star_num(pet_info, vit_atb)
  end
  if star_num >= 1 and star_num <= 4 then
    w_title.xcolor = ui_pet.name_color_white
  elseif star_num >= 5 and star_num <= 8 then
    w_title.xcolor = ui_pet.name_color_green
  elseif star_num >= 9 and star_num <= 12 then
    w_title.xcolor = ui_pet.name_color_blue
  elseif star_num >= 13 and star_num <= 16 then
    w_title.xcolor = ui_pet.name_color_purple
  else
    w_title.xcolor = ui_pet.name_color_golden
  end
end
function on_close(btn)
  local w = ui.find_control("$frame:pet_info")
  w.visible = false
end
function on_close_skill(btn)
  local parent = btn.parent.parent
  parent.visible = false
end
function set_visible(vis, pet_only_id)
  if vis == true then
    local pet = ui.pet_find(pet_only_id)
    if pet == nil then
      return
    end
    g_pet_info = pet
    update_pet_atb(pet)
    set_pet_info(pet)
    local owner_index = ui.pet_get_owner_index_by_id(pet_only_id)
    local box = ui.pet_get_box_by_id(pet_only_id)
    set_pet_skill(owner_index, box)
    update_hole(pet)
  end
  local w = ui.find_control("$frame:pet_info")
  w.visible = vis
  w:move_to_head()
  local p_pet = w:search("p_pet")
  p_pet.visible = w.visible
  local p_skill_view = w:search("p_skill_view")
  p_skill_view.visible = w.visible
end
function show_info(pet_only_id)
  set_visible(true, pet_only_id)
end
