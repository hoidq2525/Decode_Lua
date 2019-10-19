local select
function get_visible()
  local w = ui.find_control("$frame:guild_yizhan")
  return w.visible
end
function on_init(ctrl)
  w_deliver_list:item_clear()
  select = nil
  ui.insert_on_guild_build_refresh("ui_guild_mod.ui_guild_yizhan.updata_deliver_list")
end
function updata_deliver_list()
  local ilevel = 100
  local ui_guild_build
  result = ui.guild_get_build(2)
  if result then
    ilevel = result.level
  end
  select = nil
  w_deliver_list:item_clear()
  for i = 0, bo2.gv_guild_yizhan.size - 1 do
    local yizhan_excel = bo2.gv_guild_yizhan:get(i)
    if ilevel >= yizhan_excel.level then
      local deliver_excel = bo2.gv_deliver_list:find(yizhan_excel.deliver_id)
      if deliver_excel then
        local item = w_deliver_list:item_append()
        item:load_style(L("$frame/guild/guild_yizhan.xml"), L("deliver_item"))
        item.svar.deliver_id = yizhan_excel.deliver_id
        item.svar.only_id = yizhan_excel.only_id
        local vis = item.selected or item.inner_hover
        local fig = item:search("fig_highlight")
        fig.visible = vis
        local name = item:search("deliver_name")
        name.text = yizhan_excel.deliver_name
        local money_item = item:search("rb_text")
        if deliver_excel.type == bo2.eCurrency_CirculatedMoney then
          money_item.bounded = false
        elseif deliver_excel.type == bo2.eCurrency_BoundedMoney then
          money_item.bounded = true
        end
        money_item.money = deliver_excel.money
        item.svar.money = deliver_excel.money
        item.svar.tips = deliver_excel.des
      end
    end
  end
  local mysort = function(a, b)
    if a.svar.money < b.svar.money then
      return -1
    elseif a.svar.money == b.svar.money then
      return 0
    else
      return 1
    end
  end
  w_deliver_list:item_sort(mysort)
end
function on_guild_menu_event(item)
  if item.callback then
    item:callback()
  end
end
function on_visible(w, vis)
  if bo2.is_in_guild() == sys.wstring(0) then
    ui_chat.show_ui_text_id(70251)
    ui_guild_mod.ui_guild_yizhan.w_main.visible = false
  end
  local cur_money = ui.guild_get_money()
  if cur_money < 0 then
    ui_chat.show_ui_text_id(70838)
    ui_guild_mod.ui_guild_yizhan.w_main.visible = false
  end
  if vis == true then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    updata_deliver_list()
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_Guild_BuildReq, v)
  else
    ui_widget.esc_stk_pop(w)
    if w_deliver_list.item_sel ~= nil then
      w_deliver_list.item_sel:search("fig_highlight").visible = false
      w_deliver_list.item_sel.selected = false
    end
    select = nil
  end
end
function on_deliver_item_sel(item, sel)
  if not sel then
    return
  end
  if select ~= nil then
    select:search("fig_highlight").visible = false
  end
  select = item
  select:search("fig_highlight").visible = true
end
function on_deliver_item_mouse()
end
function on_check()
  if select == nil then
    return
  end
  ui_widget.ui_msg_box.show_common({
    style_uri = "$frame/guild/guild_yizhan.xml",
    style_name = "ui_guild_deliver",
    init = function(data)
      data.window:search("box").mtf = select.svar.tips
    end
  })
end
function on_chgscn()
  if select == nil then
    return
  end
  ui_guild_mod.ui_guild_yizhan2.visible = false
  local deliver_id = select.svar.deliver_id
  local only_id = select.svar.only_id
  local scn_id = bo2.gv_deliver_list:find(deliver_id).scn_id
  local gzs_id = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_ParallelGZS)
  local alloc_line = bo2.gv_scn_alloc:find(scn_id)
  local v = sys.variant()
  v:set(packet.key.deliver_id, deliver_id)
  v:set(packet.key.only_id, only_id)
  if alloc_line.gzsid.size == 0 and alloc_line.outer_gzsid.size == 0 then
    v:set(packet.key.gzs_id, gzs_id)
  end
  v:set(packet.key.is_value_true, 1)
  bo2.send_variant(packet.eCTS_UI_Deliver, v)
end
