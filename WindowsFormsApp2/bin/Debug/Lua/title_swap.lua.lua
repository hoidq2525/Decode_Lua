local ui_title_swap = ui_npcfunc.ui_title_swap
local ui_tree2 = ui_widget.ui_tree2
local ui_cell = ui_npcfunc.ui_cell
local gv_title_swap_catagory = bo2.load_table_lang("$mb/item/title_swap_catagory.xml")
local color_no_have_red = SHARED("FF0000")
local color_no_active_gray = SHARED("808080")
local color_active_green = SHARED("179317")
local color_active_white = SHARED("FFFFFF")
local g_flag_init = false
local is_inner = sys.is_file("$cfg/tool/pix_dj2_config.xml")
function on_npcfunc_open_window(npcfunc_id)
  ui.log("npcfunc_id:" .. npcfunc_id)
  g_npcfunc_id = npcfunc_id
end
function check_search_item(excel)
  if excel == nil or excel._name == nil then
    return true
  end
  local name = g_keyword_box.text
  local text_table
  local t_size = 0
  if 0 < name.size and name ~= L(" ") then
    local var = sys.variant()
    var:set(L("0"), name)
    text_table = var:get(L("0")):split_to_no_repeat_array(L(" "))
    t_size = text_table.size - 1
  end
  if text_table == nil then
    return true
  else
    for i = 0, t_size do
      local n = text_table[i]
      if 0 < n.size and n ~= L(" ") then
        local find_text_idx = excel._name:find(n)
        if find_text_idx < 0 then
          return false
        end
      end
    end
  end
  return true
end
function check_active_title(title_id)
  return ui_personal.ui_title.check_title_is_active_lv_up(title_id)
end
function get_active_title(title_id)
  local info = ui_personal.ui_title.get_active_title(title_id)
  return info
end
function on_check_click(ctrl)
  local root = w_title_view.root
  local node = root:item_get(0)
  for j = 0, node.item_count do
    local leaf = node:item_get(j)
    if leaf ~= nil then
      if w_show_no_have_title.check == true or not g_keyword_box.text.empty then
        local line = leaf.svar.line
        local excel = bo2.gv_title_list:find(line.title_id)
        if not check_search_item(excel) or check_active_title(line.title_id) then
          leaf.display = false
        else
          leaf.display = true
        end
      else
        leaf.display = true
      end
    end
  end
  node.expanded = true
end
function detail_clear()
  local title_pic = w_title:search("title_pic")
  local pic = title_pic:search("pic")
  pic.image = ""
  local info = w_title:search("right_info")
  local name = info:search("name"):search("text")
  name.text = ""
  local state = info:search("state"):search("text")
  state.text = ""
  local rate = info:search("rate"):search("text")
  rate.text = ""
  w_title_item_list:item_clear()
  for i = 0, 2 do
    local item = w_title_item_list:item_append()
    item:load_style("$frame/npcfunc/title_swap.xml", "title_item")
  end
end
function on_item_sel(item, sel)
  w_title_view.svar.leaf_item_sel = nil
  if not sel then
    detail_clear()
    return
  end
  w_title_view.svar.leaf_item_sel = item
  if not item or not item.svar or not item.svar.line then
    return
  end
  local line = item.svar.line
  local title_pic = w_title:search("title_pic")
  local pic = title_pic:search("pic")
  local excel = bo2.gv_title_list:find(line.title_id)
  local def_pic = "$image/item/pic_item_grid.png"
  if excel.pic and excel.pic.size > 0 then
    def_pic = excel.pic
  elseif 0 < line.v_item_ids.size then
    local id = line.v_item_ids[0]
    local excel_sc = bo2.gv_scroll_item:find(id)
    if excel_sc ~= nil then
      def_pic = sys.format("$icon/item/%s.png", excel_sc.icon)
      def_pic = string.gsub(tostring(def_pic), ".png.png", ".png")
    end
  end
  pic.image = def_pic
  local info = w_title:search("right_info")
  local name = info:search("name"):search("text")
  name.text = excel._name
  name.color = ui.make_color(color_active_white)
  local b_active = check_active_title(excel.id)
  local state = info:search("state"):search("text")
  if b_active then
    state.text = ui.get_text("npcfunc|title_have")
    state.color = ui.make_color(color_active_green)
  else
    state.text = ui.get_text("npcfunc|title_unhave")
    state.color = ui.make_color(color_no_active_gray)
  end
  local title_rate_total = 0
  local title_rate_now = 0
  local function set_cell(cell, excel, k, line)
    local card = cell:search("cell_base"):search("card")
    local need_num = 99999
    card.excel_id = excel.id
    local rate_total = 99999
    local rate_now = 99999
    local dis_info = ui.discover_find_by_scroll(excel.id)
    if dis_info ~= nil then
      if dis_info.study == -1 then
        rate_now = dis_info.excel.gold_study
      else
        rate_now = dis_info.study
      end
      rate_total = dis_info.excel.gold_study
    elseif bo2.gv_use_list:find(excel.use_id).model == bo2.eUseMod_AddTitle then
      rate_now = 0
      rate_total = 1
      if b_active then
        rate_now = 1
      end
    elseif excel.discover ~= 0 then
      rate_now = 1
      local discover_list = bo2.gv_discover_list:find(excel.discover)
      rate_total = discover_list.gold_study
    end
    card.require_count = rate_total - rate_now
    title_rate_total = title_rate_total + rate_total
    title_rate_now = title_rate_now + rate_now
    local info1 = cell:search("right_info")
    local rate = info1:search("rate")
    rate:search("text").text = rate_now .. "/" .. rate_total
    local name = info1:search("name")
    name:search("text").color = ui.make_color(excel.plootlevel.color)
    name:search("text").text = excel.name
    local money = info1:search("money")
    local str = ui_widget.merge_mtf({
      price = line.v_moneys[k]
    }, ui.get_text("npcfunc|title_buy_singleprice"))
    money:search("price").mtf = moneyf(str)
    local btn_buy = info1:search("btn_buy")
    btn_buy.visible = true
  end
  w_title_item_list:item_clear()
  for i = 0, line.v_item_ids.size - 1, 2 do
    local item = w_title_item_list:item_append()
    item:load_style("$frame/npcfunc/title_swap.xml", "title_item")
    local cell = item:search("cell")
    for j = 0, 1 do
      local id = line.v_item_ids[i + j]
      local excel = bo2.gv_scroll_item:find(id)
      if excel ~= nil then
        local cell_tmp = cell:search("cell" .. j)
        set_cell(cell_tmp, excel, i + j, line)
      end
    end
  end
  local rate = info:search("rate")
  rate:search("text").text = title_rate_now .. "/" .. title_rate_total
end
function build_node(line)
  local node = ui_tree2.insert(w_title_view.root)
  ui_tree2.set_text(node, line.name)
  node.svar.category = line
  node.expanded = true
  return node
end
function build_leaf(line, node, excel)
  local item = ui_tree2.insert(node)
  item.svar.line = line
  local color = color_no_have_red
  if check_active_title(excel.id) then
    color = color_active_white
  else
    color = color_no_active_gray
  end
  ui_tree2.set_text(item, excel._name, color)
end
function on_update()
  on_init(nil)
  if w_title_view.svar.leaf_item_sel then
    on_item_sel(w_title_view.svar.leaf_item_sel, true)
  end
  w_title_view.scroll = w_title_view.scroll
end
function on_update_title(cmd, data)
  local iExcelID = data:get(packet.key.item_key).v_int
  local pExcelData = bo2.gv_title_list:find(iExcelID)
  if pExcelData == nil then
    return
  end
  for k = 0, bo2.gv_title_swap.size - 1 do
    local line = bo2.gv_title_swap:get(k)
    if line and line.off ~= 1 and line.title_id == iExcelID then
      bo2.AddTimeEvent(5, on_update())
      break
    end
  end
end
function on_update_use(cmd, data)
  if w_title_view.svar.leaf_item_sel then
    on_item_sel(w_title_view.svar.leaf_item_sel, true)
  end
end
function on_init(ctrl)
  w_title_view.root:item_clear()
  local node = build_node(gv_title_swap_catagory:get(0))
  for k = 0, bo2.gv_title_swap.size - 1 do
    local line = bo2.gv_title_swap:get(k)
    if line and line.off ~= 1 then
      local excel = bo2.gv_title_list:find(line.title_id)
      if excel then
        build_leaf(line, node, excel)
      end
    end
  end
end
function repeat_chose_rose()
  if w_title_view.svar.leaf_item_sel == nil or w_title_view.svar.leaf_item_sel.svar == nil or w_title_view.svar.leaf_item_sel.svar.line == nil then
    w_title_item_list:item_clear()
    for i = 0, 2 do
      local item = w_title_item_list:item_append()
      item:load_style("$frame/npcfunc/title_swap.xml", "title_item")
    end
  end
end
function on_visible(w, vis)
  ui_widget.on_visible_sound(w, vis)
  ui_npcfunc.on_visible(w, vis)
  if not g_flag_init then
    on_init(nil)
    g_flag_init = true
    detail_clear()
    ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_Title, on_update_title, "ui_npcfunc.ui_title_swap:on_signal")
    ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_Discover, on_update_use, "ui_npcfunc.ui_title_swap:on_discover")
  end
  repeat_chose_rose()
end
function on_input_change(tb, txt)
  input_mask.visible = g_keyword_box.text.empty
end
function on_search(ctrl)
  on_check_click(ctrl)
end
function on_keydown_return(ctrl, key, keyflag)
  if key == ui.VK_RETURN and keyflag.down then
    on_search(ctrl)
  end
end
function get_item_price(excel_id)
  local line = w_title_view.svar.leaf_item_sel.svar.line
  for i = 0, line.v_item_ids.size - 1 do
    if line.v_item_ids[i] == excel_id then
      return line.v_moneys[i]
    end
  end
  return 0
end
function get_my_money(ctrl)
  return bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_MoneyDaibi)
end
function moneyf(str)
  return sys.format("%s<daibi:18>", str)
end
function on_btn_buy(btn)
  local sel_line = w_title_view.svar.leaf_item_sel.svar.line
  if sel_line == nil then
    return
  end
  local card = btn.parent.parent:search("card")
  local excel = card.excel
  ui_widget.ui_msg_box.show_common({
    style_uri = "$frame/npcfunc/title_swap.xml",
    style_name = "buy",
    modal = true,
    init = function(data)
      local w = data.window
      local card1 = w:search("itembox"):search("card")
      card1.excel_id = excel.id
      w:search("name").text = excel.name
      local price = get_item_price(excel.id)
      local str = ui_widget.merge_mtf({price = price}, ui.get_text("npcfunc|title_buy_singleprice"))
      w:search("price").mtf = moneyf(str)
      w:search("num").focus = true
      local my_money = get_my_money()
      local function update()
        local pay = price * w:search("num").text.v_int
        local str = ui_widget.merge_mtf({num = pay}, ui.get_text("npcfunc|title_buy_pay"))
        w:search("pay").mtf = moneyf(str)
        w:search("rmb").mtf = ui_widget.merge_mtf({num = my_money}, ui.get_text("npcfunc|title_buy_have_money"))
      end
      update()
      local timer = w:find_plugin("timer")
      timer.suspended = false
      timer:insert_on_timer(update)
    end,
    callback = function(rst)
      if rst.result == 1 then
        do
          local w = rst.window
          local n = w:search("num").text.v_int
          if n == 0 then
            return
          end
          local price = get_item_price(excel.id)
          local my_money = get_my_money()
          local pay = n * price
          if my_money < pay then
            ui_chat.show_ui_text_id(72145)
            return
          end
          local function send()
            local v = sys.variant()
            v:set(packet.key.talk_excel_id, g_npcfunc_id)
            v:set(packet.key.item_excelid, excel.id)
            v:set(packet.key.item_count, n)
            v:set(packet.key.cmn_id, sel_line.id)
            bo2.send_variant(packet.eCTS_UI_NpcFuncItem, v)
          end
          local function on_btn_msg(msg)
            if msg.result == 1 then
              send()
            end
          end
          if not check_active_title(sel_line.title_id) then
            send()
            return
          end
          local msg = {
            callback = on_btn_msg,
            btn_confirm = true,
            btn_cancel = true,
            modal = true
          }
          msg.text = ui.get_text("npcfunc|title_have_title_confirm")
          ui_widget.ui_msg_box.show_common(msg)
        end
      end
    end
  })
end
function ctip_make_item_icon(stk_orig, excel, info)
  local stk = sys.mtf_stack()
  local ncnt = 0
  function push_newline()
    ncnt = ncnt + 1
    if ncnt == 1 then
      return
    end
    stk_orig:raw_push(ui_tool.cs_tip_newline)
  end
  if is_inner then
    push_newline()
    ui_tool.ctip_push_text(stk_orig, "ID = " .. excel.id)
  end
  local def_pic = "$image/item/pic_item_grid.png"
  if excel.pic then
    def_pic = excel.pic
  end
  stk_orig:raw_format([[

<img:%s*32,32>]], def_pic)
end
function ctip_make_title_ex(stk, name, color)
  local fmt = ui_tool.cs_tip_title_enter
  if color ~= nil then
    if not sys.is_type(color, "number") then
      fmt = ui_tool.cs_tip_title_enter_s
    end
  else
    fmt = ui_tool.cs_tip_title_enter_n
  end
  stk:raw_format(fmt, color)
  stk:push(name)
  stk:raw_push(ui_tool.cs_tip_title_leave)
end
function ctip_make_item(stk, excel)
  local colcor = ui.make_color(excel._color)
  ctip_make_title_ex(stk, excel._name, colcor)
  ctip_make_item_icon(stk, excel, info)
  if not excel.detail_desc.empty then
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|title_tip_detail_desc"), color_active_green, ui_tool.cs_tip_a_add_l)
    ui_tool.ctip_push_newline(stk)
    stk:raw_format("<c+:FFFFFF>%s<c->", excel.detail_desc, ui_tool.cs_tip_a_add_r)
  end
  local nSizeTrait = excel._attribute.size
  if nSizeTrait ~= 0 then
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("npcfunc|title_tip_attribute"), color_active_green, ui_tool.cs_tip_a_add_l)
    ui_tool.ctip_push_newline(stk)
    for i = 0, nSizeTrait - 1 do
      local trait_des = ui_tool.ctip_trait_text(excel._attribute[i])
      ui_tool.ctip_push_text(stk, trait_des, "FFFFFF", ui_tool.cs_tip_a_add_r)
      ui_tool.ctip_push_newline(stk)
    end
  end
end
function on_title_tip_make(tip)
  if not w_title_view.svar.leaf_item_sel then
    return
  end
  local stk = sys.mtf_stack()
  local line = w_title_view.svar.leaf_item_sel.svar.line
  local excel = bo2.gv_title_list:find(line.title_id)
  if excel == nil then
    return
  end
  ctip_make_item(stk, excel)
  ui_tool.ctip_show(tip.owner, stk)
end
function on_item_box_tip_show(tip)
  ui_npcfunc.ui_cell.on_tip_show(tip)
end
