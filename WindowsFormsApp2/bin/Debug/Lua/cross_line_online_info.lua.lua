g_award_table = nil
function on_init_desc()
  g_vis_fate_desc = false
  g_vis_cl_desc = false
end
on_init_desc()
local set_item_visible = function(item_name, vis)
  local item = ui_cross_line.w_online_items:search(item_name)
  if sys.check(item) ~= true then
    return
  end
  item.visible = vis
end
function set_data_visible(type, vis)
  if type == 0 then
    set_item_visible("desc_sep", vis)
    set_item_visible("desc_offline", vis)
    set_item_visible("fight_exp", vis)
    set_item_visible("kill_exp", vis)
    set_item_visible("total_exp", vis)
    set_item_visible("remain_times", vis)
  else
    set_item_visible("desc_fate", vis)
  end
end
function on_self_enter_finish()
  on_init_desc()
end
function on_add_fate_desc(data)
  set_data_visible(0, g_vis_cl_desc)
  g_vis_fate_desc = true
  set_data_visible(1, true)
  ui_cross_line.w_online_info_main.visible = true
  local _modify_data = {}
  _modify_data.iRank = data[packet.key.fate_rank_award]
  local function modify_rb_text(p_name)
    local parent_item = ui_cross_line.w_online_items:search(p_name)
    if sys.check(parent_item) then
      local mtf_item = parent_item:search("rb_item")
      if sys.check(mtf_item) then
        if _modify_data.iRank == 0 then
          p_name = L("desc_fate_no_rank")
          parent_item.dy = 58
        else
          parent_item.dy = 50
        end
        local get_text_name = sys.format(L("fate|%s"), p_name)
        mtf_item.mtf = ui_widget.merge_mtf(_modify_data, ui.get_text(get_text_name))
      end
    end
  end
  modify_rb_text(L("desc_fate"))
  ui_cross_line.w_online_info_main.dy = 220
end
function on_handle_online_info(cmd, data)
  if data:has(packet.key.fate_rank_award) == true then
    on_add_fate_desc(data)
    return
  end
  local _modify_data = {}
  local set_data = function(data)
    if data == nil then
      return 0
    end
    return data
  end
  _modify_data.battle_times = data[packet.key.battle_player_count]
  _modify_data.battle_times = set_data(_modify_data.battle_times)
  _modify_data.kill_count = data[packet.key.battle_kill_count]
  _modify_data.kill_count = set_data(_modify_data.kill_count)
  _modify_data.kill_exp = data[packet.key.knight_pk_exp]
  _modify_data.fight_exp = data[packet.key.cmn_exp]
  if _modify_data.kill_exp == nil then
    _modify_data.kill_exp = 0
  end
  if _modify_data.fight_exp == nil then
    _modify_data.fight_exp = 0
  end
  _modify_data.total_exp = _modify_data.kill_exp + _modify_data.fight_exp
  if sys.check(bo2.player) then
    _modify_data.remain_times = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_RegistCrossLineCount)
  end
  local iLevel = ui.safe_get_atb(bo2.eAtb_Level)
  local check_award_table_vaild = function()
    if g_award_table == nil then
      g_award_table = sys.load_table("$mb/cross_line/cross_line_award.xml")
    end
  end
  function find_award(id)
    check_award_table_vaild()
    if sys.check(g_award_table) then
      return g_award_table:find(id)
    else
      return nil
    end
  end
  local function get_award(id)
    check_award_table_vaild()
    if sys.check(g_award_table) then
      return g_award_table:get(id)
    else
      return nil
    end
  end
  local function get_size_award()
    check_award_table_vaild()
    if sys.check(g_award_table) then
      return g_award_table.size
    else
      return 0
    end
  end
  local iSize = get_size_award()
  if iSize <= 0 then
    return
  end
  local bFound = false
  for i = 0, iSize - 1 do
    local pExcelData = get_award(i)
    if sys.check(pExcelData) then
      _modify_data.resent_kill_times = 0
      if _modify_data.kill_count > 0 then
        local iOddsSize = pExcelData.kill_stage_odds.size
        local iStageSize = pExcelData.kill_stage_count.size
        if iOddsSize == iStageSize then
          local odds = bo2.rand01()
          for i = 0, iOddsSize - 1 do
            local fCurrentOdds = pExcelData.kill_stage_odds[i]
            if odds > fCurrentOdds then
              local iRandomKillCount = pExcelData.kill_stage_count[i]
              if iRandomKillCount > _modify_data.kill_count then
                iRandomKillCount = _modify_data.kill_count
              end
              _modify_data.resent_kill_times = bo2.rand(0, iRandomKillCount)
              break
            else
              odds = odds - fCurrentOdds
            end
          end
        end
      end
      bFound = true
      break
    end
  end
  if bFound ~= true then
    return
  end
  ui_cross_line.w_online_info_main.visible = true
  local function modify_rb_text(p_name)
    local parent_item = ui_cross_line.w_online_items:search(p_name)
    if sys.check(parent_item) then
      local mtf_item = parent_item:search("rb_item")
      if sys.check(mtf_item) then
        local get_text_name = sys.format("cross_line|%s", p_name)
        mtf_item.mtf = ui_widget.merge_mtf(_modify_data, ui.get_text(get_text_name))
      end
    end
  end
  g_vis_cl_desc = true
  set_data_visible(0, true)
  local dy = 300
  if g_vis_fate_desc == nil or g_vis_fate_desc == false then
    set_data_visible(1, false)
    set_item_visible("desc_sep", false)
  else
    dy = 330
    set_item_visible("desc_sep", true)
    modify_rb_text("desc_sep")
  end
  modify_rb_text("desc_offline")
  modify_rb_text("fight_exp")
  modify_rb_text("kill_exp")
  modify_rb_text("total_exp")
  ui_cross_line.w_online_info_main.dy = dy
end
function on_online_info_confirm()
  ui_cross_line.w_online_info_main.visible = false
end
function runf_oi()
  local data = sys.variant()
  data[packet.key.battle_player_count] = 2
  data[packet.key.battle_kill_count] = 2800
  data[packet.key.knight_pk_exp] = 30000000
  data[packet.key.battle_res_count] = 2
  on_handle_online_info(0, data)
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter_finish, "ui_cross_line.on_self_enter_finish")
local sig_name = "ui_cross_line:on_handle_online_info"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_CrossLineOnlineInfo, on_handle_online_info, sig_name)
