local ui_tab = ui_widget.ui_tab
local color_white = ui.make_color("FFFFFF")
local color_dark_yellow = ui.make_color("E0B060")
local g_sep_bar_unit = 26
local g_sep_skill_cnt = 3
function get_skill_excel(excel_id)
  local excel = bo2.gv_passive_skill:find(excel_id)
  return excel
end
function on_wuxing_show()
end
function on_xinfapingfen_show()
end
function on_xinfa_tip_show()
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
function on_skill_card_mouse(card, msg)
  if msg ~= ui.mouse_lbutton_down then
    return
  end
  local player = bo2.player
  if player == nil then
    return
  end
  local excel_id = card.excel_id
  if excel_id <= 0 then
    return
  end
  local skill_excel = bo2.gv_passive_skill:find(excel_id)
  if skill_excel == nil then
    return
  end
  local skill_info = ui.skill_find(excel_id)
  if skill_info ~= nil then
    ui_tool.note_insert(ui.get_text("skill|skill_learnt"), "FF0000")
    return
  end
  local unlock_level = skill_excel.level1[0]
  local xinfa_mas_level = ui.xinfa_find(skill_excel.xinfa).mas_level
  if unlock_level > xinfa_mas_level then
    ui_tool.note_insert(ui.get_text("skill|skill_locked"), "FF0000")
    return
  end
  local master_points = player:get_flag_int32(bo2.ePlayerFlagInt32_XinfaMasterPoints)
  local pts_req = skill_excel.extra[0]
  if master_points < pts_req then
    ui_tool.note_insert(ui.get_text("skill|master_points_insufficient"), "FF0000")
    return
  end
  if skill_excel.tgt_skill.size == 2 then
    local tgt_skill_id = skill_excel.tgt_skill[0]
    local tgt_skill_info = ui.skill_find(tgt_skill_id)
    if tgt_skill_info == nil or tgt_skill_info.level == 0 then
      ui_tool.note_insert(ui.get_text("skill|tgt_skill_locked"), "FF0000")
      return
    end
  end
  local function on_msg_callback(msg_call)
    if msg_call.result ~= 1 then
      return
    end
    local v = sys.variant()
    v:set(packet.key.skill_id, excel_id)
    bo2.send_variant(packet.eCTS_UI_LearnMasterSkill, v)
  end
  local text_show = ui_widget.merge_mtf({num = pts_req}, ui.get_text("skill|learn_mas_skill_hint"))
  local msg = {callback = on_msg_callback, text = text_show}
  ui_widget.ui_msg_box.show_common(msg)
end
function on_prog_bar_tip_show(tip)
  local bar = tip.owner
  local stk = sys.mtf_stack()
  local item_sel = w_zhuzhi_xinfa_list.item_sel
  local xinfa_id = item_sel:search("xinfa_card").excel_id
  local xinfa_info = ui.xinfa_find(xinfa_id)
  local dmg_num = 0
  local master_hit_line = bo2.gv_xinfa_master_hit:find(xinfa_info.mas_level)
  if master_hit_line ~= nil then
    dmg_num = (master_hit_line.factor - 1) * 100 + 1.0E-5
    dmg_num = dmg_num - dmg_num % 0.01
  end
  local txt = ui_widget.merge_mtf({num = dmg_num}, ui.get_text("skill|dmg_rate"))
  ui_tool.ctip_push_text(stk, txt)
  ui_tool.ctip_show(bar, stk)
end
local make_percent = function(r)
  r = r * 100
  if r > 100 then
    r = 100
  end
  local f = math.floor(r)
  if r - f > 0.5 then
    return f + 1
  end
  return f
end
function on_bar_lock_tip_show(tip)
  local lock_pic = tip.owner
  local item_sel = w_zhuzhi_xinfa_list.item_sel
  local xinfa_id = item_sel:search("xinfa_card").excel_id
  local xinfa_info = ui.xinfa_find(xinfa_id)
  local break_lv
  if lock_pic.name == L("bar_lock1") then
    break_lv = 2
  elseif lock_pic.name == L("bar_lock2") then
    break_lv = 3
  end
  local break_cur_lv = xinfa_info.mas_break_lv
  local break_excel = bo2.gv_xinfa_master_break:find(break_lv)
  local item_id = break_excel.item_id
  local break_rate = break_excel.base_suc_rate
  local fail_rate = 0
  if break_lv - break_cur_lv == 1 then
    fail_rate = xinfa_info.mas_break_fail_cnt * break_excel.fail_add_rate
  end
  local bar = tip.owner
  local stk = sys.mtf_stack()
  ui_tool.ctip_push_text(stk, ui.get_text("skill|master_break_lv") .. break_excel.name)
  ui_tool.ctip_push_sep(stk)
  stk:raw_push(ui.get_text("skill|master_break_desc"))
  for i = 0, item_id.size - 1 do
    local item_id_n = item_id[i]
    if item_id_n ~= 0 then
      ui_tool.ctip_push_sep(stk)
      stk:merge({id = item_id_n}, ui.get_text("skill|master_break_item"))
      ui_tool.ctip_push_newline(stk)
      ui_tool.ctip_push_text(stk, ui.get_text("skill|master_break_rate"))
      stk:format("%d%%", make_percent(break_rate[i] + fail_rate))
    end
  end
  ui_tool.ctip_show(bar, stk)
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel_id = card.excel_id
  if excel_id == nil or excel_id == 0 then
    return
  end
  local excel = get_skill_excel(excel_id)
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  local info = ui.skill_find(excel_id)
  ui_tool.ctip_make_master_passive_skill(stk, excel, info)
  ui_tool.ctip_show(card, stk)
end
function on_pts_limit_desc_show(tip)
  local owner = tip.owner
  local stk = sys.mtf_stack()
  local merge_tb = {
    threshold = bo2.XINFA_SCORE_THRESHOLD,
    gap = bo2.XINFA_SCORE_GAP,
    unit = 1
  }
  local txt_show = ui_widget.merge_mtf(merge_tb, ui.get_text("skill|mas_pts_limit_desc"))
  stk:raw_format("%s", txt_show)
  ui_tool.ctip_show(owner, stk)
end
function on_skill_item_mouse(item, msg)
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
function on_zhuzhi_visible(ctrl)
end
function on_window_visible(window)
  if window.visible == true then
    local head_item = w_zhuzhi_xinfa_list:item_get(0)
    on_xinfa_item(head_item, ui.mouse_lbutton_click)
    head_item.selected = true
    on_master_points_change()
  end
end
function clear_info(w)
  w:search("xinfa_title_name").text = ""
  for i = 1, bo2.gv_xinfa_master_break.size do
    local sep = w:search("mas_stage" .. i)
    for j = 1, g_sep_skill_cnt do
      local item = sep:search("skill" .. j)
      item:search("skill_card").excel_id = 0
      item:search("skill_frame").visible = false
      item:search("skill_lv").visible = false
      item:search("skill_card").draw_gray = false
    end
  end
end
function set_skill_card(skill_excel, item)
  item:search("skill_card").excel_id = skill_excel.id
  item:search("skill_frame").visible = true
  item:search("skill_card").draw_gray = false
  local unlock_level = skill_excel.level1[0]
  local xinfa_mas_level = ui.xinfa_find(skill_excel.xinfa).mas_level
  if unlock_level > xinfa_mas_level then
    item:search("skill_card").draw_gray = true
  else
    local skill_info = ui.skill_find(skill_excel.id)
    if skill_info == nil then
      item:search("skill_card").draw_gray = true
    else
      if skill_info.level == 0 then
        item:search("skill_card").draw_gray = true
      end
      item:search("skill_lv").visible = true
      item:search("skill_lv").text = skill_info.level
    end
  end
end
function show_xinfa_skills(xinfa_id)
  local function set_info(w, info)
    w:search("xinfa_title_name").text = info.excel.name
    local mas_level = info.mas_level
    local break_lv = info.mas_break_lv
    local break_line = bo2.gv_xinfa_master_break:find(break_lv)
    if break_line == nil then
      ui.log("!!!!THEY SUCK!!!!")
      return
    end
    local sep_bar = w:search("sep_bar")
    sep_bar.dx = mas_level * g_sep_bar_unit
    for i = 1, bo2.gv_xinfa_master_break.size do
      local pic_stage = w:search("mas_stage" .. i):search("pic_bg")
      local lv_peak = bo2.gv_xinfa_master_break:get(i - 1).lv_peak
      if mas_level < lv_peak then
        pic_stage.color = ui.make_argb("88ffffff")
      else
        pic_stage.color = ui.make_argb("ffffffff")
      end
      local pic_bar_lock = w:search("bar_lock" .. i)
      if pic_bar_lock ~= nil then
        if i < break_lv then
          pic_bar_lock.visible = false
        else
          pic_bar_lock.visible = true
        end
      end
    end
    if mas_level == break_line.lv_peak then
      w_btn_master.text = ui.get_text("skill|xinfa_master_break")
      w_btn_master:insert_on_click(on_xinfa_master_break, "ui_skill_master.on_master_btn_click")
    else
      w_btn_master.text = ui.get_text("skill|xinfa_master")
      w_btn_master:insert_on_click(on_xinfa_assign_points, "ui_skill_master.on_master_btn_click")
    end
    local skill_tmp_table = {}
    local xinfa_excel = info.excel
    local arr_master
    arr_master = xinfa_excel.beskill_master_0
    for i = 0, arr_master.size - 1 do
      local excel = get_skill_excel(arr_master[i])
      table.insert(skill_tmp_table, excel)
    end
    arr_master = xinfa_excel.beskill_master_1
    for i = 0, arr_master.size - 1 do
      local excel = get_skill_excel(arr_master[i])
      table.insert(skill_tmp_table, excel)
    end
    for _, v in ipairs(skill_tmp_table) do
      local unlock_lv = v.level1[0]
      for k = 1, bo2.gv_xinfa_master_break.size do
        local line = bo2.gv_xinfa_master_break:get(k - 1)
        local lv_peak = line.lv_peak
        if unlock_lv <= lv_peak then
          local sep = w:search("mas_stage" .. k)
          local skill_idx = v.extra[1]
          local skill_item = sep:search("skill" .. skill_idx)
          if skill_item ~= nil then
            set_skill_card(v, skill_item)
          end
          break
        end
      end
    end
  end
  if xinfa_id == 0 then
    return
  end
  local xinfa_info = ui.xinfa_find(xinfa_id)
  if xinfa_info == nil then
    return
  end
  local type = bo2.gv_xinfa_list:find(xinfa_info.excel_id).type_id
  local tab = w_skill_master:search("zhuzhi_tab")
  clear_info(tab)
  set_info(tab, xinfa_info)
end
function on_xinfa_item(btn, msg)
  if msg == ui.mouse_lbutton_click then
    if btn == nil then
      last_xinfa_highlight_ctrl = nil
      return
    end
    set_highlight(btn, 1)
    local xinfa_card = btn:search("xinfa_card")
    if xinfa_card then
      show_xinfa_skills(xinfa_card.excel_id)
    end
  end
end
function on_choose_confirm(btn)
  local data = ui_widget.ui_msg_box.get_data(btn)
  if data == nil then
    return
  end
  local choose_list = data.window:search("choose_list")
  local item_sel = choose_list.item_sel
  if item_sel == nil then
    ui_tool.note_insert(ui.get_text("skill|master_break_note"), "ffffff00")
    return
  end
  data.result = 1
  data.excel_id = item_sel:search("card").excel.id
  ui_widget.ui_msg_box.invoke(data)
end
function on_xinfa_master_break(btn)
  local item_sel = w_zhuzhi_xinfa_list.item_sel
  if item_sel == nil then
    ui_tool.note_insert(ui.get_text("skill|note_select_xinfa"), "FF0000")
    return
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/skill/skill_master.xml",
    style_name = "break_msg_box",
    callback = function(msg)
      if msg.result == 0 then
        return
      end
      local xinfa_id = item_sel:search("xinfa_card").excel_id
      local v = sys.variant()
      v[packet.key.xinfa_masterbreak_id] = xinfa_id
      v[packet.key.item_excelid] = msg.excel_id
      bo2.send_variant(packet.eCTS_UI_XinfaMasterBreak, v)
    end,
    modal = true
  })
end
function choose_update(item)
  local vis = item.selected or item.inner_hover
  local fig = item:search("fig_highlight")
  fig.visible = vis
end
function on_choose_sel(item, sel)
  choose_update(item)
end
function on_choose_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    choose_update(item)
    return
  end
end
function on_choose_card_mouse(card, msg)
  if msg == ui.mouse_lbutton_click then
    card:upsearch_type("ui_list_item").selected = true
  end
end
function on_choose_quick_buy(btn)
  local data = ui_widget.ui_msg_box.get_data(btn)
  if data == nil then
    return
  end
  data.result = 0
  ui_widget.ui_msg_box.invoke(data)
  local id = btn:upsearch_type("ui_list_item"):search("card").excel.id
  ui_supermarket2.shelf_quick_buy(w_quick_buy_btn, id, function()
    on_xinfa_master_break(w_btn_master)
  end)
end
function on_break_msg_visible(ctrl, vis)
  if not vis then
    return
  end
  ctrl:apply_dock(true)
  local rb_desc = ctrl:search("rb_desc")
  rb_desc:update()
  rb_desc.dy = rb_desc.extent.y
  local choose_list = ctrl:search("choose_list")
  local item_sel = w_zhuzhi_xinfa_list.item_sel
  local xinfa_id = item_sel:search("xinfa_card").excel_id
  local xinfa_info = ui.xinfa_find(xinfa_id)
  local break_cur_lv = xinfa_info.mas_break_lv
  local break_excel = bo2.gv_xinfa_master_break:find(break_cur_lv + 1)
  local item_id = break_excel.item_id
  local break_rate = break_excel.base_suc_rate
  local fail_rate = xinfa_info.mas_break_fail_cnt * break_excel.fail_add_rate
  for i = 0, item_id.size - 1 do
    local excel_id = item_id[i]
    if excel_id > 0 then
      local item = choose_list:item_append()
      item:load_style("$frame/skill/skill_master.xml", "choose_item")
      local card = item:search("card")
      local lb_name = item:search("lb_name")
      card.excel_id = excel_id
      local excel = card.excel
      lb_name.text = excel.name
      lb_name.color = ui.make_color(excel.plootlevel_star.color)
      item:search("lb_rate").text = sys.format("%s%d%%", ui.get_text("skill|master_break_rate"), make_percent(break_rate[i] + fail_rate))
      item:search("quick_buy").visible = 0 < ui_supermarket2.shelf_quick_buy_id(excel.id)
    end
  end
  ctrl:tune_y("choose_list")
end
function on_xinfa_assign_points(btn)
  local player = bo2.player
  if player == nil then
    return
  end
  local master_points = player:get_flag_int32(bo2.ePlayerFlagInt32_XinfaMasterPoints)
  if master_points <= 0 then
    ui_tool.note_insert(ui.get_text("skill|master_points_insufficient"), "FF0000")
    return
  end
  if sys.check(last_xinfa_highlight_ctrl) then
    local id = last_xinfa_highlight_ctrl:search("xinfa_card").excel_id
    local v = sys.variant()
    v:set(packet.key.xinfa_masterlevelup_id, id)
    bo2.send_variant(packet.eCTS_UI_XinfaMasterLevelUp, v)
  end
end
function insert_tab(name)
  local btn_uri = "$frame/skill/skill_master.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/skill/skill_master.xml"
  local page_sty = name
  ui_tab.insert_suit(w_skill_master, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_skill_master, name)
  btn.text = ui.get_text("skill|" .. name)
end
function on_init(ctrl)
  last_highlight_ctrl = nil
  last_xinfa_selected = nil
end
function update_xinfa_level(id)
  local xinfa_info = ui.xinfa_find(id)
  if xinfa_info == nil then
    return
  end
  for i = 0, w_zhuzhi_xinfa_list.item_count - 1 do
    local item = w_zhuzhi_xinfa_list:item_get(i)
    local item_id = item:search("xinfa_card").excel_id
    if item_id ~= 0 and item_id == id then
      item:search("xf_level").text = L("Lv.") .. xinfa_info.level
    end
  end
end
function update_mas_pts_limit()
  local lmt = ui.get_mas_pts_limit()
  w_skill_master:search("master_points_limit"):search("limit").text = lmt
end
function update_xinfa_master(id)
  local xinfa_info = ui.xinfa_find(id)
  local mas_level = xinfa_info.mas_level
  for i = 0, w_zhuzhi_xinfa_list.item_count - 1 do
    local item = w_zhuzhi_xinfa_list:item_get(i)
    local item_id = item:search("xinfa_card").excel_id
    if item_id ~= 0 and item_id == id then
      item:search("mas_level").text = mas_level
      local lb_color = color_dark_yellow
      if mas_level == 0 then
        lb_color = color_white
      end
      item:search("mas_level").color = lb_color
      show_xinfa_skills(id)
    end
  end
end
function new_xinfa(id)
  local xinfa_info = ui.xinfa_find(id)
  if xinfa_info == nil then
    ui.log("xinfa_info == nil")
    return
  end
  local excel = bo2.gv_xinfa_list:find(id)
  if excel == nil then
    ui.log("xinfa_excel == nil")
    return
  end
  local type_id = excel.type_id
  if type_id ~= bo2.eXinFaType_Currency and type_id ~= bo2.eXinFaType_Expert then
    return
  end
  local mas_lv = xinfa_info.mas_level
  local xf_lv = xinfa_info.level
  local child_item_uri = L("$frame/skill/skill_master.xml")
  local child_item_style = L("master_xinfa_item")
  local child_item = w_zhuzhi_xinfa_list:item_append()
  child_item:load_style(child_item_uri, child_item_style)
  child_item:search("xinfa_card").excel_id = id
  child_item:search("name").text = excel.name
  child_item:search("mas_level").text = mas_lv
  child_item:search("xf_level").text = "Lv." .. xf_lv
  local lb_color = color_dark_yellow
  if mas_lv == 0 then
    lb_color = color_white
  end
  child_item:search("mas_level").color = lb_color
end
function remove_xinfa(id)
  for i = 0, w_zhuzhi_xinfa_list.item_count - 1 do
    local item = w_zhuzhi_xinfa_list:item_get(i)
    if item == nil then
      return
    end
    local item_id = item:search("xinfa_card").excel_id
    if item_id ~= 0 and item_id == id then
      item:self_remove()
    end
  end
end
function new_skill(id)
  if bo2.is_master_passive_skill(id) == false then
    return
  end
  local item_sel = w_zhuzhi_xinfa_list.item_sel
  if item_sel == nil then
    return
  end
  local xinfa_id = item_sel:search("xinfa_card").excel_id
  show_xinfa_skills(xinfa_id)
end
function on_master_points_change()
  local player = bo2.player
  if player == nil then
    return
  end
  local master_points = player:get_flag_int32(bo2.ePlayerFlagInt32_XinfaMasterPoints)
  local mas_pts_total = ui.get_mas_pts_total()
  w_skill_master:search("master_points"):search("mas_pts").text = master_points .. L("/") .. mas_pts_total
  on_mas_exp_change()
end
function on_mas_exp_change()
  local player = bo2.player
  if player == nil then
    return
  end
  local mas_exp = player:get_flag_int32(bo2.ePlayerFlagInt32_MasExp)
  local mas_pts_total = ui.get_mas_pts_total()
  local mas_exp_req = bo2.XINFA_MASTER_THRESHOLD + mas_pts_total * bo2.XINFA_MASTER_GAP
  local mas_exp_bar = w_skill_master:search("mas_exp"):search("mas_exp_bar")
  local total_dx = mas_exp_bar:search("pic").dx
  mas_exp_bar.dx = total_dx * mas_exp / mas_exp_req
  w_skill_master:search("mas_exp"):search("lb_mas_exp").text = mas_exp .. L("/") .. mas_exp_req
end
function on_item_count(card, excel_id, bag, all)
  if w_btn_break == nil then
    return
  end
  w_btn_break.enable = false
  local cnt = ui.item_get_count(excel_id, true)
  if cnt < 1 then
    return
  end
  w_btn_break.enable = true
end
function on_player_info_init(obj)
  if obj == bo2.player then
    obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_XinfaMasterPoints, on_master_points_change, "ui_skill_master.on_master_points_change")
    obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_MasExp, on_mas_exp_change, "ui_skill_master.on_mas_exp_change")
  end
end
ui.insert_on_update_xinfa_master(update_xinfa_master, "ui_skill_master.update_xinfa_master")
ui.insert_on_new_xinfa(new_xinfa, "ui_skill_master.new_xinfa")
ui.insert_on_remove_xinfa(remove_xinfa, "ui_skill_master.remove_xinfa")
ui.insert_on_new_skill(new_skill, "ui_skill_master.new_skill")
ui.insert_skill(new_skill, "ui_skill_master.update_skill")
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_player_info_init, "ui_skill_master.packet_handle")
