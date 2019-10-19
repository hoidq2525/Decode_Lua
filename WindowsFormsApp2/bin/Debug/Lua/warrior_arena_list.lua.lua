local n_page_limit = 7
local n_page_count = 10
local n_cell_count = 6
local refresh_type_runtime = 1
local refresh_type_all = 2
local g_view_help_tip = false
g_rank_data = {valid = false}
g_cha_rank = {}
g_interface_data = {}
g_refresh_page = false
g_color_gray = SHARED("979797")
g_refresh_table = nil
g_time_count = 0
local g_last_player
function on_init()
  g_interface_data = {}
  g_interface_data[bo2.eRequestModelType_StaticData] = {request = 0, fun = refresh_static_data}
  g_interface_data[bo2.eRequestModelType_RuntimeData] = {request = 0, fun = refresh_runtime_data}
  g_record_data = {
    state = bo2.eWarriorArenaState_None
  }
  g_current_act = 1
  g_refresh_table = nil
end
on_init()
function on_mouse_view_career(w, msg, pos, wheel)
  if msg == ui.mouse_inner then
    w_title_help.visible = false
  end
end
function init_rank()
  if g_rank_data.valid == true then
    return
  end
  g_rank_data = {}
  g_cha_rank = {}
  g_rank_data.valid = true
  local knight_size = bo2.gv_knight_likeness_list.size
  for i = 0, knight_size - 1 do
    local knight_renown = bo2.gv_knight_likeness_list:get(i)
    local cha_data = bo2.gv_cha_list:find(knight_renown.id)
    if cha_data then
      local val = {}
      val.name = cha_data.name
      val.rank = knight_renown.renown_rank
      val.title_id = cha_data.title_id
      table.insert(g_rank_data, val)
    end
  end
end
function refresh_button_text()
  local btn = btn_regist_fight
  if sys.check(btn) ~= true then
    return
  end
  if g_time_count <= 0 then
    btn.enable = true
    btn.dx = 118
    btn.text = ui.get_text("warrior_arena|regist_fight")
  else
    btn.enable = false
    local mtf_data = {}
    mtf_data.second = g_time_count
    btn.text = ui_widget.merge_mtf(mtf_data, ui.get_text("warrior_arena|btn_text"))
    btn.dx = 180
  end
end
function on_timer_set_button(timer)
  if g_time_count <= 0 then
    if sys.check(timer) then
      timer.suspended = true
    end
    refresh_button_text()
    return
  end
  g_time_count = g_time_count - 1
  refresh_button_text()
end
function get_fighter_data(cha_list)
  if sys.check(cha_list) == false then
    return nil
  end
  if g_cha_rank ~= nil and g_cha_rank[cha_list.id] ~= nil then
    return g_cha_rank[cha_list.id]
  end
  local tab_size = table.getn(g_rank_data)
  for i = 1, tab_size - 1 do
    local v = g_rank_data[i]
    if v ~= nil and cha_list.name == v.name then
      g_cha_rank[cha_list.id] = v
      break
    end
  end
  return g_cha_rank[cha_list.id]
end
function stk_push_new_line(stk)
  stk:raw_push(L("\n"))
end
function desc_common_align(stk)
  stk:raw_push(L("<c+:979797><a+:left>"))
end
function l()
  on_self_enter()
  w_main_list.visible = true
end
function s()
  w_main_select.visible = true
end
function on_visible_select(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis then
    update_select_data()
    w.priority = 500
    w:move_to_head()
  else
    w.priority = 110
  end
end
function on_visible_list(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  local vPacket = sys.variant()
  vPacket:set(packet.key.sociality_personals_type, bo2.eSocialUI_WarriorArena)
  vPacket:set(packet.key.sociality_personals_uiopen, vis)
  if vis then
    refresh_scn_data()
    local refresh_base = {
      bo2.eRequestModelType_StaticData,
      bo2.eRequestModelType_RuntimeData
    }
    for i, v in pairs(refresh_base) do
      local tab = g_interface_data[v]
      vPacket:set(v, tab.request)
    end
    local refresh_type = refresh_type_all
    refresh_act_challenger_data(1, refresh_type)
    refresh_button_text()
    w_title_help.visible = false
    ui_handson_teach.on_test_visible_set_proprity(w)
  else
    w.priority = 110
  end
  bo2.send_variant(packet.eCTS_Sociality_UISwitch, vPacket)
end
function on_confirm_fight(excel)
  if sys.check(excel) ~= true then
    return
  end
  local v = sys.variant()
  v:set(packet.key.knight_pk_npc_cha_id, excel.id)
  bo2.send_variant(packet.eCTS_UI_WarriorArena_RegistFight, v)
  w_main_select.visible = false
end
function on_try_join()
  local tab = g_interface_data[bo2.eRequestModelType_RuntimeData]
  if tab == nil then
    return
  end
  local data = tab.data
  if data == nil then
    return
  end
  anime_reg.visible = false
  local act = get_act()
  local excel_tab, tab_count = get_act_fighter(act)
  if tab_count == 1 then
    local excel = excel_tab[0]
    on_confirm_fight(excel)
  elseif act > get_fight_invitation() then
    local excel = bo2.gv_text:find(71560)
    if sys.check(excel) then
      ui_tool.note_insert(excel.text, "00FF00")
    end
  else
    w_main_select.visible = true
  end
end
function on_execute_fight()
  local rst, cell = check_select()
  if rst ~= true or cell == nil then
    return
  end
  local var = cell.var
  local excel_id = var:get(L("excel")).v_int
  local excel = bo2.gv_cavalier_championship_npc:find(excel_id)
  if sys.check(excel) ~= true then
    w_main_select.visible = false
    return
  end
  on_confirm_fight(excel)
end
function on_regist_fight()
  on_try_join()
end
function get_player_career_pic(obj)
  if sys.check(obj) ~= true then
    return nil
  end
  local career_panel = {}
  local career = obj:get_atb(bo2.eAtb_Cha_Profession)
  local career_idx = 0
  local pro = bo2.gv_profession_list:find(career)
  local set_image = false
  if pro == nil then
    career_idx = 0
  else
    career_idx = pro.career - 1
    if career_idx >= 6 then
      career_idx = career_idx + 1
      career_panel.image = L("$image/widget/btn/career.png")
      career_panel.irect = ui.rect(career_idx * 21 + 1, 46, (career_idx + 1) * 21, 77)
      set_image = true
    end
  end
  if set_image ~= true then
    career_panel.image = L("$image/cha/portrait/career.png")
    career_panel.irect = ui.rect(career_idx * 21, 0, (career_idx + 1) * 21, 32)
  end
  career_panel.svar = career
  career_panel.visible = true
  return career_panel
end
function is_enable_teach_mode()
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return false
  end
  local flag = obj:get_flag_int8(bo2.ePlayerFlagInt8_WarriorArenaRegist)
  if flag >= 240 then
    flag = flag - 240
  end
  local teach_mode = flag == 0 or flag == 1
  return teach_mode
end
function on_set_flag()
  local teach_mode = btn_teach_mode.check
  local chaos = btn_chaos.check
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return
  end
  local new_flag = 0
  local flag = obj:get_flag_int8(bo2.ePlayerFlagInt8_WarriorArenaRegist)
  local val = 0
  if flag >= 240 then
    val = 0
  end
  local val0 = 0
  local val1 = 1
  if chaos == true then
    val0 = 4
  else
    val0 = 0
  end
  if teach_mode == true then
    val1 = 0
  else
    val1 = 1
  end
  local new_flag = val0 + val1 + val
  if flag ~= new_flag then
    bo2.send_flag_int8(bo2.ePlayerFlagInt8_WarriorArenaRegist, new_flag)
  end
end
function set_teach_mode()
  on_set_flag()
end
function enable_chaos()
  on_set_flag()
end
function refresh_scn_data()
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return
  end
  local flag = obj:get_flag_int8(bo2.ePlayerFlagInt8_WarriorArenaRegist)
  if flag >= 240 then
    flag = flag - 240
  end
  btn_chaos.check = flag == 4 or flag == 5
  btn_teach_mode.check = flag == 0 or flag == 4
  local w_base_item = ui_warrior_arena.w_defender
  local protrait_url = ui_portrait.make_icon_uri(obj)
  local portrait = w_base_item:search(L("portrait"))
  portrait.image = protrait_url
  local career_panel = w_base_item:search(L("job"))
  local career_data = get_player_career_pic(obj)
  if career_data ~= nil and career_data.visible ~= nil and career_data.visible == true then
    career_panel.image = career_data.image
    career_panel.irect = career_data.irect
    career_panel.svar = career_data.svar
    career_panel.visible = true
  else
    career_panel.visible = false
  end
  local lb_name = w_base_item:search(L("lb_name"))
  lb_name.text = obj.name
  local iLevel = ui.safe_get_atb(bo2.eAtb_Level)
  local lb_level = w_base_item:search(L("lb_level"))
  lb_level.text = sys.format(L("Lv.%d"), iLevel)
  local mtf_data = {}
  mtf_data.total_match = obj:get_flag_int32(bo2.ePlayerFlagInt32_WarriorArena_TotalTimes)
  mtf_data.win_count = obj:get_flag_int32(bo2.ePlayerFlagInt32_WarriorArena_WinTimes)
  if 0 < mtf_data.total_match then
    mtf_data.win_rate = sys.format("%.1f", mtf_data.win_count / mtf_data.total_match * 100)
  else
    mtf_data.win_rate = 0
  end
  mtf_data.score = obj:get_flag_int32(bo2.ePlayerFlagInt32_XinshouScore)
  mtf_data.today_token = bo2.get_cd_real_token(50082)
  mtf_data.week_token = bo2.get_cd_real_token(50083)
  if 0 >= mtf_data.today_token or 0 >= mtf_data.week_token then
    btn_finish_arena.visible = true
    btn_regist_fight.visible = false
    if 0 >= mtf_data.week_token then
      btn_finish_arena.tip.text = ui.get_text("warrior_arena|btn_finish_arena_tip_week")
    else
      btn_finish_arena.tip.text = ui.get_text("warrior_arena|btn_finish_arena_tip")
    end
  else
    btn_regist_fight.visible = true
    btn_finish_arena.visible = false
  end
  local stk = sys.mtf_stack()
  desc_common_align(stk)
  stk:raw_push(ui_widget.merge_mtf(mtf_data, ui.get_text("warrior_arena|win_count")))
  stk_push_new_line(stk)
  stk:raw_push(ui_widget.merge_mtf(mtf_data, ui.get_text("warrior_arena|total_match")))
  stk_push_new_line(stk)
  stk:raw_push(ui_widget.merge_mtf(mtf_data, ui.get_text("warrior_arena|win_rate")))
  stk_push_new_line(stk)
  stk:raw_push(ui_widget.merge_mtf(mtf_data, ui.get_text("warrior_arena|today_token")))
  stk_push_new_line(stk)
  stk:raw_push(ui_widget.merge_mtf(mtf_data, ui.get_text("warrior_arena|week_token")))
  stk_push_new_line(stk)
  stk:raw_push(ui_widget.merge_mtf(mtf_data, ui.get_text("warrior_arena|self_score")))
  stk_push_new_line(stk)
  local rb_desc = w_base_item:search(L("rb_desc"))
  rb_desc.mtf = stk.text
  if mtf_data.score == 0 then
    anime_reg.visible = true
  else
    anime_reg.visible = false
  end
end
function on_mouse_select_data(w, msg, pos, wheel)
  if msg == ui.mouse_inner then
  elseif msg == ui.mouse_outer then
  elseif msg == ui.mouse_lbutton_click then
    select_mutex_item(w)
  elseif msg == ui.mouse_lbutton_dbl then
  end
end
function on_mouse_act_data(w, msg, pos, wheel)
  if msg == ui.mouse_inner then
  elseif msg == ui.mouse_outer then
  end
end
function on_tip_select_fighter(tip)
  local stk = sys.mtf_stack()
  local owner = tip.owner
  local function on_show_tip()
    ui_tool.ctip_show(owner, stk, stk_use)
  end
  if sys.check(owner) ~= true then
    return
  end
  local var = owner.var
  local excel_id = var:get(L("excel")).v_int
  local excel = bo2.gv_cavalier_championship_npc:find(excel_id)
  if sys.check(excel) ~= true then
    on_show_tip()
    return
  end
  local cha_list_data = bo2.gv_cha_list:find(excel.cha_list_id)
  if cha_list_data == nil then
    on_show_tip()
    return
  end
  local mtf = {}
  mtf.name = cha_list_data.name
  local fighter_data = get_fighter_data(cha_list_data)
  if fighter_data ~= nil then
    mtf.rank = fighter_data.rank
    mtf.title_id = fighter_data.title_id
    local title = bo2.gv_title_list:find(mtf.title_id)
    if title ~= nil then
      mtf.title = title._name
    end
  end
  stk:raw_push(L("<a+:mid>"))
  stk:raw_push(mtf.name)
  stk_push_new_line(stk)
  desc_common_align(stk)
  if mtf.title ~= nil then
    stk:raw_push(ui_widget.merge_mtf(mtf, ui.get_text("warrior_arena|title_name")))
    stk_push_new_line(stk)
  end
  if mtf.rank ~= nil then
    stk:raw_push(ui_widget.merge_mtf(mtf, ui.get_text("warrior_arena|fighter_rank")))
  end
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("warrior_arena|left_mouse"), ui_tool.cs_tip_color_operation)
  on_show_tip()
end
function on_tip_show_fighter(tip)
  local stk = sys.mtf_stack()
  local on_fill_data = function(stk, iAct, var)
    local act = get_act()
    if iAct > act then
      local push_text = ui_widget.merge_mtf({
        last_act = iAct - 1
      }, ui.get_text("warrior_arena|last_act_title"))
      ui_tool.ctip_push_text(stk, push_text, g_color_gray, ui_tool.cs_tip_a_add_l)
    elseif iAct < act then
      ui_tool.ctip_push_text(stk, ui.get_text("warrior_arena|has_win"), g_color_gray, ui_tool.cs_tip_a_add_l)
    else
      ui_tool.ctip_push_text(stk, ui.get_text("warrior_arena|has_invitation"), g_color_gray, ui_tool.cs_tip_a_add_l)
    end
    ui_tool.ctip_push_sep(stk)
    local mtf = update_act_fighter_info(iAct)
    if mtf == nil or mtf.tab_count == nil or mtf.tab_count <= 0 then
      return
    end
    if mtf.tab_count == 1 then
      stk:raw_push(ui_widget.merge_mtf(mtf, ui.get_text("warrior_arena|fighter_name")))
      stk_push_new_line(stk)
      if mtf.title ~= nil then
        stk:raw_push(ui_widget.merge_mtf(mtf, ui.get_text("warrior_arena|title_name")))
        stk_push_new_line(stk)
      end
      if mtf.rank ~= nil then
        stk:raw_push(ui_widget.merge_mtf(mtf, ui.get_text("warrior_arena|fighter_rank")))
      end
    end
  end
  local owner = tip.owner
  if sys.check(owner) then
    local var = owner.var
    local iAct = var:get(packet.key.fate_act, iAct).v_int
    local desc_title = ui_widget.merge_mtf({act = iAct}, ui.get_text("warrior_arena|tips_title"))
    ui_tool.ctip_make_title_ex(stk, desc_title, nil, ui_tool.cs_tip_a_add_m)
    stk_push_new_line(stk)
    local idx = owner.var:get(L("index")).v_int
    if idx == 0 then
      ui_tool.ctip_push_text(stk, ui.get_text("warrior_arena|default_tip_text"), g_color_gray, ui_tool.cs_tip_a_add_l)
    else
      on_fill_data(stk, iAct, var)
    end
  end
  ui_tool.ctip_show(owner, stk, stk_use)
end
function set_cell_common_size(cell, portrait, base)
  cell.dx = 50
  cell.dy = 50
  portrait.dx = 35
  portrait.dy = 35
  portrait.margin = ui.rect(0, 0, 0, 2)
  base.dx = 50
  base.dy = 50
end
function set_cell_big_size(cell, portrait, base)
  cell.dx = 78
  cell.dy = 78
  portrait.dx = 56
  portrait.dy = 56
  portrait.margin = ui.rect(0, 0, 1, 3)
  base.dx = 78
  base.dy = 78
end
function set_cell_data(cell, idx)
  if sys.check(cell) ~= true then
    return
  end
  if idx >= n_page_count then
    cell.visible = false
    return
  end
  cell.visible = true
  local close = cell:search(L("close"))
  close.visible = false
  local portrait = cell:search(L("portrait"))
  portrait.visible = false
  portrait.effect = ""
  local base = cell:search(L("base"))
  set_cell_common_size(cell, portrait, base)
  local iAct = idx + 1
  local iInvitationCount = get_fight_invitation()
  local function on_refresh_portrait()
    local act = get_act()
    local mtf = update_act_fighter_info(iAct)
    if mtf.table_count == 0 then
      return
    end
    portrait.image = mtf.uri
    portrait.visible = true
    local function set_cell_effect(is_close)
      portrait.effect = "gray"
      close.visible = is_close
    end
    if act == iAct then
      set_cell_big_size(cell, portrait, base)
    else
      set_cell_effect(act > iAct)
    end
  end
  cell.var:set(packet.key.fate_act, iAct)
  if iAct > iInvitationCount then
    cell.var:set(L("index"), 0)
    base.effect = "gray"
  else
    base.effect = ""
    cell.var:set(L("index"), 1)
    on_refresh_portrait()
  end
  ui_warrior_arena.div_act_count.parent:tune("view")
end
function update_page(page)
  local p_idx = math.floor(page.index / n_page_limit)
  local p_cnt = math.floor((page.count + n_page_limit - 1) / n_page_limit)
  ui_widget.ui_stepping.set_page(ui_warrior_arena.w_step, p_idx, p_cnt)
  local p_cur_begin = p_idx * n_page_limit
  local p_cur_end = (p_idx + 1) * n_page_limit
  local count = page.count - 1
  local idx = 0
  local page_count = n_page_limit - 1
  for i = 0, page_count do
    local cell_name = sys.format(L("%d"), i)
    idx = page.index + i
    local cell = div_act_count:search(cell_name)
    set_cell_data(cell, idx)
  end
end
function set_fighter_cell_data(cell, excel)
  local portrait = cell:search(L("portrait"))
  local base = cell:search(L("base"))
  local highlight = cell:search(L("highlight"))
  local lb_name = cell:search(L("lb_name"))
  local lb_star = cell:search(L("lb_star"))
  local function on_init_cell()
    portrait.visible = false
    portrait.effect = ""
    cell.visible = false
    lb_name.visible = false
    lb_star.visible = false
  end
  on_init_cell()
  if sys.check(excel) ~= true then
    highlight.visible = false
    return
  end
  cell.visible = true
  cell.var:set(L("excel"), excel.id)
  local cha_list_data = bo2.gv_cha_list:find(excel.cha_list_id)
  if cha_list_data == nil then
    return
  end
  local obj_por = {}
  obj_por.excel = cha_list_data
  local uri = ui_portrait.on_get_portrait_icon(obj_por, 0)
  portrait.image = uri
  portrait.visible = true
  lb_name.visible = true
  lb_name.text = cha_list_data.name
  lb_star.visible = true
  local stk = sys.mtf_stack()
  local star = 1
  if 0 < excel.server_rand then
    star = excel.server_rand
  end
  local s_text = sys.format(L("<a:mid><star:%d>"), star)
  stk:raw_push(s_text)
  lb_star.mtf = stk.text
end
function select_mutex_item(select_cell)
  local function on_cancel_all_highlight()
    for i = 0, n_cell_count - 1 do
      local cell_name = sys.format(L("%d"), i)
      local cell = div_select_count:search(cell_name)
      if sys.check(cell) then
        local highlight = cell:search(L("highlight"))
        highlight.visible = false
      end
    end
  end
  on_cancel_all_highlight()
  if sys.check(select_cell) then
    local highlight = select_cell:search(L("highlight"))
    highlight.visible = true
  end
end
function check_select()
  local select_only_one = false
  local selected_cell
  for i = 0, n_cell_count - 1 do
    local cell_name = sys.format(L("%d"), i)
    local cell = div_select_count:search(cell_name)
    if sys.check(cell) then
      local highlight = cell:search(L("highlight"))
      if highlight.visible == true then
        if cell.visible == false then
          return false
        end
        if select_only_one == false then
          selected_cell = cell
          select_only_one = true
        else
          return false
        end
      end
    end
  end
  return select_only_one, selected_cell
end
function update_select_highlight(excel_tab, tab_count)
  local rand = 0
  local val = 0
  for i = 0, tab_count - 1 do
    local c_val = excel_tab[i].server_rand
    if i == 0 or val > c_val then
      val = c_val
      rand = i
    end
  end
  local cell_name = sys.format(L("%d"), rand)
  local cell = div_select_count:search(cell_name)
  select_mutex_item(cell)
end
function update_select_data()
  local act = get_act()
  local excel_tab, tab_count = get_act_fighter(act)
  if tab_count <= 1 then
    return
  end
  for i = 0, n_cell_count - 1 do
    local cell_name = sys.format(L("%d"), i)
    local cell = div_select_count:search(cell_name)
    if i >= tab_count then
      set_fighter_cell_data(cell, nil)
    else
      set_fighter_cell_data(cell, excel_tab[i])
    end
  end
  local dx = 600 - (n_cell_count - tab_count) * 50
  div_select_count.dx = dx
  ui_warrior_arena.div_select_count:set_divide(tab_count, 1)
  ui_warrior_arena.div_select_count.parent:tune("view")
  update_select_highlight(excel_tab, tab_count)
end
function update_act_fighter_info(act)
  local mtf = {}
  local excel_tab, tab_count = get_act_fighter(act)
  mtf.tab_count = tab_count
  if tab_count == 0 then
    return mtf
  end
  local excel
  if tab_count ~= 1 then
    excel = get_searver_act_challenger(act)
  elseif tab_count == 1 then
    excel = excel_tab[0]
  end
  if sys.check(excel) ~= true then
    return mtf
  end
  mtf.tab_count = 1
  local cha_list_data = bo2.gv_cha_list:find(excel.cha_list_id)
  if cha_list_data == nil then
    return mtf
  end
  local obj_por = {}
  obj_por.excel = cha_list_data
  mtf.uri = ui_portrait.on_get_portrait_icon(obj_por, 0)
  mtf.name = cha_list_data.name
  local fighter_data = get_fighter_data(cha_list_data)
  if fighter_data ~= nil then
    mtf.rank = fighter_data.rank
    mtf.title_id = fighter_data.title_id
    local title = bo2.gv_title_list:find(mtf.title_id)
    if title ~= nil then
      mtf.title = title._name
    end
  end
  return mtf
end
function refresh_attacker_info()
  local w_base_item = ui_warrior_arena.w_attacker
  local career_panel = w_base_item:search(L("job"))
  local lb_name = w_base_item:search(L("lb_name"))
  local lb_level = w_base_item:search(L("lb_level"))
  local portrait = w_base_item:search(L("portrait"))
  local rb_desc = w_base_item:search(L("rb_desc"))
  local function on_init_attacker_info(vis)
    career_panel.visible = vis
    lb_name.visible = vis
    lb_level.visible = vis
    portrait.image = L("$icon/portrait/zj/0000.png")
    rb_desc.mtf = L("")
  end
  local act = get_act()
  local iInvitationCount = get_fight_invitation()
  if act > iInvitationCount then
    on_init_attacker_info(false)
    return
  end
  on_init_attacker_info(true)
  local mtf = update_act_fighter_info(act)
  if mtf == nil or mtf.tab_count == nil or mtf.tab_count <= 0 then
    return
  end
  if mtf.tab_count == 1 then
    career_panel.visible = false
    portrait.image = mtf.uri
    lb_name.text = mtf.name
    local iLevel = ui.safe_get_atb(bo2.eAtb_Level)
    lb_level.text = sys.format(L("Lv.%d"), iLevel)
    local stk = sys.mtf_stack()
    desc_common_align(stk)
    if mtf.title ~= nil then
      stk:raw_push(ui_widget.merge_mtf(mtf, ui.get_text("warrior_arena|title_name")))
      stk_push_new_line(stk)
    end
    if mtf.rank ~= nil then
      stk:raw_push(ui_widget.merge_mtf(mtf, ui.get_text("warrior_arena|fighter_rank")))
    end
    rb_desc.mtf = stk.text
  else
    career_panel.visible = false
    lb_name.text = ui.get_text("warrior_arena|unknow")
    lb_level.text = sys.format(L("Lv.%s"), ui.get_text("warrior_arena|level_unknow"))
    local stk = sys.mtf_stack()
    desc_common_align(stk)
    stk:raw_push(ui_widget.merge_mtf(mtf, ui.get_text("warrior_arena|may_selected")))
    rb_desc.mtf = stk.text
  end
end
function refresh_act_challenger_data(interval, refresh_type)
  local function on_refresh()
    if sys.check(bo2.scn) ~= true then
      return
    end
    if g_refresh_page == false then
      return
    end
    g_refresh_page = false
    local function refresh_step()
      local act = get_act()
      if act > n_page_limit then
        refresh_step_data(n_page_limit)
      else
        refresh_step_data(0)
      end
    end
    if g_refresh_table == nil then
      g_refresh_table = {}
      g_refresh_table[refresh_type_runtime] = {}
      g_refresh_table[refresh_type_all] = {}
      table.insert(g_refresh_table[refresh_type_runtime], refresh_step)
      table.insert(g_refresh_table[refresh_type_runtime], refresh_attacker_info)
      table.insert(g_refresh_table[refresh_type_all], refresh_step)
      table.insert(g_refresh_table[refresh_type_all], refresh_attacker_info)
    end
    for i, v in pairs(g_refresh_table[refresh_type]) do
      v()
    end
  end
  if interval == 1 then
    if g_refresh_page == true then
      return
    end
    g_refresh_page = true
    bo2.AddTimeEvent(25, on_refresh)
  else
    g_refresh_page = true
    on_refresh()
  end
end
function refresh_step_data(begin_index)
  local page = {index = begin_index, count = n_page_count}
  local function on_page_step(var)
    page.index = var.index * n_page_limit
    update_page(page)
  end
  ui_widget.ui_stepping.set_event(ui_warrior_arena.w_step, on_page_step)
  update_page(page)
end
function enable_timer()
  g_timer_second.suspended = false
  g_time_count = 5
  refresh_button_text()
  local on_time_set_visible = function()
    if sys.check(w_main_list) then
      w_main_list.visible = false
    end
  end
  bo2.AddTimeEvent(125, on_time_set_visible)
  local iAct = get_act()
  local mtf = update_act_fighter_info(iAct)
  if mtf ~= nil and mtf.tab_count ~= nil and mtf.tab_count == 1 then
    local text = ui_widget.merge_mtf(mtf, ui.get_text("warrior_arena|notify_text"))
    ui_tool.note_insert(text, "00FF00")
  end
end
function refresh_runtime_data(data)
  local state = data:get(packet.key.WarriorArena_State).v_int
  local act = data:get(packet.key.WarriorArena_Act).v_int
  local count = data:get(packet.key.WarriorArena_TimesCount).v_int
  if act <= 3 then
    if g_view_help_tip == false and act == 1 then
      local obj = bo2.player
      if sys.check(obj) then
        w_title_help.visible = true
        ui_warrior_arena.w_title_help.mtf = sys.format(L("<handson:0,6,,119>"))
        g_view_help_tip = true
      end
    end
    btn_teach_mode.visible = true
    btn_chaos.visible = false
  else
    btn_teach_mode.visible = false
    btn_chaos.visible = true
  end
  if g_record_data.state == bo2.eWarriorArenaState_Regist and state == bo2.eWarriorArenaState_WaitFight then
    enable_timer()
  end
  g_record_data.state = state
end
function refresh_static_data(data)
  local challenge = data:get(packet.key.WarriorArena_Challengers)
end
function get_searver_act_challenger(act)
  if act <= 3 then
    return nil
  end
  local tab = g_interface_data[bo2.eRequestModelType_StaticData]
  if tab ~= nil and tab.data ~= nil then
    local data = tab.data:get(packet.key.WarriorArena_Challengers)
    if data:has(act) then
      local excel_id = data:get(act).v_int
      local excel = bo2.gv_cavalier_championship_npc:find(excel_id)
      return excel
    end
  end
  return nil
end
function on_refresh_client_data(type, data)
  local tab = g_interface_data[type]
  if tab == nil then
    return
  end
  tab.data = data:get(type)
  if tab.data:has(packet.key.ui_request_id) then
    tab.request = tab.data[packet.key.ui_request_id]
  end
  if sys.check(tab.fun) then
    tab.fun(tab.data)
  end
end
function on_handle_data(cmd, data)
  if data:has(packet.key.flight) then
    ui_xinshou.enable_xinshou_button_flick(true)
    return
  end
  local refresh_base = {}
  refresh_base[1] = bo2.eRequestModelType_StaticData
  refresh_base[2] = bo2.eRequestModelType_RuntimeData
  local refresh_type = refresh_type_runtime
  for i = 1, 2 do
    local v = refresh_base[i]
    if v ~= nil and data:has(v) then
      if v == bo2.eRequestModelType_StaticData then
        refresh_type = refresh_type_all
      end
      on_refresh_client_data(v, data)
    end
  end
  refresh_act_challenger_data(0, refresh_type)
end
local g_enter_open = false
function on_self_enter()
  if g_last_player == nil or g_last_player ~= bo2.player then
    on_init()
    init_rank()
    g_refresh_page = false
    g_view_help_tip = false
  else
    ui_warrior_arena.w_main_list.visible = g_enter_open
    local scn_tab = {id_begin = 370, id_end = 377}
    local scn = bo2.scn
    local next_open = false
    if sys.check(scn) and scn.excel then
      local id = scn.excel.id
      if id >= scn_tab.id_begin and id <= scn_tab.id_end then
        next_open = true
      end
    end
    g_enter_open = next_open
  end
  g_last_player = bo2.player
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_warrior_arena.on_self_enter")
function get_act_fighter(act)
  local mask0 = 72000
  local mask1 = 172000
  local mask2 = 100
  local mask_act = 0
  local mask_per = 0
  local max_count = 99
  if act < 10 then
    mask_act = mask0
    mask_per = 100
  elseif act == 10 then
    mask_act = mask1
    mask_per = 0
  else
    return nil, 0
  end
  local npc_begin = mask_act + act * mask_per + 1
  local npc_end = mask_act + act * mask_per + max_count
  local excel_tab = {}
  local tab_count = 0
  for i = npc_begin, npc_end do
    local excel = bo2.gv_cavalier_championship_npc:find(i)
    if sys.check(excel) and excel.cha_list_id ~= 0 then
      excel_tab[tab_count] = excel
      tab_count = tab_count + 1
    else
      break
    end
  end
  return excel_tab, tab_count
end
function get_fight_invitation()
  local tab = g_interface_data[bo2.eRequestModelType_RuntimeData]
  if tab ~= nil and tab.data ~= nil then
    return tab.data:get(packet.key.WarriorArena_TimesCount).v_int
  end
  return 0
end
function get_act()
  local tab = g_interface_data[bo2.eRequestModelType_RuntimeData]
  if tab ~= nil and tab.data ~= nil then
    local act = tab.data:get(packet.key.WarriorArena_Act).v_int
    return act
  end
  return 1
end
function triggle_visible(fn, fn_faild)
  local c_flag = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_TeachSkillCareer)
  if c_flag == 0 then
    fn_faild()
    vis_c(fn)
  else
    fn()
  end
end
local sig_name = "ui_warrior_arena:on_handle_data"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Sociality_UIWarriorArenaData, on_handle_data, sig_name)
