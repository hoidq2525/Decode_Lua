local ui_tab = ui_widget.ui_tab
local fuben_max_id = 10
local update_time_delay = 900
local cd_data_list_tbl = {
  [1] = {
    name = "fuben2",
    cd_data_table = {},
    update_type = 1
  },
  [2] = {
    name = "fuben5",
    cd_data_table = {},
    update_type = 2
  },
  [3] = {
    name = "match",
    cd_data_table = {},
    update_type = 3
  },
  [fuben_max_id] = {
    name = "knight",
    cd_data_table = {},
    update_type = fuben_max_id
  },
  [fuben_max_id + 1] = {
    name = "special",
    cd_data_table = {},
    update_type = fuben_max_id + 1
  }
}
local cd_item_tbl = {}
local cd_count_max = 3
local cd_sort_type = -1
local cd_is_hide = 1
local hide_ids_tbl = {}
local sort_btn_name = "btn_cd_sort"
local hide_btn_name = "btn_cd_hide"
local ui_tips = {}
local fuben_tips_default = {
  [6] = 1804,
  [30] = 1801,
  [31] = 1802,
  [32] = 1803,
  [48] = 1888,
  [202] = 1805,
  [886] = 82913,
  [20] = 84491,
  [908] = 84482,
  [59] = 84486,
  [208] = 84481,
  [47] = 84488,
  [209] = 84480,
  [139] = 84487,
  [204] = 84484,
  [14] = 80301,
  [26] = 84490
}
local cd_color_disable = "808080"
local cd_color_valid = "00FF00"
local cd_color_yellow = "FFFFFF00"
local cd_knight_max = 0
local cd_knight_count = 0
local cd_knight_help_max = 0
local cd_knight_help_count = 0
function on_init(ctrl)
  cd_data_list_tbl = {
    [1] = {
      name = "fuben2",
      cd_data_table = {},
      update_type = 1
    },
    [2] = {
      name = "fuben5",
      cd_data_table = {},
      update_type = 2
    },
    [3] = {
      name = "match",
      cd_data_table = {},
      update_type = 3
    },
    [fuben_max_id] = {
      name = "knight",
      cd_data_table = {},
      update_type = fuben_max_id
    },
    [fuben_max_id + 1] = {
      name = "special",
      cd_data_table = {},
      update_type = fuben_max_id + 1
    }
  }
  hide_ids_tbl = {-1, 0}
  ui_tips = {
    [sort_btn_name] = {
      [-1] = ui.get_text("personal|descending_sort"),
      [1] = ui.get_text("personal|ascending_sort"),
      ["cur_type"] = cd_sort_type
    },
    [hide_btn_name] = {
      [-1] = ui.get_text("personal|show_all"),
      [1] = ui.get_text("personal|hide_no_cd"),
      ["cur_type"] = cd_is_hide
    }
  }
  insert_tab("cd_view_all")
end
function insert_tab(name)
  local btn_uri, btn_sty
  local page_uri = "$frame/personal/cd_view.xml"
  local page_sty = name
  local view = w_cd_view_all
  if view == nil then
    return
  end
  init_cd_list_item(view)
end
function init_cd_list_item(view)
  local page_uri = "$frame/personal/cd_view.xml"
  local item_sty = L("list_item")
  local list_name = L("blue_btn_label")
  local root = w_left_list
  local tbl_key_sorted = {}
  for i, v in pairs(cd_data_list_tbl) do
    table.insert(tbl_key_sorted, i)
  end
  table.sort(tbl_key_sorted)
  root:item_clear()
  for k, v in pairs(tbl_key_sorted) do
    local list_item
    local cd_list_tbl = cd_data_list_tbl[v]
    list_item = root:item_append()
    list_item:load_style(page_uri, item_sty)
    local item_pic = list_item:search("pic_item")
    local pic_name = "fig_" .. cd_list_tbl.name
    item_pic:load_style(page_uri, pic_name)
    list_item.name = cd_list_tbl.name
    list_item.var:set("update_type", v)
  end
end
function set_ctrl_visible(ctrl_name)
  local root = w_left_list
  for k, v in pairs(cd_data_list_tbl) do
    local cd_list_tbl = v
    local list_item = root:search(cd_list_tbl.name)
    local fader_sel = list_item:search("fader")
    if ctrl_name ~= nil and ctrl_name == cd_list_tbl.name then
      fader_sel.visible = true
    else
      fader_sel.visible = false
    end
  end
end
function on_item_select(ctrl, v)
  ctrl:search("fader").visible = v
  if v then
    if w_main.visible then
      bo2.PlaySound2D(578)
    end
    local view = w_cd_view_all
    if view == nil then
      return
    end
    local update_type = ctrl.var:get("update_type").v_int
    if update_type == nil or update_type == 0 then
      return
    end
    local list_view = w_right_info_list
    local slider = list_view:search("cmn_vs")
    slider.scroll = 0
    list_view:item_clear()
    local cd_list_data = cd_data_list_tbl[update_type]
    local list_panel = w_right_info_panel
    local cd_title = list_panel:search("cd_title")
    if update_type == fuben_max_id then
      w_cd_total1.visible = true
      w_cd_total2.visible = true
    else
      w_cd_total1.visible = false
      w_cd_total2.visible = false
    end
    if cd_title ~= nil then
      cd_title.text = ui.get_text("personal|cd_" .. cd_list_data.name)
    end
    local cur_time_var = bo2.get_svrcurtime64()
    local cur_time = cur_time_var:get(packet.key.chat_im_time).v_int
    if cd_list_data.update_time == nil or cur_time - cd_list_data.update_time > update_time_delay then
      local variant = sys.variant()
      variant:set(packet.key.ui_cd_view_type, update_type)
      bo2.send_variant(packet.eCTS_UI_ViewCDGetInf, variant)
    else
      show_cd_data(cd_list_data.cd_data_table, cd_list_data.name)
    end
  end
end
function on_cd_view_close(btn)
end
function on_cd_view_visible(w, vis)
end
function on_cd_tip_make(tip)
  local lbl_basic_cd = tip.owner
  if lbl_basic_cd == nil then
    return
  end
  local lb_name = lbl_basic_cd:search("lb_name")
  if lb_name == nil then
    return
  end
  local text
  if lb_name.svar ~= nil then
    text = lb_name.svar
  else
    text = lb_name.text
  end
  ui_widget.tip_make_view(tip.view, text)
end
function on_knight_cd_tip_show(tip)
  local owner = tip.owner
  local cd_total1_var = w_cd_total1:search("cd_total1")
  local text = ui.get_text("personal|knight_cd_tip") .. cd_total1_var.text
  local stk = sys.mtf_stack()
  ui_tool.ctip_push_unwrap(stk, text, SHARED("FFFFFF"))
  ui_tool.ctip_show(owner, stk)
end
function on_knight_help_tip_show(tip)
  local owner = tip.owner
  local cd_total2_var = w_cd_total2:search("cd_total2")
  local text = ui.get_text("personal|knight_help_cd_tip") .. cd_total2_var.text
  local stk = sys.mtf_stack()
  ui_tool.ctip_push_unwrap(stk, text, SHARED("FFFFFF"))
  ui_tool.ctip_show(owner, stk)
end
function on_cd_init(p, def, reg)
end
function on_cd_sort(btn)
  cd_sort_type = cd_sort_type * -1
  cd_item_sort()
  ui_tips[sort_btn_name].cur_type = cd_sort_type
end
function init_sort_tbl(cd_data_table)
  cd_item_tbl = {}
  local txt_color = cd_color_valid
  local total_cd_enable = true
  for id, cd_data in pairs(cd_data_table) do
    if id == 0 then
      if cd_data.count >= cd_data.max then
        total_cd_enable = false
      end
    elseif id > 0 then
      if cd_data.count >= cd_data.max or total_cd_enable == false then
        txt_color = cd_color_disable
      else
        txt_color = cd_color_valid
      end
      local remain = cd_data.max - cd_data.count
      if cd_data.max == 0 then
        remain = -1
      end
      if cd_item_tbl[remain] == nil then
        cd_item_tbl[remain] = {}
      end
      local cd_item_data = {
        name = cd_data.name,
        cd_text = cd_data.text,
        count = cd_data.count,
        max = cd_data.max,
        txt_color = txt_color
      }
      if remain > cd_count_max then
        cd_count_max = remain
      end
      table.insert(cd_item_tbl[remain], cd_item_data)
    end
  end
end
function cd_item_sort()
  local start_id = -1
  local end_id = cd_count_max
  local step = 1
  if cd_sort_type > 0 then
    start_id = cd_count_max
    end_id = -1
    step = -1
  end
  local list_view = w_right_info_panel:search("item_list")
  list_view:item_clear()
  local page_uri = "$frame/personal/cd_view.xml"
  local item_name = L("cd_item")
  for i = start_id, end_id, step do
    if cd_item_tbl[i] ~= nil then
      for key, cd_item_data in pairs(cd_item_tbl[i]) do
        local list_item = list_view:item_append()
        list_item:load_style(page_uri, item_name)
        local lbl_item_name = list_item:search("lb_name")
        local lbl_item_value = list_item:search("lb_value")
        local txt_color = cd_item_data.txt_color
        if lbl_item_name ~= nil and lbl_item_value ~= nil then
          lbl_item_name.color = ui.make_color(txt_color)
          lbl_item_name.text = cd_item_data.name
          lbl_item_name.svar = cd_item_data.cd_text
          lbl_item_value.color = ui.make_color(txt_color)
          if cd_item_data.max == 0 then
            lbl_item_value.text = "-/-"
            if cd_is_hide > 0 then
              list_item.visible = true
            else
              list_item.visible = false
            end
          else
            lbl_item_value.text = cd_item_data.count .. "/" .. cd_item_data.max
          end
        end
        cd_item_data.ctrl = list_item
      end
    end
  end
end
function on_cd_hide(btn)
  if table.getn(hide_ids_tbl) == 0 then
    return
  end
  local is_show = false
  cd_is_hide = cd_is_hide * -1
  if cd_is_hide > 0 then
    is_show = true
  end
  cd_item_sort()
  local function set_display(key, value)
    if cd_item_tbl[value] ~= nil then
      for id, item in pairs(cd_item_tbl[value]) do
        if item.ctrl ~= nil then
          item.ctrl.visible = is_show
        end
      end
    end
  end
  ui_tips[hide_btn_name].cur_type = cd_is_hide
end
function get_knight_cd_info(knight_id)
  local cd_table = cd_data_list_tbl[fuben_max_id].cd_data_table
  if cd_table == nil then
    return nil
  end
  local cd_data = cd_table[knight_id]
  if cd_data == nil then
    return nil
  end
  local cd_count = cd_data.count
  local cd_max = cd_data.max
  local cd_left = true
  if cd_count >= cd_max and cd_max > 0 then
    cd_left = false
  end
  local cd_item_data = {
    count = cd_count,
    max = cd_max,
    left = cd_left
  }
  return cd_item_data
end
function get_knight_cd_total()
  local cd_total_data = {
    cd_max = cd_knight_max,
    cd_count = cd_knight_count,
    help_max = cd_knight_help_max,
    help_count = cd_knight_help_count
  }
  return cd_total_data
end
function knight_can_fight(knight_id)
  local knight_list = bo2.gv_knight_likeness_list:find(knight_id)
  if knight_list == nil then
    return bo2.FIGHT_NPC_OTHER_FAIL
  end
  local player_lvl = bo2.player:get_atb(bo2.eAtb_Level)
  local KNIGHT_LEVEL_PRIMARY = 10
  local KNIGHT_LEVEL_SECTION = 10
  local lvl_section_idx = math.floor((player_lvl - KNIGHT_LEVEL_PRIMARY) / KNIGHT_LEVEL_SECTION)
  if lvl_section_idx < 0 then
    return bo2.FIGHT_NPC_LVL_LOW
  end
  if lvl_section_idx > knight_list.fight_lvl_section.size then
    return bo2.FIGHT_PLAYER_LVL_HIGH
  end
  local fight_lvl_section = knight_list.fight_lvl_section[lvl_section_idx]
  if fight_lvl_section.size < 3 then
    return bo2.FIGHT_NPC_NO_MOLD_DATA
  end
  local fight_mold_id = fight_lvl_section[1]
  local moldboard_tbl = bo2.gv_fight_moldboard_list:find(fight_mold_id)
  if moldboard_tbl == nil then
    return bo2.FIGHT_NPC_NO_MOLD_DATA
  end
  if player_lvl < moldboard_tbl.fight_lvl_min then
    return bo2.FIGHT_NPC_LVL_LOW
  end
  local renown_lvl_player = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_RenownLvl)
  if renown_lvl_player == 0 then
    renown_lvl_player = 1
  end
  if renown_lvl_player < moldboard_tbl.fight_renown_min then
    return bo2.FIGHT_NPC_RENOWN_LOW
  end
  local flag_id = knight_list.flag_id
  local depth = bo2.player:get_flag_int8(flag_id)
  local depth_symbol = math.floor(depth / 128)
  if depth_symbol > 0 then
    depth = depth - 128
    depth = -depth
  end
  if depth < 0 then
    return bo2.FIGHT_NPC_DEPTH_LOW
  end
  return bo2.FIGHT_NPC_SUC
end
function update_all_cd()
end
function on_cd_func_show_text(tip)
  local ctrl = tip.owner
  local stk = sys.mtf_stack()
  local btn_name = tostring(ctrl.name)
  local type = ui_tips[btn_name].cur_type
  stk:push(ui_tips[btn_name][type])
  ui_tool.ctip_show(ctrl, stk)
end
function show_cd_data(cd_data_table, cd_all_ctrl_name)
  if cd_all_ctrl_name == "knight" then
    local cd_total1_var = w_cd_total1:search("cd_total1")
    local cd_total1_name = w_cd_total1:search("cd_total1_name")
    if cd_knight_count < 0 then
      local extra_count = -cd_knight_count
      cd_total1_var.text = "0/" .. cd_knight_max .. "(" .. extra_count .. ")"
    else
      cd_total1_var.text = cd_knight_count .. "/" .. cd_knight_max
    end
    if cd_knight_count >= cd_knight_max then
      cd_total1_var.color = ui.make_color(cd_color_disable)
      cd_total1_name.color = ui.make_color(cd_color_disable)
    else
      cd_total1_var.color = ui.make_color(cd_color_yellow)
      cd_total1_name.color = ui.make_color(cd_color_yellow)
    end
    local cd_total2_var = w_cd_total2:search("cd_total2")
    local cd_total2_name = w_cd_total2:search("cd_total2_name")
    cd_total2_var.text = cd_knight_help_count .. "/" .. cd_knight_help_max
    if cd_knight_help_count >= cd_knight_help_max then
      cd_total2_var.color = ui.make_color(cd_color_disable)
      cd_total2_name.color = ui.make_color(cd_color_disable)
    else
      cd_total2_var.color = ui.make_color(cd_color_yellow)
      cd_total2_name.color = ui.make_color(cd_color_yellow)
    end
  end
  init_sort_tbl(cd_data_table)
  cd_item_sort()
end
function release_data(data, cd_list_table)
  local cd_table = cd_list_table.cd_data_table
  if cd_table == nil then
    return
  end
  if data:has(packet.key.ui_cd_view_arr_data) == false then
    return
  end
  cd_list_table.update_time = data:get(packet.key.ui_cd_view_updatetime).v_int
  local arr_data = data:get(packet.key.ui_cd_view_arr_data)
  local data_size = arr_data.size
  local function set_cd_info_data(knight_cd_data)
    local data_id = knight_cd_data:get(packet.key.ui_cd_view_id).v_int
    local cd_count = knight_cd_data:get(packet.key.ui_cd_view_count).v_int
    local cd_max = knight_cd_data:get(packet.key.ui_cd_view_max).v_int
    local cd_name = knight_cd_data:get(packet.key.ui_cd_view_data_name).v_string
    if cd_table[data_id] == nil then
      cd_table[data_id] = {}
    end
    cd_table[data_id].count = cd_count
    cd_table[data_id].max = cd_max
    cd_table[data_id].name = cd_name
    cd_table[data_id].text = nil
    local text_id = 0
    if knight_cd_data:has(packet.key.ui_cd_view_text_id) then
      text_id = knight_cd_data:get(packet.key.ui_cd_view_text_id).v_int
    else
      text_id = fuben_tips_default[data_id]
    end
    if text_id ~= nil and text_id > 0 then
      local text_data = bo2.gv_text:find(text_id)
      if text_data then
        cd_table[data_id].text = text_data.text
      end
    else
    end
  end
  for i = 1, data_size do
    local cell_data = arr_data:get(i)
    set_cd_info_data(cell_data)
  end
  if data:has(packet.key.ui_cd_view_total_cddata) then
    local cd_total_data = data:get(packet.key.ui_cd_view_total_cddata)
    if cd_total_data ~= nil then
      set_cd_info_data(cd_total_data)
      local data_type = data:get(packet.key.ui_cd_view_type).v_int
      if data_type == fuben_max_id then
        cd_knight_count = cd_total_data:get(packet.key.ui_cd_view_count).v_int
        cd_knight_max = cd_total_data:get(packet.key.ui_cd_view_max).v_int
        cd_knight_help_max = cd_total_data:get(packet.key.ui_cd_view_help_max).v_int
        cd_knight_help_count = cd_total_data:get(packet.key.ui_cd_view_help_count).v_int
      end
    else
      ui.log("cd_view::release_data has cd_total_data, but cd_total_data == nil. data_type is " .. data_type)
      return
    end
  end
end
function handle_svr_cd_data(cmd, data)
  local data_type = data:get(packet.key.ui_cd_view_type).v_int
  release_data(data, cd_data_list_tbl[data_type])
  ui_personal.ui_renown.update_all()
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_personal.ui_cd_view.packet_handle"
reg(packet.eSTC_UI_UpdateCDData, handle_svr_cd_data, sig)
