local excel
local remain_time = 1
local base_path = "$icon/map/scn_anim/test/"
local pic_info = {}
local pic_speed_list = {}
local pic_excel
local PIC_SIZE = 512
function on_move(c)
  scale_x = ui_phase.ui_tool.w_top.dx / 1024
  scale_y = ui_phase.ui_tool.w_top.dy / 768
  if scale_x >= scale_y then
    scale = scale_x
  end
  if scale_x < scale_y then
    scale = scale_y
  end
  w_pic.dx = 2048 * scale
  w_pic.dy = 1536 * scale
end
function pic_timer(timer)
  local offset_x = math.abs(pic_info.cur_x - 512)
  local offset_y = math.abs(pic_info.cur_y - 512)
  w_pic.offset = ui.point(-math.floor(offset_x + pic_speed_list[pic_info.speed_id].x), -math.floor(offset_y + pic_speed_list[pic_info.speed_id].y))
  pic_info.cur_x = pic_info.cur_x + pic_speed_list[pic_info.speed_id].x
  pic_info.cur_y = pic_info.cur_y + pic_speed_list[pic_info.speed_id].y
  local x_ok = false
  local y_ok = false
  if x_ok == false and pic_speed_list[pic_info.speed_id].x >= 0 then
    if pic_info.cur_x >= pic_speed_list[pic_info.speed_id].pos_x then
      x_ok = true
    end
  elseif x_ok == false and pic_speed_list[pic_info.speed_id].x < 0 and pic_info.cur_x <= pic_speed_list[pic_info.speed_id].pos_x then
    x_ok = true
  end
  if y_ok == false and pic_speed_list[pic_info.speed_id].y >= 0 then
    if pic_info.cur_y >= pic_speed_list[pic_info.speed_id].pos_y then
      y_ok = true
    end
  elseif y_ok == false and pic_speed_list[pic_info.speed_id].y < 0 and pic_info.cur_y <= pic_speed_list[pic_info.speed_id].pos_y then
    y_ok = true
  end
  if x_ok then
    pic_speed_list[pic_info.speed_id].x = 0
  end
  if y_ok then
    pic_speed_list[pic_info.speed_id].y = 0
  end
  if x_ok and y_ok then
    pic_info.speed_id = pic_info.speed_id + 1
    if pic_speed_list[pic_info.speed_id] == nil then
      w_pic_timer.suspended = true
    end
  end
end
function text_timer(timer)
end
function update_pic(x, y)
  scale_x = ui_phase.ui_tool.w_top.dx / 1024
  scale_y = ui_phase.ui_tool.w_top.dy / 768
  if scale_x >= scale_y then
    scale = scale_x
  end
  if scale_x < scale_y then
    scale = scale_y
  end
  w_pic.dx = pic_excel.size_x * PIC_SIZE * scale
  w_pic.dy = pic_excel.size_x * PIC_SIZE * scale
  ui.log("%s %s", ui_phase.ui_tool.w_top.dx, ui_phase.ui_tool.w_top.dx)
  ui.log("dx %s dy %s", w_pic.dx, w_pic.dy)
  ui.log("start update_pic %s %s", os.date(), os.clock())
  for i = 0, 2 do
    for j = 0, 3 do
      local image_path = base_path .. pic_excel.pic .. i .. j .. ".png"
      ui.log("%s", image_path)
      if sys.is_file(image_path) == true then
        w_backcloth:set_item(j, i, image_path)
      end
    end
  end
  ui.log("end update_pic %s %s", os.date(), os.clock())
end
function show_pic(excel)
  ui.log("show_pic %s", excel.id)
  local function init_pic_speed_list()
    for i = 0, excel.speed.size, 2 do
      table.insert(pic_speed_list, {
        x = excel.speed[i],
        y = excel.speed[i + 1],
        pos_x = excel.speed_pos[i],
        pos_y = excel.speed_pos[i + 1]
      })
    end
  end
  local x = excel.pos_start[0]
  local y = excel.pos_start[1]
  update_pic(x, y)
  init_pic_speed_list()
  pic_info.speed_id = 1
  pic_info.cur_x = excel.pos_start[0]
  pic_info.cur_y = excel.pos_start[0]
  local m_x = excel.size_x / 2
  local m_y = excel.size_y / 2
  local offset_x = m_x - pic_info.cur_x
  local offset_y = m_y - pic_info.cur_y
  ui.log("offset_x %s offset_y %s", offset_x, offset_y)
  w_pic_timer.suspended = false
  w_pic:reset(0, 1, 1000)
  w_pic.visible = true
end
function show_text(excel)
end
function total_timer(timer)
  for i = 0, excel.pic_id.size - 1 do
    pic_excel = bo2.gv_scn_pic_list:find(excel.pic_id[i])
    if pic_excel == nil then
      ui.log("scn_pic_list is nil id = %s", excel.pic_id[i])
    elseif remain_time == excel.pic_time[i] * 1000 then
      show_pic(pic_excel)
    end
  end
  for i = 0, excel.text_id.size - 1 do
    local text_excel = bo2.gv_scn_text_list:find(excel.text_id[i])
    if text_excel == nil then
      ui.log("scn_text_list is nil id = %s", excel.text_id[i])
    elseif remain_time == excel.text_time[i] * 1000 then
      show_text(text_excel)
    end
  end
  remain_time = remain_time + 1000
end
function set_on_anims(id)
  ui.log("set_on_anims %s %s", os.date(), os.clock())
  excel = bo2.gv_scn_pic_anims:find(id)
  if excel == nil then
    return
  end
  if excel.total_time <= 0 then
    return
  else
    w_total_timer.suspended = false
    w_total_timer.span = excel.total_time * 1000
    ui_phase.ui_startup.show_top(false)
  end
  if excel.pic_id.size == 0 then
    ui.log("pics is empty")
    return
  else
  end
  if excel.text_id.size ~= 0 then
    w_text_timer.period = excel.text_time
  end
  if excel.pic_time[0] == 0 then
    ui.log("pic_id %s", excel.pic_id[0])
    pic_excel = bo2.gv_scn_pic_list:find(excel.pic_id[0])
    show_pic(pic_excel)
  end
  w_top.visible = true
end
function on_init()
end
