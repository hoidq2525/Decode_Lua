function on_invite_search_click(btn)
  local v = sys.variant()
  local level_min = ui_convene_w_invite_search_level_low.text
  local level_max = ui_convene_w_invite_search_level_high.text
  local score_min = ui_convene_w_invite_search_score_low.text
  local score_max = ui_convene_w_invite_search_score_high.text
  if level_min ~= nil then
    v:set(packet.key.sociality_playerlevel_min, level_min)
  end
  if level_max ~= nil then
    v:set(packet.key.sociality_playerlevel_max, level_max)
  end
  if score_min ~= nil then
    v:set(packet.key.sociality_fight_score_min, score_min)
  end
  if score_max ~= nil then
    v:set(packet.key.sociality_fight_score_max, score_max)
  end
  v:set(packet.key.cha_onlyid, bo2.player.only_id)
  bo2.send_variant(packet.eCTS_Convene_InviteSearch, v)
end
function on_convene_invite_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis == true then
    w_invite_list:item_clear()
    local type = w_invite_view_main.svar.type
    local scn_id = w_invite_view_main.svar.scn_id
    ui_convene_w_invite_dungeon_type.text = ui.get_text("convene|convene_type_" .. type)
    local scnlist_tb = bo2.gv_scn_list:find(scn_id)
    local scnname = scnlist_tb.name
    ui_convene_w_invite_dungeon_name.text = scnname
  end
end
function clear_search_list()
  w_invite_list:item_clear()
end
function insert_serach_item(view, name, level, career_id, fight_score)
  local item = view:item_append()
  item:load_style("$frame/convene/invite.xml", "invite_item")
  local career = ""
  local pro_list = bo2.gv_profession_list:find(career_id)
  if pro_list ~= nil then
    career = pro_list.name
  end
  local i_name = item:search("player_name")
  i_name.text = name
  local i_level = item:search("level")
  i_level.text = level
  local i_career = item:search("career")
  i_career.text = career
  local i_score = item:search("fight_score")
  i_score.text = fight_score
end
function insert_search_result(data, bIsNewData)
  for i = 0, data.size - 1 do
    local v = data:get(i)
    local name = v:get(packet.key.cha_name).v_string
    local level = v:get(packet.key.cha_level).v_int
    local career_id = v:get(packet.key.player_career).v_int
    local fight_score = v:get(packet.key.gs_score).v_int
    insert_serach_item(w_invite_list, name, level, career_id, fight_score)
  end
end
function on_invite_player_click(btn)
  local name = btn.parent:search("player_name").text
  if ui_group.may_invite(name) == false then
    ui_chat.show_ui_text_id(1000)
    return
  end
  local group_id = bo2.get_group_id()
  local v = sys.variant()
  v:set(packet.key.cha_name, name)
  v:set(packet.key.group_id, group_id)
  bo2.send_variant(packet.eCTS_Convene_InvitePlayer, v)
  btn.text = ui.get_text("convene|btn_invited")
  btn.enable = false
end
function on_btn_invite_title_name_click(btn)
  g_sort_asc = not g_sort_asc
  sort_list(w_invite_list, "player_name", false, g_sort_asc)
end
function on_btn_invite_title_level_click(btn)
  g_sort_asc = not g_sort_asc
  sort_list(w_invite_list, "level", true, g_sort_asc)
end
function on_btn_invite_title_career_click(btn)
  g_sort_asc = not g_sort_asc
  sort_list(w_invite_list, "career", false, g_sort_asc)
end
function on_btn_invite_title_score_click(btn)
  g_sort_asc = not g_sort_asc
  sort_list(w_invite_list, "fight_score", true, g_sort_asc)
end
