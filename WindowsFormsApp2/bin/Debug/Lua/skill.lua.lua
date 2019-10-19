local ui_tab = ui_widget.ui_tab
local common_xinfa_num = 5
local branch_xinfa_num = 5
local fuzhi_xinfa_num = 10
local skill_num = 10
local qita_skill_num = 20
local uri = "$frame/skill/skill.xml"
local xinfa_sty = "card_xinfa"
local skill_sty = "card_skill"
function on_init_card_xinfa(ctype)
end
function on_init_card_skill(ctype)
end
function get_skill_excel(excel_id, type)
  local excel
  if type == 0 then
    excel = bo2.gv_passive_skill:find(excel_id)
  elseif type == 1 then
    excel = bo2.gv_skill_group:find(excel_id)
  else
    return
  end
  return excel
end
function on_init_qita_skill_card(ctrl, data)
  local uri = "$frame/skill/common.xml"
  local skill_sty = "skill_item"
  local item
  for i = 1, 15 do
    item = ui.create_control(w_qita, "divider")
    item:load_style(uri, skill_sty)
    item.name = "skill" .. i
    local skill = item:search("skill_card")
  end
end
function on_init_liyi_skill_card(ctrl, data)
  local uri = "$frame/skill/common.xml"
  local skill_sty = "liyi_skill_item"
  local item
  for i = 1, 60 do
    item = ui.create_control(w_liyi, "divider")
    item:load_style(uri, skill_sty)
    item.name = "skill" .. i
    local skill = item:search("skill_card")
  end
end
scratch_skill_edit_ctrl = {}
function on_init_scratch_skill_edit(ctrl, data)
  w_richbox_desc.mtf = ui.get_text("skill|scratch_skill_desc")
  local uri = "$frame/skill/skill.xml"
  local skill_sty = "card_scratch_skill"
  local list_num = bo2.gv_scratch_skill_list.size
  if list_num > 16 then
    ui.log("!!!!There are over 16 element in scratch_skill_list.txt!!!")
    return
  end
  for i = 0, list_num - 1 do
    local line = bo2.gv_scratch_skill_list:get(i)
    item = ui.create_control(w_scratch_div, "panel")
    item:load_style(uri, skill_sty)
    item:search("lb_desc").text = line.desc
    item:search("skill_card").index = 62 + i
    if item:search("skill_card").index >= 78 then
      item:search("skill_card").index = 0
    end
    scratch_skill_edit_ctrl[line.id] = item
  end
end
function on_scratch_skill_card_drop(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  ui_shortcut.on_card_drop_logic(card, msg, pos, data)
end
function on_scratch_skill_card_mouse(card, msg, pos, data)
  if msg == ui.mouse_lbutton_drag or msg == ui.mouse_lbutton_down then
    ui_shortcut.shortcut_create_drop(card.index)
    return
  end
end
function on_scratch_skill_card_tip_show(tip)
  ui_shortcut.on_card_tip_show(tip)
end
function on_xinfa_card_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    if ui.is_key_down(ui.VK_CONTROL) then
      local xinfa_info = ui.xinfa_find(card.excel_id)
      ui_chat.insert_xinfa(xinfa_info.excel_id, xinfa_info.level)
      return
    end
    on_xinfa_item(card.topper, msg)
  end
end
function on_skill_card_mouse(card, msg, pos, data)
  if card.excel_id == 0 then
    return
  end
  local icon
  if card.icon then
    icon = card.icon
  else
    return
  end
  local skill_info = ui.skill_find(card.excel_id)
  if skill_info == nil then
    return
  end
  if msg == ui.mouse_lbutton_down then
    if ui.is_key_down(ui.VK_CONTROL) then
      ui_chat.insert_skill(skill_info.excel_id, skill_info.level, skill_info.type)
      return
    end
    if skill_info.type == 0 then
      return
    end
    if skill_info.type == 2 then
      return
    end
    if skill_info.level == 0 then
      return
    end
    ui.set_cursor_icon(icon.uri)
    local on_drop_hook = function(w, msg, pos, data)
      if msg == ui.mouse_drop_clean then
      end
      if msg == ui.mouse_drop_setup then
      end
    end
    if skill_info.type == 1 then
      local data = sys.variant()
      data:set("drop_type", ui_widget.c_drop_type_skill)
      data:set("excel_id", card.excel_id)
      data:set("card", card)
      ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
    end
  elseif msg == ui.mouse_lbutton_drag then
    if skill_info.type == 0 then
      return
    end
    if skill_info.type == 2 then
      return
    end
    if skill_info.level == 0 then
      return
    end
    ui.set_cursor_icon(icon.uri)
    local on_drop_hook = function(w, msg, pos, data)
      if msg == ui.mouse_drop_clean then
      end
      if msg == ui.mouse_drop_setup then
      end
    end
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_skill)
    data:set("excel_id", card.excel_id)
    data:set("card", card)
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  elseif msg == ui.mouse_rbutton_click then
  end
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel_id = card.excel_id
  if excel_id == nil or excel_id == 0 then
    return
  end
  local stk = sys.mtf_stack()
  local info = ui.skill_find(card.excel_id)
  if info == nil then
    ui.log("on_skill_card_tip_show info is nil")
    return
  end
  if info.type == 1 then
    ui_tool.ctip_make_skill(stk, info)
  elseif info.type == 0 then
    ui_tool.ctip_make_passive_skill(stk, info)
  else
    return
  end
  ui_tool.ctip_show(card, stk)
end
function set_highlight(ctrl, xinfa)
  if ctrl == last_highlight_ctrl then
    return
  end
  function set_highlight_in(ctrl, flag)
    if not sys.check(ctrl) then
      return
    end
    local highlight = ctrl:search("highlight")
    if sys.check(highlight) then
      highlight.visible = flag
    end
    local highlight_bg = ctrl:search("highlight_bg")
    if sys.check(highlight_bg) then
      if flag == true then
        highlight_bg.color = ui.make_argb("FFFFFFFF")
      else
        highlight_bg.color = ui.make_argb("80FFFFFF")
      end
    end
  end
  if xinfa then
    set_highlight_in(last_highlight_ctrl, false)
    if sys.check(last_xinfa_highlight_ctrl) then
      set_highlight_in(last_xinfa_highlight_ctrl, false)
    end
    last_highlight_ctrl = nil
    last_xinfa_highlight_ctrl = ctrl
    set_highlight_in(ctrl, true)
    last_xinfa_selected = last_xinfa_highlight_ctrl:search("xinfa_card").excel_id
  else
    set_highlight_in(ctrl, true)
    set_highlight_in(last_highlight_ctrl, false)
    last_highlight_ctrl = ctrl
  end
end
function set_wuxing()
  if bo2.player then
    w_skill:search("wuxing"):search("label").text = ui.get_text("skill|wuxing") .. bo2.player:get_atb(bo2.eAtb_Cha_Savvy)
  end
end
function packet_equip_xinfa(id, b)
  local v = sys.variant()
  v:set(packet.key.xinfa_levelup_id, id)
  v:set(packet.key.equip_xinfa, b)
  bo2.send_variant(packet.eCTS_UI_EquipXinfa, v)
end
function xinfa_not_chosen_err()
  local v = sys.variant()
  v:set(packet.key.ui_text_id, 76067)
  ui_packet.recv_wrap(packet.eSTC_UI_ShowText, v)
end
function on_equip_xinfa()
  if sys.check(last_xinfa_highlight_ctrl) then
    if w_fuzhi_xinfa_list.item_count == 1 then
      ui_tool.note_insert(ui.get_text("skill|no_pause_xinfa"), "FF0000")
      return
    end
    ui_handson_teach.test_complate_xinfacangku_monitor(false)
    ui_widget.ui_msg_box.show_common({
      text = ui.get_text("skill|pause_practise_xinfa"),
      callback = function(ret)
        if ret.result == 1 then
          local id = last_xinfa_highlight_ctrl:search("xinfa_card").excel_id
          packet_equip_xinfa(id, 0)
        end
      end
    })
  else
    xinfa_not_chosen_err()
  end
end
function on_xinfa_cangku()
  ui_xf_cangku.w_xf_cangku.visible = true
end
function on_zhuzhi_visible(window)
  stop_all_unlock_skill_anim(window)
  if window.visible == true then
    set_wuxing()
    if w_zhuzhi_xinfa_list:item_get(0) then
      on_xinfa_item(w_zhuzhi_xinfa_list:item_get(0), ui.mouse_lbutton_click)
    end
    if w_zhuzhi_xinfa_list:item_get(2) then
      w_zhuzhi_xinfa_list:item_get(2).visible = true
    end
  elseif w_zhuzhi_xinfa_list:item_get(2) then
    w_zhuzhi_xinfa_list:item_get(2).visible = false
  end
end
function on_fuzhi_visible(window)
  stop_all_unlock_skill_anim(window)
  if window.visible == true then
    set_wuxing()
    if w_fuzhi_xinfa_list:item_get(0) then
      on_xinfa_item(w_fuzhi_xinfa_list:item_get(0), ui.mouse_lbutton_click)
    end
  end
end
function on_liyi_visible(ctrl, vis)
  w_skill:search("wuxing").visible = not vis
  w_skill:search("xinfapingfen").visible = not vis
end
function find_tudun_skill_flicker()
  for i = 1, 15 do
    local item = w_qita:search("skill" .. i)
    if item ~= nil and item:search("skill_card").excel_id == 110027 then
      return item:search("flicker_handson")
    end
  end
end
function find_tudun_skill()
  for i = 1, 15 do
    local item = w_qita:search("skill" .. i)
    if item ~= nil and item:search("skill_card").excel_id == 110027 then
      return item:search("flicker_handson")
    end
  end
end
function on_qita_visible(ctrl, vis)
  if vis == true then
    local obj = bo2.player
    if obj then
      local value1 = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_Skill_Qita)
      if value1 == 16 then
        ui_handson_teach.test_complate_skill_tudun(true)
      end
    end
  end
  ui_handson_teach.test_complate_on_skill_qita_visible(vis)
end
function on_open_xinfa_master()
  ui_handson_teach.test_complate_xinfamaster_showui(false)
  ui_skill_master.w_skill_master.visible = not ui_skill_master.w_skill_master.visible
end
function on_btn_xinfa_master_visible(ctrl, vis)
  if vis == true then
    ui.log("hell?")
    ui_handson_teach.test_complate_xinfamaster_showui(true)
  end
end
function on_open_lianzhao()
  ui_lianzhao.w_lianzhao.visible = true
end
function on_open_huazhao()
  ui_huazhao.w_huazhao.visible = not ui_huazhao.w_huazhao.visible
end
function on_wuxing_show(tip)
  local card = tip.owner
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_wuxing(stk)
  ui_tool.ctip_show(card, stk)
end
local LIMIT_LEVEL_DEFINE_ID = 555
local function enable_level_up()
  local limit_level = tonumber(tostring(bo2.gv_define:find(LIMIT_LEVEL_DEFINE_ID).value))
  if limit_level <= bo2.player:get_atb(bo2.eAtb_Level) then
    w_btn_zhuzhi_xinfa_levelup.enable = true
    w_btn_fuzhi_xinfa_levelup.enable = true
    w_btn_living_xinfa_levelup.enable = true
  end
end
function on_window_visible(window, _vis)
  if window.visible == true then
    w_flicker_skill.visible = false
    local player = bo2.player
    if player == nil then
      return
    end
    if not sys.check(player) then
      return
    end
    local value = player:get_atb(bo2.eAtb_Cha_Exp)
    set_wuxing()
    ui_tab.show_page(w_skill, "zhuzhi", true)
    ui_tab.get_button(w_skill, "livingskill").visible = true
    on_xinfa_item(w_zhuzhi_xinfa_list:item_get(0), ui.mouse_lbutton_click)
    local limit_level = tonumber(tostring(bo2.gv_define:find(LIMIT_LEVEL_DEFINE_ID).value))
    if limit_level > player:get_atb(bo2.eAtb_Level) then
      w_btn_zhuzhi_xinfa_levelup.enable = false
      w_btn_fuzhi_xinfa_levelup.enable = false
      w_btn_living_xinfa_levelup.enable = false
      player:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Level, enable_level_up, "ui_skill.enable_level_up")
    else
      w_btn_zhuzhi_xinfa_levelup.enable = true
      w_btn_fuzhi_xinfa_levelup.enable = true
      w_btn_living_xinfa_levelup.enable = true
    end
    if w_fuzhi_xinfa_list.item_count == 0 then
      ui_tab.get_button(w_skill, "fuzhi").visible = false
    end
    if w_living_xinfa_list.item_count == 0 then
      ui_tab.get_button(w_skill, "livingskill").visible = false
    end
    local xf_score = bo2.GetZhuZhiXinFaLevel()
    if xf_score >= bo2.XINFA_SCORE_THRESHOLD then
      w_btn_xinfa_master.visible = true
    end
  end
  stop_all_unlock_skill_anim(w_zhuzhi_info)
  stop_all_unlock_skill_anim(w_fuzhi_info)
  w_btn_equip_xinfa.visible = false
  ui_xf_cangku.w_xf_cangku.visible = false
  ui_tab.get_button(w_skill, "zhuzhi").visible = true
  ui_tab.get_button(w_skill, "qita").visible = true
  ui_tab.get_button(w_skill, "liyi").visible = true
  ui_tab.get_button(w_skill, "hunskill").visible = true
  local zhuzhi_panel = window:search("zhuzhi_tab")
  if zhuzhi_panel then
    zhuzhi_panel.visible = window.visible
  end
  ui_handson_teach.test_complate_on_skill_visible(_vis)
end
function on_cangku_window_visible(window)
  if w_fuzhi_xinfa_list.item_count + ui_xf_cangku.w_cangku_xinfa_list.item_count <= 0 then
    ui_tool.note_insert(ui.get_text("skill|no_open_warehouse"), "FF0000")
    return
  end
  window.visible = true
  w_flicker_skill.visible = false
  local player = bo2.player
  if player == nil then
    return
  end
  if not sys.check(player) then
    return
  end
  local value = player:get_atb(bo2.eAtb_Cha_Exp)
  set_wuxing()
  ui_tab.show_page(w_skill, "fuzhi", true)
  on_xinfa_item(w_fuzhi_xinfa_list:item_get(0), ui.mouse_lbutton_click)
  local limit_level = tonumber(tostring(bo2.gv_define:find(LIMIT_LEVEL_DEFINE_ID).value))
  if limit_level > player:get_atb(bo2.eAtb_Level) then
    w_btn_zhuzhi_xinfa_levelup.enable = false
    w_btn_fuzhi_xinfa_levelup.enable = false
    w_btn_living_xinfa_levelup.enable = false
    player:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Level, enable_level_up, "ui_skill.enable_level_up")
  else
    w_btn_zhuzhi_xinfa_levelup.enable = true
    w_btn_fuzhi_xinfa_levelup.enable = true
    w_btn_living_xinfa_levelup.enable = true
  end
  w_btn_equip_xinfa.visible = true
  ui_xf_cangku.w_xf_cangku.visible = true
  ui_tab.get_button(w_skill, "zhuzhi").visible = false
  ui_tab.get_button(w_skill, "qita").visible = false
  ui_tab.get_button(w_skill, "liyi").visible = false
  ui_tab.get_button(w_skill, "fuzhi").visible = true
  ui_tab.get_button(w_skill, "livingskill").visible = false
  ui_tab.get_button(w_skill, "hunskill").visible = false
end
function set_skill_card(w, info)
  local use_zhanfa = function(item)
    local id = item.id
    local v = sys.variant()
    v:set(packet.key.zhanfa_id, id)
    v:set(packet.key.zhanfa_use, 1)
    bo2.send_variant(packet.eCTS_UI_Zhanfa, v)
    ui.log("use_zhanfa send %s", id)
  end
  for i = 1, 15 do
    local item = w:search("skill" .. i)
    if item == nil then
      return
    end
    if item:search("skill_card").excel_id == info.excel_id then
      return
    end
    if item:search("skill_card").excel_id == 0 and not check_is_hunskill(info.excel_id) then
      item:search("skill_card").excel_id = info.excel_id
      local excel = get_skill_excel(info.excel_id, info.type)
      item:search("name").text = excel.name
      if info.level == 0 then
        if info.type == 1 then
          local skill_level = bo2.gv_skill_level:find(info.excel_id)
          if sys.check(skill_level) then
            local req_level = skill_level.unlock
            local arg = sys.variant()
            arg:set("level", req_level)
            item:search("level").text = sys.mtf_merge(arg, ui.get_text("skill|xinfa_unlock_desc"))
          end
        elseif info.type == 0 then
          local slevel = "level" .. info.level + 1
          if bo2.gv_xinfa_list:find(excel.xinfa) ~= nil and excel[slevel].size ~= 0 then
            local arg = sys.variant()
            arg:set("level", excel[slevel][0])
            item:search("level").text = sys.mtf_merge(arg, ui.get_text("skill|xinfa_unlock_desc"))
          end
        end
      else
        item:search("level").text = ""
      end
      item:search("name").visible = true
      item:search("level").visible = true
      item:search("skill_bg").visible = true
      item:search("skill_cell").visible = true
      if info.level == 0 then
        item:search("lock").visible = true
        item:search("skill_card").draw_gray = true
      end
      return
    end
  end
end
function skill_sort(a, b)
  local get_lock_level = function(info)
    local skill_excel = get_skill_excel(info.excel_id, info.type)
    if info.type == 1 then
      local excel = bo2.gv_skill_level:find(info.excel_id)
      return excel.unlock
    elseif info.type == 0 and bo2.gv_xinfa_list:find(skill_excel.xinfa) ~= nil then
      return skill_excel.level1[0]
    end
  end
  local lock_of_a = get_lock_level(a)
  local lock_of_b = get_lock_level(b)
  return lock_of_a < lock_of_b
end
function show_xinfa_skills(card)
  local set_info = function(w, info)
    local type = bo2.gv_xinfa_list:find(info.excel_id).type_id
    if type == bo2.eXinFaType_Living then
      local exp = get_livingskill_exp_value(info.excel_id)
      local max_rate = 100
      local now_rate = exp % max_rate
      w_now_livingskill_exp_lb.text = sys.format("%d/%d", now_rate, max_rate)
      local per = now_rate / max_rate
      local new_dx = 260 * per
      w_next_livingskill_exp_pic.dx = new_dx
    end
    w:search("xinfa_title_name").text = info.excel.name
    w:search("desc").text = bo2.gv_text:find(info.excel.desc_id).text
    local level = info.level
    local mb_levelup = bo2.gv_xinfa_levelup_spend:find(level + 1)
    w:search("cur_exp").text = bo2.player:get_atb(bo2.eAtb_Cha_Exp)
    local modify_text
    if type == bo2.eXinFaType_Living then
      local excel_levelup = bo2.gv_livingskill_levelup:find(level)
      local index = info.excel_id - 601
      local text_begin = ui.get_text("skill|livingskill_show_begin_" .. index)
      if excel_levelup == nil then
      else
        local ids = excel_levelup.v_ids[index]
        local ids_size = ids.size
        local arg = sys.variant()
        local desc_text = ""
        for i = 0, ids_size - 1 do
          arg:clear()
          arg:set("item_id", sys.format("%d", ids[i]))
          local req_text = sys.mtf_merge(arg, ui.get_text("skill|ui_need_use_equip"))
          if i < ids_size - 1 then
            req_text = req_text .. "\161\162"
          end
          desc_text = desc_text .. req_text
        end
        local text_end = ui.get_text("skill|livingskill_show_end_" .. index)
        w_desc.mtf = text_begin .. desc_text .. text_end
      end
    else
      for i = 0, info.excel.mdf_chg.size / 2 do
        local id = info.excel.mdf_chg[i * 2]
        local modify = bo2.gv_modify_player:find(id)
        if modify then
          local iDt = info.excel.mdf_chg[i * 2 + 1] * level
          local text = ui_tool.ctip_trait_text_ex(id, iDt)
          if i == 0 then
            modify_text = modify_text .. text
            w:search("modify").text = sys.format("%s", modify_text)
            w:search("modify1").text = L("")
          else
            w:search("modify").text = sys.format("%s", modify_text)
            w:search("modify1").text = sys.format("%s", text)
          end
        end
      end
    end
    if not mb_levelup then
      w:search("money").money = 0
      w:search("need_exp").text = ui.get_text("skill|reach_level_peak")
    else
      local exp_id = info.excel.exp_id
      local data1 = "data" .. exp_id * 2 - 1
      local data2 = "data" .. exp_id * 2
      local req_exp = mb_levelup[data1]
      local req_money = mb_levelup[data2]
      local money_type = tonumber(tostring(bo2.gv_define:find(1266).value))
      w:search("money").visible = false
      w:search("money1").visible = false
      if type == bo2.eXinFaType_Living and money_type == bo2.eCurrency_CirculatedMoney then
        w:search("money1").visible = true
        w:search("money1").money = req_money
      else
        w:search("money").visible = true
        w:search("money").money = req_money
      end
      w:search("need_exp").text = req_exp .. "/"
    end
    local head_skill = info.head_skill
    if head_skill ~= nil then
    else
      ui.log("head_skill nil")
      return
    end
    local skill_info = ui.skill_find(head_skill.excel_id)
    local skill_tmp_table = {}
    while skill_info ~= nil do
      if bo2.is_master_passive_skill(skill_info.excel_id) == false then
        table.insert(skill_tmp_table, skill_info)
      end
      skill_info = ui.next_skill(skill_info.excel_id)
    end
    table.sort(skill_tmp_table, skill_sort)
    local cnt_skill = #skill_tmp_table
    local cnt_unlock_skill = 0
    for i, v in ipairs(skill_tmp_table) do
      if v.level > 0 then
        cnt_unlock_skill = cnt_unlock_skill + 1
      end
      set_skill_card(w, v)
    end
    w:search("unlock_ratio").text = cnt_unlock_skill .. "/" .. cnt_skill
  end
  if card.excel_id == 0 then
    return
  end
  local xinfa_info = ui.xinfa_find(card.excel_id)
  if xinfa_info == nil then
    return
  end
  local type = bo2.gv_xinfa_list:find(xinfa_info.excel_id).type_id
  local tab
  if type == bo2.eXinFaType_Currency then
    tab = card.topper.parent.topper:search("zhuzhi_tab")
  elseif type == bo2.eXinFaType_Expert then
    tab = card.topper.parent.topper:search("zhuzhi_tab")
  elseif type == bo2.eXinFaType_Other then
    tab = card.topper.parent.topper:search("fuzhi_tab")
  elseif type == bo2.eXinFaType_Living then
    tab = card.topper.parent.topper:search("livingskill_tab")
  end
  if tab then
    clear_info(tab)
    set_info(tab, xinfa_info)
  else
    ui.log("tab nil")
  end
end
function insert_xinfa(w, id, lv, class, level)
  local child_item_uri = L("$frame/skill/common.xml")
  local child_item_style = L("xinfa_item")
  local child_item = w:item_append()
  w.slider_y.visible = w.item_count > 6
  child_item:load_style(child_item_uri, child_item_style)
  child_item:search("xinfa_card").excel_id = id
  local excel = bo2.gv_xinfa_list:find(id)
  if excel == nil then
    return
  end
  local xinfa_name_text = excel.name
  local lb_level = child_item:search("level")
  if level == nil or level then
    lb_level.text = "Lv." .. lv
  else
    lb_level.visible = false
  end
  local type = excel.type_id
  if type == bo2.eXinFaType_Living then
    local exp = math.modf(get_livingskill_exp_value(id) / 100)
    local excel_levelup = bo2.gv_livingskill_levelup:find(lv)
    if excel_levelup == nil then
      return
    end
    if lv >= excel.level_max then
      local max_level = ui.get_text("skill|livingskill_max_level")
      xinfa_name_text = excel.name .. " " .. excel_levelup.name .. "(" .. max_level .. ")"
    else
      local next_level_exp = excel_levelup.exp_max
      xinfa_name_text = excel.name .. " " .. excel_levelup.name .. "(" .. exp .. "/" .. next_level_exp .. ")"
    end
    lb_level.visible = false
  end
  child_item:search("name").text = xinfa_name_text
  local lb_class = child_item:search("class")
  if class == nil then
    lb_class.text = ""
    lb_class.visible = false
  else
    lb_class.text = class
    lb_class.visible = true
  end
  xinfa_item_list[id] = {}
  xinfa_item_list[id] = {
    id = id,
    item = child_item,
    list_item = w,
    level = lv
  }
  return child_item
end
function on_xinfa_item_mouse(btn, msg)
  if msg == ui.mouse_lbutton_click then
    stop_all_unlock_skill_anim(w_zhuzhi_info)
    stop_all_unlock_skill_anim(w_fuzhi_info)
  end
  on_xinfa_item(btn, msg)
end
function on_xinfa_item(btn, msg)
  if msg == ui.mouse_lbutton_click then
    if btn == nil then
      last_xinfa_highlight_ctrl = nil
      return
    end
    if btn.topper.parent.topper == ui.find_control("$frame:skill") then
      set_highlight(btn, 1)
      local anger_flag
      local obj = bo2.player
      if obj == nil then
        return
      end
      anger_flag = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_Anger_LevelUp)
      if btn.topper.index == 2 then
        local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_Skill_Choose)
        if flag_value == 16 then
          btn.topper:search("flicker_handson").visible = false
          ui_handson_teach.test_complate_anger_level_up(true)
        elseif flag_value == 17 and anger_flag == 16 and ui_handson_teach.w_flicker_levelup.visible ~= true then
          ui_handson_teach.w_flicker_levelup.visible = true
          local tb = ui_handson_teach.g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Anger_LevelUp]
          if tb.handson_teach and tb.handson_teach.view then
            tb.handson_teach.view.visible = true
            tb.handson_teach.timer.suspended = false
          end
        end
      elseif anger_flag == 16 and ui_handson_teach.w_flicker_levelup.visible ~= false then
        ui_handson_teach.w_flicker_levelup.visible = false
        local tb = ui_handson_teach.g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_Anger_LevelUp]
        if tb.handson_teach and tb.handson_teach.view then
          tb.handson_teach.view.visible = false
          tb.handson_teach.timer.suspended = true
        end
      end
    elseif btn.topper.parent.topper == ui.find_control("$frame:xf_cangku") then
      ui_xf_cangku.set_highlight(btn, 1)
    else
      ui_skill_learn.set_highlight(btn, 1)
    end
    if btn:search("xinfa_card") then
      show_xinfa_skills(btn:search("xinfa_card"))
    end
  end
end
function on_skill_item_mouse(item, msg)
  local skill_card = item:search("skill_card")
  local skill_info = ui.skill_find(skill_card.excel_id)
  if skill_info == nil then
    return
  end
  if skill_info.type == 0 then
    return
  end
  if bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_Skill_Tudun) == 16 and skill_info.excel_id == 110027 then
    ui_handson_teach.test_complate_skill_tudun(false)
  end
  local excel = get_skill_excel(skill_info.excel_id, skill_info.type)
  if excel.preview_id == 0 then
    return
  end
  if msg == ui.mouse_enter or msg == ui.mouse_inner then
    item:search("yulan").visible = true
  elseif msg == ui.mouse_outer or msg == ui.mouse_leave then
    item:search("yulan").visible = false
  end
end
function on_skill_preview_mouse(ctrl, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_inner then
    ctrl.visible = true
  end
end
function set_xinfa_card(info)
  local type = bo2.gv_xinfa_list:find(info.excel_id).type_id
  if type == bo2.eXinFaType_Other and info.equip == 0 then
    insert_xinfa(ui_xf_cangku.w_cangku_xinfa_list, info.excel_id, info.level, nil, false)
    ui_handson_teach.test_complate_xinfacangku_continue_monitor(true)
    return nil
  end
  if type == bo2.eXinFaType_Currency then
    return insert_xinfa(w_zhuzhi_xinfa_list, info.excel_id, info.level, ui.get_text("skill|xinfa_general"))
  elseif type == bo2.eXinFaType_Expert then
    return insert_xinfa(w_zhuzhi_xinfa_list, info.excel_id, info.level, ui.get_text("skill|xinfa_branch"))
  elseif type == bo2.eXinFaType_Other then
    return insert_xinfa(w_fuzhi_xinfa_list, info.excel_id, info.level)
  elseif type == bo2.eXinFaType_Living then
    return insert_xinfa(w_living_xinfa_list, info.excel_id, info.level)
  end
end
function clear_info(w)
  w:search("xinfa_title_name").text = ""
  w:search("desc").text = ""
  if w:search("modify") ~= nil then
    w:search("modify").text = ""
  end
  if w:search("modify1") ~= nil then
    w:search("modify1").text = ""
  end
  w:search("need_exp").text = ""
  w:search("money").money = 0
  for i = 1, 6 do
    local item = w:search("skill" .. i)
    item:search("name").text = ""
    item:search("name").visible = false
    item:search("level").text = 0
    item:search("level").visible = false
    item:search("skill_card").excel_id = 0
    item:search("skill_bg").visible = false
    item:search("skill_cell").visible = false
    item:search("lock").visible = false
    item:search("skill_card").draw_gray = false
    item:search("yulan").visible = false
  end
end
local lock_frag1_anim_uri = "$frame/skill/transition.xml|lock_frag_drop1"
local lock_frag2_anim_uri = "$frame/skill/transition.xml|lock_frag_drop2"
local unlock_highlight_anim_uri = "$frame/skill/transition.xml|unlock_highlight_fade"
local blade_track_anim_uri = "$frame/skill/transition.xml|blade_track_move"
function on_unlock_skill(id, type)
  if type == 3 then
    return
  end
  local page = ui_tab.get_show_page(w_skill)
  if page ~= w_zhuzhi_info.parent and page ~= w_fuzhi_info.parent then
    return
  end
  for i = 1, 6 do
    local skill_item = page:search("skill" .. i)
    local skill_excel_id = skill_item:search("skill_card").excel_id
    if skill_excel_id > 0 and skill_excel_id == id then
      local lock_frag1 = skill_item:search("lock_frag1_view")
      local lock_frag2 = skill_item:search("lock_frag2_view")
      local blade_track = skill_item:search("blade_track")
      local unlock_highlight = skill_item:search("unlock_highlight")
      lock_frag1.visible = true
      lock_frag2.visible = true
      blade_track.visible = true
      unlock_highlight.visible = true
      lock_frag1.transition = lock_frag1_anim_uri
      lock_frag2.transition = lock_frag2_anim_uri
      blade_track.transition = blade_track_anim_uri
      unlock_highlight.transition = unlock_highlight_anim_uri
    end
  end
end
function on_unlock_new_skill(id, type)
  if type == 3 then
    return
  end
  local skill_info = ui.skill_find(id)
  local skill_excel = get_skill_excel(skill_info.excel_id, skill_info.type)
  if sys.check(skill_excel) ~= true then
    return
  end
  local xinfa_id = skill_excel.xinfa
  local xinfa_excel = bo2.gv_xinfa_list:find(xinfa_id)
  if xinfa_excel == nil then
    return
  end
  if xinfa_excel.type_id ~= bo2.eXinFaType_Other then
    return
  end
  ui_tab.show_page(w_skill, "fuzhi", true)
  local xinfa_item
  for k = 0, w_fuzhi_xinfa_list.item_count - 1 do
    local item = w_fuzhi_xinfa_list:item_get(k)
    if item ~= nil and item:search("xinfa_card").excel_id == xinfa_id then
      xinfa_item = item
      break
    end
  end
  if xinfa_item ~= nil then
    on_xinfa_item(xinfa_item, ui.mouse_lbutton_click)
  end
  stop_all_unlock_skill_anim(w_zhuzhi_info)
  stop_all_unlock_skill_anim(w_fuzhi_info)
  if skill_info.level == 0 then
    return
  end
  for i = 1, 6 do
    local skill_item = w_fuzhi_info:search("skill" .. i)
    local skill_excel_id = skill_item:search("skill_card").excel_id
    if skill_excel_id > 0 and skill_excel_id == id then
      local unlock_highlight = skill_item:search("unlock_highlight")
      unlock_highlight.visible = true
      unlock_highlight.transition = unlock_highlight_anim_uri
    end
  end
end
function stop_all_unlock_skill_anim(w)
  for i = 1, 6 do
    local skill_item = w:search("skill" .. i)
    local lock_frag1 = skill_item:search("lock_frag1_view")
    local lock_frag2 = skill_item:search("lock_frag2_view")
    local blade_track = skill_item:search("blade_track")
    local unlock_highlight = skill_item:search("unlock_highlight")
    lock_frag1.visible = false
    lock_frag2.visible = false
    blade_track.visible = false
    unlock_highlight.visible = false
    lock_frag1.transition = nil
    lock_frag2.transition = nil
    blade_track.transition = nil
    unlock_highlight.transition = nil
  end
end
function update_skill(excel_id, type)
  if excel_id == nil then
    return
  end
  if type == 3 then
    return
  end
  local excel = get_skill_excel(excel_id, type)
  if excel == nil then
    return
  end
  local xinfa_id = excel.xinfa
  local xinfa_excel = bo2.gv_xinfa_list:find(xinfa_id)
  if xinfa_excel ~= nil and xinfa_excel.type_id ~= bo2.eXinFaType_Etiquette then
    local xinfa_info = ui.xinfa_find(xinfa_id)
    if xinfa_info and xinfa_id == last_xinfa_selected and xinfa_item_list[xinfa_id] and sys.check(xinfa_item_list[xinfa_id].item) then
      on_xinfa_item(xinfa_item_list[xinfa_id].item, ui.mouse_lbutton_click)
    end
    if xinfa_excel.type_id == bo2.eXinFaType_Other then
      update_sw_bar(1)
    end
  elseif xinfa_excel ~= nil and xinfa_excel.type_id == bo2.eXinFaType_Etiquette then
    if type == 1 and excel.weapon2nd_type >= bo2.eItemtype_UseHWeapon and excel.weapon2nd_type <= bo2.eItemType_UseHWeaponEnd then
      return
    end
    local skill_info = ui.skill_find(excel_id)
    if skill_info then
      for i = 1, 60 do
        local item = w_liyi:search("skill" .. i)
        if item then
          if item:search("skill_card").excel_id == skill_info.excel_id then
            return
          end
          if item:search("skill_card").excel_id == 0 then
            item:search("skill_card").excel_id = skill_info.excel_id
            temp_flag = temp_flag + 1
            return
          end
        end
      end
    end
  else
    if type == 1 and excel.weapon2nd_type >= bo2.eItemtype_UseHWeapon and excel.weapon2nd_type <= bo2.eItemType_UseHWeaponEnd then
      return
    end
    local skill_info = ui.skill_find(excel_id)
    if skill_info then
      set_skill_card(w_qita, skill_info)
    end
  end
end
function update_equip(id)
  local info = ui.xinfa_find(id)
  local excel = bo2.gv_xinfa_list:find(id)
  if excel == nil then
    return
  end
  type_id = excel.type_id
  if info == nil then
    return
  end
  local item_list = xinfa_item_list[id]
  if item_list then
    local child_item = xinfa_item_list[id].item
    if sys.check(child_item) then
      local list_item = xinfa_item_list[id].list_item
      if sys.check(list_item) then
        list_item:item_remove(child_item.index)
        list_item.slider_y.visible = list_item.item_count > 6
        if sys.check(list_item:item_get(0)) then
          on_xinfa_item(list_item:item_get(0), ui.mouse_lbutton_click)
        elseif type_id == bo2.eXinFaType_Other then
          if item_list.item_count == 0 then
            ui_tab.get_button(w_skill, "fuzhi").visible = false
          else
            ui_tab.get_button(w_skill, "fuzhi").visible = true
          end
        end
      end
    end
    set_xinfa_card(info)
  end
  if type_id == bo2.eXinFaType_Other then
    update_sw_bar()
  end
end
function update_xinfa(id)
  local info = ui.xinfa_find(id)
  local excel = bo2.gv_xinfa_list:find(id)
  if excel == nil then
    return
  end
  type_id = excel.type_id
  ui_skill_master.update_xinfa_level(id)
  ui_skill_master.update_mas_pts_limit()
  if info == nil then
    local item_list = xinfa_item_list[id]
    if item_list then
      local child_item = xinfa_item_list[id].item
      if sys.check(child_item) then
        local list_item = xinfa_item_list[id].list_item
        if sys.check(list_item) then
          list_item:item_remove(child_item.index)
          list_item.slider_y.visible = list_item.item_count > 6
          if sys.check(list_item:item_get(0)) then
            on_xinfa_item(list_item:item_get(0), ui.mouse_lbutton_click)
          elseif type_id == bo2.eXinFaType_Other then
            if item_list.item_count == 0 then
              ui_tab.get_button(w_skill, "fuzhi").visible = false
            else
              ui_tab.get_button(w_skill, "fuzhi").visible = true
            end
          elseif type_id == bo2.eXinFaType_Living then
            if item_list.item_count == 0 or item_list.item_count == nil then
              ui_tab.get_button(w_skill, "livingskill").visible = false
              ui_tab.show_page(w_skill, "zhuzhi", true)
            else
              ui_tab.get_button(w_skill, "livingskill").visible = true
            end
          end
          xinfa_item_list[id] = nil
        end
      end
    end
    return
  else
    local item_list = xinfa_item_list[id]
    if item_list then
      local child_item = xinfa_item_list[id].item
      if sys.check(child_item) then
        if child_item.topper.visible then
          show_xinfa_skills(child_item:search("xinfa_card"))
        end
        local xinfa_name_text = excel.name
        child_item:search("level").text = "Lv." .. info.level
        if type_id == bo2.eXinFaType_Living then
          local exp = math.modf(get_livingskill_exp_value(id) / 100)
          local excel_levelup = bo2.gv_livingskill_levelup:find(info.level)
          if excel_levelup == nil then
            return
          end
          if info.level >= excel.level_max and exp >= excel_levelup.exp_max then
            local max_level = ui.get_text("skill|livingskill_max_level")
            xinfa_name_text = excel.name .. " " .. excel_levelup.name .. "(" .. max_level .. ")"
          else
            local next_level_exp = excel_levelup.exp_max
            xinfa_name_text = excel.name .. " " .. excel_levelup.name .. "(" .. exp .. "/" .. next_level_exp .. ")"
          end
        end
        child_item:search("name").text = xinfa_name_text
        local lb_class = child_item:search("class")
      end
    else
      set_xinfa_card(info)
    end
    if type_id == bo2.eXinFaType_Currency or type_id == bo2.eXinFaType_Expert or type_id == bo2.eXinFaType_Living then
      local head_info = ui.xinfa_head()
      if head_info == nil then
        return
      end
      local xinfaLv = 0
      while head_info ~= nil do
        local e = bo2.gv_xinfa_list:find(head_info.excel_id)
        if e and (e.type_id == bo2.eXinFaType_Currency or e.type_id == bo2.eXinFaType_Expert) then
          xinfaLv = xinfaLv + head_info.level
        end
        head_info = ui.next_xinfa(head_info.excel_id)
      end
      w_skill:search("xinfapingfen"):search("label").text = ui.get_text("skill|xinfa_score") .. xinfaLv
      if xinfaLv >= bo2.XINFA_SCORE_THRESHOLD then
        w_btn_xinfa_master.visible = true
      end
    elseif type_id == bo2.eXinFaType_Other and info.equip == 1 then
      ui_tab.get_button(w_skill, "fuzhi").visible = true
      update_sw_bar(1)
    end
  end
end
function on_preview_display(btn)
  local item = btn.topper
  if item:search("skill_card").excel_id ~= 0 then
    local excel = bo2.gv_skill_group:find(item:search("skill_card").excel_id)
    if excel then
      ui_skill_preview.set_preview_skill(excel.preview_id, 0)
    end
  end
end
function set_exp()
  local value = bo2.player:get_atb(bo2.eAtb_Cha_Exp)
  w_skill:search("cur_exp").text = value
  w_skill:search("zhuzhi_tab"):search("cur_exp").text = value
  w_skill:search("fuzhi_tab"):search("cur_exp").text = value
  ui_skill_learn.w_skill:search("zhuzhi_tab"):search("cur_exp").text = value
  ui_skill_learn.w_skill:search("fuzhi_tab"):search("cur_exp").text = value
end
function on_shortcut(obj, idx, val)
  sw_save()
end
function on_player_info_init(obj)
  if obj == bo2.player then
    obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Cha_Savvy, set_wuxing, "ui_skill.packet_handle")
    obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Cha_Exp, set_exp, "ui_skill.set_exp")
    obj:insert_on_flagmsg(bo2.eFlagType_Shortcut, 79, on_shortcut, "ui_skill.on_shortcut")
    obj:insert_on_flagmsg(bo2.eFlagType_Shortcut, 80, on_shortcut, "ui_skill.on_shortcut")
    obj:insert_on_flagmsg(bo2.eFlagType_Shortcut, 81, on_shortcut, "ui_skill.on_shortcut")
    obj:insert_on_flagmsg(bo2.eFlagType_Shortcut, 82, on_shortcut, "ui_skill.on_shortcut")
  end
end
function packet_xinfa_levelup(id)
  local v = sys.variant()
  v:set(packet.key.xinfa_levelup_id, id)
  bo2.send_variant(packet.eCTS_UI_XinFaLevelUp, v)
end
function on_zhuzhi_ok(btn)
  if sys.check(last_xinfa_highlight_ctrl) then
    local id = last_xinfa_highlight_ctrl:search("xinfa_card").excel_id
    packet_xinfa_levelup(id)
  end
  local obj = bo2.player
  if obj then
    local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_Anger_LevelUp)
    if flag_value == 16 and ui_handson_teach.w_flicker_levelup.visible == true then
      ui_handson_teach.test_complate_anger_level_up(false)
    end
  end
end
function update_sw_bar(note)
  if loading == true then
    return
  end
  local index = 79
  for i = 79, 82 do
    ui.shortcut_set(i, bo2.eShortcut_Skill, 0)
  end
  local info = ui.xinfa_head()
  if info == nil then
    return
  end
  if ui.item_of_coord(bo2.eItemArray_InSlot, bo2.eItemSlot_2ndWeapon) == nil then
    return
  end
  local find = false
  while info ~= nil do
    local excel = bo2.gv_xinfa_list:find(info.excel_id)
    local type = excel.type_id
    if type == bo2.eXinFaType_Other then
      local item_info = ui.item_of_coord(bo2.eItemArray_InSlot, bo2.eItemSlot_2ndWeapon)
      if item_info then
        local item_excel = bo2.gv_equip_item:find(item_info.excel_id)
        if item_excel and item_excel.type == excel.weapon_type then
          find = true
          if info.equip == 0 and note == nil then
            break
          end
          local head_skill = info.head_skill
          if head_skill ~= nil then
          else
            ui.log("head_skill nil")
            return
          end
          local skills = sw_load(item_excel.type)
          if skills == nil then
            local skill_info = ui.skill_find(head_skill.excel_id)
            local skill_tmp_table = {}
            while skill_info ~= nil do
              if bo2.is_master_passive_skill(skill_info.excel_id) == false then
                table.insert(skill_tmp_table, skill_info)
              end
              skill_info = ui.next_skill(skill_info.excel_id)
            end
            table.sort(skill_tmp_table, skill_sort)
            local cnt_skill = #skill_tmp_table
            for i, v in ipairs(skill_tmp_table) do
              ui.shortcut_set(index, bo2.eShortcut_Skill, v.excel_id)
              index = index + 1
            end
          else
            for i, v in ipairs(skills) do
              ui.shortcut_set(index, bo2.eShortcut_Skill, v)
              index = index + 1
            end
            local skill_info = ui.skill_find(head_skill.excel_id)
            while skill_info ~= nil do
              if bo2.is_master_passive_skill(skill_info.excel_id) == false then
                local ok = false
                for i, v in ipairs(skills) do
                  if skill_info.excel_id == v then
                    ok = true
                    break
                  end
                end
                if ok == false then
                  for i, v in ipairs(skills) do
                    if v == 0 then
                      skills[i] = skill_info.excel_id
                      ui.shortcut_set(78 + i, bo2.eShortcut_Skill, skill_info.excel_id)
                      break
                    end
                  end
                end
              end
              skill_info = ui.next_skill(skill_info.excel_id)
            end
          end
          return
        end
      end
    end
    info = ui.next_xinfa(info.excel_id)
  end
  if find ~= false or note == nil then
  end
end
function sw_load(type)
  local cfg = ui_main.player_cfg_load("sw_shortcut.xml")
  local node
  local skills = {}
  if cfg ~= nil then
    node = cfg:find("type" .. type)
    local xnode, x
    if node then
      for i = 79, 82 do
        xnode = node:find("skill" .. i)
        x = xnode:get_attribute("value")
        table.insert(skills, tonumber(tostring(x)))
      end
    else
      return nil
    end
  end
  return skills
end
function sw_save()
  local item_info = ui.item_of_coord(bo2.eItemArray_InSlot, bo2.eItemSlot_2ndWeapon)
  if item_info then
    local item_excel = bo2.gv_equip_item:find(item_info.excel_id)
    index = item_excel.type
    local root = ui_main.player_cfg_load("sw_shortcut.xml")
    if root == nil then
      root = sys.xnode()
    end
    local item = root:get("type" .. index)
    if item == nil then
      item = root:add("type" .. index)
    end
    item:clear()
    for i = 79, 82 do
      local info = ui.shortcut_get(i)
      if info ~= nil and info.kind == bo2.eShortcut_Skill then
        local x = item:add("skill" .. i)
        x:set_attribute("value", info.only_id)
      end
    end
    ui_main.player_cfg_save(root, "sw_shortcut.xml")
  end
end
function update_wheapon()
  local info = ui.item_of_coord(bo2.eItemArray_InSlot, bo2.eItemSlot_HWeapon)
  if info ~= nil then
    local excel = bo2.gv_equip_item:find(info.excel_id)
    if excel == nil then
      return
    end
    ui.skill_insert(excel.use_par[0], 1, 3)
    cur_hweapon = info
  elseif sys.check(cur_hweapon) then
    local excel = bo2.gv_equip_item:find(cur_hweapon.excel_id)
    if excel == nil then
      return
    end
    ui.skill_remove(excel.use_par[0])
    cur_hweapon = nil
  end
end
function on_pro_view(btn)
  ui_skill_preview.on_pro_skill_preview()
end
function insert_tab(name)
  local btn_uri = "$frame/skill/skill.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/skill/skill.xml"
  local page_sty = name
  ui_tab.insert_suit(w_skill, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_skill, name)
  btn.text = ui.get_text("skill|" .. name)
end
function hotkey_update()
  local player = bo2.player
  if player == nil then
    return
  end
  local txt = ui_setting.ui_input.get_op_simple_text(2006)
  local lb_title = w_skill:search("lb_title")
  if txt ~= nil and not txt.empty then
    lb_title.text = ui_widget.merge_mtf({name = txt}, ui.get_text("skill|main_title_param"))
  else
    lb_title.text = ui.get_text("skill|main_title")
  end
end
function createfinished()
  loading = false
end
function on_init(ctrl)
  temp_flag = 1
  loading = true
  last_highlight_ctrl = nil
  last_xinfa_selected = nil
  xinfa_item_list = {}
  ui_tab.clear_tab_data(w_skill)
  ui_tab.make_adaptive(w_skill, true)
  insert_tab("zhuzhi")
  insert_tab("fuzhi")
  insert_tab("livingskill")
  insert_tab("qita")
  insert_tab("liyi")
  insert_tab("hunskill")
  ui_tab.show_page(w_skill, "zhuzhi", true)
  ui_tab.set_button_sound(w_skill, 578)
  gain_init()
  ui_setting.ui_input.hotkey_notify_insert(hotkey_update, "ui_skill.hotkey_update")
  hotkey_update()
end
function on_xinfapingfen_show(tip)
  local card = tip.owner
  local stk = sys.mtf_stack()
  stk:raw_push(ui.get_text("skill|xinfaxiuwei_desc"))
  ui_tool.ctip_show(card, stk)
end
function on_xinfa_tip_show(tip)
  local card = tip.owner:search("xinfa_card")
  local excel_id = card.excel_id
  if excel_id == nil or excel_id == 0 then
    return
  end
  local xinfa_info = ui.xinfa_find(excel_id)
  if xinfa_info == nil then
    return
  end
  local stk = sys.mtf_stack()
  local xinfa_type = bo2.gv_xinfa_list:find(xinfa_info.excel_id).type_id
  if bo2.eXinFaType_Living == xinfa_type then
    ui_tool.ctip_make_xinfa_livingskill(stk, xinfa_info)
  else
    ui_tool.ctip_make_xinfa(stk, xinfa_info)
  end
  ui_tool.ctip_show(tip.owner, stk)
end
ui.insert_xinfa(update_xinfa, "update_xinfa")
ui.insert_skill(update_skill, "update_skill")
ui.insert_equip(update_equip, "update_equip")
ui.insert_unlock_skill(on_unlock_skill, "xinfa")
ui.insert_unlock_new_skill(on_unlock_new_skill, "xinfa")
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_skill.packet_handle"
reg(packet.eSTC_UI_Zhanfa, insert_zhanfa, sig)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_player_info_init, sig)
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, createfinished, sig .. "ui_skill.packet.createfinished")
