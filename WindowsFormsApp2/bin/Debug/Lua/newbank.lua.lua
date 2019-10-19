c_text_item_file = L("$frame/newbank/newbank.xml")
c_text_item_cell = L("item_cell")
c_box_size_x = 8
c_box_size_y = 12
c_box_count = 6
c_box_margin = 5
c_cells_margin = 22
c_cell_size = 37
c_warninig_color = "FFFF0000"
local cs_item_grid = SHARED("$image/item/pic_item_grid.png|0,0,36,36")
local cs_item_bad = SHARED("$image/item/pic_item_bad.png|0,0,36,36")
function on_init()
end
function get_visible()
  local w = ui.find_control("$frame:newbank")
  return w.visible
end
function lev_limite()
  local player = bo2.player
  if bo2.player == nil then
    return
  end
  local pLevel = bo2.player:get_atb(bo2.eAtb_Level)
  local defines = bo2.gv_define:find(1238)
  local levelLimite = defines.value.v_int
  local limite = pLevel >= levelLimite
  if limite then
    return true
  else
    local v = sys.variant()
    v:set("limite", levelLimite)
    local text = sys.mtf_merge(v, ui.get_text("bank|newbank_limite"))
    ui_tool.note_insert(text, "FFFF0000")
    return false
  end
end
function show_bank()
  local vis = lev_limite()
  set_visible(vis)
  ui_item.set_visible(vis)
  ui_bank.set_visible(false)
end
function close_bank()
  set_visible(false)
  ui_item.set_visible(false)
end
function set_visible(vis)
  local w = ui.find_control("$frame:newbank")
  w.visible = vis
end
function get_useable_grid(excel_id)
  local size = bo2.get_newbank_cur_size()
  local w_box = w_root:search(sys.format("box:%d", bo2.eItemBox_NewBank))
  local w_cells = w_box:search("w_cells")
  for i = 0, size - 1 do
    local cell = w_cells:search(sys.format("grid:%d", i))
    local card = cell:search("card")
    local info = ui.item_of_coord(bo2.eItemBox_NewBank, i)
    if info == nil then
      return i, card
    end
    local excel = ui.item_get_excel(info.excel_id)
    if info.excel_id == excel_id and excel.consume_mode == bo2.eItemConsumeMod_Stack and 1 < excel.consume_par and info.count < excel.consume_par * 2 then
      return i, card
    end
  end
  return nil
end
function on_click_tidy_box()
  ui_item.send_tidy(bo2.eItemBox_NewBank)
  bo2.PlaySound2D(522)
end
function on_init_box(ctrl, data)
  local w_cells = ctrl:search("w_cells")
  if w_cells == nil then
    ui.log("failed get w_cells.")
    return
  end
  local box = data.v_int
  for r = 0, c_box_size_y - 1 do
    for i = 0, c_box_size_x - 1 do
      local c = ui.create_control(w_cells, "panel")
      c:load_style(c_text_item_file, c_text_item_cell)
      c.offset = ui.point(i * c_cell_size, r * c_cell_size)
      local grid = r * c_box_size_x + i
      c.name = grid
      local d = c:search("card")
      d.box = box
      d.grid = grid
      c.name = sys.format("grid:%d", grid)
      local bg = c:search("bg")
      local b_size = bo2.get_newbank_cur_size()
      if grid >= b_size then
        d.enable = false
        bg.image = cs_item_bad
      else
        d.enable = true
        bg.image = cs_item_grid
      end
    end
  end
  ctrl.name = sys.format("box:%d", box)
end
function on_card_drop(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  if not ui_widget.check_drop(data, ui_widget.c_drop_type_item) then
    return
  end
  ui.clean_drop()
  ui.log("only_id:" .. data:get("only_id").v_string .. "index:" .. card.index)
  ui_item.cmn_move_item(data:get("only_id").v_string, card.index)
end
function on_card_mouse(card, msg, pos, wheel)
  local icon = card.icon
  if icon == nil then
    return
  end
  local info = card.info
  if info == nil then
    return
  end
  local box = card.box
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_drag then
    ui.clean_drop()
    if info.lock > 0 then
      return
    end
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_item)
    data:set("only_id", card.only_id)
    data:set("count", info.count)
    ui.set_cursor_icon(icon.uri)
    local function on_drop_hook(w, msg, pos, data)
      local info = card.info
      if info == nil then
        return
      end
      if msg == ui.mouse_drop_setup then
        info:insert_lock(bo2.eItemLock_Drop)
      elseif msg == ui.mouse_drop_clean then
        info:remove_lock(bo2.eItemLock_Drop)
      end
    end
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  elseif msg == ui.mouse_mbutton_click then
    if ui.is_key_down(ui.VK_CONTROL) then
      ui_fitting_room.req_fitting_item_by_excel(info.excel)
      return
    end
    ui_item.show_tip_frame_card(card)
  elseif msg == ui.mouse_rbutton_click then
    local box, grid = ui_item.get_useable_box_grid(info.excel_id)
    ui.log("box:%d,grid:%d", box, grid)
    local on_msg = function(msg)
      if msg.result == 0 then
        return
      end
      local count = msg.window:search("number").text.v_int
      if count == 0 then
        return
      end
      ui_item.send_newbank(msg.only_id, -1, -1, count)
    end
    if info.count > 1 then
      do
        local cfm_text = ui.get_text("item|cnt_bank_in")
        local arg = sys.variant()
        local stack_count = info.excel.consume_par
        arg:set("stack_count", stack_count)
        ui_widget.ui_msg_box.show({
          style_uri = "$frame/org/common.xml",
          style_name = "goods_box",
          only_id = info.only_id,
          init = function(msg)
            local window = msg.window
            local btn = window:search("all_btn")
            window:search("title").mtf = sys.mtf_merge(arg, cfm_text)
            btn.text = ui.get_text("item|all_get")
            btn.svar.count = info.count
            btn.svar.win = window
            window:search("number").text = info.count
          end,
          callback = on_msg
        })
      end
    elseif info.count == 1 then
      ui_item.send_newbank(info.only_id, -1, -1, info.count)
    end
  end
end
function get_extend_box(cnt)
  return math.floor((cnt - 24) / 16)
end
function box_resize(slot, cnt)
  local extend = get_extend_box(cnt)
  local w_box = w_root:search(sys.format("box:%d", slot))
  local item = w_box:upsearch_type("ui_tree_item").owner
  if cnt > 0 then
    item.display = true
  else
    item.display = false
    return
  end
  local w_cells = w_box:search("w_cells")
  local cy = math.floor((cnt + c_box_size_x - 1) / c_box_size_x)
  local dy = c_cell_size * c_box_size_y
  w_cells.dy = dy + c_cells_margin
  w_box.dy = w_cells.dy + c_box_margin
  for y = 0, c_box_size_y - 1 do
    for x = 0, c_box_size_x - 1 do
      local grid = y * c_box_size_x + x
      local cell = w_cells:search(sys.format("grid:%d", grid))
      local card = cell:search("card")
      local bg = cell:search("bg")
      if y >= cy then
        cell.visible = true
        bg.image = cs_item_bad
        card.enable = false
      else
        if cnt > grid then
          card.enable = true
          bg.image = cs_item_grid
        else
          card.enable = false
          bg.image = cs_item_bad
        end
        cell.visible = true
      end
    end
  end
end
function box_item_size(info)
  if info == nil then
    return 0
  end
  local excel = info.excel
  if excel == nil or excel.type ~= bo2.eItemType_BankBox then
    return 0
  end
  local cnt = excel.use_par[0]
  return cnt
end
function box_index_to_coord(idx)
  local box = math.floor(idx / 65536)
  local grid = math.floor(math.fmod(idx, 65536))
  return box, grid
end
function on_slot_index(ctrl, idx, info)
  if idx == -1 then
    return
  end
  local cnt = box_item_size(info)
  local box, grid = box_index_to_coord(idx)
  box_resize(bo2.eItemBox_NewBank, cnt)
end
function on_msg(msg)
  if msg.result == 0 then
    return
  end
  send_bank_extend(msg.bank_size)
  bo2.PlaySound2D(585)
end
function get_max_bank_size()
  local defines = bo2.gv_define:find(1240)
  local max_bank_size = defines.value.v_int
  return max_bank_size
end
function on_buy_click(btn)
  local size = bo2.get_newbank_cur_size()
  if size == 0 then
    ui.log("band cur size nil")
    return
  end
  local bank_extend = bo2.gv_bank_extend:find(size)
  local max_size = get_max_bank_size()
  if bank_extend == nil then
    ui.log("bank_extend is nil")
    if size >= max_size then
      ui_tool.note_insert(ui.get_text("bank|extend_tip"), ui_bank.c_warninig_color)
    end
    return
  end
  local i_excel = bo2.gv_item_list:find(bank_extend.item_id)
  local n_excel = bo2.gv_bank_extend:find(i_excel.use_par[0])
  msg = {
    callback = on_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    bank_size = size
  }
  local arg = sys.variant()
  local mt = bank_extend.money_type
  if mt == bo2.eCurrency_CirculatedMoney then
    arg:set("money", sys.format("<m:%d>", bank_extend.money))
  elseif mt == bo2.eCurrency_BoundedMoney then
    arg:set("money", sys.format("<bm:%d>", bank_extend.money))
  elseif mt == bo2.eCurrency_BoundedJade then
    arg:set("money", sys.format("%d<brmb:16>", bank_extend.money))
    function msg.callback(msg)
      if msg.result == 0 then
        return
      end
      ui_supermarket2.shelf_prepareJade(bank_extend.money, function()
        send_bank_extend(msg.bank_size)
        bo2.PlaySound2D(585)
      end)
    end
  else
    return
  end
  msg.text = sys.mtf_merge(arg, ui.get_text("bank|extend_tip2"))
  ui_widget.ui_msg_box.show_common(msg)
end
function on_num_max_click(btn)
  local parent = btn.parent.parent
  local frm_input = parent:search("frm_input")
  local input = frm_input:search("box_input")
  input.text = _G.g_num_max
end
