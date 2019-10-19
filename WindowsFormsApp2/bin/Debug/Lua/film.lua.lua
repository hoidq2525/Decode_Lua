local g_disable_set_ui = false
local citem_url = L("$frame/film/film.xml")
local citem_name = L("talk_item")
local g_npc_mng = {}
local g_npc_name_mng = {}
local g_loading_process = 0
local g_aside_data = {}
local g_pause_scene = false
local g_btn_pause = false
local g_loading_process = false
local g_film_speed = 1
local g_camera_speed = 1
local g_film_end_type = 0
local c_static_mask_time = 1000
local g_mask_time = c_static_mask_time
local g_scn_mask_timer = c_static_mask_time
local g_next_film_id = 0
local g_current_film_id = 0
local g_pos_name
local g_skip_data = {}
function on_init_skip_data()
  g_skip_data = {valid = false, skip = false}
end
on_init_skip_data()
function on_init_scene_data()
  g_film_speed = 1
  g_camera_speed = 1
end
local g_talk_item_data = {}
g_art_charactor_data = {}
local g_art_charactor_max_dx = 512
local g_text_count = 0
local g_second_confirm_data = {is_valid = false}
function on_init_art_charactor_data()
  g_art_charactor_data = {
    valid = nil,
    pic_url = nil,
    phase = 0,
    pixel_dy = 0
  }
  if sys.check(g_art_charactor_timer) then
    g_art_charactor_timer.suspended = true
  end
  if sys.check(film_art_charactor) then
    film_art_charactor.visible = false
    for i = 0, 4 do
      local pic_name = sys.format("pic_line%d", i)
      local pic_i = film_art_charactor:search(pic_name)
      if sys.check(pic_i) then
        pic_i.visible = false
      end
    end
  end
end
local g_item_display_frame = 30
local g_talk_item_index = 0
function on_init_talk_item_data()
  on_clear_talk_data()
end
function on_clear_talk_data()
  g_talk_item_index = 0
  g_talk_list_root:item_clear()
  g_talk_item_data = {}
end
function insert_talk_data(name, text)
  ui_mask.on_subtitle_insert_data(ui_film.w_main, name, text)
end
function on_enable_mask_timer()
  g_mask_time = c_static_mask_time
  g_film_mask_timer.suspended = false
end
function on_timer_set_text()
  if ui_film.w_main.visible ~= true then
    g_film_text_timer.suspended = true
    g_text_count = 0
    return
  end
  if g_text_count > 5 then
    g_text_count = 0
  end
  local get_text_name = sys.format("film|film_%d", g_text_count)
  lb_film_text.text = ui.get_text(get_text_name)
  g_text_count = g_text_count + 1
end
function on_enable_scn_mask_timer()
  g_scn_mask_timer = 0
  g_film_enable_mask_timer.suspended = false
  ui_film.film_loading.visible = true
  ui_film.film_loading.alpha = 0
end
function on_timer_scn_mask(timer)
  if sys.check(ui_film.w_main) ~= true or ui_film.w_main.visible ~= true then
    timer.suspended = true
    return 0
  end
  g_scn_mask_timer = g_scn_mask_timer + timer.period
  ui_film.film_loading.alpha = g_scn_mask_timer * 0.004
  if g_scn_mask_timer >= 500 then
    if g_next_film_id == 0 then
      ui_film.w_main.visible = false
    else
      DestroyScn()
      local var_play_film = sys.variant()
      var_play_film:set(packet.key.cmn_id, g_next_film_id)
      g_next_film_id = 0
      HandleStartFilm(0, var_play_film)
    end
    timer.suspended = true
  end
end
function on_timer_set_mask(timer)
  if sys.check(ui_film.w_main) ~= true or ui_film.w_main.visible ~= true or sys.check(ui_film.film_loading) ~= true or ui_film.film_loading.visible ~= true then
    timer.suspended = true
    return 0
  end
  g_mask_time = g_mask_time - timer.period
  ui_film.film_loading.alpha = g_mask_time * 0.001
  if g_mask_time <= 0 then
    ui_film.film_loading.visible = false
  end
end
function on_second_confirm_to_close_film(w)
  if sys.check(mask_view_bind) ~= true or mask_view_bind.visible == true then
    return
  end
  local function on_msg_callback(msg)
    if msg.result == 1 and sys.check(w) then
      ui_film.w_main.visible = false
      return
    end
    if sys.check(ui_film.w_main) and ui_film.w_main.visible == true then
      ui_film.w_main.focus = true
    end
  end
  g_second_confirm_data = {
    text = ui.get_text("film|skip_film"),
    btn_confirm = ui.get_text("film|skip"),
    btn_cancel = ui.get_text("film|cancel_skip"),
    owner = ui_film.w_main,
    btn2 = true,
    callback = on_msg_callback,
    is_valid = true
  }
  ui_widget.ui_msg_box.show_common(g_second_confirm_data)
end
function on_click_skip_film()
  if g_loading_process == nil or g_loading_process == true then
    return
  end
  on_second_confirm_to_close_film(w_main)
end
function on_film_key(w, key, flag)
  if key == ui.VK_ESCAPE then
    if flag.down == true then
      return
    end
    on_second_confirm_to_close_film(w)
  else
    ui_main.on_key(w, key, flag)
  end
end
function on_esc_visible(w, vis)
  if vis then
    if ui_film.destroy_timer then
      ui_film.destroy_timer.suspended = true
    end
    if sys.check(ui_phase.w_main) then
      ui.tag_text_reset(ui_phase.w_main)
    end
    if sys.check(gx_scn.scn) then
      gx_scn.scn:DisableRender(false)
    end
    bo2.set_disable_scn_music(true)
    g_film_mask_timer.suspended = true
    on_clear_talk_data()
    bo2.SetCamfar(500)
    if sys.check(ui_film.g_film_text_timer) then
      ui_film.g_film_text_timer.suspended = false
      g_text_count = 0
    end
    function on_move_to_head()
      if sys.check(w) then
        w:move_to_head()
      end
    end
    bo2.AddTimeEvent(25, on_move_to_head)
    w_main.focus = true
  else
    if g_second_confirm_data ~= nil and g_second_confirm_data.is_valid == true then
      ui_widget.ui_msg_box.cancel(g_second_confirm_data)
    end
    g_second_confirm_data = {is_valid = false}
    if film_end() ~= true then
      g_current_film_id = 0
      w.visible = true
      return
    end
    w_main.focus = false
    ui_main.ShowUI(true)
    if sys.check(ui_film.g_film_enable_mask_timer) then
      ui_film.g_film_enable_mask_timer.suspended = true
    end
    if sys.check(ui_film.film_loading) then
      ui_film.film_loading.visible = false
    end
    bo2.revert_soundmgr()
    bo2.scn:DisableRender(false)
    ui_widget.esc_stk_pop(w)
    on_close_debug_info()
    if sys.check(ui_film.destroy_timer) then
      ui_film.destroy_timer.suspended = false
    end
    gx_scn.scn:DisableRender(true)
    g_next_film_id = 0
    bo2.SetCamfar(0)
    bo2.scn:DisableRender(false)
  end
end
function Create_Scn(scn_id, film_id, posName)
  ui_film.g_mask_top.visible = false
  ui_film.g_mask_bottom.visible = false
  ui_film.film_loading.visible = true
  film_loading_mask.visible = false
  if g_disable_set_ui == true then
  else
    ui_main.ShowUI(false)
  end
  bo2.scn:DisableRender(true)
  g_loading_per = 0
  ui_film.film_loading.alpha = 1
  film_loading_mask.visible = true
  local on_call_back_scn_progress = function(per, msg)
    if per > 0.9 then
      film_loading_mask.visible = true
    end
    if per < 0.1 then
      bo2.draw_gui()
    end
  end
  gx_scn.visible = false
  gx_scn:load_scn(scn_id, nil)
  ui_film.film_loading.alpha = 1
  film_loading_mask.visible = true
  bo2.draw_gui()
  ui_film.g_mask_top.visible = true
  ui_film.g_mask_bottom.visible = true
  g_pos_name = posName
  bo2.draw_gui()
  on_init_scene_data()
  local scn = gx_scn.scn
  if scn == nil then
    return
  end
  scn:bind_soundmgr()
  ui.view_tag_text_reset(gx_scn)
  gx_scn.scn:UpdateAllPin(true)
  ui_film.w_main:move_to_head()
end
function Clear_All_Scn()
  local scn = gx_scn.scn
  if scn == nil then
    return
  end
  scn:clear_obj(bo2.eScnObjKind_Player)
  scn:clear_obj(bo2.eScnObjKind_Npc)
  scn:clear_obj(bo2.eScnObjKind_Still)
  scn:clear_obj(bo2.eScnObjKind_Lone)
  scn:clear_client_scnobj()
end
function DestroyScn()
  if sys.check(gx_scn.scn) then
    Clear_All_Scn()
    g_npc_mng = {}
    g_npc_name_mng = {}
  end
end
function OnCleanScn()
  if sys.check(gx_scn.scn) then
    DestroyScn()
    gx_scn:set_excel_id(0)
  end
end
function Create_Obj(cha_id, pos, id, name, use_index, refresh_index, fade_in)
  local npc = gx_scn.scn:create_obj(bo2.eScnObjKind_Npc, cha_id, pos, nil, use_index, refresh_index, fade_in)
  if sys.check(npc) then
    npc:set_flag_objmem(bo2.eFlagObjMemory_Run, 1)
    local _cha_list = bo2.gv_cha_list:find(cha_id)
    if _cha_list ~= nil then
      local career_id = _cha_list.nCareer
      if career_id ~= 0 then
        npc:set_view_player_career(career_id)
      end
    end
    g_npc_mng[id] = npc
    if sys.check(name) and 1 <= name.size then
      local string_name = tostring(name)
      if g_npc_name_mng[string_name] == nil then
        g_npc_name_mng[string_name] = {}
      end
      table.insert(g_npc_name_mng[string_name], npc)
    end
  end
  return npc
end
function on_time_set_art_charactor()
  if ui_film.w_main.visible == false or g_art_charactor_data == nil or g_art_charactor_data.valid ~= true or sys.check(film_art_charactor) ~= true then
    g_art_charactor_timer.suspended = true
    return
  end
  film_art_charactor.visible = true
  local add_phase = false
  for i = 0, 4 do
    local pic_name = sys.format("pic_line%d", i)
    local pic_i = film_art_charactor:search(pic_name)
    if sys.check(pic_i) ~= true then
      g_art_charactor_timer.suspended = true
      ui.log("pic_error!")
      return
    end
    if i > g_art_charactor_data.phase then
      pic_i.visible = false
    else
      if i == g_art_charactor_data.phase then
        local dy = g_art_charactor_max_dx
        if i == 0 then
          dy = g_art_charactor_data.phase0_dy_pixel
        end
        local speed = g_art_charactor_data.phase0_speed
        if i ~= 0 then
          if i % 2 ~= 0 then
            speed = g_art_charactor_data.phase1_speed
          else
            speed = g_art_charactor_data.phase2_speed
          end
        end
        speed = speed / 10
        if speed < 1 then
          speed = 1
        end
        g_art_charactor_data.pixel_dy = g_art_charactor_data.pixel_dy + dy / speed
        local set_dy = g_art_charactor_data.pixel_dy
        if dy <= g_art_charactor_data.pixel_dy then
          g_art_charactor_data.pixel_dy = dy
          add_phase = true
        end
        local dx_margin = 0
        local dx0 = 0
        local dx1 = 0
        for j = 0, 4 - i do
          if j == 0 then
            dx_margin = dx_margin + g_art_charactor_data.phase0_dx
            dx0 = dx_margin
            dx1 = dx_margin + g_art_charactor_data.phase2_dx
          elseif j % 2 == 0 then
            dx_margin = dx_margin + g_art_charactor_data.phase1_dx
            dx0 = dx_margin
            dx1 = dx_margin + g_art_charactor_data.phase2_dx
          elseif j % 2 ~= 0 then
            dx_margin = dx_margin + g_art_charactor_data.phase2_dx
            dx0 = dx_margin
            dx1 = dx_margin + g_art_charactor_data.phase1_dx
          end
        end
        if dx1 > g_art_charactor_max_dx then
          dx1 = g_art_charactor_max_dx
        end
        pic_i.margin = ui.rect(dx_margin, 0, 0, 0)
        pic_i.dy = set_dy
        local image_pic = sys.format("%s|%d,0,%d,%d", g_art_charactor_data.url, dx0, dx1, set_dy)
        pic_i.image = image_pic
        if i == 0 then
          pic_i.dx = g_art_charactor_max_dx - dx0
        else
          pic_i.dx = dx1 - dx0
        end
        pic_i.visible = true
      else
      end
    end
  end
  if add_phase == true then
    g_art_charactor_data.pixel_dy = 0
    g_art_charactor_data.phase = g_art_charactor_data.phase + 1
    if 4 < g_art_charactor_data.phase then
      g_art_charactor_timer.suspended = true
      return
    end
  end
end
function FilmCameraControl(_id, npc_id)
  if npc_id ~= 0 then
    local npc = g_npc_mng[npc_id]
    if sys.check(npc) then
      gx_scn.scn:SetCameraControl(_id, npc.sel_handle)
    else
    end
  else
    gx_scn.scn:SetCameraControl(_id, 0)
  end
end
function FilmSeceneTask(_type, begin_frame, last_frame, speed)
  local v = sys.variant()
  v:set(packet.key.cmn_type, _type)
  v:set(packet.key.ui_begin, begin_frame)
  v:set(packet.key.marquee_times, last_frame)
  v:set(packet.key.marquee_speed, speed)
  gx_scn.scn:AddScnTask(v)
end
function on_film_init()
  g_npc_mng = {}
  g_npc_name_mng = {}
end
function set_visible(vis)
  ui_film.w_main.visible = vis
  on_init_art_charactor_data()
end
function preload_resource(pFilmData, fDist, fRadius)
  local load_obj_res = function()
    local call_back_obj_res_load = function()
      bo2.draw_gui()
    end
    gx_scn.scn:start_object_res_load(call_back_obj_res_load)
  end
  sys.cpu_pcall(" film :: load_obj_res", load_obj_res)
  if sys.check(pFilmData) ~= true then
    return
  end
  local g_load_histroy = {}
  for i = 0, pFilmData.inc_film_key_frame.size - 1 do
    local excel_id = pFilmData.inc_film_key_frame[i]
    local pCurrentKeyFrame = bo2.gv_film_key_frame:find(excel_id)
    if sys.check(pCurrentKeyFrame) then
      local iKeyFrameType = pCurrentKeyFrame.execute_type
      if iKeyFrameType == bo2.eKeyFrameType_PlayAnime then
        local iHandle = pCurrentKeyFrame.param0.v_int
        local iAnimeIndex = pCurrentKeyFrame.param1.v_int
        if g_load_histroy[iHandle] == nil or g_load_histroy[iHandle][iAnimeIndex] == nil then
          if g_load_histroy[iHandle] == nil then
            g_load_histroy[iHandle] = {}
          end
          g_load_histroy[iHandle][iAnimeIndex] = 1
          local npc = g_npc_mng[iHandle]
          if sys.check(npc) then
            npc:LoadAnimeRes(iAnimeIndex)
          end
        end
      elseif iKeyFrameType == bo2.eKeyFrameType_PlaySound then
        local iSoundID = pCurrentKeyFrame.param0.v_int
        local iLoop = pCurrentKeyFrame.param1.v_int
        local iStream = pCurrentKeyFrame.param2.v_int
        local bLoop = false
        local bStream = true
        if iLoop == 0 then
          bLoop = false
        else
          bLoop = true
        end
        if iStream == 0 then
          bStream = true
        else
          bStream = false
        end
        bo2.LoadSound2D(iSoundID, bLoop, bStream)
      end
    end
  end
  local function load_res()
    local on_call_back_progress = function(per, msg)
      bo2.draw_gui()
    end
    gx_scn.scn:start_res_load_by_pos_name(g_pos_name, on_call_back_progress, fDist, fRadius)
  end
  sys.cpu_pcall(" film :: load_res", load_res)
end
function execute_key_frame(pKeyFrameData, bInitKeyFrame, pFilmData)
  if sys.check(pKeyFrameData) ~= true then
    return true
  end
  local iKeyFrameType = pKeyFrameData.execute_type
  if iKeyFrameType == bo2.eKeyFrameType_CreateScene then
    local function ON_CREATE_SCN()
      OnCleanScn()
      Create_Scn(pKeyFrameData.param0.v_int, nil, pKeyFrameData.param1.v_string)
    end
    sys.cpu_pcall(" film :: ON_CREATE_SCN", ON_CREATE_SCN)
  elseif iKeyFrameType == bo2.eKeyFrameType_CreateActor then
    local iChaID = pKeyFrameData.param0.v_int
    local iPos = pKeyFrameData.param1.v_string
    local iHandle = pKeyFrameData.param2.v_int
    local iNum = pKeyFrameData.param3.v_int
    local strName = pKeyFrameData.param4.v_string
    local updateAnime = pKeyFrameData.param5.v_int
    local fade_in = pKeyFrameData.param6.v_int
    if iNum > 1 then
      for i = 0, iNum - 1 do
        local pNpc = Create_Obj(iChaID, iPos, iHandle + i, strName, 1, i, fade_in)
        if updateAnime == 1 and sys.check(pNpc) then
          pNpc:SetAlwaysUpdateAnime(true)
        end
      end
    else
      local pNpc = Create_Obj(iChaID, iPos, iHandle, strName, 0, 0, fade_in)
      if updateAnime == 1 and sys.check(pNpc) then
        pNpc:SetAlwaysUpdateAnime(true)
      end
    end
  elseif iKeyFrameType == bo2.eKeyFrameType_CameraControl then
    do
      local fDist = pKeyFrameData.param2.v_number
      local fRadius = pKeyFrameData.param3.v_number
      local function ON_RES_LOAD()
        if fDist <= 1 then
          fDist = 50
        end
        if fRadius < 1 then
          fRadius = 50
        end
        preload_resource(pFilmData, fDist, fRadius)
      end
      if bInitKeyFrame ~= nil and bInitKeyFrame == true then
        sys.cpu_pcall(" film :: preload_resource", ON_RES_LOAD)
      end
      local iControlId = pKeyFrameData.param0.v_int
      local iNpc = pKeyFrameData.param1.v_int
      FilmCameraControl(iControlId, iNpc)
    end
  elseif iKeyFrameType == bo2.eKeyFrameType_SceneTask then
    local iControlType = pKeyFrameData.param0.v_int
    local iBeginFrame = pKeyFrameData.key_frame
    local iLastFrame = pKeyFrameData.last_frame
    local iSpeed = pKeyFrameData.param1.v_int
    FilmSeceneTask(iControlType, iBeginFrame, iLastFrame, iSpeed)
  elseif iKeyFrameType == bo2.eKeyFrameType_ActorUseSkill then
    local iNpcId = pKeyFrameData.param0.v_int
    local iSkillID = pKeyFrameData.param1.v_int
    local iTargetId = pKeyFrameData.param2.v_int
    local strName = pKeyFrameData.param3.v_string
    local ActorUseSkill = function(skill_id, npc, target)
      if sys.check(npc) and sys.check(target) then
        npc:use_skill(skill_id, target.sel_handle, nil, 100, end_skill, bEnablePassive, bEnableState, bEnableState, bEnableDamageState)
      end
    end
    ActorUseSkill(iSkillID, g_npc_mng[iNpcId], g_npc_mng[iTargetId], strName)
    if 0 >= strName.size then
      return
    end
    local target_data = g_npc_mng[target_id]
    local npc_set = g_npc_name_mng[tostring(strName)]
    if npc_set ~= nil then
      for i, v in pairs(npc_set) do
        if sys.check(v) then
          ActorUseSkill(iSkillID, v, v)
        end
      end
    end
  elseif iKeyFrameType == bo2.eKeyFrameType_ActorMove then
    local iMoveType = pKeyFrameData.param0.v_int
    local iNpcId = pKeyFrameData.param1.v_int
    local pos_name = pKeyFrameData.param2.v_string
    local move_style = pKeyFrameData.param3.v_int
    local strName = pKeyFrameData.param4.v_string
    local move_speed = pKeyFrameData.param5.v_int
    local function ActorMove(move_type, npc_id, end_pos, move_style, name, move_speed)
      local npc = g_npc_mng[npc_id]
      local pos = gx_scn.scn:GetPosByPortal(end_pos)
      if sys.check(pos) ~= true then
        return
      end
      if sys.check(npc) then
        npc:SetMoveState(move_type, pos)
        if move_style == 1 then
          npc:set_flag_objmem(bo2.eFlagObjMemory_Run, 0)
        else
          npc:set_flag_objmem(bo2.eFlagObjMemory_Run, 1)
        end
        if move_speed > 0 then
          npc:set_atb(bo2.eAtb_MoveSpeed, move_speed)
        end
      elseif sys.check(name) and 0 < name.size then
        local _name = tostring(name)
        local text_excel = bo2.gv_text:find(text_id)
        if sys.check(text_excel) and g_npc_name_mng[_name] ~= nil then
          for i, v in pairs(g_npc_name_mng) do
            if sys.check(v) then
              v:SetMoveState(move_type, pos)
              if move_style == 1 then
                v:set_flag_objmem(bo2.eFlagObjMemory_Run, 0)
              else
                v:set_flag_objmem(bo2.eFlagObjMemory_Run, 1)
              end
            end
          end
        end
      end
    end
    ActorMove(iMoveType, iNpcId, pos_name, move_style, strName, move_speed)
  elseif iKeyFrameType == bo2.eKeyFrameType_ActorSpeak then
    do
      local iNpcId = pKeyFrameData.param0.v_int
      local iTextID = pKeyFrameData.param1.v_int
      local strName = pKeyFrameData.param2.v_string
      local bDisableNpcTalk = pKeyFrameData.param3.v_int
      local function ActorSpeak(actor_id, text_id)
        local npc = g_npc_mng[actor_id]
        if sys.check(npc) then
          local text_excel = bo2.gv_text:find(text_id)
          if sys.check(text_excel) then
            if bDisableNpcTalk ~= 1 then
              npc:NpcTalk(text_excel.text)
            end
            local data = sys.variant()
            data:set(packet.key.ui_text_id, iTextID)
            local name = npc.cha_name
            if name.size <= 0 then
              name = npc.excel.name
            end
            data:set(packet.key.cha_name, name)
            ui_chat.show_ui_text(0, data)
          end
        elseif sys.check(name) and 0 < name.size then
          local _name = tostring(name)
          local text_excel = bo2.gv_text:find(text_id)
          if sys.check(text_excel) and g_npc_name_mng[_name] ~= nil then
            for i, v in pairs(g_npc_name_mng) do
              if sys.check(v) then
                v:NpcTalk(text_excel.text)
              end
            end
          end
        end
      end
      ActorSpeak(iNpcId, iTextID, strName)
    end
  elseif iKeyFrameType == bo2.eKeyFrameType_Aside then
    local iTextID = pKeyFrameData.param0.v_int
    local iNpcID = pKeyFrameData.param1.v_int
    local data = sys.variant()
    data:set(packet.key.ui_text_id, iTextID)
    local npc = g_npc_mng[id]
    if sys.check(npc) then
      local name = npc.cha_name
      if 0 >= name.size then
        name = npc.excel.name
      end
      data:set(packet.key.cha_name, name)
    end
    ui_chat.show_ui_text(0, data)
  elseif iKeyFrameType == bo2.eKeyFrameType_FilmClose then
    set_visible(false)
  elseif iKeyFrameType == bo2.eKeyFrameType_KillActor then
    local iHandle = pKeyFrameData.param0.v_int
    local iDeadType = pKeyFrameData.param1.v_int
    local strName = pKeyFrameData.param2.v_string
    local function ActorSetDead(id, dead_type, name)
      local npc = g_npc_mng[id]
      if sys.check(npc) then
        npc:FakeSetDead(dead_type)
        g_npc_mng[id] = nil
      elseif name.size > 0 then
        local _name = tostring(name)
        if g_npc_name_mng[_name] ~= nil then
          for i, v in pairs(g_npc_name_mng) do
            if sys.check(v) then
              v:FakeSetDead(dead_type)
            end
          end
        end
      end
    end
    ActorSetDead(iHandle, iDeadType, strName)
  elseif iKeyFrameType == bo2.eKeyFrameType_CameraShaker then
    local iTime = pKeyFrameData.param0.v_int
    local iID = pKeyFrameData.param1.v_int
    gx_scn.scn:CameraShake(iTime, iID)
  elseif iKeyFrameType == bo2.eKeyFrameType_AddSceneParticle then
    local iId = pKeyFrameData.param0.v_int
    local iPosName = pKeyFrameData.param1.v_string
    local iHandle = pKeyFrameData.param2.v_int
    local function AddSceneParticle(iId, iPosName, iHandle)
      local npc = g_npc_mng[iHandle]
      if sys.check(npc) then
        gx_scn.scn:_AddMethodUnit(iId, npc, true, iPosName)
      else
      end
    end
    AddSceneParticle(iId, iPosName, iHandle)
  elseif iKeyFrameType == bo2.eKeyFrameType_PlayAnime then
    local iHandle = pKeyFrameData.param0.v_int
    local iAnimeIndex = pKeyFrameData.param1.v_int
    local iLoop = pKeyFrameData.param2.v_int
    if iLoop == 0 then
      iLoop = false
    else
      iLoop = true
    end
    local npc = g_npc_mng[iHandle]
    if sys.check(npc) then
      npc:ViewPlayerAnimPlayFadeIn(iAnimeIndex, 0, 1, iLoop)
    end
    local npc_name = pKeyFrameData.param3.v_string
    if 0 >= npc_name.size then
      return
    end
    local npc_set = g_npc_name_mng[tostring(npc_name)]
    if sys.check(npc_set) then
      for i, v in pairs(npc_set) do
        if sys.check(v) then
          v:ViewPlayerAnimPlayFadeIn(iAnimeIndex, 0, 1, iLoop)
        end
      end
    end
  elseif iKeyFrameType == bo2.eKeyFrameType_NpcDefence then
    local iHandle = pKeyFrameData.param0.v_int
    local iDefenceType = pKeyFrameData.param1.v_int
    local npc = g_npc_mng[iHandle]
    if sys.check(npc) then
      npc:set_flag_objmem(bo2.eFlagObjMemory_Defend, iDefenceType)
    end
    local npc_name = pKeyFrameData.param2.v_string
    if 0 >= npc_name.size then
      return
    end
    local npc_set = g_npc_name_mng[tostring(npc_name)]
    for i, v in pairs(npc_set) do
      if sys.check(v) then
        v:set_flag_objmem(bo2.eFlagObjMemory_Defend, iDefenceType)
      end
    end
  elseif iKeyFrameType == bo2.eKeyFrameType_ArtCharactor then
    on_init_art_charactor_data()
    g_art_charactor_data.url = sys.format("$image/server_charactor/%s.png", pKeyFrameData.param0.v_string)
    g_art_charactor_data.phase0_speed = pKeyFrameData.param1.v_int
    g_art_charactor_data.phase0_dy_pixel = pKeyFrameData.param2.v_int
    g_art_charactor_data.phase1_speed = pKeyFrameData.param3.v_int
    g_art_charactor_data.phase2_speed = pKeyFrameData.param4.v_int
    g_art_charactor_data.phase0_dx = pKeyFrameData.param5.v_int
    g_art_charactor_data.phase1_dx = pKeyFrameData.param6.v_int
    g_art_charactor_data.phase2_dx = pKeyFrameData.param7.v_int
    g_art_charactor_data.valid = true
    g_art_charactor_data.phase = 0
    g_art_charactor_data.pixel_dy = 0
    g_art_charactor_timer.suspended = false
  elseif iKeyFrameType == bo2.eKeyFrameType_AddState then
    local iHandle = pKeyFrameData.param0.v_int
    local iStateID = pKeyFrameData.param1.v_int
    local npc = g_npc_mng[iHandle]
    if sys.check(npc) then
      npc:AddState(iStateID, npc)
    end
    local npc_name = pKeyFrameData.param2.v_string
    local npc_set = g_npc_name_mng[tostring(npc_name)]
    if 0 >= npc_name.size then
      return
    end
    for i, v in pairs(npc_set) do
      if sys.check(v) then
        v:AddState(iStateID, v)
      end
    end
  elseif iKeyFrameType == bo2.eKeyFrameType_PlaySound then
    local iSoundID = pKeyFrameData.param0.v_int
    bo2.enable_sound2D(iSoundID)
  elseif iKeyFrameType == bo2.eKeyFrameType_ActorFastMove then
    local iHandle = pKeyFrameData.param0.v_int
    local iType = pKeyFrameData.param1.v_int
    local fSpeed = pKeyFrameData.param2.v_int
    local npc = g_npc_mng[iHandle]
    if sys.check(npc) then
      npc:set_flag_objmem(bo2.eFlagObjMemory_FastMove, iType)
      if fSpeed > 0 then
        npc:set_atb(bo2.eAtb_MoveSpeed, fSpeed)
      end
    end
    local npc_name = pKeyFrameData.param3.v_string
    if 0 >= npc_name.size then
      return
    end
    local npc_set = g_npc_name_mng[tostring(npc_name)]
    for i, v in pairs(npc_set) do
      if sys.check(v) then
        v:set_atb(bo2.eAtb_MoveSpeed, fSpeed)
      end
    end
  elseif iKeyFrameType == bo2.eKeyFrameType_PlayNewFilm then
    do
      local iIndex = pKeyFrameData.param0.v_int
      local bSameScn = pKeyFrameData.param1.v_int
      g_next_film_id = iIndex
      if bSameScn == 1 then
        if sys.check(gx_scn.scn) then
          gx_scn.scn:ResetFilm()
        end
        on_enable_scn_mask_timer()
      else
        local function on_time_play_film()
          local var_play_film = sys.variant()
          var_play_film:set(packet.key.cmn_id, iIndex)
          HandleStartFilm(0, var_play_film)
        end
        bo2.AddTimeEvent(1, on_time_play_film)
      end
      return false
    end
  elseif iKeyFrameType == bo2.eKeyFrameType_ExecuteServerEventStream then
    local iIndex = pKeyFrameData.param0.v_int
    if iIndex ~= 0 then
      local var = sys.variant()
      var:set(packet.key.group_id, iIndex)
      bo2.send_variant(packet.eCTS_Film_End, var)
    end
  elseif iKeyFrameType == bo2.eKeyFrameType_DisableSceneMusic then
    bo2.set_disable_scn_music(true)
  elseif iKeyFrameType == bo2.eKeyFrameType_CloneSelfPlayer then
    local strPos = pKeyFrameData.param1.v_string
    local iHandle = pKeyFrameData.param2.v_int
    local updateAnime = pKeyFrameData.param3.v_int
    local player = bo2.player
    if sys.check(player) then
      local gui_player = gx_scn.scn:create_obj(bo2.eScnObjKind_Player, player.excel.id, strPos)
      gui_player.view_target = player
      gui_player:set_flag_objmem(bo2.eFlagObjMemory_Run, 1)
      if updateAnime == 1 then
        gui_player:SetAlwaysUpdateAnime(true)
      end
      g_npc_mng[iHandle] = gui_player
    end
  elseif iKeyFrameType == bo2.eKeyFrameType_HandsonFoundNpc then
    if sys.check(ui_handson_teach.on_scn_npc_nofity) then
      ui_handson_teach.on_scn_npc_nofity()
    end
  elseif iKeyFrameType == bo2.eKeyFrameType_PlayRandomAnime then
    do
      local iHandle = pKeyFrameData.param0.v_int
      local iAnimeVessel = pKeyFrameData.param1
      local iLoop = pKeyFrameData.param2.v_int
      local iInterval = pKeyFrameData.param4.v_int
      local anime_size = iAnimeVessel.size - 1
      local array_0 = iAnimeVessel:split_to_int_array("*")
      if iLoop == 0 then
        iLoop = false
      else
        iLoop = true
      end
      local interval_time = 0
      local npc_handle = iHandle
      local cur_npc = g_npc_mng[npc_handle]
      local function on_play_anime(cur_npc)
        if ui_film.w_main.visible == false then
          return
        end
        if sys.check(gx_scn.scn) ~= true then
          return
        end
        local anime_size = array_0.size - 1
        local anime_index = bo2.rand(0, anime_size)
        local anime = array_0:get(anime_index).v_int
        if sys.check(cur_npc) then
          cur_npc:ViewPlayerAnimPlayFadeIn(anime, 0, 1, iLoop)
        else
        end
      end
      if iInterval > 0 then
        do
          local interval_time = bo2.rand(1, iInterval)
          local _npc = cur_npc
          local function on_play()
            on_play_anime(_npc)
          end
          bo2.AddTimeEvent(interval_time, on_play_anime)
        end
      else
        on_play_anime(cur_npc)
      end
      local npc_name = pKeyFrameData.param3.v_string
      if 0 >= npc_name.size then
        return
      end
      local npc_set = g_npc_name_mng[tostring(npc_name)]
      if npc_set ~= nil then
        for i, v in pairs(npc_set) do
          if sys.check(v) then
            if iInterval > 0 then
              do
                local _npc = v
                local interval_time = bo2.rand(1, iInterval)
                local function play_anime()
                  on_play_anime(_npc)
                end
                bo2.AddTimeEvent(interval_time, on_play_anime)
              end
            else
              local cur_npc = v
              on_play_anime(cur_npc)
            end
          end
        end
      end
    end
  elseif iKeyFrameType == bo2.eKeyFrameType_Weather then
    if sys.check(gx_scn.scn) ~= true then
      return
    end
    local scn = gx_scn.scn
    local name = pKeyFrameData.param0.v_string
    local time = pKeyFrameData.param1.v_int
    scn:set_local_weather(name, time)
  elseif KeyFrameFunc ~= nil and KeyFrameFunc[iKeyFrameType] ~= nil then
    KeyFrameFunc[iKeyFrameType](pKeyFrameData)
  end
  return true
end
function runf_test_packet()
  local var = sys.variant()
  var:set(packet.key.group_id, 2)
  bo2.send_variant(packet.eCTS_Film_End, var)
end
function update_aside_data()
  local close_aside_data = function()
  end
  if sys.check(g_aside_data.pFilmData) ~= true then
    close_aside_data()
    return false
  end
end
function on_init_film_aside(pFilmData)
  g_aside_data = {}
  g_aside_data.pFilmData = pFilmData
  g_aside_data.cur_key_frame = 0
  g_aside_data.cur_second = 0
end
g_bg_callback = nil
function set_bg_visible(vis)
  bg_rand.visible = vis
  bg_rand_mask.visible = vis
  if vis == false then
    clear_bg_display()
  end
  if g_bg_callback ~= nil and sys.check(g_bg_callback) then
    bo2.RemoveTimeEvent(g_bg_callback)
  end
end
function execute_film(film_id, film_end_type)
  local pFilmData = bo2.gv_film_data:find(film_id)
  if sys.check(pFilmData) ~= true then
    return false
  end
  if pFilmData.first_key_frame_id.size == 0 then
    return false
  end
  g_loading_process = true
  set_visible(true)
  g_film_end_type = film_end_type
  on_film_init()
  g_current_film_id = film_id
  mask_view_bind.visible = true
  set_bg_visible(false)
  bo2.draw_gui()
  for i = 0, pFilmData.first_key_frame_id.size - 1 do
    local excel_id = pFilmData.first_key_frame_id[i]
    local pFirstKeyFrame = bo2.gv_film_key_frame:find(excel_id)
    if pFirstKeyFrame.is_end ~= 1 then
      execute_key_frame(pFirstKeyFrame, true, pFilmData)
    end
  end
  mask_view_bind.visible = false
  if sys.check(gx_scn.scn) then
    gx_scn.scn:SetFilmDataID(film_id)
  end
  on_init_film_aside(pFilmData)
  gx_scn.visible = true
  film_loading_mask.visible = false
  bo2.draw_scngui()
  on_enable_mask_timer()
  timer.suspended = true
  g_loading_process = false
  ui_widget.esc_stk_push(w)
  w_main.focus = true
  return true
end
function _run(...)
  ui.log("------------------film prepare ------------------")
  local function on_run_data()
    local iFilmIdx = arg[1].v_int
    execute_film(iFilmIdx)
  end
  sys.cpu_pcall(" film :: _run", on_run_data)
  ui.log("------------------film end ------------------")
  if arg[2] ~= nil then
    local iFrame = arg[2].v_int
    gx_scn.scn:JumpToFrame(iFrame)
  end
end
function run(...)
  local _film_speed = g_film_speed
  local _camera_speed = g_camera_speed
  local iFilmIdx = arg[1].v_int
  execute_film(iFilmIdx)
  set_pause()
  set_pause_scene(true)
  show_debug()
  on_click_refresh_debug_info()
  on_set_film_speed(g_film_speed)
  on_set_camera_speed(_camera_speed)
  if arg[2] ~= nil then
    local iFrame = arg[2].v_int
    gx_scn.scn:JumpToFrame(iFrame)
  end
end
function FilmLogicTick(pFilmKeyFrame)
  if sys.check(pFilmKeyFrame) ~= true then
    return
  end
  execute_key_frame(pFilmKeyFrame)
end
function on_timer_destroy()
  ui_film.destroy_timer.suspended = true
  if ui_film.w_main.visible == false then
    OnCleanScn()
  end
end
function film_end()
  if g_film_end_type ~= nil then
    local var = sys.variant()
    var:set(packet.key.film_end_type, g_film_end_type)
    if g_film_end_type == bo2.eFilmEnd_Knight then
      var = ui_packet.g_knight_film_var
      var:set(packet.key.knight_pk_npc_cha_id, knight_id_tmp)
      var:set(packet.key.knight_ack_result, bo2.FIGHT_NPC_SUC)
      ui_knight.handle_knight_ack_rst(packet.eSTC_UI_KnightAckRst, var)
    elseif g_film_end_type == bo2.eFilmEnd_ZDTeach then
      ui_zdteach.show_com_ui()
      bo2.send_variant(packet.eCTS_ZDTeach_FilmFinish, var)
    elseif g_film_end_type ~= 0 then
    end
  end
  g_film_end_type = 0
  if g_current_film_id == nil then
    return true
  end
  local pFilmData = bo2.gv_film_data:find(g_current_film_id)
  if sys.check(pFilmData) ~= true then
    return true
  end
  local bRst = true
  for i = 0, pFilmData.first_key_frame_id.size - 1 do
    local excel_id = pFilmData.first_key_frame_id[i]
    local pEndKeyFrame = bo2.gv_film_key_frame:find(excel_id)
    if pEndKeyFrame.is_end == 1 and execute_key_frame(pEndKeyFrame) ~= true then
      bRst = false
    end
  end
  return bRst
end
function on_send()
  local var = sys.variant()
  var:set(packet.key.knight_pk_npc_cha_id, 60944)
  var:set(packet.key.knight_pk_npc_lvl, 3)
  bo2.send_variant(packet.eSTC_Knight_FriendAssist_Confirm, var)
end
function on_close_debug_info()
  if sys.check(ui_film.debug_info_timer) then
    ui_film.debug_info_timer.suspended = true
  end
  if sys.check(w_debug_panel) then
    w_debug_panel.visible = false
  end
end
function show_debug()
  ui_film.debug_info_timer.suspended = false
  ui_film.w_debug_panel.visible = true
  local scn = gx_scn.scn
  if scn == nil then
    return
  end
  scn:SetUnLoadFreeCamera(true)
end
function set_pause_debug_info(bPause)
  g_pause_scene = bPause
end
function set_pause_scene(bPause)
  set_pause_debug_info(bPause)
  local scn = gx_scn.scn
  if scn == nil then
    return
  end
  if bPause then
    gx_scn.scn:ClearSystemSceneTask()
    local v = sys.variant()
    v:set(packet.key.cmn_type, 1)
    v:set(packet.key.ui_begin, 0)
    v:set(packet.key.marquee_times, -1)
    v:set(packet.key.marquee_speed, 0)
    gx_scn.scn:AddSystemSceneTask(v)
  else
    on_set_film_speed(g_film_speed)
    on_slider_film_speed(ui_film.w_film_speed, ui_film.w_film_speed.scroll * 512)
  end
end
function on_click_set_pause(btn)
  if g_pause_scene == false then
    btn.text = L("\188\204\208\248")
  else
    btn.text = L("\212\221\205\163")
  end
  set_pause_scene(not g_pause_scene)
end
function on_mouse_debug_info(w, msg, pos, wheel)
end
function on_click_refresh_debug_info()
  local scn = gx_scn.scn
  if scn == nil then
    rb_debug_text.mtf = "\195\187\211\208\179\161\190\176"
    return
  end
  local stk = sys.stack()
  stk:push(sys.format("\179\161\190\176\214\161\202\253:%d\n", scn.iTick))
  stk:push(sys.format("\215\214\196\187\214\161\202\253:\n"))
  local vData = scn:GetCameraData()
  local free_x = vData:get(packet.key.cha_pos_x).v_number
  local free_y = vData:get(packet.key.cha_pos_y).v_number
  local free_z = vData:get(packet.key.cha_pos_z).v_number
  local free_yaw = vData:get(packet.key.cha_min_level).v_number
  local free_pitch = vData:get(packet.key.cha_max_level).v_number
  stk:push(sys.format("\215\212\211\201\207\224\187\250:\n%.3f  %.3f\n%.3f*%.3f*%.3f\n", free_yaw, free_pitch, free_x, free_y, free_z))
  local satellite_x = vData:get(packet.key.action_target_x).v_number
  local satellite_y = vData:get(packet.key.action_target_y).v_number
  local satellite_z = vData:get(packet.key.action_target_z).v_number
  local satellite_yaw = vData:get(packet.key.action_target_id).v_number
  local satellite_pitch = vData:get(packet.key.action_distance).v_number
  local satellite_radius = vData:get(packet.key.action_speed).v_number
  stk:push(sys.format("\189\199\201\171\207\224\187\250:\n%.3f   %.3f\n%.3f*%.3f*%.3f\n radius:%.3f", satellite_yaw, satellite_pitch, satellite_x, satellite_y, satellite_z, satellite_radius))
  rb_debug_text.mtf = stk.text
end
function on_time_debug_info()
  if g_pause_scene == true then
    return
  end
  on_click_refresh_debug_info()
end
function on_set_camera_speed(fData)
  g_camera_speed = fData
  local iPos = 0.1 * fData + 0.01
  ui_film.w_free_camera_speed.scroll = iPos
end
function on_slider_camera_speed(w, pos)
  local fPos = pos / 512
  g_camera_speed = (fPos - 0.01) / 0.1
  w_camera_speed_label.text = sys.format(L("%.1f"), g_camera_speed)
  local scn = gx_scn.scn
  if scn == nil then
    return
  end
  scn.fFreeCameraMoveSpeed = g_camera_speed
end
function on_click_reset_camera_speed()
  on_set_camera_speed(1)
end
function set_camera_speed(...)
  local fData = arg[1].v_number
  on_set_camera_speed(fData)
end
function set_camera(...)
  local iControl = arg[1].v_int
  local iNpc = arg[2].v_int
  local scn = gx_scn.scn
  if scn == nil then
    return
  end
  FilmCameraControl(iControl, iNpc)
end
function set_pause()
  local scn = gx_scn.scn
  if scn == nil then
    return
  end
  if g_pause_scene ~= true then
    on_click_set_pause(ui_film.btn_debug_pause)
  end
end
function on_slider_film_speed(w, pos)
  local speed_persent = pos / 512
  local iSpeed = (speed_persent - 0.47916666666666663) / 0.020833333333333332
  local iRealSpeed = 0
  if iSpeed > 0 then
    if iSpeed < 8 then
      iRealSpeed = 1
    elseif iSpeed < 16 then
      iRealSpeed = 4
    elseif iSpeed < 20 then
      iRealSpeed = 8
    else
      iRealSpeed = 25
    end
  elseif iSpeed > -8 then
    iRealSpeed = 1
  elseif iSpeed > -16 then
    iRealSpeed = -4
  elseif iSpeed > -20 then
    iRealSpeed = -8
  else
    iRealSpeed = -25
  end
  g_film_speed = iRealSpeed
  w_film_speed_text.text = sys.format(L("%d"), g_film_speed)
  local scn = gx_scn.scn
  if scn == nil then
    return
  end
  if g_pause_scene == true then
    return
  end
  gx_scn.scn:ClearSystemSceneTask()
  local v = sys.variant()
  v:set(packet.key.cmn_type, 2)
  v:set(packet.key.ui_begin, 0)
  v:set(packet.key.marquee_times, -1)
  v:set(packet.key.marquee_speed, iRealSpeed)
  gx_scn.scn:AddSystemSceneTask(v)
end
function on_set_film_speed(speed)
  local iPos = 0.020833333333333332 * speed + 1 - 0.5208333333333334
  ui_film.w_film_speed.scroll = iPos
end
function on_click_reset_film_speed()
  on_set_film_speed(1)
end
function set_speed(...)
  local iSpeed = arg[1].v_int
  on_set_film_speed(iSpeed)
end
function clear_speed()
  gx_scn.scn:ClearSystemSceneTask()
end
function jump_to(...)
  local scn = gx_scn.scn
  if scn == nil then
    return
  end
  local iFrame = arg[1].v_int
  if g_pause_scene == true then
    on_click_set_pause(ui_film.btn_debug_pause)
  end
  gx_scn.scn:JumpToFrame(iFrame)
  local iSpeed = arg[2].v_int
  if iSpeed ~= 0 then
    gx_scn.scn:ClearSystemSceneTask()
    local v = sys.variant()
    v:set(packet.key.cmn_type, 2)
    v:set(packet.key.ui_begin, 0)
    v:set(packet.key.marquee_times, -1)
    v:set(packet.key.marquee_speed, iSpeed)
    gx_scn.scn:AddSystemSceneTask(v)
  end
end
function runf_camera(...)
  local scn = bo2.scn
  local iFrame = arg[1].v_int
  scn:SetCameraControl(iFrame, bo2.player.sel_handle)
end
function test_camera()
  local scn = bo2.scn
  local function go_2()
    scn:SetCameraControl(43, bo2.player.sel_handle)
  end
  local function go_1()
    scn:SetCameraControl(42, bo2.player.sel_handle, go_2)
  end
  scn:SetCameraControl(44, bo2.player.sel_handle, go_1)
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_film.packet_handler"
function HandleStartFilm(cmd, var)
  local id = var:get(packet.key.cmn_id).v_int
  local function on_time_execute_film()
    if sys.check(ui_film.w_main) then
      g_disable_set_ui = sys.check(ui_film.w_main) and ui_film.w_main.visible == true
      execute_film(id)
      g_disable_set_ui = false
    end
  end
  bo2.AddTimeEvent(1, on_time_execute_film)
  local _var = sys.variant()
  ui_npcfunc.ui_talk.on_close_talk(0, _var)
end
reg(packet.eSTC_Scn_StartFilm, HandleStartFilm, "ui_film.HandleStartFilm")
function on_skip_begin_scene()
  local text_excel = bo2.gv_text:find(2043)
  if text_excel == nil then
    return
  end
  local quit_text = text_excel.text
  ui_widget.ui_msg_box.show_common({
    text = quit_text,
    btn_confirm = ui.get_text("film|skip"),
    btn_cancel = ui.get_text("film|cancel_skip"),
    btn2 = true,
    callback = function(msg)
      if msg.result == 1 then
        local v = sys.variant()
        bo2.send_variant(packet.eCTS_deathCount_Knight_ReplyAsk, v)
      end
    end
  })
end
function save_begin_scene()
  local root = sys.xnode()
  local add_nod = root:add("film")
  add_nod:set_attribute("index", 143)
  ui_main.player_cfg_save(root, "film_skip.xml", 1)
  return
end
function check_skip()
  if g_skip_data == nil then
    return false
  end
  if g_skip_data.valid ~= true then
    local get_cfg = ui_main.player_cfg_load("film_skip.xml", 1)
    g_skip_data.valid = true
    g_skip_data.skip = get_cfg ~= nil
    save_begin_scene()
  end
  return g_skip_data.skip
end
function on_enter_begin_scene()
  on_init_skip_data()
  local bCheck = check_skip()
  if bCheck == nil or bCheck ~= true then
    return
  end
  on_skip_begin_scene()
end
function on_self_enter(cmd, var)
  on_init_talk_item_data()
  local function on_time_load_finish()
    local scn = bo2.scn
    if sys.check(scn) ~= true or sys.check(scn.excel) ~= true then
      if ui_mask.w_main.visible == true then
        ui_mask.w_main.visible = false
      end
      return
    end
    if scn.excel.sight_dummy ~= 0 then
      local firstlogin = var:get(packet.key.cmn_type).v_int
      if firstlogin == 1 then
        ui_tool.ui_avi_player.play_by_id(3)
      else
        local v = sys.variant()
        bo2.send_variant(packet.eCTS_ClientLoadOver, v)
      end
      if scn.excel.id == 143 then
        on_enter_begin_scene()
      end
    else
      bo2.firstinscn()
      if ui_mask.w_main.visible == true then
        ui_mask.w_main.visible = false
      end
    end
  end
  bo2.AddTimeEvent(1, on_time_load_finish)
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter, "ui_film.on_self_enter")
