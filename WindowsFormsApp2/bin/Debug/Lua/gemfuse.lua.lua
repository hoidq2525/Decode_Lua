local ui_gemfuse = ui_npcfunc.ui_gemfuse
local ui_tree2 = ui_widget.ui_tree2
local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local g_scn_player
local reg = ui_packet.game_recv_signal_insert
local gv_gemfuse_category = bo2.load_table_lang("$mb/item/gemfuse_catagory.xml")
local g_sig = "ui_npcfunc.ui_gemfuse.count_refresh"
local m_equip_line
function on_btn_fuse_click(btn)
  local item = w_special_equip_view.svar.leaf_item_sel
  if not sys.check(item) then
    return
  end
  if ui_stall.owner.g_owner.opening or ui_deal.g_main_window.visible == true or ui_stall.owner.gx_main_window.visible == true then
    local excel = bo2.gv_text:find(1168)
    if sys.check(excel) then
      ui_tool.note_insert(excel.text, L("FF0000"))
    end
    return
  end
  do_product_update()
  local equip_line = item.svar.gemfuse_rules
  local use_bd_mat = 0
  if w_use_bound_mat.check then
    use_bd_mat = 1
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_GemFuse)
  v:set(packet.key.item_excelid, equip_line.id)
  v:set(packet.key.itemdata_val, use_bd_mat)
  local bd_item_excel, bd_item_cnt, cir_item_excel, cir_item_cnt, req_cnt
  local text_show = L("")
  local bMsg = false
  for i = 0, 5 do
    local id = equip_line.reg_id[i]
    if id ~= 0 then
      local item_excel = ui.item_get_excel(id)
      local ref_excel = bo2.gv_fuse_variety:find(item_excel.fuse_variety)
      if ref_excel == nil then
        return
      end
      if w_use_bound_mat.check and ref_excel then
        local bd_item_id = ref_excel.fuse_inc_bd_items[item_excel.fuse_varlevel]
        local bd_item_excel = ui.item_get_excel(bd_item_id)
        local cir_item_excel = ui.item_get_excel(id)
        local bd_item_cnt = ui.item_get_count(bd_item_id, true)
        local cir_item_cnt = ui.item_get_count(cir_item_id, true)
        local req_cnt = equip_line.reg_num[i]
        if bd_item_cnt < req_cnt then
          local tb_param1 = {
            bd_item = bd_item_id,
            cir_num = req_cnt - bd_item_cnt,
            cir_item = id
          }
          local text_model1 = ui.get_text("npcfunc|refine_bd_msg")
          local txt_result1 = ui_widget.merge_mtf(tb_param1, text_model1)
          text_show = text_show .. txt_result1 .. L("\n")
          bMsg = true
        end
      end
    end
  end
  if bMsg then
    local function on_msg_callback(msg_call)
      if msg_call.result ~= 1 then
        return
      end
      bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
    end
    local msg = {callback = on_msg_callback, text = text_show}
    ui_widget.ui_msg_box.show_common(msg)
  else
    bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
  end
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
  local item = w_special_equip_view.svar.leaf_item_sel
  if not sys.check(item) or not item.selected then
    return
  end
  w_btn_make.enable = false
  w_lb_bd_mat_cnt.visible = false
  local equip_line = item.svar.gemfuse_rules
  for i = 0, 5 do
    local id = equip_line.reg_id[i]
    if id ~= 0 then
      local item_excel = ui.item_get_excel(id)
      local ref_excel = bo2.gv_fuse_variety:find(item_excel.fuse_variety)
      if ref_excel == nil then
        return
      end
      if w_use_bound_mat.check and ref_excel then
        local bd_item_id = ref_excel.fuse_inc_bd_items[item_excel.fuse_varlevel]
        local raw_bd_cnt = ui.item_get_count(bd_item_id, true)
        local raw_cir_cnt = ui.item_get_count(id, true)
        if raw_cir_cnt > 0 then
          local raw_cir_excel = ui.item_get_excel(id)
          w_lb_bd_mat_cnt.visible = true
          w_lb_bd_mat_cnt.text = ui_widget.merge_mtf({
            cnt = raw_cir_cnt,
            item_name = raw_cir_excel.name
          }, ui.get_text("npcfunc|spec_equip_bd_tip"))
        end
        if raw_bd_cnt + raw_cir_cnt < equip_line.reg_num[i] then
          return
        end
      else
        local c = ui.item_get_count(id, true)
        if c < equip_line.reg_num[i] then
          return
        end
      end
    end
  end
  w_btn_make.enable = true
end
function post_product_update()
  w_special_equip_view:insert_post_invoke(do_product_update, "ui_gemfuse.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  local c = ui_cell.top_of(card)
  post_product_update()
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
  if not sel then
    detail_clear()
    return
  end
  w_special_equip_view.svar.leaf_item_sel = item
  local equip_line = item.svar.gemfuse_rules
  local gemfuse_rand_excel = bo2.gv_gemfuse_rand:find(equip_line.rand_id)
  local final_item_count = 1
  if gemfuse_rand_excel ~= nil and gemfuse_rand_excel.prob[0] / 1000000 == 1 and gemfuse_rand_excel.item_count[0] ~= nil then
    final_item_count = gemfuse_rand_excel.item_count[0]
  end
  local c = w_detail:search("product")
  ui_cell.set(c, equip_line.item_id)
  w_item_count.text = final_item_count
  for i = 0, 5 do
    local id = equip_line.reg_id[i]
    if id ~= 0 then
      local c = w_detail:search("mat_reg_" .. i)
      ui_cell.set(c, id, equip_line.reg_num[i])
      if w_use_bound_mat.check then
        local item_excel = ui.item_get_excel(id)
        local ref_excel = bo2.gv_fuse_variety:find(item_excel.fuse_variety)
        if ref_excel == nil then
          return
        end
        if ref_excel then
          local bd_item_id = ref_excel.fuse_inc_bd_items[item_excel.fuse_varlevel]
          ui_cell.set(c, bd_item_id, equip_line.reg_num[i])
          ui_cell.set(w_detail:search("mat_reg_10"), id, equip_line.reg_num[i])
        end
      end
    end
  end
  m_equip_line = nil
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
  local root = w_special_equip_view.root
  for i = 0, root.item_count do
    local node = root:item_get(i)
    if node ~= nil then
      for j = 0, node.item_count do
        local leaf = node:item_get(j)
        if leaf ~= nil then
          if ctrl.check == true then
            local equip_line = leaf.svar.gemfuse_rules
            for k = 0, 5 do
              local req_id = equip_line.reg_id[k]
              local req_num = equip_line.reg_num[k]
              if req_id ~= 0 then
                local item_excel = ui.item_get_excel(req_id)
                local ref_excel = bo2.gv_fuse_variety:find(item_excel.fuse_variety)
                if ref_excel == nil then
                  return
                end
                if w_use_bound_mat.check and ref_excel then
                  local bd_item_id = ref_excel.fuse_inc_bd_items[item_excel.fuse_varlevel]
                  req_id = bd_item_id
                end
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
function on_check_bound_mat_click(ctrl)
  local item_sel = w_special_equip_view.item_sel
  if item_sel then
    on_item_sel(item_sel, true)
    do_product_update()
  end
end
function build_node(line)
  local node = ui_tree2.insert(w_special_equip_view.root)
  ui_tree2.set_text(node, line.name)
  node.svar.special_equip_category = line
  node.expanded = false
  return node
end
function build_leaf(equip_line, node, item_excel)
  if equip_line.disable ~= 0 then
    return
  end
  local item = ui_tree2.insert(node)
  item.svar.gemfuse_rules = equip_line
  ui_tree2.set_text(item, item_excel.name, item_excel.plootlevel.color)
end
function on_init(ctrl)
  for j = 0, gv_gemfuse_category.size - 1 do
    local category_line = gv_gemfuse_category:get(j)
    local node = build_node(category_line)
    for k = 0, bo2.gv_gemfuse_rules.size - 1 do
      local equip_line = bo2.gv_gemfuse_rules:get(k)
      local item_excel = ui.item_get_excel(equip_line.item_id)
      if node.svar.special_equip_category.id == equip_line.cat_id then
        build_leaf(equip_line, node, item_excel)
      end
    end
  end
end
function on_visible(ctrl, vis)
  do_product_update()
  ui_npcfunc.on_visible(ctrl, vis)
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
