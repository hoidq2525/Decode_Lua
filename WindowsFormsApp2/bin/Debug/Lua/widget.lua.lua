c_drop_type_item = SHARED("drop_type_item")
c_drop_type_skill = SHARED("drop_type_skill")
c_drop_type_PetSkill = SHARED("drop_type_petskill")
c_drop_type_PetPortrait = SHARED("drop_type_petportrait")
c_drop_type_shortcut = SHARED("drop_type_shortcut")
c_drop_type_repair = SHARED("drop_type_repair")
c_drop_type_useto = SHARED("drop_type_useto")
c_drop_type_freezeitem = SHARED("drop_type_freezeitem")
c_drop_type_unfreezeitem = SHARED("drop_type_unfreezeitem")
c_drop_type_freezeridepet = SHARED("drop_type_freezeridepet")
c_drop_type_unfreezeridepet = SHARED("drop_type_unfreezeridepet")
c_drop_type_lianzhao = SHARED("drop_type_lianzhao")
c_drop_type_ = SHARED("drop_type")
c_disable_destroy = "disable_destroy"
c_drop_type_im = SHARED("drop_type_im")
c_drop_type_ride = SHARED("drop_type_ride")
c_drop_type_fitting = SHARED("drop_type_fitting")
c_drop_type_equippack = SHARED("drop_type_equippack")
c_drop_type_skilltoitem = SHARED("drop_type_skilltoitem")
c_drop_type_gem_inlay = SHARED("drop_type_gem_inlay")
c_drop_type_punch = SHARED("drop_type_punch")
c_drop_type_seal = SHARED("drop_type_seal")
c_drop_type_teachskill = SHARED("c_drop_type_teachskill")
function check_drop(drop_data, drop_type)
  if drop_data == nil then
    return false
  end
  return drop_data:get(c_drop_type_).v_string == L(drop_type)
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
function merge_mtf(t, s)
  local var = sys.variant()
  for n, v in pairs(t) do
    var:set(L(n), L(v))
  end
  return sys.mtf_merge(var, s)
end
function level_bind_scn()
  local scn = bo2.scn
  if scn ~= nil and scn.excel.id == 143 then
    return 60
  end
  return 0
end
function level_safe_scn(player)
  if player == nil then
    player = bo2.player
  elseif player ~= bo2.player then
    return player:get_atb(bo2.eAtb_Level)
  end
  local lv = level_bind_scn()
  if lv ~= 0 then
    return lv
  end
  if player ~= nil then
    return player:get_atb(bo2.eAtb_Level)
  end
  return 0
end
local init_once = function()
  if rawget(_M, "g_already_init") ~= nil then
    return
  end
  g_already_init = 1
  g_esc_stk = {}
  g_leavescn_stk = {}
end
function on_close_click(btn)
  if sys.check(btn) ~= true then
    return
  end
  local p = btn.topper
  if p == nil then
    return
  end
  p.visible = false
end
function on_tree_node_toggle_click(btn)
  local p = btn
  while true do
    if p == nil or sys.is_type(p, "ui_tree_item") then
      break
    end
    p = p.parent
  end
  if p == nil then
    return
  end
  p.expanded = not p.expanded
end
function on_tree_node_toggle_init(pn)
  local p = pn
  while true do
    if p == nil or sys.is_type(p, "ui_tree_item") then
      break
    end
    p = p.parent
  end
  if p == nil then
    return
  end
  local btn_plus = pn:search("btn_plus")
  local btn_minus = pn:search("btn_minus")
  local function on_tree_node_toggle(item, expanded)
    if expanded then
      btn_plus.visible = false
      btn_minus.visible = true
    else
      btn_plus.visible = true
      btn_minus.visible = false
    end
  end
  on_tree_node_toggle(p, p.expanded)
  p:insert_on_expanded(on_tree_node_toggle)
end
function on_phase_visible(ctrl, vis)
  if vis then
    ui.set_default_focus(ctrl)
  else
    local f = ui.get_default_focus()
    while f ~= nil do
      if f == ctrl then
        ui.set_default_focus(nil)
        break
      end
      f = f.parent
    end
  end
end
local s_rb_text = SHARED("rb_text")
function tip_try_tune(view, dx, dy)
  view.dx = dx
  view:tune_y(s_rb_text)
  view:tune_x(s_rb_text)
  if dy < view.dy then
    return false
  end
  view:tune(s_rb_text)
  return true
end
function tip_make_view(view, text)
  local box = view:search(s_rb_text)
  box.mtf = text
  if tip_try_tune(view, 200, 360) then
    if view.dx < 20 then
      view.dx = 20
    end
    if 20 > view.dy then
      view.dy = 20
    end
    return
  end
  if tip_try_tune(view, 240, 440) then
    return
  end
  if tip_try_tune(view, 320, 540) then
    return
  end
  if tip_try_tune(view, 400, 640) then
    return
  end
  if tip_try_tune(view, 480, 480) then
    return
  end
  view:tune(s_rb_text)
end
function tip_make_view_custom(view, text, dx)
  local box = view:search(s_rb_text)
  box.mtf = text
  if dx < 20 then
    dx = 20
  end
  if tip_try_tune(view, dx, 640) then
    return
  end
  view:tune(s_rb_text)
end
function on_make_tip(tip)
  tip_make_view(tip.view, tip.text)
end
local border_sound_table = {
  [SHARED("$frame:personal")] = {show = 507, hide = 508},
  [SHARED("$frame:view_personal")] = {show = 507, hide = 508},
  [SHARED("$frame:item")] = {show = 509, hide = 510},
  [SHARED("$frame:ridepet")] = {show = 507, hide = 508},
  [SHARED("$frame:quest_new")] = {show = 511, hide = 512},
  [SHARED("$frame:skill")] = {show = 513, hide = 514},
  [SHARED("$frame:match_test")] = {show = 515, hide = 516},
  [SHARED("$frame:cloned_battle")] = {show = 515, hide = 516},
  [SHARED("$frame:md")] = {show = 517, hide = 518},
  [SHARED("$frame:guild")] = {show = 519, hide = 520},
  [SHARED("$frame:supermarket2")] = {show = 521, hide = 522},
  [SHARED("$frame:ui_log_deal")] = {show = 511, hide = 512},
  [SHARED("$frame:stallowner")] = {show = 511, hide = 512},
  [SHARED("$frame:top_win")] = {show = 511, hide = 512},
  [SHARED("$frame:stallsurround")] = {show = 511, hide = 512},
  [SHARED("$frame:lianzhao")] = {show = 578, hide = 578},
  [SHARED("$frame:huazhao")] = {show = 578, hide = 578},
  [SHARED("$frame:champion")] = {show = 515, hide = 516},
  [SHARED("$frame:guild_hall_mgr")] = {show = 578, hide = 579},
  [SHARED("$frame:guild_view")] = {show = 578, hide = 579},
  [SHARED("$frame:guild_apply_mgr")] = {show = 578, hide = 579},
  [SHARED("$frame:schedule")] = {show = 578, hide = 579},
  [SHARED("$frame:im_info_panel")] = {show = 578, hide = 579},
  [SHARED("$frame:confirm_top")] = {show = 578, hide = 579},
  [SHARED("$frame:find_path")] = {show = 578, hide = 579},
  [SHARED("$frame:convene")] = {show = 580, hide = 581},
  [SHARED("$frame:boss_list")] = {show = 582, hide = 583},
  [SHARED("$frame:boss_list:affix")] = {show = 578, hide = 579},
  [SHARED("$frame:ui_mail")] = {show = 578, hide = 579},
  [SHARED("$frame:video")] = {show = 586, hide = 587},
  [SHARED("$frame:map")] = {show = 588, hide = 589},
  [SHARED("$frame:campaign")] = {show = 590, hide = 591},
  [SHARED("$frame:campaign_desc")] = {show = 590, hide = 591},
  [SHARED("$frame:shop")] = {show = 578, hide = 579},
  [SHARED("$frame:talk")] = {show = 578, hide = 579},
  [SHARED("$frame:bank")] = {show = 578, hide = 579},
  [SHARED("$frame:barbershop_facial")] = {show = 578, hide = 579},
  [SHARED("$frame:barbershop_haircut")] = {show = 578, hide = 579},
  [SHARED("$frame:impclear")] = {show = 578, hide = 579},
  [SHARED("$frame:imprint")] = {show = 578, hide = 579},
  [SHARED("$frame:make_avatar")] = {show = 578, hide = 579},
  [SHARED("$frame:reputation_quest")] = {show = 578, hide = 579},
  [SHARED("$frame:ui_askway")] = {show = 578, hide = 579},
  [SHARED("$frame:refine")] = {show = 578, hide = 579},
  [SHARED("$frame:make")] = {show = 578, hide = 579},
  [SHARED("$frame:enforce")] = {show = 578, hide = 579},
  [SHARED("$frame:inlay")] = {show = 578, hide = 579},
  [SHARED("$frame:pullout")] = {show = 578, hide = 579},
  [SHARED("$frame:composegem2")] = {show = 578, hide = 579},
  [SHARED("$frame:composegem5")] = {show = 578, hide = 579},
  [SHARED("$frame:enchant_upgrades")] = {show = 578, hide = 579},
  [SHARED("$frame:make_special_equip")] = {show = 578, hide = 579},
  [SHARED("$frame:identify_ride")] = {show = 578, hide = 579},
  [SHARED("$frame:face_lifting")] = {show = 578, hide = 579},
  [SHARED("$frame:body_lifting")] = {show = 578, hide = 579},
  [SHARED("$frame:ridepet_exp")] = {show = 578, hide = 579},
  [SHARED("$frame:ridepet_unseal")] = {show = 578, hide = 579},
  [SHARED("$frame:ridepet_skill_exp")] = {show = 578, hide = 579},
  [SHARED("$frame:ridepet_skill_add")] = {show = 578, hide = 579},
  [SHARED("$frame:ridepet_refine")] = {show = 578, hide = 579},
  [SHARED("$frame:chgprf_gemswap")] = {show = 578, hide = 579},
  [SHARED("$frame:change_profession")] = {show = 578, hide = 579},
  [SHARED("$frame:chgprf_shenbingswap")] = {show = 578, hide = 579},
  [SHARED("$frame:chgprf_equipswap")] = {show = 578, hide = 579},
  [SHARED("$frame:tianwu_swap")] = {show = 578, hide = 579},
  [SHARED("$frame:cuiqu")] = {show = 578, hide = 579},
  [SHARED("$frame:diaowen")] = {show = 578, hide = 579},
  [SHARED("$frame:smelt_gem")] = {show = 578, hide = 579},
  [SHARED("$frame:jingpo_guanzhu")] = {show = 578, hide = 579},
  [SHARED("$frame:title_swap")] = {show = 578, hide = 579}
}
function on_visible_sound(w, vis)
  local sound = border_sound_table[w.name]
  if sound == nil then
    return
  end
  local w = ui_main.w_top
  if w ~= nil and not w.visible then
    return
  end
  w = ui_loading.w_top
  if w ~= nil and w.visible then
    return
  end
  if vis then
    if sound.show ~= nil then
      bo2.PlaySound2D(sound.show)
    end
  elseif sound.hide ~= nil then
    bo2.PlaySound2D(sound.hide)
  end
end
function safe_play_sound(id)
  local w = ui_main.w_top
  if w ~= nil and not w.visible then
    return
  end
  w = ui_loading.w_top
  if w ~= nil and w.visible then
    return
  end
  bo2.PlaySound2D(id)
end
function on_border_visible(w, vis)
  on_visible_sound(w, vis)
  if not vis then
    return
  end
  local function on_move_to_head()
    if w.visible then
      w:move_to_head()
    end
  end
  w:insert_post_invoke(on_move_to_head, "ui_widget.on_border_visible")
end
function set_title(w, t)
  w:search("lb_title").text = t
end
function get_define_int(id)
  local x = bo2.gv_define:find(id)
  if x == nil then
    return 0
  end
  return x.value.v_int
end
local f_rot_angle = 90
function doll_rotl_press(w_scn, press)
  if press then
    w_scn.rotate_angle = -f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
end
function doll_rotr_press(w_scn, press)
  if press then
    w_scn.rotate_angle = f_rot_angle
  else
    w_scn.rotate_angle = 0
  end
end
function esc_stk_clear()
  g_esc_stk = {}
end
local cs_esc_on_move_to_head = SHARED("ui_widget.esc_on_move_to_head")
local esc_on_move_to_head = function(w)
  if w.visible then
    esc_stk_push(w)
  end
end
function esc_stk_push(w)
  if not sys.check(w) then
    return
  end
  esc_stk_remove(w)
  table.insert(g_esc_stk, w)
  w:insert_on_move_to_head(esc_on_move_to_head, cs_esc_on_move_to_head)
end
function esc_stk_remove(w)
  local i = 1
  local p = g_esc_stk[i]
  while p ~= nil do
    if not sys.check(p) or p == w then
      table.remove(g_esc_stk, i)
    else
      i = i + 1
    end
    p = g_esc_stk[i]
  end
end
function esc_stk_remove_focus(w)
  if not sys.check(w) then
    return table.maxn(g_esc_stk) > 0
  end
  local f = ui.get_focus()
  while sys.check(f) do
    if f == w then
      ui.get_focus().focus = false
      break
    end
    f = f.parent
  end
end
function esc_stk_pop(w)
  if w ~= nil then
    esc_stk_remove(w)
    esc_stk_remove_focus(w)
    return nil
  end
  local i = #g_esc_stk
  while i > 0 do
    w = g_esc_stk[i]
    if sys.check(w) and w.visible then
      break
    end
    table.remove(g_esc_stk, i)
    i = i - 1
  end
  if not sys.check(w) then
    return nil
  end
  return w
end
function on_esc_stk_visible(w, vis)
  if vis then
    esc_stk_push(w)
  else
    esc_stk_pop(w)
  end
end
function leavescn_stk_remove(w)
  local i = 1
  local p = g_leavescn_stk[i]
  while p ~= nil do
    if not sys.check(w) or p == w then
      table.remove(g_leavescn_stk, i)
    else
      i = i + 1
    end
    p = g_leavescn_stk[i]
  end
end
function leavescn_stk_close_all()
  local temp_leavescn_stk = {}
  for i, w in pairs(g_leavescn_stk) do
    temp_leavescn_stk[i] = w
  end
  for _, w in pairs(temp_leavescn_stk) do
    if sys.check(w) == true then
      w.visible = false
    end
  end
  temp_leavescn_stk = {}
  g_leavescn_stk = {}
end
function leavescn_stk_push(w)
  if not sys.check(w) then
    return nil
  end
  leavescn_stk_remove(w)
  table.insert(g_leavescn_stk, w)
end
function leavescn_stk_pop(w)
  if not sys.check(w) then
    return nil
  end
  leavescn_stk_remove(w)
end
function on_leavescn_stk_visible(w, vis)
  if vis then
    leavescn_stk_push(w)
  else
    leavescn_stk_pop(w)
  end
end
function on_player_leave()
  leavescn_stk_close_all()
end
init_once()
