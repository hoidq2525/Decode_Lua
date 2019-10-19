table_stall_item = 1
table_stall_pet = 2
eError_No = 0
eError_General = 1
eError_NoTable = 2
eError_Overstep = 3
eError_NoKey = 4
eError_KeyRepeat = 5
g_Database = {}
g_KeyToIndex = {}
function CreateTable(table_name)
  g_Database[table_name] = {}
  g_KeyToIndex[table_name] = {}
end
function Insert(table_name, data, key)
  if g_Database[table_name] == nil then
    return eError_NoTable
  end
  if key == nil then
    return eError_NoKey
  end
  if g_KeyToIndex[table_name][data[key]] ~= nil then
    return eError_KeyRepeat
  end
  data.key_name = key
  table.insert(g_Database[table_name], data)
  g_KeyToIndex[table_name][data[key]] = table.maxn(g_Database[table_name])
  return table.maxn(g_Database[table_name])
end
function DeleteKeytoIndex(table_name, index)
  local data = g_Database[table_name][index]
  local key = data.key_name
  g_KeyToIndex[table_name][data[key]] = nil
  if index == 0 then
    return
  end
  local i = index + 1
  while g_Database[table_name][i] ~= nil do
    data = g_Database[table_name][i]
    key = data.key_name
    g_KeyToIndex[table_name][data[key]] = i - 1
    i = i + 1
  end
end
function DeleteByIndex(table_name, index)
  if index == nil or index < 0 then
    return eError_General
  end
  if index > table.maxn(g_Database[table_name]) then
    return eError_Overstep
  end
  DeleteKeytoIndex(table_name, index)
  table.remove(g_Database[table_name], index)
end
function PopBack(table_name)
  DeleteByIndex(table_name, table.maxn(g_Database[table_name]))
end
function ClearTable(table_name)
  local size = table.maxn(g_Database[table_name])
  for i = 1, size do
    PopBack(table_name)
  end
end
function DeleteByKey(table_name, key)
  local index = g_KeyToIndex[table_name][key]
  if index == nil then
    return eError_NoKey
  end
  DeleteByIndex(table_name, index)
end
function DeleteTable(table_name)
  ClearTable(table_name)
  g_Database[table_name] = nil
end
function SearchByIndex(table_name, index, item)
  if index == nil then
    return eError_General
  end
  if index > table.maxn(g_Database) then
    return eError_Overstep
  end
  return g_Database[table_name][index][item]
end
function SearchByKey(table_name, key, item)
  local index = g_KeyToIndex[table_name][key]
  if index == nil then
    return eError_NoKey
  end
  return SearchByIndex(table_name, index, item)
end
function UpdataByIndex(table_name, index, item, value)
  if index == nil then
    return eError_General
  end
  if index > table.maxn(g_Database) then
    return eError_Overstep
  end
  g_Database[table_name][index][item] = value
  return g_Database[table_name][index]
end
function UpdataByKey(table_name, key, item, value)
  local index = g_KeyToIndex[table_name][key]
  if index == nil then
    return eError_NoKey
  end
  return UpdataByIndex(table_name, index, item, value)
end
