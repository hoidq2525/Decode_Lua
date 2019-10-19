local g_buyItems = {}
local g_1hxm = 120
local g_cfg_ish_uri = L("$cfg/user/%s/%s/ish.xml")
local g_cfg_op
local g_init = false
local g_minite_time = 60
local g_hour_time = g_minite_time * 60
local g_day_time = g_hour_time * 24
function load_config()
  local x = sys.xnode()
  local uri = sys.format(g_cfg_ish_uri, ui_main.g_player_cfg_username, ui_main.g_player_cfg_playername)
  if not x:load(uri) then
    return
  end
  for i = 0, x.size - 1 do
    local t = x:get(i)
    local d = g_cfg_op[tostring(t.name)]
    if d ~= nil then
      d.value = t:get_attribute("value")
    end
  end
end
function save_config()
  local x = sys.xnode()
  for n, v in pairs(g_cfg_op) do
    local t = x:add(n)
    t:set_attribute("value", v.value)
  end
  local uri = sys.format(g_cfg_ish_uri, ui_main.g_player_cfg_username, ui_main.g_player_cfg_playername)
  x:save(uri)
end
function on_init()
  w_buyBtn.text = ui.get_text("ish|ish_buy_btn_name")
  w_bottom1.visible = true
  w_bottom2.visible = false
  w_buy.visible = false
  w_set.visible = true
  for i = 1, 5 do
    local pSet = bo2.gv_ish_set:find(i)
    if pSet.data.size == 3 then
      g_buyItems[i] = {
        type = 1,
        index = i,
        h = pSet.data[0],
        m = pSet.data[1],
        cd = pSet.data[2]
      }
    end
  end
  g_1hxm = bo2.gv_ish_set:find(6).data[0]
end
function on_btn_save()
  for n, v in pairs(g_cfg_op) do
    v.event.save(n)
  end
  save_config()
end
function on_btn_open(btn)
  on_btn_save()
  if bo2.player then
    local iTimer = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_InSideHangTime)
    if iTimer < 60 then
      do
        local ret = false
        ui_widget.ui_msg_box.show_common({
          text = ui.get_text("ish|ish_time_little"),
          callback = function(msg)
            if msg.result == 1 then
              ret = true
            end
          end
        })
        if ret then
          return
        end
      end
    end
    local bfind = false
    local tp = 0
    local tudun_table = bo2.gv_scn_tudun
    local c = tudun_table.size
    for i = 0, c - 1 do
      local excel = tudun_table:get(i)
      if excel.scn_id == bo2.scn.scn_excel.id then
        if excel.money == 0 and bo2.player:get_atb(bo2.eAtb_Level) >= excel.level and excel.vip == 0 then
          bfind = true
          tp = excel.id
        end
        break
      end
    end
    if not bfind then
      ui_chat.show_ui_text_id(73286)
      return
    end
    local v = sys.variant()
    for n, d in pairs(g_cfg_op) do
      v:set(n, d.value)
    end
    v:set("transfer_skill_param", tp)
    local auto_skill = g_cfg_op.auto_skill
    if auto_skill.value == 0 then
      local player_skills = g_cfg_op.player_skills
      if player_skills.value == L("0*0*0*0*0*0") then
        ui_chat.show_ui_text_id(73283)
        return
      end
    end
    v:set("kaiguan", 1)
    bo2.OnInSideHang(bo2.player, v)
  end
  btn.visible = false
  local ish_open = w_bottom1:search("ish_close")
  ish_open.visible = true
end
function on_btn_close(btn)
  on_btn_save()
  if bo2.player then
    local v = sys.variant()
    v:set("kaiguan", 0)
    bo2.OnInSideHang(bo2.player, v)
  end
  btn.visible = false
  local ish_open = w_bottom1:search("ish_open")
  ish_open.visible = true
end
function upDataBuyItem()
  local money = ui_supermarket2.g_rmb
  local items = w_buy:search("items")
  for i = 1, 5 do
    local child = items:control_get(i)
    if child.visible then
      local v = child.svar
      if money < v.m then
        if v.cd == 0 or bo2.is_cooldown_over(v.cd) then
          child.enable = true
          child:search("txt").mtf = ui_widget.merge_mtf({
            id = i,
            hour = v.h,
            money = v.m
          }, ui.get_text("ish|ish_buy_item_no_money"))
        else
          child.enable = false
          child.check = false
          child:search("txt").mtf = ui_widget.merge_mtf({
            id = i,
            hour = v.h,
            money = v.m
          }, ui.get_text("ish|ish_buy_item_no_money_cd"))
        end
      elseif v.cd == 0 or bo2.is_cooldown_over(v.cd) then
        child.enable = true
        child:search("txt").mtf = ui_widget.merge_mtf({
          id = i,
          hour = v.h,
          money = v.m
        }, ui.get_text("ish|ish_buy_item"))
      else
        child.enable = false
        child.check = false
        child:search("txt").mtf = ui_widget.merge_mtf({
          id = i,
          hour = v.h,
          money = v.m
        }, ui.get_text("ish|ish_buy_item_cd"))
      end
    end
  end
  local custom_buy = w_buy:search("custom_buy")
  local show_money = custom_buy:search("txt")
  local count = custom_buy:search("tb_input")
  local hour = count.text.v_int
  local needMoney = hour * g_1hxm
  if money >= needMoney then
    show_money.mtf = ui_widget.merge_mtf({money = needMoney}, ui.get_text("ish|ish_custom_buy_money"))
  else
    show_money.mtf = ui_widget.merge_mtf({money = needMoney}, ui.get_text("ish|ish_custom_buy_money_no_money"))
  end
end
function on_init_buy()
  local items = w_buy:search("items")
  for i, v in ipairs(g_buyItems) do
    local child = items:control_get(i)
    child.svar = v
    child.visible = true
  end
  local custom_buy = items:search("custom_buy")
  ui_widget.ui_count_box.on_init(custom_buy:search("count"), L("1,999"))
  upDataBuyItem()
end
function on_btn_buy_time()
  if w_set.visible then
    on_init_buy()
    w_bottom1.visible = false
    w_bottom2.visible = true
    w_buy.visible = true
    w_set.visible = false
    w_buyBtn.text = ui.get_text("ish|ish_cancel_buy")
  else
    w_bottom1.visible = true
    w_bottom2.visible = false
    w_buy.visible = false
    w_set.visible = true
    w_buyBtn.text = ui.get_text("ish|ish_buy_btn_name")
  end
end
local sendBuyHangTimer = function(sel)
  local v = sys.variant()
  if sel.type == 1 then
    v:set(packet.key.InSideHang_buy_time_package, sel.index)
  else
    v:set(packet.key.InSideHang_buy_time_custom, sel.h)
  end
  bo2.send_variant(packet.eCTS_ScnObj_ISH_BuyTime, v)
end
function on_btn_buy_click()
  local items = w_buy:search("items")
  for i = 1, items.control_size do
    local child = items:control_get(i - 1)
    if child.check then
      do
        local sel
        if tostring(child.name) == "custom_buy" then
          local count = child:search("tb_input")
          local hour = count.text.v_int
          if hour < 1 then
            break
          end
          sel = {
            type = 0,
            h = hour,
            m = hour * g_1hxm
          }
        else
          sel = child.svar
        end
        local money = ui_supermarket2.g_rmb
        if money < sel.m then
          ui_chat.show_ui_text_id(72167)
          break
        end
        ui_widget.ui_msg_box.show_common({
          text = sys.format(ui.get_text("ish|ish_buy_ask"), sel.m, sel.h),
          callback = function(msg)
            if msg.result == 1 then
              sendBuyHangTimer(sel)
            end
          end
        })
        break
      end
    end
  end
end
function on_ish_sld_make_tip(tip)
  local c = tip.owner
  local sld = c.parent.parent
  local r = sld.svar.range
  local v = r.range_min + (r.range_max - r.range_min) * sld.scroll
  ui_widget.tip_make_view(tip.view, sys.format("%.1f", v))
end
function on_ish_sld_make_tip_pct(tip)
  local c = tip.owner
  local sld = c.parent.parent
  local r = sld.svar.range
  local v = r.range_min + (r.range_max - r.range_min) * sld.scroll
  ui_widget.tip_make_view(tip.view, sys.format("%.1f%%", v * 100))
end
function on_timer(t)
  local iTimer = 0
  if bo2.player then
    iTimer = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_InSideHangTime)
  end
  local iDay = math.floor(iTimer / g_day_time)
  iTimer = iTimer % g_day_time
  local ihour = math.floor(iTimer / g_hour_time)
  iTimer = iTimer % g_hour_time
  local iminite = math.floor(iTimer / g_minite_time)
  iTimer = iTimer % g_minite_time
  local isecond = iTimer
  local txt
  if iDay > 0 then
    txt = sys.format(ui.get_text("ish|ish_hang_time_day"), iDay) .. sys.format(ui.get_text("ish|ish_hang_time_hour"), ihour) .. sys.format(ui.get_text("ish|ish_hang_time_minute"), iminite) .. sys.format(ui.get_text("ish|ish_hang_time_second"), isecond)
  elseif ihour > 0 then
    txt = sys.format(ui.get_text("ish|ish_hang_time_hour"), ihour) .. sys.format(ui.get_text("ish|ish_hang_time_minute"), iminite) .. sys.format(ui.get_text("ish|ish_hang_time_second"), isecond)
  elseif iminite > 0 then
    txt = sys.format(ui.get_text("ish|ish_hang_time_minute"), iminite) .. sys.format(ui.get_text("ish|ish_hang_time_second"), isecond)
  else
    txt = sys.format(ui.get_text("ish|ish_hang_time_second"), isecond)
  end
  w_hang_timer.text = ui.get_text("ish|ish_hang_time") .. txt
  if w_set.visible then
    local ride_skills = w_main:search("ride_skills")
    for i = 1, 6 do
      local c = sys.format(L("%d"), i)
      local card = ride_skills:search(c)
      ui.shortcut_set(card.index, bo2.eShortcut_None, 0)
    end
    local nRideFight = 0
    local ride_item = w_main:search("ride_item")
    local ride_info = ride_item.info
    if ride_info ~= nil then
      local cnt = ride_info:get_skill_cnt()
      for i = 0, cnt - 1 do
        local skill_info = ride_info:get_skill(i)
        if skill_info ~= nil then
          local ridepet_skill_excel = bo2.gv_ridepet_skill:find(skill_info.excel_id)
          if ridepet_skill_excel.nSkillGroup == bo2.eRidePetSlot_RideFight then
            nRideFight = nRideFight + 1
            local c = sys.format(L("%d"), nRideFight)
            local card = ride_skills:search(c)
            ui.shortcut_set(card.index, bo2.eShortcut_Skill, ridepet_skill_excel.nLinkSkillId)
          end
        end
      end
    end
  else
    local lb = w_buy:search("cur_money")
    local money = ui_supermarket2.g_rmb
    lb.mtf = ui_widget.merge_mtf({rmb = money}, ui.get_text("ish|ish_cur_money"))
    upDataBuyItem()
  end
end
function on_top_visible(ctrl, vis)
  ui_widget.on_esc_stk_visible(ctrl, vis)
  local timer = w_main:find_plugin("timer")
  if vis then
    load_config()
    if not g_init then
      for n, v in pairs(g_cfg_op) do
        local init = v.event.init
        if init ~= nil then
          init(n)
        end
      end
      g_init = true
    end
    for n, v in pairs(g_cfg_op) do
      v.event.load(n)
    end
    timer.suspended = false
    if bo2.player == nil or not bo2.player.bIshOpen then
      local ish_open = w_bottom1:search("ish_open")
      ish_open.visible = true
      local ish_close = w_bottom1:search("ish_close")
      ish_close.visible = false
    else
      local ish_open = w_bottom1:search("ish_open")
      ish_open.visible = false
      local ish_close = w_bottom1:search("ish_close")
      ish_close.visible = true
    end
  else
    timer.suspended = true
  end
end
function on_show_insidehang(btn)
  w_main.visible = not w_main.visible
end
function on_card_item_tip(tip)
  local card = tip.owner
  local excel = card.excel
  if excel == nil then
    local stk = sys.mtf_stack()
    local ctr_name = tostring(card.name)
    local tip_name = "ish|" .. ctr_name .. "_tip"
    text = ui.get_text(tip_name)
    stk:push(text)
    ui_tool.ctip_show(card, stk)
    return
  end
  ui_item.on_card_tip_show(tip)
end
function on_card_ride_tip(tip)
  local stk = sys.mtf_stack()
  local card = tip.owner
  if card.info == nil then
    local ctr_name = tostring(card.name)
    local tip_name = "ish|" .. ctr_name .. "_tip"
    text = ui.get_text(tip_name)
    stk:push(text)
    ui_tool.ctip_show(card, stk)
    return
  end
  ui_ridepet.ctip_make_ridepet(stk, card.info)
  ui_tool.ctip_show_custom(card, stk, 200)
end
function on_skill_tip(tip)
  local card = tip.owner
  local only_id = card.info.only_id
  if only_id.v_int == 0 then
    local stk = sys.mtf_stack()
    local ctr_name = tostring(card.name)
    local tip_name = "ish|" .. ctr_name .. "_tip"
    text = ui.get_text(tip_name)
    stk:push(text)
    ui_tool.ctip_show(card, stk)
    return
  end
  ui_shortcut.on_main_card_tip_show(tip)
end
function on_card_ride_mouse(card, msg, pos, wheel)
  if card.info == nil then
    return
  end
  if msg == ui.mouse_lbutton_click then
    if ui.is_key_down(ui.VK_CONTROL) then
      ui_chat.insert_ridepet(ui.ride_encode(card.info))
    end
    return
  end
  if msg == ui.mouse_rbutton_click then
    card.grid = -1
    return
  end
  if msg == ui.mouse_lbutton_drag then
    local function on_drop_hook(w, msg, pos, data)
      if msg == ui.mouse_drop_clean then
        card.grid = -1
      end
    end
    ui.clean_drop()
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_ride)
    data:set("only_id", card.info.onlyid)
    ui.set_cursor_icon(card.icon.uri)
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  end
  if msg == ui.mouse_mbutton_click then
    ui_ridepet.ridepet_msgbox(card.info)
  end
end
function on_card_ride_drop(card, msg, pos, data)
  if msg == ui.mouse_rbutton_down or msg == ui.mouse_rbutton_up then
    ui.clean_drop()
    return
  end
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  local drop_type = data:get("drop_type").v_string
  if drop_type == ui_widget.c_drop_type_ride then
    local only_id = data:get("only_id")
    local info = ui_ridepet.find_info_from_onlyid(only_id)
    if info ~= nil then
      card.grid = info:get_flag(bo2.eRidePetFlagInt32_Pos)
    end
  elseif drop_type == ui_widget.c_drop_type_shortcut then
    local idx_src = data:get("index").v_int
    if idx_src == idx_dst then
      return
    end
    local info_src = ui.shortcut_get(idx_src)
    if info_src ~= nil and info_src.kind == bo2.eShortcut_Ridepet then
      local only_id = info_src.only_id
      local ride_info = ui_ridepet.find_info_from_onlyid(only_id)
      if ride_info ~= nil then
        card.grid = ride_info:get_flag(bo2.eRidePetFlagInt32_Pos)
      end
    end
  end
  ui.clean_drop()
end
function on_skill_mouse(card, msg, pos, wheel)
  if card.info == nil then
    return
  end
  if msg == ui.mouse_lbutton_click and ui.is_key_down(ui.VK_CONTROL) then
    local info = ui.shortcut_get(card.index)
    if info == nil then
      return
    end
    local excel = info.excel
    if excel == nil then
      return
    end
    if info.kind == bo2.eShortcut_Skill then
      local skill_info = ui.skill_find(excel.id)
      if skill_info == nil then
        return
      end
      ui_chat.insert_skill(skill_info.excel_id, skill_info.level, skill_info.type)
      return
    end
  end
  if msg == ui.mouse_rbutton_click then
    ui.shortcut_set(card.index, bo2.eShortcut_None, 0)
    return
  end
  if msg == ui.mouse_lbutton_drag then
    ui_shortcut.shortcut_create_drop(card.index)
  end
end
function on_skill_drop(card, msg, pos, data)
  if msg == ui.mouse_rbutton_down or msg == ui.mouse_rbutton_up then
    ui.clean_drop()
    return
  end
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  local drop_type = data:get("drop_type").v_string
  local index = card.index
  if index < 1042 then
    if drop_type == ui_widget.c_drop_type_skill then
      local id = data:get("excel_id").v_int
      ui.shortcut_set(card.index, bo2.eShortcut_Skill, id)
    elseif drop_type == ui_widget.c_drop_type_lianzhao then
      local id = data:get("id").v_int
      ui.shortcut_set(card.index, bo2.eShortcut_LianZhao, id)
    elseif drop_type == ui_widget.c_drop_type_shortcut then
      local idx_src = data:get("index").v_int
      if idx_src == idx_dst then
        return
      end
      local info_src = ui.shortcut_get(idx_src)
      if info_src == nil then
        return
      end
      if info_src.kind == bo2.eShortcut_LianZhao or info_src.kind == bo2.eShortcut_Skill then
        local info_target = card.info
        local t_type = info_target.kind
        local t_onlyid = info_target.only_id
        ui.shortcut_set(card.index, info_src.kind, info_src.only_id)
        if idx_src >= bo2.eShortcut_IshSlotBegin and idx_src < 1042 then
          ui.shortcut_set(idx_src, t_type, t_onlyid)
        end
      end
    end
  else
    local id = 0
    if drop_type == ui_widget.c_drop_type_skill then
      id = data:get("excel_id").v_int
    elseif drop_type == ui_widget.c_drop_type_shortcut then
      local idx_src = data:get("index").v_int
      if idx_src == idx_dst then
        return
      end
      local info_src = ui.shortcut_get(idx_src)
      if info_src == nil then
        return
      end
      if info_src.kind == bo2.eShortcut_Skill then
        local info_target = card.info
        local t_onlyid = info_target.only_id
        id = info_src.only_id.v_int
      end
    end
    if id > 0 then
      local d = g_cfg_op[tostring(card.name)]
      if d ~= nil and d.range ~= nil then
        if d.range.name ~= nil then
          local excel = bo2.gv_skill_group:find(id)
          if excel.name ~= d.range.name then
            id = 0
          end
        end
        if id > 0 and d.range.id ~= nil then
          local bok = false
          for i, v in pairs(d.range.id) do
            if v == id then
              bok = true
              break
            end
          end
          if not bok then
            id = 0
          end
        end
      end
      if id > 0 then
        ui.shortcut_set(card.index, bo2.eShortcut_Skill, id)
      end
    end
  end
  ui.clean_drop()
end
function on_skills_init(ctr, data)
  local index = 1029
  if data == L("ride_skills") then
    index = 1035
  end
  for i = 1, 6 do
    local c = ctr:search(L(i))
    c.index = index + i
  end
end
function on_card_item_drop(card, msg, pos, data)
  if msg == ui.mouse_rbutton_down or msg == ui.mouse_rbutton_up then
    ui.clean_drop()
    return
  end
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  local drop_type = data:get("drop_type").v_string
  local info, onlyid
  if drop_type == ui_widget.c_drop_type_item then
    onlyid = data:get("only_id")
    info = ui.item_of_only_id(onlyid)
    if info == nil then
      return
    end
    if bo2.eItemBox_BagBeg > info.box or info.box > bo2.eItemBox_Quest then
      return
    end
  elseif drop_type == ui_widget.c_drop_type_shortcut then
    local idx_src = data:get("index").v_int
    if idx_src == idx_dst then
      return
    end
    local info_src = ui.shortcut_get(idx_src)
    if info_src == nil then
      return
    end
    if info_src.kind == bo2.eShortcut_Item then
      info = ui.item_of_only_id(info_src.only_id)
      if info == nil then
        return
      end
      onlyid = info_src.only_id
    end
  end
  if info ~= nil then
    local d = g_cfg_op[tostring(card.name)]
    if d == nil or d.range == nil then
      card.only_id = onlyid
    else
      local bok = true
      local excel = info.excel
      local r = d.range
      local type = r.type
      if type ~= nil then
        local type_ok = false
        for i, v in pairs(type) do
          if excel.type == v then
            type_ok = true
            break
          end
        end
        bok = type_ok
      end
      local use_type = r.use_type
      if bok and use_type ~= nil then
        local use_ok = false
        for i, v in pairs(use_type) do
          if excel.use_id == v then
            use_ok = true
            break
          end
        end
        bok = use_ok
      end
      if bok then
        card.only_id = onlyid
      end
    end
  end
  ui.clean_drop()
end
function search_widget(n)
  return w_main:search(n)
end
event_slider = {
  load = function(n)
    local sld = search_widget(n)
    if sld == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    local r = d.range
    local v = d.value.v_number
    if d.rate ~= nil then
      v = v / d.rate
    end
    sld.scroll = (v - r.range_min) / (r.range_max - r.range_min)
  end,
  save = function(n)
    local sld = search_widget(n)
    if sld == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    local r = d.range
    d.value = r.range_min + (r.range_max - r.range_min) * sld.scroll
    if d.rate ~= nil then
      d.value = d.value * d.rate
    end
  end,
  init = function(n)
    local sld = search_widget(n)
    if sld == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    local r = d.range
    if r == nil then
      r = {range_min = 0, range_max = 1}
    end
    sld.svar.range = r
    local lb_lo = sld:search("lb_lo")
    if lb_lo ~= nil then
      lb_lo.text = L(r.range_min)
    end
    local lb_hi = sld:search("lb_hi")
    if lb_hi ~= nil then
      lb_hi.text = L(r.range_max)
    end
  end
}
event_combo_box = {
  load = function(n)
    local cb = search_widget(n)
    if cb == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    ui_widget.ui_combo_box.select(cb, d.value.v_int)
  end,
  save = function(n)
    local cb = search_widget(n)
    if cb == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    local item = ui_widget.ui_combo_box.selected(cb)
    if item ~= nil then
      d.value = item.id
    end
  end,
  init = function(n)
    local cb = search_widget(n)
    if cb == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    local r = d.range
    for n, v in pairs(r) do
      ui_widget.ui_combo_box.append(cb, v)
    end
  end
}
event_check_box = {
  load = function(n)
    local btn = search_widget(n)
    if btn == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    if d.value.v_int == 1 then
      btn.check = true
    else
      btn.check = false
    end
  end,
  save = function(n)
    local btn = search_widget(n)
    if btn == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    if btn.check then
      d.value = 1
    else
      d.value = 0
    end
  end
}
event_item = {
  load = function(n)
    local card = search_widget(n)
    if card == nil then
      return
    end
    card.only_id = L("0")
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    card.only_id = d.value
  end,
  save = function(n)
    local card = search_widget(n)
    if card == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    d.value = card.only_id
  end
}
event_ride = {
  load = function(n)
    local card = search_widget(n)
    if card == nil then
      return
    end
    card.grid = -1
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    local only_id = d.value
    local info = ui_ridepet.find_info_from_onlyid(only_id)
    if info == nil then
      return
    end
    card.grid = info:get_flag(bo2.eRidePetFlagInt32_Pos)
  end,
  save = function(n)
    local card = search_widget(n)
    if card == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    d.value = L("0")
    local info = card.info
    if info == nil then
      return
    end
    d.value = info.onlyid
  end
}
evemt_skill = {
  load = function(n)
    local card = search_widget(n)
    if card == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    if d.value.v_int > 0 then
      ui.shortcut_set(card.index, bo2.eShortcut_Skill, d.value)
    else
      ui.shortcut_set(card.index, bo2.eShortcut_None, 0)
    end
  end,
  save = function(n)
    local card = search_widget(n)
    if card == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    local info = card.info
    if info == nil then
      return
    end
    d.value = info.only_id
  end,
  init = function(n)
    local card = search_widget(n)
    if card == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    card.index = d.index
  end
}
event_skill_list = {
  load = function(n)
    function SetCard(clist, n, v)
      local card = clist:search(n)
      if card == nil then
        return
      end
      if v ~= nil then
        local i = v.v_int
        if i > 0 then
          ui.shortcut_set(card.index, bo2.eShortcut_Skill, i)
          return
        elseif i < 0 then
          ui.shortcut_set(card.index, bo2.eShortcut_LianZhao, -i)
          return
        end
      end
      ui.shortcut_set(card.index, bo2.eShortcut_None, 0)
    end
    local skilllist = search_widget(n)
    if skilllist == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    local sp = L("*")
    local str = d.value
    local s = {}
    s["1"], s["2"], s["3"], s["4"], s["5"], s["6"] = str:split(sp, 6)
    for i, s in pairs(s) do
      SetCard(skilllist, i, s)
    end
  end,
  save = function(n)
    local skilllist = search_widget(n)
    if skilllist == nil then
      return
    end
    local d = g_cfg_op[n]
    if d == nil then
      return
    end
    d.value = L("")
    for i = 1, 6 do
      local c = sys.format(L("%d"), i)
      local card = skilllist:search(c)
      if card ~= nil then
        local info = card.info
        if info.kind == bo2.eShortcut_LianZhao then
          if i ~= 1 then
            d.value = sys.format(L("%s*-%s"), d.value, info.only_id)
          else
            d.value = sys.format(L("-%s"), info.only_id)
          end
        elseif i ~= 1 then
          d.value = sys.format(L("%s*%s"), d.value, info.only_id)
        else
          d.value = sys.format(L("%s"), info.only_id)
        end
      end
    end
  end
}
g_cfg_op = {
  fight_rang = {
    value = L("0"),
    range = {range_min = 5, range_max = 50},
    event = event_slider
  },
  fight_hp = {
    value = L("50"),
    range = {range_min = 0, range_max = 1},
    rate = 100,
    event = event_slider
  },
  idle_hp = {
    value = L("50"),
    range = {range_min = 0, range_max = 1},
    rate = 100,
    event = event_slider
  },
  food = {
    value = L("50"),
    range = {range_min = 0, range_max = 1},
    rate = 100,
    event = event_slider
  },
  fight_hp_item = {
    value = L("0"),
    range = {
      type = {2}
    },
    event = event_item
  },
  idle_hp_item = {
    value = L("0"),
    range = {
      type = {2, 3}
    },
    event = event_item
  },
  food_item = {
    value = L("0"),
    range = {
      type = {3}
    },
    event = event_item
  },
  auto_pick = {
    value = L("0"),
    event = event_check_box
  },
  auto_repair = {
    value = L("0"),
    event = event_check_box
  },
  auto_skill = {
    value = L("0"),
    event = {
      load = function(n)
        local btn = search_widget(n)
        if btn == nil then
          return
        end
        local d = g_cfg_op[n]
        if d == nil then
          return
        end
        local skill_list = w_main:search("player_skills")
        if d.value.v_int == 1 then
          btn.check = true
          skill_list.enable = false
        else
          btn.check = false
          skill_list.enable = true
        end
      end,
      save = event_check_box.save
    }
  },
  transfer_skill = {
    value = L("0"),
    range = {
      id = {110027}
    },
    index = 1042,
    event = evemt_skill
  },
  recover_skill = {
    value = L("0"),
    range = {
      name = ui.get_text("ish|recover_skill_lable")
    },
    index = 1043,
    event = evemt_skill
  },
  burst_skill = {
    value = L("0"),
    range = {
      name = ui.get_text("ish|burst_skill_lable")
    },
    index = 1044,
    event = evemt_skill
  },
  auto_ride = {
    value = L("0"),
    event = event_check_box
  },
  ride_item = {
    value = L("0"),
    event = event_ride
  },
  player_skills = {
    value = L(""),
    event = event_skill_list
  }
}
