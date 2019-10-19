local ui_cell = ui_npcfunc.ui_cell
local ui_tree2 = ui_widget.ui_tree2
local level = 0
function add_tree_item(item, item_text)
  local app_item
  for i = 0, item.item_count - 1 do
    local chile_item = item:item_get(i)
    if chile_item.title:search("lb_text").text == item_text then
      app_item = chile_item
      break
    end
  end
  local inst
  if app_item == nil then
    app_item, inst = ui_tree2.insert(item)
    if not inst then
      app_item.svar.item_group = item_text
      app_item.expanded = false
      app_item.title:search("lb_text").text = item_text
      app_item.title:search("lb_text_exp").text = item_text
    end
  end
  return app_item
end
function on_init(ctrl)
  update_view()
  ui.insert_on_guild_build_refresh("ui_npcfunc.ui_makeitem.update_view", "ui_makeitem")
end
function update_view()
  local ui_guild_build
  result = ui.guild_get_build(5)
  if result then
    level = result.level
  end
  if w_item_view.item_sel ~= nil then
    w_item_view:clear_selection()
  end
  w_item_view.root:item_clear()
  ui_tree2.on_view_move(w_item_view)
  for k = 0, bo2.gv_make_item.size - 1 do
    local make_item = bo2.gv_make_item:get(k)
    local excel = ui.item_get_excel(make_item.id)
    if excel and make_item.enable == 1 and make_item.buildlevel <= level and make_item.type ~= nil then
      local node = add_tree_item(w_item_view.root, make_item.type)
      local app_item, inst = ui_tree2.insert(node)
      if not inst then
        app_item.svar.make_item = make_item
        app_item.expanded = false
        app_item.title:search("lb_text").text = excel.name
      end
      if make_item.buildlevel == level then
        app_item.title:search("highlight").visible = true
      else
        app_item.title:search("highlight").visible = false
      end
    end
  end
  ui_cell.set_n(w_detail, "product", 0)
  for i = 0, 9 do
    local c = w_detail:search("mat_reg_" .. i)
    ui_cell.set(c, id, 0)
    if i > 1 and i % 2 == 0 then
      c.parent.parent.visible = false
    end
  end
end
function on_visible(w, vis)
  local ui_guild_build
  result = ui.guild_get_build(5)
  if bo2.is_in_guild() == sys.wstring(0) or result == nil or result.level == 0 then
    ui_chat.show_ui_text_id(70154)
    ui_npcfunc.ui_makeitem.w_main.visible = false
  end
  if vis then
    update_view()
  end
  ui_npcfunc.on_visible(w, vis)
end
function on_btn_make_click(btn)
  local item = w_item_view.item_sel
  if item == nil then
    return
  end
  count = ui_widget.ui_count_box.get_value(w_count_box)
  if count == 0 then
    return
  end
  local make_item = item.svar.make_item
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_GuildMakeItem)
  v:set(packet.key.item_count, count)
  v:set(packet.key.cmn_id, make_item.keyid)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  post_product_update()
end
function product_count()
  local item = w_item_view.item_sel
  if item == nil or item.depth ~= 2 then
    return 0
  end
  local make_item = item.svar.make_item
  local count = 1000
  for i = 0, 9 do
    local id = make_item.reg_id[i]
    if id ~= 0 then
      local c = ui.item_get_count(id, true) / make_item.reg_num[i]
      if ui.item_get_count(id, true) < make_item.reg_num[i] then
        count = 0
        break
      end
      if c < count then
        count = math.floor(c)
      end
    end
  end
  local player = ui_personal.ui_equip.safe_get_player()
  local money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney) + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
  t = math.floor(money / make_item.money)
  if count > t then
    count = t
  end
  return count
end
function do_product_update()
  local count = product_count()
  if count == 0 then
    w_btn_make.enable = false
    w_btn_max.enable = false
  else
    w_btn_make.enable = true
    w_btn_max.enable = true
  end
  ui_widget.ui_count_box.set_range(w_count_box, 1, count)
end
function post_product_update()
  w_item_view:insert_post_invoke(do_product_update, "ui_npcfunc.ui_makeitem.do_product_update")
end
function detail_clear()
  ui_cell.batch_clear(w_detail, {
    "product",
    "mat_reg_0",
    "mat_reg_1",
    "mat_reg_2",
    "mat_reg_3",
    "mat_reg_4",
    "mat_reg_5",
    "mat_reg_6",
    "mat_reg_7",
    "mat_reg_8",
    "mat_reg_9"
  })
  w_detail:search("lb_money").money = 0
  w_btn_make.enable = false
end
function on_item_sel(item, sel)
  if item.depth ~= 2 then
    return
  end
  ui_widget.ui_count_box.set_range(w_count_box, 1, 1)
  post_product_update()
  if not sel then
    detail_clear()
    return
  end
  local make_item = item.svar.make_item
  ui_cell.set_n(w_detail, "product", make_item.id)
  for i = 0, 9 do
    local id = make_item.reg_id[i]
    if id ~= 0 then
      local c = w_detail:search("mat_reg_" .. i)
      ui_cell.set(c, id, make_item.reg_num[i])
      if i > 1 and i % 2 == 0 then
        c.parent.parent.visible = true
      end
    else
      local c = w_detail:search("mat_reg_" .. i)
      if i > 1 and i % 2 == 0 then
        c.parent.parent.visible = false
      end
    end
  end
  w_detail:search("lb_money").money = make_item.money
end
function on_item_count(card, excel_id, bag, all)
  local c = ui_cell.top_of(card)
  if c.name == L("product") then
    return
  end
end
function on_max_click(btn)
  post_product_update()
  ui_widget.ui_count_box.set_max(w_count_box)
end
