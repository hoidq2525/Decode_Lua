local ui_tab = ui_widget.ui_tab
local pre_day = 0
local lclick_repute_tip1 = ui.get_text("personal|lclick_repute_tip1")
local lclick_repute_tip2 = ui.get_text("personal|lclick_repute_tip2")
local text_click_open_shop = ui.get_text("personal|click_open_shop")
function on_init(ctrl)
  ui_tab.clear_tab_data(w_main)
  insert_tab("camp")
  ui_tab.show_page(w_main, "camp", true)
  ui_tab.set_button_sound(w_main, 578)
end
function on_tab_click(btn)
  update_recommend()
end
function on_tab_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    w_recommend_repute.visible = false
    w_repute_panel.visible = true
  end
end
function insert_tab(name)
  local btn_uri = "$frame/personal/repute.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/personal/repute.xml"
  local page_sty = name
  ui_tab.insert_suit(w_main, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_main, name)
  btn.text = ui.get_text("personal|title_" .. name)
  local view = ui_tab.get_page(w_main, name)
  view.name = name
  if view == nil then
    return
  end
  local root = view:search("rp_list")
  if root == nil then
    return
  end
  local list_name = L("rp_item")
  local type = 1
  if name == "hero" then
    type = 2
  end
  for i = 0, bo2.gv_repute_list.size - 1 do
    local repute = bo2.gv_repute_list:get(i)
    if repute.type == type and repute.disable == 0 then
      local list_item = root:item_append()
      list_item:load_style(page_uri, list_name)
      set_item(list_item, repute, view)
    end
  end
end
function set_item(list_item, repute, view)
  list_item.svar.repute_id = repute.id
  local tip = bo2.gv_text:find(repute.tip)
  if tip ~= nil then
    list_item.svar.tip = tip.text
  end
  local excel = bo2.gv_repute_level:find(1)
  if excel == nil then
    return
  end
  list_item:search("rp_name").text = repute.name .. "(0/" .. excel.max .. ")"
  ui_tool.set_progress(list_item, 0)
end
function on_item_select(ctrl, vis)
end
function on_item_mouse(panel, msg, pos, wheel)
  local item = panel:search("rp_tracing")
  if item == nil then
    return
  end
  if msg == ui.mouse_enter or msg == ui.mouse_inner then
    item.visible = true
  elseif msg == ui.mouse_leave or msg == ui.mouse_outer then
    item.visible = false
  end
end
function ss_open(m)
  local v = sys.variant()
  v:set(packet.key.cmn_id, m.v_int)
  v:set(packet.key.cmn_type, 100)
  bo2.send_variant(packet.eCTS_UI_OpenReputeShop, v)
end
function on_tracing_click(btn)
  local item = btn.parent.parent
  local id = item.svar.repute_id
  local info = ui.repute_find(id)
  if info == nil then
    return
  end
  local excel = bo2.gv_repute_list:find(info.excel_id)
  if excel == nil then
    return
  end
  ui_handson_teach.test_complate_click_reputation_shop()
  local v = sys.variant()
  v:set(packet.key.cmn_id, info.excel_id)
  v:set(packet.key.cmn_type, 100)
  bo2.send_variant(packet.eCTS_UI_OpenReputeShop, v)
end
function on_repute_tracing(tip)
  local item = tip.owner.parent.parent
  local text = text_click_open_shop
  ui_widget.tip_make_view(tip.view, text)
end
function on_recommend_tip(tip)
  if w_recommend_repute.visible then
    w_recommend_tip.text = lclick_repute_tip1
  else
    w_recommend_tip.text = lclick_repute_tip2
  end
  ui_widget.tip_make_view(tip.view, w_recommend_tip.text)
end
function on_recommend_repute(btn)
  w_recommend_repute.visible = not w_recommend_repute.visible
  w_repute_panel.visible = not w_repute_panel.visible
  local view = ui_tab.get_show_page(w_main)
  local root = view:search("rp_list")
  root.visible = not w_recommend_repute.visible
  local recommend = w_recommend_repute:search("rp_recommend")
  recommend.mtf = ui.get_text("personal|recommend_" .. view.name)
  bo2.PlaySound2D(578)
end
function update_recommend()
  local view = ui_tab.get_show_page(w_main)
  if tostring(view.name) == "renown" then
    ui_personal.ui_renown.send_renown_request()
    return
  else
  end
  local recommend = w_recommend_repute:search("rp_recommend")
  recommend.mtf = ui.get_text("personal|recommend_" .. view.name)
  local root = view:search("rp_list")
  root.visible = not w_recommend_repute.visible
  local cur_today = 0
  local max_per_day = 0
  for i = 0, bo2.gv_repute_list.size - 1 do
    local excel = bo2.gv_repute_list:get(i)
    if excel ~= nil then
      local info = ui.repute_find(excel.id)
      if info ~= nil then
        local today = info.today
        cur_today = cur_today + today
      end
    end
  end
  local v = sys.variant()
  v:set("today_num", cur_today)
  v:set("max_today", bo2.gv_define:find(1027).value.v_int)
  local text = sys.mtf_merge(v, ui.get_text("personal|max_today"))
  w_today_max.text = text
end
function get_item(id)
  local repute = bo2.gv_repute_list:find(id)
  if repute == nil then
    return nil
  end
  local vname = "camp"
  if repute.type == 2 then
    vname = "hero"
  end
  local view = ui_tab.get_page(w_main, vname)
  local root = view:search("rp_list")
  for i = 0, root.item_count - 1 do
    local item = root:item_get(i)
    local repute_id = item.svar.repute_id
    if repute_id == id then
      return item
    end
  end
  return nil
end
function set_level(list_item, level)
  local n = bo2.gv_repute_level:find(level)
  if n == nil then
    return
  end
  list_item.svar.level = level
  list_item.svar.max = n.max
  local pre = bo2.gv_repute_level:find(level - 1)
  if pre ~= nil then
    list_item.svar.min = pre.max
  else
    list_item.svar.min = 0
  end
end
function on_repute(cmd, data)
  local key = data:get(packet.key.item_key).v_int
  local cur = data:get(packet.key.itemdata_val).v_int
  local time = data:get(packet.key.item_key3).v_int
  local level = data:get(packet.key.itemdata_idx).v_int
  local canuse = data:get(packet.key.item_key1).v_int
  local list_item = get_item(key)
  if list_item == nil then
    return
  end
  list_item.svar.time = time
  local oldlevel = list_item.svar.level
  if oldlevel ~= level then
    set_level(list_item, level)
  end
  local min = list_item.svar.min
  local max = list_item.svar.max
  if max == min then
    ui_tool.set_progress(list_item, 0)
  else
    local f = (cur - min) / (max - min)
    ui_tool.set_progress(list_item, f)
  end
  local repute = bo2.gv_repute_list:find(key)
  if repute == nil then
    return
  end
  local progress_text
  local excel = bo2.gv_repute_level:find(level)
  if excel == nil then
    return
  end
  if level == 1 then
    progress_text = sys.format("%d/%d", cur, excel.max)
    list_item:search("frm"):search("pic").color = ui.make_color("659bff")
  else
    local excel_p = bo2.gv_repute_level:find(level - 1)
    local max = excel.max - excel_p.max
    local cur_p = cur - excel_p.max
    progress_text = sys.format("%d/%d", cur_p, max)
    if level % 3 == 1 then
      list_item:search("frm"):search("pic").color = ui.make_color("659bff")
    elseif level % 3 == 2 then
      list_item:search("frm"):search("pic").color = ui.make_color("ff9e3f")
    elseif level % 3 == 0 then
      list_item:search("frm"):search("pic").color = ui.make_color("fffccc")
    end
  end
  list_item:search("rp_name").text = repute.name .. "(" .. progress_text .. ")"
  update_recommend(key)
end
function on_repute_tip(tip)
  local p = tip.owner.parent.parent.parent
  local time = p.svar.time
  local repute_id = p.svar.repute_id
  local info = ui.repute_find(repute_id)
  if info == nil then
    return
  end
  local canuse = info.canuse
  local today = info.today
  local current = info.cur
  local excel = bo2.gv_repute_list:find(info.excel_id)
  if excel == nil then
    return
  end
  local level = 0
  if info.level == 0 then
    level = 1
  else
    level = info.level
  end
  local level_excel = bo2.gv_repute_level:find(level)
  if level_excel == nil then
    return
  end
  local tip_text = p.svar.tip
  local player = bo2.player
  local player_level = 1
  if player ~= nil then
    player_level = bo2.player:get_atb(bo2.eAtb_Level)
  end
  local max_per_day = bo2.gv_define:find(1027).value.v_int
  local v = sys.variant()
  v:set("can_use", canuse)
  v:set("repute_level", level_excel.name)
  local e_new = bo2.gv_repute_level:find(level_excel.id + 1)
  if e_new == nil then
    v:set("repute_level_new", "--")
    v:set("add_num", "--")
  else
    v:set("repute_level_new", e_new.name)
    v:set("add_num", level_excel.max + 1 - current)
  end
  v:set("day_num", today)
  v:set("day_limit", level_excel.max_level)
  v:set("tip_text", tip_text)
  local text = sys.mtf_merge(v, ui.get_text("personal|repute_total_tip"))
  ui_widget.tip_make_view(tip.view, text)
end
function on_observable(w, vis)
  ui_handson_teach.test_complate_reputation_shop(vis)
end
function on_camp_observable(w, vis)
  ui_handson_teach.test_complate_camp_reputation_shop(vis)
end
local sig_name = "ui_personal.ui_repute:on_signal"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_Repute, on_repute, sig_name)
