log_list_limit = 20
log_list = {}
local c_chat_list_uri = SHARED("$frame/deal/deal.xml")
local c_chat_list_style = SHARED("deal_chat_list_item")
local tradeinfo_channel = bo2.eChatChannel_Trade
local logout = function(str)
  local this_box = g_my_log:search("log_box")
  if this_box ~= nil and this_box.svar.log_list_data ~= nil then
    local this_log_list = this_box.svar.log_list_data.this_log_list
    local limit = this_box.svar.log_list_data.limit
    while limit < #this_log_list do
      table.remove(this_log_list, 1)
    end
    ui_im.set_box_no_sel(this_box)
    table.insert(this_log_list, str)
    local rank = ui.mtf_rank_system
    this_box:insert_mtf(str, rank)
  end
  while #log_list > log_list_limit do
    table.remove(log_list, 1)
  end
  table.insert(log_list, str)
end
local function fmt_logout(txt_key, param)
  local fmt = ui.get_text(txt_key)
  local str = sys.mtf_merge(param, fmt)
  local text1 = sys.format("%s", str)
  logout(text1)
end
function on_log_panel(btn, msg, pos, wheel)
end
local cha_name = {}
function log_dealopen(data)
  local id1 = data:get(packet.key.deal_player_1):get(packet.key.cha_onlyid).v_string
  local name1 = data:get(packet.key.deal_player_1):get(packet.key.cha_name).v_string
  local jobid1 = data:get(packet.key.deal_player_1):get(packet.key.player_profession).v_int
  local jobname1 = bo2.gv_profession_list:find(jobid1).name
  local level1 = data:get(packet.key.deal_player_1):get(packet.key.cha_level).v_string
  cha_name[id1] = name1
  local id2 = data:get(packet.key.deal_player_2):get(packet.key.cha_onlyid).v_string
  local name2 = data:get(packet.key.deal_player_2):get(packet.key.cha_name).v_string
  local jobid2 = data:get(packet.key.deal_player_2):get(packet.key.player_profession).v_int
  local jobname2 = bo2.gv_profession_list:find(jobid2).name
  local level2 = data:get(packet.key.deal_player_2):get(packet.key.cha_level).v_string
  cha_name[id2] = name2
  local param = sys.variant()
  param:set("cha1", name1)
  param:set("cha2", name2)
  param:set("chalevel1", level1)
  param:set("chalevel2", level2)
  param:set("chajob1", jobname1)
  param:set("chajob2", jobname2)
  fmt_logout("deal_log|open_fmt", param)
end
function log_dealclose(data)
  local param = sys.variant()
  local cha_id = data:get(packet.key.cha_onlyid).v_string
  ui.console_print(cha_id)
  if cha_id == L("0") then
    fmt_logout("deal_log|sys_close_fmt", param)
  else
    local name = cha_name[cha_id]
    param:set("cha_name", name)
    fmt_logout("deal_log|close_fmt", param)
  end
  cha_name = {}
end
function log_additem(data)
  local cha_id = data:get(packet.key.cha_onlyid).v_string
  local item_id = data:get(packet.key.item_key).v_string
  ui.log(item_id)
  local info = ui.item_of_only_id(item_id)
  if not info then
    return
  end
  if info:is_ridepet() == false then
    local itemid = info.excel_id
    ui.log(itemname)
    local param = sys.variant()
    param:set("cha_name", cha_name[cha_id])
    param:set("item", itemid)
    param:set("code", info.code)
    fmt_logout("deal_log|additem_fmt", param)
  else
    local nListId = info:get_data_32(bo2.eItemUInt32_RidePetListId)
    local nOnlyId = info:get_data_64(bo2.eItemUInt64_RidePetOnlyId)
    local param = sys.variant()
    param:set("cha_name", cha_name[cha_id])
    param:set("code", ui.ride_encode_1(nListId, nOnlyId, cha_name[cha_id]))
    fmt_logout("deal_log|addridepet_fmt", param)
  end
end
function log_removeitem(data)
  local cha_id = data:get(packet.key.cha_onlyid).v_string
  local only_id = data:get(packet.key.item_key).v_string
  local itemid = data:get(packet.key.item_excelid).v_int
  local info = ui.item_of_only_id(only_id)
  if not info then
    return
  end
  if info:is_ridepet() == false then
    local param = sys.variant()
    param:set("cha_name", cha_name[cha_id])
    param:set("item", info.excel_id)
    param:set("code", info.code)
    local noitem = data:has(packet.key.deal_no_item)
    if noitem == true then
      fmt_logout("deal_log|remove_noitem", param)
    else
      fmt_logout("deal_log|removeitem_fmt", param)
    end
  else
    local nListId = info:get_data_32(bo2.eItemUInt32_RidePetListId)
    local nOnlyId = info:get_data_64(bo2.eItemUInt64_RidePetOnlyId)
    local param = sys.variant()
    param:set("cha_name", cha_name[cha_id])
    param:set("code", ui.ride_encode_1(nListId, info, nOnlyId, cha_name[cha_id]))
    fmt_logout("deal_log|removeridepet_fmt", param)
  end
end
local function log_player_setlock(cha_id, locked)
  local param = sys.variant()
  param:set("cha_name", cha_name[cha_id])
  if locked then
    fmt_logout("deal_log|player_lock_fmt", param)
  else
    fmt_logout("deal_log|player_unlock_fmt", param)
  end
end
local function log_system_setlock(locked)
  local param = sys.variant()
  if locked then
    fmt_logout("deal_log|sys_lock_fmt", param)
  else
    fmt_logout("deal_log|sys_unlock_fmt", param)
  end
end
function log_setlock(data)
  local cha_id = data:get(packet.key.cha_onlyid).v_string
  local locked = data:get(packet.key.deal_lock).v_int ~= 0
  if cha_id ~= L("") then
    log_player_setlock(cha_id, locked)
  else
    log_system_setlock(locked)
  end
end
function log_setmoney(data)
  local cha_id = data:get(packet.key.cha_onlyid).v_string
  local money = data:get(packet.key.deal_money).v_int
  if money ~= 0 then
    local param = sys.variant()
    param:set("cha_name", cha_name[cha_id])
    param:set("money", money)
    fmt_logout("deal_log|set_money_fmt", param)
  end
end
function log_set_execute(data)
  local cha_id = data:get(packet.key.cha_onlyid).v_string
  local param = sys.variant()
  param:set("cha_name", cha_name[cha_id])
  fmt_logout("deal_log|execute_fmt", param)
end
