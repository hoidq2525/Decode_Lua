local init = function()
  if sys.check(rawget(_M, "w_source")) then
    return
  end
  w_top:load_style("$frame/item/item_lottery.xml", "main")
  local svar = w_top.svar
  local grids = {}
  svar.grids = grids
  for index = 0, 9 do
    local gtop = w_top:search(index)
    local card = gtop:search("card")
    local blink = gtop:search("blink")
    local holo = gtop:search("holo")
    grids[index] = {
      top = gtop,
      card = card,
      count = gtop:search("lb_count"),
      blink = blink,
      holo = holo
    }
    blink.visible = false
    holo.visible = false
  end
end
local remove_lock = function(excel_id)
  local info = ui.item_of_excel_id(excel_id)
  if info ~= nil then
    info:remove_lock(bo2.eItemLock_UI)
  end
end
function on_visible(ctrl, vis)
  if not vis then
    local svar = w_top.svar
    remove_lock(svar.excel_id)
    return
  end
  init()
end
function grid_reset(grid)
  local drop_type = grid.drop_type
  if drop_type ~= nil then
    grid.card.drop_type = drop_type
  else
    grid.card.excel_id = grid.excel_id
  end
  local lb_count = grid.count
  if grid.item_count == 1 then
    lb_count.visible = false
  else
    lb_count.visible = true
    lb_count.text = grid.item_count
  end
end
function reset(info)
  local svar = w_top.svar
  local use_tick = svar.use_tick
  if use_tick ~= nil and sys.dtick(sys.tick(), use_tick) < 30000 then
    local excel_id = svar.excel_id
    if excel_id ~= nil then
      return excel_id
    end
  end
  set_rand_state(false)
  svar.use_tick = nil
  if not sys.check(info) then
    if not w_top.visible then
      return nil
    end
    info = ui.item_of_excel_id(svar.excel_id)
    if not sys.check(info) then
      return nil
    end
  end
  local excel_id = info.excel_id
  svar.excel_id = excel_id
  remove_lock(w_source.excel_id)
  w_source.excel_id = excel_id
  info:insert_lock(bo2.eItemLock_UI)
  local excel = info.excel
  w_top:search("lb_title").text = excel.name
  local index = 0
  local use_par = excel.use_par
  local grids = svar.grids
  for i = 0, use_par.size - 1 do
    local rand = bo2.gv_item_rand:find(use_par[i])
    if rand ~= nil then
      local drop_kind = rand.drop_kind
      local drop_id = rand.drop_id
      for k = 0, 9 do
        local kind = drop_kind[k]
        local excel_id = 0
        local item_count = 1
        local drop_type
        local drop_id_v = drop_id[k]
        if kind == 1 then
          excel_id = drop_id_v[0]
          if drop_id_v.size > 1 then
            item_count = drop_id_v[1]
          end
        elseif kind == 2 then
          drop_type = drop_id_v[0]
          local drop_list = bo2.item_drop_list_find(drop_type)
          if drop_list ~= nil then
            excel_id = drop_list:get(0)
          end
        end
        if index <= 9 then
          if excel_id > 0 then
            local grid = grids[index]
            grid.excel_id = excel_id
            grid.item_count = item_count
            grid.drop_type = drop_type
            grid.blink.visible = false
            grid.holo.visible = false
            grid_reset(grid)
            index = index + 1
          else
            local grid = grids[index]
            grid.excel_id = 0
            grid.item_count = ""
            grid.drop_type = 0
            grid.blink.visible = false
            grid.holo.visible = false
            index = index + 1
            grid.card.excel_id = 0
            grid.card.drop_type = 0
            lb_count = grid.count
            lb_count.visible = false
            lb_count.text = ""
          end
        end
      end
    end
  end
  return nil
end
function show(info)
  w_top.visible = true
  w_top:move_to_head()
  local excel_id = reset(info)
  if excel_id == info.excel_id then
    return
  end
end
local only_id_sig = "ui_item_lottery.on_lottery.on_only_id"
function set_rand_state(s)
  w_btn_send.visible = not s
  w_encircle.visible = s
  w_light.visible = s
  p_timer.suspended = not s
  w_flash.visible = false
  local svar = w_top.svar
  for i, grid in pairs(svar.grids) do
    grid.blink.visible = false
    grid.holo.visible = false
    grid_reset(grid)
    grid.card:remove_on_item_only_id(only_id_sig)
  end
end
function send()
  local svar = w_top.svar
  local use_tick = svar.use_tick
  if use_tick ~= nil and sys.dtick(sys.tick(), use_tick) < 5000 then
    set_rand_state(true)
    return
  end
  local info = ui.item_of_excel_id(svar.excel_id)
  if not sys.check(info) then
    local text = ui.get_text("item|lottery_no_item")
    ui_widget.ui_msg_box.show_common({
      text = ui_widget.merge_mtf({
        item = "<i:" .. w_source.excel_id .. ">"
      }, text),
      btn_confirm = true,
      btn_cancel = false,
      modal = true
    })
    return
  end
  svar.use_tick = sys.tick()
  set_rand_state(true)
  ui_item.send_use(info)
end
function on_timer(t)
  local svar = w_top.svar
  local use_tick = svar.use_tick
  if use_tick == nil or sys.dtick(sys.tick(), use_tick) >= 5000 then
    set_rand_state(false)
    return
  end
  local grids = {}
  local tick = sys.tick()
  for i, grid in pairs(svar.grids) do
    local holo = grid.holo
    if holo.visible then
      local dt = sys.dtick(tick, grid.holo_tick)
      if dt >= 2500 then
        table.insert(grids, grid)
        if dt >= 3000 then
          holo.visible = false
        end
      end
    else
      table.insert(grids, grid)
    end
  end
  local c = #grids
  if c == 0 then
    return
  end
  local i = bo2.rand(1, c)
  local grid = grids[i]
  grid.holo_tick = tick
  local holo = grid.holo
  holo.visible = true
  holo:reset()
end
function on_send_click(btn)
  send()
end
function on_lottery(cmd, data)
  local svar = w_top.svar
  svar.use_tick = nil
  local state = data[packet.key.cmn_state]
  if state == 0 then
    reset()
    return
  end
  if state == 1 then
    do
      local item_count = data[packet.key.item_count]
      if item_count == nil then
        item_count = 1
      end
      set_rand_state(false)
      local only_id = data[packet.key.item_key]
      local info = ui.item_of_only_id(only_id)
      local match_grid
      if info ~= nil then
        for i, grid in pairs(svar.grids) do
          if (grid.excel_id == info.excel_id or grid.drop_type == info.excel.drop_type) and grid.item_count == item_count then
            grid.blink.visible = true
            local card = grid.card
            card.only_id = only_id
            local function on_only_id()
              local info2 = ui.item_of_only_id(only_id)
              if info2 == nil then
                grid_reset(grid)
              end
            end
            card:insert_on_item_only_id(on_only_id, only_id_sig)
            match_grid = grid
          end
        end
      else
        local excel_id = data[packet.key.item_excelid]
        local excel = ui.item_get_excel(excel_id)
        for i, grid in pairs(svar.grids) do
          if (grid.excel_id == excel_id or grid.drop_type == excel.drop_type) and grid.item_count == item_count then
            grid.blink.visible = true
            local card = grid.card
            card.excel_id = excel_id
            match_grid = grid
          end
        end
      end
      if match_grid ~= nil then
        local top = match_grid.top
        local pt = ui.point(top.dx * 0.5, top.dy * 0.5)
        pt = top:control_to_parent(w_flash.parent, pt)
        pt = ui.point(pt.x - w_flash.dx * 0.5, pt.y - w_flash.dy * 0.5)
        w_flash.offset = pt
        w_flash.visible = true
        w_flash:reset()
      end
    end
  end
end
local reg = ui_packet.game_recv_signal_insert
reg(packet.eSTC_UI_ItemLottery, on_lottery, "ui_item_lottery.on_lottery")
