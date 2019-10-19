function show_life_info_ui(vis)
  g_life_info.visible = vis
end
function set_life_info(self_life, teammate_life)
  wlt_self_life.text = self_life
  wlt_teammate_life.text = teammate_life
end
function set_level(cur_level)
  wlt_cur_level.text = cur_level
end
function set_target(target)
  wlt_target.text = target
end
function on_life_ui_init(ctrl)
  g_life_info.visible = false
end
