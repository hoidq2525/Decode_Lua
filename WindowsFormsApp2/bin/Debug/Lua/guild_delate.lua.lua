local input_mun = 0
local inputmax = 1
function on_init(ctrl)
  ui.insert_on_guild_delate_refresh("ui_guild_mod.ui_delate.on_guild_delate_refresh", "on_guild_delate_refresh")
end
function on_guild_delate_refresh()
  if bo2.is_in_guild() == sys.wstring(0) then
    w_delate_main.visible = false
  end
  local info = ui.guild_get_delate()
  local self = ui.guild_get_self()
  local pos_str = ""
  if info ~= nil then
    pos_str = ui.get_text("guild|guild_pos" .. info.guild_pos)
  end
  if info ~= nil and self ~= nil then
    local arg = sys.variant()
    arg:set("cha_name", info.name)
    arg:set("pos_name", pos_str)
    g_delate_info.text = sys.mtf_merge(arg, ui.get_text("guild|pos_info"))
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
    g_delate_result.text = sys.mtf_merge(arg, ui.get_text("guild|result_info"))
    g_delate_vote.text = sys.mtf_merge(arg, ui.get_text("guild|vote_info"))
    g_delate_result.parent.visible = true
    g_delate_vote.parent.visible = true
    if info.vote < info.req then
      g_delate_result.color = ui.make_color("FF0000")
      g_delate_vote.color = ui.make_color("FF0000")
    else
      g_delate_result.color = ui.make_color("00FF00")
      g_delate_vote.color = ui.make_color("00FF00")
    end
    g_delate_text.enable = false
    g_begin_btn.enable = false
    if self.id == info.id or self.guild_pos == bo2.Guild_Leader then
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
    g_delate_info.text = ui.get_text("guild|delate_null")
    g_delate_info.color = ui.make_color("FF0000")
    local arg = sys.variant()
    arg:set("vote_day", 0)
    arg:set("vote_hour", 0)
    arg:set("vote_num", 0)
    arg:set("vote_req", 0)
    g_delate_result.text = sys.mtf_merge(arg, ui.get_text("guild|result_info"))
    g_delate_vote.text = sys.mtf_merge(arg, ui.get_text("guild|vote_info"))
    g_delate_result.parent.visible = false
    g_delate_vote.parent.visible = false
    g_delate_text.text = L("")
    g_begin_btn.visible = true
    g_stop_btn_visible = true
    g_agree_btn.visible = false
    g_disagree_btn.visible = false
    g_stop_btn.enable = false
    if self ~= nil and self.guild_pos == bo2.Guild_Assist then
      g_begin_btn.enable = true
      g_delate_text.enable = true
      g_delate_text.focus = true
    else
      g_stop_btn.visible = true
      g_stop_btn.enable = false
      g_begin_btn.enable = false
      g_delate_text.enable = false
      g_delate_text.focus = false
    end
  end
end
function on_delate_visible(w, vis)
  if vis == true then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    on_guild_delate_refresh()
  else
    ui_widget.esc_stk_pop(w)
  end
end
function on_delate_begin(ctrl)
  local msg = {
    callback = on_delate_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true
  }
  msg.text = ui.get_text("guild|delate_msg")
  ui_widget.ui_msg_box.show_common(msg)
end
function on_delate_stop(ctrl)
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_Guild_StopDelate, v)
  w_delate_main.visible = false
end
function on_delate_close(ctrl)
  w_delate_main.visible = false
end
function on_delate_agree(ctrl)
  local v = sys.variant()
  v:set(packet.key.org_acceptrequest, 0)
  bo2.send_variant(packet.eCTS_Guild_DelateVote, v)
  w_delate_main.visible = false
end
function on_delate_disagree(ctrl)
  local v = sys.variant()
  v:set(packet.key.org_acceptrequest, 1)
  bo2.send_variant(packet.eCTS_Guild_DelateVote, v)
  w_delate_main.visible = false
end
function on_delate_msg(msg)
  if msg == nil then
    return
  end
  if msg.result == 1 then
    local v = sys.variant()
    v:set(packet.key.org_vartext, g_delate_text.text)
    bo2.send_variant(packet.eCTS_Guild_BeginDelate, v)
    w_delate_main.visible = false
  end
end
function on_input_keydown(ctrl, key, keyflag)
  if key == ui.VK_RETURN then
    inputtext = g_delate_text.text
  end
end
function on_input_char(ctrl, ch)
  if ch == ui.VK_RETURN then
    local count = sys.findwchar(inputtext, L("\r"))
    input_mun = count + 1
    if input_mun >= inputmax then
      g_delate_text:remove_on_widget_mouse(ch)
      g_delate_text.text = inputtext
      return
    end
  end
end
