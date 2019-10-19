local select
function get_visible()
  local w = ui.find_control("$frame:guild_jiaotou")
  return w.visible
end
function on_init(ctrl)
  w_guard_list:item_clear()
  select = nil
  ui.insert_on_guild_guard_refresh("ui_guild_mod.ui_guild_jiaotou.updata_guard_list", "ui_guild_jiaotou")
end
function updata_guard_list()
  local arg = sys.variant()
  arg:set("guild_money", ui.guild_get_money())
  g_guild_money.money = ui.guild_get_money()
  arg:clear()
  arg:set("guild_develop", sys.format("%d", ui.guild_get_develop()))
  g_guild_develop.text = sys.mtf_merge(arg, ui.get_text("guild|guild_develop"))
  local level = 100
  local ui_guild_build
  jiaochang = ui.guild_get_build(4)
  if jiaochang then
    level = jiaochang.level
  end
  for i = 0, bo2.gv_guild_shouwei.size - 1 do
    local guard_excel = bo2.gv_guild_shouwei:get(i)
    local cha_list_excel = bo2.gv_cha_list:find(guard_excel.npc_id)
    local guilditem = getitem(guard_excel.npc_id)
    if guilditem ~= nil then
      local count = guilditem:search("count")
      count.text = 0
      local ui_guild_guard
      guard = ui.guild_find_guard(guilditem.svar.excel_id)
      if guard ~= nil then
        count.text = guard.count
      end
    elseif level >= guard_excel.build_level and cha_list_excel then
      local item = w_guard_list:item_append()
      item:load_style(L("$frame/guild/guild_jiaotou.xml"), L("guard_item"))
      item.svar.excel_id = guard_excel.npc_id
      local vis = item.selected or item.inner_hover
      local fig = item:search("fig_highlight")
      fig.visible = vis
      local name = item:search("guard_name")
      name.text = guard_excel.npc_name
      local guard_level = item:search("level")
      guard_level.text = cha_list_excel.level
      local stk = sys.mtf_stack()
      stk:raw_format("<a+:r><m:%d><a->", guard_excel.money)
      local rb = item:search("rb_text")
      rb.mtf = stk.text
      local develop = item:search("develop")
      develop.text = guard_excel.develop
      local count = item:search("count")
      count.text = 0
      local ui_guild_guard
      guard = ui.guild_find_guard(item.svar.excel_id)
      if guard ~= nil then
        count.text = guard.count
      end
    end
  end
end
function getitem(excel_id)
  for n = 0, w_guard_list.item_count - 1 do
    local item = w_guard_list:item_get(n)
    if item.svar.excel_id == excel_id then
      return item
    end
  end
  return nil
end
function on_visible(w, vis)
  if bo2.is_in_guild() == sys.wstring(0) then
    ui_chat.show_ui_text_id(70251)
    ui_guild_mod.ui_guild_jiaotou.w_main.visible = false
  end
  if vis == true then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    updata_guard_list()
    local guard_v = sys.variant()
    bo2.send_variant(packet.eCTS_Guild_GetGuardData, guard_v)
  else
    ui_widget.esc_stk_pop(w)
    if w_guard_list.item_sel ~= nil then
      w_guard_list.item_sel:search("fig_highlight").visible = false
      w_guard_list.item_sel.selected = false
    end
    if select then
      select:search("fig_highlight").visible = false
    end
    select = nil
  end
end
function on_item_sel(ctrl)
  if select ~= nil then
    select:search("fig_highlight").visible = false
  end
  select = ctrl
  select:search("fig_highlight").visible = true
end
function on_item_mouse()
end
function on_addguard()
  if select == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.guild_guard_excel_id, select.svar.excel_id)
  bo2.send_variant(packet.eCTS_Guild_AddGuard, v)
end
function on_delguard()
  if select == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.guild_guard_excel_id, select.svar.excel_id)
  bo2.send_variant(packet.eCTS_Guild_DelGuard, v)
end
function on_chuzhanguard()
  if select == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.guild_guard_excel_id, select.svar.excel_id)
  bo2.send_variant(packet.eCTS_Guild_ChuZhan, v)
end
function depot_updatamoney(cmd, data)
  local arg = sys.variant()
  g_guild_money.money = ui.guild_get_money()
  arg:clear()
  arg:set("guild_develop", sys.format("%d", ui.guild_get_develop()))
  g_guild_develop.text = sys.mtf_merge(arg, ui.get_text("guild|guild_develop"))
end
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_guild_mod.ui_guild_jiaotou:on_signal"
reg(packet.eSTC_Guild_SelfData, depot_updatamoney, sig)
