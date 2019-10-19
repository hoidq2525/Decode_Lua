local ITEMGEM_NUM = 4
local gem_sel = 0
function on_visible(w, vis)
  ui_npcfunc.on_visible(w, vis)
  if vis == false then
    ui_npcfunc.ui_cell.clear(g_equip.parent.parent)
    gem_sel = 0
  end
end
function item_rbutton_tip(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel then
    return ui.get_text("npcfunc|gem_pull_rclick")
  end
end
function item_rbutton_check(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel then
    local idxbeg = bo2.eItemUInt32_GemBeg
    local flag = false
    for i = 1, ITEMGEM_NUM do
      local oldGem = info:get_data_32(idxbeg)
      idxbeg = idxbeg + 1
      if oldGem then
        flag = true
      end
    end
    return flag
  end
  return false
end
function item_rbutton_use(info)
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel then
    ui_npcfunc.ui_cell.drop(g_equip, info)
  end
end
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  ui_npcfunc.ui_cmn.succ_rate_set(w_succ_rate, 0)
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  g_equip:insert_on_item_only_id(on_equip_chg, "ui_gempullout.on_equip_chg")
end
function on_ok()
  local gem = g_gem_group:search("g_gempanel" .. gem_sel)
  if gem == nil or gem.excel_id == 0 then
    return
  end
  local function send_impl()
    w_main.var:set("server_tool_chg", 1)
    local v = sys.variant()
    v:set(packet.key.talk_excel_id, bo2.eNpcFunc_PullOutGem)
    v:set64(packet.key.item_key, g_equip.only_id)
    v:set64(packet.key.itemdata_idx, bo2.eItemUInt32_GemBeg + gem_sel - 1)
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
    gem_sel = 0
  end
  local excel = g_equip.info.excel
  local ptype = excel.ptype
  local cfm_text = ui.get_text("npcfunc|cfm_pullout")
  local arg = sys.variant()
  local item_name = sys.format("<i:%d>", gem.excel_id)
  arg:set("item_name", item_name)
  ui_widget.ui_msg_box.show_common({
    text = sys.mtf_merge(arg, cfm_text),
    callback = function(ret)
      if ret.result == 1 then
        send_impl()
      end
    end
  })
end
function set_sel(n)
  local c = g_gem_group:search("g_gempanel" .. n)
  if c == nil or c.excel_id == 0 then
    c = g_gem_group:search("g_gempanel" .. gem_sel)
    if c == nil or c.excel_id == 0 then
      n = 0
      for i = 1, ITEMGEM_NUM do
        c = g_gem_group:search("g_gempanel" .. i)
        if c.excel_id ~= 0 then
          n = i
          break
        end
      end
    else
      n = gem_sel
    end
  end
  for i = 1, ITEMGEM_NUM do
    local item = g_gem_group:search("g_gempanel" .. i)
    local hl = item.parent:search("highlight")
    if i ~= n then
      hl.visible = false
    else
      hl.visible = true
    end
  end
  gem_sel = n
  ui_npcfunc.ui_cmn.succ_rate_set(w_succ_rate, 0)
  ui_npcfunc.ui_cmn.money_set(w_money, 0)
  pullout_ok.enable = false
  local gem = g_gem_group:search("g_gempanel" .. gem_sel)
  if gem ~= nil then
    pullout_ok.enable = true
  else
    return
  end
  ui_npcfunc.ui_cmn.succ_rate_set(w_succ_rate, 1)
end
function on_gem_mouse1(card, msg, pos, data)
  if card.excel_id == 0 then
    return
  end
  if msg == ui.mouse_lbutton_down then
    set_sel(1)
  end
end
function on_gem_mouse2(card, msg, pos, data)
  if card.excel_id == 0 then
    return
  end
  if msg == ui.mouse_lbutton_down then
    set_sel(2)
  end
end
function on_gem_mouse3(card, msg, pos, data)
  if card.excel_id == 0 then
    return
  end
  if msg == ui.mouse_lbutton_down then
    set_sel(3)
  end
end
function on_gem_mouse4(card, msg, pos, data)
  if card.excel_id == 0 then
    return
  end
  if msg == ui.mouse_lbutton_down then
    set_sel(4)
  end
end
function on_equip_chg(card, onlyid, info)
  if info == nil then
    for i = 1, ITEMGEM_NUM do
      local gem = g_gem_group:search("g_gempanel" .. i)
      gem.excel_id = 0
    end
    set_sel(0)
  else
    draw_gems()
  end
end
function on_tool_chg(excel_id, bag, all)
  if w_main.var:get("server_tool_chg").v_int == 1 then
    w_main.var:set("server_tool_chg", 0)
    draw_gems()
  end
end
function on_suctool_chg(card, onlyid, info)
  if card.excel_id == nil or card.excel_id == 0 then
    g_suctool.parent.parent:search("lb_item").text = ui.get_text("npcfunc|pullout_input_suctool")
    g_suctool.parent.parent:search("lb_item").color = ui.make_color("ffffff")
  end
  set_sel(gem_sel)
end
function on_suctool_card_mouse(card, msg, pos, wheel)
  local icon = card.icon
  if icon == nil then
    return
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_drag then
    ui.set_cursor_icon(icon.uri)
    local function on_drop_hook(w, msg, pos, data)
      if msg == ui.mouse_drop_clean then
        card(card.parent.parent)
      end
    end
    local data = sys.variant()
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  elseif msg == ui.mouse_rbutton_click then
    ui_npcfunc.ui_cell.clear(card.parent.parent)
    g_suctool.parent.parent:search("lb_item").text = ui.get_text("npcfunc|pullout_input_suctool")
    g_suctool.parent.parent:search("lb_item").color = ui.make_color("ffffff")
  end
end
function draw_gems()
  if g_equip.info == nil then
    return
  end
  local pEquExcel = bo2.gv_equip_item:find(g_equip.info.excel_id)
  if pEquExcel == nil then
    return
  end
  local idxbeg = bo2.eItemUInt32_GemBeg
  for i = 1, ITEMGEM_NUM do
    local oldGem = g_equip.info:get_data_32(idxbeg)
    idxbeg = idxbeg + 1
    local gem = g_gem_group:search("g_gempanel" .. i)
    gem.excel_id = oldGem
  end
  set_sel(gem_sel)
end
