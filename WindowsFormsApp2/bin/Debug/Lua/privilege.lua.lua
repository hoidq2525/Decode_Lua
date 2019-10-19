local tag = "supermarket.privilege"
local bhighlight = false
local c_menu_type_iron = 1
local c_menu_type_shop = 2
local function updatePanel()
  local lv = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_RMBPrivilege)
  local vipExcel = bo2.gv_supermarket_vip:find(lv)
  if not vipExcel then
    return
  end
  w_privilegeLevel.mtf = ui_widget.merge_mtf({level = lv}, ui.get_text("supermarket|privilegeLevel"))
  local hours = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_RMBPrivilegeHours)
  w_privilegeDbExp.enable = hours > 0 and 0 < vipExcel.dbexp
  w_fastdb.visible = w_privilegeDbExp.enable
  w_privilegeGift.enable = hours > 0 and 0 < vipExcel.gift and bo2.is_cooldown_over(50065)
  w_privilegeFlicker.visible = hours <= 0 and not w_privilegeFlicker.svar.click
  w_privilegeFlicker.suspended = hours > 0 or w_privilegeFlicker.svar.click
  w_privilegeShop.enable = hours > 0 and test_func_menu(c_menu_type_shop)
  w_fastshop.visible = w_privilegeShop.enable
  w_privilegeIron.enable = hours > 0 and test_func_menu(c_menu_type_iron)
  w_fastiron.visible = w_privilegeIron.enable
  if hours > 0 then
    local upt = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_RMBPrivilegeTimeBeg)
    local t = upt + hours * 60 * 60
    t = os.date("%Y-%m-%d", t)
    w_privilegeStatus.text = ui_widget.merge_mtf({
      ["yyyy-mm-dd"] = t
    }, ui.get_text("supermarket|privilegeStatus1"))
    w_privilegeStatus.color = ui.make_color("FF0EAB62")
    w_privilegeSpeed.text = ui_widget.merge_mtf({
      speed = vipExcel.dayexp
    }, ui.get_text("supermarket|privilegeSpeed"))
    w_privilegeBuy.text = ui.get_text("supermarket|privilegeBuy1")
    w_privilegeBtn.image = "$image/supermarket/vip1.png|4,5,57,256"
  else
    w_privilegeStatus.text = ui.get_text("supermarket|privilegeStatus0")
    w_privilegeStatus.xcolor = "FFC1C1C1"
    w_privilegeSpeed.text = ui_widget.merge_mtf({speed = 0}, ui.get_text("supermarket|privilegeSpeed"))
    w_privilegeBuy.text = ui.get_text("supermarket|privilegeBuy0")
    w_privilegeBtn.image = "$image/supermarket/vip0.png|4,5,57,256"
  end
  local Exp = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_RMBPrivilegeExp)
  w_privilegeExp:search("exp").text = sys.format("%d/%d", Exp, vipExcel.nextexp)
  local len = 435 * Exp / vipExcel.nextexp
  w_privilegeExp:search("bar").dx = len
  w_privilegeExp:search("barcap").margin = ui.rect(len + 7, 0, 0, 0)
  for i = 1, w_privilegeList.item_count do
    local item = w_privilegeList:item_get(i - 1)
    local check = item:search("check")
    local txt = item:search("lb_text")
    if hours > 0 and lv >= i then
      check.xcolor = "FFFFFFFF"
      txt.color = ui.make_color("FF0EAB62")
    elseif lv >= i then
      check.xcolor = "FF333333"
      txt.xcolor = "FFFFFFFF"
    else
      check.xcolor = "00000000"
      txt.xcolor = "FF9C9C9C"
    end
  end
end
local BoxGiftID = function(i)
  return 5000 + i
end
function highlight_init(...)
  if not sys.check(w_privilegeList) then
    return
  end
  local lv = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_RMBPrivilege)
  local hours = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_RMBPrivilegeHours)
  local high_t = {}
  for i, v in ipairs(arg) do
    v = tonumber(v)
    if not v then
      return
    end
    if lv < v then
      local item = listview:item_get(v - 1)
      if item then
        local check = item:search("check")
        check.image = "$image/supermarket/arrow.png|0,0,32,32"
        bhighlight = true
        table.insert(high_t, check)
      end
    end
  end
  local step = 0
  return function()
    for _, v in pairs(high_t) do
      local x = step % 13 - 1
      v.margin = ui.rect(x, 0, -x, 0)
    end
    step = step + 1
    if step >= 130000 then
      step = 0
    end
  end
end
local highlight_anim
function highlight_item(...)
  updatePanel()
  bhighlight = true
  highlight_anim = highlight_init(unpack(arg))
  htimer.suspended = false
end
function highlight_timer()
  if bhighlight then
    highlight_anim()
  end
end
function testhighlight()
  highlight_item(1, 6)
end
function cancel_highlight()
  bhighlight = false
  htimer.suspended = true
  updatePanel()
end
local canGetGift = false
function privilege_checkGift()
  if not bo2.player then
    return
  end
  local rst = bo2.is_cooldown_over(50065)
  if rst and not canGetGift then
    updatePanel()
    canGetGift = true
  end
  if not rst and canGetGift then
    updatePanel()
    canGetGift = false
  end
  if not w_privilege.visible and bhighlight then
    cancel_highlight()
  end
  if w_privilege.visible and sys.check(bo2.player) then
    for i = 0, w_privilegeList.item_count - 1 do
      local giftid = BoxGiftID(i + 1)
      local n = bo2.gv_gift_award:find(giftid)
      local btn = w_privilegeList:item_get(i):search("btn_gift")
      local flag = 0
      local gift_vis = false
      if n ~= nil then
        flag = bo2.player:get_flag_bit(n.flag_id)
        gift_vis = ui_gift_award.ui_svrbeg2.check_on_visible(n)
      else
        btn.mouse_able = false
      end
      btn.svar.ok = flag ~= 1 and gift_vis
      local pic = btn:search("got")
      if flag == 1 then
        pic.visible = true
        pic.image = "$image/xinshou/1.png|10,12,45,40"
      elseif not gift_vis then
        pic.visible = true
        pic.image = "$image/xinshou/gift_btn.png|10,204,45,40"
      else
        pic.visible = false
      end
    end
  end
end
function privilege_gift_tip(tip)
  local level = tip.owner:upsearch_type("ui_list_item").index + 1
  local giftid = BoxGiftID(level)
  local n = bo2.gv_gift_award:find(giftid)
  if n == nil then
    return
  end
  local stk = sys.mtf_stack()
  stk:merge({level = level}, ui.get_text("supermarket|giftbtntip1"))
  local award_items = n.award_items
  for i = 1, award_items.size do
    stk:raw_format([[

<i:%d>]], award_items[i - 1])
  end
  ui_widget.tip_make_view(tip.view, stk.text)
end
local make_func_digit = function(n)
  return sys.format("<c+:00FF00>%d<c->", n)
end
local make_func_percent = function(n)
  return sys.format("<c+:00FF00>%d%%<c->", n)
end
local make_func_menu = function(x)
  local menu_name = x.menu_name
  if menu_name.size > 0 then
    return menu_name
  end
  local func_type = x.func_type
  local func
  if func_type == 1 then
    func = bo2.gv_npc_func:find(x.func_id)
    local flag, type = check_level_quest(x.func_id)
    if not flag and type == 1 then
      local tmp_text = ui_widget.merge_mtf({
        level = func.required_level
      }, ui.get_text("supermarket|open_level"))
      menu_name = func.text .. "(" .. tmp_text .. ")"
    else
      menu_name = func.text
    end
  elseif func_type == 2 then
    func = bo2.gv_npc_shop:find(x.func_id)
    menu_name = func.text
  end
  return menu_name
end
local function make_func_tip(stk, vip_level, is_simple)
  stk:raw_push("<a+:m><lb:art,18,,FFFF00|")
  stk:merge({level = vip_level}, ui.get_text("supermarket|privilege_level"))
  stk:raw_push("><a->")
  local has = false
  local function newline()
    if has then
      stk:raw_push("\n")
    else
      has = true
    end
  end
  local function newline_reset()
    has = false
  end
  local prev_vip_excel = bo2.gv_supermarket_vip:find(vip_level - 1)
  local vip_excel = bo2.gv_supermarket_vip:find(vip_level)
  local is_enter_new = false
  local function push_new()
    is_enter_new = true
    stk:raw_format("<c+:FF0000>%s<c-><c+:0EAB62>", ui.get_text("supermarket|func_new"))
  end
  local function enter_new(name)
    is_enter_new = false
    local val = vip_excel[name]
    if val <= 0 then
      return false
    end
    newline()
    if prev_vip_excel == nil or val ~= prev_vip_excel[name] then
      push_new()
    end
    return true
  end
  local function enter_list_new(count, is_new)
    if count == 0 then
      return false
    end
    newline()
    if is_new then
      push_new()
    end
    return true
  end
  local function leave_new()
    if is_enter_new then
      is_enter_new = false
      stk:raw_push("<c->")
    end
  end
  ui_tool.ctip_push_sep(stk)
  newline_reset()
  if enter_new("dayexp") then
    stk:merge({
      n = make_func_digit(vip_excel.dayexp)
    }, ui.get_text("supermarket|day_exp"))
    leave_new()
  end
  if enter_new("gift") then
    stk:push(ui.get_text("supermarket|day_gift"))
    stk:raw_format("<i:%d>", vip_excel.gift)
    leave_new()
  end
  if enter_new("jifen") then
    stk:merge({
      n = make_func_percent(vip_excel.jifen)
    }, ui.get_text("supermarket|jifen"))
    leave_new()
  end
  if vip_excel.dbexp > 0 or 0 < vip_excel.dbexpHour or 0 < vip_excel.cultoexp or 0 < vip_excel.battleexp then
    ui_tool.ctip_push_sep(stk)
    newline_reset()
    if enter_new("dbexp") then
      stk:push(ui.get_text("supermarket|func_dexp"))
      leave_new()
    end
    if enter_new("dbexpHour") then
      stk:merge({
        hour = make_func_digit(vip_excel.dbexpHour)
      }, ui.get_text("supermarket|week_dexp_hours"))
      leave_new()
    end
    if enter_new("cultoexp") then
      stk:merge({
        n = make_func_percent(vip_excel.cultoexp)
      }, ui.get_text("supermarket|cultoexp"))
      leave_new()
    end
    if enter_new("battleexp") then
      stk:merge({
        n = make_func_percent(vip_excel.battleexp)
      }, ui.get_text("supermarket|battle_exp"))
      leave_new()
    end
  end
  if 0 < vip_excel.knight_gift_no_cd or 0 < vip_excel.pkcnt or 0 < vip_excel.pkexp or 0 < vip_excel.clonecnt or 0 < vip_excel.cloneexp then
    ui_tool.ctip_push_sep(stk)
    newline_reset()
    if enter_new("knight_gift_no_cd") then
      stk:raw_push(ui.get_text("supermarket|knight_gift_no_cd"))
      leave_new()
    end
    if enter_new("pkcnt") then
      stk:merge({
        n = sys.format("<c+:00FF00>%d<c->", vip_excel.pkcnt)
      }, ui.get_text("supermarket|day_pkcnt"))
      leave_new()
    end
    if enter_new("pkexp") then
      stk:merge({
        n = sys.format("<c+:00FF00>%d%%<c->", vip_excel.pkexp)
      }, ui.get_text("supermarket|day_pkexp"))
      leave_new()
    end
    if enter_new("clonecnt") then
      stk:merge({
        n = sys.format("<c+:00FF00>%d<c->", vip_excel.clonecnt)
      }, ui.get_text("supermarket|day_clonecnt"))
      leave_new()
    end
    if enter_new("cloneexp") then
      stk:merge({
        n = sys.format("<c+:00FF00>%d%%<c->", vip_excel.cloneexp)
      }, ui.get_text("supermarket|day_cloneexp"))
      leave_new()
    end
  end
  if 0 < vip_excel.camp_repute or 0 < vip_excel.reduce_repute then
    ui_tool.ctip_push_sep(stk)
    newline_reset()
    if enter_new("camp_repute") then
      stk:merge({
        n = sys.format("<c+:00FF00>%d%%<c->", vip_excel.camp_repute)
      }, ui.get_text("supermarket|camp_repute"))
      leave_new()
    end
    if enter_new("reduce_repute") then
      stk:merge({
        n = sys.format("<c+:00FF00>%d%%<c->", vip_excel.reduce_repute)
      }, ui.get_text("supermarket|reduce_repute"))
      leave_new()
    end
  end
  local tudun_list = {}
  local tudun_new = false
  for i = 0, bo2.gv_scn_tudun.size - 1 do
    local tudun_excel = bo2.gv_scn_tudun:get(i)
    if 0 < tudun_excel.vip and vip_level >= tudun_excel.vip then
      table.insert(tudun_list, tudun_excel)
      if tudun_excel.vip == vip_level then
        tudun_new = true
      end
    end
  end
  local shop_list = {}
  local shop_new = false
  local func_list = {}
  local func_new = false
  for i = 0, bo2.gv_supermarket_vip_func.size - 1 do
    local func_excel = bo2.gv_supermarket_vip_func:get(i)
    if vip_level >= func_excel.vip_level then
      if func_excel.menu_type == 1 then
        table.insert(func_list, func_excel)
        if func_excel.vip_level == vip_level then
          func_new = true
        end
      elseif func_excel.menu_type == 2 then
        table.insert(shop_list, func_excel)
        if func_excel.vip_level == vip_level then
          shop_new = true
        end
      end
    end
  end
  local cd_list = {}
  local cd_new = false
  for i = 0, bo2.gv_supermarket_vip_cd.size - 1 do
    local cd_excel = bo2.gv_supermarket_vip_cd:get(i)
    local idx = -1
    local x_vip_level = cd_excel.vip_level
    local x_reduce_time = cd_excel.reduce_time
    for t = 0, x_vip_level.size - 1 do
      local xv = x_vip_level[t]
      if xv > 0 and vip_level >= xv then
        idx = t
      end
    end
    if idx >= 0 then
      table.insert(cd_list, {excel = cd_excel, index = idx})
      if x_vip_level[idx] == vip_level then
        cd_new = true
      end
    end
  end
  if is_simple then
    local tudun_count = #tudun_list
    local shop_count = #shop_list
    local func_count = #func_list
    local cd_count = #cd_list
    if tudun_count > 0 or shop_count > 0 or func_count > 0 or cd_count > 0 then
      ui_tool.ctip_push_sep(stk)
      newline_reset()
      if enter_list_new(cd_count, cd_new) then
        stk:merge({
          n = make_func_digit(cd_count)
        }, ui.get_text("supermarket|list_cd_x"))
        leave_new()
      end
      if enter_list_new(tudun_count, tudun_new) then
        stk:merge({
          n = make_func_digit(tudun_count)
        }, ui.get_text("supermarket|list_tudun_x"))
        leave_new()
      end
      if enter_list_new(shop_count, shop_new) then
        stk:merge({
          n = make_func_digit(shop_count)
        }, ui.get_text("supermarket|list_shop_x"))
        leave_new()
      end
      if enter_list_new(func_count, func_new) then
        stk:merge({
          n = make_func_digit(func_count)
        }, ui.get_text("supermarket|list_func_x"))
        leave_new()
      end
    end
  else
    local cd_count = #cd_list
    if cd_count > 0 then
      ui_tool.ctip_push_sep(stk)
      newline_reset()
      newline()
      stk:raw_format("<a+:m><c+:FF6600>%s<c-><a->", ui.get_text("supermarket|list_cd_title"))
      for i, x in ipairs(cd_list) do
        newline()
        local excel = x.excel
        local index = x.index
        if excel.vip_level[index] == vip_level then
          push_new()
        end
        stk:raw_format("%s<space:1><a+:r>-%s<a->", excel.name, ui_tool.ctip_time_text(excel.reduce_time[index]))
        leave_new()
      end
    end
    local tudun_count = #tudun_list
    if tudun_count > 0 then
      ui_tool.ctip_push_sep(stk)
      newline_reset()
      newline()
      stk:raw_format("<a+:m><c+:FF6600>%s<c-><a->", ui.get_text("supermarket|list_tudun_title"))
      for i, x in ipairs(tudun_list) do
        newline()
        if x.vip == vip_level then
          push_new()
        end
        stk:raw_format("%s<space:1><a+:r><bm:%d><a->", x.name, x.money)
        leave_new()
      end
    end
    local shop_count = #shop_list
    if shop_count > 0 then
      ui_tool.ctip_push_sep(stk)
      newline_reset()
      newline()
      stk:raw_format("<a+:m><c+:FF6600>%s<c-><a->", ui.get_text("supermarket|list_shop_title"))
      for i, x in ipairs(shop_list) do
        newline()
        if x.vip_level == vip_level then
          push_new()
        end
        stk:raw_push(make_func_menu(x))
        leave_new()
      end
    end
    local func_count = #func_list
    if func_count > 0 then
      ui_tool.ctip_push_sep(stk)
      newline_reset()
      newline()
      stk:raw_format("<a+:m><c+:FF6600>%s<c-><a->", ui.get_text("supermarket|list_func_title"))
      for i, x in ipairs(func_list) do
        newline()
        if x.vip_level == vip_level then
          push_new()
        end
        stk:raw_push(make_func_menu(x))
        leave_new()
      end
    end
  end
  if is_simple then
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("supermarket|left_click_note"), ui_tool.cs_tip_color_operation)
  end
end
function privilege_func_tip(tip)
  local level = tip.owner:upsearch_type("ui_list_item").index + 1
  local stk = sys.mtf_stack()
  make_func_tip(stk, level, true)
  ui_widget.tip_make_view(tip.view, stk.text)
end
function privilege_func_mouse(ctrl, msg)
  if msg ~= ui.mouse_lbutton_click then
    return
  end
  local level = ctrl:upsearch_type("ui_list_item").index + 1
  local stk = sys.mtf_stack()
  make_func_tip(stk, level, false)
  local privilege_desc = rawget(_M, "w_privilege_desc")
  if privilege_desc == nil then
    privilege_desc = ui.create_control(ui_main.w_top, "panel")
    w_privilege_desc = privilege_desc
    privilege_desc:load_style("$frame/supermarket_v2/privilege.xml", "privilege_desc")
  end
  privilege_desc.visible = true
  privilege_desc:move_to_head()
  privilege_desc.dy = 800
  privilege_desc:search("rb_text").mtf = stk.text
  privilege_desc:tune_y("rb_text")
  if privilege_desc.dy > 400 then
    privilege_desc.dy = 400
  end
end
function privilege_get_gift(btn)
  if btn.svar.ok then
    local level = btn:upsearch_type("ui_list_item").index + 1
    local v = sys.variant()
    v:set(packet.key.cmn_id, BoxGiftID(level))
    bo2.send_variant(packet.eCTS_GiftAward_Get, v)
  end
end
function check_privilegeBoxGift()
  for i = 1, 9 do
    local giftid = BoxGiftID(i)
    local n = bo2.gv_gift_award:find(giftid)
    if bo2.player:get_flag_bit(n.flag_id) ~= 1 and ui_gift_award.ui_svrbeg2.check_on_visible(n) then
      return true
    end
  end
  return w_privilegeGift.enable
end
function check_and_get_once()
  if w_privilegeGift.enable then
    privilegeFetchGift()
  end
  local time_e = 20
  for i = 1, 9 do
    do
      local giftid = BoxGiftID(i)
      local n = bo2.gv_gift_award:find(giftid)
      local function do_get()
        if bo2.player:get_flag_bit(n.flag_id) ~= 1 and ui_gift_award.ui_svrbeg2.check_on_visible(n) then
          local v = sys.variant()
          v:set(packet.key.cmn_id, giftid)
          bo2.send_variant(packet.eCTS_GiftAward_Get, v)
        end
        if i == 9 then
          ui_gift_award.check_btn_encircle()
        end
      end
      bo2.AddTimeEvent(time_e * i, do_get)
    end
  end
end
local c_dy_min = 40
local c_lb_text = L("lb_text")
local function privilege_list_update_view(view)
  for i = 0, w_privilegeList.item_count - 1 do
    local item = w_privilegeList:item_get(i)
    item:tune_y(c_lb_text)
    if item.dy < c_dy_min then
      item.dy = c_dy_min
    end
  end
end
function on_privilege_move(view)
  view:insert_post_invoke(privilege_list_update_view)
end
function privilegeInit()
  w_privilege:apply_dock(true)
  bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, function()
    bo2.player:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_RMBPrivilege, updatePanel)
    bo2.player:insert_on_flagmsg(bo2.eFlagType_Int16, bo2.ePlayerFlagInt16_RMBPrivilegeExp, updatePanel)
    bo2.player:insert_on_flagmsg(bo2.eFlagType_Int16, bo2.ePlayerFlagInt16_RMBPrivilegeHours, updatePanel)
  end, tag)
  local view = w_privilegeList
  view:item_clear()
  for i = 1, bo2.gv_supermarket_vip.size do
    local vip = bo2.gv_supermarket_vip:get(i - 1)
    local txt = bo2.gv_text:find(vip.descid).text
    local data = {text = txt}
    local item = view:item_append()
    item:load_style("$frame/supermarket_v2/privilege.xml", "privilegeItem")
    item:search(c_lb_text).text = txt
    if i % 2 == 1 then
      item:search("color").xcolor = "6F000000"
    end
  end
  privilege_list_update_view(view)
  ui_gift_award.push_check_timer("privilege", check_privilegeBoxGift)
  ui_gift_award.push_check_get_all("privilege", check_and_get_once)
end
local g_privilegeItems = {
  {d = 7, m = 50},
  {d = 30, m = 200},
  {d = 90, m = 550},
  {d = 365, m = 2000}
}
local reg = ui_packet.recv_wrap_signal_insert
reg(packet.eSTC_Supermarket, function(cmd, data)
  local cmntype = data:get(packet.key.cmn_type).v_int
  if cmntype == bo2.eSupermarketUI_Announce and data:has(packet.key.buy_privilege) then
    g_privilegeItems = {}
    local items = data:get(packet.key.buy_privilege):split_to_int_array(L("*"))
    for i = 1, items.size, 3 do
      local day = items:fetch_v(i - 1).v_int
      local money = items:fetch_v(i).v_int
      local txtln = bo2.gv_text:find(items:fetch_v(i + 1).v_int)
      local txt
      if txtln then
        txt = txtln.text
      end
      table.insert(g_privilegeItems, {
        d = day,
        m = money,
        txt = txt
      })
    end
  end
end, "ui_supermarket2.privilege")
local sendBuyPrivilege = function(sel)
  local v = sys.variant()
  v:set(packet.key.buy_privilege, sel.d)
  v:set(packet.key.cmn_money, sel.m)
  v:set(packet.key.multi_goods, "1*" .. sel.d)
  v:set(packet.key.cmn_type, bo2.eSupermarket_Privilege)
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
end
function privilegeClickBuy()
  if bo2.player then
    local hours = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_RMBPrivilegeHours)
    if hours >= 43800 then
      ui_chat.show_ui_text_id(72144)
      return
    end
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/supermarket_v2/privilege.xml",
    style_name = "buydlg",
    modal = true,
    init = function(data)
      local w = data.window
      local lb = w:search("lb")
      g_rmb = g_rmb or 9999
      lb.mtf = ui_widget.merge_mtf({rmb = g_rmb}, ui.get_text("supermarket|privilegeBuyLb"))
      local items = w:search("items")
      local ci = 0
      for i, v in ipairs(g_privilegeItems) do
        local child = items:control_get(i - 1)
        if child then
          child.svar = v
          local str = ui_widget.merge_mtf({
            day = v.d,
            rmb = v.m,
            txt = v.txt
          }, ui.get_text("supermarket|privilegeBuyItem"))
          if v.m > g_rmb then
            str = sys.format("<c+:8C8C8C>%s<c->", str)
          end
          child:search("txt").mtf = str
          child.visible = true
          ci = i
        end
      end
      for i = ci + 1, items.control_size do
        local child = items:control_get(i - 1)
        child.visible = false
      end
    end,
    callback = function(ret)
      if ret.result == 1 then
        local items = ret.window:search("items")
        for i = 1, items.control_size do
          local child = items:control_get(i - 1)
          if child.check then
            if child.svar.m <= g_rmb then
              sendBuyPrivilege(child.svar)
            else
              ui_chat.show_ui_text_id(72161)
            end
          end
        end
      end
    end
  })
end
function privilegeSelectBuy(btn, c)
  if c and btn.svar.m > g_rmb then
    ui_chat.show_ui_text_id(72161)
  end
end
function privilegeOpenDbExp()
  ui_dexp.w_dexpView_main.visible = true
  ui_dexp.w_freeze_button.visible = false
  ui_dexp.w_active_button.parent.visible = true
  ui_dexp.w_dexpView_main:insert_on_visible(function(ctrl, vis)
    if not vis then
      ui_dexp.w_dexpView_main:remove_on_visible("ui_supermarket")
      ui_dexp.w_freeze_button.visible = true
      ui_dexp.w_active_button.parent.visible = true
    end
  end, "ui_supermarket")
end
function privilegeFetchGift()
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eSupermarket_PrivilegeGift)
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
end
local requestIron = function(id)
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eSupermarket_PrivilegeIron)
  v:set(packet.key.talk_excel_id, id)
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
end
local requestShop = function(id)
  local v = sys.variant()
  v[packet.key.cmn_type] = bo2.eSupermarket_PrivilegeShop
  if id ~= nil then
    v[packet.key.cmn_id] = id
  end
  bo2.send_variant(packet.eCTS_UI_Supermarket, v)
end
local c_Refine2014516_usable = ui_widget.get_define_int(50101) == 0
local c_ride_usable = 0 < ui_widget.get_define_int(1094)
local function ride_usable(func)
  return c_ride_usable
end
local func_usable_table = {
  [1] = {
    [bo2.eNpcFunc_Refine2014516] = function(func)
      return c_Refine2014516_usable
    end,
    [bo2.eNpcFunc_RidePetWeaponAddExp] = ride_usable,
    [bo2.eNpcFunc_RidePetWeaponAddSlot] = ride_usable,
    [bo2.eNpcFunc_RidePetWeaponAddSkillExp] = ride_usable,
    [bo2.eNpcFunc_RidePetWeaponAddSkill] = ride_usable
  },
  [2] = {}
}
local function func_usable(func)
  local h = func_usable_table[func.func_type]
  if h == nil then
    return true
  end
  h = h[func.func_id]
  if h == nil then
    return true
  end
  return h(func)
end
local bank_enable = function(func)
  local x = bo2.gv_supermarket_vip_bank_scn:find(bo2.scn.excel.id)
  if x == nil then
    ui_tool.note_insert(ui.get_text("supermarket|bank_scn_note"), "FF0000")
    return false
  end
  return true
end
local func_enable_table = {
  [1] = {
    [bo2.eNpcFunc_Bank] = bank_enable,
    [bo2.eNpcFunc_AccBank] = bank_enable,
    [bo2.eNpcFunc_NewBank] = bank_enable
  },
  [2] = {}
}
local function func_enable(id)
  local func = bo2.gv_supermarket_vip_func:find(id)
  local h = func_enable_table[func.func_type]
  if h == nil then
    return true
  end
  h = h[func.func_id]
  if h == nil then
    return true
  end
  return h(func)
end
function test_func_menu(menu_type)
  local vip_level = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_RMBPrivilege)
  for i = 0, bo2.gv_supermarket_vip_func.size - 1 do
    local func = bo2.gv_supermarket_vip_func:get(i)
    if vip_level >= func.vip_level and func.menu_type == menu_type and func_usable(func) then
      return true
    end
  end
  return false
end
function check_level_quest(id)
  if id >= bo2.eNpcFunc_Null and id <= bo2.eNpcFunc_Max then
    local excel = bo2.gv_npc_func:find(id)
    if excel ~= nil then
      if sys.check(bo2.player) and excel.required_level > 0 then
        local player_lv = bo2.player:get_atb(bo2.eAtb_Level)
        if player_lv < excel.required_level then
          return false, 1
        end
      end
      if 0 < excel.v_required_quests.size then
        local size_quest = excel.v_required_quests.size
        for i = 0, size_quest - 1 do
          if not ui.quest_find_c(excel.v_required_quests[i]) then
            return false, 2
          end
        end
      end
    end
  end
  return true
end
local function show_func_menu(btn, menu_type)
  local vip_level = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_RMBPrivilege)
  local items = {}
  for i = 0, bo2.gv_supermarket_vip_func.size - 1 do
    local func = bo2.gv_supermarket_vip_func:get(i)
    if vip_level >= func.vip_level and func.menu_type == menu_type and func_usable(func) then
      local func_type = func.func_type
      local item
      if func_type == 1 then
        local x = bo2.gv_npc_func:find(func.func_id)
        local flag, type = check_level_quest(func.func_id)
        if flag then
          item = {
            text = x.text
          }
        end
      elseif func_type == 2 then
        local x = bo2.gv_npc_shop:find(func.func_id)
        item = {
          text = x.text
        }
      end
      if item ~= nil then
        item.id = func.id
        item.priority = func.menu_priority
        local n = func.menu_name
        if 0 < n.size then
          item.text = n
        end
        table.insert(items, item)
      end
    end
  end
  local cnt = #items
  if cnt == 0 then
    return
  end
  local function item_event(item)
    func_enable(item.id)
    local v = sys.variant()
    v[packet.key.cmn_type] = bo2.eSupermarket_PrivilegeShop
    v[packet.key.cmn_id] = item.id
    bo2.send_variant(packet.eCTS_UI_Supermarket, v)
  end
  if cnt == 1 then
    item_event(items[1])
    return
  end
  table.sort(items, function(x, y)
    if x.priority ~= y.priority then
      return x.priority > y.priority
    end
    return x.id < y.id
  end)
  ui_tool.show_menu({
    items = items,
    event = item_event,
    source = btn,
    dx = 170
  })
end
function privilegeOpenShop(btn)
  show_func_menu(btn, c_menu_type_shop)
  return
end
function privilegeOpenIron(btn)
  show_func_menu(btn, c_menu_type_iron)
  return
end
