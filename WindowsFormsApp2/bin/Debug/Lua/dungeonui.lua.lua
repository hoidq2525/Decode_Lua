local ui_tab = ui_widget.ui_tab
local cs_item_grid = SHARED("$image/item/pic_item_grid.png|0,0,36,36")
local cs_item_bad = SHARED("$image/item/pic_item_bad.png|0,0,36,36")
c_text_item_file = L("$frame/dungeonui/dungeonui.xml")
c_text_item_cell = L("item_cell")
c_text_boss_cell = L("boss_cell")
boss_style = L("cmn_boss_item")
c_item_size = 37
c_item_column = 4
c_item_line = 2
function on_init_box(ctrl, data)
end
function find_unused_card(all_cards)
  for i, v in ipairs(all_cards) do
    local card = v:search("card")
    if card.excel_id == 0 then
      return card
    end
  end
end
function find_used_ctrl(all_cards)
  for i, v in ipairs(all_cards) do
    local card = v:search("card")
    if card.excel_id == 0 then
      v:search("itembg").image = cs_item_bad
    end
  end
end
function on_item_ctrls(ctrlpanel)
  local item_cards = {}
  local ctop = ctrlpanel:search("citem")
  if ctop == nil then
    return
  end
  for y = 1, c_item_line do
    for x = 1, c_item_column do
      local ctrl = ui.create_control(ctop, "panel")
      ctrl:load_style(c_text_item_file, c_text_item_cell)
      ctrl.offset = ui.point(x * c_item_size, y * c_item_size)
      local card = ctrl:search("card")
      table.insert(item_cards, ctrl)
    end
  end
  return item_cards
end
function on_init_list(data)
  local eachofboss = {}
  local information = get_information(data)
  local fubenintro = information[1]
  theintro.mtf = ui_widget.merge_mtf({
    btn_desc = bo2.gv_text:find(82053).text
  }, bo2.gv_text:find(fubenintro).text)
  theintro.slider_y.scroll = 0
  local numsofboss = information[2]
  boss_nums.text = numsofboss .. ui.get_text("dungeonui|nums_unit")
  eachofboss = information[3]
  boss_list:item_clear()
  for i = 1, numsofboss do
    local item = boss_list:item_append()
    item:load_style(c_text_item_file, boss_style)
    local the_item_cards = on_item_ctrls(item)
    local bossuri = "$icon/portrait/" .. eachofboss[i][1] .. ".png"
    local equipsofboss = eachofboss[i][2]
    local bossname = eachofboss[i][3]
    local equipnum = equipsofboss[1]
    local cboss = item:search("cboss")
    local theboss = ui.create_control(cboss, "panel")
    theboss:load_style(c_text_item_file, c_text_boss_cell)
    theboss:search("bossimage").image = bossuri
    thename.text = bossname
    for j = 2, equipnum + 1 do
      local card, v = find_unused_card(the_item_cards)
      if card ~= nil then
        card.excel_id = equipsofboss[j]
      end
    end
    find_used_ctrl(the_item_cards)
  end
end
function insert_tab(name)
  local btn_uri = "$frame/dungeonui/dungeonui.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/dungeonui/dungeonui.xml"
  local page_sty = name
  ui_tab.insert_suit(w_item, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(w_item, name)
  btn.text = ui.get_text("dungeonui|" .. name)
end
function on_init(ctrl)
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
