function on_im_combo_box(btn)
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
    ui_widget.ui_combo_box.select(cb, item.id)
    local event = svar.on_select
    if event == nil then
      return
    end
    event(item)
  end
  local size = #t
  local vs
  if size > 7 then
    size = 7
    vs = true
  end
  local dx = cb.dx
  if vs then
    dx = dx - 20
  end
  local dy = size * 28 + 20
  ui.log("vs %s", vs)
  ui_tool.show_menu({
    items = items,
    event = on_event_list_select,
    source = btn,
    popup = "y",
    dx = dx,
    dy = dy,
    vs = vs
  })
end
local unc_common = SHARED(",ffffff")
local unc_self = SHARED(",ff8040")
local unc_thetype = SHARED(",00ff00")
local unc_owtype = {
  [bo2.OWR_Type_Exclude] = SHARED(",000000"),
  [bo2.OWR_Type_Enemy] = SHARED(",ff0000")
}
function user_name_color(value)
  if value == bo2.player.name then
    return unc_self
  end
  local fnl = friend_name_list[value]
  if fnl == nil then
    return unc_common
  end
  local color = unc_common
  if fnl.thetype ~= 0 then
    color = unc_thetype
  end
  local owtype = fnl.owtype
  if owtype then
    for m, n in pairs(owtype) do
      local t = unc_owtype[m]
      if t ~= nil then
        color = t
        break
      end
    end
  end
  return color
end
function get_chat_merge(text, value, name1, value1, name2, value2, name3, value3, name4, value4, name5, value5)
  local color = user_name_color(value)
  local v = sys.variant()
  local vset = v.set
  vset(v, "cha_name", value .. color)
  if name1 then
    vset(v, name1, value1)
  end
  if name2 then
    vset(v, name2, value2)
  end
  if name3 then
    vset(v, name3, value3)
  end
  if name4 then
    vset(v, name4, value4)
  end
  if name5 then
    vset(v, name5, value5)
  end
  local fmt = ui.get_text(text)
  return sys.mtf_merge(v, fmt)
end
function get_merge(text, value, name1, value1, name2, value2, name3, value3, name4, value4, name5, value5)
  local v = sys.variant()
  v:set("cha_name", value)
  if name1 then
    v:set(name1, value1)
  end
  if name2 then
    v:set(name2, value2)
  end
  if name3 then
    v:set(name3, value3)
  end
  if name4 then
    v:set(name4, value4)
  end
  if name5 then
    v:set(name5, value5)
  end
  local fmt = ui.get_text(text)
  return sys.mtf_merge(v, fmt)
end
function ban_filter(name, channel)
  if friend_name_list[name] then
    for m, n in pairs(friend_name_list[name].owtype) do
      if m == bo2.OWR_Type_Exclude then
        local excel = bo2.gv_chat_list:find(channel)
        if excel and excel.ban == 1 then
          return false
        end
        break
      end
    end
  end
  return true
end
function set_samll_icon(panel, friend_panel)
  local target = panel:search("career_icon")
  local source = friend_panel:search("career_icon")
  target.image = source.image
  target.xcolor = source.xcolor
  target.tip.text = source.tip.text
  target = panel:search("friend_icon")
  source = friend_panel:search("friend_icon")
  target.image = source.image
  target.irect = source.irect
  target.tip.text = source.tip.text
  target.visible = source.visible
  target = panel:search("master_icon")
  source = friend_panel:search("master_icon")
  target.image = source.image
  target.irect = source.irect
  target.tip.text = source.tip.text
  target.visible = source.visible
  panel:search("senior_icon").visible = friend_panel:search("senior_icon").visible
  panel:search("strange_icon").visible = friend_panel:search("strange_icon").visible
  panel:search("black_icon").visible = friend_panel:search("black_icon").visible
  panel:search("enemy_icon").visible = friend_panel:search("enemy_icon").visible
end
function updata_progress(friendly_item, cur_value, max_value)
  if max_value ~= 0 then
    friendly_item:search("text").text = "(" .. cur_value .. "/" .. max_value .. ")"
    local f = cur_value / max_value
    ui_tool.set_progress(friendly_item, f)
  else
    friendly_item:search("text").text = "(" .. cur_value .. ")"
    ui_tool.set_progress(friendly_item, 0)
  end
end
