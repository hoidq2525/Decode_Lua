local reg = ui_packet.game_recv_signal_insert
local sig = "ui_knight.packet_handler"
function get_empty_card(all_cards)
  for i, v in ipairs(all_cards) do
    local card = v:search("card")
    if card.only_id == L("0") then
      return card, i
    end
  end
end
function get_the_card(all_cards, key)
  for i, v in ipairs(all_cards) do
    local card = v:search("card")
    if card ~= nil and card.only_id ~= L("0") and card.only_id == key then
      return card
    end
  end
end
function handle_k_additem(cmd, data)
  local key = data:get(packet.key.item_key).v_string
  local cnt = data:get(packet.key.item_count).v_int
  local box = data:get(packet.key.item_box).v_int
  if data:has(packet.key.itemdata_all) then
    local key = data:get(packet.key.item_key).v_string
    ui.item_insert(key, data:get(packet.key.itemdata_all))
    local card = get_empty_card(g_items_challenge.cards)
    if card ~= nil then
      card.only_id = key
    end
    local info = ui.item_of_only_id(key)
    if info ~= nil then
      show_points_and_rate(info, 1)
    end
  end
end
function handle_k_removeitem(cmd, data)
  local key = data:get(packet.key.item_key).v_string
  local cnt = data:get(packet.key.item_count).v_int
  local card = get_the_card(g_items_challenge.cards, key)
  if card ~= nil and card.info then
    local info = ui.item_of_only_id(key)
    if info ~= nil then
      show_points_and_rate(info, -1)
    end
    ui.item_remove(key)
    card.only_id = 0
  end
end
function handle_k_openui(cmd, data)
  local npcid = data:get(packet.key.knight_pk_npc_cha_id).v_int
  local line = bo2.gv_cha_list:find(npcid)
  if line == nil then
    return
  end
  local level = 0
  if data:has(packet.key.knight_rand_level) then
    level = data:get(packet.key.knight_rand_level).v_int
  end
  if record_npc(npcid, level) == false then
    return
  end
  set_visible(true)
end
function handle_k_randnpc(cmd, data)
  local npcid = data:get(packet.key.knight_pk_npc_cha_id).v_int
  local line = bo2.gv_cha_list:find(npcid)
  if line == nil then
    return
  end
  if record_rand_npc(data) == false then
    return
  end
  set_visible(false)
  set_rand_visible(true)
end
function handle_k_buypoint(cmd, data)
  local cnt = data:get(packet.key.cmn_val).v_int
  show_points_and_rate(info, -1, cnt)
end
function handle_k_sendGCD(cmd, data)
  local npcid = data:get(packet.key.knight_pk_npc_cha_id).v_int
  local line = bo2.gv_cha_list:find(npcid)
  if line == nil then
    return
  end
  local cdDatas = data:get(packet.key.ui_cd_view_arr_data)
  local size = cdDatas.size
  if size == 0 then
    return
  end
  for i = 0, size - 1 do
    local level = cdDatas:get(i):get(packet.key.cmn_index).v_int
    local cd = cdDatas:get(i):get(packet.key.ui_cd_view_id).v_int
    local cdvalue = true
    if cd == 1 then
      cdvalue = true
    elseif cd == 0 then
      cdvalue = false
    end
    set_GCD_value(level, cdvalue)
  end
  after_points_fixed()
end
function handle_k_LevelDown(cmd, data)
  local npcid = data:get(packet.key.knight_pk_npc_cha_id).v_int
  local line = bo2.gv_cha_list:find(npcid)
  if line == nil then
    return
  end
  if data:has(packet.key.knight_rand_level) then
    level = data:get(packet.key.knight_rand_level).v_int
  end
  if record_npc(npcid, level) == false then
    return
  end
  set_visible(true)
end
function handle_k_ShowResult(cmd, data)
  local result = data:get(packet.key.cmn_id).v_int
  ui_match.cmn_show_result(result)
end
reg(packet.eSTC_UI_Knight_OpenItemUI, handle_k_openui, sig)
reg(packet.eSTC_UI_Knight_AddItem, handle_k_additem, sig)
reg(packet.eSTC_UI_Knight_RemoveItem, handle_k_removeitem, sig)
reg(packet.eSTC_UI_Knight_RandNpc, handle_k_randnpc, sig)
reg(packet.eSTC_UI_Knight_BuyPoint, handle_k_buypoint, sig)
reg(packet.eSTC_UI_Knight_SendGCD, handle_k_sendGCD, sig)
reg(packet.eSTC_UI_Knight_LevelDown, handle_k_LevelDown, sig)
reg(packet.eSTC_UI_Knight_ShowResult, handle_k_ShowResult, sig)
