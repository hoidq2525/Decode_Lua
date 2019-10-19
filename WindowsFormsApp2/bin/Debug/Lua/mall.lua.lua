local ui_tab = ui_widget.ui_tab
function on_init(ctrl)
end
function on_box_observable(w, vis)
  local w = ui.find_control("$frame:item")
  if w ~= nil then
    w.visible = vis
  end
end
function on_wnd_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis == false then
    if w.var:get("server_close_talk").v_int == 1 then
      return
    end
    local d = sys.variant()
    d:set("kind", bo2.eTalkSel_Null)
    d:set("id", 1)
    bo2.send_wrap(packet.eSTC_Fake_talk_sel, d)
    ui_mall.ui_build.g_input_name.text = L("")
    ui_mall.ui_build.w_mask_name.visible = true
  end
end
function compare_str(item1, item2, field)
  local str1 = item1:search(field).text
  local str2 = item2:search(field).text
  if str1 < str2 then
    return -1
  elseif str1 == str2 then
    return 0
  end
  return 1
end
function compare_num(item1, item2, field)
  local num1 = item1:search(field).text.v_int
  local num2 = item2:search(field).text.v_int
  if num1 < num2 then
    return -1
  elseif num1 == num2 then
    return 0
  end
  return 1
end
function compare_mny(item1, item2, field)
  local mny1 = item1:search(field).money
  local mny2 = item2:search(field).money
  if mny1 < mny2 then
    return -1
  elseif mny1 == mny2 then
    return 0
  end
  return 1
end
function create_box(parent, dx, dy, uri, box)
  if parent == nil then
    return
  end
  local function create_cell(x, y)
    local ctrl = ui.create_control(parent, "panel")
    ctrl:load_style(uri, "cmn_item")
    local L = 36
    ctrl.offset = ui.point(x * L, y * L)
    local card = ctrl:search("card")
    card.box = box
    card.grid = y * dx + x
    ctrl.name = sys.format("grid:%d", card.grid)
    ctrl.svar.total = 0
    return ctrl
  end
  parent:control_clear()
  parent.name = sys.format("box:%d", box)
  for y = 0, dy - 1 do
    for x = 0, dx - 1 do
      create_cell(x, y)
    end
  end
end
function create_shelfitembox(parent, uri, box)
  if parent == nil then
    return
  end
  local function create_itemcell()
    local w = ui.create_control(parent, "panel")
    w:load_style(uri, "shelf_panel")
    local card = w:search("card")
    card.box = 127
    card.grid = box - bo2.eItemBox_Mall_Sell1
  end
end
function box_resize(w_box, max_cnt, cnt)
  if max_cnt < cnt then
    cnt = max_cnt
  end
  for i = 0, cnt - 1 do
    local ctrl = w_box:search(sys.format("grid:%d", i))
    ctrl:search("card").enable = true
    ctrl:search("bg").visible = true
  end
  for i = cnt, max_cnt - 1 do
    local ctrl = w_box:search(sys.format("grid:%d", i))
    ctrl:search("card").enable = false
    ctrl:search("bg").visible = false
  end
end
function insert_mall_pet(root)
  local leaf_name = L("mall_pet")
  local leaf_item = root:item_append()
  local style_uri = L("$frame/mall/common.xml")
  leaf_item:load_style(style_uri, leaf_name)
  local card = leaf_item:search("card")
  card.index = root.item_count - 1
  card.box = bo2.ePetBox_Mall
  local pet_info = card.info
  leaf_item.svar.id = card.only_id
  leaf_item.svar.total = 0
  leaf_item:search("name").text = pet_info.name
  leaf_item:search("level").text = ui.get_text("mall|lvl_lb") .. pet_info:get_atb(bo2.eFlag_Pet_Level)
  leaf_item:search("price").money = pet_info:get_atb(bo2.eFlag_Pet_ShopPrice)
  local gen_atb = {
    value = bo2.eFlag_Pet_GenGrowth
  }
  leaf_item:search("star").dx = 16 * ui_pet.get_star_num(pet_info, gen_atb) / 2
  leaf_item:search("star_max").dx = 16 * ui_pet.get_star_max(pet_info, gen_atb) / 2
end
function erase_mall_pet(root, id)
  for i = 0, root.item_count - 1 do
    local item = root:item_get(i)
    if item.svar.id == id then
      root:item_remove(i)
      break
    end
  end
  for i = 0, root.item_count - 1 do
    local item = root:item_get(i)
    local card = item:search("card")
    card.index = i
    card.box = bo2.ePetBox_Mall
  end
end
function clear_mall_pet(root)
  ui.pet_clear_pet_vec(bo2.ePetBox_Mall)
  root:item_clear()
end
function on_click_sort_btn(ctrl)
  local root = ctrl.parent
  if root.svar.sort == nil then
    root.svar.sort = {
      text = L(""),
      dir = 0
    }
  end
  local sort = root.svar.sort
  if sort.name == ctrl.name then
    if sort.dir == 1 then
      sort.dir = 0
      ctrl:search("inc").visible = false
      ctrl:search("dec").visible = true
    else
      sort.dir = 1
      ctrl:search("inc").visible = true
      ctrl:search("dec").visible = false
    end
  else
    local oldBtn = root:search(sort.name)
    if oldBtn ~= nil then
      oldBtn:search("inc").visible = false
      oldBtn:search("dec").visible = false
    end
    sort.name = ctrl.name
    sort.dir = 1
    ctrl:search("inc").visible = true
    ctrl:search("dec").visible = false
  end
end
function find_parent(ctrl, name)
  while ctrl ~= nil do
    if ctrl.name == name then
      return ctrl
    end
    ctrl = ctrl.parent
  end
  return nil
end
