MEMBER_NUM_MAX = 4
offline_image = SHARED("$icon/portrait/zj/0000.png")
c_image_frm = L("$image/cha/portrait/group_frm.png")
c_image_frm1 = L("$image/cha/portrait/group_frm1.png")
local c_image_status_near = L("$image/portrait/teammate_status.png|1,1,26,26")
local c_image_status_far = L("$image/portrait/teammate_status.png|1,30,26,26")
local c_image_status_otherScn = L("$image/portrait/teammate_status.png|1,88,26,26")
local c_image_status_offline = L("$image/portrait/teammate_status.png|1,146,26,26")
local current_scn_id = 0
local c_image_qt_offline = L("$image/guild/qt_sound.png|19,301,16,20")
local c_image_qt_online = L("$image/guild/qt_sound.png|19,187,16,20")
local c_image_qt_speaking = L("$image/guild/qt_sound.png|19,226,16,20")
local c_image_qt_masked = L("$image/guild/qt_sound.png|19,261,16,20")
local disable_qt = bo2.gv_define:find(1106).value.v_int
function get_gzs_name(id)
  for i, v in ipairs(ui_choice.server_list_data) do
    if v ~= nil and v.id == id then
      return v.name
    end
  end
  if ui_minimap.server_list_data ~= nil then
    for i, v in ipairs(ui_minimap.server_list_data) do
      if v ~= nil and v.id == id then
        return v.name
      end
    end
  end
  return nil
end
function set_member_selected(obj)
  do return end
  if obj == nil then
    for i = 1, MEMBER_NUM_MAX do
      local parent = ui_resource[i].control_parent
      local only_id = mem_data[i].cha_onlyid
      local frame = parent:search("frame")
      frame.image = c_image_frm1
    end
    return
  end
  for i = 1, MEMBER_NUM_MAX do
    local parent = ui_resource[i].control_parent
    if parent ~= nil then
      local only_id = mem_data[i].cha_onlyid
      local frame = parent:search("frame")
      if only_id == obj.only_id then
        frame.image = c_image_frm
      else
        frame.image = c_image_frm1
      end
    end
  end
end
function get_career_idx(val)
  local pro = bo2.gv_profession_list:find(val)
  if pro == nil then
    return 0
  end
  return pro.career - 1
end
function on_team_member_click(btn, msg, pos)
  if msg == ui.mouse_rbutton_down then
    do
      local top = btn:upsearch_name("member_top")
      local md
      if team_captain_data.window == top then
        md = team_captain_data
      else
        for i, d in ipairs(member_data) do
          if d.window == top then
            md = d
            break
          end
        end
      end
      local only_id = md.info.only_id
      local data = {
        items = {
          {
            text = ui.get_text("menu|move_to"),
            callback = send_move_to
          },
          {
            text = ui.get_text("menu|chat"),
            callback = function(mi)
              local name = mi.name
              ui_chat.set_channel(bo2.eChatChannel_PersonalChat, name, name)
            end
          },
          {
            text = ui.get_text("menu|copy_name"),
            callback = function(mi)
              ui.cb_copy(mi.name)
            end
          }
        },
        event = function(item)
          local info = ui.member_find(only_id)
          if info == nil then
            return
          end
          local callback = item.callback
          callback(info)
        end,
        auto_size = true,
        dx = 100,
        dy = 50,
        source = btn,
        consult = btn,
        popup = "x2"
      }
      if bo2.get_captain_id() == bo2.player.only_id then
        table.insert(data.items, {
          text = ui.get_text("menu|set_captain"),
          callback = function(mi)
            ui_group.send_change_captain(mi.name)
          end
        })
        table.insert(data.items, {
          text = ui.get_text("menu|delete_member"),
          callback = function(mi)
            ui_group.send_delete_member(mi.name)
          end
        })
      end
      local f = ui_im.friend_name_list[md.info.name]
      if f == nil or f.thetype == 0 then
        table.insert(data.items, {
          text = ui.get_text("menu|make_friend"),
          callback = function(mi)
            ui_sociality.send_make_friend_with_cha(mi.name)
          end
        })
      end
      ui_tool.show_menu(data)
      data.window.offset = btn.abs_area.p1 + pos
    end
  elseif msg == ui.mouse_lbutton_click then
    local top = btn:upsearch_name("member_top")
    local name = top:search("name").text
    local obj = bo2.get_scn_obj_by_name(name)
    ui.log("set target:%s", name)
    if obj ~= nil then
      bo2.send_target_packet(obj.sel_handle)
    end
  end
end
function on_status_tip_make(tip)
  local parent = tip.owner.parent
  local name = parent:search("name").text
  local info = ui.member_get_by_name(name)
  local status = info.status
  local text
  if status == 1 then
    text = ui.get_text("portrait|tip_online")
  end
  if info.hp <= 0 then
    text = ui.get_text("portrait|tip_dead")
  end
  if status == 0 then
    text = ui.get_text("portrait|tip_offline")
  end
  ui_widget.tip_make_view(tip.view, text)
end
function on_member_career_tip_make(tip)
  local parent = tip.owner.parent
  local name = parent:search("name").text
  local info = ui.member_get_by_name(name)
  local text = make_career_tip_text_i(info.career)
  ui_widget.tip_make_view(tip.view, text)
end
function on_member_camp_tip_make(tip)
  local parent = tip.owner.parent
  local name = parent:search("name").text
  local info = ui.member_get_by_name(name)
  local text
  local c = info.camp
  if c == bo2.eCamp_Blade then
    text = ui.get_text("phase|camp_blade")
  else
    text = ui.get_text("phase|camp_sword")
  end
  ui_widget.tip_make_view(tip.view, text)
end
function on_qt_state(tip)
  local parent = tip.owner.parent
  local name = parent:search("name").text
  local info = ui.member_get_by_name(name)
  local state = info.qt_state
  local text = L("")
  if state == 0 then
    text = ui.get_text("qt|team_chat_enable")
  elseif state == 1 then
    text = ui.get_text("qt|team_chat_disable")
  elseif state == 2 then
    text = ui.get_text("qt|team_chat_disable_now")
  elseif state == 4 then
    text = ui.get_text("qt|team_not_in")
  else
    text = ui.get_text("qt|team_not_in")
  end
  if 0 == bo2.qt_is_loaded() then
    text = ui.get_text("qt|team_no_voice")
  end
  if 0 == info.status then
    text = ui.get_text("qt|team_not_online")
  end
  local room_id = bo2.qt_cur_room_id()
  if room_id ~= -1 then
    text = ui.get_text("qt|team_self_not_in")
  end
  ui_widget.tip_make_view(tip.view, text)
end
function on_qt_icon_mouse(btn, msg, pos)
  if msg == ui.mouse_lbutton_down then
    local top = btn:upsearch_name("member_top")
    local md
    for i, d in ipairs(member_data) do
      if d.window == top then
        md = d
        break
      end
    end
    local only_id = md.info.only_id
    local info = ui.member_find(only_id)
    if info == nil then
      return
    end
    local state = info.qt_state
    local text = L("")
    if state == 0 then
      bo2.qt_cancel_mask(0, info.name)
    elseif state == 1 then
      bo2.qt_mask(0, info.name)
    elseif state == 2 then
      bo2.qt_mask(0, info.name)
    elseif state == 4 then
    end
  else
  end
end
function on_map_tip_make(tip)
  local parent = tip.owner.parent.parent
  local name = parent:search("name").text
  local info = ui.member_get_by_name(name)
  if info == nil then
    ui_widget.tip_make_view(tip.view, " ")
    return
  end
  if info.status == 0 then
    ui_widget.tip_make_view(tip.view, ui.get_text("portrait|tip_offline"))
    return
  end
  local scn = bo2.gv_scn_list:find(info.scn_id)
  local area_list = bo2.gv_area_list:find(info.area_id)
  local gzs_name = get_gzs_name(info.gzs_id)
  if gzs_name == nil then
    gzs_name = ui.get_text("portrait|unknow_line")
  end
  local img, gray = tip.owner.image:split2("?")
  local obj_dist
  if tostring(gray) == "gray" then
    obj_dist = ui.get_text("portrait|far")
  else
    obj_dist = ui.get_text("portrait|near")
  end
  local scn_name
  if scn ~= nil then
    scn_name = scn.name
  else
    scn_name = ui.get_text("portrait|unknown_scn")
  end
  local area_name
  if area_list ~= nil then
    area_name = area_list.display_name
  elseif scn ~= nil then
    area_name = scn_name
  else
    area_name = ui.get_text("portrait|unknown_area")
  end
  local text = ui_widget.merge_mtf({
    name = name,
    gzs = gzs_name,
    scn = scn_name,
    area = area_name,
    dist = obj_dist
  }, ui.get_text("portrait|map_tip"))
  ui_widget.tip_make_view(tip.view, text)
end
function set_config(data)
  local autoadd_enable = data[packet.key.group_autoadd_enable]
  if autoadd_enable ~= nil then
    g_autoadd_enable = autoadd_enable
  end
  local alloc_mode = data:get(packet.key.group_alloc_mode).v_int
  local roll_lev = data:get(packet.key.group_alloc_rolllevel).v_int
  if alloc_mode == 0 or roll_lev == 0 then
    return
  end
  if g_alloc_mode == alloc_mode and g_roll_level == roll_lev then
    return
  end
  local num_max = data:get(packet.key.group_max_member_count).v_int
  local captain_id = bo2.get_captain_id()
  if bo2.player.only_id ~= captain_id and num_max ~= 20 then
    local mode_t, note_t
    if alloc_mode == bo2.eLootMod_GroupFree then
      mode_t = ui.get_text("menu|group_alloc_free")
    elseif alloc_mode == bo2.eLootMod_GroupRoll then
      mode_t = ui.get_text("menu|group_alloc_roll")
    elseif alloc_mode == bo2.eLootMod_GroupCaptainAssign then
      mode_t = ui.get_text("menu|group_alloc_captain")
    end
    if alloc_mode == bo2.eLootMod_GroupCaptainAssign then
      note_t = ui.get_text("team|alloc_note_captain")
    elseif roll_lev == 100 then
      note_t = ui.get_text("team|alloc_note_free")
    else
      note_t = ui.get_text("team|alloc_note")
    end
    local level_t = bo2.gv_lootlevel:find(roll_lev).name
    local text = ui_widget.merge_mtf({mode = mode_t, level = level_t}, note_t)
    ui_tool.note_insert(text, "FF00FF00")
  end
  g_alloc_mode = alloc_mode
  g_roll_level = roll_lev
end
function get_groupalloc_submenu()
  local mode_roll = bo2.eLootMod_GroupRoll
  local mode_free = bo2.eLootMod_GroupFree
  local mode_captain = bo2.eLootMod_GroupCaptainAssign
  local mode_data = {
    [mode_roll] = {
      items = {}
    },
    [mode_free] = {
      items = {}
    },
    [mode_captain] = {
      items = {}
    }
  }
  local is_captain = true
  if bo2.player.only_id ~= bo2.get_captain_id() then
    is_captain = false
  end
  local function insert_level(i, mode)
    local lootlevel = bo2.gv_lootlevel:find(i)
    if lootlevel == nil then
      return
    end
    local md = mode_data[mode]
    local item_text = lootlevel.name
    local item_color = ui.make_color(lootlevel.color)
    if g_alloc_mode == mode and g_roll_level == i then
      item_text = sys.format("[%s]", item_text)
      md.color = item_color
    end
    table.insert(md.items, {
      enable = is_captain,
      text = item_text,
      color = item_color,
      callback = function()
        if is_captain == false then
          ui_tool.note_insert(ui.get_text("portrait|warning_captain"), "FFFF0000")
          return
        end
        local pack = sys.variant()
        pack:set(packet.key.group_alloc_mode, mode)
        pack:set(packet.key.group_alloc_rolllevel, i)
        bo2.send_variant(packet.eCTS_Group_SetConfig, pack)
      end
    })
  end
  for i = 11, 15 do
    insert_level(i, mode_roll)
    insert_level(i, mode_free)
    insert_level(i, mode_captain)
  end
  insert_level(100, mode_roll)
  insert_level(100, mode_free)
  local free_text = ui.get_text("menu|group_alloc_free")
  local roll_text = ui.get_text("menu|group_alloc_roll")
  local captain_text = ui.get_text("menu|group_alloc_captain")
  if g_alloc_mode == mode_roll then
    roll_text = sys.format("[%s]", roll_text)
  elseif g_alloc_mode == mode_free then
    free_text = sys.format("[%s]", free_text)
  else
    captain_text = sys.format("[%s]", captain_text)
  end
  local items = {
    {
      text = free_text,
      color = mode_data[mode_free].color,
      sub_menu = {
        items = mode_data[mode_free].items
      }
    },
    {
      text = captain_text,
      color = mode_data[mode_captain].color,
      sub_menu = {
        items = mode_data[mode_captain].items
      }
    }
  }
  return {items = items}
end
local member_update_flag = {
  0,
  0,
  0,
  0
}
local member_update_posted = false
if rawget(_M, "member_data") == nil then
  member_data = {
    {},
    {},
    {},
    {}
  }
end
function show_membertalk(name, text)
  for i, d in ipairs(member_data) do
    local info = d.info
    if info ~= nil and info.name == name then
      local data = {
        input_ctrl = d.window,
        popup = "x2",
        text = text,
        time = bo2.gv_define:find(325).value.v_int,
        margin = ui.rect(5, -18, -112, 0),
        popup_margin = ui.rect(-5, -4, 0, 0),
        max_text_size = 32
      }
      ui_tool.ui_talkpopo.show_talkpopo(data)
      break
    end
  end
end
function set_member_data(data)
  local only_id = data:get(packet.key.cha_onlyid).v_string
  for i, d in ipairs(member_data) do
    local info = d.info
    if info ~= nil and info.only_id == only_id then
      member_update(i)
    end
  end
end
function on_click_group_btn(btn)
  local player = bo2.player
  if player == nil then
    return
  end
  local info = ui.member_find(player.only_id)
  if info == nil then
    ui_group.send_setteam()
    return
  end
  local menu = menu_make(player, 1)
  menu.source = btn
  ui_tool.show_menu(menu)
end
local group_alloc_color = function()
  local lootlevel = bo2.gv_lootlevel:find(g_roll_level)
  if lootlevel == nil then
    return ui.make_color("FFFFFF")
  end
  return lootlevel.color
end
function on_group_tip_make(tip)
  local player = bo2.player
  if player == nil then
    ui_widget.tip_make_view(tip.view, "group")
    return
  end
  local text
  local info = ui.member_find(player.only_id)
  if info == nil then
    text = ui.get_text("portrait|noteam_toteam")
  else
    local alloc_text
    local mode_roll = bo2.eLootMod_GroupRoll
    local mode_free = bo2.eLootMod_GroupFree
    if g_alloc_mode == mode_roll then
      alloc_text = sys.format("<c+:%.6x>%s<c->", group_alloc_color(), ui.get_text("menu|group_alloc_roll"))
    elseif g_alloc_mode == mode_free then
      alloc_text = sys.format("<c+:%.6x>%s<c->", group_alloc_color(), ui.get_text("menu|group_alloc_free"))
    else
      alloc_text = sys.format("<c+:%.6x>%s<c->", group_alloc_color(), ui.get_text("menu|group_alloc_captain"))
    end
    if info.only_id == bo2.get_captain_id() then
      text = ui.get_text("portrait|youarecaptain")
    else
      text = ui.get_text("portrait|youaremember")
    end
    text = ui_widget.merge_mtf({m = alloc_text}, text)
  end
  ui_widget.tip_make_view(tip.view, text)
end
function member_do_update_self(info)
  local player = bo2.player
  if player == nil then
    return
  end
  if info == nil or info.only_id == L("0") then
    w_group_btn_pic.image = "$image/qbar/qbar_main.png|36,108,21,21"
    w_team_together.visible = false
    return
  end
  local only_id = info.only_id
  if only_id == bo2.get_captain_id() then
    if bo2.get_cur_group_num() > 1 and disable_qt ~= 1 then
      w_team_together.visible = true
    end
    w_group_btn_pic.image = "$image/qbar/qbar_main.png|36,131,21,21"
  else
    w_group_btn_pic.image = "$image/qbar/qbar_main.png|36,154,21,21"
    w_team_together.visible = false
  end
end
local function member_update_portrait(d, info)
  if info.hp <= 0 then
    d.lb_name.xcolor = ui_team.c_status_dead
  else
    d.lb_name.xcolor = "FFFCE6C9"
  end
  local por_list = bo2.gv_portrait:find(info:get_flag_int32(bo2.ePlayerFlagInt32_Portrait))
  if por_list ~= nil then
    local dist = 1000
    local dist_near = 900
    if current_scn_id == 14 and info.scn_id == current_scn_id then
      dist = 5000
      dist_near = 4900
    end
    local player = bo2.player
    local obj = bo2.get_scn_obj_by_name(info.name)
    if player ~= nil and obj ~= nil then
      local dx1, dy1 = player:get_position()
      local dx2, dy2 = obj:get_position()
      local dx = dx2 - dx1
      local dy = dy2 - dy1
      dist = dx * dx + dy * dy
    end
    if info.hp <= 0 or dist_near < dist then
      d.pic_portrait.image = sys.format("%s%s.png?gray", g_portrait_path, por_list.icon)
    else
      d.pic_portrait.image = sys.format("%s%s.png", g_portrait_path, por_list.icon)
    end
    if info.scn_id ~= current_scn_id then
      d.window.svar = 2
      d.status_flag.image = c_image_status_otherScn
    elseif dist_near < dist then
      d.window.svar = 1
      d.status_flag.image = c_image_status_far
    else
      d.window.svar = 0
      d.status_flag.image = c_image_status_near
    end
  end
end
function member_do_update_single(idx, info)
  local d = member_data[idx]
  if info == nil or info.only_id == L("0") then
    d.window.visible = false
    d.info = nil
    d.only_id = nil
    return
  end
  d.window.visible = true
  d.info = info
  d.lb_name.text = info.name
  d.lb_level.text = sys.format("Lv%d", info.level)
  local only_id = info.only_id
  if only_id == bo2.get_captain_id() then
    d.pn_caption.visible = true
  else
    d.pn_caption.visible = false
  end
  if d.only_id ~= only_id then
    d.only_id = only_id
    ui_state.set_mini_handle(d.pn_state, only_id)
  end
  local career_idx = 0
  local pro = bo2.gv_profession_list:find(info.career)
  if pro ~= nil then
    career_idx = pro.career - 1
    make_career_color(d.pic_career, pro)
  end
  d.pic_career.irect = ui.rect(career_idx * 29, 98, (career_idx + 1) * 29 - 2, 128)
  d.pic_camp.image = sys.format("$image/qbar/camp_%d.png|0,0,27,27", info.camp)
  local per = 0
  if 1 <= info.hp_max then
    per = info.hp / info.hp_max
    if per > 1 then
      per = 1
    end
  end
  d.pic_hp.dx = 40 * per
  local is_online = info.status ~= 0
  if is_online then
    member_update_portrait(d, info)
    if disable_qt ~= 1 then
      d.qt_state.visible = true
      if info.qt_state == 0 then
        d.qt_state.image = c_image_qt_masked
      elseif info.qt_state == 1 then
        d.qt_state.image = c_image_qt_online
      elseif info.qt_state == 2 then
        d.qt_state.image = c_image_qt_speaking
      elseif info.qt_state == 4 then
        d.qt_state.image = c_image_qt_offline
      else
        d.qt_state.image = c_image_qt_offline
      end
    else
      d.qt_state.visible = false
    end
  else
    d.lb_name.xcolor = ui_team.c_status_offline
    d.pic_portrait.image = offline_image
    d.window.svar = 3
    d.status_flag.image = c_image_status_offline
    if disable_qt ~= 1 then
      d.qt_state.image = c_image_qt_offline
    end
  end
  d.pic_career.mouse_able = is_online
end
function member_do_update()
  member_update_posted = false
  local player = bo2.player
  local self_id = 0
  if player ~= nil then
    local info = ui.member_find(player.only_id)
    if info ~= nil then
      self_id = info.index
    end
  end
  local base_id = math.floor(self_id / 5) * 5
  local idx = 1
  for i = base_id, base_id + 4 do
    if i == self_id then
      local info = ui.member_get_by_idx(i)
      member_do_update_self(info)
    else
      if member_update_flag[idx] == 0 then
        member_update_flag[idx] = 1
        local info = ui.member_get_by_idx(i)
        member_do_update_single(idx, info)
      end
      idx = idx + 1
    end
  end
  w_team_captain.visible = false
  w_team_captain_.visible = true
  local team_id = ui.get_team_id()
  if team_id == L("0") then
    return
  end
  local info = ui.member_find(bo2.get_captain_id())
  if info == nil or info.index == self_id then
    return
  end
  w_team_captain.visible = true
  w_team_captain_.visible = false
  team_captain_data.lb_name.text = info.name
  team_captain_data.info = info
  member_update_portrait(team_captain_data, info)
end
function member_update(idx)
  if idx == nil then
    for i = 1, 4 do
      member_update_flag[i] = 0
    end
  else
    member_update_flag[idx] = 0
  end
  if not member_update_posted then
    member_update_posted = true
    w_team_member:insert_post_invoke(member_do_update, "ui_portrait.member_do_update")
  end
end
function member_data_init(idx, w)
  local d = member_data[idx]
  d.window = w
  d.lb_name = w:search("name")
  d.lb_level = w:search("level")
  d.pic_career = w:search("career")
  d.pic_camp = w:search("camp")
  d.pic_portrait = w:search("portrait")
  d.pic_hp = w:search("hp")
  d.pn_caption = w:search("captain_flag")
  d.pn_state = w:search("team_state")
  d.status_flag = w:search("status_flag")
  d.only_id = nil
  d.qt_state = w:search("qt_state")
  w.svar = 0
end
function on_team_init(ctrl)
  g_alloc_mode = 0
  g_roll_level = 0
  current_scn_id = 0
  member_data_init(1, w_team_member1)
  member_data_init(2, w_team_member2)
  member_data_init(3, w_team_member3)
  member_data_init(4, w_team_member4)
  team_captain_data = {}
  team_captain_data.lb_name = w_team_captain:search("name")
  team_captain_data.lb_mark = w_team_captain:search("mark")
  team_captain_data.pic_portrait = w_team_captain:search("portrait")
  team_captain_data.status_flag = w_team_captain:search("status_flag")
  team_captain_data.window = w_team_captain
  w_team_together.visible = false
  member_update_posted = false
  member_update()
end
function on_update_player_pos(obj)
  if obj == bo2.player then
    member_update()
  end
  local info = ui.member_find(obj.only_id)
  if info == nil then
    return
  end
  member_update(info.index)
end
function on_qt_team_status(cmd, data)
  member_update()
  ui_team.update_qt_status()
end
function on_qt_group_status(cmd, data)
  member_update()
  if ui_team.w_main.visible then
    ui_team.update_qt_status()
  end
  if ui_team.w_watch.visible then
    ui_team.ui_team_watch.update_qt_status()
  end
end
function on_qt_self_status(cmd, data)
end
function on_member_status_make(tip)
  local parent = tip.owner.parent
  local name = parent:search("name").text
  local text = ui_widget.merge_mtf({name = name}, ui.get_text("portrait|teammate_state_" .. parent.svar))
  ui_widget.tip_make_view(tip.view, text)
end
function on_player_enter_scn(obj)
  if obj == bo2.player then
    local scn_id = 0
    if bo2.scn and bo2.scn.scn_excel then
      scn_id = bo2.scn.scn_excel.id
    end
    if current_scn_id ~= scn_id then
      current_scn_id = scn_id
      on_update_player_pos(obj)
    end
  end
end
function on_qt_get_together()
  if bo2.get_captain_id() ~= bo2.player.only_id then
    ui_tool.note_insert(ui.get_text("team|inform_not_captain"), ui_team.warining_color)
    return
  end
  if bo2.qt_cur_room_id() ~= -1 then
    ui_tool.note_insert(ui.get_text("team|inform_not_in_team_room"), ui_team.warining_color)
    return
  end
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_Team_QTGetTogether, v)
end
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_protrait:on_signal"
reg(packet.eSTC_Fake_Qt_Team_Status, on_qt_team_status, sig)
reg(packet.eSTC_Group_QtStatus, on_qt_group_status, sig)
reg(packet.eSTC_Fake_Qt_Self_Status, on_qt_self_status, sig)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_position, on_update_player_pos, "ui_portrait:on_update_player_pos")
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enter_scn, on_player_enter_scn, "ui_portrait:on_player_enter_scn")
