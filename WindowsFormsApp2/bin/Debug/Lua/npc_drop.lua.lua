if rawget(_M, "w_npc_drop") == nil then
  w_npc_drop = 0
end
if rawget(_M, "tb_drop_type") == nil then
  tb_drop_type = 0
  tb_drop_type_sel = 0
end
function on_show_npc_drop(btn)
  if not sys.check(w_npc_drop) then
    w_npc_drop = ui.create_control(ui_main.w_top, "panel")
    w_npc_drop:load_style("$frame/npcfunc/npc_drop.xml", "npc_drop")
  end
  w_npc_drop.visible = not w_npc_drop.visible
end
local drop_type_load = function(tb)
  local c = tb.size
  for i = 0, c - 1 do
    local n = tb:get(i)
    local t = n.drop_type
    if t > 0 then
      local s = tb_drop_type[t]
      if s == nil then
        s = {}
        tb_drop_type[t] = s
      end
      table.insert(s, n)
    end
  end
end
function on_mtf_drop_type_click(btn)
  local sel = btn.svar.arg.v_int
  if sel == tb_drop_type_sel then
    tb_drop_type_sel = 0
  else
    tb_drop_type_sel = sel
  end
  w_npc_drop.svar.target = nil
end
local make_drop_single = function(stk, id)
  local rand = bo2.gv_item_rand:find(id)
  if rand == nil then
    return
  end
  stk:raw_format("\n-\181\244\194\228\163\186%d, %d-%d\180\206", rand.id, rand.minRoll, rand.maxRoll)
  local drop_kind = rand.drop_kind
  local drop_id = rand.drop_id
  local drop_prob = rand.drop_prob
  for i = 0, 9 do
    local k = drop_kind[i]
    local d = drop_id[i]
    if k == 1 then
      stk:raw_format("\n\181\192\190\223\163\186<i:%d>,%.3g%%", d, drop_prob[i] / 10000)
    else
      if k == 2 then
        stk:raw_format("\n<btn:ui_npcfunc.ui_npc_drop.on_mtf_drop_type_click,\192\224\208\205%d,%d>\163\186%.3g%%,", d, d, drop_prob[i] / 10000)
        local v = tb_drop_type[d]
        if v then
          local t = #v
          local c = 3
          if tb_drop_type_sel == d then
            c = t
          end
          for idx = 1, c do
            local x = v[idx]
            if x then
              stk:raw_format("<i:%d>", x.id)
            else
              break
            end
          end
          if t > c then
            stk:push("...")
          end
        else
          stk:raw_format("<c+:FF0000>\195\187\213\210\181\189T_T<c->")
        end
      else
      end
    end
  end
end
local function make_drop_multi(stk, ids, name)
  local c = ids.size
  if c == 0 then
    return
  end
  ui_tool.ctip_push_sep(stk)
  local v0 = ids[0]
  local si, mark
  if v0 == 0 then
    si = 1
    mark = "\182\224\209\161"
  else
    si = 0
    mark = "\181\165\209\161"
  end
  stk:raw_format("<a+:m>%s(%s)<a->", name, mark)
  for i = si, c - 1 do
    make_drop_single(stk, ids[i])
  end
end
local make_drop_quest = function(stk, ids, name)
  local c = ids.size
  if c < 3 then
    return
  end
  ui_tool.ctip_push_sep(stk)
  stk:raw_format("<a+:m>%s<a->", name)
  for i = 2, c - 1, 3 do
    stk:raw_format([[

<i:%d>x%d,%.3g%%]], ids[i - 2], ids[i - 1], ids[i])
  end
end
if rawget(_M, "mb_money_drop_list") == nil then
  mb_money_drop_list = 0
end
local make_drop_money = function(stk, id, name)
  if id <= 0 then
    return
  end
  if not sys.check(mb_money_drop_list) then
    mb_money_drop_list = bo2.gv_money_drop_list
    if mb_money_drop_list.size == 0 then
      mb_money_drop_list = sys.load_table("$mb/item/money_drop_list.xml")
    end
  end
  local m = mb_money_drop_list:find(id)
  if m == nil then
    return
  end
  ui_tool.ctip_push_sep(stk)
  stk:raw_format("<a+:m>%s(\184\161\182\175%.3g%%)<a->", name, m.rate * 100)
  local drop_heap = m.drop_heap
  local _money = m._money
  local drop_persent = m.drop_persent
  local c = drop_persent.size
  for i = 0, c - 1 do
    stk:raw_format([[

<bm:%d>x %d, %.3g%%]], _money[i], drop_heap[i], drop_persent[i] * 100)
  end
end
local function make_drop_special(stk, excel)
  local gv_special_drop = bo2.gv_special_drop
  local c = gv_special_drop.size
  if c == 0 then
    return
  end
  local cur_scn_id = bo2.scn.excel.id
  local cur_cha_id = excel.id
  for i = 0, c - 1 do
    local sd = gv_special_drop:get(i)
    local scn_id = sd.scnid
    local cha_id = sd.chaid
    local name
    if scn_id > 0 and cha_id > 0 then
      if scn_id == cur_scn_id and cha_id == cur_cha_id then
        name = "\179\161\190\176\189\199\201\171\181\244\194\228"
      end
    elseif scn_id > 0 then
      if scn_id == cur_scn_id then
        name = "\179\161\190\176\181\244\194\228"
      end
    elseif cha_id > 0 then
      if cha_id == cur_cha_id then
        name = "\189\199\201\171\181\244\194\228"
      end
    else
      name = "\200\171\190\214\181\244\194\228"
    end
    if name then
      make_drop_multi(stk, sd.item_rand, "\187\238\182\175" .. sd.id .. "\163\186" .. name)
    end
  end
end
function on_npc_drop_timer(t)
  local player = bo2.player
  local svar = w_npc_drop.svar
  if not sys.check(player) then
    svar.target = nil
    tb_drop_type_sel = 0
    w_npc_drop:search("rb_text").mtf = ""
    return
  end
  local target = bo2.scn:get_scn_obj(player.target_handle)
  if target == nil or target.kind == bo2.eScnObjKind_Player then
    svar.target = nil
    tb_drop_type_sel = 0
    w_npc_drop:search("rb_text").mtf = ""
    return
  end
  if svar.target == target then
    return
  end
  svar.target = target
  if not sys.check(tb_drop_type) then
    tb_drop_type = {}
    drop_type_load(bo2.gv_item_list)
    drop_type_load(bo2.gv_quest_item)
    drop_type_load(bo2.gv_equip_item)
    drop_type_load(bo2.gv_gem_item)
    drop_type_load(bo2.gv_starstone_item)
    drop_type_load(bo2.gv_scroll_item)
  end
  local excel = target.excel
  local stk = sys.mtf_stack()
  stk:raw_format("<a+:m>%s<a->", target.name)
  make_drop_money(stk, excel.money_drop, "\189\240\199\174\181\244\194\228")
  make_drop_multi(stk, excel.feature_drop, "\204\216\201\171\181\244\194\228")
  make_drop_multi(stk, excel.world_drop, "\202\192\189\231\181\244\194\228")
  make_drop_multi(stk, excel.still_drop, "\204\229\205\226\181\244\194\228")
  make_drop_quest(stk, excel.quest_drop, "\200\206\206\241\181\244\194\228")
  make_drop_special(stk, excel)
  w_npc_drop.size = ui.point(300, 200)
  w_npc_drop:search("rb_text").mtf = stk.text
  w_npc_drop:tune_y("rb_text")
  w_npc_drop:tune_x("rb_text")
  w_npc_drop.dx = w_npc_drop.dx + 20
  w_npc_drop.visible = false
  local dx = w_npc_drop.dx
  if dx < 180 then
    dx = 180
  end
  local dy = w_npc_drop.dy
  if dy < 120 then
    dy = 120
  elseif dy > 800 then
    dy = 800
  end
  w_npc_drop.size = ui.point(dx, dy)
  w_npc_drop.visible = true
end
