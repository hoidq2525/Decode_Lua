local select_guild
local def_seach_tar_type_cmn = 0
local def_seach_tar_type_union = 1
local def_seach_tar_type_enmey = 2
local def_seach_tar_type_temp_battle = 3
local g_num_in_page = 10
function on_init(ctrl)
  select_guild = nil
  g_search_list:item_clear()
  g_keyword_box.text = L("")
  ui.insert_on_guild_search_refresh("ui_guild_mod.ui_guild_search.on_guild_search_refresh")
end
function update_page(var)
  g_search_list:item_clear()
  select_guild = nil
  if g_search_list.item_sel ~= nil then
    g_search_list.item_sel:search("select").visible = false
    g_search_list.item_sel.selected = false
  end
  local page_idx = var.index
  local page_cnt = var.count
  local item_size = ui.guild_search_rst_size()
  local item_bg_idx = page_idx * g_num_in_page
  local item_end = item_bg_idx + g_num_in_page
  if item_size < item_end then
    item_end = item_size
  end
  local item_file = "$frame/guild/guild_search.xml"
  local item_style = "guild_search_item"
  local max_union_num = bo2.gv_define_org:find(63).value.v_int - 1
  for i = item_bg_idx, item_end - 1 do
    local ui_guild_search
    result = ui.guild_get_search_rst(i)
    local item = g_search_list:item_append()
    item:load_style(item_file, item_style)
    local id = item:search("id")
    id.text = result.id
    local intro = item:search("intro")
    intro.text = result.intro
    local guild_name = item:search("guild_name")
    guild_name.text = result.name
    local leader = item:search("leader")
    leader.text = result.leader
    local level = item:search("level")
    level.text = result.level
    local num = item:search("num")
    local v = sys.variant()
    v:set("cur_num", result.number)
    v:set("max_num", result.maxnumber)
    local num_text = sys.mtf_merge(v, ui.get_text("guild|family_member"))
    num.text = num_text
    local union = item:search("union")
    local unum = result.union
    if unum > 0 then
      unum = unum - 1
    end
    local v2 = sys.variant()
    v2:set("cur_num", unum)
    v2:set("max_num", max_union_num)
    union.text = sys.mtf_merge(v2, ui.get_text("guild|union_count"))
  end
end
function on_guild_search_refresh()
  local item_size = ui.guild_search_rst_size()
  local page_cnt = math.ceil(item_size / g_num_in_page)
  ui_widget.ui_stepping.set_event(w_step, update_page)
  ui_widget.ui_stepping.set_page(w_step, 0, page_cnt)
  update_page(w_step.svar.stepping)
end
function on_guild_item_tip_show(tip)
  local stk = sys.mtf_stack()
  local item = tip.owner
  local intro_text = item:search("intro").text
  ui_tool.ctip_push_text(stk, ui.get_text("guild|guild_name"), "CAFF70")
  ui_tool.ctip_push_text(stk, ":")
  ui_tool.ctip_push_text(stk, item:search("guild_name").text)
  ui_tool.ctip_push_newline(stk)
  ui_tool.ctip_push_text(stk, ui.get_text("guild|guild_pos8"), "CAFF70")
  ui_tool.ctip_push_text(stk, ":")
  ui_tool.ctip_push_text(stk, item:search("leader").text)
  if intro_text ~= L("") then
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_text(stk, ui.get_text("guild|guild_manage_title_info"), "CAFF70")
    ui_tool.ctip_push_text(stk, ":")
    ui_tool.ctip_push_text(stk, intro_text)
  end
  ui_tool.ctip_show(item, stk)
end
function on_guild_search_visible(w, vis)
  if ui_guild_mod.ui_guild.is_multi_server(bo2.player:get_flag_objmem(bo2.eFlagObjMemory_ScnExcelID)) == false then
    ui_guild_mod.ui_guild_search.w_guild_search.visible = false
    return
  end
  if vis == true then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    g_keyword_box.focus = true
    g_keyword_box.text = L("")
    select_guild = nil
    g_guild_search_btn:click()
    g_guild_applym_btn.enable = true
    bo2.PlaySound2D(519)
  else
    ui_widget.esc_stk_pop(w)
    ui_guild_mod.ui_apply_win.w_apply_main.visible = false
    if select_guild ~= nil then
      select_guild:search("intro").visible = false
    end
    if g_search_list.item_sel ~= nil then
      g_search_list.item_sel:search("select").visible = false
      g_search_list.item_sel.selected = false
    end
    bo2.PlaySound2D(520)
  end
  ui_handson_teach.test_complate_guild(vis)
end
function on_search_item_select(ctrl)
  g_keyword_box.focus = false
  if select_guild ~= nil then
    select_guild:search("select").visible = false
  end
  select_guild = ctrl
  select_guild:search("item_hover").visible = false
  select_guild:search("select").visible = true
end
function on_search_item_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_enter then
    if ctrl.selected == false then
      ctrl:search("item_hover").visible = true
    end
  elseif msg == ui.mouse_leave then
    ctrl:search("item_hover").visible = false
  end
end
function on_guild_search(ctrl)
  local v = sys.variant()
  v:set(packet.key.org_vartext, g_keyword_box.text)
  if g_guild_applym_btn.svar.type == nil then
    g_guild_applym_btn.svar.type = def_seach_tar_type_cmn
  end
  if g_guild_applym_btn.svar.type == def_seach_tar_type_cmn or g_guild_applym_btn.svar.type == def_seach_tar_type_union then
    v:set(packet.key.cmn_state, 1)
  end
  v:set(packet.key.cmn_type, g_guild_applym_btn.svar.type)
  bo2.send_variant(packet.eCTS_Guild_Search, v)
  g_guild_search_btn.enable = false
  g_timer.suspended = false
end
function on_guild_apply(ctrl)
  ui_handson_teach.test_complate_guild(false)
  if select_guild == nil then
    local msg = {
      btn_confirm = true,
      btn_cancel = false,
      modal = true
    }
    msg.text = ui.get_text("guild|select_guild")
    ui_tool.show_msg(msg)
  else
    local msg = {
      callback = on_guild_apply_msg,
      btn_confirm = true,
      btn_cancel = true,
      modal = true
    }
    msg.text = ui.get_text("guild|guild_apply_msg")
    ui_tool.show_msg(msg)
  end
end
function on_guild_apply_member(ctrl)
  if select_guild == nil then
    local msg = {
      btn_confirm = true,
      btn_cancel = false,
      modal = true
    }
    msg.text = ui.get_text("guild|select_guild")
    ui_widget.ui_msg_box.show_common(msg)
    return
  end
  local tar_type = ctrl.svar.type
  if tar_type == def_seach_tar_type_union then
    local name = select_guild:search("guild_name").text
    local v = sys.variant()
    v:set(packet.key.org_name, name)
    bo2.send_variant(packet.eCTS_Guild_InviteUnion, v)
  elseif tar_type == def_seach_tar_type_enmey then
    local msg = {
      callback = function(data)
        if data.result == 1 then
          local name = select_guild:search("guild_name").text
          local v = sys.variant()
          v:set(packet.key.org_name, name)
          bo2.send_variant(packet.eCTS_Guild_AddEnemy, v)
          ui.log(packet.eCTS_Guild_TempBattle)
        end
      end,
      btn_confirm = true,
      btn_cancel = true,
      modal = true,
      text = ui.get_text("guild|enemy_money")
    }
    ui_widget.ui_msg_box.show_common(msg)
  elseif tar_type == def_seach_tar_type_temp_battle then
    local msg = {
      callback = function(data)
        if data.result == 1 then
          local name = select_guild:search("guild_name").text
          local v = sys.variant()
          v:set(packet.key.org_name, name)
          bo2.send_variant(packet.eCTS_Guild_TempBattle, v)
          ui.log(packet.eCTS_Guild_TempBattle)
        end
      end,
      btn_confirm = true,
      btn_cancel = true,
      modal = true,
      text = ui.get_text("guild|temp_battle_makesure")
    }
    ui_widget.ui_msg_box.show_common(msg)
  else
    local msg = {
      callback = on_guild_apply_member_msg,
      btn_confirm = true,
      btn_cancel = true,
      modal = true
    }
    msg.text = ui.get_text("guild|guild_applym_msg")
    ui_widget.ui_msg_box.show_common(msg)
  end
end
function on_guild_apply_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local id = select_guild:search("id")
    ui_guild_mod.ui_apply_win.set_apply_info(2, id.text)
    ui_guild_mod.ui_apply_win.w_apply_main.visible = true
  end
end
function on_guild_apply_member_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local id = select_guild:search("id")
    ui_guild_mod.ui_apply_win.set_apply_info(3, id.text)
    ui_guild_mod.ui_apply_win.w_apply_main.visible = true
  end
end
function on_timer(timer)
  g_guild_search_btn.enable = true
  timer.suspended = true
end
function on_input_change(tb, txt)
  input_mask.visible = g_keyword_box.text.empty
end
function on_keydown_return(ctrl, key, keyflag)
  if key == ui.VK_RETURN and keyflag.down then
    on_guild_search(ctrl)
  end
end
function set_win_open(tar_type)
  local btn_text = ""
  g_guild_applym_btn.svar.type = tar_type
  if tar_type == def_seach_tar_type_union then
    btn_text = ui.get_text("guild|guild_search_union")
  elseif tar_type == def_seach_tar_type_enmey then
    btn_text = ui.get_text("guild|guild_search_enemy")
  elseif tar_type == def_seach_tar_type_temp_battle then
    btn_text = ui.get_text("guild|guild_search_temp_battle")
  else
    btn_text = ui.get_text("guild|guild_applym")
  end
  g_guild_applym_btn.text = btn_text
  g_guild_search_btn:click()
  w_guild_search.visible = true
end
function HandleSecondTempBattle(cmd, data)
  local num = bo2.gv_define:find(1236).value.v_int
  local item_id = bo2.gv_define:find(1235).value.v_int
  ui_widget.ui_msg_box.show_common({
    text = ui_widget.merge_mtf({num = num, item_id = item_id}, ui.get_text("guild|text_second_confirm")),
    modal = true,
    btn_confirm = true,
    btn_cancel = true,
    callback = function(msg)
      if msg.result == 1 then
        bo2.send_variant(packet.eCTS_UI_Guild_Second_Temp_Battle, data)
      end
    end
  })
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_Guild_Second_Temp_Battle, HandleSecondTempBattle, "ui_guild_mod.ui_guild_search:HandleSecondTempBattle")
