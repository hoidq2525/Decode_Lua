PM_KEYBOARD_LEFT = 200
NOTE_OFF_DELAY = 32
BUFFER_NFRONTPS = 32
BUFFER_NPOINTS = 32
LENGTH_SHORTEST = 54
LENGTH_LONGEST = 180
LENGTH_PER_SAMPLE = 3
PM_PIANO_HMOVING = 0
PM_PIANO_VMOVING = 1
NO_KEY = 255
KEY_UNITS_HEIGHT = 20
m_nLoNote = 0
m_nHiNote = 0
m_numOctaves = 0
m_piano = {}
m_nWidth = 1020
m_nLeftLimit = PM_KEYBOARD_LEFT
m_nRightLimit = PM_KEYBOARD_LEFT + m_nWidth - 200
m_nHightStart = 80
m_aScoreBuff = {}
m_bnCurrent = {}
m_bnNext = {}
m_iBuffIndex = 0
m_iStartBuff1 = 0
m_iSamplesRemain = 0
m_bFirstBuff = false
m_bForwardDrawing = false
m_bFirstWaittime = 0
noteAfterBreak = 0
m_iCarrot = 0
m_iXIncrement = 0
m_iYIncrement = 0
local i_count = 0
function YPosInNote(Note)
  local nPosOctave, nPosNote
  local nPosOctave = math.floor((m_nHiNote - Note) / 12)
  local nPosNote = (m_nHiNote - Note) % 12
  return m_piano[nPosOctave][nPosNote].m_nPosY
end
function on_get_noteinfo_first(v)
  m_iBuffIndex = 0
  m_iCarrot = 0
  m_iStartBuff1 = 0
  m_bFirstBuff = true
  local note = v:get(packet.key.pm_note_num).v_int
  local vel = v:get(packet.key.pm_note_vel).v_int
  local sample = v:get(packet.key.pm_note_sample).v_int
  if note >= m_nLoNote and note <= m_nHiNote then
    m_bnCurrent.x = m_nLeftLimit
    m_bnCurrent.y = YPosInNote(note)
    m_bnCurrent.note = note
    m_bnCurrent.vel = vel
    if m_aScoreBuff[m_iBuffIndex] == nil then
      m_aScoreBuff[m_iBuffIndex] = {}
    end
    m_aScoreBuff[m_iBuffIndex].x = m_bnCurrent.x
    m_aScoreBuff[m_iBuffIndex].y = m_bnCurrent.y
    m_aScoreBuff[m_iBuffIndex].note = m_bnCurrent.note
    m_aScoreBuff[m_iBuffIndex].vel = m_bnCurrent.vel
    m_iBuffIndex = m_iBuffIndex + 1
    m_iSamplesRemain = sample
    m_bForwardDrawing = true
  end
  m_bFirstWaittime = v:get(packet.key.pm_first_waittime).v_int - 32
  g_pm_timer.suspended = false
end
function MyDivision(iDividend, iDivisor)
  local result = math.floor(iDividend / iDivisor)
  if math.abs(result * iDivisor) < math.abs(iDividend) then
    if result < 0 then
      result = result - 1
    else
      result = result + 1
    end
  end
  return result
end
function CalcNextY(Note)
  m_bnNext.y = YPosInNote(Note)
end
function DrawForward()
  m_iXIncrement = LENGTH_PER_SAMPLE
  m_bnNext.x = m_bnCurrent.x + m_iSamplesRemain * m_iXIncrement - math.abs(m_bnNext.y - m_bnCurrent.y)
  if m_bnNext.x - m_bnCurrent.x < LENGTH_SHORTEST then
    m_iXIncrement = MyDivision(math.abs(m_bnNext.y - m_bnCurrent.y) + LENGTH_SHORTEST, m_iSamplesRemain)
    m_bnNext.x = m_bnCurrent.x + LENGTH_SHORTEST
  elseif m_bnNext.x - m_bnCurrent.x > LENGTH_LONGEST then
    m_iXIncrement = MyDivision(math.abs(m_bnNext.y - m_bnCurrent.y) + LENGTH_LONGEST, m_iSamplesRemain)
    m_bnNext.x = m_bnCurrent.x + LENGTH_LONGEST
  end
end
function DrawBackward()
  m_iXIncrement = 0 - LENGTH_PER_SAMPLE
  m_bnNext.x = m_bnCurrent.x + m_iSamplesRemain * m_iXIncrement - math.abs(m_bnNext.y - m_bnCurrent.y)
  if m_bnNext.x - m_bnCurrent.x < LENGTH_SHORTEST then
    m_iXIncrement = 0 - MyDivision(math.abs(m_bnNext.y - m_bnCurrent.y) + LENGTH_SHORTEST, m_iSamplesRemain)
    m_bnNext.x = m_bnCurrent.x - LENGTH_SHORTEST
  elseif m_bnNext.x - m_bnCurrent.x > LENGTH_LONGEST then
    m_iXIncrement = 0 - MyDivision(math.abs(m_bnNext.y - m_bnCurrent.y) + LENGTH_LONGEST, m_iSamplesRemain)
    m_bnNext.x = m_bnCurrent.x - LENGTH_LONGEST
  end
end
function CalcXIncrement()
  if m_iSamplesRemain <= 0 then
    m_bnNext.x = m_bnCurrent.x
    m_iXIncrement = 0
    return
  end
  if m_bForwardDrawing then
    DrawForward()
  else
    DrawBackward()
  end
end
function CalcYIncrement()
  if m_iXIncrement == 0 then
    m_iYIncrement = 0
    return
  end
  local ny = math.abs((m_bnNext.y - m_bnCurrent.y) / m_iXIncrement)
  if ny > NOTE_OFF_DELAY then
    m_iYIncrement = MyDivision(m_bnNext.y - m_bnCurrent.y, NOTE_OFF_DELAY)
    m_iXIncrement = MyDivision(m_iXIncrement * (m_iSamplesRemain - ny), m_iSamplesRemain - NOTE_OFF_DELAY)
    return
  end
  if m_bnNext.y > m_bnCurrent.y then
    m_iYIncrement = math.abs(m_iXIncrement)
  elseif m_bnNext.y < m_bnCurrent.y then
    m_iYIncrement = 0 - math.abs(m_iXIncrement)
  else
    m_iYIncrement = 0
  end
end
function on_get_noteinfo(v)
  i_count = i_count + 1
  local isFirst = v:has(packet.key.pm_first_draw)
  if isFirst == true then
    on_get_noteinfo_first(v)
    return
  end
  local note = v:get(packet.key.pm_note_num).v_int
  if note == 255 then
    g_pm_timer.suspended = true
    return
  end
  local vel = v:get(packet.key.pm_note_vel).v_int
  local sample = v:get(packet.key.pm_note_sample).v_int
  if m_iSamplesRemain > 0 then
    local mainpanel = ui.find_control("$phase:main")
    m_nRightLimit = mainpanel.dx
    if m_bnCurrent.x > m_nLeftLimit and m_bForwardDrawing then
      m_bForwardDrawing = false
    elseif m_bnCurrent.x < m_nRightLimit and not m_bForwardDrawing then
      m_bForwardDrawing = true
    end
  end
  if note == 0 then
    CalcXIncrement()
    CalcYIncrement()
    m_iNextSamples = 0 - sample
    m_bnNext.note = NO_KEY
  elseif note >= m_nLoNote and note <= m_nHiNote then
    CalcNextY(note)
    CalcXIncrement()
    CalcYIncrement()
    m_iNextSamples = sample
    m_bnNext.note = note
    m_bnNext.vel = vel
  end
  if m_bnNext.x < m_nLeftLimit and not m_bForwardDrawing then
    m_bForwardDrawing = true
    CalcXIncrement()
    CalcYIncrement()
  elseif m_bnNext.x > m_nRightLimit and m_bForwardDrawing then
    m_bForwardDrawing = false
    CalcXIncrement()
    CalcYIncrement()
  end
end
function set_piano_range(v)
  local octaveRange = v:get(packet.key.pm_octaves_range).v_int
  m_nHiNote = octaveRange
  m_numOctaves = v:get(packet.key.pm_num_octaves).v_int
  for i = 0, m_numOctaves - 1 do
    m_piano[i] = {}
    local m_bValidKey = octaveSetRange(octaveRange)
    m_piano[i] = m_bValidKey
    octaveRange = octaveRange - 12
  end
  m_nLoNote = octaveRange + 1
end
function drawPiano(v)
  local panel = ui.create_control(ui.find_control("$phase:main"), "panel")
  panel:load_style("$frame/pixelmouse/ui_pixelmouse.xml", "bg_pm")
  local p_list = panel:search("key_list")
  if p_list ~= nil then
    m_nHightStart = p_list.margin.y1
  end
  panel.visible = true
  local keys = v:get(packet.key.pm_num_keys)
  if keys.empty then
    return
  end
  local validKeyNum = v:get(packet.key.pm_valid_key_num).v_int
  local y_hight = m_nHightStart
  for i = 0, m_numOctaves - 1 do
    for j = 0, keys.size - 1 do
      local data = keys:get(j)
      local valid_key = data:get(packet.key.pm_num_key_index).v_int
      if valid_key == 1 then
        load_key_info(j, y_hight, m_piano[i][j])
        y_hight = y_hight + KEY_UNITS_HEIGHT
      end
    end
  end
end
function CarrotLogic()
end
function BufferLogic()
  if m_bFirstBuff then
    m_iCarrot = m_iBuffIndex - BUFFER_NFRONTPS
    if m_iCarrot < 0 then
      m_iCarrot = 0
    end
  else
    m_iCarrot = m_iCarrot + 1
    if m_iCarrot == BUFFER_NPOINTS then
      m_iCarrot = m_iCarrot - BUFFER_NPOINTS
    end
    m_iStartBuff1 = m_iStartBuff1 + 1
    if m_iStartBuff1 == BUFFER_NPOINTS then
      m_iStartBuff1 = 0
    end
  end
  CarrotLogic()
  if m_iBuffIndex == BUFFER_NPOINTS then
    m_iBuffIndex = 0
    m_bFirstBuff = false
  end
end
function DrawLogic()
  if m_iSamplesRemain < 0 then
    m_iSamplesRemain = m_iSamplesRemain + 1
    if m_aScoreBuff[m_iBuffIndex] == nil then
      m_aScoreBuff[m_iBuffIndex] = {}
    end
    m_aScoreBuff[m_iBuffIndex].x = m_bnNext.x
    m_aScoreBuff[m_iBuffIndex].y = m_bnNext.y
    m_aScoreBuff[m_iBuffIndex].vel = m_bnCurrent.vel
    m_iBuffIndex = m_iBuffIndex + 1
    BufferLogic()
  end
  if m_iSamplesRemain > 0 then
    if m_iXIncrement ~= 0 then
      m_bnCurrent.x = m_bnCurrent.x + m_iXIncrement
      if m_aScoreBuff[m_iBuffIndex] == nil then
        m_aScoreBuff[m_iBuffIndex] = {}
      end
      m_aScoreBuff[m_iBuffIndex].moving = PM_PIANO_HMOVING
      if 0 < m_iXIncrement and m_bnCurrent.x >= m_bnNext.x or 0 > m_iXIncrement and m_bnCurrent.x <= m_bnNext.x then
        m_iXIncrement = 0
        m_bnCurrent.x = m_bnNext.x
      end
    elseif m_iYIncrement ~= 0 then
      m_bnCurrent.y = m_bnCurrent.y + m_iYIncrement
      if 0 < m_iYIncrement and m_bnCurrent.y >= m_bnNext.y or 0 > m_iYIncrement and m_bnCurrent.y <= m_bnNext.y then
        m_iYIncrement = 0
        m_bnCurrent.y = m_bnNext.y
      end
      if m_aScoreBuff[m_iBuffIndex] == nil then
        m_aScoreBuff[m_iBuffIndex] = {}
      end
      m_aScoreBuff[m_iBuffIndex].moving = PM_PIANO_VMOVING
    end
    m_iSamplesRemain = m_iSamplesRemain - 1
    if m_aScoreBuff[m_iBuffIndex] == nil then
      m_aScoreBuff[m_iBuffIndex] = {}
    end
    m_aScoreBuff[m_iBuffIndex].x = m_bnCurrent.x
    m_aScoreBuff[m_iBuffIndex].y = m_bnCurrent.y
    m_aScoreBuff[m_iBuffIndex].vel = m_bnCurrent.vel
    m_iBuffIndex = m_iBuffIndex + 1
    BufferLogic()
  end
  if m_iSamplesRemain == 0 then
    m_bnCurrent.x = m_bnNext.x
    m_bnCurrent.y = m_bnNext.y
    m_bnCurrent.note = m_bnNext.note
    m_bnCurrent.vel = m_bnNext.vel
    if m_aScoreBuff[m_iBuffIndex] == nil then
      m_aScoreBuff[m_iBuffIndex] = {}
    end
    m_aScoreBuff[m_iBuffIndex].note = m_bnCurrent.note
    m_aScoreBuff[m_iBuffIndex].vel = m_bnCurrent.vel
    m_iSamplesRemain = m_iNextSamples
    return true
  end
  return false
end
local fade_in_uri = "$frame/skill/transition.xml|scratch_skill_in"
local fade_out_uri = "$frame/skill/transition.xml|scratch_skill_out"
function DrawPointToPointLogic(pos_x, pos_y)
  local panel = ui.create_control(ui.find_control("$phase:main"), "panel")
  panel:load_style("$frame/pixelmouse/ui_pixelmouse.xml", "serpentine_line")
  local serpentine_view = panel:search("serpentine_view")
  panel.visible = true
  panel.offset = ui.point(pos_x, pos_y)
  panel:find_plugin("serpentine_timer").suspended = false
  serpentine_view.transition = fade_in_uri
end
function on_serpentine_timer(ctrl)
  ctrl.owner.visible = false
  ctrl.suspended = true
end
function DrawSerpentineLine()
  local i = -1
  m_iStartX = m_aScoreBuff[m_iStartBuff1].x
  m_iLeftX = m_aScoreBuff[m_iStartBuff1].x
  m_iRightX = m_aScoreBuff[m_iStartBuff1].x
  m_iStartY = m_aScoreBuff[m_iStartBuff1].y
  m_iTopY = m_aScoreBuff[m_iStartBuff1].y
  m_iBottomY = m_aScoreBuff[m_iStartBuff1].y
  m_crLastColor = PM_COLOR_BACK
  if m_bFirstBuff then
    DrawPointToPointLogic(m_aScoreBuff[m_iBuffIndex - 1].x, m_aScoreBuff[m_iBuffIndex - 1].y)
  else
    DrawPointToPointLogic(m_aScoreBuff[m_iBuffIndex - 1].x, m_aScoreBuff[m_iBuffIndex - 1].y)
  end
end
