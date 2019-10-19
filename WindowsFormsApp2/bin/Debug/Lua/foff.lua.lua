function on_f_of_f_init()
end
function on_im_f_of_f_visible()
end
function insert_friend_of_friend(v)
  ui.log("insert_friend_of_friend")
  local name = v:get(packet.key.sociality_playername).v_string
  local level = v:get(packet.key.sociality_playerlevel).v_int
  local careerId = v:get(packet.key.sociality_playercareer).v_int
  local sex = v:get(packet.key.sociality_playersex).v_int
  local camp = v:get(packet.key.sociality_playercamp).v_int
  local camp_text = L("")
  if camp == bo2.eCamp_Blade then
    camp_text = ui.get_text("phase|camp_blade")
  elseif camp == bo2.eCamp_Sword then
    camp_text = ui.get_text("phase|camp_sword")
  end
  insert_find(w_f_of_f_res, name, level, careerId, sex, camp_text)
end
function insert_f_of_f(view, name, level, career, sex, flag, camp)
  local item = view:item_append()
  item:load_style("$frame/im/foff.xml", "row_lable_f_of_f")
  if flag == false then
    item:search("button1").visible = false
    item:search("button2").visible = false
    return
  end
  item:search("name"):search("text").text = name
  item:search("sex"):search("text").text = sex
  item:search("career"):search("text").text = career
  item:search("level"):search("text").text = level
  item:search("camp"):search("text").text = camp
end
function on_f_of_f_sel(item, sel)
end
