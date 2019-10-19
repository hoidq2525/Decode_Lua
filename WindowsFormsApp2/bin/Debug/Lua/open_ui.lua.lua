local ui_name = {}
ui_name[1] = "$frame:champion"
ui_name[2] = "$frame:cloned_battle"
ui_name[3] = "$frame:personal"
ui_name[4] = "$frame:personal"
ui_name[5] = "$frame:personal"
ui_name[6] = "$frame:personal"
ui_name[7] = "$frame:item"
ui_name[8] = "$frame:item"
ui_name[9] = "$frame:item"
ui_name[10] = "$frame:received_quest"
ui_name[11] = "$frame:skill"
ui_name[12] = "$frame:skill"
ui_name[13] = "$frame:skill"
ui_name[14] = "$frame:match_test"
ui_name[15] = "$frame:md"
ui_name[16] = "$frame:guild"
ui_name[17] = "$frame:advertise"
ui_name[18] = "$frame:supermarket2"
ui_name[19] = "$frame:setting:input"
ui_name[20] = "$frame:ui_mail"
ui_name[22] = "$frame:map"
ui_name[23] = "$frame:convene"
ui_name[25] = "$frame:campaign"
ui_name[26] = "$frame:im_find_panel"
ui_name[27] = "$frame:im_main"
ui_name[28] = "$frame:im_main"
ui_name[29] = "$frame:im_main"
ui_name[30] = "$frame:action"
ui_name[31] = "$frame:skill"
ui_name[32] = "$frame:skill"
ui_name[33] = "$frame:dungeonsel"
ui_name[34] = "$frame:areaquest"
ui_name[35] = "$frame:personal"
ui_name[36] = "$frame:personal"
ui_name[37] = "$frame:personal"
ui_name[38] = "$frame:personal"
ui_name[39] = "$frame:chg_portrait"
function open_ui_by_name(nameid)
  local window_name = ui_name[nameid]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    wnd:move_to_head()
  end
end
local ui_open_fn = {}
ui_open_fn[3] = function()
  local window_name = ui_name[3]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    ui_personal.ui_equip.w_quickequip.visible = not ui_personal.ui_equip.w_quickequip.visible
    wnd:move_to_head()
    bo2.PlaySound2D(592)
  end
end
ui_open_fn[4] = function()
  local window_name = ui_name[4]
  if nil ~= window_name then
    ui_personal.ui_renown.update_all()
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    ui_widget.ui_tab.show_page(ui_personal.w_personal, "repute", true)
    ui_widget.ui_tab.show_page(ui_personal.ui_repute.w_main, "renown", true)
    wnd:move_to_head()
  end
end
ui_open_fn[5] = function()
  local window_name = ui_name[5]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    ui_widget.ui_tab.show_page(ui_personal.w_personal, "ridepet", true)
    wnd:move_to_head()
  end
end
ui_open_fn[6] = function()
  local window_name = ui_name[6]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    ui_widget.ui_tab.show_page(ui_personal.w_personal, "cd_view", true)
  end
end
ui_open_fn[8] = function()
  local window_name = ui_name[8]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    if false == ui_item.ui_stall.owner.get_visible() then
      ui_item.on_click_open_stall()
    end
  end
end
ui_open_fn[9] = function()
  local window_name = ui_name[9]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    if false == ui_item.g_log_deal.visible then
      ui_item.on_click_deallog(nil)
    end
  end
end
ui_open_fn[10] = function()
  local window_name = ui_name[10]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    ui_widget.ui_tab.show_page(ui_quest.w_quest_list, "quyu", true)
  end
end
ui_open_fn[11] = function()
  local obj = bo2.player
  if obj then
    local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_Skill)
    if flag_value == 16 then
      ui_handson_teach.test_complate_skill_choose()
    end
  end
  local window_name = ui_name[11]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    ui_widget.ui_tab.show_page(ui_skill.w_skill, "liyi", true)
  end
end
ui_open_fn[12] = function()
  local obj = bo2.player
  if obj then
    local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_Skill)
    if flag_value == 16 then
      ui_handson_teach.test_complate_skill_choose()
    end
  end
  local window_name = ui_name[12]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    ui_lianzhao.w_lianzhao.visible = true
  end
end
ui_open_fn[13] = function()
  local obj = bo2.player
  if obj then
    local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_Skill)
    if flag_value == 16 then
      ui_handson_teach.test_complate_skill_choose()
    end
  end
  local window_name = ui_name[13]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    ui_huazhao.w_huazhao.visible = true
  end
end
ui_open_fn[14] = function()
  local window_name = ui_name[14]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    ui_widget.ui_tab.show_page(ui_match.g_match_test, "dooaltar_rank", true)
  end
end
ui_open_fn[16] = function()
  if bo2.is_in_guild() == sys.wstring(0) then
    local ui_search_visible = ui_guild_mod.ui_guild_search.w_guild_search.visible
    if false == ui_search_visible then
      ui_chat.show_ui_text_id(70251)
    end
    ui_guild_mod.ui_guild_search.set_win_open(0)
    return
  else
    ui_handson_teach.test_complate_guild(true)
  end
end
ui_open_fn[19] = function()
  open_ui_by_name(19)
end
ui_open_fn[21] = function()
  if nil == bo2.video_mode then
    ui_video.w_main.visible = true
  end
end
ui_open_fn[24] = function()
  ui_minimap.w_npc_panel.visible = true
  ui_handson_teach.test_complate_npc_list()
end
ui_open_fn[26] = function()
  local window_name = "$frame:im_main"
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    open_ui_by_name(26)
    wnd:move_to_head()
  end
end
ui_open_fn[27] = function()
  open_ui_by_name(27)
  ui_im.create_info_dlg(bo2.player.name, true)
  ui_widget.ui_tab.show_page(ui_im.w_info_panel, "self_info", true)
end
ui_open_fn[28] = function()
  open_ui_by_name(28)
  ui_im.create_info_dlg(bo2.player.name, true)
  ui_widget.ui_tab.show_page(ui_im.w_info_panel, "close", true)
end
ui_open_fn[29] = function()
  open_ui_by_name(29)
  ui_im.create_info_dlg(bo2.player.name, true)
  ui_widget.ui_tab.show_page(ui_im.w_info_panel, "shitu", true)
end
ui_open_fn[31] = function()
  local obj = bo2.player
  if obj then
    local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_Skill)
    if flag_value == 16 then
      ui_handson_teach.test_complate_skill_choose()
    end
  end
  local window_name = ui_name[31]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    ui_widget.ui_tab.show_page(ui_skill.w_skill, "qita", true)
  end
end
ui_open_fn[32] = function()
  local obj = bo2.player
  if obj then
    local flag_value = obj:get_flag_int16(bo2.ePlayerFlagInt16_HandsOn_Skill)
    if flag_value == 16 then
      ui_handson_teach.test_complate_skill_choose()
    end
  end
  local window_name = ui_name[32]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    ui_widget.ui_tab.show_page(ui_skill.w_skill, "fuzhi", true)
  end
end
ui_open_fn[33] = function()
  ui_dungeonui.ui_dungeonsel.set_visible()
  local window_name = ui_name[33]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    wnd:move_to_head()
  end
end
ui_open_fn[34] = function()
  ui_areaquest.set_visible()
  local window_name = ui_name[34]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    wnd:move_to_head()
  end
end
ui_open_fn[35] = function()
  local window_name = ui_name[35]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    ui_widget.ui_tab.show_page(ui_personal.w_personal, "title", true)
    wnd:move_to_head()
  end
end
ui_open_fn[36] = function()
  local window_name = ui_name[36]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    ui_widget.ui_tab.show_page(ui_personal.w_personal, "repute", true)
    wnd:move_to_head()
    ui_widget.ui_tab.show_page(ui_personal.ui_repute.w_main, "renown", true)
  end
end
ui_open_fn[37] = function()
  local window_name = ui_name[37]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    wnd:move_to_head()
  end
end
ui_open_fn[38] = function()
  local window_name = ui_name[37]
  if nil ~= window_name then
    local wnd = ui.find_control(window_name)
    wnd.visible = true
    wnd:move_to_head()
  end
  ui_personal.ui_equip.on_btn_slot_enhance()
end
ui_open_fn[39] = function()
  local w = ui_im.w_chg_portrait
  w.visible = not w.visible
end
function open_ui_by_id(id)
  local fn = ui_open_fn[id]
  if nil ~= fn then
    fn()
    return
  end
  open_ui_by_name(id)
end
function open()
  open_ui_by_id(39)
end
