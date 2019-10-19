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
  if not sys.check(rawget(_M, "w_source")) then
    w_top:load_style("$frame/item/item_compose.xml", "main")
  end
  ctrl:apply_dock(true)
  local rb_desc = ctrl:search("rb_desc")
  rb_desc.mtf = ui.get_text("item_compose|func_desc")
  rb_desc:update()
  rb_desc.dy = rb_desc.extent.y
  reset(ui.item_of_excel_id(50037))
end
function update(count)
  w_product.text = nil
  local svar = w_top.svar
  local excel_id = svar.excel_id
  local info = ui.item_of_excel_id(excel_id)
  if info == nil then
    return 0
  end
  local comp_view = bo2.item_compose_find(excel_id)
  local comp_count = comp_view.size
  local count_min = comp_view:get(0).count
  local count_max = comp_view:get(comp_count - 1).count
  if count == nil then
    count = count_min
  end
  if count >= info.count then
    count = info.count
  end
  if count_max <= count then
    count = count_max
  end
  if count_min > count then
    if count_min > info.count then
      return count
    end
    count = count_min
  end
  svar.count = count
  local comp1, comp2
  for i = 0, comp_count - 1 do
    local comp = comp_view:get(i)
    if count <= comp.count then
      if comp.count == count then
        comp1 = comp
        break
      end
      comp1 = comp_view:get(i - 1)
      comp2 = comp
      break
    end
  end
  local cells = {}
  local function insert_cell(data, prob)
    local stk = sys.stack()
    for i = 0, data.size - 1 do
      stk:format("%d*", data[i])
    end
    local t = stk.text
    local cell = cells[t]
    if cell == nil then
      cells[t] = {data = data, prob = prob}
    else
      cell.prob = cell.prob + prob
    end
  end
  local vdata = comp1.data
  local vprob = comp1.prob
  if comp2 == nil then
    for i = 0, 9 do
      local pr = vprob[i]
      if pr > 0 then
        insert_cell(vdata[i], pr)
      end
    end
  else
    local delta = comp2.count - comp1.count
    local factor1 = (comp2.count - count) / delta
    local factor2 = (count - comp1.count) / delta
    local vdata2 = comp2.data
    local vprob2 = comp2.prob
    for i = 0, 9 do
      local pr = vprob[i]
      if pr > 0 then
        insert_cell(vdata[i], pr * factor1)
      end
      pr = vprob2[i]
      if pr > 0 then
        insert_cell(vdata2[i], pr * factor2)
      end
    end
  end
  local prob = 0
  local vcell = {}
  for _, cell in pairs(cells) do
    prob = prob + cell.prob
    table.insert(vcell, cell)
  end
  table.sort(vcell, function(x, y)
    return x.prob > y.prob
  end)
  local stk = sys.mtf_stack()
  local multi = ui.get_text("item|drop_type_title")
  for idx, cell in ipairs(vcell) do
    local data = cell.data
    local dc = data.size
    for i = 1, dc - 1, 3 do
      local kind = data[i - 1]
      local id = data[i]
      local cnt = 1
      if dc > i + 1 then
        cnt = data[i + 1]
      end
      if i > 1 then
        stk:raw_push("\n")
      end
      if kind == 1 then
        stk:raw_format("<i:%d>", id)
      elseif kind == 2 then
        stk:raw_format("<drop_type:%d>", id)
      end
      if cnt ~= 1 then
        stk:raw_format(" x %d", cnt)
      end
    end
    local v = cell.prob * 100 / prob
    if v < 1 then
      if v < 0.1 then
        if v < 0.001 then
          stk:raw_format("<a+:r><c+:ff0000>%.6f%%<c-><a->", v)
        else
          stk:raw_format("<a+:r><c+:ff0000>%.4f%%<c-><a->", v)
        end
      else
        stk:raw_format("<a+:r><c+:ff0000>%.2f%%<c-><a->", v)
      end
    elseif v < 10 then
      if v == math.floor(v) then
        stk:raw_format("<a+:r><c+:ffff00>%d%%<c-><a->", v)
      else
        stk:raw_format("<a+:r><c+:ffff00>%.2f%%<c-><a->", v)
      end
    elseif v == math.floor(v) then
      stk:raw_format("<a+:r><c+:00ff00>%d%%<c-><a->", v)
    else
      stk:raw_format("<a+:r><c+:00ff00>%.1f%%<c-><a->", v)
    end
    ui_tool.ctip_push_sep(stk)
  end
  w_product.mtf = stk.text
  return count
end
function update2(count2)
  if count2 == nil or count2 <= 1 then
    return 1
  end
  local svar = w_top.svar
  local excel_id = svar.excel_id
  local info = ui.item_of_excel_id(excel_id)
  if info == nil then
    return 0
  end
  local count = w_input_count.text.v_int
  local total = info.count / count
  total = math.floor(total)
  if total > 999 then
    total = 999
  end
  if count2 >= total then
    return total
  end
  return count2
end
function reset(info)
  local svar = w_top.svar
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
  w_source_name.text = excel.name
  w_source_name.color = ui.make_color(excel.plootlevel_star.color)
  local comp_view = bo2.item_compose_find(excel_id)
  local comp_count = comp_view.size
  w_source_min.text = ui.get_text("item_compose|cost_min") .. comp_view:get(0).count
  w_source_max.text = ui.get_text("item_compose|cost_max") .. comp_view:get(comp_count - 1).count
  w_input_count.text = update()
  w_input_count2.text = update2()
end
function show(info)
  w_top.visible = true
  w_top:move_to_head()
  reset(info)
end
local send_count_limit = function(excel_id)
  local text = ui.get_text("item|lottery_no_item")
  ui_widget.ui_msg_box.show_common({
    text = ui_widget.merge_mtf({
      item = "<i:" .. excel_id .. ">"
    }, text),
    btn_confirm = true,
    btn_cancel = false,
    modal = true
  })
end
function on_send_click(btn)
  local svar = w_top.svar
  local excel_id = svar.excel_id
  local info = ui.item_of_excel_id(excel_id)
  if info == nil then
    send_count_limit(excel_id)
    return
  end
  local comp_view = bo2.item_compose_find(excel_id)
  local count_min = comp_view:get(0).count
  local count_max = comp_view:get(comp_view.size - 1).count
  local count = w_input_count.text.v_int
  if count_min > count or count_max < count then
    send_count_limit(excel_id)
    return
  end
  local total = info.count / count
  local count2 = w_input_count2.text.v_int
  total = math.floor(total)
  if count2 > total then
    send_count_limit(excel_id)
    return
  end
  local v = sys.variant()
  v[packet.key.item_key] = info.only_id
  v[packet.key.item_count] = count
  v[packet.key.cmn_count] = count2
  bo2.send_variant(packet.eCTS_UI_ComposeItem, v)
end
function on_item_count(btn)
  local name = tostring(btn.name)
  local count = w_input_count.text.v_int
  if name == "plus" then
    count = count + 1
  elseif name == "minus" then
    count = count - 1
  elseif name == "max" then
    count = 9999
  end
  local r = update(count)
  w_input_count.text = r
end
function on_item_count2(btn)
  local name = tostring(btn.name)
  local count = w_input_count2.text.v_int
  if name == "plus" then
    count = count + 1
  elseif name == "minus" then
    count = count - 1
  elseif name == "max2" then
    count = 999
  end
  local r = update2(count)
  w_input_count2.text = r
end
function on_timer(t)
  local count = w_input_count.text.v_int
  local r = update(count)
  if r ~= count then
    w_input_count.text = r
  end
  local count2 = w_input_count2.text.v_int
  local r2 = update2(count2)
  if count2 == nil or r2 ~= count2 then
    w_input_count2.text = r2
  end
end
function try_compose(info)
  local box = info.box
  if box < bo2.eItemBox_BagBeg or box > bo2.eItemBox_Quest then
    return false
  end
  local excel = info.excel
  local comp_view = bo2.item_compose_find(excel.id)
  if comp_view == nil or comp_view.size <= 0 then
    return false
  end
  show(info)
  return true
end
function try_decompose(info)
  local box = info.box
  if box < bo2.eItemBox_BagBeg or box > bo2.eItemBox_Quest then
    return false
  end
  local excel = info.excel
  local d = bo2.gv_item_decompose:find(excel.id)
  if d == nil or size_id == 0 then
    return false
  end
  local size_id = d.v_item_rands.size
  if size_id == 0 then
    return false
  end
  for i = 0, size_id - 1 do
    local r = bo2.gv_item_rand:find(d.v_item_rands[i])
    if r == nil then
      return false
    end
  end
  local function send(count)
    local v = sys.variant()
    v[packet.key.item_key] = info.only_id
    v[packet.key.item_count] = count
    bo2.send_variant(packet.eCTS_UI_EquipResolve, v)
  end
  if info.count == 1 then
    send(1)
    return true
  end
  ui_widget.ui_msg_box.show_common({
    text = ui_widget.merge_mtf({
      item = sys.format("<i:%d>", excel.id)
    }, ui.get_text("item_compose|decompose_msg_box_desc")),
    input = 1,
    number_only = true,
    callback = function(msg)
      if msg.result == 0 then
        return
      end
      local count = msg.input.v_int
      if count <= 0 or count > info.count then
        ui_tool.note_insert(bo2.gv_text:find(2517).text, "FFFF0000")
        return
      end
      send(count)
    end
  })
  ui.log("decompose")
  return true
end
local find_item_card = function(index)
  local box = math.floor(index / 256)
  local box_data = ui_item.g_boxs[box]
  if box_data == nil then
    return nil
  end
  local grid = index % 256
  local cell = box_data.cells[grid]
  if cell == nil then
    return nil
  end
  local card = cell.card
  return card
end
function make_compose_animation(source, vBox, vMail)
  if source == nil then
    return
  end
  local w_item = ui_item.w_item
  if not w_item.visible then
    return
  end
  w_item:move_to_head()
  local count = 0
  if vBox ~= nil then
    count = vBox.size
  end
  if vMail ~= nil then
    count = count + vMail.size
  end
  if count < 1 then
    return
  end
  local anim_tick = sys.tick()
  local source_dx = source.dx
  local source_size = source.size
  local angle_min = -30
  local angle_max = -90
  local radius_min = source_dx * 1.25
  local radius_max = source_dx * 1.85
  local count_max = 8
  local factor = 1
  if count < count_max then
    factor = (count - 1) / (count_max - 1)
  end
  local angle = 0
  local angle_step = 0
  if count > 1 then
    angle = angle_min + (angle_max - angle_min) * factor
    angle_step = 2 * angle / (count - 1)
  end
  local radius = radius_min + (radius_max - radius_min) * factor
  local origin = ui.point(0, radius)
  local scale1 = ui.point(1.5, 1.5)
  local scale2 = ui.point(2.4, 2.4)
  local origin2 = ui.point(0, radius - source_dx * 0.65)
  local time1 = 800
  local tool = ui_qbar.ui_animation.w_tool
  local function make_animation(excel_id, target, time)
    local card = tool:inner_create("card_item")
    card.excel_id = excel_id
    card:set_count_mode("none")
    card.size = source_size
    local anim = tool:animation_create(anim_tick)
    local source_card = source
    if source.excel_id == 0 then
      source_card = card
    end
    local f = anim:frame_create(time1, source_card, source)
    f = anim:frame_create(200, card, source)
    f.origin = origin
    f.rotate = angle
    f.scale = scale1
    f = anim:frame_create(200, card, source)
    f.origin = origin2
    f.rotate = angle
    f.scale = scale2
    f = anim:frame_create(time, card, source)
    f.origin = origin
    f.rotate = angle
    f.scale = scale1
    f = anim:frame_create(100, card, target)
    f.scale = target.size / card.size
    angle = angle - angle_step
  end
  if vBox ~= nil then
    for _, index, excel_id in vpairs(vBox) do
      local card = find_item_card(index)
      make_animation(excel_id, card, 1000)
    end
  end
  if vMail ~= nil then
    for _, idx, excel_id in vpairs(vMail) do
      make_animation(excel_id, ui_mail.gx_toggle, 1200)
    end
  end
end
function on_decompose(cmd, data)
  local vBox = data[packet.key.item_box]
  local vMail = data[packet.key.mail_type]
  local source = find_item_card(data[packet.key.itemdata_idx])
  make_compose_animation(source, vBox, vMail)
end
function on_compose(cmd, data)
  local vBox = data[packet.key.item_box]
  local vMail = data[packet.key.mail_type]
  if w_top.visible then
    make_compose_animation(w_source, vBox, vMail)
    return
  end
  local source = find_item_card(data[packet.key.itemdata_idx])
  make_compose_animation(source, vBox, vMail)
end
function on_lucky_award(cmd, data)
  local vBox = data[packet.key.item_box]
  local vMail = data[packet.key.mail_type]
  local count = 0
  if vBox ~= nil then
    count = vBox.size
  end
  if vMail ~= nil then
    count = count + vMail.size
  end
  if count < 1 then
    return
  end
  local w_target
  local w_item = ui_item.w_item
  if w_item.visible then
    w_item:move_to_head()
  else
    w_target = ui_qbar.w_btn_item
  end
  local source = rawget(_M, "w_lucky_award_icon")
  if source == nil then
    source = ui.create_control(ui_main.w_top, "panel")
    source.visible = false
    source.size = ui.point(64, 64)
    w_lucky_award_icon = source
  end
  source.size = ui.point(64, 64)
  source.offset = ui.point(ui_main.w_top.dx * 0.5 - source.dx * 0.5, ui_main.w_top.dy * 0.5 - source.dy * 0.5)
  local anim_tick = sys.tick()
  local source_dx = source.dx
  local source_size = source.size
  local angle_min = -30
  local angle_max = -90
  local radius_min = source_dx * 1.25
  local radius_max = source_dx * 1.85
  local count_max = 8
  local factor = 1
  if count < count_max then
    factor = (count - 1) / (count_max - 1)
  end
  local angle = 0
  local angle_step = 0
  if count > 1 then
    angle = angle_min + (angle_max - angle_min) * factor
    angle_step = 2 * angle / (count - 1)
  end
  local radius = radius_min + (radius_max - radius_min) * factor
  local origin = ui.point(0, radius)
  local scale1 = ui.point(1.5, 1.5)
  local scale2 = ui.point(2.4, 2.4)
  local origin2 = ui.point(0, radius - source_dx * 0.65)
  local time1 = 800
  local tool = ui_qbar.ui_animation.w_tool
  local function make_animation(excel_id, target, time)
    local card = tool:inner_create("card_item")
    card.excel_id = excel_id
    card:set_count_mode("none")
    card.size = source_size
    local anim = tool:animation_create(anim_tick)
    local f = anim:frame_create(time1, card, source)
    f = anim:frame_create(200, card, source)
    f.origin = origin
    f.rotate = angle
    f.scale = scale1
    f = anim:frame_create(200, card, source)
    f.origin = origin2
    f.rotate = angle
    f.scale = scale2
    f = anim:frame_create(time, card, source)
    f.origin = origin
    f.rotate = angle
    f.scale = scale1
    f = anim:frame_create(100, card, target)
    f.scale = target.size / card.size
    angle = angle - angle_step
  end
  local icon = tool:inner_create("picture")
  icon.size = ui.point(64, 64)
  icon.image = "$image/qbar/lucky.png"
  local anim = tool:animation_create(anim_tick)
  local f = anim:frame_create(2000, icon, source)
  f = anim:frame_create(1200, icon, source)
  f = anim:frame_create(500, icon, source)
  f.rotate = 180
  f.scale = ui.point(0.8, 0.8)
  anim:frame_fadeout()
  local lb = tool:inner_create("label")
  lb.font = ui.font("plain", "18", "full")
  lb.text = ui.get_text("item_compose|lucky_award")
  lb.xcolor = "FFFFFF00"
  local lb_off = ui.point(0, 60)
  anim = tool:animation_create(anim_tick)
  f = anim:frame_create(300, lb, source)
  f.offset = lb_off
  f.color = "00000000"
  f = anim:frame_create(300, lb, source)
  f.offset = lb_off
  f.color = "FFFFFFFF"
  f = anim:frame_create(300, lb, source)
  f.offset = lb_off
  f.color = "88AAAAAA"
  f = anim:frame_create(300, lb, source)
  f.offset = lb_off
  f.color = "FFFFFFFF"
  f = anim:frame_create(300, lb, source)
  f.offset = lb_off
  f.color = "AACCCCCC"
  f = anim:frame_create(1800, lb, source)
  f.offset = lb_off
  f.color = "FFFFFFFF"
  f = anim:frame_create(500, lb, source)
  f.offset = lb_off
  f = anim:frame_create(500, lb, source)
  f.offset = lb_off
  f.scale = ui.point(0.6, 0.6)
  anim:frame_fadeout()
  if vBox ~= nil then
    for _, index, excel_id in vpairs(vBox) do
      local card = w_target
      if card == nil then
        find_item_card(index)
      end
      make_animation(excel_id, card, 1500)
    end
  end
  if vMail ~= nil then
    for _, idx, excel_id in vpairs(vMail) do
      make_animation(excel_id, ui_mail.gx_toggle, 1500)
    end
  end
end
function test_lucky_award()
  local vBox = sys.variant()
  vBox[1] = 21011
  vBox[2] = 10574
  vBox[3] = 21011
  vBox[4] = 10574
  local vMail = sys.variant()
  vMail:push_back(21011)
  vMail:push_back(10574)
  local v = sys.variant()
  v[packet.key.item_box] = vBox
  v[packet.key.mail_type] = vMail
  on_lucky_award(0, v)
end
local reg = ui_packet.game_recv_signal_insert
reg(packet.eSTC_UI_DecomposeItem, on_decompose, "ui_item_decompose.on_decompose")
reg(packet.eSTC_UI_ComposeItem, on_compose, "ui_item_decompose.on_compose")
reg(packet.eSTC_UI_LuckyAward, on_lucky_award, "ui_item_decompose.on_lucky_award")
