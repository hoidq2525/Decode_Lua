c_text_item_file = L("$frame/account_bank/account_bank.xml")
c_text_item_cell = L("item_cell")
c_box_size_x = 8
c_box_size_y = 3
c_box_count = 6
c_box_margin = 5
c_cells_margin = 22
c_cell_size = 37
c_warninig_color = "FFFF0000"
local cs_item_grid = SHARED("$image/item/pic_item_grid.png|0,0,36,36")
local cs_item_bad = SHARED("$image/item/pic_item_bad.png|0,0,36,36")
function on_init(ctrl)
  ui_item.insert_rbutton_data(ctrl, item_rbutton_check, item_rbutton_use, item_rbutton_tip)
end
function item_rbutton_check(info)
  return true
end
function item_rbutton_use(info)
  local grid, c = get_useable_grid()
  if grid == nil and c == nil then
    ui_tool.note_insert(ui.get_text("bank|bank_full_warning"), "FFFF0000")
    return
  end
  local function on_msgend(msg)
    if msg.result == 0 then
      return
    end
    info = ui.item_of_only_id(msg.only_id)
    ui_item.send_accbank(info.only_id, bo2.eItemBox_AccBank, -1, msg.count)
  end
  local function on_msg(msg)
    if msg.result == 0 then
      return
    end
    local count = msg.window:search("number").text.v_int
    if count == 0 then
      return
    end
    local msgend = {
      callback = on_msgend,
      btn_confirm = true,
      btn_cancel = true,
      modal = true,
      only_id = msg.only_id,
      count = count
    }
    local item_name = ui_account_bank.get_item_name(msg.excel_id)
    local accbank_item_in = bo2.gv_accbank_item_in:find(msg.excel_id)
    if accbank_item_in == nil then
      return
    end
    local money = accbank_item_in.money * count
    local arg = sys.variant()
    arg:set("item_num", count)
    arg:set("item_name", item_name)
    arg:set("money_num", money)
    msgend.text = sys.mtf_merge(arg, ui.get_text("account_bank|put_item"))
    ui_widget.ui_msg_box.show_common(msgend)
  end
  if info.count > 1 then
    do
      local accbank_item_in = bo2.gv_accbank_item_in:find(info.excel_id)
      if accbank_item_in == nil then
        ui_account_bank.ui_account_bank_safe.notify(1388)
        return
      end
      local cfm_text = ui.get_text("item|cnt_bank_in")
      local arg = sys.variant()
      local stack_count = info.excel.consume_par
      arg:set("stack_count", stack_count)
      ui_widget.ui_msg_box.show({
        style_uri = "$frame/org/common.xml",
        style_name = "goods_box",
        only_id = info.only_id,
        excel_id = info.excel_id,
        init = function(msg)
          local window = msg.window
          local btn = window:search("all_btn")
          window:search("title").mtf = sys.mtf_merge(arg, cfm_text)
          btn.text = ui.get_text("item|all_put")
          btn.svar.count = info.count
          btn.svar.win = window
          window:search("number").text = info.count
        end,
        callback = on_msg
      })
    end
  elseif info.count == 1 then
    local msgend = {
      callback = on_msgend,
      btn_confirm = true,
      btn_cancel = true,
      modal = true,
      only_id = info.only_id,
      count = info.count
    }
    local item_name = ui_account_bank.get_item_name(info.excel_id)
    local accbank_item_in = bo2.gv_accbank_item_in:find(info.excel_id)
    if accbank_item_in == nil then
      ui_account_bank.ui_account_bank_safe.notify(1388)
      return
    end
    local arg = sys.variant()
    arg:set("item_num", info.count)
    arg:set("item_name", item_name)
    arg:set("money_num", accbank_item_in.money)
    msgend.text = sys.mtf_merge(arg, ui.get_text("account_bank|put_item"))
    ui_widget.ui_msg_box.show_common(msgend)
  end
end
function item_rbutton_tip(info)
  local p = bo2.gv_accbank_item_in:find(info.excel.id)
  if p == nil then
    return ui.get_text("account_bank|tip1")
  end
  return ui.get_text("account_bank|tip2")
end
function get_visible()
  local w = ui.find_control("$frame:account_bank")
  return w.visible
end
function show_bank()
  set_visible(true)
  ui_item.set_visible(true)
  ui_item.set_bag_item_flag(true)
end
function close_bank()
  set_visible(false)
  ui_item.set_visible(false)
  ui_item.set_bag_item_flag(false)
end
function set_visible(vis)
  local w = ui.find_control("$frame:account_bank")
  w.visible = vis
end
function get_useable_grid()
  local size = bo2.get_acc_bank_cur_size()
  local w_box = w_root:search(sys.format("box:%d", bo2.eItemBox_AccBank))
  local w_cells = w_box:search("w_cells")
  for i = 0, size - 1 do
    local cell = w_cells:search(sys.format("grid:%d", i))
    local card = cell:search("card")
    local info = ui.item_of_coord(bo2.eItemBox_AccBank, i)
    if info == nil then
      return i, card
    end
  end
  return nil
end
function on_click_tidy_box()
  ui_item.send_tidy(bo2.eItemBox_AccBank)
end
function on_init_box(ctrl, data)
  local w_cells = ctrl:search("w_cells")
  if w_cells == nil then
    ui.log("failed get w_cells.")
    return
  end
  local box = data.v_int
  local b_size = bo2.get_acc_bank_cur_size()
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
      if b_size <= grid then
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
      ui_item.send_accbank(msg.only_id, -1, -1, count)
    end
    if info.count > 1 then
      do
        local cfm_text = ui.get_text("item|cnt_bank_out")
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
      ui_item.send_accbank(info.only_id, -1, -1, info.count)
    end
  end
end
function get_extend_box(cnt)
  return math.floor((cnt - 0) / 16)
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
  if excel == nil or excel.type ~= bo2.eItemType_AccBankBox then
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
  box_resize(bo2.eItemBox_AccBank, cnt)
end
function on_msg(msg)
  if msg.result == 0 then
    return
  end
  send_bank_extend(msg.bank_size)
end
function get_max_bank_size()
  local e_size = bo2.gv_accbank_extend.size
  local b_excel = bo2.gv_accbank_extend:get(e_size - 1)
  local i_excel = bo2.gv_item_list:find(b_excel.bank_item_id)
  return i_excel.use_par[0]
end
function on_buy_click(btn)
  local size = bo2.get_acc_bank_cur_size()
  if size == 0 then
    return
  end
  local bank_extend = bo2.gv_accbank_extend:find(size)
  local max_size = get_max_bank_size()
  if bank_extend == nil then
    if size >= max_size then
      ui_tool.note_insert(ui.get_text("account_bank|tip3"), ui_bank.c_warninig_color)
    end
    return
  end
  msg = {
    callback = on_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    bank_size = size
  }
  if 0 < bank_extend.item_id then
    local item_name = bo2.gv_item_list:find(bank_extend.item_id).name
    local arg = sys.variant()
    arg:set("money", bank_extend.money)
    arg:set("item_num", bank_extend.item_num)
    arg:set("item_name", item_name)
    msg.text = sys.mtf_merge(arg, ui.get_text("account_bank|expand_bank_info2"))
  else
    local arg = sys.variant()
    arg:set("money", bank_extend.money)
    msg.text = sys.mtf_merge(arg, ui.get_text("account_bank|expand_bank_info1"))
  end
  ui_widget.ui_msg_box.show_common(msg)
end
function on_num_max_click(btn)
  local parent = btn.parent.parent
  local frm_input = parent:search("frm_input")
  local input = frm_input:search("box_input")
  input.text = _G.g_num_max
end
function get_item_name(excel_id)
  local item_info = ui.item_get_excel(excel_id)
  return item_info.name
end
function on_account_bank_visible(ctrl, vis)
  local define = bo2.gv_define:find(1096)
  if define ~= nil and define.value ~= L("1") then
    local safebtn = ui_account_bank.w_main:search("btn_3")
    safebtn.visible = false
  end
  ui_widget.on_esc_stk_visible(ctrl, vis)
  if vis then
    return
  end
  ui_item.set_bag_item_flag(false)
end
