KEY_UNITS_HEIGHT = 20
key_text_tb = {
  "7",
  "6#",
  "6",
  "5#",
  "5",
  "4#",
  "4",
  "3",
  "2#",
  "2",
  "1#",
  "1"
}
function setNote(nNote)
end
function octaveSetRange(HiRange)
  local m_bValidKey = {}
  for i = 0, 11 do
    m_bValidKey[i] = {}
    m_bValidKey[i].valid = 0
    m_bValidKey[i].noteRange = HiRange - i
    m_bValidKey[i].m_nPosY = 0
  end
  return m_bValidKey
end
function load_key_info(index, y_hight, validkey_tb)
  validkey_tb.valid = 1
  local key_info = g_key_list:item_append()
  key_info:load_style("$frame/pixelmouse/ui_pixelmouse.xml", L("key_pm"))
  KEY_UNITS_HEIGHT = key_info.dy
  validkey_tb.m_nPosY = y_hight + KEY_UNITS_HEIGHT / 2
  key_info:search("key_name").text = key_text_tb[index + 1]
end
function MidOfKey(numKey)
  local iMidY = m_bValidKey[numKey].m_nPosY + KEY_UNITS_HEIGHT / 2
  return iMidY
end
