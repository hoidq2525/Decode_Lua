remove_player_name = nil
remove_sel_item = nil
enforce_relation_type = nil
remove_npc_func = nil
function begin_enforce_remove_relation(cmd, data, relation_type, npc_func)
  enforce_remove_ok.enable = false
  local relation_packet = data:get(packet.key.sociality_twrelationpacket)
  if relation_packet.size == 1 then
    local relation_info = relation_packet:fetch_v(i)
    remove_player_name = relation_info:get(packet.key.sociality_tarplayername).v_string
    enforce_relation_type = relation_type
    remove_npc_func = npc_func
    show_enforce_remove_confirm()
  else
    w_remove_list:item_clear()
    for i = 0, relation_packet.size - 1 do
      local relation_info = relation_packet:fetch_v(i)
      local player_name = relation_info:get(packet.key.sociality_tarplayername).v_string
      local portrait_id = relation_info:get(packet.key.sociality_portrait).v_int
      local depth = relation_info:get(packet.key.sociality_twrelationdepth).v_int
      local max_depth = relation_info:get(packet.key.sociality_maxdepth).v_int
      insert_re_item(player_name, relation_type, npc_func, portrait_id, depth, max_depth)
    end
    w_remove_window.visible = true
    local relation_name = ui_sociality.get_relation_name(relation_type)
    local temp_text = ui.get_text("sociality|romove_relation_text")
    local text_final = ui_widget.merge_mtf({relation = relation_name}, temp_text)
    rich_remove.mtf = text_final
    enforce_relation_type = relation_type
    remove_npc_func = npc_func
  end
end
function insert_re_item(player_name, relation_type, npc_func, portrait_id, depth, max_depth)
  local item_uri = "$frame/sociality/remove_relation.xml"
  local item_style = "remove_relation_list_item"
  local app_item = w_remove_list:item_append()
  app_item:load_style(item_uri, item_style)
  app_item:search("player_name").text = player_name
  local temp_text = ui.get_text("sociality|depth_and_maxdepth")
  local depth_text = ui_widget.merge_mtf({friend_depth = depth, friend_max_depth = max_depth}, temp_text)
  app_item:search("depth_value").text = depth_text
  if tonumber(portrait_id) ~= 0 then
    app_item:search("relation_icon").image = "$icon/portrait/zj/" .. portrait_id .. ".png"
  end
  app_item.var = npc_func
  return app_item
end
function on_item_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_enter then
    ctrl:search("high_light").visible = true
  elseif msg == ui.mouse_leave then
    ctrl:search("high_light").visible = false
  elseif msg == ui.mouse_lbutton_click then
    local playername = ctrl:search("player_name").text
    remove_player_name = playername
    ctrl:search("select_light").visible = true
    if remove_sel_item ~= ctrl and remove_sel_item ~= nil then
      remove_sel_item:search("select_light").visible = false
    end
    remove_sel_item = ctrl
    enforce_remove_ok.enable = true
  end
end
function on_remove_select_ok(btn)
  show_enforce_remove_confirm()
end
function show_enforce_remove_confirm()
  if remove_player_name ~= nil then
    local confirm_plus_text
    if enforce_relation_type == bo2.TWR_Type_Engagement or enforce_relation_type == bo2.TWR_Type_Couple then
      local tmp_plus_text = ui.get_text("sociality|remove_marry_plus_text")
      local money_num = tonumber(tostring(bo2.gv_define_sociality:find(50).value))
      local currency = tonumber(tostring(bo2.gv_define_sociality:find(49).value))
      local money_text
      if currency == bo2.eCurrency_CirculatedMoney then
        money_text = sys.format("<m:%d>", money_num)
      elseif currency == bo2.eCurrency_BoundedMoney then
        money_text = sys.format("<bm:%d>", money_num)
      end
      confirm_plus_text = ui_widget.merge_mtf({money = money_text}, tmp_plus_text)
    elseif enforce_relation_type == bo2.TWR_Type_Sworn then
      confirm_plus_text = ui.get_text("sociality|remove_sworn_plus_text")
    elseif enforce_relation_type == bo2.TWR_Type_MasterAndApp and remove_npc_func == bo2.eNpcFunc_RemoveAppren then
      local tmp_plus_text = ui.get_text("sociality|remove_master_plus_text")
      local money_num = tonumber(tostring(bo2.gv_define_sociality:find(52).value))
      local currency = tonumber(tostring(bo2.gv_define_sociality:find(51).value))
      local money_text
      if currency == bo2.eCurrency_CirculatedMoney then
        money_text = sys.format("<m:%d>", money_num)
      elseif currency == bo2.eCurrency_BoundedMoney then
        money_text = sys.format("<bm:%d>", money_num)
      end
      confirm_plus_text = ui_widget.merge_mtf({money = money_text}, tmp_plus_text)
    else
      confirm_plus_text = ui.get_text("sociality|remove_plus_text_default")
    end
    local relation_name = ui_sociality.get_relation_name(enforce_relation_type)
    local tmp_text = ui.get_text("sociality|remove_relation_confirm_text")
    local confirm_text = ui_widget.merge_mtf({
      plus_text = confirm_plus_text,
      player = remove_player_name,
      relation = relation_name
    }, tmp_text)
    rich_enforce_confirm.mtf = confirm_text
    w_enforce_remove_confirm.visible = true
    w_remove_window.visible = false
  end
end
function on_remove_select_cancel(btn)
  remove_sel_item = nil
  remove_player_name = nil
  enforce_relation_type = nil
  w_remove_window.visible = false
end
function on_enforce_remove_confirm_ok(btn)
  ui.console_print("on_enforce_remove_confirm_ok")
  if remove_player_name ~= nil then
    ui.console_print("remove_player_name~ nil")
    local v = sys.variant()
    v:set(packet.key.sociality_tarplayername, remove_player_name)
    v:set(packet.key.sociality_twrelationtype, enforce_relation_type)
    if enforce_relation_type == bo2.TWR_Type_Engagement or enforce_relation_type == bo2.TWR_Type_Couple then
      v:set(packet.key.sociality_twrelationchgtype, bo2.TWR_ChgType_EnforceDivorce)
    elseif enforce_relation_type == bo2.TWR_Type_Sworn then
      v:set(packet.key.sociality_twrelationchgtype, bo2.TWR_ChgType_EnforceRemoveSworn)
    elseif enforce_relation_type == bo2.TWR_Type_MasterAndApp then
      v:set(packet.key.sociality_twrelationchgtype, bo2.TWR_ChgType_EnforceRemoveMA)
    end
    v:set(packet.key.sociality_npcfuncid, remove_npc_func)
    bo2.send_variant(packet.eCTS_Sociality_ChgTWRelation, v)
  end
  remove_sel_item = nil
  remove_player_name = nil
  enforce_relation_type = nil
  w_enforce_remove_confirm.visible = false
  ui.console_print("on_enforce_remove_confirm_ok end")
end
function on_enforce_remove_confirm_cancel(btn)
  remove_sel_item = nil
  remove_player_name = nil
  enforce_relation_type = nil
  w_enforce_remove_confirm.visible = false
end
function on_enforce_remove_close()
  remove_sel_item = nil
  remove_player_name = nil
  enforce_relation_type = nil
  w_remove_window.visible = false
  w_enforce_remove_confirm.visible = false
end
function on_init()
  local uri = "$frame/sociality/remove_relation.xml"
  local style = "remove_relation_list_item"
  cur_row = w_remove_list:item_append()
  cur_row:load_style(uri, style)
end
