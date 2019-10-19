bo2.gv_box_extend = bo2.load_table_lang("$mb/item/box_extend.xml")
local gv_equip_resolve_verify = bo2.load_table_lang("$mb/item/equip_resolve_verify.xml")
if rawget(_M, "g_boxs") == nil then
  g_boxs = {}
  g_slots = {}
end
function box_coord_to_index(box, grid)
  return box * 65536 + grid
end
function box_index_to_coord(idx)
  local box = math.floor(idx / 65536)
  local grid = math.floor(math.fmod(idx, 65536))
  return box, grid
end
math.randomseed(os.time())
c_text_item_file = SHARED("$frame/item/item.xml")
c_text_item_cell = SHARED("item_cell")
c_box_size_x = 8
c_box_size_y = 5
c_box_count = 6
c_box_margin_x = 29
c_box_margin = 32
c_box_margin2 = 4
c_cell_size = 37
local cs_item_grid = SHARED("$image/item/pic_item_grid.png|0,0,36,36")
local cs_item_bad = SHARED("$image/item/pic_item_bad.png|0,0,36,36")
local cs_item_add = SHARED("$image/item/pic_item_add.png|0,0,36,36")
local cs_item_flag_good = SHARED("$image/item/safe.png|0,0,16,16")
local cs_item_flag_bad = SHARED("$image/pet/female.png|0,0,16,16")
function box_tune()
  local off = w_item.offset
  w_item.dy = 800
  w_item:tune_y("box_list")
  local dy = w_item.dy
  local sy = ui_main.w_top.dy
  local ignore_data = w_item.svar.ignore_data
  if ignore_data ~= nil then
    w_item.svar.ignore_data = nil
  end
  for xx = 1, 8 do
    if dy < sy then
      break
    end
    for slot = 1, 8 do
      local box_data = g_boxs[slot]
      if box_data ~= nil and box_data ~= ignore_data and box_data.expanded then
        box_data.expanded = false
        box_update(box_data, false)
        break
      end
    end
    w_root:update()
    w_item:tune_y("box_list")
    dy = w_item.dy
  end
  w_item.offset = off
end
function box_post_tune()
  w_item:insert_post_invoke(box_tune, "ui_item.box_tune")
end
function on_init_box(ctrl, data)
  local ctop = ctrl:search("ctop")
  if ctop == nil then
    ui.log("failed get box_ctop.")
    return
  end
  local box = data.v_int
  local pn_title = ctrl:search("pn_title")
  local cells = {}
  local box_data = {
    top = ctrl,
    ctop = ctop,
    box = box,
    title = pn_title,
    cells = cells,
    btn_plus = pn_title:search("btn_plus"),
    btn_minus = pn_title:search("btn_minus"),
    expanded = true,
    count = 0
  }
  if box == 0 then
    pn_title.visible = false
  end
  box_data.btn_plus.visible = false
  box_data.btn_minus.visible = true
  g_boxs[box] = box_data
  ctrl.svar.box_data = box_data
  box_update(box_data)
end
function on_init_slot(ctrl, data)
  local slot = data.v_int
  g_slots[slot] = {
    card = ctrl:search("card"),
    bg_lock = ctrl:search("bg_lock")
  }
end
function box_update(box_data, post_tune)
  local cnt = box_data.count
  box_data.top.visible = cnt > 0
  w_item.dx = c_box_margin_x + c_cell_size * c_box_size_x
  box_data.ctop.dx = c_cell_size * c_box_size_x
  local cy = math.floor((cnt + c_box_size_x - 1) / c_box_size_x)
  local dy = c_cell_size * cy
  if box_data.expanded then
    box_data.ctop.visible = true
    box_data.ctop.dy = dy
    if box_data.title.visible then
      box_data.top.dy = dy + c_box_margin
    else
      box_data.top.dy = dy + c_box_margin2
    end
    box_data.btn_plus.visible = false
    box_data.btn_minus.visible = true
  else
    if box_data.box == bo2.eItemBox_BagBeg then
      box_data.ctop.visible = true
    else
      box_data.ctop.visible = false
    end
    box_data.top.dy = c_box_margin - 2
    box_data.btn_plus.visible = true
    box_data.btn_minus.visible = false
  end
  local ext_limit = 0
  local box_ext = bo2.gv_box_extend:find(box_data.box)
  if box_ext ~= nil then
    local items = box_ext.item
    for i = 0, items.size - 1 do
      local item = ui.item_get_excel(items[i])
      if item == nil then
      else
        local use_par = item.use_par
        local par_cnt = use_par.size
        if par_cnt < 3 and par_cnt % 2 ~= 1 then
        else
          for j = 1, par_cnt - 2, 2 do
            local box_item = ui.item_get_excel(use_par[j])
            if box_item ~= nil then
              local par = box_item.use_par
              if 0 < par.size then
                local size = par[0]
                if ext_limit < size then
                  ext_limit = size
                end
              end
            end
          end
        end
      end
    end
  end
  local finish = false
  for y = 0, c_box_size_y - 1 do
    for x = 0, c_box_size_x - 1 do
      local grid = y * c_box_size_x + x
      local cell_data = box_data.cells[grid]
      if y >= cy then
        if cell_data ~= nil then
          cell_data.top.visible = false
        else
          finish = true
          break
        end
      else
        if cell_data == nil then
          local c = ui.create_control(box_data.ctop, "picture")
          c:load_style(c_text_item_file, c_text_item_cell)
          local grid = y * c_box_size_x + x
          local d = c:search("card")
          d.box = box_data.box
          d.grid = grid
          cell_data = {
            top = c,
            card = d,
            bg = c:search("bg")
          }
          box_data.cells[grid] = cell_data
        end
        cell_data.top.offset = ui.point(x * c_cell_size, y * c_cell_size)
        cell_data.top.visible = true
        local bg = cell_data.bg
        if cnt > grid then
          cell_data.card.enable = true
          bg.image = cs_item_grid
          bg.mouse_able = false
        else
          cell_data.card.enable = false
          if ext_limit > grid then
            bg.image = cs_item_add
            bg.mouse_able = true
          else
            bg.image = cs_item_bad
            bg.mouse_able = false
          end
        end
        cell_data.top.visible = true
      end
    end
    if finish then
      break
    end
  end
  if post_tune == nil then
    box_post_tune()
  end
end
function box_resize(slot, cnt)
  local box_data = g_boxs[slot]
  if box_data == nil then
    return
  end
  box_data.count = cnt
  box_update(box_data)
end
function box_item_size(info)
  if info == nil then
    return 0
  end
  local excel = info.excel
  if excel == nil then
    return 0
  end
  local cnt = excel.use_par[0]
  return cnt
end
function box_destroy_drop(data)
  local only_id = data:get("only_id").v_string
  local info = ui.item_of_only_id(only_id)
  if info == nil or info.count == 0 then
    return
  end
  if info.box == bo2.eItemBox_Bank or info.box == bo2.eItemBox_AccBank or info.box == bo2.eItemBox_NewBank or info.box >= bo2.eItemBox_Guild_Depot1 and info.box <= bo2.eItemBox_Guild_Depot3 then
    ui_tool.note_insert(ui.get_text("bank|bank_item_destroy_warning"), "FFFF0000")
    return
  end
  if info.box >= bo2.eItemBox_RidePetBegin and info.box < bo2.eItemBox_RidePetEnd then
    return
  end
  if info.box == bo2.eItemArray_InSlot then
    return
  end
  local holesnum = info:get_data_8(bo2.eItemByte_Holes)
  for idx = 0, holesnum - 1 do
    if info:get_data_32(bo2.eItemUInt32_GemBeg + idx) ~= 0 then
      local txt = ui.get_text("npcfunc|eu_gem_tip")
      ui_tool.note_insert(txt, "FF0000")
      return
    end
  end
  if 0 < info:get_data_8(bo2.eItemByte_DiaowenMaxHolesTotle) and 0 < info:get_data_32(bo2.eItemUInt32_DiaowenCurHolesTotle) then
    local txt = ui.get_text("skill|hunskill_have_jinshi_warning")
    ui_tool.note_insert(txt, "FF0000")
    return
  end
  local function on_msg(msg)
    if msg.result == 0 then
      return
    end
    info = ui.item_of_only_id(only_id)
    if info == nil or info.count == 0 then
      return
    end
    local count = 0
    if msg.input == nil then
      count = info.count
    else
      count = L(msg.input).v_int
      if count == 0 then
        return
      end
    end
    send_destroy(only_id, count)
  end
  local msg = {
    callback = on_msg,
    modal = true,
    limit = 12,
    number_only = true
  }
  if info.count == 1 then
    msg.text = ui_widget.merge_mtf({
      code = info.code
    }, ui.get_text("item|confirm_del_item"))
  else
    msg.text = ui_widget.merge_mtf({
      code = info.code
    }, ui.get_text("item|confirm_del_item_count"))
    msg.input = info.count
  end
  ui_widget.ui_msg_box.show_common(msg)
end
function on_slot_index(ctrl, idx, info)
  if idx == -1 then
    return
  end
  local cnt = box_item_size(info)
  local box, grid = box_index_to_coord(idx)
  box_resize(grid, cnt)
end
function on_recognized_msg(msg)
  if msg.result == 0 then
    return
  end
  local v = sys.variant()
  v:set(packet.key.item_key, msg.only_id)
  bo2.send_variant(packet.eCTS_Equip_RecognizedMaster, v)
end
function on_box_visible(ctr, vis)
  if vis == true then
    ui_handson_teach.on_vis_box_popo(false)
  end
end
function on_card_drop(card, msg, pos, data)
  if msg == ui.mouse_rbutton_down or msg == ui.mouse_rbutton_up then
    ui.clean_drop()
    return
  end
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  local info = card.info
  if ui_widget.check_drop(data, ui_widget.c_drop_type_repair) then
    local fn = ui_npcfunc.ui_shop.fn_repair_one
    if fn ~= nil then
      fn()
    end
    if info == nil then
      if msg == ui.mouse_lbutton_up then
        ui_tool.note_insert(ui.get_text("item|click_repair_item"))
      end
      return
    end
    if msg == ui.mouse_lbutton_up then
      send_repair(info.only_id)
      bo2.PlaySound2D(536)
    end
    return
  elseif ui_widget.check_drop(data, ui_widget.c_drop_type_seal) then
    if info == nil then
      return
    end
    local function on_send_use(msg)
      if msg.result == 0 then
        return
      end
      send_useto(data:get("only_id"), info.only_id)
    end
    local _item_name = ui_widget.merge_mtf({
      item_name = sys.format(L("<fi:%d,%s>"), info.excel.id, info.only_id)
    }, ui.get_text("tool|item_seal"))
    local msg = {
      text = _item_name,
      btn_confirm = true,
      btn_cancel = true,
      callback = on_send_use
    }
    ui_widget.ui_msg_box.show_common(msg)
    return
  elseif ui_widget.check_drop(data, ui_widget.c_drop_type_useto) then
    if info == nil then
      return
    end
    do
      local src_only_id = data:get("only_id")
      local src_info = ui.item_of_only_id(src_only_id)
      local puse = src_info.excel.iuse
      if puse ~= nil then
        if puse.model == bo2.eUseMod_IdentifyEquip then
          if ui_handson_teach.is_in_mstone(ui_handson_teach.g_ei_quest_id, ui_handson_teach.g_ei_mstone_id) then
            ui_handson_teach.test_complate_equipidentify_open_ui(false)
            ui_handson_teach.test_complate_equipidentify_action1(false)
            ui_handson_teach.test_complate_equipidentify_action2(false)
          end
        elseif puse.model == bo2.eUseMod_EquipModelRecover then
          if info:get_data_32(bo2.eItemUint32_EquipModel) ~= 0 then
            send_useto(src_only_id, info.only_id)
          end
          return
        end
      end
      if puse ~= nil and puse.model == bo2.eUseMod_SecondWeaponMultiExp then
        local s_excel = info.excel
        if s_excel ~= nil then
          if s_excel.ptype ~= nil and s_excel.ptype.equip_slot == bo2.eItemSlot_2ndWeapon and s_excel.ass_id ~= 0 and s_excel.ass_upgrade.size ~= 0 then
            local iAdd = info:get_data_32(bo2.eItemUInt32_SeExpAdd)
            local iCount = info:get_data_32(bo2.eItemUInt32_SeExpCount)
            if iAdd == 0 and iCount == 0 then
              send_useto(data:get("only_id"), info.only_id)
              return
            else
              local function on_msg_callback(msg)
                if msg.result ~= 1 then
                  return
                end
                send_useto(data:get("only_id"), info.only_id)
                return
              end
              local stk = sys.mtf_stack()
              local v = sys.variant()
              v:set("add", iAdd + 1)
              v:set("count", iCount)
              local title_text = sys.format(sys.mtf_merge(v, ui.get_text("item|cover_old")))
              local msg = {callback = on_msg_callback, text = title_text}
              ui_widget.ui_msg_box.show_common(msg)
            end
          else
            ui_tool.note_insert(ui.get_text("item|only_up"), L("FFFF0000"))
            return
          end
        end
      elseif puse ~= nil and puse.model == bo2.eUseMod_AvataEnchant then
        if info:get_data_8(bo2.eItemByte_Bound) == 0 and src_info:get_data_8(bo2.eItemByte_Bound) == 1 then
          local function on_msg_callback(m_data)
            if m_data.result ~= 1 then
              return
            end
            ui_item.ui_avata.open(src_info, info)
          end
          local msg = {
            callback = on_msg_callback,
            text = ui.get_text("item|bound_notify")
          }
          ui_widget.ui_msg_box.show_common(msg)
        else
          ui_item.ui_avata.open(src_info, info)
        end
        return
      elseif puse ~= nil and puse.model == bo2.eUseMod_Clear_RecognizedMaster then
        local equip_line = bo2.gv_equip_item:find(info.excel_id)
        if equip_line == nil then
          ui_chat.show_ui_text_id(2653)
          return
        end
        local maxRec = info:get_data_8(bo2.eItemByte_RecognizedMaxCount)
        local timesRec = info:get_data_8(bo2.eItemByte_RecognizedCounted)
        if equip_line.ptype.group ~= bo2.eItemGroup_Equip or maxRec <= 0 or timesRec <= 0 then
          ui_chat.show_ui_text_id(2653)
          return
        end
        local function on_msg_callback(m_data)
          if m_data.result ~= 1 then
            return
          end
          local v = sys.variant()
          v:set(packet.key.item_key, src_only_id)
          v:set(packet.key.use_dstitem_key, info.only_id)
          bo2.send_variant(packet.eCTS_UI_UseItem, v)
        end
        local msg = {
          callback = on_msg_callback,
          text = ui.get_text("item|info_clear_recognizedmaster")
        }
        ui_widget.ui_msg_box.show_common(msg)
        return
      elseif puse ~= nil and puse.model == bo2.eUseMod_Add_RecognizedMasterMaxCount then
        local equip_line = bo2.gv_equip_item:find(info.excel_id)
        if equip_line == nil then
          ui_chat.show_ui_text_id(2656)
          return
        end
        local maxRec = info:get_data_8(bo2.eItemByte_RecognizedMaxCount)
        if equip_line.ptype.group ~= bo2.eItemGroup_Equip and maxRec <= 0 then
          ui_chat.show_ui_text_id(2656)
          return
        end
        local v = sys.variant()
        v:set(packet.key.item_key, src_only_id)
        v:set(packet.key.use_dstitem_key, info.only_id)
        bo2.send_variant(packet.eCTS_UI_UseItem, v)
        return
      elseif puse ~= nil and puse.model == bo2.eUseMod_LivingSkillJianding then
        send_useto(data:get("only_id"), info.only_id)
        return
      elseif puse ~= nil and info:get_data_8(bo2.eItemByte_Bound) == 0 and src_info:get_data_8(bo2.eItemByte_Bound) == 1 and (puse.model == bo2.eUseMod_AvataPunch or puse.model == bo2.eUseMod_AvataRemoveEnchant or puse.model == bo2.eUseMod_AvataInsetEnchant) then
        local function on_msg_callback(m_data)
          if m_data.result ~= 1 then
            return
          end
          send_useto(data:get("only_id"), info.only_id)
        end
        local msg = {
          callback = on_msg_callback,
          text = ui.get_text("item|bound_notify")
        }
        ui_widget.ui_msg_box.show_common(msg)
      else
        send_useto(data:get("only_id"), info.only_id)
        return
      end
    end
  elseif ui_widget.check_drop(data, ui_widget.c_drop_type_freezeitem) then
    ui_safe.req_freezeitem(card.info)
    return
  elseif ui_widget.check_drop(data, ui_widget.c_drop_type_unfreezeitem) then
    ui_safe.req_unfreezeitem(card.info)
    return
  elseif ui_widget.check_drop(data, ui_widget.c_drop_type_fitting) then
    ui_fitting_room.req_fitting_item_by_excel(card.excel, info)
    return
  elseif ui_widget.check_drop(data, ui_widget.c_drop_type_punch) then
    local equip_line = bo2.gv_equip_item:find(info.excel_id)
    if equip_line == nil then
      ui_tool.note_insert(ui.get_text("npcfunc|punch_no_equip"), L("FFFF0000"))
      return
    end
    local excel_id = data:get("excel_id").v_int
    local level = equip_line.reqlevel
    local ptype = equip_line.ptype
    local group = math.floor((level + 10) / 10)
    local function punch_confirm(msg)
      if msg.result == 0 then
        return
      end
      send_useto(data:get("only_id"), info.only_id)
    end
    if ptype.group == bo2.eItemGroup_Avata then
      local avatar = bo2.gv_avatar_punch:find(group)
      if avatar == nil then
        ui_tool.note_insert(ui.get_text("npcfunc|punch_level"), L("FFFF0000"))
        return
      end
      local stk = sys.mtf_stack()
      local cfm_text = ui.get_text("npcfunc|punch_confirm_avatar")
      local arg = sys.variant()
      local bdmoney = sys.format("<bm:%d>", avatar.money)
      arg:set("money", bdmoney)
      stk:raw_format(sys.mtf_merge(arg, cfm_text))
      local msg = {
        text = stk.text,
        btn_confirm = true,
        btn_cancel = true,
        callback = punch_confirm
      }
      ui_widget.ui_msg_box.show_common(msg)
    else
      local epn = bo2.gv_equip_punch:find(group)
      if epn == nil then
        ui_tool.note_insert(ui.get_text("npcfunc|punch_level"), L("FFFF0000"))
        return
      end
      local stk = sys.mtf_stack()
      local cfm_text = ui.get_text("npcfunc|punch_confirm")
      local arg = sys.variant()
      local bdmoney = sys.format("<bm:%d>", epn.money)
      arg:set("money", bdmoney)
      stk:raw_format(sys.mtf_merge(arg, cfm_text))
      local msg = {
        text = stk.text,
        btn_confirm = true,
        btn_cancel = true,
        callback = punch_confirm
      }
      ui_widget.ui_msg_box.show_common(msg)
    end
    return
  elseif ui_widget.check_drop(data, ui_widget.c_drop_type_gem_inlay) then
    do
      local equip_line = bo2.gv_equip_item:find(info.excel_id)
      if equip_line == nil then
        ui_tool.note_insert(ui.get_text("npcfunc|gem_inlay_no_equip"), L("FFFF0000"))
        return
      end
      local excel_id = data:get("excel_id").v_int
      local pGemExcel = bo2.gv_gem_item:find(excel_id)
      local pGemInl = bo2.gv_gem_inlay:find(pGemExcel.varlevel)
      local function gem_inlay_confirm_again(msg)
        if msg.result == 0 then
          return
        end
        send_useto(data:get("only_id"), info.only_id)
      end
      local function gem_inlay_confirm(msg)
        if msg.result == 0 then
          return
        end
        local mtf_stk = sys.mtf_stack()
        local txt = ui.get_text("npcfunc|gem_inlay_confirm_again")
        local var = sys.variant()
        local cost = sys.format("<m:%d>", pGemInl.money)
        local gem_name = sys.format("<i:%d>", excel_id)
        local equip_name = sys.format("<fi:%s>", info.code)
        var:set("money", cost)
        var:set("item_name", gem_name)
        var:set("equip_name", equip_name)
        mtf_stk:raw_format(sys.mtf_merge(var, txt))
        local msg_again = {
          text = mtf_stk.text,
          btn_confirm = true,
          btn_cancel = true,
          callback = gem_inlay_confirm_again
        }
        ui_widget.ui_msg_box.show_common(msg_again)
      end
      local stk = sys.mtf_stack()
      local cfm_text = L("")
      if equip_line.ptype.group == bo2.eItemGroup_Avata then
        cfm_text = ui.get_text("npcfunc|gem_inlay_confirm2")
      else
        cfm_text = ui.get_text("npcfunc|gem_inlay_confirm")
      end
      local arg = sys.variant()
      local bdmoney = sys.format("<m:%d>", pGemInl.money)
      arg:set("money", bdmoney)
      stk:raw_format(sys.mtf_merge(arg, cfm_text))
      local msg = {
        text = stk.text,
        btn_confirm = true,
        btn_cancel = true,
        callback = gem_inlay_confirm
      }
      ui_widget.ui_msg_box.show_common(msg)
    end
  elseif ui_widget.check_drop(data, ui_widget.c_drop_type_skilltoitem) then
    if info == nil then
      return
    end
    local skill_id = data:get("skill_id").v_int
    if skill_id == 100042 then
      if info:get_data_8(bo2.eItemByte_Bound) ~= 0 then
        if 0 < info:get_data_32(bo2.eItemUInt32_RecognizedMasterTimes) then
          local msg = {
            callback = on_recognized_msg,
            only_id = info.only_id
          }
          msg.text = ui.get_text("item|recognized_already")
          msg.title = ui.get_text("item|recognizedmaster")
          ui_widget.ui_msg_box.show_common(msg)
        else
          local v = sys.variant()
          v:set(packet.key.item_key, info.only_id)
          bo2.send_variant(packet.eCTS_Equip_RecognizedMaster, v)
        end
      else
        local msg = {
          callback = on_recognized_msg,
          only_id = info.only_id
        }
        if 0 < info:get_data_32(bo2.eItemUInt32_RecognizedMasterTimes) then
          msg.text = ui.get_text("item|recognized_already")
        else
          msg.text = ui.get_text("item|recognized_sure")
        end
        msg.title = ui.get_text("item|recognizedmaster")
        ui_widget.ui_msg_box.show_common(msg)
      end
    elseif skill_id == 100284 then
      do
        local excel_id = info.excel_id
        local excel = bo2.gv_item_list:find(excel_id)
        if excel == nil then
          excel = bo2.gv_quest_item:find(excel_id)
        end
        local function check_yanmo(excel_id)
          if excel.requires.size == 2 and excel.requires[0] == 101 and excel.requires[1] == 100284 then
            return true
          end
          return false
        end
        local skill_info = ui.skill_find(100284)
        if excel == nil or skill_info == nil or not check_yanmo(excel_id) then
          local msg = {
            text = ui.get_text("npcfunc|livingskill_yanmo_warning"),
            btn_confirm = true,
            btn_cancel = false
          }
          ui_widget.ui_msg_box.show_common(msg)
        else
          local callback_confirm = function(msg)
            if msg.result == 0 then
              return
            end
            local v = sys.variant()
            v:set(packet.key.cmn_type, bo2.eFuncTypeSkillYanmo)
            v:set(packet.key.item_key, msg.only_id)
            bo2.send_variant(packet.eCTS_UI_Livingskill, v)
          end
          local text = ui_widget.merge_mtf({
            item = sys.format("<fi:%s>", info.code)
          }, ui.get_text("npcfunc|livingskill_yanmo_confirm"))
          local msg = {
            text = text,
            btn_confirm = true,
            btn_cancel = true,
            callback = callback_confirm
          }
          msg.only_id = info.only_id
          ui_widget.ui_msg_box.show_common(msg)
        end
      end
    elseif skill_id == 100287 then
      do
        local excel_id = info.excel_id
        local excel = bo2.gv_item_list:find(excel_id)
        if excel == nil then
          excel = bo2.gv_quest_item:find(excel_id)
        end
        local function check_jianding(excel_id)
          if excel.requires.size == 2 and excel.requires[0] == 101 and excel.requires[1] == 100287 then
            return true
          end
          return false
        end
        local skill_info = ui.skill_find(100287)
        if excel == nil or skill_info == nil or not check_jianding(excel_id) then
          local msg = {
            text = ui.get_text("npcfunc|livingskill_jianding_warning"),
            btn_confirm = true,
            btn_cancel = false
          }
          ui_widget.ui_msg_box.show_common(msg)
        else
          local callback_confirm = function(msg)
            if msg.result == 0 then
              return
            end
            local v = sys.variant()
            v:set(packet.key.cmn_type, bo2.eFuncTypeSkillJianding)
            v:set(packet.key.item_key, msg.only_id)
            bo2.send_variant(packet.eCTS_UI_Livingskill, v)
          end
          local text = ui_widget.merge_mtf({
            item = sys.format("<fi:%s>", info.code)
          }, ui.get_text("npcfunc|livingskill_jianding_confirm"))
          local msg = {
            text = text,
            btn_confirm = true,
            btn_cancel = true,
            callback = callback_confirm
          }
          msg.only_id = info.only_id
          ui_widget.ui_msg_box.show_common(msg)
        end
      end
    elseif skill_id == 100113 then
      if ui_item_compose.try_decompose(info) then
        return
      end
      local excel_id = info.excel_id
      local excel = bo2.gv_equip_item:find(info.excel_id)
      if excel == nil then
        excel = bo2.gv_item_list:find(info.excel_id)
      end
      if excel == nil then
        local msg = {
          text = ui.get_text("npcfunc|resolve_warning"),
          btn_confirm = true,
          btn_cancel = false
        }
        ui_widget.ui_msg_box.show_common(msg)
      while true do
        else
          do
            local resolve_second_confirm = function(msg)
              if msg.result == 0 then
                return
              end
              if w_verify_input.text ~= w_text_verify.text then
                ui_tool.note_insert(ui.get_text("item|resolve_verify_wrong"), "FFFFFF00")
                return
              end
              local v = sys.variant()
              v:set(packet.key.item_key, msg.equip_only_id)
              bo2.send_variant(packet.eCTS_UI_EquipResolve, v)
            end
            local function resolve_first_confirm(msg)
              if msg.result == 0 then
                return
              end
              if msg.star >= 7 then
                local s_msg = {
                  callback = resolve_second_confirm,
                  btn_confirm = true,
                  btn_cancel = true,
                  modal = true,
                  style_uri = "$frame/item/item.xml",
                  style_name = "resolve_verify_msg_box"
                }
                s_msg.equip_only_id = msg.equip_only_id
                ui_widget.ui_msg_box.show(s_msg)
                local id = math.random(gv_equip_resolve_verify.size)
                local excel = gv_equip_resolve_verify:find(id)
                w_text_verify.text = excel.name
              else
                local v = sys.variant()
                v:set(packet.key.item_key, msg.equip_only_id)
                bo2.send_variant(packet.eCTS_UI_EquipResolve, v)
              end
            end
            local text = ui_widget.merge_mtf({
              item = sys.format("<fi:%s>", info.code)
            }, ui.get_text("npcfunc|resolve_confirm"))
            local msg = {
              text = text,
              btn_confirm = true,
              btn_cancel = true,
              callback = resolve_first_confirm
            }
            msg.equip_only_id = info.only_id
            msg.star = info.star
            ui_widget.ui_msg_box.show_common(msg)
            break
          end
        end
      end
    end
  end
  if not ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    return
  end
  if info ~= nil and info.only_id == data:get("only_id").v_string and msg == ui.mouse_lbutton_up then
    return
  end
  ui.clean_drop()
  cmn_move_item(data:get("only_id").v_string, card.index)
end
function on_verify_input_chg()
  w_verify_input_mask.visible = w_verify_input.text.empty
end
function on_mouse_chg_another_verify(ctrl, msg)
  if msg ~= ui.mouse_lbutton_down then
    return
  end
  local id = math.random(gv_equip_resolve_verify.size)
  local excel = gv_equip_resolve_verify:find(id)
  if excel.name ~= w_text_verify.text then
    w_text_verify.text = excel.name
    return
  end
end
local flash_item_release = function()
  w_flash_item_release:control_clear()
end
local function flash_item_post_release(flash_item)
  flash_item.parent = w_flash_item_release
  w_flash_item_release:insert_post_invoke(flash_item_release, "ui_item.flash_item_release")
end
function on_cancel_item_fresh(card)
  if sys.check(card) ~= true or sys.check(card.info) ~= true then
    return
  end
  if card.info.fresh ~= true then
    return
  end
  card.info.fresh = false
  local item_flicker = card.parent:search("flash_item")
  if sys.check(item_flicker) then
    flash_item_post_release(item_flicker)
  end
end
function check_box_need_open(grid)
  local basic = ui_widget.get_define_int(249)
  local limit = ui_widget.get_define_int(250)
  if grid > basic and grid <= limit then
    local player = bo2.player
    local count = basic + player:get_flag_int8(bo2.ePlayerFlagInt8_ItemBoxExt)
    if grid > count then
      return true
    end
  end
  return false
end
local is_inner = sys.is_file("$cfg/tool/pix_dj2_config.xml")
function on_bad_card_mouse(img, msg, pos, wheel)
  if msg ~= ui.mouse_rbutton_click then
    return
  end
  local box_ext = bo2.gv_box_extend:find(img:search("card").box)
  local items = box_ext.item
  for i = 0, items.size - 1 do
    local excel_id = items[i]
    local item = ui.item_get_excel(excel_id)
    if item ~= nil then
      ui_supermarket2.shelf_quick_buy(w_btn_quick_buy, excel_id)
    end
  end
end
function on_bad_card_tip_make(tip)
  local card = tip.owner:search("card")
  local stk = sys.mtf_stack()
  stk:raw_push(ui.get_text("box_extend|tip_ext_items"))
  local box_ext = bo2.gv_box_extend:find(card.box)
  local items = box_ext.item
  local qbuy = false
  for i = 0, items.size - 1 do
    local excel_id = items[i]
    local item = ui.item_get_excel(excel_id)
    if item ~= nil then
      stk:raw_format([[

<i:%d>]], excel_id)
      if 0 < ui_supermarket2.shelf_quick_buy_id(excel_id) then
        qbuy = true
      end
    end
  end
  if qbuy then
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("box_extend|tip_ext_buy"), ui_tool.cs_tip_color_operation)
  end
  ui_widget.tip_make_view(tip.view, stk.text)
end
function on_card_mouse(card, msg, pos, wheel)
  local icon = card.icon
  if icon == nil then
    if card.box == bo2.eItemArray_InSlot and msg == ui.mouse_rbutton_click then
      do
        local grid = card.grid
        local player = bo2.player
        local basic = ui_widget.get_define_int(249)
        local count_cur = basic + player:get_flag_int8(bo2.ePlayerFlagInt8_ItemBoxExt)
        if check_box_need_open(grid) and grid - 1 == count_cur and grid == 3 then
          do
            local rmb = ui_widget.get_define_int(250 + grid)
            local text = ui_widget.merge_mtf({
              n = grid,
              m = sys.format("%d<brmb:16>", rmb)
            }, ui.get_text("item|item_box_ext_price"))
            ui_widget.ui_msg_box.show_common({
              text = text,
              btn_confirm = true,
              btn_cancel = true,
              callback = function(msg)
                if msg.result == 1 then
                  ui_supermarket2.shelf_prepareJade(rmb, function()
                    bo2.send_variant(packet.eCTS_UI_ItemBoxExtOpen, grid)
                  end)
                end
              end
            })
          end
        end
      end
    end
    return
  end
  local info = card.info
  if info == nil then
    if msg == ui.mouse_mbutton_click then
      sys.pcall(ui_handson_teach.test_complate_item_mclick, true)
      show_tip_frame_card(card)
    end
    return
  end
  local box = card.box
  on_cancel_item_fresh(card, info)
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_drag then
    if ui.is_key_down(ui.VK_CONTROL) then
      if is_inner and ui.is_key_down(ui.VK_SHIFT) then
        ui_tool.ui_test_editor.w_input.mtf = sys.format(L([[
%s

%s]]), ui_tool.ui_test_editor.w_input.mtf, info.code)
      end
      ui_chat.insert_item(info.excel_id, info.code)
      return
    end
    if box == bo2.eItemArray_InSlot and card.grid >= bo2.eItemSlot_HunskillBegin and card.grid <= bo2.eItemSlot_HunskillEnd then
      return
    end
    if box == bo2.eItemBox_OtherSlot then
      return
    end
    sys.pcall(ui_handson_teach.test_complate_item_monitor, false)
    ui.clean_drop()
    if info.lock > 0 then
      return
    end
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_item)
    data:set("only_id", card.only_id)
    ui.set_cursor_icon(icon.uri)
    local function on_drop_hook(w, msg, pos, data)
      local info = card.info
      if info == nil then
        return
      end
      if msg == ui.mouse_drop_setup then
        info:insert_lock(bo2.eItemLock_Drop)
      elseif msg == ui.mouse_drop_clean then
        info:remove_lock(bo2.eItemLock_Drop)
      end
    end
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  elseif msg == ui.mouse_rbutton_click then
    if ui_bank.get_visible() then
      local grid, c = ui_bank.get_useable_grid(info.excel_id)
      if grid == nil and c == nil then
        ui_tool.note_insert(ui.get_text("bank|bank_full_warning"), "FFFF0000")
        return
      end
      local on_msg = function(msg)
        if msg.result == 0 then
          return
        end
        local count = msg.window:search("number").text.v_int
        if count == 0 then
          return
        end
        send_bank(msg.only_id, bo2.eItemBox_Bank, -1, count)
      end
      if 1 < info.count then
        do
          local cfm_text = ui.get_text("item|cnt_bank_in")
          local arg = sys.variant()
          local stack_count = info.excel.consume_par * 2
          arg:set("stack_count", stack_count)
          ui_widget.ui_msg_box.show({
            style_uri = "$frame/org/common.xml",
            style_name = "goods_box",
            only_id = info.only_id,
            init = function(msg)
              local window = msg.window
              local btn = window:search("all_btn")
              window:search("title").mtf = sys.mtf_merge(arg, cfm_text)
              btn.text = ui.get_text("item|all_put")
              btn.svar.count = info.count
              btn.svar.win = window
              window:search("number").text = info.count
            end,
            callback = on_msg
          })
        end
      elseif info.count == 1 then
        send_bank(info.only_id, bo2.eItemBox_Bank, -1, info.count)
      end
    elseif ui_newbank.get_visible() then
      local grid, c = ui_newbank.get_useable_grid(info.excel_id)
      if grid == nil and c == nil then
        ui_tool.note_insert(ui.get_text("bank|bank_full_warning"), "FFFF0000")
        return
      end
      local on_msg = function(msg)
        if msg.result == 0 then
          return
        end
        local count = msg.window:search("number").text.v_int
        if count == 0 then
          return
        end
        send_newbank(msg.only_id, bo2.eItemBox_NewBank, -1, count)
      end
      if 1 < info.count then
        do
          local cfm_text = ui.get_text("item|cnt_bank_in")
          local arg = sys.variant()
          local stack_count = info.excel.consume_par * 2
          arg:set("stack_count", stack_count)
          ui_widget.ui_msg_box.show({
            style_uri = "$frame/org/common.xml",
            style_name = "goods_box",
            only_id = info.only_id,
            init = function(msg)
              local window = msg.window
              local btn = window:search("all_btn")
              window:search("title").mtf = sys.mtf_merge(arg, cfm_text)
              btn.text = ui.get_text("item|all_put")
              btn.svar.count = info.count
              btn.svar.win = window
              window:search("number").text = info.count
            end,
            callback = on_msg
          })
        end
      elseif info.count == 1 then
        send_newbank(info.only_id, bo2.eItemBox_NewBank, -1, info.count)
      end
    elseif ui_guild_mod.ui_guild_depot.get_visible() then
      guild_req_upgoods(info, info.only_id)
    else
      use_item(info)
    end
    ui_handson_teach.on_vis_item_popo(false, info.excel_id)
  elseif msg == ui.mouse_mbutton_click then
    if ui.is_key_down(ui.VK_CONTROL) then
      ui_fitting_room.req_fitting_item_by_excel(info.excel, info)
      return
    end
    sys.pcall(ui_handson_teach.test_complate_item_mclick, true)
    show_tip_frame_card(card)
  end
end
function tip_get_using_equip(excel, push_operation)
  if excel == nil then
    return nil
  end
  local ptype = excel.ptype
  if ptype == nil then
    return nil
  end
  local info
  for i = bo2.eItemSlot_EquipBeg, bo2.eItemSlot_AvataEnd - 1 do
    local t = ui.item_of_coord(bo2.eItemArray_InSlot, i)
    if t ~= nil and t.excel.ptype.equip_slot == ptype.equip_slot then
      info = t
      break
    end
  end
  if info == nil then
    return nil
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_push_text(stk, ui.get_text("item|current_equip"), ui_tool.cs_tip_color_operation, ui_tool.cs_tip_a_add_m)
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_make_item(stk, info.excel, info)
  return stk
end
function box_data_of(p)
  while sys.check(p) do
    if p.name == L("top") then
      return p.svar.box_data
    end
    p = p.parent
  end
end
function on_box_plus_click(btn)
  local box_data = box_data_of(btn)
  box_data.expanded = true
  box_update(box_data)
  w_item.svar.ignore_data = box_data
end
function on_box_minus_click(btn)
  local box_data = box_data_of(btn)
  box_data.expanded = false
  box_update(box_data)
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  local stk = sys.mtf_stack()
  if excel == nil then
    local box = card.box
    if box == bo2.eItemArray_InSlot or box == bo2.eItemBox_OtherSlot then
      local grid = card.grid
      if check_box_need_open(grid) and grid == 3 then
        stk:merge({
          m = sys.format("%d<brmb:16>", ui_widget.get_define_int(250 + grid))
        }, ui.get_text("item|item_box_ext_tip"))
        ui_tool.ctip_show(card, stk)
        return
      elseif check_box_need_open(grid) and grid == 4 then
        stk:merge({}, ui.get_text("item|item_box_ext_tip2"))
        ui_tool.ctip_show(card, stk)
        return
      elseif check_box_need_open(grid) and grid == 5 then
        stk:merge({}, ui.get_text("item|item_box_ext_tip3"))
        ui_tool.ctip_show(card, stk)
        return
      elseif check_box_need_open(grid) and grid == 6 then
        stk:merge({}, ui.get_text("item|item_box_ext_tip4"))
        ui_tool.ctip_show(card, stk)
        return
      end
      stk:push(ui.get_text(sys.format(L("item|slot%d"), grid)))
      ui_tool.ctip_show(card, stk)
    elseif card.box >= bo2.eItemBox_RidePetBegin and card.box < bo2.eItemBox_RidePetEnd or card.box == bo2.eItemBox_RidePetView then
      ui_ridepet.on_ridepet_equip_tip(tip)
    else
      ui_tool.ctip_show(card, nil)
    end
    return
  else
    ui_tool.ctip_make_item(stk, excel, card.info, card)
  end
  local stk_use
  local info = card.info
  local operation_count = 0
  local function push_operation_new()
    if operation_count == 0 then
      operation_count = 1
      ui_tool.ctip_push_sep(stk)
    else
      ui_tool.ctip_push_newline(stk)
    end
  end
  local function push_operation(txt)
    push_operation_new()
    ui_tool.ctip_push_text(stk, txt, ui_tool.cs_tip_color_operation)
  end
  if card.box == bo2.eItemBox_OtherSlot then
    stk_use = tip_get_using_equip(excel)
  else
    if info ~= nil and tip.is_drop then
      local data = tip.drop_data
      if ui_widget.check_drop(data, ui_widget.c_drop_type_repair) then
        price = info.repair_price
        if price == 0 then
          push_operation(ui.get_text("item|not_need_repair"))
        else
          push_operation(ui.get_text("item|repair_price"))
          stk:raw_format("<bm:%d>", price)
          do break end
          else
            if ui_widget.check_drop(data, ui_widget.c_drop_type_skilltoitem) and data:get("skill_id").v_int == 100113 then
          end
          else
            return
          end
          else
            local box = card.box
            if info ~= nil and box >= bo2.eItemBox_BagBeg and box <= bo2.eItemBox_Quest then
              local d = bo2.item_compose_find(excel.id)
              if d ~= nil and 0 < d.size then
                push_operation(ui.get_text("item_compose|tip_rclick"))
              end
            end
            push_operation(ui.get_text("item|middle_click"))
            if ui_fitting_room.test_item_may_suit(excel) ~= false then
              push_operation(ui.get_text("item|ctrl_fit"))
            elseif 0 < excel.fitting_index.size then
              local size = excel.fitting_index.size
              for i = 0, size - 1 do
                local v = excel.fitting_index[i]
                local equip_excel = bo2.gv_equip_item:find(v)
                if sys.check(equip_excel) then
                  push_operation(ui.get_text("item|ctrl_fit"))
                  break
                end
              end
            end
            local item_type_excel = bo2.gv_item_type:find(excel.type)
            if item_type_excel and item_type_excel.id == bo2.eItemtype_BarberQuan then
              push_operation(ui.get_text("item|ctrl_fit"))
            end
            local ptype = excel.ptype
            local puse = excel.iuse
            if box == bo2.eItemArray_InSlot then
              local grid = card.grid
              if grid >= bo2.eItemSlot_BagBeg and grid <= bo2.eItemSlot_Quest then
                push_operation(ui.get_text("item|right_chg_bag"))
              elseif grid >= bo2.eItemSlot_EquipBeg and grid < bo2.eItemSlot_AvataEnd then
                push_operation(ui.get_text("item|right_input_bag"))
              end
            elseif box >= bo2.eItemBox_RidePetBegin and box < bo2.eItemBox_RidePetEnd then
              local grid = card.grid
              if grid >= bo2.eItemSlot_RidePetBegin and grid < bo2.eItemSlot_RidePetEnd then
                if puse ~= nil then
                  push_operation(ui.get_text("item|right_use"))
                else
                  push_operation(ui.get_text("item|right_input_bag"))
                end
              end
            elseif box >= bo2.eItemBox_BagBeg and box <= bo2.eItemBox_Quest then
              local txt = use_tip(info)
              if txt ~= nil then
                push_operation(txt)
              end
              local bSetIndestructible = false
              if ptype ~= nil then
                local group = ptype.group
                if group == bo2.eItemGroup_Equip or group == bo2.eItemGroup_Avata then
                  stk_use = tip_get_using_equip(excel)
                  local indestructible = excel.indestructible
                  if sys.check(indestructible) and indestructible ~= 0 then
                    ui_tool.ctip_push_sep(stk)
                    ui_tool.ctip_push_text(stk, ui.get_text("item|canot_destroy"), ui_tool.cs_tip_color_operation)
                    bSetIndestructible = true
                  end
                end
              end
              if bSetIndestructible ~= true then
                local pExcel = bo2.gv_item_destory_banned_list:find(excel.id)
                if pExcel then
                  ui_tool.ctip_push_sep(stk)
                  ui_tool.ctip_push_text(stk, ui.get_text("item|canot_destroy"), ui_tool.cs_tip_color_operation)
                end
              end
            end
          end
        end
  end
  local stk_use_data
  if plus_stall_viewer ~= nil and plus_stall_viewer.check_may_use_stk2() then
    local stk_use0 = plus_stall_viewer.get_item_stk2_plus(excel, info)
    if stk_use ~= nil then
      stk_use0:push(ui_tool.cs_tip_sep)
      stk_use0:push(stk_use.text)
    end
    stk_use_data = stk_use0
  else
    stk_use_data = stk_use
  end
  ui_tool.ctip_show(card, stk, stk_use_data)
end
function cd()
  ui.cooldown_insert(1001, 0, 5000)
end
function on_click_open_stall()
  if ui_stall.is_Send_To_Sev == 1 or ui_stall.owner.g_owner.opening ~= true then
    ui_stall.get_stall_cookies()
    ui_stall.is_Send_To_Sev = 0
  end
  if ui_stall.viewer.gx_main_window.visible then
    ui_stall.viewer.the_view_stall_open = false
    ui_stall.viewer.gx_main_window.visible = false
  end
  local is_stallvisible = ui_stall.owner.get_visible()
  ui_stall.owner.set_visible(not is_stallvisible)
  ui_bank.set_visible(false)
  ui_deal.set_visible(false)
end
function on_click_tidy_box()
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_TidyBox, v)
  close_all_item_flicker()
  bo2.PlaySound2D(522)
end
function on_click_open_supermarket(btn)
  if ui_supermarket2.CanOpen() then
    ui_supermarket2.w_main.visible = not ui_supermarket2.w_main.visible
  end
end
function set_visible(vis)
  local w = ui.find_control("$frame:item")
  w.visible = vis
end
function close_all_item_flicker()
  for i, v in pairs(ui_item.g_boxs) do
    for j, k in pairs(v.cells) do
      if sys.check(k.card) and k.card.info ~= nil and k.card.info.fresh then
        on_cancel_item_fresh(k.card)
      end
    end
  end
end
local cs_flicker = SHARED("flicker")
local cs_flicker_style_uri = SHARED("$frame/item/item.xml")
local cs_flicker_style_name = SHARED("item_flicker")
function enable_all_item_flicker()
  for i, v in pairs(ui_item.g_boxs) do
    for j, k in pairs(v.cells) do
      local card = k.card
      if card then
        local parent = card.parent
        local item_flicker = parent:search("flash_item")
        if sys.check(card.info) and sys.is_type(card.info, L("ui_item_info")) and card.info.fresh then
          if not sys.check(item_flicker) then
            item_flicker = ui.create_control(parent, cs_flicker)
            item_flicker:load_style(cs_flicker_style_uri, cs_flicker_style_name)
            item_flicker:move_to_head()
          end
          item_flicker.visible = true
        elseif sys.check(item_flicker) then
          flash_item_post_release(item_flicker)
        end
      end
    end
  end
end
function on_esc_visible(w, vis)
  if vis then
    enable_all_item_flicker()
    local player = bo2.player
    if player and player:get_flag_objmem(bo2.eFlagObjMemory_Stalling) ~= 0 then
      local vis = ui_stall.chat.get_visible()
      on_click_open_stall()
      ui_stall.owner.set_visible(true)
      ui_stall.chat.set_visible(vis)
    end
    if ui_handson_teach.is_in_mstone(ui_handson_teach.g_ei_quest_id, ui_handson_teach.g_ei_mstone_id) then
      ui_handson_teach.test_complate_equipidentify_action1(true)
    end
  else
    close_all_item_flicker()
  end
  ui_handson_teach.test_complate_item_monitor(vis)
  ui_widget.on_esc_stk_visible(w, vis)
  bo2.SendUIEvent(bo2.eUIEvent_Bag, vis)
end
local init_test_item = function()
  local info
  ui.item_create(10001, 0, 3)
  ui.item_create(10002, 0, 4)
  ui.item_create(10003, 0, 5)
  ui.item_create(51019, 0, 6)
  ui.item_create(52101, 0, 8, 332)
  ui.item_create(52111, 0, 9, 422)
  ui.item_create(52121, 0, 10, 514)
  ui.item_create(52001, 0, 11, 122)
  ui.item_create(52002, 0, 12, 242)
  ui.item_create(52003, 0, 13, 322)
  ui.item_create(53345, 0, 7)
  ui.cooldown_insert(20005, 1000, 2000)
  ui.item_create(10043, 0, 21, 754)
  ui.item_create(53871, 0, 22, 10)
  ui.item_create(53872, 0, 23, 20)
  ui.item_create(14, 0, 25, 4)
  ui.item_create(10004, 0, 26, 1)
  info = ui.item_create(34405, 0, 27, 1)
  info:set_data_8(bo2.eItemByte_EnforceLvl, 10)
  ui.item_create(34405, 0, 28, 1)
  ui.item_create(13004, 0, 29)
  info = ui.item_create(10301, 0, 30)
  info:set_data_8(bo2.eItemByte_Star, 3)
  info:set_data_8(bo2.eItemByte_EnforceLvl, 2)
  info:set_data_32(bo2.eItemUInt32_IdentTraitBeg, 1)
  info = ui.item_create(10002, 0, 31, 33)
  info:set_data_8(bo2.eItemByte_EnforceLvl, 3)
  info:set_data_8(bo2.eItemByte_Star, 4)
  info:set_data_32(bo2.eItemUInt32_IdentTraitBeg, 1001)
  info:set_data_8(bo2.eItemByte_Holes, 4)
  info:set_data_32(bo2.eItemUInt32_GemBeg, 90010)
  info:set_data_32(bo2.eItemUInt32_GemBeg + 1, 90011)
  info:set_data_32(bo2.eItemUInt32_EnchantBeg, 1001)
  info:set_data_32(bo2.eItemUInt32_EnchantBeg + 1, 1002)
  info:set_data_32(bo2.eItemUInt32_CurWearout, 200)
  info:set_data_32(bo2.eItemUInt32_MaxWearout, 300)
  info:set_xdata_32(bo2.eItemXData32_TimeUpdate, sys.tick())
  info:set_xdata_32(bo2.eItemXData32_TimeRemain, 5000)
  ui.item_create(50006, bo2.eItemArray_InSlot, 0)
  ui.item_create(50008, bo2.eItemArray_InSlot, 8)
  ui.item_create(10001, bo2.eItemArray_InSlot, bo2.eItemSlot_EquipBeg)
  ui.item_create(10002, bo2.eItemArray_InSlot, bo2.eItemSlot_EquipBeg + 1)
  ui.item_create(10003, bo2.eItemArray_InSlot, bo2.eItemSlot_EquipBeg + 2)
  ui.item_goods_insert(205, 1, 0)
  ui.item_goods_insert(210, 3, 0)
  ui.item_goods_insert(215, 3, 0)
end
function hotkey_update()
  local player = bo2.player
  if player == nil then
    return
  end
  local txt = ui_setting.ui_input.get_op_simple_text(2001)
  if txt ~= nil and not txt.empty then
    w_item:search("lb_title").text = ui_widget.merge_mtf({name = txt}, ui.get_text("item|bag_param"))
  else
    w_item:search("lb_title").text = ui.get_text("item|bag")
  end
end
function on_init()
  if bo2.ui_test_mark == true then
    init_test_item()
  end
  ui_setting.ui_input.hotkey_notify_insert(hotkey_update, "ui_item.hotkey_update")
  hotkey_update()
  wide_update()
  gain_init()
end
function get_useable_box_grid(id)
  local info = ui.item_of_excel_id(id)
  if info ~= nil then
    ui.log("info,box:%d,grid:%d", info.box, info.grid)
    return info.box, info.grid
  end
  local size = w_list.item_count
  for i = 0, size - 1 do
    local item = w_list:item_get(i)
    local box_data = item.svar.box_data
    if box_data.box >= bo2.eItemBox_BagBeg and box_data.box < bo2.eItemBox_Quest then
      for j = 0, box_data.count - 1 do
        local cell = box_data.cells[j]
        if cell.card.info == nil then
          return cell.card.box, cell.card.grid
        end
      end
    end
  end
  return 0, 0
end
function is_bag_full()
  local size = w_list.item_count
  for i = 0, size - 1 do
    local item = w_list:item_get(i)
    local box_data = item.svar.box_data
    if box_data.box >= bo2.eItemBox_BagBeg and box_data.box < bo2.eItemBox_Quest then
      for j = 0, box_data.count - 1 do
        local cell = box_data.cells[j]
        if cell.card.info == nil then
          return false
        end
      end
    end
  end
  return true
end
local ui_tab = ui_widget.ui_tab
function update_show_deal()
  local btn = ui_tab.get_button(g_log_deal, "deal_log")
  local flag = btn.var:get("flag").v_int
  if flag == 0 then
    local this_panel = g_log_deal:search("deal_log")
    if this_panel ~= nil then
      local this_richbox = this_panel:search("log_box")
      local size = #ui_deal.log_list
      if size == 0 then
        local text = ui.get_text("item|no_deal_log")
        this_richbox.mtf = text
      else
        for i, v in ipairs(ui_deal.log_list) do
          local rank = ui.mtf_rank_system
          this_richbox:insert_mtf(v, rank)
        end
      end
    end
  end
  btn.var:set("flag", 1)
end
function update_show_stall()
  local btn = ui_tab.get_button(g_log_deal, "stall_log")
  local flag = btn.var:get("flag").v_int
  if flag == 0 then
    local this_panel = g_log_deal:search("stall_log")
    if this_panel ~= nil then
      local this_richbox = this_panel:search("log_box")
      local id = bo2.player:get_qwordtemp(bo2.ePFlagQwordTemp_StallNewsgroup)
      if id == L("0") then
        local text = ui.get_text("item|no_stall_log")
        this_richbox.mtf = text
      else
        local table = ui_stall.chat.chat_table[id]
        local size = #table
        if size == 0 then
          local text = ui.get_text("item|no_stall_log")
          this_richbox.mtf = text
        else
          for i, v in ipairs(table) do
            local rank = ui.mtf_rank_system
            this_richbox:insert_mtf(v .. "\n", rank)
          end
        end
      end
    end
  end
  btn.var:set("flag", 1)
end
function clear_log_list(log_name)
  local this_panel = g_log_deal:search(log_name)
  if this_panel ~= nil then
    local this_richbox = this_panel:search("log_box")
    this_richbox:item_clear()
  end
end
function on_click_deallog(ctrl)
  local vis = g_log_deal.visible
  g_log_deal.visible = not vis
  if vis == true then
    return
  end
  local w = ui.find_control("$frame:item")
  g_log_deal.dy = w.dy
  g_log_deal.dock = w.dock
  g_log_deal.margin = ui.rect(w.margin.x1, w.margin.y1, w.margin.x2 + w.dx, w.margin.y2)
  local btn = ui_tab.get_button(g_log_deal, "deal_log")
  btn.var:set("flag", 0)
  btn = ui_tab.get_button(g_log_deal, "stall_log")
  btn.var:set("flag", 0)
  clear_log_list(L("deal_log"))
  clear_log_list(L("stall_log"))
  ui_tab.show_page(g_log_deal, "deal_log", true)
  update_show_deal()
end
function wide_update()
  if not sys.check(w_item) then
    return
  end
  local sz = 8
  if ui_setting.ui_game.cfg_def.wide_item_box.value == L("1") then
    sz = 12
    w_wide_btn.check = false
  else
    w_wide_btn.check = true
  end
  if sz == c_box_size_x then
    return
  end
  c_box_size_x = sz
  for n, box_data in pairs(g_boxs) do
    box_update(box_data)
  end
end
function on_click_wide_box(btn)
  local cfg
  if c_box_size_x == 8 then
    cfg = L("1")
  else
    cfg = L("0")
  end
  ui_setting.ui_game.save_single_config("wide_item_box", cfg)
  wide_update()
end
function on_tab_btn(btn)
  local idx = btn.var:get("index").v_int
  local flag = btn.var:get("flag").v_int
  if idx == 1 then
    update_show_deal()
  elseif idx == 2 then
    update_show_stall()
  end
end
function CreateShelfPages(main_win)
  ui_tab.clear_tab_data(main_win)
  local styurl = "$frame/item/log_deal.xml"
  local pages = {
    {
      name = "deal_log",
      txt = ui.get_text("item|deal_log")
    },
    {
      name = "stall_log",
      txt = ui.get_text("item|stall_log")
    }
  }
  for _i, v in ipairs(pages) do
    ui_tab.insert_suit(main_win, v.name, styurl, "tab_button", styurl, v.name)
    local btn = ui_tab.get_button(main_win, v.name)
    btn.text = v.txt
    btn.var:set("index", _i)
    btn.var:set("flag", 0)
    btn:insert_on_click(on_tab_btn, "ui_item.on_tab_btn")
  end
end
function on_logdeal_init(ctrl)
  CreateShelfPages(ctrl)
  ui_tab.get_page(ctrl, "deal_log")
  ui_tab.get_page(ctrl, "stall_log")
  ui_tab.show_page(ctrl, "deal_log", true)
end
function on_common_close(ctrl)
  set_visible(false)
  local main_ctl = ctrl.parent
  if main_ctl ~= nil then
  end
end
function set_bag_item_flag(visible)
  ui.item_mark_show("account_bank", visible)
end
function handleBagItemImageFlag(cmd, data)
  function do_update()
    if ui_account_bank.get_visible() then
      set_bag_item_flag(true)
    else
      set_bag_item_flag(false)
    end
  end
  w_list:insert_post_invoke(do_update, "ui_item.do_update")
  if ui_item.w_item.visible then
    enable_all_item_flicker()
  end
end
function on_flash_timer(t)
  local owner = t.owner
  if sys.dtick(sys.tick(), owner.svar.tick) > 10000 then
    owner.visible = false
  end
end
local flash_post_remove = function()
  w_flash_timer_post.suspended = true
  ui.remove_on_item_gain("ui_item.on_flash_gain")
end
function on_flash_timer_post(t)
  local owner = t.owner
  local svar = owner.svar
  if svar.post_tick == nil then
    flash_post_remove()
    return
  end
  if sys.dtick(sys.tick(), svar.post_tick) > 5000 then
    svar.post_tick = nil
    flash_post_remove()
  end
end
function card_flash_view()
  local view = rawget(_M, "w_flash")
  if not sys.check(view) then
    view = ui.create_control(ui_main.w_top, "animation_view")
    view:load_style("$frame/item/item.xml", "item_flash32")
    w_flash = view
  end
  return view
end
function show_card_flash(card)
  if not sys.check(card) or not card.observable then
    return
  end
  local view = card_flash_view()
  local pt = card:control_to_window(ui.point(card.dx * 0.5, card.dy * 0.5))
  pt = ui.point(pt.x - view.dx * 0.5, pt.y - view.dy * 0.5)
  view.svar.tick = sys.tick()
  view.offset = pt
  view.visible = true
  view:reset()
end
function post_card_flash(card)
  local view = card_flash_view()
  w_flash_timer_post.suspended = false
  local function on_flash_gain(info, cnt)
    if cnt <= 0 then
      return
    end
    if not sys.check(card) or not card.observable then
      flash_post_remove()
      return
    end
    if card.excel_id ~= info.excel_id then
      return
    end
    local box = info.box
    if box >= bo2.eItemBox_Bank then
      return
    end
    local bd = g_boxs[box]
    if bd == nil then
      return
    end
    local cell = bd.cells[info.grid]
    if cell == nil then
      return
    end
    flash_post_remove()
    show_card_flash(cell.card)
  end
  local svar = view.svar
  svar.post_tick = sys.tick()
  ui.insert_on_item_gain(on_flash_gain, "ui_item.on_flash_gain")
end
function on_item_box_ext(obj)
  local basic = ui_widget.get_define_int(249)
  local limit = ui_widget.get_define_int(250)
  local count = basic + obj:get_flag_int8(bo2.ePlayerFlagInt8_ItemBoxExt)
  for grid = basic + 1, limit do
    local slot = g_slots[grid]
    local bg_lock = slot.bg_lock
    if grid <= limit and grid <= count then
      if bg_lock.visible and w_item.visible then
        show_card_flash(slot.card)
      end
      bg_lock.visible = false
    else
      bg_lock.visible = true
    end
    slot.card.parent.visible = true
  end
  for grid = limit + 1, 7 do
    local slot = g_slots[grid]
    slot.card.parent.visible = false
  end
end
function find_item_card(index)
  local box = math.floor(index / 256)
  local box_data = g_boxs[box]
  if box_data == nil then
    return nil
  end
  local grid = index % 256
  local cell = box_data.cells[grid]
  if cell == nil then
    return nil
  end
  local card = cell.card
  return card
end
function on_item_box_extend(cmd, data)
  local w_item = ui_item.w_item
  if not w_item.visible then
    return
  end
  w_item:move_to_head()
  ui.log("on_item_box_extend")
  local box = data[packet.key.item_box]
  local size_all = data[packet.key.item_count]
  local orig_size = size_all % 256
  local ext_size = math.floor(size_all / 256)
  local count = ext_size - orig_size
  if count < 1 then
    return
  end
  local source = find_item_card(data[packet.key.itemdata_idx])
  if source == nil then
    return
  end
  local anim_tick = sys.tick()
  local source_dx = source.dx
  local source_size = source.size
  local angle_min = -30
  local angle_max = -90
  local radius_min = source_dx * 1.25
  local radius_max = source_dx * 1.85
  local count_max = 8
  local factor = 1
  if count < count_max then
    factor = (count - 1) / (count_max - 1)
  end
  local angle = 0
  local angle_step = 0
  if count > 1 then
    angle = angle_min + (angle_max - angle_min) * factor
    angle_step = 2 * angle / (count - 1)
  end
  local radius = radius_min + (radius_max - radius_min) * factor
  local origin = ui.point(0, radius)
  local scale1 = ui.point(1.5, 1.5)
  local scale2 = ui.point(2.4, 2.4)
  local origin2 = ui.point(0, radius - source_dx * 0.65)
  local time1 = 800
  local box_data = g_boxs[box]
  if box_data == nil then
    return nil
  end
  local tool = ui_qbar.ui_animation.w_tool
  local excel_id = data[packet.key.item_excelid]
  local card = tool:inner_create("card_item")
  card.excel_id = excel_id
  card:set_count_mode("none")
  card.size = source_size
  local pic_lock = tool:inner_create("picture")
  pic_lock.image = "$image/skill/skill_show/icon_lock.png|0,0,42,51"
  pic_lock.size = ui.point(42, 51)
  local p1 = tool:inner_create("picture")
  p1.image = "$image/skill/skill_show/icon_lock_frag1.png|0,10,38,41"
  p1.size = ui.point(38, 41)
  local p2 = tool:inner_create("picture")
  p2.image = "$image/skill/skill_show/icon_lock_frag2.png|2,0,38,45"
  p2.size = ui.point(38, 41)
  local p3 = tool:inner_create("picture")
  p3.image = "$image/skill/skill_show/blade_track.png|0,0,48,48"
  p3.size = ui.point(48, 48)
  local p1_offset = ui.point(-1, 6)
  local p2_offset = ui.point(1, -6)
  local p3_offset = ui.point(0, 2)
  local p1_dest = ui.point(-5, 90)
  local p2_dest = ui.point(5, 65)
  local function make_animation(target, time)
    anim = tool:animation_create(anim_tick)
    local f = anim:frame_create(time1, card, source)
    f = anim:frame_create(200, card, source)
    f.origin = origin
    f.rotate = angle
    f.scale = scale1
    f = anim:frame_create(200, card, source)
    f.origin = origin2
    f.rotate = angle
    f.scale = scale2
    f = anim:frame_create(time, card, source)
    f.origin = origin
    f.rotate = angle
    f.scale = scale1
    f = anim:frame_create(100, card, target)
    f.scale = target.size / card.size
    local cycle = anim.cycle
    local anim2 = tool:animation_create(anim_tick)
    local f2 = anim2:frame_create(cycle, pic_lock, target)
    local anim_p1 = tool:animation_create(anim_tick)
    anim_p1.delay = cycle
    local f1 = anim_p1:frame_create(1200, p1, target)
    f1.offset = p1_offset
    f1 = anim_p1:frame_create(1500, p1, target)
    f1.offset = p1_offset
    f1 = anim_p1:frame_create(300, p1, target)
    f1.offset = p1_dest
    f1.rotate = 45
    anim_p1:frame_fadeout()
    local anim_p2 = tool:animation_create(anim_tick)
    anim_p2.delay = cycle
    local f2 = anim_p2:frame_create(1500, p2, target)
    f2.offset = p2_offset
    f2 = anim_p2:frame_create(1500, p2, target)
    f2.offset = p2_offset
    f2 = anim_p2:frame_create(300, p2, target)
    f2.offset = p2_dest
    f2.rotate = -10
    anim_p2:frame_fadeout()
    local anim_p3 = tool:animation_create(anim_tick)
    anim_p3.delay = cycle
    local f3 = anim_p3:frame_create(200, p3, target)
    f3.offset = p3_offset
    f3 = anim_p3:frame_create(200, p3, target)
    f3.offset = p3_offset
    f3.scale = ui.point(1.2, 1.2)
    f3 = anim_p3:frame_create(500, p3, target)
    f3.offset = p3_offset
    f3 = anim_p3:frame_create(500, p3, target)
    f3.offset = p3_offset
    anim_p3:frame_fadeout()
    angle = angle - angle_step
  end
  local time = 1000
  for grid = orig_size, ext_size - 1 do
    cell = box_data.cells[grid]
    if cell ~= nil then
      make_animation(cell.card, time)
      time = time + 800
    end
  end
end
function test_ext()
  local data = sys.variant()
  data[packet.key.item_box] = 8
  data[packet.key.item_excelid] = 50088
  data[packet.key.item_count] = 5136
  data[packet.key.itemdata_idx] = 13
  on_item_box_extend(nil, data)
end
function on_self_daibi(obj, ft, idx)
  local c = obj:get_flag_int32(bo2.ePlayerFlagInt32_MoneyDaibi)
  w_daibi.mtf = sys.format("<a+:r>%s<daibi:18><a->", c)
end
function on_make_tip_daibi(tip)
  local player = bo2.player
  if player ~= nil then
    local levelup = bo2.gv_player_levelup:find(player:get_atb(bo2.eAtb_Level))
    if levelup ~= nil then
      m = levelup.max_daibi
    end
  end
  local t = sys.format([[

%s
%d<daibi:18>]], ui.get_text("widget|money_carry_limit"), m)
  ui_widget.tip_make_view(tip.view, ui.get_text("widget|daibi_tip") .. t)
end
function on_self_enter(obj, msg)
  if ui_handson_teach.is_in_mstone(ui_handson_teach.g_ei_quest_id, ui_handson_teach.g_ei_mstone_id) then
  end
  obj:insert_on_flagmsg(bo2.eFlagType_Int8, bo2.ePlayerFlagInt8_ItemBoxExt, "ui_item.on_item_box_ext", "ui_item.on_item_box_ext")
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_MoneyDaibi, on_self_daibi, "ui_item.on_self_daibi")
  on_item_box_ext(obj)
  on_self_daibi(obj, ft, idx)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_item.packet_handle"
reg(packet.eSTC_BagItemImageFlag, handleBagItemImageFlag, sig)
reg(packet.eSTC_UI_BoxExtend, function(cmd, data)
  w_item:insert_post_invoke(function()
    on_item_box_extend(cmd, data)
  end, "ui_item.on_item_box_extend")
end, sig)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_item.on_self_enter")
