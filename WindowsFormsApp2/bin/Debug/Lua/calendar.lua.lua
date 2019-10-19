function IsEqual(a, b, c, d)
  if a == b then
    return c
  else
    return d
  end
end
function leapMonth(y)
  local lm = bo2.bit_and(g_LunarInfo[y + 1 - 2001], 15)
  return IsEqual(lm, 15, 0, lm)
end
function monthDays(y, m)
  if bo2.bit_and(tonumber(g_LunarInfo[y + 1 - 2001]), 65536 / 2 ^ m) ~= 0 then
    return 30
  else
    return 29
  end
end
function leapDays(y)
  if leapMonth(y) ~= 0 then
    return IsEqual(bo2.bit_and(g_LunarInfo[y + 1 - 2001], 15), 15, 30, 29)
  else
    return 0
  end
end
function lYearDays(y)
  local i
  local sum = 348
  local lunarInfo = g_LunarInfo[y + 1 - 2001]
  i = 32768
  while i > 8 do
    if bo2.bit_and(lunarInfo, i) ~= 0 then
      sum = sum + 1
    end
    i = i / 2
  end
  return sum + leapDays(y)
end
function IsLeapYear(year)
  if year % 4 ~= 0 then
    return false
  end
  if year % 400 == 0 then
    return true
  end
  if year % 100 == 0 then
    return false
  end
  return true
end
function SolarDays(year, month, day)
  local ofs
  if month > 1 and IsLeapYear(year) == true then
    ofs = 1
  else
    ofs = 0
  end
  year = year - 1
  local r = year * 365 + math.floor(year / 4) - math.floor(year / 100) + math.floor(year / 400) + g_SolarDays[month + 1] + day + ofs
  return math.floor(r)
end
function SolarDate(year, month, days)
  local ry = year
  local rm = month
  local rd = days
  local y = math.floor(days / 365.2425)
  if year ~= nil then
    ry = y + 1
  end
  rd = rd - (y * 365 + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400))
  local m = 1
  while m < 12 and rd > g_SolarDays[m] do
    if m == 2 and IsLeapYear(y + 1) then
      rd = rd - 1
    end
    m = m + 1
  end
  m = m - 1
  rd = rd - g_SolarDays[m + 1]
  if rd == 0 then
    rd = 29
    m = m - 1
  end
  return rd
end
function sTerm(y, n)
  local ofs
  ofs = SolarDays(1900, 0, 6) + math.floor((3.15569259747E7 * (y - 1900) + g_TermInfo[n + 1] * 60 + 7500 + 4570.1) / 86400)
  local r = SolarDate(0, 0, ofs)
  return r
end
function GanZhi(type, offset)
  offset = math.floor(offset)
  local o10 = offset % 10
  local o12 = offset % 12
  if o10 < 0 then
    o10 = o10 + 10
  end
  if o12 < 0 then
    o12 = o12 + 12
  end
  if type == "year" then
    sdate.y_tiangan = g_TianGan[o10 + 1]
    sdate.y_dizhi = g_DiZhi[o12 + 1]
    sdate.animal = g_Animals[o12 + 1]
  elseif type == "month" then
    sdate.m_tiangan = g_TianGan[o10 + 1]
    sdate.m_dizhi = g_DiZhi[o12 + 1]
  elseif type == "day" then
    sdate.d_tiangan = g_TianGan[o10 + 1]
    sdate.d_dizhi = g_DiZhi[o12 + 1]
  end
end
function LunarDate(year, month, day)
  local i, temp
  local offset = SolarDays(year, month, day) - SolarDays(2010, 1, 14)
  i = 2010
  while i < 2020 and offset > 0 do
    temp = lYearDays(i)
    offset = offset - temp
    i = i + 1
  end
  if offset < 0 then
    offset = offset + temp
    i = i - 1
  end
  sdate.lyear = i
  local leap = leapMonth(i)
  local isLeap = false
  i = 1
  while i < 13 and offset > 0 do
    if leap > 0 and i == leap + 1 and not isLeap then
      i = i - 1
      isLeap = true
      temp = leapDays(sdate.lyear)
    else
      temp = monthDays(sdate.lyear, i)
    end
    if isLeap and i == leap + 1 then
      isLeap = false
    end
    offset = offset - temp
    i = i + 1
  end
  if offset == 0 and leap > 0 and i == leap + 1 then
    if isLeap then
      isLeap = false
    else
      isLeap = true
      i = i - 1
    end
  end
  if offset < 0 then
    offset = offset + temp
    i = i - 1
  end
  sdate.lmonth = i
  sdate.ldays = offset + 1
  return isLeap
end
function lformat()
  if sdate.ldays ~= 0 then
    local days = sdate.ldays % 10
    if days == 0 then
      days = 10
    end
    if sdate.ldays < 11 then
      sdate.ldays = ui.get_text("calendar|chu") .. ui.get_text("calendar|" .. days)
    elseif sdate.ldays < 20 then
      sdate.ldays = ui.get_text("calendar|shi") .. ui.get_text("calendar|" .. days)
    elseif sdate.ldays < 21 then
      sdate.ldays = ui.get_text("calendar|er") .. ui.get_text("calendar|" .. days)
    elseif sdate.ldays < 30 then
      sdate.ldays = ui.get_text("calendar|ershi") .. ui.get_text("calendar|" .. days)
    else
      sdate.ldays = ui.get_text("calendar|san") .. ui.get_text("calendar|" .. days)
    end
  end
  if sdate.lmonth ~= 0 then
    local months = sdate.lmonth % 10
    if months == 0 then
      months = 10
    end
    if sdate.lmonth == 1 then
      sdate.lmonth = ui.get_text("calendar|zheng")
    elseif 11 > sdate.lmonth then
      sdate.lmonth = ui.get_text("calendar|" .. months)
    elseif sdate.lmonth == 11 then
      sdate.lmonth = ui.get_text("calendar|10") .. ui.get_text("calendar|1")
    elseif sdate.lmonth == 12 then
      sdate.lmonth = ui.get_text("calendar|10") .. ui.get_text("calendar|2")
    end
  end
end
function on_calendar_init()
  local time = os.date("*t")
end
function on_calendar_tip(tip)
  local time = os.date("*t")
  sdate.time = sys.format("%s", os.date("%H:%M"))
  if time.wday then
    local week = time.wday - 1
    if time.wday ~= 0 then
      sdate.weeks = ui.get_text("calendar|week") .. ui.get_text("calendar|" .. week)
    else
      sdate.weeks = ui.get_text("calendar|week") .. ui.get_text("calendar|" .. ri)
    end
  end
  Calendar(time.year, time.month, time.day)
  local stk = sys.mtf_stack()
  ui_tool.ctip_make_calenlar(stk, sdate)
  stk:push("\n")
  local id = bo2.scn.excel.pk_limit
  local areaID = bo2.player:get_atb(bo2.eAtb_AreaID)
  local area_list = bo2.gv_area_list:find(areaID)
  local limit = ui.get_text("portrait|pk_limit_" .. id)
  stk:push(limit)
  if area_list ~= nil then
    local lvl = area_list.pk_level
    local lvl_limit = sys.format("%s:%d", ui.get_text("portrait|area_pk_level"), lvl)
    stk:push("\n")
    stk:push(lvl_limit)
  end
  ui_tool.ctip_show(tip.owner, stk)
end
function Calendar(year, month, day)
  local week = SolarDays(year, month - 1, day) % 7
  sdate.year = year
  sdate.month = month
  sdate.days = day
  local term2 = sTerm(year, 2)
  local firstNode = sTerm(year, (month - 1) * 2)
  local dayCyclical = SolarDays(year, month - 1, 1) - 693586
  LunarDate(year, month - 1, day)
  sdate.LunarFestival = 0
  for i, v in ipairs(g_LunarFestival) do
    if sdate.lmonth == v[1] and sdate.ldays == v[2] then
      sdate.LunarFestival = v[3]
      break
    end
  end
  lformat()
  GanZhi("year", year - 1864)
  GanZhi("month", (year - 1900) * 12 + month - 1 + 13)
  GanZhi("day", dayCyclical + day - 1)
  local firstterm = sTerm(year, (month - 1) * 2)
  local secondterm = sTerm(year, (month - 1) * 2 + 1)
  if day == firstterm then
    sdate.term = g_SolarTerm[(month - 1) * 2 + 1]
  elseif day == secondterm then
    sdate.term = g_SolarTerm[(month - 1) * 2 + 1 + 1]
  else
    sdate.term = 0
  end
  sdate.SolarFestival = 0
  for i, v in ipairs(g_SolarFestival) do
    if sdate.month == v[1] and sdate.days == v[2] then
      sdate.SolarFestival = v[3]
      break
    end
  end
end
