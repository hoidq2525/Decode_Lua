cs_tip_title_enter = SHARED("<a+:m><lb:art,18,,%.6X|")
cs_tip_title_enter_s = SHARED("<a+:m><lb:art,18,,%s|")
cs_tip_title_enter_n = SHARED("<a+:m><lb:art,18,,|")
cs_tip_title_leave = SHARED("><a->")
cs_tip_sep = SHARED([[
<tf+:micro>
<sep>
<tf->]])
cs_tip_c_add = SHARED("<c+:%.6X>")
cs_tip_c_add_s = SHARED("<c+:%s>")
cs_tip_c_sub = SHARED("<c->")
cs_tip_a_add = SHARED("<a+:%s>")
cs_tip_a_sub = SHARED("<a->")
cs_tip_a_add_l = SHARED("<a+:l>")
cs_tip_a_add_m = SHARED("<a+:m>")
cs_tip_a_add_r = SHARED("<a+:r>")
cs_tip_mb_data_item_list = SHARED("mb_data_item_list")
cs_tip_mb_data_equip_item = SHARED("mb_data_equip_item")
cs_tip_mb_data_gem_item = SHARED("mb_data_gem_item")
cs_tip_color_white = SHARED("FFFFFF")
cs_tip_color_red = SHARED("FF0000")
cs_tip_color_gold = SHARED("FFD800")
cs_tip_color_cyan = SHARED("00B4FA")
cs_tip_color_yellow = SHARED("DCDC00")
cs_tip_color_orange = SHARED("F0821E")
cs_tip_color_green = SHARED("00FF00")
cs_tip_color_bound = SHARED("00FF00")
cs_tip_color_set_has = SHARED("FFD800")
cs_tip_color_set_no = SHARED("808080")
cs_tip_color_operation = SHARED("FF6600")
cs_tip_newline = SHARED("\n")
cs_tip_space = SHARED("  ")
ci_skill_preview_idx = 899
function ctip_get_text(name)
  local n = L("tip|" .. name)
  local txt = ui.get_text(n)
  if not ui.has_text(n) then
    ui.log("failed load tip text '%s'.", name)
  end
end
function ctip_push_text(stk, text, color, align)
  if align ~= nil then
    stk:raw_push(align)
  end
  if color ~= nil then
    local fmt = cs_tip_c_add_s
    if sys.is_type(color, "number") then
      fmt = cs_tip_c_add
    end
    stk:raw_format(fmt, color)
    stk:push(text)
    stk:raw_push(cs_tip_c_sub)
  else
    stk:push(text)
  end
  if align ~= nil then
    stk:raw_push(cs_tip_a_sub)
  end
end
function ctip_push_sep(stk)
  stk:raw_push(cs_tip_sep)
end
function ctip_push_newline(stk)
  stk:raw_push(cs_tip_newline)
end
function ctip_push_operation(stk, txt)
  ctip_push_text(stk, cs_tip_newline .. txt, cs_tip_color_operation)
end
function ctip_make_title(stk, excel, color)
  local fmt = cs_tip_title_enter
  if color ~= nil then
    if not sys.is_type(color, "number") then
      fmt = cs_tip_title_enter_s
    end
  else
    fmt = cs_tip_title_enter_n
  end
  stk:raw_format(fmt, color)
  stk:push(excel.name)
  stk:raw_push(cs_tip_title_leave)
end
function ctip_make_title_ex(stk, name, color)
  local fmt = cs_tip_title_enter
  if color ~= nil then
    if not sys.is_type(color, "number") then
      fmt = cs_tip_title_enter_s
    end
  else
    fmt = cs_tip_title_enter_n
  end
  stk:raw_format(fmt, color)
  stk:push(name)
  stk:raw_push(cs_tip_title_leave)
end
function ctip_get_atb(id)
  local player = bo2.player
  if player == nil then
    return 0
  end
  return player:get_atb(id)
end
function ctip_trait_text_ex(modify_id, modify_value, a0, a1)
  if a0 == nil then
    a0 = L("")
  end
  if a1 == nil then
    a1 = L("")
  end
  local modify = bo2.gv_modify_player:find(modify_id)
  if modify == nil then
    return nil
  end
  if modify.isCent > 0 then
    local d1 = math.floor(modify_value / 100)
    local d2 = math.floor(math.mod(modify_value, 100))
    if d2 > 0 then
      return sys.format(L("%s%s%s%+d%.2d%%"), a0, modify.name, a1, d1, d2)
    end
    return sys.format(L("%s%s%s%+d%%"), a0, modify.name, a1, d1)
  end
  return sys.format("%s%s%s%+d", a0, modify.name, a1, modify_value)
end
function ctip_trait_text(id)
  local trait = bo2.gv_trait_list:find(id)
  if trait == nil then
    return nil
  end
  local desc = trait.desc
  if desc.size > 0 then
    if trait.color ~= 0 then
      return desc, trait.color
    end
    return desc
  end
  return ctip_trait_text_ex(trait.modify_id, trait.modify_value)
end
function ctip_push_unwrap(stk, text, color)
  if color == nil then
    color = cs_tip_color_white
  end
  stk:raw_push(sys.format("<lb:,13,,%s|", color))
  stk:push(sys.format("%s", text))
  stk:raw_push(">")
end
function ctip_make_shortcut(stk, excel, info)
  if info == nil or excel == nil or stk == nil then
    return
  end
  local excel = info.excel
  if excel == nil then
    return
  end
  local kind = info.kind
  if kind == bo2.eShortcut_Widget then
  elseif kind == bo2.eShortcut_Item then
    local only_id = info.only_id
    local item_info
    if only_id ~= L("0") then
      item_info = ui.item_of_only_id(only_id)
    end
    if item_info.excel.type >= bo2.eItemtype_UseHWeapon and item_info.excel.type <= bo2.eItemType_UseHWeaponEnd then
      local skill_info = ui.skill_find(item_info.excel.use_par[0])
      if skill_info ~= nil then
        ctip_make_shortcut_skill(stk, skill_info)
        return
      end
    end
    ctip_make_item(stk, excel, item_info)
  elseif kind == bo2.eShortcut_Skill then
    ctip_make_shortcut_skill(stk, ui.skill_find(excel.id), excel)
  elseif kind == bo2.eShortcut_Pet then
  elseif kind == bo2.eShortcut_Ridepet then
    local rideinfo = ui.get_ride_info(info.only_id)
    ui_ridepet.build_ridepet_tip(stk, rideinfo)
  elseif kind == bo2.eShortcut_PetSkill then
    ctip_make_pet_skill(stk, excel.id)
  elseif kind == bo2.eShortcut_LianZhao then
    ctip_make_lianzhao(stk, excel)
  elseif kind == bo2.eShortcut_EquipPack then
    ctip_make_equippack(stk, excel)
  end
end
local t_tip_filter_valid_msg = {
  [ui.mouse_lbutton_down] = 1,
  [ui.mouse_rbutton_down] = 1,
  [ui.mouse_lbutton_dbl] = 1,
  [ui.mouse_rbutton_dbl] = 1
}
local c_tip_mouse_filter_name = SHARED("ui_tool.on_tip_mouse_filter")
function ctip_show_popup(tgt, text, popup)
  ui_widget.tip_make_view(w_tip_popup, text)
  w_tip_popup:show_popup(tgt, popup)
  local function on_mouse_filter(ctrl, msg, pos, wheel)
    if t_tip_filter_valid_msg[msg] == nil then
      return
    end
    ui.remove_mouse_filter(c_tip_mouse_filter_name)
    w_tip_popup.visible = false
  end
  ui.insert_mouse_filter_prev(on_mouse_filter, c_tip_mouse_filter_name)
end
function ctip_close_skill_popup(btn)
  w_skill_tip_popup.visible = false
end
function ctip_skill_preview()
  local idx = w_skill_tip_popup.var:get(ci_skill_preview_idx).v_int
  ui_skill_preview.set_preview_skill(idx, 0)
end
function ctip_show_skill_popup(tgt, text, popup, idx)
  ui_widget.tip_make_view(w_skill_tip_popup, text)
  w_skill_tip_popup:show_popup(tgt, popup)
  w_skill_tip_popup.var:set(ci_skill_preview_idx, idx)
  local function on_mouse_filter(ctrl, msg, pos, wheel)
    if t_tip_filter_valid_msg[msg] == nil then
      return
    end
    if ctrl.name == L("btn") then
      return
    end
    ui.remove_mouse_filter(c_tip_mouse_filter_name)
    w_skill_tip_popup.visible = false
  end
  ui.insert_mouse_filter_prev(on_mouse_filter, c_tip_mouse_filter_name)
end
function ctip_show(card, stk1, stk2)
  local tip = card.tip
  local view = tip.view
  if stk1 == nil then
    view.visible = false
    return
  end
  local tip1 = view:search("tip1")
  local tip2 = view:search("tip2")
  local dis = 10
  ui_widget.tip_make_view(tip1, stk1.text)
  if stk2 ~= nil then
    tip2.visible = true
    ui_widget.tip_make_view(tip2, stk2.text)
    view.dy = math.max(tip1.dy, tip2.dy)
    view.dx = tip1.dx + tip2.dx + dis
  else
    tip2.visible = false
    tip1.offset = ui.point(0, 0)
    view.size = tip1.size
  end
  local tgt = tip.target
  if not sys.check(tgt) then
    tgt = card
  end
  view:show_popup(tgt, tip.popup, tip.margin)
  if stk2 ~= nil then
    local cv = view.abs_area.p1 + view.size / 2
    local ct = tgt.abs_area.p1 + tgt.size / 2
    local dx = view.dx
    local dy = view.dy
    local x1 = 0
    local y1 = 0
    local x2 = 0
    local y2 = 0
    if cv.y <= ct.y then
      y1 = dy - tip1.dy
      y2 = dy - tip2.dy
    end
    if cv.x <= ct.x then
      x1 = tip2.dx + dis
      x2 = 0
    else
      x1 = 0
      x2 = tip1.dx + dis
    end
    tip1.offset = ui.point(x1, y1)
    tip2.offset = ui.point(x2, y2)
  end
end
function ctip_show_custom(card, stk, dx)
  local tip = card.tip
  local view = tip.view
  if stk == nil then
    view.visible = false
    return
  end
  local tip1 = view:search("tip1")
  ui_widget.tip_make_view_custom(tip1, stk.text, dx)
  tip1.offset = ui.point(0, 0)
  view.size = tip1.size
  local tgt = tip.target
  if not sys.check(tgt) then
    tgt = card
  end
  view:show_popup(tgt, tip.popup, tip.margin)
end
function ctip_make_tatraw(stk, excel, status, color)
  ctip_make_title(stk, excel, excel.plootlevel.color)
  if status ~= nil then
    ctip_push_text(stk, cs_tip_newline)
    stk:raw_format(cs_tip_title_enter_s, color)
    stk:push(status)
    stk:raw_push(cs_tip_title_leave)
  end
  local ptype = excel.ptype
  if ptype ~= nil then
    ctip_push_text(stk, cs_tip_newline)
    ctip_push_text(stk, ptype.name)
  end
  ctip_make_item_atb(stk, excel, info)
  local tip_id = excel.tip
  if tip_id == 0 then
  else
    local tip_x = bo2.gv_text:find(tip_id)
    if tip_x == nil then
    else
      stk:raw_push(cs_tip_newline)
      stk:raw_push(tip_x.text)
    end
  end
end
function ctip_make_tatlvl(stk, card)
  local idx = card.name.v_int
  local level = math.floor(idx / 10) - 1
  local grid = idx - math.floor(idx / 10) * 10
  local board = ui_personal.ui_tattoo.g_board
  local bdExcel = ui_personal.ui_tattoo.get_board_excel()
  local curlvl = ui_personal.ui_tattoo.get_board_lvl()
  local text = ui.get_text("personal|tattoo_lvl" .. level)
  local color = cs_tip_color_set_has
  if level > curlvl then
    color = cs_tip_color_set_no
  end
  stk:raw_format(cs_tip_title_enter_s, color)
  stk:push(text)
  stk:raw_push(cs_tip_title_leave)
  ctip_push_text(stk, cs_tip_newline)
  text = sys.format(ui.get_text("personal|tattoo_grid"), grid + 1)
  ctip_push_text(stk, text)
  ctip_push_text(stk, cs_tip_newline)
  local reqs = bdExcel.requires[level]
  local reqID = reqs[grid]
  text = ui.get_text("personal|tattoo_cellreq")
  ctip_push_text(stk, text)
  ctip_push_text(stk, cs_tip_newline)
  if reqID == 0 then
    text = ui.get_text("personal|tatraw_any")
    ctip_push_text(stk, text)
  elseif reqID == 1 then
    text = ui.get_text("personal|tatraw_low")
    ctip_push_text(stk, text)
  elseif reqID == 2 then
    text = ui.get_text("personal|tatraw_hig")
    ctip_push_text(stk, text)
  else
    local n = bo2.gv_tattoo_variety:find(reqID)
    if n ~= nil then
      ctip_push_text(stk, n.name)
    end
  end
  local excel = card.excel
  if excel ~= nil then
    ctip_push_sep(stk)
    ctip_make_tatraw(stk, excel, nil, nil)
    return
  end
end
function ctip_make_tatawd(stk, excel)
  local curlvl = ui_personal.ui_tattoo.get_board_lvl()
  local text = ui.get_text("personal|tattoo_lvl3")
  local color = cs_tip_color_set_has
  if curlvl < 3 then
    color = cs_tip_color_set_no
  end
  stk:raw_format(cs_tip_title_enter_s, color)
  stk:push(text)
  stk:raw_push(cs_tip_title_leave)
  ctip_make_item_atb(stk, excel, info)
end
function ctip_show_tag(cmd, data)
  w_tip_tag.visible = false
  local kind = data:get(packet.key.scnobj_type).v_int
  if kind == 0 then
    return
  end
  local stk = sys.mtf_stack()
  local excelID = data:get(packet.key.scnobj_excel_id).v_int
  local text = data:get(packet.key.target_name).v_string
  stk:raw_push(text)
  local yaokuang
  local function check_is_livingskill_yaokuang(id)
    local size_yk = bo2.gv_livingskill_yaokuang_rules.size
    for i = 0, size_yk - 1 do
      local tmp_yaokuang = bo2.gv_livingskill_yaokuang_rules:get(i)
      if tmp_yaokuang ~= nil and tmp_yaokuang.still_id == id then
        yaokuang = tmp_yaokuang
        return true
      end
    end
    return false, nil
  end
  local b_yaokuang = check_is_livingskill_yaokuang(excelID)
  if b_yaokuang and yaokuang ~= nil then
    ctip_push_text(stk, cs_tip_newline)
    ctip_push_text(stk, ui.get_text("tip|need_livingskill"), cs_tip_color_white, cs_tip_a_add_l)
    local stillExcel = bo2.gv_still_list:find(excelID)
    local model_id = bo2.gv_use_list:find(stillExcel.use_id).model
    local skill_id = 0
    if model_id == bo2.eUseMod_LivingSkillCaiyao then
      skill_id = 130089
    elseif model_id == bo2.eUseMod_LivingSkillCaikuang then
      skill_id = 130090
    end
    local skill = ui_skill.get_skill_excel(skill_id, 0)
    if skill == nil then
      skill = ui_skill.get_skill_excel(skill_id, 1)
    end
    if skill == nil then
    else
      stk:merge({
        icon = skill.icon,
        id = skill_id
      }, ui.get_text("tool|cuiqu_hongji_id"))
      ctip_push_text(stk, cs_tip_newline)
      ctip_push_text(stk, ui.get_text("tip|need_shuliandu"), cs_tip_color_white, cs_tip_a_add_l)
      ctip_push_text(stk, yaokuang.tip_need_exp, cs_tip_color_green, cs_tip_a_add_r)
      ctip_push_text(stk, cs_tip_newline)
    end
  end
  if kind == bo2.eScnObjKind_Still then
    local stillExcel = bo2.gv_still_list:find(excelID)
    if stillExcel ~= nil then
      local puse = stillExcel.iuse
      if puse ~= nil then
        for i = 0, puse.key_item_id.size - 1 do
          local n = ui.item_get_excel(puse.key_item_id[i])
          if n ~= nil then
            ctip_push_text(stk, ui.get_text("tip|need") .. n.name, cs_tip_color_cyan)
            ctip_push_text(stk, cs_tip_newline)
          end
        end
        ctip_push_operation(stk, ui.get_text("tip|left_click"))
      end
    end
  else
    local lvl = data:get(packet.key.scnobj_data).v_int
    ctip_push_text(stk, ui_widget.merge_mtf({level = lvl}, ui.get_text("tip|level")), cs_tip_color_yellow)
    if kind == bo2.eScnObjKind_Player then
      local prof = data:get(packet.key.player_profession).v_int
      local profExcel = bo2.gv_profession_list:find(prof)
      if profExcel ~= nil then
        ctip_push_text(stk, profExcel.name, cs_tip_color_orange)
      end
    elseif kind == bo2.eScnObjKind_Pet then
      local chaExcel = bo2.gv_cha_list:find(excelID)
      if chaExcel ~= nil then
        local sorExcel = bo2.gv_cha_sort:find(chaExcel.sort)
        if sorExcel ~= nil then
          ctip_push_text(stk, sorExcel.name)
        end
      end
      ctip_push_text(stk, cs_tip_newline)
      text = data:get(packet.key.pet_host).v_string
      ctip_push_text(stk, ui_widget.merge_mtf({host = text}, ui.get_text("tip|host")), cs_tip_color_cyan)
    else
      local chaExcel = bo2.gv_cha_list:find(excelID)
      if chaExcel ~= nil then
        local sorExcel = bo2.gv_cha_sort:find(chaExcel.sort)
        if sorExcel ~= nil then
          ctip_push_text(stk, sorExcel.name)
        end
        local busExcel = bo2.gv_npc_business:find(chaExcel.business)
        if busExcel ~= nil then
          ctip_push_text(stk, cs_tip_newline)
          ctip_push_text(stk, busExcel.name, cs_tip_color_orange)
        end
        local facExcel = bo2.gv_faction_list:find(chaExcel.faction)
        if facExcel ~= nil then
          ctip_push_text(stk, cs_tip_newline)
          ctip_push_text(stk, facExcel.name, cs_tip_color_cyan)
        end
        if data:has(packet.key.gs_score) then
          ctip_push_text(stk, cs_tip_newline)
          local _text = ui_widget.merge_mtf({
            gs_score = data:get(packet.key.gs_score).v_int
          }, ui.get_text("tip|gs_score"))
          ctip_push_text(stk, _text)
        end
        local fight_body = chaExcel.fight_body
        if fight_body ~= 0 then
          ctip_push_text(stk, cs_tip_newline)
          if fight_body == 1 then
            stk:raw_push("<img:$image/portrait/body_1.png*22,22>")
            ctip_push_text(stk, ui.get_text("portrait|controls_state1"), cs_tip_color_cyan)
          elseif fight_body == 3 then
            stk:raw_push("<img:$image/portrait/body_3.png*22,22>")
            ctip_push_text(stk, ui.get_text("portrait|controls_state2"), cs_tip_color_cyan)
          elseif fight_body == 4 then
            stk:raw_push("<img:$image/portrait/body_4.png*22,22>")
            ctip_push_text(stk, ui.get_text("portrait|controls_state3"), cs_tip_color_cyan)
          end
        end
        local add_quest_title = false
        local reqkill = chaExcel.quest_reqkill
        for i = 0, reqkill.size - 1 do
          local info = ui.quest_find(reqkill[i])
          if info ~= nil then
            local quest = info.excel
            for j = 0, 3 do
              if quest.req_obj[j] == bo2.eQuestObj_KillNpc and quest.req_id[j] == excelID then
                if not add_quest_title then
                  ctip_push_text(stk, cs_tip_newline)
                  ctip_push_text(stk, ui.get_text("tip|relative_quest"), cs_tip_color_yellow)
                  add_quest_title = true
                end
                ctip_push_text(stk, cs_tip_newline)
                ctip_push_text(stk, quest.name)
                break
              end
            end
            local mstone = bo2.gv_milestone_list:find(info.mstone_id)
            if mstone ~= nil and mstone.req_obj == bo2.eQuestObj_KillNpc and mstone.req_id == excelID then
              if not add_quest_title then
                ctip_push_text(stk, cs_tip_newline)
                ctip_push_text(stk, ui.get_text("tip|relative_quest"), cs_tip_color_yellow)
                add_quest_title = true
              end
              ctip_push_text(stk, cs_tip_newline)
              ctip_push_text(stk, quest.name .. "-" .. mstone.name)
              break
            end
          end
        end
        local reqgroup = chaExcel.qcg_id
        for i = 0, reqgroup.size - 1 do
          local qcg_id = reqgroup[i]
          if qcg_id == 0 then
            break
          end
          local g = bo2.gv_quest_chagroup:find(qcg_id)
          if g == nil then
            break
          end
          local quest_req = g.quest_req
          for j = 0, quest_req.size - 1 do
            local info = ui.quest_find(quest_req[j])
            if info ~= nil then
              local quest = info.excel
              for k = 0, 3 do
                if quest.req_obj[k] == bo2.eQuestObj_ChaGroup and quest.req_id[k] == qcg_id then
                  if not add_quest_title then
                    ctip_push_text(stk, cs_tip_newline)
                    ctip_push_text(stk, ui.get_text("tip|relative_quest"), cs_tip_color_yellow)
                    add_quest_title = true
                  end
                  ctip_push_text(stk, cs_tip_newline)
                  ctip_push_text(stk, quest.name)
                  break
                end
              end
              local mstone = bo2.gv_milestone_list:find(info.mstone_id)
              if mstone ~= nil and mstone.req_obj == bo2.eQuestObj_ChaGroup and mstone.req_id == qcg_id then
                if not add_quest_title then
                  ctip_push_text(stk, cs_tip_newline)
                  ctip_push_text(stk, ui.get_text("tip|relative_quest"), cs_tip_color_yellow)
                  add_quest_title = true
                end
                ctip_push_text(stk, cs_tip_newline)
                ctip_push_text(stk, quest.name .. "-" .. mstone.name)
                break
              end
            end
          end
        end
        ui_handson_teach.test_complate_npc_Lum(chaExcel, data)
      end
    end
  end
  ui_widget.tip_make_view(w_tip_tag, stk.text)
  w_tip_tag.visible = true
end
function ctip_make_calenlar(stk, sdate)
  ctip_push_unwrap(stk, ui_widget.merge_mtf({
    time = sdate.time
  }, ui.get_text("tip|time")))
  ctip_push_unwrap(stk, ui_widget.merge_mtf({
    year = sdate.year,
    month = sdate.month,
    days = sdate.days,
    weeks = sdate.weeks
  }, ui.get_text("tip|solar_date")))
  ctip_push_unwrap(stk, ui_widget.merge_mtf({
    lmonth = sdate.lmonth,
    ldays = sdate.ldays
  }, ui.get_text("tip|lunar_date")))
  ctip_push_unwrap(stk, ui_widget.merge_mtf({
    y_tiangan = sdate.y_tiangan,
    y_dizhi = sdate.y_dizhi,
    shengxiao = sdate.animal,
    m_tiangan = sdate.m_tiangan,
    m_dizhi = sdate.m_dizhi,
    d_tiangan = sdate.d_tiangan,
    d_dizhi = sdate.d_dizhi
  }, ui.get_text("tip|whole_date")))
  local start_time = ui_prompt.get_start_time()
  local end_time
  if start_time then
    end_time = os.clock() - start_time
    ctip_push_unwrap(stk, ui_widget.merge_mtf({
      online_time = ui_state.cal_time(end_time * 1000)
    }, ui.get_text("tip|online_time")))
  end
  if sdate.term ~= 0 then
    ctip_push_unwrap(stk, ui_widget.merge_mtf({
      jieqi = sdate.term
    }, ui.get_text("tip|jieqi")))
  end
  if sdate.SolarFestival ~= 0 then
    ctip_push_unwrap(stk, ui_widget.merge_mtf({
      solar_festival = sdate.SolarFestival
    }, ui.get_text("tip|solar_festival")))
  end
  if sdate.LunarFestival ~= 0 then
    ctip_push_unwrap(stk, ui_widget.merge_mtf({
      lunar_festival = sdate.LunarFestival
    }, ui.get_text("tip|lunar_festival")))
  end
end
local sig_name = "ui_tool:on_signal"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Fake_see_obj, ctip_show_tag, sig_name)
