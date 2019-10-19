local levelup_numbers = {}
levelup_numbers[0] = SHARED("$image/levelup/numbers.png|0,0,22,31")
levelup_numbers[1] = SHARED("$image/levelup/numbers.png|38,0,57,31")
levelup_numbers[2] = SHARED("$image/levelup/numbers.png|70,0,57,31")
levelup_numbers[3] = SHARED("$image/levelup/numbers.png|105,0,126,31")
levelup_numbers[4] = SHARED("$image/levelup/numbers.png|147,0,170,31")
levelup_numbers[5] = SHARED("$image/levelup/numbers.png|192,0,215,31")
levelup_numbers[6] = SHARED("$image/levelup/numbers.png|242,0,264,31")
levelup_numbers[7] = SHARED("$image/levelup/numbers.png|286,0,309,31")
levelup_numbers[8] = SHARED("$image/levelup/numbers.png|325,0,348,31")
levelup_numbers[9] = SHARED("$image/levelup/numbers.png|377,0,400,31")
local recommand_excel = bo2.gv_levelup
local level_intro, g_level, system_tip_title, system_tip_content, quest_tip_title, quest_tip_content, event_tip_title, event_tip_content, dungeon_tip_title, dungeon_tip_content, next_tip_title, next_tip_content
local tip_note_openui = ui.get_text("levelup|tip_note_openui")
local tip_note_searchpath = ui.get_text("levelup|tip_note_searchpath")
local tip_note_pleasewait = ui.get_text("levelup|tip_note_pleasewait")
local panel_contain_button_x = 449
local button_x = 60
function on_levelup(data)
  local level = data:get(packet.key.levelup_level).v_int
  local intro = recommand_excel:find(level)
  if 1 ~= intro.is_visible then
    return
  end
  g_level = level
  level_intro = intro
  local is_zh_cn = bo2.gv_define:find(1107).value.v_int
  if 1 == is_zh_cn then
    congrat_number.visible = true
    congrat_pic.visible = true
    congrat_words.visible = false
    set_level_number(g_level)
  else
    congrat_number.visible = false
    congrat_pic.visible = false
    congrat_words.visible = true
    congrat_words.text = ui_widget.merge_mtf({level = level}, ui.get_text("levelup|congrat_words"))
  end
  init_btn()
  local pro_id = tonumber(bo2.player:get_atb(bo2.eAtb_Cha_Profession))
  set_atb_up(pro_id, g_level, data)
  levelup_main.visible = true
  local wnd = ui.find_control("$frame:levelup")
  wnd:move_to_head()
end
function set_atb_up(pro_id, level, atb_packet)
  local up_hp = atb_packet:get(packet.key.levelup_hpmax_up).v_int
  local up_phy_def_lvl = atb_packet:get(packet.key.levelup_phydefendlv_up).v_int
  local up_mgc_def_lvl = atb_packet:get(packet.key.levelup_mgcdefendlv_up).v_int
  local up_dmg_lvl
  local pro = bo2.gv_profession_list:find(pro_id)
  if nil == pro then
    return
  end
  local dmg_type = pro.damage
  if 1 == dmg_type then
    item_dmg_type.text = ui.get_text("levelup|item_atb_mgc_dmg_level")
    up_dmg_lvl = atb_packet:get(packet.key.levelup_mgcattacklv_up).v_int
  else
    item_dmg_type.text = ui.get_text("levelup|item_atb_phy_dmg_level")
    up_dmg_lvl = atb_packet:get(packet.key.levelup_phyattacklv_up).v_int
  end
  local player_lvlup = bo2.gv_player_levelup:find(level - 1)
  if nil == player_lvlup then
    return
  end
  local pro_index = math.floor(pro_id / 3) * 2
  if 0 == pro_id % 3 then
    pro_index = pro_index - 1
  end
  local up_vit = player_lvlup.up_vit[pro_index]
  local up_agi = player_lvlup.up_agi[pro_index]
  local up_int = player_lvlup.up_int[pro_index]
  local up_str = player_lvlup.up_str[pro_index]
  item_atb_hp_max_digit.text = "+" .. up_hp
  item_atb_vit_digit.text = "+" .. up_vit
  item_atb_agi_digit.text = "+" .. up_agi
  item_atb_int_digit.text = "+" .. up_int
  item_atb_str_digit.text = "+" .. up_str
  item_atb_phy_def_level_digit.text = "+" .. up_phy_def_lvl
  item_atb_mgc_def_level_digit.text = "+" .. up_mgc_def_lvl
  item_atb_dmg_level_digit.text = "+" .. up_dmg_lvl
end
function init_btn()
  local btn_visible_count = 5
  btn_system.visible = true
  btn_quest.visible = true
  btn_event.visible = true
  btn_dungeon.visible = true
  btn_next.visible = true
  if nil == level_intro then
    btn_visible_count = 0
    btn_system.visible = false
    btn_quest.visible = false
    btn_event.visible = false
    btn_dungeon.visible = false
    btn_next.visible = false
    return
  end
  system_tip_title = level_intro.manual_system_tip_title
  system_tip_content = level_intro.manual_system_tip_content
  quest_tip_title = level_intro.manual_quest_tip_title
  quest_tip_content = level_intro.manual_quest_tip_content
  event_tip_title = level_intro.manual_event_tip_title
  event_tip_content = level_intro.manual_event_tip_content
  dungeon_tip_title = level_intro.manual_dungeon_tip_title
  dungeon_tip_content = level_intro.manual_dungeon_tip_content
  next_tip_title = level_intro.manual_next_tip_title
  next_tip_content = level_intro.manual_next_tip_content
  if nil == system_tip_title or string.len(tostring(system_tip_title)) == 0 then
    btn_system.visible = false
    btn_visible_count = btn_visible_count - 1
  end
  if nil == quest_tip_title or string.len(tostring(quest_tip_title)) == 0 then
    btn_quest.visible = false
    btn_visible_count = btn_visible_count - 1
  end
  if nil == event_tip_title or string.len(tostring(event_tip_title)) == 0 then
    btn_event.visible = false
    btn_visible_count = btn_visible_count - 1
  end
  if nil == dungeon_tip_title or string.len(tostring(dungeon_tip_title)) == 0 then
    btn_dungeon.visible = false
    btn_visible_count = btn_visible_count - 1
  end
  if nil == next_tip_title or string.len(tostring(next_tip_title)) == 0 then
    btn_next.visible = false
    btn_visible_count = btn_visible_count - 1
  end
  pos_btn(btn_visible_count)
end
function pos_btn(btn_visible_count)
  if btn_visible_count < 0 or btn_visible_count > 5 then
    return
  end
  local margin_x = (panel_contain_button_x - button_x * btn_visible_count) / (btn_visible_count + 1)
  margin_x = math.floor(margin_x + 0.5)
  btn_system.margin = ui.rect(margin_x, 0, 0, 0)
  btn_quest.margin = ui.rect(margin_x, 0, 0, 0)
  btn_event.margin = ui.rect(margin_x, 0, 0, 0)
  btn_dungeon.margin = ui.rect(margin_x, 0, 0, 0)
  btn_next.margin = ui.rect(margin_x - 6, 0, 0, 0)
end
function set_level_number(level)
  if level < 10 then
    num_0.visible = true
    num_2.visible = false
    num_1.image = levelup_numbers[level]
  elseif level < 100 then
    num_0.visible = false
    num_2.visible = true
    num_1.image = levelup_numbers[math.floor(level / 10)]
    num_2.image = levelup_numbers[level % 10]
  end
end
function on_tip_make(tip)
  local btn = tip.owner
  local catagory = string.sub(tostring(btn.name), 5, -1)
  local tip_title, tip_content
  local tip_note = tip_note_pleasewait
  if "system" == catagory then
    tip_title = system_tip_title
    tip_content = system_tip_content
    tip_note = tip_note_openui
  elseif "quest" == catagory then
    tip_title = quest_tip_title
    tip_content = quest_tip_content
    tip_note = tip_note_searchpath
  elseif "event" == catagory then
    tip_title = event_tip_title
    tip_content = event_tip_content
    flag = tonumber(level_intro.manual_event_type)
    if nil == flag then
      return
    end
    if 0 == flag then
      tip_note = tip_note_openui
    end
    if 1 == flag then
      tip_note = tip_note_searchpath
    end
  elseif "dungeon" == catagory then
    tip_title = dungeon_tip_title
    tip_content = dungeon_tip_content
    tip_note = tip_note_searchpath
  elseif "next" == catagory then
    tip_title = next_tip_title
    tip_content = next_tip_content
  end
  if nil == tip_title then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_push_text(stk, tip_title, ui_tool.cs_tip_color_green)
  ui_tool.ctip_push_sep(stk)
  stk:raw_push(tip_content)
  ui_tool.ctip_push_sep(stk)
  ui_tool.ctip_push_text(stk, tip_note, ui_tool.cs_tip_color_orange)
  ui_tool.ctip_show(tip.owner, stk, nil)
end
function clear_tip()
  system_tip_title = nil
  system_tip_content = nil
  quest_tip_title = nil
  quest_tip_content = nil
  event_tip_title = nil
  event_tip_content = nil
  dungeon_tip_title = nil
  dungeon_tip_content = nil
  next_tip_title = nil
  next_tip_content = nil
end
function on_close_click(btn)
  clear_tip()
  ui_widget.on_close_click(btn)
end
function find_path(markid)
  ui_map.find_path_byid(markid)
end
function open_ui(id)
  open_ui_by_id(id)
end
function on_system_click(btn)
  id = tonumber(level_intro.manual_system_id)
  if nil == id then
    return
  end
  open_ui(id)
end
function on_quest_click(btn)
  markid = tonumber(level_intro.manual_quest_markid)
  if nil == markid then
    return
  end
  find_path(markid)
end
function on_event_click(btn)
  flag = tonumber(level_intro.manual_event_type)
  if nil == flag then
    return
  end
  id = tonumber(level_intro.manual_event_id)
  if nil == id then
    return
  end
  if 0 == flag then
    open_ui(id)
  elseif 1 == flag then
    find_path(id)
  end
end
function on_dungeon_click(btn)
  markid = tonumber(level_intro.manual_dungeon_markid)
  if nil == markid then
    return
  end
  find_path(markid)
end
function on_next_click(btn)
end
