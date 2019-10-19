local ui_tab = ui_widget.ui_tab
local atb_tab_btn_uri = SHARED("$frame/personal/common.xml")
local atb_tab_btn_sty = SHARED("common_tab_btn2")
local atb_tab_page_uri = SHARED("$frame/personal/view_equip.xml")
local atb_tab_page_sty = SHARED("atb_tab_page_")
local atb_tab_name_phy = SHARED("phy")
local atb_tab_name_mgc = SHARED("mgc")
local src_mod = ui_personal.ui_equip
local cs_camp_text = {
  [bo2.eCamp_Blade] = ui.get_text("phase|camp_blade"),
  [bo2.eCamp_Sword] = ui.get_text("phase|camp_sword")
}
local init_once = function()
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
      value = bo2.eAtb_Cha_AtbPoint
    },
    atb_vit = {
      value = bo2.eAtb_Vit,
      basic = bo2.eAtb_BaseVit
    },
    atb_ske = {
      value = bo2.eAtb_Ske,
      basic = bo2.eAtb_BaseSke
    },
    atb_agi = {
      value = bo2.eAtb_Agi,
      basic = bo2.eAtb_BaseAgi
    },
    atb_str = {
      value = bo2.eAtb_Str,
      basic = bo2.eAtb_BaseStr
    },
    atb_int = {
      value = bo2.eAtb_Int,
      basic = bo2.eAtb_BaseInt
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
    atb_dmg_score = {on_make_text = on_make_dmg_score_text},
    atb_def_score = {on_make_text = on_make_def_score_text},
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
  atb_def.atb_fight_score.tip = ui.get_text("atb|tip_atb_fight_score_view")
  atb_reg = {}
  fake_player = ui_personal.ui_equip.fake_player
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
    },
    b
  }
  for n, v in pairs(slot_def) do
    local slot = w_equip:search(n)
    slot.grid = v.equip
  end
end
function on_make_limit_text(player, atb)
  return src_mod.on_make_limit_text(player, atb)
end
function on_make_range_text(player, atb)
  return sys.format("%d-%d", player:get_atb(atb.value), player:get_atb(atb.range))
end
function on_make_value_text(player, atb)
  return src_mod.on_make_value_text(player, atb)
end
function on_make_level_text(player, atb)
  local lvl = player:get_atb(atb.value)
  return sys.format("Lv%d", lvl)
end
function on_make_dmg_score_text(player, atb)
  return src_mod.on_make_dmg_score_text(player, atb)
end
function on_make_def_score_text(player, atb)
  return src_mod.on_make_def_score_text(player, atb)
end
local function make_fight_score_text(player, atb)
  local z = src_mod.on_make_fight_score_text(player, atb)
  local get_atb2 = player.get_atb2
  if get_atb2 ~= nil then
    local get_atb = player.get_atb
    player.get_atb = get_atb2
    local y = src_mod.on_make_fight_score_text(player, atb)
    player.get_atb = get_atb
    return y, z
  end
  return z, z
end
function on_make_fight_score_text(player, atb)
  local y, z = make_fight_score_text(player, atb)
  local pic = atb.label.parent:search("pic_score_up")
  pic.visible = y ~= z
  return z
end
function on_make_tip_fight_score(player, atb)
  local y, z = make_fight_score_text(player, atb)
  if y ~= z then
    local v = sys.variant()
    v:set("z", z)
    v:set("y", y)
    return sys.mtf_merge(v, ui.get_text("atb|tip_atb_fight_score_view2"))
  end
  return src_mod.on_make_tip_fight_score(player, atb)
end
function on_make_sex_text(player, atb)
  local sex = player:get_atb(atb.value)
  local t = ui.get_text(sys.format("common|sex%d", sex))
  return t
end
function on_make_exp_text(player, atb)
  return src_mod.on_make_exp_text(player, atb, true)
end
function on_exp_move()
  on_make_exp_text(safe_get_player(), atb_def.atb_exp)
end
function on_make_career_text(player, atb)
  return src_mod.on_make_career_text(player, atb)
end
function on_make_career_tip(player, atb)
  return src_mod.on_make_career_tip(player, atb)
end
function on_make_tip(player, atb)
  return atb.tip
end
function on_make_tip_anti(player, atb)
  return src_mod.on_make_tip_anti(player, atb)
end
function on_make_tip_def(player, atb)
  return src_mod.on_make_tip_def(player, atb)
end
function on_make_tip_atk(player, atb)
  return src_mod.on_make_tip_atk(player, atb)
end
function on_make_tip_tenacity(player, atb)
  return src_mod.on_make_tip_tenacity(player, atb)
end
function on_make_tip_nicety(player, atb)
  return src_mod.on_make_tip_nicety(player, atb)
end
function on_make_tip_dmg(player, atb)
  return src_mod.on_make_tip_dmg(player, atb)
end
function on_make_tip_dead(player, atb)
  return src_mod.on_make_tip_dead(player, atb)
end
function on_make_basic_tip(player, atb)
  return src_mod.on_make_basic_tip(player, atb)
end
function on_make_tip_transfer(player, atb)
  return src_mod.on_make_tip_transfer(player, atb)
end
function on_make_tip_hit(player, atb)
  return src_mod.on_make_tip_hit(player, atb)
end
function safe_get_player()
  return fake_player
end
function on_atb_tip_make(tip)
  local atb = atb_def[tostring(tip.owner.name)]
  if atb == nil then
    return
  end
  local text = atb.on_make_tip(safe_get_player(), atb)
  ui_widget.tip_make_view(tip.view, text)
end
function on_atb_init(p)
  src_mod.atb_init(p, atb_def, atb_reg)
end
function update_atb(player)
  src_mod.update_atb(player, atb_reg)
end
function on_atb_tab_press(btn, press)
  if press then
    bo2.PlaySound2D(586)
  end
end
function atb_tab_insert(tab, name, x)
  local page_sty = atb_tab_page_sty .. name
  ui_tab.insert_suit(tab, name, atb_tab_btn_uri, atb_tab_btn_sty, atb_tab_page_uri, page_sty)
  local btn = ui_tab.get_button(tab, name)
  btn.tip.text = ui.get_text("personal|title_" .. page_sty)
  btn:search("tab_pic").irect = ui.rect(x, 0, x + 27, 128)
  btn:insert_on_press(on_atb_tab_press, "ui_view_personal.ui_view_equip.on_atb_tab_press")
end
function on_atb_tab_init(tab)
  w_atb_tab = tab
  atb_tab_insert(tab, atb_tab_name_phy, 0)
  atb_tab_insert(tab, atb_tab_name_mgc, 31)
end
function bind_player(obj)
  local sex = obj:get_atb(bo2.eAtb_Sex)
  ui_view_personal.w_bg.image = sys.format("$image/personal/512x512/bg_%d.png|0,0,491,470", sex)
end
function do_update()
  bind_player(fake_player)
  update_atb(fake_player)
  src_mod.update_pro(fake_player, w_atb_tab, atb_def)
  src_mod.update_title(fake_player, ui_view_personal.w_view_personal)
  sys.pcall(ui_view_personal.ui_view_match.updata, fake_player)
  local guild_name = fake_player.guild_name
  if guild_name.size > 0 then
    w_lb_guild_name.text = sys.format("<%s>", fake_player.guild_name)
  else
    w_lb_guild_name.text = nil
  end
  local camp_id = safe_get_player():get_atb(bo2.eAtb_Camp)
  local camp_name = cs_camp_text[camp_id]
  if camp_name.size > 0 then
    w_lb_camp_name.text = sys.format("<%s>", camp_name)
  else
    w_lb_camp_name.text = nil
  end
  w_skill_score.text = ui.get_text("skill|xinfa_score") .. fake_player.skill_score
end
function update_data(data)
  local flag = data:get(packet.key.player_view_flag)
  local atb = flag:get(bo2.eFlagType_Atb)
  local equip = data:get(packet.key.player_view_equip)
  local flag32 = flag:get(bo2.eFlagType_Int32)
  local flag16 = flag:get(bo2.eFlagType_Int16)
  fake_player = {
    get_atb = function(obj, idx)
      local v = atb:get(idx).v_int
      return v
    end,
    get_flag32 = function(obj, idx)
      local v = flag32:get(idx).v_int
      return v
    end,
    get_flag16 = function(obj, idx)
      local v = flag16:get(idx).v_int
      return v
    end,
    equip = equip,
    name = data:get(packet.key.cha_name).v_string,
    guild_name = data:get(packet.key.guild_name).v_string,
    skill_score = data:get(packet.key.player_view_skill_score).v_int,
    gzs = data:get(packet.key.player_view_gzs).v_int,
    GetPlayerArenaRank = function(obj)
      local flag = flag32:get(bo2.ePlayerFlagInt32_ArenaRankScore)
      local excel = bo2.GetArenaRankByScore(flag.v_int)
      return excel
    end
  }
  if flag:has(100 + bo2.eFlagType_Atb) then
    do
      local atb2 = flag:get(100 + bo2.eFlagType_Atb)
      function fake_player.get_atb2(obj, idx)
        local v = atb2:get(idx).v_int
        return v
      end
    end
  end
  local item = data:get(packet.key.player_view_item)
  ui.item_box_clear(bo2.eItemBox_OtherSlot)
  for i = 0, item.size - 1 do
    local n, v = item:fetch_nv(i)
    ui.item_create_data(bo2.eItemBox_OtherSlot, n.v_int, v)
  end
  do_update()
end
function test_show()
  ui.find_control("$frame:view_personal").visible = true
  do_update()
end
function on_observable(w, vis)
  if sys.check(w_affix) then
    w_affix.visible = vis
  end
end
init_once()
