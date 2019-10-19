theme_type_search_page = 0
theme_type_cha_list = 1
theme_type_item_list = 2
theme_type_quest_list = 3
theme_type_area_list = 4
theme_type_topic = 10
theme_type_end = 3
class_type_equal = 1
class_type_found = 2
class_type_end = 3
class_type_begin = class_type_equal
g_mb_view = nil
g_theme_data = nil
function on_init_mb_view()
  if g_mb_view == nil then
    g_mb_view = {}
    g_mb_view.guide_cha_auto = sys.load_table("$mb/help/guide/auto/guide_cha_auto.xml")
    g_mb_view.guide_item_auto = sys.load_table("$mb/help/guide/auto/guide_item_auto.xml")
    g_mb_view.guide_area_auto = sys.load_table("$mb/help/guide/auto/guide_area_auto.xml")
    g_mb_view.whitelist_cha_auto = sys.load_table("$mb/help/guide/whitelist/whitelist_cha_auto.xml")
    g_mb_view.whitelist_item_auto = sys.load_table("$mb/help/guide/whitelist/whitelist_item_auto.xml")
    g_mb_view.whitelist_area_auto = sys.load_table("$mb/help/guide/whitelist/whitelist_area_auto.xml")
  end
end
function find_item_auto_excel(id)
  if g_mb_view == nil then
    return nil
  end
  local pExcel = g_mb_view.guide_item_auto:find(id)
  return pExcel
end
function find_cha_auto_excel(id)
  if g_mb_view == nil then
    return nil
  end
  local pExcel = g_mb_view.guide_cha_auto:find(id)
  return pExcel
end
function find_area_auto_excel(id)
  if g_mb_view == nil then
    return nil
  end
  local pExcel = g_mb_view.guide_area_auto:find(id)
  return pExcel
end
function on_init_theme_data()
  if g_theme_data == nil then
    g_theme_data = {}
    local get_desc_name = function(mb)
      return mb.desc
    end
    local _get_name = function(mb)
      return mb.name
    end
    local get_mtf_text_common = function(theme_table, id)
      local mb_view = theme_table.mb_view
      local mb_data = mb_view:find(id)
      return mb_data.name
    end
    local get_mtf_text_item = function(theme_table, id)
      local mb_data = ui.item_get_excel(id)
      if mb_data == nil then
        return nil
      end
      return mb_data.name
    end
    local get_mb_data_common = function(theme_table, id)
      local mb_view = theme_table.mb_view
      local mb_data = mb_view:find(id)
      return mb_data
    end
    local get_mb_data_item = function(theme_table, id)
      local mb_data = ui.item_get_excel(id)
      return mb_data
    end
    g_theme_data[theme_type_cha_list] = {
      mb_view = bo2.gv_cha_list,
      search_view = g_mb_view.guide_cha_auto,
      get_name = get_desc_name,
      get_mb = get_mb_data_common,
      get_mtf_text = get_mtf_text_common,
      find_auto = find_cha_auto_excel,
      while_list = g_mb_view.whitelist_cha_auto
    }
    g_theme_data[theme_type_item_list] = {
      mb_view = bo2.gv_item_list,
      search_view = g_mb_view.guide_item_auto,
      get_name = get_desc_name,
      get_mb = get_mb_data_item,
      get_mtf_text = get_mtf_text_item,
      find_auto = find_item_auto_excel,
      while_list = g_mb_view.whitelist_item_auto
    }
    g_theme_data[theme_type_quest_list] = {
      mb_view = bo2.gv_quest_list,
      get_name = _get_name,
      get_mb = get_mb_data_common,
      get_mtf_text = get_mtf_text_common
    }
    local get_area_name = function(mb)
      return mb.display_name
    end
    g_theme_data[theme_type_area_list] = {
      mb_view = bo2.gv_area_list,
      get_name = get_area_name,
      get_mb = get_mb_data_common,
      get_mtf_text = get_mtf_text_common,
      find_auto = find_area_auto_excel,
      while_list = g_mb_view.whitelist_area_auto
    }
  end
end
class_type_equal = 1
class_type_found = 2
class_type_end = 3
class_type_begin = class_type_equal
