local first_sel
local count_sel = 0
local talk_quest_sel_num = 0
local repute_level_low = 6
talk_obj = nil
g_talk_sel_id = 0
local g_close_talk = true
local g_close_max_tick = 25
local g_server_close_max_tick = 5
local g_disable_fader_show = false
local icon_npc_shop = 9
local icon_npc_func = 2
local icon_talk_inquire = 15
local icon_talk_return = 16
local icon_talk_accept = 14
local icon_talk_collect = 10
local quest_text_color = "<c+:FFFF00>"
function on_set_disable_fader_show(bShow)
  g_disable_fader_show = bShow
end
function on_init()
end
function on_visible_disable_window()
  ui_skill_preview.w_skill_preview.visible = false
  ui_camp_repute.w_main.visible = false
end
function play_talk_sound(obj)
  if talk_obj == nil or talk_obj ~= obj then
    local bPlayer = false
    if talk_quest_sel_num > 0 then
      bPlayer = obj:playsound(bo2.eSE_Talk_OpenQuestTalk)
    end
    if obj.cha_excel == nil then
      return
    end
    if not bPlayer then
      local soundExcel = bo2.gv_sound_effect:find(obj.cha_excel.sound_effect)
      if not bPlayer and ui_quest.ui_reputation.is_reputation_npc(obj.cha_excel.id) then
        local level = ui.quest_get_qobj_value(bo2.eQuestObj_ReputeLevel, obj.cha_excel.reputation_id)
        if level <= repute_level_low then
          bPlayer = obj:playsound(bo2.eSE_Talk_ReputeLowTalk)
        else
          bPlayer = obj:playsound(bo2.eSE_Talk_ReputeHighTalk)
        end
      end
    end
    if not bPlayer then
      obj:playsound(bo2.eSE_Talk_OpenTalk)
    end
    talk_obj = obj
  end
end
function make_sel_query(stk, quest_id, query_kind, id)
  local info = ui.quest_find(quest_id)
  if info == nil then
    info = ui.guild_quest_find(quest_id)
    if info == nil then
      return
    end
  end
  local talk_inquire_text = quest_text_color .. ui.get_text("npcfunc|talk_inquire")
  local talk_collect_text = quest_text_color .. ui.get_text("npcfunc|talk_collect")
  local excel = info.excel
  if info.completed then
  else
    for i = 0, 3 do
      if excel.req_obj[i] == query_kind and excel.req_id[i] == id then
        if query_kind == bo2.eQuestObj_QueryNpc then
          local handson_sel_name = ui_handson_teach.on_active_quest_talk(id)
          make_sel(stk, bo2.eTalkSel_QueryQuest, excel.req_min[i], sys.format(talk_inquire_text .. "%s<c->", excel.name), icon_talk_inquire, handson_sel_name)
          talk_quest_sel_num = talk_quest_sel_num + 1
          return
        elseif query_kind == bo2.eQuestObj_NpcCollect then
          local handson_sel_name = ui_handson_teach.on_active_quest_talk(id)
          make_sel(stk, bo2.eTalkSel_QuestCollect, excel.req_min[i], sys.format(talk_inquire_text .. "%s<c->", excel.name), icon_talk_collect, handson_sel_name)
          talk_quest_sel_num = talk_quest_sel_num + 1
          return
        end
      end
    end
  end
  local mstone_id = info.mstone_id
  if mstone_id == 0 then
    return nil
  end
  local mstone = bo2.gv_milestone_list:find(mstone_id)
  if mstone == nil then
    return nil
  end
  if mstone.req_obj == query_kind and mstone.req_id == id then
    local handson_sel_name = ui_handson_teach.on_active_quest_talk(id)
    make_sel(stk, bo2.eTalkSel_QueryQuest, mstone.talk_id, sys.format(talk_inquire_text .. "%s-%s<c->", excel.name, mstone.name), icon_talk_inquire, handson_sel_name)
    talk_quest_sel_num = talk_quest_sel_num + 1
  end
end
function make_sel_medium(stk, quest_id, kind, id)
  local info = ui.quest_find(quest_id)
  if info == nil then
    info = ui.guild_quest_find(quest_id)
  end
  if info ~= nil then
    local excel = info.excel
    if excel.in_theme == bo2.eThemeType_Guild and excel.end_obj == bo2.eQuestObj_QueryNpc then
      if bo2.is_in_guild() == sys.wstring(0) then
        return
      end
      do
        local npc_guild_index = ui.npc_guild_mb_id()
        if npc_guild_index ~= 0 then
          for j = 0, bo2.gv_npcguild_npc_list.size - 1 do
            local n2 = bo2.gv_npcguild_npc_list:get(j)
            if npc_guild_index == n2.npc_guild and n2.npc_id == id then
              rst = 0
              break
            end
          end
          if rst == -1 then
            return
          end
        end
      end
    else
    end
    local talk_return_text = quest_text_color .. ui.get_text("npcfunc|talk_return")
    if excel.end_obj == kind and excel.end_id == id and info.completed then
      local handson_sel_name = ui_handson_teach.on_active_quest_talk(id)
      make_sel(stk, bo2.eTalkSel_EndQuest, quest_id, sys.format(talk_return_text .. "%s<c->", excel.name), icon_talk_return, handson_sel_name)
    else
    end
  elseif ui.quest_check_insert(quest_id) then
    local excel = bo2.gv_quest_list:find(quest_id)
    local self = ui.guild_get_self()
    if excel.in_theme == bo2.eThemeType_GuildLeader and (self == nil or self.guild_pos ~= bo2.Guild_Leader) then
      return
    end
    local talk_accept_text = quest_text_color .. ui.get_text("npcfunc|talk_accept")
    if excel.beg_obj == kind and excel.beg_id == id then
      make_sel(stk, bo2.eTalkSel_BegQuest, quest_id, sys.format(talk_accept_text .. "%s<c->", excel.name), icon_talk_accept)
      talk_quest_sel_num = talk_quest_sel_num + 1
    end
  end
end
local function build_sel(stk, kind, id, text, icon, handson, script_id)
  if icon == nil then
    icon = ""
  end
  if handson == nil then
    handson = ""
  end
  if script_id == nil then
    script_id = ""
  end
  stk:raw_push("<sel:")
  stk:format("%d,%d,%d,%s,%d,%s", kind, id, icon, handson, script_id, text)
  stk:raw_push(">")
  count_sel = count_sel + 1
end
function make_script_sel(stk, id, script_item_id, script_item_param)
  if script_item_id == nil then
    return
  end
  local excel = bo2.gv_text:find(script_item_id)
  if excel == nil then
    return
  end
  local script_item_text = excel.text
  if script_item_param ~= nil and script_item_param.empty ~= true then
    script_item_text = sys.mtf_merge(script_item_param, script_item_text)
  end
  local icon = 3
  local excel_x = bo2.gv_xtext:find(script_item_id)
  if excel_x ~= nil and excel_x.icon > 0 then
    icon = excel_x.icon
  end
  local handson_sel_name = ui_handson_teach.on_active_quest_talk(script_item_id)
  if handson_sel_name == nil then
    handson_sel_name = 3
  end
  build_sel(stk, bo2.eTalkSel_Script, id, script_item_text, icon, handson_sel_name, script_item_id)
end
function make_sel(stk, sel, id, txt, icon, handson_sel_name)
  if txt == nil then
    return
  end
  if txt.empty then
    return
  end
  build_sel(stk, sel, id, txt, icon, handson_sel_name)
  if sel == bo2.eTalkSel_QueryQuest or sel == bo2.eTalkSel_EndQuest or sel == bo2.eTalkSel_BegQuest then
    if first_sel == nil then
      first_sel = sys.format("%d,%d,,,,%s", kind, id, text)
    end
  elseif sel ~= bo2.eTalkSel_QuestCollect or first_sel == nil then
  end
end
function make_excel_sel(stk, sel, id, tb, icon_id)
  if id == 0 then
    return
  end
  local excel = tb:find(id)
  if excel == nil then
    return
  end
  local icon = icon_id
  if icon == icon_npc_func and excel.icon_id ~= 0 then
    icon = excel.icon_id
  end
  local handson_sel_name = ui_handson_teach.on_active_quest_talk(id)
  build_sel(stk, sel, id, excel.text, icon, handson_sel_name)
end
function make_end_talk_sel(stk)
  build_sel(stk, bo2.eTalkSel_EndTalk, 0, ui.get_text("npcfunc|talk_ending"))
end
function may_make_talk(query_kind, excel, script_chat, sript_items, business_id)
  local flag = false
  if excel == nil then
    return flag
  end
  local query
  if query_kind == bo2.eQuestObj_QueryNpc or query_kind == bo2.eQuestObj_QueryStill then
    query = excel.quest_reqquery
  end
  local medium = excel.quest_medium
  local id = excel.id
  if ui_quest.ui_reputation.is_reputation_npc(id) then
    flag = true
  else
    if query ~= nil then
      for i = 0, query.size - 1 do
        flag = true
      end
    end
    if medium ~= nil then
      for i = 0, medium.size - 1 do
        flag = true
      end
    end
  end
  local business = bo2.gv_npc_business:find(business_id)
  if business ~= nil then
    flag = true
  end
  if script_items ~= nil then
    for i = 0, script_items.size - 1 do
      flag = true
    end
  end
  return flag
end
function make_talk(query_kind, excel, script_chat, script_items, business_id, talk_level, script_chat_param, obj)
  first_sel = nil
  count_sel = 0
  if excel == nil then
    return false
  end
  ui_handson_teach.on_init_talk()
  w_view.text = L("")
  w_view_title.text = L("")
  w_talk_view.text = L("")
  local stk = sys.mtf_stack()
  stk:raw_format("<dc:FFFFFF>")
  if (query_kind == bo2.eQuestObj_QueryNpc or query_kind == bo2.eQuestObj_NpcCollect) and (script_chat == nil or script_chat == 0) then
    script_chat = excel.chat
  end
  local script_chat_txt = ""
  local script_chat_line = bo2.gv_text:find(script_chat)
  if script_chat_line ~= nil then
    script_chat_txt = script_chat_line.text
  end
  if script_chat_param ~= nil and script_chat_param.empty ~= true then
    script_chat_txt = sys.mtf_merge(script_chat_param, script_chat_txt)
  end
  local show_chat = false
  if script_chat_txt ~= "" then
    local talk_stk = sys.mtf_stack()
    talk_stk:raw_format("<dc:FFFFFF>")
    talk_stk:raw_push(script_chat_txt)
    w_talk_view.mtf = talk_stk.text
    w_talk_view.slider_y.scroll = 1
    show_chat = true
    if query_kind == bo2.eQuestObj_QueryNpc then
      if sys.check(obj) and obj.name.empty ~= true then
        w_view_title.text = sys.format(L("%s:"), obj.name)
      elseif excel.name.empty ~= true then
        w_view_title.text = sys.format(L("%s:"), excel.name)
      end
    end
  end
  if talk_level ~= nil and talk_level > 1 then
  else
    local query, query1
    if query_kind == bo2.eQuestObj_QueryNpc or query_kind == bo2.eQuestObj_QueryStill then
      query = excel.quest_reqquery
      if query_kind == bo2.eQuestObj_QueryNpc then
        query1 = excel.quest_collect
      end
    end
    local medium = excel.quest_medium
    local id = excel.id
    if ui_quest.ui_reputation.is_reputation_npc(id) and ui_quest.ui_reputation.may_show(medium, query_kind, id) then
      ui_quest.ui_reputation.show(medium, query_kind, id)
      return true
    else
      if query ~= nil then
        for i = 0, query.size - 1 do
          make_sel_query(stk, query[i], query_kind, id)
        end
      end
      if query1 ~= nil then
        for i = 0, query1.size - 1 do
          make_sel_query(stk, query1[i], bo2.eQuestObj_NpcCollect, id)
        end
      end
      if medium ~= nil then
        for i = 0, medium.size - 1 do
          make_sel_medium(stk, medium[i], query_kind, id)
        end
      end
    end
    local DeliverIdDetect = function(id)
      if id >= bo2.eNpcFunc_Deliver1 or id <= bo2.eNpcFunc_DeliverMAX then
        local excel = bo2.gv_npc_func:find(id)
        if excel ~= nil and excel.datas.size == 2 and sys.check(bo2.player) then
          local player_lv = bo2.player:get_atb(bo2.eAtb_Level)
          if player_lv < excel.datas[1] then
            return false
          end
        end
      end
      return true
    end
    local check_level_quest = function(id)
      if id >= bo2.eNpcFunc_Null and id <= bo2.eNpcFunc_Max then
        local excel = bo2.gv_npc_func:find(id)
        if excel ~= nil then
          if sys.check(bo2.player) and excel.required_level > 0 then
            local player_lv = bo2.player:get_atb(bo2.eAtb_Level)
            if player_lv < excel.required_level then
              return false
            end
          end
          if 0 < excel.v_required_quests.size then
            local size_quest = excel.v_required_quests.size
            for i = 0, size_quest - 1 do
              if not ui.quest_find_c(excel.v_required_quests[i]) then
                return false
              end
            end
          end
        end
      end
      return true
    end
    local business = bo2.gv_npc_business:find(business_id)
    if business ~= nil then
      local func_sels = business.func_sels
      for i = 0, func_sels.size - 1 do
        if DeliverIdDetect(func_sels[i]) and check_level_quest(func_sels[i]) then
          make_excel_sel(stk, bo2.eTalkSel_Func, func_sels[i], bo2.gv_npc_func, icon_npc_func)
        end
      end
      local shop_id = business.shop_id
      for j = 0, business.shop_id.size - 1 do
        make_excel_sel(stk, bo2.eTalkSel_Shop, business.shop_id[j], bo2.gv_npc_shop, icon_npc_shop)
      end
      local help_sels = business.help_sels
      for i = 0, help_sels.size - 1 do
        make_excel_sel(stk, bo2.eTalkSel_Help, help_sels[i], bo2.gv_npc_help, icon_npc_func)
      end
    end
  end
  if script_items ~= nil then
    for i = 0, script_items.size - 1 do
      local script_item = script_items:get(i)
      local script_item_id = script_item:get(packet.key.talk_dlg_content).v_int
      local script_item_param = script_item:get(packet.key.talk_dlg_param)
      make_script_sel(stk, i, script_item_id, script_item_param)
    end
  end
  if count_sel == 1 then
    make_end_talk_sel(stk)
  end
  w_view.mtf = stk.text
  if show_chat == true or 0 < w_view.item_count then
    w_talk.visible = true
  end
  if query_kind == bo2.eQuestObj_QueryNpc then
    if sys.check(obj) and obj.name.empty ~= true then
      w_view_title.text = sys.format(L("%s:"), obj.name)
    elseif excel.name.empty ~= true then
      w_view_title.text = sys.format(L("%s:"), excel.name)
    end
  end
  local view_slider_y = w_view.slider_y
  view_slider_y.scroll = 1
  view_slider_y.visible = true
  local view_talk_slider = w_talk_view.slider_y
  view_talk_slider.scroll = 1
  view_talk_slider.visible = true
  ui_npcfunc.ui_talk.wTalk:tune_y(L("rb_talk"))
  if ui_npcfunc.ui_talk.wTalk.dy > 100 then
    ui_npcfunc.ui_talk.wTalk.dy = 100
  elseif ui_npcfunc.ui_talk.wTalk.dy < 60 then
    ui_npcfunc.ui_talk.wTalk.dy = 60
  end
  local function on_time_go()
    local set_slider_y = function(silder)
      if sys.check(silder) then
        local btn_move = silder:search("btn_move")
        if sys.check(btn_move) then
          silder.visible = btn_move.visible
          silder.scroll = 0
        end
      end
    end
    set_slider_y(view_slider_y)
    set_slider_y(view_talk_slider)
  end
  bo2.AddTimeEvent(1, on_time_go)
  if count_sel == 1 and first_sel ~= nil then
    on_mtf_sel(w_view, first_sel)
  end
end
function on_open_talk(cmd, data)
  local script_chat = data:get(packet.key.talk_dlg_content).v_int
  local script_chat_param = data:get(packet.key.talk_dlg_param)
  local script_items = data:get(packet.key.talk_dlg_item)
  local talk_level = 0
  if data:has(packet.key.talk_kind) then
    talk_level = data:get(packet.key.talk_kind).v_int
  end
  local excel
  local query_kind = 0
  talk_quest_sel_num = 0
  local item_id = data:get(packet.key.item_excelid).v_int
  if item_id ~= 0 then
    local excel = ui.item_get_excel(item_id)
    if excel == nil then
      return
    end
    local business_id = data:get(packet.key.item_key1).v_int
    make_talk(bo2.eQuestObj_QuestItem, excel, script_chat, script_items, business_id, talk_level, script_chat_param)
  else
    do
      local obj_id = data:get(packet.key.talk_scnobj_id).v_int
      local obj = bo2.scn:get_scn_obj(obj_id)
      if obj == nil then
        return
      end
      local kind = obj.kind
      local excel = obj.excel
      if excel == nil then
        return
      end
      w_view.var:set("cha_id", excel.id)
      if kind == bo2.eScnObjKind_Npc then
        do
          local open_window = true
          local process_deliver = function(sel)
            local d = sys.variant()
            d:set("kind", bo2.eTalkSel_Func)
            d:set("id", 127)
            bo2.send_wrap(packet.eSTC_Fake_talk_sel, d)
            local function send()
              ui.log("send")
              local v = sys.variant()
              v:set(packet.key.deliver_id, sel)
              v:set(L("flag"), 1)
              bo2.send_variant(packet.eCTS_UI_Deliver, v)
            end
            bo2.AddTimeEvent(1, send)
          end
          local store_mark_scn = ui_map.get_store_scn_id()
          local function Process_business()
            local business_id = excel.business
            local business = bo2.gv_npc_business:find(business_id)
            if business == nil then
              return false
            end
            local func_sels = business.func_sels
            for i = 0, func_sels.size - 1 do
              local id = func_sels[i]
              if id == 127 then
                local func_excel = bo2.gv_npc_func:find(id)
                if sys.check(func_excel) ~= true then
                  return false
                end
                local size_data = func_excel.datas.size
                for m = 0, size_data - 1 do
                  local m_data = func_excel.datas[m]
                  local deliver_excel = bo2.gv_deliver_list:find(m_data)
                  if sys.check(deliver_excel) and deliver_excel.scn_id == store_mark_scn then
                    process_deliver(deliver_excel.id)
                    return true
                  end
                end
              end
            end
            return false
          end
          if store_mark_scn ~= nil and store_mark_scn ~= 0 then
            open_window = not Process_business()
          end
          local function open_talk_window()
            local bTalk_Open = true
            if w_talk.visible == true then
              bTalk_Open = false
            end
            make_talk(bo2.eQuestObj_QueryNpc, excel, script_chat, script_items, excel.business, talk_level, script_chat_param, obj)
            if w_talk.visible == true then
              fader_vis(true, obj, bTalk_Open)
            end
          end
          if open_window then
            open_talk_window()
          end
        end
      elseif kind == bo2.eScnObjKind_Still then
        make_talk(bo2.eQuestObj_QueryStill, excel, script_chat, script_items, excel.business, talk_level, script_chat_param)
      end
      play_talk_sound(obj)
    end
  end
  talk_quest_sel_num = 0
end
function on_mtf_sel(box, val)
  local s_kind, s_id, s_icon, s_handson, s_textid, s_text = val:splitn(",", 6)
  local kind = s_kind.v_int
  local id = s_id.v_int
  g_talk_sel_id = id
  if s_textid ~= nil and s_textid.size > 0 then
    local textid = s_textid.v_int
    ui_handson_teach.on_vis_box_popo(true, textid)
  end
  function send_sel()
    local d = sys.variant()
    d:set("kind", kind)
    d:set("id", id)
    bo2.send_wrap(packet.eSTC_Fake_talk_sel, d)
  end
  local close_now = true
  local mtf_text = sys.format(s_text)
  if kind == bo2.eTalkSel_QueryQuest then
    ui_quest.ui_quest_talk.show(mtf_text, kind, id, w_view.var:get("cha_id").v_int)
  elseif kind == bo2.eTalkSel_QuestCollect then
    send_sel()
  elseif kind == bo2.eTalkSel_EndQuest then
    ui_quest.ui_complete.show_complete(bo2.gv_quest_list:find(id))
  elseif kind == bo2.eTalkSel_BegQuest then
    ui_quest.quest_show(bo2.gv_quest_list:find(id))
  elseif kind == bo2.eTalkSel_NoticeQuest then
  elseif kind == bo2.eTalkSel_Script then
    send_sel()
    close_now = false
  elseif kind == bo2.eTalkSel_Func then
    if id == bo2.eNpcFunc_InputUserKey then
      ui_widget.ui_msg_box.show_common({
        text = ui.get_text("npcfunc|user_key"),
        input = "",
        limit = 20,
        callback = function(msg)
          if msg.result == 0 then
            return
          end
          local v = sys.variant()
          v:set(packet.key.cmn_id, msg.input)
          bo2.send_variant(packet.eCTS_UI_PointReward, v)
        end,
        tune_window = function(msg)
          local window = msg.window
          local input = window:search("frm_input")
          input.dx = 280
          input = input:search("box_input")
          input.alpha_digit = true
          input.upper_case = true
          input.ime_able = false
          input.focus = false
          input.focus = true
          window.dx = 320
          window:tune_y("rv_text")
          if window.dy < 160 then
            window.dy = 160
          end
          local r = window:search("rv_text")
          r.size = r.extent
          r.dock = "pin_xy"
        end
      })
    else
      send_sel()
    end
  elseif kind == bo2.eTalkSel_Shop then
    send_sel()
  elseif kind == bo2.eTalkSel_Help then
  elseif kind == bo2.eTalkSel_Chest then
    send_sel()
  elseif kind == bo2.eTalkSel_EndTalk then
    w_talk.visible = false
    return
  end
  close_talk(close_now)
end
function fader_vis(vis, obj, alway_open)
  if vis then
    g_close_talk = false
    if alway_open == false and ui_npcfunc.ui_talk.w_talk.visible == true then
      return
    end
    if sys.check(obj) ~= true or sys.check(obj.excel) ~= true or obj.excel.fight_body == 5 then
      return
    end
    local obj_excel = obj.excel
    if obj_excel.business == 0 and obj_excel.chat == 0 then
      return
    end
    ui_main.ShowUI(false, 100)
    bo2.scn:SetCameraControl(5001, obj.sel_handle)
    obj:OnTalkSetIdleNpcAngle(false)
    bo2.SetShowPlayer(false)
  else
    g_close_talk = true
    if sys.check(bo2.player) then
      bo2.player:OnTalkSetIdleNpcAngle(true)
    end
    bo2.scn:SetCameraControl(5002)
    ui_portrait.w_target_show.priority = 101
    bo2.SetShowPlayer(true)
    if g_disable_fader_show ~= true then
      ui_main.ShowUI(true, 80)
      local on_set_alpha = function()
        ui_portrait.w_target_show.alpha_solo = false
      end
      bo2.AddTimeEvent(2, on_set_alpha)
    end
  end
end
function on_mouse_close_talk(w, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    on_talk_visible(ui_npcfunc.ui_talk.w_talk, false)
  end
end
function on_click_close_talk()
  ui_npcfunc.ui_talk.w_talk.visible = false
end
function on_talk_visible(talk, vis)
  if not vis then
    fader_vis(vis)
    ui_widget.esc_stk_pop(talk)
    send_close()
    if sys.check(ui_handson_teach) then
      ui_handson_teach.on_close_talk()
    end
    return
  end
  on_visible_disable_window()
  ui_npcfunc.ui_shop.close_shop()
  local function move_to_head()
    if sys.check(talk) ~= true then
      return
    end
    ui_widget.esc_stk_push(talk)
    talk:move_to_head()
  end
  bo2.AddTimeEvent(1, move_to_head)
end
function send_close()
  if w_talk.svar.server_close_talk then
    return
  end
  local d = sys.variant()
  d:set("kind", bo2.eTalkSel_Null)
  d:set("id", 0)
  bo2.send_wrap(packet.eSTC_Fake_talk_sel, d)
end
function on_view_init(box)
  box.var:set("on_mtf_sel", "ui_npcfunc.ui_talk.on_mtf_sel")
end
function close_top(w)
  w_talk.svar.server_close_talk = true
  w.visible = false
  w_talk.svar.server_close_talk = false
end
function on_real_close_talk()
  w_talk.svar.server_close_talk = true
  w_talk.visible = false
  w_talk.svar.server_close_talk = false
end
function close_talk(bCloseNow)
  if bCloseNow == true then
    on_real_close_talk()
  else
    g_close_talk = true
    local function on_time_close_talk()
      if g_close_talk then
        on_real_close_talk()
      end
    end
    bo2.AddTimeEvent(g_close_max_tick, on_time_close_talk)
  end
end
function on_close_talk(cmd, data)
  svr_script_ui_close()
  local call_back_close = true
  local function fn_close(bClose)
    if bClose ~= true and g_close_talk == false then
      return
    end
    on_real_close_talk()
    ui_quest.close_talk()
  end
  if data:has(packet.key.cmn_index) then
    g_close_talk = true
    call_back_close = false
    local on_clear_view_text = function()
      w_view.mtf = ""
    end
    on_clear_view_text()
    bo2.AddTimeEvent(g_server_close_max_tick, fn_close)
  else
    fn_close(call_back_close)
    if sys.check(talk_obj) then
      talk_obj:playsound(bo2.eSE_Talk_CloseTalk)
      talk_obj = nil
    end
  end
end
function svr_script_ui_close()
  ui_guildfarm.seed_info.w_main.visible = false
  ui_guildfarm.sell_products.w_main.visible = false
  ui_guildfarm.sell_products.w_sell_confirm.visible = false
  ui_guild_mod.ui_build_res.close_win()
  ui_guild_mod.ui_create_scn_res.close_win()
  if ui_cloned_battle.is_friend_assist_knight then
    ui_cloned_battle.w_main_friend_assist.visible = false
  end
  ui_quest.ui_quest_collect.close_win()
  ui_sociality.ui_sworn.close_win()
  ui_sociality.ui_marry.close_win()
  ui_sociality.ui_remove_relation.close_win()
end
function on_talk_alias_over(cmd, data)
  local obj_id = data:get(packet.key.talk_scnobj_id).v_int
  local obj = bo2.scn:get_scn_obj(obj_id)
  talk_quest_sel_num = 0
  if obj == nil then
    return
  end
  local excel = obj.excel
  w_view.var:set("cha_id", excel.id)
  if may_make_talk(bo2.eQuestObj_QueryNpc, nil, nil, excel.business) ~= false then
    make_talk(bo2.eQuestObj_QueryNpc, excel, nil, nil, excel.business)
  end
  if count_sel == 1 and first_sel ~= nil then
    on_mtf_sel(w_view, first_sel)
  end
  play_talk_sound(obj)
  talk_quest_sel_num = 0
end
function On_Send_Talk(cmd, data)
  local h = data:get("handle").v_int
  local tgt_talk = bo2.scn:get_scn_obj(h)
  if tgt_talk ~= nil then
    local tgt_excel = tgt_talk.excel
    if tgt_talk.kind == bo2.eScnObjKind_Still then
      local use_list_line = bo2.gv_use_list:find(tgt_excel.use_id)
      if use_list_line and use_list_line.model == bo2.eUseMod_ShowTextBook then
        local arr_par = tgt_excel.use_par
        if arr_par.size == 0 then
          ui.log("ERROR!!!!PLEASE INPUT use_par!!!!")
        end
        ui_text_book.show_text_book(arr_par[0])
        return
      end
    end
  end
  if talk_obj == nil then
    bo2.send_talk(h)
  else
    local cha = bo2.scn:get_scn_obj(h)
    if cha ~= talk_obj then
      bo2.send_talk(h)
    elseif w_talk.visible == false then
      bo2.send_talk(h)
    end
  end
end
function on_choose_career(cmd, data)
  ui_personal.ui_select_pro.show(true)
end
local sig_name = "ui_npcfunc.ui_talk:on_signal"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_Talk_CTS, On_Send_Talk, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_OpenTalk, on_open_talk, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_CloseTalk, on_close_talk, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_TalkAlias, on_talk_alias_over, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_ChooseCareer, on_choose_career, sig_name)
