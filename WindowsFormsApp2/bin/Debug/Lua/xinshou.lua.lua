local cs_campaign_item_opaque = SHARED("$image/campaign/frame.png|5,157,700,76")
local cs_campaign_item_transp = SHARED("$image/campaign/frame.png|5,82,700,76")
local path_exp_award = SHARED("$mb/award/exp_award/exp_award.xml")
local path_exp = SHARED("$mb/award/exp_award/")
local path_money_award = SHARED("$mb/award/money_award/money_award.xml")
local path_money = SHARED("$mb/award/money_award/")
local DIS = 70
local TEXT_NOT_ENOUGH_SCORE = ui.get_text("xinshou|not_enough_score")
local TEXT_GET_BEFORE_AWARD = ui.get_text("xinshou|get_before_award")
local TEXT_HAS_GOT_AWARD = ui.get_text("xinshou|has_got_award")
local TEXT_CLICK_TO_GET = ui.get_text("xinshou|click_to_get_award")
local t_show_score = ui.get_text("xinshou|t_show_score")
local g_first_xuezhan = false
local g_first_time = false
local g_first_time_get_score = false
local g_login = false
function on_init()
  g_login = true
  for i = 0, bo2.gv_xinshou_campaign.size - 1 do
    local excel = bo2.gv_xinshou_campaign:get(i)
    insert_xinshou_campaign(excel, i + 1)
  end
  for i = 0, bo2.gv_xinshou_score.size - 1 do
    local excel = bo2.gv_xinshou_score:get(i)
    local gift_panel = w_score_main_panel:search("gift" .. excel.id)
    gift_panel.svar.id = excel.id
    gift_panel.svar.score = excel.score
    gift_panel:search("count").text = excel.score
    gift_panel:search("card").excel_id = excel.gift
  end
end
function on_btn_get_award(btn)
  local panel = btn.parent.parent
  local score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouScore)
  local index = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouIndex)
  if score < panel.svar.score then
    ui_tool.note_insert(TEXT_NOT_ENOUGH_SCORE, L("FF00FF00"))
  elseif panel.svar.id > index + 1 then
    ui_tool.note_insert(TEXT_GET_BEFORE_AWARD, L("FF00FF00"))
  elseif panel.svar.id == index + 1 then
    local v = sys.variant()
    v:set(packet.key.cmn_id, index)
    bo2.send_variant(packet.eCTS_UI_GetXinshouScoreGift, v)
  elseif panel.svar.id < index + 1 then
    ui_tool.note_insert(TEXT_HAS_GOT_AWARD, L("FF00FF00"))
  end
end
function on_panel_mouse(btn, msg)
  local panel = btn.parent
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
  local score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouScore)
  local index = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouIndex)
  if score < panel.svar.score then
    tip_text = TEXT_NOT_ENOUGH_SCORE
  elseif panel.svar.id > index + 1 then
    tip_text = TEXT_GET_BEFORE_AWARD
  elseif panel.svar.id == index + 1 then
    tip_text = TEXT_CLICK_TO_GET
  elseif panel.svar.id < index + 1 then
    tip_text = TEXT_HAS_GOT_AWARD
  end
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, tip_text, ui_tool.cs_tip_color_operation)
  if msg == ui.mouse_enter or msg == ui.mouse_inner then
    ui_tool.ctip_show(card, stk)
  elseif msg == ui.mouse_leave or msg == ui.mouse_outer then
    ui_tool.ctip_show(card, nil)
  end
end
function on_make_tip(tip)
end
function cal_btn_state()
  local index = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouIndex)
  local score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouScore)
  for i = 0, bo2.gv_xinshou_score.size - 1 do
    local excel = bo2.gv_xinshou_score:get(i)
    if excel == nil then
      return
    end
    local panel = w_score_main_panel:search("gift" .. excel.id)
    local label = panel:search("count")
    local btn = panel:search("btn")
    local pic = panel:search("pic")
    local flicker = panel:search("flicker")
    if panel.svar.id < index + 1 then
      label.visible = false
      btn.visible = false
      pic.visible = true
    elseif panel.svar.id == index + 1 and score >= panel.svar.score then
      label.visible = true
      btn.visible = true
      btn.enable = true
      pic.visible = false
    else
      label.visible = true
      btn.visible = true
      btn.enable = false
      pic.visible = false
    end
  end
end
function cal_flicker()
  for i = 0, bo2.gv_xinshou_score.size - 1 do
    local n = bo2.gv_xinshou_score:get(i)
    local item = w_score_main_panel:search("gift" .. n.id)
    if item == nil then
      return
    end
    item:search("flicker").visible = false
    item:search("flicker").suspended = true
  end
  local score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouScore)
  local index = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouIndex)
  local excel = bo2.gv_xinshou_score:find(index + 1)
  if excel == nil then
    return
  end
  if score >= excel.score then
    local item = w_score_main_panel:search("gift" .. excel.id)
    local flicker = item:search("flicker")
    flicker.visible = true
    flicker.suspended = false
  else
    local item = w_score_main_panel:search("gift" .. excel.id)
    local flicker = item:search("flicker")
    flicker.visible = false
    flicker.suspended = true
  end
end
function cal_position()
  local score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouScore)
  local size = bo2.gv_xinshou_score.size
  local last_excel = bo2.gv_xinshou_score:get(size - 1)
  local first_excel = bo2.gv_xinshou_score:get(0)
  if score >= last_excel.score then
    local last_panel = w_score_main_panel:search("gift" .. last_excel.id)
    w_score_progress.dx = last_panel.x + 0.5 * last_panel.dx
  elseif score < first_excel.score then
    local next_panel = w_score_main_panel:search("gift1")
    local dif_score = score
    w_score_progress.dx = dif_score * DIS / first_excel.score
  else
    for i = 1, size - 1 do
      local excel = bo2.gv_xinshou_score:get(i)
      if score < excel.score then
        local before_excel = bo2.gv_xinshou_score:get(i - 1)
        local before_panel = w_score_main_panel:search("gift" .. before_excel.id)
        local dif_score = score - before_excel.score
        local zone_score = excel.score - before_excel.score
        local panel = w_score_main_panel:search("gift" .. excel.id)
        if panel ~= nil and before_panel ~= nil then
          local before_panel_start_x = before_panel.x + 0.5 * before_panel.dx
          w_score_progress.dx = before_panel_start_x + dif_score * DIS / zone_score
        end
        return
      end
    end
  end
end
function enable_xinshou_button_flick(visible)
  if sys.check(w_new_gift_flicker) then
    w_new_gift_flicker.suspended = not visible
    w_new_gift_flicker.visible = visible
  end
end
function on_visible(w, vis)
  ui_widget.on_border_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  ui_main.w_top:apply_dock(true)
  if vis then
    w:move_to_head()
    local size = bo2.gv_xinshou_score.size
    local excel = bo2.gv_xinshou_score:get(size - 1)
    local score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouScore)
    w_cur_score.text = score .. "/" .. excel.score
    cal_position()
    cal_btn_state()
    cal_flicker()
    enable_xinshou_button_flick(false)
    if g_first_time then
      local item
      for i = 0, w_list_view.item_count - 1 do
        local t_item = w_list_view:item_get(i)
        local excel_id = t_item.svar.id
        local excel = bo2.gv_xinshou_campaign:find(excel_id)
        if excel ~= nil and excel.serverid == 77 then
          item = t_item
          break
        end
      end
      if item == nil then
        return
      end
      local btn = item:search("btn_quickjoinin")
      local pos = btn:control_to_window(ui.point(0, 0))
      local w_btn_quick = ui_tool.ui_xinshou_animation.w_btn_quick
      local w_btn_arrow = ui_tool.ui_xinshou_animation.w_btn_arrow
      w_btn_quick.visible = true
      w_btn_quick.margin = ui.rect(pos.x, pos.y, 0, 0)
      w_btn_arrow.visible = true
      w_btn_arrow.margin = ui.rect(pos.x - 120, pos.y, 0, 15)
      w_btn_arrow:search("anim"):reset()
      g_first_time = false
    elseif g_first_xuezhan then
      local item = w_list_view:item_get(1)
      if item == nil then
        return
      end
      local btn = item:search("btn_quickjoinin")
      local pos = btn:control_to_window(ui.point(0, 0))
      local w_btn_quick = ui_tool.ui_xinshou_animation_xz.w_btn_quick
      local w_btn_arrow = ui_tool.ui_xinshou_animation_xz.w_btn_arrow
      w_btn_quick.visible = true
      w_btn_quick.margin = ui.rect(pos.x, pos.y, 0, 0)
      w_btn_arrow.visible = true
      w_btn_arrow.margin = ui.rect(pos.x - 120, pos.y, 0, 15)
      w_btn_arrow:search("anim"):reset()
      g_first_xuezhan = false
    end
    for i = 0, 2 do
      local item = w_list_view:item_get(i)
      if item ~= nil then
        local btn = item:search("btn_quickjoinin")
        local cpn_state = item:search("campaign_state")
        local item_mask = item:search("item_mask")
        local excel_id = item.svar.id
        local excel = bo2.gv_xinshou_campaign:find(excel_id)
        if excel.serverid == 79 then
          local level = bo2.player:get_atb(bo2.eAtb_Level)
          if level < 20 then
            btn.visible = false
            cpn_state.text = ui.get_text("xinshou|level_20_open")
            cpn_state.visible = true
            item_mask.visible = true
          else
            btn.visible = true
            cpn_state.text = L("")
            cpn_state.visible = false
            item_mask.visible = false
          end
        elseif excel.serverid == 78 then
          btn.visible = false
          cpn_state.text = ui.get_text("xinshou|not_open_now")
          cpn_state.visible = true
          item_mask.visible = true
        else
          btn.visible = true
          cpn_state.text = L("")
          cpn_state.visible = false
          item_mask.visible = false
          local first_flag = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_FirstCampaign)
          if first_flag == 0 and not ui_tool.ui_xinshou_animation.w_btn_quick.visible then
            btn:search("visible_hl").visible = true
          else
            btn:search("visible_hl").visible = false
          end
        end
      end
    end
    ui_handson_teach.on_test_visible_set_proprity(w)
  else
    ui_xinshou_desc.w_xinshou_desc.visible = false
    w.priority = 110
  end
end
function on_close_click(btn)
  ui_widget.on_close_click(btn)
end
function set_visible()
  w_main.visible = not w_main.visible
end
function show_xinshou_arrow()
end
function insert_xinshou_campaign(excel, idx)
  local item = w_list_view:item_append()
  item.svar.id = excel.id
  local file_name = "$gui/frame/xinshou/xinshou.xml"
  local style_name = "item"
  item:load_style(file_name, style_name)
  if idx % 2 == 0 then
    item:search("item_bg").image = cs_campaign_item_transp
  else
    item:search("item_bg").image = cs_campaign_item_opaque
  end
  local img_uri = excel.img_uri
  item:search("xinshou_pic").image = L("$image/campaign/img/") .. img_uri .. L(".png")
  local show_score = item:search("xinshou_show_score")
  show_score.text = t_show_score .. excel.score_show
  local c_name = item:search("xinshou_name")
  c_name.text = excel.name
  local c_brief = item:search("xinshou_brief")
  c_brief.text = excel.brief
end
function update_item_highlight(item)
  if item == nil then
    return
  end
  local h = item:search("highlight")
  if h == nil then
    return
  end
  local hover = item:search("item_hover")
  if hover == nil then
    return
  end
  if item.selected then
    h.visible = true
  else
    h.visible = false
  end
  if item.inner_hover then
    if item.selected == false then
      hover.visible = true
    else
      hover.visible = false
    end
  else
    hover.visible = false
  end
end
function on_update_item_buttons(item, vis)
end
function update_item_buttons(item)
  if item == nil then
    return
  end
  if item.inner_hover or item.selected then
  else
  end
end
function on_xinshou_item_mouse(item, msg)
  if item:search("item_mask").visible then
    return
  end
  update_item_highlight(item)
  update_item_buttons(item)
  if msg == ui.mouse_lbutton_down then
    item:select(true)
  end
end
function dock_offset_reset()
  ui_xinshou_desc.w_xinshou_desc.x = w_main.x + w_main.dx - 14
  ui_xinshou_desc.w_xinshou_desc.y = w_main.y + 20
  ui_xinshou_desc.w_xinshou_desc.visible = true
end
function on_xinshou_item_sel(item, sel)
  if item:search("item_mask").visible then
    return
  end
  update_item_highlight(item)
  update_item_buttons(item)
  local p_reward = ui_xinshou_desc.w_xinshou_desc:search("desc_reward")
  if not sel then
    ui_xinshou_desc.w_xinshou_desc.visible = false
    p_reward:control_clear()
    return
  end
  if not w_main.visible then
    return
  end
  dock_offset_reset()
  ui_xinshou_desc.w_xinshou_desc_listview:item_clear()
  local id = item.svar.id
  local excel = bo2.gv_xinshou_campaign:find(id)
  if excel == nil then
    return
  end
  ui_xinshou_desc.w_xinshou_desc_listview.mtf = excel.desc
  ui_xinshou_desc.w_xinshou_desc_listview.slider_y.scroll = 0
  ui_xinshou_desc.w_xinshou_name.text = excel.name
  local money_star = excel.money_star
  local exp_star = excel.exp_star
  local score_star = excel.score_star
  local y_extent = 0
  if money_star ~= 0 then
    local p_temp = ui_campaign.create_reward_c(p_reward, ui.get_text("xinshou|money"), money_star)
    y_extent = y_extent + p_temp.dy
  end
  if exp_star ~= 0 then
    local p_temp = ui_campaign.create_reward_c(p_reward, ui.get_text("xinshou|exp"), exp_star)
    y_extent = y_extent + p_temp.dy
  end
  if score_star ~= 0 then
    local p_temp = ui_campaign.create_reward_c(p_reward, ui.get_text("xinshou|score"), score_star)
    y_extent = y_extent + p_temp.dy
  end
  p_reward.dy = y_extent
end
function on_move()
end
function OnPathClick()
  local item_sel = w_list_view.item_sel
  if item_sel == nil then
    return
  end
  local id = item_sel.svar.id
  local excel = bo2.gv_xinshou_campaign:find(id)
  if excel == nil then
    return
  end
  ui_map.find_path_byid(excel.mark_id)
end
function on_item_path_btn_click(btn)
  local item_sel = btn.parent.parent
  local id = item_sel.svar
  local excel = bo2.gv_xinshou_campaign:find(id)
  if excel == nil then
    return
  end
  ui_map.find_path_byid(excel.mark_id)
end
function on_item_quick_btn_mouse(btn, msg)
  update_item_buttons(btn.parent.parent)
end
function on_score_update(cmd, data)
  if w_main.visible then
    local size = bo2.gv_xinshou_score.size
    local excel = bo2.gv_xinshou_score:get(size - 1)
    local score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouScore)
    w_cur_score.text = score .. "/" .. excel.score
    cal_position()
    cal_btn_state()
    cal_flicker()
  else
    local score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouScore)
    local index = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouIndex)
    local excel = bo2.gv_xinshou_score:find(index + 1)
    if excel == nil then
      return
    end
    if score >= excel.score then
      enable_xinshou_button_flick(true)
    end
  end
end
function on_click_event(id)
  local excel = bo2.gv_xinshou_campaign:find(id)
  if excel == nil then
    return
  end
  local event_type = excel.campaign_type
  local fn_faild = function()
    w_main.visible = false
  end
  if event_type == 13 then
    local fn0 = function()
      ui_warrior_arena.w_main_list.visible = true
    end
    local fn_faild0 = function()
    end
    ui_warrior_arena.triggle_visible(fn0, fn_faild0)
    w_main.visible = false
  else
    local function fn1()
      w_main.visible = true
      local server_id = excel.serverid
      local v = sys.variant()
      v:set(packet.key.campaign_eventid, server_id)
      bo2.send_variant(packet.eCTS_UI_Campaign_JoinIn, v)
    end
    if excel.serverid ~= 78 then
      ui_warrior_arena.triggle_visible(fn1, fn_faild)
    else
      fn1()
    end
  end
end
function OnJoinInClick(btn)
  local item_sel = w_list_view.item_sel
  if item_sel == nil then
    return
  end
  local id = item_sel.svar.id
  on_click_event(id)
  local highlight = btn:search("visible_hl")
  if highlight ~= nil then
    highlight.visible = false
  end
end
function on_item_join_btn_click(btn)
  local item_sel = btn.parent.parent
  local highlight = btn:search("visible_hl")
  if highlight ~= nil then
    highlight.visible = false
  end
  local function continue_join()
    local item_sel = btn.parent.parent
    local id = item_sel.svar.id
    on_click_event(id)
  end
  if bo2.player ~= nil and bo2.player:get_flag_objmem(bo2.eFlagObjMemory_Training) == 1 then
    local msg = {
      text = ui.get_text("practice|campaign_notice"),
      modal = true,
      btn_confirm = 1,
      btn_cancel = 1,
      callback = function(data)
        if data.result == 1 then
          continue_join()
        end
      end
    }
    ui_widget.ui_msg_box.show_common(msg)
  else
    continue_join()
  end
end
function on_view_career()
  ui_warrior_arena.on_view_career()
end
function on_get_award_ack(cmd, data)
  cal_btn_state()
  cal_flicker()
end
function set_first_time(flag)
  if "xuezhan" == flag then
    g_first_xuezhan = true
  else
    g_first_time = true
  end
end
function on_xinshou_self_enter()
  local scn = bo2.scn
  if not sys.check(scn) then
    return
  end
  if g_login then
    if bo2.player ~= nil then
      local iLevel = bo2.player:get_atb(bo2.eAtb_Level)
      if iLevel < 30 then
      end
    end
    g_login = false
  end
  w_main.visible = false
  if g_first_time_get_score then
    g_first_time_get_score = false
  end
end
function on_first_get_score(cmd, data)
  g_first_time_get_score = true
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_xinshou_self_enter, "ui_xinshou.on_xinshou_self_enter")
function r()
  ui_xinshou.w_main.visible = true
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_xinshou.packet_handle"
reg(packet.eSTC_UI_XinshouFirstGetScore, on_first_get_score, sig)
reg(packet.eSTC_UI_XinshouUpdateScore, on_score_update, sig)
reg(packet.eSTC_UI_XinshouGetAwardAck, on_get_award_ack, sig)
