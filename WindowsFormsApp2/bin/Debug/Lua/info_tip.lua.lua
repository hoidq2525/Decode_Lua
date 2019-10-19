g_menu = {
  items = {},
  dx = 150,
  dy = 300
}
local text = ui.get_text(L("info_tip|new_info"))
second = 0
function on_new_info_timer()
  if second < 0 then
    return
  end
  if second == 0 then
    infos.visible = false
  else
    local pos = w_flicker1.abs_area
    infos.offset = ui.point((pos.x1 + pos.x2) * 0.5 - 28, pos.y2)
    infos.visible = true
  end
  second = second - 1
end
function on_init()
  for i = 1, #g_menu.items do
    table.remove(g_menu.items, 1)
  end
end
function callback_account(item)
  ui_guildfarm.account_book.on_show_click()
end
function callback_sch(item)
  ui_info_tip.schedule_cd.sch_cd.visible = true
end
function callback_prison(item)
  ui_prison.prison_book.on_show_click()
end
function callback_tmpbattle(item)
  ui_info_tip.tmp_battle.tmpbattle_cd.visible = true
end
function on_menu_event2(item)
  item.check_flag = true
  ui_info_tip.w_flicker2.suspended = check()
  item.list_item:search("btn_flk").suspended = true
  if item.callback then
    item.callback(item)
  end
end
g_menu.event = on_menu_event2
function find_item(id)
  for i = 1, #g_menu.items do
    if g_menu.items[i].id == id then
      return i
    end
  end
  return nil
end
function check()
  for i = 1, #g_menu.items do
    if g_menu.items[i].check_flag == false then
      return false
    end
  end
  return true
end
function info_tip_show(tip)
  local stk = sys.mtf_stack()
  local tips = ui.get_text(L("info_tip|info_tip"))
  ui_tool.ctip_push_text(stk, tips .. "(" .. #g_menu.items .. ")", "FFFFFF")
  ui_tool.ctip_show(tip.owner, stk)
end
function on_click_add_msg(id)
  if find_item(id) == nil then
    ui_info_tip.infos:search("new_info").mtf = sys.format(L("<handson:,5,%s>"), text)
    if id > 1 then
      second = 25
    end
    local item = ui_info_tip.info_tip_inc.info_menu[id]
    item.style_uri = L("$gui/frame/info_tip/info_tip.xml")
    item.style = L("menu_item2")
    if id ~= 1 then
      item.check_flag = false
    else
      item.check_flag = true
    end
    table.insert(g_menu.items, item)
  end
  if #g_menu.items > 0 then
    if id == 6 then
      local flag = ui_info_tip.tmp_battle.get_tmpbattle_curflag()
      if flag == true then
        ui_info_tip.w_flicker2.visible = true
      else
        ui_info_tip.w_flicker2.visible = false
      end
    else
      ui_info_tip.w_flicker2.visible = true
    end
    ui_info_tip.w_flicker2.suspended = check()
  end
end
function on_click_del_msg(id)
  local item = ui_info_tip.info_tip_inc.info_menu[id]
  local i = find_item(id)
  if i ~= nil then
    table.remove(g_menu.items, i)
  end
  if #g_menu.items <= 0 then
    ui_info_tip.w_flicker2.visible = false
  end
end
function add_quest_info(qst_id)
  for i = 1, #ui_info_tip.info_tip_inc.info_menu do
    if ui_info_tip.info_tip_inc.info_menu[i].quest_id == qst_id then
      on_click_add_msg(ui_info_tip.info_tip_inc.info_menu[i].id)
    end
  end
end
function del_quest_info(qst_id)
  for i = 1, #ui_info_tip.info_tip_inc.info_menu do
    if ui_info_tip.info_tip_inc.info_menu[i].quest_id == qst_id then
      on_click_del_msg(ui_info_tip.info_tip_inc.info_menu[i].id)
    end
  end
end
function on_menu_show(menu)
  for i = 1, #menu.items do
    menu.items[i].list_item:search("btn_flk").visible = not g_menu.items[i].check_flag
  end
end
function on_click_show_menu()
  if #g_menu.items <= 0 then
    on_click_add_msg(ui_info_tip.info_tip_inc.no_info)
  end
  g_menu.on_show = on_menu_show
  ui_tool.show_menu(g_menu)
  on_click_del_msg(ui_info_tip.info_tip_inc.no_info)
end
function on_close()
  w_con.visible = false
end
