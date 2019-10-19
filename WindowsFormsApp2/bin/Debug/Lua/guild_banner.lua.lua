local MaxBannerNum = 12
local banner_lists = {}
local w_select_pic = 1
local w_select_type = -1
local w_change_type_flag = -1
local w_max_wearout = bo2.gv_define_org:find(136).value.v_int
local w_each_money = bo2.gv_define_org:find(137).value.v_int
local w_hit_use_contri = bo2.gv_define_org:find(138).value.v_int
local w_sec_token = 0
function guild_banner_update()
end
function get_banner_name(banner_id)
  local name = L("")
  if banner_id <= 0 or banner_id > MaxBannerNum then
    return name
  end
  local line = bo2.gv_guild_banner:find(banner_id)
  if line == nil then
    return name
  end
  local name = line.banner_name
  return name
end
function update_banner_level(banner_list)
  local arg = sys.variant()
  local level = 1
  arg:clear()
  if banner_list ~= nil and banner_list.banner_level ~= 0 then
    level = banner_list.banner_level
  end
  arg:set("level", level)
  w_guild_banner_level.text = sys.mtf_merge(arg, ui.get_text("guild|guild_item_level"))
  w_guild_banner_level.color = ui.make_color("59a1fe")
end
function get_build_banner_atb_line(banner_list)
  local size = bo2.gv_guild_banner_atb.size
  local line = {}
  local banner_level = banner_list.banner_level
  local banner_type = banner_list.banner_type
  if banner_level == 0 or banner_level == nil then
    banner_level = 1
  end
  if banner_type == 0 or banner_type == nil then
    banner_type = 1
  end
  for i = 0, size - 1 do
    line = bo2.gv_guild_banner_atb:get(i)
    if line ~= nil and line.banner_id == banner_list.banner_id and line.banner_level == banner_level and line.update_type == banner_type then
      return line
    end
  end
  return line
end
function btn_level_visible(banner_list)
  w_levelup.enable = false
  local self = ui.guild_get_self()
  if self == nil then
    return
  end
  local guild_auth = bo2.gv_guild_auth:find(self.guild_pos)
  if get_self_banner(banner_lists) ~= 0 then
    if banner_list.org_id == banner_lists[get_self_banner(banner_lists)].org_id and guild_auth ~= nil and guild_auth.update_banner == 1 then
      w_levelup.enable = true
    end
  elseif banner_list.org_id.v_int == tonumber(0) and guild_auth ~= nil and guild_auth.update_banner == 1 then
    w_levelup.enable = true
  end
end
function clear_select_banner_pic()
  for i = 1, MaxBannerNum do
    local guild_picture = w_banner_left_info:search("banner_0" .. i)
    if i > 9 then
      guild_picture = w_banner_left_info:search("banner_" .. i)
    end
    local select_pic = guild_picture:search("select_banner_pic")
    select_pic.visible = false
  end
end
function update_select_banner_pic(banner_id)
  clear_select_banner_pic()
  if banner_id == 0 then
    banner_id = 1
  end
  local guild_picture = w_banner_left_info:search("banner_0" .. banner_id)
  if banner_id > 9 then
    guild_picture = w_banner_left_info:search("banner_" .. banner_id)
  end
  local select_pic = guild_picture:search("select_banner_pic")
  select_pic.visible = true
end
function update_self_banner_pic()
  local self_banner_id = get_self_banner(banner_lists)
  if self_banner_id == nil or self_banner_id == 0 then
    return
  end
  local guild_picture = w_banner_left_info:search("banner_0" .. self_banner_id)
  if self_banner_id > 9 then
    guild_picture = w_banner_left_info:search("banner_" .. self_banner_id)
  end
  local self_pic = guild_picture:search("self_banner_pic")
  self_pic.visible = true
end
function get_build_banner_atb_line_next(banner_list)
  local size = bo2.gv_guild_banner_atb.size
  local line = {}
  local banner_level = banner_list.banner_level
  local banner_type = banner_list.banner_type
  if banner_level == 0 or banner_level == nil then
    banner_level = 1
  end
  if banner_type == 0 or banner_type == nil then
    banner_type = 1
  end
  for i = 0, size - 1 do
    line = bo2.gv_guild_banner_atb:get(i)
    if line ~= nil and line.banner_id == banner_list.banner_id and line.banner_level == banner_level + 1 and line.update_type == banner_type then
      return line
    end
  end
  return line
end
function clear_banner_right_info()
  w_guild_banner_name.text = ""
  w_guild_banner_level.text = ""
  w_guild_banner_tip_atb.text = ""
  w_guild_banner_hour_need_money.money = ""
  w_guild_banner_active_contr.text = ""
  w_guild_banner_update_add_atb.text = ""
  w_guild_banner_update_develop.text = ""
  w_guild_banner_update_money.money = ""
  w_guild_banner_update_hall_level.text = ""
  w_guild_banner_update_item1.mtf = ""
  w_guild_banner_update_item2.mtf = ""
  w_guild_banner_update_item3.mtf = ""
  w_guild_banner_update_item4.mtf = ""
  w_guild_banner_update_item5.mtf = ""
  w_guild_banner_update_item6.mtf = ""
end
function update_banner_right_info(banner_list)
  w_levelup.enable = false
  clear_banner_right_info()
  w_hit.enable = false
  local guild_only_id = ui.guild_id()
  if guild_only_id == nil then
    return
  end
  local org_id = banner_list.org_id
  if tostring(org_id) == tostring("0") or tostring(org_id) == tostring(guild_only_id) then
    w_hit.enable = false
  else
    w_hit.enable = true
  end
  if banner_list == nil then
    return
  end
  w_guild_banner_name.text = get_banner_name(banner_list.banner_id)
  w_guild_banner_name.color = ui.make_color("8250af")
  update_banner_level(banner_list)
  local banner_atb_line = get_build_banner_atb_line(banner_list)
  if banner_atb_line == nil then
    return
  end
  w_guild_banner_tip_atb.text = banner_atb_line.atb_name
  w_guild_banner_hour_need_money.money = banner_atb_line.hour_money
  w_guild_banner_active_contr.text = banner_atb_line.active_contr
  w_guild_banner_tip_atb.color = ui.make_color("CAFF70")
  local banner_update_line = bo2.gv_guild_banner_update:find(banner_list.banner_level + 1)
  if banner_update_line == nil then
    w_guild_banner_update_add_atb.text = sys.mtf_merge(arg, ui.get_text("guild|banenr_hold_best_level"))
    w_guild_banner_update_add_atb.color = ui.make_color("FF0000")
    w_guild_banner_update_develop.text = sys.mtf_merge(arg, ui.get_text("guild|banenr_hold_best_level"))
    w_guild_banner_update_develop.color = ui.make_color("FF0000")
    return
  end
  local arg = sys.variant()
  local banner_atb_line_next = get_build_banner_atb_line_next(banner_list)
  if banner_atb_line_next == nil then
    return
  end
  w_guild_banner_update_add_atb.text = banner_atb_line_next.atb_name
  w_guild_banner_update_add_atb.color = ui.make_color("CAFF70")
  w_guild_banner_update_develop.text = banner_update_line.develop
  w_guild_banner_update_develop.color = ui.make_color("F9D23A")
  w_guild_banner_update_money.money = banner_update_line.money
  arg:set("level", banner_update_line.hall_level)
  w_guild_banner_update_hall_level.text = sys.mtf_merge(arg, ui.get_text("guild|guild_item_level"))
  w_guild_banner_update_hall_level.color = ui.make_color("59a1fe")
  local item_ids = banner_update_line.item_id
  local item_counts = banner_update_line.item_count
  if item_ids[0] ~= 0 and item_counts[0] ~= 0 then
    arg:set("item_id", sys.format("%d", item_ids[0]))
    arg:set("count", sys.format("%d", item_counts[0]))
    w_guild_banner_update_item1.mtf = sys.mtf_merge(arg, ui.get_text("guild|item_id_count"))
  end
  if item_ids[1] ~= 0 and item_counts[1] ~= 0 then
    arg:set("item_id", sys.format("%d", item_ids[1]))
    arg:set("count", sys.format("%d", item_counts[1]))
    w_guild_banner_update_item2.mtf = sys.mtf_merge(arg, ui.get_text("guild|item_id_count"))
  end
  if item_ids[2] ~= 0 and item_counts[2] ~= 0 then
    arg:set("item_id", sys.format("%d", item_ids[2]))
    arg:set("count", sys.format("%d", item_counts[2]))
    w_guild_banner_update_item3.mtf = sys.mtf_merge(arg, ui.get_text("guild|item_id_count"))
  end
  if item_ids[3] ~= 0 and item_counts[3] ~= 0 then
    arg:set("item_id", sys.format("%d", item_ids[3]))
    arg:set("count", sys.format("%d", item_counts[4]))
    w_guild_banner_update_item4.mtf = sys.mtf_merge(arg, ui.get_text("guild|item_id_count"))
  end
  if item_ids[4] ~= 0 and item_counts[4] ~= 0 then
    arg:set("item_id", sys.format("%d", item_ids[4]))
    arg:set("count", sys.format("%d", item_counts[4]))
    w_guild_banner_update_item5.mtf = sys.mtf_merge(arg, ui.get_text("guild|item_id_count"))
  end
  if item_ids[5] ~= 0 and item_counts[5] ~= 0 then
    arg:set("item_id", sys.format("%d", item_ids[5]))
    arg:set("count", sys.format("%d", item_counts[5]))
    w_guild_banner_update_item6.mtf = sys.mtf_merge(arg, ui.get_text("guild|item_id_count"))
  end
  w_levelup.text = ui.get_text("guild|banner_btn_hold")
  if banner_list.org_id.v_int ~= tonumber(0) then
    w_levelup.text = ui.get_text("guild|levelup")
  end
  btn_level_visible(banner_list)
end
function on_visible(w, vis)
  if vis == true then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_Guild_Banner_Data_Req, v)
    local cur_money = ui.guild_get_money()
    local ctrl = g_follow:search("gx_guild_money")
    local label1 = ctrl:search("l_lable_left1")
    local label2 = ctrl:search("l_lable_left2")
    label1.visible = true
    label2.visible = false
    g_guild_money.color = ui.make_color("ffffff")
    if cur_money < 0 then
      cur_money = -cur_money
      g_guild_money.color = ui.make_color("FF0000")
      label1.visible = false
      label2.visible = true
    end
    g_guild_money.money = cur_money
    g_guild_develop.text = ui.guild_get_develop()
  end
  w_banner_left_info.visible = true
  w_banner_left_info_self_banner.visible = false
  w_banner_left_info_select_type.visible = false
  local on_banner_num = bo2.gv_define_org:find(130).value.v_int
  for i = 1, MaxBannerNum do
    local guild_picture = w_banner_left_info:search("banner_0" .. i)
    if i > 9 then
      guild_picture = w_banner_left_info:search("banner_" .. i)
    end
    if i > on_banner_num then
      guild_picture.visible = false
    else
      guild_picture.visible = true
    end
  end
end
function on_widget_mouse(box, data, msg, pt)
end
function guild_banner_update()
end
function may_update_banner(banner_list)
  local guild_level = ui.guild_get_level()
  local guild_develop = ui.guild_get_develop()
  local guild_money = ui.guild_get_money()
  local banner_level = 1
  local hold = false
  if banner_list.org_id.v_int ~= tonumber(0) then
    banner_level = banner_level + 1
    hold = true
  end
  local banner_update = bo2.gv_guild_banner_update:find(banner_level)
  if banner_update == nil then
    ui_chat.show_ui_text_id(70822)
    return false
  end
  local need_money = banner_update.money
  local need_develop = banner_update.develop
  if hold == false then
    local next_atb = get_build_banner_atb_line_next(banner_list)
    if next_atb == nil then
      return false
    end
    need_develop = need_develop + next_atb.week_develop
    need_money = need_money + next_atb.week_money
  end
  if guild_level < banner_update.hall_level then
    ui_chat.show_ui_text_id(70824)
    return false
  end
  if guild_money < need_money then
    ui_chat.show_ui_text_id(70157)
    return false
  end
  if guild_develop < need_develop then
    ui_chat.show_ui_text_id(70156)
    return false
  end
  return true
end
function may_active_banner(banner_list)
  if banner_list.org_id.v_int == tonumber(0) or banner_list.banner_id == tonumber(0) or banner_list.banner_type == tonumber(0) or banner_list.banner_level == tonumber(0) then
    return false
  end
  local next_atb = get_build_banner_atb_line(banner_list)
  if next_atb == nil then
    return false
  end
  local my_info = ui.guild_get_self()
  if my_info == nil then
    return
  end
  local guild_contri = my_info.current_con
  if guild_contri < next_atb.active_contr then
    ui_chat.show_ui_text_id(70257)
    return false
  end
  return true
end
function btn_levelup_click(btn)
  local banner_on = bo2.gv_define_org:find(120).value.v_int
  if banner_on ~= 1 then
    ui_chat.show_ui_text_id(70822)
    return
  end
  local self = ui.guild_get_self()
  if self == nil then
    return
  end
  local guild_auth = bo2.gv_guild_auth:find(self.guild_pos)
  if guild_auth == nil or guild_auth.update_banner == 0 then
    ui_chat.show_ui_text_id(70013)
    return
  end
  if not may_update_banner(banner_lists[w_select_pic]) then
    return
  end
  local level = banner_lists[w_select_pic].banner_level
  if level == tonumber(0) then
    w_banner_left_info.visible = false
    w_banner_left_info_select_type.visible = true
    w_levelup.enable = false
    return
  end
  local v = sys.variant()
  v:set(packet.key.cmn_type, banner_lists[w_select_pic].banner_type)
  v:set(packet.key.levelup_level, banner_lists[w_select_pic].banner_level)
  v:set(packet.key.guild_banner_id, w_select_pic)
  bo2.send_variant(packet.eCTS_Guild_Banner_Update, v)
  clear_banner()
  update_banner(banner_lists)
end
function btn_active_click(btn)
  local banner_on = bo2.gv_define_org:find(120).value.v_int
  if banner_on ~= 1 then
    ui_chat.show_ui_text_id(70822)
    return
  end
  if not may_active_banner(banner_lists[w_select_pic]) then
    return
  end
  local v = sys.variant()
  v:set(packet.key.cmn_type, 1)
  v:set(packet.key.guild_banner_id, w_select_pic)
  bo2.send_variant(packet.eCTS_Guild_Banner_Active, v)
  clear_banner()
  update_banner(banner_lists)
end
function btn_select_click(btn)
  if w_select_type == -1 then
    ui_chat.show_ui_text_id(70829)
    return
  end
  local my_banner_list = banner_lists[w_select_pic]
  if w_change_type_flag == 1 and my_banner_list.banner_type == w_select_type + 1 then
    ui_chat.show_ui_text_id(70844)
    return
  end
  local v = sys.variant()
  v:set(packet.key.cmn_type, w_select_type + 1)
  v:set(packet.key.levelup_level, 0)
  v:set(packet.key.guild_banner_id, w_select_pic)
  v:set(packet.key.guild_banner_changeflag, w_change_type_flag)
  bo2.send_variant(packet.eCTS_Guild_Banner_Update, v)
  clear_banner()
  update_banner(banner_lists)
  w_change_type_flag = -1
end
function banner_type_click(btn)
  local parent = btn.parent
  local control_cnt = parent.control_size
  for i = 0, control_cnt - 1 do
    local ctr = parent:control_get(i)
    if ctr == btn then
      w_select_type = i
      break
    end
  end
  w_select_btn.enable = true
end
function btn_return_click(btn)
  clear_banner()
  update_banner(banner_lists)
end
function in_self_banner(pic_id)
  w_banner_left_info.visible = false
  w_banner_left_info_self_banner.visible = true
  local imax_banner = w_banner_left_info_self_banner:search("portrait")
  imax_banner.image = "$image/guild/banner/a_00" .. pic_id .. ".png"
  w_active.enable = true
  w_active.text = ui.get_text("guild|banner_active_btn_n")
  local active_on = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Guild_Banner_On)
  if active_on ~= 0 then
    w_active.enable = false
    w_active.text = ui.get_text("guild|banner_active_btn_y")
  end
  local now_wearout = banner_lists[pic_id].banner_wearout
  local wear_out = now_wearout .. "/" .. w_max_wearout
  w_wearout.text = wear_out
  w_repair.enable = false
  local self = ui.guild_get_self()
  local excel = bo2.gv_guild_auth:find(self.guild_pos)
  local mb_data = bo2.gv_cooldown_list:find(50107)
  local large_token = mb_data.token
  if large_token <= w_sec_token or excel.update_banner ~= 1 then
    w_repair.enable = false
  else
    w_repair.enable = true
  end
  w_sec_token = banner_lists[pic_id].sec_token
end
function guild_banner_picture_on_mouse(ctrl, msg, pos, wheel)
  local pic_name = ctrl.parent.name
  local pic_id = 1
  local pic_id_str = pic_name:substr(pic_name.size - 2)
  pic_id = pic_id_str.v_int
  if pic_id < 1 or pic_id > MaxBannerNum then
    return
  end
  if msg == ui.mouse_lbutton_dbl then
    if get_self_banner(banner_lists) ~= tonumber(0) and get_self_banner(banner_lists) == tonumber(pic_id) then
      in_self_banner(pic_id)
      return
    end
  elseif msg == ui.mouse_lbutton_click then
    if banner_lists[pic_id].org_id ~= tonumber(0) then
      update_banner_right_info(banner_lists[pic_id])
    else
      local banner_list = {
        org_id = 0,
        name = L(""),
        banner_id = pic_id,
        banner_level = 1,
        banner_type = 1
      }
      update_banner_right_info(banner_list)
    end
    update_select_banner_pic(pic_id)
    w_select_pic = pic_id
  end
end
function get_self_banner(banner_lists)
  local org_id = ui.guild_id()
  if org_id == nil then
    return 0
  end
  local banner_id = 0
  for i = 1, MaxBannerNum do
    local banner = banner_lists[i]
    if org_id.v_int ~= tonumber(0) and banner.org_id.v_int == org_id.v_int then
      banner_id = i
      break
    end
  end
  return banner_id
end
function update_left_update_banner(banner_lists)
  for i = 1, MaxBannerNum do
    local guild_picture = w_banner_left_info:search("banner_0" .. i)
    if i > 9 then
      guild_picture = w_banner_left_info:search("banner_" .. i)
    end
    local banner_btn = guild_picture:search("banner_btn")
    local guild_banner_pic = banner_btn:search("banner_image")
    if banner_lists[i].org_id.v_int ~= tonumber(0) then
      if i > 9 then
        guild_banner_pic.image = "$image/guild/banner/b_0" .. i .. ".png"
      else
        guild_banner_pic.image = "$image/guild/banner/b_00" .. i .. ".png"
      end
    end
  end
end
function update_banner(banner_lists)
  local self = ui.guild_get_self()
  update_left_update_banner(banner_lists)
  if self == nil then
    return
  end
  local banner_id = get_self_banner(banner_lists)
  if banner_id ~= 0 and banner_id ~= nil then
    update_banner_right_info(banner_lists[banner_id])
  else
    update_banner_right_info(banner_lists[1])
    banner_id = 1
  end
  update_select_banner_pic(banner_id)
  update_self_banner_pic()
  w_select_pic = banner_id
end
function on_banner_tip_show(tip)
  local pic_name = tip.owner.parent.name
  local pic_id_str = pic_name:substr(pic_name.size - 2)
  pic_id = pic_id_str.v_int
  if pic_id < 1 or pic_id > MaxBannerNum then
    return
  end
  local text
  local stk = sys.mtf_stack()
  local banner_list = banner_lists[pic_id]
  local org_name = banner_list.org_name
  local org_level = banner_list.org_level
  local banner_level = banner_list.banner_level
  if org_name == L("") then
    org_name = ui.get_text("guild|no_levelup")
    org_level = 0
    banner_level = 1
  end
  local banner_atb_line = get_build_banner_atb_line(banner_list)
  if banner_atb_line == nil then
    return
  end
  ui_tool.ctip_push_text(stk, ui.get_text("guild|org_name"), "FFFFFF", ui_tool.cs_tip_a_add_l)
  ui_tool.ctip_push_text(stk, org_name, "8250af", ui_tool.cs_tip_a_add_r)
  ui_tool.ctip_push_newline(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("guild|org_level"), "FFFFFF", ui_tool.cs_tip_a_add_l)
  ui_tool.ctip_push_text(stk, org_level, "59a1fe", ui_tool.cs_tip_a_add_r)
  ui_tool.ctip_push_newline(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("guild|banner_level"), "FFFFFF", ui_tool.cs_tip_a_add_l)
  ui_tool.ctip_push_text(stk, banner_level, "59a1fe", ui_tool.cs_tip_a_add_r)
  ui_tool.ctip_push_sep(stk)
  if banner_list.org_id.v_int == tonumber(0) then
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("guild|banner_active_money"), "FFFFFF", ui_tool.cs_tip_a_add_l)
    local tips = ui_widget.merge_mtf({
      money = banner_atb_line.week_money / 10000
    }, ui.get_text("guild|banner_money_jin"))
    ui_tool.ctip_push_text(stk, tips, "59a1fe", ui_tool.cs_tip_a_add_r)
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("guild|banner_active_develop"), "FFFFFF", ui_tool.cs_tip_a_add_l)
    ui_tool.ctip_push_text(stk, banner_atb_line.week_develop, "59a1fe", ui_tool.cs_tip_a_add_r)
  end
  ui_tool.ctip_push_newline(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("guild|banner_add_atb"), "FFFFFF", ui_tool.cs_tip_a_add_l)
  ui_tool.ctip_push_newline(stk)
  ui_tool.ctip_push_text(stk, banner_atb_line.atb_name, "CAFF70", ui_tool.cs_tip_a_add_l)
  if org_level == 0 then
    function copyTab(st)
      local tab = {}
      for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
          tab[k] = v
        else
          tab[k] = copyTab(v)
        end
      end
      return tab
    end
    local new_banner_list = copyTab(banner_list)
    new_banner_list.banner_type = 2
    banner_atb_line = get_build_banner_atb_line(new_banner_list)
    if banner_atb_line == nil then
      return
    end
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("guild|banner_add_atbs_or"), "FFFFFF", ui_tool.cs_tip_a_add_l)
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, banner_atb_line.atb_name, "CAFF70", ui_tool.cs_tip_a_add_l)
    new_banner_list.banner_type = 3
    banner_atb_line = get_build_banner_atb_line(new_banner_list)
    if banner_atb_line == nil then
      return
    end
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("guild|banner_add_atbs_or"), "FFFFFF", ui_tool.cs_tip_a_add_l)
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, banner_atb_line.atb_name, "CAFF70", ui_tool.cs_tip_a_add_l)
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("guild|guild_banner_hold_item"), "FFFFFF", ui_tool.cs_tip_a_add_l)
    ui_tool.ctip_push_newline(stk)
    local tip_x = bo2.gv_text:find(160686)
    if tip_x == nil or tip_x.text.empty then
      return
    end
    stk:raw_push(cs_tip_newline)
    stk:raw_format("<c+:9F601B>%s<c->", tip_x.text)
  end
  if banner_list.org_id.v_int ~= tonumber(0) and get_self_banner(banner_lists) == tonumber(pic_id) then
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("guild|banner_tips_active_ui"), "FF0000", ui_tool.cs_tip_a_add_l)
  end
  ui_tool.ctip_show(tip.owner, stk)
end
function clear_self_banner_pic()
  for i = 1, MaxBannerNum do
    local guild_picture = w_banner_left_info:search("banner_0" .. i)
    local index = i
    if i > 9 then
      guild_picture = w_banner_left_info:search("banner_" .. i)
      index = "0" .. i
    end
    local self_pic = guild_picture:search("self_banner_pic")
    self_pic.visible = false
    local banner_btn = guild_picture:search("banner_btn")
    local guild_banner_pic = banner_btn:search("banner_image")
    if i > 9 then
      guild_banner_pic.image = "$image/guild/banner/c_0" .. i .. ".png"
    else
      guild_banner_pic.image = "$image/guild/banner/c_00" .. i .. ".png"
    end
  end
end
function clear_left()
  clear_self_banner_pic()
  w_banner_left_info.visible = true
  w_banner_left_info_self_banner.visible = false
  w_banner_left_info_select_type.visible = false
end
function clear_right()
end
function clear_banner()
  clear_left()
  clear_right()
  local cur_money = ui.guild_get_money()
  g_guild_money.color = ui.make_color("ffffff")
  if cur_money < 0 then
    cur_money = -cur_money
    g_guild_money.color = ui.make_color("FF0000")
  end
  g_guild_money.money = cur_money
  g_guild_develop.text = ui.guild_get_develop()
end
function on_init(ctrl)
  for i = 1, MaxBannerNum do
    local guild_picture = w_banner_left_info:search("banner_0" .. i)
    if i > 9 then
      guild_picture = w_banner_left_info:search("banner_" .. i)
    end
    local banner_lalel = guild_picture:search("org_name")
    local banner_name = get_banner_name(i)
    if banner_name ~= L("") then
      banner_lalel.text = banner_name
    end
  end
end
function handGuildBannerData(cmd, data)
  banner_lists = {}
  local v = data:get(packet.key.cmn_dataobj)
  for i = 0, v.size - 1 do
    local data = v:get(i)
    local banner_list = {
      org_id = data:get(packet.key.org_id),
      org_level = data:get(packet.key.guild_level).v_int,
      org_name = data:get(packet.key.org_name).v_string,
      banner_id = data:get(packet.key.guild_banner_id).v_int,
      banner_level = data:get(packet.key.levelup_level).v_int,
      banner_type = data:get(packet.key.cmn_type).v_int,
      banner_wearout = data:get(packet.key.guild_banner_wearout).v_int,
      sec_token = data:get(packet.key.ui_cd_view_keep_sec).v_int
    }
    table.insert(banner_lists, banner_list)
  end
  clear_banner()
  update_banner(banner_lists)
end
function update_selfinfo(cmd, data)
  local cur_money = ui.guild_get_money()
  local ctrl = g_follow:search("gx_guild_money")
  local label1 = ctrl:search("l_lable_left1")
  local label2 = ctrl:search("l_lable_left2")
  label1.visible = true
  label2.visible = false
  g_guild_money.color = ui.make_color("ffffff")
  if cur_money < 0 then
    cur_money = -cur_money
    g_guild_money.color = ui.make_color("FF0000")
    label1.visible = false
    label2.visible = true
  end
  g_guild_money.money = cur_money
  g_guild_develop.text = ui.guild_get_develop()
end
ui_packet.game_recv_signal_insert(packet.eSTC_UI_Guild_Banner_Data, handGuildBannerData, ui_guild_mod.ui_guild_banner.handGuildBannerData)
ui_packet.game_recv_signal_insert(packet.eSTC_Guild_SelfData, update_selfinfo, ui_guild_mod.ui_guild_banner.update_selfinfo)
function handChange_GuildBanner_Type(info)
  local banner_on = bo2.gv_define_org:find(120).value.v_int
  if banner_on ~= 1 then
    ui_chat.show_ui_text_id(70822)
    return
  end
  local self = ui.guild_get_self()
  if self == nil then
    return
  end
  local guild_auth = bo2.gv_guild_auth:find(self.guild_pos)
  if guild_auth == nil or guild_auth.update_banner == 0 then
    ui_chat.show_ui_text_id(70013)
    return
  end
  local my_banner_id = get_self_banner(banner_lists)
  if my_banner_id == 0 then
    ui_chat.show_ui_text_id(70842)
    return
  end
  w_select_pic = my_banner_id
  w_banner_left_info.visible = false
  w_banner_left_info_select_type.visible = true
  w_levelup.enable = false
  w_change_type_flag = 1
end
function repair_build_price(w)
  local box_money = w:search("box_money")
  local box_input = w:search("box_input")
  local stk = sys.mtf_stack()
  stk:raw_push("<a:m>")
  stk:raw_push(ui.get_text("npcfunc|shop_total_price"))
  local count = box_input.text.v_int
  if count < 1 then
    stk:raw_push("0")
    box_money.mtf = stk.text
    return
  end
  local guild_money = ui.guild_get_money()
  local my_banner_list = banner_lists[w_select_pic]
  local need_repair_count = w_max_wearout - my_banner_list.banner_wearout
  local max_repair = guild_money / w_each_money
  if count > need_repair_count then
    count = need_repair_count
  end
  if max_repair < count then
    count = max_repair
  end
  box_input.text = count
  local money = w_each_money * count
  txt = sys.format("<m:%d>", money)
  stk:raw_push(txt)
  box_money.mtf = stk.text
end
function on_msg_repair_count(box)
  repair_build_price(box.topper)
end
function btn_repair_click(btn)
  local self = ui.guild_get_self()
  if self == nil then
    return
  end
  local guild_auth = bo2.gv_guild_auth:find(self.guild_pos)
  if guild_auth == nil or guild_auth.update_banner == 0 then
    ui_chat.show_ui_text_id(70013)
    return
  end
  local my_banner_list = banner_lists[w_select_pic]
  if my_banner_list.banner_wearout == w_max_wearout then
    ui_chat.show_ui_text_id(70846)
    return
  end
  local guild_money = ui.guild_get_money()
  if guild_money < w_each_money then
    ui_chat.show_ui_text_id(70157)
    return
  end
  local token = bo2.get_cd_real_token(50107)
  if token <= 0 then
    ui_chat.show_ui_text_id(70865)
    return
  end
  local on_msg = function(msg)
    if msg.result == 0 then
      return
    end
    local count = 0
    if msg.input ~= nil then
      count = L(msg.input).v_int
    end
    if count == 0 then
      return
    end
    local v = sys.variant()
    v:set(packet.key.guild_banner_wearout, count)
    bo2.send_variant(packet.eCTS_Guild_Repair_Banner_Wearout, v)
  end
  local on_msg_init = function(msg)
    local w = msg.window
    w.svar.shop_msg = msg
    w:tune_y("rv_text")
    repair_build_price(w)
  end
  local msg = {
    init = on_msg_init,
    callback = on_msg,
    modal = true,
    limit = 3,
    number_only = true,
    style_uri = "$frame/guild/guild_banner.xml",
    style_name = "msg_box_item_buy"
  }
  msg.text = ui.get_text("guild|repair_info")
  msg.input = 1
  ui_widget.ui_msg_box.show_common(msg)
end
function btn_hit_click(btn)
  local function on_btn_hit_msg(msg)
    if msg == nil then
      return
    end
    if msg.result == 1 then
      local v = sys.variant()
      v:set(packet.key.org_id, banner_lists[w_select_pic].org_id)
      v:set(packet.key.guild_banner_id, w_select_pic)
      v:set(packet.key.ui_varpacket_cmd, bo2.eTypeHitGuildBanner)
      v:set(packet.key.campaign_eventid, 17562)
      bo2.send_variant(packet.eCTS_UI_Check_Campaign_ON, v)
    end
  end
  local msg = {
    callback = on_btn_hit_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  local arg = sys.variant()
  arg:set("count", w_hit_use_contri)
  msg.text = sys.mtf_merge(arg, ui.get_text("guild|text_hit_msg"))
  ui_widget.ui_msg_box.show_common(msg)
end
function btn_on_tip_show_repair(tip)
  local mb_data = bo2.gv_cooldown_list:find(50107)
  local large_token = mb_data.token
  local stk = sys.mtf_stack()
  text = sys.format(ui.get_text("guild|tips_btn_repair"), w_sec_token, large_token)
  stk:push(text)
  ui_tool.ctip_show(tip.owner, stk)
end
function btn_on_tip_show_hit(tip)
  local stk = sys.mtf_stack()
  text = sys.format(ui.get_text("guild|tips_btn_hit"), w_hit_use_contri)
  stk:push(text)
  ui_tool.ctip_show(tip.owner, stk)
end
