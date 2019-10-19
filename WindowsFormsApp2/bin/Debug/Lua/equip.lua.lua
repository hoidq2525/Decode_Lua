local ui_tab = ui_widget.ui_tab
value_color_cmn = SHARED("FFFFFFFF")
value_color_equ = SHARED("FFFFEECC")
value_color_add = SHARED("FF22AA66")
value_color_sub = SHARED("FFFF2D58")
local color_atb_common = SHARED("FFFFFFFF")
local color_atb_disable = SHARED("FF808080")
local color_green = SHARED("179317")
local color_white = SHARED("FFFFFF")
local atb_tab_btn_uri = SHARED("$frame/personal/common.xml")
local atb_tab_btn_sty = SHARED("common_tab_btn2")
local atb_tab_page_uri = SHARED("$frame/personal/equip.xml")
local atb_tab_page_sty = SHARED("atb_tab_page_")
local atb_tab_name_phy = SHARED("phy")
local atb_tab_name_mgc = SHARED("mgc")
local bag_slot_count = ui_item.c_box_size_x * ui_item.c_box_size_y
local star_num = 0
local min_enhance_level = 0
local open_slot_panel = false
slot_name_tab = {}
enhance_val_perLv = bo2.gv_define:find(889).value.v_number
enhance_lv_difference = bo2.gv_define:find(921).value.v_int
local ci_slot_enhance_cd = 5667
local function init_once()
  atb_def = {
    atb_level = {
      value = bo2.eAtb_Level,
      on_make_text = on_make_level_text
    },
    atb_sex = {
      value = bo2.eAtb_Sex,
      on_make_text = on_make_sex_text
    },
    atb_exp = {
      value = bo2.eAtb_Cha_Exp,
      on_make_text = on_make_exp_text
    },
    atb_career = {
      value = bo2.eAtb_Cha_Profession,
      on_make_text = on_make_career_text,
      on_make_tip = on_make_career_tip
    },
    atb_point = {
      value = bo2.eAtb_Cha_AtbPoint,
      on_make_tip = on_make_tip_atb_point
    },
    atb_vit = {
      value = bo2.eAtb_Vit,
      basic = bo2.eAtb_BaseVit,
      point = bo2.eAtb_Cha_VitPoint
    },
    atb_ske = {
      value = bo2.eAtb_Ske,
      basic = bo2.eAtb_BaseSke,
      point = bo2.eAtb_Cha_SkePoint
    },
    atb_agi = {
      value = bo2.eAtb_Agi,
      basic = bo2.eAtb_BaseAgi,
      point = bo2.eAtb_Cha_AgiPoint
    },
    atb_str = {
      value = bo2.eAtb_Str,
      basic = bo2.eAtb_BaseStr,
      point = bo2.eAtb_Cha_StrPoint
    },
    atb_int = {
      value = bo2.eAtb_Int,
      basic = bo2.eAtb_BaseInt,
      point = bo2.eAtb_Cha_IntPoint
    },
    atb_anti_puzzle = {
      value = bo2.eAtb_AntiPuzzle,
      on_make_tip = on_make_tip_anti
    },
    atb_anti_restricted = {
      value = bo2.eAtb_AntiRestricted,
      on_make_tip = on_make_tip_anti
    },
    atb_anti_drain = {
      value = bo2.eAtb_AntiDrain,
      on_make_tip = on_make_tip_anti
    },
    atb_anti_ebb = {
      value = bo2.eAtb_AntiEbb,
      on_make_tip = on_make_tip_anti
    },
    atb_anti_tumble = {
      value = bo2.eAtb_Cha_AntiTumble,
      on_make_tip = on_make_tip_anti
    },
    atb_anti_float = {
      value = bo2.eAtb_Cha_AntiFloat,
      on_make_tip = on_make_tip_anti
    },
    atb_anti_ridedown = {
      value = bo2.eAtb_Cha_AntiRideDown,
      on_make_tip = on_make_tip_anti
    },
    atb_anti_hitback = {
      value = bo2.eAtb_Cha_AntiHitBack,
      on_make_tip = on_make_tip_anti
    },
    atb_anti_hitfly = {
      value = bo2.eAtb_Cha_AntiHitFly,
      on_make_tip = on_make_tip_anti
    },
    atb_hp = {
      value = bo2.eAtb_HP,
      limit = bo2.eAtb_HPMax
    },
    atb_mp = {
      value = bo2.eAtb_MP,
      limit = bo2.eAtb_MPMax
    },
    atb_st = {
      value = bo2.eAtb_Cha_ST,
      limit = bo2.eAtb_Cha_STMax
    },
    atb_nq = {
      value = bo2.eAtb_Cha_NQ,
      limit = bo2.eAtb_Cha_NQMax
    },
    atb_tenacity = {
      value = bo2.eAtb_TenacityLv,
      on_make_tip = on_make_tip_tenacity
    },
    atb_transfer = {
      value = bo2.eAtb_TransferLv,
      on_make_tip = on_make_tip_transfer
    },
    atb_nicety = {
      value = bo2.eAtb_NicetyLv,
      on_make_tip = on_make_tip_nicety
    },
    atb_phy_def = {
      value = bo2.eAtb_PhyDefendLv,
      on_make_tip = on_make_tip_def
    },
    atb_phy_dmg = {
      value = bo2.eAtb_PhyDmgMin,
      range = bo2.eAtb_PhyDmgMax,
      on_make_tip = on_make_tip_dmg,
      title = ui.get_text("atb|name_atb_dmg")
    },
    atb_phy_atk = {
      value = bo2.eAtb_PhyAttackLv,
      on_make_tip = on_make_tip_atk,
      title = ui.get_text("atb|name_atb_atk")
    },
    atb_phy_hit = {
      value = bo2.eAtb_PhyHitLv,
      on_make_tip = on_make_tip_hit,
      title = ui.get_text("atb|name_atb_hit")
    },
    atb_phy_dead = {
      value = bo2.eAtb_PhyDeadLv,
      on_make_tip = on_make_tip_dead,
      title = ui.get_text("atb|name_atb_dead")
    },
    atb_mgc_def = {
      value = bo2.eAtb_MgcDefendLv,
      on_make_tip = on_make_tip_def
    },
    atb_mgc_dmg = {
      value = bo2.eAtb_MgcDmgMin,
      range = bo2.eAtb_MgcDmgMax,
      on_make_tip = on_make_tip_dmg,
      title = ui.get_text("atb|name_atb_dmg")
    },
    atb_mgc_atk = {
      value = bo2.eAtb_MgcAttackLv,
      on_make_tip = on_make_tip_atk,
      title = ui.get_text("atb|name_atb_atk")
    },
    atb_mgc_hit = {
      value = bo2.eAtb_MgcHitLv,
      on_make_tip = on_make_tip_hit,
      title = ui.get_text("atb|name_atb_hit")
    },
    atb_mgc_dead = {
      value = bo2.eAtb_MgcDeadLv,
      on_make_tip = on_make_tip_dead,
      title = ui.get_text("atb|name_atb_dead")
    },
    atb_speed = {
      value = bo2.eAtb_MoveSpeed
    },
    atb_dmg_score = {
      on_make_text = on_make_dmg_score_text,
      on_make_tip = on_make_tip_score,
      value_color = "22AA66"
    },
    atb_def_score = {
      on_make_text = on_make_def_score_text,
      on_make_tip = on_make_tip_score,
      value_color = "22AA66"
    },
    atb_fight_score = {
      on_make_text = on_make_fight_score_text,
      on_make_tip = on_make_tip_fight_score,
      value_color = "22AA66"
    }
  }
  for n, v in pairs(atb_def) do
    v.name = n
    if v.title == nil then
      v.title = ui.get_text("atb|name_" .. n)
    end
    v.tip = ui.get_text("atb|tip_" .. n)
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
  fake_player = build_fake_player()
  local se_tip = ui.create_control(ui.find_control("$phase:tool"), "panel")
  se_tip:load_style("$frame/personal/equip.xml", "slot_enhance_tip")
  open_slot_panel = false
end
function milestone_complete(milestone_id)
  if ui.quest_find_c(2036) then
    return true
  else
    local quest_info = ui.quest_find(2036)
    if quest_info ~= nil and (quest_info.mstone_id == 0 or milestone_id < quest_info.mstone_id) then
      return true
    end
  end
  return false
end
function build_lvmax_player(player)
  local lvmax = ui_widget.level_bind_scn()
  if lvmax == 0 then
    return player
  end
  local m = {
    __index = function(obj, idx)
      return player[idx]
    end,
    __newindex = function(obj, idx, val)
      player[idx] = val
    end
  }
  local p = {
    get_atb = function(obj, idx)
      if idx == bo2.eAtb_Level then
        return lvmax
      end
      return player:get_atb(idx)
    end
  }
  setmetatable(p, m)
  return p
end
function build_fake_player()
  local p = {
    atb_data = {
      [bo2.eAtb_ExcelID] = 2,
      [bo2.eAtb_Level] = 19,
      [bo2.eAtb_Sex] = 2,
      [bo2.eAtb_Cha_Exp] = 95999,
      [bo2.eAtb_Cha_Profession] = 4,
      [bo2.eAtb_Cha_AtbPoint] = 32,
      [bo2.eAtb_Vit] = 43,
      [bo2.eAtb_Ske] = 65,
      [bo2.eAtb_Agi] = 46,
      [bo2.eAtb_Str] = 34,
      [bo2.eAtb_Int] = 21,
      [bo2.eAtb_BaseVit] = 53,
      [bo2.eAtb_BaseSke] = 45,
      [bo2.eAtb_BaseAgi] = 46,
      [bo2.eAtb_BaseStr] = 35,
      [bo2.eAtb_BaseInt] = 11,
      [bo2.eAtb_AntiPuzzle] = 24,
      [bo2.eAtb_AntiRestricted] = 34,
      [bo2.eAtb_AntiDrain] = 18,
      [bo2.eAtb_AntiEbb] = 7,
      [bo2.eAtb_Cha_AntiTumble] = 9,
      [bo2.eAtb_Cha_AntiFloat] = 11,
      [bo2.eAtb_Cha_AntiRideDown] = 14,
      [bo2.eAtb_Cha_AntiHitBack] = 34,
      [bo2.eAtb_Cha_AntiHitFly] = 73,
      [bo2.eAtb_Cha_Luck] = 3,
      [bo2.eAtb_HP] = 63,
      [bo2.eAtb_HPMax] = 752,
      [bo2.eAtb_MP] = 77,
      [bo2.eAtb_MPMax] = 300,
      [bo2.eAtb_Cha_ST] = 46,
      [bo2.eAtb_Cha_STMax] = 654,
      [bo2.eAtb_Cha_NQ] = 19,
      [bo2.eAtb_Cha_NQMax] = 36,
      [bo2.eAtb_TenacityLv] = 11,
      [bo2.eAtb_TransferLv] = 12,
      [bo2.eAtb_NicetyLv] = 13,
      [bo2.eAtb_TransferRate] = 120,
      [bo2.eAtb_Cha_TransferEffect] = 2120,
      [bo2.eAtb_PhyDmgMin] = 52,
      [bo2.eAtb_PhyDmgMax] = 861,
      [bo2.eAtb_PhyDefendLv] = 345,
      [bo2.eAtb_PhyAttackLv] = 14,
      [bo2.eAtb_PhyHitLv] = 15,
      [bo2.eAtb_PhyDeadLv] = 16,
      [bo2.eAtb_PhyHitRate] = 16,
      [bo2.eAtb_PhyHit] = 1345,
      [bo2.eAtb_MgcDmgMin] = 62,
      [bo2.eAtb_MgcDmgMax] = 299,
      [bo2.eAtb_MgcDefendLv] = 334,
      [bo2.eAtb_MgcAttackLv] = 17,
      [bo2.eAtb_MgcHitLv] = 18,
      [bo2.eAtb_MgcDeadLv] = 19,
      [bo2.eAtb_MgcHitRate] = 36,
      [bo2.eAtb_MgcHit] = 2945,
      [bo2.eAtb_MoveSpeed] = 100
    },
    data_flag_int32 = {
      [bo2.eFlagInt32_CirculatedMoney] = 13514,
      [bo2.eFlagInt32_BoundedMoney] = 39425
    },
    name = ui.get_text("personal|feilong"),
    get_atb = function(obj, idx)
      local v = obj.atb_data[idx]
      if v == nil then
        return 0
      end
      return v
    end,
    get_flag_int32 = function(obj, idx)
      local v = obj.data_flag_int32[idx]
      if v == nil then
        return 0
      end
      return v
    end
  }
  return p
end
function on_init(ctrl)
  local slot_def = {
    wq = {
      equip = bo2.eItemSlot_MainWeapon
    },
    mz = {
      equip = bo2.eItemSlot_Hat
    },
    yf = {
      equip = bo2.eItemSlot_Body
    },
    kz = {
      equip = bo2.eItemSlot_Legs
    },
    yd = {
      equip = bo2.eItemSlot_Waist
    },
    xz = {
      equip = bo2.eItemSlot_Feet
    },
    wq2 = {
      equip = bo2.eItemSlot_2ndWeapon
    },
    xl = {
      equip = bo2.eItemSlot_Neck
    },
    jz = {
      equip = bo2.eItemSlot_Finger
    },
    hf = {
      equip = bo2.eItemSlot_Relic
    },
    st = {
      equip = bo2.eItemSlot_Glove
    },
    hw = {
      equip = bo2.eItemSlot_Wrists
    },
    aq = {
      equip = bo2.eItemSlot_HWeapon
    },
    cb = {
      equip = bo2.eItemSlot_Wing
    },
    awt_mz = {
      equip = bo2.eItemSlot_Avatar_Hat
    },
    awt_yf = {
      equip = bo2.eItemSlot_Avatar_Body
    },
    awt_ly = {
      equip = bo2.eItemSlot_Avatar_Imprint
    },
    awt_zs = {
      equip = bo2.eItemSlot_Ornament
    }
  }
  for n, v in pairs(slot_def) do
    local slot = w_equip:search(n)
    slot.grid = v.equip
  end
  local obj = bo2.player
  if sys.check(obj) then
    bind_player(obj)
  end
  ui_setting.ui_input.hotkey_notify_insert(hotkey_update, "ui_equip.hotkey_update")
  update_equip()
  quickequip_tab = {}
  quickequip_last_sel_idx = 1
  on_init_quickequip_item()
  slot_name_tab = {
    [4] = {
      ctrl_name = "se_mz",
      index = bo2.ePlayerFlagInt8_SlotEnhance_Hat,
      value = 0,
      milestone_id = 40024,
      request_lv = 42
    },
    [7] = {
      ctrl_name = "se_yf",
      index = bo2.ePlayerFlagInt8_SlotEnhance_Body,
      value = 0,
      milestone_id = 40034,
      request_lv = 47
    },
    [10] = {
      ctrl_name = "se_kz",
      index = bo2.ePlayerFlagInt8_SlotEnhance_Legs,
      value = 0,
      milestone_id = 40022,
      request_lv = 41
    },
    [8] = {
      ctrl_name = "se_yd",
      index = bo2.ePlayerFlagInt8_SlotEnhance_Waist,
      value = 0,
      milestone_id = 40030,
      request_lv = 45
    },
    [9] = {
      ctrl_name = "se_xz",
      index = bo2.ePlayerFlagInt8_SlotEnhance_Feet,
      value = 0,
      milestone_id = 40026,
      request_lv = 43
    },
    [6] = {
      ctrl_name = "se_xl",
      index = bo2.ePlayerFlagInt8_SlotEnhance_Neck,
      value = 0,
      milestone_id = 40038,
      request_lv = 49
    },
    [1] = {
      ctrl_name = "se_jz",
      index = bo2.ePlayerFlagInt8_SlotEnhance_Finger,
      value = 0,
      milestone_id = 40036,
      request_lv = 48
    },
    [5] = {
      ctrl_name = "se_hf",
      index = bo2.ePlayerFlagInt8_SlotEnhance_Relic,
      value = 0,
      milestone_id = 40019,
      request_lv = 40
    },
    [3] = {
      ctrl_name = "se_st",
      index = bo2.ePlayerFlagInt8_SlotEnhance_Glove,
      value = 0,
      milestone_id = 40028,
      request_lv = 44
    },
    [2] = {
      ctrl_name = "se_hw",
      index = bo2.ePlayerFlagInt8_SlotEnhance_Wrists,
      value = 0,
      milestone_id = 40032,
      request_lv = 46
    }
  }
  min_enhance_level = 0
end
function level70_expr(level)
  local mode = ui_widget.get_define_int(50047)
  if mode == 1 then
    return level >= 70
  end
  if mode == 2 then
    return true
  end
  return false
end
function level70_value(expr70, val70, val)
  if expr70 then
    return val70
  end
  return val
end
function on_make_limit_text(player, atb)
  local value = player:get_atb(atb.value)
  local limit = player:get_atb(atb.limit)
  if atb.remain_value then
    value = limit - value
  end
  return sys.format("%d/%d", value, limit)
end
function on_make_range_text(player, atb)
  return sys.format("%d-%d", player:get_atb(atb.value), player:get_atb(atb.range))
end
function on_make_value_text(player, atb)
  local basic = atb.basic
  local v_atb = player:get_atb(atb.value)
  if basic == nil then
    return L(v_atb), nil
  end
  local b_atb = player:get_atb(basic)
  local point = atb.point
  if point ~= nil then
    b_atb = b_atb + player:get_atb(point)
  end
  if v_atb > b_atb then
    return L(v_atb), value_color_add
  end
  if v_atb < b_atb then
    return L(v_atb), value_color_sub
  end
  return L(v_atb), value_color_equ
end
function on_make_level_text(player, atb)
  local lvl = player:get_atb(atb.value)
  return sys.format("Lv%d", lvl)
end
local make_score = function(player, mods)
  local modify_grade = bo2.gv_modify_grade
  local modify_player = bo2.gv_modify_player
  local score = 0
  for i, mod_id in ipairs(mods) do
    local grade = modify_grade:find(mod_id).fGrade
    local mod = modify_player:find(mod_id)
    local atb = player:get_atb(mod.treeid[0])
    if mod.isCent ~= 0 then
      atb = atb / 100
    end
    score = score + atb * grade
  end
  return score
end
local dmg_score_mgc = {
  bo2.eMdf_Base_MgcDmgMin,
  bo2.eMdf_Base_MgcDmgMax,
  bo2.eMdf_Base_MgcAttackLv,
  bo2.eMdf_Base_MgcHit,
  bo2.eMdf_Base_MgcHitLv,
  bo2.eMdf_Base_MgcDeadLv,
  bo2.eMdf_Base_IgnoreMagicDefend,
  bo2.eMdf_Base_MgcHitRate,
  bo2.eMdf_Cha_CutTotalTransferRate,
  bo2.eMdf_Cha_CutTotalTransferEffect
}
local dmg_score_phy = {
  bo2.eMdf_Base_PhyDmgMin,
  bo2.eMdf_Base_PhyDmgMax,
  bo2.eMdf_Base_PhyAttackLv,
  bo2.eMdf_Base_PhyHit,
  bo2.eMdf_Base_PhyHitLv,
  bo2.eMdf_Base_PhyDeadLv,
  bo2.eMdf_Base_IgnorePhyDefend,
  bo2.eMdf_Base_PhyHitRate,
  bo2.eMdf_Cha_CutTotalTransferRate,
  bo2.eMdf_Cha_CutTotalTransferEffect
}
local dmg_score_cmn = {
  bo2.eMdf_Base_NicetyLv,
  bo2.eMdf_Cha_Luck
}
local player_io_mod = function(player, atb)
  local v = player:get_atb(atb)
  if v == 0 then
    v = 10000
  end
  return v
end
local player_io_mod1 = function(player, atb)
  local v = player:get_atb(atb)
  return v / 100
end
function make_dmg_score_no_mod(player)
  local pro_id = player:get_atb(bo2.eAtb_Cha_Profession)
  local pro = bo2.gv_profession_list:find(pro_id)
  if pro == nil then
    return 0
  end
  local dmg = pro.damage
  local score_x
  if dmg == 1 then
    score_x = make_score(player, dmg_score_mgc)
  else
    score_x = make_score(player, dmg_score_phy)
  end
  local score_cmn = make_score(player, dmg_score_cmn)
  local grade = score_x + score_cmn
  return math.floor(grade)
end
function make_dmg_score(player)
  local pro_id = player:get_atb(bo2.eAtb_Cha_Profession)
  local pro = bo2.gv_profession_list:find(pro_id)
  if pro == nil then
    return 0
  end
  local dmg = pro.damage
  local score_x
  if dmg == 1 then
    score_x = make_score(player, dmg_score_mgc)
  else
    score_x = make_score(player, dmg_score_phy)
  end
  local score_cmn = make_score(player, dmg_score_cmn)
  local out_dmg = player_io_mod(player, bo2.eAtb_Cha_OutDmgMod) / 10000
  local grade = (score_x + score_cmn) * out_dmg
  return math.floor(grade)
end
function on_make_dmg_score_text(player, atb)
  local grade = make_dmg_score(player)
  return sys.format("%d", grade)
end
local def_score_cmn = {
  bo2.eMdf_Base_HPMax,
  bo2.eMdf_Cha_HPBack,
  bo2.eMdf_Base_PhyDefendLv,
  bo2.eMdf_Base_MgcDefendLv,
  bo2.eMdf_Base_TenacityLv,
  bo2.eMdf_Base_TransferLv,
  bo2.eMdf_Base_TransferRate
}
function make_def_score_no_mod(player)
  local grade = make_score(player, def_score_cmn)
  return math.floor(grade)
end
function make_def_score(player)
  local grade = make_score(player, def_score_cmn)
  local in_dmg = player_io_mod(player, bo2.eAtb_Cha_InDmgMod) / 10000
  grade = grade * (2 - in_dmg)
  return math.floor(grade)
end
function on_make_def_score_text(player, atb)
  grade = make_def_score(player)
  return sys.format("%d", grade)
end
function on_make_tip_score(player, atb)
  local val
  if atb.name == "atb_dmg_score" then
    val = player_io_mod(player, bo2.eAtb_Cha_OutDmgMod)
  else
    val = player_io_mod(player, bo2.eAtb_Cha_InDmgMod)
  end
  local f = sys.format("%g%%", val / 100)
  local v = sys.variant()
  v:set("n", f)
  return sys.mtf_merge(v, atb.tip)
end
function on_make_fight_score_text(player, atb)
  grade = make_dmg_score(player) + make_def_score(player)
  return sys.format("%d", grade)
end
function on_make_tip_fight_score(player, atb)
  local dmg = make_dmg_score(player)
  local dmg_o = sys.format("%g%%", player_io_mod(player, bo2.eAtb_Cha_OutDmgMod) / 100)
  local def = make_def_score(player)
  local dmg_i = sys.format("%g%%", player_io_mod(player, bo2.eAtb_Cha_InDmgMod) / 100)
  local cut_tr = sys.format("%g%%", player_io_mod1(player, bo2.eAtb_Cha_CutTotalTransferRate))
  local cut_te = sys.format("%g%%", player_io_mod1(player, bo2.eAtb_Cha_CutTotalTransferEffect))
  local v = sys.variant()
  v:set("dmg", dmg)
  v:set("dmg_o", dmg_o)
  v:set("def", def)
  v:set("dmg_i", dmg_i)
  v:set("cut_tr", cut_tr)
  v:set("cut_te", cut_te)
  return sys.mtf_merge(v, atb.tip)
end
function on_make_sex_text(player, atb)
  local sex = player:get_atb(atb.value)
  local t = ui.get_text(sys.format("common|sex%d", sex))
  return t
end
function on_make_exp_text(player, atb, is_view)
  local value = player:get_atb(bo2.eAtb_Cha_Exp)
  local limit = 0
  local save_exp = 0
  local levelup = bo2.gv_player_levelup:find(player:get_atb(bo2.eAtb_Level))
  if levelup == nil then
    limit = value * 2 + 1
  else
    limit = levelup.exp
    save_exp = levelup.save_exp
  end
  local per = 0
  local vis = false
  if limit >= 1 then
    if value >= limit then
      per = (value - limit) / (save_exp - limit)
      vis = true
    else
      per = value / limit
    end
    if per > 1 then
      per = 1
    end
  end
  if not sys.check(is_view) and levelup ~= nil then
    if levelup.is_open ~= 0 then
      w_levelup_btn.visible = vis
      atb.frame.visible = not vis
      if vis then
        ui_portrait.w_leveluop_flick.visible = true
      else
        ui_portrait.w_leveluop_flick.visible = false
      end
    else
      w_levelup_btn.visible = false
      atb.frame.visible = true
      ui_portrait.w_leveluop_flick.visible = false
    end
  end
  local f1 = atb.frame:search("per")
  local f2 = atb.frame:search("full")
  local f
  if value < limit then
    f = f1
    f1.visible = true
    f2.visible = false
  else
    f = atb.frame:search("store")
    f2.visible = true
    f1.visible = false
  end
  f.dy = f2.dy * per
  atb.tip = ui_widget.merge_mtf({
    cur = value,
    limit = limit,
    save = save_exp
  }, ui.get_text("personal|exp_des"))
  return sys.format("%d/%d", value, limit)
end
function on_exp_move()
  on_make_exp_text(safe_get_player(), atb_def.atb_exp)
end
function on_make_career_text(player, atb)
  local pro = player:get_atb(atb.value)
  if pro == 0 then
    return L("NONE")
  end
  local f = atb.frame
  local n = bo2.gv_profession_list:find(pro)
  ui_portrait.make_career_color(f, n)
  f.image = sys.format("$image/personal/32x32/%d.png|0,0,27,30", n.career)
  return n.name
end
function on_make_career_tip(player, atb)
  return ui_portrait.make_career_tip_text(player)
end
function on_make_tip(player, atb)
  return atb.tip
end
make_rate = ui_widget.make_rate
local c_format_rate = SHARED(sys.format(L("<c+:%s>%%s%%%%<c->"), value_color_add))
local c_format_value = SHARED(sys.format(L("<c+:%s>%%g<c->"), value_color_add))
local function format_value(v, digit)
  local fac = 1
  if digit == nil then
    fac = 100
  else
    for i = 1, digit do
      fac = fac * 10
    end
  end
  local t = math.floor(v * fac + 0.5) / fac
  return sys.format(c_format_value, t)
end
function on_make_tip_atb_point(player, atb)
  local v = sys.variant()
  local s = sys.format("<c+:%s>%d<c->", value_color_add, player:get_atb(bo2.eAtb_Cha_AtbPoint) + player:get_atb(bo2.eAtb_Cha_VitPoint) + player:get_atb(bo2.eAtb_Cha_SkePoint) + player:get_atb(bo2.eAtb_Cha_AgiPoint) + player:get_atb(bo2.eAtb_Cha_StrPoint) + player:get_atb(bo2.eAtb_Cha_IntPoint))
  v:set("n", s)
  return sys.mtf_merge(v, atb.tip)
end
function on_make_tip_anti(player, atb)
  local v = sys.variant()
  local id = math.floor(player:get_atb(atb.value) * 20 / player:get_atb(bo2.eAtb_Level) + 1)
  local s = bo2.gv_state_resist:find(id)
  if s == nil then
    s = bo2.gv_state_resist:get(bo2.gv_state_resist.size - 1)
  end
  if s == nil then
    return atb.title
  end
  v:set("odd2", sys.format(c_format_rate, make_rate(s.resist2 * 100)))
  v:set("odd3", sys.format(c_format_rate, make_rate(s.resist3 * 100)))
  return sys.mtf_merge(v, atb.tip)
end
function on_make_tip_def(player, atb)
  local v = sys.variant()
  v:set("n", format_value(player:get_atb(atb.value) / 25))
  return sys.mtf_merge(v, atb.tip)
end
function on_make_tip_atk(player, atb)
  local v = sys.variant()
  v:set("n", format_value(player:get_atb(atb.value) / 20))
  if atb.value == bo2.eAtb_PhyAttackLv then
    v:set("d", format_value(player:get_atb(bo2.eAtb_IgnorePhyDefend)))
  else
    v:set("d", format_value(player:get_atb(bo2.eAtb_IgnoreMgcDefend)))
  end
  return sys.mtf_merge(v, atb.tip)
end
function on_make_tip_tenacity(player, atb)
  local v = sys.variant()
  local n = player:get_atb(atb.value)
  local lv = player:get_atb(bo2.eAtb_Level)
  local expr70 = level70_expr(lv)
  local n1_base = n * 3 * 0.75
  local n1 = n1_base * 100 / (n1_base * 1.4 + level70_value(expr70, 100, 30) * lv + 480)
  local n2_base = n * 1.5
  local n2 = n2_base * 100 / (n2_base + level70_value(expr70, 15, 7.5) * lv)
  if n2 > 70 then
    n2 = 70
  end
  v:set("n1", sys.format(c_format_rate, make_rate(n1)))
  v:set("n2", sys.format(c_format_rate, make_rate(n2)))
  return sys.mtf_merge(v, atb.tip)
end
function on_make_tip_nicety(player, atb)
  local v = sys.variant()
  local n = player:get_atb(atb.value) * 3
  local lv = player:get_atb(bo2.eAtb_Level)
  local expr70 = level70_expr(lv)
  local val = n / (n + level70_value(expr70, 200, 28) * lv + 160) * 100
  v:set("n", sys.format(c_format_rate, make_rate(val)))
  return sys.mtf_merge(v, atb.tip)
end
function on_make_tip_dmg(player, atb)
  local v = sys.variant()
  local n = player:get_atb(bo2.eAtb_Cha_Luck)
  local d = ((player:get_atb(atb.value) + player:get_atb(atb.range)) * 0.5 + n) * 0.1
  v:set("n", format_value(n))
  v:set("d", format_value(d, 1))
  return sys.mtf_merge(v, atb.tip)
end
local c_format_equ = sys.format(L("<c+:%s>%%d<c->"), value_color_equ)
local c_format_add = sys.format(L("<c+:%s>%%d<c->(<c+:%s>%%d<c->+<c+:%s>%%d<c->)"), value_color_add, value_color_equ, value_color_add)
local c_format_sub = sys.format(L("<c+:%s>%%d<c->(<c+:%s>%%d<c->-<c+:%s>%%d<c->)"), value_color_sub, value_color_equ, value_color_sub)
function on_make_basic_tip(player, atb)
  local basic = atb.basic
  if basic == nil then
    return atb.tip
  end
  local v_atb = player:get_atb(atb.value)
  local b_atb = player:get_atb(basic)
  local point = atb.point
  if point ~= nil then
    b_atb = b_atb + player:get_atb(point)
  end
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
local c_format_transfer_n = SHARED(sys.format(L("<c+:%s>%%s%%%%<c->(<c+:%s>%%s%%%%<c->+<c+:%s>%%s%%%%<c->)"), value_color_add, value_color_add, value_color_add))
local c_format_transfer_d = SHARED(sys.format(L("<c+:%s>%%s%%%%<c->"), value_color_add))
local make_percent = function(v)
  if v >= 10 then
    v = math.floor(v * 10 + 0.5) * 0.1
    return sys.format("%g", v)
  end
  return sys.format("%.2g", v)
end
function on_make_tip_transfer(player, atb)
  local r = player:get_atb(bo2.eAtb_TransferRate) / 100
  local n = player:get_atb(atb.value) * 3
  local lv = player:get_atb(bo2.eAtb_Level)
  local expr70 = level70_expr(lv)
  n = n / (n + level70_value(expr70, 200, 28) * lv + 160) * 100
  local t = r + n
  local d = 50 + player:get_atb(bo2.eAtb_Cha_TransferEffect) / 100
  return ui_widget.merge_mtf({
    n = sys.format(c_format_transfer_n, make_percent(t), make_percent(r), make_percent(n)),
    d = sys.format(c_format_transfer_d, make_percent(d))
  }, atb.tip)
end
function on_make_tip_hit(player, atb)
  local r = 0
  if atb.value == bo2.eAtb_PhyHitLv then
    r = player:get_atb(bo2.eAtb_PhyHitRate)
  else
    r = player:get_atb(bo2.eAtb_MgcHitRate)
  end
  r = r / 100
  local n = player:get_atb(atb.value) * 3
  local lv = player:get_atb(bo2.eAtb_Level)
  local expr70 = level70_expr(lv)
  n = n / (n * 1.4 + level70_value(expr70, 100, 30) * lv + 480) * 100
  local t = r + n
  local v = sys.variant()
  v:set("n", sys.format(c_format_transfer_n, make_percent(t), make_percent(r), make_percent(n)))
  return sys.mtf_merge(v, atb.tip)
end
function on_make_tip_dead(player, atb)
  local r = 0
  if atb.value == bo2.eAtb_PhyDeadLv then
    r = player:get_atb(bo2.eAtb_PhyHit)
  else
    r = player:get_atb(bo2.eAtb_MgcHit)
  end
  r = r / 100
  local v = sys.variant()
  local n = player:get_atb(atb.value)
  local lv = player:get_atb(bo2.eAtb_Level)
  local expr70 = level70_expr(lv)
  local val = 130 + r + n / (n + level70_value(expr70, 15, 7.5) * lv) * 100
  v:set("n", sys.format(c_format_rate, make_rate(val)))
  return sys.mtf_merge(v, atb.tip)
end
function safe_get_player()
  local player = bo2.player
  if not sys.check(player) then
    player = fake_player
  end
  player = build_lvmax_player(player)
  return player
end
function on_atb_tip_make(tip)
  local atb = atb_def[tostring(tip.owner.name)]
  if atb == nil then
    return
  end
  local player = safe_get_player()
  local text = atb.on_make_tip(player, atb)
  local append
  local pro_id = player:get_atb(bo2.eAtb_Cha_Profession)
  local pro = bo2.gv_profession_list:find(pro_id)
  if pro ~= nil then
    local dmg = pro.damage
    if dmg == 1 then
      if atb.value == bo2.eAtb_Str then
        append = ui.get_text("personal|fashu_des")
      end
    elseif atb.value == bo2.eAtb_Int then
      append = ui.get_text("personal|wuli_des")
    end
  end
  if append ~= nil then
    append = ui_widget.merge_mtf({
      pro = pro.name,
      atb = bo2.gv_atb_player:find(atb.value).name
    }, append)
    text = sys.format(L([[
%s
<c+:FF0000>%s<c->]]), text, append)
  end
  ui_widget.tip_make_view(tip.view, text)
end
function atb_init(p, def, reg)
  local n = tostring(p.name)
  local d = def[n]
  if d == nil then
    ui.log("bad atb name %s.", n)
    return
  end
  reg[n] = d
  local lb_name = p:search("lb_name")
  if lb_name ~= nil then
    lb_name.text = d.title
  end
  local lb_value = p:search("lb_value")
  if lb_value == nil and sys.is_type(p, "ui_label") then
    lb_value = p
  end
  if lb_value ~= nil then
    local color = d.value_color
    if color ~= nil then
      lb_value.color = ui.make_color(color)
    end
  end
  d.label = lb_value
  d.lb_name = lb_name
  d.frame = p
  d.btn_plus = p:search("btn_plus")
end
function on_atb_init(p)
  atb_init(p, atb_def, atb_reg)
end
function update_atb(player, reg)
  local disable_plus
  local pro_id = player:get_atb(bo2.eAtb_Cha_Profession)
  local pro = bo2.gv_profession_list:find(pro_id)
  if pro ~= nil then
    local dmg = pro.damage
    if dmg == 1 then
      disable_plus = bo2.eAtb_Str
    else
      disable_plus = bo2.eAtb_Int
    end
  end
  local point = player:get_atb(bo2.eAtb_Cha_AtbPoint)
  if reg == nil then
    reg = atb_reg
  end
  for n, v in pairs(reg) do
    local s, t, c = sys.pcall(v.on_make_text, player, v)
    local lb = v.label
    if lb ~= nil then
      lb.text = t
      if c ~= nil then
        lb.xcolor = c
      end
    end
    local btn = v.btn_plus
    if btn ~= nil then
      btn.visible = point > 0 and v.value ~= disable_plus
      local scn_id = bo2.scn.scn_excel.id
      local scn_list = bo2.gv_scn_list:find(scn_id)
      if scn_list ~= nil then
        local enable = scn_list.not_add_atb_point
        if enable == 1 then
          btn.visible = false
        end
      end
    end
  end
end
function update_title(player, w)
  w:search("lb_title").text = player.name
end
function hotkey_update()
  local player = bo2.player
  if player == nil then
    return
  end
  local txt = ui_setting.ui_input.get_op_simple_text(2000)
  if txt ~= nil and not txt.empty then
    ui_personal.w_personal:search("lb_title").text = sys.format("%s[%s]", player.name, txt)
  else
    ui_personal.w_personal:search("lb_title").text = player.name
  end
end
function update_pro(player, w, def)
  local pro_id = player:get_atb(bo2.eAtb_Cha_Profession)
  local pro = bo2.gv_profession_list:find(pro_id)
  if pro == nil then
    return
  end
  local dmg = pro.damage
  local color_phy, color_mgc
  if dmg == 1 then
    ui_tab.get_button(w, atb_tab_name_mgc):move_to_head()
    ui_tab.show_page(w, atb_tab_name_mgc, true)
    color_phy = color_atb_disable
    color_mgc = color_atb_common
  else
    ui_tab.get_button(w, atb_tab_name_phy):move_to_head()
    ui_tab.show_page(w, atb_tab_name_phy, true)
    color_phy = color_atb_common
    color_mgc = color_atb_disable
  end
  color_phy = ui.make_color(color_phy)
  color_mgc = ui.make_color(color_mgc)
  if def == nil then
    def = atb_def
  end
  local function update_atb_color(n, c)
    local d = def[n]
    if sys.check(d.label) then
      d.label.color = c
    end
  end
  update_atb_color("atb_phy_dmg", color_phy)
  update_atb_color("atb_phy_atk", color_phy)
  update_atb_color("atb_phy_hit", color_phy)
  update_atb_color("atb_phy_dead", color_phy)
  update_atb_color("atb_mgc_dmg", color_mgc)
  update_atb_color("atb_mgc_atk", color_mgc)
  update_atb_color("atb_mgc_hit", color_mgc)
  update_atb_color("atb_mgc_dead", color_mgc)
end
function on_self_pro(player)
  update_pro(player, w_atb_tab)
end
function update_skill_score()
  local info = ui.xinfa_head()
  local xinfaLv = 0
  while info ~= nil do
    local type = bo2.gv_xinfa_list:find(info.excel_id).type_id
    if type == bo2.eXinFaType_Currency or type == bo2.eXinFaType_Expert then
      xinfaLv = xinfaLv + info.level
    end
    info = ui.next_xinfa(info.excel_id)
  end
  w_skill_score.text = ui.get_text("skill|xinfa_score") .. xinfaLv
end
function update_equip(should_update_pro)
  local player = safe_get_player()
  if not w_equip.observable then
    local v = atb_reg.atb_exp
    sys.pcall(v.on_make_text, player, v)
    return
  end
  update_atb(player)
  update_title(player, ui_personal.w_personal)
  if should_update_pro then
    update_pro(player, w_atb_tab)
  end
  update_skill_score()
  hotkey_update()
  local sex = player:get_atb(bo2.eAtb_Sex)
  ui_personal.w_bg.image = sys.format("$image/personal/512x512/bg_%d.png|0,0,491,470", sex)
end
function post_update_equip()
  w_equip:insert_post_invoke(update_equip, "ui_personal.ui_equip.update_equip")
end
function on_observable(w, vis)
  ui_handson_teach.test_complate_level_monitor(vis)
  if sys.check(w_quickequip) then
    w_quickequip.visible = false
  end
  if not vis then
    w_quickequip_btn.visible = false
    ui_personal.ui_equip.w_equip_slots.visible = false
    ui_personal.ui_equip.w_equip_slots_enhance.visible = false
    return
  end
  w_quickequip_btn.visible = true
  update_equip(true)
  if vis then
    if open_slot_panel then
      on_btn_slot_enhance()
      if slot_guide ~= nil then
        slot_guide.visible = false
      end
    else
      on_btn_back_equip()
    end
    open_slot_panel = false
    if milestone_complete(40019) then
      ui_personal.ui_equip.w_equip:search("btn_slot_enhance").visible = true
      ui_personal.ui_equip.w_equip:search("pic_slot_enhance_disable").visible = false
      ui_handson_teach.test_complate_slotenhance_open_slotview(true)
    else
      ui_personal.ui_equip.w_equip:search("btn_slot_enhance").visible = false
      ui_personal.ui_equip.w_equip:search("pic_slot_enhance_disable").visible = true
    end
  end
end
function on_self_atb(obj, ft, idx)
  update_equip()
end
function on_self_exp(obj)
  on_make_exp_text(obj, atb_def.atb_exp)
end
function on_levelup_click(btn)
  local player = safe_get_player()
  local level = player:get_atb(bo2.eAtb_Level)
  local finish_app_level = tonumber(tostring(bo2.gv_define_sociality:find(37).value))
  if level == finish_app_level - 1 and ui.is_have_relation(bo2.TWR_Type_MasterAndApp) then
    ui_personal.ui_finish_apprentice.show()
    return
  end
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_ScnObj_LevelUp, v)
end
function on_self_body(obj, ft, idx)
  local v = obj:get_flag_int8(bo2.ePlayerFlagInt8_Body)
  if v == 1 then
    w_btn_toggle_body_avatar.visible = true
    w_btn_toggle_body_equip.visible = false
  else
    w_btn_toggle_body_avatar.visible = false
    w_btn_toggle_body_equip.visible = true
  end
end
function on_toggle_body_avatar_click(btn)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Body, 0)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Legs, 0)
end
function on_toggle_body_equip_click(btn)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Body, 1)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Legs, 1)
end
function on_self_legs(obj, ft, idx)
  local v = obj:get_flag_int8(bo2.ePlayerFlagInt8_Legs)
  w_btn_toggle_legs_equip.visible = v == 0
  w_btn_toggle_legs_avatar.visible = v == 1
end
function on_toggle_legs_avatar_click(btn)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Legs, 0)
end
function on_toggle_legs_equip_click(btn)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Legs, 1)
end
function on_self_hat(obj, ft, idx)
  local v = obj:get_flag_int8(bo2.ePlayerFlagInt8_Hat)
  if v == 2 then
    w_btn_toggle_hat_equip.visible = false
    w_btn_toggle_hat_avatar.visible = true
  else
    w_btn_toggle_hat_equip.visible = true
    w_btn_toggle_hat_avatar.visible = false
  end
end
function on_toggle_hat_avatar_click(btn)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Hat, 1)
end
function on_toggle_hat_equip_click(btn)
  bo2.send_flag_int8(bo2.ePlayerFlagInt8_Hat, 2)
end
function on_add_point_click(btn)
  local n = tostring(btn.parent.name)
  bo2.send_flag_atb(atb_def[n].point, 1)
end
local levelup_xinfa_tip_init = false
local gv_levelup_xinfa_tip
function make_level_tip()
  local player = safe_get_player()
  local lv = player:get_atb(bo2.eAtb_Level)
  if lv < 15 then
    return nil
  end
  local lv_data = bo2.gv_player_levelup:find(lv)
  if lv_data == nil then
    return nil
  end
  local xf_lv = lv_data.xf_level
  if xf_lv == 0 then
    return nil
  end
  if gv_levelup_xinfa_tip == nil and not levelup_xinfa_tip_init then
    levelup_xinfa_tip_init = true
    gv_levelup_xinfa_tip = bo2.gv_player_levelup_xinfa_tip
  end
  local padding_tip
  if gv_levelup_xinfa_tip ~= nil then
    local xl = gv_levelup_xinfa_tip:find(xf_lv)
    if xl ~= nil then
      padding_tip = xl.xf_tip
    end
  end
  local pro_id = player:get_atb(bo2.eAtb_Cha_Profession)
  local pro_index = math.floor(pro_id / 3) * 2 - math.mod(pro_id - 1, 3) + 1
  local xf_vID = lv_data.xf_vID[pro_index]
  local stk = sys.mtf_stack()
  stk:raw_push(ui_widget.merge_mtf({
    level = lv + 1,
    xinfa_level = xf_lv
  }, ui.get_text("personal|need_xinfa")))
  if padding_tip ~= nil then
    stk:raw_push(padding_tip)
  end
  for i = 0, xf_vID.size - 1 do
    local xf = bo2.gv_xinfa_list:find(xf_vID[i])
    local lv = 0
    local xf_info = ui.xinfa_find(xf.id)
    if xf_info ~= nil then
      lv = xf_info.level
    end
    local color
    if xf_lv <= lv then
      color = [[

<c:FFAA55>]]
    else
      color = [[

<c:FF0000>]]
    end
    stk:raw_push(color)
    stk:raw_format("<a:l><space:1>%s<a:r>[%s]<space:1>", xf.name, ui_widget.merge_mtf({level = lv}, ui.get_text("quest|aq_new_level")))
  end
  return stk.text
end
function on_levelup_make_tip(tip)
  local txt = make_level_tip()
  if txt == nil then
    txt = tip.text
  end
  ui_widget.tip_make_view(tip.view, txt)
end
function on_levelup2_make_tip(tip)
  local txt = make_level_tip()
  if txt == nil then
    txt = tip.text
  end
  ui_widget.tip_make_view(tip.view, txt)
end
function atb_tab_insert(tab, name, x)
  local page_sty = atb_tab_page_sty .. name
  ui_tab.insert_suit(tab, name, atb_tab_btn_uri, atb_tab_btn_sty, atb_tab_page_uri, page_sty)
  local btn = ui_tab.get_button(tab, name)
  btn.tip.text = ui.get_text("personal|title_" .. page_sty)
  btn:search("tab_pic").irect = ui.rect(x, 0, x + 27, 128)
end
function on_atb_tab_init(tab)
  w_atb_tab = tab
  atb_tab_insert(tab, atb_tab_name_phy, 0)
  atb_tab_insert(tab, atb_tab_name_mgc, 31)
  ui_tab.set_button_sound(tab, 586)
end
function bind_player(obj)
  on_self_body(obj)
  on_self_hat(obj)
end
function on_self_enter(obj, msg)
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, -1, on_self_atb, "ui_personal.ui_equip.on_self_atb")
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Cha_Exp, on_self_exp, "ui_personal.ui_equip.on_self_exp")
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Cha_Profession, on_self_pro, "ui_personal.ui_equip.on_self_exp")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_Body, on_self_body, "ui_personal.ui_equip.on_self_body")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_Hat, on_self_hat, "ui_personal.ui_equip.on_self_hat")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_SlotEnhance_Relic, on_self_slot_enhance, "ui_personal.ui_equip.on_self_slot_enhance")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_SlotEnhance_Glove, on_self_slot_enhance, "ui_personal.ui_equip.on_self_slot_enhance")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_SlotEnhance_Wrists, on_self_slot_enhance, "ui_personal.ui_equip.on_self_slot_enhance")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_SlotEnhance_Hat, on_self_slot_enhance, "ui_personal.ui_equip.on_self_slot_enhance")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_SlotEnhance_Body, on_self_slot_enhance, "ui_personal.ui_equip.on_self_slot_enhance")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_SlotEnhance_Legs, on_self_slot_enhance, "ui_personal.ui_equip.on_self_slot_enhance")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_SlotEnhance_Waist, on_self_slot_enhance, "ui_personal.ui_equip.on_self_slot_enhance")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_SlotEnhance_Feet, on_self_slot_enhance, "ui_personal.ui_equip.on_self_slot_enhance")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_SlotEnhance_Neck, on_self_slot_enhance, "ui_personal.ui_equip.on_self_slot_enhance")
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_SlotEnhance_Finger, on_self_slot_enhance, "ui_personal.ui_equip.on_self_slot_enhance")
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Level, on_self_slot_enhance, "ui_personal.ui_equip.on_self_slot_enhance")
  if milestone_complete(40019) then
    ui_handson_teach.test_complate_slotenhance_open_personal(true)
  end
  bind_player(obj)
  post_update_equip()
end
function on_self_leave(obj, msg)
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_personal.ui_equip.on_self_enter")
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_leave, on_self_leave, "ui_personal.ui_equip.on_self_leave")
init_once()
function on_quickequip_click(btn)
  ui_personal.ui_equip.w_quickequip.visible = not ui_personal.ui_equip.w_quickequip.visible
  bo2.PlaySound2D(592)
end
function on_quickequip_visible(w, vis)
  if vis then
    ui_personal.w_personal.dx = ui_personal.w_major.dx + w_quickequip.dx
  else
    ui_personal.w_personal.dx = ui_personal.w_major.dx
  end
end
function on_init_quickequip_item()
  if w_quickequip == nil then
    return
  end
  for i = 1, 8 do
    item = ui.create_control(w_quickequip:search("quickequip_div"), "panel")
    item:load_style("$frame/personal/equip.xml", "quickequip_card")
    local img_name = bo2.gv_equip_pack:find(i).icon
    item:search("quickequip_icon").image = "$icon/item/tz/" .. img_name .. ".png"
    quickequip_tab[i] = {
      ctrl = item,
      image = item:search("quickequip_icon").image
    }
  end
  quickequip_tab[1].ctrl:search("highlight").visible = true
end
function get_sel_card_idx(card)
  for idx, val in ipairs(quickequip_tab) do
    if card == val.ctrl then
      return idx
    end
  end
end
function on_quickequipcard_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    local card_idx = get_sel_card_idx(card)
    if card_idx == quickequip_last_sel_idx then
      ui.set_cursor_icon(quickequip_tab[card_idx].image)
      local on_drop_hook = function(w, msg, pos, data)
        if msg == ui.mouse_drop_clean then
        end
        if msg == ui.mouse_drop_setup then
        end
      end
      local data = sys.variant()
      data:set("drop_type", ui_widget.c_drop_type_equippack)
      data:set("pack_id", card_idx)
      ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
    else
      quickequip_tab[quickequip_last_sel_idx].ctrl:search("highlight").visible = false
      quickequip_tab[card_idx].ctrl:search("highlight").visible = true
      quickequip_last_sel_idx = card_idx
    end
  elseif msg == ui.mouse_lbutton_drag then
    local card_idx = get_sel_card_idx(card)
    ui.set_cursor_icon(quickequip_tab[card_idx].image)
    local on_drop_hook = function(w, msg, pos, data)
      if msg == ui.mouse_drop_clean then
      end
      if msg == ui.mouse_drop_setup then
      end
    end
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_equippack)
    data:set("pack_id", card_idx)
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
    quickequip_tab[quickequip_last_sel_idx].ctrl:search("highlight").visible = false
    quickequip_tab[card_idx].ctrl:search("highlight").visible = true
    quickequip_last_sel_idx = card_idx
  end
end
function on_quickequipcard_drop(card, msg, pos, data)
  ui.log("\200\183\182\168")
end
function on_quickequip_save_btn_tip_show(tip)
  ui_widget.tip_make_view(tip.view, ui.get_text("personal|quickequip_save"))
end
function on_quickequip_replace_btn_tip_show(tip)
  ui_widget.tip_make_view(tip.view, ui.get_text("personal|quickequip_replace"))
end
function dec_to_bin(bin_tab, dec)
  if dec < 0 or dec > 255 then
    ui.log("error")
    return
  end
  for i = 8, 1, -1 do
    bin_tab[i] = dec % 2
    dec = dec / 2
    dec = dec - dec % 1
  end
end
function get_equippack_info(tab, item_info)
  if item_info ~= nil then
    local item_type = item_info.excel.type
    if item_type == 0 then
      return
    end
    local item_group = bo2.gv_item_type:find(item_type).group
    if item_group ~= 3 and item_group ~= 4 then
      return
    end
    local type_idx = 0
    local equip_slot = bo2.gv_item_type:find(item_type).equip_slot
    local equip_list_tab = tab[1]
    for idx1, val1 in ipairs(equip_list_tab) do
      if val1.equip_slot == equip_slot then
        type_idx = idx1
        break
      end
    end
    if type_idx == 0 then
      return
    end
    local val = item_info:get_data_8(bo2.eItemByte_EquipPack)
    local bin_tab = {}
    dec_to_bin(bin_tab, val)
    for idx = 1, 8 do
      if bin_tab[idx] == 1 then
        tab[9 - idx][type_idx].only_id = item_info.only_id
      end
    end
  end
end
function get_equip_pack_from_item(equip_pack_tab)
  for i = 1, 8 do
    equip_pack_tab[i] = {
      {
        tp = "mz",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Hat
      },
      {
        tp = "yf",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Body
      },
      {
        tp = "kz",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Legs
      },
      {
        tp = "yd",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Waist
      },
      {
        tp = "xz",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Feet
      },
      {
        tp = "wq",
        only_id = 0,
        equip_slot = bo2.eItemSlot_MainWeapon
      },
      {
        tp = "wq2",
        only_id = 0,
        equip_slot = bo2.eItemSlot_2ndWeapon
      },
      {
        tp = "aq",
        only_id = 0,
        equip_slot = bo2.eItemSlot_HWeapon
      },
      {
        tp = "xl",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Neck
      },
      {
        tp = "jz",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Finger
      },
      {
        tp = "hf",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Relic
      },
      {
        tp = "st",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Glove
      },
      {
        tp = "hw",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Wrists
      },
      {
        tp = "awt_mz",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Avatar_Hat
      },
      {
        tp = "awt_yf",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Avatar_Body
      },
      {
        tp = "cb",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Wing
      },
      {
        tp = "awt_zs",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Ornament
      },
      {
        tp = "awt_ly",
        only_id = 0,
        equip_slot = bo2.eItemSlot_Avatar_Imprint
      }
    }
  end
  for grid = bo2.eItemSlot_EquipBeg, bo2.eItemSlot_AvataEnd - 1 do
    local item_info = ui.item_of_coord(bo2.eItemArray_InSlot, grid)
    get_equippack_info(equip_pack_tab, item_info)
  end
  for box = bo2.eItemBox_BagBeg, bo2.eItemBox_BagEnd - 1 do
    for grid = 0, bag_slot_count - 1 do
      local item_info = ui.item_of_coord(box, grid)
      get_equippack_info(equip_pack_tab, item_info)
    end
  end
end
function on_quickequip_card_tip_show(tip)
  local equip_pack_tab = {}
  get_equip_pack_from_item(equip_pack_tab)
  for idx, val1 in ipairs(quickequip_tab) do
    if val1.ctrl == tip.owner then
      local stk = sys.mtf_stack()
      ui_tool.ctip_push_text(stk, ui_widget.merge_mtf({n = idx}, ui.get_text("personal|quickequip_n")), ui_tool.cs_tip_color_green)
      local equip_list_tab = equip_pack_tab[idx]
      for key, val2 in ipairs(equip_list_tab) do
        local equip_card = w_equip:search(val2.tp)
        local type_text = ui.get_text(sys.format(L("item|slot%d"), equip_card.grid))
        if equip_card.grid == bo2.eItemSlot_Avatar_Hat then
          type_text = ui.get_text("personal|avatar_head")
        elseif equip_card.grid == bo2.eItemSlot_Avatar_Body then
          type_text = ui.get_text("personal|avatar_cloth")
        elseif equip_card.grid == bo2.eItemSlot_Ornament then
          type_text = ui.get_text("personal|shi_ping")
        elseif equip_card.grid == bo2.eItemSlot_Avatar_Imprint then
          type_text = ui.get_text("personal|lao_ying")
        end
        local item_text, item_text_color
        if val2.only_id == 0 then
          item_text = ""
        else
          local info = ui.item_of_only_id(val2.only_id)
          if info ~= nil then
            item_text = info.excel.name
            item_text_color = ui_tool.cs_tip_color_set_has
          else
            item_text = ui.get_text("personal|equip_not_exist")
            item_text_color = ui_tool.cs_tip_color_set_no
          end
        end
        if key == 1 then
          ui_tool.ctip_push_sep(stk)
        else
          ui_tool.ctip_push_newline(stk)
        end
        ui_tool.ctip_push_text(stk, ui_widget.merge_mtf({str = type_text}, ui.get_text("personal|str_colon")))
        ui_tool.ctip_push_text(stk, item_text, item_text_color)
      end
      ui_tool.ctip_show(tip.owner, stk)
    end
  end
end
function send_equippack_save(idx)
  card_name_tab = {
    "mz",
    "yf",
    "kz",
    "yd",
    "xz",
    "wq",
    "wq2",
    "aq",
    "xl",
    "jz",
    "hf",
    "st",
    "hw",
    "awt_mz",
    "awt_yf",
    "cb",
    "awt_zs",
    "awt_ly"
  }
  local v = sys.variant()
  local i = 1
  for key, val2 in ipairs(card_name_tab) do
    local equip_card = w_equip:search(val2)
    if equip_card.info == nil then
      v:set64(i, 0)
    else
      v:set64(i, equip_card.info.only_id)
    end
    v:set(i + 20, equip_card.grid)
    i = i + 1
  end
  v:set(packet.key.equippack_idx, idx)
  bo2.send_variant(packet.eCTS_UI_EquipPackSave, v)
end
function on_quickequip_save_btn_click(ctrl)
  bo2.PlaySound2D(578)
  for idx, val1 in ipairs(quickequip_tab) do
    if val1.ctrl:search("highlight").visible == true then
      send_equippack_save(idx)
    end
  end
  ui_tool.note_insert_normal(ui.get_text("personal|quickequip_save_suc"))
end
function quickequip_replace(idx)
  local equip_pack_tab = {}
  get_equip_pack_from_item(equip_pack_tab)
  local equip_list_tab = equip_pack_tab[idx]
  local occ_grid_cnt = 0
  local total_grid_cnt = 0
  for box = bo2.eItemBox_BagBeg, bo2.eItemBox_BagBeg + 6 do
    local box_grid_cnt = ui_item.g_boxs[box].count
    total_grid_cnt = total_grid_cnt + box_grid_cnt
    for grid = 0, box_grid_cnt - 1 do
      local item_info = ui.item_of_coord(box, grid)
      if item_info ~= nil then
        occ_grid_cnt = occ_grid_cnt + 1
      end
    end
  end
  local occ_ava_grid_cnt = 0
  local total_ava_grid_cnt = ui_item.g_boxs[bo2.eItemBox_AvataBag].count
  for grid = 0, total_ava_grid_cnt - 1 do
    local item_info = ui.item_of_coord(bo2.eItemBox_AvataBag, grid)
    if item_info ~= nil then
      occ_ava_grid_cnt = occ_ava_grid_cnt + 1
    end
  end
  local empty_grid_cnt = total_grid_cnt - occ_grid_cnt
  local empty_ava_grid_cnt = total_ava_grid_cnt - occ_ava_grid_cnt
  local unequip_cnt = 0
  local unequip_ava_cnt = 0
  for key, val2 in ipairs(equip_list_tab) do
    local equip_card = ui_personal.ui_equip.w_equip:search(val2.tp)
    if equip_card.info ~= nil then
      if val2.tp ~= "awt_mz" and val2.tp ~= "awt_yf" then
        unequip_cnt = unequip_cnt + 1
      else
        unequip_ava_cnt = unequip_ava_cnt + 1
      end
    end
    if val2.only_id ~= 0 then
      if val2.tp ~= "awt_mz" and val2.tp ~= "awt_yf" then
        unequip_cnt = unequip_cnt - 1
      else
        unequip_ava_cnt = unequip_ava_cnt - 1
      end
    end
  end
  if empty_grid_cnt < unequip_cnt then
    ui_tool.note_insert_error(ui.get_text("personal|bag_full"))
    return
  end
  if empty_ava_grid_cnt < unequip_ava_cnt and empty_grid_cnt + empty_ava_grid_cnt < unequip_ava_cnt + unequip_cnt then
    ui_tool.note_insert_error(ui.get_text("personal|bag_full"))
    return
  end
  for key, val2 in ipairs(equip_list_tab) do
    local equip_card = ui_personal.ui_equip.w_equip:search(val2.tp)
    if val2.only_id ~= 0 then
      local item_info = ui.item_of_only_id(val2.only_id)
      ui_item.send_equip(item_info, equip_card.grid)
    end
  end
  for key, val2 in ipairs(equip_list_tab) do
    local equip_card = ui_personal.ui_equip.w_equip:search(val2.tp)
    if val2.only_id == 0 then
      ui_item.send_unequip(equip_card.only_id, bo2.eItemBox_BagEnd, 0)
    end
  end
end
function on_quickequip_replace_btn_click(ctrl)
  bo2.PlaySound2D(578)
  for idx, val1 in ipairs(quickequip_tab) do
    if val1.ctrl:search("highlight").visible == true then
      quickequip_replace(idx)
    end
  end
end
function on_equip_index(slot, index, item_info)
  if ui_personal.ui_broken_equipment ~= nil then
    ui_personal.ui_broken_equipment.update_equip()
  end
  if ui_skill ~= nil then
    if item_info == ui.item_of_coord(bo2.eItemArray_InSlot, bo2.eItemSlot_HWeapon) then
      ui_skill.update_wheapon()
    elseif item_info == ui.item_of_coord(bo2.eItemArray_InSlot, bo2.eItemSlot_2ndWeapon) then
      ui_skill.update_sw_bar()
      if item_info ~= nil then
        local excel = bo2.gv_equip_item:find(item_info.excel_id)
        if excel == nil then
          return
        end
        ui.skill_insert(excel.use_par[0], 1, 3)
        cur_sweapon = item_info
      elseif sys.check(cur_sweapon) then
        local excel = bo2.gv_equip_item:find(cur_sweapon.excel_id)
        if excel == nil then
          return
        end
        ui.skill_remove(excel.use_par[0])
        cur_sweapon = nil
      end
    end
  end
end
function on_btn_slot_enhance(btn)
  ui_personal.w_bg.color = ui.make_color(SHARED("FF485069"))
  ui_personal.w_major:search("cmn_tab_bar").visible = false
  ui_personal.ui_equip.w_equip:search("slots").visible = false
  ui_personal.ui_equip.w_equip:search("slots_enhance").visible = true
end
function on_btn_back_equip(btn)
  ui_personal.w_bg.color = ui.make_color(SHARED("FFFFFFFF"))
  ui_personal.w_major:search("cmn_tab_bar").visible = true
  ui_personal.ui_equip.w_equip:search("slots").visible = true
  ui_personal.ui_equip.w_equip:search("slots_enhance").visible = false
end
function on_self_slot_enhance(obj, ft, idx)
  min_enhance_level = 256
  local max_val = get_slotenhance_maxLv()
  for key, val in ipairs(slot_name_tab) do
    local slot_card = w_equip:search(val.ctrl_name)
    if slot_card ~= nil then
      local val2 = obj:get_flag_int8(val.index)
      if val2 > 0 then
        slot_card:search("lb_num").text = sys.format("%d", val2)
        if max_val <= val2 then
          slot_card:search("lb_num").color = ui.make_color(SHARED("FF00FF00"))
        else
          slot_card:search("lb_num").color = ui.make_color(SHARED("FFFFF9CC"))
        end
        val.value = val2
      else
        slot_card:search("lb_num").text = ""
      end
      if val2 < min_enhance_level then
        min_enhance_level = val2
      end
    end
  end
  star_num = 0
  if min_enhance_level == 256 then
    min_enhance_level = 0
    return
  end
  local size = bo2.gv_slot_enhance.size
  for i = 0, size - 1 do
    local enhance_excel = bo2.gv_slot_enhance:get(i)
    if min_enhance_level >= enhance_excel._level then
      local index = math.fmod(i, 10)
      local star_panel = w_equip:search("star_panel_" .. index)
      if star_panel ~= nil then
        star_panel.mouse_able = true
        star_panel:search("animation").visible = true
        local star_url = "$image/personal/star.png|0,0,27,27"
        if enhance_excel._level > 100 then
          star_url = "$image/personal/star1.png|0,0,27,27"
          if enhance_excel._level > 200 then
            star_url = "$image/personal/star2.png|0,0,27,27"
          end
        end
        star_panel:search("bg_star").image = star_url
        star_panel:search("bg_star").visible = true
        star_panel:search("animation"):reset()
      end
    else
      local star_panel = w_equip:search("star_panel_" .. i)
      if star_panel ~= nil then
        star_panel.mouse_able = true
      end
      star_num = i
      break
    end
  end
  update_slot_enhance_detail_panel()
  update_slotenhance_cd()
end
function on_slots_enhance_visible(ctrl, vis)
  w_equip_star_timer.suspended = not ctrl.visible
  if vis == true then
    for key, val in ipairs(slot_name_tab) do
      local slot_card = w_equip:search(val.ctrl_name)
      if slot_card ~= nil and milestone_complete(val.milestone_id) then
        slot_card:search("bg_pic").visible = true
        slot_card.svar = true
      end
    end
    ui_handson_teach.test_complate_slotenhance_open_sloten(true)
    update_slotenhance_cd()
  end
end
function on_star_flash_timer(timer)
  if star_num == 0 then
    return
  end
  local flash_num = math.random(0, star_num)
  local star_panel = w_equip:search("star_panel_" .. flash_num)
  if star_panel ~= nil and star_panel:search("animation").visible == true then
    star_panel:search("animation"):reset()
    timer.period = math.random(1000, 2000)
  else
  end
end
function get_slot_trait_list_id(slot, slot_level)
  local excel = bo2.gv_slot_enhance_level_slot_trait:find(slot_level)
  if excel ~= nil and excel.vSlotList.size == excel.vTraitList.size then
    local size_list = excel.vSlotList.size
    for i = 0, size_list - 1 do
      if excel.vSlotList[i] == slot then
        return excel.vTraitList[i]
      end
    end
  end
  return -1
end
function on_star_panel_mouse(btn, msg, pos, wheel)
  if msg == ui.mouse_inner then
    local slot_index
    local enhance_lv = 0
    local request_lv = 0
    local milestone_id = 0
    for key, val in ipairs(slot_name_tab) do
      if tostring(btn.name) == val.ctrl_name then
        slot_index = val.index - bo2.ePlayerFlagInt8_EquipSlotEnhanceBegin + bo2.eItemSlot_EquipBeg
        enhance_lv = val.value
        request_lv = val.request_lv
        milestone_id = val.milestone_id
        break
      end
    end
    if slot_index ~= nil then
      local new_open = is_new_equip_slot_enhance_open(slot_index)
      local part_des = ui.get_text("item|slot" .. slot_index)
      local se_title_str = sys.format(ui.get_text("personal|slot_enhance_tiptitle"), part_des)
      if btn.svar ~= true then
        se_title_str = se_title_str .. ui.get_text("personal|unlock_des")
      end
      w_se_tip:search("se_title").mtf = se_title_str
      local info = ui.item_of_coord(bo2.eItemArray_InSlot, slot_index)
      local tip_card = w_se_tip:search("card")
      if info ~= nil then
        tip_card.image = "$icon/item/" .. info.excel.icon .. ".png"
      else
        tip_card.image = btn:search("bg_pic").image
        tip_card.irect = btn:search("bg_pic").irect
      end
      local stk_detail = sys.mtf_stack()
      stk_detail:push(sys.format("%s%s\n", ui.get_text("personal|slot_enhance_part"), part_des))
      if not new_open then
        stk_detail:push(sys.format("%s%.1f%%\n", ui.get_text("personal|slot_enhance_per"), enhance_val_perLv))
      end
      stk_detail:push(sys.format("%s%d", ui.get_text("personal|slot_enhance_lv"), enhance_lv))
      local text = w_se_tip:search("rb_text")
      text.mtf = stk_detail.text
      text.parent.visible = btn.svar == true
      local stk = sys.mtf_stack()
      stk:raw_push("<c+:ffd3a75e>")
      if btn.svar == true then
        stk:push(sys.format("%s\n", ui.get_text("personal|slot_enhance_property")))
      else
        stk:push(sys.format("%s\n", ui.get_text("personal|unlock_request")))
      end
      stk:raw_push("<c->")
      if btn.svar == true then
        local old_enhance_lv_val = enhance_lv
        if new_open then
          old_enhance_lv_val = 79 - enhance_lv_difference
        end
        ui_tool.ctip_push_unwrap(stk, sys.format(ui.get_text("personal|slot_enhance_detail"), part_des, enhance_val_perLv * old_enhance_lv_val))
        stk:raw_push("\n")
        local excelTrait
        if new_open then
          local index = get_slot_trait_list_id(slot_index, enhance_lv)
          if index ~= -1 then
            excelTrait = bo2.gv_slot_enhance_trait_list:find(index)
          end
        end
        if info ~= nil and info.excel ~= nil and enhance_lv ~= 0 then
          local datas = info.excel.datas
          local cnt = datas.size
          local atb_set = ui_tool.ctip_atb_set_create()
          local gs_score = 0
          local get_gs = function(id, fChg)
            local excel = {}
            local trait = bo2.gv_trait_list:find(id)
            if trait == nil then
              return 0
            end
            local modify_id = trait.modify_id
            local modify_value = trait.modify_value
            if fChg ~= nil and type(fChg) == "number" then
              modify_value = math.floor(modify_value * fChg / 100)
            end
            excel[modify_id] = modify_value
            local gs = ui_tool.ctip_calculate_item_rank(excel, nil, 2)
            return gs
          end
          for i = 0, cnt - 1 do
            ui_tool.ctip_atb_set_insert(atb_set, datas[i], enhance_val_perLv * old_enhance_lv_val)
            local gs = get_gs(datas[i], enhance_val_perLv * old_enhance_lv_val)
            gs_score = gs_score + gs
          end
          if excelTrait ~= nil and 0 < excelTrait.vTraitList.size then
            local nSizeTrait = excelTrait.vTraitList.size
            for i = 0, nSizeTrait - 1 do
              ui_tool.ctip_atb_set_insert(atb_set, excelTrait.vTraitList[i], 100)
              local gs = get_gs(excelTrait.vTraitList[i], 100)
              gs_score = gs_score + gs
            end
          end
          ui_tool.ctip_atb_set_output(atb_set, stk)
          ui_tool.ctip_push_sep(stk)
          ui_tool.ctip_push_text(stk, ui.get_text("tool|property_rank"), ui_tool.cs_tip_color_bound)
          local gs_text = sys.format(L("+%d"), gs_score)
          ui_tool.ctip_push_text(stk, gs_text, ui_tool.cs_tip_color_bound)
        elseif excelTrait ~= nil and 0 < excelTrait.vTraitList.size then
          local atb_set = ui_tool.ctip_atb_set_create()
          local nSizeTrait = excelTrait.vTraitList.size
          for i = 0, nSizeTrait - 1 do
            ui_tool.ctip_atb_set_insert(atb_set, excelTrait.vTraitList[i], 100)
          end
          ui_tool.ctip_atb_set_output(atb_set, stk, nil, nil, nil, color_white)
        end
        ui_tool.ctip_push_sep(stk)
        ui_tool.ctip_push_text(stk, ui.get_text("personal|left_click_info"), ui_tool.cs_tip_color_operation)
        w_se_tip.dy = 155
      else
        local player = safe_get_player()
        local level = player:get_atb(bo2.eAtb_Level)
        local lv_color = "00ff00"
        if request_lv > level then
          lv_color = "ff0000"
        end
        ui_tool.ctip_push_unwrap(stk, sys.format(ui.get_text("personal|unlock_lv"), request_lv), lv_color)
        local quest_list = bo2.gv_quest_list:find(2036)
        local milestone_list = bo2.gv_milestone_list:find(milestone_id)
        if quest_list ~= nil and milestone_list ~= nil then
          ui_tool.ctip_push_unwrap(stk, sys.format(ui.get_text("personal|unlock_quest"), quest_list.name, milestone_list.name), "ff0000")
        end
        w_se_tip.dy = 60
      end
      w_se_tip:search("se_detail").mtf = stk.text
      w_se_tip:tune("se_detail")
    end
    w_se_tip.x = btn.abs_area.p1.x + 40
    w_se_tip.y = btn.abs_area.p1.y
    w_se_tip.visible = true
  end
  if msg == ui.mouse_outer then
    w_se_tip.visible = false
  end
  if msg == ui.mouse_lbutton_up and btn.svar == true then
    open_slot_enhance_detail(btn)
  end
end
function on_slot_enhance_show(tip)
  local owner = tip.owner
  local star_index = string.match(tostring(owner.name), "%d")
  if star_index == nil then
    return
  end
  local enhance_excel = bo2.gv_slot_enhance:find(star_index + 1)
  if enhance_excel == nil then
    return
  end
  if min_enhance_level > 100 then
    enhance_excel = bo2.gv_slot_enhance:find(star_index + 11)
    if min_enhance_level > 200 then
      enhance_excel = bo2.gv_slot_enhance:find(star_index + 21)
    end
  end
  if enhance_excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  local eff_color = SHARED("808080")
  local eff_state = ui.get_text("personal|not_activate")
  if min_enhance_level < enhance_excel._level then
    ui_tool.ctip_push_unwrap(stk, sys.format(ui.get_text("personal|slot_enhance_title"), enhance_excel._level, min_enhance_level, enhance_excel._level), "D3A75E")
  else
    ui_tool.ctip_push_unwrap(stk, sys.format(ui.get_text("personal|slot_enhance_title1"), enhance_excel._level), "D3A75E")
    eff_color = SHARED("00FF00")
    eff_state = ui.get_text("personal|activate")
  end
  local function add_enhance_trait(enhance_excel, color, state)
    local nSizeTrait = enhance_excel._attribute.size - 1
    for i = 0, nSizeTrait do
      local trait_text = ui_tool.ctip_trait_text(enhance_excel._attribute[i])
      if trait_text ~= nil then
        local trait_des = sys.format("%s%s", ui.get_text("personal|effect"), trait_text)
        ui_tool.ctip_push_unwrap(stk, trait_des, color)
        stk:raw_push("<a:r>")
        ui_tool.ctip_push_unwrap(stk, state, color)
        stk:raw_push("<a:l>")
      end
    end
  end
  if min_enhance_level > 100 then
    local enhance = bo2.gv_slot_enhance:find(star_index + 1)
    add_enhance_trait(enhance, SHARED("00FF00"), ui.get_text("personal|activate"))
    if min_enhance_level > 200 then
      enhance = bo2.gv_slot_enhance:find(star_index + 21)
      add_enhance_trait(enhance, SHARED("00FF00"), ui.get_text("personal|activate"))
    end
  end
  add_enhance_trait(enhance_excel, eff_color, eff_state)
  ui_tool.ctip_push_sep(stk)
  for key, val in ipairs(slot_name_tab) do
    local part_des = sys.format("%s (lv.%d) ", ui.get_text("item|slot" .. val.index - bo2.ePlayerFlagInt8_EquipSlotEnhanceBegin + bo2.eItemSlot_EquipBeg), val.value)
    ui_tool.ctip_push_unwrap(stk, part_des, "FFFFFF")
    stk:raw_push("<a:r>")
    if val.value < enhance_excel._level then
      ui_tool.ctip_push_unwrap(stk, ui.get_text("personal|not_satisfy"), "808080")
    else
      ui_tool.ctip_push_unwrap(stk, ui.get_text("personal|satisfy"), "00FF00")
    end
    stk:raw_push("<a:l>")
    stk:raw_push("\n")
  end
  ui_tool.ctip_push_sep(stk)
  stk:push(sys.format(ui.get_text("personal|suit_des"), enhance_excel._level))
  ui_tool.ctip_show(owner, stk)
end
function update_slotenhance_milestone(milestone_id)
  if milestone_id < 40022 then
    return
  end
  for key, val in ipairs(slot_name_tab) do
    if milestone_id == val.milestone_id then
      local slot_card = w_equip:search(val.ctrl_name)
      if slot_card ~= nil then
        if val.flicker_control == nil then
          local card_parent = slot_card.parent
          local flicker_control = ui.create_control(card_parent, "panel")
          flicker_control:load_style(L("$gui/frame/help/tool_handson.xml"), L("tool_handson_flicker"))
          flicker_control:move_to_head()
          flicker_control.size = slot_card.size
          flicker_control.margin = slot_card.margin
          flicker_control.dock = slot_card.dock
          val.flicker_control = flicker_control
        end
        if ui_personal.ui_equip.w_equip_slots_enhance.visible == true then
          slot_card:search("bg_pic").visible = true
          slot_card.svar = true
        else
          open_slot_panel = true
          if slot_guide == nil then
            slot_guide = ui.create_control(ui.find_control("$phase:main"), "panel")
            slot_guide:load_style("$frame/personal/equip.xml", "slot_enhance_guide")
          else
            slot_guide.visible = true
          end
          local guide_panel = slot_guide:search("guide_panel")
          if guide_panel == nil then
            return
          end
          ui_widget.tip_make_view(guide_panel, sys.format(L("<handson:0,6,%s>"), ui.get_text("personal|se_handson_tip")))
          guide_panel:show_popup(ui_qbar.w_btn_personal, L("x1"), ui.rect(0, -20, 0, 0))
        end
      end
      return
    end
  end
end
function update_slotenhance_cd()
  local mb_data = bo2.gv_cooldown_list:find(ci_slot_enhance_cd)
  local remain_time = bo2.get_cooldown_remain_time(ci_slot_enhance_cd)
  local max_num = mb_data.token
  local cur_num = 0
  if remain_time ~= 0 then
    cur_num = max_num - bo2.get_cooldown_token(ci_slot_enhance_cd)
  end
  local cd_label = ui_personal.ui_equip.w_equip_slots_enhance:search("slotenhance_cd")
  if cd_label ~= nil then
    cd_label.text = ui_widget.merge_mtf({cur_num = cur_num, max_num = max_num}, ui.get_text("personal|today_se_count"))
  end
end
function on_pic_slot_enhance_disable_tip_show(tip)
  local quest = bo2.gv_quest_list:find(2036)
  local milestone = bo2.gv_milestone_list:find(40019)
  local tip_text = ui.get_text("personal|btn_slot_enhance_disable_tip")
  if quest ~= nil and milestone ~= nil then
    tip_text = sys.format(ui.get_text("personal|btn_slot_enhance_disable_tip"), quest.level_min, quest.name, milestone.name)
  end
  ui_widget.tip_make_view(tip.view, tip_text)
end
function on_slotenhance_cd_des_init(ctrl)
  local cd = bo2.gv_cooldown_list:find(ci_slot_enhance_cd)
  if cd == nil then
    ctrl.visible = false
    return
  end
  local time = 0
  if cd.mode == 2 then
    time = cd.time
  end
  ctrl.text = sys.format(ui.get_text("personal|slotenhance_cd_des"), time)
end
function is_new_equip_slot_enhance_open(slot)
  if slot == 0 or slot == nil then
    return false
  end
  local obj = bo2.player
  local level = obj:get_atb(bo2.eAtb_Level)
  local index = slot - bo2.eItemSlot_EquipBeg + bo2.ePlayerFlagInt8_EquipSlotEnhanceBegin
  local slot_level = obj:get_flag_int8(index)
  if level >= 79 and slot_level >= level - enhance_lv_difference then
    return true
  end
  return false
end
function on_cooldown_update(cmd, data)
  local cooldown_id = data:get(packet.key.cooldown_id).v_int
  if cooldown_id == 5667 then
    update_slotenhance_cd()
  end
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_DelCooldown, on_cooldown_update, "ui_personal.ui_equip.on_cooldown_update")
