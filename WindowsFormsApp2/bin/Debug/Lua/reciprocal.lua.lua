function resize()
  w_reciprocal.dy = 0
  local count = 0
  for k, v in pairs(items) do
    w_reciprocal.dy = w_reciprocal.dy + 36
    count = count + 1
  end
  if count > 0 then
    w_reciprocal.dy = w_reciprocal.dy + 8
  end
end
function add_reciproca(mark, sub)
  if mark == nil then
    return
  end
  if sub == nil then
    return
  end
  if sub.time == nil then
    return
  end
  if sub.name == nil then
    sub = ui.get_text("common|countdown")
  end
  if sub.manger == nil then
    sub.manger = true
  end
  local style_uri = L("$gui/frame/reciprocal/reciprocal.xml")
  local style_name_g = L("cell")
  local item_g = w_top:item_append()
  item_g:load_style(style_uri, style_name_g)
  item_g:search("text").text = sub.name
  item_g:search("time").left_time = sub.time
  if sub.icon then
    item_g:search("reciprocal_icon").image = sub.icon
  end
  if sub.manger == false then
    item_g:search("manger_panel").visible = false
  end
  items[mark] = {sub = sub, c = item_g}
  resize()
  return true
end
function del_reciproca(mark)
  if items[mark] == nil then
    return
  end
  w_top:item_remove(items[mark].c.index)
  items[mark] = nil
  resize()
end
function find_reciproca(mark)
  if items[mark] == nil then
    return nil
  end
  return items[mark].sub
end
function on_reciprocal_timer()
  for k, v in pairs(items) do
    if sys.check(v.c) then
      local ctime = v.c:search("time")
      local left_time = ctime.left_time.v_int
      local total_time = v.sub.time
      local manger_item = v.c:search("manger")
      local diff = math.floor((total_time - left_time) / total_time * 172)
      local rect = manger_item.margin
      manger_item:search("manger").margin = ui.rect(rect.x1, rect.y1, diff, rect.y2)
      if left_time <= 0 then
        if v.sub.close == true then
          del_reciproca(k)
        end
        if v.sub.callback then
          v.sub.callback()
        end
        break
      end
    end
  end
end
function on_init()
  items = {}
end
