local size_x = 2
local size_y = 3
local c_style_file = L("$frame/knight/kchallenge_item.xml")
local c_cell_item = L("cmn_item")
local c_cell_x = 115
local c_cell_y = 85
local ITEM_MAX_NUM = 999
local ITEM_MAX_POINT = 9999
local ITEM_MIN_POINT = 9
local ITEM_MAX_BUYPOINT = 500
local GCD_MIN_LEVEL = 8
local ITEM_MAX_MOST_POINT = 9999
local TOTAL_CD_ID = 5702
function get_visible()
  local w = ui_knight.ui_kchallenge.g_kchallenge
  return w.visible
end
function on_close_click()
  set_visible(false)
end
function set_visible(vis)
  local w = ui_knight.ui_kchallenge.g_kchallenge
  if vis ~= nil then
    w.visible = vis
  else
    w.visible = not w.visible
  end
  g_items_challenge.itempoints = 0
  g_items_challenge.buypoints = 0
  g_items_challenge.GCD = {
    [0] = true,
    [1] = true,
    [2] = true
  }
  local btn = w:search("rand_btn")
  if btn == nil then
    return false
  end
  local c_btn = w:search("continue_btn")
  if c_btn == nil then
    return false
  end
  local g_btn = w:search("giveup_btn")
  if g_btn == nil then
    return false
  end
  if vis == false then
    if c_btn.svar.npclevel == 0 then
      remove_all_items()
    end
    btn.svar.npcid = 0
    c_btn.svar.npclevel = 0
  else
    set_npc_details()
    local panel_before = w:search("know_before")
    local panel_after = w:search("know_after")
    local level = c_btn.svar.npclevel
    if level == nil or level == 0 then
      panel_before.visible = true
      panel_after.visible = false
      ui_item.set_visible(true)
      after_points_fixed()
    elseif level >= 1 and level <= 10 then
      panel_before.visible = false
      panel_after.visible = true
      local text = ui.get_text("knight|rand_item")
      local v = sys.variant()
      v:set("level", level)
      g_level_show.mtf = ui.get_text("knight|kc_continue") .. sys.format("<c+:00DB00>%s<c->", sys.mtf_merge(v, text))
    end
  end
  ui.item_mark_show("item_mark_kchallenge", vis)
end
local potrait_uri = SHARED("$icon/portrait/")
function set_npc_details()
  local ctrl = ui_knight.ui_kchallenge.g_kchallenge
  if ctrl == nil then
    return
  end
  local btn = ctrl:search("rand_btn")
  if btn == nil then
    return
  end
  local id = btn.svar.npcid
  local cha_data = bo2.gv_cha_list:find(id)
  if cha_data == nil then
    return
  end
  ctrl:search("tname").text = cha_data.name
  local pic_id = cha_data.pic
  local cha_pic = bo2.gv_cha_pic:find(pic_id)
  if cha_pic ~= nil then
    local icon_name = cha_pic.head_icon
    icon_name = potrait_uri .. icon_name
    ctrl:search("portrait").image = icon_name
  end
  local line_1 = bo2.gv_knight_level_list:find(id)
  if line_1 ~= nil then
    local num = bo2.get_cd_real_token(line_1.cd_id)
    local v = sys.variant()
    v:set("name", cha_data.name)
    v:set("num", num)
    local num_1 = ctrl:search("num1")
    num_1.mtf = sys.mtf_merge(v, ui.get_text("knight|kchallege_num_1"))
  end
  local num = bo2.get_cd_real_token(TOTAL_CD_ID)
  local v = sys.variant()
  v:set("num", num)
  local num_2 = ctrl:search("num2")
  num_2.mtf = sys.mtf_merge(v, ui.get_text("knight|kchallege_num_2"))
  local text_line = bo2.gv_text:find(line_1.text_id)
  if text_line ~= nil then
    ctrl:search("desctext").mtf = text_line.text
  end
end
function record_npc(id, level)
  local ctrl = ui_knight.ui_kchallenge.g_kchallenge
  if ctrl == nil then
    return false
  end
  local btn = ctrl:search("rand_btn")
  if btn == nil then
    return false
  end
  btn.svar.npcid = id
  local c_btn = ctrl:search("continue_btn")
  if c_btn == nil then
    return false
  end
  c_btn.svar.npclevel = level
  c_btn.svar.npcid = id
  local l_btn = ctrl:search("leveldown_btn")
  if l_btn == nil then
    return false
  end
  l_btn.svar.npclevel = level
  l_btn.svar.npcid = id
  local g_btn = ctrl:search("giveup_btn")
  if g_btn == nil then
    return false
  end
  g_btn.svar.npcid = id
  return true
end
function btn_kchallenge_giveup(btn)
  local function send_impl()
    set_visible(false)
    local v = sys.variant()
    v:set(packet.key.knight_pk_npc_cha_id, btn.svar.npcid)
    bo2.send_variant(packet.eCTS_UI_Knight_GiveUp, v)
  end
  ui_widget.ui_msg_box.show_common({
    style_uri = L("$widget/msg_box.xml"),
    style_name = L("cmn_msg_box_common"),
    btn2 = true,
    text = ui.get_text("knight|kc_giveup"),
    modal = true,
    close_on_leavascn = true,
    init = function(data)
      local w = data.window
    end,
    callback = function(ret)
      local window = ret.window
      if ret.result == 1 then
        send_impl(window, 1)
      end
    end
  })
end
function btn_kchallenge_leveldown(btn)
  local function send_impl()
    local v = sys.variant()
    v:set(packet.key.knight_pk_npc_cha_id, btn.svar.npcid)
    bo2.send_variant(packet.eCTS_UI_Knight_LevelDown, v)
  end
  ui_widget.ui_msg_box.show_common({
    style_uri = L("$widget/msg_box.xml"),
    style_name = L("cmn_msg_box_common"),
    btn2 = true,
    text = ui.get_text("knight|kc_leveldown"),
    modal = true,
    close_on_leavascn = true,
    init = function(data)
      local w = data.window
    end,
    callback = function(ret)
      local window = ret.window
      if ret.result == 1 then
        send_impl(window, 1)
      end
    end
  })
end
function btn_kchallenge_rand(btn)
  if btn and btn.svar.npcid ~= nil then
    local v = sys.variant()
    v:set(packet.key.knight_pk_npc_cha_id, btn.svar.npcid)
    bo2.send_variant(packet.eCTS_UI_Knight_RandNpc, v)
  end
end
function btn_buy_point(btn)
  local send_impl = function(cnt)
    local v = sys.variant()
    v:set(packet.key.cmn_val, cnt)
    bo2.send_variant(packet.eCTS_UI_Knight_BuyPoint, v)
  end
  local max_cnt = ITEM_MAX_POINT - g_items_challenge.itempoints
  local text1 = ui.get_text("knight|kc_point_need")
  local v = sys.variant()
  v:set("point", ITEM_MAX_BUYPOINT)
  local inputnum = g_items_challenge.buypoints
  if inputnum == 0 then
    inputnum = 1
  end
  local rmb = get_rmb_by_point(inputnum)
  v:set("money", rmb)
  local text2 = sys.mtf_merge(v, ui.get_text("knight|kc_point_max"))
  show_cmn_msgbox(text1, text2, max_cnt, send_impl, inputnum, 2)
end
function on_drop_sale_item(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down then
    return
  end
  ui.clean_drop()
  if ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
  elseif ui_widget.check_drop(data, ui_widget.c_drop_type_ride) then
  end
end
function edit_numberall(btn)
  local w = btn.topper
  local b = w:search("box_input")
  local svar = w.svar.deal_data
  local max = svar.max_count
  b.text = max
  if svar.type == 2 then
    local rmb = get_rmb_by_point(max)
    local v = sys.variant()
    v:set("money", rmb)
    local text2 = sys.mtf_merge(v, ui.get_text("knight|kc_point_max"))
    g_rmb_show.mtf = text2
  end
end
local get_item_count = function(onlyid)
  local item_info = ui.item_of_only_id(onlyid)
  if item_info then
    return true, item_info.count, item_info.excel_id
  end
end
function get_rmb_by_point(point)
  local rmb = 0
  if point <= 500 then
    rmb = math.ceil(point / 2)
  elseif point > 500 and point <= 1000 then
    rmb = point - 500 + 250
  elseif point > 1000 then
    rmb = (point - 1000) * 2 + 500 + 250
  end
  return rmb
end
function on_input_key(w, key, flag)
  local p = w.topper
  local svar = p.svar.deal_data
  if svar.type == 1 then
    return
  end
  local num = w.text.size
  if num > w.limit then
    return
  end
  if (key >= ui.VK_0 and key <= ui.VK_9 or key == ui.VK_BACK or key >= ui.VK_NUMPAD0 and key <= ui.VK_NUMPAD9) and not flag.down and not flag.alt then
    local point = w.text.v_int
    local rmb = get_rmb_by_point(point)
    local v = sys.variant()
    v:set("point", ITEM_MAX_BUYPOINT)
    v:set("money", rmb)
    local text2 = sys.mtf_merge(v, ui.get_text("knight|kc_point_max"))
    g_rmb_show.mtf = text2
  else
    ui_widget.ui_msg_box.on_input_key(w, key, flag)
  end
end
function show_cmn_msgbox(text1, text2, cnt, sendfn, inputnum, type)
  ui_widget.ui_msg_box.show_common({
    style_uri = "$frame/knight/kchallenge_item.xml",
    style_name = L("kitem_msgbox"),
    modal = true,
    close_on_leavascn = true,
    input = 1,
    limit = 4,
    number_only = true,
    init = function(data)
      local w = data.window
      data.max_count = cnt
      data.type = type
      w.svar.deal_data = data
      w:search("rv_text_need").mtf = text1
      w:search("rv_text_max").mtf = text2
      w:search("box_input").focus_able = cnt > 1
      w:search("box_input").text = inputnum
      w:search("btn_confirm2").visible = true
      w:search("btn_cancel2").visible = true
      w:search("p_num").visible = true
      w:search("p_num").text = "/ " .. cnt
    end,
    callback = function(ret)
      if ret.result == 1 then
        local window = ret.window
        local input = window:search("box_input").text.v_int
        sendfn(input)
      end
    end
  })
end
function may_add_item(info)
  if info == nil then
    return
  end
  local excelid = info.excel_id
  local sitem = bo2.gv_knight_spoint:find(excelid)
  if sitem == nil then
    ui_chat.show_ui_text_id(2516)
    return false
  end
  return true
end
function add_kchallenge_item(onlyid)
  local function send_impl(cnt)
    local v = sys.variant()
    v:set(packet.key.item_key, onlyid)
    v:set(packet.key.item_count, cnt)
    bo2.send_variant(packet.eCTS_UI_Knight_AddItem, v)
  end
  local item_info = ui.item_of_only_id(onlyid)
  if not item_info then
    return
  end
  if may_add_item(item_info) == false then
    return
  end
  local item_count = item_info.count
  local excelid = item_info.excel_id
  if item_count == 1 then
    return send_impl(1)
  end
  local perpoint = get_item_perpoint(excelid)
  local text1 = ui.get_text("knight|kc_num_need")
  local text2 = ui.get_text("knight|kc_num_max")
  local v = sys.variant()
  v:set("point", perpoint)
  text2 = sys.mtf_merge(v, text2)
  if item_count > ITEM_MAX_NUM then
    item_count = ITEM_MAX_NUM
  end
  local inputnum = 1
  show_cmn_msgbox(text1, text2, item_count, send_impl, inputnum, 1)
end
function item_rbutton_use(info)
  local only_id = info.only_id
  add_kchallenge_item(only_id)
end
function item_rbutton_tip(info)
  if ui_knight.ui_kchallenge.get_visible() then
    return ui.get_text("knight|rbtn_item_put")
  end
  return nil
end
function item_rbutton_check(info)
  local txt = item_rbutton_tip(info)
  return txt ~= nil
end
function on_saleitem_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_rbutton_click then
    if not card.info then
      return
    end
    local v = sys.variant()
    v:set(packet.key.item_key, card.info.only_id)
    bo2.send_variant(packet.eCTS_UI_Knight_RemoveItem, v)
  end
end
function remove_all_items()
  if g_items_challenge == nil or g_items_challenge.cards == nil then
    return
  end
  for i, v in ipairs(g_items_challenge.cards) do
    local card = v:search("card")
    if card ~= nil then
      if card.only_id ~= L("0") then
        local v = sys.variant()
        v:set(packet.key.item_key, card.only_id)
        bo2.send_variant(packet.eCTS_UI_Knight_RemoveItem, v)
      end
      if card.info ~= nil then
        show_points_and_rate(card.info, -1)
        ui.item_remove(key)
        card.only_id = 0
      end
    end
  end
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  if not excel then
    return
  end
  local stk = sys.mtf_stack()
  local info = card.info
  if info == nil then
    return
  end
  ui_tool.ctip_make_item(stk, excel, card.info)
  local stk_use
  ui_tool.ctip_push_operation(stk, ui.get_text("common|stall_owner_clear"))
  local ptype = excel.ptype
  if ptype ~= nil and (ptype.group == bo2.eItemGroup_Equip or ptype.group == bo2.eItemGroup_Avata) then
    stk_use = ui_item.tip_get_using_equip(excel)
  end
  ui_tool.ctip_show(card, stk, stk_use)
end
function get_item_perpoint(excelid)
  local per_point = 0
  local sitem = bo2.gv_knight_spoint:find(excelid)
  if sitem ~= nil then
    per_point = sitem.spoint
  end
  return per_point
end
function get_rate_line(point)
  local size = bo2.gv_knight_accumulate_points.size
  for i = size - 1, 0, -1 do
    local line = bo2.gv_knight_accumulate_points:get(i)
    if line ~= nil and (point >= line.min_point and point <= line.max_point or i == 0) then
      return line
    end
  end
end
function show_rate()
  local sum_points = g_items_challenge.itempoints + g_items_challenge.buypoints
  local rateline = get_rate_line(sum_points)
  if rateline == nil then
    return
  end
  if sum_points < ITEM_MIN_POINT then
    local param = sys.variant()
    param:set("num", ITEM_MIN_POINT)
    g_rate.mtf = sys.mtf_merge(param, ui.get_text("knight|point_less"))
    g_rand_btn.enable = false
    return
  elseif sum_points > ITEM_MAX_POINT then
    local param = sys.variant()
    param:set("num", ITEM_MAX_POINT)
    g_rate.mtf = sys.mtf_merge(param, ui.get_text("knight|point_more"))
    g_rand_btn.enable = false
    return
  end
  local v = sys.variant()
  local text = ui.get_text("knight|kc_rate_text")
  local nutext = L("")
  local allCD = false
  for i = 0, 2 do
    if rateline.level_rate[i].size == 2 then
      local level = rateline.level_rate[i][0]
      v:set("level" .. i, level .. text)
      if level >= GCD_MIN_LEVEL and g_items_challenge.GCD[level - GCD_MIN_LEVEL] == false then
        v:set("rate" .. i, ui.get_text("knight|kc_rate_cd"))
        allCD = allCD or false
      else
        v:set("rate" .. i, rateline.level_rate[i][1] .. "%")
        allCD = allCD or true
      end
    else
      v:set("level" .. i, nutext)
      v:set("rate" .. i, nutext)
    end
  end
  g_rate.mtf = sys.mtf_merge(v, ui.get_text("knight|kc_rate"))
  if allCD == false or sum_points < ITEM_MIN_POINT then
    g_rand_btn.enable = false
  else
    g_rand_btn.enable = true
  end
end
function sum_points(info, del, buycnt)
  if info ~= nil then
    local sumpoint = 0
    local excelid = info.excel_id
    local perpoint = get_item_perpoint(excelid)
    local cnt = info.count
    sumpoint = perpoint * cnt * del
    g_items_challenge.itempoints = g_items_challenge.itempoints + sumpoint
  elseif buycnt ~= nil then
    g_items_challenge.buypoints = buycnt
  end
end
function after_points_fixed()
  local sumpoints = g_items_challenge.itempoints + g_items_challenge.buypoints
  if sumpoints < 0 then
    sumpoints = 0
  elseif sumpoints > ITEM_MAX_MOST_POINT then
    sumpoints = ITEM_MAX_MOST_POINT
  end
  g_point.text = sumpoints
  show_rate()
  if sumpoints >= ITEM_MIN_POINT and sumpoints <= ITEM_MAX_POINT then
    g_rand_btn.enable = true
  else
    g_rand_btn.enable = false
  end
end
function show_points_and_rate(info, del, buycnt)
  if info == nil and buycnt == nil then
    return
  end
  sum_points(info, del, buycnt)
  after_points_fixed()
end
function on_ui_visible(ctrl, vis)
  if vis == false and g_items_challenge ~= nil then
    set_visible(vis)
  end
end
function set_GCD_value(level, cdvalue)
  g_items_challenge.GCD[level] = cdvalue
end
function set_point_limit()
  local size = bo2.gv_knight_accumulate_points.size
  if size <= 0 then
    return
  end
  local line_max = bo2.gv_knight_accumulate_points:get(size - 1)
  if line_max == nil then
    return
  end
  local line_min = bo2.gv_knight_accumulate_points:get(0)
  if line_min == nil then
    return
  end
  ITEM_MAX_POINT = line_max.max_point
  ITEM_MIN_POINT = line_min.min_point
end
function on_init(ctrl)
  ITEM_MAX_NUM = bo2.gv_define:find(1111).value.v_int
  ITEM_MAX_BUYPOINT = bo2.gv_define:find(1110).value.v_int
  ITEM_MAX_MOST_POINT = bo2.gv_define:find(1109).value.v_int
  set_point_limit()
  g_items_challenge = {}
  g_items_challenge.cards = {}
  g_items_challenge.itempoints = 0
  g_items_challenge.buypoints = 0
  g_items_challenge.GCD = {
    [0] = true,
    [1] = true,
    [2] = true
  }
  local ctop = ctrl:search("item_panel")
  for i = 0, size_x - 1 do
    for j = 0, size_y - 1 do
      local ctrl = ui.create_control(ctop, "panel")
      ctrl:load_style(c_style_file, c_cell_item)
      ctrl.offset = ui.point(j * c_cell_x, i * c_cell_y)
      local card = ctrl:search("card")
      card:insert_on_mouse(on_saleitem_mouse)
      table.insert(g_items_challenge.cards, ctrl)
    end
  end
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
