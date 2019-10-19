lock_item = {}
lock_count = 0
lock_item_m = {}
local text_tip = L("")
local notraits_warning = ui.get_text("remake|notraits_warning")
local notfinish_warning = ui.get_text("remake|notfinish_warning")
local rclick_to_inslot = ui.get_text("remake|rclick_to_inslot")
local cannot_warning = ui.get_text("remake|cannot_warning")
local click_to_unlock = ui.get_text("remake|click_to_unlock")
local click_to_lock = ui.get_text("remake|click_to_lock")
local notover_warning1 = ui.get_text("remake|notover_warning1")
local notover_warning2 = ui.get_text("remake|notover_warning2")
local notover_warning3 = ui.get_text("remake|notover_warning3")
local most_three_warning = ui.get_text("remake|most_three_warning")
local bound_warnings = ui.get_text("remake|bound_warnings")
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  w_pro_list:item_clear()
  local card = w_cell_lock:search("card")
  card.require_count = 0
end
function item_rbutton_tip(info)
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  local ptype = excel.ptype
  if ptype == nil then
    return nil
  end
  if sys.is_type(excel, ui_tool.cs_tip_mb_data_equip_item) and excel.disable_remake > 0 then
    return cannot_warning
  end
  if ptype.equip_slot >= bo2.eItemSlot_EquipBeg and ptype.equip_slot <= bo2.eItemSlot_EquipEnd then
    local star = info:get_data_8(bo2.eItemByte_Star)
    if star == 0 then
      return notraits_warning
    end
    if info:identify_finished() == false then
      return notfinish_warning
    end
    return rclick_to_inslot
  elseif ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
    local star = info:get_data_8(bo2.eItemByte_Star)
    if star == 0 then
      return notraits_warning
    end
    if info:identify_finished() == false then
      return notfinish_warning
    end
    return rclick_to_inslot
  else
    return cannot_warning
  end
end
function on_item_count_remake()
  w_btn_remake.enable = check_if_can_remake()
end
function on_item_count_lock()
  w_btn_remake.enable = check_if_can_remake()
end
function item_rbutton_check(info)
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  return true
end
function on_lock_btn_tip(tip)
  local owner = tip.owner
  local rank_score = owner.svar.gs
  local rank_score_text = L("")
  if rank_score ~= 0 then
    local v = sys.variant()
    v:set("score", math.floor(rank_score))
    rank_score_text = sys.mtf_merge(v, ui.get_text("remake|cur_property_score"))
  end
  local ctrl = owner:search(L("lock_check"))
  if ctrl.check then
    text_tip = rank_score_text .. click_to_unlock
  else
    text_tip = rank_score_text .. click_to_lock
  end
  ui_widget.tip_make_view(tip.view, text_tip)
end
function on_mouse_lock_pro(ctrl, msg, pos, wheel)
  local item = ctrl.parent.parent.parent
  local hover = item:search("hover")
  if msg == ui.mouse_enter or msg == ui.mouse_inner then
    if not ctrl.check then
      hover.visible = true
    else
      hover.visible = false
    end
  elseif msg == ui.mouse_leave or msg == ui.mouse_outer then
    hover.visible = false
  end
end
function set_lock_cell()
  local c = w_cell_lock:search("card")
  local info = w_cell_equip:search("card").info
  local excel = info.excel
  local reqlevel = excel.reqlevel
  local lock_count = 0
  for item, v in ipairs(lock_item) do
    if v.check then
      lock_count = lock_count + 1
    end
  end
  local req_count = 0
  local item_id = 0
  for i = 0, bo2.gv_lock_variety.size - 1 do
    local excel = bo2.gv_lock_variety:get(i)
    if excel ~= nil and reqlevel <= excel.level then
      req_count = excel.count[lock_count]
      for i1 = 0, excel.lock_item.size - 1 do
        local count = ui.item_get_count(excel.lock_item[i1], true)
        if req_count <= count then
          item_id = excel.lock_item[i1]
          break
        end
      end
      if item_id == 0 then
        item_id = excel.lock_item[0]
      end
      break
    end
  end
  ui_npcfunc.ui_cell.set(c.parent.parent, item_id, req_count)
  local l_item = w_cell_lock:search("card")
  local goods_id = ui_supermarket2.shelf_quick_buy_id(l_item.excel_id)
  ui_npcfunc.ui_remake.w_quick_buy_lock.visible = goods_id ~= 0
end
function set_remake_cell()
  local c = w_cell_remake:search("card")
  local info = w_cell_equip:search("card").info
  local excel = info.excel
  local reqlevel = excel.reqlevel
  local star = info:get_data_8(bo2.eItemByte_Star)
  local req_count = 0
  local item_id = 0
  for i = 0, bo2.gv_remake_variety.size - 1 do
    local excel = bo2.gv_remake_variety:get(i)
    if excel ~= nil and reqlevel <= excel.level then
      req_count = excel.count[star]
      for i1 = 0, excel.remake_item.size - 1 do
        local count = ui.item_get_count(excel.remake_item[i1], true)
        if req_count <= count then
          item_id = excel.remake_item[i1]
          break
        end
      end
      if item_id == 0 then
        item_id = excel.remake_item[0]
      end
      break
    end
  end
  ui_npcfunc.ui_cell.set(c.parent.parent, item_id, req_count)
  local r_item = w_cell_remake:search("card")
  local goods_id = ui_supermarket2.shelf_quick_buy_id(r_item.excel_id)
  ui_npcfunc.ui_remake.w_quick_buy_remake.visible = goods_id ~= 0
end
function set_money()
  local money = 0
  local c1 = w_cell_lock:search("card")
  local info = w_cell_equip:search("card").info
  local excel = info.excel
  local reqlevel = excel.reqlevel
  local star = info:get_data_8(bo2.eItemByte_Star)
  local lock_count = 0
  for item, v in ipairs(lock_item) do
    if v.check then
      lock_count = lock_count + 1
    end
  end
  for i = 0, bo2.gv_remake_variety.size - 1 do
    local excel = bo2.gv_remake_variety:get(i)
    if excel ~= nil and reqlevel <= excel.level then
      money = money + excel.money[star]
      break
    end
  end
  local lock_money = 0
  for j = 0, bo2.gv_lock_variety.size - 1 do
    local excel = bo2.gv_lock_variety:get(j)
    if excel ~= nil and reqlevel <= excel.level then
      lock_money = lock_money + excel.money[lock_count]
      break
    end
  end
  local first_remake = info:get_data_8(bo2.eItemByte_FirstRemake)
  if first_remake == 0 then
    money = 0
  end
  money = money + lock_money
  ui_npcfunc.ui_cmn.money_set(w_money, money)
end
function item_rbutton_use(info)
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  local ptype = excel.ptype
  if ptype == nil then
    return nil
  end
  if not m_timer_remake.suspended then
    return nil
  end
  if sys.is_type(excel, ui_tool.cs_tip_mb_data_equip_item) and excel.disable_remake > 0 then
    ui_tool.note_insert(cannot_warning, L("FF00FF00"))
    return nil
  end
  local star = info:get_data_8(bo2.eItemByte_Star)
  if star == 0 then
    ui_tool.note_insert(cannot_warning, L("FF00FF00"))
    return nil
  end
  if (ptype.equip_slot < bo2.eItemSlot_EquipBeg or ptype.equip_slot > bo2.eItemSlot_EquipEnd) and ptype.equip_slot ~= bo2.eItemSlot_RidePetWeapon then
    ui_tool.note_insert(cannot_warning, L("FF00FF00"))
    return
  end
  local bound = info:get_data_8(bo2.eItemByte_Bound)
  if bound == 0 then
    ui_tool.note_insert(bound_warnings, L("FF00FF00"))
    return
  end
  if info:identify_finished() == false then
    ui_tool.note_insert(notfinish_warning, L("FF00FF00"))
    return
  end
  ui_npcfunc.ui_cell.drop(w_cell_equip, info)
  load_property(info)
  w_btn_back.visible = false
  set_remake_cell()
  set_lock_cell()
  set_money()
  local can_remake = check_if_can_remake()
  w_btn_remake.enable = can_remake
  if ptype.id == bo2.eItemtype_ReMake then
  end
  if ptype.id == bo2.eItemtype_Lock then
  end
end
function load_property(info)
  w_pro_list:item_clear()
  local excel = info.excel
  local star = info:get_data_8(bo2.eItemByte_Star)
  local star = info:get_data_8(bo2.eItemByte_Star)
  if star <= 0 then
    return
  end
  local build_packet = {}
  local upgrade_data = ui_tool.get_equip_upgrade_data(info, excel)
  local new_build_packet
  if upgrade_data ~= nil then
    new_build_packet = upgrade_data.trait_packet
    build_packet = upgrade_data.build_packet
  else
    build_packet = ui_tool.get_trait_color_packet(excel, star)
  end
  local card = w_cell_lock:search("card")
  card.require_count = 0
  lock_item = {}
  local get_gs_score = function(id, value)
    local excel = {}
    excel[id] = value
    local gs = ui_tool.ctip_calculate_item_rank(excel, nil, 2)
    return gs
  end
  local function add_trait_by_id(id)
    local trait = bo2.gv_trait_list:find(id)
    if trait == nil then
      return
    end
    local desc = trait.desc
    if desc.size > 0 then
      add_property(desc)
    else
      local lastMod = 0
      local lastVal = 0
      lastMod = trait.modify_id
      lastVal = trait.modify_value
      if new_build_packet ~= nil then
        lastMod, lastVal, trait_id = ui_tool.get_trait_upgrade(build_packet, new_build_packet, lastMod, lastVal)
      end
      local ex = ui_tool.ctip_trait_text_ex(lastMod, lastVal)
      local color = ui_tool.get_trait_color(build_packet, trait.modify_id, trait.modify_value)
      local score = get_gs_score(lastMod, lastVal)
      add_property(ex, color, score)
    end
  end
  for i = bo2.eItemUInt32_IdentTraitBeg, bo2.eItemUInt32_IdentTraitEnd - 1 do
    local id = info:get_data_32(i)
    if id > 0 then
      add_trait_by_id(id)
    end
  end
  if parent_item ~= nil then
    for i, v in ipairs(lock_item) do
      if v.index == parent_item.index and v.check == btn.check then
        return
      end
    end
    table.insert(lock_item, {
      index = parent_item.index,
      check = btn.check
    })
  end
end
function content_clean()
  local c1 = w_equip_slot:search("equip_affix")
  ui_npcfunc.ui_cell.clear(c1)
  local c2 = w_remake_affix:search("remake_affix")
  ui_npcfunc.ui_cell.clear(c2)
  ui_npcfunc.ui_remake.w_quick_buy_remake.visible = false
  local c3 = w_lock_affix:search("lock_affix")
  if c3 ~= nil then
    ui_npcfunc.ui_cell.clear(c3)
    ui_npcfunc.ui_remake.w_quick_buy_lock.visible = false
  end
  w_pro_list:item_clear()
  local card = w_cell_lock:search("card")
  card.require_count = 0
  w_btn_remake.enable = false
  w_btn_back.visible = false
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
end
function is_in_bag(info)
  if info.box >= bo2.eItemBox_BagBeg and info.box < bo2.eItemBox_BagEnd then
    return true
  end
  return false
end
function is_equip_item(info)
  local excel = info.excel
  if sys.is_type(excel, ui_tool.cs_tip_mb_data_equip_item) and excel.disable_remake > 0 then
    return false
  end
  local ptype = excel.ptype
  if ptype.equip_slot >= bo2.eItemSlot_EquipBeg and ptype.equip_slot <= bo2.eItemSlot_EquipEnd then
    return true
  end
  if ptype.equip_slot >= bo2.eItemSlot_RidePetBegin and ptype.equip_slot <= bo2.eItemSlot_RidePetEnd then
    return true
  end
  return false
end
function on_drop(pn, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  ui.clean_drop()
  if not ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    return
  end
  if not m_timer_remake.suspended then
    return
  end
  local info = ui.item_of_only_id(data:get("only_id"))
  if is_in_bag(info) == false then
    return
  end
  if is_equip_item(info) == false then
    ui_tool.note_insert(cannot_warning, L("FF00FF00"))
    return
  end
  local bound = info:get_data_8(bo2.eItemByte_Bound)
  if bound == 0 then
    ui_tool.note_insert(bound_warnings, L("FF00FF00"))
    return
  end
  local star = info:get_data_8(bo2.eItemByte_Star)
  if star == 0 then
    ui_tool.note_insert(cannot_warning, L("FF00FF00"))
    return
  end
  if info:identify_finished() == false then
    ui_tool.note_insert(notfinish_warning, L("FF00FF00"))
    return
  end
  ui_npcfunc.ui_cell.drop(pn, info)
  load_property(info)
  w_btn_back.visible = false
  local can_remake = check_if_can_remake()
  w_btn_remake.enable = can_remake
  set_remake_cell()
  set_lock_cell()
  set_money()
end
function on_card_mouse(card, msg, pos, wheel)
  local icon = card.icon
  if icon == nil then
    return
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_drag then
    ui.set_cursor_icon(icon.uri)
    local function on_drop_hook(w, msg, pos, data)
      if msg == ui.mouse_drop_clean then
        if not m_timer_remake.suspended then
          ui_tool.note_insert(notover_warning1, L("FF00FF00"))
          return
        end
        ui_npcfunc.ui_cell.clear(card.parent.parent)
        w_pro_list:item_clear()
        local c = w_cell_lock:search("card")
        c.require_count = 0
        w_btn_remake.enable = false
        w_btn_back.visible = false
        ui_npcfunc.ui_cell.clear(c.parent.parent)
        local c1 = w_cell_remake:search("card")
        ui_npcfunc.ui_cell.clear(c1.parent.parent)
        ui_npcfunc.ui_cmn.money_set(w_money, 0)
        ui_npcfunc.ui_remake.w_quick_buy_lock.visible = false
        ui_npcfucn.ui_remake.w_quick_buy_remake.visible = false
      end
    end
    local data = sys.variant()
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  elseif msg == ui.mouse_rbutton_click then
    do
      local function do_move()
        ui_npcfunc.ui_cell.clear(card.parent.parent)
        w_pro_list:item_clear()
        local c = w_cell_lock:search("card")
        card.require_count = 0
        w_btn_remake.enable = false
        w_btn_back.visible = false
        ui_npcfunc.ui_cell.clear(c.parent.parent)
        local c1 = w_cell_remake:search("card")
        ui_npcfunc.ui_cell.clear(c1.parent.parent)
        ui_npcfunc.ui_cmn.money_set(w_money, 0)
        ui_npcfunc.ui_remake.w_quick_buy_lock.visible = false
        ui_npcfunc.ui_remake.w_quick_buy_remake.visible = false
      end
      if w_btn_back.visible then
        ui_widget.ui_msg_box.show_common({
          text = ui.get_text("remake|remove_sure"),
          modal = true,
          callback = function(data)
            if data.result == 1 then
              do_move()
            end
          end
        })
      else
        do_move()
      end
    end
  end
end
function on_card_mouse_remake(card, msg, pos, wheel)
end
function on_card_mouse_lock(card, msg, pos, wheel)
end
function on_remake_affix()
end
function on_equip_slot(card, onlyid, info)
  if info == nil and onlyid ~= 0 then
    ui_npcfunc.ui_cell.clear(card.parent.parent)
    w_pro_list:item_clear()
    if sys.check(w_cell_lock) then
      local c = w_cell_lock:search("card")
      card.require_count = 0
      ui_npcfunc.ui_cell.clear(c.parent.parent)
    end
    w_btn_remake.enable = false
    if sys.check(ui_npcfunc.ui_remake.w_quick_buy_lock) then
      ui_npcfunc.ui_remake.w_quick_buy_lock.visible = false
    end
    if sys.check(ui_npcfunc.ui_remake.w_quick_buy_remake) then
      ui_npcfunc.ui_remake.w_quick_buy_remake.visible = false
    end
    if sys.check(w_cell_remake) then
      local c1 = w_cell_remake:search("card")
      ui_npcfunc.ui_cell.clear(c1.parent.parent)
    end
    if sys.check(w_money) then
      ui_npcfunc.ui_cmn.money_set(w_money, 0)
    end
  end
end
function on_lock_affix()
end
function add_property(name, color, gs)
  local t_color = ui_tool.cs_tip_color_green
  if color then
    t_color = color
  end
  local item_file = "$frame/npcfunc/remake.xml"
  local item_style = "property_item"
  local item = w_pro_list:item_append()
  item:load_style(item_file, item_style)
  item.svar.gs = gs
  local property_name = item:search("property_text")
  property_name.text = name
  property_name.color = ui.make_color(t_color)
  local lock_check = item:search("lock_check")
  local select = item:search("select")
  lock_check.check = false
  select.visible = lock_check.check
  local flash = item:search("flash")
  table.insert(lock_item, {
    index = item.index,
    check = false,
    score = gs
  })
end
function on_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    w_btn_back.visible = false
    bo2.PlaySound2D(578)
    ui.item_mark_show("remake", true)
  else
    ui_widget.esc_stk_pop(w)
    content_clean()
    bo2.PlaySound2D(579)
    ui.item_mark_show("remake", false)
  end
  ui_npcfunc.on_visible(w, vis)
end
function on_btn_back(btn)
  local v = sys.variant()
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  v:set64(packet.key.item_key, info.only_id)
  bo2.send_variant(packet.eCTS_Remake_Back_Pro, v)
end
local add_prop_text = function(stk, txt)
  stk:raw_push([[

<space:2><lb:art,16,,|]])
  local v = sys.variant()
  v:set("property", txt)
  stk:merge(v, ui.get_text("remake|msg_pro"))
  stk:raw_push(">")
end
function on_equip_back_pro(cmd, data)
  local stk = sys.mtf_stack()
  stk:raw_push(ui.get_text("remake|back_title"))
  for i = bo2.eItemUInt32_IdentTraitBeg, bo2.eItemUInt32_IdentTraitEnd - 1 do
    local id = data:get(packet.key.cmn_id + i).v_int
    if id == 0 then
      local info = w_cell_equip:search("card").info
      id = info:get_data_32(i)
    end
    local trait = bo2.gv_trait_list:find(id)
    if trait ~= nil then
      local v = sys.variant()
      local lastMod = trait.modify_id
      local lastVal = trait.modify_value
      local trait_text = ui_tool.ctip_trait_text_ex(lastMod, lastVal)
      add_prop_text(stk, trait_text)
    end
  end
  local msg = {
    text = stk.text,
    font = ui.font("plain", "16"),
    modal = true,
    callback = function(data)
      if data.result == 1 then
        local v = sys.variant()
        local info = w_cell_equip:search("card").info
        if info == nil then
          return
        end
        v:set64(packet.key.item_key, info.only_id)
        bo2.send_variant(packet.eCTS_Remake_Back, v)
      end
    end
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_item_sel(ctrl)
  local btn = ctrl:search("lock_check")
  btn.check = not btn.check
  on_btn_lock_pro(btn)
end
function on_btn_lock_pro(btn)
  if not m_timer_remake.suspended then
    ui_tool.note_insert(notover_warning2, L("FF00FF00"))
    btn.check = false
    return
  end
  local count = 0
  for i, v in ipairs(lock_item) do
    if v.check then
      count = count + 1
    end
  end
  if count >= 3 and btn.check then
    btn.check = false
    ui_tool.note_insert(most_three_warning, L("FF00FF00"))
    return
  end
  local parent_item = btn.parent.parent.parent
  if parent_item ~= nil then
    for i, v in ipairs(lock_item) do
      if v.index == parent_item.index then
        v.check = btn.check
      end
    end
    local select = parent_item:search("select")
    select.visible = btn.check
    local property_name = parent_item:search("property_text")
  end
  local card = w_cell_lock:search("card")
  set_money()
  set_lock_cell()
  local can_remake = check_if_can_remake()
  w_btn_remake.enable = can_remake
end
function on_btn_remake(btn)
  local stk = sys.mtf_stack()
  stk:raw_push(ui.get_text("remake|msg_title"))
  for i = 0, w_pro_list.item_count - 1 do
    local item = w_pro_list:item_get(i)
    if not lock_item[i + 1].check then
      local pro = item:search("property_text")
      add_prop_text(stk, pro.text)
    end
  end
  local msg = {
    text = stk.text,
    font = ui.font("plain", "16"),
    modal = true,
    callback = function(data)
      if data.result == 1 then
        local var = sys.variant()
        local info = w_cell_equip:search("card").info
        if info == nil then
          return
        end
        local star = info:get_data_8(bo2.eItemByte_Star)
        for i = 0, w_pro_list.item_count - 1 do
          local item = w_pro_list:item_get(i)
          if not lock_item[i + 1].check then
            local text_fader = item:search("text_fader")
            text_fader:reset(text_fader.alpha, 0, 1500)
          end
        end
        m_timer_remake.suspended = false
        w_btn_remake.enable = false
      end
    end
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_timer_remake()
  local var = sys.variant()
  local info = w_cell_equip:search("card").info
  if info == nil then
    m_timer_remake.suspended = true
    return
  end
  local card = w_cell_lock:search("card")
  var:set(packet.key.talk_excel_id, bo2.eNpcFunc_ReMake)
  if w_money:search("rmbchk").check then
    var:set(packet.key.rmb_amount, 1)
  end
  var:set64(packet.key.item_key, info.only_id)
  local excel = info.excel
  local reqlevel = excel.reqlevel
  local lock_count = 0
  for item, v in ipairs(lock_item) do
    if v.check then
      lock_count = lock_count + 1
    end
  end
  local star = info:get_data_8(bo2.eItemByte_Star)
  for k = 0, bo2.gv_remake_variety.size - 1 do
    local excel = bo2.gv_remake_variety:get(k)
    if excel ~= nil and reqlevel <= excel.level then
      local req_count = excel.count[star]
      for i1 = 0, excel.remake_item.size - 1 do
        local count = ui.item_get_count(excel.remake_item[i1], true)
        if req_count <= count then
          var:set(packet.key.item_key1, excel.remake_item[i1])
          break
        end
      end
      break
    end
  end
  for j = 0, bo2.gv_lock_variety.size - 1 do
    local excel = bo2.gv_lock_variety:get(j)
    if excel ~= nil and reqlevel <= excel.level then
      local req_count = excel.count[lock_count]
      for i1 = 0, excel.lock_item.size - 1 do
        local count = ui.item_get_count(excel.lock_item[i1], true)
        if req_count <= count then
          var:set(packet.key.item_key2, excel.lock_item[i1])
          break
        end
      end
      break
    end
  end
  for i, item in ipairs(lock_item) do
    if item.check then
      var:set(packet.key.lock_index_start + i - 1, -1)
    else
      var:set(packet.key.lock_index_start + i - 1, item.index)
    end
  end
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, var)
  bo2.PlaySound2D(597)
  m_timer_remake.suspended = true
end
function on_equip_remade(cmd, data)
  local item_file = "$frame/npcfunc/remake.xml"
  local item_style = "property_item"
  local info = w_cell_equip:search("card").info
  if info == nil then
    return
  end
  load_property(info)
  local card = w_cell_lock:search("card")
  local star = info:get_data_8(bo2.eItemByte_Star)
  for i = 0, w_pro_list.item_count - 1 do
    local idx = data:get(packet.key.lock_index_start + i).v_int
    if idx == 1 then
      local item = w_pro_list:item_get(i)
      local text_fader = item:search("text_fader")
      text_fader.alpha = 0
      text_fader:reset(text_fader.alpha, 1, 1500)
      item:search("lock_check").check = false
      item:search("select").visible = false
      local property_name = item:search("property_text")
    else
      local item = w_pro_list:item_get(i)
      item:search("lock_check").check = true
      item:search("select").visible = true
      lock_item[i + 1].check = true
    end
  end
  set_lock_cell()
  set_remake_cell()
  set_money()
  w_btn_remake.enable = check_if_can_remake()
  w_btn_back.visible = true
end
function on_btn_close(btn)
  if not w_btn_back.visible then
    btn.topper.visible = false
    return
  end
  local msg = {
    text = ui.get_text("remake|cancel_sure"),
    modal = true,
    callback = function(data)
      if data.result == 1 then
        btn.topper.visible = false
      end
    end
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_equip_back(cmd, data)
  local info = w_cell_equip:search("card").info
  load_property(info)
  w_btn_back.visible = false
  local can_remake = check_if_can_remake()
  w_btn_remake.enable = can_remake
  local star = info:get_data_8(bo2.eItemByte_Star)
  set_remake_cell()
  set_lock_cell()
  set_money()
end
function w_btn_remake_enable()
  w_btn_remake.enable = check_if_can_remake()
end
function check_if_can_remake()
  local info = w_cell_equip:search("card").info
  if info == nil then
    return false
  end
  local excel = info.excel
  if excel == nil then
    return false
  end
  local ptype = excel.ptype
  if is_equip_item(info) == false then
    return false
  end
  local remake_check = false
  local lock_check = false
  local money_check = false
  local card = w_cell_lock:search("card")
  local star = info:get_data_8(bo2.eItemByte_Star)
  local c = w_cell_remake:search("card")
  local info = w_cell_equip:search("card").info
  local excel = info.excel
  local reqlevel = excel.reqlevel
  local lock_count = 0
  for item, v in ipairs(lock_item) do
    if v.check then
      lock_count = lock_count + 1
    end
  end
  local req_count = 0
  local req_count1 = 0
  for i = 0, bo2.gv_remake_variety.size - 1 do
    local excel = bo2.gv_remake_variety:get(i)
    if excel ~= nil and reqlevel <= excel.level then
      req_count = excel.count[star]
      for i1 = 0, excel.remake_item.size - 1 do
        local count = ui.item_get_count(excel.remake_item[i1], true)
        if req_count <= count then
          remake_check = true
          break
        end
      end
      break
    end
  end
  for j = 0, bo2.gv_lock_variety.size - 1 do
    local excel = bo2.gv_lock_variety:get(j)
    if excel ~= nil and reqlevel <= excel.level then
      req_count = excel.count[lock_count]
      for i1 = 0, excel.lock_item.size - 1 do
        local count = ui.item_get_count(excel.lock_item[i1], true)
        if req_count <= count then
          lock_check = true
          break
        end
      end
      break
    end
  end
  if lock_count == star - 1 then
    remake_check = false
  end
  if w_money:search("rmbchk").check then
    local needmoney = tonumber(tostring(w_money:search("rmb").text))
    local money = ui_supermarket2.g_rmb
    if needmoney <= money then
      money_check = true
    end
  else
    local needmoney = tonumber(tostring(w_money:search("lb_money").money))
    local money = bo2.player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    if needmoney <= money then
      money_check = true
    end
  end
  if remake_check and lock_check and money_check then
    return true
  end
  return false
end
function on_radio_click(btn)
  if not m_timer_remake.suspended then
    if btn.name == L("rmbchk") then
      w_money:search("mnychk").check = true
      w_money:search("rmbchk").check = false
    else
      w_money:search("rmbchk").check = true
      w_money:search("mnychk").check = false
    end
    ui_tool.note_insert(notover_warning3, L("FF00FF00"))
    return
  end
  w_btn_remake.enable = check_if_can_remake()
end
function on_quick_buy_lock(btn)
  local item = w_cell_lock:search("card")
  ui_supermarket2.shelf_quick_buy(btn, item.excel_id)
end
function on_quick_buy_remake(btn)
  local item = w_cell_remake:search("card")
  ui_supermarket2.shelf_quick_buy(btn, item.excel_id)
end
function on_timer()
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_npcfunc.ui_remake.packet_handle"
reg(packet.eSTC_EquipRemade, on_equip_remade, sig)
reg(packet.eSTC_EquipBack, on_equip_back, sig)
reg(packet.eSTC_EquipBackPro, on_equip_back_pro, sig)
