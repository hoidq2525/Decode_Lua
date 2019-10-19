local teammate_name
local self_life = 0
local teammate_life = 0
local timer_remain = 0
local borrow_remain = 0
function set_teammate_name(name)
  teammate_name = name
end
function set_life(self, teammate)
  self_life = self
  teammate_life = teammate
  set_life_info(self_life, teammate_life)
end
function update_life_info()
end
function reject_borrow_life()
  local var_data = sys.variant()
  var_data:set(packet.key.arcade_dungeon_player_src_name, teammate_name)
  bo2.send_variant(packet.eCTS_ArcadeDungeon_BorrowLifeReject, var_data)
  borr_wnd_end()
end
function on_life_borrow_confirm()
  if self_life < 1 then
    return
  end
  local var_data = sys.variant()
  var_data:set(packet.key.arcade_dungeon_player_src_name, teammate_name)
  bo2.send_variant(packet.eCTS_ArcadeDungeon_BorrowLifeConfirm, var_data)
  borr_wnd_end()
end
function on_life_borrow_reject()
  reject_borrow_life()
end
function on_borrow_life()
  if teammate_name == nil then
    return
  end
  g_death.visible = false
  local var_data = sys.variant()
  bo2.send_variant(packet.eCTS_ArcadeDungeon_BorrowLife, var_data)
  death_wnd_end()
end
function on_relive_byself()
  g_death.visible = false
  local var_data = sys.variant()
  bo2.send_variant(packet.eCTS_ArcadeDungeon_ReliveBySelf, var_data)
  death_wnd_end()
end
function on_out_scn()
  g_death.visible = false
  local var_data = sys.variant()
  bo2.send_variant(packet.eCTS_ArcadeDungeon_LeaveScn, var_data)
  death_wnd_end()
end
function show_borrow_life_ui(vis, v)
  if teammate_name == nil then
    return
  end
  local t = v:get(packet.key.arcade_dungeon_left_time).v_int
  local lbl_txt_fmt = ui.get_text("common|wlt_borrow_txt")
  local param = sys.variant()
  param:set("player_name", teammate_name)
  local lbl_txt = sys.mtf_merge(param, lbl_txt_fmt)
  g_borrow_life_text.mtf = lbl_txt
  g_borrow_life.visible = vis
  g_wlt_borrow_reject.visible = true
  g_borrow_life_timer.suspended = false
  borrow_remain = 30
  if t < borrow_remain then
    borrow_remain = t
  end
  if self_life < 1 then
    g_wlt_borrow_confirm.visible = false
  else
    g_wlt_borrow_confirm.visible = true
  end
end
function self_dead(leftlife, can_borrow_life, time)
  g_death.visible = true
  timer_remain = time
  g_death_timer.suspended = false
  if leftlife > 0 then
    g_wlt_relive_byself_btn.visible = true
    g_wlt_borrow_life_btn.visible = false
  else
    g_wlt_relive_byself_btn.visible = false
    if can_borrow_life ~= 0 then
      g_wlt_borrow_life_btn.visible = true
    else
      g_wlt_borrow_life_btn.visible = false
    end
  end
end
function on_close_click(ctrl)
  local var_data = sys.variant()
  var_data:set(packet.key.wlt_relive_way, 1)
  bo2.send_variant(packet.eCTS_ArcadeDungeon_ReliveBySelf, var_data)
end
function main_on_visible(panel, vis)
end
function borrow_on_visible(panel, vis)
end
function on_borrow_close_click(ctrl)
  reject_borrow_life()
end
function death_wnd_end()
  g_death.visible = false
end
function borr_wnd_end(timer)
  g_borrow_life.visible = false
  g_borrow_life_timer.suspended = true
  borrow_remain = 30
end
function on_death_timer(timer)
  if timer_remain > 0 then
    timer_remain = timer_remain - 1
    lbl_death_count.text = timer_remain
  else
    death_wnd_end()
  end
end
function on_borrow_life_timer(timer)
  if borrow_remain > 0 then
    borrow_remain = borrow_remain - 1
    lbl_borrow_count.text = borrow_remain
  else
    borr_wnd_end()
    reject_borrow_life()
  end
end
