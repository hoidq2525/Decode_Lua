local f_rot_factor = 0.4
local g_view_player
function on_init()
  local obj = bo2.player
  if sys.check(obj) then
    bind_player(obj)
  end
  w_main:search("awt_mz").svar.id = 0
  w_main:search("awt_yf").svar.id = 0
  w_main:search("imprint").svar.id = 0
  w_main:search("ride").svar.id = 0
  w_main:search("pet").svar.id = 0
end
function on_doll_rotl_click(btn)
  local scn = w_scn.scn
  scn:change_angle_x(-f_rot_factor)
end
function on_doll_rotr_click(btn)
  local scn = w_scn.scn
  scn:change_angle_x(f_rot_factor)
end
function bind_player(obj)
  if sys.check(w_scn) ~= true then
    return
  end
  local scn = w_scn.scn
  scn:clear_obj(-1)
  g_view_player = scn:create_obj(bo2.eScnObjKind_Player, obj.excel.id, "playerbegin")
  g_view_player.view_target = obj
end
function on_self_enter(obj, msg)
  bind_player(obj)
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_supermarket.ui_preview.on_self_enter")
function MaySuit(item_excel)
  local slot_id = GetEquipSlot(item_excel.type)
  if slot_id == bo2.eItemSlot_Avatar_Hat or slot_id == bo2.eItemSlot_Avatar_Body or slot_id == bo2.eItemSlot_Avatar_Imprint then
    return true
  end
  local use_excel = bo2.gv_use_list:find(item_excel.use_id)
  if use_excel ~= nil and (use_excel.model == bo2.eUseMod_Ride or use_excel.model == bo2.eUseMod_DirectMall or use_excel.model == bo2.eUseMod_AddPet) then
    return true
  end
  return false
end
function GetEquipSlot(type)
  local n = bo2.gv_item_type:find(type)
  if n ~= nil then
    return n.equip_slot
  end
  return 0
end
function IsWearout(info)
  if info.excel.consume_mode >= bo2.eItemConsumeMod_Wearout0 and info.excel.consume_mode <= bo2.eItemConsumeMod_Wearout2 and info:get_data_32(bo2.eItemUInt32_CurWearout) == 0 then
    return true
  end
  return false
end
function CountEquipInSet(setID)
  local count = 0
  local itemSlot = {}
  for i = bo2.eItemSlot_EquipBeg, bo2.eItemSlot_AvataEnd do
    local info = ui.item_of_coord(bo2.eItemArray_InSlot, i)
    if info ~= nil and IsWearout(info) == false then
      itemSlot[i] = info
    end
  end
  local slot = w_main:search("awt_mz")
  local card = slot:search("card")
  if card.excel_id ~= 0 then
    itemSlot[bo2.eItemSlot_Avatar_Hat] = card.info
  end
  slot = w_main:search("awt_yf")
  card = slot:search("card")
  if card.excel_id ~= 0 then
    itemSlot[bo2.eItemSlot_Avatar_Body] = card.info
  end
  for i = bo2.eItemSlot_EquipBeg, bo2.eItemSlot_AvataEnd do
    if itemSlot[i] ~= nil then
      local equip_excel = bo2.gv_equip_item:find(itemSlot[i].excel_id)
      if equip_excel ~= nil and equip_excel.set == setID then
        count = count + 1
      end
    end
  end
  return count
end
function SetEquipModel(item_excel, slot_id)
  local tmp = {}
  tmp[0] = -1
  tmp[1] = 0
  tmp[2] = -1
  tmp[3] = 0
  tmp[4] = bo2.eEquipData_FuMo_WholeSet
  tmp[5] = 0
  if item_excel ~= nil then
    tmp[1] = item_excel.model
    local setID = item_excel.in_set
    local set = bo2.gv_equip_set:find(setID)
    if set ~= nil then
      local count = CountEquipInSet(setID)
      if count == set.inc_equips.size then
        tmp[5] = set.fumo
      end
    end
  end
  if slot_id == bo2.eItemSlot_MainWeapon then
    tmp[0] = bo2.eEquipData_MainWeapon
    tmp[2] = bo2.eEquipData_FuMo_MainWeapon
  elseif slot_id == bo2.eItemSlot_Hat then
    tmp[0] = bo2.eEquipData_Hat
    tmp[2] = bo2.eEquipData_FuMo_Hat
  elseif slot_id == bo2.eItemSlot_Body then
    tmp[0] = bo2.eEquipData_Body
    tmp[2] = bo2.eEquipData_FuMo_Body
    if tmp[1] == 0 then
      tmp[1] = 1
    end
  elseif slot_id == bo2.eItemSlot_Legs then
    tmp[0] = bo2.eEquipData_Legs
    tmp[2] = bo2.eEquipData_FuMo_Legs
    if tmp[1] == 0 then
      tmp[1] = 1
    end
  elseif slot_id == bo2.eItemSlot_2ndWeapon then
    tmp[0] = bo2.eEquipData_2ndWeapon
    tmp[2] = bo2.eEquipData_FuMo_2ndWeapon
  elseif slot_id == bo2.eItemSlot_Avatar_Imprint then
    tmp[0] = bo2.eEquipData_Imprint
  elseif slot_id == bo2.eItemSlot_Avatar_Hat then
    tmp[0] = bo2.eEquipData_Avatar_Hat
  elseif slot_id == bo2.eItemSlot_Avatar_Body then
    tmp[0] = bo2.eEquipData_Avatar_Body
  end
  for i = 0, 5, 2 do
    if tmp[i] ~= -1 then
      g_view_player:set_view_equip(tmp[i], tmp[i + 1])
    end
  end
end
function setTrySlot(slot, goods_id, item_id)
  local card = slot:search("card")
  if card.excel_id ~= 0 and slot.svar.id ~= goods_id then
    delTryGoods(slot.svar.id)
  end
  slot.svar.id = goods_id
  card.excel_id = item_id
end
function addTryItem(goods_id, item_id)
  local item_excel = ui.item_get_excel(item_id)
  if item_excel == nil then
    return
  end
  if not MaySuit(item_excel) then
    local text = sys.format(ui.get_text("supermarket|preview_fail"), item_excel.name)
    ui_tool.note_insert(text)
    return
  end
  local slot
  local slot_id = GetEquipSlot(item_excel.type)
  if slot_id == bo2.eItemSlot_Avatar_Hat then
    slot = w_main:search("awt_mz")
    setTrySlot(slot, goods_id, item_id)
    SetEquipModel(item_excel, slot_id)
  elseif slot_id == bo2.eItemSlot_Avatar_Body then
    slot = w_main:search("awt_yf")
    setTrySlot(slot, goods_id, item_id)
    SetEquipModel(item_excel, slot_id)
  elseif slot_id == bo2.eItemSlot_Avatar_Imprint then
    slot = w_main:search("imprint")
    setTrySlot(slot, goods_id, item_id)
    SetEquipModel(item_excel, slot_id)
  end
  local use_excel = bo2.gv_use_list:find(item_excel.use_id)
  if use_excel ~= nil then
    if use_excel.model == bo2.eUseMod_Ride then
      slot = w_main:search("ride")
      setTrySlot(slot, goods_id, item_id)
      local ride_id = item_excel.use_par[0]
      local ride_excel = bo2.gv_ride_list:find(ride_id)
      if ride_excel ~= nil then
        local scn = w_scn.scn
        scn:clear_obj(bo2.eScnObjKind_Npc)
        local bus = scn:create_obj(bo2.eScnObjKind_Npc, ride_excel.chaid, "playerbegin")
        if bus ~= nil then
          g_view_player:set_ride(ride_id, bus.sel_handle)
          scn:bind_camera(bus)
        end
      end
    elseif use_excel.model == bo2.eUseMod_DirectMall then
      slot = w_main:search("pet")
      setTrySlot(slot, goods_id, item_id)
      local scn = w_scn.scn
      scn:clear_obj(bo2.eScnObjKind_Pet)
      scn:create_obj(bo2.eScnObjKind_Pet, item_excel.use_par[0], "petbegin")
    elseif use_excel.model == bo2.eUseMod_AddPet then
      slot = w_main:search("pet")
      setTrySlot(slot, goods_id, item_id)
      local pet_id = item_excel.use_par[0]
      local pet_excel = bo2.gv_pet_list:find(pet_id)
      if pet_excel ~= nil then
        local scn = w_scn.scn
        scn:clear_obj(bo2.eScnObjKind_Pet)
        scn:create_obj(bo2.eScnObjKind_Pet, pet_excel.cha_id, "petbegin")
      end
    end
  end
end
function delTryGoods(goods_id)
  local slot = w_main:search("awt_mz")
  local card = slot:search("card")
  if slot.svar.id == goods_id then
    slot.svar.id = 0
    card.excel_id = 0
    SetEquipModel(nil, bo2.eItemSlot_Avatar_Hat)
  end
  slot = w_main:search("awt_yf")
  card = slot:search("card")
  if slot.svar.id == goods_id then
    slot.svar.id = 0
    card.excel_id = 0
    SetEquipModel(nil, bo2.eItemSlot_Avatar_Body)
  end
  slot = w_main:search("imprint")
  card = slot:search("card")
  if slot.svar.id == goods_id then
    slot.svar.id = 0
    card.excel_id = 0
    SetEquipModel(nil, bo2.eItemSlot_Avatar_Imprint)
  end
  slot = w_main:search("ride")
  card = slot:search("card")
  if slot.svar.id == goods_id then
    slot.svar.id = 0
    card.excel_id = 0
    local scn = w_scn.scn
    scn:clear_obj(bo2.eScnObjKind_Npc)
    scn:bind_camera(0)
  end
  slot = w_main:search("pet")
  card = slot:search("card")
  if slot.svar.id == goods_id then
    slot.svar.id = 0
    card.excel_id = 0
    local scn = w_scn.scn
    scn:clear_obj(bo2.eScnObjKind_Pet)
  end
end
function on_card_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_rbutton_click then
    if card.excel_id ~= 0 then
      local slot = card.parent
      local goodsID = slot.svar.id
      delTryGoods(goodsID)
    end
  elseif msg == ui.mouse_lbutton_click and card.excel_id ~= 0 then
    local slot = card.parent
    local goodsID = slot.svar.id
    ui_supermarket.reqBuygoods(goodsID)
  end
end
local g_tmp_goods = {}
local g_tmp_idx = 0
local g_tmp_bjgoods = {}
local g_tmp_bjidx = 0
function insert_to_trolly(goodsID)
  if goodsID < ui_supermarket.BJGOODS_ID_MAX then
    for i = 0, g_tmp_bjidx do
      if g_tmp_bjgoods[i] == goodsID then
        return
      end
    end
    g_tmp_bjidx = g_tmp_bjidx + 1
    g_tmp_bjgoods[g_tmp_bjidx] = goodsID
    local data = ui_supermarket.ui_bjshelf.get_goods_data(goodsID)
    local text = sys.format(ui.get_text("supermarket|trolly_notify_bjgoods"), data:get(packet.key.cmn_name).v_string)
    ui_tool.note_insert(text)
  else
    for i = 0, g_tmp_idx do
      if g_tmp_goods[i] == goodsID then
        return
      end
    end
    g_tmp_idx = g_tmp_idx + 1
    g_tmp_goods[g_tmp_idx] = goodsID
    local data = ui_supermarket.ui_shelf.get_goods_data(goodsID)
    ui_supermarket.ui_trolly.on_insert(data)
  end
end
function on_click_addtotrolly(btn)
  g_tmp_idx = 0
  g_tmp_bjidx = 0
  local slot = w_main:search("awt_mz")
  local card = slot:search("card")
  if card.excel_id ~= 0 then
    local goodsID = slot.svar.id
    insert_to_trolly(goodsID)
  end
  slot = w_main:search("awt_yf")
  card = slot:search("card")
  if card.excel_id ~= 0 then
    local goodsID = slot.svar.id
    insert_to_trolly(goodsID)
  end
  slot = w_main:search("imprint")
  card = slot:search("card")
  if card.excel_id ~= 0 then
    local goodsID = slot.svar.id
    insert_to_trolly(goodsID)
  end
  slot = w_main:search("ride")
  card = slot:search("card")
  if card.excel_id ~= 0 then
    local goodsID = slot.svar.id
    insert_to_trolly(goodsID)
  end
  slot = w_main:search("pet")
  card = slot:search("card")
  if card.excel_id ~= 0 then
    local goodsID = slot.svar.id
    insert_to_trolly(goodsID)
  end
end
function on_click_clear(btn)
  local slot = w_main:search("awt_mz")
  local card = slot:search("card")
  if card.excel_id ~= 0 then
    slot.svar.id = 0
    card.excel_id = 0
    SetEquipModel(nil, bo2.eItemSlot_Avatar_Hat)
  end
  slot = w_main:search("awt_yf")
  card = slot:search("card")
  if card.excel_id ~= 0 then
    slot.svar.id = 0
    card.excel_id = 0
    SetEquipModel(nil, bo2.eItemSlot_Avatar_Body)
  end
  slot = w_main:search("imprint")
  card = slot:search("card")
  if card.excel_id ~= 0 then
    slot.svar.id = 0
    card.excel_id = 0
    SetEquipModel(nil, bo2.eItemSlot_Avatar_Imprint)
  end
  slot = w_main:search("ride")
  card = slot:search("card")
  if card.excel_id ~= 0 then
    slot.svar.id = 0
    card.excel_id = 0
    local scn = w_scn.scn
    scn:clear_obj(bo2.eScnObjKind_Npc)
    scn:bind_camera(0)
  end
  slot = w_main:search("pet")
  card = slot:search("card")
  if card.excel_id ~= 0 then
    slot.svar.id = 0
    card.excel_id = 0
    local scn = w_scn.scn
    scn:clear_obj(bo2.eScnObjKind_Pet)
  end
end
function update_goods()
  local slot = w_main:search("awt_mz")
  local card = slot:search("card")
  local goods_id = slot.svar.id
  if goods_id ~= 0 then
    delTryGoods(goods_id)
    ui_supermarket.addTryGoods(goods_id)
  end
  slot = w_main:search("awt_yf")
  card = slot:search("card")
  goods_id = slot.svar.id
  if goods_id ~= 0 then
    delTryGoods(goods_id)
    ui_supermarket.addTryGoods(goods_id)
  end
  slot = w_main:search("imprint")
  card = slot:search("card")
  goods_id = slot.svar.id
  if goods_id ~= 0 then
    delTryGoods(goods_id)
    ui_supermarket.addTryGoods(goods_id)
  end
  slot = w_main:search("ride")
  card = slot:search("card")
  goods_id = slot.svar.id
  if goods_id ~= 0 then
    delTryGoods(goods_id)
    ui_supermarket.addTryGoods(goods_id)
  end
  slot = w_main:search("pet")
  card = slot:search("card")
  goods_id = slot.svar.id
  if goods_id ~= 0 then
    delTryGoods(goods_id)
    ui_supermarket.addTryGoods(goods_id)
  end
end
