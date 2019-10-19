function on_init(ctrl)
end
function on_delate_visible(w, vis)
  if vis == true then
    local ui_delate_info
    info = nil
    local ui_family_member
    member = nil
    local ui_family_member
    self = nil
    local pos_str
    info = ui.family_get_delate()
    self = ui.family_get_self()
    if info ~= nil then
      member = ui.family_find_member(info.id)
      pos_str = ui.get_text("org|family_pos" .. member.position)
    end
    if info ~= nil and member ~= nil and self ~= nil then
      local arg = sys.variant()
      arg:set("cha_name", member.name)
      arg:set("pos_name", pos_str)
      g_delate_info.text = sys.mtf_merge(arg, ui.get_text("org|pos_info"))
      g_delate_info.color = ui.make_color("FFFFFF")
      local dst = ui.filter_text(info.info)
      g_delate_text.text = dst
      local time = info.time
      local day = math.floor(time / 86400)
      local hour = math.floor((time - day * 86400) / 3600)
      arg:clear()
      arg:set("vote_day", day)
      arg:set("vote_hour", hour)
      arg:set("vote_num", info.vote)
      arg:set("vote_req", info.req)
      g_delate_result.text = sys.mtf_merge(arg, ui.get_text("org|result_info"))
      if info.vote < info.req then
        g_delate_result.color = ui.make_color("FF0000")
      else
        g_delate_result.color = ui.make_color("00FF00")
      end
      g_delate_text.enable = false
      g_begin_btn.enable = false
      if self.id == member.id or self.position == 4 then
        g_begin_btn.visible = true
        g_stop_btn_visible = true
        g_agree_btn.visible = false
        g_disagree_btn.visible = false
        g_stop_btn.enable = true
      else
        g_begin_btn.visible = false
        g_stop_btn.visible = false
        g_agree_btn.visible = true
        g_disagree_btn.visible = true
        g_stop_btn.enable = false
      end
    else
      g_delate_info.text = ui.get_text("org|delate_null")
      g_delate_info.color = ui.make_color("FF0000")
      g_delate_result.text = L("")
      g_delate_text.text = L("")
      g_begin_btn.visible = true
      g_stop_btn_visible = true
      g_agree_btn.visible = false
      g_disagree_btn.visible = false
      g_stop_btn.enable = false
      if self ~= nil and self.position == 3 then
        g_begin_btn.enable = true
        g_delate_text.enable = true
        g_delate_text.focus = true
      else
        g_begin_btn.enable = false
        g_delate_text.enable = false
        g_delate_text.focus = false
      end
    end
  end
end
function on_delate_begin(ctrl)
  local msg = {
    callback = on_delate_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui.get_text("org|delate_msg")
  ui_tool.show_msg(msg)
end
function on_delate_stop(ctrl)
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_Family_StopDelate, v)
  w_delate_main.visible = false
end
function on_delate_close(ctrl)
  w_delate_main.visible = false
end
function on_delate_agree(ctrl)
  local v = sys.variant()
  v:set(packet.key.org_acceptrequest, 0)
  bo2.send_variant(packet.eCTS_Family_DelateVote, v)
  w_delate_main.visible = false
end
function on_delate_disagree(ctrl)
  local v = sys.variant()
  v:set(packet.key.org_acceptrequest, 1)
  bo2.send_variant(packet.eCTS_Family_DelateVote, v)
  w_delate_main.visible = false
end
function on_delate_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local v = sys.variant()
    v:set(packet.key.org_vartext, g_delate_text.text)
    bo2.send_variant(packet.eCTS_Family_BeginDelate, v)
    ui.log(111)
    w_delate_main.visible = false
  end
end
