directory = "$image/personal/broken/"
g_broken_equip = false
g_image_list = {}
function on_init()
  g_image_list = {
    {
      grid = card_helmet.grid,
      image = "helmet",
      folder = "",
      ctrl = helmet
    },
    {
      grid = card_glove1.grid,
      image = "glove_right",
      folder = "",
      ctrl = glove_right
    },
    {
      grid = card_glove2.grid,
      image = "glove_left",
      folder = "",
      ctrl = glove_left
    },
    {
      grid = card_belt.grid,
      image = "belt",
      folder = "",
      ctrl = belt
    },
    {
      grid = card_pants.grid,
      image = "pants",
      folder = "",
      ctrl = pants
    },
    {
      grid = card_wrist1.grid,
      image = "wrist_right",
      folder = "",
      ctrl = wrist_right
    },
    {
      grid = card_wrist2.grid,
      image = "wrist_left",
      folder = "",
      ctrl = wrist_left
    },
    {
      grid = card_coat.grid,
      image = "coat",
      folder = "",
      ctrl = coat
    },
    {
      grid = card_shoes.grid,
      image = "shoes",
      folder = "",
      ctrl = shoes
    },
    {
      grid = card_amulet.grid,
      image = "amulet",
      folder = "",
      ctrl = amulet
    },
    {
      grid = card_weapon.grid,
      image = "weapon",
      folder = "",
      ctrl = weapon
    },
    {
      grid = card_necklace.grid,
      image = "necklace",
      folder = "",
      ctrl = necklace
    },
    {
      grid = card_ring.grid,
      image = "ring",
      folder = "",
      ctrl = ring
    },
    {
      grid = card_2ndweapon.grid,
      image = "2ndweapon",
      folder = "",
      ctrl = assistweapon
    }
  }
end
function on_card_tip_show(tip)
  local card = tip.owner
  local stk = sys.mtf_stack()
  local info
  for i = bo2.eItemSlot_EquipBeg, bo2.eItemSlot_AvataEnd - 1 do
    local t = ui.item_of_coord(bo2.eItemArray_InSlot, i)
    if card.grid == i then
      if t ~= nil then
        info = t
        stk:push(info.excel.name)
        ui_tool.ctip_push_newline(stk)
        stk:push(ui.get_text("personal|wearout"))
        local value = info:get_data_32(bo2.eItemUInt32_CurWearout)
        local limit = info:get_data_32(bo2.eItemUInt32_MaxWearout)
        if info.excel.consume_mode == bo2.eItemConsumeMod_Avoid then
          stk:push(ui.get_text("tool|tip_item_never_broken"))
        elseif value <= limit and value > 0.8 * limit then
          stk:raw_format("%d/%d", value, limit)
        elseif value <= 0.8 * limit and value > 0 then
          stk:raw_format("<c+:FFFF00>%d<c->/%d", value, limit)
        elseif value == 0 then
          stk:raw_format("<c+:FF0000>%d<c->/%d", value, limit)
        end
      else
        stk:push(ui.get_text(sys.format(L("item|slot%d"), card.grid)))
        ui_tool.ctip_push_newline(stk)
        stk:push(ui.get_text("personal|noequip"))
      end
    end
  end
  ui_tool.ctip_show(card, stk)
end
function update_equip()
  g_broken_equip = false
  if g_image_list ~= nil then
    for i, v in ipairs(g_image_list) do
      local info = ui.item_of_coord(bo2.eItemArray_InSlot, v.grid)
      if info ~= nil then
        local value = info:get_data_32(bo2.eItemUInt32_CurWearout)
        local limit = info:get_data_32(bo2.eItemUInt32_MaxWearout)
        if info.excel.consume_mode == bo2.eItemConsumeMod_Avoid then
          v.folder = "white/"
        elseif value <= limit and value > 0.3 * limit then
          v.folder = "white/"
        elseif value <= 0.3 * limit and value > 0 then
          v.folder = "yellow/"
          g_broken_equip = true
        elseif value == 0 then
          v.folder = "red/"
          g_broken_equip = true
        end
        v.ctrl.image = directory .. v.folder .. v.image .. ".png"
      else
        v.folder = ""
        v.ctrl.image = ""
      end
    end
  end
  if g_broken_equip then
    gx_window.visible = true
  else
    gx_window.visible = false
  end
end
