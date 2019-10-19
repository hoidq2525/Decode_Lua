function ShowSelectWindow(data)
  local status = {
    id = data:get(packet.key.cmn_id).v_string,
    mode = data:get(packet.key.arena_mode).v_int,
    sel_cnt = 0,
    item = {}
  }
  local function onChecked(ctrl, c)
    if c then
      status.sel_cnt = status.sel_cnt + 1
    else
      status.sel_cnt = status.sel_cnt - 1
    end
    if status.sel_cnt > status.mode then
      ui_widget.ui_msg_box.show_common({
        text = ui.get_text("dooaltar|select_err"),
        modal = true,
        btn_confirm = true,
        btn_cancel = false,
        callback = function()
          ctrl.check = false
        end
      })
    end
  end
  gx_select_list:item_clear()
  members = data:get(packet.key.group_all_members)
  for i = 0, members.size - 1 do
    item = gx_select_list:item_append()
    item:load_style("$frame/dooaltar/select.xml", "player_item")
    item:search("button"):insert_on_check(onChecked)
    member = members:fetch_v(i)
    item:search("button").text = member:get(packet.key.cha_name).v_string
    status.item[item] = member:get(packet.key.cha_onlyid).v_string
  end
  local function onClicked()
    local v = sys.variant()
    for item, id in pairs(status.item) do
      if item:search("button").check then
        v:push_back(id)
      end
    end
    local v2 = sys.variant()
    v2:set(packet.key.cmn_id, status.id)
    v2:set(packet.key.group_all_members, v)
    bo2.send_variant(packet.eCTS_DooAltar_TeamSelect, v2)
    gx_select_window.visible = false
  end
  gx_select_ok:insert_on_click(onClicked, "select_ok")
  gx_select_window.visible = true
end
