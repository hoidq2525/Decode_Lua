function on_init(ctrl)
end
function insert_leaf(data)
  local style_uri = L("$frame/mall/manage_clerk.xml")
  local leaf_name = L("clerk_item")
  local leaf_item = g_clerk_list:item_append()
  leaf_item:load_style(style_uri, leaf_name)
  leaf_item.svar.id = data:get(packet.key.cha_onlyid).v_string
  leaf_item:search("name").text = data:get(packet.key.cha_name).v_string
  leaf_item:search("level").text = data:get(packet.key.family_level).v_int
  local prof = data:get(packet.key.player_profession).v_int
  if prof ~= 0 then
    local profExcel = bo2.gv_profession_list:find(prof)
    if profExcel ~= nil then
      leaf_item:search("profession").text = profExcel.name
    end
  end
  leaf_item:search("pos").text = ui.get_text("mall|shop_clerk")
end
function erase_leaf(data)
  local id = data:get(packet.key.cha_onlyid).v_string
  local root = g_clerk_list
  for i = 0, root.item_count - 1 do
    local item = root:item_get(i)
    if item.svar.id == id then
      root:item_remove(i)
      return
    end
  end
end
function clear_data()
  g_clerk_list:item_clear()
  g_btn_invite.enable = false
  g_btn_chgmgr.enable = false
  g_btn_expel.enable = false
end
function set_manage(manager_id)
  local root = g_clerk_list
  for i = 0, root.item_count - 1 do
    local item = root:item_get(i)
    if item.svar.id == manager_id then
      item:search("pos").text = ui.get_text("mall|shop_manager")
    else
      item:search("pos").text = ui.get_text("mall|shop_clerk")
    end
  end
  g_btn_invite.enable = ui_mall.ui_manage.im_manager()
  local g_select = g_clerk_list.item_sel
  if g_select ~= nil then
    on_item_select(g_select, true)
  end
end
function on_item_select(ctrl, v)
  ctrl:search("select").visible = v
  g_btn_chgmgr.enable = false
  g_btn_expel.enable = false
  if v then
    local player = bo2.player
    if ui_mall.ui_manage.im_manager() then
      if player ~= nil and player.only_id ~= ctrl.svar.id then
        g_btn_chgmgr.enable = true
        g_btn_expel.enable = true
      end
    elseif player ~= nil and player.only_id == ctrl.svar.id then
      g_btn_expel.enable = true
    end
  end
end
function on_invite(ctrl)
  local send_impl = function(input)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallManage_UpClerk)
    v:set(packet.key.cha_name, input)
    bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  end
  ui_widget.ui_msg_box.show_common({
    text = ui.get_text("mall|invite_input"),
    input = L(""),
    callback = function(ret)
      if ret.result == 1 then
        send_impl(ret.input)
      end
    end
  })
end
function on_chgmgr(ctrl)
  local g_select = g_clerk_list.item_sel
  if g_select == nil then
    return
  end
  local send_impl = function(id)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallManage_ChgManager)
    v:set(packet.key.cmn_id, id)
    bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  end
  ui_widget.ui_msg_box.show_common({
    text = sys.format(ui.get_text("mall|chgmgr_confirm"), g_select:search("name").text),
    callback = function(ret)
      if ret.result == 1 then
        send_impl(g_select.svar.id)
      end
    end
  })
end
function on_expel(ctrl)
  local g_select = g_clerk_list.item_sel
  if g_select == nil then
    return
  end
  local send_impl = function(id)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallManage_DownClerk)
    v:set(packet.key.cmn_id, id)
    bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  end
  local sel_id = g_select.svar.id
  if ui_mall.ui_manage.im_manager() then
    ui_widget.ui_msg_box.show_common({
      text = sys.format(ui.get_text("mall|expel_confirm"), g_select:search("name").text),
      callback = function(ret)
        if ret.result == 1 then
          send_impl(sel_id)
        end
      end
    })
  else
    ui_widget.ui_msg_box.show_common({
      text = ui.get_text("mall|exit_confirm"),
      callback = function(ret)
        if ret.result == 1 then
          send_impl(sel_id)
        end
      end
    })
  end
end
function on_sort_str(ctrl)
  ui_mall.on_click_sort_btn(ctrl)
  local function on_sort_inc(item1, item2)
    return ui_mall.compare_str(item1, item2, ctrl.name)
  end
  local function on_sort_dec(item1, item2)
    return ui_mall.compare_str(item2, item1, ctrl.name)
  end
  local root = g_clerk_list
  local cur_sort_dir = ctrl.parent.svar.sort.dir
  if cur_sort_dir == 1 then
    root:item_sort(on_sort_inc)
  else
    root:item_sort(on_sort_dec)
  end
end
function on_sort_num(ctrl)
  ui_mall.on_click_sort_btn(ctrl)
  local function on_sort_inc(item1, item2)
    return ui_mall.compare_num(item1, item2, ctrl.name)
  end
  local function on_sort_dec(item1, item2)
    return ui_mall.compare_num(item2, item1, ctrl.name)
  end
  local root = g_clerk_list
  local cur_sort_dir = ctrl.parent.svar.sort.dir
  if cur_sort_dir == 1 then
    root:item_sort(on_sort_inc)
  else
    root:item_sort(on_sort_dec)
  end
end
