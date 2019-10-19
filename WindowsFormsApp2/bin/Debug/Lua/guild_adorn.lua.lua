local select_adorn, select, mouse_item
local adorn_n = 0
function get_visible()
  local w = ui.find_control("$frame:guild_adorn")
  return w.visible
end
function on_init(ctrl)
  w_build_list:item_clear()
  select = nil
  select_adorn = nil
  g_install_btn.enable = false
  ui.insert_on_guild_adorn_refresh("ui_guild_mod.ui_guild_adorn.updata_adorn", "ui_guild_adorn")
  create_adorn_build_list()
end
function create_adorn_build_list()
  for i = 0, bo2.gv_adorn_build.size - 1 do
    local adorn_build_excel = bo2.gv_adorn_build:get(i)
    if adorn_build_excel ~= nil then
      local item = w_build_list:item_append()
      item:load_style(L("$frame/guild/guild_adorn.xml"), L("adorn_guild_item"))
      item.svar.build_id = adorn_build_excel.type
      local vis = item.selected or item.inner_hover
      local fig = item:search("fig_highlight")
      fig.visible = vis
      local build_name = item:search("build_name")
      build_name.text = adorn_build_excel.name
      local adorn_name = item:search("adorn_name")
      adorn_name.text = ui.get_text("guild|null")
    end
  end
end
function findadorn(build_type)
  for i = 0, ui.guild_adorn_size - 1 do
    local ui_guild_adorn
    adorn = ui.guild_get_adorn(i)
    if adorn ~= nil and adorn.buildtype == build_type then
      return adorn
    end
  end
  return nil
end
function get_adorn_item(id)
  for n = 0, w_adorn_list.item_count - 1 do
    local item = w_adorn_list:item_get(n)
    if item.sver.adorn_id == tostring(id) then
      return item
    end
  end
  return nil
end
function get_adorn_excel_item(excelid)
  adorn_n = 0
  for n = 0, w_adorn_list.item_count - 1 do
    local item = w_adorn_list:item_get(n)
    if tostring(item.svar.excel_id) == tostring(excelid) then
      adorn_n = n
    end
  end
  return adorn_n
end
function getitem(type)
  for n = 0, w_build_list.item_count - 1 do
    local item = w_build_list:item_get(n)
    if item.svar.build_id == type then
      return item
    end
  end
  return nil
end
function updata_adorn()
  for n = 0, w_build_list.item_count - 1 do
    local item = w_build_list:item_get(n)
    local adorn_name = item:search("adorn_name")
    adorn_name.text = ui.get_text("guild|null")
    item.svar.adorn_excel_id = 0
  end
  if w_adorn_list.item_sel ~= nil then
    w_adorn_list.item_sel.selected = false
  end
  w_adorn_list:clear_selection()
  select_adorn = nil
  w_adorn_list:item_clear()
  g_backout_btn.enable = false
  g_install_adorn_btn.enable = false
  g_del_adorn_btn.enable = false
  for i = 0, ui.guild_adorn_size() - 1 do
    local ui_guild_adorn
    adorn = ui.guild_get_adorn(i)
    if adorn ~= nil then
      local adorn_excel = bo2.gv_adorn:find(adorn.excelid)
      if adorn_excel ~= nil then
        if adorn.buildtype ~= 0 then
          local build_item = getitem(adorn.buildtype)
          if build_item ~= nil then
            local adorn_name = build_item:search("adorn_name")
            adorn_name.text = adorn_excel.name
            build_item.svar.adorn_excel_id = adorn.excelid
            local vis = build_item.selected or build_item.inner_hover
            if vis == true and build_item.svar.adorn_excel_id ~= 0 then
              g_backout_btn.enable = true
            end
          end
        end
        local item
        if item == nil then
          local typeitem_index = get_adorn_excel_item(adorn.excelid)
          if typeitem_index ~= 0 then
            item = w_adorn_list:item_insert(typeitem_index)
          else
            item = w_adorn_list:item_append()
          end
          item:load_style(L("$frame/guild/adorn_mgr.xml"), L("adorn_item"))
          item.svar.excel_id = adorn.excelid
          item.svar.adorn_id = adorn.id
          item.svar.adorn_type = adorn_type
        end
        local adorn_name = item:search("adorn_name")
        adorn_name.text = adorn_excel.name
        local adorn_type_excel = bo2.gv_adorn_type:find(adorn_excel.adorn_type)
        local adorn_type_name = item:search("adorn_type_name")
        if adorn_type_excel ~= nil then
          adorn_type_name.text = adorn_type_excel.name
        else
          adorn_type_name.text = ui.get_text("guild|null")
        end
        local install = item:search("install")
        if tostring(adorn.buildtype) == tostring(0) then
          install.text = ui.get_text("guild|tip_cmn6")
        else
          install.text = ui.get_text("guild|tip_cmn7")
        end
        if select ~= nil then
          local adorn_build = bo2.gv_adorn_build:find(select.svar.build_id)
          if adorn_build.adorn_type ~= adorn_excel.adorn_type then
            adorn_name.color = ui.make_color("808080")
            adorn_type_name.color = ui.make_color("808080")
            install.color = ui.make_color("808080")
          else
            adorn_name.color = ui.make_color("FFFFFF")
            adorn_type_name.color = ui.make_color("FFFFFF")
            install.color = ui.make_color("FFFFFF")
          end
        end
        local vis = item.selected or item.inner_hover
        if vis == true then
          g_install_adorn_btn.enable = true
          g_del_adorn_btn.enable = true
        end
      end
    end
  end
end
function updata_adorn_list()
  for n = 0, w_adorn_list.item_count - 1 do
    local item = w_adorn_list:item_get(n)
    local ui_guild_adorn
    adorn = ui.guild_find_adorn(item.svar.adorn_id)
    if adorn ~= nil then
      local adorn_excel = bo2.gv_adorn:find(adorn.excelid)
      local adorn_name = item:search("adorn_name")
      local adorn_type_name = item:search("adorn_type_name")
      local install = item:search("install")
      adorn_name.color = ui.make_color("FFFFFF")
      adorn_type_name.color = ui.make_color("FFFFFF")
      install.color = ui.make_color("FFFFFF")
      item.visible = true
      if select ~= nil then
        local adorn_build = bo2.gv_adorn_build:find(select.svar.build_id)
        if adorn_build.adorn_type ~= adorn_excel.adorn_type then
          adorn_name.color = ui.make_color("808080")
          adorn_type_name.color = ui.make_color("808080")
          install.color = ui.make_color("808080")
          item.visible = g_show_check.check
        end
      end
    end
  end
end
function on_visible(w, vis)
  if bo2.is_in_guild() == sys.wstring(0) then
    ui_chat.show_ui_text_id(70251)
    ui_guild_mod.ui_guild_adorn.w_main.visible = false
  end
  if vis == true then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    updata_adorn()
    local guard_v = sys.variant()
    bo2.send_variant(packet.eCTS_Guild_GetAdornData, guard_v)
  else
    ui_widget.esc_stk_pop(w)
    w_adorn_mgr_main.visible = false
    if w_build_list.item_sel ~= nil then
      w_build_list.item_sel.selected = false
    end
    if select ~= nil then
      select:search("fig_highlight").visible = false
    end
    select = nil
    g_install_btn.enable = false
  end
end
function on_adorn_mgr_visible(w, vis)
  if vis == true then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
  else
    ui_widget.esc_stk_pop(w)
    if w_adorn_list.item_sel ~= nil then
      w_adorn_list.item_sel.selected = false
    end
    if select_adorn ~= nil then
      select_adorn:search("fig_highlight").visible = false
    end
    select_adorn = nil
    g_install_adorn_btn.enable = false
    g_del_adorn_btn.enable = false
  end
end
function on_item_sel(item, sel)
  if not sel then
    return
  end
  if select ~= nil then
    select:search("fig_highlight").visible = false
  end
  select = item
  select:search("fig_highlight").visible = true
  updata_adorn_list()
  g_backout_btn.enable = false
  if item.svar.adorn_excel_id ~= 0 then
    g_backout_btn.enable = true
  end
  g_install_btn.enable = true
end
function on_adorn_item_sel(item, sel)
  if not sel then
    return
  end
  if select_adorn ~= nil then
    select_adorn:search("fig_highlight").visible = false
  end
  select_adorn = item
  select_adorn:search("fig_highlight").visible = true
  g_install_adorn_btn.enable = true
  g_del_adorn_btn.enable = true
end
function on_item_mouse(item, msg)
end
function on_install_click()
  if select == nil then
    return
  end
  w_adorn_mgr_main.visible = true
end
function on_backout_click()
  if select == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.guild_adorn_install_build, select.svar.build_id)
  bo2.send_variant(packet.eCTS_Guild_SetAdorn, v)
end
function on_install_adorn_click()
  if select_adorn == nil and select ~= nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.guild_adorn_id, select_adorn.svar.adorn_id)
  v:set(packet.key.guild_adorn_install_build, select.svar.build_id)
  bo2.send_variant(packet.eCTS_Guild_SetAdorn, v)
end
function on_del_adorn_click()
  if select_adorn == nil then
    return
  end
  local v = sys.variant()
  v:set(packet.key.guild_adorn_id, select_adorn.svar.adorn_id)
  bo2.send_variant(packet.eCTS_Guild_DelAdorn, v)
end
function on_show_all()
  for n = 0, w_adorn_list.item_count - 1 do
    local item = w_adorn_list:item_get(n)
    local ui_guild_adorn
    adorn = ui.guild_find_adorn(item.svar.adorn_id)
    if adorn ~= nil then
      local adorn_excel = bo2.gv_adorn:find(adorn.excelid)
      item.visible = true
      if select ~= nil then
        local adorn_build = bo2.gv_adorn_build:find(select.svar.build_id)
        if adorn_build.adorn_type ~= adorn_excel.adorn_type then
          item.visible = g_show_check.check
        end
      end
    end
  end
end
