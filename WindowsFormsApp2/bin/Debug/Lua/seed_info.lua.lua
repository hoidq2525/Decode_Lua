local MAX_SEEDNUM_EACHROW = 5
local selected_seed_info = {}
local farm_type = 0
function show_seed_info(data_packet)
  if data_packet.empty == true then
    return
  end
  local uri = "$frame/guildfarm/seed_info.xml"
  local row_style = "seed_row"
  local seed_item_style = "seed_item_cell"
  w_seed_row_list:item_clear()
  w_main:search("btn_confirm").enable = false
  farm_type = data_packet:get(packet.key.farm_type).v_int
  local seed_num_eachrow = 0
  local data = data_packet:get(packet.key.farm_packet)
  for i = 0, data.size - 1 do
    local seed_excel_id = data:get(i):get(packet.key.farm_seedid).v_int
    local seed_num = data:get(i):get(packet.key.farm_seednum).v_int
    local cur_row = w_seed_row_list:item_append()
    cur_row:load_style(uri, row_style)
    local item_line = bo2.gv_item_list:find(seed_excel_id)
    local seed_name = item_line.name
    cur_row:search("name").text = seed_name
    cur_row:search("num").text = seed_num
    cur_row.var = seed_excel_id
  end
  w_main.visible = true
end
function on_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  local stk = sys.mtf_stack()
  if excel == nil then
    ui_tool.ctip_show(card, nil)
    return
  else
    ui_tool.ctip_make_item(stk, excel, card.info)
  end
  local stk_use
  local info = card.info
  local operation_count = 0
  local function push_operation(txt)
    if operation_count == 0 then
      operation_count = 1
      ui_tool.ctip_push_sep(stk)
    else
      ui_tool.ctip_push_newline(stk)
    end
    ui_tool.ctip_push_text(stk, txt, ui_tool.cs_tip_color_operation)
  end
  ui_tool.ctip_show(card, stk, stk_use)
end
function on_init(ctrl)
  local var = sys.variant()
  local a = sys.variant()
  a:set(packet.key.farm_seedid, 50001)
  a:set(packet.key.farm_seednum, 20)
  var:push_back(a)
  var:push_back(a)
  var:push_back(a)
  var:push_back(a)
  var:push_back(a)
  var:push_back(a)
  var:push_back(a)
  show_seed_info(var)
end
function on_seed_select(ctrl, is_select)
  if is_select == true then
    local select_hl = ctrl:search("select_high_light")
    if select_hl ~= nil then
      select_hl.visible = true
    end
    local item_var = ctrl.var
    selected_seed_info.id = item_var.v_int
    selected_seed_info.ctrl = ctrl
    local confirm_btn = w_main:search("btn_confirm")
    confirm_btn.enable = true
  else
    if ctrl == nil then
      return
    end
    local select_hl = ctrl:search("select_high_light")
    if select_hl ~= nil then
      select_hl.visible = false
    end
    selected_seed_info.id = nil
    selected_seed_info.ctrl = nil
  end
end
function seed_highlight(ctrl, is_highlight)
  local hl = ctrl:search("high_light")
  if hl ~= nil then
    hl.visible = is_highlight
  end
end
function on_seed_item_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_enter then
    seed_highlight(ctrl, true)
  elseif msg == ui.mouse_leave then
    seed_highlight(ctrl, false)
  elseif msg == ui.mouse_lbutton_dbl then
    on_confirm_click(nil)
  end
end
function on_seed_card_mouse(ctrl, msg, pos, wheel)
  local parent = ctrl.parent
  if parent ~= nil then
    on_seed_item_mouse(parent, msg, pos, wheel)
  end
end
function on_confirm_click(btn)
  if selected_seed_info.id ~= nil then
    local v = sys.variant()
    v:set(packet.key.farm_seedid, selected_seed_info.id)
    v:set(packet.key.farm_type, farm_type)
    bo2.send_variant(packet.eCTS_UI_GuildFarm_PlantSeed, v)
    selected_seed_info.ctrl = nil
    selected_seed_info.id = nil
  end
  w_main.visible = false
end
function on_cancel_click()
  w_main.visible = false
end
