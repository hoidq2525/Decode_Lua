function on_init(ctrl)
end
function on_salary_visible(w, vis)
  if bo2.is_in_guild() == sys.wstring(0) then
    ui_chat.show_ui_text_id(70251)
    ui_guild_mod.ui_salary.w_salary_main.visible = false
  end
  if vis == true then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    local ui_guild_member
    self = ui.guild_get_self()
    if self ~= nil then
      local arg = sys.variant()
      arg:set("int_data", self.welfare)
      g_welfare_label.text = sys.mtf_merge(arg, ui.get_text("guild|welfare_text"))
      arg:clear()
      arg:set("int_data", self.last_con)
      g_lastcon_label.text = sys.mtf_merge(arg, ui.get_text("guild|lastcon_text"))
      arg:clear()
      arg:set("int_data", self.salary)
      g_salary_box.mtf = sys.mtf_merge(arg, ui.get_text("guild|salary_text"))
      g_receive_salary_btn.enable = true
      if self.salary == 0 then
        g_receive_salary_btn.enable = false
      end
    end
  else
    ui_widget.esc_stk_pop(w)
  end
end
function on_receive_salary(ctrl)
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_Guild_GetSalary, v)
  w_salary_main.visible = false
end
function on_cancel_salary(ctrl)
  w_salary_main.visible = false
end
