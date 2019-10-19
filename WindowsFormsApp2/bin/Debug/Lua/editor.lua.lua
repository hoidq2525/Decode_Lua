local m_edit_data = {}
local block_bound = 8
local get_target = function(blockctrl)
  local name = tostring(blockctrl.name)
  local block_define = m_block_def[name]
  if not block_define then
    return
  end
  return sys.get(block_define.target)
end
local make_target_editable = function(block_ctrl, target)
  local data = {
    target_ctrl = target,
    target_dock = target.dock,
    target_margin = target.margin,
    target_area = target.area
  }
  target.dock = L("none")
  target.margin = ui.rect()
  return data
end
function on_block_visible(ctrl, v)
  if not v then
    return
  end
  local target = get_target(ctrl)
  if not target then
    return
  end
  local data = make_target_editable(ctrl, target)
  local src_area = target.area
  local dest_area = ui.rect(src_area.x1 - block_bound, src_area.y1 - block_bound, src_area.x2 + block_bound, src_area.y2 + block_bound)
  ctrl.area = dest_area
  data.block_area = dest_area
  m_edit_data[ctrl] = data
end
function on_block_move(ctrl, area)
  if not m_edit_data[ctrl] then
    return
  end
  local target = get_target(ctrl)
  if not target then
    return
  end
  local pos = ui.point(area.x1 + block_bound, area.y1 + block_bound)
  target.offset = pos
end
function on_click_revert()
  for ctrl, data in pairs(m_edit_data) do
    ctrl.area = data.block_area
  end
end
function on_init(ctrl)
  ctrl.area = ctrl.parent.area
end
function test_toggle()
  m_main_frame.visible = not m_main_frame.visible
end
