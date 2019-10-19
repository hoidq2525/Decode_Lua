local text_abstain = 88035
vote_info = {}
local close_event = false
local init_vote_info = function(data)
  vote_info.voteid = data:get(packet.key.vote_id).v_string
  vote_info.invitiator = data:get(packet.key.vote_invitiator).v_string
  vote_info.textstart = data:get(packet.key.vote_textstart).v_int
  vote_info.optcount = data:get(packet.key.vote_optcount).v_int
  vote_info.starttime = data:get(packet.key.vote_starttime).v_number
  vote_info.time = data:get(packet.key.vote_time).v_int
  local vote_detail = {}
  vote_detail[-1] = 0
  for i = 1, vote_info.optcount do
    vote_detail[i] = 0
  end
  vote_info.vote_detail = vote_detail
  vote_info.has_voted = false
  vote_info.over = false
  local reason = data:get(packet.key.vote_reasonid).v_int
  if 0 ~= reason then
    reason = bo2.gv_text:find(reason).text
  else
    reason = data:get(packet.key.vote_reason).v_string
  end
  vote_info.reason = reason
end
local update_vote_detail = function(option)
  local vote_detail = vote_info.vote_detail
  if nil == option then
    for i = 1, vote_info.optcount do
      option_panel:item_get(i - 1):search("count_lb").text = sys.format("%d", vote_detail[i])
    end
    option_panel:item_get(vote_info.optcount):search("count_lb").text = sys.format("%d", vote_detail[-1])
  elseif -1 == option then
    option_panel:item_get(vote_info.optcount):search("count_lb").text = sys.format("%d", vote_detail[-1])
  elseif option > 0 then
    option_panel:item_get(option - 1):search("count_lb").text = sys.format("%d", vote_detail[option])
  end
end
local function show_vote_panel()
  ui_vote_main.visible = true
  local svar = option_panel.svar
  if svar.dock_done == nil then
    svar.dock_done = 1
    ui_vote_main:apply_dock(true)
  end
  local v = sys.variant()
  v:set("player", vote_info.invitiator)
  v:set("reason", vote_info.reason)
  desc_text.mtf = sys.mtf_merge(v, ui.get_text("vote|invitiate"))
  option_panel:item_clear()
  for i = 0, vote_info.optcount - 1 do
    local item = option_panel:item_append()
    item:load_style("$frame/vote/vote.xml", "option_item")
    item:search("option_btn").text = bo2.gv_text:find(vote_info.textstart + i).text
    item:search("option_btn").var:set(1, i + 1)
    option_panel:item_get(i):tune_y("lb_option_btn")
  end
  local item = option_panel:item_append()
  item:load_style("$frame/vote/vote.xml", "option_item")
  item:search("option_btn").text = bo2.gv_text:find(text_abstain).text
  item:search("option_btn").var:set(1, -1)
  option_panel:item_get(vote_info.optcount):tune("lb_option_btn")
  lb_time.text = sys.format(ui.get_text("vote|vote_time"), vote_info.time)
  update_vote_detail()
  vote_timer.suspended = false
end
function on_vote_start(data)
  if false ~= close_event then
    bo2.RemoveTimeEvent(close_event)
    close_event = false
  end
  init_vote_info(data)
  show_vote_panel()
end
function on_vote_sync(data)
  local option = data:get(packet.key.vote_option).v_int
  local count = data:get(packet.key.vote_votecount).v_int
  vote_info.vote_detail[option] = vote_info.vote_detail[option] + count
  update_vote_detail(option)
end
local close_main = function()
  ui_vote_main.visible = false
end
function on_vote_end(data)
  vote_info.time = 30
  vote_info.has_voted = true
  vote_info.over = true
  vote_timer.suspended = false
  ui_vote_main.visible = true
  close_event = bo2.AddTimeEvent(vote_info.time * 25, close_main)
end
function on_vote_reload(data)
  on_vote_start(data)
  local has_voted = data:get(packet.key.vote_hasvoted).v_int
  if 1 == has_voted then
    vote_info.has_voted = true
  end
  local try_sync_time = function()
    bo2.send_variant(packet.eCTS_Vote_Sycntime)
  end
  bo2.AddTimeEvent(5, try_sync_time)
end
function on_sync_time(data)
  vote_info.time = data:get(packet.key.vote_time).v_int
end
function on_option_click(btn)
  if vote_info.has_voted then
    return
  end
  btn.parent:search("fig_highlight2").visible = true
  btn.parent:search("fig_highlight").visible = false
  vote_info.has_voted = true
  local opt = btn.var:get(1).v_int
  local v = sys.variant()
  v:set(packet.key.vote_id, vote_info.voteid)
  v:set(packet.key.vote_option, opt)
  bo2.send_variant(packet.eCTS_Vote_Vote, v)
end
function on_timer()
  local time = vote_info.time
  time = time - 1
  vote_info.time = time
  if vote_info.over then
    lb_time.text = sys.format(ui.get_text("vote|close_time"), vote_info.time)
  else
    lb_time.text = sys.format(ui.get_text("vote|vote_time"), vote_info.time)
  end
  if time <= 0 then
    vote_info.has_voted = true
    vote_info.over = true
    vote_timer.suspended = true
    lb_time.text = ""
  end
end
function update_highlight(item)
  item:search("fig_highlight").visible = item.inner_hover and not vote_info.has_voted
end
function on_cmn_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    update_highlight(item)
  end
end
function test()
  local v = sys.variant()
  v:set(packet.key.vote_reason, "there is no reason")
  v:set(packet.key.vote_scope, bo2.eVoteScope_Group)
  v:set(packet.key.vote_textstart, 88036)
  v:set(packet.key.vote_optcount, 2)
  v:set(packet.key.vote_time, 60)
  bo2.send_variant(packet.eCTS_Vote_Initiate, v)
end
function test2()
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_Battle_Surrender, v)
end
