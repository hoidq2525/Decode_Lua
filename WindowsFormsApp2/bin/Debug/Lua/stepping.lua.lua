function on_stepping_click(btn)
  local stepping = btn.parent
  local var = stepping.svar.stepping
  local idx = var.index
  if btn.name == L("btn_head") then
    idx = 0
  elseif btn.name == L("btn_foot") then
    idx = var.count
  elseif btn.name == L("btn_prev") then
    idx = idx - 1
  elseif btn.name == L("btn_next") then
    idx = idx + 1
  end
  update(stepping, idx)
  local h = var.on_step
  if h == nil then
    return
  end
  if type(h) == "function" then
    h(var)
  else
    h = sys.get(h)
    if h ~= nil then
      h(var)
    end
  end
end
function update(stepping, idx, cnt, text)
  local var = stepping.svar.stepping
  if text == nil then
    text = var.text
  end
  if cnt == nil then
    cnt = var.count
  end
  local btn_head = true
  local btn_foot = true
  local btn_prev = true
  local btn_next = true
  if cnt <= 1 then
    btn_head = false
    btn_foot = false
    btn_prev = false
    btn_next = false
    idx = cnt
  else
    if idx <= 0 then
      idx = 0
    elseif cnt <= idx then
      idx = cnt - 1
    end
    idx = idx + 1
    if idx <= 1 then
      idx = 1
      btn_head = false
      btn_prev = false
    elseif cnt <= idx then
      idx = cnt
      btn_foot = false
      btn_next = false
    end
  end
  var.count = cnt
  var.index = idx
  if idx > 0 then
    var.index = idx - 1
  else
    var.index = 0
  end
  stepping:search("btn_head").enable = btn_head
  stepping:search("btn_foot").enable = btn_foot
  stepping:search("btn_prev").enable = btn_prev
  stepping:search("btn_next").enable = btn_next
  local s
  if text ~= nil then
    local v = sys.variant()
    v:set("index", idx)
    v:set("count", cnt)
    s = sys.mtf_merge(v, text)
  else
    s = sys.format("%d/%d", idx, cnt)
  end
  stepping:search("lb_text").text = s
end
function on_init(stepping)
  var = {
    index = 0,
    count = 0,
    text = L("{index}/{count}")
  }
  stepping.svar.stepping = var
end
function set_event(stepping, h)
  local var = stepping.svar.stepping
  var.on_step = h
end
function set_page(stepping, idx, cnt)
  update(stepping, idx, cnt, "{index}/{count}")
end
function set_number(stepping, idx, cnt)
  update(stepping, idx, cnt, "{index}/{count}")
end
