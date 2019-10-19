local ui_tab = ui_widget.ui_tab
local common_xinfa_num = 5
local branch_xinfa_num = 5
local fuzhi_xinfa_num = 10
local skill_num = 10
local qita_skill_num = 20
local uri = "$frame/skill/skill.xml"
local xinfa_sty = "card_xinfa"
local skill_sty = "card_skill"
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
function insert_qita_skill(excel_id, type)
  if excel_id == nil then
    return
  end
  local excel = get_skill_excel(excel_id, type)
  if excel == nil then
    return
  end
  local xinfa_id = excel.xinfa
  if xinfa_id ~= 0 then
    return
  end
  local skill_info = ui.skill_find(excel_id)
  if skill_info then
    set_skill_card(w_qita, skill_info)
  end
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
    if skill_info.type == 0 then
      return
    end
    if skill_info.level == 0 then
      return
    end
    if ui.is_key_down(ui.VK_CONTROL) then
      ui_chat.insert_skill(skill_info.excel_id, skill_info.level, skill_info.type)
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
  elseif msg == ui.mouse_lbutton_drag then
    if skill_info.type == 0 then
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
    if ctrl == nil then
      return
    end
    if not sys.check(ctrl) then
      return
    end
    local highlight = ctrl:search("highlight")
    if highlight then
      highlight.visible = flag
    end
  end
  if xinfa then
    set_highlight_in(last_highlight_ctrl, false)
    set_highlight_in(last_xinfa_highlight_ctrl, false)
    last_highlight_ctrl = nil
    last_xinfa_highlight_ctrl = ctrl
    last_xinfa_selected = last_xinfa_highlight_ctrl:search("xinfa_card").excel_id
    set_highlight_in(ctrl, true)
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
function on_zhuzhi_visible(window)
  if window.visible == true then
    set_wuxing()
    if w_zhuzhi_xinfa_list:item_get(0) then
      on_xinfa_item(w_zhuzhi_xinfa_list:item_get(0), ui.mouse_lbutton_click)
    else
      last_xinfa_highlight_ctrl = nil
    end
  end
end
function on_fuzhi_visible(window)
  if window.visible == true then
    set_wuxing()
    if w_fuzhi_xinfa_list:item_get(0) then
      on_xinfa_item(w_fuzhi_xinfa_list:item_get(0), ui.mouse_lbutton_click)
    else
      last_xinfa_highlight_ctrl = nil
    end
  end
end
function on_open_lianzhao()
  ui_lianzhao.w_lianzhao.visible = true
end
function on_wuxing_show(tip)
  local card = tip.owner
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_wuxing(stk)
  ui_tool.ctip_show(card, stk)
end
function on_window_visible(window)
  if window.visible == true then
    local player = bo2.player
    if player == nil then
      return
    end
    if not sys.check(player) then
      return
    end
    local value = player:get_atb(bo2.eAtb_Cha_Exp)
    set_wuxing()
    fuzhi_xinfa_limited()
    ui_tab.show_page(w_skill, "zhuzhi", true)
    if ui_tab.get_page(w_skill, "zhuzhi").visible == true then
      on_xinfa_item(w_zhuzhi_xinfa_list:item_get(0), ui.mouse_lbutton_click)
    elseif ui_tab.get_page(w_skill, "fuzhi").visible == true then
      ui.log("item_count %s", w_fuzhi_xinfa_list.item_count)
      if w_fuzhi_xinfa_list.item_count == 0 then
        w_fuzhi_xinfa_list:search("btn_fuzhi_levelup").enable = false
      else
        w_fuzhi_xinfa_list:search("btn_fuzhi_levelup").enable = true
      end
    end
  end
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
  for i = 1, 6 do
    local item = w:search("skill" .. i)
    if item:search("skill_card").excel_id == 0 then
      item:search("skill_card").excel_id = info.excel_id
      local excel = get_skill_excel(info.excel_id, info.type)
      item:search("name").text = excel.name
      if info.level == 0 then
        if info.type == 1 then
          local req_level = bo2.gv_skill_level:find(info.excel_id).unlock
          local arg = sys.variant()
          arg:set("level", req_level)
          item:search("level").text = sys.mtf_merge(arg, ui.get_text("skill|xinfa_unlock_desc"))
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
      if info.level == 0 then
        item:search("lock").visible = true
      end
      local combo = item:search("zhanfa")
      ui_widget.ui_combo_box.clear(combo)
      if zhanfa_trait_list[info.excel_id] then
        for i, v in ipairs(zhanfa_trait_list[info.excel_id]) do
          local trait_excel = bo2.gv_trait_list:find(v.trait)
          ui.log("trait_excel %s", trait_excel)
          if trait_excel then
            ui_widget.ui_combo_box.append(combo, {
              id = v.zhanfa_id,
              text = trait_excel.desc
            })
            if v.use == 1 then
              ui_widget.ui_combo_box.select(combo, v.zhanfa_id)
            end
          end
        end
      end
      combo.svar.on_select = use_zhanfa
      return
    end
  end
end
function show_xinfa_skills(card)
  local set_info = function(w, info)
    w:search("xinfa_title_name").text = info.excel.name
    w:search("desc").text = bo2.gv_text:find(info.excel.desc_id).text
    local level = info.level
    local mb_levelup = bo2.gv_xinfa_levelup_spend:find(level + 1)
    w:search("cur_exp").text = bo2.player:get_atb(bo2.eAtb_Cha_Exp)
    if not mb_levelup then
      w:search("money").money = 0
      w:search("need_exp").text = ui.get_text("skill|reach_level_peak")
    else
      local exp_id = info.excel.exp_id
      local data1 = "data" .. exp_id * 2 - 1
      local data2 = "data" .. exp_id * 2
      local req_exp = mb_levelup[data1]
      local req_money = mb_levelup[data2]
      w:search("money").money = req_money
      w:search("need_exp").text = req_exp
    end
    local head_skill = info.head_skill
    if head_skill ~= nil then
    else
      return
    end
    local skill_info = ui.skill_find(head_skill.excel_id)
    while skill_info ~= nil do
      set_skill_card(w, skill_info)
      skill_info = ui.next_skill(skill_info.excel_id)
    end
  end
  if card.excel_id == 0 then
    return
  end
  local xinfa_info = ui.xinfa_find(card.excel_id)
  if xinfa_info == nil then
    return
  end
  local type = bo2.gv_xinfa_list:find(xinfa_info.excel_id).type_id
  if type == bo2.eXinFaType_Currency then
    clear_info(w_zhuzhi_info)
    set_info(w_zhuzhi_info, xinfa_info)
  elseif type == bo2.eXinFaType_Expert then
    clear_info(w_zhuzhi_info)
    set_info(w_zhuzhi_info, xinfa_info)
  elseif type == bo2.eXinFaType_Other then
    clear_info(w_fuzhi_info)
    set_info(w_fuzhi_info, xinfa_info)
  end
end
function insert_xinfa(w, id, lv)
  local child_item_uri = L("$frame/skill/common.xml")
  local child_item_style = L("xinfa_item")
  local child_item = w:item_append()
  child_item:load_style(child_item_uri, child_item_style)
  child_item:search("xinfa_card").excel_id = id
  local excel = bo2.gv_xinfa_list:find(id)
  if excel == nil then
    return
  end
  child_item:search("name").text = excel.name
  child_item:search("level").text = ui.get_text("skill|level") .. "          " .. lv
  return child_item
end
function on_xinfa_item(btn, msg)
  if msg == ui.mouse_lbutton_click then
    set_highlight(btn, 1)
    if btn:search("xinfa_card") then
      show_xinfa_skills(btn:search("xinfa_card"))
    end
  end
end
function on_skill_item(btn, msg)
end
function set_xinfa_card(info)
  local type = bo2.gv_xinfa_list:find(info.excel_id).type_id
  if type == bo2.eXinFaType_Currency then
    return insert_xinfa(w_zhuzhi_xinfa_list, info.excel_id, info.level)
  elseif type == bo2.eXinFaType_Expert then
    return insert_xinfa(w_zhuzhi_xinfa_list, info.excel_id, info.level)
  elseif type == bo2.eXinFaType_Other then
    return insert_xinfa(w_fuzhi_xinfa_list, info.excel_id, info.level)
  end
end
function clear_info(w)
  w:search("xinfa_title_name").text = ""
  w:search("desc").text = ""
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
    item:search("lock").visible = false
  end
end
function update_xinfa()
  local clear = function()
    w_zhuzhi_xinfa_list:item_clear()
    w_fuzhi_xinfa_list:item_clear()
    clear_info(w_zhuzhi_info)
    clear_info(w_fuzhi_info)
  end
  clear()
  local info = ui.xinfa_head()
  if info == nil then
    return
  end
  local xinfaLv = 0
  while info ~= nil do
    local item = set_xinfa_card(info)
    if last_xinfa_selected == info.excel_id then
      on_xinfa_item(item, ui.mouse_lbutton_click)
    end
    local type = bo2.gv_xinfa_list:find(info.excel_id).type_id
    if type == bo2.eXinFaType_Currency or type == bo2.eXinFaType_Expert then
      xinfaLv = xinfaLv + info.level
    end
    info = ui.next_xinfa(info.excel_id)
  end
  w_skill:search("xinfapingfen"):search("label").text = ui.get_text("skill|xinfa_score") .. xinfaLv
  fuzhi_xinfa_limited()
end
function fuzhi_xinfa_limited()
  local xinfa_limited = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_OtherXinFa)
  local fuzhi_num = w_fuzhi_xinfa_list.item_count
  w_xinfa_list_label.text = sys.format(ui.get_text("xinfa_list") .. " %s/%s", fuzhi_num, xinfa_limited)
end
function insert_tab(w, name)
  local btn_uri = "$frame/skill/skill_learn.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/skill/skill_learn.xml"
  local page_sty = name
  ui_tab.insert_suit(w, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w, name)
  btn.text = ui.get_text("skill|" .. name)
end
function on_init(ctrl)
  last_highlight_ctrl = nil
  last_xinfa_selected = nil
  current_list = nil
  common_xinfa_list = {}
  branch_xinfa_list = {}
  zhuzhi_xinfa_list = {}
  fuzhi_xinfa_list = {}
  zhiye_skill_list = {}
  fuzhi_skill_list = {}
  qita_skill_list = {}
  zhanfa_list = {}
  zhanfa_trait_list = {}
  ui_tab.clear_tab_data(w_skill)
  insert_tab(w_skill, "zhuzhi")
  insert_tab(w_skill, "fuzhi")
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_skill.packet_handle"
function on_preview_display(btn)
  local item = btn.topper
  if item:search("skill_card").excel_id ~= 0 then
    local excel = bo2.gv_skill_group:find(item:search("skill_card").excel_id)
    if excel then
      ui_skill_preview.set_preview_skill(excel.preview_id, 0)
    end
  end
end
function update_zhanfa()
  for i = 1, 6 do
    local item = w_skill:search("skill" .. i)
    local excel_id = item:search("skill_card").excel_id
    if excel_id ~= 0 then
      local combo = item:search("zhanfa")
      ui_widget.ui_combo_box.clear(combo)
      if zhanfa_trait_list[excel_id] then
        for i, v in ipairs(zhanfa_trait_list[excel_id]) do
          local trait_excel = bo2.gv_trait_list:find(v.trait)
          ui.log("trait_excel %s", trait_excel)
          if trait_excel then
            ui_widget.ui_combo_box.append(combo, {
              id = v.zhanfa_id,
              text = trait_excel.desc
            })
            if v.use == 1 then
              ui_widget.ui_combo_box.select(combo, v.zhanfa_id)
            end
          end
        end
      end
      combo.svar.on_select = use_zhanfa
    end
  end
end
function insert_zhanfa(cmd, data)
  ui.log("insert_zhanfa")
  local id = data:get(packet.key.zhanfa_id).v_int
  local use = data:get(packet.key.zhanfa_use).v_int
  local excel = bo2.gv_martingale:find(id)
  if excel == nil then
    return
  end
  zhanfa_list[id] = use
  local skill_id = excel.skillId
  local trait_id = excel.traitId
  zhanfa_trait_list[skill_id] = {}
  table.insert(zhanfa_trait_list[skill_id], {
    zhanfa_id = id,
    trait = trait_id,
    use = use
  })
  update_zhanfa()
end
function zhanfa_learn(id)
  local item_excel = bo2.gv_item_list:find(id)
  if item_excel == nil then
    return
  end
  local zhanfa_id = item_excel.use_par[0]
  if zhanfa_list[zhanfa_id] then
    return true
  else
    return false
  end
end
function on_zhuzhi_ok(btn)
  if sys.check(last_xinfa_highlight_ctrl) then
    local id = last_xinfa_highlight_ctrl:search("xinfa_card").excel_id
    ui.log("packet_xinfa_levelup %s", id)
    packet_xinfa_levelup(id)
  end
end
function on_skill_learn_open(id)
  ui.log("id %s", id)
  if id == bo2.eNpcFunc_ZhuzhiXinfaLearn then
    local btn = ui_tab.get_button(w_skill, "fuzhi")
    btn.visible = false
    ui_tab.show_page(w_skill, "zhuzhi", true)
  elseif id == bo2.eNpcFunc_FuzhiXinfaLearn then
    local btn = ui_tab.get_button(w_skill, "zhuzhi")
    btn.visible = false
    ui_tab.show_page(w_skill, "fuzhi", true)
  else
    local func_excel = bo2.gv_npc_func:find(id)
    local npc_pro = func_excel.datas[0]
    local pro = bo2.player:get_atb(bo2.eAtb_Cha_Profession)
    ui.log("func %s %s %s", func_excel, npc_pro, pro)
    if bo2.gv_profession_list:find(pro) then
      local career = bo2.gv_profession_list:find(pro).career
      ui.log("%s %s", career, npc_pro)
      if career ~= npc_pro then
        w_skill.visible = false
        ui_tool.note_insert(ui.get_text("skill|wrong_class"), "ff0000")
      end
    end
  end
end
function on_xinfapingfen_show(tip)
  local card = tip.owner
  local stk = sys.mtf_stack()
  stk:raw_push(ui.get_text("skill|xinfaxiuwei_desc"))
  ui_tool.ctip_show(card, stk)
end
