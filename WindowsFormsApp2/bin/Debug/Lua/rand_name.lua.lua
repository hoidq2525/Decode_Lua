math.randomseed(os.time())
local tab_player_name = sys.load_table("$mb/etc/player_name.xml")
local tab_name_combo = sys.load_table("$mb/etc/player_name_combo.xml")
function rand_name_combo()
  local tab_combo_size = tab_name_combo.size
  local num = math.random(1, 100)
  local tab_ratio = {}
  tab_ratio[-1] = 0
  for i = 0, tab_combo_size - 1 do
    local ratio = tab_name_combo:get(i).ratio
    tab_ratio[i] = tab_ratio[i - 1] + ratio
    if num <= tab_ratio[i] then
      return i
    end
  end
  return -1
end
function rand_char(name_type)
  local tab_size = tab_player_name.size
  local character
  while character == nil or character == L("") do
    local name_line_idx = math.random(0, tab_size - 1)
    local name_line = tab_player_name:get(name_line_idx)
    local name_key = tostring(name_type)
    if name_key ~= "family_name" then
      if build_info.sex == bo2.eSex_Male then
        name_key = "male_" .. name_key
      elseif build_info.sex == bo2.eSex_Female then
        name_key = "fem_" .. name_key
      end
    end
    character = name_line[name_key]
  end
  return character
end
function on_rand_name_click(btn)
  bo2.PlaySound2D(537, false)
  local combo_idx = rand_name_combo()
  if combo_idx == -1 then
    ui.log("player_name_combo.txt\229\161\171\232\161\168\233\148\153\232\175\175\239\188\140\232\175\183\228\187\148\231\187\134\230\160\184\230\159\165")
    return
  end
  local combo_array = tab_name_combo:get(combo_idx).combo
  local player_name, rst
  repeat
    player_name = nil
    for i = 0, combo_array.size - 1 do
      local name_type = combo_array[i]
      player_name = player_name .. rand_char(name_type)
    end
    rst = ui.check_name(player_name)
  until rst == bo2.eNameCheck_ErrNone
  w_build_input_name.text = player_name
end
