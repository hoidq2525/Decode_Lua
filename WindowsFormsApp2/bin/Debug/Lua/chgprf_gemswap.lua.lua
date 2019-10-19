local ui_chgprf_gemswap = ui_npcfunc.ui_chgprf_gemswap
local ui_tree2 = ui_widget.ui_tree2
local ui_cell = ui_npcfunc.ui_cell
local gv_chgprf_gemswap_catagory = bo2.load_table_lang("$mb/item/chgprf_gemswap_catagory.xml")
local m_equip_line
function handCheckCampaignOn(cmd, data)
  local campaign_eventid = data:get(packet.key.campaign_eventid).v_int
  local talk_excel_id = data:get(packet.key.talk_excel_id).v_int
  if campaign_eventid ~= 17359 or talk_excel_id ~= bo2.eNpcFunc_ChgPrfGemSwap then
    return
  end
  local campaign_eventstate = data:get(packet.key.campaign_eventstate).v_int
  if campaign_eventstate == 1 then
    local my_w = ui_npcfunc.ui_chgprf_gemswap.w_main
    my_on_visible(my_w, true)
  else
    ui_chat.show_ui_text_id(2651)
  end
end
function on_npcfunc_open_window(npcfunc_id)
  ui.log("npcfunc_id:" .. npcfunc_id)
  g_npcfunc_id = npcfunc_id
  ui_npcfunc.ui_chgprf_gemswap.w_main.visible = false
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_ChgPrfGemSwap)
  v:set(packet.key.campaign_eventid, 17359)
  bo2.send_variant(packet.eCTS_UI_Check_Campaign_ON, v)
end
function on_btn_chgprf_gemswap_click(btn)
  local item = w_special_equip_view_gemswap.svar.leaf_item_sel
  do_product_update()
  local def_level = bo2.gv_define:find(1255).value.v_int
  local player = bo2.player
  local my_level = player:get_atb(bo2.eAtb_Level)
  if def_level > my_level then
    local var = sys.variant()
    var:set(L("level"), def_level)
    local data = sys.variant()
    data:set(packet.key.ui_text_id, 2645)
    data:set(packet.key.ui_text_arg, var)
    ui_chat.show_ui_text(0, data)
    return
  end
  local equip_line = item.svar.chgprf_gemswap_rules
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_ChgPrfGemSwap)
  v:set(packet.key.item_excelid, equip_line.id)
  bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
end
function detail_clear()
  ui_cell.batch_clear(w_detail, {
    "product",
    "mat_reg_0",
    "mat_reg_1",
    "mat_reg_2",
    "mat_reg_3",
    "mat_reg_4",
    "mat_reg_5",
    "mat_reg_10"
  })
  w_detail:search("lb_req_money").money = 0
  w_item_count.text = ""
  w_btn_make.enable = false
end
function do_product_update()
  local item = w_special_equip_view_gemswap.svar.leaf_item_sel
  if item == nil then
    return
  end
  w_btn_make.enable = false
  local equip_line = item.svar.chgprf_gemswap_rules
  for i = 0, 5 do
    local id = equip_line.reg_id[i]
    if id ~= 0 then
      local raw_cir_cnt = ui.item_get_count(id, true)
      if raw_cir_cnt < equip_line.reg_num[i] then
        return
      end
    end
  end
  w_btn_make.enable = true
end
function post_product_update()
  w_special_equip_view_gemswap:insert_post_invoke(do_product_update, "ui_chgprf_gemswap.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  local c = ui_cell.top_of(card)
  post_product_update()
  if w_show_enough_mat.check then
    on_check_mat_click(w_show_enough_mat)
  end
  if c.name == L("product") then
    return
  end
  local btn_quick_buy
  if c.name == L("mat_reg_0") then
    btn_quick_buy = w_quick_buy0
  elseif c.name == L("mat_reg_1") then
    btn_quick_buy = w_quick_buy1
  elseif c.name == L("mat_reg_2") then
    btn_quick_buy = w_quick_buy2
  elseif c.name == L("mat_reg_3") then
    btn_quick_buy = w_quick_buy3
  else
    return
  end
  btn_quick_buy.visible = false
  local goods_id = ui_supermarket2.shelf_quick_buy_id(excel_id)
  if goods_id == 0 then
    return
  end
  btn_quick_buy.name = tostring(goods_id)
  btn_quick_buy.visible = true
end
function on_quick_buy(btn)
  ui_supermarket2.shelf_singleBuy(btn)
end
function on_item_sel(item, sel)
  m_equip_line = nil
  if not sel then
    detail_clear()
    return
  end
  w_special_equip_view_gemswap.svar.leaf_item_sel = item
  local equip_line = item.svar.chgprf_gemswap_rules
  local final_item_count = 1
  local c = w_detail:search("product")
  ui_cell.set(c, equip_line.item_id)
  w_item_count.text = final_item_count
  for i = 0, 5 do
    local id = equip_line.reg_id[i]
    if id ~= 0 then
      local c = w_detail:search("mat_reg_" .. i)
      ui_cell.set(c, id, equip_line.reg_num[i])
    end
  end
  m_equip_line = equip_line
  w_detail:search("lb_req_money").money = equip_line.money
  if equip_line.money_type == bo2.eCurrency_BoundedMoney then
    w_detail:search("lb_req_money").bounded = true
    w_detail:search("lb_own_money").money = bo2.player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
    w_detail:search("lb_own_money").bounded = true
  elseif equip_line.money_type == bo2.eCurrency_CirculatedMoney then
    w_detail:search("lb_req_money").bounded = false
    w_detail:search("lb_own_money").money = bo2.player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    w_detail:search("lb_own_money").bounded = false
  end
end
function on_check_mat_click(ctrl)
  local root = w_special_equip_view_gemswap.root
  for i = 0, root.item_count do
    local node = root:item_get(i)
    if node ~= nil then
      for j = 0, node.item_count do
        local leaf = node:item_get(j)
        if leaf ~= nil then
          if ctrl.check == true then
            local equip_line = leaf.svar.chgprf_gemswap_rules
            for k = 0, 5 do
              local req_id = equip_line.reg_id[k]
              local req_num = equip_line.reg_num[k]
              if req_id ~= 0 then
                local cnt = ui.item_get_count(req_id, true)
                if req_num > cnt then
                  leaf.display = false
                  break
                end
              end
            end
          else
            leaf.display = true
          end
        end
      end
      node.expanded = true
    end
  end
end
function build_node(line)
  local node = ui_tree2.insert(w_special_equip_view_gemswap.root)
  ui_tree2.set_text(node, line.name)
  node.svar.special_equip_category = line
  node.expanded = false
  return node
end
function build_leaf(equip_line, node, item_excel)
  local item = ui_tree2.insert(node)
  item.svar.chgprf_gemswap_rules = equip_line
  ui_tree2.set_text(item, item_excel.name, item_excel.plootlevel.color)
end
function on_init(ctrl)
  for j = 0, gv_chgprf_gemswap_catagory.size - 1 do
    local category_line = gv_chgprf_gemswap_catagory:get(j)
    local node = build_node(category_line)
    for k = 0, bo2.gv_chgprf_gemswap_rules.size - 1 do
      local equip_line = bo2.gv_chgprf_gemswap_rules:get(k)
      local item_excel = ui.item_get_excel(equip_line.item_id)
      if node.svar.special_equip_category.id == equip_line.cat_id then
        build_leaf(equip_line, node, item_excel)
      end
    end
  end
end
function on_visible(w, vis)
end
function my_on_visible(w, vis)
  do_product_update()
  w.visible = true
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
end
function on_timer()
  if m_equip_line == nil then
    return
  end
  w_detail:search("lb_req_money").money = m_equip_line.money
  if m_equip_line.money_type == bo2.eCurrency_BoundedMoney then
    w_detail:search("lb_req_money").bounded = true
    w_detail:search("lb_own_money").money = bo2.player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
    w_detail:search("lb_own_money").bounded = true
  elseif m_equip_line.money_type == bo2.eCurrency_CirculatedMoney then
    w_detail:search("lb_req_money").bounded = false
    w_detail:search("lb_own_money").money = bo2.player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    w_detail:search("lb_own_money").bounded = false
  end
end
local sig = "ui_npcfunc.ui_chgprf_gemswap:on_signal"
ui_packet.game_recv_signal_insert(packet.eSTC_UI_Campaign_Check_Campaign_On, handCheckCampaignOn, sig)
