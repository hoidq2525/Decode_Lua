local animation_idx = 1
local bind_sig = SHARED("ui_qbar.ui_hide_anim.bind_on_visible")
function on_key()
end
function on_char()
end
function on_init()
  animation_idx = 1
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
      if excel ~= nil and excel.serverid == 77 then
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
function on_total_timer()
  gx_window.visible = false
  gx_window.focus = false
  w_main.visible = false
  w_mask.visible = false
  w_total_timer.suspended = true
  local quest_info = ui.quest_find(10)
  if quest_info then
    local mstone_id = quest_info.mstone_id
    if mstone_id == 421 then
      ui_quest.ui_milestone.set_visible(true)
    end
  end
end
function test_all_anim()
  gx_window.visible = true
  gx_window.focus = true
  w_main.visible = true
  w_letter_anim_new.visible = true
  w_letter_anim_new:reset(0, 1, 400)
  w_mask.visible = true
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
  w_total_timer.suspended = false
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
function on_quick_joinin_click(btn)
  w_btn_quick.visible = false
  w_btn_arrow.visible = false
  ui_xinshou.on_click_event(1)
  w_mask.visible = false
  gx_window.visible = false
end
function on_open_campaign_click(btn)
  ui_xinshou.set_first_time()
  ui_xinshou.set_visible()
  w_btn_anim.visible = false
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
  elseif info.mstone_index > 2 then
    ui_qbar.w_qlink:search("xinshou").visible = true
  else
    ui_qbar.w_qlink:search("xinshou").visible = false
  end
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_xinshou_animation.on_self_enter")
