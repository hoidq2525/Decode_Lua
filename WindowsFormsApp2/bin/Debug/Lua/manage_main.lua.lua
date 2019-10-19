local ui_combo = ui_widget.ui_combo_box
function on_label1_select(item)
  local cb = cb_label1
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallManage_LabelShop)
  v:set(packet.key.itemdata_idx, 0)
  v:set(packet.key.itemdata_val, item.id)
  bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  ui_combo.select(cb, cb.svar.old_id)
end
function on_label2_select(item)
  local cb = cb_label2
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallManage_LabelShop)
  v:set(packet.key.itemdata_idx, 1)
  v:set(packet.key.itemdata_val, item.id)
  bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  ui_combo.select(cb, cb.svar.old_id)
end
function on_init()
  init_cb_label(cb_label1, on_label1_select)
  init_cb_label(cb_label2, on_label2_select)
end
function init_cb_label(cb, fn)
  for i = 0, 4 do
    ui_combo.append(cb, {
      id = i,
      text = ui.get_text("mall|tab_label" .. i)
    })
  end
  ui_combo.select(cb, 0)
  cb.svar.on_select = fn
end
function on_upshop(ctrl)
  local send_impl = function(ctrl)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallManage_UpShop)
    local money_ctrl = ctrl:search("money")
    local money = ui_widget.ui_money_box.get_money(money_ctrl)
    v:set(packet.key.cmn_money, money)
    bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/mall/common.xml",
    style_name = "money_input_box",
    init = function(msg)
      local window = msg.window
      local mtf = ui.get_text("mall|up_shop_input")
      window:search("rv_text").mtf = mtf
      window:tune_y("rv_text")
    end,
    callback = function(msg)
      if msg.result == 1 then
        local window = msg.window
        send_impl(window)
      end
    end
  })
end
function on_downshop(ctrl)
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallManage_DownShop)
  bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
end
function on_openshop(ctrl)
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallManage_OpenShop)
  bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
end
function on_closeshop(ctrl)
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallManage_CloseShop)
  bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
end
function on_up_money(ctrl)
  local send_impl = function(ctrl, name)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallManage_UpMoney)
    local money_ctrl = ctrl:search("money")
    local money = ui_widget.ui_money_box.get_money(money_ctrl)
    v:set(packet.key.cmn_money, money)
    if tostring(name) == "acq_money" then
      v:set(packet.key.item_grid, 4)
    else
      v:set(packet.key.item_grid, 0)
    end
    bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/mall/common.xml",
    style_name = "money_input_box",
    init = function(msg)
      local window = msg.window
      local mtf = ui.get_text("mall|up_money_input")
      window:search("rv_text").mtf = mtf
      window:tune_y("rv_text")
    end,
    callback = function(msg)
      if msg.result == 1 then
        local window = msg.window
        send_impl(window, ctrl.parent.name)
      end
    end
  })
end
function on_down_money(ctrl)
  local send_impl = function(ctrl, name)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallManage_DownMoney)
    local money_ctrl = ctrl:search("money")
    local money = ui_widget.ui_money_box.get_money(money_ctrl)
    v:set(packet.key.cmn_money, money)
    if tostring(name) == "acq_money" then
      v:set(packet.key.item_grid, 4)
    else
      v:set(packet.key.item_grid, 0)
    end
    bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  end
  ui_widget.ui_msg_box.show({
    style_uri = "$frame/mall/common.xml",
    style_name = "money_input_box",
    init = function(msg)
      local window = msg.window
      local mtf = ui.get_text("mall|down_money_input")
      window:search("rv_text").mtf = mtf
      window:tune_y("rv_text")
    end,
    callback = function(msg)
      if msg.result == 1 then
        local window = msg.window
        send_impl(window, ctrl.parent.name)
      end
    end
  })
end
local g_intro_text = L("")
function on_set_intro(data)
  g_intro_text = data:get(packet.key.family_intro).v_string
  if g_intro_text.empty then
    g_intro_view.mtf = ui.get_text("mall|intro_mask")
  else
    g_intro_view.mtf = g_intro_text
  end
  g_pn_intro_view.visible = true
  g_pn_intro_edit.visible = false
  if g_intro_edit.text == g_intro_text then
    g_intro_edit:item_clear()
  end
end
function on_intro_chg(ctrl)
  g_pn_intro_view.visible = false
  g_pn_intro_edit.visible = true
  if g_intro_edit.item_count == 0 then
    g_intro_edit.text = g_intro_text
  end
end
function on_intro_send(ctrl)
  if g_intro_edit.item_count == 0 then
    return
  end
  local v = sys.variant()
  v:set(packet.key.cmn_type, bo2.eMallManage_Intro)
  v:set(packet.key.family_intro, g_intro_edit.text)
  bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
end
function on_intro_cancel(ctrl)
  g_pn_intro_view.visible = true
  g_pn_intro_edit.visible = false
  g_intro_edit:item_clear()
end
function on_chg_name(ctrl)
  local send_impl = function(input)
    local v = sys.variant()
    v:set(packet.key.cmn_type, bo2.eMallManage_Name)
    v:set(packet.key.cmn_name, input)
    bo2.send_variant(packet.eCTS_UI_Mall_Manage, v)
  end
  ui_widget.ui_msg_box.show_common({
    text = ui.get_text("mall|build_mallname"),
    input = L(""),
    callback = function(ret)
      if ret.result == 1 then
        send_impl(ret.input)
      end
    end
  })
end
function on_chg_name_tip_make(tip)
  local text = ui.get_text("mall|do_chg_name")
  if ui_mall.ui_manage.g_btn_chg_name.enable == false then
    text = text .. ui.get_text("mall|only_manager")
  end
  ui_widget.tip_make_view(tip.view, text)
end
