local buff_table_1 = {
  jade = 150,
  buff = 80,
  buffid = 10048,
  name = "item1",
  enable = true,
  vis = false,
  index = 1
}
local buff_table_2 = {
  jade = 300,
  buff = 160,
  buffid = 10049,
  name = "item2",
  enable = true,
  vis = false,
  index = 2
}
local buff_table_3 = {
  jade = 450,
  buff = 240,
  buffid = 10050,
  name = "item3",
  enable = true,
  vis = false,
  index = 3
}
local buff_table = {
  [1] = buff_table_1,
  [2] = buff_table_2,
  [3] = buff_table_3
}
local day_num = 3
function on_buff_sel(btn)
  local p = btn:upsearch_name("content1")
  if p == nil then
    return
  end
  local sel_btn = p:search("sel_btn")
  if sel_btn == nil then
    return
  end
  sel_btn.svar.selid = btn.svar.id
  for i, v in pairs(buff_table) do
    local item = p:search(v.name)
    if item == nil then
      break
    end
    local figure_info = item:search("figure")
    if figure_info == nil then
      break
    end
    if btn.svar.id == i then
      figure_info.visible = true
    else
      figure_info.visible = false
    end
  end
end
function on_buff_exchange(btn)
  local svar = btn.svar
  if svar.selid == nil then
    return
  end
  local rmb = ui_supermarket2.g_rmb
  if rmb < buff_table[svar.selid].jade then
    ui_chat.show_ui_text_id(73235)
    return
  end
  local v = sys.variant()
  v:set(packet.key.cmn_id, svar.selid)
  bo2.send_variant(packet.eCTS_UI_BuffExchange, v)
  local ctrl = btn:upsearch_name("content1")
  for i, v in pairs(buff_table) do
    local item = w_buff_exchange:search(v.name)
    if item == nil then
      break
    end
    local buff_btn = item:search("buff_btn")
    if buff_btn == nil then
      break
    end
    buff_btn.enable = false
    local figure_info = item:search("figure")
    if figure_info == nil then
      break
    end
    figure_info.visible = false
    local buff_info = item:search("buff_info")
    if buff_info == nil then
      break
    end
    local var = sys.variant()
    var:set("jade", 0)
    var:set("num", 0)
    buff_info.mtf = sys.mtf_merge(var, ui.get_text("action|buff_exchange"))
    item.color = ui.make_color("999999")
  end
  local item4 = w_buff_exchange:search("item4")
  if item4 == nil then
    return
  end
  local buff_info4 = item4:search("buff_info")
  if buff_info4 == nil then
    return
  end
  local var = sys.variant()
  var:set("num", 0)
  buff_info4.mtf = sys.mtf_merge(var, ui.get_text("action|buff_day_num"))
end
function on_buff_exchange_visible(ctrl, vis)
  if vis == false then
    return
  end
  local count = ctrl.svar.count
  if count == nil then
    count = 0
  end
  for i, v in pairs(buff_table) do
    local item = ctrl:search(v.name)
    if item == nil then
      break
    end
    local buff_info = item:search("buff_info")
    if buff_info == nil then
      break
    end
    local var = sys.variant()
    var:set("jade", v.jade)
    var:set("num", v.buff)
    buff_info.mtf = sys.mtf_merge(var, ui.get_text("action|buff_exchange"))
    local buff_btn = item:search("buff_btn")
    if buff_btn == nil then
      break
    end
    buff_btn.svar.id = i
    local figure_info = item:search("figure")
    if figure_info == nil then
      break
    end
    figure_info.visible = false
    if i <= count then
      buff_btn.enable = true
      item.color = ui.make_color("000000")
    else
      buff_btn.enable = false
      item.color = ui.make_color("999999")
    end
  end
  local item4 = ctrl:search("item4")
  if item4 == nil then
    return
  end
  local buff_info4 = item4:search("buff_info")
  if buff_info4 == nil then
    return
  end
  local var = sys.variant()
  var:set("num", count)
  buff_info4.mtf = sys.mtf_merge(var, ui.get_text("action|buff_day_num"))
  local sel_btn = ctrl:search("sel_btn")
  if sel_btn == nil then
    return
  end
  sel_btn.svar.selid = nil
end
function set_buff_exchange_vis(cmd, data)
  local count = data:get(packet.key.cmn_id).v_int
  w_buff_exchange.svar.count = count
  w_buff_exchange.visible = true
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_action.packet_handle"
reg(packet.eSTC_UI_BuffExchange, set_buff_exchange_vis, sig)
