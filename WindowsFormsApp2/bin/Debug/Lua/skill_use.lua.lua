local sig = "ui_skill.skill_use"
local g_key_hot = false
function UseSkillhotkey()
  return g_key_hot
end
function SetUseHot(b)
  if b then
    bo2.notify_on_focus(false)
  else
    bo2.notify_on_focus(true)
  end
  g_key_hot = b
end
local start_xuli = false
local xuli_skill = 0
function IsCurXuliSkill(id)
  if start_xuli and id == xuli_skill then
    return true
  end
  return false
end
function begin_xuli()
  start_xuli = true
  xuli_skill = bo2.player:GetUseSkillID()
end
function end_xuli()
  start_xuli = false
  xuli_skill = 0
end
function on_shortcut_up(id)
  if start_xuli then
    bo2.OnXuliCallback(id)
  end
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_xuli_start, begin_xuli, sig)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_xuli_end, end_xuli, sig)
local g_inKf = false
local g_b_is_inputcheck = false
local numKey = {}
numKey[0] = 32
numKey[1] = 65
numKey[2] = 83
numKey[3] = 68
numKey[4] = 87
numKey[35] = 16
local numKey1 = {}
numKey1[0] = 32
numKey1[1] = 37
numKey1[2] = 40
numKey1[3] = 39
numKey1[4] = 38
numKey1[35] = 16
local charKey = {}
charKey[0] = "kg"
charKey[1] = "a"
charKey[2] = "s"
charKey[3] = "d"
charKey[4] = "w"
charKey[35] = "sf"
local stateRight = 1
local statePreCheck = 2
local stateError = 3
local stateNone = 4
local keyNum = 6
local keyType = 2
local m_num = 0
local info = {
  keys = {},
  states = {},
  sound = {
    598,
    599,
    600,
    601,
    602,
    603,
    604,
    605
  },
  curIndex = 1
}
function randomsound()
  local n = math.random(8)
  bo2.PlaySound2D(info.sound[n], false)
end
local keyUrlBase = "$image/skill/knifefight/"
local errorKey = "bk.png|448,0,512,64"
local keyTail = "_1.png|0,0,128,128"
function resetKey()
  info.curIndex = 1
  for index = 1, keyNum do
    local ctr = w_kf:search("" .. index)
    local n = math.random(4)
    if keyType ~= 4 then
      if n == 2 then
        n = 3
      elseif n == 4 then
        n = 1
      end
    end
    info.keys[index] = n
    local st = statePreCheck
    info.states[index] = st
    local ak = ctr:search("animKey")
    ak.visible = false
    local af = ctr:search("animfalsh")
    af.visible = false
    local sk = ctr:search("staticKey")
    sk.size = ui.point(128, 128)
    sk.visible = true
    sk.image = keyUrlBase .. "wsad/" .. charKey[n] .. keyTail
    local gq = ctr:search("guangquan")
    if index == info.curIndex then
      gq.visible = true
    else
      gq.visible = false
    end
  end
end
function rightDown(key)
  local indexKey = info.keys[info.curIndex]
  if key == numKey[indexKey] or key == numKey1[indexKey] then
    return true
  end
  return false
end
function onKFKeyFilter(ctr, key, flag)
  if not flag.down then
    if key == 32 then
      local sp = w_kf:search("space")
      sp:setIndex(4)
      resetKey()
      return
    end
    if info.curIndex <= keyNum then
      if rightDown(key) then
        info.states[info.curIndex] = stateRight
      else
        info.states[info.curIndex] = stateError
      end
      local keyCtr = w_kf:search("" .. info.curIndex)
      local gq = keyCtr:search("guangquan")
      gq.visible = false
      if info.states[info.curIndex] == stateRight then
        local ak = keyCtr:search("animKey")
        ak.visible = true
        ak.animation = keyUrlBase .. "anim.xml|" .. charKey[info.keys[info.curIndex]]
        ak:reset()
        local af = keyCtr:search("animfalsh")
        af.visible = true
        af.animation = keyUrlBase .. "anim.xml|flash_" .. charKey[info.keys[info.curIndex]]
        af:reset()
        local sk = keyCtr:search("staticKey")
        sk.visible = false
        bo2.PlaySound2D(info.sound[info.curIndex], false)
      else
        local ak = keyCtr:search("animKey")
        ak.visible = false
        local af = keyCtr:search("animfalsh")
        af.visible = false
        local sk = keyCtr:search("staticKey")
        sk.size = ui.point(64, 64)
        sk.visible = true
        sk.image = keyUrlBase .. errorKey
        bo2.PlaySound2D(606, false)
      end
      info.curIndex = info.curIndex + 1
      if info.curIndex < keyNum then
        info.states[info.curIndex] = statePreCheck
        keyCtr = w_kf:search("" .. info.curIndex)
        local gq = keyCtr:search("guangquan")
        gq.visible = true
      end
    end
  elseif key == 32 then
    local sp = w_kf:search("space")
    sp:reset()
    if info.curIndex > keyNum then
      local bok = true
      for i = 1, keyNum do
        if info.states[i] ~= stateRight then
          bok = false
          break
        end
      end
      if bok then
        if g_b_is_inputcheck then
          do_inputcheck()
        else
          m_num = m_num + 1
        end
        w_kf_timer.suspended = false
        w_bjStar.visible = true
        w_bjStar.alpha = 1
      end
    end
    bo2.PlaySound2D(607, false)
  end
end
function on_kf_timer(t)
  local a = w_bjStar.alpha
  if a <= 0.06 then
    w_bjStar.visible = false
    w_kf_timer.suspended = true
    return
  end
  w_bjStar.alpha = a - 0.06
end
function on_space_init()
  local sp = w_kf:search("space")
  sp:setIndex(4)
end
function on_kf_init()
  m_num = 0
  resetKey()
  w_kf.visible = true
  g_inKf = true
  SetUseHot(true)
  ui.insert_key_filter_prev(onKFKeyFilter, sig)
end
function on_kf_start()
  keyType = 2
  if sys.check(w_kf) == false then
    local ctr = ui.create_control(ui_main.w_top, "fader")
    ctr:load_style("$gui/frame/skill/skill_use.xml", "kf")
  else
    on_kf_init()
  end
  ui.console_print(bo2.player.cha_name .. ":open kf\n")
end
function on_kf_end()
  if w_kf.visible then
    w_kf.visible = false
    g_inKf = false
    SetUseHot(false)
    ui.remove_key_filter_prev(sig)
    local v = sys.variant()
    v:set(packet.key.knifefight_hitnum, m_num)
    bo2.send_variant(packet.eCTS_ScnObj_KF_HitNum, v)
    ui.console_print(bo2.player.cha_name .. ":close kf\n")
  end
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_kfinput_start, on_kf_start, sig)
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_kfinput_end, on_kf_end, sig)
local g_crt
local g_stream_id = 0
function do_inputcheck()
  if g_crt and g_stream_id > 0 then
    bo2.OnKeyEventCallBack(g_crt, g_stream_id)
    local v = sys.variant()
    v:set(1, g_crt.sel_handle)
    v:set(2, g_stream_id)
    bo2.send_variant(packet.eCTS_ScnObj_Skill_KeyEvent, v)
  end
end
function on_inputcheck_start(crt, v)
  keyType = v:get(1).v_int
  g_crt = nil
  g_stream_id = 0
  g_crt = crt
  g_stream_id = v:get(8).v_int
  g_b_is_inputcheck = true
  if sys.check(w_kf) == false then
    local ctr = ui.create_control(ui_main.w_top, "fader")
    ctr:load_style("$gui/frame/skill/skill_use.xml", "kf")
  else
    on_kf_init()
  end
  ui.console_print(bo2.player.cha_name .. ":open kf\n")
end
function on_inputcheck_end()
  if w_kf.visible then
    w_kf.visible = false
    g_inKf = false
    SetUseHot(false)
    ui.remove_key_filter_prev(sig)
    ui.console_print(bo2.player.cha_name .. ":close kf\n")
  end
  g_b_is_inputcheck = falsedd
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_inputcheck_end, on_inputcheck_end, sig)
local w_keyEvent_table = {}
w_keyEvent_table.all_time = 20000
w_keyEvent_table.cur_time = 0
w_keyEvent_table.iKey = 100
w_keyEvent_table.iCurKey = 0
w_keyEvent_table.keypress_right_max = 100
w_keyEvent_table.keypress_right_cur = 0
w_keyEvent_table.keypress_error_max = 0
w_keyEvent_table.keypress_error_cur = 0
w_keyEvent_table.needFinish = true
w_keyEvent_table.bFinish = false
w_keyEvent_table.crt = nil
w_keyEvent_table.key_image_url = nil
w_keyEvent_table.ui_type = nil
w_keyEvent_table.ui_type_name = nil
w_keyEvent_table.stream_id = 0
w_keyEvent_table.star = nil
w_keyEvent_table.star_size = nil
function on_timer_guangbo(timer)
  timer.owner.visible = false
  timer.owner:post_release()
end
function on_visible_guangbo(ctr, vis)
  local t = ctr:find_plugin("timer")
  if vis then
    t.suspended = false
  else
    t.suspended = true
  end
end
function show_guangbo()
  local ctr = ui.create_control(ui_main.w_top, "fader")
  ctr:load_style("$gui/frame/skill/skill_use.xml", "guangbo")
  local anim = ctr:search("anim")
  anim.size = w_keyEvent_table.star_size
  anim.animation = "$image/skill/skill_key_event/anim.xml|" .. w_keyEvent_table.star
  ctr.visible = true
end
function set_key_progress_rate(angle)
  local pane_cricle = w_skill_key_event:search(w_keyEvent_table.ui_type_name)
  local key_progress = pane_cricle:search("progress_rate")
  local key_rate = key_progress:search("rate")
  if w_keyEvent_table.ui_type == 1 then
    local fp = key_rate.parent
    key_rate.dx = fp.dx * angle / 360
  else
    key_rate.angle_e = 270 + angle
  end
end
function set_timer_suspended(b)
  local pane_cricle = w_skill_key_event:search(w_keyEvent_table.ui_type_name)
  local key_progress = pane_cricle:search("progress_rate")
  local timer = key_progress:find_plugin("timer")
  timer.suspended = b
end
function UpdataPressInfo()
  local pane_cricle = w_skill_key_event:search(w_keyEvent_table.ui_type_name)
  local ctr = pane_cricle:search("text")
  ctr.text = "" .. w_keyEvent_table.keypress_right_cur .. "/" .. w_keyEvent_table.keypress_right_max
end
function SetKeyState(t)
  local url = w_keyEvent_table.key_image_url .. charKey[w_keyEvent_table.iCurKey]
  local pane_cricle = w_skill_key_event:search(w_keyEvent_table.ui_type_name)
  local ctr = pane_cricle:search("star")
  if t > 0 then
    url = url .. t
    ctr.visible = false
  else
    ctr.visible = true
  end
  ctr = pane_cricle:search("key")
  ctr.image = url .. ".png"
end
function resetKeyEventInfo()
  local ikey = w_keyEvent_table.iKey
  if ikey == 100 then
    ikey = math.random(1, 4)
  end
  w_keyEvent_table.iCurKey = ikey
  SetKeyState(0)
end
function ShowKeyEvent(b)
  w_skill_key_event.visible = b
  local ui_panel = w_skill_key_event:search(w_keyEvent_table.ui_type_name)
  ui_panel.visible = b
end
function onKeyEventFilter(ctr, key, flag)
  if flag.down then
    if flag.first then
      if key == numKey[w_keyEvent_table.iCurKey] or key == numKey1[w_keyEvent_table.iCurKey] then
        SetKeyState(1)
        show_guangbo()
        randomsound()
        w_keyEvent_table.keypress_right_cur = w_keyEvent_table.keypress_right_cur + 1
        UpdataPressInfo()
        if 1 < w_keyEvent_table.keypress_right_max then
          ui_hits.SetHit(w_keyEvent_table.keypress_right_cur)
        end
        if w_keyEvent_table.keypress_right_cur >= w_keyEvent_table.keypress_right_max then
          w_keyEvent_table.bFinish = true
          on_keyEvent_end()
        end
      else
        SetKeyState(2)
        bo2.PlaySound2D(606, false)
        w_keyEvent_table.keypress_error_cur = w_keyEvent_table.keypress_error_cur + 1
        if w_keyEvent_table.keypress_error_max > 0 and w_keyEvent_table.keypress_error_cur >= w_keyEvent_table.keypress_error_max then
          on_keyEvent_end()
        end
      end
    end
  else
    resetKeyEventInfo()
  end
end
function on_keyEvent_init()
  SetUseHot(true)
  ui.insert_key_filter_prev(onKeyEventFilter, sig)
  if w_keyEvent_table.iKey > 0 and w_keyEvent_table.iKey < 35 or w_keyEvent_table.iKey == 100 then
    w_keyEvent_table.ui_type = 0
    w_keyEvent_table.ui_type_name = "circle"
    w_keyEvent_table.star = "guangbo"
    w_keyEvent_table.star_size = ui.point(256, 256)
    w_keyEvent_table.key_image_url = "$image/skill/skill_key_event/64x64/"
  else
    w_keyEvent_table.ui_type = 1
    w_keyEvent_table.ui_type_name = "rectangle"
    w_keyEvent_table.star = "guangbo1"
    w_keyEvent_table.star_size = ui.point(512, 256)
    w_keyEvent_table.key_image_url = "$image/skill/skill_key_event/128x64/"
  end
  ShowKeyEvent(true)
  UpdataPressInfo()
  resetKeyEventInfo()
  set_key_progress_rate(0)
  set_timer_suspended(false)
end
function on_keyEvent_start(crt, v)
  w_keyEvent_table.crt = crt
  w_keyEvent_table.iKey = v:get(1).v_int
  w_keyEvent_table.iCurKey = 0
  w_keyEvent_table.keypress_right_max = v:get(3).v_int
  w_keyEvent_table.keypress_right_cur = 0
  w_keyEvent_table.keypress_error_max = v:get(4).v_int
  w_keyEvent_table.keypress_error_cur = 0
  w_keyEvent_table.all_time = v:get(5).v_int
  w_keyEvent_table.cur_time = 0
  w_keyEvent_table.bFinish = false
  if 0 < v:get(7).v_int then
    w_keyEvent_table.needFinish = false
  else
    w_keyEvent_table.needFinish = true
  end
  w_keyEvent_table.stream_id = v:get(8).v_int
  if sys.check(w_skill_key_event) == false then
    local ctr = ui.create_control(ui_main.w_top, "fader")
    ctr:load_style("$gui/frame/skill/skill_use.xml", "skill_key_event")
  else
    on_keyEvent_init()
  end
end
function on_keyEvent_end(b)
  if w_keyEvent_table.crt == nil then
    return
  end
  SetUseHot(false)
  ui.remove_key_filter_prev(sig)
  if b == nil and w_keyEvent_table.bFinish == w_keyEvent_table.needFinish then
    bo2.OnKeyEventCallBack(w_keyEvent_table.crt, w_keyEvent_table.stream_id)
    local v = sys.variant()
    v:set(1, w_keyEvent_table.crt.sel_handle)
    v:set(2, w_keyEvent_table.stream_id)
    bo2.send_variant(packet.eCTS_ScnObj_Skill_KeyEvent, v)
  end
  set_timer_suspended(true)
  ShowKeyEvent(false)
  w_keyEvent_table = {}
end
function on_timer_key_progress(timer)
  w_keyEvent_table.cur_time = w_keyEvent_table.cur_time + 1
  if w_keyEvent_table.all_time > w_keyEvent_table.cur_time then
    local angel = w_keyEvent_table.cur_time / w_keyEvent_table.all_time * 360
    set_key_progress_rate(angel)
  else
    on_keyEvent_end()
  end
end
local g_key_event_type = 0
function on_skill_keyEvent(crt, type, v)
  if type == 0 then
    if g_key_event_type == 2 then
      on_keyEvent_end(true)
    end
    g_key_event_type = 0
    return
  end
  if type == 2 then
    g_key_event_type = 2
    on_keyEvent_start(crt, v)
    return
  end
  if type == 3 then
    if 0 < v.v_int then
      ui_main.ShowUI(true, 100)
    else
      ui_main.ShowUI(false, 100)
    end
    return
  end
  if type == 4 then
    on_inputcheck_start(crt, v)
    return
  end
end
ui.insert_skill_method(on_skill_keyEvent, "ui_skill.on_skill_keyEvent")
