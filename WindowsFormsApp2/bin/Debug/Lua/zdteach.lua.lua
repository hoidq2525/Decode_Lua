local reg = ui_packet.game_recv_signal_insert
local sig = "ui_zdteach.packet_handle"
function run_set_visible()
  local w = ui_zdteach.w_main
  w.visible = false
end
function r()
  set_visible(true)
end
function set_visible(vis)
  local w = ui_zdteach.w_main
  local flicker = w:search("teach_flicker")
  w.visible = vis
  flicker.visible = vis
end
function get_visible()
  local w = ui_zdteach.w_main
  return w.visible
end
function m(...)
  local val = arg[1].v_int
  handle_open_ui(nil, nil, val)
end
function handle_open_ui(cmd, data, scn_data)
  if cmd ~= nil then
    ui_tool.note_insert(ui.get_text("common|zd_tip"), "ffffff", nil, true)
  end
  local player = bo2.player
  local scn_id = bo2.scn.scn_excel.id
  if sys.check(scn_data) then
    scn_id = scn_data
  end
  if scn_id == 70 then
    ui_qbar.ui_keyboard.show_mini(true, ui.rect(-6, 30, 300, 220))
    ui_qbar.ui_keyboard.flash_clear()
    ui_qbar.ui_keyboard.disable_all_key({"space"})
  elseif scn_id == 71 then
    ui_qbar.ui_keyboard.show_mini(true, ui.rect(-6, 30, 300, 220))
    ui_qbar.ui_keyboard.flash_clear()
    ui_qbar.ui_keyboard.flash_insert_keys({"shift"})
  elseif scn_id == 72 then
    ui_qbar.ui_keyboard.show_mini(true, ui.rect(-6, 30, 300, 220))
    ui_qbar.ui_keyboard.flash_clear()
    ui_qbar.ui_keyboard.flash_insert_keys({
      "w",
      "a",
      "s",
      "d"
    })
  elseif scn_id == 73 then
    ui_qbar.ui_keyboard.show_mini(true, ui.rect(-6, 30, 300, 220))
    ui_qbar.ui_keyboard.flash_clear()
    ui_qbar.ui_keyboard.flash_insert_keys({
      "shift",
      "w",
      "a",
      "s",
      "d"
    })
  end
  ui_handson_teach.test_complate_keyboard(true, scn_id)
  if scn_id == 70 then
  elseif scn_id == 143 then
  else
    ui_zdteach.space_notify.visible = false
  end
  if g_tip_frame ~= nil then
    g_tip_frame.visible = false
  end
end
reg(packet.eSTC_UI_ZdteachOpen, handle_open_ui, sig)
function handle_close_ui(cmd, data)
  ui_qbar.ui_keyboard.show_mini(false)
  local scn = bo2.scn
  if sys.check(scn) ~= true then
    return
  end
  local scn_id = scn.scn_excel.id
  ui_handson_teach.test_complate_keyboard(false, scn_id)
  if scn.scn_excel.id == 70 then
    ui_handson_teach.on_skill_active_use()
  end
end
reg(packet.eSTC_UI_ZdteachClose, handle_close_ui, sig)
function on_show_ctrl_pic(vis)
  ui_handson_teach.pic_ctrl_teach.visible = vis
  set_visible(vis)
  ui_zdteach.pic_flicker.visible = not vis
end
function on_confirm_click(btn)
  local parent = btn.topper
  local var = sys.variant()
  bo2.send_variant(packet.eCTS_ZDTeach_Ready, var)
  ui_zdteach.g_tip_frame.visible = false
end
function r0()
  local scn = 69
  for i = 0, 4 do
    do
      local scn0 = scn + i
      local function on_fun()
        show_com_ui(scn0)
      end
      bo2.AddTimeEvent(scn0 * i, on_fun)
    end
  end
end
function show_com_ui(_scn_id)
  local scn = bo2.scn
  if sys.check(scn) ~= true then
    return false
  end
  local scn_id = scn.scn_excel.id
  if _scn_id ~= nil and sys.check(_scn_id) then
    scn_id = _scn_id
  end
  local text_tb = {}
  if scn_id == 70 then
    text_tb = {
      83721,
      83722,
      83723
    }
  elseif scn_id == 71 then
    text_tb = {83728, 83729}
  elseif scn_id == 72 then
    text_tb = {83724}
  elseif scn_id == 73 then
    text_tb = {
      83725,
      83726,
      83727
    }
  else
    text_tb = {
      83721,
      83722,
      83723
    }
  end
  local stk = sys.stack()
  for i, v in ipairs(text_tb) do
    local excel_data = bo2.gv_text:find(v)
    if sys.check(excel_data) then
      stk:push(excel_data.text)
    end
  end
  local main_frame = g_tip_frame
  main_frame.visible = false
  main_frame.visible = true
  local rb_desc = ui_zdteach.rb_desc
  rb_desc.dock = L("fill_xy")
  rb_desc.parent.dock = L("fill_xy")
  rb_desc.mtf = stk.text
  local function fill_text()
    rb_desc.margin = ui.rect(10, 14, 6, 2)
    rb_desc.parent:tune("rv_text")
    rb_desc.parent.dock = L("pin_xy")
  end
  bo2.AddTimeEvent(1, fill_text)
  ui_zdteach.rb_notify.visible = true
  ui_zdteach.rb_notify.mtf = sys.format(L("<handson:0,5,,38>"))
end
function handle_open_film(cmd, data)
  local film_id = 0
  local player = bo2.player
  local scn_id = bo2.scn.scn_excel.id
  if scn_id == 70 then
    film_id = 4
  elseif scn_id == 71 then
    film_id = 8
  elseif scn_id == 72 then
    film_id = 6
  elseif scn_id == 73 then
    film_id = 7
  end
  local var = sys.variant()
  ui_npcfunc.ui_talk.on_close_talk(0, var)
  ui_film.execute_film(film_id, bo2.eFilmEnd_ZDTeach)
end
reg(packet.eSTC_ZDTeach_Film_Open, handle_open_film, sig)
function on_key()
end
function on_desc_visible(w, vis)
  ui_widget.on_leavescn_stk_visible(w, vis)
  w.focus = vis
end
local npc_table = {
  62811,
  62819,
  62815,
  62816,
  150616,
  150617,
  150618,
  150619,
  150620,
  150621,
  150622,
  25400
}
function on_Zdeach_mem(obj)
  local value = obj:get_flag_objmem(61)
  if value == 0 then
    return
  end
  if value == 2 or value == 3 then
    on_Zdeach_mem_xuezhan(obj)
  end
  local scn = bo2.scn
  if scn == nil then
    return
  end
  obj:set_flag_objmem(61, 0)
  local function find_npc(npc)
    local npc_id = npc.excel.id
    for i, v in ipairs(npc_table) do
      if npc_id == v then
        if value == -1 then
          scn:UnValidNpcHandsonTips(npc.sel_handle)
        else
          local text = sys.format(L("<handson:0,4,,37>"))
          scn:SetNpcHandsonTipsByHandle(npc.sel_handle, text)
        end
      end
    end
  end
  scn:ForEachScnObj(2, find_npc)
end
function on_Zdeach_mem_xuezhan(obj)
  local scn = bo2.scn
  if not scn then
    return
  end
  local value = obj:get_flag_objmem(61)
  local side = value == 2 and 1 or 0
  local text = side == 0 and sys.format(L("<handson:0,4,,138>")) or sys.format(L("<handson:0,4,,137>"))
  scn:ForEachScnObj(2, function(npc)
    if npc == bo2.player then
      return
    end
    if side ~= npc:get_flag_objmem(bo2.eFlagObjMemory_TempCamp) then
      return
    end
    scn:SetNpcHandsonTipsByHandle(npc.sel_handle, text)
    bo2.AddTimeEvent(150, function()
      scn:UnValidNpcHandsonTips(npc.sel_handle)
    end)
  end)
end
function on_self_enter(obj)
  obj:insert_on_flagmsg(bo2.eFlagType_ObjMemory, 61, on_Zdeach_mem, "ui_zdteach.on_Zdeach_mem")
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_zdteach.on_self_enter")
