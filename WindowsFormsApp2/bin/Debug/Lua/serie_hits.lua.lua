local num = 0
function set_hits1(con, num)
  con.image = "$gui/icon/skill/hits/" .. num .. ".png"
  con:reset(0.1, 1, 200)
end
function set_hits2(con, num)
  con.image = "$gui/icon/skill/hits/" .. num .. ".png"
  con:reset(1, 0, 500)
end
function set_for_hit(con1, con2, num)
  if num <= 0 then
    return
  end
  if num > 0 and num < 10 then
    set_hits1(con1, num)
    w_panel_hits_10.visible = false
  else
    w_panel_hits_10.visible = true
    if num > 99 then
      num = 99
    end
    local num_1 = num % 10
    local num_10 = math.floor(num / 10)
    set_hits1(con1, num_1)
    if num_10 ~= 0 then
      set_hits1(con2, num_10)
    end
  end
end
function set_bg_hit(con1, con2, num)
  if num <= 0 then
    return
  end
  if num > 0 and num < 10 then
    set_hits2(con1, num)
  else
    if num > 99 then
      num = 99
    end
    local num_1 = num % 10
    local num_10 = math.floor(num / 10)
    set_hits2(con1, num_1)
    if num_10 ~= 0 then
      set_hits2(con2, num_10)
    end
  end
end
function SetHit(num)
  set_for_hit(w_hits, w_hits2, num)
  set_bg_hit(w_hits1, w_hits3, num - 1)
  w_panel_hits:reset(1, 0, 2000, 1000)
end
function addhit(obj)
  local num = obj:get_flag_objmem(bo2.eFlagObjMemory_PlayerSeriesHit)
  SetHit(num)
end
function on_click(btn)
  num = num + 1
  set_for_hit(w_hits, w_hits2, num)
  set_bg_hit(w_hits1, w_hits3, num - 1)
end
function on_hits_10_visible(c)
  if c.visible == true then
    w_xx.visible = false
    w_xx1.visible = true
  else
    w_xx.visible = true
    w_xx1.visible = false
  end
end
function on_init()
  w_hits:type(1)
  w_hits2:type(1)
  w_hits1:type(2)
  w_hits3:type(2)
  w_panel_hits:reset(0, 0, 0)
end
local sig_name = "ui_hits.addhit:on_signal"
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_serie_hits, addhit, sig_name)
