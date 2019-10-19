local state = "state_small"
local radius = 52
local point = {}
point[1] = {x = 87, y = 65}
point[2] = {x = 198, y = 65}
point[3] = {x = 304, y = 65}
point[4] = {x = 411, y = 65}
point[5] = {x = 49, y = 169}
point[6] = {x = 159, y = 169}
point[7] = {x = 266, y = 169}
point[8] = {x = 375, y = 169}
local rect = {}
rect[1] = ui.rect(74, 0, 0, 2)
rect[2] = ui.rect(182, 0, 0, 2)
rect[3] = ui.rect(289, 0, 0, 2)
rect[4] = ui.rect(397, 0, 0, 2)
rect[5] = ui.rect(36, 101, 0, 0)
rect[6] = ui.rect(146, 101, 0, 0)
rect[7] = ui.rect(253, 101, 0, 0)
rect[8] = ui.rect(361, 101, 0, 0)
local radius1 = 36
local point1 = {}
point1[1] = {x = 62, y = 44}
point1[2] = {x = 136, y = 44}
point1[3] = {x = 211, y = 44}
point1[4] = {x = 285, y = 44}
point1[5] = {x = 34, y = 115}
point1[6] = {x = 112, y = 115}
point1[7] = {x = 184, y = 115}
point1[8] = {x = 278, y = 115}
local rect1 = {}
rect1[1] = ui.rect(220, 76, 0, 0)
rect1[2] = ui.rect(297, 76, 0, 0)
rect1[3] = ui.rect(373, 76, 0, 0)
rect1[4] = ui.rect(447, 76, 0, 0)
rect1[5] = ui.rect(197, 148, 0, 0)
rect1[6] = ui.rect(272, 148, 0, 0)
rect1[7] = ui.rect(348, 148, 0, 0)
rect1[8] = ui.rect(423, 148, 0, 0)
local gaomo = {}
local last_show, cur_show, cur_select, move_state
local move_size = 0
local move_speed = 256
local move_leave_size = 0
local move_leave_speend = 64
local init_rect = {}
init_rect[1] = ui.rect(0, 0, 0, 0)
init_rect[2] = ui.rect(76, 0, 0, 0)
init_rect[3] = ui.rect(152, 0, 0, 0)
init_rect[4] = ui.rect(227, 0, 0, 0)
init_rect[5] = ui.rect(0, 0, 0, 0)
init_rect[6] = ui.rect(109, 0, 0, 0)
init_rect[7] = ui.rect(217, 0, 0, 0)
init_rect[8] = ui.rect(324, 0, 0, 0)
local career_id = {}
local infos = {}
function init_choice_weapon()
  local c = bo2.gv_init_choice_weapon.size
  for i = 1, c do
    local e = bo2.gv_init_choice_weapon:get(i - 1)
    if e.disable ~= 1 then
      gaomo[i] = e.uri
      career_id[i] = e.career
      infos[i] = {
        name = e.uri,
        des = e.des,
        effect1 = e.star[0],
        effect2 = e.star[1],
        effect3 = e.star[2],
        effect4 = e.star[3],
        effect5 = e.star[4]
      }
    end
  end
end
function change_gaomo()
  if cur_show == nil then
    return
  end
  local index = 1
  for i = 0, 3 do
    for j = 0, 3 do
      w_choice_weapon_gaomo:search("back"):set_item(j, i, "$image/phase/choice_weapon/" .. gaomo[cur_show] .. "/" .. index .. ".png")
      index = index + 1
    end
  end
  w_choice_weapon_gaomo:load_res()
  move_size = w_top.dx
  move_state = "move_in"
  w_choice_weapon_timer.suspended = false
  show_info(cur_show)
end
function show_info(id)
  w_choice_weapon_info:search("pic").image = "$image/phase/choice_weapon/" .. infos[id].name .. "_c.png"
  w_choice_weapon_info:search("des").text = infos[id].des
  local rank = ui.mtf_rank_system
  local stk = sys.format([[
<evaluate:%s>
<evaluate:%s>
<evaluate:%s>
<evaluate:%s>
<evaluate:%s>
]], infos[id].effect1, infos[id].effect2, infos[id].effect3, infos[id].effect4, infos[id].effect5)
  w_choice_weapon_info:search("infos"):item_clear()
  w_choice_weapon_info:search("infos"):insert_mtf(stk, rank)
  if last_show == nil then
    w_choice_weapon_info.visible = true
    w_choice_weapon_gaomo.visible = true
  end
  w_choice_weapon_info:reset(0, 1, 1000)
end
function on_choice_weapon_timer()
  if move_state == "move_out" then
    move_size = move_size + move_speed
    w_choice_weapon_gaomo.margin = ui.rect(0, 0, move_size, 0)
    if move_size >= w_top.dx then
      w_choice_weapon_timer.suspended = true
      change_gaomo()
      move_state = "move_in"
    end
  elseif move_state == "move_in" then
    move_size = move_size - move_speed
    w_choice_weapon_gaomo.margin = ui.rect(move_size, 0, 0, 0)
    if move_size <= move_speed then
      w_choice_weapon_gaomo.margin = ui.rect(0, 0, 0, 0)
      w_choice_weapon_timer.suspended = true
      move_size = 0
    end
  elseif move_state == "leave" then
    move_size = move_size + move_speed - 100
    w_choice_weapon_gaomo.margin = ui.rect(0, 0, move_size, 0)
    if stage_leave == 1 then
      move_leave_size = w_choice_weapon_weapons_pic_s_1.margin.x1 + move_leave_speend
      w_choice_weapon_weapons_pic_s_1.margin = ui.rect(move_leave_size, 0, 0, 0)
      if move_leave_size >= 800 then
        move_leave_size = 0
        stage_leave = 2
      end
    elseif stage_leave == 2 then
      move_leave_size = w_choice_weapon_weapons_pic_s_2.margin.x1 + move_leave_speend
      w_choice_weapon_weapons_pic_s_2.margin = ui.rect(move_leave_size, 0, 0, 0)
      if move_leave_size >= 800 then
        move_leave_size = 0
        stage_leave = 3
      end
    elseif stage_leave == 3 then
      move_leave_size = w_choice_weapon_weapons_pic_s_3.margin.x1 + move_leave_speend
      w_choice_weapon_weapons_pic_s_3.margin = ui.rect(move_leave_size, 0, 0, 0)
      if move_leave_size >= 800 then
        move_leave_size = 0
        stage_leave = 4
      end
    elseif stage_leave == 4 then
      move_leave_size = w_choice_weapon_weapons_pic_s_4.margin.x1 + move_leave_speend
      w_choice_weapon_weapons_pic_s_4.margin = ui.rect(move_leave_size, 0, 0, 0)
      if move_leave_size >= 800 then
        move_leave_size = 0
        stage_leave = 5
      end
    elseif stage_leave == 5 then
      w_choice_weapon_timer.suspended = true
      ui.log("career_id %s %s", career_id[cur_show], cur_show)
      cur_career_excel = bo2.gv_career:find(career_id[cur_show])
      w_scn_view_top.visible = true
      w_cha_panel.visible = true
      set_stage(3)
      update_all_state()
      w_choice_weapon:reset(1, 0, 1000)
      stage_leave = 0
    end
  end
end
function move_out(id)
  w_choice_weapon_timer.suspended = false
  move_state = "move_out"
  w_choice_weapon_info:reset(1, 0, 0)
end
function move_in(id)
end
function show_weapon(id)
  if id == cur_show then
    return
  end
  if infos[id] == nil then
    ui_tool.note_insert(ui.get_text("phase|more_career"), "FFFF00")
    return
  end
  last_show = cur_show
  cur_show = id
  if last_show ~= nil then
    move_out(last_show)
  else
    change_gaomo()
  end
end
function on_choice_weapons_mouse(c, msg, pos)
  if msg == ui.mouse_move then
    if state == "state_large" then
      for i, v in ipairs(point) do
        local r = math.sqrt((pos.x - v.x) * (pos.x - v.x) + (pos.y - v.y) * (pos.y - v.y))
        if r < radius then
          w_choice_weapons_pic_l_flash1.margin = rect[i]
          w_choice_weapons_pic_s_flash1.margin = rect1[i]
          w_choice_weapons_pic_l_flash1.visible = true
          w_choice_weapons_pic_s_flash1.visible = false
          if cur_select ~= i then
            bo2.PlaySound2D(541, false)
          end
          cur_select = i
          break
        end
      end
    else
      for i, v in ipairs(point1) do
        local r = math.sqrt((pos.x - v.x) * (pos.x - v.x) + (pos.y - v.y) * (pos.y - v.y))
        if r < radius1 then
          w_choice_weapons_pic_s_flash1.margin = rect1[i]
          w_choice_weapons_pic_l_flash1.margin = rect[i]
          w_choice_weapons_pic_l_flash1.visible = false
          w_choice_weapons_pic_s_flash1.visible = true
          if cur_select ~= i then
            bo2.PlaySound2D(541, false)
          end
          cur_select = i
          break
        end
      end
    end
  elseif msg == ui.mouse_lbutton_down then
    if state == "state_large" then
      for i, v in ipairs(point) do
        local r = math.sqrt((pos.x - v.x) * (pos.x - v.x) + (pos.y - v.y) * (pos.y - v.y))
        if r < radius then
          if cur_select ~= i then
            bo2.PlaySound2D(541, false)
          end
          cur_select = i
          break
        end
      end
      if infos[cur_select] then
        w_choice_weapons_pic_s_flash2.margin = rect1[cur_select]
        w_choice_weapons_pic_l_flash2.margin = rect[cur_select]
        w_choice_weapons_pic_l_flash2.visible = true
        w_choice_weapons_pic_l_flash3.margin = rect[cur_select]
        w_choice_weapons_pic_l_flash3.visible = true
        w_choice_weapons_pic_l_flash3:reset(1, 0, 500)
        bo2.PlaySound2D(538, false)
      end
    else
      for i, v in ipairs(point1) do
        local r = math.sqrt((pos.x - v.x) * (pos.x - v.x) + (pos.y - v.y) * (pos.y - v.y))
        if r < radius1 then
          if cur_select ~= i then
            bo2.PlaySound2D(541, false)
          end
          cur_select = i
          break
        end
      end
      if infos[cur_select] then
        w_choice_weapons_pic_s_flash2.margin = rect1[cur_select]
        w_choice_weapons_pic_l_flash2.margin = rect[cur_select]
        w_choice_weapons_pic_s_flash2.visible = true
        w_choice_weapons_pic_s_flash3.margin = rect1[cur_select]
        w_choice_weapons_pic_s_flash3.visible = true
        w_choice_weapons_pic_s_flash3:reset(1, 0, 500)
        bo2.PlaySound2D(538, false)
      end
    end
    show_weapon(cur_select)
  elseif msg == ui.mouse_enter then
    if state == "state_large" and cur_select then
      w_choice_weapons_pic_l_flash1.visible = true
    elseif state == "state_small" and cur_select then
      w_choice_weapons_pic_s_flash1.visible = true
    end
  elseif msg == ui.mouse_leave then
    cur_select = nil
    w_choice_weapons_pic_l_flash1.visible = false
    w_choice_weapons_pic_s_flash1.visible = false
  end
  if cur_select ~= nil then
    w_choice_weapon_next.visible = true
    w_choice_weapon_back.visible = true
  end
end
function on_move()
  w_choice_weapon_gaomo.dx = w_top.dx
  w_choice_weapon_gaomo.dy = w_top.dy
  if w_top.dx >= 1460 and w_top.dy >= w_top.dx * 9 / 16 then
    w_choice_weapons_pic_s.visible = false
    w_choice_weapons_pic_l.visible = true
    if w_choice_weapons_pic_s_flash1.visible then
      w_choice_weapons_pic_l_flash1.visible = true
      w_choice_weapons_pic_s_flash1.visible = false
    end
    w_choice_weapons_text_l.visible = true
    w_choice_weapons_text_s.visible = false
    if w_choice_weapons_pic_s_flash2.visible == true then
      w_choice_weapons_pic_s_flash2.visible = false
      w_choice_weapons_pic_l_flash2.visible = true
    end
    state = "state_large"
  else
    w_choice_weapons_pic_s.visible = true
    w_choice_weapons_pic_l.visible = false
    if w_choice_weapons_pic_l_flash1.visible then
      w_choice_weapons_pic_l_flash1.visible = false
      w_choice_weapons_pic_s_flash1.visible = true
    end
    w_choice_weapons_text_l.visible = false
    w_choice_weapons_text_s.visible = true
    if w_choice_weapons_pic_l_flash2.visible == true then
      w_choice_weapons_pic_l_flash2.visible = false
      w_choice_weapons_pic_s_flash2.visible = true
    end
    state = "state_small"
  end
  if cur_show == nil then
    w_choice_weapons_pic_l_flash1.visible = false
    w_choice_weapons_pic_s_flash1.visible = false
    w_choice_weapon_info.visible = false
    w_choice_weapon_gaomo.visible = false
    w_choice_weapons_pic_l_flash2.visible = false
    w_choice_weapons_pic_s_flash2.visible = false
  end
end
function on_choice_weapon_device_reset()
end
function enable_buttons(b)
  if b == false then
    w_choice_weapons_pic_s.mouse_able = false
    w_choice_weapons_pic_l.mouse_able = false
    w_choice_weapons_pic_l_flash1.visible = false
    w_choice_weapons_pic_s_flash1.visible = false
    w_choice_weapons_pic_l_flash2.visible = false
    w_choice_weapons_pic_s_flash2.visible = false
    w_choice_weapon_next.enable = false
    w_choice_weapon_next.visible = false
    w_choice_weapon_back.enable = false
    w_choice_weapon_back.visible = false
  else
    w_choice_weapons_pic_s.mouse_able = true
    w_choice_weapons_pic_l.mouse_able = true
    w_choice_weapon_next.enable = true
    w_choice_weapon_next.visible = true
    w_choice_weapon_back.enable = true
    w_choice_weapon_back.visible = true
  end
end
function on_choice_weapon_next(btn, msg, pos)
  if cur_select == 0 then
    ui_tool.note_insert(ui.get_text("phase|choice_weapon"), "FFFF00")
    return
  end
  bo2.PlaySound2D(537, false)
  move_state = "leave"
  w_choice_weapon_timer.suspended = false
  stage_leave = 1
  w_choice_weapon_info:reset(1, 0, 1000)
  enable_buttons(false)
end
function on_choice_weapon_back(btn, msg, pos)
  bo2.PlaySound2D(537, false)
  set_stage(1)
  update_all_state()
  w_scn_view_top.visible = true
  w_cha_panel.visible = true
  enable_buttons(false)
  w_choice_weapon:reset(1, 0, 1000)
end
function show_choice_weapon()
  w_choice_weapon.visible = true
  local rank = ui.mtf_rank_system
  local stk = sys.format([[
<evaluate:3>
<evaluate:3>
<evaluate:2>
<evaluate:4>
<evaluate:2>
<evaluate:2>
]])
  w_choice_weapon_weapons_pic_s_4.margin = init_rect[1]
  w_choice_weapon_weapons_pic_s_3.margin = init_rect[2]
  w_choice_weapon_weapons_pic_s_2.margin = init_rect[3]
  w_choice_weapon_weapons_pic_s_1.margin = init_rect[4]
  w_choice_weapon_weapons_pic_l_4.margin = init_rect[5]
  w_choice_weapon_weapons_pic_l_3.margin = init_rect[6]
  w_choice_weapon_weapons_pic_l_2.margin = init_rect[7]
  w_choice_weapon_weapons_pic_l_1.margin = init_rect[8]
  stage_leave = 0
  enable_buttons(false)
  w_choice_weapon:reset(0, 1, 1000)
end
function on_choice_weapon_stop(con)
  if con.alpha == 0 then
    w_choice_weapon.visible = false
    return
  end
  cur_select = 1
  enable_buttons(true)
  if state == "state_large" then
    on_choice_weapons_mouse(w_choice_weapons_pic_l, ui.mouse_lbutton_down, point[1])
  else
    on_choice_weapons_mouse(w_choice_weapons_pic_s, ui.mouse_lbutton_down, point1[1])
  end
end
function on_choice_weapon_visible(c)
  if c.visible == true then
    w_choice_weapon_gaomo.dx = w_top.dx
    w_choice_weapon_gaomo.dy = w_top.dy
  else
    cur_select = nil
    last_show = nil
    cur_show = nil
    move_state = nil
  end
end
function on_choice_weapon_init()
  init_choice_weapon()
end
