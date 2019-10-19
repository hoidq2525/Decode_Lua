local ui_tab = ui_widget.ui_tab
local font_color = "A88A6A"
local remain_dy = 0
local remain_flag = false
local remain_in = false
local remain_mouse_in = false
c_senior_group_id = -1
c_friend_group_id = 0
c_stranger_group_id = 11
c_enemy_group_id = 12
c_blacklist_group_id = 13
function on_im_moving()
  if w_main.y == 0 and remain_flag == false and remain_mouse_in == false then
    if remain_in == false then
      remain_dy = w_main.dy
      remain_in = true
    end
    w_main.dy = w_main.dy - 20
    if w_main.dy <= 30 then
      w_main.dy = 30
      remain_flag = true
    end
  elseif remain_in == true and w_main.y ~= 0 then
    w_main.dy = w_main.dy + 20
    if w_main.dy >= remain_dy then
      w_main.dy = remain_dy
      remain_flag = false
      remain_in = false
    end
  elseif remain_in == true and remain_mouse_in == true then
    w_main.dy = w_main.dy + 20
    if w_main.dy >= remain_dy then
      w_main.dy = remain_dy
      remain_flag = false
      remain_in = false
    end
  end
end
function on_darg_mouse_in(btn, msg)
  if msg == ui.mouse_inner then
    remain_mouse_in = true
  elseif msg == ui.mouse_outer and remain_mouse_in == true then
    remain_mouse_in = false
    remain_flag = false
  end
end
function item_person_scale(w, flag)
  if flag == "large" then
    pic_scale_flag = true
    w.dy = 48
    w:search("pic_panel").dx = 48
    w:search("pic_panel").dy = 48
    w:search("name_panel").dy = 48
    w:search("xinqing1").visible = false
    w:search("large_panel").visible = true
  elseif flag == "small" then
    w.dy = 30
    w:search("pic_panel").dx = 25
    w:search("pic_panel").dy = 25
    w:search("name_panel").dy = 25
    w:search("xinqing1").visible = true
    w:search("large_panel").visible = false
  end
end
function on_item_person_mouse(btn, msg, pos, wheel)
  local name = btn.var:get("name").v_string
  if msg == ui.mouse_lbutton_drag then
    for k, v in pairs(friend_group_list) do
      if v.item == btn.topper and v.id == FG_ID_SENIOR then
        return
      end
    end
    local pic = btn:search("rel_icon")
    ui.set_cursor_icon(pic.image)
    local on_drop_hook = function(w, msg, pos, data)
      if msg == ui.mouse_drop_clean then
        for k, v in pairs(friend_group_list) do
          v.item.expanded = v.expanded
        end
      end
      if msg == ui.mouse_drop_setup then
      end
    end
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_im)
    data:set("name", name)
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
    for k, v in pairs(friend_group_list) do
      v.expanded = v.item.expanded
      v.item.expanded = false
    end
  end
  if msg == ui.mouse_lbutton_up and friend_select ~= btn.parent then
    if sys.check(friend_select) then
      friend_select:search("bg_fold").visible = false
    end
    btn.parent:search("bg_fold").visible = true
    friend_select = btn.parent
    if sys.check(friend_group_select) then
      friend_group_select:search("bg_fold").visible = false
      friend_group_select = nil
    end
  end
  if msg == ui.mouse_inner then
    btn.parent:search("bg_fold").visible = true
  end
  if msg == ui.mouse_outer and friend_select ~= btn.parent then
    btn.parent:search("bg_fold").visible = false
  end
  if msg == ui.mouse_lbutton_dbl then
    if btn.svar.is_senior then
      local item = create_friend_dialog(btn:search("label_name").text, -1)
    else
      local item = create_friend_dialog(btn:search("label_name").text, 1)
    end
  end
  if msg == ui.mouse_inner then
    show_im_tip(true, btn, name)
  end
  if msg == ui.mouse_outer then
    show_im_tip(false, btn, name)
  end
  if msg == ui.mouse_rbutton_down then
    local self_portrait_menu = {}
    if btn.svar.is_senior then
      generate_rb(name, -1)
    else
      generate_rb(name)
    end
    self_portrait_menu = {
      items = im_rb_items,
      event = on_player_portrait_event,
      info = {name = name, real_name = name},
      dx = 110,
      dy = 50,
      offset = btn.abs_area.p1 + pos
    }
    if self_portrait_menu then
      ui_tool.show_menu(self_portrait_menu)
    end
  end
end
function on_add_group_confirm(msg)
  if msg.result == 0 then
    return
  end
  if msg.input == nil then
    return
  end
  on_chg_group(0, msg.input)
end
function on_chg_group_confirm(msg)
  if msg.result == 0 then
    return
  end
  if msg.input == nil then
    return
  end
  on_chg_group(msg.data, msg.input)
  ui.log("on_chg_group_confirm id %s", msg.data)
end
function on_chg_group(id, name)
  local v = sys.variant()
  local group = sys.variant()
  group:set(id, name)
  v:set(packet.key.sociality_friendgroup, group)
  bo2.send_variant(packet.eCTS_Sociality_ChgFriendGroup, v)
end
function on_del_group_confirm(msg)
  if msg.result == 0 then
    return
  end
  ui.log("on_del_group_confirm id %s", msg.data)
  on_del_group(msg.data)
end
function on_del_group(id)
  ui.log("on_del_group id %s %s", id, packet.eCTS_Sociality_DelFriendGroup)
  local v = sys.variant()
  local group = sys.variant()
  group:set(id, name)
  v:set(packet.key.sociality_friendgroup, group)
  bo2.send_variant(packet.eCTS_Sociality_DelFriendGroup, v)
end
function on_chg_player_fg(name, id)
  ui.log("on_chg_player_fg %s %s", name, id)
  if id == FG_ID_FRIEND and friend_name_list[name] and friend_name_list[name].thetype == bo2.TWR_Type_Null then
    c_add_friend(name)
    return
  end
  if id == FG_ID_STRANGER or id == FG_ID_ENEMY or id == FG_ID_SENIOR then
    local v = sys.variant()
    v:set(packet.key.ui_text_id, 71527)
    ui_packet.recv_wrap(packet.eSTC_UI_ShowText, v)
    return
  end
  if id == FG_ID_BLACKLIST then
    ui_sociality.send_forbid_cha(name)
    return
  end
  local v = sys.variant()
  v:set(packet.key.sociality_tarplayername, name)
  v:set(packet.key.sociality_friendgroup_id, id)
  bo2.send_variant(packet.eCTS_Sociality_ChgPlayersFG, v)
end
function on_touxiang(panel, msg)
  if msg == ui.mouse_lbutton_down then
    create_info_dlg(bo2.player.name, true)
  end
  if msg == ui.mouse_inner then
    panel.parent:search("highlight").visible = true
    panel.parent:search("btn_chg").visible = true
  end
  if msg == ui.mouse_outer then
    panel.parent:search("highlight").visible = false
    panel.parent:search("btn_chg").visible = false
  end
end
function on_bg_menu(btn, msg, pos)
  if msg == ui.mouse_rbutton_down then
    local self_portrait_menu = {}
    self_portrait_menu = {
      items = im_rb_bg,
      event = on_player_portrait_event,
      info = {name = name, real_name = name},
      dx = 100,
      dy = 50,
      offset = btn.abs_area.p1 + pos
    }
    if self_portrait_menu then
      ui_tool.show_menu(self_portrait_menu)
    end
  end
end
function on_item_group_mouse(btn, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    if sys.check(group_select) then
      group_select:search("bg_fold").visible = false
    end
    btn.parent:search("bg_fold").visible = true
    group_select = btn.parent
    if sys.check(group_group_select) then
      group_group_select:search("bg_fold").visible = false
      group_group_select = nil
    end
  end
  if msg == ui.mouse_inner then
    btn.parent:search("bg_fold").visible = true
  end
  if msg == ui.mouse_outer and group_select ~= btn.parent then
    btn.parent:search("bg_fold").visible = false
  end
  if msg == ui.mouse_lbutton_dbl then
    local item = create_group_dialog(btn:search("label_name").text, btn.topper.svar.id)
  end
  if msg == ui.mouse_rbutton_down then
    local id = chatgroup_list[btn.topper.svar.id].id
    local items
    if id == nil then
      return
    end
    if chatgroup_list[id].team == true then
      return
    end
    if chatgroup_list[id].org == true then
      return
    end
    if bo2.player.name == chatgroup_list[id].leader then
      items = im_rb_cg1
    else
      items = im_rb_cg2
    end
    local self_portrait_menu = {}
    self_portrait_menu = {
      items = items,
      event = on_player_portrait_event,
      info = {
        id = id,
        name = btn:search("label_name").text
      },
      dx = 100,
      dy = 50,
      offset = btn.abs_area.p1 + pos
    }
    if self_portrait_menu then
      ui_tool.show_menu(self_portrait_menu)
    end
  end
end
function on_bottom_btn_sel(btn, sel)
  local image1 = btn:search("bg_image1")
  local image2 = btn:search("bg_image2")
  if image1 and image2 then
    if sel == true then
      image1.visible = false
      image2.visible = true
    elseif sel == false then
      image1.visible = true
      image2.visible = false
    end
  end
end
function on_create_fg(btn)
  local msg = {
    callback = on_add_group_confirm,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.title = ui.get_text("im|create_group")
  msg.text = ui.get_text("im|input_group_name")
  msg.input = L("")
  msg.limit = 16
  ui_widget.ui_msg_box.show_common(msg)
end
function on_btn_jiazhu(btn, msg)
  if msg == ui.mouse_inner then
    on_bottom_btn_sel(btn, true)
  elseif msg == ui.mouse_outer then
    on_bottom_btn_sel(btn, false)
  elseif msg == ui.mouse_lbutton_down then
    local msg = {
      callback = on_add_group_confirm,
      btn_confirm = true,
      btn_cancel = true,
      modal = true
    }
    msg.title = ui.get_text("im|create_group")
    msg.text = ui.get_text("im|input_group_name")
    msg.input = L("")
    msg.limit = 16
    ui_widget.ui_msg_box.show_common(msg)
  end
end
function on_btn_bangpai(btn, msg)
  w_chatgroup.visible = not w_chatgroup.visible
end
function on_btn_lixian(btn, msg)
  if msg == ui.mouse_inner then
    on_bottom_btn_sel(btn, true)
  elseif msg == ui.mouse_outer then
    on_bottom_btn_sel(btn, false)
  end
end
function on_btn_liulan(btn, msg)
  if msg == ui.mouse_inner then
    on_bottom_btn_sel(btn, true)
  elseif msg == ui.mouse_outer then
    on_bottom_btn_sel(btn, false)
  end
end
function on_btn_xitongxiaoxi(btn, msg)
  if msg == ui.mouse_inner then
    on_bottom_btn_sel(btn, true)
  elseif msg == ui.mouse_outer then
    on_bottom_btn_sel(btn, false)
  end
end
function on_btn_search(btn, msg)
  w_find_main.visible = not w_find_main.visible
  ui_handson_teach.test_complate_im(w_find_main.visible)
end
function on_btn_setup(btn, msg)
  w_imsetup.visible = not w_imsetup.visible
end
function on_btn_leaveword(btn, msg)
  w_leaveword.visible = not w_leaveword.visible
end
function on_btn_msg_control(btn, msg)
  w_im_msg_control.visible = not w_im_msg_control.visible
end
function on_fold_pass(btn, msg, pos)
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_dbl then
    if sys.check(friend_group_select) and friend_group_select:search("bg_fold") then
      friend_group_select:search("bg_fold").visible = false
    end
    btn.parent:search("bg_fold").visible = true
    friend_group_select = btn.parent
    if sys.check(friend_select) then
      friend_select:search("bg_fold").visible = false
      friend_select = nil
    end
    local group_flicker = friend_group_select.parent
    if group_flicker.suspended == false then
      group_flicker.suspended = true
    else
      for k, v in pairs(friend_group_list) do
        if v.item == btn.topper then
          if v.msg_num ~= nil and v.msg_num > 0 then
            group_flicker.suspended = false
          end
          return
        end
      end
      if my_chat_group == btn.topper then
        if 0 < my_chat_msg_num then
          group_flicker.suspended = false
        end
        return
      end
      if join_chat_group == btn.topper then
        if 0 < join_chat_msg_num then
          group_flicker.suspended = false
        end
        return
      end
    end
  end
  if msg == ui.mouse_inner then
    btn.parent:search("bg_fold").visible = true
  end
  if msg == ui.mouse_outer and friend_group_select ~= btn.parent then
    btn.parent:search("bg_fold").visible = false
  end
  if msg == ui.mouse_rbutton_down then
    ui.log("group right in")
    for k, v in pairs(friend_group_list) do
      if v.item == btn.topper then
        ui.log("group right %s", v.id)
        local self_portrait_menu = {}
        if v.default == true then
          if v.id == 0 then
            self_portrait_menu = {
              items = im_rb_group1,
              event = on_player_portrait_event,
              info = {
                id = v.id,
                name = v.title
              },
              dx = 100,
              dy = 50,
              offset = btn.abs_area.p1 + pos
            }
          else
            return
          end
        else
          self_portrait_menu = {
            items = im_rb_group,
            event = on_player_portrait_event,
            info = {
              id = v.id,
              name = v.title
            },
            dx = 100,
            dy = 50,
            offset = btn.abs_area.p1 + pos
          }
        end
        if self_portrait_menu then
          ui_tool.show_menu(self_portrait_menu)
        end
        return
      end
    end
  end
end
function on_fold_drop(btn, msg, pos, data)
  if msg == ui.mouse_enter then
    btn.parent:search("bg_fold").visible = true
  end
  if msg == ui.mouse_leave and friend_group_select ~= btn.parent then
    btn.parent:search("bg_fold").visible = false
  end
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  ui.clean_drop()
  ui.log("on drop in")
  if not ui_widget.check_drop(data, ui_widget.c_drop_type_im) then
    return
  end
  local name = data:get("name").v_string
  ui.log("drop %s", name)
  for k, v in pairs(friend_group_list) do
    if v.item == btn.topper then
      on_chg_player_fg(name, v.id)
      return
    end
  end
end
function insert_friend_group(id, text, def)
  local root = w_friend_top.root
  local style_uri = L("$gui/frame/im/im.xml")
  local style_name_g = L("node_group")
  local style_name_k = L("item_friend")
  local item_g = root:item_append()
  item_g:load_style(style_uri, style_name_g)
  item_g:search("btn_up").text = text
  item_g:search("btn_left").text = text
  item_g.expanded = false
  local d = {
    id = id,
    title = text,
    item = item_g,
    name = {}
  }
  if def ~= nil then
    d.default = def
  end
  friend_group_list[id] = d
  return d
end
function init_sort_priority()
  sort_priority[0] = 0
  sort_priority[bo2.TWR_Type_Friend] = 1
  sort_priority[bo2.TWR_Type_MasterAndApp] = 2
  sort_priority[bo2.TWR_Type_Sworn] = 3
  sort_priority[bo2.TWR_Type_Engagement] = 4
  sort_priority[bo2.TWR_Type_Couple] = 5
  online_priority[0] = 0
  online_priority[1] = 5
end
function friend_item_chgname(src, chg)
  for _, v in pairs(friend_group_list) do
    for idx, name in pairs(v) do
      if name == src then
        v[idx] = chg
      end
    end
  end
  remove_friend_item(src)
end
local friend_item_uri = SHARED("$frame/im/im.xml")
local friend_item_style = SHARED("item_friend")
function insert_friend_item(list, name)
  local child_item = list.item:item_append()
  child_item:load_style(friend_item_uri, friend_item_style)
  child_item:search("label_name").text = name
  table.insert(list.name, name)
  local friend_item = friend_item_list[name]
  if friend_item == nil then
    friend_item = {}
    friend_item_list[name] = friend_item
  end
  local item = friend_item.item
  if item == nil then
    item = {}
    friend_item.item = item
  end
  item[list.id] = {item = child_item, group = list}
  local item_person = child_item:search("item_person")
  local var = item_person.var
  var:set("name", name)
  var:set("group", list.id)
  item_person.svar.is_senior = false
end
function insert_person(type, name)
  remove_friend_item(name)
  insert_friend_item(friend_group_list[c_friend_group_id], name)
  refresh_group_list(friend_item_list[name].group)
  flash_items()
end
function remove_friend_item(name)
  local child = friend_item_list[name]
  if child == nil then
    return
  end
  friend_item_list[name] = nil
  for m, n in pairs(child.item) do
    local child_item = n.item
    if child_item then
      child_item:self_remove()
    end
    local group = n.group
    for i, v in ipairs(group.name) do
      if v == name then
        table.remove(group.name, i)
        post_refresh_group(group)
        break
      end
    end
  end
end
local c_effect_gray = SHARED("gray")
local c_effect_null = SHARED("")
local c_name_color_online = ui.make_color("FFFF00")
local c_name_color_offline = ui.make_color("737373")
function chg_friend_item_state(friend_name, state)
  if friend_item_list[friend_name] == nil then
    return
  end
  for k, v in pairs(friend_item_list[friend_name].item) do
    local child_item = v.item
    if state == 0 then
      child_item:search("label_name").color = c_name_color_offline
      child_item:search("rel_icon").effect = c_effect_gray
      child_item:search("career_icon").effect = c_effect_gray
    elseif state == 1 then
      child_item:search("label_name").color = c_name_color_online
      child_item:search("rel_icon").effect = c_effect_null
      child_item:search("career_icon").effect = c_effect_null
    end
    post_refresh_group(v.group)
  end
  if history_list[friend_name] ~= nil then
    local history_item = history_list[friend_name]
    if state == 0 then
      history_item:search("label_name").color = c_name_color_offline
      history_item:search("rel_icon").effect = c_effect_gray
      history_item:search("career_icon").effect = c_effect_gray
    elseif state == 1 then
      history_item:search("label_name").color = c_name_color_online
      history_item:search("rel_icon").effect = c_effect_null
      history_item:search("career_icon").effect = c_effect_null
    end
  end
end
function chg_friend_item_atb(friend_name, friend_item)
  local friend_data = friend_item_list[friend_name]
  if friend_data == nil then
    return
  end
  for k, v in pairs(friend_data.item) do
    local child_item = v.item
    if k == c_stranger_group_id then
      child_item:search("strange_icon").visible = true
    elseif k == c_enemy_group_id then
      child_item:search("enemy_icon").visible = true
    elseif k == c_blacklist_group_id then
      child_item:search("black_icon").visible = true
    else
      local friend_icon = child_item:search("friend_icon")
      local master_icon = child_item:search("master_icon")
      friend_icon.visible = true
      master_icon.visible = true
      if friend_item.thetype == bo2.TWR_Type_Engagement then
        friend_icon.image = uri_engagement
        friend_icon.tip.text = ui.get_text("im|re_2")
      elseif friend_item.thetype == bo2.TWR_Type_Couple then
        friend_icon.image = uri_couple
        friend_icon.tip.text = ui.get_text("im|re_3")
      elseif friend_item.thetype == bo2.TWR_Type_Sworn then
        friend_icon.image = uri_sworn
        friend_icon.tip.text = ui.get_text("im|re_4")
      else
        friend_icon.image = uri_friend
        friend_icon.tip.text = ui.get_text("im|re_1")
      end
      if friend_item.matype == 2 then
        master_icon.image = uri_master
        master_icon.tip.text = ui.get_text("im|re_master")
      elseif friend_item.matype == 1 then
        master_icon.image = uri_app
        master_icon.tip.text = ui.get_text("im|re_app")
      else
        master_icon.visible = false
      end
    end
    local portrait = bo2.gv_portrait:find(friend_item.flag[bo2.ePlayerFlagInt32_Portrait])
    if portrait ~= nil then
      child_item:search("rel_icon").image = g_portrait_path .. portrait.icon .. ".png"
    end
    local pro_excel = bo2.gv_profession_list:find(friend_item.atb[bo2.eAtb_Cha_Profession])
    if pro_excel ~= nil then
      dir = bo2.gv_career:find(pro_excel.career).dir
      if dir ~= nil then
        SetCareerIcon(child_item:search("career_icon"), pro_excel)
      end
    end
  end
  chg_friend_item_state(friend_name, friend_name_list[friend_name].state)
end
function SetCareerIcon(pic, pro_excel)
  pic.image = sys.format("$image/personal/32x32/%d.png|0,0,27,30", pro_excel.career)
  local tip = pic.tip
  local career_text = L("")
  if pro_excel.damage == 1 then
    pic.xcolor = "FF608CD9"
    career_text = sys.format("%s(<c+:608CD9>%s<c->)", pro_excel.name, ui.get_text("portrait|damage_type_1"))
  else
    pic.xcolor = "FFEE5544"
    career_text = sys.format("%s(<c+:EE5544>%s<c->)", pro_excel.name, ui.get_text("portrait|damage_type_0"))
  end
  if tip ~= nil then
    tip.text = career_text
  end
end
function insert_group_group(text)
  local root = w_group_top.root
  local style_uri = L("$gui/frame/im/im.xml")
  local style_name_g = L("node_group")
  local style_name_k = L("item_group")
  local item_g = root:item_append()
  item_g:load_style(style_uri, style_name_g)
  item_g:search("btn_up").text = text
  item_g:search("btn_left").text = text
  return item_g
end
function insert_group_item(item, text, uri, style)
  local child_item_uri = L("$frame/im/im.xml")
  local child_item_style = L("item_group")
  local child_item = item:item_append()
  if uri and style then
    child_item:load_style(uri, style)
  else
    child_item:load_style(child_item_uri, child_item_style)
  end
  child_item:search("label_name").text = text
  return child_item
end
function insert_tab(tab, name)
  local btn_uri = "$frame/im/btns.xml"
  local btn_sty = "btn_" .. name .. "_group"
  local page_uri = "$frame/im/im.xml"
  local page_sty = name .. "_panel"
  ui_tab.insert_suit(tab, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_tab.get_button(tab, name)
  btn.text = "123"
end
function on_btn_main_shut_btn(btn)
  btn.topper.visible = false
end
function create_groups()
  insert_friend_group(c_senior_group_id, ui.get_text("im|my_senior"), true)
  insert_friend_group(c_friend_group_id, ui.get_text("im|my_friend"), true)
  insert_friend_group(c_stranger_group_id, ui.get_text("im|stranger"), true)
  insert_friend_group(c_enemy_group_id, ui.get_text("im|enemy"), true)
  insert_friend_group(c_blacklist_group_id, ui.get_text("im|blacklist"), true)
end
function friend_group_sort(a, b)
  if a.id == -1 or b.id == -1 or a.id == 0 or b.id == 0 or a.id == 11 or b.id == 11 or a.id == 12 or b.id == 12 or a.id == 13 or b.id == 13 then
    return a.id < b.id
  else
    return a.item.index < b.item.index
  end
end
function create_sorted_friend_group_list()
  temp_friend_group_list = {}
  for k, v in pairs(friend_group_list) do
    table.insert(temp_friend_group_list, {
      id = v.id,
      name = v.title,
      item = v.item
    })
  end
  table.sort(temp_friend_group_list, friend_group_sort)
end
function add_group(id, name)
  insert_friend_group(id, name)
  create_sorted_friend_group_list()
  local index = 0
  for k, v in pairs(temp_friend_group_list) do
    v.item.index = index
    index = index + 1
  end
  w_friend_top.root:post_modify()
end
function update_group_expanded()
  ui.log("update_group_expanded")
  for k, v in pairs(friend_group_list) do
    if friend_group_expanded[v.id] ~= nil then
      v.item.expanded = friend_group_expanded[v.id]
    end
  end
end
function clear_group()
  friend_group_expanded = {}
  for k, v in pairs(friend_group_list) do
    friend_group_expanded[v.id] = v.item.expanded
  end
  w_friend_top.root:item_clear()
  friend_group_list = {}
  create_groups()
end
function on_visible(ctrl)
  if sys.check(ui_handson_teach.w_hide_im) and ui_handson_teach.w_hide_im.visible ~= true and ctrl.visible == true then
    ctrl.visible = false
    return
  end
  if ctrl.visible == true then
    local org_id = bo2.is_in_guild()
    if org_id ~= sys.wstring(0) then
      local v = sys.variant()
      bo2.send_variant(packet.eCTS_Guild_GetGuildList, v)
    end
    bo2.PlaySound2D(523)
    ui_handson_teach.test_complate_im(true)
    w_im_move_timer.suspended = false
    ctrl:search("lb_im_searchname").text = ui.get_text("im|lb_find_default")
  else
    ui_tool.hide_menu()
    bo2.PlaySound2D(524)
    ui_handson_teach.test_complate_im(false)
    w_im_move_timer.suspended = true
    local search_friend = w_main:search("search_friend")
    if search_friend ~= nil then
      search_friend.visible = false
    end
  end
end
function on_shutdown(btn)
  if btn.topper then
    btn.topper.visible = false
  end
end
function on_player_portrait_event(item)
  if item.callback then
    item:callback()
  end
end
function on_person_mouse(btn, msg, pos)
end
local get_update_data = function()
  local svar = w_main.svar
  local update_data = svar.update_data
  if update_data == nil then
    update_data = {}
    svar.update_data = update_data
  end
  return update_data
end
local update_one_item = function(k, v)
  remove_friend_item(k)
  if v.owtype ~= nil then
    for m, n in pairs(v.owtype) do
      if m == bo2.OWR_Type_Temp and v.thetype == 0 then
        insert_friend_item(friend_group_list[c_stranger_group_id], k)
        chg_friend_item_atb(k, v)
      end
      if m == bo2.OWR_Type_Exclude then
        insert_friend_item(friend_group_list[c_blacklist_group_id], k)
        chg_friend_item_atb(k, v)
      end
      if m == bo2.OWR_Type_Enemy then
        insert_friend_item(friend_group_list[c_enemy_group_id], k)
        chg_friend_item_atb(k, v)
      end
    end
  end
  local groupid = v.groupid
  if groupid == nil then
    ui.log("groupid is nil %s", v.name)
    ui.log("%s", sys.stack_trace)
    return
  end
  if groupid >= -1 and groupid <= 10 and v.thetype ~= bo2.TWR_Type_Null then
    for m, n in pairs(friend_group_list) do
      if n.id == v.groupid then
        insert_friend_item(n, k)
        chg_friend_item_atb(k, v)
        break
      end
    end
  end
end
local function do_update_item()
  local update_data = get_update_data()
  local items = update_data.items
  if items == nil then
    return
  end
  update_data.items = nil
  for k, x in pairs(items) do
    local v = friend_name_list[k]
    update_one_item(k, v)
  end
end
function post_update_item(k)
  local update_data = get_update_data()
  if update_data.all ~= nil then
    return
  end
  local items = update_data.items
  if items == nil then
    items = {}
    update_data.items = items
    w_main:insert_post_invoke(do_update_item, "ui_im.update_data")
  end
  items[k] = 1
end
local function do_update_data()
  for k, v in pairs(friend_group_list) do
    v.item:item_clear()
    v.name = {}
  end
  friend_item_list = {}
  for k, v in pairs(friend_name_list) do
    update_one_item(k, v)
  end
  for k, v in pairs(friend_group_list) do
    refresh_group_list(v)
  end
  update_group_num()
  flash_items()
  update_senior()
end
local function do_update()
  sys.pcall(do_update_data)
  local update_data = get_update_data()
  update_data.all = nil
  update_data.need_group_update = nil
end
function update()
  local update_data = get_update_data()
  update_data.all = 1
  update_data.items = nil
  w_main:insert_post_invoke(do_update, "ui_im.update_data")
end
function do_refresh_group()
  local update_data = get_update_data()
  if update_data.need_group_update == nil then
    return
  end
  update_data.need_group_update = nil
  if update_data.items ~= nil then
    return
  end
  if update_data.all ~= nil then
    return
  end
  for k, list in pairs(friend_group_list) do
    if list.need_update ~= nil then
      refresh_group_list(list)
    end
  end
  update_group_num()
  flash_items()
  update_senior()
end
function post_refresh_group(list)
  list.need_update = 1
  local update_data = get_update_data()
  if update_data.all ~= nil then
    return
  end
  if update_data.items ~= nil then
    return
  end
  if update_data.need_group_update ~= nil then
    return
  end
  update_data.need_group_update = 1
  w_main:insert_post_invoke(do_refresh_group, "ui_im.do_refresh_group")
end
function group_sort(a, b)
  local priority1 = sort_priority[friend_name_list[a].thetype] + online_priority[friend_name_list[a].state]
  local priority2 = sort_priority[friend_name_list[b].thetype] + online_priority[friend_name_list[b].state]
  if priority1 == priority2 then
    return a < b
  end
  return priority1 > priority2
end
function refresh_group_list(list)
  list.need_update = nil
  local list_id = list.id
  table.sort(list.name, group_sort)
  for i, v in ipairs(list.name) do
    friend_item_list[v].item[list_id].item.index = i - 1
  end
  list.item:post_modify()
end
function update_group_num()
  local get_online_num = function(list)
    local num = 0
    for i, v in ipairs(list) do
      if friend_name_list[v] and friend_name_list[v].state == 1 then
        num = num + 1
      end
    end
    return num
  end
  for k, v in pairs(friend_group_list) do
    if v.id ~= -1 then
      v.item:search("btn_up").text = sys.format("%s(%s/%s)", v.title, get_online_num(v.name), #v.name)
      v.item:search("btn_left").text = sys.format("%s(%s/%s)", v.title, get_online_num(v.name), #v.name)
    end
  end
end
function on_main_init(dlg)
  friend_item_list = {}
  senior_item_list = {}
  friend_group_list = {}
  friend_dialog_list = {}
  senior_dialog_list = {}
  sort_priority = {}
  online_priority = {}
  friend_name_list = {}
  senior_name_list = {}
  me = {}
  sns_info_list = {}
  sns_group_list = {}
  group_group_select = nil
  group_select = nil
  item_info = nil
  friend_group_select = nil
  friend_select = nil
  ui_tab.clear_tab_data(w_main_panel)
  insert_tab(w_main_panel, "friend")
  insert_tab(w_main_panel, "group")
  insert_tab(w_main_panel, "histroy")
  ui_tab.set_button_sound(w_main_panel, 578)
  init_sort_priority()
  create_groups()
  im_rb_list_init()
  im_relations = {}
  records_list = {}
  senior_records_list = {}
  w_qlink_flash.svar.names = {}
  senior_remind_quests = {}
  accepted_quest_list_ids = {}
  history_list = {}
  my_chat_group = insert_group_group(ui.get_text("im|my_group"))
  join_chat_group = insert_group_group(ui.get_text("im|my_join_group"))
  my_chat_msg_num = 0
  join_chat_msg_num = 0
  ui_tab.show_page(w_main_panel, "friend", true)
  local item_tip = ui.create_control(ui.find_control("$phase:tool"), "panel")
  item_tip:load_style("$frame/im/im_tip.xml", "im_tip")
  local item_info = ui.create_control(ui.find_control("$phase:main"), "panel")
  item_info:load_style("$frame/im/info.xml", "info")
  dlg.x = ui_phase.ui_main.w_top.dx
  dlg.y = ui_phase.ui_main.w_top.dy / 5
  local MANY_FRIENDS_TEST = false
  local MANY_FRIENDS_NUM = 40
  if MANY_FRIENDS_TEST == true then
    for i = 1, MANY_FRIENDS_NUM do
      local friend_item = {}
      local name = sys.wstring("test" .. i)
      friend_item.name = name
      friend_item.groupid = 0
      friend_item.thetype = 1
      friend_item.depth = 0
      friend_item.owtype = {}
      friend_item.matype = 0
      friend_item.state = 0
      friend_item.sign = "ad"
      friend_item.atb = {}
      friend_item.flag = {}
      friend_item.equip = {}
      friend_item.flag[bo2.ePlayerFlagInt32_Portrait] = 1001
      friend_item.atb[bo2.eAtb_Cha_Profession] = 10
      friend_item.atb[bo2.eAtb_Level] = 1
      friend_name_list[name] = friend_item
      ui.log("%s", name)
    end
  end
  ui_im.im_set_init_once()
  ui_im.dialog_moudle_init()
  w_main_knight_val.mouse_able = false
  w_main_knight_val.text = sys.format("%s: %d", ui.get_text("im|knight_value"), 0)
end
function friend_get_portrait(friend_data)
  local flag = friend_data.flag
  if sys.is_type(flag, "table") then
    local portrait = bo2.gv_portrait:find(flag[bo2.ePlayerFlagInt32_Portrait])
    return g_portrait_path .. portrait.icon .. ".png"
  else
    return g_portrait_path .. flag
  end
end
function on_friend_item_mouse()
end
function init_player(obj)
  if obj == bo2.player then
    w_name.text = bo2.player.name
    for k, v in pairs(chatgroup_list) do
      for m, n in pairs(v.members) do
        if v.leader == n.name then
          v.online = 1
          v.portrait = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Portrait)
          v.career = bo2.player:get_atb(bo2.eAtb_Cha_Profession)
        end
      end
    end
    obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_Portrait, on_player_portrait_chg, "ui_im:on_player_portrait_chg")
    obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_Errantry, on_player_errantry_chg, "ui_im:on_player_errantry_chg")
  end
end
function exist_in_exclude(name)
  local t = friend_name_list[name]
  ui.log("t %s", t)
  if t == nil then
    return false
  end
  if t.owtype ~= nil and t.owtype[bo2.OWR_Type_Exclude] == true then
    return true
  end
  return false
end
function on_keydown_searchname(ctrl, key, keyflag)
  if keyflag.down == false then
    return
  end
  local search_friend = ctrl.topper:search("search_friend")
  local id_list = search_friend:search("friend_list")
  if key == ui.VK_UP then
    if id_list.item_count ~= 0 then
      if id_list.item_sel == nil then
        id_list:item_get(0).selected = true
      else
        local index = id_list.item_sel.index - 1
        if index > 0 or index == 0 then
          id_list:item_get(index).selected = true
        end
      end
    end
  elseif key == ui.VK_DOWN and id_list.item_count ~= 0 then
    if id_list.item_sel == nil then
      id_list:item_get(0).selected = true
    else
      local index = id_list.item_sel.index + 1
      if index < id_list.item_count then
        id_list:item_get(index).selected = true
      end
    end
  end
end
function on_char_searchname(ctrl, ch)
  local search_friend = ctrl.topper:search("search_friend")
  local id_list = search_friend:search("friend_list")
  local search_name = ctrl:search("lb_im_searchname").text
  if search_name == L("") then
    search_friend.visible = false
    return
  end
  if ch == ui.VK_RETURN then
    if id_list.item_sel ~= nil then
      item_on_click(id_list.item_sel)
    else
      local v = sys.variant()
      local v_name = sys.variant()
      v_name:set(L("name"), search_name)
      v:set(packet.key.ui_text_id, 71524)
      v:set(packet.key.ui_text_arg, v_name)
      ui_packet.recv_wrap(packet.eSTC_UI_ShowText, v)
    end
    return
  end
  id_list:item_clear()
  for k, v in pairs(friend_name_list) do
    if string.find(tostring(v.name), tostring(search_name)) ~= nil then
      local item = id_list:item_insert(id_list.item_count)
      item:load_style("$frame/im/im.xml", "findfrienditem")
      item:search("text").text = v.name
    end
  end
  if id_list.item_count ~= 0 then
    search_friend.visible = true
    id_list:item_get(0).selected = true
  else
    search_friend.visible = false
  end
end
function on_mouse_searchname(ctrl, msg)
  local lb_im_searchname = ctrl:search("lb_im_searchname")
  if msg == ui.mouse_lbutton_down and lb_im_searchname.text == ui.get_text("im|lb_find_default") then
    lb_im_searchname.text = nil
  end
end
function on_focus_searchname(ctrl, boo)
  if boo == false then
    ctrl.topper:search("search_friend").visible = false
    ctrl:search("lb_im_searchname").text = ui.get_text("im|lb_find_default")
  end
end
function on_search_friend_sel(item, sel)
  ui.log("item:%s, sel:%s", item, sel)
  item:search("select").visible = sel
end
function item_on_mouse(item, msg)
  if msg == ui.mouse_enter then
    item.parent.selected = true
  end
end
function item_on_click(btn)
  local friend_name = btn:search("text").text
  local search_friend = w_main:search("search_friend")
  search_friend.visible = false
  w_main:search("lb_im_searchname").text = ui.get_text("im|lb_find_default")
  create_friend_dialog(friend_name, 1)
end
function on_history_person_mouse(btn, msg, pos, wheel)
  local name = btn:search("label_name").text
  if msg == ui.mouse_inner then
    btn:search("bg_fold").visible = true
    show_im_tip(true, btn, name)
  end
  if msg == ui.mouse_outer then
    btn:search("bg_fold").visible = false
    show_im_tip(false, btn, name)
  end
  if msg == ui.mouse_lbutton_dbl then
    create_friend_dialog(name, 1)
  end
  if msg == ui.mouse_rbutton_down then
    local self_portrait_menu = {}
    generate_rb(name)
    self_portrait_menu = {
      items = im_rb_items,
      event = on_player_portrait_event,
      info = {name = name, real_name = name},
      dx = 110,
      dy = 50,
      offset = btn.abs_area.p1 + pos
    }
    if self_portrait_menu then
      ui_tool.show_menu(self_portrait_menu)
    end
  end
end
function on_history_group_mouse(btn, msg, pos, wheel)
  if msg == ui.mouse_inner then
    btn:search("bg_fold").visible = true
  end
  if msg == ui.mouse_outer then
    btn:search("bg_fold").visible = false
  end
  if msg == ui.mouse_lbutton_dbl then
    create_group_dialog(btn:search("label_name").text, btn.parent.svar.id)
  end
  if msg == ui.mouse_rbutton_down then
    local id = chatgroup_list[btn.parent.svar.id].id
    local items
    if id == nil then
      return
    end
    if chatgroup_list[id].team == true then
      return
    end
    if chatgroup_list[id].org == true then
      return
    end
    if bo2.player.name == chatgroup_list[id].leader then
      items = im_rb_cg1
    else
      items = im_rb_cg2
    end
    local self_portrait_menu = {}
    self_portrait_menu = {
      items = items,
      event = on_player_portrait_event,
      info = {
        id = id,
        name = btn:search("label_name").text
      },
      dx = 100,
      dy = 50,
      offset = btn.abs_area.p1 + pos
    }
    if self_portrait_menu then
      ui_tool.show_menu(self_portrait_menu)
    end
  end
end
function update_history(name)
  if history_list[name] == nil then
    local style_uri = L("$gui/frame/im/im.xml")
    local style_name, tar_item
    local bIsPerson = false
    if friend_item_list[name] ~= nil then
      style_name = L("history_person")
      for k, v in pairs(friend_item_list[name].item) do
        tar_item = v.item
        break
      end
      bIsPerson = true
    elseif chatgroup_list[name] ~= nil and chatgroup_list[name].team ~= true and chatgroup_list[name].org ~= true then
      style_name = L("history_group")
      tar_item = chatgroup_list[name].item
    else
      return
    end
    local item = w_history_top:item_insert(0)
    item:load_style(style_uri, style_name)
    item:search("label_name").text = tar_item:search("label_name").text
    if bIsPerson then
      item:search("rel_icon").image = tar_item:search("rel_icon").image
      item:search("rel_icon").effect = tar_item:search("rel_icon").effect
      item:search("label_name").color = tar_item:search("label_name").color
      set_samll_icon(item, tar_item)
    else
      item.svar.id = name
    end
    item.svar.key = name
    history_list[name] = item
    local total_count = w_history_top.item_count
    if total_count > 20 then
      local item = w_history_top:item_get(total_count - 1)
      history_list[item.svar.key] = nil
      w_history_top:item_remove(total_count - 1)
    end
  else
    history_list[name].index = 0
  end
end
function is_friend(target_name)
  if friend_name_list[target_name] == nil then
    return false
  end
  if friend_name_list[target_name].thetype == bo2.TWR_Type_Friend or friend_name_list[target_name].thetype == bo2.TWR_Type_Engagement or friend_name_list[target_name].thetype == bo2.TWR_Type_Couple or friend_name_list[target_name].thetype == bo2.TWR_Type_Sworn then
    return true
  end
  return false
end
function on_change_touxiang(btn)
  w_chg_portrait.visible = not w_chg_portrait.visible
end
function on_chgpor_btn_mouse(btn, msg)
  if msg == ui.mouse_inner then
    btn.visible = true
  end
end
function on_player_portrait_chg(obj)
  local portrait = bo2.gv_portrait:find(bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Portrait))
  if portrait ~= nil then
    w_touxiang.image = g_portrait_path .. portrait.icon .. ".png"
  end
end
function on_player_errantry_chg(obj)
  ui.log("errantry value changed!")
  local knight_value = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Errantry)
  if knight_value > 100000 then
    w_main_knight_val.mouse_able = true
    w_main_knight_val.tip.text = sys.format("%s: %d", ui.get_text("im|knight_value"), knight_value)
    knight_value = math.floor(knight_value / 1000)
    w_main_knight_val.text = sys.format("%s: %dK", ui.get_text("im|knight_value"), knight_value)
  else
    w_main_knight_val.mouse_able = false
    w_main_knight_val.text = sys.format("%s: %d", ui.get_text("im|knight_value"), knight_value)
  end
end
local sig_name = "ui_im:on_scnmsg_enter_scn"
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enter_scn, init_player, sig_name)
