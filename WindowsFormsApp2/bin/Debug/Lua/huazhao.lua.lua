function on_window_visible(ctrl, vis)
  ui_widget.on_esc_stk_visible(ctrl, vis)
  if ctrl.visible == true then
    local length = ctrl.parent.size.x
    local w_skill = ui_skill.w_skill
    ctrl.x = w_skill.x + w_skill.dx - 6
    ctrl.y = w_skill.y
    w_skill.dock = "none"
    w_skill.x = ctrl.x - w_skill.dx + 6
  end
end
function on_scratch_skill_tip_show(tip)
  local panel = tip.owner
  local card = panel:search("skill_card")
  local excel = card.excel
  if excel == nil then
    local stk = sys.mtf_stack()
    stk:raw_push(ui.get_text("skill|scratch_skill_none_tips"))
    ui_tool.ctip_show(panel, stk)
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_shortcut(stk, excel, card.info)
  local stk_use
  ui_tool.ctip_show(panel, stk, stk_use)
end
function on_init_scratch_skill_edit(ctrl, data)
  local uri = "$frame/skill/huazhao.xml"
  local skill_sty = "card_scratch_skill"
  local list_num = bo2.gv_scratch_skill_list.size
  if list_num > 12 then
    ui.log("!!!!There are over 12 element in scratch_skill_list.txt!!!")
    return
  end
  for i = 0, list_num - 1 do
    local line = bo2.gv_scratch_skill_list:get(i)
    item = ui.create_control(w_scratch_div, "panel")
    item:load_style(uri, skill_sty)
    item:search("lb_desc").text = line.desc
    item:search("skill_card").index = 62 + i
    if item:search("skill_card").index >= 78 then
      item:search("skill_card").index = 0
    end
    ui_skill.scratch_skill_edit_ctrl[line.id] = item
  end
end
function on_close_huazhao()
  ui_huazhao.w_huazhao.visible = false
end
g_resource_path = "$image/skill/scratch_skill/"
g_describe_path = "skill|scratch_skill_des_"
g_resource_maxnum = 3
g_resource_curnum = 1
function on_click_prev(btn)
  g_resource_curnum = g_resource_curnum - 1
  if g_resource_curnum <= 1 then
    w_prev.enable = false
    g_resource_curnum = 1
  end
  w_yanshi.image = g_resource_path .. g_resource_curnum .. ".png|0,0,329,183"
  w_yanshi_des.text = ui.get_text(g_describe_path .. g_resource_curnum)
  if not w_next.enable then
    w_next.enable = true
  end
end
function on_click_next(btn)
  g_resource_curnum = g_resource_curnum + 1
  if g_resource_curnum >= g_resource_maxnum then
    w_next.enable = false
    g_resource_curnum = g_resource_maxnum
  end
  w_yanshi.image = g_resource_path .. g_resource_curnum .. ".png|0,0,329,183"
  w_yanshi_des.text = ui.get_text(g_describe_path .. g_resource_curnum)
  if not w_prev.enable then
    w_prev.enable = true
  end
end
function on_init()
  w_prev.enable = false
  w_yanshi_des.text = ui.get_text(g_describe_path .. g_resource_curnum)
end
