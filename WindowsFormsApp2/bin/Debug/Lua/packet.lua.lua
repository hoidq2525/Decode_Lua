bo2wc_none = 0
bo2wc_connect = packet.eSTC_Fake_connect
bo2wc_disconnect = packet.eSTC_Fake_disconnect
bo2wc_login = packet.eSTC_Fake_login
bo2wc_queueing = packet.eSTC_Fake_queueing
bo2wc_enter_gzs = packet.eSTC_Fake_enter_gzs
bo2wc_list_gzs = packet.eSTC_Fake_list_gzs
bo2wc_goout_gzs = packet.eSTC_Fake_goout_gzs
bo2wc_goout_login = packet.eSTC_Fake_goout_login
bo2wc_create_cha = packet.eSTC_Fake_create_cha
bo2wc_list_cha = packet.eSTC_Fake_list_cha
bo2wc_list_quest = packet.eSTC_Fake_list_quest
bo2wc_show_quest = packet.eSTC_Fake_show_quest
bo2wc_talk_npc = packet.eSTC_Fake_talk_npc
bo2wc_talk_sel = packet.eSTC_Fake_talk_sel
bo2wc_delete_cha = packet.eSTC_Fake_delete_cha
bo2wc_list_cha_finshed = packet.eSTC_Fake_list_cha_finshed
rst_ok = 0
rst_failed = 1
login_succeed = 1
goto_gzs_succeed = 1
goto_login_succeed = 1
goto_login_kick = 2
service_intermit = 15
network_intermit = 16
rst_overflow = 100
rst_bad_arg = 101
rst_connect_failed = 1000
rst_connect_timeout = 1001
rst_connect_already = 1002
function recv_wrap(cmd, data)
  local s = bo2_recv_wrap_signal[cmd]
  if s == nil then
    return
  end
  ui_common.signal_invoke(s, cmd, data)
end
function recv_wrap_signal_insert(cmd, func, name)
  if cmd == 0 then
    error("bad command.")
    return
  end
  ui_common.signal_insert_into(bo2_recv_wrap_signal, cmd, func, name)
end
game_recv_signal_insert = recv_wrap_signal_insert
function recv_wrap_signal_remove(cmd, name)
  if cmd == 0 then
    error("bad command.")
    return
  end
  ui_common.signal_remove_from(bo2_recv_wrap_signal, cmd, name)
end
game_recv_signal_remove = recv_wrap_signal_remove
function login(data)
  local v = bo2.get_proxy_data():copy()
  if data.username ~= nil then
    v:set(bo2.login_proxy_user, data.username)
  end
  if data.password ~= nil then
    v:set(bo2.login_proxy_pass, data.password)
  end
  if data.type ~= nil then
    v:set(bo2.login_proxy_mode, data.type)
  end
  local rst = bo2.send_wrap(packet.eSTC_Fake_login, v)
  v:clear()
  return rst
end
function cha_create(data)
  local eCNC_ChaName = 0
  local eCNC_Camp = 1
  local eCNC_Profession = 2
  local eCNC_Model = 3
  local eCNC_Hair = 4
  local eCNC_Face = 5
  local eCNC_Equip = 6
  local eCNC_Portrait = 7
  local eCNC_FaceDetail_EyeSize = 8
  local eCNC_FaceDetail_EyeWide = 9
  local eCNC_FaceDetail_EyeBrow = 10
  local eCNC_FaceDetail_NostrilSize = 11
  local eCNC_FaceDetail_NoseBridgePos = 12
  local eCNC_FaceDetail_NoseGuard = 13
  local eCNC_FaceDetail_MouthSize = 14
  local eCNC_FaceDetail_PhiltrumLen = 15
  local eCNC_FaceDetail_MouthLipSize = 16
  local eCNC_BodyDetail_BoneOffsetWaist = 17
  local eCNC_BodyDetail_BoneOffsetNeck = 18
  local eCNC_BodyDetail_BoneOffsetUpperArm = 19
  local eCNC_BodyDetail_BoneOffsetForearm = 20
  local eCNC_BodyDetail_BoneOffsetUpperLeg = 21
  local eCNC_BodyDetail_BoneOffsetShank = 22
  local v = sys.variant()
  v:set(eCNC_ChaName, data.name)
  v:set(eCNC_Camp, data.camp)
  v:set(eCNC_Profession, data.profession)
  v:set(eCNC_Model, data.model)
  v:set(eCNC_Hair, data.hair)
  v:set(eCNC_Face, data.face)
  v:set(eCNC_Equip, data.equip)
  v:set(eCNC_Portrait, data.protrait)
  v:set(eCNC_FaceDetail_EyeSize, data.face_detail_eyesize)
  v:set(eCNC_FaceDetail_EyeWide, data.face_detail_eyewide)
  v:set(eCNC_FaceDetail_EyeBrow, data.face_detail_eyebrow)
  v:set(eCNC_FaceDetail_NostrilSize, data.face_detail_nostrilsize)
  v:set(eCNC_FaceDetail_NoseBridgePos, data.face_detail_nosebridgepos)
  v:set(eCNC_FaceDetail_NoseGuard, data.face_detail_noseguard)
  v:set(eCNC_FaceDetail_MouthSize, data.face_detail_mouthsize)
  v:set(eCNC_FaceDetail_PhiltrumLen, data.face_detail_philtrumlen)
  v:set(eCNC_FaceDetail_MouthLipSize, data.face_detail_mouthlipsize)
  v:set(eCNC_BodyDetail_BoneOffsetWaist, data.body_detail_waist)
  v:set(eCNC_BodyDetail_BoneOffsetNeck, data.body_detail_neck)
  v:set(eCNC_BodyDetail_BoneOffsetUpperArm, data.body_detail_upperArm)
  v:set(eCNC_BodyDetail_BoneOffsetForearm, data.body_detail_forearm)
  v:set(eCNC_BodyDetail_BoneOffsetUpperLeg, data.body_detail_upperLeg)
  v:set(eCNC_BodyDetail_BoneOffsetShank, data.body_detail_shank)
  return bo2.send_wrap(bo2wc_create_cha, v)
end
function cha_list()
  return bo2.send_wrap(bo2wc_list_cha)
end
function quest_list()
  return bo2.send_wrap(bo2wc_list_quest)
end
function show_quest(quest_id)
  local v = sys.variant()
  v:set("excel_id", quest_id)
  return bo2.send_wrap(bo2wc_show_quest, v)
end
function talk_npc(cha_id)
  local v = sys.variant()
  v:set("cha_id", cha_id)
  return bo2.send_wrap(bo2wc_talk_npc, v)
end
function gzs_enter(data)
  local v = sys.variant()
  v:set("cha_id", data.cha_id)
  v:set("gzs_id", data.gzs_id)
  return bo2.send_wrap(bo2wc_enter_gzs, v)
end
function gzs_out()
  local v = sys.variant()
  v:set(packet.key.ui_exitgame_type, 1)
  if sys.check(ui_cross_line) and sys.check(ui_cross_line.try_add_regist_time) then
    ui_cross_line.try_add_regist_time(v)
  end
  return bo2.send_variant(packet.eCTS_UI_PlayExitGame, v)
end
function login_out()
  local v = sys.variant()
  v:set(packet.key.ui_exitgame_type, 0)
  if sys.check(ui_cross_line) and sys.check(ui_cross_line.try_add_regist_time) then
    ui_cross_line.try_add_regist_time(v)
  end
  return bo2.send_variant(packet.eCTS_UI_PlayExitGame, v)
end
function gzs_list()
  return bo2.send_wrap(bo2wc_list_gzs)
end
function cha_delete(data)
  local v = sys.variant()
  v:set("cha_id", data)
  return bo2.send_wrap(bo2wc_delete_cha, v)
end
function connect(data)
  return bo2.send_wrap(bo2wc_connect, data)
end
function init()
  bo2_recv_wrap_signal = {}
  bo2.insert_on_recv_wrap("ui_packet.recv_wrap", "ui_packet.recv_wrap")
end
function talk_sel(kind, id)
  local v = sys.variant()
  v:set("kind", kind)
  v:set("id", id)
  return bo2.send_wrap(bo2wc_talk_sel, v)
end
function disconnet()
  return bo2.send_wrap(bo2wc_disconnect)
end
