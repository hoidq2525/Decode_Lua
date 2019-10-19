local ui_cell = ui_npcfunc.ui_cell
local iGemSemltProductItemID = bo2.gv_define:find(1289).value.v_int
local g_input_gem_count = 0
function on_npcfunc_open_window(npcfunc_id)
  ui.log("npcfunc_id:" .. npcfunc_id)
  g_npcfunc_id = npcfunc_id
end
function clear_all()
  for i = 1, 5 do
    local card = w_main:search("g_gem" .. i)
    ui_npcfunc.clear_card(card)
  end
  for i = 1, 1 do
    local cell = w_main:search("r_gem" .. i)
    ui_cell.clear(cell)
  end
  g_input_gem_count = 0
end
function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  clear_all()
end
function on_ok(ctrl)
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_SmeltGem)
  local keybeg = packet.key.item_key
  for i = 1, 5 do
    local card = w_main:search("g_gem" .. i)
    if card.info ~= nil then
      v:set64(keybeg, card.only_id)
      keybeg = keybeg + 1
    end
  end
  local r_gem1 = w_main:search("r_gem1")
  local function on_msg_callback(msg_call)
    if msg_call.result ~= 1 then
      return
    end
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
    ui_item.post_card_flash(r_gem1:search("card"))
    clear_all()
  end
  local text_show = ui.get_text("npcfunc|smelt_gem_confim")
  local msg = {callback = on_msg_callback, text = text_show}
  ui_widget.ui_msg_box.show_common(msg)
end
function item_rbutton_tip(info)
  return ui.get_text("npcfunc|smelt_gem_rclick")
end
function GetExcel(excel_id)
  for k = 0, bo2.gv_gem_smelt.size - 1 do
    local line = bo2.gv_gem_smelt:get(k)
    if line and excel_id == line.gem_id then
      return line
    end
  end
  return nil
end
function item_rbutton_check(info)
  local excel = bo2.gv_gem_item:find(info.excel_id)
  if excel == nil then
    return false
  end
  return true
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  for i = 1, 5 do
    local card = w_main:search("g_gem" .. i)
    card:insert_on_item_only_id(on_card_chg, "ui_npcfunc.ui_smelt_gem.on_card_chg")
  end
end
function check_drop(info)
  local excel = bo2.gv_gem_item:find(info.excel_id)
  if excel == nil then
    return false
  end
  if GetExcel(info.excel_id) == nil then
    ui_chat.show_ui_text_id(20327)
    return false
  end
  return true
end
function item_rbutton_use(info)
  if not check_drop(info) then
    return
  end
  if g_input_gem_count >= 5 then
    ui_chat.show_ui_text_id(20328)
    return false
  end
  for i = 1, 5 do
    local card = w_main:search("g_gem" .. i)
    if card.excel_id == 0 then
      card.only_id = info.only_id
      info:insert_lock(bo2.eItemLock_UI)
      break
    end
  end
end
function on_card_drop(pn, msg, pos, data)
  if ui_cell.check_drop(pn, msg, pos, data) == false then
    return
  end
  local info = ui.item_of_only_id(data:get("only_id"))
  if not check_drop(info) then
    return
  end
  ui_npcfunc.clear_card(pn)
  pn.only_id = info.only_id
  info:insert_lock(bo2.eItemLock_UI)
end
function on_card_chg(card, onlyid, info)
  w_compose_ok.enable = false
  g_input_gem_count = 0
  local r_gem1 = w_main:search("r_gem1")
  ui_cell.clear(r_gem1)
  w_item_count.text = ""
  local pro_count = 0
  for i = 1, 5 do
    local card = w_main:search("g_gem" .. i)
    if card.info ~= nil then
      local line = GetExcel(card.excel_id)
      pro_count = pro_count + line.count
      g_input_gem_count = g_input_gem_count + 1
    end
  end
  if pro_count > 0 then
    ui_cell.set(r_gem1, iGemSemltProductItemID)
    w_item_count.text = pro_count
  end
  if g_input_gem_count > 0 then
    w_compose_ok.enable = true
  end
end
