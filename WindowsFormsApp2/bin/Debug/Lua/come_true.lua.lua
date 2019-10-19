function set_visible(excel_id, excel_count)
  local card = m_panel:search("card_final")
  local item = card:search("item")
  local count = card:search("count")
  item.excel_id = excel_id
  count.text = excel_count
  gx_window.visible = true
end
