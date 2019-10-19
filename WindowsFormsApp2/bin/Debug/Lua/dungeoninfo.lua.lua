local scninfo_table = sys.load_table("$mb/scn/dungeon_info.xml")
function set_visible_infopanel(scnid, cd_remain)
  w_dungeoninfo.visible = true
  w_dungeoninfo.margin = ui.rect(w_dungeonsel.margin.x1 + w_dungeonsel.dx, w_dungeonsel.margin.y1, w_dungeonsel.margin.x2, w_dungeonsel.margin.y2)
  local line = scninfo_table:find(scnid)
  if line == nil then
    return
  end
  local scnid = line.sceneID
  if scnid == 0 then
    return
  end
  local pic_name = line.imageUrl
  if pic_name == "" then
    return
  end
  local textid = line.intro
  if textid == 0 then
    return
  end
  local difficulty = line.difficulty
  if difficulty == 0 then
    return
  end
  local scnlist_tb = bo2.gv_scn_list:find(scnid)
  if scnlist_tb == nil then
    return
  end
  local scnname = scnlist_tb.name
  local min_level = scnlist_tb.min_level
  local max_level = scnlist_tb.max_level
  local scnalloc_tb = bo2.gv_scn_alloc:find(scnid)
  if scnalloc_tb == nil then
    return
  end
  local max_num = scnalloc_tb.player
  local info_panel = w_dungeoninfo:search("info_panel")
  if info_panel == nil then
    return
  end
  info_panel:search("scninfo_name").text = scnname
  info_panel:search("scninfo_name").color = ui.make_color(L("FF8000"))
  info_panel:search("scninfo_pic").image = "$image/dungeonui/icon/" .. pic_name .. ".png"
  local textline = bo2.gv_text:find(textid)
  if textline == nil then
    return
  end
  info_panel:search("scninfo_intro").mtf = textline.text
  local text1 = ui.get_text("dungeonui|infopanel_playernum")
  local param = sys.variant()
  param:set("cha_num", max_num)
  local str1 = sys.mtf_merge(param, text1)
  info_panel:search("scninfo_playernum").text = str1
  local str2 = set_level_text(min_level, max_level)
  info_panel:search("scninfo_level").text = str2
  local text3 = ui.get_text("dungeonui|infopanel_remainnum")
  local param = sys.variant()
  cur_num = 0
  total_num = 0
  param:set("remain_num", cd_remain)
  local str3 = sys.mtf_merge(param, text3)
  info_panel:search("scninfo_num").text = str3
  local star_1 = math.floor(difficulty / 2)
  local star_2 = difficulty % 2
  if star_2 > 1 then
    star_2 = 1
  end
  local star_3 = 5 - star_1 - star_2
  for i = 1, star_1 do
    local starname = "star" .. i
    info_panel:search(starname).image = "$image/widget/pic/star_n_1.png"
  end
  if star_2 == 1 then
    local starname = "star" .. star_1 + 1
    info_panel:search(starname).image = "$image/widget/pic/star_n_2.png"
  end
  if star_3 > 0 then
    for i = star_1 + star_2 + 1, 5 do
      local starname = "star" .. i
      info_panel:search(starname).image = "$image/widget/pic/star_n_3.png"
    end
  end
  local btn_recruit = info_panel:search("findteammate")
  btn_recruit.svar = {}
  btn_recruit.svar.num = max_num
  btn_recruit.svar.name = scnname
  local markid = line.markid
  local btn_findway = info_panel:search("findway")
  btn_findway.svar.markid = markid
  btn_findway.text = ui.get_text("dungeonui|scninfo_findway")
  btn_findway.enable = true
  if markid == 0 then
    btn_findway.text = ui.get_text("dungeonui|findway_no")
    btn_findway.enable = false
  end
end
function on_find_teammate(ctrl)
  ui_convene.on_btn_show_recruit_edit_click()
  ui_widget.ui_combo_box.select(ui_convene.w_type_list, 4)
  ui_widget.ui_combo_box.select(ui_convene.w_num_list, ctrl.svar.num - 1)
  local player = bo2.player
  local need_mem = 0
  local cur_team_num = player.group_cur_num
  if cur_team_num == 0 then
    cur_team_num = 1
  end
  need_mem = ctrl.svar.num - cur_team_num
  local text = ui.get_text("dungeonui|findteaminfo")
  local param = sys.variant()
  param:set("scn_name", ctrl.svar.name)
  param:set("cha_num", need_mem)
  local str3 = sys.mtf_merge(param, text)
  ui_convene.w_recruit_edit_desc.mtf = str3
  ui_convene.w_show_desc.visible = false
  ui_convene.w_type_list_desc.visible = false
  ui_convene.w_num_list_desc.visible = false
end
function on_find_way_speci(btn)
  local svar = btn.svar
  if svar == nil then
    return
  end
  local markid = svar.markid
  ui_map.find_path_byid(markid)
end
