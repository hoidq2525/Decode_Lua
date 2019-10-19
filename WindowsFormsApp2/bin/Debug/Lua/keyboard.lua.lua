function toggle()
  w_info.visible = not w_info.visible
end
function show_mini(vis, sub_rect, tip, offset)
  if not vis then
    w_mini.visible = false
    return
  end
  w_mini.visible = true
  if offset == nil then
    w_mini.dock = "pin_x2y2"
  else
    w_mini.dock = "none"
    w_mini.offset = offset
  end
  local sz
  if sub_rect == nil then
    w_mini_pic.offset = ui.point(0, 0)
    sz = w_mini_pic.size
  else
    w_mini_pic.offset = ui.point(-sub_rect.x1, -sub_rect.y1)
    sz = sub_rect.size
  end
  w_mini.size = ui.point(sz.x, sz.y + 22)
  if tip ~= nil then
    w_mini_tip.visible = true
    w_mini_tip.mtf = tip
  else
    w_mini_tip.visible = false
  end
end
function on_mini_visible(ctrl, vis)
  if not vis then
    flash_clear()
  end
end
key_def = {
  ["esc"] = {
    7,
    8,
    22,
    20
  },
  ["f5"] = {
    159,
    8,
    22,
    20
  },
  ["f6"] = {
    186,
    8,
    22,
    20
  },
  ["f11"] = {
    326,
    8,
    22,
    20
  },
  ["f12"] = {
    353,
    8,
    22,
    20
  },
  ["print"] = {
    385,
    8,
    26,
    20
  },
  ["1"] = {
    34,
    35,
    22,
    24
  },
  ["2"] = {
    61,
    35,
    22,
    24
  },
  ["3"] = {
    88,
    35,
    22,
    24
  },
  ["4"] = {
    115,
    35,
    22,
    24
  },
  ["5"] = {
    142,
    35,
    22,
    24
  },
  ["6"] = {
    169,
    35,
    22,
    24
  },
  ["7"] = {
    196,
    35,
    22,
    24
  },
  ["8"] = {
    223,
    35,
    22,
    24
  },
  ["9"] = {
    250,
    35,
    22,
    24
  },
  ["0"] = {
    277,
    35,
    22,
    24
  },
  ["tab"] = {
    7,
    63,
    36,
    24
  },
  ["w"] = {
    75,
    63,
    22,
    24
  },
  ["t"] = {
    156,
    63,
    22,
    24
  },
  ["i"] = {
    237,
    63,
    22,
    24
  },
  ["a"] = {
    56,
    91,
    22,
    24
  },
  ["s"] = {
    83,
    91,
    22,
    24
  },
  ["d"] = {
    110,
    91,
    22,
    24
  },
  ["g"] = {
    164,
    91,
    22,
    24
  },
  ["k"] = {
    245,
    91,
    22,
    24
  },
  ["l"] = {
    272,
    91,
    22,
    24
  },
  ["enter"] = {
    353,
    91,
    55,
    24
  },
  ["shift"] = {
    7,
    119,
    59,
    24
  },
  ["z"] = {
    71,
    119,
    22,
    24
  },
  ["c"] = {
    125,
    119,
    22,
    24
  },
  ["b"] = {
    179,
    119,
    22,
    24
  },
  ["n"] = {
    206,
    119,
    22,
    24
  },
  ["m"] = {
    233,
    119,
    22,
    24
  },
  ["ctrl"] = {
    7,
    147,
    33,
    24
  },
  ["space"] = {
    115,
    147,
    154,
    24
  }
}
function flash_insert(key)
  key = tostring(key)
  local kd = key_def[key]
  if kd == nil then
    return
  end
  local svar = w_mini.svar
  local flash_keys = svar.flash_keys
  if flash_keys == nil then
    flash_keys = {}
    svar.flash_keys = flash_keys
  end
  if flash_keys[key] ~= nil then
    return
  end
  local key_info = {}
  flash_keys[key] = key_info
  local w = ui.create_control(w_mini_pic, "flicker")
  w:load_style("$frame/qbar/keyboard.xml", "flash")
  local x = kd[1]
  local y = kd[2]
  w.area = ui.rect(x, y, x + kd[3], y + kd[4])
  key_info.window = w
end
function disable_key(key)
  key = tostring(key)
  local kd = key_def[key]
  if kd == nil then
    return
  end
  local svar = w_mini.svar
  local flash_keys = svar.flash_keys
  if flash_keys == nil then
    flash_keys = {}
    svar.flash_keys = flash_keys
  end
  if flash_keys[key] ~= nil then
    return
  end
  local key_info = {}
  flash_keys[key] = key_info
  local w = ui.create_control(w_mini_pic, "panel")
  w:load_style("$frame/qbar/keyboard.xml", "disable")
  local x = kd[1]
  local y = kd[2]
  w.area = ui.rect(x, y, x + kd[3], y + kd[4])
  key_info.window = w
end
function disable_all_key(t)
  for i, v in pairs(key_def) do
    disable_key(i)
  end
  for i, key in ipairs(t) do
    local _key = tostring(key)
    local svar = w_mini.svar
    local flash_keys = svar.flash_keys
    if flash_keys[key] ~= nil then
      local key_info = flash_keys[key]
      local w = key_info.window
      if sys.check(w) then
        w.visible = false
        w:post_release()
      end
    end
    flash_keys[key] = nil
  end
end
function flash_insert_keys(t)
  disable_all_key(t)
  for i, key in ipairs(t) do
    flash_insert(key)
  end
end
function flash_clear()
  local svar = w_mini.svar
  local flash_keys = svar.flash_keys
  if flash_keys == nil then
    return
  end
  svar.flash_keys = nil
  for n, key_info in pairs(flash_keys) do
    local w = key_info.window
    if sys.check(w) then
      w.visible = false
      w:post_release()
    end
  end
end
