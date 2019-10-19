value_color_cmn = L("FFFFFFFF")
value_color_equ = L("FFE4AE09")
value_color_add = L("FF22AA66")
value_color_sub = L("FFFF2D58")
name_color_white = L("FFFFFFFF")
name_color_green = L("FF00FF00")
name_color_blue = L("FF0000FF")
name_color_purple = L("FF940EE1")
name_color_golden = L("FFE1E914")
c_warning_color = L("FFFF0000")
g_pet_info = nil
g_only_id = nil
local ui_tab = ui_widget.ui_tab
g_pet_open_only_id = nil
c_fight_skill = 0
c_zb_skill = 1
c_genius_skill = 2
c_card_data_init = 0
function insert_tab(tab, name)
  local btn_uri = "$frame/pet/pet.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/pet/pet.xml"
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
function on_pet_update(pet_info)
  ui.log("on_pet_update")
  if pet_info.box == bo2.ePetBox_Player and pet_info == g_pet_info then
    local pet = ui.pet_find(pet_info.only_id)
    update_pet_atb(pet)
    set_pet_info(pet)
    local idx = ui.pet_get_index(pet_info.only_id, bo2.ePetBox_Player)
    set_pet_skill(idx, pet.box)
    update_pet_skill(pet)
    ui_pet.ui_pet_common.update_pet_atb(pet)
  else
  end
  ui_pet.ui_pet_common.on_pet_update(pet_info)
end
function on_pet_insert(pet_info)
  if pet_info.box == bo2.ePetBox_Player then
    pet_info:insert_on_update("ui_pet.on_pet_update", "ui_pet:on_pet_update")
    pet_info:insert_on_update("ui_pet.ui_pet_list.on_pet_update", "ui_pet.ui_pet_list:on_pet_update")
    g_pet_info = pet_info
    g_only_id = pet_info.only_id
    update_pet_atb(pet_info)
    update_pet_skill(pet_info)
    local index = ui.pet_get_index(pet_info.only_id, bo2.ePetBox_Player)
    set_select_by_idx(index)
    ui_pet.ui_pet_common.on_pet_insert(pet_info)
  end
end
function set_pet_info(pet_info)
  on_set_default_name(pet_info)
  on_make_name_text(pet_info)
  set_pet_only_id(pet_info)
  set_mate_only_id(pet_info)
  set_pet_liability(pet_info)
  set_pet_state(pet_info)
  set_pet_face(pet_info)
end
function on_pet_remove(pet_info)
  if pet_info.box == bo2.ePetBox_Player then
    local size = ui.pet_get_box_size(bo2.ePetBox_Player)
    if size == 0 then
      clear_all_pet_info()
      ui_pet.ui_pet_common.on_pet_remove(pet_info)
      return
    end
    set_select_by_idx(0)
  end
  ui_pet.ui_pet_common.on_pet_remove(pet_info)
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
        card.kidney = c_card_data_init
      end
    end
  end
end
function clear_all_pet_info()
  g_pet_info = nil
  g_only_id = nil
  update_pet_atb(init_pet)
  clear_pet_skill_info()
  if ui_pet.w_pet_name ~= nil then
    ui_pet.w_pet_name.text = ""
  end
  if w_pet_only_id ~= nil then
    w_pet_only_id.text = "0"
  end
  if w_title ~= nil then
    w_title.text = ""
  end
  if w_pet_liability ~= nil then
    w_pet_liability.text = ""
  end
  if w_pet_mate_only_id ~= nil then
    w_pet_mate_only_id.text = "0"
  end
  if w_pet_exp ~= nil then
    w_pet_exp.dx = 0
  end
  w_pet_openclose.text = ui.get_text(sys.format("pet|pet_open"))
end
function bind_pet(pet)
  local scn = w_scn.scn
  scn:clear_obj(bo2.eScnObjKind_Pet)
  local p = scn:create_obj(bo2.eScnObjKind_Pet, pet:get_atb(bo2.eFlag_Pet_ChaID))
end
local f_rot_factor = 0.04
function on_doll_rotl_click(btn)
  local scn = w_scn.scn
  scn:change_angle_x(-f_rot_factor)
end
function on_doll_rotr_click(btn)
  local scn = w_scn.scn
  scn:change_angle_x(f_rot_factor)
end
function init_once()
  atb_def = {
    atb_default_name = {},
    atb_name = {},
    atb_sex = {
      value = bo2.eFlag_Pet_Sex,
      on_make_text = on_make_sex_text,
      on_make_tip = on_make_sex_tip
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
      on_make_tip = on_make_tip_defend
    },
    atb_mag_antilv = {
      value = bo2.eAtb_MgcDefendLv,
      on_make_tip = on_make_tip_defend
    },
    atb_phy_attacklv = {
      value = bo2.eAtb_PhyAttackLv,
      on_make_tip = on_make_tip_attack
    },
    atb_mag_attacklv = {
      value = bo2.eAtb_MgcAttackLv,
      on_make_tip = on_make_tip_attack
    },
    atb_phy_hitlv = {
      value = bo2.eAtb_PhyHitLv,
      on_make_tip = on_make_tip_hit
    },
    atb_mag_hitlv = {
      value = bo2.eAtb_MgcHitLv,
      on_make_tip = on_make_tip_hit
    },
    atb_phy_deadlv = {
      value = bo2.eAtb_PhyDeadLv,
      on_make_tip = on_make_tip_dead
    },
    atb_mag_deadlv = {
      value = bo2.eAtb_MgcDeadLv,
      on_make_tip = on_make_tip_dead
    },
    atb_mov_lev = {
      value = bo2.eAtb_TransferLv,
      on_make_tip = on_make_tip_transfer
    },
    atb_tou_lev = {
      value = bo2.eAtb_TenacityLv,
      on_make_tip = on_make_tip_tenacity
    },
    atb_nicety_lv = {
      value = bo2.eAtb_NicetyLv,
      on_make_tip = on_make_tip_nicety
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
        v.on_make_tip = on_make_basic_tip
      else
        v.on_make_tip = on_make_tip
      end
    end
  end
  atb_reg = {}
  init_pet = {
    [bo2.eFlag_Pet_Sex] = 0,
    [bo2.eFlag_Pet_StrGrowth] = 0,
    ["get_atb"] = function(obj, idx)
      local v = obj[idx]
      if v == nil then
        return 0
      end
      return v
    end
  }
end
function get_pet_info()
  return g_pet_info
end
function get_name_color(pet_info)
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
  star_num = get_star_num(pet_info, gen_atb)
  if liability == 1 then
    star_num = star_num + get_star_num(pet_info, str_atb)
  elseif liability == 2 then
    star_num = star_num + get_star_num(pet_info, int_atb)
  elseif liability == 3 then
    star_num = star_num + get_star_num(pet_info, vit_atb)
  end
  ui.log("star_num:" .. star_num)
  if star_num >= 1 and star_num <= 4 then
    return name_color_white
  elseif star_num >= 5 and star_num <= 8 then
    return name_color_green
  elseif star_num >= 9 and star_num <= 12 then
    return name_color_blue
  elseif star_num >= 13 and star_num <= 16 then
    return name_color_purple
  else
    return name_color_golden
  end
  return name_color_white
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
  local color = get_name_color(pet_info)
  w_title.xcolor = color
end
function on_make_name_text(pet_info, atb)
  if pet_info ~= nil then
    ui_pet.w_pet_name.text = pet_info.name
  end
  ui_pet.ui_pet_common.set_pet_name(pet_info)
end
function set_pet_face(pet_info)
  local loyal = pet_info:get_atb(bo2.eFlag_Pet_Loyal)
  local flag = 0
  if loyal < 2000 then
    flag = 0
  elseif loyal < 5000 then
    flag = 1
  elseif loyal < 11000 then
    flag = 2
  elseif loyal < 15000 then
    flag = 3
  else
    flag = 4
  end
  w_face.image = sys.format("$gui/image/pet/face_%d.png", flag)
end
function set_pet_only_id(pet_info)
  if pet_info ~= nil then
    w_pet_only_id.text = sys.format("%I64X", pet_info.only_id)
  end
end
function set_mate_only_id(pet_info)
  if pet_info ~= nil then
    w_pet_mate_only_id.text = sys.format("%I64X", pet_info.mate_id)
  end
end
function set_pet_liability(pet_info)
  if pet_info ~= nil then
    local liability = pet_info:get_atb(bo2.eFlag_Pet_Liability)
    local text = ui.get_text(sys.format("common|pet_liability%d", liability))
    w_pet_liability.text = text
  end
end
function set_pet_state(pet_info)
  if pet_info ~= nil then
    local state = pet_info:get_atb(bo2.eFlag_Pet_State)
    if state == bo2.ePet_StateRelax then
      w_pet_openclose.text = ui.get_text(sys.format("pet|pet_open"))
    else
      w_pet_openclose.text = ui.get_text(sys.format("pet|pet_close"))
    end
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
  if pet == nil then
    w_pet_exp.dx = 0
  end
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
  if pet == nil then
    return
  end
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
  end
  local text = ui.get_text("pet|tip_atb_exp")
  return sys.format("%s: %d/%d", text, exp_current, exp_total)
end
function get_star_num(pet, atb)
  if pet == nil then
    return 0
  end
  local kind = pet:get_atb(bo2.eFlag_Pet_Kind)
  local excel = pet.excel
  if excel == nil then
    return 0
  end
  local adult = false
  local val = pet:get_atb(atb.value)
  if kind == bo2.ePet_KindAdult then
    val = val * (1 / excel.adult_odds)
  elseif kind == bo2.ePet_KindNextGen then
    local cha_id = pet:get_atb(bo2.eFlag_Pet_ExcelID)
    local idx = 0
    for i = 0, excel.next_gen_cha.size - 1 do
      if cha_id == excel.next_gen_cha[i] then
        idx = i
      end
    end
    val = val * (1 / excel.next_gen_val[idx])
  elseif kind == bo2.ePet_KindAberrance then
    local cha_id = pet:get_atb(bo2.eFlag_Pet_ExcelID)
    local idx = 0
    for i = 0, excel.aberrance_cha.size - 1 do
      if cha_id == excel.aberrance_cha[i] then
        idx = i
      end
    end
    val = val * (1 / excel.aberrance_odds[idx])
  end
  local tmpl = bo2.gv_pet_tmpl:find(excel.liability)
  if tmpl == nil then
    return 0
  end
  if val == 0 then
    return 0
  end
  if atb.value == bo2.eFlag_Pet_StrGrowth then
    local base_str_growth = tmpl.str_growth
    local str_growth_add = tmpl.str_growth_val
    for i = 0, str_growth_add.size - 1 do
      if val <= base_str_growth + str_growth_add[i] then
        if adult then
          if i == 0 then
            return 0
          end
          return math.floor((i + 1) / 2)
        end
        return i + 1
      end
    end
    if val >= base_str_growth + str_growth_add[str_growth_add.size - 1] then
      return str_growth_add.size
    end
    return 0
  elseif atb.value == bo2.eFlag_Pet_IntGrowth then
    local base_int_growth = tmpl.int_growth
    local int_growth_add = tmpl.int_growth_val
    for i = 0, int_growth_add.size - 1 do
      if val <= base_int_growth + int_growth_add[i] then
        if adult then
          if i == 0 then
            return 0
          end
          return math.floor((i + 1) / 2)
        end
        return i + 1
      end
    end
    if val >= base_int_growth + int_growth_add[int_growth_add.size - 1] then
      return int_growth_add.size
    end
    return 0
  elseif atb.value == bo2.eFlag_Pet_AgiGrowth then
    local base_agi_growth = tmpl.agi_growth
    local agi_growth_add = tmpl.agi_growth_val
    for i = 0, agi_growth_add.size do
      if val <= base_agi_growth + agi_growth_add[i] then
        if adult then
          if i == 0 then
            return 0
          end
          return math.floor((i + 1) / 2)
        end
        return i + 1
      end
    end
    if val >= base_agi_growth + agi_growth_add[agi_growth_add.size - 1] then
      return agi_growth_add.size
    end
    return 0
  elseif atb.value == bo2.eFlag_Pet_VitGrowth then
    local base_vit_growth = tmpl.vit_growth
    local vit_growth_add = tmpl.vit_growth_val
    for i = 0, vit_growth_add.size - 1 do
      if val <= base_vit_growth + vit_growth_add[i] then
        if adult then
          if i == 0 then
            return 0
          end
          return math.floor((i + 1) / 2)
        end
        return i + 1
      end
    end
    if val >= base_vit_growth + vit_growth_add[vit_growth_add.size - 1] then
      return vit_growth_add.size
    end
    return 0
  elseif atb.value == bo2.eFlag_Pet_SkeGrowth then
    local base_ske_growth = tmpl.ske_growth
    local ske_growth_add = tmpl.ske_growth_val
    for i = 1, ske_growth_add.size do
      if val <= base_ske_growth + ske_growth_add[i] then
        if adult then
          if i == 0 then
            return 0
          end
          return math.floor((i + 1) / 2)
        end
        return i + 1
      end
    end
    if val >= base_ske_growth + ske_growth_add[ske_growth_add.size - 1] then
      return ske_growth_add.size
    end
    return 0
  elseif atb.value == bo2.eFlag_Pet_GenGrowth then
    local pet_list = bo2.gv_pet_list:find(pet.excel_id)
    local base_gen_growth = pet_list.gen_growth
    local gen_growth_add = pet_list.gen_growth_val
    for i = 1, gen_growth_add.size - 1 do
      if val <= base_gen_growth + gen_growth_add[i] then
        if adult then
          if i == 0 then
            return 0
          end
          return math.floor((i + 1) / 2)
        end
        return i + 1
      end
    end
    if val >= base_gen_growth + gen_growth_add[gen_growth_add.size - 1] then
      return gen_growth_add.size
    end
    return 0
  end
  return 0
end
function get_star_max(pet, atb)
  local kind = pet:get_atb(bo2.eFlag_Pet_Kind)
  local val = pet:get_atb(atb.value)
  local tmpl = bo2.gv_pet_tmpl:find(pet.excel.liability)
  if tmpl == nil then
    return 0
  end
  if atb.value == bo2.eFlag_Pet_StrGrowth then
    return tmpl.str_growth_val.size
  elseif atb.value == bo2.eFlag_Pet_IntGrowth then
    return tmpl.int_growth_val.size
  elseif atb.value == bo2.eFlag_Pet_AgiGrowth then
    return tmpl.agi_growth_val.size
  elseif atb.value == bo2.eFlag_Pet_VitGrowth then
    return tmpl.vit_growth_val.size
  elseif atb.value == bo2.eFlag_Pet_SkeGrowth then
    return tmpl.ske_growth_val.size
  elseif atb.value == bo2.eFlag_Pet_GenGrowth then
    local pet_list = bo2.gv_pet_list:find(pet.excel_id)
    return pet_list.gen_growth_val.size
  end
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
  local star_num = 0
  local star_max = 0
  if val ~= 0 then
    star_num = get_star_num(pet, atb)
    star_max = get_star_max(pet, atb) / 2
  end
  if reg ~= nil then
    local star = reg.label.parent:search("star")
    star.dx = 16 * star_num / 2
    local star_bg = reg.label.parent:search("star_max")
    star_bg.dx = 16 * star_max
  end
  return val
end
function on_make_value_text(pet, atb)
  if pet == nil then
    return
  end
  local basic = atb.basic
  local v_atb = pet:get_atb(atb.value)
  if basic == nil then
    return L(v_atb), value_color_cmn
  end
  local b_atb = pet:get_atb(basic)
  if v_atb > b_atb then
    return L(v_atb), value_color_add
  end
  if v_atb < b_atb then
    return L(v_atb), value_color_sub
  end
  return L(v_atb), value_color_equ
end
function on_make_tip(pet, atb)
  return atb.tip
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
function on_atb_tip_make(tip)
  local atb = atb_def[tostring(tip.owner.name)]
  if atb == nil then
    return
  end
  local text = atb.on_make_tip(g_pet_info, atb)
  ui_widget.tip_make_view(tip.view, text)
end
function on_make_tip_attack(pet, atb)
  if pet == nil then
    return
  end
  local v = sys.variant()
  v:set("n", pet:get_atb(atb.value) / 20)
  return sys.mtf_merge(v, atb.tip)
end
function on_make_tip_defend(pet, atb)
  if pet == nil then
    return
  end
  local v = sys.variant()
  v:set("n", pet:get_atb(atb.value) / 25)
  return sys.mtf_merge(v, atb.tip)
end
function on_make_tip_gro(pet, atb)
end
local c_format_equ = sys.format(L("<c+:%s>%%d<c->"), value_color_equ)
local c_format_add = sys.format(L("<c+:%s>%%d<c->(<c+:%s>%%d<c->+<c+:%s>%%d<c->)"), value_color_add, value_color_equ, value_color_add)
local c_format_sub = sys.format(L("<c+:%s>%%d<c->(<c+:%s>%%d<c->-<c+:%s>%%d<c->)"), value_color_sub, value_color_equ, value_color_sub)
local c_format_transfer = SHARED(sys.format(L("<c+:%s>%%.2g%%%%<c->(<c+:%s>%%.2g%%%%<c->+<c+:%s>%%.2g%%%%<c->)"), value_color_add, value_color_add, value_color_add))
function on_make_tip_hit(pet, atb)
  if pet == nil then
    return
  end
  local r = 0
  if atb.value == bo2.eAtb_PhyHitLv then
    r = pet:get_atb(bo2.eAtb_PhyHitRate)
  else
    r = pet:get_atb(bo2.eAtb_MgcHitRate)
  end
  r = r / 100
  local n = pet:get_atb(atb.value)
  local lv = pet:get_atb(bo2.eFlag_Pet_Level)
  n = n / (n * 1.4 + 30 * lv + 480) * 100
  local t = r + n
  local v = sys.variant()
  v:set("n", sys.format(c_format_transfer, t, r, n))
  return sys.mtf_merge(v, atb.tip)
end
function on_make_tip_dead(pet, atb)
  if pet == nil then
    return
  end
  local r = 0
  if atb.value == bo2.eAtb_PhyDeadLv then
    r = pet:get_atb(bo2.eAtb_PhyHit)
  else
    r = pet:get_atb(bo2.eAtb_MgcHit)
  end
  r = r / 100
  local v = sys.variant()
  local n = pet:get_atb(atb.value)
  local lv = pet:get_atb(bo2.eFlag_Pet_Level)
  local val = 150 + r + n / (n * 0.5 + 7.5 * lv) * 100
  v:set("n", sys.format(c_format_rate, make_rate(val)))
  return sys.mtf_merge(v, atb.tip)
end
function on_make_tip_tenacity(pet, atb)
  if pet == nil then
    return
  end
  local v = sys.variant()
  local n = pet:get_atb(atb.value)
  local lv = pet:get_atb(bo2.eFlag_Pet_Level)
  local n1 = n * 75 / (n * 0.75 * 1.4 + 30 * lv + 480)
  local n2 = n * 50 / (n * 0.5 * 0.5 + 7.5 * lv)
  v:set("n1", sys.format(c_format_rate, make_rate(n1)))
  v:set("n2", sys.format(c_format_rate, make_rate(n2)))
  return sys.mtf_merge(v, atb.tip)
end
function on_make_tip_nicety(pet, atb)
  if pet == nil then
    return
  end
  local v = sys.variant()
  local n = pet:get_atb(atb.value)
  local lv = pet:get_atb(bo2.eFlag_Pet_Level)
  local val = n / (n + 28 * lv + 160) * 100
  v:set("n", sys.format(c_format_rate, make_rate(val)))
  return sys.mtf_merge(v, atb.tip)
end
function on_make_tip_transfer(pet, atb)
  if pet == nil then
    return
  end
  local r = pet:get_atb(bo2.eAtb_TransferRate) / 100
  local n = pet:get_atb(atb.value)
  local lv = pet:get_atb(bo2.eFlag_Pet_Level)
  n = n / (n + 28 * lv + 160) * 100
  local t = r + n
  local v = sys.variant()
  v:set("n", sys.format(c_format_transfer, t, r, n))
  return sys.mtf_merge(v, atb.tip)
end
function on_make_sex_tip(pet, atb)
  local sex = pet:get_atb(atb.value)
  local text = ui.get_text("common|pet_sex" .. sex)
  return text
end
function on_make_limit_text(pet, atb)
  if pet == nil then
    return
  end
  return sys.format("%d/%d", pet:get_atb(atb.value), pet:get_atb(atb.limit))
end
function on_make_range_text(pet, atb)
  if pet == nil then
    return
  end
  return sys.format("%d-%d", pet:get_atb(atb.value), pet:get_atb(atb.range))
end
function on_make_basic_tip(pet, atb)
  if pet == nil then
    ui.log("tip:pet is nil")
    return ""
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
    stk:format(c_format_add, v_atb, b_atb, v_atb - b_atb)
  elseif v_atb < b_atb then
    stk:format(c_format_sub, v_atb, b_atb, b_atb - v_atb)
  else
    stk:format(c_format_equ, v_atb)
  end
  stk:push("\n")
  stk:push(atb.tip)
  return stk.text
end
function set_pet_visible(b)
  local w = ui.find_control("$frame:pet")
  w.visible = b
end
function on_pet_close()
  set_pet_visible(false)
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
c_zb_skill_color_file = L("$image/pet/kidney")
function update_pet_skill(pet)
  if pet == nil then
    ui.log("pet is nil in update_pet_skill,pet.lua")
    return
  end
  ui.log("pet_only_id:%s", pet.only_id)
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
        hole.area = ui.rect(0, 0, 38, 38)
        hole.visible = true
      end
    end
  end
end
function update_atb(atbId, atbValue)
  for n, v in pairs(atb_reg) do
    if v.value == atbId then
    end
  end
end
function on_observable(w, vis)
  if not vis then
    return
  end
  if g_pet_info ~= nil then
    update_pet_atb(g_pet_info)
    set_pet_info(g_pet_info)
    update_pet_skill(g_pet_info)
  end
end
c_text_item_file = L("$frame/pet/cmn.xml")
c_text_item_cell = L("item_cell")
c_skill_cell = L("skill_cell")
c_ability_cell = L("ability_cell")
c_hole_file = L("$frame/pet/cmn.xml")
c_hole_cell = L("skill_hole")
c_box_size_x = 6
c_box_size_y = 1
c_box_count = 3
c_box_margin = 2
c_cell_size = 36
c_box_fight_skill_size_x = 4
c_box_fight_skill_size_y = 1
c_box_zb_skill_size_x = 4
c_box_zb_skill_size_y = 3
c_box_genius_size_x = 4
c_box_genius_size_y = 3
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
      d:insert_on_mouse(on_card_mouse, "ui_pet.on_card_mouse")
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
  w_cells.size = ui.point(c_box_fight_skill_size_x * c_cell_size + c_box_fight_skill_size_x * c_box_margin, c_box_fight_skill_size_y * c_cell_size + c_box_fight_skill_size_y * c_box_margin)
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
      d:insert_on_mouse(on_card_skill_mouse, "ui_pet.on_card_skill_mouse")
      local bg = ui.create_control(w_cells, "panel")
      bg:load_style(c_hole_file, c_hole_cell)
      bg.offset = ui.point(i * c_cell_size + i * c_box_margin, r * c_cell_size + r * c_box_margin)
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
      bg.offset = ui.point(i * c_cell_size + i * c_box_margin, r * c_cell_size + r * c_box_margin)
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
function set_select_by_idx(idx)
  local pet = ui.get_pet_by_index_box(idx, bo2.ePetBox_Player)
  if pet == nil then
    return
  end
  w_pet_portrait_frm.visible = true
  local x = c_cell_size * math.fmod(idx, c_box_size_x)
  local y = (1 + c_cell_size) * math.modf(idx / c_box_size_x)
  if y == 0 then
    y = 1
  end
  w_pet_portrait_frm.offset = ui.point(x - 3 + c_box_margin * idx, y - 2)
  g_pet_info = pet
  g_only_id = pet.only_id
  update_pet_atb(pet)
  set_pet_info(pet)
  local state = pet:get_atb(bo2.eFlag_Pet_State)
  if state == bo2.ePet_StateWorking then
    w_pet_openclose.text = ui.get_text(sys.format("pet|pet_close"))
  else
    w_pet_openclose.text = ui.get_text(sys.format("pet|pet_open"))
  end
  set_pet_skill(idx, pet.box)
  on_set_default_name(pet)
  update_pet_skill(pet)
end
function set_select_by_only_id(only_id)
  local pet = ui.pet_find(only_id)
  if pet == nil then
    set_select_by_idx(0)
    return
  end
  local idx = ui.pet_get_index(only_id, bo2.ePetBox_Player)
  w_pet_portrait_frm.visible = true
  local x = c_cell_size * math.fmod(idx, c_box_size_x)
  local y = (1 + c_cell_size) * math.modf(idx / c_box_size_x)
  if y == 0 then
    y = 1
  end
  w_pet_portrait_frm.offset = ui.point(x - 3 + c_box_margin * idx, y - 2)
  g_pet_info = pet
  g_only_id = pet.only_id
  update_pet_atb(pet)
  set_pet_info(pet)
  local state = pet:get_atb(bo2.eFlag_Pet_State)
  if state == bo2.ePet_StateWorking then
    w_pet_openclose.text = ui.get_text(sys.format("pet|pet_close"))
  else
    w_pet_openclose.text = ui.get_text(sys.format("pet|pet_open"))
  end
  set_pet_skill(idx, pet.box)
  on_set_default_name(pet)
  update_pet_skill(pet)
end
function on_card_mouse(card, msg, pos, wheel)
  local parent = card.parent
  local icon = card.icon
  if icon == nil then
    return
  end
  if msg == ui.mouse_lbutton_click then
    w_pet_portrait_frm.visible = true
    local x = c_cell_size * math.fmod(card.index, c_box_size_x)
    local y = (1 + c_cell_size) * math.modf(card.index / c_box_size_x)
    if y == 0 then
      y = 1
    end
    w_pet_portrait_frm.offset = ui.point(x - 3 + card.index * c_box_margin, y - 2)
    local pet = ui.pet_find(card.only_id)
    g_pet_info = pet
    g_only_id = pet.only_id
    update_pet_atb(pet)
    set_pet_info(pet)
    local state = pet:get_atb(bo2.eFlag_Pet_State)
    if state == bo2.ePet_StateWorking then
      w_pet_openclose.text = ui.get_text(sys.format("pet|pet_close"))
    else
      w_pet_openclose.text = ui.get_text(sys.format("pet|pet_open"))
    end
    set_pet_skill(card.index, pet.box)
    update_pet_skill(g_pet_info)
  end
  if msg == ui.mouse_lbutton_drag then
    ui.clean_drop()
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_PetPortrait)
    data:set("only_id", card.only_id)
    ui.set_cursor_icon(card.icon.uri)
    local on_drop_hook = function(w, msg, pos, data)
    end
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  end
end
function on_card_skill_mouse(card, msg, pos, wheel)
  if card.kind ~= 0 then
    return
  end
  if msg == ui.mouse_lbutton_dbl then
    if card.excel == nil then
      return
    end
    local state = g_pet_info:get_atb(bo2.eFlag_Pet_State)
    if state ~= bo2.ePet_StateWorking then
      ui_tool.note_insert(ui.get_text("pet|pet_manual_skill_warning"), ui_pet.c_warning_color)
      return
    end
    if card.excel == nil then
      return
    end
    bo2.pet_use_skill(card.excel.id)
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_drag then
    ui.clean_drop()
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_PetSkill)
    data:set("excel_id", card.excel.id)
    ui.set_cursor_icon(card.icon.uri)
    local on_drop_hook = function(w, msg, pos, data)
    end
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  end
end
function on_pet_pic_tip_show(tip)
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
function on_button_tip_show(tip)
  local owner = tip.owner
  local text = ui.get_text(sys.format("pet|%s", owner.name))
  ui_widget.tip_make_view(tip.view, text)
end
function on_open_pet_click(btn)
  if g_pet_info == nil then
    ui_tool.note_insert(ui.get_text("pet|pet_warning_select"), ui_pet.c_warning_color)
    return
  end
  local state = g_pet_info:get_atb(bo2.eFlag_Pet_State)
  local take_level = g_pet_info:get_atb(bo2.eFlag_Pet_TakeLevel)
  if take_level > bo2.player:get_atb(bo2.eAtb_Level) then
    ui_tool.note_insert(ui.get_text("pet|pet_level_warning"), ui_pet.c_warning_color)
    return
  end
  if state == bo2.ePet_StateWorking then
    send_close_pet()
    w_pet_openclose.text = ui.get_text(sys.format("pet|pet_open"))
    return
  end
  if state == bo2.ePet_StateRelax then
    if g_pet_info:get_atb(bo2.eFlag_Pet_Loyal) <= 0 then
      local v = sys.variant()
      v:set("pet_name", g_pet_info.name)
      local txt = sys.mtf_merge(v, ui.get_text("pet|pet_loyalzero_warning"))
      ui_tool.note_insert(txt, ui_pet.c_warning_color)
      return
    end
    send_open_pet(bo2.player.cha_name, g_pet_info.only_id)
    g_pet_open_only_id = g_only_id
    if bo2.player:IsDead() == false and bo2.scn.excel.pet_forbid == 0 then
      btn.text = ui.get_text(sys.format("pet|pet_close"))
    end
  end
  if state == bo2.ePet_StateReproduction then
    ui_tool.note_insert(ui.get_text("pet|pet_breed_warning"), ui_pet.c_warning_color)
  end
end
function on_pet_watch_click(btn)
  if g_pet_info == nil then
    ui_tool.note_insert(ui.get_text("pet|pet_warning_select"), ui_pet.c_warning_color)
    return
  end
  ui_pet.ui_pet_show.set_visible(false, 0)
  ui_pet.ui_pet_show.set_visible(true, g_only_id)
  ui_pet.ui_pet_show.set_visible(false, 0)
  ui_pet.ui_pet_show.set_visible(true, g_only_id)
end
function on_feed_pet_click(btn)
  local item_arr = {
    53701,
    53702,
    53703,
    53704,
    53705,
    53706,
    53707,
    53708,
    53709,
    53710
  }
  for i = 1, 10 do
    do
      local info = ui.item_of_excel_id(item_arr[i], bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd)
      if info ~= nil then
        local function send_impl()
          local v = sys.variant()
          v:set(packet.key.pet_only_id, g_only_id)
          v:set(packet.key.item_key, info.only_id)
          bo2.send_variant(packet.eCTS_UI_UseItem, v)
        end
        ui_item.try_send_use(info, send_impl)
        return
      end
    end
  end
  ui_tool.note_insert(ui.get_text("pet|pet_warning_no_drug"), ui_pet.c_warning_color)
end
function on_change_name_msg(msg)
  if msg == nil then
    ui.log("\202\228\200\235\181\196\214\181\206\170\191\213\163\161")
    return
  end
  if msg.result == 1 then
    if msg.input == sys.wstring("") then
      ui_tool.note_insert(ui.get_text("pet|pet_warning_chang_name"), ui_pet.c_warning_color)
      return
    end
    local err_name = ui.check_name(msg.input)
    if err_name ~= bo2.eNameCheck_ErrNone then
      ui_tool.note_insert(ui.get_text(sys.format("pet|err_name_%s", err_name)), ui_pet.c_warning_color)
      return
    end
    ui_pet.send_change_name(g_pet_info.only_id, msg.input)
  end
end
function on_change_name_click(btn)
  if g_pet_info == nil then
    ui_tool.note_insert(ui.get_text("pet|pet_warning_select"), ui_pet.c_warning_color)
    return
  end
  local msg = {
    callback = on_change_name_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    limit = 16
  }
  msg.text = sys.format("\199\235\202\228\200\235\210\170\208\222\184\196\181\196\195\251\179\198\163\186")
  msg.input = ""
  ui_widget.ui_msg_box.show_common(msg)
end
function on_delete_pet_msg(msg)
  if msg.result == 1 then
    send_delete_pet(g_pet_info.only_id)
    w_pet_portrait_frm.visible = false
  end
end
function on_free_pet_click(btn)
  if g_pet_info == nil then
    ui_tool.note_insert(ui.get_text("pet|pet_warning_select"), ui_pet.c_warning_color)
    return
  end
  local msg = {callback = on_delete_pet_msg}
  msg.text = sys.format("\202\199\183\241\210\170\183\197\198\250\179\232\206\239[%s]", g_pet_info.name)
  ui_widget.ui_msg_box.show_common(msg)
end
function on_del_pet_click(btn)
  if g_pet_info == nil then
    ui_tool.note_insert(ui.get_text("pet|pet_warning_select"), ui_pet.c_warning_color)
    return
  end
  if g_pet_info:get_atb(bo2.eFlag_Pet_State) == bo2.ePet_StateReproduction then
    ui_tool.note_insert(ui.get_text("pet|pet_warning_breed_del"), ui_pet.c_warning_color)
    return
  end
  local msg = {callback = on_delete_pet_msg}
  msg.text = sys.format("\202\199\183\241\210\170\183\197\198\250\179\232\206\239[%s]", g_pet_info.name)
  ui_widget.ui_msg_box.show_common(msg)
end
function on_open_skill_panel(btn)
  local close = btn.parent:search("btn_close_skill")
  close.visible = true
  local w = ui.find_control("$frame:pet")
  local p_skill_view = w:search("p_skill_view")
  p_skill_view.visible = true
  btn.visible = false
end
function on_close_skill_panel(btn)
  local open = btn.parent:search("btn_open_skill")
  open.visible = true
  local w = ui.find_control("$frame:pet")
  local p_skill_view = w:search("p_skill_view")
  p_skill_view.visible = false
  btn.visible = false
end
function get_pet_num()
  local num = 0
  local null = sys.wstring(0)
  for i = 0, c_box_size_y - 1 do
    for j = 0, c_box_size_x - 1 do
      local index = i * c_box_size_x + j
      local card = w_pet_portrait_box:search("w_cells"):search("grid:" .. index)
      if card.only_id ~= null then
        num = num + 1
      end
    end
  end
  return num
end
function on_close(btn)
  local w = ui.find_control("$frame:pet")
  w.visible = false
end
function on_close_skill(btn)
  local parent = btn.parent.parent
  parent.visible = false
end
function set_visible()
  local w = ui.find_control("$frame:pet")
  w.visible = not w.visible
  w:move_to_head()
  local p_pet = w:search("p_pet")
  p_pet.visible = w.visible
  local p_skill_view = w:search("p_skill_view")
  p_skill_view.visible = w.visible
  if w.visible == true then
    set_select_by_only_id(bo2.get_cur_pet_only_id())
  end
end
function on_esc_stk_visible(w, vis)
  local p_pet = w:search("p_pet")
  local p_skill_view = w:search("p_skill_view")
  if vis then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    p_pet.visible = vis
    p_skill_view.visible = vis
    if w.visible == true then
      set_select_by_only_id(bo2.get_cur_pet_only_id())
    end
  else
    ui_widget.esc_stk_pop(w)
    p_pet.visible = vis
    p_skill_view.visible = vis
  end
end
init_once()
ui.insert_pet_on_insert(on_pet_insert, "ui_pet:on_pet_insert")
ui.insert_pet_on_remove(on_pet_remove, "ui_pet:on_pet_remove")
