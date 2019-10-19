local c_t_color_correct = L("FF00FF00")
local c_t_color_wrong = L("FFFF0000")
local c_t_notify_time = 200000
local c_t_disappear_time = 1500
local c_t_end_time = 3000
local c_t_error_time = 2500
local c_t_notify_index = 1103
local c_t_notify_end_index = 1105
local c_t_disappear_index = 1106
local c_t_error_index = 1107
local g_skill_baby_teach, g_skill_baby_teach_chain
local g_baby_teach_data = {}
local g_last_teach_text = {}
local g_teach_finish_sound = 502
local g_default_combat_id = 6
function on_init()
  g_baby_teach_data = {}
  g_baby_teach_data.valid = false
  g_last_teach_text = {}
  set_unvalid_teach()
end
function load_mb()
  if g_skill_baby_teach == nil then
    g_skill_baby_teach = sys.load_table("$mb/skill/skill_baby_teaching.xml")
  end
  if g_skill_baby_teach_chain == nil then
    g_skill_baby_teach_chain = sys.load_table("$mb/skill/skill_baby_teaching_chain.xml")
  end
end
function table_size(tab)
  if tab ~= nil then
    return tab.size
  end
  return 0
end
function find_table(tab, i)
  if tab ~= nil then
    return tab:find(i)
  end
  return nil
end
function get_table(tab, i)
  if tab ~= nil then
    return tab:get(i)
  end
  return nil
end
local sig = "ui_handson_teach.skill_baby_teaching"
local sig_info = "ui_handson_teach:on_targe_info"
local sig_space = "ui_handson_teach:on_targe_space"
local sig_combat = "ui_handson_teach.combat_baby_teaching"
function set_unvalid_teach()
  g_baby_teach_data.valid = false
  ui_packet.game_recv_signal_remove(packet.eSTC_ScnObj_Skill, sig)
  ui_packet.game_recv_signal_remove(packet.eSTC_ScnObj_SkillSeriesId, sig_combat)
  local obj = bo2.player
  if sys.check(obj) then
    obj:remove_on_scnmsg(bo2.scnmsg_set_target, sig_info)
  end
  local scn = bo2.scn
  if sys.check(scn) then
    local function on_each_npc(npc)
      npc:remove_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_SpaceType, sig_space)
    end
    scn:ForEachScnObj(bo2.eScnObjKind_Npc, on_each_npc)
  end
  note_insert(L(" "), nil, c_t_notify_index, c_t_notify_time, c_t_notify_index)
end
function redo_baby_teaching()
  local redo = true
  if g_baby_teach_data.valid ~= true then
    redo = false
  end
  set_unvalid_teach()
  if redo ~= true then
    return
  end
  g_baby_teach_data.valid = true
  g_baby_teach_data.index = g_baby_teach_data.excel.redo_id
  process_teach_event()
end
function get_combat_info_data(info, ms_id, i, type)
  if sys.check(info) ~= true or sys.check(info.excel) ~= true then
    return false
  end
  if info.kind ~= bo2.eShortcut_LianZhao then
    return false
  end
  local id = info.excel.id
  if id ~= ms_id then
    return false
  end
  local index = 3000 + i - 100
  if i >= 112 then
    index = 3100 + i - 112
  end
  local op = ui_setting.ui_input.op_ids[index]
  if op == nil then
    ui.log("index" .. index)
    return false
  end
  local hk = op.hotkey
  local mtf = {}
  mtf.key = sys.format(L("<key:%s,0,1>"), hk:get_cell(0).text)
  if ui_lianzhao.lianzhao[id] then
    mtf.skill_name = ui_lianzhao.lianzhao[id].desc
  end
  return true, mtf
end
function get_info_data(info, ms_id, i, type)
  if sys.check(info) ~= true or sys.check(info.excel) ~= true then
    return false
  end
  if info.kind ~= bo2.eShortcut_Skill then
    return false
  end
  local id = info.excel.id
  if id ~= ms_id then
    return false
  end
  local index = 3000 + i - 100
  if i >= 112 then
    index = 3100 + i - 112
  end
  local op = ui_setting.ui_input.op_ids[index]
  if op == nil then
    ui.log("index" .. index)
    return false
  end
  local hk = op.hotkey
  local mtf = {}
  mtf.key = sys.format(L("<key:%s,0,1>"), hk:get_cell(0).text)
  local skill_name = bo2.gv_skill_group:find(ms_id)
  mtf.skill_name = sys.format(L("<skill_small_icon:%d>%s"), ms_id, skill_name.name)
  return true, mtf
end
local function check_teach_valid()
  if g_baby_teach_data.valid == false then
    return false
  end
  return true
end
function event_bady_teaching_skill(teach_excel, type)
  local function on_packet_skill_baby_teaching(cmd, data)
    if sys.check(data) ~= true then
      return
    end
    local idx = data:get(packet.key.cmn_id).v_int
    local cmn_type = data:get(packet.key.cmn_type).v_int
    if idx == 0 then
      return
    end
    if cmn_type ~= 2 then
      return
    end
    if g_baby_teach_data.valid == false then
      return
    end
    if sys.check(teach_excel) ~= true then
      return
    end
    local function process_rst(rst)
      if g_last_teach_text.text ~= nil then
        local color = c_t_color_correct
        if rst ~= true then
          color = c_t_color_wrong
        end
        note_insert(g_last_teach_text.text, color, c_t_disappear_index, c_t_disappear_time, c_t_disappear_index)
        if rst ~= true and g_last_teach_text.excel ~= nil and g_last_teach_text.excel.error_text_id.size > 0 then
          local n_size = g_last_teach_text.excel.error_text_id.size
          if n_size > g_last_teach_text.error_rst then
            local text_id = g_last_teach_text.excel.error_text_id[g_last_teach_text.error_rst]
            local new_notify_text = bo2.gv_text:find(text_id)
            if sys.check(new_notify_text) then
              note_insert(new_notify_text.text, c_t_color_wrong, c_t_error_index, c_t_error_time, c_t_error_index)
              return
            end
          end
        end
        g_last_teach_text.text = nil
        g_last_teach_text.excel = nil
      end
    end
    local function on_wrong_chain()
      process_rst(false)
      redo_baby_teaching()
    end
    for s = 0, teach_excel.v_skill_id.size - 1 do
      local s_id = teach_excel.v_skill_id[s]
      if s_id == idx then
        do
          local function on_right_chain()
            process_rst(true)
            g_baby_teach_data.index = g_baby_teach_data.index + 1
            process_teach_event()
          end
          if type == 0 then
            on_right_chain()
            return
          elseif type == 1 or type == 2 then
            local scn = bo2.scn
            if sys.check(scn) ~= true then
              break
            end
            local npc = bo2.SearchNpcByChaListID(teach_excel.target_id)
            if npc == nil then
              break
            else
              local function on_update_target_space(npc)
                local t = npc:get_flag_objmem(bo2.eFlagObjMemory_SpaceType)
                if t == teach_excel.status then
                  on_right_chain()
                else
                  g_last_teach_text.error_rst = 1
                  on_wrong_chain()
                end
                if type == 1 then
                  npc:remove_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_SpaceType, sig_space)
                end
              end
              if type == 1 then
                npc:insert_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_SpaceType, on_update_target_space, sig_space)
              else
                on_update_target_space(npc)
              end
              return
            end
          end
        end
      end
    end
    on_wrong_chain()
  end
  if check_teach_valid() ~= true then
    return
  end
  local g_text = bo2.gv_text:find(teach_excel.text_id)
  if sys.check(g_text) ~= true then
    return
  end
  local mtf = {}
  local function fix_mtf(ms_id)
    local max_slot = 122
    for i = 100, max_slot do
      local info = ui.shortcut_get(i)
      local rst = false
      rst, mtf = get_info_data(info, ms_id, i, type)
      if rst == true then
        return true, mtf
      end
    end
    return false, nil
  end
  for s = 0, teach_excel.v_skill_id.size - 1 do
    local ms_id = teach_excel.v_skill_id[s]
    local rst = false
    rst, mtf = fix_mtf(ms_id)
    if rst == true then
      local info = ui.skill_find(ms_id)
      if sys.check(info) and 0 < info.cooldown then
        local on_redo_event = function()
          redo_baby_teaching()
        end
        ui.log("info.cooldown = " .. info.cooldown)
        bo2.AddTimeEvent(info.cooldown * 25, on_redo_event)
        return
      end
      break
    end
  end
  local merge_text = ui_widget.merge_mtf(mtf, g_text.text)
  g_last_teach_text.text = merge_text
  g_last_teach_text.excel = teach_excel
  g_last_teach_text.error_rst = 0
  note_insert(merge_text, nil, c_t_notify_index, c_t_notify_time, c_t_notify_index)
  ui_packet.game_recv_signal_insert(packet.eSTC_ScnObj_Skill, on_packet_skill_baby_teaching, sig)
end
function event_bady_teaching_combat(teach_excel, type)
  local function on_packet_combo_skill_baby_teaching(cmd, data)
    if sys.check(data) ~= true then
      return
    end
    local idx = data:get(L("id")).v_int
    if idx == 0 then
      return
    end
    if check_teach_valid() == false then
      return
    end
    if sys.check(teach_excel) ~= true then
      return
    end
    local on_wrong_chain = function()
      process_rst(false)
      redo_baby_teaching()
    end
    local function process_rst(rst)
      if g_last_teach_text.text ~= nil then
        local color = c_t_color_correct
        if rst ~= true then
          color = c_t_color_wrong
        end
        note_insert(g_last_teach_text.text, color, c_t_disappear_index, c_t_disappear_time, c_t_disappear_index)
        if rst ~= true and g_last_teach_text.excel ~= nil and g_last_teach_text.excel.error_text_id.size > 0 then
          local n_size = g_last_teach_text.excel.error_text_id.size
          if n_size > g_last_teach_text.error_rst then
            local text_id = g_last_teach_text.excel.error_text_id[g_last_teach_text.error_rst]
            local new_notify_text = bo2.gv_text:find(text_id)
            if sys.check(new_notify_text) then
              note_insert(new_notify_text.text, c_t_color_wrong, c_t_error_index, c_t_error_time, c_t_error_index)
              return
            end
          end
        end
        g_last_teach_text.text = nil
        g_last_teach_text.excel = nil
      end
    end
    for s = 0, teach_excel.v_skill_id.size - 1 do
      local s_id = teach_excel.v_skill_id[s]
      if s_id == idx then
        local function on_right_chain()
          process_rst(true)
          g_baby_teach_data.index = g_baby_teach_data.index + 1
          process_teach_event()
        end
        if type == 4 then
          on_right_chain()
          return
        end
      end
    end
    on_wrong_chain()
  end
  if check_teach_valid() ~= true then
    return
  end
  local g_text = bo2.gv_text:find(teach_excel.text_id)
  if sys.check(g_text) ~= true then
    return
  end
  local mtf = {}
  function fix_mtf(ms_id)
    local max_slot = 122
    for i = 100, max_slot do
      local info = ui.shortcut_get(i)
      local rst = false
      rst, mtf = get_combat_info_data(info, ms_id, i, type)
      if rst == true then
        return true, mtf
      end
    end
    return false, nil
  end
  for s = 0, teach_excel.v_skill_id.size - 1 do
    local ms_id = teach_excel.v_skill_id[s]
    local rst = false
    rst, mtf = fix_mtf(ms_id)
    if rst == true then
      break
    end
  end
  local merge_text = ui_widget.merge_mtf(mtf, g_text.text)
  g_last_teach_text.text = merge_text
  g_last_teach_text.excel = teach_excel
  g_last_teach_text.error_rst = 0
  note_insert(merge_text, nil, c_t_notify_index, c_t_notify_time, c_t_notify_index)
  ui_packet.game_recv_signal_insert(packet.eSTC_ScnObj_SkillSeriesId, on_packet_combo_skill_baby_teaching, sig_combat)
end
function event_baby_teach_head_text(teach_excel)
  local obj = bo2.player
  if sys.check(obj) ~= true then
    return
  end
  local scn = bo2.scn
  local npc_id = teach_excel.target_id
  local _handson_teach_text = sys.format(L("<handson:0,4,0,%d>"), teach_excel.text_id)
  local iHandle = scn:SetNpcHandsonTips(npc_id, _handson_teach_text)
  local function on_targe_info(new_obj)
    if sys.check(new_obj) ~= true then
      return
    end
    if sys.check(scn) ~= true then
      return
    end
    if scn ~= bo2.scn then
      return
    end
    if sys.check(obj) ~= true then
      return
    end
    if new_obj.target_handle == iHandle then
      scn:UnValidNpcHandsonTips(iHandle)
      g_baby_teach_data.index = g_baby_teach_data.index + 1
      process_teach_event()
      obj:remove_on_scnmsg(bo2.scnmsg_set_target, sig_info)
    end
  end
  obj:insert_on_scnmsg(bo2.scnmsg_set_target, on_targe_info, sig_info)
end
function process_teach_event()
  local tab = g_baby_teach_data
  if tab.valid ~= true then
    return
  end
  local excel = tab.excel
  if tab.index >= excel.teach_id.size then
    if tab.index == excel.teach_id.size then
      local msg = bo2.gv_text:find(excel.finish_text)
      if sys.check(msg) then
        note_insert(msg.text, L("FF00FF00"), c_t_notify_end_index, c_t_end_time, c_t_notify_end_index)
        bo2.PlaySound2D(g_teach_finish_sound, false)
      end
    end
    set_unvalid_teach()
    return
  end
  local excel_id = tab.excel.teach_id[tab.index]
  local teach_excel = find_table(g_skill_baby_teach, excel_id)
  if teach_excel == nil then
    ui.log([[

..]] .. sys.stack_trace())
    return
  end
  local type = teach_excel.type
  if type == 0 or type == 1 or type == 2 then
    event_bady_teaching_skill(teach_excel, type)
  elseif type == 3 then
    event_baby_teach_head_text(teach_excel)
  elseif type == 4 then
    event_bady_teaching_combat(teach_excel, type)
  end
end
function on_enable_teach(excel)
  g_baby_teach_data = {}
  g_baby_teach_data.valid = true
  g_baby_teach_data.excel = excel
  g_baby_teach_data.index = 0
  process_teach_event()
end
function enable_skill_baby_teaching(act, career)
  local size = table_size(g_skill_baby_teach_chain)
  local function process_excel(excel)
    if sys.check(excel) ~= true then
      return false
    end
    if excel.act ~= act then
      return false
    end
    for m = 0, excel.career.size - 1 do
      local c_value = excel.career[m]
      if c_value == career then
        on_enable_teach(excel)
        return true
      end
    end
    return false
  end
  for i = 0, size - 1 do
    local excel = get_table(g_skill_baby_teach_chain, i)
    if process_excel(excel) == true then
      return
    end
  end
end
function on_skill_baby_teaching()
  on_init()
  load_mb()
  local on_time = function()
    local scn_table = {_begin = 370, _end = 377}
    local scn = bo2.scn
    if sys.check(scn) ~= true then
      return
    end
    local obj = bo2.player
    if sys.check(obj) ~= true then
      return
    end
    local excel = bo2.scn.excel.id
    if excel >= scn_table._begin and excel <= scn_table._end then
      if ui_warrior_arena.is_enable_teach_mode() ~= true then
        return
      end
      local act_param = ui_warrior_arena.get_act()
      local c_career = obj:get_flag_int8(bo2.ePlayerFlagInt8_TeachSkillCareer)
      enable_skill_baby_teaching(act_param, c_career)
    end
  end
  bo2.AddTimeEvent(5, on_time)
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_skill_baby_teaching, "ui_handson_teach.on_skill_baby_teaching")
