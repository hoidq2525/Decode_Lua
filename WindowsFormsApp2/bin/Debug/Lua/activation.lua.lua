function on_level_update(v)
  local p_lv = ui.safe_get_atb(bo2.eAtb_Level)
  if p_lv == ui_widget.get_define_int(1131) then
    gx_window.visible = true
  end
end
function on_visible(w, vis)
  if vis then
    local level = ui.safe_get_atb(bo2.eAtb_Level)
    if level < ui_widget.get_define_int(1131) then
      gx_window.visible = false
      return
    end
    ui_widget.esc_stk_push(w)
    update_list_all()
    local item = w_list_view.item_sel
    if item == nil then
      local item = w_list_view:item_get(0)
      item.selected = true
      item:scroll_to_visible()
    end
  else
    ui_widget.esc_stk_pop(w)
  end
end
function on_init()
  insert_list()
end
function set_visible()
  gx_window.visible = not gx_window.visible
end
function update_item_highlight(item)
  if item == nil then
    return
  end
  local hover = item:search("hover")
  if hover == nil then
    return
  end
  if item.inner_hover then
    if not item.selected then
      hover.visible = true
    else
      hover.visible = false
    end
  else
    hover.visible = false
  end
end
function on_item_mouse(item, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    return
  end
  update_item_highlight(item)
end
function on_item_sel(item, vis)
  local h = item:search("select")
  if h ~= nil then
    h.visible = vis
  end
  local excel = item.svar.excel
  local name = w_item_info:search("name")
  name.text = excel.desc
  local detail = w_item_info:search("detail")
  detail.mtf = excel.details
  local slider = detail:search("sld")
  if vis then
    slider.scroll = 0
  end
  if excel.award.size == 0 and excel.shortcut_info ~= L("pve_5") then
    local award_panel = w_item_info:search("award_panel")
    award_panel.visible = false
    w_drop_tree.visible = false
    w_drop_list.visible = false
  else
    local award_panel = w_item_info:search("award_panel")
    award_panel.visible = false
    local v = sys.variant()
    local cur_times = item:search("cur_times")
    v:set("cur", cur_times.text)
    v:set("total", excel.times)
    local award_title = w_item_info:search("award_title")
    award_title.mtf = sys.mtf_merge(v, ui.get_text("activation|award_title"))
    local card = w_item_info:search("card")
    card.excel_id = excel.award[0]
    local count = w_item_info:search("count")
    count.text = excel.award[1]
    if excel.shortcut_info == L("pve_5") then
      w_drop_tree.visible = false
      w_drop_list.visible = true
      w_item_info:search("award_panel").dy = 105
    else
      w_drop_tree.visible = true
      w_drop_list.visible = false
      w_drop_tree.root:item_clear()
      local drop_toggle = ui_widget.ui_tree2.insert(w_drop_tree.root, 1)
      drop_toggle.title:search("lb_text").mtf = ui.get_text("activation|award_title")
      local dy = 40
      if excel.award.size ~= excel.award_num.size then
        return
      end
      for i = 0, excel.award.size - 1 do
        local card_idx = i % 5
        local drop_leaf
        if card_idx == 0 then
          drop_leaf = ui_widget.ui_tree2.insert(drop_toggle)
          dy = dy + 42
        else
          drop_leaf = drop_toggle:item_get(drop_toggle.item_count - 1)
        end
        local card = drop_leaf.title:search(L("card") .. card_idx)
        card.excel_id = excel.award[i]
        card:search("count").text = excel.award_num[i]
      end
      w_drop_tree.parent.dy = dy
    end
  end
end
function on_see_drop_list(btn)
  ui_boss_list.w_major_panel.visible = true
  local root = ui_boss_list.w_boss_tree.root
  for i = 0, root.item_count - 1 do
    local item = root:item_get(i)
    item.expanded = false
  end
  local sel_item
  for i = 0, root.item_count - 1 do
    local item = root:item_get(i)
    local level = ui.safe_get_atb(bo2.eAtb_Level)
    local scn_id = item.svar.scn_list_line.id
    if level < 33 then
      if scn_id == 6 then
        sel_item = item
        break
      end
    elseif level < 35 then
      if scn_id == 202 then
        sel_item = item
        break
      end
    elseif level < 43 then
      if scn_id == 220 then
        sel_item = item
        break
      end
    elseif level < 45 then
      if scn_id == 204 then
        sel_item = item
        break
      end
    elseif level < 53 then
      if scn_id == 219 then
        sel_item = item
        break
      end
    elseif level < 55 then
      if scn_id == 210 then
        sel_item = item
        break
      end
    elseif level < 60 then
      if scn_id == 218 then
        sel_item = item
        break
      end
    elseif level < 63 then
      if scn_id == 511 then
        sel_item = item
        break
      end
    elseif level < 65 then
      if scn_id == 222 then
        sel_item = item
        break
      end
    elseif scn_id == 223 then
      sel_item = item
      break
    end
  end
  if sel_item == nil then
    return
  end
  sel_item.expanded = true
  local leaf = sel_item:item_get(0)
  leaf.selected = true
  leaf:scroll_to_visible()
end
function on_card_mouse(card, msg, pos, wheel)
  if (msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_drag) and ui.is_key_down(ui.VK_CONTROL) then
    ui_chat.insert_item(card.excel_id)
    return
  end
end
function check_enable(item)
  local excel = item.svar.excel
  local level = bo2.player:get_atb(bo2.eAtb_Level)
  if excel.min_level ~= 0 and level < excel.min_level then
    return false
  end
  local name = excel.shortcut_info
  if name == L("wish") then
    local level = bo2.player:get_atb(bo2.eAtb_Level)
    if level >= 5 then
      return true
    else
      return false
    end
  elseif name == L("pve_5") or name == L("pve_2") or name == L("pve_moyu") then
    local level = bo2.player:get_atb(bo2.eAtb_Level)
    if level >= 15 then
      return true
    else
      return false
    end
  elseif name == L("pve_knight") then
    local level = bo2.player:get_atb(bo2.eAtb_Level)
    if level >= 15 then
      return true
    else
      return false
    end
  elseif name == L("pve_cb") then
    return ui.quest_find_c(2031)
  elseif name == L("pve_v0") then
    local level = bo2.player:get_atb(bo2.eAtb_Level)
    if level >= 49 then
      return true
    else
      return false
    end
  elseif name == L("pve_ruqin") then
    local level = bo2.player:get_atb(bo2.eAtb_Level)
    if level >= 40 then
      return true
    else
      return false
    end
  elseif name == L("pvp_battle") then
    local level = bo2.player:get_atb(bo2.eAtb_Level)
    if level >= 20 then
      return true
    else
      return false
    end
  elseif name == L("pvp_3v3") then
    return true
  elseif name == L("pvp_ruqin") then
    return ui_net_delay.btn_cross_line.visible
  elseif name == L("pvp_2v2") then
    local level = bo2.player:get_atb(bo2.eAtb_Level)
    if level >= 30 then
      return true
    else
      return false
    end
  elseif name == L("pvp_1v1") then
    return true
  elseif name == L("con_action") or name == L("con_battle") or name == L("con_knight_and_cb") then
    local level = bo2.player:get_atb(bo2.eAtb_Level)
    if level >= 20 then
      return true
    else
      return false
    end
  elseif name == L("con_enchant") then
    return ui_personal.ui_equip.milestone_complete(40019)
  elseif name == L("other_gquest") then
    if bo2.is_in_guild() == sys.wstring(0) then
      return false
    else
      return true
    end
  else
    return true
  end
end
function open_window(name)
  if name == L("wish") then
    ui_wish.set_visible()
  elseif name == L("pve_5") then
    ui_dungeonui.ui_dungeonsel.set_visible()
    ui_widget.ui_tab.show_page(ui_dungeonui.ui_dungeonsel.g_sel_main, 2, true)
    ui_dungeonui.ui_dungeonsel.update_on_visible(2)
  elseif name == L("pve_2") then
    ui_dungeonui.ui_dungeonsel.set_visible()
    ui_widget.ui_tab.show_page(ui_dungeonui.ui_dungeonsel.g_sel_main, 1, true)
    ui_dungeonui.ui_dungeonsel.update_on_visible(1)
  elseif name == L("pve_moyu") then
    ui_dungeonui.ui_dungeonsel.set_visible()
    ui_widget.ui_tab.show_page(ui_dungeonui.ui_dungeonsel.g_sel_main, 3, true)
    ui_dungeonui.ui_dungeonsel.update_on_visible(3)
  elseif name == L("pve_knight") then
    ui_net_delay.on_show_renown(ui_net_delay.w_renown_btn)
  elseif name == L("pve_cb") then
    ui_cloned_battle.w_main.visible = true
  elseif name == L("pvp_battle") then
    ui_campaign.w_main.visible = true
  elseif name == L("pvp_3v3") then
    ui_campaign.w_main.visible = true
    local page = ui_widget.ui_tab.get_show_page(ui_campaign.w_core)
    local list = page:search("campaign_listview")
    local cnt = list.item_count
    for i = 0, cnt - 1 do
      local item = list:item_get(i)
      local v = item.var:get("campaign_data")
      local img_uri = v:get(packet.key.campaign_eventimguri).v_string
      if img_uri == L("campaign_yiwuhuiyou") then
        item.selected = true
        item:scroll_to_visible()
        break
      end
    end
  elseif name == L("pve_ruqin") then
    ui_campaign.w_main.visible = true
    local page = ui_widget.ui_tab.get_show_page(ui_campaign.w_core)
    local list = page:search("campaign_listview")
    local cnt = list.item_count
    for i = 0, cnt - 1 do
      local item = list:item_get(i)
      local v = item.var:get("campaign_data")
      local img_uri = v:get(packet.key.campaign_eventimguri).v_string
      if img_uri == L("campaign_luoshenhu") then
        item.selected = true
        item:scroll_to_visible()
        break
      end
    end
  elseif name == L("pve_v0") then
    ui_dungeonui.ui_dungeonsel.set_visible()
    ui_widget.ui_tab.show_page(ui_dungeonui.ui_dungeonsel.g_sel_main, 1, true)
    do
      local page = ui_widget.ui_tab.get_show_page(ui_dungeonui.ui_dungeonsel.g_sel_main)
      local root = page:search("sel_tree").root
      local function on_v0_level_sel(item)
        page:search("sel_tree"):clear_selection()
        item.selected = true
        local item_0 = item:item_get(0)
        item_0:scroll_to_visible()
        ui_dungeonui.ui_dungeonsel.on_item_sel(item, true)
        ui_dungeonui.ui_dungeonsel.on_item_expanded(item, true)
      end
      for i = 0, root.item_count - 1 do
        local item = root:item_get(i)
        local level = bo2.player:get_atb(bo2.eAtb_Level)
        if level >= 49 and level < 57 then
          if item.obtain_title.svar.scnid == 48 then
            on_v0_level_sel(item)
            break
          end
        elseif level >= 57 and level < 64 then
          if item.obtain_title.svar.scnid == 886 then
            on_v0_level_sel(item)
            break
          end
        elseif level >= 64 and item.obtain_title.svar.scnid == 877 then
          on_v0_level_sel(item)
          break
        end
      end
    end
  elseif name == L("pvp_ruqin") then
    ui_camp_repute.w_main.visible = true
  elseif name == L("pvp_2v2") then
    ui_fate.w_main.visible = true
    ui_fate.w_main.top_level = true
    ui_fate.w_main:move_to_head()
  elseif name == L("pvp_1v1") then
    ui_champion.w_main.visible = true
  elseif name == L("con_enchant") then
    ui_personal.w_personal.visible = true
    local btn = ui_personal.ui_equip.w_equip:search("btn_slot_enhance")
    if not btn.enable then
      return
    end
    ui_personal.ui_equip.on_btn_slot_enhance()
  elseif name == L("con_action") or name == L("con_battle") or name == L("con_knight_and_cb") then
    ui_action.w_exchange.visible = true
  else
    if name == L("other_gquest") then
      if ui.npc_guild_mb_id() ~= 0 then
        local w = ui_npc_guild_mod.ui_npc_guild.w_win
        w.visible = true
        ui_widget.ui_tab.show_page(w, "personal_info_main", true)
      else
        local w = ui_guild_mod.ui_guild.w_win
        w.visible = true
        ui_widget.ui_tab.show_page(w, "personal_info_main", true)
      end
    else
    end
  end
end
function find_way(name)
  if name == L("pve_knights") then
    ui_map.find_path_byid(651)
  end
end
function on_panel_mouse(ctrl, msg)
  local panel = ctrl.parent
  local card = panel:search("card")
  local excel = card.excel
  local stk = sys.mtf_stack()
  if excel ~= nil then
    ui_tool.ctip_make_item(stk, excel, card.info, card)
  end
  local stk_use
  local info = card.info
  if card.box == bo2.eItemBox_OtherSlot then
    stk_use = ui_item.tip_get_using_equip(excel)
  else
  end
  local tip_text = L("")
  local score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Activation)
  local btn = panel:search("btn")
  local need_score = btn.svar.excel.score
  if score < need_score then
    local dif = need_score - score
    local v = sys.variant()
    v:set("num", dif)
    tip_text = sys.mtf_merge(v, ui.get_text("activation|not_enough_score"))
  elseif btn.enable then
    tip_text = ui.get_text("activation|enable_get_award")
  else
    tip_text = ui.get_text("activation|already_got")
  end
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, tip_text, ui_tool.cs_tip_color_operation)
  if msg == ui.mouse_enter or msg == ui.mouse_inner then
    ui_tool.ctip_show(card, stk)
  elseif msg == ui.mouse_leave or msg == ui.mouse_outer then
    ui_tool.ctip_show(card, nil)
  end
end
function on_btn_click(btn)
  local item = btn.parent
  local excel = item.svar.excel
  if excel.shortcut_type == 1 then
    open_window(excel.shortcut_info)
  elseif excel.shortcut_type == 2 then
    find_way(excel.shortcut_info)
  elseif excel.shortcut_type == 3 then
    open_window(excel.shortcut_info)
  end
end
function update_list_all()
  for i = 0, bo2.gv_activation_list.size - 1 do
    local excel = bo2.gv_activation_list:get(i)
    update_list(excel.id)
  end
  update_activation_score()
end
function update_item_color(item, c)
  local desc = item:search("desc")
  local score = item:search("score")
  local cur_times = item:search("cur_times")
  local times = item:search("times")
  local color = ui.make_color(c)
  desc.color = color
  score.color = color
  cur_times.color = color
  times.color = color
end
function update_activation_score()
  local today_act = w_act_info:search("today_act")
  local next_level = w_act_info:search("next_level")
  local v = sys.variant()
  local today_num = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Activation)
  v:set("today_num", today_num)
  today_act.text = sys.mtf_merge(v, ui.get_text("activation|today_act"))
  local progress = w_progress_info:search("progress")
  progress.dx = today_num * 3
  for i = 0, 3 do
    local gift_panel = w_progress_info:search("gift" .. i)
    if gift_panel ~= nil then
      local btn = gift_panel:search("btn")
      btn.enable = false
      btn.visible = true
      local btn_open = gift_panel:search("btn_open")
      btn_open.visible = false
      local flicker = gift_panel:search("flicker")
      flicker.visible = false
      flicker.suspended = true
    end
  end
  for i = 0, bo2.gv_activation_award_list.size - 1 do
    local excel = bo2.gv_activation_award_list:get(i)
    if today_num < excel.score then
      v:set("num", excel.score - today_num)
      next_level.text = sys.mtf_merge(v, ui.get_text("activation|next_level"))
      return
    else
      local gift_panel = w_progress_info:search("gift" .. i)
      if gift_panel ~= nil then
        local btn = gift_panel:search("btn")
        local flicker = gift_panel:search("flicker")
        local btn_open = gift_panel:search("btn_open")
        local flag = bo2.player:get_flag_int8(bo2.ePlayerFlag8_Activation_Score_Award)
        local pow = math.pow(2, i)
        local t1 = math.floor(flag / pow)
        local t2 = t1 % 2
        if t2 == 1 then
          btn.enable = false
          btn.visible = false
          btn_open.visible = true
          flicker.visible = false
          flicker.suspended = true
        elseif t2 == 0 then
          btn.enable = true
          btn.visible = true
          btn_open.visible = false
          flicker.visible = true
          flicker.suspended = false
        end
      end
    end
  end
  next_level.text = ui.get_text("activation|today_over")
end
function get_right_item(id)
  local item
  for i = 0, w_list_view.item_count - 1 do
    item = w_list_view:item_get(i)
    if item.svar.excel.id == id then
      return item
    end
  end
  return nil
end
function update_list(id)
  local item = get_right_item(id)
  if item == nil then
    return
  end
  local cur_times = item:search("cur_times")
  local times = bo2.player:get_flag_int8(bo2.ePlayerFlag8_ActivationTimesBegin + id - 1)
  cur_times.text = times
  local btn = item:search("btn")
  btn.enable = check_enable(item)
  if btn.enable then
    update_item_color(item, "FFFFFF")
  else
    update_item_color(item, "888888")
  end
  local excel = item.svar.excel
  local total_times = excel.times
  if times >= total_times then
    update_item_color(item, "00AA00")
  end
  if item.selected then
    on_item_sel(item, true)
  end
end
function insert_list()
  w_list_view:item_clear()
  for i = 0, bo2.gv_activation_list.size - 1 do
    local item_file = "$frame/activation/activation.xml"
    local item_style = "act_item"
    local excel = bo2.gv_activation_list:get(i)
    if excel.disable ~= 1 then
      local item = w_list_view:item_append()
      item:load_style(item_file, item_style)
      local desc = item:search("desc")
      local score = item:search("score")
      local total_times = item:search("times")
      local cur_times = item:search("cur_times")
      update_item_color(item, "FFFFFF")
      cur_times.text = 0
      local btn = item:search("btn")
      desc.text = excel.desc
      score.text = "+" .. excel.score .. ui.get_text("activation|acteachtime")
      total_times.text = "/" .. excel.times
      if excel.shortcut_type ~= 0 then
        btn.text = ui.get_text("activation|btntype" .. excel.shortcut_type)
        btn.visible = true
      else
        btn.text = L("")
        btn.visible = false
      end
      item.svar.excel = excel
    end
  end
  local v = sys.variant()
  local today_act = w_act_info:search("today_act")
  v:set("today_num", 0)
  today_act.text = sys.mtf_merge(v, ui.get_text("activation|today_act"))
  local next_level = w_act_info:search("next_level")
  v:set("num", 0)
  next_level.text = sys.mtf_merge(v, ui.get_text("activation|next_level"))
  w_progress_info:search("progress").dx = 0
  for i = 0, 3 do
    local panel = w_progress_info:search("gift" .. i)
    local btn = panel:search("btn")
    local lbl = panel:search("lbl")
    local card = panel:search("card")
    local e = bo2.gv_activation_award_list:get(i)
    btn.enable = false
    btn.svar.idx = i
    btn.svar.excel = e
    lbl.text = e.score .. ui.get_text("activation|activation_tip")
    card.excel_id = e.gift
    panel.margin = ui.rect(e.score * 3 - 12, 0, 0, 0)
  end
end
function on_get_single_award(btn)
end
function on_get_score_award(btn)
  local idx = btn.svar.idx
  local v = sys.variant()
  v:set(packet.key.cmn_index, idx)
  v:set(packet.key.cmn_id, 2)
  bo2.send_variant(packet.eCTS_UI_Activation_Get_Single_Award, v)
end
function on_add_act_point(cmd, data)
  if not gx_window.visible then
    return
  end
  local id = data:get(packet.key.cmn_id).v_int
  update_list(id)
  update_activation_score()
end
function on_reset_activation(cmd, data)
  if not gx_window.visible then
    return
  end
  update_list_all()
end
function on_self_enter()
end
function on_login(cmd, data)
  local window_type = data:get(packet.key.ui_window_type).v_string
  if window_type ~= L("activation") then
    return
  end
  local level = ui.safe_get_atb(bo2.eAtb_Level)
  if level < ui_widget.get_define_int(1131) then
    return
  end
  gx_window.visible = true
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_activation.packet_handle"
reg(packet.eSTC_UI_AddActPoint, on_add_act_point, sig)
reg(packet.eSTC_UI_ResetActPoint, on_reset_activation, sig)
reg(packet.eSTC_UI_OpenWindow, on_login, sig)
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_activation.on_self_enter")
