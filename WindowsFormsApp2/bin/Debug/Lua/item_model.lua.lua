local cValueMax = 255
local camera_radius = 2.4
local camera_radius_near = 0.8
local init = function()
  if sys.check(rawget(_M, "w_core")) then
    return
  end
  w_top:load_style("$frame/item/item_model.xml", "main")
  local svar = w_top.svar
end
function on_visible(ctrl, vis)
  if not vis then
    return
  end
  init()
end
function on_frame_init(frm)
  local frames = rawget(_M, "g_frames")
  if frames == nil then
    frames = {}
    g_frames = frames
  end
  frames[tostring(frm.name)] = frm
end
function frame_expand(frm, exp)
  if not sys.check(frm) then
    return
  end
  local btn_plus = frm:search("btn_plus")
  local btn_minus = frm:search("btn_minus")
  local content = frm:search("content")
  if exp then
    btn_plus.visible = false
    btn_minus.visible = true
    content.visible = true
    frm.dy = content.dy + 40
  else
    btn_plus.visible = true
    btn_minus.visible = false
    content.visible = false
    frm.dy = 32
  end
  if exp then
    local scn = w_scn_view.scn
    local player = w_top.svar.player
    if frm == g_frames.face then
      scn:modify_camera_view_type(player, bo2.eCameraFace)
      scn:set_radius(camera_radius_near)
    else
      scn:modify_camera_view_type(player, bo2.eCameraInit)
      scn:set_radius(camera_radius)
    end
  end
end
local frame_is_expanded = function(frm)
  return frm:search("content").visible
end
function frame_expand_ext(frm, exp)
  if exp then
    if frm == g_frames.body or frm == g_frames.face then
      if w_top.svar.config.init_excel.disable_pinch == 1 then
        ui_tool.note_insert(ui.get_text("choice|no_pinch"), "FF0000")
        return
      end
      for n, w in pairs(g_frames) do
        if w == frm then
          frame_expand(w, true)
        else
          frame_expand(w, false)
        end
      end
    else
      local detail_visible = frame_is_expanded(g_frames.body) or frame_is_expanded(g_frames.face)
      if detail_visible then
        for n, w in pairs(g_frames) do
          if w == g_frames.body or w == g_frames.face then
            frame_expand(w, false)
          else
            frame_expand(w, true)
          end
        end
      else
        frame_expand(frm, true)
      end
    end
    return
  end
  if frm == g_frames.body or frm == g_frames.face then
    for n, w in pairs(g_frames) do
      if w == g_frames.body or w == g_frames.face then
        frame_expand(w, false)
      else
        frame_expand(w, true)
      end
    end
  end
  frame_expand(frm, false)
end
function on_frame_plus_click(btn)
  local frm = btn:upsearch_name("frame_title").parent
  frame_expand_ext(frm, true)
end
function on_frame_minus_click(btn)
  local frm = btn:upsearch_name("frame_title").parent
  frame_expand_ext(frm, false)
end
function select_first(w_content)
  local btn = w_content.control_head
  btn:click()
  btn.press = true
end
function on_dress_select_click(btn)
  local svar = w_top.svar
  local btn_var = btn.svar
  local dress_id = btn_var.dress_id
  svar.config.dress_id = dress_id
  local player = svar.player
  if not sys.check(player) then
    return
  end
  player:set_equip_model(bo2.eEquipData_Body, dress_id)
  player:set_equip_model(bo2.eEquipData_Legs, dress_id)
end
function on_hair_select_click(btn)
  local svar = w_top.svar
  local btn_var = btn.svar
  local hair_id = btn_var.hair_id
  svar.config.hair_id = hair_id
  local player = svar.player
  if not sys.check(player) then
    return
  end
  player:set_equip_model(bo2.eEquipData_Hair, hair_id)
  player:set_equip_model(bo2.eEquipData_Hat, 0)
end
function on_face_select_click(btn)
  local svar = w_top.svar
  local btn_var = btn.svar
  local face_id = btn_var.face_id
  svar.config.face_id = face_id
  local player = svar.player
  if not sys.check(player) then
    return
  end
  player:set_equip_model(bo2.eEquipData_Face, face_id)
  detail_reset(g_frames.face, player)
end
slider_type = {
  [L("waist")] = {
    flag = bo2.ePlayerFlagInt8_BoneOffsetWaist,
    init_value = 0,
    curr_value = 0,
    slider_ctrl = nil
  },
  [L("neck")] = {
    flag = bo2.ePlayerFlagInt8_BoneOffsetNeck,
    init_value = 0,
    curr_value = 0,
    slider_ctrl = nil
  },
  [L("up_arm")] = {
    flag = bo2.ePlayerFlagInt8_BoneOffsetUpperArm,
    init_value = 0,
    curr_value = 0,
    slider_ctrl = nil
  },
  [L("front_arm")] = {
    flag = bo2.ePlayerFlagInt8_BoneOffsetForearm,
    init_value = 0,
    curr_value = 0,
    slider_ctrl = nil
  },
  [L("thigh")] = {
    flag = bo2.ePlayerFlagInt8_BoneOffsetUpperLeg,
    init_value = 0,
    curr_value = 0,
    slider_ctrl = nil
  },
  [L("leg")] = {
    flag = bo2.ePlayerFlagInt8_BoneOffsetShank,
    init_value = 0,
    curr_value = 0,
    slider_ctrl = nil
  },
  [L("eye_size")] = {
    flag = bo2.ePlayerFlagInt8_EyeSize,
    slider_ctrl = nil
  },
  [L("eye_dist")] = {
    flag = bo2.ePlayerFlagInt8_EyeWide,
    slider_ctrl = nil
  },
  [L("brow_height")] = {
    flag = bo2.ePlayerFlagInt8_EyeBrow,
    slider_ctrl = nil
  },
  [L("nose_size")] = {
    flag = bo2.ePlayerFlagInt8_NostrilSize,
    slider_ctrl = nil
  },
  [L("nose_height")] = {
    flag = bo2.ePlayerFlagInt8_NoseBridgePos,
    slider_ctrl = nil
  },
  [L("nose_quatation")] = {
    flag = bo2.ePlayerFlagInt8_NoseGuard,
    slider_ctrl = nil
  },
  [L("mouth_width")] = {
    flag = bo2.ePlayerFlagInt8_MouthSize,
    slider_ctrl = nil
  },
  [L("mouth_height")] = {
    flag = bo2.ePlayerFlagInt8_PhiltrumLen,
    slider_ctrl = nil
  },
  [L("mouth_tickness")] = {
    flag = bo2.ePlayerFlagInt8_MouthLipSize,
    slider_ctrl = nil
  }
}
function detail_init(p, player)
  for n, v in pairs(slider_type) do
    local s = p:search(n)
    if s ~= nil then
      local value = player:get_flag_int8(v.flag)
      v.init_value = value
      v.value = value
      s = s:search("slider")
      s.scroll = value / cValueMax
      s.parent:search("value").text = value
    end
  end
end
function detail_reset(p)
  local player = w_top.svar.player
  for n, v in pairs(slider_type) do
    local s = p:search(n)
    if s ~= nil then
      local value = v.init_value
      v.value = value
      s = s:search("slider")
      s.scroll = value / cValueMax
      player:set_flag_int8(v.flag, value)
      s.parent:search("value").text = player:get_flag_int8(v.flag)
    end
  end
end
function on_slider_move(ctrl)
  local p = ctrl.parent
  local value = slider_type[p.name]
  if value ~= nil then
    local player = w_top.svar.player
    local var = ctrl.scroll * cValueMax
    player:set_flag_int8(value.flag, var)
    var = player:get_flag_int8(value.flag)
    p:search("value").text = var
    value.value = var
  end
end
local f_rot_angle = 90
function on_doll_rotl_click(btn, press)
  if press then
    w_scn_view.rotate_angle = -f_rot_angle
  else
    w_scn_view.rotate_angle = 0
  end
end
function on_doll_rotr_click(btn, press)
  if press then
    w_scn_view.rotate_angle = f_rot_angle
  else
    w_scn_view.rotate_angle = 0
  end
end
function on_face_reset_click(btn)
  detail_reset(g_frames.face)
end
function on_body_reset_click(btn)
  detail_reset(g_frames.body)
end
function on_portrait_select_click(btn)
  local svar = w_top.svar
  local btn_var = btn.svar
  local portrait_excel = btn_var.excel
  svar.config.portrait_excel = portrait_excel
  w_check_orig_portrait.check = false
end
function on_check_orig_portrait(btn, chk)
  local svar = w_top.svar
  local w_content = g_frames.portrait:search("content")
  if chk then
    local w = w_content.control_head
    while w ~= nil do
      w.press = false
      w = w.next
    end
    svar.config.portrait_excel = nil
  else
    local w = w_content.control_head
    while w ~= nil do
      if w.press then
        return
      end
      w = w.next
    end
    select_first(w_content)
  end
end
function on_model_select_click(btn)
  local svar = w_top.svar
  local btn_var = btn.svar
  local excel = btn_var.init_excel
  local config = svar.config
  local w_content
  config.init_excel = excel
  local scn = w_scn_view.scn
  scn:clear_obj(-1)
  local player = scn:create_obj(bo2.eScnObjKind_Player, excel.id, "view_npc")
  svar.player = player
  scn:modify_camera_view_type(player, bo2.eCameraInit)
  scn:set_radius(camera_radius)
  scn:set_camera_angle(0, 0)
  player:SetEquipIsHandle(false, false)
  player:EquipClear()
  player:set_flag_int8(bo2.ePlayerFlagInt8_EyeSize, 128)
  player:set_flag_int8(bo2.ePlayerFlagInt8_EyeWide, 128)
  player:set_flag_int8(bo2.ePlayerFlagInt8_EyeBrow, 128)
  player:set_flag_int8(bo2.ePlayerFlagInt8_NostrilSize, 128)
  player:set_flag_int8(bo2.ePlayerFlagInt8_NoseBridgePos, 128)
  player:set_flag_int8(bo2.ePlayerFlagInt8_NoseGuard, 128)
  player:set_flag_int8(bo2.ePlayerFlagInt8_MouthSize, 128)
  player:set_flag_int8(bo2.ePlayerFlagInt8_PhiltrumLen, 128)
  player:set_flag_int8(bo2.ePlayerFlagInt8_MouthLipSize, 128)
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetWaist, excel.boneOffset[0])
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetNeck, excel.boneOffset[1])
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetUpperArm, excel.boneOffset[2])
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetForearm, excel.boneOffset[3])
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetUpperLeg, excel.boneOffset[4])
  player:set_flag_int8(bo2.ePlayerFlagInt8_BoneOffsetShank, excel.boneOffset[5])
  detail_init(g_frames.face, player)
  detail_init(g_frames.body, player)
  local w_hair = g_frames.hair
  w_content = w_hair:search("content")
  w_content:control_clear()
  local hairs = excel.hair
  local hair_selected = false
  for i = 0, hairs.size - 1 do
    local btn = ui.create_control(w_content, "button")
    local hair_id = hairs[i]
    btn.svar.hair_id = hair_id
    btn:load_style("$frame/item/item_model.xml", "btn_select")
    btn:search("img").image = sys.format("$gui/image/phase/choice/hair/%s_%s.png", excel.id, hairs[i])
    btn.group = w_content
    btn:insert_on_click(on_hair_select_click, "on_hair_select_click")
    if hair_id == config.hair_id then
      btn:click()
      btn.press = true
      hair_selected = true
    end
  end
  if not hair_selected then
    select_first(w_content)
  end
  local w_face = g_frames.face
  w_content = w_face:search("content")
  local w_icons = w_content:search("icons")
  w_icons:control_clear()
  local faces = excel.face
  local face_c = faces.size
  for i = 0, face_c - 1 do
    local btn = ui.create_control(w_icons, "button")
    local face_id = faces[i]
    btn.svar.face_id = face_id
    btn:load_style("$frame/item/item_model.xml", "btn_select")
    btn:search("img").image = sys.format("$gui/image/phase/choice/faces/%s_%s.png", excel.id, face_id)
    btn:insert_on_click(on_face_select_click, "on_hair_select_click")
    btn.group = w_icons
  end
  select_first(w_icons)
  local row_c = math.floor((face_c + 3) / 4)
  w_icons.dy = 66 * row_c
  w_icons:set_divide(4, row_c)
  w_content.dy = w_icons.dy + w_content:search("detail").dy
  w_face.dy = w_content.dy + 40
  if config.dress_id == nil then
    select_first(g_frames.dress:search("content"))
  else
    player:set_equip_model(bo2.eEquipData_Body, config.dress_id)
    player:set_equip_model(bo2.eEquipData_Legs, config.dress_id)
  end
  frame_expand(g_frames.model, true)
  frame_expand(g_frames.portrait, true)
  frame_expand(g_frames.dress, true)
  frame_expand(g_frames.hair, true)
  frame_expand(g_frames.face, false)
  frame_expand(g_frames.body, false)
end
function send_use()
  w_top.visible = false
  local svar = w_top.svar
  local item_info = ui.item_of_only_id(svar.item_id)
  if item_info == nil then
    return
  end
  local config = svar.config
  local player = svar.player
  local flag = sys.variant()
  for n, t in pairs(slider_type) do
    local f = t.flag
    flag[f] = player:get_flag_int8(f)
  end
  local v = sys.variant()
  v[packet.key.scnobj_flag] = flag
  v[packet.key.scnobj_excel_id] = config.init_excel.id
  if config.portrait_excel ~= nil then
    v[packet.key.cha_portrait] = config.portrait_excel.id
  end
  v:set("dress_id", config.dress_id)
  v:set("face_id", config.face_id)
  v:set("hair_id", config.hair_id)
  ui_item.send_use(item_info, v)
end
function on_confirm_click(btn)
  local player = bo2.player
  local svar = w_top.svar
  local config = svar.config
  local stk = sys.mtf_stack()
  stk:raw_push(ui.get_text("item_model|confirm_note"))
  stk:raw_push("\n")
  stk:push(ui.get_text("choice|choice_model"))
  stk:raw_push("\n")
  stk:raw_format("<img:$image/phase/choice/btn_cf_%d.png|110,0,108,190*54,95>", player.excel.id)
  stk:push(" >>> ")
  stk:raw_format("<img:$image/phase/choice/btn_cf_%d.png|110,0,108,190*54,95>", config.init_excel.id)
  stk:raw_push("\n")
  stk:push(ui.get_text("choice|choice_portrait"))
  stk:raw_push("\n")
  local orig_portrait_icon = bo2.gv_portrait:find(player:get_flag_int32(bo2.ePlayerFlagInt32_Portrait)).icon
  stk:raw_format("<img:$icon/portrait/%s.png>", orig_portrait_icon)
  stk:push(" >>> ")
  if config.portrait_excel then
    stk:raw_format("<img:$icon/portrait/%s.png>", config.portrait_excel.icon)
  else
    stk:raw_format("<img:$icon/portrait/%s.png>", orig_portrait_icon)
  end
  stk:raw_push("\n")
  stk:push(ui.get_text("item_model|misc"))
  stk:raw_push("\n")
  stk:raw_format("<img:$gui/image/phase/choice/dress/%s_%s.png>", config.dress_id, svar.sex_select)
  stk:raw_format("<img:$gui/image/phase/choice/hair/%s_%s.png>", config.init_excel.id, config.hair_id)
  stk:raw_format("<img:$gui/image/phase/choice/faces/%s_%s.png>", config.init_excel.id, config.face_id)
  ui_widget.ui_msg_box.show_common({
    text = stk.text,
    callback = function(msg)
      if msg.result ~= 1 then
        return
      end
      send_use()
    end,
    tune_window = function(msg)
      local w = msg.window
      w.dx = 280
      w:tune_y("rv_text")
    end
  })
end
function show(info)
  w_top.visible = true
  w_top:move_to_head()
  w_top:search("lb_title").text = info.excel.name
  local w_content
  local player = bo2.player
  local self_id = player.excel.id
  local svar = w_top.svar
  svar.sex = bo2.gv_init_cha:find(self_id).sex
  svar.mode = info.excel.use_par[0]
  if svar.mode == 1 then
    svar.sex_select = svar.sex
  elseif svar.sex == 1 then
    svar.sex_select = 2
  else
    svar.sex_select = 1
  end
  svar.item_id = info.only_id
  svar.config = {}
  local w_dress = g_frames.dress
  w_content = w_dress:search("content")
  w_content:control_clear()
  local equips = bo2.gv_career:find(math.floor((player:get_atb(bo2.eAtb_Cha_Profession) + 2) / 3)).equip
  for i = 0, equips.size - 1 do
    local btn = ui.create_control(w_content, "button")
    local dress_id = equips[i]
    btn.svar.dress_id = dress_id
    btn:load_style("$frame/item/item_model.xml", "btn_select")
    btn:search("img").image = sys.format("$gui/image/phase/choice/dress/%s_%s.png", dress_id, svar.sex_select)
    btn:insert_on_click(on_dress_select_click, "on_dress_select_click")
    btn.group = w_content
  end
  local w_portrait = g_frames.portrait
  w_content = w_portrait:search("content")
  w_content:control_clear()
  for i = 0, bo2.gv_portrait.size - 1 do
    local excel = bo2.gv_portrait:get(i)
    if excel.kind == svar.sex_select and excel.init == 1 then
      local btn = ui.create_control(w_content, "button")
      btn.svar.excel = excel
      btn:load_style("$frame/item/item_model.xml", "btn_select")
      btn:search("img").image = sys.format("$icon/portrait/%s.png", excel.icon)
      btn:insert_on_click(on_portrait_select_click, "on_portrait_select_click")
      btn.group = w_content
    end
  end
  if svar.mode == 1 then
    w_check_orig_portrait.visible = true
    w_check_orig_portrait.check = true
  else
    w_check_orig_portrait.visible = false
    select_first(w_content)
  end
  local w_model = g_frames.model
  local w_content = w_model:search("content")
  w_content:control_clear()
  for i = 0, bo2.gv_init_cha.size - 1 do
    local init_excel = bo2.gv_init_cha:get(i)
    ui.log("init_excel.id %d", init_excel.id)
    if (init_excel.disable == 0 or init_excel.model_enable ~= 0) and init_excel.id ~= self_id and init_excel.sex == svar.sex_select then
      local btn = ui.create_control(w_content, "button")
      btn:load_style("$frame/item/item_model.xml", "btn_model")
      btn:search("img").image = sys.format("$image/phase/choice/btn_cf_%d.png|0,0,440,190", init_excel.id)
      btn.svar.init_excel = init_excel
      btn.group = w_content
    end
  end
  select_first(w_content)
end
