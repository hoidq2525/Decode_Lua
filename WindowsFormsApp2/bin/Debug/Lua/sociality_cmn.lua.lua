function build_time_text(time)
  local left_part = time % 1000
  local time_sec = (time - left_part) / 1000
  local s = time_sec % 60
  time_sec = (time_sec - s) / 60
  if tonumber(s) < 10 then
    s = "0" .. tostring(s)
  end
  local m = time_sec % 60
  time_sec = (time_sec - m) / 60
  if tonumber(m) < 10 then
    m = "0" .. tostring(m)
  end
  local h = tonumber(time_sec)
  local text
  if h == 0 then
    text = m .. ":" .. s
  else
    if tonumber(h) < 10 then
      h = "0" .. tostring(h)
    end
    text = h .. ":" .. m .. ":" .. s
  end
  return text
end
function set_timer_text(main_ctrl)
  local pro_var = main_ctrl.var
  local end_time = pro_var:get("end_tick").v_int
  local cur_time = sys.tick()
  local time = sys.dtick(end_time, cur_time)
  if time > 0 then
    local plus_text = pro_var:get("plus_text").v_string
    local time_text = plus_text .. build_time_text(time)
    main_ctrl:search(L("timer_lb_name")).text = time_text
  else
    main_ctrl:find_plugin("timer").suspended = true
  end
end
function init_timer(main_ctrl, time, plus_text)
  local time_frame = time.v_int
  local cur_tick = sys.tick()
  local stop_tick = cur_tick + time_frame / 25 * 1000
  local pro_var = main_ctrl.var
  pro_var:set("end_tick", stop_tick)
  pro_var:set("plus_text", plus_text)
  main_ctrl:find_plugin("timer").suspended = false
  set_timer_text(main_ctrl)
end
function end_timer(main_ctrl)
  main_ctrl:find_plugin("timer").suspended = true
end
relation_text = {}
relation_text[tonumber(bo2.TWR_Type_Friend)] = "sociality|relation_type_friend"
relation_text[tonumber(bo2.TWR_Type_Engagement)] = "sociality|relation_type_engagement"
relation_text[tonumber(bo2.TWR_Type_Couple)] = "sociality|relation_type_marry"
relation_text[tonumber(bo2.TWR_Type_Sworn)] = "sociality|relation_type_sworn"
relation_text[tonumber(bo2.TWR_Type_MasterAndApp)] = "sociality|relation_type_ma"
function get_relation_name(relation_type)
  local text_idx = relation_text[tonumber(relation_type)]
  local relation_name = ui.get_text(text_idx)
  return relation_name
end
function send_make_friend_with_cha(name)
  local v = sys.variant()
  v:set(packet.key.sociality_tarplayername, name)
  v:set(packet.key.sociality_twrelationchgtype, 0)
  bo2.send_variant(packet.eCTS_Sociality_ChgTWRelation, v)
end
function send_forbid_cha(name)
  local v = sys.variant()
  v:set(packet.key.sociality_tarplayername, name)
  bo2.send_variant(packet.eCTS_Sociality_AddExclude, v)
end
function send_unforbid_cha(name)
  local v = sys.variant()
  v:set(packet.key.sociality_tarplayername, name)
  bo2.send_variant(packet.eCTS_Sociality_DelExclude, v)
end
