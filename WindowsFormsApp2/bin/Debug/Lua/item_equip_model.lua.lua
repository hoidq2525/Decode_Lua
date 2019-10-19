function on_visible(ctrl, vis)
  if not vis then
    ui.item_mark_show("equip_model", 0)
    return
  end
  if not sys.check(rawget(_M, "w_core")) then
    w_top:load_style("$frame/item/item_equip_model.xml", "main")
    ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  end
end
local card_get_req = function(top)
  local p = top:search("item_req")
  local excel = top:search("card").excel
  if excel == nil then
    return p, nil, 0
  end
  local requires = excel.requires
  for i = 1, requires.size - 1, 2 do
    if requires[i - 1] == 4 then
      return p, excel.ptype, requires[i]
    end
  end
  return p, excel.ptype, 0
end
local function card_update_req()
  local p1, t1, s1 = card_get_req(w_source)
  local p2, t2, s2 = card_get_req(w_cost)
  if t1 == t2 and s1 == s2 then
    p1.color = ui.make_color("00FF00")
    p2.color = ui.make_color("00FF00")
  else
    p1.color = ui.make_color("FFFF00")
    p2.color = ui.make_color("FF0000")
  end
end
local function card_clear(top)
  top:search("card").only_id = ""
  top:search("item_name").text = ""
  top:search("item_req").text = ""
  card_update_req()
end
local function card_reset(top, info)
  top:search("card").only_id = info.only_id
  local n = top:search("item_name")
  n.text = info.name
  plootlevel_star = info.plootlevel_star
  if plootlevel_star ~= nil then
    n.color = ui.make_color(plootlevel_star.color)
  else
    n.color = ui.make_color("FFFFFF")
  end
  local p, t, s = card_get_req(top)
  if s == 1 then
    p.text = t.name .. "\n" .. ui.get_text("tool|tip_item_sex") .. ui.get_text("common|sex1")
  elseif s == 2 then
    p.text = t.name .. "\n" .. ui.get_text("tool|tip_item_sex") .. ui.get_text("common|sex2")
  else
    p.text = t.name
  end
  card_update_req()
end
function send_use()
  local svar = w_top.svar
  local item_info = ui.item_of_only_id(svar.item_id)
  if item_info == nil then
    return
  end
  local p1, t1, s1 = card_get_req(w_source)
  local p2, t2, s2 = card_get_req(w_cost)
  if t1 == nil or t2 == nil or t1 ~= t2 or s1 ~= s2 then
    ui_tool.note_insert(ui.get_text("item_equip_model|not_fit"), "FFFF0000")
    return
  end
  local source_id = w_source:search("card").only_id
  local cost_id = w_cost:search("card").only_id
  if source_id == L("0") or cost_id == L("0") then
    ui_tool.note_insert(ui.get_text("item_equip_model|not_fit"), "FFFF0000")
    return
  end
  local item_info_cost = ui.item_of_only_id(cost_id)
  if item_info_cost == nil then
    return
  end
  for idx = 0, item_info_cost:get_data_8(bo2.eItemByte_Holes) - 1 do
    if item_info_cost:get_data_32(bo2.eItemUInt32_GemBeg + idx) ~= 0 then
      local txt = ui.get_text("item_equip_model|no_gem")
      ui_tool.note_insert(txt, "FF0000")
      return
    end
  end
  local ch_text = sys.mtf_merge(arg, ui.get_text("item_equip_model|sure"))
  for idx = 0, item_info_cost:get_data_32(bo2.eItemUInt32_AvataEnchant_SlotNum) - 1 do
    if item_info_cost:get_data_32(bo2.eItemUInt32_AvataEnchant_Begin + idx) ~= 0 then
      ch_text = sys.mtf_merge(arg, ui.get_text("item_equip_model|sure_fm"))
    end
  end
  ui_widget.ui_msg_box.show_common({
    modal = true,
    btn_confirm = true,
    btn_cancel = true,
    text = ch_text,
    callback = function(ret)
      if ret.result == 1 then
        w_top.visible = false
        local v = sys.variant()
        v:set("source_id", source_id)
        v:set("cost_id", cost_id)
        ui_item.send_use(item_info, v)
      end
    end
  })
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
  send_use()
end
function on_clear_click(btn)
  card_clear(w_source)
  card_clear(w_cost)
end
local cs_rclick_change_model = ui.get_text("item_equip_model|rclick_change_model")
local cs_moveto_change_model = ui.get_text("item_equip_model|moveto_change_model")
function item_rbutton_tip(info)
  if info == nil then
    return nil
  end
  local svar = w_top.svar
  local excel_id = svar.excel_id
  if not info:check_modify_equip_model(excel_id, false) then
    return
  end
  local box = info.box
  if box < bo2.eItemBox_BagBeg or box >= bo2.eItemBox_BagEnd then
    return cs_moveto_change_model
  end
  return cs_rclick_change_model
end
function item_rbutton_check(info)
  if info == nil then
    return false
  end
  local excel = info.excel
  if excel == nil then
    return false
  end
  return true
end
function item_rbutton_use(info)
  if info == nil then
    return
  end
  local svar = w_top.svar
  local excel_id = svar.excel_id
  if not info:check_modify_equip_model(excel_id, true) then
    return
  end
  local id = info.only_id
  local source_id = w_source:search("card").only_id
  local cost_id = w_cost:search("card").only_id
  if id == source_id or id == cost_id then
    return
  end
  if source_id.size <= 1 then
    card_reset(w_source, info)
  else
    local cfg = bo2.gv_item_equip_model_config:find(info.excel_id)
    if cfg ~= nil and cfg.disable > 0 then
      ui_tool.note_insert(ui.get_text("item_equip_model|func_disable"), "FFFF0000")
      return
    end
    card_reset(w_cost, info)
  end
end
function on_card_mouse(card, msg, pos, wheel)
  if msg ~= ui.mouse_rbutton_click then
    return
  end
  local icon = card.icon
  if icon == nil then
    return
  end
  card_clear(card.parent.parent)
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  local stk = sys.mtf_stack()
  if excel == nil then
    ui_tool.ctip_show(card, nil)
    return
  end
  ui_tool.ctip_make_item(stk, excel, card.info, card)
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("item|right_input_bag"), ui_tool.cs_tip_color_operation)
  ui_tool.ctip_show(card, stk)
end
function show(info)
  local excel = info.excel
  local svar = w_top.svar
  local excel_id = info.excel_id
  svar.excel_id = excel_id
  svar.item_id = info.only_id
  w_top.visible = true
  w_top:move_to_head()
  w_top:search("lb_title").text = excel.name
  ui.item_mark_show("equip_model", excel_id)
  local rb_desc = w_top:search("rb_desc")
  rb_desc.mtf = ui_widget.merge_mtf({
    item = sys.format("<i:%d>", excel.id)
  }, ui.get_text("item_equip_model|func_desc"))
  rb_desc:update()
  on_clear_click()
end
function show_recover(info)
  local data = sys.variant()
  data:set("drop_type", ui_widget.c_drop_type_useto)
  data:set("only_id", info.only_id)
  local on_drop_hook = function(w, msg, pos, data)
    if msg == ui.mouse_drop_setup then
      ui.item_mark_show("equip_model_recover", 1)
    elseif msg == ui.mouse_drop_clean then
      ui.item_mark_show("equip_model_recover", 0)
    end
  end
  ui.setup_drop(ui_tool.w_ident_floater, data, on_drop_hook)
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
function make_flash(card, tick, delay)
  local tool = ui_qbar.ui_animation.w_tool
  local img = tool:inner_create("picture")
  img:load_style("$frame/item/item.xml", "item_flash")
  img.size = card.size * 2
  local function create(delay2, time, scale)
    local anim = tool:animation_create(tick)
    anim.delay = delay + delay2
    local f = anim:frame_create(time, img, card)
    f.scale = ui.point(scale, scale)
    f = anim:frame_create(200, img, card)
    f.scale = ui.point(0.5, 0.5)
    f = anim:frame_create(10, img, card)
    f.color = "00FFFFFF"
    f.scale = ui.point(0.4, 0.4)
  end
  create(0, 400, 1)
  create(100, 500, 1.2)
  create(200, 600, 1.4)
  create(300, 650, 1.6)
  create(400, 700, 1.8)
  create(500, 750, 1.8)
  create(600, 800, 1.8)
end
function on_equip_model(cmd, data)
  local card_source = find_item_card(data:get("source").v_int)
  local card_use = find_item_card(data:get("use").v_int)
  local card_cost = find_item_card(data:get("cost").v_int)
  local excel_use = bo2.gv_item_list:find(data:get("use_id").v_int)
  local excel_cost = bo2.gv_equip_item:find(data:get("cost_id").v_int)
  if card_source == nil or card_use == nil or card_cost == nil or excel_use == nil or excel_cost == nil then
    return
  end
  local w_item = ui_item.w_item
  if not w_item.visible then
    return
  end
  w_item:move_to_head()
  local anim_tick = sys.tick()
  local source_dx = card_source.dx
  local source_size = card_source.size
  local tool = ui_qbar.ui_animation.w_tool
  local function make_animation(excel, parent)
    local card = tool:inner_create("card_item")
    card.excel_id = excel.id
    card:set_count_mode("none")
    card.size = source_size
    local anim = tool:animation_create(anim_tick)
    anim.delay = 800
    local f = anim:frame_create(500, card, parent)
    f = anim:frame_create(1000, card, parent)
    f.rotate = 360
    f.scale = ui.point(1.5, 1.5)
    f = anim:frame_create(500, card, card_source)
    f.rotate = 360
    f.scale = ui.point(0.8, 0.8)
    f = anim:frame_create(100, card, card_source)
    f.scale = ui.point(0.4, 0.4)
  end
  local img = tool:inner_create("picture")
  img.image = "$image/item/64x64/yinyang.png"
  img.size = ui.point(64, 64)
  local function make_yinyang(parent)
    local anim = tool:animation_create(anim_tick)
    local f = anim:frame_create(600, img, parent)
    f.scale = ui.point(0.5, 0.5)
    f = anim:frame_create(400, img, parent)
    f.rotate = 240
    f.scale = ui.point(0.8, 0.8)
    f.color = "FFFFFF00"
    f = anim:frame_create(10, img, parent)
    f.rotate = 400
    f.scale = ui.point(0.6, 0.6)
    f.color = "22888800"
  end
  make_animation(excel_use, card_use)
  make_animation(excel_cost, card_cost)
  make_yinyang(card_use)
  make_yinyang(card_cost)
  make_flash(card_source, anim_tick, 2000)
end
local reg = ui_packet.game_recv_signal_insert
reg(packet.eSTC_UI_ItemEquipModel, on_equip_model, "ui_item_equip_model.on_equip_model")
