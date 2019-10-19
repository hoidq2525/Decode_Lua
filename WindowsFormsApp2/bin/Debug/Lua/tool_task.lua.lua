c_task_result_tick = 0
c_task_result_finish_item = 1
c_task_result_finish_task = 2
c_task_result_failed = -1
local g_tasks = rawget(_M, "g_task_all_datas")
if g_tasks == nil then
  g_tasks = {}
  rawset(_M, "g_task_all_datas", g_tasks)
end
local function task_check_timer()
  local cnt = #g_tasks
  if cnt == 0 then
    g_task_timer.suspended = true
  else
    g_task_timer.suspended = false
  end
end
local task_invoke = function(item, name)
  local f = item[name]
  if f == nil then
    return false
  end
  sys.pcall(f, item)
  return true
end
local function task_stop(task, result, index)
  local items = task.items
  if index == nil then
    index = #items
  end
  if task.index > 0 then
    local item = items[task.index]
    if not item.on_leave_invoked then
      task_invoke(item, "on_leave")
    end
  end
  for i = index, 1, -1 do
    local v = items[i]
    v.result = 0
    if result == c_task_result_failed and i <= task.index and task.rollback_abort == nil then
      task_invoke(v, "on_rollback")
    end
    task_invoke(v, "on_remove")
  end
  if task.state == -1 then
    return
  end
  if result == c_task_result_finish_task then
    task.state = 1
    task.cycle_index = task.cycle_index + 1
  else
    task.state = -1
  end
end
function task_tick(task)
  local items = task.items
  local size = #items
  while true do
    local state = task.state
    if state == 1 or state == -1 then
      break
    elseif state == 2 then
      if task.suspended then
        break
      end
      task.suspended = true
      if task.index > 0 then
        local item = items[task.index]
        if item.result == c_task_result_tick then
          task_invoke(item, "on_suspend")
        end
      end
      break
    elseif state == 3 then
      task.state = 0
      if task.index > 0 and task.suspended then
        local item = items[task.index]
        if item.result == c_task_result_tick then
          task_invoke(item, "on_resume")
        end
      end
    end
    if task.index > 0 then
      local item = items[task.index]
      local result = item.result
      if result == c_task_result_tick then
        if task_invoke(item, "on_tick") then
          result = item.result
          if result == c_task_result_tick then
            return
          end
        else
          result = c_task_result_finish_item
          item.result = c_task_result_finish_item
        end
      end
      if result == c_task_result_finish_item then
        if task_invoke(item, "on_leave") then
          item.on_leave_invoked = true
          local result = item.result
          if result == c_task_result_finish_task then
            task_cycle_next(task)
            return
          elseif result == c_task_result_failed then
            task_stop(task, result)
            return
          end
        end
      elseif result == c_task_result_finish_task or result == c_task_result_failed then
        task_stop(task, result)
        return
      end
    end
    if size <= task.index then
      task_stop(task, c_task_result_finish_task)
      return
    end
    task.index = task.index + 1
    local item = items[task.index]
    if task_invoke(item, "on_enter") then
      local result = item.result
      if result == c_task_result_tick then
        return
      elseif result == c_task_result_finish_task or result == c_task_result_failed then
        task_stop(task, result)
        return
      end
    end
  end
end
function on_task_timer(timer)
  local tasks = {}
  for i, v in ipairs(g_tasks) do
    table.insert(tasks, v)
  end
  for i, v in ipairs(tasks) do
    task_tick(v)
  end
  local idx = 1
  local cnt = #g_tasks
  tasks = {}
  while idx <= cnt do
    local t = g_tasks[idx]
    if t == nil then
      break
    end
    if t.state == -1 then
      table.remove(g_tasks, idx)
    elseif t.state == 1 then
      table.remove(g_tasks, idx)
      if t.cycle_count < 0 or t.cycle_index < t.cycle_count then
        table.insert(tasks, t)
      end
    else
      idx = idx + 1
    end
  end
  for i, v in ipairs(tasks) do
    task_insert(v)
  end
  task_check_timer()
end
function task_insert(task)
  local items = task.items
  if items == nil then
    ui.log("task items is empty")
    return
  end
  local count = #items
  if count < 1 then
    ui.log("task items is empty")
    return
  end
  if task.cycle_index == nil then
    task.cycle_index = 0
  end
  if task.cycle_count == nil or task.cycle_count == 0 then
    task.cycle_count = 1
  end
  task.index = 0
  task.state = 0
  task.suspended = false
  table.insert(g_tasks, task)
  task_check_timer()
  local index = 1
  for i, v in ipairs(items) do
    v.owner = task
    v.on_leave_invoked = false
    v.result = c_task_result_tick
    if task_invoke(v, "on_insert") then
      local result = v.result
      if result == c_task_result_finish_task or result == c_task_result_failed then
        task_stop(task, result, index)
        break
      end
    end
  end
end
function task_remove(task)
  if task.state == -1 then
    return
  end
  task_stop(task, c_task_result_finish_task)
  task.state = -1
end
function task_suspend(task)
  if task.state == 0 then
    task.state = 2
    task.suspended = false
    return
  end
  if task.state == 3 then
    task.state = 2
    return
  end
end
function task_resume(task)
  if task.state == 2 then
    if task.suspended then
      task.state = 3
    else
      task.state = 0
    end
  end
end
function on_task_init()
  task_check_timer()
end
