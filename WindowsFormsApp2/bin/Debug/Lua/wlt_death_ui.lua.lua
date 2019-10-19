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
  wlt_set_life_info(self_life, teammate_life)
end
function update_life_info()
end
function reject_borrow_life()
  local var_data = sys.variant()
  var_data:set(packet.key.wlt_player_src_name, teammate_name)
  bo2.send_variant(packet.eCTS_UI_WLTBorrowLifeReject, var_data)
  borr_wnd_end()
end
function on_life_borrow_confirm()
  if self_life < 1 then
    return
  end
  local var_data = sys.variant()
  var_data:set(packet.key.wlt_player_src_name, teammate_name)
  bo2.send_variant(packet.eCTS_UI_WLTBorrowLifeConfirm, var_data)
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
  bo2.send_variant(packet.eCTS_UI_WLTBorrowLife, var_data)
  death_wnd_end()
end
function on_relive_byself()
  if self_life < 1 then
    return
  end
  g_death.visible = false
  local var_data = sys.variant()
  bo2.send_variant(packet.eCTS_UI_WLTReliveBySelf, var_data)
  death_wnd_end()
end
function show_death_ui(vis)
  g_death.visible = vis
  if self_life < 1 then
    g_wlt_relive_byself_btn.visible = false
  else
    g_wlt_relive_byself_btn.visible = true
  end
  if teammate_life < 1 then
    g_wlt_borrow_life_btn.visible = false
  else
    g_wlt_borrow_life_btn.visible = true
  end
end
function show_borrow_life_ui(vis)
  if teammate_name == nil then
    return
  end
  local lbl_txt_fmt = ui.get_text("common|wlt_borrow_txt")
  local param = sys.variant()
  param:set("player_name", teammate_name)
  local lbl_txt = sys.mtf_merge(param, lbl_txt_fmt)
  g_borrow_life_text.mtf = lbl_txt
  g_borrow_life.visible = vis
  g_wlt_borrow_reject.visible = true
  g_borrow_life_timer.suspended = false
  borrow_remain = 30
  if self_life < 1 then
    g_wlt_borrow_confirm.visible = false
  else
    g_wlt_borrow_confirm.visible = true
  end
end
function wlt_self_dead()
  timer_remain = 30
  g_death_timer.suspended = false
  show_death_ui(true)
end
function on_close_click(ctrl)
  local var_data = sys.variant()
  var_data:set(packet.key.wlt_relive_way, 1)
  bo2.send_variant(packet.eCTS_UI_WLTReliveBySelf, var_data)
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
  g_death_timer.suspended = true
  timer_remain = 30
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
  end
end
