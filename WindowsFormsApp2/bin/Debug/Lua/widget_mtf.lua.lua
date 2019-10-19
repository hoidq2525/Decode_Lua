function mtf_init()
  local use_cpp_impl = true
  mtf_data = {}
  local mtf_widget = {
    img = {on_init = mtf_img_on_init, is_cpp = true},
    num = {on_init = mtf_num_on_init},
    medal = {on_init = mtf_medal_on_init},
    m = {
      on_init = mtf_m_on_init,
      on_reset = mtf_m_on_reset,
      is_cpp = true
    },
    bm = {
      on_init = mtf_bm_on_init,
      on_reset = mtf_bm_on_reset,
      is_cpp = true
    },
    guild_person_contri = {on_init = mtf_guild_person_contri_on_init, on_reset = mtf_guild_person_contri_on_reset},
    guild_flexible_contri = {on_init = mtf_guild_flexible_contri_on_init, on_reset = mtf_guild_flexible_contri_on_reset},
    errantry = {on_init = mtf_errantry_on_init, on_reset = mtf_errantry_on_reset},
    doopoint = {on_init = mtf_doopoint_on_init, on_reset = mtf_doopoint_on_reset},
    camp_repute = {on_init = mtf_camp_repute_on_init, on_reset = mtf_camp_repute_on_reset},
    u = {
      on_init = mtf_u_on_init,
      on_reset = mtf_u_on_reset,
      mouse_able = true,
      is_cpp = true
    },
    openui = {
      on_init = mtf_openui_on_init,
      on_reset = mtf_openui_on_reset,
      mouse_able = true
    },
    q_user = {
      on_init = mtf_q_user_on_init,
      on_reset = mtf_u_on_reset,
      mouse_able = true,
      on_mouse = mtf_on_mouse_q_user
    },
    vip = {on_init = mtf_vip_on_init},
    ver_number = {on_init = mtf_ver_on_init, on_reset = mtf_ver_on_reset},
    ver_date = {on_init = mtf_ver_on_init, on_reset = mtf_ver_on_reset},
    i = {
      on_init = mtf_i_on_init,
      on_reset = mtf_i_on_reset,
      on_text = mtf_i_on_text,
      on_cost = mtf_i_on_cost,
      mouse_able = true,
      is_cpp = true
    },
    fi = {
      on_init = mtf_fi_on_init,
      on_reset = mtf_fi_on_reset,
      on_text = mtf_fi_on_text,
      on_cost = mtf_fi_on_cost,
      mouse_able = true,
      is_cpp = true
    },
    si = {
      on_init = mtf_si_on_init,
      on_reset = mtf_si_on_reset,
      on_text = mtf_fi_on_text,
      on_cost = mtf_si_on_cost,
      mouse_able = true,
      is_cpp = true
    },
    cii = {on_init = mtf_cii_on_init, on_reset = mtf_cii_on_reset},
    cii2 = {on_init = mtf_cii_on_init, on_reset = mtf_cii_on_reset},
    scii = {on_init = mtf_scii_on_init, on_reset = mtf_scii_on_reset},
    star = {on_init = mtf_star_on_init},
    drop_type = {
      on_init = mtf_drop_type_on_init,
      on_reset = mtf_drop_type_on_reset,
      on_text = mtf_drop_type_on_text,
      on_cost = mtf_drop_type_on_cost,
      mouse_able = true
    },
    evaluate = {on_init = mtf_evaluate_on_init},
    ridepet = {
      on_init = mtf_ridepet_on_init,
      on_reset = mtf_ridepet_on_reset,
      on_text = mtf_ridepet_on_text,
      on_cost = mtf_ridepet_on_cost,
      mouse_able = true
    },
    lb = {on_init = mtf_lb_on_init, on_reset = mtf_lb_on_reset},
    rb = {on_init = mtf_rb_on_init, on_reset = mtf_rb_on_reset},
    url = {
      on_init = mtf_url_on_init,
      on_reset = mtf_url_on_reset,
      mouse_able = true
    },
    mid_lb = {on_init = mtf_mid_lb_on_init},
    sel = {
      on_init = mtf_sel_on_init,
      on_reset = mtf_sel_on_reset,
      on_mouse = mtf_sel_on_mouse,
      mouse_able = true
    },
    popo = {on_init = mtf_popo_on_init, on_reset = mtf_popo_on_reset},
    popo_x1 = {on_init = mtf_popo_on_init, on_reset = mtf_popo_on_reset},
    call = {on_init = mtf_call_on_init, on_reset = mtf_call_on_reset},
    player = {on_init = mtf_player_on_init, on_reset = mtf_player_on_reset},
    mark = {
      on_init = mtf_mark_on_init,
      on_reset = mtf_mark_on_reset,
      mouse_able = true
    },
    sep = {on_init = mtf_sep_on_init, stretch = true},
    key = {on_init = mtf_key_on_init, on_reset = mtf_key_on_reset},
    space = {on_init = mtf_space_on_init, on_reset = mtf_space_on_reset},
    skill = {
      on_init = mtf_skill_on_init,
      on_reset = mtf_skill_on_reset,
      mouse_able = true
    },
    skill = {
      on_init = mtf_skill_on_init_id,
      on_reset = mtf_skill_on_reset,
      mouse_able = true
    },
    xinfa = {
      on_init = mtf_xinfa_on_init,
      on_reset = mtf_xinfa_on_reset,
      mouse_able = true
    },
    ch = {
      on_init = mtf_ch_on_init,
      on_reset = mtf_ch_on_reset,
      mouse_able = true,
      is_cpp = true
    },
    imn = {
      on_init = mtf_imn_on_init,
      on_reset = mtf_imn_on_reset,
      mouse_able = true
    },
    arena = {
      on_init = mtf_arena_on_init,
      on_reset = mtf_arena_on_reset,
      mouse_able = true
    },
    matchscn = {
      on_init = mtf_matchscn_on_init,
      on_reset = mtf_matchscn_on_reset,
      mouse_able = true
    },
    skill_icon = {on_init = mtf_skill_icon_on_init},
    skill_small_icon = {on_init = mtf_skill_small_icon_on_init},
    xinfa_icon = {on_init = mtf_xinfa_icon_on_init},
    guide = {
      on_init = mtf_guide_on_init,
      on_mouse = mtf_guide_data_on_mouse,
      mouse_able = false
    },
    guide_item = {on_init = mtf_guide_item_on_init, on_reset = mtf_guide_item_on_reset},
    handson = {
      on_init = mtf_handson_on_init,
      on_reset = mtf_handson_on_reset,
      mouse_able = false
    },
    fitting = {on_init = mtf_fitting_on_init, mouse_able = true},
    btn = {on_init = mtf_btn_on_init, on_reset = mtf_btn_on_reset},
    ext = {on_init = mtf_ext_on_init, on_reset = mtf_ext_on_reset},
    mouse_anim = {on_init = mtf_init_mouse_anim},
    quest = {
      on_init = mtf_quest_on_init,
      on_reset = mtf_quest_on_reset,
      mouse_able = true,
      on_mouse = mtf_quest_on_mouse
    },
    milestone = {
      on_init = mtf_milestone_on_init,
      on_reset = mtf_milestone_on_reset,
      mouse_able = true,
      on_mouse = mtf_milestone_on_mouse
    },
    imt = {on_init = mtf_imt_on_init, on_reset = mtf_imt_on_reset},
    spmk = {on_init = mtf_spmk_on_init, mouse_able = false},
    spmk_lb = {
      on_init = mtf_spmk_lb_on_init,
      mouse_able = true,
      on_mouse = mtf_spmk_lb_on_click
    },
    trait = {
      on_init = mtf_trait_on_init,
      on_reset = mtf_trait_on_reset,
      mouse_able = false
    },
    ridepet_skill_icon = {on_init = mtf_ridepet_skill_icon_on_init},
    position = {
      on_init = mtf_position_on_init,
      on_reset = mtf_position_on_reset,
      mouse_able = true
    },
    useskill = {on_init = mtf_useskill_on_init, mouse_able = true},
    useitem = {on_init = mtf_useitem_on_init, mouse_able = true},
    img_bg = {on_init = mtf_img_bg_on_init},
    rmb = {on_init = mtf_rmb_on_init},
    brmb = {on_init = mtf_rmb_on_init},
    jfrmb = {on_init = mtf_rmb_on_init},
    daibi = {on_init = mtf_rmb_on_init},
    sp_panel = {on_init = mtf_sp_panel_on_init},
    table_idx_info = {on_init = mtf_table_idx_info}
  }
  local mtf_color = {
    ["#red"] = "FF0000",
    ["#green"] = "00FF00",
    ["#blue"] = "0000FF",
    ["#yellow"] = "FFFF00"
  }
  for n, v in pairs(mtf_widget) do
    if (not use_cpp_impl or not v.is_cpp) and not ui.def_rd_widget(n, v.on_init, v.on_text, v.on_cost, v.on_reset, v.on_mouse, v.mouse_able, v.stretch) then
      ui.log("failed def_rd_widget '%s'.", n)
    end
  end
  for n, v in pairs(mtf_color) do
    if not ui.def_rd_color(n, ui.make_color(v)) then
      ui.log("failed def_rd_color '%s'.", n)
    end
  end
  handson_margin = {}
  handson_margin[0] = ui.rect(10, 10, 10, 35)
  handson_margin[1] = ui.rect(35, 10, 10, 10)
  handson_margin[2] = ui.rect(10, 10, 35, 10)
  handson_margin[3] = ui.rect(10, 35, 10, 10)
  handson_margin[4] = ui.rect(10, 10, 10, 35)
  handson_margin[5] = ui.rect(10, 32, 10, 10)
  handson_margin[6] = ui.rect(10, 10, 30, 10)
  handson_margin[7] = ui.rect(30, 10, 10, 10)
end
local cs_mtf_style_uri = SHARED("$widget/widget_mtf.xml")
local cs_mtf_img = SHARED("img")
local cs_mtf_card = SHARED("card")
local cs_mtf_rb_text = SHARED("rb_text")
local cs_mtf_text = SHARED("text")
local cs_mtf_icon = SHARED("icon")
local cs_mtf_btn_close = SHARED("btn_close")
local cs_mtf_btn_fitting = SHARED("btn_fitting")
local cs_fmt_u = SHARED("%s")
local cs_fmt_ch = SHARED("[%s]")
local cs_fmt_i = SHARED("%s")
local cs_fmt_business = SHARED("$image/mtf/business/frame.xml|_%s")
local cs_fmt_medal = SHARED("$image/mtf/medal/frame.xml|_%s")
local cs_fmt_anim = SHARED("$image/help/anim/frame.xml|_%s")
local cs_fmt_quest = SHARED("%s")
local cs_fill_xy = SHARED("fill_xy")
local cs_pin_xy = SHARED("pin_xy")
local cs_pin_x1 = SHARED("pin_x1")
local cs_ext_x1 = SHARED("ext_x1")
local cs_ext_x1y1 = SHARED("ext_x1y1")
local cs_comma = SHARED(",")
local cs_picture = SHARED("picture")
local cs_fmt_vip = SHARED("$image/widget/btn/vip_btn%s.png|0,0,39,68")
local c_color_FFFFFFFF = ui.make_color("FFFFFFFF")
function mtf_img_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  local uri, xy = data.value:split2("*")
  p.image = uri
  if xy.empty then
    w:tune(data.name)
  else
    local dx, dy = xy:split2(",")
    w.dx = dx.v_int
    w.dy = dy.v_int
  end
  return true
end
function mtf_img_bg_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  w.dock_solo = true
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local uri, padding_bg_xy = data.value:split2("*")
  local padding, bg_xy = padding_bg_xy:split2("*")
  local bg_uri, xy = bg_xy:split2("*")
  local p = w:search("img")
  p.image = uri
  p.margin = ui.rect(padding.v_int, padding.v_int, padding.v_int, padding.v_int)
  p = w:search("bg")
  p.image = bg_uri
  if xy.empty then
    w:tune(data.name)
  else
    local dx, dy = xy:split2(",")
    w.dx = dx.v_int
    w.dy = dy.v_int
  end
  return true
end
local _rmbPic = {
  [L("rmb")] = L("$image/supermarket/qb_icon.png|4,3,20,20"),
  [L("brmb")] = L("$image/supermarket/rmb_icon.png|2,2,21,20"),
  [L("jfrmb")] = L("$image/supermarket/jf_icon.png|4,3,20,20"),
  [L("daibi")] = L("$image/supermarket/daibi_icon.png|0,0,22,22")
}
function mtf_rmb_on_init(box, data, mtf)
  local val = sys.stack()
  val:push(_rmbPic[data.name])
  val:push(L("*"))
  if not data.value.empty then
    local h = data.value.v_int
    if data.name == L("brmb") then
      val:push(math.floor(1.05 * h))
      val:push(L(","))
      val:push(h)
    else
      val:push(h)
      val:push(L(","))
      val:push(h)
    end
  end
  return mtf_img_on_init(box, {
    widget = data.widget,
    name = "img",
    value = val.str
  }, mtf)
end
local cs_num_style_uri = {
  SHARED("$widget/digit.xml"),
  SHARED("$widget/digit1.xml"),
  SHARED("$widget/digit2.xml"),
  SHARED("$widget/digit3.xml")
}
local ct_num_style_name_32 = {
  SHARED("d32_0"),
  SHARED("d32_1"),
  SHARED("d32_2"),
  SHARED("d32_3"),
  SHARED("d32_4"),
  SHARED("d32_5"),
  SHARED("d32_6"),
  SHARED("d32_7"),
  SHARED("d32_8"),
  SHARED("d32_9"),
  SHARED("d32_-")
}
local ct_num_style_name_64 = {
  SHARED("d64_0"),
  SHARED("d64_1"),
  SHARED("d64_2"),
  SHARED("d64_3"),
  SHARED("d64_4"),
  SHARED("d64_5"),
  SHARED("d64_6"),
  SHARED("d64_7"),
  SHARED("d64_8"),
  SHARED("d64_9"),
  SHARED("d64_-")
}
function mtf_num_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local value, size, color, index, text = data.value:split(cs_comma, 5)
  value = value.v_int
  if color == nil or color.empty then
    color = mtf.color
  else
    color = ui.make_color(color)
  end
  if size == nil or size.empty then
    size = 32
  else
    size = size.v_int
  end
  if index == nil or index.empty then
    index = 1
  else
    index = index.v_int + 1
  end
  local lb_size = 0
  if text ~= nil then
    local lb_txt = w:search("lb_txt")
    lb_txt.color = color
    lb_txt.text = text
    lb_txt.visible = true
    lb_size = w:search("lb_txt").dx
  end
  local sn, fac
  if size <= 32 then
    sn = ct_num_style_name_32
    fac = size / 32
  else
    sn = ct_num_style_name_64
    fac = size / 64
  end
  w.dy = size
  local neg = false
  if value < 0 then
    value = -value
    neg = true
  end
  local ext = 0
  local style_uri = cs_num_style_uri[index]
  repeat
    local m = math.mod(value, 10)
    value = math.floor(value / 10)
    local pic = ui.create_control(w, cs_picture)
    pic:load_style(style_uri, sn[m + 1])
    local dx = pic.dx * fac
    pic.dx = dx
    pic.color = color
    ext = ext + dx
  until value <= 0
  if neg then
    local pic = ui.create_control(w, cs_picture)
    pic:load_style(style_uri, sn[11])
    local dx = pic.dx * fac
    pic.dx = dx
    pic.color = color
    ext = ext + dx
  end
  w.dx = ext + lb_size
  return true
end
function mtf_business_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.animation = sys.format(cs_fmt_business, data.value)
  w:tune(data.name)
  return true
end
function mtf_init_mouse_anim(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local flicker_type = data.value:split(",", 1)
  if flicker_type ~= nil then
    local iflicker = flicker_type.v_int
    if iflicker == 1 then
      local p = w:search(L("left"))
      p.visible = true
    elseif iflicker == 2 then
      local p = w:search(L("mid"))
      p.visible = true
    elseif iflicker == 3 then
      local p = w:search(L("right"))
      p.visible = true
    elseif iflicker == 4 then
      local p = w:search("right_down")
      p.visible = true
    end
  end
  w:tune(L("_mouse_anim"))
  return true
end
function mtf_medal_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.animation = sys.format(cs_fmt_medal, data.value)
  w:tune(data.name)
  return true
end
function mtf_m_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  w:tune(data.name)
  return true
end
function mtf_m_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.money = data.value.v_number
  p.color = mtf.color
  p.font = mtf.format.font
  w:tune(data.name)
  return true
end
function mtf_bm_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  w:tune(data.name)
  return true
end
function mtf_bm_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.money = data.value.v_number
  p.color = mtf.color
  p.font = mtf.format.font
  w:tune(data.name)
  return true
end
function mtf_u_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_openui_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_q_user_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local name, color = data.value:split2(",")
  local p = w:search(data.name)
  if color ~= "" then
    p.color = ui.make_color(color)
  else
    p.color = ui.make_color("ffffff")
  end
  p.font = mtf.format.font
  p.text = sys.format(cs_fmt_u, name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_u_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local name, color = data.value:split2(",")
  local p = w:search(data.name)
  if color == "" then
    p.color = ui.make_color(color)
  else
    p.color = ui.make_color("ffffff")
  end
  p.font = mtf.format.font
  p.text = sys.format(cs_fmt_u, name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_openui_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local name, uiid, color = data.value:split(",", 3)
  uiid = uiid.v_int
  local p = w:search(data.name)
  if color ~= "" and nil ~= color then
    p.color = ui.make_color(color)
  else
    p.color = ui.make_color("ffffff")
  end
  p.font = mtf.format.font
  p.text = sys.format(cs_fmt_u, name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_on_mouse_q_user(box, data, msg, pt)
  if msg == ui.mouse_rbutton_click then
    ui_chat_list.on_widget_mouse(box, data, msg, pt)
    return
  end
end
function mtf_vip_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search("vip_btn")
  if not p then
    return false
  end
  local vip_lvl, str = data.value:split2(",")
  vip_lvl = vip_lvl.v_number
  local style
  style, str = str:split2(",")
  style = style.v_number
  local btn_text = ui.get_text("supermarket|mtfprivilege")
  p.text = vip_lvl == 0 and btn_text or sys.format(L("%s%d"), btn_text, vip_lvl)
  if style == 3 and str ~= nil and str ~= L("") then
    local t_min = str:split2(",")
    if vip_lvl < t_min.v_number then
      style = 2
    else
      style = 1
    end
  end
  if 2 == style then
    local vip_lbl = p:search("vip_lbl")
    local color1 = ui.make_color("050505")
    local color2 = ui.make_color("c6c6c6")
    vip_lbl.tint_normal = ui.tint(color1, color2)
    vip_lbl.tint_hover = ui.tint(color1, color2)
    vip_lbl.tint_press = ui.tint(color1, color2)
    vip_lbl.tint_disable = ui.tint(color1, color2)
  end
  p:search("vip_fig").image = sys.format(cs_fmt_vip, style)
  local tstr
  local idx = 1
  while str ~= nil and str ~= L("") do
    tstr, str = str:split2(",")
    p.var:set(idx, tstr.v_number)
    idx = idx + 1
  end
  p.var:set(0, idx - 1)
  return true
end
function on_mtf_vip_click(btn)
  local panel = btn
  local t = {}
  local count = panel.var:get(0).v_int
  for i = 1, count do
    table.insert(t, panel.var:get(i).v_int)
  end
  ui_supermarket2.w_privilege.visible = true
  ui_supermarket2.highlight_item(unpack(t))
end
function on_mtf_vip_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_inner or msg == ui.mouse_outer then
    item.parent:search("highlight").visible = false
  else
    item.parent:search("highlight").visible = true
  end
end
local ver_data
function mtf_ver_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_ver_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  if ver_data == nil then
    local x = sys.xnode()
    x:load("$data/option/client.xml")
    ver_data = {
      [L("ver_number")] = x:xget_attribute("version/@value"),
      [L("ver_date")] = x:xget_attribute("date/@value")
    }
  end
  local p = w:search(data.name)
  p.color = mtf.color
  p.font = mtf.format.font
  p.text = ver_data[data.name]
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_call_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
local gv_npc_call = bo2.gv_npc_call
function mtf_call_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.color = mtf.color
  p.font = mtf.format.font
  if gv_npc_call ~= nil then
    local call_def
    local cha_id = mtf.affix:get("cha_id").v_int
    if cha_id > 0 then
      local cha = bo2.gv_cha_list:find(cha_id)
      if cha ~= nil then
        local call_id = cha.call
        if call_id > 0 then
          call_def = gv_npc_call:find(call_id)
        end
      end
    else
      local call_id = data.value.v_int
      if call_id > 0 then
        call_def = gv_npc_call:find(call_id)
      end
    end
    if call_def == nil then
      call_def = gv_npc_call:find(1)
    end
    local prop_id = 0
    local self = bo2.player
    if self ~= nil then
      local sex = self:get_atb(bo2.eAtb_Sex)
      if sex == 2 then
        prop_id = 1
      end
    end
    local text = call_def["prop_" .. prop_id]
    p.text = text
  end
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_player_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_player_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.color = mtf.color
  p.font = mtf.format.font
  if ui_personal ~= nil then
    p.text = ui_personal.ui_equip.safe_get_player().name
  end
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_mark_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
local mark_color = ui.make_color("279DE9")
function mtf_mark_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.color = mtf.color
  if mtf.color == -1 then
    p.color = mark_color
  end
  p.font = mtf.format.font
  local id, name = data.value:split2(",")
  id = id.v_int
  if id == 0 and not name.empty then
    local size = bo2.gv_mark_list.size
    for i = 0, size - 1 do
      if name == bo2.gv_mark_list:get(i).enter_point then
        id = bo2.gv_mark_list:get(i).id
        break
      end
    end
  end
  local mark = bo2.gv_mark_list:find(id)
  if mark == nil then
    p.text = sys.format("mark%d", id)
  else
    p.text = mark.name
    local scn = bo2.gv_scn_list:find(mark.scn_id)
    if scn ~= nil then
      local scn_text = sys.format("(%s)", scn.name)
      p.text = p.text .. scn_text
    end
    local var = box.var:get(packet.key.ui_text_id)
    local v_size = var.size
    local pname = w:search(L("pname"))
    pname.name = sys.format(L("h_m%d"), v_size)
    var:push_back(id)
    box.var:set(packet.key.ui_text_id, var)
  end
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_i_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_i_on_text(box, data)
  local excel = ui.item_get_excel(data.value.v_int)
  return sys.format("[%s]", excel.name)
end
function mtf_i_on_cost(box, data)
  local excel = ui.item_get_excel(data.value.v_int)
  return box:make_char_cost(excel.name) + 2
end
function mtf_i_on_init(box, data, mtf)
  local excel = ui.item_get_excel(data.value.v_int)
  if excel == nil then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  local lootlevel = excel.plootlevel_star
  if lootlevel ~= nil then
    p.color = ui.make_color(lootlevel.color)
  end
  p.text = sys.format(cs_fmt_i, excel.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_ridepet_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_ridepet_on_text(box, data)
  local name = ui.ride_get_name_by_code(data.value)
  return sys.format("[%s]", name)
end
function mtf_ridepet_on_cost(box, data)
  local name = ui.ride_get_name_by_code(data.value)
  return box:make_char_cost(name) + 2
end
function mtf_ridepet_on_init(box, data, mtf)
  local name = ui.ride_get_name_by_code(data.value)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.text = sys.format(cs_fmt_i, name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
local mtf_get_item_color = function(excel_id, code)
  local info = ui.item_create(excel_id, bo2.eItemBox_Special, bo2.eItemBox_Special_Code)
  info.code = code
  local lootlevel = info.plootlevel_star
  if lootlevel == nil then
    return ui.make_color("FFFFFF")
  end
  return ui.make_color(lootlevel.color)
end
function mtf_fi_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_fi_on_text(box, data)
  local name = ui.get_item_name_by_code(data.value)
  return sys.format("[%s]", name)
end
function mtf_fi_on_cost(box, data)
  local name = ui.get_item_name_by_code(data.value)
  return box:make_char_cost(name) + 2
end
function mtf_fi_on_init(box, data, mtf)
  local dv = data.value
  local excel = ui.item_get_excel(dv.v_int)
  if excel == nil then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local item_name = ui.get_item_name_by_code(data.value)
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.color = mtf_get_item_color(excel.id, dv)
  p.text = sys.format(cs_fmt_i, item_name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_si_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_si_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_check then
    return false
  end
  local dv = data.value
  local excel = ui.item_get_excel(dv.v_int)
  if excel == nil then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.color = mtf_get_item_color(excel.id, dv)
  p.text = sys.format(cs_fmt_i, excel.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_si_on_cost(box, data)
  local excel = ui.item_get_excel(data.value.v_int)
  return box:make_char_cost(excel.name) + 2
end
function mtf_drop_type_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
local drop_type_name = ui.get_text("item|drop_type_title")
local drop_type_color = ui.make_color("FFFFFF")
local function drop_type_info(data)
  local excel = bo2.gv_drop_type_info:find(data.value.v_int)
  if excel then
    return excel.name, ui.make_color(excel.color)
  end
  return drop_type_name, drop_type_color
end
function mtf_drop_type_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local name, color = drop_type_info(data)
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.color = color
  p.text = name
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_drop_type_on_cost(box, data)
  return box:make_char_cost(drop_type_info(data)) + 2
end
function mtf_drop_type_on_text(box, data)
  return sys.format("[%s]", drop_type_info(data))
end
function mtf_guild_person_contri_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_guild_person_contri_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.color = mtf.color
  p.text = data.value
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_guild_flexible_contri_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_guild_flexible_contri_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.color = mtf.color
  p.text = data.value
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_errantry_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_errantry_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.color = mtf.color
  p.text = data.value
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_camp_repute_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_camp_repute_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.color = mtf.color
  p.text = data.value
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_doopoint_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_doopoint_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.color = mtf.color
  p.text = data.value
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_cii_on_reset(box, data, rank)
  local w = data.widget
  local card = w:search(cs_mtf_card)
  local text = w:search(cs_mtf_rb_text)
  text.dock = "fill_xy"
  w:tune_x(cs_mtf_rb_text)
  w:tune_y(cs_mtf_rb_text)
  local dy = card.parent.dy
  if dy > w.dy then
    w.dy = dy
    text.dy = text.extent.y
    text.dock = "pin_x1"
  end
  return true
end
function mtf_cii_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local card = w:search(cs_mtf_card)
  local text = w:search(cs_mtf_rb_text)
  local s_id, s_txt = data.value:split2(",")
  card.excel_id = s_id.v_int
  text.mtf = s_txt
  return mtf_cii_on_reset(box, data, mtf.rank)
end
function mtf_scii_on_reset(box, data, rank)
  local w = data.widget
end
function mtf_guide_i_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local id = data.value.v_int
  local card = w:search(cs_mtf_card)
  card.excel_id = id
  local excel = ui.item_get_excel(id)
  if excel == nil then
    return false
  end
  local color = L("FFFFFF")
  local lootlevel = excel.plootlevel
  if lootlevel ~= nil then
    color = lootlevel.color
  end
  local rb = w:search(cs_mtf_rb_text)
  rb.mtf = sys.format(L("<c+:%s>%s<c->"), color, excel.name)
  return mtf_cii_on_reset(box, data, mtf.rank)
end
function mtf_scii_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local id = data.value.v_int
  local card = w:search(cs_mtf_card)
  card.excel_id = id
  local excel = ui.item_get_excel(id)
  if excel == nil then
    return false
  end
  local p = w:search(cs_mtf_text)
  p.text = excel.name
  p.color = mtf.color
  p.font = mtf.format.font
  local lootlevel = excel.plootlevel
  if lootlevel ~= nil then
    p.color = ui.make_color(lootlevel.color)
  end
  w:tune(cs_mtf_text)
  return true
end
function mtf_star_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local cnt = data.value.v_int
  if cnt <= 0 then
    return false
  end
  local dx = 0
  local dy = 0
  local w = data.widget
  for i = 0, cnt - 1 do
    local img = ui.create_control(w, "picture")
    img:load_style(cs_mtf_style_uri, data.name)
    if dy < img.dy then
      dy = img.dy
    end
    dx = dx + img.dx
  end
  w.size = ui.point(dx, dy)
  return true
end
function mtf_evaluate_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local cnt = data.value.v_int
  if cnt <= 0 then
    return false
  end
  local dx = 0
  local dy = 0
  local w = data.widget
  for i = 0, cnt - 1 do
    local img = ui.create_control(w, "picture")
    img:load_style(cs_mtf_style_uri, data.name)
    if dy < img.dy then
      dy = img.dy
    end
    dx = dx + img.dx
  end
  w.size = ui.point(dx, dy)
  return true
end
function mtf_sel_on_reset(box, data, rank)
  local w = data.widget
  local icon = w:search(cs_mtf_icon)
  local text = w:search(cs_mtf_text)
  icon.dock = cs_ext_x1
  text.dock = cs_fill_xy
  w.dx = box.container.dx
  w:tune(cs_mtf_text)
  w.dx = w.dx + 70
  if w.dx > box.container.dx then
    w.dx = box.container.dx
  end
  local idy = icon.dy
  if w.dy <= idy + 4 then
    w.dy = idy + 4
    text.dock = cs_pin_x1
  else
    icon.dock = cs_ext_x1y1
    local fdy = text.font.extent.y
    local my1 = 0
    if idy < fdy then
      my1 = (fdy - idy) * 0.5
    end
    icon.margin = ui.rect(0, my1, 0, 0)
  end
  return true
end
function mtf_sel_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local text = w:search(cs_mtf_text)
  local s_kind, s_id, s_icon, s_handson, s_script, s_text = data.value:splitn(",", 6)
  text.mtf = s_text
  local icon = w:search("icon")
  if sys.check(s_handson) and s_handson.empty ~= true then
    local pos = w:search(L("handson_pos"))
    if sys.check(pos) then
      pos.name = s_handson
    end
  end
  if s_icon then
    local icon_id = s_icon.v_int
    local e = bo2.gv_npc_func_icons:find(icon_id)
    if e then
      icon.image = e.text
    end
  end
  return mtf_sel_on_reset(box, data, mtf.rank)
end
function mtf_sel_on_mouse(box, data, msg)
  if msg == ui.mouse_lbutton_click then
    local txt = box.var:get("on_mtf_sel").v_string
    if txt.size > 0 then
      sys.pcall(sys.get(txt), box, data.value)
    end
    return
  end
  local color
  if msg == ui.mouse_enter then
    color = "d3a75e"
  elseif msg == ui.mouse_leave then
    color = "FFFFFF"
  else
    return
  end
  local w = data.widget
  local text = w:search(cs_mtf_text)
  text.color = ui.make_color(color)
  text:set_text_color(ui.make_color(color))
  return true
end
function mtf_sep_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  return w:load_style(cs_mtf_style_uri, data.name)
end
function mtf_key_on_reset(box, data, rank)
  local w = data.widget
  local font = w.svar.font
  local lb = w:search(data.name)
  local value, color = data.value:split2(",")
  local dy = font.extent.y
  if value.size > 1 then
    font = ui.font(font.name, font.size - 2, font.edge)
  end
  lb.font = font
  dy = dy + 2
  local dx = lb.extent.x + 10
  if dx < dy + 4 then
    dx = dy + 4
  end
  w.size = ui.point(dx, dy)
end
function mtf_key_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local font = mtf.format.font
  w.svar.font = font
  local lb = w:search(data.name)
  local value, color = data.value:split2(",")
  lb.text = value
  if sys.check(color) then
    lb.color = ui.make_color(color)
  end
  local v, c, text_c = data.value:split(",")
  if text_c ~= nil and text_c.v_int ~= 0 then
    lb.color = mtf.color
  end
  mtf_key_on_reset(box, data)
  return true
end
function mtf_space_on_reset(box, data, rank)
  local w = data.widget
  local font = w.svar.font
  w.dx = font.extent.x * data.value.v_number
end
function mtf_space_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local font = mtf.format.font
  w.svar.font = font
  mtf_space_on_reset(box, data)
  return true
end
function mtf_popo_on_reset(box, data, rank)
  local w = data.widget
  if data.value.size <= 100 then
    w.dx = 200
  else
    w.dx = 300
  end
  rb = w:search(cs_mtf_rb_text)
  rb.dock = cs_fill_xy
  w.dy = 800
  w:tune(cs_mtf_rb_text)
  if w.dx < 48 then
    w.dx = 48
    rb.dock = cs_pin_xy
  end
  return true
end
function mtf_popo_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local text = w:search(cs_mtf_rb_text)
  local s_rank, s_txt = data.value:split2(cs_comma)
  text:insert_mtf(s_txt, s_rank.v_int)
  return mtf_popo_on_reset(box, data, mtf.rank)
end
function mtf_lb_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_lb_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  local f = mtf.format.font
  local arg, txt = data.value:split2("|")
  local face, size, edge, color, left = arg:split(",", 5)
  if face == nil or face.empty then
    face = f.name
  end
  if size == nil or size.empty then
    size = f.size
  end
  if edge == nil or edge.empty then
    edge = f.edge
  end
  if color == nil or color.empty then
    color = mtf.color
  end
  p.font = ui.font(face, size, edge)
  p.text = txt
  p.color = ui.make_color(color)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return mtf_lb_on_reset(box, data)
end
function mtf_url_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_url_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  local f = mtf.format.font
  local arg, url, txt = data.value:split("|", 3)
  local face, size, edge, color, left = arg:split(",", 5)
  if face == nil or face.empty then
    face = f.name
  end
  if size == nil or size.empty then
    size = f.size
  end
  if edge == nil or edge.empty then
    edge = f.edge
  end
  if color == nil or color.empty then
    color = mtf.color
  end
  p.font = ui.font(face, size, edge)
  p.text = txt
  p.color = ui.make_color(color)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return mtf_lb_on_reset(box, data)
end
function mtf_rb_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  w.dx = 800
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_mid_lb_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  local f = mtf.format.font
  local arg, txt = data.value:split2("|")
  local face, size, edge, color, height = arg:split(",", 5)
  if face == nil or face.empty then
    face = f.name
  end
  if size == nil or size.empty then
    size = f.size
  end
  if edge == nil or edge.empty then
    edge = f.edge
  end
  if color == nil or color.empty then
    color = mtf.color
  end
  p.font = ui.font(face, size, edge)
  p.text = txt
  p.color = ui.make_color(color)
  data.edge_size = p.font.edge_size
  if height.empty then
    w:tune(data.name)
  else
    w.dx = p.dx
    w.dy = height.v_int
  end
  return true
end
function mtf_rb_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  w.dx = 800
  p.mtf = data.value
  w:tune(data.name)
  return true
end
local cs_lv0 = SHARED("lv0")
local cs_lv1 = SHARED("lv1")
local cs_hp = SHARED("hp")
local cs_bar = SHARED("bar")
local cs_flk_hi = SHARED("flk_hi")
local cs_pic_hi = SHARED("pic_hi")
local cs_mtf_hp_on_close = SHARED("ui_widget.mtf_hp_on_close")
local cs_hp_color_0 = ui.make_color("FF0000")
local cs_hp_level_color_0 = ui.make_color("FF0000")
local cs_hp_level_color_1 = ui.make_color("FFFFFF")
local cs_hp_level_color_2 = ui.make_color("888888")
local cs_hp_name_color_0 = ui.make_color("00FF00")
local cs_hp_name_color_1 = ui.make_color("FF9000")
local cs_hp_name_color_2 = ui.make_color("FF0000")
local cs_hp_hi_color_0 = ui.make_argb("88FFFFFF")
local cs_hp_hi_color_1 = ui.make_color("FF0000")
local cs_hp_hi_color_2 = ui.make_color("FFFFFF")
local c_hp_update_tick = sys.tick()
local hp_digit = {
  SHARED("$image/mtf/hp.png|109,62,8,12"),
  SHARED("$image/mtf/hp.png|1,62,7,12"),
  SHARED("$image/mtf/hp.png|11,62,8,12"),
  SHARED("$image/mtf/hp.png|24,62,8,12"),
  SHARED("$image/mtf/hp.png|36,62,8,12"),
  SHARED("$image/mtf/hp.png|48,62,8,12"),
  SHARED("$image/mtf/hp.png|60,62,8,12"),
  SHARED("$image/mtf/hp.png|72,62,8,12"),
  SHARED("$image/mtf/hp.png|84,62,8,12"),
  SHARED("$image/mtf/hp.png|96,62,8,12")
}
local hp_widget = {}
local mtf_hp_state = function(player)
  local state = {}
  state.target = bo2.scn:get_scn_obj(player.target_handle)
  local hover = ui.get_hover()
  if hover ~= nil then
    state.hover_parent = hover.parent
  end
  state.level = ui_widget.level_safe_scn(player)
  return state
end
function mtf_hp_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local crt = bo2.findobj(data.value)
  if crt == nil then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  w.svar.owner_obj = crt
  local hp = w:search(cs_hp)
  hp.color = cs_hp_color_0
  local hp_per = 0
  local hp_max = crt:get_atb(bo2.eAtb_HPMax)
  if hp_max >= 1 then
    hp_per = crt:get_atb(bo2.eAtb_HP) / hp_max
  end
  hp.dx = hp.parent.dx * hp_per
  local lv0 = w:search(cs_lv0)
  local lv1 = w:search(cs_lv1)
  local lv = ui_widget.level_safe_scn(crt)
  local v0 = math.floor(math.mod(lv, 10))
  local v1 = math.floor(lv / 10)
  lv0.image = hp_digit[v0 + 1]
  if v1 > 0 then
    lv1.image = hp_digit[v1 + 1]
  else
    lv1.visible = false
  end
  lv0.parent:update()
  local flk_hi = w:search(cs_flk_hi)
  local pic_hi = flk_hi:search(cs_pic_hi)
  local function mtf_hp_on_close(w)
    hp_widget[w] = nil
  end
  local function mtf_hp_sub_on_close(p)
    bo2.leave_target(p, crt.sel_handle)
  end
  hp.parent:insert_on_close(mtf_hp_sub_on_close, cs_mtf_hp_on_close)
  lv0.parent:insert_on_close(mtf_hp_sub_on_close, cs_mtf_hp_on_close)
  w:insert_on_close(mtf_hp_on_close, cs_mtf_hp_on_close)
  hp_widget[w] = 1
  local function mtf_hp_update(state, init)
    local fader = hp.parent.parent
    local is_hi = false
    if state.hover_parent == fader or bo2.get_mouse_target() == crt.sel_handle then
      is_hi = true
    end
    local target = state.target
    local is_alpha = false
    if target ~= crt and not is_hi then
      fader.alpha = 0.3
      is_alpha = true
    else
      fader.alpha = 1
    end
    local color = cs_hp_name_color_0
    local ct = bo2.get_name_color_type(crt)
    if ct == 1 then
      color = cs_hp_name_color_1
    elseif ct == 2 then
      color = cs_hp_name_color_2
    end
    hp.color = color
    if target == crt then
      color = cs_hp_hi_color_1
    elseif is_hi or crt.is_fight then
      color = cs_hp_hi_color_2
    else
      color = cs_hp_hi_color_0
    end
    pic_hi.color = color
    if is_hi then
      flk_hi.suspended = false
      flk_hi.tick = c_hp_update_tick
      flk_hi.show_tick = 300
      flk_hi.show_hold = 200
      flk_hi.show_alpha = 1
      flk_hi.hide_tick = 300
      flk_hi.hide_hold = 200
      flk_hi.hide_alpha = 0
    elseif crt.is_fight then
      flk_hi.suspended = false
      flk_hi.tick = c_hp_update_tick
      flk_hi.show_alpha = 1
      if is_alpha then
        flk_hi.hide_alpha = 0.5
      else
        flk_hi.hide_alpha = 0
      end
      flk_hi.show_tick = 300
      flk_hi.show_hold = 200
      flk_hi.hide_tick = 300
      flk_hi.hide_hold = 200
    else
      flk_hi.suspended = true
    end
    color = cs_hp_level_color_1
    local level_d = state.level - lv
    if level_d < -10 then
      color = cs_hp_level_color_0
    elseif level_d > 10 then
      color = cs_hp_level_color_2
    end
    lv0.color = color
    lv1.color = color
  end
  w.svar.hp_update = mtf_hp_update
  local player = bo2.player
  if player ~= nil then
    local state = mtf_hp_state(player)
    mtf_hp_update(state, true)
  end
  return true
end
function mtf_hp_on_mouse(p, msg)
  if msg == ui.mouse_lbutton_click then
    local crt = p.parent.parent.svar.owner_obj
    bo2.click_target(crt.sel_handle)
  elseif msg == ui.mouse_rbutton_click then
    local crt = p.parent.parent.svar.owner_obj
    bo2.send_target_packet(crt.sel_handle)
  elseif msg == ui.mouse_enter then
    local crt = p.parent.parent.svar.owner_obj
    bo2.enter_target(p, crt.sel_handle)
  elseif msg == ui.mouse_leave then
    local crt = p.parent.parent.svar.owner_obj
    bo2.leave_target(p, crt.sel_handle)
  end
end
function mtf_hp_on_set_target(obj, msg)
  local player = bo2.player
  if obj ~= player then
    return
  end
  local state = mtf_hp_state(player)
  for w, i in pairs(hp_widget) do
    w.svar.hp_update(state)
  end
end
if rawget(_G, "bo2") ~= nil then
  bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_set_target, mtf_hp_on_set_target, "ui_widget.mtf_hp_on_set_target")
end
function mtf_skill_on_init(box, data, mtf)
  local excel_id, level, type = data.value:split(",", 3)
  local excel
  if type.v_int == 1 then
    excel = bo2.gv_skill_group:find(excel_id.v_int)
  elseif type.v_int == 0 then
    excel = bo2.gv_passive_skill:find(excel_id.v_int)
  end
  if excel == nil then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.text = sys.format(cs_fmt_i, excel.name .. "lv" .. level)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_skill_on_init_id(box, data, mtf)
  local excel_id = data.value
  local excel = bo2.gv_skill_group:find(excel_id.v_int)
  if excel == nil then
    excel = bo2.gv_passive_skill:find(excel_id.v_int)
  end
  if excel == nil then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.text = sys.format(cs_fmt_i, excel.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_skill_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_xinfa_on_init(box, data, mtf)
  local excel_id, level = data.value:split2(",")
  local excel = bo2.gv_xinfa_list:find(excel_id.v_int)
  if excel == nil then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.text = sys.format(cs_fmt_i, excel.name .. "lv" .. level)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_xinfa_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_ch_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local excel = bo2.gv_chat_list:find(data.value.v_number)
  if excel == nil then
    return
  end
  local name = excel.name
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.color = mtf.color
  p.font = mtf.format.font
  p.text = sys.format(cs_fmt_ch, name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_ch_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_btn_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local fn, text, arg = data.value:split(",", 3)
  local btn = w:search(data.name)
  btn:insert_on_click(fn, "mtf.btn.on_click")
  btn.svar.arg = arg
  local p = btn:search("btn_color")
  p.color = mtf.color
  p.font = mtf.format.font
  p.text = text
  data.edge_size = p.font.edge_size
  w.size = p.extent
  return true
end
function mtf_btn_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search("btn_color")
  data.edge_size = p.font.edge_size
  w.size = p.extent
  return true
end
function mtf_ext_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local init, reset, arg = data.value:split(",", 3)
  local fn = sys.get(init)
  if fn == nil then
    return false
  end
  return fn(box, data, mtf)
end
function mtf_ext_on_reset(box, data, rank)
  local init, reset, arg = data.value:split(",", 3)
  local fn = sys.get(reset)
  if fn == nil then
    return false
  end
  return fn(box, data, mtf)
end
function mtf_imn_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local name, time = data.value:split2(",")
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.color = mtf.color
  p.font = mtf.format.font
  p.text = sys.format(SHARED("%s  %s"), name, time)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_imn_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_arena_on_init(box, data, mtf)
  local arena_id, name = data.value:split2(",")
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.color = mtf.color
  p.font = mtf.format.font
  p.text = sys.format(cs_fmt_i, name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_arena_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_matchscn_on_init(box, data, mtf)
  local arena_id, name = data.value:split2(",")
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.color = mtf.color
  p.font = mtf.format.font
  p.text = sys.format(cs_fmt_i, name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_matchscn_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_knightscn_on_init(box, data, mtf)
  local handle = data.value.v_int
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  w.svar.handle = handle
  box.cursor = "_24"
  local p = w:search(data.name)
  p.text = sys.format(cs_fmt_i, ui.get_text("knight|ask_help"))
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_knightscn_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_knightscn_on_mouse(box, data, msg)
  local w = data.widget
  if msg == ui.mouse_lbutton_click then
    bo2.click_target(w.svar.handle)
  elseif msg == ui.mouse_enter then
    bo2.enter_target(box, w.svar.handle)
  elseif msg == ui.mouse_leave then
    bo2.leave_target(box, w.svar.handle)
  end
end
function mtf_skill_small_icon_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local excel_id = data.value:split(",", 2)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local card = w:search("skill_card")
  card.excel_id = excel_id.v_int
  return true
end
function mtf_skill_icon_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local excel_id, weapon, color, effect = data.value:split(",", 4)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local card = w:search("skill_card")
  card.excel_id = excel_id.v_int
  local w_weapon = w:search("weapon")
  local w_effect = w:search("effect")
  w_weapon.text = weapon
  w_weapon.color = ui.make_color(color)
  w_effect.text = effect
  local dx = w_weapon.extent.x
  local dx2 = w_effect.extent.x
  if dx < dx2 then
    dx = dx2
  end
  if dx < 100 then
    dx = 100
  end
  dx = dx + 8
  w_weapon.parent.dx = dx
  local wx = w.dx
  if dx > wx - 64 then
    w.dx = dx + 64
  end
  return true
end
function mtf_xinfa_icon_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local excel_id, title = data.value:split(",", 2)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local card = w:search("xinfa_card")
  card.excel_id = excel_id.v_int
  w:search("title").text = title
  return true
end
function mtf_guide_on_reset(box, data, rank)
  local w = data.widget
  local card = w:search(cs_mtf_card)
  local text = w:search(data.name)
  if card.visible == true then
    w:tune(data.name)
    if card.dy > w.dy then
      w.dy = card.dy
    end
    w.dx = text.dx + card.dx
  else
    text.dock = "fill_xy"
    w:tune(data.name)
  end
  return true
end
function on_guide_item_label_tip(tip)
  local label = tip.owner
  if sys.check(label) ~= true then
    return
  end
  local card = label.parent:search("card")
  if sys.check(card) then
    local excel = card.excel
    if sys.check(excel) ~= true then
      return
    end
    local stk = sys.mtf_stack()
    ui_tool.ctip_make_item(stk, excel, card.info, card)
    local stk_use = ui_item.tip_get_using_equip(excel)
    ui_tool.ctip_show(label, stk, stk_use)
  end
end
function on_guide_item_card_tip(tip)
  local card = tip.owner
  local excel = card.excel
  if sys.check(excel) ~= true then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_item(stk, excel, card.info, card)
  local stk_use = ui_item.tip_get_using_equip(excel)
  ui_tool.ctip_show(card, stk, stk_use)
end
function mtf_guide_item_on_reset(box, data, rank)
  local w = data.widget
  w.dx = 32
  w.dy = 32
  return true
end
function mtf_guide_item_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local card = w:search(cs_mtf_card)
  local s_id, s_count = data.value:split2(",")
  card.excel_id = s_id.v_int
  card.visible = true
  if sys.check(s_count.v_int) and s_count.v_int >= 1 then
    local num_text = w:search(cs_mtf_rb_text)
    num_text.text = sys.format(L("x%d"), s_count.v_int)
  end
  return mtf_guide_item_on_reset(box, data, mtf.rank)
end
function mtf_guide_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local theme, id, text, font_format, color, font_size, edge = data.value:split(",", 6)
  if id == nil or theme == nil then
    return false
  end
  local mtf_string = sys.format("%s", data.value)
  w.var:set(1, mtf_string)
  if font_format == nil or font_format.empty then
    font_format = w.name
  end
  if font_size == nil or font_size.empty then
    font_size = w.size
  end
  local set_color = false
  if color == nil or color.empty then
    color = mtf.color
  else
    set_color = true
    color = ui.make_color(color)
  end
  local p = w:search(data.name)
  p.font = ui.font(font_format, font_size, edge)
  if sys.check(ui_bo2_guide) then
    p.text, _color = ui_bo2_guide.on_get_mtf_text(theme.v_int, id.v_int, text)
    if set_color == false and _color ~= nil then
      color = ui.make_color(_color)
    end
  else
    p.text = text
  end
  p.color = color
  if theme.v_int == 2 then
    local card = w:search(cs_mtf_card)
    card.excel_id = id.v_int
    p.mouse_able = true
  else
    data.edge_size = p.font.edge_size
    w:tune(data.name)
  end
  return mtf_guide_on_reset(box, data, mtf.rank)
end
function guide_label_on_mouse(ctrl, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click and sys.check(ctrl.parent) then
    guide_on_mouse(ctrl.parent, msg, pos, wheel)
  end
end
function guide_on_mouse(ctrl, msg, pos, wheel)
  if sys.check(ctrl) ~= true then
    return
  end
  if msg == ui.mouse_lbutton_click then
    do
      local var = ctrl.var:get(1)
      local mtf_data = var.v_string
      local theme, id, text = mtf_data:split(",", 3)
      local function on_view()
        ui_bo2_guide.on_view_mtf(theme, id, text)
      end
      bo2.AddTimeEvent(1, on_view)
      return
    end
  end
end
function mtf_guide_data_on_mouse(box, data, msg)
  if msg == ui.mouse_lbutton_click then
    local theme, id, text = data.value:split(",", 3)
    ui_bo2_guide.on_view_mtf(theme, id, text)
    return
  end
end
function mtf_sp_panel_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local rb_left = w:search(L("rb_left"))
  local rb_right = w:search(L("rb_right"))
  if sys.check(rb_left) ~= true or sys.check(rb_right) ~= true then
    return false
  end
  local theme, excel_id, _dx = data.value:split(",", 3)
  local rst, left_text, right_text = ui_bo2_guide.get_sp_panel_data(theme.v_int, excel_id.v_int)
  if rst ~= true then
    return false
  end
  local dx = _dx.v_int
  w.dx = dx
  rb_left.parent.dx = dx / 2
  rb_left.dx = dx / 2
  rb_right.parent.dx = dx / 2
  rb_right.dx = dx / 2
  rb_left.mtf = left_text
  rb_left.parent:tune_y("rb_left")
  rb_right.mtf = right_text
  rb_right.parent:tune_y("rb_right")
  if rb_right.parent.dy > rb_left.parent.dy then
    w.dy = rb_right.parent.dy
  else
    w.dy = rb_left.parent.dy
  end
  return true
end
function mtf_handson_on_reset(box, data, rank)
  local w = data.widget
  if data.value.size < 100 then
    w.dx = 300
  elseif data.value.size > 200 then
    w.dx = 300
  end
  w.dy = 200
  w:tune(cs_mtf_rb_text)
  w.margin = ui.rect(w.dx / 2, 0, 0, 0)
  return true
end
function mtf_handson_on_init(box, data, msg)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(cs_mtf_rb_text)
  local s_txt, iGap, txt, txt_id = data.value:split(",", 4)
  if iGap ~= nil then
    local iGapType = iGap.v_int
    if iGapType == 1 then
      local gap_mid = w:search(L("gap_m"))
      gap_mid.visible = false
      local gap_qlink = w:search(L("gap_l"))
      gap_qlink.visible = true
      p.margin = handson_margin[1]
    elseif iGapType == 2 then
      local gap_mid = w:search(L("gap_m"))
      gap_mid.visible = false
      local gap_qlink = w:search(L("gap_r"))
      gap_qlink.visible = true
      p.margin = handson_margin[2]
    elseif iGapType == 3 then
      local gap_mid = w:search(L("gap_m"))
      gap_mid.visible = false
      local gap_qlink = w:search(L("gap_b"))
      gap_qlink.visible = true
      p.margin = handson_margin[3]
    elseif iGapType == 4 then
      local gap_mid = w:search(L("gap_m"))
      gap_mid.visible = false
      local gap_qlink = w:search(L("gap_m_tmp"))
      gap_qlink.visible = true
      p.margin = handson_margin[4]
    elseif iGapType == 5 then
      local gap_mid = w:search(L("gap_m"))
      gap_mid.visible = false
      local gap_qlink = w:search(L("gap_b_tmp"))
      gap_qlink.visible = true
      p.margin = handson_margin[5]
    elseif iGapType == 6 then
      local gap_mid = w:search(L("gap_m"))
      gap_mid.visible = false
      local gap_qlink = w:search(L("gap_l_tmp"))
      gap_qlink.visible = true
      p.margin = handson_margin[6]
    elseif iGapType == 7 then
      local gap_mid = w:search(L("gap_m"))
      gap_mid.visible = false
      local gap_qlink = w:search(L("gap_r_tmp"))
      gap_qlink.visible = true
      p.margin = handson_margin[7]
    else
      p.margin = handson_margin[0]
    end
  end
  local idx = s_txt.v_int
  local pExcel = bo2.gv_handson_teach:find(idx)
  if pExcel ~= nil then
    p.mtf = pExcel.teach_brief
  end
  if txt then
    p.mtf = txt
  end
  if txt_id and txt_id.v_int > 0 then
    local new_text = ui_handson_teach.get_talk_text(txt_id.v_int)
    if sys.check(new_text) then
      p.mtf = new_text
    end
  end
  return mtf_handson_on_reset(box, data)
end
function mtf_fitting_on_init(box, data, msg)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local btn = w:search(cs_mtf_btn_fitting)
  local iType, iIdx = data.value:split(",")
  btn.var:set(1, iType)
  btn.var:set(2, iIdx)
  return true
end
function mtf_quest_on_init(box, data, mtf)
  local excel = bo2.gv_quest_list:find(data.value.v_int)
  if excel == nil then
    return false
  end
  ui.log(excel.name)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.color = ui.make_color(L("00FF00"))
  p.text = sys.format(cs_fmt_quest, excel.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_milestone_on_init(box, data, mtf)
  local excel = bo2.gv_milestone_list:find(data.value.v_int)
  if excel == nil then
    return false
  end
  ui.log(excel.name)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.color = ui.make_color(L("00FF00"))
  p.text = sys.format(cs_fmt_quest, excel.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_quest_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_milestone_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_imt_on_reset(box, data, rank)
  local w = data.widget
  local img = w:search(cs_mtf_img)
  local text = w:search(cs_mtf_rb_text)
  text.dock = "fill_xy"
  w:tune_x(cs_mtf_rb_text)
  w:tune_y(cs_mtf_rb_text)
  local dy = img.dy
  if dy > w.dy then
    w.dy = dy
    text.dy = text.extent.y
    text.dock = "pin_x1"
  end
  return true
end
function mtf_imt_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local img = w:search(cs_mtf_img)
  local text = w:search(cs_mtf_rb_text)
  local s_url, s_data = data.value:split2("*")
  local xy, s_txt = s_data:split2("*")
  img.image = s_url
  if xy.empty then
    img:tune(data.name)
  else
    local dx, dy = xy:split2(",")
    img.dx = dx.v_int
    img.dy = dy.v_int
  end
  text.mtf = s_txt
  return mtf_imt_on_reset(box, data, mtf.rank)
end
function mtf_ridepet_skill_icon_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local img = w:search("img")
  local level = w:search("level")
  local lock = w:search("lock")
  local url, text_level, text_lock = data.value:split("*", 3)
  img.image = url
  level.mtf = text_level
  lock.mtf = text_lock
  return true
end
function mtf_spmk_on_init(box, data, mtf)
  local sid, stype = data.value:split(",", 2)
  local itemData = ui_supermarket2.itembox_FindItem(sid.v_int, stype and stype.v_int)
  if itemData then
    if not data.widget:load_style("$frame/supermarket_v2/itembox.xml", "itembox") then
      return
    end
    ui_supermarket2.itembox_Show(data.widget, itemData)
    ui_supermarket2.shelf_DirectShowWhenClick(data.widget)
    return true
  end
end
function mtf_spmk_lb_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style("$frame/supermarket_v2/textlink.xml", "textlink") then
    return false
  end
  local title = data.value:split(",")
  ui_supermarket2.textlink_show(w, title)
  return true
end
function mtf_spmk_lb_on_click(box, data, msg)
  if msg == ui.mouse_lbutton_click then
    local title, typee = data.value:split(",", 2)
    ui_supermarket2.textlink_Click(typee)
  end
end
function mtf_trait_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local excel_id = data.value.v_int
  local trait = bo2.gv_trait_list:find(excel_id)
  if trait == nil then
    return nil
  end
  local desc = trait.desc
  if desc.size == 0 then
    local modify = bo2.gv_modify_player:find(trait.modify_id)
    if modify == nil then
      return
    end
    desc = sys.format("%s%+d", modify.name, trait.modify_value)
  end
  local p = w:search(data.name)
  p.font = mtf.format.font
  p.text = ui_widget.merge_mtf({text = desc}, ui.get_text("widget|trait_des"))
  p.color = ui.make_color("00ff00")
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_trait_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_position_on_reset(box, data, rank)
  local w = data.widget
  local p = w:search(data.name)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
local position_color = ui.make_color("279DE9")
function mtf_position_on_init(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local p = w:search(data.name)
  p.color = mtf.color
  if mtf.color == -1 then
    p.color = position_color
  end
  p.font = mtf.format.font
  local scn_id, pos_x, pos_z = data.value:split(",", 3)
  p.text = sys.format("(%d,%d)", pos_x.v_int, pos_z.v_int)
  data.edge_size = p.font.edge_size
  w:tune(data.name)
  return true
end
function mtf_useskill_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local card = w:search(data.name)
  if card == nil then
    return false
  end
  local skill_id = data.value
  card.excel_id = skill_id.v_int
  box.var:set(packet.key.skill_id, skill_id.v_int)
  return true
end
function mtf_useitem_on_init(box, data, mtf)
  if mtf.rank < ui.mtf_rank_system then
    return false
  end
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local card = w:search(data.name)
  if card == nil then
    return false
  end
  local item_id = data.value
  card.excel_id = item_id.v_int
  return true
end
function mtf_table_idx_info(box, data, mtf)
  local w = data.widget
  if not w:load_style(cs_mtf_style_uri, data.name) then
    return false
  end
  local table_name, idx, name = data.value:split(",", 3)
  table_name = "gv_" .. tostring(table_name)
  local t = bo2[table_name]
  if t == nil then
    return false
  end
  local n = t:find(idx.v_int)
  if n == nil then
    return false
  end
  local txt = n[tostring(name)]
  if txt == nil then
    return false
  end
  local text = w:search(cs_mtf_text)
  text.dock = cs_fill_xy
  text.color = mtf.color
  text.font = mtf.format.font
  text.text = txt
  w.dx = box.container.dx
  w:tune(cs_mtf_text)
  return true
end
mtf_init()
