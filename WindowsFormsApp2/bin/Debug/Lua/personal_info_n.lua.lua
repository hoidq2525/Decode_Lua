local g_quest_list_can_accept = sys.variant()
local g_quest_list_accepted = sys.variant()
local quest_order = {}
local quest_order_accepted = {}
local g_cur_page = 1
local g_page_count = 7
local g_max_page = 0
local g_cur_page_1 = 1
local g_max_page_1 = 0
local select_quest, gx_window, ui_tab
local pic_path = L("$gui/image/guild/quest_theme/")
local pic_area = L("|3,3,58,58")
local path_level_award = SHARED("$mb/quest/level_match_award/level_match_award.xml")
local path_award = SHARED("$mb/quest/level_match_award/")
function on_init()
  g_cur_page = 1
  g_page_count = 7
  g_cur_page_1 = 1
  g_quest_list_accepted:clear()
  g_quest_list_can_accept:clear()
  quest_order = {}
  quest_order_accepted = {}
  select_quest = nil
  gx_window = ui_npc_guild_mod.ui_npc_guild.w_win
  ui_tab = ui_widget.ui_tab
  insert_tab("quest_desc")
  insert_tab("quest_theme")
  select_quest = nil
  ui_tab.show_page(w_desc, "quest_theme", true)
end
function insert_tab(name)
  local btn_uri = "$frame/npc_guild/personal_info_n.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/npc_guild/personal_info_n.xml"
  local page_sty = name
  ui_tab.insert_suit(w_desc, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_desc, name)
  btn.text = ui.get_text(sys.format("guild|tab_btn_%s", name))
  btn.name = name
  btn:insert_on_press(on_tab_press, "ui_guild_mod.ui_personal_info.on_tab_press")
end
function on_tab_press(btn, press)
  if press and btn.name == L("quest_desc") and select_quest == nil then
    update_desc()
  end
end
function update()
  if gx_window == nil then
    return
  end
  local page = ui_tab.get_show_page(gx_window)
  if page.name ~= L("personal_info") then
    return
  end
  update_today_theme()
  update_quest_num()
  update_personal_info()
end
function update_quest_all()
  update_quest_num()
end
function get_week_con_max(id)
  local line = bo2.gv_guild_welfare:find(id)
  local re_value = 0
  if line ~= nil then
    re_value = line.weekmax
  end
  return re_value
end
function get_hall_name(id)
  local hall_name = ui.guild_get_hall_name(id)
  if sys.check(hall_name) == false then
    hall_name = ui.get_text("org|null")
  end
  return hall_name
end
function update_personal_info()
  local my_info = ui.guild_get_self()
  if my_info == nil then
    return
  end
  local arg = sys.variant()
  g_p_name.text = my_info.name
  g_p_pos.text = bo2.gv_level_list:find(my_info.title).title
  if my_info.title >= bo2.NpcGuild_Youxia then
    g_p_needcontri.text = L("")
  else
    local next_pos = bo2.gv_level_list:find(my_info.title + 1)
    if next_pos == nil then
      g_p_needcontri.text = L("")
    else
      local need_con = next_pos.totalc - my_info.total_con
      local v = sys.variant()
      v:set("num", need_con)
      g_p_needcontri.text = sys.mtf_merge(v, ui.get_text("guild|level_contri"))
    end
  end
  local v = sys.variant()
  v:set("num", canuse)
  local text = sys.mtf_merge(v, ui.get_text("personal|repute_button_tip"))
  g_p_hcon.text = my_info.total_con
  g_p_wcon.text = my_info.week_con
  g_p_hall.text = get_hall_name(bo2.player.only_id)
  g_p_ucon.text = my_info.current_con
  g_p_wlimit.text = get_week_con_max(my_info.welfare)
end
function on_vote(btn)
  ui_npc_guild_mod.ui_vote.gx_window.visible = true
end
function on_get_dexp(btn)
  local dexp = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_iGuildExp)
  ui_dexp.packet_get_guildTime(dexp)
  update_personal_info()
end
function on_quest_name_tip(tip)
  local parent = tip.owner.parent
  tip.text = parent:search("quest_name").text
  ui_widget.tip_make_view(tip.view, tip.text)
end
function update_today_theme()
  local theme = ui.daily_quest_theme()
  local excel = bo2.gv_guild_quest_theme:find(theme)
  if excel == nil then
    return
  end
  local pic_name = excel.pic_name
  g_theme_box.parent:search("item_picture").image = pic_path .. pic_name .. pic_area
  g_theme_box.text = excel.name
  g_theme_desc.mtf = excel.desc
end
function update_quest()
  if bo2.player == nil then
    return
  end
  g_quest_list_can_accept:clear()
  g_quest_list_accepted:clear()
  quest_order = {}
  quest_order_accepted = {}
  local size = bo2.gv_quest_list.size
  for i = 0, size - 1 do
    local excel = bo2.gv_quest_list:get(i)
    local order = excel.guild_quest_order
    if excel.in_theme == bo2.eThemeType_Guild and order ~= 0 then
      local q_info = ui.quest_find(excel.id)
      if q_info ~= nil then
        quest_order_accepted[order] = excel.id
      elseif ui.quest_check_insert(excel.id) and bo2.is_cooldown_over(excel.cooldown) then
        for j = 0, excel.guild_quest_jiaopai.size - 1 do
          if 3 == excel.guild_quest_jiaopai[j] then
            quest_order[order] = excel.id
          end
        end
      end
    end
  end
  local first = bo2.ePlayerFlagInt32_GuildQuestBegin
  local last = bo2.ePlayerFlagInt32_GuildQuestEnd
  for i = first, last do
    local quest_id = bo2.player:get_flag_int32(i)
    if quest_id == 0 then
      break
    end
    local excel = bo2.gv_quest_list:find(quest_id)
    local order = excel.guild_quest_order
    if excel ~= nil and excel.in_theme == bo2.eThemeType_Guild and excel.guild_quest_order ~= 0 then
      quest_order_accepted[order] = quest_id
    end
  end
  for j = 1, table.maxn(quest_order) do
    if quest_order[j] ~= nil and quest_order[j] ~= 0 then
      g_quest_list_can_accept:push_back(quest_order[j])
    end
  end
  for k = 1, table.maxn(quest_order_accepted) do
    if quest_order_accepted[k] ~= nil and quest_order_accepted[k] ~= 0 then
      g_quest_list_accepted:push_back(quest_order_accepted[k])
    end
  end
  g_max_page = math.ceil(g_quest_list_can_accept.size / g_page_count)
  g_max_page_1 = math.ceil(g_quest_list_accepted.size / g_page_count)
end
function update_quest_list()
  local quest_size = g_quest_list_can_accept.size
  local star_num = (g_cur_page - 1) * g_page_count + 1
  if quest_size < star_num then
    g_cur_page = 1
    star_num = 1
  end
  for i = 1, 7 do
    local item = g_card_list_can_accept:search("quest_card_" .. i)
    local idx = star_num + i - 2
    if idx > quest_size - 1 then
      item.visible = false
    else
      local quest_id = g_quest_list_can_accept:get(idx).v_int
      local excel = bo2.gv_quest_list:find(quest_id)
      if excel == nil then
        return
      end
      local quest_name = item:search("quest_name")
      quest_name.text = excel.name
      local quest_pic = item:search("item_picture")
      local theme_id = excel.guild_quest_theme
      local theme_excel = bo2.gv_guild_quest_theme:find(theme_id)
      if theme_excel == nil then
        quest_pic.image = pic_path .. "tongyong.png" .. pic_area
      else
        local pic_name = theme_excel.pic_name
        quest_pic.image = pic_path .. pic_name .. pic_area
      end
      item.visible = true
      item.svar.quest_id = quest_id
      local b = bo2.is_cooldown_over(excel.cooldown)
      local btn = item:search("btn")
      if not b then
        btn.enable = false
        btn.text = ui.get_text("guild|quest_cooldown")
      else
        btn.enable = true
        btn.text = ui.get_text("guild|quest_accept")
      end
    end
  end
  if g_cur_page == 1 then
    g_card_list_can_accept:search("btn_prev").enable = false
  else
    g_card_list_can_accept:search("btn_prev").enable = true
  end
  if g_cur_page >= g_max_page then
    g_card_list_can_accept:search("btn_next").enable = false
  else
    g_card_list_can_accept:search("btn_next").enable = true
  end
  if select_quest ~= nil then
    ui_widget.ui_tab.show_page(w_desc, "quest_desc", true)
    update_desc(select_quest.parent.svar.quest_id)
  else
    ui_widget.ui_tab.show_page(w_desc, "quest_theme", true)
  end
end
function update_accept_list()
  if bo2.player == nil then
    return
  end
  local star_num = (g_cur_page_1 - 1) * g_page_count + 1
  if star_num > g_quest_list_accepted.size then
    g_cur_page_1 = 1
    star_num = 1
  end
  g_max_page_1 = math.ceil(g_quest_list_accepted.size / g_page_count)
  for i = 1, 7 do
    local item = g_card_list_accepted:search("quest_card_" .. i)
    local idx = star_num + i - 2
    if idx > g_quest_list_accepted.size - 1 then
      item.visible = false
    else
      local quest_id = g_quest_list_accepted:get(idx).v_int
      local excel = bo2.gv_quest_list:find(quest_id)
      if excel == nil then
        return
      end
      local quest_name = item:search("quest_name")
      quest_name.text = excel.name
      local quest_pic = item:search("item_picture")
      local theme_id = excel.guild_quest_theme
      local theme_excel = bo2.gv_guild_quest_theme:find(theme_id)
      if theme_excel == nil then
        quest_pic.image = pic_path .. "tongyong.png" .. pic_area
      else
        local pic_name = theme_excel.pic_name
        quest_pic.image = pic_path .. pic_name .. pic_area
      end
      item.visible = true
      item.svar.quest_id = quest_id
      local quest_info = ui.quest_find(quest_id)
      local btn = item:search("btn")
      if quest_info ~= nil and quest_info.completed then
        btn.text = ui.get_text("guild|tip_cmn4")
        btn.enable = true
      else
        btn.text = ui.get_text("guild|quest_giveup")
        btn.enable = true
      end
      if quest_info == nil then
        btn.text = ui.get_text("guild|quest_finished")
        btn.enable = false
      end
    end
  end
  if g_cur_page_1 == 1 then
    g_card_list_accepted:search("btn_prev").enable = false
  else
    g_card_list_accepted:search("btn_prev").enable = true
  end
  if g_cur_page_1 >= g_max_page_1 then
    g_card_list_accepted:search("btn_next").enable = false
  else
    g_card_list_accepted:search("btn_next").enable = true
  end
end
function on_stepping_left(btn)
  g_cur_page = g_cur_page - 1
  if select_quest ~= nil then
    select_quest:search("fig_highlight_sel").visible = false
    select_quest = nil
  end
  update_quest_num()
  update_desc()
  if g_cur_page == 1 then
    g_card_list_can_accept:search("btn_prev").enable = false
  else
    g_card_list_can_accept:search("btn_prev").enable = true
  end
  if g_cur_page >= g_max_page then
    g_card_list_can_accept:search("btn_next").enable = false
  else
    g_card_list_can_accept:search("btn_next").enable = true
  end
end
function on_stepping_right(btn)
  g_cur_page = g_cur_page + 1
  if select_quest ~= nil then
    select_quest:search("fig_highlight_sel").visible = false
    select_quest = nil
  end
  update_quest_num()
  update_desc()
  if g_cur_page == 1 then
    g_card_list_can_accept:search("btn_prev").enable = false
  else
    g_card_list_can_accept:search("btn_prev").enable = true
  end
  if g_cur_page >= g_max_page then
    g_card_list_can_accept:search("btn_next").enable = false
  else
    g_card_list_can_accept:search("btn_next").enable = true
  end
end
function on_accepted_stepping_left(btn)
end
function on_accepted_stepping_right(btn)
end
function on_visible(w, v)
  if v then
    update()
  end
end
function on_quest_info(ctrl, msg)
  if msg ~= ui.mouse_lbutton_down then
    return
  end
  if select_quest ~= nil then
    select_quest:search("fig_highlight_sel").visible = false
  end
  select_quest = ctrl
  select_quest:search("fig_highlight_sel").visible = true
  local quest_id = select_quest.parent.svar.quest_id
  ui_widget.ui_tab.show_page(w_desc, "quest_desc", true)
  update_desc(quest_id)
end
function set_quest_desc(quest_id)
  g_desc_box:item_clear()
  local excel = bo2.gv_quest_list:find(quest_id)
  if excel == nil then
    return
  end
  g_desc_box.mtf = excel.text.details
  g_desc_box.dy = g_desc_box.extent.y
  g_desc_box.parent.dy = g_desc_box.extent.y + 22
end
function set_quest_aim(quest_id)
  local quest_info = ui.quest_find(quest_id)
  g_aim_box:item_clear()
  local excel = bo2.gv_quest_list:find(quest_id)
  if excel == nil then
    return
  end
  local goal = excel.text.goal
  local all_text = ""
  all_text = sys.format("<c+:%s>%s<c->", ui_quest.c_title_aim_color, goal)
  for i = 0, 3 do
    local cur_num = 0
    if quest_info ~= nil then
      cur_num = quest_info.comp[i]
    end
    local obj = bo2.gv_quest_object:find(excel.req_obj[i])
    if obj ~= nil then
      local name1 = obj.name
      local list = ui.quest_get_qobj_excel(excel.req_obj[i], excel.req_id[i])
      local name2
      if list ~= nil then
        name2 = list.name
      end
      if excel.req_obj[i] == bo2.eQuestObj_Quest then
        name2 = ui.get_text("quest|milestone_step")
      end
      local total_num = ui_quest.get_aim_max_num(excel.req_obj[i], excel, i, false)
      cur_num = ui_quest.reset_value(excel.req_obj[i], cur_num, total_num)
      local v = sys.variant()
      v:set("color", ui_quest.c_aim_color)
      v:set("do", name1)
      v:set("something", name2)
      v:set("cur_num", cur_num)
      v:set("total_num", total_num)
      local content = sys.mtf_merge(v, ui.get_text("quest|quest_object_text"))
      all_text = sys.format([[
%s
%s]], all_text, content)
    end
  end
  local rank = ui.mtf_rank_system
  local content = sys.format("<tf:text>%s", all_text)
  g_aim_box:insert_mtf(content, rank)
  g_aim_box.dy = g_aim_box.extent.y
  g_aim_box.parent.dy = g_aim_box.extent.y + 22
end
function set_quest_reward(quest_id)
  w_rewards_list:item_clear()
  local excel = bo2.gv_quest_list:find(quest_id)
  if excel == nil then
    return
  end
  local rewards_uri = "$frame/quest/cmn.xml"
  if ui_quest.insert_goods(w_rewards_list, excel) then
    local has_reward = false
  end
  if not excel.awd_match_level.empty then
    local g_awd_match_level = sys.load_table(path_level_award, path_award .. excel.awd_match_level .. ".txt")
    if g_awd_match_level ~= nil then
      local pLevel = bo2.player:get_atb(bo2.eAtb_Level)
      local tbl = g_awd_match_level:find(pLevel)
      if tbl == nil then
        return
      end
      local info = ui.quest_find(quest_id)
      local temp_val = 1
      local add = 0
      local times = 1
      if excel.guild_quest_theme == ui.daily_quest_theme() then
        times = excel.guild_quest_add / 100
        add = excel.guild_quest_add / 100
      end
      if 0 < tbl.awd_exp then
        local item_exp = w_rewards_list:item_append()
        item_exp:load_style(rewards_uri, "exp_reward")
        item_exp.size = ui.point(200, 20)
        local exp_value = item_exp:search("exp_value")
        local value = tbl.awd_exp
        if info ~= nil and excel.req_max[0] > excel.req_min[0] and info.comp1 > excel.req_min[0] and excel.req_max[0] ~= 65535 then
          value = ui_quest.caculate_value(excel, info.comp1, value)
        end
        exp_value.text = value * times
        has_reward = true
      end
      if 0 < tbl.awd_money then
        local item_money = w_rewards_list:item_append()
        item_money:load_style(rewards_uri, "currency_money_reward")
        item_money.size = ui.point(200, 20)
        local currency_money_value = item_money:search("currency_money_value")
        local value = tbl.awd_money
        if info ~= nil and excel.req_max[0] > excel.req_min[0] and info.comp1 > excel.req_min[0] and excel.req_max[0] ~= 65535 then
          value = ui_quest.caculate_value(excel, info.comp1, value)
        end
        if tbl.awd_money_kind == bo2.eCurrency_CirculatedMoney then
          currency_money_value.bounded = false
        else
          currency_money_value.bounded = true
        end
        currency_money_value.money = value * times
        has_reward = true
      end
      for i = 0, 3 do
        local awd_obj = tbl["awd_obj_" .. i]
        local awd_id = tbl["awd_id_" .. i]
        local awd_num = tbl["awd_num_" .. i]
        if awd_obj == bo2.eQuestObj_ReputePoint then
          local rep_excel = bo2.gv_repute_list:find(awd_id)
          if rep_excel ~= nil and rep_excel.disable == 0 then
            local item_rep = w_rewards_list:item_append()
            item_rep:load_style(rewards_uri, "reputation_reward")
            item_rep.size = ui.point(300, 20)
            local rep = item_rep:search("rep_value")
            rep.text = sys.format("(%s) %d", rep_excel.name, awd_num * times)
            has_reward = true
          end
        elseif awd_obj == bo2.eQuestObj_GuildPersonlContri then
          local item_guild = w_rewards_list:item_append()
          item_guild:load_style(rewards_uri, "guild_reward")
          item_guild.size = ui.point(300, 20)
          local box = item_guild:search("box")
          local text = ui_quest.get_guild_text(awd_obj, awd_id, awd_num * times)
          local rank = ui.mtf_rank_system
          local content = sys.format("<tf:text>%s", text)
          box:insert_mtf(content, rank)
          has_reward = true
        end
      end
    end
  else
    local info = ui.quest_find(quest_id)
    local temp_val = 1
    local add = 0
    local times = 1
    if excel.guild_quest_theme == ui.daily_quest_theme() then
      times = excel.guild_quest_add / 100
      add = excel.guild_quest_add / 100
    end
    if 0 < excel.awd_exp then
      local item_exp = w_rewards_list:item_append()
      item_exp:load_style(rewards_uri, "exp_reward")
      item_exp.size = ui.point(200, 20)
      local exp_value = item_exp:search("exp_value")
      local value = excel.awd_exp
      if info ~= nil and excel.req_max[0] > excel.req_min[0] and info.comp1 > excel.req_min[0] and excel.req_max[0] ~= 65535 then
        value = ui_quest.caculate_value(excel, info.comp1, value)
      end
      exp_value.text = value * times
      has_reward = true
    end
    if 0 < excel.awd_money then
      local item_money = w_rewards_list:item_append()
      item_money:load_style(rewards_uri, "currency_money_reward")
      item_money.size = ui.point(200, 20)
      local currency_money_value = item_money:search("currency_money_value")
      local value = excel.awd_money
      if info ~= nil and excel.req_max[0] > excel.req_min[0] and info.comp1 > excel.req_min[0] and excel.req_max[0] ~= 65535 then
        value = ui_quest.caculate_value(excel, info.comp1, value)
      end
      if excel.awd_money_kind == bo2.eCurrency_CirculatedMoney then
        currency_money_value.bounded = false
      else
        currency_money_value.bounded = true
      end
      currency_money_value.money = value * times
      has_reward = true
    end
    for i = 0, 3 do
      local questobj = excel.awd_obj[i]
      if questobj == bo2.eQuestObj_ReputePoint then
        local rep_excel = bo2.gv_repute_list:find(excel.awd_id[i])
        if rep_excel ~= nil and rep_excel.disable == 0 then
          local item_rep = w_rewards_list:item_append()
          item_rep:load_style(rewards_uri, "reputation_reward")
          item_rep.size = ui.point(300, 20)
          local rep = item_rep:search("rep_value")
          rep.text = sys.format("(%s) %d", rep_excel.name, excel.awd_num[i] * times)
          has_reward = true
        end
      elseif questobj == bo2.eQuestObj_GuildPersonlContri then
        local item_guild = w_rewards_list:item_append()
        item_guild:load_style(rewards_uri, "guild_reward")
        item_guild.size = ui.point(300, 20)
        local box = item_guild:search("box")
        local text = ui_quest.get_guild_text(excel.awd_obj[i], excel.awd_id[i], excel.awd_num[i] * times)
        local rank = ui.mtf_rank_system
        local content = sys.format("<tf:text>%s", text)
        box:insert_mtf(content, rank)
        has_reward = true
      end
    end
  end
  w_desc_list:search("quest_rewards").dy = w_rewards_list.extent.y + 20
  w_desc_list.dy = w_rewards_list.extent.y + 42
  w_reward_title.visible = has_reward
end
function update_desc(quest_id)
  if select_quest == nil then
    w_desc_list.visible = false
    w_desc_list.parent:search("liezhuan").visible = true
    return
  else
    w_desc_list.parent:search("liezhuan").visible = false
    w_desc_list.visible = true
  end
  set_quest_desc(quest_id)
  set_quest_aim(quest_id)
  set_quest_reward(quest_id)
end
function on_theme_info(ctrl, msg)
end
function on_btn_accept(btn)
  local item = btn.parent
  local quest_id = item.svar.quest_id
  local v = sys.variant()
  v:set(packet.key.quest_id, quest_id)
  bo2.send_variant(packet.eCTS_UI_AddQuest, v)
end
function accept_quest(quest_info)
  local order = quest_info.excel.guild_quest_order
  quest_order[order] = 0
  for i = 0, g_quest_list_can_accept.size - 1 do
    local excel_id = g_quest_list_can_accept:get(i).v_int
    if excel_id == quest_info.excel_id then
      g_quest_list_can_accept:erase(i)
      break
    end
  end
  g_quest_list_accepted:clear()
  local order = quest_info.excel.guild_quest_order
  quest_order_accepted[order] = quest_info.excel_id
  for j = 1, table.maxn(quest_order_accepted) do
    if quest_order_accepted[j] ~= nil and quest_order_accepted[j] ~= 0 then
      g_quest_list_accepted:push_back(quest_order_accepted[j])
    end
  end
  update_quest_num()
  if select_quest ~= nil then
    select_quest:search("fig_highlight_sel").visible = false
    select_quest = nil
  end
  ui_widget.ui_tab.show_page(w_desc, "quest_theme", true)
end
function on_btn_giveup(btn)
  local item = btn.parent
  local quest_id = item.svar.quest_id
  local quest_info = ui.quest_find(quest_id)
  local function on_give_up_quest(data)
    if data.result == 1 then
      ui_quest.giveup(quest_id)
    end
  end
  if quest_info ~= nil and quest_info.completed then
    ui_quest.send_quest_complete(quest_id)
  else
    local list = bo2.gv_quest_list:find(quest_id)
    local v = sys.variant()
    v:set("quest_name", list.name)
    msg_text = sys.mtf_merge(v, ui.get_text("quest|giveup_confirm"))
    local data = {
      title = ui.get_text("quest|giveup_quest"),
      text = msg_text,
      callback = on_give_up_quest
    }
    ui_widget.ui_msg_box.show_common(data)
  end
end
function giveup_quest(quest_info)
  update_quest_num()
  if select_quest ~= nil then
    select_quest:search("fig_highlight_sel").visible = false
    select_quest = nil
  end
  ui_widget.ui_tab.show_page(w_desc, "quest_theme", true)
end
function update_quest_num()
  if bo2.is_in_guild() == sys.wstring(0) then
    return
  end
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_GuildQuestCD, v)
end
function handle_update_quest_num()
  update_quest()
  update_quest_list()
  update_accept_list()
  local finished_num = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_GuildQuestNum)
  local current_num = ui.get_guild_quest_num()
  if finished_num == 0 then
    local star_num = (g_cur_page_1 - 1) * g_page_count + 1
    if star_num > g_quest_list_accepted.size then
      g_cur_page_1 = 1
      star_num = 1
    end
    g_max_page_1 = math.ceil(g_quest_list_accepted.size / g_page_count)
    quest_order_accepted = {}
    for i = 1, 7 do
      local item = g_card_list_accepted:search("quest_card_" .. i)
      local idx = star_num + i - 2
      if idx > g_quest_list_accepted.size - 1 then
        item.visible = false
      else
        local quest_id = g_quest_list_accepted:get(idx).v_int
        local quest_info = ui.quest_find(quest_id)
        if quest_info ~= nil then
          local order = quest_info.excel.guild_quest_order
          quest_order_accepted[order] = quest_id
        else
          item.visible = false
        end
      end
    end
    g_quest_list_accepted:clear()
    for k = 1, table.maxn(quest_order_accepted) do
      if quest_order_accepted[k] ~= nil and quest_order_accepted[k] ~= 0 then
        g_quest_list_accepted:push_back(quest_order_accepted[k])
      end
    end
  end
  local finished_num = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_GuildQuestNum)
  local current_num = ui.get_guild_quest_num()
  local today_num = finished_num + current_num
  local guild_level = ui.guild_get_level()
  local total_num = 3
  if guild_level > 1 then
    total_num = guild_level + 1
  end
  w_quest_num.text = "(" .. today_num .. "/" .. total_num .. ")"
  if today_num >= total_num then
    for i = 1, 7 do
      local item = g_card_list_can_accept:search("quest_card_" .. i)
      local btn = item:search("btn")
      btn.enable = false
    end
  else
    for i = 1, 7 do
      local item = g_card_list_can_accept:search("quest_card_" .. i)
      local btn = item:search("btn")
      local quest_id = item.svar.quest_id
      local excel = bo2.gv_quest_list:find(quest_id)
      if excel ~= nil then
        if bo2.is_cooldown_over(excel.cooldown) then
          btn.enable = true
        else
          btn.enable = false
        end
      end
    end
  end
end
