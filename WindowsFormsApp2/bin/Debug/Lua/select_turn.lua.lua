local g_players = {}
local g_select_btns = {}
local function Reset()
  g_players = {
    [0] = {},
    [1] = {}
  }
end
Reset()
local function save_player_data(name, side, show)
  table.insert(g_players[side], {name = name, show = show})
end
local function show_selectturn_window(side)
  local datas = g_players[side]
  g_select_btns = {}
  for i, v in ipairs(datas) do
    local item = gx_selectturn_list:item_append()
    item:load_style("$frame/match/select_turn.xml", "select_btn")
    local btn = item:search("player_name")
    if v.show then
      btn.text = v.name
      btn.enable = false
    else
      btn.text = sys.format(ui.get_text("match|turn_fmt"), i)
      btn.enable = true
    end
    g_select_btns[btn] = i - 1
  end
  gx_selectturn_window.visible = true
  gx_status_window.visible = false
end
selectturn = {
  on_member = function(var)
    local side = var:get(packet.key.itemdata_idx).v_int
    local turn = var:get(packet.key.itemdata_val).v_int
    local name = var:get(packet.key.cha_name).v_string
    save_player_data(name, side, var:has(packet.key.cmn_state))
  end,
  on_select = function(var)
    local show = var:get(packet.key.cmn_rst).v_int ~= 0
    if show then
      gx_selectturn_list:item_clear()
      local side = var:get(packet.key.itemdata_idx).v_int
      show_selectturn_window(side)
    end
  end,
  on_set_turn = function(var)
    if not gx_selectturn_window.visible then
      return
    end
    local side = var:get(packet.key.itemdata_idx).v_int
    local turn = var:get(packet.key.itemdata_val).v_int
    local name = var:get(packet.key.cha_name).v_string
    local item = gx_selectturn_list:item_get(turn)
    local my_side = g_members_var[bo2.player.name]:get(packet.key.itemdata_idx).v_int
    if my_side ~= side then
      return
    end
    if item and var:has(packet.key.cmn_state) then
      for i = 0, gx_selectturn_list.item_count do
        local sel_item = gx_selectturn_list:item_get(i)
        if sel_item ~= nil then
          local btn = sel_item:search("player_name")
          if btn ~= nil and btn.text == name then
            btn.text = sys.format(ui.get_text("match|turn_fmt"), i + 1)
            btn.enable = true
            break
          end
        end
      end
      item:search("player_name").text = name
      item:search("player_name").enable = false
    end
  end,
  on_fight = function(var)
    gx_selectturn_window.visible = false
  end,
  on_enter = function(var)
    Reset()
  end
}
function on_click_select_turn(btn)
  local v = sys.variant()
  v:set(packet.key.itemdata_idx, g_select_btns[btn])
  bo2.send_variant(packet.eCTS_UI_ChgMyTurn, v)
end
