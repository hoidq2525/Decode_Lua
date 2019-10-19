function on_ok()
  ui_skill_preview.w_skill_preview.visible = false
  local chk
  if w_chk_1.check then
    chk = w_chk_1
  elseif w_chk_2.check then
    chk = w_chk_2
  else
    ui_widget.ui_msg_box.show_common({
      text = ui.get_text("personal|select_pro_msg_prosel"),
      callback = on_msg,
      modal = true,
      btn_cancel = false
    })
    return
  end
  local pro_excel = chk.svar.pro_excel
  local function on_msg(msg)
    if msg.result == 0 then
      return
    end
    show(false)
    local v = sys.variant()
    v:set(packet.key.player_profession, pro_excel.id)
    bo2.send_variant(packet.eCTS_ScnObj_LevelUp, v)
  end
  ui_widget.ui_msg_box.show_common({
    text = ui_widget.merge_mtf({
      career = pro_excel.name
    }, ui.get_text("personal|choice_career")),
    callback = on_msg,
    modal = true
  })
end
function on_cancel()
  show(false)
end
function on_play()
  if w_chk_1.check then
  elseif w_chk_2.check then
  else
    ui_widget.ui_msg_box.show_common({
      text = ui.get_text("personal|select_pro_msg_skillview"),
      callback = on_msg,
      modal = true,
      btn_cancel = false
    })
    return
  end
  local player = ui_personal.ui_equip.safe_get_player()
  local pro_id = player:get_atb(bo2.eAtb_Cha_Profession)
  local pro_excel = bo2.gv_profession_list:find(pro_id)
  local preview_excel = bo2.gv_skill_preview_tree_view:find(pro_excel.skill_preview)
  if preview_excel == nil then
    return
  end
  local page = sys.format(L("skill_preview_tree_page%d"), preview_excel.inc_data)
  ui_widget.ui_tab.show_page(ui_skill_preview.w_main_skill_tree, page, true)
  ui_skill_preview.w_skill_preview.visible = true
  local chk = w_chk_1
  if not chk.check then
    chk = w_chk_2
  end
  pro_excel = chk.svar.pro_excel
  ui_skill_preview.on_pro_skill_preview()
  ui_skill_preview.set_preview_skill(pro_excel.skill_preview, 0)
end
function on_key(w, key, flag)
  if flag.down then
    return
  end
  if key == ui.VK_LEFT then
    w_chk_1.check = true
  elseif key == ui.VK_RIGHT then
    w_chk_2.check = true
  elseif key == ui.VK_RETURN then
    on_ok()
  elseif key == ui.VK_ESCAPE then
    if ui_skill_preview.w_skill_preview.visible then
      ui_skill_preview.w_skill_preview.visible = false
    else
      on_cancel()
    end
  end
end
function on_check(btn_chk, is_chk)
  local pro = btn_chk.svar.pro_excel
  w_pic_pro.image = sys.format("$image/personal/select_pro/pro_text/%d.png|0,0,100,180", pro.id)
  ui_portrait.make_career_color(w_pic_bg, pro)
  w_pic_flash.visible = false
  w_pic_bg.visible = true
  w_pic_pro.visible = true
end
local init_chk = function(w, i)
  local pro_excel = bo2.gv_profession_list:find(i)
  w.dx = 170
  w.text = pro_excel.name
  w.tip.text = pro_excel.desc
  w.svar.pro_excel = pro_excel
end
function show(vis)
  if vis == nil or not vis then
    w_select_pro.visible = false
    ui_skill_preview.w_skill_preview.parent = ui_main.w_top
    ui_skill_preview.w_skill_preview.visible = false
    ui_main.ShowUI(true, 500)
    return
  end
  w_select_pro.visible = true
  w_select_pro.focus = true
  w_select_pro:reset(0, 1, 1000)
  ui_main.ShowUI(false, 500)
  ui_skill_preview.w_skill_preview.parent = w_select_pro
  ui_skill_preview.w_skill_preview.visible = false
  local player = ui_personal.ui_equip.safe_get_player()
  local career = player:get_atb(bo2.eAtb_Cha_Profession)
  init_chk(w_chk_1, career + 1)
  init_chk(w_chk_2, career + 2)
  w_chk_1.check = false
  w_chk_2.check = false
  w_pic_flash.visible = true
  w_pic_bg.visible = false
  w_pic_pro.visible = false
end
function test()
  show(true)
end
