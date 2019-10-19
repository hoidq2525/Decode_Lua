function insert(cb, idx, data)
  local t = cb.svar.list
  local c = #t
  if idx == nil or idx > c or idx <= 0 then
    table.insert(t, data)
    return
  end
  table.insert(t, idx, data)
end
function append(cb, data)
  local t = cb.svar.list
  table.insert(t, data)
end
local set_select = function(svar, item)
  svar.selected = item
  if item ~= nil then
    svar.btn.text = item.text
    if item.color ~= nil then
      local btn_lb = svar.btn:search("btn_lb")
      if btn_lb ~= nil and item.color ~= nil then
        btn_lb.color = item.color
      end
    end
  else
    svar.btn.text = nil
  end
end
function remove(cb, id)
  if id == nil then
    return
  end
  local svar = cb.svar
  local t = svar.list
  for i, v in ipairs(t) do
    if v.id == id then
      table.remove(t, i)
      if svar.selected == v then
        set_select(svar, t[i])
      end
      break
    end
  end
end
function select(cb, id)
  local svar = cb.svar
  local item
  if id ~= nil then
    local t = svar.list
    for i, v in ipairs(t) do
      if v.id == id then
        item = v
        break
      end
    end
  end
  set_select(svar, item)
end
function selected(cb)
  local item = cb.svar.selected
  return item
end
function find(cb, id)
  if id == nil then
    return nil, nil
  end
  local t = cb.svar.list
  for i, v in ipairs(t) do
    if v.id == id then
      return v, i
    end
  end
  return nil, nil
end
function index(cb, id)
  if id == nil then
    return nil, nil
  end
  local t = cb.svar.list
  for i, v in ipairs(t) do
    if v.id == id then
      return i, v
    end
  end
  return nil, nil
end
function clear(cb)
  local svar = cb.svar
  svar.list = {}
  set_select(svar, nil)
end
function item(cb, idx)
  local t = cb.svar.list
  return t[idx]
end
function size(cb)
  local t = cb.svar.list
  return #t
end
function set_selected_color(cb, color)
  local btn = cb.svar.btn
  local lb = btn:search("btn_lb")
  lb.color = color
end
function on_init(cb)
  local svar = cb.svar
  svar.list = {}
  svar.btn = cb:search("btn_drop_down")
  svar.owner = cb
end
function on_btn_drop_down_click(btn)
  local cb = btn.parent
  local items = {}
  local svar = cb.svar
  local t = svar.list
  for i, v in ipairs(t) do
    local item = {
      id = v.id,
      color = v.color,
      text = v.text,
      style_uri = v.style_uri,
      style = v.style,
      data = v
    }
    table.insert(items, item)
  end
  local function on_event_list_select(item)
    select(cb, item.id)
    local event = svar.on_select
    if event == nil then
      return
    end
    event(item)
  end
  ui_tool.show_menu({
    items = items,
    event = on_event_list_select,
    source = btn,
    popup = "y_auto",
    dx = cb.dx
  })
end
function on_observable(btn, vis)
  if not vis then
    ui_tool.hide_menu(btn)
  end
end
