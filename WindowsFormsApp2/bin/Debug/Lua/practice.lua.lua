local practice_type_table = bo2.gv_practice_type
local practice_time_table = bo2.gv_practice_time
local practice_item_table = bo2.gv_practice_item
local practice_exp_table = bo2.gv_guaji_award_exp
local refresh_cd = 10
local c_training_max = 280
local c_training_min = 240
local HasPracticeState = function()
  if bo2.is_cooldown_over(20131) == false then
    return true
  end
  return bo2.player ~= nil
end
local exp_rate_get = function(i)
  local x = bo2.gv_define:find(260 + i)
  if x == nil then
    return 1
  end
  return x.value.v_number
end
function on_init()
  for i = 0, practice_type_table.size - 1 do
    local practice_type = practice_type_table:get(i)
    local item = w_practice_list:item_append()
    item:load_style("$frame/practice/practice.xml", "practice_item")
    item:search("name").text = sys.format(ui.get_text("practice|type_name"), practice_type.name)
    item.svar = practice_type.id
  end
  ui_widget.ui_combo_box.clear(w_practice_time)
  for i = 0, practice_time_table.size - 1 do
    local time_type = practice_time_table:get(i)
    ui_widget.ui_combo_box.append(w_practice_time, {
      id = time_type.id,
      text = sys.format("%02d:%02d:00", time_type.time / 60, time_type.time % 60)
    })
    if i == 0 then
      ui_widget.ui_combo_box.select(w_practice_time, time_type.id)
    end
  end
end
function on_training_init(ctrl)
  local rate_item = {}
  w_training.svar.rate_item = rate_item
  for i = 0, bo2.gv_guaji_rate.size - 1 do
    local excel = bo2.gv_guaji_rate:get(i)
    local item = w_stat_list:item_append()
    item:load_style("$frame/practice/practice.xml", "rate_item")
    item:search("lb_name").text = i
    rate_item[excel] = item
    item.svar.rate_excel = excel
  end
end
local lb_set_value = function(lb, txt)
  lb:search("lb_value").text = txt
end
local lb_set_name = function(lb, txt)
  lb:search("lb_name").text = txt
end
function on_donate_tip(tip)
  local exp_data = w_training.svar.exp_data
  if exp_data == nil then
    return
  end
  local v_donate = exp_data[packet.key.donate_exp]
  if v_donate == nil then
    return
  end
  local stk = sys.mtf_stack()
  for i, k, v in vpairs(v_donate) do
    local rate_excel = bo2.gv_guaji_rate:find(v[packet.key.cmn_id])
    if i > 0 then
      stk:raw_push("\n")
    end
    stk:merge({
      u = sys.format("<u:%s>", v[packet.key.cha_name]),
      n = rate_excel.rate,
      d = rate_excel.donate,
      e = sys.format("<c+:FFCC22>%d<c->", v[packet.key.cmn_count])
    }, ui.get_text("practice|tip_exp_donate2"))
  end
  ui_widget.tip_make_view(tip.view, stk.text)
end
function on_rate_tip(tip)
  local exp_data = w_training.svar.exp_data
  if exp_data == nil then
    return
  end
  local v_rate = exp_data[packet.key.rate_exp]
  if v_rate == nil then
    return
  end
  local rate_excel = tip.owner:upsearch_type("ui_list_item").svar.rate_excel
  local v_sub = v_rate[rate_excel.id]
  if v_sub == nil then
    return
  end
  local stk = sys.mtf_stack()
  stk:merge({
    n = rate_excel.rate,
    c = v_sub[packet.key.cmn_count]
  }, ui.get_text("practice|tip_exp_rate_c"))
  if rate_excel.donate > 0 then
    stk:raw_push("\n")
    stk:merge({
      d = rate_excel.donate
    }, ui.get_text("practice|tip_exp_donate"))
  end
  stk:raw_push("\n")
  stk:merge({
    e = sys.format("<c+:FFCC22>%d<c->", v_sub[packet.key.cmn_exp])
  }, ui.get_text("practice|tip_exp_total"))
  ui_widget.tip_make_view(tip.view, stk.text)
end
local orig_info_size = ui.point(240, 600)
local function screen_info_update(info, txt)
  local view = info:search("view")
  view.container.visible = true
  info.size = orig_info_size
  info:apply_dock(true)
  info.visible = true
  info:search("rb_info").mtf = txt
  info:tune("rb_info")
  local sz = info.size
  view.container.visible = false
  view.origin = ui.point(sz.x * 0.5, sz.y * 0.5)
  view:reset()
  info.visible = true
  info.svar.tick = sys.tick()
end
function on_rate_info_timer(t)
  if sys.dtick(sys.tick(), t.owner.svar.tick) > 18000 then
    t.owner.visible = false
  end
end
function set_exp_add(lb, d)
  local view = lb:search("view")
  if view == nil then
    return
  end
  if d <= 0 then
    view.visible = false
    return
  end
  view.visible = true
  local t = view:search("lb_exp_add")
  t.text = sys.format("+%d", d)
  view:reset()
end
function training_tune()
  local dx = w_training.dx
  if w_stat_list.visible then
    if dx < c_training_max then
      local dy = w_training.dy
      local offset = w_training.offset
      w_training.size = ui.point(c_training_max, 600)
      w_training:tune_y("stat_list")
      local x = offset.x - (c_training_max - dx) * 0.5
      local y = offset.y + dy - w_training.dy
      w_training.offset = ui.point(x, y)
    else
      w_training:tune_y("stat_list")
    end
  elseif dx >= c_training_max then
    local dy = w_training.dy
    local offset = w_training.offset
    w_training.size = ui.point(c_training_min, 50)
    local x = offset.x + (dx - c_training_min) * 0.5
    local y = offset.y + dy - w_training.dy
    w_training.offset = ui.point(x, y)
  end
end
function training_update(data)
  local svar = w_training.svar
  local orig_data = svar.exp_data
  svar.exp_data = data
  local function exp_set(lb, key)
    local exp = data[key]
    if exp == nil then
      exp = 0
    end
    lb_set_value(lb, exp)
    local orig_exp = 0
    if orig_data ~= nil then
      orig_exp = orig_data[key]
      if orig_exp == nil then
        orig_exp = 0
      end
    end
    local d = exp - orig_exp
    set_exp_add(lb, d)
  end
  local total_time = data[packet.key.total_time]
  local time_cost = data[packet.key.action_time]
  if orig_data == nil or math.abs(sys.dtick(sys.tick(), svar.tick) / 1000 - time_cost) > 5 then
    svar.tick = sys.tick() - time_cost * 1000
    svar.span = total_time * 1000
    on_stat_timer()
  end
  local time_txt = sys.format("%d:%.2d:%.2d", time_cost / 3600, time_cost % 3600 / 60, time_cost % 60)
  lb_set_value(w_stat_time_total, time_txt)
  exp_set(w_stat_total_exp, packet.key.total_exp)
  exp_set(w_stat_base_exp, packet.key.cmn_exp)
  exp_set(w_stat_extra_exp, packet.key.extra_exp)
  local v_donate = data[packet.key.donate_exp]
  if v_donate ~= nil then
    w_stat_donate.visible = true
    local exp = 0
    for i, k, v in vpairs(v_donate) do
      exp = exp + v[packet.key.cmn_count]
    end
    lb_set_name(w_stat_donate, ui_widget.merge_mtf({
      n = v_donate.size
    }, ui.get_text("practice|exp_donate_c")))
    lb_set_value(w_stat_donate, exp)
  else
    w_stat_donate.visible = false
  end
  local v_rate = data[packet.key.rate_exp]
  for rate_excel, item in pairs(svar.rate_item) do
    local v_sub
    if v_rate ~= nil then
      v_sub = v_rate[rate_excel.id]
    end
    if v_sub ~= nil then
      item.visible = true
      item:search("lb_name").text = ui_widget.merge_mtf({
        n = rate_excel.rate,
        c = v_sub[packet.key.cmn_count]
      }, ui.get_text("practice|exp_rate2"))
      lb_set_value(item, v_sub[packet.key.cmn_exp])
    else
      item.visible = false
    end
  end
  local v_item = data[packet.key.item_list]
  local stk = sys.mtf_stack()
  stk:raw_push("<a:r>")
  if v_item ~= nil then
    for i = 0, v_item.size - 2, 2 do
      if i > 0 then
        stk:raw_push("\n")
      end
      stk:raw_format("<i:%d>x%d", v_item[i], v_item[i + 1])
    end
  else
    stk:push(ui.get_text("cross_line|no_rank"))
  end
  w_stat_item_list:search("lb_value").mtf = stk.text
  training_tune()
  for rate_x, item in pairs(svar.rate_item) do
    set_exp_add(item, 0)
  end
  set_exp_add(w_stat_donate, 0)
  local v_app = data[packet.key.append_data]
  if v_app == nil then
    return
  end
  data:erase(packet.key.append_data)
  local rate_info = rawget(_M, "w_rate_info")
  if not sys.check(rate_info) then
    rate_info = ui.create_control(ui_main.w_top, "panel")
    w_rate_info = rate_info
    rate_info:load_style("$frame/practice/practice.xml", "rate_info")
  end
  local stk = sys.mtf_stack()
  v_rate = v_app[packet.key.rate_exp]
  if v_rate ~= nil then
    local rate_excel = bo2.gv_guaji_rate:find(v_rate[packet.key.cmn_id])
    stk:raw_push("<a:m><c+:FFCC22>")
    stk:merge({
      n = rate_excel.rate
    }, ui.get_text("practice|exp_rate"))
    stk:raw_push("\n")
    if 0 < rate_excel.donate then
      stk:merge({
        n = rate_excel.donate
      }, ui.get_text("practice|exp_donate"))
      stk:raw_push("\n")
    end
    local exp = v_rate[packet.key.cmn_exp]
    stk:raw_format([[
<c-><img:$image/qbar/exp_rate.png*48,48><num:%d,48>
<num:%d,32,FFFF00>]], rate_excel.rate, exp)
    set_exp_add(svar.rate_item[rate_excel], exp)
  end
  v_donate = v_app[packet.key.donate_exp]
  if v_donate ~= nil then
    local t_exp = 0
    for i, k, v in vpairs(v_donate) do
      local rate_excel = bo2.gv_guaji_rate:find(v[packet.key.cmn_id])
      if 0 < stk.size then
        stk:raw_push([[


]])
      end
      stk:raw_push("<a:m><c+:FFCC22>")
      stk:merge({
        n = rate_excel.donate,
        u = sys.format("<u:%s>", v[packet.key.cha_name])
      }, ui.get_text("practice|exp_donate_from"))
      stk:raw_push("\n")
      local exp = v[packet.key.cmn_exp]
      stk:raw_format([[
<c-><img:$image/qbar/exp_donate.png*48,48><num:%d,48>
<num:%d,32,FFFF00>]], rate_excel.donate, exp)
      t_exp = t_exp + exp
    end
    set_exp_add(w_stat_donate, t_exp)
  end
  screen_info_update(rate_info, stk.text)
end
function on_training_setting(btn)
  local on_menu_select = function(item)
    local btn = item.list_item:search("btn_item")
    local id = item.id
    if id == "shutdown" then
      main:search("btn_autoshtdn").check = btn.check
      return
    end
    if id == "min" then
      local is_min = btn.check
      w_stat_list.visible = not is_min
      training_tune()
      return
    end
  end
  ui_tool.show_menu({
    items = {
      {
        text = ui.get_text("practice|chk_shutdown"),
        id = "shutdown",
        check = main:search("btn_autoshtdn").check
      },
      {
        text = ui.get_text("practice|chk_min_window"),
        id = "min",
        check = not w_stat_list.visible
      }
    },
    popup = "y1x1",
    source = btn,
    event = on_menu_select,
    auto_size = true
  })
end
function on_stat_timer()
  local scn = bo2.scn
  if scn ~= nil and scn.excel.id ~= 1200 then
    w_training.visible = false
    return
  end
  local svar = w_training.svar
  local d = sys.dtick(sys.tick(), svar.tick)
  local s = svar.span
  if s == nil then
    return
  end
  if d > s then
    d = s
  end
  d = math.floor((s - d + 500) / 1000)
  local txt = sys.format("%d:%.2d:%.2d", d / 3600, d % 3600 / 60, d % 60)
  lb_set_value(w_stat_time_remain, txt)
end
function open_practice(full_id_list)
  main.visible = true
  main:search("btn_begin").enable = false
  main:search("title").text = ui.get_text("practice|welcome")
  main:search("des").mtf = ui.get_text("practice|welcome_des")
  w_practice_list:clear_selection()
  local cnt = w_practice_list.item_count
  for i = 0, cnt - 1 do
    local item = w_practice_list:item_get(i)
    local num_detail = full_id_list[item.svar]
    if num_detail ~= nil then
      local cur_num = num_detail:get(L("cur_num")).v_int
      local max_num = num_detail:get(L("max_num")).v_int
      local label_num = item:search("count")
      if cur_num == max_num then
        label_num.color = ui.make_color("FF0000")
      else
        label_num.color = ui.make_color("00FF00")
      end
      label_num.svar = cur_num == max_num
      label_num.text = sys.format(L("(%d/%d)"), cur_num, max_num)
    end
  end
  local player_lv = bo2.player:get_atb(bo2.eAtb_Level)
  local exp_excel = practice_exp_table:find(player_lv)
  local stk = sys.mtf_stack()
  stk:push(ui.get_text("practice|exp_base"))
  stk:raw_format("%d\n", exp_excel.exp * exp_rate_get(0) * 180)
  for i = 0, practice_item_table.size - 1 do
    local x = practice_item_table:get(i)
    local state = x.buff_id
    if state > 0 then
      for s = 1, 4 do
        if state == exp_excel["sp_state_id_" .. s] then
          stk:merge({
            item = sys.format("<i:%d>", x.id)
          }, ui.get_text("practice|exp_item"))
          stk:raw_format("%d\n", exp_excel["sp_exp_" .. s] * exp_rate_get(1) * 180)
          break
        end
      end
    end
  end
  if 1 < practice_item_table.size then
    stk:raw_push("<c+:FF0000>")
    stk:push(ui.get_text("practice|exp_warning"))
    stk:raw_push("<c->")
  end
  main:search("exp_des").mtf = stk.text
end
function practice_item_update(item)
  local fig = item:search("fig_highlight")
  local color
  if item.inner_hover then
    color = "659BFF"
  elseif item.selected then
    color = "FFFCCC"
  else
    fig.visible = false
    return
  end
  fig.visible = true
  fig.color = ui.make_color(color)
end
function on_practice_item_sel(item, sel)
  practice_item_update(item)
  if not sel then
    return
  end
  main:search("btn_begin").enable = not item:search("count").svar
  local practice_type = practice_type_table:find(item.svar)
  if practice_type ~= nil then
    main:search("title").text = practice_type.name
    main:search("des").mtf = practice_type.des
  end
end
function on_practice_item_mouse(item, msg)
  if msg ~= ui.mouse_enter and msg ~= ui.mouse_leave and msg ~= ui.mouse_inner and msg ~= ui.mouse_outer then
    return
  end
  practice_item_update(item)
end
function on_refresh_btn(btn)
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_PracticeScn_RefreshPlayerNum, v)
  btn.enable = false
  refresh_cd = 10
  btn.text = sys.format("%s(%d)", ui.get_text("practice|refresh"), refresh_cd)
  g_timer_countdown.suspended = false
end
function on_refresh_btn_countdown(timer)
  refresh_cd = refresh_cd - 1
  if refresh_cd < 0 then
    main:search("refresh").enable = true
    main:search("refresh").text = ui.get_text("practice|refresh")
    timer.suspended = true
  else
    main:search("refresh").text = sys.format("%s(%d)", ui.get_text("practice|refresh"), refresh_cd)
  end
end
function on_begin_practice_btn(btn)
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/practice/practice.xml",
    style_name = "use_item_msg_box",
    callback = function(msg)
      if msg.result == 0 then
        return
      end
      send_practice(msg)
    end,
    modal = true
  })
end
function on_end_train_exit_click(btn)
  local data = ui_widget.ui_msg_box.get_data(btn)
  if data == nil then
    return
  end
  data.result = 1
  ui_widget.ui_msg_box.invoke(data)
end
function on_end_train_recovery_click(btn)
  local data = ui_widget.ui_msg_box.get_data(btn)
  if data == nil then
    return
  end
  data.result = 2
  ui_widget.ui_msg_box.invoke(data)
end
function on_end_train_btn(btn)
  local items = item_recovery()
  if #items == 0 then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_PracticeScn_EndPractice, v)
    return
  end
  local stk = sys.mtf_stack()
  stk:push(ui.get_text("practice|recovery_note"))
  stk:raw_push("<a:m>")
  for n, v in ipairs(items) do
    stk:raw_format([[

<i:%d>x%d]], v.id, v.count)
  end
  ui_widget.ui_msg_box.show_common({
    text = stk.text,
    style_uri = "$frame/practice/practice.xml",
    style_name = "end_train_msg_box",
    modal = true,
    callback = function(msg)
      if msg.result == 0 then
        return
      end
      local v = sys.variant()
      if msg.result == 2 then
        v:set("recovery", 1)
      end
      bo2.send_variant(packet.eCTS_PracticeScn_EndPractice, v)
    end
  })
end
function on_close_train_btn(btn)
  w_training.visible = false
end
function add_train_timebar(left_time)
  del_train_timebar()
  local time_id = ui_widget.ui_combo_box.selected(w_practice_time).id
  local time_type = practice_time_table:find(time_id)
  if time_type == nil then
    return
  end
  local insert_sub = {}
  if left_time == 0 then
    insert_sub.time = time_type.time * 60
  else
    insert_sub.time = left_time
  end
  insert_sub.name = ui.get_text("practice|practice_time")
  insert_sub.close = true
  insert_sub.callback = nil
  insert_sub.icon = L("$image/qbar/timer_bar_ptime.png|0,0,64,64*20,20")
  ui_reciprocal.add_reciproca("training", insert_sub)
end
function del_train_timebar()
  ui_reciprocal.del_reciproca("training")
end
function on_recovery_click(btn)
  local items = item_recovery()
  if #items == 0 then
    ui_widget.ui_msg_box.show_common({
      text = ui.get_text("practice|recovery_no"),
      btn_cancel = false,
      modal = true
    })
    return
  end
  local stk = sys.mtf_stack()
  stk:push(ui.get_text("practice|recovery_note"))
  stk:raw_push("<a:m>")
  for n, v in ipairs(items) do
    stk:raw_format([[

<i:%d>x%d]], v.id, v.count)
  end
  ui_widget.ui_msg_box.show_common({
    text = stk.text,
    modal = true,
    callback = function(msg)
      if msg.result == 0 then
        return
      end
      local v = sys.variant()
      v:set("recovery", 1)
      bo2.send_variant(packet.eCTS_PracticeScn_EndPractice, v)
    end
  })
end
function send_practice(msg)
  local cur_selected = w_practice_list.item_sel
  if cur_selected == nil then
    return
  end
  local v = sys.variant()
  v[packet.key.practice_typeid] = cur_selected.svar
  v[packet.key.practice_time] = ui_widget.ui_combo_box.selected(w_practice_time).id
  local items = sys.variant()
  local choose_list = msg.window:search("choose_list")
  for i = 0, choose_list.item_count - 1 do
    local item = choose_list:item_get(i)
    local cd = item.svar.choose_data
    local count = cd.count
    if count > 0 then
      items:set(cd.card.excel.id, count)
    end
  end
  v[packet.key.itemdata_all] = items
  bo2.send_variant(packet.eCTS_PracticeScn_BeginPractice, v)
end
function choose_list_update(choose_list)
  local exp_excel = practice_exp_table:find(bo2.player:get_atb(bo2.eAtb_Level))
  local prev_count = 0
  local exp_add = 0
  for i = choose_list.item_count - 1, 0, -1 do
    local cd = choose_list:item_get(i).svar.choose_data
    local excel = cd.card.excel
    local count = cd.count
    cd.lb_count.text = sys.format("%d/%d", count, ui.item_get_count(excel.id, true))
    count = count + cd.state_count
    local exp = 0
    local per = 100
    if count > 0 then
      local x = practice_item_table:find(excel.id)
      local state = x.buff_id
      for s = 1, 4 do
        if state == exp_excel["sp_state_id_" .. s] then
          local dc = prev_count
          if prev_count > count then
            dc = count
          end
          per = math.floor((count - dc * 0.5) * 100 / count)
          exp = exp_excel["sp_exp_" .. s] * 180 * (count - dc * 0.5)
          exp_add = exp_add + exp
          break
        end
      end
    end
    cd.btn_quick_buy.visible = 0 < ui_supermarket2.shelf_quick_buy_id(excel.id)
    if prev_count < count then
      prev_count = count
    end
    cd.lb_add_exp.text = ui_widget.merge_mtf({exp = exp}, ui.get_text("practice|exp_item3"))
    local st = cd.lb_add_exp_state
    if count > 0 then
      st.visible = true
      st.text = sys.format("%d%%", per)
      if per == 100 then
        st.color = ui.make_color("00FF00")
        st.tip.text = ui.get_text("practice|exp_full")
      else
        st.color = ui.make_color("FF0000")
        st.tip.text = ui.get_text("practice|exp_part")
      end
    else
      st.visible = false
    end
    local sc = cd.state_count
    local lb_sc = cd.lb_state_count
    if sc > 0 then
      lb_sc.visible = true
      lb_sc.text = sys.format(L("+%d"), sc)
    else
      lb_sc.visible = false
    end
  end
  local exp_base = exp_excel.exp * 180 * practice_hours()
  local rb_exp = choose_list.topper:search("rb_exp")
  rb_exp.mtf = ui_widget.merge_mtf({
    exp_base = exp_base,
    exp_add = exp_add,
    exp = exp_base + exp_add
  }, ui.get_text("practice|exp_compute"))
end
function on_state_count_tip(tip)
  local list_item = tip.owner:upsearch_type("ui_list_item")
  local cd = list_item.svar.choose_data
  local txt = ui_widget.merge_mtf({
    s = cd.state_name,
    i = sys.format("<i:%d>x%d", cd.card.excel.id, cd.state_count)
  }, ui.get_text("practice|recovery_count"))
  ui_widget.tip_make_view(tip.view, txt)
end
function on_select_item_visible(ctrl, vis)
  if not vis then
    return
  end
  ctrl:apply_dock(true)
  local rb_desc = ctrl:search("rb_desc")
  rb_desc:update()
  rb_desc.dy = rb_desc.extent.y
  local choose_list = ctrl:search("choose_list")
  for i = 0, practice_item_table.size - 1 do
    local pi = practice_item_table:get(i)
    if 0 < pi.buff_id then
      local item = choose_list:item_append()
      item:load_style("$frame/practice/practice.xml", "choose_item")
      local card = item:search("card")
      local lb_name = item:search("lb_name")
      local cd = {
        card = card,
        lb_name = lb_name,
        lb_count = item:search("lb_count"),
        lb_add_exp = item:search("lb_add_exp"),
        lb_add_exp_state = item:search("lb_add_exp_state"),
        lb_state_count = item:search("lb_state_count"),
        btn_quick_buy = item:search("quick_buy"),
        count = 0
      }
      item.svar.choose_data = cd
      card.excel_id = pi.id
      local excel = card.excel
      lb_name.text = excel.name
      lb_name.color = ui.make_color(excel.plootlevel_star.color)
      local state = ui.find_state_by_id(bo2.player.sel_handle, pi.buff_id)
      if state ~= nil then
        local d, h = state:get_remain_time()
        cd.state_count = d * 24 + h
        cd.state_name = state.excel.name
      else
        cd.state_count = 0
      end
    end
  end
  choose_list_update(choose_list)
  ctrl:tune_y("choose_list")
end
function practice_hours()
  local cmax = practice_time_table:find(ui_widget.ui_combo_box.selected(w_practice_time).id).time
  cmax = math.floor((cmax + 59) / 60)
  return cmax
end
function item_recovery()
  local exp_excel = practice_exp_table:find(bo2.player:get_atb(bo2.eAtb_Level))
  local item_prev = 0
  local items = {}
  for i = practice_item_table.size - 1, 0, -1 do
    local pi = practice_item_table:get(i)
    local state_id = pi.buff_id
    if state_id > 0 then
      local state = ui.find_state_by_id(bo2.player.sel_handle, state_id)
      local count = 0
      if item_prev > 0 then
        for s = 1, 3 do
          if state_id == exp_excel["sp_state_id_" .. s] then
            local fac = exp_excel["sp_exp_" .. s + 1] / exp_excel["sp_exp_" .. s]
            if fac > 4 then
              fac = 4
            end
            count = item_prev * fac
            break
          end
        end
      end
      if state ~= nil then
        local d, h, m, s = state:get_remain_time()
        count = count + d * 24 + h + m / 60 + s / 3600
      end
      if count >= 1 then
        local t = math.floor(count)
        item_prev = count - t
        table.insert(items, {
          id = pi.id,
          count = t
        })
      end
    end
  end
  return items
end
function on_item_count(btn)
  local list_item = btn:upsearch_type("ui_list_item")
  local cd = list_item.svar.choose_data
  local item_excel = cd.card.excel
  if bo2.player:get_atb(bo2.eAtb_Level) < item_excel.reqlevel then
    ui_tool.note_insert(ui_widget.merge_mtf({
      level = item_excel.reqlevel
    }, bo2.gv_text:find(1547).text), "ffffff00")
    return
  end
  local excel_id = item_excel.id
  local total = ui.item_get_count(excel_id, true)
  local cmax = practice_hours()
  cmax = cmax - cd.state_count
  if cmax < 0 then
    cmax = 0
  end
  if total < cmax then
    cmax = total
  end
  local count = cd.count
  if btn.name == L("plus") then
    count = count + 1
  elseif btn.name == L("minus") then
    count = count - 1
  else
    count = cmax
  end
  if count < 0 then
    count = 0
  elseif cmax < count then
    count = cmax
    ui_tool.note_insert(ui_widget.merge_mtf({item_id = excel_id, count = count}, ui.get_text("practice|limit_use")), "ffffff00")
  end
  cd.count = count
  choose_list_update(list_item.view)
end
function on_practice_directly_btn(btn)
  local data = ui_widget.ui_msg_box.get_data(btn)
  if data == nil then
    return
  end
  data.result = 2
  ui_widget.ui_msg_box.invoke(data)
end
function on_purchase_item_btn(btn)
  local data = ui_widget.ui_msg_box.get_data(btn)
  if data == nil then
    return
  end
  data.result = 0
  ui_widget.ui_msg_box.invoke(data)
  cd = btn:upsearch_type("ui_list_item").svar.choose_data
  ui_supermarket2.shelf_quick_buy(w_quick_buy_btn, cd.card.excel.id)
end
function train_prepare(is_done)
  w_stat_list.visible = true
  w_stat_time_total.visible = is_done
  w_btn_training_close.visible = is_done
  w_stat_time_remain.visible = not is_done
  w_btn_training_menu.visible = not is_done
  w_btn_training_end.visible = not is_done
  w_training.visible = true
  if is_done then
    w_training.dock = "pin_xy"
  else
    w_training.dock = "pin_y2"
  end
end
function on_player_train_flag(obj, ft, idx)
  local v = obj:get_flag_objmem(idx)
  if v == 1 then
    train_prepare(false)
    w_training.svar.exp_data = nil
    local d = sys.variant()
    d[packet.key.action_time] = 0
    local time_type = practice_time_table:find(ui_widget.ui_combo_box.selected(w_practice_time).id)
    d[packet.key.total_time] = time_type.time * 60
    training_update(d)
    main.visible = false
    add_train_timebar(0)
  else
    del_train_timebar()
  end
end
function on_player_enter_scn(obj)
  obj:insert_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_Training, "ui_practice.on_player_train_flag", "ui_practice:on_player_train_flag")
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_player_enter_scn, "ui_practice:on_player_enter_scn")
