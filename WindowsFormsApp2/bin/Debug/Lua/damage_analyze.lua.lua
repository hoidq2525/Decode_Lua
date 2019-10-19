local g_self_record_data = {}
local g_record_data = {}
local c_damage = 0
local c_damage_suffered = 1
local c_health = 2
local g_name = {}
g_name[0] = L("damage")
g_name[1] = L("damage_suffered")
g_name[2] = L("health")
local g_page_name = {}
g_page_name[bo2.eTagID_DamageFB] = c_damage
g_page_name[bo2.eTagID_DamHitFB] = c_damage
g_page_name[bo2.eTagID_PetDamageFB] = c_damage
g_page_name[bo2.eTagID_PetDamHitFB] = c_damage
g_page_name[bo2.eTagID_DamHitFB] = c_damage
g_page_name[bo2.eTagID_DamTransferFB] = c_damage
g_page_name[bo2.eTagID_DamageFBHighCrt] = c_damage
g_page_name[bo2.eTagID_DamHitFBHighCrt] = c_damage
g_page_name[bo2.eTagID_Damage] = c_damage_suffered
g_page_name[bo2.eTagID_DamHit] = c_damage_suffered
g_page_name[bo2.eTagID_SummonDamage] = c_damage_suffered
g_page_name[bo2.eTagID_DamTransfer] = c_damage_suffered
g_page_name[bo2.eTagID_DamDefend] = c_damage_suffered
g_page_name[bo2.eTagID_CureHP] = c_health
local g_dps_counter_second = 20
local g_dps_counter_time = 25 * g_dps_counter_second
local g_dps_counter_ms = g_dps_counter_second * 100
local g_dps_check_time = 375
local g_debug_test = false
function clear_record()
  g_self_record_data = {}
  g_record_data = {}
end
function clear_all_page()
  local clear_page = function(name)
    if sys.check(ui_damage.g_view) ~= true then
      return
    end
    local c_tree = ui_widget.ui_tab.get_page(ui_damage.tab_bar, name)
    if sys.check(c_tree) ~= true then
      return
    end
    local c_tree_view = c_tree:search(L("damage_tree_view"))
    c_tree_view.root:item_clear()
  end
  clear_page("damage")
  clear_page("damage_suffered")
  clear_page("health")
end
function insert_tab(name, dis)
  local btn_uri = "$frame/damage_analyze/damage_analyze.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/damage_analyze/damage_analyze.xml"
  local page_sty = name
  ui_widget.ui_tab.insert_suit(ui_damage.tab_bar, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_widget.ui_tab.get_button(tab_bar, name)
  local page_name = name
  name = ui.get_text(sys.format("damage|%s", name))
  btn.text = name
  if g_debug_test == true then
    local page = ui_widget.ui_tab.get_page(tab_bar, page_name)
    local c_tree = page:search(L("damage_tree_view"))
    local item = c_tree.root:item_append()
    item.obtain_title:load_style("$frame/damage_analyze/damage_analyze.xml", "item")
  end
  if dis ~= nil then
    btn.enable = false
  end
end
function on_init()
  insert_tab("damage")
  insert_tab("damage_suffered")
  insert_tab("health")
  ui_widget.ui_tab.show_page(tab_bar, "damage", true)
end
function insert_item(v_data)
  if v_data == nil then
    return
  end
  local name
  if v_data.data:has(packet.key.cha_name) then
    name = v_data.data:get(packet.key.cha_name).v_string
  else
    name = bo2.player.name
  end
  if g_page_name[v_data.tag_id] == nil then
    return
  end
  local c_id = g_page_name[v_data.tag_id]
  local page_name = g_name[c_id]
  local c_page = ui_widget.ui_tab.get_page(ui_damage.tab_bar, page_name)
  if sys.check(c_page) ~= true then
    return
  end
  local c_tree = c_page:search(L("damage_tree_view"))
  local item
  local count = c_tree.root.item_count
  for i = 0, count - 1 do
    local c_item = c_tree.root:item_get(i)
    if c_item.svar.name == name then
      item = c_item
      break
    end
  end
  if count >= 20 then
    return
  end
  if item == nil then
    item = c_tree.root:item_append()
    item.obtain_title:load_style("$frame/damage_analyze/damage_analyze.xml", "item")
    item.svar.name = name
    item.svar.tag_val = v_data.tag_val
    local t_name = item:search(L("name"))
    t_name.text = name
    item.svar.dps_counter = v_data.tag_val
    item.svar.dps_max = 0
    if g_record_data[c_id] == nil then
      g_record_data[c_id] = {}
      g_record_data[c_id].value = 0
    end
    local dps_text = item:search(L("dps_val"))
    dps_text.text = sys.format(L("%.2f(%.2f)"), 0, 0)
  else
    item.svar.tag_val = item.svar.tag_val + v_data.tag_val
    item.svar.dps_counter = item.svar.dps_counter + v_data.tag_val
  end
  g_record_data[c_id].value = g_record_data[c_id].value + v_data.tag_val
  item.svar.last_time = sys.tick()
  item.svar.tick = sys.tick()
  local update_all = function(m_item, total)
    local t_val = m_item:search(L("tag_val"))
    local persent = 0
    if 0 < m_item.svar.tag_val then
      persent = m_item.svar.tag_val / total
      local pic = m_item:search(L("persent"))
      pic.visible = true
      pic.dx = math.floor(255 * persent)
      t_val.text = sys.format(L("%d(%.1f%%)"), m_item.svar.tag_val, persent * 100)
    else
      t_val.text = m_item.svar.tag_val
    end
  end
  local c = c_tree.root.item_count
  for i = 0, c - 1 do
    local c_item = c_tree.root:item_get(i)
    update_all(c_item, g_record_data[c_id].value)
  end
  local function sort_list()
    local sort_fn = function(left, right)
      if left.svar.tag_val > right.svar.tag_val then
        return -1
      else
        return 1
      end
    end
    c_tree.root:item_sort(sort_fn)
  end
  sort_list()
  if item.svar.dps_update ~= nil then
    return
  end
  local function on_update_dps()
    if sys.check(item) ~= true then
      return
    end
    local tick = item.svar.tick
    local tick_diff = sys.dtick(sys.tick(), tick)
    if tick_diff > g_dps_counter_ms then
      return
    end
    local c_dps_value = item.svar.dps_counter / g_dps_counter_second
    if c_dps_value > item.svar.dps_max then
      item.svar.dps_max = c_dps_value
    end
    local dps_text = item:search(L("dps_val"))
    dps_text.text = sys.format(L("%.2f(%.2f)"), c_dps_value, item.svar.dps_max)
    item.svar.dps_update = bo2.AddTimeEvent(g_dps_counter_time, on_update_dps)
    item.svar.dps_counter = 0
  end
  item.svar.dps_update = bo2.AddTimeEvent(g_dps_counter_time, on_update_dps)
  local function on_quit_dps()
    if sys.check(item) ~= true then
      return
    end
    local tick = item.svar.tick
    local tick_diff = sys.dtick(sys.tick(), tick)
    if tick_diff > g_dps_counter_ms then
      bo2.RemoveTimeEvent(item.svar.dps_update)
      item.svar.dps_counter = 0
      item.svar.quit_counter = nil
      item.svar.dps_update = nil
    else
      item.svar.quit_counter = bo2.AddTimeEvent(g_dps_check_time, on_quit_dps)
    end
  end
  if sys.check(item.svar.quit_counter) then
    bo2.RemoveTimeEvent(item.svar.quit_counter)
  end
  item.svar.tick = sys.tick()
  item.svar.quit_counter = bo2.AddTimeEvent(g_dps_check_time, on_quit_dps)
end
function open()
  w_main.visible = true
end
function test()
  local t = {}
  t.tag_id = 4
  t.tag_val = 100
  t.data = sys.variant()
  t.data:set(packet.key.cha_name, sys.tick())
  insert_item(t)
end
function on_signal_self_log(cmd, data)
  if w_main.visible == false then
    return
  end
  local t = {}
  t.tag_id = data:get(packet.key.cmn_id).v_int
  t.tag_val = data:get(packet.key.cmn_val).v_int
  t.data = data
  if data == nil then
    return
  end
  insert_item(t)
end
local sig_name = L("ui_damage:on_signal_self_log")
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_LogTag, on_signal_self_log, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_GroupMember_LogTag, on_signal_self_log, L("ui_damage:on_signal_self_log_server"))
function c_all()
  clear_record()
  clear_all_page()
end
function on_self_enter()
  if g_c_player ~= bo2.player then
    g_c_player = bo2.player
    c_all()
  end
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_cloned_battle.on_self_enter_finish")
