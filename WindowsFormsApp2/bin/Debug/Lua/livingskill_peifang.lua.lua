local ui_livingskill_peifang = ui_npcfunc.ui_livingskill_peifang
local ui_tree2 = ui_widget.ui_tree2
local ui_cell = ui_npcfunc.ui_cell
local ui_cmn = ui_npcfunc.ui_cmn
local g_scn_player
local reg = ui_packet.game_recv_signal_insert
local gv_livingskill_category = bo2.load_table_lang("$mb/skill/living_skill/livingskill_category.xml")
local g_sig = "ui_npcfunc.ui_livingskill_peifang.count_refresh"
local m_equip_line
local g_skill_id = 0
local g_color = {
  "808080",
  "FFFFFF",
  "FFFFFF",
  "FFFFFF",
  "808080"
}
function on_btn_make_click(btn)
  local item = w_special_equip_view.svar.leaf_item_sel
  if not sys.check(item) then
    return
  end
  local count = product_count()
  if count == 0 then
    return
  end
  local count = ui_widget.ui_count_box.get_value(w_count_box)
  if count == 0 then
    return
  end
  do_product_update()
  local equip_line = item.svar.excel_rules
  local v = sys.variant()
  v:set(packet.key.item_count, count)
  v:set(packet.key.item_excelid, equip_line.id)
  v:set(packet.key.skill_id, g_skill_id)
  v:set(packet.key.cmn_type, bo2.eFuncTypePeifang)
  local function on_msg_callback(msg_call)
    if msg_call.result == 1 then
      bo2.send_variant(packet.eCTS_UI_Livingskill, v)
    end
  end
  local msg = {
    callback = on_msg_callback,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  local arg = sys.variant()
  arg:set("name", equip_line.name)
  msg.text = sys.mtf_merge(arg, ui.get_text("npcfunc|confir_info"))
  ui_widget.ui_msg_box.show_common(msg)
end
function detail_clear()
  ui_cell.batch_clear(w_detail, {
    "product",
    "mat_reg_0",
    "mat_reg_1",
    "mat_reg_2",
    "mat_reg_3"
  })
  w_detail:search("lb_req_money").money = 0
  w_item_count.text = ""
  w_btn_make.enable = false
  w_need_use_action.text = ""
  w_need_add_exp.text = ""
  w_need_equip_id.mtf = ""
end
function do_desc_update()
  w_desc:search("box").mtf = ui.get_text("npcfunc|info_desc_peifang")
  if m_equip_line == nil then
    return
  end
  if m_equip_line.text_id ~= 0 or m_equip_line.text_id ~= nil then
    local tip_x = bo2.gv_text:find(m_equip_line.text_id)
    if tip_x ~= nil and tip_x.text.empty == false then
      w_desc:search("box").mtf = tip_x.text
    end
  end
end
function product_count()
  local item = w_special_equip_view.svar.leaf_item_sel
  if not sys.check(item) or not item.selected then
    return
  end
  local equip_line = item.svar.excel_rules
  local count = 0
  for i = 0, 4 do
    local id = equip_line.reg_id[i]
    if id ~= 0 then
      local cnt = ui.item_get_count(id, true)
      local can_cnt = math.floor(cnt / equip_line.reg_num[i])
      if i == 0 then
        count = can_cnt
      elseif can_cnt < count then
        count = can_cnt
      end
    end
  end
  local player = ui_personal.ui_equip.safe_get_player()
  local money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney) + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
  if equip_line.money_type == bo2.eCurrency_CirculatedMoney then
    money = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
  end
  local t = math.floor(money / equip_line.money)
  if count > t then
    count = t
  end
  local flag_exp = ui.get_skill_add_exp_color(g_skill_id, equip_line.id)
  if flag_exp == -1 then
    count = 0
  end
  return count
end
function do_product_update()
  w_btn_max.enable = false
  ui_widget.ui_count_box.set_range(w_count_box, 1, 0)
  do_desc_update()
  local item = w_special_equip_view.svar.leaf_item_sel
  if not sys.check(item) or not item.selected then
    return
  end
  local count = product_count()
  if count == 0 then
    w_btn_max.enable = false
    w_btn_make.enable = false
  else
    w_btn_max.enable = true
    w_btn_make.enable = true
  end
  ui_widget.ui_count_box.set_range(w_count_box, 1, count)
end
function post_product_update()
  w_special_equip_view:insert_post_invoke(do_product_update, "ui_livingskill_peifang.do_product_update")
end
function on_item_count(card, excel_id, bag, all)
  post_product_update()
end
function on_item_sel(item, sel)
  if not sel then
    detail_clear()
    return
  end
  w_special_equip_view.svar.leaf_item_sel = item
  local equip_line = item.svar.excel_rules
  local final_item_count = 1
  local c = w_detail:search("product")
  ui_cell.set(c, equip_line.pdt_id)
  w_item_count.text = final_item_count
  for i = 0, 4 do
    local id = equip_line.reg_id[i]
    if id ~= 0 then
      local c = w_detail:search("mat_reg_" .. i)
      ui_cell.set(c, id, equip_line.reg_num[i])
    end
  end
  m_equip_line = nil
  m_equip_line = equip_line
  w_detail:search("lb_req_money").money = equip_line.money
  if equip_line.money_type == bo2.eCurrency_BoundedMoney then
    w_detail:search("lb_req_money").bounded = true
  elseif equip_line.money_type == bo2.eCurrency_CirculatedMoney then
    w_detail:search("lb_req_money").bounded = false
  end
  do_desc_update()
  w_need_use_action.text = equip_line.use_action
  local add_exp = item.svar.add_exp
  local add_exp_color = ui.make_color("FFE4DCAD")
  if add_exp == -1 then
    add_exp = ui.get_text("npcfunc|donot_make")
    add_exp_color = ui.make_color("FFFF0000")
  end
  w_need_add_exp.color = add_exp_color
  w_need_add_exp.text = add_exp
  if equip_line.v_equip_id.size ~= 0 or equip_line.v_equip_id.size ~= nil then
    local arg = sys.variant()
    local desc_text = ""
    for i = 0, equip_line.v_equip_id.size - 1 do
      if i >= 2 then
        local tmp_text = sys.mtf_merge(arg, ui.get_text("npcfunc|livingskill_so_on"))
        desc_text = desc_text .. tmp_text
        break
      end
      local equip_id = equip_line.v_equip_id[i]
      arg:clear()
      arg:set("item_id", sys.format("%d", equip_id))
      local req_text = sys.mtf_merge(arg, ui.get_text("npcfunc|ui_need_use_equip"))
      req_text = req_text .. "\n"
      desc_text = desc_text .. req_text
    end
    w_need_equip_id.mtf = desc_text
  end
end
function on_max_click(btn)
  ui_widget.ui_count_box.set_max(w_count_box)
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
            local equip_line = leaf.svar.excel_rules
            for k = 0, 5 do
              local req_id = equip_line.reg_id[k]
              local req_num = equip_line.reg_num[k]
              if req_id ~= 0 then
                local item_excel = ui.item_get_excel(req_id)
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
  item.svar.excel_rules = equip_line
  local color_id = ui.get_skill_add_exp_color(g_skill_id, equip_line.id)
  if color_id == -1 then
    color_id = 4
  end
  item.svar.add_exp = ui.get_skill_add_exp(g_skill_id, equip_line.id)
  ui_tree2.set_text(item, item_excel.name, g_color[color_id + 1])
end
function check_skill_type(id)
  local excel = get_livingskill_type(g_skill_id)
  if excel ~= nil and excel.id == id then
    return true
  end
  return false
end
function check_have_peifang(id)
  local val = bo2.player:get_livingskill_peifang(id)
  if val == 1 then
    return true
  end
  return false
end
function on_init(ctrl)
  local size = bo2.gv_livingskill_category.size
  for j = 0, size - 1 do
    local category_line = bo2.gv_livingskill_category:get(j)
    if g_skill_id == category_line.skill_id then
      local node = build_node(category_line)
      local size_pf = bo2.gv_livingskill_peifang_list.size
      for k = 0, size_pf - 1 do
        local equip_line = bo2.gv_livingskill_peifang_list:get(k)
        local item_excel = ui.item_get_excel(equip_line.pdt_id)
        if node.svar.special_equip_category.id == equip_line.cat_id and check_have_peifang(equip_line.id) and check_skill_type(equip_line.type) then
          build_leaf(equip_line, node, item_excel)
        end
      end
    end
  end
end
function get_livingskill_type(id)
  local excel
  local size = bo2.gv_livingskill_type.size
  for j = 0, size - 1 do
    local line = bo2.gv_livingskill_type:get(j)
    if line ~= nil and line.livingskill_skill_id == id then
      excel = line
    end
  end
  return excel
end
function check_livingskillid(skill_id)
  local excel = get_livingskill_type(skill_id)
  if excel ~= nil then
    return true
  end
  return false
end
function show(skill_id)
  m_equip_line = nil
  if not check_livingskillid(skill_id) then
    return
  end
  local skill_info = ui.skill_find(skill_id)
  if skill_info == nil then
    return
  end
  if g_skill ~= 0 and g_skill_id == skill_id and w_main.visible then
    w_main.visible = false
    g_skill_id = 0
    return
  end
  g_skill_id = 0
  w_main.visible = true
  g_skill_id = skill_id
  w_special_equip_view.root:item_clear()
  on_init()
  local excel = ui_skill.get_skill_excel(skill_info.excel_id, skill_info.type)
  w_peifang_titel.text = excel.name
end
function on_visible(ctrl, vis)
  m_equip_line = nil
  do_product_update()
  ui_npcfunc.on_visible(ctrl, vis)
end
