key_data = {}
c_keyboard_mouse_filter_name = "ui_tool.ui_keyboard.on_keyboard_mouse_filter"
function tmp_tb(t, b, e)
  local temp = {}
  for i = b, e + 1 do
    table.insert(temp, t[i])
  end
  return temp
end
function key_rand()
  for i, v in ipairs(key_data) do
    local d = key_data[i]
    if d.rand ~= nil then
      local max = d.rand.e - d.rand.b + 1
      local r = bo2.rand(1, max)
      local temp = tmp_tb(d.data, d.rand.b, d.rand.e)
      for j, n in ipairs(d.data) do
        if j >= d.rand.b and j <= d.rand.e then
          d.data[j] = temp[r]
          r = r + 1
          if max < r then
            r = 1
          end
        end
      end
    end
  end
end
function cap_chg()
  for i, v in ipairs(key_data) do
    local p = w_keyboard:search(key_data[i].name)
    for j, d in ipairs(key_data[i].data) do
      local c = p:search(sys.format("%s_%s", key_data[i].name, j))
      local btn = c:search("btn")
      if d.key ~= nil then
        if d.key >= ui.VK_A and d.key <= ui.VK_Z then
          d.val = string.lower(d.val)
          d.key = d.key + 32
        elseif d.key >= ui.VK_A + 32 and d.key <= ui.VK_Z + 32 then
          d.val = string.upper(d.val)
          d.key = d.key - 32
        end
      end
      btn.text = d.val
      btn.svar = d
    end
  end
end
function on_init()
  key_data = {
    {
      name = "r1",
      data = {
        {key = 61, val = "="},
        {key = 62, val = ">"},
        {key = 63, val = "?"},
        {key = 64, val = "@"},
        {
          key = ui.VK_LWIN,
          val = "["
        },
        {
          key = ui.VK_RWIN,
          val = "\\"
        },
        {
          key = ui.VK_APPS,
          val = "]"
        },
        {key = 94, val = "^"},
        {
          key = ui.VK_SLEEP,
          val = "_"
        },
        {
          key = ui.VK_NUMPAD0,
          val = "`"
        },
        {
          key = ui.VK_F12,
          val = "{"
        },
        {
          key = ui.VK_F13,
          val = "|"
        },
        {
          key = ui.VK_PRINT,
          val = "*"
        },
        {
          key = ui.VK_BACK,
          val = "Backspace"
        }
      }
    },
    {
      name = "r2",
      rand = {b = 2, e = 11},
      data = {
        {
          key = ui.VK_F15,
          val = "~"
        },
        {
          key = ui.VK_2,
          val = "2"
        },
        {
          key = ui.VK_3,
          val = "3"
        },
        {
          key = ui.VK_4,
          val = "4"
        },
        {
          key = ui.VK_5,
          val = "5"
        },
        {
          key = ui.VK_6,
          val = "6"
        },
        {
          key = ui.VK_7,
          val = "7"
        },
        {
          key = ui.VK_8,
          val = "8"
        },
        {
          key = ui.VK_9,
          val = "9"
        },
        {
          key = ui.VK_0,
          val = "0"
        },
        {
          key = ui.VK_1,
          val = "1"
        },
        {
          key = ui.VK_PRIOR,
          val = "!"
        },
        {
          key = ui.VK_NEXT,
          val = "\""
        },
        {
          key = ui.VK_CAPITAL,
          val = "Capslock"
        }
      }
    },
    {
      name = "r3",
      rand = {b = 1, e = 10},
      data = {
        {
          key = ui.VK_D + 32,
          val = "d"
        },
        {
          key = ui.VK_E + 32,
          val = "e"
        },
        {
          key = ui.VK_F + 32,
          val = "f"
        },
        {
          key = ui.VK_G + 32,
          val = "g"
        },
        {
          key = ui.VK_H + 32,
          val = "h"
        },
        {
          key = ui.VK_I + 32,
          val = "i"
        },
        {
          key = ui.VK_J + 32,
          val = "j"
        },
        {
          key = ui.VK_K + 32,
          val = "k"
        },
        {
          key = ui.VK_L + 32,
          val = "l"
        },
        {
          key = ui.VK_M + 32,
          val = "m"
        },
        {
          key = ui.VK_END,
          val = "#"
        },
        {
          key = ui.VK_HOME,
          val = "$"
        },
        {
          key = ui.VK_LEFT,
          val = "%"
        },
        {
          key = ui.VK_UP,
          val = "&"
        },
        {
          key = ui.VK_F14,
          val = "}"
        }
      }
    },
    {
      name = "r4",
      rand = {b = 1, e = 9},
      data = {
        {
          key = ui.VK_N + 32,
          val = "n"
        },
        {
          key = ui.VK_O + 32,
          val = "o"
        },
        {
          key = ui.VK_P + 32,
          val = "p"
        },
        {
          key = ui.VK_Q + 32,
          val = "q"
        },
        {
          key = ui.VK_R + 32,
          val = "r"
        },
        {
          key = ui.VK_S + 32,
          val = "s"
        },
        {
          key = ui.VK_T + 32,
          val = "t"
        },
        {
          key = ui.VK_U + 32,
          val = "u"
        },
        {
          key = ui.VK_V + 32,
          val = "v"
        },
        {
          key = ui.VK_RIGHT,
          val = "'"
        },
        {
          key = ui.VK_DOWN,
          val = "("
        },
        {
          key = ui.VK_SELECT,
          val = ")"
        },
        {
          key = ui.VK_RETURN,
          val = "Enter"
        }
      }
    },
    {
      name = "r5",
      rand = {b = 1, e = 7},
      data = {
        {
          key = ui.VK_W + 32,
          val = "w"
        },
        {
          key = ui.VK_X + 32,
          val = "x"
        },
        {
          key = ui.VK_Y + 32,
          val = "y"
        },
        {
          key = ui.VK_Z + 32,
          val = "z"
        },
        {
          key = ui.VK_A + 32,
          val = "a"
        },
        {
          key = ui.VK_B + 32,
          val = "b"
        },
        {
          key = ui.VK_C + 32,
          val = "c"
        },
        {
          key = ui.VK_EXECUTE,
          val = "+"
        },
        {
          key = ui.VK_SNAPSHOT,
          val = ","
        },
        {
          key = ui.VK_INSERT,
          val = "-"
        },
        {
          key = ui.VK_DELETE,
          val = "."
        },
        {
          key = ui.VK_HELP,
          val = "/"
        },
        {key = 58, val = ":"},
        {key = 59, val = ";"},
        {key = 60, val = "<"}
      }
    }
  }
  local style_uri = "$gui/phase/tool/tool_keyboard.xml"
  local style_name = "key"
  for i, v in ipairs(key_data) do
    local p = w_keyboard:search(key_data[i].name)
    p:control_clear()
    for j, d in ipairs(key_data[i].data) do
      local c = ui.create_control(p, "panel")
      c:load_style(style_uri, style_name)
      c.name = sys.format("%s_%s", key_data[i].name, j)
      if 1 < string.len(d.val) then
        if i == 4 then
          c.dx = c.dx * 3 + 3
        else
          c.dx = c.dx * 2 + 2
        end
      end
      local btn = c:search("btn")
      btn.text = d.val
      btn.svar = d
    end
  end
end
function show_keyboard(data)
  local style_uri = "$gui/phase/tool/tool_keyboard.xml"
  local style_name = "key"
  g_data = data
  w_keyboard.visible = not w_keyboard.visible
  key_rand()
  if w_keyboard.visible == false then
    return
  end
  for i, v in ipairs(key_data) do
    local p = w_keyboard:search(key_data[i].name)
    for j, d in ipairs(key_data[i].data) do
      local c = p:search(sys.format("%s_%s", key_data[i].name, j))
      local btn = c:search("btn")
      btn.text = d.val
      btn.svar = d
    end
  end
  w_keyboard:move_to_head()
  if data.input_ctrl == nil then
    w_keyboard:show_popup(data.btn, data.popup)
  else
    w_keyboard:show_popup(data.input_ctrl, data.popup)
  end
  ui.insert_mouse_filter_prev(on_keyboard_mouse_filter, c_keyboard_mouse_filter_name)
end
g_keyboard_valid_msg = {
  [ui.mouse_lbutton_down] = 1,
  [ui.mouse_rbutton_down] = 1,
  [ui.mouse_lbutton_dbl] = 1,
  [ui.mouse_rbutton_dbl] = 1
}
function on_keyboard_mouse_filter(ctrl, msg, pos, wheel)
  if g_keyboard_valid_msg[msg] == nil then
    return
  end
  while sys.check(ctrl) do
    if ctrl == w_keyboard then
      return
    end
    ctrl = ctrl.parent
  end
  ui.remove_mouse_filter_prev(c_keyboard_mouse_filter_name)
  keyboard_hide()
end
function keyboard_hide()
  w_keyboard.visible = false
end
function on_key_click(btn)
  local d = btn.svar
  if d.key ~= nil and d.key == ui.VK_RETURN then
    keyboard_hide()
    return
  end
  if d.key ~= nil and d.key == ui.VK_CAPITAL then
    cap_chg()
    return
  end
  if d.key ~= nil and d.key == ui.VK_BACK and g_data.input_ctrl ~= nil then
    g_data.input_ctrl:on_char(d.key)
    return
  end
  if g_data.input_ctrl ~= nil then
    g_data.input_ctrl:on_char(d.key)
  end
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
  else
    ui_widget.esc_stk_pop(w)
  end
end
