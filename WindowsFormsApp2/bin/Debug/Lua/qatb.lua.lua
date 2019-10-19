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
    end,
    ["get_flag_int16"] = function(obj, idx)
      return 0
    end
  }
  return player
end
function atb_update()
  local player = atb_get_player()
  if not sys.check(player) then
    return
  end
  local value = player:get_atb(bo2.eAtb_Cha_Exp)
  local limit = value * 2 + 1
  local save_exp = 0
  local level = player:get_atb(bo2.eAtb_Level)
  local levelup = bo2.gv_player_levelup:find(level)
  if levelup ~= nil then
    limit = levelup.exp
    save_exp = levelup.save_exp
  end
  w_qatb:apply_dock(true)
  local fig
  if value >= limit then
    w_exp.visible = false
    w_exp_full.visible = true
    fig = w_exp_store
  else
    w_exp.visible = true
    w_exp_full.visible = false
    fig = w_exp
  end
  local per = 0
  if limit >= 1 then
    if value >= limit then
      per = (value - limit) / (save_exp - limit)
    else
      per = value / limit
    end
    if per > 1 then
      per = 1
    end
  end
  local fp = w_exp.parent
  fig.dx = (fp.dx - 4) * per + 4
end
function on_make_tip(tip)
  local player = atb_get_player()
  if not sys.check(player) then
    return
  end
  local value = player:get_atb(bo2.eAtb_Cha_Exp)
  local limit = value * 2 + 1
  local save_exp = 0
  local level = player:get_atb(bo2.eAtb_Level)
  local levelup = bo2.gv_player_levelup:find(level)
  if levelup ~= nil then
    limit = levelup.exp
    save_exp = levelup.save_exp
  end
  local cur_cul = player:get_flag_int16(bo2.ePlayerFlagInt16_Cultivation)
  local expand_cul = player:get_flag_int16(bo2.ePlayerFlagInt16_Cultivation_Expended)
  local max_cul = bo2.gv_define:find(1052).value
  local limit_cul = bo2.gv_define:find(1053).value
  local per_cul = bo2.gv_cultoexp:find(level).exp
  local open_level = tonumber(tostring(bo2.gv_define:find(1076).value))
  ui.log("%s %s %s", bo2.gv_define:find(1076).value, tostring(bo2.gv_define:find(1076).value), tonumber(tostring(bo2.gv_define:find(1076).value)))
  local stk = sys.mtf_stack()
  if level < open_level then
    stk:merge({
      cur = value,
      limit = limit,
      save = save_exp
    }, ui.get_text("personal|exp_des1"))
  else
    stk:merge({
      cur = value,
      limit = limit,
      save = save_exp,
      cur_cul = cur_cul,
      save_cul = max_cul,
      expand_cul = expand_cul,
      expand_limit = limit_cul,
      rate = per_cul
    }, ui.get_text("personal|exp_des"))
  end
  local next_level = 999999
  local skills = {}
  local xinfa_list = ui_skill_master.w_zhuzhi_xinfa_list
  for i = 0, xinfa_list.item_count - 1 do
    local item = xinfa_list:item_get(i)
    local item_id = item:search("xinfa_card").excel_id
    if item_id > 0 then
      local xinfa_info = ui.xinfa_find(item_id)
      local skill_info = xinfa_info.head_skill
      while skill_info ~= nil do
        local skill_level = bo2.gv_skill_level:find(skill_info.excel_id)
        if skill_level ~= nil then
          local unlock = skill_level.unlock
          if level < unlock then
            if next_level > unlock then
              skills = {skill_info}
              next_level = unlock
            elseif unlock == next_level then
              table.insert(skills, skill_info)
              inst = true
            end
          end
        end
        skill_info = skill_info.next
      end
    end
  end
  if #skills > 0 then
    stk:push("\n")
    stk:merge({level = next_level}, ui.get_text("qbar|exp_tip_skill"))
    for i, v in ipairs(skills) do
      if i > 1 then
        stk:push(",")
      end
      stk:push(bo2.gv_skill_group:find(v.excel_id).name)
    end
  end
  ui_widget.tip_make_view(tip.view, stk.text)
end
function atb_post_update()
  if not sys.check(w_exp) then
    return
  end
  w_qatb:insert_post_invoke(atb_update, "ui_qbar.ui_qatb.atb_update")
end
function on_exp_init()
  atb_post_update()
end
function on_self_atb(obj, ft, idx)
  atb_update()
end
function on_self_enter(obj, msg)
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Cha_Exp, on_self_atb, "ui_qbar.ui_qatb.on_self_atb")
  obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Level, on_self_atb, "ui_qbar.ui_qatb.on_self_atb")
  obj:insert_on_flagmsg(bo2.eFlagType_Int16, bo2.ePlayerFlagInt16_Cultivation, on_self_atb, "ui_qbar.ui_qatb.on_self_atb")
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_qbar.ui_qatb.on_self_enter")
