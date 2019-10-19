local item_file = "$frame/guild/guild_hall.xml"
local item_style = "guild_hall_item"
local d_hall_maxmember = bo2.gv_define_org:find(9).value
function on_guild_mgr_visible(w, vis)
  if vis == true then
    w:move_to_head()
  elseif g_hall_list.item_sel ~= nil then
    g_hall_list.item_sel:search("fig_highlight_sel").visible = false
    g_hall_list.item_sel.selected = false
  end
end
function on_hall_item_select(ctrl, vis)
  ui_guild_mod.ui_guild.update_highlight(ctrl)
  g_hall_list.item_sel:search("fig_highlight_sel").visible = vis
  local self = ui.guild_get_self()
  local guild_auth = bo2.gv_guild_auth:find(self.guild_pos)
  if guild_auth.hallrename == 1 then
    g_hall_rename.enable = true
  end
end
function updata_hall()
  if bo2.is_in_guild() == sys.wstring(0) then
    w_guild_hall_mgr.visible = false
  end
  if g_hall_list.item_sel ~= nil then
    g_hall_list.item_sel:search("fig_highlight_sel").visible = false
    g_hall_list.item_sel.selected = false
  end
  g_hall_rename.enable = false
  g_hall_list:item_clear()
  for i = 0, ui.guild_hall_size() - 1 do
    local pHall = ui.guild_get_hall(i)
    local item = g_hall_list:item_append()
    item:load_style(item_file, item_style)
    item:search("id").text = pHall.id
    item:search("hall_name").text = pHall.name
    item:search("weekcon").text = pHall.weekcon
    local arg_v = sys.variant()
    arg_v:set("member_num", pHall.count)
    arg_v:set("max_num", d_hall_maxmember)
    item:search("number").text = sys.mtf_merge(arg_v, ui.get_text("guild|hall_member_maxnum"))
    local leader = ui.guild_find_member(pHall.leader)
    if leader ~= nil then
      item:search("leader").text = leader.name
    else
      item:search("leader").text = "--"
    end
  end
  local arg = sys.variant()
  arg:set("max_num", ui.guild_hall_size())
  g_hall_num.text = sys.mtf_merge(arg, ui.get_text("guild|guild_maxhall"))
  ui_guild_mod.ui_manage.gx_text_hall.text = sys.mtf_merge(arg, ui.get_text("guild|guild_hall_manage_tip"))
end
function on_hall_rename(ctrl)
  local on_hall_rename_msg = function(msg)
    if msg == nil then
      return
    end
    if msg.result == 1 then
      local id = g_hall_list.item_sel:search("id")
      local v = sys.variant()
      local pHall = ui.guild_find_hall(id.text)
      if pHall ~= nil then
        v:set(packet.key.guild_hallid, pHall.id)
        v:set(packet.key.guild_hallname, msg.input)
        bo2.send_variant(packet.eCTS_Guild_HallRename, v)
      end
    end
  end
  local msg = {
    callback = on_hall_rename_msg,
    btn_confirm = true,
    btn_cancel = true,
    modal = true,
    limit = 12
  }
  msg.text = ui.get_text("guild|hall_rename")
  msg.input = L("")
  ui_widget.ui_msg_box.show_common(msg)
end
function on_close_hall(ctrl)
  w_guild_hall_mgr.visible = false
end
