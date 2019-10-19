g_select = {
  count = 0,
  select = {}
}
function on_init()
  for i = 0, 7 do
    local name = "p_" .. i
    local p = w_pic:search(name)
    p.var:set("id", i)
  end
  g_select = {
    count = 0,
    select = {}
  }
end
function select_push(t)
  g_select.count = g_select.count + 1
  table.insert(g_select.select, t)
end
function select_pop()
  g_select.count = g_select.count - 1
  table.remove(g_select.select, 1)
end
function select_op_push(t)
  if g_select.count < 2 then
    select_push(t)
    return
  end
  select_pop()
  select_push(t)
end
function select_update()
  for i = 0, 7 do
    local name = "p_" .. i
    local p = w_pic:search(name)
    local select = p:search("select")
    select.visible = false
  end
  ui.log("selects:%d", g_select.count)
  for i = 1, g_select.count do
    ui.log(i)
    local name = "p_" .. g_select.select[i].id
    ui.log(name)
    local p = w_pic:search(name)
    local select = p:search("select")
    select.visible = true
  end
end
function select_sort()
  if g_select.count ~= 2 then
    return
  end
  if g_select.select[1].id < g_select.select[2].id then
    return
  end
  local temp = g_select.select[1].id
  g_select.select[1].id = g_select.select[2].id
  g_select.select[2].id = temp
end
function load()
  ui.log("load data")
  local pic = w_panel:search("pic")
  if pic == nil then
    return
  end
  pic:load_data()
  set_visible(true)
end
function on_p_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    local index = panel.var:get("id").v_int
    ui.log("mouse:%d", index)
    local t = {id = index}
    select_op_push(t)
    select_update()
  end
end
function set_visible(vis)
  local w = ui.find_control("$frame:scode")
  w.visible = vis
end
function on_esc_stk_visible(w, vis)
  if not vis then
    g_select = {
      count = 0,
      select = {}
    }
    select_update()
  end
end
function on_sure(btn)
  select_sort()
  send_answer(g_select)
  set_visible(false)
end
function on_cancel(btn)
end
