function insert_tab(uri, name)
  local btn_uri = "$frame/org/guild_mng_new.xml"
  local btn_sty = "tab_btn"
  local page_uri = "$frame/org/" .. uri .. ".xml"
  local page_sty = name
  ui_widget.ui_tab.insert_suit(g_test, name, btn_uri, btn_sty, page_uri, page_sty)
  local btn = ui_widget.ui_tab.get_button(g_test, name)
  name = ui.get_text(sys.format("org|%s", name))
  btn.text = name
end
function on_init()
  insert_tab("guild_apply", "apply_mgr_main")
  insert_tab("guild_title", "title_mgr_main")
  insert_tab("guild_mgr", "hall_mgr_main")
  ui_widget.ui_tab.show_page(g_test, "apply_mgr_main", true)
end
function set_page_btn_enable(name, vis)
  local btn = ui_widget.ui_tab.get_button(g_test, name)
  btn.enable = vis
end
function on_visible(w, vis)
  if vis then
    local self = ui.guild_get_self()
    if self == nil then
      return
    end
    local excel = bo2.gv_guild_auth:find(self.guild_pos)
    if excel.appoint == 0 then
      set_page_btn_enable("title_mgr_main", false)
    end
    if excel.approve == 0 then
      set_page_btn_enable("apply_mgr_main", false)
    end
    if excel.hallrename == 0 then
      set_page_btn_enable("hall_mgr_main", false)
    end
    ui_org.ui_guild.update_hall()
    ui_org.ui_guild.update_apply()
    ui_org.ui_guild_title.update_apply()
    ui_widget.esc_stk_push(w)
  else
    ui_widget.esc_stk_pop(w)
  end
end
function update_guild_mng()
  ui_org.ui_guild.update_hall()
  ui_org.ui_guild.update_apply()
  ui_org.ui_guild_title.update_apply()
end
