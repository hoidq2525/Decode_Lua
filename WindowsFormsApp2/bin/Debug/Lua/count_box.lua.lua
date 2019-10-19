local check_text_range = function(d, input, txt)
  local s = txt.v_int
  local c = s
  local sel_all = false
  if d.max ~= nil and c > d.max then
    c = d.max
  end
  if d.min ~= nil and c < d.min then
    c = d.min
    sel_all = true
  end
  if c ~= s then
    input.text = c
  end
  if sel_all then
    input:select(0, input.text.size)
  end
end
function on_change(tb, txt)
  local d = tb.parent.parent.svar.count_box_data
  check_text_range(d, tb, txt)
end
function on_btn_prev_click(btn)
  local d = btn.parent.svar.count_box_data
  local input = d.input
  local val = input.text.v_int
  local val = math.floor(val - 1)
  local min_v = d.min
  if min_v ~= nil and val < min_v then
    val = min_v
  end
  input.text = val
end
function on_btn_next_click(btn)
  local d = btn.parent.svar.count_box_data
  local input = d.input
  local val = input.text.v_int
  local val = math.floor(val + 1)
  local max_v = d.max
  if max_v ~= nil and val > max_v then
    val = max_v
  end
  input.text = val
end
local function update(w, d)
  local input = d.input
  check_text_range(d, input, input.text)
  local min_v = d.min
  local max_v = d.max
  if min_v == nil or max_v == nil or min_v <= max_v then
    w:search("btn_prev").enable = true
    w:search("btn_next").enable = true
    input.enable = true
    return
  end
  w:search("btn_prev").enable = false
  w:search("btn_next").enable = false
  input.enable = false
end
function on_init(w, range)
  local d = {}
  w.svar.count_box_data = d
  d.input = w:search("tb_input")
  if not range.empty then
    local min_v, max_v = range:split2(",")
    if not min_v.empty then
      d.min = min_v.v_int
      d.input.text = min_v
    end
    if not max_v.empty then
      d.max = max_v.v_int
    end
  end
  update(w, d)
end
function set_range(w, min_v, max_v)
  local d = w.svar.count_box_data
  d.min = min_v
  d.max = max_v
  update(w, d)
end
function get_range(w)
  local d = w.svar.count_box_data
  return d.min, d.max
end
function set_value(w, v)
  local d = w.svar.count_box_data
  d.input.text = v
  update(w, d)
end
function get_value(w)
  local d = w.svar.count_box_data
  return d.input.text.v_int
end
function set_max(w)
  local d = w.svar.count_box_data
  if d.max == nil then
    return
  end
  d.input.text = d.max
  update(w, d)
end
function set_min(w)
  local d = w.svar.count_box_data
  if d.min == nil then
    return
  end
  d.input.text = d.min
  update(w, d)
end
function set_enable(w, enable)
  w.enable = enable
  w:search("btn_prev").enable = enable
  w:search("btn_next").enable = enable
  w:search("tb_input").enable = enable
end
