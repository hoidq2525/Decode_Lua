if rawget(_M, "g_money_datas") == nil then
  g_money_datas = {}
end
function update_draw()
  for n, v in pairs(g_money_datas) do
    v.money.money = ui.guild_get_drawmoney()
    v.cantri.text = ui.guild_get_drawcontri()
  end
end
function on_view_close(w)
  g_money_datas[w] = nil
end
function on_view_init(w)
  local d = {
    top = w,
    money = w:search("lb_money"),
    cantri = w:search("lb_contri")
  }
  g_money_datas[w] = d
  local player = bo2.player
  if player ~= nil then
    d.money.money = ui.guild_get_drawmoney()
    d.cantri.text = ui.guild_get_drawcontri()
  end
  ui.insert_on_guild_draw_refresh("ui_org.ui_guild_draw_view.update_draw", "update_draw")
end
function on_view_visible()
  update_draw()
end
