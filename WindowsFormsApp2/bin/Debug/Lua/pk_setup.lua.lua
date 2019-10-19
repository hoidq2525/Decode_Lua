local g_pk_timer_cur = 0
function on_pk_select(item)
  local v = sys.variant()
  v:set(packet.key.cmn_msg_cmd, item.id)
  bo2.send_variant(packet.eCTS_UI_ChgPKMode, v)
end
function on_click_pk_btn(btn)
  local items = {}
  for i = 1, 2 do
    local item = {
      text = ui.get_text("portrait|pk_mode_" .. i),
      id = i
    }
    table.insert(items, item)
  end
  ui_tool.show_menu({
    items = items,
    event = on_pk_select,
    source = btn,
    popup = "x_auto"
  })
end
function on_pk_init(ctrl)
  g_pk_timer.suspended = true
end
function on_pk_timer(timer)
  g_pk_timer_cur = g_pk_timer_cur - 0.0025
  ui_tool.set_progress(w_pk_progress, g_pk_timer_cur)
  if g_pk_timer_cur < 0 then
    g_pk_timer.suspended = true
  end
end
local pk_mode_img = {
  SHARED("$image/qbar/qbar_main.png|156,108,21,92"),
  SHARED("$image/qbar/qbar_main.png|60,108,21,92"),
  SHARED("$image/qbar/qbar_main.png|180,108,21,92"),
  SHARED("$image/qbar/qbar_main.png|108,108,21,92"),
  SHARED("$image/qbar/qbar_main.png|132,108,21,92")
}
function on_pk_mode(obj, ft, idx)
  local c = obj:get_flag_int32(idx)
  g_pk_btn_pic.image = pk_mode_img[c + 1]
  local excel = bo2.scn.excel
  local level = obj:get_atb(bo2.eAtb_Level)
  if level < 30 then
    g_pk_btn.enable = false
    return
  end
  if excel.pk_limit > bo2.eScnPKLmt_Peace then
    g_pk_btn.enable = false
  else
    g_pk_btn.enable = true
  end
end
function set_scn_pklimit()
  local excel = bo2.scn.excel
  if excel.pk_limit > bo2.eScnPKLmt_Peace then
    g_pk_btn.enable = false
  else
    g_pk_btn.enable = true
  end
end
function on_pk_lvl(obj, ft, idx)
  local c = obj:get_atb(idx)
  if c < 30 then
    g_pk_btn.enable = false
    return
  else
    g_pk_btn.enable = true
  end
  set_scn_pklimit()
end
function on_start(data)
  g_pk_timer_cur = (data:get(packet.key.cmn_dataobj).v_int - 1000) / 600000
  ui_tool.set_progress(w_pk_progress, g_pk_timer_cur)
  w_pk_progress.visible = true
  g_pk_timer.suspended = false
end
function on_complete(data)
  ui_tool.set_progress(w_pk_progress, 0)
  w_pk_progress.visible = false
  g_pk_timer.suspended = true
end
function on_break(data)
  w_pk_progress.visible = false
  g_pk_timer.suspended = true
end
target_pos_x = 0
target_pos_y = 0
tot_pos_x = 0
tot_pos_y = 0
function on_config_load(cfg, root)
  if root == nil then
    return
  end
  local target_pos = root:find("target_pos")
  if target_pos ~= nil then
    local x = target_pos:get_attribute("x").v_int
    local y = target_pos:get_attribute("y").v_int
    target_pos_x = x
    target_pos_y = y
  end
  local tot_pos = root:find("tot_pos")
  if tot_pos ~= nil then
    local x = tot_pos:get_attribute("x").v_int
    local y = tot_pos:get_attribute("y").v_int
    tot_pos_x = x
    tot_pos_y = y
  end
  function do_update()
    w_target_show.dock = "none"
    w_target_show.dock_solo = true
    w_target_show.offset = ui.point(target_pos_x, target_pos_y)
    w_tot_show.dock = "none"
    w_tot_show.dock_solo = true
    w_tot_show.offset = ui.point(tot_pos_x, tot_pos_y)
  end
  w_target_show:insert_post_invoke(do_update, "ui_portrait.do_update")
  ui.log("target_show.x:" .. w_target_show.x)
  ui.log("target_show.y:" .. w_target_show.y)
  ui.log("tot_show.x:" .. w_tot_show.x)
  ui.log("tot_show.y:" .. w_tot_show.y)
  ui.log("bk_target_show.x:" .. target_pos_x)
  ui.log("bk_target_show_y:" .. target_pos_y)
end
function on_config_save(cfg, root)
  ui.log("target_show.x:" .. w_target_show.x)
  ui.log("target_show.y:" .. w_target_show.y)
  ui.log("tot_show.x:" .. w_tot_show.x)
  ui.log("tot_show.y:" .. w_tot_show.y)
  if root == nil then
    return
  end
  local target_pos = root:find("target_pos")
  if target_pos ~= nil then
    target_pos:set_attribute("x", w_target_show.x)
    target_pos:set_attribute("y", w_target_show.y)
  end
  local tot_pos = root:find("tot_pos")
  if tot_pos ~= nil then
    tot_pos:set_attribute("x", w_tot_show.x)
    tot_pos:set_attribute("y", w_tot_show.y)
  end
end
