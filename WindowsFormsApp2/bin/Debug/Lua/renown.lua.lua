local tbl_renown_list = {}
local tbl_renown_idx = {}
local tbl_renown_name = {}
local renown_save = 1000000
local renown_data = {
  tip = ui.get_text("personal|renown"),
  value = "0/0"
}
local ui_tab = ui_widget.ui_tab
local is_insert_msg = false
local KNIGHT_PK_LVL = 4
local KNIGHT_PK_RENOWN = 2
local KNIGHT_PK_GOODWILL = 1
local KNIGHT_PK_SUC = 0
local KNIGHT_PK_OTHER_ERR = -1
local cd_is_hide = -1
local cd_sort_type = 1
local cd_color_disable = "808080"
local cd_color_valid = "00FF00"
local cd_color_yellow = "d3a75e"
local cd_color_white = "FFFFFF"
local cd_color_blue = "23AFD7"
local KNIGHT_GIFT_USE_ID = 1236
local gift_knight_excel_id = 0
local safe_get_player = function()
  local player = bo2.player
  if not sys.check(player) then
    player = fake_player
  end
  return player
end
function on_init(ctrl)
end
function update_all()
  init_player_info()
  update_knight_renown()
end
function on_renown_init(ctrl)
end
function on_renown_tip_make(tip)
  lbl_value.text = renown_data.value
  tip.view = renown_data.tip
end
function init_player_info()
  local player = safe_get_player()
  local info_view = w_player_info
  init_basic_info(player, info_view)
  update_player_renown(player)
  if is_insert_msg == false then
    player:remove_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_KnightRenown, "ui_knight:update_player_renown")
    player:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Level, "ui_knight:update_player_renown")
    player:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_KnightRenown, send_renown_request, "ui_knight:update_player_renown")
    player:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Level, send_renown_request, "ui_knight:update_player_renown")
    is_insert_msg = true
  end
end
function send_renown_request()
  local variant = sys.variant()
  variant:set(packet.key.ui_cd_view_type, ui_personal.ui_cd_view.fuben_max_id)
  bo2.send_variant(packet.eCTS_UI_ViewCDGetInf, variant)
  update_all()
end
function init_basic_info(player, info_view)
  local portrait = bo2.gv_portrait:find(player:get_flag_int32(bo2.ePlayerFlagInt32_Portrait))
  local portrait_path = "$icon/portrait/"
  if portrait ~= nil then
    info_view:search("portrait").image = portrait_path .. portrait.icon .. ".png"
  end
  info_view:search("player_name").text = player.name
end
function update_player_renown(player)
  local info_view = w_player_info
  local value = player:get_flag_int32(bo2.ePlayerFlagInt32_KnightRenown)
  local lvl = player:get_flag_int8(bo2.ePlayerFlagInt8_RenownLvl)
  local renown_info = bo2.gv_knight_renown:find(lvl + 1)
  local renown_max = 0
  if renown_info == nil then
    renown_info = bo2.gv_knight_renown:find(lvl)
    if renown_info == nil then
      return
    end
    renown_max = renown_info.renown_max
  else
    renown_max = renown_info.renown_min
  end
  local renown_name = "(" .. value .. "/" .. renown_max .. ")"
  local renown_lvl = lvl
  if renown_lvl < 1 then
    renown_lvl = 1
  end
  local renown_title = bo2.gv_knight_renown:find(renown_lvl)
  if renown_title ~= nil then
    local renown_title_id = renown_title.renown_title_id
    local title = bo2.gv_title_list:find(renown_title_id)
    if title ~= nil then
      renown_name = title._name .. renown_name
    end
  end
  info_view:search("player_renown").text = renown_name
  local renown_rate = value / renown_max
  info_view:search("value").dx = info_view:search("value_bg").dx * renown_rate
end
function on_make_renown_text(player)
end
function on_exp_move()
  on_make_renown_text(safe_get_player())
end
function on_renown_item_select(ctrl)
end
local check_result = function(rst, bit)
  if bit <= 0 then
    return false
  end
  while rst > 0 do
    if math.mod(rst, 2) == 1 and bit == 1 then
      return true
    end
    rst = math.floor(rst / 2)
    bit = math.floor(bit / 2)
  end
  return false
end
function on_can_fight_tip_make(tip)
  local app_item = tip.owner.parent
  local knight_id = app_item.var:get("knight_id").v_int
  local knight_list = bo2.gv_knight_likeness_list:find(knight_id)
  local rst, lowest_lvl, lowest_gw, lowest_renown = knight_can_fight(knight_id)
  local text
  local can_color = "FF00FF00"
  local cannot_color = "FFFF0000"
  local param = sys.variant()
  local cha_data = bo2.gv_cha_list:find(knight_list.id)
  local knight_name = cha_data.name
  param:set("name", knight_name)
  local knight_rank = app_item:search("rank").text
  param:set("rank", knight_rank)
  if rst < 0 then
    fmt = ui.get_text("knight|renown_tip_simple")
    text = sys.mtf_merge(param, fmt)
    ui_widget.tip_make_view(tip.view, text)
    return
  end
  local title_id = cha_data.title_id
  local title = bo2.gv_title_list:find(title_id)
  local title_name = title._name
  param:set("title", title_name)
  local knight_display_renown = knight_list.display_renown_lvl
  local knight_renown_title = bo2.gv_knight_renown:find(knight_display_renown)
  local knight_renown_title_id = knight_renown_title.renown_title_id
  local knight_re_title = bo2.gv_title_list:find(knight_renown_title_id)
  local knight_renown_name = knight_re_title._name
  param:set("knight_renown", knight_renown_name)
  local flag_id = knight_list.flag_id
  local depth = bo2.player:get_flag_int8(flag_id)
  local depth_symbol = math.floor(depth / 128)
  if depth_symbol > 0 then
    depth = depth - 128
    depth = -depth
  end
  param:set("friend_depth", depth)
  param:set("level", lowest_lvl)
  if check_result(rst, KNIGHT_PK_LVL) then
    param:set("level_color", cannot_color)
  else
    param:set("level_color", can_color)
  end
  param:set("goodwill", lowest_gw)
  if check_result(rst, KNIGHT_PK_GOODWILL) then
    param:set("goodwill_color", cannot_color)
  else
    param:set("goodwill_color", can_color)
  end
  local renown_title = bo2.gv_knight_renown:find(lowest_renown)
  local renown_title_id = renown_title.renown_title_id
  local re_title = bo2.gv_title_list:find(renown_title_id)
  local renown_name = re_title._name
  param:set("need_renown", renown_name)
  if check_result(rst, KNIGHT_PK_RENOWN) then
    param:set("renown_color", cannot_color)
  else
    param:set("renown_color", can_color)
  end
  local discover_id = knight_list.discover
  local discover_excel = bo2.gv_discover_list:find(discover_id)
  local discover_info = ui.discover_find(discover_id)
  local study = 0
  if discover_info ~= nil then
    study = discover_info.study
  end
  if study < 0 then
    param:set("is_on_color", cd_color_valid)
    param:set("is_on", ui.get_text("personal|opened"))
    param:set("progress_color", cd_color_valid)
    param:set("progress_title", ui.get_text("knight|title_property"))
    local awd_title = bo2.gv_title_list:find(discover_excel.awd_title)
    local title_attribute = ""
    local nSizeTrait = awd_title._attribute.size
    for i = 0, nSizeTrait - 1 do
      local trait_des = ui_tool.ctip_trait_text(awd_title._attribute[i])
      title_attribute = title_attribute .. "\n" .. trait_des
    end
    param:set("progress_detail", title_attribute)
  else
    param:set("is_on_color", cd_color_disable)
    param:set("is_on", ui.get_text("personal|unopened"))
    param:set("progress_color", cd_color_white)
    param:set("progress_title", ui.get_text("knight|current_progress"))
    param:set("progress_detail", study .. "/" .. discover_excel.gold_study)
  end
  fmt = ui.get_text("knight|renown_tip")
  text = sys.mtf_merge(param, fmt)
  ui_widget.tip_make_view(tip.view, text)
end
function knight_can_fight(knight_id)
  local rst = KNIGHT_PK_SUC
  local knight_list = bo2.gv_knight_likeness_list:find(knight_id)
  if knight_list == nil then
    return KNIGHT_PK_OTHER_ERR, -1
  end
  local lowest_renown = -1
  local lowest_gw = 0
  local lowest_lvl = -1
  local flag_id = knight_list.flag_id
  local depth = bo2.player:get_flag_int8(flag_id)
  local depth_symbol = math.floor(depth / 128)
  if depth_symbol > 0 then
    depth = depth - 128
    depth = -depth
  end
  if depth < 0 then
    rst = rst + KNIGHT_PK_GOODWILL
  end
  local player_lvl = bo2.player:get_atb(bo2.eAtb_Level)
  local KNIGHT_LEVEL_PRIMARY = 10
  local KNIGHT_LEVEL_SECTION = 10
  local lvl_section_idx = math.floor((player_lvl - KNIGHT_LEVEL_PRIMARY) / KNIGHT_LEVEL_SECTION)
  for i = 0, knight_list.fight_lvl_section.size do
    if knight_list.fight_lvl_section[i] ~= nil and knight_list.fight_lvl_section[i].size >= 3 then
      lowest_lvl = (i + 1) * 10
      lvl_section_idx = i
      break
    end
  end
  if lvl_section_idx < 0 then
    return KNIGHT_PK_OTHER_ERR, lowest_lvl
  end
  if lvl_section_idx > knight_list.fight_lvl_section.size then
    lvl_section_idx = knight_list.fight_lvl_section.size - 1
  end
  local fight_lvl_section = knight_list.fight_lvl_section[lvl_section_idx]
  if fight_lvl_section.size < 3 then
    return KNIGHT_PK_OTHER_ERR, lowest_lvl
  end
  local fight_mold_id = fight_lvl_section[1]
  local moldboard_tbl = bo2.gv_fight_moldboard_list:find(fight_mold_id)
  if moldboard_tbl == nil then
    return KNIGHT_PK_OTHER_ERR, -1
  end
  if player_lvl < moldboard_tbl.fight_lvl_min then
    rst = rst + KNIGHT_PK_LVL
  end
  lowest_lvl = moldboard_tbl.fight_lvl_min
  local renown_lvl_player = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_RenownLvl)
  if renown_lvl_player == 0 then
    renown_lvl_player = 1
  end
  if renown_lvl_player < moldboard_tbl.fight_renown_min then
    rst = rst + KNIGHT_PK_RENOWN
  end
  lowest_renown = moldboard_tbl.fight_renown_min
  if lowest_renown <= 0 then
    lowest_renown = 1
  end
  return rst, lowest_lvl, lowest_gw, lowest_renown
end
function reload_data()
  tbl_renown_list = {}
  tbl_renown_idx = {}
  tbl_renown_name = {}
  local knight_size = bo2.gv_knight_likeness_list.size
  for i = 0, knight_size do
    local knight_renown = bo2.gv_knight_likeness_list:get(i)
    if knight_renown == nil then
      break
    end
    if 0 < knight_renown.display_renown_lvl then
      local cha_data = bo2.gv_cha_list:find(knight_renown.id)
      if cha_data == nil then
        return
      end
      local knight_name = cha_data.name
      local knight_renown_item = {
        knight_id = knight_renown.id,
        title_id = cha_data.title_id,
        pic_id = cha_data.pic,
        name = knight_name,
        renown_val = knight_renown.display_renown_lvl,
        renown_rank = knight_renown.renown_rank,
        can_fight = ui_personal.ui_cd_view.knight_can_fight(knight_renown.id)
      }
      tbl_renown_list[knight_name] = knight_renown_item
      table.insert(tbl_renown_idx, knight_name)
    end
  end
  local function sortFunc(a, b)
    return tbl_renown_list[a].renown_rank < tbl_renown_list[b].renown_rank
  end
  table.sort(tbl_renown_idx, sortFunc)
  local renown_size = table.getn(tbl_renown_idx)
  for i = 1, renown_size do
    local renown_lvl = tbl_renown_list[tbl_renown_idx[i]].renown_val
    if tbl_renown_name[renown_lvl] == nil then
      tbl_renown_name[renown_lvl] = {}
    end
    table.insert(tbl_renown_name[renown_lvl], tbl_renown_idx[i])
  end
end
function update_renown_list_ui()
  local item_uri = "$frame/personal/renown.xml"
  local item_style = "renown_item"
  local knight_style = "knight_item"
  local potrait_uri = "$icon/portrait/"
  local renown_slider_y = w_renown_info_list.slider_y.scroll
  local root = w_renown_info_list
  root:item_clear()
  local renown_size = table.getn(tbl_renown_name)
  for i = 1, renown_size do
    local index = renown_size - i + 1
    if cd_sort_type > 0 then
      index = i
    end
    local app_item = root:item_append()
    app_item:load_style(item_uri, item_style)
    app_item.visible = true
    local renown_title = bo2.gv_knight_renown:find(index)
    if renown_title ~= nil then
      local renown_title_id = renown_title.renown_title_id
      local title = bo2.gv_title_list:find(renown_title_id)
      if title ~= nil then
        app_item:search("renown_title").text = title._name
      end
      local knight_tbl = tbl_renown_name[index]
      local first_renown = tbl_renown_list[knight_tbl[1]]
      local rst, lowest_lvl, lowest_gw, lowest_renown = knight_can_fight(first_renown.knight_id)
      app_item.dy = 120
      if check_result(rst, KNIGHT_PK_LVL) == false and check_result(rst, KNIGHT_PK_RENOWN) == false then
        app_item:search("renown_title").color = ui.make_color(cd_color_yellow)
        app_item:search("sep1_enable").visible = true
        app_item:search("sep1_disable").visible = false
        app_item:search("sep2_enable").visible = true
        app_item:search("sep2_disable").visible = false
      else
        app_item:search("renown_title").color = ui.make_color(cd_color_disable)
        app_item:search("sep1_enable").visible = false
        app_item:search("sep1_disable").visible = true
        app_item:search("sep2_enable").visible = false
        app_item:search("sep2_disable").visible = true
        if cd_is_hide > 0 then
          app_item.dy = 60
        end
      end
      local param = sys.variant()
      param:set("level", lowest_lvl)
      param:set("goodwill", lowest_gw)
      local need_title = bo2.gv_knight_renown:find(lowest_renown)
      local need_title_id = need_title.renown_title_id
      local need_title = bo2.gv_title_list:find(need_title_id)
      param:set("need_renown", need_title._name)
      local fmt
      if lowest_lvl > 0 then
        fmt = ui.get_text("knight|require_level")
      end
      fmt = fmt .. ui.get_text("knight|require_goodwill") .. ui.get_text("knight|require_renown")
      app_item:search("renown_require").text = sys.mtf_merge(param, fmt)
      for j = 1, 3 do
        local item_name = sys.format(L("item%d"), j)
        local item = app_item:search(item_name)
        item.visible = false
      end
      local knight_size = table.getn(tbl_renown_name[index])
      for j = 1, knight_size do
        local index_j = j
        if cd_sort_type > 0 then
          index_j = knight_size - j + 1
        end
        local item_name = sys.format(L("item%d"), j)
        local item = app_item:search(item_name)
        item.visible = true
        local knight_renown = tbl_renown_list[knight_tbl[index_j]]
        item:search("rank").text = knight_renown.renown_rank
        local pic_id = knight_renown.pic_id
        local cha_pic = bo2.gv_cha_pic:find(pic_id)
        if cha_pic ~= nil then
          local icon_name = cha_pic.head_icon
          icon_name = potrait_uri .. icon_name
          item:search("portrait").image = icon_name
        end
        local npc_name = knight_renown.name
        item:search("knight_name").text = npc_name
        local nick_name = bo2.gv_title_list:find(knight_renown.title_id)
        item:search("nick_name").text = "<" .. nick_name._name .. ">"
        local knight_list = bo2.gv_knight_likeness_list:find(knight_renown.knight_id)
        local flag_id = knight_list.flag_id
        local depth = bo2.player:get_flag_int8(flag_id)
        local depth_symbol = math.floor(depth / 128)
        if depth_symbol > 0 then
          depth = depth - 128
          depth = -depth
        end
        item:search("good_will").text = depth
        local lbl_knight_cd = item:search("knight_cd")
        local cd_data = ui_personal.ui_cd_view.get_knight_cd_info(knight_renown.knight_id)
        local cd_can_fight = false
        if cd_data ~= nil then
          cd_can_fight = cd_data.left
        end
        if knight_renown.can_fight == bo2.FIGHT_NPC_SUC and cd_data ~= nil then
          lbl_knight_cd.text = cd_data.count .. "/" .. cd_data.max
        else
          lbl_knight_cd.text = "-/-"
          if cd_is_hide > 0 then
            item.visible = false
          end
        end
        item.var:set("knight_id", knight_renown.knight_id)
        local rst = knight_can_fight(knight_renown.knight_id)
        if rst == KNIGHT_PK_SUC and cd_can_fight then
          item:search("knight_name").color = ui.make_color(cd_color_white)
          item:search("nick_name").color = ui.make_color(cd_color_blue)
          item:search("rank").color = ui.make_color(cd_color_blue)
          item:search("rank_title").color = ui.make_color(cd_color_blue)
          item:search("good_will").color = ui.make_color(cd_color_blue)
          item:search("good_will_title").color = ui.make_color(cd_color_blue)
          item:search("portrait").color = ui.make_color(cd_color_white)
          item:search("knight_cd").color = ui.make_color(cd_color_valid)
        else
          item:search("knight_name").color = ui.make_color(cd_color_disable)
          item:search("nick_name").color = ui.make_color(cd_color_disable)
          item:search("rank").color = ui.make_color(cd_color_disable)
          item:search("rank_title").color = ui.make_color(cd_color_disable)
          item:search("good_will").color = ui.make_color(cd_color_disable)
          item:search("good_will_title").color = ui.make_color(cd_color_disable)
          item:search("portrait").color = ui.make_color(cd_color_disable)
          item:search("knight_cd").color = ui.make_color(cd_color_disable)
        end
        if check_result(rst, KNIGHT_PK_LVL) or check_result(rst, KNIGHT_PK_RENOWN) or cd_can_fight == false then
          item:search("gift_button").enable = false
        else
          item:search("gift_button").enable = true
        end
      end
    end
  end
  local cd_total_data = ui_personal.ui_cd_view.get_knight_cd_total()
  cd_knight_count = cd_total_data.cd_count
  cd_knight_max = cd_total_data.cd_max
  cd_knight_help_count = cd_total_data.help_count
  cd_knight_help_max = cd_total_data.help_max
  local cd_total_var = w_cd_total:search("cd_total")
  local cd_total_name = w_cd_total:search("cd_total_name")
  if 0 > cd_knight_count then
    local extra_count = -cd_knight_count
    cd_total_var.text = "0/" .. cd_knight_max .. "(" .. extra_count .. ")"
  else
    cd_total_var.text = cd_knight_count .. "/" .. cd_knight_max
  end
  if cd_knight_count >= cd_knight_max then
    cd_total_var.color = ui.make_color(cd_color_disable)
    cd_total_name.color = ui.make_color(cd_color_disable)
  else
    cd_total_var.color = ui.make_color(cd_color_yellow)
    cd_total_name.color = ui.make_color(cd_color_yellow)
  end
  local cd_help_var = w_cd_help:search("cd_help")
  local cd_help_name = w_cd_help:search("cd_help_name")
  cd_help_var.text = cd_knight_help_count .. "/" .. cd_knight_help_max
  if cd_knight_help_count >= cd_knight_help_max then
    cd_help_var.color = ui.make_color(cd_color_disable)
    cd_help_name.color = ui.make_color(cd_color_disable)
  else
    cd_help_var.color = ui.make_color(cd_color_yellow)
    cd_help_name.color = ui.make_color(cd_color_yellow)
  end
  local _vp = 0
  if sys.check(bo2.player) then
    _vp = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_RMBPrivilege)
  end
  local str = sys.mtf_merge({vp = _vp}, "<vip:{vp},3,2,7>")
  w_vip_button.mtf = ui_widget.merge_mtf({vp = _vp}, str)
  w_renown_info_list.slider_y.scroll = renown_slider_y
end
function update_knight_renown()
  reload_data()
  update_renown_list_ui()
end
function on_btn_show_renown_click()
  w_renown_wnd.visible = not w_renown_wnd.visible
end
function on_cd_sort()
  cd_sort_type = cd_sort_type * -1
  update_all()
end
function on_cd_hide()
  cd_is_hide = cd_is_hide * -1
  update_all()
end
function on_cd_hide_tip_make(tip)
  local text
  if cd_is_hide < 0 then
    text = ui.get_text("personal|hide_no_cd")
  else
    text = ui.get_text("personal|show_all")
  end
  ui_widget.tip_make_view(tip.view, text)
end
function on_cd_sort_tip_make(tip)
  local text
  if cd_sort_type > 0 then
    text = ui.get_text("personal|descending_sort")
  else
    text = ui.get_text("personal|ascending_sort")
  end
  ui_widget.tip_make_view(tip.view, text)
end
function on_knight_help_tip_show(tip)
  local owner = tip.owner
  local cd_help = w_cd_help:search("cd_help")
  local text = ui.get_text("personal|knight_help_cd_tip") .. cd_help.text
  local stk = sys.mtf_stack()
  ui_tool.ctip_push_unwrap(stk, text, SHARED("FFFFFF"))
  ui_tool.ctip_show(owner, stk)
end
function on_knight_cd_tip_make(tip)
  local cd_total = w_cd_total:search("cd_total")
  local param = sys.variant()
  local cd_total_data = ui_personal.ui_cd_view.get_knight_cd_total()
  cd_knight_count = cd_total_data.cd_count
  cd_knight_max = cd_total_data.cd_max
  if cd_knight_count >= cd_knight_max then
    param:set("color", cd_color_disable)
  else
    param:set("color", cd_color_yellow)
  end
  param:set("knight_cd", cd_total.text)
  local fmt = ui.get_text("personal|knight_cd_tip")
  local text = sys.mtf_merge(param, fmt)
  ui_widget.tip_make_view(tip.view, text)
end
function on_player_info_tip_make(tip)
  local param = sys.variant()
  local player = safe_get_player()
  local renown_lvl = player:get_flag_int8(bo2.ePlayerFlagInt8_RenownLvl)
  if renown_lvl < 1 then
    renown_lvl = 1
  end
  local renown_title = bo2.gv_knight_renown:find(renown_lvl)
  if renown_title ~= nil then
    local renown_title_id = renown_title.renown_title_id
    local title = bo2.gv_title_list:find(renown_title_id)
    if title ~= nil then
      param:set("renown_level", title._name)
    end
  end
  local next_renown_lvl = renown_lvl + 1
  local next_renown_title = bo2.gv_knight_renown:find(next_renown_lvl)
  if next_renown_title ~= nil then
    local renown_title_id = next_renown_title.renown_title_id
    local title = bo2.gv_title_list:find(renown_title_id)
    if title ~= nil then
      param:set("next_renown_level", title._name)
    end
  end
  local knight_names = ""
  local renown_size = table.getn(tbl_renown_idx)
  for i = 1, renown_size do
    local knight_renown = tbl_renown_list[tbl_renown_idx[i]]
    local a, b, c, lowest_renown = knight_can_fight(knight_renown.knight_id)
    if lowest_renown == next_renown_lvl then
      if knight_names == "" then
        knight_names = "<c+:#green>" .. knight_renown.name .. "<c->"
      else
        knight_names = knight_names .. ", <c+:#green>" .. knight_renown.name .. "<c->"
      end
    end
  end
  param:set("next_knight", knight_names)
  local fmt = ui.get_text("personal|player_renown_tip")
  local text = sys.mtf_merge(param, fmt)
  ui_widget.tip_make_view(tip.view, text)
end
function on_send_knight_gift(btn)
  local card_table = w_knight_gift_main.svar.card_table
  local size = table.getn(card_table)
  for i = 1, size do
    card_table[i].excel_id = 0
  end
  local cur_index = 1
  for i, v in pairs(ui_item.g_boxs) do
    for j, k in pairs(v.cells) do
      if k.card.info then
        local info = k.card.info
        if info.excel.use_id == KNIGHT_GIFT_USE_ID and info.excel.datas[0] == 0 then
          card_table[cur_index].excel_id = k.card.excel_id
          cur_index = cur_index + 1
        end
      end
    end
  end
  if w_knight_gift_main.visible == false then
    w_knight_gift_main.visible = true
    w_knight_gift_main.focus = true
    local pos = ui.get_cursor_pos()
    w_knight_gift_main.margin = ui.rect(pos.x + 15, pos.y, 0, 0)
  else
    w_knight_gift_main.visible = false
  end
  local app_item = btn.parent
  local knight_id = app_item.var:get("knight_id").v_int
  local knight_list = bo2.gv_knight_likeness_list:find(knight_id)
  gift_knight_excel_id = knight_list.id
end
function on_knigt_gift_init()
  local card_table = {}
  local ctop = w_knight_gift_main:search("ctop1")
  for r = 0, 1 do
    for i = 0, 3 do
      local childctrl = ui.create_control(ctop, "panel")
      childctrl:load_style("$frame/personal/renown.xml", "item_cell")
      childctrl.offset = ui.point(i * 36, r * 36)
      local card = childctrl:search("card")
      table.insert(card_table, card)
    end
  end
  w_knight_gift_main.svar = {}
  w_knight_gift_main.svar.card_table = card_table
end
function on_gift_card_tip_show(tip)
  local card = tip.owner
  local excel = card.excel
  if not excel then
    return
  end
  local stk = sys.mtf_stack()
  if excel ~= nil then
    ui_tool.ctip_make_item(stk, excel)
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("knight|gift_tip"), ui_tool.cs_tip_color_operation)
    ui_tool.ctip_show(card, stk, stk_use)
  end
end
function on_gift_item_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_rbutton_click then
    local excel_id = card.excel_id
    if excel_id == 0 then
      return
    end
    if 0 < ui.item_get_count(excel_id, true) and gift_knight_excel_id ~= 0 then
      local v = sys.variant()
      v:set(packet.key.item_excelid, excel_id)
      v:set(packet.key.knight_pk_npc_cha_id, gift_knight_excel_id)
      bo2.send_variant(packet.eCTS_Knight_SendGift, v)
    else
      local data = sys.variant()
      data[packet.key.ui_text_id] = 73133
      local v = sys.variant()
      v:set("itemid", excel_id)
      data[packet.key.ui_text_arg] = v
      ui_chat.show_ui_text(0, data)
    end
    w_knight_gift_main.visible = false
  end
end
function on_show_renown(btn)
  send_renown_request()
  w_renown_wnd.visible = not w_renown_wnd.visible
end
