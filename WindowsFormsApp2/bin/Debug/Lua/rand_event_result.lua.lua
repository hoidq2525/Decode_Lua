local g_gread = 1
local g_score = 0
local g_comp_score = 0
local g_event_score = 0
local g_complete = 0
local timer_progress_step = 0
local timer_pause_step = 0
local timer_stamp_step = 0
local timer_gread_step = 0
local g_success_count = 0
local GetStateDetail = ui_rand_event.GetStateDetail
function on_event_result(data)
  g_gread = data:get("grade").v_int
  g_score = data:get("score").v_int
  g_comp_score = data:get("comp_score").v_int
  g_event_score = g_score - g_comp_score
  g_complete = data:get("complete").v_int
  rand_event_result_wnd.visible = true
end
function on_result_no_event(data)
  g_gread = data:get("grade").v_int
  g_score = data:get("score").v_int
  g_comp_score = data:get("comp_score").v_int
  g_event_score = g_score - g_comp_score
  g_complete = data:get("complete").v_int
  on_btn_click()
end
function on_rand_event_result_visible(panel, bool)
  if bool then
    update_ui()
    g_timer.suspended = false
    gread_pic.dx = 256
    gread_pic.dy = 256
    rand_event_result_wnd:search("progress_inner").dx = 0
    for i = 1, 6 do
      local item = rand_event_result_wnd:search("item" .. i)
      local stamp = item:search("stamp")
      stamp.visible = false
      stamp.dx = 65
      stamp.dy = 34
    end
  else
    g_event_mgr = nil
    g_event_final_idx = nil
    g_success_count = 0
    g_complete = 0
    timer_progress_step = 0
    timer_pause_step = 0
    timer_stamp_step = 0
    timer_gread_step = 0
  end
  ui_widget.on_leavescn_stk_visible(panel, bool)
end
function update_ui()
  g_event_mgr = ui_rand_event.g_event_mgr
  if nil == g_event_mgr then
    return
  end
  gread_pic:search("gp").image = SHARED(sys.format("$image/rand_event/%d.png", g_gread))
  gread_pic.visible = false
  identify_event(g_event_mgr.event)
  local info_panel = rand_event_result_wnd:search("info_panel")
  local money, moneyb, exp, item, item_type
  if nil ~= info_panel then
    money, moneyb, exp, item, item_type = update_info_panel(info_panel)
  end
  local total_panel = rand_event_result_wnd:search("total_panel")
  if nil ~= total_panel then
    update_total_panel(total_panel, money, moneyb, exp, item, item_type)
  end
end
function on_btn_click(btn)
  ui_scncopy.open_lottory(g_gread)
  rand_event_result_wnd.visible = false
end
function identify_event(event_t)
  if nil == g_event_final_idx then
    g_event_final_idx = {}
  end
  local idx = 1
  for i, _ in pairs(event_t) do
    g_event_final_idx[idx] = i
    idx = idx + 1
  end
  local function sort_help(t1, t2)
    local info1 = event_t[t1]
    local info2 = event_t[t2]
    local _, bs1, _ = GetStateDetail(info1.state)
    local _, bs2, _ = GetStateDetail(info2.state)
    if bs1 == bs2 then
      if info1.score == info2.score then
        return info1.eventID < info2.eventID
      else
        return info1.score > info2.score
      end
    else
      return bs1
    end
  end
  table.sort(g_event_final_idx, sort_help)
  for i, v in pairs(g_event_final_idx) do
    event_t[v].idx = i
    local _, bs, _ = GetStateDetail(event_t[v].state)
    if bs then
      g_success_count = g_success_count + 1
    end
  end
end
function update_info_panel(info_panel)
  local money = 0
  local moneyb = 0
  local exp = 0
  local item = 0
  local item_type
  for _, v in pairs(g_event_mgr.event) do
    local _, bs, _ = GetStateDetail(v.state)
    local item_name = "item" .. v.idx
    local event_item = info_panel:search(item_name)
    if nil ~= event_item then
      if 1 == v.money_type then
        moneyb = moneyb + (bs and v.money_base + v.money_level or 0)
      else
        money = money + (bs and v.money_base + v.money_level or 0)
      end
      exp = exp + (bs and v.exp_base + v.exp_level or 0)
      event_item:search("event_name").text = v.name
      event_item:search("rich_exp").mtf = bs and sys.format("<a:r>%d", v.exp_base + v.exp_level) or "<a:r>0"
      event_item:search("money_label").money = bs and v.money_base + v.money_level or 0
      event_item:search("money_label").bounded = 1 == v.money_type
      local item_line = bo2.gv_item_list:find(v.item_type)
      if nil ~= item_line then
        item_type = v.item_type
        item = item + (bs and tonumber(tostring(v.item_count)) or 0)
        local image_uri = sys.format("$icon/item/%s.png|0,0,64,64*20,20", tostring(item_line.icon))
        local item_mtf = sys.format("<a:r><img:%s> x", image_uri)
        event_item:search("icon_item").mtf = item_mtf
        event_item:search("rich_item").mtf = sys.format("<a:l>%s", bs and v.item_count or "0")
      end
      event_item.visible = true
    end
  end
  return money, moneyb, exp, item, item_type
end
function update_total_panel(total_panel, money, moneyb, exp, item, item_type)
  total_panel:search("event_name").text = ui.get_text("scncopy|total_award")
  total_panel:search("rich_exp").mtf = sys.format("<a:r>%d", exp)
  total_panel:search("money_label").money = money
  total_panel:search("money_label_b").money = moneyb
  total_panel.visible = true
end
function on_timer()
  if not progress_animation() then
    return
  end
  if not pause_animation() then
    return
  end
  if not stamp_animation() then
    return
  end
  if not gread_animation() then
    return
  end
  lty_btn.enable = true
  g_timer.suspended = true
end
function progress_animation()
  if timer_progress_step >= g_complete then
    return true
  end
  timer_progress_step = timer_progress_step + 1
  rand_event_result_wnd:search("completion_figure").text = sys.format("%d%%", timer_progress_step)
  rand_event_result_wnd:search("progress_inner").dx = 2.69 * timer_progress_step
  total_score_lb.text = ui.get_text("scncopy|scncopy_total_score") .. math.floor(g_comp_score * timer_progress_step / g_complete)
  return timer_progress_step >= g_complete and true or false
end
function pause_animation()
  if timer_pause_step >= 30 then
    return true
  end
  timer_pause_step = timer_pause_step + 1
  local a = math.abs(15 - timer_pause_step)
  if a <= 15 then
    total_score_lb.color = ui.make_argb(string.format("%x%xdd7f19", a, a))
  end
  return timer_pause_step >= 30 and true or false
end
function gread_animation()
  if timer_gread_step >= 128 then
    return true
  end
  gread_pic.visible = true
  total_score_lb.visible = true
  local step = 8
  timer_gread_step = timer_gread_step + step
  gread_pic.dx = gread_pic.dx - step
  gread_pic.dy = gread_pic.dy - step
  local d = timer_gread_step / 2
  gread_pic.margin = ui.rect(d, d, d, d)
  return timer_gread_step >= 128 and true or false
end
function stamp_animation()
  if timer_stamp_step >= 12 * g_success_count then
    return true
  end
  timer_stamp_step = timer_stamp_step + 1
  local idx = math.floor((timer_stamp_step - 1) / 12) + 1
  local item = rand_event_result_wnd:search("item" .. idx)
  local stamp = item:search("stamp")
  stamp.visible = true
  stamp.dx = stamp.dx - timer_stamp_step % 2
  stamp.dy = stamp.dy - timer_stamp_step % 2
  total_score_lb.text = ui.get_text("scncopy|scncopy_total_score") .. math.floor(g_comp_score + g_event_score * timer_stamp_step / (12 * g_success_count))
  return timer_stamp_step >= 12 * g_success_count and true or false
end
