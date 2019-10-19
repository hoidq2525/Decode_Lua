local cur_frienditem
function get_cur_frienditem()
  return cur_frienditem
end
function show_im_tip(show, owner, name)
  if owner == nil then
    return
  end
  if show == false then
    w_im_tip_timer.suspended = false
    return
  else
    w_im_tip_timer.suspended = true
  end
  w_tip.x = owner.abs_area.p1.x
  w_tip.y = owner.abs_area.p1.y
  w_tip.visible = true
  local dis = 10
  local length = w_tip.parent.size.x
  local width = w_tip.parent.size.y
  local point = ui.point(owner.abs_area.p2.x + w_tip.size.x / 2, owner.abs_area.p2.y + w_tip.size.y / 2)
  if point.x <= length / 2 and point.y <= width / 2 then
    w_tip.x = w_tip.x + owner.dx
  elseif point.x > length / 2 and point.y <= width / 2 then
    w_tip.x = w_tip.x - w_tip.dx - dis
  elseif point.x <= length / 2 and point.y > width / 2 then
    w_tip.x = w_tip.x + owner.dx
    w_tip.y = w_tip.y - w_tip.dy + owner.dy
  elseif point.x > length / 2 and point.y > width / 2 then
    w_tip.x = w_tip.x - w_tip.dx - dis
    w_tip.y = w_tip.y - w_tip.dy + owner.dy
  end
  w_tip:search("name").text = name
  w_tip:search("touxiang").image = "$image/im/relations/temp.png|0,0,28,26"
  local name_list
  if owner.svar.is_senior then
    name_list = senior_name_list
  else
    name_list = friend_name_list
  end
  local friend_item = name_list[name]
  cur_frienditem = friend_item
  if friend_item == nil then
    ui.log("im tip friend_item is nil")
    w_tip:search("level").text = bo2.player:get_atb(bo2.eAtb_Level)
    do
      local pro_excel = bo2.gv_profession_list:find(bo2.player:get_atb(bo2.eAtb_Cha_Profession))
      if pro_excel ~= nil then
        w_tip:search("career").text = pro_excel.name
      end
      w_tip:search("relation").text = ""
    end
  else
    w_tip:search("level").text = friend_item.atb[bo2.eAtb_Level]
    local pro_excel = bo2.gv_profession_list:find(friend_item.atb[bo2.eAtb_Cha_Profession])
    if pro_excel ~= nil then
      w_tip:search("career").text = pro_excel.name
    else
      w_tip:search("career").visible = false
    end
    local group_id = friend_item.groupid
    w_tip:search("touxiang").image = friend_get_portrait(friend_item)
    local pExcelData
    if sys.is_type(friend_item.flag, "table") then
      local iTitleIdx = friend_item.flag[bo2.ePlayerFlagInt32_UsingTitle]
      pExcelData = bo2.gv_title_list:find(iTitleIdx)
    end
    if pExcelData then
      if pExcelData._sp_flag == 0 then
        w_tip:search("designation").text = pExcelData._name
      else
        w_tip:search("designation").text = friend_item.title
      end
    else
      w_tip:search("designation").text = ui.get_text("im|title_none")
    end
  end
  local table_index = 1
  if friend_item.thetype == bo2.TWR_Type_Engagement then
    table_index = 2
  elseif friend_item.thetype == bo2.TWR_Type_Couple then
    table_index = 3
  elseif friend_item.thetype == bo2.TWR_Type_Sworn then
    table_index = 4
  end
  local pExcelData = bo2.gv_define_sociality:find(table_index)
  local max_friend = 0
  if pExcelData then
    max_friend = pExcelData.value.v_int
  end
  updata_progress(w_tip:search("depth"), friend_item.depth, max_friend)
  set_samll_icon(w_tip:search("small_icon"), owner)
  w_tip:search("signature").text = ""
  if sns_info_list[name] then
    w_tip:search("signature").text = sns_info_list[name].signature
  end
end
function on_im_tip_mouse(btn, msg, pos, wheel)
  if msg == ui.mouse_inner then
    w_im_tip_timer.suspended = true
  end
  if msg == ui.mouse_outer then
    w_im_tip_timer.suspended = false
  end
end
function on_im_tip_disappear(timer)
  w_tip.visible = false
  timer.suspended = true
end
