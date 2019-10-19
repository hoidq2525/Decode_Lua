local puzzle_long_txt = {
  [1] = 2189,
  [11] = 2190,
  [10] = 2186,
  [12] = 2192,
  [2] = 2187,
  [22] = 2193,
  [20] = 2188,
  [21] = 2191
}
local puzzle_length = {
  [1] = bo2.gv_define:find(984).value.v_int,
  [2] = bo2.gv_define:find(985).value.v_int,
  [3] = bo2.gv_define:find(986).value.v_int,
  [4] = bo2.gv_define:find(987).value.v_int
}
local puzzle_timer = false
function init_once()
  if rawget(_M, "g_already_init") ~= nil then
    return
  end
  g_already_init = true
  t_rbutton_data = {}
end
function insert_rbutton_data(w, check, use, tip)
  local d = {
    name = w.name,
    widget = w,
    check = check,
    use = use,
    tip = tip
  }
  t_rbutton_data[d.name] = d
end
function search_rbutton_data(info)
  local h = ui_phase.w_main.control_head
  while h ~= nil do
    if h.visible then
      local d = t_rbutton_data[h.name]
      if d ~= nil and d.check(info) then
        return d
      end
    end
    h = h.next
  end
  return t_rbutton_data[L("$frame:personal")]
end
function use_tip(info)
  local d = search_rbutton_data(info)
  if d == nil then
    return nil
  end
  return d.tip(info)
end
local is_inner = sys.is_file("$cfg/tool/pix_dj2_config.xml")
local USE_LIMIT_XIULIAN = 2
function use_item(info, is_shortcut)
  if info.lock > 0 then
    return
  end
  local excel = info.excel
  if excel == nil then
    local box = info.box
    if box == bo2.eItemArray_InSlot then
      do
        local grid = info.grid
        if check_box_need_open(grid) then
          stk:merge({
            n = grid,
            m = sys.format("<bm:%d>", ui_widget.get_define_int(250 + grid))
          }, ui.get_text("item|item_box_ext_price"))
          ui_widget.ui_msg_box.show_common({
            text = stk.text,
            btn_confirm = true,
            btn_cancel = true,
            callback = function(msg)
              if msg.result == 1 then
                bo2.send_variant(packet.eCTS_UI_ItemBoxExtOpen, grid)
              end
            end
          })
        end
      end
    end
    return
  end
  local box = info.box
  local ptype = excel.ptype
  local puse = excel.iuse
  if puse ~= nil and puse.use_limit == USE_LIMIT_XIULIAN then
    return
  end
  if box == bo2.eItemArray_InSlot then
    local grid = info.grid
    if grid >= bo2.eItemSlot_BagBeg and grid < bo2.eItemSlot_BagEnd then
      local box = bo2.eItemBox_BagBeg + grid - bo2.eItemSlot_BagBeg
      local box_data = g_boxs[box]
      if box_data ~= nil then
        box_data.expanded = not box_data.expanded
        box_update(box_data)
      end
    elseif grid >= bo2.eItemSlot_EquipBeg and grid < bo2.eItemSlot_AvataEnd then
      send_unequip(info.only_id, bo2.eItemBox_BagEnd, 0)
    elseif grid >= bo2.eItemSlot_HunskillBegin and grid <= bo2.eItemSlot_HunskillEnd then
      local function on_btn_msg(msg)
        if msg.result == 1 then
          send_unequip(info.only_id, bo2.eItemBox_BagEnd, 0)
        end
      end
      local arg = sys.variant()
      arg:clear()
      arg:set("item_id", info.excel_id)
      local msg = {
        callback = on_btn_msg,
        btn_confirm = true,
        btn_cancel = true,
        modal = true
      }
      msg.text = sys.mtf_merge(arg, ui.get_text("skill|hunskill_bachu_confirm_info"))
      ui_widget.ui_msg_box.show_common(msg)
    end
  elseif box >= bo2.eItemBox_RidePetBegin and box < bo2.eItemBox_RidePetEnd then
    ui_ridepet.send_ride_unequip(info.only_id)
    return
  elseif box >= bo2.eItemBox_BagBeg and box <= bo2.eItemBox_Quest then
    if sys.check(is_shortcut) then
      use_item_bag(info)
    else
      local d = search_rbutton_data(info)
      if d == nil then
        return nil
      end
      d.use(info)
    end
  elseif box >= bo2.eItemBox_StarStoneBegin and box <= bo2.eItemBox_StarStoneEnd then
    send_unequip_starstone(info.only_id, bo2.eItemBox_BagEnd, 0)
  end
end
function use_item_bag(info)
  local excel = info.excel
  local ptype = excel.ptype
  if ptype ~= nil then
    local group = ptype.group
    if group == bo2.eItemGroup_Equip or group == bo2.eItemGroup_Bag or group == bo2.eItemGroup_Avata then
      local identify_type = info:get_identify_state()
      if identify_type == bo2.eIdentifyEquip_Ready or identify_type == bo2.eIdentifyEquip_Countine then
        local equip_excel = bo2.gv_equip_item:find(excel.id)
        local money = 0
        if equip_excel ~= nil then
          for i = 0, bo2.gv_identify_price.size - 1 do
            local pprice = bo2.gv_identify_price:get(i)
            if pprice ~= nil and pprice.level >= equip_excel.reqlevel then
              money = money + pprice.money
              break
            end
          end
          for i = 0, bo2.gv_identify_price_star.size - 1 do
            local pprice = bo2.gv_identify_price_star:get(i)
            if pprice ~= nil and pprice.level >= equip_excel.lootlevel then
              money = money + pprice.money
              break
            end
          end
        end
        if equip_excel ~= nil then
          local msg_text = ui.get_text("npcfunc|identify_type_notice")
          local warning_text = L("")
          local cur_money = bo2.player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
          if money > cur_money then
            warning_text = ui_widget.merge_mtf({
              money = money,
              bmmoney = cur_money,
              mmoney = money - cur_money
            }, ui.get_text("npcfunc|not_enough_money_warning"))
          end
          msg_text = msg_text .. warning_text
          local msg = {
            text = ui_widget.merge_mtf({money = money}, msg_text),
            modal = true,
            btn_confirm = true,
            btn_cancel = true,
            callback = function(msg)
              if msg.result == 1 then
                local v = sys.variant()
                v:set(packet.key.item_key, info.only_id)
                bo2.send_variant(packet.eCTS_UI_IdentifyEquip, v)
                bo2.PlaySound2D(559)
                return
              else
                return
              end
            end
          }
          ui_widget.ui_msg_box.show_common(msg)
        end
      elseif ptype.equip_slot >= bo2.eItemSlot_RidePetBegin and ptype.equip_slot < bo2.eItemSlot_RidePetEnd then
        ui_ridepet.send_ride_equip(info)
      else
        if ptype.id >= bo2.eItemType_HunskillHead and ptype.id <= bo2.eItemType_HunskillRFeet then
          return
        end
        send_equip(info, 255)
        ui_tempshortcut.on_gain_item_event(info, false)
        return
      end
    end
    if group == bo2.eItemGroup_Book then
      if excel.type == bo2.eItemType_EmptySeriesBook then
        local create_book = function(msg)
          if msg.result == 0 then
            return
          end
          bo2.send_variant(packet.eCTS_ScnObj_LineageSeriesBook, msg.data)
        end
        local msg = {
          style_uri = "$frame/skill/lianzhao.xml",
          style_name = "lianzhao_msg_box",
          callback = ui_lianzhao.create_new_book,
          modal = false
        }
        msg.title = ui.get_text("item|blank_lianzhao_msg_box_title")
        msg.text = ui.get_text("skill|blank_lianzhao_msg_box")
        msg.text_confirm = ui.get_text("skill|generate_lianzhao_book")
        ui_widget.ui_msg_box.show_common(msg)
      end
    elseif group == bo2.eItemGroup_Soul and excel.type == bo2.eItemType_Soul then
      ui_item.ui_imprint.gx_window.visible = not ui_item.ui_imprint.gx_window.visible
    end
  end
  if excel.id == 56900 then
    if bo2.player:get_qwordtemp(bo2.ePFlagQwordTemp_GuildTempBattle) ~= L("0") then
      ui_chat.show_ui_text_id(70480)
      return
    end
    ui_guild_mod.ui_guild_search.set_win_open(3)
    return
  end
  if excel.id == 66323 then
    ui_item_card.show(info)
    return
  end
  if ui_item_compose.try_compose(info) then
    return
  end
  local puse = excel.iuse
  if puse == nil then
    return
  end
  if 0 < puse.dst_item_type.size then
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_useto)
    data:set64("only_id", info.only_id)
    if puse.model == bo2.eUseMod_IdentifyEquip then
      ui.setup_drop(ui_tool.w_ident_floater, data)
      if ui_handson_teach.is_in_mstone(ui_handson_teach.g_ei_quest_id, ui_handson_teach.g_ei_mstone_id) and info.excel_id == ui_handson_teach.g_ei_item_id then
        ui_handson_teach.test_complate_equipidentify_action2(true)
      end
    elseif puse.model == bo2.eUseMod_ResetEquipMaxWearout or puse.model == bo2.eUseMod_EquipReleaseSeal then
      ui.setup_drop(ui_tool.w_ident_floater, data)
    elseif puse.model == bo2.eUseMod_EquipReleaseBound then
      data:set("drop_type", ui_widget.c_drop_type_seal)
      ui.setup_drop(ui_tool.w_ident_floater, data)
    elseif puse.model == bo2.eUseMod_SecondWeaponMultiExp then
      ui.setup_drop(ui_tool.w_ident_floater, data)
    elseif puse.model == bo2.eUseMod_PunchEquip then
      data:set("drop_type", ui_widget.c_drop_type_punch)
      data:set("excel_id", info.excel_id)
      ui.setup_drop(ui_tool.w_ident_floater, data)
    elseif puse.model == bo2.eUseMod_InlayGem or puse.model == bo2.eUseMod_EquipResolve then
      data:set("drop_type", ui_widget.c_drop_type_gem_inlay)
      data:set("excel_id", info.excel_id)
      ui.setup_drop(ui_tool.w_ident_floater, data)
    elseif puse.model == bo2.eUseMod_BlessStarStone then
      ui.setup_drop(ui_tool.w_ident_floater, data)
    else
      ui.setup_drop(ui_tool.w_ident_floater, data)
    end
  elseif puse.model == bo2.eUseMod_PetToy then
    local data = sys.variant()
    data:set64(packet.key.item_key, info.only_id)
    ui_pet.ui_pet_list.show_pet_list(ui_item.send_use_toy, data)
  elseif puse.model == bo2.eUseMod_TranslatePotentialPoint then
    local data = sys.variant()
    data:set64(packet.key.item_key, info.only_id)
    ui_pet.ui_pet_list.show_pet_list(ui_pet.send_tanslate_potential_point, data)
  elseif puse.model == bo2.eUseMod_AddPet then
    local excel = info.excel
    local level = bo2.gv_pet_list:find(excel.use_par[0]).take_level
    if level > bo2.player:get_atb(bo2.eAtb_Level) then
      ui_tool.note_insert(ui.get_text("pet|pet_add_warning"), "FFFF0000")
    else
      send_use(info)
    end
  elseif puse.model == bo2.eUseMod_PetExpDrug then
    local data = sys.variant()
    data:set64(packet.key.item_key, info.only_id)
    ui_pet.ui_pet_list.show_pet_list(ui_item.send_use_petexp, data)
  elseif puse.model == bo2.eUseMod_SkillChg then
    local cid = excel.use_par[0]
    local sc = bo2.gv_skill_change:find(cid)
    local oldId = bo2.CheckSkillChg(sc)
    if oldId > 0 then
      local skillName1 = bo2.gv_skill_group:find(oldId).name
      local skillName2 = bo2.gv_skill_group:find(sc.skillId).name
      ui_widget.ui_msg_box.show_common({
        text = sys.format(ui.get_text("skill|skill_chg_ask"), skillName1, skillName2),
        modal = true,
        btn_confirm = true,
        btn_cancel = true,
        callback = function(msg)
          if msg.result == 1 then
            send_use(info)
          end
        end
      })
      return
    end
    if oldId == -1 then
      ui_safe.notify(73011)
    elseif oldId == -2 then
      ui_safe.notify(73012)
    elseif oldId == -3 then
      ui_safe.notify(76004)
    else
      ui_safe.notify(73013)
    end
  elseif puse.model == bo2.eUseMod_Martingale then
    local cId = excel.use_par[0]
    local sc = bo2.gv_martingale:find(cId)
    local rt = bo2.CheckUseZhanfa(sc)
    if rt > 0 then
      ui_widget.ui_msg_box.show_common({
        text = sys.format(ui.get_text("skill|zhanfa_use"), sc.use_money),
        modal = true,
        btn_confirm = true,
        btn_cancel = true,
        callback = function(msg)
          if msg.result == 1 then
            send_use(info)
          end
        end
      })
      return
    end
    if rt == -1 then
      ui_safe.notify(73011)
    elseif rt == -2 then
      ui_safe.notify(73012)
    elseif rt == -3 then
      ui_safe.notify(76004)
    else
      ui_safe.notify(73014)
    end
  elseif puse.model == bo2.eUseMod_RidePetTransfer then
    ui_widget.ui_msg_box.show_common({
      text = ui.get_text("pet|ridepet_transfer_confirm"),
      modal = true,
      btn_confirm = true,
      btn_cancel = true,
      callback = function(msg)
        if msg.result == 1 then
          send_use(info)
        end
      end
    })
  elseif puse.model == bo2.euseMod_AddRideFreeSkillPoint then
    ui_widget.ui_msg_box.show_common({
      text = ui_widget.merge_mtf({
        item_id = excel.id
      }, ui.get_text("pet|ridepet_addridefreeskillpoint")),
      modal = true,
      btn_confirm = true,
      btn_cancel = true,
      callback = function(msg)
        if msg.result == 1 then
          send_use(info)
        end
      end
    })
  elseif puse.model == bo2.eUseMod_Clear_Refine then
    ui_widget.ui_msg_box.show_common({
      text = ui_widget.merge_mtf({
        item_id = excel.id
      }, ui.get_text("pet|ridepet_clearrefine")),
      modal = true,
      btn_confirm = true,
      btn_cancel = true,
      callback = function(msg)
        if msg.result == 1 then
          send_use(info)
        end
      end
    })
  elseif puse.model == bo2.eUseMod_AddPlayerNQ then
    send_use(info)
  elseif puse.model == bo2.eUseMod_Change_GuildBanner_Type then
    ui_guild_mod.ui_guild_banner.handChange_GuildBanner_Type(info)
  elseif puse.model == bo2.eUseMod_CleanRideIdentify then
    ui_widget.ui_msg_box.show_common({
      text = ui_widget.merge_mtf({
        item_id = excel.id
      }, ui.get_text("pet|ridepet_cleanrideidentify")),
      modal = true,
      btn_confirm = true,
      btn_cancel = true,
      callback = function(msg)
        if msg.result == 1 then
          send_use(info)
        end
      end
    })
  elseif puse.model == bo2.eUseMod_AddRidePotential then
    ui_widget.ui_msg_box.show_common({
      text = ui_widget.merge_mtf({
        item_id = excel.id
      }, ui.get_text("pet|ridepet_addridepotential")),
      modal = true,
      btn_confirm = true,
      btn_cancel = true,
      callback = function(msg)
        if msg.result == 1 then
          send_use(info)
        end
      end
    })
  elseif puse.model == bo2.eUseMod_CleanRideSkillPoint then
    ui_widget.ui_msg_box.show_common({
      text = ui_widget.merge_mtf({
        item_id = excel.id
      }, ui.get_text("pet|ridepet_cleanrideskillpoint")),
      modal = true,
      btn_confirm = true,
      btn_cancel = true,
      callback = function(msg)
        if msg.result == 1 then
          send_use(info)
        end
      end
    })
  elseif puse.model == bo2.eUseMod_ClientTrans then
    ui_npcfunc.ui_markpos.show_transport(info)
  elseif excel.type == bo2.eItemType_TransPos then
    ui_npcfunc.ui_markpos.show(info)
  elseif puse.model == bo2.eUseMod_ViewBattleList then
    ui_npcfunc.ui_battle_list.show_window(info)
    send_use(info)
  elseif puse.model == bo2.eUseMod_ChgCamp then
    do
      local sig = "eUseMod_ChgCamp.packet_handle"
      local function on_rst(cmd, rst)
        local c_text
        if rst:has(packet.key.cmn_type) then
          c_text = ui.get_text("item|chgcamp_reduce")
        else
          c_text = ui.get_text("item|chgcamp")
        end
        ui_widget.ui_msg_box.show_common({
          text = c_text,
          modal = true,
          btn_confirm = true,
          btn_cancel = true,
          callback = function(msg)
            if msg.result == 1 then
              send_use(info)
            end
          end
        })
        ui_packet.game_recv_signal_remove(packet.eSTC_UI_CampReputeInfoRst, sig)
      end
      local v = sys.variant()
      bo2.send_variant(packet.eCTS_UI_CampReputeInfo, v)
      ui_packet.game_recv_signal_insert(packet.eSTC_UI_CampReputeInfoRst, on_rst, sig)
    end
  elseif puse.model == bo2.eUseMod_Ride then
    if not bo2.player:enable_ride() then
      return
    end
    send_use(info)
  elseif puse.model == bo2.eUseMod_UseSkill then
    if excel.use_par.size == 0 then
      return
    end
    if bo2.IsFixPointSkill(excel.use_par[0]) then
      bo2.ItemFixPointSkill(info.only_id)
      return
    end
    send_use(info)
  elseif puse.model == bo2.eUseMod_Polymorph then
    ui_npcfunc.ui_markpos.show_polymorph(info)
  elseif puse.model == bo2.eUseMod_Lottery then
    ui_item_lottery.show(info)
  elseif puse.model == bo2.eUseMod_Model then
    ui_item_model.show(info)
  elseif puse.model == bo2.eUseMod_Rose then
    ui_item_rose.show(info)
  elseif puse.model == bo2.eUseMod_SecondWeapon_Exp then
    ui_item_secondweapon_exp.show(info)
  elseif puse.model == bo2.eUseMod_EquipModel then
    ui_item_equip_model.show(info)
  elseif puse.model == bo2.eUseMod_EquipModelRecover then
    ui_item_equip_model.show_recover(info)
  elseif puse.model == bo2.eUseMod_NeedBJade then
    do
      local id = excel.id
      local line = bo2.gv_item_list:find(id)
      if line == nil then
        return
      end
      local size = line.use_par.size
      if size == 0 then
        return
      end
      local money = line.use_par[0]
      ui_widget.ui_msg_box.show_common({
        text = ui_widget.merge_mtf({money = money}, ui.get_text("common|item_use_bjade")),
        modal = true,
        btn_confirm = true,
        btn_cancel = true,
        callback = function(msg)
          if msg.result == 1 then
            local function send_use_bjade()
              send_use(info)
            end
            ui_supermarket2.shelf_prepareJade(money, send_use_bjade)
          end
        end
      })
    end
  elseif puse.model == bo2.eUseMod_BoundGemChips then
    local confirm = false
    local size = excel.use_par.size
    if size >= 6 then
      local req_count = excel.use_par[0]
      local bagc = ui.item_get_count(excel.id, true)
      if req_count > bagc then
        local bound_excel_id = excel.use_par[5]
        local bound_count = ui.item_get_count(excel.use_par[5], true)
        if bound_count >= req_count - bagc then
          local mtf = {
            item_name = sys.format(L("<i:%d>"), bound_excel_id),
            item_count = req_count - bagc
          }
          local text_show = ui_widget.merge_mtf(mtf, ui.get_text("item|leak_of_item"))
          local function on_msg_callback(msg_call)
            if msg_call.result ~= 1 then
              return
            end
            send_use(info)
          end
          confirm = true
          local msg = {callback = on_msg_callback, text = text_show}
          ui_widget.ui_msg_box.show_common(msg)
        end
      end
    end
    if confirm ~= true then
      send_use(info)
    end
  elseif puse.model == bo2.eUseMod_AvataChips then
    local confirm = false
    local size = excel.use_par.size
    if size >= 4 then
      local req_count = excel.use_par[0]
      local bagc = ui.item_get_count(excel.id, true)
      if req_count > bagc then
        local bound_excel_id = excel.use_par[3]
        local bound_count = ui.item_get_count(excel.use_par[3], true)
        if bound_count >= req_count - bagc then
          local mtf = {
            item_name = sys.format(L("<i:%d>"), bound_excel_id),
            item_count = req_count - bagc
          }
          local text_show = ui_widget.merge_mtf(mtf, ui.get_text("item|leak_of_item"))
          local function on_msg_callback(msg_call)
            if msg_call.result ~= 1 then
              return
            end
            send_use(info)
          end
          confirm = true
          local msg = {callback = on_msg_callback, text = text_show}
          ui_widget.ui_msg_box.show_common(msg)
        end
      end
    end
    if confirm ~= true then
      send_use(info)
    end
  elseif puse.model == bo2.eUseMod_ShowTextBook then
    local arr_par = excel.use_par
    if arr_par.size == 0 then
      ui.log("ERROR!!!!PLEASE INPUT use_par!!!!")
      return
    end
    ui_text_book.show_text_book(arr_par[0])
    send_use(info)
  elseif puse.model == bo2.eUseMod_BoundMatCombine then
    local req_cnt = excel.use_par[0]
    local mat_bd_id, mat_bd_cnt, mat_cir_id, mat_cir_cnt = ui_npcfunc.ui_cmn.consume_bound_mat(excel.variety, excel.varlevel, req_cnt)
    if excel.bound_mode ~= 0 and mat_cir_cnt > 0 then
      local function on_msg_callback(msg_call)
        if msg_call.result ~= 1 then
          return
        end
        send_use(info)
      end
      local bd_excel = ui.item_get_excel(mat_bd_id)
      local cir_excel = ui.item_get_excel(mat_cir_id)
      local tb_param = {
        bd_item = bd_excel.id,
        cir_num = mat_cir_cnt,
        cir_item = cir_excel.id
      }
      local text_model = ui.get_text("npcfunc|refine_bd_msg")
      local text_show = ui_widget.merge_mtf(tb_param, text_model)
      local msg = {callback = on_msg_callback, text = text_show}
      ui_widget.ui_msg_box.show_common(msg)
    else
      send_use(info)
    end
  elseif puse.model == bo2.eUseMod_MatRand then
    local pItemRand = bo2.gv_item_rand:find(excel.use_par[1])
    for i = 0, 9 do
      local item_id = pItemRand.drop_id[i][0]
      if item_id ~= 0 then
        local item_excl = ui.item_get_excel(item_id)
        local item_max_count = item_excl.consume_par
        local raw_bd_cnt = ui.item_get_count(item_id, true)
        if item_max_count <= raw_bd_cnt then
          local tb_param1 = {item = item_id}
          local text_model1 = ui.get_text("npcfunc|exceeds_item_maximum")
          local txt_result1 = ui_widget.merge_mtf(tb_param1, text_model1)
          ui_tool.note_insert(txt_result1, "FF0000")
          return
        end
      end
    end
    if excel.use_par.size == 2 then
      send_use(info)
    elseif excel.use_par.size == 3 then
      local req_cnt = excel.use_par[0]
      local bd_id = excel.id
      local cir_id = excel.use_par[2]
      local bd_cnt_in_bag = ui.item_get_count(bd_id, true)
      local cir_cnt_in_bag = ui.item_get_count(cir_id, true)
      local bd_cnt = 0
      local cir_cnt = 0
      if req_cnt > bd_cnt_in_bag then
        bd_cnt = bd_cnt_in_bag
        cir_cnt = req_cnt - bd_cnt
        local function on_msg_callback(msg_call)
          if msg_call.result ~= 1 then
            return
          end
          send_use(info)
        end
        local cir_excel = ui.item_get_excel(cir_id)
        local tb_param = {
          bd_item = excel.id,
          cir_num = cir_cnt,
          cir_item = cir_excel.id
        }
        local text_model = ui.get_text("npcfunc|refine_bd_msg")
        local text_show = ui_widget.merge_mtf(tb_param, text_model)
        local msg = {callback = on_msg_callback, text = text_show}
        ui_widget.ui_msg_box.show_common(msg)
      else
        send_use(info)
      end
    end
  elseif puse.model == bo2.eUseMod_BoxExtend then
    local use_par = excel.use_par
    local box = use_par[0]
    local count = g_boxs[box].count
    for j = 1, use_par.size - 2, 2 do
      local box_item = ui.item_get_excel(use_par[j])
      if box_item ~= nil then
        local par = box_item.use_par
        if 0 < par.size then
          local size = par[0]
          if count < size then
            if info.count < use_par[j + 1] then
              ui_chat.show_ui_text_id(10110, {
                item_name = sys.format("<i:%d>", excel.id)
              })
            else
              send_use(info)
            end
            return
          end
        end
      end
    end
    ui_tool.note_insert(ui_widget.merge_mtf({
      box = ui.get_text("item|slot" .. box)
    }, ui.get_text("box_extend|box_limit")), "FF0000")
  elseif puse.model == bo2.eUseMod_BoxExtend2 then
    send_use(info)
  elseif puse.model == bo2.eUseMod_NewBankExtend then
    local function on_msg_callback(msg_call)
      if msg_call.result ~= 1 then
        return
      end
      send_use(info)
    end
    local id = excel.id
    local line = bo2.gv_item_list:find(id)
    if line == nil then
      return
    end
    local size = line.use_par.size
    if size == 0 then
      return
    end
    local count = line.use_par[0]
    local item_max = line.use_par[1]
    local sys_max = bo2.gv_define:find(1240).value.v_int
    local cur_size = bo2.get_newbank_cur_size()
    local text_show
    if cur_size == sys_max then
      ui_tool.note_insert(ui.get_text("bank|newbank_limite3"), ui_bank.c_warninig_color)
      return
    elseif cur_size == item_max then
      ui_tool.note_insert(ui.get_text("bank|newbank_limite4"), ui_bank.c_warninig_color)
      return
    elseif item_max < cur_size + count then
      local v = sys.variant()
      v:set("limite", item_max)
      text_show = sys.mtf_merge(v, ui.get_text("bank|newbank_limite2"))
    elseif sys_max < cur_size + count then
      local v = sys.variant()
      v:set("limite", sys_max)
      text_show = sys.mtf_merge(v, ui.get_text("bank|newbank_limite2"))
    else
      send_use(info)
      return
    end
    local msg = {callback = on_msg_callback, text = text_show}
    ui_widget.ui_msg_box.show_common(msg)
  elseif puse.model == bo2.eUseMod_ResetXinfaMaster then
    local function on_msg_callback(msg_call)
      if msg_call.result ~= 1 then
        return
      end
      send_use(info)
    end
    local text_show = ui.get_text("skill|reset_xinfa_master_confirm")
    local msg = {callback = on_msg_callback, text = text_show}
    ui_widget.ui_msg_box.show_common(msg)
  elseif puse.model == bo2.eUseMod_PuzzleMap then
    local areaID = info:get_data_32(bo2.eItemUInt32_AreaID)
    local scnID = info:get_data_32(bo2.eItemUInt32_ScnID)
    if areaID ~= 0 and scnID == bo2.scn.scn_excel.id then
      do
        local puzzle_map_id = excel.use_par[0]
        local puzzle_map_line = bo2.gv_puzzle_map:find(puzzle_map_id)
        local pos_x = info:get_data_32(bo2.eItemUInt32_PosX)
        pos_x = math.floor(pos_x / 1000)
        local pos_z = info:get_data_32(bo2.eItemUInt32_PosZ)
        pos_z = math.floor(pos_z / 1000)
        local x, z = bo2.player:get_position()
        local length = math.sqrt((pos_x - x) ^ 2 + (pos_z - z) ^ 2)
        if length < puzzle_length[1] then
          send_use(info)
        elseif puzzle_map_line.type == 0 then
          local scn_line = bo2.gv_scn_list:find(info:get_data_32(bo2.eItemUInt32_ScnID))
          ui_chat.show_ui_text_id(2184, {
            pos_x = pos_x,
            pos_z = pos_z,
            scn = scn_line.name
          })
        elseif length < puzzle_length[4] then
          ui_chat.show_ui_text_id(2194)
        else
          if puzzle_timer == true then
            return
          end
          do
            local long_txt = ""
            if length > puzzle_length[2] then
              long_txt = ui.get_text("puzzle|long_txt1")
            elseif length > puzzle_length[3] then
              long_txt = ui.get_text("puzzle|long_txt2")
            else
              long_txt = ui.get_text("puzzle|long_txt3")
            end
            local dx = x - pos_x
            local dz = z - pos_z
            local way_x = 0
            local way_z = 0
            local tan_y = math.abs(dx / dz)
            local tan_x = math.abs(dz / dx)
            if dx > 0 then
              way_x = 2
            elseif dx < 0 then
              way_x = 1
            end
            if dz > 0 then
              way_z = 2
            elseif dz < 0 then
              way_z = 1
            end
            if tan_x < 0.36 then
              way_z = 0
            elseif tan_y < 0.36 then
              way_x = 0
            end
            local text_idx = way_x * 10 + way_z
            bo2.SendUIEvent(bo2.eUIEvent_PuzzleMap, true)
            local function do_tell()
              puzzle_timer = false
              ui_chat.show_ui_text_id(puzzle_long_txt[text_idx], {
                long = long_txt,
                length = math.floor(length)
              })
            end
            puzzle_timer = true
            bo2.AddTimeEvent(25, do_tell)
          end
        end
      end
    else
      send_use(info)
    end
  elseif puse.model == bo2.eUseMod_ModifyName then
    do
      local function on_msg_callback(data)
        if data.result ~= 1 then
          return
        end
        local input_name = data.input
        local rst, new_name = ui.check_name(data.input)
        if rst ~= bo2.eNameCheck_ErrNone then
          local err
          if rst == bo2.eNameCheck_ErrLength and input_name.size < bo2.NAME_LENGTH_MIN then
            if input_name.empty then
              err = ui.get_text("phase|name_error6")
            else
              err = ui_widget.merge_mtf({
                num = bo2.NAME_LENGTH_MIN
              }, ui.get_text("phase|name_error7"))
            end
          else
            err = ui_choice.player_name_error[rst]
            if err == nil then
              err = ui.get_text("phase|name_error8")
            end
          end
          ui_tool.note_insert(err, "FF0000")
          local function invoke(name)
            local msg = {
              callback = on_msg_callback,
              text = ui.get_text("item|modify_charactor_name"),
              input = name
            }
            ui_widget.ui_msg_box.show_common(msg)
          end
          invoke(new_name)
          return
        else
          local function on_name(data)
            if data.result ~= 1 then
              local function invoke(name)
                local msg = {
                  callback = on_msg_callback,
                  text = ui.get_text("item|modify_charactor_name"),
                  input = name
                }
                ui_widget.ui_msg_box.show_common(msg)
              end
              invoke(new_name)
              return
            end
            local v = sys.variant()
            v:set(packet.key.cha_name, new_name)
            send_use(info, v)
          end
          local msg = {
            callback = on_name,
            text = ui_widget.merge_mtf({new_name = new_name}, ui.get_text("item|modify_name_confirm")),
            input = name
          }
          ui_widget.ui_msg_box.show_common(msg)
        end
      end
      local function invoke(name)
        local msg = {
          callback = on_msg_callback,
          text = ui.get_text("item|modify_charactor_name"),
          input = name
        }
        ui_widget.ui_msg_box.show_common(msg)
      end
      invoke(L(""))
    end
  elseif puse.model == bo2.eUseMod_LivingSkillPeifang then
    local excel = info.excel
    local peifang_excel = bo2.gv_livingskill_peifang_list:find(excel.use_par[0])
    local living_type = peifang_excel.type
    local skill_id = bo2.gv_livingskill_type:find(living_type).livingskill_skill_id
    local skill = ui.skill_find(skill_id)
    if skill == nil then
      ui_chat.show_ui_text_id(76186)
      return
    end
    local val = bo2.player:get_livingskill_peifang(peifang_excel.id)
    if val == 1 then
      ui_chat.show_ui_text_id(76185)
      return
    end
    local function on_btn_msg(msg)
      if msg.result == 1 then
        send_use(info)
      end
    end
    local msg = {
      callback = on_btn_msg,
      btn_confirm = true,
      btn_cancel = true,
      modal = true
    }
    local arg = sys.variant()
    arg:set("name", peifang_excel.name)
    msg.text = sys.mtf_merge(arg, ui.get_text("skill|info_confirm_use_peifang_item"))
    ui_widget.ui_msg_box.show_common(msg)
  elseif puse.model == bo2.eUseMod_LivingSkillTirouAndBopi then
    do
      local excel = info.excel
      local excel = bo2.gv_item_list:find(info.excel_id)
      local function check_tirouandbopi(excel_id)
        if excel.requires.size == 2 and excel.requires[0] == 101 and excel.requires[1] == 130091 then
          return true
        end
        return false
      end
      local skill_info = ui.skill_find(130091)
      if excel == nil or skill_info == nil or not check_tirouandbopi(excel_id) then
        ui_chat.show_ui_text_id(76186)
      end
      send_use(info)
    end
  else
    send_use(info)
  end
end
init_once()
