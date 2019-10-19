function set_value(w, v)
  local c = math.floor((v + 0.05) / 0.1)
  if c >= 10 then
    c = 10
  elseif c < 0 then
    c = 0
  end
  for i = 0, 8, 2 do
    local s = w:search("star" .. i / 2)
    if i < c then
      if c - i == 1 then
        s.image = "$image/widget/pic/star_half.png"
      else
        s.image = "$image/widget/pic/star_full.png"
      end
    else
      s.image = "$image/widget/pic/star_null.png"
    end
  end
end
