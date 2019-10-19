g_popos = {}
FADER_VALUE = 0.5
function on_init()
end
function box_insert_text(box, text)
  local rank = ui.mtf_rank_system
  box:insert_mtf(text, rank)
end
function replace_last(data)
  for i, v in ipairs(g_popos) do
    if v.input_ctrl == data.input_ctrl then
      local w = v.w
      table.remove(g_popos, i)
      w:control_clear()
    end
  end
end
function show_all(text)
  ui.log(string.find(text, ">"))
  if string.find(text, "<i:") == nil and string.find(text, "<ci:") == nil and string.find(text, "<fi:") == nil and string.find(text, "<cii:") == nil and string.find(text, "<scii:") == nil then
    return false
  end
  return true
end
function show_talkpopo(data)
  if data.input_ctrl == nil then
    return
  end
  local style_uri = "$gui/phase/tool/tool_talkpopo.xml"
  local style_name = "talkpopo"
  local w = ui.create_control(ui_main.w_top)
  w.priority = 102
  w:load_style(style_uri, style_name)
  local box = w:search("box")
  local fader = w:search("fader")
  local stk = sys.mtf_stack()
  stk:raw_push("<a:m><popo_x1:1,")
  stk:push(data.text)
  stk:raw_push(">")
  if show_all(tostring(stk.text)) ~= false or data.max_text_size == 0 and data.max_text_size == nil or data.text.size >= data.max_text_size then
  end
  local s = sys.mtf_stack()
  s:raw_push("<a:m><popo_x1:1,")
  s:push(data.text)
  s:raw_push(">")
  box_insert_text(box, s.text)
  box.parent:tune("box")
  w.size = box.parent.size
  replace_last(data)
  w:show_popup(data.input_ctrl, data.popup, data.margin)
  if data.time ~= nil then
    fader:reset(1, FADER_VALUE, data.time)
  else
    fader:reset(1, FADER_VALUE, 5000)
  end
  local t = {
    w = w,
    input_ctrl = data.input_ctrl
  }
  table.insert(g_popos, t)
end
function on_timer(timer)
  if #g_popos == 0 then
    return
  end
  for i, v in ipairs(g_popos) do
    local fader = v.w:search("fader")
    if fader.alpha <= FADER_VALUE + 0.1 then
      local w = v.w
      table.remove(g_popos, i)
      w:control_clear()
    end
  end
end
