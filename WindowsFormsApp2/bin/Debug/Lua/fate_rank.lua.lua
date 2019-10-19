local n_page_limit = 10
local g_rank_data = {}
function on_init_rank_data()
  g_rank_data = {}
  page_today = {
    index = 0,
    count = 50,
    key = bo2.eFateRankDataType_Today
  }
  page_yesterday = {
    index = 0,
    count = 50,
    key = bo2.eFateRankDataType_History
  }
end
on_init_rank_data()
function on_click_view_rank()
  ui_fate.w_main_rank.visible = not ui_fate.w_main_rank.visible
end
function on_flash_fate_rank()
  update_step()
end
function set_cell(cell, page, id, data)
  if id > page.count or data == nil or data:has(packet.key.cha_name) ~= true then
    cell.visible = false
    return
  end
  cell.visible = true
  local lb_rank = cell:search("lb_rank")
  local lb_cha_name = cell:search("lb_cha_name")
  local lb_cha_award = cell:search("lb_cha_award")
  lb_rank.text = id
  lb_cha_name.text = data:get(packet.key.cha_name).v_string
  local mtf_data = {}
  mtf_data.score = data:get(packet.key.ranklist_data).v_int
  local obj_level = ui.safe_get_atb(bo2.eAtb_Level)
  local rank_award_excel_size = bo2.gv_fate_rank_award.size
  for i = 0, rank_award_excel_size - 1 do
    local rank_award_excel = bo2.gv_fate_rank_award:get(i)
    if sys.check(rank_award_excel) and id <= rank_award_excel.iRankId then
      local money = obj_level * rank_award_excel.award_money_persent
      mtf_data.m = sys.format(L("<m:%d>"), money)
      break
    end
  end
  lb_cha_award.mtf = ui_widget.merge_mtf(mtf_data, ui.get_text("fate|fate_score_desc"))
  lb_cha_award.parent:tune_x("lb_cha_award")
end
function update_page(page)
  page.step = rank_page_step
  if page.index > page.count then
    page.index = 0
  end
  local p_idx = math.floor(page.index / n_page_limit)
  local p_cnt = math.floor((page.count + n_page_limit - 1) / n_page_limit)
  ui_widget.ui_stepping.set_page(rank_page_step, p_idx, p_cnt)
  local view = rank_page_view
  local idx = p_idx * n_page_limit + 1
  local page_count = n_page_limit - 1
  local detail_data = g_rank_data[page.key]
  for i = 0, page_count do
    local cname = sys.format(L("%d"), i)
    local cell = view:search(cname)
    if sys.check(cell) ~= true then
      return
    end
    local iRank = i + 1 + page.index
    local data
    if detail_data ~= nil and detail_data.data ~= nil then
      n, data = detail_data.data:fetch_nv(i)
    end
    set_cell(cell, page, iRank, data)
  end
end
function update_step()
  local function on_init_step(page)
    local function on_page_step(var)
      page.index = var.index * n_page_limit
      update_page(page)
      if var.index >= 0 then
        local iIndex = var.index
        local v_data = sys.variant()
        v_data[packet.key.cmn_type] = page.key
        v_data[packet.key.request_page] = iIndex
        if page[iIndex] == nil then
          page[iIndex] = {request_id = 0}
        end
        v_data[packet.key.cmn_id] = page[iIndex].request_id
        bo2.send_variant(packet.eCTS_FateRank_Request, v_data)
      end
    end
    ui_widget.ui_stepping.set_event(rank_page_step, on_page_step)
    update_page(page)
  end
  if today_rank.press == true then
    on_init_step(page_today)
  end
  if yesterday_rank.press == true then
    on_init_step(page_yesterday)
  end
end
function on_press_btn(btn)
  local v = sys.variant()
  local type = bo2.eFateRankDataType_Today
  if btn ~= today_rank then
    type = bo2.eFateRankDataType_History
  end
  v[packet.key.cmn_type] = type
  bo2.send_variant(packet.eCTS_FateRank_Request, v)
end
function on_check_press()
  if today_rank.press == false and yesterday_rank.press == false then
    today_rank.press = true
  end
  if today_rank.press == true then
    on_press_btn(today_rank)
  else
    on_press_btn(yesterday_rank)
  end
end
function on_visible_fate_rank(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis ~= false then
    on_check_press()
  end
end
function on_handle_fate_rank(cmd, data)
  local page_data = data:get(packet.key.cmn_dataobj)
  local page_type = data:get(packet.key.cmn_type).v_int
  if g_rank_data[page_type] == nil then
    g_rank_data[page_type] = {}
  end
  g_rank_data[page_type].data = page_data
  g_rank_data[page_type].id = data[packet.key.cmn_id]
  on_flash_fate_rank()
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_FateRank, on_handle_fate_rank, "ui_fate::on_handle_fate_rank")
