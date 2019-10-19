local ui_make_special_equip = ui_npcfunc.ui_make_special_equip
local ui_tree2 = ui_widget.ui_tree2
local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local g_scn_player
local reg = ui_packet.game_recv_signal_insert
local gv_special_equip_category = bo2.gv_special_equip_category
local g_sig = "ui_npcfunc.ui_make_special_equip.count_refresh"
function on_btn_make_click(btn)
  local item = w_special_equip_view.svar.leaf_item_sel
  if not sys.check(item) then
    return
  end
  do_product_update()
  local equip_line = item.svar.make_special_equip
  local use_bd_mat = 0
  if w_use_bound_mat.check then
    use_bd_mat = 1
  end
  local v = sys.variant()
  v:set(packet.key.talk_excel_id, bo2.eNpcFunc_MakeSpecialEquip)
  v:set(packet.key.item_excelid, equip_line.id)
  v:set(packet.key.itemdata_val, use_bd_mat)
  local bd_item_excel, bd_item_cnt, cir_item_excel, cir_item_cnt, req_cnt
  for i = 0, 5 do
    local id = equip_line.reg_id[i]
    if id ~= 0 then
      local item_excel = ui.item_get_excel(id)
      local ref_excel = bo2.gv_refine_variety:find(item_excel.variety)
      if w_use_bound_mat.check and ref_excel then
        local bd_item_id = ref_excel.inc_bd_items[item_excel.varlevel]
        bd_item_excel = ui.item_get_excel(bd_item_id)
        cir_item_excel = ui.item_get_excel(id)
        bd_item_cnt = ui.item_get_count(bd_item_id, true)
        cir_item_cnt = ui.item_get_count(cir_item_id, true)
        req_cnt = equip_line.reg_num[i]
        break
      end
    end
  end
  if w_use_bound_mat.check == true and bd_item_cnt < req_cnt then
    local function on_msg_callback(msg_call)
      if msg_call.result ~= 1 then
        return
      end
      bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
    end
    local tb_param = {
      bd_item = bd_item_excel.name,
      cir_num = req_cnt - bd_item_cnt,
      cir_item = cir_item_excel.name
    }
    local text_model = ui.get_text("npcfunc|spec_equip_bd_msg")
    local text_show = ui_widget.merge_mtf(tb_param, text_model)
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
  w_btn_make.enable = false
end
function do_product_update()
  local item = w_special_equip_view.svar.leaf_item_sel
  if not sys.check(item) or not item.selected then
    return
  end
  w_btn_make.enable = false
  w_lb_bd_mat_cnt.visible = false
  local equip_line = item.svar.make_special_equip
  for i = 0, 5 do
    local id = equip_line.reg_id[i]
    if id ~= 0 then
      local item_excel = ui.item_get_excel(id)
      local ref_excel = bo2.gv_refine_variety:find(item_excel.variety)
      if w_use_bound_mat.check and ref_excel then
        local bd_item_id = ref_excel.inc_bd_items[item_excel.varlevel]
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
  w_special_equip_view:insert_post_invoke(do_product_update, "ui_make_special_equip.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  local c = ui_cell.top_of(card)
  if c.name == L("product") then
    return
  end
  if c.name == L("mat_reg_3") then
    local btn_quick_buy = w_mat_quick_buy3
    btn_quick_buy.visible = false
    local goods_id = ui_supermarket2.shelf_quick_buy_id(excel_id)
    if goods_id == 0 then
      return
    end
    btn_quick_buy.name = tostring(goods_id)
    btn_quick_buy.visible = true
  end
  post_product_update()
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
  local equip_line = item.svar.make_special_equip
  local c = w_detail:search("product")
  ui_cell.set(c, equip_line.item_id)
  for i = 0, 5 do
    local id = equip_line.reg_id[i]
    if id ~= 0 then
      local c = w_detail:search("mat_reg_" .. i)
      ui_cell.set(c, id, equip_line.reg_num[i])
      if w_use_bound_mat.check then
        local item_excel = ui.item_get_excel(id)
        local ref_excel = bo2.gv_refine_variety:find(item_excel.variety)
        if ref_excel then
          local bd_item_id = ref_excel.inc_bd_items[item_excel.varlevel]
          ui_cell.set(c, bd_item_id, equip_line.reg_num[i])
          ui_cell.set(w_detail:search("mat_reg_10"), id, equip_line.reg_num[i])
        end
      end
    end
  end
  w_detail:search("lb_req_money").money = equip_line.money
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
            local equip_line = leaf.svar.make_special_equip
            for k = 0, 5 do
              local req_id = equip_line.reg_id[k]
              local req_num = equip_line.reg_num[k]
              if req_id ~= 0 then
                local item_excel = ui.item_get_excel(req_id)
                local ref_excel = bo2.gv_refine_variety:find(item_excel.variety)
                if w_use_bound_mat.check and ref_excel then
                  local bd_item_id = ref_excel.inc_bd_items[item_excel.varlevel]
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
  item.svar.make_special_equip = equip_line
  ui_tree2.set_text(item, item_excel.name)
end
function on_init(ctrl)
  for j = 0, gv_special_equip_category.size - 1 do
    local category_line = gv_special_equip_category:get(j)
    local node = build_node(category_line)
    for k = 0, bo2.gv_make_special_equip.size - 1 do
      local equip_line = bo2.gv_make_special_equip:get(k)
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
function on_self_enter(obj, msg)
  bo2.player:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.eFlagInt32_CirculatedMoney, on_money_update, "ui_npcfunc.ui_make_special_equip.on_money_update")
  bo2.player:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.eFlagInt32_BoundedMoney, on_money_update, "ui_npcfunc.ui_make_special_equip.on_money_update")
end
function on_money_update(obj, ft, idx)
  w_detail:search("lb_own_money").money = obj:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
end
function make_refresh(cmd, var)
  local item_cnt = var:get(packet.key.item_count).v_int
  ui_widget.ui_count_box.set_value(w_count_box, item_cnt)
  if item_cnt <= 0 then
    g_is_making = false
  end
end
function break_refresh(cmd, var)
  g_is_making = false
  do_product_update()
end
reg(packet.eSTC_UI_MakeSpecialEquipRefresh, make_refresh, g_sig)
reg(packet.eSTC_UI_MakeSpecialEquipBreak, break_refresh, g_sig)
if bo2 ~= nil then
  bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_npcfunc.ui_make_special_equip.on_self_enter")
end
