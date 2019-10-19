local cur_land_id = 0
function on_item_sel(item, sel)
  update_highlight(item)
  item:search("fig_highlight_sel").visible = item.selected or item.inner_hover
  if sel == false then
    return
  end
  local line = bo2.gv_guild_defense_build:find(item.svar.id)
  local need_process = line.build_time
  local day = math.modf(need_process / 86400)
  need_process = need_process % 86400
  local hour = math.modf(need_process / 3600)
  need_process = need_process % 3600
  local minute = math.modf(need_process / 60)
  local item_desc = ""
  local resources = line.resources
  gx_btn_build.enable = true
  if resources.size ~= 0 and resources.size ~= 1 then
    for i = 0, resources.size - 1, 2 do
      local res_id = resources[i]
      local count = resources[i + 1]
      local has_count = ui.item_get_count(res_id, true)
      if count > has_count then
        gx_btn_build.enable = false
      end
      local desc = sys.format([[
<scii:%s>  %s/%s
              ]], res_id, has_count, count)
      item_desc = item_desc .. desc
    end
  end
  gx_defense_build_des.mtf = sys.format(ui.get_text("guild|defense_build_desc"), line.desc, day, hour, minute, item_desc)
end
function on_build_click(btn)
  if gx_build_list.item_sel == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.cmn_id, cur_land_id)
  v:set(packet.key.cmn_type, gx_build_list.item_sel.svar.id)
  bo2.send_variant(packet.eCTS_UI_GuildDefenseBuild, v)
  gx_defense_build_win.visible = false
end
function on_win_close()
  gx_defense_build_win.visible = false
end
function update_highlight(item)
  item:search("fig_highlight").visible = item.selected or item.inner_hover
end
function on_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    update_highlight(item)
  end
end
function on_defense_build_init()
end
function open_win(cmd, data)
  gx_build_list:item_clear()
  cur_land_id = data:get(packet.key.cmn_id).v_int
  local line = bo2.gv_guild_defense_build_land:find(cur_land_id)
  if line == nil then
    return
  end
  local build_type = tostring(bo2.gv_define_org:find(line.type).value)
  for id in string.gmatch(build_type, "(%d)") do
    local build_line = bo2.gv_guild_defense_build:find(id)
    local item = gx_build_list:item_append(0)
    item:load_style("$frame/guild/guild_defense_build.xml", "list_item")
    item:search("lb_text").text = build_line.name
    item.svar.id = build_line.id
  end
  gx_build_list:item_get(0).selected = true
  gx_defense_build_win.visible = true
end
local reg = ui_packet.recv_wrap_signal_insert
local sig = "ui_guild_mod.ui_guild_defense_build"
reg(packet.eSTC_Guild_OpenDefenseWin, open_win, sig)
