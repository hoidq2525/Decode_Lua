function ctip_push_req(stk, kind, val, idx)
  if kind == bo2.eItemReq_Career then
    local prof = ctip_get_atb(bo2.eAtb_Cha_Profession)
    local profExcel = bo2.gv_profession_list:find(prof)
    if profExcel == nil then
      return
    end
    local color
    if profExcel.career ~= val then
      color = cs_tip_color_red
    end
    local name = ""
    local careerExcel = bo2.gv_career:find(val)
    if careerExcel ~= nil then
      name = careerExcel.name
    end
    if idx > 1 then
      ctip_push_newline(stk)
    end
    ctip_push_text(stk, ui_widget.merge_mtf({profession = name}, ui.get_text("tool|tip_item_profession")), color)
  elseif kind == bo2.eItemReq_Profession then
    local color
    if ctip_get_atb(bo2.eAtb_Cha_Profession) ~= val then
      color = cs_tip_color_red
    end
    local name = ""
    local profExcel = bo2.gv_profession_list:find(val)
    if profExcel ~= nil then
      name = profExcel.name
    end
    if idx > 1 then
      ctip_push_newline(stk)
    end
    ctip_push_text(stk, ui_widget.merge_mtf({profession = name}, ui.get_text("tool|tip_item_profession")), color)
  elseif kind == bo2.eItemReq_MaxLevel then
    local color
    if val <= ctip_get_atb(bo2.eAtb_Level) then
      color = cs_tip_color_red
    end
    if idx > 1 then
      ctip_push_newline(stk)
    end
    ctip_push_text(stk, ui.get_text("tool|tip_item_lvl_limit") .. sys.format("%d", val), color)
  elseif kind == bo2.eItemReq_Sex then
    local color
    if ctip_get_atb(bo2.eAtb_Sex) ~= val then
      color = cs_tip_color_red
    end
    if idx > 1 then
      ctip_push_newline(stk)
    end
    ctip_push_text(stk, ui.get_text("tool|tip_item_sex") .. sys.format("%s", ui.get_text("common|sex" .. val)), color)
  elseif kind == bo2.eItemReq_XinFaLevel then
    local xinfaLv = bo2.GetZhuZhiXinFaLevel()
    local color
    if val > xinfaLv then
      color = cs_tip_color_red
    end
    if idx > 1 then
      ctip_push_newline(stk)
    end
    ctip_push_text(stk, ui.get_text("tool|tip_item_xinfa") .. sys.format("%d", val), color)
  elseif kind == bo2.eItemReq_GuildTitle then
    local color
    local member_self = ui.guild_get_self()
    if sys.check(member_self) ~= true or val > member_self.title then
      color = cs_tip_color_red
    end
    if idx > 1 then
      ctip_push_newline(stk)
    end
    ctip_push_text(stk, ui_widget.merge_mtf({
      title = bo2.gv_guild_title:find(val).name
    }, ui.get_text("tool|tip_guild_title")), color)
  elseif kind == bo2.eItemReq_Damage then
    local pro_id = bo2.player:get_atb(bo2.eAtb_Cha_Profession)
    if pro_id == 0 then
      return
    end
    local damage = bo2.gv_profession_list:find(pro_id).damage
    local color
    if damage ~= val then
      color = cs_tip_color_red
    end
    if idx > 1 then
      ctip_push_newline(stk)
    end
    local mtf = {}
    mtf.damage = ui.get_text(sys.format("portrait|damage_type_%d", val))
    ctip_push_text(stk, ui_widget.merge_mtf(mtf, ui.get_text("tool|tip_damage")), color)
  end
end
function ctip_time_text(t)
  t = math.floor(t)
  if t <= 60 then
    return ui_widget.merge_mtf({
      second = math.floor(t)
    }, ui.get_text("tool|tip_item_time1"))
  elseif t < 3600 then
    local s = math.mod(t, 60)
    if s > 0 then
      return ui_widget.merge_mtf({
        minute = math.floor(t / 60),
        second = s
      }, ui.get_text("tool|tip_item_time2"))
    else
      return ui_widget.merge_mtf({
        minute = math.floor(t / 60)
      }, ui.get_text("tool|tip_item_time2_0"))
    end
  elseif t < 86400 then
    local m = math.floor(math.mod(t, 3600) / 60)
    if m > 0 then
      return ui_widget.merge_mtf({
        hour = math.floor(t / 3600),
        minute = m
      }, ui.get_text("tool|tip_item_time3"))
    else
      return ui_widget.merge_mtf({
        hour = math.floor(t / 3600)
      }, ui.get_text("tool|tip_item_time3_0"))
    end
  else
    local hour = math.mod(t, 86400) / 3600
    if hour == 0 then
      return ui_widget.merge_mtf({
        day = math.floor(t / 86400)
      }, ui.get_text("tool|tip_item_time4"))
    else
      return ui_widget.merge_mtf({
        day = math.floor(t / 86400),
        hours = math.floor(hour)
      }, ui.get_text("tool|tip_item_time5"))
    end
  end
end
local is_inner = sys.is_file("$cfg/tool/pix_dj2_config.xml")
function ctip_make_item_icon(stk_orig, excel, info)
  local stk = sys.mtf_stack()
  local ncnt = 0
  function push_newline()
    ncnt = ncnt + 1
    if ncnt == 1 then
      return
    end
    stk:raw_push(cs_tip_newline)
  end
  if is_inner then
    push_newline()
    ctip_push_text(stk, "ID = " .. excel.id)
  end
  local bound
  if info ~= nil and info:get_data_8(bo2.eItemByte_Bound) == 1 then
    if excel.bound_mode == bo2.eItemBoundMod_Guild then
      bound = ui.get_text("tool|bound_mode_guild")
    else
      bound = ui.get_text("tool|bound")
    end
  elseif excel.bound_mode == bo2.eItemBoundMod_Equip then
    bound = ui.get_text("tool|bound_mode_equip")
  elseif excel.bound_mode == bo2.eItemBoundMod_Consume then
    bound = ui.get_text("tool|bound_mode_use")
  elseif excel.bound_mode == bo2.eItemBoundMod_Acquire then
    bound = ui.get_text("tool|bound_mode_acquire")
  elseif excel.bound_mode == bo2.eItemBoundMod_Guild then
    bound = ui.get_text("tool|bound_mode_guild")
  end
  local ptype = excel.ptype
  if ptype ~= nil or bound ~= nil then
    push_newline()
    if ptype ~= nil then
      ctip_push_text(stk, ptype.name)
    end
    if bound ~= nil then
      local seal_text, may_deal
      if info ~= nil then
        local seal = info:get_data_8(bo2.eItemByte_ReleaseBoundLock)
        if seal == 1 then
          seal_text = ui.get_text("tool|sealed_text")
          may_deal = ui.get_text("tool|seal_deal")
        elseif sys.check(excel) then
          local seal_excel = bo2.gv_equip_release_bound:find(excel.id)
          if sys.check(seal_excel) then
            seal_text = ui.get_text("tool|seal")
          end
        end
      end
      if seal_text == nil then
        stk:raw_push("<space:0.5>")
      end
      if seal_text ~= nil then
        if may_deal ~= nil then
          stk:raw_push("<space:0.5>")
          ctip_push_text(stk, seal_text, cs_tip_color_gold)
          push_newline()
          ctip_push_text(stk, may_deal, cs_tip_color_gold)
        else
          push_newline()
          ctip_push_text(stk, bound, cs_tip_color_bound)
          ctip_push_text(stk, seal_text, cs_tip_color_bound)
        end
      else
        ctip_push_text(stk, bound, cs_tip_color_bound)
      end
    end
  end
  reqlevel = excel.reqlevel
  if 0 >= reqlevel and not sys.is_type(excel, cs_tip_mb_data_equip_item) then
  else
    local color
    if ctip_get_atb(bo2.eAtb_Level) < reqlevel then
      color = cs_tip_color_red
    end
    push_newline()
    ctip_push_text(stk, ui.get_text("tool|tip_item_lvl_req") .. sys.format("%d", reqlevel), color)
  end
  if not sys.is_type(excel, cs_tip_mb_data_equip_item) then
  else
    reqxinfa = excel.reqxinfa
    if 0 >= reqxinfa then
    else
      local xinfaLv = bo2.GetZhuZhiXinFaLevel()
      local color
      if xinfaLv < reqxinfa then
        color = cs_tip_color_red
      end
      push_newline()
      ctip_push_text(stk, ui.get_text("tool|tip_item_xiuwei_req") .. sys.format("%d", reqxinfa), color)
    end
  end
  do
    local consume_mode = excel.consume_mode
    if consume_mode == bo2.eItemConsumeMod_Stack then
      push_newline()
      txt = ui.get_text("tool|tip_item_maxnum") .. sys.format("%d", excel.consume_par)
      if info ~= nil and info.box == bo2.eItemBox_Bank then
        local val = excel.consume_par * 2
        txt = ui.get_text("tool|tip_item_store_limit") .. sys.format("%d", val)
      end
      ctip_push_text(stk, txt)
    elseif consume_mode == bo2.eItemConsumeMod_Avoid then
      push_newline()
      ctip_push_text(stk, ui.get_text("tool|tip_item_never_broken"), cs_tip_color_gold)
    else
      push_newline()
      stk:push(ui.get_text("tool|tip_item_durability"))
      if info == nil or info.goods ~= nil or info.box == bo2.eItemBox_Chest then
        stk:raw_format("%d", excel.consume_par)
      else
        local value = info:get_data_32(bo2.eItemUInt32_CurWearout)
        local limit = info:get_data_32(bo2.eItemUInt32_MaxWearout)
        if limit > 1 and value / limit < 0.3 then
          stk:raw_format("<c+:FF0000>%d/%d<c->", value, limit)
        else
          stk:raw_format("%d/%d", value, limit)
        end
      end
      if consume_mode == bo2.eItemConsumeMod_Wearout0 then
        stk:format("(%s)", ui.get_text("tool|tip_item_cant_repair"))
      elseif (consume_mode == bo2.eItemConsumeMod_Wearout2 or consume_mode == bo2.eItemConsumeMod_Wearout1) and info ~= nil and excel.reqlevel >= 40 and info:get_data_8(bo2.eItemByte_RecognizedCounted) == 0 then
        local limit = info:get_data_32(bo2.eItemUInt32_MaxWearout)
        local consume_par = excel.consume_par
        stk:raw_format(ui_widget.merge_mtf({max_wearout = consume_par}, ui.get_text("tool|equip_max_wearout")))
      end
    end
  end
  if not sys.is_type(excel, cs_tip_mb_data_equip_item) then
  elseif info ~= nil and info.goods == nil then
    local identify_type = info:get_identify_state()
    if identify_type == bo2.eIdentifyEquip_Ready then
      push_newline()
      ctip_push_text(stk, ui.get_text("tool|tip_item_identifiable"), cs_tip_color_red)
      break
    elseif identify_type == bo2.eIdentifyEquip_Countine then
      push_newline()
      ctip_push_text(stk, ui.get_text("tool|tip_item_continue_identifiable"), cs_tip_color_red)
      break
    else
      if identify_type == bo2.eIdentifyEquip_Finish then
      else
      end
    end
  else
    if info ~= nil and info.goods ~= nil and (0 < excel.ident_star or excel.ident_star == 0 and excel.identifypunch ~= 0 and excel.initialholes == 0 or 1 < excel.ass_upgrade.size) then
      push_newline()
      ctip_push_text(stk, ui.get_text("tool|tip_item_can_identify"), cs_tip_color_red)
    else
    end
  end
  inventory_lmt = excel.inventory_lmt
  if 0 < inventory_lmt then
    local txt
    if inventory_lmt == 1 then
      txt = ui.get_text("tool|tip_item_unique")
    else
      txt = ui.get_text("tool|tip_item_unique") .. sys.format("(%d)", inventory_lmt)
    end
    if ptype == nil then
      txt = cs_tip_newline .. txt
    else
      txt = cs_tip_space .. txt
    end
    ctip_push_text(stk, txt, nil, cs_tip_a_add_r)
  end
  local function gems_bound_describe()
    if excel == nil then
      return
    end
    if sys.is_type(excel, cs_tip_mb_data_gem_item) ~= true then
      return
    end
    if excel.bound_mode == bo2.eItemBoundMod_Acquire then
    end
  end
  gems_bound_describe()
  stk_orig:raw_format([[

<cii:%d,]], excel.id)
  stk_orig:push(stk.text)
  stk_orig:raw_push(">")
end
function ctip_make_item_equip_model(stk_orig, info)
  if info == nil then
    return
  end
  local excel_id = info:get_data_32(bo2.eItemUint32_EquipModel)
  if excel_id == 0 then
    return
  end
  local excel = ui.item_get_excel(excel_id)
  if excel == nil then
    return
  end
  local stk = sys.mtf_stack()
  local ncnt = 0
  function push_newline()
    ncnt = ncnt + 1
    if ncnt == 1 then
      return
    end
    stk:raw_push(cs_tip_newline)
  end
  stk:raw_format("<c+:EBCC4F>%s<c->", ui.get_text("item_equip_model|func_name"))
  stk:raw_format([[

<i:%d>]], excel_id)
  local time = info:get_data_32(bo2.eItemUint32_EquipModelTime)
  if time == 0 then
    stk:push(ui.get_text("tool|effective_time_permanent"))
  else
    local st = bo2.get_server_time()
    stk:push("\n")
    stk:push(ui.get_text("tool|effective_time"))
    if time <= st then
      stk:raw_format("<c+:FF0000>%s<c->", ui.get_text("personal|expired"))
    else
      stk:raw_push("<c+:00FF00>")
      stk:raw_push(ctip_time_text(time - st))
      stk:raw_push("<c->")
    end
  end
  if is_inner then
    ctip_push_text(stk, [[

ID = ]] .. excel.id)
  end
  ctip_push_sep(stk_orig)
  stk_orig:raw_format("<cii2:%d,", excel.id)
  stk_orig:push(stk.text)
  stk_orig:raw_push(">")
end
local gem_slot_type = {}
gem_slot_type[bo2.eItemSlot_Hat] = ui.get_text("tool|gem_type_dragon")
gem_slot_type[bo2.eItemSlot_Feet] = ui.get_text("tool|gem_type_dragon")
gem_slot_type[bo2.eItemSlot_MainWeapon] = ui.get_text("tool|gem_type_dragon")
gem_slot_type[bo2.eItemSlot_Relic] = ui.get_text("tool|gem_type_dragon")
gem_slot_type[bo2.eItemSlot_RidePetWeapon] = ui.get_text("tool|gem_type_dragon")
gem_slot_type[bo2.eItemSlot_RidePetHead] = ui.get_text("tool|gem_type_dragon")
gem_slot_type[bo2.eItemSlot_RidePetRidge] = ui.get_text("tool|gem_type_dragon")
gem_slot_type[bo2.eItemSlot_RidePetLeg] = ui.get_text("tool|gem_type_dragon")
gem_slot_type[bo2.eItemSlot_Glove] = ui.get_text("tool|gem_type_tiger")
gem_slot_type[bo2.eItemSlot_2ndWeapon] = ui.get_text("tool|gem_type_tiger")
gem_slot_type[bo2.eItemSlot_Neck] = ui.get_text("tool|gem_type_tiger")
gem_slot_type[bo2.eItemSlot_Finger] = ui.get_text("tool|gem_type_tiger")
gem_slot_type[bo2.eItemSlot_Body] = ui.get_text("tool|gem_type_phoenix")
gem_slot_type[bo2.eItemSlot_Legs] = ui.get_text("tool|gem_type_phoenix")
gem_slot_type[bo2.eItemSlot_Waist] = ui.get_text("tool|gem_type_phoenix")
gem_slot_type[bo2.eItemSlot_Wrists] = ui.get_text("tool|gem_type_phoenix")
gem_slot_type[bo2.eItemSlot_Avatar_Hat] = ui.get_text("tool|gem_type_bird")
gem_slot_type[bo2.eItemSlot_Avatar_Body] = ui.get_text("tool|gem_type_bird")
gem_slot_type[bo2.eItemSlot_Wing] = ui.get_text("tool|gem_type_bird")
gem_slot_type[bo2.eItemSlot_Ornament] = ui.get_text("tool|gem_type_dragon")
function ctip_make_item_gem(stk, info, idx, excel)
  local id = info:get_data_32(bo2.eItemUInt32_GemBeg + idx)
  if id == 0 then
    if idx > 0 then
      stk:raw_push("\n")
    end
    stk:raw_push("<img:$image/mtf/pic_gem_empty.png*16,16> ")
    local ptype = excel.ptype
    if ptype == nil then
      return
    end
    stk:raw_push(gem_slot_type[ptype.equip_slot])
    return
  end
  local gem = bo2.gv_gem_item:find(id)
  if gem == nil then
    return
  end
  local datas = gem.datas
  local cnt = datas.size
  if cnt == 0 then
    return
  end
  if idx > 0 then
    stk:raw_push("\n")
  end
  stk:raw_format("<scii:%d>\n", id)
  for i = 0, cnt - 1 do
    stk:raw_format("  ")
    ctip_push_text(stk, ctip_trait_text(datas[i]), cs_tip_color_green)
  end
end
function ctip_make_item_jingshi(stk, info, idx, excel)
  local id = info:get_data_32(bo2.eItemUInt32_DiaowenBeg + idx)
  if idx > 0 then
    stk:raw_push("\n")
  end
  if id == 0 then
    stk:raw_push("<img:$image/mtf/pic_gem_empty.png*16,16> ")
    stk:raw_push(ui.get_text("tool|not_have_jingshi"))
  else
    local jingshi = bo2.gv_item_list:find(id)
    if jingshi == nil then
      return
    end
    stk:raw_format("<scii:%d>", id)
  end
  local max_wearout = info:get_data_32(bo2.eItemUInt32_JingshiMaxWearoutBeg + idx)
  local cur_wearout = info:get_data_32(bo2.eItemUInt32_JingshiCurWearoutBeg + idx)
  ctip_push_text(stk, sys.format("%s/%s", cur_wearout, max_wearout), cs_tip_color_green, cs_tip_a_add_r)
end
function get_trait(id)
  if id < 1 then
    return
  end
  return bo2.gv_trait_list:find(id)
end
function get_trait_ass(id)
  if id < 1 then
    return
  end
  return bo2.gv_assistant_upgrade:find(id)
end
function is_tattoo(excel)
  if excel.type >= bo2.eItemType_Tattoo and excel.type < bo2.eItemType_TattooEnd then
    return true
  end
  return false
end
function get_sec_quality(excel, prop_id)
  local quality = 0
  for i = 0, excel.common_pool.size - 1 do
    if excel.common_pool[i] == prop_id then
      quality = ui.get_text("tool|quality_type_normal")
      return quality
    end
  end
  for i = 0, excel.great_pool.size - 1 do
    if excel.great_pool[i] == prop_id then
      quality = ui.get_text("tool|quality_type_good")
      return quality
    end
  end
  for i = 0, excel.perfect_pool.size - 1 do
    if excel.perfect_pool[i] == prop_id then
      quality = ui.get_text("tool|quality_type_polish")
      return quality
    end
  end
  for i = 0, excel.rare_pool.size - 1 do
    if excel.rare_pool[i] == prop_id then
      quality = ui.get_text("tool|quality_type_epic")
      return quality
    end
  end
  for i = 0, excel.unique_pool.size - 1 do
    if excel.unique_pool[i] == prop_id then
      quality = ui.get_text("tool|quality_type_legend")
      return quality
    end
  end
end
local ctip_atb_range_def = {
  atb_phy_dmg = {
    desc = ui.get_text("tool|damage_type_physical"),
    min = bo2.eMdf_Base_PhyDmgMin,
    max = bo2.eMdf_Base_PhyDmgMax
  },
  atb_mgc_dmg = {
    desc = ui.get_text("tool|damage_type_magic"),
    min = bo2.eMdf_Base_MgcDmgMin,
    max = bo2.eMdf_Base_MgcDmgMax
  }
}
local ctip_atb_range = {}
for n, v in pairs(ctip_atb_range_def) do
  v.name = n
  v.title = ui.get_text("atb|name_" .. n)
  ctip_atb_range[v.min] = v
  ctip_atb_range[v.max] = v
end
function ctip_atb_set_create()
  return {}
end
function ctip_atb_set_insert(s, id, fChg)
  local trait = bo2.gv_trait_list:find(id)
  if trait == nil then
    return nil
  end
  local modify_id = trait.modify_id
  local modify_value = trait.modify_value
  if fChg ~= nil and type(fChg) == "number" then
    modify_value = math.floor(modify_value * fChg / 100)
  end
  local range = ctip_atb_range[modify_id]
  if range == nil then
    local d = {}
    table.insert(s, d)
    d.desc = trait.desc
    if d.desc.size == 0 then
      d.desc = ctip_trait_text_ex(modify_id, modify_value)
      d.modify_id = modify_id
      d.modify_value = modify_value
    end
    d.count = 1
    return
  end
  local d
  for n, v in ipairs(s) do
    if v.range == range then
      d = v
      break
    end
  end
  if d == nil then
    d = {}
    table.insert(s, d)
    local desc = trait.desc
    if desc.size > 0 then
      d.desc = desc
    end
    d.desc = ctip_trait_text_ex(modify_id, modify_value)
    d.range = range
    d.count = 0
  end
  d.count = d.count + 1
  if modify_id == range.min then
    if d.min == nil then
      d.min = modify_value
    else
      d.min = d.min + modify_value
    end
  elseif d.max == nil then
    d.max = modify_value
  else
    d.max = d.max + modify_value
  end
end
function ctip_atb_set_output(s, stk, secondtxt, enforcetxt, rmtxt, color)
  local newline_cnt = 0
  local function push_newline()
    if newline_cnt == 0 then
      newline_cnt = newline_cnt + 1
    else
      ctip_push_newline(stk)
    end
  end
  local function push_traits(txt)
    push_newline()
    local t_color = cs_tip_color_green
    if color then
      t_color = color
    end
    ctip_push_text(stk, txt, t_color)
  end
  for n, d in ipairs(s) do
    if d.count == 1 then
      push_traits(d.desc)
    elseif d.min == nil then
      push_traits(ctip_trait_text_ex(d.range.max, d.max))
    elseif d.max == nil then
      push_traits(ctip_trait_text_ex(d.range.min, d.min))
    else
      push_traits(sys.format("%s%d-%d", d.range.desc, d.min, d.max))
    end
    if secondtxt ~= nil then
      stk:raw_push(secondtxt)
    end
    if enforcetxt ~= nil then
      stk:raw_push(enforcetxt)
    end
  end
  if rmtxt ~= nil then
    push_newline()
    stk:raw_push(rmtxt)
  end
end
function ctip_atb_set_build(datas, secondtxt, enforcetxt, rmtxt)
  local cnt = data.size
  local atb_set = ctip_atb_set_create()
  for i = 0, cnt - 1 do
    ctip_atb_set_insert(atb_set, datas[i])
  end
  ctip_atb_set_output(atb_set, stk, secondtxt, enforcetxt, rmtxt)
end
function sort_trait_packet(pack, modify_id, level)
  local trait_sort_fn = function(a, b)
    return a.value > b.value
  end
  local v = pack[modify_id]
  local color_size = bo2.gv_trait_color.size
  table.sort(v, trait_sort_fn)
  local k = modify_id
  for m, n in pairs(v) do
    local id = m
    local m_color = bo2.gv_trait_color:find(id)
    if m_color then
      n.color = m_color.color[level]
    else
      n.color = SHARED("0000FF")
    end
  end
end
function pre_process_trait_packet(build_packet, modify_id)
  local is_sort = false
  for k, v in pairs(build_packet[modify_id]) do
    if v.sort == false then
      sort_trait_packet(build_packet, modify_id, v.level)
      is_sort = true
    end
    break
  end
  if is_sort == true then
    for k, v in pairs(build_packet[modify_id]) do
      v.sort = true
    end
  end
end
function get_trait_color(build_packet, modify_id, modify_value)
  if build_packet == nil then
    return cs_tip_color_green
  end
  if build_packet[modify_id] == nil then
    return cs_tip_color_green
  end
  pre_process_trait_packet(build_packet, modify_id)
  for k, v in pairs(build_packet[modify_id]) do
    if v.value == math.abs(modify_value) then
      return v.color
    end
  end
  return cs_tip_color_green
end
function get_trait_color_packet(excel, star)
  local build_packet = {}
  local function BuildTraitPacket(star)
    local m_star = bo2.gv_equip_star:find(excel.ident_star)
    if m_star == nil then
      return false
    end
    local iPoolID = m_star.pool_id[star - 1]
    if iPoolID == nil then
      return false
    end
    local color_packet = {}
    local m_pool = bo2.gv_trait_pool:find(iPoolID)
    if m_pool == nil then
      return
    end
    for i = 0, 3 do
      if m_pool.prob[i] ~= 0 then
        for j = 0, m_pool.packets[i].size - 1 do
          local m_trait_packet = bo2.gv_trait_packet:find(m_pool.packets[i][j])
          if m_trait_packet ~= nil then
            for m = 0, m_trait_packet.traits.size - 1 do
              local m_data = m_trait_packet.traits[m]
              local m_trait = bo2.gv_trait_list:find(m_data)
              if m_trait ~= nil and not color_packet[m_trait.id] then
                color_packet[m_trait.id] = true
                if build_packet[m_trait.modify_id] == nil then
                  build_packet[m_trait.modify_id] = {}
                end
                table.insert(build_packet[m_trait.modify_id], {
                  id = m_trait.id,
                  value = math.abs(m_trait.modify_value),
                  sort = false,
                  level = math.floor(excel.lootlevel / 10)
                })
              elseif m_trait == nil then
                ui.log("m_trait_packet.traits[m]" .. m_data)
              end
            end
          end
        end
      end
    end
  end
  BuildTraitPacket(star)
  return build_packet
end
function get_trait_upgrade(build_packet, new_packet, modify_id, modify_value)
  if build_packet == nil or new_packet == nil then
    return modify_id, modify_value, 0
  end
  if build_packet[modify_id] == nil or new_packet[modify_id] == nil then
    local id = 0
    if build_packet[modify_id] ~= nil then
      id = build_packet[modify_id].id
    end
    return modify_id, modify_value, id
  end
  pre_process_trait_packet(build_packet, modify_id)
  pre_process_trait_packet(new_packet, modify_id)
  local abs_val = math.abs(modify_value)
  local count = 0
  for k, v in pairs(build_packet[modify_id]) do
    if v.value == abs_val then
      local new_count = 0
      for m, n in pairs(new_packet[modify_id]) do
        if new_count == count then
          return modify_id, n.value, n.id
        end
        new_count = new_count + 1
      end
    end
    count = count + 1
  end
  return modify_id, modify_value, build_packet[modify_id].id
end
function is_equip_upgrade_max(info)
  if info == nil or info.excel == nil then
    return false
  end
  local ex_data = {}
  ex_data.only_base = 1
  local upgrade_data = get_equip_upgrade_data(info, info.excel, ex_data)
  if upgrade_data == nil or upgrade_data.cur_stage ~= upgrade_data.cur_max then
    return false
  end
  return true
end
function get_equip_upgrade_data(info, excel, ex_data)
  if sys.check(ui_npcfunc) ~= true then
    return nil
  end
  if info == nil then
    return nil
  end
  local item_id = excel.id
  local data = {}
  data.line = ui_npcfunc.ui_equip_trait_upgrade.get_equip_upgrade_line(item_id)
  if data.line == nil then
    return nil
  end
  local identify_type = info:get_identify_state()
  if identify_type ~= bo2.eIdentifyEquip_Finish then
    return nil
  end
  data.param = ui_npcfunc.ui_equip_trait_upgrade.get_equip_upgrade_param(info, data.line)
  if data.line == nil then
    return nil
  end
  if ex_data ~= nil and ex_data.only_param ~= nil then
    return data
  end
  data.exp = info:get_data_32(bo2.eItemUint32_EquipTraitExp)
  if ex_data ~= nil and ex_data.add_value ~= nil then
    data.exp = data.exp + ex_data.add_value
  end
  if data.exp == 0 then
    return nil
  end
  data.cur_max = data.param.level_max
  data.cur_stage, data.cur_value = ui_npcfunc.ui_equip_trait_upgrade.get_stage_value(data.param, data.exp)
  data.base_persent = 0
  for i = 0, data.cur_stage - 1 do
    data.base_persent = data.param.base_trait_persent[i] + data.base_persent
  end
  if data.cur_stage ~= data.cur_max then
    local data_stage = data.cur_stage
    if data_stage > 1 then
      data_stage = data_stage - 1
    end
    local total = data.param.base_trait_persent[data_stage]
    local exp = data.param.level_exp
    local cur_value = data.cur_value
    local cur_stage = data.param.level_stage
    local single_persent = total / cur_stage
    local per_value = exp / cur_stage
    for i = 0, cur_stage - 1 do
      if cur_value >= per_value then
        data.base_persent = single_persent + data.base_persent
        cur_value = cur_value - per_value
      else
        break
      end
    end
  end
  if ex_data ~= nil and ex_data.only_base ~= nil then
    return data
  end
  data.stage_text = ui_npcfunc.ui_equip_trait_upgrade.get_stage_text(data.cur_stage)
  local id_star = 0
  if 0 < data.cur_stage then
    local target_excel_id = data.param.equip_star[data.cur_stage - 1]
    local target_excel = bo2.gv_equip_item:find(target_excel_id)
    if target_excel == nil then
      return data
    end
    id_star = target_excel.ident_star
  end
  data.temp_excel = {}
  data.temp_excel.ident_star = id_star
  data.temp_excel.lootlevel = excel.lootlevel
  local function do_update_data()
    data.trait_packet = get_trait_color_packet(data.temp_excel, info.star)
  end
  do_update_data()
  data.build_packet = get_trait_color_packet(excel, info.star)
  return data
end
local get_recognized_data = function(rmval)
  local eff_txt
  local color = cs_tip_color_bound
  local color_count = 13
  if rmval >= 5 and rmval <= 9 then
    eff_txt = ui.get_text("tool|normal_recognized_master")
  elseif rmval >= 10 and rmval <= 14 then
    eff_txt = ui.get_text("tool|good_recognized_master")
    color_count = color_count + 1
  elseif rmval >= 15 and rmval <= 18 then
    eff_txt = ui.get_text("tool|excellent_recognized_master")
    color_count = color_count + 2
  else
    eff_txt = ui.get_text("tool|perfect_recognized_master")
    color_count = color_count + 3
  end
  local lootlevel = bo2.gv_lootlevel:find(color_count)
  if lootlevel ~= nil then
    color = lootlevel.color
  end
  return eff_txt, color
end
local get_effect_data = function(final_pre)
  local effect
  local color = cs_tip_color_bound
  local color_count = 13
  if final_pre >= 0 and final_pre <= 25 then
    effect = ui.get_text("tool|normal_enforce")
  elseif final_pre > 25 and final_pre <= 35 then
    effect = ui.get_text("tool|good_enforce")
    color_count = color_count + 1
  elseif final_pre > 35 and final_pre <= 45 then
    effect = ui.get_text("tool|excellent_enforce")
    color_count = color_count + 2
  elseif final_pre > 45 then
    effect = ui.get_text("tool|perfect_enforce")
    color_count = color_count + 3
  end
  local lootlevel = bo2.gv_lootlevel:find(color_count)
  if lootlevel ~= nil then
    color = lootlevel.color
  end
  return effect, color
end
function ctip_make_avata_enchant(stk, excel, info)
  local ptype = excel.ptype
  if not bo2.IsOpenAvataEnchant() or ptype == nil or info == nil then
    return
  end
  if ptype.group == bo2.eItemGroup_Avata then
    if excel.life_mode ~= 0 or 0 < info:get_data_32(bo2.eItemUInt32_RenewalDays) then
      return
    end
  elseif excel.iuse == nil or excel.iuse.model ~= bo2.eUseMod_AvataInsetEnchant then
    return
  end
  local iSlotNum = info:get_data_32(bo2.eItemUInt32_AvataEnchant_SlotNum)
  local iTraitNum = 0
  local iPerfectNum = 0
  ctip_push_sep(stk)
  local stkTrait = sys.mtf_stack()
  if iSlotNum > 0 then
    local iSlotStart = bo2.eItemUInt32_AvataEnchant_Begin
    local iSlotEnd = iSlotStart + iSlotNum - 1
    for i = iSlotStart, iSlotEnd do
      local value = info:get_data_32(i)
      if value > 0 then
        local enchant_id = bo2.bit_and(value, 16777215)
        local level = bo2.bit_rshift(value, 24)
        if level == 5 then
          iPerfectNum = iPerfectNum + 1
        end
        local enchant_excel = bo2.gv_avata_equip_enchant:find(enchant_id)
        local trait_id = enchant_excel.trait[level - 1]
        local desc, color = ctip_trait_text(trait_id)
        if color == nil then
          color = cs_tip_color_green
        end
        if 0 < enchant_excel.icon.size then
          stkTrait:raw_format("<imt:$%s*18,18*", enchant_excel.icon)
        else
          stkTrait:raw_push("<imt:$image/mtf/pic_gem_empty.png*18,18*")
        end
        local stktext = sys.mtf_stack()
        ui_tool.ctip_push_text(stktext, desc, color)
        stkTrait:push(stktext.text)
        stkTrait:raw_push(">")
        stkTrait:raw_push(SHARED("\n"))
        iTraitNum = iTraitNum + 1
      else
        stkTrait:raw_push("<img_bg:$image/mtf/pic_gem_empty.png*2**20,20>")
        stkTrait:raw_format("<mid_lb:plain,14,,%s,20|%s>", SHARED("ffffff"), ui.get_text("equip|avata_enchant_slot"))
        stkTrait:raw_push(SHARED("\n"))
      end
    end
  end
  if ptype.group == bo2.eItemGroup_Avata then
    ctip_push_text(stk, sys.format("%s(%d/%d)", ui.get_text("equip|avata_enchant"), iTraitNum, iSlotNum), nil, cs_tip_a_add_m)
  else
    ctip_push_text(stk, sys.format("%s(%d/%d)", ui.get_text("equip|avata_enchant_record"), iTraitNum, iSlotNum), nil, cs_tip_a_add_m)
  end
  stk:raw_push(SHARED("\n"))
  stk:raw_push(stkTrait.text)
  local enchat_set = bo2.gv_avata_equip_enchant_set:find(excel.id)
  if enchat_set == nil or enchat_set.trait[0] == 0 then
    return
  end
  local stkTraitSet = sys.mtf_stack()
  local trait_set_num = enchat_set.trait.size
  local needPerfectNum = 0
  local showSet = false
  for i = 0, trait_set_num - 1 do
    local iTrait = enchat_set.trait[i]
    if iTrait ~= 0 then
      local trait_text = ctip_trait_text(iTrait)
      local color = cs_tip_color_set_no
      needPerfectNum = enchat_set.level[i]
      if iPerfectNum >= needPerfectNum then
        color = cs_tip_color_set_has
      end
      local txt = ui_widget.merge_mtf({num = needPerfectNum, des = trait_text}, ui.get_text("tool|suit_avata_property"))
      ctip_push_text(stkTraitSet, txt, color)
      showSet = true
    end
  end
  if not showSet then
    return
  end
  ctip_push_sep(stk)
  local txt = ui_widget.merge_mtf({num = iPerfectNum, max = needPerfectNum}, ui.get_text("tool|avata_enchant_perfect"))
  ctip_push_text(stk, txt, nil, cs_tip_a_add_m)
  stk:raw_push(stkTraitSet.text)
  stk:raw_push(SHARED("\n"))
end
function ctip_make_item_atb(stk, excel, info, card, upgrade_data)
  local newline_cnt = 0
  local function push_newline()
    if newline_cnt == 0 then
      newline_cnt = newline_cnt + 1
    else
      ctip_push_newline(stk)
    end
  end
  local function reset_newline()
    newline_cnt = 0
  end
  local function push_traits(txt, color)
    push_newline()
    local t_color = cs_tip_color_green
    if color then
      t_color = color
    end
    ctip_push_text(stk, txt, t_color)
  end
  local function push_group(txt)
    ctip_push_sep(stk)
    reset_newline()
    ctip_push_text(stk, txt .. cs_tip_newline, nil, cs_tip_a_add_m)
  end
  if is_tattoo(excel) or sys.is_type(excel, cs_tip_mb_data_gem_item) then
    local datas = excel.datas
    local cnt = datas.size
    if cnt == 0 then
    else
      for i = 0, cnt - 1 do
        ctip_push_text(stk, cs_tip_newline .. ctip_trait_text(datas[i]))
      end
    end
  end
  if not sys.is_type(excel, cs_tip_mb_data_equip_item) then
    return
  end
  if info ~= nil then
    local star = info.star
    if star > 0 then
      ctip_push_sep(stk)
      stk:raw_format("<a+:m><star:%d><a->", star)
    end
  end
  do
    local ptype = excel.ptype
    if ptype == nil then
    elseif info ~= nil and excel.ass_upgrade.size ~= 0 then
      local exp = 0
      local level = 1
      if info.goods == nil then
        exp = info:get_data_32(bo2.eItemUInt32_SecondExp)
        level = info:get_data_32(bo2.eItemUInt32_SecondLevel)
      end
      local al = bo2.gv_assistant_level:find(level)
      if al ~= nil then
        ctip_push_sep(stk)
        ctip_push_text(stk, ui.get_text("tool|minor_growing_level") .. sys.format("%s\n", al.id))
        local ass_upgrade_id = info:get_data_8(bo2.eItemByte_AssUpgradeID)
        if ass_upgrade_id > 0 then
          local ae = bo2.gv_assistant_upgrade:find(ass_upgrade_id)
          if ae ~= nil then
            ctip_push_text(stk, ui.get_text("tool|minor_growing_exp") .. sys.format("%s/%s", exp, al.exp[ae.exp_id]))
          end
        end
      end
    end
  end
  local function build_upgrade_desc(upgrade_data)
    if upgrade_data == nil then
      return
    end
    ctip_push_sep(stk)
    ctip_push_text(stk, ui.get_text("equip|cur_stage"))
    local txt = sys.format(L("%s\n"), upgrade_data.stage_text)
    local color
    local excel_color = bo2.gv_lootlevel:find(12 + upgrade_data.cur_stage)
    if excel_color ~= nil then
      color = excel_color.color
    end
    ctip_push_text(stk, txt, color)
    ctip_push_text(stk, ui.get_text("equip|cur_exp"))
    txt = sys.format(L("%d"), upgrade_data.cur_value)
    ctip_push_text(stk, txt)
    txt = sys.format(L("/%d\n"), upgrade_data.param.level_exp)
    ctip_push_text(stk, txt)
  end
  local function upgrade_desc()
    if upgrade_data == nil then
      if sys.check(info) ~= true or sys.check(excel) ~= true then
        return
      end
      local ex_data = {}
      ex_data.only_param = 1
      local fake_upgrade = get_equip_upgrade_data(info, excel, ex_data)
      if fake_upgrade ~= nil and sys.check(fake_upgrade.param) then
        fake_upgrade.cur_value = 0
        fake_upgrade.cur_stage = 0
        fake_upgrade.stage_text = ui.get_text(L("equip|stage_disable"))
        build_upgrade_desc(fake_upgrade)
      end
      return
    end
    build_upgrade_desc(upgrade_data)
  end
  upgrade_desc()
  do
    local ptype = excel.ptype
    if ptype == nil then
    elseif excel.ass_upgrade.size ~= 0 and ptype.group ~= bo2.eItemGroup_Avata then
      local secondtxt
      if info ~= nil and info.goods == nil then
        local secondlevel = info:get_data_32(bo2.eItemUInt32_SecondLevel)
        if secondlevel >= 1 then
          local grow_point = info:get_data_32(bo2.eItemUInt32_SecondGrowRank)
          if grow_point < 0 then
            secondtxt = sys.format("<a+:r><c+:224499>%s+%d<c-><a->", cs_tip_space, -grow_point * (secondlevel - 1))
          else
            secondtxt = sys.format("<a+:r><c+:224499>%s+%d<c-><a->", cs_tip_space, grow_point * (secondlevel - 1))
          end
          if secondtxt ~= nil then
            local ass_upgrade_id = info:get_data_8(bo2.eItemByte_AssUpgradeID)
            local temp_excel = bo2.gv_assistant_upgrade:find(ass_upgrade_id)
            if temp_excel then
              ctip_push_sep(stk)
              ctip_push_text(stk, ui.get_text("tool|minor_growing_property"), nil, cs_tip_a_add_m)
              if secondlevel == 1 then
                ctip_push_newline(stk)
                if ptype.equip_slot == bo2.eItemSlot_RidePetWeapon then
                  ctip_push_text(stk, ui.get_text("tool|ridepet_growing_des"))
                else
                  ctip_push_text(stk, ui.get_text("tool|minor_growing_des"))
                end
              else
                local color = cs_tip_color_green
                if sys.check(info) then
                  local identify_type = info:get_identify_state()
                  if identify_type == bo2.eIdentifyEquip_Finish then
                    local plootlevel_star = info.plootlevel_star
                    if plootlevel_star ~= nil then
                      color = plootlevel_star.color
                    end
                  end
                end
                for i = 0, temp_excel.modify_id.size - 1 do
                  local modify_player = bo2.gv_modify_player:find(temp_excel.modify_id[i])
                  if modify_player == nil then
                    return
                  end
                  ctip_push_newline(stk)
                  ctip_push_text(stk, modify_player.name, color)
                  if 0 < info:get_xdata_32(bo2.eItemXData32_GrowPointMax) then
                    ctip_push_text(stk, sys.format("(%d-%d)", info:get_xdata_32(bo2.eItemXData32_GrowPointMin) + grow_point, info:get_xdata_32(bo2.eItemXData32_GrowPointMax) + grow_point, color))
                  else
                    ctip_push_text(stk, sys.format("+%d", grow_point), color)
                  end
                end
              end
              local enforcetxt
              local enforcelvl = 0
              if info ~= nil then
                enforcelvl = info:get_data_8(bo2.eItemByte_EnforceLvl)
                if enforcelvl > 0 then
                  local enforce = bo2.gv_equip_enforce_cent:find(excel.ptype.equip_slot)
                  if enforce ~= nil then
                    enforcetxt = sys.format("<a+:r><c+:22AA66>%s+%d%%<c-><a->", cs_tip_space, enforce.enforce[enforcelvl - 1])
                  end
                end
              end
              enforcetxt = nil
              for i = 0, temp_excel.modify_id.size - 1 do
                local atb_set = ctip_atb_set_create()
                ctip_atb_set_insert(atb_set, temp_excel.modify_id[i])
              end
              local rmtxt
              local rmval = 0
              if info ~= nil then
                rmval = info:get_data_32(bo2.eItemUInt32_RecognizedMasterVal)
                if rmval > 0 then
                  local txt, color = get_recognized_data(rmval)
                  ctip_push_newline(stk)
                  ctip_push_text(stk, txt, color, cs_tip_a_add_l)
                  ctip_push_text(stk, rmval, color, cs_tip_a_add_r)
                  ctip_push_text(stk, L("%"), color, cs_tip_a_add_r)
                end
              end
              if enforcelvl == 1 then
                ctip_push_text(stk, "\n" .. ui.get_text("tool|ready_enforce"), cs_tip_color_red)
              elseif enforcelvl == 2 then
                local acount = info:get_data_8(bo2.eItemByte_EnforceAcount)
                local pre = 0
                if info:get_data_8(bo2.eItemByte_EnforceFlagOldNew) == 0 then
                  pre = info:get_data_8(bo2.eItemByte_EnforcePre)
                else
                  pre = ui.item_get_total_enforce_data(info)
                end
                local EnforceID = info:get_data_8(bo2.eItemByte_EnforceID)
                local excel = bo2.gv_enforce_light:find(EnforceID)
                if excel then
                  local final_pre = acount + pre
                  local effect, effect
                  local color = cs_tip_color_bound
                  effect, color = get_effect_data(final_pre)
                  ctip_push_newline(stk)
                  ctip_push_text(stk, effect, color, cs_tip_a_add_l)
                  ctip_push_text(stk, final_pre, color, cs_tip_a_add_r)
                  ctip_push_text(stk, L("%\n"), color, cs_tip_a_add_r)
                end
              elseif enforcelvl == 0 and info ~= nil then
                local pre = 0
                if info:get_data_8(bo2.eItemByte_EnforceFlagOldNew) == 0 then
                  pre = info:get_data_8(bo2.eItemByte_EnforcePre)
                else
                  pre = ui.item_get_total_enforce_data(info)
                end
                if pre > 0 then
                  local final_pre = pre
                  local effect
                  local color = cs_tip_color_bound
                  effect, color = get_effect_data(final_pre)
                  ctip_push_newline(stk)
                  ctip_push_text(stk, effect, color, cs_tip_a_add_l)
                  ctip_push_text(stk, final_pre, color, cs_tip_a_add_r)
                  ctip_push_text(stk, L("%\n"), color, cs_tip_a_add_r)
                end
              end
            end
          end
        end
      elseif info ~= nil and info.goods ~= nil then
        ctip_push_sep(stk)
        ctip_push_text(stk, ui.get_text("tool|minor_growing_property"), nil, cs_tip_a_add_m)
        ctip_push_newline(stk)
        ctip_push_text(stk, ui.get_text("tool|minor_growing_des"))
      end
    else
      local datas = excel.datas
      local cnt = datas.size
      if cnt == 0 then
      else
        local enforcetxt
        local enforcelvl = 0
        if info ~= nil then
          enforcelvl = info:get_data_8(bo2.eItemByte_EnforceLvl)
          if enforcelvl > 0 then
            local enforce = bo2.gv_equip_enforce_cent:find(excel.ptype.equip_slot)
            if enforce ~= nil then
              enforcetxt = sys.format("<a+:r><c+:22AA66>%s+%d%%<c-><a->", cs_tip_space, enforce.enforce[enforcelvl - 1])
            end
          end
        end
        enforcetxt = nil
        local rmtxt
        local rmval = 0
        if enforcelvl > 0 and enforcetxt ~= nil then
          push_group(ui_widget.merge_mtf({basic_property = enforcelvl}, ui.get_text("tool|basic_property_plus")))
        else
          push_group(ui.get_text("tool|basic_property"))
        end
        local fAddChg = 0
        if info ~= nil then
          local star = info.star
          if star > 0 then
            local pStarAddition = bo2.gv_equip_star_addition:find(excel.reqlevel)
            if pStarAddition ~= nil then
              fAddChg = pStarAddition.rate[star - 1]
            end
          end
        end
        if upgrade_data ~= nil then
          fAddChg = fAddChg + upgrade_data.base_persent / 1000000
        end
        local atb_set = ctip_atb_set_create()
        for i = 0, cnt - 1 do
          ctip_atb_set_insert(atb_set, datas[i], fAddChg * 100 + 100)
        end
        local color
        if sys.check(info) then
          local identify_type = info:get_identify_state()
          if identify_type == bo2.eIdentifyEquip_Finish then
            local plootlevel_star = info.plootlevel_star
            if plootlevel_star ~= nil then
              color = plootlevel_star.color
            end
          end
        end
        ctip_atb_set_output(atb_set, stk, secondtxt, enforcetxt, rmtxt, color)
        if info ~= nil and ptype.group ~= bo2.eItemGroup_Avata then
          rmval = info:get_data_32(bo2.eItemUInt32_RecognizedMasterVal)
          if rmval > 0 then
            local txt, color = get_recognized_data(rmval)
            ctip_push_newline(stk)
            ctip_push_text(stk, txt, color, cs_tip_a_add_l)
            ctip_push_text(stk, rmval, color, cs_tip_a_add_r)
            ctip_push_text(stk, L("%"), color, cs_tip_a_add_r)
          end
        end
        if enforcelvl == 1 then
          ctip_push_text(stk, "\n" .. ui.get_text("tool|ready_enforce"), cs_tip_color_red)
        elseif enforcelvl == 2 then
          local acount = info:get_data_8(bo2.eItemByte_EnforceAcount)
          local pre = 0
          if info:get_data_8(bo2.eItemByte_EnforceFlagOldNew) == 0 then
            pre = info:get_data_8(bo2.eItemByte_EnforcePre)
          else
            pre = ui.item_get_total_enforce_data(info)
          end
          local EnforceID = info:get_data_8(bo2.eItemByte_EnforceID)
          local excel = bo2.gv_enforce_light:find(EnforceID)
          if excel then
            local final_pre = acount + pre
            if final_pre > math.floor(excel.t_h_limit) then
              final_pre = math.floor(excel.t_h_limit)
            end
            local effect
            local color = cs_tip_color_bound
            effect, color = get_effect_data(final_pre)
            ctip_push_newline(stk)
            ctip_push_text(stk, effect, color, cs_tip_a_add_l)
            ctip_push_text(stk, final_pre, color, cs_tip_a_add_r)
            ctip_push_text(stk, L("%\n"), color, cs_tip_a_add_r)
          end
        elseif enforcelvl == 0 and info ~= nil then
          local pre = 0
          if info:get_data_8(bo2.eItemByte_EnforceFlagOldNew) == 0 then
            pre = info:get_data_8(bo2.eItemByte_EnforcePre)
          else
            pre = ui.item_get_total_enforce_data(info)
          end
          if pre > 0 then
            local final_pre = pre
            local effect
            local color = cs_tip_color_bound
            effect, color = get_effect_data(final_pre)
            ctip_push_newline(stk)
            ctip_push_text(stk, effect, color, cs_tip_a_add_l)
            ctip_push_text(stk, final_pre, color, cs_tip_a_add_r)
            ctip_push_text(stk, L("%\n"), color, cs_tip_a_add_r)
          end
        end
      end
    end
  end
  local index_item_slot, excel_data = ui_npcfunc.ui_jingpo_guanzhu.find_index_item_slot(excel.ptype.equip_slot)
  local main_weapon_info
  if index_item_slot ~= -1 then
    main_weapon_info = ui.item_of_coord(bo2.eItemArray_InSlot, excel_data.item_slots[index_item_slot])
  end
  if index_item_slot ~= -1 and main_weapon_info ~= nil and main_weapon_info.only_id == info.only_id then
    local guanzhu_level = bo2.player:get_flag_int64(excel_data.db_jingpo_levels[index_item_slot]).v_int
    if excel_data.item_slots[index_item_slot] == bo2.eItemSlot_MainWeapon then
      guanzhu_level = bo2.player:get_flag_int32(excel_data.db_jingpo_levels[index_item_slot])
    end
    local add_percent = 0
    if guanzhu_level ~= 0 then
      local line = bo2.gv_jingpo_guanzhu:find(guanzhu_level)
      add_percent = line.add_percents[index_item_slot]
    end
    ctip_push_newline(stk)
    ctip_push_text(stk, ui.get_text("tool|jingpo_guanzhu"), cs_tip_color_green, cs_tip_a_add_l)
    ctip_push_text(stk, add_percent, cs_tip_color_green, cs_tip_a_add_r)
    ctip_push_text(stk, L("%\n"), cs_tip_color_green, cs_tip_a_add_r)
  end
  if excel.ptype and excel.ptype.group == bo2.eItemGroup_Avata then
    if info ~= nil and info.goods ~= nil then
      local holes_cnt = excel.initialholes
      if holes_cnt > 0 then
        push_group(ui.get_text("tool|gem_solt"))
      end
      for idx = 0, holes_cnt - 1 do
        if idx > 0 then
          stk:raw_push("\n")
        end
        stk:raw_push("<img:$image/mtf/pic_gem_empty.png*16,16> ")
        local ptype = excel.ptype
        stk:raw_push(gem_slot_type[ptype.equip_slot])
      end
      break
    elseif info ~= nil then
      local holes = info:get_data_8(bo2.eItemByte_Holes)
      if holes <= 0 then
      else
        push_group(ui.get_text("tool|gem_solt"))
        for i = 0, holes - 1 do
          ctip_make_item_gem(stk, info, i, excel)
        end
      end
    end
    return
  end
  if info ~= nil then
  elseif card ~= ui_npcfunc.ui_manuf_equip.w_cell_pdt_pre then
  else
    ctip_push_sep(stk)
    ctip_push_text(stk, ui.get_text("npcfunc|atb_inherit"), "FF0000")
  end
  if info == nil then
  else
    local ptype = excel.ptype
    if ptype == nil then
    elseif ptype.equip_slot == bo2.eItemSlot_2ndWeapon and excel.ass_id ~= 0 and excel.ass_upgrade ~= 0 then
      if info ~= nil and info.goods ~= nil then
        push_group(ui.get_text("tool|minor_soul_property"))
        ctip_push_text(stk, ui.get_text("tool|minor_soul_des"))
        push_group(ui.get_text("tool|rand_prob"))
        ctip_push_text(stk, ui.get_text("tool|rand_prob_5"))
      elseif info ~= nil and info.goods == nil then
        push_group(ui.get_text("tool|minor_soul_property"))
        for i = 0, 4 do
          if info:get_data_32(bo2.eItemUInt32_IdentTraitBeg + i) ~= 0 then
            push_traits(ctip_trait_text(info:get_data_32(bo2.eItemUInt32_IdentTraitBeg + i)))
            local tpl_excel = bo2.gv_second_equip_template:find(excel.ass_id)
            if tpl_excel == nil then
              return
            end
            local index = i + 1
            local pool_id = tpl_excel["prop_pool_stage" .. index][0]
            local pool_excel = bo2.gv_prop_pool:find(pool_id)
            local quality, color = get_sec_quality(pool_excel, info:get_data_32(bo2.eItemUInt32_IdentTraitBeg + i))
            if quality ~= nil then
              quality = sys.format("<a+:r><c+:%s>%s%s<c-><a->", "22AA66", cs_tip_space, quality)
              stk:raw_push(quality)
            end
          elseif i == 0 then
            ctip_push_text(stk, ui.get_text("tool|minor_soul_des"))
          end
        end
        push_group(ui.get_text("tool|rand_prob"))
        local concise = info:get_data_32(bo2.eItemUint32_SecondConcise)
        local concise_type
        if concise == 1 then
          concise_type = ui.get_text("tool|concise_type1")
        elseif concise == 2 then
          concise_type = ui.get_text("tool|concise_type2")
        elseif concise == 3 then
          concise_type = ui.get_text("tool|concise_type3")
        else
          concise_type = ui.get_text("tool|concise_type0")
        end
        concise_type = sys.format("<a+:r><c+:%s>%s%s<c-><a->\n", "22AA66", cs_tip_space, concise_type)
        stk:raw_push(concise_type)
        local traits = {}
        for i = 0, 5 do
          if info:get_data_32(bo2.eItemUint32_SecondRProBeg + i) ~= 0 then
            for j = 0, 3 do
              local id = bo2.get_sw_rand(info:get_data_32(bo2.eItemUint32_SecondRProBeg + i), j)
              if id ~= 0 then
                local e = bo2.gv_sw_rand_pool:find(id)
                if e then
                  local trait = bo2.gv_trait_list:find(e.trait_id)
                  if trait == nil then
                    return
                  end
                  local lootlevel = bo2.gv_lootlevel:find(e.color)
                  local color
                  if lootlevel then
                    color = lootlevel.color
                  end
                  push_traits(ctip_trait_text_ex(trait.modify_id, trait.modify_value), color)
                end
              end
            end
          elseif i == 0 then
            ctip_push_text(stk, ui.get_text("tool|rand_prob_5"))
          end
        end
      end
    elseif info and 0 >= info:get_data_8(bo2.eItemByte_Star) then
    elseif info ~= nil then
      push_group(ui.get_text("tool|minor_identify_property"))
      local star = info:get_data_8(bo2.eItemByte_Star)
      local build_packet
      if upgrade_data == nil then
        build_packet = get_trait_color_packet(excel, star)
      else
        build_packet = upgrade_data.build_packet
      end
      local lastMod = 0
      local lastVal = 0
      for i = bo2.eItemUInt32_IdentTraitBeg, bo2.eItemUInt32_IdentTraitEnd - 1 do
        local trait = get_trait(info:get_data_32(i))
        if trait ~= nil then
          local desc = trait.desc
          if 0 < desc.size then
            push_traits(desc)
          else
            lastMod = trait.modify_id
            lastVal = trait.modify_value
            local color = get_trait_color(build_packet, lastMod, lastVal)
            local txt
            if upgrade_data ~= nil then
              local modify_id, val, trait_id = get_trait_upgrade(build_packet, upgrade_data.trait_packet, lastMod, lastVal)
              txt = ctip_trait_text_ex(modify_id, val)
            else
              txt = ctip_trait_text_ex(lastMod, lastVal)
            end
            push_traits(txt, color)
          end
        end
      end
    end
  end
  do
    local indie_traits = excel.indie_traits
    local cnt = indie_traits.size
    if cnt <= 0 then
    else
      push_group(ui.get_text("tool|unique_property"))
      for i = 0, cnt - 1 do
        local id = indie_traits[i]
        if id > 0 then
          push_traits(ctip_trait_text(id))
        end
      end
    end
  end
  if info ~= nil then
    do
      local star = info:get_data_8(bo2.eItemByte_Star)
      if star > 0 then
      end
    end
  else
    local fix_traits = excel.fix_traits
    local cnt = fix_traits.size
    if cnt <= 0 then
    else
      push_group(ui.get_text("tool|special_property"))
      for i = 0, cnt - 1 do
        local id = fix_traits[i]
        if id > 0 then
          push_traits(ctip_trait_text(id))
        end
      end
    end
  end
  if info ~= nil then
    local cnt = 0
    for i = bo2.eItemUInt32_EnchantBeg, bo2.eItemUInt32_EnchantEnd - 1 do
      local id = info:get_data_32(i)
      if id > 0 then
        if cnt == 0 then
          push_group(ui.get_text("tool|enhance_property"))
        end
        cnt = cnt + 1
        push_traits(ctip_trait_text(id))
      end
    end
  end
  do
    local has_equip = {}
    local has_cnt = 0
    if excel.in_set == 0 then
    else
      local equip_set = bo2.gv_equip_set:find(excel.in_set)
      if equip_set == nil then
      else
        local inc_equips = equip_set.inc_equips
        local cnt = inc_equips.size
        local useStar = false
        local star_cnt = 0
        local ptype = excel.ptype
        if ptype == nil then
        else
          if ptype.equip_slot < bo2.eItemSlot_RidePetBegin or ptype.equip_slot >= bo2.eItemSlot_RidePetEnd then
            local search_box = bo2.eItemArray_InSlot
            if info ~= nil and info.box == bo2.eItemBox_OtherSlot then
              search_box = bo2.eItemBox_OtherSlot
            end
            if equip_set.itype ~= 0 then
              useStar = true
            end
            for i = 0, cnt - 1 do
              local equip_id = inc_equips[i]
              local tinfo = ui.item_of_excel_id(equip_id, search_box, search_box + 1)
              if tinfo ~= nil then
                has_equip[equip_id] = tinfo
                has_cnt = has_cnt + 1
                star_cnt = star_cnt + tinfo.star
              end
            end
          else
            local search_box = bo2.eRidePetBox_Slot
            local search_grid = ui.ride_get_select()
            if info == nil and card ~= nil then
              search_grid = 0
              if card.box == bo2.eItemBox_RidePetView then
                search_box = bo2.eRidePetBox_View
              end
            end
            for i = 0, cnt - 1 do
              local equip_id = inc_equips[i]
              local cc = ui.ridepet_box_get_count(search_box, search_grid, equip_id)
              if cc > 0 then
                has_equip[equip_id] = cc
                has_cnt = has_cnt + 1
              end
            end
          end
          ctip_push_sep(stk)
          if useStar then
            local txt = ui_widget.merge_mtf({
              name = equip_set.name,
              num = has_cnt,
              max = cnt,
              star = star_cnt
            }, ui.get_text("tool|suit_star_name"))
            ctip_push_text(stk, txt, nil, cs_tip_a_add_m)
          else
            ctip_push_text(stk, sys.format("%s(%d/%d)", equip_set.name, has_cnt, cnt), nil, cs_tip_a_add_m)
          end
          for i = 0, cnt - 1 do
            local equip_id = inc_equips[i]
            local equip = ui.item_get_excel(equip_id)
            if equip ~= nil then
              local color = cs_tip_color_set_no
              if has_equip[equip_id] ~= nil then
                color = cs_tip_color_set_has
              end
              ctip_push_newline(stk)
              ctip_push_text(stk, equip.name, color, cs_tip_a_add_m)
            end
          end
          local add_trait = equip_set.add_trait
          local tcnt = add_trait.size
          if tcnt > 0 then
            local req_num = equip_set.req_num
            for i = 0, tcnt - 1 do
              local trait_text = ctip_trait_text(add_trait[i])
              local skill_text
              if trait_text ~= nil then
                local color = cs_tip_color_set_no
                if useStar then
                  if star_cnt >= req_num[i] then
                    color = cs_tip_color_set_has
                  end
                  local txt = ui_widget.merge_mtf({
                    num = req_num[i],
                    des = trait_text
                  }, ui.get_text("tool|suit_property_star"))
                  ctip_push_text(stk, txt, color)
                else
                  if has_cnt >= req_num[i] then
                    color = cs_tip_color_set_has
                  end
                  local txt = ui_widget.merge_mtf({
                    num = req_num[i],
                    des = trait_text
                  }, ui.get_text("tool|suit_property"))
                  ctip_push_text(stk, txt, color)
                end
              end
              if skill_text ~= nil then
                local color = cs_tip_color_set_no
                if useStar then
                  if star_cnt >= req_num[i] then
                    color = cs_tip_color_set_has
                  end
                  local txt = ui_widget.merge_mtf({
                    num = req_num[i],
                    des = skill_text
                  }, ui.get_text("tool|suit_property_star"))
                  ctip_push_text(stk, txt, color)
                else
                  if has_cnt >= req_num[i] then
                    color = cs_tip_color_set_has
                  end
                  local txt = ui_widget.merge_mtf({
                    num = req_num[i],
                    des = skill_text
                  }, ui.get_text("tool|suit_property"))
                  ctip_push_text(stk, txt, color)
                end
              end
            end
          end
          if 0 < equip_set.set_equip.size then
            local req_cnt = equip_set.set_equip_num
            local my_cnt, text_name
            if 0 < equip_set.set_equip_type then
              my_cnt = star_cnt
              text_name = "tool|suit_property_star"
            else
              my_cnt = has_cnt
              if req_cnt == 0 then
                req_cnt = equip_set.inc_equips.size
              end
              text_name = "tool|suit_property"
            end
            local txt = ui_widget.merge_mtf({
              num = req_cnt,
              des = ui.get_text("tool|suit_shape")
            }, ui.get_text(text_name))
            local color = cs_tip_color_set_no
            if my_cnt >= req_cnt then
              color = cs_tip_color_set_has
            end
            ctip_push_text(stk, txt, color)
          end
        end
      end
    end
  end
  if info == nil then
    local holes_cnt = excel.initialholes
    if holes_cnt > 0 then
      push_group(ui.get_text("tool|gem_solt"))
    end
    for idx = 0, holes_cnt - 1 do
      if idx > 0 then
        stk:raw_push("\n")
      end
      stk:raw_push("<img:$image/mtf/pic_gem_empty.png*16,16> ")
      local ptype = excel.ptype
      stk:raw_push(gem_slot_type[ptype.equip_slot])
    end
    break
  elseif info ~= nil then
    local holes = info:get_data_8(bo2.eItemByte_Holes)
    if holes <= 0 then
    else
      push_group(ui.get_text("tool|gem_solt"))
      for i = 0, holes - 1 do
        ctip_make_item_gem(stk, info, i, excel)
      end
    end
  end
  if excel.ptype.equip_slot >= bo2.eItemSlot_HunskillBegin and excel.ptype.equip_slot <= bo2.eItemSlot_HunskillEnd then
    if info ~= nil then
      local holesMax = info:get_data_8(bo2.eItemByte_DiaowenMaxHolesTotle)
      local holesCur = info:get_data_32(bo2.eItemUInt32_DiaowenCurHolesTotle)
      ctip_push_sep(stk)
      stk:raw_push(ui.get_text("tool|cuiqu_hongji_name"))
      if holesCur > 0 then
        local skill_id = info:get_data_32(bo2.eItemUInt32_DiaowenSkillID)
        if skill_id == 0 then
        else
          local skill = ui_skill.get_skill_excel(skill_id, 0)
          if skill == nil then
            skill = ui_skill.get_skill_excel(skill_id, 1)
          end
          if skill == nil then
          else
            stk:merge({
              icon = skill.icon,
              id = skill_id
            }, ui.get_text("tool|cuiqu_hongji_id"))
            stk:raw_push("\n")
            if holesMax == holesCur then
              stk:raw_push(ui.get_text("tool|cuiqu_hongji_state"))
              ctip_push_text(stk, ui.get_text("tool|cuiqu_hongji_activate"), cs_tip_color_green, cs_tip_a_add_r)
            else
              stk:raw_push(ui.get_text("tool|cuiqu_hongji_state"))
              ctip_push_text(stk, ui.get_text("tool|cuiqu_hongji_not_activate"), cs_tip_color_red, cs_tip_a_add_r)
            end
          end
        end
      end
    end
    if info ~= nil then
      local holesMax = info:get_data_8(bo2.eItemByte_DiaowenMaxHolesTotle)
      local holesCur = info:get_data_32(bo2.eItemUInt32_DiaowenCurHolesTotle)
      if holesMax <= 0 then
      else
        push_group(sys.format("%s(%d/%d)", ui.get_text("tool|jingshi_slot"), holesCur, holesMax))
        for i = 0, holesMax - 1 do
          ctip_make_item_jingshi(stk, info, i, excel)
        end
      end
    end
  end
  do
    local ptype = excel.ptype
    if ptype == nil then
    elseif info == nil then
    elseif ptype.equip_slot ~= bo2.eItemSlot_RidePetWeapon then
    elseif excel.ridepet_identify == 0 then
    else
      local ident_excel = bo2.gv_equip_ridepet_identify:find(excel.ridepet_identify)
      if ident_excel == nil then
      else
        local cnt = ident_excel.nMaxSlot
        local unlock_cnt = info:get_data_32(bo2.eItemUInt32_RideFightSkillSlot)
        if unlock_cnt <= 0 then
        else
          ctip_push_sep(stk)
          ctip_push_text(stk, ui.get_text("tool|item_additional_skill") .. cs_tip_newline, nil, cs_tip_a_add_m)
          for i = 0, cnt - 1 do
            local skill_id = info:item_get_ridepet_skill_id(i)
            if skill_id ~= 0 then
              local ridepet_skill = bo2.gv_ridepet_skill:find(skill_id)
              local ridepet_skill_level = info:item_get_ridepet_skill_level(i)
              if ridepet_skill ~= nil then
                stk:raw_push(" <img_bg:")
                stk:raw_format("$icon/skill/%s.png*3*", ridepet_skill.strIcon)
                stk:raw_push("$image/ride/ridepet_skill_grid.png|2,25,20,20*24,24> ")
                stk:raw_format("<mid_lb:plain,14,,%s,24|%s>", cs_tip_color_white, ridepet_skill.name .. "  ")
                stk:raw_format("<mid_lb:plain,12,,%s,24|%s>", cs_tip_color_gold, "Lv:")
                stk:raw_format("<mid_lb:plain,12,,%s,24|%s>", "01c5e9", ridepet_skill_level .. "/" .. ridepet_skill.nMaxLevel)
              end
            elseif unlock_cnt > i then
              stk:raw_push(" <img_bg:")
              stk:raw_push("**$image/ride/ridepet_skill_grid.png|2,2,20,20*24,24>")
            else
              stk:raw_push(" <img_bg:")
              stk:raw_push("**$image/ride/ridepet_skill_grid.png|2,25,20,20*24,24>")
            end
            stk:raw_push(SHARED("\n"))
          end
        end
      end
    end
  end
  if info == nil then
  elseif excel.ptype.equip_slot >= bo2.eItemSlot_AvataBeg and excel.ptype.equip_slot < bo2.eItemSlot_AvataEnd or excel.ptype.equip_slot == bo2.eItemSlot_Wing then
  elseif info ~= nil and info.goods ~= nil then
    if excel.enforce_recognized_max_count.size == 2 then
      local count1 = excel.enforce_recognized_max_count[0]
      local count2 = excel.enforce_recognized_max_count[1]
      if count1 == count2 and count1 == 255 and count2 == 255 then
      else
        ctip_push_sep(stk)
        local color = SHARED("00AA00")
        if count1 == count2 == 0 then
          ctip_push_text(stk, ui.get_text("tip|no_enforce"), color)
        else
          ctip_push_text(stk, ui.get_text("tool|enforce"), color)
          if count1 == count2 then
            ctip_push_text(stk, count1, cs_tip_color_bound, cs_tip_a_add_r)
          else
            ctip_push_text(stk, sys.format("%s-%s", count1, count2), cs_tip_color_bound, cs_tip_a_add_r)
          end
        end
      end
    elseif excel.enforce_recognized_max_count.size == 4 then
      local count1 = excel.enforce_recognized_max_count[2]
      local count2 = excel.enforce_recognized_max_count[3]
      if count1 == count2 and count1 == 255 and count2 == 255 then
      else
        ctip_push_sep(stk)
        if count1 == count2 == 0 then
          ctip_push_text(stk, ui.get_text("tip|no_bind"), color)
        else
          local color = SHARED("00AA00")
          ctip_push_text(stk, ui.get_text("tool|recognized"), color)
          if count1 == count2 then
            ctip_push_text(stk, count1, cs_tip_color_bound, cs_tip_a_add_r)
          else
            ctip_push_text(stk, sys.format("%s-%s", count1, count2), cs_tip_color_bound, cs_tip_a_add_r)
          end
          ctip_push_text(stk, "\n", cs_tip_color_bound, cs_tip_a_add_r)
          count1 = excel.enforce_recognized_max_count[0]
          count2 = excel.enforce_recognized_max_count[1]
          if count1 == count2 and count1 == 255 and count2 == 255 then
          else
            local color = SHARED("00AA00")
            if count1 == count2 == 0 then
              ctip_push_text(stk, ui.get_text("tip|no_enforce"), color)
            else
              ctip_push_text(stk, ui.get_text("tool|enforce"), color)
              if count1 == count2 then
                ctip_push_text(stk, count1, cs_tip_color_bound, cs_tip_a_add_r)
              else
                ctip_push_text(stk, sys.format("%s-%s", count1, count2), cs_tip_color_bound, cs_tip_a_add_r)
              end
            end
          end
        end
      end
    elseif excel.enforce_recognized_max_count.size == 0 then
      ctip_push_sep(stk)
      ctip_push_text(stk, ui.get_text("tool|recognized"), color)
      ctip_push_text(stk, 3, cs_tip_color_bound, cs_tip_a_add_r)
      if excel.ptype.equip_slot == bo2.eItemSlot_HWeapon or excel.ptype.equip_slot == bo2.eItemSlot_Ornament then
      else
        ctip_push_text(stk, "\n", cs_tip_color_bound, cs_tip_a_add_r)
        ctip_push_text(stk, ui.get_text("tool|enforce"), color)
        ctip_push_text(stk, 3, cs_tip_color_bound, cs_tip_a_add_r)
      end
    end
  elseif info == nil or excel.ptype.equip_slot >= bo2.eItemSlot_RidePetHead and excel.ptype.equip_slot <= bo2.eItemSlot_RidePetLeg then
  else
    local curCount = info:get_data_8(bo2.eItemByte_EnforceCounted)
    local maxCount = info:get_data_8(bo2.eItemByte_EnforceMaxCount)
    local curCount1 = info:get_data_8(bo2.eItemByte_RecognizedCounted)
    local maxCount1 = info:get_data_8(bo2.eItemByte_RecognizedMaxCount)
    if maxCount == 255 and maxCount1 == 255 then
      return
    end
    ctip_push_sep(stk)
    local color = SHARED("00AA00")
    if maxCount1 ~= 0 and maxCount1 ~= 255 then
      local R_text = sys.format("%s/%s\n", curCount1, maxCount1)
      ctip_push_text(stk, ui.get_text("tool|recognized"), color)
      ctip_push_text(stk, R_text, cs_tip_color_bound, cs_tip_a_add_r)
    elseif maxCount1 == 0 then
      ctip_push_text(stk, ui.get_text("tool|recognized"), color)
      ctip_push_text(stk, "-/-\n", cs_tip_color_bound, cs_tip_a_add_r)
    end
    if excel.ptype.equip_slot == bo2.eItemSlot_HWeapon then
    elseif maxCount ~= 0 and maxCount ~= 255 then
      if excel.ptype.equip_slot == bo2.eItemSlot_HWeapon or excel.ptype.equip_slot == bo2.eItemSlot_Ornament then
      else
        local R_text = sys.format("%s/%s", curCount, maxCount)
        ctip_push_text(stk, ui.get_text("tool|enforce"), color)
        ctip_push_text(stk, R_text, cs_tip_color_bound, cs_tip_a_add_r)
      end
    elseif maxCount == 0 then
      ctip_push_text(stk, ui.get_text("tool|enforce"), color)
      ctip_push_text(stk, "-/-\n", cs_tip_color_bound, cs_tip_a_add_r)
    end
  end
  local function add_lock_upgrade_prob()
    if info == nil then
      return
    end
    local val = info:get_data_32(bo2.eItemUInt32_UpgradeTraitLockProb)
    if val == 0 then
      return
    end
    ctip_push_sep(stk)
    ctip_push_text(stk, ui.get_text("equip|tip_lock_prob"), cs_tip_color_green)
    local val = sys.format(L("%.2f%%\n"), val / 10000)
    ctip_push_text(stk, val, cs_tip_color_green, cs_tip_a_add_r)
  end
  add_lock_upgrade_prob()
end
function ctip_calculate_item_rank(excel, info, title_mode, upgrade_data)
  local nzhiye = bo2.player:get_atb(bo2.eAtb_Cha_Profession)
  local zhiyeExcel = bo2.gv_profession_list:find(nzhiye)
  local nAttackType = zhiyeExcel.damage + 1
  local fSunGrade = 0
  local function do_modify_grade(gradeId, v)
    local mod_grade = bo2.gv_modify_grade:find(gradeId)
    local modify = bo2.gv_modify_player:find(gradeId)
    if mod_grade ~= nil and modify ~= nil and (mod_grade.ntype == 0 or mod_grade.ntype == nAttackType) then
      if modify.isCent ~= 0 then
        local is_calced = false
        if title_mode ~= nil and title_mode == 2 then
          if gradeId == bo2.eMdf_Cha_OutDmgMod then
            fSunGrade = fSunGrade + ui_personal.ui_equip.make_dmg_score_no_mod(bo2.player) * v / 10000
            is_calced = true
          elseif gradeId == bo2.eMdf_Cha_InDmgMod then
            fSunGrade = fSunGrade + ui_personal.ui_equip.make_def_score_no_mod(bo2.player) * v / 10000
            is_calced = true
          end
        end
        if is_calced ~= true then
          fSunGrade = fSunGrade + mod_grade.fGrade * v / 100
        end
      else
        fSunGrade = fSunGrade + mod_grade.fGrade * v
      end
    end
  end
  local function doAddGrade(eid, v)
    local trait = bo2.gv_trait_list:find(eid)
    if trait ~= nil then
      if trait.tp == bo2.eTraitListType_Modifier then
        do_modify_grade(trait.modify_id, v * trait.modify_value)
      else
        fSunGrade = fSunGrade + trait.modify_value / 100
      end
    end
  end
  local function doAddGradeS(datas, v)
    local cnt = datas.size
    for i = 0, cnt - 1 do
      doAddGrade(datas[i], v)
    end
  end
  if title_mode ~= nil then
    if title_mode == 2 then
      for i, v in pairs(excel) do
        do_modify_grade(i, v * 1)
      end
    else
      doAddGradeS(excel.datas, 1)
    end
    return math.floor(fSunGrade)
  end
  if excel == nil then
    return 0
  end
  local ptype = excel.ptype
  if ptype == nil or ptype.group ~= bo2.eItemGroup_Equip and ptype.group ~= bo2.eItemGroup_Gem or info == nil then
    return 0
  end
  if sys.is_type(excel, cs_tip_mb_data_gem_item) then
    doAddGradeS(excel.datas, 1)
    return math.floor(fSunGrade)
  end
  local fEnforceChg = 1
  local enforce_lvl = info:get_data_8(bo2.eItemByte_EnforceLvl)
  if enforce_lvl == 2 then
    local EnforceID = info:get_data_8(bo2.eItemByte_EnforceID)
    if EnforceID > 0 then
      local EnforceExcel = bo2.gv_enforce_light:find(EnforceID)
      if EnforceExcel ~= nil then
        local fchg = ui.item_get_total_enforce_data(info) / 100 + info:get_data_8(bo2.eItemByte_EnforceAcount) / 100
        local f = EnforceExcel.t_h_limit / 1000000
        if fchg > f then
          fchg = f
        end
        fEnforceChg = fEnforceChg + fchg
      end
    elseif EnforceID == 0 then
      local pre = ui.item_get_total_enforce_data(info)
      fEnforceChg = fEnforceChg + pre
    end
  elseif enforce_lvl == 0 then
    local pre = ui.item_get_total_enforce_data(info)
    fEnforceChg = fEnforceChg + pre / 100
  end
  fEnforceChg = fEnforceChg + info:get_data_32(bo2.eItemUInt32_RecognizedMasterVal) / 100
  local index_item_slot, excel_data = ui_npcfunc.ui_jingpo_guanzhu.find_index_item_slot(excel.ptype.equip_slot)
  local main_weapon_info
  if index_item_slot ~= -1 then
    main_weapon_info = ui.item_of_coord(bo2.eItemArray_InSlot, excel_data.item_slots[index_item_slot])
  end
  if index_item_slot ~= -1 and main_weapon_info ~= nil and main_weapon_info.only_id == info.only_id then
    local guanzhu_level = bo2.player:get_flag_int64(excel_data.db_jingpo_levels[index_item_slot]).v_int
    if excel_data.item_slots[index_item_slot] == bo2.eItemSlot_MainWeapon then
      guanzhu_level = bo2.player:get_flag_int32(excel_data.db_jingpo_levels[index_item_slot])
    end
    if guanzhu_level ~= 0 then
      local line = bo2.gv_jingpo_guanzhu:find(guanzhu_level)
      fEnforceChg = fEnforceChg + line.add_percents[index_item_slot] / 100
    end
  end
  if 0 < excel.ass_upgrade.size then
    local level = info:get_data_32(bo2.eItemUInt32_SecondLevel)
    local ass_upgrade_id = info:get_data_8(bo2.eItemByte_AssUpgradeID)
    if level > 0 then
      if ass_upgrade_id > 0 then
        local ass_up = bo2.gv_assistant_upgrade:find(ass_upgrade_id)
        if ass_up ~= nil then
          local grow = info:get_data_32(bo2.eItemUInt32_SecondGrowRank)
          for i = 0, ass_up.modify_id.size - 1 do
            do_modify_grade(ass_up.modify_id[i], grow * fEnforceChg)
          end
        end
      end
      if ptype ~= nil and ptype.equip_slot == bo2.eItemSlot_2ndWeapon and 0 < excel.ass_id then
        for i = bo2.eItemUInt32_IdentTraitBeg, bo2.eItemUInt32_IdentTraitEnd - 1 do
          doAddGrade(info:get_data_32(i), 1)
        end
        local mark = 255
        for i = bo2.eItemUint32_SecondRProBeg, bo2.eItemUint32_SecondRProEnd do
          local vd = info:get_data_32(i)
          for j = 0, 3 do
            local id = bo2.bit_and(bo2.bit_rshift(vd, j * 8), mark)
            local m = bo2.gv_sw_rand_pool:find(id)
            if m ~= nil then
              doAddGrade(m.trait_id, 1)
            end
          end
        end
      end
    end
  else
    local star = info.star
    if star > 0 then
      local pStarAddition = bo2.gv_equip_star_addition:find(excel.reqlevel)
      if pStarAddition ~= nil then
        local fAdd = pStarAddition.rate[star - 1]
        fEnforceChg = fEnforceChg + fAdd
      end
    end
    if upgrade_data ~= nil then
      fEnforceChg = fEnforceChg + upgrade_data.base_persent / 1000000
    end
    doAddGradeS(excel.datas, fEnforceChg)
  end
  doAddGradeS(excel.indie_traits, 1)
  doAddGradeS(excel.fix_traits, 1)
  for i = bo2.eItemUInt32_IdentTraitBeg, bo2.eItemUInt32_IdentTraitEnd - 1 do
    local id = info:get_data_32(i)
    if id > 0 then
      local v = 1
      if upgrade_data == nil then
        doAddGrade(id, v)
      else
        local trait = bo2.gv_trait_list:find(id)
        if trait ~= nil then
          if trait.tp == bo2.eTraitListType_Modifier then
            local lastMod = trait.modify_id
            local lastVal = trait.modify_value
            local modify_id, val, trait_id = get_trait_upgrade(upgrade_data.build_packet, upgrade_data.trait_packet, lastMod, lastVal)
            do_modify_grade(modify_id, v * val)
          else
            doAddGrade(id, v)
          end
        end
      end
    end
  end
  local holesnum = info:get_data_8(bo2.eItemByte_Holes)
  for i = 0, holesnum do
    local iGem = info:get_data_32(bo2.eItemUInt32_GemBeg + i)
    if iGem > 0 then
      local pGemExcel = bo2.gv_gem_item:find(iGem)
      if pGemExcel ~= nil then
        doAddGradeS(pGemExcel.datas, 1)
      end
    end
  end
  for i = bo2.eItemUInt32_EnchantBeg, bo2.eItemUInt32_EnchantEnd - 1 do
    local id = info:get_data_32(i)
    if id > 0 then
      doAddGrade(id, 1)
    end
  end
  return math.floor(fSunGrade)
end
function ctip_make_item_grade(stk, excel, info, upgrade_data)
  local bAdd = false
  local ptype = excel.ptype
  if ptype ~= nil and info ~= nil and (ptype.group == bo2.eItemGroup_Gem or ptype.group == bo2.eItemGroup_Equip and (excel.ass_upgrade.size == 0 or info:get_xdata_32(bo2.eItemXData32_GrowPointMax) == 0) and (ptype.id < bo2.eItemType_HunskillHead or ptype.id > bo2.eItemType_HunskillRFeet)) then
    ctip_push_sep(stk)
    bAdd = true
    ctip_push_text(stk, ui.get_text("tool|property_rank"))
    local nNum = ctip_calculate_item_rank(excel, info, nil, upgrade_data)
    ctip_push_text(stk, nNum, cs_tip_color_bound, cs_tip_a_add_r)
  end
  if ptype ~= nil and ptype.id == bo2.eItemType_SkillLearnBook then
    local skill_info = ui.skill_find(excel.use_par[1])
    if skill_info ~= nil and skill_info.type ~= 3 then
      if bAdd then
        stk:raw_push(SHARED("\n"))
      else
        ctip_push_sep(stk)
        bAdd = true
      end
      ctip_push_text(stk, ui.get_text("item|already_learnt"), cs_tip_color_red, cs_tip_a_add_r)
    end
  end
  if info ~= nil then
    local cnt = info:get_data_32(bo2.eItemUInt32_GlobalCount)
    local star = info:get_data_8(bo2.eItemByte_Star)
    if cnt > 0 and star >= 6 then
      ctip_push_sep(stk)
      local plootlevel_star = info.plootlevel_star
      local color
      if plootlevel_star ~= nil then
        color = plootlevel_star.color
      else
        color = ui.make_color(cs_tip_color_gold)
      end
      local set_text = ui.get_text("tool|equipment_global_cnt")
      if star == 6 then
        set_text = ui.get_text("tool|equipment_star_6")
      elseif star == 7 then
        set_text = ui.get_text("tool|equipment_star_7")
      elseif star == 8 then
        set_text = ui.get_text("tool|equipment_star_8")
      end
      local mtf_data = {
        n = sys.format("<c+:%.6X>%d<c->", color, cnt)
      }
      stk:raw_push("<a+:m>")
      stk:merge(mtf_data, set_text)
      stk:raw_push("<a->")
    end
  end
end
function ctip_make_item_life(info, life_second)
  if info.goods ~= nil then
    return life_second
  end
  local life_sec = math.floor(info:get_xdata_32(bo2.eItemXData32_TimeRemain))
  if life_sec > 0 then
    local span_sec = math.floor(sys.dtick(sys.tick(), info:get_xdata_32(bo2.eItemXData32_TimeUpdate)) / 1000)
    if life_sec <= span_sec then
      life_second = 0
    else
      life_second = life_sec - span_sec
    end
  else
    life_sec = bo2.get_svrcurtime32() - info:get_data_32(bo2.eItemUInt32_AcquireTime)
    if life_sec > 0 then
      if life_second > life_sec then
        life_second = life_second - life_sec
      else
        life_second = 0
      end
    end
  end
  return life_second
end
function ctip_make_item_without_price(stk, excel, info)
  local plootlevel_star, title_name
  if info ~= nil then
    plootlevel_star = info.plootlevel_star
    title_name = info.name
  else
    plootlevel_star = excel.plootlevel_star
    title_name = excel.name
  end
  if plootlevel_star ~= nil then
    ctip_make_title_ex(stk, title_name, plootlevel_star.color)
  else
    ctip_make_title_ex(stk, title_name, cs_tip_color_white)
  end
  local upgrade_data = get_equip_upgrade_data(info, excel)
  ctip_make_item_icon(stk, excel, info)
  ctip_make_item_equip_model(stk, info)
  ctip_make_item_grade(stk, excel, info, upgrade_data)
  if info ~= nil and excel.type == bo2.eItemType_TransPos then
    local areaID = info:get_data_32(bo2.eItemUInt32_AreaID)
    if areaID ~= 0 then
      local x = info:get_data_32(bo2.eItemUInt32_PosX)
      x = x / 1000
      x = math.floor(x)
      local y = info:get_data_32(bo2.eItemUInt32_PosZ)
      y = y / 1000
      y = math.floor(y)
      local area_list = bo2.gv_area_list:find(areaID)
      local area_v = sys.variant()
      area_v:set("area", area_list.name)
      local pos_v = sys.variant()
      pos_v:set("pos_x", x)
      pos_v:set("pos_y", y)
      local area_t = sys.mtf_merge(area_v, ui.get_text("npcfunc|mark_area_lb"))
      local pos_t = sys.mtf_merge(pos_v, ui.get_text("npcfunc|mark_pos_lb"))
      ctip_push_sep(stk)
      ctip_push_text(stk, area_t)
      ctip_push_newline(stk)
      ctip_push_text(stk, pos_t)
    end
  end
  if info ~= nil and excel.type == bo2.eItemType_StarStone then
    local reg = info:get_data_32(bo2.eItemUInt32_RecognizedMasterTimes)
    ctip_push_sep(stk)
    if reg > 0 then
      ctip_push_text(stk, ui.get_text("item|do_recognized"), cs_tip_color_green, cs_tip_a_add_r)
    else
      ctip_push_text(stk, ui.get_text("item|undo_recognized"), cs_tip_color_red, cs_tip_a_add_r)
    end
    local excel = info.excel
    if excel.base_attri.size ~= 0 then
      ctip_push_sep(stk)
      ctip_push_text(stk, ui.get_text("tool|special_property"), cs_tip_color_white, cs_tip_a_add_m)
      for i = 0, excel.base_attri.size - 1 do
        local trait = bo2.gv_trait_list:find(excel.base_attri[i])
        if trait ~= nil then
          ctip_push_newline(stk)
          ctip_push_text(stk, trait.desc, cs_tip_color_green, cs_tip_a_add_l)
        end
      end
    end
    local blessVal = info:get_data_32(bo2.eItemUInt32_BlessAttri)
    if blessVal == 0 then
      ctip_push_sep(stk)
      ctip_push_text(stk, ui.get_text("tool|rogation_property_des"), cs_tip_color_red, cs_tip_a_add_m)
    else
      ctip_push_sep(stk)
      ctip_push_text(stk, ui.get_text("tool|rogation_property"), cs_tip_color_white, cs_tip_a_add_m)
      ctip_push_newline(stk)
      local blessExcel = bo2.gv_bless_list:find(info:get_data_32(bo2.eItemUInt32_BlessID))
      if blessExcel ~= nil then
        ctip_push_text(stk, sys.format("%s+%d", blessExcel.desc, blessVal), cs_tip_color_green, cs_tip_a_add_l)
      end
    end
    if reg == 0 then
    elseif excel.in_set == 0 then
    else
      local equip_set = bo2.gv_equip_set:find(excel.in_set)
      if equip_set == nil then
      else
        local inc_equips = equip_set.inc_equips
        local cnt = inc_equips.size
        local has_equip = {}
        local has_cnt = 0
        for i = 0, cnt - 1 do
          local equip_id = inc_equips[i]
          local cc = ui.count_starstone_enable(equip_id)
          if cc > 0 then
            has_equip[equip_id] = cc
            has_cnt = has_cnt + 1
          end
        end
        ctip_push_sep(stk)
        ctip_push_text(stk, sys.format("%s(%d/%d)", equip_set.name, has_cnt, cnt), nil, cs_tip_a_add_m)
        for i = 0, cnt - 1 do
          local equip_id = inc_equips[i]
          local equip = ui.item_get_excel(equip_id)
          if equip ~= nil then
            local color = cs_tip_color_set_no
            if has_equip[equip_id] ~= nil then
              color = cs_tip_color_set_has
            end
            ctip_push_newline(stk)
            ctip_push_text(stk, equip.name, color, cs_tip_a_add_m)
          end
        end
        local add_trait = equip_set.add_trait
        local tcnt = add_trait.size
        if tcnt > 0 then
          local req_num = equip_set.req_num
          for i = 0, tcnt - 1 do
            local trait_text = ctip_trait_text(add_trait[i])
            if trait_text ~= nil then
              local color = cs_tip_color_set_no
              if has_cnt >= req_num[i] then
                color = cs_tip_color_set_has
              end
              local txt = ui_widget.merge_mtf({
                num = req_num[i],
                des = trait_text
              }, ui.get_text("tool|suit_property"))
              ctip_push_text(stk, txt, color)
            end
          end
        end
      end
    end
  end
  do
    local requires = excel.requires
    local cnt = requires.size
    if cnt == 0 then
    else
      ctip_push_sep(stk)
      for i = 1, cnt - 1, 2 do
        ctip_push_req(stk, requires[i - 1], requires[i], i)
      end
    end
  end
  ctip_make_item_atb(stk, excel, info, card, upgrade_data)
  upgrade_data = nil
  ctip_make_avata_enchant(stk, excel, info)
  if bo2.gv_item_type:find(excel.type) and bo2.gv_item_type:find(excel.type).id == bo2.eItemtype_BarberQuan then
    local id1 = info:get_data_32(bo2.eItemInt32_BarberShopProp1)
    local id2 = info:get_data_32(bo2.eItemInt32_BarberShopProp2)
    local eye_value = info:get_data_32(bo2.eItemInt32_BarberShopFace_Eye)
    local nose_value = info:get_data_32(bo2.eItemInt32_BarberShopFace_Nose)
    local mouth_value = info:get_data_32(bo2.eItemInt32_BarberShopFace_Mouth)
    local body_high = info:get_data_32(bo2.eItemInt32_BarberShopBodyHigh)
    local body_low = info:get_data_32(bo2.eItemInt32_BarberShopBodyLow)
    if excel.id == 58210 then
      if id1 > 0 then
        ctip_push_sep(stk)
        ctip_push_text(stk, ui.get_text("tool|barberQuan_face"))
        ctip_push_text(stk, bo2.gv_barber_shop:find(id1).name_text, cs_tip_color_red)
      end
      if id2 > 0 then
        ctip_push_sep(stk)
        ctip_push_text(stk, ui.get_text("tool|barberQuan_portrait"))
        ctip_push_text(stk, bo2.gv_barber_shop:find(id2).name_text, cs_tip_color_red)
      end
      if eye_value ~= 0 or nose_value ~= 0 or mouth_value ~= 0 then
        ctip_push_sep(stk)
        ctip_push_text(stk, ui.get_text("tool|barberQuan_facelifting"))
      end
    elseif excel.id == 58211 then
      if id1 > 0 then
        ctip_push_sep(stk)
        ctip_push_text(stk, ui.get_text("tool|barberQuan_hair"))
        ctip_push_text(stk, bo2.gv_barber_shop:find(id1).name_text, cs_tip_color_red)
      end
      if id2 > 0 then
        ctip_push_sep(stk)
        ctip_push_text(stk, ui.get_text("tool|barberQuan_hair_color"))
        ctip_push_text(stk, bo2.gv_barber_shop:find(id2).name_text, cs_tip_color_red)
      end
    elseif excel.id == 58212 then
      if id1 > 0 then
        local pExcel = bo2.gv_equip_item:find(id1)
        ctip_push_sep(stk)
        ctip_push_text(stk, ui.get_text("tool|barberQuan_tattoo"))
        ctip_push_text(stk, pExcel.name, cs_tip_color_red)
      end
    elseif excel.id == 58213 then
      ctip_push_sep(stk)
      ctip_push_text(stk, ui.get_text("tool|barberQuan_bodylifting"))
    end
  end
  do
    local puse = excel.iuse
    if puse == nil then
    else
    end
  end
  while true do
    do
      local quest_req = excel.quest_req
      if quest_req == nil then
        break
      end
      local quest_cnt = quest_req.size
      if quest_cnt <= 0 then
        break
      end
      ctip_push_sep(stk)
      ctip_push_text(stk, ui.get_text("tool|relative_quest"))
      local name_table = {}
      function check_repeat(name)
        local size = table.maxn(name_table)
        for i = 1, size do
          if name_table[i] == name then
            return true
          end
        end
        return false
      end
      for i = 0, quest_cnt - 1 do
        local quest = bo2.gv_quest_list:find(quest_req[i])
        if check_repeat(quest.name) == false then
          ctip_push_text(stk, sys.format([[

<%s>]], quest.name))
          table.insert(name_table, quest.name)
        end
      end
      break
    end
  end
  do
    local life_second = 0
    if info ~= nil then
      do
        local renew = info:get_data_32(bo2.eItemUInt32_RenewalDays)
        if renew ~= 0 then
          if renew < 0 then
          else
            local begTime = info:get_data_32(bo2.eItemUInt32_RenewalTime)
            if begTime == 0 then
            else
              life_second = begTime + 86400 * (renewDays + 5)
              life_second = ctip_make_item_life(info, life_second)
              local txt = ui.get_text("tool|left_time")
              ctip_push_sep(stk)
              stk:raw_push("<lb:,,,|")
              stk:push(txt)
              stk:push(ctip_time_text(life_second))
              stk:raw_push(">")
            end
          end
        end
      end
    else
      local life_mode = excel.life_mode
      if life_mode == 0 then
      else
        life_second = excel.life_second
        if life_second == 0 then
        else
          local txt
          if life_mode == bo2.eItemLife_RealSecond then
            if info ~= nil then
              life_second = ctip_make_item_life(info, life_second)
            end
            txt = ui.get_text("tool|left_time")
          else
            txt = ui.get_text("tool|offtime_exsit_time")
          end
          ctip_push_sep(stk)
          stk:raw_push("<lb:,,,|")
          stk:push(txt)
          stk:push(ctip_time_text(life_second))
          stk:raw_push(">")
        end
      end
    end
  end
  if info == nil then
  else
    local lock = info:get_data_32(bo2.eItemUInt32_SafeFrozen)
    if lock == 0 then
    elseif lock == 1 then
      ctip_push_sep(stk)
      stk:raw_format(ui.get_text("tool|item_safe_frozen"))
    else
      local txt = ui.get_text("tool|item_unfreeze_remain")
      local life_second = 0
      local life_sec = math.floor(info:get_xdata_32(bo2.eItemXData32_UnfreezeRemain))
      local span_sec = math.floor(sys.dtick(sys.tick(), info:get_xdata_32(bo2.eItemXData32_UnfreezeUpdate)) / 1000)
      if life_sec <= span_sec then
        life_second = 0
      else
        life_second = life_sec - span_sec
      end
      ctip_push_sep(stk)
      stk:raw_push("<c+:FFFF00><lb:,,,|")
      stk:push(txt)
      stk:push(ctip_time_text(life_second))
      stk:raw_push("><c->")
    end
  end
  if info == nil then
  else
    local renew = info:get_data_32(bo2.eItemUInt32_RenewalDays)
    if renew ~= 0 then
      if renew < 0 then
        ctip_push_sep(stk)
        stk:raw_push(ui.get_text("tool|effective_time_permanent"))
      else
        local begTime = info:get_data_32(bo2.eItemUInt32_RenewalTime)
        if begTime == 0 then
          ctip_push_sep(stk)
          stk:raw_push(ui.get_text("tool|effective_time_unactivated"))
        else
          local life_second = 0
          local life_sec = math.floor(info:get_xdata_32(bo2.eItemXData32_DisableRemain))
          local span_sec = math.floor(sys.dtick(sys.tick(), info:get_xdata_32(bo2.eItemXData32_DisableUpdate)) / 1000)
          if life_sec <= span_sec then
            ctip_push_sep(stk)
            stk:raw_push(ui.get_text("tool|effective_time_disable"))
          else
            local txt = ui.get_text("tool|effective_time")
            life_second = life_sec - span_sec
            ctip_push_sep(stk)
            stk:raw_push("<lb:,,,|")
            stk:push(txt)
            stk:push(ctip_time_text(life_second))
            stk:raw_push(">")
          end
        end
      end
    end
  end
  do
    local puse = excel.iuse
    if puse == nil then
    elseif puse.model ~= bo2.eUseMod_Rose then
    else
      local player = bo2.player
      if not sys.check(player) then
      else
        ctip_push_sep(stk)
        stk:merge({
          n = player:get_flag_int32(bo2.ePlayerFlagInt32_RoseSend)
        }, ui.get_text("item_rose|send_desc"))
        stk:push("\n")
        stk:merge({
          n = player:get_flag_int32(bo2.ePlayerFlagInt32_RoseRecv)
        }, ui.get_text("item_rose|recv_desc"))
        stk:push("\n")
        stk:merge({
          n = player:get_flag_int32(bo2.ePlayerFlagInt32_RoseSendTotal)
        }, ui.get_text("item_rose|send_total"))
        stk:push("\n")
        stk:merge({
          n = player:get_flag_int32(bo2.ePlayerFlagInt32_RoseRecvTotal)
        }, ui.get_text("item_rose|recv_total"))
        local mod = ui_item_rose
        if mod ~= nil then
          mod.make_list_tip(stk)
        end
      end
    end
  end
  do
    local puse = excel.iuse
    if puse == nil then
    elseif puse.model ~= bo2.eUseMod_EquipModel then
    else
      local use_par = excel.use_par
      if use_par.size < 2 then
      else
        ctip_push_sep(stk)
        stk:push(ui.get_text("item_equip_model|equip_list"))
        stk:raw_push([[

<c+:00FF00>]])
        for i = 1, use_par.size - 1 do
          stk:push(ui.get_text("item|slot" .. use_par[i]))
          stk:push("\n")
        end
        stk:raw_push("<c->")
        local day = use_par[0]
        if day == 0 then
          stk:push(ui.get_text("tool|effective_time_permanent"))
        else
          stk:push(ui.get_text("tool|effective_time"))
          stk:raw_push("<c+:00FF00>")
          stk:raw_push(ui_widget.merge_mtf({day = day}, ui.get_text("tool|tip_item_time4")))
          stk:raw_push("<c->")
        end
      end
    end
  end
  do
    local puse = excel.iuse
    if puse == nil then
    elseif puse.model ~= bo2.eUseMod_SnowBall then
    else
      local player = bo2.player
      if not sys.check(player) then
      else
        ctip_push_sep(stk)
        stk:merge({
          n = player:get_flag_int32(bo2.ePlayerFlagInt32_SnowballSend)
        }, ui.get_text("common|snowball_t"))
        stk:push("\n")
        local mod = ui_item_rose
        if mod ~= nil then
          mod.make_list_tip(stk)
        end
      end
    end
  end
  do
    local puse = excel.iuse
    if puse == nil then
    elseif puse.model ~= bo2.eUseMod_SnowBall then
    else
      local player = bo2.player
      if not sys.check(player) then
      else
        ctip_push_sep(stk)
        stk:merge({
          n = player:get_flag_int32(bo2.ePlayerFlagInt32_SnowballSend)
        }, ui.get_text("common|snowball_t"))
        stk:push("\n")
        local mod = ui_item_rose
        if mod ~= nil then
          mod.make_list_tip(stk)
        end
      end
    end
  end
  if excel.id == 80591 or excel.id == 80592 or excel.id == 80593 then
    local player = bo2.player
    if not sys.check(player) then
    else
      ctip_push_sep(stk)
      stk:merge({
        n = player:get_flag_int32(bo2.ePlayerFlagInt32_MooncakeTotal)
      }, ui.get_text("common|mooncake_t"))
      local mod = ui_item_rose
      if mod ~= nil then
        mod.make_list_tip(stk)
      end
    end
  end
  do
    local practice_item = bo2.gv_practice_item:find(excel.id)
    if practice_item == nil or 0 >= practice_item.buff_id then
    else
      local state_id = practice_item.buff_id
      local has = false
      for i = 0, bo2.gv_guaji_rate.size - 1 do
        local rate_excel = bo2.gv_guaji_rate:get(i)
        local states = rate_excel.states
        for s = 0, states.size - 1 do
          if states[s] == state_id then
            if not has then
              has = true
              ctip_push_sep(stk)
              stk:raw_format(ui.get_text("practice|item_rate_tip"))
            end
            stk:raw_push("\n")
            stk:merge({
              n = sys.format("<c+:FFCC22>%d<c->", rate_excel.rate)
            }, ui.get_text("practice|item_rate_tip2"))
            break
          end
        end
      end
    end
  end
  do
    local tip_id = excel.tip
    if tip_id == 0 then
    else
      local tip_x = bo2.gv_text:find(tip_id)
      if tip_x == nil or tip_x.text.empty then
      else
        ctip_push_sep(stk)
        stk:raw_format("<c+:9F601B>%s<c->", tip_x.text)
        local ptype = excel.ptype
        if ptype == nil then
          return
        end
        if info == nil then
        elseif info.goods ~= nil then
        elseif ptype.equip_slot == bo2.eItemSlot_2ndWeapon then
          local iAdd = info:get_data_32(bo2.eItemUInt32_SeExpAdd)
          local iCount = info:get_data_32(bo2.eItemUInt32_SeExpCount)
          if iCount ~= 0 and iAdd ~= 0 then
            ctip_push_sep(stk)
            local v1 = sys.variant()
            v1:set("add", iAdd + 1)
            local add_text = sys.mtf_merge(v1, ui.get_text("item|cur_se_add"))
            local v2 = sys.variant()
            v2:set("count", iCount)
            local count_text = sys.mtf_merge(v2, ui.get_text("item|cur_se_count"))
            ctip_push_text(stk, add_text, cs_tip_color_green)
            ctip_push_newline(stk)
            ctip_push_text(stk, count_text, cs_tip_color_green)
          end
        end
      end
    end
  end
  if not sys.is_type(excel, cs_tip_mb_data_equip_item) then
  elseif info ~= nil then
    local star = info:get_data_8(bo2.eItemByte_Star)
    if star > 0 then
    else
      local ptype = excel.ptype
      if ptype == nil then
      elseif excel.ass_upgrade == 0 and excel.ass_id == 0 then
      elseif excel.ass_upgrade.size == 1 then
      elseif ptype.equip_slot == bo2.eItemSlot_2ndWeapon then
        local id = info:get_data_8(bo2.eItemByte_AssUpgradeID)
        if id > 0 then
          local e = bo2.gv_assistant_upgrade:find(id)
          if e and e.ass_tip ~= 0 then
            local tip_x = bo2.gv_text:find(e.ass_tip)
            if tip_x == nil or tip_x.text.empty then
            else
              ctip_push_sep(stk)
              stk:raw_format("<c+:9F601B>%s<c->", tip_x.text)
              local tip_id = excel.ident_pretip
              if tip_id == 0 then
              else
                local tip_x = bo2.gv_text:find(tip_id)
                if tip_x == nil then
                else
                  ctip_push_sep(stk)
                  stk:raw_format("<c+:9F601B>%s<c->", tip_x.text)
                end
              end
            end
          end
        end
      end
    end
  end
  do
    local d = bo2.gv_item_decompose:find(excel.id)
    if d == nil or size_id == 0 then
      return false
    end
    local size_id = d.v_item_rands.size
    if size_id == 0 then
      return false
    end
    local flag = true
    for i = 0, size_id - 1 do
      local r = bo2.gv_item_rand:find(d.v_item_rands[i])
      if r == nil then
        flag = false
        break
      end
    end
    if flag == false then
    else
      local skill = bo2.gv_skill_group:find(100113)
      local txt = sys.format("<img:$icon/skill/%s.png*16,16><lb:,,,00FF00|%s>", skill.icon, skill.name)
      ctip_push_sep(stk)
      stk:merge({skill = txt}, ui.get_text("item_compose|tip_use_skill"))
    end
  end
  do
    local excel = bo2.gv_item_list:find(excel.id)
    if excel == nil or excel.requires.size ~= 2 or excel.requires[0] ~= 101 or excel.requires[1] ~= 100287 then
    else
      local skill = bo2.gv_skill_group:find(excel.requires[1])
      if skill == nil then
        skill = bo2.gv_passive_skill:find(excel.requires[1])
      end
      if skill == nil then
      else
        ctip_push_sep(stk)
        stk:merge({
          icon = skill.icon,
          id = skill.id
        }, ui.get_text("skill|tip_use_jianding_skill"))
      end
    end
  end
  do
    local excel = bo2.gv_item_list:find(excel.id)
    if excel == nil or excel.requires.size ~= 2 or excel.requires[0] ~= 101 or excel.requires[1] ~= 100284 then
    else
      local skill = bo2.gv_skill_group:find(excel.requires[1])
      if skill == nil then
        skill = bo2.gv_passive_skill:find(excel.requires[1])
      end
      if skill == nil then
      else
        ctip_push_sep(stk)
        stk:merge({
          icon = skill.icon,
          id = skill.id
        }, ui.get_text("skill|tip_use_yanmo_skill"))
      end
    end
  end
  do
    local excel = bo2.gv_item_list:find(excel.id)
    if excel == nil or excel.requires.size ~= 2 or excel.requires[0] ~= 101 or excel.requires[1] ~= 130091 then
    else
      local skill = bo2.gv_skill_group:find(excel.requires[1])
      if skill == nil then
        skill = bo2.gv_passive_skill:find(excel.requires[1])
      end
      if skill == nil then
      else
        ctip_push_sep(stk)
        stk:merge({
          icon = skill.icon,
          id = skill.id
        }, ui.get_text("skill|tip_use_bopitigu_skill"))
      end
    end
  end
  do
    local d = bo2.item_compose_find(excel.id)
    if d == nil or 0 >= d.size then
    else
      ctip_push_sep(stk)
      stk:raw_push(ui.get_text("item_compose|tip_func_desc"))
      stk:raw_push("\n")
      stk:raw_push(ui.get_text("item_compose|cost_min") .. d:get(0).count)
      stk:raw_push("\n")
      stk:raw_push(ui.get_text("item_compose|cost_max") .. d:get(d.size - 1).count)
    end
  end
  if ui_item == nil then
  else
    local puse = excel.iuse
    if puse == nil then
    elseif puse.model ~= bo2.eUseMod_BoxExtend then
    else
      local use_par = excel.use_par
      local par_cnt = use_par.size
      if par_cnt < 3 then
      else
        local box = use_par[0]
        local box_data = ui_item.g_boxs[box]
        if box_data == nil then
        else
          local box_size = box_data.count
          local box_name = ui.get_text("item|slot" .. box)
          ctip_push_sep(stk)
          stk:merge({
            box = box_name,
            size = sys.format("<c+:00ff00>%d<c->", box_size)
          }, ui.get_text("box_extend|item_desc"))
          local has = false
          for j = 1, par_cnt - 2, 2 do
            local box_item = ui.item_get_excel(use_par[j])
            if box_item ~= nil then
              local par = box_item.use_par
              if 0 < par.size then
                local size = par[0]
                local color = "ffffff"
                if box_size < size then
                  if has then
                    color = "bbbbbb"
                  else
                    color = "ffcc22"
                    has = true
                  end
                end
                stk:raw_format([[

<c+:%s>]], color)
                stk:merge({
                  n = sys.format("<c+:00ff00>%d<c->", size),
                  c = sys.format("<c+:00ff00>%d<c->", use_par[j + 1])
                }, ui.get_text("box_extend|item_cost"))
                stk:raw_push("<c->")
              end
            end
          end
          if not has then
            stk:raw_push([[

<c+:ff0000>]])
            stk:merge({box = box_name}, ui.get_text("box_extend|box_limit"))
            stk:raw_push("<c->")
          end
        end
      end
    end
  end
  if info == nil then
  else
    local sign = info:get_data_s()
    if sign == L("") then
    else
      local excel_id = info.excel_id
      if excel_id == nil then
        return
      end
      if excel_id == 57027 then
        ctip_push_sep(stk)
        ctip_push_text(stk, ui.get_text("tool|series_description") .. sign, cs_tip_color_green)
      else
        ctip_push_sep(stk)
        ctip_push_text(stk, ui.get_text("tool|item_maker") .. sign, cs_tip_color_green)
      end
    end
  end
  do
    local puse = excel.iuse
    if puse == nil then
    else
      local cd_id = puse.cooldown
      if cd_id == 0 then
      else
        local cd_excel = bo2.gv_cooldown_list:find(cd_id)
        if cd_excel == nil then
        else
          ctip_push_sep(stk)
          local mode = cd_excel.mode
          local tm = cd_excel.time
          local txt
          if mode == bo2.eCooldownMode_RealSec then
            txt = ctip_time_text(tm)
          elseif mode == bo2.eCooldownMode_OnlineSec then
            txt = ui.get_text("tool|online") .. ctip_time_text(tm)
          elseif mode == bo2.eCooldownMode_WeekdayClock then
            txt = ui_widget.merge_mtf({
              weekday = ui.get_text("time|weekday_" .. math.floor(tm / 100)),
              time = tm % 100
            }, ui.get_text("tool|reset_time_week"))
          elseif mode == bo2.eCooldownMode_Month then
            txt = ui_widget.merge_mtf({
              day = math.floor(tm / 100),
              time = tm % 100
            }, ui.get_text("tool|reset_time_month"))
          else
            txt = ui_widget.merge_mtf({time = tm}, ui.get_text("tool|reset_time"))
          end
          stk:raw_push("<lb:,,,FFFFFF|")
          stk:push(ui.get_text("tool|cooldown_time"))
          stk:push(txt)
          stk:raw_push(">")
          local cd_info = ui.cooldown_find(cd_id)
          if cd_info == nil then
            tm = 0
          else
            tm = cd_info.remain_second
          end
          if tm == 0 then
            do
              local ui_text = ""
              if mode == bo2.eCooldownMode_ClockHour then
                ui_text = ui.get_text("tool|cooldown_token_des")
              elseif mode == bo2.eCooldownMode_WeekdayClock then
                ui_text = ui.get_text("tool|cooldown_token_des_week")
              elseif mode == bo2.eCooldownMode_Month then
                ui_text = ui.get_text("tool|cooldown_token_des_month")
                do break end
                do break end
                local token_cool_down
                local cd_token = ui.cooldown_find_token(cd_id)
                if cd_token ~= nil then
                  token_cool_down = cd_token.token
                else
                  token_cool_down = cd_excel.token
                end
                txt = ui_widget.merge_mtf({token = token_cool_down}, ui_text)
                ctip_push_sep(stk)
                stk:raw_push(txt)
              end
            end
          else
            txt = ui.get_text("tool|left_cooldown_time")
            ctip_push_sep(stk)
            stk:raw_push("<lb:,,,FF0000|")
            stk:push(txt)
            stk:push(ctip_time_text(tm))
            stk:raw_push(">")
          end
        end
      end
    end
  end
  if excel.type == bo2.eItemType_Scroll then
    local exp = excel.exp
    if exp ~= 0 and exp ~= nil then
      ctip_push_sep(stk)
      ctip_push_text(stk, ui.get_text("tool|use_exp"))
      stk:raw_format("%d", excel.exp)
    end
    local info = ui.discover_find_by_scroll(excel.id)
    if info ~= nil then
      local v = sys.variant()
      if info.study == -1 then
        v:set("n1", info.excel.gold_study)
        v:set("n2", info.excel.gold_study)
      else
        v:set("n1", info.study)
        v:set("n2", info.excel.gold_study)
      end
      ctip_push_newline(stk)
      local disc_text = sys.mtf_merge(v, ui.get_text("discover|tool_tip_disc"))
      ctip_push_text(stk, disc_text)
    end
  end
  if sys.is_type(excel, cs_tip_mb_data_equip_item) and 0 < excel.disable_remake then
    ctip_push_sep(stk)
    ctip_push_text(stk, ui.get_text("remake|disable_remake"), "FF8800")
  elseif info == nil then
  else
    local cur_star = info:get_data_8(bo2.eItemByte_Star)
    if cur_star <= 0 then
    else
      local first_remake = info:get_data_8(bo2.eItemByte_FirstRemake)
      if first_remake == 0 then
        ctip_push_sep(stk)
        ctip_push_text(stk, ui.get_text("tool|not_remake"), "EBCC4F")
      end
    end
  end
  do
    local bank_excel = bo2.gv_accbank_item_in:find(excel.id)
    if bank_excel == nil then
    else
      ctip_push_sep(stk)
      stk:raw_format("<c+:EBCC4F>%s<c->", ui.get_text("tool|item_in_account_bank"))
    end
  end
  if info == nil then
  else
    local excel = info.excel
    if excel == nil then
    else
      local ptype = excel.ptype
      if ptype.group == bo2.eItemGroup_Avata and (ptype.id == bo2.eItemType_NewAvatar_Hat or ptype.id == bo2.eItemType_NewAvatar_Body) then
        ctip_push_sep(stk)
        ctip_push_text(stk, ui.get_text("tool|can_punch_pre"), "EBCC4F")
        stk:raw_push("<i:83702>")
        ctip_push_text(stk, ui.get_text("tool|can_punch_sub"), "EBCC4F")
      end
    end
  end
  if sys.check(excel) then
    local bound_type = excel.bound_mode
    if bound_type == 5 or bound_type == 6 then
      ctip_push_sep(stk)
      ctip_push_text(stk, ui.get_text("item|leave_scn_disappear"), "FFFFFF")
    end
  end
  local puse = excel.iuse
  if info ~= nil and puse ~= nil and puse.model == bo2.eUseMod_PuzzleMap then
    local txt
    local puzzle_map_id = excel.use_par[0]
    local puzzle_map_line = bo2.gv_puzzle_map:find(puzzle_map_id)
    local scn_id = info:get_data_32(bo2.eItemUInt32_ScnID)
    if scn_id == 0 then
      txt = ui.get_text("puzzle|scn_pos1")
    else
      local scn_name = bo2.gv_scn_list:find(scn_id).name
      local areaID = info:get_data_32(bo2.eItemUInt32_AreaID)
      if puzzle_map_line.type == 0 then
        if areaID ~= 0 then
          local pos_x = info:get_data_32(bo2.eItemUInt32_PosX)
          pos_x = math.floor(pos_x / 1000)
          local pos_z = info:get_data_32(bo2.eItemUInt32_PosZ)
          pos_z = math.floor(pos_z / 1000)
          txt = ui_widget.merge_mtf({
            scn = scn_name,
            x = pos_x,
            z = pos_z
          }, ui.get_text("puzzle|scn_pos2"))
        else
          txt = ui_widget.merge_mtf({scn = scn_name}, ui.get_text("puzzle|scn_pos3"))
        end
      else
        txt = ui_widget.merge_mtf({scn = scn_name}, ui.get_text("puzzle|scn_pos4"))
      end
    end
    ctip_push_sep(stk)
    stk:raw_push("<lb:,,,|")
    stk:push(txt)
    stk:raw_push(">")
  end
end
function ctip_make_goods_price(stk, excel, goods, count, bFull, results)
  local req_obj = goods.req_obj
  local req_id = goods.req_id
  local req_num = goods.req_num
  local expend_obj = goods.expend_obj
  local expend_num = goods.expend_num
  local has_req = false
  local txt
  local is_red = false
  if count == nil then
    count = 1
  end
  if results == nil then
    results = {}
  end
  local function push_req()
    if txt == nil then
      return
    end
    if has_req then
      stk:raw_push("+")
    else
      has_req = true
    end
    if is_red then
      stk:raw_format("<c+:#red>%s<c->", txt)
    else
      stk:raw_push(txt)
    end
  end
  local function do_req(f_obj, f_id, f_num, i)
    local obj_kind = f_obj[i]
    txt = nil
    is_red = false
    if obj_kind < bo2.eQuestObj_ItemEnd then
      local excel_id = f_id[i]
      local excel = ui.item_get_excel(excel_id)
      if excel ~= nil then
        local num = f_num[i] * count
        is_red = num > ui.item_get_count(excel_id, true)
        txt = sys.format("%d<img:$icon/item/%s.png*16,16>", num, excel.icon)
        results.need_item = true
      end
    elseif obj_kind == bo2.eQuestObj_GuildPersonlContri then
      local contri = f_num[i] * count
      local member = ui.guild_get_self()
      is_red = member == nil or contri > member.current_con
      txt = sys.format("<guild_person_contri:%d>", contri)
    elseif obj_kind == bo2.eQuestObj_GuildFlexibleContri then
      local contri = f_num[i] * count
      is_red = contri > ui.guild_get_drawcontri()
      txt = sys.format("<guild_flexible_contri:%d>", contri)
    elseif obj_kind == bo2.eQuestObj_GuildFlexibleMoney then
      local money = f_num[i] * count
      is_red = money > ui.guild_get_drawmoney()
      txt = sys.format("<m:%d>", money)
    elseif obj_kind == bo2.eQuestObj_PlayerInt32Flag then
      local id = f_id[i]
      if id == bo2.ePlayerFlagInt32_Errantry then
        local errantry = f_num[i] * count
        local player = bo2.player
        is_red = player == nil or errantry > player:get_flag_int32(bo2.ePlayerFlagInt32_Errantry)
        txt = sys.format("<errantry:%d>", errantry)
      elseif id == bo2.ePlayerFlagInt32_DooPointCur then
        local doopoint = f_num[i] * count
        local player = bo2.player
        is_red = player == nil or doopoint > player:get_flag_int32(bo2.ePlayerFlagInt32_DooPointCur)
        txt = sys.format("<doopoint:%d>", doopoint)
      end
    elseif obj_kind == bo2.eQuestObj_ReputePoint then
      local repute = bo2.gv_repute_list:find(f_id[i])
      local repute_info = ui.repute_find(repute.id)
      if repute ~= nil and repute_info ~= nil then
        if bFull ~= true then
          txt = ui_widget.merge_mtf({
            repute_name = repute.name,
            point = repute_info.canuse,
            count = f_num[i] * count
          }, ui.get_text("tool|reputePoint_cnt"))
        else
          txt = ui_widget.merge_mtf({
            repute_name = repute.name,
            point = repute_info.canuse,
            count = f_num[i] * count,
            repute_name = repute.name
          }, ui.get_text("tool|reputePoint_cnt_name"))
        end
        local repute_info = ui.repute_find(repute.id)
        if repute_info == nil or repute_info.canuse < f_num[i] then
          is_red = true
        end
        results.need_repute = true
      end
    elseif obj_kind == bo2.eQuestObj_CampReputeUseble then
      local mtf = {}
      mtf.count = f_num[i] * count
      if bFull ~= true then
        txt = sys.format("<camp_repute:%d>", mtf.count)
        mtf.count = f_num[i] * count
      else
        txt = ui_widget.merge_mtf(mtf, ui.get_text("tool|camp_reputePoint_cnt_name"))
      end
      is_red = ui_camp_repute.get_useble() < mtf.count
    elseif obj_kind == bo2.eQuestObj_ArenaRankAvailable then
      local mtf = {}
      mtf.count = f_num[i] * count
      if bFull ~= true then
        txt = sys.format("<camp_repute:%d,1>", mtf.count)
        mtf.count = f_num[i] * count
      else
        txt = ui_widget.merge_mtf(mtf, ui.get_text("tool|are_point_cnt_name"))
      end
      local available = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_PVPAvailablePoint)
      is_red = available < mtf.count
    end
    push_req()
  end
  for i = 0, req_obj.size - 1 do
    do_req(req_obj, req_id, req_num, i)
  end
  for i = 0, expend_obj.size - 1 do
    do_req(expend_obj, goods.expend_id, expend_num, i)
  end
  local price = goods.buy_price
  if price == 0 then
    return
  end
  txt = nil
  is_red = true
  price = price * count
  local currency = excel.currency
  if goods.use_self_define_currency ~= 0 then
    currency = goods.buy_currency
  end
  local player = bo2.player
  if player ~= nil then
    local m = player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
    if currency == bo2.eCurrency_CirculatedMoney then
      is_red = price > m
    else
      local bm = m + player:get_flag_int32(bo2.eFlagInt32_BoundedMoney)
      is_red = price > bm
    end
  end
  if currency == bo2.eCurrency_CirculatedMoney then
    txt = sys.format("<m:%d>", price)
  else
    txt = sys.format("<bm:%d>", price)
  end
  push_req()
end
local ctip_make_goods = function(stk, excel, info, goods)
  local req_obj = goods.req_obj
  local guild_req = false
  for i = 0, req_obj.size - 1 do
    local obj_kind = req_obj[i]
    local txt, color
    if obj_kind == bo2.eQuestObj_GuildBuilding then
      local build_type = goods.req_id[i]
      local excel = bo2.gv_guild_build:find(build_type)
      if excel ~= nil then
        local build_level = goods.req_num[i]
        txt = ui_widget.merge_mtf({
          name = excel.name,
          level = build_level
        }, ui.get_text("tool|guild_build_name_level"))
        local build = ui.guild_get_build(build_type)
        if build == nil or build_level > build.level then
          color = "FF0000"
        end
      end
    elseif obj_kind == bo2.eQuestObj_GuildWelfareLevel then
      local welfare_level = goods.req_num[i]
      txt = ui_widget.merge_mtf({level = welfare_level}, ui.get_text("tool|guild_welfare_level"))
      local member = ui.guild_get_self()
      if member == nil or welfare_level > member.welfare then
        color = "FF0000"
      end
    elseif obj_kind == bo2.eQuestObj_MarryDepth then
      local marry_depth = goods.req_num[i]
      txt = ui_widget.merge_mtf({depth = marry_depth}, ui.get_text("tool|marry_depth"))
      local cur_marry_depth = ui.get_marry_depth()
      if marry_depth > cur_marry_depth then
        color = "FF0000"
      end
    elseif obj_kind == bo2.eQuestObj_SwornDepth then
      local sworn_depth = goods.req_num[i]
      txt = ui_widget.merge_mtf({depth = sworn_depth}, ui.get_text("tool|sworn_depth"))
      local cur_sworn_depth = ui.get_sworn_depth_amount()
      if sworn_depth > cur_sworn_depth then
        color = "FF0000"
      end
    elseif obj_kind == bo2.eQuestObj_MasterLevel then
      local master_level = goods.req_num[i]
      txt = ui_widget.merge_mtf({level = master_level}, ui.get_text("tool|master_level"))
      local cur_master_level = ctip_get_atb(bo2.eAtb_Cha_MasterLevel)
      if master_level > cur_master_level then
        color = "FF0000"
      end
    elseif obj_kind == bo2.eQuestObj_ReputeLevel then
      local repute = bo2.gv_repute_list:find(goods.req_id[i])
      local repute_level = bo2.gv_repute_level:find(goods.req_num[i])
      if repute ~= nil and repute_level ~= nil then
        txt = ui_widget.merge_mtf({
          name = repute.name,
          level = repute_level.name
        }, ui.get_text("tool|repute_level"))
        local repute_info = ui.repute_find(repute.id)
        if repute_info == nil or repute_info.level < repute_level.id then
          color = "FF0000"
        else
          color = "00FF00"
        end
      end
    elseif obj_kind == bo2.eQuestObj_CampReputeLevel then
      local base_excel = ui_camp_repute.get_camp_repute_grade_by_id(goods.req_num[i])
      if base_excel ~= nil then
        local name = ui_camp_repute.get_title_text(base_excel)
        txt = ui_widget.merge_mtf({
          level = name,
          lv_count = base_excel.id
        }, ui.get_text("tool|camp_repute_level"))
        local excel = ui_camp_repute.get_camp_repute_grade()
        if excel == nil or excel.id < base_excel.id then
          color = "FF0000"
        else
          color = "00FF00"
        end
      end
    elseif obj_kind == bo2.eQuestObj_ArenaRank then
      local base_excel = bo2.gv_arena_rank:find(goods.req_num[i])
      if base_excel ~= nil then
        local get_excel_text = function(excel)
          local excel_text = bo2.gv_text:find(excel.desc_id)
          return excel_text.text
        end
        local name = get_excel_text(base_excel)
        txt = ui_widget.merge_mtf({lv_count = name}, ui.get_text("tool|arena_rank"))
        local excel = ui_personal.ui_match.get_arena_rank_excel()
        if excel == nil or excel.id < base_excel.id then
          color = "FF0000"
        else
          color = "00FF00"
        end
      end
    elseif obj_kind == bo2.eQuestObj_PlayerAtb then
      local req_id = goods.req_id[i]
      if req_id == bo2.eAtb_Level then
        local val = goods.req_num[i]
        if val > ctip_get_atb(bo2.eAtb_Level) then
          color = "FF0000"
        else
          color = "00FF00"
        end
        txt = ui_widget.merge_mtf({level = val}, ui.get_text("tool|req_level"))
      end
    end
    if txt ~= nil then
      if not guild_req then
        guild_req = true
        ctip_push_sep(stk)
        ctip_push_text(stk, ui.get_text("tool|purchase_requirement"))
        ctip_push_newline(stk)
      else
        ctip_push_newline(stk)
      end
      ctip_push_unwrap(stk, txt, color)
    end
  end
  ctip_push_sep(stk)
  ctip_push_text(stk, ui.get_text("tool|purchase_price"))
  ctip_make_goods_price(stk, excel, goods, nil, true)
  local expend_obj = goods.expend_obj
  local expend_id = goods.expend_id
  for i = 0, expend_obj.size - 1 do
    if expend_obj[i] == bo2.eQuestObj_ReputePoint then
      local repute_id = expend_id[i]
      local repute = bo2.gv_repute_list:find(repute_id)
      local repute_info = ui.repute_find(repute_id)
      if repute ~= nil and repute_info ~= nil then
        local canuse_tip = ui_widget.merge_mtf({
          repute_name = repute.name,
          point = repute_info.canuse
        }, ui.get_text("tool|can_use_tip"))
        ctip_push_newline(stk)
        ctip_push_text(stk, canuse_tip)
      end
    end
  end
end
local drop_type_name = ui.get_text("item|drop_type_title")
function ctip_make_drop_type(stk, drop_type, limit)
  if drop_type <= 0 then
    return false
  end
  local drop_list = bo2.item_drop_list_find(drop_type)
  if drop_list == nil then
    return false
  end
  local name, color
  local excel = bo2.gv_drop_type_info:find(drop_type)
  if excel then
    name = excel.name
    color = excel.color
  else
    name = drop_type_name
    color = cs_tip_color_white
  end
  ctip_make_title_ex(stk, name, color)
  ctip_push_sep(stk)
  stk:merge({
    n = "<c+:FF6600>" .. drop_list.size .. "<c->"
  }, ui.get_text("item|drop_type_desc"))
  ctip_push_sep(stk)
  local max = 999999
  if limit then
    max = 9
  end
  local cnt = drop_list.size
  local is_max = max < cnt
  if is_max then
    cnt = max
  end
  for i = 0, cnt - 1 do
    if i > 0 then
      stk:raw_push("\n")
    end
    stk:raw_push("<i:" .. drop_list:get(i) .. ">")
  end
  if is_max then
    stk:raw_push([[

......]])
  end
  return true
end
function ctip_make_item(stk, excel, info, card)
  if card ~= nil and card.drop_type > 0 and ctip_make_drop_type(stk, card.drop_type, true) then
    return
  end
  ctip_make_item_without_price(stk, excel, info, card)
  if info ~= nil then
    do
      local goods = info.goods
      if goods ~= nil then
        ctip_make_goods(stk, excel, info, goods)
      end
    end
  else
    local sell_price = excel.sell_price
    if sell_price == 0 then
    else
      ctip_push_sep(stk)
      ctip_push_text(stk, ui.get_text("tool|sell_price"))
      local currency = excel.currency
      if currency == bo2.eCurrency_CirculatedMoney then
        stk:raw_format("<m:%d>", sell_price)
      else
        stk:raw_format("<bm:%d>", sell_price)
      end
    end
  end
  if info ~= nil then
    local box = info.box
    if box >= bo2.eItemBox_BagBeg and box < bo2.eItemBox_BagEnd then
      if sys.is_type(excel, cs_tip_mb_data_gem_item) then
        local bag, bank, inlay = ui.item_count_gem(info.excel_id)
        if bank > 0 or inlay > 0 then
          local bagc = ui.item_get_count(info.excel_id, true)
          ctip_push_newline(stk)
          local txt = ui_widget.merge_mtf({
            total = bag + bank + inlay,
            bag = bag,
            bank = bank,
            gem = inlay
          }, ui.get_text("tool|tip_item_count_gem"))
          stk:raw_push("<rb:")
          stk:push(txt)
          stk:raw_push(">")
        end
      else
        local cnt = ui.item_box_get_count(bo2.eItemBox_Bank, info.excel_id)
        if cnt > 0 then
          local bagc = ui.item_get_count(info.excel_id, true)
          ctip_push_newline(stk)
          local txt = ui_widget.merge_mtf({
            total = cnt + bagc,
            bag = bagc,
            bank = cnt
          }, ui.get_text("tool|tip_item_count"))
          stk:raw_push("<rb:")
          stk:push(txt)
          stk:raw_push(">")
        end
      end
    end
  end
  if excel.deal_type == bo2.DealTypeBit_Jade and (not info or info:get_data_8(bo2.eItemByte_Bound) == 0) then
    ctip_push_newline(stk)
    ctip_push_text(stk, ui.get_text("item|only_rmb"), ui_tool.cs_tip_color_red)
  end
end
function ctip_make_equippack(stk, excel)
  local equip_pack_tab = {}
  ui_personal.ui_equip.get_equip_pack_from_item(equip_pack_tab)
  local idx = excel.id
  ui_tool.ctip_push_text(stk, ui.get_text("tool|equippack") .. idx, ui_tool.cs_tip_color_green)
  local equip_list_tab = equip_pack_tab[idx]
  for key, val2 in ipairs(equip_list_tab) do
    local equip_card = ui_personal.ui_equip.w_equip:search(val2.tp)
    local type_text = ui.get_text(sys.format(L("item|slot%d"), equip_card.grid))
    if equip_card.grid == 31 then
      type_text = ui.get_text("tool|fashion_hat")
    elseif equip_card.grid == 32 then
      type_text = ui.get_text("tool|fashion_clothes")
    end
    local item_text, item_text_color
    if val2.only_id == 0 then
      item_text = ""
    else
      local info = ui.item_of_only_id(val2.only_id)
      if info ~= nil then
        item_text = info.excel.name
        item_text_color = ui_tool.cs_tip_color_set_has
      else
        item_text = ui.get_text("tool|equip_not_exsit")
        item_text_color = ui_tool.cs_tip_color_set_no
      end
    end
    if key == 1 then
      ui_tool.ctip_push_sep(stk)
    else
      ui_tool.ctip_push_newline(stk)
    end
    ui_tool.ctip_push_text(stk, type_text .. ":")
    ui_tool.ctip_push_text(stk, item_text, item_text_color)
  end
end
function ctip_get_add_bases_atb_text(datas, fAddChg)
  local cnt = datas.size
  local atb_set = ctip_atb_set_create()
  for i = 0, cnt - 1 do
    ctip_atb_set_insert(atb_set, datas[i], fAddChg)
  end
  local text
  for n, d in ipairs(atb_set) do
    local temp_text
    if d.count == 1 then
      temp_text = sys.format("%s", d.desc) .. "\n"
    elseif d.min == nil then
      temp_text = sys.format("%s%d-%d", d.range.desc, 0, math.floor(d.max)) .. "\n"
    elseif d.max == nil then
      temp_text = sys.format("%s%d-%d", d.range.desc, math.floor(d.min), 0) .. "\n"
    else
      temp_text = sys.format("%s%d-%d", d.range.desc, math.floor(d.min + 0.5), math.floor(d.max)) .. "\n"
    end
    text = text .. temp_text
  end
  return text
end
