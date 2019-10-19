local dlg_upper_offset = 0
local OFFSETY_PER = 0.5
local DISPLAY_HEIGHT = 177
local img_roll
local bIsInit = false
local dialog_x = 0
local dialog_y = 0
local dialog_dx = 0
local dialog_dy = 0
local visible_dialog_stack = {}
local friend_select
local senior_quest_index = 1
local function push_dlg_to_stack(dlg)
  for i, v in ipairs(visible_dialog_stack) do
    if dlg == v then
      table.remove(visible_dialog_stack, i)
      break
    end
  end
  table.insert(visible_dialog_stack, dlg)
end
local function pop_dlg_from_stack(dlg)
  for i, v in ipairs(visible_dialog_stack) do
    if dlg == v then
      table.remove(visible_dialog_stack, i)
      break
    end
  end
  local cnt = #visible_dialog_stack
  if cnt ~= 0 then
    visible_dialog_stack[cnt]:move_to_head()
    dialog_x = visible_dialog_stack[cnt].x
    dialog_y = visible_dialog_stack[cnt].y
  end
end
function dialog_moudle_init()
  visible_dialog_stack = {}
end
function find_friend_dialog(name, item, min, is_senior)
  local dialog_list
  if is_senior then
    dialog_list = senior_dialog_list
  else
    dialog_list = friend_dialog_list
  end
  for i, v in ipairs(dialog_list) do
    if name ~= nil then
      if v.name == name then
        return i
      end
    elseif item ~= nil then
      if v.item == item then
        return i
      end
    elseif min ~= nil and v.min_item == min then
      return i
    end
  end
  return nil
end
function find_focus_dialog()
  for i, v in ipairs(friend_dialog_list) do
    if v.item:search("input").focus == true then
      return i
    end
  end
  return nil
end
function im_insert_mtf(index, stk, rank)
end
function get_mix_name(name)
  if chatgroup_list[name] == nil then
    return
  end
  return chatgroup_list[name].id .. "%g"
end
function create_group_dialog(name, id)
  if id == nil then
    return
  end
  if chatgroup_list[id] == nil then
    return
  end
  if find_friend_dialog(id) ~= nil then
    local dlg = friend_dialog_list[find_friend_dialog(id)].item
    dlg.visible = true
    return friend_dialog_list[find_friend_dialog(id)].item
  end
  local item = ui.create_control(ui.find_control("$phase:main"), "panel")
  item:load_style("$frame/im/dialog.xml", "group_dialog")
  item.name = "group_dialog1"
  if chatgroup_list[id].team then
    item:search("lb_title").text = ui.get_text("im|team_group")
    item:search("notice").visible = false
  else
    item:search("lb_title").text = get_merge("im|chat_in_group", name) .. "  " .. ui.get_text("im|group_master") .. chatgroup_list[id].leader
  end
  if chatgroup_list[id].org then
    local notice_title = item:search("notice_title")
    if notice_title ~= nil then
      notice_title:search("title").text = ui.get_text("im|org_notices")
    end
  end
  item:search("notice"):search("notices"):insert_mtf(chatgroup_list[id].notices, ui.mtf_rank_system)
  if chatgroup_list[id].leader == bo2.player.name and chatgroup_list[id].team ~= true and chatgroup_list[id].org ~= true then
    item:search("notice"):search("notices_steup").visible = true
  else
    item:search("notice"):search("notices_steup").visible = false
  end
  local drag = item:search("drag_mover"):find_plugin("drag")
  drag.target = item
  local scale1 = item:search("scale_zoomer1"):find_plugin("zoomer1")
  scale1.target = item
  scale1.lower = ui.point(550, 380)
  local scale2 = item:search("scale_zoomer2"):find_plugin("zoomer2")
  scale2.target = item
  scale2.lower = ui.point(550, 380)
  local scale3 = item:search("scale_zoomer3"):find_plugin("zoomer3")
  scale3.target = item
  scale3.lower = ui.point(550, 380)
  local scale4 = item:search("scale_zoomer4"):find_plugin("zoomer4")
  scale4.target = item
  scale4.lower = ui.point(550, 380)
  item.svar.is_senior = false
  local min_item = create_min_dialog(name)
  min_item.svar.is_senior = false
  table.insert(friend_dialog_list, {
    name = id,
    item = item,
    flag = true,
    min_item = min_item,
    group = true,
    team = chatgroup_list[id].team,
    org = chatgroup_list[id].org,
    record = {}
  })
  on_group_dialog_visible(item)
  update_group_members()
  on_im_dialog_visible(item)
  ui_widget.on_esc_stk_visible(item, true)
  show_chat(item)
  ui_qbar.ui_hide_anim.bind(item, min_item)
  return item
end
function create_min_dialog(name, id)
  local item = ui.create_control(w_min_im, "button")
  item:load_style("$frame/im/btns.xml", "im_min_btn")
  item:search("btn_label").text = sys.format(name)
  item.visible = true
  item.tip.text = name
  w_min_panel.visible = true
  local mini_num = w_min_im.control_size - 1
  local pos = mini_num * 64
  local offset_dx = -w_min_im.x + w_min_panel.dx - 46
  if pos > offset_dx then
    w_min_im.offset = ui.point(-pos, 0)
  end
  return item
end
function create_friend_dialog(name, id)
  if name == bo2.player.name then
    return
  end
  local dialog_id, dialog_list
  local is_senior = false
  if id then
    dialog_id = id
  else
    dialog_id = 0
  end
  if dialog_id == -1 then
    dialog_list = senior_dialog_list
    is_senior = true
  else
    dialog_list = friend_dialog_list
    is_senior = false
  end
  if find_friend_dialog(name, nil, nil, is_senior) ~= nil then
    local dlg_parent = dialog_list[find_friend_dialog(name, nil, nil, is_senior)]
    local dlg = dlg_parent.item
    dlg.visible = true
    return dlg
  end
  local item = ui.create_control(ui.find_control("$phase:main"), "panel")
  item:load_style("$frame/im/dialog.xml", "friend_dialog")
  if dialog_id == -1 then
    item.svar.is_senior = true
  else
    item.svar.is_senior = false
  end
  item.name = name
  if friend_name_list[name] then
    local relation_type = ui.get_text("im|re_" .. friend_name_list[name].thetype)
    item:search("lb_title").text = get_merge("im|chat_in_relation", name, "relation", relation_type)
  else
    item:search("lb_title").text = get_merge("im|chat_in_someone", name)
  end
  local drag = item:search("drag_mover"):find_plugin("drag")
  drag.target = item
  local scale1 = item:search("scale_zoomer1"):find_plugin("zoomer1")
  scale1.target = item
  scale1.lower = ui.point(450, 380)
  local scale2 = item:search("scale_zoomer2"):find_plugin("zoomer2")
  scale2.target = item
  scale2.lower = ui.point(450, 380)
  local scale3 = item:search("scale_zoomer3"):find_plugin("zoomer3")
  scale3.target = item
  scale3.lower = ui.point(450, 380)
  local scale4 = item:search("scale_zoomer4"):find_plugin("zoomer4")
  scale4.target = item
  scale4.lower = ui.point(450, 380)
  local min_item = create_min_dialog(name)
  table.insert(dialog_list, {
    name = name,
    item = item,
    flag = true,
    min_item = min_item,
    group = false,
    record = {}
  })
  if dialog_id == -1 and senior_records_list[name] ~= nil then
    senior_records_list[name].input_data.index = 0
    senior_quest_index = 1
  end
  on_im_dialog_visible(item)
  ui_widget.on_esc_stk_visible(item, true)
  show_chat(item)
  ui_qbar.ui_hide_anim.bind(item, min_item)
  if dialog_id == -1 then
    item:search("input").limit = 0
    item:search("btn_chat_record").enable = false
    item:search("btn_chat_send").enable = false
    item:search("btn_chat_expression").enable = false
    item:search("btn_chat_font").enable = false
    item:search("btn_chat_clear").enable = false
    min_item.svar.is_senior = true
  else
    min_item.svar.is_senior = false
  end
  return item
end
function on_set_font_size(btn)
  ui_widget.ui_popup.show(btn.topper:search("font_size"), btn, "y1x1", btn)
end
function on_reset_font_size(btn)
  btn.topper.visible = false
  local size = btn.svar.size
  dialog_font_size = size
  ui_im.im_save_font_size()
  for k, v in pairs(friend_dialog_list) do
    local rich = v.item:search("input")
    local mtf = rich.mtf
    rich:post_release()
    local box = ui.create_control(v.item:search("dlg_input"), "rich_box")
    box:load_style("$frame/im/dialog.xml", "dlg_input_size_" .. size)
    box.mtf = mtf
    v.item:search("dlg_input"):apply_dock(true)
    box:move_to_head()
    if records_list[v.name] then
      records_list[v.name].input_data.index = records_list[v.name].input_data.index - v.item:search("display_box").item_count
    end
    v.item:search("display_box"):item_clear()
    show_chat(v.item)
  end
end
function on_font_set_init(panel)
  local list_view = panel:search("lv_item")
  local item = list_view:item_append()
  item:load_style("$frame/im/dialog.xml", "font_item_style")
  item:search("btn_text").text = ui.get_text("im|font_big")
  item:search("btn_item").svar.size = 18
  item = list_view:item_append()
  item:load_style("$frame/im/dialog.xml", "font_item_style")
  item:search("btn_text").text = ui.get_text("im|font_middle")
  item:search("btn_item").svar.size = 16
  item = list_view:item_append()
  item:load_style("$frame/im/dialog.xml", "font_item_style")
  item:search("btn_text").text = ui.get_text("im|font_small")
  item:search("btn_item").svar.size = 14
end
function update_dlg_scn_view(item, name)
  local name_list
  if item.svar.is_senior then
    name_list = senior_name_list
  else
    name_list = friend_name_list
  end
  local w = item:search("cha_display_me")
  if w == nil then
    return
  end
  local scn = w:search("scn_view").scn
  scn:clear_obj(-1)
  fake_player = ui_personal.ui_equip.fake_player
  local excel_id = bo2.player:get_atb(bo2.eAtb_ExcelID)
  local p = scn:create_obj(bo2.eScnObjKind_Player, excel_id)
  if p == nil then
    return
  end
  p.view_target = bo2.player
  scn:modify_camera_view_type(p, bo2.eCameraFace)
  scn:change_radius(-20)
  local w = item:search("cha_display_to")
  if w == nil then
    return
  end
  local scn = w:search("scn_view").scn
  scn:clear_obj(-1)
  if name_list[name] then
    local group_id = name_list[name].groupid
    if group_id == -1 then
      local outlook_id = name_list[name].atb[bo2.eAtb_ExcelID]
      p = scn:create_obj(bo2.eScnObjKind_Npc, outlook_id)
      scn:modify_camera_view_type(p, bo2.eCameraFace)
    else
      excel_id = name_list[name].atb[bo2.eAtb_ExcelID]
      p = scn:create_obj(bo2.eScnObjKind_Player, excel_id)
      if p == nil then
        return
      end
      scn:modify_camera_view_type(p, bo2.eCameraFace)
      for k, v in pairs(name_list[name].equip) do
        p:set_view_equip(k, v)
      end
    end
  end
  scn:change_radius(-20)
end
function release_dlg(index, is_senior)
  local dialog_list
  if is_senior then
    dialog_list = senior_dialog_list
  else
    dialog_list = friend_dialog_list
  end
  if dialog_list[index] then
    pop_dlg_from_stack(dialog_list[index].item)
    dialog_list[index].item:post_release()
    dialog_list[index].min_item:post_release()
    table.remove(dialog_list, index)
  end
  w_min_im:insert_post_invoke(update_min_panel)
end
function on_dialog_shutdown(btn)
  if btn.topper then
    release_dlg(find_friend_dialog(nil, btn.topper, nil, btn.topper.svar.is_senior), btn.topper.svar.is_senior)
  end
end
function update_min_panel()
  local min_count = w_min_im.control_size
  if min_count == 0 then
    w_min_panel.visible = false
    w_min_im.offset = ui.point(0, 0)
  else
    local offset_x = -min_count * 64
    if offset_x >= w_min_im.x then
      local x = w_min_im.offset.x + 64
      w_min_im.offset = ui.point(x, 0)
    end
  end
  update_min_flash()
end
function on_dialog_min(btn)
  if btn.topper then
    local dialog_list
    if btn.topper.svar.is_senior then
      dialog_list = senior_dialog_list
    else
      dialog_list = friend_dialog_list
    end
    local index = find_friend_dialog(nil, btn.topper, nil, btn.topper.svar.is_senior)
    if index ~= nil then
      local dlg = dialog_list[index]
      dlg.min_item.visible = true
      w_min_panel.visible = true
      dlg.item.visible = false
    end
  end
end
function on_min_visible(btn)
  local index = find_friend_dialog(nil, nil, btn, btn.svar.is_senior)
  local dialog_list
  if btn.svar.is_senior then
    dialog_list = senior_dialog_list
  else
    dialog_list = friend_dialog_list
  end
  if index ~= nil then
    btn.visible = true
    if dialog_list[index].item.visible then
      if dialog_list[index].item:search("input").focus == true then
        dialog_list[index].item.visible = false
      else
        dialog_list[index].item:move_to_head()
      end
    else
      dialog_list[index].item.visible = true
    end
    dialog_list[index].msg = false
    dialog_list[index].min_item.svar.has_msg = false
    btn:search("flash").visible = false
  end
end
function on_dlg_focus(dlg)
  if dlg.topper then
    local index = find_friend_dialog(nil, dlg.topper)
    if index then
      friend_dialog_list[index].min_item:search("flash").visible = false
      for i, v in ipairs(friend_dialog_list) do
        v.min_item.press = false
      end
      friend_dialog_list[index].min_item.press = true
    end
  end
end
function update_min_flash()
  w_min_left_btn:search("flash").visible = false
  w_min_right_btn:search("flash").visible = false
  local min_count = w_min_im.control_size
  for i = 0, min_count - 1 do
    local ctr = w_min_im:control_get(i)
    if ctr ~= nil and ctr.svar.has_msg == true then
      local offset_x = ctr.x + w_min_im.x
      local mini_im_dx = w_min_panel.dx - 46
      ctr:search("flash").visible = true
      if offset_x < 0 then
        w_min_left_btn:search("flash").visible = true
      elseif offset_x > mini_im_dx then
        w_min_right_btn:search("flash").visible = true
      end
    end
  end
end
function on_min_left(btn)
  if w_min_im.x == 0 then
    return
  end
  local x = w_min_im.offset.x + 64
  w_min_im.offset = ui.point(x, 0)
  btn:insert_post_invoke(update_min_flash)
end
function on_min_right(btn)
  local min_count = w_min_im.control_size - 1
  local offset_x = -min_count * 64
  if offset_x >= w_min_im.x then
    return
  end
  local x = w_min_im.offset.x - 64
  local num = w_min_im.control_size
  w_min_im.offset = ui.point(x, 0)
  btn:insert_post_invoke(update_min_flash)
end
function send_chat(btn)
  local box = btn.topper:search("input")
  local text = box.mtf
  box.mtf = nil
  local index = find_friend_dialog(nil, box.topper)
  if index == nil then
    return
  end
  if friend_dialog_list[index].group == false then
    local target_name = friend_dialog_list[index].name
    if text == L("") then
      return
    end
    local v = sys.variant()
    v:set(packet.key.chat_channel_id, bo2.eChatChannel_PersonalIm)
    v:set(packet.key.chat_text, text)
    v:set(packet.key.target_name, target_name)
    bo2.send_variant(packet.eCTS_UI_Chat, v)
  else
    local groupid = friend_dialog_list[index].name
    if text == L("") then
      return
    end
    if friend_dialog_list[index].team then
      local v = sys.variant()
      v:set(packet.key.chat_channel_id, bo2.eChatChannel_Group)
      v:set(packet.key.chat_text, text)
      v:set(packet.key.group_id, groupid)
      bo2.send_variant(packet.eCTS_UI_Chat, v)
      return
    end
    if friend_dialog_list[index].org then
      local v = sys.variant()
      v:set(packet.key.chat_channel_id, bo2.eChatChannel_Guild)
      v:set(packet.key.chat_text, text)
      bo2.send_variant(packet.eCTS_UI_Chat, v)
      return
    end
    local v = sys.variant()
    v:set(packet.key.chat_channel_id, bo2.eChatChannel_ChatGroup)
    v:set(packet.key.chat_text, text)
    v:set(packet.key.chat_group_id, groupid)
    bo2.send_variant(packet.eCTS_UI_Chat, v)
  end
end
function on_group_item_person_mouse(btn, msg, pos, wheel)
  if msg == ui.mouse_inner then
    btn.parent:search("bg_fold").visible = true
  end
  if msg == ui.mouse_outer and friend_select ~= btn.parent then
    btn.parent:search("bg_fold").visible = false
  end
  if msg == ui.mouse_lbutton_dbl then
    local item = create_friend_dialog(btn:search("label_name").text, id)
  end
  if msg == ui.mouse_rbutton_down then
    local self_portrait_menu = {}
    local groupid
    local index = find_friend_dialog(nil, btn.topper)
    if index == nil then
      return
    end
    groupid = friend_dialog_list[index].name
    local name = btn:search("label_name").text
    generate_rb(name, groupid)
    self_portrait_menu = {
      items = im_rb_items,
      event = on_player_portrait_event,
      info = {
        name = name,
        groupid = groupid,
        real_name = name
      },
      dx = 110,
      dy = 50,
      offset = btn.abs_area.p1 + pos
    }
    if self_portrait_menu then
      ui_tool.show_menu(self_portrait_menu)
    end
  end
end
function show_chat(item)
  local dialog_list
  if item.svar.is_senior then
    dialog_list = senior_dialog_list
  else
    dialog_list = friend_dialog_list
  end
  local index = find_friend_dialog(nil, item, nil, item.svar.is_senior)
  local item_list, name_list, temp_records_list
  if item.svar.is_senior then
    item_list = senior_item_list
    name_list = senior_name_list
    temp_records_list = senior_records_list
  else
    item_list = friend_item_list
    name_list = friend_name_list
    temp_records_list = records_list
  end
  if index ~= nil then
    local name = dialog_list[index].name
    if item_list[name] then
      for k, v in pairs(item_list[name].item) do
        if v.item:search("item_person").suspended == false then
          dec_friend_group_msg_num(v.group)
        end
        if item.svar.is_senior then
          on_im_end(v.item:search("item_person"), senior_name_list[name].id)
        else
          on_im_end(v.item:search("item_person"), name)
        end
      end
      if history_list[name] ~= nil then
        on_im_end(history_list[name]:search("item_person"))
      end
    elseif chatgroup_list[name] then
      if chatgroup_list[name].item:search("item_group").suspended == false then
        if chatgroup_list[name].leader == bo2.player.name then
          my_chat_msg_num = my_chat_msg_num - 1
          local group_flicker = my_chat_group:search("node_group").parent
          if my_chat_msg_num == 0 and group_flicker.suspended == false then
            group_flicker.suspended = true
          end
        else
          join_chat_msg_num = join_chat_msg_num - 1
          local group_flicker = join_chat_group:search("node_group").parent
          if join_chat_msg_num == 0 and group_flicker.suspended == false then
            group_flicker.suspended = true
          end
        end
      end
      on_im_end(chatgroup_list[name].item:search("item_group"), name)
      if history_list[name] ~= nil then
        on_im_end(history_list[name]:search("item_group"))
      end
    end
    local record = temp_records_list[name]
    if record == nil then
      return
    end
    local texts = record.input_data.texts
    if record.input_data.index == #texts then
      return
    end
    for i, v in ipairs(texts) do
      if i > record.input_data.index then
        local s_name = v.s_name
        local t_name = v.t_name
        local text = v.text
        local time = v.time
        local time_str = bo2.get_cpgtime(time)
        local box = dialog_list[index].item:search("page_list")
        local chat_excel = bo2.gv_chat_list:find(bo2.eChatChannel_PersonalIm)
        local color
        if chat_excel then
          color = chat_excel.color
        end
        local rank = ui.mtf_rank_system
        local stk = sys.format("<c:%.6X>%s", color, text)
        local data = {text = stk}
        local info = sys.format("<c:ffff00><imn:%s,%s>\n", s_name, time_str)
        if friend_name_list[s_name] then
          for m, n in pairs(friend_name_list[s_name].owtype) do
            if m == bo2.OWR_Type_Temp and friend_name_list[s_name].thetype == 0 then
              info = ui.get_text("im|nonofficial") .. info
              break
            end
          end
        end
        box = dialog_list[index].item:search("display_box")
        local child_item_uri = L("$frame/im/dialog.xml")
        local child_item_style = L("chatinfo_others_item")
        if s_name == bo2.player.name then
          child_item_style = L("chatinfo_myself_item")
        end
        local child_item = box:item_append()
        child_item:load_style(child_item_uri, child_item_style)
        if box.item_count > 50 then
          box:item_remove(0)
        end
        local text_richbox = child_item:search("rb_text")
        text_richbox:load_style("$frame/im/dialog.xml", "dlg_output_size_" .. dialog_font_size)
        local text_panel = child_item:search("panel_text")
        dialog_list[index].item:apply_dock(true)
        child_item.dx = box.dx - 85
        text_richbox.mtf = info .. data.text
        child_item:tune("rb_text")
        text_richbox.parent.dy = text_richbox.dy
        local portrait_image
        if s_name == bo2.player.name then
          text_panel.dock = SHARED("ext_x2y1")
          text_richbox.margin = ui.rect(7, 3, 15, 0)
          local portrait = bo2.gv_portrait:find(bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Portrait))
          if portrait ~= nil then
            portrait_image = g_portrait_path .. portrait.icon .. ".png"
          end
        else
          text_panel.dock = SHARED("ext_x1y1")
          text_richbox.margin = ui.rect(15, 3, 7, 0)
          if chatgroup_list[name] then
            local chatgroup = chatgroup_list[name]
            local chat_memeber = chatgroup.members[s_name]
            if chatgroup.org ~= true and chat_memeber then
              local portrait = bo2.gv_portrait:find(chat_memeber.portrait)
              if portrait ~= nil then
                portrait_image = g_portrait_path .. portrait.icon .. ".png"
              end
            end
          else
            local friend_item = name_list[s_name]
            if friend_item ~= nil then
              portrait_image = friend_get_portrait(friend_item)
              if item.svar.is_senior and insert_richbox_senior_quest(senior_quest_index, text_richbox) then
                senior_quest_index = senior_quest_index + 1
              end
            end
          end
        end
        if guild_group_portrait[s_name] and chatgroup_list[name] and chatgroup_list[name].org == true then
          local chat_memeber = chatgroup_list[name].members[s_name]
          local portrait = bo2.gv_portrait:find(guild_group_portrait[s_name])
          if portrait ~= nil then
            portrait_image = g_portrait_path .. portrait.icon .. ".png"
          end
          if chat_memeber ~= nil and chat_memeber.portrait ~= guild_group_portrait[s_name] then
            chat_memeber.portrait = guild_group_portrait[s_name]
            if portrait_image ~= nil then
              chat_memeber.item:search("rel_icon").image = portrait_image
            end
          end
        end
        if portrait_image ~= nil then
          child_item:search("touxiang").image = portrait_image
        end
        text_panel.dy = text_richbox.parent.dy + 7
        text_panel.dx = text_richbox.dx + 22
        child_item.dy = text_panel.dy + 6
        box.slider_y.scroll = 1
        table.insert(dialog_list[index].record, info)
        table.insert(dialog_list[index].record, data.text)
        if dialog_list == friend_dialog_list and dialog_list[index].item.focus == false and dialog_list[index].item:search("input").focus == false then
          dialog_list[index].min_item.visible = true
          dialog_list[index].msg = true
          dialog_list[index].min_item.svar.has_msg = true
          update_min_flash()
        end
      end
    end
    record.input_data.index = #texts
  end
end
local show_record_from_file = function(dlg_index)
  if ui_im.save_friend_msg == L("false") then
    return
  end
  local name = friend_dialog_list[dlg_index].name
  local root = ui_main.player_cfg_load("chat.rec")
  if root == nil then
    return
  end
  local contacter = root:find(name)
  if contacter == nil or contacter.size == 0 then
    return
  else
    local date_begin = contacter.size - 20
    if date_begin < 0 then
      date_begin = 0
    end
    for i = date_begin, contacter.size - 1 do
      local msg = contacter:get(i)
      local s_name = msg:get_attribute("talker")
      local text = msg:get_attribute("text")
      local time = msg:get_attribute("time")
      local time_str = bo2.get_cpgtime(time)
      local box = friend_dialog_list[dlg_index].item:search("record_page_list")
      local chat_excel = bo2.gv_chat_list:find(bo2.eChatChannel_PersonalIm)
      local color
      if chat_excel then
        color = chat_excel.color
      end
      local rank = ui.mtf_rank_system
      local stk = sys.format("<c:%.6X>%s\n", color, text)
      local data = {text = stk}
      local info = sys.format([[
<c:ffff00><imn:%s,%s>
	]], s_name, time_str)
      box = friend_dialog_list[dlg_index].item:search("display_record")
      box:insert_mtf(info, rank)
      box:insert_mtf(data.text, rank)
      set_box_no_sel(box)
    end
  end
end
function show_record(btn)
  local record_panel = btn.topper:search("record")
  local index = find_friend_dialog(nil, btn.topper)
  if index ~= nil then
    if record_panel.visible == false then
      bIsInit = true
      btn.topper.dy = btn.topper.dy + 170
      bIsInit = false
      btn.topper:search("main_panel").margin = ui.rect(0, 0, 0, 170)
      record_panel.visible = true
      record_panel:search("display_record"):item_clear()
      show_record_from_file(index)
      local name = friend_dialog_list[index].name
      local record = records_list[name]
      if record == nil then
        return
      end
      local texts = record.input_data.texts
      for i, v in ipairs(texts) do
        if i > record.input_data.record_index then
          local s_name = v.s_name
          local t_name = v.t_name
          local text = v.text
          local time = v.time
          local time_str = bo2.get_cpgtime(time)
          local box = friend_dialog_list[index].item:search("record_page_list")
          local chat_excel = bo2.gv_chat_list:find(bo2.eChatChannel_PersonalIm)
          local color
          if chat_excel then
            color = chat_excel.color
          end
          local rank = ui.mtf_rank_system
          local stk = sys.format("<c:%.6X>%s\n", color, text)
          local data = {text = stk}
          local info = sys.format([[
<c:ffff00><imn:%s,%s>
	]], s_name, time_str)
          box = friend_dialog_list[index].item:search("display_record")
          box:insert_mtf(info, rank)
          box:insert_mtf(data.text, rank)
          set_box_no_sel(box)
        end
      end
    else
      record_panel.visible = false
      btn.topper.dy = btn.topper.dy - 170
      btn.topper:search("main_panel").margin = ui.rect(0, 0, 0, 0)
    end
  end
end
function on_fold_pass(btn, msg)
  if msg == ui.mouse_lbutton_click then
    if friend_group_select then
      friend_group_select:search("bg_fold").visible = false
    end
    btn.parent:search("bg_fold").visible = true
    friend_group_select = btn.parent
    if friend_select then
      friend_select:search("bg_fold").visible = false
      friend_select = nil
    end
  end
  if msg == ui.mouse_inner then
    btn.parent:search("bg_fold").visible = true
  end
  if msg == ui.mouse_outer and friend_group_select ~= btn.parent then
    btn.parent:search("bg_fold").visible = false
  end
end
function insert_group_friend_group(w, text)
  local root = w.root
  local style_uri = L("$gui/frame/im/dialog.xml")
  local style_name_g = L("node_group")
  local style_name_k = L("item_friend")
  local item_g = root:item_append()
  item_g:load_style(style_uri, style_name_g)
  item_g:search("btn_up").text = text
  item_g:search("btn_left").text = text
  return item_g
end
function insert_group_friend_item(item, text)
  local child_item_uri = L("$frame/im/dialog.xml")
  local child_item_style = L("item_friend")
  local child_item = item:item_append()
  child_item:load_style(child_item_uri, child_item_style)
  child_item:search("label_name").text = text
  return child_item
end
function on_dialog_init(dialog)
  bIsInit = true
  if #visible_dialog_stack ~= 0 then
    if dialog_x + dialog_dx + 30 > ui_phase.ui_main.w_top.dx or dialog_y + dialog_dy + 30 > ui_phase.ui_main.w_top.dy then
      dialog.x = 30
      dialog.y = 30
    else
      dialog.x = dialog_x + 30
      dialog.y = dialog_y + 30
    end
  else
    dialog.x = ui_phase.ui_main.w_top.dx / 2 - dialog.dx / 2
    dialog.y = ui_phase.ui_main.w_top.dy / 2 - dialog.dy / 2
  end
  if dialog_dx == 0 and dialog_dy == 0 then
    dialog_dx = dialog.dx
    dialog_dy = dialog.dy
  else
    dialog.dx = dialog_dx
    dialog.dy = dialog_dy
  end
  dialog_x = dialog.x
  dialog_y = dialog.y
  bIsInit = false
end
local send_message = function(box)
  local text = box.mtf
  box.mtf = nil
  local index = find_friend_dialog(nil, box.topper)
  if index == nil then
    ui.log("find_friend_dialog nil")
    return
  end
  if friend_dialog_list[index].group == false then
    local target_name = friend_dialog_list[index].name
    if text == L("") then
      return
    end
    local v = sys.variant()
    v:set(packet.key.chat_channel_id, bo2.eChatChannel_PersonalIm)
    v:set(packet.key.chat_text, text)
    v:set(packet.key.target_name, target_name)
    bo2.send_variant(packet.eCTS_UI_Chat, v)
  else
    local groupid = friend_dialog_list[index].name
    if text == L("") then
      return
    end
    if friend_dialog_list[index].team then
      local v = sys.variant()
      v:set(packet.key.chat_channel_id, bo2.eChatChannel_Group)
      v:set(packet.key.chat_text, text)
      v:set(packet.key.group_id, groupid)
      bo2.send_variant(packet.eCTS_UI_Chat, v)
      return
    end
    if friend_dialog_list[index].org then
      local v = sys.variant()
      v:set(packet.key.chat_channel_id, bo2.eChatChannel_Guild)
      v:set(packet.key.chat_text, text)
      bo2.send_variant(packet.eCTS_UI_Chat, v)
      return
    end
    local v = sys.variant()
    v:set(packet.key.chat_channel_id, bo2.eChatChannel_ChatGroup)
    v:set(packet.key.chat_text, text)
    v:set(packet.key.chat_group_id, groupid)
    bo2.send_variant(packet.eCTS_UI_Chat, v)
  end
end
function on_input(box, key, flag)
  if key == ui.VK_ESCAPE and flag.down then
    ui_im.w_input_custom.visible = false
    release_dlg(find_friend_dialog(nil, box.topper, nil, box.topper.svar.is_senior), box.topper.svar.is_senior)
    return
  end
  if flag.down then
    return
  end
  if key == ui.VK_C and ui.is_key_down(ui.VK_MENU) or key == ui.VK_MENU and ui.is_key_down(ui.VK_C) then
    ui_im.w_input_custom.visible = false
    release_dlg(find_friend_dialog(nil, box.topper, nil, box.topper.svar.is_senior), box.topper.svar.is_senior)
    return
  end
  ui_chat.translate_face(box)
  if ui_im.send_type == 1 then
    if key == ui.VK_RETURN and ui.is_key_down(ui.VK_CONTROL) or key == ui.VK_CONTROL and ui.is_key_down(ui.VK_RETURN) then
      send_message(box)
    end
  elseif ui_im.send_type == 2 then
    if key == ui.VK_RETURN and ui.is_key_down(ui.VK_CONTROL) then
      box:insert_mtf(L("\r"))
    end
  elseif key == ui.VK_S and ui.is_key_down(ui.VK_MENU) or key == ui.VK_MENU and ui.is_key_down(ui.VK_S) then
    send_message(box)
  end
end
function on_inputbox_enter(box)
  if ui_im.send_type == 2 then
    local text = box.mtf
    box.mtf = text:substr(0, text.size - 1)
    send_message(box)
  end
end
function insert_chat(name, t_name, text, time, groupid)
  local dialog_list
  local is_senior = false
  if groupid and groupid == -1 then
    dialog_list = senior_dialog_list
    is_senior = true
  else
    dialog_list = friend_dialog_list
    is_senior = false
  end
  if groupid then
    input_data_add(groupid, name, nil, text, time)
  elseif name == bo2.player.name then
    input_data_add(t_name, name, t_name, text, time)
  elseif t_name == bo2.player.name then
    input_data_add(name, name, t_name, text, time)
    if find_friend_dialog(name, nil, nil, is_senior) == nil then
      flash_items()
    end
    ui_tool.ui_tray.glint_insert("im")
  end
  bo2.PlaySound2D(529)
  if groupid then
    if find_friend_dialog(groupid, nil, nil, is_senior) then
      show_chat(dialog_list[find_friend_dialog(groupid, nil, nil, is_senior)].item)
    end
    if find_friend_dialog(groupid, nil, nil, is_senior) == nil then
      flash_items()
    end
    return
  end
  if find_friend_dialog(name, nil, nil, is_senior) then
    show_chat(dialog_list[find_friend_dialog(name, nil, nil, is_senior)].item)
  elseif find_friend_dialog(t_name, nil, nil, is_senior) then
    show_chat(dialog_list[find_friend_dialog(t_name, nil, nil, is_senior)].item)
  end
end
function insert_msg(c, msg, name, color)
  local index
  if c then
    index = find_friend_dialog(nil, c)
  else
    index = find_friend_dialog(name)
  end
  if index ~= nil then
    box = friend_dialog_list[index].item:search("display_box")
    local chat_excel = bo2.gv_chat_list:find(bo2.eChatChannel_PersonalIm)
    local color = color
    if color == nil and chat_excel then
      color = chat_excel.color
    end
    local rank = ui.mtf_rank_system
    local stk = sys.format("<c:%.6X>%s\n", color, msg)
    local data = {text = stk}
    local child_item_uri = L("$frame/im/dialog.xml")
    local child_item_style = L("chatinfo_others_item")
    local child_item = box:item_append()
    child_item:load_style(child_item_uri, child_item_style)
    local text_richbox = child_item:search("rb_text")
    text_richbox:load_style("$frame/im/dialog.xml", "dlg_output_size_" .. dialog_font_size)
    local text_panel = child_item:search("panel_text")
    child_item:search("touxiang").visible = false
    friend_dialog_list[index].item:apply_dock(true)
    child_item.dx = box.dx - 85
    text_richbox.mtf = data.text
    child_item:tune("rb_text")
    text_richbox.margin = ui.rect(15, 3, 7, 0)
    text_panel.dy = text_richbox.dy + 7
    text_panel.dx = text_richbox.dx + 22
    child_item.dy = text_panel.dy + 6
    box.slider_y.scroll = 1
    table.insert(friend_dialog_list[index].record, data.text)
  end
end
function on_group_dialog_init(dialog)
  bIsInit = true
  dialog.x = ui_phase.ui_main.w_top.dx / 2 - dialog.dx / 2
  dialog.y = ui_phase.ui_main.w_top.dy / 2 - dialog.dy / 2
  bIsInit = false
end
function on_group_dialog_visible(dialog)
  local index = find_friend_dialog(nil, dialog)
  if index then
    local name = friend_dialog_list[index].name
    if chatgroup_list[name] and chatgroup_list[name].leader == bo2.player.name then
      dialog:search("btn_invite").visible = true
    end
  end
end
function on_disable_key(box, key, flag)
  if flag.down then
    if key == ui.VK_CONTROL then
      return
    end
    if ui.is_key_down(ui.VK_CONTROL) and ui.is_key_down(ui.VK_C) then
      return
    end
  else
  end
end
function set_box_no_sel(box)
  box:sel_set(box.item_count, box.item_count)
end
function on_disable_focus(box, b)
  if b == false then
    box:sel_set(box.item_count, box.item_count)
  end
end
function on_clear(btn)
  ui_widget.ui_msg_box.show_common({
    text = ui.get_text("im|clear_confirm"),
    callback = function(ret)
      if ret.result == 1 then
        local item = btn.topper
        local box = item:search("display_box")
        box:item_clear()
      end
    end
  })
end
function on_im_cg_invite(btn)
  w_chatgroup.visible = true
end
function on_im_cg_quit(btn)
  local dialog_list
  if btn.topper.svar.is_senior then
    dialog_list = senior_dialog_list
  else
    dialog_list = friend_dialog_list
  end
  local index = find_friend_dialog(nil, btn.topper, nil, btn.topper.svar.is_senior)
  if index then
    local id = dialog_list[index].name
    del_member(id, bo2.player.name)
  end
end
function on_senior_dlg_effect_timer(timer)
  if img_roll == nil then
    return
  end
  local display_dlg = img_roll.topper
  local display_box = display_dlg:search("display_box")
  dlg_upper_offset = dlg_upper_offset + OFFSETY_PER
  local size = display_box.size
  if dlg_upper_offset < DISPLAY_HEIGHT then
    img_roll.dy = display_box.dy - display_box.dy / DISPLAY_HEIGHT * dlg_upper_offset
  else
    timer.suspended = true
    img_roll.visible = false
    img_roll.dy = img_roll.dy - dlg_upper_offset
    dlg_upper_offset = 0
  end
end
function on_im_dialog_visible(dlg)
  if dlg.visible == false then
    pop_dlg_from_stack(dlg)
    return
  end
  dlg:move_to_head()
  local index = find_friend_dialog(nil, dlg)
  ui.log("index %s", index)
  if index then
    ui.log("%s", friend_dialog_list[index])
    friend_dialog_list[index].msg = false
    friend_dialog_list[index].min_item.svar.has_msg = false
    update_min_flash()
    local name = friend_dialog_list[index].name
    if friend_name_list[name] then
      local relation_type = ui.get_text("im|re_" .. friend_name_list[name].thetype)
      dlg:search("lb_title").text = get_merge("im|chat_in_relation", name, "relation", relation_type)
    end
  end
end
function on_change_custom(btn)
  ui_widget.ui_popup.show(ui_im.w_input_custom, btn, "y2x1", btn)
end
function on_input_custom_visible(panel)
  if panel.visible == true then
    ui_im.w_input_custom:search("send_type" .. send_type).check = true
  else
    if ui_im.w_input_custom:search("send_type" .. send_type).check == true then
      return
    end
    if ui_im.w_input_custom:search("send_type1").check then
      send_type = 1
    elseif ui_im.w_input_custom:search("send_type2").check then
      send_type = 2
    else
      send_type = 3
    end
    ui_im.im_save_sendtype()
  end
end
function on_dialog_move(v)
  if bIsInit then
    return
  end
  if dialog_x ~= v.x then
    dialog_x = v.x
  end
  if dialog_y ~= v.y then
    dialog_y = v.y
  end
  if dialog_dx ~= v.dx then
    local index = find_friend_dialog(nil, v)
    if index ~= nil then
      local name = friend_dialog_list[index].name
      local record = records_list[name]
      if record then
        record.input_data.index = record.input_data.index - v:search("display_box").item_count
        v:search("display_box"):item_clear()
        show_chat(friend_dialog_list[index].item)
      end
    end
    dialog_dx = v.dx
  end
  if dialog_dy ~= v.dy then
    dialog_dy = v.dy
  end
end
function on_min_panel_move(ctr, rec)
  update_min_flash()
end
function on_im_dialog_head(dlg)
  for i, v in ipairs(friend_dialog_list) do
    v.min_item.press = false
    v.item:search("lb_title").color = ui.make_color("d2b48c")
  end
  for i, v in ipairs(senior_dialog_list) do
    v.min_item.press = false
    v.item:search("lb_title").color = ui.make_color("d2b48c")
  end
  dlg:search("input").focus = true
  dlg:search("lb_title").color = ui.make_color("ffffff")
  local is_senior = dlg.svar.is_senior
  local index = find_friend_dialog(nil, dlg, nil, is_senior)
  if index then
    local dialog_list
    if is_senior then
      dialog_list = senior_dialog_list
    else
      dialog_list = friend_dialog_list
    end
    dialog_list[index].min_item:search("flash").visible = false
    dialog_list[index].min_item.press = true
  end
  push_dlg_to_stack(dlg)
  update_min_flash()
end
