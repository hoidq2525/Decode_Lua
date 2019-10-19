if _M.input_data == nil then
  local v_texts = sys.variant()
  v_texts.type = sys.vt_array
  input_data = {
    limit = 20,
    index = -1,
    texts = v_texts
  }
end
function input_data_roll(i)
  local cnt = input_data.texts.size
  if cnt == 0 then
    return
  end
  local idx = input_data.index + i
  if idx < 0 then
    idx = cnt - 1
  elseif cnt <= idx then
    idx = 0
  end
  input_data.index = idx
  w_input.text = input_data.texts:get(idx)
end
function input_data_add(txt)
  local texts = input_data.texts
  local idx = texts:index(txt)
  if idx >= 0 then
    texts:erase(idx)
  else
    local limit = input_data.limit
    while limit < texts.size do
      texts:erase(0)
    end
  end
  texts:push_back(txt)
  input_data.index = -1
end
function input_data_load(x)
  if x == nil then
    return
  end
  local n = x:find("texts")
  if n == nil then
    return
  end
  for i = 0, n.size - 1 do
    local t = n:get(i)
    local s = t:get_attribute("value")
    if not s.empty then
      input_data_add(s)
    end
  end
end
function input_data_save(x)
  if x == nil then
    return
  end
  local n = x:get("texts")
  n:clear()
  local texts = input_data.texts
  if texts.empty then
    return
  end
  for i = 0, texts.size - 1 do
    n:add("item"):set_attribute("value", texts:get(i))
  end
end
