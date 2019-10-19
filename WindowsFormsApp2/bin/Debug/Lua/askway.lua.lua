function on_init()
  main.visible = false
end
function show_wnd(npc_func_id)
  main.visible = true
  get_marks(npc_func_id)
end
function close_wnd()
  mark_list:item_clear()
  main.visible = false
end
function insert_mark(lb_name, name)
  local item = mark_list:item_append()
  item:load_style("$gui/frame/askway/askway.xml", "list_item")
  mark_item.text = lb_name
  mark_item.name = name
  return true
end
function on_click_goto(btn)
  ui_map.find_path_byid(btn.name.v_int)
  main.visible = false
end
function get_marks(id)
  mark_list:item_clear()
  local exc1 = bo2.gv_npc_func
  local exc2 = bo2.gv_mark_list
  if exc1 == nil or exc2 == nil then
    return nil
  end
  local ln1 = exc1:find(id)
  if ln1 == nil then
    return
  end
  for i = 0, ln1.datas.size - 1 do
    local ln2 = exc2:find(ln1.datas[i])
    if ln2 ~= nil then
      insert_mark(ln2.name, ln2.id)
    end
  end
end
