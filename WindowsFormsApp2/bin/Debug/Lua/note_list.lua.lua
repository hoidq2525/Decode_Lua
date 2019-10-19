local c_rb_text = SHARED("rb_text")
local c_fader = SHARED("fader")
local c_span_fader1 = 120
local c_span_fader2 = 1000
local c_span_delay = 4000
local c_span = c_span_fader1 + c_span_fader2 + c_span_delay
local c_span_min = c_span - 2000
local c_span_max = c_span + 16000
local pop = function(d)
  local index = d.index
  if index <= 0 then
    return
  end
  local tick = sys.tick()
  local list = d.list
  local item = list:item_get(0)
  local item_data = item.svar.note_item_data
  local remain = item_data.span - sys.dtick(tick, item_data.tick)
  for i = 1, index - 1 do
    local t_item = list:item_get(i)
    local t_item_data = t_item.svar.note_item_data
    local t_remain = item_data.span - sys.dtick(tick, t_item_data.tick)
    if remain > t_remain then
      item = t_item
      item_data = t_item_data
      remain = t_remain
    end
  end
  item.index = d.count - 1
  item_data.fader.visible = false
  item_data.text.text = nil
  d.index = index - 1
end
function reset_fader(d, span)
  local f = d.fader
  f:reset(0, 1, 120)
  f.visible = true
  d.tick = sys.tick()
  if span == nil or span == 0 then
    d.span = c_span
  elseif span < c_span_min then
    d.span = c_span_min
  elseif span > c_span_max then
    d.span = c_span_min
  else
    d.span = span
  end
end
function insert_ex(w, text, color, data)
  if data ~= nil then
    insert(w, text, color, data.span, data.show_scn, data.limit_group, data.limit_count)
  else
    insert(w, text, color)
  end
end
function insert(w, text, color, span, show_scn, limit_group, limit_count)
  local d = w.svar.note_list_data
  if d == nil then
    return
  end
  local curidx = d.index
  if curidx >= d.count then
    pop(d)
    curidx = d.index
  end
  local item_find
  text = L(text)
  local list = d.list
  if limit_group ~= nil and limit_group ~= 0 then
    local item1, item1_data
    local item_cnt = 0
    for i = 0, curidx - 1 do
      local item = list:item_get(i)
      local item_data = item.svar.note_item_data
      local t = item_data.limit_group
      if t == limit_group then
        item_cnt = item_cnt + 1
        if item1 == nil then
          item1 = item
          item1_data = item_data
        end
        if limit_count <= item_cnt then
          item1.index = curidx - 1
          d.index = curidx
          item_find = item1
          break
        end
      end
    end
  else
    for i = 0, curidx - 1 do
      local item = list:item_get(i)
      local item_data = item.svar.note_item_data
      local t = item_data.text_data
      if t == text then
        item.index = curidx - 1
        item_data.limit_count = nil
        reset_fader(item_data, span)
        return
      end
    end
  end
  local item
  if item_find ~= nil then
    item = item_find
  else
    item = d.list:item_get(curidx)
    d.index = curidx + 1
  end
  local item_data = item.svar.note_item_data
  item_data.limit_group = limit_group
  reset_fader(item_data, span)
  local mtf
  if color ~= nil then
    if show_scn == nil or show_scn == false then
      mtf = sys.format("<a:m><dc:%.8X>%s", ui.make_color(color), text)
    else
      mtf = sys.format("<a:m><dc:%.8X><lb:art,36,half,|%s>", ui.make_color(color), text)
    end
  elseif show_scn == nil or show_scn == false then
    mtf = sys.format("<a:m>%s", text)
  else
    mtf = sys.format("<a:m><lb:art,36,half,|%s>", text)
  end
  item_data.text.mtf = mtf
  item_data.text_data = text
  item:tune_y(c_rb_text)
  if curidx < 1 then
    return
  end
  local dy = w.dy
  local outer = true
  while outer do
    outer = false
    local y = 0
    for i = 0, curidx - 1 do
      y = y + list:item_get(i).dy
      if dy < y then
        pop(d)
        outer = true
        curidx = d.index - 1
        if curidx < 1 then
          return
        end
        break
      end
    end
  end
end
function on_fade_stop(f)
  local item = f.parent
  local item_data = item.svar.note_item_data
  if f.alpha > 0.5 then
    f:reset(1, 0, c_span_fader2, item_data.span - c_span_fader2 - c_span_fader1)
    return
  end
  local d = item.view.parent.svar.note_list_data
  item_data.fader.visible = false
  if item.index >= d.index then
    return
  end
  item.index = d.count - 1
  item_data.text.text = nil
  d.index = d.index - 1
end
function on_list_init(w)
  local d = {
    top = w,
    index = 0,
    count = 0,
    list = w:search("note_list"),
    reserve_data = nil
  }
  w.svar.note_list_data = d
  d.count = d.list.item_count
  for i = 0, d.count - 1 do
    local item = d.list:item_get(i)
    local item_data = {
      item = item,
      fader = item:search(c_fader),
      text = item:search(c_rb_text),
      span = c_span
    }
    item.svar.note_item_data = item_data
    item_data.fader.visible = false
  end
end
