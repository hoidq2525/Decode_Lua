function on_group_list_init()
end
function on_im_group_list_visible(ctrl)
  if ctrl.visible == false then
    ui_tool.hide_menu()
  end
end
function insert_group_list_of_friend(v)
  local name = v:get(packet.key.sociality_playername).v_string
  local level = v:get(packet.key.sociality_playerlevel).v_int
  local careerId = v:get(packet.key.sociality_playercareer).v_int
  local sex = v:get(packet.key.sociality_playersex).v_int
  local relation = v:get(packet.key.sociality_relation_type).v_int
  local camp = v:get(packet.key.sociality_playercamp).v_int
  local locId = v:get(packet.key.cha_area).v_int
  relation = ui.get_text("im|re_" .. relation)
  local location = ui.get_text("im|loc_unknown")
  local area_excel = bo2.gv_area_list:find(locId)
  if area_excel then
    local scn_excel = bo2.gv_scn_list:find(area_excel.in_scn)
    if scn_excel then
      location = scn_excel.name
    end
  end
  local camp_text = L("")
  if camp == bo2.eCamp_Blade then
    camp_text = ui.get_text("phase|camp_blade")
  elseif camp == bo2.eCamp_Sword then
    camp_text = ui.get_text("phase|camp_sword")
  end
  insert_group_list(w_group_list_res, name, sex, careerId, level, relation, location, camp_text, true)
end
function insert_group_list(view, name, sex, careerId, level, relation, location, camp, flag)
  local item
  local b_IsSelf = false
  if name ~= bo2.player.name then
    item = view:item_append()
  else
    item = view:item_insert(0)
    relation = L("--")
    b_IsSelf = true
  end
  item:load_style("$frame/im/group_list.xml", "row_lable_group_list")
  item.mouse_able = flag
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
  local excel = bo2.gv_profession_list:find(careerId)
  if excel ~= nil then
    local career_pic = item:search("career_pic"):search("career_icon")
    ui_im.SetCareerIcon(career_pic, excel)
  end
  item:search("level"):search("text").text = level
  item:search("relation"):search("text").text = relation
  item:search("location"):search("text").text = location
  item:search("camp"):search("text").text = camp
  if b_IsSelf then
    local chg_color = ui.make_color("FFE27907")
    item:search("name"):search("text").color = chg_color
    item:search("level"):search("text").color = chg_color
    item:search("relation"):search("text").color = chg_color
    item:search("location"):search("text").color = chg_color
    item:search("camp"):search("text").color = chg_color
  end
end
function on_group_list_mouse(btn, msg, pos, wheel)
  local name = btn:search("name"):search("text").text
  if msg == ui.mouse_inner then
    btn:search("bg_fold").visible = true
  end
  if msg == ui.mouse_outer and group_select ~= btn.parent then
    btn:search("bg_fold").visible = false
  end
  if msg == ui.mouse_rbutton_down then
    local self_portrait_menu = {}
    generate_group_list_rb(name)
    self_portrait_menu = {
      items = im_rb_group_view,
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
function on_group_list_sel(item, sel)
end
function update_group_list_by_name(name, bIsAdd)
  local cnt = w_group_list_res.item_count - 1
  for i = 0, cnt do
    local item = w_group_list_res:item_get(i)
    if item:search("name"):search("text").text == name then
      local relation = ui.get_text("im|re_0")
      if bIsAdd then
        relation = ui.get_text("im|re_1")
      end
      item:search("relation"):search("text").text = relation
      return
    end
  end
end
