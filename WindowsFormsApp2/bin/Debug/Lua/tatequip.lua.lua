function get_mat_excel(info)
  if info == nil then
    return nil
  end
  local excel = info.excel
  if excel == nil then
    return nil
  end
  if excel.type ~= bo2.eItemType_Tattoo then
    return nil
  end
  if excel.use_par.size < 1 then
    return nil
  end
  local bdExcel = bo2.gv_tattoo_board:find(excel.use_par[0])
  return bdExcel
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|tatequip_rclick")
end
function item_rbutton_check(info)
  local excel = get_mat_excel(info)
  return excel ~= nil
end
function item_rbutton_use(info)
  ui_npcfunc.ui_cell.drop(w_main:search("mat_raw"), info)
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
function update_desc()
end
function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  ui_npcfunc.ui_cell.clear(w_main:search("mat_raw"))
  if vis then
    update_desc()
  end
end
function on_raw_card_mouse(ctrl, msg)
  if msg ~= ui.mouse_rbutton_down then
    return
  end
  ui_npcfunc.ui_cell.clear(w_main:search("mat_raw"))
end
function on_card_chg()
  w_main:insert_post_invoke(do_raw_update, "ui_npcfunc.ui_tatequip.do_raw_update")
end
function do_raw_update()
  tatequip_ok.enable = false
  w_main:search("lb_money").money = 0
  local c = w_main:search("mat_raw")
  local card = c:search("card")
  local info = card.info
  local bdExcel = get_mat_excel(info)
  if bdExcel == nil then
    ui_npcfunc.ui_cell.clear(c)
    return
  end
  tatequip_ok.enable = true
  w_main:search("lb_money").money = bdExcel.equip_money
end
function on_ok(ctrl)
  local info = w_main:search("mat_raw"):search("card").info
  if info == nil then
    return
  end
  local function send_impl()
    local v = sys.variant()
    v:set(packet.key.talk_excel_id, bo2.eNpcFunc_EquipTattoo)
    v:set64(packet.key.item_key, info.only_id)
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  end
  local cfm_text = ui.get_text("npcfunc|cfm_tatequip")
  local arg = sys.variant()
  local item_name = sys.format("<fi:%s>", info.code)
  arg:set("item_name", item_name)
  local bdmoney = sys.format("<bm:%d>", w_main:search("lb_money").money)
  arg:set("bdmoney", bdmoney)
  if ui_personal.ui_tattoo.g_board_item ~= 0 then
    local old_item = sys.format("<i:%d>", ui_personal.ui_tattoo.g_board_item)
    arg:set("old_item", old_item)
    cfm_text = cfm_text .. ui.get_text("npcfunc|cfm_delold")
  end
  ui_widget.ui_msg_box.show_common({
    text = sys.mtf_merge(arg, cfm_text),
    callback = function(ret)
      if ret.result == 1 then
        send_impl()
      end
    end
  })
end
