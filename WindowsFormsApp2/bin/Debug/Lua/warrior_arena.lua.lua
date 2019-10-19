g_interface_data = {}
function on_run()
  w_main.visible = true
end
function on_esc_stk_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
end
function on_click_view_rank()
end
function on_self_enter()
end
function on_visible_career()
end
function on_visible_list()
  ui_widget.on_esc_stk_visible(w, vis)
end
function init_act(...)
  on_run()
  local act = arg[1].v_int
  init_act_data_by_index(act)
end
