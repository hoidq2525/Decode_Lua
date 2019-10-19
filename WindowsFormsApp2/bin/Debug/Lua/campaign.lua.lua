local ui_text_list = ui_widget.ui_text_list
local ui_tab = ui_widget.ui_tab
local w_sort_asc = true
function insert_text(view, text)
  ui_text_list.insert_text(view, text)
  view.scroll = 1
end
function create_reward_c(p_parent, text, star)
  local p_child = ui.create_control(p_parent, "panel")
  p_child:load_style(L("$frame/campaign/campaign.xml"), L("reward_star"))
  p_child:search("lb_name").text = text
  p_child:search("star_full").dx = 16 * star / 2
  p_child:search("star_half").dx = 16 * math.ceil(star / 2)
  return p_child
end
function set_textcolor(label, textcolor)
  label.color = textcolor
  label.shade = textcolor
end
local function select_item(list_id)
  local week_day = bo2.get_cur_camp_svr_weekday()
  ui_tab.show_page(w_core, week_day, true)
  local page = ui_tab.get_page(w_core, week_day)
  local campaign_listview = page:search("campaign_listview")
  local item_cnt = campaign_listview.item_count
  for i = 0, item_cnt - 1 do
    local item = campaign_listview:item_get(i)
    local data = item.var:get("campaign_data")
    local item_camp_id = data:get(packet.key.campaign_detailsid).v_int
    if item_camp_id == list_id then
      item:select(true)
      local num_item_show = math.floor(item.view.dy / item.dy)
      local ratio = i / (item_cnt - num_item_show)
      if ratio > 1 then
        ratio = 1
      end
      item.view.slider_y.scroll = ratio
    end
  end
end
function on_btn_special_img_click(btn, uri)
  local name = btn.svar.data:get(packet.key.campaign_eventname).v_string
  if w_campaign_special_main.visible == true and name == w_campaign_special_title.text then
    w_campaign_special_main.visible = false
    return
  end
  local uri1 = "$image/campaign/special_img/512x512/" .. uri .. ".png"
  local uri2 = "$image/campaign/special_img/256x512/" .. uri .. ".png"
  w_campaign_special_title.text = name
  w_campaign_special_img1.image = uri1
  w_campaign_special_img2.image = uri2
  w_campaign_special_main.visible = true
end
function on_btn_dynamic_campaign_click(btn)
  local btn_camp_id = btn.svar.data:get(packet.key.campaign_detailsid).v_int
  local btn_special_img_uri = btn.svar.data:get(packet.key.campaign_specialimguri).v_string
  if btn_special_img_uri.empty == false then
    on_btn_special_img_click(btn, btn_special_img_uri)
    return
  end
  local week_day = bo2.get_cur_camp_svr_weekday()
  local page = ui_tab.get_page(w_core, week_day)
  local campaign_listview = page:search("campaign_listview")
  if w_main.visible == false then
    w_main.visible = true
    select_item(btn_camp_id)
  elseif w_main.visible == true then
    local item_sel = campaign_listview.item_sel
    if item_sel == nil then
      select_item(btn_camp_id)
    else
      local item_sel_data = item_sel.var:get("campaign_data")
      local item_sel_id = item_sel_data:get(packet.key.campaign_detailsid).v_int
      if btn_camp_id == item_sel_id then
        w_main.visible = false
      else
        select_item(btn_camp_id)
      end
    end
  end
end
function insert_tab(idx)
  local tab_uri = "$frame/campaign/campaign.xml"
  local btn_sty = "tab_btn"
  local page_sty = "tab_page"
  ui_tab.insert_suit(w_core, idx, tab_uri, btn_sty, tab_uri, page_sty)
  local btn = ui_tab.get_button(w_core, idx)
  btn.text = ui.get_text("campaign|weekday" .. idx)
end
function on_init()
  for i = 1, 7 do
    insert_tab(i)
  end
  ui_tab.show_page(w_core, 1, true)
  dynamic_campaign_init()
end
function on_visible(w, vis)
  ui_widget.on_border_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  ui_main.w_top:apply_dock(true)
  if vis == true then
    w:move_to_head()
    local week_day = bo2.get_cur_camp_svr_weekday()
    if week_day == nil then
      week_day = 0
    end
    ui_tab.show_page(w_core, week_day, true)
    local page = ui_tab.get_page(w_core, week_day)
    local campaign_listview = page:search("campaign_listview")
    update_view_data(campaign_listview)
  else
    ui_minimap:on_huodong_end()
    ui_campaign_desc.w_campaign_desc.visible = false
  end
end
function on_view_observable(view, vis)
  if vis then
    update_view_page(view)
  end
end
function on_tab_page_visible(ctrl, vis)
  if vis == false then
    local campaign_listview = ctrl:search("campaign_listview")
    campaign_listview:clear_selection()
  end
end
function on_click_fate_view_rank()
  ui_fate.w_main_rank.visible = true
end
function on_update_item_buttons(item, v, vis)
  if vis ~= true then
    item:search("btn_quickjoinin").visible = false
    item:search("btn_quickpath").visible = false
    item:search("btn_rank").visible = false
    return
  end
  local btn_rank = item:search("btn_rank")
  btn_rank.visible = false
  local state = v:get(packet.key.campaign_eventstate).v_int
  local serverID = v:get(packet.key.campaign_eventid).v_int
  local mark_id = v:get(packet.key.campaign_eventmarkid).v_int
  if state == 2 and serverID ~= 0 then
    item:search("btn_quickjoinin").visible = true
  else
    item:search("btn_quickjoinin").visible = false
    local iEventType = v:get(packet.key.campaign_eventtype).v_int
    if iEventType == bo2.eCampaignType_GlobalMisc_Fate or iEventType == bo2.eCampaignType_GlobalMisc_FateDoubleAward then
      btn_rank.visible = true
    end
  end
  if mark_id == 0 then
    item:search("btn_quickpath").visible = false
  else
    item:search("btn_quickpath").visible = true
  end
end
function update_item_buttons(item)
  if item == nil then
    return
  end
  local v = item.var:get("campaign_data")
  if item.inner_hover or item.selected then
    on_update_item_buttons(item, v, true)
  else
    on_update_item_buttons(item, v, false)
  end
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
function on_campaign_item_mouse(item, msg)
  update_item_highlight(item)
  update_item_buttons(item)
  if msg == ui.mouse_lbutton_down then
    item:select(true)
  end
end
function dock_offset_reset()
  ui_campaign_desc.w_campaign_desc.x = w_main.x + w_main.dx - 14
  ui_campaign_desc.w_campaign_desc.y = w_main.y + 20
  ui_campaign_desc.w_campaign_desc.visible = true
end
function on_device_reset()
end
function on_campaign_item_sel(item, sel)
  update_item_highlight(item)
  update_item_buttons(item)
  local p_reward = ui_campaign_desc.w_campaign_desc:search("desc_reward")
  if not sel then
    ui_campaign_desc.w_campaign_desc.visible = false
    p_reward:control_clear()
    return
  end
  if w_main.visible == false then
    return
  end
  dock_offset_reset()
  ui_campaign_desc.w_campaign_desc_listview:item_clear()
  local v = item.var:get("campaign_data")
  ui_campaign_desc.w_campaign_desc_listview.mtf = v:get(packet.key.campaign_eventdesc)
  ui_campaign_desc.w_campaign_desc_listview.slider_y.scroll = 0
  ui_campaign_desc.w_campaign_name.text = v:get(packet.key.campaign_eventname)
  local y_extent = 0
  local money_star = v:get(packet.key.campaign_eventmoneystar).v_int
  local exp_star = v:get(packet.key.campaign_eventexpstar).v_int
  if money_star ~= 0 then
    local p_temp = create_reward_c(p_reward, ui.get_text("campaign|cash"), money_star)
    y_extent = y_extent + p_temp.dy
  end
  if exp_star ~= 0 then
    local p_temp = create_reward_c(p_reward, ui.get_text("campaign|exp"), exp_star)
    y_extent = y_extent + p_temp.dy
  end
  p_reward.dy = y_extent
  item:tune_y("campaign_time")
  on_update_item_buttons(ui_campaign_desc.w_btn_joinin.parent, v, true)
end
function on_click()
  if w_campaign_level.check then
    setitmevisible(w_campaign_listview, false)
  else
    setitmevisible(w_campaign_listview, true)
  end
end
function setitmevisible(view, is)
  for i = 0, view.item_count - 1 do
    local item = view:item_get(i)
    ui.console_print("item_get")
    if not is then
      local c_v = item.var:get("campaign_data")
      if c_v:get(packet.key.campaign_eventlevelmin).v_int > bo2.player:get_atb(bo2.eAtb_Level) then
        item.visible = is
        ui.console_print("is == false")
      end
    else
      item.visible = is
    end
  end
end
function getkey(field_name)
  if field_name == "campaign_time" then
    return packet.key.campaign_eventtime
  elseif field_name == "campaign_name" then
    return packet.key.campaign_eventname
  elseif field_name == "campaign_levelmin" then
    return packet.key.campaign_eventlevelmin
  elseif field_name == "campaign_area" then
    return packet.key.campaign_eventarea
  elseif field_name == "campaign_eventintensity" then
    return packet.key.campaign_eventintensity
  else
    return nil
  end
end
function get_compare(v, p, item, ikey)
  if p == item then
    return p
  end
  if w_sort_asc then
    if v:get(p):get(ikey).v_int > v:get(item):get(ikey).v_int then
      return item
    end
  elseif v:get(p):get(ikey).v_int < v:get(item):get(ikey).v_int then
    return item
  end
  return p
end
function OnJoinInClick()
  local page = ui_widget.ui_tab.get_show_page(w_core)
  local campaign_listview = page:search("campaign_listview")
  local item_sel = campaign_listview.item_sel
  if item_sel == nil then
    return
  end
  local data = item_sel.var:get("campaign_data")
  local iEventType = data:get(packet.key.campaign_eventtype).v_int
  if iEventType == bo2.eCampaignType_CavalierChampion then
    ui_campaign.w_main.visible = false
    ui_champion.w_main.visible = true
    return
  elseif iEventType == bo2.eCampaignType_GlobalMisc_Fate or iEventType == bo2.eCampaignType_GlobalMisc_FateDoubleAward then
    ui_campaign.w_main.visible = false
    ui_fate.w_main.visible = true
    return
  elseif iEventType == bo2.eCampaignType_Globalmisc_DooAltar then
    ui_match.on_dooaltar_apply_request()
    ui_match.gx_match_win.visible = true
    return
  elseif iEventType == bo2.eCampaignType_QuestionQuiz then
    local cur_q_idx = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_TodayQuestionIDIdx)
    if bo2.is_cooldown_over(ui_question.g_cd_id) then
      ui_question.send_generate_question()
    elseif bo2.ePlayerFlagInt16_TodayQuestionIDBeg + cur_q_idx >= bo2.ePlayerFlagInt16_TodayQuestionIDEnd then
      ui_question_conclusion.w_main.visible = true
    else
      ui_question.w_main.visible = true
    end
  end
  local serverID = data:get(packet.key.campaign_eventid).v_int
  if iEventType == bo2.eCampaignType_DailyRandomBattle then
    serverID = get_double_campaign_server_id()
  end
  local v = sys.variant()
  v:set(packet.key.campaign_eventid, serverID)
  bo2.send_variant(packet.eCTS_UI_Campaign_JoinIn, v)
end
function OnPathClick()
  local page = ui_widget.ui_tab.get_show_page(w_core)
  local campaign_listview = page:search("campaign_listview")
  local item_sel = campaign_listview.item_sel
  if item_sel == nil then
    return
  end
  local data = item_sel.var:get("campaign_data")
  local mark_id = data:get(packet.key.campaign_eventmarkid).v_int
  local excel = bo2.gv_mark_list:find(mark_id)
  ui_widget.ui_chat_list.on_click_mark_id(mark_id, excel)
end
function on_item_join_btn_click(btn)
  local function continue_join()
    local item_sel = btn.parent.parent
    local data = item_sel.var:get("campaign_data")
    local iEventType = data:get(packet.key.campaign_eventtype).v_int
    if iEventType == bo2.eCampaignType_CavalierChampion then
      ui_campaign.w_main.visible = false
      ui_champion.w_main.visible = true
      return
    elseif iEventType == bo2.eCampaignType_GlobalMisc_Fate or iEventType == bo2.eCampaignType_GlobalMisc_FateDoubleAward then
      ui_campaign.w_main.visible = false
      ui_fate.w_main.visible = true
      return
    elseif iEventType == bo2.eCampaignType_Globalmisc_DooAltar then
      ui_match.on_dooaltar_apply_request()
      ui_match.gx_match_win.visible = true
      return
    elseif iEventType == bo2.eCampaignType_QuestionQuiz then
      local cur_q_idx = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_TodayQuestionIDIdx)
      if bo2.is_cooldown_over(ui_question.g_cd_id) then
        ui_question.send_generate_question()
      elseif bo2.ePlayerFlagInt16_TodayQuestionIDBeg + cur_q_idx >= bo2.ePlayerFlagInt16_TodayQuestionIDEnd then
        ui_question_conclusion.w_main.visible = true
      else
        ui_question.w_main.visible = true
      end
    end
    local serverID = data:get(packet.key.campaign_eventid).v_int
    if iEventType == bo2.eCampaignType_DailyRandomBattle then
      serverID = get_double_campaign_server_id()
    end
    local v = sys.variant()
    v:set(packet.key.campaign_eventid, serverID)
    bo2.send_variant(packet.eCTS_UI_Campaign_JoinIn, v)
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
function on_item_path_btn_click(btn)
  local item_sel = btn.parent.parent
  local data = item_sel.var:get("campaign_data")
  local mark_id = data:get(packet.key.campaign_eventmarkid).v_int
  local excel = bo2.gv_mark_list:find(mark_id)
  ui_widget.ui_chat_list.on_click_mark_id(mark_id, excel)
end
function on_close_click(btn)
  ui_widget.on_close_click(btn)
end
function on_item_quick_btn_mouse(btn, msg)
  update_item_buttons(btn.parent.parent)
end
