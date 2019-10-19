local animation_idx = 1
function get_rand_visible()
  local w = ui_knight.ui_kchallenge.g_krand
  return w.visible
end
function set_rand_visible(vis)
  local w = ui_knight.ui_kchallenge.g_krand
  w.visible = vis
  if vis == true then
    w_next.suspended = false
    w_over.suspended = false
    g_rand_name.text = ""
    animation_idx = 1
    w_animation.visible = true
    g_kchallenge_now.enable = false
  else
    w.svar.rand_id = 0
    w.svar.npc_id = 0
  end
end
function record_rand_npc(data)
  local ctrl = ui_knight.ui_kchallenge.g_krand
  if ctrl == nil then
    return false
  end
  local npclevel = data:get(packet.key.knight_rand_level).v_int
  local npcid = data:get(packet.key.knight_pk_npc_cha_id).v_int
  ctrl.svar.rand_id = npclevel
  ctrl.svar.npc_id = npcid
  local btn = ctrl:search("btn_now")
  if btn == nil then
    return false
  end
  btn.svar.npcid = npcid
  return true
end
function on_visible(ctrl, vis)
end
function on_rand_init(ctrl)
  w_animation_list.scroll = 0.99
end
function on_animation_next()
  w_animation_picture.image = "$image/dailyquest/animation/" .. animation_idx .. ".png"
  animation_idx = animation_idx + 1
  if animation_idx > 12 then
    animation_idx = 1
  end
end
function on_animation_over()
  w_next.suspended = true
  w_over.suspended = true
  animation_idx = 1
  w_block.suspended = false
  w_animation_list.scroll = 0.99
  w_animation.visible = false
end
function update_item(quest_id, item_id)
  local item_name = L("item") .. item_id
  local item = w_item_list:search(item_name)
  if item == nil then
    return
  end
  local aim_box = item:search("rand_name")
  aim_box:item_clear()
end
function on_animation_block()
  w_animation_list.scroll = w_animation_list.scroll - 0.03
  for i = 2, 4 do
    local item = w_animation_list:search("block" .. i)
    local pic = item:search("picture")
    if w_animation_list.scroll < 0.33 * (i - 1) and pic.dx < 200 then
      pic.dx = pic.dx + 0.45
    end
  end
  for i = 5, 6 do
    local item = w_animation_list:search("block" .. i)
    local pic = item:search("picture")
    if w_animation_list.scroll > 0.33 * (i - 4) then
      if pic.dx < 200 then
        pic.dx = pic.dx + 0.45
      end
    elseif pic.dx > 185 then
      pic.dx = pic.dx - 0.45
    end
  end
  for i = 7, 9 do
    local item = w_animation_list:search("block" .. i)
    local pic = item:search("picture")
    if pic.dx > 185 then
      pic.dx = pic.dx - 0.45
    end
  end
  if w_animation_list.scroll <= 0.01 then
    w_block.suspended = true
    w_next.suspended = true
    w_over.suspended = true
    if g_krand.visible then
      set_rand_item_label(g_krand.svar.npc_id, g_krand.svar.rand_id)
      g_kchallenge_now.enable = true
    end
  end
end
function set_rand_item_label(npcid, npclevel)
  local itemtext = ui.get_text("knight|rand_item")
  local v = sys.variant()
  local block_idx = 4
  local block_min = block_idx - 3
  local block_max = block_idx + 3
  for i = block_min, block_max do
    local item = w_animation_list:search("block" .. i)
    local label = item:search("label")
    local level_idx = npclevel - (block_idx - i)
    if level_idx < 1 then
      level_idx = 10 + level_idx
    elseif level_idx > 10 then
      level_idx = level_idx - 10
    end
    v:set("level", level_idx)
    label.text = sys.mtf_merge(v, itemtext)
    if i == block_idx then
      label.color = ui.make_color("00D8FF")
    end
  end
  local line = bo2.gv_cha_list:find(npcid)
  local resulttext = ui.get_text("knight|rand_result")
  v:set("level", npclevel)
  v:set("name", line.name)
  g_rand_name.text = sys.mtf_merge(v, resulttext)
end
function btn_kchallenge_now(btn)
  if btn and btn.svar.npcid ~= nil then
    local v = sys.variant()
    v:set(packet.key.knight_pk_npc_cha_id, btn.svar.npcid)
    bo2.send_variant(packet.eCTS_UI_Knight_Challenge, v)
  end
  set_visible(false)
  set_rand_visible(false)
end
function btn_kchallenge_after(btn)
  set_rand_visible(false)
end
