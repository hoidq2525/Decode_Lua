if rawget(_M, "g_jade_datas") == nil then
  g_jade_datas = {}
end
function on_jade(cmd, data)
  local c = data:get(packet.key.rmb_amount).v_int
  for n, v in pairs(g_jade_datas) do
    v.jade.text = c
  end
end
function on_bdjade(obj, ft, idx)
  local c = obj:get_flag_int32(idx)
  for n, v in pairs(g_jade_datas) do
    v.bdjade.text = c
  end
end
function on_score(obj, ft, idx)
  local c = obj:get_flag_int32(idx)
  for n, v in pairs(g_jade_datas) do
    v.score.text = c
  end
end
function on_star(obj, ft, idx)
  local c = obj:get_flag_int32(idx)
  for n, v in pairs(g_jade_datas) do
    v.star.text = c
  end
end
function on_view_close(w)
  g_jade_datas[w] = nil
end
function on_view_init(w)
  local d = {
    top = w,
    jade = w:search("jade"),
    bdjade = w:search("bdjade"),
    score = w:search("score"),
    star = w:search("star")
  }
  g_jade_datas[w] = d
  local player = bo2.player
  if player ~= nil then
    d.jade.text = player:get_flag_int32(bo2.eFlagInt32_CirculatedJade)
    d.bdjade.text = player:get_flag_int32(bo2.eFlagInt32_BoundedJade)
  end
end
function on_self_enter(obj, msg)
  obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.eFlagInt32_BoundedJade, on_bdjade, "ui_supermarket.ui_account.on_bdjade")
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, on_self_enter, "ui_supermarket.ui_account.on_self_enter")
ui_packet.game_recv_signal_insert(packet.eSTC_SupermarketRMB, on_jade, "ui_supermarket.ui_rmb")
