g_all_stall_list = sys.variant()
COLOR_white = "FFFFFF"
COLOR_grey = "7D7D7D"
COLOR_orange = "FF8000"
COLOR_green = "00DB00"
COLOR_blue = "0080FF"
COLOR_gold = "0080FF"
local singlestall = {}
local ui_combo = ui_widget.ui_combo_box
local tip_index = 0
local gx_selected_item
local mark_index = 0
color_table = {
  {
    index = 0,
    colorname = ui.get_text("stall|stall_white"),
    colorcode = COLOR_white,
    btnuri = "$image/widget/btn/btn_white.png|0,0,16,56"
  },
  {
    index = 2,
    colorname = ui.get_text("stall|stall_orange"),
    colorcode = COLOR_orange,
    btnuri = "$image/widget/btn/btn_orange.png|0,0,16,56"
  },
  {
    index = 3,
    colorname = ui.get_text("stall|stall_green"),
    colorcode = COLOR_green,
    btnuri = "$image/widget/btn/btn_green.png|0,0,16,56"
  },
  {
    index = 4,
    colorname = ui.get_text("stall|stall_blue"),
    colorcode = COLOR_blue,
    btnuri = "$image/widget/btn/btn_blue.png|0,0,16,56"
  },
  {
    index = 5,
    colorname = ui.get_text("stall|stall_grey"),
    colorcode = COLOR_grey,
    btnuri = "$image/widget/btn/btn_grey.png|0,0,16,56"
  }
}
local type_table = {
  {
    index = 0,
    typename = ui.get_text("stall|stall_null")
  },
  {
    index = 1,
    typename = ui.get_text("stall|stall_gem")
  },
  {
    index = 2,
    typename = ui.get_text("stall|stall_equip")
  },
  {
    index = 3,
    typename = ui.get_text("stall|stall_clothes")
  },
  {
    index = 4,
    typename = ui.get_text("stall|stall_medicine")
  },
  {
    index = 5,
    typename = ui.get_text("stall|stall_food")
  },
  {
    index = 6,
    typename = ui.get_text("stall|stall_weapon")
  },
  {
    index = 7,
    typename = ui.get_text("stall|stall_guild")
  },
  {
    index = 8,
    typename = ui.get_text("stall|stall_others")
  }
}
local set_sel_table = {}
local function set_table()
  for i, v in ipairs(type_table) do
    local tb = {}
    tb.index = v.index
    tb.typename = v.typename
    if i == 1 then
      tb.typename = ui.get_text("stall|stall_all")
    end
    table.insert(set_sel_table, tb)
  end
end
set_table()
function get_visible()
  local w = ui_stall.surround.gx_main_window
  return w.visible
end
function get_stall_vip()
  return false
end
function set_visible(vis)
  local ws = ui_stall.surround.gx_main_window
  ws.visible = vis
  if vis == true then
    local w = ui_stall.viewer.g_viewer
    ws:move_to_head()
    ws.margin = ui.rect(w.margin.x1, w.margin.y1, w.margin.x2 - w.dx, w.margin.y2)
  end
end
function find_the_ctrl(mainctrl)
  for i, v in ipairs(mainctrl) do
    if v ~= nil then
      return v
    end
  end
end
function on_init(mainwin)
  g_all_stall_list:clear()
  g_surround = {}
  local ctrl = mainwin:search("g_stalllist")
  if ctrl ~= nil then
    table.insert(g_surround, ctrl)
  end
end
function table_clear(stall_table)
  for i, v in ipairs(stall_table) do
    stall_table[i] = nil
  end
end
function get_stall_state(hHandle)
  if hHandle == nil or hHandle == 0 then
    return false
  end
  local scn = bo2.scn
  if scn == nil then
    return false
  end
  local obj = scn:get_scn_obj(hHandle)
  if obj ~= nil and obj.kind == bo2.eScnObjKind_Player and obj:get_flag_objmem(bo2.eFlagObjMemory_Stalling) ~= 0 then
    return true
  end
  return false
end
function get_stallsur_table(scn_unit)
  local stall_table = {}
  local stallname_table = {}
  local my_name = bo2.player.name
  local function insert_table(target, stallname)
    if target.name == my_name then
      return
    end
    local keyhandle = target.sel_handle
    local keyname = stallname
    local open_time = target:get_flag_objmem(bo2.eFlagObjMemory_StallOpenTime)
    table.insert(stall_table, {
      key = keyhandle,
      stall_name = stallname,
      open_time = open_time
    })
    if g_all_stall_list:has(keyhandle) then
      local v = g_all_stall_list:get(keyhandle)
      local mark_open_time = v:get("open_time").v_int
      if mark_open_time ~= open_time then
        v:set("open_time", open_time)
        v:set("color", COLOR_white)
        v:set("type", "")
      else
        local colorcode = v:get("color").v_string
        local type_name = v:get("type").v_string
        scn_unit:SetOpenedStall(keyhandle, colorcode, type_name)
      end
    else
      local v = sys.variant()
      v:set("open_time", open_time)
      v:set("color", COLOR_white)
      v:set("type", "")
      g_all_stall_list:set(keyhandle, v)
    end
  end
  scn_unit:ForEachScnStall(insert_table)
  return stall_table, stallname_table
end
function show_stallsur(scn_unit, stall_table)
  local tablesize = table.maxn(stall_table)
  gx_stalllist:item_clear()
  local thectrl = find_the_ctrl(g_surround)
  for i = 1, tablesize do
    local thectrl = find_the_ctrl(g_surround)
    local stall_info = thectrl:item_append()
    stall_info:load_style("$frame/stall/stall_surround.xml", L("show_info"))
    local v_item = stall_table[i]
    local cb = stall_info
    local svar = cb.svar
    local list = svar.list
    for i, v in ipairs(type_table) do
      ui_combo.append(cb, {
        id = v.index,
        text = v.typename,
        style_uri = "$gui/frame/stall/stall_surround.xml",
        style = "type_item",
        parent_ctr = cb
      })
    end
    local color_list = svar.color_list
    for i, v in ipairs(color_table) do
      local color_item = {
        index = v.index,
        colorname = v.colorname,
        btnuri = v.btnuri,
        colorcode = v.colorcode,
        parent_ctr = cb
      }
      table.insert(color_list, color_item)
    end
    cb.svar.index = i - 1
    cb.svar.stall_key = v_item.key
    cb.svar.stall_name = v_item.stall_name
    cb.svar.stall_info = stall_info
    cb.svar.on_select = on_mainlb_select
    local ctr_stall = stall_info:search("stall_name")
    ctr_stall:insert_on_mouse(stall_item_on_mouse)
    if v_item.key ~= nil then
      ctr_stall.text = v_item.stall_name
      local type_name = scn_unit:GetOpenedStallType(v_item.key)
      if type_name ~= L("") then
        local id = get_type_id(cb, type_name)
        ui_combo.select(cb, id)
        ctr_stall.text = "[" .. type_name .. "]" .. ctr_stall.text
        cb.svar.selected_type_id = id
      else
        ui_combo.select(cb, 0)
      end
      cb.svar.open_time = v_item.open_time
      local color_code = scn_unit:GetOpenedStallColor(v_item.key)
      if color_code ~= L("") then
        local color_id = get_color_id(cb, color_code)
        set_color(cb, color_id)
      else
        set_color(cb, 0)
      end
    end
  end
end
function on_chg_stall_color(stall_keyhandle, typename, colorcode)
  local scn = bo2.scn
  if scn ~= nil then
    scn:SetOpenedStall(stall_keyhandle, colorcode, typename)
    local v = g_all_stall_list:get(stall_keyhandle)
    v:set("color", colorcode)
    v:set("type", typename)
    g_all_stall_list:set(stall_keyhandle, v)
  end
end
function remove_null_item(svar)
  local stallinfo = svar.stall_info
  local stall_keyhandle = svar.stall_key
  local view_handle = ui_stall.viewer.g_data.key_handle
  if view_handle ~= nil and view_handle == stall_keyhandle then
    ui_stall.viewer.set_visible(false)
  end
  if stall_info == gx_selected_item then
    gx_selected_item = nil
  end
  ui_chat.show_ui_text_id(1531)
  stallinfo:self_remove()
end
function sort_marked(stallitem)
  local cur_index = stallitem.index
  if cur_index >= mark_index then
    stallitem.index = mark_index
    mark_index = mark_index + 1
  end
end
function on_mainlb_select(item)
  local index = item.id
  local cb = item.data.parent_ctr
  local svar = cb.svar
  local stallinfo = svar.stall_info
  local stall_keyhandle = svar.stall_key
  local state = get_stall_state(stall_keyhandle)
  if state ~= true then
    remove_null_item(svar)
    return
  end
  if index > 0 then
  end
  svar.selected_type_id = index
  ui_combo.select(cb, index)
  local ctrstall = stallinfo:search("stall_name")
  local type_name = item.text
  ctrstall.text = svar.stall_name
  ctrstall.text = "[" .. type_name .. "]" .. ctrstall.text
  local color_btn = stallinfo:search("color_button")
  local select_color_item = svar.selected_color
  if select_color_item == nil then
    select_color_item = svar.color_list[1]
  end
  local color_id = select_color_item.index
  set_color(cb, color_id)
  local type_selected = svar.selected
  on_chg_stall_color(stall_key, type_name, select_color_item.colorcode)
end
function search_stall(scn_unit)
  local get_stall_table, get_stallname_table = get_stallsur_table(scn_unit)
  show_stallsur(scn_unit, get_stall_table)
  local cb = ui_stall.surround.set_select_btn
  ui_combo.clear(cb)
  for i, v in ipairs(set_sel_table) do
    ui_combo.append(cb, {
      id = v.index,
      text = v.typename,
      parent_ctr = cb
    })
  end
  ui_combo.select(ui_stall.surround.set_select_btn, 0)
  ui_stall.surround.set_select_btn.svar.on_select = on_set_select
  stallname_table = get_stallname_table
end
function on_set_select(item)
  local id = item.data.id
  local thectrl = find_the_ctrl(g_surround)
  local count = thectrl.item_count
  local index = 0
  for i = 0, count - 1 do
    local item = thectrl:item_get(i)
    local type_id = item.svar.selected_type_id
    if id ~= 0 then
      if type_id ~= id then
        item.visible = false
      else
        item.visible = true
        item.index = index
        index = index + 1
      end
    else
      item.visible = true
    end
  end
  if index == 0 then
    ui_chat.show_ui_text_id(85058)
  end
end
function refresh_stallsur()
  local scn = bo2.scn
  if scn ~= nil then
    search_stall(scn)
  end
end
function set_select(btn)
  local cb = ui_stall.surround.set_select_btn
  local items = {}
  local svar = cb.svar
  local t = svar.list
  for i, v in ipairs(t) do
    local item = {
      id = v.id,
      text = v.text,
      style_uri = v.style_uri,
      style = v.style,
      enable = true,
      data = v
    }
    table.insert(items, item)
  end
  local function on_event_list_select(item)
    ui_combo.select(cb, item.id)
    local event = svar.on_select
    if event == nil then
      return
    end
    event(item)
  end
  ui_tool.show_menu({
    items = items,
    event = on_event_list_select,
    source = btn,
    popup = "y_auto",
    dx = 150,
    dy = 120,
    vs = true
  })
end
function select_type(btn)
  local cb = btn:upsearch_name("show_info")
  if cb == nil then
    return
  end
  local items = {}
  local svar = cb.svar
  local t = svar.list
  for i, v in ipairs(t) do
    local item = {
      id = v.id,
      text = v.text,
      style_uri = v.style_uri,
      style = v.style,
      enable = true,
      data = v
    }
    table.insert(items, item)
  end
  local function on_event_list_select(item)
    ui_combo.select(cb, item.id)
    local event = svar.on_select
    if event == nil then
      return
    end
    event(item)
  end
  ui_tool.show_menu({
    items = items,
    event = on_event_list_select,
    source = btn,
    popup = "y_auto",
    dx = 80,
    dy = 100,
    vs = true
  })
end
function func_clr(cb)
  local svar = cb.svar
  local ctrstall = svar.color_btn
  local stall_key = svar.stall_key
  local stall_info = svar.stall_info
  local state = get_stall_state(stall_key)
  if state ~= true then
    remove_null_item(svar)
    return
  end
  local ctrstall = stall_info:search("stall_name")
  ctrstall.text = svar.stall_name
  ui_combo.select(cb, 0)
  set_color(cb, 0)
end
function on_click_clr_color(btn)
  local ctrbtn = btn:upsearch_name("show_info")
  func_clr(ctrbtn)
end
function on_click_clr_all(btn)
  local thectrl = find_the_ctrl(g_surround)
  local size = thectrl.item_count
  for i = 0, size - 1 do
    local stallitem = thectrl:item_get(i)
    func_clr(stallitem)
  end
end
function set_stall_color(stallkey, cb)
  local scn = bo2.scn
  local set_grey = false
  if cb == nil then
    local thectrl = find_the_ctrl(g_surround)
    local size = thectrl.item_count
    for i = 0, size - 1 do
      local stallitem = thectrl:item_get(i)
      if stallitem.svar.stall_key == stallkey then
        cb = stallitem
        break
      end
    end
  end
  if scn ~= nil then
    local color_code = scn:GetOpenedStallColor(stallkey)
    if color_code ~= L("") then
      local color_id = get_color_id(cb, color_code)
      if color_id ~= 2 and color_id ~= 3 and color_id ~= 4 then
        set_grey = true
      end
    else
      set_grey = true
    end
    if set_grey == true then
      local type_name = scn:GetOpenedStallType(stallkey)
      local colorcode = ui_stall.surround.COLOR_grey
      scn:SetOpenedStall(stallkey, colorcode, type_name)
      local v = g_all_stall_list:get(stallkey)
      v:set("color", colorcode)
      v:set("type", type_name)
      g_all_stall_list:set(stallkey, v)
      if cb ~= nil then
        set_color(cb, 5)
      end
    end
  end
end
function stall_item_on_mouse(ctr, msg)
  local parent = ctr:upsearch_name("show_info")
  if parent == nil then
    return
  end
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_dbl then
    parent:select(true)
    local cb = parent
    local svar = cb.svar
    local stall_key = svar.stall_key
    local stall_info = svar.stall_info
    local state = get_stall_state(stall_key)
    if state == true then
      gx_selected_item = parent
      local v = sys.variant()
      v:set(packet.key.scnobj_handle, stall_key)
      bo2.send_variant(packet.eCTS_UI_GetStallSur, v)
      set_stall_color(stall_key, cb)
    else
      remove_null_item(svar)
    end
  end
end
function OnSelectStallSur(ctr, vis)
  if ctr:search("hilight") == nil then
    return
  end
  ctr:search("hilight").visible = vis
end
function select_color(btn, msg)
  if msg ~= ui.mouse_lbutton_up then
    return
  end
  local cb = btn.parent
  local items = {}
  local svar = cb.svar
  local color_list = svar.color_list
  local stall_key = svar.stall_key
  local stall_info = svar.stall_info
  local state = get_stall_state(stall_key)
  if state ~= true then
    remove_null_item(svar)
    return
  end
  local select_color_item = svar.selected_color
  if select_color_item == nil then
    select_color_item = color_list[0]
  end
  local color_id = select_color_item.index
  if color_id == 0 or color_id == 1 then
    set_color(cb, 2)
  elseif color_id == 4 or color_id == 5 then
    set_color(cb, 0)
  else
    set_color(cb, color_id + 1)
  end
end
function get_type_id(cb, type)
  local svar = cb.svar
  local id
  if type ~= nil then
    local t = svar.list
    for i, v in ipairs(t) do
      if L(v.text) == type then
        id = v.id
        break
      end
    end
  end
  return id
end
function get_color_id(cb, colorcode)
  local id
  for i, v in ipairs(color_table) do
    if L(v.colorcode) == colorcode then
      id = v.index
      break
    end
  end
  return id
end
function set_color(cb, id, flag)
  local svar = cb.svar
  local item
  if id ~= nil then
    local t = svar.color_list
    for i, v in ipairs(t) do
      if v.index == id then
        item = v
        break
      end
    end
  end
  set_select_color(svar, item, flag)
end
function set_select_color(svar, item, flag)
  svar.selected_color = item
  if item ~= nil then
    local btn = svar.color_btn
    local tip = btn.tip
    if flag == nil then
    end
    tip_index = item.index
    local btn_picture = svar.color_btn:search("button_picture")
    if btn_picture ~= nil and item.btnuri ~= nil then
      btn_picture.image = item.btnuri
    end
    local stall_info = svar.stall_info
    local stall_key = svar.stall_key
    local ctrstall = stall_info:search("stall_name")
    ctrstall.color = ui.make_color(item.colorcode)
    local type_selected = svar.selected
    on_chg_stall_color(stall_key, type_selected.text, item.colorcode)
  else
  end
end
function show_info_init(cb)
  ui_widget.ui_combo_box.on_init(cb)
  local svar = cb.svar
  svar.color_list = {}
  svar.color_btn = cb:search("color_button")
  svar.color_btn:insert_on_mouse(select_color)
  svar.owner = cb
end
function on_make_tip(tip)
  local btn = tip.owner
  local cb = btn:upsearch_name("show_info")
  if cb ~= nil then
    local svar = cb.svar
    local select_color_item = svar.selected_color
    if select_color_item == nil then
      select_color_item = svar.color_list[1]
    end
    local color_name = select_color_item.colorname
    ui_widget.tip_make_view(tip.view, color_name)
  end
end
function on_stallname_tip_make(tip)
  local panel = tip.owner.parent
  if panel == nil then
    return
  end
  local svar_name = panel.svar.stall_name
  ui_widget.tip_make_view(tip.view, svar_name)
end
function ExamineSelecteditem()
  if gx_selected_item == nil then
    return
  end
  OnSelectStallSur(gx_selected_item)
end
function set_rank_type(btn)
  local i = 1
  j = i
end
function rank_init()
end
function on_stall_state(obj)
  local thectrl = find_the_ctrl(g_surround)
  local size = thectrl.item_count
  if g_all_stall_list:has(obj.sel_handle) then
    local v = g_all_stall_list:get(obj.sel_handle)
    local colorcode = v:get("color").v_string
    local type_name = v:get("type").v_string
    bo2.scn:SetOpenedStall(obj.sel_handle, colorcode, type_name)
  end
  for i = 0, size - 1 do
    local stallitem = thectrl:item_get(i)
    if stallitem.svar.stall_key == obj.sel_handle and stallitem.svar.open_time ~= obj:get_flag_objmem(bo2.eFlagObjMemory_StallOpenTime) then
      stallitem.svar.selected_type_id = 0
      ui_combo.select(stallitem, 0)
      local ctrstall = stallitem:search("stall_name")
      local type_name = type_table[1].typename
      ctrstall.text = stallitem.svar.stall_name
      ctrstall.text = "[" .. type_name .. "]" .. ctrstall.text
      stallitem.svar.selected_type_id = 0
      set_color(stallitem, 0)
      stallitem.svar.open_time = obj:get_flag_objmem(bo2.eFlagObjMemory_StallOpenTime)
      return
    end
  end
end
function on_player_enter(obj, msg)
  if bo2.scn == nil then
    return
  end
  if bo2.scn.excel.id ~= 893 then
    return
  end
  if obj ~= bo2.player then
    obj:insert_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_StallOpenTime, on_stall_state, "ui_stall.surround.on_stall_state")
    on_stall_state(obj)
  end
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enter_scn, on_player_enter, "ui_stall.surround.on_player_enter")
function on_player_out(obj, msg)
  if bo2.scn == nil then
    return
  end
  if bo2.scn.excel.id ~= 893 or obj ~= bo2.player then
    return
  end
  g_all_stall_list:clear()
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_leave_scn, on_player_out, "ui_stall.surround.on_player_out")
