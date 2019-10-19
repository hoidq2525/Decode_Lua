local cur_time = 20
local guess_players = {}
function on_watch_guess_init()
  cur_time = 20
  guess_players[0] = gx_watch_guess_left
  guess_players[1] = gx_watch_guess_right
end
function on_watch_guess_timer()
  if cur_time == 0 then
    gx_watch_guess.visible = false
    return
  end
  cur_time = cur_time - 1
  gx_watch_guess_time.text = cur_time
end
function on_watch_guess_visible(win, vis)
  if vis == false then
    cur_time = 0
  else
    win:move_to_head()
  end
  gx_watch_guess_timer.suspended = not vis
end
function watch_guess_click(panel, msg)
  if msg == ui.mouse_lbutton_down then
    local arg = sys.variant()
    arg:set("cha_name", panel.parent:search("player_name").text)
    local msg = {
      text = sys.mtf_merge(arg, ui.get_text("match|watch_guess_sure")),
      modal = true,
      btn_confirm = 1,
      btn_cancel = 1,
      timeout = cur_time * 1000,
      callback = function(data)
        if data.result == 1 then
          local v = sys.variant()
          v:set(packet.key.itemdata_idx, panel.parent.svar)
          bo2.send_variant(packet.eCTS_DooAltar_WatchGuessAsk, v)
          gx_watch_guess.visible = false
        end
      end
    }
    ui_widget.ui_msg_box.show_common(msg)
  end
end
function get_career_idx(val)
  local pro = bo2.gv_profession_list:find(val)
  if pro == nil then
    return -1
  end
  return pro.career - 1
end
function set_career_color(pic, career_idx)
  local pro = bo2.gv_profession_list:find(career_idx)
  if pro ~= nil then
    ui_portrait.make_career_color(pic, pro)
  end
end
function packet_WatchGuess(data)
  local players = data:get(packet.key.arena_players)
  for i = 0, players.size - 1 do
    local var = players:get(i)
    local side = var:get(packet.key.itemdata_idx).v_int
    local item = guess_players[side]
    item.svar = side
    item:search("player_name").text = var:get(packet.key.cha_name).v_string
    item:search("level").text = var:get(packet.key.cha_level).v_int
    local portrait = var:get(packet.key.cha_portrait).v_int
    local por_list = bo2.gv_portrait:find(portrait)
    if por_list ~= nil then
      item:search("portrait").image = sys.format("$icon/portrait/%s.png", por_list.icon)
    end
    local career = var:get(packet.key.player_profession).v_int
    local career_panel = item:search("job")
    local career_idx = get_career_idx(career)
    if career_idx >= 0 then
      career_panel.image = sys.format("$image/personal/32x32/%d.png|0,0,27,30", career_idx + 1)
      set_career_color(career_panel, career)
      career_panel.svar = career
    else
      career_panel.visible = false
    end
    item:search("side").image = sys.format("$image/mtf/medal/00%d.png", side + 2)
  end
  cur_time = data:get(packet.key.itemdata_val).v_int
  gx_watch_guess.visible = true
end
