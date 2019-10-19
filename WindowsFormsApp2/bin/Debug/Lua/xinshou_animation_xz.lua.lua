local animation_idx = 1
local bind_sig = SHARED("ui_qbar.ui_hide_anim.bind_on_visible")
function on_key()
end
function on_char()
end
function on_init()
  animation_idx = 1
end
function on_move()
  if w_btn_anim.visible then
    local qbar_btn = ui_qbar.w_qlink:search("xinshou")
    local pos = qbar_btn:control_to_window(ui.point(0, 0))
    w_btn_anim.margin = ui.rect(pos.x - 80, pos.y, 0, 0)
  end
  if w_btn_quick.visible and w_btn_arrow.visible then
    local item
    for i = 0, ui_xinshou.w_list_view.item_count - 1 do
      local t_item = ui_xinshou.w_list_view:item_get(i)
      local excel_id = t_item.svar.id
      local excel = bo2.gv_xinshou_campaign:find(excel_id)
      if excel ~= nil and excel.serverid == 79 then
        item = t_item
        break
      end
    end
    if item == nil then
      return
    end
    local btn = item:search("btn_quickjoinin")
    local pos = btn:control_to_window(ui.point(0, 0))
    w_btn_quick.visible = true
    w_btn_quick.margin = ui.rect(pos.x, pos.y, 0, 0)
    w_btn_arrow.visible = true
    w_btn_arrow.margin = ui.rect(pos.x - 120, pos.y, 0, 15)
    w_btn_arrow:search("anim"):reset()
  end
end
function on_timer_letter1()
  player_letter_animation_new()
end
function on_timer_letter2()
  player_pic_animation()
end
function on_timer_pic()
  w_pic_anim2.visible = true
  local w_hide_anim = w_hide_anim
  w_hide_anim.svar.target = gx_window
  w_hide_anim:frame_clear()
  w_hide_anim.visible = true
  local w = w_main
  local btn = ui_qbar.w_qlink:search("xinshou")
  local bs = btn.size
  local ws = w.size
  local pos = btn:control_to_window(ui.point(0, 0)) + bs * 0.5
  local src = w.offset + ws * 0.5
  local dis = pos - src
  local tick = math.sqrt(math.sqrt(dis.x * dis.x + dis.y * dis.y)) * 20
  if tick < 100 then
    tick = 100
  end
  local f = w_hide_anim:frame_insert(500, w)
  f.color1 = "FFFFFFFF"
  f.color2 = "CCFFFFFF"
  f = w_hide_anim:frame_insert(tick, w)
  f.color1 = "CCFFFFFF"
  f.color2 = "99FFFFFF"
  f.set_scale1(1, 1)
  f.set_scale2(0.667, 0.667)
  f:set_translate2(dis.x, dis.y)
  f = w_hide_anim:frame_insert(300, w)
  f.color1 = "99FFFFFF"
  f.color2 = "00FFFFFF"
  f:set_translate1(dis.x, dis.y)
  f:set_translate2(dis.x, dis.y)
  if w ~= nil then
    w:insert_on_visible(on_visible, bind_sig)
  end
  w_timer_pic.suspended = true
  w_timer_btn.period = 800 + tick
  w_timer_btn.suspended = false
  w_main.visible = false
end
function on_timer_btn()
  local qbar_btn = ui_qbar.w_qlink:search("xinshou")
  qbar_btn.visible = true
  local pos = qbar_btn:control_to_window(ui.point(0, 0))
  w_btn_anim.visible = true
  w_btn_anim.margin = ui.rect(pos.x - 80, pos.y, 0, 0)
  local anim = w_btn_anim:search("anim")
  anim:reset()
  w_timer_btn.suspended = true
end
function on_self_enter()
end
function test_all_anim()
  gx_window.visible = true
  w_main.visible = true
  w_letter_anim_new.visible = true
  w_letter_anim_new:reset(0, 1, 400)
  animation_idx = 1
  local pic = w_letter_anim:search("pic")
  pic.image = ""
  pic.visible = false
  local anim = w_letter_anim:search("anim")
  anim.visible = false
  local anim_pic = w_pic_anim:search("anim_pic")
  local anim_back = w_pic_anim:search("anim_back")
  anim_pic.visible = false
  anim_back.visible = false
  w_pic_anim2.visible = false
  w_btn_anim.visible = false
  w_btn_quick.visible = false
  w_btn_arrow.visible = false
  ui_qbar.w_qlink:search("xinshou").visible = false
  w_timer_letter1.suspended = false
end
function on_player_levelup()
  local xzlvl = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_XuezhanLevel)
  local disable = bo2.gv_define:find(1108).value.v_int
  if xzlvl == 1 and disable == 0 then
    test_all_anim()
  end
end
function reset_xzlvl()
  bo2.player:set_flag_int8(bo2.ePlayerFlagInt8_XuezhanLevel, 0)
end
function clear_mask()
  w_mask.visible = false
end
function player_letter_animation_new()
  w_letter_anim_new:reset(1, 0, 1400)
  w_timer_letter1.suspended = true
  w_timer_letter2.suspended = false
end
function player_letter_animation()
  local anim = w_letter_anim:search("anim")
  anim.visible = true
  anim:reset()
  w_timer_letter1.suspended = true
  w_timer_letter2.suspended = false
end
function player_pic_animation()
  w_pic_anim.visible = true
  local anim_pic = w_pic_anim:search("anim_pic")
  local anim_back = w_pic_anim:search("anim_back")
  anim_pic.visible = true
  anim_pic:reset()
  anim_back.visible = true
  anim_back:reset()
  w_timer_letter2.suspended = true
  w_timer_pic.suspended = false
end
function player_btn_animation()
end
function show_waitlist_popo()
  ui_minimap.gx_minimap_win:apply_dock(true)
  local pos = ui_minimap.gx_waitlist_minibtn:control_to_window(ui.point(0, 0))
  gx_waitlist_popo.margin = ui.rect(pos.x - 200, pos.y + 3, 0, 0)
  gx_waitlist_popo:search("popo").mtf = "<handson:0,6,,143>"
  gx_window.visible = true
  gx_waitlist_popo.visible = true
  w_btn_anim.visible = false
  w_hide_anim.visible = false
  w_main.visible = false
  bo2.AddTimeEvent(1500, function()
    gx_waitlist_popo.visible = false
    gx_window.visible = false
  end)
end
function on_waitlist_click(btn)
  gx_window.mouse_able = false
  gx_window.wheel_able = false
  gx_window.focus_able = false
  gx_window.focus = false
  gx_window.visible = false
  w_mask.visible = false
  gx_waitlist_minibtn.visible = false
  gx_waitlist_arrow.visible = false
  ui_minimap.wait_list.on_waitlist_visible()
end
function on_quick_joinin_click(btn)
  w_btn_quick.visible = false
  w_btn_arrow.visible = false
  ui_xinshou.on_click_event(3)
  gx_window.mouse_able = false
  gx_window.wheel_able = false
  gx_window.focus_able = false
  gx_window.focus = false
  gx_window.visible = false
  w_mask.visible = false
end
function on_career_seleted()
  gx_window.mouse_able = true
  gx_window.wheel_able = true
  gx_window.focus_able = true
  gx_window.focus = true
  w_mask.visible = true
  w_btn_anim.visible = false
  ui_xinshou.set_first_time("xuezhan")
  ui_xinshou.set_visible()
end
local b_campaign_clicked = false
function on_open_campaign_click(btn)
  if b_campaign_clicked then
    return
  end
  ui_warrior_arena.w_main_career.visible = true
end
function on_self_enter()
  local disable = bo2.gv_define:find(1108).value.v_int
  if disable == 1 then
    ui_qbar.w_qlink:search("xinshou").visible = false
    return
  end
  local info = ui.quest_find(10)
  if info == nil then
    local show = ui.quest_find_c(10)
    if show then
      ui_qbar.w_qlink:search("xinshou").visible = true
    else
      ui_qbar.w_qlink:search("xinshou").visible = false
    end
  elseif sys.check(ui_qbar) and sys.check(ui_qbar.w_qlink) then
    if info.mstone_index > 2 then
      ui_qbar.w_qlink:search("xinshou").visible = true
    else
      ui_qbar.w_qlink:search("xinshou").visible = false
    end
  end
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_xinshou_animation.on_self_enter")
function guide_start()
  bo2.scene_black(25, 0.9, 1)
  bo2.AddTimeEvent(25, function()
    guide_enemy()
  end)
end
function guide_enemy()
  bo2.player:set_flag_objmem(61, 2)
  bo2.AddTimeEvent(175, function()
    guide_ally()
  end)
end
function guide_ally()
  bo2.player:set_flag_objmem(61, 3)
  bo2.AddTimeEvent(175, function()
    guide_myself()
  end)
end
function guide_myself()
  local guide_popo = ui_tool.ui_xinshou_animation_xz.guide_popo
  local popo_myself = guide_popo:search("myself")
  guide_popo.visible = true
  popo_myself.mtf = "<handson:0,4,,139>"
  popo_myself.visible = true
  bo2.AddTimeEvent(150, function()
    popo_myself.visible = false
  end)
  bo2.AddTimeEvent(175, function()
    guide_bright()
  end)
end
function guide_bright()
  bo2.scene_black(25, 0.9, 0)
  bo2.AddTimeEvent(50, function()
    guide_common_border()
  end)
end
function guide_common_border()
  ui_tool.ui_mask.set_mask(false)
  ui_tool.ui_mask.set_mask_basedon_ctrl(true, ui_common_border.w_main, false, false, 0, 0, 0, 0)
  local guide_popo = ui_tool.ui_xinshou_animation_xz.guide_popo
  local popo_border = guide_popo:search("border")
  popo_border.visible = true
  popo_border.mtf = "<handson:0,7,,140>"
  bo2.AddTimeEvent(175, function()
    popo_border.visible = false
    guide_toptip()
  end)
end
function guide_N()
  bo2.AddTimeEvent(175, function()
    guide_toptip()
  end)
end
function guide_toptip()
  ui_tool.ui_mask.set_mask(false)
  ui_tool.ui_mask.set_mask_basedon_ctrl(true, ui_battle_5v5green.iner.gx_top_tip, false, false, 0, 0, 0, 0)
  local guide_popo = ui_tool.ui_xinshou_animation_xz.guide_popo
  local popo_toptip = guide_popo:search("toptip")
  popo_toptip.visible = true
  popo_toptip.mtf = "<handson:0,5,,142>"
  bo2.AddTimeEvent(175, function()
    popo_toptip.visible = false
    guide_over()
  end)
end
function guide_over()
  ui_tool.ui_mask.set_mask(false)
  ui_main.ShowUI(true)
end
function on_self_enter(obj)
  if not bo2.scn then
    return
  end
  if 179 ~= bo2.scn.excel.id then
    return
  end
  local xzlvl = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_XuezhanLevel)
  if 2 ~= xzlvl then
    return
  end
  ui_main.w_top:apply_dock(true)
  local w_mask = ui_tool.ui_mask.w_mask
  ui_tool.ui_mask.set_mask_basedon_ctrl(true, w_mask, false, false, 0, 0, 0, 0)
  bo2.AddTimeEvent(75, guide_start)
  bo2.AddTimeEvent(1, function()
    ui_main.ShowUI(false, 0)
  end)
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_xinshou_animation_xz.on_self_enter")
