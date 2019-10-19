function atb_get_player()
  local player = bo2.player
  if player ~= nil then
    return player
  end
  player = {
    [bo2.eAtb_Level] = 33,
    [bo2.eAtb_Cha_Exp] = 45000,
    [bo2.eAtb_Cha_ST] = 40,
    [bo2.eAtb_Cha_STMax] = 77,
    [bo2.eAtb_FT] = 43,
    [bo2.eAtb_FTMax] = 65,
    ["get_atb"] = function(obj, idx)
      local v = obj[idx]
      if v == nil then
        return 0
      end
      return v
    end
  }
  return player
end
function atb_update()
  ui.log("skill atb_update")
  local player = atb_get_player()
  if not sys.check(player) then
    return
  end
  local value = player:get_atb(bo2.eAtb_Cha_Exp)
  local limit = value * 2 + 1
  local save_exp = 0
  local levelup = bo2.gv_player_levelup:find(player:get_atb(bo2.eAtb_Level))
  if levelup ~= nil then
    limit = levelup.exp
    save_exp = levelup.save_exp
  end
  ui.log("exp %s level", value, levelup)
  w_qatb:apply_dock(true)
  local fig
  if value >= limit then
    w_exp.visible = false
    w_exp_full.visible = true
    fig = w_exp_full
  else
    w_exp.visible = true
    w_exp_full.visible = false
    fig = w_exp
  end
  local per = 0
  if limit >= 1 then
    per = value / limit
    if per > 1 then
      per = 1
    end
  end
  local fp = fig.parent
  fig.dx = fp.dx * per
  ui.log("fig.dx %s %s", fig.dx, per)
  local arg = sys.variant()
  arg:set("cur_exp", value)
  arg:set("level_exp", limit)
  arg:set("save_exp", save_exp)
  fp.tip.text = sys.format(arg, ui.get_text("skill|tip_level_exp"))
  w_exp_lb.text = sys.format("%d/%d", value, limit)
end
function atb_post_update()
  ui.log("atb_post_update")
  if not sys.check(w_exp) then
    return
  end
  w_qatb:insert_post_invoke(atb_update, "ui_skill.ui_qatb.atb_update")
end
function on_exp_init()
  atb_post_update()
end
function on_self_atb(obj, ft, idx)
  atb_update()
end
function on_self_enter(obj, msg)
  ui.log("skill on_self_enter")
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Cha_Exp, on_self_atb, "ui_skill.ui_qatb.on_self_atb")
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Level, on_self_atb, "ui_skill.ui_qatb.on_self_atb")
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_skill.ui_qatb.on_self_enter")
