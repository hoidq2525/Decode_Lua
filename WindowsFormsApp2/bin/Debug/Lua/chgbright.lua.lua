local color_table = {}
color_table[0] = "0x00000000"
color_table[1] = "0xdf000000"
color_table[2] = "0x88000000"
color_table[3] = "0x22ffffff"
color_table[4] = "0x88ffffff"
local dark_table = {}
dark_table[1] = 0.8
dark_table[2] = 0.6
local min_frm = 25
function on_chgbright(data)
  local chg = data:get(packet.key.chg_scn_bri_chg).v_int
  local frm = data:get(packet.key.chg_scn_bri_frm).v_int
  if nil == chg then
    chg = 0
  end
  if nil == frm then
    frm = 25
  end
  if chg >= 3 then
    bo2.setcoloreffect(frm, 1, color_table[chg])
  elseif chg >= 1 then
    if frm < min_frm then
      frm = min_frm
    end
    bo2.scene_black(frm, dark_table[chg], 1)
  else
    bo2.setcoloreffect(frm, 0, color_table[chg])
    if frm < min_frm then
      frm = min_frm
    end
    bo2.scene_black(frm, dark_table[chg], 0)
  end
end
