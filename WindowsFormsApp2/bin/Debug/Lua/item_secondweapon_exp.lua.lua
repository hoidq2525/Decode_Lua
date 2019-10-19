flag = false
expnew = 0
function on_visible(ctrl, vis)
  if not vis then
    ui.item_mark_show("equip_model", 0)
    return
  end
  if not sys.check(rawget(_M, "w_core")) then
    w_top:load_style("$frame/item/item_secondweapon_exp.xml", "main")
    ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
  end
end
local card_get_req = function(top)
  local info = top:search("card").info
  if info == nil then
    return nil, 0, 0, 0
  end
  local level = info:get_data_32(bo2.eItemUInt32_SecondLevel)
  local exp = info:get_data_32(bo2.eItemUInt32_SecondExp)
  local expsum = exp
  local al = bo2.gv_assistant_level:find(level)
  local item_list = bo2.gv_item_list:find(71040)
  if item_list == nil then
    return
  end
  local per = item_list.use_par[2] / 100
  if al ~= nil then
    local ass_upgrade_id = info:get_data_8(bo2.eItemByte_AssUpgradeID)
    local ae = bo2.gv_assistant_upgrade:find(ass_upgrade_id)
    for i = 1, level - 1 do
      expsum = expsum + bo2.gv_assistant_level:find(i).exp[ae.exp_id]
    end
    return info, level, exp, expsum * per
  end
end
local function card_update_req()
  local s, level1, exp1, expsum1 = card_get_req(w_source)
  local c, level2, exp2, expsum2 = card_get_req(w_cost)
  local exp1_cur = exp1
  if s then
    if c then
      expnew = 0
      local excel_id = s.excel_id
      local pEquipExcel = bo2.gv_equip_item:find(excel_id)
      local n1 = w_source:search("level")
      local n2 = w_cost:search("level")
      local al1 = bo2.gv_assistant_level:find(level1)
      local al2 = bo2.gv_assistant_level:find(level2)
      local ass_upgrade_id1 = s:get_data_8(bo2.eItemByte_AssUpgradeID)
      local ass_upgrade_id2 = c:get_data_8(bo2.eItemByte_AssUpgradeID)
      if ass_upgrade_id1 > 0 and ass_upgrade_id2 > 0 then
        local ae1 = bo2.gv_assistant_upgrade:find(ass_upgrade_id1)
        local ae2 = bo2.gv_assistant_upgrade:find(ass_upgrade_id2)
        if ae1 ~= nil and ae2 ~= nil then
          local addLevel = 0
          local expsum = expsum2 + exp1_cur
          flag = false
          while true do
            if not (expsum >= bo2.gv_assistant_level:find(level1).exp[ae1.exp_id]) or flag then
              break
            end
            expsum = expsum - bo2.gv_assistant_level:find(level1).exp[ae1.exp_id]
            level1 = level1 + 1
            local lv = bo2.player:get_atb(bo2.eAtb_Level)
            if level1 >= lv then
              ui_tool.note_insert(ui.get_text("item_secondweapon_exp|remind_text"), "FFFF0000")
            end
            exp1 = expsum
            local pTemplateExcel = bo2.gv_second_equip_template:find(pEquipExcel.ass_id)
            local a = pTemplateExcel.grow_prop_level
            for i = 0, 10 do
              al1 = bo2.gv_assistant_level:find(level1)
              if pTemplateExcel.grow_prop_level[i] == 0 then
                break
              end
              if level1 >= pTemplateExcel.grow_prop_level[i] and s:get_data_32(bo2.eItemUInt32_IdentTraitBeg + i) == 0 then
                flag = true
                if level1 > pTemplateExcel.grow_prop_level[i] then
                  level1 = level1 - 1
                  al1 = bo2.gv_assistant_level:find(level1)
                end
                exp1 = exp1_cur
                for i = 1, level1 - 1 do
                  expnew = expnew + bo2.gv_assistant_level:find(i).exp[0]
                end
                expnew = expnew + exp1
                break
              end
            end
          end
          if not flag then
            expnew = expsum2
          end
          n1.text = ui.get_text("item_secondweapon_exp|level") .. sys.format("%s\n", level1)
          n2.text = ui.get_text("item_secondweapon_exp|level") .. sys.format("%s\n", level2)
          al1 = bo2.gv_assistant_level:find(level1)
          w_source:search("exp").text = ui.get_text("item_secondweapon_exp|exp") .. sys.format("%s/%s", exp1, al1.exp[ae1.exp_id])
          w_cost:search("exp").text = ui.get_text("item_secondweapon_exp|exp") .. sys.format("%s/%s", exp2, al2.exp[ae2.exp_id])
        end
      end
    else
      w_cost:search("card").only_id = ""
      w_cost:search("level").text = ""
      w_cost:search("exp").text = ""
      expnew = 0
      flag = false
      local n = w_source:search("level")
      local al1 = bo2.gv_assistant_level:find(level1)
      n.text = ui.get_text("item_secondweapon_exp|level") .. sys.format("%s\n", level1)
      local ass_upgrade_id = s:get_data_8(bo2.eItemByte_AssUpgradeID)
      if ass_upgrade_id > 0 then
        local ae = bo2.gv_assistant_upgrade:find(ass_upgrade_id)
        if ae ~= nil then
          w_source:search("exp").text = ui.get_text("item_secondweapon_exp|exp") .. sys.format("%s/%s", exp1, al1.exp[ae.exp_id])
        end
      end
    end
  else
    flag = false
    expnew = 0
    w_source:search("card").only_id = ""
    w_source:search("level").text = ""
    w_source:search("exp").text = ""
    w_cost:search("card").only_id = ""
    w_cost:search("level").text = ""
    w_cost:search("exp").text = ""
  end
end
local function card_clear(top)
  flag = false
  top:search("card").only_id = ""
  top:search("level").text = ""
  top:search("exp").text = ""
  card_update_req()
end
local function card_reset(top, info)
  top:search("card").only_id = info.only_id
  card_update_req()
end
function send_use()
  local svar = w_top.svar
  local item_info = ui.item_of_only_id(svar.item_id)
  if item_info == nil then
    return
  end
  local p1, t1, s1, expsum1 = card_get_req(w_source)
  local p2, t2, s2, expsum2 = card_get_req(w_cost)
  if t1 == nil or t2 == nil or t1 <= 0 or t2 <= 0 then
    ui_tool.note_insert(ui.get_text("item_secondweapon_exp|not_fit"), "FFFF0000")
    return
  end
  local source_id = w_source:search("card").only_id
  local cost_id = w_cost:search("card").only_id
  if source_id == L("0") or cost_id == L("0") then
    ui_tool.note_insert(ui.get_text("item_secondweapon_exp|not_fit"), "FFFF0000")
    return
  end
  local v = sys.variant()
  if flag then
    local function click_ok(msg)
      if msg.result == 0 then
        return
      end
      v:set("source_id", source_id)
      v:set("cost_id", cost_id)
      v:set("expnew", expnew)
      ui_item.send_use(item_info, v)
      w_top.visible = false
    end
    local msg = {
      callback = click_ok,
      btn_confirm = true,
      btn_cancel = true,
      modal = true
    }
    msg.text = ui.get_text("item_secondweapon_exp|readd")
    ui_widget.ui_msg_box.show_common(msg)
  else
    v:set("source_id", source_id)
    v:set("cost_id", cost_id)
    v:set("expnew", expnew)
    ui_item.send_use(item_info, v)
    w_top.visible = false
  end
end
local send_count_limit = function(excel_id)
  local text = ui.get_text("item|lottery_no_item")
  ui_widget.ui_msg_box.show_common({
    text = ui_widget.merge_mtf({
      item = "<i:" .. excel_id .. ">"
    }, text),
    btn_confirm = true,
    btn_cancel = false,
    modal = true
  })
end
function on_send_click(btn)
  local svar = w_top.svar
  local excel_id = svar.excel_id
  local info = ui.item_of_excel_id(excel_id)
  if info == nil then
    send_count_limit(excel_id)
    return
  end
  send_use()
end
function on_clear_click(btn)
  card_clear(w_source)
  card_clear(w_cost)
end
local cs_rclick_change_model = ui.get_text("item_secondweapon_exp|rclick_change_model")
local cs_moveto_change_model = ui.get_text("item_secondweapon_exp|moveto_change_model")
function item_rbutton_tip(info)
  if info == nil then
    return nil
  end
  local svar = w_top.svar
  local excel_id = svar.excel_id
  if not info:check_modify_equip_model(excel_id, false) then
    return
  end
  local box = info.box
  if box < bo2.eItemBox_BagBeg or box >= bo2.eItemBox_BagEnd then
    return cs_moveto_change_model
  end
  return cs_rclick_change_model
end
function item_rbutton_check(info)
  if info == nil then
    return false
  end
  local excel = info.excel
  if excel == nil then
    return false
  end
  return true
end
function item_rbutton_use(info)
  if info == nil then
    return
  end
  local svar = w_top.svar
  local excel_id = svar.excel_id
  if not info:check_modify_equip_model(excel_id, true) then
    return
  end
  local id = info.only_id
  local source_id = w_source:search("card").only_id
  local cost_id = w_cost:search("card").only_id
  if id == source_id or id == cost_id then
    return
  end
  local excel = bo2.gv_equip_item:find(info.excel_id)
  if excel == nil then
    ui_tool.note_insert(ui.get_text("item_secondweapon_exp|cannot"), "FFFF0000")
    return
  end
  local type_excel = bo2.gv_item_type:find(excel.type)
  if type_excel == nil then
    ui_tool.note_insert(ui.get_text("item_secondweapon_exp|cannot"), "FFFF0000")
    return
  end
  if type_excel.equip_slot ~= bo2.eItemSlot_2ndWeapon then
    ui_tool.note_insert(ui.get_text("item_secondweapon_exp|cannot"), "FFFF0000")
    return
  end
  local cfg = bo2.gv_item_secondweapon_exp_config:find(info.excel_id)
  if cfg ~= nil then
    ui_tool.note_insert(ui.get_text("item_secondweapon_exp|func_disable"), "FFFF0000")
    return
  end
  if source_id.size <= 1 then
    card_reset(w_source, info)
  else
    for i = 0, 3 do
      local gem_item = info:get_data_32(bo2.eItemUInt32_GemBeg + i)
      if gem_item > 0 then
        ui_tool.note_insert(ui.get_text("item_secondweapon_exp|gem_item"), "FFFF0000")
        return
      end
    end
    card_reset(w_cost, info)
  end
end
function on_card_mouse(card, msg, pos, wheel)
  if msg ~= ui.mouse_rbutton_click then
    return
  end
  local icon = card.icon
  if icon == nil then
    return
  end
  card_clear(card.parent.parent)
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  local stk = sys.mtf_stack()
  if excel == nil then
    ui_tool.ctip_show(card, nil)
    return
  end
  ui_tool.ctip_make_item(stk, excel, card.info, card)
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("item|right_input_bag"), ui_tool.cs_tip_color_operation)
  ui_tool.ctip_show(card, stk)
end
function show(info)
  local excel = info.excel
  local svar = w_top.svar
  local excel_id = info.excel_id
  svar.excel_id = excel_id
  svar.item_id = info.only_id
  w_top.visible = true
  w_top:move_to_head()
  w_top:search("lb_title").text = excel.name
  ui.item_mark_show("equip_model", excel_id)
  local rb_desc = w_top:search("rb_desc")
  rb_desc.mtf = ui_widget.merge_mtf({
    item = sys.format("<i:%d>", excel.id)
  }, ui.get_text("item_secondweapon_exp|func_desc"))
  rb_desc:update()
  on_clear_click()
end
