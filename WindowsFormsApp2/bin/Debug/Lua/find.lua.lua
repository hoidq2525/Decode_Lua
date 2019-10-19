local find_data
function on_btn_drop_down_click(btn)
  local cb = btn.parent
  local items = {}
  local svar = cb.svar
  local t = svar.list
  for i, v in ipairs(t) do
    local item = {
      id = v.id,
      text = v.text,
      style_uri = L("$frame/im/btns.xml"),
      style = L("im_xiala_btn"),
      data = v
    }
    table.insert(items, item)
  end
  local function on_event_list_select(item)
    select(cb, item.id)
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
    dx = cb.dx,
    bg_uri = L("$frame/im/find.xml"),
    bg_style = L("im_menu_window")
  })
end
function on_cha_item_sel(list)
end
function on_find_make_friend(btn)
  local name = btn.parent:search("name"):search("text").text
  if name then
    c_add_friend(name)
  end
end
function on_find_group_invite(btn)
  local name = btn.parent:search("name"):search("text").text
  if name then
    ui_group.send_invite_cha(name)
  end
end
function on_find_mouse(box, msg, pt)
  if msg == ui.mouse_rbutton_down then
    local name = box:search("name"):search("text").text
    local items
    ui.log("name %s", name)
    ui_im.generate_rb(name)
    items = ui_im.im_rb_items
    local datas = {
      items = items,
      info = {name = name, real_name = name},
      popup = "y_auto",
      dx = 120,
      dy = 50,
      offset = box:control_to_window(pt)
    }
    ui_tool.show_cha_menu(datas)
  end
  if msg == ui.mouse_inner then
    box:search("bg_fold").visible = true
  end
  if msg == ui.mouse_outer then
    box:search("bg_fold").visible = false
  end
end
function insert_find(view, name, level, careerId, sex, camp, flag)
  local item = view:item_append()
  item:load_style("$frame/im/find.xml", "row_lables")
  if flag == false then
    item:search("button1").visible = false
    item:search("button2").visible = false
    return
  end
  item:search("name"):search("text").text = name
  if sex == 1 then
    item:search("sex"):search("sex_pic").image = "$image/im/btn_misc.png|66,2,27,31"
  else
    item:search("sex"):search("sex_pic").image = "$image/im/btn_misc.png|93,2,27,31"
    sex = 2
  end
  local tip = item:search("sex"):search("sex_pic").tip
  if tip ~= nil then
    tip.text = ui.get_text("im|sex_" .. sex)
  end
  item:search("level"):search("text").text = level
  item:search("camp"):search("text").text = camp
  local excel = bo2.gv_profession_list:find(careerId)
  if excel ~= nil then
    local career_pic = item:search("career_pic"):search("career_icon")
    ui_im.SetCareerIcon(career_pic, excel)
  end
  item.mouse_able = true
  item:insert_on_mouse(on_find_mouse, "ui_im.ui_find.on_find_mouse")
  if ui_group.may_invite(name) == false then
    item:search("button2").enable = false
  end
end
function on_find_confirm()
  local v = sys.variant()
  local name = w_find_name.text
  local level_min = w_find_level_min:search("text").text
  local level_max = w_find_level_max:search("text").text
  local career = ui_widget.ui_combo_box.selected(w_combo_career).id
  local career2 = ui_widget.ui_combo_box.selected(w_combo_career2).id
  local sex = ui_widget.ui_combo_box.selected(w_combo_sex).id
  local camp = ui_widget.ui_combo_box.selected(w_combo_camp).id
  if name ~= "" and name ~= ui.get_text("im|lb_find_default") then
    v:set(packet.key.sociality_playername, name)
  end
  if level_min ~= nil then
    v:set(packet.key.sociality_playerlevel_min, level_min)
  end
  if level_max ~= nil then
    v:set(packet.key.sociality_playerlevel_max, level_max)
  end
  if career2 ~= 0 then
    v:set(packet.key.sociality_playercareer, career2)
  elseif career ~= 0 then
    v:set(packet.key.sociality_playercareer, career)
  end
  if sex ~= 0 then
    v:set(packet.key.sociality_playersex, sex)
  end
  if camp ~= 0 then
    v:set(packet.key.sociality_playercamp, camp)
  end
  bo2.send_variant(packet.eCTS_Sociality_SearchPlayer, v)
end
function find_confirm(btn)
  ui.log("find_confirm")
  ui_handson_teach.test_complate_im_find(false)
  btn:insert_post_invoke(on_find_confirm, "ui_im.im_find_confirm")
end
function clear_find_res()
  w_find_res:item_clear()
end
function insert_find_res(data, bIsNewData)
  if bIsNewData then
    find_data = data
  end
  for i = 0, data.size - 1 do
    local v = data:get(i)
    local name = v:get(packet.key.sociality_playername).v_string
    local level = v:get(packet.key.sociality_playerlevel).v_int
    local careerId = v:get(packet.key.sociality_playercareer).v_int
    local sex = v:get(packet.key.sociality_playersex).v_int
    local camp = v:get(packet.key.sociality_playercamp).v_int
    if camp == bo2.eCamp_Blade then
      camp = ui.get_text("phase|camp_blade")
    elseif camp == bo2.eCamp_Sword then
      camp = ui.get_text("phase|camp_sword")
    else
      camp = L("")
    end
    insert_find(w_find_res, name, level, careerId, sex, camp)
  end
end
function on_im_find_visible(dlg, vis)
  ui_handson_teach.test_complate_im_find(vis)
  if dlg.visible == false then
    return
  end
  ui_widget.ui_combo_box.select(w_combo_sex, 0)
  w_combo_sex:search("btn_drop_down").text = ui.get_text("im|find_choose_sex")
  ui_widget.ui_combo_box.select(w_combo_career, 0)
  w_combo_career:search("btn_drop_down").text = ui.get_text("im|find_choose_occupation")
  ui_widget.ui_combo_box.clear(w_combo_career2)
  ui_widget.ui_combo_box.append(w_combo_career2, {
    id = 0,
    text = ui.get_text("im|find_all_branch")
  })
  ui_widget.ui_combo_box.select(w_combo_career2, 0)
  w_combo_career2:search("btn_drop_down").text = ui.get_text("im|find_choose_branch")
  w_combo_career2:search("btn_drop_down").enable = false
  ui_widget.ui_combo_box.select(w_combo_camp, 0)
  w_combo_camp:search("btn_drop_down").text = ui.get_text("im|find_choose_camp")
  w_find_level_min:search("text").text = ""
  w_find_level_max:search("text").text = ""
  w_find_name.text = ui.get_text("im|lb_find_default")
  dlg:move_to_head()
  w_find_name.focus = true
end
function on_main_career_select(item)
  ui_widget.ui_combo_box.clear(w_combo_career2)
  ui_widget.ui_combo_box.append(w_combo_career2, {
    id = 0,
    text = ui.get_text("im|find_all_branch")
  })
  ui_widget.ui_combo_box.select(w_combo_career2, 0)
  w_combo_career2:search("btn_drop_down").text = ui.get_text("im|find_choose_branch")
  w_combo_career2:search("btn_drop_down").enable = true
  if item.id == 0 then
    w_combo_career2:search("btn_drop_down").enable = false
    return
  end
  local pro_id = item.id + 1
  local pro_list = bo2.gv_profession_list
  for i = pro_id, pro_id + 1 do
    local excel = pro_list:find(i)
    if excel then
      ui_widget.ui_combo_box.append(w_combo_career2, {
        id = excel.id,
        text = excel.name
      })
    end
  end
end
function on_dlg_find_init()
  ui_widget.ui_combo_box.append(w_combo_sex, {
    id = 0,
    text = ui.get_text("im|find_all_sex")
  })
  ui_widget.ui_combo_box.append(w_combo_sex, {
    id = bo2.eSex_Male,
    text = ui.get_text("im|sex_1")
  })
  ui_widget.ui_combo_box.append(w_combo_sex, {
    id = bo2.eSex_Female,
    text = ui.get_text("im|sex_2")
  })
  ui_widget.ui_combo_box.select(w_combo_sex, 0)
  w_combo_sex:search("btn_drop_down").text = ui.get_text("im|find_choose_sex")
  ui_widget.ui_combo_box.append(w_combo_camp, {
    id = 0,
    text = ui.get_text("im|find_all_camp")
  })
  ui_widget.ui_combo_box.append(w_combo_camp, {
    id = bo2.eCamp_Blade,
    text = ui.get_text("phase|camp_blade")
  })
  ui_widget.ui_combo_box.append(w_combo_camp, {
    id = bo2.eCamp_Sword,
    text = ui.get_text("phase|camp_sword")
  })
  ui_widget.ui_combo_box.select(w_combo_camp, 0)
  w_combo_camp:search("btn_drop_down").text = ui.get_text("im|find_choose_camp")
  ui_widget.ui_combo_box.append(w_combo_career, {
    id = 0,
    text = ui.get_text("im|find_all_occupation")
  })
  local pro_list = bo2.gv_profession_list
  for i = 0, pro_list.size - 1, 3 do
    local excel = pro_list:get(i)
    local career_excel = bo2.gv_career:find(excel.career)
    if career_excel ~= nil and career_excel.disable == 0 then
      ui_widget.ui_combo_box.append(w_combo_career, {
        id = excel.id,
        text = excel.name
      })
    end
  end
  ui_widget.ui_combo_box.select(w_combo_career, 0)
  w_combo_career:search("btn_drop_down").text = ui.get_text("im|find_choose_occupation")
  w_combo_career.svar.on_select = on_main_career_select
  ui_widget.ui_combo_box.append(w_combo_career2, {
    id = 0,
    text = ui.get_text("im|find_all_branch")
  })
  ui_widget.ui_combo_box.select(w_combo_career2, 0)
  w_combo_career2:search("btn_drop_down").text = ui.get_text("im|find_choose_branch")
  w_combo_career2:search("btn_drop_down").enable = false
  find_data = sys.variant()
end
function on_keydown_findplayer(ctrl, key, keyflag)
  if key == ui.VK_RETURN and keyflag.down then
    on_find_confirm()
  elseif key ~= ui.VK_ESCAPE and keyflag.down and w_find_name.text == ui.get_text("im|lb_find_default") then
    w_find_name.text = nil
  end
end
function on_mouse_findplayer(panel, msg)
  if msg == ui.mouse_lbutton_down and w_find_name.text == ui.get_text("im|lb_find_default") then
    w_find_name.text = nil
  end
end
function on_btn_sort_find(btn)
  if find_data.size == 0 then
    return
  end
  local name = btn.name
  local field
  if name == L("column_name") then
    field = packet.key.sociality_playername
  elseif name == L("column_camp") then
    field = packet.key.sociality_playercamp
  elseif name == L("column_level") then
    field = packet.key.sociality_playerlevel
  elseif name == L("column_sex") then
    field = packet.key.sociality_playersex
  else
    field = packet.key.sociality_playercareer
  end
  if btn.svar == 1 then
    find_data:rsort(field)
    btn.svar = 0
  else
    find_data:sort(field)
    btn.svar = 1
  end
  clear_find_res()
  insert_find_res(find_data, false)
end
