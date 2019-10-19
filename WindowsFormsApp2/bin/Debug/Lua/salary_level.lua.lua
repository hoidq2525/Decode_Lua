function on_init(ctrl)
end
function on_salary_level_visible(w, vis)
  if bo2.is_in_guild() == sys.wstring(0) then
    ui_chat.show_ui_text_id(70251)
    ui_guild_mod.ui_salary_level.w_salary_level_main.visible = false
  end
  if vis == true then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    local level = ui.guild_next_salary_level()
    g_stop_radio.check = false
    g_low_radio.check = false
    g_normal_radio.check = false
    g_high_radio.check = false
    if level == 1 then
      g_stop_radio.check = true
    elseif level == 2 then
      g_low_radio.check = true
    elseif level == 3 then
      g_normal_radio.check = true
    elseif level == 4 then
      g_high_radio.check = true
    end
    g_level_confirm_btn.enable = false
    local ui_guild_member
    self = ui.guild_get_self()
    if self ~= nil and self.guild_pos == bo2.Guild_Leader then
      g_level_confirm_btn.enable = true
    end
  else
    ui_widget.esc_stk_pop(w)
  end
end
function on_salary_level_confirm(ctrl)
  local next
  if g_stop_radio.check == true then
    next = 1
  end
  if g_low_radio.check == true then
    next = 2
  end
  if g_normal_radio.check == true then
    next = 3
  end
  if g_high_radio.check == true then
    next = 4
  end
  if next ~= nil then
    local v = sys.variant()
    v:set(packet.key.guild_next, next)
    bo2.send_variant(packet.eCTS_Guild_SalaryLevel, v)
  end
  w_salary_level_main.visible = false
end
function on_salary_level_cancel(ctrl)
  w_salary_level_main.visible = false
end
