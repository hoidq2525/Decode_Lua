MAX_NUM = 10
MAX_DISPLAY_NUM = 5
local blank_lianzhao_id = 0
function init_once()
  if rawget(_M, "g_already_init") ~= nil then
    return
  end
  g_already_init = true
end
function clear()
  w_desc:item_clear()
  for i, v in ipairs(skills) do
    v.excel_id = 0
  end
end
function on_clear()
  clear()
end
function on_book(btn)
  local create_book = function(msg)
    if msg.result == 0 then
      return
    end
    bo2.send_variant(packet.eCTS_ScnObj_LineageSeriesBook, msg.data)
  end
  local index = get_cur_sel(last_highlight_ctrl)
  if index == nil then
    return
  end
  local var = sys.variant()
  var:set(packet.key.series_skill_id, index)
  local msg = {
    callback = create_book,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.title = ui.get_text("skill|create_book")
  msg.text = ui.get_text("skill|create_book_des")
  msg.data = var
  ui_widget.ui_msg_box.show_common(msg)
end
function on_ok(btn)
  local generate = function(msg)
    if msg.result == 0 then
      return
    end
    bo2.send_variant(packet.eCTS_ScnObj_SeriesSkill, msg.data)
  end
  local index = get_cur_sel(last_highlight_ctrl)
  if index == nil then
    return
  end
  if bedit == false then
    bedit = true
    w_desc.mouse_able = true
    btn:search("btn_color").text = ui.get_text("skill|generate")
    w_btn_clear.visible = true
    ui.log("desc %s length %s", lianzhao[index].desc, #lianzhao[index].skills)
    if lianzhao[index].desc == L("") and #lianzhao[index].skills == 0 then
      w_desc:item_clear()
      w_desc:insert_mtf(sys.format("<lb:,,,00B050|" .. ui.get_text("skill|lianzhao_input_desc") .. ">"))
    end
    return
  end
  if index < 1 or index > 5 then
    ui_tool.note_insert(ui.get_text("skill|select_default"), "FF0000")
    return
  end
  local var = sys.variant()
  local skill = sys.variant()
  for i, v in ipairs(skills) do
    if v.excel_id ~= 0 then
      skill:push_back(v.excel_id)
    end
  end
  var:set(packet.key.series_skill_id, index)
  var:set(packet.key.series_skill_data, skill)
  var:set(packet.key.series_skill_desc, w_desc.mtf)
  bo2.send_variant(packet.eCTS_ScnObj_SeriesSkill, var)
  local text
  text = w_desc.mtf
end
function get_cur_sel(card)
  for i, v in ipairs(lianzhao) do
    if v.ctrl == card then
      return i
    end
  end
end
function set_highlight(ctrl)
  if ctrl == last_highlight_ctrl then
    return
  end
  function set_highlight_in(ctrl, flag)
    if ctrl == nil then
      return
    end
    local highlight = ctrl:search("highlight")
    if highlight then
      highlight.visible = flag
    end
  end
  set_highlight_in(ctrl, true)
  set_highlight_in(last_highlight_ctrl, false)
  last_highlight_ctrl = ctrl
end
function on_serie_tip(tip)
  local card = tip.owner
  for k, v in pairs(lianzhao) do
    if v.ctrl == card then
      local stk = sys.mtf_stack()
      if k <= 5 and v.desc == L("") and #v.skills == 0 then
        if bedit == false then
          stk:raw_push("<lb:,,,00B050|" .. ui.get_text("skill|lianzhao_click_mod") .. ">")
        else
          stk:raw_push("<lb:,,,00B050|" .. ui.get_text("skill|lianzhao_input_desc") .. ">")
        end
      elseif k <= 5 then
        stk:raw_push(v.desc)
      elseif v.desc == L("") and #v.skills == 0 then
        stk:raw_push("<lb:,,,00B050|" .. ui.get_text("skill|no_edit") .. ">")
      else
        stk:raw_push(v.desc)
      end
      ui_tool.ctip_show(card, stk)
      break
    end
  end
end
function show_skills()
  clear()
  local index = get_cur_sel(last_highlight_ctrl)
  if index == nil then
    return
  end
  w_desc:insert_mtf(lianzhao[index].desc)
  if lianzhao[index].desc == L("") and #lianzhao[index].skills == 0 then
    if index <= 5 then
      w_desc:insert_mtf(sys.format("<lb:,,,00B050|" .. ui.get_text("skill|lianzhao_click_mod") .. ">"))
    else
      w_desc:insert_mtf(sys.format("<lb:,,,00B050|" .. ui.get_text("skill|no_edit") .. ">"))
    end
  end
  for i, v in ipairs(lianzhao[index].skills) do
    skills[i].excel_id = v
  end
end
function insert_lianzhao(cmd, data)
  local id = data:get(packet.key.series_skill_id).v_int
  lianzhao[id].skills = {}
  lianzhao[id].desc = data:get(packet.key.series_skill_desc).v_string
  local s_data = data:get(packet.key.series_skill_data)
  for i = 0, s_data.size - 1 do
    table.insert(lianzhao[id].skills, s_data:get(i).v_int)
  end
  show_skills()
  set_edit_false()
end
function on_window_visible(ctrl, vis)
  ui_widget.on_esc_stk_visible(ctrl, vis)
  if ctrl.visible == true then
    local length = ctrl.parent.size.x
    local w_skill = ui_skill.w_skill
    if w_skill.x + w_skill.dx / 2 > length / 2 then
      ctrl.x = w_skill.x - ctrl.dx
      ctrl.y = w_skill.y
    else
      ctrl.x = w_skill.x + w_skill.dx
      ctrl.y = w_skill.y
    end
    set_highlight(lianzhao[1].ctrl)
    show_skills()
    set_edit_false()
  end
end
function lianzhao_init()
  for i = 1, MAX_NUM do
    lianzhao[i] = {}
  end
end
function set_edit_false()
  bedit = false
  w_desc.mouse_able = false
  w_desc.focus = false
  w_btn_clear.visible = false
  w_btn_generate:search("btn_color").text = ui.get_text("skill|modify")
  local index = get_cur_sel(last_highlight_ctrl)
  local serie_excel = bo2.gv_serie_skill:find(index)
  if serie_excel == nil then
    return
  end
  if serie_excel.type == 0 then
    w_btn_generate.visible = false
  else
    w_btn_generate.visible = true
  end
end
function on_lianzhao_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    if card == last_highlight_ctrl then
      local index = get_cur_sel(card)
      if index == nil then
        ui.log("on_lianzhao_mouse:error index")
      end
      ui.set_cursor_icon(lianzhao[index].image)
      local on_drop_hook = function(w, msg, pos, data)
        if msg == ui.mouse_drop_clean then
        end
        if msg == ui.mouse_drop_setup then
        end
      end
      local data = sys.variant()
      data:set("drop_type", ui_widget.c_drop_type_lianzhao)
      data:set("id", index)
      ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
      return
    end
    set_highlight(card)
    show_skills()
    set_edit_false()
  elseif msg == ui.mouse_lbutton_drag then
    set_highlight(card)
    show_skills()
    local index = get_cur_sel(card)
    if index == nil then
      ui.log("on_lianzhao_mouse:error index")
    end
    ui.set_cursor_icon(lianzhao[index].image)
    local on_drop_hook = function(w, msg, pos, data)
      if msg == ui.mouse_drop_clean then
      end
      if msg == ui.mouse_drop_setup then
      end
    end
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_lianzhao)
    data:set("id", index)
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  elseif msg == ui.mouse_rbutton_click then
  end
end
function on_skill_card_mouse(card, msg, pos, data)
  if bedit == false then
    return
  end
  if card.excel_id == 0 then
    return
  end
  local icon
  if card.icon then
    icon = card.icon
  else
    return
  end
  local skill_info = ui.skill_find(card.excel_id)
  if skill_info == nil then
    return
  end
  if msg == ui.mouse_lbutton_down then
  elseif msg == ui.mouse_lbutton_drag then
    local index = get_cur_sel(last_highlight_ctrl)
    local serie_excel = bo2.gv_serie_skill:find(index)
    if serie_excel == nil then
      return
    end
    if serie_excel.type == 0 then
      ui_tool.note_insert(ui.get_text("skill|unedited"), "FF0000")
      return
    end
    if skill_info.type == 0 then
      return
    end
    ui.set_cursor_icon(icon.uri)
    local on_drop_hook = function(w, msg, pos, data)
      if msg == ui.mouse_drop_clean then
      end
      if msg == ui.mouse_drop_setup then
      end
    end
    local data = sys.variant()
    data:set("drop_type", ui_widget.c_drop_type_lianzhao)
    data:set("excel_id", card.excel_id)
    data:set("card", card:search("skill_card"))
    ui.setup_drop(ui_tool.w_drop_floater, data, on_drop_hook)
  elseif msg == ui.mouse_rbutton_click then
    local index = get_cur_sel(last_highlight_ctrl)
    local serie_excel = bo2.gv_serie_skill:find(index)
    if serie_excel == nil then
      return
    end
    if serie_excel.type == 0 then
      return
    end
    card.excel_id = 0
  end
end
function on_skill_card_drop(card, msg, pos, data)
  if msg ~= ui.mouse_lbutton_down and msg ~= ui.mouse_lbutton_up then
    return
  end
  if bedit == false then
    return
  end
  local index = get_cur_sel(last_highlight_ctrl)
  local serie_excel = bo2.gv_serie_skill:find(index)
  if serie_excel == nil then
    return
  end
  if serie_excel.type == 0 then
    ui_tool.note_insert(ui.get_text("skill|unedited"), "FF0000")
    return
  end
  ui.clean_drop()
  if not ui_widget.check_drop(data, ui_widget.c_drop_type_skill) and not ui_widget.check_drop(data, ui_widget.c_drop_type_lianzhao) and not ui_widget.check_drop(data, ui_widget.c_drop_type_shortcut) then
    return
  end
  local excel_id = data:get("excel_id").v_int
  if ui_widget.check_drop(data, ui_widget.c_drop_type_shortcut) then
    local idx_src = data:get("index").v_int
    local info_src = ui.shortcut_get(idx_src)
    if info_src.kind == bo2.eShortcut_Skill then
      excel_id = info_src.excel.id
    end
  end
  local serie_excel = bo2.gv_skill_series:find(excel_id)
  if serie_excel == nil then
    ui_tool.note_insert(ui.get_text("skill|unedited_skill"), "FF0000")
    return
  end
  local type = data:get("drop_type").v_string
  if type == ui_widget.c_drop_type_lianzhao then
    local pre_card = data:get("card").v_object
    pre_card.excel_id = card:search("skill_card").excel_id
  end
  card:search("skill_card").excel_id = excel_id
end
function on_init_lianzhao_skill_card()
  local item
  local uri = "$frame/skill/lianzhao.xml"
  local skill_sty = "card_serie_skill"
  for i = 1, 15 do
    item = ui.create_control(w_lianzhao_skill, "divider")
    item:load_style(uri, skill_sty)
    table.insert(skills, item:search("skill_card"))
  end
end
function on_init_lianzhao_icon_card()
  local item
  local uri = "$frame/skill/lianzhao.xml"
  local skill_sty = "card_lianzhao"
  local pic
  for i = 6, 10 do
    item = ui.create_control(w_sys_lianzhao:search("lianzhao_icon"), "divider")
    item:load_style(uri, skill_sty)
    pic = bo2.gv_serie_skill:find(i).icon
    item:search("lianzhao_icon").image = "$icon/skill/lianzhao/" .. pic .. ".png"
    lianzhao[i] = {
      ctrl = item,
      skills = {},
      image = item:search("lianzhao_icon").image
    }
  end
  for i = 1, 5 do
    item = ui.create_control(w_self_lianzhao:search("lianzhao_icon"), "divider")
    item:load_style(uri, skill_sty)
    pic = bo2.gv_serie_skill:find(i).icon
    item:search("lianzhao_icon").image = "$icon/skill/lianzhao/" .. pic .. ".png"
    lianzhao[i] = {
      ctrl = item,
      skills = {},
      image = item:search("lianzhao_icon").image
    }
  end
end
function test_insert_lianzhao(index, id)
end
function display_serie_skills()
  for i, v in ipairs(display_list) do
    w_display:search("pic" .. i).image = v.image
  end
  w_display:reset(0, 1, 1, 0)
  w_display.visible = true
end
function start(id)
  local icon = ui.get_skill_icon(id)
  if icon ~= nil then
    table.insert(display_list, 1, {
      skill_id = id,
      image = icon.uri
    })
  else
    table.insert(display_list, 1, {skill_id = id, image = ""})
  end
  if #display_list > MAX_DISPLAY_NUM then
    table.remove(display_list, #display_list)
  end
  display_serie_skills()
end
function using_serie(cmd, data)
  local id = data:get("id").v_int
  if id < 1 or id > MAX_NUM then
    ui.log("error lianzhao index")
  end
  if cur_index == 0 then
    start(lianzhao[id].skills[1])
    start(lianzhao[id].skills[2])
    start(lianzhao[id].skills[3])
    cur_index = 1
  else
    cur_index = cur_index + 1
    start(lianzhao[id].skills[cur_index + 2])
  end
end
function serie_end()
  for i = 1, 5 do
    w_display:search("pic" .. i).image = ""
  end
  w_display:reset(1, 0, 500)
  display_list = {}
  cur_index = 0
end
function on_serie_card_tip_show(tip)
  local card = tip.owner
  local excel_id = card.excel_id
  if excel_id == nil or excel_id == 0 then
    return
  end
  local stk = sys.mtf_stack()
  local info = ui.skill_find(card.excel_id)
  if info == nil then
    ui.log("on_skill_card_tip_show info is nil")
    return
  end
  if info.type == 1 then
    ui_tool.ctip_make_skill(stk, info)
  elseif info.type == 0 then
    ui_tool.ctip_make_passive_skill(stk, info)
  else
    return
  end
  if bedit then
    stk:push(ui.get_text("skill|right_click_to_del"))
  end
  ui_tool.ctip_show(card, stk)
end
function on_init()
  last_highlight_ctrl = nil
  lianzhao = {}
  skills = {}
  display_list = {}
  on_init_lianzhao_skill_card()
  on_init_lianzhao_icon_card()
  set_highlight(lianzhao[1].ctrl)
  show_skills()
  cur_index = 0
  bedit = false
end
function on_blank_card_drop(card, msg, pos, data)
  if msg == ui.mouse_lbutton_up then
    if data:get("disable_lbutton_up").v_int == 1 then
      return
    end
  elseif msg ~= ui.mouse_lbutton_down then
    return
  end
  local drop_type = data:get("drop_type").v_string
  local excel_id = data:get("excel_id").v_int
  local index = data:get("index").v_int
  local parent = card.parent.parent
  local pic = parent:search("icon")
  if drop_type == ui_widget.c_drop_type_lianzhao then
    local id = data:get("id").v_int
    if id > 5 then
      return
    end
    pic.image = lianzhao[id].image
    ui.clean_drop()
    blank_lianzhao_id = id
  elseif drop_type == ui_widget.c_drop_type_shortcut then
    local info_src = ui.shortcut_get(index)
    if info_src == nil then
      return
    end
    if info_src.kind == bo2.eShortcut_LianZhao then
      local id = info_src.only_id.v_int
      if id > 5 then
        return
      end
      pic.image = info_src.icon.uri
      ui.clean_drop()
      blank_lianzhao_id = id
    end
  end
end
function create_new_book(msg)
  if msg.result == 0 then
    blank_lianzhao_id = 0
    return
  end
  local var = sys.variant()
  var:set(packet.key.series_skill_id, blank_lianzhao_id)
  bo2.send_variant(packet.eCTS_ScnObj_LineageSeriesBook, var)
  blank_lianzhao_id = 0
end
function get_lianzhao_skill(id)
  local info = lianzhao[id]
  local var = sys.variant()
  for i, id in ipairs(info.skills) do
    var:push_back(id)
  end
  return var
end
init_once()
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_lianzhao.insert_lianzhao:on_signal"
reg(packet.eSTC_ScnObj_SeriesSkill, insert_lianzhao, sig)
sig = "ui_lianzhao.using_serie:on_signal"
reg(packet.eSTC_ScnObj_SkillSeriesId, using_serie, sig)
sig = "ui_lianzhao.serie_end:on_signal"
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_serie_end, serie_end, sig)
ui.insert_on_get_lianzhao_skill(get_lianzhao_skill, sig)
